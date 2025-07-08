import express from "express";
import { authMiddleware } from "../middlewares/auth.middleware.js";
import * as userController from "../controllers/user.controller.js";
import budgetController from "../controllers/budget.controller.js";
import categoryController from "../controllers/category.controller.js";
import assetController from "../controllers/asset.controller.js";
import transactionController from "../controllers/transaksi.controller.js";
import reminderController from "../controllers/reminder.controller.js";
import upload from "../middlewares/upload.middleware.js";

const privateRouter = new express.Router();
privateRouter.use(authMiddleware);
privateRouter.get("/api/users/current", userController.getCurrentUser);
privateRouter.put("/api/users/current", upload.single("profile_picture"), userController.updateUser);
privateRouter.get("/api/categories", categoryController.getAll);
privateRouter.get("/api/assets", assetController.getAll);
privateRouter.post("/api/assets", assetController.create);
privateRouter.post("/api/budgets", budgetController.create);
privateRouter.get("/api/budgets", budgetController.getAll);
privateRouter.get("/api/budgets/:id", budgetController.get);
privateRouter.get("/api/transactions/summary", transactionController.getSummary);
privateRouter.put("/api/budgets/:id", budgetController.update);
privateRouter.delete("/api/budgets/:id", budgetController.remove);

// Rute untuk Reminder (diperbaiki)
privateRouter.post("/api/reminders", reminderController.create); // Pastikan "reminders"
privateRouter.get("/api/reminders", reminderController.getAll);   // Pastikan "reminders"

export { privateRouter };