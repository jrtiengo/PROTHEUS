#include "protheus.ch"
#include "topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FB102MDT  ºAutor  ³Ezequiel Pianegonda º Data ³  12/07/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Equipe X EPC                                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FB102MDT()
	Local cAli:= "ZZ4"

	Private cCadastro:= "Equipe x EPC"
	Private aRotina:= {}

	AADD(aRotina,{"Pesquisar"   , "AxPesqui", 0, 1})
	AADD(aRotina,{"Equipe x EPC", "u_EqXEpc", 0, 4})
	AADD(aRotina,{"Rel. Equipe x EPC", "u_FB603MDT", 0, 4})

	dbSelectArea(cAli)
	dbSetOrder(1)
	mBrowse(6, 1, 22, 75, cAli)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³EqXEpc    ºAutor  ³Ezequiel Pianegonda º Data ³  12/07/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Tela de manutencao de equipe x epc, modelo2                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function EqXEpc()
	Local cTitulo	:= "Incluir Equipe x Epc"
	Local aCab		:= {}
	Local aRoda		:= {}
	Local aGrid		:= {80,005,050,300}
	Local aColsAux	:= {}
	Local aRecno	:= {}
	Local aDesc		:= {}
	Local aEst		:= {}
	Local cLinhaOk	:= "AllwaysTrue()"
	Local cTudoOk	:= "AllwaysTrue()"
	Local lRetMod2 := .F.
	Local nColuna	:= 0
	Local nOpc		:= 0
	Local nX			:= 0
	Local nY			:= 0
	Local nCount	:= 0
	Local nNunDias	:= 0	//numero de dias que o material deveria durar
	Local nDescFun	:= 0	//valor a ser rateado entre os funcionarios da equipe
	Local nDiasLim	:= 0	//numero de dias maximo para devolucao sem cobranca dos 50% em folha
	Local cSeqD3	:= ""
	Local cQuery	:= ""
	Local cAli		:= GetNextAlias()

	// Variaveis para GetDados()
	Private aCols	:= {}
	Private aHeader:= {}
	Private _aDados:= {}

	// Variaveis para campos da Enchoice()
	Private cEquipe:= ZZ4->ZZ4_EQUIPE
	Private cNomeEq:= Posicione("AA1", 1, xFilial("AA1")+ZZ4->ZZ4_EQUIPE, "AA1_NOMTEC")

	Private cVERBEPC := GetMv("ML_VERBEPC")

	// Montagem do array de cabeçalho
	AADD(aCab,{"cEquipe"	,{015,010} ,"Equipe","@!",,,.F.})
	AADD(aCab,{"cNomeEq"	,{015,080} ,"Nome Equipe","@!",,,.T.})

	// Montagem do aHeader
	aHeader:= GetaHeader(GetaCampos("ZZD"))

	// Montagem do aCols
	GetaCols(aHeader)
	dbSelectArea("ZZD")
	dbSetOrder(1)
	dbSeek(xFilial("ZZD")+ZZ4->ZZ4_EQUIPE)
	Do While !ZZD->(EOF()) .AND. xFilial("ZZD")+ZZ4->ZZ4_EQUIPE == ZZD_FILIAL+ZZD_EQUIPE
		aColsAux:= {}
		For nX:= 1 To Len(aHeader)
			If aHeader[nX, 10] == "R"
				AADD(aColsAux, &(aHeader[nX, 2]))
			ElseIf Alltrim(aHeader[nX, 2]) == "ZZD_RECNO"
				AADD(aColsAux, ZZD->(RECNO()))
			Else
				AADD(aColsAux, CriaVar(aHeader[nX, 2]))
			EndIf
		Next nX
		AADD(aColsAux, .F.)

		AADD(aCols, aColsAux)
		ZZD->(dbSkip())
	EndDo

	ASORT(aCols, , , {|x, y| DtoS(x[ASCAN(aHeader, {|z| Alltrim(z[2]) == "ZZD_DTENTR"})])+x[ASCAN(aHeader, {|z| Alltrim(z[2]) == "ZZD_HRENTR"})] < DtoS(y[ASCAN(aHeader, {|z| Alltrim(z[2]) == "ZZD_DTENTR"})])+y[ASCAN(aHeader, {|z| Alltrim(z[2]) == "ZZD_HRENTR"})]})

	lRetMod2 := Modelo2(cTitulo, aCab, aRoda, aGrid, nOpc, cLinhaOk, cTudoOk,,,,9999,,,.T.)


	nDIASLIM := GetMv("ML_DIASLIM")
	
	//gravacao dos dados do browser
	If lRetMod2
		
		BEGIN TRANSACTION
		
		For nX:= 1 To Len(aCols)
			If gdDeleted(nX)
				//se estiver deletado, apaga o registro e volta o estoque
				dbGoTo(gdFieldGet("ZZD_RECNO", nX))
				If !ZZD->(EOF())
					If !Empty(Movimenta(ZZD->ZZD_CODEPC, "DE1", 2))
						Reclock("ZZD", .F.)
							dbDelete()
						MSUnlock()
					Endif
				EndIf
			ElseIf !Empty(gdFieldGet("ZZD_CODEPC", nX))

				//se a data de devolucao nao estiver em branco
				If !Empty(gdFieldGet("ZZD_DTDEVO", nX))
					//se o registro ja existe no banco
					If !Empty(gdFieldGet("ZZD_RECNO", nX))
						//se devolveu o epc
						If gdFieldGet("ZZD_INDDEV", nX) == '1'
							dbGoTo(gdFieldGet("ZZD_RECNO", nX))
							//se no acols nao estiver em branco a data de devolucao e no registro estiver é porque ainda nao foi lancado o desconto
							//ou se devolveu apos
							If Empty(ZZD->ZZD_DTDEVO)
								//gravo no vetor aDesc para fazer o desconto posteriormente
								AADD(aDesc, gdFieldGet("ZZD_RECNO", nX))
							ElseIf gdFieldGet("ZZD_DEV", nX) == '3' .AND. ZZD->ZZD_DEV == '4'
								//gravo no vetor aEst para fazer o estorno posteriormente
								If Date() - ZZD->ZZD_DTDEVO < nDIASLIM //GetMv("ML_DIASLIM")
									AADD(aEst, gdFieldGet("ZZD_RECNO", nX))
								EndIf
							EndIf
						EndIf
					EndIf
				EndIf
				
				If Empty(gdFieldGet("ZZD_RECNO", nX))
					Reclock("ZZD", .T.)
					ZZD_FILIAL:= xFilial("ZZD")
					ZZD_EQUIPE:= cEquipe
				Else
					dbGoTo(gdFieldGet("ZZD_RECNO", nX))
					Reclock("ZZD", .F.)
				EndIf

				For nY:= 1 To Len(aHeader)
					&(aHeader[ny, 2]):= gdFieldGet(aHeader[ny, 2], nX)
				Next nY

				MSUnlock()
				AADD(aRecno, ZZD->(Recno()))
			EndIf
		Next nX
		
		//percoro todos os itens do browser para movimentar o estoque
		For nX:= 1 To Len(aRecno)
			dbSelectArea("ZZD")
			dbGoTo(aRecno[nX])
			If Empty(ZZD->ZZD_SEQD3)
				cSeqD3 := Movimenta(ZZD->ZZD_CODEPC, "RE1", 1)
			ElseIf ZZD->ZZD_DEV == "3" .AND. ZZD->ZZD_INDDEV == "1" .AND. ZZD_TIPODV == "1"
				cSeqD3 := Movimenta(ZZD->ZZD_CODEPC, "DE1", 2)
			EndIf
			If !Empty(cSeqD3)
				RecLock("ZZD", .F.)
				ZZD->ZZD_TIPODV:= "2"
				ZZD->ZZD_SEQD3 := cSeqD3
				MsUnlock()
			EndIf
		Next nX
	
		//verifico os itens que devo fazer o desconto em folha
		For nX:= 1 To Len(aDesc)
			dbSelectArea("ZZD")
			dbGoTo(aDesc[nX])
			//alert("Desconto")
			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(xFilial("SB1")+ZZD->ZZD_CODEPC)
			nDescFun:= 0
			If Found()
				//pego o numero de dias que o epc deveria durar
				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(xFilial("SB1")+ZZD->ZZD_CODEPC)
				If Found()
					nNumDias:= SB1->B1_PRVALID
					//verifico se o epc nao durou o esperado
					If nNumDias > ZZD->ZZD_DTDEVO-ZZD->ZZD_DTENTR
						nDescFun:= (SB1->B1_UPRC/nNumDias)*(nNumDias-(ZZD->ZZD_DTDEVO-ZZD->ZZD_DTENTR))
					EndIf
					//alert(nDescFun)
	
					//se o epc nao foi devolvido cobro mais 50% do valor
					If ZZD->ZZD_DEV == '4'
						nDescFun+= SB1->B1_UPRC*0.5
					EndIf
					//alert(nDescFun)
	
					//se o desconto der acima do valor do epc, cobro apenas o epc
					If nDescFun > SB1->B1_UPRC
						nDescFun:= SB1->B1_UPRC
					EndIf
					//alert(nDescFun)
					
					cQuery:= " SELECT * "
					cQuery+= " FROM "+RetSqlName("ZZ4")+" ZZ4 "
					cQuery+= " WHERE ZZ4_EQUIPE = '"+cEquipe+"' AND "
					cQuery+= "       ZZ4_CODSRA <> '' AND "
					cQuery+= "       "+RetSqlCond("ZZ4")
	
					cAli:= GetNextAlias()
					TCQuery ChangeQuery(cQuery) New Alias &(cAli)
					Count To nCount
					&(cAli)->(dbGoTop())
	

					Do While !&(cAli)->(EOF())
	
						dbSelectArea("SRA")
						dbSetOrder(1)
						dbSeek(xFilial("SRA")+&(cAli)->(ZZ4_CODSRA))
						If Found()
	
							RecLock ("SRK", .T.)
							SRK->RK_FILIAL		:= xFilial ("SRK")		// filial
							SRK->RK_MAT			:= SRA->RA_MAT				// Matricula
							SRK->RK_PD 			:= cVERBEPC //GetMv("ML_VERBEPC")	// Codigo da Verba
							SRK->RK_CC     		:= SRA->RA_CC				// Codigo do CC
							SRK->RK_PARCELA		:= 1
							SRK->RK_VALORTO		:= Round(nDescFun/nCount, 2)	// valor da verba
							SRK->RK_VALORPA		:= round(nDescFun/nCount, 2)				// valor da verba
							SRK->RK_REGRADS		:= 1
							SRK->RK_DTVENC		:= IIF(Day(Date()) > 16, STOD(STRZERO(YEAR(DATE()),4)+STRZERO(MONTH(DATE())+1,2)+"15"), STOD(STRZERO(YEAR(DATE()),4)+STRZERO(MONTH(DATE()),2)+"15"))
							SRK->RK_DTMOVI		:= ZZD->ZZD_DTDEVO
							SRK->RK_DOCUMEN		:= cValToChar(SRK->(Recno()))
							SRK->RK_OBS			:= "REF. " + IIF(ZZD->ZZD_MOTIVO == "1", "ADMISSIONAL", IIF(ZZD->ZZD_MOTIVO == "2", "DESGASTE", IIF(ZZD->ZZD_MOTIVO == "3", "DEFEITO", IIF(ZZD->ZZD_MOTIVO == "4", "PERDA", IIF(ZZD->ZZD_MOTIVO == "5", "ROUBO", IIF(ZZD->ZZD_MOTIVO == "6", "DEMISSIONAL", "OUTROS")))))) + " EPC " + SB1->B1_DESC
							MsUnLock()
						EndIf
	
						&(cAli)->(dbSkip())
					Enddo
				EndIf
	
				&(cAli)->(dbCloseArea())
	
			EndIf
	
		Next nX
	

		cVERBDEV := GetMv("ML_VERBDEV")

		//verifico os itens que devo fazer o estorno na folha
		For nX:= 1 To Len(aEst)
			dbSelectArea("ZZD")
			dbGoTo(aEst[nX])
			//alert("Estorno")
			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(xFilial("SB1")+ZZD->ZZD_CODEPC)
			nDescFun:= 0
			If Found()
				//pego o numero de dias que o epc deveria durar
				dbSelectArea("SB1")
				dbSetOrder(1)
				dbSeek(xFilial("SB1")+ZZD->ZZD_CODEPC)
				If Found()
	
					cQuery:= " SELECT * "
					cQuery+= " FROM "+RetSqlName("ZZ4")+" ZZ4 "
					cQuery+= " WHERE ZZ4_EQUIPE = '"+cEquipe+"' AND "
					cQuery+= "       ZZ4_CODSRA <> '' AND "
					cQuery+= "       "+RetSqlCond("ZZ4")
	
					cAli:= GetNextAlias()
					TCQuery ChangeQuery(cQuery) New Alias &(cAli)
					Count To nCount
					&(cAli)->(dbGoTop())
	
					Do While !&(cAli)->(EOF())
	
						dbSelectArea("SRA")
						dbSetOrder(1)
						dbSeek(xFilial("SRA")+&(cAli)->(ZZ4_CODSRA))
						If Found()
	
							RecLock ("SRK", .T.)
							SRK->RK_FILIAL		:= xFilial ("SRK")		// filial
							SRK->RK_MAT			:= SRA->RA_MAT				// Matricula
							SRK->RK_PD 			:= cVERBDEV //GetMv("ML_VERBDEV")	// Codigo da Verba
							SRK->RK_CC     	:= SRA->RA_CC				// Codigo do CC
							SRK->RK_PARCELA	:= 1
							SRK->RK_VALORTO	:= SB1->B1_UPRC*0.5		// valor da verba
							SRK->RK_DTVENC		:= IIF(Day(Date()) > 16, STOD(STRZERO(YEAR(DATE()),4)+STRZERO(MONTH(DATE())+1,2)+"15"), STOD(STRZERO(YEAR(DATE()),4)+STRZERO(MONTH(DATE()),2)+"15"))
							SRK->RK_DTMOVI		:= ZZD->ZZD_DTDEVO
							SRK->RK_DOCUMEN	:= cValToChar(SRK->(Recno()))
							SRK->RK_OBS			:= "REF. " + IIF(ZZD->ZZD_MOTIVO == "1", "ADMISSIONAL", IIF(ZZD->ZZD_MOTIVO == "2", "DESGASTE", IIF(ZZD->ZZD_MOTIVO == "3", "DEFEITO", IIF(ZZD->ZZD_MOTIVO == "4", "PERDA", IIF(ZZD->ZZD_MOTIVO == "5", "ROUBO", IIF(ZZD->ZZD_MOTIVO == "6", "DEMISSIONAL", "OUTROS")))))) + " EPC " + SB1->B1_DESC
							MsUnLock()
						EndIf
	
						&(cAli)->(dbSkip())
					Enddo
				EndIf
	
				&(cAli)->(dbCloseArea())
	
			EndIf
	
		Next nX
	
		//chamada do comprovante de entrega
		If Len(_aDados) > 0
			U_FB602MDT()
		EndIf
		
		END TRANSACTION
		
	EndIf
	
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GetaCamposºAutor  ³Ezequiel Pianegondaº Data ³  12/07/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna um vetor com os campos usados para passar para a    º±±
±±º          ³funcao getaheader. ex.: aCampos:={a1_cod, a1_desc}          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetaCampos(cAlias)
	Local aCampos	:= {}
	//Local aAreaSX3	:= SX3->(GetArea())
	Local _cSX3 	:= GetNextAlias()

	//SX3
	OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX3,"SX3",Nil,.F.)
	lOpen := Select(_cSX3) > 0
	If (lOpen)
  		dbSelectArea(_cSX3)
  		(_cSX3)->(dbSetOrder(1)) 
  		(_cSX3)->(dbSeek(cAlias))
		If (Found())
  			While ( !(_cSX3)->(Eof()) .And. &("(_cSX3)->X3_ARQUIVO") == cAlias )
    			
				If &("((_cSX3)->X3_USADO") == "€€€€€€€€€€€€€€ " .AND. &("(_cSX3)->X3_BROWSE") == 'S' //.AND. SX3->X3_CONTEXT == 'R'
					AADD(aCampos, &("(_cSX3)->X3_CAMPO"))
				EndIf
				
				(_cSX3)->(DBSkip())
   			EndDo
		EndIf
	Endif
	(_cSX3)->(dbCloseArea())


	/*SX3->(DBSetOrder(1))
	SX3->(DBSeek(cAlias))
	Do While !SX3->(EOF()) .AND. SX3->X3_ARQUIVO == cAlias
		If SX3->X3_USADO == "€€€€€€€€€€€€€€ " .AND. SX3->X3_BROWSE == 'S' //.AND. SX3->X3_CONTEXT == 'R'
			AADD(aCampos, SX3->X3_CAMPO)
		EndIf
		SX3->(dbSkip())
	EndDo
	RestArea(aAreaSX3)
	*/

