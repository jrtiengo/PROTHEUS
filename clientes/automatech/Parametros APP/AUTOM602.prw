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
// Referencia: AUTOM602.PRW                                                             ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: (X) Programa  ( ) Gatilho                                                ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                  ##
// Data......: 23/11/2016                                                               ##
// Objetivo..: Controle de Horas Trabalhadas                                            ##
// #######################################################################################

User Function AUTOM602()

   Local cMemo1	   := ""
   Local oMemo1

   Private aFiliais  := {}
   Private aTecnicos := {}

   Private cDtaInicial := Ctod("  /  /    ")
   Private cDtaFinal   := Ctod("  /  /    ")
   Private cNumeroOS   := Space(06)

   Private cComboBx1
   Private cComboBx2
   Private oGet1
   Private oGet2
   Private oGet3
  
   Private aBrowse := {}

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

   DEFINE MSDIALOG oDlg TITLE "Controle de Horas Trabalhadas" FROM C(183),C(002) TO C(632),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlg
   @ C(212),C(128) Jpeg FILE "br_verde"    Size C(010),C(010) PIXEL NOBORDER OF oDlg
   @ C(212),C(176) Jpeg FILE "br_vermelho" Size C(010),C(010) PIXEL NOBORDER OF oDlg
   @ C(212),C(221) Jpeg FILE "br_amarelo"  Size C(010),C(010) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(495),C(001) PIXEL OF oDlg

   @ C(036),C(189) Say "Data Inicial" Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(232) Say "Data Final"   Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(036),C(274) Say "Nº da OS"     Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(005) Say "Filial"       Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(057) Say "Técnico"      Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(212),C(141) Say "Encerrados"   Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(212),C(189) Say "A Encerrar"   Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(212),C(234) Say "Cancelados"   Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(046),C(005) ComboBox cComboBx1 Items aFiliais    Size C(045),C(010)                              PIXEL OF oDlg
   @ C(046),C(057) ComboBox cComboBx2 Items aTecnicos   Size C(126),C(010)                              PIXEL OF oDlg
   @ C(046),C(189) MsGet    oGet1     Var   cDtaInicial Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(232) MsGet    oGet2     Var   cDtaFinal   Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(274) MsGet    oGet3     Var   cNumeroOs   Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(043),C(312) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( PsqHoras(0) )

   @ C(210),C(005) Button "Incluir"   Size C(037),C(012) PIXEL OF oDlg ACTION( ManHoras("I", "", "") )
   @ C(210),C(043) Button "Alterar"   Size C(037),C(012) PIXEL OF oDlg ACTION( ManHoras("A", aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,07]) )
   @ C(210),C(082) Button "Cancelar"  Size C(037),C(012) PIXEL OF oDlg ACTION( ManHoras("E", aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,07]) )
   @ C(210),C(461) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // ###################################
   // Desenha o Grid para visualização ##
   // ###################################
   aAdd( aBrowse, { "7", "", "", "", "", "", "", "", "", "", "", "" })

   oBrowse := TCBrowse():New( 080 , 005, 633, 185,,{'LG'                         ,; // 01
                                                    'FL'                         ,; // 02
                                                    'Nº da OS'                   ,; // 03
                                                    'Cliente'                    ,; // 04
                                                    'Loja'                       ,; // 05
                                                    'Descrição dos Clientes'     ,; // 06
                                                    'Controle'                   ,; // 07 
                                                    'Data Inicial'               ,; // 08
                                                    'Hora Inicial'               ,; // 09
                                                    'Data Final'                 ,; // 10
                                                    'Hora Final'                 ,; // 11
                                                    'Total de Horas'           } ,; // 12
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
                         aBrowse[oBrowse:nAt,12]            }}

   oBrowse:Refresh()

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ################################################################
// Função que pesquisa as horas trabalhasdas conforme parâmetros ##
// ################################################################
Static Function PsqHoras(_TipoPesquisa)

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
   cSql := "SELECT ZTU_FILIAL," 
   cSql += "       ZTU_CONT  ,"
   cSql += "       ZTU_TECN  ,"
   cSql += "	   ZTU_NUMOS ,"
   cSql += "	   ZTU_DINI  ,"
   cSql += "	   ZTU_HINI  ,"
   cSql += "	   ZTU_DFIM  ,"
   cSql += "	   ZTU_HFIM  ,"
   cSql += "       ZTU_HTOT  ,"
   cSql += "	   ZTU_DELE   "
   cSql += "  FROM " + RetSqlName("ZTU")
   cSql += " WHERE ZTU_FILIAL = '" + Substr(cComboBx1,01,02) + "'"
   cSql +="    AND ZTU_TECN   = '" + Substr(cComboBx2,01,06) + "'"
   cSql += "   AND ZTU_DINI  >= CONVERT(DATETIME,'" + Dtoc(cDtaInicial) + "', 103)"
   cSql += "   AND ZTU_DINI  <= CONVERT(DATETIME,'" + Dtoc(cDtaFinal)   + "', 103)"

   If Empty(Alltrim(cNumeroOS)) 
   Else
      cSql += "  AND ZTU_NUMOS = '" + Alltrim(cNumeroOs) + "'"
   Endif                                                                                     

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )

   aBrowse := {}

   __NumeroOS  := T_CONSULTA->ZTU_NUMOS
   __SomaHoras := 0
   __Minutos   := 0
   
   WHILE !T_CONSULTA->( EOF() )

      If T_CONSULTA->ZTU_NUMOS == __NumeroOS

   	     kCodCli  := Posicione("AB6",1, T_CONSULTA->ZTU_FILIAL + T_CONSULTA->ZTU_NUMOS,"AB6_CODCLI")
   	     kCodLoj  := Posicione("AB6",1, T_CONSULTA->ZTU_FILIAL + T_CONSULTA->ZTU_NUMOS,"AB6_LOJA")
         kNomeCli := Posicione("SA1",1, xFilial("SA1") + kCodCli + kCodLoj,"A1_NOME")

         If T_CONSULTA->ZTU_HTOT == "  :  "
            cLegenda := "9"
         Else
            cLegenda := "1"              
         Endif
         
         If T_CONSULTA->ZTU_DELE == "X"  
            cLegenda := "3"                        
         Endif

         xxx_DtaInicial := Substr(T_CONSULTA->ZTU_DINI,07,02) + "/" + Substr(T_CONSULTA->ZTU_DINI,05,02) + "/" + Substr(T_CONSULTA->ZTU_DINI,01,04)
         xxx_DtaFinal   := Substr(T_CONSULTA->ZTU_DFIM,07,02) + "/" + Substr(T_CONSULTA->ZTU_DFIM,05,02) + "/" + Substr(T_CONSULTA->ZTU_DFIM,01,04)

         aAdd( aBrowse, {cLegenda               ,; // 01
                         T_CONSULTA->ZTU_FILIAL ,; // 02
                         T_CONSULTA->ZTU_NUMOS  ,; // 03
                         kCodCli                ,; // 04
                         kcodloj                ,; // 05
                         kNomeCLi               ,; // 06
                         T_CONSULTA->ZTU_CONT   ,; // 07 
                         XXX_DTAINICIAL         ,; // 08
                         T_CONSULTA->ZTU_HINI   ,; // 09
                         XXX_DTAFINAL           ,; // 10
                         T_CONSULTA->ZTU_HFIM   ,; // 11
                         T_CONSULTA->ZTU_HTOT   }) // 12
          
         If T_CONSULTA->ZTU_DELE == "X"
         Else
            __SomaHoras := __SomaHoras + INT(VAL(Substr(T_CONSULTA->ZTU_HTOT,01,02)))
         
            __Minutos   := __Minutos   + INT(VAL(Substr(T_CONSULTA->ZTU_HTOT,04,02)))
         
            If __Minutos >= 60
               __aSomar    := __Minutos - 60
               __SomaHoras := __SomaHoras + 1
               __Minutos   := __aSomar
            Endif

         Endif   

      Else                  
                      
         aAdd( aBrowse, {"", "", "", "", "", "", "", "", "", "", "Total:", Strzero(__SomaHoras,2) + ":" + Strzero(__Minutos,2) })

         aAdd( aBrowse, {"", "", "", "", "", "", "", "", "", "", "", "" })
         
         __NumeroOS  := T_CONSULTA->ZTU_NUMOS
         __SomaHoras := 0
         __Minutos   := 0
         
         Loop
         
      Endif

      T_CONSULTA->( DbSkip() )
      
   ENDDO

   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "", "", "", "", "", "", "", "", "", "", "" })   
   Else
      aAdd( aBrowse, {"", "", "", "", "", "", "", "", "", "", "Total:", Strzero(__SomaHoras,2) + ":" + Strzero(__Minutos,2) })
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
                         aBrowse[oBrowse:nAt,09]            ,;
                         aBrowse[oBrowse:nAt,10]            ,;
                         aBrowse[oBrowse:nAt,11]            ,;
                         aBrowse[oBrowse:nAt,12]            }}

