#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch"    

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: PE_MT450FIM.PRW                                                     ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Jean Rehermann                                                      ##
// Data......: 26/09/2011                                                          ##
// Objetivo..: Tratamento dos Status dos PVs                                       ##
//             Tratamento do uso de Cartao de Credito no Faturamento               ##
//                                                                                 ##
//             Ponto de entrada MT450FIM - Liberação de crédito                    ##
//             Ponto de entrada no final da liberação manual de crédito            ##
// ##################################################################################

User Function MT450FIM()

   Local cSql     := ""
   Local cPedido  := Paramixb[ 1 ]
   Local lServ    := .F.

   // ####################
   // Cartao de Credito ##
   // ####################
// Local _lEhCartao := (SC5->C5_FORMA == "2")
   Local _lEhCartao := .F.
   Local lChumbado  := .F.

   Local aComboBx1  := {"Scaner","Manual"}
   Local cComboBx1

   Local _cIdentC5 	:= SC5->C5_NUM
   Local _aBoxForma := RetSX3Box( Posicione( "SX3", 2, "C5_FORMA", "X3CBox()" ),,, 1 )
   Local _cC5Forma  := Upper( RTrim(_aBoxForma[Ascan( _aBoxForma, { |aBox| aBox[2] = SC5->C5_FORMA } )][3]) )

   Local oGet1
   Local oGet2
   Local oGet3
   Local oGet4
   Local oGet5
   Local oGet6
   Local _lTemEstoq := .f.		// Indica se tem saldo suficienADMINte em estoque

   Local lChumba := .F.
   Local cMemo1	 := ""
   Local cMemo2	 := ""

   Local oMemo1
   Local oMemo2

   Private oDlgx

