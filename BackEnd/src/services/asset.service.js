import { prismaClient } from "../application/database.js";
import { validate } from "../validations/validation.js";
import { createAssetValidation } from "../validations/asset.validation.js";

const getAll = async (user) => {
  return prismaClient.asset.findMany({
    where: {
      email_user: user.username
    },
    select: {
      id: true,
      asset_name: true,
    }
  });
};

const create = async (user, request) => {
  const asset = validate(createAssetValidation, request);

  const dataToCreate = {
    ...asset,
    email_user: user.username,
    current_amount: asset.first_amount,
  };

  return prismaClient.asset.create({
    data: dataToCreate,
    select: {
      id: true,
      asset_name: true,
      asset_type: true,
      current_amount: true,
    },
  });
};

export default {
  getAll,
  create,
};