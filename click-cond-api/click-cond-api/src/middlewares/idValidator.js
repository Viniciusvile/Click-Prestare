const IdSchema = require("../schemas/IdSchema");
module.exports = async (req, res, next) => {
  const { id } = req.params;
  try {
    await IdSchema.validateAsync(id);
    next();
  } catch (err) {
    console.log(err);
    res.status(400).json({ message: "Bad Params", details: err.details });
  }
};
