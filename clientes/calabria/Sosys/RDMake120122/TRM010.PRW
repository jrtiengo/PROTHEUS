#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"  
#INCLUDE "TRM010.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o       ³ TRM010   ³ Autor ³ Eduardo Ju              ³ Data ³ 19.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o    ³ Lista de Presenca                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso          ³ TRM010                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data     ³ BOPS ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Carv.³31/07/2014³TPZWAO³AIncluido o fonte da 11 para a 12 e efetuada³±±
±±³             ³          ³      ³a limpeza.                                  ³±±
±±³Isabel N.    ³22/06/2017³DRHPONTP-736³Alterada query para realizar LEFT JOIN³±±
±±³             ³          ³            ³entre tabelas SQ3 e SQ0.              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function TRM010()

Local oReport
Local aArea := GetArea()

Pergunte("TRR030",.F.)
oReport := ReportDef()
oReport:PrintDialog()
RestArea( aArea )
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportDef() ³ Autor ³ Eduardo Ju          ³ Data ³ 16.05.06 ³±±
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
Local cAliasQry := GetNextAlias()
//Private cCargo

oReport := TReport():New("TRM010",OemToAnsi(STR0001),"TRR030",{|oReport| PrintReport(oReport,cAliasQry)},OemToAnsi(STR0046)+" - "+OemToAnsi(STR0002)+" "+OemToAnsi(STR0003))
	//"Lista de Presença"###"Emite Lista de Presenca para os Treinamentos."###"Será impresso de acordo com os parametros solicitados pelo usuario"
oReport:SetLandscape()	//Imprimir Somente Paisagem
oReport:SetTotalInLine(.F.) 
Pergunte("TRR030",.F.)

Aadd( aOrdem, STR0004)	// "Nome"
Aadd( aOrdem, STR0005)	// "Matricula"

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Primeira Secao: Cabecalho				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
oSection1 := TRSection():New(oReport,OemToAnsi(STR0034),{"RA3","RA2","RA1","RA7","RA9"},aOrdem) 	//"Curso"
oSection1:SetTotalInLine(.F.)  
oSection1:SetHeaderBreak(.T.)
oSection1:SetPageBreak(.T.)

TRCell():New(oSection1,"RA3_CALEND","RA3",STR0033,,25,.T.)	//Codigo do Calendario 
TRCell():New(oSection1,"RA2_DESC","RA2","")	   			//Descricado do Calendario
TRCell():New(oSection1,"RA3_CURSO","RA3",STR0034,,20,.T.)	//Codigo do Curso
TRCell():New(oSection1,"RA1_DESC","RA1","")	   			//Descricao do Curso 
TRCell():New(oSection1,"RA2_SINON","RA2",STR0037,,20,.T.)	//Sinonimo do Curso
TRCell():New(oSection1,"RA9_DESCR","RA9","")  	  			//Descricao do Sinonimo do Curso  
TRCell():New(oSection1,"RA3_TURMA","RA3",STR0035,,20,.T.)	//Turma
TRCell():New(oSection1,"RA2_INSTRU","RA2",STR0036,,20,.T.)	//Codigo do Instrutor
TRCell():New(oSection1,"RA7_NOME","RA7","") 	  			//Nome do Instrutor
TRCell():New(oSection1,"RA2_DATAIN","RA2",STR0038)			//Periodo: Data Inicio do Curso
TRCell():New(oSection1,"RA2_DATAFI","RA2","") 	   			//Periodo: Data Final do Curso 
TRCell():New(oSection1,"RA2_HORARI","RA2",STR0040)			//Horario
TRCell():New(oSection1,"RA2_LOCAL","RA2",STR0041) 			//Local

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Segunda Secao: Impressao dos Funcionarios ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection2 := TRSection():New(oSection1,OemToAnsi(STR0047),{"RA3","SRA","SQ3","SQ0","SQB"})	//"Relacao dos Participantes"
oSection2:SetTotalInLine(.F.)  
oSection2:SetHeaderBreak(.T.)
oSection2:SetLeftMargin(2)	//Identacao da Secao

