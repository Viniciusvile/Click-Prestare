import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

export interface CreatePrestadorDto {
  nome: string;
  telefone?: string;
  categorias?: string;
  id_condominio: number;
}

@Injectable()
export class PrestadoresService {
  constructor(private readonly prisma: PrismaService) {}

  findAll(idCondominio: number, search?: string) {
    return this.prisma.prestadores_servico.findMany({
      where: {
        id_condominio: idCondominio,
        ...(search
          ? {
              OR: [
                { nome: { contains: search } },
                { telefone: { contains: search } },
                { categorias: { contains: search } },
              ],
            }
          : {}),
      },
      orderBy: { nome: 'asc' },
    });
  }

  async findOne(id: number) {
    const p = await this.prisma.prestadores_servico.findUnique({ where: { id } });
    if (!p) throw new NotFoundException(`Prestador ${id} não encontrado`);
    return p;
  }

  create(dto: CreatePrestadorDto) {
    return this.prisma.prestadores_servico.create({
      data: {
        nome: dto.nome,
        telefone: dto.telefone ?? null,
        categorias: dto.categorias ?? null,
        id_condominio: dto.id_condominio,
      },
    });
  }

  async update(id: number, dto: Partial<CreatePrestadorDto>) {
    try {
      return await this.prisma.prestadores_servico.update({
        where: { id },
        data: {
          ...(dto.nome !== undefined && { nome: dto.nome }),
          ...(dto.telefone !== undefined && { telefone: dto.telefone }),
          ...(dto.categorias !== undefined && { categorias: dto.categorias }),
        },
      });
    } catch {
      throw new NotFoundException(`Prestador ${id} não encontrado`);
    }
  }

  async remove(id: number) {
    try {
      await this.prisma.prestadores_servico.delete({ where: { id } });
    } catch {
      throw new NotFoundException(`Prestador ${id} não encontrado`);
    }
  }
}