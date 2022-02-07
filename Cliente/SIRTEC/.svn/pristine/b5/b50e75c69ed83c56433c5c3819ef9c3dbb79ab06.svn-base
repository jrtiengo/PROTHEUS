#Include 'Totvs.ch'
#Include 'Rwmake.ch'

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FB009PPR ³ Autor ³ Felipe S. Raota             ³ Data ³ 11/04/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Unidade   ³ TRS              ³Contato ³ felipe.raota@totvs.com.br             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de Valores Fixos.                                        ³±±
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

User Function FB009PPR(cGrp, cInd)

Local oDlg, oSay1, oSay2, oSay3, oSay4, oSay5, oTGet, oTGet2, oPane1, oPane2, oPane3, oTButton1, oTButton2, oTButton3
Local aColsZG  := {}
Local aYesAlt  := {"ZG_MESANO", "ZG_UNIDADE", "ZG_DESCUN", "ZG_EQUIPE", "ZG_DESCEQP", "ZG_MAT", "ZG_NOMFUN", "ZG_VALOR"}
Local aYesCmp  := {"ZG_MESANO", "ZG_UNIDADE", "ZG_DESCUN", "ZG_EQUIPE", "ZG_DESCEQP", "ZG_MAT", "ZG_NOMFUN", "ZG_VALOR"}
Local aSizeAut := MsAdvSize()

Local oFont14	 := TFont():New( "Arial",,14,,.F.,,,,,.F. )
Local oFont16N := TFont():New( "Arial",,16,,.T.,,,,,.F. )
Local oFont22N := TFont():New( "Arial",,22,,.T.,,,,,.F. )

Local lMenu := .F.

Private oGDValFix
Private aHeadZG  := {}

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

aHeadZG := U_GeraHead("SZG",.T.,,aYesCmp,.T.)

