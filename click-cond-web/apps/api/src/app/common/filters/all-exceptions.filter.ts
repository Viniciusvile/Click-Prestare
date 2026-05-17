import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { HttpAdapterHost } from '@nestjs/core';

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger('ExceptionFilter');

  constructor(private readonly httpAdapterHost: HttpAdapterHost) {}

  catch(exception: unknown, host: ArgumentsHost): void {
    const { httpAdapter } = this.httpAdapterHost;

    const ctx = host.switchToHttp();
    const request = ctx.getRequest();
    const response = ctx.getResponse();

    const httpStatus =
      exception instanceof HttpException
        ? exception.getStatus()
        : HttpStatus.INTERNAL_SERVER_ERROR;

    // Extrai mensagem do HttpException corretamente — quando o objeto de resposta
    // tem `message` (BadRequestException, etc.), prefere esse valor.
    let message: string | string[] = 'Erro interno do servidor';
    if (exception instanceof HttpException) {
      const resp = exception.getResponse();
      if (typeof resp === 'string') {
        message = resp;
      } else if (resp && typeof resp === 'object') {
        const m = (resp as any).message;
        if (m) message = m;
        else message = exception.message;
      } else {
        message = exception.message;
      }
    } else if (exception instanceof Error) {
      message = exception.message;
    }

    const responseBody = {
      statusCode: httpStatus,
      timestamp: new Date().toISOString(),
      path: httpAdapter.getRequestUrl(request),
      message,
    };

    this.logger.error(
      `Http Status: ${httpStatus} Error: ${JSON.stringify(responseBody)}`,
      exception instanceof Error ? exception.stack : '',
    );

    // Garante headers CORS na resposta de erro (Express bypassa o cors middleware
    // quando o filter responde direto via httpAdapter.reply).
    const origin = request?.headers?.origin;
    if (origin && response?.setHeader) {
      response.setHeader('Access-Control-Allow-Origin', origin);
      response.setHeader('Access-Control-Allow-Credentials', 'true');
      response.setHeader('Vary', 'Origin');
    }

    httpAdapter.reply(response, responseBody, httpStatus);
  }
}
