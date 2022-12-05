#include "protheus.ch"
#DEFINE  ENTER CHR(13)+CHR(10)

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: PE_MATA410.PRW                                                      ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Cesdar Mussi e Harald Hans Löschenkohl                              ##
// Data......: 19/04/2017                                                          ##
// Objetivo..: Ponto de Entrada disparado na gravação do pedido de venda.          ##
//             Tratamento dos Status dos Pedidos de Venda.                         ##   
// Parâmetros: Sem Parâmetros                                                      ##
// Retorno...: Sem Retorno                                                         ##
// ##################################################################################

User Function Mta410t()

   // ###########################
   // Guardam Areas Anteriores ##
   // ###########################
   Local aAreaAtu        := GetArea()
   Local aAreaSC5        := SC5->(GetArea())
   Local aAreaSC6        := SC6->(GetArea())
   Local aAreaSB1        := SB1->(GetArea())
   Local aAreaSB2        := SB2->(GetArea())
   Local aAreaSF4        := SF4->(GetArea())
   Local aAreaSC2        := SC2->(GetArea())
   Local wRotAnt         := Alltrim(FUNNAME())
   Local cCodFil         := SC5->C5_FILIAL
   Local cCodPed         := SC5->C5_NUM
   Local _lBlqItm        := .f.                 // Controla se algum item foi bloqueado
   Local _lBlqTot        := .f.                 // Controla o bloqueio total do pedido de venda
   Local _cPedCli        := ""
   Local __Ordem         := ""                  // Variável que conterá o nºs das ordens de compra do cliente
   Local nMrgMin         := GetMv("AUT_QTG003") // Margem minima para bloqueio
   Local nLimite         := GetMv("AUT_QTG002") // Delimitador de % da margem
   Local lQtgBlq         := GetMv("AUT_QTG001") // Ativa ou desativa o bloqueio por margem
   Local nMrgMinEtq      := GetMv("AUT_QTG004") // Margem minima para bloqueio para produtos etiqueta
   Local nValImp         := 0
   Local _nPrcVen        := 0
   Local _nTotItm        := 0
   Local nPpis 	         := GetMv("MV_TXPIS")   // Percentual de PIS
   Local nPcof 	         := GetMv("MV_TXCOF")	  // Percentual de COFINS
   Local nPAdm 	         := GetMv("MV_CUSTADM") // Percentual de Custo Administrativo
   Local nPFre 	         := GetMv("MV_CUSTFRE") // Percentual de Frete

   // #############################################
   // Jean Rehermann - 23/01/2014 - Tarefa #8459 ##
   // #############################################
   Local nPCCC := GetMv("MV_CUSTCC")            // Parâmetro que define o percentual de custo com cartão de crédito: nPCCC
   Local cCPCC := GetMv("MV_CONPGCC")           // Condições de pagamento com cartão de credito
   Local cCond := M->C5_CONDPAG

   Local _nSumCust       := 0                   // Soma dos custos que compoe o valor de venda
   Local nCustTotFin     := 0                   // Custo financeiro total de aquisicao
   Local _nValorTot      := 0
   Local __Tipo_Frete    := ""                  // Guarda o tipo de frete para consistência da regra do frete
   Local __Valor_Frete   := 0                   // Valor Total do Frete
   Local __Valor_Total   := 0                   // Guarda o valor total do pedido de venda
   Local cSql            := ""
   Local cSql            := ""
   Local nPosicao        := 0
   Local nTotPedido      := 0
   Local __Cliente       := ""
   Local __Loja          := ""
   Local __Altera_Status := .F.
   Local __Primeiro      := .T.
   Local __TaxaDolar     := 0
   Local cSql            := ""
   Local _lTipoN         := M->C5_TIPO == "N" // Jean Rehermann - Solutio IT - 23/11/15 - Para margem apenas quando for venda
   Local K_Margem        := 0                 // Recebe o cálculo da margem em caso do programa ser chamado pela proposta Comercial

   Local cParcelas       := ""
   Local nParcelas       := 0
   Local vParcelas       := 0
   Local xResultado      := 0
   Local lBloqueiaCond   := .F.

   Private _QnAliqIcm  := 0
   Private _QnValIcm   := 0
   Private _QnBaseIcm  := 0
   Private _QnValIpi   := 0
   Private _QnBaseIpi  := 0
   Private _QnValMerc  := 0
   Private _QnValSol   := 0
   Private _QnValDesc  := 0
   Private _QnPrVen    := 0
   Private _lQtdExata  := .F.

   U_AUTOM628("PE_MATA410")

   // ################################
   // Grava Campos do Quoting Tools ##
   // ################################

   Conout("nOME DA FUNÇÃO QUE CHEGOU NO PE_MATA410: " + wRotAnt)


   IF ( wRotAnt $ "MATA410|AUTOM243|RPC" .And. INCLUI)
	
      // ###############################################################################
	  // Elimina qualquer bloqueio do pedido de venda para nova avaliação de bloqueio ##
	  // ###############################################################################
	  Reclock( "SC5", .F. )
	  SC5->C5_BLQ := ""
	  SC5->( Msunlock() )

      // #########################################################################
      // Inicializa a variável que controla o bloqueio total do pedido de venda ##
      // #########################################################################
      _lBlqTot := .F.      

      // ##########################################################
      // Posiciona os produtos do pedido de venda para avaliação ##
      // ##########################################################
	  DbSelectArea("SC6")
	  DbSetOrder(1)
	  DbSeek( xfilial("SC6")+cCodPed )

	  Do While SC6->C6_NUM = cCodPed .And. SC6->C6_FILIAL == xfilial("SC6")
		
         // ##################################################################
         // Inicializa a variável que controla o bloqueio do item do pedido ##
         // ##################################################################
         _lBlqItm := .F.

         // #################################################################################
         // Libera o produto para nova avaliação de gravação dos status do pedido de venda ##
         // #################################################################################
  		 Reclock( "SC6", .F. )
         SC6->C6_QTDEMP  := 0
         SC6->C6_QTDEMP2 := 0
		 SC6->C6_BLQ     := ""

         // SC6->C6_STATUS  := IIF(cEmpAnt == "03", "01", "")

         Do Case

            Case cEmpAnt == "01"

          	     IF (LEFT(SC6->C6_PRODUTO,2) == "02" .Or. LEFT(SC6->C6_PRODUTO,2) == "03")
                    SC6->C6_STATUS := "01"                                                
                 Else   
                    SC6->C6_STATUS := ""
                 Endif                                                   

            Case cEmpAnt == "03"
                 SC6->C6_STATUS := "01"
                 
            Otherwise
                 SC6->C6_STATUS := ""                 
         EndCase                 

         SC6->C6_ZTBL    := ""
		 SC6->( Msunlock() )
		
         // ############################
         // Posiciona a Tabela de TES ##
         // ############################
		 DbSelectArea("SF4")
		 DbSetOrder(1)
		 DbSeek(xfilial("SF4")+SC6->C6_TES)
		
		 DbSelectArea("SC6")
		
		 IF SF4->F4_DUPLIC = "S" .AND. SF4->F4_ESTOQUE == "S"
			
            // #########################################################################################################################################
            // Se programa foi chamado pela proposta comercial, primeiro realiza o cálculo da margem para depois atribuir o status do pedido de venda ##
            // #########################################################################################################################################
            If UPPER(ALLTRIM(wRotAnt)) == "AUTOM243" .Or. UPPER(ALLTRIM(wRotAnt)) == "RPC"
               
               If M->C5_TIPO == "N"

                  K_Margem := 0
                  K_Margem := U_AUTOM524(1               ,; // 01 - Indica a chamada pelo Pedido de Venda
                                         SC6->C6_FILIAL  ,; // 02 - Filial
                                         SC6->C6_NUM     ,; // 03 - Nº do Pedido de Venda
                                         SC6->C6_ITEM    ,; // 04 - Posição do Item no Pedido de Venda
                                         SC6->C6_PRODUTO ,; // 05 - Código do Produto
                                         0               ,; // 06 - Posição do Produto no Acols
                                         "R")               // 07 -Indica tipo de retorno

 				  dbSelectArea("SC6")
				  Reclock("SC6",.f.)
                  SC6->C6_QTGMRG := K_Margem

   	           Endif
   	           
   	        Endif

            // ###############################################################################################################################
			// Jean Rehermann - 27/02/14 - Tarefa #8453                                                                                     ##
			// Pedido referente a doacao                                                                                                    ##
			// Jean Rehermann - Solutio IT - 23/11/2015 - Incluída a validação _lTipoN pois só considera margem quando pedido for do tipo N ##
			// ###############################################################################################################################

            // ##################################################################################################
            // O bloqueio de margem apartir do dia 23/02/2017 é diferente entre produtos etiquetas e os demais ##
            // ##################################################################################################
            
            nMrgCalculada := SC6->C6_QTGMRG

            If Len(Alltrim(SC6->C6_PRODUTO)) == 17
               k_MrgMin := nMrgMinEtq
            Else
               k_MrgMin := nMrgMin
            Endif               

            // ###########################################
            // Bloqueia o registro da SC6 para gravação ##
            // ###########################################
			dbSelectArea("SC6")
			Reclock("SC6",.f.)

            // ########################################################################
            // Verifica se o pedido de venda deve ser bloqueado por margem ou doação ##
            // ########################################################################
    		If ( _lTipoN .And. lQtgBlq .And. ( nMrgCalculada < k_MrgMin ) ) .Or. SC6->C6_TES $ SuperGetMv("MV_TESDOAC",,"")

			   SC6->C6_BLQ := "S"
			   _lBlqItm    := .t.
			   _lBlqTot    := .t.
			   				
               // ##################################################################
               // Status 02 -> Aguardando liberação de margem OU Pedido de doação ##
               // ##################################################################			   
			   SC6->C6_STATUS := "02"

               // #######################################
               // Atualiza o campo de Tipo de Bloqueio ##
               // #######################################
               If SC6->C6_TES $ SuperGetMv("MV_TESDOAC",,"")
                  SC6->C6_ZTBL := Alltrim(SC6->C6_ZTBL) + "DOA-"
               Else
                  SC6->C6_ZTBL := Alltrim(SC6->C6_ZTBL) + "MRG-"
               Endif   

               // ########################################################
               // Atualiza o log de atualização de status na tabela ZZ0 ##
               // ########################################################    
			   U_GrvLogSts(xFilial("SC6"),SC6->C6_NUM, SC6->C6_ITEM, "02", "PE_MATA410 (INC)") 

			Endif
				
            // ########################################################################################
            // Verifica se bloqueia o produto do pedido de venda pela regra da condição de pagamento ##
            // ########################################################################################
            cParcelas     := Posicione( "SE4", 1, xFilial("SE4") + SC5->C5_CONDPAG, "E4_COND" ) + ","
            nParcelas     := U_P_OCCURS(cParcelas, ",", 1)
            vParcelas     := 0
            xResultado    := 0
            lBloqueiaCond := .F.

            For nContar = 1 to nParcelas
                vParcelas := vParcelas + INT(VAL(U_P_CORTA(cParcelas, ",", nContar)))
            Next nContar
               
            xResultado := Int(vParcelas / nParcelas)
               
            If xResultado <> 0
               Do Case
                  Case cEmpAnt == "01"
                       lBloqueiaCond := IIF(xResultado <= 46, .F., .T.)
                  Case cEmpAnt == "02"
                       lBloqueiaCond := IIF(xResultado <= 46, .F., .T.)
                  Case cEmpAnt == "03"
                       lBloqueiaCond := IIF(xResultado <= 33, .F., .T.)
                  Case cEmpAnt == "04"
                       lBloqueiaCond := IIF(xResultado <= 46, .F., .T.)
                  Otherwise
                       lBloqueiaCond := .F.
               EndCase                               
            Else
               lBloqueiaCond := .F.
            Endif   
                     
            If lBloqueiaCond == .T.

			   _lBlqItm       := .T.
			   _lBlqTot       := .T.
  			   SC6->C6_BLQ    := "S"
			   SC6->C6_STATUS := "02"
               SC6->C6_ZTBL   := Alltrim(SC6->C6_ZTBL) + "PAG-"

               // #####################################################
               // Grava o log de atualização de status na tabela ZZ0 ##
               // #####################################################
  		       U_GrvLogSts(xFilial("SC6"),SC6->C6_NUM, SC6->C6_ITEM, "02", "PE_MATA410 (INC)") 

  		    Endif
  		       
            // #########################################
            // Bloqueia por Frete Gratuito - SimFrete ##
            // #########################################
	        If SC6->C6_ZGRA == "S"

			   _lBlqItm       := .T.
			   _lBlqTot       := .T.
  	           SC6->C6_STATUS := "02" 
  	           SC6->C6_BLQ    := "S"
               SC6->C6_ZTBL   := Alltrim(SC6->C6_ZTBL) + "SIM-"
    
               // #####################################################
               // Grava o log de atualização de status na tabela ZZ0 ##
               // #####################################################
	           U_GrvLogSts(xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "02", "PE_MATA410")

            Endif

            // #############################################################
            // Se não houve bloqueio, libera o produto do pedido de venda ##
            // #############################################################
            If _lBlqItm == .T.
            Else

               // ######################################################
               // Status 01 - Aguardando liberação de Pedido de Venda ##
               // ######################################################
			   SC6->C6_STATUS := "01" 

               // #####################################################
               // Grava o log de atualização de status na tabela ZZ0 ##
               // #####################################################
			   U_GrvLogSts(xFilial("SC6"),SC6->C6_NUM, SC6->C6_ITEM, "01", "PE_MATA410 (INC)") // Gravo o log de atualização de status na tabela ZZ0

		    Endif

            // ##################################
            // Libera o registro da tabela SC6 ##
            // ##################################
		    MsUnlock()

		 ELSE
		 
		 
            // ###############################################################
            // Verifica se o pedido de venda deve ser bloqueado pela regra: ##
            // TES Duplicata = NÃO                                          ##
            //     Estoque   = SIM                                          ##
            // ###############################################################

  		    IF SF4->F4_DUPLIC = "N" .AND. SF4->F4_ESTOQUE == "S"

   		       Reclock( "SC6", .F. )
			   _lBlqItm       := .T.
			   _lBlqTot       := .T.
  	           SC6->C6_STATUS := "02" 
  	           SC6->C6_BLQ    := "S"
               SC6->C6_ZTBL   := Alltrim(SC6->C6_ZTBL) + "TES-"
    
               // #####################################################
               // Grava o log de atualização de status na tabela ZZ0 ##
               // #####################################################
	           U_GrvLogSts(xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "02", "PE_MATA410")
		 
               // ##################################
               // Libera o registro da tabela SC6 ##
               // ##################################
		       MsUnlock()
		          
		    Endif   
		 
		 ENDIF
		
		 DbSelectArea("SC6")
		 DBSKIP()

  	  ENDDO
	
      IF _lBlqTot
	     DbSelectArea("SC5")
	     DbSetOrder(1)
	     DbSeek( xFilial("SC5") + cCodPed )
	     Reclock( "SC5", .F. )
	     SC5->C5_BLQ := "3"
	     SC5->( Msunlock() )
	  Endif
    
      // ########################################################################################
      // Envia para o programa que verifica se o Pedido de Venda pode ser liberado quando o PV ##
      // for de remessa para conserto ou serviço (AT) ou TES 766 Dev. Conserto Garantia.       ##
      // ########################################################################################
      U_AUTOM618(cCodFil, cCodPed, 2)

      // #########################################################################################
      // Tarefa #3440 - Pedidos com AT com TES 766 (DEV TROCA GARANTIA)                         ##
      // Para pedidos de venda com esta TES (&66), devem nascer com Status 10 - Ag. Faturamento ##
      // Envia para o programa que verifica se o Pedido de Venda pode ser liberado quando  o PV ##
      // tiver TES 766 -> Dev. Conserto Garantia.                                               ##
      // #########################################################################################
      U_AUTOM618(cCodFil, cCodPed, 3)

   ENDIF

   // #############################################################################
   // Jean Rehermann - Quando houver alteração no PV preciso reavaliar os status ##
   // #############################################################################
   If wRotAnt == "MATA410" .And. ALTERA
	
	  lBlqDoa := .F.
	
      // #############################################################################
	  // Jean Rehermann - Quando houver alteração no PV preciso reavaliar os status ##
	  // #############################################################################
	  DbSelectArea("SC6")
	  DbSetOrder(1)
	  DbSeek( xfilial("SC6") + cCodPed )

	  Do While SC6->C6_NUM == cCodPed .And. SC6->C6_FILIAL == xfilial("SC6")
		
	     If SC5->C5_EXTERNO == "1"
			
			If SC6->C6_STATUS == "13" .And. !Empty( SC5->C5_NFDISTR )
               
               // #########################
               // Aguardando faturamento ##
               // #########################
			   SC6->C6_STATUS := "10" 

               // #####################################################
               // Gravo o log de atualização de status na tabela ZZ0 ##
               // #####################################################
   			   U_GrvLogSts(xFilial("SC6"),SC6->C6_NUM, SC6->C6_ITEM, "10", "PE_MATA410 (ALT)") 

			ElseIf !( SC6->C6_STATUS $ "10,13" ) .And. !Empty( SC5->C5_NFDISTR )
               
               // #########################
               // Aguardando faturamento ##
               // #########################
			   SC6->C6_STATUS := "10" 
               
               // #####################################################
               // Gravo o log de atualização de status na tabela ZZ0 ##
               // #####################################################
			   U_GrvLogSts(xFilial("SC6"),SC6->C6_NUM, SC6->C6_ITEM, "10", "PE_MATA410 (ALT)") // Gravo o log de atualização de status na tabela ZZ0

			ElseIf SC6->C6_STATUS != "13" .And. Empty( SC5->C5_NFDISTR )

               // ########################## 
               // Aguardando distribuidor ##
               // ##########################
			   SC6->C6_STATUS := "13" 
               
               // #####################################################
               // Gravo o log de atualização de status na tabela ZZ0 ##
               // #####################################################
			   U_GrvLogSts(xFilial("SC6"),SC6->C6_NUM, SC6->C6_ITEM, "13", "PE_MATA410 (ALT)") 

			EndIf
			
		Else

            // #############################################
			// Jean Rehermann - 27/02/2014 - Tarefa #8453 ##
			// #############################################
			If !( SC6->C6_STATUS $ "02,11,12,13,14" ) .And. SC6->C6_TES $ SuperGetMv("MV_TESDOAC",,"") // Pedido referente a doação
				SC6->C6_STATUS := "02" // Bloqueia na margem por ser pedido de doação
				SC6->C6_BLQ    := "S"  // Bloqueia na margem por ser pedido de doação
				lBlqDoa := .T.

                If SC6->C6_TES $ SuperGetMv("MV_TESDOAC",,"")
                   SC6->C6_ZTBL := Alltrim(SC6->C6_ZTBL) + "DOA-"
                Else
                   SC6->C6_ZTBL := Alltrim(SC6->C6_ZTBL) + "MRG-"                   
                Endif   

				U_GrvLogSts(xFilial("SC6"),SC6->C6_NUM, SC6->C6_ITEM, "02", "PE_MATA410 (ALT)") // Gravo o log de atualização de status na tabela ZZ0

