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

// Semua route di bawah ini butuh token
privateRouter.use(authMiddleware);

// User Routes
privateRouter.get("/api/users/current", userController.getCurrentUser);
privateRouter.put(
  "/api/users/current",
  upload.single("profile_picture"),
  userController.updateUser
);

// Category Routes
privateRouter.get("/api/categories", categoryController.getAll);
privateRouter.post("/api/categories", categoryController.create); // <-- Tambah ini
privateRouter.put("/api/categories/:id", categoryController.update); // <-- Tambah ini
privateRouter.delete("/api/categories/:id", categoryController.remove);

// Asset Routes
privateRouter.get("/api/assets", assetController.getAll);
privateRouter.post("/api/assets", assetController.create);
privateRouter.put("/api/assets/:id", assetController.update);
privateRouter.delete("/api/assets/:id", assetController.remove);

// Budget Routes
privateRouter.post("/api/budgets", budgetController.create);
privateRouter.get("/api/budgets", budgetController.getAll);
privateRouter.get("/api/budgets/:id", budgetController.get);
privateRouter.put("/api/budgets/:id", budgetController.update);
privateRouter.delete("/api/budgets/:id", budgetController.remove);

// Transaction Routes
privateRouter.get("/api/transactions/summary", transactionController.getSummary);
privateRouter.post("/api/transactions", transactionController.create);
privateRouter.get("/api/transactions", transactionController.getAll);
privateRouter.put("/api/transactions/:id", transactionController.update);
privateRouter.delete("/api/transactions/:id", transactionController.remove);

// Reminder Routes
privateRouter.get("/api/reminders", reminderController.getAll);
privateRouter.post("/api/reminders", reminderController.create);
privateRouter.put("/api/reminders/:id", reminderController.update);
privateRouter.delete("/api/reminders/:id", reminderController.remove);

export { privateRouter };
