import { Injectable, OnModuleInit, Logger } from '@nestjs/common';
import * as admin from 'firebase-admin';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class NotificationsService implements OnModuleInit {
  private readonly logger = new Logger(NotificationsService.name);
  private enabled = false;

  onModuleInit() {
    try {
      // 1) Tenta credenciais via env (FIREBASE_SERVICE_ACCOUNT_JSON em base64 ou JSON puro).
      const envCred = process.env.FIREBASE_SERVICE_ACCOUNT_JSON;
      if (envCred && envCred.trim().length > 0) {
        let parsed: admin.ServiceAccount;
        try {
          const raw = envCred.trim().startsWith('{')
            ? envCred
            : Buffer.from(envCred, 'base64').toString('utf-8');
          parsed = JSON.parse(raw);
        } catch {
          this.logger.warn('FIREBASE_SERVICE_ACCOUNT_JSON inválido. Notificações push desativadas.');
          return;
        }
        admin.initializeApp({ credential: admin.credential.cert(parsed) });
        this.enabled = true;
        this.logger.log('Firebase Admin SDK inicializado (env credentials).');
        return;
      }

      // 2) Tenta arquivo local.
      const serviceAccountPath = path.resolve(
        __dirname,
        'assets/firebase-service-account.json',
      );
      if (!fs.existsSync(serviceAccountPath)) {
        this.logger.warn('Notificações push desativadas (firebase-service-account.json ausente).');
        return;
      }

      admin.initializeApp({ credential: admin.credential.cert(serviceAccountPath) });
      this.enabled = true;
      this.logger.log('Firebase Admin SDK inicializado (file credentials).');
    } catch (error: any) {
      this.logger.warn(`Notificações push desativadas: ${error?.message ?? error}`);
    }
  }

  async sendPushNotification(
    token: string,
    title: string,
    body: string,
    data?: any,
  ) {
    if (!this.enabled) return null;
    try {
      const response = await admin.messaging().send({
        notification: { title, body },
        token,
        data: data || {},
      });
      return response;
    } catch (error) {
      this.logger.warn(`Falha ao enviar push: ${(error as any)?.message ?? error}`);
      return null;
    }
  }

  async sendToTopic(topic: string, title: string, body: string, data?: any) {
    if (!this.enabled) return null;
    try {
      const response = await admin.messaging().send({
        notification: { title, body },
        topic,
        data: data || {},
      });
      return response;
    } catch (error) {
      this.logger.warn(`Falha ao enviar push para tópico ${topic}: ${(error as any)?.message ?? error}`);
      return null;
    }
  }
}
