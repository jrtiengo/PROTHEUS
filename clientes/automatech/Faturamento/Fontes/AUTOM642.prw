#INCLUDE "PROTHEUS.CH"
#INCLUDE "jpeg.ch" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM642.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 19/10/2012                                                          ##
// Objetivo..: Programa do Parametrizador Customizável - Parte II                  ##
// ################################################################################## 

User Function AUTOM642()

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private oDlgII

// U_AUTOM628("AUTOM642")
   
   // ##############################################
   // Desenha a tela do parametrizador Automatech ##
   // ##############################################
   DEFINE MSDIALOG oDlgII TITLE "Parâmetros Customizados" FROM C(178),C(181) TO C(590),C(1143) PIXEL

   @ C(005),C(005) Jpeg FILE "nlogoautoma.bmp" Size C(145),C(040) PIXEL NOBORDER OF oDlgII
   @ C(043),C(002) GET oMemo1 Var cMemo1 MEMO Size C(500),C(001) PIXEL OF oDlgII

   @ C(046),C(002) Button "Histórico de Produtos "               Size C(095),C(012) PIXEL OF oDlgII ACTION( AcsHstPrd() )
   @ C(046),C(098) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII 
   @ C(046),C(194) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(046),C(290) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(046),C(386) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(060),C(002) Button "Etiqueta GKN"                         Size C(095),C(012) PIXEL OF oDlgII ACTION( SeqGKN() )
   @ C(060),C(098) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(060),C(194) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(060),C(290) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(060),C(386) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(073),C(002) Button "Cond.Pgtº SimFrete"                   Size C(095),C(012) PIXEL OF oDlgII ACTION( CndPgtSFrete() )
   @ C(073),C(098) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(073),C(194) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(073),C(290) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(073),C(386) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(087),C(002) Button "Cotação SIMFRETE"                     Size C(095),C(012) PIXEL OF oDlgII ACTION( CotacaoSFrete() )
   @ C(087),C(098) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(087),C(194) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(087),C(290) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(087),C(386) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(100),C(002) Button "Fechamento Fin/Fiscal"                Size C(095),C(012) PIXEL OF oDlgII ACTION( FechaMvto() )
   @ C(100),C(098) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(100),C(194) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(100),C(290) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(100),C(386) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(114),C(002) Button "TES Direto Faturamento"               Size C(095),C(012) PIXEL OF oDlgII ACTION( TESFATURAMENTO() )
   @ C(114),C(098) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(114),C(194) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(114),C(290) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(114),C(386) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(127),C(002) Button "Taxa Reprovação OS"                   Size C(095),C(012) PIXEL OF oDlgII ACTION( TAXAREPROVA() )
   @ C(127),C(098) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(127),C(194) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(127),C(290) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(127),C(386) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(141),C(002) Button "TES Transf. Entre Filiais"            Size C(095),C(012) PIXEL OF oDlgII ACTION( TTRANSFERE() )
   @ C(141),C(098) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(141),C(194) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(141),C(290) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(141),C(386) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(154),C(002) Button "Alteração Vctº Boletos"               Size C(095),C(012) PIXEL OF oDlgII ACTION( AltBoleto() )
   @ C(154),C(098) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(154),C(194) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(154),C(290) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(154),C(386) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(167),C(002) Button "Banco X Tipo X Ocorrência"            Size C(095),C(012) PIXEL OF oDlgII ACTION( BcoTipOcor() )
   @ C(167),C(098) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(167),C(194) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(167),C(290) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(167),C(386) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(180),C(002) Button "Alteração Hora Emissão NFE"           Size C(095),C(012) PIXEL OF oDlgII ACTION( HoraNFEntrada() )
   @ C(180),C(098) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(180),C(194) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(180),C(290) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(180),C(386) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(193),C(002) Button "Alteração Vendedor Cad.Cliente"       Size C(095),C(012) PIXEL OF oDlgII ACTION( GrupoVendCli() )
   @ C(193),C(098) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(193),C(194) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(193),C(290) Button "Disponível"                           Size C(095),C(012) PIXEL OF oDlgII
   @ C(193),C(386) Button "Voltar"                               Size C(095),C(012) PIXEL OF oDlgII ACTION( oDlgII:End() )

   ACTIVATE MSDIALOG oDlgII CENTERED

Return(.T.)

