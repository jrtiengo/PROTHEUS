#Include "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"

#INCLUDE "RWMAKE.CH"
#include "ap5mail.ch"


#define ENTER Chr(13)+Chr(10)

/*/{Protheus.doc} BACA005
Ajusta Arredondamento de Custo M้dio quando Quantidade Final(B2_QFIM = 0 ) ZERADA  e Existe Valor final (B2_VFIM1 <> 0 ). 
USO PARA FECHAMENTO 03/2022 CANOAS 
@type function
@version 1.0
@author Mแrcio Borges
@since 02/04/2022
/*/
User Function BACA005()
	Processa({|| Roda()},"Analisando e ajustando registros ...")
REturn

Static Function Roda()

	Local lAtu := .T. //Atualiza registros. .F. ้ utilizado para valida็ใo do programa.

	Local aSetField := {}
	Local aTamSX3

	Local _cFilial // filial temporแria
	Local dMVUlmes := SUPERGETMV("MV_ULMES",.f.,SPACE(8))
	Local cPeriodo := ANOMES(dMVUlmes+1)
	Local cOper    := "" //aopera็ใo adi็ใo (+)ou subtra็ใo (-)


	Private cTABB2   := GetNextAlias() //Alias Tabela Temporแria
	Private cTABMOV  := GetNextAlias() //Alias Tabela Temporแria
	PRIVATE cLOGERRO := ""
	

	_cFilial := cFilAnt


	DBSelectArea("SD1");DBSetOrder(1)
	DBSelectArea("SD2");DBSetOrder(1)
	DBSelectArea("SD3");DBSetOrder(1)
	DBSelectArea("SB2");DBSetOrder(1)


	// Busca SB2 com problemas
	cSql := "SELECT COUNT(*) OVER ( PARTITION BY '1') QTDREG, R_E_C_N_O_ B2REG, B2_FILIAL,B2_COD, B2_LOCAL FROM SB2980 WHERE B2_FILIAL = '0102' AND D_E_L_E_T_  = ' ' AND B2_QFIM = 0 AND B2_VFIM1 <> 0 "
	MPSysOpenQuery( cSql, cTABB2, aSetField  )

	If (cTABB2)->(!EOF())
		ProcRegua((cTABB2)->QTDREG) //ProcRegua((cBASE)->QTDREG)
	Endif

	Do While (cTABB2)->(!EOF())

		lPula := .F.

		IncProc("Produto " + (cTABB2)->(B2_FILIAL + "/" + B2_COD + '/' + B2_LOCAL))
		//Posiciona no SB2
		SB2->(DBGotop())
		SB2->(DBGoto( (cTABB2)->B2REG))

		IF SB2->(recno()) <>  (cTABB2)->B2REG
			cLOGERRO += "- Falha no posicionamento SB2. Registro: " + AllTrim(STR((cTABB2)->B2REG)) + "chave: " + (cTABB2)->B2_FILIAL + "/" + B2_COD + '/' + B2_LOCAL+ ENTER
			EXIT
		Endif

		nDIFERENCA := SB2->B2_VFIM1

		//------------- Consulta Kardex Movimentos
		aSetField := { }
		aTamSX3 := TAMSX3("B2_QFIM")
		AADD(aSetField,{"QTD", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
		aTamSX3 := TAMSX3("B2_VFIM1")
		AADD(aSetField,{"CUSTO", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
		aTamSX3 := TAMSX3("B2_VFIM1")
		AADD(aSetField,{"CM", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })

		cSqlMov := ""
		cSqlMov += "SELECT  * FROM ( "
		cSqlMov += " SELECT 'SD1' TAB, R_E_C_N_O_ ,D1_SEQCALC SEQCALC ,D1_NUMSEQ NUMSEQ, D1_COD PRODUTO, D1_LOCAL AS ARMAZEM, D1_QUANT QTD , D1_CUSTO CUSTO, (CASE WHEN D1_QUANT = 0 THEN 0 ELSE D1_CUSTO/D1_QUANT END  ) CM, 'E' TM  FROM SD1980 WHERE D1_FILIAL = '0102' AND D_E_L_E_T_ = ' ' AND D1_DTDIGIT LIKE '"+ cPeriodo + "%'  AND D1_SEQCALC  <> ' ' "
		cSqlMov += "	AND D1_COD = '"+ SB2->B2_COD + "' AND D1_LOCAL = '"+ SB2->B2_lOCAL +"' "
		cSqlMov += " UNION "
		cSqlMov += " SELECT 'SD2' TAB, R_E_C_N_O_,D2_SEQCALC SEQCALC ,D2_NUMSEQ NUMSEQ, D2_COD PRODUTO, D2_LOCAL, D2_QUANT QTD  , D2_CUSTO1 CUSTO, (CASE WHEN D2_QUANT = 0 THEN 0 ELSE D2_CUSTO1/D2_QUANT END  ) CM, 'S' TM  FROM SD2980 WHERE D2_FILIAL = '0102' AND D_E_L_E_T_ = ' ' AND D2_EMISSAO LIKE '"+ cPeriodo + "%'  AND D2_SEQCALC  <> ' ' "
		cSqlMov += "	AND D2_COD = '"+ SB2->B2_COD + "' AND D2_LOCAL = '"+ SB2->B2_lOCAL +"'"
		cSqlMov += " UNION "
		cSqlMov += " SELECT 'SD3' TAB, R_E_C_N_O_,D3_SEQCALC SEQCALC ,D3_NUMSEQ NUMSEQ, D3_COD PRODUTO, D3_LOCAL, D3_QUANT, D3_CUSTO1 CUSTO,(CASE WHEN D3_QUANT = 0 THEN 0 ELSE D3_CUSTO1/D3_QUANT END  ) CM, (CASE WHEN D3_TM < '500' THEN 'E' ELSE 'S' END ) TM  FROM SD3980 WHERE D3_FILIAL = '0102' AND D_E_L_E_T_ = ' ' AND D3_EMISSAO LIKE '"+ cPeriodo + "%'  AND D3_SEQCALC  <> ' ' "
		cSqlMov += "	AND D3_COD = '"+ SB2->B2_COD + "' AND D3_LOCAL = '"+ SB2->B2_lOCAL +"'"
		cSqlMov += ") AS TMP "
		cSqlMov += "ORDER BY  SEQCALC DESC

		MPSysOpenQuery( cSqlMov, cTABMOV, aSetField  )



		IF (cTABMOV)->(!EOF())

			//Determina operador de adi็ใo ou subtra็ใo do custo 
			IF  (cTABMOV)->TM == 'S'
				If nDIFERENCA > 0
					cOper := "+"
				Else
					cOper := "-"
				Endif
			Else// Entrada
				If nDIFERENCA > 0
					cOper := "-"
				Else
					cOper := "+"
				Endif
			Endif

			//Seta a diferen็a para seu valor absoluto/ operador serแ utilizado na f๓rmula de grava็ใo
			nDIFERENCA := ABS(nDIFERENCA)

			Begin Transaction
				//Posiciona na tabela de refer๊ncia
				IF (cTABMOV)->TAB == 'SD1'
					DBSelectArea("SD1")
					SD1->(DBGotop())
					SD1->(DBGoto((cTABMOV)->R_E_C_N_O_))

					IF SD1->(recno()) ==   (cTABMOV)->R_E_C_N_O_
						If lAtu
							RecLock("SD1", .F.)
							If cOper == '-'
								SD1->D1_CUSTO := SD1->D1_CUSTO - nDIFERENCA
							Else
								SD1->D1_CUSTO := SD1->D1_CUSTO + nDIFERENCA
							Endif
							MsUnlock()
						Endif

					ELSE
						cLOGERRO += "- Nใo localizado movimento  Registro SD1: " + AllTrim(STR((cTABMOV)->R_E_C_N_O_)) + "chave: " + (cTABB2)->B2_FILIAL + "/" + B2_COD + '/' + B2_LOCAL+ ENTER
						lPula := .t.
					Endif

				ELSEIF (cTABMOV)->TAB == 'SD2'
					DBSelectArea("SD2")
					SD2->(DBGotop())
					SD2->(DBGoto((cTABMOV)->R_E_C_N_O_))

					IF SD2->(recno()) ==   (cTABMOV)->R_E_C_N_O_
						If lAtu
							RecLock("SD2", .F.)
							If cOper == '-'
								SD2->D2_CUSTO1 := SD2->D2_CUSTO1 - nDIFERENCA
							Else
								SD2->D2_CUSTO1 := SD2->D2_CUSTO1 + nDIFERENCA
							Endif
							MsUnlock()
						Endif

					ELSE
						cLOGERRO += "- Nใo localizado movimento  Registro SD2: " + AllTrim(STR((cTABMOV)->R_E_C_N_O_)) + "chave: " + (cTABB2)->B2_FILIAL + "/" + B2_COD + '/' + B2_LOCAL+ ENTER
						lPula := .t.
					Endif

				ELSEIF (cTABMOV)->TAB == 'SD3'
					DBSelectArea("SD3")
					SD3->(DBGotop())
					SD3->(DBGoto((cTABMOV)->R_E_C_N_O_))

					IF SD3->(recno()) ==   (cTABMOV)->R_E_C_N_O_
						If lAtu
							RecLock("SD3", .F.)
							If cOper == '-'
								SD3->D3_CUSTO1 := SD3->D3_CUSTO1 - nDIFERENCA
							Else
								SD3->D3_CUSTO1 := SD3->D3_CUSTO1 + nDIFERENCA
							Endif
							MsUnlock()
						Endif

					ELSE
						cLOGERRO += "- Nใo localizado movimento  Registro SD3: " + AllTrim(STR((cTABMOV)->R_E_C_N_O_)) + "chave: " + (cTABB2)->B2_FILIAL + "/" + B2_COD + '/' + B2_LOCAL+ ENTER
						lPula := .t.
					Endif
				ENDIF

				If !lPula
					If lAtu
						RecLock("SB2", .F.)
						SB2->B2_VFIM1 := 0
						MsUnlock()
					Endif

				Endif

			End Transaction
		Else
			cLOGERRO += "- Nใo localizado movimentos. Registro: " + AllTrim(STR((cTABB2)->B2REG)) + "chave: " + (cTABB2)->B2_FILIAL + "/" + B2_COD + '/' + B2_LOCAL+ ENTER
		Endif

		(cTABMOV)->(DBCloseArea())

		(cTABB2)->(DBSKIP())
	Enddo
	(cTABB2)->(DBCloseArea())





	//Gera tela de LOG
	If !Empty(cLOGERRO)
		M := "*** Processamento Realizado - Log / Inconsist๊ncias / Advert๊ncias  ***" + ENTER + cLOGERRO
		GeraLog(M)
		cLOGERRO := ""
	else
		MsgInfo("processo executado com sucesso ")
	Endif

	cFilAnt := _cFilial

Return



//*************************************************************************************************************

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGeraLog   บAutor  ณMแrcio.Borges   บ Data ณ      05/06/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function GeraLog( cLogTxt )
	*********************************************************************
	__cFileLog := MemoWrite(Criatrab(,.F.)+".LOG",cLogTxt)

	Define FONT oFont NAME "Tahoma" Size 6,12
	Define MsDialog oDlgMemo Title "Consist๊ncia dos Dados" From 3,0 to 340,550 Pixel

	@ 5,5 Get oMemo  Var cLogTxt MEMO Size 265,145 Of oDlgMemo Pixel
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:=oFont
//Define SButton  From 153,205 Type 13 Action (cFile := cGetFile(cMask,""), Iif(cFile="",.T.,MemoWrite(cFile,cLogTxt)) ) Enable Of oDlgMemo Pixel
	Define SButton  From 153,205 Type 13 Action ({oDlgMemo:End(),Mysend(cLogTxt)}) Enable Of oDlgMemo Pixel
	Define SButton  From 153,235 Type 1 Action oDlgMemo:End() Enable Of oDlgMemo Pixel

	Activate MsDialog oDlgMemo Center

Return()
	*********************************************************************
Static Function Mysend(cTxt)
	*********************************************************************
	Static oDlg
	Static oButton1
	Static oButton2
	Static oGet1
	Static cGet1 := Space(200)
	Static oSay

	DEFINE MSDIALOG oDlg TITLE "Envio de Log" FROM 000, 000  TO 150, 300 COLORS 0, 12632256 PIXEL

	@ 031, 015 MSGET oGet1 VAR cGet1 SIZE 114, 010 OF oDlg PICTURE "@!" VALID !Empty(Alltrim(cGet1)) COLORS 0, 16777215 PIXEL
	@ 016, 015 SAY oSay PROMPT "Por favor, entre com seu email ABAIXO:" SIZE 100, 007 OF oDlg PICTURE "@!" COLORS 0, 12632256 PIXEL

	@ 050, 025 BUTTON oButton1 PROMPT "Enviar" SIZE 040, 012 OF oDlg ACTION {||oDlg:End(),DISMAILX(cGet1,cTxt)} PIXEL
	@ 050, 075 BUTTON oButton2 PROMPT "Sair" SIZE 040, 012 OF oDlg ACTION oDlg:End()  PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return
	*********************************************************************
Static Function DISMAILX(cMail,cTxt)
	*********************************************************************

	CONNECT SMTP SERVER GETMV("MV_RELSERV") ACCOUNT GETMV("MV_RELACNT") PASSWORD GETMV("MV_RELPSW") RESULT lResult

	If !lResult
		MsgBox('Erro no Envio')
		Return()
	EndIf

	cAccount := GETMV("MV_RELACNT")

	SEND MAIL FROM cAccount 	;
		TO      cMail	        	;
		SUBJECT FUNDESC()       	;//SUBJECT "Log Sx3 vs Banco" 	;
		BODY cTxt + CRLF + CRLF + FUNNAME() + " - " + FUNDESC()

	DISCONNECT SMTP SERVER

	MsgInfo("Email Enviado com Sucesso!")

Return()
