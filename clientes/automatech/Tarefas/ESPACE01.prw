#Include "Protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPACE01.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 09/09/2013                                                          *
// Objetivo..: Programa que controla as solicitações de acessos de menu do sistema *
//**********************************************************************************

User Function ESPACE01()

   Local lChumba     := .F.
   Local cSql        := ""
   Local cMemo1	     := ""
   Local cMemo2	     := ""
   Local oMemo1
   Local oMemo2

   Private aSolicita := {}
   Private aStatus   := {"0 - Todos", "1 = Incluídos", "2 = Alterados", "3 = Excluidos", "4 = Aprovados", "5 - Reprocados", "6 - Em Produção"}
   Private aBrowse   := {}
   Private oBrowse

   Private cComboBx1
   Private cStatus

   // Declara as Legendas
   Private oVerde    := LoadBitmap(GetResources(),'br_verde')
   Private oVermelho := LoadBitmap(GetResources(),'br_vermelho')
   Private oAzul     := LoadBitmap(GetResources(),'br_azul')
   Private oAmarelo  := LoadBitmap(GetResources(),'br_amarelo')
   Private oPreto    := LoadBitmap(GetResources(),'br_preto')
   Private oLaranja  := LoadBitmap(GetResources(),'br_laranja')
   Private oCinza    := LoadBitmap(GetResources(),'br_cinza')
   Private oBranco   := LoadBitmap(GetResources(),'br_branco')

   Private oDlg
   
   // Crarega o combo de Usuários
   If Alltrim(Upper(cUserName))$("ADMINISTRADOR")
      lChumba := .T.
      // Pesquisa os usuários importados para display
      If Select("T_USUARIO") > 0
         T_USUARIO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZA_CODI, "
      cSql += "       ZZA_NOME, "
      cSql += "       ZZA_EMAI  "
      cSql += "  FROM " + RetSqlName("ZZA")
      cSql += " ORDER BY ZZA_NOME "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIO", .T., .T. )

      If T_USUARIO->( EOF() )
         aUsuarios := {}
      Else
         T_USUARIO->( DbGoTop() )
         WHILE !T_USUARIO->( EOF() )
            aAdd( aSolicita, T_USUARIO->ZZA_NOME )
            T_USUARIO->( DbSkip() )
         ENDDO
      ENDIF
   Else
      lChumba := .F.
      aAdd( aSolicita, cUserName )
   Endif   

   aAdd( aBrowse, { "1", "", "", "", "", "", "", "" } )

   DEFINE MSDIALOG oDlg TITLE "Solicitação de Acessos Sistema Protheus" FROM C(178),C(181) TO C(595),C(876) PIXEL

   @ C(005),C(005) Say "Solicitantes"    Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(005),C(138) Say "Status"          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(165),C(005) Say "L e g e n d a s" Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(176),C(016) Say "Inclusão"        Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(176),C(052) Say "Alteração"       Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(176),C(090) Say "Exclusão"        Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(176),C(126) Say "Aprovados"       Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(176),C(168) Say "Reprovados"      Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(176),C(213) Say "Em Produção"     Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
      
   @ C(169),C(042) GET oMemo2 Var cMemo2 MEMO Size C(302),C(001) PIXEL OF oDlg
   @ C(176),C(004) Jpeg FILE "br_amarelo"     Size C(010),C(010) PIXEL NOBORDER OF oDlg
   @ C(176),C(040) Jpeg FILE "br_laranja"     Size C(010),C(010) PIXEL NOBORDER OF oDlg
   @ C(176),C(078) Jpeg FILE "br_vermelho"    Size C(010),C(010) PIXEL NOBORDER OF oDlg
   @ C(176),C(114) Jpeg FILE "br_verde"       Size C(010),C(010) PIXEL NOBORDER OF oDlg
   @ C(176),C(155) Jpeg FILE "br_preto"       Size C(010),C(010) PIXEL NOBORDER OF oDlg
   @ C(176),C(200) Jpeg FILE "br_azul"        Size C(010),C(010) PIXEL NOBORDER OF oDlg
   @ C(188),C(005) GET oMemo1 Var cMemo1 MEMO Size C(340),C(002) PIXEL OF oDlg

   @ C(014),C(005) ComboBox cComboBx1 Items aSolicita When lChumba Size C(127),C(010) PIXEL OF oDlg
   @ C(014),C(138) ComboBox cStatus   Items aStatus                Size C(072),C(010) PIXEL OF oDlg

   @ C(012),C(217) Button "Pesquisar"           Size C(037),C(012) PIXEL OF oDlg ACTION(CarregaSolAcessos())

   @ C(192),C(005) Button "Incluir"             Size C(057),C(012) PIXEL OF oDlg ACTION( Abre_Acesso("I", "", "" ) )
   @ C(192),C(063) Button "Alterar/Visualizar"  Size C(057),C(012) PIXEL OF oDlg ACTION( Abre_Acesso("A", aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,01]) )
   @ C(192),C(122) Button "Excluir"             Size C(057),C(012) PIXEL OF oDlg ACTION( Abre_Acesso("E", aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,01]) )
