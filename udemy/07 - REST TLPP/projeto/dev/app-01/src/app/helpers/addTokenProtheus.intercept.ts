import { HttpEvent, HttpHandler, HttpInterceptor, HttpRequest } from "@angular/common/http";
import { Injectable } from "@angular/core";
import { Observable } from "rxjs";
import { environment } from "../environment/environment";
import { LoginService } from "../services/login.service";

@Injectable()

export class AddTokenProtheus implements HttpInterceptor {

  constructor(private loginService: LoginService) { }

  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {

    let refresh_token = localStorage.getItem('refresh_token');
    let dataExpire    = Number(localStorage.getItem('dataExpire'));
    let dataAtual     = Date.now();

    if (req.url.startsWith(environment.urlAPI) && !(req.url.startsWith(environment.urlAuth) || req.url.startsWith(environment.urlRefreshToken))) {
      dataAtual > dataExpire 
      ? this.loginService.refresh(refresh_token).subscribe({})
      : null
    }    

    let token = localStorage.getItem('access_token');

    if (req.url.startsWith(environment.urlAPI) && !(req.url.startsWith(environment.urlAuth) || req.url.startsWith(environment.urlRefreshToken))) {
      req = req.clone({ setHeaders: { Authorization: `Bearer ${token}` } });
    }

    return next.handle(req);
  }
}