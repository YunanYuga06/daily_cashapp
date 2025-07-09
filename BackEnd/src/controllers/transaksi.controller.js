// daily_cashapp/BackEnd/src/controllers/transaksi.controller.js

import transactionService from "../services/transaksi.service.js";

// Fungsi untuk membuat transaksi baru
const create = async (req, res, next) => {
    try {
        // Memanggil service 'create' dengan data dari user dan body request
        const result = await transactionService.create(req.user, req.body);
        res.status(200).json({ data: result });
    } catch (e) {
        next(e);
    }
};

// Fungsi untuk mendapatkan ringkasan (summary) transaksi bulanan
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

// Fungsi untuk mendapatkan semua data transaksi dalam satu bulan
const getAll = async (req, res, next) => {
    try {
        const date = new Date();
        const year = parseInt(req.query.year) || date.getFullYear();
        const month = parseInt(req.query.month) || (date.getMonth() + 1);

        const result = await transactionService.getAll(req.user, year, month);
        res.status(200).json({ data: result });
    } catch (e) {
        next(e);
    }
}

// Mengekspor semua fungsi agar bisa digunakan oleh file routes
export default {
    create,
    getSummary,
    getAll
}