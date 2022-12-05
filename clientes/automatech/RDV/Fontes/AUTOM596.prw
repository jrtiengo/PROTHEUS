#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"                      
#INCLUDE "jpeg.ch" 

// ###################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            ##
// -------------------------------------------------------------------------------- ##
// Referencia: AUTOM596.PRW                                                         ##
// Parâmetros: Nenhum                                                               ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                              ##
// Data......: 07/08/2017                                                           ##
// Objetivo..: Manutenção Cadastro de Solicitantes de RDV                           ##
// ###################################################################################

User Function AUTOM596()

   Local cMemo1	 := ""
   Local oMemo1

   Private oDlg

   Private aBrowse := {}

   // #########################################################################
   // Função que carrega o grid com dados do cadastro de Solicitantes de RDV ##
   // #########################################################################
   CarregaZSB(0)

   DEFINE MSDIALOG oDlg TITLE "Cadastro de Solicitante RDV" FROM C(178),C(181) TO C(506),C(710) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(257),C(001) PIXEL OF oDlg

   @ C(147),C(005) Button "Incluir" Size C(037),C(012) PIXEL OF oDlg
   @ C(147),C(043) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg
   @ C(147),C(081) Button "Excluir" Size C(037),C(012) PIXEL OF oDlg
   @ C(147),C(223) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   oBrowse := TCBrowse():New( 050 , 005, 326, 133,,{'Código', 'Nome dos Solicitantes'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ##################################################
// Função que carrega o grid com dados do cadastro ##
// ##################################################
Static Function CarregaZSB(kTipo)

   Local cSql := ""
   
   aBrowse := {}
   
   If Select("T_SOLICITANTE") > 0
      T_SOLICITANTE->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZSB_CODI,"
   cSql += "       ZSB_NOME "
   cSql += "  FROM " + RetSqlName("ZSB")
   cSql += " WHERE ZSB_DELE = ''"
   cSql += " ORDER BY ZSB_NOME"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SOLICITANTE", .T., .T. )
   
   T_SOLICITANTE->( DbGoTop() )
   
   WHILE !T_SOLICITANTE->( EOF() )
      aAdd( aBrowse, { T_SOLICITANTE->ZSB_CODI, T_SOLICITANTE->ZSB_NOME })
      T_SOLICITANTE->( DbSkip() )
   ENDDO

   If Len(aBrowse) == 0
      aAdd( aBrowse, { "", "" })
   Endif   
   
   If kTipo == 0
      Return(.T.)
   Endif
   
   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02]}}

Return(.T.)      

// #########################################################################
// Função que abre janela de manutenção do cadastro de Solicitante de RDV ##
// #########################################################################
Static Function ManSolcitante(kOperacao, kCodigo)

   Local lChumba := .F.
   Local cSql    := ""

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private cCodigo  := Space(06)
   Private cNome	:= Space(40)
   Private cDetalhe := ""
   
   Private oGet1
   Private oGet2
   Private oMemo3

   Private oDlgP

   If kOperacao == "I"
   Else
   
      If Select("T_PROJETO") > 0
         T_PROJETO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZSD_CODI,"
      cSql += "       ZSD_NOME,"
	  cSql += "       CAST(CAST(ZSD_OBSE AS VARBINARY(1024)) AS VARCHAR(1024)) AS DETALHE"
      cSql += "  FROM " + RetSqlName("ZSD")
      cSql += " WHERE ZSD_CODI = '" + Alltrim(kCodigo) + "'"
      cSql += "   AND ZSD_DELE = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROJETO", .T., .T. )
                       
      If T_PROJETO->( EOF() )

         MsgAlert("Projeto inexistente. Verifique!")
         Return(.T.)

      Else

         cCodigo  := T_PROJETO->ZSD_CODI
         cNome    := T_PROJETO->ZSD_NOME
         cDetalhe := T_PROJETO->DETALHE
         
      Endif
      
   Endif

   DEFINE MSDIALOG oDlgP TITLE "Cadastro de Projetos" FROM C(178),C(181) TO C(477),C(629) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoautoma.bmp" Size C(135),C(022) PIXEL NOBORDER OF oDlgP

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(216),C(001) PIXEL OF oDlgP
   @ C(127),C(002) GET oMemo2 Var cMemo2 MEMO Size C(216),C(001) PIXEL OF oDlgP
   
   @ C(033),C(005) Say "Código"                         Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(033),C(037) Say "Descrição do Projeto"           Size C(052),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   @ C(054),C(005) Say "Descrição Detalhada do Projeto" Size C(078),C(008) COLOR CLR_BLACK PIXEL OF oDlgP
   
   @ C(042),C(005) MsGet oGet1  Var cCodigo       Size C(026),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP When lChumba
   @ C(042),C(037) MsGet oGet2  Var cNome         Size C(182),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgP When IIF(kOperacao == "E", .F.,.T.)
   @ C(063),C(005) GET   oMemo3 Var cDetalhe MEMO Size C(215),C(061)                              PIXEL OF oDlgP When IIF(kOperacao == "E", .F.,.T.)

   @ C(133),C(073) Button IIF(kOperacao == "E", "Exclui", "Salvar") Size C(037),C(012) PIXEL OF oDlgP ACTION( SalvaProjeto( kOperacao) )
   @ C(133),C(111) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgP ACTION( oDlgP:End() )

   ACTIVATE MSDIALOG oDlgP CENTERED 

Return(.T.)


