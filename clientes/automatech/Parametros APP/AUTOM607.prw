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
// Referencia: AUTOM607.PRW                                                             ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: (X) Programa  ( ) Gatilho                                                ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                  ##
// Data......: 05/01/2017                                                               ##
// Objetivo..: GeoLocalizador App Auutomatech AT                                        ##
// #######################################################################################

User Function AUTOM607()

   Local cMemo1	 := ""
   Local oMemo1

   Private aFiliais    := {}
   Private aCelular    := {}
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
   // Carrega o combobox de Celulares ##
   // ##################################
   If Select("T_CELULAR") > 0
      T_CELULAR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZTZ.ZTZ_CELU  ,"
   cSql += "       ZTZ.ZTZ_MODELO,"
   cSql += "       ZTZ.ZTZ_ATIVO  "
   cSql += "  FROM " + RetSqlName("ZTZ") + " ZTZ "
   cSql += " WHERE ZTZ.D_E_L_E_T_ = ''           "
   cSql += "   AND ZTZ.ZTZ_DELE   = ''           " 
   cSql += " ORDER BY ZTZ.ZTZ_CELU               "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CELULAR", .T., .T. )

   T_CELULAR->( DbGoTop() )

   aAdd( aCelular, "Selecione" )
   
   WHILE !T_CELULAR->( EOF() )
      aAdd( aCelular, T_CELULAR->ZTZ_CELU )
      T_CELULAR->( DbSkip() )
   ENDDO

   DEFINE MSDIALOG oDlg TITLE "Controle de GeoLocalização" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(037),C(005) Say "Filial"       Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(057) Say "Nº Celular"   Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(137) Say "Data Inicial" Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(179) Say "Data Final"   Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg


   @ C(046),C(005) ComboBox cComboBx1 Items aFiliais    Size C(045),C(010)                              PIXEL OF oDlg
   @ C(046),C(057) ComboBox cComboBx2 Items aCelular    Size C(075),C(010)                              PIXEL OF oDlg
   @ C(046),C(137) MsGet    oGet1     Var   cDtaInicial Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(179) MsGet    oGet2     Var   cDtaFinal   Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(043),C(221) Button   "Pesquisar"                 Size C(031),C(012)                              PIXEL OF oDlg ACTION( PsqGeoLoc(0) )
   @ C(210),C(461) Button   "Voltar"                    Size C(037),C(012)                              PIXEL OF oDlg ACTION( oDlg:End() )

   // ###################################
   // Desenha o Grid para visualização ##
   // ###################################
   aAdd( aBrowse, { "", "", "", "", "", "", "", "", "" })

   oBrowse := TCBrowse():New( 080 , 005, 633, 185,,{'FL'              ,; // 01
                                                    'Nº Controle'     ,; // 02
                                                    'Nº Celular'      ,; // 03
                                                    'Data Leitura'    ,; // 04
                                                    'Hora Leitura'    ,; // 05
                                                    'Latitude    '    ,; // 06
                                                    'Longitude   '    ,; // 07
                                                    'Altitude    '    ,; // 08
                                                    'Velocidade  '  } ,; // 09
                                      {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // ###########################
   // Seta vetor para a browse ##
   // ###########################                           
   oBrowse:SetArray(aBrowse) 

   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06],;
                         aBrowse[oBrowse:nAt,07],;
                         aBrowse[oBrowse:nAt,08],;
                         aBrowse[oBrowse:nAt,09]}}

   oBrowse:Refresh()

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ###########################################################
// Função que pesquisa as quilometragem conforme parâmetros ##
// ###########################################################
Static Function PsqGeoLoc()

   Local cSql   := ""
   Local lVolta := .F.

   // #############################################################
   // Gera consistências dos parâmetros para realizar a pesquisa ##
   // #############################################################
   If Substr(cComboBx1,01,02) == "00"
      MsgAlert("Filial de pesquisa não selecionada.")
      Return(.T.)
   Endif
              
   If Alltrim(cComboBx2) == "Selecione"
      MsgAlert("Celualr a ser rastreado não selecionado.")
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
   cSql := "SELECT ZTW.ZTW_FILIAL," 
   cSql += "       ZTW.ZTW_CONT  ," 
   cSql += "       ZTW.ZTW_CELU  ,"
   cSql += "       ZTW.ZTW_DATA  ,"
   cSql += "       ZTW.ZTW_HORA  ,"
   cSql += "	   ZTW.ZTW_LATI  ,"
   cSql += "       ZTW.ZTW_LONG  ,"
   cSql += "	   ZTW.ZTW_ALTI  ,"
   cSql += "       ZTW.ZTW_VELO   "
   cSql += "  FROM " + RetSqlName("ZTW") + " ZTW "
   cSql += " WHERE ZTW.ZTW_FILIAL  = '" + Substr(cComboBx1,01,02) + "'"
   cSql +="    AND ZTW.ZTW_CELU    = '" + Alltrim(cComboBx2)      + "'"
   cSql += "   AND ZTW.ZTW_DINI   >= CONVERT(DATETIME,'" + Dtoc(cDtaInicial) + "', 103)"
   cSql += "   AND ZTW.ZTW_DINI   <= CONVERT(DATETIME,'" + Dtoc(cDtaFinal)   + "', 103)"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )

   aBrowse := {}

   WHILE !T_CONSULTA->( EOF() )

      xxx_DtaLeitura := Substr(T_CONSULTA->ZTW_DINI,07,02) + "/" + Substr(T_CONSULTA->ZTW_DINI,05,02) + "/" + Substr(T_CONSULTA->ZTW_DINI,01,04)

      aAdd( aBrowse, {T_CONSULTA->ZTW_FILIAL ,; // 01  
                      T_CONSULTA->ZTW_CONT   ,; // 02
                      T_CONSULTA->ZTW_CELU   ,; // 03
                      xxx_DtaLeitura         ,; // 04
                      T_CONSULTA->ZTW_HORA   ,; // 05
                      T_CONSULTA->ZTW_LATI   ,; // 06
                      T_CONSULTA->ZTW_LONG   ,; // 07
                      T_CONSULTA->ZTW_ALTI   ,; // 08
                      T_CONSULTA->ZTW_VELO   }) // 09

      aAdd( aBrowse, {"", "", "", "", "", "", "", "", "" })

      T_CONSULTA->( DbSkip() )
      
   ENDDO

   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "", "", "", "", "", "", "", "" })
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
                         aBrowse[oBrowse:nAt,09] }}

   oBrowse:Refresh()

Return(.T.)