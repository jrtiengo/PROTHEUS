#Include 'Totvs.ch'
#Include 'Rwmake.ch'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FB006PPR ³ Autor ³ Felipe S. Raota             ³ Data ³ 10/04/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Unidade   ³ TRS              ³Contato ³ felipe.raota@totvs.com.br             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de Variação de Metas.                                    ³±±
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

User Function FB006PPR(cGrp, cInd)

Local oDlg, oSay1, oSay2, oSay3, oSay4, oSay5, oTGet, oTGet2, oPane1, oPane2, oPane3, oTButton1, oTButton2, oTButton3
Local aColsZA  := {}
Local aYesAlt  := {"ZA_CODFUN", "ZA_OPER1", "ZA_CHAV1", "ZA_OPER2", "ZA_CHAV2", "ZA_CODFUN2", "ZA_OPERFIL", "ZA_CHAVFIL", "ZA_VALREF", "ZA_TPDADO", "ZA_TPDADO2"}
Local aYesCmp  := {"ZA_CODFUN", "ZA_OPER1", "ZA_CHAV1", "ZA_OPER2", "ZA_CHAV2", "ZA_CODFUN2", "ZA_OPERFIL", "ZA_CHAVFIL", "ZA_VALREF", "ZA_TPDADO", "ZA_TPDADO2"}
Local aSizeAut := MsAdvSize()

Local oFont14	 := TFont():New( "Arial",,14,,.F.,,,,,.F. )
Local oFont16N := TFont():New( "Arial",,16,,.T.,,,,,.F. )
Local oFont22N := TFont():New( "Arial",,22,,.T.,,,,,.F. )

Local lMenu := .F.

Private oGDVarM
Private aHeadZA  := {}

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

dbSelectArea("SZ8")
SZ8->(dbSetOrder(1))

aHeadZA := U_GeraHead("SZA",.T.,,aYesCmp,.T.)

