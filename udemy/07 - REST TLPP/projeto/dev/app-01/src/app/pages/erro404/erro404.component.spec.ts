import { ComponentFixture, TestBed } from '@angular/core/testing';

import { Erro404Component } from './erro404.component';

describe('Erro404Component', () => {
  let component: Erro404Component;
  let fixture: ComponentFixture<Erro404Component>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [Erro404Component]
    });
    fixture = TestBed.createComponent(Erro404Component);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
