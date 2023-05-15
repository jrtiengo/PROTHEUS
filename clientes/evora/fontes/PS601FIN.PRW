#Include 'Protheus.ch'
#Include 'Topconn.ch'
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

/*
Impressao boletim pre titulo
Ezequiel Pianegonda
05/12/2020
*/

User Function PS601FIN()
	
	Private cPerg := PADR("PS601FIN", 10, " ") //PADR("PS601FIN", Len(SX1->X1_GRUPO), " ") solutio - tiengo 13/04/2023
	
	If ! SuperGetMV('ES_PPFRE',.F.,.F.)
		MsgAlert('Empresa não foi configurada para o Paper Free', 'Atenção')
		RETURN
	end


	//ValidPerg()
	If Pergunte(cPerg, .T.)
		Processa({|| RunRel()})
	Else
		MsgInfo("Cancelado pelo usuário.")
	EndIf

Return

/*
Processamento do relatorio
*/
Static Function RunRel()
	Local lAdjustToLegacy:= .F.
	Local lDisableSetup:= .T.
	Local cLocal:= "\spool\"
	Local cQuery:= ""
	Local cAli:= GetNextAlias()
	Local nCount:= 0
	Local nTot:= 0

	Private _nLin:= 10000
	Private _oPrinter:= Nil
	Private _oFont:= TFont():New("Courier",, 12,,.F.)
	Private _oFontN := TFont():New("Courier",, 12,,.T.)
	Private _nPag:= 0

	_oPrinter := FWMSPrinter():New("PS601FIN.PDF", IMP_PDF, lAdjustToLegacy, cLocal, lDisableSetup, , , , , , .F.,)
	_oPrinter:lServer:= .F.
	_oPrinter:cPathPDF:= "\spool\"
	_oPrinter:SetPortrait( )

	cQuery:= " SELECT Z3_NATUREZ, Z3_CC, Z3_VALOR, Z3_NOME, Z3_PREFIXO, Z3_NUM, Z3_PARCELA, Z3_TIPO "
	cQuery+= " FROM  "+RetSqlTab("SZ3,SE2")
	cQuery+= " WHERE "+RetSqlFil("SZ3,SE2")+" AND "
	cQuery+= "       Z3_PREFIXO = E2_PREFIXO AND "
	cQuery+= "       Z3_NUM = E2_NUM AND "
	cQuery+= "       Z3_PARCELA = E2_PARCELA AND "
	cQuery+= "       Z3_TIPO = E2_TIPO AND "
	cQuery+= "       Z3_DATA >= '"+DTOS(MV_PAR01)+"' AND "
	cQuery+= "       Z3_DATA <= '"+DTOS(MV_PAR02)+"' AND "
	cQuery+= "       "+RetSqlDel("SZ3,SE2")

	TCQuery ChangeQuery(cQuery) New Alias &(cAli)

	Count To nCount
	ProcRegua(nCount)
	&(cAli)->(dbGoTop())

	Do While !&(cAli)->(EOF())

		IncProc("Imprimindo...")
		If _nLin > 550
			Cabec()
		EndIf

		_oPrinter:Say(_nLin, 030, &(cAli)->(Z3_NATUREZ), _oFont)
		_oPrinter:Say(_nLin, 100, &(cAli)->(Z3_CC), _oFont)
		_oPrinter:Say(_nLin, 150, Alltrim(Transform(&(cAli)->(Z3_VALOR), "@e 999,999,999.99")), _oFont)
		_oPrinter:Say(_nLin, 200, &(cAli)->(Z3_PREFIXO+Z3_NUM+Z3_PARCELA+Z3_TIPO), _oFont)
		_oPrinter:Say(_nLin, 300, Alltrim(&(cAli)->(Z3_NOME)), _oFont)

		nTot+= &(cAli)->(Z3_VALOR)

		_nLin+= 15
		&(cAli)->(dbSkip())
	EndDo
	Rodap(nTot)

	_oPrinter:Setup()
	_oPrinter:Preview()

