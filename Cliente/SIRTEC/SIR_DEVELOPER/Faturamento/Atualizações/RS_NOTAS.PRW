#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APWEBSRV.CH'
#include 'TBICONN.ch'
#include 'topconn.ch'
#include 'rwmake.ch'

/*
Struct Utilizado no Web Service de Cadastro de Notas
@Autor	Edinilson Bonato Pereira
@Data   04/04/2014
*/

WsStruct RS_NOTAS
    WsData TPARQ As String
	WsData CODIGO As String
	WsData NOTA As String  
	WsData TIPO As String
	WsData FONE As String
	WsData SERVICO As String
	WsData SUBCAT	As String
	WsData MEDIDA As String
	WsData CLIENT As String 
	WsData ENDER As String
	WsData COMP As String
	WsData BAIRRO As String
	WSData MUNIC As String
	WsData DATAH As String
	WsData HORDAT As String 
   WsData INSTAL As String 
   WsData CLASSE As String 
   WsData COORD As String 
   WsData CARGA As String 
   WsData FASE As String 
   WsData EQUIP As String 
   WsData MEDICA As String 
   WsData VENC As String 
   WsData HORVEN As String 
   WsData PRAZO As String 
   WsData STATUS As String 
   WsData LIBERA	As String 
   WsData AREA 	As String
   WsData ITEM 	As String
   WsData DATPRG 	As String
   WsData IDUSER 	As String
   WsData USERE 	As String
   WsData TEL 	As String
   WsData PROTIN 	As String
   WsData PROTEN 	As String
   WsData NEUTRO 	As String
   WsData FILEIO 	As String
   WsData OBS 	As String
   WsData SELO1 	As String
   WsData SELO2 	As String
   WsData SELO3 	As String
   WsData DOCDB1 	As String
   WsData VENC1 	As String
   WsData VALDB1 	As Float
   WsData DOCDB2 	As String
   WsData VENC2 	As String
   WsData VALDB2 	As Float
   WsData DOCDB3 	As String
   WsData VENC3 	As String
   WsData VALDB3 	As Float
   WsData DOCDB4 	As String
   WsData VENC4 	As String
   WsData VALDB4 	As Float
   WsData OUTDEB 	As Float
   WsData TOTDEB 	As Float
   WsData PREFIX 	As String
   WsData MEDID 	As String
   WsData BAIRMU 	As String
   WsData ENDCOB 	As String
   WsData AGEND 	As String
   WsData DATLIM 	As String
   WsData HORLIM 	As String
   WsData UNDCON 	As String
   WsData CENTTR 	As String

ENDWSSTRUCT