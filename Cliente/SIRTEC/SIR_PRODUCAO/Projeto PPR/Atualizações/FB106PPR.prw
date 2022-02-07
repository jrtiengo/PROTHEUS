#Include 'Totvs.ch'
#Include 'Topconn.ch'
#Include "Poncalen.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FB106PPR ³ Autor ³ Felipe S. Raota             ³ Data ³ 20/05/14  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Unidade   ³ TRS              ³Contato ³ felipe.raota@totvs.com.br             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina de gera dados para a query de Horas Trabalhadas p/ BSC     ³±±
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

User Function FB106PPR()

Local cCadastro := "Horas Trabalhadas BSC"
Local aSays     := {}
Local aButtons  := {}
Local nOpca     := 0

Private cPerg := PADR("FB106PPR", 10," ") //PADR("FB106PPR", LEN(SX1->X1_GRUPO)," ")

Private _aErroHora := {}
Private _aDados := {}
Private _aDadTec := {}
Private _aMeses := {}

aADD(aSays, "   Este programa tem como objetivo de gerar informações de Horas Trabalhadas      ")
aADD(aSays, "   para utilização no BSC.                                                        ")
aADD(aSays, "                                                                                  ")

aADD(aButtons, {1, .T., {|| (nOpca := 1, FechaBatch()) }})
aADD(aButtons, {2, .T., {|| (nOpca := 2, FechaBatch()) }})

FormBatch(cCadastro, aSays, aButtons)

If nOpca == 1

	// Gera Arq. Trab. temporário para OS's
	_GeraTrab()

	// Gera Arq. Trab. temporário para Horas Trabalhadas por Dia
	_GeraTrab2()

	If Pergunte(cPerg,.T.)

		MakeSqlExpr(cPerg)

		// Executa consulta que retorna totais por Equipe
		Processa({|| _ExecQuery() }, "Aguarde...", "Efetuando Busca de informações.", .T.)

		// Busca Horas Trabalhadas dos técnicos através do Registro do Ponto
		Processa({|| _HorasTrab() }, "Aguarde...", "Buscando Horas Trabalhadas.", .T.)

		// Agrupa informações p/ técnico
		Processa({|| _AgrupaInf() }, "Aguarde...", "Gerando informações p/ Equipes.", .T.)

		For _x:=1 to len(_aMeses)
			TcSQLExec("UPDATE "+RetSqlName("SZO")+" SET D_E_L_E_T_ = '*' WHERE ZO_MESANO = '"+ _aMeses[_x] +"'")
		Next

		For _x:=1 to len(_aDadTec)

			RecLock("SZO", .T.)
				SZO->ZO_FILIAL := xFilial("SZO")
				SZO->ZO_MESANO := _aDadTec[_x,1]
				SZO->ZO_CC     := _GetCC(xFilial("SRA"), _aDadTec[_x,3], _aDadTec[_x,1])
				SZO->ZO_EQUIPE := _aDadTec[_x,2]
				SZO->ZO_MAT    := _aDadTec[_x,3]
				SZO->ZO_HORAS  := _aDadTec[_x,4]
			MsUnLock()

		Next

	Endif

Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GeraTrab  ³ Autor ³ Felipe S. Raota            ³ Data ³ 19/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Cria Arquivo de Trabalho temporário.                              ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB104PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GeraTrab()

Local aCampos := {}
Local aCampos2 := {}

Private _cTRB1	 := GetNextAlias() //Alias Tabela Temporária

// Tabela para Produtividade
aADD(aCampos,{"FILIAL"  ,"C",TamSX3("ZZ5_FILIAL")[1],0})
aADD(aCampos,{"EQUIPE"  ,"C",TamSX3("ZZ5_EQUIPE")[1],0})
aADD(aCampos,{"CODTEC"  ,"C",TamSX3("ZZ5_CODTEC")[1],0})
aADD(aCampos,{"DTCHEG"  ,"C",TamSX3("ZZ5_DTCHEG")[1],0})
aADD(aCampos,{"FATOR"   ,"N",TamSX3("ABC_VALOR")[1],TamSX3("ABC_VALOR")[2]})
aADD(aCampos,{"HORAS"   ,"N",TamSX3("ABC_VALOR")[1],TamSX3("ABC_VALOR")[2]})

//-------------------
//Criação do objeto
//-------------------
If (Select(_cTRB1) > 0)
    oTempTab1:Delete()
EndIf
oTempTab1 := FWTemporaryTable():New( _cTRB1, aCampos  )
oTempTab1:AddIndex("01", {aCampos[1] + aCampos[3] + aCampos[4]} )
oTempTab1:Create()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GeraTrab2 ³ Autor ³ Felipe S. Raota            ³ Data ³ 21/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Cria Arquivo de Trabalho temporário para Horas/Dia dos técnicos.  ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB104PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GeraTrab2()

Local aCampos := {}

Private _cTRB2	 := GetNextAlias() //Alias Tabela Temporária

//Cria arquivo temporário
aADD(aCampos,{"FILIAL" ,"C",TamSX3("P8_FILIAL")[1],0})
aAdd(aCampos,{"MAT"    ,"C",TamSX3("P8_MAT")[1],0})
aAdd(aCampos,{"DTPON"  ,"C",TamSX3("P8_DATA")[1],0})
aAdd(aCampos,{"HORA"   ,"N",TamSX3("P8_HORA")[1],TamSX3("P8_HORA")[2]})


//-------------------
//Criação do objeto
//-------------------
If (Select(_cTRB2) > 0)
    oTempTab2:Delete()
EndIf
oTempTab2 := FWTemporaryTable():New( _cTRB2, aCampos  )
oTempTab2:AddIndex("01", {aCampos[1] + aCampos[2] + aCampos[3]} )
oTempTab2:Create()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _ExecQuery ³ Autor ³ Felipe S. Raota            ³ Data ³ 19/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Cria Arquivo de Trabalho temporário.                              ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB104PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _ExecQuery()

Local cQry := ""
Local _CRLF := Chr(13) + Chr(10)

Local nQtdReg := 0

// ***********************
// Retorno de Informações
// ***********************

cQry += " SELECT DISTINCT ZZ5.ZZ5_FILIAL, ZZ5.ZZ5_EQUIPE, ZZ5.ZZ5_CODTEC, ZZ5_DTCHEG, " + _CRLF
cQry += " " + _CRLF
cQry += "	(SELECT COUNT(*) " + _CRLF
cQry += "	 FROM " + _CRLF
cQry += "	 (	 SELECT DISTINCT FAT.ZZ5_EQUIPE " + _CRLF
cQry += "		 FROM "+RetSqlName("ZZ5")+" FAT " + _CRLF
cQry += "		 WHERE FAT.D_E_L_E_T_ = ' ' " + _CRLF
cQry += "		   AND FAT.ZZ5_FILIAL = '01' " + _CRLF
cQry += "		   AND FAT.ZZ5_CODTEC = ZZ5.ZZ5_CODTEC " + _CRLF
cQry += "		   AND FAT.ZZ5_DTCHEG = ZZ5.ZZ5_DTCHEG " + _CRLF
cQry += "	 ) TRB ) as EQP_DIA " + _CRLF
cQry += "  " + _CRLF
cQry += " FROM "+RetSqlName("ZZ5")+" ZZ5 INNER JOIN "+RetSqlName("SRA")+" SRA ON ZZ5.ZZ5_CODTEC = SRA.RA_MAT " + _CRLF
cQry += " WHERE ZZ5.ZZ5_FILIAL = '01' " + _CRLF
cQry += "   AND ZZ5.D_E_L_E_T_ = ' ' " + _CRLF
cQry += "   AND SRA.RA_FILIAL = '01' " + _CRLF
cQry += "   AND SRA.D_E_L_E_T_ = ' ' " + _CRLF
cQry += "   AND ZZ5.ZZ5_DTCHEG BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' " + _CRLF
cQry += " 	AND ZZ5.ZZ5_CODTEC BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' " + _CRLF
cQry += " ORDER BY ZZ5.ZZ5_FILIAL, ZZ5.ZZ5_CODTEC, ZZ5.ZZ5_DTCHEG " + _CRLF

MemoWrite("C:\temp\BSC_BUSCA_06.txt", cQry)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"IND",.F.,.T.)
TCSetField ("IND", "ZZ5_DTCHEG", "D")

COUNT TO nQtdReg
ProcRegua(nQtdReg)

IND->(dbGoTop())