Return

/*
Cabecalho
*/
Static Function Cabec()
	_nPag++
	_nLin:= 100
	_oPrinter:EndPage()
	_oPrinter:StartPage()
	_oPrinter:Line(020, 020, 020, 565)
	_oPrinter:Line(770, 020, 770, 565)
	_oPrinter:Line(020, 020, 770, 020)
	_oPrinter:Line(020, 565, 770, 565)

	_oPrinter:SayBitmap(030, 040, FisxLogo("1"), 60, 20)
	_oPrinter:Say(040, 200, "Relatório de Fundo Fixo", _oFontN)
	_oPrinter:Say(040, 400, "No. Fundo Fixo", _oFontN)
	_oPrinter:Say(040, 520, "Pág. "+cValToChar(_nPag), _oFontN)
	_oPrinter:Say(055, 400, Alltrim(MV_PAR03), _oFontN)

	_oPrinter:Line(060, 020, 060, 565)
	_oPrinter:Say(075, 030, "Empresa", _oFontN)
	_oPrinter:Say(075, 300, "Dt.Emissão", _oFontN)
	_oPrinter:Say(075, 400, "Local", _oFontN)

	_oPrinter:Say(085, 030, SM0->M0_NOMECOM, _oFontN)
	_oPrinter:Say(085, 300, DtoC(dDataBase), _oFontN)
	_oPrinter:Say(085, 400, SM0->M0_CIDENT, _oFontN)

	_oPrinter:Line(090, 020, 090, 565)
	_oPrinter:Say(105, 030, "Natureza", _oFontN)
	_oPrinter:Say(105, 100, "C.Custo", _oFontN)
	_oPrinter:Say(105, 150, "Valor", _oFontN)
	_oPrinter:Say(105, 200, "Título", _oFontN)
	_oPrinter:Say(105, 300, "Favorecido", _oFontN)
	_oPrinter:Line(110, 020, 110, 565)
	_nLin:= 120

Return

/*
Rodape
*/
Static Function Rodap(nTot)
	_nLin:= 650
	_oPrinter:Line(_nLin, 020, _nLin, 565)
	_nLin+= 20
	_oPrinter:Say(_nLin, 030, "     Vistos de aprovação", _oFontN)
	_nLin+= 20
	_oPrinter:Say(_nLin, 030, "     _________________________", _oFontN)
	_nLin+= 10
	_oPrinter:Say(_nLin, 030, "     "+Alltrim(MV_PAR04), _oFontN)
	_nLin+= 10
	_oPrinter:Say(_nLin, 030, "     (Solicitante)", _oFont)
	_nLin+= 20
	_oPrinter:Say(_nLin, 030, "     _________________________", _oFontN)
	_nLin+= 10
	_oPrinter:Say(_nLin, 030, "     "+Alltrim(MV_PAR05), _oFontN)
	_nLin+= 10
	_oPrinter:Say(_nLin, 030, "     (Gerência/Diretoria)", _oFont)

	_nLin:= 670
	_oPrinter:Say(_nLin, 300, "Controle dos desembolsos", _oFontN)
	_nLin+= 20
	_oPrinter:Say(_nLin, 300, "Saldo Anterior", _oFontN)
	_nLin+= 20
	_oPrinter:Say(_nLin, 300, "(-) Pagamentos      "+Alltrim(Transform(nTot, "@e 999,999,999.99")), _oFontN)
	_nLin+= 20
	_oPrinter:Say(_nLin, 300, "(+) Reembolsos Rec. "+Alltrim(Transform(nTot, "@e 999,999,999.99")), _oFontN)
	_nLin+= 20
	_oPrinter:Say(_nLin, 300, "Saldo Disponível", _oFontN)

Return

