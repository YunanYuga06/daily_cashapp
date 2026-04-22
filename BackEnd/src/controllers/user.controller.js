import userService from "../services/user.service.js";
import { PrismaClient } from "@prisma/client";
import { supabase } from "../application/supabase.js";

const prisma = new PrismaClient();

/**
 * GET /api/users/test
 */
export const test = async (req, res) => {
  console.log("HALLO");
  return res.status(200).json({
    data: "HALLO",
  });
};

/**
 * POST /api/users
 */
export const register = async (req, res, next) => {
  try {
    const result = await userService.register(req.body);
    return res.status(200).json({
      data: result,
    });
  } catch (e) {
    return next(e);
  }
};

/**
 * POST /api/users/login
 */
export const login = async (req, res, next) => {
  try {
    const result = await userService.login(req.body);
    return res.status(200).json({
      data: result,
    });
  } catch (e) {
    return next(e);
  }
};

/**
 * GET /api/users
 * (public list users)
 */
export const getAllUsers = async (req, res, next) => {
  try {
    const users = await prisma.user.findMany({
      select: {
        email: true,
        name: true,
        password: true,
        image_url: true,
      },
    });

    return res.status(200).json({
      data: users,
    });
  } catch (e) {
    return next(e);
  }
};

/**
 * GET /api/users/current
 * (private, requires auth middleware)
 */
export const getCurrentUser = async (req, res, next) => {
  try {
    const result = await userService.get(req.user.username);
    return res.status(200).json({
      data: result,
    });
  } catch (e) {
    return next(e);
  }
};

/**
 * PATCH /api/users/current
 * (private, requires auth middleware)
 * Optional file upload -> sets image_url
 */
export const updateUser = async (req, res, next) => {
  try {
    const requestData = {
      name: req.body.name,
    };

    // Jika ada file gambar yang diupload
    if (req.file) {
      // 1. Buat nama file unik (misal: profile_yunanyuga_1701234567.png)
      const ext = req.file.mimetype === "image/png" ? "png" : "jpg";
      const fileName = `profile_${req.user.username}_${Date.now()}.${ext}`;

      // 2. Upload Buffer biner ke Supabase Storage (Bucket: 'avatars')
      const { data, error } = await supabase.storage
        .from('avatars') // <-- PASTIKAN ANDA MEMBUAT BUCKET INI DI SUPABASE
        .upload(fileName, req.file.buffer, {
          contentType: req.file.mimetype,
          upsert: true // Jika nama file sama, akan ditimpa (update)
        });

      if (error) {
        throw new Error("Gagal mengunggah gambar ke Supabase: " + error.message);
      }

      // 3. Dapatkan URL Publik dari file yang baru diupload
      const { data: publicUrlData } = supabase.storage
        .from('avatars')
        .getPublicUrl(fileName);

      // 4. Masukkan URL Publik tersebut ke dalam request data Prisma
      requestData.image_url = publicUrlData.publicUrl;
    }

    // 5. Simpan perubahan ke Database (Supabase PostgreSQL via Prisma)
    const result = await userService.updateUser(req.user.username, requestData);
    
    return res.status(200).json({
      data: result,
    });
  } catch (e) {
    return next(e);
  }
};
