// src/middlewares/upload.middleware.js
import multer from "multer";

function safeSlug(value) {
  return String(value || "unknown")
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9]+/g, "_")
    .replace(/^_+|_+$/g, "");
}

function extFromMime(mime) {
  if (mime === "image/png") return ".png";
  if (mime === "image/jpeg" || mime === "image/jpg") return ".jpg";
  return "";
}

const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, "public/images");
  },
  filename: (req, file, cb) => {
    const extension = extFromMime(file.mimetype);
    if (!extension) return cb(new Error("Format file tidak didukung"), "");

    // ✅ Ambil identifier dari JWT payload kamu (yang kamu pakai di controller)
    // Biasanya ini adalah email, tapi disimpan dalam field "username".
    const identifier =
      req.user?.email ||
      req.user?.username ||
      req.user?.email_user ||
      req.body?.email ||
      "unknown";

    const slug = safeSlug(identifier);

    // Nama file tetap per user
    cb(null, `profile_${slug}${extension}`);
  },
});

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
