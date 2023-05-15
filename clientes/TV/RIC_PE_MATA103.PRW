#INCLUDE "PROTHEUS.CH"

//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} MTCOLSE2
Manipula os dados do aCols de Títulos a pagar

@author Leandro Natan Bonette Santos
@since  21/03/2013
@return aVetor - Vetor contendo o aCols do título a pagar 
				 com as alterações desejadas.
/*/
//-------------------------------------------------------------------------------------------

/*
User Function MTCOLSE2()

	Public __aColsSE2 := aClone(PARAMIXB[1])

Return Nil

*/
//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} MTCOLSE2
Possibilita a adição de campos ao aCols de informação

@author Leandro Natan Bonette Santos
@since  21/03/2013
@return aVetor - Vetor contendo os campos que deverão ser incluídos
				 ao aHeader de títulos financeiros.
/*/
//-------------------------------------------------------------------------------------------
User Function MT103SE2()

	/* 
	 * Copia os dados do aHeadSE2 para serem utilizados no
	 * ponto de entrada MT100TOK
	 */
	Public __aHeadSE2 := aClone(PARAMIXB[1])

Return Nil

//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} MT103IPC
Atualiza campos customizados no Documento de Entrada

@author Leandro Natan Bonette Santos
@since  05/12/2017
@return uRet, nulo

