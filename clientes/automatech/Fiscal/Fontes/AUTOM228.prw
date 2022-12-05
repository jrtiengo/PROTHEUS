#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM228.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 10/04/2013                                                          *
// Objetivo..: Programa que abre janela de consulta de variáveis do cálculo de mar-*
//             gem dos produtos do pedido de venda.                                *
//**********************************************************************************

User Function AUTOM228()

   Local lChumba := .F.

   Local nPpis 	:= GetMv("MV_TXPIS")  			// Percentual de PIS
   Local nPcof 	:= GetMv("MV_TXCOF")			// Percentual de COFINS
   Local nPAdm 	:= GetMv("MV_CUSTADM")			// Percentual de Custo Administrativo
   Local nPFre 	:= GetMv("MV_CUSTFRE")			// Percentual de Frete

   Local cCodFilial   := Space(02)
   Local cPedido      := Space(06)
   Local cProduto     := Space(20)
   Local cDescricao   := Space(40)
   Local cQunatidade  := 0
   Local cComissao    := 0
   Local cFrete       := 0
   Local cCustoAdm    := 0
   Local cCondicao    := Space(25)
   Local cNomeCond    := Space(25)
   Local cVendedor    := Space(06)
   Local cNomeVend    := Space(40)
   Local cMedio  	  := 0
   Local cPrcVenda 	  := 0
   Local cIcms        := 0
   Local cIcmsSt 	  := 0
   Local nValPis	  := 0
   Local nValCof	  := 0
   Local cMargem      := 0
   Local vMargem      := 0
   Local nJuros 	  := 0
   Local cTransporte  := Space(40)
   Local cNometransp  := Space(03)
   Local cTes	      := Space(03)
   Local cNomeTes     := Space(60)
   Local cTipoFrete	  := Space(25)
   Local cPcomissao   := 0
   Local cPfrete      := nPFre
   Local cPCustoAdm   := nPAdm
   Local cGet28	      := Space(25)
   Local nPjuros      := 0
   Local nPicms	      := 0
   Local nPicmsSt     := 0
   Local nPPis	      := nPpis
   Local nPCof	      := nPcof
   Local cDifAliquota := 0
   Local cTotalProdut := 0
   Local nFreteCob    := 0
   Local __Cliente    := Space(60)
   Local __Cidade     := Space(60)
   Local __Condicao   := Space(60)
   Local __Vendedor   := Space(40)
   Local __Transporte := Space(60)
   Local __Tes        := Space(60)
   Local lReal    	  := .F.
   Local lDolar	      := .F.
   Local cData        := Date()

   Local cAdjudicado  := 0
   Local pAdjudicado  := 0
   Local nTotalCusto  := 0
   Local pDifAliquota := 0

   Local cMemo1	 := ""
   Local cMemo3	 := ""
   Local cMemo4	 := ""
   Local cMemo5	 := ""
   Local cMemo6	 := "" 
   Local cMemo7	 := "" 
   Local cMemo8	 := ""    
   
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
   Local oGet20
   Local oGet21
   Local oGet22
   Local oGet23
   Local oGet24
   Local oGet25
   Local oGet26
   Local oGet27
   Local oGet28
   Local oGet29
   Local oGet30
   Local oGet31
   Local oGet32
   Local oGet33
   Local oGet34
   Local oGet35
   Local oGet36
   Local oGet37
   Local oGet38
   Local oGet40
   Local oGet41
   Local oGet42
   Local oGet43
   Local oGet44
   Local oGet46

   Local oMemo1
   Local oMemo3
   Local oMemo4
   Local oMemo5
   Local oMemo6
   Local oMemo7
   Local oMemo8   

   Local oCheckBox1
   Local oCheckBox2

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
   Private cCotacao    := 1

   Private oDlg

   dbSelectArea("SC6")
   dbSetOrder(1)
   If !dbSeek('01' + '046978')
      MsgAlert("não encontrado")
      Return(.T.)
   Endif

   // Carrega as variáveis para display
   cCodFilial  := SC6->C6_FILIAL
   cPedido     := SC6->C6_NUM
   cProduto    := SC6->C6_PRODUTO
   cDescricao  := SC6->C6_DESCRI
   cQuantidade := SC6->C6_QTDVEN

   // Pesquisa os dados do Pedido de Venda
   If Select("T_PEDIDO") > 0
      T_PEDIDO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC5.C5_EMISSAO,"
   cSql += "       SC5.C5_CONDPAG,"
   cSql += "       SC5.C5_TPFRETE,"
   cSql += "       SC5.C5_TRANSP ,"
   cSql += "       SC5.C5_TPFRETE,"
   cSql += "       SC5.C5_FRETE  ,"
   cSql += "       SC5.C5_CLIENTE,"
   cSql += "       SC5.C5_LOJACLI,"
   cSql += "       SC5.C5_MOEDA  ,"
   cSql += "       SC5.C5_VEND1  ,"
   cSql += "       SC5.C5_COMIS1 ,"
   cSql += "       SC5.C5_COMIS2 ,"
   cSql += "       SC5.C5_COMIS3 ,"
   cSql += "       SC5.C5_COMIS4 ,"
   cSql += "       SC5.C5_COMIS5 ,"         
   cSql += "       SA1.A1_NOME   ,"
   cSql += "       SA1.A1_EST    ,"
   cSql += "       SA1.A1_MUN    ,"
   cSql += "       SA1.A1_CEP     "
   cSql += "  FROM " + RetSqlName("SC5") + " SC5, "
   cSql += "       " + RetSqlName("SA1") + " SA1  "
   cSql += " WHERE SC5.C5_FILIAL  = '" + Alltrim(SC6->C6_FILIAL) + "'"
   cSql += "   AND SC5.C5_NUM     = '" + Alltrim(SC6->C6_NUM)    + "'"
   cSql += "   AND SC5.D_E_L_E_T_ = ''"            
   cSql += "   AND SC5.C5_CLIENTE = SA1.A1_COD "
   cSql += "   AND SC5.C5_LOJACLI = SA1.A1_LOJA"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )

   If T_PEDIDO->( EOF() )
      cCondicao    := ""
      cNomeCond    := ""
      cVendedor    := ""
      cNomeVend    := ""
      cTransporte  := ""
      cNomeTransp  := ""
      cTipoFrete   := ""
      nFretecob    := 0
      __Cliente    := ""
      __Cidade     := ""
      __Condicao   := ""
      __Vendedor   := ""
      __Transporte := ""
      __Tes        := ""
      lReal        := .F.
      lDolar       := .F.
   Else
      __Cliente   := Alltrim(T_PEDIDO->A1_NOME)
      __Cidade    := Alltrim(T_PEDIDO->A1_MUN) + '(' + Alltrim(T_PEDIDO->A1_EST) + ') - CEP: ' + SUBSTR(T_PEDIDO->A1_CEP,01,02) + '.' + SUBSTR(T_PEDIDO->A1_CEP,03,03) + '-' + SUBSTR(T_PEDIDO->A1_CEP,06,03)
      cCondicao   := T_PEDIDO->C5_CONDPAG
      cNomeCond   := ""
      cVendedor   := T_PEDIDO->C5_VEND1
      cNomeVend   := ""
      cTransporte := T_PEDIDO->C5_TRANSP
      cNomeTransp := ""
      nFreteCob   := T_PEDIDO->C5_FRETE
      Do Case
         Case T_PEDIDO->C5_TPFRETE == "C"
              cTipoFrete  := "CIF"
         Case T_PEDIDO->C5_TPFRETE == "F"
              cTipoFrete  := "FOB"
         Otherwise
              cTipoFrete  := "   "
      EndCase

      If T_PEDIDO->C5_MOEDA == 1
         lReal  := .T.
         lDolar := .F.
      Else
         lReal  := .F.
         lDolar := .T.
      Endif

   Endif

   // Captura a cotação da moeda 2 para a data atual
   If Select("T_COTACAO") > 0
      T_COTACAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT M2_MOEDA2"
   cSql += "  FROM " + RetSqlName("SM2")
   cSql += " WHERE M2_DATA    = CONVERT(DATETIME,'" + Dtoc(Date()) + "', 103)"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COTACAO", .T., .T. )

   If !T_COTACAO->( EOF() )
      If lDolar
         cCotacao := T_COTACAO->M2_MOEDA2
      Endif
   Endif   

   // Converte em dolar se necessário
   cPrcVenda := SC6->C6_PRCVEN
   cPrcVenda := IIF(lDolar, Round(cPrcVenda * cCotacao,2), cPrcVenda)

   // Pesquisa dados da Transportadora
   If Select("T_TRANSPORTE") > 0
      T_TRANSPORTE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SA4.A4_NOME   "
   cSql += "  FROM " + RetSqlName("SA4") + " SA4  "
   cSql += " WHERE SA4.A4_COD = '" + Alltrim(cTransporte) + "'"
   cSql += "   AND SA4.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TRANSPORTE", .T., .T. )

   If T_TRANSPORTE->( EOF() )
      cNomeTransp  := ""
      __Transporte := ""
   Else
      cNomeTransp  := T_TRANSPORTE->A4_NOME
      __Transporte := T_TRANSPORTE->A4_NOME
   Endif

   // Pesquisa a Condição de Pagamento
   If Select("T_CONDICAO") > 0
      T_CONDICAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SE4.E4_DESCRI   "
   cSql += "  FROM " + RetSqlName("SE4") + " SE4  "
   cSql += " WHERE SE4.E4_CODIGO  = '" + Alltrim(cCondicao) + "'"
   cSql += "   AND SE4.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONDICAO", .T., .T. )

   If T_CONDICAO->( EOF() )
      cNomeCond  := ""
      __Condicao := ""
   Else
      cNomeCond  := T_CONDICAO->E4_DESCRI
      __Condicao := T_CONDICAO->E4_DESCRI
   Endif

   // Pesquisa o NOme do Vendedor para Display
   If Select("T_VENDEDOR") > 0
      T_VENDEDOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A3_COD , "
   cSql += "       A3_NOME  "
   cSql += "  FROM " + RetSqlName("SA3")
   cSql += " WHERE A3_COD     = '" + Alltrim(cVendedor) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

   If T_VENDEDOR->( EOF() )
      cNomeVend  := ""
      __Vendedor := ""
   Else
      cNomeVend  := T_VENDEDOR->A3_NOME
      __Vendedor := T_VENDEDOR->A3_NOME
   Endif

   // Pesquisa a descrição do TES do produto selecionado
   SF4->(dbSetOrder(1))
   SF4->(MsSeek(xFilial("SF4") + SC6->C6_TES))
   
   If Empty(Alltrim(SF4->F4_FINALID))
      cTES     := SC6->C6_TES
      cNomeTes := SF4->F4_TEXTO
      __Tes    := SF4->F4_TEXTO
   Else
      cTES     := SC6->C6_TES
      cNomeTes := SF4->F4_FINALID
      __Tes    := SF4->F4_FINALID
   Endif      

   cMargem    := 0
   vMargem    := 0
  
   cComissao  := (cPrcVenda * (SC6->C6_COMIS1 + SC6->C6_COMIS2 + SC6->C6_COMIS3 + SC6->C6_COMIS4 + SC6->C6_COMIS5)) / 100
   cPcomissao := SC6->C6_COMIS1 + SC6->C6_COMIS2 + SC6->C6_COMIS3 + SC6->C6_COMIS4 + SC6->C6_COMIS5
   cMedio     := Posicione("SB2",1,xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL,"B2_CM1")
   cCustoAdm  := cMedio * ( nPAdm / 100 )

   If cPcomissao == 0
      cPcomissao := T_PEDIDO->C5_COMIS1 + T_PEDIDO->C5_COMIS2 + T_PEDIDO->C5_COMIS3 + T_PEDIDO->C5_COMIS4 + T_PEDIDO->C5_COMIS5
   Endif

   nCustFrt   := cPrcVenda * ( nPFre / 100 )
   cFrete     := Iif( T_PEDIDO->C5_TPFRETE == "C", nCustFrt, 0 )
   
   // Calculo os impostos
   _xCalcImp(cPrcVenda)

   nPIcms := _QnAliqIcm
   cIcms  := _QnValIcm / SC6->C6_QTDVEN

   // Calcula o ICMS ST
   aRetDife := U_xCalDifal(SC6->C6_FILIAL, SC6->C6_PRODUTO, SC6->C6_CLI, SC6->C6_LOJA, cPrcvenda, SC6->C6_TES, nFretecob )

