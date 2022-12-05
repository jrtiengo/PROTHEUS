#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"
#INCLUDE "jpeg.ch"    
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: AUTOM598.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                         ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 08/08/2017                                                              ##
// Objetivo..: Programa que calcula o consumo de produtos                              ##
// Parâmetros: kProduto - Prodto a ser pesquisado na entrada do programa               ##
// ######################################################################################

User Function AUTOM598(kProduto)

   Local lChumba := .F.
   Local cSql    := ""
   Local cMemo1	 := ""
   Local oMemo1

   Private aEmpresa   := U_AUTOM539(1, "")     
   Private aFiliais   := U_AUTOM539(2, cEmpAnt)
   Private aGrupos    := {}
   Private aTipoMat   := {"0 - Selecione", "1 - Consumo", "2 - Venda"}
   Private cDataIni	  := Ctod("01/01/" + Strzero(Year(Date()),4))
   Private cDataFim	  := Ctod("31/12/" + Strzero(Year(Date()),4))
   Private cProduto	  := Space(30)
   Private cDescricao := Space(60)
   Private cString    := Space(60)

   Private cComboBx1
   Private cComboBx2 := "2 - Venda"
   Private cComboBx3
   Private cComboBx4   
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5

   DEFINE FONT oFont Name "Courier New" Size 0, 14

   Private aLista := {}

   Private oDlg

   U_AUTOM628("AUTOM598")
   
   If kProduto == Nil
      cProduto := Space(30)
   Else
      cProduto := kProduto
   Endif      

   // #########################################
   // Carrega o combo dos grupos de produtos ##
   // #########################################
   If Select("T_GRUPOS") > 0
      T_GRUPOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT BM_GRUPO,"
   cSql += "       BM_DESC  "
   cSql += "  FROM " + RetSqlName("SBM")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += " ORDER BY BM_GRUPO    "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GRUPOS", .T., .T. )

   aAdd( aGrupos, "0000 - Selecione")

   T_GRUPOS->( DbGoTop() )
   
   WHILE !T_GRUPOS->( EOF() )
      aAdd( aGrupos, T_GRUPOS->BM_GRUPO + " - " + Alltrim(T_GRUPOS->BM_DESC))
      T_GRUPOS->( DbSkip() )
   ENDDO
   
   // ################################################################################
   // Envia para a função que pesquisa os dados caso o produto passado no parâmetro ##
   // ################################################################################
   If Empty(Alltrim(cProduto))
   Else
      PsqConsumo(0)
   Endif   

   // #############################################
   // Desenha a tela para visualização dos dados ##
   // #############################################
   DEFINE MSDIALOG oDlg TITLE "Consulta Consumo de Produtos" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(000),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(126),C(022) PIXEL OF oDlg

   @ C(031),C(005) Say "Período Inicial" Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(031),C(045) Say "Período Final"   Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(031),C(086) Say "Produto"         Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(031),C(260) Say "Grupo"           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(031),C(365) Say "String"          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(016),C(145) Say "Empresas"        Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(016),C(222) Say "Filiais"         Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlg   
   @ C(016),C(299) Say "Pesquisar por"   Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(022),C(145) ComboBox cComboBx3 Items aEmpresa   Size C(072),C(010)                              PIXEL OF oDlg  ON CHANGE ALTERACOMBO()
   @ C(022),C(222) ComboBox cComboBx4 Items aFiliais   Size C(072),C(010)                              PIXEL OF oDlg
   @ C(022),C(299) ComboBox cComboBx2 Items aTipoMat   Size C(072),C(010)                              PIXEL OF oDlg

   @ C(039),C(005) MsGet    oGet1     Var   cDataIni   Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(039),C(045) MsGet    oGet2     Var   cDataFim   Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(039),C(086) MsGet    oGet3     Var   cProduto   Size C(053),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SB1") VALID( PegaNomePro() ) 
   @ C(039),C(145) MsGet    oGet4     Var   cDescricao Size C(108),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(039),C(260) ComboBox cComboBx1 Items aGrupos    Size C(100),C(010)                              PIXEL OF oDlg
   @ C(039),C(365) MsGet    oGet5     Var   cString    Size C(091),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(036),C(462) Button "Pesquisar"           Size C(037),C(012) PIXEL OF oDlg ACTION( PsqConsumo(1) )
   @ C(210),C(362) Button "Exportar para Excel" Size C(056),C(012) PIXEL OF oDlg ACTION( xGeraPCSV() ) When !Empty(Alltrim(aLista[1,1]))
   @ C(210),C(462) Button "Voltar"              Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aLista, { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" } )

   // ##################################################
   // Desenha a Lista para visualização dos resultado ##
   // ##################################################
   @ 070,005 LISTBOX oList FIELDS HEADER "Produto", "Descrição dos Produtos", "Janeio", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro", "Total" PIXEL SIZE 633,195 FONT oFont OF oDlg ;             
                           ON LEFT DBLCLICK ( TrocaCor()), ON RIGHT CLICK (TrocaCor())

   oList:SetArray( aLista )

   oList:bLine := {||     {aLista[oList:nAt,01],;
                    	   aLista[oList:nAt,02],;
          				   aLista[oList:nAt,03],;
          				   aLista[oList:nAt,04],;
          				   aLista[oList:nAt,05],;
          				   aLista[oList:nAt,06],;
          				   aLista[oList:nAt,07],;          					             					   
         	        	   aLista[oList:nAt,08],;
         	        	   aLista[oList:nAt,09],;
         	        	   aLista[oList:nAt,10],;
         	        	   aLista[oList:nAt,11],;
         	        	   aLista[oList:nAt,12],;
         	        	   aLista[oList:nAt,13],;
         	        	   aLista[oList:nAt,14],;
         	        	   aLista[oList:nAt,15]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #######################################################################
// Função que carrega o combo de filiais conforme a empresa selecionada ##
// #######################################################################
Static Function AlteraCombo

   aFiliais := U_AUTOM539(2, Substr(cComboBx3,01,02) )
   @ C(022),C(222) ComboBox cComboBx4 Items aFiliais Size C(072),C(010) PIXEL OF oDlg

Return(.T.)

// #######################################################
// Função que pesquisa a descrição do produto informado ##
// #######################################################
Static Function PegaNomePro()

   If Empty(Alltrim(cProduto))
      cProduto   := Space(30)
      cDescricao := Space(60)
      oGet3:Refresh()
      oGet4:Refresh()
      Return(.T.)
   Endif
   
   cDescricao := Alltrim(Posicione( "SB1", 1, xFilial("SB1") + cProduto, "B1_DESC" )) + " " + ;
                 Alltrim(Posicione( "SB1", 1, xFilial("SB1") + cProduto, "B1_DAUX" ))

   If Empty(Alltrim(cDescricao))
      MsgAlert("Produto informado não cadastrado.")
      cProduto   := Space(30)
      cDescricao := Space(60)
      oGet3:Refresh()
      oGet4:Refresh()
      Return(.T.)
   Endif

   oGet3:Refresh()
   oGet4:Refresh()

Return(.T.)

// ####################################################
// Função que pesquisa o consumo do filtro informado ##
// ####################################################
Static Function PsqConsumo(kTipo)

   MsgRun("Aguarde! Pesquisando informações conforme parâmetros ...", "Pesquisa de Informações",{|| xPsqConsumo(kTipo) })

Return(.T.)

// ####################################################
// Função que pesquisa o consumo do filtro informado ##
// ####################################################
Static Function xPsqConsumo(kTipo)

   Local cSql := ""

   If kTipo == 1
      If Empty(cDataIni)
         MsgAlert("Necessário informar data inicial para pesquisa.")
         Return(.T.)
      Endif
      
      If Empty(cDataFim)
         MsgAlert("Necessário informar data final para pesquisa.")
         Return(.T.)
      Endif

      If Year(cDataIni) <> Year(cDataFim)
         MsgAlert("Período informado inválido. Somente permitido pesquisar períodos do mesmo ano.")
         Return(.T.)
      Endif
   
      If Substr(cComboBx2,01,01) == "0"
         MsgAlert("Necessário selecionar o tipo de pesquisa a ser realizada.")
         Return(.T.)
      Else
         kPesquisa := Substr(cComboBx2,01,01)
      Endif

   Else

      kPesquisa := "2"
      
   Endif   

   // ##############################################
   // Limpa o array para receber novos resultados ##
   // ##############################################
   aLista := {}

   // ###############################################
   // Realiza a pesquisa conforme filtro informado ##
   // ###############################################

   If kPesquisa == "1"

      If Select("T_PRODUTO") > 0
         T_PRODUTO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SUBSTRING(SD3.D3_EMISSAO,05,02) + '/' + SUBSTRING(SD3.D3_EMISSAO,01,04) AS MES," + chr(13)
      cSql += "       SD3.D3_COD , " + chr(13)
      cSql += "       SB1.B1_DESC, "   + chr(13)
      cSql += "       SUM(SD3.D3_QUANT) AS CONSUMO" + chr(13)

      If kTipo == 0
         cSql += "  FROM " + RetSqlName("SD3") + " SD3, " + chr(13)
      Else
         cSql += "  FROM SD3" + Substr(cComboBx3,01,02) + "0 SD3, " + chr(13)         
      Endif
         
      cSql += "       " + RetSqlName("SB1") + " SB1  " + chr(13)

      If kTipo == 0
         cSql += " WHERE SD3.D3_FILIAL   = '"  + Alltrim(cFilAnt) + "'" + chr(13)
      Else   
         cSql += " WHERE SD3.D3_FILIAL   = '"  + Alltrim(Substr(cComboBx4,01,02)) + "'" + chr(13)
      Endif   

      If Empty(Alltrim(cProduto))
      Else
         cSql += "   AND SD3.D3_COD      = '" + Alltrim(cProduto) + "'" + chr(13)
      Endif   

      If kTipo == 0
      Else 
         If Substr(cComboBx1,01,04) == "0000"
         Else
            cSql += " AND SD3.D3_GRUPO = '" + Alltrim(Substr(cComboBx1,01,04)) + "'" + chr(13)
         Endif   
      Endif   

      If Empty(Alltrim(cString))
      Else
         cSql += " AND SB1.B1_DESC LIKE '%" + Alltrim(cString) + "%'" + chr(13)
      Endif   

      cSql += "   AND SD3.D3_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(cDataIni) + "', 103)" + chr(13)
      cSql += "   AND SD3.D3_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(cDataFim) + "', 103)" + chr(13)
      cSql += "   AND SD3.D3_ESTORNO = '' " + chr(13)
      cSql += "   AND SD3.D3_OP     <> '' " + chr(13)
      cSql += "   AND SD3.D_E_L_E_T_ = '' " + chr(13)
      cSql += "   AND SB1.B1_COD     = SD3.D3_COD " + chr(13)
      cSql += "   AND SB1.D_E_L_E_T_ = '' " + chr(13)
      cSql += " GROUP BY SUBSTRING(SD3.D3_EMISSAO,05,02) + '/' + SUBSTRING(SD3.D3_EMISSAO,01,04), SD3.D3_COD, SB1.B1_DESC" + chr(13)
      cSql += " ORDER BY SD3.D3_COD, SUBSTRING(SD3.D3_EMISSAO,05,02) + '/' + SUBSTRING(SD3.D3_EMISSAO,01,04)"  + chr(13)

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTO", .T., .T. )

      lExiste := .F.

      T_PRODUTO->( DbGoTop() )
     
      WHILE !T_PRODUTO->( EOF() )
   
         lExiste := .F.

         For nContar = 1 to Len(aLista)

             If Alltrim(aLista[nContar,01]) == Alltrim(T_PRODUTO->D3_COD)
                lExiste := .T.
                Exit
             Endif
          
         Next nContar       

         If lExiste == .F.

            aAdd( aLista, { T_PRODUTO->D3_COD             ,;
                            T_PRODUTO->B1_DESC            ,;
                            Transform(0, "@E 9999999.99") ,;
                            Transform(0, "@E 9999999.99") ,;
                            Transform(0, "@E 9999999.99") ,;
                            Transform(0, "@E 9999999.99") ,;
                            Transform(0, "@E 9999999.99") ,;
                            Transform(0, "@E 9999999.99") ,;
                            Transform(0, "@E 9999999.99") ,;
                            Transform(0, "@E 9999999.99") ,;
                            Transform(0, "@E 9999999.99") ,;
                            Transform(0, "@E 9999999.99") ,;
                            Transform(0, "@E 9999999.99") ,;
                            Transform(0, "@E 9999999.99") ,;
                            Transform(0, "@E 9999999.99") })
                         
          Endif
                                
          T_PRODUTO->( DbSkip() )

      ENDDO   

      T_PRODUTO->( DbGoTop() )
   
      WHILE !T_PRODUTO->( EOF() )
   
         For nContar = 1 to Len(aLista)
      
             If Alltrim(aLista[nContar,01]) == Alltrim(T_PRODUTO->D3_COD)
             
                Do Case
                   Case Substr(T_PRODUTO->MES,01,02) == "01"
                        aLista[nContar,03] := Transform(Val(aLista[nContar,03]) + T_PRODUTO->CONSUMO, "@E 9999999.99") 
                   Case Substr(T_PRODUTO->MES,01,02) == "02"
                        aLista[nContar,04] := Transform(Val(aLista[nContar,04]) + T_PRODUTO->CONSUMO, "@E 9999999.99") 
                   Case Substr(T_PRODUTO->MES,01,02) == "03"
                        aLista[nContar,05] := Transform(Val(aLista[nContar,05]) + T_PRODUTO->CONSUMO, "@E 9999999.99") 
                   Case Substr(T_PRODUTO->MES,01,02) == "04"
                        aLista[nContar,06] := Transform(Val(aLista[nContar,06]) + T_PRODUTO->CONSUMO, "@E 9999999.99") 
                   Case Substr(T_PRODUTO->MES,01,02) == "05"
                        aLista[nContar,07] := Transform(Val(aLista[nContar,07]) + T_PRODUTO->CONSUMO, "@E 9999999.99") 
                   Case Substr(T_PRODUTO->MES,01,02) == "06"
                        aLista[nContar,08] := Transform(Val(aLista[nContar,08]) + T_PRODUTO->CONSUMO, "@E 9999999.99") 
                   Case Substr(T_PRODUTO->MES,01,02) == "07"
                        aLista[nContar,09] := Transform(Val(aLista[nContar,09]) + T_PRODUTO->CONSUMO, "@E 9999999.99") 
                   Case Substr(T_PRODUTO->MES,01,02) == "08"
                        aLista[nContar,10] := Transform(Val(aLista[nContar,10]) + T_PRODUTO->CONSUMO, "@E 9999999.99") 
                   Case Substr(T_PRODUTO->MES,01,02) == "09"
                        aLista[nContar,11] := Transform(Val(aLista[nContar,11]) + T_PRODUTO->CONSUMO, "@E 9999999.99") 
                   Case Substr(T_PRODUTO->MES,01,02) == "10"
                        aLista[nContar,12] := Transform(Val(aLista[nContar,12]) + T_PRODUTO->CONSUMO, "@E 9999999.99") 
                   Case Substr(T_PRODUTO->MES,01,02) == "11"
                        aLista[nContar,13] := Transform(Val(aLista[nContar,13]) + T_PRODUTO->CONSUMO, "@E 9999999.99") 
                   Case Substr(T_PRODUTO->MES,01,02) == "12"
                        aLista[nContar,14] := Transform(Val(aLista[nContar,14]) + T_PRODUTO->CONSUMO, "@E 9999999.99") 
                EndCase        

                aLista[nContar,15] := Transform(Val(aLista[nContar,03]) + ;
                                                Val(aLista[nContar,04]) + ;
                                                Val(aLista[nContar,05]) + ;
                                                Val(aLista[nContar,06]) + ;
                                                Val(aLista[nContar,07]) + ;
                                                Val(aLista[nContar,08]) + ;
                                                Val(aLista[nContar,09]) + ;
                                                Val(aLista[nContar,10]) + ;
                                                Val(aLista[nContar,11]) + ;
                                                Val(aLista[nContar,12]) + ;
                                                Val(aLista[nContar,13]) + ;
                                                Val(aLista[nContar,14]), "@E 9999999.99")
                Exit
   
             Endif
          
         Next nContar    
                      
         T_PRODUTO->( DbSkip() )
      
      ENDDO
      
   Else

      If Select("T_PRODUTO") > 0
         T_PRODUTO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT SUBSTRING(SC6.C6_DATFAT,05,02) + '/' + SUBSTRING(SC6.C6_DATFAT,01,04) AS MES,"
      cSql += "       SC6.C6_PRODUTO , "
      cSql += "       SB1.B1_DESC    , " 
      cSql += "       SB1.B1_GRUPO   , "
      cSql += "       SUM(SC6.C6_QTDVEN) AS CONSUMO"

      If kTipo == 0
         cSql += "  FROM " + RetSqlName("SC6") + " SC6, " 
      Else   
         cSql += "  FROM SC6" + Substr(cComboBx3,01,02) + "0 SC6, " 
      Endif   

      cSql += "       " + RetSqlName("SB1") + " SB1  " 

      If kTipo == 0
         cSql += " WHERE SC6.C6_FILIAL   = '" + Alltrim(cFilAnt) + "'"
      Else
         cSql += " WHERE SC6.C6_FILIAL   = '" + Alltrim(Substr(cComboBx4,01,02)) + "'"
      Endif   

      cSql += "   AND SC6.C6_DATFAT >= CONVERT(DATETIME,'" + Dtoc(cDataIni) + "', 103)"
      cSql += "   AND SC6.C6_DATFAT <= CONVERT(DATETIME,'" + Dtoc(cDataFim) + "', 103)"
      cSql += "   AND SC6.C6_NOTA   <> ''"
      cSql += "   AND SC6.D_E_L_E_T_ = ''" 

      If Empty(Alltrim(cProduto))
      Else
         cSql += "   AND SC6.C6_PRODUTO = '" + Alltrim(cProduto) + "'" + chr(13)
      Endif   

      If kTipo == 0
      Else
         If Substr(cComboBx1,01,04) == "0000"
         Else
            cSql += " AND SB1.B1_GRUPO = '" + Alltrim(Substr(cComboBx1,01,04)) + "'" + chr(13)
         Endif   
      Endif   

      If Empty(Alltrim(cString))
      Else
         cSql += " AND SB1.B1_DESC LIKE '%" + Alltrim(cString) + "%'" + chr(13)
      Endif   

      cSql += "   AND SB1.B1_COD     = SC6.C6_PRODUTO"
      cSql += "   AND SB1.D_E_L_E_T_ = '' "
      cSql += " GROUP BY SUBSTRING(SC6.C6_DATFAT,05,02) + '/' + SUBSTRING(SC6.C6_DATFAT,01,04), SC6.C6_PRODUTO, SB1.B1_DESC, SB1.B1_GRUPO"
      cSql += " ORDER BY SC6.C6_PRODUTO, SUBSTRING(SC6.C6_DATFAT,05,02) + '/' + SUBSTRING(SC6.C6_DATFAT,01,04)"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTO", .T., .T. )

      lExiste := .F.

      T_PRODUTO->( DbGoTop() )
     
      WHILE !T_PRODUTO->( EOF() )
   
         lExiste := .F.

         For nContar = 1 to Len(aLista)

             If Alltrim(aLista[nContar,01]) == Alltrim(T_PRODUTO->C6_PRODUTO)
                lExiste := .T.
                Exit
             Endif
          
         Next nContar       

         If lExiste == .F.

            aAdd( aLista, { T_PRODUTO->C6_PRODUTO         ,;
                            T_PRODUTO->B1_DESC            ,;
                            Transform(0, "@E 9999999.99") ,;
                            Transform(0, "@E 9999999.99") ,;
                            Transform(0, "@E 9999999.99") ,;
                            Transform(0, "@E 9999999.99") ,;
                            Transform(0, "@E 9999999.99") ,;
                            Transform(0, "@E 9999999.99") ,;
                            Transform(0, "@E 9999999.99") ,;
                            Transform(0, "@E 9999999.99") ,;
                            Transform(0, "@E 9999999.99") ,;
                            Transform(0, "@E 9999999.99") ,;
                            Transform(0, "@E 9999999.99") ,;
                            Transform(0, "@E 9999999.99") ,;
                            Transform(0, "@E 9999999.99") })
                         
          Endif
                                
          T_PRODUTO->( DbSkip() )

      ENDDO   

      T_PRODUTO->( DbGoTop() )
   
      WHILE !T_PRODUTO->( EOF() )
   
         For nContar = 1 to Len(aLista)
      
             If Alltrim(aLista[nContar,01]) == Alltrim(T_PRODUTO->C6_PRODUTO)
             
                Do Case
                   Case Substr(T_PRODUTO->MES,01,02) == "01"
                        aLista[nContar,03] := Transform(Val(aLista[nContar,03]) + T_PRODUTO->CONSUMO, "@E 9999999.99") 
                   Case Substr(T_PRODUTO->MES,01,02) == "02"
                        aLista[nContar,04] := Transform(Val(aLista[nContar,04]) + T_PRODUTO->CONSUMO, "@E 9999999.99") 
                   Case Substr(T_PRODUTO->MES,01,02) == "03"
                        aLista[nContar,05] := Transform(Val(aLista[nContar,05]) + T_PRODUTO->CONSUMO, "@E 9999999.99") 
                   Case Substr(T_PRODUTO->MES,01,02) == "04"
                        aLista[nContar,06] := Transform(Val(aLista[nContar,06]) + T_PRODUTO->CONSUMO, "@E 9999999.99") 
                   Case Substr(T_PRODUTO->MES,01,02) == "05"
                        aLista[nContar,07] := Transform(Val(aLista[nContar,07]) + T_PRODUTO->CONSUMO, "@E 9999999.99") 
                   Case Substr(T_PRODUTO->MES,01,02) == "06"
                        aLista[nContar,08] := Transform(Val(aLista[nContar,08]) + T_PRODUTO->CONSUMO, "@E 9999999.99") 
                   Case Substr(T_PRODUTO->MES,01,02) == "07"
                        aLista[nContar,09] := Transform(Val(aLista[nContar,09]) + T_PRODUTO->CONSUMO, "@E 9999999.99") 
                   Case Substr(T_PRODUTO->MES,01,02) == "08"
                        aLista[nContar,10] := Transform(Val(aLista[nContar,10]) + T_PRODUTO->CONSUMO, "@E 9999999.99") 
                   Case Substr(T_PRODUTO->MES,01,02) == "09"
                        aLista[nContar,11] := Transform(Val(aLista[nContar,11]) + T_PRODUTO->CONSUMO, "@E 9999999.99") 
                   Case Substr(T_PRODUTO->MES,01,02) == "10"
                        aLista[nContar,12] := Transform(Val(aLista[nContar,12]) + T_PRODUTO->CONSUMO, "@E 9999999.99") 
                   Case Substr(T_PRODUTO->MES,01,02) == "11"
                        aLista[nContar,13] := Transform(Val(aLista[nContar,13]) + T_PRODUTO->CONSUMO, "@E 9999999.99") 
                   Case Substr(T_PRODUTO->MES,01,02) == "12"
                        aLista[nContar,14] := Transform(Val(aLista[nContar,14]) + T_PRODUTO->CONSUMO, "@E 9999999.99") 
                EndCase        

                aLista[nContar,15] := Transform(Val(aLista[nContar,03]) + ;
                                                Val(aLista[nContar,04]) + ;
                                                Val(aLista[nContar,05]) + ;
                                                Val(aLista[nContar,06]) + ;
                                                Val(aLista[nContar,07]) + ;
                                                Val(aLista[nContar,08]) + ;
                                                Val(aLista[nContar,09]) + ;
                                                Val(aLista[nContar,10]) + ;
                                                Val(aLista[nContar,11]) + ;
                                                Val(aLista[nContar,12]) + ;
                                                Val(aLista[nContar,13]) + ;
                                                Val(aLista[nContar,14]), "@E 9999999.99")
                Exit
   
             Endif
          
         Next nContar    
                      
         T_PRODUTO->( DbSkip() )
      
      ENDDO
   
   Endif   

   If Len(aLista) == 0
      MsgAlert("Não existem dados a serem visualizados.")
      aAdd( aLista, { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" } )
   Endif

   If kTipo == 0
      Return(.T.)
   Endif   
    
   oList:SetArray( aLista )

   oList:bLine := {||     {aLista[oList:nAt,01],;
                    	   aLista[oList:nAt,02],;
          				   aLista[oList:nAt,03],;
          				   aLista[oList:nAt,04],;
          				   aLista[oList:nAt,05],;
          				   aLista[oList:nAt,06],;
          				   aLista[oList:nAt,07],;          					             					   
         	        	   aLista[oList:nAt,08],;
         	        	   aLista[oList:nAt,09],;
         	        	   aLista[oList:nAt,10],;
         	        	   aLista[oList:nAt,11],;
         	        	   aLista[oList:nAt,12],;
         	        	   aLista[oList:nAt,13],;
         	        	   aLista[oList:nAt,14],;
         	        	   aLista[oList:nAt,15]}}
Return(.T.)

// #####################################
// Função que gera o resultado em CSV ##
// #####################################
Static Function xGeraPCSV()

   Local aCabExcel   :={}
   Local aItensExcel :={}
   
   // AADD(aCabExcel, {"TITULO DO CAMPO", "TIPO", NTAMANHO, NDECIMAIS})
   AADD(aCabExcel, {"Produto"   , "C", 30, 0 })
   AADD(aCabExcel, {"Descricao" , "C", 60, 0 })
   AADD(aCabExcel, {"Janeio"    , "N", 10,02 })
   AADD(aCabExcel, {"Fevereiro" , "N", 10,02 })
   AADD(aCabExcel, {"Março"     , "N", 10,02 })
   AADD(aCabExcel, {"Abril"     , "N", 10,02 })
   AADD(aCabExcel, {"Maio"      , "N", 10,02 })
   AADD(aCabExcel, {"Junho"     , "N", 10,02 })
   AADD(aCabExcel, {"Julho"     , "N", 10,02 })
   AADD(aCabExcel, {"Agosto"    , "N", 10,02 })
   AADD(aCabExcel, {"Setembro"  , "N", 10,02 })
   AADD(aCabExcel, {"Outubro"   , "N", 10,02 })
   AADD(aCabExcel, {"Novembro"  , "N", 10,02 })
   AADD(aCabExcel, {"Dezembro"  , "N", 10,02 })
   AADD(aCabExcel, {"Total"     , "N", 10,02 })
   AADD(aCabExcel, {" "         , "C", 01,00 })

   MsgRun("Favor Aguardar.....", "Selecionando os Registros", {|| GProcItens(aCabExcel, @aItensExcel)})
   MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel", {||DlgToExcel({{"GETDADOS","CONSUMO DE PRODUTOS REF AO PERÍODO DE " + Dtoc(cDataIni) + " A " + Dtoc(cDataFim), aCabExcel,aItensExcel}})})

Return(.T.)

// ##############################################
// Função que gera o arquivo CSV para gravação ##
// ##############################################
Static Function GProcItens(aHeader, aCols)

   Local nContar
   
   For nContar = 1 to Len(aLista)

       aAdd( aCols, { aLista[nContar,01] ,;
                      aLista[nContar,02] ,;
                      aLista[nContar,03] ,;
                      aLista[nContar,04] ,;
                      aLista[nContar,05] ,;
                      aLista[nContar,06] ,;
                      aLista[nContar,07] ,;
                      aLista[nContar,08] ,;
                      aLista[nContar,09] ,;
                      aLista[nContar,10] ,;
                      aLista[nContar,11] ,;
                      aLista[nContar,12] ,;
                      aLista[nContar,13] ,;
                      aLista[nContar,14] ,;
                      aLista[nContar,15] ,;
                      ""                 })
   Next nContar

Return(.T.)