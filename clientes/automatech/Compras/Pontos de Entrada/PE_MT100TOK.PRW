#INCLUDE "protheus.ch"

// ###################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                            ##
// -------------------------------------------------------------------------------- ##
// Referencia: MT100TOK.PRW                                                         ##
// Par�metros: Nenhum                                                               ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Jean Rehermann                                                       ##
// Data......: 24/08/2011                                                           ##
// Objetivo..: Ponto de Entrada MT100TOK - No OK da tela de lan�amento de documento ##
//             de  entrada  Verifica  nos  itens  de  entrada que possuem pedido de ##
//             compra informado,se algum item de pedido de vendas tem amarra��o com ##
//             este pedido  de  compras e item. Caso afirmativo, altera o status do ##
//             item do PV para 08 - Aguardando separa��o de estoque.                ##
// ###################################################################################

User Function MT100TOK()

	Local _lRet    := .T.
	Local _cQuery  := ""

   	Local _nPd     := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "D1_COD"     } )  // Posi��o do c�digo do produto no aHeader
	Local _nPc     := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "D1_PEDIDO"  } )  // Posi��o do pedido de compras no aHeader
	Local _nIt     := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "D1_ITEMPC"  } )  // Posi��o do item do pedido no aHeader
	Local _nQt     := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "D1_QUANT"   } )  // Posi��o da quantidade do produto do pedido no aHeader
    Local _nTES    := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "D1_TES"     } )  // Posi��o da informa��o do TES
    Local _nRateio := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "D1_RATEIO"  } )  // Posi��o da informa��o de Rateio Sim/N�o
    Local _NfOri   := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "D1_NFORI"   } )  // Nota Fiscal de Origem quando retorno de mercadorias
    Local _SrOri   := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "D1_SERIORI" } )  // S�rie da Nota Fiscal quando retorno de mercadorias
    Local _D1CC    := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "D1_CC"      } )  // Centro de Custo (�nico para a Nota Fiscal)
	Local _nDel    := 0
	Local _lDel    := .F.          // Verificar se item est� ou n�o deletado
	Local _nItens  := Len( aCols ) // Total de itens do aCols
 	Local _aArea   := GetArea()
    Local lxCentro := .T.

    Local cSql     := ""
    Local lExiste  := .F.
    Local nContar  := 0

    U_AUTOM628("PE_MT100TOK")

    If Alltrim(FUNNAME()) == "SPEDNFE"                                                 
       Return _lRet
    Endif

    If Alltrim(FUNNAME()) == "MATA920"
       Return(.T.)
    Endif
    
	// Verifica��o adicionada por Manoel Nesio (Fabritech) para evitar os erros
	// no m�dulo Central XML. Ticket #0220-000316.
    If ISINCALLSTACK("U_CENTNFEXM")
       Return(.T.)
    Endif
    
    // #############################################################
    // Verifica se foi informado algum produto de c�digo gen�rico ##
    // #############################################################
    If Select("T_GENERICO") > 0
       T_GENERICO->( dbCloseArea() )
    EndIf
   
    cSql := ""
    cSql := "SELECT ZZ4_GENE"
    cSql += "  FROM " + RetSqlName("ZZ4")
    cSql += " WHERE D_E_L_E_T_ = ''"

    cSql := ChangeQuery( cSql )
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GENERICO", .T., .T. )

    If !T_GENERICO->( EOF() )

       If !Empty(Alltrim(T_GENERICO->ZZ4_GENE))

          // ###################################################
          // Compara o produto digitado com os parametrizados ##
          // ###################################################
     	  For _nX := 1 To _nItens    

  		      _nDel := Len( aHeader ) + 1

   		      If aCols[ _nX, _nDel ]
   		         Loop
   		      Endif   

              lExiste := .F.

              For nContar = 1 to U_P_OCCURS(T_GENERICO->ZZ4_GENE, "|", 1)
                  If Alltrim(aCols[ _nX, _nPd ]) == Alltrim(U_P_CORTA(T_GENERICO->ZZ4_GENE, "|", nContar))
                     lExiste := .T.
                     Exit
                  Endif
              Next nContar
   
              If lExiste
                 MsgAlert("Aten��o! N�o � permitido a utiliza��o de produto gen�rico nesta opera��o.")
                 Return(.F.)
              Endif

          Next _nX   

       Endif

    Endif

    // #############################################################################################
    // Percorre os produtos e verifica se foi realizado o Rateio por Centro de Custo.             ##
    // Somente ser� obrigat�rio a informa��o do centro de custo para TES com Gera Duplicata = SIM ##
    // #############################################################################################
	For _nX := 1 To _nItens    

        // ##########################
        // Se n�o estiver deletado ##	
        // ##########################
		If !_lDel

           // ############################################################################################
           // Verifica se o TES permite Gerar Fatura. Se N�o, n�o consiste o rateio por centro de custo ##
           // ############################################################################################
           If Posicione( "SF4", 1, xFilial("SF4") + aCols[ _nX, _nTES ], "F4_DUPLIC" ) == "N"
              Loop
           Endif

           // ############################
           // Item do Pedido de Compras ##
           // ############################
   		   If aCols[ _nX, _nRateio ] == "2"
		      lxCentro := .F.
   		      Exit
		   Endif
		   
		Endif

    Next _nX		      

    If Alltrim(FunName()) == "AUTOM252" && Teste colocado em 09/02/2015 por Harald. Somente verifica se n�o for importa��o autom�tica de CTE's
    Else
       If !lxCentro
          If Empty(Alltrim(aCols[ _nX, _NfOri ]))
             MsgAlert("Aten��o! Rateio por Centro de Custo de algum produto n�o informado. Verifique!")
             Return(.F.)
          Else
             MsgAlert("Aten��o! N�o esque�a de efetuar o Rateio por Centro de Custo dos produtos desta devolu��o.")       
          Endif
       Endif
    Endif

    // ###################################
    // Percorre todos os itens do aCols ##
    // ###################################
	For _nX := 1 To _nItens  
		
		_nDel := Len( aHeader ) + 1
		_lDel := aCols[ _nX, _nDel ] // Verificando �ltima posi��o do acols para verificar dele��o da linha
	
		If !_lDel // Se n�o estiver deletado

		   _cPd := aCols[ _nX, _nPd ] // C�digo do Produto
		   _cPc := aCols[ _nX, _nPc ] // Pedido de Compras
		   _cIt := aCols[ _nX, _nIt ] // Item do Pedido de Compras
		   _nQd := aCols[ _nX, _nQt ] // Quantidade do Item
			
		   If !Empty( AllTrim( _cPc ) ) .And. !Empty( AllTrim( _cIt ) ) // Apenas caso o pedido de compra e item tenham sido informados
			
		 	  _cQuery := "SELECT C6_PRODUTO,"
			  _cQuery += "       C6_NUM    ,"
			  _cQuery += "       C6_ITEM   ,"
			  _cQuery += "       C6_SLDPCOM,"
			  _cQuery += "       R_E_C_N_O_ "
			  _cQuery += "  FROM " + RetSqlName("SC6")
			  _cQuery += " WHERE C6_FILIAL  = '" + xFilial("SC6") +"' "
			  _cQuery += "   AND D_E_L_E_T_ = ' '"
			  _cQuery += "   AND C6_PCOMPRA = '" + AllTrim( _cPc ) +"' "
			  _cQuery += "   AND C6_ITPCSTS = '" + AllTrim( _cIt ) +"' "
			  _cQuery += "   AND C6_STATUS  = '06' " // 06/01/2012 - Jean Rehermann - S� pode considerar os itens que est�o em compras.
			  _cQuery += " ORDER BY C6_NUM, C6_ITEM ASC"
				
			  dbUseArea( .T., "TOPCONN", TCGenQry( ,,_cQuery ), "SD1SC6", .F., .T. )

              // #################################################################################################
              // Query para verificar se existem itens de PV com o PC/Item informado no item do Doc. de entrada ##
              // #################################################################################################				
		      While !SD1SC6->( Eof() ) 
					
			     If AllTrim( SD1SC6->C6_PRODUTO ) == AllTrim( _cPd ) // Validar se o c�digo de produto confere ( PC x PV )

				    dbSelectArea("SC6")
				    dbGoTo( SD1SC6->R_E_C_N_O_ ) // Seleciono o SC6 e posiciono no RECNO correspondente

				    If SD1SC6->C6_SLDPCOM > 0

				       If _nQd >= SD1SC6->C6_SLDPCOM
				   		  _nQd -= SD1SC6->C6_SLDPCOM // Diminuo da quantidade comprada o saldo deste item do PV
						  RecLock("SC6",.F.)
						  SC6->C6_SLDPCOM := 0     // Acaba o saldo em espera pois a compra atual j� atende ao item do PV
						  SC6->C6_STATUS  := "08"  // Gravo novo status no item "08 - Aguardando Separa��o de Estoque"
						  U_GrvLogSts(xFilial("SC6"),SC6->C6_NUM, SC6->C6_ITEM, "08", "PE_MT100TOK") // Gravo o log de atualiza��o de status na tabela ZZ0
						  MsUnlock()
 					   Else
					 	  RecLock("SC6",.F.)
						  SC6->C6_SLDPCOM -= _nQd // Acaba o saldo em espera pois a compra atual j� atende ao item do PV
						  MsUnlock()
					   EndIf

					EndIf
			  
					dbSelectArea("SD1SC6")

			 	 Else  // Caso os c�digos de produto n�o sejam iguais, mesmo tendo a amarra��o, n�o muda o status e emite aviso ao operador

				    _cMsg := "Existe amarra��o PC x PV com c�digo de produto diferentes! " + Chr(13)
				    _cMsg += "PC: "+ AllTrim( _cPc ) + "/" + AllTrim( _cIt ) + " - PV: " + AllTrim( SD1SC6->C6_NUM ) + "/" + AllTrim( SD1SC6->C6_ITEM )
				    MsgAlert( _cMsg )

  				 EndIf
					
				 SD1SC6->( dbSkip() )

			  Enddo
				
		      SD1SC6->( dbCloseArea() )
			
		   EndIf
		
 		EndIf
		
	Next _nX

	RestArea( _aArea )

Return _lRet