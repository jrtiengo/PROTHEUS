#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "XMLXFUN.CH"
#include "rwmake.ch"
#include "topconn.ch"
#Include "Tbiconn.Ch"
#INCLUDE "jpeg.ch" 

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM662.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho ( ) Ponte de Entrada                      ##                       
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 30/11/2017                                                          ##
// Objetivo..: Programa que permite usuários alterarem dados de pedido de venda    ##
//             sem que haja a alteração do status do mesmo.                        ##
// ##################################################################################

User Function AUTOM662()

   Local lChumba     := .F.
   Local cMemo1	     := ""
   Local oMemo1

   Private lEditar   := .F.
   Private lAbre     := .T.

   Private aEmpresas := U_AUTOM539(1, ""     ) 
   Private aFiliais  := U_AUTOM539(2, cEmpAnt)

   Private cComboBx1
   Private cComboBx2

   Private nStatus   := Space(50)
   Private cPedido   := Space(06)
   Private cTranspo  := Space(06)
   Private cNomeTra  := Space(80)
   Private cFrete    := 0
   Private cDetalhe  := ""
   Private cInterna  := ""

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5

   Private oMemo2
   Private oMemo3

   Private oFontxx  := TFont():New( "Courier New",,14,,.f.,,,,.f.,.f. )

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Alteração de Pedidos de Venda" FROM C(178),C(181) TO C(570),C(718) PIXEL

   @ C(002),C(002) Jpeg FILE "nLogoAutoma.bmp"    Size C(122),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO     Size C(262),C(001) PIXEL OF oDlg

   @ C(037),C(005) Say "Empresa"                  Size C(022),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(082) Say "Filial"                   Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(184) Say "Nº Ped. Venda"            Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(061),C(005) Say "Dados do Pedido de Venda" Size C(068),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(100),C(005) Say "Transportadora"           Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(100),C(214) Say "Valor do Frete"           Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(122),C(005) Say "Observações Internas"     Size C(054),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(047),C(005) ComboBox cComboBx1 Items aEmpresas Size C(072),C(010)                              PIXEL OF oDlg ON CHANGE AlteraCombo() When lChumba
   @ C(047),C(082) ComboBox cComboBx2 Items aFiliais  Size C(097),C(010)                              PIXEL OF oDlg
   @ C(047),C(184) MsGet    oGet1     Var   cPedido   Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg When lAbre

   @ C(070),C(005) GET   oMemo2 Var cDetalhe MEMO Size C(259),C(026) FONT oFontxx                            PIXEL OF oDlg When lChumba
   @ C(109),C(005) MsGet oGet2  Var cTranspo      Size C(029),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg When lEditar F3("SA4") VALID( cNomeTra := Posicione( "SA4", 1, xFilial("SA4") + cTranspo, "A4_NOME" ) )
   @ C(109),C(042) MsGet oGet3  Var cNomeTra      Size C(162),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlg When lChumba
   @ C(109),C(214) MsGet oGet4  Var cFrete        Size C(050),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlg When lEditar
   @ C(131),C(005) GET   oMemo3 Var cInterna MEMO Size C(259),C(044)                                         PIXEL OF oDlg When lEditar

   @ C(044),C(227) Button "Pesquisar"     Size C(037),C(012) PIXEL OF oDlg ACTION( PsqPVAltMen() ) When lAbre
   @ C(180),C(142) Button "Nova Pesquisa" Size C(043),C(012) PIXEL OF oDlg ACTION( LimpaDadosTl() )
   @ C(180),C(188) Button "Salvar"        Size C(037),C(012) PIXEL OF oDlg  ACTION( GrvDsdPV() ) When lEditar
   @ C(180),C(227) Button "Voltar"        Size C(037),C(012) PIXEL OF oDlg ACTION( odlg:End() )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #####################################################################
// Função que carrega o array de filiais conforme empresa selecionada ##
// #####################################################################
Static Function AlteraCombo

   aFiliais := U_AUTOM539(2, Substr(cComboBx1,01,02) )
   @ C(047),C(082) ComboBox cComboBx2 Items aFiliais  Size C(097),C(010) PIXEL OF oDlg

Return

