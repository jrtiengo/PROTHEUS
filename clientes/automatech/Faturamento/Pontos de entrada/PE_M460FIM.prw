#INCLUDE "RWMAKE.ch"
#INCLUDE "PROTHEUS.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: M460FIM.PRW                                                         ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 09/05/2011                                                          ##
// Objetivo..: Ponto de entrada após a gravação da nota fiscal de saída.           ##
// Parâmetros: Sem Parâmetros                                                      ##
// Retorno...: .T./.F.                                                             ##
// ##################################################################################

User Function M460FIM()

   Local cSql      := ""
   Local cNumNota  := SF2->F2_DOC
   Local cNumSerie := SF2->F2_SERIE
   Local _cItens   := ""
   Local nContar   := 0
   Local aDivPed   := {}

   Local aArea 	   := GetArea()
   Local aAreaSD2  := SD2->(GetArea())
   Local aAreaSC6  := SC6->(GetArea())
   Local aAreaSC5  := SC5->(GetArea())
   Local aAreaSC9  := SC9->(GetArea())
   Local aAreaSE1  := SE1->(GetArea())
   Local cPrefixo  := SF2->F2_SERIE
   Local cNumDoc   := SF2->F2_DOC
   Local nValor    := SF2->F2_VALFAT
   Local cCond     := SF2->F2_COND
   Local cPedVen   := ""
   Local cNat	   := ""
   Local cOpeADM   := ""
   Local cOpeCRT   := ""
   Local cOpeAUT   := ""
   Local cOpeTID   := ""
   Local cOpeDOC   := ""
   Local cOpeDAT   := ""
   Local cFilNota  := SF2->F2_FILIAL
   Local cNumNota  := SF2->F2_DOC
   Local cNumSerie := SF2->F2_SERIE
   Local cCliente  := SF2->F2_CLIENTE
   Local cLoja     := SF2->F2_LOJA
   Local aItens    := {}
   Local nOpc	   := 3
   Local xCodVend  := SF2->F2_VEND1
   Local xFormaPg  := ""
   Local lOServico := .F.

   Local _cItens := ""

   U_AUTOM628("PE_M460FIM")
	
   // ###########################################################################################################
   // Envia para a função que envia e-mail ao financeiro com os dados da nota fiscal para geração da guia GNRE ##
   // ###########################################################################################################
   EnviaGNREFIN(SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA)

   // ################################################################################
   // Tarefa: #3821 - PIN                                                           ##   
   // Envia para a função que verifica se deve mostrar a mensagem de geração do PIN ##
   // ################################################################################
   EnviaMsgPIN(SF2->F2_FILIAL, SF2->F2_DOC, SF2->F2_SERIE, SF2->F2_CLIENTE, SF2->F2_LOJA)

   // #######################
   // Busca o Numero do PV ##
   // #######################
   dbSelectArea("SD2")
   dbSetOrder(3)
   If dbSeek( xFilial("SD2") + cNumDoc + cPrefixo )
      kkFilial := SD2->D2_FILIAL
      cPedVen  := SD2->D2_PEDIDO
   Endif
	
    // ##############################################################################
    // Envia para a função que atualiza o campo margem dos produtos da nota fiscal ##
    // ##############################################################################
    // Calc_Mrg_Prod(kkFilial, cPedVen)

    // #######################################################################################
    // Verifica no pedido de venda se é um pedido de venda referente a uma ordem de serviço ##
    // #######################################################################################
    If Select("T_OSERVICO") > 0
       T_OSERVICO->( dbCloseArea() )
    EndIf
    
    cSql := ""
    cSql := "SELECT C6_PRODUTO                AS OPRODUTO,"
    cSql += "       SUBSTRING(C6_NUMOS,01,06) AS OSERVICO,"
    cSql += "       SUBSTRING(C6_NUMOS,07,02) AS OFILIAL  "    
    cSql += "  FROM " + RetSqlName("SC6")
    cSql += " WHERE C6_FILIAL  = '" + Alltrim(SF2->F2_SERIE) + "'"
    cSql += "   AND C6_NUM     = '" + Alltrim(cPedVen)       + "'"
    cSql += "   AND D_E_L_E_T_ = ''"

    cSql := ChangeQuery( cSql )
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_OSERVICO", .T., .T. )

    If T_OSERVICO->( EOF() )
       lOServico := .F.
    Else
       If Empty(Alltrim(T_OSERVICO->OSERVICO))
          lOServico := .F.
       Else
          lOServico := .T.
       Endif
    Endif
             
    If lOServico == .T.

       T_OSERVICO->( DbGoTop() )
	
       WHILE !T_OSERVICO->( Eof() )

          DbSelectArea("ZZZ")
	      DbSetOrder(1)
		
   	      If DbSeek(T_OSERVICO->OFILIAL + T_OSERVICO->OSERVICO + T_OSERVICO->PRODUTO)
			
	  	     Reclock("ZZZ", .F.)
		     ZZZ->ZZZ_NOTA  := SF2->F2_DOC
		     ZZZ->ZZZ_SERIE := SF2->F2_SERIE
		     MsunLock()
			
  	     Endif
		 
	     T_OSERVICO->( DbSkip() )
		 
       ENDDO	 
       
    Endif

    // ##########################################################
	// Posiciona no registro do titulo referente a nota fiscal ##
	// ##########################################################
	dbSelectArea('SE1')
	dbSeek(xFilial('SE1')+cPrefixo+cNumDoc)
	cNat := SE1->E1_NATUREZ
	
    // #################################
	// Busca os dados do cartao no PV ##
	// #################################
	dbSelectArea('SC5')
	dbSeek(xFilial('SC5')+cPedven)
	cOpeADM  := SC5->C5_ADM
	cOpeCRT  := SC5->C5_CARTAO
	cOpeAUT  := SC5->C5_AUTORIZ
	cOpeTID  := SC5->C5_TID
	cOpeDOC  := SC5->C5_DOC
	dOpeDAT  := SC5->C5_DATCART
    cTipoPV  := SC5->C5_TIPO

    // ################################
    // Pesquisa a forma de pagamento ##
    // ################################               
    If Select("T_XCONDICAO") > 0
       T_XCONDICAO->( dbCloseArea() )
    EndIf

    cSql := ""
    cSql := "SELECT E4_FORMA"
    cSql += "  FROM " + RetSqlName("SE4")
    cSql += " WHERE E4_CODIGO  = '" + Alltrim(SC5->C5_CONDPAG) + "'"
    cSql += "   AND D_E_L_E_T_ = ''"
    
    cSql := ChangeQuery( cSql )
    dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_XCONDICAO", .T., .T. )
    
    xFormaPg := IIF(Alltrim(T_XCONDICAO->E4_FORMA) == "BOL", "1", "2" )
    
