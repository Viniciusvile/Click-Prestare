import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { JwtStrategy } from './jwt.strategy';
import { MobileAuthService } from './mobile-auth.service';
import {
  SindicoMobileController,
  MoradoresMobileController,
  FuncionariosMobileController,
  DashboardMobileController,
  CondominioMobileController,
} from './mobile-auth.controller';

@Module({
  imports: [
    PassportModule,
    JwtModule.register({
      secret: process.env['JWT_SECRET'] ?? 'fallback-secret',
      signOptions: { expiresIn: process.env['JWT_EXPIRES_IN'] ?? '7d' },
    }),
  ],
  controllers: [
    AuthController,
    SindicoMobileController,
    MoradoresMobileController,
    FuncionariosMobileController,
    DashboardMobileController,
    CondominioMobileController,
  ],
  providers: [AuthService, MobileAuthService, JwtStrategy],
})
export class AuthModule {}