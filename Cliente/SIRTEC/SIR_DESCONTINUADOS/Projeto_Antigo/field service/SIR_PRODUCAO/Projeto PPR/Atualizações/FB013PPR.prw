#Include 'Protheus.ch'
#include "fwmvcdef.ch"
#include "rwmake.ch"
#include "tbiconn.ch"
#include "topconn.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FB013PPR ³ Autor ³ Felipe S. Raota             ³ Data ³ 12/07/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Unidade   ³ TRS              ³Contato ³ felipe.raota@totvs.com.br             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Alteração de dados da tabela ZZ5 - OS's x Técnicos.               ³±±
±±³          ³ Gravação em tabela separada, para posterior aprovação.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para cliente Sirtec - Projeto PPR                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³  Data  ³ Manutencao Efetuada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³  /  /  ³                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function FB013PPR()

Private aHeadZZ5 := {}
Private aColsZZ5 := {}

Private cPerg := PADR("FB013PPR", 10," ") //PADR("FB013PPR", LEN(SX1->X1_GRUPO)," ")

If !Pergunte(cPerg,.T.)
	Return
Endif

_AtuCols()

FB013OS()

Return

Static Function _AtuCols()

Local cQuery := ""

cQuery := " SELECT DISTINCT ZZ5.ZZ5_FILIAL, ZZ5.ZZ5_NUMOS, ZZ5.ZZ5_SEQ, ZZ5.ZZ5_EQUIPE, ZZ5.ZZ5_CODGRP, ZZ5.ZZ5_DTCHEG "
cQuery += " FROM "+RetSqlName("ZZ5")+" ZZ5 "
cQuery += " WHERE ZZ5.D_E_L_E_T_ = ' ' "
cQuery += "   AND ZZ5.ZZ5_DTCHEG BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"' "
cQuery += " ORDER BY ZZ5.ZZ5_FILIAL, ZZ5.ZZ5_NUMOS, ZZ5.ZZ5_SEQ, ZZ5.ZZ5_DTCHEG "

cQuery := ChangeQuery(cQuery)
dbUseArea(.T., "TOPCONN", TcGenQry(,,cQuery),'TRB',.F.,.T.)

TCSetField ("TRB", "ZZ5_DTCHEG", "D")

aColsZZ5 := {}

While TRB->(!EoF())

	aADD(aColsZZ5, {TRB->ZZ5_NUMOS, TRB->ZZ5_SEQ, TRB->ZZ5_EQUIPE, TRB->ZZ5_CODGRP, TRB->ZZ5_DTCHEG, .F. })

	TRB->(dbSkip())
Enddo

TRB->(dBclosearea())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ FB013OS    ³ Autor ³ Felipe S. Raota            ³ Data ³ 12/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Tela com as OS's e técnicos para manutenção.                      ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB013PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static function FB013OS()

Local cTitle   := "Manutenção OS's x Técnicos"
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
Local aYesFields := {"ZZ5_NUMOS", "ZZ5_SEQ", "ZZ5_EQUIPE", "ZZ5_CODGRP", "ZZ5_DTCHEG"}

Private _aCampos:= {"ZZ5_NUMOS", "ZZ5_SEQ", "ZZ5_EQUIPE", "ZZ5_CODGRP", "ZZ5_DTCHEG","NOUSER"} //{"B1_COD", "B1_DESC","NOUSER"}
Private _aCamposAtl := {"ZZ5_EQUIPE", "ZZ5_CODGRP", "ZZ5_DTCHEG"}

dbSelectArea("SZL")
SZL->(dbSetOrder(2))

