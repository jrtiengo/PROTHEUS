import { Router, UrlTree } from '@angular/router';
import { LoginService } from '../services/login.service';
import { Observable } from 'rxjs';
import { Injectable } from '@angular/core';

@Injectable()
export class AuthGuard {
  constructor(private router: Router, private loginService: LoginService) { }

  canActivate(): boolean | UrlTree | Observable<boolean | UrlTree> | Promise<boolean | UrlTree> {

    let access_token  = localStorage.getItem('access_token');
    let refresh_token = localStorage.getItem('refresh_token');
    
    let dataExpire    = Number(localStorage.getItem('dataExpire'));
    let dataAtual     = Date.now();

    if (!access_token) {
      this.router.navigate(['login']);
      return false;
    }

    dataAtual > dataExpire 
    ? this.loginService.refresh(refresh_token).subscribe({})
    : null

    access_token = localStorage.getItem('access_token');

    if (!access_token) {
      this.router.navigate(['login']);
      return false;
    }

    return true;
  }
}
