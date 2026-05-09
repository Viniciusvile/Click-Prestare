import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-stat-pill',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="flex items-center gap-3 px-4 py-3 rounded-xl bg-graphite-200 border border-white/10 min-w-[140px]">
      <div class="w-8 h-8 rounded-lg flex items-center justify-center shrink-0"
           [class]="iconBg">
        <span [innerHTML]="icon" [class]="iconColor"></span>
      </div>
      <div>
        <p class="text-xl font-semibold text-white tabular-nums leading-none">{{ value }}</p>
        <p class="text-[11px] text-slate-400 mt-1">{{ label }}</p>
      </div>
    </div>
  `,
})
export class StatPillComponent {
  @Input() label = '';
  @Input() value: string | number = 0;
  @Input() icon = '';
  @Input() iconColor = 'text-accent';
  @Input() iconBg = 'bg-accent/10 border border-accent/20';
}
