import { NgModule } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';

import { AppRoutingModule } from './app-routing.module';
import { AppComponent } from './app.component';
import { PoModule } from '@po-ui/ng-components';
import { HTTP_INTERCEPTORS, HttpClientModule } from '@angular/common/http';
import { RouterModule } from '@angular/router';
import { PoTemplatesModule } from '@po-ui/ng-templates';
import { HomeComponent } from './pages/home/home.component';
import { LoginComponent } from './pages/login/login.component';
import { MasterComponent } from './pages/master/master.component';
import { Erro404Component } from './pages/erro404/erro404.component';
import { AuthGuard } from './helpers/auth.guard';
import { AddTokenProtheus } from './helpers/addTokenProtheus.intercept';
import { CustomerDetailComponent } from './pages/customer/customer-detail/customer-detail.component';
import { CustomerEditComponent } from './pages/customer/customer-edit/customer-edit.component';
import { CustomerListComponent } from './pages/customer/customer-list/customer-list.component';
import { OrcamentosComponent } from './pages/orcamentos/orcamentos.component';
import { CustomerService } from './services/customerService';
import { CustomerNewComponent } from './pages/customer/customer-new/customer-new.component';
import { CustomerDelComponent } from './pages/customer/customer-del/customer-del.component';
import { CustomerIndicatorsComponent } from './pages/customer/customer-indicators/customer-indicators.component';
import { CustomIntercept } from './helpers/customerIntercept';

@NgModule({
  declarations: [
    AppComponent,
    HomeComponent,
    LoginComponent,
    MasterComponent,
    Erro404Component,
    CustomerListComponent,
    OrcamentosComponent,
    CustomerDetailComponent,
    CustomerEditComponent,
    CustomerNewComponent,
    CustomerDelComponent,
    CustomerIndicatorsComponent,
  ],
  imports: [
    BrowserModule,
    AppRoutingModule,
    PoModule,
    HttpClientModule,
    RouterModule.forRoot([]),
    PoTemplatesModule
  ],
  providers: [
    AuthGuard,
    { provide: HTTP_INTERCEPTORS, useClass: AddTokenProtheus, multi: true },
    { provide: HTTP_INTERCEPTORS, useClass: CustomIntercept, multi: true },
  ],
  bootstrap: [AppComponent]
})
export class AppModule { }
