import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

export type OcorrenciaStatus = 'Pendente' | 'Ciente' | 'Solucionado';

export interface CreateOcorrenciaDto {
  descricao: string;
  tipo: number;
  anexos?: string;
  id_condominio: number;
}

@Injectable()
export class OcorrenciasService {
  constructor(private readonly prisma: PrismaService) {}

  listCategorias() {
    return this.prisma.ocorrencias_Categorias.findMany({
      orderBy: { prioridade: 'asc' },
    });
  }

  async findAll(idCondominio: number, status?: string) {
    const list = await this.prisma.ocorrencias.findMany({
      where: {
        id_condominio: idCondominio,
        ...(status ? { status } : {}),
      },
      include: { categoria: { select: { nome: true } } },
      orderBy: { created_at: 'desc' },
    });
    return list.map((o) => ({
      id: o.id,
      descricao: o.descricao,
      anexos: o.anexos,
      status: o.status,
      resposta: o.resposta,
      resposta_at: o.resposta_at,
      tipo: o.tipo,
      tipoNome: o.categoria?.nome ?? null,
      created_at: o.created_at,
    }));
  }

  async findOne(id: number) {
    const o = await this.prisma.ocorrencias.findUnique({
      where: { id },
      include: { categoria: { select: { nome: true } } },
    });
    if (!o) throw new NotFoundException(`Ocorrência ${id} não encontrada`);
    return { ...o, tipoNome: o.categoria?.nome ?? null };
  }

  create(dto: CreateOcorrenciaDto) {
    return this.prisma.ocorrencias.create({
      data: {
        descricao: dto.descricao,
        anexos: dto.anexos ?? null,
        tipo: dto.tipo,
        status: 'Pendente',
        id_condominio: dto.id_condominio,
      },
    });
  }

  async updateStatus(id: number, status: OcorrenciaStatus) {
    try {
      return await this.prisma.ocorrencias.update({
        where: { id },
        data: { status },
      });
    } catch {
      throw new NotFoundException(`Ocorrência ${id} não encontrada`);
    }
  }

  async remove(id: number) {
    try {
      await this.prisma.ocorrencias.delete({ where: { id } });
    } catch {
      throw new NotFoundException(`Ocorrência ${id} não encontrada`);
    }
  }
}