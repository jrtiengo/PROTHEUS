#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'APWEBSRV.CH'
#include 'TBICONN.ch'
#include 'topconn.ch'
#include 'rwmake.ch'
#include 'TOTVS.CH' 

WsService Ligacao DESCRIPTION "WebServices especÌfico integraÁ„o Protheus SmartPhone Ligacao" 

	/*/f/ 
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ 
	<Descricao> : Webservice para operaÁıes de Ligacao
	<Autor> : Edinilson Bonato Pereira
	<Data> : 01/04/2013
	<Parametros> : Nenhum
	<Retorno> : Nil 
	<Processo> : 
	<Rotina> : 	
	<Tipo> (Menu,Trigger,Validacao,Ponto de Entrada,Genericas,Especificas ) : W
	<Obs> :  
	‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹ 
	*/               
	// Usadas em GetFor

	WsData Codigo  	AS String //RequisiÁ„o
	WsData Equipe 	AS RS_EQUIPE //Equipe
	WsData Produto 	AS Array of RS_PRODUTO //Produto
	WsData Notas  	AS Array of RS_NOTAS

	WsMethod GetEquipe
	WsMethod GetProd
	WsMethod GetNotas
		
EndWsService


WsMethod GetEquipe WsReceive Codigo WsSend Equipe WsService Ligacao
	
Local cAlias := getNextAlias() 
Local _cCodigo:= ::CODIGO

::Equipe := WsClassNew("RS_EQUIPE") 	
	
BEGINSQL ALIAS cAlias
   SELECT ZZS_CODIGO, ZZS_EQUIPE, ZZS_TIPO, ZZS_RESP
     FROM %table:ZZS%
    WHERE 
		 ZZS_CODIGO = %exp:_cCodigo%
ENDSQL	

::Equipe:CODIGO	:= (cAlias)->ZZS_CODIGO
::Equipe:EQUIPE	:= (cAlias)->ZZS_EQUIPE
::Equipe:TIPO	:= (cAlias)->ZZS_TIPO
::Equipe:RESP	:= (cAlias)->ZZS_RESP
	

(cAlias)->(dbCloseArea())
	
Return .T.


WsMethod GetProd  WsReceive Codigo WsSend Produto WsService Ligacao

Local cAlias := getNextAlias() 
Local nX := 0
	 
BEGINSQL ALIAS cAlias
   SELECT B1_COD, B1_DESC, B1_CODSAP
     FROM %table:SB1%
    WHERE 
		 B1_PDA = 'S'
ENDSQL	

DO WHILE !(cAlias)->( EOF() )

   aAdd(::Produto,WSClassNew("RS_PRODUTO"))
 
   nX := len(::Produto)

	::Produto[nX]:CODIGO	:= (cAlias)->B1_COD
	::Produto[nX]:CODSAP	:= (cAlias)->B1_CODSAP
	::Produto[nX]:DESCRI	:= (cAlias)->B1_DESC

   (cAlias)->(dbSkip())
   
ENDDO	

(cAlias)->(dbCloseArea())
	
Return .T.


WsMethod GetNotas  WsReceive Codigo WsSend Notas WsService Ligacao

Local cAlias := getNextAlias()      
Local cUpdate :=''
 
Local nX := 0
Local _cCodigo := ::CODIGO         

Private lMsErroAuto := .F.
	 
