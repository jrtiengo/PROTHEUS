#Include "Topconn.ch"
#include "Totvs.ch"
#Include "protheus.ch"
#Include "rwmake.ch"
#INCLUDE "TBICONN.CH"

//--------------------------------------------------------------------------
//Gerenciamento do pre-titulos Evora
//--------------------------------------------------------------------------
User Function PS001FIN()
	Local cVldAlt:= "IIF(INCLUI, .T., IIF(Empty(SZ3->Z3_PREFIXO), .T., (MsgInfo('Já foi gerado financeiro para este item, utilize o estorno para poder alterar.'),.F.)))"
	Local cVldExc:= "IIF(Empty(SZ3->Z3_PREFIXO), .T., (MsgInfo('Já foi gerado financeiro para este item, utilize o estorno para poder excluir. '),.F.))"
	Local aRotina:= {}
	If ! SuperGetMV('ES_PPFRE',.F.,.F.)
		MsgAlert('Empresa não foi configurada para o Paper Free', 'Atenção')
		RETURN
	end


	Private cString:= "SZ3"

	dbSelectArea(cString)
	dbSetOrder(1)

	AADD(aRotina, {'Gerar Titulos', 'Processa({|| U_GERATIT()})', 0, 4, 0, NIL})
	AADD(aRotina, {'Estornar', 'Processa({|| U_ESTORNA() })', 0, 4, 0, NIL})
	AADD(aRotina, {'Imprimir Boletim', 'U_PS601FIN()', 0, 4, 0, NIL})
	AADD(aRotina, {'Conhecimento Titulo', 'Processa({|| U_fmybco1() })', 0, 4, 0, NIL})

	AxCadastro(cString, "Cadastro Pré-Titulos", cVldExc, cVldAlt, aRotina)

Return

//--------------------------------------------------------------------------
//Estorna o financeiro
//--------------------------------------------------------------------------

