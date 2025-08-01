#Include "TOTVS.ch"
#Include "PROTHEUS.ch"
#Include "TOPCONN.ch"

/*/{Protheus.doc} xCTBAUC
Este programa tem como objetivo gerar automaticamente os Lançamentos contábeis para Documentos de entrada, Contas a Pagar, Contas a Receber
@type  Function
@author Tiengo Junior
@since 21/07/2025
@version version
@param 
    MV_PAR01 = Da Filial ?                   
    MV_PAR02 = Até a Filial ?                
    MV_PAR03 = Processo 1=Doc.Entrada ? 2=Titulos a pagar ? 3=Titulos a receber ?
    MV_PAR04 = Aglut. Lançamentos ?          
    MV_PAR05 = Mostra Lanç Contab ?       
/*/

User Function XCTBAUC()

	Local aArea         := FWGetArea()
	Local bProcess      := {|oSelf| fBusca(oSelf)}
	Local cPerg         := "XUCCTB01"
	Local cTitulo       := "SPM - Lançamentos Contabeis Off-Line"
	Local cDesc         := "Este programa tem como objetivo gerar automaticamente os Lançamentos contábeis para Documentos de entrada, Contas a Pagar, Contas a Receber."

	If ! IsBlind()
		tNewProcess():New( "XCTBAUC", cTitulo, bProcess, cDesc, cPerg )
	Endif

	FwRestArea(aArea)

Return()

//Consulta com base nos parametros informados
Static Function fBusca(oSelf)

	Local aArea             := fWGetArea()
	Local cQuery            := ''
	Local cAlias            := ''
	Local cLanPad           := ''
	Local lDigita			:= .F.
	Local lAglut			:= .F.
	Local cChave			:= ''
	Local cTipo				:= ''

	If MV_PAR03 == 1

		cQuery := "SELECT DISTINCT SD1.D1_FILIAL	FILIAL,          	                                    "
		cQuery += "                SD1.D1_PEDIDO 	NUM,                                                    "
		cQUery += "                SD1.D1_SERIE 	SERIE,                                                  "
		cQuery += "                SD1.D1_FORNECE 	FORCLI,                                                 "
		cQuery += "                SD1.D1_LOJA 		LOJA,                                                   "
		cQuery += "               'PARCELA'    		PARCELA                                          		"
		cQuery += "FROM " + RetSqlName("SD1") + " SD1 														"
		cQuery += "INNER JOIN " + RetSqlName("SC7") + " SC7 ON SC7.C7_FILIAL = SD1.D1_FILIAL 				"
		cQuery += "AND SC7.C7_NUM = SD1.D1_PEDIDO 															"
		cQuery += "AND SC7.C7_XRATSPM = 'S' 																"
		cQuery += "AND SC7.D_E_L_E_T_ = '' 																	"
		cQuery += "WHERE SD1.D_E_L_E_T_ = ''                                                                "
		cQuery += "AND SD1.D1_FILIAL >= '" + MV_PAR01 + "'                                                  "
		cQuery += "AND SD1.D1_FILIAL <= '" + MV_PAR02 + "'                                                  "
		cQuery += "AND EXISTS( 																				"
		cQuery += "	SELECT 1 FROM " + RetSqlName("SZ0") + " SZ0  											"
		cQuery += "		WHERE SZ0.Z0_NUMPED = SD1.D1_PEDIDO AND ROWNUM = 1 AND SZ0.D_E_L_E_T_ = ''   		"
		cQuery += "		AND SZ0.Z0_LA = '' )																"

		//Definir o LP
		cLanPad := 'UC1'

	Elseif MV_PAR03 == 2

		cQuery := "SELECT DISTINCT SE2.E2_FILORIG	FILIAL,                                                 "
		cQuery += "                SE2.E2_NUM 		NUM,                                                    "
		cQUery += "                SE2.E2_PREFIXO 	SERIE,                                                  "
		cQuery += "                SE2.E2_FORNECE 	FORCLI,                                                 "
		cQuery += "                SE2.E2_LOJA 		LOJA,                                                   "
		cQUery += "                SE2.E2_PARCELA 	PARCELA                                                 "
		cQuery += "FROM " + RetSqlName("SE2") + " SE2     	                                                "
		cQuery += "WHERE SE2.D_E_L_E_T_ = ''                                                                "
		cQuery += "AND SE2.E2_XRATSPM = 'S'                                                              	"
		cQuery += "AND SE2.E2_FILORIG >= '" + MV_PAR01 + "'                        							"
		cQuery += "AND SE2.E2_FILORIG <= '" + MV_PAR02 + "'                        							"
		cQuery += "AND EXISTS( 																				"
		cQuery += "	SELECT 1 FROM " + RetSqlName("SZ0") + " SZ0 											"
		cQuery += "		WHERE SZ0.Z0_NUMTIT = SE2.E2_PREFIXO || SE2.E2_NUM || SE2.E2_PARCELA 				"
		cQuery += "			AND ROWNUM = 1 AND SZ0.D_E_L_E_T_ = '' AND SZ0.Z0_LA = '' )  					"

		//Definir o LP
		cLanPad := 'UC2'

	Elseif MV_PAR03 == 3

		cQuery := "SELECT DISTINCT SE1.E1_FILORIG 	FILIAL,                                                 "
		cQuery += "                SE1.E1_NUM 		NUM,                                                    "
		cQUery += "                SE1.E1_PREFIXO 	SERIE,                                          	    "
		cQuery += "                SE1.E1_CLIENTE 	FORCLI,                                                 "
		cQuery += "                SE1.E1_LOJA 		LOJA,                                                   "
		cQUery += "                SE1.E1_PARCELA 	PARCELA                                                 "
		cQuery += "FROM " + RetSqlName("SE1") + " SE1                                                 	    "
		cQuery += "WHERE SE1.D_E_L_E_T_ = ''                                                                "
		cQuery += "AND SE1.E1_XRATSPM = 'S'                                                               	"
		cQuery += "AND SE1.E1_FILORIG >= '" + MV_PAR01 + "'                        							"
		cQuery += "AND SE1.E1_FILORIG <= '" + MV_PAR02 + "'                        							"
		cQuery += "AND EXISTS( 																				"
		cQuery += "	SELECT 1 FROM " + RetSqlName("SZ0") + " SZ0 											"
		cQuery += "		WHERE SZ0.Z0_NUMTIT = SE1.E1_PREFIXO || SE1.E1_NUM || SE1.E1_PARCELA 				"
		cQuery += "			AND ROWNUM = 1 AND SZ0.D_E_L_E_T_ = '' AND SZ0.Z0_LA = '' )	   					"

		//Definir o LP
		cLanPad := 'UC3'

	Endif

	cQuery := ChangeQuery(cQuery)
	cAlias := MPSysOpenQuery(cQuery)

	If (cAlias)->(EoF())
		If ! IsBlind()
			FWAlertWarning('Atenção não foram encontrados registros para contabilização ','Atenção')
		Endif
		Return()
	Endif

	lDigita := IIf(MV_PAR04 == 1,.T.,.F.)
	lAglut  := IIf(MV_PAR05 == 1,.T.,.F.)

	While ! (cAlias)->(EoF())

		If MV_PAR03 == 1
			cChave 	:= (cAlias)->FILIAL + (cAlias)->NUM
			cTipo 	:= '1'
		Else
			cChave  := (cAlias)->FILIAL + (cAlias)->SERIE + (cAlias)->NUM + (cAlias)->PARCELA
			cTipo 	:= '2'
		Endif

		fProcessa(cChave, cTipo, cLanPad, lDigita, lAglut)

		(cAlias)->(dbSkip())
	Enddo

	If Select(cAlias) > 0
		(cAlias)->(DbCloseArea())
	EndIf

	FwRestArea(aArea)

	If ! IsBlind()
		FWAlertInfo('Processamento finalizado!','Processamento')
	Endif