// aRetDife := U_AlqCalcST( SC6->C6_PRODUTO, SC6->C6_CLI, SC6->C6_LOJA, cPrcvenda, SC6->C6_TES )

   nPicmsSt := aRetDife[5]  && 4
   cIcmsSt  := aRetDife[1]

   cDifAliquota := cIcmsSt
   pDifAliquota := aRetDife[5] &&4
   cTotalProdut := cPrcVenda + cIcmsSt

   // Calcula o valor do PIS
   nValPIS := cPrcVenda * ( nPpis / 100 )

   // Calcula o valor do COFINS
   nValCOF := cPrcVenda * ( nPcof / 100 )

   // Calcula o valor do Juro
   _TpCond := Posicione( "SE4", 1, xFilial("SE4") + T_PEDIDO->C5_CONDPAG, "E4_TIPO" ) //Verifico o tipo da condicao de pagamento

   If _TpCond != "9" // Se for tipo 9 não tenho como calcular

 	  _nValjur := 0
	  _aParc := Condicao( cPrcVenda, T_PEDIDO->C5_CONDPAG, , STOD(T_PEDIDO->C5_EMISSAO) )

	  For _nX := 1 To Len( _aParc )
			
	 	  _dVenc  := _aParc[ _nX, 1 ]
		  _nValor := _aParc[ _nX, 2 ]
		  _nDias  := DateDiffDay( STOD(T_PEDIDO->C5_EMISSAO), _dVenc )
			
		  _nValjur += _nValor / ( ( 1 + ( Getmv("MV_JUROS") / 100 ) ) ** ( _nDias / 30 ) )
			
	  Next

	  _nPorJur := 1 - ( _nValJur / cPrcvenda )
	  nPJuros  := _nPorJur
	  nJuros   := _nPorJur * cPrcvenda

   EndIf

   // Calcula o Crédito Adjudicado
