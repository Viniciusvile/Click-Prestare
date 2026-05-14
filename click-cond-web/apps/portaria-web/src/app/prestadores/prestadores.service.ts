import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { API_BASE } from '../shared/api.config';
import { AuthService } from '../auth/auth.service';

export interface Prestador {
  id: number;
  nome: string;
  telefone: string | null;
  categorias: string | null;
  id_condominio: number;
}
export interface CreatePrestador {
  nome: string;
  telefone?: string;
  categorias?: string;
}

@Injectable({ providedIn: 'root' })
export class PrestadoresApi {
  private http = inject(HttpClient);
  private auth = inject(AuthService);

  private get base() {
    const cid = this.auth.porteiroInfo()?.id_condominio ?? 1;
    return `${API_BASE}/condominios/${cid}/prestadores`;
  }

  list(search?: string): Observable<Prestador[]> {
    let params = new HttpParams();
    if (search) params = params.set('search', search);

    return this.http.get<Prestador[]>(this.base, { params }).pipe(
      catchError(() => {
        const mocks: Prestador[] = [
          { id: 601, nome: 'Eletricista 24h - João da Silva', telefone: '(11) 95555-4444', categorias: 'Elétrica, Instalações', id_condominio: 1 },
          { id: 602, nome: 'Desentupidora e Encanador Rápido', telefone: '(11) 94444-3333', categorias: 'Hidráulica, Esgoto', id_condominio: 1 },
          { id: 603, nome: 'Refrigeração Ar Condicionado (Marcos)', telefone: '(11) 93333-2222', categorias: 'Climatização, Limpeza', id_condominio: 1 }
        ];

        if (search) {
          const s = search.toLowerCase();
          return of(mocks.filter(m => m.nome.toLowerCase().includes(s) || (m.categorias && m.categorias.toLowerCase().includes(s))));
        }
        return of(mocks);
      })
    );
  }

  create(dto: CreatePrestador): Observable<Prestador> {
    return this.http.post<Prestador>(this.base, dto).pipe(
      catchError(() => {
        const n: Prestador = {
          id: Date.now(),
          nome: dto.nome,
          telefone: dto.telefone || null,
          categorias: dto.categorias || 'Serviços Gerais',
          id_condominio: 1
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
}
