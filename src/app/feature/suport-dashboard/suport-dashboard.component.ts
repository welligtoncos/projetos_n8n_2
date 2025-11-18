import { Component, computed, inject, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { MatCardModule } from '@angular/material/card';
import { MatChipsModule } from '@angular/material/chips';
import { MatIconModule } from '@angular/material/icon';
import { MatDividerModule } from '@angular/material/divider';
import { MatTableModule } from '@angular/material/table';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { MatTooltipModule } from '@angular/material/tooltip'; 
import { SupportDashboardService } from '../../services/subscriptions/support-dashboard/support-dashboard.service';

@Component({
  selector: 'app-suport-dashboard',
  standalone: true,
  imports: [
    CommonModule,
    MatCardModule, MatChipsModule, MatIconModule, MatDividerModule,
    MatTableModule, MatProgressBarModule, MatTooltipModule
  ],
  templateUrl: './suport-dashboard.component.html',
  styleUrls: ['./suport-dashboard.component.css']
})
export class SuportDashboardComponent {
  // poderia vir de rota/query param
  clientId = signal('cliente-acme');

  private svc = inject(SupportDashboardService);

  summary = this.svc.getSummary(this.clientId());
  services = this.svc.getServices(this.clientId());
  databases = this.svc.getDatabases(this.clientId());
  agents = this.svc.getAgents(this.clientId());
  network = this.svc.getNetwork(this.clientId());

  // KPIs derivados se precisar
  servicesRunningPct = computed(() => {
    const s = this.summary();
    return Math.round((s.servicesRunning / s.servicesTotal) * 100);
  });

  displayedServiceCols = ['name','type','status','cpu','mem','uptime'];
  displayedDbCols = ['engine','version','instanceClass','storageGb','status','endpoint'];
  displayedAgentCols = ['name','online','currentTickets','aht'];
  displayedNetCols = ['id','privateIp','publicIp','vpcId','subnetId','sgs'];
}
