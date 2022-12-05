#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ATVATI09.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 30/07/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Atividades X Áreas (Browse)   *
//**********************************************************************************

User Function ATVATI09(_Area, _NomeArea, _Usuario)

   Local _aArea   := {}
   Local _aAlias  := {}
   Local cSql     := {}
   Local lChumba  := .F.

   Private __Area    := _Area
   Private __Nome    := _NomeArea
   Private __Usuario := _Usuario

   Private oGet1
   Private oGet2
   Private oGet3

   Private oDlg

   Private aBrowse := {}

   // Verifica se existem atividades parametrizadas para o usuário/área selecionados.
   // Caso não exista, envia direto para o programa de inclusão de atividades.
   If Select("T_ATIVIDADE") > 0
      T_ATIVIDADE->( dbCloseArea() )
   EndIf

   cSql := "SELECT A.ZZV_FILIAL," + chr(13)
   cSql += "       A.ZZV_CODIGO," + chr(13)
   cSql += "       A.ZZV_DATA  ," + chr(13)
   cSql += "       A.ZZV_AREA  ," + chr(13)
   cSql += "       A.ZZV_USUA  ," + chr(13)
   cSql += "       B.ZZR_NOME  ," + chr(13)
   cSql += "       A.ZZV_STATUS," + chr(13)
   cSql += "       A.ZZV_ATIV  ," + chr(13)
   cSql += "       C.ZZU_NOME   " + chr(13)
   cSql += "  FROM " + RetSqlName("ZZV") + " A, " + chr(13)
   cSql += "       " + RetSqlName("ZZR") + " B, " + chr(13)
   cSql += "       " + RetSqlName("ZZU") + " C  " + chr(13)
   cSql += " WHERE A.ZZV_AREA   = '" + Alltrim(__Area)    + "'" + chr(13)
   cSql += "   AND A.ZZV_USUA   = '" + Alltrim(__Usuario) + "'" + chr(13)
   cSql += "   AND A.ZZV_DELETE = ''"                           + chr(13)
   cSql += "   AND A.ZZV_AREA   = B.ZZR_CODIGO"                 + chr(13)
   cSql += "   AND B.ZZR_DELETE = ''"                           + chr(13)
   cSql += "   AND A.ZZV_ATIV   = C.ZZU_CODIGO"                 + chr(13)
   cSql += "   AND C.ZZU_DELETE = ''"                           + chr(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATIVIDADE", .T., .T. )

   If T_ATIVIDADE->( EOF() )
      If MsgYesNo("Atenção!!!" + chr(13) + chr(10) + "Não existem atividades parametrizadas para este usuário." + chr(13) + chr(10) + "Deseja incluir?")
         U_ATVATI10("I", Space(02), Space(06), __Area, __Nome, __Usuario ) 
         Return .T.
      Else
         Return .T.      
      Endif
   Endif

   CarregaBRWD()

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Atividades X Áreas" FROM C(178),C(181) TO C(617),C(967) PIXEL

   @ C(006),C(005) Say "Área"    Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(006),C(224) Say "Usuário" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(004),C(021) MsGet oGet1 Var __Area    When lChumba Size C(021),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(004),C(046) MsGet oGet2 Var __Nome    When lChumba Size C(170),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(004),C(247) MsGet oGet3 Var __Usuario When lChumba Size C(138),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(203),C(234) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg ACTION(_AbreXative( "I", Space(02)                 , Space(06)                 , __Area, __Nome, __Usuario ) )
   @ C(203),C(273) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION(_AbreXative( "A", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ], __Area, __Nome, __Usuario ) )
   @ C(203),C(312) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg ACTION(_AbreXative( "E", aBrowse[ oBrowse:nAt, 01 ], aBrowse[ oBrowse:nAt, 02 ], __Area, __Nome, __Usuario ) )
   @ C(203),C(351) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Desenha o Browse
   oBrowse := TCBrowse():New( 025 , 005, 490, 230,,{'FL','Código','Abertura','Agenda', 'Status','Usuário','Atividade','Descrição das Atividades' },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,10],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,09],;
                         aBrowse[oBrowse:nAt,07],;
                         aBrowse[oBrowse:nAt,08]} }

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Carrega o Browse
Static Function CarregaBRWD()

   aBrowse := {}

   // Carrega o Array com os Componentes de tarefas cadastrados
   If Select("T_ATIVIDADE") > 0
      T_ATIVIDADE->( dbCloseArea() )
   EndIf

   cSql := "SELECT A.ZZV_FILIAL,"
   cSql += "       A.ZZV_CODIGO,"
   cSql += "       A.ZZV_DATA  ,"
   cSql += "       A.ZZV_AREA  ,"
   cSql += "       A.ZZV_USUA  ,"
   cSql += "       B.ZZR_NOME  ,"
   cSql += "       A.ZZV_STATUS,"
   cSql += "       A.ZZV_ATIV  ,"
   cSql += "       A.ZZV_PERI  ,"
   cSql += "       C.ZZU_NOME   "
   cSql += "  FROM " + RetSqlName("ZZV") + " A, "
   cSql += "       " + RetSqlName("ZZR") + " B, "
   cSql += "       " + RetSqlName("ZZU") + " C  "
   cSql += " WHERE A.ZZV_AREA   = '" + Alltrim(__Area)    + "'"
   cSql += "   AND A.ZZV_USUA   = '" + Alltrim(__Usuario) + "'"
   cSql += "   AND A.ZZV_DELETE = ''"
   cSql += "   AND A.ZZV_AREA   = B.ZZR_CODIGO"
   cSql += "   AND B.ZZR_DELETE = ''"
   cSql += "   AND A.ZZV_ATIV   = C.ZZU_CODIGO"
   cSql += "   AND C.ZZU_DELETE = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ATIVIDADE", .T., .T. )

   T_ATIVIDADE->( DbGoTop() )
   WHILE !T_ATIVIDADE->( EOF() )

      cAgenda := ""
      
      If U_P_CORTA(T_ATIVIDADE->ZZV_PERI, "|", 1) == "T"
         cAgenda := "DIARIO"
      Endif
         
      If U_P_CORTA(T_ATIVIDADE->ZZV_PERI, "|", 2) == "T"
         cAgenda := "SEMANAL"
      Endif
         
      If U_P_CORTA(T_ATIVIDADE->ZZV_PERI, "|", 10) == "T"
         cAgenda := "QUINZENAL"
      Endif

      If U_P_CORTA(T_ATIVIDADE->ZZV_PERI, "|", 15) == "T"
         cAgenda := "MENSAL"
      Endif

      If U_P_CORTA(T_ATIVIDADE->ZZV_PERI, "|", 18) == "T"
         cAgenda := "ANUAL"
      Endif

      aAdd( aBrowse, { T_ATIVIDADE->ZZV_FILIAL,;
                       T_ATIVIDADE->ZZV_CODIGO,;
                       Substr(T_ATIVIDADE->ZZV_DATA,07,02) + "/" + Substr(T_ATIVIDADE->ZZV_DATA,05,02) + "/" + Substr(T_ATIVIDADE->ZZV_DATA,01,04) ,;
                       IIF(T_ATIVIDADE->ZZV_STATUS == "A", "ATIVA", "INATIVA") ,;
                       T_ATIVIDADE->ZZV_AREA  ,;
                       T_ATIVIDADE->ZZR_NOME  ,;
                       T_ATIVIDADE->ZZV_ATIV  ,;
                       T_ATIVIDADE->ZZU_NOME  ,;
                       Alltrim(T_ATIVIDADE->ZZV_USUA),;
                       cAgenda})
      T_ATIVIDADE->( DbSkip() )
   ENDDO

Return .T.

// Chama o programa de manipulação dos dados
Static Function _AbreXative( _Tipo, _Filial, _Codigo, _Area, _Nome, _xUsuario)

   If _Tipo == "I"
      U_ATVATI10("I", _Filial, _Codigo, __Area, __Nome, _xUsuario ) 
   Endif
      
   If _Tipo == "A"
      U_ATVATI10("A", _Filial, _Codigo, __Area, __Nome, _xUsuario ) 
   Endif
      
   If _Tipo == "E"
      U_ATVATI10("E", _Filial, _Codigo, __Area, __Nome, _xUsuario ) 
   Endif

   aBrowse := {}

   CarregaBRWD()
   
   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,10],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,09],;
                         aBrowse[oBrowse:nAt,07],;
                         aBrowse[oBrowse:nAt,08]} }

Return .T.   