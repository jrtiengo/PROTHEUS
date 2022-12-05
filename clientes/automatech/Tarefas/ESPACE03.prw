#Include "Protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: ESPACE03.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 13/09/2013                                                          *
// Objetivo..: Programa que realiza inclui Acessos liberados em Produção           *
//**********************************************************************************

User Function ESPACE03()

   // Declara as Imagens das Legendas
   Private oVerde    := LoadBitmap(GetResources(),'br_verde')
   Private oVermelho := LoadBitmap(GetResources(),'br_vermelho')
   Private oAzul     := LoadBitmap(GetResources(),'br_azul')
   Private oAmarelo  := LoadBitmap(GetResources(),'br_amarelo')
   Private oPreto    := LoadBitmap(GetResources(),'br_preto')
   Private oLaranja  := LoadBitmap(GetResources(),'br_laranja')
   Private oCinza    := LoadBitmap(GetResources(),'br_cinza')
   Private oBranco   := LoadBitmap(GetResources(),'br_branco')

   Private aBrowse   := {}
   Private oBrowse

   Private oDlg

   aAdd( aBrowse, { "1", "", "", "", "", ""} )

   DEFINE MSDIALOG oDlg TITLE "Liberação Acesso em produção" FROM C(178),C(181) TO C(595),C(882) PIXEL

   @ C(192),C(221) Button "Liberar em Produção" Size C(085),C(012) PIXEL OF oDlg ACTION( LibAcesso(aBrowse[oBrowse:nAt,02]) )
   @ C(192),C(307) Button "Voltar"              Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 005, 005, 435, 235,,{'', 'Código', 'Solicitante', 'Beneficiado', 'Data Solic.', 'Menu'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
   
   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 
    
   CarregaAprovacao()
   
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
                         aBrowse[oBrowse:nAt,06]               }}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// Função que Aprova ou Reprova a solicitação de Acesso
