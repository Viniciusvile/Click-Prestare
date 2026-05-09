require('dotenv').config();
const { DB_DIALECT, DB_HOST, DB_NAME, DB_USER, DB_PASSWORD } = process.env;

const config = {
  username: DB_USER,
  password: DB_PASSWORD,
  database: DB_NAME,
  host: DB_HOST,
  dialect: DB_DIALECT,
};

module.exports = config;
