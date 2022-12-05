#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TRM040.CH"


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao       ³ TRM040   ³ Autor ³ Eduardo Ju            ³ Data ³ 09.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao    ³ Custo do Treinamento Anual                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso          ³ TRM030                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Carv.³31/07/14³TPZWAO³AIncluido o fonte da 11 para a 12 e efetuada³±±
±±³             ³        ³      ³a limpeza.                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function TRM040()

Local oReport
Local aArea := GetArea()
Private aValor 	:= Array(12)
Private aHoras 	:= Array(12)

Pergunte("TR040R",.F.)
oReport := ReportDef()
oReport:PrintDialog()
RestArea( aArea )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportDef() ³ Autor ³ Eduardo Ju          ³ Data ³ 23.08.06 ³±±
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
Local oSection3
Local oBreakCC
Local aOrdem    := {}
Local nTotal	:= 0 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oReport:=TReport():New("TRM040",STR0001,"TR040R",{|oReport| PrintReport(oReport)},STR0002+" "+STR0003)	//"Custo de Treinamento Anual"#"Será impresso de acordo com os parametros solicitados pelo usuario"
oReport:SetTotalInLine(.F.) //Totaliza em linha 
oReport:SetLandscape()		//Imprimir Somente Paisagem
Pergunte("TR040R",.F.)  

Aadd( aOrdem, STR0004)	// "Curso"
Aadd( aOrdem, STR0005)	// "Centro de Custo"

