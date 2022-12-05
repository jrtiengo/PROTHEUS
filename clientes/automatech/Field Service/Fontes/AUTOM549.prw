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
// Referencia: AUTOM549.PRW                                                         ##
// Parâmetros: Nenhum                                                               ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                              ##
// Data......: 09/03/2017                                                           ##
// Objetivo..: Inclusão de Ordem de Compra e Data de Entrega no Pedido de Venda     ##
// ###################################################################################

User Function AUTOM549()

   Local cMemo1	 := ""
   Local oMemo1

   Private aEmpresas := U_AUTOM539(1, "")
   Private aFiliais	 := U_AUTOM539(2, cEmpAnt)
   Private cPedido 	 := Space(06)
   Private kStatus   := ""
   Private cComboBx1
   Private cComboBx2
   Private oGet1

   Private aBrowse := {}

   Private oDlg
 
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

   @ C(156),C(005) Button "Incluir O.Compra" Size C(053),C(012) PIXEL OF oDlg ACTION( AltDtaOC( Substr(cComboBx1,01,02), Substr(cComboBx2,01,02), cPedido, aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,07]) )
   @ C(156),C(059) Button "Limpar O.Compra"  Size C(053),C(012) PIXEL OF oDlg ACTION( LimpaDadosOC(   Substr(cComboBx1,01,02), Substr(cComboBx2,01,02), cPedido, aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,03], aBrowse[oBrowse:nAt,04], aBrowse[oBrowse:nAt,05], aBrowse[oBrowse:nAt,06] ) )
   @ C(156),C(251) Button "Voltar"           Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   // ###################
   // Desenha o Browse ##
   // ###################

   aAdd( aBrowse, { "", "", "", "", "", "" })

   oBrowse := TCBrowse():New( 085 , 005, 363, 110,,{'Item', 'Produto', 'Descrição dos Produtos', 'O.Compra', 'Data Entrega', 'Item PC' },{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;   
                         aBrowse[oBrowse:nAt,03],;   
                         aBrowse[oBrowse:nAt,04],;      
                         aBrowse[oBrowse:nAt,05],;      
                         aBrowse[oBrowse:nAt,06]}}

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
   cSql += "       C6_PCOMPRA,"
   cSql += "       C6_ITPCSTS,"
   cSql += "       C6_PRVCOMP,"
   cSql += "       C6_STATUS  "
   cSql += "  FROM SC6" + Substr(cCombobx1,01,02) + "0 (NOLOCK) "
   cSql += " WHERE C6_FILIAL  = '" + Alltrim(Substr(cComboBx2,01,02)) + "'"
   cSql += "   AND C6_NUM     = '" + Alltrim(cPedido)         + "'"
//   cSql += "   AND C6_STATUS  < '08'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )

      aAdd( aBrowse, { T_CONSULTA->C6_ITEM                         ,; // 01
                       T_CONSULTA->C6_PRODUTO                      ,; // 02
                       T_CONSULTA->C6_DESCRI + Space(30)           ,; // 03
                       T_CONSULTA->C6_PCOMPRA                      ,; // 04
                       SUBSTR(T_CONSULTA->C6_PRVCOMP,07,02) + "/" + ; // 05
                       SUBSTR(T_CONSULTA->C6_PRVCOMP,05,02) + "/" + ; // 
                       SUBSTR(T_CONSULTA->C6_PRVCOMP,01,04)        ,; // 
                       T_CONSULTA->C6_ITPCSTS                      ,; // 06
                       T_CONSULTA->C6_STATUS                       }) // 07

      T_CONSULTA->( DbSkip() )
      
   ENDDO

   If Len(aBrowse) == 0
      MsgAlert("Não existem dados a serem visualizados para este pedido de venda.")
      aAdd( aBrowse, { "", "", "", "", "", "" })                                
   Endif
      
   oBrowse:SetArray(aBrowse) 
    
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;   
                         aBrowse[oBrowse:nAt,03],;   
                         aBrowse[oBrowse:nAt,04],;      
                         aBrowse[oBrowse:nAt,05],;      
                         aBrowse[oBrowse:nAt,06]}}

Return(.T.)

