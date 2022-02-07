#Include 'Totvs.ch'
#Include 'Rwmake.ch'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FB003PPR ³ Autor ³ Felipe S. Raota             ³ Data ³ 04/04/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Unidade   ³ TRS              ³Contato ³ felipe.raota@totvs.com.br             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de Indicadores.                                          ³±±
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

User Function FB003PPR()

Local oDlg, oSay1, oSay2, oTGet, oPane1, oPane2, oPane3, oTButton1, oTButton2, oTButton3, oTButton4, oTButton5, oTButton6
Local cGrupo   := Space(6)
Local cDesc    := Space(80)
Local nOpc     := 0
Local aColsZ5  := {}
Local aYesAlt  := {"Z5_COD", "Z5_DESC", "Z5_FRMAPUR", "Z5_DIAINI", "Z5_DIAFIM", "Z5_CODFUN", "Z5_ORDEM", "Z5_INCIDEN", "Z5_TIPO", "Z5_AFERIC", "Z5_BC", "Z5_TPDADO", "Z5_INDCOND", "Z5_VALMIN", "Z5_VALBASE", "Z5_RETRO", "Z5_PERC"}
Local aYesCmp  := {"Z5_COD", "Z5_DESC", "Z5_FRMAPUR", "Z5_DIAINI", "Z5_DIAFIM", "Z5_CODFUN", "Z5_ORDEM", "Z5_INCIDEN", "Z5_TIPO", "Z5_AFERIC", "Z5_BC", "Z5_TPDADO", "Z5_INDCOND", "Z5_VALMIN", "Z5_VALBASE", "Z5_RETRO", "Z5_PERC"}
Local aSizeAut := MsAdvSize()

Local oFont14	 := TFont():New( "Arial",,14,,.F.,,,,,.F. )
Local oFont16N := TFont():New( "Arial",,16,,.T.,,,,,.F. )
Local oFont22N := TFont():New( "Arial",,22,,.T.,,,,,.F. )

Private oGetDad

Private aHeadZ5  := {}

Private _aPosObj := {{002,002,499,013},; // TPanel 1
						{017,002,499,226},; // TPanel 2
						{245,002,499,014},; // TPanel 3
						{002,002,497,209}}  // MsNewGetDados

dbSelectArea("SZ4")
SZ4->(dbSetOrder(1))

dbSelectArea("ZZ5")
SZ5->(dbSetOrder(1))

aHeadZ5 := U_GeraHead("SZ5",.T.,,aYesCmp,.T.)

