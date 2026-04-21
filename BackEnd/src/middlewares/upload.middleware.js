// src/middlewares/upload.middleware.js
import multer from "multer";

const storage = multer.memoryStorage(); // File akan disimpan sebagai Buffer di RAM sementara

const fileFilter = (req, file, cb) => {
  const ok =
    file.mimetype === "image/jpeg" ||
    file.mimetype === "image/png" ||
    file.mimetype === "image/jpg";

  if (ok) cb(null, true);
  else cb(new Error("Hanya file gambar (JPEG, PNG, JPG) yang diizinkan!"), false);
};

const upload = multer({
  storage,
  limits: { fileSize: 1024 * 1024 * 5 }, // 5MB
  fileFilter,
});

export default upload;