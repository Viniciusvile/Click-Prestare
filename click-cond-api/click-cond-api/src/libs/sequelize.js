const Sequelize = require("sequelize");
const { DB_DIALECT, DB_HOST, DB_NAME, DB_USER, DB_PASSWORD } = process.env;
const sequelize = new Sequelize(DB_NAME, DB_USER, DB_PASSWORD, {
  host: DB_HOST,
  dialect: DB_DIALECT,
  define: { timestamps: false, charset: "latin1", engine: "InnoDB" },
});

module.exports = {
  sequelize,
  Sequelize,
};
// sequelize
//   .authenticate()
//   .then(() => {
//     console.log("Connection has been established successfully.");
//   })
//   .catch((err) => {
//     console.error("Unable to connect to the database:", err);
//   });
