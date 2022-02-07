#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APWEBSRV.CH'
#include 'TBICONN.ch'
#include 'topconn.ch'
#include 'rwmake.ch'

/*
Struct Utilizado no Web Service de Cadastro de Produto
@Autor	Edinilson Bonato Pereira
@Data   04/04/2014
*/

WsStruct RS_EXECUCAO

	WsData NOTA AS String
	WsData DATA As String OPTIONAL
	WsData CORTE As String OPTIONAL
	WsData HORA As String OPTIONAL
	WsData TIPO As String  OPTIONAL
	WsData MEDIDORINSTALADO As String OPTIONAL
	WsData LEITURAMEDIDOR As String OPTIONAL
	WsData MEDIDORRETIRADO As String OPTIONAL
	WsData LEITURARETIRADO As String OPTIONAL
	WsData MEDIDORLOCAL As String OPTIONAL
	WsData LEITURALOCAL As String OPTIONAL
	WsData MEDIDORVIZINHO1 As String OPTIONAL
	WsData MEDIDORVIZINHO2 As String OPTIONAL
	WsData TIPOARQ As String OPTIONAL
	WsData TRAFORETIRADO As String OPTIONAL
	WsData LACRE As String OPTIONAL
	WsData OBSERVACAO As String OPTIONAL
	WsData SITUACAO As String OPTIONAL
	WsData DEFEITO As String OPTIONAL

EndWsStruct