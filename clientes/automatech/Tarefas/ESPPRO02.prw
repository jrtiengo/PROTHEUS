#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPPRO02.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 16/01/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Processos de Tarefas          *
//**********************************************************************************

User Function ESPPRO02(_Tipo, _Programa, _Codigo, _Nome)

   Local lChumba     := .F.
   Local cTexto      := ""

   Private aComboBx1 := {"F - Fonte", "G - Gatilho", "P = Ponto de Entrada", "T - Tabela", "C - Campo", "I - ìndice"}
   Private cComboBx1
   Private cTarefa	 := _Codigo
   Private cNome	 := _Nome
   Private cPrograma := _programa
   Private cMemo1	 := ""

   Private oGet1
   Private oGet2
   Private oGet3
   Private oMemo1

   Private oDlgF

   // Em caso de Alteração ou Exclusão, pesquisa os dados para display
   If _Tipo == "I"
   Else
      cSql := ""
      
      If Select("T_PROGRAMA") > 0
         T_PROGRAMA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZM_TARE, "
      cSql += "       ZZM_PROG, "
      cSql += "       ZZM_NOT2  "
      cSql += "  FROM " + RetSqlName("ZZM")
      cSql += " WHERE ZZM_TARE = '" + Alltrim(cTarefa)   + "'"
      cSql += "   AND ZZM_PROG = '" + Alltrim(cPrograma) + "'"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROGRAMA", .T., .T. )

      If T_PROGRAMA->( EOF() )
         MsgAlert("Não existem dados a serem visualizados.")
         Return .T.
      Endif
      
      // Pesquisa as observações
      If Select("T_OBSERVA") > 0
         T_OBSERVA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT YP_TEXTO "
      cSql += "  FROM " + retSqlName("SYP") 
      cSql += " WHERE YP_CHAVE   = '" + Alltrim(T_PROGRAMA->ZZM_NOT2) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OBSERVA", .T., .T. )

      If T_OBSERVA->( EOF() )
         cTexto := ""
      Else
         T_OBSERVA->( DbGoTop() )
         WHILE !T_OBSERVA->( EOF() )
            cTexto := cTexto + Alltrim(STRTRAN(T_OBSERVA->YP_TEXTO, "\13\10", chr(13) + chr(10)))
            T_OBSERVA->( DbSkip() )
         ENDDO
      Endif

      cMemo1 := cTexto
      
   Endif

   DEFINE MSDIALOG oDlgF TITLE "Componentes da Tarefa" FROM C(178),C(181) TO C(478),C(687) PIXEL

   @ C(004),C(006) Say "Código Tarefa"       Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgF
   @ C(004),C(046) Say "Descrição da Tarefa" Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlgF
   @ C(027),C(006) Say "Componente"          Size C(032),C(008) COLOR CLR_BLACK PIXEL OF oDlgF
   @ C(027),C(115) Say "Tipo do Componente"  Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlgF
   @ C(050),C(007) Say "Observações"         Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlgF

   @ C(014),C(006) MsGet oGet1 Var cTarefa   When lChumba Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgF
   @ C(014),C(046) MsGet oGet2 Var cNome     When lChumba Size C(202),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgF
   @ C(037),C(006) MsGet oGet3 Var cPrograma Size C(102),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgF
   @ C(037),C(114) ComboBox cComboBx1 Items  aComboBx1 Size C(135),C(010) PIXEL OF oDlgF
   @ C(059),C(006) GET oMemo1 Var cMemo1 MEMO Size C(242),C(071) PIXEL OF oDlgF

   @ C(133),C(169) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgF ACTION( _SalvaProce( _Tipo ) )
   @ C(134),C(210) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgF ACTION( ODlgF:End() )

   ACTIVATE MSDIALOG oDlgF CENTERED 

Return(.T.)

// Função que realiza a gravação dos dados
Static Function _SalvaProce(_Operacao)

   Local cSql := ""

   // Operação de Inclusão
   If _Operacao == "I"

      If Empty(Alltrim(cPrograma))
         MsgAlert("Nome do Componente não informado.")
         Return .T.
      Endif   

      If Select("T_JATEM") > 0
         T_JATEM->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZM_TARE, "
      cSql += "       ZZM_PROG  "
      cSql += "  FROM " + RetSqlName("ZZM")
      cSql += " WHERE ZZM_TARE = '" + Alltrim(cTarefa)   + "'"
      cSql += "   AND ZZM_PROG = '" + Alltrim(cPrograma) + "'"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JATEM", .T., .T. )

      If !T_JATEM->( EOF() )
         MsgAlert("Componente de Tarefa já cadastrado. Verique!!")
         Return .T.
      Endif

      // Inseri os dados na Tabela
      aArea := GetArea()

      dbSelectArea("ZZM")
      RecLock("ZZM",.T.)
      ZZM_TARE := cTarefa
      ZZM_PROG := cPrograma
      ZZM_TIPO := Substr(cComboBx1,01,01)
      ZZM_NOME := cNome
      ZZM_DELE := " "
      MsUnLock()

      // Grava o campo memo da Descrição da Solução
      MSMM(,80,,cMemo1,1,,,"ZZM","ZZM_NOT2")
      
   Endif

   // Operação de Alteração
   If _Operacao == "A"

      aArea := GetArea()

      DbSelectArea("ZZM")
      DbSetOrder(1)
      If DbSeek(xfilial("ZZM") + cTarefa + cPrograma)
         RecLock("ZZM",.F.)
         ZZM_PROG := cPrograma
         ZZM_TIPO := Substr(cComboBx1,01,01)
         ZZM_NOME := cNome
         MsUnLock()              

         // Grava o campo memo da Descrição da Solução
         MSMM(,80,,cMemo1,1,,,"ZZM","ZZM_NOT2")

      Endif
      
   Endif

   // Operação de Exclusão
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclusão deste registro?")

         aArea := GetArea()

         DbSelectArea("ZZM")
         DbSetOrder(1)
         If DbSeek(xfilial("ZZM") + cTarefa + cPrograma)
            RecLock("ZZM",.F.)
            ZZM_DELE := "X"
            MsUnLock()              
         Endif

         // Elimina da tabela SYP os dados do Campo Texto
         dbSelectArea("SYP")
         dbSeek(xFilial("SYP")+cChavetex)
         If found()
            While SYP->YP_CHAVE==cChaveTex
               Reclock("SYP",.F.)
               dbDelete()
               MsUnlock()
               dbSkip()
            Enddo
         Endif

      Endif   

   Endif

   ODlgF:End()

Return Nil                                                                   
