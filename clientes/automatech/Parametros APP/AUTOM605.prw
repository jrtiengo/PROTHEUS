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
// Referencia: AUTOM605.PRW                                                             ##
// Parâmetros: Nenhum                                                                   ##
// Tipo......: (X) Programa  ( ) Gatilho                                                ##
// ------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                  ##
// Data......: 29/11/2016                                                               ##
// Objetivo..: Parâmetros App Automatech AT                                             ##  
// #######################################################################################
User Function AUTOM605()

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private cPesquisas   := Space(250)
   Private cOcorrencias := Space(250)
   Private cposicoes    := Space(250)

   Private oGet1
   Private oGet2
   Private oGet3

   Private oDlg

   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZTR_PESQ,"
   cSql += "       ZTR_OCOR,"
   cSql += "       ZTR_POSI "
   cSql += "  FROM " + RetSqlName("ZTR")
   cSql += " WHERE D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      cPesquisas   := Space(250)
      cOcorrencias := Space(250)
      cposicoes    := Space(250)
   Else
      cPesquisas   := T_PARAMETROS->ZTR_PESQ
      cOcorrencias := T_PARAMETROS->ZTR_OCOR
      cposicoes    := T_PARAMETROS->ZTR_POSI
   Endif

   DEFINE MSDIALOG oDlg TITLE "Parâmetros App Automatech AT" FROM C(178),C(181) TO C(437),C(715) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(257),C(001) PIXEL OF oDlg
   @ C(107),C(002) GET oMemo2 Var cMemo2 MEMO Size C(257),C(001) PIXEL OF oDlg
   
   @ C(038),C(005) Say "Usuários com permissão de selecionar técnicos no App ( Preencher com Nome|nome|nome| )" Size C(221),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(061),C(005) Say "Ocorrências para pesquisa ( Preencher com 'codigo', 'codigo', 'codigo' )"               Size C(161),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(083),C(005) Say "Posição para pesquisa ( Preencher com 'codigo', 'codigo', 'codigo' )"                   Size C(152),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(048),C(005) MsGet oGet1 Var cPesquisas   Size C(255),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(070),C(005) MsGet oGet2 Var cOcorrencias Size C(255),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(092),C(005) MsGet oGet3 Var cPosicoes    Size C(255),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(113),C(112) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( EncerraPar() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ######################################################################
// Função que grava e ecerra a tela de parâmetros do App Automatech AT ##
// ######################################################################
Static Function EncerraPar()

   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZTR_PESQ,"
   cSql += "       ZTR_OCOR,"
   cSql += "       ZTR_POSI "
   cSql += "  FROM " + RetSqlName("ZTR")
   cSql += " WHERE D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   IF T_PARAMETROS->( EOF() )
      DbSelectArea("ZTR")
      RecLock("ZTR",.T.)
      ZTR_PESQ := cPesquisas
      ZTR_OCOR := cOcorrencias
      ZTR_POSI := cPosicoes
      MsUnLock()
   Else
      DbSelectArea("ZTR")
      RecLock("ZTR",.F.)
      ZTR_PESQ := cPesquisas
      ZTR_OCOR := cOcorrencias
      ZTR_POSI := cPosicoes
      MsUnLock()
   Endif

   oDlg:End()

Return(.T.)