Static Function LibAcesso(_Codigo)

   Private lChumba      := .F.
   Private cSolicitante := ""
   Private cBeneficiado := ""
   Private cModulos 	:= ""
   Private cAprovador   := cUserName
   Private cNomeMenu    := Space(60)
   Private cNomeProg    := Space(60)
   Private cCodigo      := ""
   Private cData	    := ""
   Private cHora	    := ""
   Private cDataAnal    := Ctod("  /  /    ")
   Private cProducao    := Date()
   Private cAbas        := 0
   Private cNota	    := ""
   Private cMemo2	    := ""
   Private cMemo3	    := ""
   Private cMemo4	    := ""
   Private lAprovado	:= .F.
   Private lReprovado 	:= .F.
   Private lCheckBox3	:= .T.
   Private lCheckBox4	:= .T.
   Private lCheckBox5	:= .T.
   Private lCheckBox6	:= .T.
   Private lCheckBox7	:= .T.
   Private lCheckBox8	:= .T.
   Private lCheckBox9	:= .T.
   Private lCheckBox10  := .T.
   Private lCheckBox11  := .T.
   Private lCheckBox12  := .T.

   Private oCheckBox1
   Private oCheckBox10
   Private oCheckBox11
   Private oCheckBox12
   Private oCheckBox2
   Private oCheckBox3
   Private oCheckBox4
   Private oCheckBox5
   Private oCheckBox6
   Private oCheckBox7
   Private oCheckBox8
   Private oCheckBox9
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet7
   Private oGet8   
   Private oGet9   
   Private oGet10   
   Private oGet11         
   Private oGet12         
   Private oGet13         
   Private oMemo1
   Private oMemo2
   Private oMemo3
   Private oMemo4

   Private oDlgL

   // Pesquisa os dados da solicitação de acesso
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
   cSql += "       ZS3_APRO  ,"
   cSql += "       ZS3_REPR  ,"
   cSql += "       ZS3_DAPR  ,"
   cSql += "       ZS3_QUEM  ,"
   cSql += "       ZS3_LB01  ,"
   cSql += "       ZS3_LB02  ,"
   cSql += "       ZS3_LB03  ,"
   cSql += "       ZS3_LB04  ,"
   cSql += "       ZS3_LB05  ,"
   cSql += "       ZS3_LB06  ,"
   cSql += "       ZS3_LB07  ,"
   cSql += "       ZS3_LB08  ,"
   cSql += "       ZS3_LB09  ,"
   cSql += "       ZS3_LB10  ,"
   cSql += "       CAST( CAST(ZS3_NOTA AS VARBINARY(1024)) AS VARCHAR(1024)) AS NOTA,"
   cSql += "       CAST( CAST(ZS3_OBSE AS VARBINARY(1024)) AS VARCHAR(1024)) AS NOTA1"
   cSql += "  FROM " + RetSqlName("ZS3")
   cSql += " WHERE ZS3_CODI = '" + Alltrim(_Codigo) + "'"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   cCodigo      := T_CONSULTA->ZS3_CODI
   cData        := T_CONSULTA->ZS3_DATA
   cHora        := T_CONSULTA->ZS3_HORA
   cSolicitante := T_CONSULTA->ZS3_SOLI
   cBeneficiado := T_CONSULTA->ZS3_BENE
   cModulos     := T_CONSULTA->ZS3_MODU
   cNomeMenu    := T_CONSULTA->ZS3_MENU
   cNomeProg    := T_CONSULTA->ZS3_PROG
   cAbas        := T_CONSULTA->ZS3_ABAS
   cNota        := T_CONSULTA->NOTA
   cDataAnal    := Substr(T_CONSULTA->ZS3_DAPR,07,02) + "/" + Substr(T_CONSULTA->ZS3_DAPR,05,02) + "/" + Substr(T_CONSULTA->ZS3_DAPR,01,04)
   lAprovado	:= IIF(T_CONSULTA->ZS3_APRO == '1', .T., .F.)
   lReprovado 	:= IIF(T_CONSULTA->ZS3_REPR == '1', .T., .F.)
   lCheckBox3	:= IIF(T_CONSULTA->ZS3_LB01 == '1', .T., .F.)
   lCheckBox4	:= IIF(T_CONSULTA->ZS3_LB02 == '1', .T., .F.)
   lCheckBox5	:= IIF(T_CONSULTA->ZS3_LB03 == '1', .T., .F.)
   lCheckBox6	:= IIF(T_CONSULTA->ZS3_LB04 == '1', .T., .F.)
   lCheckBox7	:= IIF(T_CONSULTA->ZS3_LB05 == '1', .T., .F.)
   lCheckBox8	:= IIF(T_CONSULTA->ZS3_LB06 == '1', .T., .F.)
   lCheckBox9	:= IIF(T_CONSULTA->ZS3_LB07 == '1', .T., .F.)
   lCheckBox10  := IIF(T_CONSULTA->ZS3_LB08 == '1', .T., .F.)
   lCheckBox11  := IIF(T_CONSULTA->ZS3_LB09 == '1', .T., .F.)
   lCheckBox12  := IIF(T_CONSULTA->ZS3_LB10 == '1', .T., .F.)
   cMemo3	    := T_CONSULTA->NOTA1

   // Posiciona o combo dos Módulos
   Do Case
      Case Alltrim(T_CONSULTA->ZS3_MODU) == "ATF"
           cModulos := "ATF - Ativo" 
      Case Alltrim(T_CONSULTA->ZS3_MODU) == "COM"
           cModulos := "COM - Compras" 
      Case Alltrim(T_CONSULTA->ZS3_MODU) == "EST"
           cModulos := "EST - Estoque"          
      Case Alltrim(T_CONSULTA->ZS3_MODU) == "FAT"
           cModulos := "FAT - Faturamento" 
      Case Alltrim(T_CONSULTA->ZS3_MODU) == "FIN"
           cModulos := "FIN - Financeiro" 
      Case Alltrim(T_CONSULTA->ZS3_MODU) == "FIS"
           cModulos := "FIS - Livros Fiscais" 
      Case Alltrim(T_CONSULTA->ZS3_MODU) == "TMK"
           cModulos := "TMK - Call Center" 
      Case Alltrim(T_CONSULTA->ZS3_MODU) == "TEC"
           cModulos := "TEC - Field Service" 
      Case Alltrim(T_CONSULTA->ZS3_MODU) == "CTB"
           cModulos := "CTB - Contabilidade Gerencial" 
      Case Alltrim(T_CONSULTA->ZS3_MODU) == "CGT"
           cModulos := "GCT - Contrato"
   EndCase

   DEFINE MSDIALOG oDlgL TITLE "Solicitação de Acesso ao Protheus" FROM C(178),C(181) TO C(626),C(763) PIXEL

   @ C(005),C(005) Say "Código"                     Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(005),C(037) Say "Data Solic."                Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(005),C(082) Say "Hora"                       Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(006),C(188) Say "APROVAÇÃO/REPROVAÇÃO"       Size C(075),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(024),C(236) Say "Data"                       Size C(014),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(025),C(005) Say "Solicitante"                Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(045),C(173) Say "Aprovador/Reprovador por"   Size C(067),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(046),C(005) Say "Para quem"                  Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(069),C(005) Say "Módulo"                     Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(070),C(173) Say "OPÇÕES (xxxxxxxxxx)"        Size C(060),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(093),C(005) Say "Nome do Menu"               Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(115),C(005) Say "Nome do Programa"           Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(141),C(005) Say "Aumentar Nº de Abas para"   Size C(064),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(155),C(005) Say "Motivo Liberação do Acesso" Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(135),C(173) Say "Observações"                Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(192),C(173) Say "Data Produção"              Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(090),C(214) Say "Opções de 1 a 5 são padrão" Size C(070),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(099),C(214) Say "para todos os cadastros."   Size C(063),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(109),C(214) Say "As opções de 6 a 10, "      Size C(055),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(119),C(214) Say "depende de cada cadastro."  Size C(067),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
	
   @ C(003),C(163) GET oMemo2 Var cMemo2 MEMO Size C(001),C(218) PIXEL OF oDlgL
   @ C(078),C(173) GET oMemo4 Var cMemo4 MEMO Size C(112),C(001) PIXEL OF oDlgL

   // Solicitação
   @ C(014),C(005) MsGet oGet3      Var   cCodigo      When lChumba Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL
   @ C(014),C(037) MsGet oGet4      Var   cData        When lChumba Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL
   @ C(014),C(082) MsGet oGet5      Var   cHora        When lChumba Size C(033),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL
   @ C(034),C(005) MsGet oGet9      Var   cSolicitante When lChumba Size C(151),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL
   @ C(055),C(005) MsGet oGet10     Var   cBeneficiado When lChumba Size C(151),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL
   @ C(080),C(005) MsGet oGet11     Var   cModulos     When lChumba Size C(151),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL
   @ C(103),C(005) MsGet oGet1      Var   cNomeMenu    When lChumba Size C(151),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL
   @ C(124),C(005) MsGet oGet2      Var   cNomeProg    When lChumba Size C(151),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL
   @ C(140),C(072) MsGet oGet8      Var   cAbas        When lChumba Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL
   @ C(164),C(005) GET   oMemo1     Var   cNota MEMO   When lChumba Size C(151),C(055) PIXEL OF oDlgL

   // Aprovação
   @ C(019),C(173) CheckBox oCheckBox1  Var lAProvado  Prompt "Aprovado"     When lChumba Size C(034),C(008) PIXEL OF oDlgL
   @ C(031),C(173) CheckBox oCheckBox2  Var lReprovado Prompt "Reprovado"    When lChumba Size C(037),C(008) PIXEL OF oDlgL
   @ C(024),C(252) MsGet    oGet7       Var cDataAnal                        When lChumba Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL
   @ C(055),C(173) MsGet    oGet12      Var cAprovador                       When lChumba Size C(112),C(010) PIXEL OF oDlgL
   @ C(083),C(173) CheckBox oCheckBox3  Var lCheckBox3 Prompt "Pesquisar"    When lChumba Size C(034),C(008) PIXEL OF oDlgL
   @ C(094),C(173) CheckBox oCheckBox4  Var lCheckBox4 Prompt "Visualizar"   When lChumba Size C(033),C(008) PIXEL OF oDlgL
   @ C(104),C(173) CheckBox oCheckBox5  Var lCheckBox5 Prompt "Incluir"      When lChumba Size C(027),C(007) PIXEL OF oDlgL
   @ C(114),C(173) CheckBox oCheckBox6  Var lCheckBox6 Prompt "Alterar"      When lChumba Size C(028),C(008) PIXEL OF oDlgL
   @ C(124),C(173) CheckBox oCheckBox7  Var lCheckBox7 Prompt "Excluir"      When lChumba Size C(028),C(008) PIXEL OF oDlgL
