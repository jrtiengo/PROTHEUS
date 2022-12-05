#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPTAR04.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 17/02/2012                                                          *
// Objetivo..: Programa de Aprovação/Reprovação de Tarefas                         *
// Parâmetros: _xCodigo   - Código da Tarefa                                       *
//**********************************************************************************

User Function ESPTAR04( _xCodigo )

   Local lChumba := .F.

   // Variaveis da Funcao de Controle e GertArea/RestArea
   Local _aArea  := {}
   Local _aAlias := {}

   // Variaveis Locais da Funcao
   Private aComboBx1	 := {} // Usuários
   Private aComboBx2	 := {} // Status
   Private aComboBx3	 := {} // Prioridade
   Private aComboBx4	 := {} // Origem
   Private aComboBx5	 := {} // Componente
   Private aComboBx6	 := {} // Programador
   Private cUsuario
   Private cStatus
   Private cPrioridade
   Private cOrigem     
   Private cComponente 
   Private cProgramador 
   Private cCodigo	 := Space(06)
   Private cTitulo	 := Space(60)
   Private dData01   := Ctod("  /  /    ")
   Private cHora     := Space(10)
   Private dPrevisto := Ctod("  /  /    ")
   Private dTermino  := Ctod("  /  /    ")
   Private dProducao := Ctod("  /  /    ")
   Private cChamado  := Space(50)
   Private cChaveTex := Space(06)
   Private cChaveNot := Space(06)
   Private cChaveSol := Space(06)
   Private cTexto	 := ""
   Private cNota	 := ""
   Private cSolucao  := ""
   Private oGet1
   Private oGet2
   Private oGet3   := Ctod("  /  /    ")
   Private oGet4   := Ctod("  /  /    ")
   Private oGet5   := Ctod("  /  /    ")
   Private oGet6   := Ctod("  /  /    ")
   Private oGet7   := Ctod("  /  /    ")
   Private oGet8   := Space(50)
   Private oMemo1
   Private oMemo2
   Private oMemo3
   Private nContar := 0
   Private lSalvar := .F.

   // Variaveis Private da Funcao
   Private oDlg				// Dialog Principal
   
   // Verifica se o usuário logado possui permissão para liberar tarefas
   If Select("T_USUARIO") > 0
      T_USUARIO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZA_CODI, "
   cSql += "       ZZA_NOME, "
   cSql += "       ZZA_EMAI, "
   cSql += "       ZZA_VISU  "
   cSql += "  FROM " + RetSqlName("ZZA")
   cSql += "WHERE RTRIM(LTRIM(UPPER(ZZA_NOME))) = '" + Upper(Alltrim(cUserName)) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIO", .T., .T. )
   
   If T_USUARIO->( EOF() )
      MsgAlert("Atenção! Você não possui permissão para realizar esta operação.")
      Return(.T.)
   Endif
            
   If T_USUARIO->ZZA_VISU <> "T"
      lSalvar := .T.
   Else
      lSalvar := .F.   
   Endif

   // Carrega o combo de usuarios
   If Select("T_USUARIO") > 0
      T_USUARIO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZA_CODI, "
   cSql += "       ZZA_NOME, "
   cSql += "       ZZA_EMAI  "
   cSql += "  FROM " + RetSqlName("ZZA")
   cSql += " ORDER BY ZZA_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIO", .T., .T. )

   If T_USUARIO->( EOF() )
      MsgAlert("Cadastro de Usuários está vazio.")
      Return .T.
   Endif

   // Carrega o Combo dos Usuários do Sistema
   aComboBx1 := {}
   aAdd( aComboBx1, "          " )
   T_USUARIO->( EOF() )
   WHILE !T_USUARIO->( EOF() )
      aAdd( aComboBx1, T_USUARIO->ZZA_NOME )
      T_USUARIO->( DbSkip() )
   ENDDO
 
   // Posiciona o usuário logado
   For nContar = 1 to Len(aComboBX1)
       If Alltrim(aComboBx1[nContar]) == Alltrim(cUserName)
          cUsuario = cUserName
          Exit
       Endif
   Next nContar       

   // Carrega o Combo de Origem
   If Select("T_ORIGEM") > 0
      T_ORIGEM->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZF_CODIGO, "
   cSql += "       ZZF_NOME    "
   cSql += "  FROM " + RetSqlName("ZZF")
   cSql += " WHERE ZZF_DELETE = ''"
   cSql += " ORDER BY ZZF_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ORIGEM", .T., .T. )

   aComboBx4 := {}

   If !T_ORIGEM->( EOF() )
      aAdd( aComboBx4, "              " )  
      WHILE !T_ORIGEM->( EOF() )
         aAdd( aComboBx4, T_ORIGEM->ZZF_CODIGO + " - " + T_ORIGEM->ZZF_NOME )
         T_ORIGEM->( DbSkip() )
      ENDDO
   Endif
      
   // Carrega o Combo de Componentes
   If Select("T_COMPO") > 0
      T_COMPO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZB_CODIGO, "
   cSql += "       ZZB_NOME    "
   cSql += "  FROM " + RetSqlName("ZZB")
   cSql += " WHERE ZZB_DELETE = ''"
   cSql += " ORDER BY ZZB_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMPO", .T., .T. )

   aComboBx5 := {}

   If !T_COMPO->( EOF() )
      aAdd( aComboBx5, "              " )
      WHILE !T_COMPO->( EOF() )
         aAdd( aComboBx5, T_COMPO->ZZB_CODIGO + " - " + T_COMPO->ZZB_NOME )
         T_COMPO->( DbSkip() )
      ENDDO
   Endif

   // Carrega o Combo de Desenvolvedores
   If Select("T_DESENVE") > 0
      T_DESENVE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZE_CODIGO, "
   cSql += "       ZZE_NOME    "
   cSql += "  FROM " + RetSqlName("ZZE")
   cSql += " WHERE ZZE_DELETE = ''"
   cSql += " ORDER BY ZZE_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DESENVE", .T., .T. )

   aComboBx6 := {}

   If !T_DESENVE->( EOF() )
      aAdd( aComboBx6, "              " )
      WHILE !T_DESENVE->( EOF() )
         aAdd( aComboBx6, T_DESENVE->ZZE_CODIGO + " - " + T_DESENVE->ZZE_NOME )
         T_DESENVE->( DbSkip() )
      ENDDO
   Endif

   // Status das Tarefas
   //
   // 01 - Abertura de Tarefa - Aguardando Aprovação
   // 02 - Tarefa Aprovada
   // 03 - Tarefa Não Aprovada
   // 04 - Em Desenvolvimento
   // 05 - Em Validação
   // 06 - Validação Aprovada
   // 07 - Validação Reprovada
   // 08 - Encerrada (Em Produção)

   // Carrega o Combo de Status
   If Select("T_STATUS") > 0
      T_STATUS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZC_CODIGO, "
   cSql += "       ZZC_NOME    "
   cSql += "  FROM " + RetSqlName("ZZC")
   cSql += " WHERE ZZC_DELETE = ''"
   cSql += "   AND ZZC_CODIGO IN ('000002', '000003') "
   cSql += " ORDER BY ZZC_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_STATUS", .T., .T. )

   aComboBx2 := {}

   If !T_STATUS->( EOF() )
      WHILE !T_STATUS->( EOF() )
         aAdd( aComboBx2, STR(INT(VAL(T_STATUS->ZZC_CODIGO)),1) + " - " + T_STATUS->ZZC_NOME )
         T_STATUS->( DbSkip() )
      ENDDO
   Endif
   
   // Carrega o Combo de Prioidades
   If Select("T_PRIORI") > 0
      T_PRIORI->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZD_CODIGO, "
   cSql += "       ZZD_NOME    "
   cSql += "  FROM " + RetSqlName("ZZD")
   cSql += " WHERE ZZD_DELETE = ''"
   cSql += " ORDER BY ZZD_NOME "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRIORI", .T., .T. )

   aComboBx3 := {}

   If !T_PRIORI->( EOF() )
      aAdd( aComboBx3, "" )
      WHILE !T_PRIORI->( EOF() )
         aAdd( aComboBx3, T_PRIORI->ZZD_CODIGO + " - " + T_PRIORI->ZZD_NOME )
         T_PRIORI->( DbSkip() )
      ENDDO
   Endif

   // Em caso de alteração, captura os dados para manipulação
   If Select("T_TAREFA") > 0
      T_TAREFA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZG_FILIAL,"
   cSql += "       ZZG_CODI  ,"
   cSql += "       ZZG_SEQU  ,"
   cSql += "       ZZG_TITU  ,"
   cSql += "       ZZG_USUA  ,"
   cSql += "       ZZG_DATA  ,"
   cSql += "       ZZG_HORA  ,"
   cSql += "       ZZG_STAT  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_DES1)) AS DESCRICAO, "
   cSql += "       ZZG_DES2  ,"
   cSql += "       ZZG_PRIO  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_NOT1)) AS NOTAS, "
   cSql += "       ZZG_NOT2  ,"
   cSql += "       ZZG_PREV  ,"
   cSql += "       ZZG_TERM  ,"
   cSql += "       ZZG_PROD  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZZG_SOL1)) AS SOLICITAS, "
   cSql += "       ZZG_SOL2  ,"
   cSql += "       ZZG_DELE  ,"
   cSql += "       ZZG_ORIG  ,"
   cSql += "       ZZG_COMP  ,"
   cSql += "       ZZG_PROG  ,"
   cSql += "       ZZG_CHAM   "
   cSql += "  FROM " + RetSqlName("ZZG")
   cSql += " WHERE ZZG_DELE  = ''"
   cSql += "   AND ZZG_CODI  = '" + Substr(_xCodigo,01,06) + "'"
   cSql += "   AND ZZG_SEQU  = '" + Substr(_xCodigo,08,02) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAREFA", .T., .T. )

   If T_TAREFA->( EOF() )
      MsgAlert("Não existem dados a serem visualizados para a tarefa selecioada.")
      ODlg:End()
      Return .T.
   Endif

   cCodigo   := Alltrim(T_TAREFA->ZZG_CODI) + "." + Alltrim(T_TAREFA->ZZG_SEQU)
   cTitulo   := T_TAREFA->ZZG_TITU
   dData01   := Substr(T_TAREFA->ZZG_DATA,07,02) + "/" + Substr(T_TAREFA->ZZG_DATA,05,02) + "/" + Substr(T_TAREFA->ZZG_DATA,01,04)
   cHora     := T_TAREFA->ZZG_HORA
   dPrevisto := Substr(T_TAREFA->ZZG_PREV,07,02) + "/" + Substr(T_TAREFA->ZZG_PREV,05,02) + "/" + Substr(T_TAREFA->ZZG_PREV,01,04)
   dTermino  := Substr(T_TAREFA->ZZG_TERM,07,02) + "/" + Substr(T_TAREFA->ZZG_TERM,05,02) + "/" + Substr(T_TAREFA->ZZG_TERM,01,04)
   dProducao := Substr(T_TAREFA->ZZG_PROD,07,02) + "/" + Substr(T_TAREFA->ZZG_PROD,05,02) + "/" + Substr(T_TAREFA->ZZG_PROD,01,04)
   cChamado  := T_TAREFA->ZZG_CHAM
   cChaveTex := T_TAREFA->ZZG_DES2
   cChaveNot := T_TAREFA->ZZG_NOT2
   cChaveSol := T_TAREFA->ZZG_SOL2

   // Localiza o Usuario para display
   For nContar = 1 to Len(aComboBx1)
       If Upper(Alltrim(aComboBx1[nContar])) == Upper(Alltrim(T_TAREFA->ZZG_USUA)) 
          cUsuario := T_TAREFA->ZZG_USUA
          Exit
       Endif
   Next nContar       
             
   // Localiza o Status para display
   For nContar = 1 to Len(aComboBx2)
       If Upper(Alltrim(Substr(aComboBx2[nContar],01,06))) == Upper(Alltrim(T_TAREFA->ZZG_STAT)) 
          cStatus := aComboBx2[nContar]
          Exit
       Endif
   Next nContar       

   // Localiza a Prioridade para display
   For nContar = 1 to Len(aComboBx3)
       If Upper(Alltrim(Substr(aComboBx3[nContar],01,06))) == Upper(Alltrim(T_TAREFA->ZZG_PRIO)) 
          cPrioridade := aComboBx3[nContar]
          Exit
       Endif
   Next nContar       

   // Localiza a Origem para display
   For nContar = 1 to Len(aComboBx4)
       If Upper(Alltrim(Substr(aComboBx4[nContar],01,06))) == Upper(Alltrim(T_TAREFA->ZZG_ORIG)) 
          cOrigem := aComboBx4[nContar]
          Exit
       Endif
   Next nContar       

   // Localiza o Componente para display
   For nContar = 1 to Len(aComboBx5)
       If Upper(Alltrim(Substr(aComboBx5[nContar],01,06))) == Upper(Alltrim(T_TAREFA->ZZG_COMP)) 
          cComponente := aComboBx5[nContar]
          Exit
       Endif
   Next nContar       

   // Localiza o Programador para display
   For nContar = 1 to Len(aComboBx6)
       If Upper(Alltrim(Substr(aComboBx6[nContar],01,06))) == Upper(Alltrim(T_TAREFA->ZZG_PROG)) 
          cProgramador := aComboBx6[nContar]
          Exit
       Endif
   Next nContar       

   // Carrega o campo cTexto
   If !Empty(Alltrim(T_TAREFA->DESCRICAO))
      cTexto := T_TAREFA->DESCRICAO
   Endif

   // Carrega o campo cNota
   If !Empty(Alltrim(T_TAREFA->NOTAS))
      cNota := T_TAREFA->NOTAS
   Endif

   // Carrega o campo cSolucao
   If !Empty(Alltrim(T_TAREFA->SOLICITAS))
      cSolucao := T_TAREFA->SOLICITAS
   Endif

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Tarefas" FROM C(178),C(181) TO C(601),C(967) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp"    Size C(150),C(026) PIXEL NOBORDER OF oDlg

   @ C(026),C(006) Say "Tarefa"              Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(039) Say "Título"              Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(146) Say "Usuáio"              Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(214) Say "Data"                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(259) Say "Hora"                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(299) Say "Status"              Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(047),C(007) Say "Descrição da Tarefa" Size C(049),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(101),C(006) Say "Prioidade"           Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(101),C(085) Say "Origem"              Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(101),C(150) Say "Nº Chamado"          Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(101),C(200) Say "Componente"          Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(101),C(290) Say "Desenvolvedor"       Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(121),C(007) Say "Prevista Para"       Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(121),C(070) Say "Data Término"        Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(121),C(136) Say "Data Produção"       Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(121),C(190) Say "Outras Observação"   Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(142),C(007) Say "Solução Adotada"     Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   If lSalvar
   Else
      @ C(198),C(005) Say "Usuário somente com permissão de consulta." Size C(107),C(008) COLOR CLR_RED PIXEL OF oDlg
   Endif
   
