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
// Referencia: AUTOM528.PRW                                                             ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                          ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                  ##
// Data......: 11/01/2017                                                               ##
// Objetivo..: Programa que gera informações sobre venda com Cartões                    ##
// #######################################################################################

User Function AUTOM528()

   Local cSql    := ""
// Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1

   Private aEmpresas   := {"00 - Selecione", "TT - Todas as Empresas", "01 - Automatech", "02 - TI Automação", "03 - Atech"}
   Private aFiliais    := {"00 - Selecione", "TT - Todas as Filiais" , "01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos", "05 - São Paulo", "CC - Curitiba", "AA - Atech"}
   Private cDtaInicial := Ctod("  /  /    ")
   Private cDtaFinal   := Ctod("  /  /    ")
   Private aAdministra := {}
   Private aBandeiras  := {}
   Private aCondicoes  := {}

   Private cComboBx1 
   Private cComboBx2 
   Private cComboBx3 
   Private cComboBx4 
   Private cComboBx5 
   Private oGet1     
   Private oGet2     

   Private aBrowse := {}

   Private oDlg

   // ################################################
   // Carrega o combo de Administradoras de Cartões ##
   // ################################################
   If Select("T_ADMINISTRA") > 0
      T_ADMINISTRA->( dbCloseArea() )
   EndIf

   cSql := "SELECT SAE.AE_FILIAL,"
   cSql += "       SAE.AE_COD   ,"
   cSql += "       SAE.AE_DESC   "
   cSql += "     FROM " + RetSqlName("SAE") + " SAE "
   cSql += "    WHERE SAE.AE_FILIAL  = '" + Alltrim(xFilial("SC9")) + "'"
   cSql += "      AND SAE.D_E_L_E_T_ = ''"
   cSql += "    ORDER BY SAE.AE_DESC     "
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ADMINISTRA", .T., .T. )
   
   T_ADMINISTRA->( DbGoTop() )
   
   aAdd( aAdministra, "000000 - Totas as Administradoras" )

   WHILE !T_ADMINISTRA->(EOF())
      aAdd( aAdministra, T_ADMINISTRA->AE_COD + " - " + Alltrim(T_ADMINISTRA->AE_DESC) )
      T_ADMINISTRA->( DbSkip() )
   ENDDO
       
   // #####################################################
   // Carrega o combo de Bandeiras de Cartões de Crédito ##
   // #####################################################     
   If Select("T_BANDEIRAS") > 0
      T_BANDEIRAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT X5_CHAVE,"
   cSql += "       X5_DESCRI" 
   cSql += "  FROM " + RetSqlName("SX5")
   cSql += " WHERE X5_TABELA  = 'G3'"
   cSql += "   AND D_E_L_E_T_ = ''  "
   cSql += " ORDER BY X5_DESCRI     "
                                
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BANDEIRAS", .T., .T. )

   T_BANDEIRAS->( DbGoTop() )
   
   aAdd( aBandeiras, "000000 - Todas as Bandeiras" )

   WHILE !T_BANDEIRAS->(EOF())
      aAdd( aBandeiras, T_BANDEIRAS->X5_CHAVE + " - " + Alltrim(T_BANDEIRAS->X5_DESCRI) )
      T_BANDEIRAS->( DbSkip() )
   ENDDO

   // ############################################
   // Carrega o combo de Condições de Pagamento ##
   // ############################################
   If Select("T_CONDICAO") > 0
      T_CONDICAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT E4_CODIGO,"
   cSql += "       E4_DESCRI "
   cSql += "  FROM " + RetSqlName("SE4") + " (Nolock)"
   cSql += " WHERE E4_DESCRI LIKE '%CARTAO%'"
   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += " ORDER BY E4_CODIGO"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONDICAO", .T., .T. )

   T_CONDICAO->( DbGoTop() )
   
   aAdd( aCondicoes, "000000 - Todas as Condições de Pagamentos" )

   WHILE !T_CONDICAO->(EOF())
      aAdd( aCondicoes, T_CONDICAO->E4_CODIGO + " - " + Alltrim(T_CONDICAO->E4_DESCRI) )
      T_CONDICAO->( DbSkip() )
   ENDDO

   // ##############################
   // Desneha a tela para display ##
   // ##############################
   DEFINE MSDIALOG oDlg TITLE "Informações de Vendas em Cartões" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Empresa"        Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(069) Say "Filiais"        Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(132) Say "Data Inicial"   Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(174) Say "Data Final"     Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(216) Say "Administradora" Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(293) Say "Bandeiras"      Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(370) Say "Cond.Pagtº"     Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(046),C(005) ComboBox cComboBx1 Items aEmpresas   Size C(058),C(010)                              PIXEL OF oDlg
   @ C(046),C(069) ComboBox cComboBx2 Items aFiliais    Size C(058),C(010)                              PIXEL OF oDlg
   @ C(046),C(132) MsGet    oGet1     Var   cDtaInicial Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(174) MsGet    oGet2     Var   cDtaFinal   Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(216) ComboBox cComboBx3 Items aAdministra Size C(072),C(010)                              PIXEL OF oDlg
   @ C(046),C(293) ComboBox cComboBx4 Items aBandeiras  Size C(072),C(010)                              PIXEL OF oDlg
   @ C(046),C(370) ComboBox cComboBx5 Items aCondicoes  Size C(072),C(010)                              PIXEL OF oDlg

   @ C(043),C(447) Button "Pesquisar"                   Size C(031),C(012)                              PIXEL OF oDlg ACTION( CrgLancGrid() )

   @ C(210),C(420) Button   "Gera TXT"                  Size C(037),C(012)                              PIXEL OF oDlg ACTION( GERAARQTXT() )
   @ C(210),C(461) Button   "Voltar"                    Size C(037),C(012)                              PIXEL OF oDlg ACTION( oDlg:End() )

   // ###################################
   // Desenha o Grid para visualização ##
   // ###################################
   aAdd( aBrowse, { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })

   oBrowse := TCBrowse():New( 080 , 005, 633, 185,,{'Empresa'                ,; // 01
                                                    'Filial'                 ,; // 02
                                                    'Dta Venda'              ,; // 03
                                                    'Nº NF'                  ,; // 04
                                                    'Série'                  ,; // 05
                                                    'Cliente'                ,; // 06
                                                    'Loja'                   ,; // 07
                                                    'Descrição dos Clientes' ,; // 08
                                                    'Cond. Pgtº'             ,; // 09
                                                    'Descrição Cond.Pagtº'   ,; // 10
                                                    'Qtd Parcelas'           ,; // 11
                                                    'Valor da Venda'         ,; // 12                                                    
                                                    'Administradora'         ,; // 13
                                                    'Bandeira'               ,; // 14
                                                    'Ult 4 Dígitos'          ,; // 15
                                                    'Dt.Emissão'             ,; // 16
                                                    'Documento'              ,; // 17
                                                    'Autorização'            ,; // 18
                                                    'NSU/TID'       }        ,; // 19
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
                         aBrowse[oBrowse:nAt,15],;                         
                         aBrowse[oBrowse:nAt,16],;                         
                         aBrowse[oBrowse:nAt,17],;                         
                         aBrowse[oBrowse:nAt,18],;                         
                         aBrowse[oBrowse:nAt,19]}}

   oBrowse:Refresh()

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #######################################################
// Função que pesquisa as comissões conforme parâmetros ##
// #######################################################
/*
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
      aAdd( aBrowse, { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
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
*/


