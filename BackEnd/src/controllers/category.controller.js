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

export default {
    getAll
}