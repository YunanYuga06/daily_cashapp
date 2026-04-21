import reminderService from "../services/reminder.service.js";

const create = async (req, res, next) => {
    try {
        const result = await reminderService.create(req.user, req.body);
        res.status(200).json({ data: result });
    } catch (e) {
        next(e);
    }
};

const getAll = async (req, res, next) => {
    try {
        const date = new Date();
        const year = parseInt(req.query.year) || date.getFullYear();
        const month = parseInt(req.query.month) || (date.getMonth() + 1);

        const result = await reminderService.getAll(req.user, year, month);
        res.status(200).json({ data: result });
    } catch (e) {
        next(e);
    }
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