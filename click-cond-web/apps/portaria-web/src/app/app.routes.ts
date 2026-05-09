import { Route } from '@angular/router';
import { authGuard } from './auth/auth.guard';

export const appRoutes: Route[] = [
  {
    path: 'login',
    loadComponent: () =>
      import('./auth/login-page.component').then((m) => m.LoginPageComponent),
  },
  {
    path: '',
    canActivate: [authGuard],
    loadComponent: () =>
      import('./shell/shell.component').then((m) => m.ShellComponent),
    children: [
      { path: '', pathMatch: 'full', redirectTo: 'dashboard' },
      {
        path: 'dashboard',
        loadComponent: () =>
          import('./dashboard/dashboard-page.component').then(
            (m) => m.DashboardPageComponent,
          ),
      },
      {
        path: 'visitantes',
        loadComponent: () =>
          import('./visitantes/visitantes-page.component').then(
            (m) => m.VisitantesPageComponent,
          ),
      },
      {
        path: 'prestadores',
        loadComponent: () =>
          import('./prestadores/prestadores-page.component').then(
            (m) => m.PrestadoresPageComponent,
          ),
      },
      {
        path: 'moradores',
        loadComponent: () =>
          import('./moradores/moradores-page.component').then(
            (m) => m.MoradoresPageComponent,
          ),
      },
      {
        path: 'apartamentos',
        loadComponent: () =>
          import('./apartamentos/apartamentos-page.component').then(
            (m) => m.ApartamentosPageComponent,
          ),
      },
      {
        path: 'ocorrencias',
        loadComponent: () =>
          import('./ocorrencias/ocorrencias-page.component').then(
            (m) => m.OcorrenciasPageComponent,
          ),
      },
      {
        path: 'comunicados',
        loadComponent: () =>
          import('./comunicados/comunicados-page.component').then(
            (m) => m.ComunicadosPageComponent,
          ),
      },
      {
        path: 'encomendas',
        loadComponent: () =>
          import('./encomendas/encomendas-page.component').then(
            (m) => m.EncomendasPageComponent,
          ),
      },
    ],
  },
];