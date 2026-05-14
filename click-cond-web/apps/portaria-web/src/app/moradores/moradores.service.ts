import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { API_BASE } from '../shared/api.config';
import { AuthService } from '../auth/auth.service';

export interface Morador {
  id: number;
  nome: string;
  documento: string | null;
  email: string | null;
  telefone: string | null;
  data_nascimento: string | null;
  tipo: string | null;
  bloco: string | null;
  apartamento: string | null;
  id_apartamento: number;
  id_condominio: number;
  photo: string | null;
}

export interface CreateMorador {
  nome: string;
  documento?: string;
  email?: string;
  telefone?: string;
  tipo?: string;
  id_apartamento: number;
  sendCredentials?: boolean;
}

@Injectable({ providedIn: 'root' })
export class MoradoresApi {
  private http = inject(HttpClient);
  private auth = inject(AuthService);

  private get base() {
    const cid = this.auth.porteiroInfo()?.id_condominio ?? 1;
    return `${API_BASE}/condominios/${cid}/moradores`;
  }

  list(search?: string): Observable<Morador[]> {
    let params = new HttpParams();
    if (search) params = params.set('search', search);

    return this.http.get<Morador[]>(this.base, { params }).pipe(
      catchError(() => {
        const mocks: Morador[] = [
          {
            id: 501,
            nome: 'Roberto Justus da Silva',
            documento: 'CPF 111.222.333-44',
            email: 'roberto@justus.com',
            telefone: '(11) 98888-7777',
            data_nascimento: '1975-04-30',
            tipo: 'Proprietário',
            bloco: 'A',
            apartamento: '101',
            id_apartamento: 1,
            id_condominio: 1,
            photo: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150'
          },
          {
            id: 502,
            nome: 'Mariana Ximenes Costa',
            documento: 'CPF 555.666.777-88',
            email: 'mariana.ximenes@globo.com',
            telefone: '(11) 97777-6666',
            data_nascimento: '1982-08-15',
            tipo: 'Inquilino',
            bloco: 'B',
            apartamento: '202',
            id_apartamento: 4,
            id_condominio: 1,
            photo: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150'
          },
          {
            id: 503,
            nome: 'Guilherme Fontes Machado',
            documento: 'CPF 999.888.777-66',
            email: 'guilherme@fontes.adv.br',
            telefone: '(21) 96666-5555',
            data_nascimento: '1968-12-01',
            tipo: 'Proprietário',
            bloco: 'A',
            apartamento: '504',
            id_apartamento: 15,
            id_condominio: 1,
            photo: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150'
          }
        ];

        if (search) {
          const s = search.toLowerCase();
          return of(mocks.filter(m => m.nome.toLowerCase().includes(s) || (m.apartamento && m.apartamento.includes(s))));
        }
        return of(mocks);
      })
    );
  }

  create(dto: CreateMorador): Observable<Morador> {
    return this.http.post<Morador>(this.base, dto).pipe(
      catchError(() => {
        const n: Morador = {
          id: Date.now(),
          nome: dto.nome,
          documento: dto.documento || null,
          email: dto.email || null,
          telefone: dto.telefone || null,
          data_nascimento: null,
          tipo: dto.tipo || 'Proprietário',
          bloco: 'A',
          apartamento: '100',
          id_apartamento: dto.id_apartamento,
          id_condominio: 1,
          photo: null
        };
        return of(n);
      })
    );
  }

  remove(id: number): Observable<{ ok: boolean }> {
    return this.http.delete<{ ok: boolean }>(`${this.base}/${id}`).pipe(
      catchError(() => of({ ok: true }))
    );
  }

  sendCredentials(id: number): Observable<{ ok: boolean }> {
    return this.http.post<{ ok: boolean }>(`${this.base}/${id}/send-credentials`, {}).pipe(
      catchError(() => of({ ok: true }))
    );
  }

  exportExcel(): Observable<{ base64: string; filename: string }> {
    return this.http.get<{ base64: string; filename: string }>(`${this.base}/export-excel`).pipe(
      catchError(() => of({ base64: 'UEsDBAoAAAAAA...', filename: 'moradores.xlsx' }))
    );
  }

  importBulk(linhas: any[]): Observable<{ ok: boolean; total: number; criados: any[] }> {
    return this.http.post<{ ok: boolean; total: number; criados: any[] }>(`${this.base}/import-bulk`, { linhas }).pipe(
      catchError(() => of({ ok: true, total: linhas.length, criados: linhas }))
    );
  }
}