//			ElseIf !( SC6->C6_STATUS $ "01,02,11,12,13,14" ) // Se aguardando liberação ou margem ou faturado ou intermediário ou cancelado, não altero o status!
			ElseIf !( SC6->C6_STATUS $ "02,11,12,13,14" ) // Se aguardando liberação ou margem ou faturado ou intermediário ou cancelado, não altero o status!

                // ################################################################################
                // Verifica se o pedido de venda deve ser bloqueado por Condição de Pagamento    ##
                // Regra a ser aplicada                                                          ##
                // 1. Somente para o Grupo de Empresa 01 - Automatech, 03 - Atech e 04  Atechpel ##
                // 2. Soma-se as parcelas e divide-se pelça quantidade de parcelas               ##
                // 3. Se o resultado para a Automatech for > 46, bloqueia                        ##
                //    Se o resultado para a AtechPel   for > 46, bloqueia                        ##
                //    Se o resultado para a Atech      for > 33, bloqueia                        ##
                // ################################################################################

                cParcelas     := Posicione( "SE4", 1, xFilial("SE4") + SC5->C5_CONDPAG, "E4_COND" ) + ","
                nParcelas     := U_P_OCCURS(cParcelas, ",", 1)
                vParcelas     := 0
                xResultado    := 0
                lBloqueiaCond := .F.

                For nContar = 1 to nParcelas
                    vParcelas := vParcelas + INT(VAL(U_P_CORTA(cParcelas, ",", nContar)))
                Next nContar
               
                xResultado := Int(vParcelas / nParcelas)
               
                If xResultado <> 0
                   Do Case
                      Case cEmpAnt == "01"
                           lBloqueiaCond := IIF(xResultado <= 46, .F., .T.)
                      Case cEmpAnt == "02"
                           lBloqueiaCond := IIF(xResultado <= 46, .F., .T.)
                      Case cEmpAnt == "03"
                           lBloqueiaCond := IIF(xResultado <= 33, .F., .T.)
                      Case cEmpAnt == "04"
                           lBloqueiaCond := IIF(xResultado <= 46, .F., .T.)
                      Otherwise
                           lBloqueiaCond := .F.
                   EndCase                               
                Else
                   lBloqueiaCond := .F.
                Endif   

                If lBloqueiaCond == .T.
   				   _lBlqItm       := .T.
   				   SC6->C6_BLQ    := "S"
			       SC6->C6_STATUS := "02" // Aguardando liberação por problema de Condição de Pagamento
                   SC6->C6_ZTBL   := Alltrim(SC6->C6_ZTBL) + "PAG-"

                   // #####################################################
                   // Grava o log de atualização de status na tabela ZZ0 ##
                   // #####################################################
	    		   U_GrvLogSts(xFilial("SC6"),SC6->C6_NUM, SC6->C6_ITEM, "02", "PE_MATA410 (INC)") 
	    		   
	    		Else   

				   SC6->C6_STATUS := "01" // Aguardando liberação
				   U_GrvLogSts(xFilial("SC6"),SC6->C6_NUM, SC6->C6_ITEM, "01", "PE_MATA410 (ALT)") // Gravo o log de atualização de status na tabela ZZ0
				   
                   // ##############################################################################################
      			   // Cesar - 24.08.2015                                                                          ##
	     		   // Encontrei um caso de um PV que , Alterado, já tinha o SC9 criado e com credito liberado ... ##
		    	   // Vamos fazer aqui uma garantia de que o pedido deva ter seu credito analisado novamente      ##
			       // ##############################################################################################
				   DbSelectArea("SC9")
				   DbSetorder(1)
	  			   DbSeek( xfilial("SC9") + SC6->C6_NUM + SC6->C6_ITEM )
	  			   IF FOUND() .And. _lTipoN // Jean Rehermann - Solutio IT - 23/11/2015 - Validar para bloquear apenas pedidos tipo N (_lTipoN)
				      // CASO ENCONTRE SC9
                      Reclock("SC9",.f.)
                      C9_BLCRED := "01"
                      MsUnlock()
                   ENDIF
   				Endif      
			EndIf
			
		EndIf
				
		SC6->( dbSkip() )
		
	EndDo
	
	// Tratamento de gravação dos memos
	
	DbSelectArea("SC5")
	DbSetOrder(1)
	DbSeek( xfilial("SC5") + cCodPed )
	RecLock("SC5",.F.)

		If lBlqDoa
			SC5->C5_BLQ := "3"
		Else
			// Jean Rehermann - 15/12/2014 - A linha abaixo estava liberando todo pedido que não fosse doação
			// C5_BLQ    := ""
		EndIf

		C5_JPCSEP := ""

	SC5->( MsUnLock())
	
	// Grava Log dos Memos gravados no pedido de vendas
	U_GrvMemo("SC5",SC5->C5_NUM,"C5_OBSI","C5_OBSI",SC5->(RECNO()),SC5->C5_OBSI,SUBSTR(CUSUARIO,7,15),Date(),time())
	
	// Fim do tratamento de gravação dos memos
	
    // #######################################################################################
    // Envia para o programa que verifica se o Pedido de Venda por der liberado quando o PV ##
    // for de remessa para conserto ou serviço (AT).                                        ##
    // #######################################################################################
    U_AUTOM618(cCodFil, cCodPed, 2)

