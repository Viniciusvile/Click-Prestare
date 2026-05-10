import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';

export interface CreateVisitanteDto {
  nome: string;
  doc_identificacao?: string;
  data_hora_inicio?: string;
  data_hora_termino?: string;
  is_visitante?: number;
  is_prestador?: number;
  id_apartamento: number;
  id_condominio: number;
  foto_documento?: string;
  foto_pessoa?: string;
}

export interface UpdateVisitanteDto extends Partial<CreateVisitanteDto> {
  id: number;
}

import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class VisitantesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly notifications: NotificationsService,
  ) {}

  async findAll(idCondominio: number, search?: string) {
    return this.prisma.visitantes.findMany({
      where: {
        id_condominio: idCondominio,
        ...(search
          ? {
              OR: [
                { nome: { contains: search } },
                { doc_identificacao: { contains: search } },
              ],
            }
          : {}),
      },
      include: {
        apartamento: { select: { bloco: true, apto: true } },
      },
      orderBy: [{ data_hora_inicio: 'desc' }, { created_at: 'desc' }],
    });
  }

  async findOne(id: number) {
    const v = await this.prisma.visitantes.findUnique({
      where: { id },
      include: { apartamento: { select: { bloco: true, apto: true } } },
    });
    if (!v) throw new NotFoundException(`Visitante ${id} não encontrado`);
    return v;
  }

  async create(dto: CreateVisitanteDto) {
    const visitante = await this.prisma.visitantes.create({
      data: {
        nome: dto.nome,
        doc_identificacao: dto.doc_identificacao ?? null,
        data_hora_inicio: dto.data_hora_inicio ? new Date(dto.data_hora_inicio) : new Date(),
        data_hora_termino: dto.data_hora_termino ? new Date(dto.data_hora_termino) : null,
        is_visitante: dto.is_visitante ?? 1,
        is_prestador: dto.is_prestador ?? 0,
        id_apartamento: dto.id_apartamento,
        id_condominio: dto.id_condominio,
        foto_documento: dto.foto_documento ?? null,
        foto_pessoa: dto.foto_pessoa ?? null,
      },
    });

    // Notificar moradores
    try {
      const moradores = await this.prisma.users.findMany({
        where: {
          apartamentosUsers: {
            some: {
              id_apto: dto.id_apartamento,
            },
          },
          fcm_token: { not: null },
          notif_visitantes: 1,
        },
        select: { fcm_token: true },
      });

      for (const m of moradores) {
        if (m.fcm_token) {
          await this.notifications.sendPushNotification(
            m.fcm_token,
            dto.is_prestador ? 'Prestador de Serviço' : 'Chegada de Visitante',
            `${dto.nome} acabou de chegar para o seu apartamento.`,
            { id: visitante.id.toString(), type: 'visitante' },
          );
        }
      }
    } catch (error) {
      console.error('Erro ao notificar moradores sobre visitante:', error);
    }

    return visitante;
  }

  async update(dto: UpdateVisitanteDto) {
    try {
      return await this.prisma.visitantes.update({
        where: { id: dto.id },
        data: {
          ...(dto.nome !== undefined && { nome: dto.nome }),
          ...(dto.doc_identificacao !== undefined && { doc_identificacao: dto.doc_identificacao }),
          ...(dto.data_hora_inicio !== undefined && {
            data_hora_inicio: new Date(dto.data_hora_inicio),
          }),
          ...(dto.data_hora_termino !== undefined && {
            data_hora_termino: dto.data_hora_termino ? new Date(dto.data_hora_termino) : null,
          }),
          ...(dto.is_visitante !== undefined && { is_visitante: dto.is_visitante }),
          ...(dto.is_prestador !== undefined && { is_prestador: dto.is_prestador }),
          ...(dto.id_apartamento !== undefined && { id_apartamento: dto.id_apartamento }),
          ...(dto.foto_documento !== undefined && { foto_documento: dto.foto_documento }),
          ...(dto.foto_pessoa !== undefined && { foto_pessoa: dto.foto_pessoa }),
        },
      });
    } catch {
      throw new NotFoundException(`Visitante ${dto.id} não encontrado`);
    }
  }

  async remove(id: number) {
    try {
      await this.prisma.visitantes.delete({ where: { id } });
    } catch {
      throw new NotFoundException(`Visitante ${id} não encontrado`);
    }
  }
}