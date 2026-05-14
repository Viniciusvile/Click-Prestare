import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { API_BASE } from '../shared/api.config';
import { AuthService } from '../auth/auth.service';

export type OcorrenciaStatus = 'Pendente' | 'Ciente' | 'Solucionado';

export interface Categoria { id: number; nome: string; prioridade: number; }

export interface Ocorrencia {
  id: number;
  descricao: string;
  status: OcorrenciaStatus;
  resposta: string | null;
  resposta_at: string | null;
  tipo: number;
  tipoNome?: string;
  created_at: string;
}

export interface CreateOcorrencia {
  descricao: string;
  tipo: number;
}

@Injectable({ providedIn: 'root' })
export class OcorrenciasApi {
  private http = inject(HttpClient);
  private auth = inject(AuthService);

  private get base() {
    const cid = this.auth.porteiroInfo()?.id_condominio ?? 1;
    return `${API_BASE}/condominios/${cid}/ocorrencias`;
  }

  list(status?: string): Observable<Ocorrencia[]> {
    let params = new HttpParams();
    if (status) params = params.set('status', status);

    return this.http.get<Ocorrencia[]>(this.base, { params }).pipe(
      catchError(() => {
        const mocks: Ocorrencia[] = [
          {
            id: 201,
            descricao: 'Festa no apartamento 302 após as 23h com som de alta intensidade incomodando moradores vizinhos.',
            status: 'Pendente',
            resposta: null,
            resposta_at: null,
            tipo: 1,
            tipoNome: 'Barulho excessivo',
            created_at: new Date().toISOString()
          },
          {
            id: 202,
            descricao: 'Portão eletrônico da garagem apresentando travamento intermitente na abertura.',
            status: 'Ciente',
            resposta: 'Técnico notificado, visita agendada para hoje à tarde.',
            resposta_at: new Date(Date.now() - 1800000).toISOString(),
            tipo: 3,
            tipoNome: 'Portão danificado',
            created_at: new Date(Date.now() - 7200000).toISOString()
          },
          {
            id: 203,
            descricao: 'Lâmpada do hall principal do bloco B queimada.',
            status: 'Solucionado',
            resposta: 'Lâmpada substituída pelo zelador no turno da manhã.',
            resposta_at: new Date(Date.now() - 86400000).toISOString(),
            tipo: 2,
            tipoNome: 'Manutenção Predial',
            created_at: new Date(Date.now() - 172800000).toISOString()
          }
        ];

        if (status) {
          return of(mocks.filter(m => m.status === status));
        }
        return of(mocks);
      })
    );
  }

  categorias(): Observable<Categoria[]> {
    return this.http.get<Categoria[]>(`${this.base}/categorias`).pipe(
      catchError(() => of([
        { id: 1, nome: 'Barulho excessivo', prioridade: 1 },
        { id: 2, nome: 'Manutenção Predial', prioridade: 3 },
        { id: 3, nome: 'Portão danificado', prioridade: 1 }
      ]))
    );
  }

  create(dto: CreateOcorrencia): Observable<Ocorrencia> {
    return this.http.post<Ocorrencia>(this.base, dto).pipe(
      catchError(() => {
        const n: Ocorrencia = {
          id: Date.now(),
          descricao: dto.descricao,
          status: 'Pendente',
          resposta: null,
          resposta_at: null,
          tipo: dto.tipo,
          tipoNome: dto.tipo === 1 ? 'Barulho excessivo' : dto.tipo === 3 ? 'Portão danificado' : 'Geral',
          created_at: new Date().toISOString()
        };
        return of(n);
      })
    );
  }

  updateStatus(id: number, status: OcorrenciaStatus): Observable<Ocorrencia> {
    return this.http.patch<Ocorrencia>(`${this.base}/${id}/status`, { status }).pipe(
      catchError(() => {
        return of({
          id,
          descricao: 'Ocorrência atualizada localmente',
          status,
          resposta: 'Status modificado para ' + status,
          resposta_at: new Date().toISOString(),
          tipo: 1,
          created_at: new Date().toISOString()
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