//   aRetDife := U_xCalDifal(SC6->C6_FILIAL, SC6->C6_PRODUTO, SC6->C6_CLI, SC6->C6_LOJA, cPrcvenda, SC6->C6_TES, nFretecob )

 aRetDife := U_xAlqCalcST( SC6->C6_PRODUTO, SC6->C6_CLI, SC6->C6_LOJA, cPrcvenda, SC6->C6_TES ) 

   _xCustoEnt := aRetDife[2]
   _xMVA      := aRetDife[3]
   _xAliquota := aRetDife[4]
   _xReducao  := aRetDife[5]

   If _xReducao == 0
      cAdjudicado := (((_xCustoEnt * _xMVA) / 100) * _xAliquota) / 100
   Else
      cAdjudicado := (((((_xCustoEnt - ((_xCustoEnt * _xReducao) / 100)) * _xMVA) / 100) * _xAliquota) / 100)
   Endif   

   // Calcula o Acumulado do Custo
   _nSumCust   := cIcms  + cComissao + cFrete - cIcmsSt + nValPIS + nValCOF + nJuros

   // Custo de Entrada 
   nCustTotFin := cMedio + cCustoAdm - cAdjudicado

   _nMargem := ( ( cPrcVenda - _nSumCust ) - nCustTotFin )// Subtraio do preco de venda, todo o custo referente o mesmo 
   vMargem  := _nMargem
   cMargem  := Round((( _nMargem / cPrcVenda ) * 100),2) // % da Margem

   // Conforme orientação do Roger, o diferencial de alquota das variáveis deverá ficar zerado por hora
   nPicmsSt := 0
   cIcmsSt  := 0

   // Desenha a Tela
   DEFINE MSDIALOG oDlg TITLE "Parâmetros Calculo Margem" FROM C(186),C(190) TO C(611),C(939) PIXEL

   @ C(022),C(005) Say "Cliente"                    Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(022),C(189) Say "Ciade"                      Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(034),C(005) Say "Cond. de Pagtº"             Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(046),C(005) Say "Transportadora"             Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(046),C(309) Say "Tipo de Frete"              Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(059),C(005) Say "T E S"                      Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(059),C(189) Say "Vendedor"                   Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(075),C(125) Say "Magem do Item"              Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(076),C(246) Say "%"                          Size C(007),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(092),C(005) Say "VARIÁVEIS DE CÁLCULO"       Size C(064),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(104),C(005) Say "Custo Médio"                Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
// @ C(104),C(114) Say "%"                          Size C(005),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(104),C(140) Say "Comissão"                   Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(105),C(243) Say "%"                          Size C(005),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(104),C(364) Say "%"                          Size C(005),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(105),C(262) Say "ICMS"                       Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(116),C(005) Say "Custo Adm"                  Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(117),C(115) Say "%"                          Size C(005),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(116),C(140) Say "Frete"                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(117),C(243) Say "%"                          Size C(005),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(116),C(364) Say "%"                          Size C(005),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(117),C(262) Say "ICMS ST"                    Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(127),C(005) Say "C.Adjudicado"               Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlg
// @ C(128),C(115) Say "%"                          Size C(006),C(008) COLOR CLR_BLACK PIXEL OF oDlg
// @ C(127),C(122) Button "..."                     Size C(011),C(009) PIXEL OF oDlg
   @ C(127),C(140) Say "Juros"                      Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(128),C(243) Say "%"                          Size C(005),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(127),C(262) Say "PIS"                        Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(127),C(364) Say "%"                          Size C(005),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(139),C(364) Say "%"                          Size C(005),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(140),C(005) Say "Custo Total"                Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(140),C(262) Say "COFINS"                     Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(158),C(005) Say "VALORES DO PEDIDO DE VENDA" Size C(088),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(168),C(171) Say "Valor Venda"                Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(169),C(005) Say "Moeda"                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(177),C(108) Say "Valor Total (R$)"           Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(181),C(171) Say "DIFAL"                      Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(182),C(295) Say "%"                          Size C(005),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(183),C(005) Say "Data"                       Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(185),C(108) Say "do Frete Cobrado"           Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(194),C(171) Say "Total do Produto"           Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(197),C(005) Say "Cotação"                    Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   // Zera os percentuais em caso de valores zerados
   If cComissao == 0
      cComissao  := 0
      cPcomissao := 0
   Endif
      
   If cIcms == 0
      cIcms  := 0
      nPIcms := 0
   Endif

   If cFrete == 0
      cFrete  := 0
      cPfrete := 0
   Endif
      
   If nJuros == 0
      nJuros  := 0
      nPjuros := 0
   Endif
      
   If cIcmsSt == 0
      cIcmsSt  := 0
      nPicmsSt := 0
   Endif
      
   If cCustoAdm == 0
      cCustoAdm  := 0
      cPcustoAdm := 0
   Endif
      
   If nValPis == 0
      nValPis := 0
      nPPis   := 0
   Endif   

   If nValCof == 0
      nValCof := 0
      nPCof   := 0
   Endif   

   // Calcula o custo médio total para display
   nTotalCusto := cMedio + cCustoAdm - cAdjudicado

   // Se pedido de venda em dolar, converte o valor pela taxa do dolar do dia
   If lDolar == .T.
      cDifAliquota = Round(cDifAliquota * cCotacao,2)
      cTotalProdut = Round(cTotalProdut * cCotacao,2)
   Endif

   // Se não houve valor de diferencial de aliquota, zera o percentual do diferencial
   If cDifAliquota == 0
      pDifAliquota := 0
   Endif

   @ C(010),C(005) MsGet    oGet1      Var cPedido      When lChumba   Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(010),C(045) MsGet    oGet2      Var cProduto     When lChumba   Size C(085),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(010),C(135) MsGet    oGet3      Var cDescricao   When lChumba   Size C(206),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(010),C(345) MsGet    oGet4      Var cQuantidade  When lChumba   Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(022),C(045) MsGet    oGet39     Var __Cliente    When lChumba   Size C(138),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(022),C(217) MsGet    oGet46     Var __Cidade     When lChumba   Size C(153),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(034),C(045) MsGet    oGet9      Var __Condicao   When lChumba   Size C(324),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(045) MsGet    oGet21     Var __Transporte When lChumba   Size C(259),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(345) MsGet    oGet24     Var cTipoFrete   When lChumba   Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(058),C(045) MsGet    oGet23     Var __Tes        When lChumba   Size C(138),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(058),C(217) MsGet    oGet23     Var __Vendedor   When lChumba   Size C(153),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(070),C(005) GET      oMemo6     Var cMemo6 MEMO  When lChumba   Size C(365),C(001) PIXEL OF oDlg
   @ C(074),C(169) MsGet    oGet18     Var vMargem      When lChumba   Size C(045),C(009) COLOR CLR_BLACK Picture ("@E 9,999,999.99") PIXEL OF oDlg
   @ C(074),C(217) MsGet    oGet40     Var cMargem      When lChumba   Size C(025),C(009) COLOR CLR_BLACK Picture ("@E 999,999.99")   PIXEL OF oDlg
   @ C(087),C(005) GET      oMemo1     Var cMemo1 MEMO  When lChumba   Size C(365),C(001) PIXEL OF oDlg
   @ C(103),C(040) MsGet    oGet10     Var cMedio       When lChumba   Size C(045),C(009) COLOR CLR_BLACK Picture ("@E 9,999,999.99") PIXEL OF oDlg
   @ C(103),C(169) MsGet    oGet5      Var cComissao    When lChumba   Size C(045),C(009) COLOR CLR_BLACK Picture ("@E 9,999,999.99") PIXEL OF oDlg
   @ C(103),C(217) MsGet    oGet25     Var cPcomissao   When lChumba   Size C(022),C(009) COLOR CLR_BLACK Picture ("@E 999.99")       PIXEL OF oDlg

   @ C(103),C(250) Button "..." Size C(009),C(010) PIXEL OF oDlg ACTION( TelaComissao() )

   @ C(103),C(289) MsGet    oGet12     Var cIcms        When lChumba   Size C(045),C(009) COLOR CLR_BLACK Picture ("@E 9,999,999.99") PIXEL OF oDlg
   @ C(103),C(337) MsGet    oGet30     Var nPicms       When lChumba   Size C(022),C(009) COLOR CLR_BLACK Picture ("@E 999.99")       PIXEL OF oDlg
   @ C(115),C(040) MsGet    oGet7      Var cCustoAdm    When lChumba   Size C(045),C(009) COLOR CLR_BLACK Picture ("@E 9,999,999.99") PIXEL OF oDlg
   @ C(115),C(088) MsGet    oGet27     Var cPcustoAdm   When lChumba   Size C(022),C(009) COLOR CLR_BLACK Picture ("@E 999.99")       PIXEL OF oDlg
   @ C(115),C(169) MsGet    oGet6      Var cFrete       When lChumba   Size C(045),C(009) COLOR CLR_BLACK Picture ("@E 9,999,999.99") PIXEL OF oDlg
   @ C(115),C(217) MsGet    oGet26     Var cPfrete      When lChumba   Size C(022),C(009) COLOR CLR_BLACK Picture ("@E 999.99")       PIXEL OF oDlg
   @ C(115),C(289) MsGet    oGet13     Var cIcmsSt      When lChumba   Size C(045),C(009) COLOR CLR_BLACK Picture ("@E 9,999,999.99") PIXEL OF oDlg
   @ C(115),C(337) MsGet    oGet31     Var nPicmsSt     When lChumba   Size C(022),C(009) COLOR CLR_BLACK Picture ("@E 999.99")       PIXEL OF oDlg

   @ C(127),C(040) MsGet    oGet42     Var cAdjudicado  When lChumba   Size C(045),C(009) COLOR CLR_BLACK Picture ("@E 9,999,999.99") PIXEL OF oDlg
