#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FB602MDT  º Autor ³ Ezequiel Pianegondaº Data ³  14/07/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Relatorio de entrega de EPC.                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FB602MDT()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	Local cDesc1	:= "Este programa tem como objetivo imprimir relatorio "
	Local cDesc2	:= "de acordo com os parametros informados pelo usuario."
	Local cDesc3	:= "Comprovante de entrega de EPC"
	Local cPict		:= ""
	Local titulo	:= "Comprovante de entrega de EPC"
	Local nLin		:= 80
	Local Cabec1	:= ""
	Local Cabec2	:= ""
	Local imprime	:= .T.
	Local aOrd		:= {}

	Private lEnd			:= .F.
	Private lAbortPrint	:= .F.
	Private CbTxt			:= ""
	Private limite			:= 132
	Private tamanho		:= "M"
	Private nomeprog		:= "FB602MDT" // Coloque aqui o nome do programa para impressao no cabecalho
	Private nTipo			:= 18
	Private aReturn		:= { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
	Private nLastKey		:= 0
	Private cbtxt			:= Space(10)
	Private cbcont			:= 00
	Private CONTFL			:= 01
	Private m_pag			:= 01
	Private wnrel			:= "FB602MDT" // Coloque aqui o nome do arquivo usado para impressao em disco
	Private cString		:= "ZZD"

	dbSelectArea("ZZD")
	dbSetOrder(1)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn,cString)

	If nLastKey == 27
		Return
	Endif

	nTipo := If(aReturn[4]==1,15,18)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Processamento. RPTSTATUS monta janela com a regua de processamento. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
	Return

	/*/
	ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
	±±ºFun‡„o    ³RUNREPORT º Autor ³ Ezequiel Pianegondaº Data ³  14/07/2011 º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºDescri‡„o ³ Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTATUS º±±
	±±º          ³ monta a janela com a regua de processamento.               º±±
	±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
	±±ºUso       ³ Programa principal                                         º±±
	±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
	±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
	ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
	/*/

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
	Local nOrdem
	Local nX:= 0
	Local aDados:= IIF(Type("_aDados")=="U", {}, _aDados)

	dbSelectArea(cString)
	dbSetOrder(1)

//inicio uma nova pagina
	Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
	nLin := 6

//crio o cabecalho
	Cabecalho(@nLin)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SETREGUA -> Indica quantos registros serao processados para a regua ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SetRegua(Len(aDados))

	For nX:= 1 To Len(aDados)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o cancelamento pelo usuario...                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If lAbortPrint
			@nLin,00 PSAY "*** CANCELADO PELO OPERADOR ***"
			Exit
		Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao do cabecalho do relatorio. . .                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,nTipo)
			nLin := 6
		Endif
		dbSelectArea("ZZD")
		dbSetOrder(1)
		dbGoTo(aDados[nx])

		Posicione("SB1", 1, xFilial("SB1")+ZZD_CODEPC, "B1_COD")

		@nLin, 00 PSAY PADR("|"+PADR(ZZD_CODEPC, 15)+"  "+PADR(SB1->B1_DESC, 35)+" "+DtoC(ZZD_DTENTR)+"    "+ZZD_HRENTR+"     "+Transform(ZZD_QTDENT, "@e 99,99")+"   "+IIF(ZZD_INDDEV=="1", "SIM", "NAO")+"   "+DtoC(ZZD_DTDEVO)+"   "+Left(ZZD_SERIE, 6)+"   Ass: ______________", 131)+"|"

		nLin := nLin + 1 // Avanca a linha de impressao

	Next nX

//termo de responsabilidade
	Termo(@nLin)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a execucao do relatorio...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	SET DEVICE TO SCREEN

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se impressao em disco, chama o gerenciador de impressao...          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	If aReturn[5]==1
		dbCommitAll()
		SET PRINTER TO
		OurSpool(wnrel)
	Endif

	MS_FLUSH()

	Return

