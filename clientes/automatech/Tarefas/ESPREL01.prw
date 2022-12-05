#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPREL01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 20/08/2013                                                          *
// Objetivo..: Emissão relatório de Tarefas                                        *
//**********************************************************************************

User Function ESPREL01()

   Local cSql          := ""

   Private cDesc1      := "Este programa tem como objetivo imprimir relatorio "
   Private cDesc2      := "de acordo com os parametros informados pelo usuario."
   Private cDesc3      := ""
   Private cPict       := ""
   Private titulo      := ""
   Private nLin        := 80
   Private nPagina     := 0
   
   Private Cabec1      := ""
   Private Cabec2      := ""
   Private imprime     := .T.
   Private aOrd        := {}

   Private lEnd        := .F.
   Private lAbortPrint := .F.
   Private CbTxt       := ""
   Private limite      := 220
   Private tamanho     := "G"
   Private nomeprog    := "ESPREL01"
   Private nTipo       := 18
   Private aReturn     := { "Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
   Private nLastKey    := 0
   Private cbtxt       := Space(10)
   Private cbcont      := 00
   Private CONTFL      := 01
   Private m_pag       := 01
   Private wnrel       := ""

   Private aUsuarios   := {}
   Private aModulos    := {}
   Private aResponsa   := {}
   Private aDesenve    := {}
   Private aPriori     := {}
   Private aStatus     := {}

   Private cUsuarios
   Private cxModulos
   Private cResponsa
   Private cDesenve
   Private cPriori
   Private cStatus

   Private cInicial    := Ctod("  /  /    ")
   Private cFinal      := Ctod("  /  /    ")
   Private oGet1
   Private oGet2

   Private oDlg

   Private cString     := "SA3"

   dbSelectArea("SA3")
   dbSetOrder(1)

   // Carrega o Combo de usuários
   If Select("T_USUARIOS") > 0
      T_USUARIOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZA_CODI,"            + CHR(13)
   cSql += "       ZZA_NOME "            + CHR(13)
   cSql += "  FROM " + RetSqlName("ZZA") + CHR(13)
   cSql += " WHERE D_E_L_E_T_ = ''"      + CHR(13)
   cSql += " ORDER BY ZZA_NOME"          + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIOS", .T., .T. )

   T_USUARIOS->( DbGoTop() )

   aAdd( aUsuarios, "Todos os Usuários" )

   WHILE !T_USUARIOS->( EOF() )
      aAdd( aUsuarios, T_USUARIOS->ZZA_CODI + " - " + Upper(Alltrim(T_USUARIOS->ZZA_NOME)) )
      T_USUARIOS->( DbSkip() )
   ENDDO
         
   // Carrega o Combo de Módulos
   If Select("T_MODULOS") > 0
      T_MODULOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZB_CODIGO,"          + CHR(13)
   cSql += "       ZZB_NOME "            + CHR(13)
   cSql += "  FROM " + RetSqlName("ZZB") + CHR(13)
   cSql += " WHERE ZZB_DELETE = ' '"     + CHR(13)
   cSql += " ORDER BY ZZB_NOME"          + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MODULOS", .T., .T. )

   T_MODULOS->( DbGoTop() )

   aAdd( aModulos, "Todos os Móduos" )

   WHILE !T_MODULOS->( EOF() )
      aAdd( aModulos, T_MODULOS->ZZB_CODIGO + " - " + Upper(Alltrim(T_MODULOS->ZZB_NOME)) )
      T_MODULOS->( DbSkip() )
   ENDDO

   // Carrega o Combo de Responsáveis
   If Select("T_RESPONSA") > 0
      T_RESPONSA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZF_CODIGO,"          + CHR(13)
   cSql += "       ZZF_NOME "            + CHR(13)
   cSql += "  FROM " + RetSqlName("ZZF") + CHR(13)
   cSql += " WHERE ZZF_DELETE = ' '"     + CHR(13)
   cSql += " ORDER BY ZZF_NOME"          + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RESPONSA", .T., .T. )

   T_RESPONSA->( DbGoTop() )

   aAdd( aResponsa, "Todos os Responsáveis" )

   WHILE !T_RESPONSA->( EOF() )
      aAdd( aResponsa, T_RESPONSA->ZZF_CODIGO + " - " + Upper(Alltrim(T_RESPONSA->ZZF_NOME)) )
      T_RESPONSA->( DbSkip() )
   ENDDO

   // Carrega o Combo de Desenvolvedores
   If Select("T_DESENVOLVE") > 0
      T_DESENVOLVE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZE_CODIGO,"          + CHR(13)
   cSql += "       ZZE_NOME "            + CHR(13)
   cSql += "  FROM " + RetSqlName("ZZE") + CHR(13)
   cSql += " WHERE ZZE_DELETE = ' '"     + CHR(13)
   cSql += " ORDER BY ZZE_NOME"          + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DESENVOLVE", .T., .T. )

   T_DESENVOLVE->( DbGoTop() )

   aAdd( aDesenve, "Todos os Desenvolvedores" )

   WHILE !T_DESENVOLVE->( EOF() )
      aAdd( aDesenve, T_DESENVOLVE->ZZE_CODIGO + " - " + Upper(Alltrim(T_DESENVOLVE->ZZE_NOME)) )
      T_DESENVOLVE->( DbSkip() )
   ENDDO

   // Carrega o Combo de Prioridade
   If Select("T_PRIORIDADE") > 0
      T_PRIORIDADE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZD_CODIGO,"          + CHR(13)
   cSql += "       ZZD_NOME "            + CHR(13)
   cSql += "  FROM " + RetSqlName("ZZD") + CHR(13)
   cSql += " WHERE ZZD_DELETE = ' '"     + CHR(13)
   cSql += " ORDER BY ZZD_NOME"          + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRIORIDADE", .T., .T. )

   T_PRIORIDADE->( DbGoTop() )

   aAdd( aPriori, "Todos as Prioridades" )

   WHILE !T_PRIORIDADE->( EOF() )
      aAdd( aPriori, T_PRIORIDADE->ZZD_CODIGO + " - " + Upper(Alltrim(T_PRIORIDADE->ZZD_NOME)) )
      T_PRIORIDADE->( DbSkip() )
   ENDDO

   // Carrega o Combo de Status
   aAdd( aStatus, "Todos os Status" )
   aAdd( aStatus, "1 - ABERTURA" )
   aAdd( aStatus, "2 - APROVADA" )
   aAdd( aStatus, "3 - REPROVADA" )
   aAdd( aStatus, "4 - DESENVOLVIMENTO" )      
   aAdd( aStatus, "5 - VALIDAÇÃO" )
   aAdd( aStatus, "6 - RETORNO PARA DESENVOVIMENTO" )
   aAdd( aStatus, "7 - EM PRODUÇÃO" )
   aAdd( aStatus, "8 - LIBERADA PARA PRODUÇÃO" )   
   aAdd( aStatus, "9 - TAREFA ENCERRADA" )

   DEFINE MSDIALOG oDlg TITLE "Relatório de Tarefas" FROM C(178),C(181) TO C(545),C(505) PIXEL

   @ C(005),C(005) Say "Dta Inclusão Inicial" Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(059) Say "Dta Inclusão Final"   Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(005) Say "Usuários"             Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(048),C(005) Say "Módulos"              Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(069),C(005) Say "Responsável"          Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(092),C(005) Say "Desenvolvedor"        Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(114),C(005) Say "Prioridade"           Size C(026),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(137),C(005) Say "Status"               Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(005) MsGet    oGet1     Var   cInicial  Size C(046),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(059) MsGet    oGet2     Var   cFinal    Size C(046),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(034),C(005) ComboBox cUsuarios Items aUsuarios Size C(152),C(010) PIXEL OF oDlg
   @ C(057),C(005) ComboBox cxModulos Items aModulos  Size C(152),C(010) PIXEL OF oDlg
   @ C(078),C(005) ComboBox cResponsa Items aResponsa Size C(152),C(010) PIXEL OF oDlg
   @ C(101),C(005) ComboBox cDesenve  Items aDesenve  Size C(152),C(010) PIXEL OF oDlg
   @ C(123),C(005) ComboBox cPriori   Items aPriori   Size C(152),C(010) PIXEL OF oDlg
   @ C(146),C(005) ComboBox cStatus   Items aStatus   Size C(152),C(010) PIXEL OF oDlg

   @ C(164),C(043) Button "O K"    Size C(037),C(012) PIXEL OF oDlg ACTION( RodaRelatorio() )
   @ C(164),C(081) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que Abre o relatório
Static Function RodaRelatorio()

   If Empty(cInicial)
      MsgAlert("Data inicial de inclusão não informada.")
      Return .T.
   Endif
      
   If Empty(cFinal)
      MsgAlert("Data final de inclusão não informada.")
      Return .T.
   Endif

   // Monta a interface padrao com o usuário
   wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.T.,Tamanho,,.T.)

   If nLastKey == 27
      Return
   Endif

   SetDefault(aReturn,cString)

   If nLastKey == 27
      Return
   Endif

   nTipo := If(aReturn[4]==1,15,18)

   // Processamento. RPTSTATUS monta janela com a regua de processamento
   RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)

