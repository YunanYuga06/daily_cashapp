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
       asset_type: true,
       current_amount: true,
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
const update = async (id, user, request) => {
  const assetId = parseInt(id);

  // 1. Cari aset lama
  const existing = await prismaClient.asset.findFirst({
    where: { id: assetId, email_user: user.username }
  });

  if (!existing) {
    throw new ResponseError(404, "Aset tidak ditemukan atau bukan milik Anda");
  }

  // 2. Hitung selisih jika saldo awal (first_amount) diubah
  // Misal: dulu awal 100rb (sisa 50rb). Diedit awal jadi 150rb (+50rb). Maka sisa jadi 100rb.
  const difference = request.first_amount - existing.first_amount;
  const newCurrentAmount = existing.current_amount + difference;

  // 3. Update data aset
  return prismaClient.asset.update({
    where: { id: assetId },
    data: {
      asset_name: request.asset_name,
      asset_type: request.asset_type,
      first_amount: request.first_amount,
      current_amount: newCurrentAmount,
    },
    select: { id: true, asset_name: true, asset_type: true, current_amount: true }
  });
};

const remove = async (id, user) => {
  const assetId = parseInt(id);

  const existing = await prismaClient.asset.findFirst({
    where: { id: assetId, email_user: user.username }
  });

  if (!existing) {
    throw new ResponseError(404, "Aset tidak ditemukan atau bukan milik Anda");
  }

  // Catatan: Jika aset ini sudah dipakai di tabel Transaksi/Budget, 
  // Prisma secara otomatis akan menolak (error) untuk melindungi integritas data.
  return prismaClient.asset.delete({
    where: { id: assetId }
  });
};

export default {
  getAll,
  create,
  update,
  remove
};