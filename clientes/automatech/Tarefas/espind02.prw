#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPIND02.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 27/06/2013                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Usuários                      *
//**********************************************************************************

User Function ESPIND02(_Operacao, _Codigo)

   Local lChumba     := .F.

   Private cCodigo   := IIF(_Operacao == "I", Space(06), _Codigo)
   Private cNome     := Space(40)
   Private cEmail    := Space(100)
   Private lConsulta := .F.

   Private oGet1
   Private oGet2
   Private oGet3
   Private oCheckBox1

   Private oDlg

   If _Operacao <> "I"

      If Select("T_USUARIOS") > 0
         T_USUARIOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.ZZA_CODI,"  
      cSql += "       A.ZZA_NOME,"  
      cSql += "       A.ZZA_EMAI,"  
      cSql += "       A.ZZA_VISU "
      cSql += "  FROM " + RetSqlName("ZZA") + " A "
      cSql += " WHERE A.ZZA_CODI   = '" + Alltrim(_Codigo) + "'"
      cSql += "   AND A.D_E_L_E_T_ = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIOS", .T., .T. )
               
      cCodigo   := T_USUARIOS->ZZA_CODI
      cNome	    := T_USUARIOS->ZZA_NOME
      cEmail    := T_USUARIOS->ZZA_EMAI
      lConsulta := IIF(T_USUARIOS->ZZA_VISU == "T", .T., .F.)
                                       
   Endif

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Usuários" FROM C(178),C(181) TO C(335),C(526) PIXEL

   @ C(005),C(005) Say "Código"            Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(035) Say "Nome do Usuário"   Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(026),C(035) Say "E-mail do Usuário" Size C(043),C(009) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(014),C(005) MsGet oGet1 Var cCodigo When _Operacao == "I" Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(035) MsGet oGet2 Var cNome   Size C(130),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(035),C(035) MsGet oGet3 Var cEmail  Size C(130),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(051),C(035) CheckBox    oCheckBox1  Var lConsulta Prompt "Somente Consulta de Tarefas" Size C(084),C(008) PIXEL OF oDlg

   @ C(062),C(089) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg ACTION( _SalvaProjeto( _Operacao, cCodigo, cNome, cEmail, lConsulta) )
   @ C(062),C(128) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( ODlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que realiza a gravação dos dados
Static Function _SalvaProjeto(_Operacao, _Codigo, _Nome, _Email)

   Local cSql := ""

   // Operação de Inclusão
   If _Operacao == "I"

      If Empty(Alltrim(_Codigo))
         MsgAlert("Código do Usuário não informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Nome))
         MsgAlert("Nome do Usuário não informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Email))
         MsgAlert("E-Mail do Usuário não informado. Verique !!")
         Return .T.
      Endif   

      If Select("T_JATEM") > 0
         T_JATEM->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZA_CODI"  
      cSql += "  FROM " + RetSqlName("ZZA")
      cSql += " WHERE ZZA_CODI = '" + Alltrim(_Codigo) + "'"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JATEM", .T., .T. )

      If !T_JATEM->( EOF() )
         MsgAlert("Código de Usuário já cadastrado. Verique!!")
         Return .T.
      Endif

      // Inseri os dados na Tabela
      aArea := GetArea()

      dbSelectArea("ZZA")
      RecLock("ZZA",.T.)
      ZZA_FILIAL := "  "
      ZZA_CODI   := _Codigo
      ZZA_NOME   := _Nome
      ZZA_EMAI   := _Email
      ZZA_VISU   := IIF(lConsulta == .T., "T", "F")
      MsUnLock()
      
   Endif

   // Operação de Alteração
   If _Operacao == "A"

      If Empty(Alltrim(_Codigo))
         MsgAlert("Código do Usuário não informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Nome))
         MsgAlert("Nome do Usuário não informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(_Email))
         MsgAlert("Email do Usuário não informado. Verique !!")
         Return .T.
      Endif   

      aArea := GetArea()

      DbSelectArea("ZZA")
      DbSetOrder(1)
      If DbSeek("  " + _Codigo)
         RecLock("ZZA",.F.)
         ZZA_CODI := _Codigo
         ZZA_NOME := _Nome
         ZZA_EMAI := _Email
         ZZA_VISU := IIF(lConsulta == .T., "T", "F")
         MsUnLock()              
      Endif
      
   Endif

   // Operação de Exclusão
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclusão deste registro?")

         // Elimina o registro para a solicitação de reserva para o produto selecionado para nova gravação
         cSql := ""
         cSql := "DELETE FROM " + RetSqlName("ZZA")
         cSql += " WHERE ZZA_FILIAL = '  '"
         cSql += "   AND ZZA_CODI   = '" + Alltrim(_Codigo) + "'"

         _nErro := TcSqlExec(cSql) 

         If TCSQLExec(cSql) < 0 
            alert(TCSQLERROR())
         Endif

      Endif   

   Endif

   ODlg:End()

Return Nil