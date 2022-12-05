#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "jpeg.ch" 
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: SYSCON01.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 21/09/2017                                                          ##
// Objetivo..: Conciliador Financeiro                                              ##
// ##################################################################################

User Function SYSCON01()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private aEmpresas  := U_AUTOM539(1, "")      
   Private aFiliais   := U_AUTOM539(2, cEmpAnt) 
   Private dInicial	  := Ctod("  /  /    ")
   Private dFinal 	  := Ctod("  /  /    ")
   Private aConciliar := {"00 - Selecione", "01 - Contas a Pagar", "03 - Contas a Receber"}
   Private aTipocon   := {"00 - Selecione", "01 - Financeiro", "02 - Contábil"}
   Private aVisual    := {"00 - Selecione o tipo de conciliação", "01 - Somente Registros Inconsistêntes", "02 - Somente Registros Consistente", "03 - Ambos"}

   Private oGet1
   Private oGet2

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4
   Private cComboBx5

   Private kSCP01    := "0"
   Private kSCP02    := Space(03)
   Private kSCP03    := ""
   Private kSCP04    := ""
   Private kSCP05    := ""
   Private kSCP06    := ""
   
   Private kSCR01    := "0"
   Private kSCR02    := Space(03)
   Private kSCR03    := ""
   Private kSCR04    := ""
   Private kSCR05    := ""
   Private kSCR06    := ""

   Private oDlgC

   DEFINE MSDIALOG oDlgC TITLE "Conciliador Financeiro/Contábil" FROM C(178),C(181) TO C(566),C(483) PIXEL

   @ C(004),C(002) Jpeg FILE "SYSFINAN.PNG" Size C(146),C(016) PIXEL NOBORDER OF oDlgC

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(145),C(001) PIXEL OF oDlgC
   @ C(172),C(002) GET oMemo2 Var cMemo2 MEMO Size C(145),C(001) PIXEL OF oDlgC
   
   @ C(037),C(005) Say "Empresa"             Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(060),C(005) Say "Filiais"             Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(082),C(005) Say "Período Inicial"     Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(083),C(054) Say "Período Final"       Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(104),C(005) Say "Conciliar"           Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(126),C(005) Say "Tipo de Conciliação" Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgC
   @ C(149),C(005) Say "Visualizar"          Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgC

   @ C(046),C(005) ComboBox cComboBx1 Items aEmpresas  Size C(143),C(010)                              PIXEL OF oDlgC When lChumba
   @ C(068),C(005) ComboBox cComboBx2 Items aFiliais   Size C(143),C(010)                              PIXEL OF oDlgC
   @ C(091),C(005) MsGet    oGet1     Var   dInicial   Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC
   @ C(091),C(054) MsGet    oGet2     Var   dFinal     Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgC
   @ C(113),C(005) ComboBox cComboBx3 Items aConciliar Size C(143),C(010)                              PIXEL OF oDlgC
   @ C(135),C(005) ComboBox cComboBx4 Items aTipoCon   Size C(143),C(010)                              PIXEL OF oDlgC
   @ C(157),C(005) ComboBox cComboBx5 Items aVisual    Size C(143),C(010)                              PIXEL OF oDlgC

   @ C(178),C(017) Button "Parâmetros" Size C(037),C(012) PIXEL OF oDlgC ACTION( SYSPARAM() )
   @ C(178),C(056) Button "Conciliar"  Size C(037),C(012) PIXEL OF oDlgC ACTION( xGeraConcFiCt() )
   @ C(178),C(095) Button "Voltar"     Size C(037),C(012) PIXEL OF oDlgC ACTION( oDlgC:End() )
   
   ACTIVATE MSDIALOG oDlgC CENTERED 

Return(.T.)

// #############################################################
// Função que realiza a conciliação da display dos resultados ##
// #############################################################
Static Function xGeraConcFiCt()

   If dInicial == Ctod("  /  /    ")
      MsgAlert("Período inicial de conciliação não informada. Verifique!")
      Return(.T.)
   Endif
     
   If dFinal == Ctod("  /  /    ")
      MsgAlert("Período final de conciliação não informada. Verifique!")
      Return(.T.)
   Endif
      
   If Substr(cComboBx3,01,02) == "00"
      MsgAlert("Tipo de conciliação não selecionada. Verifique!")
      Return(.T.)
   Endif

   If Substr(cComboBx5,01,02) == "00"
      MsgAlert("Conciliação Financeira ou Contábil não selecionada. Verifique!")
      Return(.T.)
   Endif

   If Substr(cComboBx4,01,02) == "00"
      MsgAlert("Tipo de visualização da conciliação não selecionada. Verifique!")
      Return(.T.)
   Endif

   yGeraConcFiCt()

Return(.T.)

// #############################################################
// Função que realiza a conciliação da display dos resultados ##
// #############################################################
Static Function yGeraConcFiCt()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private kEmpresas  := cComboBx1
   Private kFiliais   := cComboBx2
   Private kInicial	  := dInicial
   Private kFinal 	  := dFinal
   Private kConciliar := cComboBx3
   Private kTipocon   := cComboBx4
   Private kVisual    := cComboBx5

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7

   Private aBrowse   := {}

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

   Private kSCP01    := "0"
   Private kSCP02    := Space(03)
   Private kSCP03    := ""
   Private kSCP04    := ""
   Private kSCP05    := ""
   Private kSCP06    := ""
   
   Private kSCR01    := "0"
   Private kSCR02    := Space(03)
   Private kSCR03    := ""
   Private kSCR04    := ""
   Private kSCR05    := ""
   Private kSCR06    := ""

   DEFINE FONT oFont Name "Courier New" Size 0, 16

   Private oDlg

   // #################################################################################
   // Verifica se existe a pasta SYSFINAN na aplicação. Caso não exista, será criada ##
   // #################################################################################
   If !ExistDir( "\SYSPARAM" )

      nRet := MakeDir( "\SYSPARAM" )
   
      If nRet != 0
         MsgAlert("Não foi possível criar a pasta SYSPARAM. Erro: " + cValToChar( FError() ) )
         Return(.T.)
      Endif
   
   Endif

   // ############################################################
   // Envia para a função que carrega os parâmetros do programa ##
   // ############################################################
   Carregaparam()

   // ###############################################################################
   // Envia para a função que realiza a conciliação conforme parâmetros informados ##
   // ###############################################################################
   If Substr(cComboBx4,01,02) == "01"
      ConcFinanceiro()
   Else
      ConcContabil()
   Endif   

   // #############################################
   // Desenha a tela para visualização dos dados ##
   // #############################################
   DEFINE MSDIALOG oDlg TITLE "Conciliador Financeiro/Contábil" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(004),C(002) Jpeg FILE "SYSFINAN.PNG" Size C(146),C(016) PIXEL NOBORDER OF oDlg

   @ C(047),C(002) GET oMemo2 Var cMemo2 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(024),C(005) Say "Empresa"          Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(024),C(076) Say "Filial"           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(024),C(147) Say "Período Inicial"  Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(024),C(190) Say "Período Final"    Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(024),C(233) Say "Conciliar"        Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(024),C(300) Say "Tipo Conciliação" Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(024),C(365) Say "Visualizar"       Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(050),C(005) Say "Inconsistências"  Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(033),C(147) MsGet oGet1 Var   dInicial   Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(033),C(190) MsGet oGet2 Var   dFinal     Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(033),C(005) MsGet oGet3 Var   kEmpresas  Size C(066),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(033),C(076) MsGet oGet4 Var   kFiliais   Size C(066),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(033),C(233) MsGet oGet5 Var   kConciliar Size C(062),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(033),C(300) MsGet oGet6 Var   kTipocon   Size C(062),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(033),C(365) MsGet oGet7 Var   kVisual    Size C(133),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
	
// @ C(030),C(461) Button "Conciliar"         Size C(037),C(012) PIXEL OF oDlg ACTION( ConcFinanceiro() )
   @ C(210),C(005) Button "Parametros"        Size C(037),C(012) PIXEL OF oDlg ACTION( SYSPARAM() )
   @ C(210),C(043) Button "Ctas A Receber"    Size C(047),C(012) PIXEL OF oDlg ACTION( FINA740() )
   @ C(210),C(092) Button "Ctas A Pagar"      Size C(047),C(012) PIXEL OF oDlg ACTION( FINA750() )
   @ C(210),C(140) Button "Doc Entrada/Saída" Size C(055),C(012) PIXEL OF oDlg ACTION( SPEDNFE() )
   @ C(210),C(197) Button "Lote Contábil"     Size C(043),C(012) PIXEL OF oDlg
   @ C(210),C(241) Button "Exporta TXT"       Size C(037),C(012) PIXEL OF oDlg
   @ C(210),C(280) Button "Exporta Excel"     Size C(037),C(012) PIXEL OF oDlg
   @ C(210),C(318) Button "Legendas"          Size C(031),C(012) PIXEL OF oDlg
   @ C(210),C(461) Button "Voltar"            Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   If Substr(cComboBx4,01,02) == "01"

//    aAdd( aBrowse, { "0", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" } )

      @ 074,005 LISTBOX oBrowse FIELDS HEADER "Leg"                     ,; // 01
                                              "Filial"                  ,; // 02
                                              "Dta Emissão"             ,; // 03
                                              "Documento"               ,; // 04
                                              "Série"                   ,; // 05
                                              "Cliente"                 ,; // 06
                                              "Loja"                    ,; // 07
                                              "Descrição dos Clientes"  ,; // 08
                                              "Total Documento"         ,; // 09
                                              "Nº do Título"            ,; // 10  
                                              "Prefixo"                 ,; // 11
                                              "Tipo"                    ,; // 12
                                              "Parcela"                 ,; // 13
                                              "Vencimento"              ,; // 14
                                              "Vcto Real"               ,; // 15
                                              "Valor Parcela"           ,; // 16
                                              "Dta Baixa"               ,; // 17
                                              "Saldo Parcela"            ; // 18
                                              PIXEL SIZE 633,189 OF oDlg FONT oFont ;
                ON LEFT DBLCLICK ( MDetalhe()), ON RIGHT CLICK (MDetalhe())

      oBrowse:SetArray( aBrowse )

      oBrowse:bLine := {||    {If(aBrowse[oBrowse:nAt,01] == "0", oBranco   ,;
                               If(aBrowse[oBrowse:nAt,01] == "2", oVerde    ,;
                               If(aBrowse[oBrowse:nAt,01] == "3", oCancel   ,;                         
                               If(aBrowse[oBrowse:nAt,01] == "1", oAmarelo  ,;                         
                               If(aBrowse[oBrowse:nAt,01] == "5", oAzul     ,;                         
                               If(aBrowse[oBrowse:nAt,01] == "6", oLaranja  ,;                         
                               If(aBrowse[oBrowse:nAt,01] == "7", oPreto    ,;                         
                               If(aBrowse[oBrowse:nAt,01] == "8", oVermelho ,;
                               If(aBrowse[oBrowse:nAt,01] == "9", oPink     ,;
                               If(aBrowse[oBrowse:nAt,01] == "4", oEncerra, "")))))))))),;
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
         	        	          aBrowse[oBrowse:nAt,18]}}

   Else         	        	          

