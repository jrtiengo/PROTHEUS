#Include "Protheus.ch"
#INCLUDE "jpeg.ch"    

// ####################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                             ##
// --------------------------------------------------------------------------------- ##
// Referencia: AUTOM663.PRW                                                          ##
// Parâmetros: Nenhum                                                                ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                       ##
// --------------------------------------------------------------------------------  ##
// Autor.....: Harald Hans Löschenkohl                                               ##
// Data......: 04/12/2017                                                            ##
// Objetivo..: Programa que permite alterar a data de entrega do pedido de venda sem ##
//             alterar o status do pedido.                                           ##
//             Programa chamado na tela de separação de estoque Automatech.          ##
// ####################################################################################
User Function AUTOM663()

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local oMemo1
   
   Private aFiliais  := U_AUTOM539(2, cEmpAnt)
   Private cPedido	 := Space(06)
   Private cDetalhe	 := ""

   Private cComboBx1
   Private oGet1
   Private oMemo2

   Private oOk       := LoadBitmap( GetResources(), "LBOK" )
   Private oNo       := LoadBitmap( GetResources(), "LBNO" )

   Private oFont10c  := TFont():New( "Courier New",,14,,.f.,,,,.f.,.f. )
	
   Private oDlg

   Private aListaPed := {}

   DEFINE MSDIALOG oDlg TITLE "Novo Formulário" FROM C(178),C(181) TO C(497),C(774) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(106),C(022) PIXEL NOBORDER OF oDlg

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(290),C(001) PIXEL OF oDlg

   @ C(032),C(005) Say "Filial"       Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(032),C(068) Say "Pedido Venda" Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlg

   @ C(041),C(005) ComboBox cComboBx1 Items aFiliais      Size C(058),C(010)                              PIXEL OF oDlg
   @ C(041),C(068) MsGet    oGet1     Var   cPedido       Size C(034),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(056),C(005) GET      oMemo2    Var   cDetalhe MEMO Size C(287),C(020) Font oFont10c                PIXEL OF oDlg When lChumba

   @ C(038),C(109) Button "Pesquisar"    Size C(037),C(012) PIXEL OF oDlg ACTION( PsqPvAltDta() )
   @ C(143),C(005) Button "Alterar Data" Size C(037),C(012) PIXEL OF oDlg ACTION( AltDtaDtaEnt() )
   @ C(143),C(254) Button "Voltar"       Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

   aAdd( aListaPed, { .F., "", "", "", "", "" })

   @ 102,005 LISTBOX oListaPed FIELDS HEADER "M"                     ,;
                                             "Item"                  ,;
                                             "Produto"               ,;
                                             "Descrição dos Produtos",;
                                             "Dta. Entrega"          ,;   
                                             "Status"                 ;
                                             PIXEL SIZE 368,078 OF oDlg ON dblClick(aListaPed[oListaPed:nAt,1] := !aListaPed[oListaPed:nAt,1],oListaPed:Refresh())     
   oListaPed:SetArray( aListaPed )

   oListaPed:bLine := {||{Iif(aListaPed[oListaPed:nAt,01],oOk,oNo),;
                              aListaPed[oListaPed:nAt,02]         ,;
                              aListaPed[oListaPed:nAt,03]         ,;
                              aListaPed[oListaPed:nAt,04]         ,;
                              aListaPed[oListaPed:nAt,05]         ,;
                              aListaPed[oListaPed:nAt,06]         }}


   ACTIVATE MSDIALOG oDlg CENTERED 

Return(.T.)

