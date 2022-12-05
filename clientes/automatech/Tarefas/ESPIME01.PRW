#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPIME01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 22/07/2014                                                          *
// Objetivo..: Programa de Tarefas Imediatas                                       *
//**********************************************************************************

User Function ESPIME01()

   Local cSql        := ""
   Local lChumba     := .F.
   Local cMemo1	     := ""
   Local oMemo1

   Private lLiberado := .T.
   Private lSetor01  := .F.
   Private lSetor02  := .F.

   Private aStatus	 := {"00 - Todos os Status" , "02 - A Realizar", "06 - Em Desenvolvimneto", "08 - Realizadas", "XX - Canceladas", "NF - Na Fila"}
   Private aUsuario  := {}
   Private aSetores  := {"00 - Todos os Setores", "01 - Projetos"  , "02 - TI"} 

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3

   Private nTotVerde    := 0
   Private nTotLaranja  := 0
   Private nTotVermelho := 0
   Private nTotCancel   := 0 

   Private dInicial 	:= Ctod("01/01/" + Strzero(year(Date()),6))
   Private dFinal       := Ctod("31/12/" + Strzero(year(Date()),6))

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6   

   Private aBrowse := {}

   // Declara as Legendas
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

   // Carrega o combo de usuarios
   If Select("T_USUARIO") > 0
      T_USUARIO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZA_CODI, "
   cSql += "       ZZA_NOME, "
   cSql += "       ZZA_EMAI  "
   cSql += "  FROM " + RetSqlName("ZZA")
   cSql += " WHERE D_E_L_E_T_ = ''"
   cSql += " ORDER BY ZZA_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIO", .T., .T. )

   // Carrega o Combo dos Usuários do Sistema
   aAdd( aUsuario, "Todos os Usuários" )
   T_USUARIO->( EOF() )
   WHILE !T_USUARIO->( EOF() )
      aAdd( aUsuario, T_USUARIO->ZZA_NOME )
      T_USUARIO->( DbSkip() )
   ENDDO

   // Envia para a função que carrega o grid da tela
   PesqImediatas(1)

   If !lLiberado
      Return(.T.)
   Endif

   // Carrega o array de setores
   If lSetor01 .And. lSetor02
      aSetores  := {"00 - Todos os Setores", "01 - Projetos"  , "02 - TI"}    
   Endif
      
   If lSetor01 .And. !lSetor02
      aSetores  := {"01 - Projetos"}    
   Endif

   If !lSetor01 .And. lSetor02
      aSetores  := {"02 - TI"}    
   Endif

   // Desenha tela de manutenção dos dados das tarefas de solução imediata
   DEFINE MSDIALOG oDlg TITLE "Tarefas de Solução Imediata" FROM C(178),C(181) TO C(598),C(933) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp"        Size C(162),C(026) PIXEL NOBORDER OF oDlg
   @ C(165),C(048) Jpeg FILE "br_verde"              Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(176),C(048) Jpeg FILE "br_laranja"            Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(186),C(048) Jpeg FILE "br_vermelho"           Size C(009),C(009) PIXEL NOBORDER OF oDlg
   @ C(197),C(048) Jpeg FILE "br_cancel"             Size C(009),C(009) PIXEL NOBORDER OF oDlg

   @ C(031),C(002) GET oMemo1 Var cMemo1 MEMO         Size C(370),C(001) PIXEL OF oDlg

   @ C(023),C(286) Say "TAREFAS SOLUÇÕES IMEDIATAS"   Size C(087),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(005) Say "Dta Inicial"                  Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(046) Say "Dta Final"                    Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(089) Say "Status"                       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(184) Say "Usuários"                     Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(265) Say "Setor"                        Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(056),C(005) Say "Relação de solicitações"      Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(166),C(061) Say "Tarefas a serem realizadas"   Size C(064),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(177),C(061) Say "Total em Desenvolvimento"     Size C(064),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(186),C(061) Say "Tarefas Realizadas"           Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(197),C(062) Say "Tarefas Canceladas"           Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(044),C(005) MsGet oGet3 Var dInicial           Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(044),C(047) MsGet oGet4 Var dFinal             Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(044),C(089) ComboBox cComboBx1 Items aStatus   Size C(090),C(010)                              PIXEL OF oDlg
   @ C(044),C(184) ComboBox cComboBx2 Items aUsuario  Size C(075),C(010)                              PIXEL OF oDlg
   @ C(044),C(265) ComboBox cComboBx3 Items aSetores  Size C(064),C(010)                              PIXEL OF oDlg

   @ C(041),C(335) Button "Atualizar"                 Size C(037),C(012)                              PIXEL OF oDlg ACTION( PesqImediatas(2) )
   
   @ C(165),C(129) MsGet oGet1 Var nTotVerde          Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(176),C(129) MsGet oGet6 Var nTotLaranja        Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(187),C(129) MsGet oGet2 Var nTotVermelho       Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(198),C(129) MsGet oGet5 Var nTotCancel         Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   
   @ C(179),C(006) Button "Detalhe"                       Size C(037),C(012) PIXEL OF oDlg ACTION(Detalhe_Imediata(aBrowse[oBrowse:nAt,02]))
   @ C(165),C(156) Button "Abre Horário"                  Size C(047),C(012) PIXEL OF oDlg ACTION(AbrFecHoras(1, aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,06], aBrowse[oBrowse:nAt,08], aBrowse[oBrowse:nAt,09], aBrowse[oBrowse:nAt,10], aBrowse[oBrowse:nAt,11], aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,05] ) )
   @ C(165),C(205) Button "Fecha Horário"                 Size C(047),C(012) PIXEL OF oDlg ACTION(AbrFecHoras(2, aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,06], aBrowse[oBrowse:nAt,08], aBrowse[oBrowse:nAt,09], aBrowse[oBrowse:nAt,10], aBrowse[oBrowse:nAt,11], aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,05] ) )
   @ C(180),C(156) Button "Consulta Horário Fechado"      Size C(097),C(012) PIXEL OF oDlg ACTION(AbrFecHoras(3, aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,06], aBrowse[oBrowse:nAt,08], aBrowse[oBrowse:nAt,09], aBrowse[oBrowse:nAt,10], aBrowse[oBrowse:nAt,11], aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,05] ) )
   @ C(194),C(156) Button "Troca Área de Desenvolvimento" Size C(097),C(012) PIXEL OF oDlg ACTION(Troca_Setor(aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,13], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,06]))
   @ C(173),C(265) Button "Cancela Tarefa"                Size C(060),C(012) PIXEL OF oDlg ACTION(Cancela_Imediata(aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,06]))
   @ C(187),C(265) Button "Transfere Horário Extra"       Size C(060),C(012) PIXEL OF oDlg ACTION(transf_horas() )
   @ C(179),C(335) Button "Voltar"                        Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 080 , 005, 470, 123,,{'', 'Código', 'Data','Hora', 'Solicitante', 'Título', 'Realizado Por', 'Data I', 'Hora I','Data F','Hora F','Tempo'}, {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 

   // Monta a linha a ser exibina no Browse
   If Len(aBrowse) == 0
   Else
      oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oPink    ,;                         
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho,;
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                            aBrowse[oBrowse:nAt,02]               ,;
                            aBrowse[oBrowse:nAt,03]               ,;
                            aBrowse[oBrowse:nAt,04]               ,;                         
                            aBrowse[oBrowse:nAt,05]               ,;                         
                            aBrowse[oBrowse:nAt,06]               ,;                         
                            aBrowse[oBrowse:nAt,07]               ,;                         
                            aBrowse[oBrowse:nAt,08]               ,;                         
                            aBrowse[oBrowse:nAt,09]               ,;                         
                            aBrowse[oBrowse:nAt,10]               ,;                         
                            aBrowse[oBrowse:nAt,11]               ,;                                                     
                            aBrowse[oBrowse:nAt,12]               }}
   Endif

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Pesquisa as tarefas para popular o Grid
Static Function PesqImediatas(_Tipo)

   Local cSql := ""

   aBrowse := {}

   If Empty(dInicial)
      dInicial := Ctod("01/01/" + Strzero(year(Date()),6))
   Endif
   
   If Empty(dFinal)
      dFinal   := Ctod("31/12/" + Strzero(year(Date()),6))
   Endif

   // Libera inicialmente o processo para o usuário
   lLiberado := .T.
   lSetor01  := .F.
   lSetor02  := .F.

   // Verifica o tipo de tarefas de solução imediata que o usuário pode visualizar
   If Select("T_USUARIO") > 0
      T_USUARIO->( dbCloseArea() )
   EndIf

   cSql := "SELECT ZZE_CODIGO,"
   cSql += "       ZZE_NOME  ,"
   cSql += "       ZZE_LOGIN ,"
   cSql += "       ZZE_IMEDI ,"
   cSql += "       ZZE_PROJE ,"
   cSql += "       ZZE_TECNI  "
   cSql += "  FROM " + RetSqlName("ZZE")
   cSql += " WHERE ZZE_DELETE = ''"
   cSql += "   AND RTRIM(UPPER(ZZE_LOGIN)) = '" + Alltrim(Upper(cUserName)) + "'"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIO", .T., .T. )

   If T_USUARIO->( EOF() )
      MsgAlert("Atenção! Você não possui acesso liberado para executar este programa.")
      lLiberado := .F.
      Return(.T.)
   Endif
      
   If T_USUARIO->ZZE_IMEDI <> "T"
      MsgAlert("Atenção! Você não possui acesso liberado para executar este programa.")
      lLiberado := .F.
      Return(.T.)
   Endif

   // Usuário tem acesso ao setor Projetos
   If T_USUARIO->ZZE_PROJE == "T"
      lSetor01 := .T.
   Endif
      
   // Usuário tem acesso ao setor TI
   If T_USUARIO->ZZE_TECNI == "T"
      lSetor02 := .T.
   Endif

   // Pesquisa as tarefas de solução imediata
   If Select("T_TAREFAS") > 0
      T_TAREFAS->( dbCloseArea() )
   EndIf

   cSql := "SELECT ZT1_FILIAL,"
   cSql += "       ZT1_CODI  ,"
   cSql += "       ZT1_DATA  ,"
   cSql += "       ZT1_HORA  ,"
   cSql += "       ZT1_SOLI  ,"
   cSql += "       ZT1_TITU  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT1_DESC)) AS DESCRICAO,"
   cSql += "       ZT1_DTAI  ,"
   cSql += "       ZT1_HRSI  ,"
   cSql += "       ZT1_DTAF  ,"
   cSql += "       ZT1_HRSF  ,"
   cSql += "       ZT1_TEMP  ,"
   cSql += "       ZT1_RESP  ,"
   cSql += "       ZT1_DELE  ,"
   cSql += "       ZT1_STAT  ,"
   cSql += "       ZT1_TRTI   "
   cSql += "  FROM " + RetSqlName("ZT1")
   cSql += " WHERE ZT1_DELE  = ''"
   cSql += "   AND ZT1_DATA  >= CONVERT(DATETIME,'" + Dtoc(dInicial) + "', 103)"
   cSql += "   AND ZT1_DATA  <= CONVERT(DATETIME,'" + Dtoc(dFinal)   + "', 103)"

   // Filtra pelo tipo de visualização que o usuário pode visualizar
   Do Case
      Case T_USUARIO->ZZE_PROJE == "T" .And. T_USUARIO->ZZE_TECNI <> "T"
           cSql += "   AND ZT1_TRTI <> 'T'"

      Case T_USUARIO->ZZE_PROJE <> "T" .And. T_USUARIO->ZZE_TECNI == "T"   
           cSql += "   AND ZT1_TRTI = 'T'"
   EndCase

   // Filtra por Status
   If _Tipo == 1
   Else
      // Filtra pelo Setor da Tarefa de Solução Imediata
      If Substr(cComboBx3,01,02) <> "00"
         If T_USUARIO->ZZE_PROJE == "T" .And. T_USUARIO->ZZE_TECNI == "T"
            Do Case
               Case Substr(cComboBx3,01,02) == "01"
                    cSql += " AND ZT1_TRTI = 'F'"
               Case Substr(cComboBx3,01,02) == "02"
                    cSql += " AND ZT1_TRTI = 'T'"         
            EndCase
         Else
            If T_USUARIO->ZZE_PROJE == "T" 
               cSql += " AND ZT1_TRTI = 'F'"
            Endif
            
            If T_USUARIO->ZZE_TECNI == "T"         
               cSql += " AND ZT1_TRTI = 'T'"
            Endif   
         Endif   
      Endif

      // Filtra por Status
      If Substr(cComboBx1,01,02) <> "00"
         Do Case
            Case Substr(cComboBx1,01,02) == "02"
                 cSql += " AND ZT1_STAT = '2'"
            Case Substr(cComboBx1,01,02) == "06"
                 cSql += " AND ZT1_STAT = '6'"         
            Case Substr(cComboBx1,01,02) == "08"
                 cSql += " AND ZT1_STAT = '8'"         
            Case Substr(cComboBx1,01,02) == "XX"
                 cSql += " AND ZT1_STAT = 'X'"         
            Case Substr(cComboBx1,01,02) == "NF"
                 cSql += " AND ZT1_STAT IN ('2','6')"
         EndCase
      Endif

      // Filtra por Usuários
      If Alltrim(cComboBx2) <> "Todos os Usuários"
         cSql += " AND ZT1_SOLI = '" + Alltrim(cComboBx2) + "'"
      Endif

   Endif

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAREFAS", .T., .T. )

   nTotVerde    := 0
   nTotVermelho := 0

   WHILE !T_TAREFAS->( EOF() )
      aAdd( aBrowse, {T_TAREFAS->ZT1_STAT,;
                      T_TAREFAS->ZT1_CODI,;
                      Substr(T_TAREFAS->ZT1_DATA,7,2) + "/" + Substr(T_TAREFAS->ZT1_DATA,5,2) + "/" + Substr(T_TAREFAS->ZT1_DATA,1,4),;
                      T_TAREFAS->ZT1_HORA,;
                      T_TAREFAS->ZT1_SOLI,;
                      T_TAREFAS->ZT1_TITU,;
                      T_TAREFAS->ZT1_RESP,;
                      Substr(T_TAREFAS->ZT1_DTAI,7,2) + "/" + Substr(T_TAREFAS->ZT1_DTAI,5,2) + "/" + Substr(T_TAREFAS->ZT1_DTAI,1,4),;
                      T_TAREFAS->ZT1_HRSI,;
                      Substr(T_TAREFAS->ZT1_DTAF,7,2) + "/" + Substr(T_TAREFAS->ZT1_DTAF,5,2) + "/" + Substr(T_TAREFAS->ZT1_DTAF,1,4),;
                      T_TAREFAS->ZT1_HRSF,;
                      T_TAREFAS->ZT1_TEMP,;
                      T_TAREFAS->ZT1_TRTI})

      Do Case
         Case T_TAREFAS->ZT1_STAT = "2"
              nTotVerde    := nTotVerde + 1
         Case T_TAREFAS->ZT1_STAT = "6"
              nTotLaranja  := nTotLaranja + 1
         Case T_TAREFAS->ZT1_STAT = "8"
              nTotVermelho := nTotVermelho + 1
         Case T_TAREFAS->ZT1_STAT = "X"
              nTotCancel   := nTotCancel + 1
      EndCase

      T_TAREFAS->( DbSkip() )

   ENDDO
                            
   If Len(aBrowse) == 0
      aAdd( aBrowse, { '1', '', '', '', '', '', '', '', '', '', '', '' } )
      If _Tipo == 1
         Return(.T.)
      Endif   
   Endif
      
   If _Tipo == 1
      Return(.T.)
   Endif
 
   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 

   // Monta a linha a ser exibina no Browse
   If Len(aBrowse) == 0
   Else
      oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oPink    ,;                         
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho,;
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "X", oCancel  ,;                                                
                            If(Alltrim(aBrowse[oBrowse:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                            aBrowse[oBrowse:nAt,02]               ,;
                            aBrowse[oBrowse:nAt,03]               ,;
                            aBrowse[oBrowse:nAt,04]               ,;                         
                            aBrowse[oBrowse:nAt,05]               ,;                         
                            aBrowse[oBrowse:nAt,06]               ,;                         
                            aBrowse[oBrowse:nAt,07]               ,;                         
                            aBrowse[oBrowse:nAt,08]               ,;                         
                            aBrowse[oBrowse:nAt,09]               ,;                         
                            aBrowse[oBrowse:nAt,10]               ,;                         
                            aBrowse[oBrowse:nAt,11]               ,;                                                     
                            aBrowse[oBrowse:nAt,12]               }}
   Endif
   
Return(.T.)

// Abre tela de Abertura/fechamento  de solução da tarefa
Static Function AbrFecHoras(_Tipo, _Codigo, _Titulo, _DataInicial, _HoraInicial, _DataFinal, _HoraFinal, _Status, _Solicitante)

   Local lChumba     := .F.

   Local xTipo       := _Tipo
   Local xCodigo     := _Codigo
   Local xTitulo     := _Titulo
   Local xDataI      := Ctod("  /  /    ")
   Local xHoraI      := "  :  :  "
   Local xDataF      := Ctod("  /  /    ")
   Local xHoraF      := "  :  :  " 
   Local cMemo1	     := ""
   Local cObservacao := ""

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5
   Local oGet6
   Local oMemo1
   Local oMemo2

   Do Case
      Case _Tipo == 1
           xDataI  := Date()
           xHoraI  := Time()
           xDataF  := Ctod("  /  /    ")
           xHoraF  := "  :  :  "

      Case _Tipo == 2
           xDataI  := _DataInicial
           xHoraI  := _HoraInicial
           xDataF  := Date()
           xHoraF  := Time()

      Case _Tipo == 3
           // Pesquisa as tarefas de solução imediata
           If Select("T_TAREFAS") > 0
              T_TAREFAS->( dbCloseArea() )
           EndIf

           cSql := "SELECT ZT1_FILIAL,"
           cSql += "       ZT1_CODI  ,"
           cSql += "       ZT1_DATA  ,"
           cSql += "       ZT1_HORA  ,"
           cSql += "       ZT1_SOLI  ,"
           cSql += "       ZT1_TITU  ,"
           cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT1_DESC)) AS DESCRICAO ,"
           cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT1_OBSE)) AS OBSERVACAO,"
           cSql += "       ZT1_DTAI  ,"
           cSql += "       ZT1_HRSI  ,"
           cSql += "       ZT1_DTAF  ,"
           cSql += "       ZT1_HRSF  ,"
           cSql += "       ZT1_TEMP  ,"
           cSql += "       ZT1_RESP  ,"
           cSql += "       ZT1_DELE  ,"
           cSql += "       ZT1_STAT  ,"
           cSql += "       ZT1_TRTI   "
           cSql += "  FROM " + RetSqlName("ZT1")
           cSql += " WHERE ZT1_DELE = ''"
           cSql += "   AND ZT1_CODI = '" + Alltrim(_Codigo) + "'"

           cSql := ChangeQuery( cSql )
           dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAREFAS", .T., .T. )

           xDataI      := T_TAREFAS->ZT1_DTAI
           xHoraI      := T_TAREFAS->ZT1_HRSI
           xDataF      := T_TAREFAS->ZT1_DTAF
           xHoraF      := T_TAREFAS->ZT1_HRSF
           cObservacao := T_TAREFAS->OBSERVACAO
   EndCase

   // Captura as observações para display/alteração da tarefa de solução imediata
   If Select("T_TAREFAS") > 0
      T_TAREFAS->( dbCloseArea() )
   EndIf

   cSql := "SELECT CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT1_OBSE)) AS OBSERVACAO"
   cSql += "  FROM " + RetSqlName("ZT1")
   cSql += " WHERE ZT1_DELE = ''"
   cSql += "   AND ZT1_CODI = '" + Alltrim(_Codigo) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAREFAS", .T., .T. )

   cObservacao := T_TAREFAS->OBSERVACAO

   If _Tipo <> 3
      If _Status == "8"
         MsgAlert("Tarefa já encerrada.")
         Return(.T.)
      Endif
   Endif   

   Private oDlgH

   DEFINE MSDIALOG oDlgH TITLE "Abertura/Fechamento de Data/Horário" FROM C(178),C(181) TO C(544),C(663) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(150),C(026) PIXEL NOBORDER OF oDlgH

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(235),C(001) PIXEL OF oDlgH

   @ C(038),C(005) Say "Código"             Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgH
   @ C(038),C(034) Say "Título"             Size C(016),C(008) COLOR CLR_BLACK PIXEL OF oDlgH
   @ C(065),C(034) Say "Data Abertura"      Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlgH
   @ C(065),C(083) Say "Hora Abertura"      Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgH
   @ C(065),C(133) Say "Data Fechamento"    Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlgH
   @ C(065),C(182) Say "Hora Fechamento"    Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgH
   @ C(087),C(034) Say "Observações Gerais" Size C(049),C(008) COLOR CLR_BLACK PIXEL OF oDlgH
	
   @ C(048),C(005) MsGet oGet1 Var xCodigo Size C(023),C(009) COLOR CLR_BLACK Picture "@!"             PIXEL OF oDlgH When lChumba
   @ C(048),C(034) MsGet oGet2 Var xTitulo Size C(202),C(009) COLOR CLR_BLACK Picture "@!"             PIXEL OF oDlgH When lChumba
 
   Do Case 
      Case _Tipo == 1
           @ C(075),C(034) MsGet oGet3 Var xDataI  Size C(040),C(009) COLOR CLR_BLACK Picture "@!"          PIXEL OF oDlgH
           @ C(075),C(083) MsGet oGet4 Var xHoraI  Size C(033),C(009) COLOR CLR_BLACK Picture "@! XX:XX:XX" PIXEL OF oDlgH
           @ C(075),C(133) MsGet oGet5 Var xDataF  Size C(040),C(009) COLOR CLR_BLACK Picture "@!"          PIXEL OF oDlgH When lChumba
           @ C(075),C(182) MsGet oGet6 Var xHoraF  Size C(033),C(009) COLOR CLR_BLACK Picture "@! XX:XX:XX" PIXEL OF oDlgH When lChumba

      Case _Tipo == 2
           @ C(075),C(034) MsGet oGet3 Var xDataI  Size C(040),C(009) COLOR CLR_BLACK Picture "@!"          PIXEL OF oDlgH When lChumba
           @ C(075),C(083) MsGet oGet4 Var xHoraI  Size C(033),C(009) COLOR CLR_BLACK Picture "@! XX:XX:XX" PIXEL OF oDlgH When lChumba
           @ C(075),C(133) MsGet oGet5 Var xDataF  Size C(040),C(009) COLOR CLR_BLACK Picture "@!"          PIXEL OF oDlgH
           @ C(075),C(182) MsGet oGet6 Var xHoraF  Size C(033),C(009) COLOR CLR_BLACK Picture "@! XX:XX:XX" PIXEL OF oDlgH

      Case _Tipo == 3
           @ C(075),C(034) MsGet oGet3 Var xDataI  Size C(040),C(009) COLOR CLR_BLACK Picture "@!"          PIXEL OF oDlgH When lChumba
           @ C(075),C(083) MsGet oGet4 Var xHoraI  Size C(033),C(009) COLOR CLR_BLACK Picture "@! XX:XX:XX" PIXEL OF oDlgH When lChumba
           @ C(075),C(133) MsGet oGet5 Var xDataF  Size C(040),C(009) COLOR CLR_BLACK Picture "@!"          PIXEL OF oDlgH When lChumba
           @ C(075),C(182) MsGet oGet6 Var xHoraF  Size C(033),C(009) COLOR CLR_BLACK Picture "@! XX:XX:XX" PIXEL OF oDlgH When lChumba
   EndCase

   If _Tipo <> 3
      @ C(096),C(034) GET oMemo2 Var cObservacao MEMO Size C(202),C(064) PIXEL OF oDlgH
   Else
      @ C(096),C(034) GET oMemo2 Var cObservacao MEMO Size C(202),C(064) PIXEL OF oDlgH When lChumba      
   Endif

   If _Tipo <> 3
      @ C(165),C(082) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgH ACTION( SalvaHorasX(xTipo, xCodigo, xDataI, xHoraI, xDataF, xHoraF, _Solicitante, cObservacao))
   Endif

   @ C(165),C(121) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgH ACTION( oDlgH:End() )

   ACTIVATE MSDIALOG oDlgH CENTERED 

