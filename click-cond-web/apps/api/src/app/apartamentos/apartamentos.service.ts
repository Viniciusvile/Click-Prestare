import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

export interface CreateApartamentoDto {
  bloco?: string;
  apto: string;
  fracao?: string;
  id_condominio: number;
}

@Injectable()
export class ApartamentosService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(idCondominio: number, search?: string) {
    const list = await this.prisma.apartamentos.findMany({
      where: {
        id_condominio: idCondominio,
        ...(search
          ? {
              OR: [
                { apto: { contains: search } },
                { bloco: { contains: search } },
              ],
            }
          : {}),
      },
      include: {
        _count: { select: { users: true } },
      },
      orderBy: [{ bloco: 'asc' }, { apto: 'asc' }],
    });
    return list.map((a) => ({
      id: a.id,
      bloco: a.bloco,
      apto: a.apto,
      fracao: a.fracao,
      id_condominio: a.id_condominio,
      qtdMoradores: a._count.users,
    }));
  }

  async findOne(id: number) {
    const a = await this.prisma.apartamentos.findUnique({ where: { id } });
    if (!a) throw new NotFoundException(`Apartamento ${id} não encontrado`);
    return a;
  }

  create(dto: CreateApartamentoDto) {
    return this.prisma.apartamentos.create({
      data: {
        bloco: dto.bloco ?? null,
        apto: dto.apto,
        fracao: dto.fracao ?? null,
        id_condominio: dto.id_condominio,
      },
    });
  }

  async update(id: number, dto: Partial<CreateApartamentoDto>) {
    try {
      return await this.prisma.apartamentos.update({
        where: { id },
        data: {
          ...(dto.bloco !== undefined && { bloco: dto.bloco }),
          ...(dto.apto !== undefined && { apto: dto.apto }),
          ...(dto.fracao !== undefined && { fracao: dto.fracao }),
        },
      });
    } catch {
      throw new NotFoundException(`Apartamento ${id} não encontrado`);
    }
  }

  async remove(id: number) {
    try {
      await this.prisma.apartamentos.delete({ where: { id } });
    } catch {
      throw new NotFoundException(`Apartamento ${id} não encontrado`);
    }
  }
}