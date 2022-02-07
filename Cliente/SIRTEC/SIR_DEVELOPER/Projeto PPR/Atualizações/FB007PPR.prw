#Include 'Totvs.ch'
#Include 'Rwmake.ch'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FB007PPR ³ Autor ³ Felipe S. Raota             ³ Data ³ 10/04/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Unidade   ³ TRS              ³Contato ³ felipe.raota@totvs.com.br             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de Bases de Cálculo Variáveis.                           ³±±
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

User Function FB007PPR()

Local oDlg, oSay1, oSay2, oSay5, oTGet, oPane1, oPane2, oPane3, oTButton1, oTButton2, oTButton3
Local aColsZC  := {}
Local aYesAlt  := {"ZC_CODFUN", "ZC_OPER1", "ZC_VAL1", "ZC_OPER2", "ZC_VAL2", "ZC_TPDADO", "ZC_QTDBC"}
Local aYesCmp  := {"ZC_CODFUN", "ZC_OPER1", "ZC_VAL1", "ZC_OPER2", "ZC_VAL2", "ZC_TPDADO", "ZC_QTDBC"}
Local aSizeAut := MsAdvSize()

Local oFont14	 := TFont():New( "Arial",,14,,.F.,,,,,.F. )
Local oFont16N := TFont():New( "Arial",,16,,.T.,,,,,.F. )
Local oFont22N := TFont():New( "Arial",,22,,.T.,,,,,.F. )

Private cPerg := PADR("FB007PPR", 10, " ") //PADR("FB007PPR", LEN(SX1->X1_GRUPO), " ")

Private oGDBaseV
Private aHeadZC  := {}

Private _aPosObj := {{002,002,499,030},; // TPanel 1
						{034,002,499,226},; // TPanel 2
						{245,002,499,014},; // TPanel 3
						{002,002,497,209}}  // MsNewGetDados

Private cCodGrp  := Space(6)
Private cDescGrp := Space(80)

ValidPerg()
If !Pergunte(cPerg,.T.)
	Return
Endif

