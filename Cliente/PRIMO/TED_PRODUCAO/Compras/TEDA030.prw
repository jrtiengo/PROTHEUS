#INCLUDE "Protheus.Ch"
#INCLUDE "ap5mail.ch"
#INCLUDE "colors.ch"
#INCLUDE "Totvs.ch"
#INCLUDE "Tbiconn.ch"
#INCLUDE "Topconn.ch"
#INCLUDE "TbiCode.ch"
#Include 'RwMake.ch'
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} TEDA030
Validação do tamanho do código informado.
Usado nos Pontos de Entrada de Nota Fiscal PE_MT100TOK e PE_MT140TOK
@author Mauro - Solutio.
@since 12/02/2021
@version 1.0
@return ${return}, ${return_description}
@param _cNum, , descricao
@type function
/*/
User Function TEDA030(_cNum)

	Local lRet_ := .T.

	If Len(Alltrim(_cNum)) < 9
		MsgAlert("Código de documento informado,"+Alltrim(_cNum)+", com menos de nove caracteres. Favor revisar!")
		lRet_ := .F.
	EndIf

Return(lRet_)