While IND->(!EoF())

	IncProc("Processando Matrícula: " + IND->ZZ5_CODTEC)

	(_cTRB1)->(DBAppend())
		(_cTRB1)->FILIAL  := IND->ZZ5_FILIAL
		(_cTRB1)->EQUIPE  := IND->ZZ5_EQUIPE
		(_cTRB1)->CODTEC  := IND->ZZ5_CODTEC
		(_cTRB1)->DTCHEG  := DtoS(IND->ZZ5_DTCHEG)
		(_cTRB1)->FATOR   := IND->EQP_DIA
		(_cTRB1)->HORAS   := 0.00
	(_cTRB1)->(DBCommit())

	If aScan(_aDados, {|x| Alltrim(x) == Alltrim(IND->ZZ5_CODTEC) }) == 0
		aADD(_aDados, IND->ZZ5_CODTEC)
	Endif

	IND->(dbSkip())
Enddo

IND->(dbCloseArea())

// Adiciona Funcionários que não fazem parte de equipe.

dbSelectArea("SRA")
SRA->(dbSetOrder(1))

While !SRA->(EoF())

	If SRA->RA_MAT >= MV_PAR03 .AND. SRA->RA_MAT <= MV_PAR04

		If aScan(_aDados, {|x| Alltrim(x) == Alltrim(SRA->RA_MAT) }) == 0
			aADD(_aDados, SRA->RA_MAT)
		Endif

	Endif

	SRA->(dbSkip())
Enddo

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _HorasTrab ³ Autor ³ Felipe S. Raota            ³ Data ³ 19/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Verifica ponto dos técnicos para saber as horas trabalhadas em    ³±±
±±³          ³ cada Ordem de Serviço.                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB104PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _HorasTrab()

// Define Variaveis Locais (Basicas)
Local aArea       := GetArea()
Local cString     := 'SRA'
Local wnRel       := ""
Local aFilesOpen  :={"SP5", "SPN", "SP8", "SPG","SPB","SPL","SPC", "SPH", "SPF"}
Local bCloseFiles := {|cFiles| If( Select(cFiles) > 0, (cFiles)->( DbCloseArea() ), NIL) }

// Define Variaveis Private(Basicas)
Private aReturn  := {'Zebrado' , 1, 'Administracao' , 2, 2, 1, '',1 }
Private nomeprog := "FB106PPR"
Private nLastKey := 0

// Define variaveis Private utilizadas no programa RDMAKE ImpEsp
Private aImp      := {}
Private _aTotal   := {}
Private aTotais   := {}
Private aAbonados := {}
Private nImpHrs   := 0

// Variaveis Utilizadas na funcao IMPR
Private Titulo   := OemToAnsi('Horas trabalhadas p/ Dia' )
Private nTamanho := 'P'

// Define Variaveis Private(Programa)
Private dPerIni  := Ctod("//")
Private dPerFim  := Ctod("//")
Private cMenPad1 := Space(30)
Private cMenPad2 := Space(19)
Private cIndCond := ''
Private cFilSPA	 := IF(Empty(xFilial("SPA")),Space(02),SRA->RA_FILIAL)
Private cFor     := ''
Private nOrdem   := 0
Private cAponFer := ''
Private aInfo    := {}
Private aTurnos  := {}
Private aPrtTurn := {}
Private nColunas := 0
Private dEnvIni  := Ctod("//")
Private dEnvFim  := Ctod("//")

Private lTerminal := .F.

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Parametro MV_COLMARC										   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
nColunas := SuperGetmv("MV_COLMARC")
IF ( nColunas == NIL )
	Help("", 1, "MVCOLNCAD")
	Return( .F. )
EndIF


// Calcula Tamanho e Tipo de Impressao de modo a conter  integralmente o cabecalho.
IF ( nColunas < 5 )
	nTamanho		:= "M"
	aReturn[4]	:= 1
Else
	nTamanho		:= "G"
	aReturn[4]	:= 1
EndIF

// O numero de colunas eh sempre aos pares
nColunas *= 2

// Define a Ordem do Arquivo Principal SRA
nOrdem := 2

// Carregando variaveis mv_par?? para Variaveis do Sistema.
FilialDe    := '  '			//Filial  De
FilialAte   := 'ZZ'			//Filial  Ate
CcDe        := '                    '			//Centro de Custo De
CcAte       := 'ZZZZZZZZZZZZZZZZZZZZ'			//Centro de Custo Ate
TurDe       := '   '			//Turno De
TurAte      := 'ZZZ'			//Turno Ate
MatDe       := '      '		//Matricula De
MatAte      := '      '		//Matricula Ate
NomDe       := '                              '			//Nome De
NomAte      := 'ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ'			//Nome Ate
cSit        := ' ADFT'				//Situacao
cCat        := 'ACDEGHIJMPST   '	//Categoria
nImpHrs     := 3				//Imprimir horas Calculadas/Inform/Ambas/NA
nImpAut     := 3				//Demonstrar horas Autoriz/Nao Autorizadas
nCopias     := 1				//N£mero de Copias
lSemMarc    := .T.			//Imprime para Funcion rios sem Marcacoes
cMenPad1    := ''				//Mensagem padrao anterior a Assinatura
cMenPad2    := ''				//Mens. padrao anterior a Assinatura(Cont.)
dPerIni     := mv_par01		//Data Contendo o Inicio do Periodo de Apontamento
dPerFim     := mv_par02		//Data Contendo o Fim  do Periodo de Apontamento
lSexagenal  := .T.			//Horas em  (Sexagenal/Centesimal)
lImpRes     := .F.			//Imprime eventos a partir do resultado ?
lImpTroca   := .T.			//Imprime Descricao Troca de Turnos ou o Atual
lImpExcecao := .T.			//Imprime Descricao da Excecao no Lugar da do Afastamento
dEnvIni     := mv_par01		//Data Contendo o Inicio do Periodo de Apontamento
dEnvFim     := mv_par02		//Data Contendo o Fim  do Periodo de Apontamento

If !( nLastKey == 27 )
	Processa( { |lEnd| GetMarcPPR(@lEnd)} , Titulo )
EndIf

Return()

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _AgrupaInf ³ Autor ³ Felipe S. Raota            ³ Data ³ 24/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Agrupa informações p/ Equipe.                                     ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB104PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _AgrupaInf()

Local nPos := 0
Local nPosFat := 0
Local cEqp := ""

//ARQTRB->(dbGoTop())
dbSelectArea(_cTRB2)
dbGoTop()

_nCount := 0

COUNT TO _nCount
ProcRegua(_nCount)

//ARQTRB->(dbGoTop())
dbSelectArea(_cTRB2)
dbGoTop()

_cLogTec := ""
_nQtdDia := 1

// Somo horas do Ponto
While (_cTRB2)->(!EoF())

	//If TRB->(MsSeek( ARQTRB->FILIAL + ARQTRB->MAT + ARQTRB->DTPON ))
	If (_cTRB1)->(MsSeek( (_cTRB2)->FILIAL + (_cTRB2)->MAT + (_cTRB2)->DTPON ))


		// Vou varrer todas as equipes que ele trabalhou no dia
		//While !TRB->(EoF()) .AND. ARQTRB->FILIAL + ARQTRB->MAT + ARQTRB->DTPON == TRB->FILIAL + TRB->CODTEC + TRB->DTCHEG
		While !(_cTRB1)->(EoF()) .AND. (_cTRB2)->FILIAL + (_cTRB2)->MAT + (_cTRB2)->DTPON == (_cTRB1)->FILIAL + (_cTRB1)->CODTEC + (_cTRB1)->DTCHEG

			RecLock(_cTRB1, .F.)
				(_cTRB1)->HORAS := SomaHoras( (_cTRB1)->HORAS, ((_cTRB2)->HORA / (_cTRB1)->FATOR ))
			(_cTRB1)->(MsUnLock())

			(_cTRB1)>(dbSkip())
		Enddo

	Else

		If (_cTRB2)->HORA > 0  //If ARQTRB->HORA > 0

			(_cTRB1)->(DBAppend())
				(_cTRB1)->FILIAL := (_cTRB2)->FILIAL
				(_cTRB1)->EQUIPE := ""
				(_cTRB1)->CODTEC := (_cTRB2)->MAT
				(_cTRB1)->DTCHEG := (_cTRB2)->DTPON
				(_cTRB1)->FATOR  := 1
				(_cTRB1)->HORAS  := (_cTRB2)->HORA
			(_cTRB1)->(DBCommit())

		Endif
	Endif

	(_cTRB2)->(dbSkip())
