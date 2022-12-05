#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTO218B.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 21/03/2014                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Motivos de Aprovação/Reprova- *
//             ção de RMA                                                          *
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

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Motivos de Aprovação/Reprovação de RMA" FROM C(178),C(181) TO C(274),C(502) PIXEL

   @ C(005),C(005) Say "Código"              Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(032) Say "Descrição do Motivo" Size C(062),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(015),C(005) MsGet oGet1 Var cCodigo When lChumba Size C(021),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(015),C(032) MsGet oGet2 Var cNome                Size C(122),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(029),C(047) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg ACTION( _SalvaMotivo( _Operacao, cCodigo, cNome ) )
   @ C(029),C(086) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( ODlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que realiza a gravação dos dados
Static Function _SalvaMotivo(_Operacao, _Codigo, _Descricao)

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

   // Operação de Alteração
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

   // Operação de Exclusão
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclusão deste registro?")

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