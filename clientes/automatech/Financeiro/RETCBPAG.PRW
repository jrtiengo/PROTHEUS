#INCLUDE "protheus.ch"
/*
Jean Rehermann - 29/06/2012
Programa que retorna valores para os campos de c�digo de barras do CNAB a pagar do ITAU

Retorno = _aRetCB

C�DIGO BANCO FAVORECIDO   - POS 018 A 020  = _aRetCB[1]
C�DIGO DA MOEDA           - POS 021 A 021  = _aRetCB[2]
D�GITO VERIF. C�D. BARRAS - POS 022 A 022  = _aRetCB[3]
FATOR DE VENCIMENTO       - POS 023 A 026  = _aRetCB[4]
C�D. DE BARRAS � VALOR    - POS 027 A 036  = _aRetCB[5]
CAMPO LIVRE C�D. BARRAS   - POS 037 A 061  = _aRetCB[6]
*/
User Function RETCBPAG( cBar )

	Local _aRetCB  := {} // Array de retorno com os valores de cada campo
	Local _nTam    := 0  // Tamanho da string passada como par�metro para a fun��o
	Local _cBar   := ""  // Recebe o conte�do do par�metro
	Local _aPosCLC := {{01,48}}                                         // Linha digit�vel de Concession�ria            (48 posi��es)
	Local _aPosCBB := {{01,03},{04,01},{05,01},{06,04},{10,10},{20,25}} // C�digo de barras de boleto ou Concession�ria (44 posi��es)
	Local _aPosLDB := {{01,03},{04,01},{33,01},{34,04},{38,10},{{05,05},{11,10},{22,10}}} // Linha digit�vel de boleto  (47 posi��es)
	Local _aPos    := Nil // Recebe o array de acordo com o tamanho da string, e sera processado no AEVAL

	Default cBar := Space( 48 ) // Defino um valor default para evitar erro em tempo de execu��o
	
	_cBar := AllTrim( cBar ) // Limpo a string
	_nTam := Len( _cBar )    // Tamanho da string
	
	If _nTam == 44           // C�digo de barras boleto ou concession�ria
		If SubStr( cBar, 1, 1 ) == "8" .And. SubStr( cBar, 2, 1 ) $ "2-3-4"
			_aPos := aClone( _aPosCLC )  // 8 = Concession�ria | (2-Saneamento/3-Energia e g�s/4-Telecomunica��es)
		Else
			_aPos := aClone( _aPosCBB )  // Boleto
		EndIf
	ElseIf _nTam == 47       // Linha digit�vel boleto
		_aPos := aClone( _aPosLDB )
	ElseIf _nTam == 48       // Linha digit�vel concession�ria
		_aPos := aClone( _aPosCLC )
	EndIf
		
	If _aPos != Nil // Se for NIL, a string tinha tamanho diferente de 44, 47 ou 48
		aEval( _aPos, { |e| aAdd( _aRetCB, Iif( ValType( e[ 1 ] ) == "A", CLCB( e, _cBar ), SubStr( _cBar, e[ 1 ], e[ 2 ] ) ) ) } )
    EndIf
    
Return _aRetCB

// Fun��o para montar o campo livre do c�digo de barras � partir da linha digit�vel, quando esta for informada (47 posi��es)
Static Function CLCB( aCL, cBar )

	Local _cRet := "" // String de retorno

	If ValType( aCL ) == "A" // Verifico se o par�metro passado � um array
		aEval( aCL, { |o| _cRet += SubStr( cBar, o[ 1 ], o[ 2 ] ) } ) // Monto a string com as posi��es passadas no array
	Endif

Return _cRet