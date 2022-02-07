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

WsStruct RS_EXEXPROD
    WsData NOTA As String
    WsData DATA As String
	WsData CODSAP As String
	WsData DESCRI As String 
	WsData QUANT As String

ENDWSSTRUCT

WsStruct LISTAPROD
     WsData ITENSPROD   As Array Of RS_EXEXPROD
EndWsStruct