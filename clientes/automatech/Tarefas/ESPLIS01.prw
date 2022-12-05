#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPLIS01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 18/07/2013                                                          *
// Objetivo..: Programa que pesquisa/Lista Projeto Selecionado                     *
//**********************************************************************************

User Function ESPLIS01()

   Local cSql        := ""
   Local lChumba     := .F.

   Private aProjetos := {}
   Private aTarefas  := {}
   Private aStatus   := {"T - Todos", "A - Abertas", "E - Encerradas"}

   Private cProjetos := "          "
   Private cTarefas  := "          "
   Private cStatus   := "          "
   Private cCliente	 := Space(06)
   Private cLoja	 := Space(03)
   Private cNomeCli	 := Space(60)
   Private cMemo1	 := ""
   Private oGet1
   Private oGet2
   Private oGet3
   Private oMemo1

   Private aBrowsekk := {}

   Private oDlg

   // Carrega o ComboBox dos Projetos
   If Select("T_PROJETO") > 0
      T_PROJETO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZY_CODIGO, "
   cSql += "       A.ZZY_CHAVE   "
   cSql += "  FROM " + RetSqlName("ZZY") + " A "
   cSql += " WHERE A.ZZY_DELETE = ''"
   cSql += " ORDER BY A.ZZY_CHAVE  "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROJETO", .T., .T. )

   If T_PROJETO->( EOF() )
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "O cadastro de Projetos está vazio.")
      Return .T.
   Endif

   aAdd( aProjetos, "         " )

   T_PROJETO->( DbGoTop() )
   WHILE !T_PROJETO->( EOF() )
      aAdd( aProjetos, T_PROJETO->ZZY_CODIGO + " - " + Alltrim(T_PROJETO->ZZY_CHAVE) )
      T_PROJETO->( DbSkip() )
   ENDDO

   // Desenha a tela de pesquisa de tarefas por projeto
   DEFINE MSDIALOG oDlg TITLE "Tarefas por Projeto" FROM C(183),C(002) TO C(620),C(1000) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(130),C(027) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(490),C(001) PIXEL OF oDlg

   @ C(035),C(269) Say "Cliente" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(005) Say "Projeto" Size C(019),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(103) Say "Tarefa"  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(035),C(204) Say "Status"  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(044),C(005) ComboBox cProjetos Items aProjetos Size C(093),C(010) PIXEL OF oDlg ON CHANGE CargaTarefas()
   @ C(044),C(103) ComboBox cTarefas  Items aTarefas  Size C(096),C(010) PIXEL OF oDlg
   @ C(044),C(204) ComboBox cStatus   Items aStatus   Size C(057),C(010) PIXEL OF oDlg

   @ C(044),C(269) MsGet oGet1 Var cCliente Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg F3("SA1")
   @ C(044),C(300) MsGet oGet2 Var cLoja    Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg VALID( __pqcliente(cCliente, cLoja) )
   @ C(044),C(323) MsGet oGet3 Var cNomeCli Size C(135),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba

   @ C(042),C(460) Button "Pesquisar"             Size C(037),C(012) PIXEL OF oDlg ACTION( AtlGridTar() )
   @ C(204),C(004) Button "Nova Tarefa"           Size C(046),C(012) PIXEL OF oDlg ACTION( TRATA_TAREFA(aBrowsekk[oBrowsekk:nAt,03], 2) )
   @ C(204),C(051) Button "Alterar Tarefa"        Size C(046),C(012) PIXEL OF oDlg ACTION( TRATA_TAREFA(aBrowsekk[oBrowsekk:nAt,03], 1) )
   @ C(204),C(227) Button "Apontar Horas"         Size C(072),C(012) PIXEL OF oDlg ACTION( U_ESPTAR17() )
   @ C(204),C(301) Button "Consulta Apontamentos" Size C(072),C(012) PIXEL OF oDlg ACTION( U_ESPAPO01() )
   @ C(204),C(460) Button "Voltar"                Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // Inicializa o browse 
   oBrowsekk := TCBrowse():New( 075 , 005, 630, 182,,{'Cliente', 'Projeto', 'Código', 'Tarefas', 'Hrs Cobradas', 'Status'}, {20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   // Seta vetor para a browse                            
   oBrowsekk:SetArray(aBrowsekk) 
    
   // Monta a linha a ser exibina no Browse
   If Len(aBrowsekk) == 0
      aAdd( aBrowsekk, { "", "", "", "", "", "" })
   Endif

   oBrowsekk:bLine := {||{ aBrowsekk[oBrowsekk:nAt,01],;
                           aBrowsekk[oBrowsekk:nAt,02],;
                           aBrowsekk[oBrowsekk:nAt,03],;
                           aBrowsekk[oBrowsekk:nAt,04],;
                           aBrowsekk[oBrowsekk:nAt,05],;
                           aBrowsekk[oBrowsekk:nAt,06]}}
      
   oBrowsekk:Refresh()

   oBrowsekk:bHeaderClick := {|oObj,nCol| oBrowsekk:aArray := Ordenar(nCol,oBrowsekk:aArray),oBrowsekk:Refresh()}
   
   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que Ordena a coluna selecionada no grid
Static Function Ordenar(_nPosCol,_aOrdena)

   _aOrdena := ASort (_aOrdena,,,{|x,y| x[_nPosCol] < y[_nPosCol]  }) // Ordenando Arrays

Return(_aOrdena)

// Função que carrega as tarefas conforme projeto selecionado no combo de projetos
Static Function CargaTarefas()

   Local cSql := ""

   If Empty(Alltrim(Substr(cProjetos,01,06)))
      aTarefas := {}
      Return(.T.)
   Endif
      
   // Carrega o combo das tarefas do projeto
   If Select("T_TAREFAS") > 0
      T_TAREFAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZG_CODI,"
   cSql += "       A.ZZG_SEQU,"
   cSql += "       A.ZZG_TITU,"
   cSql += "       A.ZZG_STAT,"
   cSql += "       A.ZZG_HTOT,"
   cSql += "       B.ZZE_NOME "
   cSql += "  FROM " + RetSqlName("ZZG") + " A, "
   cSql += "       " + RetSqlName("ZZE") + " B  "
   cSql += " WHERE A.ZZG_PROJ = '" + Substr(cProjetos,01,06) + "'"
   cSql += "   AND A.ZZG_DELE = ''"
   cSql += "   AND A.ZZG_STAT <> '1'"
   cSql += "   AND A.ZZG_PROG = B.ZZE_CODIGO"
   cSql += "   AND B.ZZE_DELETE = ''" 
   cSql += " ORDER BY A.ZZG_CODI DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAREFAS", .T., .T. )

   // Carrega o Combo das Tarefas
   aTarefas := {"          "}
   T_TAREFAS->( EOF() )
   WHILE !T_TAREFAS->( EOF() )
      aAdd( aTarefas, Alltrim(T_TAREFAS->ZZG_CODI) + "." + Alltrim(T_TAREFAS->ZZG_SEQU) + " - " + T_TAREFAS->ZZG_TITU + " Des.: " + Alltrim(T_TAREFAS->ZZE_NOME))
      T_TAREFAS->( DbSkip() )
   ENDDO

   If Len(aTarefas) == 0
      aAdd( aTarefas, "" )
   Endif   

   @ C(044),C(103) ComboBox cTarefas  Items aTarefas  Size C(096),C(010) PIXEL OF oDlg

Return(.T.)

// Função que pesquisa o cliente informado
Static Function __pqcliente(__Cliente, __cLoja)

   If Empty(Alltrim(__Cliente))
      Return(.T.)
   Endif
   
   If Empty(Alltrim(__cLoja))
      Return(.T.)
   Endif
      
   cNomeCli := POSICIONE("SA1",1,XFILIAL("SA1") + __Cliente + __cLoja, "A1_NOME")
   
Return(.T.)   

// Função que atualiza o grid com os dados de filtros informados
Static Function AtlGridTar()

   Local cSql := ""

   // Carrega o combo das tarefas do projeto
   If Select("T_TAREFAS") > 0
      T_TAREFAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZG_PROJ  ,"
   cSql += "       A.ZZG_CODI  ,"
   cSql += "       A.ZZG_SEQU  ,"
   cSql += "       A.ZZG_TITU  ,"
   cSql += "       A.ZZG_STAT  ,"
   cSql += "       A.ZZG_SITU  ,"
   cSql += "       A.ZZG_HTOT  ,"
   cSql += "       A.ZZG_HCOB  ,"
   cSql += "       B.ZZE_NOME  ,"
   cSql += "       C.ZZY_TITULO," 
   cSql += "       C.ZZY_CHAVE ,"
   cSql += "       C.ZZY_CLIENT,"
   cSql += "       C.ZZY_LOJA  ,"
   cSql += "       D.A1_NOME   ,"
   cSql += "       A.ZZG_OCLI  ,"
   cSql += "       A.ZZG_OLOJ  ,"
   cSql += "   (SELECT A1_NOME "
   cSql += "      FROM " + RetSqlName("SA1")
   cSql += "     WHERE A1_COD  = A.ZZG_OCLI "
   cSql += "       AND A1_LOJA = A.ZZG_OLOJ "
   cSql += "       AND D_E_L_E_T_ = '') AS OUTROCLI"
   cSql += "  FROM " + RetSqlName("ZZG") + " A, " 
   cSql += "       " + RetSqlName("ZZE") + " B, "  
   cSql += "       " + RetSqlName("ZZY") + " C, "
   cSql += "       " + RetSqlName("SA1") + " D  "

   cSql += " WHERE A.ZZG_DELE = ' '"

   // Filtra pelo projeto informado
   If !Empty(Alltrim(Substr(cProjetos,01,06)))
      cSql += "   AND A.ZZG_PROJ = '" + Alltrim(Substr(cProjetos,01,06)) + "'"
   Endif
      
   // Filtra pela tarefa informada
   If !Empty(Alltrim(Substr(cTarefas,01,06)))  
      cSql += "   AND A.ZZG_CODI = '" + Alltrim(Substr(cTarefas,01,06)) + "'"
      cSql += "   AND A.ZZG_SEQU = '" + Alltrim(Substr(cTarefas,08,02)) + "'"
   Endif
   
   // Filtra pelo cliente informado   
   If !Empty(Alltrim(cCliente))
      cSql += "   AND (C.ZZY_CLIENT = '" + Alltrim(cCliente) + "'"
      cSql += "   AND  C.ZZY_LOJA   = '" + Alltrim(cLoja)    + "'"
      cSql += "    OR  A.ZZG_OCLI   = '" + Alltrim(cCliente) + "'"
      cSql += "   AND  A.ZZG_OLOJ   = '" + Alltrim(cLoja)    + "')"
   Endif
   
   // Filtra pelo Status informado
   If Substr(cStatus,01,01) <> "T"
      If Substr(cStatus,01,01) == "A"
         cSql += " AND A.ZZG_STAT = '1'
      Else
         cSql += " AND A.ZZG_STAT = '2'         
      Endif
   Endif

   cSql += "   AND A.ZZG_PROG   = B.ZZE_CODIGO"
   cSql += "   AND B.ZZE_DELETE = ''"
   cSql += "   AND C.ZZY_CODIGO = A.ZZG_PROJ  "
   cSql += "   AND C.ZZY_DELETE = ''          "
   cSql += "   AND D.A1_COD     = C.ZZY_CLIENT"
   cSql += "   AND D.A1_LOJA    = C.ZZY_LOJA  "
   cSql += " ORDER BY A.ZZG_CODI DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAREFAS", .T., .T. )

   aBrowsekk := {}

   // Carrega o Combo das Tarefas (aBrowsekk)
   T_TAREFAS->( EOF() )
   WHILE !T_TAREFAS->( EOF() )

      If Empty(Alltrim(T_TAREFAS->OUTROCLI))
         ___Cliente := T_TAREFAS->ZZY_CLIENT + "." + T_TAREFAS->ZZY_LOJA + " - " + Alltrim(T_TAREFAS->A1_NOME)
      Else
         ___Cliente := T_TAREFAS->ZZG_OCLI   + "." + T_TAREFAS->ZZG_OLOJ + " - " + Alltrim(T_TAREFAS->OUTROCLI)         
      Endif
                     
