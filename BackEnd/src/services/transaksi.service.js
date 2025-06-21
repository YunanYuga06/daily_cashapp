import { prismaClient } from "../application/database.js";

const mapCategoryNames = async (summaryData) => {
    if (summaryData.length === 0) {
        return [];
    }

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

export default {
    getSummary
}