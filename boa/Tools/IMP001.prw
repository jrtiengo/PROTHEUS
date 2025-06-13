#include "protheus.ch"
#include "rwmake.ch"
#include "TOTVS.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "DBSTRUCT.CH"
#INCLUDE "MSGRAPHI.CH"
#Include "FWMVCDEF.CH"

/*
=====================================================================================
Programa.:              IMP001
Autor....:              Tiago Barbieri
Data.....:              05/09/2016
Descricao / Objetivo:   importacao de cadastros
Doc. Origem:
Solicitante:            Cliente
Uso......:               
Obs......:              Tela de importacao de cadastros
=====================================================================================
*/

User Function IMP001()

	Local oRadMenu1
	Local oSay1
	Local aOpcoes := {}
	Static oDlg3
	Private nRadMenu1 := 1

	aadd(aOpcoes,"Cadastros de Produtos SB1")                              //01 SB1
	aadd(aOpcoes,"Estrutura de Produtos SG1")                              //02 SG1
	aadd(aOpcoes,"Clientes SA1")                                           //03 SA1
	aadd(aOpcoes,"Fornecedores SA2")                                       //04 SA2
	aadd(aOpcoes,"Representantes/Vendedores SA3")                          //05 SA3
	aadd(aOpcoes,"Veiculos DA3")                                           //06 DA3
	aadd(aOpcoes,"Transportadoras SA4")                                    //07 SA4
	aadd(aOpcoes,"Cadastro de Bens 'Ativo Fixo' - 2 arquivos SN1/SN3")     //08 SN1/SN3
	aadd(aOpcoes,"Saldos de Estoque SB9")                                  //09 SB9
	aadd(aOpcoes,"Lotes de Estoque SD5")                                   //10 SD5
	aadd(aOpcoes,"Pedidos de Compra em Aberto SC7")                        //11 SC7
	aadd(aOpcoes,"Pedidos de Venda em Aberto - 2 arquivos SC5/SC6")        //12 SC5/SC6
	aadd(aOpcoes,"Movimento Financeiro Contas a Pagar em Aberto SE2")      //13 SE2
	aadd(aOpcoes,"Movimento Financeiro Contas a Receber em Aberto SE1")    //14 SE1
	aadd(aOpcoes,"Ordens de Compra SC1")     							   //15 SC1
	aadd(aOpcoes,"Cadastro de Naturezas")     							   //16 SC1
	aadd(aOpcoes,"AmarraÁ„o ProdutoxFornecedor SA5")                       //17 SA5
	aadd(aOpcoes,"Contratos CN9")                      					   //18 CN9/CNC/CNA/CNB/CNN

	DEFINE MSDIALOG oDlg3 TITLE "importacao de Cadastros " FROM 000, 000  TO 380, 545 COLORS 0, 16777215 PIXEL
	oRadMenu1:= tRadMenu():New(20,06,aOpcoes,{|u|if(PCount()>0,nRadMenu1:=u,nRadMenu1)}, oDlg3,,,,,,,,159,130,,,,.T.)
	@ 006, 006 SAY oSay1 PROMPT "Selecione o cadastro a importar :" SIZE 091, 007 OF oDlg3 COLORS 0, 16777215 PIXEL
	@ 177,  90 BUTTON "Importar" SIZE 050, 012 PIXEL OF oDlg3 Action(processa({|| ImpCad()},"importacao de Cadastros Basicos"))
	@ 177, 150 BUTTON "Cancelar" SIZE 050, 012 PIXEL OF oDlg3 Action(oDlg3:End())

	ACTIVATE MSDIALOG oDlg3 CENTERED

Return

