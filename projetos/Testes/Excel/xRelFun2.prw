#Include "PROTHEUS.CH"
#Include "Totvs.ch"
#Include "Topconn.ch"
#Include "rwmake.ch"

/*/{Protheus.doc} xRelFunc2
Gera relatório de funcionários em Excel Admitidos 
@type function
@author Seu Nome
@since 10/10/2025
@version 1.0
/*/
User Function XRELFUN2()

	Local aPergs 		:= {}
	Local aWebAgent 	:= GetWebAgentInfo()
	Local lSchedule		:= FWGetRunSchedule()

	Private aResps		:= {}

	If lSchedule
		ImpRel(lSchedule)
	Else
		If Empty(aWebAgent[1])
			FWAlertWarning("É necessário a utilização do webagent para gerar o relatorio.","Atenção")
			Return()
		Endif

		// ParamBox para filtros
		aAdd(aPergs, {1, "Filial de"			, Space(TamSx3("RA_FILIAL")[1]), "", ".T.", "SM0", ".T.", 20, .F.})
		aAdd(aPergs, {1, "Filial até"			, Space(TamSx3("RA_FILIAL")[1]), "", ".T.", "SM0", ".T.", 20, .T.})

		If ParamBox(aPergs, "Parâmetros - Relatório Funcionários", @aResps)
			Processa({|| ImpRel(lSchedule) }, "Aguarde... #Processando")
		EndIf

	Endif

Return()

