#Include "Protheus.ch"
#Include "TOTVS.ch"
#include "jpeg.ch"    
#INCLUDE "topconn.ch"    
#INCLUDE "XMLXFUN.CH"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"

// #######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                ##
// ------------------------------------------------------------------------------------ ##
// Referencia: AUTOM527.PRW                                                             ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                          ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                  ##
// Data......: 09/01/2017                                                               ##
// Objetivo..: Programa que verifica as comissões de parceiros                          ##
// #######################################################################################

User Function AUTOM527()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1

   Private aFiliais    := {}
   Private cComboBx1
   Private cDtaInicial := Ctod("  /  /    ")
   Private cDtaFinal   := Ctod("  /  /    ")
   Private cVendedor1  := Space(06)
   Private cVendedor2  := Space(06)
   Private cPedido     := Space(06)
   Private nTotLanc    := 0
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4   
   Private oGet5   
   Private oGet6   

   Private aBrowse := {}

   Private oDlg

   U_AUTOM628("AUTOM527")

   // #################################   
   // Carrega o combobox das filiais ##
   // #################################
   aFiliais := U_AUTOM539(2, cEmpAnt)

   DEFINE MSDIALOG oDlg TITLE "Comissão de Parceiros" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Filial"               Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(073) Say "Data Inicial"         Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(115) Say "Data Final"           Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(157) Say "Vendedor 1"           Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(199) Say "Vendedor 2"           Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(241) Say "Pedido venda"         Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(211),C(006) Say "Total de Lançamentos" Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(046),C(005) ComboBox cComboBx1 Items aFiliais    Size C(063),C(010)                              PIXEL OF oDlg
   @ C(046),C(073) MsGet    oGet1     Var   cDtaInicial Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(115) MsGet    oGet2     Var   cDtaFinal   Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(157) MsGet    oGet3     Var   cVendedor1  Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA3")
   @ C(046),C(199) MsGet    oGet4     Var   cVendedor2  Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA3")
   @ C(046),C(241) MsGet    oGet6     Var   cPedido     Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(210),C(063) MsGet    oGet5     Var   nTotLanc    Size C(030),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(043),C(283) Button   "Pesquisar"                 Size C(031),C(012)                              PIXEL OF oDlg ACTION( PsqComissao() )
   @ C(210),C(420) Button   "Gera TXT"                  Size C(037),C(012)                              PIXEL OF oDlg ACTION( GeraTXT() )
   @ C(210),C(461) Button   "Voltar"                    Size C(037),C(012)                              PIXEL OF oDlg ACTION( oDlg:End() )

   // ###################################
   // Desenha o Grid para visualização ##
   // ###################################
   aAdd( aBrowse, { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })

   oBrowse := TCBrowse():New( 080 , 005, 633, 185,,{'FL'               ,; // 01
                                                    'Data'             ,; // 02
                                                    'Oportunidade'     ,; // 03
                                                    'Proposta'         ,; // 04
                                                    'Orçamento'        ,; // 05
                                                    'Ped.Venda'        ,; // 06
                                                    'N.Fiscal'         ,; // 07
                                                    'Vendedor 1'       ,; // 08
                                                    'Nome'             ,; // 09
                                                    '% Comissão 1 PC'  ,; // 10
                                                    '% Comissão 1 PV'  ,; // 11                                                    
                                                    'Vendedor 2'       ,; // 12
                                                    'Nome'             ,; // 13
                                                    '% Comissao 2 PC'  ,; // 14
                                                    '% Comissao 2 PV'} ,; // 15
                                      {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // ###########################
   // Seta vetor para a browse ##
   // ###########################                           
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
                         aBrowse[oBrowse:nAt,12],;
                         aBrowse[oBrowse:nAt,13],;                         
                         aBrowse[oBrowse:nAt,14],;                         
                         aBrowse[oBrowse:nAt,15]}}

   oBrowse:Refresh()

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ###########################################################
// Função que pesquisa as quilometragem conforme parâmetros ##
// ###########################################################
Static Function PsqComissao()

   Local cSql   := ""
   Local lVolta := .F.

   // #############################################################
   // Gera consistências dos parâmetros para realizar a pesquisa ##
   // #############################################################
   If Substr(cComboBx1,01,02) == "00"
      MsgAlert("Filial de pesquisa não selecionada.")
      Return(.T.)
   Endif
              
   If cDtaInicial == Ctod("  /  /    ")
      MsgAlert("Data inicial de pesquisa não informada.")
      Return(.T.)
   Endif

   If cDtaFinal == Ctod("  /  /    ")
      MsgAlert("Data final de pesquisa não informada.")
      Return(.T.)
   Endif

   // ########################################
   // Pesquisa os dados conforme parâmetros ##
   // ########################################
   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AD1.AD1_FILIAL,"
   cSql += "       AD1.AD1_DTINI ,"
   cSql += "       AD1.AD1_NROPOR,"
   cSql += "       ADY.ADY_PROPOS," 
   cSql += "       SCJ.CJ_NUM    ,"
   cSql += "      (SELECT TOP(1) CK_NUMPV FROM SCK010 WHERE CK_FILIAL = ADY.ADY_FILIAL AND CK_NUMPV <> '' AND CK_PROPOST = ADY.ADY_PROPOS AND D_E_L_E_T_ = '') AS PEDIDO,"
   cSql += "       AD1.AD1_REVISA,"
   cSql += "	   AD1.AD1_VEND  ,"
   cSql += "	  (SELECT A3_NOME FROM SA3010 WHERE A3_COD = AD1.AD1_VEND  AND D_E_L_E_T_ = '') AS VENDEDOR,"
   cSql += "      (SELECT TOP(1) ADZ_COMIS1 FROM ADZ010 WHERE ADZ_PROPOS = ADY.ADY_PROPOS AND ADZ_FILIAL = ADY.ADY_FILIAL AND D_E_L_E_T_ = '') AS COMIS_01,"
   cSql += "	   AD1.AD1_VEND2 ,"
   cSql += "	  (SELECT A3_NOME FROM SA3010 WHERE A3_COD = AD1.AD1_VEND2 AND D_E_L_E_T_ = '') AS PARCEIRO,"
   cSql += "      (SELECT TOP(1) ADZ_COMIS2 FROM ADZ010 WHERE ADZ_PROPOS = ADY.ADY_PROPOS AND ADZ_FILIAL = ADY.ADY_FILIAL AND D_E_L_E_T_ = '') AS COMIS_02 "	   
   cSql += "  FROM " + RetSqlName("AD1") + " AD1 (Nolock), "
   cSql += "       " + RetSqlName("ADY") + " ADY (Nolock), "
   cSql += "       " + RetSqlName("SCJ") + " SCJ (Nolock)  "
   cSql += " WHERE AD1.AD1_FILIAL = '" + Substr(cComboBx1,01,02) + "'"
   cSql += "   AND AD1.D_E_L_E_T_ = ''"
   cSql += "   AND AD1.AD1_VEND  <> ''"
   cSql += "   AND AD1.AD1_VEND2 <> ''"
   cSql += "   AND AD1.AD1_DTINI >= CONVERT(DATETIME,'" + Dtoc(cDtaInicial) + "', 103)"+ CHR(13)
   cSql += "   AND AD1.AD1_DTINI <= CONVERT(DATETIME,'" + Dtoc(cDtaFinal)   + "', 103)"+ CHR(13)
   cSql += "   AND ADY.ADY_FILIAL = AD1.AD1_FILIAL "
   cSql += "   AND ADY.ADY_OPORTU = AD1.AD1_NROPOR "
   cSql += "   AND ADY.D_E_L_E_T_ = ''             "
   cSql += "   AND SCJ.CJ_FILIAL  = ADY.ADY_FILIAL "
   cSql += "   AND SCJ.CJ_PROPOST = ADY.ADY_PROPOS "
   cSql += "   AND SCJ.D_E_L_E_T_ = ''             "
   
   Do Case
      Case !Empty(Alltrim(cVendedor1)) .And. Empty(Alltrim(cVendedor2)) 
           cSql += "   AND AD1.AD1_VEND  = '" + Alltrim(cVendedor1) + "'"
      Case Empty(Alltrim(cVendedor1)) .And. !Empty(Alltrim(cVendedor2)) 
           cSql += "   AND AD1.AD1_VEND2 = '" + Alltrim(cVendedor2) + "'"
      Case !Empty(Alltrim(cVendedor1)) .And. !Empty(Alltrim(cVendedor2)) 
           cSql += "   AND AD1.AD1_VEND  = '" + Alltrim(cVendedor1) + "'"
           cSql += "   AND AD1.AD1_VEND2 = '" + Alltrim(cVendedor2) + "'"
   EndCase   
 
   cSql += " ORDER BY AD1.AD1_FILIAL, AD1.AD1_VEND"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )

   aBrowse  := {}

   nTotLanc := 0

   WHILE !T_CONSULTA->( EOF() )

      If Empty(Alltrim(T_CONSULTA->PEDIDO))
         T_CONSULTA->( DbSkip() )
         Loop
      Endif   

      If Empty(Alltrim(cPedido))
      Else
         If Alltrim(T_CONSULTA->PEDIDO) <> Alltrim(cPedido)
            T_CONSULTA->( DbSkip() )
            Loop
         Endif   
      Endif   

      If Select("T_COMISSAO") > 0
         T_COMISSAO->( dbCloseArea() )
      EndIf

      cSql := ""      
      cSql := "SELECT TOP(1) C6_COMIS1,"
      cSql += "              C6_COMIS2,"
      cSql += "              C6_NOTA   "
      cSql += "  FROM " + RetSqlName("SC6") + " (Nolock) "
      cSql += " WHERE C6_FILIAL  = '" + Alltrim(T_CONSULTA->AD1_FILIAL) + "'"
      cSql += "   AND C6_NUM     = '" + Alltrim(T_CONSULTA->PEDIDO)     + "'"
      cSql += "   AND D_E_L_E_T_ = ''

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMISSAO", .T., .T. )

      xxx_DtaLeitura := Substr(T_CONSULTA->AD1_DTINI,07,02) + "/" + Substr(T_CONSULTA->AD1_DTINI,05,02) + "/" + Substr(T_CONSULTA->AD1_DTINI,01,04)

      nTotLanc := nTotLanc + 1

      aAdd( aBrowse, {T_CONSULTA->AD1_FILIAL ,; // 01  
                      XXX_DTALEITURA         ,; // 02
                      T_CONSULTA->AD1_NROPOR ,; // 03
                      T_CONSULTA->ADY_PROPOS ,; // 04
                      T_CONSULTA->CJ_NUM     ,; // 05
                      T_CONSULTA->PEDIDO     ,; // 06
                      T_COMISSAO->C6_NOTA    ,; // 07
                      T_CONSULTA->AD1_VEND   ,; // 08
                      T_CONSULTA->VENDEDOR   ,; // 09
                      T_CONSULTA->COMIS_01   ,; // 10
                      T_COMISSAO->C6_COMIS1  ,; // 11
                      T_CONSULTA->AD1_VEND2  ,; // 12
                      T_CONSULTA->PARCEIRO   ,; // 13
                      T_CONSULTA->COMIS_02   ,; // 14
                      T_COMISSAO->C6_COMIS2  }) // 15                      

      T_CONSULTA->( DbSkip() )
      
   ENDDO

   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
   Endif
   
   oBrowse:SetArray(aBrowse) 

   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01] ,;
                         aBrowse[oBrowse:nAt,02] ,;
                         aBrowse[oBrowse:nAt,03] ,;
                         aBrowse[oBrowse:nAt,04] ,;
                         aBrowse[oBrowse:nAt,05] ,;
                         aBrowse[oBrowse:nAt,06] ,;
                         aBrowse[oBrowse:nAt,07] ,;
                         aBrowse[oBrowse:nAt,08] ,;
                         aBrowse[oBrowse:nAt,09] ,;
                         aBrowse[oBrowse:nAt,10] ,;
                         aBrowse[oBrowse:nAt,11] ,;                                                  
                         aBrowse[oBrowse:nAt,12] ,;                                                  
                         aBrowse[oBrowse:nAt,13] ,;                                                  
                         aBrowse[oBrowse:nAt,14] ,;                                                                           
                         aBrowse[oBrowse:nAt,15] }}

   oBrowse:Refresh()

   oGet5:refresh()