// #########################################################################################
// Função que abre a tela de seleção da data e ordem de compra para o produto selecionado ##
// #########################################################################################
Static Function AltDtaOC(_Empresa, _Filial, _Pedido, _Item, _Produto, _Descricao, _Status)

   Local cSql    := ""
   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1

   Private kEmpresa   := _Empresa
   Private kFilial    := _Filial
   Private kPedido    := _Pedido
   Private kProduto   := _Produto
   Private kDescricao := _Descricao

   Private oGet1
   Private oGet2
   Private oGet3

   Private oOk    := LoadBitmap( GetResources(), "LBOK" )
   Private oNo    := LoadBitmap( GetResources(), "LBNO" )

   Private oDlgE

   Private aLista := {}
   Private oLista

   kStatus := _Status

   If Select("T_COMPRA") > 0
      T_COMPRA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC7.C7_FILIAL ,"
   cSql += "       SC7.C7_NUM    ,"
   cSql += "	   SC7.C7_DATPRF ,"
   cSql += "   	   SC7.C7_FORNECE,"
   cSql += "       SC7.C7_LOJA   ,"
   cSql += "	   SA2.A2_NOME   ,"
   cSql += "	   SC7.C7_QUANT  ,"
   cSql += "	   SC7.C7_QUJE   ,"
   cSql += "   	  (SC7.C7_QUANT - SC7.C7_QUJE) AS SALDO,"
   cSql += "       SC7.C7_ITEM    "
   cSql += "  FROM SC7" + Substr(kEmpresa,01,02) + "0 SC7 (NOLOCK),"
   cSql += "       SA2010 SA2 (NOLOCK) "
   cSql += " WHERE SC7.C7_FILIAL  = '" + Alltrim(kFilial)  + "'"
   cSql += "   AND SC7.C7_PRODUTO = '" + Alltrim(kProduto) + "'"
   cSql += "   AND SC7.C7_QUANT  <> SC7.C7_QUJE"
   cSql += "   AND SC7.D_E_L_E_T_ = ''"
   cSql += "   AND SA2.A2_COD     = SC7.C7_FORNECE"
   cSql += "   AND SA2.A2_LOJA    = SC7.C7_LOJA"
   cSql += "   AND SA2.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMPRA", .T., .T. )

   T_COMPRA->( dBgOtOP() )
   
   WHILE !T_COMPRA->( EOF() )

      aAdd( aLista, { .F.                 ,;
                      T_COMPRA->C7_NUM    ,;
                      Substr(T_COMPRA->C7_DATPRF,07,02) + "/" + Substr(T_COMPRA->C7_DATPRF,05,02) + "/" + Substr(T_COMPRA->C7_DATPRF,01,04) ,;
                      T_COMPRA->C7_FORNECE,;
                      T_COMPRA->C7_LOJA   ,;                      
                      T_COMPRA->A2_NOME   ,;
                      T_COMPRA->SALDO     ,;
                      T_COMPRA->C7_ITEM   })
                      
      T_COMPRA->( DbSkip() )
      
   ENDDO                         

   If Len(aLista) == 0
      aAdd( aLista, { .F., "", "", "", "", "", "", "" })
   Endif

   // ########################################
   // Desenha a tela para display dos dados ##
   // ########################################
   DEFINE MSDIALOG oDlgE TITLE "Data de Entrega de Produtos" FROM C(178),C(181) TO C(479),C(758) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgE

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(282),C(001) PIXEL OF oDlgE

   @ C(037),C(005) Say "Pedido de Venda"                                        Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(037),C(051) Say "Produto"                                                Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(058),C(005) Say "Selecione o Pedido de Compra que atenderá este produto" Size C(139),C(008) COLOR CLR_BLACK PIXEL OF oDlgE

   @ C(045),C(005) MsGet oGet1 Var kPedido    Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(045),C(051) MsGet oGet2 Var kProduto   Size C(064),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(045),C(121) MsGet oGet3 Var kDescricao Size C(162),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba

   @ C(134),C(208) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgE ACTION( ColDtaOC(_Empresa, _Filial, _Pedido, _Item, _Produto, _Descricao) )
   @ C(134),C(247) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgE ACTION( oDlgE:End() )

   // ###########################
   // Cria o display da aLista ##
   // ###########################
   @ 085,005 LISTBOX oLista FIELDS HEADER "M"                      ,; // 01
                                          "P.Compra"               ,; // 02
                                          "Dta Entrega"            ,; // 03
                                          "Fornecedor"             ,; // 04
                                          "Loja"                   ,; // 05
                                          "Descrição Fornecedores" ,; // 06
                                          "Saldo"                  ,; // 07
                                          "Item"                    ; // 08
                             PIXEL SIZE 360,080 OF oDlgE ;
                             ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())     

   oLista:SetArray( aLista )

   oLista:bLine := {|| {Iif(aLista[oLista:nAt,01],oOk,oNo),;
                            aLista[oLista:nAt,02]         ,;  
                            aLista[oLista:nAt,03]         ,;  
                            aLista[oLista:nAt,04]         ,;  
                            aLista[oLista:nAt,05]         ,;  
                            aLista[oLista:nAt,06]         ,;  
                            aLista[oLista:nAt,07]         ,;  
                            aLista[oLista:nAt,08]         }}

   ACTIVATE MSDIALOG oDlgE CENTERED 

