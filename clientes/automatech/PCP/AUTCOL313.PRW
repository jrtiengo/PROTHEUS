#INCLUDE 'APVT100.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE "TOPCONN.CH"
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE "AP5MAIL.CH"
#Include "Totvs.ch"
#Include "ApWebSrv.ch"
#INCLUDE "RPTDEF.CH"

#DEFINE ENTER (CHR(13)+CHR(10))

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±-±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AUTTELOP  ºAutor  ³                    º Data ³  04/05/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º          ³   O programa foi desenvolvido para funcionamento apenas    º±±
±±º          ³ na filial 04.                                              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AUTOMATECH                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±º12/02/2015³Jeferson Arteiro - SOLUTIO IT - Programa que fará a leitura º±±
±±º          ³das novas OP's e irá gerar os apontamentos das mesmas.      º±±
±±º          ³                                                            º±±
±±º14/09/2015³Mauro Silva - Solutio - Alterações no programa.             º±±
±±º          ³ Ajustado para fazer a leitura e gravação, assim como       º±±
±±º          ³ validar se o apontamento já foi iniciado.                  º±±
±±º          ³                                                            º±±
±±º19/10/2015³ Criado o parâmetro AUT_DOCMOV, com sequencial para a       º±±
±±º          ³movimentação interna do apontamento de separação.           º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AUTTELOP()

   Local k_Empresa := ""
   Local k_Filial  := ""
   
   If cEmpAnt == "01" .And. cFilAnt == "04"
      k_Empresa := "01"
      k_Filial  := "04"
   Endif
      
   If cEmpAnt == "03" .And. cFilAnt == "01"
      k_Empresa := "03"
      k_Filial  := "01"
   Endif

   PREPARE ENVIRONMENT EMPRESA k_Empresa FILIAL k_Filial USER 'Admin' PASSWORD '@tech15004' TABLES 'SC2,SH6,SH1,ZH6'

//	PREPARE ENVIRONMENT EMPRESA '99' FILIAL '01' USER 'Admin' PASSWORD '' TABLES 'SC2,SH6,SH1,ZH6'                   out()

VTClear()

VTSetSize(15,20)	//	Seta tamanho da tela (linha X coluna) // VTSetSize(18,26)
VTClear()
VTClearBuffer()

Private nQBeepErro	:= 2
Private nTBeepErro	:= 2500
Private nEstru		:= 0
Private aStru		:= {}
Private aEstrutura	:= {}

Private nMaxCol		:= VTMaxCol()	// VTMaxCol()+06  	// 25 + 6 = 31

Private cOP  		:= Space(16)
Private cCracha 	:= Space(07)
Private cMaquina	:= Space(07)
Private nQtd    	:= 0

Private cHoraIni	:= ""
Private cHoraFim	:= ""
Private dDataIni	:= ""
Private dDataFim	:= ""
Private cHoraRet	:= ""
Private lErroAuto := .F.
Private lMSErroAuto	:= .F.

Do While .T.
	
	cOpcao  	:= Space(1)
	VTClear()
	VTClearBuffer()
	TelaInfoPV('LEITURA_OP')
	VTClear()
	VTClearBuffer()
	Exit
	
EndDo

RESET ENVIRONMENT

Return()


/***
********************************************************************************
********************************************************************************
***| TelaInfoPV                   ||         Solutio          ||   /  /     |***
********************************************************************************
********************************************************************************
***| TELA PARA LER\VALIDAR A OP.                                            |***
***|                                                                        |***
***|                                                                        |***
********************************************************************************
********************************************************************************
***/

Static Function TelaInfoPV(cOpcao)

Do While .T.
	If TelaLerOP()
	Else
		EXIT
	EndIf
EndDo

Return()


/***
********************************************************************************
********************************************************************************
***| TelaLerOP                    ||         Solutio          ||   /  /     |***
********************************************************************************
********************************************************************************
***| ROTINA PARA APONTAMENTOS DAS OP'S.                                     |***
***|                                                                        |***
***|                                                                        |***
********************************************************************************
********************************************************************************
***/

Static Function TelaLerOP()

Local lRetorno 	:=	.T.
Local aOpera    := {}
Local VTSay     := 1

Do While .T.
	cOP  		:=	Space(16)
	cCracha 	:=  Space(06)
	cMaquina	:=  Space(07)
	nQtd    	:=  0
	
	VTClear()
	VTClearBuffer()
	
	nLin := 00
	
	@ nLin++,00 VTSay Replicate('-', nMaxCol)
	@ nLin++,00 VTSay PadC('AUTOMATECHA',   nMaxCol,'')
	@ nLin++,00 VTSay PadC('[Apontamento de OP]',nMaxCol,'')
	@ nLin++,00 VTSay Replicate('-', nMaxCol)
	nLin++
	
	@ nLin++,00 VTSay "Crachax: " VTGet cCracha		PICTURE "999999"	Valid(ValidaCra(left(cCracha,6)))
	@ nLin++,00 VTSay "Maquina: " VTGet cMaquina	PICTURE REPLICATE("X",06)	Valid(ValidaMaq(left(cMaquina,6)))
	@ nLin++,00 VTSay "OP.....: " VTGet cOP			PICTURE REPLICATE("X",16)
	//@ nLin++,00 VTSay "Qtd....: " VTGet nQtd		PICTURE "@E999999.99"
	nLin++
	@ nLin++,00 VTSay "  [ ESC ] Sair            "
	VTRead
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³  VERIFICA A OP             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cCracha := left(cCracha,6) 
	cMaquina:= left(cMaquina,6)
	
	cOperacao := SUBSTRING(cOP,12,2)
	cTpApo    := IIF(SUBSTR(cOP,14,2)$"01|02","P","T")
	cOP       := LEFT(cOP,11)
	
	If VTLastKey() == 27  .Or. Upper(AllTrim(cOP)) == "X"
		lRetorno := .F.
		Exit
	EndIf
	
	If Empty(cOP) .Or. Empty(cOperacao)
		VTClear()
		VTClearBuffer()
		VTBeep(nQBeepErro)
		If Empty(cOP)
			VTAlert("Informe o Numero da O.P.","Alerta.",.T., nTBeepErro)
		Else
			VTAlert("Informe o Numero da Operação","Alerta.",.T., nTBeepErro)
		EndIf
		Loop
	Else
		DbSelectArea("SC2")
		DbSetOrder(1)
		
		If Dbseek(xFilial("SC2") + cOP)
			If !Empty(C2_DATRF)
				VTClear()
				VTClearBuffer()
				VTBeep(nQBeepErro)
				VTAlert("O.P. já foi lida/encerrada.","Alerta.",.T., nTBeepErro)
				Loop	//	[ RETORNA PARA TELA INFO PEDIDO DE VENDA ]
			EndIf
		Else
			VTClear()
			VTClearBuffer()
			VTBeep(nQBeepErro)
			VTAlert("O.P. nao encontrada.","Alerta.",.T., nTBeepErro)
			Loop
		EndIf
		//Grava o apontamento na tabela temporária.
		ApontZH6(cOP,SC2->C2_PRODUTO,dDataBase,cOperacao,cMaquina,cTpApo,SC2->C2_QUANT)
	EndIf
