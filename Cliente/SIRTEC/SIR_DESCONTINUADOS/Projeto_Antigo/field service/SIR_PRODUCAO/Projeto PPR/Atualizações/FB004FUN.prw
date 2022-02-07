#Include 'Protheus.ch'

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Programa  � FB004FUN � Autor � Felipe S. Raota             � Data � 30/04/14  ���
��������������������������������������������������������������������������������Ĵ��
���Unidade   � TRS              �Contato � felipe.raota@totvs.com.br             ���
��������������������������������������������������������������������������������Ĵ��
���Descricao � Fun��o de Busca: 000004. Busca indicador conforme par�metros(SZL) ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � Especifico para cliente Sirtec - Projeto PPR                      ���
��������������������������������������������������������������������������������Ĵ��
���Analista  �  Data  � Manutencao Efetuada                                      ���
��������������������������������������������������������������������������������Ĵ��
���          �  /  /  �                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

User Function FB004FUN(cMesAno, cTipo, cUnid, cTpSep, cMat)

Local aArea := GetArea()
Local xRet := 0
Local sPFim := ""

sPFim := Right(Alltrim(cMesAno),4) + Left(Alltrim(cMesAno),2) + "16"

dbSelectArea("SZL")

If cTpSep == "U"
	SZL->(dbSetOrder(1))
ElseIf cTpSep == "S"
	SZL->(dbSetOrder(2))
	
	cUnid := ""
	
	If Select("DEPT") <> 0
		DEPT->(dbCloseArea())
	Endif
	
	cQuery := " SELECT TOP 1 SRE.RE_DEPTOP "
	cQuery += " FROM "+RetSqlName("SRE")+" SRE "
	cQuery += " WHERE " + RetSqlCond("SRE")
	cQuery += "   AND SRE.RE_MATD = '"+cMat+"'"  
	cQuery += "   AND SRE.RE_DATA <= '"+sPFim+"' "
	cQuery += " ORDER BY SRE.RE_DATA DESC "
	
	MemoWrite("C:\temp\qryDEPT.txt", cQuery)
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "DEPT", .F., .T.)
	
	If !DEPT->(EoF())
		cUnid := DEPT->RE_DEPTOP
	Endif
	
	If Empty(cUnid)
		cUnid := fBuscaCPO("SRA", 1, xFilial("SRA") + cMat, "RA_DEPTO" )
	Endif
	
	_cRefLog := cUnid
	
	DEPT->(dbCloseArea())
	
Else
	Return 0
Endif

If !Empty(cUnid)
	If SZL->(MsSeek( xFilial("SZL") + cMesAno + cTipo + cUnid ))
		xRet := SZL->ZL_VALOR
	Else
		xRet := 0
	Endif
Else
	xRet := 0
Endif

restArea(aArea)

Return xRet