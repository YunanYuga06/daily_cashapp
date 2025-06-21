import express from "express";
import { authMiddleware } from "../middlewares/auth.middleware.js";
import budgetController from "../controllers/budget.controller.js";
import categoryController from "../controllers/category.controller.js";
import assetController from "../controllers/asset.controller.js";

const privateRouter = new express.Router();
privateRouter.use(authMiddleware);

privateRouter.get('/api/categories', categoryController.getAll);
privateRouter.get('/api/assets', assetController.getAll);
privateRouter.post('/api/budgets', budgetController.create);
privateRouter.get('/api/budgets', budgetController.getAll);
privateRouter.get('/api/budgets/:id', budgetController.get);
export {
    privateRouter
};