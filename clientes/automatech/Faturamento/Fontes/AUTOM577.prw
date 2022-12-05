#Include "Protheus.ch"
#INCLUDE "jpeg.ch"    
#Include "restful.ch"
#Include "totvs.ch"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"

// ####################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                             ##
// --------------------------------------------------------------------------------- ##
// Referencia: AUTOM577.PRW                                                          ##
// Parâmetros: Nenhum                                                                ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                       ##
// --------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                               ##
// Data......: 25/05/2017                                                            ##
// Objetivo..: Comissões de Distribuidores (Pedidos Externos)                        ##
// #################################################################################### 

User Function AUTOM577()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private aEmpresa     := U_AUTOM539(1, "")
   Private aFilial      := U_AUTOM539(2, cEmpAnt)
   Private aStatus      := {"0-Todos"      , "1-A Faturar" , "2-Fat.Total", "3-A Fat.Parcial"}
   Private aTipoData    := {"1-Faturamento", "2-Vencimento"}
   Private aPesquisa    := {}
   Private aAchados     := {}
   Private aEncontrados := {}
   Private aCopia       := {}
   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4   
   Private cComboBx5   
   Private cInicial     := Ctod("  /  /    ")
   Private cFinal       := Ctod("  /  /    ")
   Private cFornece     := Space(006)
   Private cLoja        := Space(003)
   Private cNomeFor     := Space(060)
   Private cString      := Space(100)
   Private nTotalCom    := 0
   Private nTotalFat    := 0
   Private nTotalAfa    := 0
   Private nTotalSal    := 0
   Private nTotalPed    := 0
   Private lNinformado  := .F.
   Private lDataEmissao := .T.
   Private lDataVencime := .F.
   Private lEncontrados := .F.
           
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
   Private oGet10
   Private oGet11
   Private oCheckBox1
   Private oCheckBox2
   Private oCheckBox3   
   Private oCheckBox4

   Private oDlg

   Private aAdicional := {}

   Private aLista     := {}
   Private oLista

   Private oVerde     := LoadBitmap(GetResources(),'br_verde')
   Private oVermelho  := LoadBitmap(GetResources(),'br_vermelho')
   Private oAzul      := LoadBitmap(GetResources(),'br_azul')
   Private oAmarelo   := LoadBitmap(GetResources(),'br_amarelo')
   Private oPreto     := LoadBitmap(GetResources(),'br_preto')
   Private oLaranja   := LoadBitmap(GetResources(),'br_laranja')
   Private oCinza     := LoadBitmap(GetResources(),'br_cinza')
   Private oBranco    := LoadBitmap(GetResources(),'br_branco')
   Private oPink      := LoadBitmap(GetResources(),'br_pink')
   Private oCancel    := LoadBitmap(GetResources(),'br_cancel')
   Private oEncerra   := LoadBitmap(GetResources(),'br_marrom')

   Private oOk        := LoadBitmap( GetResources(), "LBOK" )
   Private oNo        := LoadBitmap( GetResources(), "LBNO" )

   DEFINE FONT oFont Name "Courier New" Size 0, 14

   U_AUTOM628("AUTOM577")

   aAdd( aPesquisa, "00-Selecione"              ) // 00
   aAdd( aPesquisa, "01-NF Dist."               ) // 03
   aAdd( aPesquisa, "02-Distrib."               ) // 16
   aAdd( aPesquisa, "03-Loja"                   ) // 17
   aAdd( aPesquisa, "04-Desc.Distribuidores"    ) // 18
   aAdd( aPesquisa, "05-Nº PVenda"              ) // 19
   aAdd( aPesquisa, "06-Ped.Externo"            ) // 21
   aAdd( aPesquisa, "07-Nº NFiscal"             ) // 23
   aAdd( aPesquisa, "08-Série"                  ) // 24
   aAdd( aPesquisa, "09-Cliente"                ) // 25
   aAdd( aPesquisa, "10-Loja"                   ) // 26
   aAdd( aPesquisa, "11-Descrição dos Clientes" ) // 27

   DEFINE MSDIALOG oDlg TITLE "Inclusão Automática de Pedidos de Venda para Cobrança de Comissões de Distribuidores" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(122),C(026) PIXEL NOBORDER OF oDlg
   @ C(199),C(002) Jpeg FILE "br_vermelho.png" Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(199),C(041) Jpeg FILE "br_amarelo.png"  Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(199),C(104) Jpeg FILE "br_verde.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg
   @ C(207),C(003) GET oMemo2 Var cMemo2 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Empresa"                     Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(062) Say "Filiais"                     Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(120) Say "Dta Inicial"                 Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(159) Say "Dta Final"                   Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(198) Say "Tipo Data"                   Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(234) Say "Status"                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(274) Say "Distribuidor"                Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(057),C(005) Say "Relação de Pedidos de Venda" Size C(074),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(188),C(005) Say "Pesquisar por"               Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(185),C(183) Say "Total Ped.Vendas"            Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(185),C(247) Say "Total Comissões"             Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(185),C(311) Say "Total Faturado"              Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(185),C(375) Say "Total A Faturar"             Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(185),C(439) Say "Saldo A Faturar"             Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(199),C(015) Say "A Faturar"                   Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(199),C(053) Say "Faturamento Parcial"         Size C(048),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(199),C(116) Say "Faturamento Total"           Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(046),C(005) ComboBox cComboBx1  Items aEmpresa     Size C(054),C(010)                              PIXEL OF oDlg ON CHANGE AlteraCombo()
   @ C(046),C(062) ComboBox cComboBx2  Items aFilial      Size C(054),C(010)                              PIXEL OF oDlg
   @ C(046),C(120) MsGet    oGet1      Var   cInicial     Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(159) MsGet    oGet2      Var   cFinal       Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(197) ComboBox cComboBx4  Items aTipoData    Size C(037),C(010)                              PIXEL OF oDlg
   @ C(046),C(234) ComboBox cComboBx3  Items aStatus      Size C(037),C(010)                              PIXEL OF oDlg
   @ C(046),C(274) MsGet    oGet3      Var   cFornece     Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA2")
   @ C(046),C(302) MsGet    oGet4      Var   cLoja        Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( CaptaDist() )
   @ C(046),C(323) MsGet    oGet5      Var   cNomeFor     Size C(135),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(036),C(323) CheckBox oCheckBox1 Var   lNinformado  Prompt "PV com Distribuidor não informado" Size C(091),C(008) PIXEL OF oDlg
   @ C(195),C(183) MsGet    oGet11     Var   nTotalPed    Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999999.99" PIXEL OF oDlg When lChumba
   @ C(195),C(247) MsGet    oGet7      Var   nTotalCom    Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999999.99" PIXEL OF oDlg When lChumba
   @ C(195),C(311) MsGet    oGet8      Var   nTotalFat    Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999999.99" PIXEL OF oDlg When lChumba
   @ C(195),C(375) MsGet    oGet9      Var   nTotalAfa    Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999999.99" PIXEL OF oDlg When lChumba
   @ C(195),C(439) MsGet    oGet10     Var   nTotalSal    Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999999.99" PIXEL OF oDlg When lChumba
   @ C(043),C(461) Button "Pesquisar"       Size C(037),C(012) PIXEL OF oDlg ACTION( PsqExterno() )
   @ C(210),C(003) Button "MT"              Size C(015),C(012) PIXEL OF oDlg ACTION( MrcDmrcReg(1) )        
   @ C(210),C(019) Button "DT"              Size C(015),C(012) PIXEL OF oDlg ACTION( MrcDmrcReg(2) )
   @ C(186),C(038) MsGet    oGet6     Var   cString   Size C(072),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(188),C(112) ComboBox cComboBx5 Items aPesquisa Size C(042),C(010)                              PIXEL OF oDlg
   @ C(186),C(156) Button ">>>"                       Size C(018),C(012)                              PIXEL OF oDlg ACTION( BuscaLista() )

   @ C(210),C(035) Button "Zoom"          Size C(037),C(012) PIXEL OF oDlg ACTION( ZoomDeRegistro(aLista[oLista:nAt,30]) )
   @ C(210),C(074) Button "Importa Arqs"  Size C(037),C(012) PIXEL OF oDlg ACTION( IMPLAYCOMIS() )
   @ C(210),C(113) Button "R - I"         Size C(018),C(012) PIXEL OF oDlg ACTION( ResumoImpo() )
   @ C(210),C(133) Button "R - B"         Size C(017),C(012) PIXEL OF oDlg ACTION( MostraBaixas() )
   @ C(210),C(152) Button "Alt.Dist."     Size C(037),C(012) PIXEL OF oDlg ACTION( AltCodDistri(aLista[oLista:nAt,01]) )
   @ C(210),C(191) Button "Ajusta Valor"  Size C(037),C(012) PIXEL OF oDlg ACTION( AjustaValor(aLista[oLista:nAt,01], aLista[oLista:nAt,06], aLista[oLista:nAt,07], aLista[oLista:nAt,08], aLista[oLista:nAt,09]) ) 
   @ C(210),C(230) Button "Vlr Adicional" Size C(037),C(012) PIXEL OF oDlg ACTION( PPAdicional() )
   @ C(210),C(269) Button "Gera PV"       Size C(037),C(012) PIXEL OF oDlg ACTION( GeraPVendaDist() )
   @ C(210),C(308) Button "Movtº"         Size C(037),C(012) PIXEL OF oDlg ACTION( ContaCorrenteFat(aLista[oLista:nAt,30]) )
   @ C(210),C(347) Button "Estatíscas"    Size C(037),C(012) PIXEL OF oDlg ACTION( VeEstatistica() )
   @ C(210),C(386) Button "Excel"         Size C(034),C(012) PIXEL OF oDlg ACTION( kkGeraPCSV() )
   @ C(210),C(425) Button "Layout Arq."   Size C(034),C(012) PIXEL OF oDlg ACTION( LayoutArq() )
   @ C(210),C(464) Button "Voltar"        Size C(035),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   //              01   02   03  04  05  06  07  08  09  10  11   12  13  14  15   16  17  18  19  20  21  22  23  24  25  26  27  28  29  30
   aAdd( aLista, { .F., "0", "", "", "", "", "", "", "", "", "0", "", "", "", "0", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })

   @ 083,005 LISTBOX oLista FIELDS HEADER "M"                           ,; // 01
                                          "LG"                          ,; // 02
                                          "NF Dist."                    ,; // 03                                          
                                          "PRC"                         ,; // 04
                                          "Dta Prev. Rec."              ,; // 05
                                          "Vlr Comissão"                ,; // 06
                                          "Vlr Faturado"                ,; // 07
                                          "Vlr A Faturar"               ,; // 08
                                          "Sld A Faturar"               ,; // 09
                                          "Valor PV."                   ,; // 10                                         
                                          "LG %"                        ,; // 11
                                          "% Comissão"                  ,; // 12
                                          "Dta Fat. P1"                 ,; // 13
                                          "Dta Cob.Com."                ,; // 14
                                          "TB"                          ,; // 15
                                          "Distrib."                    ,; // 16
                                          "Loja"                        ,; // 17
                                          "Descrição dos Distribuidores",; // 18
                                          "Nº PVenda"                   ,; // 19
                                          "Emissão"                     ,; // 20
                                          "Ped.Externo"                 ,; // 21
                                          "Dta Fech."                   ,; // 22
                                          "Nº NFiscal"                  ,; // 23
                                          "Série"                       ,; // 24
                                          "Cliente"                     ,; // 25
                                          "Loja"                        ,; // 26
                                          "Descrição dos Clientes"      ,; // 27
                                          "Emp.Ori"                     ,; // 28
                                          "Fil.Ori"                     ,; // 29
                                          "LCT"                          ; // 30                                          
                                          PIXEL SIZE 633,150 OF oDlg FONT oFont ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

   oLista:SetArray( aLista )

   oLista:bLine := {||{ Iif(aLista[oLista:nAt,01],oOk,oNo)          ,;
                         If(aLista[oLista:nAt,02] == "0", oBranco   ,;
                         If(aLista[oLista:nAt,02] == "2", oVerde    ,;
                         If(aLista[oLista:nAt,02] == "3", oCancel   ,;                         
                         If(aLista[oLista:nAt,02] == "1", oAmarelo  ,;                         
                         If(aLista[oLista:nAt,02] == "5", oAzul     ,;                         
                         If(aLista[oLista:nAt,02] == "6", oLaranja  ,;                         
                         If(aLista[oLista:nAt,02] == "7", oPreto    ,;                         
                         If(aLista[oLista:nAt,02] == "8", oVermelho ,;
                         If(aLista[oLista:nAt,02] == "9", oPink     ,;
                         If(aLista[oLista:nAt,02] == "4", oEncerra, "")))))))))),;
                            aLista[oLista:nAt,03]         ,;
                            aLista[oLista:nAt,04]         ,;
                            aLista[oLista:nAt,05]         ,;
                            aLista[oLista:nAt,06]         ,;
                            aLista[oLista:nAt,07]         ,;
                            aLista[oLista:nAt,08]         ,;
                            aLista[oLista:nAt,09]         ,;
                            aLista[oLista:nAt,10]         ,;
                         If(aLista[oLista:nAt,11] == "0", oBranco   ,;
                         If(aLista[oLista:nAt,11] == "2", oVerde    ,;
                         If(aLista[oLista:nAt,11] == "3", oCancel   ,;                         
                         If(aLista[oLista:nAt,11] == "1", oAmarelo  ,;                         
                         If(aLista[oLista:nAt,11] == "5", oAzul     ,;                         
                         If(aLista[oLista:nAt,11] == "6", oLaranja  ,;                         
                         If(aLista[oLista:nAt,11] == "7", oPreto    ,;                         
                         If(aLista[oLista:nAt,11] == "8", oVermelho ,;
                         If(aLista[oLista:nAt,11] == "9", oPink     ,;
                         If(aLista[oLista:nAt,11] == "4", oEncerra, "")))))))))),;
                            aLista[oLista:nAt,12]         ,;
                            aLista[oLista:nAt,13]         ,;
                            aLista[oLista:nAt,14]         ,;
                         If(aLista[oLista:nAt,15] == "0", oBranco   ,;
                         If(aLista[oLista:nAt,15] == "2", oVerde    ,;
                         If(aLista[oLista:nAt,15] == "3", oCancel   ,;                         
                         If(aLista[oLista:nAt,15] == "1", oAmarelo  ,;                         
                         If(aLista[oLista:nAt,15] == "5", oAzul     ,;                         
                         If(aLista[oLista:nAt,15] == "6", oLaranja  ,;                         
                         If(aLista[oLista:nAt,15] == "7", oPreto    ,;                         
                         If(aLista[oLista:nAt,15] == "8", oVermelho ,;
                         If(aLista[oLista:nAt,15] == "9", oPink     ,;
                         If(aLista[oLista:nAt,15] == "4", oEncerra, "")))))))))),;
                            aLista[oLista:nAt,16]         ,;
                            aLista[oLista:nAt,17]         ,;
                            aLista[oLista:nAt,18]         ,;
                            aLista[oLista:nAt,19]         ,;
                            aLista[oLista:nAt,20]         ,;
                            aLista[oLista:nAt,21]         ,;
                            aLista[oLista:nAt,22]         ,;
                            aLista[oLista:nAt,23]         ,;
                            aLista[oLista:nAt,24]         ,;
                            aLista[oLista:nAt,25]         ,;
                            aLista[oLista:nAt,26]         ,;
                            aLista[oLista:nAt,27]         ,;
                            aLista[oLista:nAt,28]         ,;
                            aLista[oLista:nAt,29]         ,;
                            aLista[oLista:nAt,30]         }}

   oLista:bLDblClick := {|| MarcaReg() }
   
   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ###################################################
// Função que marca/desmarca o registro selecionado ##
// ###################################################
Static Function MarcaReg()

   // ##############################
   // Referente a linha em branco ##
   // ##############################
   If Empty(Alltrim(aLista[oLista:nAt,03]))
      aLista[oLista:nAt,01] := .F.
      Return(.T.)
   Endif      

   // ##########################################
   // Se estiver encerrado (Verde), não marca ##
   // ##########################################
   If aLista[oLista:nAt,02] == "2"
      aLista[oLista:nAt,01] := .F.
      Return(.T.)
   Endif      

   If aLista[oLista:nAt,01] == .F.
      aLista[oLista:nAt,01] := .T.
      aLista[oLista:nAt,08] := aLista[oLista:nAt,09]
      aLista[oLista:nAt,09] := TRANSFORM(0, "@E 9999999.99")
   Else
      aLista[oLista:nAt,01] := .F.      
      aLista[oLista:nAt,08] := TRANSFORM(0, "@E 9999999.99")
      aLista[oLista:nAt,09] := TRANSFORM(VAL(StrTran(aLista[oLista:nAt,06], ",", ".")) - VAL(StrTran(aLista[oLista:nAt,07], ",", ".")) - VAL(StrTran(aLista[oLista:nAt,08], ",", ".")), "@E 9999999.99")
   Endif

   // #####################################################
   // Envia para a função que atualiza os totais da tela ##
   // #####################################################
   TotaisTela()

Return(.T.)      

// #############################################################
// Função que carrega as filiais conforme Empresa selecionada ##
// #############################################################
Static Function AlteraCombo

   aFilial := {}

   Do Case
      Case Substr(cComboBx1,01,02) == "01"
           aAdd( aFilial, "01 - PORTO ALEGRE" )
           aAdd( aFilial, "02 - CAXIAS DO SUL" )
           aAdd( aFilial, "03 - PELOTAS" )
           aAdd( aFilial, "04 - SUPRIMENTOS" )
           aAdd( aFilial, "05 - SÃO PAULO" )
           aAdd( aFilial, "06 - ESPIRITO SANTO" )                                                       

      Case Substr(cComboBx1,01,02) == "02"
           aAdd( aFilial, "01 - CURITIBA" )

      Case Substr(cComboBx1,01,02) == "03"
           aAdd( aFilial, "01 - PORTO ALEGRE" )

      Case Substr(cComboBx1,01,02) == "04"
           aAdd( aFilial, "01 - PELOTAS" )

   EndCase

   @ C(046),C(062) ComboBox cComboBx2 Items aFilial Size C(054),C(010) PIXEL OF oDlg

Return(.T.)

