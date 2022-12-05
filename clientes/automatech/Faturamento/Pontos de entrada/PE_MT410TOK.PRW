#INCLUDE "protheus.ch"

// ###################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            ##
// -------------------------------------------------------------------------------- ##
// Referencia: PE_MT410TOK.PRW                                                      ##
// Parâmetros: Nenhum                                                               ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                      ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Jean Solutio e Harald Hans Löschenkohl                               ##
// Data......: 24/08/2011                                                           ##
// Objetivo..: Ponto de Entrada MT410TOK - No OK da Inclusão/Alteração de um pedido ##
//             de venda Verifica se foi informado  pedido  de  compra  e  item para ##
//             amarração e posterior troca de status.                               ##
//                                                                                  ##
//             Jean Rehermann | JPC - 24/08/2011                                    ##
//             Harald Hans Löschenkohl - 26/01/2015 - Consistência para pedidos  de ##
//             intermediação. Informação comissão interna obrigadtória              ##
// ###################################################################################

User Function MT410TOK()

	Local _lRet        := .T.
	Local _cPd         := ""
	Local _cPc         := ""
	Local _cIt         := ""
	Local _nPd         := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "C6_PRODUTO" } ) // Posição do Código do Produto no aHeader
	Local _nPc         := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "C6_PCOMPRA" } ) // Posição do Pedido de Compra no aHeader (Campo customizado)
	Local _nIt         := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "C6_ITPCSTS" } ) // Posição do Item do pedido de compra no aHeader (Campo customizado)
	Local _nInternas   := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "C6_COMIAUT" } ) // Posição da comissão interna
	Local _TotPedido   := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "C6_VALOR"   } ) // Posição do Valor Total do Produto
	Local _nPosTES     := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "C6_TES"     } ) // Posição do TES do produto do pedido de venda
	Local _nComissao1  := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "C6_COMIS1"  } ) // Posição da Comissão para o Vendedor 1
	Local _n1Comissao  := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "C6_COMIS1"  } ) // Posição da Comissão para o Vendedor 1
	Local _n2Comissao  := aScan( aHeader, { | x | AllTrim( x[ 2 ] ) == "C6_COMIS2"  } ) // Posição da Comissão para o Vendedor 2
	Local _nDel        := 0
	Local _lDel        := .F. // Verificar se linha está deletada
	Local _cQuery      := ""
	Local _nItens      := Len( aCols ) // Quantidade de itens no aCols
	Local _aArea       := GetArea()
    Local csql         := ""
    Local nContar      := 0
    Local nTProdutos   := 0
    Local wRotAnt      := FUNNAME()
    Local lCobranca    := .F.
    Local lBloqueia    := .F.
    Local nPosicao     := 0
    Local __Posicao    := 0
    Local __Tes        := 0         
    Local lTemInternas := .T.
    Local lPertence    := .F.
    Local lLocacao     := .F.
    Local lPCompra     := .F.
    Local lHardware    := .F.
    Local lSuprimentos := .F.

    U_AUTOM628("PE_MT410TOK")

    // #########################################################################################################################
    // Verifica se o pedido de venda é um pedido de Locação. Se for, verifica se houve informações para o Contrato de Locação ##
    // #########################################################################################################################
    lLocacao := .F.
    For nContar = 1 to Len(aCols)
        If aCols[nContar, _nPosTES] == "728"
           lLocacao := .T.
           Exit
        Endif
    Next nContar
    
    If lLocacao == .T.
       If Empty(Alltrim(M->C5_ZLOC))
          MsgAlert("Este pedido é um pedido de locação porém os dados para Contrato de Locação não foram preenchidos. Verifique!")
          Return(.F.)
       Endif
 
       kParam01 := U_P_CORTA(M->C5_ZLOC, "|", 1)
       kParam02 := U_P_CORTA(M->C5_ZLOC, "|", 2)
       kParam03 := U_P_CORTA(M->C5_ZLOC, "|", 3)
       kParam04 := U_P_CORTA(M->C5_ZLOC, "|", 4)
       kParam05 := U_P_CORTA(M->C5_ZLOC, "|", 5)
       kParam06 := U_P_CORTA(M->C5_ZLOC, "|", 6)
       kParam07 := U_P_CORTA(M->C5_ZLOC, "|", 7)
       kParam08 := U_P_CORTA(M->C5_ZLOC, "|", 8)                                    
 
       If Empty(Alltrim(kparam01))
          MsgAlert("Data inicial de vigência do contrato de locação não informado. Verifique!")
          Return(.F.)
       Endif
          
       If Empty(Alltrim(kparam02))
          MsgAlert("Data final de vigência do contrato de locação não informado. Verifique!")
          Return(.F.)
       Endif
 
       If Empty(Alltrim(kparam03)) .Or. kparam03 == "0"
          MsgAlert("Unidade de Vigência do contrato de locação não selecionado. Verifique!")
          Return(.F.)
       Endif
 
       If Empty(Alltrim(kparam04))
          MsgAlert("Vigência do contrato de locação não informado. Verifique!")
          Return(.F.)
       Endif
 
       If Empty(Alltrim(kparam05)) .Or. kparam05 == "0"
          MsgAlert("Tipo de Atendimento do contrato de locação não selecionado. Verifique!")
          Return(.F.)
       Endif
          
       If Empty(Alltrim(kparam06)) .Or. kparam06 == "0"
          MsgAlert("Tipo de Contrato do contrato de locação não selecionado. Verifique!")
          Return(.F.)
       Endif
 
       If VAL(kparam07) == 0
          MsgAlert("Valor do contrato de locação não informado. Verifique!")
          Return(.F.)
       Endif
 
    Endif   

    // ###################################################################################################################
    // Realiza a consistência. Se informado campo C6_PCOMPRA, verifica se foi informado os campos C6_ITEMPC, C6_ITPCSTS ##
    // ###################################################################################################################
    lPCompra := .F.
    
    For nContar = 1 to Len(aCols)
        If Empty(Alltrim(aCols[nContar, _nPc]))
        Else
           If Empty(Alltrim(aCols[nContar, _nIt]))
              lPCompra := .T.
              Exit
           Endif
        Endif   
    Next nContar
    
    If lPCompra == .T.
       MsgAlert("Atenção!"                                                                                                                    + chr(13) + chr(10) + chr(13) + chr(10) + ;
                "Existem produtos que serão atendidos por Pedido de Compra, porém, não foi informado no produto, o Item do Pedido de Compra." + chr(13) + chr(10) + chr(13) + chr(10) + ;
                "Verifique!")
       Return(.F.)
    Endif

    // #################################################################################
    // Tarefa #4343 - Se frete for FOB, é obrigado a ser informado uma transportadora ##
    // #################################################################################
    If M->C5_TPFRETE == "F"

       // ###################################################################
       // Tarefa #3241 - Se o frete for FOB, não poderá ter valor de frete ##
       // ###################################################################
       If M->C5_FRETE == 0
       Else
          MsgAlert("Atenção! Valor do frete será zerado em razão do tipo de frete ser FOB.")
          M->C5_FRETE := 0
       Endif   

       If Empty(Alltrim(M->C5_TRANSP))
          MsgAlert("Atenção! Necessário informar uma transportadora. Verifique!")
          Return(.F.)
       Endif
    Endif

    // #################################################################################
    // Tarefa #4343 - Se frete for FOB, é obrigado a ser informado uma transportadora ##
    // #################################################################################
    If M->C5_FRETE == 0
    Else
       If M->C5_TPFRETE == "F"
          MsgAlert("Atenção! Valor do frete será zerado em razão do tipo de frete ser FOB.")
          M->C5_FRETE := 0       
       Endif
    Endif      