// @ C(192),C(199) Button "Aprova/Reprova Solicitação" Size C(085),C(012) PIXEL OF oDlg ACTION( Abre_Acesso("L", aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,01]) )
   @ C(192),C(307) Button "Voltar"              Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 035 , 005, 435, 175,,{'', 'Código', 'Solicitante', 'Beneficiado', 'Data Solic.', 'Menu', 'Data Aprov/Reprov', 'Data Produção'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
   
   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   CarregaSolAcessos()
   
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oCinza   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho, oBranco)))))))),;                         
                         aBrowse[oBrowse:nAt,02]               ,;
                         aBrowse[oBrowse:nAt,03]               ,;
                         aBrowse[oBrowse:nAt,04]               ,;                         
                         aBrowse[oBrowse:nAt,05]               ,;                         
                         aBrowse[oBrowse:nAt,06]               ,;                         
                         aBrowse[oBrowse:nAt,07]               ,;                         
                         aBrowse[oBrowse:nAt,08]               }}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que abre a tela de manutenção da solicitação de acessos
Static Function Abre_Acesso(_Operacao, _Codigo, _Legenda)

   Local cSql           := ""
   Local lChumba        := .F.
   Local lChumbaU       := .T.
   Local lSalvar        := .F.

   Private aSolicitante := {}
   Private aBeneficiado := {}
   Private aModulos     := {"ATF - Ativo", "COM - Compras", "EST - Estoque", "FAT - Faturamento", "FIN - Financeiro", "FIS - Livros Fiscais", "TMK - Call Center", "TEC - Field Service", "CTB - Contabilidade Gerencial", "GCT - Contrato"}

   Private cComboBx1
   Private cComboBx2
   Private cComboBx3
   Private cNomeMenu := Space(60)
   Private cNomeProg := Space(60)
   Private cCodigo	 := Space(06)
   Private cData	 := Date()
   Private cHora 	 := Time()
   Private cAbas     := 0
   Private cNota	 := ""
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oMemo1

   Private oDlgS

   // Abre ou Fecha o botão Salvar conforme a legenda o registro
   If _Legenda = "" .Or. _Legenda == "4" .Or. _Legenda == "6"
      lSalvar := .T.
   Else
      lSalvar := .F.      
   Endif

   // Crarega o combo de Usuários
   If Alltrim(Upper(cUserName))$("ADMINISTRADOR")
      // Pesquisa os usuários importados para display
      If Select("T_USUARIO") > 0
         T_USUARIO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZA_CODI, ZZA_NOME, ZZA_EMAI FROM " + RetSqlName("ZZA") + " ORDER BY ZZA_NOME "
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIO", .T., .T. )

      If T_USUARIO->( EOF() )
         aSolicitante := {}
      Else
         T_USUARIO->( DbGoTop() )
         WHILE !T_USUARIO->( EOF() )
            aAdd( aSolicitante, T_USUARIO->ZZA_NOME )
            T_USUARIO->( DbSkip() )
         ENDDO
      ENDIF
   Else
      aAdd( aSolicitante, cUserName )
   Endif   

   // Crarega o combo de Beneficiados
   If Select("T_USUARIO") > 0
      T_USUARIO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZA_CODI, ZZA_NOME, ZZA_EMAI FROM " + RetSqlName("ZZA") + " ORDER BY ZZA_NOME "
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIO", .T., .T. )

   If T_USUARIO->( EOF() )
      aBeneficiado := {}
   Else
      T_USUARIO->( DbGoTop() )
      WHILE !T_USUARIO->( EOF() )
         aAdd( aBeneficiado, T_USUARIO->ZZA_NOME )
         T_USUARIO->( DbSkip() )
      ENDDO
   ENDIF

   // Caso for alteração ou exclusão, carrega os dados para display
   If _Operacao == "I"
      lChumbaU := .T.
   Else   

      lChumbaU := .F.

      If Select("T_CONSULTA") > 0
         T_CONSULTA->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZS3_FILIAL,"
      cSql += "       ZS3_CODI  ,"
      cSql += "       ZS3_DATA  ,"
      cSql += "       ZS3_HORA  ,"
      cSql += "       ZS3_STAT  ,"
      cSql += "       ZS3_SOLI  ,"
      cSql += "       ZS3_BENE  ,"
      cSql += "       ZS3_MODU  ,"
      cSql += "       ZS3_MENU  ,"
      cSql += "       ZS3_PROG  ,"
      cSql += "       ZS3_ABAS  ,"
      cSql += "       CAST( CAST(ZS3_NOTA AS VARBINARY(1024)) AS VARCHAR(1024)) AS NOTA"
      cSql += "  FROM " + RetSqlName("ZS3")
      cSql += " WHERE ZS3_CODI = '" + Alltrim(_Codigo) + "'"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

