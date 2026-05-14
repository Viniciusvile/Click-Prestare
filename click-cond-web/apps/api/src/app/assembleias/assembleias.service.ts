import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

@Injectable()
export class AssembleiasService {
  constructor(private readonly prisma: PrismaService) {}

  // ==========================================
  // ASSEMBLEIAS
  // ==========================================
  async insert(idCondominio: number, assembleia: any, userId: number) {
    if (!this.prisma.isConnected) return { success: true };

    // Processar anexos (docs) se vierem base64
    let listDocs: string[] = [];
    if (Array.isArray(assembleia.docs)) {
      listDocs = assembleia.docs.map((doc: string, idx: number) => {
        if (doc.startsWith('data:')) {
          return `https://example.com/doc_${idx}.pdf`;
        }
        return doc;
      });
    }

    // Datas no formato YYYY-MM-DD ou DD/MM/YYYY
    let dataObj: Date | undefined;
    if (assembleia.data) {
      if (assembleia.data.includes('/')) {
        const parts = assembleia.data.split('/');
        dataObj = new Date(Number(parts[2]), Number(parts[1]) - 1, Number(parts[0]));
      } else {
        dataObj = new Date(assembleia.data);
      }
    }

    let horaObj: Date | undefined;
    if (assembleia.hora) {
      const [h, m] = assembleia.hora.split(':').map(Number);
      horaObj = new Date(1970, 0, 1, h, m, 0);
    }

    await this.prisma.assembleias.create({
      data: {
        titulo: assembleia.titulo,
        descricao: assembleia.descricao,
        data: dataObj,
        hora: horaObj,
        local: assembleia.local,
        link: assembleia.link ?? '',
        id_condominio: Number(idCondominio),
        user: Number(userId),
        anexos: listDocs.join(';'),
      },
    });

    return { success: true };
  }

  async update(idCondominio: number, assembleia: any, userId: number) {
    if (!this.prisma.isConnected) return { success: true };

    let listDocs: string[] = [];
    if (Array.isArray(assembleia.docs)) {
      listDocs = assembleia.docs.map((doc: string, idx: number) => {
        if (doc.startsWith('data:')) return `https://example.com/doc_${idx}.pdf`;
        return doc;
      });
    }

    let dataObj: Date | undefined;
    if (assembleia.data) {
      if (assembleia.data.includes('/')) {
        const parts = assembleia.data.split('/');
        dataObj = new Date(Number(parts[2]), Number(parts[1]) - 1, Number(parts[0]));
      } else {
        dataObj = new Date(assembleia.data);
      }
    }

    let horaObj: Date | undefined;
    if (assembleia.hora) {
      const [h, m] = assembleia.hora.split(':').map(Number);
      horaObj = new Date(1970, 0, 1, h, m, 0);
    }

    await this.prisma.assembleias.updateMany({
      where: {
        id: Number(assembleia.id),
        id_condominio: Number(idCondominio),
      },
      data: {
        titulo: assembleia.titulo,
        descricao: assembleia.descricao,
        ...(dataObj ? { data: dataObj } : {}),
        ...(horaObj ? { hora: horaObj } : {}),
        local: assembleia.local,
        link: assembleia.link ?? '',
        user: Number(userId),
        ...(listDocs.length > 0 ? { anexos: listDocs.join(';') } : {}),
      },
    });

    return { success: true };
  }

  async remove(id: number) {
    if (!this.prisma.isConnected) return { success: true };
    await this.prisma.assembleias.delete({ where: { id: Number(id) } });
    return { success: true };
  }

  async getAll(idCondominio: number) {
    if (!this.prisma.isConnected) {
      return [
        { id: 1, titulo: 'Assembleia Geral Ordinária', descricao: 'Aprovação de contas e eleição de síndico', data: '20/05/2026', hora: '19:30' },
      ];
    }

    const list = await this.prisma.assembleias.findMany({
      where: { id_condominio: Number(idCondominio) },
      orderBy: { data: 'asc' },
    });

    return list.map(item => ({
      id: item.id,
      titulo: item.titulo,
      descricao: item.descricao,
      data: item.data ? item.data.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric' }) : '',
      hora: item.hora ? item.hora.toTimeString().substring(0, 5) : '',
    }));
  }