// ##################################################
// Função que pesquisa o pedido de venda informado ##
// ##################################################
Static Function PsqPVAltMen()

   If Empty(Alltrim(cPedido))
      MsgAlert("Pedido de Venda a ser pesquisado não informado. Verifique!")
      Return(.T.)
   Endif

   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT SC5.C5_FILIAL ,"
   cSql += "       SC5.C5_NUM    ,"
   cSql += "       SC5.C5_CLIENTE,"
   cSql += "	   SC5.C5_LOJACLI,"
   cSql += "	   SA1.A1_NOME   ,"
   cSql += "       SA1.A1_END    ,"
   cSql += "	   SA1.A1_MUN    ,"
   cSql += "	   SA1.A1_EST    ,"
   cSql += "	   SA1.A1_BAIRRO ,"
   cSql += "	   SA1.A1_CEP    ,"
   cSql += "	   SC5.C5_TRANSP ,"
   cSql += "      (SELECT A4_NOME FROM SA4010 WHERE A4_COD = SC5.C5_TRANSP AND D_E_L_E_T_ = '') AS NOME_TRANSPO,"
   cSql += "	   SC5.C5_FRETE  ,"
   cSql += "       SC5.C5_NOTA   ,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), SC5.C5_MENNOTA)) AS OBS_INTERNA" 
   cSql += "  FROM " + RetSqlName("SC5") + " SC5, "
   cSql += "       " + RetSqlName("SA1") + " SA1  "
   cSql += "  WHERE SC5.C5_FILIAL = '" + Substr(cComboBx2,01,02) + "'"
   cSql += "   AND SC5.C5_NUM     = '" + Alltrim(cPedido)        + "'"
   cSql += "   AND SC5.D_E_L_E_T_ = ''            "
   cSql += "   AND SA1.A1_COD     = SC5.C5_CLIENTE"
   cSql += "   AND SA1.A1_LOJA    = SC5.C5_LOJACLI"
   cSql += "   AND SA1.D_E_L_E_T_ = ''            "
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )
   
   If T_CONSULTA->( EOF() )
      MsgAlert("Não existem dados a serem visualizados.")
      Return(.T.)
   Endif

   cDetalhe := ""
   cDetalhe := "Cliente....: [" + T_CONSULTA->C5_CLIENTE + "." + T_CONSULTA->C5_LOJACLI + "] - " + Alltrim(T_CONSULTA->A1_NOME) + CHR(13) + CHR(10) +;
               "Endereço...: "  + Alltrim(T_CONSULTA->A1_END) + " Bairro: " + Alltrim(T_CONSULTA->A1_BAIRRO)                   + CHR(13) + CHR(10) +;
               "Municipio.: "   + Alltrim(T_CONSULTA->A1_CEP) + " - " + Alltrim(T_CONSULTA->A1_MUN) + "/" + Alltrim(T_CONSULTA->A1_EST)
   cTranspo := T_CONSULTA->C5_TRANSP
   cNomeTra := T_CONSULTA->NOME_TRANSPO
   cFrete   := T_CONSULTA->C5_FRETE
   cInterna := T_CONSULTA->OBS_INTERNA

   If Empty(Alltrim(T_CONSULTA->C5_NOTA))
      lEditar  := .T.
      lAbre    := .F.
   Else
      lEditar  := .F.      
      lAbre    := .F.
      MsgAlert("Pedido de Venda já encerrado com a nota fiscal nº " + T_CONSULTA->C5_NOTA)
   Endif   

Return(.T.)

// #######################################################
// Função que limpa os dados da tela para nova pesquisa ##
// #######################################################
Static Function LimpaDadosTl()

   lEditar   := .F.
   lAbre     := .T.

   nStatus   := Space(50)
   cPedido   := Space(06)
   cTranspo  := Space(06)
   cNomeTra  := Space(80)
   cFrete    := 0
   cDetalhe  := ""
   cInterna  := ""

Return(.T.)

// #########################################################################
// Função que grava os dados alterados para o pedido de venda selecionado ##
// #########################################################################
Static Function GrvDsdPV()

   dbSelectArea("SC5")
   dbSetOrder(1)
   If dbSeek( Substr(cComboBx2,01,02) + cPedido )
      Reclock("SC5",.F.)
	  SC5->C5_TRANSP  := cTranspo
	  SC5->C5_FRETE   := cFrete
      SC5->C5_MENNOTA := cInterna
	  MsUnlock()
   Endif

   MsgAlert("Pedidi de Venda alterado.")
   
   LimpaDadosTl()      
   
Return(.T.)