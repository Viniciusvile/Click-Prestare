import { Component, inject } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink, RouterLinkActive } from '@angular/router';
import { AuthService } from '../auth/auth.service';

interface NavItem {
  label: string;
  path: string;
  icon: string;
}

@Component({
  selector: 'app-sidebar',
  standalone: true,
  imports: [CommonModule, RouterLink, RouterLinkActive],
  templateUrl: './sidebar.component.html',
})
export class SidebarComponent {
  readonly auth = inject(AuthService);

  readonly nav: NavItem[] = [
    { label: 'Dashboard',    path: '/dashboard',    icon: '◉' },
    { label: 'Visitantes',   path: '/visitantes',   icon: '◆' },
    { label: 'Prestadores',  path: '/prestadores',  icon: '✦' },
    { label: 'Moradores',    path: '/moradores',    icon: '✪' },
    { label: 'Apartamentos', path: '/apartamentos', icon: '▣' },
    { label: 'Ocorrências',  path: '/ocorrencias',  icon: '!' },
    { label: 'Comunicados',  path: '/comunicados',  icon: '✉' },
    { label: 'Encomendas',   path: '/encomendas',   icon: '⬚' },
  ];
}