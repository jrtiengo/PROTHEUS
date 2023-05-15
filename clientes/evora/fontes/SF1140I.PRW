/*
PE utilizado para atualizacao do cabecalho do pre doc entrada
Ezequiel Pianegonda
07/11/2020
*/
User Function SF1140I()
	Local aArea:= GetArea()
	If ! SuperGetMV('ES_PPFRE',.F.,.F.)
		RETURN
	end

	If INCLUI.or.altera
		dbSelectArea('SZ1')
		dbSetOrder(1)
		If dbSeek(xFilial("SZ1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)
			RecLock("SZ1", .f.)
		else
			RecLock("SZ1", .T.)
		end

		nTotal:=u_fQueTotal() //precisa estar em cima da SF1

        /*
        dbSelectArea('SD1')
        dbSetOrder(1)
        dbSeek(xFilial('SD1')+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
        while xFilial('SD1')+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA .AND. !EOF()
            nTotal+=SD1->D1_TOTAL
            DBSKIP()
        end
        */

		//dbSelectArea('SZ1')
		//RecLock("SZ1", .T.)
		SZ1->Z1_FILIAL:= xFilial("SZ1")
		SZ1->Z1_DOC:= SF1->F1_DOC
		SZ1->Z1_SERIE:= SF1->F1_SERIE
		SZ1->Z1_FORNECE:= SF1->F1_FORNECE
		SZ1->Z1_LOJA:= SF1->F1_LOJA
		SZ1->Z1_LIB:= "P"
		SZ1->Z1_NOMFOR:=SA2->A2_NOME
		SZ1->Z1_VALOR:=nTotal

		SZ1->(MsUnLock())
	EndIf

//envia WF para gestores avisando sobre documento pendente de validação
	IF EXISTBLOCK('EVOA607')
		lOk:=U_EVOA607()

		dbSelectArea("SF1")
		RecLock("SF1",.F.)
		If lOk
			SF1->F1_EMAILOK:='1'
		ELSE
			SF1->F1_EMAILOK:='2'
		END
		MsUnLock()
	END

	RestArea(aArea)
Return