// @ C(127),C(088) MsGet    oGet43     Var pAdjudicado  When lChumba   Size C(022),C(009) COLOR CLR_BLACK Picture ("@E 999.99")       PIXEL OF oDlg
   @ C(139),C(040) MsGet    oGet44     Var nTotalCusto  When lChumba   Size C(045),C(009) COLOR CLR_BLACK Picture ("@E 9,999,999.99") PIXEL OF oDlg

   @ C(127),C(169) MsGet    oGet19     Var nJuros       When lChumba   Size C(045),C(009) COLOR CLR_BLACK Picture ("@E 9,999,999.99") PIXEL OF oDlg
   @ C(127),C(217) MsGet    oGet29     Var nPjuros      When lChumba   Size C(022),C(009) COLOR CLR_BLACK Picture ("@E 999.99")       PIXEL OF oDlg
   @ C(127),C(289) MsGet    oGet14     Var nValPis      When lChumba   Size C(045),C(009) COLOR CLR_BLACK Picture ("@E 9,999,999.99") PIXEL OF oDlg
   @ C(127),C(337) MsGet    oGet32     Var nPpis        When lChumba   Size C(022),C(009) COLOR CLR_BLACK Picture ("@E 999.99")       PIXEL OF oDlg
   @ C(139),C(289) MsGet    oGet15     Var nValCof      When lChumba   Size C(045),C(009) COLOR CLR_BLACK Picture ("@E 9,999,999.99") PIXEL OF oDlg
   @ C(139),C(337) MsGet    oGet33     Var nPcof        When lChumba   Size C(022),C(009) COLOR CLR_BLACK Picture ("@E 999.99")       PIXEL OF oDlg
   @ C(153),C(005) GET      oMemo3     Var cMemo3 MEMO  When lChumba   Size C(365),C(001) PIXEL OF oDlg
   @ C(164),C(100) GET      oMemo7     Var cMemo7 MEMO  When lChumba   Size C(001),C(044) PIXEL OF oDlg
   @ C(164),C(160) GET      oMemo8     Var cMemo8 MEMO  When lChumba   Size C(001),C(044) PIXEL OF oDlg
   @ C(164),C(312) GET      oMemo5     Var cMemo5 MEMO  When lChumba   Size C(001),C(044) PIXEL OF oDlg
   @ C(168),C(220) MsGet    oGet11     Var cPrcVenda    When lChumba   Size C(045),C(009) COLOR CLR_BLACK Picture ("@E 9,999,999.99") PIXEL OF oDlg
   @ C(169),C(029) CheckBox oCheckBox1 Var lReal        Prompt "REAL"  When lChumba Size C(026),C(008) PIXEL OF oDlg
   @ C(169),C(059) CheckBox oCheckBox2 Var lDolar       Prompt "DOLAR" When lChumba Size C(029),C(008) PIXEL OF oDlg
   @ C(181),C(220) MsGet    oGet34     Var cDifAliquota When lChumba   Size C(045),C(009) COLOR CLR_BLACK Picture ("@E 9,999,999.99") PIXEL OF oDlg
   @ C(181),C(268) MsGet    oGet41     Var pDifAliquota When lChumba   Size C(023),C(009) COLOR CLR_BLACK Picture ("@E 999.99")       PIXEL OF oDlg
   @ C(182),C(029) MsGet    oGet37     Var cData        When lChumba   Size C(036),C(009) COLOR CLR_BLACK Picture "@!"                PIXEL OF oDlg
   @ C(194),C(108) MsGet    oGet36     Var nFreteCob    When lChumba   Size C(045),C(009) COLOR CLR_BLACK Picture ("@E 9,999,999.99") PIXEL OF oDlg
   @ C(194),C(220) MsGet    oGet35     Var cTotalProdut When lChumba   Size C(045),C(009) COLOR CLR_BLACK Picture ("@E 9,999,999.99") PIXEL OF oDlg
   @ C(196),C(029) MsGet    oGet38     Var cCotacao     When lChumba   Size C(044),C(009) COLOR CLR_BLACK Picture ("@E 999.9999")     PIXEL OF oDlg

   @ C(181),C(203) Button "..."                                        Size C(012),C(009) PIXEL OF oDlg ACTION( AbreDifal(cEmpAnt, SC6->C6_FILIAL, SC6->C6_NUM) )

// @ C(127),C(122) Button "..."        Size C(011),C(009) PIXEL OF oDlg ACTION( TelaAdjudicado( SC6->C6_PRODUTO, SC6->C6_CLI, SC6->C6_LOJA, SC6->C6_PRCVEN, SC6->C6_TES ) )

   @ C(127),C(089) Button "Detalhes"   When cAdjudicado <> 0 Size C(025),C(009) PIXEL OF oDlg ACTION( TelaAdjudicado( SC6->C6_PRODUTO, SC6->C6_CLI, SC6->C6_LOJA, cPrcvenda, SC6->C6_TES ) )

   @ C(172),C(318) Button "Detalhe PV" Size C(048),C(012) PIXEL OF oDlg ACTION( AbrePV(cCodFilial, cPedido) )
   @ C(185),C(318) Button "Retornar"   Size C(048),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

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

Static Function _xCalcImp(cPrcVenda)

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
    nValMerc  := (SC6->C6_VALOR * cCotacao)

	nPrcLista := cPrcvenda
	If ( nPrcLista == 0 )
		nPrcLista := NoRound(nValMerc/SC6->C6_QTDVEN,TamSX3("C6_PRCVEN")[2])
	EndIf

	nAcresFin := A410Arred(cPrcvenda * SC5->C5_ACRSFIN/100,"D2_PRCVEN")

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

