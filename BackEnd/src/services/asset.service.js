import { prismaClient } from "../application/database.js";

const getAll = async (user) => {
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