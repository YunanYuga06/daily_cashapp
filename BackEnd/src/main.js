import {web} from "./application/web.js";
import {logger} from "./application/logging.js";

web.listen(3000, '0.0.0.0', () => {
    logger.info("Server berjalan di port 3000");
});