// #############################################
// Função que pesquisa o nome do distribuidor ##
// #############################################
Static Function CaptaDist()

   If Empty(Alltrim(cFornece)) 
      cFornece := Space(06)
      cLoja    := Space(03)
      cNomeFor := Space(60)
      oGet3:Refresh()
      oGet4:Refresh()
      oGet5:Refresh()      
      Return(.T.)
   Endif
   
   If Empty(Alltrim(cLoja)) 
      cFornece := Space(06)
      cLoja    := Space(03)
      cNomeFor := Space(60)
      oGet3:Refresh()
      oGet4:Refresh()
      oGet5:Refresh()      
      Return(.T.)
   Endif

   cNomeFor := POSICIONE("SA2",1,XFILIAL("SA2") + cFornece + cLoja, "A2_NOME")

   If Empty(Alltrim(cNomeFor)) 
      MsgAlert("Distribuidor informado não localizado.")
      cFornece := Space(06)
      cLoja    := Space(03)
      cNomeFor := Space(60)
      oGet3:Refresh()
      oGet4:Refresh()
      oGet5:Refresh()      
      Return(.T.)
   Endif

Return(.T.)

// ######################################################################
// Função que realiza a pesquisa dos pedido externos a serem faturados ##
// ######################################################################
Static Function PsqExterno()

   MsgRun("Aguarde! Pesquisando Pedidos Externos ...", "Faturamento de Comissões",{|| xPsqExterno() })
   
Return(.T.)

