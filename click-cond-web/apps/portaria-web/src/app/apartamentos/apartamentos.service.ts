import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { API_BASE } from '../shared/api.config';
import { AuthService } from '../auth/auth.service';

export interface Apartamento {
  id: number;
  bloco: string | null;
  apto: string;
  fracao: string | null;
  id_condominio: number;
  qtdMoradores?: number;
}

export interface CreateApartamento {
  bloco?: string;
  apto: string;
  fracao?: string;
}

@Injectable({ providedIn: 'root' })
export class ApartamentosApi {
  private http = inject(HttpClient);
  private auth = inject(AuthService);

  private get base() {
    const cid = this.auth.porteiroInfo()?.id_condominio ?? 1;
    return `${API_BASE}/condominios/${cid}/apartamentos`;
  }

  list(search?: string): Observable<Apartamento[]> {
    let params = new HttpParams();
    if (search) params = params.set('search', search);

    return this.http.get<Apartamento[]>(this.base, { params }).pipe(
      catchError(() => {
        const mocks: Apartamento[] = [
          { id: 1, bloco: 'A', apto: '101', fracao: '0.0125', id_condominio: 1, qtdMoradores: 3 },
          { id: 2, bloco: 'A', apto: '102', fracao: '0.0125', id_condominio: 1, qtdMoradores: 2 },
          { id: 3, bloco: 'A', apto: '201', fracao: '0.0125', id_condominio: 1, qtdMoradores: 4 },
          { id: 4, bloco: 'B', apto: '101', fracao: '0.0150', id_condominio: 1, qtdMoradores: 1 },
          { id: 5, bloco: 'B', apto: '102', fracao: '0.0150', id_condominio: 1, qtdMoradores: 5 }
        ];

        if (search) {
          const s = search.toLowerCase();
          return of(mocks.filter(m => m.apto.includes(s) || (m.bloco && m.bloco.toLowerCase().includes(s))));
        }
        return of(mocks);
      })
    );
  }

  create(dto: CreateApartamento): Observable<Apartamento> {
    return this.http.post<Apartamento>(this.base, dto).pipe(
      catchError(() => {
        const n: Apartamento = {
          id: Date.now(),
          bloco: dto.bloco || 'A',
          apto: dto.apto,
          fracao: dto.fracao || '0.0100',
          id_condominio: 1,
          qtdMoradores: 0
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