EndDo
Return()


/***
********************************************************************************
********************************************************************************
***| ApontZH6                     || Mauro - Solutio          || 23/09/2015 |***
********************************************************************************
********************************************************************************
***| Inclui registro na tabela ZH6. Tabela intermediária, usada para        |***
***|iniciar o apontamento. No encerramento do apontamento, grava na SH6.    |***
***|                                                                        |***
********************************************************************************
********************************************************************************
***/

Static Function ApontZH6(cOP, cProd, dData, cOperacao, cMaquina,cTpApo,nQtdC2)

Local lValidAp		:= .T.
Local cQuery		:= {}
Local cQtdHora		:= 0
Local nCont			:= 0
Local cOpca			:= Space(1)
Local nD4qTD		:= 0
Local nD4qTA		:= 0
Local nD4qTO		:= 0
Local nPerc1		:= 0
Local nApont		:= 0
Local nRat			:= 0
Local nRat2			:= 0
Local nRat3			:= 0
Local nRat4			:= 0
local _cAp			:= space(1)
Local lValD4		:= .F.

Local lApont 		:= .T.

Local lValidOp 		:= .F.
Local nApontaOp 	:= 0
Local nApontaOA		:= 0
local nQop02		:=0
local aZd4			:= {}

Private nReco		:= 0
Private aStru		:= {}
Private aEstrutura	:= {}
Private lQtdMaior   :=.T.


// <<<<<< Valida se o apontamento já foi iniciado.
cQuery := " SELECT R_E_C_N_O_ AS ZH6RECNO, * "
cQuery += " FROM "+ RETSQLNAME("ZH6") +" ZH6 "
cQuery += " WHERE ZH6_FILIAL = '"+ XFILIAL("ZH6") +"' "
cQuery += " AND ZH6_OP = '"+ cOP +"' "
cQuery += " AND ZH6_PRODUT = '"+ cProd +"' "
cQuery += " AND ZH6_OPERAC = '"+ cOperacao +"' "
cQuery += " AND ZH6_HORAFI = '' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "ZH6TMP", .F., .T.)

DbSelectArea("ZH6TMP")

nReco := 0
nReco := ZH6TMP->ZH6RECNO


If nReco > 0
	lValidAp := .F.
EndIf

DbSelectArea("ZH6TMP")
DbCloseArea()

//Posiciona a tabela SD4 para validar existencia de saldo.
cQuery := " SELECT SUM(D4_QUANT) AS QUANT "
cQuery += " FROM "+ RETSQLNAME("SD4") +" SD4 "
cQuery += " WHERE D4_FILIAL = '"+ XFILIAL("SD4") +"' "
cQuery += " AND D4_OP = '"+ cOP +"' "
cQuery += " AND D4_LOCAL = '01' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "SD4TMP", .F., .T.)

DbSelectArea("SD4TMP")

If SD4TMP->QUANT > 0
	lValD4 := .T.
EndIf

DbSelectArea("SD4TMP")
DbCloseArea()

//Posiciona a tabela SH6 Para ver se já possui apontamento nesta operação
cQuery := " SELECT MAX(H6_QTDPROD) AS QUANT "
cQuery += " FROM "+ RETSQLNAME("SH6") +" SH6 "
cQuery += " WHERE H6_FILIAL = '"+ XFILIAL("SH6") +"' "
cQuery += " AND H6_OP = '"+ cOp +"' "
cQuery += " AND H6_OPERAC = '"+ cOperacao +"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "SH6TMP", .F., .T.)

DbSelectArea("SH6TMP")

If SH6TMP->QUANT > 0
	nApontaOp := SH6TMP->QUANT
Else
	nApontaOp := 0
	
	// Se for o primeiro apontamento da separação, clona o SD4, para que na produção, se tenha a quantidade apontada por componente.
	If cOperacao == "01"
		
		// Confirma se já não foram criados os registros desta OP.
		cQuery := " SELECT R_E_C_N_O_ AS ZD4RECNO, * "
		cQuery += " FROM "+ RETSQLNAME("ZD4") +" ZD4 "
		cQuery += " WHERE ZD4_FILIAL = '"+XFILIAL("ZD4")+"' "
		cQuery += " AND ZD4_OP = '"+ cOP +"' "
		cQuery += " AND D_E_L_E_T_ <> '*' "
		DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "ZD4TMP", .F., .T.)
		
		dbSelectArea("ZD4TMP")
		
		nRecoD4 := 0
		nRecoD4 := ZD4TMP->ZD4RECNO
		
		dbselectarea("ZD4TMP")
		dbclosearea()
		
		If nRecoD4 == 0
			cQuery := " SELECT D4_OP, D4_COD, D4_QTDEORI ,D4_QUANT "
			cQuery += " FROM "+ RETSQLNAME("SD4") +" SD4 "
			cQuery += " WHERE D4_FILIAL = '"+XFILIAL("SD4")+"' "
			cQuery += " AND D4_OP = '"+ cOP +"' "
			cQuery += " AND D4_LOCAL = '01' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "SD4TMP", .F., .T.)
			
			DbSelectArea("SD4TMP")
			DbGoTop()
			Do While !EOF()
				
				DbSelectArea("ZD4")
				RecLock("ZD4",.T.)
				ZD4->ZD4_FILIAL		:= XFILIAL("ZD4")
				ZD4->ZD4_OP			:= SD4TMP->D4_OP
				ZD4->ZD4_COD		:= SD4TMP->D4_COD
				ZD4->ZD4_QTDORI		:= SD4TMP->D4_QTDEORI
				ZD4->ZD4_QTD		:= SD4TMP->D4_QTDEORI
				MSUnLock()
				
				DbSelectArea("SD4TMP")
				DbSkip()
			EndDo
			PutMV("AUT_DOCMOV",1)
			DbSelectArea("SD4TMP")
			DbCloseArea()
		EndIf
	EndIf
EndIf

DbSelectArea("SH6TMP")
DbCloseArea()

//Posiciona a tabela SH6 Para ver a quantidade já liberada pela operação anterior
cQuery := " SELECT MAX(H6_QTDPROD) AS QUANT "
cQuery += " FROM "+ RETSQLNAME("SH6") +" SH6 "
cQuery += " WHERE H6_FILIAL = '"+XFILIAL("SH6")+"' "
cQuery += " AND H6_OP = '"+ cOp +"' "
cQuery += " AND H6_OPERAC = '"+ strzero((val(cOperacao)-1),2)+"' "
cQuery += " AND D_E_L_E_T_ <> '*' "
DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "SH6TMP", .F., .T.)

