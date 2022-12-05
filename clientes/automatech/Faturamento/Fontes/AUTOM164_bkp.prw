#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM164.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 02/04/2013                                                          *
// Objetivo..: Programa que abre janela de consulta de variáveis do cálculo de mar-*
//             gem dos produtos do pedido de venda.                                *
//**********************************************************************************

User Function AUTOM164()

   Local lChumba := .F.

   Local nPpis 	:= GetMv("MV_TXPIS")  			// Percentual de PIS
   Local nPcof 	:= GetMv("MV_TXCOF")			// Percentual de COFINS
   Local nPAdm 	:= GetMv("MV_CUSTADM")			// Percentual de Custo Administrativo
   Local nPFre 	:= GetMv("MV_CUSTFRE")			// Percentual de Frete

   Local cPedido     := Space(06)         
   Local cProduto    := Space(20)
   Local cDescricao  := Space(40)
   Local cQuantidade := 0
   Local cComissao   := 0
   Local cFrete      := 0
   Local cCustoAdm   := 0
   Local cCondicao   := Space(25)
   Local cNomeCond   := Space(25)
   Local cMedio      := 0
   Local cPrcVenda   := 0
   Local cIcms	     := 0
   Local cIcmsSt	 := 0
   Local nValPIS	 := 0
   Local nValCOF	 := 0
   Local nJuros      := 0
   Local cMargem     := 0

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local cMemo3	 := ""

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5
   Local oGet6
   Local oGet7
   Local oGet8
   Local oGet9
   Local oGet10
   Local oGet11
   Local oGet12
   Local oGet13
   Local oGet14
   Local oGet15
   Local oGet18
   Local oGet19
   
   Local oMemo1
   Local oMemo2
   Local oMemo3

   Local cSql := ""

   Private _QnAliqIcm  := 0
   Private _QnValIcm   := 0
   Private _QnBaseIcm  := 0
   Private _QnValIpi   := 0
   Private _QnBaseIpi  := 0
   Private _QnValMerc  := 0
   Private _QnValSol   := 0
   Private _QnValDesc  := 0
   Private _QnPrVen    := 0

   Private oDlg

   // Carrega as variáveis para display
   cPedido     := SC6->C6_NUM
   cProduto    := SC6->C6_PRODUTO
   cDescricao  := SC6->C6_DESCRI
   cQuantidade := SC6->C6_QTDVEN

   // Pesquisa a Condição de Pagamento
   If Select("T_PEDIDO") > 0
      T_PEDIDO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC5.C5_EMISSAO,"
   cSql += "       SC5.C5_CONDPAG,"
   cSql += "       SC5.C5_TPFRETE,"
   cSql += "       SE4.E4_DESCRI  "
   cSql += "  FROM " + RetSqlName("SC5") + " SC5, "
   cSql += "       " + RetSqlName("SE4") + " SE4  "
   cSql += " WHERE SC5.C5_FILIAL  = '" + Alltrim(SC6->C6_FILIAL) + "'"
   cSql += "   AND SC5.C5_NUM     = '" + Alltrim(SC6->C6_NUM)    + "'"
   cSql += "   AND SC5.C5_CONDPAG = SE4.E4_CODIGO"
   cSql += "   AND SC5.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )

   If T_PEDIDO->( EOF() )
      cCondicao := ""
      cNomeCond := ""
   Else
      cCondicao := T_PEDIDO->C5_CONDPAG
      cNomeCond := T_PEDIDO->E4_DESCRI
   Endif

   cMargem   := 0
  
   cComissao := (SC6->C6_PRCVEN * (SC6->C6_COMIS1 + SC6->C6_COMIS2 + SC6->C6_COMIS3 + SC6->C6_COMIS4 + SC6->C6_COMIS5)) / 100
   cPrcVenda := SC6->C6_PRCVEN
   cMedio    := Posicione("SB2",1,xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL,"B2_CM1")
   cCustoAdm := cMedio * ( nPAdm / 100 )

   nCustFrt  := cPrcVenda * ( nPFre / 100 )
   cFrete    := Iif( T_PEDIDO->C5_TPFRETE == "C", nCustFrt, 0 )
   
   // Calculo os impostos
   _xCalcImp()

   cIcms := _QnValIcm / SC6->C6_QTDVEN

   // Calcula o ICMS ST
   cIcmsSt := U_CalcST( SC6->C6_PRODUTO, SC6->C6_CLI, SC6->C6_LOJA, SC6->C6_PRCVEN, SC6->C6_TES )

   // Calcula o valor do PIS
   nValPIS := SC6->C6_PRCVEN * ( nPpis / 100 )

   // Calcula o valor do COFINS
   nValCOF := SC6->C6_PRCVEN * ( nPcof / 100 )

   // Calcula o valor do Juro
   _TpCond := Posicione( "SE4", 1, xFilial("SE4") + T_PEDIDO->C5_CONDPAG, "E4_TIPO" ) //Verifico o tipo da condicao de pagamento

   If _TpCond != "9" // Se for tipo 9 não tenho como calcular

 	  _nValjur := 0
	  _aParc := Condicao( SC6->C6_PRCVEN, T_PEDIDO->C5_CONDPAG, , STOD(T_PEDIDO->C5_EMISSAO) )

	  For _nX := 1 To Len( _aParc )
			
	 	  _dVenc  := _aParc[ _nX, 1 ]
		  _nValor := _aParc[ _nX, 2 ]
		  _nDias  := DateDiffDay( STOD(T_PEDIDO->C5_EMISSAO), _dVenc )
			
		  _nValjur += _nValor / ( ( 1 + ( Getmv("MV_JUROS") / 100 ) ) ** ( _nDias / 30 ) )
			
	  Next

	  _nPorJur := 1 - ( _nValJur / SC6->C6_PRCVEN )
	  nJuros   := _nPorJur * SC6->C6_PRCVEN

   EndIf

   _nSumCust   := cIcms  + cComissao + cFrete - cIcmsSt + nValPIS + nValCOF + nJuros   
   nCustTotFin := cMedio + cCustoAdm
   
   _nMargem := ( ( SC6->C6_PRCVEN - _nSumCust ) - nCustTotFin )// Subtraio do preco de venda, todo o custo referente o mesmo 
   cMargem  := ( _nMargem / SC6->C6_PRCVEN ) * 100 // % da Margem

   DEFINE MSDIALOG oDlg TITLE "Parâmetros Calculo Margem" FROM C(178),C(181) TO C(446),C(733) PIXEL

   @ C(005),C(005) Say "Nº PV"                 Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(045) Say "Produto"               Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(097) Say "Descrição do Produto"  Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(243) Say "Qtd Vda"               Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(005) Say "Condição de Pagamento" Size C(063),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(182) Say "Magem do Item"         Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(046),C(110) Say "Variáveis de Cálculo"  Size C(049),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(057),C(005) Say "Comissão"              Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(057),C(095) Say "Custo Médio"           Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(057),C(191) Say "ICMS"                  Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(070),C(005) Say "Frete"                 Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(070),C(095) Say "Valor Venda"           Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(070),C(191) Say "ICMS ST"               Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(083),C(005) Say "Custo Adm"             Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(083),C(191) Say "PIS"                   Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(096),C(191) Say "COFINS"                Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(083),C(095) Say "Juros"                 Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(050),C(005) GET oMemo1 Var cMemo1 MEMO Size C(103),C(001) PIXEL OF oDlg
   @ C(050),C(162) GET oMemo2 Var cMemo2 MEMO Size C(105),C(001) PIXEL OF oDlg
   @ C(110),C(005) GET oMemo3 Var cMemo3 MEMO Size C(262),C(001) PIXEL OF oDlg

   @ C(013),C(005) MsGet oGet1  Var cPedido     When lChumba Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(013),C(045) MsGet oGet2  Var cProduto    When lChumba Size C(046),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(013),C(097) MsGet oGet3  Var cDescricao  When lChumba Size C(139),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(013),C(243) MsGet oGet4  Var cQuantidade When lChumba Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(035),C(005) MsGet oGet8  Var cCondicao   When lChumba Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(035),C(032) MsGet oGet9  Var cNomeCond   When lChumba Size C(142),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(035),C(222) MsGet oGet18 Var cMargem     When lChumba Size C(045),C(009) COLOR CLR_BLACK Picture("@E 9,999,999.99") PIXEL OF oDlg
   @ C(055),C(222) MsGet oGet12 Var cIcms       When lChumba Size C(045),C(009) COLOR CLR_BLACK Picture("@E 9,999,999.99") PIXEL OF oDlg
   @ C(056),C(035) MsGet oGet5  Var cComissao   When lChumba Size C(045),C(009) COLOR CLR_BLACK Picture("@E 9,999,999.99") PIXEL OF oDlg
   @ C(057),C(129) MsGet oGet10 Var cMedio      When lChumba Size C(045),C(009) COLOR CLR_BLACK Picture("@E 9,999,999.99") PIXEL OF oDlg
   @ C(069),C(035) MsGet oGet6  Var cFrete      When lChumba Size C(045),C(009) COLOR CLR_BLACK Picture("@E 9,999,999.99") PIXEL OF oDlg
   @ C(069),C(129) MsGet oGet11 Var cPrcVenda   When lChumba Size C(045),C(009) COLOR CLR_BLACK Picture("@E 9,999,999.99") PIXEL OF oDlg
   @ C(069),C(222) MsGet oGet13 Var cIcmsSt     When lChumba Size C(045),C(009) COLOR CLR_BLACK Picture("@E 9,999,999.99") PIXEL OF oDlg
   @ C(082),C(035) MsGet oGet7  Var cCustoAdm   When lChumba Size C(045),C(009) COLOR CLR_BLACK Picture("@E 9,999,999.99") PIXEL OF oDlg
   @ C(082),C(222) MsGet oGet14 Var nValPIS     When lChumba Size C(045),C(009) COLOR CLR_BLACK Picture("@E 9,999,999.99") PIXEL OF oDlg
   @ C(095),C(222) MsGet oGet15 Var nValCOF     When lChumba Size C(045),C(009) COLOR CLR_BLACK Picture("@E 9,999,999.99") PIXEL OF oDlg
   @ C(082),C(129) MsGet oGet19 Var nJuros      When lChumba Size C(045),C(009) COLOR CLR_BLACK Picture("@E 9,999,999.99") PIXEL OF oDlg

   @ C(116),C(005) Button "Detalhes do pedido de Venda" Size C(086),C(012) PIXEL OF oDlg ACTION( AbrePV(SC6->C6_FILIAL, SC6->C6_NUM) )
   @ C(116),C(229) Button "Retornar"                    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)
                           