EndIf


   IF INCLUI
	
      // #####################
      // Proposta Comercial ##
      // #####################
	  If ProcName(15) == "FT300GRV" 
		
		 // ###############################
		 // vem das Propostas Comerciais ##
		 // ###############################
		 Reclock("AD1",.f.)
		 AD1_NUMORC := SCJ->CJ_NUM
		 MsUnlock()
		
		 dbselectarea("SCK")
		 dbsetorder(1)
		 dbseek(xFilial("SCK")+SCJ->CJ_NUM)
		
		 dbselectarea("ADY")
		 dbsetorder(1)
		 dbseek(xFilial("ADY")+SCK->CK_PROPOST)
		
		 DbSelectArea("SC5")
		 DbSetorder(1)
		 DbSeek(xFilial("SC5")+cCodPed)
		
		 __Tipo_Frete  := ADY->ADY_TPFRETE
		 __Valor_Frete := ADY->ADY_FRETE
		 __Cliente     := ADY->ADY_CODIGO
		 __Loja        := ADY->ADY_LOJA
		 _lQtdExata    := Iif(ADY->ADY_QEXAT <> "S",.T.,.F.)
		
		 Reclock("SC5",.f.)
		
		 C5_VEND1   := AD1->AD1_VEND
		 C5_COMIS1  := AD1->AD1_COMIS1
		 C5_VEND2   := AD1->AD1_VEND2
		 C5_COMIS2  := AD1->AD1_COMIS2
		 C5_FRETE   := ADY->ADY_FRETE
		 C5_MENNOTA := "PEDIDO NR. " + ALLTRIM(cCodPed) + IIF(!EMPTY(ALLTRIM(ADY->ADY_OC)), " - OC: " + ALLTRIM(ADY->ADY_OC), "" )
		 C5_OBSI	  := ADY->ADY_OBSI
		 C5_TRANSP  := ADY->ADY_TRANSP
		 C5_TPFRETE := ADY->ADY_TPFRETE
		
		 // Atualiza os campos de Vencimento e Valo para conidições de pagamento do tipo 9
		 C5_DATA1   := SCJ->CJ_DATA1
		 C5_PARC1   := SCJ->CJ_PARC1
		 C5_DATA2   := SCJ->CJ_DATA2
		 C5_PARC2   := SCJ->CJ_PARC2
		 C5_DATA3   := SCJ->CJ_DATA3
		 C5_PARC3   := SCJ->CJ_PARC3
		 C5_DATA4   := SCJ->CJ_DATA4
		 C5_PARC4   := SCJ->CJ_PARC4
		
		 MsUnlock()
		 
		 // ###################################################
		 // Grava Log dos Memos gravados no pedido de vendas ##
		 // ###################################################
		 U_GrvMemo("SC5",SC5->C5_NUM,"C5_OBSI","ADY_OBSI",ADY->(RECNO()),ADY->ADY_OBSI,SUBSTR(CUSUARIO,7,15),Date(),time())
		
		 _cPedCli   := AD1->AD1_OC
		 
		 // ################################################################################################################################
		 // Pesquisa a condição de pagamento e verifica se é permitido impressão de Boleto Bancário no encerramento da Proposta Comercial ##
		 // ################################################################################################################################
		 If Select("T_CONDICAO") > 0
			T_CONDICAO->( dbCloseArea() )
		 EndIf
		
		 cSql := ""
		 cSql := "SELECT E4_CODIGO,"
		 cSql += "       E4_BVDA   "
		 cSql += "  FROM " + RetSqlName("SE4")
		 cSql += " WHERE E4_CODIGO  = '" + Alltrim(SC5->C5_CONDPAG) + "'"
		 cSql += "   AND E4_FILIAL  = ''"
		 cSql += "   AND D_E_L_E_T_ = ''"
		
		 cSql := ChangeQuery( cSql )
		 dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONDICAO", .T., .T. )
		
		 If !T_CONDICAO->( EOF() )
			
			If T_CONDICAO->E4_BVDA == "S"
			   IMP_BOLETO(SC5->C5_CONDPAG, SC5->C5_CLIENTE, SC5->C5_LOJACLI)
			Endif
			
		 Endif
		
	 ElseIf wRotAnt == "TECA450"
		
		DbSelectArea("AB6")
		DbSetOrder(1)
		DbSeek(xFilial("AB6")+LEFT(SC6->C6_NUMOS,6))
		
		DbSelectArea("SC5")
		DbSetorder(1)
		DbSeek(xFilial("SC5")+cCodPed)
		Reclock("SC5",.f.)
		C5_OBSI	:= M->AB6_MINTER //MSMM(M->AB6_MEMO5)
		C5_MENNOTA := "REF. OS NR.: " + LEFT(SC6->C6_NUMOS,6)
		MsUnlock()
		
		// Grava Log dos Memos gravados no pedido de vendas
		//U_GrvMemo("SC5",SC5->C5_NUM,"C5_OBSI","AB6_MEMO5",LEFT(SC6->C6_NUMOS,6),MSMM(M->AB6_MEMO5),SUBSTR(CUSUARIO,7,15),Date(),time())
		U_GrvMemo("SC5",SC5->C5_NUM,"C5_OBSI","AB6_MINTER",AB6->( Recno() ),M->AB6_MINTER,SUBSTR(CUSUARIO,7,15),Date(),time())
		
     Endif
	
   Endif

   // ########################################################################################################
   // Se inclusão e proposta comercial, captura o valor total do pedido de venda para consistência do Frete ##
   // ########################################################################################################
   If Inclui
	  
	  // #####################
      // Proposta Comercial ##
      // #####################
	  If ProcName(15) == "FT300GRV" 
		
		 // Pesquisa o valor da moeda (Dolar) do dia
		 If Select("T_DOLAR") > 0
			T_DOLAR->( dbCloseArea() )
		 EndIf
		
		 cSql := ""
		 cSql := "SELECT M2_MOEDA2 "
		 cSql += "  FROM " + RetSqlName("SM2")
		 cSql += " WHERE M2_DATA = CONVERT(DATETIME,'" + Dtoc(Date()) + "', 103)"
		 cSql += "   AND D_E_L_E_T_ = ''"
		
		 cSql := ChangeQuery( cSql )
		 dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DOLAR", .T., .T. )
		
		 __TaxaDolar := T_DOLAR->M2_MOEDA2
		 
		 // #############################################
		 // Pesquisa os Produtos da Proposta Comercial ##
		 // #############################################
		 If Select("T_PEDIDO") > 0
			T_PEDIDO->( dbCloseArea() )
		 EndIf
		
		 cSql := ""
		 cSql := "SELECT ADZ_MOEDA,"
		 cSql += "       ADZ_TOTAL "
		 cSql += "  FROM " + RetSqlName("ADZ")
		 cSql += " WHERE ADZ_FILIAL = '" + Alltrim(xFilial("SCK")) + "'"
		 cSql += "   AND ADZ_PROPOS = '" + Alltrim(SCK->CK_PROPOST)    + "'"
		 cSql += "   AND D_E_L_E_T_ = ''"
		
		 cSql := ChangeQuery( cSql )
		 dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )
		
		 // ##############################################
		 // Calcula o valor total da Proposta Comercial ##
		 // ##############################################
		 __Valor_Total := 0
		
		 T_PEDIDO->( DbGoTop() )
		
		 WHILE !T_PEDIDO->( EOF() )
			
		    If T_PEDIDO->ADZ_MOEDA == "1"
				__Valor_Total := __Valor_Total + T_PEDIDO->ADZ_TOTAL
			Else
				__Valor_Total := __Valor_Total + (T_PEDIDO->ADZ_TOTAL * __TaxaDolar)
			Endif
			
			T_PEDIDO->( DbSkip() )
			
		 ENDDO
		
		 // --------------------------------------------------------------------------------------------------------------------- *
		 // Regra para a Consistência                                                                                             *
		 // -------------------------                                                                                             *
		 // Indicação de Frete CIF somente se o valor da Proposta Comercial for <= R$ 1.500,00                                    *
		 // Se Cidade do Cliente = Porto Alegre, Frete >= 15,00 e CIF ou Frete = 0 e FOB                                          *
		 // Se Cidade do Cliente <> Porto Alegre mas UF = RS, Frete >= 30,00 e CIF ou Frete = 0 e FOB                             *
		 // Se Cidade do Cliente fora da UF RS e não for um dos estados da região Norte, Frete >= 45,00 e CIF ou Frete = 00 e FOB *
		 // Se Estado for da região Norte, Frete >= 60,00 e CIF ou Frete = 0 e FOB                                                *
		 // --------------------------------------------------------------------------------------------------------------------- *
		
		 // Pesquisa os parâmetros de frete
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
		 cSql += " WHERE A1_COD     = '" + Alltrim(__Cliente) + "'"
		 cSql += "   AND A1_LOJA    = '" + Alltrim(__Loja)    + "'"
		 cSql += "   AND D_E_L_E_T_ = ''"
		
		 cSql := ChangeQuery( cSql )
		 dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )
		
		 // #################
		 // Aplica a Regra ##
		 // #################
		 __Altera_Status := .F.
		
		 If __Valor_Total <= T_PARAMETROS->ZZ4_FTOT
			
			If Alltrim(T_CLIENTE->A1_EST) == "RS"
				
			   //If Alltrim(T_CLIENTE->A1_MUN) == "PORTO ALEGRE"
				
			   If Alltrim(T_CLIENTE->A1_MUN) == Alltrim(SM0->M0_CIDENT)
			 	  If Alltrim(__Tipo_Frete) == "C"
				 	 If __Valor_Frete < T_PARAMETROS->ZZ4_FNRS
						__Altera_Status := .T.
					 Endif
				  Endif
			   Else
				  If Alltrim(__Tipo_Frete) == "C"
					 If __Valor_Frete < T_PARAMETROS->ZZ4_FFRS
						__Altera_Status := .T.
					 Endif
				  Endif
			   Endif
			Else
			   If Alltrim(T_CLIENTE->A1_EST)$("RR#AM#AC#RO#PA#AP#TO")
				  If Alltrim(__Tipo_Frete) == "C"
					 If __Valor_Frete < T_PARAMETROS->ZZ4_FRNO
						__Altera_Status := .T.
					 Endif
				  Endif
			   Else
				  If Alltrim(__Tipo_Frete) == "C"
					 If __Valor_Frete < T_PARAMETROS->ZZ4_FNNO
						__Altera_Status := .T.
					 Endif
				  Endif
			   Endif
			Endif
			
	 	 Endif
		
	  Endif
	
   Endif

   // ####################################################################################################################################
   // Se inclusão de Pedidos de Venda por medição de contratos, grava no pedido de venda a mensagem da nota fiscal e observação interna ##
   // ####################################################################################################################################
   If Inclui
	
	  // ######################
	  // Medição de Contrato ##
	  // ######################
	  If Alltrim(wRotAnt) == "CNTA260"
		
		 DbSelectArea("SC5")
		 DbSetorder(1)
		 If DbSeek(xFilial("SC5") + cCodPed)
			
		    If Select("T_OBSERVA") > 0
			   T_OBSERVA->( dbCloseArea() )
			EndIf
			
			cSql := ""
			cSql := "SELECT CN9_FILIAL,"
			cSql += "       CN9_NUMERO,"
			cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), CN9_MNOT)) AS MENSAGEM,"
			cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), CN9_OINT)) AS INTERNAS, "
			cSql += "       R_E_C_N_O_ RECCN9 "                             //Adicionado Michel Aoki
			cSql += "  FROM " + RetSqlName("CN9")
			cSql += " WHERE CN9_FILIAL = '" + Alltrim(SC5->C5_FILIAL)  + "'"
			cSql += "   AND CN9_NUMERO = '" + Alltrim(SC5->C5_MDCONTR) + "'"
			cSql += "   AND D_E_L_E_T_ = ''"
			
			cSql := ChangeQuery( cSql )
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OBSERVA", .T., .T. )
			
			_aAreaSC9 := CN9->(GetArea())
			DbSelectArea("CN9")
			DbGoTo(T_OBSERVA->RECCN9)
			DbSelectArea("SC5")
			DbSetorder(1)
			DbSeek(xFilial("SC5") + cCodPed)
			Reclock("SC5",.f.)
			C5_MENNOTA := Alltrim(C5_MENNOTA) + " " + Alltrim(CN9->CN9_MNOT) //Alterado Michel Aoki as Mensagens não estavam indo para o pedido
			C5_OBSI	   := Alltrim(C5_OBSI)    + " " + Alltrim(CN9->CN9_OINT) //Alterado Michel Aoki as Mensagens não estavam indo para o pedido
			MsUnlock()
			RestArea(_aAreaSC9)

		 Endif
		
	  Endif
	
   Endif

   DbSelectArea("SC6")
   DbSetOrder(1)
   DbSeek(xfilial("SC6")+cCodPed)
   lMovEst := .f.

   /*IF INCLUI .AND. xfilial("SC6") == "04"
	   cNumOp   := GetNumSc2(.T.)
	   cItemOp  := "01"
	   cSeqC2   := "001"
   ENDIF*/

   Begin Transaction

   Do While SC6->C6_NUM = cCodPed
	
	  DbSelectArea("SF4")
	  DbSetOrder(1)
	  DbSeek(xfilial("SF4")+SC6->C6_TES)
	
	  DbSelectArea("SC6")
	
	  IF SF4->F4_ESTOQUE == "S"
		 lMovEst := .T.
	  ENDIF
	
	  If Inclui
		 
         // #####################
		 // Proposta Comercial ##
		 // #####################
		 If ProcName(15) == "FT300GRV"

			// ####################
			// vem das propostas ##
			// ####################
			DbSelectArea("SCK")
			DbSetorder(1)
			DbSeek(xFilial("SCK")+SCJ->CJ_NUM+SC6->C6_ITEM)
			
			DbSelectArea("ADZ")
			DbSetorder(1)
			DbSeek(xFilial("ADZ")+SCK->CK_PROPOST+SCK->CK_ITEMPRO)
			
			IF !ADZ->(eof())
				
			   _nComis1   := ADZ->ADZ_COMIS1
			   _nComis2   := ADZ->ADZ_COMIS2
			   _nMoeda    := Val(ADZ->ADZ_MOEDA)  /// o C5_MOEDA é numerico
			   _Descricao := ADZ->ADZ_DESCRI
			   _Lacre     := ADZ->ADZ_LACRE
			   _Ocompra   := ADZ->ADZ_ORDC
			   _AnoOC     := ADZ->ADZ_ORDA
			   _SeqProOC  := ADZ->ADZ_ORDS
				
			   If !Empty(Alltrim(ADZ->ADZ_ORDC))
			   	  If !Empty(Alltrim(ADZ->ADZ_ORDA))
					 __Ordem := __Ordem + Alltrim(ADZ->ADZ_ORDC) + "/" + Alltrim(ADZ->ADZ_ORDA)  + "  "
				  Else
					 __Ordem := __Ordem + Alltrim(ADZ->ADZ_ORDC) + "/" + Strzero(YEAR(DATE()),4) + "  "
				  Endif
			   Endif
			   
			   If Empty(SC6->C6_ENTREG)
				  dEntrega := U_CalcPrevEnt(SC6->C6_PRODUTO, SC6->C6_QTDVEN, SC5->C5_EMISSAO, Posicione("SA1",1, xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI,"",SC6->C6_ENTREG))
			   Else
			  	  dEntrega := SC6->C6_ENTREG
			   Endif

			   DbSelectArea("SC6")
			   Reclock("SC6",.f.)
			   C6_COMIS1 := _nComis1
			   C6_COMIS2 := _nComis2
			   C6_PEDCLI := _cPedCli  // vem do AD1_OC
			   C6_DESCRI := _Descricao
			   C6_LACRE  := _Lacre
			   C6_TEMDOC := Iif( _Lacre == "S", _Lacre, "N" ) // Jean Rehermann | 09/04/2013
			   C6_ORDC   := _Ocompra
			   C6_ORDA   := IIF(Empty(Alltrim(_AnoOC)), Strzero(YEAR(DATE()),4), _AnoOC)
			   C6_ORDS   := _SeqProOC
 			   C6_ENTREG := dEntrega

			   // ##########################################################################################################
			   // Se __Altera_Status == .T., altera o Status do Pedido de Venda para 02 - Aguardando Liberação de Margem  ##
			   // ##########################################################################################################
			   If __Altera_Status
				  SC6->C6_BLQ    := "S"
				  SC6->C6_STATUS := "02" // Aguardando liberação de margem
                  SC6->C6_ZTBL   := Alltrim(SC6->C6_ZTBL) + "FRT-"
				  MsUnlock()
				  U_GrvLogSts(xFilial("SC6"),SC6->C6_NUM, SC6->C6_ITEM, "02", "PE_MATA410 (INC)") // Gravo o log de atualização de status na tabela ZZ0
				  If __Primeiro
					 MsgAlert("Atenção !!" + chr(13) + chr(10) + chr(13) + chr(10) + "Pedido de Venda bloqueado por regra de Frete." + chr(13) + chr(10) + "Aguarde Liberação!")
					 __Primeiro := .F.
				  Endif
			   Else
			   	  MsUnlock()
 			   Endif
				
			   DbSelectArea("SC5")
			   DbSetorder(1)
			   DbSeek(xFilial("SC5")+cCodPed)
			   Reclock("SC5",.f.)
			   C5_MOEDA := _nMoeda
				
			   If __Altera_Status
			      C5_BLQ := "3"
  			   Endif
				
			   MsUnlock()
				
			ENDIF
			
		ElseIf Substr(wRotAnt,1,7) == "TECA450"
			
			//AB6_MEMO2 //obs interna
			
		ElseIf Substr(wRotAnt,1,8) == "AUTOM243"
			
			_Ocompra   := ADZ->ADZ_ORDC
			_AnoOC     := ADZ->ADZ_ORDA
			_SeqProOC  := ADZ->ADZ_ORDS
			
			DbSelectArea("SC6")
			Reclock("SC6",.f.)
			C6_ORDC   := _Ocompra
			C6_ORDA   := IIF(Empty(Alltrim(_AnoOC)), Strzero(YEAR(DATE()),4), _AnoOC)
			C6_ORDS   := _SeqProOC
			MsUnlock()
			
		Endif
		
 	 ENDIF
	
	 DbSelectArea("SC6")
	 DbSkip()
	
   Enddo

   End Transaction

   // ########################################################################################################
   // Atualiza o campo mensagem da nota fiscal complementando com os dados das Ordens de Compras do Cliente ##
   // ########################################################################################################
   If !Empty(Alltrim(__Ordem))
	  DbSelectArea("SC5")
	  DbSetorder(1)
	  DbSeek(xFilial("SC5")+cCodPed)
	  Reclock("SC5",.f.)
	  C5_MENNOTA := "PEDIDO NR. " + ALLTRIM(cCodPed) + " - OC: " + ALLTRIM(__Ordem)
	  MsUnlock()
   Endif

   IF !lMovEst
	  // ############################
	  // Se NAO movimentou estoque ##
	  // ############################
	  
   	  DbSelectArea("SC5")
	  DbSetOrder(1)
	  DbSeek(xfilial("SC5")+cCodPed)
	  Reclock("SC5",.f.)
	  C5_JPCSEP := "T"
	  Msunlock()
	
   ENDIF

   // ############################
   // Restaura areas anteriores ##
   // ############################
   RestArea(aAreaSC2)
   RestArea(aAreaSF4)
   RestArea(aAreaSB2)
   RestArea(aAreaSB1)
   RestArea(aAreaSC6)
   RestArea(aAreaSC5)
   RestArea(aAreaAtu)