DbSelectArea("SH6TMP")

nApontaOA := SH6TMP->QUANT

DbSelectArea("SH6TMP")
DbCloseArea()

If nApontaOp >= nApontaOA
	lValidOp := .F.
Else
	lValidOp := .T.
EndIf

// <<<<<<
If cOperacao <> '01' .And. nApontaOA == 0
	VTClear()
	VTClearBuffer()
	VTBeep(4)
	nLin := 0
	@ nLin++,00 VTSay "ATENCAO"
	@ nLin++,00 VTSay "Nao foi realizada a operacao anterior."
	@ nLin++,00 VTSay "Tecle algo para sair:" VTGet cOpca
	VTRead
	Return()
EndIf

If lValidAp
	
	// <<<<<< No caso da operação 02, tenho que saber e mostrar o que já foi apontado. Caso contrário, sempre mostrará a quantidade
	// <<<<<< original dos componentes.
	// <<<<<< Arrumar!!!
	
	If lValD4  .Or. lValidOp
		DbSelectArea("ZH6")
		DbSetOrder(1)
		RecLock("ZH6", .T.)
		ZH6_FILIAL		:= XFILIAL("ZH6") // Se o programa for aterado para incluir outros filiais, alterar este registro.
		ZH6_OP			:= cOP
		ZH6_PRODUT		:= cProd
		ZH6_DTAPON		:= dData
		ZH6_DATAIN		:= dData
		ZH6_HORAIN		:= LEFT(TIME(),5)
		ZH6_OPERAC		:= cOperacao
		ZH6_RECURS		:= cMaquina
		ZH6_PT			:= cTpApo
		ZH6_LOCAL		:= "01"
		ZH6_OPERAD		:= cCracha
		MsUnlock()
		
		VTClear()
		VTClearBuffer()
		
		// Informa os componentes para as operações de separação (01) e produção (02).
		If cOperacao == "01" .Or. cOperacao == "02"
			// Explode a estrutura do produto.
			aStru	:= Estrut(cProd,1,.F.,.F.)
			nLin := 00
			
			For nCont := 1 To Len(aStru)
				
				nLin := 00
				
				//Para operação 01, mostra o saldo disponível na SD4 para separação. Para a 02, mostra o saldo da ZD4.
				If cOperacao == "01"
					cQuery := " SELECT D4_QUANT AS QUANT "
					cQuery += " FROM "+ RETSQLNAME("SD4") +" SD4 "
					cQuery += " WHERE D4_FILIAL = '"+XFILIAL("SD4")+"' "
					cQuery += " AND D4_OP = '"+ cOP +"' "
					cQuery += " AND D4_COD = '"+ aStru[nCont][3] +"' "
					cQuery += " AND D4_LOCAL = '01' "
				Else
					cQuery := " SELECT ZD4_QTD AS QUANT "
					cQuery += " FROM "+ RETSQLNAME("ZD4") +" ZD4 "
					cQuery += " WHERE ZD4_FILIAL = '"+XFILIAL("ZD4")+"' "
					cQuery += " AND ZD4_OP = '"+ cOP +"' "
					cQuery += " AND ZD4_COD = '"+ aStru[nCont][3] +"' "
				EndIf
				cQuery += " AND D_E_L_E_T_ <> '*' "
				DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "SD4TMP", .F., .T.)
				
				DbSelectArea("SD4TMP")
				
				nD4qTD := 0
				nD4qTD := SD4TMP->QUANT
				
				DbSelectArea("SD4TMP")
				DbCloseArea()
				
				// Posiciona a tabela SB1.
				cQuery := " SELECT B1_DESC AS NOME, B1_UM AS UNIDADE "
				cQuery += " FROM "+ RETSQLNAME("SB1") +" SB1 "
				cQuery += " WHERE B1_COD = '"+ aStru[nCont][3] +"' "
				cQuery += " AND D_E_L_E_T_ <> '*' "
				DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "SB1TMP", .F., .T.)
				
				DbSelectArea("SB1TMP")
				
				_cDesPrd	:= ""
				_cUMPrd		:= ""
				
				_cDesPrd	:= SB1TMP->NOME
				_cUMPrd		:= SB1TMP->UNIDADE
				
				DbSelectArea("SB1TMP")
				DbCloseArea()
				
				If (nD4qTD <=0)
					Loop
				EndIf
				
				@ nLin++,00 VTSay Replicate('-', nMaxCol)
				@ nLin++,00 VTSay PadC('AUTOMATECHB',   nMaxCol,'')
				
				If cOperacao == "01"
					@ nLin++,00 VTSay PadC('[Separa MP]',nMaxCol,'')
				Else
					@ nLin++,00 VTSay PadC('[MP Produção]',nMaxCol,'')
				EndIf
				
				@ nLin++,00 VTSay Replicate('-', nMaxCol)
				nLin++
				@ nLin++,00 VTSay "ITEM  : " + StrZero(nCont,2)+"/"+strzero(len(aStru),2)
				@ nLin++,00 VTSay "CÓDIGO: " + aStru[nCont][3] // Código do produto.
				@ nLin++,00 VTSay "DESCRI: " + Alltrim(_cDesPrd) // Descricão.
				@ nLin++,00 VTSay "UM    : " + Alltrim(_cUMPrd) // Unidade de medida.
				@ nLin++,00 VTSay "QUANT : " + Str(nD4qTD) // Quantidade do SD4.
				@ nLin++,00 VTSay Replicate('-', nMaxCol)
				
				nD4qTD := 0
				
				If nCont == len(aStru)
					@ nLin++,00 VTSay "Tecle algo para sair:" VTGet cOpca
				Else
					@ nLin++,00 VTSay "Tecle algo para o proximo item:" VTGet cOpca
				EndIf
				
				VTRead
				VTClear()
				VTClearBuffer()
				
			Next nCont
			
			// Limpa.
			aStru		:= {}
			aEstrutura	:= {}
		Else // Operação 03 em diante.
			
			_cString:=alltrim(posicione("SB1",1,xFilial("SB1")+cProd,"B1_DESC"))
			_cString02:=alltrim(posicione("SB1",1,xFilial("SB1")+cProd,"B1_DAUX"))
			_cString03:="Quantidade da OP:    "+alltrim(Str(SC2->C2_QUANT))+" "+posicione("SB1",1,xFilial("SB1")+cProd,"B1_UM")
			
			nLin := 00
			@ nLin++,00 VTSay Replicate('-', nMaxCol)
			@ nLin++,00 VTSay PadC('AUTOMATECHC',   nMaxCol,'')
			@ nLin++,00 VTSay PadC('[Produção]',nMaxCol,'')
			@ nLin++,00 VTSay Replicate('-', nMaxCol)
			@ nLin++,00 VTSay 'Produto :'
			@ nLin++,00 VTSay _cString
			@ nLin++,00 VTSay _cString02
			nLin++
			
			@ nLin++,00 VTSay   _cString03
			//	@ nLin++,00 VTSay PadC(Str(SC2->C2_QUANT),nMaxCol,'')
			nLin++
			@ nLin++,00 VTSay "Tecle algo para sair:" VTGet cOpca
			VTRead
		EndIf
	Else
		VTClear()
		VTClearBuffer()
		VTBeep(4)
		nLin := 0
		@ nLin++,00 VTSay "ATENCAO"
		@ nLin++,00 VTSay "Esta Operacao Nao Possui Mais Saldo"
		@ nLin++,00 VTSay "Tecle algo para sair:" VTGet cOpca
		VTRead
	EndIf
