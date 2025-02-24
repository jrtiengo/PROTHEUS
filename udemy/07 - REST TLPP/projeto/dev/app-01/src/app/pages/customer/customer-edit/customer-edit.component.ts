import { Component , OnInit, OnDestroy, ViewChild} from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { PoBreadcrumb, PoComboComponent, PoDynamicFormComponent, PoDynamicFormField, PoDynamicFormFieldChanged, PoDynamicFormLoad, PoDynamicFormValidation, PoNotificationService } from '@po-ui/ng-components';
import { PoPageDynamicEditActions, PoPageDynamicEditComponent, PoPageDynamicEditField } from '@po-ui/ng-templates';
import { CustomerService } from 'src/app/services/customerService';
import { environment } from 'src/app/environment/environment';

@Component({
  selector: 'app-customer-edit',
  templateUrl: './customer-edit.component.html',
  styleUrls: ['./customer-edit.component.css']
})
export class CustomerEditComponent implements OnInit{

  constructor(private activatedRoute: ActivatedRoute, 
              private router: Router,
              private customerService: CustomerService, 
              private poNotify: PoNotificationService) {}

  codigo: any;            
  loja: any;
  customerData: any;
  urlCidades: any;

  ngOnInit(): void {
    
    this.activatedRoute.paramMap.subscribe(params => {
     
      this.codigo = params.get('codigo');
      this.loja = params.get('loja');

      localStorage.setItem('codcliente', this.codigo);
      localStorage.setItem('lojcliente', this.loja);
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
  @ViewChild('estado') estado !: PoComboComponent;
  
  customerSave() {
    
    this.poNotify.setDefaultDuration(2000)

    this.customerService.putDataCustomer(this.customerForm.value).subscribe({
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

  changeField(field: PoDynamicFormFieldChanged): PoDynamicFormValidation {
    return {
      value: {},
      fields: [
        {property:'cidade', optionsService: `${environment.urlListaCidades}/${field.value.estado}`},
      ]
    }
  }

  getUrlCidades(): string {
    return `${environment.urlListaCidades}/ES`;
  }

  editTitle: string =  `Editar Cliente`
  editActions: PoPageDynamicEditActions = {
    save: '',
  }

  breadcrumb: PoBreadcrumb = {
    items: [
      {label: 'Home', link: '/'},
      {label: 'Clientes',link: '/customer-list'},
      {label: 'Alterar'}
    ]
  }

  editFields: Array<PoDynamicFormField> = [
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
    },{
      property: 'pessoa',
    },{
      property: 'nome',
      required: true,
      gridColumns: 12,
    },{
      property: 'endereco',
      divider: 'Endereço',
      required: true,
      gridColumns: 12,
    },{
      property: 'cep',
      required: true,
    },{
      property: 'bairro',
      required: true,
    },{
      property: 'estado',
      required: true,
      /*options:['AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO','EX']*/
      optionsService: `${environment.urlListaEstados}`,
    },{
      property: 'cidade',
      required:true,
      optionsService: this.getUrlCidades(),
    }
  ]
}