/*/
//-------------------------------------------------------------------------------------------
User Function MT103IPC()

	Local aArea      := GetArea()
	Local aAreaSB1   := SB1->(GetArea())

	Local nLinha     := PARAMIXB[1]

	Local nPosProd   := AScan(aHeader,{|x| AllTrim(x[2]) == "D1_COD"     }) //Código do Produto
	Local nPosItCta  := AScan(aHeader,{|x| AllTrim(x[2]) == "D1_ITEMCTA" }) //Item Conta
	Local nPosCO     := AScan(aHeader,{|x| AllTrim(x[2]) == "D1_CO"      }) //Conta orçamentária
	Local nPosCC     := AScan(aHeader,{|x| AllTrim(x[2]) == "D1_CC"      }) //Código do Centro de Custo
	Local nPosObs    := AScan(aHeader,{|x| AllTrim(x[2]) == "D1_X_OBS"   }) //Observações
	Local nPosConta  := AScan(aHeader,{|x| AllTrim(x[2]) == "D1_CONTA"   }) //Conta contábil
	Local nPosDescr  := AScan(aHeader,{|x| AllTrim(x[2]) == "D1_DESCR"   }) //Descrição do produto
	Local nPosDesCCT := AScan(aHeader,{|x| AllTrim(x[2]) == "D1_DESCCT"  })
	Local nPosDesCt  := AScan(aHeader,{|x| AllTrim(x[2]) == "D1_DESCCC"  })	//Descrição da conta contábil


	aCols[nLinha][nPosCC]     := SC7->C7_CC
	aCols[nLinha][nPosCO]     := SC7->C7_CO
	aCols[nLinha][nPosItCta]  := SC7->C7_ITEMCTA
	aCols[nLinha][nPosObs]    := SC7->C7_OBS
	aCols[nLinha][nPosConta]  := SC7->C7_CONTA

	aCols[nLinha][nPosDesCCT] := POSICIONE("CTT",1,xFilial("CTT")+aCols[nLinha][nPosCC]   ,"CTT_DESC01")
	aCols[nLinha][nPosDescr]  := POSICIONE("SB1",1,xFilial("SB1")+aCols[nLinha][nPosProd] ,"B1_DESC"   ) // Descrição produto
	aCols[nLinha][nPosDesCt]  := POSICIONE("CT1",1,xFilial("CT1")+aCols[nLinha][nPosConta],"CT1_DESC01") // Descrição Conta contábil

	RestArea(aAreaSB1)
	RestArea(aArea)

Return



//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} MT103FIN
Ponto de entrada para validação final da aba de duplicatas no documento de entrada

Utilizado para bloquear vencimento fora do parametrizado

@author Thiago Henrique dos Santos
@since  08/01/2013
@return lRet, indica se aba duplicatas foi ou não validada

/*/
//-------------------------------------------------------------------------------------------
User Function MT103FIN()

	Local aHeadSE2 := PARAMIXB[1]
	Local aColsSE2   := PARAMIXB[2]
	Local nDiasTitu  := 0
	Local nPVencto := 1
	Local lRet := .T.
	Local lUserLib   := __cUserId $ ("000000;" + GetMv("RIC_DTITLB",,"000000"))

	If !("D" $ cTipo)

		nDiasTitu := GetMv("RIC_DTITU")
		If( aColsSE2[1][aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_VENCTO"})] - Date() <= nDiasTitu ) .AND. !lUserLib
			lRet := U_AFIN014B(CA100FOR,CLOJA) //Bloqueio de Inclusão do Titulo
		EndIf

	Endif

Return lRet


//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} MT103FIM
PE operação após a gravação da NFE.

@author Weslley Goncalves
@since  23/08/2011
@return uRet, nulo

/*/
//-------------------------------------------------------------------------------------------
User Function MT103FIM()

	Local uRet := Nil

	If FWCodEmp() == "01"
		uRet := RICPR03()
	EndIf

	If FWCodEmp() == "02"
		uRet := RICSC03()
	EndIf

	//Custom para atualziar a tabela SZ5 quando for retorno de uma nf
	if SD1->D1_TIPO == "D"
		MsgRun('Criando registros na tabela SZ5',"Aguarde...",u_atuSZ5())
	endIf

Return uRet

User Function atuSZ5()

	Local aSD2 := SD2->(getArea())
	Local aSC5 := SC5->(getArea())
	Local aSC6 := SC6->(getArea())
	Local nOpcao    := PARAMIXB[1]
	Local nConfirma := PARAMIXB[2]

	if nOpcao == 3 .And. nConfirma == 1
		dbSelectArea('SD2')
		SD2->(DbSetOrder(3))
		if SD2->(dbSeek(xFilial("SD2")+SD1->D1_NFORI+SD1->D1_SERIORI+SD1->D1_FORNECE+SD1->D1_LOJA))

			dbSelectArea("SC5")
			SC5->(dbSetOrder(3))
			if SC5->(dbSeek(xFilial("SC5")+SD2->D2_CLIENTE+SD2->D2_LOJA+SD2->D2_PEDIDO))

				dbSelectArea("SC6")
				SC6->(dbSetOrder(1))
				if SC6->(dbSeek(xFilial("SC6")+SD2->D2_PEDIDO+SD2->D2_ITEMPV))

					U_MTA410E()

				endIf

			endIf

		endIf
	endIf

	RestArea(aSC5)
	RestArea(aSC6)
	RestArea(aSD2)
	/*
	BeginSQL Alias "QRYEXC"
				
		SELECT 	
			SC5.R_E_C_N_O_ AS SC5_REC, 
			SC6.R_E_C_N_O_ AS SC6_REC
		FROM %Table:SD2% SD2 
		INNER JOIN %Table:SC6% SC6
			ON SC6.C6_FILIAL = SD2.D2_FILIAL
			AND SC6.C6_NOTA = SD2.D2_DOC
			AND SC6.C6_SERIE = SD2.D2_SERIE
			AND SC6.%NotDel%
		INNER JOIN %Table:SC5% SC5
			ON	SC5.C5_FILIAL = SC6.C6_FILIAL
			AND SC5.C5_NUM    = SC6.C6_NUM
			AND SC5.%NotDel%			
		WHERE 		SD2.D2_FILIAL = %Exp:SD1->D1_FILIAL%
				AND SD2.D2_DOC    = %Exp:SD1->D1_NFORI%
				AND SD2.D2_SERIE  = %Exp:SD1->D1_SERIORI%
				AND SD2.%NotDel%
		ORDER BY %Order:SD2%
				 
	EndSQL

	DbSelectArea("QRYEXC")
	QRYEXC->(DbGoTop())

	while (QRYEXC)->(!Eof())

		dbSelectArea('SC5')
		dbGoTo((QRYEXC)->SC5_REC)

		dbSelectArea('SC6')
		dbGoTo((QRYEXC)->SC6_REC)

		U_xMTA410E()
		QRYEXC->(dbSkip())

	endDo

	QRYEXC->(dbCloseArea())
*/
Return

Static Function RICPR03()

	Local nOpcao    := PARAMIXB[1] // Opção Escolhida pelo usuario no aRotina
	Local nConfirma := PARAMIXB[2] // Se o usuario confirmou a operação de gravação da NFE
	Local c_PREFIXO := ""
	Local c_FIL     :=""
	Local c_DOC     :=""
	Local c_SERIE   :=""
	Local c_FORNECE :=""
	Local c_LOJA    := ""
	Local c_TIPO    := ""
	Local cMGS      := ""
	Local c_Num     := ""
	Local cQuery    := ""
	Local cFromSE2  := RetSQLName("SE2")
	Local cAliasQry := GetNextAlias()

	Local aArea     := GetArea()
	Local aAreaSE2  := SE2->(GetArea())

	If nOpcao == 3 .And. nConfirma == 1
		cMGS:=TelaObs()
		If !Empty(cMGS)
			dbSelectArea("SF1")
			c_FIL    := SF1->F1_FILIAL
			c_DOC    := SF1->F1_DOC
			c_SERIE  := SF1->F1_SERIE
			c_FORNECE:= SF1->F1_FORNECE
			c_LOJA   := SF1->F1_LOJA
			c_TIPO   := SF1->F1_TIPO
			c_Num    := SF1->F1_DUPL
			c_PREFIXO:= SF1->F1_PREFIXO

			//
			//Gravar SF1
			dbSetOrder(1)

			If MsSeek(c_FIL+c_DOC+c_SERIE+c_FORNECE+c_LOJA+c_TIPO)
				RecLock("SF1", .F.)
				SF1->F1_OBSNF:=cMGS
				MsUnLock()
			EndIf

			//Gravar SE2
			cQuery:=""
			cQuery:="SELECT R_E_C_N_O_ REC "
			cQuery+=" FROM SE2010 WHERE E2_FILIAL = '"+c_FIL+"'"
			cQuery+=" AND E2_PREFIXO = '"+c_PREFIXO+"' "
			cQuery+=" AND E2_NUM = '"+c_Num+"' "
			cQuery+=" AND E2_TIPO = '"+MVNOTAFIS+"' "
			cQuery+=" AND E2_FORNECE = '"+c_FORNECE+"' "
			cQuery+=" AND E2_LOJA = '"+c_LOJA+"' "
			cQuery+=" AND D_E_L_E_T_ = ' ' "

			cQuery:= ChangeQuery(cQuery)
			cAliasQry := GetNextAlias()//dbSelectArea(cAliasQry)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

			dbSelectArea(cAliasQry)
			dbGoTop()

			nValor  := 0
			nAbatim := 0

			Do While !(cAliasQry)->(EOF())
				dbSelectArea("SE2")
				dbGoTo((cAliasQry)->(REC))

				RecLock("SE2", .F.)
				SE2->E2_HIST:=cMGS
				MsUnLock()

				dbSelectArea(cAliasQry)
				(cAliasQry)->(dbSkip())

			EndDo

			dbSelectArea(cAliasQry)
			(cAliasQry)->(dbCloseArea())

			RestArea(aAreaSE2)
			RestArea(aArea)

		EndIf
		// Opção para impressão de demonstrativo NF x PCO
		If MSGYESNO("Deseja imprimir demonstrativo NF x PCO ?","NF entrada x Conta do PCO")
			U_RPCO002()
		EndIf

		gravaDARF()//Grava a DARF
		gravaNumPed() // Grava Numero Pedido

	EndIf


Return()


Static Function RICSC03()

	Local nOpcao    := PARAMIXB[1]
	Local nConfirma := PARAMIXB[2]
	Local cQuery    := ""
	Local cFromSC7  := RetSQLName("SC7")
	Local cAliasQry := GetNextAlias()
	Local aGArea    := GetArea()
	Local cNom      := ""
	Local cDesCC    := ""
	Local cDesCT    := ""

	DbSelectArea("SD1")

	If nOpcao == 3 .And. nConfirma == 1

		cNom   := Posicione("SA2",1,xFilial("SA2")+SD1->D1_FORNECE+SD1->D1_LOJA,"A2_NOME")
		cDesCC := Posicione("CTT",1,xFilial("CTT")+SD1->D1_CC,"CTT_DESC01")
		cDesCT := Posicione("CT1",1,xFilial("CT1")+SD1->D1_CONTA,"CT1_DESC01")

		dbSelectArea("SD1")
		If RecLock("SD1",.F.)
			SD1->D1_NOME	:= cNom
			SD1->D1_DESCCC	:= cDesCT
			SD1->D1_DESCCT	:= cDesCC
			SD1->(MsUnLock())
		Endif

	/*
	Reclock ("SF1",.F.)
	SF1->F1_FORNISS := IIF(Empty(cForIss),GETMV("MV_MUNIC"),cForIss)
	SF1->F1_LOJAISS := IIF(Empty(cLojIss),"00",cLojIss)
	SF1->F1_DIAVC	:= IIF(Empty(nDiaVc),GETMV("MV_DIAISS"),nDiaVc)
	SF1->F1_HORA	:= TIME()
	SF1->(MsUnlock())
	*/
		RestArea(aGArea)
	EndIf

Return

Static Function TelaObs()

	Local oFontArial
	Local oTela
	Local oSayTl
	Local oGetTl
	Local oSBtnTl
	Local oSBtnTl
	Local oBtnTl
	Local cObsNF := Space(TamSX3("F1_OBSNF")[1])

	oFontArial := TFont():New( "Arial Black",0,-15,,.T.,0,,700,.F.,.F.,,,,,, )
	oTela      := MSDialog():New( 423,353,533,836,"Obs - NFE",,,.F.,,,,,,.T.,,,.T. )
	TBitMap():New(000,000,030,400,"ProjetoAP",,.t.,oTela,,,,,,,,,.t.)
	oSayTl      := TSay():New(003,100,{||"Observação:"},oTela,,oFontArial,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,050,012)
	oGetTl      := TGet():New(020,060,{|u| if(PCount()>0,cObsNF:=u,cObsNF)}   ,oTela,168,008,'',                     ,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,""       ,"cObsNF",,)
	TButton():New(035,108,OemToAnsi("&OK"),oTela,{|| oTela:End()},040,015,,,.T.,.T.,,OemToAnsi("OK"))

	Activate MsDialog oTela Center

Return (cObsNF)

//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} gravaDARF 
Grava os dados da DARF nos títulos de taxas

@author Leandro Natan Bonette Santos
@since  15/07/2013

/*/
//-------------------------------------------------------------------------------------------
Static Function gravaDARF()

	Local aArea    := GetArea()
	Local aAreaSE2 := SE2->(GetArea())

	Local cNaturIRRF := "22.1.05   "
	Local cTipoTX    := "TX "

	Local cTpTrib    := "DP"
	Local nCodReceit := 1708
	Local cTpIdent   := "01"
	Local cIdentifi  := SM0->M0_CGC
	Local cContaORC  := "95          "
	Local cItemConta := " "

	Local dApuracao,dVenctDARF,dPagamento

	If Select("TRB") > 0
		TRB->(dbCloseArea())
	EndIf

	BeginSQL Alias "TRB"
		SELECT E2_FILIAL, E2_TIPO, E2_PREFIXO, E2_NUM, E2_FORNECE,
			    E2_LOJA, E2_NOMFOR, R_E_C_N_O_
		FROM %table:SE2%
		WHERE E2_FILIAL  = %xFilial:SE2%
		AND   E2_PREFIXO = %exp:SE2->E2_PREFIXO%
		AND   E2_NUM     = %exp:SE2->E2_NUM%
		AND   E2_NATUREZ = %exp:cNaturIRRF%
		AND   E2_TIPO    = %exp:cTipoTX%        
		AND   %notDel%
	EndSQL

	If( TRB->(!EoF()) )

		SE2->(dbGoTo(TRB->R_E_C_N_O_))

		If SE2->(!EoF())

			dApuracao  := LastDay(SE2->E2_EMISSAO,2)
			dVenctDARF := LastDay(SE2->E2_EMISSAO) + 20

			If DOW(dVenctDARF) == 7
				dVenctDARF -= 1
			ElseIf DOW(dVenctDARF) == 1
				dVenctDARF -= 1
			EndIf

			dPagamento := dVenctDARF

			RecLock("SE2",.F.)
			SE2->E2_TPTRIB  := "DP"
			SE2->E2_CODRECT := nCodReceit
			SE2->E2_TPIDENT := "01"
			SE2->E2_IDENTF  := cIdentifi
			SE2->E2_PAPRU   := dApuracao
			SE2->E2_VCTDARF := dVenctDARF
			SE2->E2_DTPG    := dPagamento
			SE2->E2_CO      := cContaORC
			SE2->E2_ITEMCTA := cItemConta
			MsUnlock()

		EndIf

	EndIf

	TRB->(dbCloseArea())
	RestArea(aAreaSE2)
	RestArea(aArea)

Return


//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} gravaNumPed 

Grava numero pedido de venda no campo NumPed na SE2

@author Anderson Nunes Navarro Leal
@since  12/11/2013

/*/
//-------------------------------------------------------------------------------------------
Static Function gravaNumPed()

	Local cPedido := ""
	Local nOpc    :=PARAMIXB[1]
	lOCAL nGrava  :=PARAMIXB[2]

	If nOpc == 3 .AND. nGrava == 1

		SD1->(dbSetorder(1))
		if SD1->(dbseek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))

			cPedido := SD1->D1_PEDIDO

			SE2->(dbSetorder(6))

			if SE2->(dbseek(xFilial("SE2")+SD1->D1_FORNECE+SD1->D1_LOJA+SD1->D1_SERIE+SD1->D1_DOC))

				//Insere o numero do pedido nos titulos a pagar
				while SE2->(!Eof())	 					    .AND. ;
						SE2->E2_FILIAL 		== xFilial("SE2") 	.AND. ;
						SE2->E2_PREFIXO 	== SD1->D1_SERIE 	.AND. ;
						SE2->E2_NUM 		== SD1->D1_DOC	    .AND. ;
						SE2->E2_FORNECE 	== SD1->D1_FORNECE  .AND. ;
						SE2->E2_LOJA 		== SD1->D1_LOJA

					RecLock("SE2",.F.) // Trava o registro para atualização dos dados
					SE2->E2_NUMPED := cPedido
					MsUnlock()

					SE2->(dbskip())
				End
			Endif

		EndIf

	Endif
Return


//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} MT100TOK 
Valida a inclusão de NF

@author  Leandro Natan Bonette Santos
@since   05/12/2017
@return  lRet, valida a nota pode ou não ser incluída 

/*/
//-------------------------------------------------------------------------------------------
User Function MT100TOK()

	Local aAreaAtu := GetArea()
	Local aAreaSD1 := SD1->(GetArea())
	Local aAreaSF1 := SF1->(GetArea())

	Local aHeadSE2:= {}
	Local aColsSE2:= {}
	Local aHeadSEV:={}
	Local aColsSEV:={}

	Local nPParcela := 0
	Local nPVencto  := 0
	Local nPValor   := 0
	Local nPIRRF    := 0
	Local nPISS     := 0
	Local nPINSS    := 0
	Local nPPIS     := 0
	Local nPCOFINS  := 0
	Local nPCSLL    := 0
	Local nPSEST    := 0
	Local nPFETHAB  := 0
	Local nPFABOV	:= 0
	Local nPFACS    := 0
	Local nValor    := 0
	Local nVAbat    := 0
	Local nOp       := 0
	Local lOk       := .F.

	Local nI        := 0
	Local nIE2      := 0

	Local nDiasTitu := 0
	Local lRet 		:= .T.
	Local lBloqueio := .F.
	Local lUserLib   := __cUserId $ ("000000;" + GetMv("RIC_DTITLB",,"000000"))

	Local nA	    := 0

	Local nPosITEMCTA := 0
	Local nPosCO      := 0
	Local nPosTOTAL   := 0
	Local nPosPEDIDO  := 0
	Local nItem       := 0
	Local aSaldos     := {}
	Local dDTlim      := CTOD("  /  /    ")

	Local cCOIni      := PADR("4",TamSx3("AK5_CODIGO")[1]) //Contas orçamentárias a serem consideradas na validação
	Local cCOFim      := PADR("5",TamSx3("AK5_CODIGO")[1])
	Local p_RRWSLDPCO := AllTrim(GetMV("RR_WSLDPCO",,"1"))
	If funname()=='SPEDNFE' .or. funname()=='MATA920'
		return .t.
	endif
	/*
	if !Empty(cEspecie)

	endif
	*/

	// validação do preenchimento da espécie da nota fiscal de entrada
	if empty(alltrim(cEspecie))
		_cMsg := "O campo [Espécie] não foi preenchido no cabeçalho. Favor preeencher."
		Help("",1,"SEM ESPECIE - MT100TOK",,OemToAnsi(_cMsg),1,0)
		Return(.F.)
	endif

	nPosITEMCTA := aScan(aHeader,{|cColuna| AllTrim( cColuna[2] ) == "D1_ITEMCTA"})
	nPosCO      := aScan(aHeader,{|cColuna| AllTrim( cColuna[2] ) == "D1_CO"     })
	nPosTOTAL   := aScan(aHeader,{|cColuna| AllTrim( cColuna[2] ) == "D1_TOTAL"   })
	nPosPEDIDO  := aScan(aHeader,{|cColuna| AllTrim( cColuna[2] ) == "D1_PEDIDO"   })
	nItem       := aScan(aCols, {|x|!x[Len(x)] .and. !empty(x[nPosPedido])})

	//----------------------------------------------------------------------------------------------------------
	// AFSouza - Trava do PCO (Leandro Natan)
	//----------------------------------------------------------------------------------------------------------
	If cTipo == "N" .and. nItem == 0
	//NF de entrada normal - cTipo - Variável Private da Rotina


		For nI := 1 To Len(aCols)

			//Verifica se o registro não foi excluído
			If !aCols[nI, Len(aCols[nI])]

				cItemCTA := aCols[nI][nPosITEMCTA]
				cCO      := aCols[nI][nPosCO]
				nTotal   := aCols[nI][nPosTOTAL]

				If cCO >= cCOIni .AND. cCO < cCOFim //Somente valida se a conta orçamentária estiver dentro do range configurado

					aSaldos  := U_MPCO001(cCO, cItemCTA, dDataBase, nTotal)

					//Data limite para considerar orçamento anual
					dDTlim := Posicione("AK5",1,xFilial("AK5")+cCO,"AK5_XDTLIA")

					If p_RRWSLDPCO == "1"

						If aSaldos[5] == 0.0
							MsgAlert("Conta de Orçamento sem Saldo Orçado Anual - " + cCO+CRLF+"ATUALIZAÇÃO NÃO PERMITIDA!";
								+CRLF+"Orçado Acumulado   = "+Transform(aSaldos[1],"@E 999,999,999.99");
								+CRLF+"Efetuado Acumulado = "+Transform(aSaldos[2],"@E 999,999,999.99");
								+CRLF+"Orçado Mensal         = "+Transform(aSaldos[3],"@E 999,999,999.99");
								+CRLF+"Efetuado Mensal       = "+Transform(aSaldos[4],"@E 999,999,999.99");
								+CRLF+"Orçamento Anual      = "+Transform(aSaldos[5],"@E 999,999,999.99");
								+CRLF+"Verifique com a Gerência de Controladoria.","Atenção")
							lRet:=.F.
						ElseIf Iif(aSaldos[5] < 0.000, -1*aSaldos[5], aSaldos[5]) <  Iif(aSaldos[2] < 0.000, -1* aSaldos[2], aSaldos[2])
							MsgAlert("Conta de Orçamento com Saldo Insuficiente - " + cCO+CRLF+"ATUALIZAÇÃO NÃO PERMITIDA!";
								+CRLF+"Orçado Acumulado   = "+Transform(aSaldos[1],"@E 999,999,999.99");
								+CRLF+"Efetuado Acumulado = "+Transform(aSaldos[2],"@E 999,999,999.99");
								+CRLF+"Orçado Mensal         = "+Transform(aSaldos[3],"@E 999,999,999.99");
								+CRLF+"Efetuado Mensal       = "+Transform(aSaldos[4],"@E 999,999,999.99");
								+CRLF+"Orçamento Anual      = "+Transform(aSaldos[5],"@E 999,999,999.99");
								+CRLF+"Verifique com a Gerência de Controladoria.","Atenção")
							lRet:=.F.

						ElseIf !Empty(dDTlim) .and. dDTlim < dDataBase .OR. Empty(dDTlim)
							//           Orçado Acumulado, Efetuado Acumulado, Orçado Mensal, Efetuado Mensal, Orçamento Anual
							If aSaldos[3] == 0.0
								MsgAlert("Conta de Orçamento sem Saldo Orçado MENSAL - " + cCO+CRLF+"ATUALIZAÇÃO NÃO PERMITIDA!";
									+CRLF+"Orçado Acumulado   = "+Transform(aSaldos[1],"@E 999,999,999.99");
									+CRLF+"Efetuado Acumulado = "+Transform(aSaldos[2],"@E 999,999,999.99");
									+CRLF+"Orçado Mensal         = "+Transform(aSaldos[3],"@E 999,999,999.99");
									+CRLF+"Efetuado Mensal       = "+Transform(aSaldos[4],"@E 999,999,999.99");
									+CRLF+"Orçamento Anual      	= "+Transform(aSaldos[5],"@E 999,999,999.99");
									+CRLF+"Verifique com a Gerência de Controladoria.","Atenção")
								lRet:=.F.
							ElseIf Iif(aSaldos[3] < 0.000, -1* aSaldos[3], aSaldos[3]) <  Iif(aSaldos[4] < 0.000, -1*aSaldos[4], aSaldos[4])
								MsgAlert("Conta de Orçamento MENSAL com Saldo Insuficiente - " + cCO+CRLF+"ATUALIZAÇÃO NÃO PERMITIDA!";
									+CRLF+"Orçado Acumulado   = "+Transform(aSaldos[1],"@E 999,999,999.99");
									+CRLF+"Efetuado Acumulado = "+Transform(aSaldos[2],"@E 999,999,999.99");
									+CRLF+"Orçado Mensal         = "+Transform(aSaldos[3],"@E 999,999,999.99");
									+CRLF+"Efetuado Mensal       = "+Transform(aSaldos[4],"@E 999,999,999.99");
									+CRLF+"Orçamento Anual      = "+Transform(aSaldos[5],"@E 999,999,999.99");
									+CRLF+"Verifique com a Gerência de Controladoria.","Atenção")
								lRet:=.F.
							EndIf
						EndIf

					EndIf

				EndIf

			EndIf

		Next nI

		RestArea(aAreaSF1)
		RestArea(aAreaSD1)
		RestArea(aAreaAtu)


		If !lRet
			Return lRet
		EndIf

	EndIf
	//----------------------------------------------------------------------------------------------------------

	IF !IsInCallStack("A103DEVOL")

		aHeadSE2:= aClone(__aHeadSE2) //Array Public criado no ponto de entrada MT103SE2
		aColsSE2:= aClone(__aColsSE2) //Array Public criado no ponto de entrada MTCOLSE2

		nValor:= 0
		If Len(aHeadSE2) > 0

			nPParcela := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_PARCELA"})
			nPVencto  := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_VENCTO"})
			nPValor   := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_VALOR"})
			nPIRRF    := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_IRRF"})  //
			nPISS     := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_ISS"})        //
			nPINSS    := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_INSS"})     //
			nPPIS     := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_PIS"})   //
			nPCOFINS  := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_COFINS"})  //
			nPCSLL    := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_CSLL"})//
			nPSEST    := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_SEST"})
			nPFETHAB  := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_FETHAB"})
			nPFABOV	:= aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_FABOV"})
			nPFACS    := aScan(aHeadSE2,{|x| AllTrim(x[2])=="E2_FACS"})

			For nIE2:=1 To Len(aColsSE2)
				nValor:=nValor + (aColsSE2[nIE2,nPValor]- (aColsSE2[nIE2,nPIRRF]+aColsSE2[nIE2,nPISS]+aColsSE2[nIE2,nPINSS]+aColsSE2[nIE2,nPPIS] +aColsSE2[nIE2,nPCOFINS] + aColsSE2[nIE2,nPCSLL]))
			Next nIE2

		EndIf

		cMensagem:="Valor total da Fatura:"+chr(10)+chr(13)+chr(10)+chr(13)+"R$: "+AllTrim(Transform(nValor,"@E 999,999,999.99"))

		nOp:=Aviso("Valor Fatura",cMensagem,{"Sim","Nao"})

		lOk:= (nOp==1)


		If lOk
			//Bloqueio de Inclusão do título pela data do vencimento - Leandro Natan - CONSULTIR - leandro.natan@consultir.com.br
			nDiasTitu := GetMv("RIC_DTITU")

			For nA := 1 To LEN(aColsSE2)
				If( aColsSE2[nA][nPVencto] - Date() <= nDiasTitu )
					lBloqueio := .T.
				EndIf
			Next nA

			If lBloqueio .AND. !lUserLib
				lRet := U_AFIN014B(CA100FOR,CLOJA) //Bloqueio de Inclusão do Titulo
			EndIf

		EndIf

	Else
		lOk	:= .T.
		lRet:= .T.
	EndIf

	RestArea(aAreaAtu)
	RestArea(aAreaSD1)
	RestArea(aAreaSF1)

Return (lOk .AND. lRet)


//-------------------------------------------------------------------------------------------
/*/{Protheus.doc} MA103OPC 
Inclui novas opções no item do menu

@author  Rogerio C Lemos
@since   04/01/2018
@return  aRet, Array contendo dados do novo item do menu. 

/*/
//-------------------------------------------------------------------------------------------
User Function MA103OPC()

	Local aRet  := {}

	AAdd(aRet,{'Vincular PDF Documento', 'U_MCOM011A()', 0, 3})
	AAdd(aRet,{'Baixar PDF Documento'  , 'U_MCOM011B()', 0, 3})
	//OPÇÃO DE TESTE - AAdd(aRet,{'Envia PDF Vinculado'   , 'U_MCOM011C()', 0, 3})


Return aRet

user function MTA103MNU


	aAdd(aRotina,{OemToAnsi("Conhecimento TV"), "u_xDocument", 0 , 02, 0, nil})
return nil

user function xDocument

	
	Local nBack    := N

	MsDocument( "SF1", SF1->( Recno() ), 1 )
	

return nil