Return aCampos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GetaHeaderºAutor  ³Ezequiel Pianegondaº Data ³  12/07/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera um aHeader para MSGetDados dos campos passados no      º±±
±±º          ³vetor aCampos ex. aCampos:= {a1_cod, a1_desc}               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Generico                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetaHeader(aCampos)
	Local aHeader	:= {}
	//Local aAreaSX3	:= SX3->(GetArea())
	Local i:= 0

	Local _cSX3 	:= GetNextAlias()

	//SX3
	OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX3,"SX3",Nil,.F.)
	lOpen := Select(_cSX3) > 0
	If (lOpen)
  		dbSelectArea(_cSX3)
  		(_cSX3)->(dbSetOrder(2)) 
  		(_cSX3)->(dbSeek(Upper(aCampos[i])))
		If (Found())
  			AADD(aHeader, {Trim(&("(_cSX3)->X3_TITULO")), &("(_cSX3)->X3_CAMPO"), &("(_cSX3)->X3_PICTURE"), &("(_cSX3)->X3_TAMANHO"), &("(_cSX3)->X3_DECIMAL"), "", &("(_cSX3)->X3_USADO"), &("(_cSX3)->X3_TIPO"), &("(_cSX3)->X3_ARQUIVO"), &("(_cSX3)->X3_CONTEXT")})
		EndIf
	Endif
	(_cSX3)->(dbCloseArea())


	/*For i:= 1 To Len(aCampos)
		SX3->(DBSetOrder(2))
		SX3->(DBGoTop())
		If SX3->(DBSeek(Upper(aCampos[i])))
			AADD(aHeader, {Trim(SX3->X3_TITULO), SX3->X3_CAMPO, SX3->X3_PICTURE, SX3->X3_TAMANHO, SX3->X3_DECIMAL, "", SX3->X3_USADO, SX3->X3_TIPO, SX3->X3_ARQUIVO, SX3->X3_CONTEXT})
		EndIf
	Next i
	RestArea(aAreaSX3)*/

