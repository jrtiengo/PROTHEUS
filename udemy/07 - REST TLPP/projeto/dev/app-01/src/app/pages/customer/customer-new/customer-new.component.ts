import { Component, OnInit, ViewChild } from '@angular/core';
import { Form } from '@angular/forms';
import { ActivatedRoute, Router } from '@angular/router';
import { PoBreadcrumb, PoCheckboxGroupOption, PoDialogService, PoDynamicFormComponent, PoDynamicFormField, PoDynamicFormFieldChanged, PoDynamicFormFieldValidation, PoDynamicFormValidation, PoInputComponent, PoNotificationService, PoSelectComponent, PoSelectOption } from '@po-ui/ng-components';
import { pipe, tap } from 'rxjs';
import { Customer } from 'src/app/interfaces/customer';
import { CustomerService } from 'src/app/services/customerService';

@Component({
  selector: 'app-customer-new',
  templateUrl: './customer-new.component.html',
  styleUrls: ['./customer-new.component.css']
})
export class CustomerNewComponent implements OnInit {

  constructor(private activatedRoute: ActivatedRoute,
    private router: Router,
    private customerService: CustomerService,
    private poNotify: PoNotificationService,
    private poDialog: PoDialogService) { }

  cidade: number = 0;
  estados: Array<PoSelectOption> = new Array()
  customerData: any;
  validateFields: Array<string> = ['nome', 'pessoa', 'endereco', 'cep', 'bairro', 'estado', 'cidade'];

  @ViewChild('nome') nome!: PoInputComponent;
  @ViewChild('selectPessoa') selectPessoa !: PoSelectComponent;
  @ViewChild('endereco') endereco !: PoInputComponent;
  @ViewChild('cep') cep !: PoInputComponent;
  @ViewChild('bairro') bairro !: PoInputComponent;
  @ViewChild('selectEstado') selectEstado !: PoSelectComponent;
  @ViewChild('selectCidade') selectCidade !: PoSelectComponent;

  ngOnInit(){
    this.listaEstados()
  }

  editTitle: string = `Incluir Cliente`
  tipoPessoaOptions: Array<PoSelectOption> = [
    { value: 'F', label: 'Fisica' },
    { value: 'J', label: 'Juridica' }
  ]

  breadcrumb: PoBreadcrumb = {
    items: [
      { label: 'Home', link: '/' },
      { label: 'Clientes', link: '/customer-list' },
      { label: 'Incluir' }
    ]
  }

  cidadeOptions: Array<PoSelectOption> = []

  onChangeEstado() {
    console.info('[INFO]', this.nome);
    this.listarCidades(this.selectEstado.selectedValue);
  }

  listaEstados() {
    this.customerService
      .getListaEstados()
      .subscribe((resp) => {
        this.estados = resp.items
      });
  }

  listarCidades(estado: string) {
    this.customerService
      .getListaCidades(estado)
      .subscribe(
        {
          next: (resp) => {
            let optionCidades: Array<PoSelectOption> = new Array()
            resp.items.forEach((cidade: any) => {
              optionCidades.push({ value: cidade.cidade, label: cidade.cidade })
            });
            this.cidadeOptions = optionCidades;
            this.selectCidade.selectedValue = optionCidades[0].value;
            this.selectCidade.displayValue = optionCidades[0].value;
          },
          error: (err) => {}
        }
      )
  }

  customerSave() {

    this.poNotify.setDefaultDuration(2000)

    let customer: Customer = {
      nome: this.nome.modelLastUpdate,
      pessoa: this.selectPessoa.selectedValue,
      endereco: this.endereco.modelLastUpdate,
      cep: this.cep.modelLastUpdate,
      bairro: this.bairro.modelLastUpdate,
      estado: this.selectEstado.selectedValue,
      cidade: this.selectCidade.selectedValue,
      status: false,
    }

    this.customerService.postDataCustomer(customer).subscribe(
      {
        next: resp => this.poDialog.alert({
          title: 'Cliente cadastrado',
          message: `Codigo: ${resp.codigo}, Loja: ${resp.loja}, Nome: ${resp.nome}`
        }),
          complete: () => this.router.navigate(['customer-list'])
      }
    )

  }

  customerCancel() {
    this.router.navigate(['/customer-list'])
  }

  validForm(): boolean {
    return true;
  }

}
