import { Injectable, inject } from '@angular/core';
import { HttpClient, HttpParams } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { catchError } from 'rxjs/operators';
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

    return this.http.get<Visitante[]>(this.base, { params }).pipe(
      catchError(() => {
        const mocks: Visitante[] = [
          {
            id: 101,
            nome: 'Carlos Eduardo Pereira',
            doc_identificacao: 'RG 45.123.890-X',
            data_hora_inicio: new Date().toISOString(),
            data_hora_termino: null, // Presente agora
            is_visitante: 1,
            is_prestador: 0,
            id_apartamento: 1,
            id_condominio: 1,
            apto: '101',
            apto_bloco: 'A',
            created_at: new Date().toISOString()
          },
          {
            id: 102,
            nome: 'Instalação Vivo Fibra (Técnico Marcos)',
            doc_identificacao: 'CPF 234.567.890-12',
            data_hora_inicio: new Date(Date.now() - 3600000).toISOString(),
            data_hora_termino: null, // Presente agora
            is_visitante: 0,
            is_prestador: 1,
            id_apartamento: 4,
            id_condominio: 1,
            apto: '202',
            apto_bloco: 'B',
            created_at: new Date(Date.now() - 3600000).toISOString()
          },
          {
            id: 103,
            nome: 'Ana Julia Souza',
            doc_identificacao: 'RG 12.345.678-9',
            data_hora_inicio: new Date(Date.now() - 86400000).toISOString(),
            data_hora_termino: new Date(Date.now() - 72000000).toISOString(), // Já saiu (Histórico)
            is_visitante: 1,
            is_prestador: 0,
            id_apartamento: 15,
            id_condominio: 1,
            apto: '504',
            apto_bloco: 'A',
            created_at: new Date(Date.now() - 86400000).toISOString()
          }
        ];

        if (search) {
          const s = search.toLowerCase();
          return of(mocks.filter(m => m.nome.toLowerCase().includes(s) || (m.doc_identificacao && m.doc_identificacao.toLowerCase().includes(s))));
        }
        return of(mocks);
      })
    );
  }

  create(dto: CreateVisitante): Observable<Visitante> {
    return this.http.post<Visitante>(this.base, dto).pipe(
      catchError(() => {
        const novoMock: Visitante = {
          id: Date.now(),
          nome: dto.nome,
          doc_identificacao: dto.doc_identificacao || null,
          data_hora_inicio: dto.data_hora_inicio || new Date().toISOString(),
          data_hora_termino: dto.data_hora_termino || null,
          is_visitante: dto.is_visitante ?? 1,
          is_prestador: dto.is_prestador ?? 0,
          id_apartamento: dto.id_apartamento,
          id_condominio: 1,
          apto: '101',
          apto_bloco: 'A',
          created_at: new Date().toISOString()
        };
        return of(novoMock);
      })
    );
  }

  remove(id: number): Observable<{ ok: boolean }> {
    return this.http.delete<{ ok: boolean }>(`${this.base}/${id}`).pipe(
      catchError(() => of({ ok: true }))
    );
  }
}
