import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { PoBreadcrumb } from '@po-ui/ng-components';
import { PoPageDynamicDetailActions, PoPageDynamicDetailField } from '@po-ui/ng-templates';
import { environment } from 'src/app/environment/environment';

@Component({
  selector: 'app-customer-detail',
  templateUrl: './customer-detail.component.html',
  styleUrls: ['./customer-detail.component.css']
})
export class CustomerDetailComponent implements OnInit{

  constructor(private activatedRoute: ActivatedRoute) {}

  codigo: any;
  loja: any;
  serviceApi: any;
  detailTitle: string = `Visualizar Cliente`

  ngOnInit(): void {
    this.activatedRoute.paramMap.subscribe(params => {
      this.codigo = params.get('codigo');
      this.loja = params.get('loja');
      this.serviceApi = `${environment.urlDetalheCliente}?codigo=${this.codigo}&loja=${this.loja}`
    })
  }

  public readonly detailActions: PoPageDynamicDetailActions = { back: '/customer-list'};
  
  public readonly breadcrumb: PoBreadcrumb = {
    items: [
      {label: 'Home', link: '/'},
      {label: 'Clientes',link: '/customer-list'},
      {label: 'Detalhes'}
    ]
  }

  public readonly detailFields: Array<PoPageDynamicDetailField> = [
    {property: 'codigo',label:'Codigo',key: true, tag: true,divider:'Identificação'},
    {property: 'loja',label:'Loja', tag: true},
    {property: 'nome',label: 'Nome', tag: true},
    {property: 'endereco',tag:true,divider:'Endereço'},
    {property: 'cidade', label: 'Cidade',tag:true}
  ]  

}