//      If T_TAREFAS->ZZG_STAT = '1'
//         ___Status := "Aberta"
//      Else
//         ___Status := "Encerrada"
//      Endif

      Do Case
         Case T_TAREFAS->ZZG_SITU == "A"
              ___Status := "Aberta"      
         Case T_TAREFAS->ZZG_SITU == "E"
              ___Status := "Encerrada"      
         Otherwise
              ___Status := "Aberta"
      EndCase

      aAdd( aBrowsekk, { ___Cliente, T_TAREFAS->ZZY_CHAVE, Alltrim(T_TAREFAS->ZZG_CODI) + "." + Alltrim(T_TAREFAS->ZZG_SEQU), T_TAREFAS->ZZG_TITU, T_TAREFAS->ZZG_HCOB, ___Status } )

      T_TAREFAS->( DbSkip() )

   ENDDO

   // Ordena o Array para Impressão
   ASORT(aBrowsekk,,,{ | x,y,z | x[1] + x[2] + x[3] < y[1] + y[2] + y[3] } )

   If Len(aBrowsekk) == 0
      aAdd( aBrowsekk, { "", "", "", "", "", "" } )
   Endif   

   // Seta vetor para a browse                            
   oBrowsekk:SetArray(aBrowsekk) 
   oBrowsekk:bLine := {||{ aBrowsekk[oBrowsekk:nAt,01],;
                           aBrowsekk[oBrowsekk:nAt,02],;
                           aBrowsekk[oBrowsekk:nAt,03],;
                           aBrowsekk[oBrowsekk:nAt,04],;
                           aBrowsekk[oBrowsekk:nAt,05],;
                           aBrowsekk[oBrowsekk:nAt,06]}}
      
   oBrowsekk:Refresh()

