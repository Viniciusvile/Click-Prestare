export interface JwtPayload {
  sub: number;
  nome: string;
  id_condominio: number;
  turno: string | null;
}