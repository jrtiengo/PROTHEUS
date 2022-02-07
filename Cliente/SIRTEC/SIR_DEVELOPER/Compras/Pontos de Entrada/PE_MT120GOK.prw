#Include 'Protheus.ch'

/*/{Protheus.doc} MT120GOK
Ponto de Entrada chamado no final da Inclus�o, Altera��o ou Exclus�o de Pedido de Compra.
@author Jorge Alberto - Solutio
@since 14/08/2019
@version 1.0
@type user function
/*/
User Function MT120GOK()

	Local cCodUsr := UsrRetName( RetCodUsr() )
	Local cA120Num := PARAMIXB[1]
	Local l120Inclui  := PARAMIXB[2]
	//Local l120Altera  := PARAMIXB[3]
	//Local l120Deleta  := PARAMIXB[4]
	
	// Somente para o usu�rio Fornecedor � que dever� ser mostrada a mensagem. 
	If ( l120Inclui .And. cCodUsr == U_CamposPC( "CGC" ) )
		MsgInfo("Inclu�do o pedido de compra n�mero " + cA120Num + CRLF+;
				"Aguarde o pedido de compras liberado em PDF que ser� mandado "+;
				"para seu e-email autorizando para emitir a Nota Fiscal." )
	EndIf
	
Return