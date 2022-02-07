#Include 'Totvs.ch'
#Include 'Rwmake.ch'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FB005PPR ³ Autor ³ Felipe S. Raota             ³ Data ³ 09/04/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Unidade   ³ TRS              ³Contato ³ felipe.raota@totvs.com.br             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de Metas.                                                ³±±
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

User Function FB005PPR(cGrp, cInd)

Local oDlg, oSay1, oSay2, oSay3, oSay4, oSay5, oTGet, oTGet2, oPane1, oPane2, oPane3, oTButton1, oTButton2, oTButton3
Local aColsZ7  := {}
Local aYesAlt  := {"Z7_CODMETA", "Z7_OPER1", "Z7_VAL1", "Z7_OPER2", "Z7_VAL2", "Z7_PREMIO", "Z7_TPDADO"}
Local aYesCmp  := {"Z7_CODMETA", "Z7_OPER1", "Z7_VAL1", "Z7_OPER2", "Z7_VAL2", "Z7_PREMIO", "Z7_TPDADO"}
Local aSizeAut := MsAdvSize()

Local oFont14	 := TFont():New( "Arial",,14,,.F.,,,,,.F. )
Local oFont16N := TFont():New( "Arial",,16,,.T.,,,,,.F. )
Local oFont22N := TFont():New( "Arial",,22,,.T.,,,,,.F. )

Local lMenu := .F.

Private oGDMeta
Private aHeadZ7  := {}

Private _aPosObj := {{002,002,499,030},; // TPanel 1
						{034,002,499,226},; // TPanel 2
						{245,002,499,014},; // TPanel 3
						{002,002,497,209}}  // MsNewGetDados

Private cCodGrp  := cGrp 
Private cCodInd  := cInd
Private cDescGrp := Space(80)
Private cDescInd := Space(80)

cCodGrp := IIF(TYPE("cCodGrp") == "C", cCodGrp, Space(6))
cCodInd := IIF(TYPE("cCodInd") == "C", cCodInd, Space(6))

If !Empty(cCodGrp) .OR. !Empty(cCodInd)
	lMenu := .T.
Endif

dbSelectArea("SZ5")
SZ5->(dbSetOrder(1))

dbSelectArea("SZ7")
SZ7->(dbSetOrder(1))

aHeadZ7 := U_GeraHead("SZ7",.T.,,aYesCmp,.T.)