// @ C(194),C(005) Say "Utilize o Campo Solução Adotada para envio de mensagem ao usuário." Size C(200),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(035),C(006) MsGet oGet1           Var   cCodigo       When lChumba Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(035),C(039) MsGet oGet2           Var   cTitulo       Size C(100),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(035),C(145) ComboBox cUsuario     Items aComboBx1     Size C(064),C(010) PIXEL OF oDlg
   @ C(035),C(214) MsGet oGet3           Var   dData01       When lChumba Size C(038),C(009) COLOR CLR_BLACK Picture "@d" PIXEL OF oDlg
   @ C(035),C(258) MsGet oGet4           Var   cHora         When lChumba Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(035),C(299) ComboBox cStatus      Items aComboBx2     Size C(087),C(010) PIXEL OF oDlg

   @ C(054),C(006) GET oMemo1            Var   cTexto MEMO   Size C(379),C(044) PIXEL OF oDlg

   @ C(108),C(006) ComboBox cPrioridade  Items aComboBx3     Size C(070),C(010) PIXEL OF oDlg
   @ C(108),C(085) ComboBox cOrigem      Items aComboBx4     Size C(060),C(010) PIXEL OF oDlg
   @ C(108),C(150) MsGet oGet8           Var   cChamado      Size C(044),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(108),C(200) ComboBox cComponente  Items aComboBx5     Size C(080),C(010) PIXEL OF oDlg
   @ C(108),C(290) ComboBox cProgramador Items aComboBx6     Size C(095),C(010) PIXEL OF oDlg

   @ C(129),C(190) GET oMemo2            Var   cNota  MEMO   Size C(195),C(020) PIXEL OF oDlg
   @ C(129),C(006) MsGet oGet5           Var   dPrevisto     Size C(046),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(129),C(070) MsGet oGet6           Var   dTermino      Size C(046),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(129),C(136) MsGet oGet7           Var   dProducao     Size C(046),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(151),C(006) GET oMemo3            Var   cSolucao MEMO Size C(379),C(040) PIXEL OF oDlg

   @ C(194),C(309) Button "Salvar"  Size C(037),C(012) PIXEL OF oDlg ACTION( SalvaTar() ) When lSalvar
   @ C(194),C(348) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION(oDlg:End() )
   
   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Altera Valor da Variável lLibera e lChumba
