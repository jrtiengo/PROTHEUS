#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TRM080.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ TRM080   ³ Autor ³ Eduardo Ju            ³ Data ³ 07/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Relatorio de Avaliacoes Realizadas                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ TRM080                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³31/07/14³TPZWAO³AIncluido o fonte da 11 para a 12 e efetu-³±±
±±³            ³        ³      ³da a limpeza.                             ³±±
±±³Isabel N.   ³08/02/17³MRH-3233³Ajuste nos nomes dos campos RAI_RESULTA ³±±
±±³            ³        ³        ³p/RAI_RESULT e RAI_QUESTAO p/RAI_QUESTA,³±±
±±³            ³        ³        ³conforme cadastrados no Atusx.          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  

User Function TRM080()

Local oReport
Local aArea := GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("TR080R",.F.)
oReport := ReportDef()
oReport:PrintDialog()	

RestArea( aArea )

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportDef() ³ Autor ³ Eduardo Ju          ³ Data ³ 07.07.06 ³±±
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
Local oSection4
Local oSection5
Local oSection6
Local oSection7
Local oSection8
Local oSection9
Local oSection10

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:=TReport():New("TRM080",STR0003,"TR080R",{|oReport| PrintReport(oReport)},STR0001+" "+STR0002)	//"Avaliacoes Realizadas"#"Este programa tem como objetivo imprimir os testes realizados conforme parametros selecionados."
Pergunte("TR080R",.F.) 
                                             
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Primeira Secao: Calendario ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection1 := TRSection():New(oReport,STR0009 + " (" + STR0024 + ")",{"RAI"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//"Calendario"	
oSection1:SetTotalInLine(.F.)    
oSection1:SetHeaderBreak(.T.)

TRCell():New(oSection1,"RAI_CALEND","RAI")				//Calendario de Treinamento
TRCell():New(oSection1,"RA2_DESC","RA2","")			//Descricado do Calendario
TRCell():New(oSection1,"RAI_CURSO","RAI")				//Curso
TRCell():New(oSection1,"RA1_DESC","RA1","")			//Descricao do Curso  
TRCell():New(oSection1,"RA2_SINON","RA2",STR0018)		//Sinonimo do Curso
TRCell():New(oSection1,"RA9_DESCR","RA9","")			//Descricao do Sinonimo do Curso
TRCell():New(oSection1,"RAI_TURMA","RAI")				//Turma   

TRPosition():New(oSection1,"RA2",1,{|| xFilial("RA2",RAI->RAI_FILIAL)+ RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA})
TRPosition():New(oSection1,"RA1",1,{|| xFilial("RA1",RAI->RAI_FILIAL)+ RAI->RAI_CURSO})
TRPosition():New(oSection1,"RA9",2,{|| xFilial("RA9",RAI->RAI_FILIAL)+ RAI->RAI_CURSO})
TRPosition():New(oSection1,"RAI",1,{|| xFilial("RAI",RAI->RAI_FILIAL)+ RAI->RAI_CALEND + RAI->RAI_CURSO +RAI->RAI_TURMA +RAI->RAI_MAT+RAI->RAI_TESTE+RAI->RAI_QUESTA+RAI->RAI_ALTERN})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Segunda Secao: Funcionario  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection2 := TRSection():New(oSection1,STR0020,{"RAI"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)		//Funcionario	
oSection2:SetTotalInLine(.F.)
oSection2:SetHeaderBreak(.T.)
oSection2:SetLeftMargin(1)	//Identacao da Secao  
  
TRCell():New(oSection2,"RAI_FILIAL","RAI")				//Filial do Funcionario    
TRCell():New(oSection2,"RAI_MAT","RAI")					//Matricula do Funcionario
TRCell():New(oSection2,"RA_NOME","SRA")					//Nome do Funcionario
TRCell():New(oSection2,"RAI_TESTE","RAI")				//Codigo da Avaliacao
TRCell():New(oSection2,"QQ_DESCRIC","SQQ","")			//Descricao da Avaliacao  

TRPosition():New(oSection2,"SRA",1,{|| xFilial("SRA",RAI->RAI_FILIAL)+ RAI->RAI_MAT})
TRPosition():New(oSection2,"SQQ",1,{|| xFilial("SQQ",RAI->RAI_FILIAL)+ Alltrim(RAI->RAI_TESTE)})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Terceira Secao: Questoes    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection3:= TRSection():New(oSection2,STR0021,{"RAI"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//Questoes	
oSection3:SetTotalInLine(.F.)   
oSection3:SetHeaderBreak(.T.)
oSection3:SetLeftMargin(2)	//Identacao da Secao  

TRCell():New(oSection3,"RAI_QUESTA","RAI")				//Questao   
TRCell():New(oSection3,"RAI_ALTERN","RAI",,,,,{|| CHR(Val(RAI->RAI_ALTERN)+96)})	//Alternativa Selecionada   
TRCell():New(oSection3,"QP_PERCENT","SQP",STR0027,"@E 999.99",,,{|| SQP->QP_PERCENT}) //Percentual de cada alternativa da questao
TRCell():New(oSection3,"QO_PONTOS","SQO",STR0015,"@E 999.99",,,{|| SQO->QO_PONTOS * RAI->RAI_RESULT / 100 }) //Pontos de cada alternativa em relação aos pontos da questao (%)

TRPosition():New(oSection3,"SQO",1,{|| xFilial("SQO",RAI->RAI_FILIAL)+ RAI->RAI_QUESTA})

oSection3:SetTotalText({|| STR0012 }) //Total de Pontos 
TRFunction():New(oSection3:Cell("QO_PONTOS"),/*cId*/,"SUM",/*oBreak*/,/*cTitle*/,/*cPicture*/,/*uFormula*/,/*lEndSection*/,.F./*lEndReport*/,/*lEndPage*/)
 
//*** ANALITICO ***
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Quarta Secao: Calendario  ³ 
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection4 := TRSection():New(oReport,STR0009 + " (" + STR0025 + ")",{"RAI","RA2","RA1","RA9"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	
oSection4:SetTotalInLine(.F.) 
oSection4:SetHeaderBreak(.T.)

TRCell():New(oSection4,"RAI_CALEND","RAI")				//Calendario de Treinamento
TRCell():New(oSection4,"RA2_DESC","RA2","")			//Descricado do Calendario
TRCell():New(oSection4,"RAI_CURSO","RAI")				//Curso
TRCell():New(oSection4,"RA1_DESC","RA1","")			//Descricao do Curso  
TRCell():New(oSection4,"RA2_SINON","RA2",STR0018) 		//Sinonimo do Curso
TRCell():New(oSection4,"RA9_DESCR","RA9","")			//Descricao do Sinonimo do Curso
TRCell():New(oSection4,"RAI_TURMA","RAI")				//Turma        
TRPosition():New(oSection4,"RA2",1,{|| xFilial("RA2",RAI->RAI_FILIAL)+ RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA})
TRPosition():New(oSection4,"RA1",1,{|| xFilial("RA1",RAI->RAI_FILIAL)+ RAI->RAI_CURSO})
TRPosition():New(oSection4,"RA9",2,{|| xFilial("RA9",RAI->RAI_FILIAL)+ RAI->RAI_CURSO})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Quinta Secao: Funcionario  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection5 := TRSection():New(oSection4,STR0020,{"RAI","SRA","SQQ"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	
oSection5:SetTotalInLine(.F.)  
oSection5:SetHeaderBreak(.T.)
oSection5:SetLeftMargin(1)	//Identacao da Secao  
oSection5:OnPrintLine({|| oReport:GetFunction("TOTAL1"):ResetSection(),oReport:GetFunction("TOTAL2"):ResetSection(),oReport:GetFunction("TOTAL3"):ResetSection(),.T.})

TRCell():New(oSection5,"RAI_FILIAL","RAI")				//Filial do Funcionario    
TRCell():New(oSection5,"RAI_MAT","RAI")					//Matricula do Funcionario
TRCell():New(oSection5,"RA_NOME","SRA")					//Nome do Funcionario
TRCell():New(oSection5,"RAI_TESTE","RAI")				//Codigo da Avaliacao
TRCell():New(oSection5,"QQ_DESCRIC","SQQ","")			//Descricao da Avaliacao  

TRPosition():New(oSection5,"SRA",1,{|| xFilial("SRA",RAI->RAI_FILIAL)+ RAI->RAI_MAT})
TRPosition():New(oSection5,"SQQ",1,{|| xFilial("SQQ",RAI->RAI_FILIAL)+ Alltrim(RAI->RAI_TESTE)})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Sexta Secao: Questoes    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection6:= TRSection():New(oSection5,STR0021,{"RAI","SQO"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//Questoes	
oSection6:SetTotalInLine(.F.)   
oSection6:SetHeaderBreak(.T.)
oSection6:SetLeftMargin(2)	//Identacao da Secao  

TRCell():New(oSection6,"RAI_QUESTA","RAI")			//Questao     
TRCell():New(oSection6,"QO_QUEST","SQO","",,110)	//Descricao da Questao
TRCell():New(oSection6,"QO_DMEMO","SQO","",,,,{|| MSMM(SQO->QO_QUEST,,,,3)})		//Descricao da Questao (Memo)

TRPosition():New(oSection6,"SQO",1,{|| xFilial("SQO",RAI->RAI_FILIAL)+ RAI->RAI_QUESTA})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Setima Secao: Resposta das Questoes (Pai) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
oSection7 := TRSection():New(oSection6,STR0022,{"RAI"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)		//Respostas
oSection7:SetTotalInLine(.F.)
oSection7:SetHeaderBreak(.T.)
oSection7:SetLeftMargin(3)	//Identacao da Secao    

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Oitava Secao: Resposta Dissertativa (Filha 1) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection8 := TRSection():New(oSection7,STR0023,{"RAI","SQO"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//"Resposta Dissertativa"	
oSection8:SetHeaderBreak(.T.)
oSection8:SetLeftMargin(3)	//Identacao da Secao  

TRCell():New(oSection8,"RAI_ALTERN","RAI",,,,,{|| CHR(Val(RAI->RAI_ALTERN)+96)})	//Alternativa Selecionada   
TRCell():New(oSection8,"RAI_MRESPO","RAI")	//Resposta da Questao
TRCell():New(oSection8,"RAI_MEMO1","RAI",Alltrim(STR0016),,150,,{|| MSMM(RAI->RAI_MRESPO,,,,3)})		//Descricao Resposta da Questao (Memo)
TRCell():New(oSection8,"QP_PERCENT","SQP",STR0027,"@E 999.99",,,{|| SQP->QP_PERCENT}) //Percentual de cada alternativa da questao
TRCell():New(oSection8,"QO_PONTOS","SQO",STR0015,"@E 999.99",6,,{|| SQO->QO_PONTOS * RAI->RAI_RESULT / 100 }) //Pontos de cada alternativa da questao


oObj := TRFunction():New(oSection8:Cell("QO_PONTOS"),"TOTAL1", "SUM",,,,,.F.,	.T.,.F.,,)
oObj:Disable()     

TRPosition():New(oSection8,"SQO",1,{|| xFilial("SQO",RAI->RAI_FILIAL)+ RAI->RAI_QUESTA})

//Nao imprime cod campo memo
oSection8:Cell("RAI_ALTERN"):Disable()  
oSection8:Cell("RAI_MRESPO"):Disable() 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Nona Secao: Resposta por Selecao (Filha 2A) - RBL  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection9 := TRSection():New(oSection7,STR0014 + " - " + STR0026,{"RBL", "SQO"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)	//Alternativas
oSection9:SetHeaderBreak(.T.)
oSection9:SetLeftMargin(3)	//Identacao da Secao  
	
TRCell():New(oSection9,"ALTSEL","   ","",,3,,{|| If ( RAI->RAI_ALTERN == RBL->RBL_ITEM,"(X)","( )" ) }) //Alternativa respondida
TRCell():New(oSection9,"RBL_ITEM","RBL",,,,,{|| CHR(Val(RBL->RBL_ITEM)+96)})	//Alternativa Selecionada 
TRCell():New(oSection9,"RBL_DESCRI","RBL",STR0014,,141)	//Alternativas
TRCell():New(oSection9,"QP_PERCENT","SQP",STR0027,"@E 999.99",,,{|| SQP->QP_PERCENT}) //Percentual de cada alternativa da questao
TRCell():New(oSection9,"QO_PONTOS","SQO",STR0015,"@E 999.99",6,,{|| If ( RAI->RAI_ALTERN == RBL->RBL_ITEM, SQO->QO_PONTOS * RAI->RAI_RESULT / 100, 0) }) //Pontos de cada alternativa da questao (%)


oObj := TRFunction():New(oSection9:Cell("QO_PONTOS"),"TOTAL2", "SUM",,,,,.F.,.T.,.F.,,)
oObj:Disable()

TRPosition():New(oSection9,"SQO",1,{|| xFilial("SQO",RAI->RAI_FILIAL)+ RAI->RAI_QUESTA})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Decima Secao: Resposta por Selecao (Filha 2B) - SQP ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection10 := TRSection():New(oSection7,STR0014,{"SQP", "SQO"},/*aOrdem*/,/*Campos do SX3*/,/*Campos do SIX*/)		//Alternativas
oSection10:SetHeaderBreak(.T.)
oSection10:SetLeftMargin(3)	//Identacao da Secao  

TRCell():New(oSection10,"ALTSEL","   ","",,3,,{|| If ( RAI->RAI_ALTERN == SQP->QP_ALTERNA,"(X)","( )" ) }) //Alternativa respondida		
TRCell():New(oSection10,"QP_ALTERNA","SQP","",,,,{|| CHR(Val(SQP->QP_ALTERNA)+96)})	//Alternativa Selecionada 
TRCell():New(oSection10,"QP_DESCRIC","SQP",STR0014,,141)	//Alternativas
TRCell():New(oSection10,"QP_PERCENT","SQP",STR0027,"@E 999.99",,,{|| SQP->QP_PERCENT}) //Percentual de cada alternativa da questao 
TRCell():New(oSection10,"QO_PONTOS","SQO", STR0015,"@E 999.99",6,,{|| If ( RAI->RAI_ALTERN == SQP->QP_ALTERNA, SQO->QO_PONTOS * RAI->RAI_RESULT / 100,0) }) //Pontos de cada alternativa da questao (%)


oObj := TRFunction():New(oSection10:Cell("QO_PONTOS"),"TOTAL3","SUM",,,,,.F.,.F.,.F.,,)
oObj:Disable()

oSection5:SetTotalText({|| STR0012 })  //"Total de Pontos"
TRFunction():New(oSection10:Cell("QO_PONTOS"),"TOTAL3","ONPRINT",,,,{|| oReport:GetFunction("TOTAL1"):SectionValue()+oReport:GetFunction("TOTAL2"):SectionValue()+oReport:GetFunction("TOTAL3"):SectionValue()},.T.,.F.,.F.,oSection5,)

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
Static Function PrintReport(oReport)

Local oSection1 := If ( MV_PAR10 = 1,(If(MV_PAR11 = 1, oReport:Section(2), oReport:Section(1))),oReport:Section(1) )
Local oSection2 := oSection1:Section(1) 
Local oSection3 := oSection2:Section(1)
Local oSection4 := oSection3:Section(1)
Local cFiltro 	:= ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros                         ³
//³ MV_PAR01        //  Filial                                   ³ 
//³ MV_PAR02        //  Calendario                               ³ 
//³ MV_PAR03        //  Curso                                    ³ 
//³ MV_PAR04        //  Turma                                    ³ 
//³ MV_PAR05        //  Matricula                                ³ 
//³ MV_PAR06        //  Teste               					 ³ 
//³ MV_PAR07        //  Nota De                                  ³ 
//³ MV_PAR08        //  Nota Ate                                 ³ 
//³ MV_PAR09        //  Tipo Avaliacao                           ³ 
//³ MV_PAR10        //  Relatorio: Analitico / Sintetico         ³
//³ MV_PAR11        //  Imp.Todas Alternat.: Sim / Nao           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Transforma parametros Range em expressao (intervalo) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeAdvplExpr("TR080R")	                                  

If !Empty(MV_PAR01)
	cFiltro:= MV_PAR01 
EndIf  
	
If !Empty(MV_PAR02)
	cFiltro += IIF(!Empty(cFiltro)," .And. ","")
	cFiltro += MV_PAR02 
EndIf  
	
If !Empty(MV_PAR03)
	cFiltro += IIF(!Empty(cFiltro)," .And. ","")
	cFiltro += MV_PAR03
EndIf  
	
If !Empty(MV_PAR04)
	cFiltro += IIF(!Empty(cFiltro)," .And. ","")
	cFiltro += MV_PAR04 
EndIf  	       
	
If !Empty(MV_PAR05)
	cFiltro += IIF(!Empty(cFiltro)," .And. ","") 
	cFiltro += MV_PAR05
EndIf   

If !Empty(MV_PAR06)
	cFiltro += IIF(!Empty(cFiltro)," .And. ","") 
	cFiltro += MV_PAR06 
EndIf  

If !Empty(MV_PAR09)
	cFiltro += IIF(!Empty(cFiltro)," .And. ","")
	cFiltro += MV_PAR09
EndIf  
	
oSection1:SetFilter(cFiltro)
	       
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Condicao para Impressao   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection2:SetParentFilter({|cParam| RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA == cParam},{|| RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA})
oSection3:SetParentFilter({|cParam| RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA+RAI->RAI_MAT+RAI->RAI_TESTE == cParam},{|| RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA+RAI->RAI_MAT+RAI->RAI_TESTE})

If MV_PAR10 == 1 .And. MV_PAR11 == 1	//Imprime Analitico e Todas as alternativas

	oSection4:SetParentFilter({|cParam| RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA+RAI->RAI_MAT+RAI->RAI_TESTE+RAI->RAI_QUESTA == cParam},{|| RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA+RAI->RAI_MAT+RAI->RAI_TESTE+RAI->RAI_QUESTA})
	oSection4:SetLineCondition({|| fCondResp(oSection3, oSection4) })	
EndIf 
             
If MV_PAR10 = 2 
	oSection3:Hide()
EndIf

oReport:SetMeter(RAI->(LastRec()))	
oSection1:Print() //Imprimir 

Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³fCondResp() ³ Autor ³ Eduardo Ju          ³ Data ³ 07.07.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Impressao da Resposta                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fCondResp(oSection3,oSection4)
	
	//Tipo de Resposta
	If RAI->RAI_ALTERN == "00" .Or. Empty(RAI->RAI_ALTERN)	//Dissertativa 
		oSection4:Section(1):Enable()
		oSection4:Section(2):Disable()	//RBL
		oSection4:Section(3):Disable() //SQP
			
		oSection3:Cell("QO_QUEST"):SetLineBreak() //Impressao de campo Memo
		oSection3:Cell("QO_DMEMO"):SetLineBreak() //Impressao de campo Memo
	
		oSection4:Section(1):Cell("RAI_MEMO1"):SetLineBreak() //Impressao de campo Memo   	
		oSection4:Section(1):SetParentFilter({|cParam| RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA+RAI->RAI_MAT+RAI->RAI_TESTE+RAI->RAI_QUESTA == cParam},{|| RAI->RAI_CALEND+RAI->RAI_CURSO+RAI->RAI_TURMA+RAI->RAI_MAT+RAI->RAI_TESTE+RAI->RAI_QUESTA})
	
	Else //Alternativa	
		oSection4:Section(1):Disable()	//Dissertativa
	
		If RBL->( dbSeek( xFilial("RBL", RAI->RAI_FILIAL) + SQO->QO_ESCALA ) )
			
			oSection4:Section(2):Enable()
			oSection4:Section(3):Disable()
			oSection4:Section(2):SetRelation({|| xFilial("RBL", RAI->RAI_FILIAL) + SQO->QO_ESCALA }, "RBL",1,.T.)
			oSection4:Section(2):SetParentFilter({|cParam| RBL->RBL_FILIAL + RBL->RBL_ESCALA == cParam},{|| xFilial("RBL",RAI->RAI_FILIAL) + SQO->QO_ESCALA})
	
		ElseIf SQP->(dbSeek( xFilial("SQP", RAI->RAI_FILIAL) + RAI->RAI_QUESTA ) )
		
			oSection4:Section(2):Disable()
			oSection4:Section(3):Enable()
			oSection4:Section(3):SetRelation({|| xFilial("SQP", RAI->RAI_FILIAL) + RAI->RAI_QUESTA}, "SQP",1,.T.)
			oSection4:Section(3):SetParentFilter({|cParam| SQP->QP_FILIAL + SQP->QP_QUESTAO == cParam}, {|| xFilial("SQP", RAI->RAI_FILIAL) + RAI->RAI_QUESTA})		
								
		EndIf		
		
	EndIf	

Return .T.