DEFINE MSDIALOG oDlg TITLE "Cadastro de Variação de Metas"  From 00,00 To 520,1000 OF oMainWnd PIXEL
	
	// Painel 1
	oPane1 := TPanel():New(_aPosObj[1,1],_aPosObj[1,2],"",oDlg,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,080),_aPosObj[1,3],_aPosObj[1,4],.F.,.F.)
	
	oSay1 	:= TSay():New(003,002,{||"Grupo PPR: "  },oPane1,,oFont16N,,,,.T.,CLR_WHITE,CLR_WHITE,200,10)
	oTGet  := TGet():New(002,040,{|u| If(Pcount()>0,(cCodGrp:=u,_GetDesc(oSay2, 1, oSay4), _GerCols(@aColsZA)),cCodGrp) },oPane1,030,008,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,{|| ExistCpo("SZ4", cCodGrp) .OR. Empty(cCodGrp)},.F.,.F.,"SZ4",cCodGrp,,,, )
	oSay2  := TSay():New(003,080,{|| cDescGrp },oPane1,,oFont14,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	
	oSay3 	:= TSay():New(018,002,{||"Indicador: "  },oPane1,,oFont16N,,,,.T.,CLR_WHITE,CLR_WHITE,200,10)
	oTGet2 := TGet():New(017,040,{|u| If(Pcount()>0,(cCodInd:=u, _GetDesc(oSay4, 2), _GerCols(@aColsZA)),cCodInd) },oPane1,030,008,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,{|| ExistCpo("SZ5", cCodGrp+cCodInd) .OR. Empty(cCodInd)},.F.,.F.,"SZ5",cCodInd,,,, )
	oSay4  := TSay():New(018,080,{|| cDescInd },oPane1,,oFont14,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	
	oSay5 	:= TSay():New(012,350,{||"_Variação de Metas_" },oPane1,,oFont22N,,,,.T.,CLR_WHITE,CLR_WHITE,200,10)
	
	// Painel 2
	oPane2  := TPanel():New(_aPosObj[2,1],_aPosObj[2,2],"",oDlg,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,030),_aPosObj[2,3],_aPosObj[2,4],.F.,.F.)
	    
	oGDVarM := MsNewGetDados():New(_aPosObj[4,1],_aPosObj[4,2],_aPosObj[4,4],_aPosObj[4,3],GD_UPDATE+GD_INSERT+GD_DELETE,"U_006PPRLOK()",/*Tok*/,,aYesAlt,/*freeze*/,,/*fieldok*/,/*superdel*/,,oPane2,aHeadZA,aColsZA)
	oGDVarM:Disable()
	
	// Painel 3
	oPane3 	:= TPanel():New(_aPosObj[3,1],_aPosObj[3,2],"",oDlg,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,080),_aPosObj[3,3],_aPosObj[3,4],.F.,.F.)
	
	oTButton1 	:= TButton():New( 02, 010, "&Gravar", oPane3,{|| _GrvVMet(@oSay2, @oSay4, @oTGet, @oTGet2) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton2 	:= TButton():New( 02, 055, "&Limpar", oPane3,{|| _CleanScr(@oSay2, @oSay4, @oTGet, @oTGet2) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	oTButton3 	:= TButton():New( 02, 450, "&Fechar", oPane3,{|| oDlg:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	If lMenu
		_GetDesc(oSay2, 1, oSay4)
		_GetDesc(oSay4, 2)
		
		_GerCols(@aColsZA)	
	Endif
		
	
ACTIVATE MSDIALOG oDlg CENTERED

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GerCols   ³ Autor ³ Felipe S. Raota            ³ Data ³ 10/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Gera linhas do aCols para a grid.                                 ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB006PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GerCols(aC)

If !Empty(cCodGrp) .AND. !Empty(cCodInd)
	
	If SZ4->(MsSeek( xFilial("SZ4") + cCodGrp ))
		
		If SZ5->(MsSeek( xFilial("SZ5") + cCodGrp + cCodInd ))
			
			If SZA->(MsSeek( xFilial("SZA") + cCodGrp + cCodInd ))
				
				aC := {}
				
				While SZA->(!EoF()) .AND. xFilial("SZA") + cCodGrp + cCodInd == SZA->ZA_FILIAL + SZA->ZA_CODGRP + SZA->ZA_CODIND
					
					aADD(aC, {SZA->ZA_CODFUN, SZA->ZA_OPER1, SZA->ZA_CHAV1, SZA->ZA_OPER2, SZA->ZA_CHAV2, SZA->ZA_CODFUN2, SZA->ZA_OPERFIL, SZA->ZA_CHAVFIL, SZA->ZA_VALREF, SZA->ZA_TPDADO, SZA->ZA_TPDADO2, .F.})
					
					SZA->(dbSkip())
				Enddo
				
				_GetDadHab(aC, .T.)
				
			Else
				aC := {}
				aADD(aC, U_LinVazia(aHeadZA))
				_GetDadHab(aC, .T.)
			Endif
			
		Else
			aC := {}
			aADD(aC, U_LinVazia(aHeadZA))
			_GetDadHab(aC, .F.)
		Endif
	
	Else
		aC := {}
		aADD(aC, U_LinVazia(aHeadZA))
		_GetDadHab(aC, .F.)
	Endif

Else
	aC := {}
	
	// Validação pode ser executada antes de criar o objeto.
	If TYPE("oGDVarM") == "O"
		oGDVarM:Disable()
	Endif
	
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GetDesc   ³ Autor ³ Felipe S. Raota            ³ Data ³ 10/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Busca descrição do Grupo e Indicador se houver.                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB006PPR                                                          ³±±
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
				aADD(aC, U_LinVazia(aHeadZA))
				_GetDadHab(aC, .F.)
			Endif
		
		Else
			aC := {}
			aADD(aC, U_LinVazia(aHeadZA))
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
				aADD(aC, U_LinVazia(aHeadZA))
				_GetDadHab(aC, .F.)
			Endif
		
		Else
			aC := {}
			aADD(aC, U_LinVazia(aHeadZA))
			_GetDadHab(aC, .F.)
		Endif
		
EndCase

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ 006PPRLOK  ³ Autor ³ Felipe S. Raota            ³ Data ³ 10/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Valida linha do aCols.                                            ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB006PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function 006PPRLOK()

Local aAux := oGDVarM:aCols
Local lOk  := .T.

// Valida Código da Função
If lOk
	
	If !Empty(GDFieldGet("ZA_CODFUN"))
		
		If !SZ8->(MsSeek( xFilial("SZ8") + GDFieldGet("ZA_CODFUN") ))
			lOk := .F.
			Alert("Código da Função não existe.")
		Endif
		
	Endif
	
Endif

// Valida Operação2 com Chave2
If lOk
	
	If !Empty(GDFieldGet("ZA_OPER2"))
		
		If GDFieldGet("ZA_CHAV2") == 0
			lOk := .F.
			Alert("Quando utilizado Operação 2, obrigatório preenchimento da Chave 2.")
		Endif
		
	Endif
	
Endif

// Valida Valor2 com Chave2
If lOk
	
	If !Empty(GDFieldGet("ZA_CHAV2"))
		
		If GDFieldGet("ZA_OPER2") == 0
			lOk := .F.
			Alert("Quando utilizada Chave 2, obrigatório preenchimento da Operação 2.")
		Endif
		
	Endif
	
Endif

Return lOk

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _006TOK    ³ Autor ³ Felipe S. Raota            ³ Data ³ 10/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Valida aCols completo.                                            ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB006PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _006TOK()

Local aAux  := oGDVarM:aCols
Local aAux2 := oGDVarM:aCols
Local cCod  := ""
Local lOk   := .T.
Local cInd  := ""

For _y:=1 to len(aAux2)
	
	If !GdDeleted(_y, aHeadZA, aAux2)
		
		cCod := Alltrim("Linha: " + Alltrim(Str(_y)))
		
		lOk := U_ObrColsPPR(_y, aHeadZA, aAux2, Alltrim(cCod))
		
		If !lOk
			EXIT
		Endif
		
		// Valida Código da Função
		If lOk
			
			If !Empty(GDFieldGet( "ZA_CODFUN", _y, .F., aHeadZA, aAux2 ))
				
				If !SZ8->(MsSeek( xFilial("SZ8") + GDFieldGet( "ZA_CODFUN", _y, .F., aHeadZA, aAux2 ) ))
					lOk := .F.
					Alert(cCod + " -> Código da Função não existe.")
				Endif
				
			Endif
			
		Endif
		
		// Valida Operação2 com Chave2
		If lOk
			
			If !Empty(GDFieldGet( "ZA_OPER2", _y, .F., aHeadZA, aAux2 ))
				
				If GDFieldGet( "ZA_CHAV2", _y, .F., aHeadZA, aAux2 ) == 0
					lOk := .F.
					Alert(cCod + " -> Quando utilizado Operação 2, obrigatório preenchimento da Chave 2.")
					EXIT
				Endif
				
			Endif
			
		Endif
		
		// Valida Chave2 com Operação2
		If lOk
			
			If !Empty(GDFieldGet( "ZA_CHAV2", _y, .F., aHeadZA, aAux2 ))
				
				If Empty(GDFieldGet( "ZA_OPER2", _y, .F., aHeadZA, aAux2 ))
					lOk := .F.
					Alert(cCod + " -> Quando utilizada Chave 2, obrigatório preenchimento da Operação 2.")
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
±±³Função    ³ _GrvVMet    ³ Autor ³ Felipe S. Raota            ³ Data ³ 10/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Efetua gravação dos dados.                                        ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB006PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GrvVMet(oSay2, oSay4, oTGet, oTGet2)

_aC := oGDVarM:aCols

If _006TOK()
	
	If SZA->(MsSeek( xFilial("SZA") + cCodGrp + cCodInd ))
		
		While SZA->(!EoF()) .AND. xFilial("SZA") + cCodGrp + cCodInd == SZA->ZA_FILIAL + SZA->ZA_CODGRP + SZA->ZA_CODIND
		
			RecLock("SZA", .F.)
				SZA->(dbDelete())
			MsUnLock()
			
			SZA->(dbSkip())
		Enddo
		
	Endif
	
	For _x:=1 to len(_aC)
		
		If !GdDeleted(_x, aHeadZA, _aC)
			
			RecLock("SZA", .T.)
				
				SZA->ZA_FILIAL   := xFilial("SZA")
				SZA->ZA_CODGRP   := cCodGrp
				SZA->ZA_CODIND   := cCodInd
				SZA->ZA_CODFUN   := GDFieldGet( "ZA_CODFUN",  _x, .F., aHeadZA, _aC )
				SZA->ZA_OPER1    := GDFieldGet( "ZA_OPER1",   _x, .F., aHeadZA, _aC )
				SZA->ZA_CHAV1    := GDFieldGet( "ZA_CHAV1",   _x, .F., aHeadZA, _aC )
				SZA->ZA_OPER2    := GDFieldGet( "ZA_OPER2",   _x, .F., aHeadZA, _aC )
				SZA->ZA_CHAV2    := GDFieldGet( "ZA_CHAV2",   _x, .F., aHeadZA, _aC )
				SZA->ZA_CODFUN2  := GDFieldGet( "ZA_CODFUN2", _x, .F., aHeadZA, _aC )
				SZA->ZA_OPERFIL  := GDFieldGet( "ZA_OPERFIL", _x, .F., aHeadZA, _aC )
				SZA->ZA_CHAVFIL  := GDFieldGet( "ZA_CHAVFIL", _x, .F., aHeadZA, _aC )
				SZA->ZA_VALREF   := GDFieldGet( "ZA_VALREF",  _x, .F., aHeadZA, _aC )
				SZA->ZA_TPDADO   := GDFieldGet( "ZA_TPDADO",  _x, .F., aHeadZA, _aC )
				SZA->ZA_TPDADO2  := GDFieldGet( "ZA_TPDADO2", _x, .F., aHeadZA, _aC )
				
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
	
	aColsZA := {}
	aADD(aColsZA, U_LinVazia(aHeadZA))
	_GetDadHab(aColsZA, .F.)
	
	MsgInfo("Variação de Metas gravadas com sucesso.")

Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _CleanScr  ³ Autor ³ Felipe S. Raota            ³ Data ³ 10/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Efetua gravação dos dados.                                        ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB006PPR                                                          ³±±
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

aColsZA := {}
aADD(aColsZA, U_LinVazia(aHeadZA))
_GetDadHab(aColsZA, .F.)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GetDadHab ³ Autor ³ Felipe S. Raota            ³ Data ³ 10/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Habilita ou Desabilita GetDados                                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB006PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GetDadHab(aC, lHab)

aColsZA := aC
oGDVarM:aCols := aColsZA
oGDVarM:ForceRefresh()

If lHab
	oGDVarM:Enable()
Else
	oGDVarM:Disable()
Endif

Return