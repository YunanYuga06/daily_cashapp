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


export const getCurrentUser = async (req, res, next) => {
    try {
        const result = await userService.get(req.user.username);
        res.status(200).json({ data: result });
    } catch (e) {
        next(e);
    }
};

export const updateUser = async (req, res, next) => {
    try {
        const requestData = {
            name: req.body.name,
        };
        if (req.file) {
            const baseUrl = `${req.protocol}://${req.get('host')}`;
            requestData.image_url = `${baseUrl}/api/images/${req.file.filename}`;
        }

        const result = await userService.update(req.user.username, requestData);
        res.status(200).json({ data: result });
    } catch (e) {
        next(e);
    }
};