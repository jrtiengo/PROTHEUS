import { Component , OnInit, OnDestroy, ViewChild} from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { PoBreadcrumb, PoDynamicFormComponent, PoDynamicFormField, PoDynamicFormLoad, PoNotificationService } from '@po-ui/ng-components';
import { PoPageDynamicEditActions, PoPageDynamicEditField } from '@po-ui/ng-templates';
import { CustomerService } from 'src/app/services/customerService';

@Component({
  selector: 'app-customer-del',
  templateUrl: './customer-del.component.html',
  styleUrls: ['./customer-del.component.css']
})
export class CustomerDelComponent implements OnInit{

  constructor(private activatedRoute: ActivatedRoute, 
              private router: Router,
              private customerService: CustomerService, 
              private poNotify: PoNotificationService) {}

  codigo: any;            
  loja: any;
  customerData: any

  ngOnInit(): void {
    
    this.activatedRoute.paramMap.subscribe(params => {
      this.codigo = params.get('codigo');
      this.loja = params.get('loja');
    })

    if(this.codigo){
      this.customerService.getDataCustomer(this.codigo,this.loja).subscribe(
        {
          next: (data: any) => {
                     
            this.customerData = {
              codigo: this.codigo,
              loja: this.loja,
              nome: data.nome,
              pessoa: data.pessoa,
              endereco: data.endereco,
              cep: data.cep,
              bairro: data.bairro,
              cidade: data.cidade,
              estado: data.estado,
              status: true,
            }          
  
          },
          error:() => {
              this.poNotify.error('Cliente nao encontrado no ERP');
          }
        }
      )
    } 
  }  

  @ViewChild('customerForm') customerForm !: PoDynamicFormComponent;
  
  customerSave() {
    
    this.poNotify.setDefaultDuration(2000)

    this.customerService.delCustomer(this.codigo,this.loja).subscribe({
      next: () => {
        this.poNotify.success('Sucesso!!')
        this.router.navigate(['/customer-list'])
      },

      error: (err: any) => {
        this.poNotify.error(err.message)
      }
    });
    
  }

  customerCancel() {
    this.router.navigate(['/customer-list'])
  }

  formTitle: string =  `Deletar Cliente`
  formActions: PoPageDynamicEditActions = {
    save: '',
  }

  breadcrumb: PoBreadcrumb = {
    items: [
      {label: 'Home', link: '/'},
      {label: 'Clientes',link: '/customer-list'},
      {label: 'Alterar'}
    ]
  }

  formFields: Array<PoDynamicFormField> = [
    {
      property: 'codigo',
      divider:'Identificação',
      key:true,
      required:true,
      readonly:true,
    },{
      property: 'loja',
      key:true,
      required:true,
      readonly:true,
    },{
      property: 'status',
      required: true,
      type: 'boolean',
      booleanTrue: 'Ativo',
      booleanFalse: 'Inativo',
      readonly:true,
    },{
      property: 'pessoa',
      readonly:true,
    },{
      property: 'nome',
      required: true,
      gridColumns: 12,
      readonly:true,
    },{
      property: 'endereco',
      divider: 'Endereço',
      required: true,
      gridColumns: 12,
      readonly:true,
    },{
      property: 'cep',
      required: true,
      readonly:true,
    },{
      property: 'bairro',
      required: true,
      readonly:true,
    },{
      property: 'estado',
      required: true,
      options:['AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO','EX'],
      readonly:true,  
    },{
      property: 'cidade',
      required:true,
      readonly:true,
    }
  ]

}
