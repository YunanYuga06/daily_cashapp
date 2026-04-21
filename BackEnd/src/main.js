import "dotenv/config";
import { web } from "./application/web.js";
import { logger } from "./application/logging.js";

// Optional debug: memastikan env kebaca
logger.info(`SECRET_KEY loaded: ${Boolean(process.env.SECRET_KEY)}`);

const PORT = process.env.PORT || 3000;

// Hanya jalankan 'listen' saat di lokal. Di Vercel, Vercel yang akan mengaturnya.
if (process.env.NODE_ENV !== 'production') {
    web.listen(PORT, () => {
        logger.info(`App start on port ${PORT}`);
    });
}


export default { web };