//******************* Relatorio por Curso **********************
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Primeira Secao: "Curso" - Valor ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection1 := TRSection():New(oReport,STR0035 + " -" + STR0011,{"RA4","RA1"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)	//"Custo por Curso - Valor"
oSection1 :SetTotalInLine(.F.)   
oSection1:SetHeaderBreak(.T.) 

TRCell():New(oSection1,"RA4_CURSO","RA4",STR0004,,,,{|| cCurso })	//Codigo do Curso
TRCell():New(oSection1,"RA1_DESC","RA1",,,,,{|| Posicione("RA1",1,xFilial("RA1")+cCurso,+space(5)+"RA1_DESC") }) //Descricao do Curso  
TRCell():New(oSection1,"JANEIRO"	,"   ",	STR0020 + CRLF + STR0033 ,"@R 9999,999.99",12,, {|| aValor[1] })
TRCell():New(oSection1,"FEVEREIRO"	,"   ", STR0021 + CRLF + STR0033 ,"@R 9999,999.99",12,, {|| aValor[2] })
TRCell():New(oSection1,"MARCO"		,"   ", STR0022 + CRLF + STR0033 ,"@R 9999,999.99",12,, {|| aValor[3] })
TRCell():New(oSection1,"ABRIL"		,"   ", STR0023 + CRLF + STR0033 ,"@R 9999,999.99",12,, {|| aValor[4] })
TRCell():New(oSection1,"MAIO"		,"   ", STR0024 + CRLF + STR0033 ,"@R 9999,999.99",12,, {|| aValor[5] })
TRCell():New(oSection1,"JUNHO"		,"   ", STR0025 + CRLF + STR0033 ,"@R 9999,999.99",12,, {|| aValor[6] })
TRCell():New(oSection1,"JULHO"		,"   ", STR0026 + CRLF + STR0033 ,"@R 9999,999.99",12,, {|| aValor[7] })
TRCell():New(oSection1,"AGOSTO"		,"   ", STR0027 + CRLF + STR0033 ,"@R 9999,999.99",12,, {|| aValor[8] })
TRCell():New(oSection1,"SETEMBRO"	,"   ", STR0028 + CRLF + STR0033 ,"@R 9999,999.99",12,, {|| aValor[9] })
TRCell():New(oSection1,"OUTUBRO"	,"   ", STR0029 + CRLF + STR0033 ,"@R 9999,999.99",12,, {|| aValor[10]})
TRCell():New(oSection1,"NOVEMBRO"	,"   ", STR0030 + CRLF + STR0033 ,"@R 9999,999.99",12,, {|| aValor[11]})
TRCell():New(oSection1,"DEZEMBRO"	,"   ", STR0031 + CRLF + STR0033 ,"@R 9999,999.99",12,, {|| aValor[12]})
TRCell():New(oSection1,"TOTAL"		,"   ", STR0032 ,"@R 9999,999.99",12,, {|| nTotal:= 0, aEval(aValor,{ |X| nTotal += X }), nTotal})	 	

TRPosition():New(oSection1,"RA1",2,{|| RhFilial("RA1",RA4->RA4_FILIAL)+ cCurso })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Primeira Secao: "Curso" - Horas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection2 := TRSection():New(oReport,STR0035 + " -" + STR0012,{"RA4","RA1"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)	//"Custo por Curso - Horas"
oSection2 :SetTotalInLine(.F.)   
oSection2:SetHeaderBreak(.T.)

TRCell():New(oSection2,"RA4_CURSO","RA4",STR0004,,,,{|| cCurso })	//Codigo do Curso
TRCell():New(oSection2,"RA1_DESC","RA1",,,,,{|| Posicione("RA1",1,xFilial("RA1")+cCurso,+space(5)+"RA1_DESC") })	//Descricao do Curso  
TRCell():New(oSection2,"JANEIRO"	,"   ",	STR0020 + CRLF + STR0034,"@R 9999.99",6,, {|| aHoras[1] })
TRCell():New(oSection2,"FEVEREIRO"	,"   ", STR0021 + CRLF + STR0034,"@R 9999.99",6,, {|| aHoras[2] })
TRCell():New(oSection2,"MARCO"		,"   ", STR0022 + CRLF + STR0034,"@R 9999.99",6,, {|| aHoras[3] })
TRCell():New(oSection2,"ABRIL"		,"   ", STR0023 + CRLF + STR0034,"@R 9999.99",6,, {|| aHoras[4] })
TRCell():New(oSection2,"MAIO"		,"   ", STR0024 + CRLF + STR0034,"@R 9999.99",6,, {|| aHoras[5] })
TRCell():New(oSection2,"JUNHO"		,"   ", STR0025 + CRLF + STR0034,"@R 9999.99",6,, {|| aHoras[6] })
TRCell():New(oSection2,"JULHO"		,"   ", STR0026 + CRLF + STR0034,"@R 9999.99",6,, {|| aHoras[7] })
TRCell():New(oSection2,"AGOSTO"		,"   ", STR0027 + CRLF + STR0034,"@R 9999.99",6,, {|| aHoras[8] })
TRCell():New(oSection2,"SETEMBRO"	,"   ", STR0028 + CRLF + STR0034,"@R 9999.99",6,, {|| aHoras[9] })
TRCell():New(oSection2,"OUTUBRO"	,"   ", STR0029 + CRLF + STR0034,"@R 9999.99",6,, {|| aHoras[10]})
TRCell():New(oSection2,"NOVEMBRO"	,"   ", STR0030 + CRLF + STR0034,"@R 9999.99",6,, {|| aHoras[11]})
TRCell():New(oSection2,"DEZEMBRO"	,"   ", STR0031 + CRLF + STR0034,"@R 9999.99",6,, {|| aHoras[12]})
TRCell():New(oSection2,"TOTAL"		,"   ", STR0032,"@R 9999.99",6,, {|| nTotal:= 0, aEval(aHoras,{ |X| nTotal += X }), nTotal})	 	
 
TRPosition():New(oSection2,"RA1",2,{|| RhFilial("RA1",RA4->RA4_FILIAL)+ cCurso })

//******************* Relatorio por CC **********************
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Terceira Secao: "C.Custo" ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection3 := TRSection():New(oReport, STR0001 ,{"RA4","SRA"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)	//"Custo de Treinamento Anual"
oSection3 :SetTotalInLine(.F.)   
oSection3:SetHeaderBreak(.T.)  

TRCell():New(oSection3,"RA_CC","SRA",,,,,{|| TRA->TR_CC })	//Centro de Custo
TRCell():New(oSection3,"CTT_DESC01","CTT","")				//Descricao do Centro de Custo

TRPosition():New(oSection3,"SRA",1,{|| RhFilial("SRA",TRA->TR_FILIAL)+ TRA->TR_MAT })
TRPosition():New(oSection3,"CTT",1,{|| RhFilial("CTT",TRA->TR_FILIAL)+ TRA->TR_CC })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Quarta Secao: C.Custo por Valor  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection4 := TRSection():New(oSection3,STR0037 + " -" + STR0011,{"RA4","RA1"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)		//"Custo por C.Custo - Valor"
oSection4:SetTotalInLine(.F.)  
oSection4:SetHeaderBreak(.T.)  

TRCell():New(oSection4,"RA4_CURSO","RA4",STR0004,,,,{|| cCurso })	//Codigo do Curso
TRCell():New(oSection4,"RA1_DESC","RA1",,,,,{|| Posicione("RA1",1,xFilial("RA1")+cCurso,+space(5)+"RA1_DESC") })//Descricao do Curso  
TRCell():New(oSection4,"JANEIRO"	,"   ",	STR0020 + CRLF + STR0033,"@R 9999,999.99",12,, {|| aValor[1] })
TRCell():New(oSection4,"FEVEREIRO"	,"   ", STR0021 + CRLF + STR0033,"@R 9999,999.99",12,, {|| aValor[2] })
TRCell():New(oSection4,"MARCO"		,"   ", STR0022 + CRLF + STR0033,"@R 9999,999.99",12,, {|| aValor[3] })
TRCell():New(oSection4,"ABRIL"		,"   ", STR0023 + CRLF + STR0033,"@R 9999,999.99",12,, {|| aValor[4] })
TRCell():New(oSection4,"MAIO"		,"   ", STR0024 + CRLF + STR0033,"@R 9999,999.99",12,, {|| aValor[5] })
TRCell():New(oSection4,"JUNHO"		,"   ", STR0025 + CRLF + STR0033,"@R 9999,999.99",12,, {|| aValor[6] })
TRCell():New(oSection4,"JULHO"		,"   ", STR0026 + CRLF + STR0033,"@R 9999,999.99",12,, {|| aValor[7] })
TRCell():New(oSection4,"AGOSTO"		,"   ", STR0027 + CRLF + STR0033,"@R 9999,999.99",12,, {|| aValor[8] })
TRCell():New(oSection4,"SETEMBRO"	,"   ", STR0028 + CRLF + STR0033,"@R 9999,999.99",12,, {|| aValor[9] })
TRCell():New(oSection4,"OUTUBRO"	,"   ", STR0029 + CRLF + STR0033,"@R 9999,999.99",12,, {|| aValor[10]})
TRCell():New(oSection4,"NOVEMBRO"	,"   ", STR0030 + CRLF + STR0033,"@R 9999,999.99",12,, {|| aValor[11]})
TRCell():New(oSection4,"DEZEMBRO"	,"   ", STR0031 + CRLF + STR0033,"@R 9999,999.99",12,, {|| aValor[12]})
TRCell():New(oSection4,"TOTAL"		,"   ",STR0032,"@R 9999,999.99",12,, {|| nTotal:= 0, aEval(aValor,{ |X| nTotal += X }), nTotal})	 	

TRPosition():New(oSection4,"RA1",2,{|| RhFilial("RA1",TRA->TR_FILIAL)+ cCurso })

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Quinta Secao: C.Custo por Horas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection5 := TRSection():New(oSection3,STR0037 + " -" + STR0012,{"RA4","RA1"},aOrdem,/*Campos do SX3*/,/*Campos do SIX*/)	//"Custo do Treinamento Anual por Curso"
oSection5 :SetTotalInLine(.F.)   
oSection5:SetHeaderBreak(.T.) 

TRCell():New(oSection5,"RA4_CURSO","RA4",CRLF + "Curso",,,,{|| cCurso })	//Codigo do Curso
TRCell():New(oSection5,"RA1_DESC","RA1",,,,,{|| Posicione("RA1",1,xFilial("RA1")+cCurso,+space(5)+"RA1_DESC") }) //Descricao do Curso  
TRCell():New(oSection5,"JANEIRO"	,"   ",	STR0020 + CRLF + STR0034,"@R 9999.99",6,, {|| aHoras[1] })
TRCell():New(oSection5,"FEVEREIRO"	,"   ", STR0021 + CRLF + STR0034,"@R 9999.99",6,, {|| aHoras[2] })
TRCell():New(oSection5,"MARCO"		,"   ", STR0022 + CRLF + STR0034,"@R 9999.99",6,, {|| aHoras[3] })
TRCell():New(oSection5,"ABRIL"		,"   ", STR0023 + CRLF + STR0034,"@R 9999.99",6,, {|| aHoras[4] })
TRCell():New(oSection5,"MAIO"		,"   ", STR0024 + CRLF + STR0034,"@R 9999.99",6,, {|| aHoras[5] })
TRCell():New(oSection5,"JUNHO"		,"   ", STR0025 + CRLF + STR0034,"@R 9999.99",6,, {|| aHoras[6] })
TRCell():New(oSection5,"JULHO"		,"   ", STR0026 + CRLF + STR0034,"@R 9999.99",6,, {|| aHoras[7] })
TRCell():New(oSection5,"AGOSTO"		,"   ", STR0027 + CRLF + STR0034,"@R 9999.99",6,, {|| aHoras[8] })
TRCell():New(oSection5,"SETEMBRO"	,"   ", STR0028 + CRLF + STR0034,"@R 9999.99",6,, {|| aHoras[9] })
TRCell():New(oSection5,"OUTUBRO"	,"   ", STR0029 + CRLF + STR0034,"@R 9999.99",6,, {|| aHoras[10]})
TRCell():New(oSection5,"NOVEMBRO"	,"   ", STR0030 + CRLF + STR0034,"@R 9999.99",6,, {|| aHoras[11]})
TRCell():New(oSection5,"DEZEMBRO"	,"   ", STR0031 + CRLF + STR0034,"@R 9999.99",6,, {|| aHoras[12]})
TRCell():New(oSection5,"TOTAL"		,"   ",STR0032,"@R 9999.99",6,, {|| nTotal:= 0, aEval(aHoras,{ |X| nTotal += X }), nTotal})	 	

TRPosition():New(oSection5,"RA1",2,{|| RhFilial("RA1",TRA->TR_FILIAL)+ cCurso })

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
Static Function PrintReport(oReport) 

Local nOrdem		:= oReport:Section(1):GetOrder()
Local oSection1
Local oSection2
Local cFiltroRA4	:= ""
Local cFiltroSRA	:= ""
Local cFiltroSQ3	:= ""
Local aIndCond		:= {}
Local aFields		:= {}
Local cAcessaRA4	:= &("{ || " + ChkRH("TRM040","RA4","2") + "}")
Local cSituacao		:= ""
Local nFerProg		:= 0
Local cSitFol		:= ""
Local cTit			:= ""
Local aLogCargo		:= {}
Local aLogTitle		:= {}
Local lExcLogCargo	:= .F.
Local cMainTitle	:= ""
Local cTitle1		:= ""
Local nX 			:= 0

Private oTempTable	:= Nil
Private cCurso		:= ""

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
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                                   ³
//³ MV_PAR01        //  Filial?                                            ³
//³ MV_PAR02        //  Matricula ?                                        ³
//³ MV_PAR03        //  Centro de Custo?                                   ³
//³ MV_PAR04        //  Nome?                                              ³
//³ MV_PAR05        //  Curso?                                             ³
//³ MV_PAR06        //  Grupo?                                             ³
//³ MV_PAR07        //  Depto?                                             ³
//³ MV_PAR08        //  Cargo?                                             ³
//³ MV_PAR09        //  Ano?                                               ³
//³ MV_PAR10        //  Totais Em? 1- Valor; 2- Horas                      ³
//³ MV_PAR11        //  Situacoes?                                         ³ 
//³ MV_PAR12        //  Ferias Programadas?                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Transforma parametros Range em expressao (intervalo) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeAdvplExpr("TR040R")

cSituacao 	:= MV_PAR11
nFerProg  	:= MV_PAR12

If nOrdem = 1	//Relatorio por Curso

	oSection1 := If(MV_PAR10 = 1, oReport:Section(1), oReport:Section(2))	//Por Valor # Por Horas
	
	TRFunction():New(oSection1:Cell("JANEIRO")  ,/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection1:Cell("FEVEREIRO"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection1:Cell("MARCO")    ,/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection1:Cell("ABRIL")    ,/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection1:Cell("MAIO")     ,/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection1:Cell("JUNHO")    ,/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection1:Cell("JULHO")    ,/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection1:Cell("AGOSTO")   ,/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection1:Cell("SETEMBRO") ,/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection1:Cell("OUTUBRO")  ,/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection1:Cell("NOVEMBRO") ,/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection1:Cell("DEZEMBRO") ,/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection1:Cell("TOTAL")    ,/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/)
		
Else			//Relatorio por C.Custo 

	oSection1 := oReport:Section(3)	
	oSection2 := If(MV_PAR10 = 1, oSection1:Section(1), oSection1:Section(2))

	oBreakCC := TRBreak():New(oReport,oSection1:Cell("RA_CC"),STR0036) // "Total por C.Custo"
	
	TRFunction():New(oSection2:Cell("JANEIRO")  ,/*cId*/,"SUM",oBreakCC,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("FEVEREIRO"),/*cId*/,"SUM",oBreakCC,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("MARCO")    ,/*cId*/,"SUM",oBreakCC,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("ABRIL")    ,/*cId*/,"SUM",oBreakCC,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("MAIO")     ,/*cId*/,"SUM",oBreakCC,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("JUNHO")    ,/*cId*/,"SUM",oBreakCC,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("JULHO")    ,/*cId*/,"SUM",oBreakCC,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("AGOSTO")   ,/*cId*/,"SUM",oBreakCC,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("SETEMBRO") ,/*cId*/,"SUM",oBreakCC,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("OUTUBRO")  ,/*cId*/,"SUM",oBreakCC,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("NOVEMBRO") ,/*cId*/,"SUM",oBreakCC,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("DEZEMBRO") ,/*cId*/,"SUM",oBreakCC,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/)
	TRFunction():New(oSection2:Cell("TOTAL")    ,/*cId*/,"SUM",oBreakCC,/*cTitle*/,/*cPicture*/,/*uFormula*/,.F.,/*lEndReport*/,/*lEndPage*/) 

Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra RA4   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(MV_PAR01)	//RA4_FILIAL
	cFiltroRA4 := MV_PAR01
EndIf 

If !Empty(MV_PAR02)	//RA4_MAT 
	cFiltroRA4 += IIF(!Empty(cFiltroRA4)," .And. ","")
	cFiltroRA4 += MV_PAR02 
EndIf

If !Empty(MV_PAR05)	//RA4_CURSO  
	cFiltroRA4 += IIF(!Empty(cFiltroRA4)," .And. ","")
	cFiltroRA4 += MV_PAR05
EndIf

If !Empty(cFiltroRA4) 
	cFiltroRA4 += ' .And. Year(RA4_DATAIN) = ' + AllTrim(Str(MV_PAR09)) 	//Apenas Filtrar Registros do Ano definido no parametro.		
Else
	cFiltroRA4 += ' Year(RA4_DATAIN) = ' + AllTrim(Str(MV_PAR09)) 	//Apenas Filtrar Registros do Ano definido no parametro.		
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra SRA   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(MV_PAR03)	//RA_CC
	cFiltroSRA := MV_PAR03 
EndIf

If !Empty(MV_PAR04)	//RA_NOME  
	cFiltroSRA += IIF(!Empty(cFiltroSRA)," .And. ","")
	cFiltroSRA += MV_PAR04
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Filtra SQ3   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !Empty(MV_PAR06)	//Q3_GRUPO
	cFiltroSQ3 := MV_PAR06
EndIf  

If !Empty(MV_PAR07)	//Q3_DEPTO 
	cFiltroSQ3 += IIF(!Empty(cFiltroSQ3)," .And. ","")
	cFiltroSQ3 += MV_PAR07 
EndIf

If !Empty(MV_PAR08)	//Q3_CARGO
	cFiltroSQ3 += IIF(!Empty(cFiltroSQ3)," .And. ","")
	cFiltroSQ3 += MV_PAR08 
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Definicao do filtro para a Tabela Principal e Secundaria ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection1:SetFilter(cFiltroRA4,,,"RA4")
oSection1:SetFilter(cFiltroSRA,,,"SRA")
oSection1:SetFilter(cFiltroSQ3,,,"SQ3")
   
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Arquivo Principal: Cursos do Funcionario ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("RA4")
dbSetOrder(2)
RA4->( DbGoTop() )
oReport:SetMeter(RecCount())

//Inicializa
aFill(aHoras,0)
aFill(aValor,0)

If nOrdem = 1   //Por Curso
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Centralizacao das Celulas do Relatorio ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oSection1:Cell("JANEIRO"):SetHeaderAlign("CENTER")
	oSection1:Cell("FEVEREIRO"):SetHeaderAlign("CENTER")
	oSection1:Cell("MARCO"):SetHeaderAlign("CENTER")
	oSection1:Cell("ABRIL"):SetHeaderAlign("CENTER")
	oSection1:Cell("MAIO"):SetHeaderAlign("CENTER")
	oSection1:Cell("JUNHO"):SetHeaderAlign("CENTER")
	oSection1:Cell("JULHO"):SetHeaderAlign("CENTER")
	oSection1:Cell("AGOSTO"):SetHeaderAlign("CENTER")
	oSection1:Cell("SETEMBRO"):SetHeaderAlign("CENTER")
	oSection1:Cell("OUTUBRO"):SetHeaderAlign("CENTER")
	oSection1:Cell("NOVEMBRO"):SetHeaderAlign("CENTER")
	oSection1:Cell("DEZEMBRO"):SetHeaderAlign("CENTER")
	oSection1:Cell("TOTAL"):SetHeaderAlign("CENTER")

	oSection1:Init()

	While !RA4->(Eof())

		cCurso 	:= RA4->RA4_CURSO 
			
		oReport:IncMeter()
		
		If oReport:Cancel()
			Exit
		EndIf
		
		While !RA4->(Eof()) .And. cCurso == RA4->RA4_CURSO
			Begin Sequence
				If !Eval(cAcessaRA4)
					break
				EndIf
				dbSelectArea("SRA")
				dbSetOrder(1)
				
				If dbSeek(RA4->RA4_FILIAL+RA4->RA4_MAT)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Situacao do Funcionario  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					cSitFol := TrmSitFol()
					cCargo 	:= fGetCargo(SRA->RA_MAT)
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Alimenta array com os registros que não ha cargo ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
					If Empty(cCargo)
						aAdd( aLogCargo,SRA->RA_FILIAL + Space(05) + SRA->RA_MAT + Space(04) + SRA->RA_NOME + Space(01) + RA4->RA4_CALEND + Space(07) + RA4->RA4_CURSO) 
					EndIf
						
					If	(!(cSitfol $ cSituacao) 	.And.	(cSitFol <> "P")) .Or.;
						(cSitfol == "P" .And. nFerProg == 2)
						Break
					EndIf
					nMes := Month(RA4->RA4_DATAIN)
					aHoras[nMes] := aHoras[nMes]  + RA4->RA4_HORAS
					aValor[nMes] := aValor[nMes]  + RA4->RA4_VALOR
				EndIf
			End Sequence
			dbSelectArea("RA4")
			dbSkip()
		EndDo
		
		For nX:= 1 to Len(aHoras)
			aHoras[nX] := fConvHr( aHoras[nX], 'H' )	
		Next
		
		oSection1:PrintLine()
		aFill(aHoras,0)
		aFill(aValor,0)
	EndDo
	oSection1:Finish()
Else  //Relatorio do Centro de custo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Centralizacao das Celulas do Relatorio ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
	oSection2:Cell("JANEIRO"):SetHeaderAlign("CENTER")
	oSection2:Cell("FEVEREIRO"):SetHeaderAlign("CENTER")
	oSection2:Cell("MARCO"):SetHeaderAlign("CENTER")
	oSection2:Cell("ABRIL"):SetHeaderAlign("CENTER")
	oSection2:Cell("MAIO"):SetHeaderAlign("CENTER")
	oSection2:Cell("JUNHO"):SetHeaderAlign("CENTER")
	oSection2:Cell("JULHO"):SetHeaderAlign("CENTER")
	oSection2:Cell("AGOSTO"):SetHeaderAlign("CENTER")
	oSection2:Cell("SETEMBRO"):SetHeaderAlign("CENTER")
	oSection2:Cell("OUTUBRO"):SetHeaderAlign("CENTER")
	oSection2:Cell("NOVEMBRO"):SetHeaderAlign("CENTER")
	oSection2:Cell("DEZEMBRO"):SetHeaderAlign("CENTER")
	oSection2:Cell("TOTAL"):SetHeaderAlign("CENTER")

	AADD(aFields,{"TR_FILIAL", "C", FWGETTAMFILIAL,          0                       } )
	AADD(aFields,{"TR_MAT",    "C", TamSx3("RA_MAT")[1],     TamSx3("RA_MAT")[2]     } )
	AADD(aFields,{"TR_CC",     "C", TamSx3("RA_CC")[1],      TamSx3("RA_CC")[2]      } )
	AADD(aFields,{"TR_CURSO",  "C", TamSx3("RA4_CURSO")[1],  TamSx3("RA4_CURSO")[2]  } )  
	AADD(aFields,{"TR_CUSTO",  "N", TamSx3("RA4_VALOR")[1],  TamSx3("RA4_VALOR")[2]  } )  
	AADD(aFields,{"TR_HORAS",  "N", TamSx3("RA4_HORAS")[1],  TamSx3("RA4_HORAS")[2]  } )  
	AADD(aFields,{"TR_DATA",   "D", TamSx3("RA4_DATAIN")[1], TamSx3("RA4_DATAIN")[2] } )

	aIndCond := { "TR_CC", "TR_CURSO" }	// Centro de Custo + Curso

	oTempTable := FWTemporaryTable():New("TRA")
	oTempTable:SetFields( aFields )
	oTempTable:AddIndex( "01", aIndCond )
	oTempTable:Create()
	dbGoTop()

	dbSelectArea("RA4")
	dbSetOrder(1)
	dbGoTop()

	While !RA4->(Eof())
		
		If !Eval(cAcessaRA4)
			dbSkip()
			Loop
		EndIf
		
		dbSelectArea("SRA")
		dbSetOrder(1)
	
		If dbSeek(RA4->RA4_FILIAL+RA4->RA4_MAT)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Situacao do Funcionario  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSitFol := TrmSitFol()
			cCargo 	:= fGetCargo(SRA->RA_MAT)
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Alimenta array com os registros que não ha cargo ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
			If Empty(cCargo)
				aAdd( aLogCargo,SRA->RA_FILIAL + Space(05) + SRA->RA_MAT + Space(04) + SRA->RA_NOME + Space(01) + RA4->RA4_CALEND + Space(07) + RA4->RA4_CURSO) 
			EndIf
			
			If	(!(cSitfol $ cSituacao) 	.And.	(cSitFol <> "P")) .Or.;
				(cSitfol == "P" .And. nFerProg == 2)
				
				dbSelectArea("RA4")
				dbSkip()
				Loop
			EndIf
			
			RecLock("TRA",.T.)
				TRA->TR_FILIAL	:= RA4->RA4_FILIAL 
				TRA->TR_MAT		:= SRA->RA_MAT
				TRA->TR_CC		:= SRA->RA_CC
				TRA->TR_CURSO	:= RA4->RA4_CURSO
				TRA->TR_CUSTO	:= RA4->RA4_VALOR
				TRA->TR_HORAS	:= RA4->RA4_HORAS
				TRA->TR_DATA 	:= RA4->RA4_DATAIN
			MsUnlock()
			dbSelectArea("RA4")
			dbSkip()
		Else
			dbSelectArea("RA4")
			dbSkip()
		EndIf
		
	EndDo
	
	aHoras := Array(12)
	aValor := Array(12)
	
	aFill(aHoras,0)
	aFill(aValor,0)
	
	dbSelectArea("TRA")
	dbGotop()
	
	While !Eof()
		
		oReport:IncMeter()
		
		If oReport:Cancel()
			Exit
		EndIf
		
		cCC 	:= TRA->TR_CC 
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Impressao da Secao Pai ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		oSection1:Init()
		oSection1:PrintLine()
		oSection1:Finish()
		
		While !TRA->(Eof()) .And. cCC == TRA->TR_CC 
		 
			cCurso	:= TRA->TR_CURSO
			
			//While !Eof() .And. cCurso == TRA->TR_CURSO
			While !TRA->(Eof()) .And. cCc + cCurso == TRA->TR_CC + TRA->TR_CURSO
				
				nMes := Month(TRA->TR_DATA)
				
				aHoras[nMes] := aHoras[nMes]  + TRA->TR_HORAS
				aValor[nMes] := aValor[nMes]  + TRA->TR_CUSTO
				
				TRA->( dbSkip() )
			EndDo
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Impressao da Secao Filha ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oSection2:Init()
			oSection2:PrintLine()
			
			aFill(aHoras,0)
			aFill(aValor,0)
		EndDo
		
		oSection2:Finish()
		
	EndDo    
	
	dbSelectArea("TRA")
	dbCloseArea()
	oTempTable:Delete()
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Gera Arquivo Log com as Inconsistencias no vinculo Funcao x Cargo  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ( lExcLogCargo := !Empty(aLogCargo) )

	cMainTitle 	:= STR0038			//"Inconsistências na função ou cargo"
	cTitle1		:= Upper(STR0039)	//"Filial Matricula Funcionario                    Calendario Curso"

	aAdd(aLogTitle,cTitle1)

	If ( lExcLogCargo := MsgNoYes(STR0040, STR0001 + " - " + cMainTitle ) )	//"Foram encontradas inconsistências no vínculo Função x Cargo. Deseja gerar Log?"
		FMakeLog( { aLogCargo } , aLogTitle , , NIL , NIL , STR0001 + Space(01)+ "("+ cMainTitle+")","M","P",,.F. )
	EndIf
	
EndIf

Return Nil
