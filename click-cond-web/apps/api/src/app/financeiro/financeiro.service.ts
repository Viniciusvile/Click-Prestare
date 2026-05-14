import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class FinanceiroService {
  constructor(private readonly prisma: PrismaService) {}

  // ==========================================
  // CRUD PRINCIPAL
  // ==========================================
  async insert(idCondominio: number, financeiro: any, operatorName: string) {
    if (!this.prisma.isConnected) return { success: true };

    let valor = parseFloat(financeiro.valor || 0);
    if (financeiro.tipo === 'D') {
      valor = Math.abs(valor) * -1;
    }

    let photoUrl = financeiro.photo ?? '';
    if (photoUrl && photoUrl.startsWith('data:')) {
      photoUrl = 'https://example.com/comprovante_mock.jpg';
    }

    const parseDate = (dStr?: string) => {
      if (!dStr) return null;
      if (dStr.includes('/')) {
        const parts = dStr.split('/');
        return new Date(Number(parts[2]), Number(parts[1]) - 1, Number(parts[0]));
      }
      return new Date(dStr);
    };

    const dLanc = parseDate(financeiro.data);
    const dVenc = parseDate(financeiro.data_vencimento);

    const isPago = (!financeiro.data || financeiro.data === '') ? 0 : 1;

    await this.prisma.financeiro.create({
      data: {
        nome: financeiro.nome,
        tipo: financeiro.tipo,
        valor,
        data: dLanc,
        data_vencimento: dVenc,
        categoria: financeiro.categoria ?? 'Geral',
        conta: financeiro.conta ?? null,
        descricao: financeiro.descricao ?? null,
        cliente: financeiro.cliente ?? null,
        forma_pagamento: financeiro.forma_pagamento ?? null,
        parcelas: financeiro.parcelas ?? null,
        nome_operador: operatorName,
        id_condominio: Number(idCondominio),
        photo: photoUrl,
        pago: isPago,
        url_boleto: financeiro.url_boleto ?? null,
        status: financeiro.status ? String(financeiro.status) : '0',
        id_usuario: financeiro.id_usuario ? Number(financeiro.id_usuario) : null,
      },
    });

    return { success: true };
  }

  async update(idCondominio: number, financeiro: any, operatorName: string) {
    if (!this.prisma.isConnected) return { success: true };

    let valor = parseFloat(financeiro.valor || 0);
    if (financeiro.tipo === 'D') {
      valor = Math.abs(valor) * -1;
    }

    let photoUrl = financeiro.photo ?? undefined;
    if (photoUrl && photoUrl.startsWith('data:')) {
      photoUrl = 'https://example.com/comprovante_mock_updated.jpg';
    }

    const parseDate = (dStr?: string) => {
      if (!dStr) return null;
      if (dStr.includes('/')) {
        const parts = dStr.split('/');
        return new Date(Number(parts[2]), Number(parts[1]) - 1, Number(parts[0]));
      }
      return new Date(dStr);
    };

    const dLanc = parseDate(financeiro.data);
    const dVenc = parseDate(financeiro.data_vencimento);

    await this.prisma.financeiro.updateMany({
      where: {
        id: Number(financeiro.id),
        id_condominio: Number(idCondominio),
      },
      data: {
        nome: financeiro.nome,
        tipo: financeiro.tipo,
        valor,
        ...(dLanc !== null ? { data: dLanc } : {}),
        ...(dVenc !== null ? { data_vencimento: dVenc } : {}),
        categoria: financeiro.categoria,
        conta: financeiro.conta,
        descricao: financeiro.descricao,
        cliente: financeiro.cliente,
        forma_pagamento: financeiro.forma_pagamento,
        parcelas: financeiro.parcelas,
        nome_operador: operatorName,
        ...(photoUrl !== undefined ? { photo: photoUrl } : {}),
        ...(financeiro.pago !== undefined ? { pago: Number(financeiro.pago) } : {}),
        ...(financeiro.status !== undefined ? { status: String(financeiro.status) } : {}),
      },
    });

    return { success: true };
  }

  async remove(id: number) {
    if (!this.prisma.isConnected) return { success: true };
    await this.prisma.financeiro.delete({ where: { id: Number(id) } });
    return { success: true };
  }

  async get(idCondominio: number, id: number, user: any) {
    if (!this.prisma.isConnected) {
      return {
        id, nome: 'Taxa Condominial', tipo: 'C', valor: 650.0,
        data_vencimento: '10/05/2026', data: '10/05/2026',
        categoria: 'Taxa Condominial', pago: 1, id_usuario: null,
      };
    }

    const result = await this.prisma.financeiro.findFirst({
      where: { id: Number(id), id_condominio: Number(idCondominio) },
    });

    if (!result) throw new NotFoundException('Lançamento não encontrado.');

    // Isolamento de dados para moradores
    const isMorador = user?.typeAccess === 'Morador';
    if (isMorador && result.id_usuario && result.id_usuario !== user.id) {
      throw new NotFoundException('Acesso negado: Lançamento pertence a outro condômino.');
    }

    const fmt = (d?: Date | null) => d ? d.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric' }) : '';

    return {
      id: result.id,
      nome: result.nome,
      tipo: result.tipo,
      valor: result.valor ? Number(result.valor) : 0,
      data_vencimento: fmt(result.data_vencimento),
      data: fmt(result.data),
      categoria: result.categoria,
      conta: result.conta,
      descricao: result.descricao,
      cliente: result.cliente,
      forma_pagamento: result.forma_pagamento,
      parcelas: result.parcelas,
      photo: result.photo,
      pago: result.pago,
      id_usuario: result.id_usuario,
    };
  }

  // ==========================================
  // LISTAGEM E AGRUPAMENTO GERAL
  // ==========================================
  async getAll(idCondominio: number, mesStr?: string, anoStr?: string, isSindico: boolean = true) {
    if (!this.prisma.isConnected) {
      return {
        lancamentos: {
          '10 de Maio de 2026': [
            { id: 1, nome: 'Taxa Condominial Apto 101', tipo: 'C', valorString: 'R$ 650,00', valor: 650, pago: 1, categoria: 'Receitas', status: '1' },
            { id: 2, nome: 'Manutenção de Elevadores', tipo: 'D', valorString: '-R$ 1.200,00', valor: -1200, pago: 1, categoria: 'Despesas', status: '1' },
          ],
        },
        saldo: 'R$ 12.500,00',
        totalReceita: 'R$ 18.000,00',
        totalDespesa: 'R$ 5.500,00',
        dia: '14/05/2026',
        meses: [{ mes: '05', ano: '2026', periodo: 'Maio/2026' }],
      };
    }

    // Identificar meses disponíveis
    const mesesDisponiveis = await this.getAllMeses(idCondominio);

    let mes = mesStr ? Number(mesStr) : 5;
    let ano = anoStr ? Number(anoStr) : 2026;

    if (mesesDisponiveis.length > 0 && (!mesStr || !anoStr)) {
      const ult = mesesDisponiveis[mesesDisponiveis.length - 1];
      mes = Number(ult.mes);
      ano = Number(ult.ano);
    }

    // Montar intervalo
    const dataIni = new Date(ano, mes - 1, 1);
    const dataFim = new Date(ano, mes, 0); // último dia do mês

    const whereClause: any = {
      id_condominio: Number(idCondominio),
      OR: [
        { data: { gte: dataIni, lte: dataFim } },
        { data_vencimento: { gte: dataIni, lte: dataFim } },
      ],
    };

    if (!isSindico) {
      whereClause.pago = 1;
    }

    const list = await this.prisma.financeiro.findMany({
      where: whereClause,
      orderBy: [{ data: 'asc' }, { data_vencimento: 'asc' }],
    });

    const lancamentosMap: Record<string, any[]> = {};
    let saldo = 0;
    let totalReceita = 0;
    let totalDespesa = 0;
    let ultimoDiaFmt = `01/${mes < 10 ? '0' + mes : mes}/${ano}`;

    const mesesNomes = ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];

    for (const item of list) {
      const v = item.valor ? Number(item.valor) : 0;
      if (item.pago === 1) {
        saldo += v;
        if (v > 0) totalReceita += v;
        else totalDespesa += v;
      }

      const refDate = item.data || item.data_vencimento || item.created_at;
      const d = refDate.getDate();
      const m = refDate.getMonth();
      const y = refDate.getFullYear();

      const chave = `${d} de ${mesesNomes[m]} de ${y}`;
      ultimoDiaFmt = `${d < 10 ? '0' + d : d}/${m + 1 < 10 ? '0' + (m + 1) : m + 1}/${y}`;

      const formatReal = (num: number) => {
        return num.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
      };

      const formatado = {
        id: item.id,
        nome: item.nome,
        tipo: item.tipo,
        valor: v,
        valorString: formatReal(v),
        saldoString: formatReal(saldo),
        categoria: item.categoria,
        nome_operador: item.nome_operador,
        pago: item.pago,
        status: item.status,
        url_boleto: item.url_boleto,
        url_comprovante: item.url_comprovante,
      };

      if (!lancamentosMap[chave]) {
        lancamentosMap[chave] = [];
      }
      lancamentosMap[chave].push(formatado);
    }

    const formatRealGeral = (n: number) => n.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });

    return {
      lancamentos: lancamentosMap,
      saldo: formatRealGeral(saldo),
      totalReceita: formatRealGeral(totalReceita),
      totalDespesa: formatRealGeral(totalDespesa),
      dia: ultimoDiaFmt,
      meses: mesesDisponiveis,
    };
  }

  // ==========================================
  // INADIMPLÊNCIA E TAXAS DE MORADORES
  // ==========================================
  async getAllMoradores(idCondominio: number, mesStr: string, anoStr: string) {
    if (!this.prisma.isConnected) return { meses: [], blocos: [] };

    const meses = await this.getAllMeses(idCondominio);
    const aptos = await this.prisma.apartamentos.findMany({
      where: { id_condominio: Number(idCondominio) },
      orderBy: [{ bloco: 'asc' }, { apto: 'asc' }],
    });

    const blocosMap: Record<string, any[]> = {};

    for (const a of aptos) {
      const matchName = `Apto ${a.apto} Bloco ${a.bloco} - Ref. ${mesStr}/${anoStr}`;
      const fin = await this.prisma.financeiro.findFirst({
        where: {
          id_condominio: Number(idCondominio),
          nome: matchName,
        },
      });

      const val = fin?.valor ? Number(fin.valor) : 0;
      const fmt = val.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });

      const itemApto = {
        apto_id: a.id,
        bloco: a.bloco,
        apto: a.apto,
        valor: val,
        valorReal: fmt,
        financeiro_id: fin?.id ?? null,
        pago: fin?.pago ?? 0,
        conta: fin?.conta ?? '',
        descricao: fin?.descricao ?? '',
      };

      if (!blocosMap[a.bloco]) {
        blocosMap[a.bloco] = [];
      }
      blocosMap[a.bloco].push(itemApto);
    }

    const listBlocos = Object.keys(blocosMap).map(b => {
      const listaAptos = blocosMap[b];
      const totBloco = listaAptos.reduce((acc, curr) => acc + curr.valor, 0);
      return {
        bloco: b,
        total: totBloco.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' }),
        aptos: listaAptos,
      };
    });

    return { meses, blocos: listBlocos };
  }

  async getAllInadimplentes(idCondominio: number) {
    if (!this.prisma.isConnected) {
      return {
        blocos: [
          {
            bloco: 'A',
            aptos: [{ bloco: 'A', apto: '102', qtd: 2 }, { bloco: 'A', apto: '204', qtd: 1 }],
          },
        ],
      };
    }

    const meses = await this.getAllMeses(idCondominio);
    if (meses.length === 0) return { blocos: [] };

    const aptos = await this.prisma.apartamentos.findMany({
      where: { id_condominio: Number(idCondominio) },
      orderBy: [{ bloco: 'asc' }, { apto: 'asc' }],
    });

    const blocosMap: Record<string, any[]> = {};

    for (const a of aptos) {
      // Checar em quantos dos meses faturados este apartamento possui `pago = 1`
      let pagosCount = 0;
      for (const m of meses) {
        const matchName = `Apto ${a.apto} Bloco ${a.bloco} - Ref. ${m.mes}/${m.ano}`;
        const fin = await this.prisma.financeiro.findFirst({
          where: {
            id_condominio: Number(idCondominio),
            nome: matchName,
            pago: 1,
          },
        });
        if (fin) pagosCount++;
      }

      const devendoCount = meses.length - pagosCount;
      if (devendoCount > 0) {
        if (!blocosMap[a.bloco]) blocosMap[a.bloco] = [];
        blocosMap[a.bloco].push({
          bloco: a.bloco,
          apto: a.apto,
          qtd: devendoCount,
        });
      }
    }

    const listBlocos = Object.keys(blocosMap).map(b => ({
      bloco: b,
      aptos: blocosMap[b],
    }));

    return { blocos: listBlocos };
  }

  async getInadimplenteDetail(idCondominio: number, apto: string, bloco: string) {
    if (!this.prisma.isConnected) {
      return [{ mes: '03', ano: '2026', periodo: 'Março/2026' }, { mes: '04', ano: '2026', periodo: 'Abril/2026' }];
    }

    const meses = await this.getAllMeses(idCondominio);
    const mesesDevendo: any[] = [];

    for (const m of meses) {
      const anoCurto = m.ano.slice(-2);
      // Nomes possiveis gerados no banco legado: MM/YY ou MM/YYYY
      const matchName1 = `Apto ${apto} Bloco ${bloco} - Ref. ${m.mes}/${m.ano}`;
      const matchName2 = `Apto ${apto} Bloco ${bloco} - Ref. ${m.mes}/${anoCurto}`;

      const fin = await this.prisma.financeiro.findFirst({
        where: {
          id_condominio: Number(idCondominio),
          OR: [{ nome: matchName1 }, { nome: matchName2 }],
        },
      });

      // Se não encontrou o lançamento pago, está devendo esse mês
      if (!fin || fin.pago === 0) {
        mesesDevendo.push(m);
      }
    }

    return mesesDevendo;
  }

  // ==========================================
  // GRÁFICOS E COMPARTILHAMENTO DE ARQUIVOS
  // ==========================================
  async getGrafico(idCondominio: number, mesStr: string, anoStr: string) {
    if (!this.prisma.isConnected) {
      return {
        meses: [{ mes: '05', ano: '2026', periodo: 'Maio/2026' }],
        categorias: [
          { categoria: 'Taxas Condominiais', saldo: 15000, saldoReal: 'R$ 15.000,00', percentualString: '80.00%', tipo: 'C' },
          { categoria: 'Manutenção', saldo: -3000, saldoReal: '-R$ 3.000,00', percentualString: '20.00%', tipo: 'D' },
        ],
        totalReceitaReal: 'R$ 15.000,00',
        totalDespesaReal: '-R$ 3.000,00',
        saldoReal: 'R$ 12.000,00',
        percentualReceita: '83.33%',
        percentualDespesa: '16.67%',
      };
    }

    const meses = await this.getAllMeses(idCondominio);
    const mes = Number(mesStr);
    const ano = Number(anoStr);

    const dataIni = new Date(ano, mes - 1, 1);
    const dataFim = new Date(ano, mes, 0);

    const list = await this.prisma.financeiro.findMany({
      where: {
        id_condominio: Number(idCondominio),
        pago: 1,
        OR: [
          { data: { gte: dataIni, lte: dataFim } },
          { data_vencimento: { gte: dataIni, lte: dataFim } },
        ],
      },
      orderBy: { categoria: 'asc' },
    });

    const categsMap: Record<string, { saldo: number; tipo: string }> = {};
    let totalReceita = 0;
    let totalDespesa = 0;
    let saldo = 0;

    for (const item of list) {
      const v = item.valor ? Number(item.valor) : 0;
      const cat = item.categoria || 'Outros';

      if (!categsMap[cat]) {
        categsMap[cat] = { saldo: 0, tipo: item.tipo ?? 'C' };
      }
      categsMap[cat].saldo += v;
      saldo += v;

      if (item.tipo === 'C' || v > 0) totalReceita += v;
      else totalDespesa += Math.abs(v);
    }

    const baseCalc = totalReceita + totalDespesa;

    const formatReal = (n: number) => n.toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });

    const listCategs = Object.keys(categsMap).map(c => {
      const info = categsMap[c];
      let perc = baseCalc > 0 ? (Math.abs(info.saldo) * 100) / baseCalc : 0;
      return {
        categoria: c,
        saldo: info.saldo,
        saldoReal: formatReal(info.saldo),
        tipo: info.tipo,
        percentualString: perc.toFixed(2) + '%',
      };
    });

    const percRec = baseCalc > 0 ? (totalReceita * 100) / baseCalc : 0;
    const percDes = baseCalc > 0 ? (totalDespesa * 100) / baseCalc : 0;

    return {
      meses,
      categorias: listCategs,
      totalReceitaReal: formatReal(totalReceita),
      totalDespesaReal: formatReal(-totalDespesa),
      saldoReal: formatReal(saldo),
      percentualReceita: percRec.toFixed(2) + '%',
      percentualDespesa: percDes.toFixed(2) + '%',
    };
  }

  async getByUser(idUser: number, idCondominio: number) {
    if (!this.prisma.isConnected) {
      return [
        {
          id: 1, nome: 'Taxa de Condomínio - Maio', tipo: 'C', valorReal: 'R$ 650,00',
          data_vencimento: '10/05/2026', data: '10/05/2026', pago: 1,
          url_boleto: 'https://example.com/boleto.pdf', url_comprovante: '', status: '1',
        },
      ];
    }

    const list = await this.prisma.financeiro.findMany({
      where: {
        id_condominio: Number(idCondominio),
        OR: [
          { id_usuario: Number(idUser) },
          { id_usuario: null },
        ],
      },
      orderBy: { data_vencimento: 'desc' },
    });

    return list.map(item => ({
      id: item.id,
      nome: item.nome,
      tipo: item.tipo,
      valorReal: item.valor ? Number(item.valor).toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' }) : 'R$ 0,00',
      data_vencimento: item.data_vencimento ? item.data_vencimento.toLocaleDateString('pt-BR') : '',
      data: item.data ? item.data.toLocaleDateString('pt-BR') : '',
      pago: item.pago,
      url_boleto: item.url_boleto ?? '',
      url_comprovante: item.url_comprovante ?? '',
      status: item.status ?? '0',
    }));
  }

  async uploadSharedFile(id: number, fileBase64: string, type: string) {
    if (!this.prisma.isConnected) return { url: 'https://example.com/arquivo_shared.pdf' };

    const mockUrl = `https://example.com/${type}_upload_${Date.now()}.pdf`;

    if (type === 'boleto') {
      await this.prisma.financeiro.update({
        where: { id: Number(id) },
        data: { url_boleto: mockUrl },
      });
    } else {
      // comprovante, seta status = 2 (aguardando auditoria do sindico)
      await this.prisma.financeiro.update({
        where: { id: Number(id) },
        data: { url_comprovante: mockUrl, status: '2' },
      });
    }

    return { url: mockUrl };
  }

  async updateStatus(id: number, statusStr: string | number) {
    if (!this.prisma.isConnected) return { success: true };

    const status = String(statusStr);
    const isPago = status === '1' ? 1 : 0;

    await this.prisma.financeiro.update({
      where: { id: Number(id) },
      data: { status, pago: isPago },
    });

    return { success: true };
  }

  // Auxiliar para computar meses gerais que tenham lançamentos
  private async getAllMeses(idCondominio: number) {
    const list = await this.prisma.financeiro.findMany({
      where: { id_condominio: Number(idCondominio) },
      select: { data: true, data_vencimento: true, created_at: true },
      orderBy: { created_at: 'asc' },
    });

    const setMesesMap = new Map<string, any>();
    const mesesNomes = ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho', 'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];

    for (const item of list) {
      const d = item.data || item.data_vencimento || item.created_at;
      const m = d.getMonth() + 1;
      const y = d.getFullYear();

      const mStr = m < 10 ? '0' + m : String(m);
      const chave = `${mStr}/${y}`;

      if (!setMesesMap.has(chave)) {
        setMesesMap.set(chave, {
          mes: mStr,
          ano: String(y),
          periodo: `${mesesNomes[m - 1]}/${y}`,
        });
      }
    }

    // Se vazio, adiciona o mês atual
    if (setMesesMap.size === 0) {
      const hoje = new Date();
      const m = hoje.getMonth() + 1;
      const y = hoje.getFullYear();
      const mStr = m < 10 ? '0' + m : String(m);
      setMesesMap.set(`${mStr}/${y}`, {
        mes: mStr,
        ano: String(y),
        periodo: `${mesesNomes[m - 1]}/${y}`,
      });
    }

    return Array.from(setMesesMap.values());
  }
}
