// src/validations/asset.validation.js
import Joi from "joi";

const createAssetValidation = Joi.object({
  asset_name: Joi.string().max(255).required(),
  asset_type: Joi.string().max(255).required(),
  first_amount: Joi.number().min(0).required(),
});
const getAssetValidation = Joi.object({
  id: Joi.number().required(),
});

export { createAssetValidation, getAssetValidation };
