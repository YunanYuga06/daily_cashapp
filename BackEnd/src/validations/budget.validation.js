import Joi from "joi";

const createBudgetValidation = Joi.object({
    id_category: Joi.number().required(),
    amount: Joi.number().positive().required(),
    first_period: Joi.date().required(),
    last_period: Joi.date().required(),
    id_asset: Joi.number().optional().allow(null),
    note: Joi.string().optional().allow('')
});

const updateBudgetValidation = Joi.object({
    id_category: Joi.number().required(),
    amount: Joi.number().positive().required(),
    first_period: Joi.date().required(),
    last_period: Joi.date().required(),
    id_asset: Joi.number().optional().allow(null),
    note: Joi.string().optional().allow('').allow(null)
});

const getBudgetValidation = Joi.object({
    id: Joi.number().positive().required()
});

export {
    createBudgetValidation,
    updateBudgetValidation,
    getBudgetValidation
}