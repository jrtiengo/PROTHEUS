#include "protheus.ch"
#include "trm070.ch" 

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o       ³ TRM070   ³ Autor ³ Eduardo Ju            ³ Data ³ 16.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o    ³ Formulario para Avaliacoes (Testes)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso          ³ TRM070                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador  ³ Data   ³ BOPS ³  Motivo da Alteracao                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Carv.³31/07/14³TPZWAO³AIncluido o fonte da 11 para a 12 e efetuda ³±±
±±³             ³        ³      ³a limpeza.                                  ³±±
±±³Matheus M.   ³05/07/16³TVOH44³Ajuste no tratamento do tamanho da quebra   ³±±
±±³             ³        ³      ³de linha para formato Excel.                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function TRM070()

Local oReport
Local aArea := GetArea()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Pergunte("TRM070",.F.)
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

oReport := TReport():New("TRM070",STR0012,"TRM070",{|oReport| PrintReport(oReport)},STR0001+" "+STR0002)	//"Fomulário dos Teste"#"Este programa tem como objetivo imprimir os testes conforme parâmetros selecionados."

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Primeira Secao: Cabecalho				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1 := TRSection():New(oReport,STR0014,{"SQQ"}) 	//"Cabeçalho formulário"
oSection1:SetHeaderBreak(.T.)  
oSection1:SetLeftMargin(2)	//Identacao da Secao 
oSection1:SetEdit(.F.)		//Desabilitado Manipulacao das Secoes do Botao Personalizar

TRCell():New(oSection1,"QQ_TESTE","SQQ") 
TRCell():New(oSection1,"QQ_DESCRIC","SQQ")    
TRPosition():New(oSection1,"SQQ",1,{|| xFilial("SQQ") + mv_par01,.T.})

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criacao da Segunda Secao: Impressao de Cada Questao	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection2 := TRSection():New(oSection1,STR0013,{"SQQ","SQO","SQP","RBL"})	//"Questões do teste"
oSection2:SetHeaderBreak(.T.)  
oSection2:SetLeftMargin(3)	//Identacao da Secao
oSection2:SetEdit(.F.)		//Desabilitado Manipulacao das Secoes do Botao Personalizar

TRCell():New(oSection2,"QQ_QUESTAO","SQQ")
TRCell():New(oSection2,"QQ_ITEM","SQQ") 
TRCell():New(oSection2,"QO_QUEST","SQO")
TRCell():New(oSection2,"QO_ESCALA","SQO") 
TRCell():New(oSection2,"QP_ALTERNA","SQP",,"",,,{|| CHR(Val(SQP->QP_ALTERNA)+96)}) 
TRCell():New(oSection2,"QP_DESCRIC","SQP") 
TRCell():New(oSection2,"RBL_ITEM","RBL",,"",,,{|| CHR(Val(RBL->RBL_ITEM)+96) }) 
TRCell():New(oSection2,"RBL_DESCRI","RBL") 
TRPosition():New(oSection2,"SQO",1,{|| xFilial("SQO") + SQQ->QQ_QUESTAO,.T.})
TRPosition():New(oSection2,"SQP",1,{|| xFilial("SQP") + SQO->QO_QUESTAO,.T.})

Return oReport

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ReportDef() ³ Autor ³ Eduardo Ju          ³ Data ³ 16.05.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Impressao do Relatorio (Formulario para Testes)             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function PrintReport(oReport)

Local oSection1 := oReport:Section(1)
Local oSection2 := oReport:Section(1):Section(1)
Local cCodTeste	:= "" 
Local cTexto    := ""
Local cDetalhe  := ""
Local nLinha    := 0
Local nTamanho  := 0
Local nTamAux   := 0
Local i:= 0

dbSelectArea("SQQ")
dbSetOrder(1)
dbSeek(xFilial("SQQ")+mv_par01,.T.)
cInicio := "QQ_FILIAL+QQ_TESTE"
cFim	:= QQ_FILIAL+mv_par02

oReport:SetMeter(RecCount())

oSection1:Init(.F.)
oSection2:Init(.F.)	//Obs.: .F. - Nao exibe a identificacao da celula (Titulo do Campo de acordo SX3)

// - Efetua o tratamento para o tamanho correto de célula do Excel/BrOffice/LibreOffice.
nTamanho := Iif(oReport:nDevice == 4,254,round(oReport:PageWidth()/oReport:Char2Pix(" "),0)) //Tamanho maximo de caracteres que cabem na linha. Arredondado para baixo.

