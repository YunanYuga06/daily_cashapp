// daily_cashapp/BackEnd/src/validations/transaksi.validation.js

import Joi from "joi";

const createTransactionValidation = Joi.object({
    id_category: Joi.number().required(),
    id_asset: Joi.number().optional().allow(null), // id_asset bisa opsional atau null
    amount: Joi.number().positive().required(), // jumlah harus angka positif
    type: Joi.string().valid('income', 'expense').required(), // type harus 'income' atau 'expense'
    description: Joi.string().optional().allow(''), // deskripsi bisa opsional atau string kosong
    date: Joi.date().required(), // tanggal wajib diisi
});

const getTransactionValidation = Joi.object({
    id: Joi.number().positive().required() // id transaksi harus angka positif
});

const updateTransactionValidation = Joi.object({
    id_category: Joi.number().optional(),
    id_asset: Joi.number().optional().allow(null),
    amount: Joi.number().positive().optional(),
    type: Joi.string().valid('income', 'expense').optional(),
    description: Joi.string().optional().allow(''),
    date: Joi.date().optional(),
});

export {
    createTransactionValidation,
    getTransactionValidation,
    updateTransactionValidation
}