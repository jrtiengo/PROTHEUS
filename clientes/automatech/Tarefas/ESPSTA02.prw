#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPSTA02.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 05/01/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Status de tarefas             *
//**********************************************************************************

User Function ESPSTA02(_Operacao, _Codigo, _Descricao)

   Local cGet1	   := Space(25)
   Local cGet2	   := Space(25)
   Local oGet1     := Space(06)
   Local oGet2     := Space(40)
   Local aComboBx1 := {"1 - Verde", "2 - Vermelho", "3 - Azul", "4 - Amarelo", "5 - Preto", "6 - Laranja", "7 - Cinza", "8 - Branco"}
   Local cComboBx1

   Local _aArea  := {}
   Local _aAlias := {}

   Private oDlg	

   cGet1 := _Codigo
   cGet2 := _Descricao

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Status de Tarefas" FROM C(178),C(181) TO C(276),C(750) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(006),C(008) Say "Código"         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(006),C(036) Say "Descrição"      Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(006),C(202) Say "Cor da Legenda" Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(016),C(008) MsGet oGet1 Var cGet1 WHEN _Operacao == "I" Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(016),C(036) MsGet oGet2 Var cGet2                       Size C(162),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(016),C(202) ComboBox cComboBx1 Items aComboBx1          Size C(081),C(010) PIXEL OF oDlg

   @ C(029),C(119) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg ACTION( _SalvaStatus( _Operacao, cGet1, cGet2, cComboBx1 ) )
   @ C(029),C(161) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( ODlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que realiza a gravação dos dados
Static Function _SalvaStatus(_Operacao, _Codigo, _Descricao, _Combox01)

   Local cSql := ""

   // Operação de Inclusão
   If _Operacao == "I"

      If Empty(Alltrim(_Codigo))
         MsgAlert("Código não informado. Verifique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Descricao))
         MsgAlert("Descrição não informada. Verifique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Combox01))
         MsgAlert("Cor da Legenda não informada. Verifique !!")
         Return .T.
      Endif   

      If Select("T_JATEM") > 0
         T_JATEM->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZC_CODIGO, "
      cSql += "       ZZC_NOME    "
      cSql += "  FROM " + RetSqlName("ZZC")
      cSql += " WHERE ZZC_CODIGO = '" + Alltrim(_Codigo) + "'"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JATEM", .T., .T. )

      If !T_JATEM->( EOF() )
         MsgAlert("Código de Status de tarefa já cadastrado. Verique!!")
         Return .T.
      Endif

      // Inseri os dados na Tabela
      aArea := GetArea()

      dbSelectArea("ZZC")
      RecLock("ZZC",.T.)
      ZZC_CODIGO := _Codigo
      ZZC_NOME   := _Descricao
      ZZC_LEGE   := _Combox01
      ZZC_DELETE := " "
      MsUnLock()
      
   Endif

   // Operação de Alteração
   If _Operacao == "A"

      aArea := GetArea()

      DbSelectArea("ZZC")
      DbSetOrder(1)
      If DbSeek(xfilial("ZZC") + _Codigo)
         RecLock("ZZC",.F.)
         ZZC_NOME   := _Descricao
         ZZC_LEGE   := _Combox01
         MsUnLock()              
      Endif
      
   Endif

   // Operação de Exclusão
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclusão deste registro?")

         aArea := GetArea()

         DbSelectArea("ZZC")
         DbSetOrder(1)
         If DbSeek(xfilial("ZZC") + _Codigo)
            RecLock("ZZC",.F.)
            ZZC_DELETE := "X"
            MsUnLock()              
         Endif

      Endif   

   Endif

   ODlg:End()

Return Nil                                                                   