user Function Estorna()
	Local aArea:= GetArea()
	Local cAli:= GetNextAlias()
	Local cQuery:= ""
	Local aDados:= {}
	Local nCount:= {}
	Local nX:= 0

	Local oDlg:= Nil
	Local oBrw:= Nil
	Local nOpc:= 0

	Local aCab:= {}

	cQuery:= " SELECT SZ3.R_E_C_N_O_ RECNOZ3 "
	cQuery+= " FROM  "+RetSqlTab("SZ3")
	cQuery+= " WHERE "+RetSqlFil("SZ3")+" AND "
	cQuery+= "       Z3_PREFIXO = '"+SZ3->Z3_PREFIXO+"' AND "
	cQuery+= "       Z3_NUM = '"+SZ3->Z3_NUM+"' AND "
	cQuery+= "       Z3_PARCELA = '"+SZ3->Z3_PARCELA+"' AND "
	cQuery+= "       Z3_TIPO = '"+SZ3->Z3_TIPO+"' AND "
	cQuery+= "       Z3_FORNECE = '"+SZ3->Z3_FORNECE+"' AND "
	cQuery+= "       Z3_LOJA = '"+SZ3->Z3_LOJA+"' AND "
	cQuery+= "       Z3_PREFIXO <> '' AND "
	cQuery+= "       Z3_NUM <> '' AND "
	cQuery+= "       Z3_PARCELA <> '' AND "
	cQuery+= "       Z3_TIPO <> '' AND "
	cQuery+= "       Z3_FORNECE <> '' AND "
	cQuery+= "       Z3_LOJA <> '' AND "
	cQuery+= "       "+RetSqlDel("SZ3")

	TCQuery ChangeQuery(cQuery) New Alias &(cAli)
	Count To nCount
	&(cAli)->(dbGoTop())

	ProcRegua(nCount)
	Do While !&(cAli)->(EOF())
		IncProc("Buscando registros...")
		SZ3->(dbGoTo(&(cAli)->(RECNOZ3)))
		If !SZ3->(EOF())
			AADD(aDados, {SZ3->Z3_FORNECE, SZ3->Z3_LOJA, SZ3->Z3_NOME, SZ3->Z3_VALOR, SZ3->Z3_NATUREZ, SZ3->Z3_CC, SZ3->(RECNO()),SZ3->Z3_VENCREA})
		EndIf
		&(cAli)->(dbSkip())
	EndDo
	&(cAli)->(dbCloseArea())

	If Len(aDados) > 0
		oDlg:= MSDIALOG():New(000, 000, 450, 850, "Gerar Pre-Titulos - Multi Naturezas",,,,,,,,,.T.)
		//oDlg:lMaximized:= .T.
		oBrw:= TCBrowse():New(20, 01, 285, 115, , {'Fornecedor', 'Loja', 'Nome', 'Valor', 'Natureza', 'CC','Vencimento'}, {50, 20, 150, 50, 50, 50}, oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,,)
		oBrw:Align:= CONTROL_ALIGN_ALLCLIENT
		oBrw:SetArray(aDados)
		oBrw:bLine:= {|| {aDados[oBrw:nAt, 01],;
			aDados[oBrw:nAt, 02],;
			aDados[oBrw:nAt, 03],;
			Transform(aDados[oBrw:nAt, 04], "@e 999,999,999.99"),;
			aDados[oBrw:nAt, 05],;
			aDados[oBrw:nAt, 06],;
			aDados[oBrw:nAt, 08]}}

		ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, {|| nOpc:= 1, oDlg:End()},{|| nOpc:= 0, oDlg:End()},,)) CENTERED

		If nOpc != 0
			SE2->(dbSetOrder(1))
			If SE2->(dbSeek(xFilial("SE2")+SZ3->Z3_PREFIXO+SZ3->Z3_NUM+SZ3->Z3_PARCELA+SZ3->Z3_TIPO))

				aCab:= {}
				AADD(aCab, {"E2_FILIAL" , xFilial("SE2")          , Nil})
				AADD(aCab, {"E2_PREFIXO", SZ3->Z3_PREFIXO         , Nil})
				AADD(aCab, {"E2_NUM"    , SZ3->Z3_NUM             , Nil})
				AADD(aCab, {"E2_PARCELA", SZ3->Z3_PARCELA         , Nil})
				AADD(aCab, {"E2_TIPO"   , SZ3->Z3_TIPO            , Nil})
				AADD(aCab, {"E2_FORNECE", SZ3->Z3_FORNECE         , Nil})
				AADD(aCab, {"E2_LOJA"   , SZ3->Z3_LOJA            , Nil})

				lMsErroAuto:= .F.
				Begin Transaction
					MsExecAuto({|x, y, z| FINA050(x, y, z)}, aCab, , 5)
					If lMsErroAuto
						DisarmTransaction()
						MostraErro()
					Else
						For nX:= 1 To Len(aDados)
							SZ3->(dbGoTo(aDados[nX,7]))
							If !SZ3->(EOF())
								RecLock("SZ3", .F.)
								SZ3->Z3_PREFIXO:= ""
								SZ3->Z3_NUM:= ""
								SZ3->Z3_PARCELA:= ""
								SZ3->Z3_TIPO:= ""
								SZ3->(MsUnLock())
							EndIf
						Next nX
					EndIf
				End Transaction
			Else
				MsgInfo("Título não encontrado.", "PS001FIN")
			EndIf
		Else
			MsgInfo("Cancelado pelo usuário.", "PS001FIN")
		EndIf
	Else
		MsgInfo("A pesquisa não retornou registros.", "PS001FIN")
	EndIf

	RestArea(aArea)
Return

