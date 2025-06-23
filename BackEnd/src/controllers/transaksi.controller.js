import transactionService from "../services/transaksi.service.js";

const getSummary = async (req, res, next) => {
    try {
        const date = new Date();
        const year = parseInt(req.query.year) || date.getFullYear();
        const month = parseInt(req.query.month) || (date.getMonth() + 1);

        const result = await transactionService.getSummary(req.user, year, month);
        res.status(200).json({ data: result });
    } catch (e) {
        next(e);
    }
}

export default {
    getSummary
}