/*	IF !empty(cOpeADM)
		// O PV tem uma Administradora de Cartao cadastrada...
		//Busca o Codigo de cliente da operadora
		DbSelectArea("SAE")
		DbSetOrder(1)
		DbSeek(xFilial("SAE")+cOpeADM)
		IF FOUND()
			cLiqCli := SAE->AE_CODCLI
			nLiqTax := SAE->AE_TAXA
			
			//Busca Loja no SA1
			DbSelectArea("SA1")
			DbSetorder(1)
			DbSeek(xFilial("SA1")+cLiqCli)
			
			cLiqLoj := SA1->A1_LOJA
			cLiqNom := SA1->A1_NREDUZ
			
			//Filtro do Usuário
			cFiltro := "E1_FILIAL=='"+xFilial("SE1")+"' .And. "
			cFiltro += "E1_CLIENTE=='"+cCliente+"'.And. E1_LOJA =='"+cLoja+"' .And. "
			cFiltro += "E1_NUM =='"+cNumDoc+"'.And. E1_PREFIXO =='"+cprefixo+"' .And. "
			cFiltro += "E1_SITUACA$'0FG' .And. E1_SALDO>0 .and. "
			cFiltro += 'Empty(E1_NUMLIQ)'
			
			//Array do processo automatico (aAutoCab)
			aCab:={ {"cCondicao" ,cCond },;
			{"cNatureza" ,cNat },;
			{"E1_TIPO" ,"CC " },;
			{"cCLIENTE" ,cLiqCli},;
			{"nMoeda" ,1 },;
			{"cLOJA" ,cLiqLoj }}
			
			//------------------------------------------------------------
			//Monta as parcelas de acordo com a condição de pagamento
			//------------------------------------------------------------
			aParcelas:=Condicao(nValor,cCond,,dOpeDat)

			//--------------------------------------------------------------
			//Não é possivel mandar Acrescimo e Decrescimo junto.
			//Se mandar os dois valores maiores que zero considera Acrescimo
			//--------------------------------------------------------------
			cParc := "01"
			For nZ:=1 to Len(aParcelas)
				//Dados das parcelas a serem geradas
				Aadd(aItens,{{ "E1_PREFIXO"," " },;//Prefixo
				{"E1_BCOCHQ"  ,cOpeCRT         },;//Banco
				{"E1_AGECHQ"  ,cOpeAUT         },;//Agencia
				{"E1_CTACHQ"  ,cOpeTID         },;//Conta
				{"E1_NUM"     ,cOpeDOC         },;//Nro. cheque (dará origem ao numero do titulo)
				{"E1_PARCELA" ,cParc           },;//Nro. cheque (dará origem ao numero do titulo)
				{"E1_EMITCHQ" ,cLiqNom         },;//Emitente do cheque
				{"E1_VENCTO"  ,aParcelas[nZ,1] },;//Data boa
				{"E1_VLCRUZ"  ,aParcelas[nZ,2] },;//Valor do cheque/titulo
				{"E1_DESCFIN" , nLiqTax        },;//Desconto - taxa operadora
				{"E1_ACRESC"  ,0               },;//Acrescimo
				{"E1_DECRESC" ,0    }})//Decrescimo
				cParc:=Soma1(cParc,Len(Alltrim(cParc)))
			Next nZ
			
			If Len(aParcelas) > 0
				//Liquidacao e reliquidacao
				//FINA460(nPosArotina,aAutoCab,aAutoItens,nOpcAuto,cAutoFil,cNumLiqCan)
				FINA460(,aCab,aItens,nOpc,cFiltro)//Inclusao
			Endif
		Endif
		RestArea( aArea )
		RestArea( aAreaSD2 )
		RestArea( aAreaSC6 )
		RestArea( aAreaSC5 )               
		
		RestArea( aAreaSC9 )
	Endif
    */

   // ###################################################################################################################################
   // Jean Rehermann | JPC - Avalia os itens faturados e altera o STATUS (e verifica se o transportador é o próprio pra enviar e-mail) ##
   // ###################################################################################################################################
   _aArea:=GetArea()

   If Select("T_SC6") > 0
      T_SC6->( dbCloseArea() )
   EndIf

   _cQry := ""
   _cQry := "SELECT C6_FILIAL, "
   _cQry += "       C6_NUM   , "
   _cQry += "       C6_ITEM    "
   _cQry += "  FROM " + RetSqlName("SC6") 
   _cQry += " WHERE C6_NOTA    = '" + Alltrim(SF2->F2_DOC)     + "'"
   _cQry += "   AND C6_SERIE   = '" + Alltrim(SF2->F2_SERIE)   + "'"
   _cQry += "   AND C6_CLI     = '" + Alltrim(SC5->C5_CLIENTE) + "'"
   _cQry += "   AND C6_LOJA    = '" + Alltrim(SC5->C5_LOJACLI) + "'"
   _cQry += "   AND D_E_L_E_T_ = ''"
   _cQry += "   AND C6_FILIAL  = '" + Alltrim(SC5->C5_FILIAL)  + "'"

   _cQry := ChangeQuery(_cQry)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,_cQry),"T_SC6",.T.,.T.)

   While !T_SC6->( Eof() )
   
      dbSelectArea("SC6")
	  dbSetOrder(1)
	  
	  If dbSeek( T_SC6->C6_FILIAL + T_SC6->C6_NUM + T_SC6->C6_ITEM )
         If SC6->C6_STATUS == "10" .Or. AllTrim( FunName() ) == "MATA410" // Aguardando faturamento - Jean alterado em 03-09-12 (emissao pelo mata410)
			RecLock("SC6", .F.)
			SC6->C6_STATUS := "11" // Itens faturados e nota emitida
			U_GrvLogSts(SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "11", "PE_M460FIM", 0 ) // Gravo o log de atualização de status na tabela ZZ0
			_cItens += SC6->C6_ITEM + "|"
			MsUnLock()			
		 EndIf
   	  EndIf

