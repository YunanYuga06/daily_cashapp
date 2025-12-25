import userService from "../services/user.service.js";
import { PrismaClient } from "@prisma/client";

const prisma = new PrismaClient();

/**
 * GET /api/users/test
 */
export const test = async (req, res) => {
  console.log("HALLO");
  return res.status(200).json({
    data: "HALLO",
  });
};

/**
 * POST /api/users
 */
export const register = async (req, res, next) => {
  try {
    const result = await userService.register(req.body);
    return res.status(200).json({
      data: result,
    });
  } catch (e) {
    return next(e);
  }
};

/**
 * POST /api/users/login
 */
export const login = async (req, res, next) => {
  try {
    const result = await userService.login(req.body);
    return res.status(200).json({
      data: result,
    });
  } catch (e) {
    return next(e);
  }
};

/**
 * GET /api/users
 * (public list users)
 */
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

    return res.status(200).json({
      data: users,
    });
  } catch (e) {
    return next(e);
  }
};

/**
 * GET /api/users/current
 * (private, requires auth middleware)
 */
export const getCurrentUser = async (req, res, next) => {
  try {
    const result = await userService.get(req.user.username);
    return res.status(200).json({
      data: result,
    });
  } catch (e) {
    return next(e);
  }
};

/**
 * PATCH /api/users/current
 * (private, requires auth middleware)
 * Optional file upload -> sets image_url
 */
export const updateUser = async (req, res, next) => {
  try {
    const requestData = {
      name: req.body.name,
    };

    if (req.file) {
      const baseUrl = `${req.protocol}://${req.get("host")}`;
      requestData.image_url = `${baseUrl}/api/images/${req.file.filename}`;
    }

    const result = await userService.update(req.user.username, requestData);
    return res.status(200).json({
      data: result,
    });
  } catch (e) {
    return next(e);
  }
};
