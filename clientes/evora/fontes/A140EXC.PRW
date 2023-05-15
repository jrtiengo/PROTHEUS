/*
Valida a exclusao de um pre documento de entrada
Ezequiel Pianegonda
07/11/2020
*/
User Function A140EXC()
Local lRet:= .T.
Local aArea:= GetArea()
	If ! SuperGetMV('ES_PPFRE',.F.,.F.)
		RETURN lret
	end
aSZ1:= SZ1->(GetArea())

SZ1->(dbSetOrder(1))
If SZ1->(dbSeek(xFilial("SZ1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
    RecLock("SZ1", .F.)
    SZ1->(dbDelete())
    SZ1->(MsUnLock())
EndIf

RestArea(aSZ1)
RestArea(aArea)
Return lRet
