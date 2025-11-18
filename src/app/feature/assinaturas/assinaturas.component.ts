import { Component, computed, signal, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ReactiveFormsModule, FormBuilder, FormGroup, FormControl } from '@angular/forms';
import { MatTableModule } from '@angular/material/table';
import { MatSortModule } from '@angular/material/sort';
import { MatPaginatorModule } from '@angular/material/paginator';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatChipsModule } from '@angular/material/chips';
import { MatIconModule } from '@angular/material/icon';
import { MatButtonModule } from '@angular/material/button';
import { MatMenuModule } from '@angular/material/menu';
import { MatTooltipModule } from '@angular/material/tooltip';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
 

import { Subscription, SubscriptionStatus } from '../../model/subscription.model';
import { SubscriptionService } from '../../services/subscriptions/subscription.service';
import { MatDividerModule } from '@angular/material/divider';

type FiltroForm = FormGroup<{
  q: FormControl<string>;
  status: FormControl<SubscriptionStatus | ''>;
  plano: FormControl<string | ''>;
}>;

@Component({
  selector: 'app-assinaturas',
  standalone: true,
  imports: [
    CommonModule, ReactiveFormsModule,
    MatTableModule, MatSortModule, MatPaginatorModule,
    MatFormFieldModule, MatInputModule, MatSelectModule,
    MatChipsModule, MatIconModule, MatButtonModule, MatMenuModule,
    MatTooltipModule, MatDialogModule, MatDividerModule
  ],
  templateUrl: './assinaturas.component.html',
  styleUrls: ['./assinaturas.component.css']
})
export class AssinaturasComponent implements OnInit {
  displayedColumns = ['id','cliente','plano','valorMensal','ciclo','status','inicio','proxCobranca','falhas','acoes'];

  filtro!: FiltroForm;

  // inicia vazio e popula depois que o service existir
  private base = signal<Subscription[]>([]);

  // Getters para acessar os FormControls com o tipo correto
  get qControl(): FormControl<string> {
    return this.filtro.controls.q;
  }

  get statusControl(): FormControl<SubscriptionStatus | ''> {
    return this.filtro.controls.status;
  }

  get planoControl(): FormControl<string | ''> {
    return this.filtro.controls.plano;
  }

  data = computed(() => {
    const q = (this.filtro?.value.q || '').toLowerCase();
    const st = (this.filtro?.value.status || '') as SubscriptionStatus | '';
    const pl = (this.filtro?.value.plano || '').toLowerCase();

    return this.base().filter(s => {
      const text = `${s.id} ${s.cliente} ${s.email} ${s.plano}`.toLowerCase();
      const okText = !q || text.includes(q);
      const okStatus = !st || s.status === st;
      const okPlano = !pl || s.plano.toLowerCase().includes(pl);
      return okText && okStatus && okPlano;
    });
  });

  totais = computed(() => ({
    total: this.base().length,
    ativas: this.base().filter(s => s.status === 'ATIVA').length,
    pendentes: this.base().filter(s => s.status === 'PENDENTE').length,
    pausadas: this.base().filter(s => s.status === 'PAUSADA').length,
    canceladas: this.base().filter(s => s.status === 'CANCELADA').length,
    mrr: this.base().filter(s => s.status === 'ATIVA')
                     .reduce((acc, s) => acc + s.valorMensal, 0)
  }));

  planos = ['Basic','Pro','Enterprise'];
  statuses: SubscriptionStatus[] = ['ATIVA','PENDENTE','PAUSADA','CANCELADA'];

  constructor(
    private fb: FormBuilder,
    private service: SubscriptionService,
    private dialog: MatDialog
  ) {}

  ngOnInit() {
    this.filtro = this.fb.group({
      q: this.fb.control<string>('', { nonNullable: true }),
      status: this.fb.control<SubscriptionStatus | ''>('', { nonNullable: true }),
      plano: this.fb.control<string | ''>('', { nonNullable: true })
    });

    // Initialize data
    this.base.set(this.service.list());
  }

  limparFiltros() {
    this.filtro.reset({ q: '', status: '', plano: '' });
  }

  ver(sub: Subscription) { 
    alert(`Assinatura ${sub.id} — ${sub.cliente}`); 
  }

  suporte(sub: Subscription) {
    // Aqui você vai implementar a abertura da configuração completa de suporte
    console.log('Abrindo configuração de suporte para:', sub);
    alert(`Abrindo suporte para ${sub.cliente} (ID: ${sub.id})`);
  }

  pausarRetomar(sub: Subscription) {
    const novo = sub.status === 'ATIVA' ? 'PAUSADA'
               : sub.status === 'PAUSADA' ? 'ATIVA'
               : sub.status;
    this.service.update(sub.id, { status: novo });
    this.base.set(this.service.list()); // refaz a lista (mock)
  }

  cancelar(sub: Subscription) {
    if (confirm(`Cancelar a assinatura ${sub.id}?`)) {
      this.service.update(sub.id, { status: 'CANCELADA' });
      this.base.set(this.service.list());
    }
  }

  cobrarAgora(sub: Subscription) {
    alert(`Cobrança imediata simulada para ${sub.cliente} (${sub.id}).`);
  }

  novaAssinatura() {
    // this.dialog.open(NovaAssinaturaDialog, { width: '520px' });
  }
}