#Include 'Protheus.ch'

/*/{Protheus.doc} MT120LOK
Ponto de Entrada chamado na valida��o de cada linha do grid dos produtos do Pedido de Compra.
@author Jorge Alberto - Solutio
@since 14/08/2019
@return lPermite, .T. se pode passar para a pr�xima linha do grid ou .F. caso n�o possa
@version 1.0
@type user function
/*/
User Function MT120LOK()

	Local lRet := .T.
	Local nPosOdome := aScan( aHeader, {|x| AllTrim(Upper(X[2])) == "C7_ODOMETR" })
	Local nPosHorim := aScan( aHeader, {|x| AllTrim(Upper(X[2])) == "C7_HORIMET" })
	Local nPosTpMan := aScan( aHeader, {|x| AllTrim(Upper(X[2])) == "C7_TPMANUE" })
	Local nPosObs   := aScan( aHeader, {|x| AllTrim(Upper(X[2])) == "C7_OBS"     })
	Local cCodUsr := UsrRetName( RetCodUsr() )
	
	If cCodUsr == U_CamposPC( "CGC" )
	
		If ( Empty( aCols[ n, nPosOdome ] ) .And. Empty( aCols[ n, nPosHorim ] ) )
			
			MsgAlert( "Dever� ser informado o campo Od�metro ou Hor�metro." )
			lRet := .F. 
		
		ElseIf Empty( aCols[ n, nPosTpMan ] )
			
			MsgAlert( "O campo Tipo de Manuten��o est� vazio." )
			lRet := .F. 
		EndIf
	
	Else
	
		If Empty( aCols[ n, nPosObs ] )
			MsgAlert( "O campo Observa��es est� vazio." )
			lRet := .F. 
		EndIf
		
	EndIf
	
Return( lRet )