Else
	// Na separação, aponta por componente e baixa o saldo do SD4.
	If cOperacao == "01"
		If lValD4
			aStru	:= Estrut(cProd,1,.F.,.F.) // Explode a estrutura do PA.
			nRat	:= 0
			nRat2 := 100 / Len(aStru)    // Percentual para cada MP.
			
			For nCont := 1 to Len(aStru)
				
				nQtd := 0
				cQuery := " SELECT D4_QTDEORI ,D4_QUANT "
				cQuery += " FROM "+ RETSQLNAME("SD4") +" SD4 "
				cQuery += " WHERE D4_FILIAL = '"+XFILIAL("SD4")+"' "
				cQuery += " AND D4_OP = '"+ cOP +"' "
				cQuery += " AND D4_COD = '"+ aStru[nCont][3] +"' "
				cQuery += " AND D4_LOCAL = '01' "
				cQuery += " AND D_E_L_E_T_ <> '*' "
				DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "SD4TMP", .F., .T.)
				
				DbSelectArea("SD4TMP")
				
				nD4qTA := 0
				nD4qTA := SD4TMP->D4_QUANT
				
				DbSelectArea("SD4TMP")
				DbCloseArea()
				
				If nD4qTA <= 0
					Loop
				EndIf
				
				VTClear()
				VTClearBuffer()
				
				nLin := 00
				
				@ nLin++,00 VTSay PadC('[Separa MP]',nMaxCol,'')
				@ nLin++,00 VTSay PadC('[Informe a quantidade:]',nMaxCol,'')
				
				nLin++
				
				@ nLin++,00 VTSay "ITEM  : " + StrZero(nCont,2)+"/"+strzero(len(aStru),2)
				@ nLin++,00 VTSay "CÓDIGO: " + aStru[nCont][3] // Código do produto.
				@ nLin++,00 VTSay "DESCRI: " + Alltrim(Posicione("SB1",1,xFilial("SB1")+aStru[nCont][3],"B1_DESC")) // Descricão.
				@ nLin++,00 VTSay "UM    : " + Alltrim(Posicione("SB1",1,xFilial("SB1")+aStru[nCont][3],"B1_UM")) // Unidade de medida.
				nLinAp := nLin++
				nLin++
				nLin++
				@ nLin++,00 VTSay "APONTAR ITEM S-1/N-2" VTGet _cAp
				@ nLin++,00 VTSay "[ ESC ] Sair"
				VTRead
				
				If  _cAp=="1"
					@ nLinAp,00 VTSay "QUANT : " VTGet nQtd		PICTURE "@E999999.99"
					VTRead
					
					If nQtd > posicione("SD4",1,xFilial("SD4")+aStru[nCont][3]+cOp,"D4_QUANT")
						VTClear()
						VTClearBuffer()
						nLin := 00
						@ nLin++,00 VTSay 'Quantidade apontada '
						@ nLin++,00 VTSay 'Maior que o empenho '
						@ nLin++,00 VTSay 'Tecle Algo Para Sair'  VTGet _cAp
						VTRead
						
						Loop
					EndIf
				Else
					Loop
				EndIf
				
				// Posiciona na SD4 para para pegar o contador.
				cQuery := " SELECT SUM(D4_QTDEORI) AS ORIGINAL,SUM(D4_QUANT) AS RESTANTE   "
				cQuery += " FROM "+ RETSQLNAME("SD4")+" SD4 "
				cQuery += " WHERE D4_FILIAL = '"+XFILIAL("SD4")+"' "
				cQuery += " AND D4_OP = '"+ cOP +"' "
				cQuery += " AND D4_LOCAL = '01'"
				cQuery += " AND D_E_L_E_T_ <> '*' "
				DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "SD4TMP", .F., .T.)
				
				DbSelectArea("SD4TMP")
				
				nRat	:= 0
				nApont	:= 0
				nRat4	:= 0
				nApont	:= (SD4TMP->ORIGINAL - SD4TMP->RESTANTE)
				nRat4	:= SD4TMP->ORIGINAL
				
				DbSelectArea("SD4TMP")
				DbCloseArea()
				
				nPerc1	:= 0
				nRat3	:= 0
				nPerc1	:= 100/nRat4
				nRat3	:= nPerc1*(nApont+nQtd) // Para somas na ZH6.
				nRat	:= nRat + nRat3
				
				If	nQtd > 0
					U_IncReq(cOP,aStru[nCont][3],"01",nQtd)
				EndIf
				
			Next nCont
			
			nQtd := 0
			nQtd := nQtdC2 * (nRat/100)
			
			TransZH6()
			
		Else
			VTClear()
			VTClearBuffer()
			VTBeep(4)
			nLin := 0
			@ nLin++,00 VTSay "ATENCAO"
			@ nLin++,00 VTSay "Esta operacao nao possui mais saldo!"
			@ nLin++,00 VTSay "Tecle algo para sair:" VTGet cOpca
			VTRead
		EndIf
		// <<<<<< Incluir parte apenas para operação 02.
		// <<<<<< Assim como na primeira leitura, preciso saber se e quanto já houve apontamento para a produção.
	ElseIf cOperacao == "02"
		
		aStru	:= Estrut(cProd,1,.F.,.F.) // Explode a estrutura do PA.
		nRat	:= 0
		nRat2 := 100 / Len(aStru)    // Percentual para cada MP.
		
		
		For nCont := 1 to Len(aStru)
			
			nQtd := 0
			cQuery := " SELECT ZD4_QTDORI ,ZD4_QTD "
			cQuery += " FROM "+ RETSQLNAME("ZD4") +" ZD4 "
			cQuery += " WHERE ZD4_FILIAL = '"+XFILIAL("ZD4")+"' "
			cQuery += " AND ZD4_OP = '"+ cOP +"' "
			cQuery += " AND ZD4_COD = '"+ aStru[nCont][3] +"' "
			cQuery += " AND D_E_L_E_T_ <> '*' "
			DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "ZD4TMP", .F., .T.)
			
			DbSelectArea("ZD4TMP")
			
			nD4qTA := 0
			nD4qTA := ZD4TMP->ZD4_QTD
			
			If nD4qTA <= 0
  			    DbSelectArea("ZD4TMP")
			    DbCloseArea()
				alert("operação sem saldo")
				Loop
			EndIf
			
			VTClear()
			VTClearBuffer()
			
			nLin := 00
			
			@ nLin++,00 VTSay PadC('[Separa MP]',nMaxCol,'')
			@ nLin++,00 VTSay PadC('[Informe a quantidade:]',nMaxCol,'')
			
			nLin++
			
			@ nLin++,00 VTSay "ITEM  : " + StrZero(nCont,2)+"/"+strzero(len(aStru),2)
			@ nLin++,00 VTSay "CÓDIGO: " + aStru[nCont][3] // Código do produto.
			@ nLin++,00 VTSay "DESCRI: " + Alltrim(Posicione("SB1",1,xFilial("SB1")+aStru[nCont][3],"B1_DESC")) // Descricão.
			@ nLin++,00 VTSay "UM    : " + Alltrim(Posicione("SB1",1,xFilial("SB1")+aStru[nCont][3],"B1_UM")) // Unidade de medida.
			nLinAp := nLin++
			nLin++
			nLin++
			@ nLin++,00 VTSay "APONTAR ITEM S-1/N-2" VTGet _cAp
			@ nLin++,00 VTSay "[ ESC ] Sair"
			VTRead
			
			If  _cAp=="1"
				@ nLinAp,00 VTSay "QUANT : " VTGet nQtd		PICTURE "@E999999.99"
				VTRead
				
				If nQtd > nD4qTA   // Se quantidade apontada maior que saldo
					VTClear()
					VTClearBuffer()
					nLin := 00
					Conout('Quantidade apontada '+Str(nQtd,10,2) )
					Conout('Empenho '+STR(nD4qTA,10,2))
					@ nLin++,00 VTSay 'Quantidade apontada '+Str(nQtd,10,2)
					@ nLin++,00 VTSay 'Maior que o empenho '+STR(nD4qTA,10,2)
					@ nLin++,00 VTSay 'Tecle Algo Para Sair'  VTGet _cAp
					VTRead
    			    DbSelectArea("ZD4TMP")
     			    DbCloseArea()
					Loop
				EndIf
			Else
  			    DbSelectArea("ZD4TMP")
			    DbCloseArea()
				Loop
			EndIf
			

			// Posiciona na SD4 para para pegar o contador.
			//cQuery := " SELECT SUM(ZD4_QTDORI) AS ORIGINAL,SUM(ZD4_QTD) AS RESTANTE   "
			//cQuery += " FROM "+ RETSQLNAME("ZD4")+" ZD4 "
			//cQuery += " WHERE ZD4_FILIAL = '"+XFILIAL("ZD4")+"' "
			//cQuery += " AND ZD4_OP = '"+ cOP +"' "
			// cQuery += " AND ZD4_COD = '"+ aStru[nCont][3] +"' "
			//cQuery += " AND D_E_L_E_T_ <> '*' "
			//DbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "ZD4TMP", .F., .T.)
			
			DbSelectArea("ZD4TMP")
			
			nRat	:= 0
			nApont	:= 0
			nRat4	:= 0
			nApont	:= (ZD4TMP->ZD4_QTDORI - ZD4TMP->ZD4_QTD)
			nRat4	:= ZD4TMP->ZD4_QTDORI
			
			DbSelectArea("ZD4TMP")
			DbCloseArea()
			
			nPerc1	:= 0
			nRat3	:= 0
			nPerc1	:= 100/nRat4
			// nRat3	:= nPerc1*(nApont+nQtd) // Para somas na ZH6.
			nRat3	:= nPerc1 * nQtd // Para somas na ZH6.
			// nRat	:= nRat + nRat3
			nRat	+= nRat3
			nQop02 +=nRat
			AADD(aZd4,{aStru[nCont][3],nQtd})
			
		Next nCont
		
		nQtd := 0
		nQtd := nQtdC2 * (nQop02/100)
		conout("chamou a ZH6")
		
		_cQuery := " SELECT MAX(H6_QTDPROD)QTD FROM "+ RETSQLNAME("SH6") +" "
		_cQuery += " WHERE H6_OP = '"+cOP+"' AND H6_OPERAC ='"+STRZERO((VAL(cOperacao)-1),2)+"' AND D_E_L_E_T_ =" +"''"
		DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery), "TMPZH6", .F., .T.)
		
		DbSelectArea("TMPZH6")
		
		nQtdOp1 := TMPZH6->QTD
		
		DbSelectArea("TMPZH6")
		DbCloseArea()
		
		_cQuery := " SELECT SUM(H6_QTDPROD)QTD FROM "+ RETSQLNAME("SH6") +" "
		_cQuery += " WHERE H6_OP = '"+cOP+"' AND H6_OPERAC ='"+cOperacao+"' AND D_E_L_E_T_ =" +"''"
		DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery), "TMP2ZH6", .F., .T.)
		
		DbSelectArea("TMP2ZH6")
		
		nQtdOp := TMP2ZH6->QTD
		
		DbSelectArea("TMP2ZH6")
		DbCloseArea()
		
		
		If nQtdOp >0
			If	nQtdOp> nQtdOp1
				VTClear()
				VTClearBuffer()
				nLin := 00
				@ nLin++,00 VTSay "Operação ja foi finalizada "
				@ nLin++,00 VTSay " tecle para sair "	 VTGet nQtd
				VTRead
				
			Else
				nQtdOp := nQtdOp+nQtd
			EndIf
		Else
			nQtdOp := nQtd
		EndIf
		
		//	alert ("nQtdOp ="+str(nQtdOp)+" operação anterior "+str(nQtdOp1)+ "cOperacao"+cOperacao)
		nQtdOp1 := nQtdOp1 +0.01
		if nQtdOp > nQtdOp1
			alert("quantidade apontada na operacao é Maior que o disponivel ")
			alert("apontado ="+alltrim(str(nQtdOp))+" disponivel = "+alltrim(str(nQtdOp1)))
			if cOperacao = "03"
				alert ("verificando os 20%")
				nQtdOp1 := (nQtdOp1 * 1.20)
				//alert(str(nQtdOp1))
				if nQtdOp1  < nQtdOp
					alert("quantidade ultrapassa os 20%")
					lQtdMaior:=.F.
					return()
				endif
			else
				lQtdMaior:=.F.
				return()
			endif
		endif
		
		
		
		if lQtdMaior
			
			for i:=1 to len(aZd4)
				// Altera o saldo na ZD4.
				cQuery := " UPDATE "+ RETSQLNAME("ZD4") +" "
				cQuery += " SET  ZD4_QTD = (ZD4_QTD - "+ Alltrim(Str(aZd4[i][2])) +") "
				cQuery += " WHERE ZD4_OP = '"+ cOp +"' "
				cQuery += " AND ZD4_COD = '"+ aZd4[i][1] +"' "
				cQuery += " AND D_E_L_E_T_ <> '*' "
				TCSQLExec(cQuery)
			next i
			TransZH6()
			
			
		endif
		
		
	Else
		Do While lApont .AND. VTLastKey() <> 27  .AND. lQtdMaior
			
			VTClear()
			VTClearBuffer()
			
			nLin := 00
			@ nLin++,00 VTSay Replicate('-', nMaxCol)
			@ nLin++,00 VTSay PadC('AUTOMATECH QTD+',   nMaxCol,'')
			@ nLin++,00 VTSay PadC('[Informe a quantidade]',nMaxCol,'')
			@ nLin++,00 VTSay PadC('[da operação:]',nMaxCol,'')
			@ nLin++,00 VTSay Replicate('-', nMaxCol)
			nLin++
			@ nLin++,00 VTSay "Cracha.: " + cCracha
			@ nLin++,00 VTSay "Maquina: " + cMaquina
			@ nLin++,00 VTSay "OP.....: " + cOP
			@ nLin++,00 VTSay "Qtd....: " VTGet nQtd	PICTURE "@E999999.99"
			nLin++
			@ nLin++,00 VTSay "  [ ESC ] Sair            "
			VTRead
			
			if cOperacao ="02"
				
				_cQuery := " SELECT MAX(H6_QTDPROD)QTD FROM "+ RETSQLNAME("SH6") +" "
				_cQuery += " WHERE H6_OP = '"+cOP+"' AND H6_OPERAC ='"+STRZERO((VAL(cOperacao)-1),2)+"' AND D_E_L_E_T_ =" +"''"
				DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery), "TMPZH6", .F., .T.)
				
				DbSelectArea("TMPZH6")
				
				nQtdOp1 := TMPZH6->QTD
				
				DbSelectArea("TMPZH6")
				DbCloseArea()
				
				_cQuery := " SELECT SUM(H6_QTDPROD)QTD FROM "+ RETSQLNAME("SH6") +" "
				_cQuery += " WHERE H6_OP = '"+cOP+"' AND H6_OPERAC ='"+cOperacao+"' AND D_E_L_E_T_ =" +"''"
				DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery), "TMP2ZH6", .F., .T.)
				
				DbSelectArea("TMP2ZH6")
				
				nQtdOp := TMP2ZH6->QTD
				
				DbSelectArea("TMP2ZH6")
				DbCloseArea()
			else
				_cQuery := " SELECT SUM(H6_QTDPROD)QTD FROM "+ RETSQLNAME("SH6") +" "
				_cQuery += " WHERE H6_OP = '"+cOP+"' AND H6_OPERAC ='"+STRZERO((VAL(cOperacao)-1),2)+"' AND D_E_L_E_T_ =" +"''"
				DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery), "TMPZH6", .F., .T.)
				
				DbSelectArea("TMPZH6")
				
				nQtdOp1 := TMPZH6->QTD
				
				DbSelectArea("TMPZH6")
				DbCloseArea()
				
				_cQuery := " SELECT SUM(H6_QTDPROD)QTD FROM "+ RETSQLNAME("SH6") +" "
				_cQuery += " WHERE H6_OP = '"+cOP+"' AND H6_OPERAC ='"+cOperacao+"' AND D_E_L_E_T_ =" +"''"
				DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery), "TMP2ZH6", .F., .T.)
				
				DbSelectArea("TMP2ZH6")
				
				nQtdOp := TMP2ZH6->QTD
				
				DbSelectArea("TMP2ZH6")
				DbCloseArea()
				
				
			ENDIF
			conout("nQtdOP: "+str(nQtdOp))
			If nQtdOp >0
				If	nQtdOp> nQtdOp1
					VTClear()
					VTClearBuffer()
					nLin := 00
					@ nLin++,00 VTSay "Operação ja foi finalizada "
					@ nLin++,00 VTSay " tecle para sair "	 VTGet nQtd
					VTRead
					Loop
				Else
					nQtdOp := nQtdOp+nQtd
				EndIf
			Else
				nQtdOp := nQtd
			EndIf
			
			//	alert ("nQtdOp ="+str(nQtdOp)+" operação anterior "+str(nQtdOp1)+ "cOperacao"+cOperacao)
			
			if nQtdOp > nQtdOp1
				alert("quantidade apontada maior que a disponivel para a operação ")  
					alert("apontado = "+alltrim(str(nQtdOp))+" disponivel = "+alltrim(str(nQtdOp1)))
				if cOperacao = "03"
					alert ("verificando os 20%")
					nQtdOp1 := (nQtdOp1 * 1.20)
					//alert(str(nQtdOp1))
					if nQtdOp1  < nQtdOp
						alert("quantidade ultrapassa os 20%")
						lQtdMaior:=.F.
						loop
						exit
						return()
						
					endif
				else
					lQtdMaior:=.F.
					loop
					exit
					return()
				endif
			endif
			
			
			
			
			
			/*  	 nQtdOp > nQtdOp1 .and.
			VTClear()
			VTClearBuffer()
			nLin := 00
			@ nLin++,00 VTSay "0 Apontado "
			@ nLin++,00 VTSay "E maior que o da ultima"
			@ nLin++,00 VTSay "opracao, tecle algo para sair" VTGet nQtd
			lApont := .T.
			VTRead
			Loop
			*/
			lApont := .F.
			//
		EndDo
		
		Begin Transaction
		if !lQtdMaior
			DisarmTransaction()
			Conout(" Erro na alteracao do registro recno no. "+Alltrim(Str(nReco))+", OP: "+Alltrim(cOP)+".")
			VTClear()
			VTClearBuffer()
			VTBeep(nQBeepErro)
			return
		endif
		
		
		_cQuery := " SELECT SUM(H6_QTDPROD)QTD FROM "+ RETSQLNAME("SH6") +" "
		_cQuery += " WHERE H6_OP = '"+cOP+"' AND H6_OPERAC ='"+cOperacao+"' AND D_E_L_E_T_ =" +"''"
		DbUseArea(.T., "TOPCONN", TCGenQry(,,_cQuery), "TMP0101", .F., .T.)
		
		DbSelectArea("TMP0101")
		IF !EMPTY(TMP0101->QTD) .AND.TMP0101->QTD >0
			_QTDPROD := TMP0101->QTD
		ELSE
			_QTDPROD:=0
		ENDIF
		
		DbSelectArea("TMP0101")
		DbCloseArea()
		
		
		if (nQtd+_QTDPROD) > posicione("SC2",1,xFilial("SC2")+cOp,"C2_QUANT") .AND. cOP ='03'
			DbselectArea("SC2")
			DbsetOrder(1)
			dbseek(xFilial("SC2")+cOp)
			if ((SC2->C2_QUANT * 1,21) > (nQtd+_QTDPROD))
				RecLock("SC2",.F.)
				SC2->C2_QUANT := (nQtd+_QTDPROD)
				SC2->(MsUnlock())
				//SC2->(DbcloseArea())
			else
				alert("quantidade apontada Ultrapassa 20% ")
				DisarmTransaction()
				return .F.
			endif
			
		EndIf
		
		
		cQuery := " UPDATE "+ RETSQLNAME("ZH6") +" "
		Cquery += " SET  ZH6_DATAFI = '"+ Dtos(dDataBase) +"', "
		cQuery += " ZH6_HORAFI = '"+ LEFT(TIME(),5) +"', "
		cQuery += " ZH6_QTDPRO = "+ Str(nQtd) +", "
		cQuery += " ZH6_PT = '"+ cTpApo +"' "
		cQuery += " WHERE R_E_C_N_O_ = "+ Alltrim(Str(nReco)) +" "
		
		If (TCSQLExec(cQuery) < 0)
			
			
			
			DisarmTransaction()
			Conout(" Erro na alteracao do registro recno no. "+Alltrim(Str(nReco))+", OP: "+Alltrim(cOP)+".")
			
			VTClear()
			VTClearBuffer()
			VTBeep(nQBeepErro)
			VTAlert((" Erro na alteracao do registro recno no. "+Alltrim(Str(nReco))+", OP: "+Alltrim(cOP)+"."),"Alerta.",.T., nTBeepErro)
		Else
			Conout(" Alteracao do registro recno no. "+Alltrim(Str(nReco))+", OP "+Alltrim(cOP)+", realizada com sucesso.")
			
			// Posiciona o registro do ZH6.
			If nReco > 0
				ZH6->(dbClearFilter())
				ZH6->(dbGoTo(nReco))
				
				// Chama a rotina de apontamento no SH6.
				U_IncApont(ZH6->ZH6_OP, ZH6->ZH6_PRODUT, ZH6->ZH6_DTAPON, ZH6->ZH6_DATAIN, ZH6->ZH6_DATAFI, ZH6->ZH6_HORAIN, ZH6->ZH6_HORAFI,;
				ZH6->ZH6_OPERAC, ZH6->ZH6_RECURS, ZH6->ZH6_PT, ZH6->ZH6_LOCAL, ZH6->ZH6_OPERAD, ZH6->ZH6_QTDPRO)
			EndIf
		EndIf
		End Transaction
	EndIf