/*
========================================================
Fun√ß√£o de importacao de arquivo CSV com separador ";"
========================================================
*/
Static Function ImpCad
	Local cArq	     := ""
	Local cArqd	     := ""
	Local cLogDir    := ""
	Local cLogFile   := ""
	Local cTime      := ""
	Local aLog       := {}
	Local cLogWrite  := ""
	Local cLogWritet := ""
	Local nHandle
	Local cLinha     := ''
	Local cLinhad    := ''
	Local lPrim      := .T.
	Local lPrimd     := .T.
	Local aCampos    := {}
	Local aCamposd   := {}
	Local aDados     := {}
	Local aDadosd    := {}
	Local cBKFilial  := cFilAnt
	Local nCampos    := 0
	Local nCamposd   := 0
	Local cSQL       := ''
	Local cSQLd      := ''
	Local aExecAuto  := {}
	Local aExecAutod := {}
	Local aExecAutol := {}
	Local aTipoImp   := {}
	Local aTipoImpd  := {}
	Local nTipoImp   := 0
	Local nTipoImpd  := 0
	Local cTipo      := ''
	Local cTipod     := ''
	Local cTab       := ''
	Local cTabd      := ''
	Local nI
	Local nId
	Local nX
	Local cNiv
	Local cCod
	Local cBemN1
	Local cBemN3
	Local cItemN1
	Local cItemN3
	Local cFilCad	:= cFilAnt
	Local cEmpCad	:= cEmpAnt
	Local nLinhaAtu := 0 //Tiengo
	Local cTabContr := "CN9/CNC/CNA/CNB/CNN" //tiengo
	Local aLinhas   := {}
	Local cMsgErro  := ""

	Private lMsErroAuto    := .F.
	Private lMsHelpAuto	   := .F.
	Private lAutoErrNoFile := .T.
	Private aTabExclui     := {{'B1',{"SB1"} },;
		{'G1',{"SG1"} },;
		{'A1',{"SA1"} },;
		{'A2',{"SA2"} },;
		{'A3',{"SA3"} },;
		{'DA3',{"DA3"} },;
		{'A4',{"SA4"} },;
		{'N1',{"SN1","SN3","SN4","SN5"} },;
		{'B9',{"SB2","SB9"} },;
		{'D5',{"SD5"} },;
		{'C7',{"SC7"} },;
		{'C5',{"SC5"} },;
		{'C6',{"SC6"} },;
		{'E2',{"SE2"} },;
		{'E1',{"SE1"} },;
		{'C1',{"SC1"} },;
		{'ED',{"SED"} },;
		{'A5',{"SA5"}}}

	IF nRadMenu1 !=8 .AND. nRadMenu1 !=12
		cArq := cGetFile("Todos os Arquivos|*.csv", OemToAnsi("Informe o diretorio onde se encontra o arquivo."), 0, "SERVIDOR\", .F., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE ,.T.)
	Endif

	/*
	========================================================
	Importa tabela de Produtos SB1
	========================================================
	*/
	IF nRadMenu1 == 1 // Op√ß√£o 1 - Produtos
		If !File(cArq)
			MsgStop("O arquivo " +cArq + " n√£o foi selecionado. A importacao ser√£ abortada!","ATENCAO")
			Return
		EndIf

		// Valida os campos encontrados no arquivo
		FT_FUSE(cArq)
		FT_FGOTOP()
		cLinha    := FT_FREADLN()
		aTipoImp  := Separa(cLinha,";",.T.)
		cTipo     := SUBSTR(aTipoImp[1],1,2)

		IF !(cTIPO $('B1'))
			MsgAlert('N√£o √£ possivel importar a tabela: '+cTipo+ '  !!')
			Return
		ENDIF

		dbSelectArea("SX3")
		DbSetOrder(2)
		For nI := 1 To Len(aTipoImp)
			IF cTipo <> SUBSTR(aTipoImp[nI],1,2)
				MsgAlert('Todos os campos devem pertencer a mesma tabela !!')
				Return
			ENDIF
			IF !SX3->(dbSeek(Alltrim(aTipoImp[nI])))
				MsgAlert('Campo n√£o encontrado na tabela :'+aTipoImp[nI]+' !!')
				Return
			ELSEIF (SX3->X3_VISUAL $ ('V') ) .OR. (SX3->X3_CONTEXT == "V"  )
				MsgAlert('Campo marcado na tabela como visual :'+aTipoImp[nI]+' !!')
				Return
			ENDIF
		Next nI

		//Prepara a op√ß√£o para excluir ou n√£o os dados da tabela
		nTipoImp  := aScan( aTabExclui, { |x| AllTrim( x[1] ) == cTipo } )

		cTab := ''
		For nI := 1 To Len(aTabExclui[nTipoImp,2])
			cTab += aTabExclui[nTipoImp,2,nI]+' '
		Next nI

		/*
		If MsgYesNo("Deseja excluir os dados da(s) tabela(s):"+cTab+"antes da importacao ? ")
			For nI := 1 To Len(aTabExclui[nTipoImp,2])
				cSQL := "delete from "+RetSqlName(aTabExclui[nTipoImp,2,nI])
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
				cSQL := "delete from "+RetSqlName('AO4')+" where AO4_ENTIDA = '" + aTabExclui[nTipoImp,2,nI] + "'"
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
			Next nI
		EndIf
		*/

		//Lendo arquivo texto
		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		While !FT_FEOF()
			IncProc("Lendo arquivo texto...")
			cLinha := FT_FREADLN()
			If lPrim
				aCampos := Separa(cLinha,";",.T.)
				lPrim := .F.
			Else
				AADD(aDados,Separa(cLinha,";",.T.))
			EndIf
			FT_FSKIP()
		EndDo

		//Processando arquivo texto
		ProcRegua(Len(aDados))
		For nI:=1 to  Len(aDados)

			IncProc("Importando arquivo... linha: " + StrZero(nI,5))
			aExecAuto := {}
			For nCampos := 1 To Len(aCampos)
				IF  SUBSTR(Upper(aCampos[nCampos]),4,6)=='FILIAL'
					IF !EMpty(aDados[nI,nCampos])
						cFilAnt := aDados[nI,nCampos]
					ENDIF
				Else
					IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	VAL(aDados[nI,nCampos] )	,Nil})
					ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  CTOD(aDados[nI,nCampos] )	,Nil})
					ELSE
						IF  Alltrim(Upper(aCampos[nCampos]))=='B1_DESC'
							aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	SubStr(aDados[nI,nCampos],1,TamSx3("B1_DESC")[1]) 	,Nil})
						Else
							if aDados[nI,nCampos] == '" "'// Tratativa para n„o gravar " " nos campos vazios
								aDados[nI,nCampos] :=  ''
							Endif
							aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	aDados[nI,nCampos] 	,Nil})
						Endif
					ENDIF
				ENDIF
			Next nCampos

			lMsErroAuto := .F.

			SM0->(DbGoTop())
			SM0->(MsSeek (cEmpCad+SubStr(cFilAnt,1,4), .T.))	//Pego a filial mais proxima
			cFilAnt := FWGETCODFILIAL

			Begin Transaction
				MSExecAuto({|x,y| MATA010(x,y)},aExecAuto,3) // SB1 Produto

				//Caso ocorra erro, verifica se ocorreu antes ou depois dos primeiros 100 registros do arquivo
				If lMsErroAuto
					aLog := {}
					aLog := GetAutoGRLog()
					If nI <= 100
						DisarmTransaction()
						cLogWritet += "Linha do erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						//MostraErro()
						For nX :=1 to Len(aLog)
							cLogWritet += aLog[nX]+CRLF
						next nX
						MsgAlert(StrTran(cLogWritet,"< --","-->"),"Erro no arquivo!")
						cFilAnt := cBKFilial
						Return
					Else
						cLogWrite += "Linha com o erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						For nX :=1 to Len(aLog)
							cLogWrite += aLog[nX]+CRLF
						next nX
					Endif
				EndIF
			End Transaction

			cFilAnt := cFilCad

		Next nI

		//Grava arquivo de LOG caso o erro ocorra depois do 100o registro
		If !Empty(cLogWrite)
			cTime     := Time()
			cLogDir   := cGetFile("Arquivo |*.log", OemToAnsi("Informe o diretorio para gravar o LOG."), 0, "SERVIDOR\", .T., GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY ,.F.)
			cLogFile  := cLogDir+"IMP_"+substr(cTime,1,2)+substr(cTime,4,2)+substr(cTime,7,2)+".LOG"
			nHandle   := MSFCreate(cLogFile,0)
			FWrite(nHandle,cLogWrite)
			FClose(nHandle)
			msgAlert("LOG de erro gerado em "+cLogFile)
		Else
			msginfo("Arquivo importado com sucesso!!")
		Endif
		FT_FUSE()
		cFilAnt := cBKFilial

		/*
		========================================================
		Importa tabela de Estrutura de Produtos SG1
		========================================================
		*/
	ElseIF nRadMenu1 == 2 // Op√ß√£o 2 - Estrutura de Produtos
		If !File(cArq)
			MsgStop("O arquivo " +cArq + " n√£o foi selecionado. A importacao ser√£ abortada!","ATENCAO")
			Return
		EndIf

		FT_FUSE(cArq)
		FT_FGOTOP()
		cLinha    := FT_FREADLN()
		aTipoImp  := Separa(cLinha,";",.T.)
		cTipo     := SUBSTR(aTipoImp[1],1,2)

		IF !(cTIPO $('G1'))
			MsgAlert('N√£o √£ possivel importar a tabela: '+cTipo+ '  !!')
			Return
		ENDIF

		dbSelectArea("SX3")
		DbSetOrder(2)
		For nI := 1 To Len(aTipoImp)
			IF cTipo <> SUBSTR(aTipoImp[nI],1,2)
				MsgAlert('Todos os campos devem pertencer a mesma tabela !!')
				Return
			ENDIF
			IF !SX3->(dbSeek(Alltrim(aTipoImp[nI])))
				MsgAlert('Campo n√£o encontrado na tabela :'+aTipoImp[nI]+' !!')
				Return
			ELSEIF (SX3->X3_VISUAL $ ('V') ) .OR. (SX3->X3_CONTEXT == "V"  )
				MsgAlert('Campo marcado na tabela como visual :'+aTipoImp[nI]+' !!')
				Return
			ENDIF
		Next nI

		nTipoImp  := aScan( aTabExclui, { |x| AllTrim( x[1] ) == cTipo } )

		cTab := ''
		For nI := 1 To Len(aTabExclui[nTipoImp,2])
			cTab += aTabExclui[nTipoImp,2,nI]+' '
		Next nI

		//Pergunta se deseja excluir os dados do cadastro de estrutura antes de importar
		/*
		If MsgYesNo("Deseja excluir os dados da(s) tabela(s):"+cTab+"antes da importacao ? ")
			For nI := 1 To Len(aTabExclui[nTipoImp,2])
				cSQL := "delete from "+RetSqlName(aTabExclui[nTipoImp,2,nI])
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
				cSQL := "delete from "+RetSqlName("AO4") + " where AO4_ENTIDA = '" + aTabExclui[nTipoImp,2,nI] + "'"
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
			Next nI
		EndIf
		*/
		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		While !FT_FEOF()
			IncProc("Lendo arquivo texto...") // Lendo linhas do arquivo
			cLinha := FT_FREADLN()
			If lPrim
				aCampos := Separa(cLinha,";",.T.)
				lPrim := .F.
			Else
				AADD(aDados,Separa(cLinha,";",.T.))
			EndIf
			FT_FSKIP()
		EndDo

		// Processando arquivo
		cNiv := "01"
		cCod := ""
		cCpoCab := "G1_COD"
		ProcRegua(Len(aDados))

		For nI:=1 to  Len(aDados)
			IncProc("Importando arquivo...")

			If cCod # aDados[nI][1] .AND. cNiv == aDados[nI][8]
				IF Len(aExecAuto) > 0

					lMsErroAuto := .F.

					SM0->(DbGoTop())
					SM0->(MsSeek (cEmpCad+SubStr(cFilAnt,1,4), .T.))	//Pego a filial mais proxima
					cFilAnt := FWGETCODFILIAL

					Begin Transaction

						MSExecAuto({|x,y,z| MATA200(x,y,z)},aExecAuto,aExecAutod,3) // SG1 Estrutura de Produto

						//Caso ocorra erro, verifica se ocorreu antes ou depois dos primeiros 100 registros do arquivo
						If lMsErroAuto
							aLog := {}
							aLog := GetAutoGRLog()
							If nI <= 100
								DisarmTransaction()
								cLogWritet += "Linha do erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
								//MostraErro()
								For nX :=1 to Len(aLog)
									cLogWritet += aLog[nX]+CRLF
								next nX
								MsgAlert(StrTran(cLogWritet,"< --","-->"),"Erro no arquivo!")
								cFilAnt := cBKFilial
								Return
							Else
								cLogWrite += "Linha com o erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
								For nX :=1 to Len(aLog)
									cLogWrite += aLog[nX]+CRLF
								next nX
							Endif
						EndIF
					End Transaction
					cFilAnt := cFilCad
					aExecAuto  := {}
					aExecAutod := {}
				Endif

				//Montando array de Cabe√£alho
				For nCampos := 1 To Len(aCampos)
					If Alltrim(aCampos[nCampos]) $ cCpoCab
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	aDados[nI,nCampos] 	,Nil})
					Endif
				Next nCampos
				aAdd(aExecAuto ,{"G1_QUANT",1,NIL})
				aAdd(aExecAuto ,{"NIVALT","S",NIL})
			Endif
			nCampos := 1
			cCod := aDados[nI][1]

			//Monta array de ITENS
			aExecAutol := {}
			For nCampos := 1 To Len(aCampos)-1
				IF  SUBSTR(Upper(aCampos[nCampos]),4,6)=='FILIAL'
					IF !EMpty(aDados[nI,nCampos])
						cFilAnt := aDados[nI,nCampos]
					ENDIF
				Else
					IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
						aAdd(aExecAutol ,{Upper(aCampos[nCampos]), 	VAL(aDados[nI,nCampos] )	,Nil})
					ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
						aAdd(aExecAutol ,{Upper(aCampos[nCampos]),  CTOD(aDados[nI,nCampos] )	,Nil})
					ELSE
						aAdd(aExecAutol ,{Upper(aCampos[nCampos]), 	aDados[nI,nCampos] 	,Nil})
					ENDIF
				ENDIF
			Next nCampos
			aAdd(aExecAutod, aExecAutol)
		Next nI

		// Processa execauto da ultima linha do arquivo lido
		lMsErroAuto := .F.

		SM0->(DbGoTop())
		SM0->(MsSeek (cEmpCad+SubStr(cFilAnt,1,4), .T.))	//Pego a filial mais proxima
		cFilAnt := FWGETCODFILIAL

		Begin Transaction
			MSExecAuto({|x,y,z| MATA200(x,y,z)},aExecAuto,aExecAutod,3) // SG1 Estrutura de Produto
			If lMsErroAuto
				DisarmTransaction()
				MostraErro()
				cFilAnt := cBKFilial
				Return
			EndIF
		End Transaction

		cFilAnt := cFilCad

		//Grava arquivo de LOG caso o erro ocorra depois do 100o registro
		If !Empty(cLogWrite)
			cTime     := Time()
			cLogDir   := cGetFile("Arquivo |*.log", OemToAnsi("Informe o diretorio para gravar o LOG."), 0, "SERVIDOR\", .T., GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY ,.F.)
			cLogFile  := cLogDir+"IMP_"+substr(cTime,1,2)+substr(cTime,4,2)+substr(cTime,7,2)+".LOG"
			nHandle   := MSFCreate(cLogFile,0)
			FWrite(nHandle,cLogWrite)
			FClose(nHandle)
			msgAlert("LOG de erro gerado em "+cLogFile)
		Else
			MsgInfo("Arquivo importado com sucesso!!")
		Endif
		FT_FUSE()
		cFilAnt := cBKFilial

		/*
		========================================================
		Importa tabela de Clientes SA1
		========================================================
		*/
	ElseIF nRadMenu1 == 3 // Op√ß√£o 3 - Clientes
		If !File(cArq)
			MsgStop("O arquivo " +cArq + " n√£o foi selecionado. A importacao ser√£ abortada!","ATENCAO")
			Return
		EndIf

		FT_FUSE(cArq)
		FT_FGOTOP()
		cLinha    := FT_FREADLN()
		aTipoImp  := Separa(cLinha,";",.T.)
		cTipo     := SUBSTR(aTipoImp[1],1,2)

		IF !(cTIPO $('A1'))
			MsgAlert('N√£o √£ possivel importar a tabela: '+cTipo+ '  !!')
			Return
		ENDIF

		dbSelectArea("SX3")
		DbSetOrder(2)
		For nI := 1 To Len(aTipoImp)
			IF cTipo <> SUBSTR(aTipoImp[nI],1,2)
				MsgAlert('Todos os campos devem pertencer a mesma tabela !!')
				Return
			ENDIF
			IF !SX3->(dbSeek(Alltrim(aTipoImp[nI])))
				MsgAlert('Campo n√£o encontrado na tabela :'+aTipoImp[nI]+' !!')
				Return
			ELSEIF (SX3->X3_VISUAL $ ('V') ) .OR. (SX3->X3_CONTEXT == "V"  )
				MsgAlert('Campo marcado na tabela como visual :'+aTipoImp[nI]+' !!')
				Return
			ENDIF
		Next nI

		nTipoImp  := aScan( aTabExclui, { |x| AllTrim( x[1] ) == cTipo } )

		cTab := ''
		For nI := 1 To Len(aTabExclui[nTipoImp,2])
			cTab += aTabExclui[nTipoImp,2,nI]+' '
		Next nI
		/*
		If MsgYesNo("Deseja excluir os dados da(s) tabela(s):"+cTab+"antes da importacao ? ")
			For nI := 1 To Len(aTabExclui[nTipoImp,2])
				cSQL := "delete from "+RetSqlName(aTabExclui[nTipoImp,2,nI])
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
				cSQL := "delete from "+RetSqlName("AO4") + " where AO4_ENTIDA = '" + aTabExclui[nTipoImp,2,nI] + "'"
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
			Next nI
		EndIf
		*/
		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		While !FT_FEOF()
			IncProc("Lendo arquivo texto...")
			cLinha := FT_FREADLN()
			If lPrim
				aCampos := Separa(cLinha,";",.T.)
				lPrim := .F.
			Else
				AADD(aDados,Separa(cLinha,";",.T.))
			EndIf
			FT_FSKIP()
		EndDo

		ProcRegua(Len(aDados))
		For nI:=1 to  Len(aDados)

			IncProc("Importando arquivo...")
			aExecAuto := {}
			For nCampos := 1 To Len(aCampos)
				IF  SUBSTR(Upper(aCampos[nCampos]),4,6)=='FILIAL'
					IF !EMpty(aDados[nI,nCampos])
						cFilAnt := aDados[nI,nCampos]
					ENDIF
				Else
					IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	VAL(aDados[nI,nCampos] )	,Nil})
					ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  CTOD(aDados[nI,nCampos] )	,Nil})
					ELSE
						if aDados[nI,nCampos] == '" "'// Tratativa para n„o gravar " " nos campos vazios
							aDados[nI,nCampos] :=  ''
						Endif
						//aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	Left(Alltrim(aDados[nI,nCampos]),TAMSX3(Upper(aCampos[nCampos]))[01]) 	,Nil})
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	aDados[nI,nCampos] 	,Nil})
					ENDIF
				ENDIF
			Next nCampos
			lMsErroAuto := .F.

			SM0->(DbGoTop())
			SM0->(MsSeek (cEmpCad+SubStr(cFilAnt,1,4), .T.))	//Pego a filial mais proxima
			cFilAnt := FWGETCODFILIAL

			Begin Transaction
				MSExecAuto({|x,y| MATA030(x,y)},aExecAuto,3) // SA1 Cliente

				//Caso ocorra erro, verifica se ocorreu antes ou depois dos primeiros 100 registros do arquivo
				If lMsErroAuto
					aLog := {}
					aLog := GetAutoGRLog()
					If nI <= 100
						DisarmTransaction()
						cLogWritet += "Linha do erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						//MostraErro()
						For nX :=1 to Len(aLog)
							cLogWritet += aLog[nX]+CRLF
						next nX
						MsgAlert(StrTran(cLogWritet,"< --","-->"),"Erro no arquivo!")
						cFilAnt := cBKFilial
						Return
					Else
						cLogWrite += "Linha com o erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						For nX :=1 to Len(aLog)
							cLogWrite += aLog[nX]+CRLF
						next nX
					Endif
				EndIF
			End Transaction
			cFilAnt := cFilCad
		Next nI

		//Grava arquivo de LOG caso o erro ocorra depois do 100o registro
		If !Empty(cLogWrite)
			cTime     := Time()
			cLogDir   := cGetFile("Arquivo |*.log", OemToAnsi("Informe o diretorio para gravar o LOG."), 0, "SERVIDOR\", .T., GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY ,.F.)
			cLogFile  := cLogDir+"IMP_"+substr(cTime,1,2)+substr(cTime,4,2)+substr(cTime,7,2)+".LOG"
			nHandle   := MSFCreate(cLogFile,0)
			FWrite(nHandle,cLogWrite)
			FClose(nHandle)
			msgAlert("LOG de erro gerado em "+cLogFile)
		Else
			MsgInfo("Arquivo importado com sucesso!!")
		Endif

		FT_FUSE()
		cFilAnt := cBKFilial

		/*
		========================================================
		Importa tabela de Fornecedores SA2
		========================================================
		*/
	ElseIF nRadMenu1 == 4 // Op√ß√£o 4 - Fornecedores
		If !File(cArq)
			MsgStop("O arquivo " +cArq + " n√£o foi selecionado. A importacao ser√° abortada!","ATENCAO")
			Return
		EndIf

		FT_FUSE(cArq)
		FT_FGOTOP()
		cLinha    := FT_FREADLN()
		aTipoImp  := Separa(cLinha,";",.T.)
		cTipo     := SUBSTR(aTipoImp[1],1,2)

		IF !(cTIPO $('A2'))
			MsgAlert('N√£o √© possivel importar a tabela: '+cTipo+ '  !!')
			Return
		ENDIF

		dbSelectArea("SX3")
		DbSetOrder(2)
		For nI := 1 To Len(aTipoImp)
			IF cTipo <> SUBSTR(aTipoImp[nI],1,2)
				MsgAlert('Todos os campos devem pertencer a mesma tabela !!')
				Return
			ENDIF
			IF !SX3->(dbSeek(Alltrim(aTipoImp[nI])))
				MsgAlert('Campo n√£o encontrado na tabela :'+aTipoImp[nI]+' !!')
				Return
			ELSEIF (SX3->X3_VISUAL $ ('V') ) .OR. (SX3->X3_CONTEXT == "V"  )
				MsgAlert('Campo marcado na tabela como visual :'+aTipoImp[nI]+' !!')
				Return
			ENDIF
		Next nI

		nTipoImp  := aScan( aTabExclui, { |x| AllTrim( x[1] ) == cTipo } )

		cTab := ''
		For nI := 1 To Len(aTabExclui[nTipoImp,2])
			cTab += aTabExclui[nTipoImp,2,nI]+' '
		Next nI
		/*
		If MsgYesNo("Deseja excluir os dados da(s) tabela(s):"+cTab+"antes da importacao ? ")
			For nI := 1 To Len(aTabExclui[nTipoImp,2])
				cSQL := "delete from "+RetSqlName(aTabExclui[nTipoImp,2,nI])
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
				cSQL := "delete from "+RetSqlName("AO4") + " where AO4_ENTIDA = '" + aTabExclui[nTipoImp,2,nI] + "'"
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
			Next nI
		EndIf
		*/
		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		While !FT_FEOF()
			IncProc("Importando arquivo... linha: " + StrZero(nI,5))
			cLinha := FT_FREADLN()
			If lPrim
				aCampos := Separa(cLinha,";",.T.)
				lPrim := .F.
			Else
				// quando nao tem dados na coluna, o conteudo √© ;; mas a funcao StrToArr nao entende
				// entao vamos garantir pelo menos uma ""
				cLinha := StrTran(cLinha, ';;', ';" ";'  )
				// por ter dados juntos, ou seja ;;; e o strTran s√≥ processa uma por vez, entao vou repetir
				// a operacao para garantir
				cLinha := StrTran(cLinha, ';;', ';" ";'  )
				AADD(aDados,Separa(cLinha,";",.T.))
			EndIf
			FT_FSKIP()
		EndDo

		ProcRegua(Len(aDados))
		For nI:=1 to  Len(aDados)

			IncProc("Importando arquivo... linha: " + StrZero(nI,5))
			aExecAuto := {}
			For nCampos := 1 To Len(aCampos)
				IF  SUBSTR(Upper(aCampos[nCampos]),4,6)=='FILIAL'
					IF !EMpty(aDados[nI,nCampos])
						cFilAnt := aDados[nI,nCampos]
					ENDIF
				Else
					IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	VAL(aDados[nI,nCampos] )	,Nil})
					ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  CTOD(aDados[nI,nCampos] )	,Nil})
					ELSE
						if aDados[nI,nCampos] == '" "'// Tratativa para n„o gravar " " nos campos vazios
							aDados[nI,nCampos] :=  ''
						Endif
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	Left(Alltrim(aDados[nI,nCampos]),TAMSX3(Upper(aCampos[nCampos]))[01]) 	,Nil})
					ENDIF
				ENDIF
			Next nCampos
			lMsErroAuto := .F.

			SM0->(DbGoTop())
			SM0->(MsSeek (cEmpCad+SubStr(cFilAnt,1,4), .T.))	//Pego a filial mais proxima
			cFilAnt := FWGETCODFILIAL

			Begin Transaction
				MSExecAuto({|x,y| MATA020(x,y)},aExecAuto,3) // SA2 Fornecedores

				//Caso ocorra erro, verifica se ocorreu antes ou depois dos primeiros 100 registros do arquivo
				If lMsErroAuto
					aLog := {}
					aLog := GetAutoGRLog()
					If nI <= 100
						DisarmTransaction()
						cLogWritet += "Linha do erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						//MostraErro()
						For nX :=1 to Len(aLog)
							cLogWritet += aLog[nX]+CRLF
						next nX
						MsgAlert(StrTran(cLogWritet,"< --","-->"),"Erro no arquivo!")
						cFilAnt := cBKFilial
						Return
					Else
						cLogWrite += "Linha com o erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						For nX :=1 to Len(aLog)
							cLogWrite += aLog[nX]+CRLF
						next nX
					Endif
				EndIF
			End Transaction
			cFilAnt := cFilCad
		Next nI

		//Grava arquivo de LOG caso o erro ocorra depois do 100o registro
		If !Empty(cLogWrite)
			cTime     := Time()
			cLogDir   := cGetFile("Arquivo |*.log", OemToAnsi("Informe o diretorio para gravar o LOG."), 0, "SERVIDOR\", .T., GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY ,.F.)
			cLogFile  := cLogDir+"IMP_"+substr(cTime,1,2)+substr(cTime,4,2)+substr(cTime,7,2)+".LOG"
			nHandle   := MSFCreate(cLogFile,0)
			FWrite(nHandle,cLogWrite)
			FClose(nHandle)
			msgAlert("LOG de erro gerado em "+cLogFile)
		Else
			MsgInfo("Arquivo importado com sucesso!!")
		Endif
		FT_FUSE()
		cFilAnt := cBKFilial

		/*
		========================================================
		Importa tabela de Representantes/Vendedores SA3
		========================================================
		*/
	ElseIF nRadMenu1 == 5 // Op√ß√£o 5 - Representantes/Vendedores
		If !File(cArq)
			MsgStop("O arquivo " +cArq + " n√£o foi selecionado. A importacao ser√£ abortada!","ATENCAO")
			Return
		EndIf

		FT_FUSE(cArq)
		FT_FGOTOP()
		cLinha    := FT_FREADLN()
		aTipoImp  := Separa(cLinha,";",.T.)
		cTipo     := SUBSTR(aTipoImp[1],1,2)

		IF !(cTIPO $('A3'))
			MsgAlert('N√£o √£ possivel importar a tabela: '+cTipo+ '  !!')
			Return
		ENDIF

		dbSelectArea("SX3")
		DbSetOrder(2)
		For nI := 1 To Len(aTipoImp)
			IF cTipo <> SUBSTR(aTipoImp[nI],1,2)
				MsgAlert('Todos os campos devem pertencer a mesma tabela !!')
				Return
			ENDIF
			IF !SX3->(dbSeek(Alltrim(aTipoImp[nI])))
				MsgAlert('Campo n√£o encontrado na tabela :'+aTipoImp[nI]+' !!')
				Return
			ELSEIF (SX3->X3_VISUAL $ ('V') ) .OR. (SX3->X3_CONTEXT == "V"  )
				MsgAlert('Campo marcado na tabela como visual :'+aTipoImp[nI]+' !!')
				Return
			ENDIF
		Next nI

		nTipoImp  := aScan( aTabExclui, { |x| AllTrim( x[1] ) == cTipo } )

		cTab := ''
		For nI := 1 To Len(aTabExclui[nTipoImp,2])
			cTab += aTabExclui[nTipoImp,2,nI]+' '
		Next nI
		/*
		If MsgYesNo("Deseja excluir os dados da(s) tabela(s):"+cTab+"antes da importacao ? ")
			For nI := 1 To Len(aTabExclui[nTipoImp,2])
				cSQL := "delete from "+RetSqlName(aTabExclui[nTipoImp,2,nI])
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
				cSQL := "delete from "+RetSqlName("AO4") + " where AO4_ENTIDA = '" + aTabExclui[nTipoImp,2,nI] + "'"
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
			Next nI
		EndIf
		*/
		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		While !FT_FEOF()
			IncProc("Lendo arquivo texto...")
			cLinha := FT_FREADLN()
			If lPrim
				aCampos := Separa(cLinha,";",.T.)
				lPrim := .F.
			Else
				AADD(aDados,Separa(cLinha,";",.T.))
			EndIf
			FT_FSKIP()
		EndDo

		ProcRegua(Len(aDados))
		For nI:=1 to  Len(aDados)

			IncProc("Importando arquivo...")
			aExecAuto := {}
			For nCampos := 1 To Len(aCampos)
				IF  SUBSTR(Upper(aCampos[nCampos]),4,6)=='FILIAL'
					IF !EMpty(aDados[nI,nCampos])
						cFilAnt := aDados[nI,nCampos]
					ENDIF
				Else
					IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	VAL(aDados[nI,nCampos] )	,Nil})
					ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  CTOD(aDados[nI,nCampos] )	,Nil})
					ELSE
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	Left(Alltrim(aDados[nI,nCampos]),TAMSX3(Upper(aCampos[nCampos]))[01]) 	,Nil})
					ENDIF
				ENDIF
			Next nCampos
			lMsErroAuto := .F.
			SM0->(DbGoTop())
			SM0->(MsSeek (cEmpCad+SubStr(cFilAnt,1,4), .T.))	//Pego a filial mais proxima
			cFilAnt := FWGETCODFILIAL

			Begin Transaction
				MSExecAuto({|x,y| MATA040(x,y)},aExecAuto,3) // SA3 Representantes/Vendedores

				//Caso ocorra erro, verifica se ocorreu antes ou depois dos primeiros 100 registros do arquivo
				If lMsErroAuto
					aLog := {}
					aLog := GetAutoGRLog()
					If nI <= 100
						DisarmTransaction()
						cLogWritet += "Linha do erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						//MostraErro()
						For nX :=1 to Len(aLog)
							cLogWritet += aLog[nX]+CRLF
						next nX
						MsgAlert(StrTran(cLogWritet,"< --","-->"),"Erro no arquivo!")
						cFilAnt := cBKFilial
						Return
					Else
						cLogWrite += "Linha com o erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						For nX :=1 to Len(aLog)
							cLogWrite += aLog[nX]+CRLF
						next nX
					Endif
				EndIF
			End Transaction
			cFilAnt := cFilCad
		Next nI

		//Grava arquivo de LOG caso o erro ocorra depois do 100o registro
		If !Empty(cLogWrite)
			cTime     := Time()
			cLogDir   := cGetFile("Arquivo |*.log", OemToAnsi("Informe o diretorio para gravar o LOG."), 0, "SERVIDOR\", .T., GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY ,.F.)
			cLogFile  := cLogDir+"IMP_"+substr(cTime,1,2)+substr(cTime,4,2)+substr(cTime,7,2)+".LOG"
			nHandle   := MSFCreate(cLogFile,0)
			FWrite(nHandle,cLogWrite)
			FClose(nHandle)
			msgAlert("LOG de erro gerado em "+cLogFile)
		Else
			MsgInfo("Arquivo importado com sucesso!!")
		Endif
		FT_FUSE()
		cFilAnt := cBKFilial

		/*
		========================================================
		Importa tabela de Ve√£culos DA3
		========================================================
		*/
	ElseIF nRadMenu1 == 6 // Op√ß√£o 6 - Ve√£culos
		If !File(cArq)
			MsgStop("O arquivo " +cArq + " n√£o foi selecionado. A importacao ser√£ abortada!","ATENCAO")
			Return
		EndIf

		FT_FUSE(cArq)
		FT_FGOTOP()
		cLinha    := FT_FREADLN()
		aTipoImp  := Separa(cLinha,";",.T.)
		cTipo     := SUBSTR(aTipoImp[1],1,3)

		IF !(cTIPO $('DA3'))
			MsgAlert('N√£o √£ possivel importar a tabela: '+cTipo+ '  !!')
			Return
		ENDIF

		dbSelectArea("SX3")
		DbSetOrder(2)
		For nI := 1 To Len(aTipoImp)
			IF cTipo <> SUBSTR(aTipoImp[nI],1,2)
				MsgAlert('Todos os campos devem pertencer a mesma tabela !!')
				Return
			ENDIF
			IF !SX3->(dbSeek(Alltrim(aTipoImp[nI])))
				MsgAlert('Campo n√£o encontrado na tabela :'+aTipoImp[nI]+' !!')
				Return
			ELSEIF (SX3->X3_VISUAL $ ('V') ) .OR. (SX3->X3_CONTEXT == "V"  )
				MsgAlert('Campo marcado na tabela como visual :'+aTipoImp[nI]+' !!')
				Return
			ENDIF
		Next nI

		nTipoImp  := aScan( aTabExclui, { |x| AllTrim( x[1] ) == cTipo } )

		cTab := ''
		For nI := 1 To Len(aTabExclui[nTipoImp,2])
			cTab += aTabExclui[nTipoImp,2,nI]+' '
		Next nI
		/*
		If MsgYesNo("Deseja excluir os dados da(s) tabela(s):"+cTab+"antes da importacao ? ")
			For nI := 1 To Len(aTabExclui[nTipoImp,2])
				cSQL := "delete from "+RetSqlName(aTabExclui[nTipoImp,2,nI])
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
				cSQL := "delete from "+RetSqlName("AO4") + " where AO4_ENTIDA = '" + aTabExclui[nTipoImp,2,nI] + "'"
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
			Next nI
		EndIf
		*/
		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		While !FT_FEOF()
			IncProc("Lendo arquivo texto...")
			cLinha := FT_FREADLN()
			If lPrim
				aCampos := Separa(cLinha,";",.T.)
				lPrim := .F.
			Else
				AADD(aDados,Separa(cLinha,";",.T.))
			EndIf
			FT_FSKIP()
		EndDo

		ProcRegua(Len(aDados))
		For nI:=1 to  Len(aDados)

			IncProc("Importando arquivo...")
			aExecAuto := {}
			For nCampos := 1 To Len(aCampos)
				IF  SUBSTR(Upper(aCampos[nCampos]),4,6)=='FILIAL'
					IF !EMpty(aDados[nI,nCampos])
						cFilAnt := aDados[nI,nCampos]
					ENDIF
				Else
					IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	VAL(aDados[nI,nCampos] )	,Nil})
					ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  CTOD(aDados[nI,nCampos] )	,Nil})
					ELSE
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	Left(Alltrim(aDados[nI,nCampos]),TAMSX3(Upper(aCampos[nCampos]))[01]) 	,Nil})
					ENDIF
				ENDIF
			Next nCampos
			lMsErroAuto := .F.

			SM0->(DbGoTop())
			SM0->(MsSeek (cEmpCad+SubStr(cFilAnt,1,4), .T.))	//Pego a filial mais proxima
			cFilAnt := FWGETCODFILIAL

			Begin Transaction
				MSExecAuto({|x,y| OMSA060(x,y)},aExecAuto,3) // DA3 Ve√£culos

				//Caso ocorra erro, verifica se ocorreu antes ou depois dos primeiros 100 registros do arquivo
				If lMsErroAuto
					aLog := {}
					aLog := GetAutoGRLog()
					If nI <= 100
						DisarmTransaction()
						cLogWritet += "Linha do erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						//MostraErro()
						For nX :=1 to Len(aLog)
							cLogWritet += aLog[nX]+CRLF
						next nX
						MsgAlert(StrTran(cLogWritet,"< --","-->"),"Erro no arquivo!")
						cFilAnt := cBKFilial
						Return
					Else
						cLogWrite += "Linha com o erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						For nX :=1 to Len(aLog)
							cLogWrite += aLog[nX]+CRLF
						next nX
					Endif
				EndIF
			End Transaction
			cFilAnt := cFilCad
		Next nI

		//Grava arquivo de LOG caso o erro ocorra depois do 100o registro
		If !Empty(cLogWrite)
			cTime     := Time()
			cLogDir   := cGetFile("Arquivo |*.log", OemToAnsi("Informe o diretorio para gravar o LOG."), 0, "SERVIDOR\", .T., GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY ,.F.)
			cLogFile  := cLogDir+"IMP_"+substr(cTime,1,2)+substr(cTime,4,2)+substr(cTime,7,2)+".LOG"
			nHandle   := MSFCreate(cLogFile,0)
			FWrite(nHandle,cLogWrite)
			FClose(nHandle)
			msgAlert("LOG de erro gerado em "+cLogFile)
		Else
			MsgInfo("Arquivo importado com sucesso!!")
		Endif
		FT_FUSE()
		cFilAnt := cBKFilial

		/*
		========================================================
		Importa tabela de Transportadoras SA4
		========================================================
		*/
	ElseIF nRadMenu1 == 7 // Op√ß√£o 7 - Transportadoras
		If !File(cArq)
			MsgStop("O arquivo " +cArq + " n√£o foi selecionado. A importacao ser√£ abortada!","ATENCAO")
			Return
		EndIf

		FT_FUSE(cArq)
		FT_FGOTOP()
		cLinha    := FT_FREADLN()
		aTipoImp  := Separa(cLinha,";",.T.)
		cTipo     := SUBSTR(aTipoImp[1],1,2)

		IF !(cTIPO $('A4'))
			MsgAlert('N√£o √£ possivel importar a tabela: '+cTipo+ '  !!')
			Return
		ENDIF

		dbSelectArea("SX3")
		DbSetOrder(2)
		For nI := 1 To Len(aTipoImp)
			IF cTipo <> SUBSTR(aTipoImp[nI],1,2)
				MsgAlert('Todos os campos devem pertencer a mesma tabela !!')
				Return
			ENDIF
			IF !SX3->(dbSeek(Alltrim(aTipoImp[nI])))
				MsgAlert('Campo n√£o encontrado na tabela :'+aTipoImp[nI]+' !!')
				Return
			ELSEIF (SX3->X3_VISUAL $ ('V') ) .OR. (SX3->X3_CONTEXT == "V"  )
				MsgAlert('Campo marcado na tabela como visual :'+aTipoImp[nI]+' !!')
				Return
			ENDIF
		Next nI

		nTipoImp  := aScan( aTabExclui, { |x| AllTrim( x[1] ) == cTipo } )

		cTab := ''
		For nI := 1 To Len(aTabExclui[nTipoImp,2])
			cTab += aTabExclui[nTipoImp,2,nI]+' '
		Next nI
		/*
		If MsgYesNo("Deseja excluir os dados da(s) tabela(s):"+cTab+"antes da importacao ? ")
			For nI := 1 To Len(aTabExclui[nTipoImp,2])
				cSQL := "delete from "+RetSqlName(aTabExclui[nTipoImp,2,nI])
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
				cSQL := "delete from "+RetSqlName("AO4") + " where AO4_ENTIDA = '" + aTabExclui[nTipoImp,2,nI] + "'"
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
			Next nI
		EndIf
		*/
		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		While !FT_FEOF()
			IncProc("Lendo arquivo texto...")
			cLinha := FT_FREADLN()
			If lPrim
				aCampos := Separa(cLinha,";",.T.)
				lPrim := .F.
			Else
				AADD(aDados,Separa(cLinha,";",.T.))
			EndIf
			FT_FSKIP()
		EndDo

		ProcRegua(Len(aDados))
		For nI:=1 to  Len(aDados)

			IncProc("Importando arquivo...")
			aExecAuto := {}
			For nCampos := 1 To Len(aCampos)
				IF  SUBSTR(Upper(aCampos[nCampos]),4,6)=='FILIAL'
					IF !EMpty(aDados[nI,nCampos])
						cFilAnt := aDados[nI,nCampos]
					ENDIF
				Else
					IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	VAL(aDados[nI,nCampos] )	,Nil})
					ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  CTOD(aDados[nI,nCampos] )	,Nil})
					ELSE
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	Left(Alltrim(aDados[nI,nCampos]),TAMSX3(Upper(aCampos[nCampos]))[01]) 	,Nil})
					ENDIF
				ENDIF
			Next nCampos
			lMsErroAuto := .F.

			SM0->(DbGoTop())
			SM0->(MsSeek (cEmpCad+SubStr(cFilAnt,1,4), .T.))	//Pego a filial mais proxima
			cFilAnt := FWGETCODFILIAL

			Begin Transaction
				MSExecAuto({|x,y| MATA050(x,y)},aExecAuto,3) // SA4 Transportadoras

				//Caso ocorra erro, verifica se ocorreu antes ou depois dos primeiros 100 registros do arquivo
				If lMsErroAuto
					aLog := {}
					aLog := GetAutoGRLog()
					If nI <= 100
						DisarmTransaction()
						cLogWritet += "Linha do erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						//MostraErro()
						For nX :=1 to Len(aLog)
							cLogWritet += aLog[nX]+CRLF
						next nX
						MsgAlert(StrTran(cLogWritet,"< --","-->"),"Erro no arquivo!")
						cFilAnt := cBKFilial
						Return
					Else
						cLogWrite += "Linha com o erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						For nX :=1 to Len(aLog)
							cLogWrite += aLog[nX]+CRLF
						next nX
					Endif
				EndIF
			End Transaction
			cFilAnt := cFilCad
		Next nI

		//Grava arquivo de LOG caso o erro ocorra depois do 100o registro
		If !Empty(cLogWrite)
			cTime     := Time()
			cLogDir   := cGetFile("Arquivo |*.log", OemToAnsi("Informe o diretorio para gravar o LOG."), 0, "SERVIDOR\", .T., GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY ,.F.)
			cLogFile  := cLogDir+"IMP_"+substr(cTime,1,2)+substr(cTime,4,2)+substr(cTime,7,2)+".LOG"
			nHandle   := MSFCreate(cLogFile,0)
			FWrite(nHandle,cLogWrite)
			FClose(nHandle)
			msgAlert("LOG de erro gerado em "+cLogFile)
		Else
			MsgInfo("Arquivo importado com sucesso!!")
		Endif
		FT_FUSE()
		cFilAnt := cBKFilial

		/*
		========================================================
		Importa tabela de Cadastro de Bens (Ativo Fixo) SN1/SN3
		========================================================
		*/
	ElseIF nRadMenu1 == 8 // Op√ß√£o 8 - Cadastro de Bens (Ativo Fixo)

		//Arquivo Cabe√£alho
		MsgAlert("Essa opcao  precisa de 2 arquivos, o primeiro e o arquivo de CABECALHO!","ATENCAO")
		cArq := cGetFile("Todos os Arquivos|*.csv", OemToAnsi("Informe o diretorio onde se encontra o arquivo."), 0, "SERVIDOR\", .F., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE ,.T.)

		If !File(cArq)
			MsgStop("O arquivo " +cArq + " n√£o foi selecionado. A importacao ser√£ abortada!","ATENCAO")
			Return
		EndIf

		FT_FUSE(cArq)
		FT_FGOTOP()
		cLinha    := FT_FREADLN()
		aTipoImp  := Separa(cLinha,";",.T.)
		cTipo     := SUBSTR(aTipoImp[1],1,2)

		IF !(cTIPO $('N1'))
			MsgAlert('N√£o √£ possivel importar a tabela: '+cTipo+ '  !!')
			Return
		ENDIF

		dbSelectArea("SX3")
		DbSetOrder(2)
		For nI := 1 To Len(aTipoImp)
			IF cTipo <> SUBSTR(aTipoImp[nI],1,2)
				MsgAlert('Todos os campos devem pertencer a mesma tabela !!')
				Return
			ENDIF
			IF !SX3->(dbSeek(Alltrim(aTipoImp[nI])))
				MsgAlert('Campo n√£o encontrado na tabela :'+aTipoImp[nI]+' !!')
				Return
			ELSEIF (SX3->X3_VISUAL $ ('V') ) .OR. (SX3->X3_CONTEXT == "V"  )
				MsgAlert('Campo marcado na tabela como visual :'+aTipoImp[nI]+' !!')
				Return
			ENDIF
		Next nI

		nTipoImp  := aScan( aTabExclui, { |x| AllTrim( x[1] ) == cTipo } )

		cTab := ''
		For nI := 1 To Len(aTabExclui[nTipoImp,2])
			cTab += aTabExclui[nTipoImp,2,nI]+' '
		Next nI
		/*
		If MsgYesNo("Deseja excluir os dados da(s) tabela(s):"+cTab+"antes da importacao ? ")
			For nI := 1 To Len(aTabExclui[nTipoImp,2])
				cSQL := "delete from "+RetSqlName(aTabExclui[nTipoImp,2,nI])
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
				cSQL := "delete from "+RetSqlName("AO4") + " where AO4_ENTIDA = '" + aTabExclui[nTipoImp,2,nI] + "'"
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
			Next nI
		EndIf
		*/
		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		While !FT_FEOF()
			IncProc("Lendo arquivo texto...")
			cLinha := FT_FREADLN()
			If lPrim
				aCampos := Separa(cLinha,";",.T.)
				lPrim := .F.
			Else
				AADD(aDados,Separa(cLinha,";",.T.))
			EndIf
			FT_FSKIP()
		EndDo

		//Arquivo Itens
		MsgAlert("Agora √£ o arquivo de DETALHE!","ATEN√ß√£O")
		cArqd := cGetFile("Todos os Arquivos|*.csv", OemToAnsi("Informe o diretorio onde se encontra o arquivo."), 0, "SERVIDOR\", .F., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE ,.T.)

		If !File(cArqd)
			MsgStop("O arquivo " +cArqd + " n√£o foi selecionado. A importacao ser√£ abortada!","ATENCAO")
			Return
		EndIf

		FT_FUSE(cArqd)
		FT_FGOTOP()
		cLinhad    := FT_FREADLN()
		aTipoImpd  := Separa(cLinhad,";",.T.)
		cTipod     := SUBSTR(aTipoImpd[1],1,2)

		nPoscBN3   := 0
		nPosItN3   := 0

		IF !(cTIPOd $('N3'))
			MsgAlert('N√£o √£ possivel importar a tabela: '+cTipod+ '  !!')
			Return
		ENDIF

		dbSelectArea("SX3")
		DbSetOrder(2)
		For nId := 1 To Len(aTipoImpd)
			IF cTipod <> SUBSTR(aTipoImpd[nId],1,2)
				MsgAlert('Todos os campos devem pertencer a mesma tabela !!')
				Return
			ENDIF
			IF !SX3->(dbSeek(Alltrim(aTipoImpd[nId])))
				MsgAlert('Campo n√£o encontrado na tabela :'+aTipoImpd[nId]+' !!')
				Return
			ELSEIF (SX3->X3_VISUAL $ ('V') ) .OR. (SX3->X3_CONTEXT == "V"  )
				MsgAlert('Campo marcado na tabela como visual :'+aTipoImpd[nId]+' !!')
				Return
			ENDIF

			If Alltrim(SX3->X3_CAMPO) == 'N3_CBASE'
				nPoscBN3 := nId
			EndIf

			If Alltrim(SX3->X3_CAMPO) == 'N3_ITEM'
				nPosItN3 := nId
			EndIf
		Next nId

		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		While !FT_FEOF()
			IncProc("Lendo arquivo texto...")
			cLinhad := FT_FREADLN()
			If lPrimd
				aCamposd := Separa(cLinhad,";",.T.)
				lPrimd := .F.
			Else
				AADD(aDadosd,Separa(cLinhad,";",.T.))
			EndIf
			FT_FSKIP()
		EndDo

		cBemN1  := ""
		cBemN3  := ""
		cItemN1 := ""
		cItemN3 := ""

		//Monta array do cabe√£alho
		ProcRegua(Len(aDados))
		For nI:=1 to  Len(aDados)
			IncProc("Importando arquivos...")
			aExecAuto  := {}
			aExecAutod := {}
			For nCampos := 1 To Len(aCampos)
				IF  SUBSTR(Upper(aCampos[nCampos]),4,6)=='FILIAL'
					IF !EMpty(aDados[nI,nCampos])
						cFilAnt := aDados[nI,nCampos]
					ENDIF
				Else
					IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	VAL(aDados[nI,nCampos] )	,Nil})
					ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
						cConteud := CTOD(aDados[nI,nCampos] )
						If cConteud == Ctod('')
							cConteud := STOD(aDados[nI,nCampos] )
						EndIf
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  cConteud	,Nil})
					ELSE
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	Left(Alltrim(aDados[nI,nCampos]),TAMSX3(Upper(aCampos[nCampos]))[01]) 	,Nil})
					ENDIF
				ENDIF

				If aCampos[nCampos] == 'N1_CBASE'
					cBemN1  := aExecAuto[Len(aExecAuto)][2]
				EndIf
				If aCampos[nCampos] == 'N1_ITEM'
					cItemN1 := aExecAuto[Len(aExecAuto)][2]
				EndIf
			Next nCampos

			//Ordenacao do Array obrigatorio, sem isso da erro no MsExecAuto
			aExecAuto := FWVetByDic(aExecAuto, "SN1")

			//Monta array dos itens
			For nId:=1 to  Len(aDadosd)
				cBemN3  := aDadosd[nId][nPoscBN3]
				cItemN3 := aDadosd[nId][nPosItN3]
				aExecAutol := {}
				IF cBemN3 == cBemN1 .AND. cItemN3 == cItemN1
					For nCamposd := 1 To Len(aCamposd)
						IF  SUBSTR(Upper(aCamposd[nCamposd]),4,6)=='FILIAL'
							IF !EMpty(aDadosd[nId,nCamposd])
								cFilAnt := aDadosd[nId,nCamposd]
							ENDIF
						Else
							IF  TamSx3(Upper(aCamposd[nCamposd]))[3] =='N'
								aAdd(aExecAutol ,{Upper(aCamposd[nCamposd]), 	VAL(aDadosd[nId,nCamposd] )	,Nil})
							ELSEIF TamSx3(Upper(aCamposd[nCamposd]))[3] =='D'
								cConteud := CTOD(aDadosd[nId,nCamposd] )
								If cConteud == Ctod('')
									cConteud := STOD(aDadosd[nId,nCamposd] )
								EndIf
								aAdd(aExecAutol ,{Upper(aCamposd[nCamposd]),  cConteud	,Nil})
							ELSE
								aAdd(aExecAutol ,{Upper(aCamposd[nCamposd]), 	Left(Alltrim(aDadosd[nId,nCamposd]),TAMSX3(Upper(aCamposd[nCamposd]))[01]) 	,Nil})
							ENDIF
						ENDIF
					Next nCamposd
					aExecAutol := FWVetByDic(aExecAutol, "SN3")
					aAdd(aExecAutod, aExecAutol)
				ENDIF
			Next nId

			// Executa MSEXECAUTO
			lMsErroAuto := .F.

			SM0->(DbGoTop())
			SM0->(MsSeek (cEmpCad+SubStr(cFilAnt,1,4), .T.))	//Pego a filial mais proxima
			cFilAnt := FWGETCODFILIAL

			Begin Transaction
				MSExecAuto({|x,y,z| ATFA012(x,y,z)},aExecAuto,aExecAutod,3) // SN1/SN3 Bens Ativo Fixo CABECALHO/ITENS

				//Caso ocorra erro, verifica se ocorreu antes ou depois dos primeiros 100 registros do arquivo
				If lMsErroAuto
					aLog := {}
					aLog := GetAutoGRLog()
					/*
					If nI <= 100
						DisarmTransaction()
						cLogWritet += "Linha do erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						//MostraErro()
					For nX :=1 to Len(aLog)
							cLogWritet += aLog[nX]+CRLF
					next nX
						MsgAlert(StrTran(cLogWritet,"< --","-->"),"Erro no arquivo!")
						cFilAnt := cBKFilial
						Return
				Else
				*/
					cLogWrite += "Linha com o erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
					For nX :=1 to Len(aLog)
						cLogWrite += aLog[nX]+CRLF
					next nX
					//Endif
				EndIF
			End Transaction
			cFilAnt := cFilCad
		Next nI

		//Grava arquivo de LOG caso o erro ocorra depois do 100o registro
		If !Empty(cLogWrite)
			cTime     := Time()
			cLogDir   := cGetFile("Arquivo |*.log", OemToAnsi("Informe o diretorio para gravar o LOG."), 0, "SERVIDOR\", .T., GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY ,.F.)
			cLogFile  := cLogDir+"IMP_"+substr(cTime,1,2)+substr(cTime,4,2)+substr(cTime,7,2)+".LOG"
			nHandle   := MSFCreate(cLogFile,0)
			FWrite(nHandle,cLogWrite)
			FClose(nHandle)
			msgAlert("LOG de erro gerado em "+cLogFile)
		Else
			MsgInfo("Arquivo importado com sucesso!!")
		Endif
		FT_FUSE()
		cFilAnt := cBKFilial

		/*
		========================================================
		Importa tabela de Saldos de Estoque SB9
		========================================================
		*/
	ElseIF nRadMenu1 == 9 // Op√ß√£o 9 - Saldos de Estoque
		If !File(cArq)
			MsgStop("O arquivo " +cArq + " n√£o foi selecionado. A importacao ser√£ abortada!","ATENCAO")
			Return
		EndIf

		FT_FUSE(cArq)
		FT_FGOTOP()
		cLinha    := FT_FREADLN()
		aTipoImp  := Separa(cLinha,";",.T.)
		cTipo     := SUBSTR(aTipoImp[1],1,2)

		IF !(cTIPO $('B9'))
			MsgAlert('N√£o √£ possivel importar a tabela: '+cTipo+ '  !!')
			Return
		ENDIF

		dbSelectArea("SX3")
		DbSetOrder(2)
		For nI := 1 To Len(aTipoImp)
			IF cTipo <> SUBSTR(aTipoImp[nI],1,2)
				MsgAlert('Todos os campos devem pertencer a mesma tabela !!')
				Return
			ENDIF
			IF !SX3->(dbSeek(Alltrim(aTipoImp[nI])))
				MsgAlert('Campo n√£o encontrado na tabela :'+aTipoImp[nI]+' !!')
				Return
			ELSEIF (SX3->X3_VISUAL $ ('V') ) .OR. (SX3->X3_CONTEXT == "V"  )
				MsgAlert('Campo marcado na tabela como visual :'+aTipoImp[nI]+' !!')
				Return
			ENDIF
		Next nI

		nTipoImp  := aScan( aTabExclui, { |x| AllTrim( x[1] ) == cTipo } )

		cTab := ''
		For nI := 1 To Len(aTabExclui[nTipoImp,2])
			cTab += aTabExclui[nTipoImp,2,nI]+' '
		Next nI
		/*
		If MsgYesNo("Deseja excluir os dados da(s) tabela(s):"+cTab+"antes da importacao ? ")
			For nI := 1 To Len(aTabExclui[nTipoImp,2])
				cSQL := "delete from "+RetSqlName(aTabExclui[nTipoImp,2,nI])
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
				cSQL := "delete from "+RetSqlName("AO4") + " where AO4_ENTIDA = '" + aTabExclui[nTipoImp,2,nI] + "'"
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
			Next nI
		EndIf
		*/
		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		While !FT_FEOF()
			IncProc("Lendo arquivo texto...")
			cLinha := FT_FREADLN()
			If lPrim
				aCampos := Separa(cLinha,";",.T.)
				lPrim := .F.
			Else
				AADD(aDados,Separa(cLinha,";",.T.))
			EndIf
			FT_FSKIP()
		EndDo

		ProcRegua(Len(aDados))
		For nI:=1 to  Len(aDados)

			IncProc("Importando arquivo...")
			aExecAuto := {}
			For nCampos := 1 To Len(aCampos)
				IF  SUBSTR(Upper(aCampos[nCampos]),4,6)=='FILIAL'
					IF !EMpty(aDados[nI,nCampos])
						cFilAnt := aDados[nI,nCampos]
					ENDIF
				Else
					IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	VAL(aDados[nI,nCampos] )	,Nil})
					ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  CTOD(aDados[nI,nCampos] )	,Nil})
					ELSE
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	Left(Alltrim(aDados[nI,nCampos]),TAMSX3(Upper(aCampos[nCampos]))[01]) 	,Nil})
					ENDIF
				ENDIF
			Next nCampos
			lMsErroAuto := .F.

			SM0->(DbGoTop())
			SM0->(MsSeek (cEmpCad+SubStr(cFilAnt,1,4), .T.))	//Pego a filial mais proxima
			cFilAnt := FWGETCODFILIAL

			Begin Transaction
				MSExecAuto({|x,y| MATA220(x,y)},aExecAuto,3) // SB9 Saldo de estoque

				//Caso ocorra erro, verifica se ocorreu antes ou depois dos primeiros 100 registros do arquivo
				If lMsErroAuto
					aLog := {}
					aLog := GetAutoGRLog()
					If nI <= 100
						DisarmTransaction()
						cLogWritet += "Linha do erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						//MostraErro()
						For nX :=1 to Len(aLog)
							cLogWritet += aLog[nX]+CRLF
						next nX
						MsgAlert(StrTran(cLogWritet,"< --","-->"),"Erro no arquivo!")
						cFilAnt := cBKFilial
						Return
					Else
						cLogWrite += "Linha com o erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						For nX :=1 to Len(aLog)
							cLogWrite += aLog[nX]+CRLF
						next nX
					Endif
				EndIF
			End Transaction
			cFilAnt := cFilCad
		Next nI

		//Grava arquivo de LOG caso o erro ocorra depois do 100o registro
		If !Empty(cLogWrite)
			cTime     := Time()
			cLogDir   := cGetFile("Arquivo |*.log", OemToAnsi("Informe o diretorio para gravar o LOG."), 0, "SERVIDOR\", .T., GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY ,.F.)
			cLogFile  := cLogDir+"IMP_"+substr(cTime,1,2)+substr(cTime,4,2)+substr(cTime,7,2)+".LOG"
			nHandle   := MSFCreate(cLogFile,0)
			FWrite(nHandle,cLogWrite)
			FClose(nHandle)
			msgAlert("LOG de erro gerado em "+cLogFile)
		Else
			MsgInfo("Arquivo importado com sucesso!!")
		Endif
		FT_FUSE()
		cFilAnt := cBKFilial

		/*
		========================================================
		Importa tabela de Lotes de Estoque SD5
		========================================================
		*/
	ElseIF nRadMenu1 == 10 // Op√ß√£o 10 - Lotes de Estoque
		If !File(cArq)
			MsgStop("O arquivo " +cArq + " n√£o foi selecionado. A importacao ser√£ abortada!","ATENCAO")
			Return
		EndIf

		FT_FUSE(cArq)
		FT_FGOTOP()
		cLinha    := FT_FREADLN()
		aTipoImp  := Separa(cLinha,";",.T.)
		cTipo     := SUBSTR(aTipoImp[1],1,2)

		IF !(cTIPO $('D5'))
			MsgAlert('N√£o √£ possivel importar a tabela: '+cTipo+ '  !!')
			Return
		ENDIF

		dbSelectArea("SX3")
		DbSetOrder(2)
		For nI := 1 To Len(aTipoImp)
			IF cTipo <> SUBSTR(aTipoImp[nI],1,2)
				MsgAlert('Todos os campos devem pertencer a mesma tabela !!')
				Return
			ENDIF
			IF !SX3->(dbSeek(Alltrim(aTipoImp[nI])))
				MsgAlert('Campo n√£o encontrado na tabela :'+aTipoImp[nI]+' !!')
				Return
			ELSEIF (SX3->X3_VISUAL $ ('V') ) .OR. (SX3->X3_CONTEXT == "V"  )
				MsgAlert('Campo marcado na tabela como visual :'+aTipoImp[nI]+' !!')
				Return
			ENDIF
		Next nI

		nTipoImp  := aScan( aTabExclui, { |x| AllTrim( x[1] ) == cTipo } )

		cTab := ''
		For nI := 1 To Len(aTabExclui[nTipoImp,2])
			cTab += aTabExclui[nTipoImp,2,nI]+' '
		Next nI
		/*
		If MsgYesNo("Deseja excluir os dados da(s) tabela(s):"+cTab+"antes da importacao ? ")
			For nI := 1 To Len(aTabExclui[nTipoImp,2])
				cSQL := "delete from "+RetSqlName(aTabExclui[nTipoImp,2,nI])
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
				cSQL := "delete from "+RetSqlName("AO4") + " where AO4_ENTIDA = '" + aTabExclui[nTipoImp,2,nI] + "'"
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
			Next nI
		EndIf
		*/
		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		While !FT_FEOF()
			IncProc("Lendo arquivo texto...")
			cLinha := FT_FREADLN()
			If lPrim
				aCampos := Separa(cLinha,";",.T.)
				lPrim := .F.
			Else
				AADD(aDados,Separa(cLinha,";",.T.))
			EndIf
			FT_FSKIP()
		EndDo

		ProcRegua(Len(aDados))
		For nI:=1 to  Len(aDados)

			IncProc("Importando arquivo...")
			aExecAuto := {}
			For nCampos := 1 To Len(aCampos)
				IF  SUBSTR(Upper(aCampos[nCampos]),4,6)=='FILIAL'
					IF !EMpty(aDados[nI,nCampos])
						cFilAnt := aDados[nI,nCampos]
					ENDIF
				Else
					IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	VAL(aDados[nI,nCampos] )	,Nil})
					ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  CTOD(aDados[nI,nCampos] )	,Nil})
					ELSE
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	Left(Alltrim(aDados[nI,nCampos]),TAMSX3(Upper(aCampos[nCampos]))[01]) 	,Nil})
					ENDIF
				ENDIF
			Next nCampos
			lMsErroAuto := .F.

			SM0->(DbGoTop())
			SM0->(MsSeek (cEmpCad+SubStr(cFilAnt,1,4), .T.))	//Pego a filial mais proxima
			cFilAnt := FWGETCODFILIAL

			Begin Transaction
				MSExecAuto({|x,y| MATA390(x,y)},aExecAuto,3) // SD5 Lote de estoque

				//Caso ocorra erro, verifica se ocorreu antes ou depois dos primeiros 100 registros do arquivo
				If lMsErroAuto
					aLog := {}
					aLog := GetAutoGRLog()
					If nI <= 100
						DisarmTransaction()
						cLogWritet += "Linha do erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						//MostraErro()
						For nX :=1 to Len(aLog)
							cLogWritet += aLog[nX]+CRLF
						next nX
						MsgAlert(StrTran(cLogWritet,"< --","-->"),"Erro no arquivo!")
						cFilAnt := cBKFilial
						Return
					Else
						cLogWrite += "Linha com o erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						For nX :=1 to Len(aLog)
							cLogWrite += aLog[nX]+CRLF
						next nX
					Endif
				EndIF
			End Transaction
			cFilAnt := cFilCad
		Next nI

		//Grava arquivo de LOG caso o erro ocorra depois do 100o registro
		If !Empty(cLogWrite)
			cTime     := Time()
			cLogDir   := cGetFile("Arquivo |*.log", OemToAnsi("Informe o diretorio para gravar o LOG."), 0, "SERVIDOR\", .T., GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY ,.F.)
			cLogFile  := cLogDir+"IMP_"+substr(cTime,1,2)+substr(cTime,4,2)+substr(cTime,7,2)+".LOG"
			nHandle   := MSFCreate(cLogFile,0)
			FWrite(nHandle,cLogWrite)
			FClose(nHandle)
			msgAlert("LOG de erro gerado em "+cLogFile)
		Else
			MsgInfo("Arquivo importado com sucesso!!")
		Endif
		FT_FUSE()
		cFilAnt := cBKFilial

		/*
		========================================================
		Importa tabela de Pedidos de compra em aberto SC7
		========================================================
		*/
	ElseIF nRadMenu1 == 11 // Op√ß√£o 11 - Pedidos de compra em aberto
		If !File(cArq)
			MsgStop("O arquivo " +cArq + " n√£o foi selecionado. A importacao ser√£ abortada!","ATENCAO")
			Return
		EndIf

		FT_FUSE(cArq)
		FT_FGOTOP()
		cLinha    := FT_FREADLN()
		aTipoImp  := Separa(cLinha,";",.T.)
		cTipo     := SUBSTR(aTipoImp[1],1,2)

		IF !(cTIPO $('C7'))
			MsgAlert('N√£o √£ possivel importar a tabela: '+cTipo+ '  !!')
			Return
		ENDIF

		dbSelectArea("SX3")
		DbSetOrder(2)
		For nI := 1 To Len(aTipoImp)
			IF cTipo <> SUBSTR(aTipoImp[nI],1,2)
				MsgAlert('Todos os campos devem pertencer a mesma tabela !!')
				Return
			ENDIF
			IF !SX3->(dbSeek(Alltrim(aTipoImp[nI])))
				MsgAlert('Campo n√£o encontrado na tabela :'+aTipoImp[nI]+' !!')
				Return
			ELSEIF (SX3->X3_CONTEXT == "V"  )
				MsgAlert('Campo marcado na tabela como visual :'+aTipoImp[nI]+' !!')
				Return
			ENDIF
		Next nI

		nTipoImp  := aScan( aTabExclui, { |x| AllTrim( x[1] ) == cTipo } )

		cTab := ''
		For nI := 1 To Len(aTabExclui[nTipoImp,2])
			cTab += aTabExclui[nTipoImp,2,nI]+' '
		Next nI

		//Pergunta se deseja excluir os dados do cadastro de estrutura antes de importar
		/*
		If MsgYesNo("Deseja excluir os dados da(s) tabela(s):"+cTab+"antes da importacao ? ")
			For nI := 1 To Len(aTabExclui[nTipoImp,2])
				cSQL := "delete from "+RetSqlName(aTabExclui[nTipoImp,2,nI])
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
				cSQL := "delete from "+RetSqlName("AO4") + " where AO4_ENTIDA = '" + aTabExclui[nTipoImp,2,nI] + "'"
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
			Next nI
		EndIf
		*/
		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		While !FT_FEOF()
			IncProc("Lendo arquivo texto...") // Lendo linhas do arquivo
			cLinha := FT_FREADLN()
			If lPrim
				aCampos := Separa(cLinha,";",.T.)
				lPrim := .F.
			Else
				AADD(aDados,Separa(cLinha,";",.T.))
			EndIf
			FT_FSKIP()
		EndDo

		// Processando arquivo
		cCpoCab  := "C7_NUM/C7_EMISSAO/C7_FORNECE/C7_LOJA/C7_COND/C7_FILENT/C7_CONTATO"
		cCpoIte  := "C7_ITEM/C7_PRODUTO/C7_UM/C7_DESCRI/C7_QUANT/C7_PRECO/C7_TOTAL/C7_LOCAL/C7_IPI/C7_DATPRF/C7_TES"
		cPedCom  := ""
		cItemPed := "0001"

		ProcRegua(Len(aDados))

		For nI:=1 to  Len(aDados)
			IncProc("Importando arquivo...")

			If cPedCom # aDados[nI][1] .AND. cItemPed == aDados[nI][8]
				IF Len(aExecAuto) > 0
					lMsErroAuto := .F.

					SM0->(DbGoTop())
					SM0->(MsSeek (cEmpCad+SubStr(cFilAnt,1,4), .T.))	//Pego a filial mais proxima
					cFilAnt := FWGETCODFILIAL

					Begin Transaction
						MSExecAuto({|x,y,z| MATA121(x,y,z)},aExecAuto,aExecAutod,3) // SC7 Pedido de Compra

						//Caso ocorra erro, verifica se ocorreu antes ou depois dos primeiros 100 registros do arquivo
						If lMsErroAuto
							aLog := {}
							aLog := GetAutoGRLog()
							If nI <= 100
								DisarmTransaction()
								cLogWritet += "Linha do erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
								//MostraErro()
								For nX :=1 to Len(aLog)
									cLogWritet += aLog[nX]+CRLF
								next nX
								MsgAlert(StrTran(cLogWritet,"< --","-->"),"Erro no arquivo!")
								cFilAnt := cBKFilial
								Return
							Else
								cLogWrite += "Linha com o erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
								For nX :=1 to Len(aLog)
									cLogWrite += aLog[nX]+CRLF
								next nX
							Endif
						EndIF
					End Transaction
					cFilAnt := cFilCad
					aExecAuto  := {}
					aExecAutod := {}
				Endif

				//Montando array de Cabe√£alho
				For nCampos := 1 To Len(aCampos)
					If Alltrim(aCampos[nCampos]) $ cCpoCab
						IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
							aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	VAL(aDados[nI,nCampos] )	,Nil})
						ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
							aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  CTOD(aDados[nI,nCampos] )	,Nil})
						ELSE
							aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	Left(Alltrim(aDados[nI,nCampos]),TAMSX3(Upper(aCampos[nCampos]))[01]) 	,Nil})
						ENDIF
					ENDIF
				Next nCampos
			Endif
			nCampos := 1
			cPedCom := aDados[nI][1]

			//Monta array de ITENS
			aExecAutol := {}
			For nCampos := 1 To Len(aCampos)-1
				IF  SUBSTR(Upper(aCampos[nCampos]),4,6)=='FILIAL'
					IF !EMpty(aDados[nI,nCampos])
						cFilAnt := aDados[nI,nCampos]
					ENDIF
				Else
					IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
						aAdd(aExecAutol ,{Upper(aCampos[nCampos]), 	VAL(aDados[nI,nCampos] )	,Nil})
					ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
						aAdd(aExecAutol ,{Upper(aCampos[nCampos]),  CTOD(aDados[nI,nCampos] )	,Nil})
					ELSE
						aAdd(aExecAutol ,{Upper(aCampos[nCampos]), 	aDados[nI,nCampos] 	,Nil})
					ENDIF
				ENDIF
			Next nCampos
			aAdd(aExecAutod, aExecAutol)
		Next nI

		// Processa execauto da ultima linha do arquivo lido
		lMsErroAuto := .F.

		SM0->(DbGoTop())
		SM0->(MsSeek (cEmpCad+SubStr(cFilAnt,1,4), .T.))	//Pego a filial mais proxima
		cFilAnt := FWGETCODFILIAL

		Begin Transaction
			MSExecAuto({|x,y,z| MATA121(x,y,z)},aExecAuto,aExecAutod,3) // SC7 Pedido de Compra
			If lMsErroAuto
				DisarmTransaction()
				MostraErro()
				cFilAnt := cBKFilial
				Return
			EndIF
		End Transaction

		cFilAnt := cFilCad

		//Grava arquivo de LOG caso o erro ocorra depois do 100o registro
		If !Empty(cLogWrite)
			cTime     := Time()
			cLogDir   := cGetFile("Arquivo |*.log", OemToAnsi("Informe o diretorio para gravar o LOG."), 0, "SERVIDOR\", .T., GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY ,.F.)
			cLogFile  := cLogDir+"IMP_"+substr(cTime,1,2)+substr(cTime,4,2)+substr(cTime,7,2)+".LOG"
			nHandle   := MSFCreate(cLogFile,0)
			FWrite(nHandle,cLogWrite)
			FClose(nHandle)
			msgAlert("LOG de erro gerado em "+cLogFile)
		Else
			MsgInfo("Arquivo importado com sucesso!!")
		Endif
		FT_FUSE()
		cFilAnt := cBKFilial

		/*
		========================================================
		Importa tabela de Pedidos de venda em aberto SC5/SC6
		========================================================
		*/
	ElseIF nRadMenu1 == 12 // Op√ß√£o 12 - Pedidos de venda em aberto

		//Arquivo Cabe√£alho
		MsgAlert("Essa opÁ„o precisa de 2 arquivos, o primeiro È o arquivo de CABE«ALHO!","ATEN«√O!")
		cArq := cGetFile("Todos os Arquivos|*.csv", OemToAnsi("Informe o diretorio onde se encontra o arquivo."), 0, "SERVIDOR\", .F., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE ,.T.)

		If !File(cArq)
			MsgStop("O arquivo " +cArq + " n„o foi selecionado. A importaÁ„o ser· abortada!","ATEN«√O")
			Return
		EndIf

		FT_FUSE(cArq)
		FT_FGOTOP()
		cLinha    := FT_FREADLN()
		aTipoImp  := Separa(cLinha,";",.T.)
		cTipo     := SUBSTR(aTipoImp[1],1,2)

		IF !(cTIPO $('C5'))
			MsgAlert('N„o È possÌvel importar a tabela: '+cTipo+ '  !!')
			Return
		ENDIF

		dbSelectArea("SX3")
		DbSetOrder(2)
		For nI := 1 To Len(aTipoImp)
			IF cTipo <> SUBSTR(aTipoImp[nI],1,2)
				MsgAlert('Todos os campos devem pertencer a mesma tabela !!')
				Return
			ENDIF
			IF !SX3->(dbSeek(Alltrim(aTipoImp[nI])))
				MsgAlert('Campo n„o encontrado na tabela :'+aTipoImp[nI]+' !!')
				Return
			ELSEIF (SX3->X3_VISUAL $ ('V') ) .OR. (SX3->X3_CONTEXT == "V"  )
				MsgAlert('Campo marcado na tabela como visual :'+aTipoImp[nI]+' !!')
				Return
			ENDIF
		Next nI

		nTipoImp  := aScan( aTabExclui, { |x| AllTrim( x[1] ) == cTipo } )

		cTab := ''
		For nI := 1 To Len(aTabExclui[nTipoImp,2])
			cTab += aTabExclui[nTipoImp,2,nI]+' '
		Next nI
		/*
		If MsgYesNo("Deseja excluir os dados da(s) tabela(s):"+cTab+"antes da importacao ? ")
			For nI := 1 To Len(aTabExclui[nTipoImp,2])
				cSQL := "delete from "+RetSqlName(aTabExclui[nTipoImp,2,nI])
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
				cSQL := "delete from "+RetSqlName("AO4") + " where AO4_ENTIDA = '" + aTabExclui[nTipoImp,2,nI] + "'"
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
			Next nI
		EndIf
		*/
		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		While !FT_FEOF()
			IncProc("Lendo arquivo texto...")
			cLinha := FT_FREADLN()
			If lPrim
				aCampos := Separa(cLinha,";",.T.)
				lPrim := .F.
			Else
				AADD(aDados,Separa(cLinha,";",.T.))
			EndIf
			FT_FSKIP()
		EndDo

		//Arquivo Itens
		MsgAlert("Agora È o arquivo de DETALHE!","ATEN«√O")
		cArqd := cGetFile("Todos os Arquivos|*.csv", OemToAnsi("Informe o diretorio onde se encontra o arquivo."), 0, "SERVIDOR\", .F., GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_NETWORKDRIVE ,.T.)

		If !File(cArqd)
			MsgStop("O arquivo " +cArqd + " n„o foi selecionado. A importacao ser· abortada!","ATENCAO")
			Return
		EndIf

		FT_FUSE(cArqd)
		FT_FGOTOP()
		cLinhad    := FT_FREADLN()
		aTipoImpd  := Separa(cLinhad,";",.T.)
		cTipod     := SUBSTR(aTipoImpd[1],1,2)

		IF !(cTIPOd $('C6'))
			MsgAlert('N„o È possivel importar a tabela: '+cTipod+ '  !!')
			Return
		ENDIF

		dbSelectArea("SX3")
		DbSetOrder(2)
		For nId := 1 To Len(aTipoImpd)
			IF cTipod <> SUBSTR(aTipoImpd[nI],1,2)
				MsgAlert('Todos os campos devem pertencer a mesma tabela !!')
				Return
			ENDIF
			IF !SX3->(dbSeek(Alltrim(aTipoImpd[nI])))
				MsgAlert('Campo n√£o encontrado na tabela :'+aTipoImpd[nId]+' !!')
				Return
			ELSEIF (SX3->X3_CONTEXT == "V"  )
				MsgAlert('Campo marcado na tabela como visual :'+aTipoImpd[nId]+' !!')
				Return
			ENDIF
		Next nId

		nTipoImpd  := aScan( aTabExclui, { |x| AllTrim( x[1] ) == cTipod } )

		cTabd := ''
		For nId := 1 To Len(aTabExclui[nTipoImpd,2])
			cTabd += aTabExclui[nTipoImpd,2,nId]+' '
		Next nId
		/*
		If MsgYesNo("Deseja excluir os dados da(s) tabela(s):"+cTabd+"antes da importacao ? ")
			For nId := 1 To Len(aTabExclui[nTipoImpd,2])
				cSQLd := "delete from "+RetSqlName(aTabExclui[nTipoImpd,2,nId])
				If (TCSQLExec(cSQLd) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
				cSQL := "delete from "+RetSqlName("AO4") + " where AO4_ENTIDA = '" + aTabExclui[nTipoImpd,2,nId] + "'"
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
			Next nId
		EndIf
		*/
		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		While !FT_FEOF()
			IncProc("Lendo arquivo texto...")
			cLinhad := FT_FREADLN()
			If lPrimd
				aCamposd := Separa(cLinhad,";",.T.)
				lPrimd := .F.
			Else
				AADD(aDadosd,Separa(cLinhad,";",.T.))
			EndIf
			FT_FSKIP()
		EndDo

		cPedC5    := ""
		cPedC6    := ""
		//cPedItens := "C6_ITEM/C6_PRODUTO/C6_QTDVEN/C6_PRCVEN/C6_VALOR/C6_TES/C6_ENTREG"
		cPedItens := "C6_ITEM/C6_PRODUTO/C6_QTDVEN/C6_PRCVEN/C6_VALOR/C6_TES/C6_ENTREG/C6_CC"

		//Monta array do cabe√£alho
		ProcRegua(Len(aDados))
		For nI:=1 to  Len(aDados)
			IncProc("Importando arquivos...")
			aExecAuto  := {}
			aExecAutod := {}

			nPsC5NUM := aScan( aCampos , { |x| AllTrim(x) == "C5_NUM" })

			For nCampos := 1 To Len(aCampos)
				IF  SUBSTR(Upper(aCampos[nCampos]),4,6)=='FILIAL'
					IF !EMpty(aDados[nI,nCampos])
						cFilAnt := aDados[nI,nCampos]
					ENDIF
				Else
					IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	VAL(aDados[nI,nCampos] )	,Nil})
					ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  CTOD(aDados[nI,nCampos] )	,Nil})
					ELSEIF  TamSx3(Upper(aCampos[nCampos]))[3] =='M'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	Alltrim(aDados[nI,nCampos])	,Nil})
					ELSE
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	Left(Alltrim(aDados[nI,nCampos]),TAMSX3(Upper(aCampos[nCampos]))[01]) 	,Nil})
					ENDIF
				ENDIF
			Next nCampos
			cPedC5  := aDados[nI][nPsC5NUM]

			nPsC6NUM := aScan( aCamposd , { |x| AllTrim(x) == "C6_NUM" })

			//Monta array dos itens
			For nId:=1 to  Len(aDadosd)
				aExecAutol := {}
				IF cPedC5 == aDadosd[nId][nPsC6NUM]
					For nCamposd := 1 To Len(aCamposd)
						If Alltrim(aCamposd[nCamposd]) $ cPedItens
							IF  SUBSTR(Upper(aCamposd[nCamposd]),4,6)=='FILIAL'
								IF !EMpty(aDadosd[nId,nCamposd])
									cFilAnt := aDadosd[nId,nCamposd]
								ENDIF
							Else
								IF  TamSx3(Upper(aCamposd[nCamposd]))[3] =='N'
									aAdd(aExecAutol ,{Upper(aCamposd[nCamposd]), VAL(aDadosd[nId,nCamposd] )	,Nil})
								ELSEIF TamSx3(Upper(aCamposd[nCamposd]))[3] =='D'
									aAdd(aExecAutol ,{Upper(aCamposd[nCamposd]), CTOD(aDadosd[nId,nCamposd] )	,Nil})
								ELSE
									aAdd(aExecAutol ,{Upper(aCamposd[nCamposd]), aDadosd[nId,nCamposd] 	,Nil})
								ENDIF
							ENDIF
						ENDIF
					Next nCamposd
					//aExecAutol := FWVetByDic(aExecAutol,"SC6",.F.,1)
					aAdd(aExecAutod, aExecAutol)
				ENDIF
			Next nId

			// Executa MSEXECAUTO
			lMsErroAuto := .F.

			SM0->(DbGoTop())
			SM0->(MsSeek (cEmpCad+cFilAnt, .T.))	//Pego a filial mais proxima
			cFilAnt := FWGETCODFILIAL

			nOpcao := 3
			dbSelectArea("SC5")
			SC5->(dbSetOrder(1))
			If SC5->(dbSeek(cFilAnt+aExecAuto[1,2]))
				nOpcao := 4
			Endif

			Begin Transaction

				//aExecAuto  := FWVetByDic(aExecAuto,"SC5")
				//aExecAutod := FWVetByDic(aExecAutod,"SC6",.F.,1)

				MSExecAuto({|x,y,z| MATA410(x,y,z)},aExecAuto,aExecAutod,nOpcao) // SC5/SC6 Pedidos de Venda CABECALHO/ITENS

				//Caso ocorra erro, verifica se ocorreu antes ou depois dos primeiros 100 registros do arquivo
				If lMsErroAuto
					aLog := {}
					aLog := GetAutoGRLog()
					If nI <= 100
						DisarmTransaction()
						cLogWritet += "Linha do erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						//MostraErro()
						For nX :=1 to Len(aLog)
							cLogWritet += aLog[nX]+CRLF
						next nX
						MsgAlert(StrTran(cLogWritet,"< --","-->"),"Erro no arquivo!")
						cFilAnt := cBKFilial
						Return
					Else
						cLogWrite += "Linha com o erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						For nX :=1 to Len(aLog)
							cLogWrite += aLog[nX]+CRLF
						next nX
					Endif
				EndIF
			End Transaction
			cFilAnt := cFilCad
		Next nI

		//Grava arquivo de LOG caso o erro ocorra depois do 100o registro
		If !Empty(cLogWrite)
			cTime     := Time()
			cLogDir   := cGetFile("Arquivo |*.log", OemToAnsi("Informe o diretorio para gravar o LOG."), 0, "SERVIDOR\", .T., GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY ,.F.)
			cLogFile  := cLogDir+"IMP_"+substr(cTime,1,2)+substr(cTime,4,2)+substr(cTime,7,2)+".LOG"
			nHandle   := MSFCreate(cLogFile,0)
			FWrite(nHandle,cLogWrite)
			FClose(nHandle)
			msgAlert("LOG de erro gerado em "+cLogFile)
		Else
			MsgInfo("Arquivo importado com sucesso!!")
		Endif
		FT_FUSE()
		cFilAnt := cBKFilial

		/*
		========================================================
		Importa tabela de Contas a Pagar em aberto SE2
		========================================================
		*/

	ElseIF nRadMenu1 == 13 // Op√ß√£o 13 - Contas a Pagar em aberto
		If !File(cArq)
			MsgStop("O arquivo " +cArq + " n√£o foi selecionado. A importacao ser√£ abortada!","ATENCAO")
			Return
		EndIf

		FT_FUSE(cArq)
		FT_FGOTOP()
		cLinha    := FT_FREADLN()
		aTipoImp  := Separa(cLinha,";",.T.)
		cTipo     := SUBSTR(aTipoImp[1],1,2)

		IF !(cTIPO $('E2'))
			MsgAlert('N√£o √£ possivel importar a tabela: '+cTipo+ '  !!')
			Return
		ENDIF

		dbSelectArea("SX3")
		DbSetOrder(2)
		For nI := 1 To Len(aTipoImp)
			IF cTipo <> SUBSTR(aTipoImp[nI],1,2)
				MsgAlert('Todos os campos devem pertencer a mesma tabela !!')
				Return
			ENDIF
			IF !SX3->(dbSeek(Alltrim(aTipoImp[nI])))
				MsgAlert('Campo n√£o encontrado na tabela :'+aTipoImp[nI]+' !!')
				Return
			ELSEIF (SX3->X3_VISUAL $ ('V') ) .OR. (SX3->X3_CONTEXT == "V"  )
				MsgAlert('Campo marcado na tabela como visual :'+aTipoImp[nI]+' !!')
				Return
			ENDIF
		Next nI

		nTipoImp  := aScan( aTabExclui, { |x| AllTrim( x[1] ) == cTipo } )

		cTab := ''
		For nI := 1 To Len(aTabExclui[nTipoImp,2])
			cTab += aTabExclui[nTipoImp,2,nI]+' '
		Next nI
		/*
		If MsgYesNo("Deseja excluir os dados da(s) tabela(s):"+cTab+"antes da importacao ? ")
			For nI := 1 To Len(aTabExclui[nTipoImp,2])
				cSQL := "delete from "+RetSqlName(aTabExclui[nTipoImp,2,nI])
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
				cSQL := "delete from "+RetSqlName("AO4") + " where AO4_ENTIDA = '" + aTabExclui[nTipoImp,2,nI] + "'"
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
			Next nI
		EndIf
		*/
		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		While !FT_FEOF()
			IncProc("Lendo arquivo texto...")
			cLinha := FT_FREADLN()
			If lPrim
				aCampos := Separa(cLinha,";",.T.)
				lPrim := .F.
			Else
				AADD(aDados,Separa(cLinha,";",.T.))
			EndIf
			FT_FSKIP()
		EndDo

		ProcRegua(Len(aDados))
		For nI:=1 to  Len(aDados)

			IncProc("Importando arquivo...")
			aExecAuto := {}
			For nCampos := 1 To Len(aCampos)
				IF  SUBSTR(Upper(aCampos[nCampos]),4,6)=='FILIAL'
					IF !EMpty(aDados[nI,nCampos])
						cFilAnt := aDados[nI,nCampos]
					ENDIF
				Else
					IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	VAL(aDados[nI,nCampos] )	,Nil})
					ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  CTOD(aDados[nI,nCampos] )	,Nil})
					ELSE
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	Left(Alltrim(aDados[nI,nCampos]),TAMSX3(Upper(aCampos[nCampos]))[01]) 	,Nil})
					ENDIF
				ENDIF
			Next nCampos
			lMsErroAuto := .F.

			SM0->(DbGoTop())
			SM0->(MsSeek (cEmpCad+SubStr(cFilAnt,1,4), .T.))	//Pego a filial mais proxima
			cFilAnt := FWGETCODFILIAL

			Begin Transaction
				MSExecAuto({|y,z| FINA050(y,z)},aExecAuto,3)   // SE2 Contas a Pagar em aberto MESTRE

				//Caso ocorra erro, verifica se ocorreu antes ou depois dos primeiros 100 registros do arquivo
				If lMsErroAuto
					aLog := {}
					aLog := GetAutoGRLog()
					If nI <= 100
						DisarmTransaction()
						cLogWritet += "Linha do erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						//MostraErro()
						For nX :=1 to Len(aLog)
							cLogWritet += aLog[nX]+CRLF
						next nX
						MsgAlert(StrTran(cLogWritet,"< --","-->"),"Erro no arquivo!")
						cFilAnt := cBKFilial
						Return
					Else
						cLogWrite += "Linha com o erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						For nX :=1 to Len(aLog)
							cLogWrite += aLog[nX]+CRLF
						next nX
					Endif
				Else
					nPosAscan := aScan( aExecAuto, { |x| AllTrim( x[1] ) == "E2_ISS" } )
					If nPosAscan > 0
						RecLock("SE2",.F.)
						SE2->E2_ISS := aExecAuto[nPosAscan,2]
						MsUnlock()
					Endif
				EndIF
			End Transaction
			cFilAnt := cFilCad
		Next nI

		//Grava arquivo de LOG caso o erro ocorra depois do 100o registro
		If !Empty(cLogWrite)
			cTime     := Time()
			cLogDir   := cGetFile("Arquivo |*.log", OemToAnsi("Informe o diretorio para gravar o LOG."), 0, "SERVIDOR\", .T., GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY ,.F.)
			cLogFile  := cLogDir+"IMP_"+substr(cTime,1,2)+substr(cTime,4,2)+substr(cTime,7,2)+".LOG"
			nHandle   := MSFCreate(cLogFile,0)
			FWrite(nHandle,cLogWrite)
			FClose(nHandle)
			msgAlert("LOG de erro gerado em "+cLogFile)
		Else
			MsgInfo("Arquivo importado com sucesso!!")
		Endif
		FT_FUSE()
		cFilAnt := cBKFilial

		/*
		========================================================
		Importa tabela de Contas a Receber em aberto SE1
		========================================================
		*/
	ElseIF nRadMenu1 == 14 // Op√ß√£o 14 - Contas a Receber em aberto
		If !File(cArq)
			MsgStop("O arquivo " +cArq + " n√£o foi selecionado. A importacao ser√£ abortada!","ATENCAO")
			Return
		EndIf

		FT_FUSE(cArq)
		FT_FGOTOP()
		cLinha    := FT_FREADLN()
		aTipoImp  := Separa(cLinha,";",.T.)
		cTipo     := SUBSTR(aTipoImp[1],1,2)

		IF !(cTIPO $('E1'))
			MsgAlert('N√£o √£ possivel importar a tabela: '+cTipo+ '  !!')
			Return
		ENDIF

		dbSelectArea("SX3")
		DbSetOrder(2)
		For nI := 1 To Len(aTipoImp)
			IF cTipo <> SUBSTR(aTipoImp[nI],1,2)
				MsgAlert('Todos os campos devem pertencer a mesma tabela !!')
				Return
			ENDIF
			IF !SX3->(dbSeek(Alltrim(aTipoImp[nI])))
				MsgAlert('Campo n√£o encontrado na tabela :'+aTipoImp[nI]+' !!')
				Return
			ELSEIF (SX3->X3_VISUAL $ ('V') ) .OR. (SX3->X3_CONTEXT == "V"  )
				MsgAlert('Campo marcado na tabela como visual :'+aTipoImp[nI]+' !!')
				Return
			ENDIF
		Next nI

		nTipoImp  := aScan( aTabExclui, { |x| AllTrim( x[1] ) == cTipo } )

		cTab := ''
		For nI := 1 To Len(aTabExclui[nTipoImp,2])
			cTab += aTabExclui[nTipoImp,2,nI]+' '
		Next nI
		/*
		If MsgYesNo("Deseja excluir os dados da(s) tabela(s):"+cTab+"antes da importacao ? ")
			For nI := 1 To Len(aTabExclui[nTipoImp,2])
				cSQL := "delete from "+RetSqlName(aTabExclui[nTipoImp,2,nI])
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
				cSQL := "delete from "+RetSqlName("AO4") + " where AO4_ENTIDA = '" + aTabExclui[nTipoImp,2,nI] + "'"
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
			Next nI
		EndIf
		*/
		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		While !FT_FEOF()
			IncProc("Lendo arquivo texto...")
			cLinha := FT_FREADLN()
			If lPrim
				aCampos := Separa(cLinha,";",.T.)
				lPrim := .F.
			Else
				AADD(aDados,Separa(cLinha,";",.T.))
			EndIf
			FT_FSKIP()
		EndDo

		ProcRegua(Len(aDados))
		For nI:=1 to  Len(aDados)

			IncProc("Importando arquivo...")
			aExecAuto := {}
			For nCampos := 1 To Len(aCampos)
				IF  SUBSTR(Upper(aCampos[nCampos]),4,6)=='FILIAL'
					IF !EMpty(aDados[nI,nCampos])
						cFilAnt := aDados[nI,nCampos]
					ENDIF
				Else
					IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	VAL(aDados[nI,nCampos] )	,Nil})
					ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  CTOD(aDados[nI,nCampos] )	,Nil})
					ELSE
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	Left(Alltrim(aDados[nI,nCampos]),TAMSX3(Upper(aCampos[nCampos]))[01]) 	,Nil})
					ENDIF
				ENDIF
			Next nCampos

			lMsErroAuto := .F.

			SM0->(DbGoTop())
			SM0->(MsSeek (cEmpCad+SubStr(cFilAnt,1,4), .T.))	//Pego a filial mais proxima
			cFilAnt := FWGETCODFILIAL

			Begin Transaction
				MSExecAuto({|x,y| FINA040(x,y)},aExecAuto,3)   // SE1 Contas a Receber em aberto MESTRE

				//Caso ocorra erro, verifica se ocorreu antes ou depois dos primeiros 100 registros do arquivo
				If lMsErroAuto
					aLog := {}
					aLog := GetAutoGRLog()
					If nI <= 100
						DisarmTransaction()
						cLogWritet += "Linha do erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						//MostraErro()
						For nX :=1 to Len(aLog)
							cLogWritet += aLog[nX]+CRLF
						next nX
						MsgAlert(StrTran(cLogWritet,"< --","-->"),"Erro no arquivo!")
						cFilAnt := cBKFilial
						Return
					Else
						cLogWrite += "Linha com o erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						For nX :=1 to Len(aLog)
							cLogWrite += aLog[nX]+CRLF
						next nX
					Endif
				EndIF
			End Transaction

			cFilAnt := cFilCad

		Next nI

		//Grava arquivo de LOG caso o erro ocorra depois do 100o registro
		If !Empty(cLogWrite)
			cTime     := Time()
			cLogDir   := cGetFile("Arquivo |*.log", OemToAnsi("Informe o diretorio para gravar o LOG."), 0, "SERVIDOR\", .T., GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY ,.F.)
			cLogFile  := cLogDir+"IMP_"+substr(cTime,1,2)+substr(cTime,4,2)+substr(cTime,7,2)+".LOG"
			nHandle   := MSFCreate(cLogFile,0)
			FWrite(nHandle,cLogWrite)
			FClose(nHandle)
			msgAlert("LOG de erro gerado em "+cLogFile)
		Else
			MsgInfo("Arquivo importado com sucesso!!")
		Endif
		FT_FUSE()
		cFilAnt := cBKFilial

		/*
		========================================================
		Importa tabela de Ordens de Compra SC1
		========================================================
		*/
	ElseIF nRadMenu1 == 15 // Op√ß√£o 15 - Ordens de Compra
		If !File(cArq)
			MsgStop("O arquivo " +cArq + " n√£o foi selecionado. A importacao ser√£ abortada!","ATENCAO")
			Return
		EndIf

		FT_FUSE(cArq)
		FT_FGOTOP()
		cLinha    := FT_FREADLN()
		aTipoImp  := Separa(cLinha,";",.T.)
		cTipo     := SUBSTR(aTipoImp[1],1,2)

		IF !(cTIPO $('C1'))
			MsgAlert('N√£o √£ possivel importar a tabela: '+cTipo+ '  !!')
			Return
		ENDIF

		dbSelectArea("SX3")
		DbSetOrder(2)
		For nI := 1 To Len(aTipoImp)
			IF cTipo <> SUBSTR(aTipoImp[nI],1,2)
				MsgAlert('Todos os campos devem pertencer a mesma tabela !!')
				Return
			ENDIF
			IF !SX3->(dbSeek(Alltrim(aTipoImp[nI])))
				MsgAlert('Campo n√£o encontrado na tabela :'+aTipoImp[nI]+' !!')
				Return
			ELSEIF (SX3->X3_CONTEXT == "V"  )
				MsgAlert('Campo marcado na tabela como virtual :'+aTipoImp[nI]+' !!')
				Return
			ENDIF
		Next nI

		nTipoImp  := aScan( aTabExclui, { |x| AllTrim( x[1] ) == cTipo } )

		cTab := ''
		For nI := 1 To Len(aTabExclui[nTipoImp,2])
			cTab += aTabExclui[nTipoImp,2,nI]+' '
		Next nI
		/*
		If MsgYesNo("Deseja excluir os dados da(s) tabela(s):"+cTab+"antes da importacao ? ")
			For nI := 1 To Len(aTabExclui[nTipoImp,2])
				cSQL := "delete from "+RetSqlName(aTabExclui[nTipoImp,2,nI])
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
				cSQL := "delete from "+RetSqlName("AO4") + " where AO4_ENTIDA = '" + aTabExclui[nTipoImp,2,nI] + "'"
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
			Next nI
		EndIf
		*/
		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		While !FT_FEOF()
			IncProc("Lendo arquivo texto...")
			cLinha := FT_FREADLN()
			If lPrim
				aCampos := Separa(cLinha,";",.T.)
				lPrim := .F.
			Else
				AADD(aDados,Separa(cLinha,";",.T.))
			EndIf
			FT_FSKIP()
		EndDo

		// Processando arquivo
		cCpoCab  := "C1_NUM/C1_SOLICIT/C1_EMISSAO"
		cCpoIte  := "C1_ITEM/C1_PRODUTO/C1_QUANT/C1_DATPRF"
		cSolCom  := ""
		cItemPed := "0001"

		ProcRegua(Len(aDados))

		For nI:=1 to  Len(aDados)
			IncProc("Importando arquivo...")

			If cSolCom # aDados[nI][1] .AND. cItemPed == aDados[nI][2]
				IF Len(aExecAuto) > 0
					lMsErroAuto := .F.
					SM0->(DbGoTop())
					SM0->(MsSeek (cEmpCad+SubStr(cFilAnt,1,4), .T.))	//Pego a filial mais proxima
					cFilAnt := FWGETCODFILIAL
					Begin Transaction
						MSExecAuto({|x,y,z| MATA110(x,y,z)},aExecAuto,aExecAutod,3) // SC1 Solicita√ß√£o de Compra

						//Caso ocorra erro, verifica se ocorreu antes ou depois dos primeiros 100 registros do arquivo
						If lMsErroAuto
							aLog := {}
							aLog := GetAutoGRLog()
							If nI <= 100
								DisarmTransaction()
								cLogWritet += "Linha do erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
								//MostraErro()
								For nX :=1 to Len(aLog)
									cLogWritet += aLog[nX]+CRLF
								next nX
								MsgAlert(StrTran(cLogWritet,"< --","-->"),"Erro no arquivo!")
								cFilAnt := cBKFilial
								Return
							Else
								cLogWrite += "Linha com o erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
								For nX :=1 to Len(aLog)
									cLogWrite += aLog[nX]+CRLF
								next nX
							Endif
						EndIF
					End Transaction
					cFilAnt := cFilCad
					aExecAuto  := {}
					aExecAutod := {}
				Endif

				//Montando array de Cabe√£alho
				For nCampos := 1 To Len(aCampos)
					If Alltrim(aCampos[nCampos]) $ cCpoCab
						IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
							aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	VAL(aDados[nI,nCampos] )	,Nil})
						ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
							aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  CTOD(aDados[nI,nCampos] )	,Nil})
						ELSE
							aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	Left(Alltrim(aDados[nI,nCampos]),TAMSX3(Upper(aCampos[nCampos]))[01]) 	,Nil})
						ENDIF
					ENDIF
				Next nCampos
			Endif
			nCampos := 1
			cSolCom := aDados[nI][1]

			//Monta array de ITENS
			aExecAutol := {}
			For nCampos := 1 To Len(aCampos)-1
				IF  SUBSTR(Upper(aCampos[nCampos]),4,6)=='FILIAL'
					IF !EMpty(aDados[nI,nCampos])
						cFilAnt := aDados[nI,nCampos]
					ENDIF
				Else
					IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
						aAdd(aExecAutol ,{Upper(aCampos[nCampos]), 	VAL(aDados[nI,nCampos] )	,Nil})
					ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
						aAdd(aExecAutol ,{Upper(aCampos[nCampos]),  CTOD(aDados[nI,nCampos] )	,Nil})
					ELSE
						aAdd(aExecAutol ,{Upper(aCampos[nCampos]), 	aDados[nI,nCampos] 	,Nil})
					ENDIF
				ENDIF
			Next nCampos
			aAdd(aExecAutod, aExecAutol)
		Next nI

		// Processa execauto da ultima linha do arquivo lido
		lMsErroAuto := .F.
		SM0->(DbGoTop())
		SM0->(MsSeek (cEmpCad+SubStr(cFilAnt,1,4), .T.))	//Pego a filial mais proxima
		cFilAnt := FWGETCODFILIAL

		Begin Transaction
			MSExecAuto({|x,y,z| MATA110(x,y,z)},aExecAuto,aExecAutod,3) // SC1 Solicita√ß√£o de Compra
			If lMsErroAuto
				DisarmTransaction()
				MostraErro()
				cFilAnt := cBKFilial
				Return
			EndIF
		End Transaction
		cFilAnt := cFilCad

		//Grava arquivo de LOG caso o erro ocorra depois do 100o registro
		If !Empty(cLogWrite)
			cTime     := Time()
			cLogDir   := cGetFile("Arquivo |*.log", OemToAnsi("Informe o diretorio para gravar o LOG."), 0, "SERVIDOR\", .T., GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY ,.F.)
			cLogFile  := cLogDir+"IMP_"+substr(cTime,1,2)+substr(cTime,4,2)+substr(cTime,7,2)+".LOG"
			nHandle   := MSFCreate(cLogFile,0)
			FWrite(nHandle,cLogWrite)
			FClose(nHandle)
			msgAlert("LOG de erro gerado em "+cLogFile)
		Else
			MsgInfo("Arquivo importado com sucesso!!")
		Endif
		FT_FUSE()
		cFilAnt := cBKFilial

/*		
ProcRegua(Len(aDados))
		For nI:=1 to  Len(aDados)

			IncProc("Importando arquivo...")
			aExecAuto := {}
			For nCampos := 1 To Len(aCampos)
				IF  SUBSTR(Upper(aCampos[nCampos]),4,6)=='FILIAL'
					IF !EMpty(aDados[nI,nCampos])
						cFilAnt := aDados[nI,nCampos]
					ENDIF
				Else
					IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	VAL(aDados[nI,nCampos] )	,Nil})
					ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  CTOD(aDados[nI,nCampos] )	,Nil})
					ELSE
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	aDados[nI,nCampos] 	,Nil})
					ENDIF
				ENDIF
			Next nCampos
			lMsErroAuto := .F.
			Begin Transaction
				MSExecAuto({|x,y| MATA110(x,y)},aExecAuto,3) // SC1 Ordes de compra em aberto

				//Caso ocorra erro, verifica se ocorreu antes ou depois dos primeiros 100 registros do arquivo
				If lMsErroAuto
					aLog := {}
					aLog := GetAutoGRLog()
					If nI <= 100
						DisarmTransaction()
						cLogWritet += "Linha do erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						//MostraErro()
						For nX :=1 to Len(aLog)
							cLogWritet += aLog[nX]+CRLF
						next nX
						MsgAlert(StrTran(cLogWritet,"< --","-->"),"Erro no arquivo!")
						cFilAnt := cBKFilial
						Return
					Else
						cLogWrite += "Linha com o erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						For nX :=1 to Len(aLog)
							cLogWrite += aLog[nX]+CRLF
						next nX
					Endif
				EndIF
			End Transaction
		Next nI

		//Grava arquivo de LOG caso o erro ocorra depois do 100o registro
		If !Empty(cLogWrite)
			cTime     := Time()
			cLogDir   := cGetFile("Arquivo |*.log", OemToAnsi("Informe o diretorio para gravar o LOG."), 0, "SERVIDOR\", .T., GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY ,.F.)
			cLogFile  := cLogDir+"IMP_"+substr(cTime,1,2)+substr(cTime,4,2)+substr(cTime,7,2)+".LOG"
			nHandle   := MSFCreate(cLogFile,0)
			FWrite(nHandle,cLogWrite)
			FClose(nHandle)
			msgAlert("LOG de erro gerado em "+cLogFile)
		Else
			MsgInfo("Arquivo importado com sucesso!!")
		Endif
		FT_FUSE()
		cFilAnt := cBKFilial
*/
	/*
		========================================================
		Importa tabela de Naturezaz
		========================================================
		*/

	ElseIF nRadMenu1 == 16 // Op√ß√£o 16 - Cadastro de naturezas
		If !File(cArq)
			MsgStop("O arquivo " +cArq + " n√£o foi selecionado. A importacao ser√£ abortada!","ATENCAO")
			Return
		EndIf

		FT_FUSE(cArq)
		FT_FGOTOP()
		cLinha    := FT_FREADLN()
		aTipoImp  := Separa(cLinha,";",.T.)
		cTipo     := SUBSTR(aTipoImp[1],1,2)

		IF !(cTIPO $('ED'))
			MsgAlert('N√£o √£ possivel importar a tabela: '+cTipo+ '  !!')
			Return
		ENDIF

		dbSelectArea("SX3")
		DbSetOrder(2)
		For nI := 1 To Len(aTipoImp)
			IF cTipo <> SUBSTR(aTipoImp[nI],1,2)
				MsgAlert('Todos os campos devem pertencer a mesma tabela !! : ' + aTipoImp[nI])
				Return
			ENDIF
			IF !SX3->(dbSeek(Alltrim(aTipoImp[nI])))
				MsgAlert('Campo n√£o encontrado na tabela :'+aTipoImp[nI]+' !!')
				Return
			ELSEIF (SX3->X3_VISUAL $ ('V') ) .OR. (SX3->X3_CONTEXT == "V"  )
				MsgAlert('Campo marcado na tabela como visual :'+aTipoImp[nI]+' !!')
				Return
			ENDIF
		Next nI

		nTipoImp  := aScan( aTabExclui, { |x| AllTrim( x[1] ) == cTipo } )

		cTab := ''
		For nI := 1 To Len(aTabExclui[nTipoImp,2])
			cTab += aTabExclui[nTipoImp,2,nI]+' '
		Next nI
		/*
		If MsgYesNo("Deseja excluir os dados da(s) tabela(s):"+cTab+"antes da importacao ? ")
			For nI := 1 To Len(aTabExclui[nTipoImp,2])
				cSQL := "delete from "+RetSqlName(aTabExclui[nTipoImp,2,nI])
				If (TCSQLExec(cSQL) < 0)
					Return MsgStop("TCSQLError() " + TCSQLError())
				EndIf
			Next nI
		EndIf
		*/
		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		While !FT_FEOF()
			IncProc("Lendo arquivo texto...")
			cLinha := FT_FREADLN()
			If lPrim
				aCampos := Separa(cLinha,";",.T.)
				lPrim := .F.
			Else
				AADD(aDados,Separa(cLinha,";",.T.))
			EndIf
			FT_FSKIP()
		EndDo

		ProcRegua(Len(aDados))
		For nI:=1 to  Len(aDados)

			IncProc("Importando arquivo...")
			aExecAuto := {}
			For nCampos := 1 To Len(aCampos)
				IF  SUBSTR(Upper(aCampos[nCampos]),4,6)=='FILIAL'
					IF !EMpty(aDados[nI,nCampos])
						cFilAnt := aDados[nI,nCampos]
					ENDIF
				Else
					IF  TamSx3(Upper(aCampos[nCampos]))[3] =='N'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	VAL(aDados[nI,nCampos] )	,Nil})
					ELSEIF TamSx3(Upper(aCampos[nCampos]))[3] =='D'
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]),  CTOD(aDados[nI,nCampos] )	,Nil})
					ELSE
						aAdd(aExecAuto ,{Upper(aCampos[nCampos]), 	Left(Alltrim(aDados[nI,nCampos]),TAMSX3(Upper(aCampos[nCampos]))[01]) 	,Nil})
					ENDIF
				ENDIF
			Next nCampos
			lMsErroAuto := .F.

			SM0->(DbGoTop())
			SM0->(MsSeek (cEmpCad+SubStr(cFilAnt,1,4), .T.))	//Pego a filial mais proxima
			cFilAnt := FWGETCODFILIAL

			Begin Transaction
				MSExecAuto({|y,z| FINA010(y,z)},aExecAuto,3)   // SED - Cadastro de naturezas

				//Caso ocorra erro, verifica se ocorreu antes ou depois dos primeiros 100 registros do arquivo
				If lMsErroAuto
					aLog := {}
					aLog := GetAutoGRLog()
					If nI <= 100
						DisarmTransaction()
						cLogWritet += "Linha do erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						//MostraErro()
						For nX :=1 to Len(aLog)
							cLogWritet += aLog[nX]+CRLF
						next nX
						MsgAlert(StrTran(cLogWritet,"< --","-->"),"Erro no arquivo!")
						cFilAnt := cBKFilial
						Return
					Else
						cLogWrite += "Linha com o erro no arquivo CSV: "+str(nI+1)+CRLF+CRLF
						For nX :=1 to Len(aLog)
							cLogWrite += aLog[nX]+CRLF
						next nX
					Endif
				EndIF
			End Transaction
			cFilAnt := cFilCad
		Next nI

		//Grava arquivo de LOG caso o erro ocorra depois do 100o registro
		If !Empty(cLogWrite)
			cTime     := Time()
			cLogDir   := cGetFile("Arquivo |*.log", OemToAnsi("Informe o diretorio para gravar o LOG."), 0, "SERVIDOR\", .T., GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY ,.F.)
			cLogFile  := cLogDir+"IMP_"+substr(cTime,1,2)+substr(cTime,4,2)+substr(cTime,7,2)+".LOG"
			nHandle   := MSFCreate(cLogFile,0)
			FWrite(nHandle,cLogWrite)
			FClose(nHandle)
			msgAlert("LOG de erro gerado em "+cLogFile)
		Else
			MsgInfo("Arquivo importado com sucesso!!")
		Endif
		FT_FUSE()
		cFilAnt := cBKFilial

	/*
		========================================================
		Importa tabela de AmarraÁ„o Produto x Fornecedores
		========================================================
		*/

	Elseif  nRadMenu1 == 17 // OpÁ„o 17 - Cadastro de AmarraÁ„o de Produtos x Fornecedores
		If !File(cArq)
			MsgStop("O arquivo " +cArq + " n√£o foi selecionado. A importacao ser√£ abortada!","ATENCAO")
			Return
		EndIf

		FT_FUSE(cArq)
		FT_FGOTOP()
		cLinha    := FT_FREADLN()
		aTipoImp  := Separa(cLinha,";",.T.)
		cTipo     := SUBSTR(aTipoImp[1],1,2)

		IF !(cTIPO $('A5'))
			MsgAlert('N√£o È possivel importar a tabela: '+cTipo+ '  !!')
			Return
		ENDIF

		dbSelectArea("SX3")
		DbSetOrder(2)
		For nI := 1 To Len(aTipoImp)
			IF cTipo <> SUBSTR(aTipoImp[nI],1,2)
				MsgAlert('Todos os campos devem pertencer a mesma tabela !! : ' + aTipoImp[nI])
				Return
			ENDIF
			IF !SX3->(dbSeek(Alltrim(aTipoImp[nI])))
				MsgAlert('Campo n√£o encontrado na tabela :'+aTipoImp[nI]+' !!')
				Return
			ELSEIF (SX3->X3_VISUAL $ ('V') ) .OR. (SX3->X3_CONTEXT == "V"  )
				MsgAlert('Campo marcado na tabela como visual :'+aTipoImp[nI]+' !!')
				Return
			ENDIF
		Next nI

		nTipoImp  := aScan( aTabExclui, { |x| AllTrim( x[1] ) == cTipo } )

		cTab := ''
		For nI := 1 To Len(aTabExclui[nTipoImp,2])
			cTab += aTabExclui[nTipoImp,2,nI]+' '
		Next nI

		ProcRegua(FT_FLASTREC())
		FT_FGOTOP()
		While !FT_FEOF()
			IncProc("Lendo arquivo texto...")
			cLinha := FT_FREADLN()
			If lPrim
				aCampos := Separa(cLinha,";",.T.)
				lPrim := .F.
			Else
				AADD(aDados,Separa(cLinha,";",.T.))
			EndIf
			FT_FSKIP()
		EndDo
		cmsg:= ""
		ProcRegua(Len(aDados))
		For nI:=1 to  Len(aDados)

			IncProc("Importando arquivo... linha: " + StrZero(nI,5))


			for nCampos := 1 to len(aCampos)
				if Alltrim(Upper(aCampos[nCampos]))=='A5_FORNECE'
					cForn := aDados[nI,nCampos]
				Endif
				if Alltrim(Upper(aCampos[nCampos]))=='A5_LOJA'
					cLoja := aDados[nI,nCampos]
				Endif
				if Alltrim(Upper(aCampos[nCampos]))=='A5_PRODUTO'
					cProduto := aDados[nI,nCampos]
				Endif
				if Alltrim(Upper(aCampos[nCampos]))=='A5_CODPRF'
					cProdFor := aDados[nI,nCampos]
				Endif
			Next nCampos
			Begin Transaction
				EZCriaForn(cForn,cLoja,cProduto,cProdFor,@cmsg)
			End Transaction

		Next nI

		//Grava arquivo de LOG caso o erro ocorra depois do 100o registro
		If !Empty(cmsg)
			cTime     := Time()
			cLogDir   := cGetFile("Arquivo |*.log", OemToAnsi("Informe o diretorio para gravar o LOG."), 0, "SERVIDOR\", .T., GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY ,.F.)
			cLogFile  := cLogDir+"IMP_"+substr(cTime,1,2)+substr(cTime,4,2)+substr(cTime,7,2)+".LOG"
			nHandle   := MSFCreate(cLogFile,0)
			FWrite(nHandle,cmsg)
			FClose(nHandle)
			msgAlert("LOG de erro gerado em "+cLogFile)
		Else
			MsgInfo("Arquivo importado com sucesso!!")
		Endif
		FT_FUSE()
		cFilAnt := cBKFilial

		/*
		=================================================================
		Importa tabela de Contratos - Tabelas -> CN9/CNA/CNB/CNC/CNN
		=================================================================
		*/

	Elseif  nRadMenu1 == 18 // OpÁ„o 18 - Cadastro de AmarraÁ„o de Produtos x Fornecedores
		If !File(cArq)
			MsgStop("O arquivo " +cArq + " n„o foi selecionado. A importacao ser· abortada!","ATENCAO")
			Return()
		EndIf

		//Inst‚ncia a classe de auxÌlio de leitura de arquivo texto, por linhas.
		oArquivo := FWFileReader():New(cArq)

		//Se o arquivo pode ser aberto
		if (oArquivo:Open())
			If ! (oArquivo:EoF())

				CN9->(DbSetOrder(1)) //CN9_FILIAL+CN9_NUMERO+CN9_REVISA
				CNA->(DbSetOrder(1)) //CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO
				CNB->(DbSetOrder(1)) //CNB_FILIAL+CNB_CONTRA+CNB_REVISA+CNB_NUMERO+CNB_ITEM
				CNC->(DbSetOrder(1)) //CNC_FILIAL+CNC_NUMERO+CNC_REVISA+CNC_CODIGO+CNC_LOJA
				CNN->(DbSetOrder(1)) //CNN_FILIAL+CNN_USRCOD+CNN_CONTRA+CNN_TRACOD

				//Definindo o tamanho da rÈgua
				aLinhas := oArquivo:GetAllLines()
				nTotLinhas := Len(aLinhas)
				ProcRegua(nTotLinhas)

				//MÈtodo GoTop n„o funciona (dependendo da vers„o da LIB), deve fechar e abrir novamente o arquivo
				oArquivo:Close()
				oArquivo := FWFileReader():New(cArq)
				oArquivo:Open()

				While (oArquivo:HasLine())

					//Incrementa na tela a mensagem
					nLinhaAtu++
					IncProc('Analisando linha ' + cValToChar(nLinhaAtu) + ' de ' + cValToChar(nTotLinhas) + '...')

					// Se n„o for primeira/segunda linha ele alimenta o array
					If nLinhaAtu = 1 .or. nLinhaAtu = 2
						oArquivo:GetLine()
					Else
						cLinAtu := oArquivo:GetLine()
						aAdd(aDados, Separa(cLinAtu, ';') )
					Endif
				EndDo

				//Pega a primeira linha para tratar o cabeÁalho
				cCabec	:= aLinhas[1]				//Primeira linha do arquivo
				cCabec	:= StrTran(cCabec,'Ôªø','') //Retira carecter do excel
				cCabec	:= StrTran(cCabec,' ','')   //Retira espaÁos dos campos
				aCabec  := StrTokArr(cCabec, ";")

				//Valida o cabeÁalho do arquivo
				For nI := 1 to Len(aCabec)
					cCampo := AllTrim(Upper(aCabec[nI]))
					//SÛ ir· validar se for campo
					If SubStr(cCampo,1,3) <> 'PAR'
						If SubStr(cCampo,1,3) $ cTabContr
							cTabela := SubStr(cCampo,1,3)
						Else
							FWAlertError := ('Erro - Campo informado È inv·lido. Coluna invalida: ' + cCampo, 'ERRO')
							Return()
						EndIf
						//Se n„o encontrar na tabela e se tratar de um campo REAL, ir· abortar a importaÁ„o
						If (cTabela)->(FieldPos(cCampo)) == 0 .and. GetSx3Cache(cCampo,"X3_CONTEXT") == 'R'
							FWAlertError := ('Erro - Campo n„o identificado na tabela. Coluna invalida: ' + cCampo, 'ERRO')
							Return()
						EndIf
					Endif
				Next nI

				//FunÁ„o para gravar o contrato
				//fContrato(aDados, @cMsgErro)
				fThreadCtr(aDados, @cMsgErro)

				//Grava arquivo de Log
				If !Empty(GetGlbValue(cMsgErro))
					cTime     := Time()
					cLogDir   := cGetFile("Arquivo |*.log", OemToAnsi("Informe o diretorio para gravar o LOG."), 0, "SERVIDOR\", .T., GETF_LOCALFLOPPY+GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY ,.F.)
					cLogFile  := cLogDir+"IMP_"+substr(cTime,1,2)+substr(cTime,4,2)+substr(cTime,7,2)+".LOG"
					nHandle   := MSFCreate(cLogFile,0)
					FWrite(nHandle,GetGlbValue(cMsgErro))
					FClose(nHandle)
					FWAlertError('Alguns Contratos n„o foram gerado, verificar o log no caminho: ' + cLogFile + CRLF, 'ImportaÁ„o de Contratos')
				Else
					FWAlertSuccess('Todos contratos foram gerados corretamente!','ImportaÁ„o de Contratos')
				Endif
			Else
				FWAlertWarning("Arquivo n„o tem dados!", "AtenÁ„o")
			EndIf

			//Fecha o arquivo
			oArquivo:Close()

		Else
			FWAlertError("Arquivo n„o pode ser aberto!", "Erro")
		EndIf
	Endif

Return

Static Function EZCriaForn(cForn,cLoja,cProduto,cProdFor,cMsg)

	// SA5 - Amarracao Produto x Fornecedor - MATA061

	Local oModel := FWLoadModel('MATA061')
	Local aErro  := {}
	Local nOpcao := 3
	Local lRet   := .T.

	dbSelectArea("SA5")
	SA5->(dbSetOrder(1))    // A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO+A5_FABR+A5_FALOJA+A5_REFGRD
	If SA5->(dbSeek(xFilial("SA5")+cForn+cLoja+cProduto))
		nOpcao := 4
	Endif

	oSA5MdField := oModel:getModel("MdFieldSA5")
	oSA5MdGrid  := oModel:getModel("MdGridSA5")

	oModel:SetOperation(nOpcao)
	oModel:Activate()

	If nOpcao  == 3
		oSA5MdGrid:SetValue("A5_FORNECE",cForn)
		oSA5MdGrid:SetValue("A5_LOJA",cLoja)
		oSA5MdField:SetValue("A5_PRODUTO",cProduto)
		oSA5MdGrid:SetValue("A5_CODPRF",cProdFor)
	Else
		lFind := oSA5MdGrid:SeekLine({{"A5_FORNECE",cForn},{"A5_LOJA",cLoja},{"A5_PRODUTO",cProduto}})
		if lFind
			oSA5MdGrid:SetValue("A5_CODPRF",cProdFor)
		Endif
	Endif

	oSA5MdGrid:SetValue("A5_CODPRF",cProdFor)

	If oModel:VldData()
		If !oModel:CommitData()
			lRet := .F.
		EndIf
	Else
		lRet := .F.
	EndIf

	If !lRet
		aErro := oModel:GetErrorMessage()
		cMsg := "Id do formul·rio de origem:"  + ' [' + cValToChar(aErro[01]) + '], '
		cMsg += "Id do campo de origem: "      + ' [' + cValToChar(aErro[02]) + '], '
		cMsg += "Id do formul·rio de erro: "   + ' [' + cValToChar(aErro[03]) + '], '
		cMsg += "Id do campo de erro: "        + ' [' + cValToChar(aErro[04]) + '], '
		cMsg += "Id do erro: "                 + ' [' + cValToChar(aErro[05]) + '], '
		cMsg += "Mensagem do erro: "           + ' [' + cValToChar(aErro[06]) + '], '
		cMsg += "Mensagem da soluÁ„o: "        + ' [' + cValToChar(aErro[07]) + '], '
		cMsg += "Valor atribuÌdo: "            + ' [' + cValToChar(aErro[08]) + '], '
		cMsg += "Valor anterior: "             + ' [' + cValToChar(aErro[09]) + ']'
		//       cMsgRetorno += "  SA5   ;'" + cForn+"-"+cLoja + " ;'" + cProduto + " ;' " + Padr(cProdFor,30) + " ;' ERRO: " + cMsg  +  CRLF
	Else
		dbSelectArea("SA5")
		SA5->(dbSetOrder(1))    // A5_FILIAL+A5_FORNECE+A5_LOJA+A5_PRODUTO+A5_FABR+A5_FALOJA+A5_REFGRD

	Endif

	oModel:DeActivate()

	oModel:Destroy()

Return lRet

//FunÁ„o para gerar contrato MVC
User Function fContrato(aDados, cMsgErro)

	Local aArea             := FWGetArea()          	as Array
	Local aMsgDeErro        := {}                   	as Array
	Local aItens		 	:= {}                   	as Array
	Local oModel            := Nil                  	as Object
	Local oModelCNA 		:= Nil 						as Object
	Local oModelCNB 		:= Nil 						as Object
	Local oModelCNC			:= Nil 						as Object
	Local nC          		:= 0						as Numeric
	Local nI          		:= 0                    	as Numeric
	Local nF				:= 0                    	as Numeric
	Local nP				:= 0                    	as Numeric
	Local nItem 			:= 0						as Numeric
	Local cTpContr         	:= ""                   	as Character
	Local cCtrFixo			:= ""                   	as Character
	Local cContrato		 	:= ""                   	as Character
	Local cNumPla	   		:= ""                   	as Character
	Local cMsgAux			:= ""                   	as Character

	//Ordena o array pelo n˙mero de contrato, para evitar duplicidade
	aSort(aDados, , , {|x, y| x[1] <  y[1] })

	//ComeÁando na terceira linha para n„o ler o cabeÁalho
	For nC := 1 to Len(aDados)

		If cContrato <> aDados[nC][1]

			aItens 	 := {} //Limpa o array de itens
			cNumPla  := '' //Limpa o n˙mero da planilha

			cContrato   := Alltrim(aDados[nC][1])
			cTpContr 	:= PadL(aDados[nC][2], TamSX3('CN9_TPCTO')[01], '0')

			CN9->(DbSetOrder(1)) //CN9_FILIAL+CN9_NUMERO+CN9_REVISA
			If ! CN9->(MsSeek(FwxFilial('CN9')+PadL(aDados[nC][1], TamSX3('CN9_NUMERO')[01], '0')))

				//Filtra o contrato, caso tenha em mais de uma linha
				For nI := 1 to len(aDados)
					If aDados[nI][1] == cContrato

						aAdd(aItens, aDados[nI])
					Endif
				Next nI

				//Ordena os itens do contrato pelo n˙mero da planilha
				aSort(aItens, , , {|x, y| x[25] <  y[25] })

				//Busca o tipo do contrato
				CN1->(DbSetOrder(1)) //CN1_FILIAL+CN1_CODIGO+CN1_ESPCTR
				If CN1->(MSSeek(FWxFilial("CN1") + cTpContr))
					cCtrFixo := CN1->CN1_CTRFIX
					cEspCtr  := CN1->CN1_ESPCTR
				Endif

				oModel := FWLoadModel("CNTA300") 			//Carrega o modelo
				oModel:SetOperation(MODEL_OPERATION_INSERT) //Seta operacao de inclusao
				oModel:Activate() 							//Ativa o Modelo

				//Cabecalho do contrato
				oModel:SetValue(    'CN9MASTER'    ,'CN9_NUMERO'        ,PadL(aDados[nC][1], TamSX3('CN9_NUMERO')[01], '0'))
				oModel:SetValue(    'CN9MASTER'    ,'CN9_TPCTO'         ,cTpContr)
				oModel:SetValue(    'CN9MASTER'    ,'CN9_DESCRI'        ,Alltrim(aDados[nC][3]))
				oModel:SetValue(    'CN9MASTER'    ,'CN9_DTINIC'        ,CtoD(aDados[nC][4]))
				oModel:SetValue(    'CN9MASTER'    ,'CN9_UNVIGE'        ,aDados[nC][5])
				oModel:SetValue(    'CN9MASTER'    ,'CN9_VIGE'          ,Val(aDados[nC][6]))
				oModel:SetValue(    'CN9MASTER'    ,'CN9_MOEDA'         ,PadL(Val(aDados[nC][7]), TamSX3('CN9_MOEDA')[01], '0'))
				oModel:SetValue(    'CN9MASTER'    ,'CN9_CONDPG'        ,PadL(aDados[nC][8], TamSX3('CN9_CONDPG')[01], '0'))
				oModel:SetValue(    'CN9MASTER'    ,'CN9_FLGREJ'        ,aDados[nC][9])
				oModel:SetValue(    'CN9MASTER'    ,'CN9_INDICE'        ,PadL(aDados[nC][10], TamSX3('CN9_INDICE')[01], '0'))
				oModel:SetValue(    'CN9MASTER'    ,'CN9_FLGCAU'        ,aDados[nC][11])
				oModel:SetValue(    'CN9MASTER'    ,'CN9_OBJCTO'        ,Alltrim(aDados[nC][12]))
				oModel:SetValue(    'CN9MASTER'    ,'CN9_ALTCLA'        ,Alltrim(aDados[nC][13]))
				oModel:SetValue(    'CN9MASTER'    ,'CN9_VLDCTR'        ,aDados[nC][14])
				oModel:SetValue(    'CN9MASTER'    ,'CN9_APROV'         ,aDados[nC][15])
				oModel:SetValue(    'CN9MASTER'    ,'CN9_GRPAPR'        ,aDados[nC][16])
				oModel:SetValue(    'CN9MASTER'    ,'CN9_NATURE'        ,PadL(aDados[nC][17], TamSX3('CN9_NATURE')[01], '0'))
				oModel:SetValue(    'CN9MASTER'    ,'CN9_DEPART'        ,PadL(aDados[nC][18], TamSX3('CN9_DEPART')[01], '0'))
				oModel:SetValue(    'CN9MASTER'    ,'CN9_PERI'          ,Val(aDados[nC][19]))
				oModel:SetValue(    'CN9MASTER'    ,'CN9_UNPERI'        ,aDados[nC][20])
				oModel:SetValue(    'CN9MASTER'    ,'CN9_MODORJ'        ,aDados[nC][21])
				oModel:SetValue(    'CN9MASTER'    ,'CN9_PRORAT'        ,aDados[nC][22])

				oModelCNC := oModel:GetModel("CNCDETAIL")
				oModelCNA := oModel:GetModel("CNADETAIL")
				oModelCNB := oModel:GetModel("CNBDETAIL")

				//Cliente/Fornecedor do Contrato
				For nF := 1 to Len(aItens)

					If nF > 1 .and. ! Empty (aItens[nF][23])
						oModelCNC:AddLine()
					Endif

					If cEspCtr == '1' //Compra
						oModelCNC:SetValue(    'CNC_CODIGO'        ,PadL(aItens[nF][23], TamSX3('CNC_CODIGO')[01], '0'))
						oModelCNC:SetValue(    'CNC_LOJA'          ,PadL(aItens[nF][24], TamSX3('CNC_LOJA')[01], '0'))
					Else
						oModelCNC:SetValue(    'CNC_CLIENT'        ,PadL(aItens[nF][23], TamSX3('CNC_CLIENT')[01], '0'))
						oModelCNC:SetValue(    'CNC_LOJACL'         ,PadL(aItens[nF][24], TamSX3('CNC_LOJACL')[01], '0'))
					Endif
				Next nF

				//Planilhas do Contrato
				For nP := 1 to Len(aItens)

					If cNumPla <> aItens[nP][25]

						cNumPla :=  aItens[nP][25]

						If nP > 1
							If oModelCNA:VldData()
								aMsgDeErro := oModel:GetErrorMessage()
								cMsgAux   := aMsgDeErro[6]
								cMsgAux   += 'Contrato: ' + cContrato + ' ' +  "Erro: " + cMsgAux + CRLF
								PutGlbValue(cMsgErro ,cMsgAux)
								Exit
							Else
								oModelCNA:AddLine()
							Endif
						Endif

						oModelCNA:LoadValue(	'CNA_CONTRA'       ,PadL(aDados[nC][1],  TamSX3('CNA_CONTRA')[01], '0'))
						oModelCNA:LoadValue( 	'CNA_NUMERO'       ,PadL(aItens[nP][25], TamSX3('CNA_NUMERO')[01], '0'))
						If cEspCtr == '1' //Compra
							oModelCNA:SetValue( 	'CNA_FORNEC'       ,PadL(aItens[nP][26], TamSX3('CNA_FORNEC')[01], '0'))
							oModelCNA:SetValue( 	'CNA_LJFORN'       ,PadL(aItens[nP][27], TamSX3('CNA_LJFORN')[01], '0'))
						Else
							oModelCNA:SetValue( 	'CNA_CLIENT'       ,PadL(aItens[nP][26], TamSX3('CNA_CLIENT')[01], '0'))
							oModelCNA:SetValue( 	'CNA_LOJACL'       ,PadL(aItens[nP][27], TamSX3('CNA_LOJACL')[01], '0'))
						Endif
						oModelCNA:SetValue( 	'CNA_TIPPLA'       ,PadL(aItens[nP][28], TamSX3('CNA_TIPPLA')[01], '0'))

						nItem := 0

						//Itens da Planilha do Contrato
						If cCtrFixo <> '2' //Contrato N„o fixo (Flexivel) n„o gera Itens
							For nI := 1 to Len(aItens)

								If cNumPla == aItens[nI][29]
									nItem ++

									If nItem > 1
										oModelCNB:AddLine()
									EndiF
									oModelCNB:LoadValue(	'CNB_ITEM'         ,PadL(nItem, TamSX3("CNB_ITEM")[1], '0'))
									oModelCNB:SetValue(		'CNB_PRODUT'       ,PadL(aItens[nI][30], TamSX3('CNB_PRODUT')[01], '0'))
									If cCtrFixo <> '3' //Contrato SEMI-FIXO, nao preenche quantidade
										oModelCNB:SetValue(		'CNB_QUANT'        ,Val(aItens[nI][31]))
									Endif
									oModelCNB:SetValue(    'CNB_VLUNIT'       ,Val(aItens[nI][32]))
									oModelCNB:SetValue(    'CNB_CONTA'        ,aItens[nI][33])
									If  cEspCtr == '1' //Compra
										oModelCNB:SetValue(    'CNB_TE'           ,PadL(aItens[nI][34], TamSX3('CNB_TE')[01], '0'))
									Else
										oModelCNB:SetValue(    'CNB_TS'           ,PadL(aItens[nI][34], TamSX3('CNB_TS')[01], '0'))
									Endif
									oModelCNB:SetValue(    'CNB_CC'           ,aItens[nI][35])

									//Cronograma Financeiro
									If cCtrFixo == '1' //Contrato FIXO gera cronograma

										SetMVValue("CN300CRG"       ,"MV_PAR01"     ,Val(aItens[nI][36]))									//1=Mensal, 2=Quinzenal, 3=Di·rio, 4=CondiÁ„o Pagamento
										SetMVValue("CN300CRG"       ,"MV_PAR02"     ,Val(aItens[nI][37]))  									//N˙mero de dias para avanÁar nas parcelas do cronograma
										SetMVValue("CN300CRG"       ,"MV_PAR03"     ,Val(aItens[nI][38]))  									//1- Dt n„o existir: Quando a data calculada pelo intervalo de dias informados n„o existir no referido mÍs. 2- N„o: Quando a data calculada pelo sistema n„o existir, utiliza o primeiro dia do mÍs seguinte. 3- Sempre: Ultiliza sempre o ultimo dia do mÍs na data prevista de mediÁ„o, quando a periodicidade È mensal.
										SetMVValue("CN300CRG"       ,"MV_PAR04"     ,aItens[nI][39])		    							//Deve ser composta por mÍs/ano no formato MM/AAAA(Exemplo: 12/2018)
										SetMVValue("CN300CRG"       ,"MV_PAR05"     ,CtoD(aItens[nI][40]))									//Data prevista para que ocorra a primeira mediÁ„o(exemplo: 20/12/2018 )
										SetMVValue("CN300CRG"       ,"MV_PAR06"     ,Val(aItens[nI][41]))									//N˙mero de parcelas do cronograma
										SetMVValue("CN300CRG"       ,"MV_PAR07"     ,PadL(aItens[nI][42], TamSX3('CN9_CONDPG')[01], '0'))	//CÛdigo da condiÁ„o de pagamento que as parcelas do cronograma devem ser geradas
										SetMVValue("CN300CRG"       ,"MV_PAR08"     ,Val(aItens[nI][43]))									//Taxa de Juros para c·lculo do valor presente

										Pergunte("CN300CRG",.F.)
										CN300PrCF(.T.) //Incluir cronograma financeiro/fisico
									Endif
								Endif
							Next nI
						Endif
					Endif
				Next nP

				//Usuario de acesso com controle TOTAL
				oModel:LoadValue(   'CNNDETAIL'     ,'CNN_CONTRA'       ,PadL(aDados[nC][1], TamSX3('CN9_NUMERO')[01], '0'))
				oModel:LoadValue(   'CNNDETAIL'     ,'CNN_USRCOD'       ,PadL(aDados[nC][44], TamSX3('CNN_USRCOD')[01], '0'))
				oModel:SetValue(    'CNNDETAIL'     ,'CNN_TRACOD'       ,"001")

				//Validacao e Gravacao dos dados e LOG
				If oModel:VldData()
					If oModel:CommitData()

						//cMsgSuces	+=  'Contrato: ' + cContrato + ' ' +  "IncluÌdo com Sucesso: " + CRLF
					Endif
				Else
					//Caso nao tenha sido gravado o contrato, verifica o erro
					aMsgDeErro := oModel:GetErrorMessage()
					cMsgAux   := aMsgDeErro[6]
					cMsgAux   += 'Contrato: ' + cContrato + ' ' +  "Erro: " + cMsgAux + CRLF
					PutGlbValue(cMsgErro ,cMsgAux)
				EndIf
			Else
				cMsgAux   += 'Contrato: ' + cContrato + ' ' +  "Erro: " + 'N˙mero de Contrato j· existente!' + CRLF
				PutGlbValue(cMsgErro ,cMsgAux)
			Endif
		Endif
	Next nC

	If Empty(cMsgAux)
        PutGlbValue(cMsgErro ,"")
    Endif

	FWRestArea(aArea)

Return()

//FunÁ„o para controlar THread
Static Function fThreadCtr(aDados,cMsgErro)

	Local oIPC
	Local nThreadIPC	:= 1			  as Numeric
	Local cSemaphore	:= 'fThreadCtr'	  as Character
	Local cError 		:= ''			  as Character

	oIPC := FWIPCWait():New(cSemaphore,10000)
	oIPC:SetThreads(nThreadIPC)
	oIPC:SetEnvironment(FWGrpCompany(),FWCodFil())
	oIPC:Start("u_fContrato")
	oIPC:StopProcessOnError(.T.)
	oIPC:SetNoErrorStop(.T.) //Se der erro em alguma thread sai imediatamente
	oIPC:Go(aDados,cMsgErro)

	If oIPC <> nil
		oIPC:Stop()
		cError:= oIPC:GetError()
		oIPC    :=  NIL
	EndIf

Return()
