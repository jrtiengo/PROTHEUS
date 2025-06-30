#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} SitContrUC
Função para retornar as opções de contratos no campo CN9_XSITUAC
@type function
@version 1.0 
@author Tiengo Jr.
@since 30/06/2025
/*/

User function SitContrUC()

	Local cSituac := ''

	cSituac += "01=Cancelado;"
	cSituac += "02=Em Elaboração;"
	cSituac += "2N=Em Elaboração Area Negócio;"
	cSituac += "2J=Jurídico;"
	cSituac += "2A=Em Assinatura;"
	cSituac += "2C=Em Cancelamento;"
	cSituac += "03=Emitido;"
	cSituac += "04=Em Aprovação;"
	cSituac += "05=Vigente;"
	cSituac += "06=Paralisado;"
	cSituac += "07=Solicitação Finalização;"
	cSituac += "08=Finalizado;"
	cSituac += "09=Revisão;"
	cSituac += "10=Revisado;"
	cSituac += "A=Aprov Revisão"

Return(cSituac)