/* Programa para calcular o ICMS ST, adjudicação fiscal e diferencial de alíquota */
User Function xAlqCalcST( cProd, cCli, cLoja, nValor, cTes )

	Local _ICMBASE := 0
	Local _ALIBASE := 0
	Local _ICMRETI := 0
	Local _VALBASE := 0
	Local _ALIRETI := 0
	Local _VALRETI := 0
	Local _CUSTENT := 0
	Local _MVA     := 0
	Local _ALIQINT := 0
	Local _TES     := ""
    Local _REDUCAO := 0
	
	// Campos do Cliente
	Local cEst := Posicione("SA1", 1, xFilial("SA1") + cCli + cLoja, "A1_EST")
	Local cTip := Posicione("SA1", 1, xFilial("SA1") + cCli + cLoja, "A1_TIPO")
	Local cGrp := Posicione("SA1", 1, xFilial("SA1") + cCli + cLoja, "A1_GRPTRIB")

	// Campos da TES
	Local cSol := Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_INCSOL")
	Local cIcm := Posicione("SF4", 1, xFilial("SF4") + cTes, "F4_ICM")
	
	// Campo do Produto
	Local cGtp := Posicione("SB1", 1, xFilial("SB1") + cProd, "B1_GRTRIB")

	// Verifica se o Estado da Empresa Logada é diferente do estado do cliente
	If Alltrim(cEst) == Alltrim(SM0->M0_ESTENT)
		Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _REDUCAO } )
	Endif
 
	// Verifica se cliente é F = Consumidor Final
	If Alltrim(cTip) <> "F"
		Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _REDUCAO } )
	Endif

	// Verifica o ICM Solidário
	If cSol <> "S"
		Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _REDUCAO } )
	Endif

	// Verifica se TES permite calcular ICMS
	If cIcm <> "S"
		Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _REDUCAO } )
	Endif

	// Pesquisa a excesão fiscal para calculo do produto
	If Select("T_FISCAL") > 0
		T_FISCAL->( dbCloseArea() )
	EndIf

	cSql := ""
	cSql := "SELECT F7_EST    ,"
	cSql += "       F7_TIPOCLI," 
	cSql += "       F7_ALIQINT,"
	cSql += "       F7_ALIQEXT,"
	cSql += "       F7_MARGEM ,"
	cSql += "       F7_ALIQDST "
	cSql += "  FROM " + RetSqlName("SF7")
	cSql += " WHERE F7_GRTRIB  = '" + Alltrim(cGtp) + "'"
	cSql += "   AND F7_EST     = '" + Alltrim(cEst) + "'"
	cSql += "   AND F7_TIPOCLI = '" + Alltrim(cTip) + "'"
	cSql += "   AND F7_GRPCLI  = '" + Alltrim(cGrp) + "'"
	cSql += "   AND D_E_L_E_T_ = ''"
 
	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_FISCAL", .T., .T. )
 
	If T_FISCAL->( EOF() )
		If Select("T_FISCAL") > 0
			T_FISCAL->( dbCloseArea() )
		EndIf
		Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _REDUCAO } )
	Endif

	// Calcula o ICMS ST do produto lido

	_ICMBASE := nValor // Valor passado por parâmetro

    If T_FISCAL->F7_ALIQINT >= T_FISCAL->F7_ALIQDST
   	   _ALIBASE := T_FISCAL->F7_ALIQINT - T_FISCAL->F7_ALIQDST
   	Else
   	   _ALIBASE := T_FISCAL->F7_ALIQDST - T_FISCAL->F7_ALIQINT
    Endif

	_VALBASE := (_ICMBASE * _ALIBASE) / 100
	 
	_ICMRETI := nValor // Valor passado por parâmetro


    If T_FISCAL->F7_ALIQINT >= T_FISCAL->F7_ALIQDST
   	   _ALIRETI := (T_FISCAL->F7_ALIQINT - T_FISCAL->F7_ALIQDST)
   	Else
   	   _ALIRETI := (T_FISCAL->F7_ALIQDST - T_FISCAL->F7_ALIQINT)
   	Endif

	_VALRETI := (_ICMRETI * _ALIRETI) / 100
	
	If Select("T_CUSENT") > 0
		T_CUSENT->( dbCloseArea() )
	EndIf

	cSql := ""
	cSql := "SELECT TOP 1 ROUND( ( D1_TOTAL + D1_VALIPI ) / D1_QUANT, 2 ) BASE1, D1_TES "
	cSql += " FROM "+ RetSqlName("SD1")
	cSql += " WHERE " 
	cSql += " D_E_L_E_T_ = '' AND " 
	cSql += " D1_PEDIDO <> '' AND " 
	cSql += " D1_TIPO = 'N' AND " 
	cSql += " D1_COD = '"+ cProd +"' " 
	cSql += " ORDER BY D1_EMISSAO DESC" 
	
	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CUSENT", .T., .T. )
 
	If T_CUSENT->( EOF() )

		If Select("T_FISCAL") > 0
			T_FISCAL->( dbCloseArea() )
		EndIf

		If Select("T_CUSENT") > 0
			T_CUSENT->( dbCloseArea() )
		EndIf

		Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _REDUCAO } )

	Endif

	If T_FISCAL->F7_MARGEM > 0

		_CUSTENT := T_CUSENT->BASE1
		_MVA     := T_FISCAL->F7_MARGEM
		_ALIQINT := T_FISCAL->F7_ALIQINT

	EndIf
	
    // Pesquisa se o Tes de entrada possui % de redução na base de cálculo do ICMS ST
	If Select("T_REDUCAO") > 0
		T_REDUCAO->( dbCloseArea() )
	EndIf

    cSql := ""
    cSql := "SELECT F4_BSICMST "
    cSql += "  FROM " + RetSqlName("SF4")
    cSql += " WHERE F4_CODIGO  = '" + Alltrim(T_CUSENT->D1_TES) + "'" 
    cSql += "   AND D_E_L_E_T_ = ''"
    
	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_REDUCAO", .T., .T. )
    
    If T_REDUCAO->( EOF() )
       _REDUCAO := 0
    Else
       _REDUCAO := T_REDUCAO->F4_BSICMST       
    Endif

Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _REDUCAO } )

