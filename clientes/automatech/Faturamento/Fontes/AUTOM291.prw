#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM291.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 22/05/2015                                                          ##
// Objetivo..: Programa disparado pela tela de consulta padrão de produtos que tem ##
//             por objetivo de mostrar o saldo consolidado do produto selecionado. ##
// Parâmetros: Código e Dscrição do Produto a ser pesquisado                       ##
// ##################################################################################

User Function AUTOM291(kProduto, kDescricao)
                                 
   Local lChumba :=.F.
   Local cMemo1	 := ""
   Local oMemo1

   Private kEspaco := 40

   Private kSAtual01 := 0
   Private kPedido01 := 0
   Private kSalped01 := 0
  
   Private kSAtual02 := 0
   Private kPedido02 := 0
   Private kSalped02 := 0
  
   Private cProduto := Alltrim(kProduto) + " - " + Alltrim(kDescricao)
   Private oGet1

   Private aArmazem  := {}    
   Private cComboBx1
 
   Private oDlg

   Private akBrowse := {}
   Private okBrowse

   // ##############################
   // Carrega o combo de armazens ##
   // ##############################
   If Select("T_ARMAZEM") > 0
      T_ARMAZEM->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT NNR_CODIGO,"
   cSql += "       NNR_DESCRI "
   cSql += "  FROM " + RetSqlName("NNR")
   cSql += " WHERE NNR_FILIAL = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ARMAZEM", .T., .T. )

   T_ARMAZEM->( DbGoTop() )

   aArmazem := {}

   aAdd( aArmazem, "## - Todos Armazens" )   

   WHILE !T_ARMAZEM->( EOF() )
      aAdd( aArmazem, T_ARMAZEM->NNR_CODIGO + " - " + Alltrim(T_ARMAZEM->NNR_DESCRI) )
      T_ARMAZEM->( DbSkip() )
   ENDDO

   // #########################################################################################
   // Envia para a função que realiza a pesquisa consolidada do produto passado no parâmetro ##
   // #########################################################################################
   PsqSldConsolidado(0, kProduto)

   If Len(akBrowse) == 0
      akBrowse := {}
      aAdd( akBrowse, { "", "", "" , "" , "", "" })
      aAdd( akBrowse, { "", "Total Geral", 0 , 0 , 0, "" })   
   Endif   

   DEFINE MSDIALOG oDlg TITLE "Saldo Consolidado de Produto" FROM C(178),C(181) TO C(608),C(942) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(126),C(022) PIXEL NOBORDER OF oDlg

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(373),C(001) PIXEL OF oDlg

   @ C(032),C(005) Say "Saldo consolidado do produto" Size C(072),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(032),C(249) Say "Armazém" Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(041),C(005) MsGet    oGet1     Var   cProduto Size C(240),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(041),C(249) ComboBox cComboBx1 Items aArmazem Size C(086),C(010)                              PIXEL OF oDlg

   @ C(038),C(338) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( PsqSldConsolidado(1, kProduto) )
   @ C(199),C(338) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   okBrowse := TCBrowse():New( 070 , 006, 474, 180,,{"Empresa          ", "Filiais          ", "Qtd Disponível", "Qtd P.Venda", "Qtd Ent.Prevista", "Data Entrega"},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oKBrowse:SetArray(aKBrowse) 

   okBrowse:bLine := {||{akBrowse[okBrowse:nAt,01],;
                         akBrowse[okBrowse:nAt,02],;   
                         akBrowse[okBrowse:nAt,03],;   
                         akBrowse[okBrowse:nAt,04],;   
                         akBrowse[okBrowse:nAt,05],;   
                         akBrowse[okBrowse:nAt,06]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ########################################################################
// Função que pesquisa os saldos do produto em todas as Empresas/Filiais ##
// ########################################################################
Static Function PsqSldConsolidado(kJanela, kProduto)

   Local cSql     := ""  
   Local nEmpresa := 0
   Local nFilial  := 0
   Local cArmazem := ""
   Local aEmpresa := U_AUTOM539(1, "", oDlg) 
   Local aFilial  := U_AUTOM539(2, cEmpAnt, oDlg)
         
   // #################################
   // Prepara a variável de armazéns ##
   // #################################
   cArmazem := IIF(kJanela == 0, "##", Substr(cComboBx1,01,02))

   // ######################################################
   // Limpa o Browse para receber novos dados da pesquisa ##
   // ######################################################
   akBrowse := {}

   // ###################################
   // Limpa as variáveis totalizadoras ##
   // ###################################
   kSAtual01 := 0
   kPedido01 := 0
   kSalped01 := 0
  
   kSAtual02 := 0
   kPedido02 := 0
   kSalped02 := 0
   
   // ###############################################################
   // Pesquisa os saldos do produto para a Empresa 01 - Automatech ##
   // ###############################################################
   If Select("T_PORTO") > 0
      T_PORTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B2_FILIAL                  ,"
   cSql += "       B2_COD                     ,"
   cSql += "	   SUM(B2_QATU)    AS ATUAL   ,"
   cSql += "	   SUM(B2_QPEDVEN) AS QPEDIDOS,"
   cSql += "	   SUM(B2_SALPEDI) AS SPEDIDOS"
   cSql += "  FROM " + RetSqlName("SB2")                                            
   cSql += " WHERE B2_FILIAL  = '01'"
   cSql += "   AND B2_COD     = '" + Alltrim(kProduto) + "'"

   If cArmazem == "##"
   Else
      cSql += "   AND B2_LOCAL   = '" + Substr(cComboBx1,01,02) + "'"
   Endif

   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += " GROUP BY B2_FILIAL, B2_COD"
   cSql += " ORDER BY B2_FILIAL" 

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PORTO", .T., .T. )

   If T_PORTO->( EOF() )
      aAdd( akBrowse, { "AUTOMATECH" + Space(kEspaco), "01 - PORTO ALEGRE" + Space(kEspaco), 0 , 0 , 0, "" })
   Else

      If Select("T_PREVISTO") > 0
         T_PREVISTO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SUBSTRING(C7_DATPRF,07,02) + '/' + SUBSTRING(C7_DATPRF,05,02) + '/' +  SUBSTRING(C7_DATPRF,01,04) AS PREVISTO"
      cSql += "  FROM SC7010" 
      cSql += " WHERE C7_FILIAL  = '01'"
      cSql += "   AND C7_PRODUTO = '" + Alltrim(kProduto) + "'"
      cSql += "   AND C7_QUANT <> C7_QUJE"
      cSql += "   AND D_E_L_E_T_ = ''"
      cSql += " ORDER BY C7_DATPRF DESC"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PREVISTO", .T., .T. )

      cDatPOA := IIF(T_PREVISTO->( EOF() ), Ctod("  /  /    "), Ctod(T_PREVISTO->PREVISTO))

      aAdd( akBrowse, { "AUTOMATECH" + Space(kEspaco), "01 - PORTO ALEGRE" + Space(kEspaco), T_PORTO->ATUAL, T_PORTO->QPEDIDOS , T_PORTO->SPEDIDOS, cDatPOA })   

      kSAtual01 := kSAtual02 + T_PORTO->ATUAL
      kPedido01 := kPedido02 + T_PORTO->QPEDIDOS
      kSalped01 := kSalped02 + T_PORTO->SPEDIDOS
     
      kSAtual02 := kSAtual02 + T_PORTO->ATUAL
      kPedido02 := kPedido02 + T_PORTO->QPEDIDOS
      kSalped02 := kSalped02 + T_PORTO->SPEDIDOS

   Endif

   // ################
   // CAXIAS DO SUL ##
   // ################
   If Select("T_PORTO") > 0
      T_PORTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B2_FILIAL                  ,"
   cSql += "       B2_COD                     ,"
   cSql += "	   SUM(B2_QATU)    AS ATUAL   ,"
   cSql += "	   SUM(B2_QPEDVEN) AS QPEDIDOS,"
   cSql += "	   SUM(B2_SALPEDI) AS SPEDIDOS"
   cSql += "  FROM " + RetSqlName("SB2")
   cSql += " WHERE B2_FILIAL  = '02'"
   cSql += "   AND B2_COD     = '" + Alltrim(kProduto) + "'"

   If cArmazem == "##"
   Else
      cSql += "   AND B2_LOCAL   = '" + Substr(cComboBx1,01,02) + "'"
   Endif

   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += " GROUP BY B2_FILIAL, B2_COD"
   cSql += " ORDER BY B2_FILIAL" 

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PORTO", .T., .T. )

   If T_PORTO->( EOF() )
      aAdd( akBrowse, {  Space(kEspaco), "02 - CAXIAS DO SUL" + Space(kEspaco), 0 , 0 , 0, "" })
   Else

      If Select("T_PREVISTO") > 0
         T_PREVISTO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SUBSTRING(C7_DATPRF,07,02) + '/' + SUBSTRING(C7_DATPRF,05,02) + '/' +  SUBSTRING(C7_DATPRF,01,04) AS PREVISTO"
      cSql += "  FROM SC7010" 
      cSql += " WHERE C7_FILIAL  = '02'"
      cSql += "   AND C7_PRODUTO = '" + Alltrim(kProduto) + "'"
      cSql += "   AND C7_QUANT <> C7_QUJE"
      cSql += "   AND D_E_L_E_T_ = ''"
      cSql += " ORDER BY C7_DATPRF DESC"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PREVISTO", .T., .T. )

      cDatPOA := IIF(T_PREVISTO->( EOF() ), Ctod("  /  /    "), Ctod(T_PREVISTO->PREVISTO))

      aAdd( akBrowse, {  Space(kEspaco), "02 - CAXIAS DO SUL" + Space(kEspaco), T_PORTO->ATUAL, T_PORTO->QPEDIDOS , T_PORTO->SPEDIDOS, cDatPOA })   
   
      kSAtual01 := kSAtual02 + T_PORTO->ATUAL
      kPedido01 := kPedido02 + T_PORTO->QPEDIDOS
      kSalped01 := kSalped02 + T_PORTO->SPEDIDOS
     
      kSAtual02 := kSAtual02 + T_PORTO->ATUAL
      kPedido02 := kPedido02 + T_PORTO->QPEDIDOS
      kSalped02 := kSalped02 + T_PORTO->SPEDIDOS

   Endif

   // ##########
   // PELOTAS ##
   // ##########
   If Select("T_PORTO") > 0
      T_PORTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B2_FILIAL                  ,"
   cSql += "       B2_COD                     ,"
   cSql += "	   SUM(B2_QATU)    AS ATUAL   ,"
   cSql += "	   SUM(B2_QPEDVEN) AS QPEDIDOS,"
   cSql += "	   SUM(B2_SALPEDI) AS SPEDIDOS"
   cSql += "  FROM " + RetSqlName("SB2")
   cSql += " WHERE B2_FILIAL  = '03'"
   cSql += "   AND B2_COD     = '" + Alltrim(kProduto) + "'"

   If cArmazem == "##"
   Else
      cSql += "   AND B2_LOCAL   = '" + Substr(cComboBx1,01,02) + "'"
   Endif

   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += " GROUP BY B2_FILIAL, B2_COD"  
   cSql += " ORDER BY B2_FILIAL" 

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PORTO", .T., .T. )

   If T_PORTO->( EOF() )
      aAdd( akBrowse, { Space(kEspaco), "03 - PELOTAS" + Space(kEspaco), 0 , 0 , 0, "" })
   Else

      If Select("T_PREVISTO") > 0
         T_PREVISTO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SUBSTRING(C7_DATPRF,07,02) + '/' + SUBSTRING(C7_DATPRF,05,02) + '/' +  SUBSTRING(C7_DATPRF,01,04) AS PREVISTO"
      cSql += "  FROM SC7010" 
      cSql += " WHERE C7_FILIAL  = '03'"
      cSql += "   AND C7_PRODUTO = '" + Alltrim(kProduto) + "'"
      cSql += "   AND C7_QUANT <> C7_QUJE"
      cSql += "   AND D_E_L_E_T_ = ''"
      cSql += " ORDER BY C7_DATPRF DESC"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PREVISTO", .T., .T. )

      cDatPOA := IIF(T_PREVISTO->( EOF() ), Ctod("  /  /    "), Ctod(T_PREVISTO->PREVISTO))

      aAdd( akBrowse, { Space(kEspaco), "03 - PELOTAS" + Space(kEspaco), T_PORTO->ATUAL, T_PORTO->QPEDIDOS, T_PORTO->SPEDIDOS, cDatPOA })   

      kSAtual01 := kSAtual02 + T_PORTO->ATUAL
      kPedido01 := kPedido02 + T_PORTO->QPEDIDOS
      kSalped01 := kSalped02 + T_PORTO->SPEDIDOS
  
      kSAtual02 := kSAtual02 + T_PORTO->ATUAL
      kPedido02 := kPedido02 + T_PORTO->QPEDIDOS
      kSalped02 := kSalped02 + T_PORTO->SPEDIDOS

   Endif

   // ##############
   // SUPRIMENTOS ##
   // ##############
   If Select("T_PORTO") > 0
      T_PORTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B2_FILIAL                  ,"
   cSql += "       B2_COD                     ,"
   cSql += "	   SUM(B2_QATU)    AS ATUAL   ,"
   cSql += "	   SUM(B2_QPEDVEN) AS QPEDIDOS,"
   cSql += "	   SUM(B2_SALPEDI) AS SPEDIDOS"
   cSql += "  FROM " + RetSqlName("SB2")
   cSql += " WHERE B2_FILIAL  = '04'"
   cSql += "   AND B2_COD     = '" + Alltrim(kProduto) + "'"

   If cArmazem == "##"
   Else
      cSql += "   AND B2_LOCAL   = '" + Substr(cComboBx1,01,02) + "'"
   Endif

   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += " GROUP BY B2_FILIAL, B2_COD"
   cSql += " ORDER BY B2_FILIAL" 

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PORTO", .T., .T. )

   If T_PORTO->( EOF() )
      aAdd( akBrowse, { Space(kEspaco), "04 - SUPRIMENTOS" + Space(kEspaco), 0 , 0 , 0, "" })
   Else

      If Select("T_PREVISTO") > 0
         T_PREVISTO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SUBSTRING(C7_DATPRF,07,02) + '/' + SUBSTRING(C7_DATPRF,05,02) + '/' +  SUBSTRING(C7_DATPRF,01,04) AS PREVISTO"
      cSql += "  FROM SC7010" 
      cSql += " WHERE C7_FILIAL  = '04'"
      cSql += "   AND C7_PRODUTO = '" + Alltrim(kProduto) + "'"
      cSql += "   AND C7_QUANT <> C7_QUJE"
      cSql += "   AND D_E_L_E_T_ = ''"
      cSql += " ORDER BY C7_DATPRF DESC"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PREVISTO", .T., .T. )

      cDatPOA := IIF(T_PREVISTO->( EOF() ), Ctod("  /  /    "), Ctod(T_PREVISTO->PREVISTO))

      aAdd( akBrowse, { Space(kEspaco), "04 - SUPRIMENTOS" + Space(kEspaco), T_PORTO->ATUAL, T_PORTO->QPEDIDOS, T_PORTO->SPEDIDOS, cDatPOA })   

      kSAtual01 := kSAtual02 + T_PORTO->ATUAL
      kPedido01 := kPedido02 + T_PORTO->QPEDIDOS
      kSalped01 := kSalped02 + T_PORTO->SPEDIDOS
  
      kSAtual02 := kSAtual02 + T_PORTO->ATUAL
      kPedido02 := kPedido02 + T_PORTO->QPEDIDOS
      kSalped02 := kSalped02 + T_PORTO->SPEDIDOS

   Endif

   // ############
   // SÃO PAULO ##
   // ############
   If Select("T_PORTO") > 0
      T_PORTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B2_FILIAL                  ,"
   cSql += "       B2_COD                     ,"
   cSql += "	   SUM(B2_QATU)    AS ATUAL   ,"
   cSql += "	   SUM(B2_QPEDVEN) AS QPEDIDOS,"
   cSql += "	   SUM(B2_SALPEDI) AS SPEDIDOS"
   cSql += "  FROM " + RetSqlName("SB2")
   cSql += " WHERE B2_FILIAL  = '05'"
   cSql += "   AND B2_COD     = '" + Alltrim(kProduto) + "'"

   If cArmazem == "##"
   Else
      cSql += "   AND B2_LOCAL   = '" + Substr(cComboBx1,01,02) + "'"
   Endif

   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += " GROUP BY B2_FILIAL, B2_COD" 
   cSql += " ORDER BY B2_FILIAL" 

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PORTO", .T., .T. )

   If T_PORTO->( EOF() )
      aAdd( akBrowse, { Space(kEspaco), "05 - SÃO PAULO" + Space(kEspaco), 0 , 0 , 0, "" })
   Else

      If Select("T_PREVISTO") > 0
         T_PREVISTO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SUBSTRING(C7_DATPRF,07,02) + '/' + SUBSTRING(C7_DATPRF,05,02) + '/' +  SUBSTRING(C7_DATPRF,01,04) AS PREVISTO"
      cSql += "  FROM SC7010" 
      cSql += " WHERE C7_FILIAL  = '05'"
      cSql += "   AND C7_PRODUTO = '" + Alltrim(kProduto) + "'"
      cSql += "   AND C7_QUANT <> C7_QUJE"
      cSql += "   AND D_E_L_E_T_ = ''"
      cSql += " ORDER BY C7_DATPRF DESC"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PREVISTO", .T., .T. )

      cDatPOA := IIF(T_PREVISTO->( EOF() ), Ctod("  /  /    "), Ctod(T_PREVISTO->PREVISTO))

      aAdd( akBrowse, { Space(kEspaco), "05 - SÃO PAULO" + Space(kEspaco), T_PORTO->ATUAL, T_PORTO->QPEDIDOS, T_PORTO->SPEDIDOS, cDatPOA })   

      kSAtual01 := kSAtual02 + T_PORTO->ATUAL
      kPedido01 := kPedido02 + T_PORTO->QPEDIDOS
      kSalped01 := kSalped02 + T_PORTO->SPEDIDOS
  
      kSAtual02 := kSAtual02 + T_PORTO->ATUAL
      kPedido02 := kPedido02 + T_PORTO->QPEDIDOS
      kSalped02 := kSalped02 + T_PORTO->SPEDIDOS

   Endif

   // #################
   // ESPIRITO SANTO ##
   // #################
   If Select("T_PORTO") > 0
      T_PORTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B2_FILIAL                  ,"
   cSql += "       B2_COD                     ,"
   cSql += "	   SUM(B2_QATU)    AS ATUAL   ,"
   cSql += "	   SUM(B2_QPEDVEN) AS QPEDIDOS,"
   cSql += "	   SUM(B2_SALPEDI) AS SPEDIDOS"
   cSql += "  FROM " + RetSqlName("SB2")
   cSql += " WHERE B2_FILIAL  = '06'"
   cSql += "   AND B2_COD     = '" + Alltrim(kProduto) + "'"

   If cArmazem == "##"
   Else
      cSql += "   AND B2_LOCAL   = '" + Substr(cComboBx1,01,02) + "'"
   Endif

   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += " GROUP BY B2_FILIAL, B2_COD"
   cSql += " ORDER BY B2_FILIAL" 

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PORTO", .T., .T. )

   If T_PORTO->( EOF() )
      aAdd( akBrowse, {  Space(kEspaco), "06 - ESPIRITO SANTO" + Space(kEspaco), 0 , 0 , 0, "" })
   Else

      If Select("T_PREVISTO") > 0
         T_PREVISTO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SUBSTRING(C7_DATPRF,07,02) + '/' + SUBSTRING(C7_DATPRF,05,02) + '/' +  SUBSTRING(C7_DATPRF,01,04) AS PREVISTO"
      cSql += "  FROM SC7010" 
      cSql += " WHERE C7_FILIAL  = '06'"
      cSql += "   AND C7_PRODUTO = '" + Alltrim(kProduto) + "'"
      cSql += "   AND C7_QUANT <> C7_QUJE"
      cSql += "   AND D_E_L_E_T_ = ''"
      cSql += " ORDER BY C7_DATPRF DESC"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PREVISTO", .T., .T. )

      cDatPOA := IIF(T_PREVISTO->( EOF() ), Ctod("  /  /    "), Ctod(T_PREVISTO->PREVISTO))

      aAdd( akBrowse, {  Space(kEspaco), "06 - ESPIRITO SANTO" + Space(kEspaco), T_PORTO->ATUAL, T_PORTO->QPEDIDOS, T_PORTO->SPEDIDOS, cDatPOA })   

      kSAtual01 := kSAtual02 + T_PORTO->ATUAL
      kPedido01 := kPedido02 + T_PORTO->QPEDIDOS
      kSalPed01 := kSalped02 + T_PORTO->SPEDIDOS
     
      kSAtual02 := kSAtual02 + T_PORTO->ATUAL
      kPedido02 := kPedido02 + T_PORTO->QPEDIDOS
      kSalped02 := kSalped02 + T_PORTO->SPEDIDOS

   Endif

   aAdd( akBrowse, { "", "Total", KSAtual01, kpedido01 , kSalPed01, "" })

   aAdd( akBrowse, { "", "", "" , "" , "", "" })

   // #################################################################
   // Pesquisa os saldos do produto para a Empresa 02 - TI AUTOMAÇÃO ##
   // #################################################################
   If Select("T_PORTO") > 0
      T_PORTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B2_FILIAL                  ,"
   cSql += "       B2_COD                     ,"
   cSql += "	   SUM(B2_QATU)    AS ATUAL   ,"
   cSql += "	   SUM(B2_QPEDVEN) AS QPEDIDOS,"
   cSql += "	   SUM(B2_SALPEDI) AS SPEDIDOS"
   cSql += "  FROM SB2020"
   cSql += " WHERE B2_FILIAL  = '01'"
   cSql += "   AND B2_COD     = '" + Alltrim(kProduto) + "'"

   If cArmazem == "##"
   Else
      cSql += "   AND B2_LOCAL   = '" + Substr(cComboBx1,01,02) + "'"
   Endif

   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += " GROUP BY B2_FILIAL, B2_COD"
   cSql += " ORDER BY B2_FILIAL" 

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PORTO", .T., .T. )

   If T_PORTO->( EOF() )
      aAdd( akBrowse, { "TI AUTOMAÇÃO" + Space(kEspaco), "01 - CURITIBA" + Space(kEspaco), 0 , 0 , 0, "" })
   Else

      If Select("T_PREVISTO") > 0
         T_PREVISTO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SUBSTRING(C7_DATPRF,07,02) + '/' + SUBSTRING(C7_DATPRF,05,02) + '/' +  SUBSTRING(C7_DATPRF,01,04) AS PREVISTO"
      cSql += "  FROM SC7020" 
      cSql += " WHERE C7_FILIAL  = '01'"
      cSql += "   AND C7_PRODUTO = '" + Alltrim(kProduto) + "'"
      cSql += "   AND C7_QUANT <> C7_QUJE"
      cSql += "   AND D_E_L_E_T_ = ''"
      cSql += " ORDER BY C7_DATPRF DESC"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PREVISTO", .T., .T. )

      cDatPOA := IIF(T_PREVISTO->( EOF() ), Ctod("  /  /    "), Ctod(T_PREVISTO->PREVISTO))

      aAdd( akBrowse, { "TI AUTOMAÇÃO" + Space(kEspaco), "01 - CURITIBA" + Space(kEspaco), T_PORTO->ATUAL, T_PORTO->QPEDIDOS, T_PORTO->SPEDIDOS, cDatPOA })   

      kSAtual02 := kSAtual02 + T_PORTO->ATUAL
      kPedido02 := kPedido02 + T_PORTO->QPEDIDOS
      kSalped02 := kSalped02 + T_PORTO->SPEDIDOS

   Endif

   aAdd( akBrowse, { "", "", "" , "" , "", "" })

   // ##########################################################
   // Pesquisa os saldos do produto para a Empresa 03 - ATECH ##
   // ##########################################################
   If Select("T_PORTO") > 0
      T_PORTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B2_FILIAL                  ,"
   cSql += "       B2_COD                     ,"
   cSql += "	   SUM(B2_QATU)    AS ATUAL   ,"
   cSql += "	   SUM(B2_QPEDVEN) AS QPEDIDOS,"
   cSql += "	   SUM(B2_SALPEDI) AS SPEDIDOS"
   cSql += "  FROM SB2030"
   cSql += " WHERE B2_FILIAL  = '01'"
   cSql += "   AND B2_COD     = '" + Alltrim(kProduto) + "'"

   If cArmazem == "##"
   Else
      cSql += "   AND B2_LOCAL   = '" + Substr(cComboBx1,01,02) + "'"
   Endif

   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += " GROUP BY B2_FILIAL, B2_COD"
   cSql += " ORDER BY B2_FILIAL" 

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PORTO", .T., .T. )

   If T_PORTO->( EOF() )
      aAdd( akBrowse, { "ATECH", "01 - SUPRIMENTOS" + Space(kEspaco), 0 , 0 , 0, "" })
   Else

      If Select("T_PREVISTO") > 0
         T_PREVISTO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SUBSTRING(C7_DATPRF,07,02) + '/' + SUBSTRING(C7_DATPRF,05,02) + '/' +  SUBSTRING(C7_DATPRF,01,04) AS PREVISTO"
      cSql += "  FROM SC7030" 
      cSql += " WHERE C7_FILIAL  = '01'"
      cSql += "   AND C7_PRODUTO = '" + Alltrim(kProduto) + "'"
      cSql += "   AND C7_QUANT <> C7_QUJE"
      cSql += "   AND D_E_L_E_T_ = ''"
      cSql += " ORDER BY C7_DATPRF DESC"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PREVISTO", .T., .T. )

      cDatPOA := IIF(T_PREVISTO->( EOF() ), Ctod("  /  /    "), Ctod(T_PREVISTO->PREVISTO))

      aAdd( akBrowse, { "ATECH", "01 - SUPRIMENTOS" + Space(kEspaco), T_PORTO->ATUAL, T_PORTO->QPEDIDOS, T_PORTO->SPEDIDOS, cDatPOA })   

      kSAtual02 := kSAtual02 + T_PORTO->ATUAL
      kPedido02 := kPedido02 + T_PORTO->QPEDIDOS
      kSalped02 := kSalped02 + T_PORTO->SPEDIDOS

   Endif

   aAdd( akBrowse, { "", "", "" , "" , "", "" })

   // #############################################################
   // Pesquisa os saldos do produto para a Empresa 04 - ATECHPEL ##
   // #############################################################
   If Select("T_PORTO") > 0
      T_PORTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT B2_FILIAL                  ,"
   cSql += "       B2_COD                     ,"
   cSql += "	   SUM(B2_QATU)    AS ATUAL   ,"
   cSql += "	   SUM(B2_QPEDVEN) AS QPEDIDOS,"
   cSql += "	   SUM(B2_SALPEDI) AS SPEDIDOS"
   cSql += "  FROM SB2040"
   cSql += " WHERE B2_FILIAL  = '01'"
   cSql += "   AND B2_COD     = '" + Alltrim(kProduto) + "'"

   If cArmazem == "##"
   Else
      cSql += "   AND B2_LOCAL   = '" + Substr(cComboBx1,01,02) + "'"
   Endif

   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += " GROUP BY B2_FILIAL, B2_COD"
   cSql += " ORDER BY B2_FILIAL" 

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PORTO", .T., .T. )

   If T_PORTO->( EOF() )
      aAdd( akBrowse, { "ATECHPEL" + Space(kEspaco), "01 - PELOTAS" + Space(kEspaco), 0 , 0 , 0, "" })
   Else

      If Select("T_PREVISTO") > 0
         T_PREVISTO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SUBSTRING(C7_DATPRF,07,02) + '/' + SUBSTRING(C7_DATPRF,05,02) + '/' +  SUBSTRING(C7_DATPRF,01,04) AS PREVISTO"
      cSql += "  FROM SC7040" 
      cSql += " WHERE C7_FILIAL  = '01'"
      cSql += "   AND C7_PRODUTO = '" + Alltrim(kProduto) + "'"
      cSql += "   AND C7_QUANT <> C7_QUJE"
      cSql += "   AND D_E_L_E_T_ = ''"
      cSql += " ORDER BY C7_DATPRF DESC"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PREVISTO", .T., .T. )

      cDatPOA := IIF(T_PREVISTO->( EOF() ), Ctod("  /  /    "), Ctod(T_PREVISTO->PREVISTO))

      aAdd( akBrowse, { "ATECHPEL" + Space(kEspaco), "01 - PELOTAS" + Space(kEspaco), T_PORTO->ATUAL, T_PORTO->QPEDIDOS, T_PORTO->SPEDIDOS, cDatPOA })   

      kSAtual02 := kSAtual02 + T_PORTO->ATUAL
      kPedido02 := kPedido02 + T_PORTO->QPEDIDOS
      kSalPed02 := kSalped02 + T_PORTO->SPEDIDOS

   Endif

   If Len(akBrowse) == 0
      akBrowse := {}
      aAdd( akBrowse, { "", "", "" , "" , "", "" })
      aAdd( akBrowse, { "", "Total Geral", 0 , 0 , 0, "" })   
   Endif
   
   If kJanela == 0
      Return(.T.)
   Endif
         
   oKBrowse:SetArray(aKBrowse) 

   okBrowse:bLine := {||{akBrowse[okBrowse:nAt,01],;
                         akBrowse[okBrowse:nAt,02],;   
                         akBrowse[okBrowse:nAt,03],;   
                         akBrowse[okBrowse:nAt,04],;   
                         akBrowse[okBrowse:nAt,05],;   
                         akBrowse[okBrowse:nAt,06]}}

Return(.T.)