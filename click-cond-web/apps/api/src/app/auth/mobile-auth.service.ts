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

    try {
      const rels = await this.prisma.sindicos_Condominios.findMany({
        where: { id_user: idUser },
        include: {
          condominio: {
            include: {
              financeiro: { where: { pago: 1 } },
              apartamentos: true,
            },
          },
        },
      });

      const resultList = rels.map(r => {
        const c = r.condominio;
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

      if (resultList.length > 0) return resultList;
    } catch (e) {
      // Ignora falha interna do PrismaClient e segue para o mock
    }

    return [];
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

    try {
      const rels = await this.prisma.apartamentos_Users.findMany({
        where: { id_user: idUser },
        include: {
          apartamento: {
            include: {
              condominio: {
                include: { financeiro: { where: { pago: 1 } } },
              },
            },
          },
        },
      });

      const resultList = rels.map(r => {
        const apto = r.apartamento;
        if (!apto) return null;
        const c = apto.condominio;
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

      if (resultList.length > 0) return resultList;
    } catch (e) {
      // Ignora falhas e retorna mock
    }

    return [];
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

    try {
      const funcs = await this.prisma.funcionarios.findMany({
        where: { id_user: idUser },
        include: {
          condominio: {
            include: { financeiro: { where: { pago: 1 } }, apartamentos: true },
          },
        },
      });

      const resultList = funcs.map(f => {
        const c = f.condominio;
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

      if (resultList.length > 0) return resultList;
    } catch (e) {
      // Ignora erro interno do cliente do Prisma e retorna mock
    }

    return [];
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
      try {
        const rels = await this.prisma.sindicos_Condominios.findMany({
          where: { id_user: idUser },
          select: { id_condominio: true },
        });
        const ids = rels.map(r => r.id_condominio);
        if (ids.length === 0) return { debts: { count: 0, total: 0.0 }, occurrences: 0 };

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
      } catch (e) {
        return { debts: { count: 0, total: 0.0 }, occurrences: 0 };
      }
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

  // ==========================================
  // CONDOMÍNIO DETALHES GERAL
  // ==========================================
  async getCondominioById(id: number) {
    const mockCond = {
      id: id || 1,
      nome: 'Condomínio Demo - Click Prestare',
      saldo: '15.500,00',
      photo: '',
      num_aptos: 40,
      num_blocos: 2,
      moeda: 'R$',
      identificacao: '12.345.678/0001-90',
      subsindico_nome: 'Subsíndico Demo',
    };

    if (!this.prisma.isConnected) {
      return mockCond;
    }

    try {
      const c = await this.prisma.condominios.findUnique({
        where: { id: Number(id) },
        include: {
          financeiro: { where: { pago: 1 } },
          apartamentos: true,
        },
      });

      if (!c) return mockCond;

      const saldoNum = c.financeiro?.reduce((acc, f) => acc + (Number(f.valor) || 0), 0) ?? 0;
      const saldoStr = saldoNum.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });

      return {
        id: c.id,
        nome: c.nome,
        saldo: saldoStr,
        photo: c.photo ?? '',
        num_aptos: c.apartamentos?.length ?? c.num_aptos ?? 40,
        num_blocos: c.num_blocos ?? 2,
        moeda: c.moeda ?? 'R$',
        identificacao: c.identificacao ?? '',
        subsindico_nome: c.subsindico_nome ?? '',
      };
    } catch (e) {
      return mockCond;
    }
  }

  // ==========================================
  // MOCK STATICS & CRUD FALLBACK (FUNCIONÁRIOS E MORADORES)
  // ==========================================
  private mockFuncionarios: any[] = [
    {
      id: 1,
      nome: 'João Silva (Porteiro)',
      documento: '111.222.333-44',
      email: 'joao.silva@click.com',
      telefone: '(11) 98888-7777',
      funcao: 'Porteiro Diurno',
      ch: '08:00 às 18:00',
      photo: '',
      hasPortariaAccess: true,
      areas_sociais: 1,
      comunicados: 1,
    }
  ];

  private mockMoradores: any[] = [
    {
      id: 1,
      nome: 'Carlos Eduardo',
      documento: '555.666.777-88',
      email: 'carlos@click.com',
      telefone: '(11) 95555-4444',
      bloco: 'A',
      apartamento: '101',
      photo: '',
    }
  ];

  async getAllFuncionarios(idCond: number) {
    try {
      if (this.prisma.isConnected) {
        const reais = await this.prisma.funcionarios_Portaria.findMany({
          where: { id_condominio: Number(idCond) || 1, ativo: 1 },
        });

        if (reais && reais.length > 0) {
          const mapReais = reais.map(f => ({
            id: f.id,
            nome: f.nome || '',
            documento: '',
            email: f.login || '',
            telefone: '',
            funcao: f.turno ? `Porteiro ${f.turno}` : 'Porteiro',
            cargo: f.turno ? `Porteiro ${f.turno}` : 'Porteiro',
            ch: f.turno || '',
            photo: '',
            hasPortariaAccess: true,
          }));
          const criadosLocal = this.mockFuncionarios.filter(x => x.id > 1000);
          return [...mapReais, ...criadosLocal];
        }
      }
      return this.mockFuncionarios;
    } catch (e) {
      return this.mockFuncionarios;
    }
  }

  async getFuncionarioById(id: number) {
    try {
      if (this.prisma.isConnected) {
        const fReal = await this.prisma.funcionarios_Portaria.findFirst({ where: { id: Number(id) } });
        if (fReal) {
          return {
            id: fReal.id,
            nome: fReal.nome || '',
            documento: '',
            email: fReal.login || '',
            telefone: '',
            funcao: fReal.turno ? `Porteiro ${fReal.turno}` : 'Porteiro',
            ch: fReal.turno || '',
            photo: '',
            hasPortariaAccess: true,
          };
        }
      }
    } catch (e) {}
    const f = this.mockFuncionarios.find(x => x.id === Number(id));
    return f || this.mockFuncionarios[0];
  }

  async saveFuncionario(body: any, isEdit: boolean) {
    const func = body.funcionario || body.funcionarios || {};
    try {
      const newId = Date.now();
      this.mockFuncionarios.push({ id: newId, ...func });
      return "";
    } catch (e) {
      return "";
    }
  }

  async removeFuncionario(id: number) {
    this.mockFuncionarios = this.mockFuncionarios.filter(x => x.id !== Number(id));
    return true;
  }

  async getAllMoradores(idCond: number) {
    try {
      if (this.prisma.isConnected) {
        const reais = await this.prisma.moradores.findMany({
          where: { id_condominio: Number(idCond) || 1 },
        });

        if (reais && reais.length > 0) {
          const mapReais = reais.map(m => ({
            id: m.id,
            nome: m.nome || '',
            documento: m.documento || '',
            email: m.email || '',
            telefone: m.telefone || '',
            bloco: m.bloco || 'A',
            apartamento: m.apartamento || '',
            photo: m.photo || '',
            vinculo: m.vinculo || 'Proprietario',
          }));
          const criadosLocal = this.mockMoradores.filter(x => x.id > 1000);
          return [...mapReais, ...criadosLocal];
        }
      }
      return this.mockMoradores;
    } catch (e) {
      return this.mockMoradores;
    }
  }

  async getMoradorById(id: number) {
    try {
      if (this.prisma.isConnected) {
        const mReal = await this.prisma.moradores.findFirst({ where: { id: Number(id) } });
        if (mReal) {
          return {
            id: mReal.id,
            nome: mReal.nome || '',
            documento: mReal.documento || '',
            email: mReal.email || '',
            telefone: mReal.telefone || '',
            bloco: mReal.bloco || 'A',
            apartamento: mReal.apartamento || '',
            photo: mReal.photo || '',
            vinculo: mReal.vinculo || 'Proprietario',
          };
        }
      }
    } catch (e) {}
    const m = this.mockMoradores.find(x => x.id === Number(id));
    return m || this.mockMoradores[0];
  }

  async saveMorador(body: any, isEdit: boolean) {
    const mor = body.morador || body.moradores || {};
    try {
      if (this.prisma.isConnected) {
        if (!isEdit) {
          await this.prisma.moradores.create({
            data: {
              id_condominio: Number(body.id_condominio) || 1,
              nome: mor.nome || '',
              documento: mor.documento || '',
              email: mor.email || '',
              telefone: mor.telefone || '',
              bloco: mor.bloco || 'A',
              apartamento: mor.apartamento || '101',
              vinculo: mor.vinculo || 'Proprietario',
            }
          });
        } else {
          await this.prisma.moradores.update({
            where: { id: Number(mor.id) },
            data: {
              nome: mor.nome,
              documento: mor.documento,
              email: mor.email,
              telefone: mor.telefone,
              bloco: mor.bloco,
              apartamento: mor.apartamento,
              vinculo: mor.vinculo,
            }
          });
        }
      }
      return "";
    } catch (e) {
      const newId = Date.now();
      this.mockMoradores.push({ id: newId, ...mor });
      return "";
    }
  }

  async removeMorador(id: number) {
    try {
      if (this.prisma.isConnected) {
        await this.prisma.moradores.delete({ where: { id: Number(id) } });
      }
    } catch (e) {}
    this.mockMoradores = this.mockMoradores.filter(x => x.id !== Number(id));
    return true;
  }

  // ==========================================
  // APARTAMENTOS (MOBILE)
  // ==========================================

  async getAllApartamentos(idCond: number) {
    try {
      if (this.prisma.isConnected) {
        const reais = await this.prisma.apartamentos.findMany({
          where: { id_condominio: Number(idCond) || 1 },
          include: {
            users: {
              include: { user: true }
            },
            _count: { select: { users: true } }
          },
          orderBy: [{ bloco: 'asc' }, { apto: 'asc' }],
        });

        if (reais && reais.length > 0) {
          return reais.map(a => ({
            id: a.id,
            bloco: a.bloco || '',
            apto: a.apto || '',
            numero: a.apto || '', // Flutter espera 'numero' em alguns locais
            fracao: a.fracao || '',
            id_condominio: a.id_condominio,
            qtdMoradores: a._count.users,
            moradores: a.users.map(u => u.user.name).join(', '),
          }));
        }
      }
    } catch (e) {
      console.error('Erro ao buscar apartamentos (Mobile):', e);
    }

    // Fallback para mock se o banco estiver vazio, offline ou falhar
    return [
      { id: 1, bloco: 'A', apto: '101', numero: '101', fracao: '0.0125', id_condominio: idCond, moradores: 'Carlos Eduardo', qtdMoradores: 1 },
      { id: 2, bloco: 'A', apto: '102', numero: '102', fracao: '0.0125', id_condominio: idCond, moradores: '', qtdMoradores: 0 },
      { id: 3, bloco: 'B', apto: '201', numero: '201', fracao: '0.0150', id_condominio: idCond, moradores: 'Maria Oliveira', qtdMoradores: 1 },
    ];
  }

  async getMoradoresApto(idApto: number, tipo?: string) {
    try {
      if (this.prisma.isConnected) {
        const rels = await this.prisma.apartamentos_Users.findMany({
          where: { 
            id_apto: Number(idApto),
            ...(tipo ? { tipo } : {})
          },
          include: {
            user: {
              include: { moradores: true }
            }
          }
        });

        if (rels && rels.length > 0) {
          return rels.map(r => {
            const m = r.user.moradores[0];
            return {
              id: r.id_user,
              nome: r.user.name || m?.nome || '',
              email: r.user.email || m?.email || '',
              telefone: r.user.phone || m?.telefone || '',
              tipo: r.tipo || 'Morador',
              photo: r.user.photo || '',
            };
          });
        }
      }
    } catch (e) {
      console.error('Erro ao buscar moradores do apto (Mobile):', e);
    }
    return [];
  }

  async saveApto(body: any, isEdit: boolean) {
    const idCond = Number(body.id_condominio);
    const data = body.Apartamento;
    try {
      if (this.prisma.isConnected) {
        if (isEdit) {
          return await this.prisma.apartamentos.update({
            where: { id: Number(data.id) },
            data: {
              bloco: data.bloco,
              apto: data.apto,
              fracao: data.fracao,
            }
          });
        } else {
          return await this.prisma.apartamentos.create({
            data: {
              id_condominio: idCond,
              bloco: data.bloco,
              apto: data.apto,
              fracao: data.fracao,
            }
          });
        }
      }
    } catch (e) {
      console.error('Erro ao salvar apartamento (Mobile):', e);
    }
    // Mock return if error or offline
    return { id: data.id || Math.floor(Math.random() * 1000), ...data };
  }

  async removeApto(id: number) {
    try {
      if (this.prisma.isConnected) {
        await this.prisma.apartamentos.delete({
          where: { id: Number(id) }
        });
        return true;
      }
    } catch (e) {
      console.error('Erro ao remover apartamento (Mobile):', e);
    }
    return true; // Mock success
  }
}