//   Private _cC5Adm	:= SC5->C5_ADM
//   Private _cC5Cartao	:= Space(4)
//   Private _cC5Autor	:= Space(6)
//   Private _cC5TID	:= Space(16)
//   Private _cC5Doc	:= Space(6)
//   Private _dC5Dat 	:= dDatabase

   Private aAdministra := {}
   Private aBandeiras  := {}
   Private cComboBx2
   Private cComboBx3
   Private kPedido     := SC5->C5_NUM
   Private kCliente    := SC5->C5_CLIENTE + "." + SC5->C5_LOJACLI + " - " + Alltrim(Posicione("SA1",1, xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI, "A1_NOME"))
   Private kDigi       := Space(04)
   Private kEmissao    := Ctod("  /  /    ")
   Private kDocumento  := Space(06)
   Private kAutoriza   := Space(06)
   Private kNumTid     := Space(16)
   Private kValorCart  := 0

   Private cComboBx1
   Private cComboBx2
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5
   Private oGet6
   Private oGet7
   Private oGet8

   U_AUTOM628("PE_MT450FIM")

   _aAreaIni := GetArea()
   _aAreaSC6 := SC6->( GetArea() )
   _aAreaSC9 := SC9->( GetArea() )
   _aAreaSC5 := SC5->( GetArea() )

   // ################################################
   // Carrega o combo de Administradoras de Cartões ##
   // ################################################
   If Select("T_ADMINISTRA") > 0
      T_ADMINISTRA->( dbCloseArea() )
   EndIf

   cSql := "SELECT SAE.AE_FILIAL,"
   cSql += "       SAE.AE_COD   ,"
   cSql += "       SAE.AE_DESC   "
   cSql += "     FROM " + RetSqlName("SAE") + " SAE "
   cSql += "    WHERE SAE.AE_FILIAL  = '" + Alltrim(xFilial("SC9")) + "'"
   cSql += "      AND SAE.D_E_L_E_T_ = ''"
   cSql += "    ORDER BY SAE.AE_DESC     "
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ADMINISTRA", .T., .T. )
   
   T_ADMINISTRA->( DbGoTop() )
   
   aAdd( aAdministra, "000000 - Selecione Administradora" )

   WHILE !T_ADMINISTRA->(EOF())
      aAdd( aAdministra, T_ADMINISTRA->AE_COD + " - " + Alltrim(T_ADMINISTRA->AE_DESC) )
      T_ADMINISTRA->( DbSkip() )
   ENDDO
       
   // #####################################################
   // Carrega o combo de Bandeiras de Cartões de Crédito ##
   // #####################################################     
   If Select("T_BANDEIRAS") > 0
      T_BANDEIRAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT X5_CHAVE,"
   cSql += "       X5_DESCRI" 
   cSql += "  FROM " + RetSqlName("SX5")
   cSql += " WHERE X5_TABELA  = 'G3'"
   cSql += "   AND D_E_L_E_T_ = ''  "
   cSql += " ORDER BY X5_DESCRI     "
                                
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_BANDEIRAS", .T., .T. )

   T_BANDEIRAS->( DbGoTop() )
   
   aAdd( aBandeiras, "000000 - Selecione a Bandeira" )

   WHILE !T_BANDEIRAS->(EOF())
      aAdd( aBandeiras, T_BANDEIRAS->X5_CHAVE + " - " + Alltrim(T_BANDEIRAS->X5_DESCRI) )
      T_BANDEIRAS->( DbSkip() )
   ENDDO

   // #############################################################################################################################################
   // Verifica pela condição de pagamento se esta é de Cartão e seta a variável lEhCartao para abrir a solicitação de dados do cartão de crédito ##
   // #############################################################################################################################################
   If Select("T_CONDICAO") > 0
      T_CONDICAO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC5.C5_FILIAL ,"
   cSql += "       SC5.C5_NUM    ,"
   cSql += "       SC5.C5_CONDPAG,"
   cSql += "	   SE4.E4_DESCRI  "
   cSql += "  FROM " + RetSqlName("SC5") + " (Nolock) SC5, "
   cSql += "       " + RetSqlName("SE4") + " (Nolock) SE4  "
   cSql += " WHERE SC5.C5_FILIAL  = '" + Alltrim(xFilial("SC9")) + "'"
   cSql += "   AND SC5.C5_NUM     = '" + Alltrim(cPedido)        + "'"
   cSql += "   AND SC5.D_E_L_E_T_ = ''"
   cSql += "   AND SE4.E4_CODIGO  = SC5.C5_CONDPAG"
   cSql += "   AND SE4.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONDICAO", .T., .T. )

   If U_P_OCCURS(T_CONDICAO->E4_DESCRI, "CARTAO", 1) == 0
      _lEhCartao := .F.
   Else
      _lEhCartao := .T.      
   Endif   

   // ###########################################
   // Pesquisa o pedido de venda na tabela SC9 ##      
   // ###########################################                                                 
   _cSql := ""
   _cSql := "SELECT C9_PEDIDO, "
   _cSql += "       C9_ITEM  , "
   _cSql += "       C9_BLCRED  "
   _cSql += "  FROM " + RetSqlName("SC9") 
   _cSql += " WHERE C9_PEDIDO = '" + Alltrim(cPedido)        + "'"
   _cSql += "   AND C9_FILIAL = '" + Alltrim(xFilial("SC9")) + "'"
   _cSql += "   AND D_E_L_E_T_ = ''"

   dbUseArea(.T.,"TOPCONN", TCGenQry(,,_cSql),"T_C9", .F., .T.)

   While !T_C9->( Eof() )
	
      dbSelectArea("SC6")
	  dbSetOrder(1)
	  dbSeek( xFilial("SC6") + T_C9->C9_PEDIDO + T_C9->C9_ITEM )
	
	  If Empty( SC6->C6_NOTA ) // Jean Rehermann | Solutio - 20/12/2012 - Validação para não alterar o status de itens de um mesmo pedido faturado parcial

	     // ############################################
		 //                Projeto PCP                ##
		 // Geraçao da OP após a liberação de credito ##
		 // ############################################
