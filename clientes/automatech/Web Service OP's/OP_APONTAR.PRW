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
±±ºDesc.     ³ Metodo para apontar Orderm de Produção (Tabela SC2)        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Automatech - OP_APONTAR                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

WSRESTFUL OP_APONTAR DESCRIPTION "Apontamento de OP's."

	WSDATA EMPRESA    AS STRING  // Empresa. - 01
	WSDATA FILIAL     AS STRING  // Filial. - 01
	WSDATA D3_TM      AS STRING  // Tipo de movimento. 101 - Produção Atu. Emp. / 200 - Devolução manual / 600 - Requisição manual
	WSDATA D3_OP      AS STRING  // Código da OP + ítem + Sequência. - 000001 01 001
	WSDATA D3_LOCAL   AS STRING  // Código  do Armazem onde será movimentado o produto. - TM, 01, ...
	WSDATA D3_CC      AS STRING  // Centro de Custo - 0003 - Logística.
	WSDATA D3_PARCTOT AS STRING  // Apontamento P - Parcial T - Total.
	WSDATA D3_LOTECTL AS STRING  // Numeração do Lote utilizado no produto. - 123AB456
	WSDATA D3_DTVALID AS STRING  // Data de validade do lote. 01/01/2020
	WSDATA ATUEMP	  AS STRING  // Para que o sistema faça a baixa dos empenhos na chamada via ExecAuto. - "T" - " "
	WSDATA D3_QUANT   AS INTEGER // Quantidade do produto final produzido. - 10
	WSDATA D3_PERDA   AS INTEGER // Quantidade de perda de produção. - 1
	WSDATA D3_QTGANHO AS INTEGER // Ganho de produção usado quando a quantidade real produzida é maior que a quantidade prevista na OP, utilizando as mesmas quantidades de matéria-prima empenhadas/requisitadas na abertura da OP.
	WSDATA D3_QTMAIOR AS INTEGER // Caso exista quantidade de produção a maior , a requisição dos componentes será proporcionalizada para que considere a quantidade produzida a maior e assim requisite a diferença automaticamente.  ( [qtde produz a maior] / C2_QUANT) * D4_QTDEORI.) Ex: https://tdn.totvs.com/pages/releaseview.action?pageId=286729685

	WSMETHOD GET DESCRIPTION "Apontamentos de OP's"  WSSYNTAX "/EMPRESA=01&FILIAL=02&D3_TM=101&D3_OP=00000201002&D3_LOCAL=01&D3_CC=0003&D3_PARCTOT=T&D3_LOTECTL=&D3_DTVALID=&ATUEMP=T&D3_QUANT=1&D3_PERDA=&D3_QTGANHO=&D3_QTMAIOR=

	END WSRESTFUL

