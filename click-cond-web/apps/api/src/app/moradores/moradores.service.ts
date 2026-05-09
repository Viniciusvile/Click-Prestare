import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

export interface CreateMoradorDto {
  nome: string;
  documento?: string;
  email?: string;
  telefone?: string;
  data_nascimento?: string;
  tipo?: string;
  id_apartamento: number;
  id_condominio: number;
}

@Injectable()
export class MoradoresService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Moradores no schema legado têm FK para Users e podem ter id_condominio.
   * Para a portaria, listamos moradores diretamente filtrados por id_condominio
   * e juntamos foto via Users. Quando o app legado popular Apartamentos_Users
   * podemos cruzar pelo apartamento.
   */
  async findAll(idCondominio: number, search?: string) {
    const list = await this.prisma.moradores.findMany({
      where: {
        id_condominio: idCondominio,
        ...(search
          ? {
              OR: [
                { nome: { contains: search } },
                { documento: { contains: search } },
                { apartamento: { contains: search } },
                { bloco: { contains: search } },
              ],
            }
          : {}),
      },
      include: { user: { select: { photo: true } } },
      orderBy: { nome: 'asc' },
    });

    return list.map((m) => ({
      id: m.id,
      nome: m.nome,
      documento: m.documento,
      email: m.email,
      telefone: m.telefone,
      data_nascimento: m.data_nascimento,
      tipo: m.tipo,
      bloco: m.bloco,
      apartamento: m.apartamento,
      id_apartamento: 0, // legado não armazena direto na tabela Moradores
      id_condominio: m.id_condominio,
      photo: m.user?.photo ?? null,
    }));
  }

  async findOne(id: number) {
    const m = await this.prisma.moradores.findUnique({
      where: { id },
      include: { user: { select: { photo: true } } },
    });
    if (!m) throw new NotFoundException(`Morador ${id} não encontrado`);
    return {
      ...m,
      photo: m.user?.photo ?? null,
    };
  }

  /**
   * Criação simplificada: assumimos que o porteiro está só registrando dados
   * básicos. Cria um Users mínimo se ainda não existir e vincula via id_user.
   */
  async create(dto: CreateMoradorDto) {
    // Cria/encontra Users por email se fornecido
    let userId: number;
    if (dto.email) {
      const existing = await this.prisma.users.findFirst({
        where: { email: dto.email },
      });
      if (existing) {
        userId = existing.id;
      } else {
        const u = await this.prisma.users.create({
          data: {
            name: dto.nome,
            email: dto.email,
            phone: dto.telefone,
            cpf: dto.documento,
            is_morador: 1,
            login_type: 'morador',
          },
        });
        userId = u.id;
      }
    } else {
      const u = await this.prisma.users.create({
        data: {
          name: dto.nome,
          phone: dto.telefone,
          cpf: dto.documento,
          is_morador: 1,
          login_type: 'morador',
        },
      });
      userId = u.id;
    }

    return this.prisma.moradores.create({
      data: {
        nome: dto.nome,
        documento: dto.documento ?? null,
        email: dto.email ?? null,
        telefone: dto.telefone ?? null,
        data_nascimento: dto.data_nascimento ? new Date(dto.data_nascimento) : null,
        tipo: dto.tipo ?? 'morador',
        id_user: userId,
        id_condominio: dto.id_condominio,
      },
    });
  }

  async update(id: number, dto: Partial<CreateMoradorDto>) {
    try {
      return await this.prisma.moradores.update({
        where: { id },
        data: {
          ...(dto.nome !== undefined && { nome: dto.nome }),
          ...(dto.documento !== undefined && { documento: dto.documento }),
          ...(dto.email !== undefined && { email: dto.email }),
          ...(dto.telefone !== undefined && { telefone: dto.telefone }),
          ...(dto.tipo !== undefined && { tipo: dto.tipo }),
          ...(dto.data_nascimento !== undefined && {
            data_nascimento: dto.data_nascimento ? new Date(dto.data_nascimento) : null,
          }),
        },
      });
    } catch {
      throw new NotFoundException(`Morador ${id} não encontrado`);
    }
  }

  async remove(id: number) {
    try {
      await this.prisma.moradores.delete({ where: { id } });
    } catch {
      throw new NotFoundException(`Morador ${id} não encontrado`);
    }
  }
}