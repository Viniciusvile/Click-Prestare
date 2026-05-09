const db = require('../database/DB_Dashboard.js');
const jwt = require('jsonwebtoken');
const config = require('../configs/config');

module.exports = {
  async login(req, res) {
    try {
      const { login, password } = req.body;
      if(login != "admin@click.com" && password != "click@2023"){
        throw new Error('Login ou Senha incorretos');
      }

      var user = {nome: "Admin", typeAccess:"Admin"};

      const token = jwt.sign({ user: user }, config.jwt.secretKey, {});
      return res.json({ token: token, user: user });
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async getAllCondominios(req, res) {
    try {
      const list = await db.getAllCondominios();
      return res.status(200).json(list);
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async getDashboard(req, res) {
    try {
      const count_condominio = await db.getCountCondominio();
      const count_apartamentos = await db.getCountApartamentos();
      const count_moradores = await db.getCountMoradores();
      const condominios_dia = await db.getCondominiosDia();
      const condominios_localidade = await db.getCondominiosLocalidade();

      return res.status(200).json({count_condominio, count_apartamentos, count_moradores, condominios_dia, condominios_localidade});
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

};