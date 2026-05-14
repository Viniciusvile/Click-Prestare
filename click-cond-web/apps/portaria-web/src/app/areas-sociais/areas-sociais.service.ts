import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { API_BASE } from '../shared/api.config';
import { AuthService } from '../auth/auth.service';

export interface AreaSocial {
  id: number;
  nome: string;
  imagem: string;
  precisa_agendar?: number;
  precisa_autorizacao?: number;
  precisa_pagamento?: number;
  capacidade?: number;
  horarios?: any[];
}

export interface AgendamentoArea {
  id: number;
  nomeArea: string;
  status: string;
  bloco: string;
  apto: string;
  data_criacao: string;
  data: string;
  horaDe: string;
  horaAte: string;
}

@Injectable({ providedIn: 'root' })
export class AreasSociaisApi {
  private http = inject(HttpClient);
  private auth = inject(AuthService);

  private get cid() {
    return this.auth.porteiroInfo()?.id_condominio ?? 1;
  }

  // Listar áreas sociais
  listAreas(): Observable<AreaSocial[]> {
    const url = `${API_BASE}/areasSociais/get-all?id_condominio=${this.cid}`;
    return this.http.get<AreaSocial[]>(url).pipe(
      catchError(() => of([
        { id: 1, nome: 'Churrasqueira Gourmet', imagem: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=600', capacidade: 25 },
        { id: 2, nome: 'Salão de Festas', imagem: 'https://images.unsplash.com/photo-1519671482749-fd09be7ccebf?w=600', capacidade: 80 }
      ]))
    );
  }

  // Detalhes da área
  getArea(id: number): Observable<any> {
    const url = `${API_BASE}/areasSociais/get?id_condominio=${this.cid}&id=${id}`;
    return this.http.get<any>(url);
  }

  // Criar nova área
  insertArea(area: any): Observable<any> {
    const url = `${API_BASE}/areasSociais/insert`;
    return this.http.post(url, { id_condominio: this.cid, areaSocial: area });
  }

  // Atualizar área
  updateArea(area: any): Observable<any> {
    const url = `${API_BASE}/areasSociais/update`;
    return this.http.post(url, { id_condominio: this.cid, areaSocial: area });
  }

  // Remover área
  removeArea(id: number): Observable<any> {
    const url = `${API_BASE}/areasSociais/remove`;
    return this.http.post(url, { id });
  }

  // Listar todos os agendamentos do condomínio
  listAgendamentos(): Observable<AgendamentoArea[]> {
    const url = `${API_BASE}/areasSociais/agendamentos/get-all?id_condominio=${this.cid}`;
    return this.http.get<AgendamentoArea[]>(url).pipe(
      catchError(() => of([
        {
          id: 1, nomeArea: 'Churrasqueira Gourmet', status: 'pendente', bloco: 'A', apto: '101',
          data_criacao: '14/05/2026 às 10:00', data: '20/05/2026', horaDe: '12:00', horaAte: '16:00'
        }
      ]))
    );
  }

  // Atualizar status de um agendamento (Aprovar/Recusar)
  updateStatus(id: number, isAccept: boolean, motivo: string = ''): Observable<any> {
    const url = `${API_BASE}/areasSociais/agendamento/update-status`;
    return this.http.post(url, {
      id,
      isAccept,
      status: isAccept ? 'aprovado' : 'recusado',
      motivo_recusa: motivo,
      id_condominio: this.cid
    });
  }
}
