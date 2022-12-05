#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch"  

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPMAS01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 27/02/2012                                                          *
// Objetivo..: Parametrizador Sistema de Tarefas                                   *
//**********************************************************************************

User Function ESPMAS01()

   Local cTarefas   := Space(100)
   Local cAcessos   := Space(100)
   Local cProducao  := Space(100)
   Local cEvento    := Space(100)
   Local cReordena  := Space(100)
   Local cOrdenacao := 0
   Local cIntervalo := 0
   Local cMemo1	    := ""
   Local cMemo2	    := ""
   
   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5
   Local oGet6
   Local oGet7
   Local oMemo1
   Local oMemo2
   
   Private oDlg

   // Captura os dados para display
   If Select("T_MASTER") > 0
      T_MASTER->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZJ_EMAI,"
   cSql += "       ZZJ_ACES,"
   cSql += "       ZZJ_APRO,"
   cSql += "       ZZJ_AEVE,"
   cSql += "       ZZJ_ORDE,"
   cSql += "       ZZJ_INTE,"
   cSql += "       ZZJ_REOR "
   cSql += "  FROM " + RetSqlName("ZZJ")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MASTER", .T., .T. )

   If T_MASTER->( EOF() )
      cTarefas   := Space(100)
      cAcessos   := Space(100)
      cProducao  := Space(100)
      cEvento    := Space(100)
      cReordena  := Space(100)
      cOrdenacao := 0
      cIntervalo := 0
   Else
      cTarefas   := T_MASTER->ZZJ_EMAI
      cAcessos   := T_MASTER->ZZJ_ACES
      cProducao  := T_MASTER->ZZJ_APRO
      cEvento    := T_MASTER->ZZJ_AEVE
      cOrdenacao := T_MASTER->ZZJ_ORDE
      cIntervalo := T_MASTER->ZZJ_INTE
      cReordena  := T_MASTER->ZZJ_REOR
   Endif

   DEFINE MSDIALOG oDlg TITLE "Parametrizador Sistema de Tarefas" FROM C(178),C(181) TO C(549),C(611) PIXEL

   @ C(001),C(005) Jpeg FILE "logoautoma.bmp"                                                       Size C(143),C(027)                 PIXEL NOBORDER OF oDlg
   @ C(035),C(005) Say "E-mails responsáveis Aprovação/Reprovação de Tarefas"                       Size C(137),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(056),C(005) Say "E-mails responsáveis Aprovação/Reprovação de Acessos a Menus"               Size C(162),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(077),C(005) Say "E-mails responsáveis de Liberar Acessos em Produção"                        Size C(131),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(098),C(005) Say "E-mails responsáveis pela liberação de eventos (Médico, Dentista, etc ...)" Size C(180),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(140),C(005) Say "Iniciar ordenação de tarefas com a numeração"                               Size C(111),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(140),C(130) Say "Intervalo na Ordenação"                                                     Size C(058),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(120),C(005) Say "E-mail responsável pela reordenação de tarefas"                             Size C(114),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(031),C(005) GET oMemo2 Var cMemo2 MEMO Size C(204),C(001) PIXEL OF oDlg
   @ C(163),C(005) GET oMemo1 Var cMemo1 MEMO Size C(204),C(001) PIXEL OF oDlg
   
   @ C(045),C(005) MsGet oGet1 Var cTarefas   Size C(204),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlg
   @ C(066),C(005) MsGet oGet2 Var cAcessos   Size C(204),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlg
   @ C(087),C(005) MsGet oGet3 Var cProducao  Size C(204),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlg
   @ C(108),C(005) MsGet oGet6 Var cEvento    Size C(204),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlg
   @ C(128),C(005) MsGet oGet7 Var cReordena  Size C(204),C(009) COLOR CLR_BLACK Picture "@!"       PIXEL OF oDlg
   @ C(149),C(005) MsGet oGet4 Var cOrdenacao Size C(032),C(009) COLOR CLR_BLACK Picture "@E 99999" PIXEL OF oDlg
   @ C(149),C(130) MsGet oGet5 Var cIntervalo Size C(019),C(009) COLOR CLR_BLACK Picture "@E 999"   PIXEL OF oDlg

   @ C(168),C(132) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlg ACTION( Grava_Master(cTarefas, cAcessos, cProducao, cEvento, cOrdenacao, cIntervalo, cReordena) )
   @ C(168),C(171) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 
   
Return(.T.)

// Função que grava os parçametros do sistema de Controle de Tarefas
Static Function Grava_master(_Tarefas, _Acessos, _Producao, _Evento, _Ordenacao, _Intervalo, _Reordena)

   // Verifica se tabela de parametrização está vazia
   If Select("T_MASTER") > 0
      T_MASTER->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZJ_EMAI,"
   cSql += "       ZZJ_ACES,"
   cSql += "       ZZJ_APRO,"
   cSql += "       ZZJ_AEVE,"
   cSql += "       ZZJ_ORDE,"
   cSql += "       ZZJ_INTE,"
   cSql += "       ZZJ_REOR "
   cSql += "  FROM " + RetSqlName("ZZJ")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MASTER", .T., .T. )

   // Atualiza a tabela de histórico de tarefa   
   If T_MASTER->( EOF() )
      dbSelectArea("ZZJ")
      RecLock("ZZJ",.T.)
      ZZJ_EMAI := Alltrim(_Tarefas)
      ZZJ_ACES := Alltrim(_Acessos)
      ZZJ_APRO := Alltrim(_Producao)
      ZZJ_AEVE := Alltrim(_Evento)
      ZZJ_ORDE := _Ordenacao
      ZZJ_INTE := _Intervalo      
      ZZJ_REOR := _Reordena
      MsUnLock()
   Else 
      DbSelectArea("ZZJ")
      RecLock("ZZJ",.F.)
      ZZJ_EMAI := Alltrim(_Tarefas)
      ZZJ_ACES := Alltrim(_Acessos)
      ZZJ_APRO := Alltrim(_Producao)
      ZZJ_AEVE := Alltrim(_Evento)
      ZZJ_ORDE := _Ordenacao
      ZZJ_INTE := _Intervalo
      ZZJ_REOR := _Reordena
      MsUnLock()
   Endif
          
   oDlg:End()

Return(.T.)