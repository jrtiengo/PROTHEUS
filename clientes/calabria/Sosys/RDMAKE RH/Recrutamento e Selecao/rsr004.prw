#INCLUDE "Protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "RSR004.CH"
   

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ RSR004   ³ Autor ³ Eduardo Ju            ³ Data ³ 14/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Avaliacoes Realizadas Pelo Candidato          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RSR004                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³06/08/14³TQENRX³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³        ³      ³da a limpeza.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function RSR004()

Local oReport 	:= Nil
Local aArea 	:= GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("RS04AR",.F.)
oReport := ReportDef()
oReport:PrintDialog()	

RestArea( aArea )

Return


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportDef() ³ Autor ³ Eduardo Ju          ³ Data ³ 14.07.06 ³±±
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

Local oReport 	:= Nil
Local oSection1	:= Nil
Local oSection2 := Nil
Local cAliasQry := GetNextAlias()
Local cAliasQry1:= GetNextAlias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("RS04AR",.F.)
oReport:=TReport():New("RSR004",STR0003,"RS04AR",{|oReport| PrintReport(oReport,cAliasQry,cAliasQry1)},STR0001+" "+STR0002)	//"Testes Realizados"#"Este programa tem como objetivo imprimir os testes realizados conforme parametros selecionados."
                                              
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Primeira Secao: Candidato   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection1 := TRSection():New(oReport,STR0009,{"SQR","SQG","SQQ"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	
	
oSection1:SetTotalInLine(.F.)  
oSection1:SetHeaderBreak(.T.)

TRCell():New(oSection1,"QR_FILIAL","SQR")				//Filial do Curriculo do Candidato
TRCell():New(oSection1,"QR_CURRIC","SQR",STR0010)		//Codigo do Curriculo do Candidato
TRCell():New(oSection1,"QG_NOME","SQG")					//Nome do Candidato
TRCell():New(oSection1,"QR_TESTE","SQR",STR0013)		//Codigo da Teste (Avaliacao)
TRCell():New(oSection1,"QQ_DESCRIC","SQQ","")			//Descricao da Avaliacao  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Segunda Secao: Questoes    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection2:= TRSection():New(oSection1,STR0011,{"SQR"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	
oSection2:SetTotalInLine(.F.)  
oSection2:SetHeaderBreak(.T.)
oSection2:SetLeftMargin(2)	//Identacao da Secao

TRCell():New(oSection2,"QR_QUESTAO","SQR",,,,,;
	{|| IIf((cAliasQry1)->QR_ALTERNA =="00" .Or. (cAliasQry1)->QP_ALTERNA = "01" .Or.;
	(cAliasQry1)->RBL_ITEM = "01", ( oReport:IncRow(), (cAliasQry1)->QR_QUESTAO ), "") })			
TRCell():New(oSection2,"QO_QUEST"  ,"SQO", "Desc. Questão",,50,,;
	{|| IIf((cAliasQry1)->QR_ALTERNA =="00" .Or. (cAliasQry1)->QP_ALTERNA = "01" .Or.;
	(cAliasQry1)->RBL_ITEM = "01", fRetDesc(cAliasQry1), "") })
TRCell():New(oSection2,"QP_ALTERNA","SQP",,,15,,;
	{|| fRetEscala(1, cAliasQry1) })	
TRCell():New(oSection2,"QP_DESCRIC","SQP", "Desc. Alternativa",,50,,;
	{|| fRetEscala(2, cAliasQry1) })
TRCell():New(oSection2,"QO_PONTOS" ,"SQO",STR0012,,15,,;
	{|| Iif( (cAliasQry1)->QP_ALTERNA == (cAliasQry1)->QR_ALTERNA .Or. (cAliasQry1)->RBL_ITEM == (cAliasQry1)->QR_ALTERNA, fRetPontos(cAliasQry1),;
	oSection2:Cell("QO_PONTOS"):HideHeader()) })  //Pontos de cada alternativa da questao

oSection2:SetTotalText({|| STR0014 })  //Nota
TRFunction():New(oSection2:Cell("QO_PONTOS"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)

Return oReport  

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportDef() ³ Autor ³ Eduardo Ju          ³ Data ³ 07.07.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Relatorio                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PrintReport(oReport,cAliasQry,cAliasQry1)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)  
Local cFiltro 	:= ""
Local cOrder 	:= "%QR_FILIAL,QR_CURRIC,QR_TESTE%"	
Local cOrder2 	:= "%QR_FILIAL,QR_CURRIC,QR_TESTE,QR_QUESTAO,QP_ALTERNA,RBL_ITEM%"	

Private aFunc	:= {}

oSection1:SetFilter(cFiltro)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ mv_par01        //  Filial                                   ³ 
//³ mv_par02        //  Curriculo                                ³ 
//³ mv_par03        //  Teste                                    ³ 
//³ mv_par04        //  Nota De                                  ³ 
//³ mv_par05        //  Nota Ate                                 ³ 
//³ mv_par06        //  Relatorio: Analitico ou Sintetico        ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Transforma parametros Range em expressao SQL ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr("RS04AR")    

//-- Filtragem do relatório
//-- Query do relatório da secao 1
lQuery 	:= .T.         

oReport:Section(1):BeginQuery()	

if SQG->(Columnpos("QG_ACTRSP")) > 0 .AND. SQG->(Columnpos("QG_ACEITE")) > 0
	BeginSql Alias cAliasQry
		SELECT DISTINCT	QR_FILIAL,QR_CURRIC,QG_NOME,QG_ACEITE,QG_ACTRSP,QR_TESTE,QQ_DESCRIC
				
		FROM 	%table:SQR% SQR 
		
		LEFT JOIN %table:SQG% SQG
			ON QG_FILIAL = %xFilial:SQG%
			AND QG_CURRIC = QR_CURRIC
			AND SQG.%NotDel%

		LEFT JOIN %table:SQQ% SQQ
			ON QQ_FILIAL = %xFilial:SQQ%
			AND QQ_TESTE = QR_TESTE
			AND SQQ.%NotDel%    
		
		WHERE QR_FILIAL = %xFilial:SQR% AND 
			SQR.%NotDel%
		ORDER BY %Exp:cOrder%                 		
		
	EndSql
else
	BeginSql Alias cAliasQry
		
	SELECT DISTINCT	QR_FILIAL,QR_CURRIC,QG_NOME,QR_TESTE,QQ_DESCRIC
				
		FROM 	%table:SQR% SQR 
		
		LEFT JOIN %table:SQG% SQG
			ON QG_FILIAL = %xFilial:SQG%
			AND QG_CURRIC = QR_CURRIC
			AND SQG.%NotDel%

		LEFT JOIN %table:SQQ% SQQ
			ON QQ_FILIAL = %xFilial:SQQ%
			AND QQ_TESTE = QR_TESTE
			AND SQQ.%NotDel%    
		
		WHERE QR_FILIAL = %xFilial:SQR% AND 
			SQR.%NotDel%
		ORDER BY %Exp:cOrder%                 		
		
	EndSql
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Metodo EndQuery ( Classe TRSection )                                    ³
//³Prepara o relatório para executar o Embedded SQL.                       ³
//³ExpA1 : Array com os parametros do tipo Range                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:Section(1):EndQuery({mv_par01,mv_par02,mv_par03})	/*Array com os parametros do tipo Range*/

BEGIN REPORT QUERY oReport:Section(1):Section(1)

BeginSql Alias cAliasQry1
	
SELECT QR_FILIAL, QR_CURRIC, QR_TESTE, QR_TOPICO, QR_QUESTAO, QR_ALTERNA, QR_RESULTA,
		QO_FILIAL, QO_QUESTAO, QO_PONTOS, QO_TIPOOBJ, QO_ESCALA,
		QP_FILIAL, QP_QUESTAO, QP_ALTERNA, QP_PERCENT, QP_DESCRIC,
		RBL_FILIAL, RBL_ESCALA, RBL_ITEM, RBL_DESCRI, RBL_VALOR
			
	FROM 	%table:SQR% SQR
	
	LEFT JOIN %table:SQO% SQO
		ON QO_FILIAL = %xFilial:SQO% AND
			QO_QUESTAO = QR_QUESTAO AND
			SQO.%NotDel%

	LEFT JOIN %table:SQP% SQP
		ON 	QP_FILIAL = %xFilial:SQP% AND 
			QP_QUESTAO = QO_QUESTAO AND
			SQP.%NotDel%

	LEFT JOIN %table:RBL% RBL
		ON 	RBL_FILIAL = %xFilial:RBL% AND 
			RBL_ESCALA = QO_ESCALA AND
			RBL.%NotDel%

	WHERE QR_FILIAL = %xFilial:SQR%  AND
		QR_CURRIC = %report_param:(cAliasQry)->QR_CURRIC% AND
		QR_TESTE = %report_param:(cAliasQry)->QR_TESTE% AND
		SQR.%NotDel%
		
		ORDER BY %Exp:cOrder2%
EndSql

END REPORT QUERY oReport:Section(1):Section(1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿         																																																																																
//³ Inicio da impressao do fluxo do relatório ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:SetMeter(SQR->(LastRec()))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Condicao para Impressao   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1:SetLineCondition({|| Rs004Nota(cAliasQry,oReport:Section(1):Section(1),oReport:Section(1)) })

oSection2:SetLineCondition({|| fRsrCond(cAliasQry1) })   

If mv_par06 = 2	//Sintetico Obs.: Apresenta apenas Nota
	oSection2:Hide()
	oSection2:Cell("QR_QUESTAO"):HideHeader()
	oSection2:Cell("QO_PONTOS"):HideHeader()
	oSection2:Cell("QO_QUEST"):HideHeader()
	oSection2:Cell("QP_ALTERNA"):HideHeader()
	oSection2:Cell("QP_DESCRIC"):HideHeader()
EndIf

oReport:SetMeter(SQR->(LastRec()))	   

oSection1:Print() //Imprimir   

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³Rs004Nota   ³ Autor ³ Eduardo Ju          ³ Data ³ 29.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Impressao da Nota                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ RSR004                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs004Nota(cAliasQry,oPontos,oAceite)

Local nNota 	:= 0
Local cSvAlias 	:= Alias()
Local lNota		:= .F.
Local cBlqCV	:= SuperGetMv("MV_BLQCV",,"1") 
Local cFilQry
Local cCurrQry	
Local cTestQry 
Local cAlterna

oPontos:ExecSql()

cFilQry	:= (oPontos:cAlias)->QR_FILIAL
cCurrQry:= (oPontos:cAlias)->QR_CURRIC
cTestQry:= (oPontos:cAlias)->QR_TESTE

While (oPontos:cAlias)->( !Eof() ) .And. cFilQry + cCurrQry + cTestQry ==;
	(oPontos:cAlias)->QR_FILIAL + (oPontos:cAlias)->QR_CURRIC + (oPontos:cAlias)->QR_TESTE

	If Empty( (oPontos:cAlias)->RBL_ITEM )
		cAlterna := (oPontos:cAlias)->QP_ALTERNA
	Else
		cAlterna := (oPontos:cAlias)->RBL_ITEM
	EndIf

	If (oPontos:cAlias)->QR_ALTERNA == cAlterna
		nNota += ( (oPontos:cAlias)->QO_PONTOS * (oPontos:cAlias)->QR_RESULTA )/100
	EndIf
	(oPontos:cAlias)->( DbSkip() )
End

If nNota >= mv_par04 .And.  nNota <= mv_par05
	lNota	:= .T.
EndIf 

if SQG->(Columnpos("QG_ACTRSP")) > 0 .AND. SQG->(Columnpos("QG_ACEITE")) > 0
	oAceite:ExecSql()
	While (oAceite:cAlias)->( !Eof() )
		if (oAceite:cAlias)->QR_FILIAL == cFilQry .and. (oAceite:cAlias)->QR_CURRIC == cCurrQry;
			.and. (oAceite:cAlias)->QR_TESTE == cTestQry

			if (oAceite:cAlias)->QG_ACTRSP == '1' //1- sem aceite e 2-com aceite
				lNota := .F.
				exit
			ENDIF
			IF cBlqCV == "2" .and. (oAceite:cAlias)->QG_ACEITE <> '2'
				lNota := .F.
				exit
			ENDIF
			exit
		ENDIF
		(oAceite:cAlias)->( DBskip() )
	END
	oPontos:ExecSql()
ENDIF

DBSelectArea(cSvAlias)

Return lNota


/*/{Protheus.doc} fRsrCond
	(long_description)
	@type  Static Function
	@author Emerson Grassi Rocha
	@since 18/12/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function fRsrCond(cAliasQry1)
Local aArea := GetArea()
Local lRet	:= .T.  
Local cAlterna     
 
If Empty( (cAliasQry1)->RBL_ITEM )
	cAlterna := (cAliasQry1)->QP_ALTERNA
Else
	cAlterna := (cAliasQry1)->RBL_ITEM
EndIf

If (cAliasQry1)->QO_TIPOOBJ == "1" //Multipla escolha
	If Len(aFunc) = 0 .Or. Ascan(aFunc, {|x| x[1] + x[2] + x[3] + x[4] + x[5] + x[6] ==;
		 (cAliasQry1)->QR_FILIAL + (cAliasQry1)->QR_CURRIC + (cAliasQry1)->QR_TESTE + (cAliasQry1)->QR_TOPICO + (cAliasQry1)->QR_QUESTAO + cAlterna}) == 0
				
		//Verifica se foi selecionada esta questao / Adiciona Questao no Array		
		dbSelectArea("SQR")
		dbSetOrder(1)
		If dbSeek( (cAliasQry1)->QR_FILIAL + (cAliasQry1)->QR_CURRIC + (cAliasQry1)->QR_TESTE + (cAliasQry1)->QR_TOPICO + (cAliasQry1)->QR_QUESTAO + cAlterna )
			If ( cAlterna == (cAliasQry1)->QR_ALTERNA )
				AAdd(aFunc, {(cAliasQry1)->QR_FILIAL, (cAliasQry1)->QR_CURRIC, (cAliasQry1)->QR_TESTE, (cAliasQry1)->QR_TOPICO, (cAliasQry1)->QR_QUESTAO, cAlterna})
				lRet := .T. 
			Else
				lRet := .F. 
			EndIf
		Else
	  	 	AAdd(aFunc, {(cAliasQry1)->QR_FILIAL, (cAliasQry1)->QR_CURRIC, (cAliasQry1)->QR_TESTE, (cAliasQry1)->QR_TOPICO, (cAliasQry1)->QR_QUESTAO, cAlterna})
			lRet := .T.  
		EndIf     
	Else
		lRet := .F.
	EndIf 
Endif

RestArea(aArea)
Return lRet


/*/{Protheus.doc} fRetDesc
	(long_description)
	@type  Static Function
	@author Emerson Grassi Rocha
	@since 10/12/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function fRetDesc(cAliasQry1)
Local cDesc := ""
Local aArea := GetArea()

	dbSelectarea("SQO") 
	dbSetOrder(1)
	If dbSeek((cAliasQry1)->QO_FILIAL+(cAliasQry1)->QO_QUESTAO)   
		cDesc := Alltrim(SQO->QO_QUEST)
		cDesc := MemoLine(cDesc,50,1)    
	EndIf 

RestArea(aArea)
Return(cDesc)


/*/{Protheus.doc} fRetEscala
	(long_description)
	@type  Static Function
	@author Emerson Grassi Rocha
	@since 21/12/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function fRetEscala(nOpc, cAliasQry1)

Local cTipo := (cAliasQry1)->QO_TIPOOBJ
Local cAlterna

//Codigo Alternativa
If nOpc = 1
	If Empty( (cAliasQry1)->RBL_ITEM )
		cAlterna := (cAliasQry1)->QP_ALTERNA
	Else
		cAlterna := (cAliasQry1)->RBL_ITEM
	EndIf

	If cTipo == "3" //Dissertativa
		cAlterna :=  "00 X"
	ElseIf ( cAlterna == (cAliasQry1)->QR_ALTERNA )
		cAlterna += " X"
	EndIf

//Descrição Alternativa
ElseIf nOpc = 2

	If cTipo == "3" //Dissertativa
		cAlterna := "****** DISSERTATIVA ******" 
	Else 
		If Empty( (cAliasQry1)->RBL_ITEM )
			cAlterna := (cAliasQry1)->QP_DESCRIC
		Else
			cAlterna := (cAliasQry1)->RBL_DESCRI
		EndIf
	EndIf
EndIf

Return cAlterna



/*/{Protheus.doc} fRetPontos
	(long_description)
	@type  Static Function
	@author user
	@since 21/12/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function fRetPontos(cAliasQry1)

Local nPontos := 0

	If Empty( (cAliasQry1)->RBL_ITEM )
		nPontos := ( (cAliasQry1)->QO_PONTOS * (cAliasQry1)->QP_PERCENT )/100
	Else
		nPontos := ( (cAliasQry1)->QO_PONTOS * (cAliasQry1)->RBL_VALOR )/100
	EndIf

Return nPontos