//       If (cEmpAnt == "01" .And. xfilial("SC6") == "04") .Or. ;
//          (cEmpAnt == "03" .And. xfilial("SC6") == "01") .Or. ;
//          (cEmpAnt == "01" .And. xfilial("SC6") == "07")

     	 If (LEFT(SC6->C6_PRODUTO,2) == "02" .Or. LEFT(SC6->C6_PRODUTO,2) == "03")
       	   
            //IF xfilial("SC6") == "04" .and. Empty(SC6->C6_NUMOP) .and. Empty(T_C9->C9_BLCRED) .and. (LEFT(SC6->C6_PRODUTO,2) == "02" .Or. LEFT(SC6->C6_PRODUTO,2) == "03")

            // ############  
            // Gera a OP ##
            // ############
       	    IF Empty(SC6->C6_NUMOP)   .and. ;
       	       Empty(T_C9->C9_BLCRED) .and. ;
       	       (LEFT(SC6->C6_PRODUTO,2) == "02" .Or. LEFT(SC6->C6_PRODUTO,2) == "03")
               //U_GeraOP()
		    Endif
		   
            // ##########################################################################################################
            // # 4416 - Ped. de contrato ATECH não deve cai em Ag. data de entrega. Cai em 10 - Aguardando Faturamento ##
            //          Somente para pedidos com TES = 717                                                             ##
            // ##########################################################################################################
            If SC6->C6_TES == "717"
            
               Reclock("SC6",.f.)
               SC6->C6_STATUS := "10"
               MsUnlock()
            
               // #####################################################
    		   // Gravo o log de atualização de status na tabela ZZ0 ##
    		   // #####################################################
		       U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "10", "PE_MT450FIM", 0 )
		
               // ################################
 		       // Atualiza a hora na tabela SC9 ##
 		       // ################################
               dbSelectArea("SC9")
               dbSetOrder(1)
               If dbSeek( xFilial("SC9") + SC6->C6_NUM )
	  	          RecLock("SC9",.F.)
	  	          SC9->C9_BLCRED := ""
		          SC9->C9_BLEST  := ""
   		          MsUnLock()
		       Endif

		    Else
                                                                                                                                                    
               // ##################################################################################################################################
               // Se o produto que está sendo liberado não for etiqueta, sistema verificará se o saldo do produto (SB2) atende ao pedido de venda ##
               // Se não atender, será flegado o campo C6_PCS com S indicando que este produto deverá ser enviado para o status 06 - Em Compra no ##
               // Processo de Liberação de Estoque.                                                                                               ##
               // ##################################################################################################################################
               kPCS := ""
               
       	       If (LEFT(SC6->C6_PRODUTO,2) == "02" .Or. LEFT(SC6->C6_PRODUTO,2) == "03")
               Else
    			  DbSelectArea("SB2")
 	 	 	      DbSetOrder(1)
			
			      If DbSeek(xFilial("SB2") + SC6->C6_PRODUTO + SC6->C6_LOCAL)
   	                 _nSldProduto := SaldoSB2()
			      Else
   	                 _nSldProduto := 0
			      EndIf

                  If (_nSldProduto) >= ( SC6->C6_QTDVEN )
                     kPCS := ""
                  Else
                     kPCS := "S"
                  Endif
               Endif          
               
               Reclock("SC6",.f.)
               SC6->C6_STATUS := "04"
               SC6->C6_PCS    := kPCS
               MsUnlock()
            
               // #####################################################
   		       // Gravo o log de atualização de status na tabela ZZ0 ##
    		   // #####################################################
		       U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "04", "PE_MT450FIM", 0 )
		
               // ################################
 		       // Atualiza a hora na tabela SC9 ##
 		       // ################################
               dbSelectArea("SC9")
               dbSetOrder(1)
               If dbSeek( xFilial("SC9") + SC6->C6_NUM )
	  	          RecLock("SC9",.F.)
	  	          SC9->C9_BLCRED := ""
		          SC9->C9_BLEST  := "03"
   		          MsUnLock()
		       Endif
		       
		    Endif