Return(.T.)

// #######################################################################################
// Função que atualiza o nº da ordem de compra e data de entrega no produto selecionado ##
// #######################################################################################
Static Function ColDtaOC(_Empresa, _Filial, _Pedido, _Item, _Produto, _Descricao)

   Local nContar  := 0
   Local lMarcado := .F.
   Local nQuantos := 0
   Local cOcompra := ""
   Local cEntrega := Ctod("  /  /    ")
   Local cItem    := ""
   
   // #######################################################################
   // Verifica se houve macação de algum pedido de compra para atualização ##
   // #######################################################################
   lMarcado := .F.
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          cOcompra := aLista[nContar,02]
          cEntrega := Ctod(aLista[nContar,03])
          cItem    := aLista[nContar,08]
          lMarcado := .T.
          Exit
       Endif
   Next nContar        

   If lMarcado == .F.
      MsgAlert("Nenhum pedido de compra foi selecionado.")
      Return(.T.)
   Endif
      
   // #################################################
   // Verifica se foi marcado mais do que 1 registro ##
   // #################################################
   nQuantos := 0
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          nQuantos := nQuantos + 1
       Endif
   Next nContar        

   If nQuantos > 1
      MsgAlert("Somente permitido indicar um pedido de compra.")
      Return(.T.)
   Endif

   // ####################################################################################
   // Captura o saldo do pedido de compra selecionado para gravação no campo C6_SLDPCOM ##
   // ####################################################################################
   nSaldo := 0
   For nContar = 1 to Len(aLista)
       If aLista[nContar,01] == .T.
          nSaldo  := aLista[nContar,07]
          Exit
       Endif
   Next nContar        

   If nSaldo == 0
      MsgAlert("Atenção! Quantidade do PC inválido. Verifique!")
      Return(.T.)
   Endif

   // ####################################
   // Atualiza o Registro na tabela SC6 ##
   // ####################################
   dbSelectArea("SC6")
   dbSetOrder(1)
   If DbSeek( _Filial + _Pedido + _Item + _Produto )

      If kStatus < "08"
         RecLock("SC6", .F.)
         SC6->C6_PRVCOMP := cEntrega
         SC6->C6_PCOMPRA := cOcompra
         SC6->C6_ITEMPC  := cItem
         SC6->C6_ITPCSTS := cItem
         SC6->C6_SLDPCOM := SC6->C6_QTDVEN
         SC6->C6_STATUS  := "06"

         // #################################################
      	 // Atualiza a tabela de Status do Pedido de Venda ##
   	     // #################################################
    	 U_GrvLogSts(xFilial("SC6"),SC6->C6_NUM, SC6->C6_ITEM, "06", "AUTOM549")
         MsUnlock()
      Else   
         RecLock("SC6", .F.)
         SC6->C6_PCOMPRA := cOcompra
         SC6->C6_ITEMPC  := cItem
         SC6->C6_ITPCSTS := cItem
         MsUnlock()
      Endif   
      
      // ###################################################
      // Atualiza o Grid para visualização das aletrações ##
      // ###################################################
      PsqAltPed()                                                           
      
   Endif
           
   oDlgE:End()
   
