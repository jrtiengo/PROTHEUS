#Include "Protheus.ch"
#include "rwmake.ch"
#include "TbiConn.ch"
#Include "RESTFUL.CH"  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ POST     ºAutor  ³Sosys Business Insightº Data ³  NOV/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Metodo para incluir Orderm de Produção (Tabela SC2)        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Automatech - OP_CRIAR                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
 
WSRESTFUL OP_CRIAR DESCRIPTION "Criação de OP's."

	WSDATA EMPRESA    AS STRING  //Empresa - 01
	WSDATA FILIAL     AS STRING  //Filial - 01
	WSDATA PRODUTO    AS STRING  //Produto - 01234567890123456
	WSDATA ITEM       AS STRING  //Primeiro item da OP - 01
	WSDATA SEQUEN     AS STRING  //Numeração  sequencial  de  movimentos de estoque - 001
	WSDATA DATPRI     AS STRING  //Data prevista de início da OP. - DDMMAAAA
	WSDATA DATPRF     AS STRING  //Data prevista para terminar OP. - DDMMAAAA
	WSDATA PRIOR      AS STRING  //Prioridade - Padrão = 500, quanto menor, maior a prioridade da OP. - 500
	WSDATA EMISSAO    AS STRING  //Data de criação da OP. - DDMMAAAA
	WSDATA LOCAL      AS STRING  //Armazém que será estocado o produto criado. - 01
	WSDATA AUTEXPLODE AS STRING  //Para que o sistema acate a inclusão de empenho da rotina MATA650 - S
	WSDATA QUANT      AS INTEGER //Quantidade a gerar do produto indicado. - 999.99
	WSDATA BATCH	  AS STRING  //Parametro para campo C2_BATCH, para permitir apontar sem empenho - referente #6550 - 16
	
	WSMETHOD GET DESCRIPTION "Envio de dados para criação de OP."  WSSYNTAX "/EMPRESA=01&FILIAL=01&PRODUTO=02011132640000001&ITEM=01&SEQUEN=001&DATPRI=12/03/2020&DATPRF=13/03/2020&PRIOR=500&EMISSAO=12/03/2020&LOCAL=01&QUANT=50.96&AUTEXPLODE=N

	END WSRESTFUL