// Abre a visualização do Pedido de Venda
Static Function AbrePV( __Filial, __Pedido )

   dbSelectArea("SC5")
   dbSetOrder(1)
   dbSeek(__Filial + __Pedido)

   A410Visual("SC5",SC5->( Recno() ),2)
   
Return(.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MA410Impos³ Autor ³ Eduardo Riera         ³ Data ³06.12.2001 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³Ma410Impos( nOpc)                                            ³±±
±±³          ³Funcao de calculo dos impostos contidos no pedido de venda   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nOpc                                                        ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                       ³±±
±±³          ³                                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Esta funcao efetua os calculos de impostos (ICMS,IPI,ISS,etc)³±±
±±³          ³com base nas funcoes fiscais, a fim de possibilitar ao usua- ³±±
±±³          ³rio o valor de desembolso financeiro.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

// Na venda com ST buscar o valor da última compra do produto | ICMS próprio (soma como custo no final do calculo)
// Buscar na CDM | Crédito Adjudicado (subtrai do valor final)
// FISR0178 - Relatório que faz o cálculo

Static Function _xCalcImp()

	Local aFisGet	 := {}
	Local aFisGetSC5 := {}
	//Local aTitles   := {"Nota Fiscal","Duplicatas","Rentabilidade"} //"Nota Fiscal"######
	Local aDupl     := {}
	Local aVencto   := {}
	//Local aFlHead   := { STR0046,STR0047,STR0063 } //"Vencimento"###"Valor"
	Local aEntr     := {}
	Local aDuplTmp  := {}
	//Local aRFHead   := { RetTitle("C6_PRODUTO"),RetTitle("C6_VALOR"),STR0081,STR0082,STR0083,STR0084} //"C.M.V"###"Vlr.Presente"###"Lucro Bruto"###"Margem de Contribuição(%)"
	Local aRentab   := {}
	Local nPLocal   := 0
	Local nPTotal   := 0
	Local nPValDesc := 0
	Local nPPrUnit  := 0
	Local nPPrcVen  := 0
	Local nPQtdVen  := 0
	Local nPDtEntr  := 0
	Local nPProduto := 0
	Local nPTES     := 0
	Local nPNfOri   := 0
	Local nPSerOri  := 0
	Local nPItemOri := 0
	Local nPIdentB6 := 0
	Local nPSuframa := 0
//	Local nUsado    := Len(aHeader)
	Local nX        := 0
	Local nAcerto   := 0
	Local nPrcLista := 0
	Local nValMerc  := 0
	Local nDesconto := 0
	Local nAcresFin := 0
	Local nQtdPeso  := 0
	Local nRecOri   := 0
	Local nPosEntr  := 0
	Local nItem     := 0
	Local nY        := 0 
	Local nPosCpo   := 0
	Local lDtEmi    := SuperGetMv("MV_DPDTEMI",.F.,.T.)
	Local dDataCnd  := ""
	Local oDlg
	Local oDupl
	Local oFolder
	Local oRentab
	Local lCondVenda := .F. // Template GEM
	Local aRentabil := {}
	Local cProduto  := ""
	Local nTotDesc  := 0
	
    // Posiciona na tabela SC5
	dbSelectArea("SC5")
	dbSetOrder(1)
	MsSeek(SC6->C6_FILIAL + SC6->C6_NUM)

	dDataCnd  := SC5->C5_EMISSAO

	//³Busca referencias nos itens                  
	aFisGet	:= {}
	cAlias2 := "SC6"
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek(cAlias2)
	While !Eof().And.X3_ARQUIVO==cAlias2
		cValid := UPPER(X3_VALID+X3_VLDUSER)
		If 'MAFISGET("'$cValid
			nPosIni 	:= AT('MAFISGET("',cValid)+10
			nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
			cReferencia := Substr(cValid,nPosIni,nLen)
			aAdd(aFisGet,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		If 'MAFISREF("'$cValid
			nPosIni		:= AT('MAFISREF("',cValid) + 10
			cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
			aAdd(aFisGet,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		dbSkip()
	EndDo
	aSort(aFisGet,,,{|x,y| x[3]<y[3]})
	
	cAlias1 := "SC5"

	//³Busca referencias no cabecalho               
	aFisGetSC5	:= {}
	dbSelectArea("SX3")
	dbSetOrder(1)
	MsSeek(cAlias1)
	While !Eof().And.X3_ARQUIVO==cAlias1
		cValid := UPPER(X3_VALID+X3_VLDUSER)
		If 'MAFISGET("'$cValid
			nPosIni 	:= AT('MAFISGET("',cValid)+10
			nLen		:= AT('")',Substr(cValid,nPosIni,Len(cValid)-nPosIni))-1
			cReferencia := Substr(cValid,nPosIni,nLen)
			aAdd(aFisGetSC5,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		If 'MAFISREF("'$cValid
			nPosIni		:= AT('MAFISREF("',cValid) + 10
			cReferencia	:=Substr(cValid,nPosIni,AT('","MT410",',cValid)-nPosIni)
			aAdd(aFisGetSC5,{cReferencia,X3_CAMPO,MaFisOrdem(cReferencia)})
		EndIf
		dbSkip()
	EndDo
	aSort(aFisGetSC5,,,{|x,y| x[3]<y[3]})
	
	//³Inicializa a funcao fiscal                   
	MaFisSave()
	MaFisEnd()

	// Pedido de Vendas
	MaFisIni(SC5->C5_CLIENTE                ,;  // 1-Codigo Cliente/Fornecedor
		     SC5->C5_LOJAENT                ,;  // 2-Loja do Cliente/Fornecedor
		     IIf(SC5->C5_TIPO$'DB',"F","C") ,;	// 3-C:Cliente , F:Fornecedor
		     SC5->C5_TIPO                   ,;	// 4-Tipo da NF
		     SC5->C5_TIPOCLI                ,;	// 5-Tipo do Cliente/Fornecedor
		     Nil,;
		     Nil,;
		     Nil,;
		     Nil,;
		     "MATA461")

    // Realiza alteracoes de referencias do cabecalho
  	If Len(aFisGetSC5) > 0
		dbSelectArea(cAlias1)
		For nY := 1 to Len(aFisGetSC5)
			If !Empty(&("SC5->"+Alltrim(aFisGetSC5[ny][2])))
				MaFisAlt(aFisGetSC5[ny][1],&("SC5->"+Alltrim(aFisGetSC5[ny][2])),,.F.)
			EndIf
		Next nY
	Endif
	
	// Agrega os itens para a funcao fiscal         
	nQtdPeso := 0

	//³Posiciona Registros     
	cProduto := SC6->C6_PRODUTO
	MatGrdPrRf(@cProduto)
	SB1->(dbSetOrder(1))
	If SB1->(MsSeek(xFilial("SB1")+cProduto))
		nQtdPeso := SC6->C6_QTDVEN * SB1->B1_PESO
	EndIf
	
    SB2->(dbSetOrder(1))
    SB2->(MsSeek(xFilial("SB2")+SB1->B1_COD + SB1->B1_LOCPAD))

    SF4->(dbSetOrder(1))
    SF4->(MsSeek(xFilial("SF4") + SC6->C6_TES))

   	// Calcula o preco de lista                     
	nValMerc  := SC6->C6_VALOR
	nPrcLista := SC6->C6_PRCVEN
	If ( nPrcLista == 0 )
		nPrcLista := NoRound(nValMerc/SC6->C6_QTDVEN,TamSX3("C6_PRCVEN")[2])
	EndIf

	nAcresFin := A410Arred(SC6->C6_PRCVEN * SC5->C5_ACRSFIN/100,"D2_PRCVEN")

	nValMerc  += A410Arred(SC6->C6_QTDVEN * nAcresFin,"D2_TOTAL")
	nDesconto := a410Arred(nPrcLista * SC6->C6_QTDVEN,"D2_DESCON")-nValMerc
	nDesconto := IIf(nDesconto==0,SC6->C6_VALDESC,nDesconto)
	nDesconto := Max(0,nDesconto)
	nPrcLista += nAcresFin
	
	//Para os outros paises, este tratamento e feito no programas que calculam os impostos.
	If cPaisLoc=="BRA"
		nValMerc  += nDesconto
	Endif
	
	//³Verifica a data de entrega para as duplicatas³
	If ( nPDtEntr > 0 )
		If ( dDataCnd > SC6->C6_ENTREG .And. !Empty(SC6->C6_ENTREG) )
			dDataCnd := SC6->C6_ENTREG
		EndIf
	Else
		dDataCnd  := SC5->C5_EMISSAO
	EndIf

	//³Agrega os itens para a funcao fiscal         ³
	MaFisAdd(cProduto,;   	// 1-Codigo do Produto ( Obrigatorio )
			 SC6->C6_TES,;	   	// 2-Codigo do TES ( Opcional )
			 SC6->C6_QTDVEN,;  	// 3-Quantidade ( Obrigatorio )
			 nPrcLista,;		  	// 4-Preco Unitario ( Obrigatorio )
			 nDesconto,; 	// 5-Valor do Desconto ( Opcional )
			 "",;	   			// 6-Numero da NF Original ( Devolucao/Benef )
			 "",;				// 7-Serie da NF Original ( Devolucao/Benef )
			 nRecOri,;					// 8-RecNo da NF Original no arq SD1/SD2
			 0,;					// 9-Valor do Frete do Item ( Opcional )
			 0,;					// 10-Valor da Despesa do item ( Opcional )
			 0,;					// 11-Valor do Seguro do item ( Opcional )
			 0,;					// 12-Valor do Frete Autonomo ( Opcional )
			 nValMerc,;			// 13-Valor da Mercadoria ( Obrigatorio )
			 0)					// 14-Valor da Embalagem ( Opiconal )	

	//³Calculo do ISS                               ³
	SF4->(dbSetOrder(1))
	SF4->(MsSeek(xFilial("SF4") + SC6->C6_TES))
	If ( SC5->C5_INCISS == "N" .And. SC5->C5_TIPO == "N")
		If ( SF4->F4_ISS=="S" )
			nPrcLista := a410Arred(nPrcLista/(1-(MaAliqISS(nItem)/100)),"D2_PRCVEN")
			nValMerc  := a410Arred(nValMerc/(1-(MaAliqISS(nItem)/100)),"D2_PRCVEN")
			MaFisAlt("IT_PRCUNI",nPrcLista,nItem)
			MaFisAlt("IT_VALMERC",nValMerc,nItem)
		EndIf
	EndIf

	//³Analise da Rentabilidade                     ³
	If SF4->F4_DUPLIC=="S"
		//nTotDesc += MaFisRet(nItem,"IT_DESCONTO")
		nTotDesc += MaFisRet(1,"IT_DESCONTO")

		aadd(aRenTab,{SC6->C6_PRODUTO,0,0,0,0,0})

		If cPaisLoc=="BRA"
			aRentab[1][2] += (nValMerc - nDesconto)
		Else
			aRentab[1][2] += nValMerc
		Endif
		aRentab[1][3] += SC6->C6_QTDVEN * SB2->B2_CM1
	Else
		If GetNewPar("MV_TPDPIND","1")=="1"
		   //nTotDesc += MaFisRet(nItem,"IT_DESCONTO")
           nTotDesc += MaFisRet(1,"IT_DESCONTO")
		EndIf
    EndIf

	//³Indica os valores do cabecalho               
	If !Empty(SC5->(FieldPos("C5_VLR_FRT")))
		MaFisAlt("NF_VLR_FRT",SC5->C5_VLR_FRT)
	EndIf	
	MaFisAlt("NF_SEGURO",SC5->C5_SEGURO)
	MaFisAlt("NF_AUTONOMO",SC5->C5_FRETAUT)
	MaFisAlt("NF_DESPESA",SC5->C5_DESPESA)

	//³Indenizacao por valor                        ³
	If SC5->C5_DESCONT > 0
		MaFisAlt("NF_DESCONTO",Min(MaFisRet(,"NF_VALMERC")-0.01,nTotDesc+SC5->C5_DESCONT),/*nItem*/,/*lNoCabec*/,/*nItemNao*/,GetNewPar("MV_TPDPIND","1")=="2" )
	EndIf
		
	If SC5->C5_PDESCAB > 0
		MaFisAlt("NF_DESCONTO",A410Arred(MaFisRet(,"NF_VALMERC") * SC5->C5_PDESCAB/100,"C6_VALOR")+MaFisRet(,"NF_DESCONTO"))
	EndIf

/*
	//³Realiza alteracoes de referencias do SC6         
	dbSelectArea(cAlias2)
	If Len(aFisGet) > 0
		For nY := 1 to Len(aFisGet)
			If !Empty(&("SC6->"+Alltrim(aFisGet[ny][2])))
				MaFisAlt(aFisGet[ny][1],&("SC6->"+Alltrim(aFisGet[ny][2])),,.F.)
			EndIf
		Next ny
	EndIf  */

	_QnAliqIcm   := MaFisRet(1,"IT_ALIQICM")
	_QnValIcm    := MaFisRet(1,"IT_VALICM" )
	_QnBaseIcm   := MaFisRet(1,"IT_BASEICM")
	_QnValIpi    := MaFisRet(1,"IT_VALIPI" )
	_QnBaseIpi   := MaFisRet(1,"IT_BASEICM")
	_QnValMerc   := MaFisRet(1,"IT_VALMERC")
	_QnValSol    := MaFisRet(1,"IT_VALSOL" )
	_QnValDesc   := MaFisRet(1,"IT_DESCONTO" )
	_QnPrVen     := MaFisRet(1,"IT_PRCUNI")

Return(.T.)