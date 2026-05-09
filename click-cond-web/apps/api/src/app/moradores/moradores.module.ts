import { Module } from '@nestjs/common';
import { MoradoresController } from './moradores.controller';
import { MoradoresService } from './moradores.service';

@Module({
  controllers: [MoradoresController],
  providers: [MoradoresService],
})
export class MoradoresModule {}