//    aAdd( aBrowse, { "0", "", "", "", "", "", "", "", "", "", "", "", "" } )

      @ 074,005 LISTBOX oBrowse FIELDS HEADER "Leg"                             ,; // 01
                                              "Filial"                          ,; // 02
                                              "Documento"                       ,; // 03
                                              "Série"                           ,; // 04
                                              "Dta Emissão"                     ,; // 05
                                              "Fornecedor/Cliente"              ,; // 06
                                              "Loja"                            ,; // 07
                                              "Descrição Fornecedores/Clientes" ,; // 08
                                              "Total Doc. Entrada"              ,; // 09
                                              "Total Títulos"                   ,; // 10
                                              "Total Contabilizado"             ,; // 11  
                                              "Lote/Sub-Lote"                   ,; // 12
                                              "Histórico"                        ; // 13
                                              PIXEL SIZE 633,189 OF oDlg FONT oFont ;
                ON LEFT DBLCLICK ( MDetalhe()), ON RIGHT CLICK (MDetalhe())

      oBrowse:SetArray( aBrowse )

      oBrowse:bLine := {||    {If(aBrowse[oBrowse:nAt,01] == "0", oBranco   ,;
                               If(aBrowse[oBrowse:nAt,01] == "2", oVerde    ,;
                               If(aBrowse[oBrowse:nAt,01] == "3", oCancel   ,;                         
                               If(aBrowse[oBrowse:nAt,01] == "1", oAmarelo  ,;                         
                               If(aBrowse[oBrowse:nAt,01] == "5", oAzul     ,;                         
                               If(aBrowse[oBrowse:nAt,01] == "6", oLaranja  ,;                         
                               If(aBrowse[oBrowse:nAt,01] == "7", oPreto    ,;                         
                               If(aBrowse[oBrowse:nAt,01] == "8", oVermelho ,;
                               If(aBrowse[oBrowse:nAt,01] == "9", oPink     ,;
                               If(aBrowse[oBrowse:nAt,01] == "4", oEncerra, "")))))))))),;
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
          					      aBrowse[oBrowse:nAt,13]}}

   Endif
 
   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #############################################################
// Função que carrega as filiais conforme Empresa selecionada ##
// #############################################################
Static Function AlteraComboFil

   aFiliais := U_AUTOM539(2, Substr(cComboBx1,01,02) )
   @ C(033),C(076) ComboBox cComboBx2 Items aFiliais Size C(066),C(010) PIXEL OF oDlg

Return(.T.)

// #############################################################
// Função realiza a conciliação dos dados conforme parâmetros ##
// #############################################################
Static Function ConcFinanceiro()

   MsgRun("Aguarde! Pesquisando Documentos ...", "Conciliação Financeira",{|| xConcFinanceiro() })

Return(.T.)

// #############################################################
// Função realiza a conciliação dos dados conforme parâmetros ##
// #############################################################
Static Function xConcFinanceiro()

   Local cSql      := ""
   Local aErros    := {}
   Local aCertos   := {}
   Local aTransito := {}
   Local aPagar    := {}
   Local nPagar    := 0

   If dInicial == Ctod("  /  /    ")
      MsgAlert("Período inicial de conciliação não informada. Verifique!")
      Return(.T.)
   Endif
     
   If dFinal == Ctod("  /  /    ")
      MsgAlert("Período final de conciliação não informada. Verifique!")
      Return(.T.)
   Endif
      
   If Substr(cComboBx3,01,02) == "00"
      MsgAlert("Tipo de conciliação não selecionada. Verifique!")
      Return(.T.)
   Endif

   If Substr(cComboBx5,01,02) == "00"
      MsgAlert("Conciliação Financeira ou Contábil não selecionada. Verifique!")
      Return(.T.)
   Endif

   If Substr(cComboBx4,01,02) == "00"
      MsgAlert("Tipo de visualização da conciliação não selecionada. Verifique!")
      Return(.T.)
   Endif

   aBrowse   := {}
   aTransito := {}

   Private aConciliar := {"00 - Selecione", "01 - Contas a Pagar", "03 - Contas a Receber"}

   If Substr(cComboBx5,01,02) == "01"

      If Substr(cComboBx3,01,02) == "01"

         // #################
         // Contas a Pagar ##
         // #################
         If Select("T_CONSULTA") > 0
            T_CONSULTA->( dbCloseArea() )
         EndIf

         cSql := ""
         cSql := "SELECT SD1.D1_FILIAL ,"
         cSql += "       SD1.D1_EMISSAO,"
         cSql += "       SD1.D1_DOC    ,"
   	     cSql += "       SD1.D1_SERIE  ,"
         cSql += "       SD1.D1_FORNECE,"
         cSql += "       SD1.D1_LOJA   ,"
         cSql += "       SA2.A2_NOME   ,"
