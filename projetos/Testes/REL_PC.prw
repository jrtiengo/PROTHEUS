#INCLUDE "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"

#DEFINE DMPAPER_A4 9
#DEFINE MAXMENLIN 140                                               // Máximo de caracteres por linha de dados adicionais - Obs
#DEFINE MAXMENLIN1 45                                               // Máximo de caracteres por linha de dados adicionais - Desc
#DEFINE MAXMENLIN2 35                                               // Máximo de caracteres por linha de dados adicionais - Nome Empresa
#DEFINE MAXMENLIN3 15                                               // Máximo de caracteres por linha de dados adicionais - Cod Produto

/***********************************************************************************
|----------------------------------------------------------------------------------|
|* Programa   | FXCOM601                                        Data | 20/12/16 | *|
|----------------------------------------------------------------------------------|   
|* Autor      | 4Fx Soluções em Tecnologia                                        *|
|----------------------------------------------------------------------------------|
|* Utilização | Compras -> Relatórios -> Pedidos - # Pedidos de Compra            *|
|----------------------------------------------------------------------------------|
|* Descricao  | Impressão de Pedidos de Compra                                    *|
|*            |                                                                   *|
|----------------------------------------------------------------------------------|
***********************************************************************************/

User Function FXCOM601()

	Local nPrecUni	:= 0
	Local nPrecTot	:= 0
	Local nTxMoeda	:= 0
	Local nCont		:= 0
	Local nTotFrete	:= 0
	Local nVlrIPI	:= 0
	Local nFlags 	:= 0

	Local cQuery 	:= ""
	Local cQuery2	:= ""
	Local cObs	 	:= ""
	Local cNumAnt	:= ""
	Local cCodPr 	:= ""
	Local cDesc   	:= ""
	Local cEmp	 	:= ""
	Local cTFrete	:= ""
	Local cCRLF	 	:= Chr(13) + Chr(10)
	Local cSession	:= GetPrinterSession()

	Local aAux 		:= {}
	Local aObs		:= {}

	Local cPilha 	:= U_MyPCham()
	Local lPedCom 	:= "MATA121" $ Upper(cPilha)
	
	Local _x		:= 0

	Private nX 		:= 620 	//constante posicionamento horizontal
	Private nY 		:= 840  	//constante posicionamento vertical

	Private nLinha  := 15
	Private nColuna := 30

	Private nCellDiv1 := (nX-nColuna)/3
	Private nCellDiv2 := ((nX-nColuna)/8 )+ 10

	Private nPag := 1

	Private aAux2:= {}

	Private oFonte := nil
	Private oRelat := nil
	Private oSetup := nil

	Private cFornec	:= ""
	Private cNum	:= ""

	Private cPerg:=cPerg:=PADR(("FXCOM601"),LEN(SX1->X1_GRUPO)," ")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³VALIDA PERGUNTAS PARA CONSULTAS                                 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	U_ValidPerg()

	If !lPedCom
		Pergunte(cPerg,.T.)
	Else
		Pergunte(cPerg,.F.)

		MV_PAR01 := SC7->C7_NUM
		MV_PAR02 := SC7->C7_NUM
		MV_PAR03 := CtoD("01/01/2000")
		MV_PAR04 := CtoD("01/01/2050")
		MV_PAR05 := 1
		MV_PAR06 := 1
	Endif

	IF Select("TRB") > 0
		TRB->(DbCloseArea())
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³QUERY DE ORDENS DE COMPRA                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := " SELECT SC7.C7_FILIAL, SC7.C7_NUM, SC7.C7_OBS, SC7.C7_TIPO,			" + cCRLF
	cQuery += "		 SC7.C7_ITEM, SC7.C7_PRODUTO, SC7.C7_DESCRI, SC7.C7_UM,			" + cCRLF
	cQuery += "		 SC7.C7_SEGUM, SC7.C7_QUANT, SC7.C7_QTSEGUM, SC7.C7_PRECO,		" + cCRLF
	cQuery += "		 SC7.C7_TOTAL, SC7.C7_EMISSAO, SC7.C7_MOEDA, SC7.C7_TXMOEDA,	" + cCRLF
	cQuery += "		 SC7.C7_DATPRF, SC7.C7_TPFRETE, SC7.C7_VALFRE, 					" + cCRLF
	cQuery += "		 SC7.C7_DESPESA, SC7.C7_SEGURO, SC7.C7_VALIPI, SC7.C7_FORNECE, SC7.C7_CONTATO, 		" + cCRLF
	cQuery += "		 SE4.E4_CODIGO, SE4.E4_DESCRI, E4_COND, SC7.C7_PICM, SC7.C7_VALICM, C7_USER		" + cCRLF
	//IF SC7->(FieldPos("C7_APEDFOR")) >0
	//	cQuery += ",C7_APEDFOR "
	//endif
	//cQuery += "		 ISNULL(CAST(CAST(SC7.C7_COBS AS VARBINARY (5000)) AS VARCHAR (5000)),'') AS COBS, 	" + cCRLF
	cQuery += "	FROM " + RetSqlName("SC7") + " SC7 " + cCRLF
	cQuery += "	LEFT JOIN " + RetSqlName("SE4") + " SE4 "+ "ON SE4.E4_CODIGO = SC7.C7_COND " + cCRLF
	cQuery += "  WHERE SC7.C7_NUM >= '"+mv_par01+"' AND SC7.C7_NUM <= '"+mv_par02+"' " + cCRLF
	cQuery += "    AND SC7.C7_EMISSAO >= '"+DtoS(mv_par03)+"' AND SC7.C7_EMISSAO <= '"+DtoS(mv_par04)+"' " + cCRLF
	cQuery += "    AND "+ RetSqlCond("SC7")+ " " + cCRLF
	cQuery += "    AND "+ RetSqlCond("SE4")+ " " + cCRLF
	cQuery += "  ORDER BY SC7.C7_FILIAL+SC7.C7_NUM+SC7.C7_ITEM " + cCRLF

	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB", .F., .T.)

	dbSelectArea("TRB")

	ProcRegua(TRB->(RecCount()))

	TRB->(dbGoTop())

	//Instancia os objetos de fonte ates da pintura do relatorio
	oFont06N := TFont():New( "Arial",, 06,,.T.)
	oFont06  := TFont():New( "Arial",, 06,,.F.)
	oFont07N := TFont():New( "Arial",, 07,,.T.)
	oFont07  := TFont():New( "Arial",, 07,,.F.)
	oFont08N := TFont():New( "Arial",, 08,,.T.)
	oFont08  := TFont():New( "Arial",, 08,,.F.)
	oFont11N := TFont():New( "Arial",, 11,,.T.)

	//Validações de setup
	oRelat := FWMSPrinter():New("pedidos_de_compra",,.F.,,.T.)
	oRelat:SetResolution(72)
	oRelat:SetPortrait()
	oRelat:SetPaperSize(DMPAPER_A4)
	oRelat:SetMargin(05,05,05,05)
	oRelat:SetFont(oFont06)
	//oRelat:SetUp()

	nFlags := PD_ISTOTVSPRINTER
	oSetup := FWPrintSetup():New(nFlags, "Pedidos de Compra")

	oSetup:SetPropert(PD_PRINTTYPE   , 2)		//SPOOL
	oSetup:SetPropert(PD_ORIENTATION , 1)		//SETPORTRAIT
	oSetup:SetPropert(PD_DESTINATION , 2)		//LOCAL
	oSetup:SetPropert(PD_MARGIN      , {05,25,05,35})
	oSetup:SetPropert(PD_PAPERSIZE   , 9)

	// ----------------------------------------------
	// Pressionado botão OK na tela de Setup
	// ----------------------------------------------
	If oSetup:Activate() == PD_OK // PD_OK =1

		fwWriteProfString( cSession, "LOCAL"      , If(oSetup:GetProperty(PD_DESTINATION)==1 ,"SERVER"    ,"CLIENT"    ), .T. )
		fwWriteProfString( cSession, "PRINTTYPE"  , If(oSetup:GetProperty(PD_PRINTTYPE)==2   ,"SPOOL"     ,"PDF"       ), .T. )
		fwWriteProfString( cSession, "ORIENTATION", If(oSetup:GetProperty(PD_ORIENTATION)==1 ,"PORTRAIT"  ,"LANDSCAPE" ), .T. )

		If oSetup:GetProperty(PD_PRINTTYPE) == IMP_SPOOL
			oRelat:nDevice := IMP_SPOOL
			fwWriteProfString(GetPrinterSession(),"DEFAULT", oSetup:aOptions[PD_VALUETYPE], .T.)
			oRelat:cPrinter := oSetup:aOptions[PD_VALUETYPE]
		ElseIf oSetup:GetProperty(PD_PRINTTYPE) == IMP_PDF
			oRelat:nDevice := IMP_PDF
			oRelat:cPathPDF := oSetup:aOptions[PD_VALUETYPE]
		EndIf

		While !TRB->(EOF())

			SC7->(DbSetOrder(1))
			SC7->(MsSeek(xFilial("SC7") + TRB->C7_NUM + TRB->C7_ITEM ))

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³IMPRIME NUMEROS DE OC
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cNum := TRB->C7_NUM

			ImpCabec(TRB->C7_FORNECE,cNum)

			//cabeçalho Itens OC
			//horizontais
			oRelat:Line(nLinha*7, nColuna, nLinha*7,(nX - nColuna) - 20)

			//cabeçalho de itens
			oRelat:Say(nLinha*6.75,nColuna   ," Item",oFont06N)
			oRelat:Say(nLinha*6.75,nColuna+20,"Código",oFont06N)
			oRelat:Say(nLinha*6.75,nColuna+80,"Descrição do Material",oFont06N)
			oRelat:Say(nLinha*6.75,nColuna+290,"Ped. Forn.",oFont06N)
			oRelat:Say(nLinha*6.75,nColuna+343,"% IPI",oFont06N)
			oRelat:Say(nLinha*6.75,nColuna+370,"UM ",oFont06N)
			oRelat:Say(nLinha*6.75,nColuna+392,"Quant.",oFont06N)
			oRelat:Say(nLinha*6.75,nColuna+418,"Valor Unit.",oFont06N)
			oRelat:Say(nLinha*6.75,nColuna+458,"Valor Total",oFont06N)
			oRelat:Say(nLinha*6.75,nCellDiv1*3.01-55,"Entrega",oFont06N)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³IMPRIME ITENS DE ORDEM DE COMPRAS                               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCondPag := Alltrim(TRB->E4_DESCRI)//+" "+ TRB->E4_DESCRI

			cEmissao := dtoC(date())
			_nLin	 := nLinha*7.5

			If cNum != cNumAnt
				aObs 	 	:= {}
				nPag 	 	:= 1
				nTotal	 	:= 0
				cTFrete	:= 0
				nTotFrete	:= 0
				nVlrIPI	:= 0
			End

			While (!TRB->(EOF()) .AND. cNum == TRB->C7_NUM)

				If Select("TRD") != 0
					TRD->(dbCloseArea())
				EndIf

				cQuery2 := "SELECT SA5.A5_FORNECE, SA5.A5_PRODUTO "
				cQuery2 += "	FROM " + RetSqlName("SA5") + " SA5 "
				cQuery2 += " WHERE SA5.A5_PRODUTO = '"+TRB->C7_PRODUTO+"'"
				cQuery2 += "   AND "+ RetSqlCond("SA5")+" "

				cQuery2 := ChangeQuery(cQuery2)
				dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery2), "TRD", .F., .T.)

				dbSelectArea("TRD")

				ProcRegua(TRD->(RecCount()))
				TRD->(dbGoTop())

				//IMPRESSAO DOS ITENS		
				oRelat:Say(_nLin,nColuna    , " "+TRB->C7_ITEM,oFont06)

				_nLin4	:= _nLin
				If Len(AllTrim(TRB->C7_PRODUTO)) > 15
					cCodPr := Transform(TRB->C7_PRODUTO,"@R XXXXXXXXXXXXXXX XXXXXXXXXXXXXXX XXXXXXXXXXXXXXX XXXXXXXXXXXXXXX")
					aAux2 	:= _Msg(cCodPr,MAXMENLIN3)

					For _x := 1 to Len(aAux2)				//Quebra Cod Produto
						oRelat:Say(_nLin4,nColuna+20,aAux2[_x],oFont06)
						_nLin4 += 9
					Next
				Else
					oRelat:Say(_nLin,nColuna+25,TRB->C7_PRODUTO,oFont06)
				EndIf

				cDesc  := TRB->C7_DESCRI
				aAux2  := _Msg(cDesc,MAXMENLIN1)
				_nLin3 := _nLin

				For _x := 1 to Len(aAux2)				//Quebra Descricao
					oRelat:Say(_nLin3,nColuna+80,aAux2[_x],oFont06)
					_nLin3 += 9
				Next

				dbSelectArea("SB1")
				dbSetOrder(1)

				If SB1->(MsSeek(xFilial("SB1")+TRB->C7_PRODUTO))
					//NCM
					//ALIQUOTA IPI
					oRelat:SayAlign(_nLin-6,nColuna+258,transform(SB1->B1_IPI,"@E 999,999.00"),oFont06,100, 9,, 1, 0 )
				EndIf
				
				IF SC7->(FieldPos("C7_APEDFOR")) >0
					oRelat:Say(_nLin,nColuna+290,TRB->C7_APEDFOR,oFont06)
				Endif
		

				If mv_par05 == 1
					oRelat:Say(_nLin,nColuna+370,TRB->C7_UM,oFont06)
					oRelat:SayAlign(_nLin-6,nColuna+310,transform(round(TRB->C7_QUANT,2), "@E 9,999,999,999.99"  ),oFont06,100, 9,, 1, 0 )
				Else
					oRelat:Say(_nLin,nColuna+370,TRB->C7_SEGUM,oFont06)
					oRelat:SayAlign(_nLin-6,nColuna+310,transform(round(TRB->C7_QTSEGUM,2), "@E 9,999,999,999.99"),oFont06,100, 9,, 1, 0 )
				End

				If TRB->C7_MOEDA != 0
					nTxMoeda := IIF(TRB->C7_TXMOEDA > 0,TRB->C7_TXMOEDA,0)
					nPrecUni := xMoeda(TRB->C7_PRECO,TRB->C7_MOEDA,mv_par06,TRB->C7_DATPRF,nTxMoeda)
					oRelat:SayAlign(_nLin-6,nColuna+350,transform(nPrecUni, X3Picture("C7_PRECO")),oFont06,100, 9,, 1, 0 )

					nPrecTot := xMoeda(TRB->C7_TOTAL,TRB->C7_MOEDA,mv_par06,TRB->C7_DATPRF,nTxMoeda)
					oRelat:SayAlign(_nLin-6,nColuna+390,transform(nPrecTot, X3Picture("C7_TOTAL")),oFont06,100, 9,, 1, 0 )
				Else
					oRelat:SayAlign(_nLin-6,nColuna+350,transform(TRB->C7_PRECO, X3Picture("C7_PRECO")),oFont06,100, 9,, 1, 0 )
					oRelat:SayAlign(_nLin-6,nColuna+390,transform(TRB->C7_TOTAL, X3Picture("C7_TOTAL")),oFont06,100, 9,, 1, 0 )
				EndIf

				oRelat:Say(_nLin,nCellDiv1*3.01-55,DtoC(StoD(TRB->C7_DATPRF)) ,oFont06)

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³SOMA VALORES TOTAIS PARA TOTALIZAR ORDEM DE COMPRA              ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ			

				//QUEBRA DE LINHA
				Do Case
					Case _nLin3 > _nLin .And. _nLin3 > _nLin4  //Controla a posição da linha na impressao dos itens
					_nLin := _nLin3
					Case _nLin4 > _nLin3
					_nLin := _nLin4
					Otherwise
					_nLin += 9
				EndCase

				cTFrete		:= TRB->C7_TPFRETE
				nTotFrete 	+= TRB->C7_VALFRE+TRB->C7_DESPESA+TRB->C7_SEGURO
				nVlrIPI		+= TRB->C7_VALIPI
				nTotal		+= TRB->C7_TOTAL // + nTotFrete

				//IF !Empty(SB1->B1_AREFER) .or. !Empty(TRB->C7_OBS) 
            IF !Empty(TRB->C7_OBS) 
					//oRelat:Say(_nLin,nColuna+15,"Ref.: " + SB1->B1_AREFER,oFont06)
					oRelat:Say(_nLin,nColuna+80,"Obs.: " + Alltrim(TRB->C7_OBS),oFont06)
					_nLin += 9
				Endif


				If _nLin >= nLinha*46 //QUEBRA DE PAGINA
					cNumAnt := cNum	//Armazena numero do pedido para guardar obs
					nPag	 += 1

					TRB->(dbSkip())
					exit
				EndIf

				//Armazena observaçoes                         
				//If !Empty(TRB->COBS) .And. Len(aObs) < 1
				//	AADD(aObs,{TRB->C7_NUM,TRB->C7_FORNECE, AllTrim(TRB->C7_ITEM), TRB->COBS})
				//EndIf

				TRB->(dbSkip())
			EndDo

			nTotal += nTotFrete + nVlrIPI

			//Observações
			oRelat:Line(_nLin-7, nColuna,_nLin-7,(nX - nColuna) - 20)
			//oRelat:Say(_nLin,nColuna,' OBSERVAÇÕES: ',oFont06N)

			_nLin2	:= _nLin+9

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³IMPRIME OBSERVAÇÕES DOS ITENS DA ORDEM DE COMPRAS               ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ		
			For nCont = 1 to Len(aObs)
				If _nLin2 >= nLinha*46
					_nLin2  := nLinha*6.75
					cNum	:= aObs[nCont,1]
					cFornec := aObs[nCont,2]
					nPag += 1

					ImpCabec(cFornec,cNum)
				EndIf

				If aObs[nCont,3] != ""
					//oRelat:Say(_nLin2,nColuna," Item "+aObs[nCont,3]+": ",oFont06N)

					cObs  := " "+aObs[nCont,4]
					aAux2 := _Msg(cObs,MAXMENLIN)
					For _x := 1 to Len(aAux2)		 //Quebra Obs
						oRelat:Say(_nLin2,nColuna,aAux2[_x],oFont06)
						_nLin2 += 9
					Next
				EndIf
			Next

			//Linhas rodape1
			//horizontais
			//oRelat:Line(nLinha*46.7, nColuna,nLinha*46.7,nX - nColuna) 
			oRelat:Line(nLinha*46.5, nColuna,nLinha*46.5,(nX - nColuna) - 20)

			//verticais
			oRelat:Line(nLinha*46.5,nCellDiv2*2,nLinha*48,nCellDiv2*2)
			oRelat:Line(nLinha*46.5,nCellDiv2*3,nLinha*48,nCellDiv2*3)
			oRelat:Line(nLinha*46.5,nCellDiv2*4,nLinha*48,nCellDiv2*4)
			oRelat:Line(nLinha*46.5,nCellDiv2*5,nLinha*48,nCellDiv2*5)
			oRelat:Line(nLinha*46.5,nCellDiv2*6,nLinha*48,nCellDiv2*6)

			//rodape1
			oRelat:Say(nLinha*47,nColuna    ," Condicao de Pagto: ",oFont06N)
			oRelat:Say(nLinha*47,nCellDiv2*2," Data de Emissão: ",oFont06N)
			oRelat:Say(nLinha*47,nCellDiv2*3," Tipo Frete: ",oFont06N)
			oRelat:Say(nLinha*47,nCellDiv2*4," Total Frete: ",oFont06N)
			oRelat:Say(nLinha*47,nCellDiv2*5," Valor IPI: ",oFont06N)
			oRelat:Say(nLinha*47,nCellDiv2*6," Total Geral: ",oFont06N)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³IMPRIME ITENS DE RODAPE                                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
			oRelat:Say(nLinha*47.5,nColuna    ," "+cCondPag,oFont06)
			oRelat:Say(nLinha*47.5,nCellDiv2*2," "+cEmissao,oFont06)

			Do Case
				Case cTFrete == "C"
				oRelat:Say(nLinha*47.5,nCellDiv2*3," C - CIF  ",oFont06)
				Case cTFrete == "F"
				oRelat:Say(nLinha*47.5,nCellDiv2*3," F - FOB  ",oFont06)
				Case cTFrete == "T"
				oRelat:Say(nLinha*47.5,nCellDiv2*3," T - Por conta de Terceiros  ",oFont06)
				Otherwise
				oRelat:Say(nLinha*47.5,nCellDiv2*3," S - Sem Frete  ",oFont06)
			EndCase

			oRelat:SayAlign(nLinha*47.5-6,nCellDiv2*4-60,transform(nTotFrete, X3Picture("C7_DESPESA")),oFont06,100, 9,, 1, 0 )
			oRelat:SayAlign(nLinha*47.5-6,nCellDiv2*5-60,transform(nVlrIPI, X3Picture("C7_VALIPI")),oFont06,100, 9,, 1, 0 )
			oRelat:SayAlign(nLinha*47.5-6,nCellDiv2*6-60,transform(nTotal, X3Picture("C7_TOTAL")),oFont06,100, 9,, 1, 0 )	
		EndDo

		oRelat:EndPage()
		oRelat:Preview()
	Else
		MsgInfo("Relatório cancelado pelo usuário.","Atenção")
		//FClose( oRelat:nHandle )
	EndIf		

	TRB->(dbCloseArea())