// ###########################################
// Função que gera arquivo txt do resultado ##
// ###########################################
/*
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
*/

// ########################################################
// Função que carrega o grid conforme parâmetros setados ##
// ########################################################
Static Function CrgLancGrid()

   MsgRun("Favor Aguarde! Pesquisando informações de vendas ...", "Venda com Cartões",{|| xCrgLancGrid() })

Return(.T.)

// ########################################################
// Função que carrega o grid conforme parâmetros setados ##
// ########################################################
Static Function xCrgLancGrid()

   If Empty(cDtaInicial)
      MsgAlert("Data inicial de pesquisa não informada.")
      Return(.T.)
   Endif

   If Empty(cDtaFinal)
      MsgAlert("Data final de pesquisa não informada.")
      Return(.T.)
   Endif

   aBrowse := {}

   // ################################################
   // Pesquisa dados conforme parâmetros informados ##
   // ################################################
   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   If Substr(cComboBx1,01,02) <> "TT"

      cSql := ""
      cSql := "SELECT SF2.F2_FILIAL ,"
      cSql += "       '01' AS EMPRESA,"
      cSql += "       SF2.F2_EMISSAO,"
      cSql += "       SF2.F2_DOC    ,"
      cSql += "       SF2.F2_SERIE  ,"
      cSql += "       SF2.F2_CLIENTE,"
      cSql += "       SF2.F2_LOJA   ,"
      cSql += "       SA1.A1_NOME   ,"
      cSql += "       SF2.F2_COND   ,"
      cSql += "       SE4.E4_DESCRI ,"
      cSql += "       SE4.E4_COND   ,"
      cSql += "       SF2.F2_VALBRUT,"
      cSql += "       (SELECT TOP(1) C5_ADM "
      cSql += "          FROM " + RetSqlName("SC5" + Substr(cComboBx1,01,02) + "0") + " (Nolock) " 
      cSql += "         WHERE C5_FILIAL = SF2.F2_FILIAL"
      cSql += "	     AND C5_NUM    = (SELECT TOP(1) C6_NUM "
      cSql += "                            FROM " + RetSqlName("SC6" + Substr(cComboBx1,01,02) + "0") + " (Nolock) " 
      cSql += "	                       WHERE C6_FILIAL = SF2.F2_FILIAL "
      cSql += "	                         AND C6_NOTA   = SF2.F2_DOC    "
      cSql += "	                         AND C6_SERIE  = SF2.F2_SERIE  "
      cSql += "	                         AND D_E_L_E_T_ = '')) AS ADMINISTRADORA,"
      cSql += "        (SELECT TOP(1) C5_BAND "
      cSql += "           FROM " + RetSqlName("SC5" + Substr(cComboBx1,01,02) + "0") + " (Nolock) " 
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL"
      cSql += "	     AND C5_NUM    = (SELECT TOP(1) C6_NUM "
      cSql += "                            FROM " + RetSqlName("SC6" + Substr(cComboBx1,01,02) + "0") + " (Nolock) " 
      cSql += "	                       WHERE C6_FILIAL = SF2.F2_FILIAL "
      cSql += "	                         AND C6_NOTA   = SF2.F2_DOC    "
      cSql += "	                         AND C6_SERIE  = SF2.F2_SERIE  "
      cSql += "	                         AND D_E_L_E_T_ = '')) AS BANDEIRA,"
      cSql += "        (SELECT TOP(1) C5_CARTAO "
      cSql += "           FROM " + RetSqlName("SC5" + Substr(cComboBx1,01,02) + "0") + " (Nolock) " 
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL"
      cSql += "	     AND C5_NUM    = (SELECT TOP(1) C6_NUM "
      cSql += "                            FROM " + RetSqlName("SC6" + Substr(cComboBx1,01,02) + "0") + " (Nolock) " 
      cSql += "	                       WHERE C6_FILIAL = SF2.F2_FILIAL "
      cSql += "	                         AND C6_NOTA   = SF2.F2_DOC    "
      cSql += "	                         AND C6_SERIE  = SF2.F2_SERIE  "
      cSql += "	                         AND D_E_L_E_T_ = '')) AS CARTAO,"
      cSql += "        (SELECT TOP(1) C5_DATCART "
      cSql += "           FROM " + RetSqlName("SC5" + Substr(cComboBx1,01,02) + "0") + " (Nolock) " 
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL"
      cSql += "	           AND C5_NUM    = (SELECT TOP(1) C6_NUM "
      cSql += "                               FROM " + RetSqlName("SC6" + Substr(cComboBx1,01,02) + "0") + " (Nolock) " 
      cSql += "	                             WHERE C6_FILIAL = SF2.F2_FILIAL "
      cSql += "	                               AND C6_NOTA   = SF2.F2_DOC    "
      cSql += "	                               AND C6_SERIE  = SF2.F2_SERIE  "
      cSql += "	                               AND D_E_L_E_T_ = '')) AS DTAEMISSAO,"
      cSql += "        (SELECT TOP(1) C5_ZVALCRT "
      cSql += "           FROM " + RetSqlName("SC5" + Substr(cComboBx1,01,02) + "0") + " (Nolock) " 
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL"
      cSql += "	           AND C5_NUM    = (SELECT TOP(1) C6_NUM "
      cSql += "                               FROM " + RetSqlName("SC6" + Substr(cComboBx1,01,02) + "0") + " (Nolock) " 
      cSql += "	                             WHERE C6_FILIAL = SF2.F2_FILIAL "
      cSql += "	                               AND C6_NOTA   = SF2.F2_DOC    "
      cSql += "	                               AND C6_SERIE  = SF2.F2_SERIE  "
      cSql += "	                               AND D_E_L_E_T_ = '')) AS VALORVDA,"
      cSql += "        (SELECT TOP(1) C5_DOC "
      cSql += "           FROM " + RetSqlName("SC5" + Substr(cComboBx1,01,02) + "0") + " (Nolock) " 
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL"
      cSql += "	     AND C5_NUM    = (SELECT TOP(1) C6_NUM "
      cSql += "                            FROM " + RetSqlName("SC6" + Substr(cComboBx1,01,02) + "0") + " (Nolock) " 
      cSql += "	                       WHERE C6_FILIAL = SF2.F2_FILIAL "
      cSql += "	                         AND C6_NOTA   = SF2.F2_DOC    "
      cSql += "	                         AND C6_SERIE  = SF2.F2_SERIE  "
      cSql += "	                         AND D_E_L_E_T_ = '')) AS DOCUMENTO,"
      cSql += "        (SELECT TOP(1) C5_AUTORIZ "
      cSql += "           FROM " + RetSqlName("SC5" + Substr(cComboBx1,01,02) + "0") + " (Nolock) " 
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL"
      cSql += "	     AND C5_NUM    = (SELECT TOP(1) C6_NUM "
      cSql += "                            FROM " + RetSqlName("SC6" + Substr(cComboBx1,01,02) + "0") + " (Nolock) " 
      cSql += "	                       WHERE C6_FILIAL = SF2.F2_FILIAL "
      cSql += "	                         AND C6_NOTA   = SF2.F2_DOC    "
      cSql += "	                         AND C6_SERIE  = SF2.F2_SERIE  "
      cSql += "	                         AND D_E_L_E_T_ = '')) AS AUTORIZACAO,"
      cSql += "        (SELECT TOP(1) C5_TID "
      cSql += "           FROM " + RetSqlName("SC5" + Substr(cComboBx1,01,02) + "0") + " (Nolock) " 
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL"
      cSql += "	         AND C5_NUM    = (SELECT TOP(1) C6_NUM "
      cSql += "                             FROM " + RetSqlName("SC6" + Substr(cComboBx1,01,02) + "0") + " (Nolock) " 
      cSql += "	                           WHERE C6_FILIAL = SF2.F2_FILIAL "
      cSql += "	                             AND C6_NOTA   = SF2.F2_DOC    "
      cSql += "	                             AND C6_SERIE  = SF2.F2_SERIE  "
      cSql += "	                             AND D_E_L_E_T_ = '')) AS NSUTID"
      cSql += "     FROM " + RetSqlName("SF2" + Substr(cComboBx1,01,02) + "0") + " (Nolock) SF2," 
      cSql += "          " + RetSqlName("SA1") + " (Nolock) " + " SA1, "
      cSql += "    	  " + RetSqlName("SE4") + " (Nolock) " + " SE4  "
      cSql += "    WHERE SF2.F2_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(cDtaInicial) + "', 103)"
      cSql += "      AND SF2.F2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(cDtaFinal)   + "', 103)"
      cSql += "      AND SF2.D_E_L_E_T_  = ''"

      Do Case
         Case Substr(cComboBx2,01,02) == "CC"
              cSql += " AND SF2.F2_FILIAL = '01'"
         Case Substr(cComboBx2,01,02) == "AA"
              cSql += " AND SF2.F2_FILIAL = '01'"
         OtherWise
              cSql += " AND SF2.F2_FILIAL = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
      EndCase        

      cSql += "      AND SA1.A1_COD      = SF2.F2_CLIENTE"
      cSql += "      AND SA1.A1_LOJA     = SF2.F2_LOJA   "
      cSql += "      AND SA1.D_E_L_E_T_  = ''            "
      cSql += "      AND SE4.E4_CODIGO   = SF2.F2_COND   "
      cSql += "      AND SE4.D_E_L_E_T_  = ''            "
      cSql += "    ORDER BY SF2.F2_FILIAL, SF2.F2_EMISSAO, SF2.F2_DOC, SF2.F2_SERIE"
           
   Else
   
      cSql := ""
      cSql := "SELECT SF2.F2_FILIAL ," + chr(13)
      cSql += "       '01' AS EMPRESA," + chr(13)
      cSql += "       SF2.F2_EMISSAO," + chr(13)
      cSql += "       SF2.F2_DOC    ," + chr(13)
      cSql += "       SF2.F2_SERIE  ," + chr(13)
      cSql += "       SF2.F2_CLIENTE," + chr(13)
      cSql += "       SF2.F2_LOJA   ," + chr(13)
      cSql += "       SA1.A1_NOME   ," + chr(13)
      cSql += "       SF2.F2_COND   ," + chr(13)
      cSql += "       SE4.E4_DESCRI ," + chr(13)
      cSql += "       SE4.E4_COND   ," + chr(13)
      cSql += "       SF2.F2_VALBRUT," + chr(13)
      cSql += "       (SELECT TOP(1) C5_ADM " + chr(13)
      cSql += "          FROM SC5010 (Nolock) "  + chr(13)
      cSql += "         WHERE C5_FILIAL = SF2.F2_FILIAL" + chr(13)
      cSql += "	          AND C5_NUM    = (SELECT TOP(1) C6_NUM " + chr(13)
      cSql += "                            FROM SC6010 (Nolock) "  + chr(13)
      cSql += "	                       WHERE C6_FILIAL = SF2.F2_FILIAL " + chr(13)
      cSql += "	                         AND C6_NOTA   = SF2.F2_DOC    " + chr(13)
      cSql += "	                         AND C6_SERIE  = SF2.F2_SERIE  " + chr(13)
      cSql += "	                         AND D_E_L_E_T_ = '')) AS ADMINISTRADORA," + chr(13)
      cSql += "        (SELECT TOP(1) C5_BAND " + chr(13)
      cSql += "           FROM SC5010 (Nolock) "  + chr(13)
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL" + chr(13)
      cSql += "	           AND C5_NUM    = (SELECT TOP(1) C6_NUM " + chr(13)
      cSql += "                            FROM SC6010 (Nolock) "  + chr(13)
      cSql += "	                          WHERE C6_FILIAL = SF2.F2_FILIAL " + chr(13)
      cSql += "	                            AND C6_NOTA   = SF2.F2_DOC    " + chr(13)
      cSql += "	                            AND C6_SERIE  = SF2.F2_SERIE  " + chr(13)
      cSql += "	                            AND D_E_L_E_T_ = '')) AS BANDEIRA," + chr(13)
      cSql += "        (SELECT TOP(1) C5_CARTAO " + chr(13)
      cSql += "           FROM SC5010 (Nolock) "  + chr(13)
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL" + chr(13)
      cSql += "	           AND C5_NUM    = (SELECT TOP(1) C6_NUM " + chr(13)
      cSql += "                               FROM SC6010 (Nolock) "  + chr(13)
      cSql += "	                             WHERE C6_FILIAL = SF2.F2_FILIAL " + chr(13)
      cSql += "	                               AND C6_NOTA   = SF2.F2_DOC    " + chr(13)
      cSql += "	                               AND C6_SERIE  = SF2.F2_SERIE  " + chr(13)
      cSql += "	                               AND D_E_L_E_T_ = '')) AS CARTAO," + chr(13)
      cSql += "        (SELECT TOP(1) C5_DATCART " + chr(13)
      cSql += "           FROM SC5010 (Nolock) "  + chr(13)
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL" + chr(13)
      cSql += "	           AND C5_NUM    = (SELECT TOP(1) C6_NUM " + chr(13)
      cSql += "                               FROM SC6010 (Nolock) "  + chr(13)
      cSql += "	                             WHERE C6_FILIAL = SF2.F2_FILIAL " + chr(13)
      cSql += "	                               AND C6_NOTA   = SF2.F2_DOC    " + chr(13)
      cSql += "	                               AND C6_SERIE  = SF2.F2_SERIE  " + chr(13)
      cSql += "	                               AND D_E_L_E_T_ = '')) AS DTAEMISSAO," + chr(13)
      cSql += "        (SELECT TOP(1) C5_ZVALCRT "
      cSql += "           FROM " + RetSqlName("SC5" + Substr(cComboBx1,01,02) + "0") + " (Nolock) " 
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL"
      cSql += "	           AND C5_NUM    = (SELECT TOP(1) C6_NUM "
      cSql += "                               FROM " + RetSqlName("SC6" + Substr(cComboBx1,01,02) + "0") + " (Nolock) " 
      cSql += "	                             WHERE C6_FILIAL = SF2.F2_FILIAL "
      cSql += "	                               AND C6_NOTA   = SF2.F2_DOC    "
      cSql += "	                               AND C6_SERIE  = SF2.F2_SERIE  "
      cSql += "	                               AND D_E_L_E_T_ = '')) AS VALORVDA,"
      cSql += "        (SELECT TOP(1) C5_DOC " + chr(13)
      cSql += "           FROM SC5010 (Nolock) "  + chr(13)
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL" + chr(13)
      cSql += "	           AND C5_NUM    = (SELECT TOP(1) C6_NUM " + chr(13)
      cSql += "                            FROM SC6010 (Nolock) "  + chr(13)
      cSql += "	                          WHERE C6_FILIAL = SF2.F2_FILIAL " + chr(13)
      cSql += "	                            AND C6_NOTA   = SF2.F2_DOC    " + chr(13)
      cSql += "	                            AND C6_SERIE  = SF2.F2_SERIE  " + chr(13)
      cSql += "	                            AND D_E_L_E_T_ = '')) AS DOCUMENTO," + chr(13)
      cSql += "        (SELECT TOP(1) C5_AUTORIZ " + chr(13)
      cSql += "           FROM SC5010 (Nolock) "  + chr(13)
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL" + chr(13)
      cSql += "	           AND C5_NUM    = (SELECT TOP(1) C6_NUM " + chr(13)
      cSql += "                            FROM SC6010 (Nolock) "  + chr(13)
      cSql += "	                          WHERE C6_FILIAL = SF2.F2_FILIAL " + chr(13)
      cSql += "	                            AND C6_NOTA   = SF2.F2_DOC    " + chr(13)
      cSql += "	                            AND C6_SERIE  = SF2.F2_SERIE  " + chr(13)
      cSql += "	                            AND D_E_L_E_T_ = '')) AS AUTORIZACAO," + chr(13)
      cSql += "        (SELECT TOP(1) C5_TID " + chr(13)
      cSql += "           FROM SC5010 (Nolock) "  + chr(13)
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL" + chr(13)
      cSql += "	           AND C5_NUM    = (SELECT TOP(1) C6_NUM " + chr(13)
      cSql += "                            FROM SC6010 (Nolock) "  + chr(13)
      cSql += "	                          WHERE C6_FILIAL = SF2.F2_FILIAL " + chr(13)
      cSql += "	                            AND C6_NOTA   = SF2.F2_DOC    " + chr(13)
      cSql += "	                            AND C6_SERIE  = SF2.F2_SERIE  " + chr(13)
      cSql += "	                            AND D_E_L_E_T_ = '')) AS NSUTID" + chr(13)
      cSql += "     FROM SF2010 (Nolock) SF2, "  + chr(13)
      cSql += "          SA1010 (Nolock) SA1, " + chr(13)
      cSql += "     	 SE4010 (Nolock) SE4  " + chr(13)
      cSql += "    WHERE SF2.F2_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(cDtaInicial) + "', 103)" + chr(13)
      cSql += "      AND SF2.F2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(cDtaFinal)   + "', 103)" + chr(13)
      cSql += "      AND SF2.D_E_L_E_T_  = ''" + chr(13)
      cSql += "      AND SA1.A1_COD      = SF2.F2_CLIENTE" + chr(13)
      cSql += "      AND SA1.A1_LOJA     = SF2.F2_LOJA   " + chr(13)
      cSql += "      AND SA1.D_E_L_E_T_  = ''            " + chr(13)
      cSql += "      AND SE4.E4_CODIGO   = SF2.F2_COND   " + chr(13)
      cSql += "      AND SE4.D_E_L_E_T_  = ''            " + chr(13)

      cSql += " UNION " + chr(13)

      cSql += "SELECT SF2.F2_FILIAL ,"
      cSql += "       '02' AS EMPRESA,"
      cSql += "       SF2.F2_EMISSAO,"
      cSql += "       SF2.F2_DOC    ,"
      cSql += "       SF2.F2_SERIE  ,"
      cSql += "       SF2.F2_CLIENTE,"
      cSql += "       SF2.F2_LOJA   ,"
      cSql += "       SA1.A1_NOME   ,"
      cSql += "       SF2.F2_COND   ,"
      cSql += "       SE4.E4_DESCRI ,"
      cSql += "       SE4.E4_COND   ,"
      cSql += "       SF2.F2_VALBRUT,"
      cSql += "       (SELECT TOP(1) C5_ADM "
      cSql += "          FROM SC5020 (Nolock) " 
      cSql += "         WHERE C5_FILIAL = SF2.F2_FILIAL"
      cSql += "	          AND C5_NUM    = (SELECT TOP(1) C6_NUM "
      cSql += "                            FROM SC6020 (Nolock) " 
      cSql += "	                       WHERE C6_FILIAL = SF2.F2_FILIAL "
      cSql += "	                         AND C6_NOTA   = SF2.F2_DOC    "
      cSql += "	                         AND C6_SERIE  = SF2.F2_SERIE  "
      cSql += "	                         AND D_E_L_E_T_ = '')) AS ADMINISTRADORA,"
      cSql += "        (SELECT TOP(1) C5_BAND "
      cSql += "           FROM SC5020 (Nolock) " 
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL"
      cSql += "	           AND C5_NUM    = (SELECT TOP(1) C6_NUM "
      cSql += "                            FROM SC6020 (Nolock) " 
      cSql += "	                          WHERE C6_FILIAL = SF2.F2_FILIAL "
      cSql += "	                            AND C6_NOTA   = SF2.F2_DOC    "
      cSql += "	                            AND C6_SERIE  = SF2.F2_SERIE  "
      cSql += "	                            AND D_E_L_E_T_ = '')) AS BANDEIRA,"
      cSql += "        (SELECT TOP(1) C5_CARTAO "
      cSql += "           FROM SC5020 (Nolock) " 
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL"
      cSql += "	           AND C5_NUM    = (SELECT TOP(1) C6_NUM "
      cSql += "                               FROM SC6020 (Nolock) " 
      cSql += "	                             WHERE C6_FILIAL = SF2.F2_FILIAL "
      cSql += "	                               AND C6_NOTA   = SF2.F2_DOC    "
      cSql += "	                               AND C6_SERIE  = SF2.F2_SERIE  "
      cSql += "	                               AND D_E_L_E_T_ = '')) AS CARTAO,"
      cSql += "        (SELECT TOP(1) C5_DATCART "
      cSql += "           FROM SC5020 (Nolock) " 
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL"
      cSql += "	           AND C5_NUM    = (SELECT TOP(1) C6_NUM "
      cSql += "                               FROM SC6020 (Nolock) " 
      cSql += "	                             WHERE C6_FILIAL = SF2.F2_FILIAL "
      cSql += "	                               AND C6_NOTA   = SF2.F2_DOC    "
      cSql += "	                               AND C6_SERIE  = SF2.F2_SERIE  "
      cSql += "	                               AND D_E_L_E_T_ = '')) AS DTAEMISSAO,"
      cSql += "        (SELECT TOP(1) C5_ZVALCRT "
      cSql += "           FROM " + RetSqlName("SC5" + Substr(cComboBx1,01,02) + "0") + " (Nolock) " 
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL"
      cSql += "	           AND C5_NUM    = (SELECT TOP(1) C6_NUM "
      cSql += "                               FROM " + RetSqlName("SC6" + Substr(cComboBx1,01,02) + "0") + " (Nolock) " 
      cSql += "	                             WHERE C6_FILIAL = SF2.F2_FILIAL "
      cSql += "	                               AND C6_NOTA   = SF2.F2_DOC    "
      cSql += "	                               AND C6_SERIE  = SF2.F2_SERIE  "
      cSql += "	                               AND D_E_L_E_T_ = '')) AS VALORVDA,"
      cSql += "        (SELECT TOP(1) C5_DOC "
      cSql += "           FROM SC5020 (Nolock) " 
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL"
      cSql += "	           AND C5_NUM    = (SELECT TOP(1) C6_NUM "
      cSql += "                            FROM SC6020 (Nolock) " 
      cSql += "	                          WHERE C6_FILIAL = SF2.F2_FILIAL "
      cSql += "	                            AND C6_NOTA   = SF2.F2_DOC    "
      cSql += "	                            AND C6_SERIE  = SF2.F2_SERIE  "
      cSql += "	                            AND D_E_L_E_T_ = '')) AS DOCUMENTO,"
      cSql += "        (SELECT TOP(1) C5_AUTORIZ "
      cSql += "           FROM SC5020 (Nolock) " 
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL"
      cSql += "	           AND C5_NUM    = (SELECT TOP(1) C6_NUM "
      cSql += "                            FROM SC6020 (Nolock) " 
      cSql += "	                          WHERE C6_FILIAL = SF2.F2_FILIAL "
      cSql += "	                            AND C6_NOTA   = SF2.F2_DOC    "
      cSql += "	                            AND C6_SERIE  = SF2.F2_SERIE  "
      cSql += "	                            AND D_E_L_E_T_ = '')) AS AUTORIZACAO,"
      cSql += "        (SELECT TOP(1) C5_TID "
      cSql += "           FROM SC5020 (Nolock) " 
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL"
      cSql += "	           AND C5_NUM    = (SELECT TOP(1) C6_NUM "
      cSql += "                            FROM SC6020 (Nolock) " 
      cSql += "	                          WHERE C6_FILIAL = SF2.F2_FILIAL "
      cSql += "	                            AND C6_NOTA   = SF2.F2_DOC    "
      cSql += "	                            AND C6_SERIE  = SF2.F2_SERIE  "
      cSql += "	                            AND D_E_L_E_T_ = '')) AS NSUTID"
      cSql += "     FROM SF2020 (Nolock) SF2, " 
      cSql += "          SA1010 (Nolock) SA1, "
      cSql += "     	 SE4010 (Nolock) SE4  "
      cSql += "    WHERE SF2.F2_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(cDtaInicial) + "', 103)"
      cSql += "      AND SF2.F2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(cDtaFinal)   + "', 103)"
      cSql += "      AND SF2.D_E_L_E_T_  = ''"
      cSql += "      AND SA1.A1_COD      = SF2.F2_CLIENTE"
      cSql += "      AND SA1.A1_LOJA     = SF2.F2_LOJA   "
      cSql += "      AND SA1.D_E_L_E_T_  = ''            "
      cSql += "      AND SE4.E4_CODIGO   = SF2.F2_COND   "
      cSql += "      AND SE4.D_E_L_E_T_  = ''            "

      cSql += " UNION "

      cSql += "SELECT SF2.F2_FILIAL ,"
      cSql += "       '03' AS EMPRESA,"
      cSql += "       SF2.F2_EMISSAO,"
      cSql += "       SF2.F2_DOC    ,"
      cSql += "       SF2.F2_SERIE  ,"
      cSql += "       SF2.F2_CLIENTE,"
      cSql += "       SF2.F2_LOJA   ,"
      cSql += "       SA1.A1_NOME   ,"
      cSql += "       SF2.F2_COND   ,"
      cSql += "       SE4.E4_DESCRI ,"
      cSql += "       SE4.E4_COND   ,"
      cSql += "       SF2.F2_VALBRUT,"
      cSql += "       (SELECT TOP(1) C5_ADM "
      cSql += "          FROM SC5030 (Nolock) " 
      cSql += "         WHERE C5_FILIAL = SF2.F2_FILIAL"
      cSql += "	          AND C5_NUM    = (SELECT TOP(1) C6_NUM "
      cSql += "                            FROM SC6030 (Nolock) " 
      cSql += "	                       WHERE C6_FILIAL = SF2.F2_FILIAL "
      cSql += "	                         AND C6_NOTA   = SF2.F2_DOC    "
      cSql += "	                         AND C6_SERIE  = SF2.F2_SERIE  "
      cSql += "	                         AND D_E_L_E_T_ = '')) AS ADMINISTRADORA,"
      cSql += "        (SELECT TOP(1) C5_BAND "
      cSql += "           FROM SC5030 (Nolock) " 
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL"
      cSql += "	           AND C5_NUM    = (SELECT TOP(1) C6_NUM "
      cSql += "                            FROM SC6030 (Nolock) " 
      cSql += "	                          WHERE C6_FILIAL = SF2.F2_FILIAL "
      cSql += "	                            AND C6_NOTA   = SF2.F2_DOC    "
      cSql += "	                            AND C6_SERIE  = SF2.F2_SERIE  "
      cSql += "	                            AND D_E_L_E_T_ = '')) AS BANDEIRA,"
      cSql += "        (SELECT TOP(1) C5_CARTAO "
      cSql += "           FROM SC5030 (Nolock) " 
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL"
      cSql += "	           AND C5_NUM    = (SELECT TOP(1) C6_NUM "
      cSql += "                               FROM SC6030 (Nolock) " 
      cSql += "	                             WHERE C6_FILIAL = SF2.F2_FILIAL "
      cSql += "	                               AND C6_NOTA   = SF2.F2_DOC    "
      cSql += "	                               AND C6_SERIE  = SF2.F2_SERIE  "
      cSql += "	                               AND D_E_L_E_T_ = '')) AS CARTAO,"
      cSql += "        (SELECT TOP(1) C5_DATCART "
      cSql += "           FROM SC5030 (Nolock) " 
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL"
      cSql += "	           AND C5_NUM    = (SELECT TOP(1) C6_NUM "
      cSql += "                               FROM SC6030 (Nolock) " 
      cSql += "	                             WHERE C6_FILIAL = SF2.F2_FILIAL "
      cSql += "	                               AND C6_NOTA   = SF2.F2_DOC    "
      cSql += "	                               AND C6_SERIE  = SF2.F2_SERIE  "
      cSql += "	                               AND D_E_L_E_T_ = '')) AS DTAEMISSAO,"
      cSql += "        (SELECT TOP(1) C5_ZVALCRT "
      cSql += "           FROM " + RetSqlName("SC5" + Substr(cComboBx1,01,02) + "0") + " (Nolock) " 
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL"
      cSql += "	           AND C5_NUM    = (SELECT TOP(1) C6_NUM "
      cSql += "                               FROM " + RetSqlName("SC6" + Substr(cComboBx1,01,02) + "0") + " (Nolock) " 
      cSql += "	                             WHERE C6_FILIAL = SF2.F2_FILIAL "
      cSql += "	                               AND C6_NOTA   = SF2.F2_DOC    "
      cSql += "	                               AND C6_SERIE  = SF2.F2_SERIE  "
      cSql += "	                               AND D_E_L_E_T_ = '')) AS VALORVDA,"
      cSql += "        (SELECT TOP(1) C5_DOC "
      cSql += "           FROM SC5030 (Nolock) " 
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL"
      cSql += "	           AND C5_NUM    = (SELECT TOP(1) C6_NUM "
      cSql += "                            FROM SC6030 (Nolock) " 
      cSql += "	                          WHERE C6_FILIAL = SF2.F2_FILIAL "
      cSql += "	                            AND C6_NOTA   = SF2.F2_DOC    "
      cSql += "	                            AND C6_SERIE  = SF2.F2_SERIE  "
      cSql += "	                            AND D_E_L_E_T_ = '')) AS DOCUMENTO,"
      cSql += "        (SELECT TOP(1) C5_AUTORIZ "
      cSql += "           FROM SC5030 (Nolock) " 
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL"
      cSql += "	           AND C5_NUM    = (SELECT TOP(1) C6_NUM "
      cSql += "                            FROM SC6030 (Nolock) " 
      cSql += "	                          WHERE C6_FILIAL = SF2.F2_FILIAL "
      cSql += "	                            AND C6_NOTA   = SF2.F2_DOC    "
      cSql += "	                            AND C6_SERIE  = SF2.F2_SERIE  "
      cSql += "	                            AND D_E_L_E_T_ = '')) AS AUTORIZACAO,"
      cSql += "        (SELECT TOP(1) C5_TID "
      cSql += "           FROM SC5030 (Nolock) " 
      cSql += "          WHERE C5_FILIAL = SF2.F2_FILIAL"
      cSql += "	           AND C5_NUM    = (SELECT TOP(1) C6_NUM "
      cSql += "                            FROM SC6030 (Nolock) " 
      cSql += "	                          WHERE C6_FILIAL = SF2.F2_FILIAL "
      cSql += "	                            AND C6_NOTA   = SF2.F2_DOC    "
      cSql += "	                            AND C6_SERIE  = SF2.F2_SERIE  "
      cSql += "	                            AND D_E_L_E_T_ = '')) AS NSUTID"
      cSql += "     FROM SF2030 (Nolock) SF2, " 
      cSql += "          SA1010 (Nolock) SA1, "
      cSql += "     	 SE4010 (Nolock) SE4  "
      cSql += "    WHERE SF2.F2_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(cDtaInicial) + "', 103)"
      cSql += "      AND SF2.F2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(cDtaFinal)   + "', 103)"
      cSql += "      AND SF2.D_E_L_E_T_  = ''"
      cSql += "      AND SA1.A1_COD      = SF2.F2_CLIENTE"
      cSql += "      AND SA1.A1_LOJA     = SF2.F2_LOJA   "
      cSql += "      AND SA1.D_E_L_E_T_  = ''            "
      cSql += "      AND SE4.E4_CODIGO   = SF2.F2_COND   "
      cSql += "      AND SE4.D_E_L_E_T_  = ''            "

      cSql += "    ORDER BY SF2.F2_FILIAL, SF2.F2_EMISSAO, SF2.F2_DOC, SF2.F2_SERIE"
   
   Endif
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   If T_CONSULTA->( EOF() )
      aBrowse := {}
      aAdd( aBrowse, { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })   
      MsgAlert("Não existem dados a serem visualizados = 1.")
      Return(.T.)
   Endif
   
   WHILE !T_CONSULTA->( EOF() )   
   
      If U_P_OCCURS(T_CONSULTA->E4_DESCRI, "CARTAO", 1) == 0
         T_CONSULTA->( DbSkip() )
         Loop
      Endif

      // ##########################################
      // Classifica por Administradora de Cartão ##
      // ##########################################
      If Alltrim(U_P_CORTA(cComboBx3, "-", 1)) == "000000"
      Else
         If T_CONSULTA->ADMINISTRADORA <> Alltrim(U_P_CORTA(cComboBx3, "-", 1))
            T_CONSULTA->( DbSkip() )
            Loop
         Endif
      Endif      
      
      // ###############################################
      // Pesquisa o Nome da Administradora de Cartões ##
      // ###############################################
      If Select("T_ADMINISTRADORA") > 0
         T_ADMINISTRADORA->( dbCloseArea() )
      EndIf

      cSql := "SELECT AE_COD ,"
      cSql += "       AE_DESC "
      cSql += "  FROM " + RetSqlName("SAE")
      cSql += " WHERE AE_COD = '" + Alltrim(T_CONSULTA->ADMINISTRADORA) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"
                                
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ADMINISTRADORA", .T., .T. )

      Nome_ADM := IIF(T_ADMINISTRADORA->( EOF() ), "", T_ADMINISTRADORA->AE_DESC)

      // ##########################
      // Classifica por bandeira ##
      // ##########################
      If Alltrim(U_P_CORTA(cComboBx4, "-", 1)) == "000000"
      Else
         If T_CONSULTA->BANDEIRA <> Alltrim(U_P_CORTA(cComboBx4, "-", 1))
            T_CONSULTA->( DbSkip() )
            Loop
         Endif

      Endif      

      // ###############################################
      // Pesquisa o Nome da Administradora de Cartões ##
      // ###############################################
      If Select("T_BANDEIRA") > 0
         T_BANDEIRA->( dbCloseArea() )
      EndIf

      cSql := "SELECT X5_TABELA,"
      cSql += "       X5_CHAVE ,"
      cSql += "       X5_DESCRI "
      cSql += "  FROM " + RetSqlName("SX5")
      cSql += " WHERE X5_TABELA   = 'G3'"
      cSql += "    AND X5_CHAVE   = '" + Alltrim(T_CONSULTA->BANDEIRA) + "'"
      cSql += "    AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BANDEIRA", .T., .T. )

      Nome_Bandeira := IIF(T_BANDEIRA->( EOF() ), "", T_BANDEIRA->X5_DESCRI)

      // #################################
      // Valida a condição de pagamento ##
      // #################################
      If Alltrim(U_P_CORTA(cComboBx5, "-", 1)) == "000000"
      Else
         If Alltrim(T_CONSULTA->F2_COND) <> Alltrim(U_P_CORTA(cComboBx5, "-", 1))
            T_CONSULTA->( DbSkip() )
            Loop
         Endif
      Endif      

      Qtdparcelas := U_P_OCCURS(Alltrim(T_CONSULTA->E4_COND) + ",", ",", 1)

