const db = require('../database/DB_Mudancas.js');

module.exports = {
  async insert(req, res) {
    try {
      await db.insert(req.body.id_condominio, req.body.mudanca, req.session.user.id);
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async getAll(req, res) {
    try {
      if(req.session.user.typeAccess != 'Morador'){
        const result = await db.getAll(req.query.id_condominio, req.query.offset, null);
        return res.status(200).json(result);
      }else if(req.session.user.typeAccess == 'Morador'){
        const result = await db.getAll(req.query.id_condominio, req.query.offset, req.query.id_apto);
        return res.status(200).json(result);
      }
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
      await db.update(req.body.id_condominio, req.body.mudanca);
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async updateStatus(req, res) {
    console.log(111);
    try {
      await db.updateStatus(req.body.id_condominio, req.body.id, req.body.isAccept, req.body.motivo_recusa);
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