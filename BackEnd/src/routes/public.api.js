import express from "express";
import {
  test,
  register,
  login,
  getAllUsers,
} from "../controllers/user.controller.js";

const publicRouter = new express.Router();

// Test route
publicRouter.get("/api/users/test", test);

// Auth routes
publicRouter.post("/api/users", register);
publicRouter.post("/api/users/login", login);

// List users (public)
publicRouter.get("/api/users", getAllUsers);

export { publicRouter };
