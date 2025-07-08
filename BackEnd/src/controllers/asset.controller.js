import assetService from "../services/asset.service.js";

const getAll = async (req, res, next) => {
  try {
    const result = await assetService.getAll(req.user);
    res.status(200).json({
      data: result,
    });
  } catch (e) {
    next(e);
  }
};

const create = async (req, res, next) => {
  try {
    const result = await assetService.create(req.user, req.body);
    res.status(200).json({ data: result });
  } catch (e) {
    next(e);
  }
};

export default {
  getAll,
  create,
};