TRCell():New(oSection2,"RA_FILIAL","SRA",STR0043)	//Filial
TRCell():New(oSection2,"RA3_MAT","RA3",STR0044)	//Matricula do Funcionario 
TRCell():New(oSection2,"RA_NOME","SRA")				//Nome do Funcionario
TRCell():New(oSection2,"VISTO"," " ,STR0042,/*Picture*/,10          ,/*lPixel*/, {|| '__________' } )	//"Visto"
TRCell():New(oSection2,"RA3_RESERV","RA3",STR0030,)	//Status da Reserva (Reservado) 
TRCell():New(oSection2,"Q3_GRUPO","SQ3")			//Codigo do Grupo 
TRCell():New(oSection2,"Q0_DESCRIC","SQ0","")		//Descricao do Grupo 
TRCell():New(oSection2,"Q3_DEPTO","SQ3",STR0031)	//Codigo do Depto
TRCell():New(oSection2,"QB_DESCRIC","SQB","")		//Descricao do Depto 
TRCell():New(oSection2,"Q3_CARGO","SQ3",STR0032)	//Cargo:= fGetCargo(SRA->RA_MAT)
TRCell():New(oSection2,"Q3_DESCSUM","SQ3","")		//Descricao do Cargo  

TRFunction():New(oSection2:Cell("RA3_MAT"),/*cId*/,"COUNT",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
oSection2:SetTotalText(OemToAnsi(STR0045))

Return oReport

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportDef() ³ Autor ³ Eduardo Ju          ³ Data ³ 19.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Relatorio (Lista de Presenca)                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PrintReport(oReport,cAliasQry)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local cFil 		:= ""
Local cInicio 	:= ""
Local cFim    	:= ""
Local cCalend	:= ""
Local cCurso	:= ""
Local cTurma	:= ""
Local cGrupo 	:= ""
Local cDepto	:= ""
Local cCC		:= ""
Local nOrdem  	:= osection1:GetOrder()
Local nImprVias	:= 0
Local lQuery    := .F. 
Local cExpressao:= ""
Local cExpress2 := ""
Local cSelecao	:= ""		
Local cFilSRA 	:= ""
Local i			:= 0
Local cSitQuery := ""
Local cOrder	:= ""

//+--------------------------------------------------------------+
//¦ Carregando variaveis MV_PAR?? para Variaveis do Sistema.     ¦
//+--------------------------------------------------------------+
Local cFilDe 	:= If(!Empty(MV_PAR01),MV_PAR01, Space(FWGETTAMFILIAL))
Local cFilAte	:= If(!Empty(MV_PAR02),MV_PAR02, Replicate("Z", FWGETTAMFILIAL))
Local cMatDe 	:= If(!Empty(MV_PAR03),MV_PAR03, Space(GetSx3Cache("RA_MAT", "X3_TAMANHO" )) )
Local cMatAte	:= If(!Empty(MV_PAR04),MV_PAR04, Replicate("9", GetSx3Cache("RA_MAT","X3_TAMANHO" )) )
Local cNomDe 	:= If(!Empty(MV_PAR05),MV_PAR05, Space(GetSx3Cache("RA_NOME", "X3_TAMANHO" )))
Local cNomAte	:= If(!Empty(MV_PAR06),MV_PAR06, Replicate("Z", GetSx3Cache("RA_NOME","X3_TAMANHO" )) ) 
Local cCalDe 	:= If(!Empty(MV_PAR07),MV_PAR07, Space(GetSx3Cache("RA3_CALEND", "X3_TAMANHO" )) )
Local cCalAte	:= If(!Empty(MV_PAR08),MV_PAR08, Replicate("9", GetSx3Cache("RA3_CALEND","X3_TAMANHO" )) ) 
Local cCurDe 	:= If(!Empty(MV_PAR09),MV_PAR09, Space(GetSx3Cache("RA3_CURSO", "X3_TAMANHO" )) )
Local cCurAte	:= If(!Empty(MV_PAR10),MV_PAR10, Replicate("9", GetSx3Cache("RA3_CURSO", "X3_TAMANHO" )) )
Local cTurDe 	:= If(!Empty(MV_PAR11),MV_PAR11, Space(GetSx3Cache("RA3_TURMA", "X3_TAMANHO" )) )
Local cTurAte	:= If(!Empty(MV_PAR12),MV_PAR12, Replicate("9", GetSx3Cache("RA3_TURMA", "X3_TAMANHO" )) )
Local cGruDe 	:= If(!Empty(MV_PAR13),MV_PAR13, Space(GetSx3Cache("Q3_GRUPO", "X3_TAMANHO" )) )
Local cGruAte	:= If(!Empty(MV_PAR14),MV_PAR14, Replicate("9", GetSx3Cache("Q3_GRUPO", "X3_TAMANHO" )) )
Local cDepDe 	:= If(!Empty(MV_PAR15),MV_PAR15, Space(GetSx3Cache("Q3_DEPTO", "X3_TAMANHO" )) )
Local cDepAte	:= If(!Empty(MV_PAR16),MV_PAR16, Replicate("9", GetSx3Cache("Q3_DEPTO", "X3_TAMANHO" )) )
Local cCarDe 	:= If(!Empty(MV_PAR17),MV_PAR17, Space(GetSx3Cache("RA_CARGO", "X3_TAMANHO" )) )
Local cCarAte	:= If(!Empty(MV_PAR18),MV_PAR18, Replicate("9", GetSx3Cache("RA_CARGO", "X3_TAMANHO" )) )
Local cSitCur	:= If(!Empty(MV_PAR19),MV_PAR19, "LRS")
Local nVias  	:= If(!Empty(MV_PAR20),MV_PAR20, 1)
Local nFerProg 	:= MV_PAR22
Local cSitFol  	:= ""

Local aError 	:= {}  

Private cSituacao	:= MV_PAR21

	//-- Filtragem do relatório
	//-- Query do relatório da secao 1
	lQuery := .T.  

	If nOrdem == 1 	// Nome	
		cOrder := "%RA3_CALEND,RA3_CURSO,RA3_TURMA,RA3_FILIAL,RA_NOME,RA3_MAT%"
	Else			// Matricula
		cOrder := "%RA3_CALEND,RA3_CURSO,RA3_TURMA,RA3_FILIAL,RA3_MAT%"
	EndIf        
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Treinamento Aberto-Baixado-Ambos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	For i :=1 to Len(cSitCur)
   	cSitQuery += "'"+Subs(cSitCur,i,1)+"'"
   	If ( i+1 ) <= Len(cSitCur)
    	cSitQuery += "," 
   	Endif
	Next i

	oReport:Section(1):BeginQuery()	

	cFilSRA := "% AND SRA.RA_FILIAL  = " + IIf( Empty(xFilial("SRA")), "'" + Space(FWGETTAMFILIAL) + "'", "RA3.RA3_FILIAL") + "%"

	cExpressao := " (RA3_FILIAL BETWEEN '"+cFilDe+"' AND '"+cFilAte+"') "
	cExpressao += "AND (RA3_MAT BETWEEN '"+cMatDe+"' AND '"+cMatAte+"') " 
	cExpressao += "AND (RA_NOME BETWEEN '"+cNomDe+"' AND '"+cNomAte+"') " 
	cExpressao += "AND (RA3_CALEND BETWEEN '"+cCalDe+"' AND '"+cCalAte+"') "
	cExpressao += "AND (RA3_CURSO BETWEEN '"+cCurDe+"' AND '"+cCurAte+"') "
	cExpressao += "AND (RA3_TURMA BETWEEN '"+cTurDe+"' AND '"+cTurAte+"') "
	cExpressao += "AND (Q3_GRUPO BETWEEN '"+cGruDe+"' AND '"+cGruAte+"') "
	cExpressao += "AND (Q3_DEPTO BETWEEN '"+cDepDe+"' AND '"+cDepAte+"') "
	cExpressao += "AND (Q3_CARGO BETWEEN '"+cCarDe+"' AND '"+cCarAte+"') "
 	cExpressao += "AND (RA3_RESERV IN ("+Upper(cSitQuery)+")) "	
  	cExpressao := "% "+cExpressao+" %"	

	cExpress2 := " (RA3_FILIAL BETWEEN '"+cFilDe+"' AND '"+cFilAte+"') "
	cExpress2 += "AND (RA3_MAT BETWEEN '"+cMatDe+"' AND '"+cMatAte+"') " 
	cExpress2 += "AND (RA_NOME BETWEEN '"+cNomDe+"' AND '"+cNomAte+"') " 
	cExpress2 += "AND (RA3_CALEND BETWEEN '"+cCalDe+"' AND '"+cCalAte+"') "
	cExpress2 += "AND (RA3_CURSO BETWEEN '"+cCurDe+"' AND '"+cCurAte+"') "
	cExpress2 += "AND (RA3_TURMA BETWEEN '"+cTurDe+"' AND '"+cTurAte+"') "
 	cExpress2 += "AND (RA3_RESERV IN ("+Upper(cSitQuery)+")) "	
  	cExpress2 := "% "+cExpress2+" %"		

    cSelecao	:= "'' as Q3_GRUPO,'' as Q0_DESCRIC,'' as Q3_DEPTO,"
    cSelecao	+= "'' as QB_DESCRIC,'' as Q3_CARGO,'' as Q3_DESCSUM"
    cSelecao	:= "%"+cSelecao+"%"

	BeginSql Alias cAliasQry

		SELECT DISTINCT	RA3_FILIAL,RA3_CURSO,RA1_DESC,RA3_MAT,RA3_DATA,RA_NOME,Q3_GRUPO,Q0_DESCRIC,Q3_DEPTO,
				QB_DESCRIC,Q3_CARGO,Q3_DESCSUM,RA3_RESERV,RA3_CALEND,RA2_DESC,RA9_DESCR,RA7_NOME,
				RA2_DATAIN,RA2_DATAFI,RA3_TURMA,RA2_SINON,RA2_INSTRU,RA2_LOCAL,RA2_HORARI

		FROM 	%table:RA3% RA3

		INNER JOIN %table:RA1% RA1
			ON RA1_FILIAL = %xFilial:RA1%
			AND RA1_CURSO = RA3_CURSO
			AND RA1.%NotDel%
		LEFT JOIN %table:RA2% RA2
			ON RA2_FILIAL = %xFilial:RA2%
			AND RA2_CALEND = RA3_CALEND
			AND RA2_CURSO = RA3_CURSO
			AND RA2_TURMA = RA3_TURMA
			AND RA2.%NotDel% 
		INNER JOIN %table:SRA% SRA
			ON RA_MAT = RA3_MAT
			AND SRA.%NotDel%
			%exp:cFilSRA%
		INNER JOIN %table:SRJ% SRJ
			ON RJ_FILIAL = %xFilial:SRJ%
			AND RJ_FUNCAO = RA_CODFUNC
			AND SRJ.%NotDel%
		INNER JOIN %table:SQ3% SQ3
			ON Q3_FILIAL = %xFilial:SQ3%
			AND Q3_CARGO = RA_CARGO
			AND ( Q3_CC = RA_CC OR Q3_CC = ' ' )
			AND SQ3.%NotDel%
		LEFT JOIN %table:SQ0% SQ0
			ON Q0_FILIAL = %xFilial:SQ0%
			AND Q0_GRUPO = Q3_GRUPO
			AND SQ0.%NotDel%
		LEFT JOIN %table:SQB% SQB
			ON QB_FILIAL = %xFilial:SQB%
			AND QB_DEPTO = Q3_DEPTO
			AND SQB.%NotDel%
		LEFT JOIN %table:RA9% RA9
			ON RA9_FILIAL = %xFilial:RA9%
			AND RA9_SINONI   = RA2_SINON
			AND RA9.%NotDel%
		LEFT JOIN %table:RA7% RA7
			ON RA7_FILIAL = %xFilial:RA7%
			AND RA7_INSTRU = RA2_INSTRU
			AND RA7.%NotDel%
		WHERE %exp:cExpressao%
			AND	RA3.%NotDel%

	   	UNION 

		SELECT DISTINCT RA3_FILIAL,RA3_CURSO,RA1_DESC,RA3_MAT,RA3_DATA,RA_NOME,%exp:cSelecao%,RA3_RESERV,
				RA3_CALEND,RA2_DESC,RA9_DESCR,RA7_NOME,	RA2_DATAIN,RA2_DATAFI,RA3_TURMA,RA2_SINON,
				RA2_INSTRU,RA2_LOCAL,RA2_HORARI

		FROM 	%table:RA3% RA3

		INNER JOIN %table:RA1% RA1
			ON RA1_FILIAL = %xFilial:RA1%
			AND RA1_CURSO = RA3_CURSO
			AND RA1.%NotDel% 
		LEFT JOIN %table:RA2% RA2
			ON RA2_FILIAL = %xFilial:RA2%
			AND RA2_CALEND = RA3_CALEND
			AND RA2_CURSO = RA3_CURSO
			AND RA2_TURMA = RA3_TURMA
			AND RA2.%NotDel% 
		INNER JOIN %table:SRA% SRA
			ON RA_MAT = RA3_MAT
			AND SRA.%NotDel%  
			%exp:cFilSRA%
		INNER JOIN %table:SRJ% SRJ
			ON RJ_FILIAL = %xFilial:SRJ%
			AND RJ_FUNCAO = RA_CODFUNC
			AND SRJ.%NotDel%
		LEFT JOIN %table:RA9% RA9
			ON RA9_FILIAL = %xFilial:RA9%
			AND RA9_SINONI = RA2_SINON
			AND RA9.%NotDel%
		LEFT JOIN %table:RA7% RA7
			ON RA7_FILIAL = %xFilial:RA7%
			AND RA7_INSTRU = RA2_INSTRU
			AND RA7.%NotDel%
		WHERE RA_CARGO = '     ' 
			AND %exp:cExpress2%
			AND	RA3.%NotDel%

		ORDER BY %Exp:cOrder%

	EndSql

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Metodo EndQuery ( Classe TRSection )                                    ³
	//³Prepara o relatório para executar o Embedded SQL.                       ³
	//³ExpA1 : Array com os parametros do tipo Range                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:Section(1):EndQuery()	//*Array com os parametros do tipo Range*
		
	//-- Inicio da impressao do fluxo do relatório
	oReport:SetMeter(RA3->(LastRec()))

	//-- Utiliza a query do Pai
	oSection2:SetParentQuery()
	oSection2:SetParentFilter( { |cParam| (cAliasQry)->RA3_CALEND + (cAliasQry)->RA3_CURSO + (cAliasQry)->RA3_TURMA  == cParam },{ || (cAliasQry)->RA3_CALEND + (cAliasQry)->RA3_CURSO + (cAliasQry)->RA3_TURMA})	
	
	//Valida Situacao do Funcionario 
	oSection2:SetLineCondition({|| fChkSit(cAliasQry)})
	
	If ( (cAliasQry)->(EOF())) 
		aError := VerificaInconsistencia()

		If ( Len ( aError ) > 0 )
		
			fMakeLog( { aError } , { STR0048 } , "" , .T. , NIL , "TRM010.PRW" , NIL , NIL , NIL , .F. )  

		EndIf
		
	EndIf
	
	For nImprVias := 1 To nVias	
		oSection1:Print()	 //Imprimir	
	Next nImprVias	
	
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fChkSit     ³ Autor ³ Eduardo Ju          ³ Data ³ 10.10.07 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Checa a Situacao do Funcionario                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fChkSit(cAliasQry)   

Local aSaveArea	:= GetArea()
Local lChkSit	:= .F.  

SRA->(dbSeek( (cAliasQry)->RA3_FILIAL+(cAliasQry)->RA3_MAT ))
lChkSit := TrmSitFol( If(Empty((cAliasQry)->RA2_DATAIN),(cAliasQry)->RA3_DATA,(cAliasQry)->RA2_DATAIN)) $ cSituacao
       
RestArea(aSaveArea)

Return(lChkSit)

/*/{Protheus.doc} VerificaInconsistencia
Verifica possíveis motivos de não impressão do relatório.
@author Wesley Alves Pereira
@since 23/01/2020
/*/

Static Function VerificaInconsistencia()
Local aError := {}
Local cQuery := ""
Local cAliErro
Local cCodFunc := ""
Local cCodCarg := ""
Local cCodCusto:= ""

Local cMatDe 	:= If(!Empty(MV_PAR03),MV_PAR03, Space(GetSx3Cache("RA_MAT", "X3_TAMANHO" )) )
Local cMatAte	:= If(!Empty(MV_PAR04),MV_PAR04, Replicate("9", GetSx3Cache("RA_MAT","X3_TAMANHO" )) )
Local cCurDe 	:= If(!Empty(MV_PAR09),MV_PAR09, Space(GetSx3Cache("RA3_CURSO", "X3_TAMANHO" )) )
Local cCurAte	:= If(!Empty(MV_PAR10),MV_PAR10, Replicate("9", GetSx3Cache("RA3_CURSO", "X3_TAMANHO" )) )
Local cFilDe 	:= If(!Empty(MV_PAR01),MV_PAR01, Space(FWGETTAMFILIAL))
Local cFilAte	:= If(!Empty(MV_PAR02),MV_PAR02, Replicate("Z", FWGETTAMFILIAL))
Local cNomDe 	:= If(!Empty(MV_PAR05),MV_PAR05, Space(GetSx3Cache("RA_NOME", "X3_TAMANHO" )))
Local cNomAte	:= If(!Empty(MV_PAR06),MV_PAR06, Replicate("Z", GetSx3Cache("RA_NOME","X3_TAMANHO" )) ) 
Local cGruDe 	:= If(!Empty(MV_PAR13),MV_PAR13, Space(GetSx3Cache("Q3_GRUPO", "X3_TAMANHO" )) )
Local cGruAte	:= If(!Empty(MV_PAR14),MV_PAR14, Replicate("9", GetSx3Cache("Q3_GRUPO", "X3_TAMANHO" )) )
Local cDepDe 	:= If(!Empty(MV_PAR15),MV_PAR15, Space(GetSx3Cache("Q3_DEPTO", "X3_TAMANHO" )) )
Local cDepAte	:= If(!Empty(MV_PAR16),MV_PAR16, Replicate("9", GetSx3Cache("Q3_DEPTO", "X3_TAMANHO" )) )
Local cCarDe 	:= If(!Empty(MV_PAR17),MV_PAR17, Space(GetSx3Cache("RA_CARGO", "X3_TAMANHO" )) )
Local cCarAte	:= If(!Empty(MV_PAR18),MV_PAR18, Replicate("9", GetSx3Cache("RA_CARGO", "X3_TAMANHO" )) )
Local cCalDe 	:= If(!Empty(MV_PAR07),MV_PAR07, Space(GetSx3Cache("RA3_CALEND", "X3_TAMANHO" )) )
Local cCalAte	:= If(!Empty(MV_PAR08),MV_PAR08, Replicate("9", GetSx3Cache("RA3_CALEND","X3_TAMANHO" )) ) 
Local cTurDe 	:= If(!Empty(MV_PAR11),MV_PAR11, Space(GetSx3Cache("RA3_TURMA", "X3_TAMANHO" )) )
Local cTurAte	:= If(!Empty(MV_PAR12),MV_PAR12, Replicate("9", GetSx3Cache("RA3_TURMA", "X3_TAMANHO" )) )

Local cSitCur	:= If(!Empty(MV_PAR19),MV_PAR19, "LRS")
Local cSitQuery := ""
Local i
Local TAB := Space(10)

For i :=1 to Len(cSitCur)
	cSitQuery += "'"+Subs(cSitCur,i,1)+"'"
	If ( i+1 ) <= Len(cSitCur)
		cSitQuery += "," 
	Endif
Next i

cAliErro   := GetNextAlias()
cQuery := ""
cQuery += 	" SELECT RA3_CURSO " 
cQuery += 	" FROM  "+RetSqlName("RA3")+" RA3 "
cQuery +=   " WHERE (RA3_FILIAL BETWEEN '"+cFilDe+"' AND '"+cFilAte+"') "
cQuery += 	" AND (RA3_MAT BETWEEN '"+cMatDe+"' AND '"+cMatAte+"') " 
cQuery += 	" AND (RA3_CALEND BETWEEN '"+cCalDe+"' AND '"+cCalAte+"') "
cQuery += 	" AND (RA3_CURSO BETWEEN '"+cCurDe+"' AND '"+cCurAte+"') "
cQuery += 	" AND (RA3_TURMA BETWEEN '"+cTurDe+"' AND '"+cTurAte+"') "
cQuery += 	" AND (RA3_RESERV IN ("+Upper(cSitQuery)+")) "	
cQuery += 	" AND RA3.D_E_L_E_T_ <> '*' "

dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliErro,.F.,.T.)