Return

// Executa o Relatório
Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)

   Local cSql      := ""
   Local nOrdem
   Local __Usuario := ""
   Local __Status  := ""

   dbSelectArea(cString)
   dbSetOrder(1)

   // SETREGUA -> Indica quantos registros serao processados para a regua
   SetRegua(RecCount())

   // Pesquisa os dados para impressão
   If Select("T_TAREFAS") > 0
      T_TAREFAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZG_DATA AS DATA       ,"    + CHR(13)
   cSql += "       A.ZZG_CODI AS CODIGO     ,"    + CHR(13)
   cSql += "       A.ZZG_TITU AS TITULO     ,"    + CHR(13)
   cSql += "       A.ZZG_USUA AS USUARIO    ,"    + CHR(13)
   cSql += "       A.ZZG_STAT AS STATUS     ,"    + CHR(13)
   cSql += "       A.ZZG_COMP AS COD_MODULO ,"    + CHR(13)
   cSql += "       B.ZZB_NOME AS NOME_MODULO,"    + CHR(13)
   cSql += "       A.ZZG_PRIO AS COD_PRIORI ,"    + CHR(13)
   cSql += "       C.ZZD_NOME AS NOME_PRIORI,"    + CHR(13)
   cSql += "       A.ZZG_ORIG AS COD_RESPO  ,"    + CHR(13)
   cSql += "       D.ZZF_NOME AS NOME_RESPO ,"    + CHR(13)
   cSql += "       A.ZZG_PROG AS COD_DESEN  ,"    + CHR(13)
   cSql += "       E.ZZE_NOME AS NOME_DESEN  "    + CHR(13)
   cSql += "  FROM " + RetSqlName("ZZG") + " A, " + CHR(13)
   cSql += "       " + RetSqlName("ZZB") + " B, " + CHR(13)
   cSql += "       " + RetSqlName("ZZD") + " C, " + CHR(13)
   cSql += "       " + RetSqlName("ZZF") + " D, " + CHR(13)
   cSql += "       " + RetSqlName("ZZE") + " E  " + CHR(13)
   cSql += " WHERE A.ZZG_DELE   = ''            " + CHR(13)
   cSql += "   AND A.ZZG_COMP   = B.ZZB_CODIGO  " + CHR(13)
   cSql += "   AND B.ZZB_DELETE = ''            " + CHR(13)
   cSql += "   AND A.ZZG_PRIO   = C.ZZD_CODIGO  " + CHR(13)
   cSql += "   AND C.ZZD_DELETE = ''            " + CHR(13)
   cSql += "   AND A.ZZG_ORIG   = D.ZZF_CODIGO  " + CHR(13)
   cSql += "   AND D.ZZF_DELETE = ''            " + CHR(13)
   cSql += "   AND A.ZZG_PROG   = E.ZZE_CODIGO  " + CHR(13)
   cSql += "   AND E.ZZE_DELETE = ''            " + CHR(13)

   // Filtra por Usuário
   If Upper(Substr(cUsuarios,01,05)) <> "TODOS"
      cSql += "  AND LTRIM(UPPER(A.ZZG_USUA)) = '" + Alltrim(Upper(Substr(cUsuarios,10))) + "'"
   Endif

   // Filtra por Módulo
   If Upper(Substr(cxModulos,01,05)) <> "TODOS"
      cSql += "  AND A.ZZG_COMP = '" + Alltrim(Substr(cxModulos,01,06)) + "'"
   Endif
   
   // Filtra por Responsável
   If Upper(Substr(cResponsa,01,05)) <> "TODOS"
      cSql += "  AND A.ZZG_ORIG = '" + Alltrim(Substr(cResponsa,01,06)) + "'"
   Endif

   // Filtra por Desenvolvedor
   If Upper(Substr(cDesenve,01,05)) <> "TODOS"
      cSql += "  AND A.ZZG_PROG = '" + Alltrim(Substr(cDesenve,01,06)) + "'"
   Endif

   // Filtra por Prioridade
   If Upper(Substr(cPriori,01,05)) <> "TODOS"
      cSql += "  AND A.ZZG_PRIO = '" + Alltrim(Substr(cPriori,01,06)) + "'"
   Endif

   // Filtra por Status
   If Upper(Substr(cStatus,01,05)) <> "TODOS"
      cSql += "  AND A.ZZG_STAT = '" + Alltrim(Substr(cStatus,01,01)) + "'"
   Endif

   cSql += " ORDER BY A.ZZG_USUA, A.ZZG_STAT, A.ZZG_COMP, A.ZZG_CODI" + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAREFAS", .T., .T. )

   T_TAREFAS->( DbGoTop() )

   __Usuario := T_TAREFAS->USUARIO
   __Status  := T_TAREFAS->STATUS

   While !T_TAREFAS->( EOF() )

      If ALLTRIM(UPPER(T_TAREFAS->USUARIO)) == ALLTRIM(UPPER(__Usuario))
      
         If ALLTRIM(UPPER(T_TAREFAS->STATUS)) == ALLTRIM(UPPER(__Status))

            If nLin > 55
               nPagina := nPagina + 1
               nLin    := 1
               @ nLin,001 PSAY "AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA"
               @ nLin,084 PSAY "RELAÇÃO DE TAREFAS"
               @ nLin,180 PSAY dtoc(DATE()) + " - " + TIME()
               nLin := nLin + 1
               @ nLin,001 PSAY "ESPREL01.PRW"
               @ nLin,084 PSAY "PERÍODO DE " + Dtoc(cInicial) + " A " + Dtoc(cFinal)
               @ nLin,180 PSAY "PÁGINA:"
               @ nLin,195 PSAY Strzero(nPagina,6)
               nLin = nLin + 1
               @ nLin,001 PSAY "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
               nLin := nLin + 1
               @ nLin,001 PSAY "CODIGO   TÍTULO DA TAREFA                                                   DATA      MODULO                           RESPONSAVEL                      DESENVOLVEDOR                     PRIORIDADE"
               nLin := nLin + 1
               @ nLin,001 PSAY "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
               nLin := nLin + 2
               @ nLin,086 PSAY "USUÁRIO: " + Upper(__Usuario)
               nLin = nLin + 1

               Do Case
                  Case Alltrim(__Status) == "1"
                       @ nLin,086 PSAY "STATUS.: 1 - ABERTURA"
                  Case Alltrim(__Status) == "2"
                       @ nLin,086 PSAY "STATUS.: 2 - APROVADAS"
                  Case Alltrim(__Status) == "3"
                       @ nLin,086 PSAY "STATUS.: 3 - REPROVADAS"
                  Case Alltrim(__Status) == "4"
                       @ nLin,086 PSAY "STATUS.: 4 - DESENVOLVIMENTO"
                  Case Alltrim(__Status) == "5"
                       @ nLin,086 PSAY "STATUS.: 5 - VALIDAÇÃO"
                  Case Alltrim(__Status) == "6"
                       @ nLin,086 PSAY "STATUS.: 6 - RETORNO PARA DESENVOLVIMENTO"
                  Case Alltrim(__Status) == "7"
                       @ nLin,086 PSAY "STATUS.: 7 - EM PRODUÇÃO"
                  Case Alltrim(__Status) == "8"
                       @ nLin,086 PSAY "STATUS.: 8 - LIBERADAS PARA PRODUÇÃO"
                  Case Alltrim(__Status) == "9"
                       @ nLin,086 PSAY "STATUS.: 9 - ENCERRADAS"
               EndCase

               nLin = nLin + 2
            Endif   

            @ nlin,001 psay T_TAREFAS->CODIGO
            @ nlin,010 psay Substr(T_TAREFAS->TITULO,001,038)
            @ nlin,073 psay T_TAREFAS->DATA
            @ nlin,086 psay Substr(T_TAREFAS->NOME_MODULO,001,030)
            @ nlin,119 psay Substr(T_TAREFAS->NOME_RESPO,001,030)
            @ nlin,152 psay Substr(T_TAREFAS->NOME_DESEN,001,030)
            @ nlin,186 psay Substr(T_TAREFAS->NOME_PRIORI,001,015)
            
            nLin += 1

            T_TAREFAS->( DbSkip() )
            Loop
            
         Else
  
            __Status := T_TAREFAS->STATUS
            
            nLin += 2
            Do Case
               Case Alltrim(__Status) == "1"
                    @ nLin,086 PSAY "STATUS.: 1 - ABERTURA"
               Case Alltrim(__Status) == "2"
                    @ nLin,086 PSAY "STATUS.: 2 - APROVADAS"
               Case Alltrim(__Status) == "3"
                    @ nLin,086 PSAY "STATUS.: 3 - REPROVADAS"
               Case Alltrim(__Status) == "4"
                    @ nLin,086 PSAY "STATUS.: 4 - DESENVOLVIMENTO"
               Case Alltrim(__Status) == "5"
                    @ nLin,086 PSAY "STATUS.: 5 - VALIDAÇÃO"
               Case Alltrim(__Status) == "6"
                    @ nLin,086 PSAY "STATUS.: 6 - RETORNO PARA DESENVOLVIMENTO"
               Case Alltrim(__Status) == "7"
                    @ nLin,086 PSAY "STATUS.: 7 - EM PRODUÇÃO"
               Case Alltrim(__Status) == "8"
                    @ nLin,086 PSAY "STATUS.: 8 - LIBERADAS PARA PRODUÇÃO"
               Case Alltrim(__Status) == "9"
                    @ nLin,086 PSAY "STATUS.: 9 - ENCERRADAS"
            EndCase
            nLin = nLin + 2

            Loop
            
         Endif
         
      Else
            
         __Usuario := T_TAREFAS->USUARIO
            
         nLin += 2
         @ nLin,086 PSAY "USUÁRIO: " + __Usuario
         nLin = nLin + 2

         Loop
         
      Endif   
      
   ENDDO   

   // Finaliza a execucao do relatorio
   SET DEVICE TO SCREEN

   // Se impressao em disco, chama o gerenciador de impressao
   If aReturn[5]==1
      dbCommitAll()
      SET PRINTER TO
      OurSpool(wnrel)
   Endif

   MS_FLUSH()

   oDlg:End()

Return

/*
         1         2         3         4         5         6         7         8         9       100       110       120       130       140       150       160       170       180       190       200
12345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
CODIGO   TITULO DA TAREFA                                                  DATA      MODULO               RESPONSAVEL          DESENVOLVEDOR        PRIORIDADE
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
                                              
                                                                                     USUARIO: XXXXXXXXXXXXXXXXXXXXX     
                                                                                     STATUS.: X - XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

CODIGO   TITULO DA TAREFA                                                  DATA      MODULO                           RESPONSAVEL                      DESENVOLVEDOR                     PRIORIDADE
XXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   XX/XX/XXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX   XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX    XXXXXXXXXXXXXXX

*/