// ######################################################################
// Função que realiza a pesquisa dos pedido externos a serem faturados ##
// ######################################################################
Static Function xPsqExterno()

   Local cSql        := ""
   Local nLancamento := 0

   If cInicial == Ctod("  /  /    ")
      MsgAlert("Data inicla de emissão de pedidos não informado.")
      Return(.T.)
   Endif
      
   If cFinal == Ctod("  /  /    ")
      MsgAlert("Data final de emissão de pedidos não informado.")
      Return(.T.)
   Endif

   If lDataEmissao == .T. .And. lDataVencime == .T.
      MsgAlert("Atenção! Somente permitido informar um tipo de data a ser pesquisada (Emissão ou Vencimento). Verifique!")
      Return(.T.)
   Endif
   
   If lDataEmissao == .F. .And. lDataVencime == .F.
      MsgAlert("Tipo de pesquisa de data não selecionado. Verifiqeu!")
      Return(.T.)
   Endif

   aLista := {}

   If Select("T_CONSULTA") > 0
   	  T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := "" 
   cSql := "SELECT SC5.C5_FILIAL ," + CHR(13)
   cSql += "       SC5.C5_NUM    ," + CHR(13)
   cSql	+= "       SC5.C5_EMISSAO," + CHR(13)
   cSql += "	   SC5.C5_CONDPAG," + CHR(13)
   cSql += "      (SELECT E4_COND FROM SE4010 WHERE E4_CODIGO = SC5.C5_CONDPAG AND D_E_L_E_T_ = '') AS CONDICAO," + CHR(13)
   cSql	+= "       SC5.C5_CLIENTE," + CHR(13)
   cSql	+= "       SC5.C5_LOJACLI," + CHR(13)
   cSql	+= "       SA1.A1_NOME   ," + CHR(13)
   cSql	+= "       SC5.C5_NOTA   ," + CHR(13)
   cSql	+= "       SC5.C5_SERIE  ," + CHR(13)
   cSql	+= "       SC5.C5_FORNEXT," + CHR(13)
   cSql	+= "       SC5.C5_LOJAEXT," + CHR(13)
   cSql	+= "       SA2.A2_NOME   ," + CHR(13)
   cSql	+= "       SC5.C5_NFDISTR," + CHR(13)
   cSql	+= "       SC5.C5_PVEXTER," + CHR(13)
   cSql	+= "       SC5.C5_DFEC   ," + CHR(13)
   cSql += "      (SELECT TOP(1) C6_DATFAT FROM SC6010 WHERE C6_FILIAL = SC5.C5_FILIAL AND C6_NUM = SC5.C5_NUM AND C6_NOTA <> '' AND D_E_L_E_T_ = '') AS DATAFAT, " + CHR(13)
   cSql += "      (SELECT SUM(C6_VALOR)    FROM SC6010 WHERE C6_FILIAL = SC5.C5_FILIAL AND C6_NUM = SC5.C5_NUM AND D_E_L_E_T_ = '') AS TOTAL_PV      ," + CHR(13)
   cSql += "      (SELECT SUM(C6_COMIAUT ) FROM SC6010 WHERE C6_FILIAL = SC5.C5_FILIAL AND C6_NUM = SC5.C5_NUM AND D_E_L_E_T_ = '') AS TOTAL_COMISSAO " + CHR(13)

   Do Case
      Case Substr(cComboBx1,01,02) == "01"
           cSql += "  FROM SC5010 SC5," + CHR(13)
      Case Substr(cComboBx1,01,02) == "02"
           cSql += "  FROM SC5020 SC5," + CHR(13)
      Case Substr(cComboBx1,01,02) == "03"
           cSql += "  FROM SC5030 SC5," + CHR(13)
      Case Substr(cComboBx1,01,02) == "04"
           cSql += "  FROM SC5040 SC5," + CHR(13)
   EndCase

   cSql += "       " + RetSqlName("SA1") + " SA1, " + CHR(13)
   cSql += "  	   " + RetSqlName("SA2") + " SA2  " + CHR(13)
   cSql += " WHERE SC5.C5_FILIAL  = '" + Substr(cComboBx2,01,02) + "'" + CHR(13)
   cSql += "   AND SC5.C5_EXTERNO = '1'" + CHR(13)
   cSql += "   AND SC5.D_E_L_E_T_ = '' " + CHR(13)
   cSql += "   AND SA1.A1_COD     = SC5.C5_CLIENTE" + CHR(13)
   cSql += "   AND SA1.A1_LOJA    = SC5.C5_LOJACLI" + CHR(13)
   cSql += "   AND SA1.D_E_L_E_T_ = ''            " + CHR(13)
   cSql += "   AND SA2.A2_COD     = SC5.C5_FORNEXT" + CHR(13)
   cSql += "   AND SA2.A2_LOJA    = SC5.C5_LOJAEXT" + CHR(13)
   cSql += "   AND SA2.D_E_L_E_T_ = ''            " + CHR(13)
   cSql += "   AND SC5.C5_NOTA <> ''"

   If Substr(cComboBx4,01,01) == "1"
   Else
      cInicial := Date() - 365
      cFinal   := Date() + 365
   Endif   

   cSql += "   AND (SELECT TOP(1) C6_DATFAT FROM SC6010 WHERE C6_FILIAL = SC5.C5_FILIAL AND C6_NUM = SC5.C5_NUM AND C6_NOTA <> '' AND D_E_L_E_T_ = '') >= CONVERT(DATETIME,'" + Dtoc(cInicial) + "', 103)" + CHR(13)
   cSql += "   AND (SELECT TOP(1) C6_DATFAT FROM SC6010 WHERE C6_FILIAL = SC5.C5_FILIAL AND C6_NUM = SC5.C5_NUM AND C6_NOTA <> '' AND D_E_L_E_T_ = '') <= CONVERT(DATETIME,'" + Dtoc(cFinal)   + "', 103)" + CHR(13)

   If lNinformado == .F.
      If Empty(Alltrim(cFornece))
      Else
         cSql += " AND SC5.C5_FORNEXT = '" + Alltrim(cFornece) + "'" + CHR(13)
         cSql += " AND SC5.C5_LOJAEXT = '" + Alltrim(cLoja)    + "'" + CHR(13)
      Endif
   Else
      cSql += " AND SC5.C5_FORNEXT = ''" + CHR(13)
      cSql += " AND SC5.C5_LOJAEXT = ''" + CHR(13)
   Endif   

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )

   nLancamento := 0
   
   WHILE !T_CONSULTA->( EOF() )

      Do Case
         Case Substr(cComboBx1,01,02) == "01"
              kEmpresa := "01 - AUTOMATECH - POA"
              Do Case
                 Case Substr(cComboBx2,01,02) == "01"
                      kFilial := "01 - PORTO ALEGRE" 
                 Case Substr(cComboBx2,01,02) == "02"
                      kFilial := "02 - CAXIAS DO SUL" 
                 Case Substr(cComboBx2,01,02) == "03"
                      kFilial := "03 - PELOTAS" 
                 Case Substr(cComboBx2,01,02) == "04"
                      kFilial := "04 - SUPRIMENTOS" 
                 Case Substr(cComboBx2,01,02) == "05"
                      kFilial := "05 - SÃO PAULO" 
                 Case Substr(cComboBx2,01,02) == "06"
                      kFilial := "06 - ESPIRITO SANTO" 
              EndCase        
         Case Substr(cComboBx1,01,02) == "02"
              kEmpresa := "02 - TI AUTOMAÇÃO"
              kFilial  := "01 - CURITIBA" 
         Case Substr(cComboBx1,01,02) == "03"
              kEmpresa := "03 - ATECH - POA"
              kFilial  := "01 - PORTO ALEGRE" 
         Case Substr(cComboBx1,01,02) == "04"
              kEmpresa := "04 - ATECHPEL"
              kFilial  := "01 - PELOTAS" 
      EndCase

      // #########################################################################
      // Divide em parcelas conforme a condição de pagamento do pedido de venda ##
      // #########################################################################
      kCondicao    := T_CONSULTA->CONDICAO + ","
      kNrParcelas  := U_P_OCCURS(kCondicao, ",", 1)
      kVlrParcela  := Round((T_CONSULTA->TOTAL_COMISSAO / kNrParcelas),2)
      kDiferenca   := 0

      If (kVlrParcelas * kNrParcelas) <> T_CONSULTA->TOTAL_COMISSAO

         If (kVlrParcelas * kNrParcelas) > T_CONSULTA->TOTAL_COMISSAO      
            kDiferenca := (kVlrParcelas * kNrParcelas) - T_CONSULTA->TOTAL_COMISSAO      
            kSinal     := "-"
         Else
            kDiferenca := T_CONSULTA->TOTAL_COMISSAO - (kVlrParcelas * kNrParcelas)
            kSinal     := "+"
         Endif   
      Endif   
      
      // ###################################
      // Trata o valor do Pedido de Venda ##
      // ###################################
      kValorPedido := Round((T_CONSULTA->TOTAL_PV / kNrParcelas),2)
      kDifePedido  := 0

      If (kValorPedido * kNrParcelas) <> T_CONSULTA->TOTAL_PV

         If (kValorPedido * kNrParcelas) > T_CONSULTA->TOTAL_PV
            kDifePedido := (kValorPedido * kNrParcelas) - T_CONSULTA->TOTAL_PV
            kSinalPV    := "-"
         Else
            kDifePedido := T_CONSULTA->TOTAL_PV - (kValorPedido * kNrParcelas)
            kSinalPV    := "+"
         Endif   
      Endif   

      TT_Comissao := 0
      TT_Faturado := 0
      TT_Afaturar := 0
      TT_Saldo    := 0
      TT_Pedido   := 0

      For nContar = 1 to U_P_OCCURS(kCondicao, ",", 1)

          nLancamento := nLancamento + 1
                
          If nContar == 1

             If kDiferenca <> 0
                If kSinal == "-"
                   kVlrParcela := kVlrParcela - kDiferenca
                Else
                   kVlrParcela := kVlrParcela + kDiferenca
                Endif
             Endif

             If kDifePedido <> 0
                If kSinalPV == "-"
                   kValorPedido := kValorPedido - kDifePedido
                Else
                   kValorPedido := kValorPedido + kDifePedido
                Endif
             Endif

          Endif            

          // ##################################################
          // Pesquisa o valor já faturado para o pedido lido ##
          // ##################################################
          If Select("T_JAFATURADO") > 0
   	         T_JAFATURADO->( dbCloseArea() )
          EndIf

          cSql := ""                                                      
	      cSql := "SELECT SUM(ZPH_VALO) AS FATURADO"
	      cSql += "  FROM " + RetSqlName("ZPH")
          cSql += " WHERE ZPH_FILIAL = '" + Substr(kFilial ,01,02)       + "'"
          cSql += "   AND ZPH_EMPO   = '" + Substr(kEmpresa,01,02)       + "'"
          cSql += "   AND ZPH_PEDO   = '" + Alltrim(T_CONSULTA->C5_NUM)  + "'"
          cSql += "   AND ZPH_PARO   = '" + Alltrim(Strzero(nContar,02)) + "'"
		  cSql += "   AND ZPH_DELE   = ''"

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JAFATURADO", .T., .T. )

          kJaFaturado := 0
          kJaFaturado := IIF(T_JAFATURADO->( EOF() ), 0, T_JAFATURADO->FATURADO) 

          // ####################################################
          // Filtra pelo tipo de status indicado para pesquisa ##
          // ####################################################
          
          If Substr(cComboBx3,01,01) == "0"
          Else
          
             Do Case 

                // ############
                // A Faturar ##
                // ############
                Case Substr(cComboBx3,01,01) == "1"
                     If kVlrParcela == kJaFaturado
                        T_CONSULTA->( DbSkip() )
                        Loop
                     Endif
                  
                     If (kVlrParcela - kJaFaturado) < 0
                        T_CONSULTA->( DbSkip() )
                        Loop
                     Endif

                // ################
                // Faturar Total ##
                // ################
                Case Substr(cComboBx3,01,01) == "2"

                     If (kVlrParcela - kJaFaturado) <> 0
                        T_CONSULTA->( DbSkip() )
                        Loop                         
                     Endif
                
                // ##################
                // Faturar Parcial ##
                // ##################
                Case Substr(cComboBx3,01,01) == "3"
                     If (kVlrParcela - kJaFaturado) == 0
                        T_CONSULTA->( DbSkip() )
                        Loop
                     Endif

                     If (kVlrParcela - kJaFaturado) == kVlrParcela
                        T_CONSULTA->( DbSkip() )
                        Loop
                     Endif

             EndCase
                   
          Endif                
                
          kDtaFecha   := Substr(T_CONSULTA->C5_DFEC   ,07,02) + "/" + Substr(T_CONSULTA->C5_DFEC   ,05,02) + "/" + Substr(T_CONSULTA->C5_DFEC   ,01,04)
          kDEmissao   := Substr(T_CONSULTA->C5_EMISSAO,07,02) + "/" + Substr(T_CONSULTA->C5_EMISSAO,05,02) + "/" + Substr(T_CONSULTA->C5_EMISSAO,01,04)
          kNFDistri   := IIF(Empty(Alltrim(T_CONSULTA->C5_NFDISTR)), "", Alltrim(T_CONSULTA->C5_NFDISTR))
          dVencimento := Ctod(kDtaFecha) + INT(VAL(U_P_CORTA(kCondicao, ",", nContar)))

	      If Substr(cComboBx4,01,01) == "2"
             If dVencimento >= cInicial .And. dVencimento <= cFinal
             Else
                Loop
             Endif
          Endif

          // #########################
          // Carrega o Array aLista ##
          // #########################
          aAdd( aLista, { .F.                                                     ,; // 01
                          "8"                                                     ,; // 02
                          kNFDistri                                               ,; // 03
                          Strzero(nContar,02)                                     ,; // 04
                          dVencimento                                             ,; // 05
	                      TRANSFORM(kVlrParcela                , "@E 9999999.99") ,; // 06
                          TRANSFORM(kJaFaturado                , "@E 9999999.99") ,; // 07
                          TRANSFORM(0                          , "@E 9999999.99") ,; // 08
                          TRANSFORM((kVlrParcela - kJaFaturado), "@E 9999999.99") ,; // 09
                          TRANSFORM(kValorPedido               , "@E 9999999.99") ,; // 10
                          ""                                                      ,; // 11
                          TRANSFORM(0.00                       , "@E 9999999.99") ,; // 12
                          kDtaFecha                                               ,; // 13
                          "  /  /    "                                            ,; // 14
                          ""                                                      ,; // 15
                          T_CONSULTA->C5_FORNEXT                                  ,; // 16
                          T_CONSULTA->C5_LOJAEXT                                  ,; // 17
                          T_CONSULTA->A2_NOME                                     ,; // 18
                          T_CONSULTA->C5_NUM                                      ,; // 19
                          kDEmissao                                               ,; // 20        
                          T_CONSULTA->C5_PVEXTER                                  ,; // 21
                          kDtaFecha                                               ,; // 22
                          T_CONSULTA->C5_NOTA                                     ,; // 23
                          T_CONSULTA->C5_SERIE                                    ,; // 24
                          T_CONSULTA->C5_CLIENTE                                  ,; // 25
                          T_CONSULTA->C5_LOJACLI                                  ,; // 26
                          T_CONSULTA->A1_NOME                                     ,; // 27
                          kEmpresa                                                ,; // 28
                          kFilial                                                 ,; // 29
                          Strzero(nLancamento,5)                                  }) // 30
          
          TT_Comissao := TT_Comissao + kVlrParcela
          TT_Faturado := TT_Faturado + kJaFaturado
          TT_Afaturar := TT_Afatura  + 0
          TT_Saldo    := TT_Saldo    + (kVlrParcela - kJaFaturado)
          TT_Pedido   := TT_Pedido   + kValorPedido
          
      Next nContar

      // ##########################
      // Abre linha Totalizadora ##
      // ##########################
      aAdd( aLista, { .F.                                    ,; // 01   
                      ""                                     ,; // 02
                      ""                                     ,; // 03
                      ""                                     ,; // 04
                      "TOTAL PV"                             ,; // 05
                      TRANSFORM(TT_Comissao, "@E 9999999.99"),; // 06
                      TRANSFORM(TT_Faturado, "@E 9999999.99"),; // 07
                      TRANSFORM(TT_Afaturar, "@E 9999999.99"),; // 08
                      TRANSFORM(TT_Saldo   , "@E 9999999.99"),; // 09
                      TRANSFORM(TT_Pedido  , "@E 9999999.99"),; // 10
                      ""                                     ,; // 11
                      ""                                     ,; // 12
                      ""                                     ,; // 13
                      ""                                     ,; // 14
                      ""                                     ,; // 15
                      ""                                     ,; // 16
                      ""                                     ,; // 17
                      ""                                     ,; // 18
                      ""                                     ,; // 19
                      ""                                     ,; // 20
                      ""                                     ,; // 21
                      ""                                     ,; // 22
                      ""                                     ,; // 23
                      ""                                     ,; // 24
                      ""                                     ,; // 25
                      ""                                     ,; // 26
                      ""                                     ,; // 27
                      ""                                     ,; // 28
                      ""                                     ,; // 29
                      ""                                     }) // 30

      // ###########################
      // Abre uma linha em branco ##
      // ###########################
      //              01   02   03  04  05  06  07  08  09  10  11   12  13  14  15   16  17  18  19  20  21  22  23  24  25  26  27  28  29  30
      aAdd( aLista, { .F., "" , "", "", "", "", "", "", "", "", "" , "", "", "", "" , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })

      T_CONSULTA->( DbSkip() )
      
   ENDDO   

   If Len(aLista) == 0
      //              01   02   03  04  05  06  07  08  09  10  11   12  13  14  15   16  17  18  19  20  21  22  23  24  25  26  27  28  29  30
      aAdd( aLista, { .F., "" , "", "", "", "", "", "", "", "", "" , "", "", "", "" , "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
   Else
   
      // ###########################
      // Acerta a legenda do grid ##
      // ###########################
      For nContar = 1 to Len(aLista)
          If Empty(Alltrim(aLista[nContar,03]))
          Else
             Do Case
                Case VAL(aLista[nContar,09]) == 0
                     aLista[nContar,02] := "2"
                Case VAL(aLista[nContar,09]) == VAL(aLista[nContar,06])
                     aLista[nContar,02] := "8"
                Case VAL(aLista[nContar,09]) <> VAL(aLista[nContar,06])
                     aLista[nContar,02] := "6"
             EndCase
          Endif
      Next nContar    

      // ############################# 
      // Carrega o array aAdicional ##
      // #############################
      For nContar = 1 to Len(aLista)
      
          lJaTem := .F.

          If Empty(Alltrim(aLista[nContar,03]))
             Loop
          Endif
          
          For nProcura = 1 to Len(aAdicional)
              
              If aAdicional[nProcura,01] == aLista[nContar,16] .And. aAdicional[nProcura,02] == aLista[nContar,17]
                 lJaTem := .T.
                 Exit
              Endif
              
          Next nProcura
          
          If lJaTem == .F.
             aAdd( aAdicional, { aLista[nContar,16],; // Distribuidor -> 16
                                 aLista[nContar,17],; // Loja         -> 17
                                 aLista[nContar,18],; // Nome         -> 18
                                 0                 ,;
                                 ""                })
          Endif
          
      Next nContar                                     

   Endif
      
   // #############################################
   // Limpa legendas e valores da linha do Total ##
   // #############################################
   For nContar = 1 to Len(aLista)
       If Alltrim(aLista[nContar,05]) == "TOTAL PV"
          aLista[nContar,11] := ""
          aLista[nContar,12] := ""
       Endif
   Next nContar       

   oLista:SetArray( aLista )

   oLista:bLine := {||{ Iif(aLista[oLista:nAt,01],oOk,oNo)          ,;
                         If(aLista[oLista:nAt,02] == "0", oBranco   ,;
                         If(aLista[oLista:nAt,02] == "2", oVerde    ,;
                         If(aLista[oLista:nAt,02] == "3", oCancel   ,;                         
                         If(aLista[oLista:nAt,02] == "1", oAmarelo  ,;                         
                         If(aLista[oLista:nAt,02] == "5", oAzul     ,;                         
                         If(aLista[oLista:nAt,02] == "6", oLaranja  ,;                         
                         If(aLista[oLista:nAt,02] == "7", oPreto    ,;                         
                         If(aLista[oLista:nAt,02] == "8", oVermelho ,;
                         If(aLista[oLista:nAt,02] == "9", oPink     ,;
                         If(aLista[oLista:nAt,02] == "4", oEncerra, "")))))))))),;
                            aLista[oLista:nAt,03]         ,;
                            aLista[oLista:nAt,04]         ,;
                            aLista[oLista:nAt,05]         ,;
                            aLista[oLista:nAt,06]         ,;
                            aLista[oLista:nAt,07]         ,;
                            aLista[oLista:nAt,08]         ,;
                            aLista[oLista:nAt,09]         ,;
                            aLista[oLista:nAt,10]         ,;
                         If(aLista[oLista:nAt,11] == "0", oBranco   ,;
                         If(aLista[oLista:nAt,11] == "2", oVerde    ,;
                         If(aLista[oLista:nAt,11] == "3", oCancel   ,;                         
                         If(aLista[oLista:nAt,11] == "1", oAmarelo  ,;                         
                         If(aLista[oLista:nAt,11] == "5", oAzul     ,;                         
                         If(aLista[oLista:nAt,11] == "6", oLaranja  ,;                         
                         If(aLista[oLista:nAt,11] == "7", oPreto    ,;                         
                         If(aLista[oLista:nAt,11] == "8", oVermelho ,;
                         If(aLista[oLista:nAt,11] == "9", oPink     ,;
                         If(aLista[oLista:nAt,11] == "4", oEncerra, "")))))))))),;
                            aLista[oLista:nAt,12]         ,;
                            aLista[oLista:nAt,13]         ,;
                            aLista[oLista:nAt,14]         ,;
                         If(aLista[oLista:nAt,15] == "0", oBranco   ,;
                         If(aLista[oLista:nAt,15] == "2", oVerde    ,;
                         If(aLista[oLista:nAt,15] == "3", oCancel   ,;                         
                         If(aLista[oLista:nAt,15] == "1", oAmarelo  ,;                         
                         If(aLista[oLista:nAt,15] == "5", oAzul     ,;                         
                         If(aLista[oLista:nAt,15] == "6", oLaranja  ,;                         
                         If(aLista[oLista:nAt,15] == "7", oPreto    ,;                         
                         If(aLista[oLista:nAt,15] == "8", oVermelho ,;
                         If(aLista[oLista:nAt,15] == "9", oPink     ,;
                         If(aLista[oLista:nAt,15] == "4", oEncerra, "")))))))))),;
                            aLista[oLista:nAt,16]         ,;
                            aLista[oLista:nAt,17]         ,;
                            aLista[oLista:nAt,18]         ,;
                            aLista[oLista:nAt,19]         ,;
                            aLista[oLista:nAt,20]         ,;
                            aLista[oLista:nAt,21]         ,;
                            aLista[oLista:nAt,22]         ,;
                            aLista[oLista:nAt,23]         ,;
                            aLista[oLista:nAt,24]         ,;
                            aLista[oLista:nAt,25]         ,;
                            aLista[oLista:nAt,26]         ,;
                            aLista[oLista:nAt,27]         ,;
                            aLista[oLista:nAt,28]         ,;
                            aLista[oLista:nAt,29]         ,;
                            aLista[oLista:nAt,30]         }}

   // #############################################################
   // Envia para a função que realiza atualiza os totais da tela ##
   // #############################################################
   TotaisTela()

Return(.T.)   

// ###########################################
// Função que marca e desmarca os registros ##
// ###########################################
Static Function MrcDmrcReg(kTipo)

   Local nContar := 0
   
   For nContar = 1 to Len(aLista)

       Do Case 
          Case aLista[nContar,02] == "0"    
               aLista[nContar,01] := .F.
          Case aLista[nContar,02] == "2"    
               aLista[nContar,01] := .F.
          Otherwise
               aLista[nContar,01] := IIF(kTipo == 1, .T., .F.)
       EndCase 

       If aLista[nContar,02] <> "0"
          If aLista[nContar,01] == .T.
             aLista[nContar,08] := aLista[nContar,09]
             aLista[nContar,09] := TRANSFORM(0, "@E 9999999.99")
          Else
             aLista[nContar,08] := TRANSFORM(0, "@E 9999999.99")
             aLista[nContar,09] := TRANSFORM(VAL(StrTran(aLista[nContar,06], ",", ".")) - VAL(StrTran(aLista[nContar,07], ",", ".")) - VAL(StrTran(aLista[nContar,08], ",", ".")), "@E 9999999.99")
          Endif
       Endif   

   Next nContar

   // #####################################################
   // Envia para a função que atualiza os totais da tela ##
   // #####################################################
   TotaisTela()
   
Return(.T.)       
   
// ###########################################
// Função que ajusta o valor a ser faturado ##
// ###########################################
Static Function AjustaValor(kMarcado, kComissao, kFaturado, kAfaturar, KSaldo)

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local cMemo3	 := ""
   Local cMemo4	 := ""

   Local oMemo1
   Local oMemo2
   Local oMemo3
   Local oMemo4

   Private cComissao := VAL(StrTran(kComissao, ",", "."))
   Private cFaturado := VAL(StrTran(kFaturado, ",", "."))
   Private cAFaturar := VAL(StrTran(kAfaturar, ",", "."))
   Private cSaldo    := VAL(StrTran(kSaldo   , ",", "."))
   Private lFatTotal := .F.
   Private lFatParci := .F.
   Private lFatUltim := .F.
   Private lUltimo   := .F.
   Private oCheckBox1
   Private oCheckBox2
   Private oCheckBox3
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private oDlgAJT

   If kMarcado == .F.
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Ajuste não permitido." + chr(13) + chr(10) + "Registro não está marcado para utilização.")
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgAJT TITLE "Ajuste Valor a Faturar" FROM C(178),C(181) TO C(496),C(416) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(111),C(026) PIXEL NOBORDER OF oDlgAJT

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(111),C(001) PIXEL OF oDlgAJT
   @ C(103),C(048) GET oMemo2 Var cMemo2 MEMO Size C(001),C(028) PIXEL OF oDlgAJT
   @ C(136),C(002) GET oMemo3 Var cMemo3 MEMO Size C(111),C(001) PIXEL OF oDlgAJT
   @ C(096),C(002) GET oMemo4 Var cMemo4 MEMO Size C(111),C(001) PIXEL OF oDlgAJT
   
   @ C(043),C(005) Say "Total Comissão"   Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgAJT
   @ C(056),C(005) Say "Já Faturado"      Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlgAJT
   @ C(069),C(005) Say "A Faturar"        Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlgAJT
   @ C(082),C(005) Say "Saldo"            Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlgAJT
   @ C(114),C(005) Say "Tipo Faturamento" Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlgAJT
   
   @ C(042),C(052) MsGet    oGet1      Var cComissao                              Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgAJT When lChumba
   @ C(055),C(052) MsGet    oGet2      Var cFaturado                              Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgAJT When lChumba
   @ C(068),C(052) MsGet    oGet3      Var cAFaturar                              Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgAJT VALID( CalculaSld() )
   @ C(081),C(052) MsGet    oGet4      Var cSaldo                                 Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgAJT When lChumba
   @ C(102),C(052) CheckBox oCheckBox1 Var lFatTotal Prompt "Faturamento Total"   Size C(058),C(008)                                         PIXEL OF oDlgAJT When lChumba
   @ C(113),C(052) CheckBox oCheckBox2 Var lFatParci Prompt "Faturamento Parcial" Size C(059),C(008)                                         PIXEL OF oDlgAJT When lChumba
   @ C(123),C(052) CheckBox oCheckBox3 Var lFatUltim Prompt "Último Faturamento"  Size C(057),C(008)                                         PIXEL OF oDlgAJT When lUltimo

   @ C(143),C(019) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgAJT ACTION( VoltaCom() )
   @ C(143),C(057) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgAJT ACTION( oDlgAJT:End() )

   ACTIVATE MSDIALOG oDlgAJT CENTERED 

Return(.T.)

// #########################################
// Função que calcula o saldo do registro ##
// #########################################
Static Function CalculaSld()

   cSaldo := cComissao - cFaturado - cAfaturar
   oGet4:Refresh()
   
   lFatTotal := .F.
   lFatParci := .F.
   lFatUltim := .F.
   lUltimo   := .F.

   If cAfaturar >= cComissao
      lFatTotal := .T.
      lFatParci := .F.
      lFatUltim := .T.
      lUltimo   := .F.
   Else
      lFatTotal := .F.
      lFatParci := .T.
      lFatUltim := .F.
      lUltimo   := .T.
   Endif

Return(.T.)

// ##################################################
// Função que retorna o valor da comissão A Faturar##
// ##################################################
Static Function VoltaCom()

   aLista[oLista:nAt,23] := TRANSFORM(cAfaturar, "@E 9999999.99")
   aLista[oLista:nAt,24] := TRANSFORM(VAL(StrTran(aLista[oLista:nAt,21], ",", ".")) - VAL(StrTran(aLista[oLista:nAt,22], ",", ".")) - VAL(StrTran(aLista[oLista:nAt,23], ",", ".")), "@E 9999999.99")

   oDlgAJT:End()

   oLista:SetArray( aLista )


   oLista:bLine := {||{ Iif(aLista[oLista:nAt,01],oOk,oNo)          ,;
                         If(aLista[oLista:nAt,02] == "0", oBranco   ,;
                         If(aLista[oLista:nAt,02] == "2", oVerde    ,;
                         If(aLista[oLista:nAt,02] == "3", oCancel   ,;                         
                         If(aLista[oLista:nAt,02] == "1", oAmarelo  ,;                         
                         If(aLista[oLista:nAt,02] == "5", oAzul     ,;                         
                         If(aLista[oLista:nAt,02] == "6", oLaranja  ,;                         
                         If(aLista[oLista:nAt,02] == "7", oPreto    ,;                         
                         If(aLista[oLista:nAt,02] == "8", oVermelho ,;
                         If(aLista[oLista:nAt,02] == "9", oPink     ,;
                         If(aLista[oLista:nAt,02] == "4", oEncerra, "")))))))))),;
                            aLista[oLista:nAt,03]         ,;
                            aLista[oLista:nAt,04]         ,;
                            aLista[oLista:nAt,05]         ,;
                            aLista[oLista:nAt,06]         ,;
                            aLista[oLista:nAt,07]         ,;
                            aLista[oLista:nAt,08]         ,;
                            aLista[oLista:nAt,09]         ,;
                            aLista[oLista:nAt,10]         ,;
                         If(aLista[oLista:nAt,11] == "0", oBranco   ,;
                         If(aLista[oLista:nAt,11] == "2", oVerde    ,;
                         If(aLista[oLista:nAt,11] == "3", oCancel   ,;                         
                         If(aLista[oLista:nAt,11] == "1", oAmarelo  ,;                         
                         If(aLista[oLista:nAt,11] == "5", oAzul     ,;                         
                         If(aLista[oLista:nAt,11] == "6", oLaranja  ,;                         
                         If(aLista[oLista:nAt,11] == "7", oPreto    ,;                         
                         If(aLista[oLista:nAt,11] == "8", oVermelho ,;
                         If(aLista[oLista:nAt,11] == "9", oPink     ,;
                         If(aLista[oLista:nAt,11] == "4", oEncerra, "")))))))))),;
                            aLista[oLista:nAt,12]         ,;
                            aLista[oLista:nAt,13]         ,;
                            aLista[oLista:nAt,14]         ,;
                         If(aLista[oLista:nAt,15] == "0", oBranco   ,;
                         If(aLista[oLista:nAt,15] == "2", oVerde    ,;
                         If(aLista[oLista:nAt,15] == "3", oCancel   ,;                         
                         If(aLista[oLista:nAt,15] == "1", oAmarelo  ,;                         
                         If(aLista[oLista:nAt,15] == "5", oAzul     ,;                         
                         If(aLista[oLista:nAt,15] == "6", oLaranja  ,;                         
                         If(aLista[oLista:nAt,15] == "7", oPreto    ,;                         
                         If(aLista[oLista:nAt,15] == "8", oVermelho ,;
                         If(aLista[oLista:nAt,15] == "9", oPink     ,;
                         If(aLista[oLista:nAt,15] == "4", oEncerra, "")))))))))),;
                            aLista[oLista:nAt,16]         ,;
                            aLista[oLista:nAt,17]         ,;
                            aLista[oLista:nAt,18]         ,;
                            aLista[oLista:nAt,19]         ,;
                            aLista[oLista:nAt,20]         ,;
                            aLista[oLista:nAt,21]         ,;
                            aLista[oLista:nAt,22]         ,;
                            aLista[oLista:nAt,23]         ,;
                            aLista[oLista:nAt,24]         ,;
                            aLista[oLista:nAt,25]         ,;
                            aLista[oLista:nAt,26]         ,;
                            aLista[oLista:nAt,27]         ,;
                            aLista[oLista:nAt,28]         ,;
                            aLista[oLista:nAt,29]         ,;
                            aLista[oLista:nAt,30]         }}

Return(.T.)

// ######################################
// Função que gera os pedidos de venda ##
// ######################################
Static Function GeraPVendaDist()

   Local lChumba   := .F.
   Local lMarcado  := .F.
   Local lTemValor := .T.
   Local nContar   := 0

   Local cMemo1	  := ""
   Local cMemo3	  := ""

   Local oMemo1
   Local oMemo3
   
   Private aPedidos := {}

   Private kCodiDist  := Space(06)
   Private kLojaDist  := Space(03)
   Private kNomeDist  := Space(60)
   Private kValorFat  := 0
   Private kAdicional := 0
   Private kComTotal  := 0
   Private kCliente   := Space(06)
   Private kLojaCli   := Space(03)
   Private kNomeCli   := Space(60)
   Private kCondicao  := Space(03)
   Private kNomeCond  := Space(60)
   Private kTES       := Space(03)
   Private kNomeTES   := Space(60)
   Private kProduto   := Space(30)
   Private kNomePro   := Space(60)
   Private kVendedor  := Space(06)
   Private kNomeVend  := Space(60)
   Private kMensagem  := ""

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
   Private oGet10
   Private oGet11
   Private oGet12
   Private oGet13
   Private oGet14
   Private oGet15   
   Private oGet16   
   Private oGet17         

   Private oMemo4

   Private oDlgPV

   // #############################################################################
   // Verifica se houve pelo meno um registro marcado para herar pedido de venda ##
   // #############################################################################
   lMarcado := .F.
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          lMarcado := .T.
          Exit
       Endif
   Next nContar
   
   If lMarcado == .F.
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(10) + chr(13) + "Nenhum registro indicado para gerar Pedido de Venda. Verifique!")
      Return(.T.)
   Endif

   // ####################################################################
   // Verifica se os registros marcados possuem valor a serem faturados ##
   // ####################################################################
   lTemValor := .T.

   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          If VAL(StrTran(aLista[nContar,08], ",", ".")) == 0
             lTemValor := .F.
             Exit
          Endif
       Endif   
   Next nContar
   
   If lTemValor == .F.
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Existe(m) Registro(s) com valor = a 0 a ser faturado. Verifique!")
      Return(.T.)
   Endif              

   // #################################################################################
   // Carrega array com o código dos Distribuidores a serem gerados pedidos de venda ##
   // #################################################################################
   For nContar = 1 to Len(aLista)

       If aLista[nContar,01] == .T.

          lTemRegistro := .F.
          
          For nJaTem = 1 to Len(aPedidos)
              If aPedidos[nJaTem,01] == aLista[nContar,16] .And. aPedidos[nJaTem,02] == aLista[nContar,17]
                 lTemRegistro := .T.
                 Exit
              Endif
          Next nJaTem
          
          If lTemRegistro == .F.
             aAdd( aPedidos, { aLista[nContar,16], aLista[nContar,17] })
          Endif
          
       Endif
       
   Next nContar
              
   // ###########################
   // Gera os pedidos de venda ##
   // ###########################
   For nPedidos = 1 to Len(aPedidos)
   
       // #################################
       // Pesquisa dados do Distribuidor ##
       // #################################
       kCodiDist := aPedidos[nPedidos,01]
       kLojaDist := aPedidos[nPedidos,02]
       kNomeDist := POSICIONE("SA2",1,XFILIAL("SA2") + kCodiDist + kLojaDist, "A2_NOME")
       kCNPJ     := POSICIONE("SA2",1,XFILIAL("SA2") + kCodiDist + kLojaDist, "A2_CGC" )

       // ############################
       // Pesquisa dados do Cliente ##
       // ############################
       kCliente  := POSICIONE("SA1",3,XFILIAL("SA1") + kCNPJ, "A1_COD")
       kLojaCli  := POSICIONE("SA1",3,XFILIAL("SA1") + kCNPJ, "A1_LOJA")
       kNomeCli  := POSICIONE("SA1",3,XFILIAL("SA1") + kCNPJ, "A1_NOME")

       // ###################################
       // Pesquisa a condição de pagamento ##
       // ###################################
       kCondicao := "120"
       kNomeCond := POSICIONE("SE4",1,XFILIAL("SE4") + "120", "E4_DESCRI")

       // #################
       // Pesquisa o TES ##
       // #################
       kTES     := "717"
       kNomeTES := POSICIONE("SF4",1,XFILIAL("SF4") + "717", "F4_TEXTO")

       // ##################################
       // Pesquisa a descrição do produto ##
       // ##################################
       kProduto := "004604                        "
       kNomePro := POSICIONE("SB1",1,XFILIAL("SB1") + kProduto, "B1_DESC") + POSICIONE("SB1",1,XFILIAL("SB1") + kProduto, "B1_DAUX")

       // ###################################
       // Pesquisa a descrição do vendedor ##
       // ###################################
       kVendedor := "000010"
       kNomeVend := POSICIONE("SA3",1,XFILIAL("SA3") + kVendedor, "A3_NOME")

       // #######################################
       // Captura o valor total a ser faturado ##
       // #######################################
       kValorFat := 0
       For nContar = 1 to Len(aLista)
           If Alltrim(aLista[nContar,16]) == Alltrim(kCodiDist) .And. Alltrim(aLista[nContar,17]) == Alltrim(kLojaDist)
              If aLista[nContar,01] == .T.
                 kValorFat := kValorFat + VAL(StrTran(aLista[nContar,08], ",", "."))
              Endif
           Endif   
       Next nContar       

       // ########################################################################
       // Varifica se existe valor adicional a ser faturado para o distribuidor ##
       // ########################################################################
       kAdicional := 0
       lComTotal  := 0

       For nContar = 1 to Len(aAdicional)
           If aAdicional[nContar,01] == kCodiDist .And. aAdicional[nContar,02] == kLojaDist
              kAdicional  := aAdicional[nContar,04]
              Exit
           Endif
       Next nContar       

       kComTotal := kValorFat + kAdicional

       // ##############################
       // Desenha a tela para display ##
       // ##############################
       DEFINE MSDIALOG oDlgPV TITLE "Confirmação Faturamento de Comissões" FROM C(178),C(181) TO C(644),C(642) PIXEL

       @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(122),C(026) PIXEL NOBORDER OF oDlgPV

       @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(223),C(001) PIXEL OF oDlgPV
       @ C(062),C(002) GET oMemo3 Var cMemo3 MEMO Size C(223),C(001) PIXEL OF oDlgPV
   
       @ C(038),C(005) Say "Faturamento referente ao distribuidor" Size C(089),C(008) COLOR CLR_BLACK PIXEL OF oDlgPV
       @ C(066),C(005) Say "DADOS PARA O PEDIDO DE VENDA"          Size C(094),C(008) COLOR CLR_BLACK PIXEL OF oDlgPV
       @ C(078),C(005) Say "Cliente"                               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgPV
       @ C(098),C(005) Say "Cond.Pagtº"                            Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgPV
       @ C(117),C(005) Say "TES"                                   Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlgPV
       @ C(136),C(005) Say "Produto"                               Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgPV
       @ C(154),C(005) Say "Vendedor"                              Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgPV
       @ C(173),C(166) Say "Valor Total Comissão"                  Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgPV
       @ C(193),C(166) Say "Valor Adicional"                       Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgPV
       @ C(213),C(166) Say "Valor Total Total A Faturar"           Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgPV
       @ C(173),C(005) Say "Mensagem para Nota Fiscal"             Size C(069),C(008) COLOR CLR_BLACK PIXEL OF oDlgPV
   
       @ C(047),C(005) MsGet oGet1  Var kCodiDist      Size C(026),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgPV
       @ C(047),C(034) MsGet oGet2  Var kLojaDist      Size C(018),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgPV
       @ C(047),C(055) MsGet oGet3  Var kNomeDist      Size C(171),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgPV When lChumba
       @ C(086),C(005) MsGet oGet5  Var kCliente       Size C(026),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgPV F3("SA1")
       @ C(086),C(034) MsGet oGet6  Var kLojaCli       Size C(018),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgPV VALID( PPCliente() )
       @ C(086),C(055) MsGet oGet7  Var kNomeCli       Size C(171),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgPV When lChumba
       @ C(106),C(005) MsGet oGet8  Var kCondicao      Size C(026),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgPV F3("SE4") VALID( PPCondicao() )
       @ C(106),C(034) MsGet oGet9  Var kNomeCond      Size C(192),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgPV When lChumba
       @ C(125),C(005) MsGet oGet10 Var kTES           Size C(026),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgPV F3("SF4") VALID( PPTES() )
       @ C(125),C(034) MsGet oGet11 Var kNomeTES       Size C(192),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgPV When lChumba
       @ C(144),C(005) MsGet oGet12 Var kProduto       Size C(047),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgPV F3("SB1") VALID( PPProduto() )
       @ C(144),C(055) MsGet oGet13 Var kNomePro       Size C(171),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgPV When lChumba
       @ C(162),C(005) MsGet oGet14 Var kVendedor      Size C(026),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgPV F3("SA3") VALID( PPVendedor() )
       @ C(162),C(034) MsGet oGet15 Var kNomeVend      Size C(192),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgPV When lChumba
       @ C(181),C(005) GET   oMemo4 Var kMensagem MEMO Size C(156),C(035)                                         PIXEL OF oDlgPV

       @ C(181),C(166) MsGet oGet4  Var kValorFat      Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgPV When lChumba
       @ C(202),C(166) MsGet oGet16 Var kAdicional     Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgPV When lChumba
       @ C(221),C(166) MsGet oGet17 Var kComTotal      Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgPV When lChumba

       @ C(218),C(045) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgPV ACTION( PPGerPPVV() )
       @ C(218),C(084) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgPV ACTION( oDlgPV:End() )

       ACTIVATE MSDIALOG oDlgPV CENTERED 

   Next nPedidos

Return(.T.)

// ##########################################
// Função que pesquisa o cliente informado ##
// ##########################################
Static Function PPCliente()

   If Empty(Alltrim(kCliente)) .Or. Empty(Alltrim(kLojaCli))
      kCliente := Space(06)
      kLojaCli := Space(03)
      kNomeCli := Space(60)
      oGet5:Refresh()   
      oGet6:Refresh()   
      oGet7:Refresh()         
      Return(.T.)             
   Endif

   kNomeCli := POSICIONE("SA1",1,XFILIAL("SA1") + kCliente + kLojaCli, "A1_NOME")

   If Empty(Alltrim(kNomeCli))
      MsgAlert("Cliente informado não cadatrado.")
      kCliente := Space(06)
      kLojaCli := Space(03)
      kNomeCli := Space(60)
      oGet5:Refresh()   
      oGet6:Refresh()   
      oGet7:Refresh()         
      Return(.T.)
   Endif

Return(.T.)     

// ##############################################
// Função que pesquisa a Condição de Pagamento ##
// ##############################################
Static Function PPCondicao()

   If Empty(Alltrim(kCondicao))
      kCondicao := Space(03)
      kNomeCond := Space(60)
      oGet8:Refresh()   
      oGet9:Refresh()   
      Return(.T.)             
   Endif

   kNomeCond := POSICIONE("SE4",1,XFILIAL("SE4") + kCondicao, "E4_DESCRI")

   If Empty(Alltrim(kNomeCond))
      MsgAlert("Condição de Pagamento informada não cadastrada.")
      kCondicao := Space(03)
      kNomeCond := Space(60)
      oGet8:Refresh()   
      oGet9:Refresh()   
      Return(.T.)             
   Endif

Return(.T.)

// ######################################
// Função que pesquisa o TES informado ##
// ######################################
Static Function PPTES()

   If Empty(Alltrim(kTES))
      kTES     := Space(03)
      kNomeTES := Space(60)
      oGet10:Refresh()   
      oGet11:Refresh()   
      Return(.T.)             
   Endif

   kNomeTES := POSICIONE("SF4",1,XFILIAL("SF4") + kTES, "F4_TEXTO")

   If Empty(Alltrim(kNomeTES))
      MsgAlert("TES informado não cadastrado.")
      kTES     := Space(03)
      kNomeTES := Space(60)
      oGet10:Refresh()   
      oGet11:Refresh()   
   Endif

Return(.T.)           

// ##########################################
// Função que pesquisa o produto informado ##
// ##########################################
Static Function PPProduto()

   If Empty(Alltrim(kProduto))
      kProduto := Space(30)
      kNomePro := Space(60)
      oGet12:Refresh()   
      oGet13:Refresh()   
      Return(.T.)             
   Endif

   kNomePro := POSICIONE("SB1",1,XFILIAL("SB1") + kProduto, "B1_DESC") + POSICIONE("SB1",1,XFILIAL("SB1") + kProduto, "B1_DAUX")

   If Empty(Alltrim(kNomePro))
      MsgAlert("Produto informado não cadastrado.")
      kProduto := Space(30)
      kNomePro := Space(60)
      oGet12:Refresh()   
      oGet13:Refresh()   
   Endif

Return(.T.)

// #################################
// Função que pesquisa o vendedor ##
// #################################
Static Function PPVendedor()

   If Empty(Alltrim(kVendedor))
      kVendedor := Space(06)
      kNomeVend := Space(60)
      oGet13:Refresh()   
      oGet14:Refresh()   
      Return(.T.)             
   Endif

   kNomeVend := POSICIONE("SA3",1,XFILIAL("SA3") + kVendedor, "A3_NOME")

   If Empty(Alltrim(kVendedor))
      MsgAlert("Vendedor informado não cadastrado.")
      kvendedor := Space(06)
      kNomeVend := Space(60)
      oGet13:Refresh()   
      oGet14:Refresh()   
   Endif

Return(.T.)

// ####################################
// Função que gera o pedido de venda ##
// ####################################
Static Function PPGerPPVV()

   MsgRun("Aguarde! Gerando Pedido de Venda ...", "Faturamento de Comissões",{|| xPPGerPPVV() })
   
Return(.T.)

// ####################################
// Função que gera o pedido de venda ##
// ####################################
Static Function xPPGerPPVV()

   Local nContar     := 0
   Local cNumPed
   Local lPrimeiro   := .T.
   Local lDeuCerto   := .F.
   
   Local aArea       := GetArea() //Irei gravar a are3a atual

   Private Inclui    := .F.                // Defino que a inclusão é falsa
   Private Altera    := .T.                // Defino que a alteração é verdadeira
   Private nOpca     := 1                  // Obrigatoriamente passo a variavel nOpca com o conteudo 1
   Private cCadastro := "Pedido de Vendas" // Obrigatoriamente preciso definir com private a variável cCadastro
   Private aRotina   := {}                 // Obrigatoriamente preciso definir a variavel aRotina como private

   Private _aCabec     := {}
   Private _aItens     := {}
   Private lMsErroAuto := .F. 
   Private lMsHelpAuto := .F. 

   // ####################################################################
   // Realiza a consistência dos dados antes de gerar o pedido de venda ##
   // ####################################################################
   If Empty(Alltrim(kCliente))
      MsgAlert("Código do Cliente não informado.")
      Return(.T.)
   Endif
      
   If kValorFat == 0
      MsgAlert("Valor a ser faturado não informado.")
      Return(.T.)
   Endif
  
   If Empty(Alltrim(kCondicao))
      MsgAlert("Condição de Pagamento não informada.")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(kTES))
      MsgAlert("Tipo de Entrada/Saída (TES) não informada.")
      Return(.T.)
   Endif

   If Empty(Alltrim(kProduto))
      MsgAlert("Produto não informado.")
      Return(.T.)
   Endif

   If Empty(Alltrim(kVendedor))
      MsgAlert("Vendedor não informado.")
      Return(.T.)
   Endif

   Do Case
      Case Substr(cComboBx1,01,02) == "01"
           Do Case
              Case Substr(cComboBx2,01,02) == "01"
                   kEstado    := "RS"
                   kMunicipio := "14902"
              Case Substr(cComboBx2,01,02) == "02"
                   kEstado    := "RS"
                   kMunicipio := "05108"
              Case Substr(cComboBx2,01,02) == "03"
                   kEstado    := "RS"
                   kMunicipio := "14407"
              Case Substr(cComboBx2,01,02) == "04"
                   kEstado    := "RS"
                   kMunicipio := "14902"
              Case Substr(cComboBx2,01,02) == "05"
                   kEstado    := "SP"
                   kMunicipio := "50308"
              Case Substr(cComboBx2,01,02) == "06"
                   kEstado    := "ES"
                   kMunicipio := "01308"
           EndCase        
      Case Substr(cComboBx1,01,02) == "02"
           kEstado    := "PR"
           kMunicipio := "06902"
      Case Substr(cComboBx1,01,02) == "03"
           kEstado    := "RS"
           kMunicipio := "14902"
      Case Substr(cComboBx1,01,02) == "04"
           kEstado    := "RS"
           kMunicipio := "14407"
   EndCase

   lDeuCerto := .F.

   // ######################################### 
   // Pesquisa o nº do pedido a ser incluído ##
   // #########################################
   cNumPed := GetSX8Num("SC5","C5_NUM")
   ConfirmSx8()

   Begin Transaction

      DbSelectArea("SC5")
      DbSetOrder(1)
      Reclock("SC5",.T.)
      SC5->C5_FILIAL   := cFilAnt
      SC5->C5_NUM      := cNumPed
      SC5->C5_TIPO     := "N"
      SC5->C5_CLIENTE  := kCliente
      SC5->C5_LOJACLI  := kLojaCli
      SC5->C5_CLIENT   := kCliente
      SC5->C5_LOJAENT  := kLojaCli
      SC5->C5_TIPOCLI  := "J"
      SC5->C5_CONDPAG  := kCondicao
      SC5->C5_TABELA   := "001"
      SC5->C5_EMISSAO  := dDataBase
      SC5->C5_MOEDA    := 1
      SC5->C5_TIPLIB   := "1"
      SC5->C5_TXMOEDA  := 1
      SC5->C5_TPCARGA  := "2"
      SC5->C5_GERAWMS  := "1"
      SC5->C5_SOLOPC   := "1"
      SC5->C5_ESTPRES  := kEstado
