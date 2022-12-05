#INCLUDE "protheus.ch"

/*
Jean rehermann - 08/04/2011
Programa que retorna o texto do campo LAUDO do orçamento para o campo LAUDO do atendimento da OS
Gatilho no campo AB9_NUMOS ==>> AB9_MEMO2 (Origem: AB3_LAUDO2) - Portfólio Tarefa #1295
*/
User Function AUTG001()
	
	Local _cOS    := Left( M->AB9_NUMOS, 6 )
	Local _cOrc   := ""
	Local _cRet   := ""
	lOCAL _cNch   := ""
	Local _cQuery := ""
	Local _aArea1 := GetArea()
	Local _aArea2 := AB3->( GetArea() )
	
	_cQuery := "SELECT AB7_NUMORC, AB7_NRCHAM FROM "+ RetSqlName("AB7") +" AB7 "
	_cQuery += " WHERE AB7.AB7_NUMOS = '"+ _cOS +"' AND AB7_FILIAL = '"+ xFilial("AB7") +"' "
	_cQuery += " AND AB7.D_E_L_E_T_ <> '*' "
	
	_cQuery := ChangeQuery( _cQuery )
	Iif( Select("T_AB7") > 0, T_AB7->( dbCloseArea() ), )
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"T_AB7",.T.,.T.)
	_cOrc := T_AB7->AB7_NUMORC
	_cNch := T_AB7->AB7_NRCHAM
	Iif( Select("T_AB7") > 0, T_AB7->( dbCloseArea() ), )
	
	If Empty( AllTrim( _cOrc ) )
		If !Empty( AllTrim( _cNch ) )
			
			_cQuery := "SELECT AB2_NUMORC FROM "+ RetSqlName("AB2") +" AB2 "
			_cQuery += " WHERE AB2.AB2_NRCHAM = '"+ _cNch +"' AND AB2_FILIAL = '"+ xFilial("AB2") +"' "
			_cQuery += " AND AB2.D_E_L_E_T_ <> '*' "
			
			_cQuery := ChangeQuery( _cQuery )
			Iif( Select("T_AB2") > 0, T_AB2->( dbCloseArea() ), )
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"T_AB2",.T.,.T.)
			_cOrc := T_AB2->AB2_NUMORC
			Iif( Select("T_AB2") > 0, T_AB2->( dbCloseArea() ), )

		EndIf
	EndIf

	If !Empty( AllTrim( _cOrc ) )
		dbSelectArea("AB3")
		dbSetOrder(1)
		If dbSeek( xFilial("AB3") + _cOrc )
			_cRet := AB3->AB3_LAUDO
			M->AB9_RLAUDO := AB3->AB3_RLAUDO
			M->AB9_DESTEC := Posicione("AA1",1,xFilial("AA1")+AB3->AB3_RLAUDO,"AA1_NOMTEC")
		EndIf
	EndIf

	RestArea( _aArea2 )
	RestArea( _aArea1 )
	
Return _cRet