//       cSql += "       SUM(SD1.D1_TOTAL + SD1.D1_ICMSRET + SD1.D1_VALIPI + SD1.D1_DESPESA) + (SELECT TOP(1) F1_FRETE"
         cSql += "       SUM(" + Alltrim(KSCP04) + ") + (SELECT TOP(1) " + Alltrim(KSCP03)
         cSql += "                              FROM " + RetSqlName("SF1") + " SF1 "
  	     cSql += "	      			           WHERE SF1.F1_FILIAL  = SD1.D1_FILIAL  "
  	     cSql += "				                 AND SF1.F1_DOC     = SD1.D1_DOC     "
  	     cSql += "					             AND SF1.F1_SERIE   = SD1.D1_SERIE   "
  	     cSql += "				                 AND SF1.D_E_L_E_T_ = '') AS TOTAL_NF"
         cSql += "  FROM " + RetSqlName("SD1") + " SD1, " 
         cSql += "       " + RetSqlName("SF4") + " SF4, " 
         cSql += "       " + RetSqlName("SA2") + " SA2  " 
         cSql += "   WHERE SD1.D1_FILIAL   = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
         cSql += "     AND SD1.D1_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103)"
         cSql += "     AND SD1.D1_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dFinal)   + "', 103)"
         cSql += "   AND SD1.D_E_L_E_T_  = ''        "
         cSql += "   AND SF4.F4_CODIGO   = SD1.D1_TES"
         cSql += "   AND SF4.D_E_L_E_T_  = ''        "
         cSql += "   AND SF4.F4_DUPLIC   = 'S'       " 
         cSql += "   AND SA2.A2_COD      = SD1.D1_FORNECE"
         cSql += "   AND SA2.A2_LOJA     = SD1.D1_LOJA   "
         cSql += " GROUP BY SD1.D1_FILIAL, SD1.D1_EMISSAO, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SA2.A2_NOME"
         cSql += " ORDER BY SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

         T_CONSULTA->( DbGoTop() )
   
         WHILE !T_CONSULTA->( EOF() )
   
            kTotalDoc := T_CONSULTA->TOTAL_NF

            // ##################################################
            // Pesquisa o contas a pagar do título posicionado ##
            // ##################################################
            aPagar := {}

            DbSelectArea("SE2")
            DbSetOrder(6)
            DbSeek(xfilial("SE2") + T_CONSULTA->D1_FORNECE + T_CONSULTA->D1_LOJA + T_CONSULTA->D1_SERIE + T_CONSULTA->D1_DOC)
            WHILE !SE2->(EOF())                             .AND. ;
               SE2->E2_FORNECE == T_CONSULTA->D1_FORNECE .AND. ;
               SE2->E2_LOJA    == T_CONSULTA->D1_LOJA    .AND. ;
               SE2->E2_PREFIXO == T_CONSULTA->D1_SERIE   .AND. ;
               SE2->E2_NUM     == T_CONSULTA->D1_DOC
               aAdd( aPagar, { SE2->E2_VENCTO ,;
                               SE2->E2_VENCREA,;
                               SE2->E2_BAIXA  ,;
                               SE2->E2_NUM    ,;
                               SE2->E2_PREFIXO,;
                               SE2->E2_TIPO   ,;
                               SE2->E2_PARCELA,;
                               SE2->E2_VALOR  ,;
                               SE2->E2_SALDO  })
               SE2->( DbSkip() )
            ENDDO                                     
               
            If Len(aPagar) == 0

               kEmissao  := Substr(T_CONSULTA->D1_EMISSAO,07,02) + "/" + Substr(T_CONSULTA->D1_EMISSAO,05,02) + "/" + Substr(T_CONSULTA->D1_EMISSAO,01,04)

               // ############################
               // Registra a inconsistência ##
               // ############################
               aAdd( aTransito, { "7"                                                ,; // 01
                                  T_CONSULTA->D1_FILIAL                              ,; // 02
                                  kEmissao                                           ,; // 03
                                  T_CONSULTA->D1_DOC                                 ,; // 04
                                  T_CONSULTA->D1_SERIE                               ,; // 05
                                  T_CONSULTA->D1_FORNECE                             ,; // 06
                                  T_CONSULTA->D1_LOJA                                ,; // 07
                                  T_CONSULTA->A2_NOME                                ,; // 08
                                  TRANSFORM(T_CONSULTA->TOTAL_NF, "@E 99,999,999.99"),; // 09
                                  ""                                                 ,; // 10
                                  ""                                                 ,; // 11
                                  ""                                                 ,; // 12
                                  ""                                                 ,; // 13
                                  ""                                                 ,; // 14
                                  ""                                                 ,; // 15
                                  ""                                                 ,; // 16
                                  ""                                                 ,; // 17
                                  ""                                                 ,; // 18
                                  T_CONSULTA->D1_DOC                                 ,; // 19
                                  T_CONSULTA->D1_SERIE                               }) // 20                                

               // ################################
               // Registra o total do documento ##
               // ################################
               aAdd( aTransito, { ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  "Total do Documento"                               ,;
                                  TRANSFORM(T_CONSULTA->TOTAL_NF, "@E 99,999,999.99"),;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  T_CONSULTA->D1_DOC                                 ,;
                                  T_CONSULTA->D1_SERIE                               })

               // #######################
               // Registra a diferença ##
               // #######################
               aAdd( aTransito, { ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  "Diferença(DOC/SCP)"                               ,;
                                  TRANSFORM(T_CONSULTA->TOTAL_NF, "@E 99,999,999.99"),;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  T_CONSULTA->D1_DOC                                 ,;
                                  T_CONSULTA->D1_SERIE                               })

               // ###############################
               // Registra uma linha em branco ##
               // ###############################
               aAdd( aTransito, { "","","","","","","","","","","","","","","","","","", T_CONSULTA->D1_DOC, T_CONSULTA->D1_SERIE})

               T_CONSULTA->( DbSkip() )
               Loop

            Endif   

            lPrimeiro   := .T.
            kVlrParcela := 0
            kVlrSaldo   := 0
         
            For nPagar = 1 to Len(aPagar)

               If Alltrim(aPagar[nPagar,06]) == "FT"
                  Loop
               Endif    

               If lPrimeiro == .T.

                  kEmissao  := Substr(T_CONSULTA->D1_EMISSAO,07,02)  + "/" + Substr(T_CONSULTA->D1_EMISSAO,05,02)  + "/" + Substr(T_CONSULTA->D1_EMISSAO,01,04)
                  kVencto   := Dtoc(aPagar[nPagar,01])
                  kVenctoR  := Dtoc(aPagar[nPagar,02])
                  kBaixa    := Dtoc(aPagar[nPagar,03])
                  kLegenda  := "2"
                  lPrimeiro := .F.

                  aAdd( aTransito, { kLegenda                                           ,; // 01
                                     T_CONSULTA->D1_FILIAL                              ,; // 02
                                     kEmissao                                           ,; // 03
                                     T_CONSULTA->D1_DOC                                 ,; // 04
                                     T_CONSULTA->D1_SERIE                               ,; // 05
                                     T_CONSULTA->D1_FORNECE                             ,; // 06
                                     T_CONSULTA->D1_LOJA                                ,; // 07
                                     T_CONSULTA->A2_NOME                                ,; // 08
                                     TRANSFORM(T_CONSULTA->TOTAL_NF, "@E 99,999,999.99"),; // 09
                                     aPagar[nPagar,04]                                  ,; // 10
                                     aPagar[nPagar,05]                                  ,; // 11
                                     aPagar[nPagar,06]                                  ,; // 12
                                     aPagar[nPagar,07]                                  ,; // 13
                                     kVencto                                            ,; // 14
                                     kVenctoR                                           ,; // 15
                                     TRANSFORM(aPagar[nPagar,08], "@E 99,999,999.99")   ,; // 16
                                     kBaixa                                             ,; // 17
                                     TRANSFORM(aPagar[nPagar,09], "@E 99,999,999.99")   ,; // 18
                                     T_CONSULTA->D1_DOC                                 ,; // 19
                                     T_CONSULTA->D1_SERIE                               }) // 20                                
                                
               Else
                                
                  aAdd( aTransito, { ""                                                 ,; // 01 
                                     ""                                                 ,; // 02
                                     ""                                                 ,; // 03
                                     ""                                                 ,; // 04
                                     ""                                                 ,; // 05
                                     ""                                                 ,; // 06
                                     ""                                                 ,; // 07
                                     ""                                                 ,; // 08
                                     ""                                                 ,; // 09
                                     ""                                                 ,; // 10
                                     ""                                                 ,; // 11
                                     aPagar[nPagar,06]                                  ,; // 12
                                     aPagar[nPagar,07]                                  ,; // 13
                                     kVencto                                            ,; // 14
                                     kVenctoR                                           ,; // 15
                                     TRANSFORM(aPagar[nPagar,08], "@E 99,999,999.99")   ,; // 16
                                     kBaixa                                             ,; // 17
                                     TRANSFORM(aPagar[npagar,09], "@E 99,999,999.99")   ,; // 18
                                     T_CONSULTA->D1_DOC                                 ,; // 19
                                     T_CONSULTA->D1_SERIE                               }) // 20                                
                                
               Endif                   

               kVlrParcela := kVlrParcela + aPagar[nPagar,08]
               kVlrSaldo   := kVlrSaldo   + aPagar[nPagar,09]
            
            Next nPagar

            // #########################################
            // Inclui a linha dos totais do documento ##
            // #########################################
            aAdd( aTransito, { ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               "Total do Documento"                      ,;
                               TRANSFORM(kTotalDoc, "@E 99,999,999.99")  ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               TRANSFORM(kVlrParcela, "@E 99,999,999.99"),;
                               ""                                        ,;
                               TRANSFORM(kVlrSaldo, "@E 99,999,999.99")  ,;
                               T_CONSULTA->D1_DOC                        ,;
                               T_CONSULTA->D1_SERIE                      })

            // #######################
            // Registra a Diferença ##
            // #######################
            aAdd( aTransito, { ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               "Diferença (Doc/SCP)"                     ,;
                               TRANSFORM((kTotalDoc - kVlrParcela), "@E 99,999,999.99")  ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               T_CONSULTA->D1_DOC                        ,;
                               T_CONSULTA->D1_SERIE                      })
  
            // ###############################################
            // Inclui a linha em branco entre os documentos ##
            // ###############################################
            aAdd( aTransito, { "","","","","","","","","","","","","","","","","","", T_CONSULTA->D1_DOC, T_CONSULTA->D1_SERIE})

            // #####################################################################
            // Adiciona no array aErros o nº do documento e série que possui erro ##
            // #####################################################################
            If kTotalDoc <> kVlrParcela
               aAdd( aErros , { T_CONSULTA->D1_DOC, T_CONSULTA->D1_SERIE } )
            Else
               aAdd( aCertos, { T_CONSULTA->D1_DOC, T_CONSULTA->D1_SERIE } )         
            Endif   
      
            T_CONSULTA->( DbSkip() )                       
         
         ENDDO

      Else

         // ###################
         // Contas a Receber ##
         // ####################
         If Select("T_CONSULTA") > 0
            T_CONSULTA->( dbCloseArea() )
         EndIf
      
         cSql := ""
         cSql := "SELECT SD2.D2_FILIAL ,"
         cSql += "       SD2.D2_EMISSAO,"
         cSql += "       SD2.D2_DOC    ,"
         cSql += " 	  SD2.D2_SERIE  ,"
         cSql += "       SD2.D2_CLIENTE,"
         cSql += "       SD2.D2_LOJA   ,"
         cSql += "       SA1.A1_NOME   ,"