Return aHeader

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GetaCols ºAutor  ³Ezequiel Pianegonda º Data ³  12/07/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Gera um acols vazio com base no parametro aheader informado º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ aCols:= GetaCols(GetaHeader({a1_cod, a1_desc}))            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GetaCols(aHeader)
	Local aCols		:= {}
	//Local aAreaSX3	:= SX3->(GetArea())
	Local i:= 0
	Local _cSX3 	:= GetNextAlias()


	//SX3
	OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX3,"SX3",Nil,.F.)
	lOpen := Select(_cSX3) > 0
	If (lOpen)
		For i:= 1 To Len(aHeader)
  			dbSelectArea(_cSX3)
  			(_cSX3)->(dbSetOrder(2)) 
  			(_cSX3)->(dbSeek(Upper(aHeader[i, 2])))
			If (Found())
				Do Case
			    	Case aHeader[i, 8] $ "C/M"
						AADD(aCols, Space(aHeader[i, 4]))
					Case aHeader[i, 8] $ "N"
						AADD(aCols, 0)
					Case aHeader[i, 8] $ "D"
						AADD(aCols, CtoD(""))
					Case aHeader[i, 8] $ "L"
						AADD(aCols, .F.)
				EndCase
			EndIf
		Next i
		AADD(aCols, .T.)
	Endif
	(_cSX3)->(dbCloseArea())


	/*For i:= 1 To Len(aHeader)
		IF SX3->(DBSeek(Upper(aHeader[i, 2])))
			Do Case
			Case aHeader[i, 8] $ "C/M"
				AADD(aCols, Space(aHeader[i, 4]))
			Case aHeader[i, 8] $ "N"
				AADD(aCols, 0)
			Case aHeader[i, 8] $ "D"
				AADD(aCols, CtoD(""))
			Case aHeader[i, 8] $ "L"
				AADD(aCols, .F.)
			EndCase
		EndIf
	Next i
	AADD(aCols, .T.)
	RestArea(aAreaSX3)*/