// ##################################################
// Função que pesquisa o pedido de venda informado ##
// ##################################################
Static Function PsqPvAltDta()

   Local cSql      := ""
   Local lPrimeiro := .T.

   If Empty(Alltrim(cPedido))
      MsgAlert("Nº do Pedido de Venda a ser pesquisado não informado.")
      Return(.T.)
   Endif
      
   aListaPed := {}
   cDetalhe  := ""

   If Select("T_CONSULTA") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC6.C6_FILIAL ,"
   cSql += "       SC6.C6_CLI    ,"
   cSql += "	   SC6.C6_LOJA   ,"
   cSql += "       SA1.A1_NOME   ,"
   cSql += "       SC6.C6_STATUS ,"
   cSql += "       SC6.C6_ITEM   ,"
   cSql += "	   SC6.C6_PRODUTO,"
   cSql += "	   SB1.B1_DESC + SB1.B1_DAUX AS DESCRICAO,"
   cSql += "	   SC6.C6_ENTREG  "
   cSql += "  FROM " + RetSqlName("SC6") + " SC6, "
   cSql += "       " + RetSqlName("SB1") + " SB1, "
   cSql += "       " + RetSqlName("SA1") + " SA1  "
   cSql += " WHERE SC6.C6_FILIAL  = '" + Substr(cComboBx1,01,02) + "'"
   cSql += "   AND SC6.C6_NUM     = '" + Alltrim(cPedido) + "'"
   cSql += "   AND SC6.D_E_L_E_T_ = ''"
   cSql += "   AND SC6.C6_STATUS  IN ('05','08')"
   cSql += "   AND SB1.B1_COD     = SC6.C6_PRODUTO"
   cSql += "   AND SB1.D_E_L_E_T_ = ''"
   cSql += "   AND SA1.A1_COD     = SC6.C6_CLI "
   cSql += "   AND SA1.A1_LOJA    = SC6.C6_LOJA"
   cSql += "   AND SA1.D_E_L_E_T_ = ''         "
   cSql += " ORDER BY SC6.C6_ITEM"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONSULTA", .T., .T. )

   T_CONSULTA->( DbGoTop() )
   
   WHILE !T_CONSULTA->( EOF() )
   
      If lPrimeiro == .T.
         cDetalhe  := cDetalhe + "Cliente.....: " + T_CONSULTA->C6_CLI + "." + T_CONSULTA->C6_LOJA + " - " + T_CONSULTA->A1_NOME + CHR(13) + CHR(10) 
         cDetalhe  := cDetalhe + "Status......: " + T_CONSULTA->C6_STATUS + " - " + IIF(T_CONSULTA->C6_STATUS == "05", "Aguardando Data de Entrega", "Aguardando Separação")
         lPrimeiro := .F.
      Endif   

      dEntrega := Substr(T_CONSULTA->C6_ENTREG,07,02) + "/" +Substr(T_CONSULTA->C6_ENTREG,05,02) + "/" +Substr(T_CONSULTA->C6_ENTREG,01,04)

      aAdd( aListaPed, { .F.                    ,;
                         T_CONSULTA->C6_ITEM    ,;
                         T_CONSULTA->C6_PRODUTO ,;
                         T_CONSULTA->DESCRICAO  ,;
                         dEntrega               ,;
                         T_CONSULTA->C6_STATUS  })

      T_CONSULTA->( DbSkip() )

   Enddo           

   If Len(aListaPed) == 0
      MsgAlert("Não existem dados a serem visualizados para este pedido de venda.")
      aAdd( aListaPed, { .F., "", "", "", "" })
   Endif
      
   oListaPed:SetArray( aListaPed )

   oListaPed:bLine := {||{Iif(aListaPed[oListaPed:nAt,01],oOk,oNo),;
                              aListaPed[oListaPed:nAt,02]         ,;
                              aListaPed[oListaPed:nAt,03]         ,;
                              aListaPed[oListaPed:nAt,04]         ,;
                              aListaPed[oListaPed:nAt,05]         ,;
                              aListaPed[oListaPed:nAt,06]         }}

Return(.T.)   

