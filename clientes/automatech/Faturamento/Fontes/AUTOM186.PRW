#INCLUDE "rwmake.Ch"
#INCLUDE "Protheus.Ch"
#include "ap5mail.ch"
#include "colors.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAวรO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AUTOM186.PRW                                                        ##
// Parโmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L๖schenkohl                                             ##
// Data......: 09/08/2013                                                          ##
// Objetivo..: Programa que emite boleto bancแrio pela utiliza็ใo de condi็ใo de   ##
//             pagamento que permite o vendedor emitํ-lo pelo pedido de venda.     ##
// ##################################################################################

User Function AUTOM186(x__Filial, x__Pedido, x_Operacao, x_Parcela, x_Vencimento, x_Valor)

   LOCAL lPrimVez     := .T.
   LOCAL aDadosEmp    := {}
   LOCAL xMensg1	  := ""
   LOCAL xMensg2	  := ""
   LOCAL lBoleto   	  := .f. //Caso o boleto seja gerado somento pelo financeiro.
   Local cSql         := ""
   Local cCondicao    := ""
   Local cEZero       := .F.
   Local nContar      := 0
   Local cCompara     := ""
   Local cSql         := ""
   Local cQuery       := ""
   Local nContar      := 0
   Local aArea        := GetArea()
   Local nValorRateio := 0

   PRIVATE oPrint
   Private aRetDife     := {}
   Private _nValICMST   := 0
   PRIVATE lPrint     	:= .F.
   PRIVATE cPerg      	:= ""
   PRIVATE nPagNum    	:= 0
   PRIVATE nTaxaDia   	:= 0.0033333
   PRIVATE nTaxaMul   	:= 3
   PRIVATE nVlAtraso  	:= 0
   PRIVATE xBanco     	:= ""
   PRIVATE xNumBanco  	:= ""
   PRIVATE xNomeBanco 	:= ""
   PRIVATE xAgencia   	:= ""
   PRIVATE xConta     	:= ""
   PRIVATE xDvConta   	:= ""
   PRIVATE xCartCob   	:= ""
   PRIVATE xCodCedente	:= ""
   PRIVATE xNossoNum  	:= ""
   PRIVATE _cNossoNum 	:= ""
   PRIVATE xDvNossoNum	:= ""
   PRIVATE xMsg1      	:= ""
   PRIVATE xMsg2      	:= ""
   PRIVATE cCartNnDvDv	:= ""
   PRIVATE cCodCli    	:= ""
   PRIVATE xEmailTo   	:= ""
   PRIVATE cTabParc   	:= "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
   PRIVATE aParcelas    := {}
   PRIVATE aBoleto      := {}
   Private __Filial     := x__Filial
   Private __Pedido     := x__Pedido
   Private Arq_cliente  := ""
   Private Arq_lojaCli  := ""
   Private Arq_EmailCl  := ""
   Private Arq_Pedido   := ""
   Private Arq_Condicao := ""
   Private Arq_Emissao  := ""
   Private Arq_Vendedor := ""
   Private x_Documento  := ""

   // ##################################################################
   // Variแveis utilizadas para o cแlculo do Dif. de Alํquota de ICMS ##
   // ##################################################################
   Private aPrdSol  := {}  // Array com os produtos: {PRODUTO, TOTAL_DO_ITEM, TES, MOEDA}
   Private aPSolic  := {}  // Array com os produtos: {PRODUTO, TOTAL_DO_ITEM, TES, MOEDA}
   Private cEntCod  := ""  // C๓digo da entidade (cliente ou prospect)
   Private cLojEnt  := ""  // Loja da entidade
   Private nFrtVal  := 0   // Valor do frete para ser rateado proporcionalmente nos itens antes do calculo do icms
   Private nSolRet  := 0   // Valor de imposto retido calculado e retornado na fun็ใo AUTOM208
   Private aDifIcm  := {}  // Array transit๓rio que cont้m os valores do diferencial de icms por moeda (R$/U$)
   Private nContarx := 0   // Contador do Array aDifIcm
   Private aResumoV := {}  // Array que guarda os resultados para display da Planilha de Cแlculo

   Private xRetiR     := 0
   Private xRetiD     := 0

   U_AUTOM628("AUTOM186")

   // ############################
   // Carrega o Array aDadosEmp ##
   // ############################
   SM0->(DbSeek(cEmpAnt+cFilAnt))
   aDadosEmp  := {	SM0->M0_NOMECOM                                                                   ,;	// [1]Nome da Empresa
                    SM0->M0_ENDCOB                                                                    ,;    // [2]Endere็o
                    AllTrim(SM0->M0_BAIRCOB) + ", " + AllTrim(SM0->M0_CIDCOB)  + ", " + SM0->M0_ESTCOB,;	// [3]Complemento
                    "CEP: " + Transform(SM0->M0_CEPCOB,"@R 99.999-999")                               ,; 	// [4]CEP
                    "PABX/FAX: " + SM0->M0_TEL                                                        ,; 	// [5]Telefones
                    Transform(SM0->M0_CGC,"@R 99.999.999/9999-99")                                    ,;	// [6]CNPJ
                    "I.E.: " + Transform(SM0->M0_INSC,"@R 999/99999999999")}	                            // [7]Insc Estadual

   // ############################################
   // Pesquisa o Valor Total do Pedido de Venda ##
   // ############################################
   If Select("T_PEDIDO") > 0
      T_PEDIDO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.C6_FILIAL,"
   cSql += "       A.C6_NUM   ,"
   cSql += "       A.C6_CLI   ,"
   cSql += "       A.C6_LOJA  ,"
   cSql += "      (SELECT SUBSTRING(C5_EMISSAO,07,02) + '/' + SUBSTRING(C5_EMISSAO,05,02) + '/' + SUBSTRING(C5_EMISSAO,01,04)"
   cSql += "         FROM " + RetSqlName("SC5") 
   cSql += "        WHERE C5_FILIAL  = A.C6_FILIAL"
   cSql += "          AND C5_NUM     = A.C6_NUM   "
   cSql += "          AND D_E_L_E_T_ = '') AS EMISSAO,"
   cSql += "      (SELECT C5_CONDPAG"
   cSql += "         FROM " + RetSqlName("SC5")
   cSql += "        WHERE C5_FILIAL  = A.C6_FILIAL"
   cSql += "          AND C5_NUM     = A.C6_NUM   "
   cSql += "          AND D_E_L_E_T_ = '') AS CONDICAO,"
   cSql += "      (SELECT C5_FRETE"
   cSql += "         FROM " + RetSqlName("SC5") 
   cSql += "        WHERE C5_FILIAL  = A.C6_FILIAL"
   cSql += "          AND C5_NUM     = A.C6_NUM   " 
   cSql += "          AND D_E_L_E_T_ = '') AS FRETE,"
   cSql += "      (SELECT C5_VEND1"
   cSql += "         FROM " + RetSqlName("SC5") 
   cSql += "        WHERE C5_FILIAL  = A.C6_FILIAL"
   cSql += "          AND C5_NUM     = A.C6_NUM   " 
   cSql += "          AND D_E_L_E_T_ = '') AS VENDEDOR,"
   cSql += "       SUM(A.C6_VALOR) AS TOT_PRODUTO"
   cSql += "  FROM " + RetSqlName("SC6") + " A "
   cSql += " WHERE A.C6_NUM     = '" + Alltrim(__Pedido) + "'"
   cSql += "   AND A.C6_FILIAL  = '" + Alltrim(__Filial) + "'"
   cSql += "   AND A.D_E_L_E_T_ = ''" 
   cSql += " GROUP BY A.C6_FILIAL, A.C6_NUM, A.C6_CLI, A.C6_LOJA"

   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PEDIDO",.T.,.T.)

   // #####################################################################################
   // Envia para a fun็ใo que calcula as parcelas e vencimentos para emissใo dos boletos ##
   // #####################################################################################
   If x_Operacao == "I"

      // ####################################################################################
      // Calcula o valor do ICMS Retido para ser somado junto com o total a ser desdobrado ##
      // ####################################################################################
      If Select("T_CALDIFAL") > 0
         T_CALDIFAL->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.C6_FILIAL ,"
      cSql += "       A.C6_NUM    ,"
      cSql += "       A.C6_CLI    ,"
      cSql += "       A.C6_LOJA   ,"
      cSql += "       A.C6_ITEM   ,"
      cSql += "       A.C6_PRODUTO,"
      cSql += "       A.C6_VALOR  ,"
      cSql += "       A.C6_TES    ,"
      cSql += "       B.C5_MOEDA  ,"
      cSql += "       A.C6_DESCRI ," 
      cSql += "       B.C5_FRETE  ,"
      cSql += "       B.C5_CLIENTE,"
      cSql += "       B.C5_LOJACLI "
      cSql += "  FROM " + RetSqlName("SC6") + " A, "
      cSql += "       " + RetSqlName("SC5") + " B  "
      cSql += " WHERE A.C6_FILIAL  = '" + Alltrim(__Filial) + "'"
      cSql += "   AND A.C6_NUM     = '" + Alltrim(__Pedido) + "'"
      cSql += "   AND A.D_E_L_E_T_ = ''"
      cSql += "   AND A.C6_FILIAL  = B.C5_FILIAL"
      cSql += "   AND A.C6_NUM     = B.C5_NUM"

      cQuery := ChangeQuery(cQuery)
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CALDIFAL",.T.,.T.)

      // #####################################################################################
      // Acumula o valor total dos produtos para rateio do valor do frete entre os produtos ##
      // #####################################################################################
      T_CALDIFAL->( DbGoTop() )
      
      nValorRateio := 0

      WHILE !T_CALDIFAL->( EOF() )
         nValorRateio := nValorRateio + T_CALDIFAL->C6_VALOR
         T_CALDIFAL->( DbSkip() )
      ENDDO   

      T_CALDIFAL->( DbGoTop() )
      
      _nValICMST := 0  
      
      WHILE !T_CALDIFAL->( EOF() )

         // #############################
         // Pesquisa o tipo de cliente ##
         // #############################
         xTipoCli := POSICIONE("SA1",1,XFILIAL("SA1") + T_CALDIFAL->C5_CLIENTE + T_CALDIFAL->C5_LOJACLI, "A1_TIPO")

         // ###############################
         // Calculo ST e Outros Impostos ##
         // ###############################                     
         MaFisIni(T_CALDIFAL->C5_CLIENTE, T_CALDIFAL->C5_LOJACLI, "C", "N", xTipoCli, MaFisRelImp("MTR700",{"SC5","SC6"}),,,"SB1","MTR700")

         // #########################################################
         // Proporcionaliza o valro do frete para cแlculo do Difal ##
         // #########################################################
         If T_CALDIFAL->C5_FRETE == 0
            nFreteRat   := 0
         Else
            nPercentual := Round((T_CALDIFAL->C6_VALOR / nValorRateio) * 100,2)
            nFreteRat   := Round((T_CALDIFAL->C5_FRETE * nPercentual) / 100,2)
         Endif

         // ######################
         // Calcula os Impostos ##
         // ######################
         MaFisAdd(T_CALDIFAL->C6_PRODUTO           ,; // 01 - C๓digo do Produto (Obrigat๓rio)
                  T_CALDIFAL->C6_TES               ,; // 02 - C๓digo do TES (Obrigat๓rio)
                  T_CALDIFAL->C6_QTDVEN            ,; // 03 - Quantidade de Venda do Produto (Obrigat๓rio)
                  T_CALDIFAL->C6_PRCVEN            ,; // 04 - Pre็o Unitแrio de Venda do Produto (Obrigat๓rio)
                  0                                ,; // 05 - Valor do Desconto (Opcional)
                  ""                               ,; // 06 - Nบ da NF Original (Devolu็ใo/Beneficiamento)
                  ""                               ,; // 07 - S้rie da NF Original (Devolu็ใo/Beneficiamento)
                  0                                ,; // 08 - RecNo da NF Original do arq SD1/SD2
                  0                                ,; // 09 - Valor do Frete do Item ( Opcional )
                  0                                ,; // 10 - Valor da Despesa do item ( Opcional )
                  0                                ,; // 11 - Valor do Seguro do item ( Opcional )
                  0                                ,; // 12 - Valor do Frete Autonomo ( Opcional )
                  T_CALDIFAL->C6_VALOR + nFreteRat ,; // 13 - Valor da Mercadoria ( Obrigatorio )
                  0                                ,; // 14 - Valor da Embalagem ( Opiconal )
                  0                                ,; // 15 - RecNo do SB1
                  0)                                  // 16 - RecNo do SF4
           
          // #################################
          // Captura os valores de impostos ##
          // #################################
          _nAliqIcm := MaFisRet(1,"IT_ALIQICM")
          _nValIcm  := MaFisRet(1,"IT_VALICM" )
          _nBaseIcm := MaFisRet(1,"IT_BASEICM")
          _nValIpi  := MaFisRet(1,"IT_VALIPI" )
          _nValMerc := MaFisRet(1,"IT_VALMERC")
          _nValSol  := MaFisRet(1,"IT_VALSOL" )
          aDifalPF  := MaFisRet(1,"IT_LIVRO"  )

          MaFisEnd()         

          xRetiR := xRetiR + _nValSol

          T_CALDIFAL->( DbSkip() )           

      ENDDO

