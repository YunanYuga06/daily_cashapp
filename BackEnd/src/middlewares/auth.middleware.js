import jwt from "jsonwebtoken";

export const authMiddleware = async (req, res, next) => {
  const authHeader = req.get("Authorization");
  const token = authHeader?.split(" ")[1];

  if (!token) {
    return res.status(401).json({ errors: "Unauthorized" }).end();
  }

  try {
    const SECRET_KEY = process.env.SECRET_KEY;
    if (!SECRET_KEY) {
      return res
        .status(500)
        .json({ errors: "Server misconfigured (SECRET_KEY missing)" })
        .end();
    }

    req.user = jwt.verify(token, SECRET_KEY);
    next();
  } catch (error) {
    return res.status(401).json({ errors: "Unauthorized" }).end();
  }
};