RETURN(NIL)

// ######################################## 
// Função que bloqueia pedido por margem ##
// ########################################
User Function Ma410Cor()
   // Blouqio por margem
   _aAcores := paramixb
   aAdd(_aAcores, { "C5_BLQ == '3'",'BR_PRETO'}  )

Return(_aAcores)

// ######################################################
// Função Ponto de entrada na copia do pedido de venda ##
// ######################################################
User Function MT410CPY()

   Local aAreaAtu 	 := GetArea()
   Local aAreaSC5 	 := SC5->(GetArea())
   M->C5_JPCSEP:=""

// solicitado que as informa??es referentes a frete e fornecedor sejam removidas
    M->C5_ZROD      :=  ""
    M->C5_FRETE     :=  0
    M->C5_TRANSP    :=  ""
    M->C5_TPFRETE   :=  ""

   Restarea(aAreaSC5)
   Restarea(aAreaAtu)

Return()

// #################################################
// Ponto de entrada na legenda do pedido de venda ##
// #################################################
User Function MA410LEG()

   AADD ( PARAMIXB, { 'BR_PRETO', 'Bloqueio Preço Venda'}  )

Return(PARAMIXB)

// ###################################################################
// Função que bloqueia a alteracao de pedidos que estejam separados ##
// ###################################################################
User Function M410ALOK

   Local lRet := IIF(SC5->C5_JPCSEP <> ' ',.f.,.t.)
           
   // ##########################################################################################################
   // Se a variável de ambiente abaixo esteiver com T, indica que é uma copia de pedido pelo painel comercial ##
   // ##########################################################################################################
   If GetMv("MV_VEXE") == .T.
      putmv("MV_VEXE", .F.)
      Return(.T.)
   Endif   

   IF !lret
      Aviso("Atencao!","Pedido de Venda ja SEPARADO!",{"OK"}, 2)
   ELSE
      // ###################################################
      // Grava Log dos Memos gravados no pedido de vendas ##
      // ###################################################
      U_GrvMemo("SC5",SC5->C5_NUM,"C5_OBSI","C5_OBSI",SC5->(RECNO()),SC5->C5_OBSI,SUBSTR(CUSUARIO,7,15),Date(),time())
   ENDIF