Enddo

dbSelectArea(_cTRB1)
dbGoTop()

While !(_cTRB1)->(EoF())

	_cMesAno := ""

	If Val(Right(Alltrim((_cTRB1)->DTCHEG),2)) >= 16
		_sDtAux := DtoS(MonthSum(StoD((_cTRB1)->DTCHEG),1))
		_cMesAno := Left(_sDtAux,6)
	Else
		_cMesAno := Left((_cTRB1)->DTCHEG,6)
	Endif

	If aScan(_aMeses, {|x| x == _cMesAno }) == 0
		aADD(_aMeses, _cMesAno)
	Endif

	_nPosAux := aScan(_aDadTec, {|x| x[1] == _cMesAno .AND. x[2] == (_cTRB1)->EQUIPE .AND. x[3] == (_cTRB1)->CODTEC .AND. x[5] == (_cTRB1)->FILIAL })

	If _nPosAux == 0
		aADD(_aDadTec, {_cMesAno, (_cTRB1)->EQUIPE, (_cTRB1)->CODTEC, (_cTRB1)->HORAS, (_cTRB1)->FILIAL})
	Else
		_aDadTec[_nPosAux, 4] := SomaHoras(_aDadTec[_nPosAux, 4], (_cTRB1)->HORAS)
	Endif

	(_cTRB1)->(dbSkip())
Enddo

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ 104PPRGRV  ³ Autor ³ Felipe S. Raota            ³ Data ³ 21/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Gera espelho do ponto e retorna Vetor com horas trabalhadas p/Dia ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB104PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function GetMarcPPR(lEnd)

Local aComplPer	:= {}
Local aAbonosPer	:= {}
Local cFil			:= ""
Local cMat			:= ""
Local cTno			:= ""
Local cLastFil	:= "__cLastFil__"
Local cAcessaSRA	:= &("{ || " + ChkRH("PONR010","SRA","2") + "}")
Local cSeq			:= ""
Local cTurno		:= ""
Local cHtml		:= ""
Local lSPJExclu	:= !Empty( xFilial("SPJ") )
Local lSP9Exclu	:= !Empty( xFilial("SP9") )
Local nCount		:= 0.00
Local nX			:= 0.00
Local lMvAbosEve	:= .F.
Local lMvSubAbAp	:= .F.
Local cEmail		:= ""
Local cQuery		:= ""

Private aFuncFunc  := {SPACE(1), SPACE(1), SPACE(1), SPACE(1), SPACE(1), SPACE(1)}
Private aMarcacoes := {}
Private aTabPadrao := {}
Private aTabCalend := {}
Private aPeriodos  := {}
Private aId		   := {}
Private aBoxSPC	   := LoadX3Box("PC_TPMARCA")
Private aBoxSPH	   := LoadX3Box("PH_TPMARCA")
Private cHeader    := ""
Private dIniCale   := Ctod("//")	//-- Data Inicial a considerar para o Calendario
Private dFimCale   := Ctod("//")	//-- Data Final a considerar para o calendario
Private dMarcIni   := Ctod("//")	//-- Data Inicial a Considerar para Recuperar as Marcacoes
Private dMarcFim   := Ctod("//")	//-- Data Final a Considerar para Recuperar as Marcacoes
Private dIniPonMes := Ctod("//")	//-- Data Inicial do Periodo em Aberto
Private dFimPonMes := Ctod("//")	//-- Data Final do Periodo em Aberto
Private lImpAcum   := .F.

// Como a Cada Periodo Lido reinicializamos as Datas Inicial e Final preservamos-as nas variaveis: dCaleIni e dCaleFim.
dIniCale   := dPerIni   //-- Data Inicial a considerar para o Calendario
dFimCale   := dPerFim   //-- Data Final a considerar para o calendario

// Inicializa Variaveis Static
( CarExtAut() , RstGetTabExtra() )

dbSelectArea("SRA")
SRA->(dbSetOrder(nOrdem))

cEmail := ""
_nCount := 0

//COUNT TO _nCount
ProcRegua(len(_aDados))

For _z:=1 to len(_aDados)

	SRA->(dbSetOrder(1))
	If !SRA->(MsSeek(xFilial("SRA") + _aDados[_z]))
		//Alert("Não achei")
		Loop
	Endif

	IncProc("Processando Matrícula: " + SRA->RA_MAT)

	Sleep(1000) // Para mostrar processamento...

	//Processa o Cadastro de Funcionarios
	// Consiste Parametrizacao do Intervalo de Impressao
	If SRA->(!( RA_SITFOLH	$ cSit	) .OR. !(	RA_CATFUNC	$ cCat	 ) )
		//TRB2->( dbSkip() )
		Loop
	EndIf

	// Consiste a data de Demissao
	// Se o Funcionario Foi Demitido Anteriormente ao Inicio do Periodo Solicitado Desconsidera-o
	If !Empty(SRA->RA_DEMISSA) .and. ( SRA->RA_DEMISSA < dIniCale )
		Loop
	EndIf

	// Alimenta as variaveis com o conteudo dos MV_'S correspondetes
	lMvAbosEve	:= ( Upper(AllTrim(xSGetMV('SuperGetMv("MV_ABOSEVE",NIL,"N",cLastFil)'))) == "S" )
	lMvSubAbAp	:= ( Upper(AllTrim(xSGetMV('SuperGetMv("MV_SUBABAP",NIL,"N",cLastFil)'))) == "S" )

	// Atualiza a Filial Corrente
	cLastFil := SRA->RA_FILIAL

	// Carrega periodo de Apontamento Aberto
	If !CheckPonMes( @dPerIni , @dPerFim , .F. , .T. , .F. , cLastFil )
		Exit
	EndIF

	// Obtem datas do Periodo em Aberto
	GetPonMesDat( @dIniPonMes , @dFimPonMes , cLastFil )

	// Carrega as Tabelas de Horario Padrao
	If ( lSPJExclu .or. Empty( aTabPadrao ) )
		aTabPadrao := {}
		fTabTurno( @aTabPadrao , IF( lSPJExclu , cLastFil , NIL ) )
	EndIf

	// Carrega TODOS os Eventos da Filial
	IF ( Empty( aId ) .or. ( lSP9Exclu ) )
		aId := {}
		CarId( fFilFunc("SP9") , @aId , "*" )
	EndIF

	// Retorna Periodos de Apontamentos Selecionados
	dPerIni   := dIniCale
	dPerFim   := dFimCale
	aPeriodos := Monta_per( dIniCale , dFimCale , cLastFil , SRA->RA_MAT , dPerIni , dPerFim )

	// Corre Todos os Periodos
	naPeriodos := Len(aPeriodos)
	For nX := 1 To naPeriodos

		// Reinicializa as Datas Inicial e Final a cada Periodo Lido.
		// Os Valores de dPerIni e dPerFim foram preservados nas variaveis: dCaleIni e dCaleFim.
		dPerIni := aPeriodos[nX, 1]
		dPerFim := aPeriodos[nX, 2]

		// Obtem as Datas para Recuperacao das Marcacoes
		dMarcIni	:= aPeriodos[nX, 3]
		//dMarcIni	:= dPerIni
		dMarcFim	:= aPeriodos[nX, 4]
		//dMarcFim	:= dPerFim

		// Verifica se Impressao eh de Acumulado
		lImpAcum := ( dPerFim <= dFimPonMes )

		// Retorna Turno/Sequencia das Marcacoes Acumulada
		If ( lImpAcum )
			If SPF->( dbSeek( SRA->( RA_FILIAL + RA_MAT ) + Dtos( dPerIni) ) ) .and. !Empty(SPF->PF_SEQUEPA)
				cTurno	:= SPF->PF_TURNOPA
				cSeq	:= SPF->PF_SEQUEPA
			Else

				// Tenta Achar a Sequencia Inicial utilizando RetSeq()
				IF !RetSeq(cSeq,@cTurno,dPerIni,dPerFim,dDataBase,aTabPadrao,@cSeq) .or. Empty( cSeq )

					// Tenta Achar a Sequencia Inicial utilizando fQualSeq()
					cSeq := fQualSeq( NIL , aTabPadrao , dPerIni , @cTurno )
				EndIF
			EndIF

			// Obtem Codigo e Descricao da Funcao do Trabalhador na Epoca
			fBuscaCC(dMarcFim, @aFuncFunc[1], @aFuncFunc[2], Nil, .F. , .T.  )
			aFuncFunc[2]:= Substr(aFuncFunc[2], 1, 25)
			fBuscaFunc(dMarcFim, @aFuncFunc[3], @aFuncFunc[4],20, @aFuncFunc[5], @aFuncFunc[6],25, .F. )
		Else

			// Considera a Sequencia e Turno do Cadastro
			cTurno	:= SRA->RA_TNOTRAB
			cSeq	:= SRA->RA_SEQTURN

			// Obtem Codigo e Descricao da Funcao do Trabalhador
			aFuncFunc[1]:= SRA->RA_CC
			aFuncFunc[2]:= DescCc(aFuncFunc[1], SRA->RA_FILIAL, 25)
			aFuncFunc[3]:= SRA->RA_CODFUNC
			aFuncFunc[4]:= DescFun(SRA->RA_CODFUNC , SRA->RA_FILIAL)
			aFuncFunc[6]:= DescCateg(SRA->RA_CATFUNC , 25)
		EndIf

		// Carrega Arrays com as Marcacoes do Periodo (aMarcacoes), com o Calendario de Marcacoes do Periodo (aTabCalend) e com as Trocas de Turno do Funcionario (aTurnos)
		( aMarcacoes := {} , aTabCalend := {} , aTurnos := {} )

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 Importante:
		 O periodo fornecido abaixo para recuperar as marcacoes   cor
		 respondente ao periodo de apontamentoo Calendario de 	 Marca
		 coes do Periodo ( aTabCalend ) e com  as Trocas de Turno  do
		 Funcionario ( aTurnos ) integral afim de criar o  calendario
		 com as ordens correspondentes as gravadas nas marcacoes
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

		dbSelectArea("SPG")

		If !GetMarcacoes(	@aMarcacoes					,;	//Marcacoes dos Funcionarios
							@aTabCalend					,;	//Calendario de Marcacoes
							@aTabPadrao					,;	//Tabela Padrao
							@aTurnos						,;	//Turnos de Trabalho
							dPerIni 						,;	//Periodo Inicial
							dPerFim						,;	//Periodo Final
							SRA->RA_FILIAL				,;	//Filial
							SRA->RA_MAT					,;	//Matricula
							cTurno							,;	//Turno
							cSeq							,;	//Sequencia de Turno
							SRA->RA_CC						,;	//Centro de Custo
							IIF(lImpAcum,"SPG","SP8")	,;	//Alias para Carga das Marcacoes
							NIL								,;	//Se carrega Recno em aMarcacoes
							.T.								,;	//Se considera Apenas Ordenadas
							.T.    						,;	//Se Verifica as Folgas Automaticas
							.F.    			 			 ;	//Se Grava Evento de Folga Automatica Periodo Anterior
							)

			Loop
		EndIf

		aPrtTurn:={}

		aEval(aTurnos, {|x| If( x[2] >= dPerIni .AND. x[2]<= dPerFim, aADD(aPrtTurn, x),Nil )} )

		// Reinicializa os Arrays aToais e aAbonados
		( aTotais := {} , aAbonados := {} )

		// Carrega os Abonos Conforme Periodo
		fAbonosPer( @aAbonosPer , dPerIni , dPerFim , cLastFil , SRA->RA_MAT )

		// Carrega os Totais de Horas e Abonos.
		CarAboTot( @aTotais , @aAbonados , aAbonosPer, lMvAbosEve, lMvSubAbAp )

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		 Carrega o Array a ser utilizado na Impressao.
		 aPeriodos[nX,3] --> Inicio do Periodo para considerar as  marcacoes e tabela
		 aPeriodos[nX,4] --> Fim do Periodo para considerar as   marcacoes e tabela
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/

		If ( !fMontaAEsp( aTabCalend, aMarcacoes, @aImp,dMarcIni,dMarcFim, lTerminal) .AND. !( lSemMarc ) )

			MsgInfo("Não consegui montar o vetor de Horas p/ Dia")
			Loop
		EndIf

		// Reinicializa Variaveis
		aImp      := {}
		aTotais   := {}
		aAbonados := {}

	Next nX

