#include 'rwmake.ch'
#Include "MATR100.ch"
#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ MATR100  ³ Autor ³ Nereu Humberto Junior ³ Data ³ 06.06.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relacao das Solicitacoes de Compras                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function SCIR100() 

Local oReport

//If FindFunction("TRepInUse") .And. TRepInUse()
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := ReportDef()
	oReport:PrintDialog()
//Else
//	MATR100R3()
//EndIf

Return
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³Nereu Humberto Junior  ³ Data ³06.06.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local oReport 
Local oSection1
Local oCell         
Local aOrdem := {}

AjustaSX1()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oReport:= TReport():New("MATR100",STR0005,"MTR100", {|oReport| ReportPrint(oReport)},STR0001+" "+STR0002) //"Relacao de Solicitacoes de Compras"##"Emite um relacao para controle das solicitacoes cadastradas ,"##"seus respectivos pedidos e prazos de entrega."
oReport:SetLandscape()    
oReport:SetTotalInLine(.F.)
Pergunte("MTR100",.F.)
Aadd( aOrdem, STR0003 ) //" Por Solicitacao    "
Aadd( aOrdem, STR0004 ) //" Por Produto        "

oSection1 := TRSection():New(oReport,STR0022,{"SC1","SB1","SC7","SA2"},aOrdem) //"Relacao de Solicitacoes de Compras"
oSection1:SetTotalInLine(.F.)
oSection1:SetHeaderPage()
oSection1:SetNoFilter("SB1")
oSection1:SetNoFilter("SC7")
oSection1:SetNoFilter("SA2")