BEGINSQL ALIAS cAlias

  /*	COLUMN ZZU_DATA as Date 
	COLUMN ZZU_DATPRG as Date  */
	
   	%noparser%
   SELECT 
   	  ZZU_CODIGO,  
   	  ZZU_TPARQ, 
   	  ZZU_TIPO,
      ZZU_CODIGO,
      ZZU_NOTA,
      ZZU_TEL,
      ZZU_SERVIC,
      ZZU_SUBCAT,
      ZZU_MEDIDA,
      ZZU_CLIENT,
      ZZU_END,
      ZZU_COMP,
      ZZU_BAIRRO,
      ZZU_MUN,
      ZZU_DATA,
      ZZU_HORDAT,
      ZZU_INSTAL,
      ZZU_CLASSE,
      ZZU_COORD,
      ZZU_CARGA,
      ZZU_FASE,
      ZZU_EQUIP,
      ZZU_MEDICA,
      ZZU_VENC,
      ZZU_HORVEN,
      ZZU_PRAZO,
      ZZU_STATUS,
      ZZU_LIBERA,
      ZZU_AREA,
      ZZU_ITEM,
      ZZU_DATPRG,
      ZZU_IDUSER,
      ZZU_USER,
      ZZU_TEL,
      ZZU_PROTIN,
      ZZU_PROTEN,
      ZZU_NEUTRO,
      ZZU_FILE,
      ISNULL(CONVERT(VARCHAR(2047), CONVERT(VARBINARY(2047), ZZU_OBS)),' ') AS ZZU_OBS,
      ZZU_SELO1,
      ZZU_SELO2,
      ZZU_SELO3,
      ZZU_DOCDB1,
      ZZU_VENC1,
      ZZU_VALDB1,
      ZZU_DOCDB2,
      ZZU_VENC2,
      ZZU_VALDB2,
      ZZU_DOCDB3,
      ZZU_VENC3,
      ZZU_VALDB3,
      ZZU_DOCDB4,
      ZZU_VENC4,
      ZZU_VALDB4,
      ZZU_OUTDEB,
      ZZU_TOTDEB,
      ZZU_PREFIX,
      ZZU_MEDID,
      ZZU_BAIRMU,
      ZZU_ENDCOB,
      ZZU_AGEND,
      ZZU_DATLIM,
      ZZU_HORLIM,
      ZZU_UNDCON,
      ZZU_CENTTR,
      ZZU_SUBCAT      
     FROM %table:ZZU%     
     WHERE  ZZU_EQUIP = %exp:_cCodigo%	
     AND ZZU_DATPRG= %exp:dDatabase%    
     AND ZZU_ENVPDA='N'		 	 
ENDSQL	

