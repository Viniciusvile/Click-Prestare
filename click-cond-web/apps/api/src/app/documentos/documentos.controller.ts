import { Body, Controller, Get, HttpCode, Post, Query } from '@nestjs/common';
import { DocumentosService } from './documentos.service';

@Controller('documentos')
export class DocumentosController {
  constructor(private readonly service: DocumentosService) {}

  @Post('insert')
  @HttpCode(200)
  insert(@Body() body: { id_condominio: string | number; documento: any }) {
    return this.service.insert(Number(body.id_condominio), body.documento);
  }

  @Get('get-all')
  getAll(
    @Query('id_condominio') idCondominio: string,
    @Query('is_ata') isAta: string,
  ) {
    return this.service.getAll(Number(idCondominio), isAta);
  }

  @Post('remove')
  @HttpCode(200)
  remove(@Body() body: { id: string | number }) {
    return this.service.remove(Number(body.id));
  }
}
