#INCLUDE "protheus.ch" 

/*
Jean Rehermann - Ponto de entrada de filtro na tela markbrowse de faturamento
*/
User Function M460QRY()

	Local _cQuery := Paramixb[ 1 ]
	Local _cQry := ""
	Local _cPedidos := "|"
	Local _aArea := GetArea()

    U_AUTOM628("PE_M460QRY")
   
	// Só podem ser faturados os itens com status = 10 - Aguardando faturamento
    If Select("T_SC6") > 0
       T_SC6->( dbCloseArea() )
    EndIf
	
	_cQry := "SELECT C6_NUM, C6_ITEM FROM "+ RetSqlName("SC6") +" WHERE C6_FILIAL = '" + Alltrim(cFilAnt) + "' AND C6_STATUS = '10' AND D_E_L_E_T_ = '' AND C6_NOTA = ''"

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"T_SC6",.T.,.T.)
	
	While !T_SC6->( Eof() )
		
		_cPedidos += T_SC6->C6_NUM + T_SC6->C6_ITEM + "|" //String com PV+ITEM para colocar no filtro
		
		T_SC6->( dbSkip() )
	End

	T_SC6->( dbCloseArea() )

	If Len( _cPedidos ) > 1
		_cQuery += " AND ( SC9.C9_PEDIDO + SC9.C9_ITEM ) IN "+ InSqlSep( SubStr( _cPedidos, 2 ), , "|" )
	Else
		_cQuery += " AND SC9.C9_PEDIDO = '######' " // Se não houver nenehum registro no C6 com Status = 10
	EndIf
	
	RestArea( _aArea )
	
Return( _cQuery )

// Função para adequar uma string ao comando IN do SQL
// (String a ser adequada, String com possíveis caracteres de separação, Caracter de separação conhecido)
Static Function InSqlSep( StrIn, Separa, SepUni )

	Local _cInSql := ""
	Local _nCont
	Local _nChar := ''
	Local Separa := Iif( SepUni == Nil, Separa, SepUni )
	Separa := Iif( !ValType( Separa ) == "C", ",", Separa )
	
	If( !Empty( StrIn ) )
		_cInSql := "('"
		For _nCont := 1 To Len( AllTrim( StrIn ) )
			_nChar := SubStr( StrIn, _nCont, 1 )
			If !( _nChar $ Separa )
				_cInSql += _nChar
				If( Separa == "" .And. _nCont < Len( LTrim( StrIn ) ) )
					_cInSql += "','"
				EndIf
			Else
				If( _nCont > 1 .And. _nCont < Len( AllTrim( StrIn ) ) )
					_cInSql += "','"
				EndIf
			EndIf
		Next _nCont
		_cInSql += "')"
	Else
		_cInSql := "('')"
	EndIf

Return( _cInSql )
