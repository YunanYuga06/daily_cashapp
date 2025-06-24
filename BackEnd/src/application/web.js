import express from "express";
import { publicRouter } from "../routes/public.api.js";
import { privateRouter } from "../routes/api.js";
import { errorMiddleware } from "../middlewares/error.middleware.js";
import cors from 'cors';
import path from 'path';

export const web = express();

web.use(cors());
web.use(express.json());
web.use(express.urlencoded({ extended: true }));

const __dirname = path.resolve(path.dirname(''));
web.use('/api/images', express.static(path.join(__dirname, 'public/images')));

web.use(publicRouter);
web.use(privateRouter);

web.use(errorMiddleware);