/*------------------------------------------------------------------------------------------------------------------
Gera os titulos pendentes no financeiro
---------------------------------------------------------------------------------------------------------------------
*/
user function GeraTit()
	Local aArea:= GetArea()
	Local cAli:= GetNextAlias()
	Local cQuery:= ""
	Local aDados:= {}
	Local nCount:= {}

	Local oDlg:= Nil
	Local oBrw:= Nil
	Local aBut:= {}
	Local oOk:= LoadBitmap(GetResources(), "LBTIK")
	Local oNo:= LoadBitmap(GetResources(), "LBNO")
	Local nOpc:= 0
	Local nX:= 0
	Local nY:= 0
	//Local nZ:= 0

	Local aForn:= {}
	//Local aNat:= {}
	//Local aCC:= {}
	Local aRecno:= {}
	Local nPos:= 0, nD

	Local cPrefixo:= SuperGetMv("ES_PREFIX", .F., "FIX")
	Local cNum:= ""
	Local cParcela:= ""
	Local cTipo:= SuperGetMv("ES_TPPRET", .F., "DP ")
	Local aCab:= {}     //Array que recebera o titulo a receber
	Local aAuxEv:={}    //Array auxiliar do rateio multinaturezas
	Local aRatEvEz:={}  //Array do rateio multinaturezas
	Local aAuxEz:={}    //Array auxiliar de multiplos centros de custo
	Local aRatEz:={}    //Array do rateio de centro de custo em multiplas naturezas
	lOCAL oFontG    := TFont():New("Tahoma"  ,,15)

	cQuery:= " SELECT SZ3.R_E_C_N_O_ RECNOZ3 "
	cQuery+= " FROM  "+RetSqlTab("SZ3")
	cQuery+= " WHERE "+RetSqlFil("SZ3")+" AND "
	cQuery+= "       Z3_PREFIXO = '' AND "
	cQuery+= "       Z3_NUM = '' AND "
	cQuery+= "       "+RetSqlDel("SZ3")

	TCQuery ChangeQuery(cQuery) New Alias &(cAli)
	Count To nCount
	&(cAli)->(dbGoTop())

	ProcRegua(nCount)
	Do While !&(cAli)->(EOF())
		IncProc("Buscando registros...")
		SZ3->(dbGoTo(&(cAli)->(RECNOZ3)))
		If !SZ3->(EOF())
			AADD(aDados, {.T., SZ3->Z3_FORNECE, SZ3->Z3_LOJA, SZ3->Z3_NOME, SZ3->Z3_VALOR, SZ3->Z3_NATUREZ, SZ3->Z3_CC, SZ3->(RECNO()),sz3->Z3_VENCREA})
		EndIf
		&(cAli)->(dbSkip())
	EndDo
	&(cAli)->(dbCloseArea())

	If Len(aDados) = 0
		MsgInfo("Não foi encontrado nenhum Pré-Título pendente.", "PS001FIN")
		RETURN
	END
	nTotMarc:=900

	//DEFINE DIALOG oDlg TITLE "Exemplo TCBrowse" FROM 00,00 TO 550,700 PIXEL
	oDlg:= MSDIALOG():New(000, 000, 450, 1275, "Gerar Pre-Titulos - Multi Naturezas",,,,,,,,,.T.)
	oLbReg  := TSay():New(001,001,{||"Total R$"+Str(nTotMarc,11,2)}  				,oDlg,,oFontG) //,.F.,.F.,.F.,.T.,CLR_BLACK )//BLACK,CLR_WHITE) //,250,100)

	//oDlg:lMaximized:= .T.
	AADD(aBut, {"S4WB011N", {|| aEval(aDados, {|x| x[1]:= .T.})}  , "Marcar todos", "Marcar todos"})
	AADD(aBut, {"S4WB011N", {|| aEval(aDados, {|x| x[1]:= !x[1]})}, "Inverter marca", "Inverter marca"})
	AADD(aBut, {"S4WB011N", {|| ftotais(aDados)}                 , "Totais", "Totais"})

	oBrw:= TCBrowse():New(450, 400, 285, 115, , {'', 'Fornecedor', 'Loja', 'Nome', 'Valor', 'Natureza', 'CC','Vencimento'}, {10, 50, 20, 150, 50, 50, 50}, oDlg ) //, , , , ,{||}, , , , , , ,.F., ,.T.,,.F.,,,)
	oBrw:Align:= CONTROL_ALIGN_ALLCLIENT
	oBrw:SetArray(aDados)
	oBrw:bLine:= {|| {IIF(aDados[oBrw:nAt, 01], oOk, oNo),;
		aDados[oBrw:nAt, 02],;
		aDados[oBrw:nAt, 03],;
		aDados[oBrw:nAt, 04],;
		Transform(aDados[oBrw:nAt, 05], "@e 999,999,999.99"),;
		aDados[oBrw:nAt, 06],;
		aDados[oBrw:nAt, 07],;
		aDados[oBrw:nAt, 09]}}
	//dblclick
	oBrw:bLDblClick:= {|| aDados[oBrw:nAt, 01]:= !aDados[oBrw:nAt, 01]}

	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, {|| nOpc:= 1, oDlg:End()},{|| nOpc:= 0, oDlg:End()},, aBut)) CENTERED

	If nOpc = 0
		MsgInfo("Cancelado pelo usuário.", "PS001FIN")
		RETURN
	END

	ProcRegua(Len(aDados))

	For nX:= 1 To Len(aDados)
		IncProc("Selecionando fonecedores...")
		If ! aDados[nX, 1]
			loop
		end

		nPos:= ASCAN(aForn, {|x| aDados[nX, 2] + aDados[nX, 3] + DTOS(aDados[nX, 9])== x[1]+x[2]+DTOS(X[4])})
		If nPos == 0
			AADD(aForn, {aDados[nX, 2], aDados[nX, 3], aDados[nX, 5],aDados[nX, 9]}) //FOR+LOJA+VALOR+VENC
		Else
			aForn[nPos, 3]+= aDados[nX, 5]
		EndIf

	Next nX

	//u_showarray(aForn, "Fornecedores x Vencimentos selecionados")

	ProcRegua(Len(aForn))

	For nX:= 1 To Len(aForn)

		alert('proc vlr '+CValToChar(aForn[nX, 3] )+' forn '+aForn[nX, 1] )

		IncProc("Processando...")

		//cPrefixo:= SuperGetMv("ES_PREFIX", .F., "FIX") //Tiengo 02/05/23 - Removida a chamada do GetMV, pois não é permitida em Loop.
		cNum:= GetNum()
		cParcela:= "A"
		//cTipo:= SuperGetMv("ES_TPPRET", .F., "DP ") //Tiengo 02/05/23 - Removida a chamada do GetMV, pois não é permitida em Loop.
		dVcto:=IF(aForn[nX, 4] < dDataBase , dDataBase, aForn[nX, 4]) 

		aCab:= {}
		AADD(aCab, {"E2_FILIAL" , xFilial("SE2")   , Nil})
		AADD(aCab, {"E2_PREFIXO", cPrefixo         , Nil})
		AADD(aCab, {"E2_NUM"    , cNum             , Nil})
		AADD(aCab, {"E2_PARCELA", cParcela         , Nil})
		AADD(aCab, {"E2_TIPO"   , cTipo            , Nil})
		AADD(aCab, {"E2_FORNECE", aForn[nX, 1]     , Nil})
		AADD(aCab, {"E2_LOJA"   , aForn[nX, 2]     , Nil})
		AADD(aCab, {"E2_EMISSAO", dDataBase        , Nil})
		AADD(aCab, {"E2_VENCTO" , dVcto            , Nil})
		AADD(aCab, {"E2_VALOR"  , aForn[nX, 3]     , Nil})
		AADD(aCab, {"E2_MULTNAT", "1"              , Nil})

		//rateio das naturezas ----------------------------//
		//em 25/01 cliente pediu para não existir mais a soma de naturezas x cc e portanto gravar o rateio aberto
		aRatEvEz:={}
		aRecno:= {}

		For nD:=1 to Len(aDados)
			//AADD(aDados, {.T., SZ3->Z3_FORNECE, SZ3->Z3_LOJA, SZ3->Z3_NOME, SZ3->Z3_VALOR, SZ3->Z3_NATUREZ, SZ3->Z3_CC, SZ3->(RECNO()),sz3->Z3_VENCREA})

			If ! (aDados[nD,2]+aDados[nD,3]+DTOS(aDados[nD,9])==aForn[nX, 1]+aForn[nX, 2]+dtos(aForn[nX, 4]))
				loop
			end
			nRateio:=Round((aDados[nD, 5] / aForn[nX,3])*100 ,2)

			alert('SEV valor '+CValToChar(aDados[nD, 5] )+' forn '+aForn[nX, 1] +'percent '+CValToChar(nRateio  )+' NAT '+ PADR(aDados[nD, 6], TamSX3("EV_NATUREZ")[1]) +chr(13)+chr(10)+;
			      'SEZ valor '+CValToChar(aDados[nD, 5] )+' forn '+aForn[nX, 1] +'percent '+CValToChar(100 )+' CC '+aDados[nD, 7]  +chr(13)+chr(10)+;
				  'SE2_VALOR '+CValToChar(aForn[nX,3]))

			//Adicionando o vetor da natureza
			aAuxEV:= {}
			AADD(aAuxEv ,{"EV_NATUREZ", PADR(aDados[nD, 6], TamSX3("EV_NATUREZ")[1])  , Nil})     //natureza a ser rateada
			AADD(aAuxEv ,{"EV_VALOR"  , aDados[nD, 5]                                 , Nil})     //valor do rateio na natureza
			AADD(aAuxEv ,{"EV_PERC"   , nRateio								          , Nil})     //percentual do rateio na natureza
			AADD(aAuxEv ,{"EV_RATEICC", "1"                                           , Nil})     //indicando que há rateio por centro de custo

			//adiciono multiplos CCs

			//alert('SEZ valor '+CValToChar(aDados[nD, 5] )+' forn '+aForn[nX, 1] +'percent '+CValToChar(100 )+' CC '+aDados[nD, 7] )

			aRatEz:= {}

			aAuxEz:={}
			AADD(aAuxEz ,{"EZ_CCUSTO", PADR(aDados[nD, 7], TamSX3("EZ_CCUSTO")[1]), Nil})    //centro de custo da natureza
			AADD(aAuxEz ,{"EZ_VALOR" , aDados[nD, 5] , Nil})    //valor do rateio neste centro de custo
			AADD(aAuxEz ,{"EZ_PERC"  , 100 , Nil})    //valor do rateio neste centro de custo
			AADD(aRatEz, aAuxEz)

			AADD(aAuxEv, {"AUTRATEICC", aRatEz, Nil})   //recebendo dentro do array da natureza os multiplos centros de custo

			AADD(aRatEvEz, aAuxEv)  //adicionando a natureza ao rateio de multiplas naturezas
			AADD(aRecno, aDados[nD, 8 ]) //RECNCO
		Next

		AADD(aCab, {"AUTRATEEV", ARatEvEz, Nil})    //adicionando ao vetor aCab o vetor do rateio



		/*

		aNat:= {}
		aRecno:= {}

		For nY:= 1 To Len(aDados)
			If !aDados[nY, 1]
				LOOP
			END

			If aForn[nX, 1]+aForn[nX, 2] + dtos(aforn [nX,4]) <> aDados[nY, 2]+aDados[nY, 3]+dtos(aDados[nY, 9]) //FOR+LOJA+VECN
				loop
			end

			AADD(aRecno, aDados[nY, 8 ]) //RECNCO

			nPos:= ASCAN(aNat, {|x| aForn[nX, 1]+aForn[nX, 2]+aDados[nY, 6] +dtos(aForn[nx,4] )== x[1]+x[2]+x[4]+dtos(x[7])}) //FOR+LOJA+VECNTO

			If nPos == 0
				//          fornece       loja          tot titulo    natureza       valor nat      percentual   VECNTO
				AADD(aNat, {aForn[nX, 1], aForn[nX, 2], aForn[nX, 3], aDados[nY, 6], aDados[nY, 5], 0          , aDados[nY, 9]})
			Else
				aNat[nPos, 5]+= aDados[nY, 5]
			EndIf


		Next nY

		//calculo o percentual da natureza ---------------------------------//
		For nY:= 1 To Len(aNat)
			aNat[nY, 6]:= (aNat[nY, 5]/aNat[nY, 3])*100
		Next nY

		//u_showarray(aNat, "Natureza por fornecedor -> "+aForn[nX,2]+'  vcto '+dtoc(aForn[nX,4]))

		//rateio dos CCs --------------------------------------/
		aRatEvEz:= {}

		For nZ:= 1 To Len(aNat)
			//Adicionando o vetor da natureza
			aAuxEV:= {}
			AADD(aAuxEv ,{"EV_NATUREZ", PADR(aNat[nZ, 4], TamSX3("EV_NATUREZ")[1])  , Nil})     //natureza a ser rateada
			AADD(aAuxEv ,{"EV_VALOR"  , aNat[nZ, 5]                                 , Nil})     //valor do rateio na natureza
			AADD(aAuxEv ,{"EV_PERC"   , aNat[nZ, 6]                                 , Nil})     //percentual do rateio na natureza
			AADD(aAuxEv ,{"EV_RATEICC", "1"                                         , Nil})     //indicando que há rateio por centro de custo

			aCC:= {}
			For nY:= 1 To Len(aDados)
				If !aDados[nY, 1]
					loop
				END

				If aNat[nZ, 1]+aNat[nZ, 2]+aNat[nZ, 4] + dtos(aNat[nZ,7]) <>  aDados[nY, 2]+aDados[nY, 3]+aDados[nY, 6]+dtos(aDados[nY, 9])
					loop
				end

				nPos:= ASCAN(aCC, {|x| aForn[nX, 1]+aForn[nX, 2]+aDados[nY, 6]+aDados[nY, 7] + dtos(aForn[nx,4]) == x[1]+x[2]+x[4]+x[5]+dtos(x[8])})

				If nPos == 0
					//          fornece       loja          tot titulo   natureza     CC             valor CC       percentual
					AADD(aCC, {aForn[nX, 1], aForn[nX, 2], aForn[nX, 3], aNat[nZ, 4], aDados[nY, 7], aDados[nY, 5], 0, aForn[nx,4]})
				Else
					aCC[nPos, 6]+= aDados[nY, 5]
				EndIf


			Next nY
			//u_showarray(aCC, "C.C. -> "+aforn[nX,2]+'  vcto '+dtoc(aForn[nX,4]) )

			//adiciono multiplos CCs
			aRatEz:= {}
			For nY:= 1 To Len(aCC)
				aAuxEz:={}
				AADD(aAuxEz ,{"EZ_CCUSTO", aCC[nY, 5], Nil})    //centro de custo da natureza
				AADD(aAuxEz ,{"EZ_VALOR" , aCC[nY, 6], Nil})    //valor do rateio neste centro de custo
				AADD(aRatEz, aAuxEz)
			Next nY
			AADD(aAuxEv, {"AUTRATEICC", aRatEz, Nil})   //recebendo dentro do array da natureza os multiplos centros de custo

			AADD(aRatEvEz, aAuxEv)  //adicionando a natureza ao rateio de multiplas naturezas
		Next nZ

		AADD(aCab, {"AUTRATEEV", ARatEvEz, Nil})    //adicionando ao vetor aCab o vetor do rateio
		*/

		lMsErroAuto:= .F.

		Begin Transaction

			MsExecAuto({|x, y, z| FINA050(x, y, z)}, aCab, , 3)
			If lMsErroAuto
				DisarmTransaction()
				MostraErro()
			Else
				For nY:= 1 To Len(aRecno)
					SZ3->(dbGoTo(aRecno[nY]))
					If !SZ3->(EOF())
						RecLock("SZ3", .F.)
						SZ3->Z3_PREFIXO:= cPrefixo
						SZ3->Z3_NUM:= cNum
						SZ3->Z3_PARCELA:= cParcela
						SZ3->Z3_TIPO:= cTipo
						SZ3->(MsUnLock())
					EndIf
				Next nY
				IF MSGBOX("Titulo "+cNum+" gerado."+chr(13)+chr(10)+;
						"Deseja incluir os comprovantes no titulo ?","Comprovantes","YESNO")

					u_fmybco1()
				End

			Endif
		End Transaction

	Next nX




	RestArea(aArea)