/*
Criacao e validacao das perguntas

Static Function ValidPerg()
	Local aArea  := GetArea()
	Local aRegs  := {}
	Local aHelps := {}
	Local i      := 0
	Local j      := 0

	aRegs= {}
//           GRUPO  ORDEM PERGUNT                       PERSPA PERENG VARIAVL   TIPO TAM DEC PRESEL GSC  VALID           VAR01       DEF01         DEFSPA1 DEFENG1 CNT01 VAR02 DEF02        DEFSPA2 DEFENG2 CNT02 VAR03 DEF03    DEFSPA3 DEFENG3 CNT03 VAR04 DEF04 DEFSPA4 DEFENG4 CNT04 VAR05 DEF05 DEFSPA5 DEFENG5 CNT05 F3  PYME   GRPSXG  HELP  PICTURE
	AADD(aRegs, {cPerg, "01", "Período de               ?", "",    "",    "mv_ch1", "D", 01, 0,  0,     "G", "",             "mv_par01", "",           "",     "",     "",   "",   "",          "",     "",     "",   "",   "",      "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "", "",    "",     "",   ""})
	AADD(aRegs, {cPerg, "02", "Período até              ?", "",    "",    "mv_ch2", "D", 01, 0,  0,     "G", "",             "mv_par02", "",           "",     "",     "",   "",   "",          "",     "",     "",   "",   "",      "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "", "",    "",     "",   ""})
	AADD(aRegs, {cPerg, "03", "Núm. Fundo Fixo          ?", "",    "",    "mv_ch3", "C", 08, 0,  0,     "G", "",             "mv_par03", "",           "",     "",     "",   "",   "",          "",     "",     "",   "",   "",      "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "", "",    "",     "",   ""})
	AADD(aRegs, {cPerg, "04", "Solicitante              ?", "",    "",    "mv_ch4", "C", 40, 0,  0,     "G", "",             "mv_par04", "",           "",     "",     "",   "",   "",          "",     "",     "",   "",   "",      "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "", "",    "",     "",   ""})
	AADD(aRegs, {cPerg, "05", "Gerente                  ?", "",    "",    "mv_ch5", "C", 40, 0,  0,     "G", "",             "mv_par05", "",           "",     "",     "",   "",   "",          "",     "",     "",   "",   "",      "",     "",     "",   "",   "",   "",     "",     "",   "",   "",   "",     "",     "",   "", "",    "",     "",   ""})

// Definicao de textos de help (versao 7.10 em diante): uma array para cada linha.
	aHelps = {}
//            Ordem   1234567890123456789012345678901234567890    1234567890123456789012345678901234567890    1234567890123456789012345678901234567890

	DbSelectArea ("SX1")
	DbSetOrder (1)
	For i := 1 to Len (aRegs)
		If ! DbSeek (cPerg + aRegs [i, 2])
			RecLock("SX1", .T.)
		Else
			RecLock("SX1", .F.)
		Endif
		For j := 1 to FCount ()
			// Campos CNT nao sao gravados para preservar conteudo anterior.
			If j <= Len (aRegs [i]) .and. left(fieldname(j), 6) != "X1_CNT" .and. fieldname(j) != "X1_PRESEL"
				FieldPut(j, aRegs [i, j])
			Endif
		Next
		MsUnlock()
	Next

// Deleta do SX1 as perguntas que nao constam em _aRegs
	DbSeek (cPerg, .T.)
	Do While !Eof() .And. x1_grupo == cPerg
		If Ascan(aRegs, {|aVal| aVal [2] == sx1->x1_ordem}) == 0
			Reclock("SX1", .F.)
			Dbdelete()
			Msunlock()
		Endif
		Dbskip()
	enddo

// Gera helps das perguntas
	For i := 1 to Len(aHelps)
		PutSX1Help ("P." + alltrim(cPerg) + aHelps [i, 1] + ".", aHelps [i, 2], {}, {})
	Next

	Restarea(aArea)
*/

Return
