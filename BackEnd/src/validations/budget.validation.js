import Joi from "joi";

const createBudgetValidation = Joi.object({
    id_category: Joi.number().required(),
    amount: Joi.number().positive().required(),
    first_period: Joi.date().required(),
    last_period: Joi.date().required()
});

const updateBudgetValidation = Joi.object({
    id: Joi.number().positive().required(),
    id_category: Joi.number().optional(),
    amount: Joi.number().positive().optional(),
    first_period: Joi.date().optional(),
    last_period: Joi.date().optional()
});

const getBudgetValidation = Joi.object({
    id: Joi.number().positive().required()
});


export {
    createBudgetValidation,
    updateBudgetValidation,
    getBudgetValidation
}