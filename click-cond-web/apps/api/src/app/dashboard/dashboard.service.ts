import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

export interface DashboardSummary {
  visitantesAtivos: number;
  prestadoresAtivos: number;
  ocorrenciasPendentes: number;
  encomendasAguardando: number;
  comunicadosRecentes: number;
  totalApartamentos: number;
  totalMoradores: number;
  ultimosEventos: { tipo: string; descricao: string; quando: string }[];
}

@Injectable()
export class DashboardService {
  constructor(private readonly prisma: PrismaService) {}

  async summary(idCondominio: number): Promise<DashboardSummary> {
    const agora = new Date();
    const seteDiasAtras = new Date(agora.getTime() - 7 * 86400_000);

    const [
      visitantesAtivos,
      prestadoresAtivos,
      ocorrenciasPendentes,
      encomendasAguardando,
      comunicadosRecentes,
      totalApartamentos,
      totalMoradores,
      ultVisitante,
      ultEncomenda,
      ultOcorrencia,
    ] = await Promise.all([
      // Visitantes ainda no condomínio (sem data_hora_termino, ou termino > now)
      this.prisma.visitantes.count({
        where: {
          id_condominio: idCondominio,
          OR: [{ data_hora_termino: null }, { data_hora_termino: { gt: agora } }],
        },
      }),
      this.prisma.prestadores_servico.count({
        where: { id_condominio: idCondominio },
      }),
      this.prisma.ocorrencias.count({
        where: { id_condominio: idCondominio, status: 'Pendente' },
      }),
      this.prisma.encomendas.count({
        where: { id_condominio: idCondominio, status: 'Aguardando' },
      }),
      this.prisma.comunicados.count({
        where: { id_condominio: idCondominio, created_at: { gte: seteDiasAtras } },
      }),
      this.prisma.apartamentos.count({ where: { id_condominio: idCondominio } }),
      this.prisma.moradores.count({ where: { id_condominio: idCondominio } }),
      this.prisma.visitantes.findFirst({
        where: { id_condominio: idCondominio },
        orderBy: { created_at: 'desc' },
        include: { apartamento: { select: { bloco: true, apto: true } } },
      }),
      this.prisma.encomendas.findFirst({
        where: { id_condominio: idCondominio },
        orderBy: { recebido_em: 'desc' },
      }),
      this.prisma.ocorrencias.findFirst({
        where: { id_condominio: idCondominio },
        orderBy: { created_at: 'desc' },
      }),
    ]);

    const ultimosEventos: DashboardSummary['ultimosEventos'] = [];
    if (ultVisitante) {
      const aptoStr = ultVisitante.apartamento
        ? `Apto ${ultVisitante.apartamento.apto}${ultVisitante.apartamento.bloco ?? ''}`
        : '';
      ultimosEventos.push({
        tipo: 'Visitante',
        descricao: `${ultVisitante.nome} entrou — ${aptoStr}`.trim(),
        quando: ultVisitante.created_at.toISOString(),
      });
    }
    if (ultEncomenda) {
      ultimosEventos.push({
        tipo: 'Encomenda',
        descricao: `${ultEncomenda.descricao} — Apto ${ultEncomenda.destinatario_apto}${ultEncomenda.destinatario_bloco ?? ''}`,
        quando: ultEncomenda.recebido_em.toISOString(),
      });
    }
    if (ultOcorrencia) {
      ultimosEventos.push({
        tipo: 'Ocorrência',
        descricao: ultOcorrencia.descricao ?? '—',
        quando: ultOcorrencia.created_at.toISOString(),
      });
    }
    ultimosEventos.sort(
      (a, b) => new Date(b.quando).getTime() - new Date(a.quando).getTime(),
    );

    return {
      visitantesAtivos,
      prestadoresAtivos,
      ocorrenciasPendentes,
      encomendasAguardando,
      comunicadosRecentes,
      totalApartamentos,
      totalMoradores,
      ultimosEventos,
    };
  }
}
