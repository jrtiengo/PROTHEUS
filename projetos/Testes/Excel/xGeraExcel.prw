#Include "PROTHEUS.CH"
#Include "Totvs.ch"
#Include "Topconn.ch"
#Include "rwmake.ch"


//gera excel
User function xExcel()
 
	Local 	aPergs    	:= {}
	Private aResps  	:= {}
 

	//parambox para perguntas e filto processamento
	aAdd(aPergs, {1, "Produto de   "	, Space(9)		                        , "", ".T.", "SB1", ".T.", 20,  .F.})
	aAdd(aPergs, {1, "Produto ate  "	, Space(9)		                        , "", ".T.", "SB1", ".T.", 20,  .T.})


	if (ParamBox(aPergs,"Parâmetros", @aResps))
		Processa({|| ImpRel() },"Aguarde... #Processando")
	endif


Return()


/*/{Protheus.doc} ImpRel
Processamento relatorio
@type function
@version  1.0
@author Celso Rene
@since 18/07/2024
@return variant, return null
/*/
Static function ImpRel()

	Local _ncont := 0
	Local _nConta := 0
	Local cAlias  := ""
	Private oFWMsExcel
	Private oExcel
	Private lEnd    	:= .F.
	Private oProcess


	//query consulta
	_cQuery := " "
	_cQuery += " SELECT B1_COD, B1_DESC, B1_TIPO FROM SB1990 WHERE D_E_L_E_T_ = ' ' AND B1_COD BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "

	MsAguarde({|| cAlias:= MPSysOpenQuery (_cQuery)} ,"Aguarde! Obtendo os dados...")

	
	//saindo do programa caso nao exista registos para a consulta
	if select (cAlias) == 0
		MsgAlert("Conforme filtros especificados não foram encontrados registros!","# Registros")
		(cAlias)->(dbCloseArea())
		return()
	endif

	//sem contar
	//ProcRegua(0) 
	
	//contando registos
	dbSelectArea((cAlias))  
	Count To _ncont
	ProcRegua(_ncont) 
	(cAlias)->(dbGoTop())

	
	
	//objeto excel
	oFWMsExcel := FWMSEXCEL():New()
	oFWMsExcel:AddworkSheet("relprod")
	
	//colunas e tipos
	oFWMsExcel:AddTable("relprod","relprod")
	oFWMsExcel:AddColumn("relprod" ,"relprod","Cod. produto",1,1)
	oFWMsExcel:AddColumn("relprod" ,"relprod","Desc. produto",1,1)
	oFWMsExcel:AddColumn("relprod" ,"relprod","Tipo",1,1)

	Do While (cAlias)->(!EOF())

		oFWMsExcel:AddRow("relprod","relprod",{;
			(cAlias)->B1_COD,;
			(cAlias)->B1_DESC,;
			(cAlias)->B1_TIPO})

		_nConta++
		//IncProc()		
		IncProc( "Processando registros " + cValToChar(_nConta) + " de " + cValToChar(_ncont) + "...")

		(cAlias)->(DbSkip())

	EndDo
	
	//verifica a existencia do diretorio na estacao do usuario, cria se precisar
	If(ExistDir("C:\temp") == .F.)
		nRet := MakeDir("C:\temp")
	Endif

	oFWMsExcel:Activate()
	
	//processamento geracao arquivo
	MsAguarde({|| oFWMsExcel:GetXMLFile("C:\temp\relprod.xls")},"Aguarde! gerando arquivo...")
	
	//forcando abertura do arquivo
	ShellExecute("Open", "C:\temp\relprod.xls", " /k dir", "C:\", 1 )

	(cAlias)->(dbCloseArea())


Return()
