#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM321.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho  (  ) Ponto de Entrada                    *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 17/11/2015                                                          *
// Objetivo..: Programa que pesquisa pedidos de Venda Rejetados no Crédito.        *
//**********************************************************************************

User Function AUTOM321()

   Local lChumba   := .F.
   Local cMemo1	   := ""
   Local oMemo1

   Private aFilial   := () // {"01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos", "AA - Atech", "CC - Curitiba"}
   Private aEmpresa  := () // {"01 - Automatech", "02 - TI Automação", "03 - Atech"}
   Private cComboBx1
   Private cComboBx2
   Private dInicial  := Ctod("  /  /    ")
   Private dFinal    := Ctod("  /  /    ")
   Private oGet1
   Private oGet2

   Private aBrowse   := {}

   Private oDlg                       

   U_AUTOM628("AUTOM321")

   aEmpresa := U_AUTOM539(1, "", oDlg) 
   aFilial  := U_AUTOM539(2, cEmpAnt, oDlg)
   
   If Alltrim(Upper(cUserName)) <> "ADMINISTRADOR" .AND. Alltrim(Upper(cUserName)) <> "FATURAMENTO"
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Usuário sem permissão para executar esta rotina.")
      Return(.T.)
   Endif   

   DEFINE MSDIALOG oDlg TITLE "Relação de Pedidos Rejetados no Crédito" FROM C(178),C(181) TO C(586),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(003) GET oMemo1 Var cMemo1 MEMO Size C(384),C(001) PIXEL OF oDlg

   @ C(035),C(005) Say "Empresa"                                       Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(082) Say "Filial"                                        Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(147) Say "Data Inicial"                                  Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(198) Say "Data Final"                                    Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(058),C(005) Say "Relação de Pedidos Rejeitados conforme filtro" Size C(114),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(044),C(005) ComboBox cComboBx2 Items aEmpresa Size C(072),C(010) PIXEL OF oDlg ON CHANGE AlteraCombo()
   @ C(044),C(082) ComboBox cComboBx1 Items aFilial  Size C(059),C(010) PIXEL OF oDlg
   @ C(044),C(147) MsGet    oGet1     Var   dInicial Size C(045),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(044),C(198) MsGet    oGet2     Var   dFinal   Size C(045),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(042),C(249) Button "Pesquisar"        Size C(037),C(012) PIXEL OF oDlg ACTION( VerStatus15() )
   @ C(188),C(005) Button "Status"           Size C(037),C(012) PIXEL OF oDlg ACTION( MostraLog( cComboBx1, aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,07] ) )
   @ C(188),C(048) Button "Eliminar Resíduo" Size C(054),C(012) PIXEL OF oDlg ACTION( EliminaResiduo(cComboBx1, aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,07]) )
   @ C(188),C(351) Button "Voltar"           Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aBrowse, { "", "", "", "", "", "", "", "", "", "", "", "" } )

   oBrowse := TCBrowse():New( 085 , 005, 490, 150,,{'Nº P.Venda'               ,; // 01 - Nº do pedidos de venda
                                                    'Dta Pedido'               ,; // 02 - Data de Incusão do Pedido de Venda
                                                    'Dta Rejeição'             ,; // 03 - Data da Rejeição do Crédito
                                                    '1ª Dif. Dta'              ,; // 04 - Diferença entre data Rejeição para data do pedido
                                                    'Dta Atual'                ,; // 05 - Data Atual
                                                    '2ª Dif. Dta'              ,; // 06 - Diferença entre data Rejeição para data atual
                                                    'Item'                     ,; // 07 - Item do Pedido de Venda
                                                    'Produto'                  ,; // 08 - Código do Produto do Pedido de Venda
                                                    'Descrição dos Produtos'   ,; // 09 - Descrição do Produto
                                                    'Cliente'                  ,; // 10 - Código do Cliente
                                                    'Loja'                     ,; // 11 - Código da Loja do Cliente
                                                    'Descrição dos Clientes' } ,; // 12 - Descrição do Cliente
                                                   {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07],;
                         aBrowse[oBrowse:nAt,08],;
                         aBrowse[oBrowse:nAt,09],;
                         aBrowse[oBrowse:nAt,10],;
                         aBrowse[oBrowse:nAt,11],;                                                                                                                             
                         aBrowse[oBrowse:nAt,12]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

Static Function AlteraCombo

   aFilial := U_AUTOM539(2, Substr(cComboBx2,01,02) )
   @ C(044),C(082) ComboBox cComboBx1 Items aFilial  Size C(059),C(010) PIXEL OF oDlg

Return

// Função que pesquisa os pedidos conforme filtro informado
Static Function VerStatus15()

   If Empty(dFinal)
      MsgAlert("Data final de rejeição de análise de crédito para pesquisa não informada.")
      Return(.T.)      
   Endif

   If Select("T_REJEITADOS") <>  0
      T_REJEITADOS->(DbCloseArea())
   EndIf

   aBrowse    := {}

   MsgRun("Aguarde! Pesquisando Pedidos Rejetados no Crédito ...", "Pedidos Rejeitados no Crédito",{|| DetalheVerStatus15() })

Return(.T.)

// Função que pesquisa os pedidos conforme filtro informado
Static Function DetalheVerStatus15()

   Local cSql := ""
  
   If Empty(dInicial)
      MsgAlert("Data inicial de rejeição de análise de crédito para pesquisa não informada.")
      Return(.T.)      
   Endif
   
   cSql := ""
   cSql := "SELECT ZZ0.ZZ0_FILIAL,"                 + CHR(13)
   cSql += "       ZZ0.ZZ0_PEDIDO,"                 + CHR(13)
   cSql += "       ZZ0.ZZ0_ITEMPV,"                 + CHR(13)
   cSql += "       SC6.C6_PRODUTO,"                 + CHR(13)
   cSql += "       SC6.C6_DESCRI ,"                 + CHR(13)
   cSql += "       ZZ0.ZZ0_DATA  ,"                 + CHR(13)
   cSql += "       SC5.C5_CLIENTE,"                 + CHR(13)
   cSql += "       SC5.C5_LOJACLI,"                 + CHR(13)
   cSql += "       SC5.C5_EMISSAO,"                 + CHR(13)
   cSql += "       SA1.A1_NOME   ,"                 + CHR(13)
   cSql += "       SC6.C6_BLQ    ,"                 + CHR(13)
   cSql += "       SC6.C6_NOTA    "                 + CHR(13)
   cSql += "  FROM " + RetSqlName("ZZ0") + " ZZ0, " + CHR(13)

   
//   cSql += "       " + RetSqlName("SC6") + " SC6, " + CHR(13)
//   cSql += "       " + RetSqlName("SC5") + " SC5, " + CHR(13)

   cSql += "       SC6" + Alltrim(Substr(cComboBx2,01,02)) + "0 SC6, " + CHR(13)
   cSql += "       SC5" + Alltrim(Substr(cComboBx2,01,02)) + "0 SC5, " + CHR(13)

   cSql += "       " + RetSqlName("SA1") + " SA1  " + CHR(13)
   cSql += " WHERE ZZ0.ZZ0_STATUS = '15'"           + CHR(13)
   cSql += "   AND ZZ0.ZZ0_FILIAL = '" + Substr(cComboBx1,01,02) + "'" + CHR(13)
   cSql += "   AND ZZ0.ZZ0_DATA  >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103)" + CHR(13)
   cSql += "   AND ZZ0.ZZ0_DATA  <= CONVERT(DATETIME,'" + Dtoc(dFinal)   + "', 103)" + CHR(13)
   cSql += "   AND ZZ0.D_E_L_E_T_ = ''"                                              + CHR(13)
   cSql += "   AND ZZ0.R_E_C_N_O_ = (SELECT MAX(MAIOR.R_E_C_N_O_)"                   + CHR(13)
   cSql += "                           FROM " + RetSqlName("ZZ0") + " MAIOR "        + CHR(13)
   cSql += "					      WHERE MAIOR.ZZ0_FILIAL = ZZ0.ZZ0_FILIAL"       + CHR(13)
   cSql += "						    AND MAIOR.ZZ0_PEDIDO = ZZ0.ZZ0_PEDIDO"       + CHR(13)
   cSql += "						    AND MAIOR.ZZ0_ITEMPV = ZZ0.ZZ0_ITEMPV"       + CHR(13)
   cSql += "							AND MAIOR.D_E_L_E_T_ = '')"                  + CHR(13)
   cSql += "   AND SC6.C6_FILIAL  = ZZ0.ZZ0_FILIAL" + CHR(13)
   cSql += "   AND SC6.C6_NUM     = ZZ0.ZZ0_PEDIDO" + CHR(13)
   cSql += "   AND SC6.C6_ITEM    = ZZ0.ZZ0_ITEMPV" + CHR(13)
   cSql += "   AND SC6.C6_BLQ     = ''"             + CHR(13)
   cSql += "   AND SC6.C6_NOTA    = ''"             + CHR(13)
   cSql += "   AND SC6.D_E_L_E_T_ = ''"             + CHR(13)
   cSql += "   AND SC5.C5_FILIAL  = SC6.C6_FILIAL"  + CHR(13)
   cSql += "   AND SC5.C5_NUM     = SC6.C6_NUM   "  + CHR(13)
   cSql += "   AND SC5.D_E_L_E_T_ = ''           "  + CHR(13)
   cSql += "   AND SA1.A1_COD     = SC5.C5_CLIENTE" + CHR(13)
   cSql += "   AND SA1.A1_LOJA    = SC5.C5_LOJACLI" + CHR(13)
   cSql += "   AND SA1.D_E_L_E_T_ = ''            " + CHR(13)
   cSql += " ORDER BY ZZ0.ZZ0_DATA"

   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_REJEITADOS",.T.,.T.)
   
   T_REJEITADOS->( DbGoTop() )
   
   WHILE !T_REJEITADOS->( EOF() )

      xx_Pedido      := T_REJEITADOS->ZZ0_PEDIDO
      xx_DataPedido  := Substr(T_REJEITADOS->C5_EMISSAO,07,02) + "/" + Substr(T_REJEITADOS->C5_EMISSAO,05,02) + "/" + Substr(T_REJEITADOS->C5_EMISSAO,01,04)
      xx_Rejeitado   := Substr(T_REJEITADOS->ZZ0_DATA  ,07,02) + "/" + Substr(T_REJEITADOS->ZZ0_DATA  ,05,02) + "/" + Substr(T_REJEITADOS->ZZ0_DATA  ,01,04)
      xx_DifUm       := Str(CTOD(SUBSTR(T_REJEITADOS->ZZ0_DATA  ,07,02) + "/" + SUBSTR(T_REJEITADOS->ZZ0_DATA  ,05,02) + "/" + SUBSTR(T_REJEITADOS->ZZ0_DATA  ,01,04)) - ;
                            CTOD(SUBSTR(T_REJEITADOS->C5_EMISSAO,07,02) + "/" + SUBSTR(T_REJEITADOS->C5_EMISSAO,05,02) + "/" + SUBSTR(T_REJEITADOS->C5_EMISSAO,01,04)),5)
      xx_DataAtual   := Dtoc(Date())
      xx_DifDois     := Str(DATE() - ;
                            CTOD(SUBSTR(T_REJEITADOS->ZZ0_DATA,07,02) + "/" + SUBSTR(T_REJEITADOS->ZZ0_DATA,05,02) + "/" + SUBSTR(T_REJEITADOS->ZZ0_DATA,01,04)),5)
      xx_ItemPedido  := T_REJEITADOS->ZZ0_ITEMPV
      xx_Produto     := T_REJEITADOS->C6_PRODUTO
      xx_NomeProduto := T_REJEITADOS->C6_DESCRI 
      xx_Cliente     := T_REJEITADOS->C5_CLIENTE
      xx_Loja        := T_REJEITADOS->C5_LOJACLI
      xx_NomeCliente := T_REJEITADOS->A1_NOME   

      aAdd( aBrowse, { xx_Pedido      ,;
                       xx_DataPedido  ,;
                       xx_Rejeitado   ,;
                       xx_DifUm       ,;
                       xx_DataAtual   ,;
                       xx_DifDois     ,;
                       xx_ItemPedido  ,;
                       xx_Produto     ,;
                       xx_NomeProduto ,;
                       xx_Cliente     ,;
                       xx_Loja        ,;
                       xx_NomeCliente })

      T_REJEITADOS->( DbSkip() )
      
   ENDDO
      
   oBrowse:SetArray(aBrowse) 
   
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07],;
                         aBrowse[oBrowse:nAt,08],;
                         aBrowse[oBrowse:nAt,09],;
                         aBrowse[oBrowse:nAt,10],;
                         aBrowse[oBrowse:nAt,11],;                                                                                                                             
                         aBrowse[oBrowse:nAt,12]}}

