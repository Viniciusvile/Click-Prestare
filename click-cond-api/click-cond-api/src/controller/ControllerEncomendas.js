const db = require('../database/DB_Encomendas.js');
const saveToAWS = require('../utils/saveToAWS');

module.exports = {
  /**
   * Lista encomendas para o síndico ou para o morador (filtrando pelo dele).
   */
  async getAll(req, res) {
    try {
      const { id_condominio, status } = req.query;
      let bloco = null;
      let apto = null;

      // Se for morador, filtra automaticamente pelo bloco/apto dele (segurança)
      if (req.session.user.typeAccess === 'Morador') {
        // Precisamos dos dados do morador para filtrar
        const dbMoradores = require('../database/DB_Moradores');
        const morador = await dbMoradores.get(req.session.user.id);
        // Note: m.apto_bloco e m.apto vêm do DB_Moradores.get via join com Apartamentos
        // Mas o get do DB_Moradores retorna as colunas mapeadas
        const conds = await dbMoradores.listCondominios(req.session.user.id);
        // Pega o primeiro condomínio da lista para simplificar (ou o id_condominio da query se for válido)
        const currentCond = conds.find(c => c.id == id_condominio) || conds[0];
        if (currentCond) {
            bloco = currentCond.apto_bloco;
            apto = currentCond.apto;
        }
      }

      const result = await db.getAll(id_condominio, status, bloco, apto);
      return res.status(200).json(result);
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async insert(req, res) {
    try {
      const { encomenda, id_condominio } = req.body;
      encomenda.id_condominio = id_condominio;
      
      if (encomenda.photo != null) {
        const urlPhoto = await saveToAWS(encomenda.photo, `condominios/${id_condominio}/encomendas`, 'volume');
        encomenda.foto_volume = urlPhoto.url;
      }
      
      await db.insert(encomenda);
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async retirar(req, res) {
    try {
      const { id, retirado_por } = req.body;
      await db.retirar(id, retirado_por);
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async get(req, res) {
    try {
      const result = await db.get(req.query.id);
      return res.status(200).json(result);
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  }
};
