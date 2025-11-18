import { Injectable, signal } from '@angular/core';
import {
  AgentInfo, ClientSummary, DatabaseInfo, NetworkInterfaceInfo, ServiceProcess
} from '../../../model/support-dashboard/models';

@Injectable({ providedIn: 'root' })
export class SupportDashboardService {
  // Resumo geral do "cliente" (stack local em Docker)
  getSummary(clientId: string) {
    const now = new Date().toISOString();
    return signal<ClientSummary>({
      clientId,
      clientName: 'Stack Evolution (local)',
      publicIp: '127.0.0.1',
      region: 'local-docker',
      cpuAvg: 22,
      memAvg: 46,
      diskAvg: 35,
      servicesRunning: 6,   // postgres, redis, evolution-api, n8n, pgadmin, redis-commander
      servicesTotal: 6,
      rdsConnections: 15,   // usando como "conexões Postgres" aqui no mock
      agentsOnline: 3,
      parallelTickets: 5,
      updatedAt: now
    });
  }

  // Serviços (containers) do compose
  getServices(clientId: string) {
    return signal<ServiceProcess[]>([
      { id: 'postgres',         name: 'postgres',         type: 'DOCKER', status: 'RUNNING',  cpu: 8,  mem: 32, uptimeMinutes: 180 },
      { id: 'redis',            name: 'redis',            type: 'DOCKER', status: 'RUNNING',  cpu: 3,  mem: 20, uptimeMinutes: 180 },
      { id: 'evolution_api',    name: 'evolution-api',    type: 'DOCKER', status: 'RUNNING',  cpu: 14, mem: 28, uptimeMinutes: 175 },
      { id: 'n8n',              name: 'n8n',              type: 'DOCKER', status: 'RUNNING',  cpu: 9,  mem: 40, uptimeMinutes: 175 },
      { id: 'pgadmin',          name: 'pgadmin',          type: 'DOCKER', status: 'RUNNING',  cpu: 4,  mem: 15, uptimeMinutes: 170 },
      { id: 'redis_commander',  name: 'redis-commander',  type: 'DOCKER', status: 'RUNNING',  cpu: 2,  mem: 12, uptimeMinutes: 170 },
    ]);
  }

  // Bancos de dados (os dois que seu compose usa no mesmo Postgres)
  getDatabases(clientId: string) {
    return signal<DatabaseInfo[]>([
      { id:'pg-evolution', engine:'PostgreSQL', version:'15 (pgvector)', instanceClass:'docker', storageGb: 100, status:'available', endpoint:'localhost:5432/evolution' },
      { id:'pg-n8n',       engine:'PostgreSQL', version:'15',            instanceClass:'docker', storageGb: 20,  status:'available', endpoint:'localhost:5432/n8n' },
    ]);
  }

  // Agentes (mock simples pra seus indicadores de atendimento)
  getAgents(clientId: string) {
    return signal<AgentInfo[]>([
      { id:'ag-01', name:'Yasmin',    online:true,  currentTickets: 3, avgHandleTimeMin: 7.2 },
      { id:'ag-02', name:'Welligton', online:true,  currentTickets: 2, avgHandleTimeMin: 6.8 },
      { id:'ag-03', name:'João',      online:false, currentTickets: 0, avgHandleTimeMin: 8.1 },
    ]);
  }

  // Rede (visão simples da bridge do Docker)
  getNetwork(clientId: string) {
    return signal<NetworkInterfaceInfo[]>([
      { id:'evolution_network', privateIp:'172.20.0.2', publicIp: undefined, vpcId:'bridge', subnetId:'evolution_network', securityGroups:['bridge'] },
    ]);
  }
}
