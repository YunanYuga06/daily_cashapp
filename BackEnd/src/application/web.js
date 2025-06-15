import express from "express";
import { publicRouter } from "../routes/public.api.js";
import { errorMiddleware } from "../middlewares/error.middleware.js";
import cors from 'cors';
export const web = express();


web.use(express.json());
web.use(express.urlencoded({ extended: true }));

web.use(cors());
web.use(publicRouter);
web.use(errorMiddleware);