Next _z


Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ fMontaAEsp  ³ Autor ³ Felipe S. Raota           ³ Data ³ 21/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Monta vetor com a Quantidade de Horas trabalhadas por dia.        ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB104PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function fMontaAEsp(aTabCalend, aMarcacoes, aImp,dInicio,dFim, lTerminal)

Local aDescAbono := {}
Local cTipAfas   := ""
Local cDescAfas  := ""
Local cOcorr     := ""
Local cOrdem     := ""
Local cTipDia    := ""
Local dData      := Ctod("//")
Local dDtBase    := dFim
Local lRet       := .T.
Local lFeriado   := .T.
Local lTrabaFer  := .F.
Local lAfasta    := .T.
Local nX         := 0
Local nDia       := 0
Local nMarc      := 0
Local nLenMarc   := Len( aMarcacoes )
Local nLenDescAb := Len( aDescAbono )
Local nTab       := 0
Local nContMarc  := 0
Local nDias      := 0

//-- Variaveis ja inicializadas.
aImp := {}
nDias := ( dDtBase - dInicio )

For nDia := 0 To nDias

	//-- Reinicializa Variaveis.
	dData      := dInicio + nDia
	aDescAbono := {}
	cOcorr     := ""
	cTipAfas   := ""
	cDescAfas  := ""
	cOcorr	    := ""
	_aTmp := {}

	If ( nTab := aScan(aTabCalend, {|x| x[1] == dData .and. x[4] == '1E' }) ) == 0.00
		Loop
	EndIf

	If dData < dEnvIni .or. dData > dEnvFim
		Loop
	Endif

	nMarc := aScan(aMarcacoes, { |x| x[3] == aTabCalend[nTab, 2] })

	//-- Consiste Afastamentos, Demissoes ou Transferencias.
	If ( ( lAfasta := aTabCalend[ nTab , 24 ] ) .or. SRA->( RA_SITFOLH $ 'DúT' .and. dData > RA_DEMISSA ) )
		lAfasta		:= .T.
		cTipAfas	:= IF(!Empty(aTabCalend[ nTab , 25 ]),aTabCalend[ nTab , 25 ],fDemissao(SRA->RA_SITFOLH, SRA->RA_RESCRAI) )
		cDescAfas	:= fDescAfast( cTipAfas, Nil, Nil, SRA->( RA_SITFOLH == 'D' .and. dData > RA_DEMISSA ) )
	EndIf

	//Verifica Regra de Apontamento ( Trabalha Feriado ? )
	lTrabaFer := ( PosSPA( aTabCalend[ nTab , 23 ] , cFilSPA , "PA_FERIADO" , 01 ) == "S" )

	//-- Consiste Feriados.
	If ( lFeriado := aTabCalend[ nTab , 19 ] )  .AND. !lTrabaFer
		cOcorr := aTabCalend[ nTab , 22 ]
	EndIf

	//-- Carrega Array aDescAbono com os Abonos ocorridos no Dia
	nLenDescAb := Len(aAbonados)
	For nX := 1 To nLenDescAb
		If aAbonados[nX,1] == dData
			aAdd(aDescAbono, left(aAbonados[nX,2],20)) //+ Space(1) + aAbonados[nX,3]+ Space(2) + aAbonados[nX,4])
			aadd(_aTmp,aAbonados[nX,3])
		EndIf
	Next nX

	//-- Ordem e Tipo do dia em questao.
	cOrdem  := aTabCalend[nTab,2]
	cTipDia := aTabCalend[nTab,6]
	_lDiaTrab := .T.

	//-- Se a Data da marcacao for Posterior a Admissao
	IF dData >= SRA->RA_ADMISSA
		//-- Se Afastado
		If ( lAfasta  .AND. aTabCalend[nTab,10] <> 'E' ) .OR. ( lAfasta  .AND. aTabCalend[nTab,10] == 'E' .AND. !lImpExcecao )
			cOcorr := cDescAfas
			_lDiaTrab := .F.
			//-- Se nao for Afastado
		Else

			//-- Se tiver EXCECAO para o Dia  ------------------------------------------------
			If aTabCalend[nTab,10] == 'E'
				//-- Se excecao trabalhada
				If cTipDia == 'S'
					//-- Se nao fez Marcacao
					If Empty(nMarc)
						cOcorr := '** Ausente **'
						_lDiaTrab := .F.
						//-- Se fez marcacao
					Else
						//-- Motivo da Marcacao
						If !Empty(aTabCalend[nTab,11])
							cOcorr := AllTrim(aTabCalend[nTab,11])
						Else
							cOcorr := '** Excecao nao Trabalhada **'
							_lDiaTrab := .F.
						EndIf
					Endif
					//-- Se excecao outros dias (DSR/Compensado/Nao Trabalhado)
				Else
					//-- Motivo da Marcacao
					If !Empty(aTabCalend[nTab,11])
						cOcorr := AllTrim(aTabCalend[nTab,11])
					Else
						cOcorr := '** Excecao nao Trabalhada **'
						_lDiaTrab := .F.
					EndIf
				Endif

				//-- Se nao Tiver Excecao  no Dia ---------------------------------------------------
			Else
				//-- Se feriado
				If lFeriado
					//-- Se nao trabalha no Feriado
					If !lTrabaFer
						cOcorr := If(!Empty(cOcorr),cOcorr,'** Feriado **' ) // '** Feriado **'
						_lDiaTrab := .F.
						//-- Se trabalha no Feriado
					Else
						//-- Se Dia Trabalhado e Nao fez Marcacao
						If cTipDia == 'S' .and. Empty(nMarc)
							cOcorr := '** Ausente **'
							_lDiaTrab := .F.
						ElseIf cTipDia == 'D'
							cOcorr := '** D.S.R. **'
							_lDiaTrab := .F.
						ElseIf cTipDia == 'C'
							cOcorr := '** Compensado **'
							_lDiaTrab := .F.
						ElseIf cTipDia == 'N'
							cOcorr := '** Nao Trabalhado **'
							_lDiaTrab := .F.
						EndIf
					Endif
				Else
					//-- Se Dia Trabalhado e Nao fez Marcacao
					If cTipDia == 'S' .and. Empty(nMarc)
						cOcorr := '** Ausente **'
						_lDiaTrab := .F.
					ElseIf cTipDia == 'D'
						cOcorr := '** D.S.R. **'
						_lDiaTrab := .F.
					ElseIf cTipDia == 'C'
						cOcorr := '** Compensado **'
						_lDiaTrab := .F.
					ElseIf cTipDia == 'N'
						cOcorr := '** Nao Trabalhado **'
						_lDiaTrab := .F.
					EndIf

				Endif
			Endif
		Endif
	Endif

	nLenDescAb := Len(aDescAbono)

	//-- Adiciona Nova Data a ser impressa.
	aAdd(aImp,{})
	aAdd(aImp[Len(aImp)], aTabCalend[nTab,1])

	//-- Ocorrencia na Data.
	aAdd( aImp[Len(aImp)], cOcorr)

	//-- Abono na Data.
	If ( nLenDescAb  > 0 )
		If cOcorr == '** Ausente **'
			aAdd( aImp[Len(aImp)], cOcorr ) // '** Ausente **'
		Else
			If !empty(cOcorr)
				aAdd( aImp[Len(aImp)],	Space(01))
				aAdd( aImp[Len(aImp)], cOcorr )
				aAdd( aImp,{})
				aAdd( aImp[Len(aImp)], aTabCalend[nTab,1])
				aAdd( aImp[Len(aImp)],	Space(01) )
			Else
				aAdd( aImp[Len(aImp)],	Space(01))
			Endif
		Endif

		For nX := 1 To nLenDescAb
			If nX == 1
				aAdd( aImp[Len(aImp)], aDescAbono[nX])
			Else
				aAdd(aImp, {})
				aAdd(aImp[Len(aImp)], aTabCalend[nTab,1]		)
				aAdd(aImp[Len(aImp)], Space(01)			 	)
				aAdd(aImp[Len(aImp)], aDescAbono[nX]			)
			Endif
		Next nX
	Else
		If cOcorr == '** Ausente **'
			aAdd( aImp[Len(aImp)], cOcorr)
			aAdd( aImp[Len(aImp)], Space(01))
		Else
			aAdd( aImp[Len(aImp)], Space(01))
			aAdd( aImp[Len(aImp)], cOcorr )
		Endif
	Endif

	//-- Marcacoes ocorridas na data.
	If nMarc > 0
		While nMarc <= nLenMarc .and. cOrdem == aMarcacoes[nMarc,3]
			nContMarc ++
			aAdd( aImp[Len(aImp)], StrTran(StrZero(aMarcacoes[nMarc,2],5,2),'.',':'))
			nMarc ++
		End While
	EndIf

	_aAreaX := GetArea()
	_nExtr  := 0
	_nAtra  := 0
	_nFalt  := 0
	_nSaida := 0
	_nAtest := 0
	_nTotal := 0

	DbSelectArea("SPH")
	DbSetOrder(2)
	DbGoTop()

	DbSelectArea("SPC")
	DbSetOrder(2)
	DbGoTop()

	RestArea(_aAreaX)

