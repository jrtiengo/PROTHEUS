import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CustomerIndicatorsComponent } from './customer-indicators.component';

describe('CustomerIndicatorsComponent', () => {
  let component: CustomerIndicatorsComponent;
  let fixture: ComponentFixture<CustomerIndicatorsComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [CustomerIndicatorsComponent]
    });
    fixture = TestBed.createComponent(CustomerIndicatorsComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
