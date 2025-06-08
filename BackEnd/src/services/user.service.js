import {validate} from "../validations/validation.js";
import {registerUserValidation} from "../validations/user.validation.js";
import {prismaClient} from "../application/database.js";
import {ResponseError} from "../error/response.error.js";
import * as bcrypt from "bcrypt";

const SECRET_KEY = process.env.SECRET_KEY;

const register = async (request) => {
    const user = validate(registerUserValidation, request);

    const countUser = await prismaClient.user.count({
        where: {
            email: user.email
        }
    });

    if (countUser === 1) {
        throw new ResponseError(400, "Email already exists");
    }

    user.password = await bcrypt.hash(user.password, 10);

    return prismaClient.user.create({
        data: user,
        select: {
            email: true,
            name: true
        }
    });
}

export default {
    register
}