import Joi from "joi";

const registerUserValidation = Joi.object({
    email: Joi.string().max(255).required(),
    password: Joi.string().max(255).required(),
    name: Joi.string().max(255).required()
});

const loginUserValidation = Joi.object({
    email: Joi.string().max(100).required(),
    password: Joi.string().max(100).required()
});

export {
    registerUserValidation, loginUserValidation
}