//	  dbSelectArea("T_SC6")

	  T_SC6->( dbSkip() )

   Enddo 

// T_SC6->( dbCloseArea() )
	   
   If !Empty( AllTrim( _cItens ) )
   	  U_MailSts( SC6->C6_NUM, SubStr( _cItens, 1, Len( _cItens ) - 1 ), "F" ) // Envio de e-mail
   EndIf

   RestArea(_aArea)
   
   // ***************************************** FIM STATUS

   // ######################################################################################################
   // Verifica se a condição de pagamento utilizada no pedido de venda permite emissão de boleto bancário ##
   // ######################################################################################################
   If empty(cOpeADM)
   
	   If Select("T_CONDICAO") <>  0
	      T_CONDICAO->(DbCloseArea())
	   EndIf
	
	   cSql := ""
	   cSql := "SELECT E4_CODIGO, "
	   cSql += "       E4_BOLET   "
	   cSql += "  FROM " + RetSqlName("SE4")
	   cSql += " WHERE E4_CODIGO    = '" + Alltrim(SF2->F2_COND) + "'"
	   cSql += "   AND R_E_C_D_E_L_ = ''"
	
	   cSql := ChangeQuery(cSql)
	   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CONDICAO",.T.,.T.)
	   
	   If T_CONDICAO->E4_BOLET == "S"

         // #########################################################################################
	     // Pergunta se gera boleto.Mauro JPC - 09/05/2011. #1098                                  ##
         // Se a serie da nota fiscal for 11 ou 13 (Série de notas fiscais eletrônica de serviço), ##
         // neste caso, não solicita impressão de boleto                                           ##
         // #########################################################################################
         Do Case
            Case SF2->F2_SERIE == "11"
            Case SF2->F2_SERIE == "13"
            Otherwise

              // ####################################################################################
              // Verfica se Pedido de Venda é um pedido de venda referente a uma ordem de serviço. ##
              // Se foi, verifica se a OS já teve seu pagamento antecipado sem Pedido de Venda.    ##
              // Neste caso, não imprime o Boleto bancário.                                        ## 
              // ####################################################################################                                                                                       
              If SC6->C6_NUMOS <> ""
                 
                 If Posicione( "AB6", 1, xFilial("AB6") + Substr(SC6->C6_NUMOS,01,06), "AB6_PANT" ) == "S"
                 Else
      	            If MSGBOX("Deseja gerar boleto para esta nf?","Atenção!","YESNO")
	                   U_AUTM001(cNumNota,cNumSerie)
	                EndIf
	             Endif
	             
	          Else   

   	             If MSGBOX("Deseja gerar boleto para esta nf?","Atenção!","YESNO")
	                U_AUTM001(cNumNota,cNumSerie)
	             EndIf
	             
	          Endif   

	     EndCase
	   Endif
	EndIf

   // Jean Rehermann | JPC - 18/06/2011 - Programa que efetua a criação de pedido de vendas de comissão quando o pedido referente a este faturamento
   // for do tipo externo (pedido de intermediação) referente à tarefa #1065 do portfólio.
   If SC5->C5_EXTERNO == "1"
