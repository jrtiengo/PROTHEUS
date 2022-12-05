#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTO218B.PRW                                                        *
// Par�metros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans L�schenkohl                                             *
// Data......: 21/03/2014                                                          *
// Objetivo..: Programa de Manuten��o do Cadastro de Motivos de Aprova��o/Reprova- *
//             ��o de RMA                                                          *
//**********************************************************************************

User Function AUTO218B(_Operacao, _Codigo, _Descricao)

   Local cSql      := ""
   Local lChumba   := .F.

   Private cCodigo := Space(06)
   Private cNome   := Space(40)

   Private oGet1
   Private oGet2

   Private oDlg	

   If _Operacao <> "I"

      If Select("T_MOTIVO") > 0
         T_MOTIVO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZS7_CODI, "
      cSql += "       ZS7_DESC  "
      cSql += "  FROM " + RetSqlName("ZS7")
      cSql += " WHERE ZS7_CODI = '" + Alltrim(_Codigo) + "'"
      cSql += "   AND ZS7_DELE = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MOTIVO", .T., .T. )

      cCodigo := T_MOTIVO->ZS7_CODI
      cNome   := T_MOTIVO->ZS7_DESC
   
   Endif   

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Motivos de Aprova��o/Reprova��o de RMA" FROM C(178),C(181) TO C(274),C(502) PIXEL

   @ C(005),C(005) Say "C�digo"              Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(032) Say "Descri��o do Motivo" Size C(062),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(015),C(005) MsGet oGet1 Var cCodigo When lChumba Size C(021),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(015),C(032) MsGet oGet2 Var cNome                Size C(122),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(029),C(047) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg ACTION( _SalvaMotivo( _Operacao, cCodigo, cNome ) )
   @ C(029),C(086) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( ODlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Fun��o que realiza a grava��o dos dados
Static Function _SalvaMotivo(_Operacao, _Codigo, _Descricao)

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
      cSql := "SELECT ZS7_CODI "
      cSql += "  FROM " + RetSqlName("ZS7")
      cSql += " ORDER BY ZS7_CODI DESC"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

      If T_PROXIMO->( EOF() )
         xCodigo := "000001"
      Else
         xCodigo := STRZERO(INT(VAL(T_PROXIMO->ZS7_CODI)) + 1,6)
      Endif

      // Inseri os dados na Tabela
      aArea := GetArea()

      dbSelectArea("ZS7")
      RecLock("ZS7",.T.)
      ZS7_CODI := xCodigo
      ZS7_DESC := _Descricao
      MsUnLock()
      
   Endif

   // Opera��o de Altera��o
   If _Operacao == "A"

      aArea := GetArea()

      DbSelectArea("ZS7")
      DbSetOrder(1)
      If DbSeek(xfilial("ZS7") + _Codigo)
         RecLock("ZS7",.F.)
         ZS7_DESC := _Descricao
         MsUnLock()              
      Endif
      
   Endif

   // Opera��o de Exclus�o
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclus�o deste registro?")

         aArea := GetArea()

         DbSelectArea("ZS7")
         DbSetOrder(1)
         If DbSeek(xfilial("ZS7") + _Codigo)
            RecLock("ZS7",.F.)
            ZS7_DELE := "X"
            MsUnLock()              
         Endif

      Endif   

   Endif

   ODlg:End()

Return Nil