Return(.T.)

// Função que envia para a alteração da tarefa do projeto
Static Function TRATA_TAREFA(__Tarefa, __Operacao)

   // Envia para a tela de manutenção de tarefa
   Do Case
      Case __Operacao == 1
           U_ESPTAR19(__Tarefa, "A")
      Case __Operacao == 2
           U_ESPTAR15("N")
      Case __Operacao == 3
           U_ESPTAR19(__Tarefa, "E")
   EndCase

   AtlGridTar()
   
   Return(.T.)


   aTarefas := {}

   // Atualiza o Grid com as tarefa do projeto
   If Select("T_TAREFAS") > 0
      T_TAREFAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZG_CODI,"
   cSql += "       A.ZZG_SEQU,"
   cSql += "       A.ZZG_TITU,"
   cSql += "       A.ZZG_STAT,"
   cSql += "       A.ZZG_HTOT,"
   cSql += "       B.ZZE_NOME "
   cSql += "  FROM " + RetSqlName("ZZG") + " A, "
   cSql += "       " + RetSqlName("ZZE") + " B  "
   cSql += " WHERE A.ZZG_PROJ = '" + Substr(cProjetos,01,06) + "'"
   cSql += "   AND A.ZZG_DELE = ''"
   cSql += "   AND A.ZZG_STAT <> '1'"
   cSql += "   AND A.ZZG_PROG = B.ZZE_CODIGO"
   cSql += "   AND B.ZZE_DELETE = ''" 
   cSql += " ORDER BY A.ZZG_CODI DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAREFAS", .T., .T. )

   // Carrega o Combo das Tarefas
   aTarefas := {}
   T_TAREFAS->( EOF() )
   WHILE !T_TAREFAS->( EOF() )
      aAdd( aTarefas, Alltrim(T_TAREFAS->ZZG_CODI) + "." + Alltrim(T_TAREFAS->ZZG_SEQU) + " - " + T_TAREFAS->ZZG_TITU + " Des.: " + Alltrim(T_TAREFAS->ZZE_NOME))
      T_TAREFAS->( DbSkip() )
   ENDDO

   oTarefas:SetArray(aTarefas)
   oTarefas:bLine := {|| {aTarefas[oTarefas:nAt]} }