Return(lRet)

// ####################
// Função grava memo ##
// ####################
User Function GrvMemo(_cAliasDest,_cNumPed,_cFieldDest,_cFieldOrig,_nRegOrig,_mConteudo,_cUsr,_Data,_Time)

   _aArea1 := GetArea()

   Reclock("ZZ1",.t.)
   ZZ1_FILIAL := xFilial("ZZ1")
   ZZ1_ALIASD := _cAliasDest
   ZZ1_PEDVEN := _cNumPed
   ZZ1_FLDDES := _cFieldDest
   ZZ1_FLDORI := _cFieldOrig
   ZZ1_REGORI := _nRegOrig
   ZZ1_TEXTO  := _mConteudo
   ZZ1_USER	  := _cUsr
   ZZ1_DATA   := _Data
   ZZ1_HORA   := _Time
   MsUnlock()

   RestArea(_aArea1)

Return(.T.)

// #######################################################
// Função que realiza a impressão dos boletos bancários ##
// #######################################################
Static Function IMP_BOLETO()

   Private cMemo1 := ""
   Private oMemo1
   Private oDlgBol

   DEFINE MSDIALOG oDlgBol TITLE "Emissão de Boleto Bancario" FROM C(178),C(181) TO C(315),C(634) PIXEL

   @ C(005),C(005) Say "Atenção!"                                                                                                 Size C(023),C(008) COLOR CLR_RED PIXEL OF oDlgBol
   @ C(017),C(005) Say "A Condição de Pagamento utilizada nesta Proposta Comercial permite que seja emitido o Boleto Bancário de" Size C(217),C(008) COLOR CLR_BLACK PIXEL OF oDlgBol
   @ C(026),C(005) Say "cobrança para envio ao Cliente. Salve o(s) Boleto(s) em PDF e envie-os por e-mail ao Cliente."            Size C(217),C(008) COLOR CLR_BLACK PIXEL OF oDlgBol

   @ C(045),C(005) GET oMemo1 Var cMemo1 MEMO Size C(216),C(001) PIXEL OF oDlgBol

   @ C(051),C(005) Button "Gerar Boleto(s)"             Size C(077),C(012) PIXEL OF oDlgBol ACTION(U_AUTOM636(SC5->C5_FILIAL, SC5->C5_NUM, INCLUI) )
   @ C(051),C(143) Button "Continuar s/Gerar Boleto(s)" Size C(077),C(012) PIXEL OF oDlgBol ACTION( oDlgBol:End() )

   ACTIVATE MSDIALOG oDlgBol CENTERED