//       cSql += "       SUM(SD2.D2_TOTAL + SD2.D2_VALCSL + SD2.D2_VALCOF + SD2.D2_VALPIS + SD2.D2_ICMSRET) + (SELECT F2_FRETE"
         cSql += "       SUM(" + Alltrim(KSCR04) + ") + (SELECT TOP(1) " + Alltrim(KSCR03)
         cSql += "                              FROM " + RetSqlName("SF2") + " SF2 "
         cSql += "		      			     WHERE SF2.F2_FILIAL  = SD2.D2_FILIAL  "
         cSql += "					           AND SF2.F2_DOC     = SD2.D2_DOC     "
         cSql += "						       AND SF2.F2_SERIE   = SD2.D2_SERIE   "
         cSql += "					           AND SF2.D_E_L_E_T_ = '') AS TOTAL_NF"
         cSql += "    FROM " + RetSqlName("SD2") + " SD2, "
         cSql += "         " + RetSqlName("SF4") + " SF4, " 
         cSql += "         " + RetSqlName("SA1") + " SA1  "
         cSql += "   WHERE SD2.D2_FILIAL   = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
         cSql += "     AND SD2.D2_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103)"
         cSql += "     AND SD2.D2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dFinal)   + "', 103)"
         cSql += "     AND SD2.D_E_L_E_T_  = ''        "
         cSql += "     AND SF4.F4_CODIGO   = SD2.D2_TES"
         cSql += "     AND SF4.D_E_L_E_T_  = ''        "
         cSql += "     AND SF4.F4_DUPLIC   = 'S'       "
         cSql += "     AND SA1.A1_COD      = SD2.D2_CLIENTE"
         cSql += "     AND SA1.A1_LOJA     = SD2.D2_LOJA   "
         cSql += "   GROUP BY SD2.D2_FILIAL, SD2.D2_EMISSAO, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA, SA1.A1_NOME"
         cSql += "   ORDER BY SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

         T_CONSULTA->( DbGoTop() )
   
         WHILE !T_CONSULTA->( EOF() )
   
            kTotalDoc := T_CONSULTA->TOTAL_NF

            // ####################################################
            // Pesquisa o contas a receber do título posicionado ##
            // ####################################################
            aReceber := {}
         
            DbSelectArea("SE1")
            DbSetOrder(2)
            DbSeek(xfilial("SE1") + T_CONSULTA->D2_CLIENTE + T_CONSULTA->D2_LOJA + T_CONSULTA->D2_SERIE + T_CONSULTA->D2_DOC)
            WHILE !SE1->(EOF())                             .AND. ;
                  SE1->E1_CLIENTE == T_CONSULTA->D2_CLIENTE .AND. ;
                  SE1->E1_LOJA    == T_CONSULTA->D2_LOJA    .AND. ;
                  SE1->E1_PREFIXO == T_CONSULTA->D2_SERIE   .AND. ;
                  SE1->E1_NUM     == T_CONSULTA->D2_DOC
                  aAdd( aReceber, { SE1->E1_VENCTO ,;
                                    SE1->E1_VENCREA,;
                                    SE1->E1_BAIXA  ,;
                                    SE1->E1_NUM    ,;
                                    SE1->E1_PREFIXO,;
                                    SE1->E1_TIPO   ,;
                                    SE1->E1_PARCELA,;
                                    SE1->E1_VALOR  ,;
                                    SE1->E1_SALDO  })
                  SE1->( DbSkip() )
            ENDDO                                     

            If Len(aReceber) == 0

               kEmissao  := Substr(T_CONSULTA->D2_EMISSAO,07,02) + "/" + Substr(T_CONSULTA->D2_EMISSAO,05,02) + "/" + Substr(T_CONSULTA->D2_EMISSAO,01,04)

               // ############################
               // Registra a inconsistência ##
               // ############################
               aAdd( aTransito, { "7"                                                ,; // 01
                                  T_CONSULTA->D2_FILIAL                              ,; // 02
                                  kEmissao                                           ,; // 03
                                  T_CONSULTA->D2_DOC                                 ,; // 04
                                  T_CONSULTA->D2_SERIE                               ,; // 05
                                  T_CONSULTA->D2_CLIENTE                             ,; // 06
                                  T_CONSULTA->D2_LOJA                                ,; // 07
                                  T_CONSULTA->A1_NOME                                ,; // 08
                                  TRANSFORM(T_CONSULTA->TOTAL_NF, "@E 99,999,999.99"),; // 09
                                  ""                                                 ,; // 10
                                  ""                                                 ,; // 11
                                  ""                                                 ,; // 12
                                  ""                                                 ,; // 13
                                  ""                                                 ,; // 14
                                  ""                                                 ,; // 15
                                  ""                                                 ,; // 16
                                  ""                                                 ,; // 17
                                  ""                                                 ,; // 18
                                  T_CONSULTA->D2_DOC                                 ,; // 19
                                  T_CONSULTA->D2_SERIE                               }) // 20                                

               // ################################
               // Registra o total do documento ##
               // ################################
               aAdd( aTransito, { ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  "Total do Documento"                               ,;
                                  TRANSFORM(T_CONSULTA->TOTAL_NF, "@E 99,999,999.99"),;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  ""                                                 ,;
                                  T_CONSULTA->D2_DOC                                 ,;
                                  T_CONSULTA->D2_SERIE                               })
    
               // ###############################
               // Registra uma linha em branco ##
               // ###############################
               aAdd( aTransito, { "","","","","","","","","","","","","","","","","","", T_CONSULTA->D2_DOC, T_CONSULTA->D2_SERIE})

               T_CONSULTA->( DbSkip() )
               Loop

            Endif   

            lPrimeiro   := .T.
            kVlrParcela := 0
            kVlrSaldo   := 0
         
            For nReceber = 1 to Len(aReceber)
         
               If Alltrim(aReceber[nReceber,06]) == "FT"
                  Loop
               Endif    

               If lPrimeiro == .T.
      
                  kEmissao  := Substr(T_CONSULTA->D2_EMISSAO,07,02) + "/" + Substr(T_CONSULTA->D2_EMISSAO,05,02) + "/" + Substr(T_CONSULTA->D2_EMISSAO,01,04)
                  kVencto   := Dtoc(aReceber[nReceber,01])
                  kVenctoR  := Dtoc(aReceber[nReceber,02])
                  kBaixa    := Dtoc(aReceber[nReceber,03])
                  kLegenda  := "2"
                  lPrimeiro := .F.
      
                  aAdd( aTransito, { kLegenda                                            ,; // 01
                                     T_CONSULTA->D2_FILIAL                               ,; // 02
                                     kEmissao                                            ,; // 03
                                     T_CONSULTA->D2_DOC                                  ,; // 04
                                     T_CONSULTA->D2_SERIE                                ,; // 05
                                     T_CONSULTA->D2_CLIENTE                              ,; // 06
                                     T_CONSULTA->D2_LOJA                                 ,; // 07
                                     T_CONSULTA->A1_NOME                                 ,; // 08
                                     TRANSFORM(T_CONSULTA->TOTAL_NF, "@E 99,999,999.99") ,; // 09
                                     aReceber[nReceber,04]                               ,; // 10
                                     aReceber[nReceber,05]                               ,; // 11
                                     aReceber[nReceber,06]                               ,; // 12
                                     aReceber[nReceber,07]                               ,; // 13
                                     kVencto                                             ,; // 14
                                     kVenctoR                                            ,; // 15
                                     TRANSFORM(aReceber[nReceber,08], "@E 99,999,999.99"),; // 16
                                     kBaixa                                              ,; // 17
                                     TRANSFORM(aReceber[nReceber,09], "@E 99,999,999.99"),; // 18
                                     T_CONSULTA->D2_DOC                                  ,; // 19
                                     T_CONSULTA->D2_SERIE                                }) // 20                                
                                  
               Else
                                
                  aAdd( aTransito, { ""                                                  ,; // 01 
                                     ""                                                  ,; // 02
                                     ""                                                  ,; // 03
                                     ""                                                  ,; // 04
                                     ""                                                  ,; // 05
                                     ""                                                  ,; // 06
                                     ""                                                  ,; // 07
                                     ""                                                  ,; // 08
                                     ""                                                  ,; // 09
                                     ""                                                  ,; // 10
                                     ""                                                  ,; // 11
                                     aReceber[nReceber,06]                               ,; // 12
                                     aReceber[nReceber,07]                               ,; // 13
                                     kVencto                                             ,; // 14
                                     kVenctoR                                            ,; // 15
                                     TRANSFORM(aReceber[nReceber,08], "@E 99,999,999.99"),; // 16
                                     kBaixa                                              ,; // 17
                                     TRANSFORM(aReceber[nReceber,09], "@E 99,999,999.99"),; // 18
                                     T_CONSULTA->D2_DOC                                  ,; // 19
                                     T_CONSULTA->D2_SERIE                                }) // 20                                
                                   
               Endif                   

               kVlrParcela := kVlrParcela + aReceber[nReceber,08]
               kVlrSaldo   := kVlrSaldo   + aReceber[nReceber,09]
            
            Next nReceber

            // #########################################
            // Inclui a linha dos totais do documento ##
            // #########################################
            aAdd( aTransito, { ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               "Total do Documento"                      ,;
                               TRANSFORM(kTotalDoc, "@E 99,999,999.99")  ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               TRANSFORM(kVlrParcela, "@E 99,999,999.99"),;
                               ""                                        ,;
                               TRANSFORM(kVlrSaldo, "@E 99,999,999.99")  ,;
                               T_CONSULTA->D2_DOC                        ,;
                               T_CONSULTA->D2_SERIE                      })

            // #######################
            // Registra a diferença ##
            // #######################
            aAdd( aTransito, { ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               "Diferença (DOC/SCR)"                     ,;
                               TRANSFORM((kTotalDoc - kVlrParcela), "@E 99,999,999.99")  ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               ""                                        ,;
                               T_CONSULTA->D2_DOC                        ,;
                               T_CONSULTA->D2_SERIE                      })

            // ###############################################
            // Inclui a linha em branco entre os documentos ##
            // ###############################################
            aAdd( aTransito, { "","","","","","","","","","","","","","","","","","", T_CONSULTA->D2_DOC, T_CONSULTA->D2_SERIE})

            // #####################################################################
            // Adiciona no array aErros o nº do documento e série que possui erro ##
            // #####################################################################
            If kTotalDoc <> kVlrParcela
               aAdd( aErros , { T_CONSULTA->D2_DOC, T_CONSULTA->D2_SERIE } )
            Else
               aAdd( aCertos, { T_CONSULTA->D2_DOC, T_CONSULTA->D2_SERIE } )         
            Endif   

            T_CONSULTA->( DbSkip() )                       
      
         ENDDO
      
      Endif   
   
      // #################################################################
      // Filtra os dados conforme a indicação de visualização dos dados ##
      // #################################################################
      Do Case

         Case Substr(cComboBx4,01,02) == "01"

              For nContar = 1 to Len(aErros)
        
                  lPrimeiro := .T.

                  For nCarga = 1 to Len(aTransito)
           
                      If Alltrim(aTransito[nCarga,19]) == Alltrim(aErros[nContar,01]) .And. Alltrim(aTransito[nCarga,20]) == Alltrim(aErros[nContar,02])

                         If lPrimeiro == .T.
                            kLegenda  := "8"
                            lPrimeiro := .F.
                         Else   
                            kLegenda  := ""                         
                         Endif   

                         aAdd( aBrowse, { kLegenda            ,; // 01
                                          aTransito[nCarga,02],; // 02
                                          aTransito[nCarga,03],; // 03
                                          aTransito[nCarga,04],; // 04
                                          aTransito[nCarga,05],; // 05
                                          aTransito[nCarga,06],; // 06
                                          aTransito[nCarga,07],; // 07
                                          aTransito[nCarga,08],; // 08
                                          aTransito[nCarga,09],; // 09
                                          aTransito[nCarga,10],; // 10
                                          aTransito[nCarga,11],; // 11
                                          aTransito[nCarga,12],; // 12
                                          aTransito[nCarga,13],; // 13
                                          aTransito[nCarga,14],; // 14
                                          aTransito[nCarga,15],; // 15
                                          aTransito[nCarga,16],; // 16
                                          aTransito[nCarga,17],; // 17
                                          aTransito[nCarga,18],; // 18
                                          aTransito[nCarga,19],; // 19
                                          aTransito[nCarga,20]}) // 20
                      Endif

                  Next nCarga                        
               
              Next nContar    

         Case Substr(cComboBx4,01,02) == "02"
   
              For nContar = 1 to Len(aCertos)
   
                  lPrimeiro := .T.

                  For nCarga = 1 to Len(aTransito)
           
                      If Alltrim(aTransito[nCarga,19]) == Alltrim(aCertos[nContar,01]) .And. Alltrim(aTransito[nCarga,20]) == Alltrim(aCertos[nContar,02])

                         If lPrimeiro == .T.
                            kLegenda  := "2"
                            lPrimeiro := .F.
                         Else   
                            kLegenda  := ""                         
                         Endif   

                         aAdd( aBrowse, { kLegenda            ,; // 01
                                          aTransito[nCarga,02],; // 02
                                          aTransito[nCarga,03],; // 03
                                          aTransito[nCarga,04],; // 04
                                          aTransito[nCarga,05],; // 05
                                          aTransito[nCarga,06],; // 06
                                          aTransito[nCarga,07],; // 07
                                          aTransito[nCarga,08],; // 08
                                          aTransito[nCarga,09],; // 09
                                          aTransito[nCarga,10],; // 10
                                          aTransito[nCarga,11],; // 11
                                          aTransito[nCarga,12],; // 12
                                          aTransito[nCarga,13],; // 13
                                          aTransito[nCarga,14],; // 14
                                          aTransito[nCarga,15],; // 15
                                          aTransito[nCarga,16],; // 16
                                          aTransito[nCarga,17],; // 17
                                          aTransito[nCarga,18],; // 18
                                          aTransito[nCarga,19],; // 19
                                          aTransito[nCarga,20]}) // 20
                      Endif

                  Next nCarga                        

              Next nContar
   
         Case Substr(cComboBx4,01,02) == "03"
   
              For nCarga = 1 to Len(aTransito)
           
                  lTemErro := .F.

                  For nContar = 1 to Len(aErros)
               
                      If Alltrim(aErros[nContar,01]) == Alltrim(aTransito[nCarga,19]) .And. Alltrim(aErros[nContar,02]) == Alltrim(aTransito[nCarga,20])
                         lTemErro := .T.
                         Exit
                      Endif
                   
                  Next nContar       

                  kLegenda := IIF(lTemErro == .T., "8", "2")

                  If Empty(Alltrim(aTransito[nCarga,02]))
                      kLegenda := ""
                  Endif    

                  aAdd( aBrowse, { kLegenda            ,; // 01
                                   aTransito[nCarga,02],; // 02
                                   aTransito[nCarga,03],; // 03
                                   aTransito[nCarga,04],; // 04
                                   aTransito[nCarga,05],; // 05
                                   aTransito[nCarga,06],; // 06
                                   aTransito[nCarga,07],; // 07
                                   aTransito[nCarga,08],; // 08
                                   aTransito[nCarga,09],; // 09
                                   aTransito[nCarga,10],; // 10
                                   aTransito[nCarga,11],; // 11
                                   aTransito[nCarga,12],; // 12
                                   aTransito[nCarga,13],; // 13
                                   aTransito[nCarga,14],; // 14
                                   aTransito[nCarga,15],; // 15
                                   aTransito[nCarga,16],; // 16
                                   aTransito[nCarga,17],; // 17
                                   aTransito[nCarga,18],; // 18
                                   aTransito[nCarga,19],; // 19
                                   aTransito[nCarga,20]}) // 20
              Next nCarga                        

      EndCase

      If Len(aBrowse) == 0
         aAdd( aBrowse, { "0","","","","","","","","","","","","","","","","",""})
      Endif   

   Endif

