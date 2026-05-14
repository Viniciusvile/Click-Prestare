import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { API_BASE } from '../shared/api.config';
import { AuthService } from '../auth/auth.service';

export interface Assembleia {
  id: number;
  titulo: string;
  descricao?: string;
  data: string;
  hora: string;
  local?: string;
  link?: string;
  anexos?: string;
}

export interface Votacao {
  id: number;
  titulo: string;
  descricao?: string;
  data_inicio: string;
  data_termino: string;
  status: number; // 0=Agendado, 1=Em andamento, 2=Finalizado
  opcoes: string[]; // "id;nome;votos"
}

@Injectable({ providedIn: 'root' })
export class AssembleiasApi {
  private http = inject(HttpClient);
  private auth = inject(AuthService);

  private get cid() {
    return this.auth.porteiroInfo()?.id_condominio ?? 1;
  }

  // ==========================================
  // ASSEMBLEIAS
  // ==========================================
  listAssembleias(): Observable<Assembleia[]> {
    const url = `${API_BASE}/assembleias/get-all?id_condominio=${this.cid}`;
    return this.http.get<Assembleia[]>(url).pipe(
      catchError(() => of([
        { id: 1, titulo: 'Assembleia Geral Ordinária', descricao: 'Aprovação de orçamentos e eleição', data: '20/05/2026', hora: '19:30', local: 'Salão Principal' }
      ]))
    );
  }

  getAssembleia(id: number): Observable<{ assembleia: Assembleia; votacoes: Votacao[]; meusVotos: string[] }> {
    const url = `${API_BASE}/assembleias/get?id_condominio=${this.cid}&id=${id}`;
    return this.http.get<any>(url);
  }

  insertAssembleia(payload: any): Observable<any> {
    const url = `${API_BASE}/assembleias/insert`;
    return this.http.post(url, { id_condominio: this.cid, assembleia: payload });
  }

  updateAssembleia(payload: any): Observable<any> {
    const url = `${API_BASE}/assembleias/update`;
    return this.http.post(url, { id_condominio: this.cid, assembleia: payload });
  }

  removeAssembleia(id: number): Observable<any> {
    const url = `${API_BASE}/assembleias/remove`;
    return this.http.post(url, { id });
  }

  finishAssembleia(assembleia: any): Observable<any> {
    const url = `${API_BASE}/assembleias/finish/insert`;
    return this.http.post(url, { id_condominio: this.cid, assembleia });
  }

  // ==========================================
  // VOTAÇÕES E ENQUETES
  // ==========================================
  insertVotacao(payload: any): Observable<any> {
    const url = `${API_BASE}/assembleias/votacoes/insert`;
    return this.http.post(url, { id_condominio: this.cid, votacao: payload });
  }

  removeVotacao(id: number): Observable<any> {
    const url = `${API_BASE}/assembleias/votacoes/remove`;
    return this.http.post(url, { id });
  }

  finishVotacao(id: number): Observable<any> {
    const url = `${API_BASE}/assembleias/votacoes/finish`;
    return this.http.post(url, { id });
  }

  listEnquetes(): Observable<Votacao[]> {
    const url = `${API_BASE}/assembleias/votacoes/enquetes/get-all?id_condominio=${this.cid}`;
    return this.http.get<Votacao[]>(url).pipe(
      catchError(() => of([
        {
          id: 101, titulo: 'Melhoria na Portaria', descricao: 'Instalação de biometria facial',
          data_inicio: '10/05/2026', data_termino: '25/05/2026', status: 1,
          opcoes: ['1;Sim, concordo;12', '2;Não é prioridade;4']
        }
      ]))
    );
  }
}
