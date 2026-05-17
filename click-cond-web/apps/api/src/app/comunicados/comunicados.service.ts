import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

export interface CreateComunicadoDto {
  titulo: string;
  descricao?: string;
  id_condominio: number;
}

@Injectable()
export class ComunicadosService {
  constructor(private readonly prisma: PrismaService) {}

  findAll(idCondominio: number) {
    return this.prisma.comunicados.findMany({
      where: { id_condominio: idCondominio },
      orderBy: { created_at: 'desc' },
    });
  }

  async findOne(id: number) {
    const c = await this.prisma.comunicados.findUnique({ where: { id } });
    if (!c) throw new NotFoundException(`Comunicado ${id} não encontrado`);
    return c;
  }

  create(dto: CreateComunicadoDto) {
    return this.prisma.comunicados.create({
      data: {
        titulo: dto.titulo,
        descricao: dto.descricao ?? null,
        id_condominio: dto.id_condominio,
      },
    });
  }

  async update(id: number, dto: Partial<CreateComunicadoDto>) {
    try {
      return await this.prisma.comunicados.update({
        where: { id },
        data: {
          ...(dto.titulo !== undefined && { titulo: dto.titulo }),
          ...(dto.descricao !== undefined && { descricao: dto.descricao }),
        },
      });
    } catch {
      throw new NotFoundException(`Comunicado ${id} não encontrado`);
    }
  }

  async remove(id: number) {
    try {
      await this.prisma.comunicados.delete({ where: { id } });
    } catch {
      throw new NotFoundException(`Comunicado ${id} não encontrado`);
    }
  }
}