Return(.T.)

// ############################################
// Função que realiza a conciliação contabil ##
// ############################################
Static Function ConcContabil()

   MsgRun("Aguarde! Gerando Conciliação Contábil ...", "Conciliação Contábil",{|| xConcContabil() })

Return(.T.)

// ############################################
// Função que realiza a conciliação contabil ##
// ############################################
Static Function xConcContabil()

   Local cSql := ""
   
   aBrowse := {}

      // ##########################################
      // Realiza a concialição do Contas a Pagar ##
      // ##########################################  
      If Substr(cComboBx3,01,02) == "01"

         If Select("T_CONSULTA") > 0
            T_CONSULTA->( dbCloseArea() )
         EndIf
      
         cSql := ""
         cSql := "SELECT SD1.D1_FILIAL ," + chr(13)
         cSql += "       SD1.D1_DOC    ," + chr(13)
	     cSql += "       SD1.D1_SERIE  ," + chr(13)
         cSql += "       SD1.D1_FORNECE," + chr(13)
	     cSql += "       SD1.D1_LOJA   ," + chr(13)
         cSql += "       SA2.A2_NOME   ," + chr(13)
         cSql += "       SD1.D1_EMISSAO," + chr(13)
	     cSql += "       SUM(SD1.D1_TOTAL + SD1.D1_ICMSRET + SD1.D1_VALFRE + SD1.D1_VALIPI - SD1.D1_VALDESC) AS TOTAL_PRODUTO," + chr(13)
         cSql += "      (SELECT SUM(E2_VALOR) " + chr(13)
	     cSql += "         FROM " + RetSqlName("SE2") + chr(13)
  	     cSql += "        WHERE E2_FILORIG = SD1.D1_FILIAL " + chr(13)
	     cSql += "          AND E2_NUM     = SD1.D1_DOC    " + chr(13)
		 cSql += "          AND E2_PREFIXO = SD1.D1_SERIE  " + chr(13)
		 cSql += "          AND D_E_L_E_T_ = '') AS CONTAS_PAGAR," + chr(13)
         cSql += "      (SELECT TOP(1) CT2_VALOR" + chr(13)
         cSql += "         FROM " + RetSqlName("CT2") + chr(13)
//       cSql += "        WHERE CT2_LP     = '650'" + chr(13)
//       cSql += "          AND CT2_CREDIT = '21010201'" + chr(13)
         cSql += "        WHERE CT2_LP     = '" + Alltrim(kSCP02) + "'" + chr(13)
         cSql += "          AND CT2_CREDIT = '" + Alltrim(kSCP06) + "'" + chr(13)
         cSql += "          AND D_E_L_E_T_ = ''" + chr(13)
         cSql += "          AND CT2_HIST LIKE '%' + SD1.D1_DOC + '%'" + chr(13)
         cSql += "          AND CT2_HIST LIKE '%' + SUBSTRING(SA2.A2_NOME, 1, CHARINDEX(' ', SA2.A2_NOME)) + '%') AS VALOR_CTL," + chr(13)
         cSql += "     (SELECT TOP(1) CT2_HIST" + chr(13)
         cSql += "        FROM " + RetSqlName("CT2") + chr(13)
//       cSql += "       WHERE CT2_LP     = '650'" + chr(13)
//       cSql += "         AND CT2_CREDIT = '21010201'" + chr(13)
         cSql += "        WHERE CT2_LP     = '" + Alltrim(kSCP02) + "'" + chr(13)
         cSql += "          AND CT2_CREDIT = '" + Alltrim(kSCP06) + "'" + chr(13)
         cSql += "         AND D_E_L_E_T_ = ''" + chr(13)
         cSql += "         AND CT2_HIST LIKE '%' + SD1.D1_DOC + '%'" + chr(13)
         cSql += "          AND CT2_HIST LIKE '%' + SUBSTRING(SA2.A2_NOME, 1, CHARINDEX(' ', SA2.A2_NOME)) + '%') AS HISTORICO," + chr(13)
         cSql += "    (SELECT TOP(1) CT2_LOTE + '.' + CT2_SBLOTE" + chr(13)
         cSql += "       FROM " + RetSqlName("CT2") + chr(13)