//    kEmissao    := Substr(T_CONSULTA->F2_EMISSAO,07,02) + "/" + Substr(T_CONSULTA->F2_EMISSAO,05,02) + "/" + Substr(T_CONSULTA->F2_EMISSAO,01,04)
//    kValorTot   := Transform(T_CONSULTA->VALORVDA, "@E 999,999,999.99")
//    kDocEmissao := Substr(T_CONSULTA->DTAEMISSAO,07,02) + "/" + Substr(T_CONSULTA->DTAEMISSAO,05,02) + "/" + Substr(T_CONSULTA->DTAEMISSAO,01,04)

      kEmissao    := Substr(T_CONSULTA->DTAEMISSAO,07,02) + "/" + Substr(T_CONSULTA->DTAEMISSAO,05,02) + "/" + Substr(T_CONSULTA->DTAEMISSAO,01,04)
      kValorTot   := Transform(T_CONSULTA->VALORVDA, "@E 999,999,999.99")
      kDocEmissao := Substr(T_CONSULTA->DTAEMISSAO,07,02) + "/" + Substr(T_CONSULTA->DTAEMISSAO,05,02) + "/" + Substr(T_CONSULTA->DTAEMISSAO,01,04)

      Do Case 
         Case T_CONSULTA->EMPRESA == "01"
              kEmpresa := "AUTOATECH"
         Case T_CONSULTA->EMPRESA == "02"
              kEmpresa := "TI AUTOMAÇÃO"
         Case T_CONSULTA->EMPRESA == "03"
              kEmpresa := "ATECH"
         Case T_CONSULTA->EMPRESA == "04"
              kEmpresa := "ATECHPEL"
      EndCase         

