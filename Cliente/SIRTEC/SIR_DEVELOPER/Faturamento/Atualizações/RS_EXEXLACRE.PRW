#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APWEBSRV.CH'
#include 'rwmake.ch'

/*
Struct Utilizado no Web Service de Cadastro de Produto
@Autor	Edinilson Bonato Pereira
@Data   04/04/2014
*/

WsStruct RS_EXEXLACRE
    WsData NOTA As String
    WsData DATA As String
	WsData LACRE As String

ENDWSSTRUCT

// DESSA FORMA VC ENCAPSULA A ESTRUTURA ARRAY EM UMA ESTRUTURA SIMPLES

WsStruct LISTALACRE
     WsData ITENSLACRE   As Array Of RS_EXEXLACRE
EndWsStruct