//	     aAdd( aPrdSol, { T_CALDIFAL->C6_PRODUTO, ;
//	                      T_CALDIFAL->C6_VALOR  , ;
//	                      T_CALDIFAL->C6_TES    , ;
//	                      T_CALDIFAL->C5_MOEDA  , ;
//	                      T_CALDIFAL->C6_ITEM   , ;
//	                      T_CALDIFAL->C6_DESCRI } )
//
////         aRetDife   := {} 
////         aRetDife   := U_AUTOM232( T_CALDIFAL->C6_FILIAL, T_CALDIFAL->C6_NUM, T_CALDIFAL->C6_ITEM, T_CALDIFAL->C6_PRODUTO, 0, "PV")
////         _nValICMST := _nValICMST + aRetDife[ 1 ]
//
//         T_CALDIFAL->( DbSkip() )
//
//      ENDDO
//               
//      cEntCod  := SC5->C5_CLIENT
//      cLojEnt  := SC5->C5_LOJACLI
//      nFrtVal  := SC5->C5_FRETE
//      cAnoData := SC5->C5_EMISSAO
//
//      nSolRet := U_AUTOM208( aPrdSol, cEntCod, cLojEnt, nFrtVal, 1, "T", cAnoData, "", "", __Filial )
//
//      xRetiR := nSolRet