EndIf

Return()

/***
********************************************************************************
********************************************************************************
***| TransZH6                     ||   Mauro-Solutio          ||   /  /     |***
********************************************************************************
********************************************************************************
***|                                                                        |***
***|                                                                        |***
***|                                                                        |***
********************************************************************************
********************************************************************************
***/

Static Function TransZH6()

Begin Transaction

lValidAp := .F.

cQuery := " UPDATE "+ RETSQLNAME("ZH6") +" "
Cquery += " SET  ZH6_DATAFI = '"+ Dtos(dDataBase) +"', "
cQuery += " ZH6_HORAFI = '"+ LEFT(TIME(),5) +"', "
cQuery += " ZH6_QTDPRO = "+ Str(nQtd) +", "
cQuery += " ZH6_PT = '"+ cTpApo +"' "
cQuery += " WHERE R_E_C_N_O_ = "+ Alltrim(Str(nReco)) +" "

If (TCSQLExec(cQuery) < 0)
	DisarmTransaction()
	Conout(" Erro na alteracao do registro recno no. "+Alltrim(Str(nReco))+", OP: "+Alltrim(cOP)+".")
	
	VTClear()
	VTClearBuffer()
	VTBeep(nQBeepErro)
	VTAlert((" Erro na alteracao do registro recno no. "+Alltrim(Str(nReco))+", OP: "+Alltrim(cOP)+"."),"Alerta.",.T., nTBeepErro)
