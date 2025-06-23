import { prismaClient } from "../application/database.js";
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