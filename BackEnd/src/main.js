import {web} from "./application/web.js";
import {logger} from "./application/logging.js";
import dotenv from "dotenv";
import listEndpoints from 'express-list-routes';
dotenv.config();


web.listen(3000, '0.0.0.0', () => {
    logger.info("Server berjalan di port 3000");
    console.log("========== RUTE YANG TERDAFTAR ==========");
    listEndpoints(web);
    console.log("=========================================");
});