WSMETHOD GET WSRECEIVE EMPRESA,FILIAL,D3_TM,D3_OP,D3_LOCAL,D3_CC,D3_PARCTOT,D3_LOTECTL,D3_DTVALID,ATUEMP,D3_QUANT,D3_PERDA,D3_QTGANHO,D3_QTMAIOR WSSERVICE OP_APONTAR

	Local lOk		  := .T.
	Local aMata250	  := {}
	Local cErro		  := {}
	Local nD3_QUANT   := 0
	Local nD3_QTGANHO := 0 // Quando produzido a mais sem alterar empenhos.
	Local nD3_QTMAIOR := 0 // Quando produzido a mais alterando os empenhos.
	Local nD3_PERDA   := 0
	Local cEmpresa	  := ""
	Local cCFilial	  := ""
	Local cD3_TM      := ""
	Local cD3_OP      := ""
	Local cD3_LOCAL   := ""
	Local cD3_CC      := ""
	Local cD3_PARCTOT := ""
	Local cD3_LOTECTL := ""
	Local xD3_DTVALID := ""
	Local cATUEMP	  := ""
			
	Private lMsErroAuto := .F.

	::SetContentType("application/json") //Define o tipo de retorno do metodo
	
	cEmpresa  := ::EMPRESA
	cCFilial  := ::FILIAL
	
	PREPARE ENVIRONMENT EMPRESA cEmpresa FILIAL cCFilial
	
	cD3_TM      := ::D3_TM
	nD3_QUANT   := ::D3_QUANT
	cD3_OP      := ::D3_OP
	cD3_LOCAL   := ::D3_LOCAL
	cD3_CC      := ::D3_CC
	cD3_PARCTOT := ::D3_PARCTOT
	cD3_LOTECTL := ::D3_LOTECTL
	nD3_PERDA   := ::D3_PERDA
	nD3_QTGANHO := ::D3_QTGANHO
	nD3_QTMAIOR := ::D3_QTMAIOR
	cATUEMP		:= ::ATUEMP
	xD3_DTVALID := CTOD(::D3_DTVALID)
	
	Conout("==================================================")
    Conout("==    Parametros recebidos pelo WS_APONTAR      ==")
    Conout("==================================================")
	ConOut ("Empresa.....: " + cEmpresa        )
	ConOut ("Filial......: " + cCFilial        )
	ConOut ("D3_TM.......: " + cD3_TM          )
	ConOut ("D3_QUANT....: " + Str(nD3_QUANT)  )
	ConOut ("D3_OP.......: " + cD3_OP          )
	ConOut ("D3_LOCAL....: " + cD3_LOCAL       )
	ConOut ("D3_CC.......: " + cD3_CC          )
	ConOut ("D3_PARCTOT..: " + cD3_PARCTOT     )
	ConOut ("D3_LOTECTL..: " + cD3_LOTECTL     )
	ConOut ("D3_PERDA....: " + Str(nD3_PERDA)  )  
	ConOut ("D3_QTGANHO..: " + Str(nD3_QTGANHO))
	ConOut ("D3_QTMAIOR..: " + Str(nD3_QTMAIOR))
	ConOut ("D3_DTVALID..: " + Str(xD3_DTVALID))
	ConOut ("ATUEMP......: " + cATUEMP         )
	ConOut ("=================================================")
	
	If lOk
		Begin Transaction
	
		IIF( Select('TMPOP')  !=0, TMPOP->(DbCLoseArea()  ), )
		DbSelectArea("SC2")
		SC2->(dbSetorder(1))
		cSQL := "SELECT C2_QUANT,C2_NUM FROM SC2"+cEmpresa+"0 WHERE D_E_L_E_T_ <> '*' AND "
		cSQL += "C2_NUM = '"+SubStr(cD3_OP,01,06)+"' AND C2_ITEM ='"+SubStr(cD3_OP,07,02)+"' AND C2_SEQUEN ='"+SubStr(cD3_OP,09,03)+"' "
		cSQL := ChangeQuery(cSQL)
		dbUseArea( .F., "TOPCONN", TcGenQry(,,cSQL), "TMPOP", .T., .T. )
	
			AADD(aMata250,{"D3_OP"      , cD3_OP 	  , NIL})
			AADD(aMata250,{"D3_TM"      , cD3_TM      , NIL})
			AADD(aMata250,{"D3_LOCAL"   , cD3_LOCAL   , NIL})
			AADD(aMata250,{"D3_CC"      , cD3_CC      , NIL})
			AADD(aMata250,{"D3_QUANT"   , nD3_QUANT   , NIL})
			AADD(aMata250,{"D3_PERDA"   , nD3_PERDA   , NIL})
			AADD(aMata250,{"D3_PARCTOT" , cD3_PARCTOT , NIL})
			// Quando produto não tiver controle de lote os dois campos não podem ser passados
			If cD3_LOTECTL !=""
				AADD(aMata250,{"D3_LOTECTL" , cD3_LOTECTL , NIL})
				AADD(aMata250,{"D3_DTVALID" , xD3_DTVALID , NIL})
			EndIf
			AADD(aMata250,{"D3_QTGANHO" , nD3_QTGANHO , NIL})
			AADD(aMata250,{"D3_QTMAIOR" , nD3_QTMAIOR , NIL})
			AADD(aMata250,{"ATUEMP"     , cATUEMP     , NIL})
			MSExecAuto({|x, y| mata250(x, y)}, aMata250, 3)
			TMPOP->(dbCloseArea())
			
			If lMsErroAuto    
				cErro := Mostraerro("sosystools","Error WS_OP_APONTAR.txt")
				ConOut(cErro)	
				::SetResponse( '{' )
				::SetResponse( '"errorCode": "1",' )
				::SetResponse( '"errorMessage": ' + "Erro ao apontar empenho: " + cD3_OP )	
				::SetResponse( cErro)
				::SetResponse('}')
				ConOut ( "=========================================================================" )
				ConOut ( "========                 FIM OP_APONTAR                          ========" )
				ConOut ( "========                 " + DTOS(DATE()) + "                              ========" )
				ConOut ( "========                  " + TIME() + "                               ========" )
				ConOut ( "=========================================================================" )
				DisarmTran()
				TMPSD4->(dbCloseArea())
				lOk := .T.
			Else
				::SetResponse('{')
				::SetResponse('"errorCode": "0",' )
				::SetResponse('"errorMessage": ' + CHR(34) + "Apontamento feito com sucesso." + CHR(34))
				::SetResponse('}')
				ConOut ( "=========================================================================" )
				ConOut ( "========                 FIM OP_APONTAR                          ========" )
				ConOut ( "========                 " + DTOS(DATE()) + "                              ========" )
				ConOut ( "========                  " + TIME() + "                               ========" )
				ConOut ( "=========================================================================" )								
			EndIf
		End Transaction
	EndIf
	RESET ENVIRONMENT
Return( lOk )//Caso não tenha o lOk ele retorna erro para o postman.