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

const update = async (id, user, request) => {
    const reminderId = parseInt(id);

    // Pastikan data ada dan milik user tersebut
    const existing = await prismaClient.reminder.findFirst({
        where: { id: reminderId, email_user: user.username }
    });

    if (!existing) {
        throw new ResponseError(404, "Pengingat tidak ditemukan");
    }

    return prismaClient.reminder.update({
        where: { id: reminderId },
        data: {
            description: request.description,
            amount: request.amount,
            period: request.period,
            date: new Date(request.date)
        },
        select: { id: true, description: true, amount: true, period: true, date: true }
    });
};

const remove = async (id, user) => {
    const reminderId = parseInt(id);

    const existing = await prismaClient.reminder.findFirst({
        where: { id: reminderId, email_user: user.username }
    });

    if (!existing) {
        throw new ResponseError(404, "Pengingat tidak ditemukan");
    }

    return prismaClient.reminder.delete({
        where: { id: reminderId }
    });
};

export default {
    create,
    getAll,
    update,
    remove
};