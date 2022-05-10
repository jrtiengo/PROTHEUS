#Include "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"

#INCLUDE "RWMAKE.CH"
#include "ap5mail.ch"


#define ENTER Chr(13)+Chr(10)

/*/{Protheus.doc} BACA004
Infobox X Protheus - BACA: Verifica Opดs filhas de Opดs PAI finalizada e realiza o apontamento da quantidade pendente.
@type function
@version 1.0
@author Mแrcio Borges
@since 02/03/2021
/*/
User Function BACA004()
	Processa({|| Roda()},"Analisando e efetuando apontamentos...")
REturn

Static Function Roda()

	Local aSetField := {}
	Local aTamSX3
	Local cQuery    := ""
	Local _cFilial // filial temporแria


	Private cBASE    := GetNextAlias() //Alias Tabela Temporแria
	PRIVATE cLOGERRO := ""
	Private dMVUlmes

	_cFilial := cFilAnt


	dMVUlmes := SUPERGETMV("MV_ULMES",.f.,SPACE(8))

//********  busca faturamento do m๊s ==> retorna pedido e item

	aTamSX3 := TAMSX3("H6_DATAINI")
	AADD(aSetField,{"H6_DATAINI", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
	aTamSX3 := TAMSX3("H6_DATAFIN")
	AADD(aSetField,{"H6_DATAFIN", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
	aTamSX3 := TAMSX3("H6_QTDPROD")
	AADD(aSetField,{"H6_QTDPROD", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })


	cQuery := ""
	cQuery += " SELECT COUNT(*) OVER ( PARTITION BY '1') QTDREG,H6_OPERAC, H6_OP, H6_PRODUTO, H6_DATAINI, H6_HORAINI, H6_DATAFIN, H6_HORAFIN, H6_QTDPROD ,  A.C2_SEQPAI,"
	cQuery += " A.* FROM  "+ RetSqlName("SC2") +" A, "+ RetSqlName("SH6") +" SH6 WHERE C2_FILIAL = '0102' AND A.D_E_L_E_T_  <> '*' AND C2_SEQUEN <> '001' "
	cQuery += " AND C2_QUANT > C2_QUJE AND "
	//cQuery += " AND round(C2_QUANT,2) > round(C2_QUJE,2)
	cQuery += "   EXISTS (SELECT 1 FROM "+ RetSqlName("SC2") +" B WHERE B.D_E_L_E_T_  <> '*' AND B.C2_FILIAL = A.C2_FILIAL AND B.C2_NUM = A.C2_NUM AND B.C2_SEQUEN = A.C2_SEQPAI AND B.C2_QUANT = B.C2_QUJE )"
	cQuery += " AND SH6.D_E_L_E_T_  <> '*' AND H6_FILIAL = C2_FILIAL AND H6_OP = C2_NUM + C2_ITEM +'001' "
	cQuery += " AND H6_DATAINI > '" + DTOS(dMVUlmes) + "'"
	
	cQuery += "	and H6_DATAFIN like  '202103%'"

	//cQuery += " AND C2_NUM = '028898' "

	MPSysOpenQuery( cQuery, cBASE, aSetField  )

	If (cBASE)->(!EOF())
		ProcRegua(40) //ProcRegua((cBASE)->QTDREG)
	Endif

	Do While (cBASE)->(!EOF())

		IncProc("OP " + (cBASE)->(C2_NUM + C2_ITEM + C2_SEQUEN))
		dDatabase := (cBASE)->H6_DATAINI
		cFilAnt := (cBASE)->C2_FILIAL //Fixa Filial da OP
		//-- Localiza os pedidos e itens faturados ==> retorna OFinfobox
		fAponFilh((cBASE)->C2_NUM,(cBASE)->H6_PRODUTO,(cBASE)->C2_SEQPAI,(cBASE)->H6_QTDPROD) // N๚mero da Op, produto_pai, sequen_pai, qtd_pai

		(cBASE)->(DBSKIP())
	Enddo


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

/*/{Protheus.doc} fAponFilh
Ajusta cadastro de roteiro 
@type function
@version 25
@author Manoel Mariante
@since 01/11/2019
@param cNumOp, character, N๚mero da Op
@param cProd, character, Produto Pai
@param cSequen, character, Sequencia da OP Pai
@param nQtdPai, numeric, Quantidade Apontada do Pai
/*/
Static Function fAponFilh(cNumOp,cProd,cSequen,nQtdPai)
/*
nFullPai = 420 //Quantidade total da OP do Pai
nQtdApontadaPai = 120
			
nQtd APfilho = 27,5577
			
Proporcional_apontado_pai: = nQtdApontadaPai/nFullPai
Proporcional_apontado_filho = Proporcional_apontado_pai * nOpFilho
*/
	Local aArea		:=GetArea()

	Local cTRB	:= GetNextAlias() //Alias Tabela Temporแria
	Local aSetField := {}
	Local aTamSX3

	Local nFullPai 	:= 0
	Local nProporc	:= 0
	Local nApont	:= 0 //Apontamento proporcionalidado ao pai
	Local cQuery 	:= ""
	Default nQtdPai	:= 0

	aTamSX3 := TAMSX3("C2_QUANT")
	AADD(aSetField,{"C2_QUANT", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })


	// Busca quantidade original do Pai para proporcionalizar o apontamento
	cQuery += "SELECT C2_FILIAL, C2_NUM, C2_PRODUTO,C2_ITEM, C2_SEQUEN, C2_QUANT, C2_ROTEIRO  FROM " + RetSqlName("SC2") + " WHERE C2_FILIAL = '"+ xFilial("SC2") + "' AND C2_NUM = '" + cNumOp + "' AND C2_SEQUEN = '" + cSequen + "' AND D_E_L_E_T_  <> '*'"
	MPSysOpenQuery( cQuery, cTRB,aSetField  )

	If (cTRB)->(EOF())
		Return
	Else
		nFullPai := (cTRB)->C2_QUANT
		nProporc := nQtdPai / nFullPai   //Qtd apontada pai / total op pai
		cRotPai	 := (cTRB)->C2_ROTEIRO

		// Busca Filhos para Serem Apontados
		cQuery :=  "SELECT C2_FILIAL, C2_NUM, C2_ITEM, C2_PRODUTO, C2_SEQUEN, C2_ITEMGRD, C2_QUANT , C2_QUJE FROM " + RetSqlName("SC2") + " WHERE C2_FILIAL = '"+ xFilial("SC2") + "'  AND C2_NUM = '" + cNumOp + "' AND C2_SEQPAI = '" + cSequen + "' AND C2_QUANT > C2_QUJE AND C2_STATUS = 'N' AND D_E_L_E_T_  <> '*'"
		cQuery += "		AND NOT EXISTS (SELECT 1 FROM " + RetSqlName("SH6") + " SH6 WHERE SH6.D_E_L_E_T_ = '*' AND  H6_FILIAL = C2_FILIAL AND H6_DATAINI = '"+ DTOS((cBASE)->H6_DATAINI) + "' AND H6_QTDPROD = C2_QUANT*" + STRTRAN(STR(nProporc),",",".") + " AND H6_OP = C2_NUM + C2_ITEM + C2_SEQUEN )"
		MPSysOpenQuery( cQuery, cTRB,aSetField  )



		Do While (cTRB)->(!EOF())


			dbSelectArea('SC2')
			dbSetOrder(1) //C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
			If dbSeek(xFilial('SC2')+ (cTRB)->(C2_NUM+C2_ITEM+C2_SEQUEN))

				//Verifica Roteiro do filho corresponde ao do pai
				IF cRotPai <> SC2->C2_ROTEIRO
					RecLock("SC2", .F.)
					SC2->C2_ROTEIRO := cRotPai
					MsUnlock()
				ENDIF
				//Verifica Se roteiro de opera็ใo estแ cadastrado
				u_fCargaG2(SC2->C2_PRODUTO)

				//Efetua o Apontamento
				nApont := (cTRB)->C2_QUANT * nProporc
				//se a quantidade para  apontar for maior que a que falta, ou
				IF nApont > ((cTRB)->C2_QUANT - (cTRB)->C2_QUJE ) .OR. INT((cTRB)->C2_QUANT - (cTRB)->C2_QUJE ) == INT(nApont)
					nApont := ((cTRB)->C2_QUANT - (cTRB)->C2_QUJE )
				ENDIF
				fAponSH6(nApont)

				//Recursividade para apontar os filhos dos filhos
				//fAponFilh(SC2->C2_NUM,SC2->C2_PRODUTO,SC2->C2_SEQUEN,nApont)
				(cTRB)->(DBSKIP())
			Endif
		Enddo
		RestArea(aArea)

	Endif

	(cTRB)->(DBCloseArea())
Return

/*/{Protheus.doc} fAponSH6
Realiza apontamento de Produ็ใo 
@type function
@version 
@author Manoel Mariante
@since 01/12/2019
@param nQuant, numeric, param_description
@return return_type, return_description
/*/
Static Function fAponSH6(nQuant)
	Local aCabec:={}
	Local aArea		:=GetArea()
	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.

	cErro:=""

	dDataIni 	:= (cBASE)->H6_DATAINI
	dDataFim	:= (cBASE)->H6_DATAFIN

	If dDataIni <= dMVUlmes
		dDataIni := dMVUlmes+1
		dDataFim := dDataIni
		dDataBase := dDataIni
	Endif

	aAdd( aCabec,{"H6_OP"      , SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)	,NIL})
	aAdd( aCabec,{"H6_PRODUTO" , SC2->(C2_PRODUTO)	,NIL})
	aAdd( aCabec,{"H6_LOCAL"   , SC2->(C2_LOCAL)	,NIL})
	aAdd( aCabec,{"H6_OPERAC"  , "10"				,NIL})
//	aAdd( aCabec,{"H6_FERRAM"  , ""	            	,NIL})
	aAdd( aCabec,{"H6_DATAINI" , dDataIni				,NIL})
	aAdd( aCabec,{"H6_HORAINI" , (cBASE)->H6_HORAINI	,NIL})
	aAdd( aCabec,{"H6_DATAFIN" , dDataFim				,NIL})
	aAdd( aCabec,{"H6_HORAFIN" , (cBASE)->H6_HORAFIN	,NIL})
	//aAdd( aCabec,{"H6_RECURSO"  , oJson:H6_RECURSO	,NIL})
	aAdd( aCabec,{"H6_QTDPROD"  , nQuant				,NIL})
	//aAdd( aCabec,{"H6_QTDPERD"  , oJson:H6_QTDPERD		,NIL})
	aAdd( aCabec,{"H6_DTAPONT"  , dDataIni				,NIL} )

	//Nใo utiliza o recurso em caso de erro de gerar apontamento Pendente na T4K
	// 1 - Nใo gera apontamento pendente
	// 2 - Faz Apontamento Pendente somente se houver Erros. [padrใo]
	// 3 - Sempre Pendente - todos os apontamentos ficam como pendente

	aAdd(aCabec,{"PENDENTE","1",Nil}) // doc: https://centraldeatendimento.totvs.com/hc/pt-br/articles/360051976953-MP-ADVPL-Apontamentos-Pendentes-Tabela-T4K


	u_LogConsole("BACA004", "vou processar op filha "+sc2->c2_sequen)

	MSExecAuto( {|x,y| MATA681(x,y)}, aCabec, 3 )//3- Inclusใo, 4- Altera็ใo, 5- Exclusใo

	If lMsErroAuto

		aMsg := GetAutoGRLog()
		aEval(aMsg,{|x| cErro += x + CRLF })

		lOk := .F.

		If Empty(aMsg)
			cMsgErro := "Erro nใo Identificado - Protheus (execauto MATA681)"
		Else
			//Carrega somente primeiras linhas do erro
			aMsgB      := StrTokArr(aMsg[1], CRLF)
			If Len(aMsgB) >= 2
				cMsgErro := aMsgB[1] + " - " + aMsgB[2]
			Else
				cMsgErro := SUBSTR("Problema na Gera็ใo da OP Filha? " + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN) + " |Qtd: " + AllTrim(Str(nQuant)) + " | Data: " +  DTOC(dDataIni) + CRLF + aMsgB[1],1,(TamSX3("Z1_RETORNO")[1])-3) + "..."
			Endif

		Endif
		cLOGERRO += "ERRO apontamento OP " + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN) + " |Qtd: " + AllTrim(Str(nQuant)) + " | Data: " +  DTOC(dDataIni) + CRLF  + cMsgErro + CRLF + "-----------------------------------" + CRLF



	else

		cMsgOK := ""

		cMsgOK := "Apontamento Realizado."
		cLOGERRO += "Apontamento OP " + SC2->(C2_NUM+C2_ITEM+C2_SEQUEN) + " |Qtd: " + CRLF + cMsgOK + CRLF + "-----------------------------------" + CRLF

	end
	RestArea(aArea)
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
