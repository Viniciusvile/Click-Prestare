const jwt = require("jsonwebtoken");
const config = require("../configs/config");

module.exports = ({ typeAccess }) =>
  async function (req, res, next) {
    const token = req.headers["authorization"];
    if (!token || token.length > 2046)
      return res.status(401).json({ message: "INVALID_JWT" });
    try {
      const data = await getJwtData(token);
      console.log('[JWT] Decoded User:', data.login, 'Type:', data.typeAccess);
      if (typeAccess.includes(data.typeAccess) == false) {
        console.warn('[JWT] Unauthorized access attempt for:', data.typeAccess, 'Expected:', typeAccess);
        throw "UNAUTHORIZED";
      }
      req.session.user = data;
      next();
    } catch (err) {
      console.log(err);
      return res.status(401).json({ message: "INVALID_JWT" });
    }
  };

function getJwtData(token) {
  return new Promise((resolve, reject) => {
    jwt.verify(token, config.jwt.secretKey, function (err, decoded) {
      if (err) reject(err);
      resolve(decoded.user);
    });
  });
}