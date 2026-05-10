import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import * as admin from 'firebase-admin';
import * as path from 'path';

@Injectable()
export class NotificationsService implements OnModuleInit {
  private readonly logger = new Logger(NotificationsService.name);

  onModuleInit() {
    try {
      const serviceAccountPath = path.resolve(
        __dirname,
        'assets/firebase-service-account.json',
      );

      admin.initializeApp({
        credential: admin.credential.cert(serviceAccountPath),
      });

      this.logger.log('Firebase Admin SDK inicializado com sucesso');
    } catch (error) {
      this.logger.error('Falha ao inicializar Firebase Admin SDK', error);
    }
  }

  async sendPushNotification(
    token: string,
    title: string,
    body: string,
    data?: any,
  ) {
    try {
      const message = {
        notification: { title, body },
        token: token,
        data: data || {},
      };

      const response = await admin.messaging().send(message);
      this.logger.log(`Notificação enviada com sucesso: ${response}`);
      return response;
    } catch (error) {
      this.logger.error('Erro ao enviar notificação push', error);
      throw error;
    }
  }

  async sendToTopic(topic: string, title: string, body: string, data?: any) {
    try {
      const message = {
        notification: { title, body },
        topic: topic,
        data: data || {},
      };

      const response = await admin.messaging().send(message);
      this.logger.log(`Notificação enviada para o tópico ${topic}: ${response}`);
      return response;
    } catch (error) {
      this.logger.error(`Erro ao enviar notificação para o tópico ${topic}`, error);
      throw error;
    }
  }
}
