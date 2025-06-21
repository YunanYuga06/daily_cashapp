import budgetService from "../services/budget.service.js";

const create = async (req, res, next) => {
    try {
        const result = await budgetService.create(req.user, req.body);
        res.status(200).json({ data: result });
    } catch (e) {
        next(e);
    }
}

const get = async (req, res, next) => {
    try {
        const budgetId = parseInt(req.params.id);
        const result = await budgetService.get(req.user, budgetId);
        res.status(200).json({ data: result });
    } catch (e) {
        next(e);
    }
}

const getAll = async (req, res, next) => {
    try {
        const result = await budgetService.getAll(req.user);
        res.status(200).json({ data: result });
    } catch (e) {
        next(e);
    }
}

export default {
    create,
    get,
    getAll
}