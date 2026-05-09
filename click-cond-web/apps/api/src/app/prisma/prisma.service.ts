import { Injectable, Logger, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { PrismaClient } from './generated';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(PrismaService.name);
  /** true se a conexão real foi estabelecida; false se estamos em fallback de mock. */
  isConnected = false;

  constructor() {
    super({
      log: ['warn', 'error'],
    });
  }

  async onModuleInit() {
    if (!process.env['DATABASE_URL']) {
      this.logger.warn(
        'DATABASE_URL ausente — Prisma em modo offline. Services usarão mocks em memória.',
      );
      return;
    }
    try {
      await this.$connect();
      this.isConnected = true;
      this.logger.log('Prisma conectado ao banco');
    } catch (err: any) {
      this.logger.warn(
        `Prisma falhou ao conectar (${err?.message ?? err}). Modo offline ativado — services usarão mocks.`,
      );
    }
  }

  async onModuleDestroy() {
    if (this.isConnected) {
      await this.$disconnect().catch(() => undefined);
    }
  }
}