Return

/***********************************************************************************
|----------------------------------------------------------------------------------|
|* Função     | ImpCabec                                        Data | 20/12/16 | *|
|----------------------------------------------------------------------------------|   
|* Autor      | 4Fx Soluções em Tecnologia                                        *|
|----------------------------------------------------------------------------------|
|* Descricao  | Impressão do Cabeçalho do Relatório                               *|
|*            |                                                                   *|
|----------------------------------------------------------------------------------|
***********************************************************************************/

Static Function ImpCabec(cFornec,cNum)

	Local cLogo := FisxLogo("1") //Logo
	Local _cTransp  := ""
	Local _cFonTrans:= ""
	
	Local _x		:= 0

	Local cMailUsr := Alltrim(UsrRetMail(TRB->C7_USER))

	oRelat:Startpage()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Imprime LAYOUT de Ordem de Compras                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oRelat:Line(nLinha, nColuna, nLinha*50,nColuna)//fecha linha coluna esquerda documento

	//Cabeçalho1
	//horizontais
	oRelat:Line(nLinha     ,nColuna      , nLinha     ,(nX - nColuna) - 20)
	oRelat:Line(nLinha*2   ,nCellDiv1*1.5, nLinha*2   ,(nX - nColuna) - 20)
	oRelat:Line(nLinha*6.15,nColuna      , nLinha*6.15,(nX - nColuna) - 20)

	//verticais
	oRelat:Line(nLinha, nCellDiv1*1.5,nLinha*6.15,nCellDiv1*1.5)
	oRelat:Line(nLinha, nCellDiv1*2.45,nLinha*2,nCellDiv1*2.45)
	//oRelat:Line(nLinha, nCellDiv1*2.8,nLinha*2,nCellDiv1*2.8)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³IMPRESSAO DE CABEÇALHO                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oRelat:SayBitmap(nLinha*1.3,nColuna+5,cLogo  ,90,nLinha*2.5)//LOGO

	//Fecha coluna direita documento
	oRelat:Line(nLinha, (nX - nColuna) - 20, nLinha*50,(nX - nColuna) - 20)

	//Linha final do documento
	oRelat:Line(nLinha*49, nColuna, nLinha*49,(nX - nColuna) - 20)

	//Cabeçalho1	
	//Empresa	
	cEmp  := SM0->M0_NOMECOM
	aAux2 := _Msg(cEmp,MAXMENLIN2)

	_nLin3 := 	nLinha*2.5
	For _x := 1 to Len(aAux2)				//Quebra Nome Empresa
		oRelat:Say(_nLin3,nColuna+105,aAux2[_x],oFont07N)
		_nLin3 += 9
	Next

	oRelat:Say(nLinha*4.5 ,nColuna," "+AllTrim(SM0->M0_ENDCOB)+", "+AllTrim(SM0->M0_CIDCOB) +"/"+ AllTrim(SM0->M0_ESTCOB),oFont06)
	oRelat:Say(nLinha*5.25,nColuna," CEP: ",oFont06N)
	oRelat:Say(nLinha*5.25,nColuna+20," "+ Transform(SM0->M0_CEPCOB, "@R 99999-999") ,oFont06)

	If !Empty(SM0->M0_TEL)
		oRelat:Say(nLinha*5.25,nColuna+70," FONE: ",oFont06N)
		oRelat:Say(nLinha*5.25,nColuna+95,Transform(SM0->M0_TEL, "@R (99) 9999-9999" ),oFont06)
	EndIf

	oRelat:Say(nLinha*5.25,nColuna+150," E-MAIL: ",oFont06N)
	oRelat:Say(nLinha*5.25,nColuna+175," " + cMailUsr,oFont06)

	/*If !Empty(SM0->M0_FAX)
	oRelat:Say(nLinha*5.25,nColuna+170," FAX: ",oFont06N)
	oRelat:Say(nLinha*5.25,nColuna+190,SM0->M0_FAX,oFont06)
	EndIf*/

	oRelat:Say(nLinha*6,nColuna," CNPJ: ",oFont06N)
	oRelat:Say(nLinha*6,nColuna+20," "+Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),oFont06)
	oRelat:Say(nLinha*6,nColuna+90," I.E.: ",oFont06N)
	oRelat:Say(nLinha*6,nColuna+110,Transform(AllTrim(SM0->M0_INSC),"@R 999.999.999.999"),oFont06)

	oRelat:Say(nLinha*1.75,nCellDiv1*1.75,"PEDIDO DE COMPRA",oFont11N)
	oRelat:Say(nLinha*1.75,nCellDiv1*2.45," Nro: ",oFont07N)
	oRelat:Say(nLinha*1.75,nCellDiv1*2.55,cNum,oFont11N)

	//oRelat:Say(nLinha*1.75,nCellDiv1*3.01-35,' Pág: ',oFont06N)
	//oRelat:Say(nLinha*1.75,nCellDiv1*3.01-10,cValToChar(nPag),oFont06)

	//Fornecedores
	dbSelectArea("SA2")
	dbSetOrder(1)

	If SA2->(MsSeek(xFilial("SA2")+cFornec))
		oRelat:Say(nLinha*2.75,nColuna+265," Fornecedor: ",oFont06N)
		oRelat:Say(nLinha*2.75,nColuna+310,AllTrim(SA2->A2_NOME),oFont06)
		oRelat:Say(nLinha*3.75,nColuna+460," I.E.: ",oFont06N)
		oRelat:Say(nLinha*3.75,nColuna+480,Transform(AllTrim(SA2->A2_INSCR),"@R 999.999.999.999"),oFont06)
		oRelat:Say(nLinha*3.75,nColuna+265," Endereço: ",oFont06N)
		oRelat:Say(nLinha*3.75,nColuna+300,AllTrim(SA2->A2_END)+" - "+AllTrim(SA2->A2_BAIRRO),oFont06)
		oRelat:Say(nLinha*4.75,nColuna+265," Cidade/UF:",oFont06N)
		oRelat:Say(nLinha*4.75,nColuna+305,AllTrim(SA2->A2_MUN)+"/"+AllTrim(SA2->A2_EST),oFont06)
		oRelat:Say(nLinha*4.75,nColuna+380," CEP: ",oFont06N)
		oRelat:Say(nLinha*4.75,nColuna+400," "+ Transform(SA2->A2_CEP,"@R 99999-999"),oFont06)

		oRelat:Say(nLinha*4.75,nColuna+460," CGC: ",oFont06N)
		If SA2->A2_TIPO == "J" //CNPJ ou CPF
			oRelat:Say(nLinha*4.75,nColuna+480," "+ Transform(SA2->A2_CGC,"@R 99.999.999/9999-99"),oFont06)
		Else
			oRelat:Say(nLinha*4.75,nColuna+480," "+ Transform(SA2->A2_CGC,"@R 999.999.999-99"),oFont06)
		EndIf

		oRelat:Say(nLinha*5.75,nColuna+265," Contato: ",oFont06N)
		oRelat:Say(nLinha*5.75,nColuna+305,AllTrim(TRB->C7_CONTATO),oFont06)

		If !Empty(SA2->A2_TEL)
			oRelat:Say(nLinha*5.75,nColuna+380," FONE: ",oFont06N)
			oRelat:Say(nLinha*5.75,nColuna+405,"("+SA2->A2_DDD + ")" + SA2->A2_TEL,oFont06)
		EndIf

		/*If !Empty(SA2->A2_FAX)
		oRelat:Say(nLinha*5.75,nColuna+480," FAX: ",oFont06N)
		oRelat:Say(nLinha*5.75,nColuna+500,SA2->A2_DDD + SA2->A2_FAX,oFont06)
		EndIf*/
	EndIf

	//IMPRESSAO RODAPE2
	//Linha rodape2
	//IMPRESSAO RODAPE2
	//Linha rodape2
	oRelat:Line(nLinha*48, nColuna, nLinha*48,(nX - nColuna) - 20)
	oRelat:Line(nLinha*50, nColuna, nLinha*50,(nX - nColuna) - 20)

	_cTransp := ""//IIF(!Empty(TRB->C7_CTRANSP), fBuscaCPO("SA4",1, xFilial("SA4") + TRB->C7_CTRANSP, "A4_NOME" ) ,"")
	_cFonTrans := ""//IIF(!Empty(TRB->C7_CTRANSP), fBuscaCPO("SA4",1, xFilial("SA4") + TRB->C7_CTRANSP, "A4_DDD" ) ,"") + " " + IIF(!Empty(TRB->C7_CTRANSP), fBuscaCPO("SA4",1, xFilial("SA4") + TRB->C7_CTRANSP, "A4_TEL" ) ,"")

	//rodape2 - padrão do documento
	//oRelat:Say(nLinha*48.5,nColuna," Transportadora: ",oFont06N)
	//oRelat:Say(nLinha*48.5,nColuna+50, IIF(!Empty(_cTransp),_cTransp + "      FONE: " + Transform(_cFonTrans, "@R (99) 9999-9999" ),"") ,oFont06)
	oRelat:Say(nLinha*49.5,nColuna," NOTA: ",oFont06N)
	oRelat:Say(nLinha*49.5,nColuna+25,"Favor mencionar o número deste pedido na Nota Fiscal.",oFont06)

	oRelat:Line(nLinha*51, nColuna+10, nLinha*51,nColuna+110)
	oRelat:Line(nLinha*51, nColuna+430, nLinha*51,nColuna+530)

	oRelat:Say(nLinha*51.5, nColuna+40," Comprador ",oFont07N)
	oRelat:Say(nLinha*52, nColuna+9,PADC(Alltrim(UsrFullName(TRB->C7_USER)),48),oFont07N)
	//oRelat:Say(nLinha*52, nColuna+9,PADC(Replicate("-",50),50),oFont07N)
	oRelat:Say(nLinha*51.5, nColuna+470," Diretor ",oFont07N)