//                      T_CONSULTA->F2_DOC      ,; // 04

      aAdd( aBrowse, {kEmpresa                ,; // 01
                      T_CONSULTA->F2_FILIAL   ,; // 02
                      kEmissao                ,; // 03
                      T_CONSULTA->EMPRESA + "-" + T_CONSULTA->F2_FILIAL + "-" + Alltrim(T_CONSULTA->F2_SERIE) + "-" + Alltrim(T_CONSULTA->F2_DOC) ,; // 04
                      T_CONSULTA->F2_SERIE    ,; // 05
                      T_CONSULTA->F2_CLIENTE  ,; // 06
                      T_CONSULTA->F2_LOJA     ,; // 07
                      T_CONSULTA->A1_NOME     ,; // 08
                      T_CONSULTA->F2_COND     ,; // 09
                      T_CONSULTA->E4_DESCRI   ,; // 10
                      Strzero(Qtdparcelas,02) ,; // 11
                      kValorTot               ,; // 12                                                    
                      Nome_ADM                ,; // 13
                      Nome_Bandeira           ,; // 14
                      T_CONSULTA->CARTAO      ,; // 15
                      kDocEmissao             ,; // 16
                      T_CONSULTA->DOCUMENTO   ,; // 17
                      T_CONSULTA->AUTORIZACAO ,; // 18
                      T_CONSULTA->NSUTID})       // 19
                                                      
      T_CONSULTA->( DbSkip() )
      
   ENDDO   

   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })   
   Endif   
