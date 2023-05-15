#Include "Protheus.ch"
#Include "rwmake.ch"
#Include "totvs.ch"
/*
+---------+-----------+-------+-------------------------------------+------+----------+
| Funcao    | F580ADDB  | Autor | Manoel M Mariante                   | Data |out/2020  |
|-----------+-----------+-------+-------------------------------------+------+----------|
| Descricao | PE que adiciona botÃµes no browse dos titulos a serem liberados            |
|           |                                                                           |
|           |                                                                           |
|-----------+---------------------------------------------------------------------------|
| Sintaxe   | executado na rotina FINA580                                               |
+-----------+---------------------------------------------------------------------------+
*/

User Function MT103NFE()

	//alert('entrei no MT103NFE')
    PUBLIC _XQTDEVO:=1
    //DEFAULT _XQTDEVO:=1
/*
	SZ1->(dbSetOrder(1))
	If SZ1->(dbSeek(xFilial("SZ1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
/*
		//Manoel, 24/dez/20
		//somente mostrar informaçoes dos vencimentos e observaçes
		aVcto:= StrTokArr(SZ1->Z1_VENCTO, ";")
		cTxtInfo:='Condição de Pagto :'+SZ1->Z1_COND+_CRLF
		cTxtInfo+='Vencimentos Sugeridos:'+_CRLF
		For nL:=1 to Len(aVcto)
			cTxtInfo+='   '+dtoc(stod(aVcto[nL]))+_CRLF
		Next
		cTxtInfo+=replicate('-',30)+_CRLF
		cTxtInfo+='Outras Informações:'+_CRLF
		cTxtInfo+=SZ1->Z1_OBS
		MsgInfo(cTxtInfo,'Informações Digitadas pelo Gestor')
        */
		//cCondicao:=SZ1->Z1_COND

	//EndIf
    
Return .T.
