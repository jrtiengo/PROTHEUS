#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"        
#INCLUDE "TRM030.CH"
#INCLUDE "REPORT.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o       ³ TRM030   ³ Autor ³ Eduardo Ju              ³ Data ³ 30.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o    ³ Custo dos Treinamentos                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso          ³ TRM030                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data     ³ BOPS ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Carv.³31/07/2014³TPZWAO³AIncluido o fonte da 11 para a 12 e efetuada³±±
±±³             ³          ³      ³a limpeza.                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function TRM030()

Local oReport
Local aArea := GetArea()

Pergunte("TR030R",.F.)
oReport := ReportDef()
oReport:PrintDialog()	
RestArea( aArea )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportDef() ³ Autor ³ Eduardo Ju          ³ Data ³ 30.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Definicao do Componente de Impressao do Relatorio           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportDef()

Local oReport
Local oSection1
Local oSection2
Local aOrdem    := {}
Local cAliasQry := "" 
Local lRet:= .T.     

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:=TReport():New("TRM030",STR0009,"TR030R",{|oReport| PrintReport(oReport,cAliasQry)},STR0002+" "+STR0003)	//"Custo de Treinamento"#"Será impresso de acordo com os parametros solicitados pelo usuario"
//oReport:SetLandscape()	//Imprimir Somente Paisagem
oReport:SetTotalInLine(.F.) //Totaliza em linha
Pergunte("TR030R",.F.)

Aadd( aOrdem, STR0004)	// "Matricula"
Aadd( aOrdem, STR0005)	// "Centro de Custo"
Aadd( aOrdem, STR0006)	// "Nome" 
Aadd( aOrdem, STR0016) 	// "Data"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da celulas da secao do relatorio                                ³
//³TRCell():New                                                            ³
//³ExpO1 : Objeto TSection que a secao pertence                            ³
//³ExpC2 : Nome da celula do relatório. O SX3 será consultado              ³
//³ExpC3 : Nome da tabela de referencia da celula                          ³
//³ExpC4 : Titulo da celula                                                ³
//³        Default : X3Titulo()                                            ³
//³ExpC5 : Picture                                                         ³
//³        Default : X3_PICTURE                                            ³
//³ExpC6 : Tamanho                                                         ³
//³        Default : X3_TAMANHO                                            ³
//³ExpL7 : Informe se o tamanho esta em pixel                              ³
//³        Default : False                                                 ³
//³ExpB8 : Bloco de código para impressao.                                 ³
//³        Default : ExpC2                                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Primeira Secao:³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection1 := TRSection():New(oReport,STR0041,{"RA4","RA1","RA2","RA9","RA0","RA7"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)	
oSection1:SetTotalInLine(.F.) 