// 	  U_AUTA004()

      // Pesquisa o valor total da comissão a ser dividida
      If Select("T_COMISSAO") > 0
         T_COMISSAO->( dbCloseArea() )
      EndIf

      cSql := ""
//    cSql := "SELECT SUM(C6_COMIAUT) AS COMISSAO"
      cSql := "SELECT SUM(C6_VALOR) AS COMISSAO"
      cSql += "  FROM " + RetSqlName("SC6")
      cSql += " WHERE C6_FILIAL = '" + Alltrim(SC5->C5_FILIAL) + "'"
      cSql += "   AND C6_NUM    = '" + Alltrim(SC5->C5_NUM)    + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMISSAO", .T., .T. )

      // Envia para a função que traz a quantidade de parcelas e o valor das parcelas
      // Retorno: aVenc() = Array contendo os vencimentos e valores calculados pelo desdobramento, com base na configuração da condição de pagamento informada.
      aVenc := Condicao( T_COMISSAO->COMISSAO, SC5->C5_CONDPAG )

      // Envia para o programa que abre os pedidos de comissões
      For nContar = 1 to Len(aVenc)
          U_AUTOM149(aVenc[nContar,1], aVenc[nContar,2], Len(aVenc))
      Next nContar    

   EndIf

   // Verifica se pedido é um pedido de locação. Se for, emite o recibo referente a cobrança efetuada
   If Select("T_CONTRATO") > 0
      T_CONTRATO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT C5_FILIAL ,"
   cSql += "       C5_NUM    ,"
   cSql += "       C5_MDCONTR,"
   cSql += "       C5_MDPLANI,"
   cSql += "       C5_EMISSAO "
   cSql += "  FROM " + RetSqlName("SC5")
   cSql += " WHERE C5_FILIAL  = '" + Alltrim(SC5->C5_FILIAL) + "'"
   cSql += "   AND C5_NUM     = '" + Alltrim(SC5->C5_NUM)    + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTRATO", .T., .T. )

   If !T_CONTRATO->( EOF() )
      // Programa que emite o recibo de locação
      U_AUTOM266(SC5->C5_FILIAL, T_CONTRATO->C5_MDCONTR, Substr(T_CONTRATO->C5_EMISSAO,05,02) + "/" + Substr(T_CONTRATO->C5_EMISSAO,01,04))
   Endif

   // ######################################################################################
   // Contempla a Tarefa Nº 001120.00 - Gravação de dados nas tabelas SF2 e SD2 para o BI ##
   // ######################################################################################
