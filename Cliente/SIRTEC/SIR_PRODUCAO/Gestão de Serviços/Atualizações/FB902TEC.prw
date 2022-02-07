#Include"Protheus.ch"
#Include"TopConn.ch"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FB902TEC  �Autor  �Diego Peruzzo       � Data �  21/09/12   ���
�������������������������������������������������������������������������͹��
���Desc.     �Atualiza Leitura das Mensagens do PDA                       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Sirtec                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User Function FB902TEC()
Local aArea	:= GetArea()
Local cQuery:= ""

cQuery := "SELECT "
cQuery += " MSGRETORNO.CodMensagemSync, "
cQuery += " CONVERT(VarChar(10), MSGRETORNO.DtHoraLida, 112) AS DataLida, "
cQuery += " CONVERT(VarChar(10), MSGRETORNO.DtHoraLida, 108) AS HoraLida  "
cQuery += " FROM dbo.FULL_MENSAGEMRETORNO AS MSGRETORNO  "
cQuery += " 	INNER JOIN "+RetSqlTab("ZZK")+" ON  "
cQuery += " 			MSGRETORNO.CodMensagemSync = ZZK.ZZK_CODMSG "
cQuery += " WHERE ZZK.ZZK_DTRET = '' "
cQuery += "   AND ZZK.D_E_L_E_T_ <> '*' "
cQuery += "   AND ZZK.ZZK_FILIAL = '"+xFilial("ZZG")+"' "
cQuery += "   AND Empresa = '"+SM0->M0_CODIGO+"'"

TcQuery cQuery New Alias "TRBMSG"

DbSelectArea("ZZK")
DbSetOrder(2)

DbSelectArea("TRBMSG")
DbGoTop()
While !TRBMSG->(Eof())

	IF ZZK->(MsSeek(xFilial("ZZK") + TRBMSG->CodMensagemSync ))
		RecLock("ZZK",.F.)
		ZZK->ZZK_DTRET	:= StoD(TRBMSG->DataLida)
		ZZK->ZZK_HRRET	:= TRBMSG->HoraLida
		MsUnLock()
	endif

	TRBMSG->(DbSkip())
end

TRBMSG->(dbCloseArea())

RestArea(aArea)
Return