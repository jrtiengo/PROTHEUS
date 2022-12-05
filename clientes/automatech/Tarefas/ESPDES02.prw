#INCLUDE "PROTHEUS.CH"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPDES02.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 09/01/2012                                                          *
// Objetivo..: Programa de Manutenção do Cadastro de Desenvolvedores               *
//**********************************************************************************

User Function ESPDES02(_Operacao, _Codigo, _Descricao)

   Local lChumba       := .F.

   Private cCodigo     := Space(06)
   Private cNome       := Space(40)
   Private cLogin      := Space(20)
   Private cEmail      := Space(60)
   Private cTempo      := Space(03)
   Private lTipop      := .F.
   Private lProtheus   := .F.
   Private lAdministra := .F.
   Private lImediata   := .F.
   Private lProjeto    := .F.
   Private lTecnica    := .F.

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oCheckBox1
   Private oCheckBox2
   Private oCheckBox3   
   Private oCheckBox4   
   Private oCheckBox5   
   Private oCheckBox6      

   Private oDlg	

   If _Operacao <> "I"

      If Select("T_PROGRAMADOR") > 0
         T_PROGRAMADOR->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZE_CODIGO, "
      cSql += "       ZZE_NOME  , "
      cSql += "       ZZE_LOGIN , "
      cSql += "       ZZE_EMAIL , "
      cSql += "       ZZE_TEMPO , "
      cSql += "       ZZE_TIPOP , "
      cSql += "       ZZE_PROTH , "
      cSql += "       ZZE_ADMIN , "
      cSql += "       ZZE_IMEDI , "
      cSql += "       ZZE_PROJE , "
      cSql += "       ZZE_TECNI   "
      cSql += "  FROM " + RetSqlName("ZZE")
      cSql += " WHERE ZZE_CODIGO = '" + Alltrim(_Codigo) + "'"
      cSql += "   AND ZZE_DELETE = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROGRAMADOR", .T., .T. )

      cCodigo     := T_PROGRAMADOR->ZZE_CODIGO
      cNome       := T_PROGRAMADOR->ZZE_NOME
      cLogin      := T_PROGRAMADOR->ZZE_LOGIN
      cEmail      := T_PROGRAMADOR->ZZE_EMAIL
      cTempo      := T_PROGRAMADOR->ZZE_TEMPO
      lTipop      := IIF(T_PROGRAMADOR->ZZE_TIPOP == "T", .T., .F.)
      lProtheus   := IIF(T_PROGRAMADOR->ZZE_PROTH == "T", .T., .F.)
      lAdministra := IIF(T_PROGRAMADOR->ZZE_ADMIN == "T", .T., .F.)      
      lImediata   := IIF(T_PROGRAMADOR->ZZE_IMEDI == "T", .T., .F.)      
      lProjeto    := IIF(T_PROGRAMADOR->ZZE_PROJE == "T", .T., .F.)
      lTecnica    := IIF(T_PROGRAMADOR->ZZE_TECNI == "T", .T., .F.)
   
   Endif   

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Desenvolvedores" FROM C(178),C(181) TO C(445),C(635) PIXEL

   @ C(005),C(005) Say "Código"                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(032) Say "Nome do Desenvolvedor" Size C(062),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(160) Say "Login Protheus"        Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(028),C(032) Say "E-Mail"                Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(028),C(160) Say "Horas Diárias"         Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(015),C(005) MsGet    oGet1      Var cCodigo Size C(021),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lChumba
   @ C(015),C(032) MsGet    oGet2      Var cNome   Size C(122),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(015),C(160) MsGet    oGet3      Var cLogin  Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(037),C(032) MsGet    oGet4      Var cEmail  Size C(122),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(037),C(160) MsGet    oGet5      Var cTempo  Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(051),C(032) CheckBox oCheckBox3 Var lAdministra Prompt "Administrador"                                Size C(048),C(008) PIXEL OF oDlg
   @ C(061),C(032) CheckBox oCheckBox2 Var lProtheus   Prompt "Desenvolvedor Protheus"                       Size C(072),C(008) PIXEL OF oDlg
   @ C(072),C(032) CheckBox oCheckBox1 Var lTipop      Prompt "Desenvolvedor Projetos"                       Size C(068),C(008) PIXEL OF oDlg
   @ C(082),C(032) CheckBox oCheckBox4 Var lImediata   Prompt "Recebe e-mail de Tarefas de Solução Imediata" Size C(123),C(008) PIXEL OF oDlg
   @ C(092),C(032) CheckBox oCheckBox5 Var lProjeto    Prompt "Visualiza Tarefas Imediatas do Projeto"       Size C(100),C(008) PIXEL OF oDlg
   @ C(103),C(032) CheckBox oCheckBox6 Var lTecnica    Prompt "Visualiza Tarefas do TI"                      Size C(066),C(008) PIXEL OF oDlg

   @ C(116),C(075) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg ACTION( _SalvaDesen( _Operacao, cCodigo, cNome, cLogin, cEmail, cTempo, lTipop, lProtheus, lAdministra, lImediata, lProjeto, lTecnica ) )
   @ C(116),C(114) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( ODlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que realiza a gravação dos dados
Static Function _SalvaDesen(_Operacao, _Codigo, _Descricao, _Login, _Email, _Tempo, _Tipop, _lProtheus, _lAdministra, _lImediata, _lProjeto, _lTecnica)

   Local cSql    := ""
   Local xCodigo := Space(06)

   // Operação de Inclusão
   If _Operacao == "I"

      If Empty(Alltrim(_Descricao))
         MsgAlert("Descrição não informada. Verique !!")
         Return .T.
      Endif   

      // Pesquisa o próximo código para inclusão
      If Select("T_PROXIMO") > 0
         T_PROXIMO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZE_CODIGO "
      cSql += "  FROM " + RetSqlName("ZZE")
      cSql += " WHERE ZZE_DELETE = ''"
      cSql += " ORDER BY ZZE_CODIGO DESC"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

      If T_PROXIMO->( EOF() )
         xCodigo := "000001"
      Else
         xCodigo :=   STRZERO((INT(VAL(T_PROXIMO->ZZE_CODIGO)) + 1),6)
      Endif

      // Inseri os dados na Tabela
      aArea := GetArea()

      dbSelectArea("ZZE")
      RecLock("ZZE",.T.)
      ZZE_CODIGO := xCodigo
      ZZE_NOME   := _Descricao
      ZZE_LOGIN  := _Login
      ZZE_EMAIL  := _Email
      ZZE_TEMPO  := _Tempo
      ZZE_TIPOP  := IIF(_Tipop       == .T., "T", "F")
      ZZE_PROTH  := IIF(_lProtheus   == .T., "T", "F")
      ZZE_ADMIN  := IIF(_lAdministra == .T., "T", "F")
      ZZE_IMEDI  := IIF(_lImediata   == .T., "T", "F")
      ZZE_PROJE  := IIF(_lProjeto    == .T., "T", "F")
      ZZE_TECNI  := IIF(_lTecnica    == .T., "T", "F")      

      
      MsUnLock()
      
   Endif

   // Operação de Alteração
   If _Operacao == "A"

      aArea := GetArea()

      DbSelectArea("ZZE")
      DbSetOrder(1)
      If DbSeek(xfilial("ZZE") + _Codigo)
         RecLock("ZZE",.F.)
         ZZE_NOME   := _Descricao
         ZZE_LOGIN  := _Login
         ZZE_EMAIL  := _Email
         ZZE_TEMPO  := _Tempo
         ZZE_TIPOP  := IIF(_Tipop       == .T., "T", "F")
         ZZE_PROTH  := IIF(_lProtheus   == .T., "T", "F")
         ZZE_ADMIN  := IIF(_lAdministra == .T., "T", "F")
         ZZE_IMEDI  := IIF(_lImediata   == .T., "T", "F")
         ZZE_PROJE  := IIF(_lProjeto    == .T., "T", "F")
         ZZE_TECNI  := IIF(_lTecnica    == .T., "T", "F")      
         MsUnLock()              
      Endif
      
   Endif

   // Operação de Exclusão
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclusão deste registro?")

         aArea := GetArea()

         DbSelectArea("ZZE")
         DbSetOrder(1)
         If DbSeek(xfilial("ZZE") + _Codigo)
            RecLock("ZZE",.F.)
            ZZE_DELETE := "X"
            MsUnLock()              
         Endif

      Endif   

   Endif

   ODlg:End()

Return Nil