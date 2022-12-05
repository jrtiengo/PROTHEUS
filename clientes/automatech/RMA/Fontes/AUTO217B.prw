#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch"    

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTO217B.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 21/03/2014                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Motivos de RMA                *
//**********************************************************************************

User Function AUTO217B(_Operacao, _Codigo, _Descricao)

   Local cSql      := ""
   Local lChumba   := .F.
   Local cMemo1    := ""
   Local oMemo1

   Private cCodigo   := Space(06)
   Private cNome     := Space(40)
   Private cReduzido := Space(20)

   Private oGet1
   Private oGet2
   Private oGet3

   Private oDlg	

   If _Operacao <> "I"

      If Select("T_MOTIVO") > 0
         T_MOTIVO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZS6_CODI, "
      cSql += "       ZS6_DESC, "
      cSql += "       ZS6_REDU  "
      cSql += "  FROM " + RetSqlName("ZS6")
      cSql += " WHERE ZS6_CODI = '" + Alltrim(_Codigo) + "'"
      cSql += "   AND ZS6_DELE = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MOTIVO", .T., .T. )

      cCodigo   := T_MOTIVO->ZS6_CODI
      cNome     := T_MOTIVO->ZS6_DESC
      cReduzido := T_MOTIVO->ZS6_REDU
   
   Endif   

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Motivos de RMAs" FROM C(178),C(181) TO C(382),C(522) PIXEL

   @ C(002),C(002) Jpeg FILE "logoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(163),C(001) PIXEL OF oDlg

   @ C(037),C(005) Say "Código"                           Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(033) Say "Descrição do Motivo"              Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(059),C(033) Say "Nome Reduzido (Para Indicadores)" Size C(085),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(046),C(005) MsGet oGet1 Var cCodigo   Size C(023),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(033) MsGet oGet2 Var cNome     Size C(130),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(068),C(033) MsGet oGet3 Var cReduzido Size C(069),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(084),C(045) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg ACTION( _SalvaMotivo( _Operacao, cCodigo, cNome, cReduzido ) )
   @ C(084),C(084) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( ODlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que realiza a gravação dos dados
Static Function _SalvaMotivo(_Operacao, _Codigo, _Descricao, _Reduzido)

   Local cSql := ""

   // Operação de Inclusão
   If _Operacao == "I"

      If Empty(Alltrim(_Descricao))
         MsgAlert("Descrição do Motivo não informada. Verique !!")
         Return .T.
      Endif   

      // Pesquisa o próximo código para inclusão
      If Select("T_PROXIMO") > 0
         T_PROXIMO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZS6_CODI "
      cSql += "  FROM " + RetSqlName("ZS6")
      cSql += " ORDER BY ZS6_CODI DESC"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

      If T_PROXIMO->( EOF() )
         xCodigo := "000001"
      Else
         xCodigo := STRZERO(INT(VAL(T_PROXIMO->ZS6_CODI)) + 1,6)
      Endif

      // Inseri os dados na Tabela
      aArea := GetArea()

      dbSelectArea("ZS6")
      RecLock("ZS6",.T.)
      ZS6_CODI := xCodigo
      ZS6_DESC := _Descricao
      ZS6_REDU := _Reduzido
      MsUnLock()
      
   Endif

   // Operação de Alteração
   If _Operacao == "A"

      aArea := GetArea()

      DbSelectArea("ZS6")
      DbSetOrder(1)
      If DbSeek(xfilial("ZS6") + _Codigo)
         RecLock("ZS6",.F.)
         ZS6_DESC := _Descricao
         ZS6_REDU := _Reduzido
         MsUnLock()              
      Endif
      
   Endif

   // Operação de Exclusão
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclusão deste registro?")

         aArea := GetArea()

         DbSelectArea("ZS6")
         DbSetOrder(1)
         If DbSeek(xfilial("ZS6") + _Codigo)
            RecLock("ZS6",.F.)
            ZS6_DELE := "X"
            MsUnLock()              
         Endif

      Endif   

   Endif

   ODlg:End()

Return Nil