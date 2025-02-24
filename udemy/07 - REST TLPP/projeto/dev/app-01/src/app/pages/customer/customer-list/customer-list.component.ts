import { Component ,OnInit, ViewChild} from '@angular/core';
import { Router } from '@angular/router';
import { PoModalAction, PoModalComponent, PoNotificationService } from '@po-ui/ng-components';
import { PoPageDynamicDetailField, PoPageDynamicTableComponent, PoPageDynamicTableCustomAction, PoPageDynamicTableCustomTableAction, PoPageDynamicTableField } from '@po-ui/ng-templates';
import { environment } from 'src/app/environment/environment';

@Component({
  selector: 'app-clientes',
  templateUrl: './customer-list.component.html',
  styleUrls: ['./customer-list.component.css']
})
export class CustomerListComponent implements OnInit{

  constructor(private PoNotify: PoNotificationService, private router: Router) {}

  ngOnInit():  void {}

  @ViewChild('page_customerlist') page_customerlist!: PoPageDynamicTableComponent;
//@ViewChild('modal_cliente') modal_cliente!: PoModalComponent;
//@ViewChild('modal_cliente_visual') modal_cliente_visual!: PoModalComponent;

  hideLoading: boolean = true;
  textLoading: string = "Carregando...";

  readonly apiService: string = `${environment.urlListaClientes}`

  actionsTable: Array<PoPageDynamicTableCustomAction> = [
    {label: 'Visualizar', action: this.formView.bind(this)  , visible: true, icon:'po-icon po-icon-eye'},
    {label: 'Alterar'   , action: this.formEdit.bind(this)  , visible: true, icon:'po-icon po-icon-edit'},
    {label: 'Excluir'   , action: this.formDel.bind(this)   , visible: true, icon:'po-icon po-icon-delete'},
  ]

  actionsPage: Array<PoPageDynamicTableCustomAction> = [
    {label: 'Incluir'   , action: this.formAdd.bind(this)   , visible: true, icon:'po-icon po-icon-plus'},
  ]

  formView(customAction: any) {
    this.router.navigate([`customer-detail/${customAction.codigo}/${customAction.loja}`])
  }
  formAdd() {
    this.router.navigate(['customer-new'])
  }
  formEdit(customAction: any) {
    this.router.navigate([`customer-edit/${customAction.codigo}/${customAction.loja}`])
  }
  formDel(customAction: any) {
    this.router.navigate([`customer-del/${customAction.codigo}/${customAction.loja}`])
  }

  readonly fields: Array<PoPageDynamicTableField> = [
    {property: 'codigo'   ,label: 'Codigo'  ,key: true},
    {property: 'loja'     ,label: 'Loja'    ,key: true},
    {property: 'nome'     ,label: 'Nome'              },
    {property: 'tipo'     ,label: 'Tipo'              },
    {property: 'endereco' ,label: 'Endereço'          },  
    {property: 'bairro'   ,label: 'Bairro'            },
    {property: 'cidade'   ,label: 'Cidade'            },
    {property: 'estado'   ,label: 'UF'                },
    {property: 'cep'      ,label: 'Cep'               },      
  ]

  /*/
  readonly fieldsCliente: Array<PoPageDynamicDetailField> = [
    {property: 'codigo'   ,label: 'Codigo'  ,key: true},
    {property: 'loja'     ,label: 'Loja'    ,key: true},
    {property: 'nome'     ,label: 'Nome'              },
    {property: 'tipo'     ,label: 'Tipo'              },
    {property: 'endereco' ,label: 'Endereço'          },  
    {property: 'bairro'   ,label: 'Bairro'            },
    {property: 'cidade'   ,label: 'Cidade'            },
    {property: 'estado'   ,label: 'UF'                },
    {property: 'cep'      ,label: 'Cep'               },      
  ]
  /*/

}
