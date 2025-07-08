import Joi from "joi";

const createReminderValidation = Joi.object({
    description: Joi.string().required(),
    amount: Joi.number().positive().required(),
    period: Joi.string().required(),
    date: Joi.date().required()
});

export {
    createReminderValidation
}