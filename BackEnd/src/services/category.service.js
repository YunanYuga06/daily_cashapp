import { PrismaClient } from "@prisma/client";
import { ResponseError } from "../error/response.error.js";

const prisma = new PrismaClient();

const getAll = async () => {
    return prisma.category.findMany();
};

// --- TAMBAHKAN KODE DI BAWAH INI ---

const create = async (data) => {
    // Cek apakah nama kategori sudah ada (karena di schema name itu @unique)
    const existing = await prisma.category.findUnique({
        where: { name: data.name }
    });
    
    if (existing) {
        throw new ResponseError(400, "Kategori dengan nama ini sudah ada");
    }

    return prisma.category.create({
        data: {
            name: data.name,
            type: data.type,
            description: data.description
        }
    });
};

const update = async (id, data) => {
    const categoryId = parseInt(id);
    const existing = await prisma.category.findUnique({
        where: { id: categoryId }
    });

    if (!existing) {
        throw new ResponseError(404, "Kategori tidak ditemukan");
    }

    return prisma.category.update({
        where: { id: categoryId },
        data: {
            name: data.name,
            type: data.type,
            description: data.description
        }
    });
};

const remove = async (id) => {
    const categoryId = parseInt(id);
    const existing = await prisma.category.findUnique({
        where: { id: categoryId }
    });

    if (!existing) {
        throw new ResponseError(404, "Kategori tidak ditemukan");
    }

    // PENTING: Jika kategori ini sudah dipakai di tabel Transaksi/Budget, 
    // Prisma akan menolak penghapusan untuk mencegah data yatim (Foreign Key Constraint).
    return prisma.category.delete({
        where: { id: categoryId }
    });
};

export default {
    getAll,
    create,
    update,
    remove
};