//    aParcelas := Condicao( (T_PEDIDO->TOT_PRODUTO + T_PEDIDO->FRETE + _nValICMST), T_PEDIDO->CONDICAO )

      aParcelas := Condicao( (T_PEDIDO->TOT_PRODUTO + T_PEDIDO->FRETE + xRetiR), T_PEDIDO->CONDICAO )

   Else

      aAdd( aParcelas, { Ctod(x_Vencimento), x_Valor } )

   Endif

   If Len(aParcelas) == 0
      MsgAlert("Nใo existem parcelas a serem impressas.")
      Return(.T.)
   Endif      

   // ##################################################### 
   // Inํcio do la็o que prepara os dados para impressใo ##
   // #####################################################
   For nContar = 1 to Len(aParcelas)

       // ###############################################
       // Pesquisa dados do Cliente do Pedido de Venda ##
       // ###############################################
       DbSelectArea("SA1")
	   DbSetOrder(1)
	   DbSeek(xFilial("SA1") + T_PEDIDO->C6_CLI + T_PEDIDO->C6_LOJA)
                    
 	   aDatSacado   := {}
	   cCodCli      := AllTrim(SA1->A1_COD) + AllTrim(SA1->A1_LOJA)
   
       Arq_Cliente  := AllTrim(SA1->A1_COD) 
       Arq_LojaCli  := AllTrim(SA1->A1_LOJA)
       Arq_EmailCl  := AllTrim(SA1->A1_EMAIL)
       Arq_Pedido   := T_PEDIDO->C6_NUM
       Arq_Condicao := T_PEDIDO->CONDICAO
       Arq_Emissao  := Ctod(T_PEDIDO->EMISSAO)
       Arq_Vendedor := T_PEDIDO->VENDEDOR
	
	   If !Empty(SA1->A1_ENDCOB)
	   	  aDatSacado := {AllTrim(SA1->A1_NOME)                                      ,;	// [1]Razใo Social
		                 AllTrim(SA1->A1_COD ) + "-" + SA1->A1_LOJA                 ,;	// [2]C๓digo
		                 AllTrim(SA1->A1_ENDCOB ) + " - " + AllTrim(SA1->A1_BAIRROC),;	// [3]Endere็o
		                 AllTrim(SA1->A1_MUNC )                                     ,;	// [4]Cidade
		                 SA1->A1_ESTC                                               ,;	// [5]Estado
		                 SA1->A1_CEPC                                               ,;	// [6]CEP
		                 SA1->A1_CGC}												    // [7]CGC
	   Else
		  aDatSacado := {AllTrim(SA1->A1_NOME)                                      ,;	// [1]Razใo Social
		                 AllTrim(SA1->A1_COD ) + "-" + SA1->A1_LOJA                 ,;	// [2]C๓digo
		                 AllTrim(SA1->A1_END ) + " - " + AllTrim(SA1->A1_BAIRRO)    ,;  // [3]Endere็o
		                 AllTrim(SA1->A1_MUN )                                      ,;	// [4]Cidade
	                 	 SA1->A1_EST                                                ,;	// [5]Estado
		                 SA1->A1_CEP                                                ,;	// [6]CEP
	 	                 SA1->A1_CGC}												    // [7]CGC
	   EndIf
	
	   xMsg1       := "ATษ O VENCIMENTO PAGUE PREFERENCIALMENTE NO ITAU"
	   xMsg2       := "APOS O VENCIMENTO PAGUE SOMENTE NO ITAU"
	
       Do Case

          // ########################################
          // Grupo Empresa -> 01 - Porto Alegre/RS ##
          // ########################################
          Case cEmpAnt == "01"
               xBanco 	  := "341"
               xNomeBanco  := "BANCO ITAU"
               xNumBanco   := "341"
               xCartCob    := "109"
               xCodCedente := "890866"
	           xConta      := "890866    "
	           xDVConta    := ""
	           xAgencia    := "0296 "
               kFilial     := "01"

          // #####################################
          // Grupo Empresa -> 02 - TI AUTOMAวรO ##
          // #####################################
          Case cEmpAnt == "02"
     	       xBanco 	  := "341"
	           xNomeBanco  := "BANCO ITAU"
	           xNumBanco   := "341"
	           xCartCob    := "109"
	           xCodCedente := "985875"
	           xConta      := "98587     "
	           xDVConta    := "5"
	           xAgencia    := "0624 "
               kFilial     := "01"

          // ##############################
          // Grupo Empresa -> 03 - Atech ##
          // ##############################
          Case cEmpAnt == "03"
       	       xBanco 	  := "341"
	           xNomeBanco  := "BANCO ITAU"
	           xNumBanco   := "341"
	           xCartCob    := "109"
	           xCodCedente := "049663"
	           xConta      := "049663    "
	           xDVConta    := ""
	           xAgencia    := "0328 "
               kFilial     := "01"

      EndCase	          
	
	  aDadosBanco  := { xNumBanco        ,; // [1]Numero do Banco
 	                    xNomeBanco       ,; // [2]Nome do Banco
	                    Alltrim(xAgencia),; // [3]Ag๊ncia
	                    Alltrim(xConta)  ,; // [4]Conta Corrente
	                    xDvConta         ,;	// [5]Dํgito da conta corrente
	                    xCartCob         ,;	// [6]Codigo da Carteira
	                    xCodCedente } 	    // [7]Codigo Cedente
	
      If cEmpAnt == "02"
         xx_SubConta := "005"
      Else
         xx_SubConta := "001"         
      Endif
	
	   DbSelectArea("SEE")
	   DbSetOrder(1)
	   If !DbSeek(kFilial + xNumBanco + xAgencia + xConta + xx_SubConta) 
		  MsgAlert("Conta Cobran็a Sem Parโmetros !")
		  Set Century Off
		  DbSelectArea("T_SE1")
		  DbCloseArea()
		  Return(.T.)
	   EndIf

