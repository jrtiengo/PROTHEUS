import { HttpClient } from "@angular/common/http";
import { Observable, pipe, tap } from "rxjs";
import { environment } from "../environment/environment";
import { Injectable } from "@angular/core";

@Injectable({
    providedIn: 'root'
})
export class CustomerService {
    constructor(private http: HttpClient) { }

    getListaEstados(): Observable<any> {
        return this.http.get<any>(environment.urlListaEstados)
    }

    getListaCidades(estado: string): Observable<any> {
        let url = `${environment.urlListaCidades}/${estado}`;
        return this.http.get<any>(url)
    }

    getDataCustomer(codigo: string, loja: string): Observable<any> {
        let url = `${environment.urlDetalheCliente}?codigo=${codigo}&loja=${loja}`;
        return this.http.get<any>(url)
    }

    postDataCustomer(formCustomer: any): Observable<any> {
        let url = `${environment.urlDetalheCliente}`;
        return this.http.post<any>(url, formCustomer)
    }

    putDataCustomer(formCustomer: any): Observable<any> {
        let url = `${environment.urlDetalheCliente}`;
        return this.http.put<any>(url, formCustomer)
    }

    delCustomer(codigo: string, loja: string): Observable<any> {
        let url = `${environment.urlDeleteCliente}?codigo=${codigo}&&loja=${loja}`;
        return this.http.delete<any>(url);
    }
}