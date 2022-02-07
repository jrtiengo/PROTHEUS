#Include 'Protheus.ch'
#include "fwmvcdef.ch"
#include "rwmake.ch"
#include "tbiconn.ch"
#include "topconn.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FB014PPR ³ Autor ³ Felipe S. Raota             ³ Data ³ 17/07/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Unidade   ³ TRS              ³Contato ³ felipe.raota@totvs.com.br             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina de aprovação de ajustes das OS's x Técnicos.               ³±±
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

User Function FB014PPR()

Private aHeadSZL := {}
Private aColsSZL := {}

_AtuCols()

FB014OS()

Return

Static Function _AtuCols()

Local cQuery := ""

cQuery := " SELECT DISTINCT SZL.ZL_CODAJUS, SZL.ZL_FILIAL, SZL.ZL_NUMOS, SZL.ZL_SEQ, SZL.ZL_EQUIPE, SZL.ZL_CODGRP, SZL.ZL_DTCHEG "
cQuery += " FROM "+RetSqlName("SZL")+" SZL "
cQuery += " WHERE SZL.D_E_L_E_T_ = ' ' " 
cQuery += "   AND SZL.ZL_STATUS = 'P' "
cQuery += " ORDER BY SZL.ZL_FILIAL, SZL.ZL_NUMOS, SZL.ZL_SEQ, SZL.ZL_DTCHEG "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery),'TRB',.F.,.T.)

TCSetField ("TRB", "ZL_DTCHEG", "D")

aColsSZL := {}

While TRB->(!EoF()) 
	
	aADD(aColsSZL, {TRB->ZL_CODAJUS, TRB->ZL_NUMOS, TRB->ZL_SEQ, TRB->ZL_EQUIPE, TRB->ZL_CODGRP, TRB->ZL_DTCHEG, .F. })
	
	TRB->(dbSkip())
Enddo

TRB->(dBclosearea())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ FB014OS    ³ Autor ³ Felipe S. Raota            ³ Data ³ 17/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Tela com as OS's e técnicos para APROVAÇÃO.                       ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB014PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function FB014OS()

Local cTitle   := "Aprovação OS's x Técnicos"
Local oFont13  := TFont():New( "Arial",,13,,.F.,,,,,.f. )
Local oFont13N := TFont():New( "Arial",,13,,.T.,,,,,.f. )
Local oFont14  := TFont():New( "Arial",,14,,.F.,,,,,.f. )
Local oFont14N := TFont():New( "Arial",,14,,.T.,,,,,.f. )
Local oFont15N := TFont():New( "Arial",,15,,.T.,,,,,.f. )
Local oFont15  := TFont():New( "Arial",,15,,.F.,,,,,.f. )
Local oFont16N := TFont():New( "Arial",,16,,.T.,,,,,.f. )
Local oFont17N := TFont():New( "Arial",,17,,.T.,,,,,.f. )
Local oFont18N := TFont():New( "Arial",,17,,.T.,,,,,.f. )
Local aPosObj  := {{002,002,499,013},; // TPanel 1
				   {017,002,499,226},; // TPanel 2
				   {245,002,499,014},; // TPanel 3
				   {002,002,497,209}}  // MsNewGetDados

Local lCont := .T.
Local lAlt := .F.
Local oDlg1, oPane1, oPane2, oPane3, oTButton1, oTButton2, oTButton3, oGetDad1

Local aYesAlter := {}
Local aYesFields := {"ZL_CODAJUS", "ZL_NUMOS", "ZL_SEQ", "ZL_EQUIPE", "ZL_CODGRP", "ZL_DTCHEG"}

Private _aCampos:= {"ZL_CODAJUS", "ZL_NUMOS", "ZL_SEQ", "ZL_EQUIPE", "ZL_CODGRP", "ZL_DTCHEG","NOUSER"}
Private _aCamposAtl := {"ZL_EQUIPE", "ZL_CODGRP", "ZL_DTCHEG"}

