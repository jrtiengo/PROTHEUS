#INCLUDE "protheus.ch"

/*/
Jean Rehermann | JPC - 04/05/2011
Imprime proposta comercial

Esta rotina exibe uma tela com todas as propostas associadas à oportunidade aberta, para que se selecione uma para
gerar a impressão da proposta comercial gráfica AUTR002.
/*/

User Function AUTA001()

	Local cQuery  := ""
	Local aBrowse := {}    
	Local cProp   := ""

    U_AUTOM628("AUTA001")
	
	cQuery := " SELECT ADY_PROPOS, ADY_DATA, ADY_VAL "
	cQuery += " FROM "+ RetSqlName("ADY")
	cQuery += " WHERE ADY_OPORTU = '"+ AD1->AD1_NROPOR +"' AND ADY_REVISA = '"+ AD1->AD1_REVISA +"' AND ADY_FILIAL = '"+ xfilial("ADY") +"' "
	
	cQuery := ChangeQuery( cQuery )
	If Select("T_ADY") > 0
		T_ADY->( dbCloseArea() )
	EndIf
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"T_ADY",.T.,.T.)
	
	// Formatar os campos para uso
	aStru := T_ADY->( dbStruct() )
	aEval( aStru, { |e| If( e[ 2 ] != "C" .And. T_ADY->( FieldPos( Alltrim( e[ 1 ] ) ) ) > 0, TCSetField( "T_ADY", e[ 1 ], e[ 2 ],e [ 3 ], e[ 4 ] ), Nil ) } )

	
	T_ADY->( dbGoTop() )

	If !T_ADY->( Eof() )

		DEFINE DIALOG oDlg TITLE "Exemplo TCBrowse" FROM 180,180 TO 500,700 PIXEL
		                 
	    // Vetor com elementos do Browse
		While !T_ADY->( Eof() )
			aAdd( aBrowse, { T_ADY->ADY_PROPOS, T_ADY->ADY_DATA, T_ADY->ADY_VAL } )
			T_ADY->( dbSkip() )
		End
	       
		T_ADY->( dbCloseArea() )
		
		// Cria Browse
		oBrowse := TCBrowse():New( 01, 01, 260, 156,, {'Proposta','Data de Emissão','Data de Validade da Proposta'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	
		// Seta vetor para a browse
		oBrowse:SetArray(aBrowse) 
	
		// Monta a linha a ser exibida no Browse
		oBrowse:bLine := {||{ PadR( aBrowse[ oBrowse:nAt, 01 ], 15 ), StoD( aBrowse[ oBrowse:nAt, 02 ] ), StoD( aBrowse[ oBrowse:nAT, 03 ] ) } }
	
		// Evento de clique no cabeçalho da browse
		oBrowse:bHeaderClick := {|| Nil } 
	
		// Evento de duplo click na celula
		//oBrowse:bLDblClick   := {|| cProp := aBrowse[ oBrowse:nAt, 01 ], oDlg:End(), CallPrt( cProp ) }
		oBrowse:bLDblClick   := {|| cProp := aBrowse[ oBrowse:nAt, 01 ], CallPrt( cProp ) }
	
		ACTIVATE DIALOG oDlg CENTERED 
	
	Else
		MsgAlert("Nenhuma proposta encontrada para esta oportunidade.")
	EndIf
	
Return

Static Function CallPrt( cProp )
	
	Local _cProposta   := cProp
	Local _cOportuni   := AD1->AD1_NROPOR
	
	If Empty( _cProposta ) .Or. _cProposta == Nil
		MsgAlert("Proposta não encontrada!")
		Return
	EndIf
	
	If Empty( _cOportuni ) .Or. _cOportuni == Nil
		MsgAlert("Oportunidade não encontrada!")
		Return
	EndIf

	U_AUTR002( _cOportuni, _cProposta )
	
Return