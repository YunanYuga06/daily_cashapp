import { validate } from "../validations/validation.js";
import { prismaClient } from "../application/database.js";
import { ResponseError } from "../error/response.error.js";
import {
    createBudgetValidation,
    getBudgetValidation,
    updateBudgetValidation
} from "../validations/budget.validation.js";

const create = async (user, request) => {
    const budget = validate(createBudgetValidation, request);
    budget.email_user = user.email;

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
            }
        }
    });
}

const get = async (user, budgetId) => {
    const id = validate(getBudgetValidation, { id: budgetId });

    const budget = await prismaClient.budget.findFirst({
        where: {
            id: id.id,
            email_user: user.email
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
            }
        }
    });

    if (!budget) {
        throw new ResponseError(404, "Budget not found");
    }

    return budget;
}

const getAll = async (user) => {
    return prismaClient.budget.findMany({
        where: {
            email_user: user.email
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
            }
        }
    });
}



export default {
    create,
    get,
    getAll
}