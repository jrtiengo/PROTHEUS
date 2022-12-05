#INCLUDE "protheus.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOMR91.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 13/03/2012                                                          *
// Objetivo..: Programa que permite ao usuário tocar o Status dos Pedidos de Venda *
//             do Status 03 -  Aguardando Liberação de Crédito para o Status  09 - *
//             Aguardando Cliente.                                                 * 
//**********************************************************************************

User Function AUTOMR91()

   Private aComboBx1 := U_AUTOM539(2, cEmpAnt) // {"  ", "01 - Porto Alegre", "02 - Caxias do Sul", "03 - Pelotas", "04 - Suprimentos"}
   Private cComboBx1
   Private cPedido	 := Space(06)
   Private cCliente	 := Space(100)
   Private cMemo1	 := ""
   Private oGet1
   Private oGet2
   Private oMemo1
   Private lChumba   := .F.
   Private aBrowse   := {}

   Private oDlg

   DEFINE MSDIALOG oDlg TITLE "Novo Formulário" FROM C(178),C(181) TO C(468),C(804) PIXEL

   oBrowse := TCBrowse():New( 080 , 005, 382, 080,,{'Codigo', 'Item', 'Descrição', 'Status', 'Descrição dos Status', 'Registro'},{20,50,50,50},oDlg,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

   aAdd( aBrowse, { '','','','','','' } )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 

   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06] ;
                        } }
// oBrowse:bLDblClick := {|| ZOOMPRODUTO(aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02]) } 

   oBrowse:Refresh()

   @ C(003),C(005) Say "PV"      Size C(013),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(004),C(053) Say "Filial"  Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(033),C(006) Say "Cliente" Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(056),C(005) Say "Produtos do Pedido de Venda" Size C(075),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   @ C(131),C(005) Say "Selecione o item a ser alterado e clique em Alterar" Size C(261),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
   @ C(011),C(005) MsGet oGet1 Var cPedido            Size C(027),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
   @ C(011),C(052) ComboBox cComboBx1 Items aComboBx1 Size C(072),C(010) PIXEL OF oDlg

   @ C(028),C(005) GET oMemo1 Var cMemo1 MEMO         Size C(299),C(001) PIXEL OF oDlg
	
   @ C(009),C(139) Button "Pesquisar" Size C(037),C(012) PIXEL OF oDlg ACTION ( BUSCAPDV(cPedido, cComboBx1 ) )
   @ C(009),C(178) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlg ACTION ( oDlg:End() )

   @ C(043),C(005) MsGet oGet2 Var cCliente When lChumba Size C(299),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

   @ C(128),C(266) Button "Alterar" Size C(037),C(012) PIXEL OF oDlg ACTION( ALTSTATUS(aBrowse[oBrowse:nAt,01], aBrowse[oBrowse:nAt,02], aBrowse[oBrowse:nAt,04]) )

   ACTIVATE MSDIALOG oDlg CENTERED 

Return .T.

// Função que pesquisa o pedido informado
Static Function BUSCAPDV(_Pedido, _Filial)

   Local cSql := ""

   If Empty(Alltrim(_Pedido))
      MsgAlert("Pedido para pesquisa não informado.")
      Return .T.
   Endif
    
   If Empty(Alltrim(_Filial))
      MsgAlert("Filial para pesquisa não informada.")
      Return .T.
   Endif

   aBrowse := {}
   
   aAdd( aBrowse, { '','','','','','' } )

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 

   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06] ;
                        } }
   oBrowse:Refresh()

   // Pesquisa o pedido informado
   If Select("T_PEDIDO") > 0
      T_PEDIDO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.C6_CLI    ,"
   cSql += "       A.C6_LOJA   ,"
   cSql += "       A.C6_PRODUTO,"
   cSql += "       A.C6_ITEM   ,"
   cSql += "       A.C6_STATUS ,"
   cSql += "       B.B1_DESC   ,"
   cSql += "       B.B1_DAUX   ,"
   cSql += "       C.A1_NOME   ,"
   cSql += "       A.R_E_C_N_O_ "
   cSql += "  FROM " + RetSqlName("SC6") + " A, "
   cSql += "       " + RetSqlName("SB1") + " B, "
   cSql += "       " + RetSqlName("SA1") + " C  "
   cSql += "  WHERE A.C6_NUM       = '" + Alltrim(_Pedido) + "'"
   cSql += "    AND A.C6_STATUS    = '03'"
   cSql += "    AND A.R_E_C_D_E_L_ = ''  "
   cSql += "    AND A.C6_PRODUTO   = B.B1_COD "     
   cSql += "    AND A.C6_CLI       = C.A1_COD "
   cSql += "    AND A.C6_LOJA      = C.A1_LOJA"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )

   If T_PEDIDO->( EOF() )
      MsgAlert("Pedido inexistente ou sem Status 03 - Aguardando Liberação de Crédito.")
      Return .T.
   Endif
   
   // Carrega o nome do cliente
   cCliente := T_PEDIDO->A1_NOME

   aBrowse := {}

   T_PEDIDO->( DbGoTop() )
   
   WHILE !T_PEDIDO->( EOF() )
      aAdd(aBrowse, { T_PEDIDO->C6_PRODUTO, ;
                      T_PEDIDO->C6_ITEM   , ;
                      T_PEDIDO->B1_DESC   , ;
                      T_PEDIDO->C6_STATUS , ;
                      "Aguardando Liberação de Crédito", ;
                      T_PEDIDO->R_E_C_N_O_ } )
      T_PEDIDO->( DbSkip() )
   ENDDO
      
   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 

   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06] ;
                        } }
   oBrowse:Refresh()

Return .T.

// Função que pesquisa o pedido informado
Static Function ALTSTATUS(_Codigo, _Item, _Status)

   Local nContar := 0

   If _Status == "09"
      MsgAlert("Item já alterado para o Status 09 - Aguardando Cliente.")
      Return .T.
   Endif

   If !MsgYesNo("Atenção!! Confirma a alteração do Status 03 - Aguardando Liberação de Crédito para 09 - Aguardando Cliente para o item selecionado?","Confirma")
      Return .F.
   EndIf

   dbSelectArea("SC6")
   dbSetOrder(2)
   If dbSeek( xFilial("SC6") + _Codigo + cPedido + _Item )
  	  RecLock("SC6",.F.)
	  SC6->C6_STATUS := "09" // Ag. Documentação cliente
	  U_GrvLogSts( xFilial("SC6"), cPedido, _Item, "09", "AUTOMR91" ) // Gravo o log de atualização de status na tabela ZZ0
	  MsUnLock()
   EndIf 

   // Altera o conteudo do grid para display
   For nContar = 1 to Len(aBrowse)
       If aBrowse[nContar,1] == _Codigo .and. aBrowse[nContar,2] == _Item
          aBrowse[nContar,4] := "09"
          aBrowse[nContar,5] := "Aguardando Cliente"
          Exit
       Endif
   Next nContar       

   // Seta vetor para a browse                            
   oBrowse:SetArray(aBrowse) 

   // Monta a linha a ser exibina no Browse
   oBrowse:bLine := {||{ aBrowse[oBrowse:nAt,01],;
                         aBrowse[oBrowse:nAt,02],;
                         aBrowse[oBrowse:nAt,03],;
                         aBrowse[oBrowse:nAt,04],;
                         aBrowse[oBrowse:nAt,05],;
                         aBrowse[oBrowse:nAt,06] ;
                        } }
   oBrowse:Refresh()

Return .T.