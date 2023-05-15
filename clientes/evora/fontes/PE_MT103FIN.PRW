#Include "Protheus.ch"
#Include "rwmake.ch"
#Include "totvs.ch"
/*
Pe no tudo ok do documento de entrada
Ezequiel Pianegonda
07/11/2020
*/
User Function MT103FIN()
	Local lRet:= .T.
	Local aVcto
	local nL:=1
	Local _CRLF:=chr(13)+chr(10)
	If ! SuperGetMV('ES_PPFRE',.F.,.F.)
		RETURN lret
	end

	SZ1->(dbSetOrder(1))
	//If SZ1->(dbSeek(xFilial("SZ1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
	If SZ1->(dbSeek(xFilial("SZ1")+CNFISCAL+CSERIE+CA100FOR+CLOJA))
		//Manoel, 24/dez/20
		//somente mostrar informaçoes dos vencimentos e observaçes

		/*
		aVcto:= StrTokArr(SZ1->Z1_VENCTO, ";")
		cTxtInfo:='Condição de Pagto:'+SZ1->Z1_COND+_CRLF
		cTxtInfo+='Vencimentos Sugeridos:'+_CRLF
		For nL:=1 to Len(aVcto)
			cTxtInfo+='   '+dtoc(stod(aVcto[nL]))+_CRLF
		Next
		cTxtInfo+=replicate('-',30)+_CRLF
		cTxtInfo+='Outras Informações:'+_CRLF
		cTxtInfo+=SZ1->Z1_OBS+_CRLF
		cTxtInfo+='  '+_CRLF

		*/

		        
        aVcto:= StrTokArr(SZ1->Z1_VENCTO, ";")
        cTxtInfo:=PADC('Condição de Pagto:',30)+SZ1->Z1_COND+_CRLF
        cTxtInfo+='Vencimentos Sugeridos:'+_CRLF
        For nL:=1 to Len(aVcto)
            cTxtInfo+='   '+dtoc(stod(aVcto[nL]))+_CRLF
        Next
        cTxtInfo+=replicate('-',30)+_CRLF
        cTxtInfo+=PADR('Centro de Custo: ',30)+SZ1->Z1_CC+_CRLF
        cTxtInfo+=PADR('Tipo de Pagamento: ',30)+X3Combo( "Z1_TIPO",SZ1->Z1_TIPO) +_CRLF
        cTxtInfo+=PADR('Banco/Agencia/Conta: ',30)+SZ1->Z1_BANCO+'/'+SZ1->Z1_AG+'/'+SZ1->Z1_CONTA+_CRLF
        cTxtInfo+=PADR('CPF/CNPJ: ',30)+SZ1->Z1_CNPJ+_CRLF
        cTxtInfo+='Outras Informações:'+_CRLF
        cTxtInfo+=SZ1->Z1_OBS+_CRLF
		cTxtInfo+="CONFIRMA ??"


		lRet:=MSGBOX(cTxtInfo,'Informações do Gestor','YESNO')
	end


Return lRet
