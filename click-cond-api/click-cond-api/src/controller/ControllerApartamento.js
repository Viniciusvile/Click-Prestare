const db = require('../database/DB_Apartamento.js');
const saveToAWS = require('../utils/saveToAWS');

module.exports = {
  async insert(req, res) {
    try {
      const {bloco, apto, fracao} = req.body.apartamento;
      const aptoId = await db.insertApto(bloco, apto, fracao, req.body.id_condominio);
      return res.json(aptoId);
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async getAll(req, res) {
    try {
      const result = await db.getAll(req.query.id_condominio, req.query.offset);
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
      const {id, bloco, apto, fracao} = req.body.apartamento;      
      const aptoId = await db.updateApto(id, bloco, apto, fracao, req.body.id_condominio);
      return res.json(aptoId);
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async getMoradores(req, res) {
    try {
      const result = await db.getMoradores(req.query.id_apto, req.query.tipo);
      return res.status(200).json(result);
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

};