//    SC5->C5_JPCSEP   := "T"                                                  
      SC5->C5_EXTERNO  := "2"
      SC5->C5_MUNPRES  := kMunicipio
      SC5->C5_MENNOTA  := kMensagem
      SC5->C5_VEND1    := kVendedor
      SC5->C5_FORMA    := "1"
      SC5->C5_QEXAT    := "N"
      SC5->C5_TPFRETE  := "C"
      SC5->C5_INCISS   := "S"
      MsUnlock()         

      DbSelectArea("SC6")
      DbSetOrder(1)
      Reclock("SC6",.T.)
      SC6->C6_FILIAL  := cFilAnt
      SC6->C6_ITEM    := "01"
      SC6->C6_PRODUTO := Alltrim(kProduto)
      SC6->C6_DESCRI  := Alltrim(Posicione( "SB1", 1, xFilial("SB1") + kProduto, "B1_DESC" ))
      SC6->C6_UM      := Alltrim(Posicione( "SB1", 1, xFilial("SB1") + kProduto, "B1_UM"   ))
      SC6->C6_QTDVEN  := 1
      SC6->C6_PRCVEN  := kComTotal
      SC6->C6_VALOR   := kComTotal
      SC6->C6_TES     := Alltrim(kTES)
      SC6->C6_LOCAL   := "01"
      SC6->C6_ENTREG  := dDataBase
      SC6->C6_SUGENTR := dDataBase
      SC6->C6_CLI     := kCliente
      SC6->C6_LOJA    := kLojaCli
      SC6->C6_NUM     := cNumPed
      SC6->C6_TPOP    := "F"
      SC6->C6_STATUS  := "01"
      SC6->C6_RATEIO  := "2"
      SC6->C6_TEMDOC  := "N"
      SC6->C6_CF      := Alltrim(Posicione( "SF4", 1, xFilial("SF4") + kTES    , "F4_CF"     ))
      SC6->C6_CODFAB  := Alltrim(Posicione( "SB1", 1, xFilial("SB1") + kProduto, "B1_PROC"   ))
      SC6->C6_LOJAFA  := Alltrim(Posicione( "SB1", 1, xFilial("SB1") + kProduto, "B1_LOJPROC"))
      SC6->C6_CODISS  := Alltrim(Posicione( "SBZ", 1, xFilial("SBZ") + kProduto, "BZ_CODISS" ))
      SC6->C6_CLASFIS := "041"
      MsUnlock()         

      // ###############################################################################      
      // Captura Valor e Observações dos Adicionais para o Distribuidor para gravação ##
      // ###############################################################################
      For nContar = 1 to Len(aAdicional)
          If aAdicional[nContar,01] == kCodiDist .And. aAdicional[nContar,02] == kLojaDist             
             kAdicional  := aAdicional[nContar,04]
             kObservacao := aAdicional[nContar,05]
             Exit
          Endif
      Next nContar       

   End Transaction

   // ###############################################################################################
   // Chama a tela do pedido de venda com a opção de alteração para gravação dos pontos de entrada ##
   // ###############################################################################################
   DbSelectArea("SC5")
   DbSetorder(1)
   If DbSeek(xFilial("SC5") + cNumPed)
  	  MatA410(Nil, Nil, Nil, Nil, "A410Altera")
   Endif
   RestArea(aArea) //restauro a area anterior.

   // ####################################################################################
   // Atualiza a tabela ZPH (Conta Corrente de Cobrança de Comissão de Pedidos Externos ##
   // ####################################################################################
   lPrimeiro := .T.
      
   For nContar = 1 to Len(aLista)

       If Alltrim(aLista[nContar,16]) == Alltrim(kCodiDist) .And. Alltrim(aLista[nContar,17]) == Alltrim(kLojaDist)

          If aLista[nContar,01] == .T.

             DbSelectArea("ZPH")
             DbSetOrder(1)
             Reclock("ZPH",.T.)
             ZPH->ZPH_FILIAL := Substr(aLista[nContar,29],01,02)
             ZPH->ZPH_EMPO   := Substr(aLista[nContar,28],01,02)
             ZPH->ZPH_PEDO   := aLista[nContar,19]
             ZPH->ZPH_PARO   := aLista[nContar,04]
             ZPH->ZPH_VALO   := VAL(StrTran(aLista[nContar,08], ",", "."))
             ZPH->ZPH_DIST   := aLista[nContar,16]
             ZPH->ZPH_LOJA   := aLista[nContar,17]
             ZPH->ZPH_EMPD   := cEmpAnt
             ZPH->ZPH_FILD   := cFilAnt
             ZPH->ZPH_PEDD   := cNumPed
             ZPH->ZPH_PARD   := aLista[nContar,04]
             ZPH->ZPH_VALD   := VAL(StrTran(aLista[nContar,08], ",", "."))
             ZPH->ZPH_NOTA   := ""
             ZPH->ZPH_SERI   := ""
             ZPH->ZPH_EMIS   := Ctod("  /  /    ")
             ZPH->ZPH_DELE   := ""

             If lPrimeiro == .T.
                ZPH->ZPH_ADIC := kAdicional
                ZPH->ZPH_MOTI := kObservacao 
                lPrimeiro     := .F.
             Endif   

             MsUnlock()

          Endif

       Endif   

   Next nContar       
   
   oDlgPV:End()

   // ##################################################
   // Envia para a função que atualiza o grid da tela ##
   // ##################################################
   PsqExterno()

