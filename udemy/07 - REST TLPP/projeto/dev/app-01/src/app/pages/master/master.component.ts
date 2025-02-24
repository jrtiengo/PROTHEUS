import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { PoDialogService, PoMenuItem, PoNotification, PoNotificationService } from '@po-ui/ng-components';

@Component({
  selector: 'app-master',
  templateUrl: './master.component.html',
  styleUrls: ['./master.component.css']
})
export class MasterComponent {

  constructor(private router:Router, private poDialog: PoDialogService, private poNotification: PoNotificationService){}

  readonly menus: Array<PoMenuItem> = [
    {label: "Home", action: this.onClickToHome.bind(this), icon: 'po-icon po-icon-home',shortLabel: 'Home'},
    {label: "Clientes", action: this.onClickToClientes.bind(this), icon: 'po-icon po-icon-users',shortLabel: 'Clientes'},
    {label: "Orçamentos", action: this.onClickToOrcamentos.bind(this), icon: 'po-icon po-icon-sale',shortLabel: 'Orçamentos'},
    {label: "Sair", action: this.onClickSair.bind(this), icon: 'po-icon po-icon-exit',shortLabel: 'Sair'},
  ];

  private onClickToHome(){
    this.router.navigate(['']);
  }

  private onClickToClientes(){
    this.router.navigate(['customer-list']);
  }

  private onClickToOrcamentos(){
    this.router.navigate(['orcamentos'])
  }

  private onClickSair(){
    this.poDialog.confirm({
      literals: {cancel: 'Cancelar',confirm: 'Encerrar'},
      title: 'Encerrar Seção',
      message: 'Confirma o encerramento da seção?',
      confirm: () => {
        localStorage.clear();
        this.router.navigate(['']);
        location.reload();
      },
      cancel: () => {
        location.reload();
      }
    })
  }

}
