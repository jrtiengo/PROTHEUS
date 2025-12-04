#Include 'TOTVS.ch'
#Include 'TopConn.ch'
#Include 'Protheus.ch'

/*/{Protheus.doc} LOCA021S
Atentar no exemplo para os campos que devem ser retornados para query, 
manter os nomes mas podem alterar as posições. Verificar as variaveis usadas coomo parametros da query, elas não devem ser alteradas.
@type function
@version  
@author Tiengo Junior
@since 14/10/2025
@param
@See https://tdn.totvs.com/pages/releaseview.action?pageId=592556514
@return Lógico (.T., .F.)
/*/

User Function LOCA021S()

	Local _cQuery := ""
	Local _nX
	LOCAL LFATAND     := SUPERGETMV("MV_LOCX209" ,.F.,.T.)
	LOCAL LFATLOC     := SUPERGETMV("MV_LOCX210" ,.F.,.F.)

	_cQuery := " SELECT ZAG.R_E_C_N_O_ ZAGRECNO, FP1.R_E_C_N_O_ FP1RECNO, ZA0.R_E_C_N_O_ ZA0RECNO, SB1.R_E_C_N_O_ SB1RECNO, SA1.R_E_C_N_O_ SA1RECNO, ISNULL(ST9.R_E_C_N_O_,0) ST9RECNO, FPA_PROJET , FPA_CONPAG, FP1_OBRA "

	_CQUERY += ", CASE"
	If FPA->(ColumnPos("FPA_CLIFAT")) > 0
		_CQUERY += " WHEN FPA_CLIFAT <> ' ' THEN FPA_CLIFAT"
	ENDIF
	_CQUERY += " WHEN FP1_CLIDES <> ' ' THEN FP1_CLIDES"
	_CQUERY += " ELSE FP0_CLI"
	_CQUERY += " END CLIFAT,"
	_CQUERY += " CASE"
	If FPA->(ColumnPos("FPA_CLIFAT")) > 0
		_CQUERY += " WHEN FPA_LOJFAT <> ' ' THEN FPA_LOJFAT"
	endif
	_CQUERY += " WHEN FP1_LOJDES <> ' ' THEN FP1_LOJDES"
	_CQUERY += " ELSE FP0_LOJA"
	_CQUERY += " END LOJFAT,
	_CQUERY += "  CASE "
	If FPA->(ColumnPos("FPA_CLIFAT")) > 0
		_CQUERY += " WHEN FPA_CLIFAT <> ' ' THEN FPA_NOMFAT"
	endif
	_CQUERY += " WHEN FP1_CLIDES <> ' ' THEN FP1_NOMDES"
	_CQUERY += " ELSE A1_NOME"
	_CQUERY += " END NOMFAT "

	_cQuery += " FROM "+RETSQLNAME("FPA")+" ZAG (NOLOCK) "
	_cQuery += " JOIN "+RETSQLNAME("SB1")+" SB1 (NOLOCK) ON B1_FILIAL ='"+XFILIAL("SB1")+"' AND SB1.D_E_L_E_T_ = '' AND B1_COD = FPA_PRODUT "
	_cQuery += " LEFT  JOIN "+RETSQLNAME("ST9")+" ST9 (NOLOCK) ON T9_FILIAL ='"+XFILIAL("ST9")+"' AND ST9.D_E_L_E_T_ = '' AND T9_CODBEM = FPA_GRUA "
	_cQuery += " JOIN "+RETSQLNAME("FP0")+" ZA0 (NOLOCK) ON FP0_FILIAL='"+XFILIAL("FP0")+"' AND ZA0.D_E_L_E_T_ = '' AND FP0_PROJET = FPA_PROJET "
	_cQuery += " JOIN "+RETSQLNAME("FP1")+" FP1 (NOLOCK) ON FP1_FILIAL='"+XFILIAL("FP1")+"' AND FP1.D_E_L_E_T_  = ' ' AND FP1_PROJET = FPA_PROJET AND FP1_OBRA = FPA_OBRA "
	_cQuery += " JOIN "+RETSQLNAME("SA1")+" SA1 (NOLOCK) ON A1_FILIAL ='"+XFILIAL("SA1")+"' AND SA1.D_E_L_E_T_ = ' ' AND A1_COD = FP0_CLI AND A1_LOJA = FP0_LOJA "
	_cQuery += " INNER JOIN "+RETSQLNAME("FQ5")+" DTQ (NOLOCK) ON FQ5_FILIAL='"+XFILIAL("FQ5")+"' AND DTQ.D_E_L_E_T_ = ' ' AND FQ5_FILORI = FPA_FILIAL AND FQ5_VIAGEM = FPA_VIAGEM AND FQ5_AS = FPA_AS AND FQ5_STATUS = '6' "
	_cQuery += " WHERE FPA_FILIAL = '"+XFILIAL("FPA")+"' "
	_cQuery += " AND FPA_DTFIM <> ' '"
	_cQuery += " AND FPA_DTFIM BETWEEN '"+ DTOS(DPAR01)+"' AND '" + DTOS(DPAR02)+"'"
	IF ! LFATAND
		_cQuery += " AND (FPA_DNFRET = ' ' OR FPA_DNFRET >= '"+ DTOS(DPAR01)+"')"
	ENDIF
	_cQuery     += " AND ((FPA_ULTFAT < '" + DTOS(DPAR02) + "' AND (FPA_ULTFAT <= FPA_DTSCRT OR FPA_DTSCRT = '')) OR FPA_ULTFAT = ' ')"
	_cQuery += " AND FPA_NFREM <> ' '" // Tem que ter nota de Remessa
	IF FPA->(FIELDPOS("FPA_PDESC")) > 0
		_cQuery += " AND  FPA_PDESC < 100"
	ENDIF
	_cQuery += " AND (FPA_TIPOSE <> 'L' OR FPA_GRUA BETWEEN '" + CPAR07 + "' AND '" + CPAR08 +"') "
	_cQuery += " AND FPA_PROJET BETWEEN '" +CPAR09 + "' AND '" + CPAR10 + "' "

	If _lTem12 .and. _lTem13
		_cQuery += " AND FPA_PRODUT BETWEEN '"+ CPAR12 + "' AND '" + CPAR13 +"' "
	EndIF
	_cQuery += " AND FPA_GRUA BETWEEN '" + CPAR07 + "' AND '" + CPAR08 + "' "

	IF LFATLOC // Fatura somente Locação
		_cQuery += " AND FPA_TIPOSE = 'L' "
	ELSE
		_cQuery += " AND FPA_TIPOSE IN ('L','M','Z','O') "
	ENDIF

	//Projeto Blincast, para orcamentos que são de repasses e não estão aptos a faturar
    _cQuery += " AND (FPA_XREPAS <> '1' OR FPA_XSTSRE = '1') "

	IF LEN(APRJAS) > 0
		FOR _NX := 1 TO LEN(APRJAS)
			IF EMPTY(_CASS)
				_CASS := "'"   + APRJAS[_NX]
			ELSE
				_CASS += "','" + APRJAS[_NX]
			ENDIF
			IF _NX == LEN(APRJAS)
				_CASS += "'"
			ENDIF
		NEXT _NX
		_cQuery += " AND  FPA_AS IN (" +_CASS + ") "
	ENDIF
	_cQuery += " AND  ZAG.D_E_L_E_T_ = '' "
	_cQuery += " ORDER BY     FPA_PROJET, FPA_OBRA  "
	_cQuery := CHANGEQUERY(_cQuery)

	DBUSEAREA(.T. , "TOPCONN" , TCGENQRY(,,_cQuery) , "TMP" , .F. , .T.)

Return()
