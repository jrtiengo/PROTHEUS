import { ComponentFixture, TestBed } from '@angular/core/testing';

import { OrcamentosComponent } from './orcamentos.component';

describe('OrcamentosComponent', () => {
  let component: OrcamentosComponent;
  let fixture: ComponentFixture<OrcamentosComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [OrcamentosComponent]
    });
    fixture = TestBed.createComponent(OrcamentosComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