TRCell():New(oSection1,"C1_NUM"		,"SC1",STR0024+CRLF+STR0025/*Titulo*/	,/*Picture*/,TamSX3("C1_NUM")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/) // "Numero"##"SC"
TRCell():New(oSection1,"C1_ITEM"	,"SC1",STR0026+CRLF+STR0025/*Titulo*/	,/*Picture*/,TamSX3("C1_ITEM")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/) // "Item"##"SC"
TRCell():New(oSection1,"C1_PRODUTO"	,"SC1",/*Titulo*/						,/*Picture*/,TamSX3("C1_PRODUTO")[1]+15,/*lPixel*/,/*{|| code-block de impressao }*/,/**/, /**/, /**/, /**/, /**/,.F.)
TRCell():New(oSection1,"C1_DESCRI"	,"SC1",/*Titulo*/						,/*Picture*/,20			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"B1_TIPO"	,"SB1",STR0027/*Titulo*/				,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Tp"
TRCell():New(oSection1,"B1_GRUPO"	,"SB1",/*Titulo*/						,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"C1_QUANT"	,"SC1",/*Titulo*/						,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"C1_UM"		,"SC1",STR0028/*Titulo*/				,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"UM"
TRCell():New(oSection1,"C1_CC"		,"SC1",/*Titulo*/						,/*Picture*/,20			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"C1_EMISSAO"	,"SC1",STR0029+CRLF+STR0030/*Titulo*/	,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Emissao"
TRCell():New(oSection1,"C1_DATPRF"	,"SC1",STR0031+CRLF+STR0025/*Titulo*/	,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Entrega"##"SC"
TRCell():New(oSection1,"C1_SOLICIT"	,"SC1",/*Titulo*/						,/*Picture*/,9			,/*lPixel*/,/*{|| code-block de impressao }*/)
TRCell():New(oSection1,"dDtPrazo"	,"   ",STR0019+CRLF+STR0023,/*Picture*/	,/*Tamanho*/,/*lPixel*/	,{||SomaPrazo(SC1->C1_DATPRF, - CalcPrazo(SC1->C1_PRODUTO,SC1->C1_QUANT))}) //"Dt.Limite"##"de Compra"
TRCell():New(oSection1,"nSaldo"		,"   ",STR0020,/*Picture*/,/*Tamanho*/	,/*lPixel*/,/*{|| code-block de impressao }*/) //"Saldo SC"

TRCell():New(oSection1,"C7_NUM"		,"SC7",STR0032+CRLF+STR0033/*Titulo*/	,/*Picture*/,TamSX3("C7_NUM")[1]+1,/*lPixel*/,/*{|| code-block de impressao }*/) //"Numero"##"PC"
TRCell():New(oSection1,"C7_FORNECE"	,"SC7",STR0034+CRLF+STR0033,/*Picture*/	,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Fornec."##"PC"
TRCell():New(oSection1,"C7_LOJA"	,"SC7",STR0035+CRLF+STR0033,/*Picture*/	,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Lj"##"PC"

TRCell():New(oSection1,"C1_FORNECE"	,"SC1",STR0034+CRLF+STR0025,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Fornec."##"SC"
TRCell():New(oSection1,"C1_LOJA"	,"SC1",STR0035+CRLF+STR0025,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	

TRCell():New(oSection1,"A2_NOME"	,"SA2",AllTrim(RetTitle("A2_NOME")),/*Picture*/,38/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)	
TRCell():New(oSection1,"C7_EMISSAO"	,"SC7",STR0030+CRLF+STR0033,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/) //"Emissao"##"PC"

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³Nereu Humberto Junior  ³ Data ³06.06.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)

Local oSection1 := oReport:Section(1) 
Local nOrdem    := oReport:Section(1):GetOrder() 
Local lFirst    := .T.
Local lCotacao  := .F.
Local lPedido   := .F.
Local cNum      := "" 
Local cCotacao  := ""

Local cVarAux1 := SUPERGETMV("ES_SOLSUP",.F.,"000000")
Local cVarAux4 := RetCodUsr()
Local oBreak
Local aIndex	:= {}
#IFNDEF TOP
	Local nIndex := 0
	Local nI
#ENDIF	

If nOrdem == 1
	oBreak := TRBreak():New(oSection1,oSection1:Cell("C1_NUM"),STR0015,.F.) //"Total  -  "
ElseIf nOrdem == 2
	oBreak := TRBreak():New(oSection1,oSection1:Cell("C1_PRODUTO"),STR0015,.F.) //"Total  -  "
Endif
TRFunction():New(oSection1:Cell("C1_QUANT"),NIL,"SUM",oBreak,"",/*cPicture*/,/*uFormula*/,.F.,.F.) 
TRFunction():New(oSection1:Cell("nSaldo"),NIL,"SUM",oBreak,"",/*cPicture*/,/*uFormula*/,.F.,.F.) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao do fluxo do relatório                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR06 == 1
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abre o SC7 em outra area para criar uma nova IndRegua        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC7")  // ChkFile() precisa da tabela (SC7) criada
	ChkFile('SC7',.F.,'TMP')
	aADD(aIndex,CriaTrab(NIL,.F.))
	IndRegua("TMP",aIndex[Len(aIndex)],"C7_FILIAL+C7_NUMCOT+C7_PRODUTO")
	dbSelectArea("SC7")
	aADD(aIndex,CriaTrab(NIL,.F.))
	IndRegua("SC7",aIndex[Len(aIndex)],"C7_FILIAL+C7_NUMSC+C7_ITEMSC+C7_PRODUTO")
	#IFNDEF TOP
		nIndex := RetIndex("SC7")
		dbSetIndex(aIndex[2]+OrdbagExt())
		dbSetOrder(nIndex+1)
	#ENDIF
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o usuario escolher a opcao que lista as SC's canceladas   ³
//³ pelo sistema ,e' necessario ativar as deletadas.             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR03 == 3
	SET DELE OFF
Endif

oReport:SetMeter(SC1->(LastRec()))

oSection1:Init()

dbSelectArea("SC1")
dbSetOrder(nOrdem)
If nOrdem == 1
	dbSeek(xFilial("SC1")+MV_PAR01,.T.)
Else
	dbSeek(xFilial("SC1"))
EndIf
While !oReport:Cancel() .And. SC1->(!Eof()) .And. SC1->C1_FILIAL == xFilial() .And.;
	IIf(nOrdem==1,C1_NUM <= MV_PAR02,.T.)

	If oReport:Cancel()
		Exit
	EndIf
	
	oReport:IncMeter()

	cNum := SC1->C1_NUM
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra as solicitacoes maior que o numero definido           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If C1_NUM < mv_par01 .Or. C1_NUM > mv_par02
		dbSkip()
		Loop
	Endif       
	
	
	IF ! cVarAux4 $ cVarAux1
		IF C1_USER <> cVarAux4
			dbSkip()
			Loop
		Endif       
	end

	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra as solicitacoes cancelados pelo sistema               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (mv_par03 == 3 .And. !Deleted()) .Or. (mv_par03 == 3 .And. Deleted() .And. !(STR0021$C1_OBS)) //"CANCELADA PELO SISTEMA."
		dbSkip()
		Loop
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra as solicitacoes de importacao                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par08 == 2 .And. ;
			(!Empty(C1_COTACAO) .And. C1_COTACAO == "IMPORT")
		dbSkip()
		Loop
	Endif
				
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra as solicitacoes em aberto gerada cotacao ou pedido    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par03 == 2 .And. ;
			(C1_QUANT <= C1_QUJE  .Or. (!Empty(C1_COTACAO) .And. (C1_COTACAO <> "IMPORT" .And. C1_COTACAO <> "IMPORX")) .Or. !Empty(C1_RESIDUO))  // BOPS 089411
		dbSkip()
		Loop
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra as solicitacoes completamente atendidas               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par03 == 5 .And. C1_QUANT == C1_QUJE
		dbSkip()
		Loop
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica intervalo de data de emissao                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (C1_EMISSAO < mv_par04 .Or. C1_EMISSAO > mv_par05)
		dbSkip()
		Loop
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra as solicitacoes nao entregue                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If mv_par03 == 4
		If !Empty(C1_COTACAO) .And. C1_COTACAO <> "XXXXXX"
			nRegSC1 := SC1->(RecNo())
			nOrdSC1 := SC1->( IndexOrd()) 
            cCotSC1 := SC1->C1_COTACAO
            cProSC1 := SC1->C1_PRODUTO
            cItPSC1 := SC1->C1_ITEMPED 
			nQtdSC1 := 0
            nQtdSC7 := 0
            lPedido := .F. 
			dbSelectArea("SC7")
			dbSetOrder(2)
			dbSeek(xFilial("SC7")+SC1->C1_PRODUTO)
			While !Eof() .And. xFilial("SC7")+cProSC1 == C7_FILIAL+C7_PRODUTO
				If SC7->C7_NUMCOT == cCotSC1 .And. SC7->C7_ITEM == cItPSC1             
					lPedido := .T.	 
					nQtdSC7 += If(SC7->C7_RESIDUO == "S",SC7->C7_QUANT,SC7->C7_QUJE)

					dbSelectArea("SC8")
					dbSetOrder(3)
					MsSeek(xFilial("SC8")+SC7->C7_NUMCOT+SC7->C7_PRODUTO+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_NUM+SC7->C7_ITEM)

					dbSelectArea("SC1")
					dbSetOrder(5)
					MsSeek(xFilial("SC1")+SC8->C8_NUM+SC8->C8_PRODUTO+SC8->C8_IDENT)						
					While ( !Eof() .And. xFilial("SC1") == SC1->C1_FILIAL .And. SC8->C8_NUM == SC1->C1_COTACAO .And.;
							          SC8->C8_PRODUTO == SC1->C1_PRODUTO .And. SC8->C8_IDENT == SC1->C1_IDENT .And. ;
							          SC8->C8_NUMPED == SC1->C1_PEDIDO .And. SC8->C8_ITEMPED == SC1->C1_ITEMPED )
						nQtdSC1 += SC1->C1_QUANT
						dbSelectArea("SC1")
						dbSkip()
                    EndDo 
				Endif
				dbSelectArea("SC7")
				dbSkip()
			EndDo

			dbSelectArea("SC1")
			dbSetOrder(nOrdSC1)
			MsGoto(nRegSC1)

            If lPedido	 	
				nSldEntre := nQtdSC1 - nQtdSC7				
            Else 
				nSldEntre := SC1->C1_QUANT				
            EndIf 

		Else
			nSldEntre := SC1->C1_QUANT
			dbSelectArea("SC7")
			dbSetOrder(2)
			dbSeek(xFilial("SC7")+SC1->C1_PRODUTO)
			While !Eof() .And. xFilial( "SC7" ) +SC1->C1_PRODUTO == C7_FILIAL+C7_PRODUTO
				If C7_NUMSC == SC1->C1_NUM .And. C7_ITEMSC == SC1->C1_ITEM
					nSldEntre -= If(SC7->C7_RESIDUO == "S",SC7->C7_QUANT,SC7->C7_QUJE)
				Endif
				dbSelectArea("SC7")
				dbSkip()
			EndDo
		Endif
		
		If nSldEntre <= 0
			dbSelectArea("SC1")
			dbSkip()
			Loop
		Endif

	Endif

	dbSelectArea("SC1")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Filtra Tipo de SCs Firmes ou Previstas                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !MtrAValOP(mv_par07, 'SC1')
		dbSkip()
		Loop
	EndIf

	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSeek(xFilial("SB1")+SC1->C1_PRODUTO)		

	If MV_PAR06 == 1                                        
		oSection1:Cell("C1_FORNECE"):Disable()
		oSection1:Cell("C1_LOJA"):Disable()
		
		If Empty(SC1->C1_COTACAO) .Or. SC1->C1_COTACAO == "XXXXXX" .Or. SC1->C1_COTACAO == "IMPORX" 
			lFirst := .T.
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona no arquivo de produtos                             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("SB1")
			dbSetOrder(1)
			dbSeek(xFilial("SB1")+SC1->C1_PRODUTO)		
			
			cAliasSC7 := "SC7"
			dbSelectArea("SC7")
			If dbSeek(xFilial()+SC1->C1_NUM+SC1->C1_ITEM+SC1->C1_PRODUTO)
				While !Eof() .and. C7_FILIAL+C7_NUMSC+C7_ITEMSC == xFilial("SC7")+SC1->C1_NUM+SC1->C1_ITEM
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Filtra Tipo de SCs Firmes ou Previstas                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !MtrAValOP(mv_par07, "SC7" )
						dbSkip()
						Loop
					EndIf
					
					dbSelectArea("SA2")
					dbSeek(xFilial("SA2")+(cAliasSC7)->C7_FORNECE+(cAliasSC7)->C7_LOJA)
				
					oSection1:Cell("C7_NUM"):SetValue((cAliasSC7)->C7_NUM)
					oSection1:Cell("C7_FORNECE"):SetValue((cAliasSC7)->C7_FORNECE)
					oSection1:Cell("C7_LOJA"):SetValue((cAliasSC7)->C7_LOJA)
					oSection1:Cell("C7_EMISSAO"):SetValue((cAliasSC7)->C7_EMISSAO)
					
					ImprimeSC(lFirst,0,@oSection1)
					
					If lFirst 
					   lFirst := .F.
					EndIf

					dbSelectArea(cAliasSC7)
					dbSkip()
				EndDo
				dbSelectArea("SC7")
			Else
	    		ImprimeSC(.T.,1,@oSection1)
			EndIf
		Else
			lFirst := .T.
			dbSelectArea("TMP")
			If dbSeek(xFilial('SC7')+SC1->C1_COTACAO+SC1->C1_PRODUTO)
				lCotacao  := .T.
				While !Eof() .And. C7_FILIAL+C7_NUMCOT+C7_PRODUTO  == xFilial('SC7')+SC1->C1_COTACAO+SC1->C1_PRODUTO
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Filtra Tipo de SCs Firmes ou Previstas                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If !MtrAValOP(mv_par07, 'SC7')
						dbSkip()
						Loop
					EndIf

					dbSelectArea("SA2")
					dbSeek(xFilial()+TMP->C7_FORNECE+TMP->C7_LOJA)
					
					oSection1:Cell("C7_NUM"):SetValue(TMP->C7_NUM)
					oSection1:Cell("C7_FORNECE"):SetValue(TMP->C7_FORNECE)
					oSection1:Cell("C7_LOJA"):SetValue(TMP->C7_LOJA)
					oSection1:Cell("C7_EMISSAO"):SetValue(TMP->C7_EMISSAO)
					
					If lFirst 
						ImprimeSC(lFirst,0,@oSection1)
						lFirst := .F.
					Else
						ImprimeSC(lFirst,0,@oSection1)
                    Endif

					dbSelectArea("TMP")
					dbSkip()
				EndDo
			Else
				lCotacao  := .F.
				ImprimeSc(.T.,1,@oSection1)
			EndIf
		EndIf
	Else    
		oSection1:Cell("C7_NUM"):Disable()
		oSection1:Cell("C7_FORNECE"):Disable()
		oSection1:Cell("C7_LOJA"):Disable()
		oSection1:Cell("C7_EMISSAO"):Disable() 
	
	    dbSelectArea("SA2")
	    dbSeek(xFilial()+SC1->C1_FORNECE+SC1->C1_LOJA)
	    dbSelectArea("SC1")
		oSection1:Cell("C1_QUANT"):SetValue(SC1->C1_QUANT)
		oSection1:Cell("nSaldo"):SetValue(SC1->C1_QUANT-SC1->C1_QUJE)
		oSection1:PrintLine()
	EndIf
	cCotacao := IIF(!Empty(SC1->C1_COTACAO) .And. SC1->C1_COTACAO <> "XXXXXX" .And. lCotacao,SC1->C1_COTACAO,"")
	dbSelectArea("SC1")
	dbSkip()
	If SC1->C1_NUM <> cNum .And. !Empty(cCotacao)
		oReport:PrintText(STR0016+cCotacao,,oSection1:Cell('C7_NUM'):ColPos())
	Endif	
EndDo

If MV_PAR03 == 3
	SET DELE ON
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta Arquivo Temporario e Restaura os Indices Nativos.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC7")
RetIndex("SC7")
dbSelectArea("SC1")
Set Filter To
RetIndex("SC1")
dbSetOrder(1)
If ( Select("TMP")<>0 )
	dbSelectArea("TMP")
	dbCloseArea()
	dbSelectArea("SC7")
EndIf
#IFNDEF TOP
	For nI:=1 to Len(aIndex)
		If File(aIndex[nI]+OrdBagExt())
			Ferase(aIndex[nI]+OrdBagExt())
		Endif
	Next
#ENDIF
oSection1:Finish()

Return NIL

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ ImprimeSC³ Autor ³ Julio C.Guerato³ Data ³27/05/2009 |     |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime Dados da SC na versão R4                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±   
±±³Parametros³ lImp:  Parâmetro para indicar como será setada a impressa  ³±±
±±³          ³ nTipo: 0 = Detalhe  / 1 = Totalizacao                      ³±± 
±±³          ³ oSection1: Objeto Impressao                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR100			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function ImprimeSC(lAtiva,nTipo,oSection1)

If lAtiva 
	oSection1:Cell("C1_NUM"):Show()
	oSection1:Cell("C1_ITEM"):Show()
	oSection1:Cell("C1_PRODUTO"):Show()
	oSection1:Cell("C1_DESCRI"):Show()
	oSection1:Cell("B1_TIPO"):Show()
	oSection1:Cell("B1_GRUPO"):Show()
	oSection1:Cell("C1_QUANT"):Show()
	oSection1:Cell("C1_UM"):Show()
	oSection1:Cell("C1_CC"):Show()
	oSection1:Cell("C1_EMISSAO"):Show()
	oSection1:Cell("C1_DATPRF"):Show()
	oSection1:Cell("C1_SOLICIT"):Show()
	oSection1:Cell("dDtPrazo"):Show()
	oSection1:Cell("nSaldo"):Show()
else
	oSection1:Cell("C1_NUM"):Hide()
	oSection1:Cell("C1_ITEM"):Hide()
	oSection1:Cell("C1_PRODUTO"):Hide()
	oSection1:Cell("C1_DESCRI"):Hide()
	oSection1:Cell("B1_TIPO"):Hide()
	oSection1:Cell("B1_GRUPO"):Hide()
	oSection1:Cell("C1_QUANT"):Hide()
	oSection1:Cell("C1_UM"):Hide()
	oSection1:Cell("C1_CC"):Hide()
	oSection1:Cell("C1_EMISSAO"):Hide()
	oSection1:Cell("C1_DATPRF"):Hide()
	oSection1:Cell("C1_SOLICIT"):Hide()
	oSection1:Cell("dDtPrazo"):Hide()
	oSection1:Cell("nSaldo"):Hide()
EndIf


Do Case
    Case nTipo == 0 
		If lAtiva
			oSection1:Cell("C1_QUANT"):SetValue(SC1->C1_QUANT)
			oSection1:Cell("nSaldo"):SetValue(SC1->C1_QUANT-SC1->C1_QUJE)
			oSection1:PrintLine()
		Else	
			oSection1:Cell("C1_QUANT"):SetValue(0)
			oSection1:Cell("nSaldo"):SetValue(0)
			oSection1:PrintLine()
		Endif	
    
    Case nTipo == 1
	    If lAtiva
   			oSection1:Cell("C7_NUM"):Hide()
			oSection1:Cell("C7_FORNECE"):Hide()				
			oSection1:Cell("C7_LOJA"):Hide()
			oSection1:Cell("A2_NOME"):Hide()
			oSection1:Cell("C7_EMISSAO"):Hide()
			
			oSection1:Cell("C1_QUANT"):SetValue(SC1->C1_QUANT)
			oSection1:Cell("nSaldo"):SetValue(SC1->C1_QUANT-SC1->C1_QUJE)

			oSection1:PrintLine()
				
			oSection1:Cell("C7_NUM"):Show()
			oSection1:Cell("C7_FORNECE"):Show()
			oSection1:Cell("C7_LOJA"):Show()
			oSection1:Cell("A2_NOME"):Show()
			oSection1:Cell("C7_EMISSAO"):Show()
		EndIf
EndCase

Return 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³MATR100R3 ³ Autor ³ Claudinei M. Benzi    ³ Data ³ 05.09.92 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Relacao das Solicitacoes de Compras (Antigo)                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Edson Maricate³02/05/00³XXXXXX³Revisao geral no processamento do Rel.  ³±±
±±³Patricia Sal. ³17/07/00³XXXXXX³Deletar arquivo de trabalho ("TMP").    ³±±
±±³Ricardo Berti ³01/12/05³089411³Listava residuos na op.lista "EM ABERTO"³±±
±±³Ricardo Berti ³01/12/05³089411³ + OemToAnsi( ) nas strings de tela.    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MATR100R3()
LOCAL wnrel
LOCAL cDesc1   := OemToAnsi(STR0001)	//"Emite um relacao para controle das solicitacoes cadastradas ,"
LOCAL cDesc2   := OemToAnsi(STR0002)	//"seus respectivos pedidos e prazos de entrega."
LOCAL cDesc3   := ""
LOCAL cString  := "SC1"
LOCAL aOrd      := {OemToAnsi(STR0003),OemToAnsi(STR0004)}		//" Por Solicitacao    "###" Por Produto        "

PRIVATE Tamanho	:= "G"
PRIVATE Titulo	:= OemToAnsi(STR0005)	//"Relacao de Solicitacoes de Compras"
PRIVATE NomeProg:= "MATR100"
PRIVATE aReturn	:= { OemToAnsi(STR0006), 1,OemToAnsi(STR0007), 1, 2, 1, "",1 }		//"Zebrado"###"Administracao"
PRIVATE nLastKey:= 0
PRIVATE cPerg 	:= "MTR100"
PRIVATE aInd	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica as perguntas selecionadas                           ³
//³mv_par01             // a partir do numero                    ³
//³mv_par02             // ate o numero                          ³
//³mv_par03 // Todas/em Aberto/Canceladas/nao entregues/Pendentes³
//³mv_par04             // Data emissao inicial                  ³
//³mv_par05             // Data emissao final                    ³
//³mv_par06             // Mostra Pedido Compra p/ cotacoes      ³
//³mv_par07             // Impr. SC's Firmes, Previstas ou Ambas |
//|mv_par08				// Considera solicitacoes de importacao  |
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
AjustaSX1()
Pergunte(cPerg,.F.)

wnrel:=SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,aOrd,.F.,Tamanho)

If nLastKey == 27
	Set Filter To
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| C100Imp(@lEnd,wnRel,cString)},Titulo)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ C100IMP  ³ Autor ³ Cristina M. Ogura     ³ Data ³ 09.11.95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada do Relatorio                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR100                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function C100Imp(lEnd,WnRel,cString)

LOCAL nCntImpr	:= 0
LOCAL nSldEntre	:= 0
LOCAL nSldProd	:= 0
LOCAL nTotSC	:= 0
Local nIndex	:= 0
LOCAL nOrdem	:= aReturn[8]
LOCAL aSoma		:= {}
Local aIndex	:= {}
LOCAL Cabec1,Cabec2,nX,n
Local lQuery    := .F.
Local cQuery    := ""
Local lPedido   := .F.
Local nOrdSC1   := 1 
Local nRegSC1   := 0
Local nQtdSC1   := 0
Local nQtdSC7   := 0
Local cCotSC1   := ""
Local cProSC1   := ""
Local cItPSC1   := "" 
Local cProduto	:= ""
Local cNumSol   := ""

Local cVarAux2 := SUPERGETMV("ES_SOLSUP",.F.,"000000")
Local cVarAux3 := RetCodUsr()
Local nI        := 0  

li := 80
m_pag := 1
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa os codigos de caracter Comprimido/Normal da impressora ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta os Cabecalhos                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Titulo := STR0009	+Iif(MV_PAR06 == 1, STR0010, " ")		//"RELACAO DE SOLICITACOES DE COMPRAS"###" (Incluindo Pedidos de Compra)"
If MV_PAR06 == 1
   Cabec1 := STR0011	//"NUMERO ITEM PRODUTO         D E S C R I C A O              TP GRUP   QUANTIDADE UM   CENTRO  EMISSAO  ENTREGA SOLICITANTE           DT.LIMITE          SALDO N.PED/ CODIGO LJ RAZAO SOCIAL                          DATA DE "
   Cabec2 := STR0012	//"                                                                     SOLICITADA       CUSTO           DA S.C.                       DE COMPRA        DA S.C. N.COT. FORNEC                                          EMISSAO "
Else
   Cabec1 := STR0017	//"NUMERO ITEM PRODUTO         D E S C R I C A O              TP GRUP   QUANTIDADE UM   CENTRO  EMISSAO  ENTREGA SOLICITANTE           DT.LIMITE          SALDO        CODIGO LJ RAZAO SOCIAL                                  "
   Cabec2 := STR0018	//"                                                                     SOLICITADA       CUSTO           DA S.C.                       DE COMPRA        DA S.C.        FORNEC                                                  "
Endif
*****      123456 12 123456789012345 123456789012345678901234567890 99 9999 999999999.99 99 999999999 99/99/99 99/99/99 XXXXXXXXXX            999999 999999 99 9999999999999999999999999999999999999999 99/99/99 99/99/99 999999999.99
*****      0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19       200       210       220
*****      01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

If MV_PAR06 == 1
	#IFNDEF TOP
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Abre o SC7 em outra area para criar uma nova IndRegua        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SC7")  // ChkFile() precisa da tabela (SC7) criada
	ChkFile('SC7',.F.,'TMP')
	aADD(aIndex,CriaTrab(NIL,.F.))
	IndRegua("TMP",aIndex[Len(aIndex)],"C7_FILIAL+C7_NUMCOT+C7_PRODUTO")
	dbSelectArea("SC7")
	aADD(aIndex,CriaTrab(NIL,.F.))
	IndRegua("SC7",aIndex[Len(aIndex)],"C7_FILIAL+C7_NUMSC+C7_ITEMSC+C7_PRODUTO")
	nIndex := RetIndex("SC7")
	dbSetIndex(aIndex[2]+OrdbagExt())
	dbSetOrder(nIndex+1)
	#ENDIF
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o usuario escolher a opcao que lista as SC's canceladas   ³
//³ pelo sistema ,e' necessario ativar as deletadas.             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If MV_PAR03 == 3
	SET DELE OFF
Endif

dbSelectArea("SC1")
If nOrdem == 1
	dbSetOrder(1)
	dbSeek(xFilial()+MV_PAR01,.T.)
Else
	dbSetOrder(2)
	dbSeek(xFilial())
EndIf
SetRegua(LastRec())

While !Eof() .And. SC1->C1_FILIAL == xFilial() .And.;
	IIf(nOrdem==1,C1_NUM <= MV_PAR02,.T.)
	If nOrdem == 2
		cValAnt		:= xFilial("SC1")+SC1->C1_PRODUTO
		cProduto    := SC1->C1_PRODUTO
		cQuebra		:= 'cValAnt==xFilial("SC1")+SC1->C1_PRODUTO'
	Else
		cValAnt		:= xFilial("SC1")+SC1->C1_NUM
		cNumSol     := SC1->C1_NUM
		cQuebra 	:= 'cValAnt==xFilial("SC1")+SC1->C1_NUM'
	EndIf

	If lEnd
		@PROW()+1,001 PSAY STR0014		//"CANCELADO PELO OPERADOR"
		Exit
	Endif
	
	While !Eof() .And. &(cQuebra)
		If lEnd
			@PROW()+1,001 PSAY STR0014		//"CANCELADO PELO OPERADOR"
			Exit
		Endif
		
		IncRegua()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtra as solicitacoes maior que o numero definido           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If C1_NUM < mv_par01 .Or. C1_NUM > mv_par02
			dbSkip()
			Loop
		Endif
		
		IF ! cVarAux3 $ cVarAux2
			IF C1_USER <> cVarAux3
				dbSkip()
				Loop
			Endif       
		end
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtra as solicitacoes cancelados pelo sistema               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (mv_par03 == 3 .And. !Deleted()) .Or. (mv_par03 == 3 .And. Deleted() .And. !(STR0021$C1_OBS)) //"CANCELADA PELO SISTEMA."
			dbSkip() 
			Loop
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtra as solicitacoes de importacao                         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par08 == 2 .And. ;
				(!Empty(C1_COTACAO) .And. C1_COTACAO == "IMPORT")
			dbSkip()
			Loop
		Endif
					
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtra as solicitacoes em aberto gerada cotacao ou pedido    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par03 == 2 .And. ;
				(C1_QUANT <= C1_QUJE  .Or. (!Empty(C1_COTACAO) .And. (C1_COTACAO <> "IMPORT" .And. C1_COTACAO <> "IMPORX")) .Or. !Empty(C1_RESIDUO))  // BOPS 089411
			dbSkip()
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtra as solicitacoes completamente atendidas               ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par03 == 5 .And. C1_QUANT == C1_QUJE
			dbSkip()
			Loop
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica intervalo de data de emissao                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (C1_EMISSAO < mv_par04 .Or. C1_EMISSAO > mv_par05)
			dbSkip()
			Loop
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtra as solicitacoes nao entregue                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par03 == 4
			If !Empty(C1_COTACAO) .And. C1_COTACAO <> "XXXXXX"
				nRegSC1 := SC1->(RecNo())
				nOrdSC1 := SC1->( IndexOrd()) 
                cCotSC1 := SC1->C1_COTACAO
                cProSC1 := SC1->C1_PRODUTO
                cItPSC1 := SC1->C1_ITEMPED 
				nQtdSC1 := 0
                nQtdSC7 := 0
                lPedido := .F. 
				dbSelectArea("SC7")
				dbSetOrder(2)
				dbSeek(xFilial("SC7")+SC1->C1_PRODUTO)
				While !Eof() .And. xFilial("SC7")+cProSC1 == C7_FILIAL+C7_PRODUTO
					If SC7->C7_NUMCOT == cCotSC1 .And. SC7->C7_ITEM == cItPSC1             
						lPedido := .T.	 
						nQtdSC7 += If(SC7->C7_RESIDUO == "S",SC7->C7_QUANT,SC7->C7_QUJE)

						dbSelectArea("SC8")
						dbSetOrder(3)
						MsSeek(xFilial("SC8")+SC7->C7_NUMCOT+SC7->C7_PRODUTO+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_NUM+SC7->C7_ITEM)
						dbSelectArea("SC1")
						dbSetOrder(5)
						MsSeek(xFilial("SC1")+SC8->C8_NUM+SC8->C8_PRODUTO+SC8->C8_IDENT)						
						While ( !Eof() .And. xFilial("SC1") == SC1->C1_FILIAL .And. SC8->C8_NUM == SC1->C1_COTACAO .And.;
								          SC8->C8_PRODUTO == SC1->C1_PRODUTO .And. SC8->C8_IDENT == SC1->C1_IDENT .And. ;
								          SC8->C8_NUMPED == SC1->C1_PEDIDO .And. SC8->C8_ITEMPED == SC1->C1_ITEMPED )
							nQtdSC1 += SC1->C1_QUANT
							dbSelectArea("SC1")
							dbSkip()
	                    EndDo 
					Endif
					dbSelectArea("SC7")
					dbSkip()
				EndDo

				dbSelectArea("SC1")
				dbSetOrder(nOrdSC1)
				MsGoto(nRegSC1)

                If lPedido	 	
					nSldEntre := nQtdSC1 - nQtdSC7				
                Else 
					nSldEntre := SC1->C1_QUANT				
                EndIf 

			Else
				nSldEntre := SC1->C1_QUANT
				dbSelectArea("SC7")
				dbSetOrder(2)
				dbSeek(xFilial("SC7")+SC1->C1_PRODUTO)
				While !Eof() .And. xFilial( "SC7" ) +SC1->C1_PRODUTO == C7_FILIAL+C7_PRODUTO
					If C7_NUMSC == SC1->C1_NUM .And. C7_ITEMSC == SC1->C1_ITEM
						nSldEntre -= If(SC7->C7_RESIDUO == "S",SC7->C7_QUANT,SC7->C7_QUJE)
					Endif
					dbSelectArea("SC7")
					dbSkip()
				EndDo
			Endif
			
			If nSldEntre <= 0
				dbSelectArea("SC1")
				dbSkip()
				Loop
			Endif

		Endif

		dbSelectArea("SC1")
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Filtra Tipo de SCs Firmes ou Previstas                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !MtrAValOP(mv_par07, 'SC1')
			dbSkip()
			Loop
		EndIf
		
		If li > 55
			Cabec(Titulo,Cabec1,Cabec2,NomeProg,Tamanho,IIF(aReturn[4]==1,15,18))
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Adiciona 1 ao contador de registros impressos         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nCntImpr++
		
		@ li,000 PSAY C1_NUM
		@ li,007 PSAY C1_ITEM
		@ li,012 PSAY C1_PRODUTO
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Imprime descricao completa da SC                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		@ li,028 PSAY SubStr(C1_DESCRI,1,30)
		For nX := 31 To Len(Trim(C1_DESCRI)) Step 30
			li++
			@ li,028 PSAY SubStr(C1_DESCRI,nX,30)
		Next nX		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no arquivo de produtos                             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial()+SC1->C1_PRODUTO)
		
		@ li,059 PSAY B1_TIPO
		@ li,062 PSAY B1_GRUPO
		
		dbSelectArea("SC1")
		@ li,067 PSAY C1_QUANT          Picture PesqPictQt("C1_QUANT",12)
		@ li,080 PSAY C1_UM
		@ li,083 PSAY PadL(Alltrim(C1_CC),20)    Picture "@!"
		@ li,104 PSAY C1_EMISSAO        Picture PesqPict("SC1","C1_EMISSAO")
		@ li,115 PSAY C1_DATPRF         Picture PesqPict("SC1","C1_DATPRF")
		@ li,126 PSAY Substr(C1_SOLICIT,1,12)
		@ li,139 PSAY SomaPrazo(SC1->C1_DATPRF, - CalcPrazo(SC1->C1_PRODUTO,SC1->C1_QUANT))
		@ li,150 PSAY SC1->C1_QUANT-SC1->C1_QUJE  Picture PesqPictQt("C1_QUANT",12)
		
		nSldProd += ( SC1->C1_QUANT - SC1->C1_QUJE )
		nTotSc   += SC1->C1_QUANT
		
		If MV_PAR06 == 1
			If Empty(SC1->C1_COTACAO) .Or. SC1->C1_COTACAO == "XXXXXX"  .Or. SC1->C1_COTACAO == "IMPORX"
				#IFNDEF TOP
					cAliasSC7 := "SC7"
				dbSelectArea("SC7")
				If dbSeek(xFilial()+SC1->C1_NUM+SC1->C1_ITEM+SC1->C1_PRODUTO)
					While !Eof() .and. C7_FILIAL+C7_NUMSC+C7_ITEMSC == xFilial()+SC1->C1_NUM+SC1->C1_ITEM
				#ELSE
					cAliasSC7 := "TMP"
					lQuery := .T.
					cQuery := "SELECT C7_FILIAL,C7_NUM,C7_FORNECE,C7_LOJA,C7_EMISSAO,C7_TPOP,C7_NUMSC,C7_ITEMSC "
					cQuery += "FROM "+RetSqlName("SC7")+" "					
					cQuery += "WHERE "
					cQuery += "C7_FILIAL = '"+xFilial("SC7")+"' AND "
					cQuery += "C7_NUMSC  = '"+SC1->C1_NUM+"' AND "
					cQuery += "C7_ITEMSC = '"+SC1->C1_ITEM+"' AND "
					cQuery += "C7_TIPO   = 1 AND "
					cQuery += "D_E_L_E_T_= ' ' "
					cQuery += "ORDER BY C7_FILIAL,C7_NUMSC,C7_ITEMSC"
					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)
					TcSetField("TMP","C7_EMISSAO","D",8,0)
					If ( Eof() )
						li++
					EndIf
					While !Eof()
				#ENDIF
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Filtra Tipo de SCs Firmes ou Previstas                       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !MtrAValOP(mv_par07, "SC7" )
							dbSkip()
							Loop
						EndIf
						
						@ li,163 PSAY C7_NUM
						@ li,170 PSAY C7_FORNECE
						@ li,177 PSAY C7_LOJA
						dbSelectArea("SA2")
						dbSeek(xFilial()+(cAliasSC7)->C7_FORNECE+(cAliasSC7)->C7_LOJA)
						@ li,180 PSAY SubStr(A2_NOME,1,28)
						@ li,210 PSAY (cAliasSC7)->C7_EMISSAO
						li++
						dbSelectArea(cAliasSC7)
						dbSkip()
					EndDo
					If ( lQuery )
						(cAliasSC7)->(dbCloseArea())
					EndIf
					dbSelectArea("SC7")
					#IFNDEF TOP
				Else
					li++
				EndIf
					#ENDIF
			Else
				#IFNDEF TOP
				dbSelectArea("TMP")
				If dbSeek(xFilial('SC7')+SC1->C1_COTACAO+SC1->C1_PRODUTO)
					@ li,163 PSAY OemToAnsi(STR0016) + SC1->C1_COTACAO // "Pedidos gerados por cotacao - Num. "
					li++
					While !Eof() .And. C7_FILIAL+C7_NUMCOT+C7_PRODUTO  == xFilial('SC7')+SC1->C1_COTACAO+SC1->C1_PRODUTO
				#ELSE
					lQuery := .T.
					cQuery := "SELECT C7_FILIAL,C7_NUM,C7_FORNECE,C7_LOJA,C7_EMISSAO,C7_TPOP,C7_NUMCOT,C7_PRODUTO "
					cQuery += "FROM "+RetSqlName("SC7")+" "
					cQuery += "WHERE "
					cQuery += "C7_FILIAL = '"+xFilial("SC7")+"' AND "
					cQuery += "C7_NUMCOT = '"+SC1->C1_COTACAO+"' AND "
					cQuery += "C7_PRODUTO = '"+SC1->C1_PRODUTO+"' AND "
					cQuery += "D_E_L_E_T_= ' ' "
					cQuery += "ORDER BY C7_FILIAL,C7_NUMCOT,C7_PRODUTO "
					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TMP",.T.,.T.)
					TcSetField("TMP","C7_EMISSAO","D",8,0)
					If ( Eof() )
						li++
					Else
						@ li,163 PSAY OemToAnsi(STR0016) + SC1->C1_COTACAO // "Pedidos gerados por cotacao - Num. "
						li++
					EndIf
					While !Eof()
				#ENDIF
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Filtra Tipo de SCs Firmes ou Previstas                       ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If !MtrAValOP(mv_par07, 'SC7')
							dbSkip()
							Loop
						EndIf
						@ li,163 PSAY C7_NUM
						@ li,170 PSAY C7_FORNECE
						@ li,177 PSAY C7_LOJA
						dbSelectArea("SA2")
						dbSeek(xFilial()+TMP->C7_FORNECE+TMP->C7_LOJA)
						@ li,180 PSAY SubStr(A2_NOME,1,28)
						@ li,210 PSAY TMP->C7_EMISSAO
						li++
						dbSelectArea("TMP")
						dbSkip()
					EndDo
				#IFDEF TOP
					dbSelectArea("TMP")
					dbCloseArea()
					dbSelectArea("SC7")
				#ELSE
				Else
					li++
				EndIf
				#ENDIF
			EndIf
		Else
		    dbSelectArea("SA2")
		    If dbSeek(xFilial()+SC1->C1_FORNECE+SC1->C1_LOJA)
		       dbSelectArea("SC1")
		       @ li,170 PSAY SubStr(SC1->C1_FORNECE,1,6)
		       @ li,177 PSAY SubStr(SC1->C1_LOJA,1,2)
		       @ li,180 PSAY SubStr(SA2->A2_NOME,1,38)
		    Endif   
			li++
		EndIf
		dbSelectArea("SC1")
		dbSkip()
	EndDo
	If lEnd
		Exit
	Endif
	If nOrdem == 2 .And. nTotSC > 0
		li++
		@li, 00 PSay STR0015 + Rtrim(cProduto) + " ----> "      //"Total  -  "
		@li, 67 PSay nTotSC   Picture PesqPictQt("C1_QUANT",16)
		@li,150 PSay nSldProd Picture PesqPictQt("C1_QUANT",16)
		li++
		@li, 00 PSay __PrtThinLine()
		nTotSc   := 0
		nSldProd := 0
		li++
	ElseIf nOrdem == 1 .And. nTotSC > 0
		li++
		@li, 00 PSay STR0015 + Rtrim(cNumSol) + " ----> "      //"Total  -  "
		@li, 67 PSay nTotSC   Picture PesqPictQt("C1_QUANT",16)
		@li,150 PSay nSldProd Picture PesqPictQt("C1_QUANT",16)
		li++
		@li, 00 PSay __PrtThinLine()
		nTotSc   := 0
		nSldProd := 0
		li++
	EndIf
EndDo

If MV_PAR03 == 3
	SET DELE ON
EndIf

If li != 80
	Roda(nCntImpr,STR0008,Tamanho)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Deleta Arquivo Temporario e Restaura os Indices Nativos.     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SC7")
RetIndex("SC7")
dbSelectArea("SC1")
Set Filter To
RetIndex("SC1")
dbSetOrder(1)
If ( Select("TMP")<>0 )
	dbSelectArea("TMP")
	dbCloseArea()
	dbSelectArea("SC7")
EndIf
#IFNDEF TOP
	For nI:=1 to Len(aIndex)
		If File(aIndex[nI]+OrdBagExt())
			Ferase(aIndex[nI]+OrdBagExt())
		Endif
	Next
#ENDIF

Set Device to Screen

If aReturn[5] = 1
	Set Printer To
	dbCommitAll()
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ AjustaSX1³ Autor ³ Alexandre Inacio Lemes³ Data ³26/05/2004³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Altera descricao da pergunta no SX1                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR100			                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function AjustaSX1()

Local aArea := { Alias(), IndexOrd() } , aPerg:={}
Local cPerg := "MTR100"         

Local aHelpPor := {}
Local aHelpEng := {}
Local aHelpSpa := {}
Local nTamSX1  := 10 /*TamSx3("X1_GRUPO")[1]*/ 

Aadd(aPerg,{"Pendentes em PC","Pendiente en PC","Pending in Purc"})

//Denis - Compatibilização Lobo Guara
/*dbSelectArea("SX1")
dbSetOrder(1)
If dbSeek(PADR(cPerg,nTamSX1)+"03")
	RecLock("SX1",.F.)
	Replace X1_DEF05 	with aPerg[1][1]
	Replace X1_DEFSPA5	with aPerg[1][2]
	Replace X1_DEFENG5 	with aPerg[1][3]
	MsUnLock()
EndIf*/

//-------------------------------------------MV_PAR08--------------------------------------------
     
aHelpPor := {"Considera as solicitacoes","de importacao(Sim/Nao)?"}
aHelpEng := {"Consider import","requests (Yes/No)?"}
aHelpSpa := {"Considera las Solicitudes","de Importacion (Si/No)?"}

//PutSX1(cPerg,"08","Considera SCs Import?","Consider import SCs?","Considera las SCs Importacion?","mv_ch8","N",2,0,2,"C","","","","","mv_par08","Sim","Si","Yes","","Nao","No","No","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)

dbSelectArea( aArea[1] )
dbSetOrder( aArea[2] )
Return
    

Return