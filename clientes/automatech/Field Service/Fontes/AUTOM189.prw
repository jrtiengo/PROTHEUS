#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM189.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 27/08/2013                                                          *
// Objetivo..: Cadastro de metas por Técnico                                       *
//**********************************************************************************

User Function AUTOM189()   

   Local cGet1	   := Str(year(date()),4)
   Local oGet1

   Private aBrowse := {}

   Private oDlg

   aAdd( aBrowse, {"","","","","","","","","","","","","","","","","","","","","","","","","",""} )
   
   DEFINE MSDIALOG oDlg TITLE "Cadastro metas de Etiquetas por Técnico" FROM C(178),C(181) TO C(565),C(962) PIXEL

   @ C(005),C(005) Say "Ano"             Size C(012),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(004),C(020) MsGet oGet1 Var cGet1 Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(002),C(050) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION( CARREGA_GRID(cGet1) )
   
   @ C(177),C(230) Button "Incluir"   Size C(037),C(012) PIXEL OF oDlg ACTION(PesqMetasTec("I", "", "", ""))
   @ C(177),C(269) Button "Alterar"   Size C(037),C(012) PIXEL OF oDlg ACTION(PesqMetasTec("A", cGet1, aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02]))
   @ C(177),C(308) Button "Excluir"   Size C(037),C(012) PIXEL OF oDlg ACTION(PesqMetasTec("E", cGet1, aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,01]))
   @ C(177),C(347) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 025 , 005, 490, 195,,{'Código', 'Nome dos Técnicos','Jan/Min', 'Jan/Max', 'Fev/Min', 'Fev/Max', 'Mar/Min', 'Mar/Mox', 'Abr/Min', 'Abr/Max', 'Mai/Min', 'Mai/Max', 'Jun/Min', 'Jun/Max', 'Jul/Min', 'Jul/Max', 'Ago/Min', 'Ago/Max', 'Set/Min', 'Set/Max', 'Out/Min', 'Out/Max', 'Nov/Min', 'Nov/Max', 'Dez/Min', 'Dez/Max'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
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
                         aBrowse[oBrowse:nAt,19],;
                         aBrowse[oBrowse:nAt,20],;
                         aBrowse[oBrowse:nAt,21],;
                         aBrowse[oBrowse:nAt,22],;
                         aBrowse[oBrowse:nAt,23],;
                         aBrowse[oBrowse:nAt,24],;
                         aBrowse[oBrowse:nAt,25],;
                         aBrowse[oBrowse:nAt,26]} }

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que carrega o grid
Static Function Carrega_grid(cAno)

   Local cSql := ""
   
   aBrowse := {}
   
   If Empty(Alltrim(cAno))
      MsgAlert("Necessário informar o Ano para realizar a pesquisa.")
      aAdd( aBrowse, {"","","","","","","","","","","","","","","","","","","","","","","","","",""} )      

      // Seta vetor para a browse                            
      oBrowse:SetArray(aBrowse) 
    
      // Monta a linha a ser exibina no Browse
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
                            aBrowse[oBrowse:nAt,19],;
                            aBrowse[oBrowse:nAt,20],;
                            aBrowse[oBrowse:nAt,21],;
                            aBrowse[oBrowse:nAt,22],;
                            aBrowse[oBrowse:nAt,23],;
                            aBrowse[oBrowse:nAt,24],;
                            aBrowse[oBrowse:nAt,25],;
                            aBrowse[oBrowse:nAt,26]} }

      Return(.T.)
   Endif

   If Select("T_PESQUISA") > 0
      T_PESQUISA->( dbCloseArea() )
   EndIf

   cSql := ""  
   cSql := "SELECT A.ZS2_FILIAL,"
   cSql += "       A.ZS2_ANO   ,"
   cSql += "       A.ZS2_TECN  ,"
   cSql += "       B.AA1_NOMTEC,"
   cSql += "       A.ZS2_01M   ,"
   cSql += "       A.ZS2_01X   ,"
   cSql += "       A.ZS2_02M   ,"
   cSql += "       A.ZS2_02X   ,"
   cSql += "       A.ZS2_03M   ,"
   cSql += "       A.ZS2_03X   ,"
   cSql += "       A.ZS2_04M   ,"
   cSql += "       A.ZS2_04X   ,"
   cSql += "       A.ZS2_05M   ,"
   cSql += "       A.ZS2_05X   ,"
   cSql += "       A.ZS2_06M   ,"
   cSql += "       A.ZS2_06X   ,"
   cSql += "       A.ZS2_07M   ,"
   cSql += "       A.ZS2_07X   ,"
   cSql += "       A.ZS2_08M   ,"
   cSql += "       A.ZS2_08X   ,"
   cSql += "       A.ZS2_09M   ,"
   cSql += "       A.ZS2_09X   ,"
   cSql += "       A.ZS2_10M   ,"
   cSql += "       A.ZS2_10X   ,"
   cSql += "       A.ZS2_11M   ,"
   cSql += "       A.ZS2_11X   ,"
   cSql += "       A.ZS2_12M   ,"
   cSql += "       A.ZS2_12X    "
   cSql += "  FROM " + RetSqlName("ZS2") + " A, "
   cSql += "       " + RetSqlName("AA1") + " B  "
   cSql += " WHERE A.ZS2_ANO  = '" + Alltrim(cAno) + "'"
   cSql += "   AND A.ZS2_DELE = ''"
   cSql += "   AND A.ZS2_TECN = B.AA1_CODTEC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PESQUISA", .T., .T. )
   
   If T_PESQUISA->( EOF() )
      MsgAlert("Não exsitem dados a serem visualizados.")
      aAdd( aBrowse, {"","","","","","","","","","","","","","","","","","","","","","","","","",""} )      
   Else
      T_PESQUISA->( DbGoTop() )
      WHILE !T_PESQUISA->( EOF() )
         aAdd( aBrowse, { T_PESQUISA->ZS2_TECN  ,;
                          T_PESQUISA->AA1_NOMTEC,;
                          T_PESQUISA->ZS2_01M   ,;
                          T_PESQUISA->ZS2_01X   ,;
                          T_PESQUISA->ZS2_02M   ,;
                          T_PESQUISA->ZS2_02X   ,;
                          T_PESQUISA->ZS2_03M   ,;
                          T_PESQUISA->ZS2_03X   ,;
                          T_PESQUISA->ZS2_04M   ,;
                          T_PESQUISA->ZS2_04X   ,;
                          T_PESQUISA->ZS2_05M   ,;
                          T_PESQUISA->ZS2_05X   ,;
                          T_PESQUISA->ZS2_06M   ,;
                          T_PESQUISA->ZS2_06X   ,;
                          T_PESQUISA->ZS2_07M   ,;
                          T_PESQUISA->ZS2_07X   ,;
                          T_PESQUISA->ZS2_08M   ,;
                          T_PESQUISA->ZS2_08X   ,;                                                                         
                          T_PESQUISA->ZS2_09M   ,;
                          T_PESQUISA->ZS2_09X   ,;
                          T_PESQUISA->ZS2_10M   ,;
                          T_PESQUISA->ZS2_10X   ,;
                          T_PESQUISA->ZS2_11M   ,;
                          T_PESQUISA->ZS2_11X   ,;
                          T_PESQUISA->ZS2_12M   ,;
                          T_PESQUISA->ZS2_12X   })
         T_PESQUISA->( DbSkip() )
      Enddo
   Endif
                                   
   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
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
                         aBrowse[oBrowse:nAt,19],;
                         aBrowse[oBrowse:nAt,20],;
                         aBrowse[oBrowse:nAt,21],;
                         aBrowse[oBrowse:nAt,22],;
                         aBrowse[oBrowse:nAt,23],;
                         aBrowse[oBrowse:nAt,24],;
                         aBrowse[oBrowse:nAt,25],;
                         aBrowse[oBrowse:nAt,26]} }