Return(.T.)

// ###############################################################
// Função que abre a janela de valor adicional para faturamento ##
// ###############################################################
Static Function PPAdicional()

   Local nContar := 0
   Local cMemo1	 := ""
   Local oMemo1
   
   Private lEdita      := .F.
   Private aDistribui  := {}
   Private nAdicional  := 0
   Private cObservacao := ""

   Private cDistribui
   Private oGet1
   Private oMemo2

   Private oDlgADD

   // ###########################################
   // Carrega o combobox com os distribuidores ##
   // ###########################################
   aAdd( aDistribui, "000000.000 - Selecione o Distribuidor" )   

   For nContar = 1 to Len(aAdicional)
       aAdd( aDistribui, aAdicional[nContar,01] + "." + aAdicional[nContar,02] + " - " + Alltrim(aAdicional[nContar,03]) )
   Next nContar     

   DEFINE MSDIALOG oDlgADD TITLE "Valor de Comissão Adicional" FROM C(178),C(181) TO C(574),C(559) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgADD

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO   Size C(182),C(001) PIXEL OF oDlgADD

   @ C(037),C(005) Say "Distribuidor"                     Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgADD
   @ C(059),C(005) Say "Valor adicional para faturamento" Size C(078),C(008) COLOR CLR_BLACK PIXEL OF oDlgADD
   @ C(082),C(005) Say "Observações"                      Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgADD

   @ C(047),C(005) ComboBox cDistribui Items aDistribui     Size C(180),C(010)                                         PIXEL OF oDlgADD ON CHANGE TROCADIST()
   @ C(069),C(005) MsGet    oGet1      Var nAdicional       Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgADD When lEdita
   @ C(091),C(005) GET      oMemo2     Var cObservacao MEMO Size C(179),C(087)                                         PIXEL OF oDlgADD When lEdita

   @ C(181),C(056) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgADD ACTION( SalvaAdicional() )
   @ C(181),C(095) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgADD ACTION( oDlgADD:End() )

   ACTIVATE MSDIALOG oDlgADD CENTERED 

Return(.T.)

// ########################################################################
// Função que realiza a troca do distribuidor na tela de valor adicional ##
// ########################################################################
Static Function TROCADIST()

   Local nContar := 0

   nAdicional  := 0
   cObservacao := ""

   For nContar = 1 to Len(aAdicional)
       If aAdicional[nContar,01] == Substr(cDistribui,01,06) .And. aAdicional[nContar,02] == Substr(cDistribui,08,03)
          nAdicional  := aAdicional[nContar,04]
          cObservacao := aAdicional[nContar,05]
          Exit
       Endif
   Next nContar       

   If Substr(cDistribui,01,06) == "000000"
      lEdita := .F.
   Else
      lEdita := .T.      
   Endif

   oGet1:Refresh()
   oMemo2:Refresh()

Return(.T.)

// #########################################
// Função que salva o adicional informado ##
// #########################################
Static Function SalvaAdicional()

   Local nContar := 0

   For nContar = 1 to Len(aAdicional)
       If aAdicional[nContar,01] == Substr(cDistribui,01,06) .And. aAdicional[nContar,02] == Substr(cDistribui,08,03)
          aAdicional[nContar,04] := nAdicional
          aAdicional[nContar,05] := cObservacao
          Exit
       Endif
   Next nContar       

   oDlgADD:End()
 
Return(.T.)

// #########################################
// Função que realiza a pesquisa avançada ##
// #########################################
Static Function BuscaLista()

   Local lAchei  := .F.
   Local nContar := 0
   Local cMemo1	 := ""
   Local oMemo1

   Private oDlgSel

   Private aSelecao := {}
   Private oSelecao

   If Empty(Alltrim(cString))
      MsgAlert("String a ser pesquisada não informada. Verifique!")
      Return(.T.)
   Endif

   If Substr(cComboBx5,01,02) == "00"
      MsgAlert("Tipo de campo a ser consultado não selecionado. Verifique!")
      Return(.T.)
   Endif   

   // ###################################################################
   // Pesquisa a nota fiscal do distribuidor informada no array aLista ##
   // ###################################################################
   lAchei := .F.
   
   For nContar = 1 to Len(aLista)
   
       Do Case
          Case Substr(cComboBx5,01,02) == "01"
               If U_P_OCCURS(Alltrim(Upper(aLista[nContar,03])), Alltrim(Upper(cString)), 1) == 0
               Else
                  aAdd( aSelecao, { aLista[nContar,30], aLista[nContar,03] })
               Endif

          Case Substr(cComboBx5,01,02) == "02"
               If U_P_OCCURS(Alltrim(Upper(aLista[nContar,16])), Alltrim(Upper(cString)), 1) == 0
               Else
                  aAdd( aSelecao, { aLista[nContar,30], aLista[nContar,16] })
               Endif

          Case Substr(cComboBx5,01,02) == "03"
               If U_P_OCCURS(Alltrim(Upper(aLista[nContar,17])), Alltrim(Upper(cString)), 1) == 0
               Else
                  aAdd( aSelecao, { aLista[nContar,30], aLista[nContar,17] })
               Endif

          Case Substr(cComboBx5,01,02) == "04"
               If U_P_OCCURS(Alltrim(Upper(aLista[nContar,18])), Alltrim(Upper(cString)), 1) == 0
               Else
                  aAdd( aSelecao, { aLista[nContar,30], aLista[nContar,18] })
               Endif

          Case Substr(cComboBx5,01,02) == "05"
               If U_P_OCCURS(Alltrim(Upper(aLista[nContar,19])), Alltrim(Upper(cString)), 1) == 0
               Else
                  aAdd( aSelecao, { aLista[nContar,30], aLista[nContar,19] })
               Endif

          Case Substr(cComboBx5,01,02) == "06"
               If U_P_OCCURS(Alltrim(Upper(aLista[nContar,21])), Alltrim(Upper(cString)), 1) == 0
               Else
                  lAchei := .T.
                  Exit
               Endif

          Case Substr(cComboBx5,01,02) == "07"
               If U_P_OCCURS(Alltrim(Upper(aLista[nContar,23])), Alltrim(Upper(cString)), 1) == 0
               Else
                  aAdd( aSelecao, { aLista[nContar,30], aLista[nContar,23] })
               Endif

          Case Substr(cComboBx5,01,02) == "08"
               If U_P_OCCURS(Alltrim(Upper(aLista[nContar,24])), Alltrim(Upper(cString)), 1) == 0
               Else
                  aAdd( aSelecao, { aLista[nContar,30], aLista[nContar,24] })
               Endif

          Case Substr(cComboBx5,01,02) == "09"
               If U_P_OCCURS(Alltrim(Upper(aLista[nContar,25])), Alltrim(Upper(cString)), 1) == 0
               Else
                  aAdd( aSelecao, { aLista[nContar,30], aLista[nContar,25] })
               Endif

          Case Substr(cComboBx5,01,02) == "10"
               If U_P_OCCURS(Alltrim(Upper(aLista[nContar,26])), Alltrim(Upper(cString)), 1) == 0
               Else
                  aAdd( aSelecao, { aLista[nContar,30], aLista[nContar,26] })
               Endif

          Case Substr(cComboBx5,01,02) == "11"
               If U_P_OCCURS(Alltrim(Upper(aLista[nContar,27])), Alltrim(Upper(cString)), 1) == 0
               Else
                  aAdd( aSelecao, { aLista[nContar,30], aLista[nContar,27] })
               Endif
               
       EndCase        

   Next nContar

   If Len(aSelecao) == 0
      MsgAlert("Nenhum registro encontrado para esta pesquisa.")
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgSel TITLE "Novo Formulário" FROM C(178),C(181) TO C(482),C(420) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgSel

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(113),C(001) PIXEL OF oDlgSel

   @ C(136),C(002) Button "ZOOM"   Size C(037),C(012) PIXEL OF oDlgSel ACTION( ZoomDeRegistro(aSelecao[oSelecao:nAt,01]) )
   @ C(136),C(041) Button "Movtºs" Size C(037),C(012) PIXEL OF oDlgSel ACTION( ContaCorrenteFat(aSelecao[oSelecao:nAt,01]) )
   @ C(136),C(079) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgSel ACTION( oDlgSel:End() )

   @ 045,005 LISTBOX oSelecao FIELDS HEADER "Lançamento", "Conteúdo";
                                     PIXEL SIZE 145,127 OF oDlgSel FONT oFont ON dblClick(aSelecao[oSelecao:nAt,1] := !aSelecao[oSelecao:nAt,1],oSelecao:Refresh())     

   oSelecao:SetArray( aSelecao )

   oSelecao:bLine := {||{aSelecao[oSelecao:nAt,01], aSelecao[oSelecao:nAt,02]}}

   ACTIVATE MSDIALOG oDlgSel CENTERED 

Return(.T.)

// ########################################
// Função que abre a janela das legendas ##
// ########################################
Static Function MostraLgndas()

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private oDlgLEG

   DEFINE MSDIALOG oDlgLEG TITLE "Legenda" FROM C(178),C(181) TO C(379),C(461) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(134),C(022) PIXEL NOBORDER OF oDlgLEG

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(133),C(001) PIXEL OF oDlgLEG
   @ C(076),C(002) GET oMemo2 Var cMemo2 MEMO Size C(133),C(001) PIXEL OF oDlgLEG

   @ C(035),C(025) Say "A FATURAR"              Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlgLEG
   @ C(047),C(025) Say "FATURADOS TOTALMENTE"   Size C(072),C(008) COLOR CLR_BLACK PIXEL OF oDlgLEG
   @ C(062),C(025) Say "FATURADOS PARCIALMENTE" Size C(077),C(008) COLOR CLR_BLACK PIXEL OF oDlgLEG

   @ C(033),C(010) Jpeg FILE "br_vermelho.png"  Size C(009),C(009) PIXEL NOBORDER OF oDlgLEG
   @ C(046),C(010) Jpeg FILE "br_verde.png"     Size C(009),C(009) PIXEL NOBORDER OF oDlgLEG
   @ C(060),C(010) Jpeg FILE "br_amarelo.png"   Size C(009),C(009) PIXEL NOBORDER OF oDlgLEG

   @ C(082),C(051) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgLEG ACTION(oDlgLEG:End() )

   ACTIVATE MSDIALOG oDlgLEG CENTERED 

Return(.T.)

// #####################################################################################
// Função que abre a janela do conta corrente de faturamento da comissão seleciionada ##
// #####################################################################################
Static Function ContaCorrenteFat(kRegistro)

   Local lChumba := .F.
   Local cSql    := ""
   Local nContar := 0
   Local cMemo1	 := ""
   Local oMemo1

   Local kPedido	     := ""
   Local kDistribuidor   := ""
   Local kNFDistribuidor := ""
   Local kPedidoExterno  := ""
   Local kNotaFiscal  	 := ""
   Local kSerieNF	     := ""
   Local xxFilial        := ""

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5
   Local oGet6

   Private aBrowse := {}

   Private oDlgCTA            
   
   If Empty(Alltrim(aLista[oLista:nAt,03]))
      Return(.T.)
   Endif   

   // #####################################################
   // Posiciona no regsitro para captura das informações ##
   // #####################################################
   For nContar = 1 to Len(aLista)
       If Alltrim(aLista[nContar,30]) == Alltrim(kRegistro)
          Exit
       Endif
   Next nContar
          
   kPedido	       := aLista[nContar,19]
   kDistribuidor   := aLista[nContar,16] + "." + aLista[nContar,17] + " - " + aLista[nContar,18]
   kNFDistribuidor := aLista[nContar,03]
   kPedidoExterno  := aLista[nContar,21]
   kNotaFiscal     := aLista[nContar,23]
   kSerieNF	       := aLista[nContar,24]
   xxFilial        := Substr(aLista[nContar,29],01,02)

   // #########################################################
   // Pesquisa os movimentos para o distribuidor/nota fiscal ##
   // #########################################################
   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZPH.ZPH_FILIAL,"
   cSql += "      (SELECT C5_EMISSAO FROM SC5010 WHERE C5_FILIAL = ZPH_FILIAL AND C5_NUM = ZPH.ZPH_PEDO AND D_E_L_E_T_ = '') AS EMISSAO,"
   cSql += "       ZPH.ZPH_PEDO  ,"
   cSql += "	   ZPH.ZPH_PARO  ,"
   cSql += "      (SELECT TOP(1) C6_NOTA  FROM SC6010 WHERE C6_FILIAL = ZPH_FILIAL AND C6_NUM = ZPH.ZPH_PEDO AND D_E_L_E_T_ = '') AS NOTA ,"
   cSql += "      (SELECT TOP(1) C6_SERIE FROM SC6010 WHERE C6_FILIAL = ZPH_FILIAL AND C6_NUM = ZPH.ZPH_PEDO AND D_E_L_E_T_ = '') AS SERIE,"
   cSql += "	   ZPH.ZPH_VALO  ,"
   cSql += "	   ZPH.ZPH_FILD  ,"
   cSql += "	   ZPH.ZPH_PEDD  ,"
   cSql += "      (SELECT TOP(1) C6_NOTA  FROM " + RetSqlName("SC6") + " WHERE C6_FILIAL = ZPH_FILD AND C6_NUM = ZPH.ZPH_PEDD AND D_E_L_E_T_ = '') AS NOTA_NOVA ,"
   cSql += "      (SELECT TOP(1) C6_SERIE FROM " + RetSqlName("SC6") + " WHERE C6_FILIAL = ZPH_FILD AND C6_NUM = ZPH.ZPH_PEDD AND D_E_L_E_T_ = '') AS SERIE_NOVA "
   cSql += "  FROM " + RetSqlName("ZPH") + " ZPH "
   cSql += " WHERE ZPH.ZPH_FILIAL = '" + Alltrim(xxFilial) + "'"
   cSql += "   AND ZPH.ZPH_PEDO   = '" + Alltrim(kPedido)  + "'"
   cSql += "   AND ZPH.ZPH_DELE   = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )

      kEmissao := Substr(T_CONSULTA->EMISSAO,07,02) + "/" +Substr(T_CONSULTA->EMISSAO,05,02) + "/" +Substr(T_CONSULTA->EMISSAO,01,04)
   
      aAdd( aBrowse, {T_CONSULTA->ZPH_FILIAL,; // 01
                      kEmissao              ,; // 02
                      T_CONSULTA->ZPH_PEDO  ,; // 03
                      T_CONSULTA->NOTA      ,; // 04
                      T_CONSULTA->SERIE     ,; // 05
                      T_CONSULTA->ZPH_PARO  ,; // 06
                      T_CONSULTA->ZPH_FILD  ,; // 07
                      T_CONSULTA->ZPH_PEDD  ,; // 08
                      T_CONSULTA->NOTA_NOVA ,; // 09
                      T_CONSULTA->SERIE_NOVA,; // 10
                      T_CONSULTA->ZPH_VALO  }) // 11

      aAdd( aBrowse, { "", "", "", "", "", "", "", "", "", "", "" })

      T_CONSULTA->( DbSkip() )
      
   ENDDO   

   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "", "", "", "", "", "", "", "", "", "" })
   Endif   

   DEFINE MSDIALOG oDlgCTA TITLE "Conta Corrente de Faturamento de Comissões" FROM C(178),C(181) TO C(497),C(951) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgCTA

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(378),C(001) PIXEL OF oDlgCTA

   @ C(036),C(005) Say "Distribuidor"    Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgCTA
   @ C(036),C(186) Say "NF Distribuidor" Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlgCTA
   @ C(036),C(232) Say "Ped.Externo"     Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgCTA
   @ C(036),C(278) Say "PV. Origem"      Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgCTA
   @ C(036),C(322) Say "N.Fiscal"        Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgCTA
   @ C(036),C(360) Say "Série"           Size C(015),C(008) COLOR CLR_BLACK PIXEL OF oDlgCTA

   @ C(046),C(005) MsGet oGet1 Var kDistribuidor   Size C(175),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCTA When lChumba
   @ C(046),C(186) MsGet oGet2 Var kNFDistribuidor Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCTA When lChumba
   @ C(046),C(232) MsGet oGet3 Var kPedidoExterno  Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCTA When lChumba
   @ C(046),C(278) MsGet oGet4 Var kPedido         Size C(038),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCTA When lChumba
   @ C(046),C(322) MsGet oGet5 Var kNotaFiscal     Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCTA When lChumba
   @ C(046),C(360) MsGet oGet6 Var kSerieNF        Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgCTA When lChumba

   @ C(144),C(343) Button "Voltar"       Size C(037),C(012) PIXEL OF oDlgCTA ACTION( oDlgCTA:End() )

   // ###################
   // Desenha o Browse ##
   // ###################
   oBrowse := TCBrowse():New( 075 , 005, 480, 106,,{'Filial', 'Emissão', 'Nº P.Venda', 'NFiscal', 'Série', 'Parcela', 'Filial', 'P.Venda', 'NFiscal', 'Série', 'Valor Comissao' },{20,50,50,50},oDlgCTA,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

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
                         aBrowse[oBrowse:nAt,11]}}

   ACTIVATE MSDIALOG oDlgCTA CENTERED 

