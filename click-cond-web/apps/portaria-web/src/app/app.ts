import { Component } from '@angular/core';
import { RouterModule } from '@angular/router';
import { ConfirmHostComponent } from './shared/confirm-host.component';

@Component({
  imports: [RouterModule, ConfirmHostComponent],
  selector: 'app-root',
  templateUrl: './app.html',
  styleUrl: './app.css',
})
export class App {
  protected title = 'portaria-web';
}
