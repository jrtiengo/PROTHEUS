import { NgModule } from '@angular/core';
import { RouterModule, Routes } from '@angular/router';
import { LoginComponent } from './pages/login/login.component';
import { MasterComponent } from './pages/master/master.component';
import { AuthGuard } from './helpers/auth.guard';
import { HomeComponent } from './pages/home/home.component';
import { Erro404Component } from './pages/erro404/erro404.component';
import { CustomerListComponent } from './pages/customer/customer-list/customer-list.component';
import { OrcamentosComponent } from './pages/orcamentos/orcamentos.component';
import { CustomerDetailComponent } from './pages/customer/customer-detail/customer-detail.component';
import { CustomerEditComponent } from './pages/customer/customer-edit/customer-edit.component';
import { CustomerNewComponent } from './pages/customer/customer-new/customer-new.component';
import { CustomerDelComponent } from './pages/customer/customer-del/customer-del.component';

const routes: Routes = [
  {path: 'login', component: LoginComponent},
  {
    path: '',
    component: MasterComponent,
    canActivate: [AuthGuard],
    children:[
      {path: '', component: HomeComponent,canActivate: [AuthGuard]},
      {path: 'home', component: HomeComponent,canActivate: [AuthGuard]},
      {path: 'customer-list',component: CustomerListComponent,canActivate: [AuthGuard]},
      {path: 'customer-edit/:codigo/:loja', component: CustomerEditComponent,canActivate: [AuthGuard]},
      {path: 'customer-detail/:codigo/:loja' , component: CustomerDetailComponent,canActivate: [AuthGuard]},    
      {path: 'customer-del/:codigo/:loja', component: CustomerDelComponent, canActivate: [AuthGuard]},     
      {path: 'customer-new',component: CustomerNewComponent,canActivate: [AuthGuard]},
      {path: 'orcamentos',component: OrcamentosComponent,canActivate: [AuthGuard]}
    ]
  },
  {path: '**', component: Erro404Component}
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