Return aCols

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Movimenta ³ Autor ³Ezequiel Pianegonda    ³ Data ³13/07/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera Movimento de Requisicao e/ou Devolucao nos Arquivos de ³±±
±±³          ³ Movimentacao Interna (SD3).                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Numero Sequencial gravado no SD3                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cProd = Codigo do Produto                                   ³±±
±±³          ³ cCod = Codigo da movimentação (DE1/RE1)                     ³±±
±±³          ³ nTpMov= 1. Requisicao/ 2. Devolucao                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
static Function Movimenta(cProd, cCod, nTpMov)
	
	Local aArea	:= GetArea()
	Local cTpMov:= ""
	Local cSeqD3:= ""
	Local aAuto	:= {}
	Local cResp	:= cUserName
	Local cQuery:= ""
	Local cAli	:= GetNextAlias()
	Local cCC	:= ""

	Private lMSErroAuto:= .F.

	If nTpMov == 1
		cTpMov:= SuperGetMv("ML_SAIEPI", .F., "")
	Else
		cTpMov:= SuperGetMv("ML_ENTEPI", .F., "")
	EndIf

	If Empty(cTpMov)
		MsgStop("Não foi informado o tipo de movimentação do estoque. Confira os parâmetros ML_ENTEPI e ML_SAIEPI. Alteração de estoque não efetuada!")
		Return ""
	EndIf
	
	dbSelectArea("AA1")
	dbSetOrder(1)
	if MsSeek(xFilial("AA1")+ZZD->ZZD_EQUIPE)
		cCC := AA1->AA1_CC
	else
		MsgStop("Não foi encontrado o Centro de Custo da equipe("+ZZD->ZZD_EQUIPE+"). Verificar no cadastro da equipes(AA1). ")
	Return ""
	EndIf

	Dbselectarea("SRA")
	Dbsetorder(1)
	MsSeek(xfilial("SRA")+cResp)

	Dbselectarea("SB2")
	Dbsetorder(1)
	If !MsSeek(xfilial("SB2")+cProd+ZZD->ZZD_LOCAL)
		CriaSB2(cProd, ZZD->ZZD_LOCAL)
		// A FUNCAO ACIMA NAO LIBERA O REGISTRO
		MsUnlock("SB2")
	EndIf

	Dbselectarea("SBF")
	Dbsetorder(4)
	Dbseek(xfilial("SBF")+cProd+ZZD->ZZD_SERIE)
	
	Dbselectarea("SB1")
	Dbsetorder(1)
	Dbseek(xFilial("SB1")+cProd)

