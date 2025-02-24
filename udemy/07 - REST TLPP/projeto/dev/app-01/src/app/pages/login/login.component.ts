import { Component } from '@angular/core';
import { Router } from '@angular/router';
import { PoDialogService } from '@po-ui/ng-components';
import { PoPageLogin } from '@po-ui/ng-templates';
import { LoginService } from 'src/app/services/login.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.css']
})

export class LoginComponent {

  constructor(private loginService: LoginService, private poDialog: PoDialogService, private router: Router){}

  ngOnInit(): void {}

  async onSubmit(formData: PoPageLogin){

    const username = formData.login;
    const password = formData.password;

    this.loginService.logar(username,password).subscribe({
      next: (token) => {this.router.navigate([''])},
      error: (erro) => this.poDialog.alert({title: 'Erro de Login', message: 'Dados inválidos!'})
    });
  }
}