Return(.T.)

// Função que pesquisa os dados para o ano selecionado
Static Function PesqMetasTec(__Operacao, __Ano, __Tecnico, __NomeTecnico)

   Local cSql        := ""
   Local lChumba     := .F.
   
   Private cGet1	 := Space(04)
   Private cGet2	 := Space(06)
   Private cGet3	 := Space(40)
   Private cGet4	 := 0
   Private cGet5	 := 0
   Private cGet6	 := 0
   Private cGet7	 := 0
   Private cGet8	 := 0
   Private cGet9	 := 0
   Private cGet10	 := 0
   Private cGet11	 := 0
   Private cGet12	 := 0
   Private cGet13	 := 0
   Private cGet14	 := 0
   Private cGet15	 := 0
   Private cGet16	 := 0
   Private cGet17	 := 0
   Private cGet18	 := 0
   Private cGet19	 := 0
   Private cGet20	 := 0
   Private cGet21	 := 0
   Private cGet23	 := 0
   Private cGet24	 := 0
   Private cGet25	 := 0
   Private cGet26	 := 0
   Private cGet27	 := 0
   Private cGet28	 := 0
   Private cMemo1	 := ""
   Private cMemo2	 := ""
   Private cMemo3	 := ""

   Private oGet1
   Private oGet10
   Private oGet11
   Private oGet12
   Private oGet13
   Private oGet14
   Private oGet15
   Private oGet16
   Private oGet17
   Private oGet18
   Private oGet19
   Private oGet2
   Private oGet20
   Private oGet21
   Private oGet23
   Private oGet24
   Private oGet25
   Private oGet26
   Private oGet27
   Private oGet28
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9
   Private oMemo1
   Private oMemo2
   Private oMemo3

   Private oDlgD

   If __OPeracao <> "I"
      If Select("T_PESQUISA") > 0
         T_PESQUISA->( dbCloseArea() )
      EndIf

      cSql := ""  
      cSql := "SELECT A.ZS2_FILIAL,"
      cSql += "       A.ZS2_ANO   ,"
      cSql += "       A.ZS2_TECN  ,"
      cSql += "       B.AA1_NOMTEC,"
      cSql += "       A.ZS2_01M   ,"
      cSql += "       A.ZS2_01X   ,"
      cSql += "       A.ZS2_02M   ,"
      cSql += "       A.ZS2_02X   ,"
      cSql += "       A.ZS2_03M   ,"
      cSql += "       A.ZS2_03X   ,"
      cSql += "       A.ZS2_04M   ,"
      cSql += "       A.ZS2_04X   ,"
      cSql += "       A.ZS2_05M   ,"
      cSql += "       A.ZS2_05X   ,"
      cSql += "       A.ZS2_06M   ,"
      cSql += "       A.ZS2_06X   ,"
      cSql += "       A.ZS2_07M   ,"
      cSql += "       A.ZS2_07X   ,"
      cSql += "       A.ZS2_08M   ,"
      cSql += "       A.ZS2_08X   ,"
      cSql += "       A.ZS2_09M   ,"
      cSql += "       A.ZS2_09X   ,"
      cSql += "       A.ZS2_10M   ,"
      cSql += "       A.ZS2_10X   ,"
      cSql += "       A.ZS2_11M   ,"
      cSql += "       A.ZS2_11X   ,"
      cSql += "       A.ZS2_12M   ,"
      cSql += "       A.ZS2_12X    "
      cSql += "  FROM " + RetSqlName("ZS2") + " A, "
      cSql += "       " + RetSqlName("AA1") + " B  "
      cSql += " WHERE A.ZS2_ANO  = '" + Alltrim(__Ano)     + "'"
      cSql += "   AND A.ZS2_TECN = '" + Alltrim(__Tecnico) + "'"
      cSql += "   AND A.ZS2_DELE = ''"
      cSql += "   AND A.ZS2_TECN = B.AA1_CODTEC"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PESQUISA", .T., .T. )
      
      cGet1  = T_PESQUISA->ZS2_ANO    
      cGet2  = T_PESQUISA->ZS2_TECN    
      cGet3  = T_PESQUISA->AA1_NOMTEC 
      cGet4  = T_PESQUISA->ZS2_01M    
      cGet5  = T_PESQUISA->ZS2_01X    
      cGet6  = T_PESQUISA->ZS2_02M    
      cGet7  = T_PESQUISA->ZS2_02X    
      cGet8  = T_PESQUISA->ZS2_03M    
      cGet9  = T_PESQUISA->ZS2_03X    
      cGet10 = T_PESQUISA->ZS2_04M    
      cGet11 = T_PESQUISA->ZS2_04X    
      cGet12 = T_PESQUISA->ZS2_05M    
      cGet13 = T_PESQUISA->ZS2_05X    
      cGet14 = T_PESQUISA->ZS2_06M    
      cGet15 = T_PESQUISA->ZS2_06X    
      cGet16 = T_PESQUISA->ZS2_07M    
      cGet23 = T_PESQUISA->ZS2_07X    
      cGet17 = T_PESQUISA->ZS2_08M    
      cGet24 = T_PESQUISA->ZS2_08X    
      cGet18 = T_PESQUISA->ZS2_09M    
      cGet25 = T_PESQUISA->ZS2_09X    
      cGet19 = T_PESQUISA->ZS2_10M    
      cGet26 = T_PESQUISA->ZS2_10X    
      cGet20 = T_PESQUISA->ZS2_11M    
      cGet27 = T_PESQUISA->ZS2_11X    
      cGet21 = T_PESQUISA->ZS2_12M    
      cGet28 = T_PESQUISA->ZS2_12X    
   Endif

   DEFINE MSDIALOG oDlgD TITLE "Metas por Técnico" FROM C(178),C(181) TO C(465),C(582) PIXEL

   @ C(005),C(005) Say "Ano"       Size C(010),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(005),C(028) Say "Técnico"   Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(027),C(005) Say "M e s e s" Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(027),C(046) Say "Mínimo"    Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(027),C(075) Say "Máximo"    Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(027),C(106) Say "M e s e s" Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(027),C(146) Say "Mínimo"    Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(027),C(175) Say "Máximo"    Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(041),C(005) Say "JANEIRO"   Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(041),C(106) Say "JULHO"     Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(054),C(005) Say "FEVEREIRO" Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(054),C(106) Say "AGOSTO"    Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(067),C(005) Say "MARÇO"     Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(067),C(106) Say "SETEMBRO"  Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(080),C(005) Say "ABRIL"     Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(080),C(106) Say "OUTUBRO"   Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(093),C(005) Say "MAIO"      Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(093),C(106) Say "NOVEMBRO"  Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(106),C(005) Say "JUNHO"     Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(106),C(106) Say "DEZEMBRO"  Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlgD

   @ C(035),C(005) GET oMemo1 Var cMemo1 MEMO Size C(088),C(001) PIXEL OF oDlgD
   @ C(035),C(106) GET oMemo2 Var cMemo2 MEMO Size C(087),C(001) PIXEL OF oDlgD
   @ C(120),C(005) GET oMemo3 Var cMemo3 MEMO Size C(188),C(001) PIXEL OF oDlgD
   
   If __Operacao == "I"
      @ C(013),C(005) MsGet oGet1  Var cGet1  Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgD
      @ C(013),C(028) MsGet oGet2  Var cGet2  Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgD F3("AA1") VALID( T_PsqTecnico(cGet2) )
   Else
      @ C(013),C(005) MsGet oGet1  Var cGet1  When lChumba Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgD
      @ C(013),C(028) MsGet oGet2  Var cGet2  When lChumba Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgD
   Endif

   @ C(013),C(055) MsGet oGet3  Var cGet3  When lChumba Size C(138),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgD

   @ C(040),C(046) MsGet oGet4  Var cGet4  Size C(018),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgD
   @ C(040),C(075) MsGet oGet5  Var cGet5  Size C(018),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgD
   @ C(053),C(046) MsGet oGet6  Var cGet6  Size C(018),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgD
   @ C(053),C(075) MsGet oGet7  Var cGet7  Size C(018),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgD
   @ C(066),C(046) MsGet oGet8  Var cGet8  Size C(018),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgD
   @ C(066),C(075) MsGet oGet9  Var cGet9  Size C(018),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgD
   @ C(079),C(046) MsGet oGet10 Var cGet10 Size C(018),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgD
   @ C(079),C(075) MsGet oGet11 Var cGet11 Size C(018),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgD
   @ C(092),C(046) MsGet oGet12 Var cGet12 Size C(018),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgD
   @ C(092),C(075) MsGet oGet13 Var cGet13 Size C(018),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgD
   @ C(105),C(046) MsGet oGet14 Var cGet14 Size C(018),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgD
   @ C(105),C(075) MsGet oGet15 Var cGet15 Size C(018),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgD
   @ C(039),C(146) MsGet oGet16 Var cGet16 Size C(018),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgD
   @ C(039),C(175) MsGet oGet23 Var cGet23 Size C(018),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgD
   @ C(052),C(146) MsGet oGet17 Var cGet17 Size C(018),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgD
   @ C(052),C(175) MsGet oGet24 Var cGet24 Size C(018),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgD
   @ C(065),C(146) MsGet oGet18 Var cGet18 Size C(018),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgD
   @ C(065),C(175) MsGet oGet25 Var cGet25 Size C(018),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgD
   @ C(078),C(146) MsGet oGet19 Var cGet19 Size C(018),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgD
   @ C(078),C(175) MsGet oGet26 Var cGet26 Size C(018),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgD
   @ C(091),C(146) MsGet oGet20 Var cGet20 Size C(018),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgD
   @ C(091),C(175) MsGet oGet27 Var cGet27 Size C(018),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgD
   @ C(104),C(146) MsGet oGet21 Var cGet21 Size C(018),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgD
   @ C(104),C(175) MsGet oGet28 Var cGet28 Size C(018),C(009) COLOR CLR_BLACK Picture "@E 999" PIXEL OF oDlgD

   @ C(126),C(061) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgD ACTION( SalvaMetas( __Operacao) )
   @ C(126),C(100) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgD ACTION( oDlgD:End() )

   ACTIVATE MSDIALOG oDlgD CENTERED 