DEFINE MSDIALOG oDlg TITLE "Cadastro de Valores Fixos"  From 00,00 To 520,1000 OF oMainWnd PIXEL
	
	// Painel 1
	oPane1 := TPanel():New(_aPosObj[1,1],_aPosObj[1,2],"",oDlg,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,080),_aPosObj[1,3],_aPosObj[1,4],.F.,.F.)
	
	oSay1 	:= TSay():New(003,002,{||"Grupo PPR: "  },oPane1,,oFont16N,,,,.T.,CLR_WHITE,CLR_WHITE,200,10)
	oTGet  := TGet():New(002,040,{|u| If(Pcount()>0,(cCodGrp:=u,_GetDesc(oSay2, 1, oSay4), _GerCols(@aColsZG)),cCodGrp) },oPane1,030,008,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,{|| ExistCpo("SZ4", cCodGrp) .OR. Empty(cCodGrp)},.F.,.F.,"SZ4",cCodGrp,,,, )
	oSay2  := TSay():New(003,080,{|| cDescGrp },oPane1,,oFont14,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	
	oSay3 	:= TSay():New(018,002,{||"Indicador: "  },oPane1,,oFont16N,,,,.T.,CLR_WHITE,CLR_WHITE,200,10)
	oTGet2 := TGet():New(017,040,{|u| If(Pcount()>0,(cCodInd:=u, _GetDesc(oSay4, 2), _GerCols(@aColsZG)),cCodInd) },oPane1,030,008,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,{|| ExistCpo("SZ5", cCodGrp+cCodInd) .OR. Empty(cCodInd)},.F.,.F.,"SZ5",cCodInd,,,, )
	oSay4  := TSay():New(018,080,{|| cDescInd },oPane1,,oFont14,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	
	oSay5 	:= TSay():New(012,350,{||"_Valores Fixos_" },oPane1,,oFont22N,,,,.T.,CLR_WHITE,CLR_WHITE,200,10)
	
	// Painel 2
	oPane2  := TPanel():New(_aPosObj[2,1],_aPosObj[2,2],"",oDlg,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,030),_aPosObj[2,3],_aPosObj[2,4],.F.,.F.)
	    
	oGDValFix := MsNewGetDados():New(_aPosObj[4,1],_aPosObj[4,2],_aPosObj[4,4],_aPosObj[4,3],GD_UPDATE+GD_INSERT+GD_DELETE,"U_009PPRLOK()",/*Tok*/,,aYesAlt,/*freeze*/,,/*fieldok*/,/*superdel*/,,oPane2,aHeadZG,aColsZG)
	oGDValFix:Disable()
	
	// Painel 3
	oPane3 	:= TPanel():New(_aPosObj[3,1],_aPosObj[3,2],"",oDlg,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,080),_aPosObj[3,3],_aPosObj[3,4],.F.,.F.)
	
	oTButton1 	:= TButton():New( 02, 010, "&Gravar", oPane3,{|| _GrvVFix(@oSay2, @oSay4, @oTGet, @oTGet2) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton2 	:= TButton():New( 02, 055, "&Limpar", oPane3,{|| _CleanScr(@oSay2, @oSay4, @oTGet, @oTGet2) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	oTButton3 	:= TButton():New( 02, 450, "&Fechar", oPane3,{|| oDlg:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	If lMenu
		_GetDesc(oSay2, 1, oSay4)
		_GetDesc(oSay4, 2)
		
		_GerCols(@aColsZG)
	Endif
		
	
ACTIVATE MSDIALOG oDlg CENTERED

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GerCols   ³ Autor ³ Felipe S. Raota            ³ Data ³ 11/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Gera linhas do aCols para a grid.                                 ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB009PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GerCols(aC)

If !Empty(cCodGrp) .AND. !Empty(cCodInd)
	
	If SZ4->(MsSeek( xFilial("SZ4") + cCodGrp ))
		
		If SZ5->(MsSeek( xFilial("SZ5") + cCodGrp + cCodInd ))
			
			If SZG->(MsSeek( xFilial("SZG") + cCodGrp + cCodInd ))
				
				aC := {}
				
				While SZG->(!EoF()) .AND. xFilial("SZG") + cCodGrp + cCodInd == SZG->ZG_FILIAL + SZG->ZG_CODGRP + SZG->ZG_CODIND
					
					_cDescUn := fBuscaCPO("CTT", 1, xFilial("CTT") + SZG->ZG_UNIDADE, "CTT_DESC01" )
					_cDescEqp := fBuscaCPO("AA1", 1, xFilial("AA1") + SZG->ZG_EQUIPE, "AA1_NOMTEC" )
					_cNomeFun :=  fBuscaCPO("SRA", 1, xFilial("SRA") + SZG->ZG_MAT, "RA_NOME" )
					
					aADD(aC, {SZG->ZG_MESANO, SZG->ZG_UNIDADE, _cDescUn, SZG->ZG_EQUIPE, _cDescEqp, SZG->ZG_MAT, _cNomeFun, SZG->ZG_VALOR, .F.})
					
					SZG->(dbSkip())
				Enddo
				
				_GetDadHab(aC, .T.)
				
			Else
				aC := {}
				aADD(aC, U_LinVazia(aHeadZG))
				_GetDadHab(aC, .T.)
			Endif
			
		Else
			aC := {}
			aADD(aC, U_LinVazia(aHeadZG))
			_GetDadHab(aC, .F.)
		Endif
	
	Else
		aC := {}
		aADD(aC, U_LinVazia(aHeadZG))
		_GetDadHab(aC, .F.)
	Endif

Else
	aC := {}
	
	// Validação pode ser executada antes de criar o objeto.
	If TYPE("oGDValFix") == "O"
		oGDValFix:Disable()
	Endif
	
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GetDesc   ³ Autor ³ Felipe S. Raota            ³ Data ³ 11/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Busca descrição do Grupo e Indicador se houver.                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB009PPR                                                          ³±±
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
				aADD(aC, U_LinVazia(aHeadZG))
				_GetDadHab(aC, .F.)
			Endif
		
		Else
			aC := {}
			aADD(aC, U_LinVazia(aHeadZG))
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
				aADD(aC, U_LinVazia(aHeadZG))
				_GetDadHab(aC, .F.)
			Endif
		
		Else
			aC := {}
			aADD(aC, U_LinVazia(aHeadZG))
			_GetDadHab(aC, .F.)
		Endif
		
EndCase

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ 009PPRLOK  ³ Autor ³ Felipe S. Raota            ³ Data ³ 11/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Valida linha do aCols.                                            ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB009PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function 009PPRLOK()

Local aAux := oGDValFix:aCols
Local lOk  := .T.

Local nPosCod := GdFieldPos("ZG_MESANO")

/*
// Valida Mes/Ano
For _x:=1 to len(aAux)
	
	If !GdDeleted(_x, aHeadZG, aAux)
		
		If _x <> n
			If GDFieldGet("ZG_MESANO") == aAux[_x,nPosCod]
				lOk := .F.
			Endif
		Endif
		
	Endif

Next

If !lOk
	Alert("Não é permitido cadastrar períodos iguais.")
Endif
*/

Return lOk

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _009TOK    ³ Autor ³ Felipe S. Raota            ³ Data ³ 11/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Valida aCols completo.                                            ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB009PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _009TOK()

Local aAux  := oGDValFix:aCols
Local aAux2 := oGDValFix:aCols
Local cCod  := ""
Local lOk   := .T.

Local nPosCod := GdFieldPos("ZG_MESANO", aHeadZG)

For _y:=1 to len(aAux2)
	
	If !GdDeleted(_y, aHeadZG, aAux2)
		
		cCod := Alltrim(GDFieldGet( "ZG_MESANO", _y, .F., aHeadZG, aAux2 ))
		
		lOk := U_ObrColsPPR(_y, aHeadZG, aAux2, "Período: " + Alltrim(cCod))
		
		If !lOk
			EXIT
		Endif
		/*
		If lOk
		
			// Valida Mes/Ano
			For _x:=1 to len(aAux)
				
				If !GdDeleted(_x, aHeadZG, aAux)
				
					If _x <> _y // Testa registro posicionado e se está deletado
						If GDFieldGet( "ZG_MESANO", _y, .F., aHeadZG, aAux2 ) == aAux[_x,nPosCod]
							lOk := .F.
						Endif
					Endif
					
				Endif
			
			Next
			
			If !lOk
				Alert("Não é permitido cadastrar períodos iguais.")
				EXIT
			Endif
		
		Endif
		*/
		
	Endif
	
Next

Return lOk

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GrvVFix   ³ Autor ³ Felipe S. Raota            ³ Data ³ 11/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Efetua gravação dos dados.                                        ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB009PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GrvVFix(oSay2, oSay4, oTGet, oTGet2)

_aC := oGDValFix:aCols

If _009TOK()
	
	If SZG->(MsSeek( xFilial("SZG") + cCodGrp + cCodInd ))
		
		While SZG->(!EoF()) .AND. xFilial("SZG") + cCodGrp + cCodInd == SZG->ZG_FILIAL + SZG->ZG_CODGRP + SZG->ZG_CODIND
		
			RecLock("SZG", .F.)
				SZG->(dbDelete())
			MsUnLock()
			
			SZG->(dbSkip())
		Enddo
		
	Endif
	
	For _x:=1 to len(_aC)
		
		If !GdDeleted(_x, aHeadZG, _aC)
			
			RecLock("SZG", .T.)
				
				SZG->ZG_FILIAL   := xFilial("SZG")
				SZG->ZG_CODGRP   := cCodGrp
				SZG->ZG_CODIND   := cCodInd
				SZG->ZG_MESANO   := GDFieldGet( "ZG_MESANO",  _x, .F., aHeadZG, _aC )
				SZG->ZG_UNIDADE  := GDFieldGet( "ZG_UNIDADE", _x, .F., aHeadZG, _aC )
				SZG->ZG_EQUIPE   := GDFieldGet( "ZG_EQUIPE",  _x, .F., aHeadZG, _aC )
				SZG->ZG_MAT      := GDFieldGet( "ZG_MAT",     _x, .F., aHeadZG, _aC )
				SZG->ZG_VALOR    := GDFieldGet( "ZG_VALOR",   _x, .F., aHeadZG, _aC )
				
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
	
	aColsZG := {}
	aADD(aColsZG, U_LinVazia(aHeadZG))
	_GetDadHab(aColsZG, .F.)
	
	MsgInfo("Valores Fixos gravados com sucesso.")

Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _CleanScr  ³ Autor ³ Felipe S. Raota            ³ Data ³ 11/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Efetua gravação dos dados.                                        ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB009PPR                                                          ³±±
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

aColsZG := {}
aADD(aColsZG, U_LinVazia(aHeadZG))
_GetDadHab(aColsZG, .F.)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GetDadHab ³ Autor ³ Felipe S. Raota            ³ Data ³ 11/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Habilita ou Desabilita GetDados                                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB009PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GetDadHab(aC, lHab)

aColsZG := aC
oGDValFix:aCols := aColsZG
oGDValFix:ForceRefresh()

If lHab
	oGDValFix:Enable()
Else
	oGDValFix:Disable()
Endif

Return