//       cSql += "      WHERE CT2_LP     = '650'" + chr(13)
//       cSql += "        AND CT2_CREDIT = '21010201'" + chr(13)
         cSql += "        WHERE CT2_LP     = '" + Alltrim(kSCP02) + "'" + chr(13)
         cSql += "          AND CT2_CREDIT = '" + Alltrim(kSCP06) + "'" + chr(13)
         cSql += "        AND D_E_L_E_T_ = ''" + chr(13)
         cSql += "        AND CT2_HIST LIKE '%' + SD1.D1_DOC + '%'" + chr(13)
         cSql += "          AND CT2_HIST LIKE '%' + SUBSTRING(SA2.A2_NOME, 1, CHARINDEX(' ', SA2.A2_NOME)) + '%') AS LOTE," + chr(13)
     	 cSql += "     (SUM(SD1.D1_TOTAL + SD1.D1_ICMSRET + SD1.D1_VALFRE + SD1.D1_VALIPI - SD1.D1_VALDESC) - (SELECT SUM(E2_VALOR)"  + chr(13)
	     cSql += "                                                                                               FROM " + RetSqlName("SE2") + chr(13)
  	     cSql += "                                                                                              WHERE E2_FILORIG = SD1.D1_FILIAL " + chr(13)
         cSql += "      	                                                                                      AND E2_NUM     = SD1.D1_DOC    " + chr(13)
		 cSql += "                                                                                                AND E2_PREFIXO = SD1.D1_SERIE  " + chr(13)
		 cSql += "                                                                                                AND D_E_L_E_T_ = ''))  AS DIFERENCA" + chr(13)
         cSql += "  FROM " + RetSqlName("SD1") + " SD1, " + chr(13)
         cSql += "       " + RetSqlName("SF4") + " SF4, " + chr(13)
     	 cSql += "       " + RetSqlName("SA2") + " SA2  " + chr(13)
         cSql += "   WHERE SD1.D1_FILIAL   = '" + Alltrim(Substr(cComboBx2,01,02)) + "'" + chr(13)
         cSql += "     AND SD1.D1_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103)" + chr(13)
         cSql += "     AND SD1.D1_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dFinal)   + "', 103)" + chr(13)
         cSql += "   AND SD1.D_E_L_E_T_  = ''" + chr(13)
         cSql += "   AND SF4.F4_CODIGO   = SD1.D1_TES    " + chr(13)
         cSql += "   AND SF4.F4_DUPLIC   = 'S'           " + chr(13)
         cSql += "   AND SF4.D_E_L_E_T_  = ''            " + chr(13)
         cSql += "   AND SA2.A2_COD      = SD1.D1_FORNECE" + chr(13)
         cSql += "   AND SA2.A2_LOJA     = SD1.D1_LOJA   " + chr(13)
         cSql += "   AND SA2.D_E_L_E_T_  = ''            " + chr(13)
         cSql += " GROUP BY SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SA2.A2_NOME, SD1.D1_EMISSAO" + chr(13)
         cSql += " ORDER BY SD1.D1_FILIAL, SD1.D1_EMISSAO"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

         T_CONSULTA->( DbGoTop() )
         
         kDataQuebra := T_CONSULTA->D1_EMISSAO
  
         WHILE !T_CONSULTA->( EOF() )

            If T_CONSULTA->CONTAS_PAGAR == T_CONSULTA->VALOR_CTL
               kLegenda := "2"
            Else
               kLegenda := "8"
            Endif   

            // ###############################################
            // Mostra somente registros com inconsistências ##
            // ###############################################
            If Substr(cComboBx5,01,02) == "01"
               If kLegenda <> "8"
                  T_CONSULTA->( DbSkip() )
                  Loop
               Endif
            Endif      

            // ###############################################
            // Mostra somente registros sem inconsistências ##
            // ###############################################
            If Substr(cComboBx5,01,02) == "02"
               If kLegenda <> "2"
                  T_CONSULTA->( DbSkip() )
                  Loop
               Endif
            Endif      

            kEmissao := Substr(T_CONSULTA->D1_EMISSAO,07,02) + "/" + Substr(T_CONSULTA->D1_EMISSAO,05,02) + "/" + Substr(T_CONSULTA->D1_EMISSAO,01,04)

            If kDataQuebra == T_CONSULTA->D1_EMISSAO
            Else
               aAdd( aBrowse, { "0", "", "", "", "", "", "", "", "", "", "", "", "" })
               kDataQuebra := T_CONSULTA->D1_EMISSAO
            Endif   

            aAdd( aBrowse, { kLegenda                                                ,; // 01
                             T_CONSULTA->D1_FILIAL                                   ,; // 02
                             T_CONSULTA->D1_DOC                                      ,; // 03
                             T_CONSULTA->D1_SERIE                                    ,; // 04
                             kEmissao                                                ,; // 05
                             T_CONSULTA->D1_FORNECE                                  ,; // 06
                             T_CONSULTA->D1_LOJA                                     ,; // 07
                             T_CONSULTA->A2_NOME                                     ,; // 08
                             TRANSFORM(T_CONSULTA->TOTAL_PRODUTO, "@E 99,999,999.99"),; // 09
                             TRANSFORM(T_CONSULTA->CONTAS_PAGAR, "@E 99,999,999.99") ,; // 10                          
                             TRANSFORM(T_CONSULTA->VALOR_CTL, "@E 99,999,999.99")    ,; // 11                                                      
                             T_CONSULTA->LOTE                                        ,; // 12
                             T_CONSULTA->HISTORICO                                   }) // 13

            T_CONSULTA->( DbSkip() )
            
         ENDDO   

         If Len(aBrowse) == 0
            aAdd( aBrowse, { "0", "", "", "", "", "", "", "", "", "", "", "", "" })
         Endif   

      Else

         // ###############################
         // Conciliação Contas a receber ##
         // ###############################
         If Select("T_CONSULTA") > 0
            T_CONSULTA->( dbCloseArea() )
         EndIf
      
         cSql := ""
         cSql := "SELECT SD2.D2_FILIAL ,"
         cSql += "       SD2.D2_DOC    ,"
         cSql += "       SD2.D2_SERIE  ,"
         cSql += "       SD2.D2_CLIENTE,"
         cSql += "       SD2.D2_LOJA   ,"
         cSql += "       SA1.A1_NOME   ,"
         cSql += "       SD2.D2_EMISSAO,"
         cSql += "       SUM(SD2.D2_TOTAL + SD2.D2_ICMSRET + SD2.D2_VALFRE + SD2.D2_VALIPI) AS TOTAL_PRODUTO,"
         cSql += "      (SELECT SUM(E1_VALOR)"
         cSql += "         FROM " + RetSqlName("SE1")
         cSql += "        WHERE E1_FILORIG = SD2.D2_FILIAL "
         cSql += "          AND E1_NUM     = SD2.D2_DOC    "
         cSql += "          AND E1_PREFIXO = SD2.D2_SERIE  "
         cSql += "          AND D_E_L_E_T_ = '') AS CONTAS_RECEBER,"
         cSql += "      (SELECT TOP(1) CT2_VALOR"
         cSql += "         FROM " + RetSqlName("CT2")
         cSql += "        WHERE CT2_LP     = '610'"
         cSql += "          AND CT2_DEBITO = '11020101'"
         cSql += "          AND D_E_L_E_T_ = ''"
         cSql += "          AND CT2_HIST LIKE '%' + SD2.D2_DOC + '%'"
         cSql += "          AND CT2_HIST LIKE '%' + SUBSTRING(SA1.A1_NOME, 1, CHARINDEX(' ', SA1.A1_NOME)) + '%') AS VALOR_CTL,"
         cSql += "      (SELECT TOP(1) CT2_HIST"
         cSql += "         FROM " + RetSqlName("CT2")
         cSql += "        WHERE CT2_LP     = '610'"
         cSql += "          AND CT2_DEBITO = '11020101'"
         cSql += "          AND D_E_L_E_T_ = ''"
         cSql += "          AND CT2_HIST LIKE '%' + SD2.D2_DOC + '%'"
         cSql += "          AND CT2_HIST LIKE '%' + SUBSTRING(SA1.A1_NOME, 1, CHARINDEX(' ', SA1.A1_NOME)) + '%') AS HISTORICO,"
         cSql += "      (SELECT TOP(1) CT2_LOTE + '.' + CT2_SBLOTE"
         cSql += "         FROM " + RetSqlName("CT2")
         cSql += "        WHERE CT2_LP     = '610'"
         cSql += "          AND CT2_DEBITO = '11020101'"
         cSql += "          AND D_E_L_E_T_ = ''"
         cSql += "          AND CT2_HIST LIKE '%' + SD2.D2_DOC + '%'"
         cSql += "          AND CT2_HIST LIKE '%' + SUBSTRING(SA1.A1_NOME, 1, CHARINDEX(' ', SA1.A1_NOME)) + '%') AS LOTE,"
         cSql += "      (SUM(SD2.D2_TOTAL + SD2.D2_ICMSRET + SD2.D2_VALFRE + SD2.D2_VALIPI) - (SELECT SUM(E1_VALOR)"
         cSql += "                                                                               FROM " + RetSqlName("SE1")
         cSql += "                                                                              WHERE E1_FILORIG = SD2.D2_FILIAL "
 	     cSql += "                                                                                AND E1_NUM     = SD2.D2_DOC    "
         cSql += "                                                                                AND E1_PREFIXO = SD2.D2_SERIE  "
         cSql += "                                                                                AND D_E_L_E_T_ = ''))  AS DIFERENCA"
         cSql += "   FROM " + RetSqlName("SD2") + " SD2, "
         cSql += "        " + RetSqlName("SF4") + " SF4, "
         cSql += "        " + RetSqlName("SA1") + " SA1  "
         cSql += "   WHERE SD2.D2_FILIAL   = '" + Alltrim(Substr(cComboBx2,01,02)) + "'" + chr(13)
         cSql += "     AND SD2.D2_EMISSAO >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103)" + chr(13)
         cSql += "     AND SD2.D2_EMISSAO <= CONVERT(DATETIME,'" + Dtoc(dFinal)   + "', 103)" + chr(13)
         cSql += "     AND SD2.D_E_L_E_T_  = ''            "
         cSql += "     AND SF4.F4_CODIGO   = SD2.D2_TES    "
         cSql += "     AND SF4.F4_DUPLIC   = 'S'           "
         cSql += "     AND SF4.D_E_L_E_T_  = ''            "
         cSql += "     AND SA1.A1_COD      = SD2.D2_CLIENTE"
         cSql += "     AND SA1.A1_LOJA     = SD2.D2_LOJA   "
         cSql += "     AND SA1.D_E_L_E_T_  = ''            "
         cSql += "   GROUP BY SD2.D2_FILIAL, SD2.D2_DOC, SD2.D2_SERIE, SD2.D2_CLIENTE, SD2.D2_LOJA, SA1.A1_NOME, SD2.D2_EMISSAO"
         cSql += "   ORDER BY SD2.D2_FILIAL, SD2.D2_EMISSAO"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

         T_CONSULTA->( DbGoTop() )

         kDataQuebra := T_CONSULTA->D2_EMISSAO
  
         WHILE !T_CONSULTA->( EOF() )

            If T_CONSULTA->CONTAS_RECEBER == T_CONSULTA->VALOR_CTL
               kLegenda := "2"
            Else
               kLegenda := "8"
            Endif   

            // ###############################################
            // Mostra somente registros com inconsistências ##
            // ###############################################
            If Substr(cComboBx5,01,02) == "01"
               If kLegenda <> "8"
                  T_CONSULTA->( DbSkip() )
                  Loop
               Endif
            Endif      

            // ###############################################
            // Mostra somente registros sem inconsistências ##
            // ###############################################
            If Substr(cComboBx5,01,02) == "02"
               If kLegenda <> "2"
                  T_CONSULTA->( DbSkip() )
                  Loop
               Endif
            Endif      

            kEmissao := Substr(T_CONSULTA->D2_EMISSAO,07,02) + "/" + Substr(T_CONSULTA->D2_EMISSAO,05,02) + "/" + Substr(T_CONSULTA->D2_EMISSAO,01,04)

            If kDataQuebra == T_CONSULTA->D2_EMISSAO
            Else
               aAdd( aBrowse, { "0", "", "", "", "", "", "", "", "", "", "", "", "" })
               kDataQuebra := T_CONSULTA->D2_EMISSAO
            Endif   

            aAdd( aBrowse, { kLegenda                                                 ,; // 01
                             T_CONSULTA->D2_FILIAL                                    ,; // 02
                             T_CONSULTA->D2_DOC                                       ,; // 03
                             T_CONSULTA->D2_SERIE                                     ,; // 04
                             kEmissao                                                 ,; // 05
                             T_CONSULTA->D2_CLIENTE                                   ,; // 06
                             T_CONSULTA->D2_LOJA                                      ,; // 07
                             T_CONSULTA->A1_NOME                                      ,; // 08
                             TRANSFORM(T_CONSULTA->TOTAL_PRODUTO , "@E 99,999,999.99"),; // 09
                             TRANSFORM(T_CONSULTA->CONTAS_RECEBER, "@E 99,999,999.99"),; // 10                          
                             TRANSFORM(T_CONSULTA->VALOR_CTL     , "@E 99,999,999.99"),; // 11                                                      
                             T_CONSULTA->LOTE                                         ,; // 12
                             T_CONSULTA->HISTORICO                                    }) // 13

            T_CONSULTA->( DbSkip() )
            
         ENDDO   

         If Len(aBrowse) == 0
            aAdd( aBrowse, { "0", "", "", "", "", "", "", "", "", "", "", "", "" })
         Endif   

      Endif
                       
Return(.T.)