Return

/***********************************************************************************
|----------------------------------------------------------------------------------|
|* Função     | ValidPerg                                       Data | 20/12/16 | *|
|----------------------------------------------------------------------------------|   
|* Autor      | 4Fx Soluções em Tecnologia                                        *|
|----------------------------------------------------------------------------------|
|* Descricao  | Função auxiliar para criação das perguntas                        *|
|*            |                                                                   *|
|----------------------------------------------------------------------------------|
***********************************************************************************/

User Function ValidPerg()

	Local _aArea  := GetArea()
	Local _aRegs  := {}
	Local _aHelps := {}
	Local _i      := 0
	Local _j      := 0

	_aRegs := {}

	//             GRUPO  ORDEM PERGUNT           	PERSPA 				PERENG 				VARIAVL  TIPO 	TAM 				  DEC PRESEL 	GSC  VALID           VAR01       DEF01        DEFSPA1 DEFENG1 CNT01 VAR02 DEF02        DEFSPA2 DEFENG2 CNT02 VAR03 DEF03    DEFSPA3 DEFENG3 CNT03 VAR04 DEF04 DEFSPA4 DEFENG4 CNT04 VAR05 DEF05 DEFSPA5 DEFENG5 CNT05 F3     GRPSXG
	AADD (_aRegs, {cPerg, "01", "Pedido de	        ", "Pedido de		", "Request			",  "mv_ch1", "C", len(CriaVar("C7_NUM")),  0,  0,	"G", "", 			"mv_par01", "",			"",     		"",		"",		"",				"",				"",     		"",	     "",	"",   			"",      		"",     		"", 	"",		"",   		"",				"",				"",		"",		"",			"",   		"",     		 "",	"", "SC7", ""})
	AADD (_aRegs, {cPerg, "02", "Pedido até         ", "Pedido a		", "Request to		",  "mv_ch2", "C", len(CriaVar("C7_NUM")),  0,  0, 	"G", "", 			"mv_par02", "",			"",     		"",		"",		"",				"",				"",     		"",	     "",	"",   			"",      		"",     		"", 	"",		"",   		"",				"",				"",		"",		"",			"",  		"",    			 "",	"", "SC7", ""})
	AADD (_aRegs, {cPerg, "03", "Data de            ", "Data		    ", "Date			",  "mv_ch3", "D", 06,						0,  0,	"G", "", 			"mv_par03", "",			"",     		"",		"",		"",				"",				"",     		"",	     "",	"",   			"",      		"",     		"",		"",		"",   		"",				"",				"",		"",		"",			"",  		"",     		 "",	"", "", ""})
	AADD (_aRegs, {cPerg, "04", "Data até           ", "Data		    ", "Date to			",  "mv_ch4", "D", 06, 						0,  0,	"G", "", 			"mv_par04",	"",			"",     		"",		"",		"",				"",				"",     		"",	     "",	"",   			"",     		"",     		"", 	"",		"",   		"",				"",				"",		"",		"",			"",  		"",    			 "",	"", "", ""})
	AADD (_aRegs, {cPerg, "05", "Qual Unid. de Med.?", "			    ", "				",  "mv_ch5", "C", 01, 						0,  0,	"C", "", 			"mv_par05", "Primária",	"",          	"",		"",		"",   "Secundária",				"",     		"",	     "",	"",   			"",             "",				"",		"",		"",   		"",				"",             "",		"",		"",			"",			"",              "",	"", "", ""})
	AADD (_aRegs, {cPerg, "06", "Qual Moeda        ?", "¿Que Moneda    ?", "Currency        ?",	"mv_ch6", "N", 01, 						0,  1,	"C", "", 			"mv_par06", "Moeda 1" , "",				"" , 	"",		"",      "Moeda 2",	            "",             "",		 "",	"",      "Moeda 3",             "",             "",		"",		"",  "Moeda 4",             "",             "", 	"", 	"",  "Moeda 5",         "",              "",	"", "", "S" , "" , "" , "" })

	// Definicao de textos de help (versao 7.10 em diante): uma array para cada linha.
	_aHelps = {}

	DbSelectArea ("SX1")
	DbSetOrder (1)
	For _i := 1 to Len (_aRegs)
		If ! DbSeek (cPerg + _aRegs [_i, 2])
			RecLock("SX1", .T.)
		Else
			RecLock("SX1", .F.)
		Endif
		For _j := 1 to FCount ()
			// Campos CNT nao sao gravados para preservar conteudo anterior.
			If _j <= Len (_aRegs [_i]) .and. left (fieldname (_j), 6) != "X1_CNT" .and. fieldname (_j) != "X1_PRESEL"
				FieldPut(_j, _aRegs [_i, _j])
			Endif
		Next
		MsUnlock()
	Next