Return(.T.)

// ##################################################################
// Função que permite o usuário limpar os dados para nova gravação ##
// ##################################################################
Static Function LimpaDadosOC(_Empresa, _Filial, _Pedido, _Item, _Produto, _Descricao, _OCompra, _Entrega, _ItemPC)

   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Local kPedido    := _Pedido
   Local kProduto   := _Produto
   Local kDescricao := _Descricao
   Local kOCompra   := _OCompra
   Local kEntrega   := _Entrega
   Local kItemPC    := _ItemPC

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet5
   Local oGet6
   Local oGet7

   Private oDlgL

   DEFINE MSDIALOG oDlgL TITLE "Data de Entrega de Produtos" FROM C(178),C(181) TO C(478),C(525) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgL

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(165),C(001) PIXEL OF oDlgL
   @ C(127),C(002) GET oMemo2 Var cMemo2 MEMO Size C(165),C(001) PIXEL OF oDlgL

   @ C(037),C(005) Say "Pedido de Venda"      Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(058),C(005) Say "Produto"              Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(079),C(005) Say "Descrição do Produto" Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(102),C(005) Say "Nº O.Compra"          Size C(038),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(102),C(056) Say "Data Entrega"         Size C(033),C(008) COLOR CLR_BLACK PIXEL OF oDlgL
   @ C(102),C(104) Say "Item PC"              Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlgL

   @ C(045),C(005) MsGet oGet1 Var kPedido    Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL When lChumba
   @ C(067),C(005) MsGet oGet2 Var kProduto   Size C(064),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL When lChumba
   @ C(089),C(005) MsGet oGet3 Var kDescricao Size C(163),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL When lChumba
   @ C(112),C(005) MsGet oGet5 Var kOcompra   Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL When lChumba
   @ C(112),C(056) MsGet oGet6 Var kEntrega   Size C(037),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL When lChumba
   @ C(112),C(104) MsGet oGet7 Var kItemPC    Size C(024),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgL When lChumba

   @ C(132),C(047) Button "Limpar" Size C(037),C(012) PIXEL OF oDlgL ACTION( GrvLimpaOC(_Empresa, _Filial, _Item, kPedido, kProduto, kDescricao, kOcompra, kEntrega, kItemPC) )
   @ C(132),C(086) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgL ACTION( oDlgL:End() )

   ACTIVATE MSDIALOG oDlgL CENTERED 

Return(.T.)

// ###########################################################
// Função que grava a limpeza dos campos conforme indicação ##
// ###########################################################
Static Function GrvLimpaOC(_Empresa, _Filial, _Item, kPedido, kProduto, kDescricao, kOcompra, kEntrega, kItemPC)

   // #####################################
   // Limpa os campos do Pedido de Venda ##
   // #####################################
   dbSelectArea("SC6")
   dbSetOrder(1)
   If DbSeek( _Filial + kPedido + _Item + kProduto )

      If kStatus < "08"
         RecLock("SC6", .F.)
  	     SC6->C6_PRVCOMP := Ctod("  /  /    ")
         SC6->C6_PCOMPRA := ""
         SC6->C6_ITEMPC  := ""
         SC6->C6_ITPCSTS := ""
         SC6->C6_SLDPCOM := 0
         SC6->C6_STATUS  := "04"

         // #################################################
   	     // Atualiza a tabela de Status do Pedido de Venda ##
   	     // #################################################
   	     U_GrvLogSts(xFilial("SC6"),SC6->C6_NUM, SC6->C6_ITEM, "04", "AUTOM549")
         MsUnlock()
      Else
         RecLock("SC6", .F.)
         SC6->C6_PCOMPRA := ""
         SC6->C6_ITEMPC  := ""
         SC6->C6_ITPCSTS := ""
         MsUnlock()
      Endif            
      
      // ###################################################
      // Atualiza o Grid para visualização das aletrações ##
      // ###################################################                             
      PsqAltPed()                                                           
      
   Endif
           
   oDlgL:End()
   
Return(.T.)