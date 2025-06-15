import userService from "../services/user.service.js";
import { PrismaClient } from "@prisma/client";
const prisma = new PrismaClient();

export const test = async (req, res) => {
    console.log("HALLO");
    res.status(200).json({
        data: "HALLO"
    });
};

export const register = async (req, res, next) => {
    try {
        const result = await userService.register(req.body);
        res.status(200).json({
            data: result
        });
    } catch (e) {
        next(e);
    }
};

export const login = async (req, res, next) => {
    try {
        const result = await userService.login(req.body);
        res.status(200).json({
            data: result
        });
    } catch (e) {
        next(e);
    }
};

export const getAllUsers = async (req, res, next) => {
    try {
        const users = await prisma.user.findMany({
            select: {
                email: true,
                name: true,
                password: true,
                image_url: true,
            },
        });
        res.status(200).json({ data: users });
    } catch (e) {
        next(e);
    }
};