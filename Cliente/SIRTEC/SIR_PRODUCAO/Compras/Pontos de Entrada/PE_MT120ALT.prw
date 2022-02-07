#Include 'Protheus.ch'

/*/{Protheus.doc} MT120GOK
Ponto de Entrada chamado na entrada da altera��o do Pedido de Compra, para n�o permitir a sua altera��o
@author Jorge Alberto - Solutio
@since 14/08/2019
@return lPermite, .T. se pode alterar ou .F. caso n�o possa
@version 1.0
@type user function
/*/
User Function MT120ALT()

	Local lPermite := .T.
	Local nOpcao := PARAMIXB[1]
	Local cQuery := ""
	Local cAliCR := ""
	Local cAliAtu := ""
	Local cCodUsr := UsrRetName( RetCodUsr() )
	Local aArea := {}
	
	// S� continua as valida��es no PE se a op��o selecionada for Altera��o(4) ou Exclus�o(5)
	// OU
	// Se o usu�rio logado for um Fornecedor
	If ( ( nOpcao <> 4 .And. nOpcao <> 5 ) .Or. cCodUsr <> U_CamposPC( "CGC" ) )
		Return( lPermite )
	EndIf

	If SC7->C7_CONAPRO == "L"

		MsgAlert( "Este pedido j� est� analisado e aprovado, aguarde receber o arquivo pdf do pedido de compras "+;
				  "em seu e-mail para emitir a nota fiscal."+CRLF+CRLF+"Caso realmente precise fazer ajuste neste "+;
				  "pedido j� aprovado, entre em contato pelo n�mero (55) 3431-3195 (Setor de Frota)." ) 
		lPermite := .F.

	// Verifica se teve alguma libera��o parcial
	ElseIf SC7->C7_CONAPRO == "B"
		
		cAliAtu := Alias()
		aArea := GetArea()
	
		cQuery += "SELECT SUM(CR_VALLIB) AS CR_VALLIB "
		cQuery += "FROM " + RetSqlName("SCR") + " SCR "
		cQuery += "WHERE D_E_L_E_T_ = ' ' "
		cQuery += "AND CR_NUM = '" + SC7->C7_NUM + "' "
		cAliCR := GetNextAlias()
		DbUseArea(.T.,"TOPCONECT",TcGenQry(,,cQuery),cAliCR,.F.,.F.)
		If (cAliCR)->( !EOF() )
			If (cAliCR)->CR_VALLIB > 0
				MsgAlert( "Este pedido j� est� analisado e aprovado(parcial), aguarde receber o arquivo pdf do pedido de compras "+;
						  "em seu e-mail para emitir a nota fiscal."+CRLF+CRLF+"Caso realmente precise fazer ajuste neste "+;
						  "pedido j� aprovado, entre em contato pelo n�mero (55) 3431-3195 (Setor de Frota)." ) 
				lPermite := .F.
			EndIf 
		EndIf
		(cAliCR)->( DbCloseArea() )

		RestArea( aArea )
		If ! Empty( cAliAtu )
			DbSelectArea( cAliAtu )
		EndIf 

	EndIf

Return( lPermite )