Return(.T.)

// Função que realiza a pesquisa das tarefas do projeto selecionado
Static Function tempoTar()

   Local cSql        := ""

   Private aProjetos := {}
   Private cProjetos

   Private oDlg

   // Carrega o ComboBox dos Projetos
   If Select("T_PROJETO") > 0
      T_PROJETO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZY_CODIGO, "
   cSql += "       A.ZZY_CHAVE   "
   cSql += "  FROM " + RetSqlName("ZZY") + " A "
   cSql += " WHERE A.ZZY_DELETE = ''"
   cSql += " ORDER BY A.ZZY_CHAVE  "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROJETO", .T., .T. )

   If T_PROJETO->( EOF() )
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "O cadastro de Projetos está vazio.")
      Return .T.
   Endif

   aAdd( aProjetos, "Selecione um Projeto para a pesquisa." )

   T_PROJETO->( DbGoTop() )
   WHILE !T_PROJETO->( EOF() )
      aAdd( aProjetos, T_PROJETO->ZZY_CODIGO + " - " + Alltrim(T_PROJETO->ZZY_CHAVE) )
      T_PROJETO->( DbSkip() )
   ENDDO

   DEFINE MSDIALOG oDlg TITLE "Lista de Tarefas por Projeto" FROM C(178),C(181) TO C(283),C(504) PIXEL

   @ C(004),C(005) Say "Projetos" Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(005) ComboBox cProjetos Items aProjetos Size C(151),C(010) PIXEL OF oDlg
   