//      If _Operacao == "A"
//         If T_CONSULTA->ZS3_STAT = '3'
//            MsgAlert("Alteração não permitida. Registro foi excluído.")
//            Return(.T.)
//         Endif
//      Endif

      cCodigo   := T_CONSULTA->ZS3_CODI
      cData     := T_CONSULTA->ZS3_DATA
      cHora     := T_CONSULTA->ZS3_HORA
      cComboBx1 := T_CONSULTA->ZS3_SOLI
      cComboBx2 := T_CONSULTA->ZS3_BENE
      cComboBx3 := T_CONSULTA->ZS3_MODU
      cNomeMenu := T_CONSULTA->ZS3_MENU
      cNomeProg := T_CONSULTA->ZS3_PROG
      cAbas     := T_CONSULTA->ZS3_ABAS
      cNota     := T_CONSULTA->NOTA

      // Posiciona o combo dos Módulos
      Do Case
         Case Alltrim(T_CONSULTA->ZS3_MODU) == "ATF"
              cComboBx3 := "ATF - Ativo" 
         Case Alltrim(T_CONSULTA->ZS3_MODU) == "COM"
              cComboBx3 := "COM - Compras" 
         Case Alltrim(T_CONSULTA->ZS3_MODU) == "EST"
              cComboBx3 := "EST - Estoque"          
         Case Alltrim(T_CONSULTA->ZS3_MODU) == "FAT"
              cComboBx3 := "FAT - Faturamento" 
         Case Alltrim(T_CONSULTA->ZS3_MODU) == "FIN"
              cComboBx3 := "FIN - Financeiro" 
         Case Alltrim(T_CONSULTA->ZS3_MODU) == "FIS"
              cComboBx3 := "FIS - Livros Fiscais" 
         Case Alltrim(T_CONSULTA->ZS3_MODU) == "TMK"
              cComboBx3 := "TMK - Call Center" 
         Case Alltrim(T_CONSULTA->ZS3_MODU) == "TEC"
              cComboBx3 := "TEC - Field Service" 
         Case Alltrim(T_CONSULTA->ZS3_MODU) == "CTB"
              cComboBx3 := "CTB - Contabilidade Gerencial" 
         Case Alltrim(T_CONSULTA->ZS3_MODU) == "CGT"
              cComboBx3 := "GCT - Contrato"
      EndCase

   Endif

   DEFINE MSDIALOG oDlgS TITLE "Solicitação de Acesso ao Protheus" FROM C(178),C(181) TO C(635),C(506) PIXEL

   @ C(005),C(005) Say "Código"                     Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
   @ C(005),C(037) Say "Data Solic."                Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
   @ C(005),C(082) Say "Hora"                       Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
   @ C(025),C(005) Say "Solicitante"                Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
   @ C(046),C(005) Say "Para quem"                  Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
   @ C(069),C(005) Say "Módulo"                     Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
   @ C(093),C(005) Say "Nome do Menu"               Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
   @ C(115),C(005) Say "Nome do Programa"           Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
   @ C(139),C(005) Say "Aumentar nº de abas para"   Size C(064),C(008) COLOR CLR_BLACK PIXEL OF oDlgS
   @ C(152),C(005) Say "Motivo Liberação do Acesso" Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlgS

   @ C(014),C(005) MsGet      oGet3     Var    cCodigo      When lChumba Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgS
   @ C(014),C(037) MsGet      oGet4     Var    cData        When lChumba Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgS
   @ C(014),C(082) MsGet      oGet5     Var    cHora        When lChumba Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgS

   If Alltrim(Upper(cUserName))$("ADMINISTRADOR")   
      If _Operacao == "I"
         @ C(034),C(005) ComboBox   cComboBx1 Items  aSolicitante               Size C(151),C(010) PIXEL OF oDlgS
      Else
         @ C(034),C(005) ComboBox   cComboBx1 Items  aSolicitante When lChumbaU Size C(151),C(010) PIXEL OF oDlgS
      Endif            
   Else
      If _Operacao == "I"
         @ C(034),C(005) ComboBox   cComboBx1 Items  aSolicitante When lChumba  Size C(151),C(010) PIXEL OF oDlgS
      Else
         @ C(034),C(005) ComboBox   cComboBx1 Items  aSolicitante When lChumbaU Size C(151),C(010) PIXEL OF oDlgS         
      Endif   
   Endif
         
   @ C(055),C(005) ComboBox   cComboBx2 Items  aBeneficiado When lChumbaU Size C(151),C(010) PIXEL OF oDlgS
   @ C(080),C(005) ComboBox   cComboBx3 Items  aModulos     Size C(151),C(010) PIXEL OF oDlgS
   @ C(103),C(005) MsGet      oGet1     Var    cNomeMenu    Size C(151),C(009) COLOR CLR_BLACK Picture "@!"    PIXEL OF oDlgS
   @ C(124),C(005) MsGet      oGet2     Var    cNomeProg    Size C(151),C(009) COLOR CLR_BLACK Picture "@!"    PIXEL OF oDlgS
   @ C(138),C(070) MsGet      oGet6     Var    cAbas        Size C(017),C(009) COLOR CLR_BLACK Picture "@E 99" PIXEL OF oDlgS
   @ C(161),C(005) GET oMemo1 Var       cNota  MEMO         Size C(151),C(047) PIXEL OF oDlgS

   @ C(212),C(079) Button "Salvar" When lSalvar Size C(037),C(012) PIXEL OF oDlgS ACTION( SalvaAcesso(_Operacao, cCodigo) )
   @ C(212),C(119) Button "Voltar"              Size C(037),C(012) PIXEL OF oDlgS ACTION( oDlgS:End() )

   ACTIVATE MSDIALOG oDlgS CENTERED 

