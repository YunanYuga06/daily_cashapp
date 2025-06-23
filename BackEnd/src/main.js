import {web} from "./application/web.js";
import {logger} from "./application/logging.js";
import dotenv from "dotenv";

dotenv.config();

// --- Tambahkan baris ini di sini ---
console.log('DEBUG: Nilai SECRET_KEY setelah dotenv.config():', process.env.SECRET_KEY);
// ------------------------------------

web.listen(3000, '0.0.0.0', () => {
    logger.info("Server berjalan di port 3000");
});