Next nDia

For _x:=1 to len(aImp)

	_nLen := 5 // Quando tem somente 1 entrada e 1 saída
	_nHoras := 0

	While .T.

		_aAux := aImp[_x]

		If len(_aAux) >= _nLen
			If len(_aAux) >= _nLen + 1
				_nHoras := SomaHoras(_nHoras, ElapTime(aImp[_x, (_nLen)]+":00",aImp[_x, _nLen+1]+":00"))
			Else
				aADD(_aErroHora, {SRA->RA_FILIAL, SRA->RA_MAT, aImp[_x,1], "Sem Data Final"})
			EndIf
		Else
			EXIT
		Endif

		_nLen += 2

	EndDo

	//dbSelectArea("ARQTRB")
	dbSelectArea(_cTRB2)
	(_cTRB2)->(DBAppend())
    	(_cTRB2)->FILIAL := SRA->RA_FILIAL
		(_cTRB2)->MAT    := SRA->RA_MAT
		(_cTRB2)->DTPON  := DtoS(aImp[_x,1])
		(_cTRB2)->HORA   := _nHoras
    (_cTRB2)->(DBCommit())

Next

lRet := If(nContMarc>=1,.T.,.F.)
dbSelectArea(_cTRB2)
dbGoTop()

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³CarAboTot ³ Autor ³ EQUIPE DE RH          ³ Data ³ 08/08/96 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Carrega os totais do SPC e os abonos                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ POR010IMP                                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function CarAboTot( aTotais , aAbonados , aAbonosPer, lMvAbosEve, lMvSubAbAp )

Local aTotSpc		:= {} //-- 1-SPC->PC_PD/2-SPC->PC_QUANTC/3-SPC->PC_QUANTI/4-SPC->PC_QTABONO
Local aCodAbono		:= {}
Local aJustifica	:= {} //-- Retorno fAbonos() c/Cod abono e horas abonadas.
Local cString   	:= ""
Local cFilSP9   	:= xFilial( "SP9" , SRA->RA_FILIAL )
Local cFilSRV		:= xFilial( "SRV" , SRA->RA_FILIAL )
Local cFilSPC   	:= xFilial( "SPC" , SRA->RA_FILIAL )
Local cFilSPH   	:= xFilial( "SPH" , SRA->RA_FILIAL )
Local cImpHoras 	:= If(nImpHrs==1,"C",If(nImpHrs==2,"I","*")) //-- Calc/Info/Ambas
Local cAutoriza 	:= If(nImpAut==1,"A",If(nImpAut==2,"N","*")) //-- Aut./N.Aut./Ambas
Local cAliasRes		:= IF( lImpAcum , "SPL" , "SPB" )
Local cAliasApo		:= IF( lImpAcum , "SPH" , "SPC" )
Local bAcessaSPC 	:= &("{ || " + ChkRH("PONR010","SPC","2") + "}")
Local bAcessaSPH 	:= &("{ || " + ChkRH("PONR010","SPH","2") + "}")
Local bAcessaSPB 	:= &("{ || " + ChkRH("PONR010","SPB","2") + "}")
Local bAcessaSPL 	:= &("{ || " + ChkRH("PONR010","SPL","2") + "}")
Local bAcessRes		:= IF( lImpAcum , bAcessaSPH , bAcessaSPC )
Local bAcessApo		:= IF( lImpAcum , bAcessaSPL , bAcessaSPB )
Local lCalcula	 	:= .F.
Local lExtra	 	:= .F.
Local nColSpc   	:= 0.00
Local nCtSpc    	:= 0.00
Local nQuaSpc		:= 0.00
Local nPass     	:= 0.00
Local nHorasCal 	:= 0.00
Local nHorasInf 	:= 0.00
Local nX        	:= 0.00

