#INCLUDE "TOPCONN.ch"
#include "protheus.ch"
#include "apwizard.ch"
#include "tbiconn.ch" // include do wf
#include "TbiCode.ch" // include do wf


//**********************************************************************************
// MARCHER                                                                         *
// ------------------------------------------------------------------------------- *
// Referencia: PE_MT097END.PRW                                                     *
// Parâmetros: [cPedido,cTipo,nOpc,cFilDoc]                                        *
// Tipo......: ( ) Programa  ( ) Gatilho (x)Ponto de Entrada                       *
// ------------------------------------------------------------------------------- *
// Autor.....: Márcio Borges                                                       *
// Data......: 02/10/2018                                                          *
// Objetivo..: PE para enviar PDF do pedido no momento da liberação alcada         *
//**********************************************************************************
// Documentação do Ponto de Entrada MT: http://tdn.totvs.com/pages/releaseview.action?pageId=6085377
// acesso em 02/10/2018.


/*/{Protheus.doc} MT094END
//TODO PE para acionar envio PDF do pedido no momento da liberação alcada
@author Márcio Borges
@since 02/10/2018
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function  MT094END() 
	//PARAMIXB[1]	Caracter	Número do Documento	X
	//PARAMIXB[2]	Caracter	Tipo do documento (PC, NF, SA, IP, AE)	X
	//PARAMIXB[3]	Numérico	Operação a ser executada (1-Aprovar, 2-Estornar, 3-Aprovar pelo Superior, 4-Transferir para Superior, 5-Rejeitar, 6-Bloquear)	X
	//PARAMIXB[4]	Caracter	Filial do documento

	Local cPedido   := AllTrim(PARAMIXB[1]) 
	Local cTipoDoc  := PARAMIXB[2]
	Local nOpcao    := PARAMIXB[3]
	Local cFilDoc   := PARAMIXB[4]

	If  !Empty(SCR->CR_DATALIB) .And. SCR->CR_STATUS $ "03#05"
		if MsgYesNo("Deseja Gerar e Enviar PDF do Pedido Liberado automaticamente para o Fornecedor ? ",OemToAnsi('ATENCAO - Envio de Email?'))
			//ExecBlock("MT094END",.F.,.F.,{FwFldGet("CR_NUM"),FwFldGet("CR_TIPO"),oModel:GetOperation(),FwFldGet("CR_FILIAL")})
			If ExistBlock("PDFPCML")
				ExecBlock("PDFPCML",.F.,.F.,{cPedido,cTipoDoc,nOpcao,cFilDoc})
			endif
		Endif
	Endif

Return
