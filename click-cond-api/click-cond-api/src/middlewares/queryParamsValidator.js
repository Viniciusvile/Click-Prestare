module.exports = (schema) => async (req, res, next) => {
  const { query } = req;
  try {
    const re = await schema.validateAsync(query);
    next();
  } catch (err) {
    console.log(err);
    res.status(400).json({ message: "Bad Data", details: err.details });
  }
};
