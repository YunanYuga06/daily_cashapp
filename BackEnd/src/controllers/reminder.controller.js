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

const update = async (req, res, next) => {
    try {
        // Controller memanggil service, TIDAK menggunakan prismaClient secara langsung
        const result = await reminderService.update(req.params.id, req.user, req.body);
        res.status(200).json({
            data: result
        });
    } catch (e) {
        next(e);
    }
};

const remove = async (req, res, next) => {
    try {
        await reminderService.remove(req.params.id, req.user);
        res.status(200).json({
            data: "OK"
        });
    } catch (e) {
        next(e);
    }
};

export default {
    create,
    getAll,
    update,
    remove
};