Return(.T.)

// ################################# 
// Calculo da previsão de entrega ##
// #################################
User Function CalcPrevEnt(cProd, nQtd, dDataEmis, cUF, dDataDig)

   // ####################################
   // Codigo do Produto     Obrigatorio ##  
   // Quantidade etiquetas  Obrigatorio ##
   // Data Emissao          Obrigatorio ##
   // UF (fornecedor da MP	Opcional    ##
   // Data Digitada			Opcional    ##
   // ####################################

   Local  _aArea1  := GetArea()
   Local  cSQL     := ""
   Local  dDataRet := dDataEmis
   Local  _cTipo   := IIF(SB1->(FieldPos("B1_ETQROT")>0),Posicione("SB1",1,xFilial("SB1") + cProd,"B1_ETQROT"),"1")
   Local nPrazo    := 1
   
   // #############################################################################################
   // Este teste foi colocado aqui porque o espaço do campo condição do gatilhoe é muito pequeno ##
   // #############################################################################################
   // If (cEmpAnt == "01" .And. cFilAnt == "04") .Or. (cEmpAnt == "03" .And. cFilAnt == "01") .Or. (cEmpAnt == "01" .And. cFilAnt == "07")

   If (LEFT(cProd,2) == "02" .Or. LEFT(cProd,2) == "03")

      // #####################################################
      // Caso Não tenha o tipo especificado, assume 1 = Etq ##
      // #####################################################
      _cTipo := IIF(_cTipo $ "12",_cTipo,"1")

      cUf := U_QFORNEC(cProd)
      cUf := IIF(empty(cUf),"RS",cUf)

      DBSelectArea("SB1")
      If DBSeek(xFilial("SB1") + cProd)

         _aRet1   := U_CALCMETR(cProd)

         // ###############################
	     // 1 = Metragem Linear por rolo ##
	     // 2 = Qtd Etoquetas por rolo   ##
	     // 3= Tubete                    ##
	     // ###############################
	     IF SB1->B1_UM == "RL"
	        _nMtLin := nQtd * _aRet1[1] // qtd rolos vendida x metros por rolo
	     Else
	        _nMtLin := (nQtd/_aRet1[2]) * _aRet1[1] //(qtd etiq vendida / etiq por rolo) x metros por rolo
	     ENDIF
	
	     cSQL := " SELECT * FROM " + RetSqlName("ZZ8")
	     cSQL += " WHERE ZZ8_FILIAL='" + xFilial("SB1")  + "'"
	     cSQL += "   AND ZZ8_TIPO='"+_cTipo+"'"
	     cSQL += "   AND ZZ8_UFORIG='" + cUF + "'"
   	  
   	     //MemoWrit("c:\sql\PrevEntrega.TXT", cSQL)
	     dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PrevEnt", .T., .T. )

	     DBGOTOP()
	     While !EOF()
	        If _nMtLin >= ZZ8_DMTLIN .AND. _nMtLin <= ZZ8_AMTLIN
		  	   nPrazo := ZZ8_PRAZO
			   Exit
		    Endif
		    DBSkip()
	     Enddo
	  
	     DBCloseArea("T_PrevEnt")
	
	     For nX := 1 To nPrazo	// #############################################################
	                           // Para todos os dias de retencao valida a data               ##
		                       // O calculo eh feito desta forma, pois os dias de prazo      ##
		                       // sao dias uteis, e se fosse apenas somado dDataEmisa+Prazo  ##
		                       // nao sera verdadeiro quando a data for em uma quinta-feira, ##
		                       // por exemplo.                                               ##
		                       // #############################################################
	   	     dDataRet := DataValida(dDataRet+1,.T.)
	     Next
	
      Endif

      RestArea(_aArea1)
   
      // ##############################################################################
      // Aqui valido se a data DIGITADA for maior que a calculada, assume a digitada ##
      // ##############################################################################
      IF !empty(dDataDig)
         dDataRet := IIF(dDataRet <= dDataDig,dDataDig,dDataRet)
      ENDIF
      
   Endif
   
