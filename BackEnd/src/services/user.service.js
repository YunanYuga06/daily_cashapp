import {validate} from "../validations/validation.js";
import {registerUserValidation, loginUserValidation} from "../validations/user.validation.js";
import {prismaClient} from "../application/database.js";
import {ResponseError} from "../error/response.error.js";
import * as bcrypt from "bcrypt";
import jwt from "jsonwebtoken";

const SECRET_KEY = process.env.SECRET_KEY;
console.log('DEBUG: SECRET_KEY dari process.env di userservice.js:', SECRET_KEY); // Tetap biarkan ini

const register = async (request) => {
    // ...
}

const login = async (request, res) => {
    const loginRequest = validate(loginUserValidation, request);

    const user = await prismaClient.user.findUnique({
        where: {
            email: loginRequest.email
        },
        select: {
            email: true,
            password: true
        }
    });

    if (!user) {
        throw new ResponseError(401, "Email or password wrong");
    }

    const isPasswordValid = await bcrypt.compare(loginRequest.password, user.password);
    if (!isPasswordValid) {
        throw new ResponseError(401, "Email or password wrong");
    }

    // --- Tambahkan pemeriksaan ini sebelum jwt.sign ---
    if (!SECRET_KEY) {
        console.error("ERROR: SECRET_KEY is undefined or null when trying to sign JWT!");
        throw new ResponseError(500, "Server configuration error: JWT secret not found."); // Beri pesan error yang lebih jelas
    }
    // ----------------------------------------------------

    const token = jwt.sign({username: user.email}, SECRET_KEY, {expiresIn: '1h'});

    return {
        token: token
    };
}

export default {
    register, login
}