// ##################################################################################
// Função que abre informação de parâmetros para o conciliador Financeiro/Contábil ##
// ##################################################################################
Static Function SYSPARAM()

   Local cMemo10 := ""
   Local cMemo11 := ""
   Local cMemo12 := ""
   Local cMemo13 := ""
   Local cMemo3	 := ""
   Local cMemo4	 := ""
   Local cMemo5	 := ""
   Local cMemo9	 := ""
   Local oMemo10
   Local oMemo11
   Local oMemo12
   Local oMemo13
   Local oMemo3
   Local oMemo4
   Local oMemo5
   Local oMemo9

   Private aContaP   := {"0 - Selecione", "1 - Cadastro do Fornecedor", "2 - Lançamento padrão"}
   Private aContaR   := {"0 - Selecione", "1 - Cadastro do Cliente"   , "2 - Lançamento padrão"}
   Private cContaP   := Space(20)
   Private cContaR   := Space(20)
   Private cNumPLP   := Space(03)
   Private cNumPLR   := Space(03)
   Private cTabela1P := ""
   Private cTabela2P := ""
   Private cTabela3P := ""
   Private cTabela1R := ""
   Private cTabela2R := ""
   Private cTabela3R := ""

   Private cComboBx100
   Private cComboBx200
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4      
   Private oMemo6
   Private oMemo7
   Private oMemo8
   Private oMemo14
   Private oMemo15
   Private oMemo16

   Private oDlgPAR

   // #########################################
   // Carrega as Variáveis do Contas a Pagar ##
   // #########################################
   Do Case
      Case kSCP01 == "0"
           cComboBx100 := "0 - Selecione"
      Case kSCP01 == "1"
           cComboBx100 := "1 - Cadastro do Fornecedor"
      Case kSCP01 == "2"
           cComboBx100 := "2 - Lançamento padrão"
      OtherWise
           cComboBx100 := "0 - Selecione"
   EndCase

   cContaP   := Alltrim(KSCP06) + Space(20 - Len(Alltrim(KSCP06)))
   cNumPLP   := kSCP02
   cTabela1P := kSCP03
   cTabela2P := kSCP04
   cTabela3P := kSCP05

   // ###########################################
   // Carrega as Variáveis do Contas a Receber ##
   // ###########################################
   Do Case
      Case kSCR01 == "0"
           cComboBx200 := "0 - Selecione"
      Case kSCR01 == "1"
           cComboBx200 := "1 - Cadastro do Cliente"
      Case kSCR01 == "2"
           cComboBx200 := "2 - Lançamento padrão"
      OtherWise
           cComboBx200 := "0 - Selecione"
   EndCase                                                                            

   cContaR   := Alltrim(KSCR06) + Space(20 - Len(Alltrim(KSCR06)))
   cNumPLR   := kSCR02
   cTabela1R := kSCR03
   cTabela2R := kSCR04
   cTabela3R := kSCR05

   // ################################################
   // Desenha a tela para visualiação das variáveis ##
   // ################################################
   DEFINE MSDIALOG oDlgPAR TITLE "Conciliador Financeiro/Contábil" FROM C(178),C(181) TO C(546),C(967) PIXEL

   @ C(004),C(002) Jpeg FILE "SYSFINAN.PNG" Size C(150),C(019) PIXEL NOBORDER OF oDlgPAR

   @ C(025),C(002) GET oMemo3  Var cMemo3  MEMO Size C(386),C(001) PIXEL OF oDlgPAR
   @ C(092),C(002) GET oMemo4  Var cMemo4  MEMO Size C(386),C(001) PIXEL OF oDlgPAR
   @ C(025),C(002) GET oMemo5  Var cMemo5  MEMO Size C(001),C(155) PIXEL OF oDlgPAR
   @ C(025),C(387) GET oMemo9  Var cMemo9  MEMO Size C(001),C(155) PIXEL OF oDlgPAR
   @ C(160),C(002) GET oMemo10 Var cMemo10 MEMO Size C(386),C(001) PIXEL OF oDlgPAR
   @ C(179),C(002) GET oMemo11 Var cMemo11 MEMO Size C(386),C(001) PIXEL OF oDlgPAR
   @ C(036),C(002) GET oMemo12 Var cMemo12 MEMO Size C(386),C(001) PIXEL OF oDlgPAR
   @ C(104),C(002) GET oMemo13 Var cMemo13 MEMO Size C(386),C(001) PIXEL OF oDlgPAR

   @ C(027),C(158) Say "SCP - CONTAS A PAGAR"    Size C(064),C(008) COLOR CLR_RED   PIXEL OF oDlgPAR
   @ C(041),C(006) Say "Uilizar Conta Contábil"  Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgPAR
   @ C(041),C(196) Say "Nº Conta Contábil"       Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgPAR
   @ C(041),C(326) Say "Nº da LP"                Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgPAR
   @ C(109),C(196) Say "Nº Conta Contábil"       Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgPAR
   @ C(109),C(326) Say "Nº da LP"                Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgPAR
   @ C(054),C(006) Say "Campos Somatório (SF1)"  Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlgPAR
   @ C(067),C(006) Say "Campos Somatório (SD1)"  Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlgPAR
   @ C(080),C(006) Say "Campos Somatório (SE2)"  Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgPAR
   @ C(095),C(157) Say "SCR - CONTAS A RECEBER"  Size C(072),C(008) COLOR CLR_BLUE  PIXEL OF oDlgPAR
   @ C(109),C(006) Say "Utilizar Conta Contábil" Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlgPAR
   @ C(122),C(006) Say "Campos Somatório (SF2)"  Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlgPAR
   @ C(135),C(006) Say "Campos Somatório (SD2)"  Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgPAR
   @ C(148),C(006) Say "Campos Somatório (SE1)"  Size C(059),C(008) COLOR CLR_BLACK PIXEL OF oDlgPAR

   @ C(040),C(068) ComboBox cComboBx100 Items aContaP        Size C(125),C(010)                              PIXEL OF oDlgPAR
   @ C(040),C(242) MsGet    oGet3       Var   cContaP        Size C(079),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPAR When Substr(cComboBx100,01,01) == "2"
   @ C(040),C(350) MsGet    oGet1       Var   cNumPLP        Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPAR
   @ C(053),C(068) GET      oMemo6      Var   cTabela1P MEMO Size C(315),C(009)                              PIXEL OF oDlgPAR
   @ C(066),C(068) GET      oMemo7      Var   cTabela2P MEMO Size C(315),C(009)                              PIXEL OF oDlgPAR
   @ C(079),C(068) GET      oMemo8      Var   cTabela3P MEMO Size C(315),C(009)                              PIXEL OF oDlgPAR
   @ C(108),C(068) ComboBox cComboBx200 Items aContaR        Size C(125),C(010)                              PIXEL OF oDlgPAR
   @ C(108),C(242) MsGet    oGet4       Var   cContaR        Size C(079),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPAR When Substr(cComboBx200,01,01) == "2"
   @ C(108),C(350) MsGet    oGet2       Var   cNumPLR        Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgPAR
   @ C(121),C(068) GET      oMemo14     Var   cTabela1R MEMO Size C(315),C(009)                              PIXEL OF oDlgPAR
   @ C(134),C(068) GET      oMemo15     Var   cTabela2R MEMO Size C(315),C(009)                              PIXEL OF oDlgPAR
   @ C(147),C(068) GET      oMemo16     Var   cTabela3R MEMO Size C(315),C(009)                              PIXEL OF oDlgPAR

   @ C(164),C(158) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgPAR ACTION( gSYSPARAM() )
   @ C(164),C(196) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgPAR ACTION( oDlgPAR:End() )

   ACTIVATE MSDIALOG oDlgPAR CENTERED 

Return(.T.)

