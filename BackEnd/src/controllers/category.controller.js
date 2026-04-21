// daily_cashapp-main/BackEnd/src/controllers/category.controller.js

import categoryService from "../services/category.service.js";

const getAll = async (req, res, next) => {
    try {
        const result = await categoryService.getAll();
        res.status(200).json({
            data: result
        });
    } catch (e) {
        next(e);
    }
};

const create = async (req, res, next) => {
    try {
        const result = await categoryService.create(req.body);
        res.status(200).json({
            data: result
        });
    } catch (e) {
        next(e);
    }
};

const update = async (req, res, next) => {
    try {
        const result = await categoryService.update(req.params.id, req.body);
        res.status(200).json({
            data: result
        });
    } catch (e) {
        next(e);
    }
};

const remove = async (req, res, next) => {
    try {
        await categoryService.remove(req.params.id);
        res.status(200).json({
            data: "OK"
        });
    } catch (e) {
        next(e);
    }
};

export default {
    getAll,
    create,
    update,
    remove
}