Return

//--------------------------------------------------------------------------
Static Function fTotais(aDados)
//--------------------------------------------------------------------------
	Local nMarcados:=0
	Local nNaoMarcad:=0
	Local nK

	For nK:=1 to Len(aDados)
		If aDados[nK,1]
			nMarcados+=aDados[nK,5]
		else
			nNaoMarcad+=aDados[nK,5]
		End
	Next

	MsgInfo('Totais Marcados.....:'+Str(nMarcados,11,2)+chr(13)+chr(10)+;
		'Totais Não Marcados.:'+Str(nNaoMarcad,11,2))

Return

//--------------------------------------------------------------------------
//Proximo numero sequencia da SZ3
//--------------------------------------------------------------------------

Static Function GetNum()
	Local cRet:= ""
	Local aArea:= GetArea()
	Local cQuery:= ""
	Local cAli:= GetNextAlias()

	cQuery:= " SELECT COALESCE(MAX(Z3_NUM), '000000000') SEQ "
	cQuery+= " FROM  "+RetSqlTab("SZ3")
	cQuery+= " WHERE "+ReTSqlFil("SZ3")+" AND "
	cQuery+= "       Z3_NUM <> '' AND "
	cQuery+= "       "+RetSqlDel("SZ3")
	TCQuery ChangeQuery(cQuery) New Alias &(cAli)
	cRet:= &(cAli)->(SEQ)
	&(cAli)->(dbCloseArea())

	RestArea(aArea)
Return Soma1(cRet)


//--------------------------------------------------------------------------
// fmybanco | mostra o banco de conhecimento do titulo gerado
// Autor    | Manoel, dez/2020
//------------------------------------------------------------------------------

user Function fmybco1()
	Local aArea:=GetArea()
	Local nOper:=3 //2=altera, 1=vis 3=
	IF empty(SZ3->Z3_NUM)
		MsgInfo('Titulo nao foi gerado',"Atencao")
		Return
	End

	dbSelectArea('SE2')
	dbSetOrder(1)
	IF !dbSeek(SZ3->(Z3_FILIAL+Z3_PREFIXO+Z3_NUM+Z3_PARCELA+Z3_TIPO))
		MsgInfo('Titulo nao foi encontrado',"Atencao")
		Return
	End
	nRecno:=SE2->(RECNO())

	RestArea(aArea)

	MsDocument('SE2',nRecno,nOper)

Return