/*
            U_GravaSts("PE_MT450FIM")

            // ##############################################################################################################
            // Verifica aqui se o produto possui saldo.                                                                    ##
            // Se não tiver saldo, altera o status do pedido para 04 - Aguardando Liberação de Estoque.                    ##
            // Se tem saldo, verifica a data de entrega do produto.                                                        ##
            // - Se data de entrega <= Data Atual, Status 08 - Aguardando Separação, senão 05 - Aguardando Data de entrega ##
            // ##############################################################################################################
			DbSelectArea("SB2")
			DbSetOrder(1)
			
			If DbSeek(xFilial("SB2") + SC6->C6_PRODUTO + SC6->C6_LOCAL)
   	            _nSldProduto := SaldoSB2()
			Else
   	            _nSldProduto := 0
			EndIf

            If (_nSldProduto) >= ( SC6->C6_QTDVEN )

               If SC6->C6_ENTREG <= Date()

                  // #########################################
                  // Grava Status 08 - Aguardando Separação ##
                  // #########################################
                  Reclock("SC6",.f.)
                  SC6->C6_STATUS := "08"
                  MsUnlock()
            
                  // #####################################################
       		      // Gravo o log de atualização de status na tabela ZZ0 ##
    		      // #####################################################
		          U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "08", "PE_MT450FIM", 0 )
		
                  // ########################
 		          // Atualiza a tabela SC9 ##
 		          // ########################
                  dbSelectArea("SC9")
                  dbSetOrder(1)
                  If dbSeek( xFilial("SC9") + SC6->C6_NUM )
	  	             RecLock("SC9",.F.)
	  	             SC9->C9_BLCRED := ""
		             SC9->C9_BLEST  := "03"
   		             MsUnLock()
		          Endif
		          
		       Else
		          
                  // #########################################
                  // Grava Status 08 - Aguardando Separação ##
                  // #########################################
                  Reclock("SC6",.f.)
                  SC6->C6_STATUS := "05"
                  MsUnlock()
            
                  // #####################################################
       		      // Gravo o log de atualização de status na tabela ZZ0 ##
    		      // #####################################################
		          U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "05", "PE_MT450FIM", 0 )
		
                  // ########################
 		          // Atualiza a tabela SC9 ##
 		          // ########################
                  dbSelectArea("SC9")
                  dbSetOrder(1)
                  If dbSeek( xFilial("SC9") + SC6->C6_NUM )
	  	             RecLock("SC9",.F.)
	  	             SC9->C9_BLCRED := ""
		             SC9->C9_BLEST  := "02"
   		             MsUnLock()
		          Endif
		          
		       Endif   

            Else

               Reclock("SC6",.f.)
               SC6->C6_STATUS := "04"
               MsUnlock()
            
               // #####################################################
    		   // Gravo o log de atualização de status na tabela ZZ0 ##
    		   // #####################################################
		       U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "04", "PE_MT450FIM", 0 )
		
               // ################################
 		       // Atualiza a hora na tabela SC9 ##
 		       // ################################
               dbSelectArea("SC9")
               dbSetOrder(1)
               If dbSeek( xFilial("SC9") + SC6->C6_NUM )
	  	          RecLock("SC9",.F.)
	  	          SC9->C9_BLCRED := ""
		          SC9->C9_BLEST  := "03"
   		          MsUnLock()
		       Endif

		    Endif   

*/
		    
		 Else

            U_GravaSts("PE_MT450FIM")
	 
		 Endif
		 	   
	  EndIf
	
	  DbSelectArea("T_C9")
	  T_C9->( dbSkip() )
	
   Enddo

   T_C9->( dbCloseArea() )
   RestArea( _aAreaSC9 )
   RestArea( _aAreaSC6 )
   RestArea( _aAreaSC5 )
   RestArea( _aAreaIni )

   // ###################################
   // Preenchimento dos dados do Cupom ##
   // ###################################
   IF _lEhCartao
	