//	   DbSelectArea("T_SE1")
//	   If !Empty(T_SE1->E1_PARCELA)
//	   	  nPos     := AT(T_SE1->E1_PARCELA,cTabParc)
//		  cParcela := StrZero(nPos,2)
//	   Else
//	      cParcela := "00"
//	   EndIf
	
	   //Se for da rotina chamada pela gera็ใo da NF, pega o nosso n๚mero do SEE.
// 	   cQuery := {}
//	   cQuery := " SELECT EE_NUMBCO "
//	   cQuery += "   FROM " + RETSQLNAME("SEE")
//	   cQuery += "  WHERE EE_FILIAL  = '01'"
//	   cQuery += "    AND EE_CODIGO  = '341'"
//	   cQuery += "    AND EE_AGENCIA = '0296'"
//	   cQuery += "    AND EE_CONTA   = '890866'"
//	   cQuery += "    AND EE_SUBCTA  = '001'"
//	   cQuery += "    AND D_E_L_E_T_ <> '*'"

	   cQuery := {}
	   cQuery := " SELECT EE_NUMBCO"
	   cQuery += "   FROM "+ RETSQLNAME("SEE")
	   cQuery += "  WHERE EE_FILIAL  = '" + Alltrim(kFilial)     + "'"
       cQuery += "    AND EE_CODIGO  = '" + Alltrim(xBanco)      + "'"
       cQuery += "    AND EE_AGENCIA = '" + Alltrim(xAgencia)    + "'"
       cQuery += "    AND EE_CONTA   = '" + Alltrim(xConta)      + "'"
       cQuery += "    AND EE_SUBCTA  = '" + Alltrim(xx_SubConta) + "'"
       cQuery += "    AND D_E_L_E_T_ <> '*' "

	   cQuery := ChangeQuery(cQuery)
	   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'TEMPSEE',.T.,.T.)

  	   DbSelectArea("TEMPSEE")
	   xNossoNum := TEMPSEE->EE_NUMBCO
	   DbSelectArea("TEMPSEE")
	   DbCloseArea()
		
	   // Caso nใo encontre, finaliza a opera็ใo.
	   If Empty(xNossoNum)
	  	  MsgAlert("Nใo foi possํvel localizar o registro. Favor verificar!")
		  Return()
	   EndIf

	   _cNossoNum := STRZERO(Val(xNossoNum),8)

       // Verifica se o nบ capturado jแ existe na E1. Se existir, pesquisa  o pr๓ximo livre
	   cCompara := STRZERO(Val(xNossoNum),8)

       WHILE .T.
         
          If Select("T_JAEXISTE") > 0
             T_JAEXISTE->( dbCloseArea() )
          EndIf

          cSql := ""
          cSql := "SELECT E1_NUMBCO"
          cSql += "  FROM " + RetSqlName("SE1")
          cSql += " WHERE E1_NUMBCO  = '" + Alltrim(cCompara) + "'"
          cSql += "   AND D_E_L_E_T_ = ''"
               
          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JAEXISTE", .T., .T. )
         
          If !T_JAEXISTE->( EOF() )         
             cCompara := STRZERO(INT(VAL(T_JAEXISTE->E1_NUMBCO)) + 1,8)
          Else
             Exit
          Endif  
       ENDDO

   	   _cNossoNum := cCompara
	
 	   // Carrega o Nosso n๚mero para grava็ใo na tabela de Boletos emitidos pela proposta comercial
       aBoleto := { nContar                   ,;    // [1] Nบ da Parcela
                    Strzero(Val(_cNossoNum),8) }    // [2] Nosso N๚mero da Parcela

       // Atualiza parโmetros do banco			
	   DbSelectArea("SEE")
	   DbSetOrder(1)
	   If DbSeek("01" + xNumBanco + xAgencia + xConta + "001")
	      RecLock("SEE",.F.)
 	      SEE->EE_NUMBCO := Strzero((Val(_cNossoNum) + 1),6)
 	      //SOMA1(Right(xNossoNum,6))
		  MsUnLock() 
	   EndIf

	   oPrint:=TMSPrinter():New( "Boleto Bancario" )
	   oPrint:SetPortrait()
	
       // Carrega o Valor de Abatimento
       //DbSelectArea("T_SE1")
       //_nVlrAbat := 0T_SE1->E1_IRRF + T_SE1->E1_INSS + T_SE1->E1_PIS + T_SE1->E1_COFINS + T_SE1->E1_CSLL
       _nVlrAbat := 0
	
	   // Parโmetros
	   // 1 - Codigo Banco        
	   // 2 - Ag๊ncia	C.Corrente     
	   // 3 - Digito C/C    
	   // 4 - Carteira
	   CB_RN_NN  := xRet_cBarra(Subs(aDadosBanco[1],1,3), aDadosBanco[3], aDadosBanco[4], aDadosBanco[5], aDadosBanco[6], _cNossoNum, aParcelas[nContar,2], aParcelas[nContar,1])

       If x_Operacao == "I"
          x_Documento := " " + AllTrim(__Pedido) + " " + AllTrim(Strzero(nContar,2))
       Else
          x_Documento := " " + AllTrim(__Pedido) + " " + AllTrim(x_Parcela)
       Endif

	   aDadosTit := { x_Documento          ,;  // [01] Numero do titulo
	                  T_PEDIDO->EMISSAO    ,;  // [02] Data da emissใo do tํtulo
	                  Date()               ,;  // [03] Data da emissใo do boleto
	                  aParcelas[nContar,1] ,;  // [04] Data do vencimento
	                  aParcelas[nContar,2] ,;  // [05] Valor do tํtulo
	                  CB_RN_NN[3]		   ,;  // [06] Nosso n๚mero (Ver f๓rmula para calculo)
 	                  "   "                ,;  // [07] Prefixo da NF
  	                  "PV"    	           ,;  // [08] Tipo do Titulo
	                  0		               ,;  // [09] IRRF
	                  0	                   ,;  // [10] ISS
	                  0 	               ,;  // [11] INSS
	                  0                    ,;  // [12] PIS
	                  0                    ,;  // [13] COFINS
	                  0                    ,;  // [14] CSLL
	                  _nVlrAbat }	           // [15] Abatimentos

       nVlAtraso := ((aDadosTit[5] * nTaxaDia )/100)
	   nVlMulta := ((aDadosTit[5] * nTaxaMul  )/100)
	
 	   //Instrucoes
	   aBolText  := {""     ,; // [1]
	                 "  " +  ;
	                 "  " +  ;
	                 "  "   ,; // [2]
                     "  " +  ;
	                 "  "   ,;
	                 xMensg1,; // [4]
	                 xMensg2,; // [5]
                	 ""     ,; // [6]
	                 ""     ,; // [7]
	                 ""     ,; // [8]
	                 "" }	   // [9]

	   aBMP := {}

       // Imprime o Boleto Bancแrio
	   PRN_BOLETO(oPrint,aBMP,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)

	   lPrint := .T.
  
       If lPrint
          oPrint:Preview()     // Visualiza antes de imprimir
       EndIf  

       // Atualiza a tabela de Emissใo de Boletos A Vista
       If x_Operacao == "I"
   	      If MsgYesNo("Aten็ใo!" + chr(13) + chr(10) + chr(13) + chr(10) + "Somente serใo controlados Boletos de Cobran็a que forem gravados em PDF." + chr(13) + chr(10) + "Voc๊ salvou o Boleto Bancแrio em PDF para ser enviado ao Cliente por e-mail?")
             aArea := GetArea()
             dbSelectArea("ZS0")
             RecLock("ZS0",.T.)
             ZS0_FILIAL := cFilAnt
             ZS0_PEDIDO := Arq_Pedido
             ZS0_EMISSA := Arq_Emissao
             ZS0_CODCLI := Arq_Cliente
             ZS0_LOJCLI := Arq_LojaCli
             ZS0_COND   := Arq_condicao
             ZS0_NOSN   := _cNossoNum
             ZS0_VENC   := aParcelas[nContar,1]
             ZS0_VALOR  := aParcelas[nContar,2]
             ZS0_PARC   := Strzero(nContar,02)
             ZS0_EMAIL  := Arq_EmailCl
             ZS0_VEND   := Arq_Vendedor
             MsUnLock()
          Else
             If nContar == 1
                Exit
             Endif   
          Endif

       Else

          // Grava o nosso n๚mero
          DbSelectArea("ZS0")
          DbSetOrder(2)
          If DbSeek(x__Filial + x__Pedido + x_Parcela)
             RecLock("ZS0",.F.)
             ZS0_NOSN := _cNossoNum
             MsUnLock()              
          Endif   
       Endif   

  Next nContar

  // Fecha a janela da tela do PE_MATA410()
  If x_Operacao == "I"
     oDlgBol:End()
  Endif   