Return(.T.)
 
// Função que salva os horários
Static Function SalvaHorasX(_Tipo, _Codigo, _DataI, _HoraI, _DataF, _HoraF, _Solicitante, _Observacao)
                                                              
   aArea := GetArea()

   DbSelectArea("ZT1")
   DbSetOrder(1)
   If DbSeek(xfilial("ZT1") + _Codigo)
      RecLock("ZT1",.F.)
      If _Tipo == 1
         ZT1_DTAI := _DataI
         ZT1_HRSI := _HoraI
      Else
         ZT1_DTAF := _DataF
         ZT1_HRSF := _HoraF
         ZT1_TEMP := ElapTime( Alltrim(_HoraI), Alltrim(_HoraF) )
      Endif   
      ZT1_RESP := cUserName
      ZT1_STAT := IIF(_Tipo == 1, "6", "8")
      ZT1_OBSE := _Observacao
      MsUnLock()              
   Endif
 
   // Se for fechamento, envia e-mail ao usuário de aviso de fechamento da tarefa de solução imediata
   If _Tipo == 2
   
      // Inicializa a variável que conterá o e-mail do Usuário dono da Tarefa
      c_Email := ""

      // Envia e-mail aos desenvolvedores para assumir a tarefa incluída
      If Select("T_AVISO") > 0
         T_AVISO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZA_CODI,"
      cSql += "       ZZA_NOME,"
      cSql += "       ZZA_EMAI "
      cSql += "  FROM " + RetSqlName("ZZA")
      cSql += " WHERE D_E_L_E_T_ = ''"
      cSql += "   AND RTRIM(UPPER(ZZA_NOME)) = '" + Alltrim(Upper(_Solicitante)) + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AVISO", .T., .T. )

      If !T_AVISO->( EOF() )

         c_Email := Alltrim(T_AVISO->ZZA_EMAI)
            
         // Pesquisa detalhes da tarefa para preencher o e-mail ao usuário solicitante
         If Select("T_TAREFAS") > 0
            T_TAREFAS->( dbCloseArea() )
         EndIf

         cSql := "SELECT ZT1_FILIAL,"
         cSql += "       ZT1_CODI  ,"
         cSql += "       SUBSTRING(ZT1_DATA,07,02) + '/' + SUBSTRING(ZT1_DATA,05,02) + '/' + SUBSTRING(ZT1_DATA,01,04) AS ABERTURA,"
         cSql += "       ZT1_HORA  ,"
         cSql += "       ZT1_SOLI  ,"
         cSql += "       ZT1_TITU  ,"
         cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT1_DESC)) AS DESCRICAO,"
         cSql += "       ZT1_DTAI  ,"
         cSql += "       ZT1_HRSI  ,"
         cSql += "       ZT1_DTAF  ,"
         cSql += "       ZT1_HRSF  ,"
         cSql += "       ZT1_TEMP  ,"
         cSql += "       ZT1_RESP  ,"
         cSql += "       ZT1_DELE  ,"
         cSql += "       ZT1_STAT   "
         cSql += "  FROM " + RetSqlName("ZT1")
         cSql += " WHERE ZT1_DELE = ''"
         cSql += "   AND ZT1_CODI = '" + Alltrim(_Codigo) + "'"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAREFAS", .T., .T. )

         // Elabora o texto do e-mail
         cEmail := ""
         cEmail := "Prezado Usuário(a),"
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)   
         cEmail += "Sua tarefa de solução imediata foi desenvolvida conforme sua solicitação."
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)   
         cEmail += "Detalhes da Tarefa:"
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)   
         cEmail += "Nº da Tarefa: " + T_TAREFAS->ZT1_CODI
         cEmail += chr(13) + chr(10)
         cEmail += "Data Abertura: " + T_TAREFAS->ABERTURA + "  -  " + T_TAREFAS->ZT1_HORA
         cEmail += chr(13) + chr(10)
         cEmail += "Titulo Tarefa: " + Alltrim(T_TAREFAS->ZT1_TITU)
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)
         cEmail += "Descrição da Tarefa:" 
         cEmail += chr(13) + chr(10) + chr(13) + chr(10)
         cEmail += Alltrim(T_TAREFAS->DESCRICAO)
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)
         cEmail += "Att."
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)      
         cEmail += "Sistema de Controle de Tarefas Automatech"   
         
      Endif
         
      // Envia e-mail ao Aprovador   
      If Empty(c_email)
      Else   
