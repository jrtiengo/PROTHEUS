#Include 'Protheus.ch'

/*/{Protheus.doc} MT120GOK
Ponto de Entrada chamado no final da Inclusão, Alteração ou Exclusão de Pedido de Compra.
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
	
	// Somente para o usuário Fornecedor é que deverá ser mostrada a mensagem. 
	If ( l120Inclui .And. cCodUsr == U_CamposPC( "CGC" ) )
		MsgInfo("Incluído o pedido de compra número " + cA120Num + CRLF+;
				"Aguarde o pedido de compras liberado em PDF que será mandado "+;
				"para seu e-email autorizando para emitir a Nota Fiscal." )
	EndIf
	
Return