//	  DEFINE MSDIALOG oDlgx TITLE "Informacao Dados Cartao Credito PV "+_cIdentC5 FROM C(178),C(181) TO C(389),C(540) PIXEL
//	
//	  @ C(008),C(007) Say "Adm. Cartao"  Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
//	  @ C(022),C(007) Say "Ult.4 Dig"    Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
//	  @ C(034),C(008) Say "Dt Emissao"   Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
//	  @ C(047),C(008) Say "Documento"    Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
//	  @ C(061),C(008) Say "Autorizacao"  	Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
//	  @ C(074),C(007) Say "TID " 			Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlgx
//	
//	  @ C(007),C(043) MsGet oGet1 Var _cC5Adm      Size C(016),C(009) COLOR CLR_BLACK Picture "@X" PIXEL OF oDlgx
//	  @ C(020),C(044) MsGet oGet2 Var _cC5Cartao   Size C(040),C(009) COLOR CLR_BLACK Picture "@X" PIXEL OF oDlgx
//	  @ C(033),C(043) MsGet oGet3 Var _dC5Dat      Size C(041),C(009) COLOR CLR_BLACK Picture "@D" PIXEL OF oDlgx
//	  @ C(046),C(043) MsGet oGet4 Var _cC5Doc      Size C(041),C(009) COLOR CLR_BLACK Picture "@X" PIXEL OF oDlgx
//	  @ C(059),C(043) MsGet oGet5 Var _cC5Autor    Size C(041),C(009) COLOR CLR_BLACK Picture "@X" PIXEL OF oDlgx
//	  @ C(073),C(044) MsGet oGet6 Var _cC5TID      Size C(129),C(009) COLOR CLR_BLACK Picture "@X" PIXEL OF oDlgx
//	
//	  @ C(088),C(049) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgx ACTION( U_GRAVAC5() )
//	  @ C(088),C(087) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgx ACTION( oDlgx:End() )
//
///	  ACTIVATE MSDIALOG oDlgx CENTERED
	
      DEFINE MSDIALOG oDlgX TITLE "Informação Dados Cartão de Crédito" FROM C(178),C(181) TO C(483),C(735) PIXEL

      @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(110),C(026) PIXEL NOBORDER OF oDlgX

      @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(270),C(001) PIXEL OF oDlgX
      @ C(129),C(002) GET oMemo2 Var cMemo2 MEMO Size C(270),C(001) PIXEL OF oDlgX
      @ C(037),C(005) Say "Nº Ped.Venda"   Size C(037),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
      @ C(037),C(046) Say "Cliente"        Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
      @ C(059),C(005) Say "Administradora" Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
      @ C(081),C(005) Say "Bandeira"       Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
      @ C(104),C(005) Say "Ult.4 Dig."     Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
      @ C(104),C(035) Say "Dt.Transação"   Size C(027),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
      @ C(104),C(079) Say "Documento"      Size C(028),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
      @ C(104),C(126) Say "Autorização"    Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
      @ C(104),C(172) Say "TID"            Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlgX
      @ C(104),C(218) Say "Valor Cartão"   Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlgX

      @ C(046),C(005) MsGet    oGet1     Var   kPedido     Size C(035),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgX When lChumba
      @ C(046),C(046) MsGet    oGet2     Var   kCliente    Size C(226),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgX When lChumba
      @ C(068),C(005) ComboBox cComboBx2 Items aAdministra Size C(269),C(010)                                         PIXEL OF oDlgX
      @ C(090),C(005) ComboBox cComboBx3 Items aBandeiras  Size C(269),C(010)                                         PIXEL OF oDlgX
      @ C(113),C(005) MsGet    oGet3     Var   kDigi       Size C(024),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgX
      @ C(113),C(035) MsGet    oGet4     Var   kEmissao    Size C(038),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgX
      @ C(113),C(079) MsGet    oGet5     Var   kDocumento  Size C(040),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgX
      @ C(113),C(126) MsGet    oGet6     Var   kAutoriza   Size C(040),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgX
      @ C(113),C(172) MsGet    oGet7     Var   kNumTid     Size C(040),C(009) COLOR CLR_BLACK Picture "@!"            PIXEL OF oDlgX
      @ C(113),C(218) MsGet    oGet8     Var   kValorCart  Size C(056),C(009) COLOR CLR_BLACK Picture "@E 9999999.99" PIXEL OF oDlgX

      @ C(135),C(100) Button "Confirmar" Size C(037),C(012) PIXEL OF oDlgX ACTION( U_GRAVAC5() )
      @ C(135),C(138) Button "Voltar"    Size C(037),C(012) PIXEL OF oDlgX ACTION( oDlgX:End() )

      ACTIVATE MSDIALOG oDlgX CENTERED 

   ENDIF

   // #############################################################
   // Envia para a função que solicita o Nº da Análise do SERASA ##
   // #############################################################
   PedeAnaSerasa()
   
Return(.T.)

// #######################################
// Função que grava dados na tabela SC5 ##
// #######################################
User Function GravaC5

   // #######################################
   // Consiste os dados anbtes da gravação ##
   // #######################################
   If Substr(cComboBx2,01,06) == "000000"
      MsgAlert("Administradora de Cartão não selecionada.")
      Return(.T.)
   Endif
      
   If Substr(cComboBx3,01,06) == "000000"
      MsgAlert("Bandeira não selecionada.")
      Return(.T.)
   Endif

   If Empty(Alltrim(kNumTid))
      MsgAlert("Nº do TID não informado.")
      Return(.T.)
   Endif

   If kEmissao == Ctod("  /  /    ")
      MsgAlert("Data da Transação não informada.")
      Return(.T.)
   Endif

   If Empty(Alltrim(kAutoriza))
      MsgAlert("Nº da Autoarização não informada.")
      Return(.T.)
   Endif

   If kValorCart == 0
      MsgAlert("Valor do Cartão não informado.")
      Return(.T.)
   Endif

   Reclock("SC5",.f.)
   SC5->C5_ADM 	   := Substr(cComboBx2,01,03)
   SC5->C5_BAND    := Substr(cComboBx3,01,06)
   SC5->C5_CARTAO  := kDigi
   SC5->C5_AUTORIZ := kAutoriza
   SC5->C5_TID	   := kNumTid
   SC5->C5_DOC	   := kDocumento
   SC5->C5_DATCART := kEmissao
   SC5->C5_ZVALCRT := kValorCart
   MsUnlock()

   oDlgx:End()

Return(.t.)