Else
	Conout(" Alteracao do registro recno no. "+Alltrim(Str(nReco))+", OP "+Alltrim(cOP)+", realizada com sucesso.")
	
	// Posiciona o registro do ZH6.
	If nReco > 0
		ZH6->(dbClearFilter())
		ZH6->(dbGoTo(nReco))
		
		// Chama a rotina de apontamento no SH6.
		U_IncApont(ZH6->ZH6_OP, ZH6->ZH6_PRODUT, dDataBase, ZH6->ZH6_DATAIN, ZH6->ZH6_DATAFI, ZH6->ZH6_HORAIN, ZH6->ZH6_HORAFI,;
		ZH6->ZH6_OPERAC, ZH6->ZH6_RECURS, ZH6->ZH6_PT, ZH6->ZH6_LOCAL, ZH6->ZH6_OPERAD, nQtd)
	EndIf
EndIf
End Transaction

Return()

/***
********************************************************************************
********************************************************************************
***| IncApont                     ||         Solutio          ||   /  /     |***
********************************************************************************
********************************************************************************
***| Faz a inclusão do apontamento da operação da OP.                       |***
***|                                                                        |***
***|                                                                        |***
********************************************************************************
********************************************************************************
***/

User Function	IncApont(cOP, cProd, dDataAp, dDataIn, dDataFi, cHoraIn, cHoraFi, cOperacao, cMaquina, cTpApo, cLocal, cOperad, nQtdProd)