//       U_AUTOMR20(cEmail, c_email, "", "Abertura de Tarefa de Solução Imediata" )
      Endif
   Endif

   oDlgH:End()

   // Envia para a função que carrega o grid da tela
   PesqImediatas(2)

Return(.T.)

// Função que abre o detalhe da tarefa selecionada
Static Function Detalhe_Imediata(_Codigo)

   Local lChumba := .F.
   Local yCodigo := Space(06)
   Local yTitulo := Space(100)
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oGet1
   Local oGet2
   Local oMemo1
   Local oMemo2

   Private oDlgD

   If Select("T_TAREFAS") > 0
      T_TAREFAS->( dbCloseArea() )
   EndIf

   cSql := "SELECT ZT1_FILIAL,"
   cSql += "       ZT1_CODI  ,"
   cSql += "       ZT1_DATA  ,"
   cSql += "       ZT1_HORA  ,"
   cSql += "       ZT1_SOLI  ,"
   cSql += "       ZT1_TITU  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZT1_DESC)) AS DESCRICAO,"
   cSql += "       ZT1_DTAI  ,"
   cSql += "       ZT1_HRSI  ,"
   cSql += "       ZT1_DTAF  ,"
   cSql += "       ZT1_HRSF  ,"
   cSql += "       ZT1_TEMP  ,"
   cSql += "       ZT1_RESP  ,"
   cSql += "       ZT1_DELE  ,"
   cSql += "       ZT1_STAT   "
   cSql += "  FROM " + RetSqlName("ZT1")
   cSql += " WHERE ZT1_DELE = ''"
   cSql += "   AND ZT1_CODI = '" + Alltrim(_Codigo) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAREFAS", .T., .T. )

   yCodigo := T_TAREFAS->ZT1_CODI
   yTitulo := T_TAREFAS->ZT1_TITU
   cMemo2  := T_TAREFAS->DESCRICAO

   DEFINE MSDIALOG oDlgD TITLE "Detalhes da Tarefa" FROM C(178),C(181) TO C(626),C(663) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp"   Size C(150),C(026) PIXEL NOBORDER OF oDlgD

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO   Size C(235),C(001) PIXEL OF oDlgD

   @ C(038),C(005) Say "Código"                 Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(038),C(034) Say "Título"                 Size C(016),C(008) COLOR CLR_BLACK PIXEL OF oDlgD
   @ C(060),C(005) Say "Descrição da Tarefa"    Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlgD

   @ C(048),C(005) MsGet oGet1  Var yCodigo     Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgD When lChumba
   @ C(048),C(034) MsGet oGet2  Var yTitulo     Size C(202),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgD When lChumba
   @ C(070),C(005) GET   oMemo2 Var cMemo2 MEMO Size C(231),C(134)                              PIXEL OF oDlgD

   @ C(206),C(197) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgD ACTION( oDlgD:End() )

   ACTIVATE MSDIALOG oDlgD CENTERED 

