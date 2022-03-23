#INCLUDE "PROTHEUS.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MTA120G1 ºAutor  ³ Jorge Alberto       º Data ³ 17/08/2017 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega um array que será utilizado no PE MTA120G3, ambos  º±±
±±º          ³ os PE são usados no Pedido de Compras.                     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Marcher do Brasil                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MTA120G1()

	Local aProdutos   := {}
	Local aArea		  := {}
	Local nProd       := 0
	Local nPosAprov   := 0
	Local nPosProd    := 0
	Local cQuery      := ""
	Local cGrpProd    := ""

	// Só entra no PE se for na inclusão do PC
	If !INCLUI
		Return
	EndIf
	
	aArea	    := GetArea()
    aProdutos   := aClone( aCols )
	nPosProd    := aScan(aHeader, {|x| AllTrim( X[2] ) == "C7_PRODUTO" } )
	nPosAprov   := aScan(aHeader, {|x| AllTrim( X[2] ) == "C7_APROV" } )

	For nProd := 1 To Len( aProdutos )

		cGrpProd := GetNextAlias()
	
		cQuery := "SELECT SBM.BM_GRPAPR " 
		cQuery += "  FROM " + RetSqlName("SBM") + " SBM "
		cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 ON SBM.BM_GRUPO = SB1.B1_GRUPO "
		cQuery += " WHERE SBM.D_E_L_E_T_ = ' ' "
		cQuery += "   AND SB1.D_E_L_E_T_ = ' ' "
		cQuery += "   AND SB1.B1_COD = '" + aProdutos[ nProd, nPosProd ] + "' "
		cQuery += " ORDER BY SBM.BM_GRPAPR "
	
		cQuery := ChangeQuery(cQuery)
		DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cGrpProd,.T.,.T.)
	
		If (cGrpProd)->( !EOF() )		
			// Atualizo o arry do campo "Grupo Aprov" do Item do PC, com o valor que deverá ser gravado no PE MTA120G3
			aProdutos[ nProd, nPosAprov ] := (cGrpProd)->BM_GRPAPR
		Else
		   // Se ficar vazio no final da inclusão o sistema preenche todos os registros com o mesmo código do Grupo.
		   // então no PE_MT120F() será deixado o campo limpo para os itens com o código "LIMPAR".
			aProdutos[ nProd, nPosAprov ] := "LIMPAR"
		EndIf
		
		(cGrpProd)->( DbCloseArea() )

	Next
			
	RestArea( aArea )

Return( aProdutos )