Return(.T.)

// ###########################################
// Função que gera arquivo txt do resultado ##
// ###########################################
Static Function GeraTXT()

   Local nContar := 0
   Local cString := ""

   If Len(aBrowse) == 0
      MsgAlert("Necessário realizar a pesquisa antes de gerar o arquivo TXT.")
      Return(.T.)
   Endif
   
   cString := ""
   
   For nContar = 1 to len(aBrowse)
  
       cString := cString + aBrowse[nContar,01]            + " " + ;
                            aBrowse[nContar,02]            + " " + ;
                            aBrowse[nContar,03]            + " " + ;
                            aBrowse[nContar,04]            + " " + ;
                            aBrowse[nContar,05]            + " " + ;
                            aBrowse[nContar,06]            + " " + ;
                            aBrowse[nContar,07]            + " " + ;
                            aBrowse[nContar,08]            + " " + ;
                            aBrowse[nContar,09]            + " " + ;
                            Str(aBrowse[nContar,10],06,02) + " " + ;
                            Str(aBrowse[nContar,11],06,02) + " " + ;
                            aBrowse[nContar,12]            + " " + ;
                            aBrowse[nContar,13]            + " " + ;
                            Str(aBrowse[nContar,14],06,02) + " " + ;
                            Str(aBrowse[nContar,15],06,02) + chr(13) + chr(10) 

   Next nContar

   nHdl := fCreate("C:\COMISSOES.TXT")
   fWrite (nHdl, cString ) 
   fClose(nHdl)

   MsgAlert("Arquivo COMISSOES.TXT gerado com sucesso.")
   
Return(.T.)