Return(dDataRet)          

// ############################################
// Função que acha p último fornecedor da MP ##
// ############################################
User Function QFORNEC(cProduto)

   Local cSql := ""
   Local cRet := "SP"

   // ###########################################################################
   // Recebe o produto acabado, para achar o estado do ultimo fornecedor da MP ##
   // ###########################################################################
   cSql := ""
   cSql := " SELECT TOP 1 D1_FILIAL, D1_FORNECE, D1_LOJA "
   cSql += " ,(SELECT A2_EST from SA2010 WHERE A2_COD = D1_FORNECE AND A2_LOJA = D1_LOJA) AS 'A2_EST' "
   cSql += " FROM SD1010 "
   cSql += " WHERE D1_COD = "
   cSql += " (SELECT TOP 1 G1_COMP FROM SG1010 SG1 WHERE SG1.G1_COD = '"+cProduto+"' AND SG1.D_E_L_E_T_ = ' ' "
   cSql += " AND D_E_L_E_T_ = ' ') "
   cSql += " ORDER BY R_E_C_N_O_ DESC "

   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_QFnc", .T., .T. )
   
   DBGOTOP()
   
   IF !Eof()
      cRet := T_QFnc->A2_EST
   Endif

   DbCloseArea("T_QFNC")

Return(cRet)

