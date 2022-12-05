#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTO221B.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 27/03/2014                                                          *
// Objetivo..: Programa de Manuten��o do Cadastro de Tipos de RMA                  *
//**********************************************************************************

User Function AUTO221B(_Operacao, _Codigo, _Descricao)

   Local cSql      := ""
   Local lChumba   := .F.

   Private cCodigo	  := Space(06)
   Private cNome	  := Space(40)
   Private cHelp	  := ""
   Private lTipo      := .F.
   Private oCheckBox1
   Private oGet1
   Private oGet2
   Private oMemo1

   Private oDlg	

   If _Operacao <> "I"

      If Select("T_TIPO") > 0
         T_TIPO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZS8_CODI, "
      cSql += "       ZS8_DESC, "
      cSql += "       ZS8_TIPO, "
      cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), ZS8_HELP)) AS OBSERVACAO"
      cSql += "  FROM " + RetSqlName("ZS8")
      cSql += " WHERE ZS8_CODI = '" + Alltrim(_Codigo) + "'"
      cSql += "   AND ZS8_DELE = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TIPO", .T., .T. )

      cCodigo := T_TIPO->ZS8_CODI
      cNome   := T_TIPO->ZS8_DESC
      lTipo   := IIF(T_TIPO->ZS8_TIPO == "0", .F., .T.)
      cHelp   := T_TIPO->OBSERVACAO
   
   Endif   

   DEFINE MSDIALOG oDlg TITLE "Cadastro Tipos de RMA" FROM C(178),C(181) TO C(434),C(565) PIXEL

   @ C(005),C(005) Say "C�digo" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(039) Say "Descri��o do Tipo de RMA" Size C(069),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(041),C(005) Say "Detalhe do Tipo de RMA (Help)" Size C(061),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(014),C(005) MsGet    oGet1      Var cCodigo When lChumba Size C(028),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(039) MsGet    oGet2      Var cNome   Size C(146),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(030),C(039) CheckBox oCheckBox1 Var lTipo   Prompt "Devolu��o total dos produtos da Nota Fiscal" Size C(119),C(008) PIXEL OF oDlg
   @ C(051),C(005) GET oMemo1          Var cHelp   MEMO Size C(179),C(056) PIXEL OF oDlg

   @ C(110),C(108) Button "Salvar"   Size C(037),C(012) PIXEL OF oDlg ACTION( _SalvaTipo( _Operacao, cCodigo, cNome, lTipo, cHelp ) )
   @ C(110),C(146) Button "Retornar" Size C(037),C(012) PIXEL OF oDlg ACTION( ODlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Fun��o que realiza a grava��o dos dados
Static Function _SalvaTipo(_Operacao, _Codigo, _Descricao, _Tipo, _Help)

   Local cSql := ""

   // Opera��o de Inclus�o
   If _Operacao == "I"

      If Empty(Alltrim(_Descricao))
         MsgAlert("Descri��o do Motivo n�o informada. Verique !!")
         Return .T.
      Endif   

      // Pesquisa o pr�ximo c�digo para inclus�o
      If Select("T_PROXIMO") > 0
         T_PROXIMO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZS8_CODI "
      cSql += "  FROM " + RetSqlName("ZS8")
      cSql += " ORDER BY ZS8_CODI DESC"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

      If T_PROXIMO->( EOF() )
         xCodigo := "000001"
      Else
         xCodigo := STRZERO(INT(VAL(T_PROXIMO->ZS8_CODI)) + 1,6)
      Endif

      // Inseri os dados na Tabela
      aArea := GetArea()

      dbSelectArea("ZS8")
      RecLock("ZS8",.T.)
      ZS8_CODI := xCodigo
      ZS8_DESC := _Descricao
      ZS8_TIPO := IIF(_Tipo == .T., "1", "0")
      ZS8_HELP := _Help
      MsUnLock()
      
   Endif

   // Opera��o de Altera��o
   If _Operacao == "A"

      aArea := GetArea()

      DbSelectArea("ZS8")
      DbSetOrder(1)
      If DbSeek(xfilial("ZS8") + _Codigo)
         RecLock("ZS8",.F.)
         ZS8_DESC := _Descricao
         ZS8_TIPO := IIF(_Tipo == .T., "1", "0")
         ZS8_HELP := _Help
         MsUnLock()              
      Endif
      
   Endif

   // Opera��o de Exclus�o
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclus�o deste registro?")

         aArea := GetArea()

         DbSelectArea("ZS8")
         DbSetOrder(1)
         If DbSeek(xfilial("ZS8") + _Codigo)
            RecLock("ZS8",.F.)
            ZS8_DELE := "X"
            MsUnLock()              
         Endif

      Endif   

   Endif

   ODlg:End()

Return Nil