DO WHILE !(cAlias)->( EOF() )

   aAdd(::Notas,WSClassNew("RS_NOTAS")) 
   
   nX := Len(::Notas)             
   
	::Notas[nX]:TPARQ 	:= (cAlias)->ZZU_TPARQ
	::Notas[nX]:CODIGO 	:= (cAlias)->ZZU_CODIGO
	::Notas[nX]:NOTA 	:= (cAlias)->ZZU_NOTA  
	::Notas[nX]:TIPO 	:= (cAlias)->ZZU_TIPO
	::Notas[nX]:FONE 	:= (cAlias)->ZZU_TEL
	::Notas[nX]:TEL 	:= (cAlias)->ZZU_TEL
	::Notas[nX]:SERVICO := (cAlias)->ZZU_SERVIC
	::Notas[nX]:SUBCAT	:= (cAlias)->ZZU_SUBCAT
	::Notas[nX]:MEDIDA 	:= (cAlias)->ZZU_MEDIDA
	::Notas[nX]:CLIENT 	:= (cAlias)->ZZU_CLIENT
	::Notas[nX]:ENDER 	:= (cAlias)->ZZU_END
	::Notas[nX]:COMP 	:= (cAlias)->ZZU_COMP
	::Notas[nX]:BAIRRO 	:= (cAlias)->ZZU_BAIRRO
	::Notas[nX]:MUNIC 	:= (cAlias)->ZZU_MUN
	::Notas[nX]:DATAH 	:= (cAlias)->ZZU_DATA
	::Notas[nX]:HORDAT 	:= (cAlias)->ZZU_HORDAT
	::Notas[nX]:INSTAL 	:= (cAlias)->ZZU_INSTAL 
 	::Notas[nX]:CLASSE 	:= (cAlias)->ZZU_CLASSE 
  	::Notas[nX]:COORD 	:= (cAlias)->ZZU_COORD 
  	::Notas[nX]:CARGA 	:= (cAlias)->ZZU_CARGA 
  	::Notas[nX]:FASE 	:= (cAlias)->ZZU_FASE 
  	::Notas[nX]:EQUIP 	:= (cAlias)->ZZU_EQUIP 
  	::Notas[nX]:MEDICA 	:= (cAlias)->ZZU_MEDICA 
  	::Notas[nX]:VENC 	:= (cAlias)->ZZU_VENC 
  	::Notas[nX]:HORVEN 	:= (cAlias)->ZZU_HORVEN 
  	::Notas[nX]:PRAZO 	:= (cAlias)->ZZU_PRAZO 
  	::Notas[nX]:STATUS 	:= (cAlias)->ZZU_STATUS 
  	::Notas[nX]:LIBERA	:= (cAlias)->ZZU_LIBERA 
  	::Notas[nX]:AREA 	:= (cAlias)->ZZU_AREA
  	::Notas[nX]:ITEM 	:= (cAlias)->ZZU_ITEM
  	::Notas[nX]:DATPRG	:= (cAlias)->ZZU_DATPRG
  	::Notas[nX]:IDUSER 	:= (cAlias)->ZZU_IDUSER
  	::Notas[nX]:USERE 	:= (cAlias)->ZZU_USER
  	::Notas[nX]:PROTIN 	:= (cAlias)->ZZU_PROTIN
  	::Notas[nX]:PROTEN 	:= (cAlias)->ZZU_PROTEN
  	::Notas[nX]:NEUTRO 	:= (cAlias)->ZZU_NEUTRO
  	::Notas[nX]:FILEIO 	:= (cAlias)->ZZU_FILE
  	::Notas[nX]:OBS 	:= (cAlias)->ZZU_OBS
 	::Notas[nX]:SELO1 	:= (cAlias)->ZZU_SELO1
 	::Notas[nX]:SELO2 	:= (cAlias)->ZZU_SELO2
 	::Notas[nX]:SELO3 	:= (cAlias)->ZZU_SELO3
  	::Notas[nX]:DOCDB1 	:= (cAlias)->ZZU_DOCDB1
  	::Notas[nX]:VENC1 	:= (cAlias)->ZZU_VENC1
  	::Notas[nX]:VALDB1 	:= (cAlias)->ZZU_VALDB1
  	::Notas[nX]:DOCDB2 	:= (cAlias)->ZZU_DOCDB2
  	::Notas[nX]:VENC2 	:= (cAlias)->ZZU_VENC2
  	::Notas[nX]:VALDB2 	:= (cAlias)->ZZU_VALDB2
  	::Notas[nX]:DOCDB3 	:= (cAlias)->ZZU_DOCDB3
  	::Notas[nX]:VENC3 	:= (cAlias)->ZZU_VENC3
  	::Notas[nX]:VALDB3 	:= (cAlias)->ZZU_VALDB3
  	::Notas[nX]:DOCDB4 	:= (cAlias)->ZZU_DOCDB4
  	::Notas[nX]:VENC4 	:= (cAlias)->ZZU_VENC4
  	::Notas[nX]:VALDB4 	:= (cAlias)->ZZU_VALDB4
  	::Notas[nX]:OUTDEB 	:= (cAlias)->ZZU_OUTDEB
  	::Notas[nX]:TOTDEB 	:= (cAlias)->ZZU_TOTDEB
  	::Notas[nX]:PREFIX 	:= (cAlias)->ZZU_PREFIX
  	::Notas[nX]:MEDID 	:= (cAlias)->ZZU_MEDID
  	::Notas[nX]:BAIRMU 	:= (cAlias)->ZZU_BAIRMU
 	::Notas[nX]:ENDCOB 	:= (cAlias)->ZZU_ENDCOB
 	::Notas[nX]:AGEND 	:= (cAlias)->ZZU_AGEND
 	::Notas[nX]:DATLIM 	:= (cAlias)->ZZU_DATLIM
 	::Notas[nX]:HORLIM 	:= (cAlias)->ZZU_HORLIM
 	::Notas[nX]:UNDCON 	:= (cAlias)->ZZU_UNDCON
 	::Notas[nX]:CENTTR 	:= (cAlias)->ZZU_CENTTR
   
   (cAlias)->(dbSkip())
 
EndDo
   

_cUpdate := ""
_cUpdate += "UPDATE "+RetSQLName("ZZU")
_cUpdate += " SET ZZU_ENVPDA='S'"
_cUpdate += " WHERE  ZZU_EQUIP = '"+_cCodigo+"'"	
_cUpdate += " AND ZZU_DATPRG= '"+DtoC(dDatabase)+"'"
_cUpdate += " AND ZZU_ENVPDA='N' " 

tcSQLExec(_cUpdate)

(cAlias)->(dbCloseArea()) 

Return .T.