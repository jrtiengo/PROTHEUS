#Include 'Protheus.ch'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FB004FUN ³ Autor ³ Felipe S. Raota             ³ Data ³ 30/04/14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Unidade   ³ TRS              ³Contato ³ felipe.raota@totvs.com.br             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função de Busca: 000004. Busca indicador conforme parämetros(SZL) ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para cliente Sirtec - Projeto PPR                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³  Data  ³ Manutencao Efetuada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³  /  /  ³                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

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