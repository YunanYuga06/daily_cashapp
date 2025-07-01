import { prismaClient } from "../application/database.js";

const getAll = async (user) => {
<<<<<<< HEAD
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
=======
    return prismaClient.asset.findMany({
        where: {
            email_user: user.username
        },
        select: {
            id: true,
            asset_name: true,
            asset_type: true
        }
    });
}

export default {
    getAll
}
>>>>>>> parent of cdfc6d6 (membuat crud tambah aset)
