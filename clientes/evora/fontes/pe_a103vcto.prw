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
USER FUNCTION _a103vcto()

	Local aVencto := {} //Array com os vencimentos e valores para geração dos título
	Local aArea		:=GetArea()
	Local aRetVto	:={},nK:=0
	If ! SuperGetMV('ES_PPFRE',.F.,.F.)
		RETURN
	end

	//Local aPELinhas := PARAMIXB[1]
	//Local nPEValor := PARAMIXB[2]
	//Local cPECondicao := PARAMIXB[3]
	//Local nPEValIPI := PARAMIXB[4]
	//Local dPEDEmissao := PARAMIXB[5]
	//Local nPEValSol := PARAMIXB[6]

    //DEFAULT _XQTDEVO

	//alert('entre 130vto '+cCondicao)

    iF _XQTDEVO>1
        //alert('não vou sugerir '+cvaltochar(_XQTDEVO))
        Return .t.
    End
    _XQTDEVO++


	dbSelectArea('SZ1')
	dbSetOrder(1)
	If dbSeek(xFilial("SZ1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
		//alert('achei')

		//Manoel, 24/dez/20
		//somente mostrar informaçoes dos vencimentos e observaçes
		aVencto:= StrTokArr(SZ1->Z1_VENCTO, ";")
		nVlrParc:=SF1->F1_VALMERC / Len(aVencto)
		For nK:=1 to Len(aVencto)
			Aadd(aRetVto,{stod(aVencto[nK]),nVlrParc})
			//ALERT(aRetVto[nK,1]+'  '+cvaltochar(aRetVto[nK,2]))

		Next
		/*
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

        cCondicao:=SZ1->Z1_COND
    else
		//alert('nao ache')
	end
	RestArea(aArea)

Return aRetVto
