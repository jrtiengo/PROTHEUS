#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "XMLXFUN.CH"
#include "rwmake.ch"
#include "topconn.ch"
#Include "Tbiconn.Ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPTAR18.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 01/10/2012                                                          *
// Objetivo..: Manutenção das Tarefas do Projeto                                   *
//**********************************************************************************

User Function ESPTAR18(__Operacao, _Tarefa)

   Local lChumba := .F.

   Private cCodigo	    := Space(06)
   Private cProjeto	    := Space(40)
   Private cNcliente    := Space(40)
   Private cData	    := Ctod("  /  /    ")
   Private cHora	    := Space(10)
   Private cTitulo	    := Space(40)
   Private cTipoTar	    := Space(40)
   Private cUsuario	    := Space(20)
   Private cPrioridade  := Space(40)
   Private cResponsavel := Space(40)
   Private cTempo	    := Space(25)
   Private cPrevista    := Ctod("  /  /    ")
   Private cTermino     := Ctod("  /  /    ")
   Private cProducao    := Ctod("  /  /    ")
   Private cTarefa	    := ""
   Private cGeral	    := ""
   Private cSolucao	    := ""
   Private cStatus      := Space(20)
   
   Private oGet1
   Private oGet10
   Private oGet11
   Private oGet12
   Private oGet13
   Private oGet14
   Private oGet15
   Private oGet2
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

   Private oDlg

   // Em caso de alteração, captura os dados para manipulação
   If Select("T_TAREFA") > 0
      T_TAREFA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZG_FILIAL, A.ZZG_CODI  , A.ZZG_TITU    ,A.ZZG_USUA  , A.ZZG_DATA  , A.ZZG_HORA  , A.ZZG_STAT  ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZZG_DES1)) AS DESCRICAO," 
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZZG_NOT1)) AS NOTAS    ," 
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), A.ZZG_SOL1)) AS SOLICITAS," 
   cSql += "       A.ZZG_DES2  , A.ZZG_PRIO  , E.ZZD_NOME    , A.ZZG_NOT2 , A.ZZG_PREV  , A.ZZG_TERM  , A.ZZG_PROD  ,"
   cSql += "       A.ZZG_SOL2  , A.ZZG_DELE  , A.ZZG_ORIG    , A.ZZG_COMP , D.ZZB_NOME  , A.ZZG_PROG  , F.ZZE_NOME  ,"
   cSql += "       A.ZZG_CHAM  , A.ZZG_PROJ  , C.ZZY_CLIENT  , C.ZZY_LOJA , B.A1_NOME   , A.ZZG_HTOT  , C.ZZY_TITULO "
   cSql += "  FROM " + RetSqlName("ZZG") + " A, "
   cSql += "       " + RetSqlName("SA1") + " B, "
   cSql += "       " + RetSqlName("ZZY") + " C, "
   cSql += "       " + RetSqlName("ZZB") + " D, "
   cSql += "       " + RetSqlName("ZZD") + " E, "
   cSql += "       " + RetSqlName("ZZE") + " F  "
   cSql += " WHERE A.ZZG_DELE   = ''"
   cSql += "   AND A.ZZG_CODI   = '" + Alltrim(_Tarefa) + "'"
   cSql += "   AND A.ZZG_PROJ   = C.ZZY_CODIGO"
   cSql += "   AND C.ZZY_DELETE = ''"
   cSql += "   AND C.ZZY_CLIENT = B.A1_COD"
   cSql += "   AND C.ZZY_LOJA   = B.A1_LOJA"
   cSql += "   AND B.D_E_L_E_T_ = ''"
   cSql += "   AND A.ZZG_COMP   = D.ZZB_CODIGO"
   cSql += "   AND D.ZZB_DELETE = ''"
   cSql += "   AND A.ZZG_PRIO   = E.ZZD_CODIGO"
   cSql += "   AND E.ZZD_DELETE = ''"
   cSql += "   AND A.ZZG_PROG   = F.ZZE_CODIGO"
   cSql += "   AND F.ZZE_DELETE = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TAREFA", .T., .T. )

   If T_TAREFA->( EOF() )
      MsgAlert("Não existem dados a serem visualizados para a tarefa selecioada.")
      Return .T.
   Endif

   // Carrega as variáveis para display
   cCodigo	    := T_TAREFA->ZZG_CODI
   cProjeto	    := Alltrim(T_TAREFA->ZZG_PROJ) + " - " + Alltrim(T_TAREFA->ZZY_TITULO)
   cNcliente    := Alltrim(T_TAREFA->A1_NOME)
   cData	    := Substr(T_TAREFA->ZZG_DATA,07,02) + "/" + Substr(T_TAREFA->ZZG_DATA,05,02) + "/" + Substr(T_TAREFA->ZZG_DATA,01,04)
   cHora	    := T_TAREFA->ZZG_HORA
   cTitulo	    := T_TAREFA->ZZG_TITU
   cTipoTar	    := T_TAREFA->ZZB_NOME
   cUsuario	    := T_TAREFA->ZZG_USUA
   cPrioridade  := T_TAREFA->ZZD_NOME
   cResponsavel := T_TAREFA->ZZE_NOME
   cTempo	    := T_TAREFA->ZZG_HTOT
   cTarefa      := T_TAREFA->DESCRICAO
   cGeral	    := T_TAREFA->NOTAS
   cSolucao	    := T_TAREFA->SOLICITAS
   cPrevista    := Ctod(Substr(T_TAREFA->ZZG_PREV,07,02) + "/" + Substr(T_TAREFA->ZZG_PREV,05,02) + "/" + Substr(T_TAREFA->ZZG_PREV,01,04))
   cTermino     := Ctod(Substr(T_TAREFA->ZZG_TERM,07,02) + "/" + Substr(T_TAREFA->ZZG_TERM,05,02) + "/" + Substr(T_TAREFA->ZZG_TERM,01,04))
   cProducao    := Ctod(Substr(T_TAREFA->ZZG_PROD,07,02) + "/" + Substr(T_TAREFA->ZZG_PROD,05,02) + "/" + Substr(T_TAREFA->ZZG_PROD,01,04))

   Do Case
      Case Alltrim(T_TAREFA->ZZG_STAT) == "1"
           cStatus := "1 - Abertura"
      Case Alltrim(T_TAREFA->ZZG_STAT) == "2"
           cStatus := "2 - Aprovada" 
      Case Alltrim(T_TAREFA->ZZG_STAT) == "3"
           cStatus := "3 - Reprovada" 
      Case Alltrim(T_TAREFA->ZZG_STAT) == "4"
           cStatus := "4 - Desenvolvimento"
      Case Alltrim(T_TAREFA->ZZG_STAT) == "7"
           cStatus := "7 - Em Produção"
      Case Alltrim(T_TAREFA->ZZG_STAT) == "8"
           cStatus := "8 - Liberada para Produção"
   EndCase

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Tarefas - PROJETOS" FROM C(178),C(181) TO C(576),C(967) PIXEL

   @ C(004),C(005) Say "Código"              Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(004),C(033) Say "Projeto"             Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(176) Say "Cliente"             Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(315) Say "Data"                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(359) Say "Hora"                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(025),C(033) Say "Título da Tarefa"    Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(025),C(176) Say "Tipo de Tarefa"      Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(025),C(315) Say "Usuário"             Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(045),C(033) Say "Prioridade"          Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(045),C(176) Say "Responsável"         Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(045),C(315) Say "Previsão(Horas)"     Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(065),C(033) Say "Descrição da Tarefa" Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(105),C(189) Say "Observações gerais"  Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(106),C(033) Say "S T A T U S"         Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(123),C(033) Say "Prevista Para"       Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(123),C(087) Say "Data Término"        Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(123),C(141) Say "Data Produção"       Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(144),C(033) Say "Solução Adotada"     Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(013),C(005) MsGet    oGet1     Var cCodigo           Size C(022),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(013),C(033) MsGet    oGet10    Var cProjeto          Size C(138),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(013),C(177) MsGet    oGet6     Var cNcliente         Size C(130),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(013),C(315) MsGet    oGet3     Var cData             Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(013),C(359) MsGet    oGet4     Var cHora             Size C(029),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(033),C(033) MsGet    oGet2     Var cTitulo           Size C(138),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(033),C(177) MsGet    oGet11    Var cTipoTar          Size C(130),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(033),C(315) MsGet    oGet12    Var cUsuario          Size C(073),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(054),C(033) MsGet    oGet13    Var cPrioridade       Size C(138),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(054),C(177) MsGet    oGet14    Var cResponsavel      Size C(130),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(054),C(315) MsGet    oGet5     Var cTempo            Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(074),C(033) GET      oMemo1    Var cTarefa      MEMO Size C(355),C(026) PIXEL OF oDlg When lChumba
   @ C(104),C(068) MsGet    oGet15    Var cStatus           Size C(113),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(114),C(188) GET      oMemo2    Var cGeral       MEMO Size C(200),C(029) PIXEL OF oDlg
   @ C(133),C(033) MsGet    oGet7     Var cPrevista         Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(133),C(087) MsGet    oGet8     Var cTermino          Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(133),C(141) MsGet    oGet9     Var cProducao         Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(153),C(033) GET      oMemo3    Var cSolucao     MEMO Size C(355),C(026) PIXEL OF oDlg

   @ C(182),C(311) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg ACTION( __AprovaTar() )
   @ C(182),C(351) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Altera Valor da Variável lLibera e lChumba
Static Function __AprovaTar()

   Local cSql    := ""
   Local cEmail  := ""
   Local c_Email := ""

   aArea := GetArea()

   DbSelectArea("ZZG")
   DbSetOrder(1)
   If DbSeek(xfilial("ZZG") + cCodigo)
      RecLock("ZZG",.F.)
      ZZG_PREV := cPrevista
      ZZG_SOL1 := cSolucao
      ZZG_NOT1 := cGeral
      MsUnLock()              
   Endif   

   ODlg:End()

Return Nil                                                                   