// #################################################################################################################
// Função que abre a tela para inclusão dos c´pdigos de usuários com permissão de acesso ao Histórico de Produtos ##
// #################################################################################################################
Static Function AcsHstPrd()

   Local cMemo1	  := ""
   Local oMemo1

   Local cUsuHist := Space(254)
   Local oGet1

   Private oDlgGRP

   // ###################################
   // Pesquisa os valores para display ##
   // ###################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_AHIS FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   cUsuHist := IIF(T_PARAMETROS->( EOF() ), Space(254), T_PARAMETROS->ZZ4_AHIS)

   DEFINE MSDIALOG oDlgGRP TITLE "Acesso Histório de Produtos" FROM C(178),C(181) TO C(346),C(631) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(113),C(022) PIXEL NOBORDER OF oDlgGRP

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(217),C(001) PIXEL OF oDlgGRP

   @ C(033),C(005) Say "Informe abaixo os códigos dos usuários, concatenados por |, que poderão ter acesso ao Hsitórico de Produto" Size C(215),C(008) COLOR CLR_BLACK PIXEL OF oDlgGRP
   @ C(042),C(005) Say "pela pesquisa customizada de produtos."                                                                     Size C(117),C(008) COLOR CLR_BLACK PIXEL OF oDlgGRP

   @ C(052),C(005) MsGet oGet1 Var cUsuHist Size C(215),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgGRP

   @ C(067),C(094) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgGRP ACTION( SlvUsuHist(cUsuHist) )

   ACTIVATE MSDIALOG oDlgGRP CENTERED 

Return(.T.)

// ################################################################################
// Função que grava os usuários com permissão de acesso ao Histórico de Produtos ##
// ################################################################################
Static Function SlvUsuHist(cUsuHist)

   Local cSql    := ""
   
   // ##########################################################################################
   // Verifica se existe algum registro na Tabela ZZ4010. Se não existir, inclui senão altera ##
   // ##########################################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL "
   cSql += "  FROM " + RetSqlName("ZZ4") 
   cSql += " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
   Else
      RecLock("ZZ4",.F.)   
   Endif

   ZZ4->ZZ4_AHIS := cUsuHist
   MsUnLock()

   oDlgGRP:End()
   
Return(.T.)