If MV_PAR01 == 1

	dbSelectArea("SZ5")
	SZ5->(dbSetOrder(1))
	
	dbSelectArea("SZ8")
	SZ8->(dbSetOrder(1))
	
	aHeadZC := U_GeraHead("SZC",.T.,,aYesCmp,.T.)
	
	DEFINE MSDIALOG oDlg TITLE "Cadastro de Bases de Cálculo Variáveis"  From 00,00 To 520,1000 OF oMainWnd PIXEL
		
		// Painel 1
		oPane1 := TPanel():New(_aPosObj[1,1],_aPosObj[1,2],"",oDlg,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,080),_aPosObj[1,3],_aPosObj[1,4],.F.,.F.)
		
		oSay1 	:= TSay():New(003,002,{||"Grupo PPR: "  },oPane1,,oFont16N,,,,.T.,CLR_WHITE,CLR_WHITE,200,10)
		oTGet  := TGet():New(002,040,{|u| If(Pcount()>0,(cCodGrp:=u,_GetDesc(oSay2, 1), _GerCols(@aColsZC)),cCodGrp) },oPane1,030,008,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,{|| ExistCpo("SZ4", cCodGrp) .OR. Empty(cCodGrp)},.F.,.F.,"SZ4",cCodGrp,,,, )
		oSay2  := TSay():New(003,080,{|| cDescGrp },oPane1,,oFont14,,,,.T.,CLR_RED,CLR_WHITE,200,20)
		
		oSay5 	:= TSay():New(012,350,{||"_Base de Cálculo Variável_" },oPane1,,oFont22N,,,,.T.,CLR_WHITE,CLR_WHITE,200,10)
		
		// Painel 2
		oPane2  := TPanel():New(_aPosObj[2,1],_aPosObj[2,2],"",oDlg,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,030),_aPosObj[2,3],_aPosObj[2,4],.F.,.F.)
		    
		oGDBaseV := MsNewGetDados():New(_aPosObj[4,1],_aPosObj[4,2],_aPosObj[4,4],_aPosObj[4,3],GD_UPDATE+GD_INSERT+GD_DELETE,"U_007PPRLOK()",/*Tok*/,,aYesAlt,/*freeze*/,,/*fieldok*/,/*superdel*/,,oPane2,aHeadZC,aColsZC)
		oGDBaseV:Disable()
		
		// Painel 3
		oPane3 	:= TPanel():New(_aPosObj[3,1],_aPosObj[3,2],"",oDlg,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,080),_aPosObj[3,3],_aPosObj[3,4],.F.,.F.)
		
		oTButton1 	:= TButton():New( 02, 010, "&Gravar", oPane3,{|| _GrvBaseV(@oSay2, @oTGet) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		oTButton2 	:= TButton():New( 02, 055, "&Limpar", oPane3,{|| _CleanScr(@oSay2, @oTGet) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
		oTButton3 	:= TButton():New( 02, 450, "&Fechar", oPane3,{|| oDlg:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
		
	ACTIVATE MSDIALOG oDlg CENTERED

Else

	dbSelectArea("SZC")
	SZC->(dbSetOrder(1))
	
	AxCadastro("SZC", "Base de Cálculo Variável", ".T.", ".T.")

Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GerCols   ³ Autor ³ Felipe S. Raota            ³ Data ³ 10/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Gera linhas do aCols para a grid.                                 ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB007PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GerCols(aC)

If !Empty(cCodGrp)
	
	If SZ4->(MsSeek( xFilial("SZ4") + cCodGrp ))
		
		If SZC->(MsSeek( xFilial("SZC") + cCodGrp ))
			
			aC := {}
			
			While SZC->(!EoF()) .AND. xFilial("SZC") + cCodGrp == SZC->ZC_FILIAL + SZC->ZC_CODGRP
				
				aADD(aC, {SZC->ZC_CODFUN, SZC->ZC_OPER1, SZC->ZC_VAL1, SZC->ZC_OPER2, SZC->ZC_VAL2, SZC->ZC_TPDADO, SZC->ZC_QTDBC, .F.})
				
				SZC->(dbSkip())
			Enddo
			
			_GetDadHab(aC, .T.)
			
		Else
			aC := {}
			aADD(aC, U_LinVazia(aHeadZC))
			_GetDadHab(aC, .T.)
		Endif
		
	Else
		aC := {}
		aADD(aC, U_LinVazia(aHeadZC))
		_GetDadHab(aC, .F.)
	Endif

Else
	aC := {}
	
	// Validação pode ser executada antes de criar o objeto.
	If TYPE("oGDBaseV") == "O"
		oGDBaseV:Disable()
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
±±³Uso       ³ FB007PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GetDesc(oS, nOpc)

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
				
				aC := {}
				aADD(aC, U_LinVazia(aHeadZC))
				_GetDadHab(aC, .F.)
			Endif
		
		Else
			aC := {}
			aADD(aC, U_LinVazia(aHeadZC))
			_GetDadHab(aC, .F.)
		Endif
		
EndCase

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ 007PPRLOK  ³ Autor ³ Felipe S. Raota            ³ Data ³ 10/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Valida linha do aCols.                                            ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB007PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function 007PPRLOK()

Local aAux := oGDBaseV:aCols
Local lOk  := .T.

// Valida Código da Função
If lOk
	
	If !Empty(GDFieldGet("ZC_CODFUN"))
		
		If !SZ8->(MsSeek( xFilial("SZ8") + GDFieldGet("ZC_CODFUN") ))
			lOk := .F.
			Alert("Código da Função não existe.")
		Endif
		
	Endif
	
Endif

// Valida Operação2 com Chave2
If lOk
	
	If !Empty(GDFieldGet("ZC_OPER2"))
		
		If Empty(GDFieldGet("ZC_VAL2"))
			lOk := .F.
			Alert("Quando utilizado Operação 2, obrigatório preenchimento da Chave 2.")
		Endif
		
	Endif
	
Endif

// Valida Valor2 com Chave2
If lOk
	
	If !Empty(GDFieldGet("ZC_VAL2"))
		
		If Empty(GDFieldGet("ZC_OPER2"))
			lOk := .F.
			Alert("Quando utilizada Chave 2, obrigatório preenchimento da Operação 2.")
		Endif
		
	Endif
	
Endif

Return lOk

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _007TOK    ³ Autor ³ Felipe S. Raota            ³ Data ³ 10/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Valida aCols completo.                                            ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB007PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _007TOK()

Local aAux  := oGDBaseV:aCols
Local aAux2 := oGDBaseV:aCols
Local cCod  := ""
Local lOk   := .T.
Local cInd  := ""

For _y:=1 to len(aAux2)
	
	If !GdDeleted(_y, aHeadZC, aAux2)
		
		cCod := Alltrim("Linha: " + Alltrim(Str(_y)))
		
		lOk := U_ObrColsPPR(_y, aHeadZC, aAux2, "Variação de Meta: " + Alltrim(cCod))
		
		If !lOk
			EXIT
		Endif
		
		// Valida Código da Função
		If lOk
			
			If !Empty(GDFieldGet( "ZC_CODFUN", _y, .F., aHeadZC, aAux2 ))
				
				If !SZ8->(MsSeek( xFilial("SZ8") + GDFieldGet( "ZC_CODFUN", _y, .F., aHeadZC, aAux2 ) ))
					lOk := .F.
					Alert(cCod + " -> Código da Função não existe.")
				Endif
				
			Endif
			
		Endif
		
		// Valida Operação2 com Chave2
		If lOk
			
			If !Empty(GDFieldGet( "ZC_OPER2", _y, .F., aHeadZC, aAux2 ))
				
				If Empty(GDFieldGet( "ZC_VAL2", _y, .F., aHeadZC, aAux2 ))
					lOk := .F.
					Alert(cCod + " -> Quando utilizado Operação 2, obrigatório preenchimento do Valor 2.")
					EXIT
				Endif
				
			Endif
			
		Endif
		
		// Valida Chave2 com Operação2
		If lOk
			
			If !Empty(GDFieldGet( "ZC_VAL2", _y, .F., aHeadZC, aAux2 ))
				
				If Empty(GDFieldGet( "ZC_OPER2", _y, .F., aHeadZC, aAux2 ))
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
±±³Função    ³ _GrvBaseV  ³ Autor ³ Felipe S. Raota            ³ Data ³ 10/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Efetua gravação dos dados.                                        ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB007PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GrvBaseV(oSay2, oTGet)

_aC := oGDBaseV:aCols

If _007TOK()
	
	If SZC->(MsSeek( xFilial("SZC") + cCodGrp ))
		
		While SZC->(!EoF()) .AND. xFilial("SZC") + cCodGrp == SZC->ZC_FILIAL + SZC->ZC_CODGRP
		
			RecLock("SZC", .F.)
				SZC->(dbDelete())
			MsUnLock()
			
			SZC->(dbSkip())
		Enddo
		
	Endif
	
	For _x:=1 to len(_aC)
		
		If !GdDeleted(_x, aHeadZC, _aC)
			
			RecLock("SZC", .T.)
				
				SZC->ZC_FILIAL := xFilial("SZC")
				SZC->ZC_CODGRP := cCodGrp
				SZC->ZC_CODFUN := GDFieldGet( "ZC_CODFUN", _x, .F., aHeadZC, _aC )
				SZC->ZC_OPER1  := GDFieldGet( "ZC_OPER1",  _x, .F., aHeadZC, _aC )
				SZC->ZC_VAL1   := GDFieldGet( "ZC_VAL1",   _x, .F., aHeadZC, _aC )
				SZC->ZC_OPER2  := GDFieldGet( "ZC_OPER2",  _x, .F., aHeadZC, _aC )
				SZC->ZC_VAL2   := GDFieldGet( "ZC_VAL2",   _x, .F., aHeadZC, _aC )
				SZC->ZC_TPDADO := GDFieldGet( "ZC_TPDADO", _x, .F., aHeadZC, _aC )
				SZC->ZC_QTDBC  := GDFieldGet( "ZC_QTDBC",  _x, .F., aHeadZC, _aC )
				
			MsUnLock()
		Endif
		
	Next
	
	// Grupo PPR
	cCodGrp := Space(6)
	oTGet:SetText(cCodGrp)
	
	oSay2:SetText(Space(80))
	oSay2:CtrlRefresh()
	
	aColsZC := {}
	aADD(aColsZC, U_LinVazia(aHeadZC))
	_GetDadHab(aColsZC, .F.)
	
	MsgInfo("Bases de Cálculo Variáveis gravadas com sucesso.")

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
±±³Uso       ³ FB007PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _CleanScr(oSay2, oTGet)

// Grupo PPR
cCodGrp := Space(6)
oTGet:SetText(cCodGrp)

oSay2:SetText(Space(80))
oSay2:CtrlRefresh()

aColsZC := {}
aADD(aColsZC, U_LinVazia(aHeadZC))
_GetDadHab(aColsZC, .F.)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GetDadHab ³ Autor ³ Felipe S. Raota            ³ Data ³ 10/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Habilita ou Desabilita GetDados                                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB007PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GetDadHab(aC, lHab)

aColsZC := aC
oGDBaseV:aCols := aColsZC
oGDBaseV:ForceRefresh()

If lHab
	oGDBaseV:Enable()
Else
	oGDBaseV:Disable()
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ ValidPerg  ³ Autor ³ Felipe S. Raota            ³ Data ³ 24/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Grupo de Perguntas.                                               ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB007PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ValidPerg()

local _aArea  := GetArea ()
local _aRegs  := {}
local _aHelps := {}
local _i      := 0
local _j      := 0

_aRegs = {}
//           GRUPO  ORDEM PERGUNT                           PERSPA PERENG VARIAVL   TIPO TAM DEC PRESEL GSC  VALID         VAR01       DEF01     				DEFSPA1             DEFENG1             CNT01 VAR02     DEF02             	DEFSPA2             DEFENG2            CNT02 VAR03 DEF03   		DEFSPA3  DEFENG3   CNT03 VAR04 DEF04 DEFSPA4  DEFENG4   CNT04 VAR05 DEF05   DEFSPA5  DEFENG5  CNT05      F3    GRPSXG
aADD(_aRegs,{cPerg, "01", "Tipo de BC Variável        ?  ", "",    "",    "mv_ch1", "C", 01, 0,  0,     "C", "",      "mv_par01",      "Por Grupo PPR",     	"",                 "",                 "",   "",   		"Por Função",        "",                 "",                "",   "",   "",     		"",      "",      "",   "",   "",    "",      "",       "",   "",   "",     "",      "",      "",        "",     ""})

// Definicao de textos de help (versao 7.10 em diante): uma array para cada linha.
_aHelps = {}    //               1         2         3         4             1         2         3         4             1         2         3         4
//              Ordem   1234567890123456789012345678901234567890    1234567890123456789012345678901234567890    1234567890123456789012345678901234567890
//AADD (_aHelps, {"01", {"Informar Data Inicial         ","",""}})

/*
DbSelectArea ("SX1")
DbSetOrder (1)
For _i := 1 to Len (_aRegs)
	If ! DbSeek (cPerg + _aRegs [_i, 2])
		RecLock("SX1", .T.)
	Else
		RecLock("SX1", .F.)
	Endif
	For _j := 1 to FCount ()
		// Campos CNT nao sao gravados para preservar conteudo anterior.
		If _j <= Len (_aRegs [_i]) .and. left (FieldName (_j), 6) != "X1_CNT" .and. FieldName (_j) != "X1_PRESEL"
			FieldPut(_j, _aRegs [_i, _j])
		Endif
	Next
	MsUnlock()
Next

// Deleta do SX1 as perguntas que nao constam em _aRegs
DbSeek (cPerg, .T.)
do while ! eof () .and. x1_grupo == cPerg
	if ascan (_aRegs, {|_aVal| _aVal [2] == sx1 -> x1_ordem}) == 0
		reclock("SX1", .F.)
		dbdelete()
		msunlock()
	endif
	dbskip()
enddo

// Gera helps das perguntas
For _i := 1 to Len (_aHelps)
	PutSX1Help ("P." + AllTrim(cPerg) + _aHelps [_i, 1] + ".", _aHelps [_i, 2], {}, {})
Next
*/

Restarea(_aArea)

Return