// @ C(032),C(040) Button "Ver Cadastro" Size C(037),C(012) PIXEL OF oDlg
   @ C(032),C(079) Button "Pesquisar"    Size C(037),C(012) PIXEL OF oDlg ACTION( ListaTar() )
   @ C(032),C(117) Button "Voltar"       Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que realiza a pesquisa das tarefas do projeto selecionado
Static Function ListaTar()
                                             
   Local lChumba    := .F.
   Local cNprojeto  := ""
   Local oNprojeto

   Private aTarefas := {}
   Private oTarefas

   Private oDlgTx

   If Substr(cProjetos,01,09) == "Selecione"
      MsgAlert("Selecione um Projeto para a pesquisa.")
      Return(.T.)
   Endif

   cNprojeto  := cProjetos

   // Carrega o combo das tarefas do projeto
   If Select("T_TAREFAS") > 0
      T_TAREFAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZG_CODI,"
   cSql += "       A.ZZG_SEQU,"
   cSql += "       A.ZZG_TITU,"
   cSql += "       A.ZZG_STAT,"
   cSql += "       A.ZZG_HTOT,"
   cSql += "       B.ZZE_NOME "
   cSql += "  FROM " + RetSqlName("ZZG") + " A, "
   cSql += "       " + RetSqlName("ZZE") + " B  "
   cSql += " WHERE A.ZZG_PROJ = '" + Substr(cProjetos,01,06) + "'"
   cSql += "   AND A.ZZG_DELE = ''"
   cSql += "   AND A.ZZG_STAT <> '1'"
   cSql += "   AND A.ZZG_PROG = B.ZZE_CODIGO"
   cSql += "   AND B.ZZE_DELETE = ''" 
   cSql += " ORDER BY A.ZZG_CODI DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAREFAS", .T., .T. )

   // Carrega o Combo das Tarefas
   aTarefas := {}
   T_TAREFAS->( EOF() )
   WHILE !T_TAREFAS->( EOF() )
      aAdd( aTarefas, Alltrim(T_TAREFAS->ZZG_CODI) + "." + Alltrim(T_TAREFAS->ZZG_SEQU) + " - " + T_TAREFAS->ZZG_TITU + " Des.: " + Alltrim(T_TAREFAS->ZZE_NOME))
      T_TAREFAS->( DbSkip() )
   ENDDO

   If Len(aTarefas) == 0
      aAdd( aTarefas, "" )
   Endif   

   DEFINE MSDIALOG oDlgTx TITLE "Tarefas do Projehto Selecionado" FROM C(178),C(181) TO C(602),C(675) PIXEL

   @ C(004),C(005) Say "Projeto"     Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgTx

   @ C(013),C(005) MsGet oNprojeto   Var cNprojeto When lChumba Size C(170),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgTx

   @ C(012),C(175) Button "Visão Geral do Projeto" Size C(068),C(012) PIXEL OF oDlgTx ACTION( U_ESPARV01(Substr(cNProjeto,01,06), .F.) )

   @ C(026),C(005) ListBox oTarefas  Fields HEADER "Tarefas do Projeto" Size C(238),C(165) Of oDlgTx Pixel ;
                   ON LEFT DBLCLICK ( MOSTRA_TAR(aTarefas[oTarefas:nAt])), ON RIGHT CLICK (MOSTRA_TAR(aTarefas[oTarefas:nAt]))

   @ C(195),C(005) Button "Altera Tarefa" Size C(050),C(012) PIXEL OF oDlgTx ACTION( TRATA_TAREFA(aTarefas[oTarefas:nAt], 1) )
   @ C(195),C(057) Button "Nova Tarefa"   Size C(050),C(012) PIXEL OF oDlgTx ACTION( TRATA_TAREFA(aTarefas[oTarefas:nAt], 2) )
   @ C(195),C(204) Button "Retornar"      Size C(037),C(012) PIXEL OF oDlgTx ACTION( oDlgTx:End() )

   oTarefas:SetArray(aTarefas)
   
   oTarefas:bLine := {|| {aTarefas[oTarefas:nAt]} }

   ACTIVATE MSDIALOG oDlgTx CENTERED 