·
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
                         aBrowse[oBrowse:nAt,15],;                         
                         aBrowse[oBrowse:nAt,16],;                         
                         aBrowse[oBrowse:nAt,17],;                         
                         aBrowse[oBrowse:nAt,18],;                         
                         aBrowse[oBrowse:nAt,19]}}

   oBrowse:Refresh()

Return(.T.)

// ##########################################################################
// Função que abre diálogo solicitando o caminho onde o arquivo será salvo ##
// ##########################################################################
Static Function GERAARQTXT()

   Local xCaminho := Space(250)
   Local oCaminho
                 
   Private OdlgExporta

   If Len(aBrowse) == 0 .Or. Empty(Alltrim(aBrowse[1,1]))
      aBrowse := {}
      aAdd( aBrowse, { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
      MsgAlert("Não existem dados pesquisados para geração do arquivo = 2.")
      Return(.T.)
   Endif
   
   DEFINE MSDIALOG oDlgExporta TITLE "Gera Arquivo Vendas Cartões" FROM C(178),C(181) TO C(269),C(598) PIXEL

   @ C(005),C(004) Say "Informe o caminho onde o arquivo deverá ser salvo:" Size C(165),C(008) COLOR CLR_BLACK PIXEL OF oDlgExporta
   @ C(014),C(004) MsGet oCaminho Var xCaminho                              Size C(198),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgExporta
   @ C(028),C(127) Button "Gerar"                                           Size C(037),C(012) PIXEL OF oDlgExporta ACTION( Gera_o_Arq(xCaminho, oDlgExporta) )
   @ C(028),C(166) Button "Voltar"                                          Size C(037),C(012) PIXEL OF oDlgExporta ACTION( oDlgExporta:End() )

   ACTIVATE MSDIALOG oDlgExporta CENTERED 

Return(.T.)

// ######################################
// Função que gera o arquivo dos dados ##
// ######################################
Static Function Gera_O_Arq(kCaminho, kJanela)

   Local nContar := 0
   Local cString := ""
   
   If Empty(Alltrim(kCaminho))
      MsgAlert("Caminho/Nome do Arquivo não informado.")
      Return(.T.)
   Endif
   
   cString := ""

   For nContar = 1 to Len(aBrowse)
      
       cString := cString + aBrowse[nContar,01] + "|" + ;
                            aBrowse[nContar,02] + "|" + ;
                            aBrowse[nContar,03] + "|" + ;
                            aBrowse[nContar,04] + "|" + ;
                            aBrowse[nContar,05] + "|" + ;
                            aBrowse[nContar,06] + "|" + ;
                            aBrowse[nContar,07] + "|" + ;
                            aBrowse[nContar,08] + "|" + ;
                            aBrowse[nContar,09] + "|" + ;
                            aBrowse[nContar,10] + "|" + ;
                            aBrowse[nContar,11] + "|" + ;
                            aBrowse[nContar,12] + "|" + ;
                            aBrowse[nContar,13] + "|" + ;
                            aBrowse[nContar,14] + "|" + ;
                            aBrowse[nContar,15] + "|" + ;
                            aBrowse[nContar,16] + "|" + ;
                            aBrowse[nContar,17] + "|" + ;
                            aBrowse[nContar,18] + "|" + ;
                            aBrowse[nContar,19] + "|" + CHR(13) + CHR(10)
                            
   Next nContar

   // ##############################################
   // Gera o arquivo XML para o caminho informado ##
   // ##############################################
   nHdl := fCreate(kCaminho)
   fWrite (nHdl, cString ) 
   fClose(nHdl)

   MsgAlert("Arquivo gerado com sucesso.")

   // #############################################
   // Inicializa as variáveis para nova pesquisa ##
   // #############################################

   kJanela:End()
 
   cDtaInicial := Ctod("  /  /    ")
   cDtaFinal   := Ctod("  /  /    ")

   oGet1:Refresh()
   oGet2:Refresh()

   aBrowse := {}

   aAdd( aBrowse, { "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })   

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
                         aBrowse[oBrowse:nAt,15],;                         
                         aBrowse[oBrowse:nAt,16],;                         
                         aBrowse[oBrowse:nAt,17],;                         
                         aBrowse[oBrowse:nAt,18],;                         
                         aBrowse[oBrowse:nAt,19]}}

   oBrowse:Refresh()

Return(.T.)