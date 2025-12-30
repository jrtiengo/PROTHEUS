#Include "PROTHEUS.CH"
#Include "Totvs.ch"
#Include "Topconn.ch"
#Include "rwmake.ch"

/*/{Protheus.doc} xRelFunc3
Gera relatório de funcionários em Excel Demitidos 
@type function
@author Seu Nome
@since 10/10/2025
@version 1.0
/*/
User Function XRELFUN3()

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
	Local cDesRec			:= ""
	Local cDescrFu			:= ""
	Local cDesCC			:= ""
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
	cQuery += "     SRA.RA_CODFUNC, "
	cQuery += "     SRA.RA_CIC, "
	cQuery += "     SRA.RA_SEXO, "
	cQuery += "     SRA.RA_ADMISSA, "
	cQuery += "     SRA.RA_DEMISSA, "
	cQuery += "     SRG.RG_TIPORES, "
	cQuery += "     SRA.RA_AFASFGT, "
	cQuery += "     SRA.RA_TPDEFFI, "
	cQuery += "     SRA.RA_DEFIFIS, "
	cQuery += "     SRA.RA_CTPCD "
	cQuery += " FROM " + RetSqlName("SRA") + " SRA "
	cQuery += " LEFT JOIN " + RetSqlName("SRG") + " SRG "
	cQuery += "     ON SRG.RG_MAT = SRA.RA_MAT "
	cQuery += "    AND SRG.D_E_L_E_T_ = ' ' "
	cQuery += " WHERE SRA.D_E_L_E_T_ = ' ' "
	cQuery += "   AND SRA.RA_FILIAL >= '" + MV_PAR01 + "' "
	cQuery += "   AND SRA.RA_FILIAL <= '" + MV_PAR02 + "' "
	cQuery += "   AND SRA.RA_SITFOLH = 'D' "
	cQuery += "   AND SRA.RA_DEMISSA <> '' "
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
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "CPF", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Sexo", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Dt. Admissão", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Dt. Demissão", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Tipo de Demissão", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Desc. Tipo Demissão", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Codigo Afastamento", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Tipo. Deficiência", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Def. Física", 1, 1)
	oFWMsExcel:AddColumn("Funcionários", "Dados Funcionários", "Cota PCD?", 1, 1)

	Count To nTotal
	ProcRegua(nTotal)
	(cAlias)->(DbGoTop())

	While (cAlias)->(!Eof())

		//Descrição do tipo de rescição
		cDesRec		:= fDescRCC("S043",(cAlias)->RG_TIPORES,1,2,3,30)

		//Função
		cDescrFu 	:= fDesc('SRJ',(cAlias)->RA_CODFUNC,'RJ_DESC',TamSX3('RJ_DESC'),(cAlias)->RA_FILIAL)

		//Centro de Custo
		cDesCC 		:= fDesc("CTT",(cAlias)->RA_CC,"CTT_DESC01",,(cAlias)->RA_FILIAL)

		IncProc("Processando registros " + cValToChar(nConta) + " de " + cValToChar(nTotal) + "...")

		// AddRow com 38 valores (matching das 38 colunas)
		oFWMsExcel:AddRow("Funcionários", "Dados Funcionários", {;
			AllTrim((cAlias)->RA_FILIAL),;
			FWFilialName(cEmpAnt, (cAlias)->RA_FILIAL,1),;
			AllTrim((cAlias)->RA_MAT),;
			AllTrim((cAlias)->RA_NOME),;
			AllTrim((cAlias)->RA_CC),;
			AllTrim(cDesCC),;
			AllTrim((cAlias)->RA_CODFUNC),;
			AllTrim(cDescrFu),;
			AllTrim((cAlias)->RA_CIC),;
			AllTrim((cAlias)->RA_SEXO),;
			DtoC(StoD((cAlias)->RA_ADMISSA)),;
			DtoC(StoD((cAlias)->RA_DEMISSA)),;
			AllTrim((cAlias)->RG_TIPORES),;
			AllTrim((cDesRec)),;
			AllTrim((cAlias)->RA_AFASFGT),;
			AllTrim((cAlias)->RA_TPDEFFI),;
			AllTrim((cAlias)->RA_DEFIFIS),;
			AllTrim((cAlias)->RA_CTPCD);
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
	Local _cFunc	:= "XRELFUN3"
	Local _cPerg	:= PadR(_cFunc, 10)

	_aPar := { 	"R"		,;	//Tipo R para relatorio P para processo
	_cPerg	,;	//Nome do grupo de perguntas (SX1)
	Nil		,;	//cAlias (para Relatorio)
	Nil		,;	//aArray (para Relatorio)
	Nil		}	//Titulo (para Relatorio)

Return (_aPar)
