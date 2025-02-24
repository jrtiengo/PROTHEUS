import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Router } from '@angular/router';
import { PoDialogService } from '@po-ui/ng-components';
import { Observable, tap } from 'rxjs';
import { environment } from '../environment/environment';

@Injectable({
  providedIn: 'root'
})
export class LoginService {

  constructor(private router: Router, private httpClient: HttpClient, private poDialog: PoDialogService) { }

  logar(username: string, password: string): Observable<any> {

    let urlAPI: string = environment.urlAuth;
    let urlAuth: string = `${urlAPI}&password=${password}&username=${username}`

    return this.httpClient
    .post<any>(urlAuth, null, { headers: { "Content-Type": "application/json;charset=utf-8" }})
    .pipe(tap(resp => {
      if (resp.access_token) {
               
        let dataLogin     = Date.now();
        let dataLoginStr  = new Date(dataLogin).toLocaleString();
        let dataExpire    = dataLogin + (resp.expires_in * 1000);
        let dataExpireStr = new Date(dataExpire).toLocaleString();

        localStorage.setItem('access_token' , resp.access_token);
        localStorage.setItem('refresh_token', resp.refresh_token);
        localStorage.setItem('dataLogin'    , dataLogin.toString());
        localStorage.setItem('dataLoginStr' , dataLoginStr);
        localStorage.setItem('dataExpire'   , dataExpire.toString());
        localStorage.setItem('dataExpireStr', dataExpireStr);

      }else{
        localStorage.clear();
      }
    }
  ))
  }

  refresh(refresh_token: string | null): Observable<any> {

    let urlAPI: string = environment.urlRefreshToken;
    let urlRef: string = `${urlAPI}=${refresh_token}`;

    return this.httpClient
    .post<any>(urlRef, null, { headers: { "Content-Type": "application/json;charset=utf-8" }})
    .pipe(tap(resp => {
      if (resp.access_token) {
               
        let dataLogin     = Date.now();
        let dataLoginStr  = new Date(dataLogin).toLocaleString();
        let dataExpire    = dataLogin + (resp.expires_in * 1000);
        let dataExpireStr = new Date(dataExpire).toLocaleString();

        localStorage.setItem('access_token' , resp.access_token);
        localStorage.setItem('refresh_token', resp.refresh_token);
        localStorage.setItem('dataLogin'    , dataLogin.toString());
        localStorage.setItem('dataLoginStr' , dataLoginStr);
        localStorage.setItem('dataExpire'   , dataExpire.toString());
        localStorage.setItem('dataExpireStr', dataExpireStr);

      }else{
        localStorage.clear();
      }
    }))    
  }
}
