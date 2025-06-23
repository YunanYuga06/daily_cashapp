// daily_cashapp/BackEnd/src/services/transaksi.service.js

import { prismaClient } from "../application/database.js";
import { validate } from "../validations/validation.js";
import { ResponseError } from "../error/response.error.js";
import {
    createTransactionValidation,
    getTransactionValidation,
    updateTransactionValidation
} from "../validations/transaksi.validation.js"; // Import validasi transaksi


// Fungsi helper untuk memetakan ID kategori ke nama kategori
const mapCategoryNames = async (summaryData) => {
    if (summaryData.length === 0) {
        return [];
    }

    const categoryIds = summaryData.map(item => item.id_category);
    const categories = await prismaClient.category.findMany({
        where: { id: { in: categoryIds } },
        select: { id: true, name: true, type: true } // Sertakan 'type' juga di sini
    });
    const categoryNameMap = new Map(categories.map(c => [c.id, c.name]));
    const categoryTypeMap = new Map(categories.map(c => [c.id, c.type]));

    return summaryData.map(item => ({
        ...item,
        categoryName: categoryNameMap.get(item.id_category) || "Lainnya",
        categoryType: categoryTypeMap.get(item.id_category) || "unknown" // Tambahkan 'categoryType'
    }));
};

// Fungsi untuk mendapatkan ringkasan transaksi (total pemasukan/pengeluaran per bulan)
const getSummary = async (user, year, month) => {
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 1);

    // --- Pemasukan ---
    const totalIncomeResult = await prismaClient.transaction.aggregate({
        _sum: { amount: true },
        where: {
            email_user: user.username,
            type: 'income',
            date: { gte: startDate, lt: endDate }
        }
    });
    const totalIncome = totalIncomeResult._sum.amount || 0;

    const incomeByCategoryRaw = await prismaClient.transaction.groupBy({
        by: ['id_category'],
        _sum: { amount: true },
        where: {
            email_user: user.username,
            type: 'income',
            date: { gte: startDate, lt: endDate }
        }
    });
    const incomeByCategory = await mapCategoryNames(incomeByCategoryRaw);


    // --- Pengeluaran ---
    const totalExpenseResult = await prismaClient.transaction.aggregate({
        _sum: { amount: true },
        where: {
            email_user: user.username,
            type: 'expense',
            date: { gte: startDate, lt: endDate }
        }
    });
    const totalExpense = totalExpenseResult._sum.amount || 0;

    const expenseByCategoryRaw = await prismaClient.transaction.groupBy({
        by: ['id_category'],
        _sum: { amount: true },
        where: {
            email_user: user.username,
            type: 'expense',
            date: { gte: startDate, lt: endDate }
        }
    });
    const expenseByCategory = await mapCategoryNames(expenseByCategoryRaw);

    return {
        totalIncome,
        totalExpense,
        totalNet: totalIncome - totalExpense,
        incomeByCategory,
        expenseByCategory
    };
}

// Fungsi untuk membuat transaksi baru (CREATE)
const create = async (user, request) => {
    const transaction = validate(createTransactionValidation, request);
    transaction.email_user = user.username; // Otomatis tambahkan email user dari token otentikasi

    return prismaClient.transaction.create({
        data: transaction,
        select: {
            id: true,
            amount: true,
            type: true,
            description: true,
            date: true,
            category: { // Sertakan data kategori
                select: {
                    id: true,
                    name: true,
                    type: true
                }
            },
            asset: { // Sertakan data aset (jika ada)
                select: {
                    id: true,
                    asset_name: true
                }
            }
        }
    });
};

// Fungsi untuk mendapatkan detail satu transaksi berdasarkan ID (READ - single)
const get = async (user, transactionId) => {
    const idValidated = validate(getTransactionValidation, { id: transactionId }); // Validasi id yang diberikan

    const result = await prismaClient.transaction.findFirst({
        where: {
            id: idValidated.id,
            email_user: user.username
        },
        select: {
            id: true,
            amount: true,
            type: true,
            description: true,
            date: true,
            category: {
                select: {
                    id: true,
                    name: true,
                    type: true
                }
            },
            asset: {
                select: {
                    id: true,
                    asset_name: true
                }
            }
        }
    });

    if (!result) {
        throw new ResponseError(404, "Transaksi tidak ditemukan");
    }
    return result;
};

// Fungsi untuk memperbarui transaksi (UPDATE)
const update = async (user, request) => {
    const transactionRequest = validate(updateTransactionValidation, request);

    // Validasi bahwa ID transaksi ada di request
    if (!transactionRequest.id) {
        throw new ResponseError(400, "ID transaksi wajib diisi untuk pembaruan.");
    }

    // Pastikan transaksi yang akan diupdate milik user yang sedang login
    const checkTransaction = await prismaClient.transaction.count({
        where: {
            id: transactionRequest.id,
            email_user: user.username
        }
    });

    if (checkTransaction === 0) {
        throw new ResponseError(404, "Transaksi tidak ditemukan atau bukan milik Anda");
    }

    return prismaClient.transaction.update({
        where: {
            id: transactionRequest.id,
            email_user: user.username
        },
        data: transactionRequest,
        select: {
            id: true,
            amount: true,
            type: true,
            description: true,
            date: true,
            category: {
                select: {
                    id: true,
                    name: true,
                    type: true
                }
            },
            asset: {
                select: {
                    id: true,
                    asset_name: true
                }
            }
        }
    });
};

// Fungsi untuk menghapus transaksi (DELETE)
const remove = async (user, transactionId) => {
    const idValidated = validate(getTransactionValidation, { id: transactionId });

    // Pastikan transaksi yang akan dihapus milik user yang sedang login
    const checkTransaction = await prismaClient.transaction.count({
        where: {
            id: idValidated.id,
            email_user: user.username
        }
    });

    if (checkTransaction === 0) {
        throw new ResponseError(404, "Transaksi tidak ditemukan atau bukan milik Anda");
    }

    await prismaClient.transaction.delete({
        where: {
            id: idValidated.id,
            email_user: user.username
        }
    });

    return "OK"; // Mengembalikan status 'OK' jika berhasil dihapus
};


export default {
    getSummary,
    create,
    get,
    update,
    remove
}