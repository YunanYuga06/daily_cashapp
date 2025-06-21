// daily_cashapp-main/BackEnd/src/services/category.service.js

import { prismaClient } from "../application/database.js";

// Fungsi untuk mengambil semua kategori
const getAll = async () => {
    return prismaClient.category.findMany({
        select: {
            id: true,
            name: true,
            type: true
        }
    });
}

export default {
    getAll
}