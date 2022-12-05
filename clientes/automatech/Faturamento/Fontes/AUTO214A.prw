#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTO214A.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 14/03/2014                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Regras de Negócio             *
//**********************************************************************************

User Function AUTO214A(_Operacao, _Codigo, _Descricao)

   Local cSql      := ""
   Local lChumba   := .F.

   Private cCodigo := Space(06)
   Private cTitulo := Space(100)
   Private cTexto  := ""

   Private oGet1
   Private oGet2
   Private oMemo1

   Private oDlg	

   U_AUTOM628("AUTO214A")

   If _Operacao <> "I"

      If Select("T_CADASTRO") > 0
         T_CADASTRO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZS5_CODI, "
      cSql += "       ZS5_TITU, "
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZS5_TEXT)) AS REGRA"
      cSql += "  FROM " + RetSqlName("ZS5")
      cSql += " WHERE ZS5_CODI = '" + Alltrim(_Codigo) + "'"
      cSql += "   AND ZS5_DELE = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CADASTRO", .T., .T. )

      cCodigo := T_CADASTRO->ZS5_CODI
      cTitulo := T_CADASTRO->ZS5_TITU
      cTexto  := T_CADASTRO->REGRA
   
   Endif   

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Regras de Negócio" FROM C(178),C(181) TO C(607),C(778) PIXEL

   @ C(005),C(005) Say "Código"                        Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(038) Say "Título da Regra de Negócio"    Size C(071),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(027),C(005) Say "Descrição da regra de negócio" Size C(076),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(005) MsGet oGet1  Var cCodigo      When lChumba Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(038) MsGet oGet2  Var cTitulo                   Size C(254),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(037),C(005) GET   oMemo1 Var cTexto  MEMO              Size C(287),C(159) PIXEL OF oDlg

   @ C(199),C(216) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg ACTION( _SalvaRegra( _Operacao, cCodigo, cTitulo, cTexto ) )
   @ C(199),C(255) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( ODlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que realiza a gravação dos dados
Static Function _SalvaRegra(_Operacao, _Codigo, _Descricao, _Texto)

   Local cSql := ""

   // Operação de Inclusão
   If _Operacao == "I"

      If Empty(Alltrim(_Descricao))
         MsgAlert("Título da regra de Negócio não informado.")
         Return .T.
      Endif   

      // Pesquisa o próximo código
      If Select("T_PROXIMO") > 0
         T_PROXIMO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZS5_CODI "
      cSql += "  FROM " + RetSqlName("ZS5")
      cSql += " ORDER BY ZS5_CODI DESC"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

      If T_PROXIMO->( EOF() )
         _Codigo := "000001"
      Else
         _Codigo := STRZERO(INT(VAL(T_PROXIMO->ZS5_CODI)) + 1,6)
      Endif   

      // Inseri os dados na Tabela
      aArea := GetArea()

      dbSelectArea("ZS5")
      RecLock("ZS5",.T.)
      ZS5_CODI  := _Codigo
      ZS5_TITU  := _Descricao
      ZS5_TEXT  := _Texto
      MsUnLock()
      
   Endif

   // Operação de Alteração
   If _Operacao == "A"

      aArea := GetArea()

      DbSelectArea("ZS5")
      DbSetOrder(1)
      If DbSeek(xfilial("ZS5") + _Codigo)
         RecLock("ZS5",.F.)
         ZS5_TITU  := _Descricao
         ZS5_TEXT  := _Texto
         MsUnLock()              
      Endif
      
   Endif

   // Operação de Exclusão
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclusão deste registro?")

         aArea := GetArea()

         DbSelectArea("ZS5")
         DbSetOrder(1)
         If DbSeek(xfilial("ZS5") + _Codigo)
            RecLock("ZS5",.F.)
            ZS5_DELE := "X"
            MsUnLock()              
         Endif

      Endif   

   Endif

   ODlg:End()

Return Nil