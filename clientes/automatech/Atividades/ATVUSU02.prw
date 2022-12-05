#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ATVUSU02.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 30/07/2012                                                          *
// Objetivo..: Cadsatro de Usuários                                                *
//             Nesta tela, o vendedor poderá solicitar a reserva de produtos da    *
// Parâmetros: < FILIAL >, < OPORTUNIDADE DE VENDA >                               *
//**********************************************************************************

// Função que define a Window
User Function ATVUSU02(_Operacao, _Codigo, _Descricao)

   Local cSql        := ""
   Local nContar     := 0

   Private aComboBx1 := {}
   Private cComboBx1

   Private cUsuario    := Space(20)
   Private cNomeUsu    := Space(40)
   Private cEmailUs    := Space(60)
   Private cRespons    := Space(20)
   Private cNomeRes    := Space(40)
   Private cEmailRe    := Space(60)
   Private cGerente    := Space(20)
   Private cNomeGer    := Space(40)
   Private cEmailGe    := Space(60)

   Private lADM        := .F.
   Private lSupervisor := .F.
   Private lNormal     := .F. 
   Private lVisualiza  := .F.
   Private lLogin      := .F.

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8
   Private oGet9      

   Private oDlg

   // Carrega o combo de Áreas
   If Select("T_AREAS") > 0
      T_AREAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZR_CODIGO, "
   cSql += "       ZZR_NOME    "
   cSql += "  FROM " + RetSqlName("ZZR")
   cSql += " WHERE ZZR_DELETE = ''"
   cSql += " ORDER BY ZZR_NOME "
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_AREAS", .T., .T. )

   If T_AREAS->( EOF() )
      MsgAlert("Cadastro de Áreas está vazio. Verifique !!!!")
      Return .T.
   Endif
   
   T_AREAS->( DbGoTop() )
   WHILE !T_AREAS->( EOF() )
      aAdd(aComboBx1, T_AREAS->ZZR_CODIGO + " - " + Alltrim(T_AREAS->ZZR_NOME) )
      T_AREAS->( DbSkip() )
   ENDDO

   // Carrega os dados do Usuário selecinado
   If Select("T_USUARIO") > 0
      T_USUARIO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.ZZT_USUA , "
   cSql += "       A.ZZT_NOMS , "
   cSql += "       A.ZZT_EMAS , "
   cSql += "       A.ZZT_RESP , "
   cSql += "       A.ZZT_NOMR , "
   cSql += "       A.ZZT_EMAR , "
   cSql += "       A.ZZT_AREA , "
   cSql += "       A.ZZT_ADM  , "
   cSql += "       A.ZZT_SUPE , "
   cSql += "       A.ZZT_NORM , "
   cSql += "       A.ZZT_VISU , "
   cSql += "       A.ZZT_GERE , "
   cSql += "       A.ZZT_NOMG , "
   cSql += "       A.ZZT_EMAG , "
   cSql += "       A.ZZT_LOGI   "
   cSql += "  FROM " + RetSqlName("ZZT") + " A "
   cSql += " WHERE A.ZZT_DELETE = ''"
   cSql += "   AND A.ZZT_USUA   = '" + Alltrim(_codigo) + "'"
   cSql += " ORDER BY A.ZZT_NOMS    "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIO", .T., .T. )

   If T_USUARIO->( EOF() )
      cUsuario    := Space(20)
      cNomeUsu    := Space(40)
      cEmailUs    := Space(60)
      cRespons    := Space(20)
      cNomeRes    := Space(40)
      cEmailRe    := Space(60)
      cGerente    := Space(20)
      cNomeGer    := Space(40)
      cEmailGe    := Space(60)
      lADM        := .F.
      lSupervisor := .F.
      lNormal     := .F.
      lVisualiza  := .F.
      lLogin      := .F.
   Else
      cUsuario    := T_USUARIO->ZZT_USUA
      cNomeUsu    := T_USUARIO->ZZT_NOMS
      cEmailUs    := T_USUARIO->ZZT_EMAS
      cRespons    := T_USUARIO->ZZT_RESP
      cNomeRes    := T_USUARIO->ZZT_NOMR
      cEmailRe    := T_USUARIO->ZZT_EMAR
      cGerente    := T_USUARIO->ZZT_GERE
      cNomeGer    := T_USUARIO->ZZT_NOMG
      cEmailGe    := T_USUARIO->ZZT_EMAG
      lADM        := IIF(T_USUARIO->ZZT_ADM  == "T", .T.,.F.)
      lSupervisor := IIF(T_USUARIO->ZZT_SUPE == "T", .T.,.F.)
      lNormal     := IIF(T_USUARIO->ZZT_NORM == "T", .T.,.F.)
      lVisualiza  := IIF(T_USUARIO->ZZT_VISU == "T", .T.,.F.)
      lLogin      := IIF(T_USUARIO->ZZT_LOGI == "T", .T.,.F.)

      // Posiciona na área cadastrada para o usuário
      For nContar = 1 to Len(aComboBx1)
          If SubStr(aComboBx1[nContar],01,06) == Alltrim(T_USUARIO->ZZT_AREA)
             cComboBx1 := aComboBx1[nContar]
             Exit
          Endif
      Next nContar       

   Endif

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Usuários" FROM C(178),C(181) TO C(596),C(602) PIXEL

   @ C(004),C(006) Say "Usuário"                                  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(004),C(065) Say "Nome Completo do Usuário"                 Size C(068),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(027),C(065) Say "E-Mail do Usuário"                        Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(047),C(006) Say "Supervisor do Usuário"                    Size C(052),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(047),C(065) Say "Nome Completo do Supervisor do Usuário"   Size C(108),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(068),C(065) Say "E-Mail do Supervisor do Usuário"          Size C(087),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(090),C(006) Say "ADM Supervisor"                           Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(090),C(065) Say "Nome Completo do ADM do Supervisor"       Size C(095),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(111),C(065) Say "E-Mail do ADM"                            Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(133),C(066) Say "Área do Usuário"                          Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(158),C(017) Say "Tipo de Usuário"                          Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(189),C(006) Say "ATENÇÃO! Os Usuários devem ser os mesmos" Size C(114),C(008) COLOR CLR_RED   PIXEL OF oDlg
   @ C(196),C(006) Say "que estão cadastrados no Protheus."       Size C(086),C(008) COLOR CLR_RED   PIXEL OF oDlg

   @ C(014),C(006) MsGet oGet1 Var cUsuario Size C(050),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(014),C(065) MsGet oGet2 Var cNomeUsu Size C(139),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(036),C(065) MsGet oGet3 Var cEmailUs Size C(139),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(056),C(006) MsGet oGet4 Var cRespons Size C(050),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(056),C(065) MsGet oGet5 Var cNomeRes Size C(139),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(077),C(065) MsGet oGet6 Var cEmailRe Size C(139),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(099),C(006) MsGet oGet7 Var cGerente Size C(050),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(099),C(065) MsGet oGet8 Var cNomeGer Size C(139),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(121),C(065) MsGet oGet9 Var cEmailGe Size C(139),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(142),C(065) ComboBox cComboBx1  Items aComboBx1                       Size C(140),C(010) PIXEL OF oDlg
   @ C(158),C(065) CheckBox oCheckBox1 Var   lAdm        Prompt "ADM"        Size C(024),C(008) PIXEL OF oDlg
   @ C(158),C(105) CheckBox oCheckBox2 Var   lSupervisor Prompt "Supervisor" Size C(036),C(008) PIXEL OF oDlg
   @ C(158),C(157) CheckBox oCheckBox3 Var   lNormal     Prompt "Normal"     Size C(029),C(008) PIXEL OF oDlg

   @ C(173),C(065) CheckBox oCheckBox4 Var   lLogin      Prompt "Verificar Atividades ao logar no Sistema" Size C(109),C(008) PIXEL OF oDlg

   @ C(192),C(129) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg ACTION( _SalvaArea( _Operacao ) )
   @ C(192),C(167) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que realiza a gravação dos dados