Static Function Cabecalho(nLin)
	Local aArea:= GetArea()
	Local cQuery:= ""
	Local cAli:= GetNextAlias()
	Local cCC:= ""

	cQuery:= " SELECT * "
	cQuery+= " FROM "+RetSqlName("ZZ4")+" ZZ4, "
	cQuery+= "      "+RetSqlName("AA1")+" AA1, "
	cQuery+= "      "+RetSqlName("CTT")+" CTT "
	cQuery+= " WHERE AA1_CODTEC = '"+cEquipe+"' AND "
	cQuery+= "       CTT_CUSTO = AA1_CC AND "
	cQuery+= "      "+RetSqlCond("ZZ4")+" AND "
	cQuery+= "      "+RetSqlCond("AA1")+" AND "
	cQuery+= "      "+RetSqlCond("CTT")

	TCQuery ChangeQuery(cQuery) New Alias cAli
	cCC:= Alltrim(cAli->CTT_CUSTO)+" - "+cAli->CTT_DESC01

	cAli->(dbCloseArea())

	@nLin, 00 PSAY "|"+Replic("-", 130)+"|"
	nLin++
	@nLin, 00 PSAY PADR("|Empresa...: "+PADR(SM0->M0_NOMECOM, 30)+SPACE(40)+"CGC..:"+PADR(SM0->M0_CGC, 14)+SPACE(7), 131)+"|"
	nLin++
	@nLin, 00 PSAY PADR("|Filial....: "+SM0->M0_CODFIL+" - "+SM0->M0_NOME, 131)+"|"
	nLin++
	@nLin, 00 PSAY PADR("|Endereco..: "+PADR(SM0->M0_ENDCOB, 30)+SPACE(40)+"Cidade:"+SM0->M0_CIDCOB+" - "+SM0->M0_ESTCOB, 131)+"|"
	nLin++
	@nLin, 00 PSAY "|"+Replic("-", 130)+"|"
	nLin++
	@nLin, 00 PSAY PADR("|Equipe.........: "+cEquipe+" - "+cNomeEq, 131)+"|"
//nLin++
//@nLin, 00 PSAY PADR("|Funcionario....: ", 131)+"|"
	nLin++
	@nLin, 00 PSAY PADR("|Centro de custo: "+cCC, 131)+"|"
//nLin++
//@nLin, 00 PSAY PADR("|Funcao.........: ", 131)+"|"
//nLin++
//@nLin, 00 PSAY PADR("|Nascimento.....: "+SPACE(65)+"Admissao:"+SPACE(20)+"Idade:"+SPACE(8), 131)+"|"
	nLin++
	@nLin, 00 PSAY "|"+Replic("-", 130)+"|"
	nLin++
	@nLin, 00 PSAY PADR("|EPC              Nome do EPC                         Dt.Entr     Hora       Qtde   Dev.  Dt.Devo   Num.Serie", 131)+"|"
	nLin++

	RestArea(aArea)
	Return

Static Function Termo(nLin)
	Local cTermo:= fBuscaCpo("TMZ", 1, xFilial("TMZ")+"000002", "TMZ_DESCRI")
	Local aTermo:= _MSG(cTermo, 130)
	Local nX:= 0

	@nLin, 00 PSAY "|"+Replic("-", 130)+"|"
	nLin++
	@nLin, 00 PSAY PADR("|"+SPACE(52)+"TERMO DE RESPONSABILIDADE", 131)+"|"
	nLin++
	For nX:= 1 To Len(aTermo)

		If nLin > 55 // Salto de Página. Neste caso o formulario tem 55 linhas...
			Cabec("","","","FB602MDT","M",18)
			nLin := 6
		Endif

		@nLin, 00 PSAY PADR("|"+aTermo[nX], 131)+"|"
		nLin++
	Next nX
	@nLin, 00 PSAY "|"+Replic("-", 130)+"|"
	nLin++
	@nLin, 00 PSAY "|"+Replic(" ", 130)+"|"
	nLin++
	@nLin, 00 PSAY PADR("|     Data: ____/____/____", 131)+"|"
	nLin++
	@nLin, 00 PSAY "|"+Replic(" ", 130)+"|"
	nLin++
	@nLin, 00 PSAY PADR("|     Assinatura: __________________________"+SPACE(40)+"RespEmpr: __________________________", 131)+"|"
	nLin++
	@nLin, 00 PSAY "|"+Replic(" ", 130)+"|"
	nLin++
	@nLin, 00 PSAY "|"+Replic("-", 130)+"|"
	Return

Static Function _MSG(_cObs, _nTam)
	Local _aMsg := {}
	Local _i    := 0

	_cObs := StrTran(_cObs, " ", ";")
	Do While At(";;", _cObs) != 0
		_cObs := StrTran(_cObs, ";;", ";")
	EndDo

	_aObs := {}
	Do While Len(_cObs) > 0
		If At(";", _cObs) != 0
			AADD(_aObs, SubStr(_cObs, 1, At(";", _cObs) -1))
			_cObs := Stuff(_cObs, 1, At(";", _cObs), "")
		Else
			AADD(_aObs, AllTrim(_cObs))
			_cObs := ""
		EndIf
	EndDo

	_cObs := ""
	For _i := 1 To Len(_aObs)
		if Len(_cObs + cValToChar(_aObs[_i])) > _nTam
			AADD(_aMsg, Padr(_cObs,_nTam))
			_cObs := _aObs[_i] + " "
		Else
			_cObs := _cObs + _aObs[_i] + " "
		EndIf
	Next _i

	If AllTrim(_cObs) != ""
		AADD(_aMsg, Padr(_cObs,_nTam))
	EndIf

	Return _aMsg