//localizo o lote com saldo maior ou igual a quantidade a ser movimentada
	cQuery:= " SELECT * "
	cQuery+= " FROM "+RetSqlName("SBF")+" SBF "
	cQuery+= " WHERE BF_PRODUTO = '"+cProd+"' AND "
	cQuery+= " BF_LOCAL = '"+ZZD->ZZD_LOCAL+"' AND "
	cQuery+= " BF_LOCALIZ = '"+ZZD->ZZD_ENDLOC+"' AND "
	cQuery+= " BF_NUMSERI = '"+ZZD->ZZD_SERIE+"' AND "
	cQuery+= " "+RetSqlCond("SBF")

	TcQuery ChangeQuery(cQuery) new alias cAli

	dbselectarea("SB8")
	dbgoto(cAli->R_E_C_N_O_)

	cSeqD3:= ProxNum()
	aAuto:= {}
	AADD(aAuto, {"D3_FILIAL",	xFilial('SD3'),												NIL})
	AADD(aAuto, {"D3_TM",		cTpMov,														NIL})
	AADD(aAuto, {"D3_COD",		cProd,														NIL})
	AADD(aAuto, {"D3_UM",		SB1->B1_UM,													NIL})
	AADD(aAuto, {"D3_QUANT",	ZZD->ZZD_QTDENT,											NIL})
	AADD(aAuto, {"D3_CF",		cCod,														NIL})
	AADD(aAuto, {"D3_CONTA",	SB1->B1_CONTA,												NIL})
	AADD(aAuto, {"D3_LOCAL",	ZZD->ZZD_LOCAL,												NIL})
	AADD(aAuto, {"D3_EMISSAO",	ZZD->ZZD_DTENTR,											NIL})
	AADD(aAuto, {"D3_NUMSEQ",	cSeqD3,														NIL})
	AADD(aAuto, {"D3_SEGUM",	SB1->B1_SEGUM,												NIL})
	AADD(aAuto, {"D3_QTSEGUM",	ConvUm(cProd, 1, 0, 2),										NIL})
	AADD(aAuto, {"D3_GRUPO",	SB1->B1_GRUPO,												NIL})
	AADD(aAuto, {"D3_TIPO",		SB1->B1_TIPO,												NIL})
	AADD(aAuto, {"D3_CHAVE",	SubStr(cCod, 2, 1)+If(cCod == 'DE4', '9', '0'),				NIL})
	AADD(aAuto, {"D3_NUMSERI",	ZZD->ZZD_SERIE,												NIL})
	AADD(aAuto, {"D3_USUARIO",	Left(cUserName,20),											NIL})
	AADD(aAuto, {"D3_CC",		cCC,														NIL})
	AADD(aAuto, {"D3_LOCALIZ",	ZZD->ZZD_ENDLOC,											NIL})
	AADD(aAuto, {"D3_LOTECTL",	cAli->BF_LOTECTL,											NIL})
	cAli->(dbCloseArea())
	
	aAuto:= u_OrdAuto(aAuto)
	
	//u_showarray(aAuto)
	//AADD(aAuto, {"D3_LOCALIZ",	SBF->BF_LOCALIZ,											NIL})
	//u_showarray(aAuto)
	
	If Len(aAuto) > 0
		DbSelectArea("SD3")
		MSExecAuto({|x, y| mata240(x, y)}, aAuto, 3)
		If lMSErroAuto
			//RecLock("ZZD", .F.)
			//dbDelete()
			//MsUnlock()
			DisarmTransaction() // Adicionado por Felipe S. Raota - 23/05/14
			MsgAlert("Houve erro na movimentacao de estoque. Verifique na tela seguinte.", procname ())
			MostraErro()
		ElseIf nTpMov == 1
			AADD(_aDados, ZZD->(RECNO()))
		EndIf 
	EndIf

//alert("")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pega os 5 custos medios atuais             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//aCM := PegaCMAtu(SD3->D3_COD,SD3->D3_LOCAL)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava o custo da movimentacao              ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//aCusto := GravaCusD3(aCM)

//B2AtuComD3(aCusto,Nil,Nil,(SD3->D3_TM > '500'),Nil,.T.)

//SaldoSBF(SD3->D3_LOCAL,SD3->D3_LOCALIZ,SD3->D3_COD,SD3->D3_NUMSERI)

	RestArea(aArea)
Return cSeqD3
