import { ComponentFixture, TestBed } from '@angular/core/testing';

import { SuportDashboardComponent } from './suport-dashboard.component';

describe('SuportDashboardComponent', () => {
  let component: SuportDashboardComponent;
  let fixture: ComponentFixture<SuportDashboardComponent>;

  beforeEach(async () => {
    await TestBed.configureTestingModule({
      imports: [SuportDashboardComponent]
    })
    .compileComponents();

    fixture = TestBed.createComponent(SuportDashboardComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
