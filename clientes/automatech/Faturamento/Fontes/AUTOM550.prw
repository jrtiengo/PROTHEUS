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
// Referencia: AUTOM550.PRW                                                         ##
// Parâmetros: Nenhum                                                               ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                              ##
// Data......: 10/03/2017                                                           ##
// Objetivo..: Aletração Data de Entrega Produção                                   ##
// ###################################################################################

User Function AUTOM550()

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

   U_AUTOM628("AUTOM550")
 
   DEFINE MSDIALOG oDlg TITLE "Alteração Data de Entrega Pedido de Venda" FROM C(178),C(181) TO C(523),C(767) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(122),C(026) PIXEL NOBORDER OF oDlg

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(285),C(001) PIXEL OF oDlg

   @ C(037),C(005) Say "Empresa"                     Size C(023),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(097) Say "Filial"                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(037),C(202) Say "Nº do Pedido"                Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(060),C(005) Say "Produtos do Pedido de Venda" Size C(075),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(047),C(005) ComboBox cComboBx1 Items aEmpresas Size C(086),C(010)                              PIXEL OF oDlg ON CHANGE AlteraCombo()
   @ C(047),C(097) ComboBox cComboBx2 Items aFiliais  Size C(098),C(010)                              PIXEL OF oDlg
   @ C(047),C(202) MsGet    oGet1     Var   cPedido   Size C(043),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(044),C(251) Button "Pesquisar"                 Size C(037),C(012)                              PIXEL OF oDlg ACTION( PsqAltPed() ) 

   @ C(156),C(005) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( AltDtaOC( Substr(cComboBx1,01,02), Substr(cComboBx2,01,02), cPedido, aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04]) )
   @ C(156),C(251) Button "Voltar"  Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // ###################
   // Desenha o Browse ##
   // ###################

   aAdd( aBrowse, { "", "", "", "" })

   oBrowse := TCBrowse():New( 085 , 005, 363, 110,,{'Item', 'Produto', 'Descrição dos Produtos', 'Data Entrega' },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

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
Static Function PsqAltPed()
           
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
   cSql += "       C6_ENTREG  "
   cSql += "  FROM SC6" + Substr(cCombobx1,01,02) + "0 (NOLOCK) "
   cSql += " WHERE C6_FILIAL  = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
   cSql += "   AND C6_NUM     = '" + Alltrim(cPedido)         + "'"
   cSql += "   AND C6_STATUS  < '08'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )
   
      aAdd( aBrowse, { T_CONSULTA->C6_ITEM                        ,;
                       T_CONSULTA->C6_PRODUTO                     ,;
                       T_CONSULTA->C6_DESCRI + Space(30)          ,;
                       SUBSTR(T_CONSULTA->C6_ENTREG,07,02) + "/" + ;
                       SUBSTR(T_CONSULTA->C6_ENTREG,05,02) + "/" + ;
                       SUBSTR(T_CONSULTA->C6_ENTREG,01,04)        })

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
Static Function AltDtaOC(_Empresa, _Filial, _Pedido, _Item, _Produto, _Descricao, _Entrega)

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Local kPedido    := _Pedido
   Local kProduto   := _Produto
   Local kDescricao := _Descricao
   Local kEntrega   := Ctod(_Entrega)
   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet5

   Private oDlgE

   DEFINE MSDIALOG oDlgE TITLE "Data de Entrega de Produtos" FROM C(178),C(181) TO C(478),C(525) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgE

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(165),C(001) PIXEL OF oDlgE
   @ C(127),C(002) GET oMemo2 Var cMemo2 MEMO Size C(165),C(001) PIXEL OF oDlgE

   @ C(037),C(005) Say "Pedido de Venda"      Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(058),C(005) Say "Produto"              Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(079),C(005) Say "Descrição do Produto" Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(102),C(005) Say "Data de Entrega"      Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
                                                                                         
   @ C(045),C(005) MsGet oGet1 Var kPedido    Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(067),C(005) MsGet oGet2 Var kProduto   Size C(064),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(089),C(005) MsGet oGet3 Var kDescricao Size C(163),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(112),C(005) MsGet oGet5 Var kEntrega   Size C(040),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE

   @ C(132),C(047) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgE ACTION( ColEntrega(_Empresa, _Filial, _Pedido, _Item, _Produto, _Descricao, kEntrega ) )
   @ C(132),C(086) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgE ACTION( oDlgE:End() )

   ACTIVATE MSDIALOG oDlgE CENTERED 

Return(.T.)

// #######################################################################################
// Função que atualiza o nº da ordem de compra e data de entrega no produto selecionado ##
// #######################################################################################
Static Function ColEntrega(_Empresa, _Filial, _Pedido, _Item, _Produto, _Descricao, _Entrega)

   // ###########################################
   // Atualiza a Data de Entrega na tabela SC6 ##
   // ###########################################
   dbSelectArea("SC6")
   dbSetOrder(1)
   If DbSeek( _Filial + _Pedido + _Item + _Produto )

      RecLock("SC6", .F.)
	  SC6->C6_ENTREG := _Entrega
      MsUnlock()
      
      // ###################################################
      // Atualiza o Grid para visualização das aletrações ##
      // ###################################################
      PsqAltPed()                                                           
      
   Endif
           
   oDlgE:End()
   
Return(.T.)