Return(.T.)

// ###############################################################
// Função que abre a janela de manutenção das horas de trabalho ##
// ###############################################################
Static Function ManHoras(_Operacao, _Filial, _Controle)

   Local cSql    := ""

   Local cMemo1	 := ""
   Local cMemo3	 := ""

   Local oMemo1
   Local oMemo3

   Local lChumba        := .F.
   Local lEditar        := .F.

   Private xFiliais     := {}
   Private xTecnico     := Space(06)
   Private xNomeTecnico := Space(60)
   Private xNumeroOS    := Space(06)
   Private xControle    := Space(06)
   Private xDtaInicial  := Ctod("  /  /    ")                                                            	
   Private xHoraInicial := "  :  "
   Private xDtaFinal    := Ctod("  /  /    ")
   Private xHoraFinal   := "  :  "
   Private xHoraTotal   := "  :  "
   Private xCliente     := ""

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9   
   Private oComboBx5
   Private oMemo2

   Private oDlgM

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

   // ####################
   // Carrega variáveis ##
   // ####################
   If _Operacao == "I"
   Else
   
      If Select("T_CONSULTA") > 0
         T_CONSULTA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZTU_FILIAL," 
      cSql += "       ZTU_CONT  ,"
      cSql += "       ZTU_TECN  ,"
      cSql += "	      ZTU_NUMOS ,"
      cSql += "	      ZTU_DINI  ,"
      cSql += "	      ZTU_HINI  ,"
      cSql += "	      ZTU_DFIM  ,"
      cSql += "	      ZTU_HFIM  ,"
      cSql += "       ZTU_HTOT  ,"
      cSql += "	      ZTU_DELE   "
      cSql += "  FROM " + RetSqlName("ZTU")
      cSql += " WHERE ZTU_DELE   = ''"
      cSql += "   AND ZTU_FILIAL = '" + Alltrim(_Filial)   + "'"
      cSql +="    AND ZTU_CONT   = '" + Alltrim(_Controle) + "'" 

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

      If T_CONSULTA->( EOF() )
         MsgAlert("Não existem dados a serem visualizados.")
         Return(.T.)
      Endif
         
      Do Case
         Case cEmpAnt == "01"
              Do Case 
                 Case T_CONSULTA->ZTU_FILIAL = "01"
                      oComboBx5 := "01 - Porto Alegre"
                 Case T_CONSULTA->ZTU_FILIAL = "02"
                      oComboBx5 := "02 - Caxias do Sul"
                 Case T_CONSULTA->ZTU_FILIAL = "03"
                      oComboBx5 := "03 - Pelotas"
                 Case T_CONSULTA->ZTU_FILIAL = "04"
                      oComboBx5 := "04 - Suprimentos"
                 Case T_CONSULTA->ZTU_FILIAL = "05"
                      oComboBx5 := "05 - São Paulo"
                 Case T_CONSULTA->ZTU_FILIAL = "06"
                      oComboBx5 := "06 - Espírito Santo"
                 Case T_CONSULTA->ZTU_FILIAL = "07"
                      oComboBx5 := "07 - Suprimentos(Novo)"
              EndCase
         Case cEmpAnt == "02"
              oComboBx5 := "01 - Curitiba"
         Case cEmpAnt == "03"
              oComboBx5 := "01 - Porto Alegre"
      EndCase        

      xTecnico     := T_CONSULTA->ZTU_TECN
      xNomeTecnico := Posicione( "AA1", 1, xFilial("AA1") + T_CONSULTA->ZTU_TECN, "AA1_NOMTEC" )
      xNumeroOS    := T_CONSULTA->ZTU_NUMOS
      xControle    := T_CONSULTA->ZTU_CONT
      xDtaInicial  := Ctod(Substr(T_CONSULTA->ZTU_DINI,07,02) + "/" + Substr(T_CONSULTA->ZTU_DINI,05,02) + "/" + Substr(T_CONSULTA->ZTU_DINI,01,04))
      xHoraInicial := T_CONSULTA->ZTU_HINI
      xDtaFinal    := Ctod(Substr(T_CONSULTA->ZTU_DFIM,07,02) + "/" + Substr(T_CONSULTA->ZTU_DFIM,05,02) + "/" + Substr(T_CONSULTA->ZTU_DFIM,01,04))
      xHoraFinal   := T_CONSULTA->ZTU_HFIM
      xHoraTotal   := T_CONSULTA->ZTU_HTOT

   	  cCodCli  := Posicione("AB6",1, T_CONSULTA->ZTU_FILIAL + T_CONSULTA->ZTU_NUMOS,"AB6_CODCLI")
   	  cCodLoj  := Posicione("AB6",1, T_CONSULTA->ZTU_FILIAL + T_CONSULTA->ZTU_NUMOS,"AB6_LOJA")
      xCliente := Posicione("SA1",1, xFilial("SA1") + cCodCli + cCodLoj,"A1_NOME")            + CHR(13) + CHR(10) + ;
                  Alltrim(Posicione("SA1",1, xFilial("SA1") + cCodCli + cCodLoj,"A1_BAIRRO")) + CHR(13) + CHR(10) + ;
                  Alltrim(Posicione("SA1",1, xFilial("SA1") + cCodCli + cCodLoj,"A1_MUN"))    + "/"     + ;                      
                  Alltrim(Posicione("SA1",1, xFilial("SA1") + cCodCli + cCodLoj,"A1_EST"))
                      
   Endif
   
   // ########################################
   // Desenha atela para display dos campos ##
   // ########################################
   DEFINE MSDIALOG oDlgM TITLE "Controle de Horas Trabalhadas" FROM C(178),C(181) TO C(462),C(719) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgM

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(261),C(001) PIXEL OF oDlgM
   @ C(120),C(002) GET oMemo3 Var cMemo3 MEMO Size C(261),C(001) PIXEL OF oDlgM
   
   @ C(037),C(005) Say "Nº Controle"      Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(037),C(038) Say "Filial"           Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(038),C(116) Say "Nº da OS"         Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(059),C(005) Say "Técnico"          Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(081),C(005) Say "Dados do Cliente" Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(059),C(187) Say "Data Inicial"     Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(059),C(229) Say "Hora Inicial"     Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(081),C(187) Say "Data Final"       Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(081),C(229) Say "Hora Final"       Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
   @ C(107),C(194) Say "Total Horas"      Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgM
                                
   @ C(046),C(005) MsGet    oGet1     Var   xControle    Size C(031),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgM When lEditar
   @ C(046),C(038) ComboBox oComboBx5 Items xFiliais     Size C(072),C(010)                                    PIXEL OF oDlgM
   @ C(046),C(116) MsGet    oGet4     Var   xNumeroOS    Size C(031),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgM VALID( VeNumOS( oComboBx5, xNumeroOS ) )
   @ C(069),C(005) MsGet    oGet2     Var   xTecnico     Size C(031),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgM F3("AA1") VALID( CataTecnico( xTecnico) )
   @ C(069),C(042) MsGet    oGet3     Var   xNomeTecnico Size C(134),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgM When lChumba
   @ C(091),C(005) GET      oMemo2    Var   xCliente     MEMO Size C(171),C(025)                               PIXEL OF oDlgM When lChumba
   @ C(069),C(187) MsGet    oGet5     Var   xDtaInicial  Size C(036),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgM VALID( xDtaFinal := xDtaInicial ) 
   @ C(069),C(229) MsGet    oGet6     Var   xHoraInicial Size C(036),C(009) COLOR CLR_BLACK Picture "@! XX:XX" PIXEL OF oDlgM VALID( xDifHoras(xHoraInicial, xHoraFinal) )
   @ C(091),C(187) MsGet    oGet7     Var   xDtaFinal    Size C(036),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlgM When lChumba
   @ C(091),C(229) MsGet    oGet8     Var   xHoraFinal   Size C(036),C(009) COLOR CLR_BLACK Picture "@! XX:XX" PIXEL OF oDlgM VALID( xDifHoras(xHoraInicial, xHoraFinal) )
   @ C(106),C(229) MsGet    oGet9     Var   xHoraTotal   Size C(036),C(009) COLOR CLR_BLACK Picture "@! XX:XX" PIXEL OF oDlgM When lChumba

   @ C(125),C(094) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgM ACTION( GrvHorarios(_Operacao) )
   @ C(125),C(133) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgM ACTION( oDlgM:End() )

   ACTIVATE MSDIALOG oDlgM CENTERED 

