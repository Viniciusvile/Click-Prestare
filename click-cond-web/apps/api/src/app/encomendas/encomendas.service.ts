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

import { NotificationsService } from '../notifications/notifications.service';

@Injectable()
export class EncomendasService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly notifications: NotificationsService,
  ) {}

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

  async create(dto: CreateEncomendaDto) {
    const encomenda = await this.prisma.encomendas.create({
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

    // Notificar moradores do apartamento
    try {
      const moradores = await this.prisma.users.findMany({
        where: {
          moradores: {
            some: {
              id_condominio: dto.id_condominio,
              apartamento: {
                apto: dto.destinatario_apto,
                ...(dto.destinatario_bloco ? { bloco: dto.destinatario_bloco } : {}),
              },
            },
          },
          fcm_token: { not: null },
          notif_encomendas: 1,
        },
        select: { fcm_token: true, name: true },
      });

      for (const morador of moradores) {
        if (morador.fcm_token) {
          await this.notifications.sendPushNotification(
            morador.fcm_token,
            'Nova Encomenda!',
            `Uma encomenda (${dto.descricao}) chegou para o seu apartamento.`,
            { id: encomenda.id.toString(), type: 'encomenda' },
          );
        }
      }
    } catch (error) {
      console.error('Falha ao notificar moradores:', error);
    }

    return encomenda;
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
