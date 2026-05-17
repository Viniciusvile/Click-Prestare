import { BadRequestException, Injectable, NotFoundException, ServiceUnavailableException, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';
import { MailService } from '../common/mail/mail.service';
import { createHash, randomBytes } from 'crypto';
import * as bcrypt from 'bcrypt';

@Injectable()
export class MobileAuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwt: JwtService,
    private readonly mail: MailService,
  ) {}

  private async verifyPassword(senhaRaw: string, stored: string | null | undefined, userId: number): Promise<boolean> {
    if (!stored) return false;

    if (stored.startsWith('$2')) {
      return bcrypt.compare(senhaRaw, stored);
    }

    const md5Password = createHash('md5').update(senhaRaw).digest('hex');
    const isMatch = stored === md5Password;

    if (isMatch) {
      try {
        const newHash = await bcrypt.hash(senhaRaw, 10);
        await this.prisma.users.update({
          where: { id: userId },
          data: { password: newHash },
        });
      } catch (e) {
        // Falha na migração não deve bloquear o login
      }
    }

    return isMatch;
  }

  // ==========================================
  // SÍNDICO
  // ==========================================
  async loginSindico(login: string, senhaRaw: string) {
    if (!this.prisma.isConnected) {
      throw new ServiceUnavailableException('Banco de dados indisponível. Tente novamente em instantes.');
    }

    const user = await this.prisma.users.findFirst({
      where: { login },
      include: { sindicos: true },
    });

    if (!user || !user.sindicos || user.sindicos.length === 0) {
      throw new UnauthorizedException('Login ou Senha incorretos');
    }

    const isMatch = await this.verifyPassword(senhaRaw, user.password, user.id);

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
              financeiro: { where: { pago: 1 }, select: { valor: true, created_at: true } },
              apartamentos: true,
            },
          },
        },
      });

      const resultList = rels.map(r => {
        const c = r.condominio;
        if (!c || c.ativo === 0) return null;
        
        // Garante que financeiro seja tratado como array mesmo se vier nulo/indefinido
        const financeiro = c.financeiro ?? [];
        const apartamentos = c.apartamentos ?? [];

        const saldoNum = financeiro.reduce((acc, f) => acc + (Number(f.valor) || 0), 0);
        const saldoStr = saldoNum.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        
        return {
          id: c.id,
          nome: c.nome,
          num_blocos: c.num_blocos ?? 1,
          num_aptos: apartamentos.length > 0 ? apartamentos.length : (c.num_aptos ?? 0),
          moeda: c.moeda ?? 'R$',
          updatedAt: c.updated_at ? c.updated_at.toLocaleDateString('pt-BR') : '',
          photo: c.photo ?? '',
          saldo: saldoStr,
          data_financeiro: financeiro.length > 0 ? financeiro[financeiro.length - 1].created_at.toLocaleDateString('pt-BR') : '-',
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
      throw new ServiceUnavailableException('Banco de dados indisponível. Tente novamente em instantes.');
    }

    const user = await this.prisma.users.findFirst({
      where: { OR: [{ login }, { email: login }] },
      include: { moradores: true },
    });

    if (!user || !user.moradores || user.moradores.length === 0) {
      throw new UnauthorizedException('Login ou Senha incorretos');
    }

    const isMatch = await this.verifyPassword(senhaRaw, user.password, user.id);

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
                include: { financeiro: { where: { pago: 1 }, select: { valor: true, created_at: true } } },
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
      throw new ServiceUnavailableException('Banco de dados indisponível. Tente novamente em instantes.');
    }

    const user = await this.prisma.users.findFirst({
      where: { login },
      include: { funcionarios: true },
    });

    if (!user || !user.funcionarios || user.funcionarios.length === 0) {
      throw new UnauthorizedException('Login ou Senha incorretos');
    }

    const isMatch = await this.verifyPassword(senhaRaw, user.password, user.id);

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
            include: { financeiro: { where: { pago: 1 }, select: { valor: true, created_at: true } }, apartamentos: true },
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
          id_apartamento: { in: aptoIds },
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

  async registerCondominio(body: any, idUser: number) {
    const data = body.condominio || {};
    const addr = body.address || {};

    const nome = data.nome || 'Novo Condomínio';
    const identificacao = data.identificacao || '';

    try {
      if (this.prisma.isConnected) {
        // 1. Criar Endereço se houver dados
        let idEndereco = null;
        if (addr.cep || addr.rua) {
          const e = await this.prisma.endereco.create({
            data: {
              cep: addr.cep,
              rua: addr.rua,
              numero: String(addr.numero || ''),
              complemento: addr.complemento,
              bairro: addr.bairro,
              cidade: addr.cidade,
              uf: addr.uf,
              pais: addr.pais,
            }
          });
          idEndereco = e.id;
        }

        // 2. Criar Condomínio
        const c = await this.prisma.condominios.create({
          data: {
            nome: nome,
            identificacao: identificacao,
            subsindico_nome: data.subsindico_nome,
            num_blocos: Number(data.num_blocos) || 1,
            num_aptos: Number(data.num_aptos) || 0,
            moeda: 'BRL',
            ativo: 1,
            endereco: idEndereco,
          }
        });

        // 3. Vincular o usuário como síndico desse condomínio
        await this.prisma.sindicos_Condominios.create({
          data: {
            id_user: idUser,
            id_condominio: c.id,
          }
        });

        return { success: true, id: c.id, nome: c.nome };
      }
    } catch (e) {
      console.error('Erro ao registrar condomínio:', e);
    }

    return { success: true, id: Date.now(), nome: nome };
  }

  // ==========================================
  // RECUPERAÇÃO DE SENHA
  // ==========================================
  private gerarNovaSenha(): string {
    return randomBytes(4).toString('hex'); // 8 chars alfanumérico
  }

  async recoveryPasswordSindico(email: string) {
    const user = await this.prisma.users.findFirst({
      where: { login: email },
      include: { sindicos: true },
    });
    if (!user || !user.sindicos || user.sindicos.length === 0) {
      throw new NotFoundException('E-mail não encontrado');
    }
    const novaSenha = this.gerarNovaSenha();
    const hash = await bcrypt.hash(novaSenha, 10);
    await this.prisma.users.update({ where: { id: user.id }, data: { password: hash } });
    await this.mail.sendForgotPassword(email, novaSenha, 'Síndico');
    return { success: true };
  }

  async recoveryPasswordMorador(email: string) {
    const morador = await this.prisma.moradores.findFirst({ where: { email } });
    if (!morador) throw new NotFoundException('E-mail não encontrado');
    const user = await this.prisma.users.findFirst({ where: { login: email } });
    if (!user) throw new NotFoundException('E-mail não encontrado');
    const novaSenha = this.gerarNovaSenha();
    const hash = await bcrypt.hash(novaSenha, 10);
    await this.prisma.users.update({ where: { id: user.id }, data: { password: hash } });
    await this.mail.sendForgotPassword(email, novaSenha, 'Morador');
    return { success: true };
  }

  async recoveryPasswordFuncionario(email: string) {
    const func = await this.prisma.funcionarios_Portaria.findFirst({ where: { login: email } });
    if (!func) throw new NotFoundException('E-mail não encontrado');
    const novaSenha = this.gerarNovaSenha();
    const md5Hash = createHash('md5').update(novaSenha).digest('hex');
    await this.prisma.funcionarios_Portaria.update({ where: { id: func.id }, data: { senha: md5Hash } });
    await this.mail.sendForgotPassword(email, novaSenha, 'Funcionário');
    return { success: true };
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
    if (!this.prisma.isConnected) {
      throw new ServiceUnavailableException('Banco indisponível. Tente novamente em instantes.');
    }
    const mor = body.morador || body.moradores || {};
    const idAptoRaw = mor.id_apto ?? body.id_apto;
    const idApto = idAptoRaw ? Number(idAptoRaw) : null;
    const tipoRaw = String(mor.tipo || mor.vinculo || 'proprietario');
    // Normaliza: "Proprietário" -> "proprietario", "Inquilino" -> "inquilino"
    const tipo = tipoRaw
      .normalize('NFD')
      .replace(/\p{Diacritic}/gu, '')
      .toLowerCase()
      .trim();

    try {
      // ===== EDIÇÃO =====
      if (isEdit) {
        const idMorador = Number(mor.id);
        if (!idMorador) throw new BadRequestException('ID do morador é obrigatório para edição.');

        const atual = await this.prisma.moradores.findUnique({
          where: { id: idMorador },
          include: { user: true },
        });
        if (!atual) throw new NotFoundException('Morador não encontrado.');

        const emailMudou = mor.email !== undefined && mor.email !== atual.email;
        if (emailMudou && mor.email) {
          const conflito = await this.prisma.users.findFirst({
            where: {
              OR: [{ email: mor.email }, { login: mor.email }],
              NOT: { id: atual.id_user },
            },
            select: { id: true },
          });
          if (conflito) throw new BadRequestException('Já existe outro usuário com este e-mail.');
        }

        await this.prisma.$transaction(async (tx) => {
          await tx.moradores.update({
            where: { id: idMorador },
            data: {
              ...(mor.nome !== undefined && { nome: mor.nome }),
              ...(mor.documento !== undefined && { documento: mor.documento }),
              ...(mor.email !== undefined && { email: mor.email }),
              ...(mor.telefone !== undefined && { telefone: mor.telefone }),
              ...(mor.data_nascimento && { data_nascimento: new Date(mor.data_nascimento) }),
              ...(tipo && { tipo }),
            },
          });

          const userPatch: any = {};
          if (mor.nome !== undefined) userPatch.name = mor.nome;
          if (mor.telefone !== undefined) userPatch.phone = mor.telefone;
          if (mor.documento !== undefined) userPatch.cpf = mor.documento || null;
          if (emailMudou) {
            userPatch.email = mor.email || null;
            userPatch.login = mor.email || null;
          }
          if (Object.keys(userPatch).length > 0 && atual.id_user) {
            await tx.users.update({ where: { id: atual.id_user }, data: userPatch });
          }
        });

        return '';
      }

      // ===== CRIAÇÃO =====
      if (!idApto) throw new BadRequestException('Apartamento não informado.');

      const apto = await this.prisma.apartamentos.findUnique({ where: { id: idApto } });
      if (!apto) throw new NotFoundException('Apartamento não encontrado.');

      // Valida unicidade do email entre Users antes de tentar criar
      if (mor.email) {
        // Mantemos o reuso por email (lógica abaixo), então só checamos conflito de login se for outro usuário
        // ... a checagem real fica no bloco de criação que reutiliza/cria o Users.
      }

      const idCondominio = Number(body.id_condominio) || apto.id_condominio;

      // Cria/reutiliza Users por email (se fornecido) — senha inicial = documento ou '123456'
      let userId: number;
      const senhaInicial = (mor.documento && String(mor.documento).trim()) || '123456';
      const md5Pwd = createHash('md5').update(senhaInicial).digest('hex');

      if (mor.email) {
        const existing = await this.prisma.users.findFirst({ where: { email: mor.email } });
        if (existing) {
          // Email já existe: garante que o registro tenha login/senha para acessar.
          userId = existing.id;
          if (!existing.login || !existing.password) {
            await this.prisma.users.update({
              where: { id: existing.id },
              data: { login: mor.email, password: md5Pwd },
            });
          }
        } else {
          const u = await this.prisma.users.create({
            data: {
              name: mor.nome,
              email: mor.email,
              login: mor.email,
              password: md5Pwd,
              phone: mor.telefone,
              cpf: mor.documento || null,
              is_morador: 1,
              login_type: 'morador',
            },
          });
          userId = u.id;
        }
      } else {
        // Morador sem email — cria Users só para satisfazer FK, mas sem acesso ao app
        const u = await this.prisma.users.create({
          data: {
            name: mor.nome,
            phone: mor.telefone,
            cpf: mor.documento || null,
            is_morador: 1,
            login_type: 'morador',
          },
        });
        userId = u.id;
      }

      // Vincula em Apartamentos_Users (45 dias de vencimento padrão)
      const venc = new Date();
      venc.setDate(venc.getDate() + 45);
      try {
        await this.prisma.apartamentos_Users.create({
          data: { id_apto: apto.id, id_user: userId, tipo, vencimento: venc },
        });
      } catch {
        // Vínculo pode já existir (mesmo user em outro fluxo). Ignora.
      }

      // Cria Moradores
      const created = await this.prisma.moradores.create({
        data: {
          nome: mor.nome ?? '',
          documento: mor.documento ?? null,
          email: mor.email ?? null,
          telefone: mor.telefone ?? null,
          data_nascimento: mor.data_nascimento ? new Date(mor.data_nascimento) : null,
          tipo,
          id_user: userId,
          id_condominio: idCondominio,
          bloco: apto.bloco || null,
          apartamento: apto.apto || null,
        },
      });

      // Dispara email de boas-vindas (assíncrono, não bloqueia resposta)
      if (mor.email && mor.sendCredentials !== false) {
        this.mail
          .sendWelcomeMorador(mor.email, mor.nome ?? '', senhaInicial)
          .catch(() => {});
      }

      return { id: created.id };
    } catch (e: any) {
      // Repassa exceptions Nest (BadRequest, NotFound, etc.); embrulha o resto
      if (e?.response && e?.status) throw e;
      throw new BadRequestException(e?.message ?? 'Erro ao salvar morador.');
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

  // ==========================================
  // OCORRÊNCIAS (MOBILE)
  // ==========================================

  async listOcorrenciasCategorias() {
    try {
      if (this.prisma.isConnected) {
        return await this.prisma.ocorrencias_Categorias.findMany({
          orderBy: { prioridade: 'asc' },
        });
      }
    } catch (e) {}
    return [];
  }

  async saveOcorrencia(body: any, idUser: number) {
    try {
      if (this.prisma.isConnected) {
        return await this.prisma.ocorrencias.create({
          data: {
            id_condominio: Number(body.id_condominio),
            descricao: body.descricao,
            tipo: Number(body.tipo),
            user: idUser,
            status: 'Pendente',
          }
        });
      }
    } catch (e) {
      console.error('Erro ao salvar ocorrência (Mobile):', e);
    }
    return { id: Date.now(), success: true };
  }

  async listOcorrencias(idUser: number) {
    try {
      if (this.prisma.isConnected) {
        return await this.prisma.ocorrencias.findMany({
          where: { user: idUser },
          include: { categoria: true },
          orderBy: { created_at: 'desc' },
        });
      }
    } catch (e) {}
    return [];
  }

  // ==========================================
  // FINANCEIRO (MOBILE)
  // ==========================================

  async listFinanceiroByUser(idUser: number) {
    try {
      if (this.prisma.isConnected) {
        const moras = await this.prisma.moradores.findMany({
          where: { id_user: idUser },
          select: { id_condominio: true }
        });
        const ids = moras.map(m => m.id_condominio);

        return await this.prisma.financeiro.findMany({
          where: {
            id_condominio: { in: ids.filter((v): v is number => v !== null) },
            pago: 0,
          },
          orderBy: { data_vencimento: 'asc' },
          select: {
            id: true,
            nome: true,
            valor: true,
            data_vencimento: true,
            status: true,
            url_boleto: true,
          }
        });
      }
    } catch (e) {}
    return [];
  }

  // ==========================================
  // ENCOMENDAS (MOBILE)
  // ==========================================

  async listEncomendasByUser(idUser: number) {
    try {
      if (this.prisma.isConnected) {
        const moras = await this.prisma.moradores.findMany({
          where: { id_user: idUser },
        });

        let total: any[] = [];
        for (const m of moras) {
          const list = await this.prisma.encomendas.findMany({
            where: {
              id_condominio: m.id_condominio!,
              destinatario_bloco: m.bloco,
              destinatario_apto: m.apartamento,
            },
            orderBy: { created_at: 'desc' },
          });
          total = [...total, ...list];
        }
        return total;
      }
    } catch (e) {}
    return [];
  }
}