If ( lImpRes )
//Totaliza Codigos a partir do Resultado
	fTotalSPB(;
		@aTotSpc		,;
		SRA->RA_FILIAL	,;
		SRA->RA_Mat		,;
		dMarcIni		,;
		dMarcFim		,;
		bAcessRes		,;
		cAliasRes		,;
		cAutoriza		 ;
		)
//-- Converte as horas para sexagenal quando impressao for a partir do resultado
	If ( lSexagenal )	// Sexagenal
		For nCtSpc := 1 To Len(aTotSpc)
			For nColSpc := 2 To 4
				aTotSpc[nCtSpc,nColSpc]:=fConvHr(aTotSpc[nCtSpc,nColSpc],'H')
			Next nColSpc
		Next nCtSpc
	Endif
Endif

//Totaliza Codigos a partir do Movimento
fTotaliza(;
	@aTotSpc,;
	SRA->RA_FILIAL,;
	SRA->RA_MAT,;
	bAcessApo,;
	cAliasApo,;
	cAutoriza,;
	@aCodAbono,;
	aAbonosPer,;
	lMvAbosEve,;
	lMvSubAbAp;
	)
//-- Converte as horas para Centesimal quando impressao for a partir do apontamento
If !( lImpRes ) .and. !( lSexagenal ) // Centesimal
	For nCtSpc :=1 To Len(aTotSpc)
		For nColSpc :=2 To 4
			aTotSpc[nCtSpc,nColSpc]:=fConvHr(aTotSpc[nCtSpc,nColSpc],'D')
		Next nColSpc
	Next nCtSpc
Endif

//-- Monta Array com Totais de Horas
If nImpHrs # 4  //-- Se solicitado para Listar Totais de Horas
	For nPass := 1 To Len(aTotSpc)
		IF ( lImpRes ) //Impressao dos Resultados
//-- Se encontrar o Codigo da Verba ou For um codigo de hora extra valido de acordo com o solicitado
			If PosSrv( aTotSpc[nPass,1] , cFilSRV , NIL , 01 )
				nHorasCal 	:= aTotSpc[nPass,2] //-- Calculado - Abonado
				nHorasInf 	:= aTotSpc[nPass,3] //-- Informado
				If nHorasCal > 0 .and. cImpHoras $ 'Cú*' .or. nHorasInf > 0 .and. cImpHoras $ 'Iú*'
					cString := If(cImpHoras$'Cú*',Transform(nHorasCal, '@E 99,999.99'),Space(9)) + Space(1)
					cString += If(cImpHoras$'Iú*',Transform(nHorasInf, '@E 99,999.99'),Space(9))
					aAdd(aTotais, aTotSpc[nPass,1] + Space(1) + SRV->RV_DESC + Space(1) + cString )
				EndIf
			Endif
		ElseIf PosSP9( aTotSpc[nPass,1] , cFilSP9 , NIL , 01 )
//-- Impressao a Partir do Movimento
			nHorasCal 	:= aTotSpc[nPass,2] //-- Calculado - Abonado
			nHorasInf 	:= aTotSpc[nPass,3] //-- Informado
			If nHorasCal > 0 .and. cImpHoras $ 'Cú*' .or. nHorasInf > 0 .and. cImpHoras $ 'Iú*'
				cString := If(cImpHoras$'Cú*',Transform(nHorasCal, '@E 99,999.99'),Space(9)) + Space(1)
				cString += If(cImpHoras$'Iú*',Transform(nHorasInf, '@E 99,999.99'),Space(9))
				aAdd(aTotais, aTotSpc[nPass,1] + Space(1) + DescPDPon(aTotSpc[nPass,1], cFilSP9 ) + Space(1) + cString )
			EndIf
		EndIF
	Next nPass

//-- Acrescenta as informacoes referentes aos eventos associados aos motivos de abono
//-- Condicoes: Se nao For Impressao de Resultados
//-- 			e Se For para Imprimir Horas Calculadas ou Ambas
	If !( lImpRes ) .and. (nImpHrs == 1 .or. nImpHrs == 3)
		For nX := 1 To Len(aCodAbono)
// Converte as horas para Centesimal
			If !( lSexagenal ) // Centesimal
				aCodAbono[nX,2]:=fConvHr(aCodAbono[nX,2],'D')
			Endif
			aAdd(aTotais, aCodAbono[nX,1] + Space(1) + DescPDPon(aCodAbono[nX,1], cFilSP9) + '      0,00 '  + Transform(aCodAbono[nX,2],'@E 99,999.99') )
		Next nX
	Endif
EndIf

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fTotaliza ³ Autor ³ Mauricio MR           ³ Data ³ 27/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Totalizar as Verbas do SPC (Apontamentos) /SPH (Acumulado) ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fTotaliza(	aTotais		,;
								cFil		,;
								cMat		,;
								bAcessa 	,;
								cAlias		,;
								cAutoriza	,;
								aCodAbono	,;
								aAbonosPer	,;
								lMvAbosEve	,;
								lMvSubAbAp 	 ;
								)

Local aJustifica	:= {}
Local cCodigo		:= ""
Local cPrefix		:= SubStr(cAlias,-2)
Local cTno			:= ""
Local cCodExtras	:= ""
Local cEvento		:= ""
Local cPD			:= ""
Local cPDI			:= ""
Local cCC			:= ""
Local cTPMARCA		:= ""
Local dPD			:= Ctod("//")
Local lExtra		:= .T.
Local lAbHoras		:= .T.
Local nQuaSpc		:= 0.00
Local nX			:= 0.00
Local nEfetAbono	:= 0.00
Local nQUANTC		:= 0.00
Local nQuanti		:= 0.00
Local nQTABONO		:= 0.00

