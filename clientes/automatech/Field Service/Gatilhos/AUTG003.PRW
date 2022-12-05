#Include "Protheus.ch"
#Include "Rwmake.ch"
#Include "Topconn.ch"
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AUTG003     ºAutor  ³Lucas Moresco     º Data ³  13/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Retorna o texto das informacoes do orcamento para o campo º±±
±±º          ³  informacoes do atendimento da O.S.						  º±±
±±º          ³  Diparado por gatilho no campo AB9_NUMOS. Preenche o campo º±±
±±º          ³  AB9_MEMO6. Origem: AB3_MEMO4(Informacoes Internas)   	  º±±
±±º          ³              											  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus / Automatech                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function AUTG003()
	
	Local _cOS    := Left( M->AB9_NUMOS, 6 )
	Local _cOrc   := ""
	Local _cRet   := ""
	Local _cNch   := ""
	Local _cQuery := ""
	Local _aArea1 := GetArea()
	Local _aArea2 := AB3->( GetArea() )
	
	_cQuery := "SELECT AB7_NUMORC, AB7_NRCHAM FROM "+ RetSqlName("AB7") +" AB7 (NOLOCK) "
	_cQuery += " WHERE AB7.AB7_NUMOS = '"+ _cOS +"' AND AB7_FILIAL = '"+ xFilial("AB7") +"' "
	_cQuery += " AND AB7.D_E_L_E_T_ <> '*' "
	
	_cQuery := ChangeQuery( _cQuery )
	Iif( Select("T_AB7") > 0, T_AB7->( dbCloseArea() ), )
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"T_AB7",.T.,.T.)
	_cOrc := T_AB7->AB7_NUMORC
	_cNch := T_AB7->AB7_NRCHAM
	T_AB7->( dbCloseArea() )
	
	If Empty( AllTrim( _cOrc ) )
		If !Empty( AllTrim( _cNch ) )
			
			_cQuery := "SELECT AB2_NUMORC FROM "+ RetSqlName("AB2") +" AB2 (NOLOCK) "
			_cQuery += " WHERE AB2.AB2_NRCHAM = '"+ _cNch +"' AND AB2_FILIAL = '"+ xFilial("AB2") +"' "
			_cQuery += " AND AB2.D_E_L_E_T_ <> '*' "
			
			_cQuery := ChangeQuery( _cQuery )
			Iif( Select("T_AB2") > 0, T_AB2->( dbCloseArea() ), )
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"T_AB2",.T.,.T.)
			_cOrc := T_AB2->AB2_NUMORC
			T_AB2->( dbCloseArea() )

		EndIf
	EndIf
	
	If !Empty( AllTrim( _cOrc ) )
	
		_cQuery:= "SELECT AB3.AB3_MEMO5 FROM " +RetSqlName("AB3")+" AB3 (NOLOCK) "+chr(13)
		_cQuery+= " WHERE AB3.AB3_NUMORC = '"+ SubStr( _cOrc, 1, 6 ) +"' AND "+chr(13) 
		_cQuery+= " AB3.AB3_FILIAL = '"+ xFilial("AB3") +"'AND "+chr(13)
		_cQuery+= " AB3.D_E_L_E_T_ <> '*' "+chr(13)
		_cQuery+= " ORDER BY AB3.AB3_MEMO5 "+chr(13)
		
		_cQuery := ChangeQuery( _cQuery )
		Iif( Select("T_AB3") > 0, T_AB3->( dbCloseArea() ), )
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQuery),"T_AB3",.T.,.T.)
		
		While !T_AB3->( Eof() )
		
			_cRet += AllTrim( MSMM( T_AB3->AB3_MEMO5 ) ) + Chr(13) + Chr(10)
	   		T_AB3->( DbSkip() )
		EndDo
	
	EndIf

	RestArea( _aArea2 )
	RestArea( _aArea1 )
	        
Return _cRet