Return(.T.)

// ########################################
// Função que atualiza os totais da tela ##
// ########################################
Static Function TotaisTela()

   Local nContar := 0
   
   nTotalPed := 0
   nTotalCom := 0
   nTotalFat := 0
   nTotalAfa := 0
   nTotalSal := 0
   
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .F.
          Loop
       Endif   
       If Empty(Alltrim(aLista[nContar,03]))
       Else
          nTotalPed := nTotalPed + VAL(StrTran(aLista[nContar,10], ",", "."))
          nTotalCom := nTotalCom + VAL(StrTran(aLista[nContar,06], ",", "."))
          nTotalFat := nTotalFat + VAL(StrTran(aLista[nContar,07], ",", "."))
          nTotalAfa := nTotalAfa + VAL(StrTran(aLista[nContar,08], ",", "."))
          nTotalSal := nTotalSal + VAL(StrTran(aLista[nContar,09], ",", "."))
       Endif   
   Next nContar        

   oGet7:Refresh()
   oGet8:Refresh()
   oGet9:Refresh()
   oGet10:Refresh()         
   oGet11:Refresh()         

Return(.T.)

   // #########################################
   // Atualiza os totais por pedido de venda ##
   // #########################################
   kk_Comissao := 0
   kk_Faturado := 0
   kk_Afaturar := 0
   kk_Saldo    := 0
   kk_Pedido   := 0

   For nContar = 1 to Len(aLista)

       If Empty(Alltrim(aLista[nContar,05]))
          aLista[nContar,06] := ""
          aLista[nContar,07] := ""
          aLista[nContar,08] := ""
          aLista[nContar,09] := ""
          aLista[nContar,10] := ""
          Loop
       Endif   

       If Alltrim(aLista[nContar,05]) <> "TOTAL PV"

          kk_Comissao := kk_Comissao + VAL(StrTran(aLista[nContar,06], ",", "."))
          kk_Faturado := kk_Faturado + VAL(StrTran(aLista[nContar,07], ",", "."))
          kk_Afaturar := kk_Afaturar + VAL(StrTran(aLista[nContar,08], ",", "."))
          kk_Saldo    := kk_Saldo    + VAL(StrTran(aLista[nContar,09], ",", "."))
          kk_Pedido   := kk_Pedido   + VAL(StrTran(aLista[nContar,10], ",", "."))
          
       Else   

          aLista[nContar,06] := Transform(kk_Comissao, "@E 9999999.99")
          aLista[nContar,07] := Transform(kk_Faturado, "@E 9999999.99")
          aLista[nContar,08] := Transform(kk_Afaturar, "@E 9999999.99")
          aLista[nContar,09] := Transform(kk_Saldo   , "@E 9999999.99")
          aLista[nContar,10] := Transform(kk_Pedido  , "@E 9999999.99")

          kk_Comissao := 0
          kk_Faturado := 0
          kk_Afaturar := 0
          kk_Saldo    := 0
          kk_Pedido   := 0

       Endif

   Next nContar              

Return(.T.)

// #####################################
// Função que abre o zoom de registro ##
// #####################################
Static Function ZoomDeRegistro(kRegistro)

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cString := ""
   Local nContar := 0

   Local oMemo1
   Local oMemo2

   // ##############################################################
   // Posiciona no registro selecionado parea display dos valores ##
   // ##############################################################
   For nContar = 1 to Len(aLista)
       If Alltrim(aLista[nContar,30]) == Alltrim(kRegistro)
          Exit
       Endif
   Next nContar       

   Private oDlgZ

   DEFINE FONT oFont Name "Courier New" Size 0, 14

   cString := ""
   cString := cString + "NF Distribuidor..............: " + aLista[nContar,03] + CHR(13) + CHR(10)
   cString := cString + "Parcela......................: " + aLista[nContar,04] + CHR(13) + CHR(10)
   cString := cString + "Dta Prev. Recebimento........: " + Dtoc(aLista[nContar,05]) + CHR(13) + CHR(10)
   cString := cString + "Valor Comissão...............: " + aLista[nContar,06] + CHR(13) + CHR(10)
   cString := cString + "Valor Faturado...............: " + aLista[nContar,07] + CHR(13) + CHR(10)
   cString := cString + "Valor A Faturar..............: " + aLista[nContar,08] + CHR(13) + CHR(10)
   cString := cString + "Saldo A Faturar..............: " + aLista[nContar,09] + CHR(13) + CHR(10)
   cString := cString + "Valor Pedido de Venda........: " + aLista[nContar,10] + CHR(13) + CHR(10)
   cString := cString + "% Comissão...................: " + aLista[nContar,12] + CHR(13) + CHR(10)
   cString := cString + "Dta Fat. P1..................: " + aLista[nContar,13] + CHR(13) + CHR(10)
   cString := cString + "Dta Cob.Comissão.............: " + aLista[nContar,14] + CHR(13) + CHR(10)
   cString := cString + "Distribuidor.................: " + aLista[nContar,16] + CHR(13) + CHR(10)
   cString := cString + "Loja.........................: " + aLista[nContar,17] + CHR(13) + CHR(10)
   cString := cString + "Nome do Distribuidores.......: " + aLista[nContar,18] + CHR(13) + CHR(10)
   cString := cString + "Nº Pedido de Venda...........: " + aLista[nContar,19] + CHR(13) + CHR(10)
   cString := cString + "Data de Emissão..............: " + aLista[nContar,20] + CHR(13) + CHR(10)
   cString := cString + "Pedido Externo...............: " + aLista[nContar,21] + CHR(13) + CHR(10)
   cString := cString + "Data Fechamento..............: " + aLista[nContar,22] + CHR(13) + CHR(10)
   cString := cString + "Nº Nota Fiscal...............: " + aLista[nContar,23] + CHR(13) + CHR(10)
   cString := cString + "Série........................: " + aLista[nContar,24] + CHR(13) + CHR(10)
   cString := cString + "Cliente......................: " + aLista[nContar,25] + CHR(13) + CHR(10)
   cString := cString + "Loja.........................: " + aLista[nContar,26] + CHR(13) + CHR(10)
   cString := cString + "Nome do Cliente..............: " + aLista[nContar,27] + CHR(13) + CHR(10)
   cString := cString + "Empresa de Origem............: " + aLista[nContar,28] + CHR(13) + CHR(10)
   cString := cString + "Filial de Origem.............: " + aLista[nContar,29] + CHR(13) + CHR(10)
   cString := cString + "Nº do Lançamento.............: " + aLista[nContar,30] + CHR(13) + CHR(10)

   DEFINE MSDIALOG oDlgZ TITLE "Zoom de Registro" FROM C(178),C(181) TO C(622),C(836) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoautoma.bmp" Size C(117),C(022) PIXEL NOBORDER OF oDlgZ

   @ C(028),C(002) GET oMemo1 Var cMemo1  MEMO Size C(322),C(001) PIXEL OF oDlgZ

   @ C(032),C(005) GET oMemo2 Var cString MEMO Size C(318),C(171) FONT ofont PIXEL OF oDlgZ When lChumba

   @ C(206),C(145) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgZ ACTION( oDlgZ:End() )

   ACTIVATE MSDIALOG oDlgZ CENTERED 

Return(.T.)

// ###########################################################
// Função que realiza a importação de arquivos de comissões ##
// ###########################################################
Static Function IMPLAYCOMIS()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1
   
   Private aLayout 	 := {"0 - Selecione o layout do arquivo a ser importado", "1 - SCANSOURCE", "2 - OFFICER", "3 - PRIME", "4 - LAYOUT PADRÃO"}
   Private cCaminho	 := Space(250)

   Private oGet1
   Private cComboBx100

   Private oDlgI
 
   If Empty(Alltrim(aLista[01,03]))
      MsgAlert("Necessário realizar a pesquisa dos dados antes da importação.")
      Return(.T.)
   Endif

   DEFINE MSDIALOG oDlgI TITLE "Importação Arquivo de Comissões" FROM C(178),C(181) TO C(374),C(645) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(117),C(022) PIXEL NOBORDER OF oDlgI

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(226),C(001) PIXEL OF oDlgI

   @ C(033),C(005) Say "Informe o caminho do arquivo de comissões a ser importado" Size C(143),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   @ C(056),C(005) Say "Layout do arquivo selecionado"                             Size C(074),C(008) COLOR CLR_BLACK PIXEL OF oDlgI
   
   @ C(043),C(005) MsGet oGet1 Var cCaminho              Size C(203),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgI When lChumba
   @ C(043),C(211) Button "..."                          Size C(016),C(009) PIXEL OF oDlgI ACTION( PESQCAMCOMIS() )
   @ C(065),C(005) ComboBox    cComboBx100 Items aLayout Size C(223),C(010) PIXEL OF oDlgI

   @ C(081),C(076) Button "Importar" Size C(037),C(012) PIXEL OF oDlgI ACTION( IMPARQSELEC() )
   @ C(081),C(115) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlgI ACTION( oDlgI:End() )

   ACTIVATE MSDIALOG oDlgI CENTERED 

Return(.T.)

