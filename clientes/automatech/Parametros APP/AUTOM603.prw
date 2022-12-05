#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"    
#INCLUDE "jpeg.ch"    
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#include "fileio.ch"
#INCLUDE "TbiConn.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "XMLXFUN.CH"

// #######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                ##
// ------------------------------------------------------------------------------------ ##
// Referencia: AUTOM603.PRW                                                             ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: (X) Programa  ( ) Gatilho                                                ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                  ##
// Data......: 25/11/2016                                                               ##
// Objetivo..: Controle de Utilização de Veículos                                       ##
// #######################################################################################

User Function AUTOM603()

   Local cMemo1	 := ""
   Local oMemo1

   Private aFiliais    := {}
   Private aTecnicos   := {}
   Private aveiculos   := {}
   Private aStatus	   := {"T - Todos", "A - Abertas", "E - Encerradas"}
   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cComboBx4
   Private cDtaInicial := Ctod("  /  /    ")
   Private cDtaFinal   := Ctod("  /  /    ")
   Private oGet1
   Private oGet2

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

   Private aBrowse := {}

   Private oDlg

   // #################################   
   // Carrega o combobox das filiais ##
   // #################################
   aFiliais := U_AUTOM539(2, cEmpAnt)

//   Do Case
//      Case cEmpAnt == "01"
//           aFiliais := {"00 - Selecione", "01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos"}
//      Case cEmpAnt == "02"
//           aFiliais := {"00 - Selecione", "01 - Curitiba"}
//      Case cEmpAnt == "03"
//           aFiliais := {"00 - Selecione", "01 - Porto Alegre"}
//   EndCase

   // ##################################
   // Carrega o combobox dos Técnicos ##
   // ##################################
   If Select("T_TECNICOS") > 0
      T_TECNICOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AA1_CODTEC,"
   cSql += "       AA1_NOMTEC "
   cSql += "  FROM " + RetSqlName("AA1")
   cSql += " WHERE D_E_L_E_T_  = ''"
   cSql += "   AND AA1_CODUSR <> ''"
   cSql += " ORDER BY AA1_NOMTEC   "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TECNICOS", .T., .T. )

   aAdd( aTecnicos, "000000 - Todos o Técnico" )
   
   T_TECNICOS->( DbGoTop() )
   
   WHILE !T_TECNICOS->( EOF() )
      aAdd( aTecnicos, T_TECNICOS->AA1_CODTEC + " - " + Alltrim(T_TECNICOS->AA1_NOMTEC) )
      T_TECNICOS->( DbSkip() )
   ENDDO

   // #################################
   // Carrega o combobox de Veículos ##
   // #################################
   If Select("T_VEICULOS") > 0
      T_VEICULOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZTV_PLACA ,"
   cSql += "       ZTV_MODELO "
   cSql += "  FROM " + RetSqlName("ZTV")
   cSql += " WHERE D_E_L_E_T_  = ''"
   cSql += "   AND ZTV_DELE    = ''"
   cSql += " ORDER BY ZTV_PLACA    "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VEICULOS", .T., .T. )

   T_VEICULOS->( DbGoTop() )

   aAdd( aVeiculos, "Selecione" )
   
   WHILE !T_VEICULOS->( EOF() )
      aAdd( aVeiculos, T_VEICULOS->ZTV_PLACA )
      T_VEICULOS->( DbSkip() )
   ENDDO

   DEFINE MSDIALOG oDlg TITLE "Controle de Utilização de Veículos" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlg
   @ C(212),C(128) Jpeg FILE "br_verde"        Size C(010),C(010) PIXEL NOBORDER OF oDlg
   @ C(212),C(176) Jpeg FILE "br_vermelho"     Size C(010),C(010) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(037),C(005) Say "Filial"        Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(057) Say "Técnico"       Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(189) Say "Data Inicial"  Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(232) Say "Data Final"    Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(274) Say "Placa"         Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(315) Say "Status"        Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(212),C(141) Say "KM Encerradas" Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(212),C(189) Say "KM A Encerrar" Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(046),C(005) ComboBox cComboBx1 Items aFiliais  Size C(045),C(010) PIXEL OF oDlg
   @ C(046),C(057) ComboBox cComboBx2 Items aTecnicos Size C(126),C(010) PIXEL OF oDlg
   @ C(046),C(189) MsGet    oGet1 Var cDtaInicial     Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(232) MsGet    oGet2 Var cDtaFinal       Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(274) ComboBox cComboBx3 Items aVeiculos Size C(035),C(010) PIXEL OF oDlg
   @ C(046),C(315) ComboBox cComboBx4 Items aStatus   Size C(037),C(010) PIXEL OF oDlg

   @ C(043),C(356) Button "Pesquisar"                 Size C(031),C(012) PIXEL OF oDlg ACTION( PsqKMS(0) )
   
   @ C(210),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION( ManQuilometro("I", "", "") )
   @ C(210),C(043) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( ManQuilometro("A", aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03]) )
   @ C(210),C(082) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION( ManQuilometro("E", aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03]) )
   @ C(210),C(461) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // ###################################
   // Desenha o Grid para visualização ##
   // ###################################
   aAdd( aBrowse, { "7", "", "", "", "", "", "", "", "", "", "", "", "" })

   oBrowse := TCBrowse():New( 080 , 005, 633, 185,,{'LG'              ,; // 01
                                                    'FL'              ,; // 02
                                                    'Nº Controle'     ,; // 03
                                                    'Veículo'         ,; // 04
                                                    'D.Inicial'       ,; // 05
                                                    'H.Inicial'       ,; // 06
                                                    'D.Utilização'    ,; // 07
                                                    'H.Utilização'    ,; // 08
                                                    'D.Devolução'     ,; // 09
                                                    'H.Devolução'     ,; // 10
                                                    'KM Inicial'      ,; // 11
                                                    'KM Final'        ,; // 12
                                                    'KM Total'      } ,; // 13
                                      {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // ###########################
   // Seta vetor para a browse ##
   // ###########################                           
   oBrowse:SetArray(aBrowse) 

   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,02]            ,;
                         aBrowse[oBrowse:nAt,03]            ,;
                         aBrowse[oBrowse:nAt,04]            ,;
                         aBrowse[oBrowse:nAt,05]            ,;
                         aBrowse[oBrowse:nAt,06]            ,;
                         aBrowse[oBrowse:nAt,07]            ,;
                         aBrowse[oBrowse:nAt,08]            ,;
                         aBrowse[oBrowse:nAt,09]            ,;
                         aBrowse[oBrowse:nAt,10]            ,;
                         aBrowse[oBrowse:nAt,11]            ,;
                         aBrowse[oBrowse:nAt,12]            ,;
                         aBrowse[oBrowse:nAt,13]            }}

   oBrowse:Refresh()

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ###########################################################
// Função que abre a janela de manutenção das quilometragem ##
// ###########################################################
Static Function ManQuilometro(_Operacao, _Filial, _Controle)

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo10 := ""
   Local cMemo3	 := ""
   Local cMemo8	 := ""
   Local cMemo9	 := ""
   Local oMemo1
   Local oMemo10
   Local oMemo3
   Local oMemo8
   Local oMemo9

   Private xControle   := Space(06)
   Private xTecnicos   := {}
   Private xVeiculos   := {}
   Private xCelular    := {}
   Private xDtaInicial := Ctod("  /  /    ")
   Private xHraInicial := "  :  "
   Private xDtaUtiliza := Ctod("  /  /    ")
   Private xHraUtiliza := "  :  "
   Private xDtaEncerra := Ctod("  /  /    ")
   Private xHraEncerra := "  :  "
   Private xKMInicial  := 0
   Private xKMFinal    := 0
   Private xKMTotal    := 0
   Private xObservacao := ""

   Private cTecnico1
   Private cVeiculo1
   Private cCelular
   Private cComboBx9
   Private oGet4     
   Private oGet1     
   Private oGet9     
   Private oGet10    
   Private oGet11    
   Private oGet12    
   Private oGet13    
   Private oGet5     
   Private oGet6     
   Private oGet7     
   Private oMemo7    

   Private oDlgKM

   // #################################   
   // Carrega o combobox das filiais ##
   // #################################
   Do Case
      Case cEmpAnt == "01"
           xFiliais := {"00 - Selecione", "01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos", "05 - São Paulo", "06 - Espírito Santo", "07 - Suprimentos(Novo)"}
      Case cEmpAnt == "02"
           xFiliais := {"00 - Selecione", "01 - Curitiba"}
      Case cEmpAnt == "03"
           xFiliais := {"00 - Selecione", "01 - Porto Alegre"}
   EndCase

   // ##################################
   // Carrega o combobox dos Técnicos ##
   // ##################################
   If Select("T_TECNICOS") > 0
      T_TECNICOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AA1_CODTEC,"
   cSql += "       AA1_NOMTEC "
   cSql += "  FROM " + RetSqlName("AA1")
   cSql += " WHERE D_E_L_E_T_  = ''"
   cSql += "   AND AA1_CODUSR <> ''"
   cSql += " ORDER BY AA1_NOMTEC   "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TECNICOS", .T., .T. )

   aAdd( xTecnicos, "000000 - Todos o Técnico" )
   
   T_TECNICOS->( DbGoTop() )
   
   WHILE !T_TECNICOS->( EOF() )
      aAdd( xTecnicos, T_TECNICOS->AA1_CODTEC + " - " + Alltrim(T_TECNICOS->AA1_NOMTEC) )
      T_TECNICOS->( DbSkip() )
   ENDDO

   // ##################################
   // Carrega o combobox de Celulares ##
   // ##################################
   If Select("T_CELULAR") > 0
      T_CELULAR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZTZ_CELU  ,"
   cSql += "       ZTZ_MODELO "
   cSql += "  FROM " + RetSqlName("ZTZ")
   cSql += " WHERE D_E_L_E_T_  = ''"
   cSql += "   AND ZTZ_DELE    = ''"
   cSql += " ORDER BY ZTZ_CELU     "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CELULAR", .T., .T. )

   T_CELULAR->( DbGoTop() )

   aAdd( xCelular, "Selecione" )
   
   WHILE !T_CELULAR->( EOF() )
      aAdd( xCelular, T_CELULAR->ZTZ_CELU)
      T_CELULAR->( DbSkip() )
   ENDDO

   // #################################
   // Carrega o combobox de Veículos ##
   // #################################
   If Select("T_VEICULOS") > 0
      T_VEICULOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZTV_PLACA ,"
   cSql += "       ZTV_MODELO "
   cSql += "  FROM " + RetSqlName("ZTV")
   cSql += " WHERE D_E_L_E_T_  = ''"
   cSql += "   AND ZTV_DELE    = ''"
   cSql += " ORDER BY ZTV_PLACA    "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VEICULOS", .T., .T. )

   T_VEICULOS->( DbGoTop() )

   aAdd( xVeiculos, "Selecione" )
   
   WHILE !T_VEICULOS->( EOF() )
      aAdd( xVeiculos, T_VEICULOS->ZTV_PLACA + " - " + Alltrim(T_VEICULOS->ZTV_MODELO))
      T_VEICULOS->( DbSkip() )
   ENDDO

   // #######################################
   // Carrega as variáveis para manutenção ##
   // #######################################
   If _Operacao == "I"
   Else

      If Empty(Alltrim(_Controle))
         MsgAlert("Nenhum registro seleciondo para pesquisa.")
         Return(.T.)
      Endif

      If Select("T_CONSULTA") > 0
         T_CONSULTA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZTT.ZTT_FILIAL," 
      cSql += "	      ZTT.ZTT_CONT  ,"
      cSql += "       ZTT.ZTT_TECN  ,"
      cSql += "       ZTT.ZTT_CELU  ,"
      cSql += "       ZTT.ZTT_PLACA ,"
      cSql += "	      ZTT.ZTT_DINI  ,"
      cSql += "	      ZTT.ZTT_HINI  ,"
      cSql += "	      ZTT.ZTT_DUTI  ,"
      cSql += "	      ZTT.ZTT_HUTI  ,"
      cSql += "	      ZTT.ZTT_DFIM  ,"
      cSql += "	      ZTT.ZTT_HFIM  ,"      
      cSql += "	      ZTT.ZTT_KINI  ,"
      cSql += "	      ZTT.ZTT_KFIM  ,"
      cSql += "	      ZTT.ZTT_KTOT  ,"
      cSql += "       ZTT.ZTT_DELE  ,"
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZTT.ZTT_OBSE)) AS OBSERVACAO"
      cSql += "  FROM " + RetSqlName("ZTT") + " ZTT "
      cSql += " WHERE ZTT.ZTT_FILIAL = '" + Alltrim(_Filial)   + "'"
      cSql += "   AND ZTT.ZTT_CONT   = '" + Alltrim(_Controle) + "'"
      cSql += "   AND ZTT.ZTT_DELE   = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )
 
      If T_CONSULTA->( EOF() )
         MsgAlert("Não existem dados a serem visualizados.")
         Return(.T.)
      Endif
      
      Do Case
         Case cEmpAnt == "01"
              Do Case
                 Case T_CONSULTA->ZTT_FILIAL == "01"
                      cComboBx9 := "01 - Porto Alegre"
                 Case T_CONSULTA->ZTT_FILIAL == "02"
                      cComboBx9 := "02 - Caxias do Sul"
                 Case T_CONSULTA->ZTT_FILIAL == "03"
                      cComboBx9 := "03 - Pelotas" 
                 Case T_CONSULTA->ZTT_FILIAL == "04"
                      cComboBx9 := "04 - Suprimentos"
                 Case T_CONSULTA->ZTT_FILIAL == "05"
                      cComboBx9 := "05 - São Paulo"
                 Case T_CONSULTA->ZTT_FILIAL == "06"
                      cComboBx9 := "06 - Espírito Santo"
                 Case T_CONSULTA->ZTT_FILIAL == "07"
                      cComboBx9 := "07 - Suprimentos(Novo)"
              EndCase
         Case cEmpAnt == "02"
              cComboBx9 := "01 - Curitiba"
         Case cEmpAnt == "03"
              cComboBx9 := "01 - Porto Alegre"
      EndCase
              
      cTecnico1 := Posicione( "AA1", 1, xFilial("AA1") + T_CONSULTA->ZTT_TECN, "AA1_CODTEC" ) + " - " + ;
                   Posicione( "AA1", 1, xFilial("AA1") + T_CONSULTA->ZTT_TECN, "AA1_NOMTEC" )                                                                                             

      cVeiculo1 := Posicione( "ZTV", 1, xFilial("ZTV") + T_CONSULTA->ZTT_PLACA, "ZTV_PLACA")  + " - " + ;
                   Posicione( "ZTV", 1, xFilial("ZTV") + T_CONSULTA->ZTT_PLACA, "ZTV_MODELO" )                                                                                             

      cCelular  := T_CONSULTA->ZTT_CELU

      xDtaInicial := Ctod(Substr(T_CONSULTA->ZTT_DINI,07,02) + "/" + Substr(T_CONSULTA->ZTT_DINI,05,02) + "/" + Substr(T_CONSULTA->ZTT_DINI,01,04))
      xHraInicial := T_CONSULTA->ZTT_HINI
      xDtaUtiliza := Ctod(Substr(T_CONSULTA->ZTT_DUTI,07,02) + "/" + Substr(T_CONSULTA->ZTT_DUTI,05,02) + "/" + Substr(T_CONSULTA->ZTT_DUTI,01,04))
      xHraUtiliza := T_CONSULTA->ZTT_HUTI
      xDtaFinal   := Ctod(Substr(T_CONSULTA->ZTT_DFIM,07,02) + "/" + Substr(T_CONSULTA->ZTT_DFIM,05,02) + "/" + Substr(T_CONSULTA->ZTT_DFIM,01,04))
      xHraEncerra := T_CONSULTA->ZTT_HFIM
      xControle   := T_CONSULTA->ZTT_CONT
      xKMInicial  := T_CONSULTA->ZTT_KINI
      xKMFinal    := T_CONSULTA->ZTT_KFIM
      xKMTotal    := T_CONSULTA->ZTT_KTOT
      xObservacao := T_CONSULTA->OBSERVACAO

   Endif

   DEFINE MSDIALOG oDlgKM TITLE "Controle de Utilização de Veículos" FROM C(178),C(181) TO C(588),C(685) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgKM

   @ C(032),C(002) GET oMemo1  Var cMemo1  MEMO Size C(245),C(001) PIXEL OF oDlgKM
   @ C(091),C(005) GET oMemo8  Var cMemo8  MEMO Size C(065),C(001) PIXEL OF oDlgKM
   @ C(091),C(093) GET oMemo9  Var cMemo9  MEMO Size C(065),C(001) PIXEL OF oDlgKM
   @ C(091),C(180) GET oMemo10 Var cMemo10 MEMO Size C(065),C(001) PIXEL OF oDlgKM
   @ C(184),C(002) GET oMemo3  Var cMemo3  MEMO Size C(245),C(001) PIXEL OF oDlgKM

   @ C(037),C(005) Say "Nº Controle" Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgKM
   @ C(059),C(005) Say "Técnico"     Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgKM
   @ C(059),C(199) Say "Veículo"     Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgKM
   @ C(081),C(005) Say "Empréstimo"  Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgKM
   @ C(081),C(093) Say "Utilização"  Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgKM
   @ C(081),C(180) Say "Devolução"   Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgKM
   @ C(094),C(005) Say "Data/Hora"   Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgKM
   @ C(094),C(093) Say "Data/Hora"   Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgKM
   @ C(094),C(180) Say "Data/Hora"   Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgKM
   @ C(120),C(055) Say "KM Inicial"  Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgKM
   @ C(120),C(108) Say "KM Final"    Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgKM
   @ C(120),C(160) Say "KM Total"    Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgKM
   @ C(142),C(005) Say "Observações" Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlgKM
   @ C(037),C(038) Say "Filial"      Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgKM
   @ C(037),C(199) Say "Celular"     Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgKM

   @ C(046),C(005) MsGet      oGet4     Var   xControle        Size C(027),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgKM When lChumba

   @ C(046),C(038) ComboBox   cComboBx9 Items xFiliais         Size C(156),C(010)                                         PIXEL OF oDlgKM

   @ C(046),C(199) ComboBox   cCelular  Items xCelular         Size C(048),C(010)                                         PIXEL OF oDlgKM
   
   @ C(068),C(005) ComboBox   cTecnico1 Items xTecnicos        Size C(190),C(010)                                         PIXEL OF oDlgKM
   @ C(068),C(199) ComboBox   cVeiculo1 Items xVeiculos        Size C(048),C(010)                                         PIXEL OF oDlgKM
   @ C(104),C(005) MsGet      oGet1     Var   xDtaInicial      Size C(039),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlgKM
   @ C(104),C(048) MsGet      oGet9     Var   xHraInicial      Size C(022),C(009) COLOR CLR_BLACK Picture "@! XX:XX"      PIXEL OF oDlgKM
   @ C(104),C(093) MsGet      oGet10    Var   xDtaUtiliza      Size C(039),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlgKM
   @ C(104),C(136) MsGet      oGet11    Var   xHraUtiliza      Size C(022),C(009) COLOR CLR_BLACK Picture "@! XX:XX"      PIXEL OF oDlgKM
   @ C(104),C(180) MsGet      oGet12    Var   xDtaEncerra      Size C(039),C(009) COLOR CLR_BLACK Picture "@D XX/XX/XXXX" PIXEL OF oDlgKM
   @ C(104),C(223) MsGet      oGet13    Var   xHraEncerra      Size C(022),C(009) COLOR CLR_BLACK Picture "@! XX:XX"      PIXEL OF oDlgKM
   @ C(129),C(055) MsGet      oGet5     Var   xKMInicial       Size C(039),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgKM VALID( CalcKMTot() )
   @ C(129),C(108) MsGet      oGet6     Var   xKMFinal         Size C(039),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgKM VALID( CalcKMTot() )
   @ C(129),C(160) MsGet      oGet7     Var   xKMTotal         Size C(039),C(009) COLOR CLR_BLACK Picture "@E 999999"     PIXEL OF oDlgKM When lChumba
   @ C(151),C(005) GET oMemo7           Var   xObservacao MEMO Size C(243),C(029)                                         PIXEL OF oDlgKM

   @ C(188),C(088) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgKM ACTION( GRVQUILOMETRO(_Operacao) )
   @ C(188),C(127) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgKM ACTION( oDlgKM:End() )

   ACTIVATE MSDIALOG oDlgKM CENTERED 

