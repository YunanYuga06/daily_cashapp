import "dotenv/config";
import { web } from "./application/web.js";
import { logger } from "./application/logging.js";

// Optional debug: memastikan env kebaca
logger.info(`SECRET_KEY loaded: ${Boolean(process.env.SECRET_KEY)}`);

// Hanya jalankan 'listen' secara manual jika TIDAK berjalan di Vercel (production)
if (process.env.NODE_ENV !== 'production') {
  web.listen(8080, "0.0.0.0", () => {
    logger.info("Server berjalan di port 8080");
  });
}

// INI ADALAH BARIS PALING PENTING UNTUK VERCEL:
export default web;