import { prismaClient } from "../application/database.js";
import { validate } from "../validations/validation.js";
import { createTransactionValidation } from "../validations/transaction.validation.js";
import { ResponseError } from "../error/response.error.js";

const create = async (user, request) => {
    const transaction = validate(createTransactionValidation, request);
    if (!transaction.id_asset) {
        return prismaClient.transaction.create({
            data: {
                ...transaction,
                email_user: user.username,
            },
            select: { id: true, amount: true, type: true, date: true, description: true }
        });
    }

    return prismaClient.$transaction(async (prisma) => {
        const asset = await prisma.asset.findUnique({
            where: {
                id: transaction.id_asset,
                email_user: user.username
            }
        });

        if (!asset) {
            throw new ResponseError(404, "Aset tidak ditemukan");
        }
        if (transaction.type === 'expense' && asset.current_amount < transaction.amount) {
            throw new ResponseError(400, "Saldo aset tidak mencukupi untuk transaksi ini");
        }
        await prisma.asset.update({
            where: {
                id: transaction.id_asset
            },
            data: {
                current_amount: {
                    [transaction.type === 'income' ? 'increment' : 'decrement']: transaction.amount
                }
            }
        });

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

const update = async (id, email_user, request) => {
    const transactionId = parseInt(id);
    const data = request; 

    return prismaClient.$transaction(async (prisma) => {
        const existing = await prisma.transaction.findFirst({
            where: { id: transactionId, email_user: email_user }
        });

        if (!existing) {
            throw new ResponseError(404, "Transaksi tidak ditemukan atau Anda tidak memiliki akses");
        }
        if (existing.id_asset) {
            await prisma.asset.update({
                where: { id: existing.id_asset },
                data: {
                    current_amount: {
                        [existing.type === 'income' ? 'decrement' : 'increment']: existing.amount
                    }
                }
            });
        }
        if (data.id_asset) {
            const targetAsset = await prisma.asset.findUnique({
                where: { id: data.id_asset }
            });

            if (!targetAsset) {
                throw new ResponseError(404, "Aset tujuan tidak ditemukan");
            }
            if (data.type === 'expense' && targetAsset.current_amount < data.amount) {
                throw new ResponseError(400, "Saldo aset tidak mencukupi untuk perubahan transaksi ini");
            }

            await prisma.asset.update({
                where: { id: data.id_asset },
                data: {
                    current_amount: {
                        [data.type === 'income' ? 'increment' : 'decrement']: data.amount
                    }
                }
            });
        }
        return prisma.transaction.update({
            where: { id: transactionId },
            data: {
                id_category: data.id_category,
                id_asset: data.id_asset,
                amount: data.amount,
                type: data.type,
                description: data.description,
                date: new Date(data.date)
            }
        });
    });
};

const remove = async (id, email_user) => {
    const transactionId = parseInt(id);

    return prismaClient.$transaction(async (prisma) => {
        const existing = await prisma.transaction.findFirst({
            where: { id: transactionId, email_user: email_user }
        });

        if (!existing) {
            throw new ResponseError(404, "Transaksi tidak ditemukan atau Anda tidak memiliki akses");
        }
        if (existing.id_asset) {
            await prisma.asset.update({
                where: { id: existing.id_asset },
                data: {
                    current_amount: {
                        [existing.type === 'income' ? 'decrement' : 'increment']: existing.amount
                    }
                }
            });
        }
        return prisma.transaction.delete({
            where: { id: transactionId }
        });
    });
};

export default {
    create,
    getSummary,
    getAll,
    update,
    remove
}