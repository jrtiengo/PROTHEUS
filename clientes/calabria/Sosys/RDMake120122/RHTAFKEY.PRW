#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} RHTAFKEY
Programa para atualizar o TAFKEY de acordo com a TAFST2
@author  lidio.oliveira
@since   20/10/2020
@version 1.0
/*/
User Function RHTAFKEY()

	Local nOpcA     := 0
	Local aButtons  := {}
	Local aSays     := {}

	Private aPerg   := {}
	Private aTitle  := {}
	Private aLog    := {}

	aAdd(aSays,OemToAnsi( "Este programa tem como objetivo realizar o preenchimento dos campos R8_TAFKI"))
	aAdd(aSays,OemToAnsi( "e R8_TAFKF da rotina de ausências, consulte a documentação disponível em"))
	aAdd(aSays,OemToAnsi( "https://tdn.totvs.com/x/yHDpIQ para confirmar necessidade desta execução" ))
	aAdd(aSays,OemToAnsi( ""))
	aAdd(aSays,OemToAnsi( "Obs.: efetue o backup da tabela SR8 antes de prosseguir!"))

	aAdd(aButtons, { 14, .T., {|| ShellExecute("open","https://tdn.totvs.com/x/yHDpIQ","","",1) } } )
	aAdd(aButtons, { 5, .T., {|| fParam(@aPerg) } } )
	aAdd(aButtons, { 1, .T., {|o| nOpcA := 1,IF(gpconfOK(), FechaBatch(), nOpcA := 0 ) } } )
	aAdd(aButtons, { 2, .T., {|o| FechaBatch() } } )

	//Abre a tela de processamento
	FormBatch( "Atualização dos campos R8_TAFKI e R8_TAFKF", aSays, aButtons )

	//Efetua o processamento de geração
	If nOpcA == 1
		Aadd( aTitle, OemToAnsi( "Funcionários que tiveram ajuste:" ) )
		Aadd( aTitle, OemToAnsi( "Funcionários que NÃO tiveram ajuste:" ) )
		Aadd( aLog, {} )
		Aadd( aLog, {} )
		ProcGpe( {|lEnd| fProc()},,,.T. )
		fMakeLog(aLog,aTitle,,,"RHTAFKEY",OemToAnsi("Log de Ocorrências"),"M","P",,.F.)
	EndIf

Return


/*/{Protheus.doc} fProc
Função responsável pelo processamento dos dados.
@author  lidio.oliveira
@since   20/10/2020
@version 1.0
/*/
Static Function fProc()

	Local lBackup       := MsgYesNo("O backup da tabela SR8 já foi realizado?")
	Local lTemReg       := .F.
	Local cIdC9V        := ""
	Local cFilSR8       := ""
	Local cMatric       := ""
	Local cCPF          := ""
	Local cCodUnic      := ""
	Local aFilInTaf     := {}
	Local cFilEnv       := ""
	Local cbkp          := ""
	Local cTipo         := ""
	Local cOldFilEnv    := ""
	Local lFilAux       := .F.
	Local nX            := 0
	Local aFilInAux     := {}
	Local cDtIncSis     := ""
	Local cDtIntTaf		:= ""
	Local lAtuDt		:= .F.

	Private cTabSR8 := "cTabSR8"
	Private oTmpSR8 := Nil

	//Preenchimento dos campos de/até é obrigatório:
	If Len(aPerg) > 0 .And. (Empty(aPerg[1,2]) .Or. Empty(aPerg[1,4]) .Or. Empty(aPerg[1,6]))
		MsgAlert("Verifique o preenchimento dos parâmetros 'Filial Ate', 'Mat Ate' e 'Data Ate' para executar esta rotina. Estes perguntes tem preenchimento obrigatório.")
		Return
	EndIf

	If lBackup
		//Cria tabela com os registros da tabela SR8 com os campos TAFKI e TAFKF em branco
		lTemReg := fMntSR8()

		If lTemReg
			cNomeTab := oTmpSR8:GetRealName()

			(cTabSR8)->(DBGOTOP())
			While (cTabSR8)->(!Eof())
				cFilSR8     :=  (cTabSR8)->FILIAL
				cMatric     :=  (cTabSR8)->MAT
				cCPF        :=  (cTabSR8)->CIC
				cCodUnic    :=  (cTabSR8)->CODUNIC
				cDtIncSis   := ""
				cDtIntTaf	:= ""

				cFilAnt := (cTabSR8)->FILIAL

				//Verifica filial centralizadora do envio
				If cOldFilEnv != cFilAnt
					cOldFilEnv := cFilAnt
					lFilAux		:= .F.
					For nX := 1 To Len(aFilInTaf)
						If aScan( aFilInTaf[nX, 3], { |x| x == cFilAnt } ) > 0
							cFilEnv := aFilInTaf[nX, 2]
							lFilAux	:= .T.
							Exit
						EndIf
					Next nX
					If !lFilAux
						fGp23Cons(aFilInAux, {cFilAnt})
						For nX := 1 To Len(aFilInAux)
							If aScan( aFilInAux[nX, 3], { |x| x == cFilAnt } ) > 0
								cFilEnv := aFilInAux[nX, 2]
								Exit
							EndIf
						Next nX
					EndIf
				EndIf

				//Pesquisa na tabela C9V qual é o Id Do funcionário
				If Empty(cIdC9V) .Or. cbkp <> cFilSR8 + cMatric
					cIdC9V  := fGetID(cFilEnv, cCPF, cCodUnic)
					cbkp    := cFilSR8 + cMatric
				EndIf

				//Pesquisa na tabela CM6 se há afastamentos no período informado e guarda o RECNO
				If !Empty(cIdC9V)
					If !Empty((cTabSR8)->DATAINI) .And. !Empty((cTabSR8)->DATAFIM) .And. Empty((cTabSR8)->TAFKI) .And. Empty((cTabSR8)->TAFKF)
						cTipo := "COMP"
					ElseIf !Empty((cTabSR8)->DATAINI) .And. Empty((cTabSR8)->TAFKI)
						cTipo := "INIC"
					ElseIf !Empty((cTabSR8)->DATAFIM) .And. Empty((cTabSR8)->TAFKF)
						cTipo := "TERM"
					ElseIf (cTabSR8)->ATUDT == "S" //somente atualiza data de integração
						lAtuDt	:= .T.
						If (cTabSR8)->TAFKI == (cTabSR8)->TAFKF
							cTipo 	:= "COMP"
						ElseIf Empty((cTabSR8)->TAFKF )
							cTipo 	:= "INIC"
						Else
							cTipo 	:= "TERM"
						EndIf
					Else //Se nenhuma condição foi atendida a ausência não foi/deve ser integrada
						aAdd( aLog[2], "Filial: " + (cTabSR8)->FILIAL + " -  Matrícula: " + (cTabSR8)->MAT + " Dt. Afast.: " + DTOC(STOD((cTabSR8)->DATAINI)) + " -  Ausência não possui data fim e início já foi integrado ao TAF."  )
						(cTabSR8)->(dbSkip())
						Loop
					EndIf

					cRecnoCM6 := CVALTOCHAR(fGetRecno(cFilEnv, cIdC9V, (cTabSR8)->DATAINI, (cTabSR8)->DATAFIM, cTipo, @cDtIncSis))

					//Se não for atualizar somente a data
					If !lAtuDt
						//Se retornou o Recno pesquisa o TAFKEY nas tabelas TAFXERP e TAFST2 e atualiza a SR8
						If !Empty(cRecnoCM6) .And. cRecnoCM6 > "0"
							cTafkey := fGetKey(cRecnoCM6, cDtIncSis, cFilEnv)
							If !Empty(cTafkey)
								DBSelectArea("SR8")
								SR8->(DBSetOrder(1)) //R8_FILIAL+R8_MAT+DTOS(R8_DATAINI)+R8_TIPO
								("SR8")->(DBGOTOP())
								If SR8->(DBSEEK(cFilSR8 + cMatric + (cTabSR8)->DATAINI ))
									//Se enviou a data fim antes da data, por exemplo, quando são menos de 15 dias de afastamento, gravar o final do afastamento no R8_INTGTAF e não a DDATABASE
									If ( !Empty((cTabSR8)->DATAFIM ) ) .And. ((cTabSR8)->TPEFD  <> '15' .And. STOD((cTabSR8)->DATAFIM) - STOD((cTabSR8)->DATAINI) <= 15 )
										cDtIntTaf := (cTabSR8)->DATAFIM
									Else
										cDtIntTaf := cDtIncSis
									EndIf

									//Grava os ajustes na tabela SR8
									If RecLock("SR8", .F.)
										If cTipo = "COMP"
											SR8->R8_TAFKI 	:= cTafkey
											SR8->R8_TAFKF 	:= cTafkey
											SR8->R8_INTGTAF	:= STOD(cDtIntTaf)
										ElseIf cTipo = "INIC"
											SR8->R8_TAFKI 	:= cTafkey
											SR8->R8_INTGTAF	:= STOD(cDtIntTaf)
										Else
											SR8->R8_TAFKF 	:= cTafkey
											SR8->R8_INTGTAF	:= STOD(cDtIntTaf)
										EndIf
										("SR8")->(MsUnLock())
										aAdd( aLog[1], "Registro: Filial: " + (cTabSR8)->FILIAL + " -  Matrícula: " + (cTabSR8)->MAT  + "  -  Tp. de Afast.: " + cTipo + " - Dt do Afast.: " + If(cTipo == "TERM", DTOC(STOD((cTabSR8)->DATAFIM)), DTOC(STOD((cTabSR8)->DATAINI))) +  " ATUALIZADO com sucesso")
										(cTabSR8)->(dbSkip())
										Loop
									EndIf
								Endif
							Else
								aAdd( aLog[2], "Filial: " + (cTabSR8)->FILIAL + " -  Matrícula: " + (cTabSR8)->MAT + "  -  NÃO foi encontrado o TAFKEY na tabela TAFXERP ao pesquisar pelo afastamento. RECNO da CM6:" + cRecnoCM6 )
								(cTabSR8)->(dbSkip())
								Loop
							EndIf
						Else
							If cTipo == "COMP"
								aAdd( aLog[2], "Filial: " + (cTabSR8)->FILIAL + " -  Matrícula: " + (cTabSR8)->MAT + "  -  Afastamento do tipo COMPLETO não encontrado no TAF.  -  Dt. Afast.: " + DTOC(STOD((cTabSR8)->DATAINI)) + " - " + DTOC(STOD((cTabSR8)->DATAFIM)) )
							ElseIf cTipo == "INIC"
								aAdd( aLog[2], "Filial: " + (cTabSR8)->FILIAL + " -  Matrícula: " + (cTabSR8)->MAT + "  -  Afastamento do tipo INICIO não encontrado no TAF. - Dt. de Início: " + DTOC(STOD((cTabSR8)->DATAINI)) )
							Else
								aAdd( aLog[2], "Filial: " + (cTabSR8)->FILIAL + " -  Matrícula: " + (cTabSR8)->MAT + "  -  Afastamento do tipo TERMINO não encontrado no TAF. - Dt. Final: " + DTOC(STOD((cTabSR8)->DATAINI)) )
							EndIf
							(cTabSR8)->(dbSkip())
							Loop
						EndIf
					Else
						//Atualiza a data de de integração com o Taf
						DBSelectArea("SR8")
						SR8->(DBSetOrder(1)) //R8_FILIAL+R8_MAT+DTOS(R8_DATAINI)+R8_TIPO
						("SR8")->(DBGOTOP())
						If SR8->(DBSEEK(cFilSR8 + cMatric + (cTabSR8)->DATAINI ))
							//Se enviou a data fim antes da data, por exemplo, quando são menos de 15 dias de afastamento, gravar o final do afastamento no R8_INTGTAF e não a DDATABASE
							If ( !Empty((cTabSR8)->DATAFIM ) ) .And. ((cTabSR8)->TPEFD  <> '15' .And. STOD((cTabSR8)->DATAFIM) - STOD((cTabSR8)->DATAINI) <= 15 )
								cDtIntTaf := (cTabSR8)->DATAFIM
							Else
								cDtIntTaf := cDtIncSis
							EndIf

							//Grava os ajustes na tabela SR8
							If RecLock("SR8", .F.)
								SR8->R8_INTGTAF	:= STOD(cDtIntTaf)
								("SR8")->(MsUnLock())
								aAdd( aLog[1], "Registro: Filial: " + (cTabSR8)->FILIAL + " -  Matrícula: " + (cTabSR8)->MAT  + "  -  Dt do Afast.: " + DTOC(STOD((cTabSR8)->DATAINI))  +  " data de integração ATUALIZADA com sucesso")
								(cTabSR8)->(dbSkip())
								Loop
							EndIf
						EndIf
					EndIf
				Else
					aAdd( aLog[2], "Filial: " + (cTabSR8)->FILIAL + " -  Matrícula: " + (cTabSR8)->MAT + "  -  NÃO foi encontrado o registro do trabalhador no TAF." )
					(cTabSR8)->(dbSkip())
					Loop
				EndIf
			EndDo
		Else
			MsgInfo("Não há registros para serem processados.")
		EndIf
	Else
		MsgInfo("Realize o backup e execute a rotina novamente.")
	EndIf

Return

/*/{Protheus.doc} fMntSR8
Função que monta a tabela com os afastamentos que devem ser ajustados
@author  lidio.oliveira
@since   20/10/2020
@version 1.0
/*/
Static Function fMntSR8()

	Local cQuery    := ""
	Local cAliasQ   := GetNextAlias()
	Local aColumns  := {}
	Local lRet      := .F.

	//Adiciona os campos na tabela temporária
	aAdd( aColumns, { "FILIAL"		,"C"    ,TamSx3("RA_FILIAL")[1]     ,0})
	aAdd( aColumns, { "MAT"		    ,"C"	,TamSx3("RA_MAT")[1]        ,0})
	aAdd( aColumns, { "NOME"		,"C"	,TamSx3("RA_NOME")[1]       ,0})
	aAdd( aColumns, { "SEQ"		    ,"C"	,TamSx3("R8_SEQ")[1]        ,0})
	aAdd( aColumns, { "TIPOAFA"		,"C"    ,TamSx3("R8_TIPOAFA")[1]    ,0})
	aAdd( aColumns, { "DESCTP"		,"C"	,TamSx3("R8_DESCTP")[1]     ,0})
	aAdd( aColumns, { "DATAINI"		,"C"	,TamSx3("R8_DATAINI")[1]    ,0})
	aAdd( aColumns, { "DATAFIM"		,"C"	,TamSx3("R8_DATAFIM")[1]    ,0})
	aAdd( aColumns, { "DURACAO"		,"N"    ,TamSx3("R8_DURACAO")[1]    ,0})
	aAdd( aColumns, { "TPEFD"		,"C"	,TamSx3("R8_TPEFD")[1]      ,0})
	aAdd( aColumns, { "TAFKI"		,"C"	,TamSx3("R8_TAFKI")[1]      ,0})
	aAdd( aColumns, { "TAFKF"		,"C"	,TamSx3("R8_TAFKF")[1]      ,0})
	aAdd( aColumns, { "CIC"		    ,"C" 	,TamSx3("RA_CIC")[1]        ,0})
	aAdd( aColumns, { "CODUNIC"     ,"C" 	,TamSx3("RA_CODUNIC")[1]    ,0})
	aAdd( aColumns, { "ATUDT "      ,"C" 	,1						    ,0})

	oTmpSR8 := FWTemporaryTable():New(cTabSR8)
	oTmpSR8:SetFields( aColumns )
	oTmpSR8:Create()

	cQuery := "SELECT SR8.R8_FILIAL, SR8.R8_MAT, SR8.R8_SEQ, SR8.R8_TIPOAFA, SR8.R8_DATAINI, SR8.R8_DATAFIM, SR8.R8_DURACAO, SR8.R8_TPEFD, SR8.R8_TAFKI, SR8.R8_TAFKF, SR8.R8_INTGTAF FROM" + RetSqlName('SR8') + " SR8 "
	cQuery += "WHERE ((SR8.R8_DATAINI >= '"+ DTOS(aPerg[1,5]) +"' AND SR8.R8_DATAINI <= '"+ DTOS(aPerg[1,6]) +"' AND SR8.R8_TAFKI = '') OR "
	cQuery += "(SR8.R8_DATAINI >= '"+ DTOS(aPerg[1,5]) +"' AND SR8.R8_DATAINI <= '"+ DTOS(aPerg[1,6]) +"' AND SR8.R8_TAFKF = '') OR "
	cQuery += "(SR8.R8_TAFKI <> ' ' AND SR8.R8_INTGTAF = ' ') OR "
	cQuery += "(SR8.R8_TAFKF <> ' ' AND SR8.R8_INTGTAF = ' ')) "
	cQuery += "AND SR8.R8_FILIAL >= '"+ aPerg[1,1] +"' AND SR8.R8_FILIAL <= '"+ aPerg[1,2] +"' "
	cQuery += "AND SR8.R8_MAT >= '"+ aPerg[1,3] +"' AND SR8.R8_MAT <= '"+ aPerg[1,4] +"' "
	cQuery += "AND SR8.R8_TPEFD <> '' "
	cQuery += "AND SR8.D_E_L_E_T_ = ''"
	cQuery += "ORDER BY SR8.R8_FILIAL, SR8.R8_MAT

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQ,.T.,.T.)

	While (cAliasQ)->(!Eof())
		If RecLock(cTabSR8, .T.)
			(cTabSR8)->FILIAL   := (cAliasQ)->R8_FILIAL
			(cTabSR8)->MAT      := (cAliasQ)->R8_MAT
			(cTabSR8)->NOME     := Posicione("SRA", 1, (cAliasQ)->R8_FILIAL + (cAliasQ)->R8_MAT,"RA_NOME")
			(cTabSR8)->SEQ      := (cAliasQ)->R8_SEQ
			(cTabSR8)->TIPOAFA  := (cAliasQ)->R8_TIPOAFA
			(cTabSR8)->DESCTP   := Posicione("RCM", 1, xFilial("RCM") + (cAliasQ)->R8_TIPOAFA, "RCM_DESCRI")
			(cTabSR8)->DATAINI  := (cAliasQ)->R8_DATAINI
			(cTabSR8)->DATAFIM  := (cAliasQ)->R8_DATAFIM
			(cTabSR8)->DURACAO  := (cAliasQ)->R8_DURACAO
			(cTabSR8)->TPEFD    := (cAliasQ)->R8_TPEFD
			(cTabSR8)->TAFKI    := (cAliasQ)->R8_TAFKI
			(cTabSR8)->TAFKF    := (cAliasQ)->R8_TAFKF
			(cTabSR8)->CIC      := Posicione("SRA", 1, (cAliasQ)->R8_FILIAL + (cAliasQ)->R8_MAT,"RA_CIC")
			(cTabSR8)->CODUNIC  := Posicione("SRA", 1, (cAliasQ)->R8_FILIAL + (cAliasQ)->R8_MAT,"RA_CODUNIC")
			(cTabSR8)->ATUDT	:= If( Empty((cAliasQ)->R8_INTGTAF) .And. !Empty((cAliasQ)->R8_TAFKI) .Or. !Empty((cAliasQ)->R8_TAFKF), "S", "N" )
			(MsUnLock())
		EndIf
		If !lRet
			lRet := .T.
		EndIf
		(cAliasQ)->(DbSkip())
	EndDo

	(cAliasQ)->( dbCloseArea() )

Return lRet

/*/{Protheus.doc} fGetID
Pesquisa qual é o Id do funcionário na tabela C9V
@author  lidio.oliveira
@since   20/10/2020
@version 1.0
/*/
Static Function fGetID(cFilEnv, cCPF, cCodUnic)

	Local aArea 	:= GetArea()
	Local cIdFunc   := ""

	Default cFilEnv     := ""
	Default cCodUnic    := ""
	Default cCPF        := ""

	If !Empty(cCodUnic) .And. !Empty(cCodUnic) .And. !Empty(cCPF)
		//Encontra o Id do funcionário na tabela C9V
		DBSelectArea("C9V")
		C9V->(DBSetOrder(10)) //C9V_FILIAL + C9V_CPF + C9V_MATRIC + C9V_NOMEVE + C9V_ATIVO
		If C9V->(DBSEEK(cFilEnv + cCPF + cCodUnic + "S2200" + "1"))
			cIdFunc := C9V->C9V_ID
		EndIf
	EndIf

	RestArea( aArea )

Return cIdFunc

/*/{Protheus.doc} fGetRecno
Retorna qual é o recno do afastamento na tabela CM6
@author  lidio.oliveira
@since   20/10/2020
@version 1.0
/*/
Static Function fGetRecno(cFilEnv, cIdFunc, cDtIni, cDtFim, cTipo, cDtSis)

	Local aArea 	:= GetArea()
	Local cRecno    := ""
	Local cQuery    := ""
	Local cAlias    := GetNextAlias()

	Default cFilEnv := ""
	Default cIdFunc := ""
	Default cDtIni  := ""
	Default cDtFim  := ""
	Default cTipo   := ""
	Default cDtSis  := ""

	If !Empty(cFilEnv) .And. !Empty(cIdFunc)

		//Executa query na CM6 para retornar o R_E_C_N_O_
		cQuery  := "SELECT CM6.R_E_C_N_O_, CM6.CM6_DINSIS FROM " + RetSqlName('CM6') + " CM6 "
		cQuery  += " WHERE "
		cQuery  += " CM6.CM6_FILIAL =  '"+ cFilEnv +"'"
		cQuery  += " AND CM6.CM6_FUNC = '"+ cIdFunc +"'"
		If cTipo == "COMP"
			cQuery += " AND CM6.CM6_DTAFAS = '"+ cDtIni +"'"
			cQuery += " AND CM6.CM6_DTFAFA = '"+ cDtFim +"'"
		ElseIf cTipo == "INIC"
			cQuery += " AND CM6.CM6_DTAFAS = '"+ cDtIni +"'"
		Else
			cQuery += " AND CM6.CM6_DTFAFA = '"+ cDtFim +"'"
		EndIf
		cQuery  += " AND CM6.CM6_ATIVO = '1'"
		cQuery  += " AND CM6.D_E_L_E_T_ <> '*'"

		cQuery := ChangeQuery(cQuery)
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)

		(cAlias)->(DBGOTOP())
		cRecno := (cAlias)->R_E_C_N_O_
		cDtSis := (cAlias)->CM6_DINSIS

		(cAlias)->( dbCloseArea() )
	EndIf

	RestArea( aArea )

Return cRecno

/*/{Protheus.doc} fGetKey
Retorna qual o TAFKEY para atualização na tabela SR8
@author  lidio.oliveira
@since   20/10/2020
@version 1.0
/*/
Static Function fGetKey(cRecno, cData, cFilEnv)

	Local aArea 	:= GetArea()
	Local cTafKey   := ""
	Local cQryXERP  := ""
	Local cAlias    := GetNextAlias()
	Local cQryST2   := ""
	Local cTafFil   := ""

	Default cRecno  := ""
	Default cData   := ""
	Default cFilEnv := ""

	cTafFil := cEmpAnt + cFilEnv

	//Query para retornar o TAFTICKET na TAFST2
	cQryXERP := "SELECT TAFTICKET FROM TAFXERP "
	cQryXERP += "WHERE "
	cQryXERP += "TAFALIAS = 'CM6' "
	cQryXERP += "AND TAFDATA = '"+ cData +"' "
	cQryXERP += "AND TAFRECNO = '"+ cRecno +"' AND D_E_L_E_T_ <> '*' "

	//Executa query para retornar o TAFKEY na TAFST2
	cQryST2 := "SELECT TAFKEY FROM TAFST2 "
	cQryST2 += "WHERE TAFFIL = '"+ cTafFil +"' "
	cQryST2 += "AND TAFTICKET IN (" + cQryXERP + ") "
	cQryST2 += "AND D_E_L_E_T_ <> '*' "

	cQryST2 := ChangeQuery(cQryST2)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryST2),cAlias,.T.,.T.)

	(cAlias)->(DBGOTOP())
	cTafKey := (cAlias)->TAFKEY

	(cAlias)->( dbCloseArea() )

	RestArea( aArea )

Return cTafKey

/*/{Protheus.doc} fParam
Cria tela com perguntes para possibilitar a execução de filtros
@author  lidio.oliveira
@since   21/10/2020
@version 1.0
/*/
Static Function fParam(aParam)

	Local aAdvSize      := {}
	Local aInfoAdvSize  := {}
	Local aObjCoords    := {}
	Local aObjSize      := {}
	Local cFilDe        := Space(TamSX3("RA_FILIAL")[1])
	Local cFilAte       := cFilDe
	Local cMatDe        := Space(TamSX3("RA_MAT")[1])
	Local cMatAte       := cMatDe
	Local dDataDe       := CToD("  /  /  ")
	Local dDataAte      := CToD("  /  /  ")
	Local bSet15		:= { || nOpcA := 1, oDlg:End() }
	Local bSet24		:= { || nOpca := 2, oDlg:End() }
	Local lOk           := .T.
	Local nOpcA			:= 0
	Local oFil
	Local oMat
	Local oData

	Default aParam      := {}

	aAdvSize		:= MsAdvSize()
	aAdvSize[6]	:=	310	//Vertical
	aAdvSize[5]	:=  420	//horizontal
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
	aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )
	aAdd( aObjCoords , { 000 , 010 , .T. , .F. } )

	aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )

	DEFINE FONT oFont  NAME "Arial" SIZE 0,-11 BOLD
	DEFINE MSDIALOG oDlg FROM aAdvSize[7], 0 TO aAdvSize[6], aAdvSize[5] TITLE OemToAnsi("Parâmetros") OF oMainWnd PIXEL

	@ aObjSize[1][1],aObjSize[1][2] 	SAY "Filial de"	 SIZE 050,10  FONT oFont OF oDlg PIXEL
	@ aObjSize[1][1],aObjSize[1][2]+80	MSGET oFil VAR cFilDe   SIZE 100,10 OF oDlg F3 "XM0" WHEN .T. PIXEL

	@ aObjSize[2][1],aObjSize[2][2] 	SAY "Filial ate" SIZE 050,10  FONT oFont OF oDlg PIXEL
	@ aObjSize[2][1],aObjSize[2][2]+80	MSGET oFil VAR cFilAte  SIZE 100,10 OF oDlg F3 "XM0" PIXEL

	@ aObjSize[3][1],aObjSize[3][2] 	SAY "Matricula de" SIZE 050,10  FONT oFont OF oDlg PIXEL
	@ aObjSize[3][1],aObjSize[3][2]+80	MSGET oMat VAR cMatDe  SIZE 100,10 OF oDlg F3 "SRA" PIXEL

	@ aObjSize[4][1],aObjSize[4][2] 	SAY "Matricula Ate" SIZE 050,10  FONT oFont OF oDlg PIXEL
	@ aObjSize[4][1],aObjSize[4][2]+80	MSGET oMat VAR cMatAte  SIZE 100,10 OF oDlg F3 "SRA" PIXEL

	@ aObjSize[5][1],aObjSize[5][2] 	SAY "Data de"  SIZE 050,10 FONT oFont OF oDlg PIXEL
	@ aObjSize[5][1],aObjSize[5][2]+80	MSGET oData VAR dDataDe  SIZE 100,10 OF oDlg WHEN .T.  PIXEL

	@ aObjSize[6][1],aObjSize[6][2] 	SAY "Data ate" SIZE 050,10 FONT oFont OF oDlg PIXEL
	@ aObjSize[6][1],aObjSize[6][2]+80	MSGET oData VAR dDataAte SIZE 100,10 OF oDlg WHEN .T. PIXEL

	ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bSet15, bSet24) CENTERED

	If nOpcA == 2
		Return
	Else
		// Tratamento dos parâmetros preenchidos
		If Empty(cFilAte) .And. lOk
			Aviso( OemtoAnsi("Filial Ate em branco") , "O campo 'Filial Ate' está branco, faça o preenchimento para correta execução da rotina",	{ "Ok" } )
			lOk := .F.
		EndIf

		// Tratamento dos parâmetros preenchidos
		If Empty(cMatAte) .And. lOk
			Aviso( OemtoAnsi("Matrícula Ate em branco") , "O campo 'Matrícula Ate' está branco, faça o preenchimento para correta execução da rotina",	{ "Ok" } )
			lOk := .F.
		EndIf

		// Tratamento dos parâmetros preenchidos
		If Empty(dDataAte) .And. lOk
			Aviso( OemtoAnsi("Data Ate em branco") , "O campo 'Data Ate' está branco, faça o preenchimento para correta execução da rotina",	{ "Ok" } )
			lOk := .F.
		EndIf

		If lOk
			aAdd(aParam,{cFilDe, cFilAte, cMatDe, cMatAte, dDataDe, dDataAte})
		EndIf
	EndIf

Return

/*/{Protheus.doc} GpConfOk
@author  lidio.oliveira
@since   21/10/2020
@version 1.0
/*/
Static Function GpConfOk( cMensagem , cTitulo )

	If Len(aPerg) >  0
		cMensagem	:= IF( cMensagem == NIL .OR. ValType( cMensagem ) != "C" , "Confirma configuração dos parâmetros?" , cMensagem )//"Confirma configuração dos parâmetros?"
		cTitulo		:= IF( cTitulo	 == NIL .OR. ValType( cTitulo )   != "C" , "Atenção" , cTitulo   )//"Atenção"
	Else
		Aviso( OemtoAnsi("Parâmetros em branco") , "Preencha os parâmetros para executar esta rotina",	{ "Ok" } )
		Return .F.
	EndIf

Return( MsgYesNo( OemToAnsi( cMensagem ) , OemToAnsi( cTitulo ) ) ) //"Atenção"
