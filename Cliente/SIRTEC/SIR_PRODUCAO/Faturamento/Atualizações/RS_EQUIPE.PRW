#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APWEBSRV.CH'
#include 'TBICONN.ch'
#include 'topconn.ch'
#include 'rwmake.ch'

/*
Struct Utilizado no Web Service de Cadastro de Equipe
@Autor	Edinilson Bonato Pereira
@Data   04/04/2014
*/

WsStruct RS_EQUIPE

	WsData CODIGO As String
	WsData EQUIPE As String
	WsData TIPO As String
	WsData RESP As String

ENDWSSTRUCT



	