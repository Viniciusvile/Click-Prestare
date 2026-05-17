import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable } from 'rxjs';
import { CreateVisitante, Visitante } from './visitante.model';
import { API_BASE } from '../shared/api.config';
import { AuthService } from '../auth/auth.service';

@Injectable({ providedIn: 'root' })
export class VisitantesService {
  private http = inject(HttpClient);
  private auth = inject(AuthService);

  private get base() {
    const cid = this.auth.porteiroInfo()?.id_condominio ?? 1;
    return `${API_BASE}/condominios/${cid}/visitantes`;
  }

  list(search?: string): Observable<Visitante[]> {
    let params = new HttpParams();
    if (search) params = params.set('search', search);

    return this.http.get<Visitante[]>(this.base, { params });
  }

  create(dto: CreateVisitante): Observable<Visitante> {
    return this.http.post<Visitante>(this.base, dto);
  }

  update(id: number, dto: Partial<CreateVisitante>): Observable<Visitante> {
    return this.http.put<Visitante>(`${this.base}/${id}`, dto);
  }

  remove(id: number): Observable<{ ok: boolean }> {
    return this.http.delete<{ ok: boolean }>(`${this.base}/${id}`);
  }
}