If ( cAlias )->(dbSeek( cFil + cMat ) )
	While (cAlias)->( !Eof() .and. cFil+cMat == &(cPrefix+"_FILIAL")+&(cPrefix+"_MAT") )

		dData	:= (cAlias)->(&(cPrefix+"_DATA"))  	//-- Data do Apontamento
		cPD		:= (cAlias)->(&(cPrefix+"_PD"))    	//-- Codigo do Evento
		cPDI	:= (cAlias)->(&(cPrefix+"_PDI"))     	//-- Codigo do Evento Informado
		nQUANTC	:= (cAlias)->(&(cPrefix+"_QUANTC"))  	//-- Quantidade Calculada pelo Apontamento
		nQuanti	:= (cAlias)->(&(cPrefix+"_QUANTI"))  	//-- Quantidade Informada
		nQTABONO:= (cAlias)->(&(cPrefix+"_QTABONO")) 	//-- Quantidade Abonada
		cTPMARCA:= (cAlias)->(&(cPrefix+"_TPMARCA")) 	//-- Tipo da Marcacao
		cCC		:= (cAlias)->(&(cPrefix+"_CC")) 		//-- Centro de Custos

		If (cAlias)->( !Eval(bAcessa) )
			(cAlias)->( dbSkip() )
			Loop
		EndIf

		If dData < dMarcIni .or. dDATA > dMarcFim
			(cAlias)->( dbSkip() )
			Loop
		Endif

		/*
		ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		³ Obtem TODOS os ABONOS do Evento							   ³
		ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
		//-- Trata a Qtde de Abonos
		aJustifica 	:= {} //-- Reinicializa aJustifica
		nEfetAbono	:=	0.00
		If nQuanti == 0 .and. fAbonos( dData , cPD , NIL , @aJustifica , cTPMARCA , cCC , aAbonosPer ) > 0

			//-- Corre Todos os Abonos
			For nX := 1 To Len(aJustifica)

				/*
				ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				³ Cria Array Analitico de Abonos com horas Convertidas.		   ³
				ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
				//-- Obtem a Quantidade de Horas Abonadas
				nQuaSpc := aJustifica[nX,2] //_QtAbono

				//-- Converte as horas Abonadas para Centesimal
				If !( lSexagenal ) // Centesimal
					nQuaSpc:= fConvHr(nQuaSpc,'D')
				Endif

				//-- Cria Novo Elemento no array ANALITICO de Abonos
				aAdd( aAbonados, {} )
				aAdd( aAbonados[Len(aAbonados)], dData )
				aAdd( aAbonados[Len(aAbonados)], DescAbono(aJustifica[nX,1],'C') )

				aAdd( aAbonados[Len(aAbonados)], StrTran(StrZero(nQuaSpc,5,2),'.',':') )
				aAdd( aAbonados[Len(aAbonados)], DescTpMarca(aBoxSPC,cTPMARCA))

				If !( lImpres )
					/*
					ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					³ Trata das Informacoes sobre o Evento Associado ao Motivo corrente ³
					ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
					//-- Obtem Evento Associado
					cEvento := PosSP6( aJustifica[nX,1] , SRA->RA_FILIAL , "P6_EVENTO" , 01 )
					If ( lAbHoras := ( PosSP6( aJustifica[nX,1] , SRA->RA_FILIAL , "P6_ABHORAS" , 01 ) $ " S" ) )
						//-- Se o motivo abona Horas
						If ( lAbHoras )
							If !Empty( cEvento )
								If ( nPos := aScan( aCodAbono, { |x| x[1] == cEvento } ) ) > 0
									aCodAbono[nPos,2] := __TimeSum(aCodAbono[nPos,2], aJustifica[nX,2] ) //_QtAbono
								Else
									aAdd(aCodAbono, {cEvento,  aJustifica[nX,2] }) // Codigo do Evento e Qtde Abonada
								EndIf
							Else
								/*
								ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								³ A T E N C A O: Neste Ponto deveriamos tratar o paramentro MV_ABOSEVE  ³
								³                no entanto, como ja havia a deducao abaixo e caso al-  ³
								³                guem migra-se da versao 609 com o cadastro de motivo   ³
								³                de abonos abonando horas mas sem o codigo, deixariamos ³
								³                de tratar como antes e o cliente argumentaria alteracao³
								³                de conceito.											³
								ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
								//-- Se o motivo  nao possui abono associado
								//-- Calcula o total de horas a abonar efetivamente
								nEfetAbono:= __TimeSum(nEfetAbono, aJustifica[nX,2] ) //_QtAbono
							EndIf
						Endif
					Else
						/*
						ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						³Se Motivo de Abono Nao Abona Horas e o Codigo do Evento Relaci³
						³onado ao Abono nao Estiver Vazio, Eh como se fosse uma  altera³
						³racao do Codigo de Evento. Ou seja, Vai para os Totais      as³
						³Horas do Abono que serao subtraidas das Horas Calculadas (  Po³
						³deriamos Chamar esta operacao de "Informados via Abono" ).	   ³
						³Para que esse processo seja feito o Parametro MV_SUBABAP  deve³
						³ra ter o Conteudo igual a "S"								   ³
						ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
						IF ( ( lMvSubAbAp ) .and. !Empty( cEvento ) )
							//-- Se o motivo  nao possui abono associado
							//-- Calcula o total de horas a abonar efetivamente
							If ( nPos := aScan( aCodAbono, { |x| x[1] == cEvento } ) ) > 0
								aCodAbono[nPos,2] := __TimeSum(aCodAbono[nPos,2], aJustifica[nX,2] ) //_QtAbono
							Else
								aAdd(aCodAbono, {cEvento,  aJustifica[nX,2] }) // Codigo do Evento e Qtde Abonada
							EndIf
							//-- O total de horas acumulado em nEfetAbono sera deduzido do
							//-- total de horas apontadas.
							nEfetAbono:= __TimeSum(nEfetAbono, aJustifica[nX,2] ) //_QtAbono
						Endif
					EndIf
				Endif
			Next nX
		Endif

		If !( lImpres )
			//-- Obtem o Codigo do Evento  (Informado ou Calculado)
			cCodigo:= If(!Empty(cPDI), cPDI, cPD )

			//-- Obtem a posicao no Calendario para a Data

			If ( nPos 	:= aScan(aTabCalend, {|x| x[1] ==dDATA .and. x[4] == '1E' }) ) > 0
				//-- Obtem o Turno vigente na Data
				cTno	:=	aTabCalend[nPos,14]
				//-- Carrega ou recupera os codigos correspondentes a horas extras na Data
				cCodExtras	:= ''
				CarExtAut( @cCodExtras , cTno , cAutoriza )
				lExtra:=.F.
				If cCodigo$cCodExtras
					lExtra:=.T.
				Endif
			Endif

			//-- Se o Evento for Alguma HE Solicitada (Autorizada ou Nao Autorizada)
			//-- Ou  Valido Qquer Evento (Autorizado e Nao Autorizado)
			//-- OU  Evento possui um identificador correspondente a Evento Autorizado ou Nao Autorizado.
			If lExtra .or. cAutoriza == '*' .or. (aScan(aId,{|aEvento| aEvento[1] == cCodigo .and. Right(aEvento[2],1) == cAutoriza }) > 0.00)

				//-- Procura em aTotais pelo acumulado do Evento Lido
				If ( nPos := aScan(aTotais,{|x| x[1] == cCodigo .AND. x[6] == dData }) ) > 0

					//-- Subtrai do evento a qtde de horas que efetivamente abona horas conforme motivo de abono
					aTotais[nPos,2] := __TimeSum(aTotais[nPos,2],If(nQuanti>0, 0, __TimeSub(nQUANTC,nEfetAbono)))
					aTotais[nPos,3] := __TimeSum(aTotais[nPos,3],nQuanti)
					aTotais[nPos,4] := __TimeSum(aTotais[nPos,4],nQTABONO)

				Else

					//-- Adiciona Evento em Acumulados
					//-- Subtrai do evento a qtde de horas que efetivamente abona horas conforme motivo de abono
					aAdd(aTotais,{cCodigo,If(nQuanti > 0, 0, __TimeSub(nQUANTC,nEfetAbono)), nQuanti,nQTABONO,lExtra, dData })
				Endif
			Endif
		Endif
		(cAlias)->( dbSkip() )
	End While
Endif

Return( NIL )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao	 ³fTotalSPB ³ Autor ³ EQUIPE DE RH		    ³ Data ³ 05/06/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Totaliza eventos a partir do SPB.                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Generico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function fTotalSPB(aTotais,cFil,cMat,dDataIni,dDataFim,bAcessa,cAlias)

Local cPrefix := ""

cPrefix		:= SubStr(cAlias,-2)

If ( cAlias )->( dbSeek( cFil + cMat ) )
	While (cAlias)->( !Eof() .and. cFil+cMat == &(cPrefix+"_FILIAL")+&(cPrefix+"_MAT") )

		If (cAlias)->( &(cPrefix+"_DATA") < dDataIni .or. &(cPrefix+"_DATA") > dDataFim )
			(cAlias)->( dbSkip() )
			Loop
		Endif

		If (cAlias)->( !Eval(bAcessa) )
			(cAlias)->( dbSkip() )
			Loop
		EndIf

		If ( nPos := aScan(aTotais,{|x| x[1] == (cAlias)->( &(cPrefix+"_PD") ) }) ) > 0
			aTotais[nPos,2] := aTotais[nPos,2] + (cAlias)->( &(cPrefix+"_HORAS") )
		Else
			aAdd(aTotais,{(cAlias)->( &(cPrefix+"_PD") ),(cAlias)->( &(cPrefix+"_HORAS") ),0,0 })
		Endif
		(cAlias)->( dbSkip() )
	End While
Endif

Return( NIL )


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LoadX3Box ³ Autor ³ Mauricio MR           ³ Data ³ 10.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna array da ComboBox                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCampo - Nome do Campo                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function LoadX3Box(cCampo)

Local aRet:={},nCont,nIgual
Local cCbox,cString
Local aSvArea := SX3->(GetArea())

SX3->(DbSetOrder(2))
SX3->(DbSeek(cCampo))

cCbox := SX3->(X3Cbox())

While !Empty(cCbox)
	nCont:=AT(";",cCbox)
	nIgual:=AT("=",cCbox)
	cString:=AllTrim(SubStr(cCbox,1,nCont-1)) //Opcao
	IF nCont == 0
		aAdd(aRet,{SubStr(cString,1,nigual-1),SubStr(cString,nigual+1)})
		Exit
	Else
		aAdd(aRet,{SubStr(cString,1,nigual-1),SubStr(cString,nigual+1)})
	Endif
	cCbox:=SubStr(cCbox,nCont+1)
Enddo

RestArea(aSvArea)

Return( aRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Monta_Per³ Autor ³Equipe Advanced RH     ³ Data ³          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/

Static Function Monta_Per( dDataIni , dDataFim , cFil , cMat , dIniAtu , dFimAtu )

Local aPeriodos := {}
Local cFilSPO	:= xFilial( "SPO" , cFil )
Local dAdmissa	:= SRA->RA_ADMISSA
Local dPerIni   := Ctod("//")
Local dPerFim   := Ctod("//")

SPO->( dbSetOrder( 1 ) )
SPO->( dbSeek( cFilSPO , .F. ) )
While SPO->( !Eof() .and. PO_FILIAL == cFilSPO )

	dPerIni := SPO->PO_DATAINI
	dPerFim := SPO->PO_DATAFIM

	//-- Filtra Periodos de Apontamento a Serem considerados em funcao do Periodo Solicitado
	IF dPerFim < dDataIni .OR. dPerIni > dDataFim
		SPO->( dbSkip() )
		Loop
	Endif

	//-- Somente Considera Periodos de Apontamentos com Data Final Superior a Data de Admissao
	IF ( dPerFim >= dAdmissa )
		aAdd( aPeriodos , { dPerIni , dPerFim , Max( dPerIni , dDataIni ) , Min( dPerFim , dDataFim ) } )
	Else
		Exit
	EndIF

	SPO->( dbSkip() )

End While


IF ( aScan( aPeriodos , { |x| x[1] == dIniAtu .and. x[2] == dFimAtu } ) == 0.00 )
	dPerIni := dIniAtu
	dPerFim	:= dFimAtu
	IF !(dPerFim < dDataIni .OR. dPerIni > dDataFim)
		IF ( dPerFim >= dAdmissa )
			aAdd(aPeriodos, { dPerIni, dPerFim, Max(dPerIni,dDataIni), Min(dPerFim,dDataFim) } )
		EndIF
	Endif
EndIF


Return( aPeriodos )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³DescTPMarc³ Autor ³ Mauricio MR           ³ Data ³ 10.12.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna Descricao do Tipo da Marcacao                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aBox     - Array Contendo as Opcoes do Combox Ja Carregadas³±±
±±³          ³ cTpMarca - Tipo da Marcacao                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Ponr010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß/*/
Static Function DescTpMarca(aBox,cTpMarca)

