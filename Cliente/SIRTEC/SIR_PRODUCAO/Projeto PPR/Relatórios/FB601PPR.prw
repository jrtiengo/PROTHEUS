#include "protheus.ch"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FB601PPR ³ Autor ³ Felipe S. Raota              ³ Data ³ 30/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Unidade   ³ TRS              ³Contato ³ felipe.raota@totvs.com.br             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Relatório de LOG do Calculo PPR.                                  ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para cliente Sirtec.                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³  Data  ³ Manutencao Efetuada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³  /  /  ³                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function FB601PPR()

Local oReport

oReport := ReportDef()
oReport:PrintDialog()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ ReportDef  ³ Autor ³ Felipe S. Raota            ³ Data ³ 30/01/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³                                                                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB601PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function REPORTDEF()

Local oReport := Nil
Local oSection1 := Nil

Local cTitulo := "Log Cálculo PPR"
Local cTexto := ""

Private _cPerg := PADR("FB601PPR", 10, " ")  //PADR("FB601PPR", Len(SX1->X1_GRUPO), " ")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³		
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport := TReport():New("FB601PPR",cTitulo,_cPerg, {|oReport| ReportPrint(oReport)},cTexto)  

oReport:SetLandscape()
oReport:SetTotalInLine(.F.)

ValidPerg()
Pergunte(_cPerg, .F.)

oSection1 := TRSection():New(oReport,,/*{"SE3","SA3"}*/,,/*Campos do SX3*/,/*Campos do SIX*/)

TRCell():New(oSection1,"ZQ_MES",	"",  "Mês Calc",   /*Picture*/,  TamSX3("ZQ_MES")[1],    .F.  ,/*bloco de código*/)
TRCell():New(oSection1,"ZQ_DATA",	"",  "Data Log",   /*Picture*/,  TamSX3("ZQ_DATA")[1]+2,   .F.  ,/*bloco de código*/)
TRCell():New(oSection1,"ZQ_HORA",	"",  "Hora",       /*Picture*/,  TamSX3("ZQ_HORA")[1],   .F.  ,/*bloco de código*/)
TRCell():New(oSection1,"ZQ_USER",	"",  "Usuário",    /*Picture*/,  TamSX3("ZQ_USER")[1],   .F.  ,/*bloco de código*/)
TRCell():New(oSection1,"ZQ_CODGRP",	"",  "Grupo PPR",  /*Picture*/,  TamSX3("ZQ_CODGRP")[1], .F.  ,/*bloco de código*/)
TRCell():New(oSection1,"ZQ_MAT",	"",  "Matrícula",  /*Picture*/,  TamSX3("ZQ_MAT")[1],    .F.  ,/*bloco de código*/)
TRCell():New(oSection1,"ZQ_EQUIPE",	"",  "Equipe",     /*Picture*/,  TamSX3("ZQ_MAT")[1],    .F.  ,/*bloco de código*/)
TRCell():New(oSection1,"ZQ_CODIND",	"",  "Indicador",  /*Picture*/,  TamSX3("ZQ_CODIND")[1], .F.  ,/*bloco de código*/)
TRCell():New(oSection1,"ZQ_LOG",	"",  "Log",        /*Picture*/,  100,    .F.  ,/*bloco de código*/)

Return (oReport)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ PrintReport³ Autor ³ Felipe S. Raota            ³ Data ³ 11/09/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³                                                                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB602FAT                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ReportPrint(oReport)

Local oSection1 := oReport:Section(1)

Local cMes := ""
Local dData := CtoD("")
Local cHora := ""
Local cUser := ""
Local cCodGrp := ""
Local cMat := ""
Local cEquipe := ""
Local cCodInd := ""
Local cLog := ""

Local cCodCalc := ""

oSection1:Cell("ZQ_MES"):SetBlock({|| cMes })
oSection1:Cell("ZQ_DATA"):SetBlock({|| dData })
oSection1:Cell("ZQ_HORA"):SetBlock({|| cHora })
oSection1:Cell("ZQ_USER"):SetBlock({|| cUser })
oSection1:Cell("ZQ_CODGRP"):SetBlock({|| cCodGrp })
oSection1:Cell("ZQ_MAT"):SetBlock({|| cMat })
oSection1:Cell("ZQ_EQUIPE"):SetBlock({|| cEquipe })
oSection1:Cell("ZQ_CODIND"):SetBlock({|| cCodInd })
oSection1:Cell("ZQ_LOG"):SetBlock({|| cLog })

dbSelectArea("SZD")
SZD->(dbSetOrder(4)) // PERIODO

If SZD->(MsSeek( xFilial("SZD") + MV_PAR01 ))
	cCodCalc := SZD->ZD_CODCALC