Return()

//Processa a contabilização por meio de funções padrões
Static Function fProcessa(cChave, cTipo, cLanPad, lDigita, lAglut)

	Local aArea             := FWGetArea()
	Local aAreaCT2          := CT2->(fWGetArea())
	Local cLote             := SuperGetMV("UC_LOTESZ0",.F.,"001SZ0")
	Local lHead             := .F.
	Local cCampoChv         := ''
	Local cArquivo			:= ''
	local nTotLanc  		:= 0

	DBSelectArea("SZ0")

	If cTipo == '1'
		SZ0->(dbSetOrder(1)) //Z0_FILIAL+Z0_NUMPED+Z0_ITEM
		cCampoChv 	:= 'Z0_NUMPED'
	Else
		SZ0->(dbSetOrder(3)) //Z0_FILIAL+Z0_NUMTIT
		cCampoChv 	:= 'Z0_NUMTIT'
		cChave 		:= PadR(cChave,  TamSX3(cCampoChv)[1] + 4, ' ' )
	Endif

	If SZ0->(MSSeek(cChave))

		While SZ0->(!EOF()) .AND. (SZ0->(Z0_FILIAL) + &cCampoChv) == cChave

			If ! lHead
				lHead   := .T.
				nHdlPrv := HeadProva(cLote,'XCTBAUC',subStr(cUsuario,7,6),@cArquivo)
			Endif

			nTotLanc += DetProva(nHdlPrv,cLanPad,"XCTBAUC",cLote)

			//Atualiza os campos de Flag da tabela SZ0
			If nTotLanc > 0
				If Reclock('SZ0',.F.)
					SZ0->Z0_DTLANC  := ddatabase
					SZ0->Z0_LA      := 'S'
					SZ0->(MSUnlock())
				Endif
			Endif

			SZ0->(dbSkip())
		EndDo

		If nTotLanc > 0
			RodaProva(nHdlPrv,nTotLanc)
			cA100Incl(cArquivo,nHdlPrv,3,cLote,lDigita,lAglut)
		Endif
	Endif

	SZ0->(DbCloseArea())

	FWRestArea(aArea)
	FwRestArea(aAreaCT2)

Return()
