#INCLUDE "protheus.ch"
/*
Jean Rehermann - 29/06/2012
Programa que retorna valores para os campos de código de barras do CNAB a pagar do ITAU

Retorno = _aRetCB

CÓDIGO BANCO FAVORECIDO   - POS 018 A 020  = _aRetCB[1]
CÓDIGO DA MOEDA           - POS 021 A 021  = _aRetCB[2]
DÍGITO VERIF. CÓD. BARRAS - POS 022 A 022  = _aRetCB[3]
FATOR DE VENCIMENTO       - POS 023 A 026  = _aRetCB[4]
CÓD. DE BARRAS – VALOR    - POS 027 A 036  = _aRetCB[5]
CAMPO LIVRE CÓD. BARRAS   - POS 037 A 061  = _aRetCB[6]
*/
User Function RETCBPAG( cBar )

	Local _aRetCB  := {} // Array de retorno com os valores de cada campo
	Local _nTam    := 0  // Tamanho da string passada como parâmetro para a função
	Local _cBar   := ""  // Recebe o conteúdo do parâmetro
	Local _aPosCLC := {{01,48}}                                         // Linha digitável de Concessionária            (48 posições)
	Local _aPosCBB := {{01,03},{04,01},{05,01},{06,04},{10,10},{20,25}} // Código de barras de boleto ou Concessionária (44 posições)
	Local _aPosLDB := {{01,03},{04,01},{33,01},{34,04},{38,10},{{05,05},{11,10},{22,10}}} // Linha digitável de boleto  (47 posições)
	Local _aPos    := Nil // Recebe o array de acordo com o tamanho da string, e sera processado no AEVAL

	Default cBar := Space( 48 ) // Defino um valor default para evitar erro em tempo de execução
	
	_cBar := AllTrim( cBar ) // Limpo a string
	_nTam := Len( _cBar )    // Tamanho da string
	
	If _nTam == 44           // Código de barras boleto ou concessionária
		If SubStr( cBar, 1, 1 ) == "8" .And. SubStr( cBar, 2, 1 ) $ "2-3-4"
			_aPos := aClone( _aPosCLC )  // 8 = Concessionária | (2-Saneamento/3-Energia e gás/4-Telecomunicações)
		Else
			_aPos := aClone( _aPosCBB )  // Boleto
		EndIf
	ElseIf _nTam == 47       // Linha digitável boleto
		_aPos := aClone( _aPosLDB )
	ElseIf _nTam == 48       // Linha digitável concessionária
		_aPos := aClone( _aPosCLC )
	EndIf
		
	If _aPos != Nil // Se for NIL, a string tinha tamanho diferente de 44, 47 ou 48
		aEval( _aPos, { |e| aAdd( _aRetCB, Iif( ValType( e[ 1 ] ) == "A", CLCB( e, _cBar ), SubStr( _cBar, e[ 1 ], e[ 2 ] ) ) ) } )
    EndIf
    
Return _aRetCB

// Função para montar o campo livre do código de barras à partir da linha digitável, quando esta for informada (47 posições)
Static Function CLCB( aCL, cBar )

	Local _cRet := "" // String de retorno

	If ValType( aCL ) == "A" // Verifico se o parâmetro passado é um array
		aEval( aCL, { |o| _cRet += SubStr( cBar, o[ 1 ], o[ 2 ] ) } ) // Monto a string com as posições passadas no array
	Endif

Return _cRet