import { ComponentFixture, TestBed } from '@angular/core/testing';

import { CustomerDelComponent } from './customer-del.component';

describe('CustomerDelComponent', () => {
  let component: CustomerDelComponent;
  let fixture: ComponentFixture<CustomerDelComponent>;

  beforeEach(() => {
    TestBed.configureTestingModule({
      declarations: [CustomerDelComponent]
    });
    fixture = TestBed.createComponent(CustomerDelComponent);
    component = fixture.componentInstance;
    fixture.detectChanges();
  });

  it('should create', () => {
    expect(component).toBeTruthy();
  });
});
