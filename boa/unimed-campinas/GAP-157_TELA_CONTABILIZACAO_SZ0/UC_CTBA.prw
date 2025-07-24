#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} UC_CTBA
Este programa tem como objetivo gerar automaticamente os Lançamentos contábeis para Documentos de entrada, Contas a Pagar, Contas a Receber
@type  Function
@author user
@since 21/07/2025
@version version
@param 
    MV_PAR01 = Da Filial ?                   
    MV_PAR02 = Até a Filial ?                
    MV_PAR03 = Processo                      
    MV_PAR04 = Aglut. Lançamentos ?          
    MV_PAR05 = Mostra Lanç Contab ?        
/*/

User Function UC_CTBA()

	Local aArea         := FWGetArea()
	Local bProcess      := {|oSelf| fBusca(oSelf)}
	Local cPerg         := "UCCTB01"
	Local cTitulo       := "SPM - Lançamentos Contabeis Off-Line"
	Local cDesc         := "Este programa tem como objetivo gerar automaticamente os Lançamentos contábeis para Documentos de entrada, Contas a Pagar, Contas a Receber."

	If ! IsBlind()

		tNewProcess():New( "UC_CTBA", cTitulo, bProcess, cDesc, cPerg )
	Endif

	FwRestArea(aArea)

Return()

Static Function fBusca(oSelf)

	Local aArea             := fWGetArea()
	Local cQuery            := ''
	Local cLanPad           := ''

	If MV_PAR03 == 1
		cQuery := "SELECT DISTINCT SD1.D1_FILIAL FIL,                                                       "
		cQuery += "                SD1.D1_NUM NUM,                                                          "
		cQUery += "                SD1.D1_PREFIXO SERIE,                                                    "
		cQuery += "                SD1.D1_FORNECE FORCLI,                                                   "
		cQuery += "                SD1.D1_LOJA LOJA                                                         "
		cQuery += "FROM" + RetSqlName("SD1") + "SD1"                                                        "
		cQuery += "INNER JOIN " + RetSqlName("SC7") + " SC7 ON SC7.C7_FILIAL = SD1.D1_FILIAL                "
		cQuery += "AND SC7.C7_NUM = SD1.D1_PEDIDO                                                           "
		cQuery += "AND SC7.D_E_L_E_T_   = ''                                                                "
		cQuery += "AND SC7.C7_XRATSPM   = 'S'                                                               "
		cQuery += "WHERE SD1.D_E_L_E_T_ = ''                                                                "
		cQuery += "AND SD1.D1_FILIAL >= '" + MV_PAR01 + "'                                                  "
		cQuery += "AND SD1.D1_FILIAL <= '" + MV_PAR02 + "'                                                  "

		cLanPad := 'UC1'

	Elseif MV_PAR03 == 2
		cQuery := "SELECT DISTINCT SE2.E2_FILIAL FIL,                                                       "
		cQuery += "                SE2.E2_NUM NUM,                                                          "
		cQUery += "                SE2.E2_PREFIXO SERIE,                                                    "
		cQuery += "                SE2.E2_FORNECE FORCLI,                                                   "
		cQuery += "                SE2.E2_LOJA LOJA                                                         "
		cQuery += "FROM" + RetSqlName("SE2") + "SE2"                                                        "
		cQuery += "WHERE SE2.D_E_L_E_T_ = ''                                                                "
		cQuery += "AND SE2.E2_XRATSPM   = 'S'                                                               "
		cQuery += "AND SE2.E2_FILIAL >= '" + MV_PAR01 + "'                                                  "
		cQuery += "AND SE2.E2_FILIAL <= '" + MV_PAR02 + "'                                                  "

		cLanPad := 'UC2'

	Elseif MV_PAR03 == 3
		cQuery := "SELECT DISTINCT SE1.E1_FILIAL FIL,                                                       "
		cQuery += "                SE1.E1_NUM NUM,                                                          "
		cQUery += "                SE1.E1_PREFIXO SERIE,                                                    "
		cQuery += "                SE1.E1_CLIENTE FORCLI,                                                   "
		cQuery += "                SE1.E1_LOJA LOJA                                                         "
		cQuery += "FROM" + RetSqlName("SE1") + "SE1"                                                        "
		cQuery += "WHERE SE1.D_E_L_E_T_ = ''                                                                "
		cQuery += "AND SE1.E1_XRATSPM   = 'S'                                                               "
		cQuery += "AND SE1.E1_FILIAL >= '" + MV_PAR01 + "'                                                  "
		cQuery += "AND SE1.E1_FILIAL <= '" + MV_PAR02 + "'                                                  "

		cLanPad := 'UC3'
	Endif                                                                                                   "

	cQuery := ChangeQuery(cQuery)
	MPSysOpenQuery(cQuery, 'TMP')

	If ! TMP->(EoF())
		FWAlertWarning('Atenção não foram encontrados registros para contabilização ','Atenção')
		Return()
	Endif

	lDigita := IIf(MV_PAR04  == 1,.T.,.F.)
	lAglut  := IIf(MV_PAR05  == 1,.T.,.F.)

	While ! TMP->(EoF())

		fProcessa(TMP->FIL,TMP->NUM,TMP->FORCLI,TMP->LOJA, cLanPad, lDigita, lAglut)

	Enddo

	FwRestArea(aArea)

Return()

//Execauto CTBA102
Static Function fProcessa(cFil, cNum, cForcli, cLoja, cLanPad, lDigita, lAglut)

	Local aArea             := FWGetArea()
	Local aAreaSD1          := SD1->(fWGetArea())
	Local aAreaSE2          := SE2->(fWGetArea())
	Local aAreaSE1          := SE1->(fWGetArea())
	Local cLote             := SuperGetMV("UC_LOTESZ0",.F.,"001SZ0")
	Local lHead             := .F.

	DBSelectArea("SZ0")
	SZ0->(dbSetOrder(1)) //Z0_FILIAL+Z0_NUMPED+Z0_ITEM

	If SZ0->(MSSeek(FWxFilial("SZ0")+SC7->C7_NUM))

		While SZ0->(!EOF()) .AND. SZ0->(Z0_FILIAL+Z0_NUMPED+Z0_FORNECE+Z0_LOJA) == cFil + cNum + cForcli + cLoja

			If ! lHead
				lHead   := .T.
				nHdlPrv := HeadProva(cLote,'UC_CTBA',subStr(cUsuario,7,6),@cArquivo)
			Endif

/*
			Debito    := SZ0->Z0
			Credito   := SZ0->Z0
			Historico := SZ0->Z0
			ItemD     := SZ0->Z0
			ItemC     := SZ0->Z0
			Valor     := SZ0->Z0_CL_VALOR
			CustoD    := SZ0->Z0
			CustoC    := SZ0->Z0
*/
			nTotLanc += DetProva(nHdlPrv,cLanPad,"UC_CTBA",cLote)

			If Reclock('SZ0',.F.)
				SZ0->Z0_DTLANC  := ddatabase
				SZ0->Z0_LA      := 'S'
				SZ0->(MSUnlock())
			Endif

		EndDo

		If  nTotLanc > 0
			RodaProva(nHdlPrv,nTotLanc)
			cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,lAglut,,,,@aFlagCTB)
			aFlagCTB := {}
		Endif
	Endif

	SZ0->(DbCloseArea())

	FWRestArea(aArea)
	FwRestArea(aAreaSD1)
	FwRestArea(aAreaSE2)
	FwRestArea(aAreaSE1)

Return()