// dbSelectArea("SF2")
// dbSetOrder(2)
// If dbSeek( cFilNota + cCliente + cLoja + cNumNota + cNumSerie )
// RecLock("SF2", .F.)
//    SF2->F2_ZTVD  := Posicione("SA3", 1, xFilial("SA3") + xCodVend        , "A3_ZTBI")
//    SF2->F2_FLATU := Posicione("SA3", 1, xFilial("SA3") + xCodVend        , "A3_FATU")
//    SF2->F2_ZTCL  := Posicione("SA1", 1, xFilial("SA1") + cCliente + cLoja, "A1_PESSOA")
//    SF2->F2_ZFPG  := xFormaPg
// MsUnLock()			
// EndIf

   // ##############################################################
   // Carrega variáveis para gravação no cabeçalho da nota fiscal ##
   // ##############################################################
   kF2_ZTVD  := Posicione("SA3", 1, xFilial("SA3") + xCodVend        , "A3_ZTBI")
   kF2_FLATU := Posicione("SA3", 1, xFilial("SA3") + xCodVend        , "A3_FATU")
   kF2_ZTCL  := Posicione("SA1", 1, xFilial("SA1") + cCliente + cLoja, "A1_PESSOA")

   cSql := ""
   cSql := "UPDATE " + RetSqlName("SF2")
   cSql += "   SET"
   cSql += "   F2_ZTVD        = '" + Alltrim(kF2_ZTVD)  + "',"
   cSql += "   F2_FLATU       = '" + Alltrim(kF2_FLATU) + "',"
   cSql += "   F2_ZTCL        = '" + Alltrim(kF2_ZTCL)  + "',"
   cSql += "   F2_ZFPG        = '" + Alltrim(xFormaPg)  + "' "
   cSql += " WHERE F2_FILIAL  = '" + Alltrim(cFilNota)  + "' "
   cSql += "   AND F2_CLIENTE = '" + Alltrim(cCliente)  + "' "
   cSql += "   AND F2_LOJA    = '" + Alltrim(cLoja)     + "' "
   cSql += "   AND F2_DOC     = '" + Alltrim(cNumNota)  + "' "
   cSql += "   AND F2_SERIE   = '" + Alltrim(cNumSerie) + "' "
      
   lResult := TCSQLEXEC(cSql)

   // ###############################################################################################
   // Pesquisa os ítens do pedido de venda para atualiza o tipo de grupo de produtos na tabela SD2 ##
   // ###############################################################################################
   If Select("T_GRUPOS") <>  0
      T_GRUPOS->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT C6_FILIAL     , "
   cSql += "       C6_NOTA       , "
   cSql += "       C6_SERIE      , "
   cSql += "       C6_CLI        , "
   cSql += "       C6_LOJA       , "
   cSql += "       C6_NUM        , "
   cSql += "       C6_ITEM       , "
   cSql += "	   SB1.B1_GRUPO  , "
   cSql += "	   SC6.C6_PRODUTO, "
   cSql += "       SC6.C6_ZBICRET, "
   cSql += "	   SBM.BM_ZPBI     "
   cSql += "  FROM " + RetSqlName("SC6") + " SC6, "
   cSql += "       " + RetSqlName("SB1") + " SB1, "
   cSql += "       " + RetSqlName("SBM") + " SBM  "
   cSql += " WHERE SC6.C6_FILIAL  = '" + Alltrim(cFilNota)  + "'"
   cSql += "   AND SC6.C6_NOTA    = '" + Alltrim(cNumNota)  + "'"
   cSql += "   AND SC6.C6_SERIE   = '" + Alltrim(cNumSerie) + "'"
   cSql += "   AND SC6.C6_CLI     = '" + Alltrim(cCliente)  + "'"
   cSql += "   AND SC6.C6_LOJA    = '" + Alltrim(cLoja)     + "'"
   cSql += "   AND SC6.D_E_L_E_T_ = ''"
   cSql += "   AND SB1.B1_FILIAL  = ''"
   cSql += "   AND SB1.B1_COD     = SC6.C6_PRODUTO"
   cSql += "   AND SB1.D_E_L_E_T_ = ''"
   cSql += "   AND SBM.BM_GRUPO   = SB1.B1_GRUPO"
   cSql += "   AND SBM.D_E_L_E_T_ = ''"  
	
   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_GRUPOS",.T.,.T.)

   While !T_GRUPOS->( Eof() )
   
      dbSelectArea("SD2")
	  dbSetOrder(3)
	  
      If DbSeek(T_GRUPOS->C6_FILIAL + T_GRUPOS->C6_NOTA + T_GRUPOS->C6_SERIE + T_GRUPOS->C6_CLI + T_GRUPOS->C6_LOJA + T_GRUPOS->C6_PRODUTO + T_GRUPOS->C6_ITEM)
		 RecLock("SD2", .F.)
         SD2->D2_ZTGP := T_GRUPOS->BM_ZPBI

         // Tarefa Nº 001253.00 - Se tipo de pedido de venda for igual a [I], Complemento de ICMS, grava a base do ICMS retido informado no pedido de venda.
         If cTipoPV == "I"
            SD2->D2_BRICMS := T_GRUPOS->C6_ZBICRET 
         Endif

 		 MsUnLock()			
	  EndIf

	  T_GRUPOS->( dbSkip() )

   Enddo 

Return()

