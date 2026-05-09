import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
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
    return this.http.get<Ocorrencia[]>(this.base, { params });
  }
  categorias() { return this.http.get<Categoria[]>(`${this.base}/categorias`); }
  create(dto: CreateOcorrencia) { return this.http.post<Ocorrencia>(this.base, dto); }
  updateStatus(id: number, status: OcorrenciaStatus) {
    return this.http.patch<Ocorrencia>(`${this.base}/${id}/status`, { status });
  }
  remove(id: number) { return this.http.delete<{ ok: boolean }>(`${this.base}/${id}`); }
}
