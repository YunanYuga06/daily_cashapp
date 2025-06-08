import userService from "../services/user.service.js";

const test = async (req, res) => {
    console.log("HALLO");
    res.status(200).json({
        data: "HALLO"
    })
};

const register = async (req, res, next) => {
    try {
        const result = await userService.register(req.body);
        res.status(200).json({
            data: result
        });
    } catch (e) {
        next(e);
    }
}

export default {
    test, register
}