Return(.T.)

// Função que realiza o cancelamento da tarefa selecionada
Static Function Cancela_Imediata(_Status, _Codigo, _Titulo)

   If _Status == "8"
      MsgAlert("Atenção! Tarefa já encerrada. Operação não permitida.")
      Return(.T.)
   Endif
      
   If _Status == "X"
      MsgAlert("Atenção! Tarefa já cancelada. Operação não permitida.")
      Return(.T.)
   Endif

   If MsgYesNo("Atenção!"                            + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Deseja realmente cancelar a terafa:" + chr(13) + chr(10) + chr(13) + Chr(10) + ;
               "Código: " + Alltrim(_Codigo)         + chr(13) + chr(10) + ;
               "Título: " + Alltrim(_Titulo)         + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Confirma o cancelamento?")

      DbSelectArea("ZT1")
      DbSetOrder(1)
      If DbSeek(xfilial("ZT1") + _Codigo)
         RecLock("ZT1",.F.)
         ZT1_STAT := "X"
         MsUnLock()              
      Endif

      // Envia para a função que carrega o grid da tela
      PesqImediatas(2)

   Endif   
   
Return(.T.)

// Função que realiza a troca de setor da tarefa PROJETOS -> TI ou TI -> PROJETOS
Static Function Troca_Setor(_Status, _Setor, _Codigo, _Titulo)

   Local __Mensagem := ""

   If _Status == "8"
      MsgAlert("Atenção! Tarefa já encerrada. Operação não permitida.")
      Return(.T.)
   Endif
      
   If _Status == "X"
      MsgAlert("Atenção! Tarefa já cancelada. Operação não permitida.")
      Return(.T.)
   Endif

   If _Setor == "T"
      __Mensagem := "Trocar de TI PARA PROJETOS"
   Else
      __Mensagem := "Trocar de PROJETOS PARA TI"
   Endif   

   If MsgYesNo("Atenção!"                                      + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Deseja realmente trocar esta tarefa de setor?" + chr(13) + chr(10) + chr(13) + Chr(10) + ;
               __Mensagem                                      + chr(13) + chr(10) + chr(13) + Chr(10) + ;
               "Código: " + Alltrim(_Codigo)                   + chr(13) + chr(10) + ;
               "Título: " + Alltrim(_Titulo)                   + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Confirma a Troca de Setor?")

      DbSelectArea("ZT1")
      DbSetOrder(1)
      If DbSeek(xfilial("ZT1") + _Codigo)
         RecLock("ZT1",.F.)
         If _Setor == "T"
            ZT1_TRTI := "T"
         Else
            ZT1_TRTI := "F"            
         Endif
         MsUnLock()              
      Endif

      // Envia para a função que carrega o grid da tela
      PesqImediatas(2)

   Endif   
   
Return(.T.)

// Função que realiza a transferência de horário
Static Function transf_horas()

   Local lLiberado      := .F.
   Local lChumba        := .F.
   Local nContar        := 0

   Local cMemo1	        := ""
   Local cMemo2	        := ""
   Local cMemo4	        := ""

   Local oMemo1
   Local oMemo2
   Local oMemo4

   Private aTransfere   := {}

   Private aFuncionario := {}
   Private cComboBx1
   Private cMes	        := Space(02)
   Private cAno 	    := Space(04)
   Private nXtotHoras   := Space(05)

   Private oGet1
   Private oGet2
   Private oGet3

   Private oDlgT

   // Verifica se o usuário logado é Administrador
   If Select("T_MASTER") > 0
      T_MASTER->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZE_CODIGO,"
   cSql += "       ZZE_NOME  ,"
   cSql += "       ZZE_LOGIN ,"
   cSql += "       ZZE_ADMIN  "
   cSql += "  FROM " + RetSqlName("ZZE")
   cSql += " WHERE ZZE_DELETE = ''"  
   cSql += "   AND RTRIM(UPPER(ZZE_LOGIN)) = '" + Upper(Alltrim(cUserName)) + "'"
   cSql += " ORDER BY ZZE_NOME"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MASTER", .T., .T. )

   // Carrega o combo de Desenvolvedores
   If Select("T_PROGRAMADOR") > 0
      T_PROGRAMADOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZE_CODIGO,"
   cSql += "       ZZE_NOME  ,"
   cSql += "       ZZE_LOGIN ,"
   cSql += "       ZZE_ADMIN  "
   cSql += "  FROM " + RetSqlName("ZZE")
   cSql += " WHERE ZZE_DELETE  = ''"  
   cSql += "   AND ZZE_LOGIN  <> ''"
   cSql += " ORDER BY ZZE_NOME"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROGRAMADOR", .T., .T. )

   // Carrega o Combo dos Usuários do Sistema
   T_PROGRAMADOR->( EOF() )
   WHILE !T_PROGRAMADOR->( EOF() )
      aAdd( aFuncionario, T_PROGRAMADOR->ZZE_CODIGO + " - " + Alltrim(T_PROGRAMADOR->ZZE_LOGIN) )
      T_PROGRAMADOR->( DbSkip() )
   ENDDO

   // Se usuário for master abre combo senão posiciona e fecha o combo de desenvolvedores
   If T_MASTER->ZZE_ADMIN == "T"
      lLiberado := .T.
   Else
      lLiberado := .F.
         
      // Posiciona o usuário logado
      For nContar = 1 to Len(aFuncionario)
          If Upper(Alltrim(Substr(aFuncionario[nContar],10))) == Upper(Alltrim(cUserName))
             cComboBx1 = cUserName
             Exit
          Endif
      Next nContar       
   Endif

   // Desenha e abre a tela de manutenção das transferências de horários
   DEFINE MSDIALOG oDlgT TITLE "Transferência de Horários" FROM C(178),C(181) TO C(610),C(455) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(130),C(026) PIXEL NOBORDER OF oDlgT
   @ C(172),C(002) Jpeg FILE "br_amarelo"     Size C(009),C(009) PIXEL NOBORDER OF oDlgT
   @ C(183),C(002) Jpeg FILE "br_azul"        Size C(009),C(009) PIXEL NOBORDER OF oDlgT

   @ C(031),C(002) GET oMemo1 Var cMemo1 MEMO Size C(130),C(001) PIXEL OF oDlgT
   @ C(168),C(002) GET oMemo2 Var cMemo2 MEMO Size C(130),C(001) PIXEL OF oDlgT
   @ C(195),C(002) GET oMemo4 Var cMemo4 MEMO Size C(130),C(001) PIXEL OF oDlgT
	   
   @ C(037),C(005) Say "Usuário"                               Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(060),C(005) Say "Mês"                                   Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(060),C(026) Say "Ano"                                   Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(082),C(005) Say "Total de Horas a serem Tranferidas"    Size C(085),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(172),C(015) Say "Horários liberados para transferência" Size C(088),C(008) COLOR CLR_BLACK PIXEL OF oDlgT
   @ C(183),C(015) Say "Horários já transferidos"              Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlgT

   @ C(047),C(005) ComboBox cComboBx1 Items aFuncionario Size C(124),C(010)                              PIXEL OF oDlgT When lLiberado
   @ C(069),C(005) MsGet    oGet1     Var   cMes         Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT
   @ C(069),C(026) MsGet    oGet2     Var   cAno         Size C(022),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgT

   @ C(067),C(055) Button "Pesquisa Horários - Mês/Ano" Size C(074),C(012) PIXEL OF oDlgT ACTION( PesqHTransfe(cComboBx1, cMes, cAno) )

   @ C(200),C(030) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgT ACTION( TransHorasExtra(cComboBx1) )
   @ C(200),C(069) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgT ACTION( oDlgT:End() )

   aAdd( aTransfere, { "1", "", "" } )

   oTransfere := TCBrowse():New( 115 , 005, 165, 100,,{'Lg', 'Data', 'Tot. Horas'}, {20,50,50,50},oDlgT,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oTransfere:SetArray(aTransfere) 

   // Monta a linha a ser exibina no Browse
   oTransfere:bLine := {||{ If(Alltrim(aTransfere[oTransfere:nAt,01]) == "1", oBranco  ,;
                            If(Alltrim(aTransfere[oTransfere:nAt,01]) == "2", oVerde   ,;
                            If(Alltrim(aTransfere[oTransfere:nAt,01]) == "3", oPink    ,;                         
                            If(Alltrim(aTransfere[oTransfere:nAt,01]) == "4", oAmarelo ,;                         
                            If(Alltrim(aTransfere[oTransfere:nAt,01]) == "5", oAzul    ,;                         
                            If(Alltrim(aTransfere[oTransfere:nAt,01]) == "6", oLaranja ,;                         
                            If(Alltrim(aTransfere[oTransfere:nAt,01]) == "7", oPreto   ,;                         
                            If(Alltrim(aTransfere[oTransfere:nAt,01]) == "8", oVermelho,;
                            If(Alltrim(aTransfere[oTransfere:nAt,01]) == "X", oCancel  ,;
                            If(Alltrim(aTransfere[oTransfere:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                            aTransfere[oTransfere:nAt,02],;
                            aTransfere[oTransfere:nAt,03]}}

   ACTIVATE MSDIALOG oDlgT CENTERED 

Return(.T.)

// Função que pesquisa horas a serem transferidas
Static Function PesqHTransfe(_Funcionario, _Mes, _Ano)

   Local cSql       := ""
   Local nHatras    := "00:00:00"
   Local nHTotal    := "00:00:00"
   Local _Diferenca := "00:00:00"

   aRelogio   := {}
   aTransfere := {}

   If Empty(Alltrim(_Mes))
      MsgAlert("Mês para pesquisa não informado.")
      Return(.T.)
   Endif
      
   If Empty(Alltrim(_Ano))
      MsgAlert("Ano para pesquisa não informado.")
      Return(.T.)
   Endif

   // Pesquisa os horários para transferência
   If Select("T_HORARIOS") > 0
      T_HORARIOS->( dbCloseArea() )
   EndIf
      
   cSql := ""
   cSql := "SELECT ZT1_CODI,"
   cSql += "       ZT1_DATA,"
   cSql += "       ZT1_STAT,"
   cSql += "       ZT1_TEMP,"
   cSql += "       ZT1_TRAN "
   cSql += "  FROM " + RetSqlName("ZT1")
   cSql += " WHERE ZT1_STAT = '8'"
   cSql += "   AND RTRIM(UPPER(ZT1_RESP)) = '" + Upper(Alltrim(Substr(_Funcionario,10))) + "'"
   cSql += "   AND ZT1_DELE = ''"
   cSql += " ORDER BY ZT1_DATA"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_HORARIOS", .T., .T. )

   // Carrega Array com as datas

   T_HORARIOS->( DbGoTop() )

   WHILE !T_HORARIOS->( EOF() )

      nContar = 0
      lJaTem  := .F.

      // Verifica se já tem a data no array
      For nContar = 1 to Len(aRelogio)
          If aRelogio[nContar,01] == T_HORARIOS->ZT1_DATA
             lJaTem := .T.
             Exit
          Endif
      Next nContar
      
      If lJaTem
         T_HORARIOS->( DbSkip() )
         Loop
      Endif

      aAdd( aRelogio, { T_HORARIOS->ZT1_DATA } )

      T_HORARIOS->( DbSkip() )

   ENDDO

   // Acumula o total de horas por data
   nHatras    := "00:00:00"
   nHTotal    := "00:00:00"
   _Diferenca := "00:00:00"
   __Status   := ""
      
   For nContar = 1 to Len(aRelogio)
  
       T_HORARIOS->( DbGoTop() )   

       WHILE !T_HORARIOS->( EOF() )
          If T_HORARIOS->ZT1_DATA == aRelogio[nContar,01]
             nHatras  := SomaHoras( nHatras, T_HORARIOS->ZT1_TEMP )
             nHTotal  := SomaHoras( nHatras, T_HORARIOS->ZT1_TEMP )
             __Status := T_HORARIOS->ZT1_TRAN
          Endif
          T_HORARIOS->( DbSkip() )
       ENDDO

       // Carrega o array aTransfere com os dados calculados
       aAdd( aTransfere, { IIF(Alltrim(__Status) == "X", "5", "4")    ,;
                           Substr(aRelogio[nContar,01],07,02) + "/" +  ;
                           Substr(aRelogio[nContar,01],05,02) + "/" +  ;
                           Substr(aRelogio[nContar,01],01,04)         ,;
                           nHatras})

       nHatras := "00:00:00"

   Next nContar

   If Len(aTransfere) == 0
      aAdd( aTransfere, { "1", "", "" } )   
   Endif

   // Seta vetor para a browse                            
   oTransfere:SetArray(aTransfere) 

   // Monta a linha a ser exibina no Browse
   oTransfere:bLine := {||{ If(Alltrim(aTransfere[oTransfere:nAt,01]) == "1", oBranco  ,;
                            If(Alltrim(aTransfere[oTransfere:nAt,01]) == "2", oVerde   ,;
                            If(Alltrim(aTransfere[oTransfere:nAt,01]) == "3", oPink    ,;                         
                            If(Alltrim(aTransfere[oTransfere:nAt,01]) == "4", oAmarelo ,;                         
                            If(Alltrim(aTransfere[oTransfere:nAt,01]) == "5", oAzul    ,;                         
                            If(Alltrim(aTransfere[oTransfere:nAt,01]) == "6", oLaranja ,;                         
                            If(Alltrim(aTransfere[oTransfere:nAt,01]) == "7", oPreto   ,;                         
                            If(Alltrim(aTransfere[oTransfere:nAt,01]) == "8", oVermelho,;
                            If(Alltrim(aTransfere[oTransfere:nAt,01]) == "X", oCancel  ,;
                            If(Alltrim(aTransfere[oTransfere:nAt,01]) == "9", oEncerra, "")))))))))),;                         
                            aTransfere[oTransfere:nAt,02],;
                            aTransfere[oTransfere:nAt,03]}}

Return(.T.)

// Função que confirma a transferência de horários para a tabela ZT0
Static Function TransHorasExtra(_Funcionario)

   Local nContar    := 0
   Local lTemTransf := .F.
   Local __Texto    := ""

   For nContar = 1 to Len(aTransfere)
       If aTransfere[nContar,01] == "4"
          lTemTransf := .T.
          Exit
       Endif
   Next nContar       

   If !lTemTransf
      MsgAlert("Atenção! Não existem horários a serem transferidos.")
      Return(.T.)
   Endif

   // Realiza a transferência dos horários
   For nContar = 1 to Len(aTransfere)

       // Despreza caso horário já transferido
       If aTransfere[nContar,01] == "5"
          Loop
       Endif
 
       // Pesquisa registros da data para transferência
       If Select("T_HORARIOS") > 0
          T_HORARIOS->( dbCloseArea() )
       EndIf
      
       cSql := ""
       cSql := "SELECT ZT1_CODI,"
       cSql += "       ZT1_DATA,"
       cSql += "       ZT1_TITU,"
       cSql += "       ZT1_STAT,"
       cSql += "       ZT1_TEMP,"
       cSql += "       ZT1_TRAN "
       cSql += "  FROM " + RetSqlName("ZT1")
       cSql += " WHERE ZT1_STAT = '8'"
       cSql += "   AND ZT1_TRAN = '' "
       cSql += "   AND RTRIM(UPPER(ZT1_RESP)) = '"    + Upper(Alltrim(Substr(_Funcionario,10))) + "'"
       cSql += "   AND ZT1_DATA = CONVERT(DATETIME,'" + aTransfere[nContar,02] + "', 103)"
       cSql += "   AND ZT1_DELE = ''"
       cSql += " ORDER BY ZT1_DATA"

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_HORARIOS", .T., .T. )
       
       T_HORARIOS->( DbGoTop() )
       
       WHILE !T_HORARIOS->( EOF() )

          // Verifica se já existe registro para a data/programador
          If Select("T_JATEM") > 0
             T_JATEM->( dbCloseArea() )
          EndIf

          cSql := ""
          cSql := "SELECT ZZN_DATA, "
          cSql += "       ZZN_PROG, "
          cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZN_CHAVE)) AS DESCRICAO"
          cSql += "  FROM " + RetSqlName("ZZN")
          cSql += " WHERE ZZN_DELE   = ''"  
          cSql += "   AND ZZN_DATA   = '" + Substr(aTransfere[nContar,02],07,04) + Substr(aTransfere[nContar,02],04,02) + Substr(aTransfere[nContar,02],01,02) + "'"
          cSql += "   AND ZZN_PROG   = '" + Alltrim(Substr(_Funcionario,01,06))  + "'"
          cSql += "   AND ZZN_DELE   = ''"
          cSql += "   AND D_E_L_E_T_ = ''"
      
          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JATEM", .T., .T. )

          If T_JATEM->( EOF() )

             // Inseri os dados na Tabela
             aArea := GetArea()
             dbSelectArea("ZZN")
             RecLock("ZZN",.T.)
             ZZN_DATA  := Ctod(Substr(T_HORARIOS->ZT1_DATA,07,02) + "/" + Substr(T_HORARIOS->ZT1_DATA,05,02) + "/" + Substr(T_HORARIOS->ZT1_DATA,01,04))
             ZZN_PROG  := Substr(_Funcionario,01,06)
             ZZN_CHAVE := "@" + Substr(T_HORARIOS->ZT1_TEMP,01,05) + "@ - " + Alltrim(T_HORARIOS->ZT1_TITU) + Chr(13) + chr(10)
             ZZN_DELE  := ""
             MsUnLock()

          Else

             __Texto := Alltrim(T_JATEM->DESCRICAO) + chr(13) + chr(10) + "@" + Substr(T_HORARIOS->ZT1_TEMP,01,05) + "@" + " - " + Alltrim(T_HORARIOS->ZT1_TITU)

             // Operação de Alteração
             cSql := ""
             cSql := "UPDATE " + RetSqlName("ZZN")
             cSql += "   SET"
             cSql += "   ZZN_CHAVE      = '" + Alltrim(__Texto)                    + "'"
             cSql += " WHERE ZZN_DATA   = '" + T_HORARIOS->ZT1_DATA                + "'"
             cSql += "   AND ZZN_PROG   = '" + Alltrim(Substr(_Funcionario,01,06)) + "'"
             cSql += "   AND ZZN_DELE   = ''"
             cSql += "   AND D_E_L_E_T_ = ''"

             TCSQLEXEC(cSql)

          Endif
          
          // Atualiza o registro com status de horário transferido
          DbSelectArea("ZT1")
          DbSetOrder(1)
          If DbSeek(xfilial("ZT1") + T_HORARIOS->ZT1_CODI)
             RecLock("ZT1",.F.)
             ZT1_TRAN := "X"
             MsUnLock()              
          Endif

          T_HORARIOS->( DbSkip() )
          
       Enddo   

   Next nContar

   oDlgT:End() 

   MsgAlert("Transferênciade horários efetuada com sucesso.")
   
Return(.T.)