import { Routes } from '@angular/router';
import { LoginComponent } from './feature/login/login.component';
import { HomeComponent } from './feature/home/home.component';
import { AssinaturasComponent } from './feature/assinaturas/assinaturas.component';
import { SuportDashboardComponent } from './feature/suport-dashboard/suport-dashboard.component';

export const routes: Routes = [
     { path: '', redirectTo: '/login', pathMatch: 'full' },
     { path: 'home', component: HomeComponent },
     { path: 'login', component: LoginComponent },
     { path: 'assinatura', component: AssinaturasComponent },
     { path: 'suporte', component: SuportDashboardComponent }

];