Return(.T.)

// Função que grava a solicitação de acesso
Static Function SalvaAcesso(_Operacao, _Codigo)
                            
   Local cSql    := ""
   Local nCodigo := ""
   Local cEmail  := ""
   Local c_email := ""

   // Operação de Inclusão
   If _Operacao == "I"

      If Empty(Alltrim(cComboBx1))
         MsgAlert("Solicitante não informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(cComboBx2))
         MsgAlert("Beneficiado não informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(cComboBx3))
         MsgAlert("Módulo não informado. Verique !!")
         Return .T.
      Endif   

      If Empty(Alltrim(cNomeMenu))
         MsgAlert("Nome do Menu/Opção não informado. Verique !!")
         Return .T.
      Endif   

      // Pesquisa o Próximo Código para inclusão
      If Select("T_NOVO") > 0
         T_NOVO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZS3_CODI "
      cSql += "  FROM " + RetSqlName("ZS3")
      cSql += " ORDER BY ZS3_CODI DESC"
      
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOVO", .T., .T. )

      If T_NOVO->( EOF() )
         nCodigo := '000001'
      Else
         nCodigo := Strzero((INT(VAL(T_NOVO->ZS3_CODI)) + 1),6)      
      Endif

      // Inseri os dados na Tabela
      aArea := GetArea()

      dbSelectArea("ZS3")
      RecLock("ZS3",.T.)
      ZS3_FILIAL := ""
      ZS3_CODI   := nCodigo
      ZS3_DATA   := cData
      ZS3_HORA   := cHora
      ZS3_STAT   := '1'
      ZS3_SOLI   := cComboBx1
      ZS3_BENE   := cComboBx2
      ZS3_MODU   := cComboBx3
      ZS3_MENU   := cNomeMenu
      ZS3_PROG   := cNomeProg
      ZS3_ABAS   := cAbas
      ZS3_NOTA   := cNota
      ZS3_DELE   := ""
      MsUnLock()

      MsgAlert("Solicitação de Acesso gravada com o código: " + Alltrim(nCodigo))

      // Elabora o texto do e-mail para envio do alerta ao aprovador
      cEmail := ""
      cEmail := "Prezado(a) Aprovador(a):" + chr(13) + chr(10) + chr(13) + chr(10)
      cEmail += "O usuário " + Alltrim(cComboBx1) + ", está solicitando sua aprovação na Liberação de Acesso ao" + chr(13) + chr(10)
      cEmail += "menu do Sistema Protheus conforme dados abaixo:" + chr(13) + chr(10) + chr(13) + chr(10)
      cEmail += "Código Solicitação.: " + Alltrim(nCodigo)        + chr(13) + chr(10)
      cEmail += "Data Solicitação...: " + Dtoc(cData)             + chr(13) + chr(10)
      cEmail += "Hora Solicitação...: " + cHora                   + chr(13) + chr(10)
      cEmail += "Beneficiado........: " + Alltrim(cComboBx2)      + chr(13) + chr(10)
      cEmail += "Módulo.............: " + Alltrim(cComboBx3)      + chr(13) + chr(10)
      
      If !Empty(Alltrim(cNomeMenu))      
         cEmail += "Menu...............: " + Alltrim(cNomeMenu)      + chr(13) + chr(10)
      Endif
      
      If !Empty(Alltrim(cNomeProg))
         cEmail += "Programa...........: " + Alltrim(cNomeProg)      + chr(13) + chr(10)
      Endif
         
      If cAbas <> 0
         cEmail += "Nº de Abas.........: " + Str(cAbas)              + chr(13) + chr(10)
      Endif   

      cEmail += "Motivo da Liberação: " + chr(13) + chr(10)
      cEmail += Alltrim(cNota)          + chr(13) + chr(10) + chr(13) + chr(10)
      cEmail += "Att." + chr(13)        + chr(13) + chr(10)
      cEmail += Alltrim(cComboBx1)      + chr(13) + chr(10)

      // Pesquisa o e-mail do aprovador
      If Select("T_MASTER") > 0
         T_MASTER->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZJ_ACES"
      cSql += "  FROM " + RetSqlName("ZZJ")

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_MASTER", .T., .T. )

      If T_MASTER->( EOF() )
         c_email := ""
      Else
         c_email := T_MASTER->ZZJ_ACES
      Endif
         
      // Envia e-mail ao Aprovador
      If Empty(c_email)
      Else   
         U_AUTOMR20(cEmail ,c_email, "", "Solicitação de Liberação de Acesso de Menu Protheus" )
      Endif

   Endif

   // Operação de Alteração
   If _Operacao == "A"

      aArea := GetArea()

      DbSelectArea("ZS3")
      DbSetOrder(1)
      If DbSeek(xfilial("ZS3") + _Codigo)
         RecLock("ZS3",.F.)
//       ZS3_DATA   := cData
//       ZS3_HORA   := cHora
         ZS3_STAT   := '2'
         ZS3_SOLI   := cComboBx1
         ZS3_BENE   := cComboBx2
         ZS3_MODU   := cComboBx3
         ZS3_MENU   := cNomeMenu
         ZS3_PROG   := cNomeProg
         ZS3_ABAS   := cAbas
         ZS3_NOTA   := cNota
         ZS3_DELE   := ""
         MsUnLock()              
      Endif

   Endif

   // Operação de Exclusão
   If _Operacao == "E"

      If MsgYesNo("Confirma a exclusão deste registro?")

         aArea := GetArea()

         DbSelectArea("ZS3")
         DbSetOrder(1)
         If DbSeek(xfilial("ZS3") + _Codigo)
            RecLock("ZS3",.F.)
            ZS3_STAT := '3'
            ZS3_DELE := "X"
            MsUnLock()              
         Endif

      Endif   

   Endif

   ODlgS:End()

   CarregaSolAcessos()
   
Return(.T.)

// Função que carrega o grid de solicitação de acessos do usuário solicitante selecionado
Static Function CarregaSolAcessos()

   Local cSql := ""
   
   aBrowse := {}
   
   If Select("T_ACESSOS") > 0
      T_ACESSOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZS3_STAT," + chr(13)
   cSql += "       ZS3_CODI," + chr(13)
   cSql += "       ZS3_SOLI," + chr(13)
   cSql += "       ZS3_BENE," + chr(13)
   cSql += "       ZS3_DATA," + chr(13)
   cSql += "       ZS3_MENU," + chr(13)
   cSql += "       ZS3_ANAL," + chr(13)
   cSql += "       ZS3_PROD " + chr(13)
   cSql += "  FROM " + RetSqlName("ZS3") + chr(13)
   cSql += " WHERE UPPER(ZS3_SOLI) = '" + Alltrim(Upper(cComboBx1)) + "'" + chr(13)

   If Substr(cStatus,01,01) == "0"
   Else
      cSql += " AND ZS3_STAT = '" + SubStr(cStatus,01,01) + "'" + chr(13)
   Endif   
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ACESSOS", .T., .T. )

   If T_ACESSOS->( EOF() )
      MsgAlert("Não existem dados a serem visualizados.")
      aAdd( aBrowse, { "1", "", "", "", "", "", "", "" } )
   Else
      T_ACESSOS->( DbGoTop() )
      WHILE !T_ACESSOS->( EOF() )

         Do Case
            Case T_ACESSOS->ZS3_STAT == '1'
                 cLegenda = '4'
            Case T_ACESSOS->ZS3_STAT == '2'
                 cLegenda = '6'
            Case T_ACESSOS->ZS3_STAT == '3'
                 cLegenda = '8'
            Case T_ACESSOS->ZS3_STAT == '4'
                 cLegenda = '2'
            Case T_ACESSOS->ZS3_STAT == '5'
                 cLegenda = '7'
            Case T_ACESSOS->ZS3_STAT == '6'
                 cLegenda = '5'
         EndCase
                          
         aAdd( aBrowse, { cLegenda           ,;
                          T_ACESSOS->ZS3_CODI,;
                          ALLTRIM(UPPER(T_ACESSOS->ZS3_SOLI)),;
                          ALLTRIM(UPPER(T_ACESSOS->ZS3_BENE)),;
                          Substr(T_ACESSOS->ZS3_DATA,07,02) + "/" + Substr(T_ACESSOS->ZS3_DATA,05,02) + "/" + Substr(T_ACESSOS->ZS3_DATA,01,04),;
                          T_ACESSOS->ZS3_MENU,;
                          Substr(T_ACESSOS->ZS3_ANAL,07,02) + "/" + Substr(T_ACESSOS->ZS3_ANAL,05,02) + "/" + Substr(T_ACESSOS->ZS3_ANAL,01,04),;
                          Substr(T_ACESSOS->ZS3_PROD,07,02) + "/" + Substr(T_ACESSOS->ZS3_PROD,05,02) + "/" + Substr(T_ACESSOS->ZS3_PROD,01,04)})
         T_ACESSOS->( DbSkip() )

      ENDDO

   Endif
                                         
   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ If(Alltrim(aBrowse[oBrowse:nAt,01]) == "1", oBranco  ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "2", oVerde   ,;
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "3", oCinza   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "4", oAmarelo ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "5", oAzul    ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "6", oLaranja ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "7", oPreto   ,;                         
                         If(Alltrim(aBrowse[oBrowse:nAt,01]) == "8", oVermelho, oBranco)))))))),;                         
                         aBrowse[oBrowse:nAt,02]               ,;
                         aBrowse[oBrowse:nAt,03]               ,;
                         aBrowse[oBrowse:nAt,04]               ,;                         
                         aBrowse[oBrowse:nAt,05]               ,;                         
                         aBrowse[oBrowse:nAt,06]               ,;                         
                         aBrowse[oBrowse:nAt,07]               ,;                         
                         aBrowse[oBrowse:nAt,08]               }}

Return(.T.)