// Abre tela de variáveis do crédito adjudicado
Static Function TelaAdjudicado( xProduto, xCliente, xLoja, xUnitario, xTes )

   Local cSql      := ""
   Local lFecha    := .F.
   Local cNota	   := Space(10)
   Local cData	   := Space(10)
   Local nQuanti   := 0
   Local nTotalE   := 0
   Local nMVA 	   := 0
   Local nReducao  := 0
   Local nCustoE   := 0
   Local nAliquota := 0
   Local nProduto  := 0
   Local nIPI      := 0

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local cMemo3	 := ""

   Local oGet1
   Local oGet10
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5
   Local oGet6
   Local oGet7
   Local oGet8
   Local oGet9
   Local oMemo1
   Local oMemo2
   Local oMemo3

   Private oDlgA

   // Pesquisa a última nota fiscal de entrada
   If Select("T_ULTIMA") > 0
      T_ULTIMA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT TOP 1 ROUND( ( D1_TOTAL + D1_VALIPI ) / D1_QUANT, 2 ) BASE1, "
   cSql += "       D1_TES    , "
   cSql += "       D1_DOC    , "
   cSql += "       D1_EMISSAO, "
   cSql += "       D1_QUANT  , "
   cSql += "       D1_TOTAL  , "
   cSql += "       D1_VALIPI   "
   cSql += "  FROM " + RetSqlName("SD1")
   cSql += " WHERE D_E_L_E_T_ = '' "
   cSql += "   AND D1_PEDIDO <> '' "
   cSql += "   AND D1_TIPO    = 'N'" 
   cSql += "   AND D1_COD     = '" + Alltrim(xProduto) + "'"
   cSql += " ORDER BY D1_EMISSAO DESC "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ULTIMA", .T., .T. )

   If T_ULTIMA->( EOF() )
      cNota	    := Space(10)
      cData	    := Space(10)
      nQuanti   := 0
      nTotalE   := 0
      nMVA 	    := 0
      nReducao  := 0
      nCustoE   := 0
      nAliquota := 0
      nProduto  := 0
      nIPI      := 0
   Else
      cNota     := T_ULTIMA->D1_DOC
      cData     := Substr(T_ULTIMA->D1_EMISSAO,07,02) + "/" + Substr(T_ULTIMA->D1_EMISSAO,05,02) + "/" + Substr(T_ULTIMA->D1_EMISSAO,01,04)
      nQuanti   := T_ULTIMA->D1_QUANT
      nTotalE   := T_ULTIMA->D1_TOTAL + T_ULTIMA->D1_VALIPI
      nMVA      := 0
      nReducao  := 0
      nCustoE   := T_ULTIMA->BASE1
      nAliquota := 0
      nProduto  := T_ULTIMA->D1_TOTAL
      nIPI      := T_ULTIMA->D1_VALIPI
   Endif

   aRetDife := U_xAlqCalcST( xProduto, xCliente, xLoja, xUnitario, xTes )

   nMVA      := aRetDife[3]
   nAliquota := aRetDife[4]
   nReducao  := aRetDife[5]

   DEFINE MSDIALOG oDlgA TITLE "Variáveis Crédito Adjudicado" FROM C(177),C(180) TO C(413),C(628) PIXEL

   @ C(007),C(005) Say "NF Última Entrada" Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(007),C(102) Say "Data"              Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(025),C(005) Say "Total Produto"     Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(039),C(005) Say "Total IPI"         Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(052),C(005) Say "Total"             Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(052),C(093) Say "Qtd"               Size C(009),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(052),C(150) Say "C.Entrada"         Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(070),C(005) Say "M V A"             Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(070),C(093) Say "% de Redução"      Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgA
   @ C(070),C(171) Say "Alíquota Interna"  Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlgA

   @ C(018),C(005) GET oMemo1 Var cMemo1 MEMO When lFecha Size C(211),C(001) PIXEL OF oDlgA
   @ C(065),C(005) GET oMemo2 Var cMemo2 MEMO When lFecha Size C(211),C(001) PIXEL OF oDlgA
   @ C(094),C(005) GET oMemo3 Var cMemo3 MEMO When lFecha Size C(211),C(001) PIXEL OF oDlgA
   
   @ C(006),C(050) MsGet oGet6  Var cNota     When lFecha Size C(045),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA
   @ C(006),C(118) MsGet oGet7  Var cData     When lFecha Size C(045),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgA
   @ C(024),C(041) MsGet oGet8  Var nProduto  When lFecha Size C(045),C(009) COLOR CLR_BLACK Picture ("@E 9,999,999.99") PIXEL OF oDlgA
   @ C(038),C(041) MsGet oGet9  Var nIPI      When lFecha Size C(045),C(009) COLOR CLR_BLACK Picture ("@E 9,999,999.99") PIXEL OF oDlgA
   @ C(051),C(041) MsGet oGet10 Var nTotalE   When lFecha Size C(045),C(009) COLOR CLR_BLACK Picture ("@E 9,999,999.99") PIXEL OF oDlgA
   @ C(051),C(108) MsGet oGet1  Var nQuanti   When lFecha Size C(020),C(009) COLOR CLR_BLACK Picture ("@E 9,999.999")    PIXEL OF oDlgA
   @ C(051),C(171) MsGet oGet4  Var nCustoE   When lFecha Size C(045),C(009) COLOR CLR_BLACK Picture ("@E 9,999,999.99") PIXEL OF oDlgA
   @ C(079),C(005) MsGet oGet2  Var nMVA      When lFecha Size C(045),C(009) COLOR CLR_BLACK Picture ("@E 9,999,999.99") PIXEL OF oDlgA
   @ C(079),C(093) MsGet oGet3  Var nReducao  When lFecha Size C(025),C(009) COLOR CLR_BLACK Picture ("@E 999.99")       PIXEL OF oDlgA
   @ C(079),C(171) MsGet oGet5  Var nAliquota When lFecha Size C(025),C(009) COLOR CLR_BLACK Picture ("@E 999.99")       PIXEL OF oDlgA

   @ C(100),C(093) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgA ACTION( oDlgA:End() )

   ACTIVATE MSDIALOG oDlgA CENTERED 

Return(.T.)