TRCell():New(oSection1,"RA4_CURSO","RA4",STR0031)		//Codigo do Curso    
TRCell():New(oSection1,"RA1_DESC","RA1","")			//Descricao do Curso
TRCell():New(oSection1,"RA4_SINONI","RA4",STR0032)		//Codigo do Sinonimo do Curso    
TRCell():New(oSection1,"RA9_DESCR","RA9","")			//Descricao do Sinonimo do Curso
TRCell():New(oSection1,"RA4_CALEND","RA4")				//Codigo do Calendario de Treinamento    
TRCell():New(oSection1,"RA2_DESC","RA2","")			//Descricao do Calendario de Treinamento    
TRCell():New(oSection1,"RA4_TURMA","RA4")				//Turma     
TRCell():New(oSection1,"RA4_DATAIN","RA4",STR0033)		//Periodo: Data Inicio do Curso
TRCell():New(oSection1,"RA4_DATAFI","RA4","",,,,,,,,.T.)		//Periodo: Data Final do Curso 
TRCell():New(oSection1,"RA4_ENTIDA","RA4",STR0034) 	//Codigo da Entidade do Curso 	
TRCell():New(oSection1,"RA0_DESC","RA0","")			//Descricao da Entidade do Curso 	
TRCell():New(oSection1,"RA2_INSTRU","RA2") 				//Codigo do Instrutor
TRCell():New(oSection1,"RA7_NOME","RA7")				//Nome do Instrutor
TRCell():New(oSection1,"RA4_HORAS","RA4")				//Horario
TRCell():New(oSection1,"RA2_DURACA","RA2")				//Duracao
TRCell():New(oSection1,"RA2_UNDURA","RA2","")			//Unidade de Duracao
TRCell():New(oSection1,"RA2_LOCAL","RA2")				//Local
oSection1:SetLineStyle()                                      

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Segunda Secao: ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection2 := TRSection():New(oSection1,STR0042,{"RA4","SRA"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)
oSection2:SetTotalInLine(.F.)

TRCell():New(oSection2,"RA4_MAT","RA4",STR0035)		//Matricula do Funcionario
TRCell():New(oSection2,"RA_NOME","SRA",STR0036)		//Nome do Funcionario
TRCell():New(oSection2,"RA4_VALOR","RA4",STR0037)		//Custo
TRCell():New(oSection2,"RA4_HORAS","RA4",STR0038)		//Horas 
TRCell():New(oSection2,"RA4_PRESEN","RA4",STR0039)		//Percentual de Presença
TRCell():New(oSection2,"RA4_NOTA","RA4",STR0040)		//Nota

TRFunction():New(oSection2:Cell("RA4_MAT"),/*cId*/,"COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
TRFunction():New(oSection2:Cell("RA4_VALOR"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)
TRFunction():New(oSection2:Cell("RA4_HORAS" ),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,/*lEndReport*/,/*lEndPage*/)

oSection2:SetTotalText({|| Alltrim(STR0029)}) //Total 

Return oReport

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportDef() ³ Autor ³ Eduardo Ju          ³ Data ³ 30.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Relatorio (Custo do Treinamento)               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PrintReport(oReport,cAliasQry)

Local cFil 		:= ""
Local cMat 		:= ""
Local cCc  		:= ""
Local cNom 		:= ""
Local cCur 		:= ""
Local cGru 		:= ""
Local cDep 		:= ""
Local cCar 		:= "" 
Local dPer		:= ""
Local cRel		:= ""
Local cSituacao := ""
Local nFerProg  := ""
Local cSitFol   := "" 
Local cOrder:= ""
Local nOrdem  	:= 	oReport:Section(1):GetOrder()
Local lQuery    := .F. 
Local i := 0
Local cSitQuery := ""

//-- Transforma parametros Range em expressao SQL
MakeSqlExpr("TR030R")
cAliasQry := GetNextAlias()

//+--------------------------------------------------------------+
//¦ Carregando variaveis MV_PAR?? para Variaveis do Sistema.     ¦
//+--------------------------------------------------------------+
cFil 		:= MV_PAR01
cMat 		:= MV_PAR02
cCc  		:= MV_PAR03
cNom 		:= MV_PAR04
cCur 		:= MV_PAR05
cGru 		:= MV_PAR06
cDep 		:= MV_PAR07
cCar 		:= MV_PAR08
dPer		:= MV_PAR09
cRel		:= MV_PAR10
cSituacao 	:= MV_PAR11
nFerProg  	:= MV_PAR12

	//-- Filtragem do relatório
	//-- Query do relatório da secao 1
	lQuery := .T.
	oReport:Section(1):BeginQuery()	
	
	If nOrdem == 1 		// Matricula 
		cOrder := "%RA4_FILIAL,RA4_CURSO,RA4_CALEND,RA4_TURMA,RA4_MAT%"
	ElseIf nOrdem == 2	// Centro de Custo + Matricula
		cOrder := "%RA4_FILIAL,RA_CC,RA4_CURSO,RA4_CALEND,RA4_TURMA,RA4_MAT%"
	ElseIf nOrdem == 3	// Nome	
		cOrder := "%RA4_FILIAL,RA4_CURSO,RA4_CALEND,RA4_TURMA,RA_NOME%"
	ElseIf nOrdem == 4	// Data
		cOrder := "%RA4_FILIAL,RA4_DATAIN,RA4_CURSO,RA4_CALEND,RA4_TURMA,RA4_MAT%"	
	EndIf
    
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Tratamento da Filial para Ambiente Top                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cFilRA1 := "% AND RA1.RA1_FILIAL = " + IIf( Empty(xFilial("RA1")), "'" + Space(FWGETTAMFILIAL) + "'", "RA4.RA4_FILIAL") + "%"
	cFilRA2 := "% AND RA2.RA2_FILIAL = " + IIf( Empty(xFilial("RA2")), "'" + Space(FWGETTAMFILIAL) + "'", "RA4.RA4_FILIAL") + "%"
	cFilRA9 := "% AND RA9.RA9_FILIAL = " + IIf( Empty(xFilial("RA9")), "'" + Space(FWGETTAMFILIAL) + "'", "RA4.RA4_FILIAL") + "%"	
	cFilRA0 := "% AND RA0.RA0_FILIAL = " + IIf( Empty(xFilial("RA0")), "'" + Space(FWGETTAMFILIAL) + "'", "RA4.RA4_FILIAL") + "%"
	cFilRA7 := "% AND RA7.RA7_FILIAL = " + IIf( Empty(xFilial("RA7")), "'" + Space(FWGETTAMFILIAL) + "'", "RA2.RA2_FILIAL") + "%"
	cFilSRA := "% AND SRA.RA_FILIAL  = " + IIf( Empty(xFilial("SRA")), "'" + Space(FWGETTAMFILIAL) + "'", "RA4.RA4_FILIAL") + "%"
	cFilSQ3 := "% AND SQ3.Q3_FILIAL  = " + IIf( Empty(xFilial("SQ3")), "'" + Space(FWGETTAMFILIAL) + "'", "SRA.RA_FILIAL" ) + "%"

	BeginSql Alias cAliasQry
		SELECT 	RA4_CURSO,RA1_DESC,RA4_SINONI,RA9_DESCR,RA4_CALEND,RA2_DESC,RA4_TURMA,RA4_DATAIN,RA4_DATAFI,
				RA4_ENTIDA,RA0_DESC,RA2_INSTRU,RA7_NOME,RA4_HORAS,RA2_DURACA,RA2_UNDURA,RA2_LOCAL,RA4_VALOR,
				RA4_HORAS,RA4_PRESEN,RA4_NOTA,RA4_MAT,RA_NOME,Q3_GRUPO,Q3_DEPTO,Q3_CARGO,RA_SITFOLH, RA_FILIAL,
				RA_MAT, RA_ADMISSA, RA_DEMISSA				 
		FROM 	%table:RA4% RA4          
		LEFT JOIN %table:RA1% RA1
			ON RA1_CURSO = RA4_CURSO
			AND RA1.%NotDel%
			%exp:cFilRA1%
		LEFT JOIN %table:RA2% RA2
			ON 	RA2_CALEND = RA4_CALEND
			AND RA2_CURSO = RA4_CURSO
			AND RA2_TURMA = RA4_TURMA
			AND RA2.%NotDel%
			%exp:cFilRA2%
		LEFT JOIN %table:RA9% RA9
			ON RA9_SINONI   = RA4_SINONI
			AND RA9.%NotDel%
			%exp:cFilRA9%
		LEFT JOIN %table:RA0% RA0
			ON RA0_ENTIDA = RA4_ENTIDA
			AND RA0.%NotDel%  
			%exp:cFilRA0%		
		LEFT JOIN %table:RA7% RA7
			ON  RA7_INSTRU = RA2_INSTRU
			AND RA7.%NotDel%  
			%exp:cFilRA7%
		LEFT JOIN %table:SRA% SRA
			ON RA_MAT = RA4_MAT
			AND SRA.%NotDel%  
			%exp:cFilSRA%
		LEFT JOIN %table:SQ3% SQ3
			ON Q3_CARGO = RA_CARGO
			AND SQ3.%NotDel%			 								
			%exp:cFilSQ3%
		WHERE RA4.%NotDel%							
		ORDER BY %Exp:cOrder%                 		
	EndSql
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Metodo EndQuery ( Classe TRSection )                                    ³
	//³Prepara o relatório para executar o Embedded SQL.                       ³
	//³ExpA1 : Array com os parametros do tipo Range                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):EndQuery({cFil,cMat,cCc,cNom,cCur,cGru,cDep,cCar,dPer})	//*Array com os parametros do tipo Range*
	
	//-- Inicio da impressao do fluxo do relatório
	oReport:SetMeter(RA4->(LastRec()))

	//-- Utiliza a query do Pai
	oReport:Section(1):Section(1):SetParentQuery()
	oReport:Section(1):Section(1):SetParentFilter( { |cParam| (cAliasQry)->RA4_CALEND + (cAliasQry)->RA4_CURSO + (cAliasQry)->RA4_TURMA  == cParam },{ || (cAliasQry)->RA4_CALEND + (cAliasQry)->RA4_CURSO + (cAliasQry)->RA4_TURMA })
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Impressao do Relatorio Sintetico ou Analitico    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If	cRel == 1	// Sintetico
	   	oReport:Section(1):Section(1):Hide()
	   	oReport:Section(1):Section(1):SetTotalInLine(.T.)
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Situacao do Funcionario ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
	For i:= 1 to Len(cSituacao)
		cSitQuery += "'"+Subs(cSituacao,i,1)+"'"
		If ( i+1 ) <= Len(cSituacao)
			cSitQuery += "," 
		Endif
	Next i     
	If nFerProg = 1
		cSitQuery += ",'P'" 
	EndIf

	oReport:Section(1):Section(1):SetLineCondition({|| TrmSitFol() $ cSitQuery})
	oReport:Section(1):Print()	 	
	
Return Nil                    