// ############################################################
// Função que altera a data de entrega do pedido selecionado ##
// ############################################################
Static Function AltDtaDtaEnt()

   Local lChumba   := .F.
   Local nContar   := 0
   Local nMarcados := 0
   Local cMemo1	   := ""
   Local oMemo1

   Private kkProduto   := ""
   Private kkDataAtual := ""
   Private kkNovadata  := ""
   Private nPosicao    := 0

   Private oGet1
   Private oGet2
   Private oGet3

   Private oDlgDT
   
   // ###################################################################
   // Verifica quantos produtos foram marcados. Permite um de cada vez ##
   // ###################################################################
   For nContar = 1 to Len(aListaPed)
       If aListaPed[nContar,01] == .T.
          nPosicao  := nContar
          nMarcados += 1
       Endif
   Next nContar
   
   If nMarcados == 0
      MsgAlert("Nenhum produto foi marcado para realizar a alteração da data de entrega.")
      Return(.T.)
   Endif
      
   If nMarcados > 1
      MsgAlert("Permitido a marcação de um produto por vez para realizar a alteração da data de entrega.")
      Return(.T.)
   Endif

   kkProduto   := aListaPed[nPosicao,02] + " - " + Alltrim(aListaPed[nPosicao,03]) + " - " + Alltrim(aListaPed[nPosicao,04])
   kkDataAtual := aListaPed[nPosicao,05]
   kkNovadata  := Ctod(aListaPed[nPosicao,05])

   DEFINE MSDIALOG oDlgDT TITLE "Novo Formulário" FROM C(178),C(181) TO C(348),C(591) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlgDT

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(198),C(001) PIXEL OF oDlgDT

   @ C(037),C(005) Say "Produto"            Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgDT
   @ C(061),C(005) Say "Data Entrega Atual" Size C(047),C(008) COLOR CLR_BLACK PIXEL OF oDlgDT
   @ C(061),C(062) Say "Nova Data Entrega"  Size C(050),C(008) COLOR CLR_BLACK PIXEL OF oDlgDT

   @ C(047),C(005) MsGet oGet1 Var kkProduto   Size C(195),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDT When lChumba
   @ C(071),C(005) MsGet oGet2 Var kkDataAtual Size C(045),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDT When lChumba
   @ C(071),C(062) MsGet oGet3 Var kkNovaData  Size C(045),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgDT

   @ C(068),C(122) Button "Gravar" Size C(037),C(012) PIXEL OF oDlgDT ACTION( GrvNvDtEnt() )
   @ C(068),C(163) Button "Voltar" Size C(037),C(012) PIXEL OF oDlgDT ACTION( oDlgDT:End() )

   ACTIVATE MSDIALOG oDlgDT CENTERED 

Return(.T.)

// ####################################
// Função que grava a data informada ##
// ####################################
Static Function GrvNvDtEnt()

   If kkNovaData == Ctod("  /  /    ")
      MsgAlert("Nova Data de Entrega não informada.")
      Return(.T.)
   Endif
   
   If aListaPed[nPosicao,06] == "05"
      If kkNovadata > Date()
         MsgAlert("Data informada não pode ser maior que data atual. Verifique!")
         Return(.T.)
      Endif
   Else
      If kkNovadata <= Date()
         MsgAlert("Data informada não pode ser menor ou igual a data atual. Verifique!")
         Return(.T.)
      Endif
   Endif   

   // ###########################################
   // Atualiza a Data de Entrega na tabela SC6 ##
   // ###########################################
   dbSelectArea("SC6")
   dbSetOrder(1)
   If DbSeek( Substr(cComboBx1,01,02) + cPedido + aListaPed[nPosicao,02] + aListaPed[nPosicao,03] )

      RecLock("SC6", .F.)

      If aListaPed[nPosicao,06] == "05"

         SC6->C6_ENTREG := kkNovaData
         SC6->C6_STATUS := "08"

         // #####################################################
 	     // Gravo o log de atualização de status na tabela ZZ0 ##
    	 // #####################################################
   		 U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "08", "AUTOM555", 0 )

         aListaPed[nPosicao,05] := Dtoc(kkNovaData)
         aListaPed[nPosicao,06] := "08"
   		    
 	  Else
   		 
	     SC6->C6_ENTREG := kkNovaData
         SC6->C6_STATUS := "05"

         // #####################################################
		 // Gravo o log de atualização de status na tabela ZZ0 ##
    	 // #####################################################
   		 U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "05", "AUTOM555", 0 )

         aListaPed[nPosicao,05] := Dtoc(kkNovaData)
         aListaPed[nPosicao,06] := "05"

      Endif

      MsUnlock()
      
   Endif   
           
   oDlgDT:End()


























