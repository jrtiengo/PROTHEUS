#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TOPCONN.CH"
#include "TBICONN.CH"

/*/{Protheus.doc} CNTA300
Ponto de Entrada MVC CNTA300
@type function
@version 1.0 
@author Tiengo Jr.
@since 05/05/2025
@Obs PARAMIXB[1] O - FORMCOMMITTTSPOS - Objeto do formulário ou do modelo, conforme o caso
@Obs PARAMIXB[2] C - FORMCOMMITTTSPOS - ID do local de execução do ponto de entrada
@Obs PARAMIXB[3] C - FORMCOMMITTTSPOS - ID do formulário
@Obs PARAMIXB[4] L - FORMCOMMITTTSPOS - Se .T. indica novo registro (Inclusão) se .F. registro já existente (Alteração / Exclusão)
/*/

User Function CNTA300()

	Local aParam  		:= PARAMIXB
	Local xRet    		:= .T.
	Local oObj    		:= ''
	Local cIdPonto		:= ''
	Local cIdModel		:= ''
	Local lOperacao		:= .F.
	Local cTipo         := 'CTR'

	If aParam <> NIL

		oObj       := aParam[1]
		cIdPonto   := aParam[2]
		cIdModel   := aParam[3]

		//If cIdPonto == 'FORMCOMMITTTSPOS' //Após a gravação da tabela do formulário.
		  If cIdPonto == 'MODELCOMMITNTTS'
			lOperacao := aParam[4]

			//GAP112 - Se o contrato tiver origem do novo fluxo de compras, irá nascer como 2N = Em Elaboração Area Negócio.
			If FWIsInCallStack('PGCA010')
				If lOperacao .and. cIdModel == 'CN9MASTER'
					Reclock("CN9", .F.)
					CN9->CN9_XSITUA := '2N'
					CN9->(msUnlock())
				Endif
			Else
				Reclock("CN9", .F.)
				CN9->CN9_XSITUA := CN9->CN9_SITUAC
				CN9->(msUnlock())
			Endif

			//GAP - 021 Verifica se o contrato está aguardando aprovação e envia ao Fluig
			If ! Empty(CN9->CN9_APROV) .and. (CN9->CN9_SITUAC == '4' .or. CN9->CN9_SITUAC == '9' )

				U_IntAprovFluig(1, cTipo, CN9->CN9_NUMERO, CN9->CN9_REVISA, CN9->CN9_XIDFLU)
			EndIf

		EndIf
	Endif

Return(xRet)
