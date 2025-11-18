import { Component, computed, ElementRef, inject, OnDestroy, OnInit, signal, ViewChild } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MatSnackBar, MatSnackBarModule } from '@angular/material/snack-bar';
import { Router, RouterLink } from '@angular/router';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatIconModule } from '@angular/material/icon';
import { MatCheckboxModule } from '@angular/material/checkbox';
import { MatButtonModule } from '@angular/material/button';
import { MatProgressBarModule } from '@angular/material/progress-bar';
import { CommonModule } from '@angular/common';
interface Particle {
  x: number;
  y: number;
  vx: number;
  vy: number;
  size: number;
  opacity: number;
}
@Component({
  selector: 'app-login',
  imports: [CommonModule, ReactiveFormsModule, RouterLink,
    MatCardModule, MatFormFieldModule, MatInputModule, MatIconModule,
    MatCheckboxModule, MatButtonModule, MatProgressBarModule, MatSnackBarModule],
  templateUrl: './login.component.html',
  styleUrl: './login.component.css'
})
export class LoginComponent implements OnInit, OnDestroy{
@ViewChild('particleCanvas', { static: true }) canvasRef!: ElementRef<HTMLCanvasElement>;
  
  private fb = inject(FormBuilder);
  private router = inject(Router);
  private snack = inject(MatSnackBar);
  
  private animationId?: number;
  private particles: Particle[] = [];

  hidePassword = signal(true);
  loading = signal(false);
  focusedField = signal('');

  form = this.fb.group({
    email: ['', [Validators.required, Validators.email]],
    password: ['', [Validators.required, Validators.minLength(6)]],
    remember: [true]
  });

  emailError = computed(() => {
    const control = this.form.controls.email;
    if (!control.touched && !control.dirty) return '';
    if (control.hasError('required')) return 'E-mail é obrigatório';
    if (control.hasError('email')) return 'E-mail inválido';
    return '';
  });

  passwordError = computed(() => {
    const control = this.form.controls.password;
    if (!control.touched && !control.dirty) return '';
    if (control.hasError('required')) return 'Senha é obrigatória';
    if (control.hasError('minlength')) return 'Mínimo de 6 caracteres';
    return '';
  });

  ngOnInit() {
    this.initParticles();
    this.animate();
  }

  ngOnDestroy() {
    if (this.animationId) {
      cancelAnimationFrame(this.animationId);
    }
  }

  private initParticles() {
    const canvas = this.canvasRef.nativeElement;
    const ctx = canvas.getContext('2d');
    
    if (!ctx) return;

    const resizeCanvas = () => {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
    };

    resizeCanvas();
    window.addEventListener('resize', resizeCanvas);

    // Criar partículas
    for (let i = 0; i < 50; i++) {
      this.particles.push({
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        vx: (Math.random() - 0.5) * 0.5,
        vy: (Math.random() - 0.5) * 0.5,
        size: Math.random() * 2 + 1,
        opacity: Math.random() * 0.5 + 0.1
      });
    }
  }

  private animate = () => {
    const canvas = this.canvasRef.nativeElement;
    const ctx = canvas.getContext('2d');
    
    if (!ctx) return;

    ctx.clearRect(0, 0, canvas.width, canvas.height);

    this.particles.forEach(particle => {
      particle.x += particle.vx;
      particle.y += particle.vy;

      if (particle.x < 0 || particle.x > canvas.width) particle.vx *= -1;
      if (particle.y < 0 || particle.y > canvas.height) particle.vy *= -1;

      ctx.beginPath();
      ctx.arc(particle.x, particle.y, particle.size, 0, Math.PI * 2);
      ctx.fillStyle = `rgba(99, 102, 241, ${particle.opacity})`;
      ctx.fill();
    });

    this.animationId = requestAnimationFrame(this.animate);
  };

  async submit() {
    if (this.form.invalid) {
      this.form.markAllAsTouched();
      return;
    }

    this.loading.set(true);
    const { email, password, remember } = this.form.value;

    try {
      // Simular chamada de API
      await new Promise(resolve => setTimeout(resolve, 2000));
      
      this.snack.open('Login realizado com sucesso!', 'OK', { 
        duration: 2500,
        panelClass: ['success-snackbar']
      });
      this.router.navigateByUrl('/dashboard');
    } catch (e: any) {
      this.snack.open(e?.message || 'Falha ao autenticar.', 'Fechar', { 
        duration: 3500,
        panelClass: ['error-snackbar']
      });
    } finally {
      this.loading.set(false);
    }
  }
}
