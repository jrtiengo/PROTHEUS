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
// Referencia: AUTOM640.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Ponto de Entrada  ( ) Gatilho                         ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 29/09/2017                                                              ##
// Objetivo..: Programa que visualiza as notas fiscais de entrada                      ##
// Parâmetros: kProduto - Produto a ser pesquisado na entrada do programa              ##
// ######################################################################################

User Function AUTOM640(kProduto)

   Local lChumba  := .F.
   Local cSql     := ""
   Local cMemo1	  := ""
   Local oMemo1

   Private aEmpresa   := U_AUTOM539(1, "")     
   Private aFiliais   := U_AUTOM539(2, cEmpAnt)
   Private cProduto	  := kProduto
   Private cDescricao := Alltrim(kproduto) + " - " + Alltrim(Posicione( "SB1", 1, xFilial("SB1") + kProduto, "B1_DESC" )) + " " + ;
                                                     Alltrim(Posicione( "SB1", 1, xFilial("SB1") + kProduto, "B1_DAUX" ))
   Private oGet1
   Private cComboBx2
   Private cComboBx3

   DEFINE FONT oFont Name "Courier New" Size 0, 14

   Private aListax := {}

   Private oDlg

   U_AUTOM628("AUTOM598")
   
   // ############################################################################
   // Envia para a função que pesquisa os dados do produto passado no parâmetro ##
   // ############################################################################
   PsqNFiscalPC(0)

   // #############################################
   // Desenha a tela para visualização dos dados ##
   // #############################################
   DEFINE MSDIALOG oDlg TITLE "Nota Fiscais de Entrada" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(000),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(126),C(022) PIXEL NOBORDER OF oDlg

   @ C(025),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(030),C(005) Say "Empresa"                       Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(030),C(082) Say "Filial"                        Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(030),C(160) Say "Descrição do Produto"          Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(039),C(005) ComboBox cComboBx2 Items aEmpresa   Size C(072),C(010)                              PIXEL OF oDlg ON CHANGE ALTERACOMBO()
   @ C(039),C(082) ComboBox cComboBx3 Items aFiliais   Size C(072),C(010)                              PIXEL OF oDlg
   @ C(039),C(160) MsGet    oGet1     Var   cDescricao Size C(295),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(038),C(462) Button "Pesquisar"   Size C(037),C(012) PIXEL OF oDlg ACTION( PsqNFiscalPC(1) )
   @ C(210),C(384) Button "N.Fiscais"  Size C(037),C(012) PIXEL OF oDlg ACTION( xSTSDANFE() ) When !Empty(Alltrim(aListax[1,2]))
   @ C(210),C(423) Button "Exp. Excel" Size C(037),C(012) PIXEL OF oDlg ACTION( xGeraPCSV() ) When !Empty(Alltrim(aListax[1,2]))
   @ C(210),C(462) Button "Voltar"     Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oListax := TCBrowse():New( 070 , 005, 633, 195,,{"Dta Entrada", "Tipo NF", "Documento", "Série", "Código", "Loja", "Fornecedor/Cliente", "Quantidade", "Vlr. Unitário", "Dt. Emissão"},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   If Len(aListax) == 0
      aAdd( aListax, { '', '', '', '', '', '', '', '', '', '' } )
   Endif   

   oListax:SetArray(aListax) 
    
   oListax:bLine := {||{ aListax[oListax:nAt,01],;
                         aListax[oListax:nAt,02],;
                         aListax[oListax:nAt,03],;
                         aListax[oListax:nAt,04],;
                         aListax[oListax:nAt,05],;
                         aListax[oListax:nAt,06],;
                         aListax[oListax:nAt,07],;
                         aListax[oListax:nAt,08],;
                         aListax[oListax:nAt,09],;                         
                         aListax[oListax:nAt,10]}}

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
Static Function PsqNFiscalPC(kTipo)

   MsgRun("Aguarde! Pesquisando Notas Fiscais de Entrada ...", "Nota Fiscais de Entrada",{|| xPsqNFiscalPC(kTipo) })

Return(.T.)

// #############################################################
// Função que pesquisa as notas fiscais de entrada do produto ##
// #############################################################
Static Function xPsqNFiscalPC(kTipo)

   Local cSql := ""

   aListax := {}

   If Select("T_NOTAS") > 0
      T_NOTAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT D1_FILIAL     ,"
   cSql += "       D1_DTDIGIT    ," 
   cSql += "	  (SELECT TOP(1) F1_TIPO FROM SF1010 WHERE F1_FILIAL = SD1.D1_FILIAL AND F1_DOC = SD1.D1_DOC AND D_E_L_E_T_ = '') AS TIPO,"
   cSql += "	   SD1.D1_DOC    ,"
   cSql += "	   SD1.D1_SERIE  ,"
   cSql += "	   SD1.D1_FORNECE,"
   cSql += "	   SD1.D1_LOJA   ,"
   cSql += "	   SA2.A2_NOME   ,"
   cSql += "	   SD1.D1_QUANT  ,"
   cSql += "	   SD1.D1_VUNIT  ,"
   cSql += "	   SD1.D1_EMISSAO "

   If kTipo == 0
      cSql += "  FROM " + RetSqlName("SD1") + " SD1, "
   Else
      cSql += "  FROM SD1" + Substr(cComboBx2,01,02) + "0 SD1, "      
   Endif

   cSql += "       " + RetSqlName("SA2") + " SA2  "

   If kTipo == 0
      cSql += " WHERE SD1.D1_FILIAL  = '" + Alltrim(cFilAnt)  + "'"
   Else
      cSql += " WHERE SD1.D1_FILIAL  = '" + Alltrim(Substr(cComboBx3,01,02))  + "'"      
   Endif

   cSql += "   AND SD1.D1_COD     = '" + Alltrim(cProduto) + "'"
   cSql += "   AND SD1.D_E_L_E_T_ = ''"
   cSql += "   AND (SELECT TOP(1) F1_TIPO FROM SF1010 WHERE F1_FILIAL = SD1.D1_FILIAL AND F1_DOC = SD1.D1_DOC AND D_E_L_E_T_ = '') = 'N'"
   cSql += "   AND SA2.A2_COD     = SD1.D1_FORNECE"
   cSql += "   AND SA2.A2_LOJA    = SD1.D1_LOJA   "
   cSql += "   AND SA2.D_E_L_E_T_ = ''            "
   cSql += " ORDER BY SD1.D1_DTDIGIT DESC         "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTAS", .T., .T. )

   T_NOTAS->( DbGoTop() )
   
   WHILE !T_NOTAS->( EOF() )

      kDigitacao := Substr(T_NOTAS->D1_DTDIGIT,07,02) + "/" + Substr(T_NOTAS->D1_DTDIGIT,05,02) + "/" + Substr(T_NOTAS->D1_DTDIGIT,01,04)
      kEmissao   := Substr(T_NOTAS->D1_EMISSAO,07,02) + "/" + Substr(T_NOTAS->D1_EMISSAO,05,02) + "/" + Substr(T_NOTAS->D1_EMISSAO,01,04)

      aAdd( aListax, { kDigitacao         ,; // 01 
                       T_NOTAS->TIPO      ,; // 02
                       T_NOTAS->D1_DOC    ,; // 03
                       T_NOTAS->D1_SERIE  ,; // 04
                       T_NOTAS->D1_FORNECE,; // 05
                       T_NOTAS->D1_LOJA   ,; // 06
                       T_NOTAS->A2_NOME   ,; // 07
                       T_NOTAS->D1_QUANT  ,; // 08
                       T_NOTAS->D1_VUNIT  ,; // 09
                       kEmissao           }) // 10
                     
       T_NOTAS->( DbSkip() )
       
   ENDDO

   If Len(aListax) == 0
      aAdd( aListax, { "", "", "", "", "", "", "", "", "", "" } )
   Endif

   If kTipo == 0
      Return(.T.)
   Endif   

   oListax:SetArray(aListax) 
    
   oListax:bLine := {||{ aListax[oListax:nAt,01],;
                         aListax[oListax:nAt,02],;
                         aListax[oListax:nAt,03],;
                         aListax[oListax:nAt,04],;
                         aListax[oListax:nAt,05],;
                         aListax[oListax:nAt,06],;
                         aListax[oListax:nAt,07],;
                         aListax[oListax:nAt,08],;
                         aListax[oListax:nAt,09],;                         
                         aListax[oListax:nAt,10]}}

Return(.T.)

// #####################################
// Função que gera o resultado em CSV ##
// #####################################
Static Function xGeraPCSV()

   Local aCabExcel   :={}
   Local aItensExcel :={}

   AADD(aCabExcel, {"Data Entrada"        , "C", 10,  0 })
   AADD(aCabExcel, {"Tipo NF"             , "C", 01,  0 })
   AADD(aCabExcel, {"Documento"           , "C", 10,  0 })
   AADD(aCabExcel, {"Série"               , "C", 03,  0 })
   AADD(aCabExcel, {"Código"              , "C", 40,  0 })
   AADD(aCabExcel, {"Loja"                , "C", 40,  0 })
   AADD(aCabExcel, {"Forneceodor/Cliente" , "C", 40,  0 })
   AADD(aCabExcel, {"Quantdiade"          , "N", 10, 02 })
   AADD(aCabExcel, {"Prc.Unitário"        , "N", 10, 02 })
   AADD(aCabExcel, {"Data Emissão"        , "C", 10,  0 })
   AADD(aCabExcel, {" "                   , "C", 01,  0 })

   MsgRun("Favor Aguardar.....", "Selecionando os Registros", {|| GProcItens(aCabExcel, @aItensExcel)})
   MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel", {||DlgToExcel({{"GETDADOS","NOTAS FISCAIS DE ENTRADA DO PRODUTO: " + Alltrim(cDescricao) , aCabExcel,aItensExcel}})})

Return(.T.)

// ##############################################
// Função que gera o arquivo CSV para gravação ##
// ##############################################
Static Function GProcItens(aHeader, aCols)

   Local nContar
   
   For nContar = 1 to Len(aListax)

       aAdd( aCols, { aListax[nContar,01] ,;
                      aListax[nContar,02] ,;
                      aListax[nContar,03] ,;
                      aListax[nContar,04] ,;
                      aListax[nContar,05] ,;
                      aListax[nContar,06] ,;
                      aListax[nContar,07] ,;
                      aListax[nContar,08] ,;
                      aListax[nContar,09] ,;                      
                      aListax[nContar,10] ,;
                      ""                  })
   Next nContar

Return(.T.)

// ######################################################################
// Função que mostra o documento de entrada da nota fiscal selecionada ##
// ######################################################################
Static Function xSTSDANFE()

   MsgRun("Aguarde! Abrindo Documento de Entrada ...", "Documento de Entrada",{|| ySTSDANFE() })

Return(.T.)

// ######################################################################
// Função que mostra o documento de entrada da nota fiscal selecionada ##
// ######################################################################
Static Function ySTSDANFE()

   Local xEmpresa := cEmpAnt
   Local xFilial  := cFilAnt

   cEmpAnt := Substr(cComboBx2,01,02)
   cFilAnt := Substr(cComboBx3,01,02)   

   // #################################################
   // Posiiona o cabeçalho da nota fiscal de entrada ##
   // #################################################
   dbSelectArea("SF1")
   dbSetOrder(1)
   If dbSeek(Substr(cComboBx3,01,02) + aListax[oListax:nAt,03] + aListax[oListax:nAt,04] + aListax[oListax:nAt,05] + aListax[oListax:nAt,06] + aListax[oListax:nAt,02])
      dbSelectArea("SD1")
      dbSetOrder(1)  
      dbSeek(Substr(cComboBx3,01,02) + aListax[oListax:nAt,03] + aListax[oListax:nAt,04] + aListax[oListax:nAt,05] + aListax[oListax:nAt,06])
      A103NFiscal("SF1",,2)
   Endif

   cEmpAnt := xEmpresa
   cFilAnt := cFilial
   
Return(.T.)