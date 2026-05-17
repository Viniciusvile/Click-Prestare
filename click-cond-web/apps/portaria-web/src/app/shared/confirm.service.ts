import { Injectable, signal } from '@angular/core';

export type ConfirmVariant = 'danger' | 'primary';

export interface ConfirmOptions {
  title: string;
  message: string;
  confirmLabel?: string;
  cancelLabel?: string;
  variant?: ConfirmVariant;
}

interface PendingConfirm extends Required<Omit<ConfirmOptions, 'variant'>> {
  variant: ConfirmVariant;
  resolve: (ok: boolean) => void;
}

/**
 * Serviço global de confirmação. Substitui o `window.confirm()` nativo por um
 * modal dentro do app. O host (ConfirmHostComponent) é renderizado uma vez no
 * AppComponent e escuta o sinal `state`.
 */
@Injectable({ providedIn: 'root' })
export class ConfirmService {
  readonly state = signal<PendingConfirm | null>(null);

  ask(opts: ConfirmOptions): Promise<boolean> {
    return new Promise<boolean>((resolve) => {
      this.state.set({
        title: opts.title,
        message: opts.message,
        confirmLabel: opts.confirmLabel ?? 'Confirmar',
        cancelLabel: opts.cancelLabel ?? 'Cancelar',
        variant: opts.variant ?? 'danger',
        resolve,
      });
    });
  }

  resolve(ok: boolean) {
    const current = this.state();
    if (!current) return;
    this.state.set(null);
    current.resolve(ok);
  }
}