Else
	MsgInfo("Período não encontrado!")
	RETURN
Endif

dbSelectArea("SZQ")
SZQ->(dbSetOrder(1))

oSection1:Init()

If SZQ->( MsSeek( xFilial("SZQ") + cCodCalc ) )

	While !SZQ->(EoF()) .AND. !oReport:Cancel() .AND. xFilial("SZQ") + cCodCalc == SZQ->ZQ_FILIAL + SZQ->ZQ_CODCALC
		
		cMes := SZQ->ZQ_MES
		dData := SZQ->ZQ_DATA
		cHora := SZQ->ZQ_HORA
		cUser := SZQ->ZQ_USER
		cCodGrp := SZQ->ZQ_CODGRP
		cMat := SZQ->ZQ_MAT
		cEquipe := SZQ->ZQ_EQUIPE
		cCodInd := SZQ->ZQ_CODIND
		cLog := SZQ->ZQ_LOG
		
		oSection1:PrintLine()
		
		SZQ->(dbSkip())
	Enddo

Endif

oSection1:Finish()
	
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³VALIDPERG ³ Autor ³ Alisson R. Teles      ³ Data ³ 25/05/013³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³                                                            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ValidPerg()

Local aArea  := GetArea()
Local aRegs  := {}
Local aHelps := {}
Local i      := 0
Local j      := 0

aRegs = {}
//             	   GRUPO ORDEM  PERGUNT         			       PERSPA  PERENG 	   VARIAVL    TIPO 	TAM DEC PRESEL 	   GSC   VALID           	  VAR01       DEF01                DEFSPA1 DEFENG1   CNT01   VAR02               DEF02         DEFSPA2    DEFENG2   CNT02 	  VAR03 					DEF03   DEFSPA3 DEFENG3 CNT03 	VAR04 	     DEF04     DEFSPA4     DEFENG4 CNT04             VAR05      DEF05 DEFSPA5 DEFENG5 CNT05   F3  	GRPSXG    
AADD (aRegs, {_cPerg, "01", "Período (Ex.: 1/2014 ou 2/2014)?", 	"",    "",    "mv_ch1", 	"C", 06, 0,  	0,     "G", 	"",          "mv_par01", 				"",        		"",     "",     "",		"",   				"",             "",			"",		"",		"",     					"",     "",   	"",   "",      "",     		"",     	"",   		"",   "",   			"",     	"",     "",    "",	"",   	"",   	""})
//AADD (aRegs, {_cPerg, "01", "Data até        		   		?", 	"",    "",    "mv_ch2", 	"D", 08, 0,  	0,     "G", 	"",          "mv_par02", 				"",        		"",     "",     "",		"",   				"",             "",			"",		"",		"",     					"",     "",   	"",   "",      "",     		"",     	"",   		"",   "",   			"",     	"",     "",    "",	"",   	"",   	""})
// Definicao de textos de help (versao 7.10 em diante): uma array para cada linha.
aHelps = {}
//              	Ordem   1234567890123456789012345678901234567890    1234567890123456789012345678901234567890    1234567890123456789012345678901234567890
AADD (aHelps, {"01", {"Informe código do cálculo", 		    "                             ", "                                    "}})

/*
DbSelectArea("SX1")
DbSetOrder(1)
For i := 1 to Len (aRegs)
	If ! DbSeek (_cPerg + aRegs [i, 2])
		RecLock("SX1", .T.)
	Else
		RecLock("SX1", .F.)
	Endif
	For j := 1 to FCount ()
	// Campos CNT nao sao gravados para preservar conteudo anterior.
		//If j <= Len (aRegs [i]) .and. left (fieldname (j), 6) != "X1_CNT" .and. fieldname (j) != "X1_PRESEL"
		If j <= Len (aRegs [i]) .and. fieldname (j) != "X1_PRESEL"
			FieldPut(j, aRegs [i, j])
		Endif
	Next
	MsUnlock()
Next

// Deleta do SX1 as perguntas que nao constam em aRegs
DbSeek (_cPerg, .T.)
Do While !Eof() .And. x1_grupo == _cPerg
	If Ascan(aRegs, {|_aVal| _aVal [2] == sx1 -> x1_ordem}) == 0
		Reclock("SX1", .F.)
		Dbdelete()
		Msunlock()
	Endif
	Dbskip()
enddo

// Gera helps das perguntas
For i := 1 to Len(aHelps)
	PutSX1Help ("P." + alltrim(_cPerg) + aHelps [i, 1] + ".", aHelps [i, 2], {}, {})
Next
*/

Restarea(aArea)

Return 