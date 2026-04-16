import "dotenv/config";
import { web } from "./application/web.js";
import { logger } from "./application/logging.js";

// Optional debug: memastikan env kebaca
logger.info(`SECRET_KEY loaded: ${Boolean(process.env.SECRET_KEY)}`);

web.listen(8080, "0.0.0.0", () => {
  logger.info("Server berjalan di port 3000");
});