// ###################################
// Função que calcula a perda da MP ##
// ###################################
User Function CalcPerda(K_Tipo, cOp, cProdPed, lGravaSD4)

   Local nRet       := 0
   Local _aArea     := GetArea()
   Local cSQL       := ""
   Local nPercPerd  := GetMv("MV_PERCPER") // percentual de perda
   Local nQtdSetup  := GetMv("MV_QTDSETU") // quantidade padrão de perda
   Local aComp      := {}
   Local nQtdLin    := 0
   Local nQtdLinPer := 0
   Local nMultip    := 0
   Local aDim       := {}
   Local _nL        := 0
   Local _nH        := 0
   Local _nC        := 0
   Local _nEspEtq   := SuperGetMv("MV_ESPETQ",,3)
   Local _ehExata   := "N"
   Local nCores     := 1
   Local kaQtdRolo  := {}

   // #########################################################
   // K_Tipo == "OP" - Rotina chamada pela Ordem de produção ##
   // K_Tipo == "SM" - Rotina chamada pelo Sales Machine     ##
   // #########################################################

   If K_Tipo == "OP"

      _ehExata := IIF("EXATA" $ SC2->C2_OBS ,"S",_ehExata)

      aComp  := U_BuscaComp() // Busca os componentes do produto para obter o calculo linear

   Else
 
      // ###########################################
      // Busca as dimensões da Etiqueta           ##
      // ###########################################
      KaQtdRolo := u_CalcMetr(cProdPed)

      // ################################
      // Pega a largura da Fatia da MP ##
      // ################################
      cDesc := Alltrim(Posicione('SB1', 1, xFilial('SB1') + cProdPed, 'B1_DESC'))
      nPos  := AT("/",cDesc)
      nMult := Val(Substr(cDesc,nPos+1,3))/1000

      // ##############################
      // Calcula a quantidade linear ##
      // ##############################
      nQtdLin := KaQtdRolo[1]

      // ############################################################# 
      // Calcula o percentual de perda do pedido conforme parametro ##
      // #############################################################
 	  nPerdaPed := (nQtdLin * nPercPerd) / 100 // Qtd linear perdida

	  cSQL := "SELECT COUNT(*) NCORES "
	  cSQL += "  FROM " + RetSqlName("ZP3")
	  cSQL += " WHERE ZP3_FILIAL  = '" + xFilial("ZP3")    + "'"
	  cSQL += "   AND ZP3_COD     = '" + Alltrim(cProdPed) + "'"
	  cSQL += "   AND D_E_L_E_T_ <> '*'"
	 
      DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSQL),'SQL',.F.,.F.)
	  
	  DBSelectArea("SQL")
	  
	  nCores := SQL->nCores
	  DBCloseArea("SQL")
	  If nCores == 0
	     If nPerdaPed < nQtdSetup
	        nQtdPerda := nQtdSetup
	     Else
	        nQtdPerda := nPerdaPed
	     Endif
	  Else
	     If nPerdaPed < nQtdSetup
	        nQtdPerda := nQtdSetup * nCores
	     Else
	        nQtdPerda := nPerdaPed
	     Endif
	  Endif

 	  nQtdLinPer := (nQtdLin + nQtdperda) // perda em metros lineares

	  // nQtdPerda  := nQtdLinPer / nMultip // Perda em M2

	  nQtdPerda  := nQtdLinPer * nMult // M2 + Perda em M2
		
      Return(nQtdPerda)

   Endif

   IF LEN(aComp) > 0

      DBSelectArea("SD4")
      DBSetOrder(2)

      If DBSeek(xFilial("SD4") + cOP)
	     cProd   := D4_COD           // codigo do material
		 nQuant  := D4_QUANT         // Quantidade empenhada do material
		 nQtdLin := aComp[01][06]    // Quantidade linear do material utilizado no pedido
		 nMultip := nQtdLin / nQuant // fator de proporção utilizado para calcular as perda em M2.
		 nQtdLinPer := nQtdLin       // nao tem perda em metros lineares
   	  Endif

   Endif   

   If _ehExata <> "S"
	
      IF LEN(aComp) > 0
		
         // #############################################################
         // Calcula o percentual de perda do pedido conforme parametro ##
         // #############################################################
		 nPerdaPed := (nQtdLin * nPercPerd) / 100 // Qtd linear perdida
		 cSQL := "SELECT COUNT(*) NCORES FROM " + RetSqlName("ZP3")
		 cSQL += " WHERE ZP3_FILIAL ='" + xFilial("ZP3") + "'"
		 cSQL += "   AND ZP3_COD='" + cProdPed + "'"
		 cSQL += "   AND D_E_L_E_T_ <> '*'

		 DbUseArea(.T.,'TOPCONN',TcGenQry(,,cSQL),'SQL',.F.,.F.)
		 DBSelectArea("SQL")

		 nCores := SQL->nCores
		 DBCloseArea("SQL")

		 If nCores == 0
		    If nPerdaPed < nQtdSetup
		       nQtdPerda := nQtdSetup
		    Else
		       nQtdPerda := nPerdaPed
		    Endif
		 Else
		    If nPerdaPed < nQtdSetup
		       nQtdPerda := nQtdSetup * nCores
		    Else
		       nQtdPerda := nPerdaPed
		    Endif
		 Endif

		 nQtdLinPer := (nQtdLin + nQtdperda) // perda em metros lineares

		 // nQtdPerda  := nQtdLinPer / nMultip // Perda em M2

	 	 nQtdPerda  := nQtdLinPer * aComp[1][8] // M2 + Perda em M2

		 If lGravaSD4
   		    Reclock("SD4",.F.)
		    SD4->D4_QUANT   := nQtdPerda // Quantidade empenhada por M2 + perda M2
		    SD4->D4_QTDEORI := nQtdPerda
		    MSUnlock()
		 Endif
		
      Endif

   Endif

   RestArea(_aArea)

Return(nQtdLinPer)