Return(.T.)

// Fun็ใo que imprime o boleto bancแrio
Static Function PRN_BOLETO(oPrint,aBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)

   Local cSql := ""

   //Parโmetros de TFont.New()
   //1.Nome da Fonte (Windows)
   //3.Tamanho em Pixels
   //5.Bold (T/F)
   Local oFont6  := TFont():New("Arial"      ,9,6 ,.T.,.F.,5,.T.,5,.T.,.F.)
   Local oFont8a := TFont():New("Arial"      ,9,10,.T.,.F.,5,.T.,5,.T.,.F.)
   Local oFont8c := TFont():New("Courier New",9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
   Local oFont18c:= TFont():New("Courier New",9,18,.T.,.T.,5,.T.,5,.T.,.F.)
   Local oFont10 := TFont():New("Arial"      ,9,10,.T.,.F.,5,.T.,5,.T.,.F.)
   Local oFont10N:= TFont():New("Arial"      ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
   Local oFont16 := TFont():New("Arial"      ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
   Local oFont16n:= TFont():New("Arial"      ,9,14,.T.,.F.,5,.T.,5,.T.,.F.)
   Local oFont24 := TFont():New("Arial"      ,9,24,.T.,.T.,5,.T.,5,.T.,.F.)
   Local oFontW  := TFont():New("Wingdings"  ,9,14,.T.,.F.,5,.T.,5,.T.,.F.)
   LOCAL i := 0
   LOCAL oBrush

   // Pesquisa no parametrizador Automatech as instru็๕es a serem impressas
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_BOL1," 
   cSql += "       ZZ4_BOL2," 
   cSql += "       ZZ4_BOL3," 
   cSql += "       ZZ4_BOL4," 
   cSql += "       ZZ4_BOL5 "          
   cSql += "  FROM " + RetSqlName("ZZ4")

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      aBolText[1] := T_PARAMETROS->ZZ4_BOL1
      aBolText[2] := T_PARAMETROS->ZZ4_BOL2
      aBolText[3] := T_PARAMETROS->ZZ4_BOL3
      aBolText[4] := T_PARAMETROS->ZZ4_BOL4
      aBolText[5] := T_PARAMETROS->ZZ4_BOL5
      aBolText[6] := ""
      aBolText[7] := ""
      aBolText[8] := ""
      aBolText[9] := ""
   Else
      aBolText[1] := ""
      aBolText[2] := ""
      aBolText[3] := ""
      aBolText[4] := ""
      aBolText[5] := ""
      aBolText[6] := ""
      aBolText[7] := ""
      aBolText[8] := ""
      aBolText[9] := ""
   Endif

   nPagNum++

   Set Century On

   // Inicia uma nova pแgina
   oPrint:StartPage()   

   nInd   := 0
   nLinha := 130

   For nInd := 1 To 3
	   oPrint:Line (nLinha + 0000,0100,nLinha + 0000,2300)
	   oPrint:Line (nLinha + 0000,0550,nLinha - 0070,0550)
	   oPrint:Line (nLinha + 0000,0800,nLinha - 0070,0800)
	
	   If xBanco = "104"
		  oPrint:SayBitmap(nLinha - 0085,0120,"104.bmp",340,80)	// Logotipo do Banco
	   ElseIf xBanco = "341"
		  oPrint:SayBitmap(nLinha - 0085,0120,"341.bmp",310,80)	// Logotipo do Banco
	   Else
	      oPrint:Say  (nLinha - 0066,0100,aDadosBanco[2],oFont16)	// [2]Nome do Banco
	   EndIf
	
	   oPrint:Say  (nLinha - 0088,0567,Left(aDadosBanco[1],3)+"-"+Right(aDadosBanco[1],1),oFont24)	// [1]Numero do Banco
	   oPrint:Line (nLinha + 0100,0100,nLinha + 0100,2300)
	   oPrint:Line (nLinha + 0200,0100,nLinha + 0200,2300)
	   oPrint:Line (nLinha + 0270,0100,nLinha + 0270,2300)
	   oPrint:Line (nLinha + 0340,0100,nLinha + 0340,2300)
	
	   oPrint:Line (nLinha + 0200,0500,nLinha + 0340,0500)
	   oPrint:Line (nLinha + 0270,0750,nLinha + 0340,0750)
	   oPrint:Line (nLinha + 0200,1000,nLinha + 0340,1000)
	   oPrint:Line (nLinha + 0200,1350,nLinha + 0270,1350)
	   oPrint:Line (nLinha + 0200,1550,nLinha + 0340,1550)
	
	   oPrint:Say  (nLinha + 0000,0100,"Local Pagamento"								,oFont8c)
	   oPrint:Say  (nLinha + 0020,0400,xMsg1											,oFont8a)
	   oPrint:Say  (nLinha + 0060,0400,xMsg2											,oFont8a)
	   oPrint:Say  (nLinha + 0000,1910,"Vencimento"									,oFont6)
	
	   oPrint:Say  (nLinha + 0040,2010,PadL(DTOC(aDadosTit[4]),20)                  	,oFont8a)
	
	   oPrint:Say  (nLinha + 0100,0100,"Cedente"										,oFont6)
	   oPrint:Say  (nLinha + 0100,1355,"CNPJ"											,oFont6)
	   oPrint:Say  (nLinha + 0100,1910,"Ag๊ncia/C๓digo Cedente"						,oFont6)
	   oPrint:Say  (nLinha + 0200,0100,"Data do Documento"								,oFont6)
//     oPrint:Say  (nLinha + 0230,0100,DTOC(aDadosTit[2])								,oFont8a) // Emissao do Titulo (E1_EMISSAO)
       oPrint:Say  (nLinha + 0230,0100,aDadosTit[2]    								,oFont8a) // Emissao do Titulo (E1_EMISSAO)
	   oPrint:Say  (nLinha + 0200,0505,"Nro.Documento"									,oFont6)
	   oPrint:Say  (nLinha + 0230,0605,aDadosTit[7]+aDadosTit[1]						,oFont8a) //Prefixo +Numero+Parcela
	   oPrint:Say  (nLinha + 0200,1005,"Esp้cie Doc."									,oFont6)
	   oPrint:Say  (nLinha + 0230,1050,"DM"											,oFont8a) //Tipo do Titulo
	   oPrint:Say  (nLinha + 0200,1355,"Aceite"										,oFont6)
	   oPrint:Say  (nLinha + 0230,1455,"N"												,oFont8a)
	   oPrint:Say  (nLinha + 0200,1555,"Data do Processamento"							,oFont6)
	   oPrint:Say  (nLinha + 0230,1655,DTOC(aDadosTit[3])								,oFont8a) // Data impressao
	   oPrint:Say  (nLinha + 0200,1910,"Nosso N๚mero"									,oFont6)
	
	   oPrint:Say  (nLinha + 0230,2010,PadL(xCartCob + "/" + STRZERO(Val(xNossoNum),8) + "-" + xDvNossoNum,20),oFont8a)
	
	   oPrint:Say  (nLinha + 0140,2010,PadL(xAgencia+               "/"+Substr(xConta,1,5)+"-"+Substr(xConta,6,1),22),oFont8a)
	
	   oPrint:Say  (nLinha + 0140,0100,aDadosEmp[1]              						,oFont8a) //Nome
	   oPrint:Say  (nLinha + 0140,1380,aDadosEmp[6]              						,oFont8a) //CNPJ
	
	   oPrint:Say  (nLinha + 0270,0100,"Uso do Banco"									,oFont6)
	   oPrint:Say  (nLinha + 0270,0505,"Carteira"										,oFont6)
	   oPrint:Say  (nLinha + 0300,0555,aDadosBanco[6]									,oFont8a)
	   oPrint:Say  (nLinha + 0270,0755,"Esp้cie"										,oFont6)
	   oPrint:Say  (nLinha + 0300,0805,"R$"											,oFont8a)
	   oPrint:Say  (nLinha + 0270,1005,"Quantidade"									,oFont6)
	   oPrint:Say  (nLinha + 0270,1555,"Valor"											,oFont6)
	   oPrint:Say  (nLinha + 0270,1910,"Valor do Documento"							,oFont6)
	   oPrint:Say  (nLinha + 0300,2010,Padl(AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),20),oFont8a)
	   oPrint:Say  (nLinha + 0340,0100,"Instru็๕es (Todas informa็๕es deste bloqueto sใo de exclusiva responsabilidade do cedente)",oFont6)
	   oPrint:Say  (nLinha + 0390,0100,aBolText[1]										,oFont8a)
	   oPrint:Say  (nLinha + 0440,0100,aBolText[2]										,oFont8a)
	   oPrint:Say  (nLinha + 0490,0100,aBolText[3]										,oFont8a)
	   oPrint:Say  (nLinha + 0540,0100,aBolText[4]										,oFont8a)
	   oPrint:Say  (nLinha + 0590,0100,aBolText[5]										,oFont8a)
//	   oPrint:Say  (nLinha + 0490,1400,aBolText[6]										,oFont8a)
//	   oPrint:Say  (nLinha + 0540,1400,aBolText[7]										,oFont8a)
//	   oPrint:Say  (nLinha + 0590,1400,aBolText[8]										,oFont8a)
//	   oPrint:Say  (nLinha + 0640,0100,aBolText[9]										,oFont8a)
	
	   oPrint:Say  (nLinha + 0340,1910,"(-)Desconto/Abatimento"						,oFont6)
	   If aDadosTit[15] > 0
	      oPrint:Say  (nLinha + 0270,2010,AllTrim(Transform(aDadosTit[15],"@E 999,999,999.99")),oFont8a)
	   Endif
	   oPrint:Say  (nLinha + 0410,1910,"(-)Outras Dedu็๕es"							,oFont6)
	   oPrint:Say  (nLinha + 0480,1910,"(+)Mora/Multa"									,oFont6)
	   oPrint:Say  (nLinha + 0550,1910,"(+)Outros Acr้scimos"							,oFont6)
	   oPrint:Say  (nLinha + 0620,1910,"(=)Valor Cobrado"								,oFont6)
	
	   oPrint:Say  (nLinha + 0690,0100,"Sacado"										,oFont6)
	   oPrint:Say  (nLinha + 0700,0300,aDatSacado[1]+" ("+aDatSacado[2]+") - " + TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99") ,oFont8a)
	   oPrint:Say  (nLinha + 0735,0300,aDatSacado[3]									,oFont8a)
	   oPrint:Say  (nLinha + 0770,0300,Transform(aDatSacado[6],"@R 99.999-999")+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont8a) // CEP+Cidade+Estado
	
	   oPrint:Say  (nLinha + 0818,0100,"Sacador/Avalista"								,oFont6)
	
	   oPrint:Line (nLinha + 0000,1900,nLinha + 0690,1900)
	   oPrint:Line (nLinha + 0410,1900,nLinha + 0410,2300)
	
	   oPrint:Line (nLinha + 0480,1900,nLinha + 0480,2300)
	   oPrint:Line (nLinha + 0550,1900,nLinha + 0550,2300)
	   oPrint:Line (nLinha + 0620,1900,nLinha + 0620,2300)
	
	   oPrint:Line (nLinha + 0690,0100,nLinha + 0690,2300)
	   oPrint:Line (nLinha + 0840,0100,nLinha + 0840,2300)
	
	   If nInd = 1
		  oPrint:Say  (nLinha - 0070,2000,"Recibo do Sacado",oFont10)
		  oPrint:Say  (nLinha + 0850,1500,"Autentica็ใo Mecโnica",oFont8a)
		  nLinha += 1065
   	   ElseIf nInd = 2
		  oPrint:Say  (nLinha - 0140,0100,"#",oFontW)
		  For i := 100 to 2300 step 10
			  oPrint:Line( nLinha - 0100, i, nLinha - 0100, i+5)
		  Next i
		  oPrint:Say  (nLinha - 0066,0820,CB_RN_NN[2],oFont16n)	// Linha Digitavel do Codigo de Barras
		  oPrint:Say  (nLinha + 0850,1500,"Autentica็ใo Mecโnica - Ficha de Compensa็ใo",oFont8a)
		
	   EndIf
	
   Next

   MSBAR3("INT25",18.4,0.8,CB_RN_NN[1],oPrint,.F.,,,,1.5,,,,.F.)

   // Finaliza a pแgina
   oPrint:EndPage() 

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณModulo10  บAutor  ณMicrosiga           บ Data ณ  05/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function xModulo10(cData)

   LOCAL L, D, P, nInt := 0

   L := Len(cdata)
   D := 0
   P := 2
   N := 0

   Do While L > 0
      N := (Val(SubStr(cData, L, 1)) * P)
  	  If N > 9
		 D := D + (N - 9)
	  Else
		 D := D + N
	  Endif
	  If P = 2
	   	 P := 1
	  Elseif P = 1
		 P := 2
	  EndIf
	  L := L - 1
   EndDo

   D := Mod(D,10)
   D := 10 - D

   If D == 10
	  D:=0
   Endif

Return(D)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMod11CB   บAutor  ณMicrosiga           บ Data ณ  05/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Modulo 11 CB                                               บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function xMod11CB(cBarraImp) // Modulo 11 com base 9

   nCont	:= 0.00
   nCont	:= nCont+(Val(Subs(cBarraImp,43,1))*2)
   nCont	:= nCont+(Val(Subs(cBarraImp,42,1))*3)
   nCont	:= nCont+(Val(Subs(cBarraImp,41,1))*4)
   nCont	:= nCont+(Val(Subs(cBarraImp,40,1))*5)
   nCont	:= nCont+(Val(Subs(cBarraImp,39,1))*6)
   nCont	:= nCont+(Val(Subs(cBarraImp,38,1))*7)
   nCont	:= nCont+(Val(Subs(cBarraImp,37,1))*8)
   nCont	:= nCont+(Val(Subs(cBarraImp,36,1))*9)
   nCont	:= nCont+(Val(Subs(cBarraImp,35,1))*2)
   nCont	:= nCont+(Val(Subs(cBarraImp,34,1))*3)
   nCont	:= nCont+(Val(Subs(cBarraImp,33,1))*4)
   nCont	:= nCont+(Val(Subs(cBarraImp,32,1))*5)
   nCont	:= nCont+(Val(Subs(cBarraImp,31,1))*6)
   nCont	:= nCont+(Val(Subs(cBarraImp,30,1))*7)
   nCont	:= nCont+(Val(Subs(cBarraImp,29,1))*8)
   nCont	:= nCont+(Val(Subs(cBarraImp,28,1))*9)

   nCont	:= nCont+(Val(Subs(cBarraImp,27,1))*2)
   nCont	:= nCont+(Val(Subs(cBarraImp,26,1))*3)
   nCont	:= nCont+(Val(Subs(cBarraImp,25,1))*4)
   nCont	:= nCont+(Val(Subs(cBarraImp,24,1))*5)
   nCont	:= nCont+(Val(Subs(cBarraImp,23,1))*6)
   nCont	:= nCont+(Val(Subs(cBarraImp,22,1))*7)
   nCont	:= nCont+(Val(Subs(cBarraImp,21,1))*8)
   nCont	:= nCont+(Val(Subs(cBarraImp,20,1))*9)
   nCont	:= nCont+(Val(Subs(cBarraImp,19,1))*2)

   nCont	:= nCont+(Val(Subs(cBarraImp,18,1))*3)
   nCont	:= nCont+(Val(Subs(cBarraImp,17,1))*4)
   nCont	:= nCont+(Val(Subs(cBarraImp,16,1))*5)
   nCont	:= nCont+(Val(Subs(cBarraImp,15,1))*6)
   nCont	:= nCont+(Val(Subs(cBarraImp,14,1))*7)
   nCont	:= nCont+(Val(Subs(cBarraImp,13,1))*8)

   nCont	:= nCont+(Val(Subs(cBarraImp,12,1))*9)
   nCont	:= nCont+(Val(Subs(cBarraImp,11,1))*2)
   nCont	:= nCont+(Val(Subs(cBarraImp,10,1))*3)
   nCont	:= nCont+(Val(Subs(cBarraImp,09,1))*4)
   nCont	:= nCont+(Val(Subs(cBarraImp,08,1))*5)
   nCont	:= nCont+(Val(Subs(cBarraImp,07,1))*6)

   nCont	:= nCont+(Val(Subs(cBarraImp,06,1))*7)
   nCont	:= nCont+(Val(Subs(cBarraImp,05,1))*8)
   nCont	:= nCont+(Val(Subs(cBarraImp,04,1))*9)
   nCont	:= nCont+(Val(Subs(cBarraImp,03,1))*2)
   nCont	:= nCont+(Val(Subs(cBarraImp,02,1))*3)
   nCont	:= nCont+(Val(Subs(cBarraImp,01,1))*4)

   nResto := MOD(ncont,11)
   CBD := 11 - nResto

   If nResto <= 1 .or. nResto > 9
	  CBD := 1
   Endif

Return(CBD)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRet_cBarraบAutor  ณMicrosiga           บ Data ณ  05/12/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna Linha Digitavel, Linha Codigo Barras e Nosso Numero บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function xRet_cBarra(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor, Vencimento)

   LOCAL bldocnufinal := StrZero(Val(cNroDoc),8)
   LOCAL blvalorfinal := strzero(nValor*100,10)
   LOCAL dvnn         := 0
   LOCAL dvcb         := 0
   LOCAL dv           := 0
   LOCAL NN           := ''
   LOCAL RN           := ''
   LOCAL CB           := ''
   LOCAL s            := ''
   Local dDtBase	  := ctod("07/10/1997")
   Local cFatorVencto := ""

   //Calculo do Fator de Vencimento do Titulo
   //cFatorVencto := Str(T_SE1->E1_VENCREA - dDtBase,4)

   cFatorVencto := Str(Vencimento - dDtBase,4)
   
   // - Montagem do Nosso Numero
   snn  := cAgencia + SubStr(cConta,1,5) + cCarteira + bldocnufinal     // Agencia + Conta + Carteira + Nosso Numero
   dvnn := xModulo10(snn)    // Digito verificador no Nosso Numero
   NN   := cCarteira + BlDocNuFinal + AllTrim(Str(dvnn))
   xDvNossoNum := AllTrim(Str(dvnn))

   // - MONTAGEM DOS DADOS PARA O CODIGO DE BARRAS
   scb  := cBanco + "9" + cFatorVencto + blvalorfinal + NN + cAgencia + cConta + cDacCC + "000"
   dvcb := xMod11CB(scb)	//digito verificador do codigo de barras
   CB   := SubStr(scb,1,4) + AllTrim(Str(dvcb)) + SubStr(scb,5,39)

   // - Montagem da Linha Digitavel
   srn := cBanco + "9" + cCarteira + SubsTr(BlDocNuFinal,1,2)
   dv  := xModulo10(srn)
   RN  := SubStr(srn, 1, 5) + '.' + SubStr(srn,6,4) + AllTrim(Str(dv)) + ' '
   srn := SubsTr(bldocnuFinal,3) + (AllTrim(Str(DvNN))) + SubsTr(cAgencia,1,3) // posicao 6 a 15 do campo livre
   dv  := xModulo10(srn)
   RN  := RN + SubStr(srn,1,5) + '.' + SubStr(srn,6,5) + AllTrim(Str(dv)) + ' '
   srn := SubsTr(cAgencia,4,1) + cConta + cDacCC + "000" // posicao 16 a 25 do campo livre
   dv  := xModulo10(srn)
   RN  := RN + SubStr(srn,1,5) + '.' + SubStr(srn,6,5)+AllTrim(Str(dv)) + ' '
   RN  := RN + AllTrim(Str(dvcb)) + ' '
   RN  := RN + cFatorVencto + StrZero((nValor * 100),10)

Return({CB,RN,NN})