Return(.T.)

// #############################################################
// Função que pesquisa os dados da Ordem de Serviço informada ##
// #############################################################
Static Function VeNumOS( oComboBx5, xNumeroOS )

   If Substr(oComboBx5,01,02) == "00"
      xNumeroOS := Space(06)
      xCliente  := ""
      oGet4:Refresh()
      oMemo2:Refresh()
      Return(.T.)
   Endif
   
   If Empty(Alltrim(xNumeroOS))
      xNumeroOS := Space(06)
      xCliente  := ""
      oGet4:Refresh()
      oMemo2:Refresh()
      Return(.T.)
   Endif

   DBSelectArea("AB6")     
   DbSetOrder(1)
   If DbSeek( Substr(oComboBx5,01,02) + xNumeroOS)
      kCodCli  := AB6->AB6_CODCLI
      kCodLoj  := AB6->AB6_LOJA
      xCliente := Posicione("SA1",1, xFilial("SA1") + kCodCli + kCodLoj,"A1_NOME")            + CHR(13) + CHR(10) + ;
                  Alltrim(Posicione("SA1",1, xFilial("SA1") + kCodCli + kCodLoj,"A1_BAIRRO")) + CHR(13) + CHR(10) + ;
                  Alltrim(Posicione("SA1",1, xFilial("SA1") + kCodCli + kCodLoj,"A1_MUN"))    + "/"     + ;                      
                  Alltrim(Posicione("SA1",1, xFilial("SA1") + kCodCli + kCodLoj,"A1_EST"))
   Else
      MsgAlert("Ordem de serviço informada não localizada.")
      xNumeroOS := Space(06)
      xCliente  := ""
      oGet4:Refresh()
      oMemo2:Refresh()
   Endif