// #################################
// Função que grava os parâmetros ##
// #################################
Static Function gSYSPARAM()

   Local cString  := ""
   Local cStringP := ""
   Local cStringR := ""
   Local cArquivo := "SYSPARAM\SYSFINAN.CFG"   

   If Substr(cComboBx100,01,01) == "0"
      MsgAlert("Conta Contábil a ser utilizada não selecionada.")
      Return(.T.)
   Endif
         
   If Empty(Alltrim(cNumPLP))
      MsgAlert("Nº PL não informado.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cTabela1P))
      MsgAlert("Campos para somatório da tabela SF1 não informados.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cTabela2P))
      MsgAlert("Campos para somatório da tabela SD1 não informados.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cTabela3P))
      MsgAlert("Campos para somatório da tabela SE2 não informados.")
      Return(.T.)
   Endif
      
   If Substr(cComboBx100,01,01) == "0"
      MsgAlert("Conta Contábil a ser utilizada não selecionada.")
      Return(.T.)
   Endif
         
   If Empty(Alltrim(cNumPLR))
      MsgAlert("Nº PL não informado.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cTabela1R))
      MsgAlert("Campos para somatório da tabela SF1 não informados.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(cTabela2R))
      MsgAlert("Campos para somatório da tabela SD1 não informados.")
      Return(.T.)
   Endif

   If Empty(Alltrim(cTabela3R))
      MsgAlert("Campos para somatório da tabela SE2 não informados.")
      Return(.T.)
   Endif
      
   If Substr(cComboBx100,01,01) == "2"
      If Empty(Alltrim(cContaP))
         MsgAlert("Nº da Conta Contábil do Contas a Pagar não informada.")
         Return(.T.)
      Endif   
   Else
      cContaP := Space(20)
   Endif

   If Substr(cComboBx200,01,01) == "2"
      If Empty(Alltrim(cContaR))
         MsgAlert("Nº da Conta Contábil do Contas a receber não informada.")
         Return(.T.)
      Endif   
   Else
      cContaR := Space(20)
   Endif

   // ##################################
   // Prepara as string para gravação ##
   // ##################################
   cStringP := ""
   cStringP := "[SCP]"                   + "|" + ;
               Substr(cComboBx100,01,01) + "|" + ;
               cNumPLP                   + "|" + ;
               Alltrim(cTabela1P)        + "|" + ;
               Alltrim(cTabela2P)        + "|" + ;
               Alltrim(cTabela3P)        + "|" + ;
               Alltrim(cContaP)          + "|" + ; 
               "[/SCP]"

   kSCP01 := Substr(cComboBx100,01,01)
   kSCP02 := cNumPLP
   kSCP03 := Alltrim(cTabela1P)
   kSCP04 := Alltrim(cTabela2P)
   kSCP05 := Alltrim(cTabela3P)
   kSCP06 := Alltrim(cContaP)

   cStringR := ""
   cStringR := "[SCR]"                   + "|" + ;
               Substr(cComboBx100,01,01) + "|" + ;
               cNumPLR                   + "|" + ;
               Alltrim(cTabela1R)        + "|" + ;
               Alltrim(cTabela2R)        + "|" + ;
               Alltrim(cTabela3R)        + "|" + ;
               Alltrim(cContaR)          + "|" + ; 
               "[/SCR]" 

   kSCR01 := Substr(cComboBx100,01,01)
   kSCR02 := cNumPLR
   kSCR03 := Alltrim(cTabela1R)
   kSCR04 := Alltrim(cTabela2R)
   kSCR05 := Alltrim(cTabela3R)
   kSCR06 := Alltrim(cContaR)

   cString := cStringP + "@" + cStringR + "@"

   // ################################
   // Grava o arquivo de parâmetros ##
   // ################################
   If File(cArquivo)
      
      If (MsgYesNo("Arquivo já existe na pasta. Deseja sobrescrever o arquivo?","Atenção!"))

         nHdl := fCreate(cArquivo)
         fWrite (nHdl, cString ) 
         fClose(nHdl)

         oDlgPar:End()
            
      Else
         
         oDlgPar:End()
         Return(.T.)
         
      Endif
         
   Else
         
      nHdl := fCreate(cArquivo)
      fWrite (nHdl, cString ) 
      fClose(nHdl)

      oDlgPar:End()

   Endif            
   
Return(.T.)

// ################################################################
// Função que pesquisa os parâmetros para execusão das pesquisas ##
// ################################################################
Static Function Carregaparam()

   Local aFiles
   Local aSizes
   Local cParametros := "SYSPARAM\SYSFINAN.CFG"

   aParametros := {}

   // ####################################################################################
   // Verifica se o arquivo de parâmetros para o Conciliador Financeiro/Contábil existe ##
   // ####################################################################################
   If !File(cParametros)
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Não foram criados os parâmetros para realizar a Conciliação Financeira/Contábil." + chr(13) + chr(10) + ;
               "Selecione o botão Parâmetros")
      Return(.T.)
   Endif

   // ###############################
   // Abre o arquivo de parâmetros ##
   // ###############################
   nHandle := FOPEN(cParametros, FO_READWRITE + FO_SHARED)
     
   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo de parâmetros.")
      FCLOSE(cRetorno)
      Return(.T.)
   Endif

   // ################################
   // Lê o tamanho total do arquivo ##
   // ################################
   nLidos := 0
   FSEEK(nHandle,0,0)
   nTamArq := FSEEK(nHandle,0,2)
   FSEEK(nHandle,0,0)

   // ########################
   // Lê todos os Registros ##
   // ########################
   xBuffer:=Space(nTamArq)
   FREAD(nHandle,@xBuffer,nTamArq)
   
   cString := xBuffer

   // ##################
   // Fecha o arquivo ##
   // ##################
   FCLOSE(nHandle)

   // ##################
   // Fecha o arquivo ##
   // ##################
   FCLOSE(cParametros)

   // ##################################################
   // Carrega os dados do retorno para o array aDados ##
   // ##################################################

   // #######################################
   // Separa os campos e os grava no array ##
   // #######################################
   kPar01 := U_P_CORTA(cString, "@", 1)
   kPar02 := U_P_CORTA(cString, "@", 2)

   kSCP01 := U_P_CORTA(kpar01, "|", 2)
   kSCP02 := U_P_CORTA(kpar01, "|", 3)
   kSCP03 := U_P_CORTA(kpar01, "|", 4)
   kSCP04 := U_P_CORTA(kpar01, "|", 5)
   kSCP05 := U_P_CORTA(kpar01, "|", 6)
   kSCP06 := U_P_CORTA(kpar01, "|", 7)

   kSCR01 := U_P_CORTA(kpar02, "|", 2)
   kSCR02 := U_P_CORTA(kpar02, "|", 3)
   kSCR03 := U_P_CORTA(kpar02, "|", 4)
   kSCR04 := U_P_CORTA(kpar02, "|", 5)
   kSCR05 := U_P_CORTA(kpar02, "|", 6)
   kSCR06 := U_P_CORTA(kpar02, "|", 7)

Return(.T.)

// ###################################################
// Função que mostra o detalhe da linha selecionada ##
// ###################################################
Static Function MDetalhe()

   Local nContar  := 0
   Local lChumba  := .F.
   Local cMemo1	  := ""
   Local cDetalhe := ""
   Local oMemo1
   Local oMemo2

   DEFINE FONT oFont Name "Courier New" Size 0, 16
   
   Private oDlgD

   If Substr(cComboBx4,01,02) == "01"

      cDetalhe := "Filial.................: " + aBrowse[oBrowse:nAt,02] + chr(13) + chr(10) + ;
                  "Dta Emissão............: " + aBrowse[oBrowse:nAt,03] + chr(13) + chr(10) + ;
                  "Documento..............: " + aBrowse[oBrowse:nAt,04] + chr(13) + chr(10) + ;
                  "Série..................: " + aBrowse[oBrowse:nAt,05] + chr(13) + chr(10) + ;
                  "Cliente................: " + aBrowse[oBrowse:nAt,06] + chr(13) + chr(10) + ;
                  "Loja...................: " + aBrowse[oBrowse:nAt,07] + chr(13) + chr(10) + ;
                  "Descrição dos Clientes.: " + aBrowse[oBrowse:nAt,08] + chr(13) + chr(10) + ;
                  "Total Documento........: " + aBrowse[oBrowse:nAt,09] + chr(13) + chr(10) + ;
                  "Nº do Título...........: " + aBrowse[oBrowse:nAt,10] + chr(13) + chr(10) + ;
                  "Prefixo................: " + aBrowse[oBrowse:nAt,11] + chr(13) + chr(10) + ;
                  "Tipo...................: " + aBrowse[oBrowse:nAt,12] + chr(13) + chr(10) + ;
                  "Parcela................: " + aBrowse[oBrowse:nAt,13] + chr(13) + chr(10) + ;
                  "Vencimento.............: " + aBrowse[oBrowse:nAt,14] + chr(13) + chr(10) + ;
                  "Vcto Real..............: " + aBrowse[oBrowse:nAt,15] + chr(13) + chr(10) + ;
                  "Valor Parcela..........: " + aBrowse[oBrowse:nAt,16] + chr(13) + chr(10) + ;
                  "Dta Baixa..............: " + aBrowse[oBrowse:nAt,17] + chr(13) + chr(10) + ;
                  "Saldo Parcela..........: " + aBrowse[oBrowse:nAt,18] + chr(13) + chr(10)

   Else         	        	          

      cDetalhe := "Filial..........................: " + aBrowse[oBrowse:nAt,02] + chr(13) + chr(10) + ;
                  "Documento.......................: " + aBrowse[oBrowse:nAt,03] + chr(13) + chr(10) + ;
                  "Série...........................: " + aBrowse[oBrowse:nAt,04] + chr(13) + chr(10) + ;
                  "Dta Emissão.....................: " + aBrowse[oBrowse:nAt,05] + chr(13) + chr(10) + ;
                  "Fornecedor/Cliente..............: " + aBrowse[oBrowse:nAt,06] + chr(13) + chr(10) + ;
                  "Loja............................: " + aBrowse[oBrowse:nAt,07] + chr(13) + chr(10) + ;
                  "Descrição Fornecedores/Clientes.: " + aBrowse[oBrowse:nAt,08] + chr(13) + chr(10) + ;
                  "Total Doc. Entrada..............: " + aBrowse[oBrowse:nAt,09] + chr(13) + chr(10) + ;
                  "Total Títulos...................: " + aBrowse[oBrowse:nAt,10] + chr(13) + chr(10) + ;
                  "Total Contabilizado.............: " + aBrowse[oBrowse:nAt,11] + chr(13) + chr(10) + ;
                  "Lote/Sub-Lote...................: " + aBrowse[oBrowse:nAt,12] + chr(13) + chr(10) + ;
                  "Histórico.......................: " + aBrowse[oBrowse:nAt,13] + chr(13) + chr(10)

   Endif

   DEFINE MSDIALOG oDlgD TITLE "Detalhe Registro Selecionado" FROM C(178),C(181) TO C(629),C(749) PIXEL

   @ C(004),C(002) Jpeg FILE "SYSFINAN.PNG" Size C(146),C(016) PIXEL NOBORDER OF oDlgD

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(279),C(001) PIXEL OF oDlgD

   @ C(032),C(005) GET oMemo2 Var cDetalhe MEMO Size C(275),C(176) PIXEL OF oDlgD FONT oFont When lChumba

   @ C(211),C(124) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgD ACTION( oDlgD:End() )

   ACTIVATE MSDIALOG oDlgD CENTERED 

Return(.T.)











/*
SELECT SD1.D1_FILIAL ,
       SD1.D1_DOC    ,
	   SD1.D1_SERIE  ,
       SD1.D1_FORNECE,
	   SD1.D1_LOJA   ,
       SA2.A2_NOME   ,

       SD1.D1_EMISSAO,
	   SD1.D1_DTDIGIT,

	   SUM(SD1.D1_TOTAL + SD1.D1_ICMSRET + SD1.D1_VALFRE + SD1.D1_VALIPI - SD1.D1_VALDESC) AS TOTAL_PRODUTO,

      (SELECT SUM(E2_VALOR) 
	    FROM SE2010 
  	   WHERE E2_FILORIG = SD1.D1_FILIAL 
	     AND E2_NUM     = SD1.D1_DOC 
		 AND E2_PREFIXO = SD1.D1_SERIE 
		 AND D_E_L_E_T_ = '') AS CONTAS_PAGAR,

       (SELECT TOP(1) CT2_VALOR
         FROM CT2010 
        WHERE CT2_LP     = '650'
          AND CT2_CREDIT = '21010201'
          AND D_E_L_E_T_ = ''
          AND CT2_HIST LIKE '%' + SD1.D1_DOC + '%'
		  AND CT2_HIST LIKE '%' + SUBSTRING(SA2.A2_NOME, 1, CHARINDEX(' ', SA2.A2_NOME)) + '%') AS VALOR_CTL,

       (SELECT TOP(1) CT2_HIST
         FROM CT2010 
        WHERE CT2_LP     = '650'
          AND CT2_CREDIT = '21010201'
          AND D_E_L_E_T_ = ''
          AND CT2_HIST LIKE '%' + SD1.D1_DOC + '%'
		  AND CT2_HIST LIKE '%' + SUBSTRING(SA2.A2_NOME, 1, CHARINDEX(' ', SA2.A2_NOME)) + '%') AS VALOR_CTL,

       (SELECT TOP(1) CT2_LOTE + '.' + CT2_SBLOTE
         FROM CT2010 
        WHERE CT2_LP     = '650'
          AND CT2_CREDIT = '21010201'
          AND D_E_L_E_T_ = ''
          AND CT2_HIST LIKE '%' + SD1.D1_DOC + '%'
		  AND CT2_HIST LIKE '%' + SUBSTRING(SA2.A2_NOME, 1, CHARINDEX(' ', SA2.A2_NOME)) + '%') AS VALOR_CTL,

	  (SUM(SD1.D1_TOTAL + SD1.D1_ICMSRET + SD1.D1_VALFRE + SD1.D1_VALIPI - SD1.D1_VALDESC) - (SELECT SUM(E2_VALOR) 
	                          FROM SE2010 
  	                          WHERE E2_FILORIG = SD1.D1_FILIAL 
	                            AND E2_NUM     = SD1.D1_DOC 
		                        AND E2_PREFIXO = SD1.D1_SERIE 
		                        AND D_E_L_E_T_ = ''))  AS DIFERENCA
  FROM SD1010 SD1,
       SF4010 SF4,
	   SA2010 SA2
 WHERE SD1.D1_FILIAL   = '01'
   AND SD1.D1_EMISSAO >= '20171001'
   AND SD1.D1_EMISSAO <= '20171017'
   AND SD1.D_E_L_E_T_  = ''
   AND SF4.F4_CODIGO   = SD1.D1_TES
   AND SF4.F4_DUPLIC   = 'S'
   AND SF4.D_E_L_E_T_  = ''
   AND SA2.A2_COD      = SD1.D1_FORNECE
   AND SA2.A2_LOJA     = SD1.D1_LOJA
   AND SA2.D_E_L_E_T_  = ''
 GROUP BY SD1.D1_FILIAL, SD1.D1_DOC, SD1.D1_SERIE, SD1.D1_FORNECE, SD1.D1_LOJA, SA2.A2_NOME, SD1.D1_EMISSAO, SD1.D1_DTDIGIT

--SELECT * FROM SD1010 WHERE D1_DOC = '006533'
--SELECT * FROM SE2010 WHERE E2_NUM = '000002044'



--SELECT SUBSTRING(A1_NOME, 1, CHARINDEX(' ', A1_NOME)) FROM SA1010 

*/