DEFINE MSDIALOG oDlg TITLE "Cadastro de Indicadores"  From 00,00 To 520,1000 OF oMainWnd PIXEL
	
	// Painel 1
	oPane1 := TPanel():New(_aPosObj[1,1],_aPosObj[1,2],"",oDlg,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,080),_aPosObj[1,3],_aPosObj[1,4],.F.,.F.)
	
	oSay1 	:= TSay():New(003,002,{||"Grupo PPR: "  },oPane1,,oFont16N,,,,.T.,CLR_WHITE,CLR_WHITE,200,10)
	oTGet  := TGet():New(002,040,{|u| If(Pcount()>0,(cGrupo:=u,_GerCols(cGrupo, @aColsZ5, @cDesc, @oSay2)),cGrupo) },oPane1,030,008,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,{|| ExistCpo("SZ4", cGrupo) .OR. Empty(cGrupo)},.F.,.F.,"SZ4",cGrupo,,,, )
	
	oSay2  := TSay():New(003,080,{|| cDesc },oPane1,,oFont14,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	
	// Painel 2
	oPane2  := TPanel():New(_aPosObj[2,1],_aPosObj[2,2],"",oDlg,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,030),_aPosObj[2,3],_aPosObj[2,4],.F.,.F.)
	
	oGetDad := MsNewGetDados():New(_aPosObj[4,1],_aPosObj[4,2],_aPosObj[4,4],_aPosObj[4,3],GD_UPDATE+GD_INSERT+GD_DELETE,"U_003PPRLOK()",/*Tok*/,,aYesAlt,/*freeze*/,,/*fieldok*/,/*superdel*/,,oPane2,aHeadZ5,aColsZ5)
	oGetDad:Disable()
	
	// Painel 3
	oPane3 	:= TPanel():New(_aPosObj[3,1],_aPosObj[3,2],"",oDlg,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,080),_aPosObj[3,3],_aPosObj[3,4],.F.,.F.)
	
	oTButton1 	:= TButton():New( 02, 010, "Gravar", oPane3,{|| _GrvInd(@cGrupo, @oTGet, @oSay2) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton2 	:= TButton():New( 02, 055, "Limpar", oPane3,{|| _CleanScr(@cGrupo, @oTGet, @oSay2) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	oTButton4 	:= TButton():New( 02, 180, "Metas", oPane3,{|| U_FB005PPR(cGrupo, oGetDad:aCols[oGetDad:nAt,GdFieldPos("Z5_COD", oGetDad:aHeader)]) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton5 	:= TButton():New( 02, 225, "Variação de Metas", oPane3,{|| U_FB006PPR(cGrupo, oGetDad:aCols[oGetDad:nAt,GdFieldPos("Z5_COD", oGetDad:aHeader)]) },65,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton6 	:= TButton():New( 02, 295, "Valores Fixos", oPane3,{|| U_FB009PPR(cGrupo, oGetDad:aCols[oGetDad:nAt,GdFieldPos("Z5_COD", oGetDad:aHeader)]) },55,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	oTButton3 	:= TButton():New( 02, 450, "Sair", oPane3,{|| oDlg:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

ACTIVATE MSDIALOG oDlg CENTERED

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GerCols   ³ Autor ³ Felipe S. Raota            ³ Data ³ 04/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Gera linhas do aCols para a grid.                                 ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB003PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GerCols(cGrupo, aC, cDesc, oSay2)

If !Empty(cGrupo)
	
	If SZ4->(MsSeek( xFilial("SZ4") + cGrupo ))
		
		cDesc := SZ4->Z4_DESC
		oSay2:SetText(cDesc)
		oSay2:CtrlRefresh()
		
		If SZ5->(MsSeek( xFilial("SZ5") + cGrupo ))
			
			aC := {}
			
			While SZ5->(!EoF()) .AND. xFilial("SZ5") + cGrupo == SZ5->Z5_FILIAL + SZ5->Z5_CODGRP
				
				aADD(aC, {SZ5->Z5_COD, SZ5->Z5_DESC, SZ5->Z5_FRMAPUR, SZ5->Z5_DIAINI, SZ5->Z5_DIAFIM, SZ5->Z5_CODFUN, SZ5->Z5_ORDEM, SZ5->Z5_INCIDEN, SZ5->Z5_TIPO, SZ5->Z5_AFERIC, SZ5->Z5_BC, SZ5->Z5_TPDADO, SZ5->Z5_INDCOND, SZ5->Z5_VALMIN, SZ5->Z5_VALBASE, SZ5->Z5_RETRO, SZ5->Z5_PERC, .F.})
				
				SZ5->(dbSkip())
			Enddo
			
			oGetDad:aCols := aC
			oGetDad:ForceRefresh()
			
			oGetDad:Enable()
			
		Else
			aC := {}
			aADD(aC, U_LinVazia(aHeadZ5))
			oGetDad:aCols := aC
			oGetDad:ForceRefresh()
			oGetDad:Enable()
		Endif
		
	Else
		
		cDesc := Space(80)
		oSay2:SetText(cDesc)
		oSay2:CtrlRefresh()
		
		aC := {}
		aADD(aC, U_LinVazia(aHeadZ5))
		oGetDad:aCols := aC
		oGetDad:ForceRefresh()
		oGetDad:Disable()
	Endif

Else
	aC := {}
	
	// Validação pode ser executada antes de criar o objeto.
	If TYPE("oGetDad") == "O"
		
		oGetDad:Disable()
		
		cDesc := Space(80)
		oSay2:SetText(cDesc)
		oSay2:CtrlRefresh()
		
	Endif
	
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ 003PPRLOK  ³ Autor ³ Felipe S. Raota            ³ Data ³ 05/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Valida linha do aCols.                                            ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB003PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function 003PPRLOK()

Local aAux := oGetDad:aCols
Local lOk  := .T.

Local nPosCod := GdFieldPos("Z5_COD")

// Valida Código do Indicador
For _x:=1 to len(aAux)
	
	If !GdDeleted(_x, aHeadZ5, aAux)
		
		If _x <> n
			If GDFieldGet("Z5_COD") == aAux[_x,nPosCod]
				lOk := .F.
			Endif
		Endif
		
	Endif

Next

If !lOk
	Alert("Não é permitido código de indicadores iguais.")
Endif

// Valida Dia Inicial e Dia Final
If lOk
	
	If GDFieldGet("Z5_FRMAPUR") == "P"
		
		If Empty(GDFieldGet("Z5_DIAINI")) .OR. Empty(GDFieldGet("Z5_DIAFIM"))
			lOk := .F.
			Alert("Quando apuração for por período, obrigatório informar dia inicial e final.")
		Endif
		
	Endif
	
Endif

// Valida indicador condicional
If lOk
	
	If !Empty(GDFieldGet("Z5_INDCOND"))
		
		If GDFieldGet("Z5_INDCOND") == GDFieldGet("Z5_COD")
			lOk := .F.
			Alert("Indicador condicional não pode ser o seu próprio indicador.")
		Endif
		
	Endif
	
Endif

cInd := Alltrim(GDFieldGet("Z5_INDCOND"))

If lOk .AND. !Empty(cInd)
	
	_lAchei := .F.
	
	// Valida Código do Indicador
	For _x:=1 to len(aAux)
		
		If !GdDeleted(_x, aHeadZ5, aAux)
		
			If _x <> n  .AND. GDFieldGet( "Z5_INDCOND" ) == aAux[_x,nPosCod] // Não é ele mesmo e existe o indicador
				_lAchei := .T.
				EXIT
			Endif
		
		Endif
	
	Next
	
	If !_lAchei
		lOk := .F.
		Alert("Indicador condicional não encontrado. Primeiro o insira na lista.")
	Endif

Endif

// Valida valor mínimo com indicador condicional
If lOk
	
	If !Empty(GDFieldGet("Z5_INDCOND"))
		
		If GDFieldGet("Z5_VALMIN") == 0
			lOk := .F.
			Alert("Quando utilizado Indicador Condicional, obrigatório preenchimento do Valor Mínimo.")
		Endif
		
	Endif
	
Endif

Return lOk

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _003TOK    ³ Autor ³ Felipe S. Raota            ³ Data ³ 05/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Valida aCols completo.                                            ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB003PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _003TOK()

Local aAux  := oGetDad:aCols
Local aAux2 := oGetDad:aCols
Local lOk   := .T.
Local cCod  := ""
Local cInd  := ""

Local nPosCod := GdFieldPos("Z5_COD", aHeadZ5)

For _y:=1 to len(aAux2)
	
	If !GdDeleted(_y, aHeadZ5, aAux2)
		
		cCod := Alltrim(GDFieldGet( "Z5_COD", _y, .F., aHeadZ5, aAux2 ))
		
		lOk := U_ObrColsPPR(_y, aHeadZ5, aAux2, "Indicador: " + Alltrim(cCod))
		
		If !lOk
			EXIT
		Endif
		
		If lOk
		
			// Valida Código do Indicador
			For _x:=1 to len(aAux)
				
				If !GdDeleted(_x, aHeadZ5, aAux)
				
					If _x <> _y // Testa registro posicionado e se está deletado
						If GDFieldGet( "Z5_COD", _y, .F., aHeadZ5, aAux2 ) == aAux[_x,nPosCod]
							lOk := .F.
						Endif
					Endif
					
				Endif
			
			Next
			
			If !lOk
				Alert("Não é permitido código de indicadores iguais.")
				EXIT
			Endif
		
		Endif
		
		// Valida Dia Inicial e Dia Final
		If lOk
			
			If GDFieldGet( "Z5_FRMAPUR", _y, .F., aHeadZ5, aAux2 ) == "P"
				
				If Empty(GDFieldGet( "Z5_DIAINI", _y, .F., aHeadZ5, aAux2 )) .OR. Empty(GDFieldGet( "Z5_DIAFIM", _y, .F., aHeadZ5, aAux2 ))
					lOk := .F.
					Alert(cCod + " -> Quando apuração for por período, obrigatório informar dia inicial e final.")
					EXIT
				Endif
				
			Endif
			
		Endif
		
		// Valida Indicador Condicional
		If lOk
			
			If !Empty(GDFieldGet( "Z5_INDCOND", _y, .F., aHeadZ5, aAux2 ))
				
				If GDFieldGet( "Z5_INDCOND", _y, .F., aHeadZ5, aAux2 ) == GDFieldGet( "Z5_COD", _y, .F., aHeadZ5, aAux2 )
					lOk := .F.
					Alert(cCod + " -> Indicador condicional não pode ser o seu próprio indicador.")
					EXIT
				Endif
				
			Endif
			
		Endif
		
		// Valida existência do Indicador Condicional
		
		cInd := Alltrim(GDFieldGet( "Z5_INDCOND", _y, .F., aHeadZ5, aAux2 ))
		
		If lOk .AND. !Empty(cInd)
			
			_lAchei := .F.
			
			// Valida Código do Indicador
			For _x:=1 to len(aAux)
				
				If !GdDeleted(_x, aHeadZ5, aAux)
				
					If _x <> _y  .AND. GDFieldGet( "Z5_INDCOND", _y, .F., aHeadZ5, aAux2 ) == aAux[_x,nPosCod] // Não é ele mesmo e existe o indicador
						_lAchei := .T.
						EXIT
					Endif
				
				Endif
			
			Next
			
			If !_lAchei
				lOk := .F.
				Alert(cCod + " -> Indicador condicional não encontrado. Primeiro o insira na lista.")
				EXIT
			Endif
		
		Endif
		
		// Valida valor mínimo com indicador condicional
		If lOk
			
			If !Empty(GDFieldGet( "Z5_INDCOND", _y, .F., aHeadZ5, aAux2 ))
				
				If GDFieldGet( "Z5_VALMIN", _y, .F., aHeadZ5, aAux2 ) == 0
					lOk := .F.
					Alert(cCod + " -> Quando utilizado Indicador Condicional, obrigatório preenchimento do Valor Mínimo.")
					EXIT
				Endif
				
			Endif
			
		Endif
		
	Endif
	
Next

Return lOk

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GrvInd    ³ Autor ³ Felipe S. Raota            ³ Data ³ 05/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Efetua gravação dos dados.                                        ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB003PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GrvInd(cGrupo, oTGet, oSay2)

_aC := oGetDad:aCols

If _003TOK()

	If SZ5->(MsSeek( xFilial("SZ5") + cGrupo ))
		
		While SZ5->(!EoF()) .AND. xFilial("SZ5") + cGrupo == SZ5->Z5_FILIAL + SZ5->Z5_CODGRP
		
			RecLock("SZ5", .F.)
				SZ5->(dbDelete())
			MsUnLock()
			
			SZ5->(dbSkip())
		Enddo
		
	Endif
	
	For _x:=1 to len(_aC)
		
		If !GdDeleted(_x, aHeadZ5, _aC)
			
			RecLock("SZ5", .T.)
				
				SZ5->Z5_FILIAL   := xFilial("SZ5")
				SZ5->Z5_CODGRP   := cGrupo
				SZ5->Z5_COD      := GDFieldGet( "Z5_COD",     _x, .F., aHeadZ5, _aC )
				SZ5->Z5_DESC     := GDFieldGet( "Z5_DESC",    _x, .F., aHeadZ5, _aC )
				SZ5->Z5_FRMAPUR  := GDFieldGet( "Z5_FRMAPUR", _x, .F., aHeadZ5, _aC )
				SZ5->Z5_DIAINI   := GDFieldGet( "Z5_DIAINI",  _x, .F., aHeadZ5, _aC )
				SZ5->Z5_DIAFIM   := GDFieldGet( "Z5_DIAFIM",  _x, .F., aHeadZ5, _aC )
				SZ5->Z5_CODFUN   := GDFieldGet( "Z5_CODFUN",  _x, .F., aHeadZ5, _aC )
				SZ5->Z5_ORDEM    := GDFieldGet( "Z5_ORDEM",   _x, .F., aHeadZ5, _aC )
				SZ5->Z5_INCIDEN  := GDFieldGet( "Z5_INCIDEN", _x, .F., aHeadZ5, _aC )
				SZ5->Z5_TIPO     := GDFieldGet( "Z5_TIPO",    _x, .F., aHeadZ5, _aC )
				SZ5->Z5_AFERIC   := GDFieldGet( "Z5_AFERIC",  _x, .F., aHeadZ5, _aC )
				SZ5->Z5_BC       := GDFieldGet( "Z5_BC",      _x, .F., aHeadZ5, _aC )
				SZ5->Z5_TPDADO   := GDFieldGet( "Z5_TPDADO",  _x, .F., aHeadZ5, _aC )
				SZ5->Z5_INDCOND  := GDFieldGet( "Z5_INDCOND", _x, .F., aHeadZ5, _aC )
				SZ5->Z5_VALMIN   := GDFieldGet( "Z5_VALMIN",  _x, .F., aHeadZ5, _aC )
				SZ5->Z5_VALBASE  := GDFieldGet( "Z5_VALBASE", _x, .F., aHeadZ5, _aC )
				SZ5->Z5_RETRO    := GDFieldGet( "Z5_RETRO",   _x, .F., aHeadZ5, _aC )
				SZ5->Z5_PERC     := GDFieldGet( "Z5_PERC",    _x, .F., aHeadZ5, _aC )
				
			MsUnLock()
		Endif
		
	Next
	
	cGrupo := Space(6)
	oTGet:SetText(cGrupo)
	
	oSay2:SetText(Space(80))
	oSay2:CtrlRefresh()
	
	aColsZ5 := {}
	aADD(aColsZ5, U_LinVazia(aHeadZ5))
	oGetDad:aCols := aColsZ5
	oGetDad:ForceRefresh()
	oGetDad:Disable()
	
	MsgInfo("Indicadores gravados com sucesso.")

Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _CleanScr  ³ Autor ³ Felipe S. Raota            ³ Data ³ 09/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Efetua gravação dos dados.                                        ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB003PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _CleanScr(cGrupo, oTGet, oSay2)

cGrupo := Space(6)
oTGet:SetText(cGrupo)

oSay2:SetText(Space(80))
oSay2:CtrlRefresh()

aColsZ5 := {}
aADD(aColsZ5, U_LinVazia(aHeadZ5))
oGetDad:aCols := aColsZ5
oGetDad:ForceRefresh()
oGetDad:Disable()

Return