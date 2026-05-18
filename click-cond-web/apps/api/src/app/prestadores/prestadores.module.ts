import { Module } from '@nestjs/common';
import { PrestadoresController } from './prestadores.controller';
import { PrestadoresMobileController } from './prestadores-mobile.controller';
import { PrestadoresService } from './prestadores.service';

@Module({
  controllers: [PrestadoresController, PrestadoresMobileController],
  providers: [PrestadoresService],
})
export class PrestadoresModule {}
