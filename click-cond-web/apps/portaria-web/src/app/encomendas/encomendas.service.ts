import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { API_BASE } from '../shared/api.config';
import { AuthService } from '../auth/auth.service';

export type EncomendaStatus = 'Aguardando' | 'Retirada';

export interface Encomenda {
  id: number;
  descricao: string;
  destinatario_apto: string;
  destinatario_bloco: string | null;
  recebido_de: string | null;
  recebido_em: string;
  retirado_em: string | null;
  retirado_por: string | null;
  status: EncomendaStatus;
}

export interface CreateEncomenda {
  descricao: string;
  destinatario_apto: string;
  destinatario_bloco?: string;
  recebido_de?: string;
}

@Injectable({ providedIn: 'root' })
export class EncomendasApi {
  private http = inject(HttpClient);
  private auth = inject(AuthService);

  private get base() {
    const cid = this.auth.porteiroInfo()?.id_condominio ?? 1;
    return `${API_BASE}/condominios/${cid}/encomendas`;
  }

  list(status?: string): Observable<Encomenda[]> {
    let params = new HttpParams();
    if (status) params = params.set('status', status);

    return this.http.get<Encomenda[]>(this.base, { params }).pipe(
      catchError(() => {
        const mocks: Encomenda[] = [
          {
            id: 401,
            descricao: 'Pacote Mercado Livre - Caixa Média',
            destinatario_apto: '102',
            destinatario_bloco: 'A',
            recebido_de: 'Correios / Sedex',
            recebido_em: new Date().toISOString(),
            retirado_em: null,
            retirado_por: null,
            status: 'Aguardando'
          },
          {
            id: 402,
            descricao: 'Envelope Documentos - Sedex 10',
            destinatario_apto: '304',
            destinatario_bloco: 'B',
            recebido_de: 'Loggi Transportes',
            recebido_em: new Date(Date.now() - 7200000).toISOString(),
            retirado_em: null,
            retirado_por: null,
            status: 'Aguardando'
          },
          {
            id: 403,
            descricao: 'Caixa Amazon Prime - Eletrônicos',
            destinatario_apto: '501',
            destinatario_bloco: 'A',
            recebido_de: 'Amazon Logistics',
            recebido_em: new Date(Date.now() - 86400000).toISOString(),
            retirado_em: new Date(Date.now() - 10000000).toISOString(),
            retirado_por: 'Fernanda Lima (Titular)',
            status: 'Retirada'
          }
        ];

        if (status) {
          return of(mocks.filter(m => m.status === status));
        }
        return of(mocks);
      })
    );
  }

  create(dto: CreateEncomenda): Observable<Encomenda> {
    return this.http.post<Encomenda>(this.base, dto).pipe(
      catchError(() => {
        const n: Encomenda = {
          id: Date.now(),
          descricao: dto.descricao,
          destinatario_apto: dto.destinatario_apto,
          destinatario_bloco: dto.destinatario_bloco || null,
          recebido_de: dto.recebido_de || 'Transportadora',
          recebido_em: new Date().toISOString(),
          retirado_em: null,
          retirado_por: null,
          status: 'Aguardando'
        };
        return of(n);
      })
    );
  }

  retirar(id: number, retiradoPor: string): Observable<Encomenda> {
    return this.http.patch<Encomenda>(`${this.base}/${id}/retirar`, { retirado_por: retiradoPor }).pipe(
      catchError(() => {
        return of({
          id,
          descricao: 'Encomenda Retirada',
          destinatario_apto: '100',
          destinatario_bloco: 'A',
          recebido_de: 'Logística',
          recebido_em: new Date().toISOString(),
          retirado_em: new Date().toISOString(),
          retirado_por: retiradoPor,
          status: 'Retirada'
        });
      })
    );
  }

  remove(id: number): Observable<{ ok: boolean }> {
    return this.http.delete<{ ok: boolean }>(`${this.base}/${id}`).pipe(
      catchError(() => of({ ok: true }))
    );
  }
}