WSMETHOD GET WSRECEIVE EMPRESA,FILIAL,PRODUTO,ITEM,SEQUEN,DATPRI,DATPRF,PRIOR,EMISSAO,LOCAL,QUANT,AUTEXPLODE,BATCH WSSERVICE OP_CRIAR

	Local lOk		  := .T.
	Local aMata650	  := {}
	Local cErro		  := {}
	Local cSQL        := ""
	Local cEmpresa    := ""
	Local cCFilial    := ""
	Local cProduto    := ""
	Local cNum		  := ""
	Local cItem       := ""
	Local cSequen     := ""
	Local xDatPri     := ""
	Local xDatPrf     := ""
	Local cPrior      := ""
	Local xEmissao    := ""
	Local cLocal      := ""
	Local nQuant      := 0
	Local cAutExplode := ""   
			
	Private lMsErroAuto := .F.
	
	cEmpresa  := ::EMPRESA
	cCFilial  := ::FILIAL
	
	PREPARE ENVIRONMENT EMPRESA cEmpresa FILIAL cCFilial
	
	::SetContentType("application/json") //Define o tipo de retorno do metodo

	cProduto  	:= ::PRODUTO
	cItem     	:= ::ITEM
	cSequen   	:= ::SEQUEN
	cPrior    	:= ::PRIOR
	cLocal    	:= ::LOCAL
	nQuant    	:= ::QUANT
	cAutExplode := ::AUTEXPLODE
	xDatPri   	:= CTOD(::DATPRI)
	xDatPrf   	:= CTOD(::DATPRF)
	xEmissao  	:= CTOD(::EMISSAO)
	Conout ("==================================================")
    Conout ("==     Parametros recebidos pelo WS_CRIAR       ==")
    Conout ("==================================================")
	ConOut ("Empresa.....: " + cEmpresa     		)
	ConOut ("Filial......: " + cCFilial     		)
	ConOut ("PRODUTO.....: " + cProduto    			)
	ConOut ("ITEM........: " + cItem        		)
	ConOut ("SEQUEN......: " + cSequen      		)
	ConOut ("PRIOR.......: " + cPrior       		)
	ConOut ("LOCAL.......: " + cLocal       		)
	ConOut ("QUANT.......: " + cValToChar(nQuant)   )
	ConOut ("AUTEXPLODE..: " + cAutExplode  		)
	ConOut ("DATPRI......: " + cValToChar(xDatPri)  )  
	ConOut ("DATPRF......: " + cValToChar(xDatPrf)  )
	ConOut ("EMISSAO.....: " + cValToChar(xEmissao) )  
	ConOut ("=================================================")
	
	Begin Transaction
		//Recebe o próximo Num de OP.
		// ---------------------------------------------------------------------------------
		IIF( Select('TMPSC2')  !=0, TMPSC2->(DbCLoseArea()  ), )
		DbSelectArea("SC2")
		SC2->(dbSetorder(1))
		cSQL := "SELECT Max(C2_NUM) AS NUMERO FROM SC2" +cEmpresa+ "0 WHERE D_E_L_E_T_ <> '*' AND C2_FILIAL = '" +cCFilial+"'"
		cSQL := ChangeQuery(cSQL)
		dbUseArea( .F., "TOPCONN", TcGenQry(,,cSQL), "TMPSC2", .T., .T. )
	
		cNum := Strzero((INT(VAL(NUMERO)) + 1), TamSX3("C2_NUM")[01])

		aMata650 := {{'C2_FILIAL'   ,cCFilial							        ,NIL},;
				     {'C2_PRODUTO'  ,PadR( cProduto, TamSX3("C2_PRODUTO")[01] ) ,NIL},;          
				     {'C2_NUM'      ,cNum              					    	,NIL},;          
				     {'C2_ITEM'     ,cItem               					    ,NIL},;          
				     {'C2_SEQUEN'   ,cSequen             					    ,NIL},;
				     {'C2_DATPRI'   ,xDatPri 								    ,NIL},;
				     {'C2_DATPRF'   ,xDatPrf			   				 	    ,NIL},;
				     {'C2_PRIOR'    ,cPrior			                            ,Nil},;
				     {'C2_EMISSAO'  ,xEmissao			                        ,Nil},;
				     {'C2_LOCAL'    ,cLocal   	                            	,Nil},;
				     {'C2_QUANT'    ,nQuant            						    ,Nil},;
				     {'AUTEXPLODE'  ,cAutExplode							    ,Nil}}
				     msExecAuto({|x,Y| Mata650(x,Y)},aMata650,3)

    End Transaction
    
    If lMsErroAuto
    	cErro := Mostraerro("sosystools","Error WS_OP_APONTAR.txt")
		ConOut(cErro)	
		::SetResponse( '{' )
		::SetResponse( '"errorCode": "1",' )
		::SetResponse( '"errorMessage": ' + "Erro ao criar empenho: " + cNum+cItem+cSequen )	
		::SetResponse( cErro)
		::SetResponse('}')
		ConOut ( "=========================================================================" )
		ConOut ( "========                  FIM OP_CRIAR                           ========" )
		ConOut ( "========                 " + DTOS(DATE()) + "                              ========" )
		ConOut ( "========                  " + TIME() + "                               ========" )
		ConOut ( "=========================================================================" )
		DisarmTran()
		TMPSD4->(dbCloseArea())
		lOk := .T.			
	Else
		TMPSC2->(dbCloseArea())
		::SetResponse('{')
		::SetResponse('"errorCode": "0",' )
		::SetResponse('"errorMessage": ' + CHR(34) + "Ordem de Producao incluida com sucesso." + CHR(34) + "," )
		::SetResponse('"id_protheus": ' + CHR(34) + cNum + cItem + cSequen + CHR(34) )	
		::SetResponse('}')
		ConOut ( "id_protheus:" + cNum + cItem + cSequen)
		ConOut ( "=========================================================================" )
		ConOut ( "========                  FIM OP_CRIAR                           ========" )
		ConOut ( "========                 " + DTOS(DATE()) + "                              ========" )
		ConOut ( "========                  " + TIME() + "                               ========" )
		ConOut ( "=========================================================================" )							
	EndIf
	RESET ENVIRONMENT
Return ( lOk )