// ################################################################
// Função que calcula o campo margem dos produtos da nota fiscal ##
// ################################################################
Static Function Calc_Mrg_Prod(kk_Filial, kk_Pedido)

   Local cSql     := ""
   Local K_Margem := 0

   If Select("T_PRODUTOS") <>  0
      T_PRODUTOS->(DbCloseArea())
   EndIf

   cSql := ""
   cSql := "SELECT SC6.C6_FILIAL ,"
   cSql += "       SC6.C6_NUM    ,"
   cSql += "       SC6.C6_ITEM   ,"
   cSql += "	   SC6.C6_PRODUTO "
   cSql += "  FROM " + RetSqlName("SC6") + " SC6 "
   cSql += " WHERE C6_FILIAL  = '" + Alltrim(kk_Filial) + "'"
   cSql += "   AND C6_NUM     = '" + Alltrim(kk_Pedido) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
	
   cSql := ChangeQuery(cSql)
   DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PRODUTOS",.T.,.T.)

   If T_PRODUTOS->( EOF() )
      Return(.T.)
   Endif
      
   T_PRODUTOS->( DbGoTop() )

   WHILE !T_PRODUTOS->( EOF() )

      // #####################################################  
      // Calcula as margens dos produtos do pedido de venda ##
      // #####################################################
      K_Margem := 0
      K_Margem := U_AUTOM524(3            ,; // 01 - Indica a chamada pelo Pedido de Venda
                  T_PRODUTOS->C6_FILIAL   ,; // 02 - Filial
                  T_PRODUTOS->C6_NUM      ,; // 03 - Nº do Pedido de Venda
                  T_PRODUTOS->C6_ITEM     ,; // 04 - Posição do Item no Pedido de Venda
                  T_PRODUTOS->C6_PRODUTO  ,; // 05 - Código do Produto
                  0                       ,; // 06 - Posição do item
                  "R")                       // 07 - Indica tipo de retorno

      T_PRODUTOS->( DbSkip() )
      
   ENDDO
      
Return(.T.)