While !Eof() .And. &cInicio <= cFim
	
	oReport:IncMeter()
	
	If oReport:Cancel()
		Exit
	EndIf
		
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao da Primeira Secao: Cabecalho				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cCodTeste # SQQ->QQ_TESTE
		oReport:ThinLine()	//Imprime linha simples
		oReport:SkipLine()	//Salta uma linha 
		oReport:PrintText(STR0010,oReport:Row())	//"Nome:"
		oReport:Line(oReport:Row()+oReport:LineHeight(),oReport:Col(),oReport:Row()+oReport:LineHeight(),oReport:PageWidth())	//Imprime linha continua
		oReport:SkipLine()
		oReport:SkipLine()
		oReport:PrintText(STR0011,oReport:Row())	//"Avaliador:"
		oReport:Line(oReport:Row()+oReport:LineHeight(),oReport:Col(),oReport:Row()+oReport:LineHeight(),oReport:PageWidth())
		oReport:SkipLine()
		oReport:SkipLine()	
		oSection1:Cell("QQ_TESTE"):Execute()	//Executa comando para disponibilizar conteudo do campo por meio da GetText()
		oSection1:Cell("QQ_DESCRIC"):Execute()
		oReport:PrintText(STR0009+oSection1:Cell("QQ_TESTE"):GetText() + " - " + oSection1:Cell("QQ_DESCRIC"):GetText()) //"Avaliacao: "
		oReport:SkipLine()
		oReport:ThinLine()
		oReport:SkipLine()
		cCodTeste:= SQQ->QQ_TESTE
	EndIf	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao da Segunda Secao: Questoes				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SQO")
	dbSetOrder(1)
	
	If dbSeek(xFilial("SQO")+SQQ->QQ_QUESTAO)
		oSection2:Cell("QQ_ITEM"):Execute()
		oSection2:Cell("QO_QUEST"):Execute()
		
		cTexto   := Alltrim(oSection2:Cell("QO_QUEST"):GetText())
		nLinha   := MLCount(cTexto,nTamanho)
		cDetalhe := oSection2:Cell("QQ_ITEM"):GetText() + " - "
		
		For i := 1 to nLinha    
			cDetalhe += Memoline(cTexto,nTamanho-5,i,,.T.)
			oReport:PrintText(cDetalhe)
			cDetalhe := Space(5)
		Next i		
		
		oReport:SkipLine()	 
	EndIf   
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Impressao das Alternativas das Questoes				 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Empty(SQO->QO_ESCALA)
		dbSelectArea("SQP")
		dbSetOrder(1)
		If dbSeek(xFilial("SQP")+SQQ->QQ_QUESTAO)
			While !Eof() .And. xFilial("SQQ")+SQQ->QQ_QUESTAO == QP_FILIAL+QP_QUESTAO
				oSection2:Cell("QP_ALTERNA"):Execute()
				oSection2:Cell("QP_DESCRIC"):Execute()
				
				cTexto   := SQP->QP_DESCRIC
				nLinha   := MLCount(cTexto,nTamanho)
				cDetalhe := "( " + oSection2:Cell("QP_ALTERNA"):GetText() + " ) - "
				nTamAux  := Len(cDetalhe)
				
				For i := 1 to nLinha    
					cDetalhe += Memoline(cTexto,nTamanho-9,i,,.T.)
					oReport:PrintText(cDetalhe)
					cDetalhe := Space(nTamAux)
				Next i		
				
				SQP->( dbSkip() )
			EndDo 									
		Else
			For i := 1 To 5
				oReport:ThinLine()
				oReport:SkipLine()
			Next i
		EndIf
	Else
		dbSelectArea("RBL") 
		dbSetOrder(1)
		If dbSeek(xFilial("RBL")+SQO->QO_ESCALA)
			While !Eof() .And. xFilial("RBL")+SQO->QO_ESCALA == RBL->RBL_FILIAL+RBL->RBL_ESCALA
				oSection2:Cell("RBL_ITEM"):Execute()
				oSection2:Cell("RBL_DESCRI"):Execute()
				oReport:PrintText("( "+oSection2:Cell("RBL_ITEM"):GetText() + " ) - " + oSection2:Cell("RBL_DESCRI"):GetText())
				RBL->( dbSkip() )
			EndDo
		Else
			For i := 1 To 5
				oReport:ThinLine()
				oReport:SkipLine()
			Next i
		EndIf	
	EndIf
	
	DbSelectArea("SQQ")
	DbSkip()
	
	oReport:SkipLine()
End 

oSection2:Finish()
oSection1:Finish()

Return Nil