  async get(idCondominio: number, idAssembleia: number, userId: number) {
    if (!this.prisma.isConnected) {
      return {
        assembleia: {
          id: idAssembleia, titulo: 'Assembleia Geral Ordinária', descricao: 'Aprovação de contas',
          data: '20/05/2026', hora: '19:30', link: 'https://meet.google.com', local: 'Salão de Festas', anexos: '',
        },
        votacoes: [],
        meusVotos: [],
      };
    }

    const item = await this.prisma.assembleias.findFirst({
      where: { id: Number(idAssembleia), id_condominio: Number(idCondominio) },
    });

    if (!item) throw new NotFoundException('Assembleia não encontrada');

    const assembleiaFormatada = {
      id: item.id,
      titulo: item.titulo,
      descricao: item.descricao,
      data: item.data ? item.data.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric' }) : '',
      hora: item.hora ? item.hora.toTimeString().substring(0, 5) : '',
      link: item.link ?? '',
      local: item.local ?? '',
      anexos: item.anexos ?? '',
    };

    // Buscar votações da assembleia
    const votacoes = await this.getVotacoesFormatadas(Number(idAssembleia), false, Number(idCondominio));
    const meusVotos = await this.getMyVotosAssembleia(Number(idAssembleia), Number(userId));

    return {
      assembleia: assembleiaFormatada,
      votacoes,
      meusVotos,
    };
  }

  async finish(idCondominio: number, assembleia: any) {
    if (!this.prisma.isConnected) return { success: true };

    let linkDoc = '';
    if (assembleia.doc && assembleia.doc.startsWith('data:')) {
      linkDoc = 'https://example.com/ata_finalizada.pdf';
    } else {
      linkDoc = assembleia.doc ?? '';
    }

    const nomeAta = `ATA ${assembleia.titulo} - ${assembleia.data}`;

    // Gravar na tabela Documentos
    await this.prisma.documentos.create({
      data: {
        id_condominio: Number(idCondominio),
        is_ata: 1,
        nome: nomeAta,
        link_doc: linkDoc,
      },
    });

    // Remover assembleia finalizada
    await this.prisma.assembleias.delete({
      where: { id: Number(assembleia.id) },
    });

    return {
      message: 'Assembléia Finalizada!\nA ATA se encontra disponível no menu "Docs" na tela de seu condomínio.',
    };
  }

  // ==========================================
  // VOTAÇÕES E ENQUETES
  // ==========================================
  async insertVotacao(votacao: any, idCondominio: number) {
    if (!this.prisma.isConnected) return { success: true };

    const parseDate = (dStr: string) => {
      if (!dStr) return new Date();
      if (dStr.includes('/')) {
        const p = dStr.split('/');
        return new Date(Number(p[2]), Number(p[1]) - 1, Number(p[0]));
      }
      return new Date(dStr);
    };

    const dIni = parseDate(votacao.data_inicio);
    const dFim = parseDate(votacao.data_termino);
    const isEnquete = votacao.is_enquete ? 1 : 0;

    // Criar a votação
    const created = await this.prisma.votacoes.create({
      data: {
        titulo: votacao.titulo,
        descricao: votacao.descricao ?? '',
        data_inicio: dIni,
        data_termino: dFim,
        id_assembleia: votacao.id_assembleia ? Number(votacao.id_assembleia) : null,
        id_condominio: Number(idCondominio),
        is_enquete: isEnquete,
      },
    });

    // Inserir opções
    if (Array.isArray(votacao.opcoes)) {
      await this.prisma.votacoes_Opcoes.createMany({
        data: votacao.opcoes.map((nomeOpcao: string) => ({
          id_votacao: created.id,
          nome: nomeOpcao,
        })),
      });
    }

    return { success: true };
  }

  async removeVotacao(id: number) {
    if (!this.prisma.isConnected) return { success: true };
    await this.prisma.votacoes.delete({ where: { id: Number(id) } });
    return { success: true };
  }

  async finishVotacao(id: number) {
    if (!this.prisma.isConnected) return { success: true };

    const ontem = new Date();
    ontem.setDate(ontem.getDate() - 1);

    await this.prisma.votacoes.update({
      where: { id: Number(id) },
      data: { data_termino: ontem },
    });

    return { success: true };
  }

  async registerVoto(votacaoId: number, opcaoId: number, userId: number) {
    if (!this.prisma.isConnected) return { success: true };

    // Remover voto anterior do usuário nessa votação
    const opcoesDb = await this.prisma.votacoes_Opcoes.findMany({
      where: { id_votacao: Number(votacaoId) },
      select: { id: true },
    });

    const idsOpcoes = opcoesDb.map(o => o.id);

    if (idsOpcoes.length > 0) {
      await this.prisma.votacoes_Usuarios.deleteMany({
        where: {
          id_user: Number(userId),
          id_opcao: { in: idsOpcoes },
        },
      });
    }

    // Inserir novo voto
    await this.prisma.votacoes_Usuarios.create({
      data: {
        id_opcao: Number(opcaoId),
        id_user: Number(userId),
      },
    });

    return { success: true };
  }

