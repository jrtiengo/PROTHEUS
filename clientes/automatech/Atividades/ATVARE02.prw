#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ATVARE02.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 30/07/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Áreas                         *
//**********************************************************************************

User Function ATVARE02(_Operacao, _Codigo, _Descricao)

   Local oGet1   := Space(06)
   Local oGet2   := Space(40)

   Local _aArea  := {}
   Local _aAlias := {}

   Private oDlg	

   cGet1 := _Codigo
   cGet2 := _Descricao

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Áreas" FROM C(178),C(181) TO C(276),C(585) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(006),C(008) Say "Código"    Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(006),C(036) Say "Descrição" Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(016),C(008) MsGet oGet1 Var cGet1 WHEN _Operacao == "I" Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(016),C(036) MsGet oGet2 Var cGet2 Size C(162),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(029),C(119) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg ACTION( _SalvaArea( _Operacao, cGet1, cGet2 ) )
   @ C(029),C(161) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( ODlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que realiza a gravação dos dados
Static Function _SalvaArea(_Operacao, _Codigo, _Descricao)

   Local cSql := ""

   // Operação de Inclusão
   If _Operacao == "I"

      If Empty(Alltrim(_Codigo))
         MsgAlert("Código não informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Descricao))
         MsgAlert("Descrição não informada. Verique !!")
         Return .T.
      Endif   

      If Select("T_JATEM") > 0
         T_JATEM->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZR_CODIGO, "
      cSql += "       ZZR_NOME    "
      cSql += "  FROM " + RetSqlName("ZZR")
      cSql += " WHERE ZZR_CODIGO = '" + Alltrim(_Codigo) + "'"
      cSql += "   AND ZZR_DELETE = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JATEM", .T., .T. )

      If !T_JATEM->( EOF() )
         MsgAlert("Código de Área já cadastrada. Verique!!")
         Return .T.
      Endif

      // Inseri os dados na Tabela
      aArea := GetArea()

      dbSelectArea("ZZR")
      RecLock("ZZR",.T.)
      ZZR_CODIGO := _Codigo
      ZZR_NOME   := _Descricao
      MsUnLock()
      
   Endif

   // Operação de Alteração
   If _Operacao == "A"

      aArea := GetArea()

      DbSelectArea("ZZR")
      DbSetOrder(1)
      If DbSeek(xfilial("ZZR") + _Codigo)
         RecLock("ZZR",.F.)
         ZZR_NOME   := _Descricao
         MsUnLock()              
      Endif
      
   Endif

   // Operação de Exclusão
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclusão deste registro?")

         aArea := GetArea()

         DbSelectArea("ZZR")
         DbSetOrder(1)
         If DbSeek(xfilial("ZZR") + _Codigo)
            RecLock("ZZR",.F.)
            ZZR_DELETE := "X"
            MsUnLock()              
         Endif

      Endif   

   Endif

   ODlg:End()

Return Nil                                                                   
