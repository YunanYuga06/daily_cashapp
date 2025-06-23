import jwt from "jsonwebtoken";

const SECRET_KEY = process.env.SECRET_KEY

export const authMiddleware = async (req, res, next) => {
    const token = req.get('Authorization')?.split(' ')[1];

    if (!token) {
        return res.status(401).json({ errors: "Unauthorized" }).end();
    }

    try {
        req.user = jwt.verify(token, SECRET_KEY);

        next();
    } catch (error) {
        return res.status(401).json({ errors: "Unauthorized" }).end();
    }
};