Return(.T.)

// Função que abre tela de cadastro da tarefa selecionada
Static Function MOSTRA_TAR()
Return(.T.)

// Função que envia para a alteração da tarefa do projeto
Static Function xTRATA_TAREFA(__Tarefa, __Operacao)

   // Envia para a tela de manutenção de tarefa
   If __Operacao == 1
      U_ESPTAR19(__Tarefa)
   Else
      U_ESPTAR15("N")
   Endif   

   aTarefas := {}

   // Atualiza o Grid com as tarefa do projeto
   If Select("T_TAREFAS") > 0
      T_TAREFAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZG_CODI,"
   cSql += "       A.ZZG_SEQU,"
   cSql += "       A.ZZG_TITU,"
   cSql += "       A.ZZG_STAT,"
   cSql += "       A.ZZG_HTOT,"
   cSql += "       B.ZZE_NOME "
   cSql += "  FROM " + RetSqlName("ZZG") + " A, "
   cSql += "       " + RetSqlName("ZZE") + " B  "
   cSql += " WHERE A.ZZG_PROJ = '" + Substr(cProjetos,01,06) + "'"
   cSql += "   AND A.ZZG_DELE = ''"
   cSql += "   AND A.ZZG_STAT <> '1'"
   cSql += "   AND A.ZZG_PROG = B.ZZE_CODIGO"
   cSql += "   AND B.ZZE_DELETE = ''" 
   cSql += " ORDER BY A.ZZG_CODI DESC"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAREFAS", .T., .T. )

   // Carrega o Combo das Tarefas
   aTarefas := {}
   T_TAREFAS->( EOF() )
   WHILE !T_TAREFAS->( EOF() )
      aAdd( aTarefas, Alltrim(T_TAREFAS->ZZG_CODI) + "." + Alltrim(T_TAREFAS->ZZG_SEQUE) + " - " + T_TAREFAS->ZZG_TITU + " Des.: " + Alltrim(T_TAREFAS->ZZE_NOME))
      T_TAREFAS->( DbSkip() )
   ENDDO

   oTarefas:SetArray(aTarefas)
   oTarefas:bLine := {|| {aTarefas[oTarefas:nAt]} }

Return(.T.)