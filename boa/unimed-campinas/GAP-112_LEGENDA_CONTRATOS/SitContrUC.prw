#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} SitContrUC
Fun��o para retornar as op��es de contratos no campo CN9_XSITUAC
@type function
@version 1.0 
@author Tiengo Jr.
@since 30/06/2025
/*/

User function SitContrUC()

	Local cSituac := ''

	cSituac += "01=Cancelado;"
	cSituac += "02=Em Elabora��o;"
	cSituac += "2N=Em Elabora��o Area Neg�cio;"
	cSituac += "2J=Jur�dico;"
	cSituac += "2A=Em Assinatura;"
	cSituac += "2C=Em Cancelamento;"
	cSituac += "03=Emitido;"
	cSituac += "04=Em Aprova��o;"
	cSituac += "05=Vigente;"
	cSituac += "06=Paralisado;"
	cSituac += "07=Solicita��o Finaliza��o;"
	cSituac += "08=Finalizado;"
	cSituac += "09=Revis�o;"
	cSituac += "10=Revisado;"
	cSituac += "A=Aprov Revis�o"

Return(cSituac)
