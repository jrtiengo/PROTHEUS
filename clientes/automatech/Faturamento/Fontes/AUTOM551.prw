#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "jpeg.ch" 

// ###################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            ##
// -------------------------------------------------------------------------------- ##
// Referencia: AUTOM551.PRW                                                         ##
// Parâmetros: Nenhum                                                               ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                              ##
// Data......: 15/03/2017                                                           ##
// Objetivo..: Aletração Observação Campo C6_TRATA                                  ##
// ###################################################################################

User Function AUTOM551()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1

   Private aEmpresas := U_AUTOM539(1, "")
   Private aFiliais	 := U_AUTOM539(2, cEmpAnt)
   Private cPedido 	 := Space(06)
   Private cComboBx1
   Private cComboBx2
   Private oGet1

   Private aBrowse := {}

   Private oDlg
 
   U_AUTOM628("AUTOM551")

   DEFINE MSDIALOG oDlg TITLE "Alteração Tratativa de Item de Pedido de Venda" FROM C(178),C(181) TO C(523),C(767) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(122),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(285),C(001) PIXEL OF oDlg

   @ C(037),C(005) Say "Empresa"                     Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(097) Say "Filial"                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(202) Say "Nº do Pedido"                Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(060),C(005) Say "Produtos do Pedido de Venda" Size C(075),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(047),C(005) ComboBox cComboBx1 Items aEmpresas Size C(086),C(010)                              PIXEL OF oDlg ON CHANGE AlteraCombo() When lChumba
   @ C(047),C(097) ComboBox cComboBx2 Items aFiliais  Size C(098),C(010)                              PIXEL OF oDlg
   @ C(047),C(202) MsGet    oGet1     Var   cPedido   Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(044),C(251) Button "Pesquisar"                 Size C(037),C(012)                              PIXEL OF oDlg ACTION( xPsqAltPed() ) 

   @ C(156),C(005) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( AltTrata( Substr(cComboBx1,01,02), Substr(cComboBx2,01,02), cPedido, aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04]) )
   @ C(156),C(251) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // ###################
   // Desenha o Browse ##
   // ###################

   aAdd( aBrowse, { "", "", "", "" })

   oBrowse := TCBrowse():New( 085 , 005, 363, 110,,{'Item', 'Produto', 'Descrição dos Produtos', 'Tratativa' },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;   
                         aBrowse[oBrowse:nAt,03],;   
                         aBrowse[oBrowse:nAt,04]}}

   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// #############################################################
// Função que carrega as filiais conforme Empresa selecionada ##
// #############################################################
Static Function AlteraCombo

   aFiliais := U_AUTOM539(2, Substr(cComboBx1,01,02) )
   @ C(047),C(097) ComboBox cComboBx2 Items aFiliais  Size C(098),C(010) PIXEL OF oDlg

Return(.T.)

// ##################################################
// Função que pesquisa o pedido de venda informado ##
// ##################################################
Static Function xPsqAltPed()
           
   If Empty(Alltrim(cPedido))
      Msgalert("Pedido a ser pesquisado não informado.")
      Return(.T.)
   Endif
   
   aBrowse := {}

   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT C6_ITEM   ,"
   cSql += "       C6_PRODUTO,"
   cSql += "       C6_DESCRI ,"
   cSql += "       C6_TRATA   "
   cSql += "  FROM SC6" + Substr(cCombobx1,01,02) + "0 (NOLOCK) "
   cSql += " WHERE C6_FILIAL  = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
   cSql += "   AND C6_NUM     = '" + Alltrim(cPedido)         + "'"
   cSql += "   AND C6_STATUS  < '08'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )
   
      aAdd( aBrowse, { T_CONSULTA->C6_ITEM               ,;
                       T_CONSULTA->C6_PRODUTO            ,;
                       T_CONSULTA->C6_DESCRI + Space(30) ,;
                       T_CONSULTA->C6_TRATA              })

      T_CONSULTA->( DbSkip() )
      
   ENDDO
   
   If Len(aBrowse) == 0
      MsgAlert("Não existem dados a serem visualizados para este pedido de venda.")
      aAdd( aBrowse, { "", "", "", "" })
   Endif
      
   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;   
                         aBrowse[oBrowse:nAt,03],;   
                         aBrowse[oBrowse:nAt,04]}}

Return(.T.)

// #########################################################################################
// Função que abre a tela de seleção da data e ordem de compra para o produto selecionado ##
// #########################################################################################
Static Function AltTrata(_Empresa, _Filial, _Pedido, _Item, _Produto, _Descricao, _Observacao)

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Local kPedido    := _Pedido
   Local kProduto   := _Produto
   Local kDescricao := _Descricao
   Local kTrata01   := _Observacao
   Local kTrata02   := Space(250)

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5

   Private oDlgE

   DEFINE MSDIALOG oDlgE TITLE "Alteração de tratativa de Produto de Pedido de Venda" FROM C(178),C(181) TO C(524),C(824) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(150),C(026) PIXEL NOBORDER OF oDlgE

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(313),C(001) PIXEL OF oDlgE
   @ C(151),C(002) GET oMemo2 Var cMemo2 MEMO Size C(313),C(001) PIXEL OF oDlgE
   
   @ C(037),C(005) Say "Nº Pedido de Venda"   Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(059),C(005) Say "Código do Produto"    Size C(046),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(081),C(005) Say "Descrição do Produto" Size C(053),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(104),C(005) Say "Tratativa Atual"      Size C(040),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(127),C(005) Say "Nova Tratativa"       Size C(039),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
	   
   @ C(046),C(005) MsGet oGet1 Var kPedido    Size C(036),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(068),C(005) MsGet oGet2 Var kProduto   Size C(068),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(091),C(005) MsGet oGet3 Var kDescricao Size C(177),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(114),C(005) MsGet oGet4 Var ktrata01   Size C(313),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(136),C(005) MsGet oGet5 Var ktrata02   Size C(313),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE

   @ C(156),C(238) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgE ACTION( ColTrata(_Empresa, _Filial, _Pedido, _Item, _Produto, _Descricao, kTrata02 ) )
   @ C(156),C(279) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgE ACTION( oDlgE:End() )

   ACTIVATE MSDIALOG oDlgE CENTERED 

Return(.T.)

// #######################################################################################
// Função que atualiza o nº da ordem de compra e data de entrega no produto selecionado ##
// #######################################################################################
Static Function ColTrata(_Empresa, _Filial, _Pedido, _Item, _Produto, _Descricao, _Trata02)

   // ###########################################
   // Atualiza a Data de Entrega na tabela SC6 ##
   // ###########################################
   dbSelectArea("SC6")
   dbSetOrder(1)
   If DbSeek( _Filial + _Pedido + _Item + _Produto )

      RecLock("SC6", .F.)
	  SC6->C6_TRATA := _Trata02
      MsUnlock()
      
      // ###################################################
      // Atualiza o Grid para visualização das aletrações ##
      // ###################################################
      xPsqAltPed()                                                           
      
   Endif
           
   oDlgE:End()
   
Return(.T.)