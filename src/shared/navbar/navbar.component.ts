import { Component, EventEmitter, Input, Output } from '@angular/core';
import { MatToolbarModule } from '@angular/material/toolbar';
import { MatButtonModule } from '@angular/material/button';
import { MatIconModule } from '@angular/material/icon';
import { CommonModule } from '@angular/common';
import { MatDividerModule } from '@angular/material/divider'
import { MatMenuModule } from '@angular/material/menu';
@Component({
  selector: 'app-navbar',
  imports: [CommonModule, MatMenuModule,MatDividerModule,MatToolbarModule, MatButtonModule, MatIconModule],
  templateUrl: './navbar.component.html',
  styleUrl: './navbar.component.css'
})
export class NavbarComponent {
    @Input() title = 'Meu App';
    @Input() usuario?: string; // ex.: "Yasmin Santos"
    @Output() logout = new EventEmitter<void>();

    onLogout() { this.logout.emit(); }

  get iniciais(): string {
    if (!this.usuario) return '👤';
    const parts = this.usuario.split(' ').filter(Boolean);
    return parts.slice(0, 2).map(p => p[0].toUpperCase()).join('');
  }
}
