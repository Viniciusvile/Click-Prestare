import { Component, Input } from '@angular/core';
import { CommonModule } from '@angular/common';

@Component({
  selector: 'app-page-header',
  standalone: true,
  imports: [CommonModule],
  template: `
    <div class="flex flex-wrap items-center justify-between gap-4 mb-6">
      <div class="flex items-start gap-4">
        @if (icon) {
          <div class="w-11 h-11 rounded-xl bg-accent/10 border border-accent/20 flex items-center justify-center shrink-0">
            <span class="text-accent" [innerHTML]="icon"></span>
          </div>
        }
        <div>
          <h1 class="text-2xl font-semibold text-white tracking-tight">{{ title }}</h1>
          <p class="text-sm text-slate-400 mt-0.5">{{ subtitle }}</p>
        </div>
      </div>
      <div class="flex items-center gap-2">
        <ng-content></ng-content>
      </div>
    </div>
  `,
})
export class PageHeaderComponent {
  @Input() title = '';
  @Input() subtitle = '';
  @Input() icon = '';
}
