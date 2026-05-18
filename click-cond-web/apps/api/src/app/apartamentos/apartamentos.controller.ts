import {
  Body, Controller, Delete, Get, Param, ParseIntPipe, Post, Put, Query,
} from '@nestjs/common';
import { ApartamentosService, CreateApartamentoDto } from './apartamentos.service';

@Controller('condominios/:idCondominio/apartamentos')
export class ApartamentosController {
  constructor(private readonly service: ApartamentosService) {}

  @Get()
  list(
    @Param('idCondominio', ParseIntPipe) idCondominio: number,
    @Query('search') search?: string,
  ) {
    return this.service.findAll(idCondominio, search);
  }

  @Get(':id')
  get(@Param('id', ParseIntPipe) id: number) {
    return this.service.findOne(id);
  }

  @Post()
  create(
    @Param('idCondominio', ParseIntPipe) idCondominio: number,
    @Body() body: Omit<CreateApartamentoDto, 'id_condominio'>,
  ) {
    return this.service.create({ ...body, id_condominio: idCondominio });
  }

  @Put(':id')
  update(
    @Param('id', ParseIntPipe) id: number,
    @Body() body: Partial<CreateApartamentoDto>,
  ) {
    return this.service.update(id, body);
  }

  @Delete(':id')
  remove(@Param('id', ParseIntPipe) id: number) {
    this.service.remove(id);
    return { ok: true };
  }

  @Post('import-bulk')
  importBulk(
    @Param('idCondominio', ParseIntPipe) idCondominio: number,
    @Body() body: { linhas: any[] },
  ) {
    return this.service.importBulk(idCondominio, body.linhas);
  }
}