Return(.T.)

// Tela para exibir a sequencia de logs para o item selecionado
Static Function MostraLog( _Filial, _Pedido, _Item )
	
	Local _cTitle    := "Log de Status - PV: " + _Pedido +" Item: " + _Item
	Local cQuery     := ""
	Local aStru      := {}
	Local aMlog      := {}
	Local oMlog
    Local xxx_Filial := ""
	
    Do Case
       Case Substr(_Filial,01,02) == "CC"   
            xxx_Filial := "01"
       Case Substr(_Filial,01,02) == "AA"   
            xxx_Filial := "01"
       oTherwise
            xxx_Filial := Substr(_Filial,01,02)
    EndCase

	If Select("T_ZZ0") > 0
		T_ZZ0->( dbCloseArea() )
	EndIf

	cQuery := " SELECT * "
	cQuery += "   FROM "+ RetSqlName("ZZ0")
	cQuery += "  WHERE ZZ0_PEDIDO = '" + Alltrim(_Pedido)    + "'"
	cQuery += "    AND ZZ0_ITEMPV = '" + Alltrim(_Item)      + "'"
	cQuery += "    AND ZZ0_FILIAL = '" + Alltrim(xxx_Filial) + "'"
	cQuery += "    AND D_E_L_E_T_ = '' "
	cQuery += "  ORDER BY ZZ0_DATA, ZZ0_HORA "
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"T_ZZ0",.T.,.T.)
	
	// Formatar os campos para uso
	aStru := T_ZZ0->( dbStruct() )
	aEval( aStru, { |e| If( e[ 2 ] != "C" .And. T_ZZ0->( FieldPos( Alltrim( e[ 1 ] ) ) ) > 0, TCSetField( "T_ZZ0", e[ 1 ], e[ 2 ],e [ 3 ], e[ 4 ] ), Nil ) } )

	T_ZZ0->( dbGoTop() )

    // Vetor com elementos do Browse
	While !T_ZZ0->( Eof() )
		aAdd( aMlog, { Padr( Iif( T_ZZ0->ZZ0_STATUS <> '  ', T_ZZ0->ZZ0_STATUS+"-"+ Tabela( "Z0", T_ZZ0->ZZ0_STATUS ), "SEM STATUS" ),60 ),;
					   PadR( T_ZZ0->ZZ0_USER+"-"+ Upper( UsrRetName( T_ZZ0->ZZ0_USER ) ), 30 ),;
					   PadR( DtoC( StoD( T_ZZ0->ZZ0_DATA ) ), 10 ),;
					   PadR( T_ZZ0->ZZ0_HORA, 10 ),;
					   Padr( T_ZZ0->ZZ0_ORIGEM, 20 ) } )
		T_ZZ0->( dbSkip() )
	End
       
	T_ZZ0->( dbCloseArea() )

	If Len( aMlog ) > 0

		DEFINE DIALOG oDlg2 TITLE _cTitle FROM 180,180 TO 500,800 PIXEL
		                 
		// Cria Browse
		oMlog := TCBrowse():New( 01, 01, 310, 156,, {PadR('Status',60),PadR('Usuário',30),PadR('Data',10),PadR('Hora',10),PadR('Origem',25) },{20,50,50,50},oDlg2,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
	
		// Seta vetor para a browse
		oMlog:SetArray(aMlog) 
	
		// Monta a linha a ser exibida no Browse
		oMlog:bLine := {||{ aMlog[ oMlog:nAt, 01 ], aMlog[ oMlog:nAt, 02 ], aMlog[ oMlog:nAT, 03 ], aMlog[ oMlog:nAT, 04 ], aMlog[ oMlog:nAT, 05 ] } }
	
		// Evento de clique no cabeçalho da browse
		oMlog:bHeaderClick := {|| Nil } 
	
		// Evento de duplo click na celula
		oMlog:bLDblClick   := {|| Nil }
	
		ACTIVATE DIALOG oDlg2 CENTERED 

	Else                
	
		MsgAlert( "Nenhum log registrado para o PV: " + Alltrim(_Pedido) + " Item: " + Alltrim(_Item) )

	EndIf

Return(.T.)

// Função que elimina o resíduo do pedido selecionado
Static Function EliminaResidu( _Filial, _Pedido, _Item )

   // Posiciona no cabeçalho do pedido de venda   
   dbSelectArea("SC5")
   dbSetOrder(1)
   If dbSeek( xFilial("SC5") + _Pedido )
      ma410resid("SC5", SC5->(RECNO()), 2)
      VerStatus15()
   Else
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Registro do cabeçalho do pedido de venda selecionado não localizado." + chr(13) + chr(10) + "Operação não será realizada.")
      Return(.T.)
   Endif

Return(.T.)