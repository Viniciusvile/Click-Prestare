import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

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
}