// ######################################
// Função que gera a Ordem de Produção ##
// ######################################
User Function GeraOP

   Local cSql        := ""
   Local _aArea      := GetArea()
   Local _lTemEstoq  := U_TemEstoque(SC6->C6_PRODUTO,SC6->C6_LOCAL,SC6->C6_QTDVEN)
   Local nLib        := SC6->C6_QTDVEN

   Private aComp     := {}
   Private __nQtdLin := 0
   Private __nQtdM2  := 0
		
   // #############################################################
   // Pesquisa a indicação de quantidade exata                   ##
   // Se não encontrar, pesquisa no cabeçalho do Pedido de Venda ##
   // #############################################################
   DbSelectArea("SCJ")
   DbSetOrder(1)
   If DbSeek(xFilial("SCJ")+LEFT(SC6->C6_NUMORC,6))
		
      DbSelectArea("ADY")
      DbSetOrder(1)
      DbSeek(xFilial("ADY")+SCJ->CJ_PROPOST)
		
      _lQtdExata    := Iif(ADY->ADY_QEXAT == "S",.T.,.F.)
      
   Else

      _lQtdExata    := Iif(SC5->C5_QEXAT == "S",.T.,.F.)
      
   Endif
		
   cNumOp   := GetNumSc2(.T.)
   cItemOp  := SC6->C6_ITEM
   cSeqC2   := "001"

   // ##########################
   // Gera OP Automaticamente ##
   // ##########################

   // ######################
   // Posiciona registros ##
   // ######################
   dbSelectArea("SB1")
   dbSetOrder(1)
   MsSeek(xFilial("SB1") + SC6->C6_PRODUTO)
		
   dbSelectArea("SF4")
   dbSetOrder(1)
   MsSeek(xFilial("SF4") + SC6->C6_TES)

   dbSelectArea("SB2")
   dbSetOrder(1)
   If !MsSeek(xFilial("SB2")+SC6->C6_PRODUTO+SC6->C6_LOCAL)
	  CriaSB2(SC6->C6_PRODUTO,SC6->C6_LOCAL)
   EndIf
		
   // ##############################################################################################################
   // Data de entrega do PV n'ao [e alterada na liberacao de credito                                              ##
   // dEntrega := U_CalcPrevEnt(SC6->C6_PRODUTO    ,;                                                             ##
   //                           SC6->C6_QTDVEN*1000,;                                                             ##
   //                           SC5->C5_EMISSAO    ,;                                                             ##
   //                           Posicione("SA1",1, xFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI, "A1_EST")) ##
   // ##############################################################################################################
// IF SF4->F4_ESTOQUE == "S"

   _Estoque := Posicione( "SF4", 1, xFilial("SF4") + SC6->C6_TES, "F4_ESTOQUE")

   If _Estoque == "S"
                                         
	  //Reclock("SC6",.f.)
	  //IF _lTemEstoq
	  //   SC6->C6_ENTREG := dDatabase  //Entrega pela database da liberação de credito
	  //Else
	  //   SC6->C6_ENTREG := dEntrega
	  //Endif
	  //MsUnlock()

      // #####################################################
      // Soma não liberados... parametro MV_GRVBLQ2 ativado ##
      // #####################################################
      If Select("T_SQL") > 0
         T_SQL->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ISNULL(SUM(SC9.C9_QTDLIB),0) NLIB "
      cSql += "  FROM " + RetSqlName("SC9") + " SC9 "
      cSql += " WHERE SC9.C9_FILIAL   = '" + Alltrim(cFilAnt)         + "'"
      cSql += "   AND SC9.C9_PEDIDO   = '" + Alltrim(SC6->C6_NUM)     + "'"
      cSql += "   AND SC9.C9_PRODUTO  = '" + Alltrim(SC6->C6_PRODUTO) + "'"
      cSql += "   AND SC9.C9_BLEST   <> ''"
      cSql += "   AND SC9.D_E_L_E_T_ <> '*'"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SQL", .T., .T. )

//	  DBSelectArea("_SQL")

	  nLib := T_SQL->NLIB

//    DBCloseArea("_SQL")
			    
      dbSelectArea("SB2")
      
