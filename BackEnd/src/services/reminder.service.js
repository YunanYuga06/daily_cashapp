import { prismaClient } from "../application/database.js";
import { validate } from "../validations/validation.js";
import { createReminderValidation } from "../validations/reminder.validation.js";

const create = async (user, request) => {
    const reminder = validate(createReminderValidation, request);
    reminder.email_user = user.username;

    return prismaClient.reminder.create({
        data: reminder,
        select: {
            id: true,
            description: true,
            amount: true,
            period: true,
            date: true
        }
    });
};

const getAll = async (user, year, month) => {
    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 0);

    return prismaClient.reminder.findMany({
        where: {
            email_user: user.username,
            date: {
                gte: startDate,
                lte: endDate,
            },
        },
        select: {
            id: true,
            description: true,
            amount: true,
            period: true,
            date: true
        }
    });
};

export default {
    create,
    getAll
};