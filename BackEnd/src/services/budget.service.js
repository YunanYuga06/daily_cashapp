import { validate } from "../validations/validation.js";
import { prismaClient } from "../application/database.js";
import { ResponseError } from "../error/response.error.js";
import {
    createBudgetValidation,
    getBudgetValidation,
    updateBudgetValidation
} from "../validations/budget.validation.js";



const create = async (user, request) => {
    return prismaClient.budget.create({
        data: budget,
        select: {
            id: true,
            amount: true,
            first_period: true,
            last_period: true,
            category: {
                select: {
                    id: true,
                    name: true
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
}


const get = async (user, budgetId) => {
    const budget = await prismaClient.budget.findFirst({
        where: { id: budgetId, email_user: user.username },
        select: {
            id: true, amount: true, first_period: true, last_period: true,
            id_category: true, id_asset: true,
            category: { select: { id: true, name: true } },
            asset: { select: { id: true, asset_name: true } }
        }
    });

    if (!budget) throw new ResponseError(404, "Budget tidak ditemukan");

    const transactionWhereClause = {
        email_user: user.username, type: 'expense', id_category: budget.id_category,
        date: { gte: budget.first_period, lte: budget.last_period },
    };
    if (budget.id_asset) {
        transactionWhereClause.id_asset = budget.id_asset;
    }

    const spentResult = await prismaClient.transaction.aggregate({
        _sum: { amount: true },
        where: transactionWhereClause,
    });

    return { ...budget, spent: spentResult._sum.amount || 0 };
};

const getAll = async (user, year, month) => {
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0);

    const budgets = await prismaClient.budget.findMany({
        where: {
            email_user: user.username,
            first_period: {
                lte: endDate,
            },
            last_period: {
                gte: startDate,
            },
        },
        select: {
            id: true, amount: true, first_period: true, last_period: true,
            id_category: true, id_asset: true,
            category: { select: { id: true, name: true } },
            asset: { select: { id: true, asset_name: true } }
        }
    });
    const budgetsWithSpent = await Promise.all(budgets.map(async (budget) => {
        const transactionWhereClause = {
            email_user: user.username, type: 'expense', id_category: budget.id_category,
            date: { gte: budget.first_period, lte: budget.last_period },
        };
        if (budget.id_asset) {
            transactionWhereClause.id_asset = budget.id_asset;
        }

        const spentResult = await prismaClient.transaction.aggregate({
            _sum: { amount: true },
            where: transactionWhereClause,
        });

        return { ...budget, spent: spentResult._sum.amount || 0 };
    }));

    return budgetsWithSpent;
};


const update = async (user, budgetId, request) => {
    const budgetRequest = validate(updateBudgetValidation, request);
    const totalBudgetInDatabase = await prismaClient.budget.count({
        where: {
            email_user: user.username,
            id: budgetId
        }
    });

    if (totalBudgetInDatabase !== 1) {
        throw new ResponseError(404, "Budget tidak ditemukan");
    }

    return prismaClient.budget.update({
        where: {
            id: budgetId
        },
        data: budgetRequest,
        select: {
            id: true,
            amount: true,
            category: { select: { name: true } }
        }
    });
};

const remove = async (user, budgetId) => {
    const totalBudgetInDatabase = await prismaClient.budget.count({
        where: {
            email_user: user.username,
            id: budgetId
        }
    });

    if (totalBudgetInDatabase !== 1) {
        throw new ResponseError(404, "Budget tidak ditemukan");
    }
    return prismaClient.budget.delete({
        where: {
            id: budgetId
        }
    });
};


export default {
    create,
    get,
    getAll,
    update,
    remove
};