//    // ###########################################################
//    // Verifica se existe saldos para o produto para gerar a op ##
//    // ###########################################################
//	  DbSelectArea("SB1")
//	  DbSetOrder(1)
//	  DbSeek( xFilial("SB1") + SC6->C6_PRODUTO )
//
//    kSaldoDisp := SaldoSb2()
//      
//    If kSaldoDisp > 0
//       If kSaldoDisp < nLib                   
////        nLib := nLib - kSaldoDisp
//       Endif
//    Endif      
//
//    dbSelectArea("SB2")

      // #################################################################
      // Pesquisa o saldo disponível do produto pela nova regra (Juan). ##
      // Pesquisa do saldo no local 01                                  ##
      // #################################################################                                                                          
      kSaldoDisp := 0

      If Select("T_SALDOPRO") > 0
         T_SALDOPRO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT B2_FILIAL ,"
      cSql += "       B2_COD    ,"
      cSql += "       B2_LOCAL  ,"
	  cSql += "       B2_QATU   ,"
	  cSql += "       B2_QACLASS,"
	  cSql += "       B2_RESERVA,"
      cSql += "      (B2_QATU - B2_QACLASS - B2_RESERVA) AS SALDO"
      cSql += "  FROM " + RetSqlName("SB2")
      cSql += " WHERE B2_FILIAL  = '" + Alltrim(cFilAnt)         + "'"
      cSql += "   AND B2_COD     = '" + Alltrim(SC6->C6_PRODUTO) + "'"
      cSql += "   AND B2_LOCAL   = '01'"
      cSql += "   AND D_E_L_E_T_ = ''  "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SALDOPRO", .T., .T. )

      If T_SALDOPRO->SALDO <= 0
  	  Else
   	     nLib := nLib - T_SALDOPRO->SALDO
   	  Endif   
      			
//	  IF _lTemEstoq
//         // ##############
//		 // Tem Estoque ##
//		 // ##############
//	  Else
 
	  If nLib > 0
	
		  	 // ##########################
	  	 // Nao tem estoque Gera OP ##                                  
	  	 // cSeqC2:=Soma1(cSeqc2)   ##
		 // cItemOP:=Soma1(cItemOP) ##
		 // ##########################
		 aColsC2 :={}
		 aAdd(aColsC2,{"C2_NUM"		, cNumOp			,NIL})
		 aAdd(aColsC2,{"C2_ITEM"	, cItemOp			,NIL})
		 aAdd(aColsC2,{"C2_SEQUEN"	, cSeqC2			,NIL})
	   //aAdd(aColsC2,{"C2_QUANT"	, SC6->C6_QTDVEN	,NIL})
		 aAdd(aColsC2,{"C2_QUANT"	, nLib		        ,NIL})
		 aAdd(aColsC2,{"C2_QUJE"	, 0					,NIL})
		 aAdd(aColsC2,{"C2_PRODUTO"	, SC6->C6_PRODUTO	,NIL})
		 aAdd(aColsC2,{"C2_DATPRF"	, IIF(EMPTY(SC6->C6_ENTREG),dDataBase,SC6->C6_ENTREG), NIL})
		 aAdd(aColsC2,{"C2_DATPRI"	, dDataBase			,NIL})
		 aAdd(aColsC2,{"C2_UM"		, SC6->C6_UM		,NIL})
		 aAdd(aColsC2,{"C2_TPOP"	, "F"				,NIL})
		 aAdd(aColsC2,{"C2_OBS"		, "PV :"+SC6->C6_NUM+"/"+SC6->C6_ITEM+" "+IIF(_lQtdExata,"EXATA",""),NIL})
		 aAdd(aColsC2,{"C2_PEDIDO"	, SC6->C6_NUM		,NIL})
		 aAdd(aColsC2,{"C2_ITEMPV"	, SC6->C6_ITEM		,NIL})
		 aAdd(aColsC2,{"C2_DESTINA"	, "P"				,NIL})
		 aAdd(aColsC2,{"C2_SEQPAI"	, "000"				,NIL})
		 aAdd(aColsC2,{"C2_ZDOE"   	, IIF(EMPTY(SC6->C6_ENTREG),dDataBase,SC6->C6_ENTREG), NIL})
		 aAdd(aColsC2,{"AUTEXPLODE"  , "S"				,NIL})
				
		 lMSErroAuto := .F.
		 MSExecAuto({|x,y| Mata650(x,y)},aColsC2,3)

         // ###############################################
		 // MSExecAuto({|x,y| Mata650(x,y)},_aOrdProd,3) ##
		 // ###############################################
		 If lMSErroAuto
		    Mostraerro()
		    DisarmTransaction()
		    lImprime 	:= .f.
		    lContinua 	:= .f.
		    Break	//o Break joga para depois do EndTransaction
		 Else
		    //
		 Endif
				
	     // #############################################################
	     // Guarda o Numero da Ordem de Producao no Orcamento de Venda ##
	     // #############################################################
         dbSelectArea("SC6")
	     dbSetOrder(1)
	     dbSeek( xFilial("SC6") + T_C9->C9_PEDIDO + T_C9->C9_ITEM )

	     RecLock("SC6",.F.)
	     SC6->C6_NUMOP  := cNumOp
	     SC6->C6_ITEMOP := cItemop
	     SC6->C6_OP     := "01" 
         SC6->C6_STATUS := "07" // Em produção (pedido com OP em aberto)

         MsUnlock()           

         U_GrvLogSts(SC6->C6_FILIAL, SC6->C6_NUM, SC6->C6_ITEM, "07", "U_GERAOP") // Gravo o log de atualização de status na tabela ZZ0

		 A650PutBatch(SC2->C2_FILIAL + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + SC2->C2_ITEMGRD,.T.,SC2->C2_DATPRI,SC2->C2_DATPRF)
		 U_CalcPerda("OP", SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN, SC2->C2_PRODUTO, .T.)

