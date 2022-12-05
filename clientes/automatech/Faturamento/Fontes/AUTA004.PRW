#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"

/*
Jean Rehermann | JPC - 18/06/2011 - Gravação do pedido de comissionamento
Programa que efetua a criação de pedido de vendas de comissão quando o pedido referente a este faturamento
for do tipo externo (pedido de intermediação) referente à tarefa #1065 do portfólio.
Chamado pelo ponto de entrada M460FIM (fonte PE_M460FIM.PRW)
*/

User Function AUTA004

	Local _cNewNumPV   := ""
	Local _cProduto    := ""
	Local _lMsErroAuto := .F.
	Local _cPedido     := SC5->C5_NUM
    Local _Emissao     := SC5->C5_EMISSAO
    Local _Cliente     := SC5->C5_CLIENTE
    Local _LojaCli     := SC5->C5_LOJACLI
    Local _Condicao    := SC5->C5_CONDPAG
    Local cNota        := ""
    Local cSerie       := ""
    Local cSerLido     := ""
    Local nCarne       := 0
    Local cGravar      := ""
    Local nDifBase     := 0
    Local nDifComi     := 0
	Local _nTotFat     := _nTotCom := 0
	Local _aCabec      := {}
	Local _aItens      := {}
	Local _aItem       := {}
	Local _aVend       := {}
	Local _cProd       := SuperGetMV("AUT_PROINT", ,"004604") // Produto referente à comissão
	Local _cTes        := SuperGetMV("AUT_TESINT", ,"508") // Tes de serviço
    Local cSql         := "" 
    Local nContar      := 0
    Local aComissao    := {}
    Local aCondicao    := {}
    Local nTcomissao   := 0
    Local nTprodutos   := 0   
    Local nDataFatur   := Ctod("  /  /    ")
    Local j            := ""
    Local __Condicao   := ""

    Local cPVOrigem    := SC5->C5_NUM
    Local cPVDestino   := ""

	Private	_aAreaXXX := GetArea()
	Private _aAreaSC5 := SC5->( GetArea() )
	Private _aAreaSC6 := SC6->( GetArea() )
    Private _aAreaSE3 := SE3->( GetArea() )

    U_AUTOM628("AUTA004")
	
	If SC5->C5_EXTERNO == "1"
	
		_cNewNumPV := GetSxeNum( "SC5", "C5_NUM" )
        cPVDestino := _cNewNumPV

		For _nX := 1 To 5
			
			// [1] Código do Vendedor  [2] Percentual Original   [3] Novo Percentual
			aAdd( _aVend, { &("SC5->C5_VEND" + AllTrim( Str( _nX ) ) ), &("SC5->C5_COMIS" + AllTrim( Str( _nX ) ) ), 0 } )
			
			If !Empty( AllTrim( aTail( _aVend )[ 1 ] ) ) .And. aTail( _aVend )[ 2 ] == 0
				
				// Se o percentual no pedido estiver zerado para o vendedor, busco no cadastro deste vendedor.
				aTail( _aVend )[ 2 ] := Posicione( "SA3", 1, xFilial("SA3") + aTail( _aVend )[ 1 ], "A3_COMIS" )
			
			EndIf
	
		Next
		
		dbSelectArea("SC6")
		dbSetOrder(1)
		If dbSeek( xFilial("SC6") + SC5->C5_NUM )
		
			While !SC6->( Eof() ) .And. SC6->C6_FILIAL + SC6->C6_NUM == xFilial("SC6") + SC5->C5_NUM
				
				_aItem := {}
				_cProduto := IIf( Empty( _cProd ), SC6->C6_PRODUTO, _cProd )
	
				aAdd( _aItem, { "C6_FILIAL" , xFilial("SC6") , NIL } ) // Filial
				aAdd( _aItem, { "C6_NUM"    , _cNewNumPV     , NIL } ) // Número do Pedido
				aAdd( _aItem, { "C6_ITEM"   , SC6->C6_ITEM   , NIL } ) // Número do Item no Pedido
				aAdd( _aItem, { "C6_PRODUTO", _cProduto      , NIL } ) // Código do Produto
				aAdd( _aItem, { "C6_QTDVEN" , 1              , NIL } ) // Quantidade Vendida
				aAdd( _aItem, { "C6_PRCVEN" , SC6->C6_COMIAUT, NIL } ) // Preço Unitário Líquido
				aAdd( _aItem, { "C6_VALOR"  , SC6->C6_COMIAUT, NIL } ) // Valor Total do Item
				aAdd( _aItem, { "C6_ENTREG" , dDataBase      , NIL } ) // Data da Entrega
				aAdd( _aItem, { "C6_UM"     , SC6->C6_UM     , NIL } ) // Unidade de Medida Primária
				aAdd( _aItem, { "C6_TES"    , _cTes          , NIL } ) // Tipo de Entrada/Saida do Item
				aAdd( _aItem, { "C6_CLI"    , SC5->C5_FORNEXT, NIL } ) // Cliente
				aAdd( _aItem, { "C6_LOJA"   , SC5->C5_LOJAEXT, NIL } ) // Loja do Cliente
	
				_nTotCom += SC6->C6_COMIAUT  // Valor total da comissão da Automatech, ou seja, do pedido que será gerado.
				_nTotFat += SC6->C6_VALOR    // Valor total faturado contra o cliente, neste faturamento.
				
				aAdd( _aItens, _aItem )
				
				SC6->( dbSkip() )
			EndDo
		
		EndIf
		
		For _nX := 1 To 5
			If !Empty( AllTrim( _aVend[ _nX, 1 ] ) ) .And. _aVend[ _nX, 2 ] > 0
				// Calculando o valor de comissão devido, que é o percentual do vendedor sobre o total faturado.
				_ValComOrig :=  _nTotFat * (_aVend[ _nX, 2 ] / 100)
				// Calculando o novo percentual sobre a base deste pedido
				_nComis := ( _ValComOrig / _nTotCom ) * 100
				
				_aVend[ _nX, 3 ] := Round( _nComis, TamSX3("A3_COMIS")[ 2 ] )
			EndIf
		Next
		
		// Monta os dados para o cabeçalho do pedido
		aAdd( _aCabec, { "C5_FILIAL" , xFilial("SC5") , NIL } )
		aAdd( _aCabec, { "C5_NUM"    , _cNewNumPV     , NIL } )
		aAdd( _aCabec, { "C5_TIPO"   , "N"            , NIL } )
		aAdd( _aCabec, { "C5_CLIENTE", SC5->C5_FORNEXT, NIL } )
		aAdd( _aCabec, { "C5_LOJACLI", SC5->C5_LOJAEXT, NIL } )
		aAdd( _aCabec, { "C5_TIPOCLI", "F"            , NIL } )
		aAdd( _aCabec, { "C5_CONDPAG", SC5->C5_CONDPAG, NIL } )
		aAdd( _aCabec, { "C5_VEND1"  , _aVend[ 1, 1 ] , NIL } )
		aAdd( _aCabec, { "C5_VEND2"  , _aVend[ 2, 1 ] , NIL } )
		aAdd( _aCabec, { "C5_VEND3"  , _aVend[ 3, 1 ] , NIL } )
		aAdd( _aCabec, { "C5_VEND4"  , _aVend[ 4, 1 ] , NIL } )
		aAdd( _aCabec, { "C5_VEND5"  , _aVend[ 5, 1 ] , NIL } )
		aAdd( _aCabec, { "C5_COMIS1" , _aVend[ 1, 3 ] , NIL } )
		aAdd( _aCabec, { "C5_COMIS2" , _aVend[ 2, 3 ] , NIL } )
		aAdd( _aCabec, { "C5_COMIS3" , _aVend[ 3, 3 ] , NIL } )
		aAdd( _aCabec, { "C5_COMIS4" , _aVend[ 4, 3 ] , NIL } )
		aAdd( _aCabec, { "C5_COMIS5" , _aVend[ 5, 3 ] , NIL } )
		aAdd( _aCabec, { "C5_EMISSAO", dDataBase      , NIL } )
		aAdd( _aCabec, { "C5_TIPLIB" , "2"            , NIL } )
		aAdd( _aCabec, { "C5_TPFRETE", "C"            , NIL } )
	
		// Rotina automática para inclusão do pedido de vendas.
		MsExecAuto( { |x,y,z| Mata410( x, y, z ) }, _aCabec, _aItens, 3 ) 
	
		If !_lMsErroAuto

			ConfirmSX8() // Confirma o número do pedido

            // Abre registros de comissão na Tabela E3 para os vendedores do pedido de intermediação
            
            // Calcula o valor de comissão para os vendedores
            If Select("T_COMISSAO") > 0
               T_COMISSAO->( dbCloseArea() )
            EndIf

            cSql := ""
            cSql := "SELECT C6_VALOR ,"
            cSql += "       C6_COMIS1,"
            cSql += "       C6_COMIS2,"
            cSql += "       C6_COMIS3,"
            cSql += "       C6_COMIS4,"
            cSql += "       C6_COMIS5,"
            cSql += "       ((C6_VALOR * C6_COMIS1) / 100) AS COMISSAO01,"
            cSql += "       ((C6_VALOR * C6_COMIS2) / 100) AS COMISSAO02,"
            cSql += "       ((C6_VALOR * C6_COMIS3) / 100) AS COMISSAO03,"
            cSql += "       ((C6_VALOR * C6_COMIS4) / 100) AS COMISSAO04,"
            cSql += "       ((C6_VALOR * C6_COMIS5) / 100) AS COMISSAO05,"
            cSql += "       C6_DATFAT                                   ,"
            cSql += "       C6_NOTA                                      "
            cSql += "  FROM " + RetSqlName("SC6010")
            cSql += " WHERE C6_NUM       = '" + Alltrim(_cPedido)       + "'"
            cSql += "   AND C6_FILIAL    = '" + Alltrim(xFilial("SC5")) + "'"
            cSql += "   AND R_E_C_D_E_L_ = ''"

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMISSAO", .T., .T. )

            If !T_COMISSAO->( EOF() )

               For nContar = 1 to Len(_aVend)
                
                   If Empty(Alltrim(_avend[nContar,1])) 
                      Loop
                   Endif

                   T_COMISSAO->( DbGoTop() )

                   nTcomissao := 0 
                   nTprodutos := 0   
                   cNota      := T_COMISSAO->C6_NOTA
                   nDataFatur := Ctod(Substr(T_COMISSAO->C6_DATFAT,07,02) + "/" + ;
                                      Substr(T_COMISSAO->C6_DATFAT,05,02) + "/" + ;
                                      Substr(T_COMISSAO->C6_DATFAT,01,04))
                   Do Case
                      Case Alltrim(xFilial("SC5")) == "01"
                           cSerie := "P1"
                      Case Alltrim(xFilial("SC5")) == "02"
                           cSerie := "P2"
                      Case Alltrim(xFilial("SC5")) == "03"
                           cSerie := "P3"
                   EndCase                           

                   While !T_COMISSAO->( EOF() )
                      Do Case
                         Case nContar = 1
                              nTComissao := nTcomissao + T_COMISSAO->COMISSAO01
                         Case nContar = 2
                              nTComissao := nTcomissao + T_COMISSAO->COMISSAO02
                         Case nContar = 3
                              nTComissao := nTcomissao + T_COMISSAO->COMISSAO03
                         Case nContar = 4
                              nTComissao := nTcomissao + T_COMISSAO->COMISSAO04
                         Case nContar = 5
                              nTComissao := nTcomissao + T_COMISSAO->COMISSAO05
                      EndCase                              
                      nTprodutos := nTprodutos + T_COMISSAO->C6_VALOR
                      T_COMISSAO->( DbSkip() )
                   Enddo      
                         
                   // Abre o registro na Tabela SE3 - Comissões.
                   // Serão abertos tantos registros conforme a condição de pagamento do Pedido de Intermediação
                   
                   // Pesquisa a condição de Pagamento
                   If Select("T_CONDICAO") > 0
                      T_CONDICAO->( dbCloseArea() )
                   EndIf

                   cSql := ""
                   cSql := "SELECT E4_CODIGO, "
                   cSql += "       E4_TIPO  , "
                   cSql += "       E4_COND  , "
                   cSql += "       E4_DESCRI  "
                   cSql += "  FROM " + RetSqlName("SE4010")
                   cSql += " WHERE E4_CODIGO    = '" + ALLTRIM(_Condicao) + "'"
                   cSql += "   AND E4_FILIAL    = ''"
                   cSql += "   AND R_E_C_D_E_L_ = ''"

                   cSql := ChangeQuery( cSql )
                   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONDICAO", .T., .T. )

                   If !T_CONDICAO->( EOF() )
                   
                      aCondicao := {}
                      cSerLido  := Alltrim(T_CONDICAO->E4_COND) + ","
                      cGravar   := ""
                      
                      For nCarne = 1 to Len(cSerlido)
                          If Substr(cSerLido,nCarne,1) == ","
                             __Condicao := IIF(Int(Val(cGravar)) == 0, 2, Int(Val(cGravar)))
                             aAdd(aCondicao, { __Condicao } )
                             cGravar := ""
                          Else
                             cGravar := cGravar + Substr(cSerLido,nCarne,1)
                          Endif
                      Next nCarne          
                      
                   Else

                      aAdd(aCondicao, { 0 } )
                   
                   Endif

                   // Abre os registros conforme a condição de pagamento
                   nDifBase := nTprodutos
                   nDifComi := nTComissao

                   For nCarne = 1 to Len(aCondicao)
                   
                       DbSelectArea("SE3")
                       DbAppend(.F.)
                       SE3->E3_FILIAL  := xFilial("SC5")
                       SE3->E3_VEND    := _avend[nContar,1]
                       SE3->E3_NUM     := cNota
                       SE3->E3_CODCLI  := _Cliente
                       SE3->E3_LOJA    := _LojaCli 
                       SE3->E3_SERIE   := cSerie
                       SE3->E3_PREFIXO := "P1"
                       SE3->E3_BASE    := ROUND(NTPRODUTOS/LEN(ACONDICAO),2)
                       SE3->E3_PORC    := ROUND(ROUND(NTCOMISSAO /  LEN(ACONDICAO),2) / ROUND(NTPRODUTOS / LEN(ACONDICAO),2) * 100,2)	
                       SE3->E3_COMIS   := ROUND((ROUND(NTPRODUTOS / LEN(ACONDICAO),2) * ROUND(ROUND(NTCOMISSAO / LEN(ACONDICAO),2) / ROUND(NTPRODUTOS / LEN(ACONDICAO),2) * 100,2)) / 100,2)
                       SE3->E3_EMISSAO := nDataFatur + aCondicao[nCarne,1]
                       SE3->E3_VENCTO  := nDataFatur + aCondicao[nCarne,1]
                       SE3->E3_PEDIDO  := _cPedido

                       nDifBase := nDifBase - ROUND(NTPRODUTOS/LEN(ACONDICAO),2)
                       nDifComi := nDifComi - ROUND((ROUND(NTPRODUTOS / LEN(ACONDICAO),2) * ROUND(ROUND(NTCOMISSAO / LEN(ACONDICAO),2) / ROUND(NTPRODUTOS / LEN(ACONDICAO),2) * 100,2)) / 100,2)

                       If nCarne == Len(aCondicao)

                          If nDifBase < 0
                             SE3->E3_BASE  := (SE3->E3_BASE - (nDifBase * -1))
                          Else
                             SE3->E3_BASE  := (SE3->E3_BASE + nDifBase)                             
                          Endif
                          
                          If nDifComi < 0
                             SE3->E3_COMIS := (SE3->E3_COMIS - (nDifComi * -1))
                          Else
                             SE3->E3_COMIS := (SE3->E3_COMIS + nDifComi)                             
                          Endif

                       Endif

                       DbUnlock()
                       
                   Next nCarne    
                   
               Next nContar    
               
            Endif

            // Linka os pedidos entre si pela gravação do campo C5_PVEXTER
   		    dbSelectArea("SC5")
		    dbSetOrder(1)
		    If dbSeek( xFilial("SC5") + cPVOrigem )
			   Reclock("SC5",.F.)
			   C5_PVEXTERN := cPVDestino
			   MsUnlock()
			Endif
			   
   		    dbSelectArea("SC5")
		    dbSetOrder(1)
		    If dbSeek( xFilial("SC5") + cPVDestino )
			   Reclock("SC5",.F.)
			   C5_PVEXTERN := cPVOrigem
			   MsUnlock()
			Endif

		Else

			If MsgYesNo("Ocorreu um problema na criação do pedido de comissão. Deseja exibir o erro?")
				MostraErro() // Exibe tela indicando qual o erro ocorrrido
			EndIf

			RollBackSX8() // Retorna o número para o controle do SXE

		EndIf
	
	EndIf
	
	RestArea( _aAreaSC6 )
	RestArea( _aAreaSC5 )
	RestArea( _aAreaXXX )
	RestArea( _aAreaSE3 )

Return( Nil )