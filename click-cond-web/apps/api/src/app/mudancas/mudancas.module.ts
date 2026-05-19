import { Module } from '@nestjs/common';
import { MudancasController } from './mudancas.controller';
import { MudancasService } from './mudancas.service';

@Module({
  controllers: [MudancasController],
  providers: [MudancasService],
  exports: [MudancasService],
})
export class MudancasModule {}
