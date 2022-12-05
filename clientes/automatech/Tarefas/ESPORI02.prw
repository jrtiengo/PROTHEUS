#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPORI02.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 06/01/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Responsável pelas Tarefas     *
//**********************************************************************************

User Function ESPORI02(_Operacao, _Codigo, _Descricao)

   Local lChumba := .F.
   Local cGet1	 := Space(25)
   Local cGet2	 := Space(25)
   Local oGet1   := Space(06)
   Local oGet2   := Space(40)
   Local _aArea  := {}
   Local _aAlias := {}

   Private oDlg	

   cGet1 := _Codigo
   cGet2 := _Descricao

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Responsáveis pelas Tarefas" FROM C(178),C(181) TO C(276),C(585) PIXEL

   // Cria Componentes Padroes do Sistema
   @ C(006),C(008) Say "Código"    Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(006),C(036) Say "Descrição" Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(016),C(008) MsGet oGet1 Var cGet1 Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(016),C(036) MsGet oGet2 Var cGet2 Size C(162),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(029),C(119) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg ACTION( _SalvaOrigem( _Operacao, cGet1, cGet2 ) )
   @ C(029),C(161) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( ODlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que realiza a gravação dos dados
Static Function _SalvaOrigem(_Operacao, _Codigo, _Descricao)

   Local cSql    := ""
   Local xCodigo := Space(06)

   // Operação de Inclusão
   If _Operacao == "I"

      If Empty(Alltrim(_Descricao))
         MsgAlert("Descrição não informada. Verique !!")
         Return .T.
      Endif   

      If Select("T_PROXIMO") > 0
         T_PROXIMO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZF_CODIGO "
      cSql += "  FROM " + RetSqlName("ZZF")
      cSql += " WHERE ZZF_DELETE = ''"
      cSql += " ORDER BY ZZF_CODIGO DESC"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

      If !T_PROXIMO->( EOF() )
         xCodigo := "000001"
      Else
         xCodigo := Strzero((INT(VAL(T_PROXIMO->ZZF_CODIGO)) + 1),6)
      Endif

      // Inseri os dados na Tabela
      aArea := GetArea()

      dbSelectArea("ZZF")
      RecLock("ZZF",.T.)
      ZZF_CODIGO := xCodigo
      ZZF_NOME   := _Descricao
      MsUnLock()
      
   Endif

   // Operação de Alteração
   If _Operacao == "A"

      aArea := GetArea()

      DbSelectArea("ZZF")
      DbSetOrder(1)
      If DbSeek(xfilial("ZZF") + _Codigo)
         RecLock("ZZF",.F.)
         ZZF_NOME   := _Descricao
         MsUnLock()              
      Endif
      
   Endif

   // Operação de Exclusão
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclusão deste registro?")

         aArea := GetArea()

         DbSelectArea("ZZF")
         DbSetOrder(1)
         If DbSeek(xfilial("ZZF") + _Codigo)
            RecLock("ZZF",.F.)
            ZZF_DELETE := "X"
            MsUnLock()              
         Endif

      Endif   

   Endif

   ODlg:End()

Return Nil                                                                   
