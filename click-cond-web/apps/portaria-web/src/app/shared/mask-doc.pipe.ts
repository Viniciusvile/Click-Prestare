import { Pipe, PipeTransform } from '@angular/core';

/**
 * Função utilitária para mascaramento de documentos (CPF, CNPJ, RG)
 * em conformidade com o princípio da minimização da LGPD (Art. 6º, III).
 */
export function maskDocument(value: string | null | undefined): string {
  if (!value) return '';
  const str = String(value).trim();
  const digits = str.replace(/\D/g, '');

  // CPF (11 dígitos): ex: 123.***.***-45
  if (digits.length === 11) {
    return `${digits.slice(0, 3)}.***.***-${digits.slice(9)}`;
  }

  // CNPJ (14 dígitos): ex: 12.***.***/0001-34
  if (digits.length === 14) {
    return `${digits.slice(0, 2)}.***.***/${digits.slice(8, 12)}-${digits.slice(12)}`;
  }

  // RG ou documento com outros tamanhos (> 4 dígitos): preserva início e fim
  if (digits.length > 4) {
    const start = digits.slice(0, 2);
    const end = digits.slice(-2);
    return `${start}.***.**-${end}`;
  }

  // Documento muito curto ou não numérico
  if (str.length > 4) {
    return `${str.slice(0, 2)}***${str.slice(-2)}`;
  }

  return str;
}

@Pipe({
  name: 'maskDoc',
  standalone: true,
})
export class MaskDocPipe implements PipeTransform {
  transform(value: string | null | undefined): string {
    return maskDocument(value);
  }
}
