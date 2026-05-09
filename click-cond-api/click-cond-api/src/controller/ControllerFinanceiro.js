const { formatRelativeWithOptions } = require('date-fns/fp');
const db = require('../database/DB_Financeiro.js');
const doubleToReal = require('../utils/doubleToReal.js');
const stringExtension = require('../utils/stringExtension.js');
const saveToAWS = require('../utils/saveToAWS');

module.exports = {
  async insert(req, res) {
    try {
      if(req.body.financeiro.tipo == 'D'){
        req.body.financeiro.valor = req.body.financeiro.valor * -1;
      }
      
      if(req.body.financeiro.photo != null){
        const urlPhotoProfile = await saveToAWS(req.body.financeiro.photo, `condominios/${req.body.id_condominio}/financeiro`, 'lancamento');
        req.body.financeiro.photo = urlPhotoProfile.url;
      }

      await db.insert(req.body.id_condominio, req.body.financeiro, req.session.user.name);
      return res.json();
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async getAll(req, res) {
    try {
      // CONSULTA MESES QUE TEM LANÇAMENTOS
      var meses = await db.getAllMeses(req.query.id_condominio);
      for (var i=0; i<meses.length; i++){
        const mes = meses[i];
        meses[i].periodo = stringExtension.convertMonthToReal(mes.mes, true)+'/'+mes.ano;
      }

      if(meses.length == 0){
        var today = new Date();
        var obj = {mes: today.getMonth()+1, ano: today.getFullYear(), periodo: ''};
        obj.periodo = stringExtension.convertMonthToReal(obj.mes, true)+'/'+obj.ano;
        meses.push(obj);
      }

      if(req.query.mes=='' || req.query.ano==''){
        req.query.mes = meses[meses.length-1].mes;
        req.query.ano = meses[meses.length-1].ano;
      }

      var getPendentes = req.session.user.typeAccess == "Sindico";

      const results = await db.getAll(req.query.id_condominio, req.query.mes, req.query.ano, getPendentes);

      // CONSULTA LANÇAMENTOS
      var arrayFinal = new Map();
      var saldo=-9999999;
      var dia = `${new Date().getDate()}/${req.query.mes}/${req.query.ano}`;
      for(var i=0; i<results.length; i++){       
        if(results[i].pago == 1){
          saldo = saldo == -9999999 ? results[i].valor : saldo += results[i].valor;
        }       
        if(results[i].ano < req.query.ano 
          || (results[i].ano == req.query.ano && results[i].mes < req.query.mes)          
          ){
            continue;
          }
        results[i].saldo=doubleToReal.convertDoubleToReal(saldo ?? 0);
        results[i].valorString=doubleToReal.convertDoubleToReal(results[i].valor ?? 0);
        if(arrayFinal[`${results[i].dia} de ${stringExtension.convertMonthToReal(results[i].mes, false)} de ${results[i].ano}`] == null){
          arrayFinal[`${results[i].dia} de ${stringExtension.convertMonthToReal(results[i].mes, false)} de ${results[i].ano}`] = [results[i]];
          dia = `${results[i].dia}/${req.query.mes}/${req.query.ano}`;
        }else{
          arrayFinal[`${results[i].dia} de ${stringExtension.convertMonthToReal(results[i].mes, false)} de ${results[i].ano}`].push(results[i]);
        }
      }
      saldo= saldo==-9999999 ? 0 : saldo;
      return res.status(200).json({lancamentos: arrayFinal, saldo: doubleToReal.convertDoubleToReal(saldo ?? 0), dia: dia, meses:meses});
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async getAllMoradores(req, res) {
    try {
      var meses = await db.getAllMeses(req.query.id_condominio);
      for (var i=0; i<meses.length; i++){
        const mes = meses[i];
        meses[i].periodo = stringExtension.convertMonthToReal(mes.mes, true)+'/'+mes.ano;
      }
      const result = await db.getAllMoradores(req.query.id_condominio, req.query.mes, req.query.ano);
      var listBlocos = [];
      var ultimoApto = null;
      result.forEach(function(apto, i) {
        apto.mes = req.query.mes;
        apto.ano = req.query.ano;
        apto.valor = apto.valor ?? 0.0;
        apto.valorReal = doubleToReal.convertDoubleToReal(apto.valor ?? 0);
        if(ultimoApto == null || ultimoApto.bloco != apto.bloco){
          listBlocos.push({bloco: apto.bloco, total: "", aptos: [apto]})
          console.log(apto.bloco);
        }else{
          listBlocos[listBlocos.length-1].aptos.push(apto);
        }
        ultimoApto = apto;
      });
      listBlocos.forEach(function(bloco, i) {
        var total = 0.0;
        bloco.aptos.forEach(function(apto, i) {
          total += apto.valor ?? 0.0;
        });
        listBlocos[i].total = doubleToReal.convertDoubleToReal(total);
      });
      return res.status(200).json({meses: meses, blocos: listBlocos});
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async getAllInadimplentes(req, res) {
    try {
      var meses = await db.getAllMeses(req.query.id_condominio);
      const result = await db.getAllInadimplentes(req.query.id_condominio, meses);   

      var listBlocos = [];
      var ultimoApto = null;
      result.forEach(function(apto, i) {               
        if(ultimoApto == null || ultimoApto.bloco != apto.bloco){
          listBlocos.push({bloco: apto.bloco, aptos: [apto]})
        }else{
          listBlocos[listBlocos.length-1].aptos.push(apto);
        }
        ultimoApto = apto;
      });

      return res.status(200).json({blocos: listBlocos});
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

  async getInadimplenteDetail(req, res) {
    try {
      var meses = await db.getAllMeses(req.query.id_condominio);
      const result = await db.getInadimplenteDetail(req.query.id_condominio, meses, req.query.apto, req.query.bloco);
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
      if(req.body.financeiro.tipo == 'D'){
        req.body.financeiro.valor = req.body.financeiro.valor * -1;
      }
      if(req.body.financeiro.photo != null){
        const urlPhotoProfile = await saveToAWS(req.body.financeiro.photo, `condominios/${req.body.id_condominio}/financeiro`, 'lancamento');
        await db.updatePhoto(urlPhotoProfile.url, req.body.financeiro.id);
      }
      await db.update(req.body.id_condominio, req.body.financeiro, req.session.user.name);
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

  async getGrafico(req, res) {
    try {
      var meses = await db.getAllMeses(req.query.id_condominio);
      for (var i=0; i<meses.length; i++){
        const mes = meses[i];
        meses[i].periodo = stringExtension.convertMonthToReal(mes.mes, true)+'/'+mes.ano;
      }

      const results = await db.getAllGrafico(req.query.id_condominio, req.query.mes, req.query.ano);

      var listCategs = [];
      var ultimoLancamento = null;
      var totalReceita = 0.0;
      var totalDespesa = 0.0;
      var saldo = 0.0;
      results.forEach(function(lancamento, i) {               
        if(ultimoLancamento == null || ultimoLancamento.categoria != lancamento.categoria){
          listCategs.push({categoria: lancamento.categoria, saldo: lancamento.valor, tipo: lancamento.tipo, percentual:0.0})
        }else{
          listCategs[listCategs.length-1].saldo += lancamento.valor;
        }
        if(lancamento.tipo == "C"){totalReceita += lancamento.valor;}
        if(lancamento.tipo == "D"){totalDespesa += lancamento.valor;}
        saldo += lancamento.valor;
        ultimoLancamento = lancamento;
      });

      listCategs.forEach(function(categ, i) {       
        var percentual = (categ.saldo * 100)/(totalReceita+(-1*totalDespesa));
        if(percentual < 0){percentual = percentual*-1;}
        listCategs[i].percentual = parseFloat(percentual.toFixed(2));
        listCategs[i].percentualString = percentual.toFixed(2)+"%";
        listCategs[i].saldoReal = doubleToReal.convertDoubleToReal(listCategs[i].saldo);
      });
      totalReceitaReal = doubleToReal.convertDoubleToReal(totalReceita);
      totalDespesaReal = doubleToReal.convertDoubleToReal(totalDespesa);
      percentualReceita = (totalReceita * 100)/(totalReceita+(-1*totalDespesa));
      percentualReceita = percentualReceita.toFixed(2)+"%";
      percentualDespesa = (totalDespesa * -1 * 100)/(totalReceita+(-1*totalDespesa));
      percentualDespesa = percentualDespesa.toFixed(2)+"%";
      saldoReal = doubleToReal.convertDoubleToReal(saldo);

      return res.status(200).json({meses:meses, categorias: listCategs, totalReceita, totalDespesa, saldo, saldoReal, totalReceitaReal, totalDespesaReal, percentualReceita, percentualDespesa});
    } catch (err) {
      return res.status(500).json({ message: err.message });
    }
  },

};