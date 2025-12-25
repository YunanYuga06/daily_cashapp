import express from "express";
import cors from "cors";
import path from "path";
import morgan from "morgan";

import { publicRouter } from "../routes/public.api.js";
import { privateRouter } from "../routes/api.js";
import { errorMiddleware } from "../middlewares/error.middleware.js";

export const web = express();

web.use(cors());
web.use(express.json());
web.use(express.urlencoded({ extended: true }));

// Static untuk gambar profile (opsional)
const __dirname = path.resolve(path.dirname(""));
web.use("/api/images", express.static(path.join(__dirname, "public/images")));

// ✅ Morgan custom format: hanya 1 baris "Ada request METHOD ke URL"
morgan.token("msg", (req) => {
  return `Ada request ${req.method} ke ${req.originalUrl}`;
});

// ✅ skip biar tidak spam request selain /api (opsional)
web.use(
  morgan(":msg", {
    skip: (req) => !req.originalUrl.startsWith("/api"),
  })
);

// ✅ PENTING: publicRouter HARUS DI ATAS privateRouter
web.use(publicRouter);
web.use(privateRouter);

// Error handler terakhir
web.use(errorMiddleware);
