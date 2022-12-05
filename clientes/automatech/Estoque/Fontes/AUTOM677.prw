#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"                      
#INCLUDE "jpeg.ch" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM677.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 17/02/2017                                                          ##
// Objetivo..: Programa que realiza a reabertura de fechamento mensal de estoque   ##
// ##################################################################################

User Function AUTOM677()

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo3	 := ""

   Local oMemo1
   Local oMemo3

   Private aEmpresas := U_AUTOM539(1, "")
   Private aFiliais	 := U_AUTOM539(2, cEmpAnt)
   Private aMeses 	 := {}
   Private aAnos	 := {}
   Private aTipo	 := {"00 - Selecione", "01 - Controle por Número de Série", "02 - Controle por Lote"}
   Private cData	 := Ctod("  /  /    ")
   Private cUsuario	 := Alltrim(cUserName)
   Private cLanca	 := Date()
   Private cHora	 := Time()
   Private cMotivo	 := ""

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4
   Private cComboBx5
   Private oMemo2

   Private oDlg

   // ######################
   // Cria o array aMeses ##
   // ######################
   aAdd( aMeses, "00 - SELECIONE" )
   aAdd( aMeses, "01 - JANEIRO"   )
   aAdd( aMeses, "02 - FEVEREIRO" )
   aAdd( aMeses, "03 - MARÇO"     )
   aAdd( aMeses, "04 - ABRIL"     )
   aAdd( aMeses, "05 - MAIO"      )
   aAdd( aMeses, "06 - JUNHO"     )
   aAdd( aMeses, "07 - JULHO"     )
   aAdd( aMeses, "08 - AGOSTO"    )
   aAdd( aMeses, "09 - SETEMBRO"  )
   aAdd( aMeses, "10 - OUTUBRO"   )
   aAdd( aMeses, "11 - NOVEMBRO"  )
   aAdd( aMeses, "12 - DEZEMBRO"  )

   // ########################
   // Carrega o array aAnos ##
   // ########################
   aAdd( aAnos , "SELECIONE" )
   aAdd( aAnos , "2011" )
   aAdd( aAnos , "2012" )
   aAdd( aAnos , "2013" )
   aAdd( aAnos , "2014" )
   aAdd( aAnos , "2015" )         
   aAdd( aAnos , "2016" )
   aAdd( aAnos , "2017" )
   aAdd( aAnos , "2018" )
   aAdd( aAnos , "2019" )
   aAdd( aAnos , "2020" )         
   aAdd( aAnos , "2021" )
   aAdd( aAnos , "2022" )
   aAdd( aAnos , "2023" )
   aAdd( aAnos , "2024" )
   aAdd( aAnos , "2025" )         
   aAdd( aAnos , "2026" )
   aAdd( aAnos , "2027" )
   aAdd( aAnos , "2028" )
   aAdd( aAnos , "2029" )
   aAdd( aAnos , "2030" )         
   aAdd( aAnos , "2031" )
   aAdd( aAnos , "2032" )
   aAdd( aAnos , "2033" )
   aAdd( aAnos , "2034" )
   aAdd( aAnos , "2035" )         

   DEFINE MSDIALOG oDlg TITLE "Reabertura Virada Mensal de Estoque" FROM C(178),C(181) TO C(554),C(791) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(022) PIXEL NOBORDER OF oDlg

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(299),C(001) PIXEL OF oDlg
   @ C(168),C(002) GET oMemo3 Var cMemo3 MEMO Size C(299),C(001) PIXEL OF oDlg

   @ C(033),C(005) Say "Empresa"                       Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(033),C(146) Say "Motivo da Reabertura"          Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(056),C(005) Say "Filial"                        Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(078),C(005) Say "Mês a ser reaberto"            Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(101),C(005) Say "Ano a ser reaberto"            Size C(045),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(101),C(096) Say "Data"                          Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(123),C(005) Say "Tipo de Fechamento de Estoque" Size C(080),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(145),C(005) Say "Usuário"                       Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(145),C(075) Say "Data"                          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(145),C(109) Say "Hora"                          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(042),C(005) ComboBox cComboBx1 Items aEmpresas    Size C(136),C(010)                              PIXEL OF oDlg ON CHANGE AlteraCombo()
   @ C(065),C(005) ComboBox cComboBx2 Items aFiliais     Size C(136),C(010)                              PIXEL OF oDlg
   @ C(088),C(005) ComboBox cComboBx3 Items aMeses       Size C(136),C(010)                              PIXEL OF oDlg ON CHANGE CompoeData()
   @ C(110),C(005) ComboBox cComboBx4 Items aAnos        Size C(085),C(010)                              PIXEL OF oDlg ON CHANGE CompoeData()
   @ C(110),C(096) MsGet    oGet1     Var   cData        Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(132),C(005) ComboBox cComboBx5 Items aTipo        Size C(136),C(010)                              PIXEL OF oDlg
   @ C(154),C(005) MsGet    oGet2     Var   cUsuario     Size C(066),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(154),C(075) MsGet    oGet3     Var   cLanca       Size C(030),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(154),C(109) MsGet    oGet4     Var   cHora        Size C(030),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(042),C(146) GET      oMemo2    Var   cMotivo MEMO Size C(154),C(121)                              PIXEL OF oDlg

   @ C(172),C(114) Button "Reabrir" Size C(037),C(012) PIXEL OF oDlg ACTION( ReabrePeriodo() )
   @ C(172),C(152) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #############################################################
