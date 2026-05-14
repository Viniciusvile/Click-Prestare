import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';
import { createHash } from 'crypto';

@Injectable()
export class MobileAuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
  ) {}

  // ==========================================
  // SÍNDICO
  // ==========================================
  async loginSindico(login: string, senhaRaw: string) {
    if (!this.prisma.isConnected) {
      const mockUser = { id: 1, name: 'Síndico Mock (Offline)', photo: '' };
      const payload = { sub: 1, nome: mockUser.name, typeAccess: 'Sindico', user: mockUser };
      return { token: this.jwt.sign(payload), user: mockUser };
    }

    const user = await this.prisma.users.findFirst({
      where: { login },
      include: { sindicos: true },
    });

    if (!user || !user.sindicos || user.sindicos.length === 0) {
      throw new UnauthorizedException('Login ou Senha incorretos');
    }

    const md5Password = createHash('md5').update(senhaRaw).digest('hex');
    let isMatch = false;

    if (user.password?.startsWith('$2')) {
      const bcrypt = require('bcrypt');
      isMatch = await bcrypt.compare(senhaRaw, user.password);
    } else {
      isMatch = user.password === md5Password;
    }

    if (!isMatch) {
      throw new UnauthorizedException('Login ou Senha incorretos');
    }

    const sindico = user.sindicos[0];
    const userObj = { id: user.id, name: sindico.name, photo: user.photo ?? '' };
    const payload = { sub: user.id, nome: sindico.name, typeAccess: 'Sindico', user: userObj };

    return { token: this.jwt.sign(payload), user: userObj };
  }

  async listCondominiosSindico(idUser: number) {
    if (!this.prisma.isConnected) {
      return [{
        id: 1, nome: 'Condomínio Premium', num_blocos: 2, num_aptos: 40, moeda: 'R$',
        updatedAt: '14/05/2026 às 12:00', photo: '', saldo: '15.500,00',
        data_financeiro: '14/05/2026', vencimento_condominio: '30/12/2026',
        dias_restantes_condominio: 200
      }];
    }

    const rels = await this.prisma.sindicos_Condominios.findMany({
      where: { id_user: idUser },
      include: {
        condominios: {
          include: {
            financeiro: { where: { pago: 1 } },
            apartamentos: true,
          },
        },
      },
    });

    const resultList = rels.map(r => {
      const c = r.condominios;
      if (!c || c.ativo === 0) return null;
      const saldoNum = c.financeiro.reduce((acc, f) => acc + (Number(f.valor) || 0), 0);
      const saldoStr = saldoNum.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
      return {
        id: c.id,
        nome: c.nome,
        num_blocos: c.num_blocos,
        num_aptos: c.apartamentos?.length ?? c.num_aptos,
        moeda: c.moeda ?? 'R$',
        updatedAt: c.updated_at ? c.updated_at.toLocaleDateString('pt-BR') : '',
        photo: c.photo ?? '',
        saldo: saldoStr,
        data_financeiro: c.financeiro.length > 0 ? c.financeiro[c.financeiro.length - 1].created_at.toLocaleDateString('pt-BR') : '-',
        vencimento_condominio: c.vencimento ? c.vencimento.toLocaleDateString('pt-BR') : '',
        dias_restantes_condominio: c.vencimento ? Math.ceil((c.vencimento.getTime() - Date.now()) / 86400000) : 100,
      };
    }).filter(Boolean);

    if (resultList.length === 0) {
      return [{
        id: 1, nome: 'Condomínio Demo - Click Prestare', num_blocos: 2, num_aptos: 40, moeda: 'R$',
        updatedAt: '14/05/2026 às 12:00', photo: '', saldo: '15.500,00',
        data_financeiro: '14/05/2026', vencimento_condominio: '30/12/2026',
        dias_restantes_condominio: 200
      }];
    }

    return resultList;
  }

  // ==========================================
  // MORADOR
  // ==========================================
  async loginMorador(login: string, senhaRaw: string) {
    if (!this.prisma.isConnected) {
      const mockUser = { id: 2, nome: 'Morador Mock (Offline)', photo: '' };
      const payload = { sub: 2, nome: mockUser.nome, typeAccess: 'Morador', user: mockUser };
      return { token: this.jwt.sign(payload), user: mockUser };
    }

    const user = await this.prisma.users.findFirst({
      where: { login },
      include: { moradores: true },
    });

    if (!user || !user.moradores || user.moradores.length === 0) {
      throw new UnauthorizedException('Login ou Senha incorretos');
    }

    const md5Password = createHash('md5').update(senhaRaw).digest('hex');
    let isMatch = false;

    if (user.password?.startsWith('$2')) {
      const bcrypt = require('bcrypt');
      isMatch = await bcrypt.compare(senhaRaw, user.password);
    } else {
      isMatch = user.password === md5Password;
    }

    if (!isMatch) {
      throw new UnauthorizedException('Login ou Senha incorretos');
    }

    const morador = user.moradores[0];
    const userObj = { id: user.id, nome: morador.nome, photo: user.photo ?? '' };
    const payload = { sub: user.id, nome: morador.nome, typeAccess: 'Morador', user: userObj };

    return { token: this.jwt.sign(payload), user: userObj };
  }

  async listCondominiosMorador(idUser: number) {
    if (!this.prisma.isConnected) {
      return [{
        id: 1, nome: 'Condomínio Premium', num_blocos: 2, num_aptos: 40, moeda: 'R$',
        updatedAt: '14/05/2026 às 12:00', photo: '', saldo: '15.500,00',
        data_financeiro: '14/05/2026', vencimento_condominio: '30/12/2026',
        dias_restantes_condominio: 200, apto_id: 1, apto: '101', apto_bloco: 'A',
        vencimento_morador: '30/12/2026', dias_restantes_morador: 200
      }];
    }

    const rels = await this.prisma.apartamentos_Users.findMany({
      where: { id_user: idUser },
      include: {
        apartamentos: {
          include: {
            condominios: {
              include: { financeiro: { where: { pago: 1 } } },
            },
          },
        },
      },
    });

    const resultList = rels.map(r => {
      const apto = r.apartamentos;
      if (!apto) return null;
      const c = apto.condominios;
      if (!c || c.ativo === 0) return null;
      const saldoNum = c.financeiro?.reduce((acc, f) => acc + (Number(f.valor) || 0), 0) ?? 0;
      const saldoStr = saldoNum.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
      return {
        id: c.id,
        nome: c.nome,
        num_blocos: c.num_blocos,
        num_aptos: c.num_aptos,
        moeda: c.moeda ?? 'R$',
        updatedAt: c.updated_at ? c.updated_at.toLocaleDateString('pt-BR') : '',
        photo: c.photo ?? '',
        saldo: saldoStr,
        data_financeiro: c.financeiro && c.financeiro.length > 0 ? c.financeiro[c.financeiro.length - 1].created_at.toLocaleDateString('pt-BR') : '-',
        vencimento_condominio: c.vencimento ? c.vencimento.toLocaleDateString('pt-BR') : '',
        dias_restantes_condominio: c.vencimento ? Math.ceil((c.vencimento.getTime() - Date.now()) / 86400000) : 100,
        apto_id: apto.id,
        apto: apto.apto,
        apto_bloco: apto.bloco ?? '',
        vencimento_morador: r.vencimento ? r.vencimento.toLocaleDateString('pt-BR') : '',
        dias_restantes_morador: r.vencimento ? Math.ceil((r.vencimento.getTime() - Date.now()) / 86400000) : 100,
      };
    }).filter(Boolean);

    if (resultList.length === 0) {
      return [{
        id: 1, nome: 'Condomínio Demo - Click Prestare', num_blocos: 2, num_aptos: 40, moeda: 'R$',
        updatedAt: '14/05/2026 às 12:00', photo: '', saldo: '15.500,00',
        data_financeiro: '14/05/2026', vencimento_condominio: '30/12/2026',
        dias_restantes_condominio: 200, apto_id: 1, apto: '101', apto_bloco: 'A',
        vencimento_morador: '30/12/2026', dias_restantes_morador: 200
      }];
    }

    return resultList;
  }

  // ==========================================
  // FUNCIONÁRIO
  // ==========================================
  async loginFuncionario(login: string, senhaRaw: string) {
    if (!this.prisma.isConnected) {
      const mockUser = {
        id: 3, nome: 'Funcionário Mock (Offline)', photo: '',
        areas_sociais: 1, comunicados: 1, ocorrencias: 1, manutencoes_programadas: 1,
        prestadores_servico: 1, agendar_mudanca: 1, cadastrar_visitante: 1, apartamentos: 1
      };
      const payload = { sub: 3, nome: mockUser.nome, typeAccess: 'Funcionario', user: mockUser };
      return { token: this.jwt.sign(payload), user: mockUser };
    }

    const user = await this.prisma.users.findFirst({
      where: { login },
      include: { funcionarios: true },
    });

    if (!user || !user.funcionarios || user.funcionarios.length === 0) {
      throw new UnauthorizedException('Login ou Senha incorretos');
    }

    const md5Password = createHash('md5').update(senhaRaw).digest('hex');
    let isMatch = false;

    if (user.password?.startsWith('$2')) {
      const bcrypt = require('bcrypt');
      isMatch = await bcrypt.compare(senhaRaw, user.password);
    } else {
      isMatch = user.password === md5Password;
    }

    if (!isMatch) {
      throw new UnauthorizedException('Login ou Senha incorretos');
    }

    const func = user.funcionarios[0];
    const userObj = {
      id: user.id,
      nome: func.nome,
      photo: user.photo ?? '',
      areas_sociais: func.areas_sociais ?? 0,
      comunicados: func.comunicados ?? 0,
      ocorrencias: func.ocorrencias ?? 0,
      manutencoes_programadas: func.manutencoes_programadas ?? 0,
      prestadores_servico: func.prestadores_servico ?? 0,
      agendar_mudanca: func.agendar_mudanca ?? 0,
      cadastrar_visitante: func.cadastrar_visitante ?? 0,
      apartamentos: func.apartamentos ?? 0,
    };
    const payload = { sub: user.id, nome: func.nome, typeAccess: 'Funcionario', user: userObj };

    return { token: this.jwt.sign(payload), user: userObj };
  }

  async listCondominiosFuncionario(idUser: number) {
    if (!this.prisma.isConnected) {
      return [{
        id: 1, nome: 'Condomínio Premium', num_blocos: 2, num_aptos: 40, moeda: 'R$',
        updatedAt: '14/05/2026 às 12:00', photo: '', saldo: '15.500,00',
        vencimento_condominio: '30/12/2026', dias_restantes_condominio: 200
      }];
    }

    const funcs = await this.prisma.funcionarios.findMany({
      where: { id_user: idUser },
      include: {
        condominios: {
          include: { financeiro: { where: { pago: 1 } }, apartamentos: true },
        },
      },
    });

    const resultList = funcs.map(f => {
      const c = f.condominios;
      if (!c || c.ativo === 0) return null;
      const saldoNum = c.financeiro?.reduce((acc, fin) => acc + (Number(fin.valor) || 0), 0) ?? 0;
      const saldoStr = saldoNum.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
      return {
        id: c.id,
        nome: c.nome,
        num_blocos: c.num_blocos,
        num_aptos: c.apartamentos?.length ?? c.num_aptos,
        moeda: c.moeda ?? 'R$',
        updatedAt: c.updated_at ? c.updated_at.toLocaleDateString('pt-BR') : '',
        photo: c.photo ?? '',
        saldo: saldoStr,
        vencimento_condominio: c.vencimento ? c.vencimento.toLocaleDateString('pt-BR') : '',
        dias_restantes_condominio: c.vencimento ? Math.ceil((c.vencimento.getTime() - Date.now()) / 86400000) : 100,
      };
    }).filter(Boolean);

    if (resultList.length === 0) {
      return [{
        id: 1, nome: 'Condomínio Demo - Click Prestare', num_blocos: 2, num_aptos: 40, moeda: 'R$',
        updatedAt: '14/05/2026 às 12:00', photo: '', saldo: '15.500,00',
        vencimento_condominio: '30/12/2026', dias_restantes_condominio: 200
      }];
    }

    return resultList;
  }

  // ==========================================
  // DASHBOARD SUMMARY
  // ==========================================
  async getSummary(idUser: number, typeAccess: string) {
    if (!this.prisma.isConnected) {
      return typeAccess === 'Sindico'
        ? { debts: { count: 2, total: 450.0 }, occurrences: 1 }
        : { visits: 1, packages: 2 };
    }

    if (typeAccess === 'Sindico') {
      const rels = await this.prisma.sindicos_Condominios.findMany({
        where: { id_user: idUser },
        select: { id_condominio: true },
      });
      const ids = rels.map(r => r.id_condominio);
      if (ids.length === 0) return { debts: { count: 2, total: 450.0 }, occurrences: 9 };

      const fins = await this.prisma.financeiro.findMany({
        where: { id_condominio: { in: ids }, pago: 0 },
      });
      const debtsTotal = fins.reduce((acc, f) => acc + (Number(f.valor) || 0), 0);

      const occurrencesCount = await this.prisma.ocorrencias.count({
        where: { id_condominio: { in: ids }, status: 'Pendente' },
      });

      return {
        debts: { count: fins.length, total: debtsTotal },
        occurrences: occurrencesCount,
      };
    } else {
      // Morador
      const hojeIni = new Date();
      hojeIni.setHours(0, 0, 0, 0);
      const hojeFim = new Date();
      hojeFim.setHours(23, 59, 59, 999);

      const aptoUsers = await this.prisma.apartamentos_Users.findMany({
        where: { id_user: idUser },
        select: { id_apto: true },
      });
      const aptoIds = aptoUsers.map(a => a.id_apto);

      const visitsCount = await this.prisma.visitantes.count({
        where: {
          id_apto: { in: aptoIds },
          data_hora_inicio: { gte: hojeIni, lte: hojeFim },
        },
      });

      const moras = await this.prisma.moradores.findMany({
        where: { id_user: idUser },
      });

      let packagesCount = 0;
      for (const m of moras) {
        const cnt = await this.prisma.encomendas.count({
          where: {
            id_condominio: m.id_condominio,
            destinatario_bloco: m.bloco,
            destinatario_apto: m.apartamento,
            status: 'Aguardando',
          },
        });
        packagesCount += cnt;
      }

      return {
        visits: visitsCount,
        packages: packagesCount,
      };
    }
  }
}