// #################################################################################################
// Função que verifica se há a necessidad de envio do e-mail ao financeiro para pagamento da GNRE ##
// #################################################################################################
Static Function EnviaGNREFIN(kFilial, kDocumento, kSerie, kCliente, kLoja)

   Local nValorDifal := 0
   Local cString     := ""

   // #######################################
   // Verifica se o cliente é contribuinte ##
   // #######################################
   If Posicione( "SA1", 1, xFilial("SA1") + kCliente + kLoja, "A1_CONTRIB" ) <> "2"
      Return(.T.)
   Endif

   // ##################################################################
   // Verifica o estado brasileiro do cliente conforme Empresa logada ##
   // ##################################################################
   If cEmpAnt$("01#02#04")
      If Posicione( "SA1", 1, xFilial("SA1") + kCliente + kLoja, "A1_EST" )$("SP#SC#MG#PR#RJ#RS")
         Return(.T.)
      Endif
   Else
      If Posicione( "SA1", 1, xFilial("SA1") + kCliente + kLoja, "A1_EST" )$("RS")
         Return(.T.)
      Endif
   Endif   

   // #############################################################
   // Captura o valor total do DIFAL dos produtos da nota fiscal ##
   // #############################################################         
   If Select("T_PRODUTOS") > 0
      T_PRODUTOS->( dbCloseArea() )
   EndIf
      
   cSql := ""
   cSql := "SELECT D2_FILIAL ,"
   cSql += "       D2_DOC    ,"
   cSql += "       D2_SERIE  ,"
   cSql += "       D2_CLIENTE,"
   cSql += "       D2_LOJA   ,"
   cSql += "       D2_CF     ,"
   cSql += "       D2_DIFAL   "

   Do Case
      Case cEmpAnt == "01"
           cSql += "  FROM SD2010"
      Case cEmpAnt == "02"
           cSql += "  FROM SD2020"
      Case cEmpAnt == "03"
           cSql += "  FROM SD2030"
      Case cEmpAnt == "04"
           cSql += "  FROM SD2040"
   EndCase              
              
   cSql += " WHERE D2_FILIAL  = '" + Alltrim(kFilial)    + "'"
   cSql += "   AND D2_DOC     = '" + Alltrim(kDocumento) + "'"
   cSql += "   AND D2_SERIE   = '" + Alltrim(kSerie)     + "'"
   cSql += "   AND D2_CLIENTE = '" + Alltrim(kCliente)   + "'"
   cSql += "   AND D2_FILIAL  = '" + Alltrim(kLoja)      + "'"
   cSql += "   AND D2_CF      = '6108'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTOS", .T., .T. )

   If T_PRODUTOS->( EOF() )
      Return(.T.)
   Endif
         
   nValorDifal := 0
      
   WHILE !T_PRODUTOS->( EOF() )
      nValorDifal := nValorDifal + T_PRODUTOS->D2_DIFAL
      T_PRODUTOS->( DbSkip() )
   ENDDO
      
   If nValorDifal == 0
      Return(.T.)
   Endif
  
   // ############################################
   // Elabora o e-mail para envio ao Financeiro ##
   // ############################################            
   cString := ""
   cString += "Solicitamos a geração da GNRE para o documento abaixo especificado."

   // #################
   // Início do HTML ##
   // #################
   _cHTML:='<HTML><HEAD><TITLE></TITLE>'
   _cHTML+='<META http-equiv=Content-Type content="text/html; charset=windows-1252">'
   _cHTML+='<META content="MSHTML 6.00.6000.16735" name=GENERATOR></HEAD>'
   _cHTML+='<BODY>'

   // ###########################
   // Imprime o texto da carta ##
   // ########################### 
   _cHtml	+= '<h3 align = Left><font size="2" color="#000000" face="Verdana">' + Alltrim(cString) + '</h3></font>'

   // ######################################
   // Cria o quadro dos títulos em atraso ##
   // ######################################
   _cHtml += '<TABLE WIDTH=100% BORDER=1 BORDERCOLOR="#CCCCCC" BGCOLOR=#EEE9E9 CELLPADDING=2 CELLSPACING=0 STYLE="page-break-before: always">'

   _cHtml += '	<TR ALIGN=TOP>'
   _cHtml += '		<TD ALIGN=LEFT WIDTH=60 >'
   _cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>EMPRESA</P></font>'
   _cHtml += '		</TD>'

   _cHtml += '		<TD ALIGN=CENTER WIDTH=60 >'
   _cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>FILIAL</P></font>'
   _cHtml += '		</TD>'

   _cHtml += '		<TD ALIGN=CENTER WIDTH=60 >'
   _cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>DOCUMENTO</P></font>'
   _cHtml += '		</TD>'

   _cHtml += '		<TD ALIGN=CENTER WIDTH=60 >'
   _cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>SÉRIE</P></font>'
   _cHtml += '		</TD>'

   _cHtml += '		<TD ALIGN=CENTER WIDTH=60 >'
   _cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>EMISSÃO</P></font>'
   _cHtml += '		</TD>'

   _cHtml += '		<TD ALIGN=CENTER WIDTH=60 >'
   _cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>CLIENTE</P></font>'
   _cHtml += '		</TD>'

   _cHtml += '		<TD ALIGN=CENTER WIDTH=60 >'
   _cHtml += '			<P><font size="2" color=#000000 face="Verdana"><b>VALOR GNRE</P></font>'
   _cHtml += '		</TD>'

   _cHtml += '	</TR>'

   // ######################################
   // Inclui os dados do título em atraso ##
   // ######################################
   _cHtml += '<TR ALIGN=TOP>'
   _cHtml += '		<TD ALIGN=CENTER bgcolor=#FFFFFF>'

   // ##################
   // Nome da Empresa ##
   // ##################
   Do Case
      Case cEmpAnt == "01"
           _cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> ' + 'AUTOMATECH' + '</P></font>'
      Case cEmpAnt == "02"
           _cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> ' + 'TI AUTOMAÇÃO' + '</P></font>'
      Case cEmpAnt == "03"
           _cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> ' + 'ATECH' + '</P></font>'
      Case cEmpAnt == "04"
           _cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> ' + 'ATECHPEL' + '</P></font>'
   EndCase

   _cHtml += '		</TD>'
   _cHtml += '		<TD ALIGN=LEFT bgcolor=#FFFFFF>'

   // ############################
   // Nome da Filial da Empresa ##
   // ############################
   Do Case
      Case cEmpAnt == "01"
           Do Case
              Case cFilAnt == "01" 
                   _cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> ' + 'PORTO ALEGRE' + '</P></font>'
              Case cFilAnt == "02" 
                   _cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> ' + 'CAXIAS DO SUL' + '</P></font>'
              Case cFilAnt == "03" 
                   _cHtml += '	    	<P><font size="2" color=#696969 face="Verdana"><b> ' + 'PELOTAS' + '</P></font>'
              Case cFilAnt == "04" 
                   _cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> ' + 'SUPRIMENTOS' + '</P></font>'
              Case cFilAnt == "05" 
                   _cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> ' + 'SÃO PAULO' + '</P></font>'
              Case cFilAnt == "06" 
                   _cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> ' + 'ESPIRITO SANTO' + '</P></font>'
              Case cFilAnt == "07" 
                   _cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> ' + 'PORTO ALEGRE' + '</P></font>'
           EndCase
      Case cEmpAnt == "02"
           _cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> ' + 'CURITIBA' + '</P></font>'
      Case cEmpAnt == "03"
           _cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> ' + 'PORTO ALEGRE' + '</P></font>'
      Case cEmpAnt == "04"
           _cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> ' + 'PELOTAS' + '</P></font>'
   EndCase
  
   _cHtml += '		</TD>'
   _cHtml += '		<TD ALIGN=CENTER bgcolor=#FFFFFF>'
   _cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> ' + Alltrim(kDocumento) + '</P></font>'
   _cHtml += '		</TD>'
    
   _cHtml += '		<TD ALIGN=CENTER bgcolor=#FFFFFF>'
   _cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> ' + Alltrim(kSerie) + '</P></font>'
   _cHtml += '		</TD>'

   _cHtml += '		<TD ALIGN=CENTER bgcolor=#FFFFFF>'
   _cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> ' + kCliente + "." + kLoja + '</P></font>'
   _cHtml += '		</TD>'
   
   _cHtml += '		<TD ALIGN=CENTER bgcolor=#FFFFFF>'
   _cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> ' + Alltrim(Posicione( "SA1", 1, xFilial("SA1") + kCliente + kLoja, "A1_NOME" ))  + '</P></font>'
   _cHtml += '		</TD>'
    
   _cHtml += '		<TD ALIGN=CENTER bgcolor=#FFFFFF>'
   _cHtml += '			<P><font size="2" color=#696969 face="Verdana"><b> ' + Transform(nValorDifal, "@E 9999999.99") + '</P></font>'
   _cHtml += '		</TD>'

   _cHtml += '</TR>'
	
   _cHtml 	+= '</TABLE>'

   _cHtml	+= '<br></br>'
   _cHtml	+= '<br></br>'

   kEnviadoPor := ""
   kEnviadoPor += 'Att.'                                  + '<br></br>' + '<br></br>'
   kEnviadoPor += 'Automatech Sistemas de Automação Ltda' + '<br></br>'
   kEnviadoPor += 'Área Logística'                        + '<br></br>'
   kEnviadoPor += 'www.automatech.com.br'                 + '<br></br>' + '<br></br>'

   _cHtml	+= '<br></br>'
   _cHtml	+= '<br></br>'
   _cHtml 	+= '<b><font size="1" color=#696969 face="Verdana"> E-mail enviado automaticamente, nao responda este e-mail </font></b>'
   _cHtml	+= '<br></br>'
   _cHtml	+= '<br></br>'
   _cHtml 	+= '</head>'
   _cHtml 	+= '</html>'

   // #################
   // Envia o e-mail ##
   // #################
   cParaQuem := Alltrim(aLista[nContar,07])

   lRetorno := U_AUTOMR20(_cHtml, cParaQuem, "", "SOLICITAÇÃO GERAÇÃO DE GNRE")

   // ############################################################
   // Atualiza o envio da carta no cadastro de contas a receber ##
   // ############################################################
   If lRetorno == .T.
   Else
      MsgAlert("Atenção! E-mail de solicitação de geração de GNRE não foi possível de ser enviado. Informe o financeiro.")
   Endif	  

