import { validate } from "../validations/validation.js";
import {
  registerUserValidation,
  loginUserValidation,
} from "../validations/user.validation.js";
import { prismaClient } from "../application/database.js";
import { ResponseError } from "../error/response.error.js";
import * as bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

const register = async (request) => {
  const user = validate(registerUserValidation, request);

  const countUser = await prismaClient.user.count({
    where: { email: user.email },
  });

  if (countUser === 1) {
    throw new ResponseError(400, "Email already exists");
  }

  user.password = await bcrypt.hash(user.password, 10);

  const dataToCreate = {
    name: user.name,
    email: user.email,
    password: user.password,
  };

  return prismaClient.user.create({
    data: dataToCreate,
    select: {
      email: true,
      name: true,
    },
  });
};

const login = async (request) => {
  const loginRequest = validate(loginUserValidation, request);

  const user = await prismaClient.user.findUnique({
    where: { email: loginRequest.email },
    select: { email: true, password: true },
  });

  if (!user) {
    throw new ResponseError(401, "Email or password wrong");
  }

  const isPasswordValid = await bcrypt.compare(
    loginRequest.password,
    user.password
  );
  if (!isPasswordValid) {
    throw new ResponseError(401, "Email or password wrong");
  }

  const SECRET_KEY = process.env.SECRET_KEY;
  if (!SECRET_KEY) {
    throw new ResponseError(500, "Server misconfigured (SECRET_KEY missing)");
  }

  const token = jwt.sign({ username: user.email }, SECRET_KEY, {
    expiresIn: "30d",
  });

  return { token };
};

const get = async (userEmail) => {
  const user = await prismaClient.user.findUnique({
    where: { email: userEmail },
    select: {
      name: true,
      email: true,
      image_url: true,
    },
  });

  if (!user) {
    throw new ResponseError(404, "User tidak ditemukan");
  }

  return user;
};

const updateUser = async (userEmail, request) => {
  const dataToUpdate = {};

  if (request.name) dataToUpdate.name = request.name;
  if (request.image_url) dataToUpdate.image_url = request.image_url;

  if (Object.keys(dataToUpdate).length === 0) {
    throw new ResponseError(400, "Tidak ada data yang diperbarui");
  }

  return prismaClient.user.update({
    where: { email: userEmail },
    data: dataToUpdate,
    select: {
      name: true,
      email: true,
      image_url: true,
    },
  });
};

export default {
  register,
  login,
  get,
  updateUser,
};
