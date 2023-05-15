/*
PE na classificacao do documento de entrada
Ezequiel Pianegonda
07/11/2020
*/
User Function MT100CLA()
	If ! SuperGetMV('ES_PPFRE',.F.,.F.)
		RETURN
	end
	SZ1->(dbSetOrder(1))
	If SZ1->(dbSeek(xFilial("SZ1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
		If SZ1->Z1_LIB != "S"
			MsgInfo("Esse Documento de Entrada não poderá ser classificado pois encontra-se pendente para validação ou bloqueado.", "MT100CLA")
		EndIf
	EndIf
Return