Local aRotAuto	:= {}
Local nOpc		:= 3 // inclusao
Local cQuery	:= {}
Local lRet		:= .F.

Private lMsHelpAuto := .F. // se .T. direciona as mensagens de help para o arq. de log.
conout ("entrou na SH6")
VTClear()
VTClearBuffer()
VTBeep(1)
VTAlert("Realizando apontamento","Aguarde, por favor..",.T., nTBeepErro)


Begin Transaction

aRotAuto := {;
{"H6_FILIAL"	,xFilial("ZH6")					,NIL},;
{"H6_OP"		,cOP							,NIL},;
{"H6_PRODUTO"	,cProd							,NIL},;
{"H6_DTAPONT"	,dDataAp						,NIL},;
{"H6_DATAINI"	,dDataIn						,NIL},;
{"H6_DATAFIN"	,dDataFi						,NIL},;
{"H6_HORAINI"	,cHoraIn						,NIL},;
{"H6_HORAFIN"	,cHoraFi						,NIL},;
{"H6_OPERAC"	,cOperacao						,NIL},;
{"H6_RECURSO"	,cMaquina						,NIL},;
{"H6_PT"		,cTpApo							,NIL},;
{"H6_LOCAL"		,cLocal							,NIL},;
{"H6_OPERADO"	,cOperad						,NIL},;
{"H6_QTDPROD"	,nQtdProd						,NIL}}

