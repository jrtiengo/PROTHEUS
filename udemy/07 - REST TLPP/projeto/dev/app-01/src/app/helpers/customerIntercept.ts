import { HttpEvent, HttpHandler, HttpInterceptor, HttpRequest } from "@angular/common/http";
import { Observable } from "rxjs";
import { environment } from "../environment/environment";

export class CustomIntercept implements HttpInterceptor {
  constructor() {}

  intercept(req: HttpRequest<any>, next: HttpHandler): Observable<HttpEvent<any>> {

    let codcliente = localStorage.getItem('codcliente');
    let lojcliente = localStorage.getItem('lojcliente');

    if(codcliente && lojcliente && req.url.startsWith(environment.urlListaCidades)) {
        req = req.clone({setHeaders : {codcliente: codcliente, lojcliente: lojcliente}})
        localStorage.removeItem('codcliente');
        localStorage.removeItem('lojcliente');
    }

    return next.handle(req);

  }
}