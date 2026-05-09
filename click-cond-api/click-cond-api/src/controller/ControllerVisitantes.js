const db = require('../database/DB_Visitantes.js');

module.exports = {
  async insert(req, res) {
    try {
      await db.insert(req.body.id_condominio, req.body.visitante, req.session.user.id);
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async getAll(req, res) {
    try {
      const result = await db.getAll(req.query.id_condominio, req.query.offset, req.query.id_apto, req.query.search);
      return res.status(200).json(result);
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async remove(req, res) {
    try {
      await db.remove(req.body.id);
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async update(req, res) {
    try {
      await db.update(req.body.id_condominio, req.body.visitante);
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async get(req, res) {
    try {
      const result = await db.get(req.query.id_condominio, req.query.id);
      return res.status(200).json(result);
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },


};