import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

export interface CreateEncomendaDto {
  descricao: string;
  destinatario_apto: string;
  destinatario_bloco?: string;
  recebido_de?: string;
  foto_volume?: string;
  id_condominio: number;
}

@Injectable()
export class EncomendasService {
  constructor(private readonly prisma: PrismaService) {}

  findAll(idCondominio: number, status?: string) {
    return this.prisma.encomendas.findMany({
      where: {
        id_condominio: idCondominio,
        ...(status ? { status } : {}),
      },
      orderBy: { recebido_em: 'desc' },
    });
  }

  async findOne(id: number) {
    const e = await this.prisma.encomendas.findUnique({ where: { id } });
    if (!e) throw new NotFoundException(`Encomenda ${id} não encontrada`);
    return e;
  }

  create(dto: CreateEncomendaDto) {
    return this.prisma.encomendas.create({
      data: {
        descricao: dto.descricao,
        destinatario_apto: dto.destinatario_apto,
        destinatario_bloco: dto.destinatario_bloco ?? null,
        recebido_de: dto.recebido_de ?? null,
        foto_volume: dto.foto_volume ?? null,
        status: 'Aguardando',
        id_condominio: dto.id_condominio,
      },
    });
  }

  async retirar(id: number, retiradoPor: string) {
    try {
      return await this.prisma.encomendas.update({
        where: { id },
        data: {
          retirado_em: new Date(),
          retirado_por: retiradoPor,
          status: 'Retirada',
        },
      });
    } catch {
      throw new NotFoundException(`Encomenda ${id} não encontrada`);
    }
  }

  async remove(id: number) {
    try {
      await this.prisma.encomendas.delete({ where: { id } });
    } catch {
      throw new NotFoundException(`Encomenda ${id} não encontrada`);
    }
  }
}
