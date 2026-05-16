import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable } from 'rxjs';
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
    return this.http.get<Comunicado[]>(this.base);
  }
}
