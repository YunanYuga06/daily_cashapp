// daily_cashapp/BackEnd/src/routes/api.js

import express from "express";
import { authMiddleware } from "../middlewares/auth.middleware.js";
import budgetController from "../controllers/budget.controller.js";
import categoryController from "../controllers/category.controller.js";
import assetController from "../controllers/asset.controller.js";
import transactionController from "../controllers/transaksi.controller.js"; // Import controller transaksi

const privateRouter = new express.Router();
privateRouter.use(authMiddleware);

// Routes yang sudah ada
privateRouter.get('/api/categories', categoryController.getAll);
privateRouter.get('/api/assets', assetController.getAll);
privateRouter.post('/api/budgets', budgetController.create);
privateRouter.get('/api/budgets', budgetController.getAll);
privateRouter.get('/api/budgets/:id', budgetController.get);
privateRouter.get('/api/transactions/summary', transactionController.getSummary);

// BARIS BARU: Tambahkan route untuk Transaksi CRUD
privateRouter.post('/api/transactions', transactionController.create); // CREATE
privateRouter.get('/api/transactions/:transactionId', transactionController.get); // READ (single)
privateRouter.put('/api/transactions/:transactionId', transactionController.update); // UPDATE
privateRouter.delete('/api/transactions/:transactionId', transactionController.remove); // DELETE

export {
    privateRouter
};