Return(.T.)

// #################################################
// Função que pesquisa dados do técnico informado ##
// #################################################
Static Function CataTecnico( xTecnico)

   If Empty(Alltrim(xTecnico))
      xTecnico     := Space(06)
      xNomeTecnico := Space(60)
      oGet2:refresh()
      oGet3:Refresh()
      Return(.T.)
   Endif

   xNomeTecnico := ""
   xNomeTecnico := POSICIONE("AA1",1, xFilial("AA1") + xTecnico,"AA1_NOMTEC")

   If Empty(Alltrim(xNomeTecnico))
      MsgAlert("Técnico informado não cadastrado.")
      xTecnico     := Space(06)
      xNomeTecnico := Space(60)
      oGet2:refresh()
      oGet3:Refresh()
   Endif   
   
Return(.T.)   

// #######################################################################
// Função que calcula a direfença de horas entre a hora inicial e final ##
// #######################################################################
Static Function xDifHoras(_HoraInicial, _HoraFinal)

    If _HoraInicial == "  :  "
       xHoraTotal := "  :  "
       oGet9:Refresh()       
       Return(.T.)
    Endif
       
    If _HoraFinal == "  :  "
       xHoraTotal := "  :  "
       oGet9:Refresh()       
       Return(.T.)
    Endif

    If xHoraInicial > xHorafinal
       MsgAlert("Horário informado inválido.")
       Return(.T.)
    Endif

    xHoraTotal := ElapTime( _HoraInicial + ":00", _HoraFinal + ":00" ) 
    oGet9:Refresh()

