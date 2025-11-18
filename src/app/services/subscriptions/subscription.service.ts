// src/app/features/subscriptions/subscription.service.ts
import { Injectable, signal } from '@angular/core'; 
import { Subscription } from '../../model/subscription.model';

@Injectable({ providedIn: 'root' })
export class SubscriptionService {
  private _data = signal<Subscription[]>([
    {
      id: 'SUB-001', cliente: 'Empresa A', email: 'financeiro@a.com',
      plano: 'Pro', valorMensal: 299.9, ciclo: 'mensal', status: 'ATIVA',
      inicio: '2025-05-10', proxCobranca: '2025-09-10', falhas: 0
    },
    {
      id: 'SUB-002', cliente: 'Clínica Vida', email: 'contato@vida.com',
      plano: 'Basic', valorMensal: 99.9, ciclo: 'mensal', status: 'PENDENTE',
      inicio: '2025-08-01', proxCobranca: '2025-09-01', falhas: 1
    },
    {
      id: 'SUB-003', cliente: 'Loja XPTO', email: 'adm@xpto.com',
      plano: 'Enterprise', valorMensal: 999.0, ciclo: 'anual', status: 'PAUSADA',
      inicio: '2024-10-03', proxCobranca: '2025-10-03', falhas: 0
    },
    {
      id: 'SUB-004', cliente: 'Studio Bela', email: 'financeiro@bela.com',
      plano: 'Pro', valorMensal: 299.9, ciclo: 'mensal', status: 'ATIVA',
      inicio: '2025-03-21', proxCobranca: '2025-09-21', falhas: 2
    },
  ]);

  list() { return this._data(); }

  create(sub: Subscription) {
    this._data.update(arr => [sub, ...arr]);
  }

  update(id: string, patch: Partial<Subscription>) {
    this._data.update(arr => arr.map(s => s.id === id ? { ...s, ...patch } : s));
  }
}