If (cAliErro)->(EOF()) 
	aAdd( aError , TAB )
	aAdd( aError , TAB )
	aAdd( aError , STR0049 ) //"Verifique a tabela de Solicitações de Treinamento (RA3). Não foi possível encontrar a solicitação!"
	aAdd( aError , TAB + STR0054 ) //"Possíveis Causas:"
	aAdd( aError , TAB + TAB + STR0055 ) //"Parâmetros de filiais incorretos;"
	aAdd( aError , TAB + TAB + STR0056 ) //"Parâmetros de matrículas incorretos;"
	aAdd( aError , TAB + TAB + STR0057 ) //"Parâmetros de calendários incorretos;"
	aAdd( aError , TAB + TAB + STR0058 ) //"Parâmetros de cursos incorretos;"
	aAdd( aError , TAB + TAB + STR0059 ) //"Parâmetros de turma incorretos;"
	aAdd( aError , TAB + TAB + STR0060 ) //"Situações de reserva incorretas;"
					
EndIf

DbSelectArea((cAliErro))
(cAliErro)->(dbCloseArea())

cAliErro   := GetNextAlias()
cQuery := ""
cQuery += 	" SELECT RA1_CURSO " 
cQuery += 	" FROM  "+RetSqlName("RA1")+" RA1 "
cQuery +=   " WHERE (RA1_FILIAL BETWEEN '"+cFilDe+"' AND '"+cFilAte+"') "
cQuery += 	" AND   (RA1_CURSO BETWEEN '"+cCurDe+"' AND '"+cCurAte+"') "
cQuery += 	" AND   RA1.D_E_L_E_T_ <> '*' "

dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliErro,.F.,.T.)

If (cAliErro)->(EOF()) 
	aAdd( aError , TAB )
	aAdd( aError , TAB )
	aAdd( aError , STR0050) //"Verifique a tabela de Cursos (RA1). Não foi possível encontrar o curso!"
	aAdd( aError , TAB + STR0054 ) //"Possíveis Causas:"
	aAdd( aError , TAB + TAB + STR0055 ) //"Parâmetros de filiais incorretos;"
	aAdd( aError , TAB + TAB + STR0058 ) //"Parâmetros de cursos incorretos;"
EndIf

DbSelectArea((cAliErro))
(cAliErro)->(dbCloseArea())

cAliErro   := GetNextAlias()
cQuery := ""
cQuery += 	" SELECT RA_CODFUNC, RA_CARGO, RA_CC " 
cQuery += 	" FROM  "+RetSqlName("SRA")+" SRA "
cQuery +=   " WHERE (RA_FILIAL BETWEEN '"+cFilDe+"' AND '"+cFilAte+"') "
cQuery += 	" AND   (RA_MAT BETWEEN '"+cMatDe+"' AND '"+cMatAte+"') "
cQuery +=   " AND   (RA_NOME BETWEEN '"+cNomDe+"' AND '"+cNomAte+"') " 
cQuery += 	" AND   SRA.D_E_L_E_T_ <> '*' "

dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliErro,.F.,.T.)

If (cAliErro)->(EOF()) 
	aAdd( aError , TAB )
	aAdd( aError , TAB )
	aAdd( aError , STR0051 ) // "Verifique a tabela de Funcionários (SRA). Não foi possível encontrar a matrícula!"
	aAdd( aError , TAB + STR0054 ) //"Possíveis Causas:"
	aAdd( aError , TAB + TAB + STR0055 ) //"Parâmetros de filiais incorretos;"
	aAdd( aError , TAB + TAB + STR0056 ) //"Parâmetros de matrículas incorretos;"
	aAdd( aError , TAB + TAB + STR0061 ) //"Parâmetros de nomes incorretos;"
Else
	cCodFunc := (cAliErro)->RA_CODFUNC
	cCodCarg := (cAliErro)->RA_CARGO
	cCodCusto:=  (cAliErro)->RA_CC
EndIf

DbSelectArea((cAliErro))
(cAliErro)->(dbCloseArea())

cAliErro   := GetNextAlias()
cQuery := ""
cQuery += 	" SELECT RJ_FUNCAO " 
cQuery += 	" FROM  "+RetSqlName("SRJ")+" SRJ "
cQuery +=   " WHERE (RJ_FILIAL BETWEEN '"+cFilDe+"' AND '"+cFilAte+"') "
cQuery += 	" AND   RJ_FUNCAO = '"+cCodFunc+"'"
cQuery += 	" AND   SRJ.D_E_L_E_T_ <> '*' "

dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliErro,.F.,.T.)

If (cAliErro)->(EOF()) 
	aAdd( aError , TAB )
	aAdd( aError , TAB )
	aAdd( aError , STR0052 ) //"Verifique a tabela de Funções (SRJ). Não foi possível encontrar a função!"
	aAdd( aError , TAB + STR0054 ) //"Possíveis Causas:"
	aAdd( aError , TAB + TAB + STR0055 ) //"Parâmetros de filiais incorretos;"
	aAdd( aError , TAB + TAB + STR0056 ) //"Parâmetros de matrículas incorretos;"
	aAdd( aError , TAB + TAB + STR0061 ) //"Parâmetros de nomes incorretos;"
	aAdd( aError , TAB + TAB + STR0062 ) //"Função do funcionário inválida;"
EndIf

DbSelectArea((cAliErro))
(cAliErro)->(dbCloseArea())

cAliErro   := GetNextAlias()
cQuery := ""
cQuery += 	" SELECT Q3_CARGO " 
cQuery += 	" FROM  "+RetSqlName("SQ3")+" SQ3 "
cQuery +=   " WHERE (Q3_FILIAL BETWEEN '"+cFilDe+"' AND '"+cFilAte+"') "
cQuery += 	" AND   Q3_CARGO = '"+cCodCarg +"'"
cQuery += 	" AND ( Q3_CC = '"+cCodCusto+"' OR Q3_CC = ' ' ) 
cQuery += 	" AND (Q3_GRUPO BETWEEN '"+cGruDe+"' AND '"+cGruAte+"') "
cQuery += 	" AND (Q3_DEPTO BETWEEN '"+cDepDe+"' AND '"+cDepAte+"') "
cQuery += 	" AND (Q3_CARGO BETWEEN '"+cCarDe+"' AND '"+cCarAte+"') "
cQuery += 	" AND   SQ3.D_E_L_E_T_ <> '*' "

dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliErro,.F.,.T.)

If (cAliErro)->(EOF()) 
	aAdd( aError , TAB )
	aAdd( aError , TAB )
	aAdd( aError , STR0053 ) //"Verifique a tabela de Cargos (SQ3). Não foi possível encontrar o cargo!"
	aAdd( aError , TAB + STR0054 ) //"Possíveis Causas:"
	aAdd( aError , TAB + TAB + STR0055 ) //"Parâmetros de filiais incorretos;"
	aAdd( aError , TAB + TAB + STR0063 ) //"Parâmetros de grupos incorretos;"
	aAdd( aError , TAB + TAB + STR0064 ) //"Parâmetros de departamentos incorretos;"
	aAdd( aError , TAB + TAB + STR0065 ) //"Parâmetros de cargos incorretos;"
	aAdd( aError , TAB + TAB + STR0066 ) //"Cargo do funcionário inválido;"
	aAdd( aError , TAB + TAB + STR0067 ) //"Caso o funcionário tenha o centro de custo informado, o cargo deverá ter o centro de custo informado;"
EndIf

DbSelectArea((cAliErro))
(cAliErro)->(dbCloseArea())

Return ( aError )	