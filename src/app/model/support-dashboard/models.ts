export type ServiceStatus = 'RUNNING' | 'STOPPED' | 'DEGRADED';

export interface ClientSummary {
  clientId: string;
  clientName: string;
  publicIp: string;
  region: string;
  cpuAvg: number;        // %
  memAvg: number;        // %
  diskAvg: number;       // %
  servicesRunning: number;
  servicesTotal: number;
  rdsConnections: number;
  agentsOnline: number;
  parallelTickets: number;
  updatedAt: string;     // ISO
}

export interface ServiceProcess {
  id: string;            // pod/task/instance id
  name: string;          // ex: api-gateway
  type: 'EC2' | 'ECS' | 'EKS' | 'LAMBDA' | 'DOCKER';
  status: ServiceStatus;
  cpu: number;           // %
  mem: number;           // %
  uptimeMinutes: number;
}

export interface DatabaseInfo {
  id: string;
  engine: 'PostgreSQL' | 'MySQL' | 'MariaDB' | 'SQLServer' | 'Oracle';
  version: string;
  instanceClass: string;
  storageGb: number;
  status: 'available' | 'modifying' | 'stopped';
  endpoint: string;
}

export interface AgentInfo {
  id: string;
  name: string;
  online: boolean;
  currentTickets: number;
  avgHandleTimeMin: number;
}

export interface NetworkInterfaceInfo {
  id: string;
  privateIp: string;
  publicIp?: string;
  vpcId: string;
  subnetId: string;
  securityGroups: string[];
}