// ###################################################################
// Função que abre diálogo de pesquisa do arquivo a serem importado ##
// ###################################################################
Static Function PESQCAMCOMIS()

   cCaminho := cGetFile('*.*', "Selecione o Arquivo a ser Importado",1,"C:\",.F.,16,.F.)

Return(.T.)

// ########################################################
// Função que importa o arquivo de comissões selecionado ##
// ########################################################
Static Function IMPARQSELEC()

   MsgRun("Aguarde! Importando arquivo selecionado ...", "Importação de Arquivo",{|| xIMPARQSELEC() })
   
Return(.T.)

// ########################################################
// Função que importa o arquivo de comissões selecionado ##
// ########################################################
Static Function xIMPARQSELEC()

   Local cConteudo    := ""
   Local nContar      := 0

   Private aResultado := {}

   aAchados := {}

   If Empty(Alltrim(cCaminho))
      MsgAlert("Atenção! Arquivo de comissões a ser importado não selecionado. Verifique!")
      Return(.T.)
   Endif

   If Substr(cComboBx100,01,01) == "0"
      MsgAlert("Atenção! Layout a ser importado não selecionado. Verifique!")
      Return(.T.)
   Endif

   // #######################################################
   // Lê arquivo selecionado para carregar o array aBrowse ##
   // #######################################################
   nHandle := FOPEN(Alltrim(cCaminho), 0)

   If FERROR() != 0
      MsgAlert("Erro ao abrir o arquivo de Inventário.")
      Return .T.
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

   // ##################################################               
   // Trata os dados e guarda-os no array aResultado ##
   // #################################################
   cConteudo := ""

   For nContar = 1 to Len(xBuffer)

       If Substr(xBuffer, nContar, 1) <> chr(13)
          cConteudo := cConteudo + Substr(xBuffer, nContar, 1)
       Else
          cConteudo := cConteudo + "|"
          aAdd( aResultado, StrTRan(cConteudo, chr(9), "|") )
          cConteudo := ""
       Endif   
               
   Next nContar                   

   // #########################################
   // Localiza os documentos no array aLista ##
   // #########################################
   For nContar = 1 to Len(aResultado)
   
       // #############
       // SCANSOURCE ##
       // #############
       If Substr(cComboBx100,01,01) == "1"
                                               
          If Substr(aResultado[nContar],01,08) == "IMPRIMIR"
             Loop
          Endif
               
          If Substr(aResultado[nContar],01,06) == "(Excel"
             Loop
          Endif
                                                                            
          If Substr(aResultado[nContar],01,10) == "Lan‡amento"
             Loop
          Endif

          If Substr(aResultado[nContar],01,10) == "          "
             Loop
          Endif

          kDocumento := U_P_CORTA(U_P_CORTA(aResultado[nContar], "|",6) + "/", "/", 2)
          kParcela   := U_P_CORTA(U_P_CORTA(aResultado[nContar], "|",6) + "/", "/", 3)
          kComissao  := val(StrTran(StrTran(U_P_CORTA(aResultado[nContar], "|",12), ".", ""),",","."))

          If Empty(Alltrim(kDocumento))
             Loop
          Endif   

          Do Case
             Case kParcela == "A"
                  kParcela := "01"
             Case kParcela == "B"
                  kParcela := "02"
             Case kParcela == "C"
                  kParcela := "03"
             Case kParcela == "D"
                  kParcela := "04"
             Case kParcela == "E"
                  kParcela := "05"
             Case kParcela == "F"
                  kParcela := "06"
             Case kParcela == "G"
                  kParcela := "07"
             Case kParcela == "H"
                  kParcela := "08"
             Case kParcela == "I"
                  kParcela := "09"
             Case kParcela == "J"
                  kParcela := "10"
             Case kParcela == "K"
                  kParcela := "11"
             Case kParcela == "L"
                  kParcela := "12"
          EndCase
                       
          lAchouReg := .F.

          For nProcura = 1 to Len(aLista)
                   
              If Alltrim(aLista[nProcura,03]) == Alltrim(kDocumento) .And. ;
                 Alltrim(aLista[nProcura,04]) == Alltrim(kParcela)
                 aLista[nProcura,01] := .T.
                 aLista[nProcura,08] := Transform(kComissao, "@E 9999999.99")
                 aLista[nProcura,12] := Transform(Round((kComissao * 100) / VAL(Strtran(aLista[nProcura,10], ",", ".")),2), "@E 9999999.99")
                 aLista[nProcura,09] := Transform (VAL(Strtran(aLista[nProcura,06], ",", ".")) - VAL(Strtran(aLista[nProcura,07], ",", ".")) - VAL(Strtran(aLista[nProcura,08], ",", ".")), "@E 9999999.99")
                 PctComissao         := Round((kComissao * 100) / VAL(Strtran(aLista[nProcura,10], ",", ".")),2)
                 
                 Do Case  
                    Case PctComissao >= 9
                         aLista[nProcura,11] := "2"
                    Case PctComissao >= 6 .And. PctComissao <= 8.9
                         aLista[nProcura,11] := "1"
                    Case PctComissao < 6
                         aLista[nProcura,11] := "8"
                 EndCase        

                 lAchouReg := .T.

                 Exit

              Endif
               
          Next nProcura

          aAdd( aAchados, { IIF(lAchouReg == .T., "S", "N"), "Documento: " + kDocumento + "  Parcela: " + kParcela + "  Valor Comissão: " + Transform(kComissao, "@E 9999999.99") })
       
       Endif

       // ##########
       // OFFICER ##
       // ##########
       If Substr(cComboBx100,01,01) == "2"
                                               
          If U_P_CORTA(aResultado[nContar],"|",1) == "NF"
             Loop
          Endif
               
          If Substr(aResultado[nContar],14,01) <> "/"
             Loop
          Endif

          kDocumento := Alltrim(str(int(val(Substr(U_P_CORTA(aResultado[nContar],"|", 1),01,10))))) + Substr(u_p_corta(aResultado[nContar],"|",1),11,02)
          kParcela   := strzero(int(val(Substr(U_P_CORTA(aResultado[nContar],"|", 1),17,03))),2)
          kComissao  := Val(Strtran(Strtran(strtran(U_P_CORTA(aResultado[nContar],"|", 5), "R$", ""), ".", ""), ",", "."))

          If Empty(Alltrim(kDocumento))
             Loop
          Endif   

          lAchouReg := .F.

          For nProcura = 1 to Len(aLista)
                   
              If Alltrim(aLista[nProcura,03]) == Alltrim(kDocumento) .And. ;
                 Alltrim(aLista[nProcura,04]) == Alltrim(kParcela)
                 aLista[nProcura,01] := .T.
                 aLista[nProcura,08] := Transform(kComissao, "@E 9999999.99")
                 aLista[nProcura,12] := Transform(Round((kComissao * 100) / VAL(Strtran(aLista[nProcura,10], ",", ".")),2), "@E 9999999.99")
                 aLista[nProcura,09] := Transform (VAL(Strtran(aLista[nProcura,06], ",", ".")) - VAL(Strtran(aLista[nProcura,07], ",", ".")) - VAL(Strtran(aLista[nProcura,08], ",", ".")), "@E 9999999.99")
                 PctComissao         := Round((kComissao * 100) / VAL(Strtran(aLista[nProcura,10], ",", ".")),2)
                 
                 Do Case  
                    Case PctComissao >= 9
                         aLista[nProcura,11] := "2"
                    Case PctComissao >= 6 .And. PctComissao <= 8.9
                         aLista[nProcura,11] := "1"
                    Case PctComissao < 6
                         aLista[nProcura,11] := "8"
                 EndCase        

                 lAchouReg := .T.

                 Exit

              Endif
               
          Next nProcura

          aAdd( aAchados, { IIF(lAchouReg == .T., "S", "N"), "Documento: " + kDocumento + "  Parcela: " + kParcela + "  Valor Comissão: " + Transform(kComissao, "@E 9999999.99") })
       
       Endif

       // ########
       // PRIME ##
       // ########
       If Substr(cComboBx100,01,01) == "3"
                                               
          If Upper(Alltrim(Substr(aResultado[nContar],02,07))) == "CLIENTE"
             Loop
          Endif
               
          If Empty(Alltrim(U_P_CORTA(aResultado[nContar], "|",2)))
             Loop
          Endif

          kDocumento := Alltrim(U_P_CORTA(aResultado[nContar], "|",4))
          kParcela   := STRZERO(INT(VAL(U_P_CORTA(aResultado[nContar], "|",7))),2)
          kComissao  := val(StrTran(StrTran(U_P_CORTA(aResultado[nContar], "|",9), ".", ""),",","."))

          If Empty(Alltrim(kDocumento))
             Loop
          Endif   

          lAchouReg := .F.

          For nProcura = 1 to Len(aLista)
                   
              If Alltrim(aLista[nProcura,03]) == Alltrim(kDocumento) .And. ;
                 Alltrim(aLista[nProcura,04]) == Alltrim(kParcela)
                 aLista[nProcura,01] := .T.
                 aLista[nProcura,08] := Transform(kComissao, "@E 9999999.99")
                 aLista[nProcura,12] := Transform(Round((kComissao * 100) / VAL(Strtran(aLista[nProcura,10], ",", ".")),2), "@E 9999999.99")
                 aLista[nProcura,09] := Transform (VAL(Strtran(aLista[nProcura,06], ",", ".")) - VAL(Strtran(aLista[nProcura,07], ",", ".")) - VAL(Strtran(aLista[nProcura,08], ",", ".")), "@E 9999999.99")
                 PctComissao         := Round((kComissao * 100) / VAL(Strtran(aLista[nProcura,10], ",", ".")),2)
                 
                 Do Case  
                    Case PctComissao >= 9
                         aLista[nProcura,11] := "2"
                    Case PctComissao >= 6 .And. PctComissao <= 8.9
                         aLista[nProcura,11] := "1"
                    Case PctComissao < 6
                         aLista[nProcura,11] := "8"
                 EndCase        

                 lAchouReg := .T.

                 Exit

              Endif
               
          Next nProcura

          aAdd( aAchados, { IIF(lAchouReg == .T., "S", "N"), "Documento: " + kDocumento + "  Parcela: " + kParcela + "  Valor Comissão: " + Transform(kComissao, "@E 9999999.99") })
       
       Endif

   Next nContar    

   oDlgI:End() 

   TotaisTela()

   ResumoImpo()

Return(.T.)        

// ##################################################
// Função que abre diálogo do resumo da importação ##
// ##################################################
Static Function ResumoImpo()

   Local cMemo1	   := ""
   Local cMemo2	   := ""
   Local cAchouSIM := ""
   Local cAchouNAO := ""
   
   Local oMemo1
   Local oMemo2
   Local oMemo3
   Local oMemo4

   DEFINE FONT oFont Name "Courier New" Size 0, 14

   Private oDlgRES

   For nContar = 1 to Len(aAchados)
       If aAchados[nContar,01] == "S"
          cAchouSIM := cAchouSIM + aAchados[nContar,02] + chr(13) + chr(10) 
       Else
          cAchouNAO := cAchouNAO + aAchados[nContar,02] + chr(13) + chr(10)           
       Endif
   Next nContar       

   DEFINE MSDIALOG oDlgRES TITLE "Resumo da Importação" FROM C(178),C(181) TO C(643),C(959) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(117),C(022) PIXEL NOBORDER OF oDlgRES

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(382),C(001) PIXEL OF oDlgRES
   @ C(044),C(002) GET oMemo2 Var cMemo2 MEMO Size C(382),C(001) PIXEL OF oDlgRES
   
   @ C(032),C(159) Say "RESUMO DA IMPORTAÇÃO"      Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlgRES
   @ C(048),C(005) Say "COMISSÕES ENCONTRADAS"     Size C(075),C(008) COLOR CLR_BLACK PIXEL OF oDlgRES
   @ C(048),C(197) Say "REGISTROS NÃO ENCONTRADOS" Size C(089),C(008) COLOR CLR_BLACK PIXEL OF oDlgRES

   @ C(058),C(005) GET oMemo3 Var cAchouSIM MEMO Size C(188),C(154) FONT oFont PIXEL OF oDlgRES
   @ C(058),C(197) GET oMemo4 Var cAchouNAO MEMO Size C(188),C(154) FONT oFont PIXEL OF oDlgRES

   @ C(215),C(005) Button "Gerar Pedido de Venda" Size C(065),C(012) PIXEL OF oDlgRES ACTION( GeraPVendaDist() )
   @ C(216),C(348) Button "Voltar"                Size C(037),C(012) PIXEL OF oDlgRES ACTION( odlgRes:End() )

   ACTIVATE MSDIALOG oDlgRES CENTERED 

Return(.T.)

// #####################################
// Função que gera o resultado em CSV ##
// #####################################
Static Function kkGeraPCSV()

   Local aCabExcel   :={}
   Local aItensExcel :={}

   AADD(aCabExcel, {"NF Dist."                    , "C", 06,00 }) // 03                                          
   AADD(aCabExcel, {"PRC"                         , "C", 02,00 }) // 04
   AADD(aCabExcel, {"Dta Prev. Rec."              , "C", 10,00 }) // 05
   AADD(aCabExcel, {"Vlr Comissao"                , "C", 12,00 }) // 06
   AADD(aCabExcel, {"Vlr Faturado"                , "C", 12,00 }) // 07
   AADD(aCabExcel, {"Vlr A Faturar"               , "C", 12,00 }) // 08
   AADD(aCabExcel, {"Sld A Faturar"               , "C", 12,00 }) // 09
   AADD(aCabExcel, {"Valor PV."                   , "C", 12,00 }) // 10                                         
   AADD(aCabExcel, {"% Comissao"                  , "C", 10,00 }) // 12
   AADD(aCabExcel, {"Dta Fat. P1"                 , "C", 10,00 }) // 13
   AADD(aCabExcel, {"Dta Cob.Com."                , "C", 10,00 }) // 14
   AADD(aCabExcel, {"Distrib."                    , "C", 06,00 }) // 16
   AADD(aCabExcel, {"Loja"                        , "C", 02,00 }) // 17
   AADD(aCabExcel, {"Descricao dos Distribuidores", "C", 40,00 }) // 18
   AADD(aCabExcel, {"Nº PVenda"                   , "C", 06,00 }) // 19
   AADD(aCabExcel, {"Emissao"                     , "C", 10,00 }) // 20
   AADD(aCabExcel, {"Ped.Externo"                 , "C", 20,00 }) // 21
   AADD(aCabExcel, {"Dta Fech."                   , "C", 10,00 }) // 22
   AADD(aCabExcel, {"Nº NFiscal"                  , "C", 09,00 }) // 23
   AADD(aCabExcel, {"Serie"                       , "C", 03,00 }) // 24
   AADD(aCabExcel, {"Cliente"                     , "C", 06,00 }) // 25
   AADD(aCabExcel, {"Loja"                        , "C", 02,00 }) // 26
   AADD(aCabExcel, {"Descricao dos Clientes"      , "C", 40,00 }) // 27
   AADD(aCabExcel, {"Emp.Ori"                     , "C", 30,00 }) // 28
   AADD(aCabExcel, {"Fil.Ori"                     , "C", 30,00 }) // 29
   AADD(aCabExcel, {"LCT"                         , "C", 10,00 }) // 30                                          
   AADD(aCabExcel, {" "                           , "C", 01,00 }) // 31

   MsgRun("Favor Aguardar.....", "Selecionando os Registros", {|| GProcItens(aCabExcel, @aItensExcel)})
   MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel", {||DlgToExcel({{"GETDADOS","COMISSÕES DISTRIBUIDORES REF AO PERÍODO DE " + Dtoc(cInicial) + " A " + Dtoc(cFinal), aCabExcel,aItensExcel}})})
                                                         
Return(.T.)

// ##############################################
// Função que gera o arquivo CSV para gravação ##
// ##############################################
Static Function GProcItens(aHeader, aCols)

   Local nContar
   
   For nContar = 1 to Len(aLista)

       aAdd( aCols, { aLista[nContar,03],;
                      aLista[nContar,04],;
                      aLista[nContar,05],;
                      aLista[nContar,06],;
                      aLista[nContar,07],;
                      aLista[nContar,08],;
                      aLista[nContar,09],;
                      aLista[nContar,10],;
                      aLista[nContar,12],;
                      aLista[nContar,13],;
                      aLista[nContar,14],;
                      aLista[nContar,16],;
                      aLista[nContar,17],;
                      aLista[nContar,18],;
                      aLista[nContar,19],;
                      aLista[nContar,20],;
                      aLista[nContar,21],;
                      aLista[nContar,22],;
                      aLista[nContar,23],;
                      aLista[nContar,24],;
                      aLista[nContar,25],;
                      aLista[nContar,26],;
                      aLista[nContar,27],;
                      aLista[nContar,28],;
                      aLista[nContar,29],;
                      aLista[nContar,30],;
                      ""                   })
   Next nContar

Return(.T.)

// #########################################################
// Função que gera o resultado em CSV - Baixa de parcelas ##
// #########################################################
Static Function xkGeraPCSV()

   Local aCabExcel   :={}
   Local aItensExcel :={}

   AADD(aCabExcel, {"NF Dist."                    , "C", 06,00 }) // 03                                          
   AADD(aCabExcel, {"PRC"                         , "C", 02,00 }) // 04
   AADD(aCabExcel, {"Dta Prev. Rec."              , "C", 10,00 }) // 05
   AADD(aCabExcel, {"Vlr Comissao"                , "C", 12,00 }) // 06
   AADD(aCabExcel, {"Vlr Faturado"                , "C", 12,00 }) // 07
   AADD(aCabExcel, {"Vlr A Faturar"               , "C", 12,00 }) // 08
   AADD(aCabExcel, {"Sld A Faturar"               , "C", 12,00 }) // 09
   AADD(aCabExcel, {"Valor PV."                   , "C", 12,00 }) // 10                                         
   AADD(aCabExcel, {"% Comissao"                  , "C", 10,00 }) // 12
   AADD(aCabExcel, {"Dta Fat. P1"                 , "C", 10,00 }) // 13
   AADD(aCabExcel, {"Dta Cob.Com."                , "C", 10,00 }) // 14
   AADD(aCabExcel, {"Distrib."                    , "C", 06,00 }) // 16
   AADD(aCabExcel, {"Loja"                        , "C", 02,00 }) // 17
   AADD(aCabExcel, {"Descricao dos Distribuidores", "C", 40,00 }) // 18
   AADD(aCabExcel, {"Nº PVenda"                   , "C", 06,00 }) // 19
   AADD(aCabExcel, {"Emissao"                     , "C", 10,00 }) // 20
   AADD(aCabExcel, {"Ped.Externo"                 , "C", 20,00 }) // 21
   AADD(aCabExcel, {"Dta Fech."                   , "C", 10,00 }) // 22
   AADD(aCabExcel, {"Nº NFiscal"                  , "C", 09,00 }) // 23
   AADD(aCabExcel, {"Serie"                       , "C", 03,00 }) // 24
   AADD(aCabExcel, {"Cliente"                     , "C", 06,00 }) // 25
   AADD(aCabExcel, {"Loja"                        , "C", 02,00 }) // 26
   AADD(aCabExcel, {"Descricao dos Clientes"      , "C", 40,00 }) // 27
   AADD(aCabExcel, {"Emp.Ori"                     , "C", 30,00 }) // 28
   AADD(aCabExcel, {"Fil.Ori"                     , "C", 30,00 }) // 29
   AADD(aCabExcel, {"LCT"                         , "C", 10,00 }) // 30                                          
   AADD(aCabExcel, {" "                           , "C", 01,00 }) // 31

   MsgRun("Favor Aguardar.....", "Selecionando os Registros", {|| xGProcItens(aCabExcel, @aItensExcel)})
   MsgRun("Favor Aguardar.....", "Exportando os Registros para o Excel", {||DlgToExcel({{"GETDADOS","COMISSÕES DISTRIBUIDORES REF AO PERÍODO DE " + Dtoc(cInicial) + " A " + Dtoc(cFinal), aCabExcel,aItensExcel}})})
                                                         
Return(.T.)

// ##############################################
// Função que gera o arquivo CSV para gravação ##
// ##############################################
Static Function xGProcItens(aHeader, aCols)

   Local nContar
   
   For nContar = 1 to Len(aResumo)

       aAdd( aCols, { aResumo[nContar,03],;
                      aResumo[nContar,04],;
                      aResumo[nContar,05],;
                      aResumo[nContar,06],;
                      aResumo[nContar,07],;
                      aResumo[nContar,08],;
                      aResumo[nContar,09],;
                      aResumo[nContar,10],;
                      aResumo[nContar,12],;
                      aResumo[nContar,13],;
                      aResumo[nContar,14],;
                      aResumo[nContar,16],;
                      aResumo[nContar,17],;
                      aResumo[nContar,18],;
                      aResumo[nContar,19],;
                      aResumo[nContar,20],;
                      aResumo[nContar,21],;
                      aResumo[nContar,22],;
                      aResumo[nContar,23],;
                      aResumo[nContar,24],;
                      aResumo[nContar,25],;
                      aResumo[nContar,26],;
                      aResumo[nContar,27],;
                      aResumo[nContar,28],;
                      aResumo[nContar,29],;
                      aResumo[nContar,30],;
                      ""                   })
   Next nContar

Return(.T.)

// ####################################################################
// Função que permite a alteração do distribuidor no pedido de venda ##
// ####################################################################
Static Function AltCodDistri(kMarcado)

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private xxPedido := aLista[oLista:nAt,19]
   Private xxDist01 := aLista[oLista:nAt,16]
   Private xxLoja01 := aLista[oLista:nAt,17]
   Private xxNome01 := aLista[oLista:nAt,18]
   Private xxDist02	:= aLista[oLista:nAt,16]
   Private xxLoja02 := aLista[oLista:nAt,17]
   Private xxNome02 := aLista[oLista:nAt,18]

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7

   Private oDlgDist

   If kMarcado == .F.
      MsgAlert("Selecione um registro para visualização")
      Return(.T.)                                        
   Endif   

   DEFINE MSDIALOG oDlgDist TITLE "Alteração de Distribuidor Pedido de Venda Externo" FROM C(178),C(181) TO C(419),C(604) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(118),C(022) PIXEL NOBORDER OF oDlgDist

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(205),C(001) PIXEL OF oDlgDist
   @ C(099),C(002) GET oMemo2 Var cMemo2 MEMO Size C(205),C(001) PIXEL OF oDlgDist
   
   @ C(032),C(005) Say "Nº Pedido "                  Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgDist
   @ C(054),C(005) Say "Distribuidor Atual"          Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgDist
   @ C(076),C(005) Say "Alterar para o Distribuidor" Size C(062),C(008) COLOR CLR_BLACK PIXEL OF oDlgDist

   @ C(041),C(005) MsGet oGet1 Var xxPedido Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDist When lChumba 
   @ C(063),C(005) MsGet oGet2 Var xxDist01 Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDist When lChumba 
   @ C(063),C(038) MsGet oGet3 Var xxLoja01 Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDist When lChumba 
   @ C(063),C(059) MsGet oGet4 Var xxNome01 Size C(148),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDist When lChumba 
   @ C(085),C(005) MsGet oGet5 Var xxDist02 Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDist F3("SA2") 
   @ C(085),C(038) MsGet oGet6 Var xxLoja02 Size C(017),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDist VALID( zzTrazDist() )
   @ C(085),C(059) MsGet oGet7 Var xxNome02 Size C(148),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDist

   @ C(104),C(067) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgDist ACTION( GravaDistPV() )
   @ C(104),C(106) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgDist ACTION( oDlgDist:End() )

   ACTIVATE MSDIALOG oDlgDist CENTERED 

Return(.T.)

// #####################################
// Função que pesquisa o distribuidor ##
// #####################################
Static Function zzTrazDist()

   If Empty(Alltrim(xxDist02)) 
      xxDist02 := Space(06)
      xxLoja02 := Space(03)
      xxNome02 := Space(60)
      oGet5:Refresh()
      oGet6:Refresh()
      oGet7:Refresh()      
      Return(.T.)
   Endif
   
   If Empty(Alltrim(xxLoja02)) 
      xxDist02 := Space(06)
      xxLoja02 := Space(03)
      xxNome02 := Space(60)
      oGet5:Refresh()
      oGet6:Refresh()
      oGet7:Refresh()      
      Return(.T.)
   Endif

   xxNome02 := POSICIONE("SA2",1,XFILIAL("SA2") + xxDist02 + xxLoja02, "A2_NOME")

   If Empty(Alltrim(xxNome02)) 
      MsgAlert("Distribuidor informado não localizado.")
      xxDist02 := Space(06)
      xxLoja02 := Space(03)
      xxNome02 := Space(60)
      oGet5:Refresh()
      oGet6:Refresh()
      oGet7:Refresh()      
      Return(.T.)
   Endif

Return(.T.)

// ##########################################################
// Função que grava o novo distribuidor no pedido de venda ##
// ##########################################################
Static Function GravaDistPV()

   Local cSql := ""

   If Empty(Alltrim(xxDist02)) 
      MsgAlert("Distribuidor não informado. Verifique!")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(xxLoja02)) 
      MsgAlert("Distribuidor não informado. Verifique!")
      Return(.T.)
   Endif

   cSql := ""
   
   Do Case
      Case Substr(aLista[oLista:nAt,28],01,02) == "01"
           cSql := "UPDATE SC5010"
      Case Substr(aLista[oLista:nAt,28],01,02) == "02"
           cSql := "UPDATE SC5020"
      Case Substr(aLista[oLista:nAt,28],01,02) == "03"
           cSql := "UPDATE SC5030"                  
      Case Substr(aLista[oLista:nAt,28],01,02) == "04"
           cSql := "UPDATE SC5040"
   EndCase
  
   cSql += "  SET "
   cSql += "  C5_FORNEXT = '" + Alltrim(xxDist02) + "',"
   cSql += "  C5_LOJAEXT = '" + Alltrim(xxLoja02) + "' "
   cSql += "  WHERE C5_FILIAL  = '" + Substr(aLista[oLista:nAt,29],01,02) + "'"
   cSql += "    AND C5_NUM     = '" + Alltrim(xxPedido)                   + "'"  
   cSql += "    AND D_E_L_E_T_ = ''"

   lResult := TCSQLEXEC(cSql)
 
   If lResult < 0
      oDlgDist:End() 
      Return MsgStop("Erro ao gravar o novo distribuidor no pedido de venda: " + TCSQLError())
   EndIf 

   oDlgDist:End() 
   
   PsqExterno()
   