Local aTpMarca:={},cRet:='',nTpMarca:=0
//-- SE Existirem Opcoes Realiza a Busca da Marcacao
If Len(aBox)>0
   nTpmarca:=aScan(aBox,{|xtp| xTp[1] == cTpMarca})
   cRet:=If(nTpMarca>0,aBox[nTpmarca,2],"")
Endif

Return( cRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CarExtAut³ Autor ³ Mauricio MR           ³ Data ³ 24/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna Relacao de Horas Extras por Filial/Turno           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cCodExtras --> String que Contem ou Contera os Codigos     ³±±
±±³          ³ cTnoCad    --> Turno conforme o Dia                        ³±±
±±³          ³ cAutoriza  --> "*" Horas Autorizadas/Nao Autorizadas       ³±±
±±³          ³                "A" Horas Autorizadas                       ³±±
±±³          ³                "N" Horas Nao Autorizadas                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PONM010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CarExtAut( cCodExtras , cTnoCad , cAutoriza )

Local aTabExtra		:= {}
Local cFilSP4		:= fFilFunc("SP4")
Local cTno			:= ""
Local lFound		:= .F.
Local lRet			:= .T.
Local nX			:= 0
Local naTabExtra	:= 0
Local ncTurno	    := 0.00

Static aExtrasTno

If ( PCount() == 0.00 )

	aExtrasTno	:= NIL

Else

	DEFAULT aExtrasTno	:= {}

//-- Procura Tabela (Filial + Turno corrente)
	If ( lFound	:= ( SP4->( dbSeek( cFilSP4 + cTnoCad , .F. ) ) ) )
		cTno		:=	cTnoCad
		lFound	:=	.T.
	Else
//-- Procura Tabela (Filial)
		cTno	:= Space(Len(SP4->P4_TURNO))
		lFound	:= SP4->( dbSeek(  cFilSP4 + cTno , .F.) )
	Endif

//-- Se Existe Tabela de HE
	If ( lFound )
//-- Verifica se a Tabela de HE para o Turno ainda nao foi carregada
		If (ncTurno:=aScan(aExtrasTno,{|aTurno| aTurno[1]  == cFilSP4 .and. aTurno[2] == cTno} )) == 0.00
//-- Se nao Encontrou Carrega Tabela para Filial e Turno especificos
			GetTabExtra( @aTabExtra , cFilSP4 , cTno , .F. , .F. )
//-- Posiciona no inicio da Tabela de HE da Filial Solicitada
			If !Empty(aTabExtra)
				naTabExtra:=	Len(aTabExtra)
//-- Corre Codigos de Hora Extra da Filial
				For nX:=1 To naTabExtra
//-- Se Ambos os Tipos de Eventos ou Autorizados
					If cAutoriza == '*' .or. (cAutoriza == 'A' .and. !Empty(aTabExtra[nX,4]))
						cCodExtras += aTabExtra[nX,4]+'A' //-- Cod Autorizado
					Endif
//-- Se Ambos os Tipos de Eventos ou Nao Autorizados
					If cAutoriza == '*' .or. (cAutoriza == 'N' .and. !Empty(aTabExtra[nX,5]))
						cCodExtras += aTabExtra[nX,5]+'N' //-- Cod Nao Autorizado
					EndIf
				Next nX
			Endif
//-- Cria Nova Relacao de Codigos Extras para o Turno Lido
			aAdd(aExtrasTno,{cFilSP4,cTno,cCodExtras})
		Else
//-- Recupera Tabela Anteriormente Lida
			cCodExtras:=aExtrasTno[ncTurno,3]
		Endif

	Endif

Endif

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CarId    ³ Autor ³ Mauricio MR           ³ Data ³ 24/05/02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna Relacao de Eventos da Filial						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cFil       --> Codigo da Filial desejada					  ³±±
±±³          ³ aId    	  --> Array com a Relacao	                      ³±±
±±³          ³ cAutoriza  --> "*" Horas Autorizadas/Nao Autorizadas       ³±±
±±³          ³                "A" Horas Autorizadas                       ³±±
±±³          ³                "N" Horas Nao Autorizadas                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ PONM010                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CarId( cFil , aId , cAutoriza )

Local nPos	:= 0.00

//-- Preenche o Array aCodAut com os Eventos (Menos DSR Mes Ant.)
SP9->( dbSeek( cFil , .T. ) )
While SP9->( !Eof() .and. cFil == P9_FILIAL )
	IF ( ( Right(SP9->P9_IDPON,1) == cAutoriza ) .or. ( cAutoriza == "*" ) )
		aAdd( aId , Array( 04 ) )
		nPos := Len( aId )
		aId[ nPos , 01 ] := SP9->P9_CODIGO	//-- Codigo do Evento
		aId[ nPos , 02 ] := SP9->P9_IDPON 	//-- Identificador do Ponto
		aId[ nPos , 03 ] := SP9->P9_CODFOL	//-- Codigo do da Verba Folha
		aId[ nPos , 04 ] := SP9->P9_BHORAS	//-- Evento para B.Horas
	EndIF
	SP9->( dbSkip() )
EndDo

Return( NIL )

Static Function _GetCC(cFil, cMat, cMesAno)

Local cCentro := ""
Local cQry := ""

cQry := " SELECT "
cQry += " 	ISNULL(( "
cQry += " 	 SELECT TOP 1 SRE.RE_CCP "
cQry += " 	 FROM "+RetSqlName("SRE")+" SRE "
cQry += " 	 WHERE SRE.D_E_L_E_T_ = ' ' "
cQry += " 	   AND SRE.RE_MATD = SRA.RA_MAT "
cQry += " 	   AND SRE.RE_EMPD = '"+Alltrim(cEmpAnt)+"' "
cQry += " 	   AND SRE.RE_DATA <= '"+cMesAno+"15"+"' "
cQry += " 	   AND DATEDIFF(DAY, CAST(SRE.RE_DATA as DATE),CAST('"+cMesAno+"15"+"' as DATE)) + 1 >= 15 "
cQry += " 	 ORDER BY SRE.RE_DATA DESC "
cQry += " 	),SRA.RA_CC) as UNIDADE "
cQry += " FROM "+RetSqlName("SRA")+" SRA "
cQry += " WHERE SRA.D_E_L_E_T_ = ' ' "
cQry += "   AND SRA.RA_FILIAL = '"+cFil+"' "
cQry += "   AND SRA.RA_MAT = '"+cMat+"' "

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"_CC",.F.,.T.)

MemoWrite("C:\temp\BSC_BUSCA_CC.txt", cQry)

If !_CC->(EoF())
	cCentro := _CC->UNIDADE
Endif

_CC->(dbCloseArea())

Return cCentro


//SuperGetMV - funcionalidade nao funciona em LOOP
Static Function xSGetMV(_cVar)

Local _cRet := &(_cVar)

Return(_cRet)