// #########################################################################
// Função que abre janela de manutenção do cadastro de Solicitante de RDV ##
// #########################################################################
Static Function ManSolcitante(kOperacao, kCodigo)

   Local aComboBx1	 := {"Item01","Item02"}
   Local aComboBx2	 := {"Item01","Item02"}
   Local aComboBx3	 := {"Item01","Item02"}
   Local cComboBx1
   Local cComboBx2
   Local cComboBx3
   Local cGet1	 := Space(25)
   Local cGet16	 := Space(25)
   Local cGet17	 := Space(25)
   Local cGet2	 := Space(25)
   Local cGet3	 := Space(25)
   Local cGet4	 := Space(25)
   Local cGet5	 := Space(25)
   Local cGet6	 := Space(25)
   Local cGet7	 := Space(25)
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local cMemo3	 := ""
   Local oGet1
   Local oGet16
   Local oGet17
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5
   Local oGet6
   Local oGet7
   Local oMemo1
   Local oMemo2
   Local oMemo3

   Private oDlgSOL

   DEFINE MSDIALOG oDlgSOL TITLE "Cadastro de Solicitantes" FROM C(178),C(181) TO C(638),C(553) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(179),C(001) PIXEL OF oDlg

   @ C(037),C(005) Say "Código"                       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(047) Say "Cod.Usr.Protheus"             Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(059),C(005) Say "Nome Solicitante"             Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(081),C(005) Say "CPF"                          Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(081),C(096) Say "DDD"                          Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(081),C(122) Say "Celular"                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(104),C(005) Say "Gestor"                       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(126),C(005) Say "Centro de Custo"              Size C(042),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(148),C(005) Say "E-Mail"                       Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(170),C(005) Say "Dados para Depósito Bancário" Size C(075),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(183),C(005) Say "Banco"                        Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(183),C(086) Say "Conta"                        Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(183),C(121) Say "Agência"                      Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(046),C(005) MsGet    oGet1     Var   cGet1       Size C(032),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(046),C(047) MsGet    oGet3     Var   cGet3       Size C(041),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(069),C(005) MsGet    oGet2     Var   cGet2       Size C(177),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(091),C(005) MsGet    oGet17    Var   cGet17      Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(091),C(096) MsGet    oGet4     Var   cGet4       Size C(019),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(091),C(122) MsGet    oGet5     Var   cGet5       Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(113),C(005) ComboBox cComboBx1 Items aComboBx1   Size C(178),C(010)                              PIXEL OF oDlg
   @ C(136),C(005) ComboBox cComboBx2 Items aComboBx2   Size C(178),C(010)                              PIXEL OF oDlg
   @ C(157),C(005) MsGet    oGet16    Var   cGet16      Size C(177),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(179),C(005) GET      oMemo2    Var   cMemo2 MEMO Size C(176),C(001)                              PIXEL OF oDlg
   @ C(193),C(005) ComboBox cComboBx3 Items aComboBx3   Size C(078),C(010)                              PIXEL OF oDlg
   @ C(193),C(086) MsGet    oGet6     Var   cGet6       Size C(031),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(193),C(121) MsGet    oGet7     Var   cGet7       Size C(060),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(208),C(002) GET      oMemo3    Var   cMemo3 MEMO Size C(179),C(001)                              PIXEL OF oDlg

   @ C(213),C(054) Button "Salvar" Size C(037),C(012) PIXEL OF oDlg
   @ C(213),C(092) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg

   ACTIVATE MSDIALOG oDlg CENTERED 





// ################################################
// Função que salva as informações na tabela ZSD ##
// ################################################
Static Function SalvaProjeto(kOperacao)

   If kOperacao == "E"
      If MsgYesNo("Deseja realmente excluir este registro?")
      Else
         Return(.T.)
      Endif
   Else
      If Empty(Alltrim(cNome))
         MsgAlert("Nome do Projeto não informado.")
         Return(.T.)
      Endif
   Endif    

   // ###########
   // Inclusão ##
   // ###########
   If kOperacao == "I"

      // ##########################################
      // Pesquisa o próximo código para inclusão ##
      // ##########################################
      If Select("T_PROXIMO") > 0
         T_PROXIMO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT MAX(ZSD_CODI) AS PROXIMO FROM " + RetSqlName("ZSD")

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

      IF T_PROXIMO->( EOF() )
         xCodigo := "000001"
      Else
         xCodigo := Strzero(INT(VAL(T_PROXIMO->PROXIMO)) + 1,6)
      Endif   

      dbSelectArea("ZSD")
      RecLock("ZSD",.T.)
      ZSD->ZSD_FILIAL := cFilAnt
      ZSD->ZSD_CODI   := xCodigo
      ZSD->ZSD_NOME   := cNome
      ZSD->ZSD_OBSE   := cDetalhe
      ZSD->ZSD_DELE   := ""
      MsUnLock()
   Endif
      
   // ############
   // Alteração ##
   // ############
   If kOperacao == "A"
      dbSelectArea("ZSD")
      DbSetOrder(1)
      If DbSeek(cFilAnt + cCodigo)
         RecLock("ZSD",.F.)
         ZSD->ZSD_NOME := cNome
         ZSD->ZSD_OBSE := cDetalhe
         MsUnLock()
      Endif
   Endif
      
   // ###########
   // Exclusão ##
   // ###########
   If kOperacao == "E"
      dbSelectArea("ZSD")
      DbSetOrder(1)
      If DbSeek(cFilAnt + cCodigo)
         RecLock("ZSD",.F.)
         ZSD->ZSD_DELE := "X"
         MsUnLock()
      Endif
   Endif

   // #########################################
   // Fecha a tela de manutenção do cadastro ##
   // #########################################
   oDlgP:End()

   // ####################################
   // Atualiza o gris com as alterações ##
   // ####################################
   CarregaZSD(1)
   
Return(.T.)   