Return(.T.)

// ###########################################
// Função que calcula a quilometragem total ##
// ###########################################
Static Function CalcKMTot()

   If xKMInicial == 0
      xKMTotal := 0
      oGet7:Refresh()
      Return(.T.)
   Endif
      
   If xKMFinal == 0
      xKMTotal := 0
      oGet7:Refresh()
      Return(.T.)
   Endif

   If xKMInicial > xKMFinal
      MsgAlert("KM infomados inválidos. Veirfique!")
      Return(.T.)
   Endif
   
   xKMTotal := xKMFinal - xKMInicial
   oGet7:refresh()

Return(.T.)

// ######################################################
// Função que grava os dados da utilização de veículos ##
// ######################################################
Static Function GrvQuilometro(_Operacao)

   Local cSql := ""

   // #################################################
   // Gera consistências dos dados antes da gravação ##
   // #################################################

   If xDtaInicial == Ctod("  /  /    ")
      MsgAlert("Data inicial não informada.")
      Return(.T.)
   Endif

   If xKMTotal <> 0
      If xDtaEncerra == Ctod("  /  /    ")
         MsgAlert("Data de devolução não informada.")
         Return(.T.)
      Endif
   Endif   

   If Substr(cComboBx9,01,02) == "00"
      MsgAlert("Filial não selecionada.")
      Return(.T.)
   Endif

   If Substr(cTecnico1,01,05) == "000000"
      MsgAlert("Técnico não selecionado.")
      Return(.T.)
   Endif

   If Alltrim(cCelular) == "Selecione"
      MsgAlert("Nº Celular não selecionado.")
      Return(.T.)
   Endif

   If Alltrim(Substr(cVeiculo1,01,10)) == "Selecione"
      MsgAlert("Veículo não selecionado.")
      Return(.T.)
   Endif

   If xDtaInicial <> Ctod("  /  /    ")
      If xHraInicial == "  :  "
         MsgAlert("Hora inicial não informada.")
         Return(.T.)
      Endif
   Endif   
      
   If xDtaUtiliza <> Ctod("  /  /    ")
      If xHraUtiliza == "  :  "
         MsgAlert("Hora de utilização não informada.")
         Return(.T.)
      Endif
   Endif   

   If xDtaEncerra <> Ctod("  /  /    ")
      If xHraEncerra == "  :  "
         MsgAlert("Hora de devolução não informada.")
         Return(.T.)
      Endif
   Endif   

   If xDtaEncerra <> Ctod("  /  /    ")
      If xKMTotal == 0
         MsgAlert("KM inválida.")
         Return(.T.)
      Endif
   Endif   
   
   If xDtaEncerra <> Ctod("  /  /    ")
      If xKMInicial> xKMFinal
         MsgAlert("KMs inválidos.")
         Return(.T.)
      Endif
   Endif
   
   // ########################
   // Inclusçao do Registro ##
   // ########################
   If _Operacao == "I"

      // #################################################################
      // Pesquisa o próximo código de controle para realizar a inclusão ##
      // #################################################################
      If Select("T_PROXIMO") > 0
         T_PROXIMO->( dbCloseArea() )
      EndIf
      
      cSql := ""
      cSql := "SELECT TOP(1) ZTT_CONT"
      cSql += "  FROM " + RetSqlName("ZTT")
      cSql += " WHERE ZTT_FILIAL = '" + Alltrim(cFilAnt) + "'"
      cSql += "   AND ZTT_DELE   = ''"
      cSql += " ORDER BY ZTT_CONT DESC"
   
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

      xControle := IIF(T_PROXIMO->( EOF() ), "000001", Strzero((INT(VAL(T_PROXIMO->ZTT_CONT)) + 1),6))

      dbSelectArea("ZTT")
      RecLock("ZTT",.T.)
      ZTT_FILIAL := Substr(cComboBx9,01,02)
      ZTT_CONT   := xControle
      ZTT_TECN   := Substr(cTecnico1,01,06)
      ZTT_CELU   := cCelular
      ZTT_PLACA  := Substr(cVeiculo1,01,10)
      ZTT_DINI   := xDtaInicial
      ZTT_HINI   := xHraInicial
      ZTT_DUTI   := xDtaUtiliza
      ZTT_HUTI   := xHraUtiliza
      ZTT_DFIM   := xDtaEncerra
      ZTT_HFIM   := xHraEncerra
      ZTT_KINI   := xKMInicial
      ZTT_KFIM   := xKMFinal
      ZTT_KTOT   := xKMTotal
      ZTT_OBSE   := xObservacao
      ZTT_DELE   := ""
      MsUnLock()
      
   Endif   

   // ########################
   // Alteração do Registro ##
   // ########################
   If _Operacao == "A"

      DbSelectArea("ZTT")
      DbSetOrder(1)
      If DbSeek(Substr(cComboBx9,01,02) + xControle)
         RecLock("ZTT",.F.)
         ZTT_FILIAL := Substr(cComboBx9,01,02)
         ZTT_TECN   := Substr(cTecnico1,01,06)
         ZTT_CELU   := cCelular 
         ZTT_PLACA  := Substr(cVeiculo1,01,10)
         ZTT_DINI   := xDtaInicial
         ZTT_HINI   := xHraInicial
         ZTT_DUTI   := xDtaUtiliza
         ZTT_HUTI   := xHraUtiliza
         ZTT_DFIM   := xDtaEncerra
         ZTT_HFIM   := xHraEncerra
         ZTT_KINI   := xKMInicial
         ZTT_KFIM   := xKMFinal
         ZTT_KTOT   := xKMTotal
         ZTT_OBSE   := xObservacao
         ZTT_DELE   := ""
         MsUnLock()
      Endif
      
   Endif
     
   // #######################
   // Exclusão do Registro ##
   // #######################
   If _Operacao == "E"

      DbSelectArea("ZTT")
      DbSetOrder(1)
      If DbSeek(Substr(cComboBx9,01,02) + xControle)
         RecLock("ZTT",.F.)
         ZTT_DELE   := "X"
         MsUnLock()
      Endif
      
   Endif

   oDlgKM:End()

   // ################################################################
   // Envia para a função que carrega o grid principal para display ##
   // ################################################################
   PsqKMS(1)