  async enqueteGetAll(idCondominio: number) {
    if (!this.prisma.isConnected) {
      return [
        {
          id: 1, titulo: 'Melhoria da Academia', descricao: 'Qual equipamento comprar?',
          data_inicio: '10/05/2026', data_termino: '30/05/2026', status: 1,
          opcoes: ['1;Esteira;5', '2;Bicicleta;3'],
        },
      ];
    }

    return this.getVotacoesFormatadas(undefined, true, Number(idCondominio));
  }

  async enqueteGetDetails(idVotacao: number, userId: number) {
    if (!this.prisma.isConnected) {
      return {
        votacao: {
          id: idVotacao, titulo: 'Melhoria da Academia', descricao: 'Qual equipamento comprar?',
          data_inicio: '10/05/2026', data_termino: '30/05/2026', status: 1,
          opcoes: ['1;Esteira;5', '2;Bicicleta;3'],
        },
        meuVoto: ['1'],
      };
    }

    const list = await this.getVotacoesFormatadas(undefined, true, undefined, Number(idVotacao));
    const votacao = list[0];

    if (!votacao) throw new NotFoundException('Enquete não encontrada');

    // Buscar voto do usuário
    const vu = await this.prisma.votacoes_Usuarios.findFirst({
      where: {
        id_user: Number(userId),
        opcao: { id_votacao: Number(idVotacao) },
      },
      select: { id_opcao: true },
    });

    const meuVoto = vu ? [String(vu.id_opcao)] : [];

    return { votacao, meuVoto };
  }

  // ==========================================
  // FUNÇÕES DE FORMATACÃO E CÁLCULO
  // ==========================================
  private async getVotacoesFormatadas(
    idAssembleia?: number,
    isEnquete: boolean = false,
    idCondominio?: number,
    idVotacaoEspecifica?: number,
  ) {
    const whereClause: any = {};
    if (idAssembleia !== undefined) whereClause.id_assembleia = idAssembleia;
    if (isEnquete) whereClause.is_enquete = 1;
    if (idCondominio !== undefined) whereClause.id_condominio = idCondominio;
    if (idVotacaoEspecifica !== undefined) whereClause.id = idVotacaoEspecifica;

    const votacoesDb = await this.prisma.votacoes.findMany({
      where: whereClause,
      include: {
        opcoes: {
          include: {
            votos: { select: { id: true } },
          },
          orderBy: { id: 'asc' },
        },
      },
      orderBy: { created_at: 'desc' },
    });

    return votacoesDb.map(v => {
      const dIniStr = v.data_inicio ? v.data_inicio.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric' }) : '';
      const dFimStr = v.data_termino ? v.data_termino.toLocaleDateString('pt-BR', { day: '2-digit', month: '2-digit', year: 'numeric' }) : '';

      // Computar o status como inteiro (0 = agendado, 1 = em andamento, 2 = finalizado)
      const statusInt = this.calcStatusInt(v.data_inicio, v.data_termino);

      // Mapear opções para o formato de string do group_concat: "id;nome;votos"
      const opcoesStrArray = v.opcoes.map(op => `${op.id};${op.nome};${op.votos.length}`);

      return {
        id: v.id,
        titulo: v.titulo,
        descricao: v.descricao ?? '',
        data_inicio: dIniStr,
        data_termino: dFimStr,
        status: statusInt,
        opcoes: opcoesStrArray,
      };
    });
  }

  private async getMyVotosAssembleia(idAssembleia: number, userId: number): Promise<string[]> {
    const votosDb = await this.prisma.votacoes_Usuarios.findMany({
      where: {
        id_user: Number(userId),
        opcao: {
          votacao: { id_assembleia: Number(idAssembleia) },
        },
      },
      select: { id_opcao: true },
    });

    return votosDb.map(v => String(v.id_opcao));
  }

  private calcStatusInt(dIni?: Date | null, dFim?: Date | null): number {
    if (!dIni || !dFim) return 1;

    const hoje = new Date();
    hoje.setHours(0, 0, 0, 0);

    const inicio = new Date(dIni);
    inicio.setHours(0, 0, 0, 0);

    const fim = new Date(dFim);
    fim.setHours(0, 0, 0, 0);

    if (fim < hoje) return 2; // finalizado
    if (inicio > hoje) return 0; // agendado
    return 1; // em andamento
  }
}