//    // ##########################################
//    // Verifica se o vendedor 1 foi informado. ##
//    // ##########################################
//    If Substr(wRotAnt,1,7) == "MATA410" .Or.  Substr(wRotAnt,1,8) == "AUTOM587"
//    
//       If Empty(Alltrim(M->C5_VEND1))
//          MsgAlert("Atenção! Vendedor 1 não informado. Campo obrigadtório!")
//          Return(.F.)
//       Endif
//       
//    Endif      

    // ###########################################################################################
    // Verifica se o pedido de venda é um pedido de transsferências entre filials               ##
    // Se for, verifica se a transferência está sendo realizada para a filiais da mesma Empresa ##
    // ###########################################################################################
    If Substr(wRotAnt,1,7) == "MATA410" .Or.  Substr(wRotAnt,1,8) == "AUTOM587"
                                               
       // ###################################
       // Captura o CNPJ da Empresa logada ##
       // ###################################
       dbSelectArea("SM0")
       dbSeek(cEmpAnt)
       cCGCLogado := SM0->M0_CGC

       // ##################################
       // Pesquisa os parâmetros de frete ##
       // ##################################
       If Select("T_TRANSFERE") > 0
          T_TRANSFERE->( dbCloseArea() )
       EndIf
   
       cSql := ""
       cSql := "SELECT ZZ4_TTRA FROM " + RetSqlName("ZZ4")

       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TRANSFERE", .T., .T. )

       If Empty(Alltrim(T_TRANSFERE->ZZ4_TTRA))
       Else

          lTransferencia := .F.
                                      
          For nContar = 1 to Len(aCols)

              If U_P_OCCURS(T_TRANSFERE->ZZ4_TTRA, aCols[nContar, _nPosTES], 1) == 0
              Else
                 lTransferencia := .T.
                 Exit
              Endif
          Next nContar
    
          If lTransferencia == .T.   
             If Substr(cCGCLogado,01,08) <> Substr(Posicione("SA1", 1, xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_CGC"),01,08)
                MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + ;
                         "Transferência somente permitida entre Filiais de mesma Empresa." + chr(13) + chr(10) + chr(13) + chr(10) + ;
                         "Verifique!")
                Return(.F.)
             Endif
          Endif
       Endif
    Endif

    // ###################################################################################################
    // Verifica, somente para vendedores e Executivos de Venda, se os dados do contato foram informados ##
    // ###################################################################################################

    // #####################################
    // Pesquisa o grupo do usuário logado ##
    // #####################################
/*
    PswOrder(2)
     
    If PswSeek(cUserName,.F.)

       _aRetUser := PswRet(1)
       lPertence := .F.

       // #######################################
       // Carrega o código do grupo do usuário ##
       // #######################################
       If Len(_aRetUser[1][10]) <> 0

          _Grupo    := _aRetUser[1][10][1]
          lPertence := .F.

          For xx = 1 to Len(_aRetUser[1][10])
              If _Grupo$("000011#000017#000026")
                 lPertence := .T.
                 Exit
              Endif
          Next xx                   

       Endif    
      
   Else
   
      lPertence := .F.
      
   Endif      

*/

//   If lPertence == .T.
   
      // ##############################################
      // Verifica se o nome do contato foi informado ##
      // ##############################################
      If Empty(Alltrim(M->C5_ZCON))
         // ###################################################
         // Quando for encerramento de contratos, não valida ##
         // ###################################################
         If Upper(Alltrim(FunName())) == "CNTA120" .OR. Upper(Alltrim(FunName())) == "CNTA121"
         Else
            MsgAlert("Atenção!" + CHR(13) + CHR(10) + CHR(13) + CHR(10) + "Nome do Contato não informado. Verifique!")
            Return(.F.)
         Endif   
      Endif
         
      // ################################################
      // Verifica se o e-mail do contato foi informado ##
      // ################################################
      If Empty(Alltrim(M->C5_ZEMA))
         // ###################################################
         // Quando for encerramento de contratos, não valida ##
         // ###################################################
         If Upper(Alltrim(FunName())) == "CNTA120" .OR. Upper(Alltrim(FunName())) == "CNTA121"
         Else
            MsgAlert("Atenção!" + CHR(13) + CHR(10) + CHR(13) + CHR(10) + "E-mail do Contato não informado. Verifique!")
            Return(.F.)
         Endif
      Endif

      // #############################################
      // Verifica se o DDD do contato foi informado ##
      // #############################################
//      If Empty(Alltrim(M->C5_ZDD1))
//         MsgAlert("Atenção!" + CHR(13) + CHR(10) + CHR(13) + CHR(10) + "DDD do Telefone do Contato não informado. Verifique!")
//         Return(.F.)
//      Endif

      // ##################################################
      // Verifica se o Telefone do contato foi informado ##
      // ##################################################
//      If Empty(Alltrim(M->C5_ZTE1))
//         MsgAlert("Atenção!" + CHR(13) + CHR(10) + CHR(13) + CHR(10) + "Telefone do Contato não informado. Verifique!")
//         Return(.F.)
//      Endif
      
//    Endif

    // ################################################################
    // Verifica se o pedido de venda é um pedido de intermediação.   ##
    // Se for, verifica se TES é igual a 543 para os produtos.       ##
    // ################################################################
    If Substr(wRotAnt,1,7) == "MATA410" .Or.  Substr(wRotAnt,1,8) == "AUTOM587" .OR. Substr(wRotAnt,1,3) == "RPC"

       // ##################################################################
       // Se pedido indicado como intermedição, verifica se o TES é o 543 ##
       // ##################################################################
       If M->C5_EXTERNO = "1"

          lTESIncorreta := .F.

          For nContar = 1 to Len(aCols)
              If Empty(Alltrim(aCols[nContar,_nPosTES]))
                 lTESIncorreta := .T.
                 Exit
              Endif

              If aCols[nContar,_nPosTES] <> "543"
                 lTESIncorreta := .T.
                 Exit
              Endif

          Next nContar
          
          If lTESIncorreta == .T.
             MsgAlert("Atenção !" + chr(13) + chr(13) + "TES informada está incorreta para pedidos de venda de intermediação." + chr(13) + chr(10) + "Verifique!")
             Return .F.
          Endif   

       Endif
       
       // #####################################################################################################################################
       // Se pedido não for indicado como intermedição, verifica se o TES é o 543, neste caso, dá mensagem que o tio de pedido está inválido ##
       // #####################################################################################################################################
       If M->C5_EXTERNO = "1"
       Else

          lTESIncorreta := .F.

          For nContar = 1 to Len(aCols)
              If Empty(Alltrim(aCols[nContar,_nPosTES]))
                 lTESIncorreta := .T.
                 Exit
              Endif

              If aCols[nContar,_nPosTES] == "543"
                 lTESIncorreta := .T.
                 Exit
              Endif

          Next nContar
          
          If lTESIncorreta == .T.
             MsgAlert("Atenção !" + chr(13) + chr(13) + "TES informada é referente a Pedido de Intermedição, porém, o pedido não está indicado como pedido de intermedição." + chr(13) + chr(10) + "Verifique!")
             Return .F.
          Endif   
       Endif

       // ###############################################################################################
       // Se pedido for indicado como intermedição, verifica se o código do distribuidor foi informado ##
       // ###############################################################################################
//       If M->C5_EXTERNO = "1"
//
//          If M->C5_FORNEXT == "" 
//             MsgAlert("Atenção !" + chr(13) + chr(13) + ;
//                      "Pedido de venda é um pedido de intermedição." + chr(13) + chr(10) + ;
//                      "Código do Distribuidor não informado."        + chr(13) + chr(10) + ;
//                      "Verifique!")
//             Return .F.
//          Endif   
//
//          If Empty(Alltrim(M->C5_LOJAEXT))
//             MsgAlert("Atenção !" + chr(13) + chr(13) + ;
//                      "Pedido de venda é um pedido de intermedição." + chr(13) + chr(10) + ;
//                      "Loja do Distribuidor não informado."          + chr(13) + chr(10) + ;
//                      "Verifique!")
//             Return .F.
//          Endif   
//
//       Endif   

    Endif

    // ################################################################
    // Verifica se o pedido de venda é um pedido de intermediação.   ##
    // Se for, verifica se o valor de comissão interna foi informada ##
    // ################################################################
    If Substr(wRotAnt,1,7) == "MATA410" .Or.  Substr(wRotAnt,1,8) == "AUTOM587" .OR. Substr(wRotAnt,1,3) == "RPC"

       If M->C5_EXTERNO = "1"

          lTemInternas := .T.
          For nContar = 1 to Len(aCols)
              If aCols[nContar,_nInternas] == 0
                 lTemInternas := .F.
                 Exit
              Endif
          Next nContar
          
          If lTemInternas == .F.
             If cEmpAnt == "02"
                MsgAlert("Atenção !" + chr(13) + chr(13) + "Existem produtos sem informação do valor da comissão interna." + chr(13) + chr(10) + "Pedido de Venda não será gravado sem esta informações." + chr(13) + chr(10) + "Verifique!")
                Return .F.
             Endif   
          Endif
       Endif
       
    Endif

    // ############################################################
    // Realiza consistência dos dados da tela do pedido de venda ##
    // ############################################################
    If (Substr(wRotAnt,1,7) == "MATA410" .Or.  Substr(wRotAnt,1,8) == "AUTOM587" .Or. Substr(wRotAnt,1,3) == "RPC") .And. M->C5_TIPO == "N"

/*
       // ########################################################################################################################
       // Regra de preenchimento do código do vendedor no pedido de venda                                                       ##
       // --------------------------------------------------------------------------------------------------------------------- ##
       // Se Empresa logada for 03 - Atech e Filial 01 ou Empresa 01 e Filial 04, aplica-se a seguinte regra                    ##
       // --------------------------------------------------------------------------------------------------------------------- ##
       // 1) Se pedido de venda tiver somente produtos de serviço, o vendedor será o vendedor Hardware do cadastro de clientes. ##
       // 2) Se pedido de venda tiver somente produtos de suprimentos (Grupo de 0200 ao 0299) o vendedor é do Suprimentos       ##
       // 3) Se no pedido de venda tiver produtos de suprimentos junto com produtos de serviço , sistema deverá dar um aviso    ##
       //    que o mesmos deverá ser desdobrado e não permitir a gravação do mesmo.                                             ##
       // Nova regra para venda compartilhada                                                                                   ##
       // Quando o cliente for um cliente com venda compartilhada, não se aplica a regra abaixo ou seja, o pedido de venda po-  ##
       // derá vender os produtos todos juntos.                                                                                 ##            
       // ########################################################################################################################
       If Posicione("SA1", 1, xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_ZCOMP") == "S"
       Else

          If (cEmpAnt == "01" .And. cFilAnt == "04") .Or. ;
             (cEmpAnt == "03" .And. cFilAnt == "01") .Or. ;
             (cEmpAnt == "01" .And. cFilAnt == "07")
       
             // ############################################################################
             // Verifica se todos os produtos do pedido de venda são produtos de serviços ##
             // ############################################################################
             nTotalProdutos := 0
             nTotalServicos := 0
             For nContar = 1 to Len(aCols)

		    	 _nDel := Len( aHeader ) + 1
			     _lDel := aCols[ nContar, _nDel ] // Verificando de a linha está deletada
		
			     If !_lDel 

                    If Alltrim(Posicione("SB1", 1, xFilial("SB1") + aCols[nContar,_nPd], "B1_TIPO")) == "MO"
                       nTotalServicos := nTotalServicos + 1
                    Else
                       nTotalProdutos := nTotalProdutos + 1
                    Endif                   
                 
                 Endif   

             Next nContar

             // ##################################################################
             // Aplica a regra quando o pedido de venda somente possui serviços ##
             // ##################################################################
             If nTotalServicos <> 0 .And. nTotalProdutos == 0

                k_Novo_Vendedor := POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_VEND")       
               
                If Empty(Alltrim(k_Novo_Vendedor))
                Else
                   k_Vendedor_Antes := M->C5_VEND1
                   M->C5_VEND1 := POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_VEND")       
                   If k_Vendedor_Antes == M->C5_VEND1
                   Else
                      MsgAlert("Atenção!" + chr(13) + chr(10) + "Vendedor foi alterado para vendedor Hardware para o código: " + k_Novo_Vendedor)
                   Endif   
                Endif

             Else

                If nTotalServicos <> 0 .And. nTotalProdutos <> 0          
//                   MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Produtos de Suprimentos e Serviços devem estar em pedidos separados.")
//                   Return(.F.)
                Else   
      
                   // #############################################################################
                   // Verifica se os produtos pertencem aos grupos de suprimentos (0200 ao 0299) ##
                   // #############################################################################
                   lTodosSuprimentos := .F.

                   For nContar = 1 to Len(aCols)

    			       _nDel := Len( aHeader ) + 1
   			           _lDel := aCols[ nContar, _nDel ] // Verificando de a linha está deletada

			           If !_lDel 

                          k_Grupo_Produto := Posicione("SB1", 1, xFilial("SB1") + aCols[nContar,_nPd], "B1_GRUPO")

                          If (k_Grupo_Produto >= "0200" .And. k_Grupo_Produto <= "0299") .Or. (k_Grupo_Produto >= "0400")
                             lTodosSuprimentos := .T.                       
                          Else
                             lTodosSuprimentos := .F.                                              
                             Exit
                          Endif
                     
                       Endif   

                   Next nContar

                   // ####################################################################################################
                   // Não permite venda de produtos que não sejam de suprimentos na Empresa 03 ou Empresa 01, Filial 04 ##
                   // ####################################################################################################
                   If lTodosSuprimentos == .F.
//                      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Produtos não são produtos de Suprimentos. Verifique!")
//                      Return(.F.)
                   Endif
                
                   // #############################################################################
                   // Pesquisa o vendedor suprimentos para popular o vendedor do pedido de venda ##
                   // #############################################################################
                   k_Novo_Vendedor := POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_ZVEND2")

                   If Empty(Alltrim(k_Novo_Vendedor))
                   Else
                      k_Vendedor_Antes := M->C5_VEND1
                      M->C5_VEND1 := POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_ZVEND2") 
                      If k_Vendedor_Antes == M->C5_VEND1
                      Else
                         MsgAlert("Atenção!" + chr(13) + chr(10) + "Vendedor foi alterado para vendedor Suprimentos para código: " + k_Novo_Vendedor)
                      Endif
                   Endif   

                Endif
          
             Endif
          
          Else
          
             // #############################################################################################################
             // Nova regra incluída no dia 22/06/2017                                                                      ##
             // Se o cliente possuir dois vendedores e não for um cliente com venda compartilhada, verifica se os produtos ##
             // possuem hardware e suprimentos juntos.                                                                     ##
             // Se possuir dispara mensagem informando que o pedido não poderá ser finalizado por este motivo.             ##
             // Se os produtos forem todos de Hardware, vale o vendedor 1 senão é o Vendedor 2                             ##
             // #############################################################################################################
             kk_Vend1 := M->C5_VEND1  // Posicione("SA1", 1, xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_VEND")
             kk_Vend2 := M->C5_VEND2  // Posicione("SA1", 1, xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_ZVEND2")

             If Alltrim(kk_Vend1) <> "" .And. Alltrim(kk_Vend2) <> ""
          
                If Posicione("SA1", 1, xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_ZCOMP") == "N"
   
                   lTodosSuprimentos := .F.
                   lTodosProdutos    := .F.

                   For nContar = 1 to Len(aCols)

	      		       _nDel := Len( aHeader ) + 1
   			           _lDel := aCols[ nContar, _nDel ] // Verificando de a linha está deletada

			           If !_lDel 

                          k_Grupo_Produto := Posicione("SB1", 1, xFilial("SB1") + aCols[nContar,_nPd], "B1_GRUPO")

                          If (k_Grupo_Produto >= "0200" .And. k_Grupo_Produto <= "0299") .Or. (k_Grupo_Produto >= "0400")

                             If k_Grupo_Produto == "0119" .And.k_Grupo_Produto == "0410"
                             Else
                                lTodosSuprimentos := .T.                       
                             Endif   

                          Else
                             lTodosProdutos    := .T.
                             Exit
                          Endif
                     
                       Endif   

                   Next nContar
          
                   If lTodosSuprimentos == .T. .And. lTodosProdutos == .T.
//                      MsgAlert("Atenção!" + chr(13) + chr(10) + "Pedido de venda não pode ter produtos de Hardware juntamente com produtos de Suprimentos." + CHR(13) + CHR(10) + "Faça pedidos de venda separados.")             
//                      Return(.F.)
                   Endif   

                   If lTodosSuprimentos == .T. .And. lTodosProdutos == .F.
                      k_Novo_Vendedor := POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_ZVEND2") 
                      M->C5_VEND1     := k_Novo_Vendedor
                      kTipoVen2       := Posicione("SA3",1,xFilial("SA3") + k_Novo_Vendedor, "A3_TIPOV")

                      // ######################################################################################
                      // Altera o % de comissão dos produtos com o % de comissão do vendedor 2 - Suprimentos ##
                      // ######################################################################################
                      For nContar = 1 to Len(aCols)
                          
                          // #######################################
                          // Verificando de a linha está deletada ##
                          // #######################################
            		      _nDel := Len( aHeader ) + 1
   			              _lDel := aCols[ nContar, _nDel ] 

			              If !_lDel 

                             k_Grupo_Produto := Posicione("SB1", 1, xFilial("SB1") + aCols[nContar,_nPd], "B1_GRUPO")

                             Do Case
                                Case kTipoVen2 == "1"
                                     kComissao := Posicione("SBM",1,xFilial("SBM") + SB1->B1_GRUPO, "BM_COME1")
                                Case kTipoVen2 == "2"
                                     kComissao := Posicione("SBM",1,xFilial("SBM") + SB1->B1_GRUPO, "BM_COMIS")
                                Case kTipoVen2 == "3"
                                     kComissao := Posicione("SBM",1,xFilial("SBM") + SB1->B1_GRUPO, "BM_COME2")
                             EndCase
                                     
                             aCols[nContar,_nComissao1] := kComissao
                     
                          Endif   

                      Next nContar


                      MsgAlert("Atenção!" + chr(13) + chr(10) + "Vendedor foi alterado para vendedor Suprimentos para o código: " + k_Novo_Vendedor)

                   Endif   
             
                Endif
          
             Else
             
                lTodosSuprimentos := .F.
                lTodosProdutos    := .F.

                For nContar = 1 to Len(aCols)

    		        _nDel := Len( aHeader ) + 1
   			        _lDel := aCols[ nContar, _nDel ] // Verificando de a linha está deletada

			        If !_lDel 

                       k_Grupo_Produto := Posicione("SB1", 1, xFilial("SB1") + aCols[nContar,_nPd], "B1_GRUPO")

                       If (k_Grupo_Produto >= "0200" .And. k_Grupo_Produto <= "0299") .Or. (k_Grupo_Produto >= "0400")
                          lTodosSuprimentos := .T.                       
                       Else
                          lTodosProdutos    := .T.
                       Endif
                     
                    Endif   

                Next nContar
          
                If lTodosSuprimentos == .T. .And. lTodosProdutos == .T.
//                   MsgAlert("Atenção!" + chr(13) + chr(10) + "Pedido de venda não pode ter produtos de Hardware juntamente com produtos de Suprimentos." + CHR(13) + CHR(10) + "Faça pedidos de venda separados.")             
//                   Return(.F.)
                Endif   
             
             Endif
          
          Endif   
          
       Endif   
*/
  
       // #############################################################################################################################
       // Tarefa #4556 - Nova Regra para popular vendedor no Pedido de Venda                                                         ##
       // -------------------------------------------------------------------------------------------------------------------------- ##
       // Se o grupo do produto do pedido de venda estiver entre 0200 a 0299 e 0400, o vendedor a ser considerado no pedido de venda ##
       // será o vendedor 2 (A1_ZVEND2).                                                                                             ## 
       //                                                                                                                            ##
       // Se o grupo de produtos do pedido de venda for diferente do range de 0200 a 0299 e 400, o vendedor do pedido de venda  será ##
       // populado com o vendedor 1 (A1_VEND).                                                                                       ##
       //                                                                                                                            ##
       // Se houverem produtos com grupos de vendas diversos, ou seja, produtos no  range 0200  a 0299 e 0400  e  demais  grupos,  o ##
       // vendedor 1 e vendedor 2 do pedido de venda somente  serão  populados  se  o  vendedor  1 (A1_VEND) for igual ao vendedor 2 ##
       // (A1_ZVEND2)                                                                                                                ##
       //                                                                                                                            ##
       // A regra acima somente será aplicada se no cadastro do cliente não existir a indicação de venda compartilhado, ou seja,  se ##
       // venda for compartilhada, a  regra  acima  não  deverá  ser  aplicada  sendo populado neste caso o vendedor 1 com A1_VEND e ##
       // vendedor 2 com A1_ZVEND2.                                                                                                  ##
       // #############################################################################################################################
       If Posicione("SA1", 1, xFilial("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_ZCOMP") == "S"

          M->C5_VEND1 := POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_VEND"  ) 
          M->C5_VEND2 := POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_ZVEND2") 

          // ######################################################################################
          // Altera o % de comissão dos produtos com o % de comissão do vendedor 2 - Suprimentos ##
          // ######################################################################################
          For nContar = 1 to Len(aCols)
                          
              // #######################################
              // Verificando de a linha está deletada ##
              // #######################################
       		  _nDel := Len( aHeader ) + 1
   			  _lDel := aCols[ nContar, _nDel ] 

			  If !_lDel 

                 // #############################################################
                 // Programa que calcula o % de comissão por Vendedor/Produtos ##
                 // #############################################################
                 U_AUTOM573(aCols[nContar,_nPd])
                                         
              Endif   

          Next nContar

       Else
       
          // ######################################################################################################
          // Verifica os grupos dos produtos dos pedidos do pedidos de venda para aplicar a regra acima descrita ##
          // ######################################################################################################
          lHardware    := .F.
          lSuprimentos := .F.

          For nContar = 1 to Len(aCols)

              // ######################################################
              // Variáveis paa verificar se o registro está deletado ##
              // ######################################################
 		      _nDel := Len( aHeader ) + 1
   			  _lDel := aCols[ nContar, _nDel ]

	          If !_lDel 

                 k_Grupo_Produto := Posicione("SB1", 1, xFilial("SB1") + aCols[nContar,_nPd], "B1_GRUPO")

                 If (k_Grupo_Produto >= "0200" .And. k_Grupo_Produto <= "0299") .Or. (k_Grupo_Produto >= "0400")
                    lSuprimentos := .T.                       
                 Else
                    lHardware    := .T.
                 Endif
                     
              Endif   

          Next nContar
          
          // #################
          // Aplica a Regra ##
          // #################
          Do Case
          
             Case lHardware == .F. .And. lSuprimentos == .T.
             
                  If Empty(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_ZVEND2")))

                     If Empty(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_VEND")))
                           
                        If Empty(Alltrim(M->C5_VEND1)) .And. Empty(Alltrim(M->C5_VEND2))
                           M->C5_VEND1 := Space(06)
                           M->C5_VEND2 := Space(06)

                           MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Vendedor não informado. Verifique!")
       
                           // #################################################################################################################                    
                           // Este programa refere-se ao gatilho que é disparado no campo do código do vendedor.                             ##
                           // Isso serve para verificar se o campo do vendedor deve ou não ser aberto para que o usuário informe um vendedor ##
                           // #################################################################################################################
                           U_AUTOM534(M->C5_VEND1)
                           Return(.F.)
                        Endif   

                     Else   
                        M->C5_VEND1 := POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_VEND") 
                        M->C5_VEND2 := Space(06)
                     Endif   

                  Else   
                     M->C5_VEND1 := POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_ZVEND2") 
                     M->C5_VEND2 := Space(06)
                  Endif   

             Case lHardware == .T. .And. lSuprimentos == .F.

                  If Empty(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_VEND")))

                     If Empty(Alltrim(POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_ZVEND2")))

                        If Empty(Alltrim(M->C5_VEND1))
                           MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Vendedor não informado. Verifique!")
                           U_AUTOM534(M->C5_VEND1)
                           Return(.F.)
                        Endif   

                     Else   
                        M->C5_VEND1 := POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_ZVEND2") 
                        M->C5_VEND2 := Space(06)
                     Endif
                        
                  Else   
                     M->C5_VEND1 := POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_VEND") 
                     M->C5_VEND2 := Space(06)
                  Endif   
          
             Case lHardware == .T. .And. lSuprimentos == .T.

                  If POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_VEND"  ) <> ;
                     POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_ZVEND2")
                     MsgAlert("Atenção!"                                                                       + chr(13) + chr(10) + chr(13) + chr(10) + ;
                              "Vendedor Hardware e Suprimentos são diferentes no Cadastro do Cliente."         + chr(13) + chr(10) + chr(13) + chr(10) + ;
                              "Para inclusão deste pedido, faça pedidos de Hardware e Suprimentos separados.") 
                     M->C5_VEND1 := Space(06)
                     M->C5_VEND2 := Space(06)
                     Return(.F.)
                  Else   
                     M->C5_VEND1 := POSICIONE("SA1",1,XFILIAL("SA1") + M->C5_CLIENTE + M->C5_LOJACLI, "A1_VEND"  ) 
                     M->C5_VEND2 := Space(06)
                  Endif
                  
          EndCase       

       Endif

       // ##########################################
       // Verifica se o vendedor 1 foi informado. ##
       // ##########################################
//       If Substr(wRotAnt,1,7) == "MATA410" .Or.  Substr(wRotAnt,1,8) == "AUTOM587"
//             If Empty(Alltrim(M->C5_VEND1)) .Or. Empty(Alltrim(M->C5_VEND2))
//                MsgAlert("Atenção! Vendedor 1 não informado. Campo obrigadtório!")
//                Return(.F.)
//             Endif
//          Endif
//       Endif      

       // #####################################################################################################################################
       // Jean Rehermann - 23/06/2014 - Tarefa #8459 - Validar campo de administradora de cartão quando forma de pagto for cartão de crédito ##
       // #####################################################################################################################################
	   If M->C5_FORMA == "2"
			If Empty( M->C5_ADM )
				MsgAlert("Informar administradora do cartão")
				Return .F.
			EndIf
		EndIf
       
       // ####################################################
       // Consiste Tipo e Valor do Frete do Pedido de Venda ##
       // ####################################################
       If !CPDVA_FRETE()       
          Return .F.
       Endif   

       // ###########################################################
       // Consiste o % de Comissão dos produtos do Pedido de Venda ##
       // ###########################################################

       // ##############################################################################################################################################
       // Por solicitação do Sr. Roger no dia 09/11/2012, foi solicitado que não fosse mais consistido o % de comissão na gravação do Pedido de Venda ##
       // PV_COMISSAO()                                                                                                                               ##
       // ##############################################################################################################################################

//       If Select("T_CONTATO") > 0
//          T_CONTATO->( dbCloseArea() )
//       EndIf
//
//       cSql := ""
//       cSql := "SELECT AC8_CODCON "
//       cSql += "  FROM " + RetSqlName("AC8010")
//       cSql += " WHERE AC8_CODENT   = '" + Alltrim(M->C5_CLIENTE) + Alltrim(M->C5_LOJACLI) + "'"
//       cSql += "   AND R_E_C_D_E_L_ = ''"         
//
//       cSql := ChangeQuery( cSql )
//       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTATO", .T., .T. )
//
//       DbSelectArea("T_CONTATO")
//
//       If EOF()
//          MsgAlert("Atenção !!" + chr(13) + chr(13) + "Cliente Informado não possui indicação de Contato." + chr(13) + "Necessário informar primeiramente o contato para utilização deste Cliente.")
//          Return .F.
//       Endif
//
//       // ##################################################################
//       // Verifica se pelo menos um dos contatos é um contato de cobrança ##
//       // ##################################################################
//       lCobranca := .F.
//       T_CONTATO->( DbGoTop() )
//       WHILE !T_CONTATO->( EOF() )
//
//          If Select("T_COBRANCA") > 0
//             T_COBRANCA->( dbCloseArea() )
//          EndIf
//
//          csql := ""
//          cSql := "SELECT U5_CODCONT, "
//          cSql += "       U5_NIVEL    "
//          cSql += "  FROM " + RetSqlName("SU5010")
//          cSql += " WHERE U5_CODCONT = '" + Alltrim(T_CONTATO->AC8_CODCON) + "'"
//
//          cSql := ChangeQuery( cSql )
//          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COBRANCA", .T., .T. )
//          
//          If Alltrim(T_COBRANCA->U5_NIVEL) == "08"
//             lCobranca := .T.
//             Exit
//          Endif
//          
//          T_CONTATO->( DbSkip() )
//          
//       ENDDO
//       
//       If !lCobranca
//          MsgAlert("Contato do cliente não é um contato de Cobrança. Verifique o cadastro de Contatos.")
//          Return .F.
//       Endif

       // ################################################
       // Verifica os códigos dos vendedores informados ##
       // ################################################
       For nContar = 1 to 5
           j := Strzero(nContar,1)

           If !Empty(Alltrim(M->C5_VEND&j))       
           
              If Len(Alltrim(M->C5_VEND&j)) < 6
                 xVendedor := Strzero(INT(VAL(M->C5_VEND&j)),6)
              Else
                 xVendedor := Alltrim(M->C5_VEND&j)
              Endif   
           
              If Select("T_VENDEDOR") > 0
                 T_VENDEDOR->( dbCloseArea() )
              EndIf

              csql := ""
              csql := "SELECT A3_COD, "
              csql += "       A3_NOME "
              cSql += "  FROM " + RetSqlName("SA3010")
              csql += " WHERE A3_COD = '" + ALLTRIM(xVendedor) + "'"
          
              cSql := ChangeQuery( cSql )
              dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

              If T_VENDEDOR->( EOF() )
                 MsgAlert("Vendedor (" + Str(nContar,1) + ") não é válido. Verifique!")
                 Return .F.
              Endif
           Endif
       Next nContar

       // ##################################################################################
       // Verifica se a condição de pagamento utilizada é do tipo 9.                      ##
       // Caso for, consiste se foram informados os vencimentos e os valores das parcelas ##
       // ##################################################################################
       If Select("T_CONDICAO") > 0
          T_CONDICAO->( dbCloseArea() )
       EndIf

       cSql := ""   
       cSql := "SELECT E4_CODIGO, "
       cSql += "       E4_TIPO    "
       cSql += "  FROM " + RetSqlName("SE4010")
       cSql += " WHERE E4_CODIGO = '" + ALLTRIM(M->C5_CONDPAG) + "'"
   
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONDICAO", .T., .T. )

       If !T_CONDICAO->( EOF() )
   
          If T_CONDICAO->E4_TIPO == "9"
          
             If Empty(M->C5_DATA1) .AND. EMPTY(M->C5_DATA2) .AND. EMPTY(M->C5_DATA3) .AND. EMPTY(M->C5_DATA4)
                MsgAlert("Atenção !" + chr(13) + chr(13) + "Datas de vencimento do pedido não foram informadas." + chr(13) + chr(13) + "Verifique !")
                Return .F.
             Endif
          
             If (M->C5_PARC1 + M->C5_PARC2 + M->C5_PARC3 + M->C5_PARC4) == 0
                MsgAlert("Atenção !" + chr(13) + chr(13) + "Valores do parcelamento do pedido não foram informados." + chr(13) + chr(13) + "Verifique !")
                Return .F.
             Endif

             // ####################################################################################
             // Verifica se o valor total do desdobramento confere com o valor total dos produtos ##
             // ####################################################################################
             nTProdutos := 0
             For nContar = 1 to Len(aCols)
                 nTProdutos := nTProdutos + aCols[nContar,_TotPedido]
             Next nContar

             If (M->C5_PARC1 + M->C5_PARC2 + M->C5_PARC3 + M->C5_PARC4) <> (nTProdutos + M->C5_FRETE + M->C5_DESPESA)
                MsgAlert("Atenção !" + chr(13) + chr(13) + "Total do desdobramento das pacelas informado não confere com o valor total do pedido." + chr(13) + chr(13) + "Verifique !")
                Return .F.
             Endif

          Else
          
             M->C5_DATA1 := Space(08)
             M->C5_DATA2 := Space(08)
             M->C5_DATA3 := Space(08)
             M->C5_DATA4 := Space(08)
             M->C5_PARC1 := 0
             M->C5_PARC2 := 0
             M->C5_PARC3 := 0
             M->C5_PARC4 := 0
          
          Endif
       
       Endif
      
      // ####################################################################################################
      // Verifica se o Pedido de Venda é de remessa para demosntração. (Verificação pelo TES dos Produtos) #3
      // Se for, verifica se houve a informação da data prevista de retorno dos produtos.                  ##
      // Se não estiver informado, abre janela para o usuário informar a data prevista.                    ##
      // ####################################################################################################
      __Posicao := 0
      __Tes     := ""

      // Localiza a posição da Data de Devolução
      For nPosicao = 1 to Len(aHeader)
          If Alltrim(aHeader[nPosicao,02]) == "C6_DTADEV"
             __Posicao := nPosicao
             Exit
          Endif
      Next nPosicao
             
      // Localiza a posição do TES
      For nPosicao = 1 to Len(aHeader)
          If Alltrim(aHeader[nPosicao,02]) == "C6_TES"
             __Tes := nPosicao
             Exit
          Endif
      Next nPosicao

      For nPosicao = 1 to Len(aCols)
         If aCols[nPosicao,__Tes]$('523#542')
            If aCols[nPosicao,__Posicao] == Ctod("  /  /    ")
               lBloqueia := .T.
               Exit
            Endif
         Endif
      Next nPosicao
      
      If lBloqueia 
         U_AUTOM135(2, M->C5_NUM, M->C5_FILIAL, __Posicao, __Tes)
      Endif
    Endif
	
	If _nPc > 0 .And. _nIt > 0 .And. ( INCLUI .Or. ALTERA ) // Verifico se existem os campos customizados e se operação é inclusão ou alteração
	
		For _nX := 1 To _nItens // Percorrendo todos os itens do aCols
			
			_nDel := Len( aHeader ) + 1
			_lDel := aCols[ _nX, _nDel ] // Verificando de a linha está deletada
		
            // ##############################################################
            // Se linha não estiver deletada, continuo considerando o item ##
            // ##############################################################
			If !_lDel 

				_cPd := aCols[ _nX, _nPd ] // Código do Produto
				_cPc := aCols[ _nX, _nPc ] // Pedido de compras informado
				_cIt := aCols[ _nX, _nIt ] // Item do pedido de compras informado
				
				If !Empty( AllTrim( _cPc ) ) .And. !Empty( AllTrim( _cIt ) ) .And. _lRet // Caso exista PC + Item informado e a validação ainda esteja OK
				
					_cQuery := "SELECT * FROM " + RetSqlName("SC7")  + " WHERE "
					_cQuery += "C7_FILIAL      = '" + xFilial("SC7") + "' "
					_cQuery += "AND D_E_L_E_T_ = ' ' "
					_cQuery += "AND C7_NUM     = '" + _cPc + "' "
					_cQuery += "AND C7_ITEM    = '" + _cIt + "' "
					_cQuery += "AND C7_PRODUTO = '" + _cPd + "' "
					
					If Select("C6C7") > 0
						C6C7->( dbCloseArea() )					
					EndIf
					
					dbUseArea( .T., "TOPCONN", TCGenQry( ,,_cQuery ), "C6C7", .F., .T. ) // Verificar se existe realmente o PC para o produto x cliente
					
					If C6C7->( Eof() ) // Caso não exista nenhum, avisar o operador e não permitir continuar o processo de inclusão/alteração
						MsgAlert("Selecione o pedido de compra correto no item "+ StrZero( _nX, TamSx3("C6_ITEM")[1] ) )
						_lRet := .F.  // Quando este flag for falso, não valida mais nenhum item e não permite continuar operação
						Exit
					EndIf
					
					C6C7->( dbCloseArea() )
				
				EndIf

/*
                // Verifica se o grupo de produtos permite Lacre na Automatech.
                // Se permite, verifica se usuário informou Sim/Não no produto para o Campo LACRE
                __Produto := aScan(aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
                __Lacre   := aScan(aHeader,{|x| AllTrim(x[2])=="C6_LACRE"})

                If Select("T_LACRE") > 0
                   T_LACRE->( dbCloseArea() )
                EndIf

                cSql := "SELECT A.B1_COD  ,"
                cSql += "       A.B1_GRUPO,"
                cSql += "       B.BM_GRUPO,"
                cSql += "       B.BM_LACRE "
                cSql += "  FROM " + RetSqlName("SB1") + " A, "
                cSql += "       " + RetSqlName("SBM") + " B  "
                cSql += " WHERE A.B1_COD     = '" + Alltrim(aCols[n,__Produto]) + "'"
                cSql += "   AND A.D_E_L_E_T_ = ''"  
                cSql += "   AND A.B1_GRUPO   = B.BM_GRUPO"
                cSql += "   AND B.D_E_L_E_T_ = ''"

                cSql := ChangeQuery( cSql )
                dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_LACRE", .T., .T. )

                If T_LACRE->BM_LACRE == "S"
                   If Empty(aCols[n,__Lacre])
					  MsgAlert("Indicação de Lacre Automatech não informado para o produto " + aCols[n,__Produto] )
 					  _lRet := .F.
					  Exit
				   Endif
				Endif

*/
			
			EndIf
			
		Next _nX

	EndIf
	
	RestArea( _aArea )

Return _lRet

// ####################################################################
// Função que consiste o Tipo e Valor do Frete da Proposta Comercial ##
// ####################################################################
Static Function CPDVA_FRETE()

   Local cSql       := ""
   Local nPosicao   := 0
   Local nTotPedido := 0

   // ########################################################################################################################
   // Regra para a Consistência                                                                                             ##
   // -------------------------                                                                                             ##
   // Indicação de Frete CIF somente se o valor da Proposta Comercial for > R$ 1.500,00                                     ##
   // Se Cidade do Cliente = Porto Alegre, Frete >= 15,00 e CIF ou Frete = 0 e FOB                                          ##
   // Se Cidade do Cliente <> Porto Alegre mas UF = RS, Frete >= 30,00 e CIF ou Frete = 0 e FOB                             ##
   // Se Cidade do Cliente fora da UF RS e não for um dos estados da região Norte, Frete >= 45,00 e CIF ou Frete = 00 e FOB ##
   // Se Estado for da região Norte, Frete >= 60,00 e CIF ou Frete = 0 e FOB                                                ##
   // ########################################################################################################################

   // ############################################################################################################################
   // 06/11/2012 - Por solicitação do Roger, foi pedido para não testar mais a rotina do Frete no Pedido de Venda por enquanto. ##
   // ############################################################################################################################
   Return .T.

   // ##################################
   // Pesquisa os parâmetros de frete ##
   // ##################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_FILIAL," 
   cSql += "       ZZ4_CODI  ,"
   cSql += "       ZZ4_FTOT  ,"
   cSql += "       ZZ4_FNRS  ,"
   cSql += "       ZZ4_FFRS  ,"
   cSql += "       ZZ4_FNNO  ,"
   cSql += "       ZZ4_FRNO   "
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If T_PARAMETROS->( EOF() )
      Return .T.
   Endif

   // ##################################################################
   // Pesquisa dados do cliente para geração da consistência do Frete ##
   // ##################################################################
   If Select("T_CLIENTE") > 0
      T_CLIENTE->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT A1_COD , "
   cSql += "       A1_LOJA, "
   cSql += "       A1_EST , "
   cSql += "       A1_MUN   "
   cSql += "  FROM " + RetSqlName("SA1")
   cSql += " WHERE A1_COD     = '" + Alltrim(M->C5_CLIENTE) + "'"
   cSql += "   AND A1_LOJA    = '" + Alltrim(M->C5_LOJACLI) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

   // ##############################################################
   // Pesquisa o Valor Total do Pedido de Venda para consistência ##
   // ##############################################################
   nPosicao := 0

   // ##########################################
   // Localiza a posição da Data de Devolução ##
   // ##########################################
   For nPosicao = 1 to Len(aHeader)
       If Alltrim(aHeader[nPosicao,02]) == "C6_VALOR"
          Exit
       Endif
   Next nPosicao

   nTotPedido := 0
   For nContar = 1 to Len(acols)
       nTotPedido := nTotPedido + aCols[nContar,nPosicao]
   Next nContar    

   // ###############
   // Regra geral. ##
   // ###############
   If nTotpedido > T_PARAMETROS->ZZ4_FTOT
      Return .T.
   Endif
      
   If Alltrim(M->C5_TPFRETE) == "F"
      Return .T.
   Endif

   If Alltrim(T_CLIENTE->A1_EST) == "RS"
      If Alltrim(T_CLIENTE->A1_MUN) == "PORTO ALEGRE"
         If Alltrim(M->C5_TPFRETE) == "C"
            If M->C5_FRETE < T_PARAMETROS->ZZ4_FNRS
               MsgAlert("Atenção !! Valor do Frete não pode ser menor que R$ " + Alltrim(Str(T_PARAMETROS->ZZ4_FNRS,10,02)) + ". Verifique o valor do frete do Pedido de Venda.")
               Return .F.
            Endif   
         Endif
      Else
         If Alltrim(M->C5_TPFRETE) == "C"
            If M->C5_FRETE < T_PARAMETROS->ZZ4_FFRS
               MsgAlert("Atenção !! Valor do Frete não pode ser menor que R$ " + Alltrim(Str(T_PARAMETROS->ZZ4_FFRS,10,02)) + ". Verifique o valor do frete do Pedido de Venda.")
               Return .F.
            Endif   
         Endif                    
      Endif
   Else
      If Alltrim(T_CLIENTE->A1_EST)$("RR#AM#AC#RO#PA#AP#TO")
         If Alltrim(M->C5_TPFRETE) == "C"
            If M->C5_FRETE < T_PARAMETROS->ZZ4_FRNO
               MsgAlert("Atenção !! Valor do Frete não pode ser menor que R$ " + Alltrim(Str(T_PARAMETROS->ZZ4_FRNO,10,02)) + ". Verifique o valor do frete do Pedido de Venda.")
               Return .F.
            Endif   
         Endif                    
      Else
         If Alltrim(M->C5_TPFRETE) == "C"
            If M->C5_FRETE < T_PARAMETROS->ZZ4_FNNO
               MsgAlert("Atenção !! Valor do Frete não pode ser menor que R$ " + Alltrim(Str(T_PARAMETROS->ZZ4_FNNO,10,02)) + ". Verifique o valor do frete do Pedido de Venda.")
               Return .F.
            Endif   
         Endif                    
      Endif
   Endif
         
Return .T.

// ####################################################################
// Função que consiste o % de comissão do produto no Pedido de Venda ##
// ####################################################################
Static Function PV_COMISSAO()

   Local cSql          := ""
   Local cComissao     := 0
   Local cBaseComi     := 0
   Local nContar       := 0
   Local nposItem      := 0
   Local nPosProdu     := 0
   Local nPosNome      := 0
   Local nPosComis     := 0
   Local _dar_mensagem := .F.

   Private oComissao

   Private aComissao   := {}

   // ##############################
   // Pesquisa o tipo de Vendedor ##
   // ##############################
   If Select("T_VENDEDOR") > 0
      T_VENDEDOR->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A3_COD  , "
   cSql += "       A3_TIPOV  "
   cSql += "  FROM " + RetSqlName("SA3")
   cSql += " WHERE A3_COD = '" + Alltrim(M->C5_VEND1) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )
   
   If T_VENDEDOR->( EOF() )
      Return 0
   Endif
   
   // #############################################################################################
   // Pesquisa parametrizador Automatech para capturar o % de comissão para os Gerentes de Venda ##
   // #############################################################################################
   If Select("T_PARAMETRO") > 0
      T_PARAMETRO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZZ4_COMIS FROM " + RetSqlName("ZZ4010")
      
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETRO", .T., .T. )

   If T_PARAMETRO->( EOF() )
      cBaseComi := 0
   Else
      cBaseComi := T_PARAMETRO->ZZ4_COMIS
   Endif      

   // ########################################################################
   // Pesquisa a posição do campo produto valor total da proposta comercial ##
   // ########################################################################
   For nPosItem = 1 to Len(aHeader)
       If Alltrim(aHeader[nPosItem,02]) == "C6_ITEM"
          Exit
       Endif
   Next nPosItem

   For nPosProdu = 1 to Len(aHeader)
       If Alltrim(aHeader[nPosProdu,02]) == "C6_PRODUTO"
          Exit
       Endif
   Next nPosProdu

   For nPosNome = 1 to Len(aHeader)
       If Alltrim(aHeader[nPosNome,02]) == "C6_DESCRI"
          Exit
       Endif
   Next nPosNome

   For nPosComis = 1 to Len(aHeader)
       If Alltrim(aHeader[nPosComis,02]) == "C6_COMIS1"
          Exit
       Endif
   Next nPosComis

   // ######################
   // Consiste a comissão ##
   // ######################
   For nContar = 1 to Len(aCols)

       // Pesquisa o Grupo do Produto
       If Select("T_GRUPO") > 0
          T_GRUPO->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT A.B1_GRUPO, "
       cSql += "       B.BM_GRUPO, "
       cSql += "       B.BM_COMIS  "
       cSql += "  FROM " + RetSqlName("SB1") + " A, " 
       cSql += "       " + RetSqlName("SBM") + " B  "
       cSql += " WHERE A.B1_GRUPO   = B.BM_GRUPO"
       cSql += "   AND A.B1_COD     = '" + Alltrim(aCols[nContar,nPosProdu]) + "'"
       cSql += "   AND A.D_E_L_E_T_ = ''"
       cSql += "   AND B.D_E_L_E_T_ = ''"
      
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_GRUPO", .T., .T. )
   
       If !T_GRUPO->( EOF() )
          cComissao := T_GRUPO->BM_COMIS
       Endif   

       // ########################################################
       // Verifica se existe exceção de comissão para o produto ##
       // ########################################################  
       If Select("T_COMISSAO") > 0
          T_COMISSAO->( dbCloseArea() )
       EndIf

       cSql := ""
       cSql := "SELECT ZZ5_GRUPO , "
       cSql += "       ZZ5_PRODUT, "
       cSql += "       ZZ5_COMIS   "
       cSql += "  FROM " + RetSqlName("ZZ5")
       cSql += " WHERE ZZ5_GRUPO  = '" + Alltrim(T_GRUPO->B1_GRUPO)        + "'"
       cSql += "   AND ZZ5_PRODUT = '" + Alltrim(aCols[nContar,nPosProdu]) + "'"
       cSql += "   AND ZZ5_DELETE = ''"
      
       cSql := ChangeQuery( cSql )
       dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMISSAO", .T., .T. )

       If !T_COMISSAO->( EOF() )
          If T_VENDEDOR->A3_TIPOV == "1"
             cComissao := T_COMISSAO->ZZ5_COMIS
          Else
             If cBaseComi == 0
                cComissao := T_COMISSAO->ZZ5_COMIS         
             Else
                cComissao := Round(((T_COMISSAO->ZZ5_COMIS * cBaseComi) / 100),1)
             Endif   
          Endif
       Else
          If T_VENDEDOR->A3_TIPOV == "1"
             cComissao := T_GRUPO->BM_COMIS
          Else
             If cBaseComi == 0      
                cComissao := T_GRUPO->BM_COMIS      
             Else
                cComissao := Round(((T_GRUPO->BM_COMIS * cBaseComi) / 100),1)
              Endif
          Endif   
       Endif

       If aCols[nContar,nPosComis] > cComissao
          aAdd( aComissao, { aCols[nContar,nPosItem] ,;
                             aCols[nContar,nPosProdu],;
                             aCols[nContar,nPosNome] ,;
                             Str(aCols[nContar,nPosComis],06,02),;
                             Str(cComissao,06,02) } )
          _dar_mensagem := .T.
       Endif
       
   Next nContar    

   // #######################################################################################
   // Em 29/12/2016, Sr. Roger solicitou que esta funcionalidade fosse retirada do Sistema ##
   // #######################################################################################
//   If _dar_mensagem 
//
//      DEFINE MSDIALOG oComissao TITLE "Consistência % Comissão" FROM C(178),C(181) TO C(465),C(833) PIXEL
//
//      @ C(005),C(005) Say "Atenção ! Foi verificado que existem produtos com divergência da informação do % de comissão do Pedido de Venda." Size C(285),C(008) COLOR CLR_BLACK PIXEL OF oComissao
//      @ C(014),C(005) Say "Serão atualizados os percentuais de comissão automaticamente conforme demonstrativo abaixo."                      Size C(236),C(008) COLOR CLR_BLACK PIXEL OF oComissao
//
//      @ C(128),C(283) Button "Continuar ..." Size C(037),C(012) PIXEL OF oComissao ACTION( SaiComis(nPosItem, nPosProdu, nPosComis) )
//
//      oBrowse := TCBrowse():New( 025 , 005, 400, 135,,{'Item', 'Código', 'Descrição dos Produtos', 'Comissão Informada', 'Comissão Parametrizada'},{20,50,50,50},oComissao,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
//   
//      // Seta vetor para a browse                            
//      oBrowse:SetArray(aComissao) 
//    
//      // Monta a linha a ser exibina no Browse
//      oBrowse:bLine := {||{ aComissao[oBrowse:nAt,01],;
//                            aComissao[oBrowse:nAt,02],;
//                            aComissao[oBrowse:nAt,03],;
//                            aComissao[oBrowse:nAt,04],;
//                            aComissao[oBrowse:nAt,05],;
//                          } }
//
//      ACTIVATE MSDIALOG oComissao CENTERED 
//
//   Endif   
   
Return(.T.)

// ####################################################
// Função que sai da tela de informação de comissões ##
// ####################################################
Static Function SAICOMIS( _PosItem, _PosCodi, _PosComi)

   Local _Contar  := 0
   Local _Corrige := 0
   
   For _Contar = 1 to Len(aComissao)
   
       For _Corrige = 1 to Len(aCols)
       
           If aCols[_Corrige,_PosItem] == aComissao[_Contar,01] .And. aCols[_Corrige,_PosCodi] == aComissao[_Contar,02]
              aCols[_Corrige,_PosComi] := VAL(aComissao[_Contar,05])
              Exit
           Endif
           
       Next _Corrige
       
   Next _Contar
   
   oComissao:End()
   
Return(.T.)