// -------------------------------------

//         // ###############################################################################
//         // Calcula a metragem linear a ser gravada no campo C2_QUANT para atender a ACD ##
//         // ###############################################################################
//         aComp     := U_BuscaComp()		//	[	QUERY PARA BUSCAR COMPONENTES DA OP	]		
//         __nQtdLin := U_CalcPerda("OP", SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN, SC2->C2_PRODUTO, .F.)
//	     __nQtdM2  := IIF(Len(aComp) > 0, __nQtdLin * aComp[1][8],0)
//
//         // ###################################
//         // Atualiza a metragem linear na op ##
//         // ###################################
//         DbSelectArea("SC2")
//         If DBSEEK(xFilial("SC2") + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN)
//            RecLock("SC2",.F.)
//            SC2->C2_ZQTD := SC2->C2_QUANT
//            SC2->C2_QUANT:= __nQtdLin
//            MsUnLock()              
//         Endif

           U_GravaSts("PE_MT450FIM")    		   

 	  Else
 	     
 	     // #############################################################################################
 	     // Se não for aberta a OP, analisa se envia para separação ou para aguardando data de entrega ##
 	     // #############################################################################################
         If Dtos(SC6->C6_ENTREG) > Dtos(DATE())

      		RecLock( "SC6", .F. )
    		SC6->C6_STATUS := "05" 
            MsUnlock()           

       		// ########################################################
    		// Atualiza o log de atualização de status na tabela ZZ0 ##
    		// ########################################################
		    U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "05", "PE_MT450FIM", 0 )

         Else

            RecLock( "SC6", .F. )
    		SC6->C6_STATUS := "08" 
            MsUnlock()           

            // ########################################################
            // Atualiza o log de atualização de status na tabela ZZ0 ##
            // ########################################################
            U_GrvLogSts( xFilial("SC6"), SC6->C6_NUM, SC6->C6_ITEM, "08", "PE_MT450FIM", 0 )

	     Endif
 	  
 	  ENDIF

  ENDIF

  RestArea(_aArea)

Return(.T.)

// #####################################################################
// Função que abre a janela de solicitação do Nº da Análise do SERASA ##
// #####################################################################
Static Function PedeAnaSERASA()

   Local cMemo1	 := ""
   Local oMemo1
   
   Private cAnaSerasa := Space(20)
   Private oGet1

   Private oDlgAna

   DEFINE MSDIALOG oDlgAna TITLE "Nº Análise SERASA" FROM C(178),C(181) TO C(330),C(438) PIXEL

   @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(122),C(022) PIXEL NOBORDER OF oDlgAna

   @ C(028),C(002) GET oMemo1 Var cMemo1 MEMO Size C(122),C(001) PIXEL OF oDlgAna

   @ C(033),C(026) Say "Nº Análise do SERASA" Size C(056),C(008) COLOR CLR_BLACK PIXEL OF oDlgAna

   @ C(042),C(026) MsGet oGet1 Var cAnaSerasa Size C(075),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgAna

   @ C(058),C(045) Button "Continuar" Size C(037),C(012) PIXEL OF oDlgAna ACTION( GravaAnaSerasa() )

   ACTIVATE MSDIALOG oDlgAna CENTERED 

Return(.T.)

// #######################################
// Função que grava dados na tabela SC5 ##
// #######################################
Static Function GravaAnaSerasa()

   // ###################################################
   // Atualiza o Nº da Análise do SERASA na tabela SC5 ##
   // ###################################################
   Reclock("SC5",.f.)
   SC5->C5_ZSER := cAnaSerasa
   MsUnlock()

   oDlgAna:End()

Return(.t.)