// @ C(083),C(226) CheckBox oCheckBox8  Var lCheckBox8 Prompt "Copiar"       When lChumba Size C(026),C(008) PIXEL OF oDlgL
// @ C(094),C(226) CheckBox oCheckBox9  Var lCheckBox9 Prompt "Conhecimento" When lChumba Size C(048),C(008) PIXEL OF oDlgL
// @ C(104),C(226) CheckBox oCheckBox10 Var lCheckBox10 Prompt "?"           When lChumba Size C(042),C(008) PIXEL OF oDlgL
// @ C(114),C(225) CheckBox oCheckBox11 Var lCheckBox11 Prompt "Facilitador" When lChumba Size C(037),C(008) PIXEL OF oDlgL
// @ C(124),C(226) CheckBox oCheckBox12 Var lCheckBox12 Prompt "?"           When lChumba Size C(038),C(008) PIXEL OF oDlgL
   @ C(145),C(173) GET      oMemo3      Var cMemo3 MEMO                      When lChumba Size C(112),C(043) PIXEL OF oDlgL
   @ C(192),C(211) MsGet    oGet13      Var cProducao                                     Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL

   @ C(206),C(189) Button "Salvar" Size C(037),C(012) PIXEL OF oDlgL ACTION( SalvaProdução() )
   @ C(206),C(227) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgL ACTION( oDlgL:End() )

   ACTIVATE MSDIALOG oDlgL CENTERED 

