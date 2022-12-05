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
// Referencia: AUTOM639.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                         ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 29/09/2017                                                              ##
// Objetivo..: Programa que visualiza os últimos pedidos de compra de produtos         ##
// Parâmetros: kProduto - Prodto a ser pesquisado na entrada do programa               ##
// ######################################################################################

User Function AUTOM639(kProduto)

   Local lChumba := .F.
   Local cSql    := ""
   Local cMemo1	 := ""
   Local oMemo1

   Private aEmpresa   := U_AUTOM539(1, "")     
   Private aFiliais   := U_AUTOM539(2, cEmpAnt)
   Private cProduto	  := kProduto
   Private cDescricao := Alltrim(kproduto) + " - " + Alltrim(Posicione( "SB1", 1, xFilial("SB1") + kProduto, "B1_DESC" )) + " " + ;
                                                     Alltrim(Posicione( "SB1", 1, xFilial("SB1") + kProduto, "B1_DAUX" ))

   Private oGet1
   Private cComboBx2
   Private cComboBx3

   // ######################
   // Declara as Legendas ##
   // ######################
   Private oVerde    := LoadBitmap(GetResources(),'br_verde')
   Private oVermelho := LoadBitmap(GetResources(),'br_vermelho')
   Private oAzul     := LoadBitmap(GetResources(),'br_azul')
   Private oAmarelo  := LoadBitmap(GetResources(),'br_amarelo')
   Private oPreto    := LoadBitmap(GetResources(),'br_preto')
   Private oLaranja  := LoadBitmap(GetResources(),'br_laranja')
   Private oCinza    := LoadBitmap(GetResources(),'br_cinza')
   Private oBranco   := LoadBitmap(GetResources(),'br_branco')
   Private oPink     := LoadBitmap(GetResources(),'br_pink')
   Private oCancel   := LoadBitmap(GetResources(),'br_cancel')
   Private oEncerra  := LoadBitmap(GetResources(),'br_marrom')

   DEFINE FONT oFont Name "Courier New" Size 0, 14

   Private aListax := {}

   Private oDlg

   U_AUTOM628("AUTOM598")
   
   // ############################################################################
   // Envia para a função que pesquisa os dados do produto passado no parâmetro ##
   // ############################################################################
   PsqUltimostPC(0)

   // #############################################
   // Desenha a tela para visualização dos dados ##
   // #############################################
   DEFINE MSDIALOG oDlg TITLE "Últimos Pedidos de Compra" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(000),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(126),C(022) PIXEL NOBORDER OF oDlg
   @ C(211),C(005) Jpeg FILE "br_verde.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(211),C(075) Jpeg FILE "br_amarelo.png"  Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(211),C(162) Jpeg FILE "br_vermelho.png" Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(025),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(030),C(005) Say "Empresa"                       Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(030),C(082) Say "Filial"                        Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(030),C(160) Say "Descrição do Produto"          Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(211),C(017) Say "Pedidos Abertos Total"         Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(211),C(087) Say "Pedidos Abertos Parcialmente"  Size C(072),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(211),C(174) Say "Pedidos Encerrados"            Size C(049),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(039),C(005) ComboBox cComboBx2 Items aEmpresa   Size C(072),C(010)                              PIXEL OF oDlg  ON CHANGE ALTERACOMBO()
   @ C(039),C(082) ComboBox cComboBx3 Items aFiliais   Size C(072),C(010)                              PIXEL OF oDlg
   @ C(039),C(160) MsGet    oGet1     Var   cDescricao Size C(295),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(038),C(462) Button "Pesquisar"   Size C(037),C(012) PIXEL OF oDlg ACTION( PsqUltimostPC(1) )
   @ C(210),C(384) Button "Ped. Compra" Size C(037),C(012) PIXEL OF oDlg ACTION( U_AUTR001(aListax[oListax:nAt,02], Substr(cComboBx2,01,02) + "|" + Substr(cComboBx3,01,02) + "|" ) ) When !Empty(Alltrim(aListax[1,2]))
   @ C(210),C(423) Button "Exp. Excel"  Size C(037),C(012) PIXEL OF oDlg ACTION( xGeraPCSV() )                        When !Empty(Alltrim(aListax[1,2]))
   @ C(210),C(462) Button "Voltar"      Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oListax := TCBrowse():New( 070 , 005, 633, 195,,{"LG", "Pedido", "Item", "Código", "Loja", "Fornecedor", "Quantidade", "Prc.Unitário", "Qtd Entregue", "Resíduo Eliminado", "Cond. Pgtº", "Descrição Cond. Pgtº", "Data Previsão Entrega"},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   If Len(aListax) == 0
      aAdd( aListax, { '1', '', '', '', '', '', '', '', '', '', '', '', '' } )
   Endif   

   oListax:SetArray(aListax) 
    
   oListax:bLine := {||{ If(Alltrim(aListax[oListax:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aListax[oListax:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aListax[oListax:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(aListax[oListax:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aListax[oListax:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aListax[oListax:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aListax[oListax:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aListax[oListax:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(aListax[oListax:nAt,01]) == "9", oEncerra, ""))))))))),;                         
                         aListax[oListax:nAt,02]               ,;
                         aListax[oListax:nAt,03]               ,;
                         aListax[oListax:nAt,04]               ,;                         
                         aListax[oListax:nAt,05]               ,;
                         aListax[oListax:nAt,06]               ,;
                         aListax[oListax:nAt,07]               ,;
                         aListax[oListax:nAt,08]               ,;
                         aListax[oListax:nAt,09]               ,;
                         aListax[oListax:nAt,10]               ,;
                         aListax[oListax:nAt,11]               ,;                                                                           
                         aListax[oListax:nAt,12]               ,;                                                                           
                         aListax[oListax:nAt,13]               }}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #######################################################################
// Função que carrega o combo de filiais conforme a empresa selecionada ##
// #######################################################################
Static Function AlteraCombo

   aFiliais := U_AUTOM539(2, Substr(cComboBx2,01,02) )
   @ C(039),C(082) ComboBox cComboBx3 Items aFiliais Size C(072),C(010) PIXEL OF oDlg

Return(.T.)

// ##########################################################
// Função que pesquisa os pedidos de compra para o produto ##
// ##########################################################
Static Function PsqUltimostPC(kTipo)

   MsgRun("Aguarde! Pesquisando pedidos de compra para o produto ...", "Pedidos de Compra",{|| xPsqUltimostPC(kTipo) })

Return(.T.)

// ##########################################################
// Função que pesquisa os pedidos de compra para o produto ##
// ##########################################################
Static Function xPsqUltimostPC(kTipo)

   Local cSql := ""

   aListax := {}

   If Select("T_PEDIDOS") > 0
      T_PEDIDOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC7.C7_FILIAL ," + Chr(13)
   cSql += "       SC7.C7_NUM    ," + Chr(13)
   cSql += "	   SC7.C7_ITEM   ," + Chr(13)
   cSql += "       SC7.C7_FORNECE," + Chr(13)
   cSql	+= "       SC7.C7_LOJA   ," + Chr(13)
   cSql	+= "       SA2.A2_NOME   ," + Chr(13)
   cSql	+= "       SC7.C7_QUANT  ," + Chr(13)
   cSql	+= "       SC7.C7_PRECO  ," + Chr(13)
   cSql	+= "       SC7.C7_QUJE   ," + Chr(13)
   cSql	+= "       SC7.C7_RESIDUO," + Chr(13)
   cSql	+= "       SC7.C7_COND   ," + Chr(13)
   cSql	+= "       SE4.E4_DESCRI ," + Chr(13)
   cSql	+= "       SC7.C7_DATPRF  " + Chr(13)

   If kTipo == 0
      cSql += "  FROM " + RetSqlName("SC7") + " SC7, " + Chr(13)
   Else
      cSql += "  FROM SC7" + Substr(cComboBx2,01,02) + "0 SC7, " + Chr(13)
   Endif
      
   cSql += "       " + RetSqlName("SA2") + " SA2, " + Chr(13)
   cSql	+= "       " + RetSqlName("SE4") + " SE4  " + Chr(13)

   If kTipo == 0
      cSql += " WHERE SC7.C7_FILIAL  = '" + Alltrim(cFilAnt) + "'" + Chr(13)
   Else   
      cSql += " WHERE SC7.C7_FILIAL  = '" + Alltrim(Substr(cComboBx3,01,02))  + "'" + Chr(13)
   Endif   

   cSql += "   AND SC7.C7_PRODUTO = '" + Alltrim(cProduto) + "'" + Chr(13)
   cSql += "   AND SC7.D_E_L_E_T_ = ''            " + Chr(13)
   cSql += "   AND SA2.A2_COD     = SC7.C7_FORNECE" + Chr(13)
   cSql += "   AND SA2.A2_LOJA    = SC7.C7_LOJA   " + Chr(13)
   cSql += "   AND SA2.D_E_L_E_T_ = ''            " + Chr(13)
   cSql += "   AND SE4.E4_CODIGO  = SC7.C7_COND   " + Chr(13)
   cSql += "   AND SE4.D_E_L_E_T_ = ''            " + Chr(13)
   cSql += " ORDER BY SC7.C7_NUM DESC             " + Chr(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDOS", .T., .T. )

   T_PEDIDOS->( DbGoTop() )
   
   WHILE !T_PEDIDOS->( EOF() )

      kEntrega := Substr(T_PEDIDOS->C7_DATPRF,07,02) + "/" + Substr(T_PEDIDOS->C7_DATPRF,05,02) + "/" + Substr(T_PEDIDOS->C7_DATPRF,01,04)

      Do CAse

         Case T_PEDIDOS->C7_QUJE == 0
              kLegenda := "2"

         Case T_PEDIDOS->C7_QUJE >= T_PEDIDOS->C7_QUANT
              kLegenda := "8"

         Case T_PEDIDOS->C7_QUJE < T_PEDIDOS->C7_QUANT
              kLegenda := "4"

      EndCase

      aAdd( aListax, {kLegenda             ,; // 01
                     T_PEDIDOS->C7_NUM    ,; // 02
                     T_PEDIDOS->C7_ITEM   ,; // 03
                     T_PEDIDOS->C7_FORNECE,; // 04
                     T_PEDIDOS->C7_LOJA   ,; // 05    
                     T_PEDIDOS->A2_NOME   ,; // 06
                     T_PEDIDOS->C7_QUANT  ,; // 07
                     T_PEDIDOS->C7_PRECO  ,; // 08
                     T_PEDIDOS->C7_QUJE   ,; // 09
                     T_PEDIDOS->C7_RESIDUO,; // 10
                     T_PEDIDOS->C7_COND   ,; // 11
                     T_PEDIDOS->E4_DESCRI ,; // 12
                     kEntrega             }) // 13
                     
       T_PEDIDOS->( DbSkip() )
       
   ENDDO

   If Len(aListax) == 0
      aAdd( aListax, { "7", "", "", "", "", "", "", "", "", "", "", "", "" } )
   Endif

   If kTipo == 0
      Return(.T.)
   Endif

   oListax:SetArray(aListax) 
    
   oListax:bLine := {||{ If(Alltrim(aListax[oListax:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aListax[oListax:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aListax[oListax:nAt,01]) == "3", oPink    ,;                         
                         If(Alltrim(aListax[oListax:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aListax[oListax:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aListax[oListax:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aListax[oListax:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aListax[oListax:nAt,01]) == "8", oVermelho,;
                         If(Alltrim(aListax[oListax:nAt,01]) == "9", oEncerra, ""))))))))),;                         
                         aListax[oListax:nAt,02]               ,;
                         aListax[oListax:nAt,03]               ,;
                         aListax[oListax:nAt,04]               ,;                         
                         aListax[oListax:nAt,05]               ,;
                         aListax[oListax:nAt,06]               ,;
                         aListax[oListax:nAt,07]               ,;
                         aListax[oListax:nAt,08]               ,;
                         aListax[oListax:nAt,09]               ,;
                         aListax[oListax:nAt,10]               ,;
                         aListax[oListax:nAt,11]               ,;                                                                           
                         aListax[oListax:nAt,12]               ,;                                                                           
                         aListax[oListax:nAt,13]               }}
      
Return(.T.)

// #####################################
// Função que gera o resultado em CSV ##
// #####################################
Static Function xGeraPCSV()

   Local aCabExcel   :={}
   Local aItensExcel :={}
   
   AADD(aCabExcel, {"Legenda"                  , "C", 01,  0 })
   AADD(aCabExcel, {"Item"                     , "C", 04,  0 })
   AADD(aCabExcel, {"Código"                   , "C", 06,  0 })
   AADD(aCabExcel, {"Loja"                     , "C", 03,  0 })
   AADD(aCabExcel, {"Fornecedor"               , "C", 40,  0 })
   AADD(aCabExcel, {"Quantdiade"               , "N", 10, 02 })
   AADD(aCabExcel, {"Prc.Unitário"             , "N", 10, 02 })
   AADD(aCabExcel, {"Qtd Entregue"             , "N", 10, 02 })
   AADD(aCabExcel, {"Resíduo Eliminado"        , "C", 01,  0 })
   AADD(aCabExcel, {"Cond.Pgtº"                , "C", 03,  0 })
   AADD(aCabExcel, {"Descrição Condição Pgtº"  , "C", 40,  0 })
   AADD(aCabExcel, {"Data Prev. Entrega"       , "C", 10,  0 })
   AADD(aCabExcel, {" "                        , "C", 01,  0 })

   MsgRun("Favor Aguardar.....", "Selecionando os Registros", {|| GProcItens(aCabExcel, @aItensExcel)})
   MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel", {||DlgToExcel({{"GETDADOS","PEDIDOS DE COMPRA DO PRODUTO: " + Alltrim(cDescricao) , aCabExcel,aItensExcel}})})

Return(.T.)

// ##############################################
// Função que gera o arquivo CSV para gravação ##
// ##############################################
Static Function GProcItens(aHeader, aCols)

   Local nContar
   
   For nContar = 1 to Len(aListax)

       If aListax[nContar,01] == "2"
          kLegenda := "A"
       Else
          kLegenda := "F"          
       Endif   

       aAdd( aCols, { kLegenda            ,;
                      aListax[nContar,02] ,;
                      aListax[nContar,03] ,;
                      aListax[nContar,04] ,;
                      aListax[nContar,05] ,;
                      aListax[nContar,06] ,;
                      aListax[nContar,07] ,;
                      aListax[nContar,08] ,;
                      aListax[nContar,09] ,;
                      aListax[nContar,10] ,;
                      aListax[nContar,11] ,;
                      aListax[nContar,12] ,;
                      aListax[nContar,13] ,;
                      ""                 })
   Next nContar

Return(.T.)