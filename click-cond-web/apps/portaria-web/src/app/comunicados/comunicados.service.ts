import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { API_BASE } from '../shared/api.config';
import { AuthService } from '../auth/auth.service';

export interface Comunicado {
  id: number;
  titulo: string;
  descricao: string;
  created_at: string;
}

@Injectable({ providedIn: 'root' })
export class ComunicadosApi {
  private http = inject(HttpClient);
  private auth = inject(AuthService);

  private get base() {
    const cid = this.auth.porteiroInfo()?.id_condominio ?? 1;
    return `${API_BASE}/condominios/${cid}/comunicados`;
  }

  list(): Observable<Comunicado[]> {
    return this.http.get<Comunicado[]>(this.base).pipe(
      catchError(() => of([
        {
          id: 301,
          titulo: 'Manutenção Preventiva dos Elevadores',
          descricao: 'Informamos que nesta sexta-feira, das 08h às 12h, o elevador social do bloco A estará inoperante para revisão técnica programada.',
          created_at: new Date().toISOString()
        },
        {
          id: 302,
          titulo: 'Coleta Seletiva e Descarte de Lixo',
          descricao: 'Solicitamos a todos os moradores que respeitem os horários de coleta e utilizem devidamente os contêineres azuis para recicláveis.',
          created_at: new Date(Date.now() - 86400000).toISOString()
        },
        {
          id: 303,
          titulo: 'Assembleia Geral Ordinária',
          descricao: 'Edital de convocação publicado. A assembleia acontecerá no dia 25/05 às 19:30h no salão principal. Contamos com a presença de todos.',
          created_at: new Date(Date.now() - 172800000).toISOString()
        }
      ]))
    );
  }
}
