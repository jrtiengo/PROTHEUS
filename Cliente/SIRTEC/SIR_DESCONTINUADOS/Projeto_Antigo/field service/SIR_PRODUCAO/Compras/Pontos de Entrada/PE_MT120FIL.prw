#Include 'Protheus.ch'

/*/{Protheus.doc} MT120FIL
Ponto de Entrada chamado antes de mostrar os Pedidos de Compra, utilizado para filtrar os dados.
@author Jorge Alberto - Solutio
@since 14/08/2019
@version 1.0
@return cFiltra, texto com o filtro de usuário que será executado.
@type user function
/*/
User Function MT120FIL()

	Local cFiltra := ""
	Local cCodUsr := UsrRetName( RetCodUsr() )
	Local cCorte  := SuperGetMV("ES_CORTEPC",, "20190819" )
	
	// Se o usuário logado for um Fornecedor, então irá filtrar os PC para mostrar somente os seus.
	If cCodUsr == U_CamposPC( "CGC" )
		cFiltra := " C7_FORNECE=='"+U_CamposPC( "CODIGO" )+"' .AND. C7_EMISSAO >= '" + cCorte + "' "
	EndIf
	
Return( cFiltra )