Return(.T.)

// #################################################
// Função que mostra a estatísca por distribuidor ##
// #################################################
Static Function VeEstatistica()

   Local nContar := 0
   Local aDados  := {}
   Local lExiste := .F.
   Local cMemo1	 := ""
   Local cDados	 := ""
   Local oMemo1
   Local oMemo3
  
   DEFINE FONT oFont Name "Courier New" Size 0, 14
   
   Private oDlgEst   

   For nContar = 1 to Len(aLista)

       lExiste := .F.

       For x = 1 to Len(aDados)
           If aDados[x,01] == aLista[nContar,16] .And. aDados[x,02] == aLista[nContar,17]
              aDados[x,04] := aDados[x,04] + Val(StrTran(aLista[nContar,06], ",", "."))
              aDados[x,05] := aDados[x,05] + Val(StrTran(aLista[nContar,10], ",", "."))              
              lExiste := .T.
              Exit
           Endif
       Next x
       
       If lExiste == .F.
          aAdd( aDados, { aLista[nContar,16],;
                          aLista[nContar,17],;
                          aLista[nContar,18],;
                          Val(StrTran(aLista[nContar,06], ",", ".")),;
                          Val(StrTran(aLista[nContar,10], ",", "."))})
       Endif         
       
   Next nContar   
   
   For nContar = 1 to Len(aDados)
       If Empty(Alltrim(aDados[nContar,01]))
       Else
          cDados := cDados + aDados[nContar,03] + "   Comissão: " + Transform(aDados[nContar,04], "@E 999,999,999.99") + "  Vlr Pedido: " + Transform(aDados[nContar,05], "@E 999,999,999.99") + chr(13) + chr(10)          
       Endif   
   Next nContar   

   DEFINE MSDIALOG oDlgEst TITLE "Estatística de Valores por Distribuidor" FROM C(178),C(181) TO C(578),C(957) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(118),C(022) PIXEL NOBORDER OF oDlgEst
   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO  Size C(381),C(001) PIXEL OF oDlgEst
   @ C(032),C(005) GET oMemo3 Var cDados MEMO  Size C(379),C(148) FONT ofont PIXEL OF oDlgEst
   @ C(184),C(176) Button "Voltar"             Size C(037),C(012) PIXEL OF oDlgEst ACTION( oDlgEst:End() )
 
   ACTIVATE MSDIALOG oDlgEst CENTERED 

Return(.T.)

// ########################################
// Função que mostra o Resumo das Baixas ##
// ########################################
Static Function MostraBaixas()

   Local lChumba := .F.
   Local nContar := 0

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Local YY_Comissao := 0
   Local YY_Faturado := 0
   Local YY_Afaturar := 0
   Local YY_Saldo    := 0
   Local YY_Pedido   := 0

   Private aResumo   := {}
   Private oResumo

   Private oDlgMB
   
   aResumo := {}
   
   For nContar = 1 to Len(aLista)
   
       If aLista[nContar,01] == .F.
          Loop
       Endif   

       // ##########################
       // Carrega o Array aResumo ##
       // ##########################
       aAdd( aResumo,{ aLista[nContar,01],;
                       aLista[nContar,02],;
                       aLista[nContar,03],;
                       aLista[nContar,04],;
                       aLista[nContar,05],;
                       aLista[nContar,06],;
                       aLista[nContar,07],;
                       aLista[nContar,08],;                                                                                                                   
                       aLista[nContar,09],;
                       aLista[nContar,10],;
                       aLista[nContar,11],;                       
                       aLista[nContar,12],;
                       aLista[nContar,13],;
                       aLista[nContar,14],;
                       aLista[nContar,15],;
                       aLista[nContar,16],;
                       aLista[nContar,17],;
                       aLista[nContar,18],;                                                                                                                   
                       aLista[nContar,19],;
                       aLista[nContar,20],;
                       aLista[nContar,21],;                       
                       aLista[nContar,22],;
                       aLista[nContar,23],;
                       aLista[nContar,24],;
                       aLista[nContar,25],;
                       aLista[nContar,26],;
                       aLista[nContar,27],;
                       aLista[nContar,28],;                                                                                                                   
                       aLista[nContar,29],;
                       aLista[nContar,30]})
          
       YY_Comissao := YY_Comissao + VAL(aLista[nContar,06])
       YY_Faturado := YY_Faturado + VAL(aLista[nContar,07])
       YY_Afaturar := YY_Afatura  + VAL(aLista[nContar,08])
       YY_Saldo    := YY_Saldo    + VAL(aLista[nContar,09])
       YY_Pedido   := YY_Pedido   + VAL(aLista[nContar,10])
          
   Next nContar

   If Len(aResumo) == 0
      //              01   02   03  04  05  06  07  08  09  10  11   12  13  14  15   16  17  18  19  20  21  22  23  24  25  26  27  28  29  30
      aAdd( aResumo,{ .F., "0", "", "", "", "", "", "", "", "", "0", "", "", "", "0", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "" })
   Endif

   DEFINE MSDIALOG oDlgMB TITLE "Inclusão Automática de Pedidos de Venda para Cobrança de Comissões de Distribuidores" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(122),C(026) PIXEL NOBORDER OF oDlgMB
   @ C(199),C(002) Jpeg FILE "br_vermelho.png" Size C(009),C(009) PIXEL NOBORDER OF oDlgMB
   @ C(199),C(041) Jpeg FILE "br_amarelo.png"  Size C(009),C(009) PIXEL NOBORDER OF oDlgMB
   @ C(199),C(104) Jpeg FILE "br_verde.png"    Size C(009),C(009) PIXEL NOBORDER OF oDlgMB

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlgMB
   @ C(207),C(003) GET oMemo2 Var cMemo2 MEMO Size C(495),C(001) PIXEL OF oDlgMB

   @ C(036),C(005) Say "Empresa"                     Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgMB
   @ C(036),C(062) Say "Filiais"                     Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgMB
   @ C(036),C(120) Say "Dta Inicial"                 Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgMB
   @ C(036),C(159) Say "Dta Final"                   Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgMB
   @ C(036),C(198) Say "Tipo Data"                   Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgMB
   @ C(036),C(234) Say "Status"                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgMB
   @ C(036),C(274) Say "Distribuidor"                Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgMB
   @ C(057),C(005) Say "Relação de Pedidos de Venda" Size C(074),C(008) COLOR CLR_BLACK PIXEL OF oDlgMB
   @ C(185),C(183) Say "Total Ped.Vendas"            Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlgMB
   @ C(185),C(247) Say "Total Comissões"             Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlgMB
   @ C(185),C(311) Say "Total Faturado"              Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlgMB
   @ C(185),C(375) Say "Total A Faturar"             Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgMB 
   @ C(185),C(439) Say "Saldo A Faturar"             Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgMB
   @ C(199),C(015) Say "A Faturar"                   Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgMB
   @ C(199),C(053) Say "Faturamento Parcial"         Size C(048),C(008) COLOR CLR_BLACK PIXEL OF oDlgMB
   @ C(199),C(116) Say "Faturamento Total"           Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlgMB

   @ C(046),C(005) ComboBox cComboBx1  Items aEmpresa     Size C(054),C(010)                              PIXEL OF oDlgMB When lChumba
   @ C(046),C(062) ComboBox cComboBx2  Items aFilial      Size C(054),C(010)                              PIXEL OF oDlgMB When lChumba
   @ C(046),C(120) MsGet    oGet1      Var   cInicial     Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMB When lChumba
   @ C(046),C(159) MsGet    oGet2      Var   cFinal       Size C(035),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMB When lChumba
   @ C(046),C(197) ComboBox cComboBx4  Items aTipoData    Size C(037),C(010)                              PIXEL OF oDlgMB When lChumba
   @ C(046),C(234) ComboBox cComboBx3  Items aStatus      Size C(037),C(010)                              PIXEL OF oDlgMB When lChumba
   @ C(046),C(274) MsGet    oGet3      Var   cFornece     Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMB When lChumba
   @ C(046),C(302) MsGet    oGet4      Var   cLoja        Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMB When lChumba
   @ C(046),C(323) MsGet    oGet5      Var   cNomeFor     Size C(135),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgMB When lChumba
   @ C(036),C(323) CheckBox oCheckBox1 Var   lNinformado  Prompt "PV com Distribuidor não informado" Size C(091),C(008) PIXEL OF oDlgMB
   @ C(195),C(183) MsGet    oGet11     Var   yy_Pedido    Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999999.99" PIXEL OF oDlgMB When lChumba
   @ C(195),C(247) MsGet    oGet7      Var   yy_Comissao  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999999.99" PIXEL OF oDlgMB When lChumba
   @ C(195),C(311) MsGet    oGet8      Var   yy_Faturado  Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999999.99" PIXEL OF oDlgMB When lChumba
   @ C(195),C(375) MsGet    oGet9      Var   yy_Afatura   Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999999.99" PIXEL OF oDlgMB When lChumba
   @ C(195),C(439) MsGet    oGet10     Var   yy_Saldo     Size C(060),C(009) COLOR CLR_BLACK Picture "@E 9999999999.99" PIXEL OF oDlgMB When lChumba

   @ C(210),C(003) Button "Zoom"          Size C(037),C(012) PIXEL OF oDlgMB ACTION( ZoomDeRegistro() )
   @ C(210),C(042) Button "Estatíscas"    Size C(037),C(012) PIXEL OF oDlgMB ACTION( VeEstatistica() )
   @ C(210),C(081) Button "Excel"         Size C(034),C(012) PIXEL OF oDlgMB ACTION( xkGeraPCSV() )
   @ C(210),C(461) Button "Voltar"        Size C(037),C(012) PIXEL OF oDlgMB ACTION( oDlgMB:End() )

   @ 083,005 LISTBOX oResumo FIELDS HEADER "M"                           ,; // 01
                                           "LG"                          ,; // 02
                                           "NF Dist."                    ,; // 03                                          
                                           "PRC"                         ,; // 04
                                           "Dta Prev. Rec."              ,; // 05
                                           "Vlr Comissão"                ,; // 06
                                           "Vlr Faturado"                ,; // 07
                                           "Vlr A Faturar"               ,; // 08
                                           "Sld A Faturar"               ,; // 09
                                           "Valor PV."                   ,; // 10                                         
                                           "LG %"                        ,; // 11
                                           "% Comissão"                  ,; // 12
                                           "Dta Fat. P1"                 ,; // 13
                                           "Dta Cob.Com."                ,; // 14
                                           "TB"                          ,; // 15
                                           "Distrib."                    ,; // 16
                                           "Loja"                        ,; // 17
                                           "Descrição dos Distribuidores",; // 18
                                           "Nº PVenda"                   ,; // 19
                                           "Emissão"                     ,; // 20
                                           "Ped.Externo"                 ,; // 21
                                           "Dta Fech."                   ,; // 22
                                           "Nº NFiscal"                  ,; // 23
                                           "Série"                       ,; // 24
                                           "Cliente"                     ,; // 25
                                           "Loja"                        ,; // 26
                                           "Descrição dos Clientes"      ,; // 27
                                           "Emp.Ori"                     ,; // 28
                                           "Fil.Ori"                     ,; // 29
                                           "LCT"                          ; // 30                                          
                                           PIXEL SIZE 633,150 OF oDlgMB FONT oFont ON dblClick(aResumo[oResumo:nAt,1] := !aResumo[oResumo:nAt,1],oResumo:Refresh())     

   oResumo:SetArray( aResumo )

   oResumo:bLine := {||{ Iif(aResumo[oResumo:nAt,01],oOk,oNo)          ,;
                          If(aResumo[oResumo:nAt,02] == "0", oBranco   ,;
                          If(aResumo[oResumo:nAt,02] == "2", oVerde    ,;
                          If(aResumo[oResumo:nAt,02] == "3", oCancel   ,;                         
                          If(aResumo[oResumo:nAt,02] == "1", oAmarelo  ,;                         
                          If(aResumo[oResumo:nAt,02] == "5", oAzul     ,;                         
                          If(aResumo[oResumo:nAt,02] == "6", oLaranja  ,;                         
                          If(aResumo[oResumo:nAt,02] == "7", oPreto    ,;                         
                          If(aResumo[oResumo:nAt,02] == "8", oVermelho ,;
                          If(aResumo[oResumo:nAt,02] == "9", oPink     ,;
                          If(aResumo[oResumo:nAt,02] == "4", oEncerra, "")))))))))),;
                             aResumo[oResumo:nAt,03]         ,;
                             aResumo[oResumo:nAt,04]         ,;
                             aResumo[oResumo:nAt,05]         ,;
                             aResumo[oResumo:nAt,06]         ,;
                             aResumo[oResumo:nAt,07]         ,;
                             aResumo[oResumo:nAt,08]         ,;
                             aResumo[oResumo:nAt,09]         ,;
                             aResumo[oResumo:nAt,10]         ,;
                          If(aResumo[oResumo:nAt,11] == "0", oBranco   ,;
                          If(aResumo[oResumo:nAt,11] == "2", oVerde    ,;
                          If(aResumo[oResumo:nAt,11] == "3", oCancel   ,;                         
                          If(aResumo[oResumo:nAt,11] == "1", oAmarelo  ,;                         
                          If(aResumo[oResumo:nAt,11] == "5", oAzul     ,;                         
                          If(aResumo[oResumo:nAt,11] == "6", oLaranja  ,;                         
                          If(aResumo[oResumo:nAt,11] == "7", oPreto    ,;                         
                          If(aResumo[oResumo:nAt,11] == "8", oVermelho ,;
                          If(aResumo[oResumo:nAt,11] == "9", oPink     ,;
                          If(aResumo[oResumo:nAt,11] == "4", oEncerra, "")))))))))),;
                             aResumo[oResumo:nAt,12]         ,;
                             aResumo[oResumo:nAt,13]         ,;
                             aResumo[oResumo:nAt,14]         ,;
                          If(aResumo[oResumo:nAt,15] == "0", oBranco   ,;
                          If(aResumo[oResumo:nAt,15] == "2", oVerde    ,;
                          If(aResumo[oResumo:nAt,15] == "3", oCancel   ,;                         
                          If(aResumo[oResumo:nAt,15] == "1", oAmarelo  ,;                         
                          If(aResumo[oResumo:nAt,15] == "5", oAzul     ,;                         
                          If(aResumo[oResumo:nAt,15] == "6", oLaranja  ,;                         
                          If(aResumo[oResumo:nAt,15] == "7", oPreto    ,;                         
                          If(aResumo[oResumo:nAt,15] == "8", oVermelho ,;
                          If(aResumo[oResumo:nAt,15] == "9", oPink     ,;
                          If(aResumo[oResumo:nAt,15] == "4", oEncerra, "")))))))))),;
                             aResumo[oResumo:nAt,16]         ,;
                             aResumo[oResumo:nAt,17]         ,;
                             aResumo[oResumo:nAt,18]         ,;
                             aResumo[oResumo:nAt,19]         ,;
                             aResumo[oResumo:nAt,20]         ,;
                             aResumo[oResumo:nAt,21]         ,;
                             aResumo[oResumo:nAt,22]         ,;
                             aResumo[oResumo:nAt,23]         ,;
                             aResumo[oResumo:nAt,24]         ,;
                             aResumo[oResumo:nAt,25]         ,;
                             aResumo[oResumo:nAt,26]         ,;
                             aResumo[oResumo:nAt,27]         ,;
                             aResumo[oResumo:nAt,28]         ,;
                             aResumo[oResumo:nAt,29]         ,;
                             aResumo[oResumo:nAt,30]         }}

   ACTIVATE MSDIALOG oDlgMB CENTERED 

Return(.T.)

// ########################################################################################
// Função que mostra o layout do arquivo padrão a ser enviado pelos novos distribuidores ##
// ########################################################################################
Static Function LayoutArq()

   Local lChumba  := .F.
   Local cMemo1   := ""
   Local cColunas := ""

   Local oMemo1
   Local oMemo2

   DEFINE FONT oFont Name "Courier New" Size 0, 14
   
   Private oDlgLayout

   cColunas := ""
   cColunas := cColunas + "Campo: NF DISTRIBUIDOR         TIPO: CARACTER  TAM.: 10   DEC.: 0" + CHR(13) + CHR(10)
   cColunas := cColunas + "Campo: RAZÃO SOCIAL CLIENTE    TIPO: CARACTER  TAM.: 60   DEC.: 0" + CHR(13) + CHR(10)
   cColunas := cColunas + "Campo: DATA EMISSÃO            TIPO: DATE      TAM.: 10   DEC.: 0" + CHR(13) + CHR(10)
   cColunas := cColunas + "Campo: DATA VENCIMENTO         TIPO: DATE      TAM.: 10   DEC.: 0" + CHR(13) + CHR(10)
   cColunas := cColunas + "Campo: PARCELA                 TIPO: CARACTER  TAM.:  2   DEC.: 0" + CHR(13) + CHR(10)
   cColunas := cColunas + "Campo: VALOR COMISSÃO          TIPO: NUMÉRICO  TAM.: 10   DEC.: 2" + CHR(13) + CHR(10)

   DEFINE MSDIALOG oDlgLayout TITLE "Novo Formulário" FROM C(178),C(181) TO C(534),C(575) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlgLayout

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(189),C(001) PIXEL OF oDlgLayout

   @ C(037),C(005) Say "Layout arquivo padrão de comissões."                                             Size C(089),C(008) COLOR CLR_BLACK PIXEL OF oDlgLayout
   @ C(045),C(005) Say "Solicitar a novos distribuidores que nos enviem as comissões no formato abaixo." Size C(190),C(008) COLOR CLR_BLACK PIXEL OF oDlgLayout
   @ C(054),C(005) Say "O arquivo a ser enviado pelo distribuidor poderá ser no formato Excel ou TXT."   Size C(185),C(008) COLOR CLR_BLACK PIXEL OF oDlgLayout

   @ C(064),C(005) GET oMemo2 Var cColunas MEMO Size C(188),C(093) FONT oFont PIXEL OF oDlgLayout When lChumba

   @ C(161),C(080) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgLayout ACTION( oDlgLayout:End() )

   ACTIVATE MSDIALOG oDlgLayout CENTERED 

Return(.T.)