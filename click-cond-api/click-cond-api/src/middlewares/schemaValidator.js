module.exports = (schema) => async (req, res, next) => {
  const { body } = req;
  try {
    await schema.validateAsync(body);
    next();
  } catch (err) {
    console.log(err);
    res.status(400).json({ message: "Bad Data", details: err.details });
  }
};
