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
        where: {
            id: id.id,
            email_user: user.username
        },
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
    // ...
    return budget;
}


const getAll = async (user) => {
    return prismaClient.budget.findMany({
        where: {
            email_user: user.username
        },
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
            // TAMBAHKAN BLOK DI BAWAH INI
            asset: {
                select: {
                    id: true,
                    asset_name: true
                }
            }
        }
    });
}



export default {
    create,
    get,
    getAll
}