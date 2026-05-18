import { Body, Controller, Get, HttpCode, Post, Query } from '@nestjs/common';
import { PrestadoresService } from './prestadores.service';

@Controller('prestadores')
export class PrestadoresMobileController {
  constructor(private readonly service: PrestadoresService) {}

  @Get('get-all')
  getAll(@Query('id_condominio') idCondominio: string) {
    return this.service.findAll(Number(idCondominio));
  }

  @Get('get')
  getOne(@Query('id') id: string) {
    return this.service.findOne(Number(id));
  }

  @Post('insert')
  @HttpCode(200)
  create(@Body() body: any) {
    const idCondominio = Number(body.id_condominio);
    const data = body.prestador || body.Prestador || body.prestadores || {};
    return this.service.create({
      id_condominio: idCondominio,
      nome: data.nome,
      telefone: data.telefone,
      categorias: data.categorias,
    });
  }

  @Post('update')
  @HttpCode(200)
  update(@Body() body: any) {
    const data = body.prestador || body.Prestador || body.prestadores || {};
    const id = Number(data.id);
    return this.service.update(id, {
      nome: data.nome,
      telefone: data.telefone,
      categorias: data.categorias,
    });
  }

  @Post('remove')
  @HttpCode(200)
  remove(@Body() body: { id: string | number }) {
    return this.service.remove(Number(body.id));
  }
}
