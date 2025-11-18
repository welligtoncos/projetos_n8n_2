import { Component } from '@angular/core';
import { Router, RouterOutlet } from '@angular/router';
import { MatSlideToggleModule } from '@angular/material/slide-toggle';
import { CommonModule } from '@angular/common';
import { NavbarComponent } from '../shared/navbar/navbar.component';
import { FooterComponent } from '../shared/footer/footer.component';
@Component({
  selector: 'app-root',
  imports: [ NavbarComponent,FooterComponent, CommonModule, RouterOutlet,MatSlideToggleModule],
  templateUrl: './app.component.html',
  styleUrl: './app.component.css'
})
export class AppComponent {
  title = 'ss-agent-dashboard';
  usuario: string | null = null; // Nome do usuário logado (null = não logado)
  isLoggedIn = false; // Controle de login

  constructor(private router: Router) {}
   isLoginPage(): boolean {
    return this.router.url === '/login';
  }

  ngOnInit() {
    // Simulação: verifica se já tem "login" salvo (mockado no localStorage)
    // const savedUser = localStorage.getItem('usuario');
    // if (savedUser) {
    //   this.usuario = savedUser;
    //   this.isLoggedIn = true;
    // }
  }
  
    loginMock() {
    // Simula login
    this.usuario = 'Yasmin Santos';
    this.isLoggedIn = true;
    localStorage.setItem('usuario', this.usuario);
    this.router.navigate(['/home']);
  }

  logout() {
    // Simula logout
    this.usuario = null;
    this.isLoggedIn = false;
    localStorage.removeItem('usuario');
    this.router.navigate(['/login']);
  }
}
