#Include "TOTVS.CH"
#include "TBICONN.ch"
#include "PROTHEUS.ch"
#Include "RESTFUL.CH"   

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma ³ GET ºAutor:Guilherme Barrios ³Sosys Business Insightº Data ³NOV/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Metodo para finalizar OP apontada parcialmente(Tabela SC2)	       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Automatech - OP_FINALIZAR                               		       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

WSRESTFUL OP_FINALIZAR DESCRIPTION "Encerrar Ordem de Produção" 

	WSDATA EMPRESA    AS STRING // Empresa. - 01
	WSDATA FILIAL  	  AS STRING // Filial. - 01
	WSDATA D3_OP   	  AS STRING // Número da Ordem de Produção + Item + Sequência. - 00000101001
	WSDATA D3_COD	  AS STRING // Código do Produto Final. - 02010432630102641
	WSDATA D3_TM   	  AS STRING // Tipo de Movimento - 101, ...
	WSDATA D3_LOCAL   AS STRING // Local do Armazém. - 01, TM, ...
	WSDATA D3_EMISSAO AS STRING // Data da emissão da OP. - 01/01/2020
	WSDATA D3_DOC     AS STRING // Número do Documento. - UTILIZARJ, 000013010, ...
	WSDATA D3_NUMSEQ  AS STRING // Numeração sequencial. - 727641
		
WSMETHOD GET DESCRIPTION "Encerrar Ordem de Produção apontada parcialmente" WSSYNTAX "/EMPRESA=01&FILIAL=02&D3_OP=00000601001&D3_TM=101&D3_LOCAL=01&D3_COD=02010432630102641&D3_EMISSAO=12/01/2020&D3_DOC=000013010&D3_NUMSEQ=727641
	
END WSRESTFUL

WSMETHOD GET WSRECEIVE EMPRESA,FILIAL,D3_OP,D3_TM,D3_LOCAL,D3_COD,D3_EMISSAO,D3_DOC,D3_NUMSEQ WSSERVICE OP_FINALIZAR

	Local aOrdPro     := {}
	Local cErro		  := {}
	Local lOk	      := .T.
	Local cEmpresa    := ""
	Local cCFilial    := ""
	Local cD3_OP      := ""
	Local cD3_COD	  := ""
	Local cD3_LOCAL	  := ""
	Local cD3_TM   	  := ""
	Local cD3_EMISSAO := ""
	Local cD3_DOC	  := ""
	Local cD3_NUMSEQ  := ""
	   
    PRIVATE lMsErroAuto := .F.

    ::SetContentType("application/json") //Define o tipo de retorno do metodo
    
    cEmpresa := ::EMPRESA
    cCFilial := ::FILIAL
    
    PREPARE ENVIRONMENT EMPRESA cEmpresa FILIAL cCFilial
    
    cD3_OP	    := ::D3_OP
    cD3_TM	    := ::D3_TM
    cD3_LOCAL   := ::D3_LOCAL
    cD3_EMISSAO := ::D3_EMISSAO
    cD3_COD     := ::D3_COD
    cD3_DOC     := ::D3_DOC
    cD3_NUMSEQ  := ::D3_NUMSEQ
    cD3_OP := PadR( cD3_OP, TamSX3("D3_OP")[01] )
    cD3_COD := PadR( cD3_COD, TamSX3("D3_COD")[01] )
    
    Conout("==================================================")
    Conout("==    Parametros recebidos pelo WS_FINALIZAR    ==")
    Conout("==================================================")
	ConOut ("Empresa......: " + cEmpresa    )
	ConOut ("Filial.......: " + cCFilial    )
	ConOut ("C2_OP........: " + cD3_OP      )
	ConOut ("D3_TM........: " + cD3_TM      )
	ConOut ("D3_LOCAL.....: " + cD3_LOCAL   )
	ConOut ("D3_EMISSAO...: " + cD3_EMISSAO )
	ConOut ("D3_COD.......: " + cD3_COD     )
	ConOut ("D3_DOC.......: " + cD3_DOC     )
	ConOut ("D3_NUMSEQ....: " + cD3_NUMSEQ  )
	ConOut ("=================================================")
    
    Begin Transaction
    	SD3->(DbSetOrder(1))//xFilial("SD3") + cOp + cCod + cLocal
		SD3->(DbSeek(cCFilial+cD3_OP+cD3_COD+cD3_LOCAL))
		
    	aOrdPro := {{"D3_OP"     , cD3_OP	    ,Nil},;
    			    {"D3_TM"     , cD3_TM	    ,Nil},;
    			    {"D3_COD"    , cD3_COD      ,Nil},;
    			    {"D3_EMISSAO", cD3_EMISSAO  ,Nil},;
    			    {"D3_DOC"    , cD3_DOC  	,Nil},;
    			    {"D3_NUMSEQ" , cD3_NUMSEQ   ,Nil}}
    			   
        MSExecAuto({|x, y| mata250(x, y)}, aOrdPro, 6)

    End Transaction
    
    If lMsErroAuto
    	cErro := Mostraerro("sosystools","Error WS_OP_FINALIZAR.txt")
		ConOut(cErro)
		::SetResponse( '{' )
        ::SetResponse( '"errorCode": "1",' )
        ::SetResponse( '"errorMessage": ' + "Erro ao finalizar empenho: " + cD3_OP )	
        ::SetResponse( cErro )
        ::SetResponse('}')
       	ConOut ( "=========================================================================" )
       	ConOut ( "========                FIM OP_FINALIZAR                         ========" )
       	ConOut ( "========                 " + DTOS(DATE()) + "                              ========" )
		ConOut ( "========                  " + TIME() + "                               ========" )
        ConOut ( "=========================================================================" )
        DisarmTran()
		SD3->(dbCloseArea())
		lOk := .T.		
	Else
		SD3->(dbCloseArea())
		::SetResponse('{')
		::SetResponse('"errorCode": "0",' )
		::SetResponse('"errorMessage": ' + CHR(34) + "OP finalizada com sucesso." + CHR(34))	
		::SetResponse('}')
		ConOut ( "=========================================================================" )
		ConOut ( "========                FIM OP_FINALIZAR                         ========" )
		ConOut ( "========                 " + DTOS(DATE()) + "                              ========" )
		ConOut ( "========                  " + TIME() + "                               ========" )
		ConOut ( "=========================================================================" )
	EndIf
	RESET ENVIRONMENT
Return ( lOk )