/*








   Local lChumba := .F.

   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private kPedido    := Space(06)
   Private kProduto   := Space(30)
   Private kDescricao := Space(80)
   Private kEntrega   := Ctod("  /  /    ")

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet5

   Private oDlgE

   DEFINE MSDIALOG oDlgE TITLE "Data de Entrega de Produtos" FROM C(178),C(181) TO C(478),C(525) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(114),C(026) PIXEL NOBORDER OF oDlgE

   @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(165),C(001) PIXEL OF oDlgE
   @ C(127),C(002) GET oMemo2 Var cMemo2 MEMO Size C(165),C(001) PIXEL OF oDlgE

   @ C(037),C(005) Say "Pedido de Venda"      Size C(044),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(058),C(005) Say "Produto"              Size C(020),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(079),C(005) Say "Descrição do Produto" Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
   @ C(102),C(005) Say "Data de Entrega"      Size C(043),C(008) COLOR CLR_BLACK PIXEL OF oDlgE
                                                                                         
   @ C(045),C(005) MsGet oGet1 Var kPedido    Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE
   @ C(067),C(005) MsGet oGet2 Var kProduto   Size C(064),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(089),C(005) MsGet oGet3 Var kDescricao Size C(163),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE When lChumba
   @ C(112),C(005) MsGet oGet5 Var kEntrega   Size C(040),C(010) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgE

   @ C(132),C(047) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgE ACTION( xColEntrega(_Pedido, _Item, _Produto, _Descricao, kEntrega ) )
   @ C(132),C(086) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgE ACTION( oDlgE:End() )

   ACTIVATE MSDIALOG oDlgE CENTERED 

Return(.T.)

// #######################################################################################
// Função que atualiza o nº da ordem de compra e data de entrega no produto selecionado ##
// #######################################################################################
Static Function xColEntrega(_Pedido, _Item, _Produto, _Descricao, _Entrega)

   Local cTexto := ""
   Local cTipoD := 0

   // ###############################################################################
   // Consistência para pedidos com Status inicial 05 - Aguardando Data de Entrega ##
   // ###############################################################################
   If Substr(cComboBx2,01,02) == "05"

      If _Entrega <= Date()

         cTexto := ""
         cTexto += "Atenção!"                                            + chr(13) + chr(10) + chr(13) + chr(10) 
         cTexto += "Esta alteração irá alterar o Status deste produto"   + chr(13) + chr(10)
         cTexto += "para o status 08 - Aguardando Separação de Estoque." + chr(13) + chr(10) + chr(13) + chr(10) 
         cTexto += "Deseja realmente realizar esta operação?"

         cTipoD := 2
      
      Else
   
         cTexto := ""
         cTexto += "Deseja realmente realizar esta aletração de data de entrega?"

         cTipoD := 1

      Endif

   Endif

   // ################################################################
   // Consistência para pedidos com Status inicial 07 - Em Produção ##
   // ################################################################
   If Substr(cComboBx2,01,02) == "07"

      cTexto := ""
      cTexto += "Deseja realmente realizar esta aletração de data de entrega?"

      cTipoD := 1
      
   Endif   

   If MsgYesNo(cTexto)

      // ###########################################
      // Atualiza a Data de Entrega na tabela SC6 ##
      // ###########################################
      dbSelectArea("SC6")
      dbSetOrder(1)
      If DbSeek( cFilAnt + _Pedido + _Item + _Produto )

         RecLock("SC6", .F.)

         If _Entrega <= SC6->C6_ENTREG 

	        SC6->C6_ENTREG := _Entrega

            SC6->C6_STATUS := "08"

            // #####################################################
   		    // Gravo o log de atualização de status na tabela ZZ0 ##
    	    // #####################################################
   		    U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "08", "AUTOM555", 0 )
   		    
   		 Else
   		 
	        SC6->C6_ENTREG := _Entrega

            SC6->C6_STATUS := "05"

            // #####################################################
   		    // Gravo o log de atualização de status na tabela ZZ0 ##
    	    // #####################################################
   		    U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "05", "AUTOM555", 0 )

         Endif

         MsUnlock()
      
         // ###################################################
         // Atualiza o Grid para visualização das aletrações ##
         // ###################################################
         PesqEntrega()
      
      Endif
      
   Else
     
      Return(.T.)
   
   Endif   
           
   oDlgE:End()
   
Return(.T.)


   If Empty(Alltrim(_Pedido))
      MsgAlert("Nenhum pedido de venda selecionado para alteração.")
      Return(.T.)
   Endif

   If Substr(_Status,01,02) == "04"
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Alteração não permitida para pedidos de venda com " + chr(13) + chr(10) + "status 04 - Aguardando Liberação de Estoque.")
      Return(.T.)
   Endif

   If Substr(_Status,01,02) == "06"
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Alteração não permitida para pedidos de venda com " + chr(13) + chr(10) + "status 06 - Em Compra.")
      Return(.T.)
   Endif

   If Substr(_Status,01,02) == "08"
//      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Alteração não permitida para pedidos de venda com " + chr(13) + chr(10) + "status 08 - Aguardando Separação de Estoque.")
//      Return(.T.)
   Endif

*/