Return(.T.)

// #############################################################################
// Função que verifica se há a necessidade de avisar usário da geração do PIN ##
// #############################################################################
Static Function EnviaMsgPIN(yFilial, yNota, ySerie, yCliente, yLoja)
      
   Local cMensagem := ""
           
   kEstado := Posicione( "SA1", 1, xFilial("SA1") + yCliente + yLoja, "A1_EST"  )
   kNome   := Posicione( "SA1", 1, xFilial("SA1") + yCliente + yLoja, "A1_NOME" )
      
   If kEstado$("AC#AM#AP#RO#RR")
      
      cMensagem := ""
      cMensagem += "ATENÇÃO!"                                                    + chr(13) + chr(10) + chr(13) + chr(10)
      cMensagem += "Necessário geração do documento PIN para:"                   + chr(13) + chr(10) + chr(13) + chr(10)
      cMensagem += "Nota Fiscal: " + yNota                                       + chr(13) + chr(10)
      cMensagem += "Série: " + ySerie                                            + chr(13) + chr(10)
      cMensagem += "Cliente: " + yCliente + "." + yLoja + " - " + Alltrim(kNome) + chr(13) + chr(10)

      Do Case
         Case kEstado == "AC"
              cMensagem += "Estado: AC - Acre"
         Case kEstado == "AM"
              cMensagem += "Estado: AM - Amazonas"
         Case kEstado == "AP"
              cMensagem += "Estado: AP - Amapá"
         Case kEstado == "RO"
              cMensagem += "Estado: RO - Rondônia"
         Case kEstado == "RR"
              cMensagem += "Estado: RR - Roraima"
      EndCase

      MsgAlert(cMensagem)
      
   Endif
   
Return(.T.)