// Função que carrega as filiais conforme Empresa selecionada ##
// #############################################################
Static Function AlteraCombo

   aFiliais := U_AUTOM539(2, Substr(cComboBx1,01,02) )
   @ C(065),C(005) ComboBox cComboBx2 Items aFiliais Size C(136),C(010) PIXEL OF oDlg

Return(.T.)

// ##########################################
// Função que compõe a data a ser reaberta ##
// ##########################################
Static Function CompoeData()

   Local lChumba := .F.

   If Substr(cComboBx3,01,02) == "00"
      MsgAlert("Mês a ser reaberto não selecionado. Verifique!")
      Return(.T.)
   Endif    

   If Alltrim(cComboBx4) == "SELECIONE"
      MsgAlert("Ano a ser reaberto não selecionado. Verifique!")
      Return(.T.)
   Endif    

   // ###############################
   // Compõe a data a ser reaberta ##
   // ###############################
   Do Case
      Case Substr(cComboBx3,01,02) == "01"
           cData := Ctod("31/01/" + Alltrim(cComboBx4))
      Case Substr(cComboBx3,01,02) == "02"
           If Mod(Int(Val(cComboBx4)),4) == 0
              cData := Ctod("29/02/" + Alltrim(cComboBx4))
           Else   
              cData := Ctod("28/02/" + Alltrim(cComboBx4))
           Endif
      Case Substr(cComboBx3,01,02) == "03"
           cData := Ctod("31/03/" + Alltrim(cComboBx4))
      Case Substr(cComboBx3,01,02) == "04"
           cData := Ctod("30/04/" + Alltrim(cComboBx4))
      Case Substr(cComboBx3,01,02) == "05"
           cData := Ctod("31/05/" + Alltrim(cComboBx4))
      Case Substr(cComboBx3,01,02) == "06"
           cData := Ctod("30/06/" + Alltrim(cComboBx4))
      Case Substr(cComboBx3,01,02) == "07"
           cData := Ctod("31/07/" + Alltrim(cComboBx4))
      Case Substr(cComboBx3,01,02) == "08"
           cData := Ctod("31/08/" + Alltrim(cComboBx4))
      Case Substr(cComboBx3,01,02) == "09"
           cData := Ctod("30/09/" + Alltrim(cComboBx4))
      Case Substr(cComboBx3,01,02) == "10"
           cData := Ctod("31/10/" + Alltrim(cComboBx4))
      Case Substr(cComboBx3,01,02) == "11"
           cData := Ctod("30/11/" + Alltrim(cComboBx4))
      Case Substr(cComboBx3,01,02) == "12"
           cData := Ctod("31/12/" + Alltrim(cComboBx4))
   EndCase
              
   @ C(110),C(096) MsGet    oGet1     Var   cData        Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

Return(.T.)

// ###############################################################################
// Função que realiza a reabertura do fechamento do estoque conforme parâmetros ##
// ###############################################################################
Static Function ReabrePeriodo()

   If cData == Ctod("  /  /    ")
      MsgAlert("Data a ser reaberta não informada. Verifique!")
      Return(.T.)
   Endif
   
   If Empty(Alltrim(cMotivo))
      MsgAlert("Motivo da reabertura não informado.")
      Return(.T.)
   Endif
      
   If Substr(cComboBx5,01,02) == "00"
      MsgAlert("Tipo de reabertura não selecionada. Verifique")
      Return(.T.)
   Endif
   
   If MsgYesNo("ATENÇÃO!"                                                    + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Você vai realizar a Reabertura do Fechamento de Estoque de:" + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Empresa: " + cComboBx1                                       + chr(13) + chr(10)                     + ;
               "Filial: "  + cComboBx2                                       + chr(13) + chr(10)                     + ;
               "Mês: "     + Substr(cComboBx3,06)                            + chr(13) + chr(10)                     + ;
               "Ano: "     + cComboBx4                                       + chr(13) + chr(10)                     + ;
               "Data: "    + Dtoc(cData)                                     + chr(13) + chr(10)                     + ;
               "Tipo: "    + Substr(cComboBx5,06)                            + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Confirma a reabertura conforme parâmetros acima?", "Confirmação de Reabertura")
   Endif               

Return(.T.)