Return(.T.)

// Função que pesquisa o técnico informado
Static Function T_PsqTecnico(__Tecnico)

   Local cSql := ""

   If Empty(Alltrim(__Tecnico))
      cGet3 := Space(40)
      oget3:Refresh()
      Return .T.        
   Endif
   
   If Select("T_TECNICO") > 0
      T_TECNICO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AA1_CODTEC,"
   cSql += "       AA1_NOMTEC "
   cSql += " FROM " + RetSqlName("AA1")
   cSql += " WHERE AA1_CODTEC = '" + Alltrim(__Tecnico) + "'"
   cSql += "   AND D_E_L_E_T_ = ''  "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TECNICO", .T., .T. )

   If T_TECNICO->( EOF() )
      cGet3 := Space(40)
      oget3:Refresh()   
   Else
      cGet3 := T_TECNICO->AA1_NOMTEC
      oget3:Refresh()   
   Endif

Return(.T.)

// Função que grava os dados informados
Static Function SalvaMetas(__Operacao)

   // Consiste o ano
   If Empty(Alltrim(cGet1))
      MsgAlert("Ano não informado.")
      Return .T.
   Endif
   
   // Consiste o técnico
   If Empty(Alltrim(cGet2))
      MsgAlert("Técnico não informado.")
      Return .T.
   Endif

   // INCLUSÃO
   If __Operacao == "I"
      dbSelectArea("ZS2")
      RecLock("ZS2",.T.)
      ZS2_FILIAL := ""
      ZS2_ANO    := cGet1
      ZS2_TECN   := cGet2
      ZS2_01M    := cGet4
      ZS2_01X    := cGet5
      ZS2_02M    := cGet6
      ZS2_02X    := cGet7
      ZS2_03M    := cGet8
      ZS2_03X    := cGet9
      ZS2_04M    := cGet10
      ZS2_04X    := cGet11
      ZS2_05M    := cGet12
      ZS2_05X    := cGet13
      ZS2_06M    := cGet14
      ZS2_06X    := cGet15
      ZS2_07M    := cGet16
      ZS2_07X    := cGet23
      ZS2_08M    := cGet17
      ZS2_08X    := cGet24
      ZS2_09M    := cGet18
      ZS2_09X    := cGet25
      ZS2_10M    := cGet19
      ZS2_10X    := cGet26
      ZS2_11M    := cGet20
      ZS2_11X    := cGet27
      ZS2_12M    := cGet21
      ZS2_12X    := cGet28
      MsUnLock()
   Endif

   // ALTERAÇÃO
   If __Operacao == "A"
      DbSelectArea("ZS2")
      DbSetOrder(1)
      If DbSeek(xfilial("ZS2") + cGet2 + cGet1)
         RecLock("ZS2",.F.)
         ZS2_01M    := cGet4
         ZS2_01X    := cGet5
         ZS2_02M    := cGet6
         ZS2_02X    := cGet7
         ZS2_03M    := cGet8
         ZS2_03X    := cGet9
         ZS2_04M    := cGet10
         ZS2_04X    := cGet11
         ZS2_05M    := cGet12
         ZS2_05X    := cGet13
         ZS2_06M    := cGet14
         ZS2_06X    := cGet15
         ZS2_07M    := cGet16
         ZS2_07X    := cGet23
         ZS2_08M    := cGet17
         ZS2_08X    := cGet24
         ZS2_09M    := cGet18
         ZS2_09X    := cGet25
         ZS2_10M    := cGet19
         ZS2_10X    := cGet26
         ZS2_11M    := cGet20
         ZS2_11X    := cGet27
         ZS2_12M    := cGet21
         ZS2_12X    := cGet28
         MsUnLock()              
      Endif
   Endif
   
   // EXCLUSÃO
   If __Operacao == "E"

      If MsgYesNo("Confirma a exclusão deste registro?")

         DbSelectArea("ZS2")
         DbSetOrder(1)
         If DbSeek(xfilial("ZS2") + cGet2 + cGet1)
            RecLock("ZS2",.F.)
            ZS2_DELE := "X"
            MsUnLock()              
         Endif
      Endif   

   Endif

   ODlgd:End()      

   CARREGA_GRID(cGet1)
   
Return(.T.)