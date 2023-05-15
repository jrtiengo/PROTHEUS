#Include "Protheus.ch"
#Include "rwmake.ch"
#Include "totvs.ch"
/*
Pe no tudo ok do documento de entrada
Ezequiel Pianegonda
07/11/2020
*/
User Function MT100TOK()
	Local lRet:= .T.
	Local aVcto
	local nL:=1
	Local _CRLF:=chr(13)+chr(10)

	If ! SuperGetMV('ES_PPFRE',.F.,.F.)
		RETURN .T.
	end
	SZ1->(dbSetOrder(1))
	If SZ1->(dbSeek(xFilial("SZ1")+CNFISCAL+CSERIE+CA100FOR+CLOJA))

		If SZ1->Z1_LIB != "S"
			MsgInfo("Esse Documento "+CNFISCAL+'/'+CSERIE+" não poderá ser classificado pois encontra-se pendente para validação ou bloqueado.", "MT100TOK")
			return .f.
		End
	END

Return .t.

/*

If ALTERA
    SZ1->(dbSetOrder(1))
    If SZ1->(dbSeek(xFilial("SZ1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))

        If SZ1->Z1_LIB != "S"
            MsgInfo("Esse Documento de Entrada não poderá ser classificado pois encontra-se pendente para validação ou bloqueado.", "MT100CLA")
            return .f.
        End

        //Manoel, 24/dez/20
        //somente mostrar informaçoes dos vencimentos e observaçes
        
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
        cTxtInfo+=SZ1->Z1_OBS

        MsgInfo(cTxtInfo,'Informações do Gestor')
        

    EndIf
EndIf

Return lRet
*/