MSExecAuto({|x,y| mata681(x,y)},aRotAuto,nOpc)

If lMsErroAuto
    conout ("Erro AUTCOL313 Linha 1181 - MATA681 Filial SM0 "+SM0->M0_CODFIL +SM0->M0_FILIAL)
    conout ("H6_FILIAL   ,"	+ xFilial("ZH6") )
    conout ("H6_OP       ," + cOP	         )
    conout ("H6_PRODUTO  ," + cProd	         )
    conout ("H6_DTAPONT  ," + DTOC(dDataAp)  )
    conout ("H6_DATAINI  ," + DTOC(dDataIn)  )
    conout ("H6_DATAFIN  ," + DTOC(dDataFi)  )
    conout ("H6_HORAINI  ," + cHoraIn        )
    conout ("H6_HORAFIN  ," + cHoraFi        )
    conout ("H6_OPERAC   ," + cOperacao      )
    conout ("H6_RECURSO  ," + cMaquina       )
    conout ("H6_PT       ," + cTpApo         )
    conout ("H6_LOCAL    ," + cLocal         )
    conout ("H6_OPERADO  ," + cOperad        )
    conout ("H6_QTDPROD  ," + STR(nQtdProd,10,2)  )
	MostraErro()
	DisarmTransaction()
	Break
EndIf
End Transaction

If lMsErroAuto
	MostraErro()
	alert("erro no exec auto da SH6")
	MostraErro()
	VTClear()
	VTClearBuffer()
	VTBeep(nQBeepErro)
	Return(.F.)
Else
	VTClear()
	VTClearBuffer()
	VTBeep(2)
	VTAlert("Apontamento realizado.","Alerta.",.T., nTBeepErro)
	lRet := .T.
EndIf

Return(lRet)


/***
********************************************************************************
********************************************************************************
***| ValidaCra                    ||         Solutio          ||   /  /     |***
********************************************************************************
********************************************************************************
***| Valida a existencia do cracha.                                         |***
***|                                                                        |***
***|                                                                        |***
********************************************************************************
********************************************************************************
***/

Static Function ValidaCra(cCracha)

Local lRet := .F.     
//Verifica a existencia do cracha
If Empty(cCracha)
	VTClear()
	VTClearBuffer()
	VTBeep(nQBeepErro)
	VTAlert("Informe o Numero do Cracha","Alerta.",.T., 5 )
	lRet := .F.		//	[ RETORNA PARA TELA INFO PEDIDO DE VENDA ]
Else
	DbSelectArea("SX5")
	DbSetOrder(1)
	DbSeek(xFilial("SX5")+'Z5')

	Do While SX5->(X5_FILIAL+ X5_TABELA) == xFilial("SX5")+'Z5'
		If ALLTRIM(SX5->X5_CHAVE) == ALLTRIM(cCracha)
			lRet := .T.
			Exit
		EndIf
		
		SX5->(DbSkip())
	EndDo
	
	If ! lRet
		VTClearBuffer()
		VTBeep(nQBeepErro)
		VTAlert("Numero de Cracha Inexistente","Alerta.",.T., 5 )
		lRet := .F.
	EndIf
EndIf

Return(lRet)


/***
********************************************************************************
********************************************************************************
***| ValidaMaq                    ||         Solutio          ||   /  /     |***
********************************************************************************
********************************************************************************
***| Valida a existencia da maquina.                                        |***
***|                                                                        |***
***|                                                                        |***
********************************************************************************
********************************************************************************
***/

Static Function ValidaMaq(cMaquina)

Local lRet := .F.

If Empty(cMaquina)
	VTClearBuffer()
	VTBeep(nQBeepErro)
	VTAlert("Informe o Numero da Maquina.","Alerta.",.T., nTBeepErro)
	lRet := .F.
Else
	DbSelectArea("SH1")
	DbSetOrder(1)
	
	If ! Dbseek(xFilial("SH1") + cMaquina)
		VTClearBuffer()
		VTBeep(nQBeepErro)
		VTAlert("Maquina nao encontrada.","Alerta.",.T., nTBeepErro)
		lRet := .F.
	Else
		lRet := .T.
	Endif
Endif

Return(lRet)


/***
********************************************************************************
********************************************************************************
***| IncReq                     ||         Solutio          ||   /  /       |***
********************************************************************************
********************************************************************************
***| faz a requisição do material para a op 		                        |***
***|                                                                        |***
***|                                                                        |***
********************************************************************************
********************************************************************************
***/

User Function IncReq(cOP,cProd,cLocal,nQtdProd)

Local aItem			:= {}
Local cAux			:= Left(ALLTRIM(cOP),6)+"V"+StrZero(GETMV("AUT_DOCMOV"),2)
Local lErroM		:= .F.
Local cTrt         	:=""



Dbselectarea("SD4")
DbsetOrder(2)
If Dbseek(xFilial("SD4")+cOP+"  "+cProd+cLocal)
	cTrt:=SD4->D4_TRT
	DbCloseArea("SD4")
	conout("achou no seek SD4")
else
	conout("não cahou no seek SD4")
	conoutt(cOP+"  "+cProd+cLocal)
endif




conout("inicia a  função")
///	begintransaction()

PutMV("AUT_DOCMOV",(GETMV("AUT_DOCMOV")+1))
conout("pega o parametro")

aItem :=	{  {"D3_FILIAL"    ,xFilial("SD3") ,NIL },;
{"D3_TM"		,"600"			,NIL},;
{"D3_CF"		,"RE0"			,NIL},;
{"D3_COD"		,cProd			,NIL},;
{"D3_QUANT"		,nQtdProd		,NIL},;
{"D3_LOCAL"		,cLocal			,NIL},;
{"D3_NUMSEQ"	,"001"			,NIL},;
{"D3_OP"		,cOP			,NIL},;
{"D3_DOC"		,cAux			,NIL},;
{"D3_EMISSAO"	,dDataBase		,NIL},;
{"D3_TRT"	,cTrt         		,NIL};
}
conout("durante o exec auto")
MsExecAuto({|x,y| mata240(x,y)},aItem,3) //Inclusao

If lMsErroAuto
	
	lErroM := .T.
	
	_cErro:=	MostraErro()
	DisarmTransaction()
	conout("teste, "+_cErro)
	VTAlert("erro "+_cErro,"Alerta.",.T., nTBeepErro)
	
	//	Break
	
EndIf
conout("termina o exec auto")
Return()