Return

// #############################################
// Função que grava os dados na tabela ZTU010 ##
// #############################################
Static Function GrvHorarios(_Operacao)

   Local cSql := ""

   // #################################################
   // Gera consistências dos dados antes da gravação ##
   // #################################################
   If Substr(oComboBx5,01,02) == "00"
      MsgAlert("Filial não selecionada.")
      Return(.T.)
   Endif

   If Empty(Alltrim(xNumeroOs))
      MsgAlert("Nº da OS não informada.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(xTecnico))
      MsgAlert("Técnico não informado.")
      Return(.T.)
   Endif
   
   If xDtaInicial == Ctod("  /  /    ")
      MsgAlert("Data inicial não informada.")
      Return(.T.)
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
      cSql := "SELECT TOP(1) ZTU_CONT"
      cSql += "  FROM " + RetSqlName("ZTU")
      cSql += " WHERE ZTU_FILIAL = '" + Alltrim(Substr(oComboBx5,01,02)) + "'"
      cSql += "   AND ZTU_DELE   = ''"
      cSql += " ORDER BY ZTU_CONT DESC"
   
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

      xControle := IIF(T_PROXIMO->( EOF() ), "000001", Strzero((INT(VAL(T_PROXIMO->ZTU_CONT)) + 1),6))

      dbSelectArea("ZTU")
      RecLock("ZTU",.T.)
      ZTU_FILIAL := Substr(oComboBx5,01,02)
      ZTU_CONT   := xControle
      ZTU_NUMOS  := xNumeroOS
      ZTU_TECN   := xTecnico
      ZTU_DINI   := xDtaInicial
      ZTU_HINI   := xHoraInicial
      ZTU_DFIM   := xDtaFinal
      ZTU_HFIM   := xHoraFinal
      ZTU_HTOT   := xHoraTotal
      ZTU_DELE   := ""
      MsUnLock()
      
   Endif   

   // ########################
   // Alteração do Registro ##
   // ########################
   If _Operacao == "A"

      DbSelectArea("ZTU")
      DbSetOrder(1)
      If DbSeek(Substr(oComboBx5,01,02) + xControle)
         RecLock("ZTU",.F.)
         ZTU_NUMOS  := xNumeroOS
         ZTU_TECN   := xTecnico
         ZTU_DINI   := xDtaInicial
         ZTU_HINI   := xHoraInicial
         ZTU_DFIM   := xDtaFinal
         ZTU_HFIM   := xHoraFinal
         ZTU_HTOT   := xHoraTotal
         ZTU_DELE   := ""
         MsUnLock()
      Endif
      
   Endif
     
   // #######################
   // Exclusão do Registro ##
   // #######################
   If _Operacao == "E"

      DbSelectArea("ZTU")
      DbSetOrder(1)
      If DbSeek(Substr(oComboBx5,01,02) + xControle)
         RecLock("ZTU",.F.)
         ZTU_DELE   := "X"
         MsUnLock()
      Endif
      
   Endif

   oDlgM:End()

   // ################################################################
   // Envia para a função que carrega o grid principal para display ##
   // ################################################################
   PsqHoras(1)
    
Return(.T.)