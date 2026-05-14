import { Module } from '@nestjs/common';
import { AreasSociaisController } from './areas-sociais.controller';
import { AreasSociaisService } from './areas-sociais.service';

@Module({
  controllers: [AreasSociaisController],
  providers: [AreasSociaisService],
})
export class AreasSociaisModule {}