Return(.T.)

// Função que salva a aprovação/reprovação
Static Function SalvaProducao()

   Local cSql    := ""
   Local cEmail  := ""
   Local c_email := ""

   If Empty(cProducao)
      MsgAlert("Necessário informar data em que acesso foi liberado em produção.")
      Return .T.
   Endif

   DbSelectArea("ZS3")
   DbSetOrder(1)
   If DbSeek(xfilial("ZS3") + cCodigo)
      RecLock("ZS3",.F.)
      ZS3_STAT := '6'
      ZS3_DPRO := cProducao
      ZS3_QPRO := cUserName
      MsUnLock()              

      // Envia e-mail ao solicitante informando que o acesso foi colocado em produção
      If Select("T_ACESSOS") > 0
         T_ACESSOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZS3_STAT," + chr(13)
      cSql += "       ZS3_CODI," + chr(13)
      cSql += "       ZS3_SOLI," + chr(13)
      cSql += "       ZS3_BENE," + chr(13)
      cSql += "       ZS3_DATA," + chr(13)
      cSql += "       ZS3_HORA," + chr(13)
      cSql += "       ZS3_MODU," + chr(13)
      cSql += "       ZS3_MENU," + chr(13)
      cSql += "       ZS3_PROG," + chr(13)
      cSql += "       ZS3_ANAL," + chr(13)
      cSql += "       ZS3_ABAS," + chr(13)
      cSql += "       ZS3_PROD," + chr(13)
      cSql += "       CAST( CAST(ZS3_NOTA AS VARBINARY(1024)) AS VARCHAR(1024)) AS NOTA" + chr(13)
      cSql += "  FROM " + RetSqlName("ZS3") + chr(13)
      cSql += " WHERE ZS3_CODI = '" + Alltrim(cCodigo) + "'"
   
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ACESSOS", .T., .T. )

      cEmail := "Prezado(a) " + Alltrim(T_ACESSOS->ZS3_SOLI) + chr(13) + chr(10) + chr(13) + chr(10)
      
      cEmail += "Informamos que sua solicitação de Liberação de Acesso ao Menu do Sistema Protheus foi liberada em produção." + chr(13) + chr(10)
      cEmail += "Favor informar ao usuário beneficiado desta liberação."                                                      + chr(13) + chr(10) + chr(13) + chr(10)
      cEmail += "Dados da solicitação:" + chr(13) + chr(10) + chr(13) + chr(10)

      cEmail += "Código Solicitação.: "  + Alltrim(T_ACESSOS->ZS3_CODI)        + chr(13) + chr(10)
      cEmail += "Data Solicitação...: "  + Substr(T_ACESSOS->ZS3_DATA,07,02) + "/" + Substr(T_ACESSOS->ZS3_DATA,05,02) + "/" + Substr(T_ACESSOS->ZS3_DATA,01,04) + chr(13) + chr(10)
      cEmail += "Hora Solicitação...: "  + T_ACESSOS->ZS3_HORA  + chr(13) + chr(10)
      cEmail += "Beneficiado........: "  + T_ACESSOS->ZS3_BENE  + chr(13) + chr(10)

      Do Case
         Case Alltrim(T_ACESSOS->ZS3_MODU) == "ATF"
              cEmail += "Módulo.............: ATF - Ativo" + chr(13) + chr(10)
         Case Alltrim(T_ACESSOS->ZS3_MODU) == "COM"
              cEmail += "Módulo.............: COM - Compras" + chr(13) + chr(10)
         Case Alltrim(T_ACESSOS->ZS3_MODU) == "EST"
              cEmail += "Módulo.............: EST - Estoque" + chr(13) + chr(10)
         Case Alltrim(T_ACESSOS->ZS3_MODU) == "FAT"
              cEmail += "Módulo.............: FAT - Faturamento" + chr(13) + chr(10)
         Case Alltrim(T_ACESSOS->ZS3_MODU) == "FIN"
              cEmail += "Módulo.............: FIN - Financeiro" + chr(13) + chr(10)
         Case Alltrim(T_ACESSOS->ZS3_MODU) == "FIS"
              cEmail += "Módulo.............: FIS - Livros Fiscais" + chr(13) + chr(10)
         Case Alltrim(T_ACESSOS->ZS3_MODU) == "TMK"
              cEmail += "Módulo.............: TMK - Call Center" + chr(13) + chr(10)
         Case Alltrim(T_ACESSOS->ZS3_MODU) == "TEC"
              cEmail += "Módulo.............: TEC - Field Service" + chr(13) + chr(10)
         Case Alltrim(T_ACESSOS->ZS3_MODU) == "CTB"
              cEmail += "Módulo.............: CTB - Contabilidade Gerencial" + chr(13) + chr(10)
         Case Alltrim(T_ACESSOS->ZS3_MODU) == "CGT"
              cEmail += "Módulo.............: GCT - Contrato" + chr(13) + chr(10)
      EndCase
      
      If !Empty(Alltrim(T_ACESSOS->ZS3_MENU))      
         cEmail += "Menu...............: " + Alltrim(T_ACESSOS->ZS3_MENU)      + chr(13) + chr(10)
      Endif
      
      If !Empty(Alltrim(T_ACESSOS->ZS3_PROG))
         cEmail += "Programa...........: " + Alltrim(T_ACESSOS->ZS3_PROG)      + chr(13) + chr(10)
      Endif
         
      If T_ACESSOS->ZS3_ABAS <> 0
         cEmail += "Nº de Abas.........: " + Str(T_ACESSOS->ZS3_ABAS)              + chr(13) + chr(10)
      Endif   

      cEmail += "Motivo da Liberação: "  + chr(13) + chr(10)
      cEmail += Alltrim(T_ACESSOS->NOTA) + chr(13) + chr(10) + chr(13) + chr(10)
      cEmail += "Att." + chr(13)         + chr(13) + chr(10)
      cEmail += Alltrim(cUserName)       + chr(13) + chr(10)

      // Pesquisa o e-mail do Solicitante para envio
      If Select("T_USUARIOS") > 0
         T_USUARIOS->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.ZZA_CODI, "
      cSql += "       A.ZZA_NOME, "
      cSql += "       A.ZZA_EMAI  "
      cSql += "  FROM " + RetSqlName("ZZA")  + " A "
      cSql += " WHERE UPPER(A.ZZA_NOME) = '" + UPPER(Alltrim(T_ACESSOS->ZS3_SOLI)) + "'"
      cSql += "   AND A.D_E_L_E_T_      = ''"
      cSql += " ORDER BY A.ZZA_NOME "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_USUARIOS", .T., .T. )

      If T_USUARIOS->( EOF() )
         c_email := ""
      Else
         c_email := T_USUARIOS->ZZA_EMAI
      Endif

      // Envia e-mail ao Aprovador
      If Empty(c_email)
      Else   
         U_AUTOMR20(cEmail ,c_email, "", "Aviso de Liberação de Acesso de Menu Sistema Protheus em produção." )
      Endif

   Endif
   
   oDlgL:End() 

   CarregaAprovacao()

Return .T.      

// Função que carrega o grid de solicitação de acessos do usuário solicitante selecionado
Static Function CarregaAprovacao()

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
   cSql += " WHERE ZS3_STAT IN('4')"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ACESSOS", .T., .T. )

   If T_ACESSOS->( EOF() )
      aAdd( aBrowse, { "1", "", "", "", "", ""} )
   Else
      T_ACESSOS->( DbGoTop() )
      WHILE !T_ACESSOS->( EOF() )

         cLegenda = '2'
                          
         aAdd( aBrowse, { cLegenda           ,;
                          T_ACESSOS->ZS3_CODI,;
                          ALLTRIM(UPPER(T_ACESSOS->ZS3_SOLI)),;
                          ALLTRIM(UPPER(T_ACESSOS->ZS3_BENE)),;
                          Substr(T_ACESSOS->ZS3_DATA,07,02) + "/" + Substr(T_ACESSOS->ZS3_DATA,05,02) + "/" + Substr(T_ACESSOS->ZS3_DATA,01,04),;
                          T_ACESSOS->ZS3_MENU })
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
                         aBrowse[oBrowse:nAt,06]               }}

Return(.T.)