// Abre tela de consulta de comissão
Static Function TelaComissao()

   Local lChumba := .F.

   Local cVend01  := Space(40)
   Local cVend02  := Space(40)
   Local cVend03  := Space(40)
   Local cVend04  := Space(40)
   Local cVend05  := Space(40)
      
   Local cPreco01 := SC6->C6_VALOR
   Local cPerc01  := SC6->C6_COMIS1
   Local cComis01 := (SC6->C6_VALOR * SC6->C6_COMIS1) / 100

   Local cPreco02 := SC6->C6_VALOR
   Local cPerc02  := SC6->C6_COMIS2
   Local cComis02 := (SC6->C6_VALOR * SC6->C6_COMIS2) / 100

   Local cPreco03 := SC6->C6_VALOR
   Local cPerc03  := SC6->C6_COMIS3
   Local cComis03 := (SC6->C6_VALOR * SC6->C6_COMIS3) / 100

   Local cPreco04 := SC6->C6_VALOR
   Local cPerc04  := SC6->C6_COMIS4
   Local cComis04 := (SC6->C6_VALOR * SC6->C6_COMIS4) / 100

   Local cPreco05 := SC6->C6_VALOR
   Local cPerc05  := SC6->C6_COMIS5
   Local cComis05 := (SC6->C6_VALOR * SC6->C6_COMIS5) / 100
   Local cTcomis  := cComis01 + cComis02 + cComis03 + cComis04 + cComis05

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
   Local oGet16
   Local oGet17
   Local oGet18
   Local oGet19
   Local oGet20
   Local oGet21

   Private oDlgC

   // Pesquisa os dados do Pedido de Venda
   If Select("T_COMISSAO") > 0
      T_COMISSAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC5.C5_VEND1  ,"
   cSql += "       SC5.C5_VEND2  ,"
   cSql += "       SC5.C5_VEND3  ,"
   cSql += "       SC5.C5_VEND4  ,"
   cSql += "       SC5.C5_VEND5   "            
   cSql += "  FROM " + RetSqlName("SC5") + " SC5 "
   cSql += " WHERE SC5.C5_FILIAL  = '" + Alltrim(SC6->C6_FILIAL) + "'"
   cSql += "   AND SC5.C5_NUM     = '" + Alltrim(SC6->C6_NUM)    + "'"
   cSql += "   AND SC5.D_E_L_E_T_ = ''"            

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMISSAO", .T., .T. )

   DbSelectArea( "SA3" )
   DbSetOrder(1)
   If DbSeek( xFilial("SA3") + T_COMISSAO->C5_VEND1)
      cVend01 := SA3->A3_NOME
   Endif
      
   DbSelectArea( "SA3" )
   DbSetOrder(1)
   If DbSeek( xFilial("SA3") + T_COMISSAO->C5_VEND2)
      cVend02 := SA3->A3_NOME
   Endif

   DbSelectArea( "SA3" )
   DbSetOrder(1)
   If DbSeek( xFilial("SA3") + T_COMISSAO->C5_VEND3)
      cVend03 := SA3->A3_NOME
   Endif

   DbSelectArea( "SA3" )
   DbSetOrder(1)
   If DbSeek( xFilial("SA3") + T_COMISSAO->C5_VEND4)
      cVend04 := SA3->A3_NOME
   Endif

   DbSelectArea( "SA3" )
   DbSetOrder(1)
   If DbSeek( xFilial("SA3") + T_COMISSAO->C5_VEND5)
      cVend05 := SA3->A3_NOME
   Endif

   DEFINE MSDIALOG oDlgC TITLE "Consulta Comissão" FROM C(178),C(181) TO C(382),C(696) PIXEL

   @ C(005),C(005) Say "Vendedores"     Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(005),C(119) Say "Prc. Venda"     Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(005),C(162) Say "% Com."         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(005),C(191) Say "Tot. Comissão"  Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(077),C(150) Say "Total Comissão" Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   
   @ C(015),C(005) MsGet oGet1  Var cVend01                          When lChumba Size C(108),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC
   @ C(015),C(119) MsGet oGet2  Var IIF(Empty(cVend01), 0, cPreco01) When lChumba Size C(036),C(009) COLOR CLR_BLACK Picture "@E 9,999,999.99" PIXEL OF oDlgC
   @ C(015),C(162) MsGet oGet3  Var IIF(Empty(cVend01), 0, cPerc01)  When lChumba Size C(023),C(009) COLOR CLR_BLACK Picture "@E 999.99"       PIXEL OF oDlgC
   @ C(015),C(191) MsGet oGet4  Var IIF(Empty(cVend01), 0, cComis01) When lChumba Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9,999,999.99" PIXEL OF oDlgC

   @ C(027),C(005) MsGet oGet5  Var cVend02                          When lChumba Size C(108),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC
   @ C(027),C(119) MsGet oGet6  Var IIF(Empty(cVend02), 0, cPreco02) When lChumba Size C(036),C(009) COLOR CLR_BLACK Picture "@E 9,999,999.99" PIXEL OF oDlgC
   @ C(027),C(162) MsGet oGet7  Var IIF(Empty(cVend02), 0, cPerc02)  When lChumba Size C(023),C(009) COLOR CLR_BLACK Picture "@E 999.99"       PIXEL OF oDlgC
   @ C(027),C(191) MsGet oGet8  Var IIF(Empty(cVend02), 0, cComis02) When lChumba Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9,999,999.99" PIXEL OF oDlgC

   @ C(039),C(005) MsGet oGet9  Var cVend03                          When lChumba Size C(108),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC
   @ C(039),C(119) MsGet oGet10 Var IIF(Empty(cVend03), 0, cPreco03) When lChumba Size C(036),C(009) COLOR CLR_BLACK Picture "@E 9,999,999.99" PIXEL OF oDlgC
   @ C(039),C(162) MsGet oGet11 Var IIF(Empty(cVend03), 0, cPerc03)  When lChumba Size C(023),C(009) COLOR CLR_BLACK Picture "@E 999.99"       PIXEL OF oDlgC
   @ C(039),C(191) MsGet oGet12 Var IIF(Empty(cVend03), 0, cComis03) When lChumba Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9,999,999.99" PIXEL OF oDlgC

   @ C(051),C(005) MsGet oGet13 Var cVend04                          When lChumba Size C(108),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC
   @ C(051),C(119) MsGet oGet14 Var IIF(Empty(cVend04), 0, cPreco04) When lChumba Size C(036),C(009) COLOR CLR_BLACK Picture "@E 9,999,999.99" PIXEL OF oDlgC
   @ C(051),C(162) MsGet oGet15 Var IIF(Empty(cVend04), 0, cPerc04)  When lChumba Size C(023),C(009) COLOR CLR_BLACK Picture "@E 999.99"       PIXEL OF oDlgC
   @ C(051),C(191) MsGet oGet16 Var IIF(Empty(cVend04), 0, cComis04) When lChumba Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9,999,999.99" PIXEL OF oDlgC

   @ C(063),C(005) MsGet oGet17 Var cVend05                          When lChumba Size C(108),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC
   @ C(063),C(119) MsGet oGet18 Var IIF(Empty(cVend05), 0, cPreco05) When lChumba Size C(036),C(009) COLOR CLR_BLACK Picture "@E 9,999,999.99" PIXEL OF oDlgC
   @ C(063),C(162) MsGet oGet19 Var IIF(Empty(cVend05), 0, cPerc05)  When lChumba Size C(023),C(009) COLOR CLR_BLACK Picture "@E 999.99"       PIXEL OF oDlgC
   @ C(063),C(191) MsGet oGet20 Var IIF(Empty(cVend05), 0, cComis05) When lChumba Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9,999,999.99" PIXEL OF oDlgC

   @ C(076),C(191) MsGet oGet21 Var cTcomis  When lChumba Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9,999,999.99" PIXEL OF oDlgC

   @ C(088),C(111) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgC ACTION( oDlgC:End() )

   ACTIVATE MSDIALOG oDlgC CENTERED 

Return(.T.)

// Função que abre a tela de verificação de variáveis do cálculo do DIFAL
Static Function AbreDIFAL(_EmpAnt, _Filial, _Pedido)

   U_AUTOM227(_EmpAnt, _Filial, _Pedido)
   
Return(.T.)