// #####################################################################################
// Função que abre a tela para inclusão do sequenciador da geração da etiqueta da GKN ##
// #####################################################################################
Static Function SeqGKN()

   Local cSql    := ""
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private cSequenciador := 0
   Private cSubContrato  := ""
   Private oGet1
   Private oGet2

   Private oDlg

   // ###################################
   // Pesquisa os valores para display ##
   // ###################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_SGKN, ZZ4_XCON FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   cSubContrato  := IIF(T_PARAMETROS->( EOF() ), Space(10), T_PARAMETROS->ZZ4_XCON)
   cSequenciador := IIF(T_PARAMETROS->( EOF() ), 0        , T_PARAMETROS->ZZ4_SGKN)

   DEFINE MSDIALOG oDlg TITLE "Parâmetros Etiqueta GKN" FROM C(178),C(181) TO C(384),C(423) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.Bmp" Size C(114),C(022) PIXEL NOBORDER OF oDlg

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(115),C(001) PIXEL OF oDlg
   @ C(079),C(002) GET oMemo2 Var cMemo2 MEMO Size C(115),C(001) PIXEL OF oDlg
   
   @ C(033),C(005) Say "Nº do Subcontrato"                 Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(055),C(005) Say "Sequenciador gerador Etiqueta GKN" Size C(090),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(042),C(005) MsGet oGet1 Var cSubContrato  Size C(044),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(065),C(005) MsGet oGet2 Var cSequenciador Size C(044),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(086),C(042) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( SlvSeqGKN() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ################################################################
// Função que grava o sequenciador da emissão da etiqueta da GKN ##
// ################################################################
Static Function SlvSeqGKN()

   Local cSql    := ""
   
   // ##########################################################################################
   // Verifica se existe algum registro na Tabela ZZ4010. Se não existir, inclui senão altera ##
   // ##########################################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL "
   cSql += "  FROM " + RetSqlName("ZZ4") 
   cSql += " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
   Else
      RecLock("ZZ4",.F.)   
   Endif

   ZZ4->ZZ4_XCON := cSubContrato
   ZZ4->ZZ4_SGKN := cSequenciador
   MsUnLock()

   oDlg:End()
   
Return(.T.)

// ################################################################
// Função que habilita parâmetros condição de pagamento SimFrete ##
// ################################################################
Static Function CndPgtSFrete()

   Local cSql    := ""

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private lValidar  := .T.
   Private lSabado   := .T.
   Private lDomingo  := .T.
   Private kDias	   := 0
   Private kNacional := Space(250)
   Private kRegional := Space(250)
   Private kUsuarios := Space(250)

   Private oCheckBox1
   Private oCheckBox2
   Private oCheckBox3
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4

   Private oDlg

   // ###################################
   // Pesquisa os valores para display ##
   // ###################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_VCSF,"
   cSql += "       ZZ4_DSAB,"
   cSql += "       ZZ4_DDOM,"
   cSql += "       ZZ4_SDIA,"
   cSql += "       ZZ4_FNAC,"
   cSql += "       ZZ4_FREG,"
   cSql += "       ZZ4_VUSU "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   lValidar  := IIF(T_PARAMETROS->ZZ4_VCSF == "S", .T., .F.)
   lSabado   := IIF(T_PARAMETROS->ZZ4_DSAB == "S", .T., .F.)
   lDomingo  := IIF(T_PARAMETROS->ZZ4_DSAB == "S", .T., .F.)
   kDias     := T_PARAMETROS->ZZ4_SDIA
   kNacional := T_PARAMETROS->ZZ4_FNAC
   kRegional := T_PARAMETROS->ZZ4_FREG
   kUsuarios := T_PARAMETROS->ZZ4_VUSU

   DEFINE MSDIALOG oDlg TITLE "Validação Condição de Pagamento Pedido de Venda X SimFrete" FROM C(178),C(181) TO C(547),C(671) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlg

   @ C(074),C(005) Say "Qtd dias a serem considerados para cálculo de vencimento SimFrete"         Size C(164),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(096),C(005) Say "Feriados Nacionais/Mundiais ( Exemplo preechimento: 01/01#25/12#)"         Size C(169),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(118),C(005) Say "Feriados Municipais/Regionais (Exemplo preenchimento: 02/02#14/03#)"       Size C(176),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(140),C(005) Say "Não abrir esta validação para os usuários (Informar login separado por |)" Size C(171),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(238),C(001) PIXEL OF oDlg
   @ C(164),C(002) GET oMemo2 Var cMemo2 MEMO Size C(238),C(001) PIXEL OF oDlg
  
   @ C(038),C(005) CheckBox oCheckBox1 Var lValidar  Prompt "Validar Condição de Pagamento Pedido de Venda X Simfrete" Size C(155),C(008) PIXEL OF oDlg
   @ C(050),C(005) CheckBox oCheckBox2 Var lSabado   Prompt "Considerar Sábado para cálculo de vencimento"             Size C(124),C(008) PIXEL OF oDlg
   @ C(061),C(005) CheckBox oCheckBox3 Var lDomingo  Prompt "Considerar Domingo para cálculo de vencimento"            Size C(127),C(008) PIXEL OF oDlg
   @ C(083),C(005) MsGet    oGet1      Var kDias                                                                       Size C(014),C(009) COLOR CLR_BLACK Picture "@E 99" PIXEL OF oDlg
   @ C(105),C(005) MsGet    oGet2      Var kNacional                                                                   Size C(235),C(009) COLOR CLR_BLACK Picture "@!"    PIXEL OF oDlg
   @ C(127),C(005) MsGet    oGet3      Var kRegional                                                                   Size C(235),C(009) COLOR CLR_BLACK Picture "@!"    PIXEL OF oDlg
   @ C(149),C(005) MsGet    oGet4      Var kUsuarios                                                                   Size C(235),C(009) COLOR CLR_BLACK Picture "@!"    PIXEL OF oDlg

   @ C(168),C(102) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( SlvCndPgtoSFrete() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ################################################################
// Função que grava o sequenciador da emissão da etiqueta da GKN ##
// ################################################################
Static Function SlvCndPgtoSFrete()

   Local cSql    := ""
   
   // ##########################################################################################
   // Verifica se existe algum registro na Tabela ZZ4010. Se não existir, inclui senão altera ##
   // ##########################################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL "
   cSql += "  FROM " + RetSqlName("ZZ4") 
   cSql += " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
   Else
      RecLock("ZZ4",.F.)   
   Endif

   ZZ4->ZZ4_VCSF := IIF(lValidar == .T., "S", "N")
   ZZ4->ZZ4_DSAB := IIF(lSabado  == .T., "S", "N")
   ZZ4->ZZ4_DDOM := IIF(lDomingo == .T., "S", "N")
   ZZ4->ZZ4_SDIA := kDias
   ZZ4->ZZ4_FNAC := kNacional
   ZZ4->ZZ4_FREG := kRegional
   ZZ4->ZZ4_VUSU := kUsuarios

   MsUnLock()

   oDlg:End()
   
Return(.T.)

// ##########################################################################################
// Função que abre janela para indicar usuários que não precisam realizar cotação SimFrete ##
// ##########################################################################################
Static Function CotacaoSFrete()

   Local cMemo1	 := ""
   Local oMemo1
   
   Private cCotacaoSF := Space(250)
   Private oGet1

   Private oDlg

   // ###################################
   // Pesquisa os valores para display ##
   // ###################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_UCOT FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   cCotacaoSF := T_PARAMETROS->ZZ4_UCOT

   DEFINE MSDIALOG oDlg TITLE "Cotação SimFrete" FROM C(178),C(181) TO C(351),C(679) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(243),C(001) PIXEL OF oDlg

   @ C(037),C(005) Say "Informe o login dos usuários que não precisam realizar cotação de frete pelo Simfrete." Size C(209),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(045),C(005) Say "Separar o login por |"                                                                  Size C(051),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(054),C(005) MsGet oGet1 Var cCotacaoSF Size C(239),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(069),C(106) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( SlvCotSF() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #####################################################################
// Função que salva o parâmetros de usuários para cotação do SimFrete ##
// #####################################################################
Static Function SlvCotSF()

   Local cSql    := ""
   
   // ##########################################################################################
   // Verifica se existe algum registro na Tabela ZZ4010. Se não existir, inclui senão altera ##
   // ##########################################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL "
   cSql += "  FROM " + RetSqlName("ZZ4") 
   cSql += " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
   Else
      RecLock("ZZ4",.F.)   
   Endif

   ZZ4->ZZ4_UCOT := cCotacaoSF

   MsUnLock()

   oDlg:End()
   
Return(.T.)

// ####################################################################################################################################
// Função que abre janela para indicar os usuários que terão acesso aos programas de fechamento de movimentos financeiros e fisicais ##
// ####################################################################################################################################
Static Function FechaMvto()

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private xFinanceiro := Space(250)
   Private xFiscal     := Space(250)

   Private oGet1
   Private oGet2

   Private oDlg

   // ###################################
   // Pesquisa os valores para display ##
   // ###################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_XFIN, ZZ4_XFIS FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   xFinanceiro := IIF(Empty(Alltrim(T_PARAMETROS->ZZ4_XFIN)), Space(250), T_PARAMETROS->ZZ4_XFIN)
   xFiscal     := IIF(Empty(Alltrim(T_PARAMETROS->ZZ4_XFIS)), Space(250), T_PARAMETROS->ZZ4_XFIS)

   DEFINE MSDIALOG oDlg TITLE "Autorização de Acesso (Fechamento Financeiro e Fiscal)" FROM C(178),C(181) TO C(379),C(708) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(106),C(022) PIXEL NOBORDER OF oDlg

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(258),C(001) PIXEL OF oDlg
   @ C(080),C(002) GET oMemo2 Var cMemo2 MEMO Size C(258),C(001) PIXEL OF oDlg

   @ C(032),C(005) Say "Usuários com permissão de acesso ao programa Fechamento Movimentos Financeiros" Size C(205),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(054),C(005) Say "Usuários com permissão de acesso ao programa Fechamento Movimentos Fiscais"     Size C(205),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(087),C(005) Say "Separar os logins com #"                                                        Size C(061),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(041),C(005) MsGet oGet1 Var xFinanceiro Size C(255),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(063),C(005) MsGet oGet2 Var xFiscal     Size C(255),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(084),C(113) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( SlvFecha() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #########################################################################################################
// Função que salva os parâmetros de acessos a usuários para fechamento de momentos financeiros e fiscais ##
// #########################################################################################################
Static Function SlvFecha()

   Local cSql    := ""
   
   // ##########################################################################################
   // Verifica se existe algum registro na Tabela ZZ4010. Se não existir, inclui senão altera ##
   // ##########################################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL "
   cSql += "  FROM " + RetSqlName("ZZ4") 
   cSql += " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
   Else
      RecLock("ZZ4",.F.)   
   Endif

   ZZ4->ZZ4_XFIN := xFinanceiro
   ZZ4->ZZ4_XFIS := xFiscal

   MsUnLock()

   oDlg:End()
   
Return(.T.)

// ###########################################################################################################
// Função que abre janela para receber as TES que vão diretamente para o Status 10 - Aguardando Faturamento ##
// ###########################################################################################################
Static Function TESFATURAMENTO()

   Local cMemo1	 := ""
   Local oMemo1

   Private xTESfat := Space(250)
   Private oGet1

   Private oDlg

   // ###################################
   // Pesquisa os valores para display ##
   // ###################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_TFAT FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   xTESFat := IIF(Empty(Alltrim(T_PARAMETROS->ZZ4_TFAT)), Space(250), T_PARAMETROS->ZZ4_TFAT)

   DEFINE MSDIALOG oDlg TITLE "TES direto para Faturamento" FROM C(178),C(181) TO C(354),C(859) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(333),C(001) PIXEL OF oDlg

   @ C(037),C(005) Say "Informe abaixo a(s) TES(s) quando utilizadas em Pedidos de Venda, estes já serão atualizados com o Status 10 - Aguardando Faturamento " Size C(326),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(045),C(005) Say "Separar as TES com #"                                                                                                                   Size C(057),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(055),C(005) MsGet oGet1 Var xTESfat Size C(328),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(071),C(152) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( SlvTESfat() )
   
   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ####################################################################################
// Função que salva as TES que irão direto para o Status 10 - aguardando Faturamento ##
// ####################################################################################
Static Function SlvTESfat()

   Local cSql    := ""
   
   // ##########################################################################################
   // Verifica se existe algum registro na Tabela ZZ4010. Se não existir, inclui senão altera ##
   // ##########################################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL "
   cSql += "  FROM " + RetSqlName("ZZ4") 
   cSql += " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
   Else
      RecLock("ZZ4",.F.)   
   Endif

   ZZ4->ZZ4_TFAT := xTESfat

   MsUnLock()

   oDlg:End()
   
Return(.T.)

// ####################################################################################################
// Função que abre janela para parametrizar a taxa de reprovação de orçamennto de Ordens de Serviços ##
// ####################################################################################################
Static Function TAXAREPROVA()

   Local cMemo1	 := ""
   Local oMemo1
      
   Private lEditar := .F.
   Private cTaxa   := 0
   Private oGet1

   Private oDlg
 
   Private aLista := {}
   Private oLista
                     
   aAdd( aLista, { "01 - Automatech"  , "01 - Porto Alegre"  , 0 })
   aAdd( aLista, { "01 - Automatech"  , "02 - Caixas do Sul" , 0 })
   aAdd( aLista, { "01 - Automatech"  , "05 - São Paulo"     , 0 })
   aAdd( aLista, { "01 - Automatech"  , "06 - Espirito Santo", 0 })   
   aAdd( aLista, { "02 - TI Automação", "01 - Curitiba"      , 0 })   
   aAdd( aLista, { "03 - Atech"       , "01 - Porto Alegre"  , 0 })   
   aAdd( aLista, { "04 - AtelPel"     , "01 - Pelotas"       , 0 })         

   // ###################################
   // Pesquisa os valores para display ##
   // ###################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_TREP FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   For nContar = 1 to U_P_OCCURS(T_PARAMETROS->ZZ4_TREP, "#", 1)
       
       xSepara := U_P_CORTA(T_PARAMETROS->ZZ4_TREP, "#", nContar)
       
       For nProcura = 1 to Len(aLista)
           If Substr(aLista[nProcura,01],01,02) == U_P_CORTA(xSepara, "|", 1)
              If Substr(aLista[nProcura,02],01,02) == U_P_CORTA(xSepara, "|", 2)
                 aLista[nProcura,03] := Val(U_P_CORTA(xSepara, "|", 3))
                 Exit
              Endif
           Endif             	
      Next nContar           
      
   Next nContar

   If Len(aLista) == 0
      aAdd( aLista, { "", "", "" } )
   Endif   

   DEFINE MSDIALOG oDlg TITLE "Taxa de Reprovação de Orçamento AT" FROM C(178),C(181) TO C(531),C(614) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(150),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(209),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Valor da Taxa de Reprovação de Orçamento AT" Size C(116),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(154),C(048) Say "Taxa Reprovação"                             Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(164),C(048) MsGet oGet1 Var cTaxa Size C(045),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlg When lEditar
	
   @ C(160),C(005) Button "Alterar"  Size C(037),C(012) PIXEL OF oDlg ACTION( cTaxa := aLista[oLista:nAt,03], lEditar := .T. )
   @ C(160),C(100) Button "Confirma" Size C(037),C(012) PIXEL OF oDlg ACTION( SLVTAXA() )
   @ C(160),C(175) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( FECHATAXA() )

   @ 058,005 LISTBOX oLista FIELDS HEADER "Empresa"         ,; // 01
                                          "Filial"          ,; // 02
                                          "Taxa Reprovação"  ; // 03
                                          PIXEL SIZE 265,137 OF oDlg ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     
   oLista:SetArray( aLista )

   oLista:bLine := {|| {aLista[oLista:nAt,01],;
          			    aLista[oLista:nAt,02],;
          			    Transform(aLista[oLista:nAt,03], "@E 9999999.99")}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)
       
// ####################################
// Função que salva a taxa informada ##
// ####################################
Static Function SlvTaxa()

   Local nContar  := 0
   Local lTemTaxa := .F.
   
   aLista[oLista:nAt,03] := cTaxa

   oLista:SetArray( aLista )

   oLista:bLine := {|| {aLista[oLista:nAt,01],;
          			    aLista[oLista:nAt,02],;
          			    Transform(aLista[oLista:nAt,03], "@E 9999999.99")}}
   lEditar := .F.
 
   cTaxa := 0

Return(.T.)      
             
// ##################################################
// Função que grava o campo ZZ4_TREP na tabela ZZ4 ##
// ##################################################
Static Function FECHATAXA()

   Local cSql    := ""
   Local nContar := 0
   Local cString := ""

   cString := ""
   
   For nContar = 1 to Len(aLista)
       If Empty(Alltrim(aLista[nContar,01]))
          Loop
       Endif
       cString := cString + Substr(aLista[ncontar,01],01,02) + "|" + ;
                            Substr(aLista[nContar,02],01,02) + "|" + ;
                            Str(aLista[nContar,03],10,02)    + "|" + "#"
   Next nContar
  
   // ##########################################################################################
   // Verifica se existe algum registro na Tabela ZZ4010. Se não existir, inclui senão altera ##
   // ##########################################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL "
   cSql += "  FROM " + RetSqlName("ZZ4") 
   cSql += " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
   Else
      RecLock("ZZ4",.F.)   
   Endif

   ZZ4->ZZ4_TREP := cString

   MsUnLock()

   oDlg:End()
   
Return(.T.)

// #############################################################################
// Função que abre janela para receber as TES de Transferência de Mercadorias ##
// #############################################################################
Static Function TTRANSFERE()

   Local cMemo1	 := ""
   Local oMemo1

   Private xTESTra := Space(250)
   Private oGet1

   Private oDlg

   // ###################################
   // Pesquisa os valores para display ##
   // ###################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_TTRA FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   xTESTra := IIF(Empty(Alltrim(T_PARAMETROS->ZZ4_TTRA)), Space(250), T_PARAMETROS->ZZ4_TTRA)

   DEFINE MSDIALOG oDlg TITLE "TES Transferência de Mercadorias" FROM C(178),C(181) TO C(354),C(859) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp" Size C(126),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(333),C(001) PIXEL OF oDlg

   @ C(037),C(005) Say "Informe abaixo a(s) TES(s) utilizadas para Transferências de Mercadorias. Não permite Transferências p/Empresas Diferente." Size C(326),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(045),C(005) Say "Separar as TES com #"                                                                                                                   Size C(057),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(055),C(005) MsGet oGet1 Var xTESTra Size C(328),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(071),C(152) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( SlvTESTra() )
   
   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ############################################
// Função que salva as TES de transferências ##
// ############################################
Static Function SlvTESTra()

   Local cSql    := ""
   
   // ##########################################################################################
   // Verifica se existe algum registro na Tabela ZZ4010. Se não existir, inclui senão altera ##
   // ##########################################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL "
   cSql += "  FROM " + RetSqlName("ZZ4") 
   cSql += " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
   Else
      RecLock("ZZ4",.F.)   
   Endif

   ZZ4->ZZ4_TTRA := xTESTra

   MsUnLock()

   oDlg:End()
   
Return(.T.)

// ############################################
// Função que salva as TES de transferências ##
// ############################################
Static Function AltBoleto()

   Local cMemo1	   := ""
   Local cMemo2	   := ""

   Local oMemo1
   Local oMemo2

   Private cUsua01 := Space(250)
   Private cUsua02 := Space(250)

   Private oGet3
   Private oGet4

   Private oDlg

   // ###################################
   // Pesquisa os valores para display ##
   // ###################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_UVE1, ZZ4_UVE2 FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   cUsua01 := IIF(Empty(Alltrim(T_PARAMETROS->ZZ4_UVE1)), Space(250), T_PARAMETROS->ZZ4_UVE1)
   cUsua02 := IIF(Empty(Alltrim(T_PARAMETROS->ZZ4_UVE2)), Space(250), T_PARAMETROS->ZZ4_UVE2)

   DEFINE MSDIALOG oDlg TITLE "Permissão de Alteração de Vencimento em Boletos Bancários" FROM C(178),C(181) TO C(562),C(735) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(271),C(001) PIXEL OF oDlg
   @ C(068),C(002) GET oMemo2 Var cMemo2 MEMO Size C(271),C(001) PIXEL OF oDlg
   
   @ C(036),C(005) Say "Relação de usuáriso com permissão para alterar vencimentos de boletos bancários"     Size C(198),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(072),C(005) Say "Informar os parâmetros conforme orientação abaixo:"                                  Size C(122),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(083),C(018) Say "XXXXXXXXXX|T|5|#XXXXXXXXXX|A|7|# ..."                                                Size C(104),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(097),C(036) Say "XXXXXXXXXXXXXXXXXXXX = Login do Usuário"                                             Size C(118),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(105),C(036) Say "| = Utilizar | para separar parâmetros do usuário"                                   Size C(111),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(115),C(036) Say "T = Indica que o usuário poderá realizar antecipações e postergações de vencimentos" Size C(206),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(124),C(046) Say "A = Usuário somente poderá realizar Antecipações de Vencimentos"                     Size C(162),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(132),C(046) Say "P = Usuário somente poderá realizar Postergações de Vencimentos"                     Size C(161),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(141),C(046) Say "T = Indica que o usuário poderá realizar Antecipações/Postergações de Vencimentos"   Size C(205),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(151),C(036) Say "5 = Indica que o usuário poderá Antecipar ou Postergar o Vencimento em até 5 Dias"   Size C(204),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(162),C(036) Say "# = Indica o final da parametrização do usuário"                                     Size C(114),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(046),C(005) MsGet oGet3 Var cUsua01 Size C(267),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(055),C(005) MsGet oGet4 Var cUsua02 Size C(267),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(176),C(119) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( SalvaUsua() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ############################################
// Função que salva as TES de transferências ##
// ############################################
Static Function SalvaUsua()

   Local cSql    := ""
   
   // ##########################################################################################
   // Verifica se existe algum registro na Tabela ZZ4010. Se não existir, inclui senão altera ##
   // ##########################################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL "
   cSql += "  FROM " + RetSqlName("ZZ4") 
   cSql += " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
   Else
      RecLock("ZZ4",.F.)   
   Endif

   ZZ4->ZZ4_UVE1 := cUsua01
   ZZ4->ZZ4_UVE2 := cUsua02

   MsUnLock()

   oDlg:End()
   
Return(.T.)

// #################################################################
// Função que solicita os parâmetros de banco X Tipo X Ocorrencia ##
// #################################################################
Static Function BcoTipOcor()

   Local cMemo1	  := ""
   Local oMemo1
      
   Private cOcorr := Space(250)
   Private oGet1

   Private oDlg

   // ###################################
   // Pesquisa os valores para display ##
   // ###################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_BOCO FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   cOcorr := IIF(Empty(Alltrim(T_PARAMETROS->ZZ4_BOCO)), Space(250), T_PARAMETROS->ZZ4_BOCO)

   DEFINE MSDIALOG oDlg TITLE "Parâmetros Banaco X Ocorrências" FROM C(178),C(181) TO C(328),C(662) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(234),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Informe Banco - Tipo - Ocorrência para alteração de Vencimentos, Juros e Multa" Size C(192),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(045),C(005) MsGet oGet1 Var cOcorr Size C(231),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(058),C(083) Button "?"      Size C(037),C(012) PIXEL OF oDlg ACTION( MsgAlert("Em Desenvolvimento.") )
   @ C(058),C(121) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( SlvOcorr() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ##############################################################
// Função que salva os parâmetros de Banco X Tipo X Ocorrencia ##
// ##############################################################
Static Function SlvOcorr()

   Local cSql    := ""
   
   // ##########################################################################################
   // Verifica se existe algum registro na Tabela ZZ4010. Se não existir, inclui senão altera ##
   // ##########################################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL "
   cSql += "  FROM " + RetSqlName("ZZ4") 
   cSql += " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
   Else
      RecLock("ZZ4",.F.)   
   Endif

   ZZ4->ZZ4_BOCO := cOcorr

   MsUnLock()

   oDlg:End()
   
Return(.T.)

// ##################################################################################
// Função que solicita usuários que podem alterar hora em notas fiscais de entrada ##
// ##################################################################################
Static Function HoraNFEntrada()

   Local cMemo1	  := ""
   Local oMemo1
      
   Private cHora  := Space(250)
   Private oGet1

   Private oDlg

   // ###################################
   // Pesquisa os valores para display ##
   // ###################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_AHOR FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   cHora := IIF(Empty(Alltrim(T_PARAMETROS->ZZ4_AHOR)), Space(250), T_PARAMETROS->ZZ4_AHOR)

   DEFINE MSDIALOG oDlg TITLE "Parâmetros Hora Nota Fiscal de Entrada" FROM C(178),C(181) TO C(328),C(662) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(234),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Informe login de usuários com permissão para alterar Hora em Nota Fiscal de Entrada (Separar login com #)" Size C(250),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(045),C(005) MsGet oGet1 Var cHora Size C(231),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(058),C(083) Button "?"      Size C(037),C(012) PIXEL OF oDlg ACTION( MsgAlert("Em Desenvolvimento.") )
   @ C(058),C(121) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( SlvHora() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #####################################################################################################
// Função que salva os parâmetros de usuários com permissão de alterar hora da nota fiscal de entreda ##
// #####################################################################################################
Static Function SlvHora()

   Local cSql    := ""
   
   // ##########################################################################################
   // Verifica se existe algum registro na Tabela ZZ4010. Se não existir, inclui senão altera ##
   // ##########################################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL "
   cSql += "  FROM " + RetSqlName("ZZ4") 
   cSql += " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
   Else
      RecLock("ZZ4",.F.)   
   Endif

   ZZ4->ZZ4_AHOR := cHora

   MsUnLock()

   oDlg:End()
   
Return(.T.) 

// #######################################################################################################
// Função que solicita os id dos usuários que podem alterar o campo de vendedor no cadastro de clientes ##
// #######################################################################################################
Static Function GrupoVendCli()

   Local cMemo1	  := ""
   Local oMemo1
      
   Private cGrupoVend  := Space(250)
   Private oGet1

   Private oDlg

   // ###################################
   // Pesquisa os valores para display ##
   // ###################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_GVEN FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   cGrupoVend := IIF(Empty(Alltrim(T_PARAMETROS->ZZ4_GVEN)), Space(250), T_PARAMETROS->ZZ4_GVEN)

   DEFINE MSDIALOG oDlg TITLE "Parâmetros Usuários Alteração vendedor Cad.Cliente" FROM C(178),C(181) TO C(328),C(662) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(234),C(001) PIXEL OF oDlg

   @ C(036),C(005) Say "Informe ID dos Usuários que possuem autorização de alterar código vendedor Cad. Cliente. (Separar ID com #)" Size C(250),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(045),C(005) MsGet oGet1 Var cGrupoVend Size C(231),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(058),C(083) Button "?"      Size C(037),C(012) PIXEL OF oDlg ACTION( MsgAlert("Em Desenvolvimento.") )
   @ C(058),C(121) Button "Voltar" Size C(037),C(012) PIXEL OF oDlg ACTION( SlvGVend() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ##########################################################
// Função que salva os parâmetros da função GrupoVendCli() ##
// ##########################################################
Static Function SlvGVend()

   Local cSql    := ""
   
   // ##########################################################################################
   // Verifica se existe algum registro na Tabela ZZ4010. Se não existir, inclui senão altera ##
   // ##########################################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL "
   cSql += "  FROM " + RetSqlName("ZZ4") 
   cSql += " WHERE ZZ4_CODI = '000001'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )
   
   dbSelectArea("ZZ4")

   If T_PARAMETROS->( EOF() )
      RecLock("ZZ4",.T.)
      ZZ4_FILIAL := cFilAnt
      ZZ4_CODI   := "000001"
   Else
      RecLock("ZZ4",.F.)   
   Endif

   ZZ4->ZZ4_GVEN := cGrupoVend

   MsUnLock()

   oDlg:End()
   
Return(.T.)