While lCont
	
	aHeadSZL := U_GeraHead("SZL",.T.,,aYesFields,.T.)
	
	DEFINE MSDIALOG oDlg1 TITLE cTitle  From 00,00 To 520,1000 OF oMainWnd PIXEL
	
	oPane1 		:= TPanel():New(aPosObj[1,1],aPosObj[1,2],"",oDlg1,,.F.,.F.,,SetTransparentColor(CLR_BLUE,080),aPosObj[1,3],aPosObj[1,4],.F.,.F.)
	
	oTButton1 	:= TButton():New( 002, 450, "Pesquisar",oPane1,{|| GdSeek(oGetDad1,OemtoAnsi("Pesquisar"))},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	oPane2 		:= TPanel():New(aPosObj[2,1],aPosObj[2,2],"",oDlg1,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,030),aPosObj[2,3],aPosObj[2,4],.F.,.F.)
	oGetDad1 	:= MsNewGetDados():New(aPosObj[4,1],aPosObj[4,2],aPosObj[4,4],aPosObj[4,3],GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",,aYesAlter,/*freeze*/,,,/*superdel*/,/*delok*/,oPane2,aHeadSZL,aColsSZL)

	oPane3 		:= TPanel():New(aPosObj[3,1],aPosObj[3,2],"",oDlg1,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,080),aPosObj[3,3],aPosObj[3,4],.F.,.F.)
	oTButton2 	:= TButton():New( 02, 450, "&Sair",oPane3,{|| (lCont := .F., oDlg1:End()) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton3 	:= TButton():New( 02, 050, "&Visualizar",oPane3,{|| U_FB014APR(oGetDad1:aCols[oGetDad1:nAt,1])},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton4 	:= TButton():New( 02, 390, "&Aprovar",oPane3,{|| (lAlt := .T., oDlg1:End()) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	ACTIVATE MSDIALOG oDlg1 CENTERED
	
	If lAlt
		
		// GRAVAR APROVAÇÃO E ALTERAR NA ZZ5
		_AtuCols()
	Endif
	
Enddo

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ FB014APR   ³ Autor ³ Felipe S. Raota            ³ Data ³ 16/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Abre tela para aprovar alterações da OS selecionada.              ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB014PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User function FB014APR(_cCodAjus)

Local oDlg
Local aYesAlt  := {}
Local aYesCmp  := {"ZL_FILIAL", "ZL_NUMOS", "ZL_SEQ", "ZL_EQUIPE", "ZL_CODGRP", "ZL_DTCHEG"}
Local aYesAlter := {}
Local lOk       := .F.          //Confirmacao da tela

Local lAlt := .F.

Private oGetDados               //Objeto da msgetdados

Private aHeadAux := {}
Private aColsAux := {}

SZM->(dbSetOrder(1))

If SZM->(MsSeek(xFilial("SZM") + _cCodAjus))
	
	dbSelectArea("AA1")
	AA1->(dbSetOrder(1))
	
	While SZM->(!EoF()) .AND. xFilial("SZM") + _cCodAjus == SZM->ZM_FILIAL + SZM->ZM_CODAJUS
		
		If AA1->(MsSeek( xFilial("AA1") + SZM->ZM_CODTEC ))
			aADD(aColsAux, {SZM->ZM_CODTEC, AA1->AA1_NOMTEC, SZM->ZM_ENCARR, .F. })
		Endif
		
		SZM->(dbSkip()) 
	Enddo
	
	_aHAux := U_GeraHead("AA1",.T.,,{"AA1_CODTEC", "AA1_NOMTEC"},.T.)
	
	For _x:=1 to len(_aHAux)
		aADD(aHeadAux, _aHAux[_x])
	Next
	
	_aHAux := U_GeraHead("SZM",.T.,,{"ZM_ENCARR"},.T.) 
	
	For _x:=1 to len(_aHAux)
		aADD(aHeadAux, _aHAux[_x])
	Next 
	
	// Altera inicializadores padrões
	For _x:=1 to len(aHeadAux) 
		If Alltrim(aHeadAux[_x,2]) == "AA1_CODTEC" .OR. Alltrim(aHeadAux[_x,2]) == "ZM_ENCARR"
			aHeadAux[_x,12] := ""
		Endif
	Next
	
	DEFINE MSDIALOG oDlg TITLE "Técnicos da OS Modificada" From 00,00 To 220,500 OF oMainWnd PIXEL
	
	oGetDad1 := MsNewGetDados():New(000,000,097,250,/*GD_UPDATE+GD_INSERT+GD_DELETE*/,"AllwaysTrue()","AllwaysTrue()",,/*aYesAlter*/,/*freeze*/,,,/*superdel*/,/*delok*/,oDlg,aHeadAux,aColsAux)
	
	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| oDlg:End() },{||oDlg:End()})
	
Endif

Return lAlt