Return(.T.)

// ###########################################################
// Função que pesquisa as quilometragem conforme parâmetros ##
// ###########################################################
Static Function PsqKMS(_TipoPesquisa)

   Local cSql   := ""
   Local lVolta := .F.

   // #############################################################
   // Gera consistências dos parâmetros para realizar a pesquisa ##
   // #############################################################
   If _TipoPesquisa == 0

      If Substr(cComboBx1,01,02) == "00"
         MsgAlert("Filial de pesquisa não selecionada.")
         Return(.T.)
      Endif
              
      If Substr(cComboBx2,01,06) == "000000"
         MsgAlert("Técnico a ser pesquisado não selecionado.")
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

   Else

      If Substr(cComboBx1,01,02) == "00"
         lVolta := .T.
      Endif
              
      If Substr(cComboBx2,01,06) == "000000"
         lVolta := .T.
      Endif

      If cDtaInicial == Ctod("  /  /    ")
         lVolta := .T.
      Endif

      If cDtaFinal == Ctod("  /  /    ")
         lVolta := .T.
      Endif
    
      If lVolta == .T.
         Return(.T.)
      Endif
         
   Endif

   // ########################################
   // Pesquisa os dados conforme parâmetros ##
   // ########################################
   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZTT.ZTT_FILIAL," 
   cSql += "       ZTT.ZTT_TECN  ,"
   cSql += "       AA1.AA1_NOMTEC,"
   cSql += "       ZTT.ZTT_CELU  ,"
   cSql += "       ZTT.ZTT_PLACA ,"
   cSql += "       ZTV.ZTV_MODELO,"
   cSql += "	   ZTT.ZTT_DINI  ,"
   cSql += "       ZTT.ZTT_HINI  ,"
   cSql += "	   ZTT.ZTT_DUTI  ,"
   cSql += "       ZTT.ZTT_HUTI  ,"
   cSql += "	   ZTT.ZTT_DFIM  ,"
   cSql += "	   ZTT.ZTT_HFIM  ,"
   cSql += "	   ZTT.ZTT_KINI  ,"
   cSql += "	   ZTT.ZTT_KFIM  ,"
   cSql += "	   ZTT.ZTT_KTOT  ,"
   cSql += "       ZTT.ZTT_DELE  ,"
   cSql += "	   ZTT.ZTT_CONT   "
   cSql += "  FROM " + RetSqlName("ZTT") + " ZTT, "
   cSql += "       " + RetSqlName("AA1") + " AA1, "
   cSql += "       " + RetSqlName("ZTV") + " ZTV  "
   cSql += " WHERE ZTT.ZTT_FILIAL  = '" + Substr(cComboBx1,01,02) + "'"
   cSql +="    AND ZTT.ZTT_TECN    = '" + Substr(cComboBx2,01,06) + "'"
   cSql += "   AND ZTT.ZTT_DINI   >= CONVERT(DATETIME,'" + Dtoc(cDtaInicial) + "', 103)"
   cSql += "   AND ZTT.ZTT_DINI   <= CONVERT(DATETIME,'" + Dtoc(cDtaFinal)   + "', 103)"
   cSql += "   AND ZTT.ZTT_DELE    = ''"
   cSql += "   AND AA1.AA1_CODTEC  = ZTT.ZTT_TECN "
   cSql += "   AND AA1.D_E_L_E_T_  = ''"
   cSql +="    AND ZTV.ZTV_PLACA   = ZTT.ZTT_PLACA"
   cSql += "   AND ZTV.ZTV_DELE    = ''"

   If Alltrim(cComboBx3) == "Selecione"
   Else
      cSql += "  AND ZTT_PLACA = '" + Alltrim(cComboBx3) + "'"
   Endif                                                                                     

   Do Case
      Case Substr(cComboBx4,01,01) == "A"
           cSql += "  AND ZTT_KTOT  = " + Str(0)
      Case Substr(cComboBx4,01,01) == "E"
           cSql += "  AND ZTT_KTOT <> " + Str(0)
   EndCase           

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )

   aBrowse := {}

   WHILE !T_CONSULTA->( EOF() )

      xxx_DtaInicial := Substr(T_CONSULTA->ZTT_DINI,07,02) + "/" + Substr(T_CONSULTA->ZTT_DINI,05,02) + "/" + Substr(T_CONSULTA->ZTT_DINI,01,04)
      xxx_DtaUtiliza := Substr(T_CONSULTA->ZTT_DUTI,07,02) + "/" + Substr(T_CONSULTA->ZTT_DUTI,05,02) + "/" + Substr(T_CONSULTA->ZTT_DUTI,01,04)
      xxx_DtaFinal   := Substr(T_CONSULTA->ZTT_DFIM,07,02) + "/" + Substr(T_CONSULTA->ZTT_DFIM,05,02) + "/" + Substr(T_CONSULTA->ZTT_DFIM,01,04)
      cLegenda       := IIF(T_CONSULTA->ZTT_KTOT == 0, "9", "1")

      aAdd( aBrowse, {cLegenda               ,; // 01
                      T_CONSULTA->ZTT_FILIAL ,; // 02
                      T_CONSULTA->ZTT_CONT   ,; // 03
                      T_CONSULTA->ZTT_PLACA  ,; // 04
                      xxx_DtaInicial         ,; // 05
                      T_CONSULTA->ZTT_HINI   ,; // 06
                      xxx_DtaUtiliza         ,; // 07
                      T_CONSULTA->ZTT_HUTI   ,; // 08
                      xxx_DtaFinal           ,; // 09 
                      T_CONSULTA->ZTT_HFIM   ,; // 10
                      T_CONSULTA->ZTT_KINI   ,; // 11
                      T_CONSULTA->ZTT_KFIM   ,; // 12
                      T_CONSULTA->ZTT_KTOT   }) // 13

      aAdd( aBrowse, {" ", "", "", "", "", "", "", "", "", "", "", "", "" })

      T_CONSULTA->( DbSkip() )
      
   ENDDO

   If Len(aBrowse) == 0
      aAdd( aBrowse, { "7", "", "", "", "", "", "", "", "", "", "", "", "" })   
   Endif
   
   oBrowse:SetArray(aBrowse) 

   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oPink    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oVermelho,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oEncerra, "")))))))))),;                         
                         aBrowse[oBrowse:nAt,02]            ,;
                         aBrowse[oBrowse:nAt,03]            ,;
                         aBrowse[oBrowse:nAt,04]            ,;
                         aBrowse[oBrowse:nAt,05]            ,;
                         aBrowse[oBrowse:nAt,06]            ,;
                         aBrowse[oBrowse:nAt,07]            ,;
                         aBrowse[oBrowse:nAt,08]            ,;
                         aBrowse[oBrowse:nAt,10]            ,;
                         aBrowse[oBrowse:nAt,11]            ,;
                         aBrowse[oBrowse:nAt,11]            ,;
                         aBrowse[oBrowse:nAt,12]            ,;                         
                         aBrowse[oBrowse:nAt,13]            }}

   oBrowse:Refresh()

Return(.T.)