import budgetService from "../services/budget.service.js";

const create = async (req, res, next) => {
    try {
        const result = await budgetService.create(req.user, req.body);
        res.status(200).json({ data: result });
    } catch (e) {
        next(e);
    }
};

const get = async (req, res, next) => {
    try {
        const budgetId = parseInt(req.params.id);
        const result = await budgetService.get(req.user, budgetId);
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

        const result = await budgetService.getAll(req.user, year, month);
        res.status(200).json({ data: result });
    } catch (e) {
        next(e);
    }
};

const update = async (req, res, next) => {
    try {
        const budgetId = parseInt(req.params.id);
        const result = await budgetService.update(req.user, budgetId, req.body);
        res.status(200).json({ data: result });
    } catch (e) {
        next(e);
    }
};

const remove = async (req, res, next) => {
    try {
        const budgetId = parseInt(req.params.id);
        await budgetService.remove(req.user, budgetId);
        res.status(200).json({ data: "OK" });
    } catch (e) {
        next(e);
    }
};

export default {
    create,
    get,
    getAll,
    update,
    remove 
};