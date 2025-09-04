//Função para enviar em massa os cadastros
User Function IntUsrJob()

	Local cQuery		:= ""       as Character
	Local cAlias        := ""       as Character

	RPCSetEnv("03" , "0101",,,"GPE",,,,,,)

	//Query para trazer os tecnicos pela SRA para enviar ao TracOS
	cQuery := " SELECT  SRA.RA_NOME, 												"
	cQuery += "			SRA.RA_EMAIL, 												"
	cQuery += "			SRA.R_E_C_N_O_												"
	cQuery += "	FROM "+ RetSqlName("SRA") +" SRA                                    "
	cQuery += "	WHERE SRA.D_E_L_E_T_ = ''                                           "
	cQuery += "	  AND SRA.RA_FILIAL = '0101'              							"
	cQuery += "   AND SRA.RA_SITFOLH IN (' ', 'A', 'F')                          	"
	cQuery += "	  AND SRA.RA_MSBLQL <> '1'                                          "
	cQuery += "   AND SRA.RA_XIDTRAC = '' <>										"

	cQuery := ChangeQuery(cQuery)
	cAlias := MPSysOpenQuery(cQuery)

	If (cAlias)->(EoF())
		ConOut('Nenhum registro encontrado na consulta')
		Return()
	EndIf

	While ! (cAlias)->(EoF())

		SRA->(DbGoTo((cAlias)->R_E_C_N_O_))

		U_IntUsr()

		(cAlias)->(dbSkip())
	EndDo

	RpcClearEnv()

Return()

//Função para enviar em massa os cadastros
User Function IntAtvJob()

	Local cQuery		:= ""       as Character
	Local cAlias        := ""       as Character

	RPCSetEnv("03" , "0101",,,"GPE",,,,,,)

	//Query para trazer os tecnicos pela ST9 para enviar ao TracOS
	cQuery := " SELECT  ST9.CODBEM, 												"
	cQuery += "			ST9.R_E_C_N_O_												"
	cQuery += "	FROM "+ RetSqlName("ST9") +" ST9                                    "
	cQuery += "	WHERE ST9.D_E_L_E_T_ = ''                                           "

	cQuery := ChangeQuery(cQuery)
	cAlias := MPSysOpenQuery(cQuery)

	If (cAlias)->(EoF())
		ConOut('Nenhum registro encontrado na consulta')
		Return()
	EndIf

	While ! (cAlias)->(EoF())

		ST9->(DbGoTo((cAlias)->R_E_C_N_O_))

		U_IntUsr()

		(cAlias)->(dbSkip())
	EndDo

	RpcClearEnv()

Return()

//Função para enviar em massa os cadastros
User Function IntCliJob()

	Local cQuery		:= ""       as Character
	Local cAlias        := ""       as Character

	RPCSetEnv("03" , "0101",,,"GPE",,,,,,)

	//Query para trazer os locais pela SA1 para enviar ao TracOS
	cQuery := " SELECT  SA1.A1_COD, 												"
	cQuery += "			SA1.A1_LOJA, 												"
	cQuery += "			SA1.R_E_C_N_O_												"
	cQuery += "	FROM "+ RetSqlName("SA1") +" SA1                                    "
	cQuery += "	WHERE SA1.D_E_L_E_T_ = ''                                           "
	cQuery += "	  AND SRA.RA_MSBLQL <> '1'                                          "

	cQuery := ChangeQuery(cQuery)
	cAlias := MPSysOpenQuery(cQuery)

	If (cAlias)->(EoF())
		ConOut('Nenhum registro encontrado na consulta')
		Return()
	EndIf

	While ! (cAlias)->(EoF())

		SA1->(DbGoTo((cAlias)->R_E_C_N_O_))

		U_IntUsr()

		(cAlias)->(dbSkip())
	EndDo

	RpcClearEnv()

Return()
