#Include 'Protheus.ch'
#Include 'TopConn.ch'
#Include "Totvs.ch"
#Include 'parmtype.ch'
#INCLUDE "Rwmake.ch"

/*/{Protheus.doc} SIRR006
Relat�rio de atestados de sa�de ocupacional.
@type function
@author Mauro Silva
@since 21/07/2021
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function SIRR006()

	Private cPerg	:= "SIRR006"+Space(3)
	Private oReport

	If !Pergunte(cPerg,.T.)
		Return()
	EndIf

	ReportDef()
	oReport:PrintDialog()

Return()



Static Function ReportDef()

    // Local oBreak1 	:= Nil
	Local oSctD1 	:= Nil
    
	
	oReport := TReport():New("SIRR006","Relat�rio de atestados de sa�de ocupacional.",cPerg,{|oReport| PrintReport(oReport)},"Lista de Atestados")
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	//oReport:SetPortrait()
	oReport:SetLandscape(.T.)

	//Criando a se��o de dados
	oSctD1 := TRSection():New(	oReport,;		//Objeto TReport que a se��o pertence
	"Cabecalho",;		//Descri��o da se��o
	{"QRY1"})		//Tabelas utilizadas, a primeira ser� considerada como principal da se��o
	
	oSctD1:SetCellBorder("ALL",,, .T.)
	// oSctD1:SetCellBorder("RIGHT")
	// oSctD1:SetCellBorder("LEFT")

	oSctD1:SetTotalInLine(.F.)  //Define se os totalizadores ser�o impressos em linha ou coluna. .F.=Coluna; .T.=Linha

	// Colunas do relat�rio
    TRCell():New(oSctD1, "MATRICULA"	, "QRY1", "Matricula"	, X3Picture("RC8_MAT")		,TamSX3("RC8_MAT")[1] + 2,,,"LEFT",,"CENTER" )
    TRCell():New(oSctD1, "NOME"		    , "QRY1", "Nome"		, X3Picture("RA_NOME")		,TamSX3("RA_NOME")[1] + 2,,,"LEFT",,"CENTER" )
    
	
	oSctD2 := TRSection():New(	oReport,;		//Objeto TReport que a se��o pertence
	"Cabecalho",;		//Descri��o da se��o
	{"QRY2"})		//Tabelas utilizadas, a primeira ser� considerada como principal da se��o
	
	oSctD2:SetTotalInLine(.F.)  //Define se os totalizadores ser�o impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	TRCell():New(oSctD2, "EMISSAO"		, "QRY2", "Emissao"		, X3Picture("RC8_DATA") 	,TamSX3("RC8_DATA")[1] + 2,,,"LEFT",,"CENTER" )
	TRCell():New(oSctD2, "TIPO"			, "QRY2", "Tipo"		, X3Picture("RC8_TIPOEX")	,TamSX3("RC8_TIPOEX")[1] + 2,,,"LEFT",,"CENTER" )

	// Definindo a quebra
	oBreak1 := TRBreak():New(oSctD1,{|| QRY1->(MATRICULA) },{|| "Matricula" })
	oSctD1:SetHeaderBreak(.T.)	

Return()



/*/{Protheus.doc} PrintReport
Static respons�vel por pegar os dados para gerar a lista.
@type function
@author Mauro Silva
@since 21/07/2021
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function PrintReport(oReport)

    Local cQuery    := ""
    Local oSctD1 	:= Nil
	Local oSctD2 	:= Nil
 
	cQuery := " SELECT DISTINCT RC8_MAT AS MATRICULA, RA_NOME AS NOME "
    cQuery += " FROM "+ RETSQLNAME("RC8") +" RC8, "+ RETSQLNAME("SRA") +" SRA "
    cQuery += " WHERE RC8.RC8_FILIAL = '"+ xFilial("RC8") +"' "
	cQuery += " AND RC8.RC8_MAT BETWEEN '"+ MV_PAR01 +"' AND '"+ MV_PAR02 +"' "
	cQuery += " AND SRA.RA_FILIAL = RC8.RC8_FILIAL  "
	cQuery += " AND SRA.RA_MAT = RC8.RC8_MAT  "
	If MV_PAR03 == 2 // N�o mostra demitidos.
		cQuery += " AND SRA.RA_SITFOLH <> 'D' "
	EndIf
    cQuery += " AND RC8.D_E_L_E_T_ <> '*' "
    cQuery += " AND SRA.D_E_L_E_T_ <> '*' "

    If Select("QRY1") > 0
		Dbselectarea("QRY1")
		QRY1->(DbClosearea())
	EndIf

	TcQuery cQuery New Alias "QRY1"

    //Pegando as se��es do relat�rio
	oSctD1 := oReport:Section(1)
	oSctD2 := oReport:Section(2)

	//inicializo a primeira sessao.
	oSctD1:Init()
    QRY1->(DbGoTop())
	Do While !QRY1->(Eof())

		oSctD1:PrintLine()

		cQuery := " SELECT RC8_DATA AS EMISSAO , RC8_TIPOEX AS TIPO "
		cQuery += " FROM "+ RETSQLNAME("RC8") +" RC8 "
		cQuery += " WHERE RC8.RC8_MAT = '"+ QRY1->MATRICULA +"' "
		cQuery += " AND RC8.D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY RC8.RC8_DATA "

		If Select("QRY2") > 0
			Dbselectarea("QRY2")
			QRY2->(DbClosearea())
		EndIf

		TcQuery cQuery New Alias "QRY2"

		TCSetField("QRY2", "EMISSAO", "D")

		//inicializo a segunda sessao.
		oSctD2:Init()
		QRY2->(DbGoTop())
		Do While !QRY2->(Eof())

			oSctD2:PrintLine()

			QRY2->(DbSkip())
		EndDo

		oSctD2:Finish()
		QRY2->(DbCloseArea())

		QRY1->(DbSkip())
	EndDo

    oSctD1:Finish()
	QRY1->(DbCloseArea())

Return()