Static Function SalvaTar()

   Local cSql        := ""
   Local cEmail      := ""
   Local c_Email     := ""
   Local nIncremento := 0
   Local nIntervalo  := 0
   Local nOrdencao   := 0
   Local cPrior01    := Space(06)
   Local cProor02    := Space(06)
   Local nOrdem01    := 0
   Local nordem02    := 0
   Local nAgravar    := 0
      
   // Verifica se desenvolvedor foi informado
   If Substr(cProgramador,01,06) = "      "
      MsgAlert("Desenvolvedor da tarefa não indicado. Verifique!")
      Return(.T.)
   Endif

   // Posiciona o parametrizador do Sistema de Controle de Tarefas para capturar o intervalo de incremento da ordenação
   If Select("T_MASTER") > 0
      T_MASTER->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZJ_ORDE,"
   cSql += "       ZZJ_INTE "
   cSql += "  FROM " + RetSqlName("ZZJ")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MASTER", .T., .T. )

   If T_MASTER->( EOF() )
      nIncremento := 100
      nIntervalo  := 20
   Else
      nIncremento := IIF(T_MASTER->ZZJ_ORDE == 0, 100, T_MASTER->ZZJ_ORDE)
      nIntervalo  := IIF(T_MASTER->ZZJ_INTE == 0,  20, T_MASTER->ZZJ_INTE)
   Endif

   // Carrega as variáveis de prioridade para pesquisa
   cPrior01 := Substr(cPrioridade,01,06)
   
   // Pesquisa a maior ordem para a prioridade 01
   If Select("T_ORDEM01") > 0
      T_ORDEM01->( dbCloseArea() )
   EndIf
   
   cSql := "SELECT MAX(ZZG_ORDE) AS ORDEM01"
   cSql += "  FROM " + RetSqlName("ZZG")
   cSql += " WHERE ZZG_DELE = ''"
   cSql += "   AND LTRIM(ZZG_STAT) IN ('2','4','5','6','8','10')"
   cSql += "   AND ZZG_PRIO = '" + Alltrim(cPrior01) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ORDEM01", .T., .T. )

   If T_ORDEM01->( EOF() )
      nOrdem01 := 0
      nAgravar := nIncremento + nIntervalo
   Else
      nOrdem01 := T_ORDEM01->ORDEM01
      nAgravar := T_ORDEM01->ORDEM01 + nIntervalo
   Endif   

   // Verifica se existe ordenação superior a ordenação criada
   If Select("T_MAIORQUE") > 0
      T_MAIORQUE->( dbCloseArea() )
   EndIf

   cSql := "SELECT TOP(1) ZZG_CODI,"
   cSql += "              ZZG_ORDE" 
   cSql += "  FROM " + RetSqlName("ZZG")
   cSql += " WHERE ZZG_ORDE > '" + Alltrim(Str(nAgravar)) + "'"
   cSql += "   AND ZZG_DELE = ''"
   cSql += "   AND LTRIM(ZZG_STAT) IN ('2','4','5','6','8','10')"
   cSql += " ORDER BY ZZG_ORDE"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MAIORQUE", .T., .T. )

   If T_MAIORQUE->( EOF() )
   Else
      If T_MAIORQUE->ZZG_ORDE > nAgravar
         nAgravar := INT((T_ORDEM01->ORDEM01 + T_MAIORQUE->ZZG_ORDE) / 2)
      Endif
   Endif

   // Atualiza o registro da Tarefa Aprovada ou Reprovada
   aArea := GetArea()

   DbSelectArea("ZZG")
   DbSetOrder(1)
   If DbSeek(xfilial("ZZG") + Substr(cCodigo,01,06) + Substr(cCodigo,08,02))
      RecLock("ZZG",.F.)

      ZZG_TITU := cTitulo
      ZZG_USUA := cUsuario
      ZZG_DATA := Ctod(dData01)
      ZZG_HORA := cHora
  
      If Substr(cStatus,01,01) == "2"
         ZZG_STAT := "10"
         ZZG_ESTI := "01"         
         ZZG_ORDE := nAgravar
         ZZG_APAR := Date()
      Else
         ZZG_STAT := Substr(cStatus,01,01)
      Endif

      ZZG_PRIO := Substr(cPrioridade,01,06)
      ZZG_PREV := Ctod(dPrevisto)
      ZZG_TERM := Ctod(dTermino)
      ZZG_PROD := Ctod(dProducao)
      ZZG_ORIG := Substr(cOrigem,01,06)
      ZZG_CHAM := cChamado
      ZZR_COMP := Substr(cComponente,01,06)
      ZZG_PROG := Substr(cProgramador,01,06)
      ZZG_DES1 := cTexto
      ZZG_SOL1 := cSolucao 
      ZZG_NOT1 := cNota
      MsUnLock()              

      dbSelectArea("ZZH")
      RecLock("ZZH",.T.)
      ZZH_CODI := Substr(cCodigo,01,06)
      ZZH_SEQU := Substr(cCodigo,08,02)
      ZZH_DATA := Date()
      ZZH_HORA := Time()
      ZZH_STAT := Substr(cStatus,01,01)
      ZZH_DELE := " "
      MsUnLock()

      // Pesquisa o e-mail do usuário da tarefa para envio do e-mail informativo
      If Select("T_USUARIO") > 0
         T_USUARIO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZA_CODI, "
      cSql += "       ZZA_NOME, "
      cSql += "       ZZA_EMAI  "
      cSql += "  FROM " + RetSqlName("ZZA")
      cSql += " WHERE ZZA_NOME = '" + Alltrim(cUsuario) + "'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIO", .T., .T. )

      If !Empty(T_USUARIO->ZZA_EMAI)
         // Envia E-mail
         cEmail := ""
         cEmail := "Prezado(a) Usuário(a),"
         cEmail += chr(13) + chr(10)
         cEmail += chr(13) + chr(10)   
         cEmail += "Sua solicitação via Tarefa nº " + Substr(cCodigo,01,06) + "." + Substr(cCodigo,08,02)
         cEmail += chr(13) + chr(10)
         cEmail += Alltrim(cTitulo)
         cEmail += chr(13) + chr(10)

         If Substr(cStatus,01,01) == '2'
            cEmail += "foi APROVADA."
            cEmail += chr(13) + chr(10)
            cEmail += chr(13) + chr(10)
            cEmail += "Aguarde Desenvolvimento."
            If !Empty(Alltrim(cSolucao))
               cEmail += chr(13) + chr(10)
               cEmail += chr(13) + chr(10)
               cEmail += "Observação:"
               cEmail += chr(13) + chr(10)
               cEmail += chr(13) + chr(10)
               cEmail += Alltrim(cSolucao)
               cEmail += chr(13) + chr(10)
               cEmail += chr(13) + chr(10)
            Endif   
         Else
            cEmail += "foi REPROVADA."
            cEmail += chr(13) + chr(10)
            cEmail += chr(13) + chr(10)
            If !Empty(Alltrim(cSolucao))
               cEmail += chr(13) + chr(10)
               cEmail += chr(13) + chr(10)
               cEmail += "Motivo:"
               cEmail += chr(13) + chr(10)
               cEmail += chr(13) + chr(10)
               cEmail += Alltrim(cSolucao)
               cEmail += chr(13) + chr(10)
               cEmail += chr(13) + chr(10)
            Endif   
         Endif

         If Empty(Alltrim(T_USUARIO->ZZA_EMAI))
         Else
            // Envia e-mail ao Aprovador
            U_AUTOMR20(cEmail , ;
                       Alltrim(T_USUARIO->ZZA_EMAI)                       , ;
                       ""                                                 , ;
                       "Retorno de Solicitação de Aprovação de Tarefa" )
         Endif              
      Endif

   Endif   

   ODlg:End()

Return Nil                                                                   