// Função que pesquisa as variáveis do pedido selecionado
User Function xCalDifal(D_Filial, D_Produto, D_Cliente, D_Loja, D_Unitarioi, D_TES, D_FRETE )

   Local cSql       := ""
   Local nContar    := 0
   Local nRet       := 0
   Local nTotal     := 0
   Local nTConf     := 0
   Local cItem      := ""
   Local cProd      := ""
   Local cTes       := ""
   Local cOri       := ""
   lOCAL cNcm       := ""
   Local cCFOP      := ""
   Local _ALQINTEST := 0
   Local _ALQINT    := 0
   Local MV_ESTICM  := SuperGetMV("MV_ESTICM")
   Local cEst       := ""
   Local cTip       := ""
   Local cGrp       := ""
   Local cSol       := ""
   Local cIcm       := ""
   Local cGtp       := ""
   Local vPedido    := 0
   Local vFrete     := 0

   Local _ICMBASE := 0
   Local _ALIBASE := 0
   Local _ICMRETI := 0
   Local _VALBASE := 0
   Local _ALIRETI := 0
   Local _VALRETI := 0
   Local _CUSTENT := 0
   Local _MVA     := 0
   Local _ALIQINT := 0
   Local _TES     := ""
   Local _REDUCAO := 0
   
   // Pesquisa dados do Cliente
   If Select("T_CLIENTE") > 0
      T_CLIENTE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SA1.A1_NOME   ,"
   cSql += "       SA1.A1_EST    ,"
   cSql += "       SA1.A1_TIPO   ,"
   cSql += "       SA1.A1_GRPTRIB "
   cSql += "  FROM SA1010 SA1     "
   cSql += " WHERE SA1.A1_COD     = '" + Alltrim(D_CLIENTE) + "'"
   cSql += "   AND SA1.A1_LOJA    = '" + Alltrim(D_LOJA)    + "'"
   cSql += "   AND SA1.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

   If T_CLIENTE->( EOF() )
	  Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _REDUCAO } )
      Return(.T.)
   Endif
   
   // Estado do Cliente (UF)
   cEstado  := T_CLIENTE->A1_EST

   // Tipo de Cliente
   Do Case
      Case T_CLIENTE->A1_TIPO == "F"
           cTipoCli := "F"
      Case T_CLIENTE->A1_TIPO == "L"
           cTipoCli := "L"
      Case T_CLIENTE->A1_TIPO == "R"
           cTipoCli := "R"
      Case T_CLIENTE->A1_TIPO == "S"
           cTipoCli := "S"
      Case T_CLIENTE->A1_TIPO == "X"
           cTipoCli := "X"
      Otherwise     
           cTipoCli := ""
   EndCase        

   // Grupo Tributário do Cliente
   cGrpTrib := T_CLIENTE->A1_GRPTRIB

   // Captura o valor do Frete
   vFrete := D_FRETE

   // Calcula o ICM DIFAL para display
   cEst := cEstado
   cTip := cTipoCli
   cGrp := cGrpTrib
   cSol := ""
   cIcm := ""
   cGtp := ""

   // Rateia o Frete
   If D_Frete > 0
      vFrete := Round(D_Frete * Round((D_Frete / D_Unitario) * 100,2) / 100,2)
   Endif

   // Verifica se o Estado da Empresa Logada é diferente do estado do cliente
   If Alltrim(cEst) == Alltrim(SM0->M0_ESTENT)
	  Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _REDUCAO } )
   Endif
 
   // Verifica se cliente é F = Consumidor Final
   If Alltrim(cTip) <> "F"
	  Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _REDUCAO } )
   Endif

   // Verifica se IE do Cliente está Ativa
   If Alltrim(cGrp) <> "002"
	  Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _REDUCAO } )
   Endif

   cTes  := D_TES
   cSol  := Posicione("SF4", 1, xFilial("SF4") + D_TES, "F4_INCSOL")
   cIcm  := Posicione("SF4", 1, xFilial("SF4") + D_TES, "F4_ICM")
   cCFOP := Posicione("SF4", 1, xFilial("SF4") + D_TES, "F4_CF")

   If cEst <> "CE"
      If Alltrim(cCfop) == "5102" .Or. Alltrim(cCfop) == "6102" .Or. Alltrim(cCfop) == ""
  	     Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _REDUCAO } )
      Endif   
   Endif

   cPro := D_Produto
   cGtp := Posicione("SB1", 1, xFilial("SB1") + D_PRODUTO, "B1_GRTRIB")
   cOri := Posicione("SB1", 1, xFilial("SB1") + D_PRODUTO, "B1_ORIGEM")
   cNcm := Posicione("SB1", 1, xFilial("SB1") + D_PRODUTO, "B1_POSIPI")

   // Verifica o ICM Solidário
   If !(cSol <> "S") .And. !(cIcm <> "S") .And. !(AllTrim( cGtp ) == "017")

      // Carrega a alíquota interestadual pela origem do produto
      Do Case
         Case cOri = "0"
   	          If cEst $ "MG/PR/RJ/SC/SP"
			     _ALQINTEST := 12
                      
                 If cEst $ "RJ"			          
			        _ALQINTEST := 13
			     Endif   
			          			          
		      ElseIf cEst $ "AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RO/RR/SE/TO"
			     _ALQINTEST := 7
			  Endif

         Case cOri = "1"
		      _ALQINTEST := 4
         Case cOri = "2"
              _ALQINTEST := 4
         Case cOri = "3"
              _ALQINTEST := 4
         Case cOri = "4"
     	      If cEst $ "MG/PR/RJ/SC/SP"
		         _ALQINTEST := 12
		      ElseIf cEst $ "AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RO/RR/SE/TO"
		         _ALQINTEST := 7
			  Endif
         Case cOri = "5"
  		      If cEst $ "MG/PR/RJ/SC/SP"
			     _ALQINTEST := 12
			  ElseIf cEst $ "AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RO/RR/SE/TO"
			     _ALQINTEST := 7
			  Endif
         Case cOri = "6"
  		      If cEst $ "MG/PR/RJ/SC/SP"
			     _ALQINTEST := 12
			  ElseIf cEst $ "AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RO/RR/SE/TO"
			     _ALQINTEST := 7
			  Endif
         Case cOri = "7"
  		      If cEst $ "MG/PR/RJ/SC/SP"
			     _ALQINTEST := 12
			  ElseIf cEst $ "AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RO/RR/SE/TO"
			     _ALQINTEST := 7
			  Endif
	  EndCase        
		
      If cEst $ "MG/PR/SP"
	  	 _ALIQINT := 18
      ElseIf cEst $ "RJ"

	     _ALIQINT := 19

         If Substr(cNcm,01,04) == "8471"
            _ALIQINT := 13
    	 Endif                               

      ElseIf cEst $ "AC/AL/AM/AP/BA/CE/DF/ES/GO/MA/MT/MS/PA/PB/PE/PI/RN/RS/RO/RR/SC/SE/TO"
	   	  _ALIQINT := 17
	  EndIf

      // Verifica se existe execeção fiscal
   	  If (Select( "T_DETALHES" ) != 0 )
	     T_DETALHES->( DbCloseArea() )
	  EndIf

      cSql := ""
      cSql := "SELECT F7_ALIQDST,"
      cSql += "       F7_MARGEM  "
      cSql += "  FROM " + RetSqlName("SF7")
      cSql += " WHERE F7_GRTRIB  = '" + Alltrim(cGtp)      + "'"
      cSql += "   AND F7_EST     = '" + Alltrim(cEst)      + "'"
      cSql += "   AND F7_TIPOCLI = '" + Substr(cTip,01,01) + "'"
      cSql += "   AND F7_GRPCLI  = '" + Substr(cGrp,01,03) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"
                   
  	  cSql := ChangeQuery( cSql )
 	  dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_DETALHES",.T.,.T.)

      If T_DETALHES->( EOF() )
      Else

         _MVA := T_DETALHES->F7_MARGEM

         If T_DETALHES->F7_ALIQDST == 0
         Else
            If cEst == "RJ"
               _ALI7QINT := T_DETALHES->F7_ALIQDST + 1
            Else
               _ALIQINT := T_DETALHES->F7_ALIQDST
            Endif   
         Endif
      Endif

	  If cEst == "RJ"
         If Substr(cNcm,01,04) == "8471"
            _ALIQINT := 13
  		 Endif                               
   	  Endif

      // Pesquisa o custo de entrada
   	  If Select("T_CUSENT") > 0
	   	 T_CUSENT->( dbCloseArea() )
	  EndIf

 	  cSql := ""
 	  cSql := "SELECT TOP 1 ROUND( ( D1_TOTAL + D1_VALIPI ) / D1_QUANT, 2 ) BASE1, D1_TES "
	  cSql += " FROM "+ RetSqlName("SD1")
	  cSql += " WHERE " 
	  cSql += " D_E_L_E_T_ = '' AND " 
	  cSql += " D1_PEDIDO <> '' AND " 
	  cSql += " D1_TIPO = 'N' AND " 
	  cSql += " D1_COD = '" + cProd + "' " 
	  cSql += " ORDER BY D1_EMISSAO DESC" 
	
	  cSql := ChangeQuery( cSql )
	  dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CUSENT", .T., .T. )
 
	  If T_CUSENT->( EOF() )
		 _CUSTENT := 0
	  Else	
		 _CUSTENT := T_CUSENT->BASE1
 	  Endif

      // Aplica o cálculo e acumula (item)
 	  _VALRETI := ( D_unitario * ( _ALIQINT / 100 ) ) - ( D_unitario * ( _ALQINTEST / 100 ) )
      _ALIQINT := _ALIQINT
      _REDUCAO := _ALQINTEST	  

      // Se for estado do CE, zera o DIFAL
      If Alltrim(cEst) == "CE"
         nRet := 0
      Endif

   Endif

Return( { _VALRETI, _CUSTENT, _MVA, _ALIQINT, _REDUCAO } )