Static Function _SalvaArea(_Operacao)

   Local cSql     := ""
   Local __Indica := 0

   If lADM == .F. .and. lSupervisor == .F. .and. lNormal == .F.
      MsgAlert("Tipo de usuário não informado. Verique !!")
      Return .T.
   Endif   
         
   __Indica := 0
      
   If lADM == .T.
      __Indica += 1
   Endif   

   If lSupervisor == .T.
      __Indica += 1
   Endif   

   If lNormal == .T.
      __Indica += 1
   Endif   

   If __Indica > 1
      MsgAlert("Indique apenas um Tipo de Usuário.")
      Return .T.
   Endif   

   // Operação de Inclusão
   If _Operacao == "I"

      If Empty(Alltrim(cUsuario))
         MsgAlert("Usuário não informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(cNomeUsu))
         MsgAlert("Nome do Usuário não informada. Verique !!")
         Return .T.
      Endif   

      If Select("T_JATEM") > 0
         T_JATEM->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZT_USUA, "
      cSql += "       ZZT_NOMS  "
      cSql += "  FROM " + RetSqlName("ZZT")
      cSql += " WHERE ZZT_USUA   = '" + Alltrim(cUsuario) + "'"
      cSql += "   AND ZZT_DELETE = ''"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JATEM", .T., .T. )

      If !T_JATEM->( EOF() )
         MsgAlert("Usuário já cadastrado. Verique!!")
         Return .T.
      Endif

      // Inseri os dados na Tabela
      aArea := GetArea()

      dbSelectArea("ZZT")
      RecLock("ZZT",.T.)
      ZZT_USUA   := cUsuario
      ZZT_NOMS   := cNomeUsu
      ZZT_EMAS   := cEmailUs
      ZZT_RESP   := cRespons
      ZZT_NOMR   := cNomeRes
      ZZT_EMAR   := cEmailRe
      ZZT_GERE   := cGerente
      ZZT_NOMG   := cNomeGer
      ZZT_EMAG   := cEmailGe
      ZZT_AREA   := Substr(cComboBx1,01,06)
      ZZT_ADM    := IIF(lAdm        == .T., "T", "F")
      ZZT_SUPE   := IIF(lSupervisor == .T., "T", "F")
      ZZT_NORM   := IIF(lNormal     == .T., "T", "F")
      ZZT_VISU   := IIF(lvisualiza  == .T., "T", "F")
      ZZT_LOGI   := IIF(lLogin      == .T., "T", "F")
      ZZT_DELETE := ""
      MsUnLock()
      
   Endif

   // Operação de Alteração
   If _Operacao == "A"

      aArea := GetArea()

      DbSelectArea("ZZT")
      DbSetOrder(1)
      If DbSeek(xfilial("ZZT") + cUsuario)
         RecLock("ZZT",.F.)
         ZZT_NOMS   := cNomeUsu
         ZZT_EMAS   := cEmailUs
         ZZT_RESP   := cRespons
         ZZT_NOMR   := cNomeRes
         ZZT_EMAR   := cEmailRe
         ZZT_GERE   := cGerente
         ZZT_NOMG   := cNomeGer
         ZZT_EMAG   := cEmailGe
         ZZT_AREA   := Substr(cComboBx1,01,06)
         ZZT_ADM    := IIF(lAdm        == .T., "T", "F")
         ZZT_SUPE   := IIF(lSupervisor == .T., "T", "F")
         ZZT_NORM   := IIF(lNormal     == .T., "T", "F")
         ZZT_VISU   := IIF(lVisualiza  == .T., "T", "F")
         ZZT_LOGI   := IIF(lLogin      == .T., "T", "F")
         MsUnLock()              
      Endif
      
   Endif

   // Operação de Exclusão
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclusão deste registro?")

         aArea := GetArea()

         DbSelectArea("ZZT")
         DbSetOrder(1)
         If DbSeek(xfilial("ZZT") + cUsuario)
            RecLock("ZZT",.F.)
            ZZT_DELETE := "X"
            MsUnLock()              
         Endif

      Endif   

   Endif

   ODlg:End()

Return Nil