DEFINE MSDIALOG oDlg TITLE "Cadastro de Metas"  From 00,00 To 520,1000 OF oMainWnd PIXEL
	
	// Painel 1
	oPane1 := TPanel():New(_aPosObj[1,1],_aPosObj[1,2],"",oDlg,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,080),_aPosObj[1,3],_aPosObj[1,4],.F.,.F.)
	
	oSay1 	:= TSay():New(003,002,{||"Grupo PPR: "  },oPane1,,oFont16N,,,,.T.,CLR_WHITE,CLR_WHITE,200,10)
	oTGet  := TGet():New(002,040,{|u| If(Pcount()>0,(cCodGrp:=u,_GetDesc(oSay2, 1, oSay4), _GerCols(@aColsZ7)),cCodGrp) },oPane1,030,008,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,{|| ExistCpo("SZ4", cCodGrp) .OR. Empty(cCodGrp)},.F.,.F.,"SZ4",cCodGrp,,,, )
	oSay2  := TSay():New(003,080,{|| cDescGrp },oPane1,,oFont14,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	
	oSay3 	:= TSay():New(018,002,{||"Indicador: "  },oPane1,,oFont16N,,,,.T.,CLR_WHITE,CLR_WHITE,200,10)
	oTGet2 := TGet():New(017,040,{|u| If(Pcount()>0,(cCodInd:=u, _GetDesc(oSay4, 2), _GerCols(@aColsZ7)),cCodInd) },oPane1,030,008,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,{|| ExistCpo("SZ5", cCodGrp+cCodInd) .OR. Empty(cCodInd)},.F.,.F.,"SZ5",cCodInd,,,, )
	oSay4  := TSay():New(018,080,{|| cDescInd },oPane1,,oFont14,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	
	oSay5 	:= TSay():New(012,400,{||"_Metas_" },oPane1,,oFont22N,,,,.T.,CLR_WHITE,CLR_WHITE,200,10)
	
	// Painel 2
	oPane2  := TPanel():New(_aPosObj[2,1],_aPosObj[2,2],"",oDlg,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,030),_aPosObj[2,3],_aPosObj[2,4],.F.,.F.)
	    
	oGDMeta := MsNewGetDados():New(_aPosObj[4,1],_aPosObj[4,2],_aPosObj[4,4],_aPosObj[4,3],GD_UPDATE+GD_INSERT+GD_DELETE,"U_005PPRLOK()",/*Tok*/,,aYesAlt,/*freeze*/,,/*fieldok*/,/*superdel*/,,oPane2,aHeadZ7,aColsZ7)
	oGDMeta:Disable()
	
	// Painel 3
	oPane3 	:= TPanel():New(_aPosObj[3,1],_aPosObj[3,2],"",oDlg,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,080),_aPosObj[3,3],_aPosObj[3,4],.F.,.F.)
	
	oTButton1 	:= TButton():New( 02, 010, "&Gravar", oPane3,{|| _GrvMet(@oSay2, @oSay4, @oTGet, @oTGet2) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton2 	:= TButton():New( 02, 055, "&Limpar", oPane3,{|| _CleanScr(@oSay2, @oSay4, @oTGet, @oTGet2) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	oTButton3 	:= TButton():New( 02, 450, "&Fechar", oPane3,{|| oDlg:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	If lMenu
		_GetDesc(oSay2, 1, oSay4)
		_GetDesc(oSay4, 2)
		
		_GerCols(@aColsZ7)	
	Endif
		
	
ACTIVATE MSDIALOG oDlg CENTERED

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GerCols   ³ Autor ³ Felipe S. Raota            ³ Data ³ 09/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Gera linhas do aCols para a grid.                                 ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB005PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GerCols(aC)

If !Empty(cCodGrp) .AND. !Empty(cCodInd)
	
	If SZ4->(MsSeek( xFilial("SZ4") + cCodGrp ))
		
		If SZ5->(MsSeek( xFilial("SZ5") + cCodGrp + cCodInd ))
			
			If SZ7->(MsSeek( xFilial("SZ7") + cCodGrp + cCodInd ))
				
				aC := {}
				
				While SZ7->(!EoF()) .AND. xFilial("SZ7") + cCodGrp + cCodInd == SZ7->Z7_FILIAL + SZ7->Z7_CODGRP + SZ7->Z7_CODIND
					
					aADD(aC, {SZ7->Z7_CODMETA, SZ7->Z7_OPER1, SZ7->Z7_VAL1, SZ7->Z7_OPER2, SZ7->Z7_VAL2, SZ7->Z7_PREMIO, SZ7->Z7_TPDADO, .F.})
					
					SZ7->(dbSkip())
				Enddo
				
				_GetDadHab(aC, .T.)
				
			Else
				aC := {}
				aADD(aC, U_LinVazia(aHeadZ7))
				_GetDadHab(aC, .T.)
			Endif
			
		Else
			aC := {}
			aADD(aC, U_LinVazia(aHeadZ7))
			_GetDadHab(aC, .F.)
		Endif
	
	Else
		aC := {}
		aADD(aC, U_LinVazia(aHeadZ7))
		_GetDadHab(aC, .F.)
	Endif

Else
	aC := {}
	
	// Validação pode ser executada antes de criar o objeto.
	If TYPE("oGDMeta") == "O"
		oGDMeta:Disable()
	Endif
	
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GetDesc   ³ Autor ³ Felipe S. Raota            ³ Data ³ 09/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Busca descrição do Grupo e Indicador se houver.                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB005PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GetDesc(oS, nOpc, oS2)

Local aC := {}

Do Case
	
	Case nOpc == 1
		
		If !Empty(cCodGrp)
			
			If SZ4->(MsSeek( xFilial("SZ4") + cCodGrp ))
				cDescGrp := SZ4->Z4_DESC
				oS:SetText(cDescGrp)
			Else
				cDescGrp := Space(80)
				oS:SetText(cDescGrp)
				
				cDescInd := Space(80)
				oS2:SetText(cDescInd)
				
				aC := {}
				aADD(aC, U_LinVazia(aHeadZ7))
				_GetDadHab(aC, .F.)
			Endif
		
		Else
			aC := {}
			aADD(aC, U_LinVazia(aHeadZ7))
			_GetDadHab(aC, .F.)
		Endif
		
	Case nOpc == 2
		
		If !Empty(cCodGrp) .AND. !Empty(cCodInd)
			
			If SZ5->(MsSeek( xFilial("SZ5") + cCodGrp + cCodInd ))
				cDescInd := SZ5->Z5_DESC
				oS:SetText(cDescInd)
			Else
				cDescInd := Space(80)
				oS:SetText(cDescInd)
				
				aC := {}
				aADD(aC, U_LinVazia(aHeadZ7))
				_GetDadHab(aC, .F.)
			Endif
		
		Else
			aC := {}
			aADD(aC, U_LinVazia(aHeadZ7))
			_GetDadHab(aC, .F.)
		Endif
		
EndCase

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ 005PPRLOK  ³ Autor ³ Felipe S. Raota            ³ Data ³ 09/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Valida linha do aCols.                                            ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB005PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function 005PPRLOK()

Local aAux := oGDMeta:aCols
Local lOk  := .T.

Local nPosCod := GdFieldPos("Z7_CODMETA")

// Valida Código da Meta
For _x:=1 to len(aAux)
	
	If !GdDeleted(_x, aHeadZ7, aAux)
		
		If _x <> n
			If GDFieldGet("Z7_CODMETA") == aAux[_x,nPosCod]
				lOk := .F.
			Endif
		Endif
		
	Endif

Next

If !lOk
	Alert("Não é permitido código de metas iguais.")
Endif

// Valida Operação2 com Valor2
If lOk
	
	If !Empty(GDFieldGet("Z7_OPER2"))
		
		If GDFieldGet("Z7_VAL2") == 0
			lOk := .F.
			Alert("Quando utilizado Operação 2, obrigatório preenchimento do Valor 2.")
		Endif
		
	Endif
	
Endif

// Valida Valor2 com Operação2
If lOk
	
	If !Empty(GDFieldGet("Z7_OVal2"))
		
		If GDFieldGet("Z7_OPER2") == 0
			lOk := .F.
			Alert("Quando utilizado Valor 2, obrigatório preenchimento da Operação 2.")
		Endif
		
	Endif
	
Endif

Return lOk

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _003TOK    ³ Autor ³ Felipe S. Raota            ³ Data ³ 09/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Valida aCols completo.                                            ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB005PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _005TOK()

Local aAux  := oGDMeta:aCols
Local aAux2 := oGDMeta:aCols
Local lOk   := .T.
Local cCod  := ""
Local cInd  := ""

Local nPosCod := GdFieldPos("Z7_CODMETA", aHeadZ7)

For _y:=1 to len(aAux2)
	
	If !GdDeleted(_y, aHeadZ7, aAux2)
		
		cCod := Alltrim(GDFieldGet( "Z7_CODMETA", _y, .F., aHeadZ7, aAux2 ))
		
		lOk := U_ObrColsPPR(_y, aHeadZ7, aAux2, "Meta: " + Alltrim(cCod))
		
		If !lOk
			EXIT
		Endif
		
		If lOk
		
			// Valida Código da Meta
			For _x:=1 to len(aAux)
				
				If !GdDeleted(_x, aHeadZ7, aAux)
				
					If _x <> _y // Testa registro posicionado e se está deletado
						If GDFieldGet( "Z7_CODMETA", _y, .F., aHeadZ7, aAux2 ) == aAux[_x,nPosCod]
							lOk := .F.
						Endif
					Endif
					
				Endif
			
			Next
			
			If !lOk
				Alert("Não é permitido código de metas iguais.")
				EXIT
			Endif
		
		Endif
		
		// Valida Operação2 com Valor2
		If lOk
			
			If !Empty(GDFieldGet( "Z7_OPER2", _y, .F., aHeadZ7, aAux2 ))
				
				If GDFieldGet( "Z7_VAL2", _y, .F., aHeadZ7, aAux2 ) == 0
					lOk := .F.
					Alert(cCod + " -> Quando utilizado Operação 2, obrigatório preenchimento do Valor 2.")
					EXIT
				Endif
				
			Endif
			
		Endif
		
		// Valida Valor2 com Operação2
		If lOk
			
			If !Empty(GDFieldGet( "Z7_VAL2", _y, .F., aHeadZ7, aAux2 ))
				
				If Empty(GDFieldGet( "Z7_OPER2", _y, .F., aHeadZ7, aAux2 ))
					lOk := .F.
					Alert(cCod + " -> Quando utilizado Valor 2, obrigatório preenchimento da Operação 2.")
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
±±³Função    ³ _GrvMet    ³ Autor ³ Felipe S. Raota            ³ Data ³ 09/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Efetua gravação dos dados.                                        ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB005PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GrvMet(oSay2, oSay4, oTGet, oTGet2)

_aC := oGDMeta:aCols

If _005TOK()

	If SZ7->(MsSeek( xFilial("SZ7") + cCodGrp + cCodInd ))
		
		While SZ7->(!EoF()) .AND. xFilial("SZ7") + cCodGrp + cCodInd == SZ7->Z7_FILIAL + SZ7->Z7_CODGRP + SZ7->Z7_CODIND
		
			RecLock("SZ7", .F.)
				SZ7->(dbDelete())
			MsUnLock()
			
			SZ7->(dbSkip())
		Enddo
		
	Endif
	
	For _x:=1 to len(_aC)
		
		If !GdDeleted(_x, aHeadZ7, _aC)
			
			RecLock("SZ7", .T.)
				
				SZ7->Z7_FILIAL   := xFilial("SZ7")
				SZ7->Z7_CODGRP   := cCodGrp
				SZ7->Z7_CODIND   := cCodInd
				SZ7->Z7_CODMETA  := GDFieldGet( "Z7_CODMETA", _x, .F., aHeadZ7, _aC )
				SZ7->Z7_OPER1    := GDFieldGet( "Z7_OPER1",   _x, .F., aHeadZ7, _aC )
				SZ7->Z7_VAL1     := GDFieldGet( "Z7_VAL1",    _x, .F., aHeadZ7, _aC )
				SZ7->Z7_OPER2    := GDFieldGet( "Z7_OPER2",   _x, .F., aHeadZ7, _aC )
				SZ7->Z7_VAL2     := GDFieldGet( "Z7_VAL2",    _x, .F., aHeadZ7, _aC )
				SZ7->Z7_PREMIO   := GDFieldGet( "Z7_PREMIO",  _x, .F., aHeadZ7, _aC )
				SZ7->Z7_TPDADO   := GDFieldGet( "Z7_TPDADO",  _x, .F., aHeadZ7, _aC )
				
			MsUnLock()
		Endif
		
	Next
	
	// Grupo PPR
	cCodGrp := Space(6)
	oTGet:SetText(cCodGrp)
	
	oSay2:SetText(Space(80))
	oSay2:CtrlRefresh()
	
	// Indicador
	cCodInd := Space(6)
	oTGet2:SetText(cCodInd)
	
	oSay4:SetText(Space(80))
	oSay4:CtrlRefresh()
	
	aColsZ7 := {}
	aADD(aColsZ7, U_LinVazia(aHeadZ7))
	_GetDadHab(aColsZ7, .F.)
	
	MsgInfo("Metas gravadas com sucesso.")

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
±±³Uso       ³ FB005PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _CleanScr(oSay2, oSay4, oTGet, oTGet2)

// Grupo PPR
cCodGrp := Space(6)
oTGet:SetText(cCodGrp)

oSay2:SetText(Space(80))
oSay2:CtrlRefresh()

// Indicador
cCodInd := Space(6)
oTGet2:SetText(cCodInd)

oSay4:SetText(Space(80))
oSay4:CtrlRefresh()

aColsZ7 := {}
aADD(aColsZ7, U_LinVazia(aHeadZ7))
_GetDadHab(aColsZ7, .F.)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GetDadHab ³ Autor ³ Felipe S. Raota            ³ Data ³ 09/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Habilita ou Desabilita GetDados                                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB005PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GetDadHab(aC, lHab)

aColsZ7 := aC
oGDMeta:aCols := aColsZ7
oGDMeta:ForceRefresh()

If lHab
	oGDMeta:Enable()
Else
	oGDMeta:Disable()
Endif

Return