Return

/***********************************************************************************
|----------------------------------------------------------------------------------|
|* Função     | _MSG                                            Data | 20/12/16 | *|
|----------------------------------------------------------------------------------|   
|* Autor      | 4Fx Soluções em Tecnologia                                        *|
|----------------------------------------------------------------------------------|
|* Descricao  | Função auxiliar para tratamento de quebra dos dados adicionais p/ *|
|*            | não ultrapassar o limite definido no layout.                      *|
|----------------------------------------------------------------------------------|
***********************************************************************************/

Static Function _MSG(_cObs,_nTam)

	Local _aMsg := {}
	Local _i    := 0

	_cObs := StrTran(_cObs, " ", ";")
	Do While At(";;", _cObs) != 0
		_cObs := StrTran(_cObs, ";;", ";")
	EndDo

	_aObs := {}
	Do While Len(_cObs) > 0
		If At(";", _cObs) != 0
			AADD(_aObs, SubStr(_cObs, 1, At(";", _cObs) -1))
			_cObs := Stuff(_cObs, 1, At(";", _cObs), "")
		Else
			AADD(_aObs, AllTrim(_cObs))
			_cObs := ""
		EndIf
	EndDo

	_cObs := ""
	For _i := 1 To Len(_aObs)
		If Len(_cObs + cValToChar(_aObs[_i])) > _nTam
			AADD(_aMsg, Padr(_cObs,_nTam))
			_cObs := _aObs[_i] + " "
		Else
			_cObs := _cObs + _aObs[_i] + " "
		EndIf
	Next _i

	If AllTrim(_cObs) != ""
		AADD(_aMsg, Padr(_cObs,_nTam))
	EndIf

Return _aMsg

#Include 'Protheus.ch'

// Programa...: MyPCham
// Descricao..: Retorna pilha de chamadas de funcoes (formato string)

User Function MyPCham()
	
	local _i      := 0
	local _sPilha := ""
	do while procname (_i) != ""
		_sPilha += chr (13) + chr (10) + procname (_i)
		_i++
	enddo
	
return UPPER(_sPilha)