While lCont

	aHeadZZ5 := U_GeraHead("ZZ5",.T.,,aYesFields,.T.)

	DEFINE MSDIALOG oDlg1 TITLE cTitle  From 00,00 To 520,1000 OF oMainWnd PIXEL

	oPane1 		:= TPanel():New(aPosObj[1,1],aPosObj[1,2],"",oDlg1,,.F.,.F.,,SetTransparentColor(CLR_BLUE,080),aPosObj[1,3],aPosObj[1,4],.F.,.F.)

	oTButton1 	:= TButton():New( 002, 450, "Pesquisar",oPane1,{|| GdSeek(oGetDad1,OemtoAnsi("Pesquisar"))},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	oPane2 		:= TPanel():New(aPosObj[2,1],aPosObj[2,2],"",oDlg1,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,030),aPosObj[2,3],aPosObj[2,4],.F.,.F.)
	oGetDad1 	:= MsNewGetDados():New(aPosObj[4,1],aPosObj[4,2],aPosObj[4,4],aPosObj[4,3],GD_UPDATE,"AllwaysTrue()","AllwaysTrue()",,aYesAlter,/*freeze*/,,,/*superdel*/,/*delok*/,oPane2,aHeadZZ5,aColsZZ5)

	oPane3 		:= TPanel():New(aPosObj[3,1],aPosObj[3,2],"",oDlg1,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,080),aPosObj[3,3],aPosObj[3,4],.F.,.F.)
	oTButton2 	:= TButton():New( 02, 450, "&Sair",oPane3,{|| (lCont := .F., oDlg1:End()) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTButton3 	:= TButton():New( 02, 390, "&Alterar",oPane3,{|| lAlt := U_FB013ALT(oGetDad1:aCols[oGetDad1:nAt,1],oGetDad1:aCols[oGetDad1:nAt,2],oGetDad1:aCols[oGetDad1:nAt,3])},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

	ACTIVATE MSDIALOG oDlg1 CENTERED

	If lAlt
		_AtuCols()
	Endif

Enddo

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ FB113ALT   ³ Autor ³ Felipe S. Raota            ³ Data ³ 16/07/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Abre tela para alterar informações da OS selecionada.             ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB113PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User function FB013ALT(_cOs, _cSeq, _cEqp)

Local oDlg, oSay, oTGet, oSay2, oTBut, oTGet2
Local aYesAlt  := {}
Local aYesCmp  := {"ZZ5_FILIAL", "ZZ5_NUMOS", "ZZ5_SEQ", "ZZ5_EQUIPE", "ZZ5_CODGRP", "ZZ5_DTCHEG"}
Local aYesAlter := {}
Local aSize     := MsAdvSize()  //Size da tela.
Local aObjects  := {}           //Objetos da tela
Local aPosObj   := {}           //Posicoes do objeto
Local aInfo     := {}           //Posicoes do objeto
Local lOk       := .F.          //Confirmacao da tela
Local nAcaoGetD := 0            //Acao a ser tomado no MsGetDados
Local aCriaCols := {}           //Variavel que guarda o retorno da funcao A610CriaCols

Local lAlt := .F.

Private nOpcX     := 4       	//Opcao selecionada no sistema
Private aGets, aTela            //Variaveis auxiliares da Enchoice
Private oDlg                    //Objeto da dialog
Private oGetDados               //Objeto da msgetdados
Private oEnch                   //Objeto da Enchoice

Private aHeadAux := {}
Private aColsAux := {}

// Verifica se não tem nenhuma alteração pendente
If SZL->(MsSeek( xFilial("SZL") + _cOs + _cEqp + _cSeq + "P" ))
	Alert("Essa OS já possui uma alteração pendente, aguarde aprovação.")
	Return .F.
Endif

dbselectarea("ZZ5")
ZZ5->(dbSetOrder(1))

If ZZ5->(MsSeek(xFilial("ZZ5") + _cOs + _cEqp + _cSeq))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carrega variaveis da enchoice na memoria.                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RegToMemory( "ZZ5", .F. )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define as posicoes da GetDados e Paineis.                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	AAdd( aObjects, {  100, 100, .F., .F. } )      //Enchoice
	AAdd( aObjects, {  aSize[ 4 ], 100, .T., .T. } )      //MsNewGetDados

	aInfo 	 := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 2, 2 }
	aPosObj  := MsObjSize( aInfo, aObjects, .T. , .F. )

	dbSelectArea("AA1")
	AA1->(dbSetOrder(1))

	While ZZ5->(!EoF()) .AND. xFilial("ZZ5") + _cOs + _cEqp + _cSeq == ZZ5->ZZ5_FILIAL + ZZ5->ZZ5_NUMOS + ZZ5->ZZ5_EQUIPE + ZZ5->ZZ5_SEQ

		If AA1->(MsSeek( xFilial("AA1") + ZZ5->ZZ5_CODTEC ))
			aADD(aColsAux, {ZZ5->ZZ5_CODTEC, AA1->AA1_NOMTEC, ZZ5->ZZ5_ENCARR, .F. })
		Endif

		ZZ5->(dbSkip())
	Enddo

	_aHAux := U_GeraHead("AA1",.T.,,{"AA1_CODTEC", "AA1_NOMTEC"},.T.)

	For _x:=1 to len(_aHAux)
		aADD(aHeadAux, _aHAux[_x])
	Next

	_aHAux := U_GeraHead("ZZ5",.T.,,{"ZZ5_ENCARR"},.T.)

	For _x:=1 to len(_aHAux)
		aADD(aHeadAux, _aHAux[_x])
	Next

	// Altera inicializadores padrões

	For _x:=1 to len(aHeadAux)
		If Alltrim(aHeadAux[_x,2]) == "AA1_CODTEC" .OR. Alltrim(aHeadAux[_x,2]) == "ZZ5_ENCARR"
			aHeadAux[_x,12] := ""
		Endif
	Next

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da tela.                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DEFINE MSDIALOG oDlg TITLE "Ajuste OS's x Técnico" From 00,00 To 520,1000 OF oMainWnd PIXEL

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Enchoice                                                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oEnchoice := Enchoice( "ZZ5",/*Recno()*/,3,,,,_aCampos,{aPosObj[1,1],aPosObj[1,2],aPosObj[1,3],aPosObj[1,4]},_aCamposAtl,4,,,,,,,,,.T.,,,,,,)

	oGetDad1 := MsNewGetDados():New(050,020,220,480,GD_UPDATE+GD_INSERT+GD_DELETE,"AllwaysTrue()","AllwaysTrue()",,/*aYesAlter*/,/*freeze*/,,,/*superdel*/,/*delok*/,oDlg,aHeadAux,aColsAux)

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| IIf(lOk := .t.,oDlg:End(),lOk := .F.)},{||oDlg:End()})

	If lOk

		_cCodZL := GetSXENum("SZL", "ZL_CODAJUS")
		ConfirmSX8()

		RecLock("SZL", .T.)
			SZL->ZL_FILIAL  := xFilial("SZL")
			SZL->ZL_CODAJUS := _cCodZL
			SZL->ZL_NUMOS   := M->ZZ5_NUMOS
			SZL->ZL_EQUIPE  := M->ZZ5_EQUIPE
			SZL->ZL_SEQ     := M->ZZ5_SEQ
			SZL->ZL_CODGRP  := M->ZZ5_CODGRP
			SZL->ZL_DTCHEG  := M->ZZ5_DTCHEG
			SZL->ZL_LOG     := Upper(LogUserName()) + "-" + DtoC(dDataBase) + "-" + Time()
			SZL->ZL_STATUS  := "P"
		MsUnLock()

		_aColAux := oGetDad1:aCols

		For _x:=1 to len(_aColAux)

			RecLock("SZM", .T.)
				SZM->ZM_FILIAL  := xFilial("SZM")
				SZM->ZM_CODAJUS := _cCodZL
				SZM->ZM_CODTEC  := _aColAux[_x,1]
				SZM->ZM_ENCARR  := _aColAux[_x,3]
			MsUnLock()

		Next

		lAlt := .T.

		MsgInfo("Alteração gravada com sucesso, aguarde aprovação.")

	Endif

Endif

Return lAlt