//-------------------------------------------------------------------
/*/{Protheus.doc} ImpRel
Processamento do relatório
@type function
@author Seu Nome
@since 10/10/2025
@version 1.0
/*/
//-------------------------------------------------------------------
Static Function ImpRel(lSchedule)

	Local cAlias 			:= GetNextAlias()
	Local cQuery 			:= ""
	Local nTotal 			:= 0
	Local nConta 			:= 0
	Local cArquivo    		:= ""
	Local cDescrCC			:= ""
	Local cDescrFu			:= ""
	Local cDescMun			:= ""
	Local cNomResp			:= ""
	Local cDescrInst		:= ""
	Local cDescDep			:= ""
	Local cMatResp			:= ""
	Local cEmpResp			:= ""
	Local cFilResp			:= ""
	Local cSindicato		:= ""
	Local cSitFol			:= ""
	Local cTpAfasta			:= ""
	Local cDirServer    	:= "/relatorios/"

	Private oFWMsExcel		:= Nil

	// Define caminho do arquivo conforme execução
	If lSchedule
		// Cria diretório se não existir
		If !ExistDir(cDirServer)
			MakeDir(cDirServer)
		EndIf
		cArquivo := cDirServer + "RelFuncionarios_" + DtoS(Date()) + "_" + StrTran(Time(), ":", "") + ".xml"
	Else
		cArquivo := GetTempPath() + "zFuncRel.xml"
	EndIf

	cQuery := " SELECT "
	cQuery += "     SRA.RA_FILIAL, "
	cQuery += "     SRA.RA_MAT, "
	cQuery += "     SRA.RA_NOME, "
	cQuery += "     SRA.RA_CC, "
	cQuery += "		SRA.RA_CODFUNC, "
	cQuery += "     SRA.RA_ADMISSA, "
	cQuery += "     SRA.RA_SITFOLH, "
	cQuery += "     SRA.RA_CIC, "
	cQuery += "     SRA.RA_ESTCIVI, "
	cQuery += "     SRA.RA_LOGRTP, "
	cQuery += "     SRA.RA_LOGRDSC, "
	cQuery += "     SRA.RA_LOGRNUM, "
	cQuery += "     SRA.RA_COMPLEM, "
	cQuery += "     SRA.RA_BAIRRO, "
	cQuery += "     SRA.RA_CODMUN, "
	cQuery += "     SRA.RA_UFCERT, "
	cQuery += "     SRA.RA_ESTADO, "
	cQuery += "     SRA.RA_CEP, "
	cQuery += "     SRA.RA_NASC, "
	cQuery += "     SRA.RA_SEXO, "
	cQuery += "     SRA.RA_GRINRAI, "
	cQuery += "     SRA.RA_CATFUNC, "
	cQuery += "     SRA.RA_TPDEFFI, "
	cQuery += "     SR8.R8_DATAINI, "
	cQuery += "     SR8.R8_TIPOAFA, "
	cQuery += "     SR8.R8_DATAFIM, "
	cQuery += "     SRA.RA_DEFIFIS, "
	cQuery += "     SRA.RA_DEPTO, "
	cQuery += "     SRA.RA_EMAIL, "
	cQuery += "     SRA.RA_SINDICA, "
	cQuery += "     SRA.RA_RACACOR, "
	cQuery += "     SRA.RA_BCDEPSA, "
	cQuery += "     SRA.RA_CTDEPSA, "
	cQuery += "     SRA.RA_MAE, "
	cQuery += "     SRA.RA_RG , "
	cQuery += "     SRA.RA_DTRGEXP, "
	cQuery += "     SRA.RA_RGUF, "
	cQuery += "     SRA.RA_RGORG, "
	cQuery += "     SRA.RA_PIS, "
	cQuery += "     SRA.RA_NUMCP, "
	cQuery += "     SRA.RA_SERCP, "
	cQuery += "     SRA.RA_UFCP "
	cQuery += " FROM " + RetSqlName("SRA") + " SRA "
	cQuery += " LEFT JOIN " + RetSqlName("SR8") + " SR8 "
	cQuery += "   ON SR8.R8_FILIAL = SRA.RA_FILIAL "
	cQuery += "  AND SR8.R8_MAT = SRA.RA_MAT "
	cQuery += "  AND SR8.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE SRA.D_E_L_E_T_ = ' ' "
	cQuery += "   AND SRA.RA_FILIAL >= '" + MV_PAR01 + "' "
	cQuery += "   AND SRA.RA_FILIAL <= '" + MV_PAR02 + "' "
	cQuery += "   AND SRA.RA_SITFOLH IN (' ', 'A', 'F')  "
	cQuery += " ORDER BY SRA.RA_FILIAL, SRA.RA_MAT "

	cQuery := ChangeQuery(cQuery)
	cAlias := MPSysOpenQuery(cQuery)

	If (cAlias)->(EoF())
		FWAlertWarning("Nenhuma Matricula foi encontrada!", "Atenção")
		Return()
	Endif

	// Cria objeto Excel
	oFWMsExcel := FWMSEXCEL():New()
	oFWMsExcel:AddworkSheet("Funcionários")

	// Tabela de Dados dos Funcionários
	oFWMsExcel:AddTable("Funcionários", "Dados Funcionários")

	// Define colunas
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Cod.Empresa", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Razão Social", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Matrícula", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Nome", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "C.Custo", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Desc. C.Custo", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Cód. Função", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Desc. Função", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Dt. Admissão", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Situação", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "CPF", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Estado Civil", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Tipo do endereço", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Endereço", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Número", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Complemento", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Bairro", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Cód. Município", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Município", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "UF Cert.", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Estado", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "CEP", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Dt. Nascimento", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Sexo", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Grau Instrução", 1, 1) //25
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Desc. Grau Inst.", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Cat. Func.", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Tp. Deficiência", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Dt. Ini. Afastamento", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Tp. Afastamento", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Dt. Fim Afastamento", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Def. Física", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Departamento", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Desc. Departamento", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Emp. Responsável", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Fil. Responsável", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Mat. Responsável", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Nome Responsável", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "E-mail", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Sindicato", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Rac. Cor", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Bco.Ag.D.Sal", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Cta.Dep.Sal.", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Nome da mãe", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "R.G.", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "D t.Emis.RG ", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "UF do RG ", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Org.Emissor", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "P.I.S. ", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Cart.Profis.", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Série Cart.", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "UF Cart.Prof", 1, 1)

	Count To nTotal
	ProcRegua(nTotal)
	(cAlias)->(DbGoTop())

	While (cAlias)->(!Eof())

		//Situação da Folha
		cSitFol 	:= fDesc("SX5","31"+(cAlias)->RA_SITFOLH,"X5_DESCRI",,(cAlias)->RA_FILIAL)

		//Tipos Afastamento
		cTpAfasta 	:= fDesc('RCM',(cAlias)->R8_TIPOAFA,'RCM_DESCRI',TamSX3('RCM_DESCRI'),(cAlias)->RA_FILIAL)

		//Centro de Custo
		cDescrCC 	:= fDesc("CTT",(cAlias)->RA_CC,"CTT_DESC01",,(cAlias)->RA_FILIAL)

		// Função
		cDescrFu 	:= fDesc('SRJ',(cAlias)->RA_CODFUNC,'RJ_DESC',TamSX3('RJ_DESC'),(cAlias)->RA_FILIAL)

		// Município
		CC2->(DbSetOrder(1)) //CC2_FILIAL+CC2_EST+CC2_CODMUN
		If CC2->(MSSeek(fwxFilial('CC2') + (cAlias)->RA_ESTADO + (cAlias)->RA_CODMUN))
			cDescMun := CC2->CC2_MUN
		EndIf

		// Departamento
		cDescDep := fDesc('SQB',(cAlias)->RA_DEPTO,'QB_DESCRIC',TamSX3('QB_DESCRIC'),(cAlias)->RA_FILIAL)
		cMatResp := fDesc('SQB',(cAlias)->RA_DEPTO,'QB_MATRESP',TamSX3('QB_MATRESP'),(cAlias)->RA_FILIAL)
		cEmpResp := fDesc('SQB',(cAlias)->RA_DEPTO,'QB_EMPRESP',TamSX3('QB_EMPRESP'),(cAlias)->RA_FILIAL)
		cFilResp := fDesc('SQB',(cAlias)->RA_DEPTO,'QB_FILRESP',TamSX3('QB_FILRESP'),(cAlias)->RA_FILIAL)

		// Responsável
		SRA->(DbSetOrder(1)) //RA_FILIAL+RA_MAT+RA_NOME
		If SRA->(MSSeek((cAlias)->RA_FILIAL + cMatResp))
			cNomResp := SRA->RA_NOME
		EndIf

		// Instituição
		cDescrInst := fDesc("SX5","26"+(cAlias)->RA_GRINRAI,"X5_DESCRI",,(cAlias)->RA_FILIAL)

		//Nome do sindicato
		cSindicato := fDesc("RCE",(cAlias)->RA_SINDICA,"RCE_DESCRI",,(cAlias)->RA_FILIAL)

		IncProc("Processando registros " + cValToChar(nConta) + " de " + cValToChar(nTotal) + "...")

		oFWMsExcel:AddRow("Funcionários", "Dados Funcionários", {;
			AllTrim((cAlias)->RA_FILIAL),;
			FWFilialName(),;
			AllTrim((cAlias)->RA_MAT),;
			AllTrim((cAlias)->RA_NOME),;
			AllTrim((cAlias)->RA_CC),;
			AllTrim(cDescrCC),;
			AllTrim((cAlias)->RA_CODFUNC),;
			AllTrim(cDescrFu),;
			DtoC(StoD((cAlias)->RA_ADMISSA)),;
			AllTrim(cSitFol),;
			AllTrim((cAlias)->RA_CIC),;
			AllTrim((cAlias)->RA_ESTCIVI),;
			AllTrim((cAlias)->RA_LOGRTP),;
			AllTrim((cAlias)->RA_LOGRDSC),;
			AllTrim((cAlias)->RA_LOGRNUM),;
			AllTrim((cAlias)->RA_COMPLEM),;
			AllTrim((cAlias)->RA_BAIRRO),;
			AllTrim((cAlias)->RA_CODMUN),;
			AllTrim(cDescMun),;
			AllTrim((cAlias)->RA_UFCERT),;
			AllTrim((cAlias)->RA_ESTADO),;
			AllTrim((cAlias)->RA_CEP),;
			DtoC(StoD((cAlias)->RA_NASC)),;
			AllTrim((cAlias)->RA_SEXO),;
			AllTrim((cAlias)->RA_GRINRAI),;
			AllTrim(cDescrInst),;
			AllTrim((cAlias)->RA_CATFUNC),;
			AllTrim((cAlias)->RA_TPDEFFI),;
			DtoC(StoD((cAlias)->R8_DATAINI)),;
			AllTrim(cTpAfasta),;
			DtoC(StoD((cAlias)->R8_DATAFIM)),;
			AllTrim((cAlias)->RA_DEFIFIS),;
			AllTrim((cAlias)->RA_DEPTO),;
			Alltrim(cDescDep),;
			AllTrim(cEmpResp),;
			AllTrim(cFilResp),;
			AllTrim(cMatResp),;
			AllTrim(cNomResp),;
			AllTrim((cAlias)->RA_EMAIL),;
			AllTrim(cSindicato),;
			AllTrim( IIF( AllTrim((cAlias)->RA_RACACOR) == "1", "Indígena", ;
			IIF( AllTrim((cAlias)->RA_RACACOR) == "2", "Branca", ;
			IIF( AllTrim((cAlias)->RA_RACACOR) == "4", "Negra", ;
			IIF( AllTrim((cAlias)->RA_RACACOR) == "6", "Amarela", ;
			IIF( AllTrim((cAlias)->RA_RACACOR) == "8", "Parda", "Não informado")))))),;
			AllTrim((cAlias)->RA_BCDEPSA),;
			AllTrim((cAlias)->RA_CTDEPSA),;
			AllTrim((cAlias)->RA_MAE),;
			AllTrim((cAlias)->RA_RG),;
			DtoC(StoD((cAlias)->RA_DTRGEXP)),;
			AllTrim((cAlias)->RA_RGUF),;
			AllTrim((cAlias)->RA_RGORG),;
			AllTrim((cAlias)->RA_PIS),;
			AllTrim((cAlias)->RA_NUMCP),;
			AllTrim((cAlias)->RA_SERCP),;
			AllTrim((cAlias)->RA_UFCP);
			})

		nConta++

		(cAlias)->(DbSkip())
	EndDo

	(cAlias)->(DbCloseArea())

	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cArquivo)

	If ! lSchedule
		oExcel := MsExcel():New()
		oExcel:WorkBooks:Open(cArquivo)
		oExcel:SetVisible(.T.)
		oExcel:Destroy()
	Else
		cPara 	 := SuperGetMV('EZ_MAILRH', .F., '')
		cAssunto := 'Lista de Funcionarios'
		cCorpo 	 := 'Lista de Funcionarios'
		aAnexos  := {}
		Aadd(aAnexos, cArquivo)
		u_xEnvMail(cPara, cAssunto, cCorpo, aAnexos)
	Endif

Return()

/*/{Protheus.doc} SchedDef
description Rotina para schedule
@type function
@version  v 1.0
@author Tiengo Junior
@since 3/21/2025
@return variant, return_description
/*/
Static Function SchedDef()

	Local _aPar 	:= {}		//array de retorno
	Local _cFunc	:= "XRELFUN2"
	Local _cPerg	:= PadR(_cFunc, 10)

	_aPar := { 	"R"		,;	//Tipo R para relatorio P para processo
	_cPerg	,;	//Nome do grupo de perguntas (SX1)
	Nil		,;	//cAlias (para Relatorio)
	Nil		,;	//aArray (para Relatorio)
	Nil		}	//Titulo (para Relatorio)

Return (_aPar)

