// src/app/features/subscriptions/subscription.model.ts
export type SubscriptionStatus = 'ATIVA' | 'PAUSADA' | 'CANCELADA' | 'PENDENTE';

export interface Subscription {
  id: string;
  cliente: string;
  email: string;
  plano: string;
  valorMensal: number;
  ciclo: 'mensal' | 'anual';
  status: SubscriptionStatus;
  inicio: string;    // ISO date
  proxCobranca: string; // ISO date
  falhas?: number;
}
