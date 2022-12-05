#Include "TOTVS.CH"
#include "TBICONN.ch"
#include "PROTHEUS.ch"
#Include "RESTFUL.CH"   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ POST     ºAutor  ³Sosys Business Insightº Data ³  NOV/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Metodo para incluir Empenhos em OP's   (Tabela     SD4)    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ OP_EMPENHO_INCLUIR                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±Para alterar: Filial+Cod+OP+TRT										   ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

WSRESTFUL OP_EMPENHO_INCLUIR DESCRIPTION "Alterar a quantidade dos Empenhos" 

	WSDATA EMPRESA  AS STRING	// Empresa. - 01
	WSDATA FILIAL   AS STRING	// Filial. - 01
	WSDATA D4_COD   AS STRING	// Código do Material. - nnnnnn
	WSDATA D4_LOCAL AS STRING	// Local do armazém. - nn
	WSDATA D4_OP 	AS STRING	// OP original do empenho. - nnnnnnnnnn
	WSDATA D4_TRT   AS STRING	// Sequência na estrutura. - nnn
	WSDATA D4_QUANT AS INTEGER	// Quantidade desejada para alterar o empenho. - nn.nn
	
WSMETHOD GET DESCRIPTION "Incluir empenhos de OP's." WSSYNTAX "/EMPRESA=01&FILIAL=01&D4_COD=000001&D4_LOCAL=01&D4_OP=00000101001&D4_TRT=001&D4_QUANT=1"
	
	END WSRESTFUL

WSMETHOD GET WSRECEIVE EMPRESA,FILIAL,D4_COD,D4_LOCAL,D4_OP,D4_TRT,D4_QUANT WSSERVICE OP_EMPENHO_INCLUIR


	Local aEmpen     := {}
	Local cErro		 := {}
	Local lOk		 := .T.
	Local cD4_COD	 := ""
	Local cD4_LOCAL  := ""
	Local cD4_OP	 := ""
	Local cD4_TRT	 := ""
	Local nD4_QUANT  := 0
	Local cEmpresa	 := ""
	Local cCFilial 	 := ""
	
    PRIVATE lMsErroAuto := .F.
    
    cEmpresa  := ::EMPRESA
    cCFilial  := ::FILIAL
    
    PREPARE ENVIRONMENT EMPRESA cEmpresa FILIAL cCFilial
    
    ::SetContentType("application/json") //Define o tipo de retorno do metodo

    cD4_COD   := ::D4_COD
	cD4_LOCAL := ::D4_LOCAL
	cD4_OP	  := ::D4_OP
	cD4_TRT	  := ::D4_TRT
	nD4_QUANT := ::D4_QUANT
	
	Conout("==================================================")
    Conout("== Parametros recebidos pelo WS_EMPENHO_INCLUIR ==")
    Conout("==================================================")
	ConOut ("Empresa.....: " + cEmpresa        )
	ConOut ("Filial......: " + cCFilial        )
	ConOut ("D4_COD......: " + cD4_COD         )
	ConOut ("D4_LOCAL....: " + cD4_LOCAL       )
	ConOut ("D4_OP.......: " + cD4_OP          )
	ConOut ("D4_TRT......: " + cD4_TRT         )
	ConOut ("D4_QUANT....: " + AllTrim(Str(nD4_QUANT)) )
	ConOut ("=================================================")
	
    IIF( Select('TDASD4')  !=0, TDASD4->(DbCLoseArea()  ), )
	DbSelectArea("SD4")
	SD4->(dbSetorder(1))
    cSQL := "SELECT D4_FILIAL,D4_COD,D4_LOCAL,D4_OP,D4_DATA,D4_TRT,D4_QTSEGUM,D4_QTDEORI,D4_QUANT FROM SD4" +cEmpresa+ "0 "
    cSQL += "WHERE D_E_L_E_T_ <> '*' AND D4_OP ='"+cD4_OP+"' AND D4_COD = '"+cD4_COD+"' AND D4_LOCAL = '"+cD4_LOCAL+"' "
    cSQL += "AND D4_TRT = '"+cD4_TRT+"' AND D4_FILIAL = '"+cCFilial+"'"
    cSQL := ChangeQuery(cSQL)
    dbUseArea( .F., "TOPCONN", TcGenQry(,,cSQL), "TDASD4", .T., .T. )
	
	Begin Transaction	 
		
		AADD(aEmpen,{"D4_COD"     , PadR(cD4_COD, TamSX3("D4_COD")[01]) ,Nil})
		AADD(aEmpen,{"D4_LOCAL"   , cD4_LOCAL   						,Nil})
		AADD(aEmpen,{"D4_OP"      , PadR(cD4_OP, TamSX3("D4_OP")[01])	,Nil})
		AADD(aEmpen,{"D4_DATA"    , date()    		  					,Nil})
		AADD(aEmpen,{"D4_QTDEORI" , nD4_QUANT	  	  					,Nil})
		AADD(aEmpen,{"D4_QUANT"	  , nD4_QUANT     	  					,Nil})
		AADD(aEmpen,{"D4_TRT"     , cD4_TRT	  							,Nil})
		AADD(aEmpen,{"D4_QTSEGUM" , 0 									,Nil})//D4_OPERAC
		MSExecAuto({|x,y,z| mata380(x,y,z)},aEmpen,3)	
		 
	End Transaction
    
    If lMsErroAuto
    	cErro := Mostraerro("sosystools","Error WS_OP_EMPENHO+INCLUIR.txt")
		ConOut(cErro)	
		::SetResponse( '{' )
		::SetResponse( '"errorCode": "1",' )
		::SetResponse( '"errorMessage": ' + "Erro ao incluir empenho: " + cD4_OP )	
		::SetResponse( cErro )
		::SetResponse('}')
		ConOut ( "=========================================================================" )
		ConOut ( "========             FIM OP_EMPENHO_INCLUIR                      ========" )
		ConOut ( "========                 " + DTOS(DATE()) + "                              ========" )
		ConOut ( "========                  " + TIME() + "                               ========" )
		ConOut ( "=========================================================================" )
		DisarmTran()
		TDASD4->(dbCloseArea())
		lOk := .T.		
	Else
		TDASD4->(dbCloseArea())
		::SetResponse('{')
		::SetResponse('"errorCode": "0",' )
		::SetResponse('"errorMessage": ' + CHR(34) + "Empenho incluido com sucesso: " + CHR(34))	
		::SetResponse('"id_protheus": ' + CHR(34) + cD4_OP + CHR(34) )
		::SetResponse('}')
		ConOut ( "=========================================================================" )
		ConOut ( "========             FIM OP_EMPENHO_INCLUIR                      ========" )
		ConOut ( "========                 " + DTOS(DATE()) + "                              ========" )
		ConOut ( "========                  " + TIME() + "                               ========" )
		ConOut ( "=========================================================================" )
	EndIf
	RESET ENVIRONMENT
Return ( lOk )