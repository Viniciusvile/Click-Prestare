import { Injectable, inject } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Observable, of } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { API_BASE } from '../shared/api.config';
import { AuthService } from '../auth/auth.service';

export interface DocumentoItem {
  id: number;
  nome: string;
  link_doc: string;
}

@Injectable({ providedIn: 'root' })
export class DocumentosApi {
  private http = inject(HttpClient);
  private auth = inject(AuthService);

  private get cid() {
    return this.auth.porteiroInfo()?.id_condominio ?? 1;
  }

  listDocumentos(isAta: boolean): Observable<DocumentoItem[]> {
    const isAtaStr = isAta ? '1' : '0';
    const url = `${API_BASE}/documentos/get-all?id_condominio=${this.cid}&is_ata=${isAtaStr}`;
    return this.http.get<DocumentoItem[]>(url).pipe(
      catchError(() => {
        if (isAta) {
          return of([
            { id: 101, nome: 'ATA da Assembleia Geral Ordinária - 2026', link_doc: 'https://example.com/ata_2026.pdf' },
          ]);
        } else {
          return of([
            { id: 201, nome: 'Regimento Interno e Normas', link_doc: 'https://example.com/regimento.pdf' },
            { id: 202, nome: 'Convenção do Condomínio', link_doc: 'https://example.com/convencao.pdf' },
          ]);
        }
      })
    );
  }

  insertDocumento(nome: string, isAta: boolean, docBase64: string): Observable<any> {
    const url = `${API_BASE}/documentos/insert`;
    const payload = {
      nome,
      is_ata: isAta ? 1 : 0,
      doc: docBase64,
    };
    return this.http.post(url, { id_condominio: this.cid, documento: payload });
  }

  removeDocumento(id: number): Observable<any> {
    const url = `${API_BASE}/documentos/remove`;
    return this.http.post(url, { id });
  }
}
