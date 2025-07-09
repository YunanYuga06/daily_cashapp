// BackEnd/src/validations/transaction.validation.js

import Joi from "joi";

const createTransactionValidation = Joi.object({
    id_category: Joi.number().required(),
    amount: Joi.number().positive().required(),
    type: Joi.string().valid('income', 'expense').required(),
    date: Joi.date().required(),
    id_asset: Joi.number().optional().allow(null),
    description: Joi.string().optional().allow('').allow(null)
});

export {
    createTransactionValidation
}