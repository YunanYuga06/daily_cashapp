import express from "express";
import { publicRouter } from "../routes/public.api.js";
import { privateRouter } from "../routes/api.js";
import { errorMiddleware } from "../middlewares/error.middleware.js";
import cors from 'cors';

export const web = express();

// 1. Middleware Dasar (didaftarkan satu kali di atas)
web.use(cors());
web.use(express.json());
web.use(express.urlencoded({ extended: true }));

// 2. Semua Router (publik dulu, baru privat)
web.use(publicRouter);
web.use(privateRouter); // Sekarang Express tahu tentang /api/categories

// 3. Error Middleware (WAJIB paling terakhir)
web.use(errorMiddleware);