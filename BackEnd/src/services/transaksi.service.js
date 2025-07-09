import { prismaClient } from "../application/database.js";
import { validate } from "../validations/validation.js";
import { createTransactionValidation } from "../validations/transaction.validation.js";
import { ResponseError } from "../error/response.error.js";

// Fungsi untuk membuat transaksi baru DENGAN pembaruan saldo aset
const create = async (user, request) => {
    const transaction = validate(createTransactionValidation, request);

    // Jika transaksi TIDAK terhubung dengan aset, langsung buat transaksi saja
    if (!transaction.id_asset) {
        return prismaClient.transaction.create({
            data: {
                ...transaction,
                email_user: user.username,
            },
            select: { id: true, amount: true, type: true, date: true, description: true }
        });
    }

    // Jika terhubung dengan aset, gunakan database transaction
    // Ini memastikan kedua operasi (update aset & create transaksi) berhasil atau gagal bersamaan
    return prismaClient.$transaction(async (prisma) => {
        // 1. Cari aset yang dipilih untuk memastikan aset itu ada dan milik user
        const asset = await prisma.asset.findUnique({
            where: {
                id: transaction.id_asset,
                email_user: user.username
            }
        });

        if (!asset) {
            throw new ResponseError(404, "Aset tidak ditemukan");
        }

        // 2. Jika ini adalah pengeluaran, cek dulu apakah saldonya mencukupi
        if (transaction.type === 'expense' && asset.current_amount < transaction.amount) {
            throw new ResponseError(400, "Saldo aset tidak mencukupi untuk transaksi ini");
        }

        // 3. Perbarui saldo aset berdasarkan jenis transaksi
        await prisma.asset.update({
            where: {
                id: transaction.id_asset
            },
            data: {
                current_amount: {
                    // Gunakan 'increment' untuk pemasukan, 'decrement' untuk pengeluaran
                    [transaction.type === 'income' ? 'increment' : 'decrement']: transaction.amount
                }
            }
        });

        // 4. Setelah aset diupdate, baru buat catatan transaksinya
        const newTransaction = await prisma.transaction.create({
            data: {
                ...transaction,
                email_user: user.username,
            },
            select: { id: true, amount: true, type: true, date: true, description: true }
        });

        return newTransaction;
    });
};


// --- FUNGSI LAINNYA (TETAP SAMA) ---

const mapCategoryNames = async (summaryData) => {
    if (summaryData.length === 0) return [];
    const categoryIds = summaryData.map(item => item.id_category);
    const categories = await prismaClient.category.findMany({
        where: { id: { in: categoryIds } },
        select: { id: true, name: true }
    });
    const categoryNameMap = new Map(categories.map(c => [c.id, c.name]));
    return summaryData.map(item => ({
        ...item,
        categoryName: categoryNameMap.get(item.id_category) || "Lainnya"
    }));
};

const getSummary = async (user, year, month) => {
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 1);
    const totalIncomeResult = await prismaClient.transaction.aggregate({
        _sum: { amount: true },
        where: { email_user: user.username, type: 'income', date: { gte: startDate, lt: endDate } }
    });
    const totalIncome = totalIncomeResult._sum.amount || 0;
    const incomeByCategoryRaw = await prismaClient.transaction.groupBy({
        by: ['id_category'],
        _sum: { amount: true },
        where: { email_user: user.username, type: 'income', date: { gte: startDate, lt: endDate } }
    });
    const incomeByCategory = await mapCategoryNames(incomeByCategoryRaw);
    const totalExpenseResult = await prismaClient.transaction.aggregate({
        _sum: { amount: true },
        where: { email_user: user.username, type: 'expense', date: { gte: startDate, lt: endDate } }
    });
    const totalExpense = totalExpenseResult._sum.amount || 0;
    const expenseByCategoryRaw = await prismaClient.transaction.groupBy({
        by: ['id_category'],
        _sum: { amount: true },
        where: { email_user: user.username, type: 'expense', date: { gte: startDate, lt: endDate } }
    });
    const expenseByCategory = await mapCategoryNames(expenseByCategoryRaw);
    return {
        totalIncome,
        totalExpense,
        totalNet: totalIncome - totalExpense,
        incomeByCategory,
        expenseByCategory
    };
};

const getAll = async (user, year, month) => {
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 1);
    return prismaClient.transaction.findMany({
        where: {
            email_user: user.username,
            date: { gte: startDate, lt: endDate },
        },
        include: {
            category: { select: { id: true, name: true } },
            asset: { select: { id: true, asset_name: true } }
        },
        orderBy: { date: 'desc' }
    });
};

export default {
    create,
    getSummary,
    getAll
}