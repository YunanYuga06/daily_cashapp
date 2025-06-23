// daily_cashapp/BackEnd/src/controllers/transaksi.controller.js

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

// BARIS BARU: Controller untuk membuat transaksi
const create = async (req, res, next) => {
    try {
        const result = await transactionService.create(req.user, req.body);
        res.status(200).json({ data: result });
    } catch (e) {
        next(e);
    }
}

// BARIS BARU: Controller untuk mendapatkan detail satu transaksi
const get = async (req, res, next) => {
    try {
        const transactionId = parseInt(req.params.transactionId); // Pastikan nama parameter sesuai route
        const result = await transactionService.get(req.user, transactionId);
        res.status(200).json({ data: result });
    } catch (e) {
        next(e);
    }
}

// BARIS BARU: Controller untuk memperbarui transaksi
const update = async (req, res, next) => {
    try {
        req.body.id = parseInt(req.params.transactionId); // Ambil ID dari parameter route dan tambahkan ke body
        const result = await transactionService.update(req.user, req.body);
        res.status(200).json({ data: result });
    } catch (e) {
        next(e);
    }
}

// BARIS BARU: Controller untuk menghapus transaksi
const remove = async (req, res, next) => {
    try {
        const transactionId = parseInt(req.params.transactionId); // Pastikan nama parameter sesuai route
        const result = await transactionService.remove(req.user, transactionId);
        res.status(200).json({ data: "OK" }); // Mengembalikan status OK jika berhasil
    } catch (e) {
        next(e);
    }
}

export default {
    getSummary,
    create,
    get,
    update,
    remove
}