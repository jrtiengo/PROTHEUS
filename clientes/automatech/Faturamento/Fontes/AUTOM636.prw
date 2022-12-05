#include "ap5mail.ch"
#include "colors.ch"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "Protheus.Ch"
#include "ap5mail.ch"
#include "colors.ch"
#INCLUDE "jpeg.ch" 
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "topconn.ch"
#INCLUDE "SHELL.CH"
#include "TOTVS.CH"
#include "fileio.ch"

#DEFINE IMP_SPOOL 2
#DEFINE VBOX       080
#DEFINE VSPACE     008
#DEFINE HSPACE     010
#DEFINE SAYVSPACE  008
#DEFINE SAYHSPACE  008
#DEFINE HMARGEM    030
#DEFINE VMARGEM    030
#DEFINE MAXITEM    022                                                // Máximo de produtos para a primeira página
#DEFINE MAXITEMP2  049                                                // Máximo de produtos para a pagina 2 em diante
#DEFINE MAXITEMP2F 069                                                // Máximo de produtos para a página 2 em diante quando a página não possui informações complementares
#DEFINE MAXITEMP3  025                                                // Máximo de produtos para a pagina 2 em diante (caso utilize a opção de impressao em verso) - Tratamento implementado para atender a legislacao que determina que a segunda pagina de ocupar 50%.
#DEFINE MAXITEMC   018                                                // Máxima de caracteres por linha de produtos/serviços
#DEFINE MAXMENLIN  080                                                // Máximo de caracteres por linha de dados adicionais
#DEFINE MAXMSG     013                                                // Máximo de dados adicionais por página
#DEFINE MAXVALORC  008                                                // Máximo de caracteres por linha de valores numéricos

// ###################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            ##
// -------------------------------------------------------------------------------- ##
// Referencia: AUTOM636.PRW                                                         ##
// Parâmetros: Nenhum                                                               ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                              ##
// Data......: 27/09/2017                                                           ##
// Objetivo..: Geração de Boleto Santander pelo Pedido de Venda                     ##
// ###################################################################################

User Function AUTOM636(kFilial, kPedido)

   Local cSql    := ""
   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local xRetiR  := 0
   Local oMemo1
   Local oMemo2

// Private _lBord    := .F.
// Private lPorOnde  := cPorOnde

   Private cPelaNota := ""
   Private cQuery    := {}

   Private cPrefixo	 := Space(03)
   Private cNum01	 := Space(09)
   Private cNum02	 := Space(09)
   Private cPar01	 := Space(02)
   Private cPar02	 := Space(02)
   Private lDisco    := .F.
   Private oDisco

   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5

   Private aImpressao := {}
   Private aParcelas  := {}

   Private oDlg

   // ###########################################################################################
   // Verifica se existe a pasta C:\DANFE na máquina do usuário. Caso não exista, será criada. ##
   // ###########################################################################################
   If !ExistDir( "C:\DANFE" )

      nRet := MakeDir( "C:\DANFE" )
   
      If nRet != 0
         Return(.T.)
      Endif
   
   Endif

   If Empty(Alltrim(kFilial))
      Return(.T.)
   Endif
   
   If Empty(Alltrim(kpedido))
      Return(.T.)
   Endif

   // #########################################
   // Pesquisa os Valores do Pedido de Venda ##
   // #########################################
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
   cSql += "      (SELECT C5_MOEDA"
   cSql += "         FROM " + RetSqlName("SC5")
   cSql += "        WHERE C5_FILIAL  = A.C6_FILIAL"
   cSql += "          AND C5_NUM     = A.C6_NUM   "
   cSql += "          AND D_E_L_E_T_ = '') AS MOEDA,"
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
   cSql += " WHERE A.C6_NUM     = '" + Alltrim(kPedido) + "'"
   cSql += "   AND A.C6_FILIAL  = '" + Alltrim(kFilial) + "'"
   cSql += "   AND A.D_E_L_E_T_ = ''" 
   cSql += " GROUP BY A.C6_FILIAL, A.C6_NUM, A.C6_CLI, A.C6_LOJA"

   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PEDIDO",.T.,.T.)

   // ######################################################
   // Verifica se cliente permite receber boleto bancário ##
   // ######################################################
   If POSICIONE("SA1",1,XFILIAL("SA1") + T_PEDIDO->C6_CLI + T_PEDIDO->C6_LOJA, "A1_BOLET") == "N"
      MsgAlert("Cliente está configurado para não receber Boleto Bancário. Verifique Cadastro de Clientes!")
      Return(.T.)
   Endif   

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
   cSql += "       A.C6_QTDVEN ,"
   cSql += "       A.C6_PRCVEN ,"
   cSql += "       A.C6_VALOR  ,"
   cSql += "       A.C6_TES    ,"
   cSql += "       B.C5_MOEDA  ,"
   cSql += "       A.C6_DESCRI ," 
   cSql += "       B.C5_FRETE  ,"
   cSql += "       B.C5_CLIENTE,"
   cSql += "       B.C5_LOJACLI,"
   cSql += "       B.C5_CONDPAG "
   cSql += "  FROM " + RetSqlName("SC6") + " A, "
   cSql += "       " + RetSqlName("SC5") + " B  "
   cSql += " WHERE A.C6_FILIAL  = '" + Alltrim(kFilial) + "'"
   cSql += "   AND A.C6_NUM     = '" + Alltrim(kpedido) + "'"
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
      // Proporcionaliza o valro do frete para cálculo do Difal ##
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
      MaFisAdd(T_CALDIFAL->C6_PRODUTO           ,; // 01 - Código do Produto (Obrigatório)
               T_CALDIFAL->C6_TES               ,; // 02 - Código do TES (Obrigatório)
               T_CALDIFAL->C6_QTDVEN            ,; // 03 - Quantidade de Venda do Produto (Obrigatório)
               T_CALDIFAL->C6_PRCVEN            ,; // 04 - Preço Unitário de Venda do Produto (Obrigatório)
               0                                ,; // 05 - Valor do Desconto (Opcional)
               ""                               ,; // 06 - Nº da NF Original (Devolução/Beneficiamento)
               ""                               ,; // 07 - Série da NF Original (Devolução/Beneficiamento)
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

   // ############################################################################################
   // Cria o array aParcelas contendo a quantidade total de parcelas para impressão dos boletos ##
   // ############################################################################################
   aImpressao := Condicao( (T_PEDIDO->TOT_PRODUTO + T_PEDIDO->FRETE + xRetiR), T_PEDIDO->CONDICAO )

   If Len(aImpressao) == 0
      MsgAlert("Não existem parcelas a serem impressas utilizadas para impressão de Boleto Bancário. Verifique!")
      Return(.T.)
   Endif      

   // ###########################################
   // Prepara o array aParcelas para impressão ##
   // ###########################################
   kEmail := POSICIONE("SA1",1,XFILIAL("SA1") + T_CALDIFAL->C5_CLIENTE + T_CALDIFAL->C5_LOJACLI, "A1_EMAIL") 

   For nContar = 1 to Len(aImpressao)
       aAdd( aParcelas, { aImpressao[nContar,01] ,; // 01
                          aImpressao[nContar,02] ,; // 02
                          T_PEDIDO->C6_CLI       ,; // 03
                          T_PEDIDO->C6_LOJA      ,; // 04
                          T_PEDIDO->CONDICAO     ,; // 05
                          T_PEDIDO->C6_NUM       ,; // 06
                          T_PEDIDO->EMISSAO      ,; // 07
                          T_PEDIDO->MOEDA        ,; // 08
                          kFilial                ,; // 09
                          ""                     ,; // 10
                          kEmail                 ,; // 11
                          T_PEDIDO->VENDEDOR     }) // 12
   Next nContar

   // ####################################################
   // Aviso de solicitação de gravação do boleto em PDF ##
   // ####################################################
   MsgAlert("Atenção!"                                                                 + chr(13) + chr(10) + chr(13) + chr(10) + ;
            "Somente serão controlados Boletos de Cobrança que forem gravados em PDF." + chr(13) + chr(10) + ;
            "Não esqueça de realizar a gravação deste boleto.")

   // ####################################################################
   // Envia para a função que realiza a impressão dos boletos bancários ##
   // ####################################################################
   BImprimeDup()

   // ################################################## 
   // Atualiza a tabela de Emissão de Boletos A Vista ##
   // ##################################################
   DbSelectArea("ZS0")
   DbSetOrder(2)
   If DbSeek(kFilial + kPedido + "01")
   Else
      aArea := GetArea()
      dbSelectArea("ZS0")
      RecLock("ZS0",.T.)
      ZS0_FILIAL := kFilial
      ZS0_PEDIDO := kPedido
      ZS0_EMISSA := CTOD(T_PEDIDO->EMISSAO)
      ZS0_CODCLI := T_CALDIFAL->C6_CLI         
      ZS0_LOJCLI := T_CALDIFAL->C6_LOJA
      ZS0_COND   := T_PEDIDO->CONDICAO
      ZS0_NOSN   := aParcelas[01,10]
      ZS0_VENC   := aParcelas[01,01]
      ZS0_VALOR  := aParcelas[01,02]
      ZS0_PARC   := "01"
      ZS0_EMAIL  := kEmail
      ZS0_VEND   := T_PEDIDO->VENDEDOR
      MsUnLock()
   Endif   

Return(.T.)

// ############################################
// Função que imprime o boleto do Banco Itaú ##
// ############################################
Static Function BImprimeDup()

   LOCAL lPrimVez        := .T.
   LOCAL aDadosEmp       := {}
   LOCAL xMensg1	     := ""
   LOCAL xMensg2	     := ""
   LOCAL lBoleto   	     := .f. //Caso o boleto seja gerado somento pelo financeiro.
   Local cSql            := ""
   Local cCondicao       := ""
   Local cEZero          := .F.
   Local nContar         := 0
   Local cCompara        := ""
   Local cSql            := ""
   Local lJaImpresso     := .F.
   Local cMensagem       := "" 
   Local nValorAbat		 := 0

   Local cLocal          := "c:\DANFE\"
   Local lAdjustToLegacy := .F.
   Local lDisableSetup   := .T.
   Local cFilePrint := ""
   
   PRIVATE oPrint
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
   PRIVATE nLinhaDig    := ""
   PRIVATE xMsg1      	:= ""
   PRIVATE xMsg2      	:= ""
   PRIVATE cCartNnDvDv	:= ""
   PRIVATE cCodCli    	:= ""
   PRIVATE xEmailTo   	:= ""
   Private cTabParc   	:= "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
   Private aAbatimento  := {}

   Private kGrupo01      := ""
   Private kGrupo02      := ""
   Private kGrupo03      := ""
   Private kGrupo04      := ""
   Private kGrupo05      := ""            
   Private cFatorVencto  := ""
   Private cValorNominal := ""

   // ####################################################################
   // Captura dados da Empresa Logada para Impressão do Boleto Bancário ##
   // ####################################################################
   SM0->(DbSeek(cEmpAnt+cFilAnt))

   aDadosEmp  := {	SM0->M0_NOMECOM,;	                                     // [1]Nome da Empresa
                    SM0->M0_ENDCOB,;						                 // [2]Endereço
                    AllTrim(SM0->M0_BAIRCOB) + ", " + ;
                    AllTrim(SM0->M0_CIDCOB)  + ", " + ;
                    SM0->M0_ESTCOB,;										 // [3]Complemento
                    "CEP: " + Transform(SM0->M0_CEPCOB,"@R 99.999-999"),; 	 // [4]CEP
                    "PABX/FAX: " + SM0->M0_TEL,; 							 // [5]Telefones
                    Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),; 		 // [6]CNPJ
                    "I.E.: " + Transform(SM0->M0_INSC,"@R 999/99999999999")} // [7]Insc Estadual

   // ##################################
   // Início da Impressão dos Boletos ##
   // ##################################        
   For nLaco = 1 to Len(aParcelas)

       // ###############################
       // Pesquisa os dados do Cliente ##
       // ###############################
       DbSelectArea("SA1")
	   DbSetOrder(1)
 
  	   If !DbSeek(xFilial("SA1") + aParcelas[nLaco,03]  + aParcelas[nLaco,04])
	   	  Loop
	   EndIf

 	   aDatSacado := {}
	   cCodCli    := AllTrim(SA1->A1_COD) + AllTrim(SA1->A1_LOJA)
	
	   If !Empty(SA1->A1_ENDCOB)
	   	  aDatSacado := { AllTrim(SA1->A1_NOME)                                     ,;	// [1]Razão Social
   		                  AllTrim(SA1->A1_COD )    + "-" + SA1->A1_LOJA             ,;	// [2]Código
   		                  AllTrim(SA1->A1_ENDCOB ) + "-" + AllTrim(SA1->A1_BAIRROC) ,;	// [3]Endereço
		                  AllTrim(SA1->A1_MUNC )                                    ,;	// [4]Cidade
		                  SA1->A1_ESTC                                              ,;	// [5]Estado
		                  SA1->A1_CEPC                                              ,;  // [6]CEP
		                  SA1->A1_CGC}												    // [7]CGC
	   Else
		  aDatSacado := { AllTrim(SA1->A1_NOME)                                     ,;	// [1]Razão Social
		                  AllTrim(SA1->A1_COD ) + "-" + SA1->A1_LOJA                ,;	// [2]Código
		                  AllTrim(SA1->A1_END ) + "-" + AllTrim(SA1->A1_BAIRRO)     ,;  // [3]Endereço
		                  AllTrim(SA1->A1_MUN )                                     ,;	// [4]Cidade
		                  SA1->A1_EST                                               ,;	// [5]Estado
		                  SA1->A1_CEP                                               ,;	// [6]CEP
		                  SA1->A1_CGC}												    // [7]CGC
	   EndIf
	
	   xMsg1       := "ATÉ O VENCIMENTO PAGUE PREFERENCIALMENTE NO SANTANDER"
	   xMsg2       := "APOS O VENCIMENTO PAGUE SOMENTE NO SANTANDER"
	
       Do Case

          // ########################################
          // Grupo Empresa -> 01 - Porto Alegre/RS ##
          // ########################################
          Case cEmpAnt == "01"
     	       xBanco 	   := "033"
	           xNomeBanco  := "BANCO SANTANDER"
	           xNumBanco   := "033"
	           xCartCob    := "101"
	           xCodCedente := "130015489 "
	           xConta      := "130015489 "
	           xDVConta    := ""
	           xAgencia    := "1011 "
               kFilial     := "01"
               xIdentifica := "8680922"

          // ######################################
          // Grupo Empresa -> 02 - TI AUTOMAÇÃO  ##
          // ######################################
          Case cEmpAnt == "02"
     	       xBanco 	   := "341"
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
      	       xBanco 	   := "033"
	           xNomeBanco  := "BANCO SANTANDER"
	           xNumBanco   := "033"
	           xCartCob    := "101"
	           xCodCedente := "130015472 "
	           xConta      := "130015472 "
	           xDVConta    := ""
	           xAgencia    := "1011 "
               kFilial     := "01"
               xIdentifica := "8680930"
              
          // #################################
          // Grupo Empresa -> 04 - AtechPel ##
          // #################################
          Case cEmpAnt == "04"
      	       xBanco 	   := "033"
   	           xNomeBanco  := "BANCO SANTANDER"
   	           xNumBanco   := "033"
   	           xCartCob    := "101"
   	           xCodCedente := "130015654 "
   	           xConta      := "130015654 "
   	           xDVConta    := ""        
   	           xAgencia    := "1011 "
               kFilial     := "01"
               xIdentifica := "9008772"

       EndCase	          
	
  	   aDadosBanco  := { xNumBanco        ,; // [1]Numero do Banco
	                     xNomeBanco       ,; // [2]Nome do Banco
	                     Alltrim(xAgencia),; // [3]Agência
	                     Alltrim(xConta)  ,; // [4]Conta Corrente
	                     xDvConta         ,; // [5]Dígito da conta corrente
	                     xCartCob         ,; // [6]Codigo da Carteira
	                     xCodCedente       } // [7]Codigo Cedente
	
       xx_SubConta := "001"         

       // ######################################################
       // Verifica se existem parâmetros para o Banco/Agência ##
       // ######################################################
       DbSelectArea("SEE")
	   DbSetOrder(1)
	   If !DbSeek(kFilial + xNumBanco + xAgencia + xConta + xx_SubConta) 
	      Alert("Conta Cobrança Sem Parâmetros !")
	      Set Century Off
	      Return()
 	   EndIf

       // ##############################
       // Prepara o número da parcela ##
       // ##############################
       cParcela := Strzero(nLaco,02)
	
       // ######################################
       // Trata o Nosso Número junto ao banco ##
       // ######################################

       // ###########################################################################################
       // Verifica na tabela SE1 (Contas a Receber) se o nosso número já foi gerado para o título. ##
       // Se ainda não foi, gera e atualiza.                                                       ##
       // ###########################################################################################      

       // ############################################################
       // Pesquisa o próximo código do nosso número a ser utilizado ##
       // ############################################################
       DbSelectArea("ZS0")
       DbSetOrder(2)
       If DbSeek(aParcelas[nLaco,09] + aParcelas[nLaco,06] + Strzero(nlaco,2))

          xNossoNum   := INT(VAL(Substr(ZS0->ZS0_NOSN,01,07)))
          xDvNossoNum := INT(VAL(Substr(ZS0->ZS0_NOSN,08,01)))
      		 
          // ###############################################
          // Calcula o digito verificador do nosso número ##
          // ###############################################
          _cNossoNum  := Strzero(xNossoNum,12)
          _DigNossoN  := Alltrim(Str(DigNossoNumero(_cNossoNum)))
          xNossoNum   := _cNossoNum
          xDvNossoNum := _DigNossoN

       Else

   	      DbSelectArea("SEE")
	      DbSetOrder(1)
	      If DbSeek("01" + xBanco + xAgencia + xConta + "001")

             nProximoNN := Strzero((INT(VAL(SEE->EE_NUMBCO)) + 1),6)

             // ########################################
             // Atualiza o nosso número na tabela SEE ##
             // ########################################
	         RecLock("SEE",.F.)
		     SEE->EE_NUMBCO  := nProximoNN
		     MsUnLock()

             // ###############################################
             // Calcula o dígito verificador no nosso número ##
             // ###############################################
             _cNossoNum  := Strzero(Int(Val(nProximoNN)),12)
             _DigNossoN  := Alltrim(Str(DigNossoNumero(_cNossoNum)))
             xNossoNum   := _cNossoNum
             xDvNossoNum := _DigNossoN

		  Else

             MsgAlert("Parâmetros bancários estão incorretos. Entre em contato com a controladoria.")
		     Return(.T.)

		  Endif   

       Endif

       // ######################################################
       // Atualiza o nosso número no registro do título (SE1) ##
       // ######################################################
       aParcelas[nLaco,10] := StrZero(INT(VAL(xNossoNum)),7) + Alltrim(_DigNossoN)

       oPrint:=TMSPrinter():New( "Boleto Bancario" )
       oPrint:SetPortrait()
	
       // ###################################
       // Inicializa o valor de abatimento ##
       // ###################################
	   _nVlrAbat := 0

       // ################################
       // Calcula o valor do abatimento ##
       // ################################
       nAbatimento := 0

       // ##################################################
       // Verifica se deve ser cobrado a Despesa Bancária ##
       // ##################################################
       If Posicione("SA1",1,xFilial("SA1") + aParcelas[nLaco,03] + aParcelas[nLaco,04], "A1_COBTAX") == "S"

          If Select("T_PARAMETROS") > 0
             T_PARAMETROS->( dbCloseArea() )
          EndIf
   
          cSql := ""
          cSql := "SELECT ZZ4_DTAX FROM ZZ4010"

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

          //nCobraTaxa := IIF(T_PARAMETROS->( EOF() ), 0, T_PARAMETROS->ZZ4_DTAX)
          nCobraTaxa := 0
        
       Else

          nCobraTaxa := 0

       Endif
                                                                                 
       // #####################################
       // Linha digitável do boleto bancário ##
       // #####################################

       // #######################################
       // Prepara os grupos da linha digitável ##
       // #######################################
       Do Case
          Case cEmpAnt == "01" 
               kGrupo01 := "033" + "9" + "9" + "8680" + "." + Alltrim(Str(modulo10("033998680")))
               kGrupo02 := "922" + (Substr(xNossoNum,01,07)) + "." + Alltrim(Str(modulo10("922" + Substr(xNossoNum,01,07))))
               kGrupo03 := Substr((xNossoNum + xDvNossoNum),08,06) + "0" + "101" + "." + Alltrim(Str(modulo10(Substr((xNossoNum + xDvNossoNum),08,06) + "0" + "101")))

          Case cEmpAnt == "03" 
               kGrupo01 := "033" + "9" + "9" + "8680" + "." + Alltrim(Str(modulo10("033998680")))
               kGrupo02 := "930" + (Substr(xNossoNum,01,07)) + "." + Alltrim(Str(modulo10("930" + Substr(xNossoNum,01,07))))
               kGrupo03 := Substr((xNossoNum + xDvNossoNum),08,06) + "0" + "101" + "." + Alltrim(Str(modulo10(Substr((xNossoNum + xDvNossoNum),08,06) + "0" + "101")))

          Case cEmpAnt == "04" 
               kGrupo01 := "033" + "9" + "9" + "9008" + "." + Alltrim(Str(modulo10("033999008")))
               kGrupo02 := "772" + (Substr(xNossoNum,01,07)) + "." + Alltrim(Str(modulo10("772" + Substr(xNossoNum,01,07))))
               kGrupo03 := Substr((xNossoNum + xDvNossoNum),08,06) + "0" + "101" + "." + Alltrim(Str(modulo10(Substr((xNossoNum + xDvNossoNum),08,06) + "0" + "101")))

       EndCase

       // ###################################################
       // Calcula o dígito verificador do código de Barras ##
       // ###################################################
       //nValorAbat := xSAbatimento()
       nValorAbat    := 0
       cFatorVencto  := Str(aParcelas[nLaco,01] - Ctod("07/10/1997"),4)
       cValorNominal := Replicate("0", 10 - len(Alltrim(STR((aParcelas[nLaco,02] - nValorAbat + nCobraTaxa) * 100)))) + Alltrim(STR((aParcelas[nLaco,02] - nValorAbat + nCobraTaxa) * 100))

       Do Case
          Case cEmpAnt == "01" 
               kGrupo04 := Alltrim(Str(DigCodBarras("033" + "9" + cFatorVencto + cValorNominal + "9" + "8680922" + (xNossoNum + xDvNossoNum) + "0" + "101")))
          Case cEmpAnt == "03" 
               kGrupo04 := Alltrim(Str(DigCodBarras("033" + "9" + cFatorVencto + cValorNominal + "9" + "8680930" + (xNossoNum + xDvNossoNum) + "0" + "101")))
          Case cEmpAnt == "04"
               kGrupo04 := Alltrim(Str(DigCodBarras("033" + "9" + cFatorVencto + cValorNominal + "9" + "9008772" + (xNossoNum + xDvNossoNum) + "0" + "101")))
       EndCase
     
       kGrupo05      := cFatorVencto + cValorNominal
       nLinhaDig     := kGrupo01 + " " + kGrupo02 + " " + kGrupo03 + " " + kGrupo04 + " " + kGrupo05
 
	   //						      Codigo Banco        Agencia	      C.Corrente     Digito C/C     Carteira
       //	 CB_RN_NN  := Ret_cBarra(Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],aDadosBanco[6],_cNossoNum,( T_SE1->E1_VALOR - nAbatimento + nCobraTaxa) )

	   aDadosTit := {" " + AllTrim(aParcelas[nLaco,06]) + " " + Strzero(nlaco,2)    ,; // [1] Numero do titulo
	                 aParcelas[nLaco,07]                                            ,; // [2] Data da emissão do título
	                 Date()                                  		                ,; // [3] Data da emissão do boleto
	                 aParcelas[nLaco,01]								            ,; // [4] Data do vencimento
	                (aParcelas[nLaco,02] + nCobraTaxa)   			                ,; // [5] Valor do título
	                (xNossoNum + xDvNossoNum)                                       ,; // [6] Nosso número (Ver fórmula para calculo)
	                 ""                                                             ,; // [7] Prefixo da NF
  	                 ""	                               	                            ,; // [8] Tipo do Titulo
	                 0		                           	                            ,; // [9] IRRF
	                 0	                             	                            ,; // [10] ISS
	                 0 	                                                            ,; // [11] INSS
	                 0                                                              ,; // [12] PIS
	                 0                                                              ,; // [13] COFINS
	                 0                               	                            ,; // [14] CSLL
	                 _nVlrAbat                                                      ,; // [15] Abatimentos
                     aParcelas[nLaco,06]                                            ,; // [16] Nº do Título
                     Strzero(nlaco,02)                                              ,; // [17] Nº da Parcela
                     kFilial                                                        ,; // [18] Filial de Origem
                     aParcelas[nLaco,08]                                            ,; // [19] Moeda do Título
                     aParcelas[nlaco,03]                                            ,; // [20] Código do Cliente
                     aParcelas[nLaco,04]                                             } // [21] Código da Loja

	   nVlAtraso := ((aDadosTit[5] * nTaxaDia )/100)
	   nVlMulta  := ((aDadosTit[5] * nTaxaMul  )/100)
	
       // #############
 	   // Instrucoes ##
 	   // #############
	   aBolText  := { ""     ,;	// [1]
  	                  "  " +  ;
	                  "  " +  ;
	                  "  "   ,; // [2]
	                  "  " +  ;
	                  "  "   ,;
	                  xMensg1,; // [4]
                      xMensg2,; // [5]
         	          "",; 		// [6]
	                  "",; 		// [7]
	                  "",; 		// [8]
	                  "" }		// [9]
	   aBMP := {}
	   Impress(oPrint,aBMP,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText)  &&,CB_RN_NN)

	   lPrint := .T.

   Next nContar

   // ##############################
   // Visualiza antes de imprimir ##
   // ##############################
   oPrint:Preview()

   If lDisco == .T.

      // #######################
      // Abre o arquivo DANFE ##
      // #######################
      nHandle := FOPEN("C:\DANFE\TOTVS Printer Document.pdf" , FO_READWRITE + FO_SHARED )

      If FERROR() != 0
         MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Imagem do boleto não foi gerado em disco." + chr(13) + chr(10) + "Operação abosrtada pelo usuário.")
         Return(.T.)
      Endif

      // ################################
      // Lê o tamanho total do arquivo ##
      // ################################
      nLidos := 0
      FSEEK(nHandle,0,0)
      nTamArq := FSEEK(nHandle,0,2)
      FSEEK(nHandle,0,0)

      // ########################
      // Lê todos os Registros ##
      // ########################
      xBuffer := Space(nTamArq)
      FREAD(nHandle,@xBuffer,nTamArq)
   
      kString := xBuffer

      // ##################
      // Fecha o arquivo ##
      // ##################
      FCLOSE(nHandle)

      // ######################################################################################
      // Verifica se o arquivo já existe no diretório. Se existir, exclui para nova gravação ##
      // ######################################################################################
      If File("\XML_DANFE\BOLETO_" + Alltrim(MV_PAR01) + "_" + Alltrim(MV_PAR02) + "_" + Alltrim(MV_PAR03) + ".PDF")
         Ferase("\XML_DANFE\BOLETO_" + Alltrim(MV_PAR01) + "_" + Alltrim(MV_PAR02) + "_" + Alltrim(MV_PAR03) + ".PDF")
      Endif

      // ######################
      // Grava o arquivo PDF ##
      // ######################
      kCaminho := "\XML_DANFE\BOLETO_" + Alltrim(MV_PAR01) + "_" + Alltrim(MV_PAR02) + "_" + Alltrim(MV_PAR03) + ".PDF"
      nHdl := fCreate(kCaminho)
      fWrite (nHdl, kString ) 
      fClose(nHdl)

      // ################################################################
      // Elimina o arquivo da pasta c:\DANFE do equipamento do usuário ##
      // ################################################################
      If File("C:\DANFE\TOTVS Printer Document.pdf")
         Ferase("C:\DANFE\TOTVS Printer Document.pdf")
      Endif
        
   EndIf  

Return(.T.)

// ##############################################################
// Função que impressão do boleto gráfico com código de barras ##
// ##############################################################
Static Function Impress(oPrint,aBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText)  &&,CB_RN_NN)

   Local cSql := ""

   // ############################
   // Parâmetros de TFont.New() ##
   // 1.Nome da Fonte (Windows) ##
   // 3.Tamanho em Pixels       ##
   // 5.Bold (T/F)              ##
   // ############################
   Local oFont6   := TFont():New("Arial"      ,9,6 ,.T.,.F.,5,.T.,5,.T.,.F.)
   Local oFont8a  := TFont():New("Arial"      ,9,10,.T.,.F.,5,.T.,5,.T.,.F.)
   Local oFont8c  := TFont():New("Courier New",9,8 ,.T.,.T.,5,.T.,5,.T.,.F.)
   Local oFont9a  := TFont():New("Arial"      ,9,9,.T.,.F.,5,.T.,5,.T.,.F.)
   Local oFont18c := TFont():New("Courier New",9,18,.T.,.T.,5,.T.,5,.T.,.F.)
   Local oFont09  := TFont():New("Arial"      ,9,9,.T.,.F.,5,.T.,5,.T.,.F.)
   Local oFont10  := TFont():New("Arial"      ,9,10,.T.,.F.,5,.T.,5,.T.,.F.)
   Local oFont10N := TFont():New("Arial"      ,9,10,.T.,.T.,5,.T.,5,.T.,.F.)
   Local oFont16  := TFont():New("Arial"      ,9,12,.T.,.T.,5,.T.,5,.T.,.F.)
   Local oFont16n := TFont():New("Arial"      ,9,14,.T.,.F.,5,.T.,5,.T.,.F.)
   Local oFont24  := TFont():New("Arial"      ,9,24,.T.,.T.,5,.T.,5,.T.,.F.)
   Local oFontW   := TFont():New("Wingdings"  ,9,14,.T.,.F.,5,.T.,5,.T.,.F.)
   LOCAL i := 0
   LOCAL oBrush

   Private aPaginas := {}

   // ##########################################################################################
   // Verifica se nota fiscal é referente a uma nota fiscal de serviço.                       ##
   // Se for serviço, imprime nas instruções a referência da nota fiscal de serviço com o RPS ##
   // Somente fará para notas fiscais com séries 11 - Porto alegre e 13 - Pelotas             ##
   // ##########################################################################################
   _NfRelacao := ""                    

   // ###############################################################
   // Pesquisa se vai ser acrescido o valor da taxa Administrativa ##
   // ###############################################################
   cCobraTaxa :=  Posicione("SA1",1,xFilial("SA1") + aDadosTit[20] + aDadosTit[21], "A1_COBTAX")

   // ########################################################################
   // Pesquisa no parametrizador Automatech as instruções a serem impressas ##
   // ########################################################################
   If Select("T_PARAMETROS") > 0
      T_PARAMETROS->( dbCloseArea() )
   EndIf
   
   cSql := ""
   cSql := "SELECT ZZ4_BOL1," 
   cSql += "       ZZ4_BOL2," 
   cSql += "       ZZ4_BOL3," 
   cSql += "       ZZ4_BOL4," 
   cSql += "       ZZ4_BOL5,"
   cSql += "       ZZ4_DTAX "
   cSql += "  FROM ZZ4010"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

   If !T_PARAMETROS->( EOF() )
      aBolText[1] := T_PARAMETROS->ZZ4_BOL1
      aBolText[2] := T_PARAMETROS->ZZ4_BOL2
      aBolText[3] := T_PARAMETROS->ZZ4_BOL3
      aBolText[4] := T_PARAMETROS->ZZ4_BOL4
      aBolText[5] := T_PARAMETROS->ZZ4_BOL5
//    aBolText[6] := IIF(T_PARAMETROS->ZZ4_DTAX == 0, "", IIF(cCobraTaxa == "S", "DESPESA BANCÁRIA DE R$ " + Alltrim(Str(T_PARAMETROS->ZZ4_DTAX,10,02)), ""))
      aBolText[6] := ""
      aBolText[7] := ""
      aBolText[8] := ""
      aBolText[9] := _NfRelacao
   Else
//    aBolText[1] := IIF(T_PARAMETROS->ZZ4_DTAX == 0, "", IIF(cCobraTaxa == "S", "DESPESA BANCÁRIA DE R$ " + Alltrim(Str(T_PARAMETROS->ZZ4_DTAX,10,02)), ""))
      aBolText[1] := ""
      aBolText[2] := ""
      aBolText[3] := ""
      aBolText[4] := ""
      aBolText[5] := ""
      aBolText[6] := ""
      aBolText[7] := ""
      aBolText[8] := ""
      aBolText[9] := _NfRelacao
   Endif

   nPagNum++

   Set Century On
   
   // #########################
   // Inicia uma nova página ##
   // #########################
   oPrint:StartPage()   

   nInd   := 0
   nLinha := 130

   For nInd := 1 To 3
   
	   oPrint:Line (nLinha + 0000,0100,nLinha + 0000,2300)
	   oPrint:Line (nLinha + 0000,0550,nLinha - 0070,0550)
	   oPrint:Line (nLinha + 0000,0800,nLinha - 0070,0800)
	
       // #########################################
       // Imprime a logomarca do banco Santander ##
       // #########################################
       oPrint:SayBitmap(nLinha - 0085,0097,"033.bmp",400,80)
//     oPrint:Say  (nLinha - 0088,0567,Left(aDadosBanco[1],3)+"-"+Right(aDadosBanco[1],1),oFont24)	// [1]Numero do Banco
       oPrint:Say  (nLinha - 0088,0567,"033-7",oFont24)	// [1]Numero do Banco
	   oPrint:Line (nLinha + 0100,0100,nLinha + 0100,2300)
	   oPrint:Line (nLinha + 0200,0100,nLinha + 0200,2300)
	   oPrint:Line (nLinha + 0270,0100,nLinha + 0270,2300)
	   oPrint:Line (nLinha + 0340,0100,nLinha + 0340,2300)
	
	   oPrint:Line (nLinha + 0200,0500,nLinha + 0270,0500)
	   oPrint:Line (nLinha + 0270,0750,nLinha + 0340,0750)
	   oPrint:Line (nLinha + 0200,1000,nLinha + 0340,1000)
	   oPrint:Line (nLinha + 0200,1350,nLinha + 0270,1350)
	   oPrint:Line (nLinha + 0200,1550,nLinha + 0340,1550)
	
	   oPrint:Say  (nLinha + 0000,0100,"Local Pagamento"							,oFont8c)
	   oPrint:Say  (nLinha + 0040,0100,"PAGAR PREFERENCIALMENTE NO BANCO SANTANDER", oFont09)

	   oPrint:Say  (nLinha + 0000,1910,"Vencimento"									,oFont6)
	   oPrint:Say  (nLinha + 0040,1910,DTOC(aDadosTit[4])                           ,oFont09)
	
	   oPrint:Say  (nLinha + 0100,0100,"Beneficiário"								,oFont6)
	   oPrint:Say  (nLinha + 0100,1910,"Agência / Ident.Beneficiário"  			    ,oFont6)
	   oPrint:Say  (nLinha + 0200,0100,"Data do Documento"							,oFont6)
	   oPrint:Say  (nLinha + 0230,0100,aDadosTit[2]    							    ,oFont09) // Emissao do Titulo (E1_EMISSAO)
	   oPrint:Say  (nLinha + 0200,0505,"Nro.Documento"								,oFont6)
	   oPrint:Say  (nLinha + 0230,0605,aDadosTit[7]+aDadosTit[1]					,oFont09) // Prefixo +Numero+Parcela
	   oPrint:Say  (nLinha + 0200,1005,"Espécie Doc."								,oFont6)
	   oPrint:Say  (nLinha + 0230,1050,"DM"											,oFont09) // Tipo do Titulo
	   oPrint:Say  (nLinha + 0200,1355,"Aceite"										,oFont6)
	   oPrint:Say  (nLinha + 0230,1455,"N"											,oFont09)
	   oPrint:Say  (nLinha + 0200,1555,"Data do Processamento"						,oFont6)
	   oPrint:Say  (nLinha + 0230,1655,DTOC(aDadosTit[3])							,oFont09) // Data impressao
	   oPrint:Say  (nLinha + 0200,1910,"Nosso Número"								,oFont6)

       // ###############
       // Nosso Número ##
       // ###############
 	   oPrint:Say  (nLinha + 0230,1910,xNossoNum + "-" + xDvNossoNum,oFont09)
	
       // ################################
       // Agência / Ident. Beneficiário ##
       // ################################
  	   oPrint:Say  (nLinha + 0140,1910,Alltrim(xAgencia) + "/" + Alltrim(xIdentifica),oFont09)
	
       // ################################
       // Imprime dados do Beneficiário ##
       // ################################
	   oPrint:Say  (nLinha + 0140,0100,Alltrim(aDadosEmp[1]) + " - CNPJ/CPF: " + aDadosEmp[6] ,oFont09)                       // Nome + CNPJ
//	   oPrint:Say  (nLinha + 0150,0250,Alltrim(aDadosEmp[2]) + ", " + Alltrim(aDadosEmp[3]) + " - " + aDadosEmp[4] ,oFont09)  // Endereço + Bairro + Cidade + UF + Cep

	   oPrint:Say  (nLinha + 0270,0100,"Carteira"	  			    				,oFont6)
//     oPrint:Say  (nLinha + 0300,0100,aDadosBanco[6]								,oFont8a)
       oPrint:Say  (nLinha + 0300,0100,"101 - RÁPIDA COM REGISTRO"  				,oFont09)
	   oPrint:Say  (nLinha + 0270,0755,"Espécie"									,oFont6)
	   oPrint:Say  (nLinha + 0300,0805,"REAL"										,oFont09)
	   oPrint:Say  (nLinha + 0270,1005,"Quantidade"									,oFont6)
	   oPrint:Say  (nLinha + 0270,1555,"Valor"										,oFont6)
	   oPrint:Say  (nLinha + 0270,1910,"(=)Valor do Documento"						,oFont6)

       // ###########################################################################################################################
       // Calcula o valor do abatimento a ser descontado do valor total para impressão do boleto em caso de nota fiscal de serviço ##
       // ###########################################################################################################################
       nAbatimento := 0
       //nAbatimento := xSAbatimento()      

       If Alltrim(aDadosTit[07]) == "11" .Or. Alltrim(aDadosTit[07]) == "13"
          If nAbatimento < 10
             nAbatimento := 0
          Endif
       Endif

       // ########################################################
       // Notas Fiscal de Serviço Eletrônica de Porto Alegre/RS ##
       // ########################################################
       Do Case
          Case Alltrim(aDadosTit[07]) == "11"
     	       oPrint:Say  (nLinha + 0300,2010,"R$ " + Padl(AllTrim(Transform((aDadosTit[5] - (aDadosTit[15])) ,"@E 999,999,999.99")),20),oFont09)      
          Case Alltrim(aDadosTit[07]) == "13"
     	       oPrint:Say  (nLinha + 0300,2010,"R$ " + Padl(AllTrim(Transform((aDadosTit[5] - (aDadosTit[15])) ,"@E 999,999,999.99")),20),oFont09)      
          Otherwise
               If nAbatimento == 0                               
       	          oPrint:Say  (nLinha + 0300,2010,"R$ " + Padl(AllTrim(Transform(aDadosTit[5],"@E 999,999,999.99")),20),oFont09)      
   	           Else   
   	              oPrint:Say  (nLinha + 0300,2010,"R$ " + Padl(AllTrim(Transform((aDadosTit[5] - nAbatimento),"@E 999,999,999.99")),20),oFont09)
   	           Endif   
   	   EndCase        

	   oPrint:Say  (nLinha + 0340,0100,"Instruções (termo de responsabilidade do beneficiário)",oFont10N)
	   oPrint:Say  (nLinha + 0390,0100,aBolText[1]										       ,oFont09)
	   oPrint:Say  (nLinha + 0440,0100,aBolText[2]										       ,oFont09)
	   oPrint:Say  (nLinha + 0490,0100,aBolText[3]										       ,oFont09)
	   oPrint:Say  (nLinha + 0540,0100,aBolText[4]										       ,oFont09)
	   oPrint:Say  (nLinha + 0590,0100,aBolText[5]										       ,oFont09)
       oPrint:Say  (nLinha + 0640,0100,aBolText[6]										       ,oFont09)

//	   oPrint:Say  (nLinha + 0540,0100,aBolText[7]										,oFont8a)
//	   oPrint:Say  (nLinha + 0590,0100,aBolText[8]										,oFont8a)
//	   oPrint:Say  (nLinha + 0640,0100,aBolText[9]										,oFont16n)
	
	   oPrint:Say  (nLinha + 0340,1910,"(-)Desconto"								            ,oFont6)

       // ########################################################################################################################
       // Este teste abaixo foi retirado temporariamente.                                                                       ##
       // Este bloqueio foi autorizado pela Controladoria no dia 20/08/2014 em função de estarem fechando a regra do abatimento ##
	   // If aDadosTit[15] > 0                                                                                                  ##
	   //    oPrint:Say  (nLinha + 0270,2010,AllTrim(Transform(aDadosTit[15],"@E 999,999,999.99")),oFont8a)                     ##
	   // Endif                                                                                                                 ##
       // ########################################################################################################################	   

	   oPrint:Say  (nLinha + 0410,1910,"(-)Abatimento"   							,oFont6)
	   oPrint:Say  (nLinha + 0480,1910,"(+)Mora"    								,oFont6)
	   oPrint:Say  (nLinha + 0550,1910,"(+)Outros Acréscimos"						,oFont6)
	   oPrint:Say  (nLinha + 0620,1910,"(=)Valor Cobrado"							,oFont6)
	
	   oPrint:Say  (nLinha + 0690,0100,"Pagador"									,oFont6)
	   oPrint:Say  (nLinha + 0700,0300,aDatSacado[1]+" ("+aDatSacado[2]+") - CNPJ/CPF " + TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99") ,oFont09)
	   oPrint:Say  (nLinha + 0735,0300,aDatSacado[3]								,oFont09)
	   oPrint:Say  (nLinha + 0770,0300,Transform(aDatSacado[6],"@R 99.999-999")+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont09) // CEP+Cidade+Estado
	
	   oPrint:Say  (nLinha + 0818,0100,"Sacador/Avalista"							,oFont6)
	
	   oPrint:Line (nLinha + 0000,1900,nLinha + 0690,1900)
	   oPrint:Line (nLinha + 0410,1900,nLinha + 0410,2300)
	
	   oPrint:Line (nLinha + 0480,1900,nLinha + 0480,2300)
	   oPrint:Line (nLinha + 0550,1900,nLinha + 0550,2300)
	   oPrint:Line (nLinha + 0620,1900,nLinha + 0620,2300)
	
	   oPrint:Line (nLinha + 0690,0100,nLinha + 0690,2300)
	   oPrint:Line (nLinha + 0840,0100,nLinha + 0840,2300)

	   If nInd = 1
		  oPrint:Say  (nLinha - 0070,2000,"Recibo do Sacado",oFont10N)
		  oPrint:Say  (nLinha + 0850,1880,"Autenticação Mecânica",oFont10N)
		  nLinha += 1065
   	   ElseIf nInd = 2
		  oPrint:Say  (nLinha - 0140,0100,"#",oFontW)
		  For i := 100 to 2300 step 10
			  oPrint:Line( nLinha - 0100, i, nLinha - 0100, i+5)
		  Next i
//		  oPrint:Say  (nLinha - 0066,0820,CB_RN_NN[2],oFont16n)	// Linha Digitavel do Codigo de Barras
		  oPrint:Say  (nLinha - 0066,0820,nLinhaDig,oFont16n)	// Linha Digitavel do Codigo de Barras
		  oPrint:Say  (nLinha + 0850,1880,"Autenticação Mecânica",oFont10N)
		
	   EndIf
	
   Next

   // ############################################
   // Elabora o código de barras para impressão ##
   // ############################################
   Do Case
      Case cEmpAnt == "01"
           cCodigoBarras := "033" + "9" + kGrupo04 + cFatorVencto + cValorNominal + "9" + "8680922" + xNossoNum + xDvNossoNum + "0" + "101"
      Case cEmpAnt == "03"
           cCodigoBarras := "033" + "9" + kGrupo04 + cFatorVencto + cValorNominal + "9" + "8680930" + xNossoNum + xDvNossoNum + "0" + "101"
      Case cEmpAnt == "04"
           cCodigoBarras := "033" + "9" + kGrupo04 + cFatorVencto + cValorNominal + "9" + "9008772" + xNossoNum + xDvNossoNum + "0" + "101"
   EndCase           

// MSBAR3("INT25",18.4,0.8,CB_RN_NN[1],oPrint,.F.,,,,1.5,,,,.F.)
   MSBAR3("INT25",18.4,0.8,cCodigoBarras,oPrint,.F.,,,,1.5,,,,.F.)
   nLinha += 300

   oPrint:Say  (nLinha + 0850,1880,"Ficha de Compensação",oFont10N)
		  
   // ####################
   // Finaliza a página ##
   // ####################
   oPrint:EndPage() 

Return()

// ##########################################
// Função que calcula dígitos no módulo 10 ##
// ##########################################
Static Function Modulo10(cData)

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

// ######################################################
// Função que calcula dígitos nmo módulo 11 com base 9 ##
// ######################################################
Static Function Mod11CB(cBarraImp) // Modulo 11 com base 9

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

// #################################################################################
// Função que retorna a LInha Digitável, Linha do Código de Barras e Nosso Número ##
// #################################################################################
Static Function Ret_cBarra(cBanco,cAgencia,cConta,cDacCC,cCarteira,cNroDoc,nValor)

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

   // ###########################################
   // Calculo do Fator de Vencimento do Titulo ##
   // ###########################################
   cFatorVencto := Str(T_SE1->E1_VENCREA - dDtBase,4)

   // ###########################
   // Montagem do Nosso Numero ##
   // ###########################
   snn  := cAgencia + SubStr(cConta,1,5) + cCarteira + bldocnufinal     // Agencia + Conta + Carteira + Nosso Numero
   dvnn := modulo10(snn)    // Digito verificador no Nosso Numero
   NN   := cCarteira + BlDocNuFinal + AllTrim(Str(dvnn))
   xDvNossoNum := AllTrim(Str(dvnn))

   // #############################################
   // MONTAGEM DOS DADOS PARA O CODIGO DE BARRAS ##
   // #############################################
   scb  := cBanco + "9" + cFatorVencto + blvalorfinal + NN + cAgencia + cConta + cDacCC + "000"
   dvcb := mod11CB(scb)	//digito verificador do codigo de barras
   CB   := SubStr(scb,1,4) + AllTrim(Str(dvcb)) + SubStr(scb,5,39)

   // ################################
   // - Montagem da Linha Digitavel ##
   // ################################
   srn := cBanco + "9" + cCarteira + SubsTr(BlDocNuFinal,1,2)
   dv  := modulo10(srn)
   RN  := SubStr(srn, 1, 5) + '.' + SubStr(srn,6,4) + AllTrim(Str(dv)) + ' '
   srn := SubsTr(bldocnuFinal,3) + (AllTrim(Str(DvNN))) + SubsTr(cAgencia,1,3) // posicao 6 a 15 do campo livre
   dv  := modulo10(srn)
   RN  := RN + SubStr(srn,1,5) + '.' + SubStr(srn,6,5) + AllTrim(Str(dv)) + ' '
   srn := SubsTr(cAgencia,4,1) + cConta + cDacCC + "000" // posicao 16 a 25 do campo livre
   dv  := modulo10(srn)
   RN  := RN + SubStr(srn,1,5) + '.' + SubStr(srn,6,5)+AllTrim(Str(dv)) + ' '
   RN  := RN + AllTrim(Str(dvcb)) + ' '
   RN  := RN + cFatorVencto + StrZero((nValor * 100),10)

Return({CB,RN,NN})

// #################################
// Função que valida as perguntas ##
// #################################
Static Function VALIDPERG()

   Private cAlias 	:= Alias()
   Private aRegs 	:= {}

   //          Grupo/Ordem/Pergunta             /Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
   AADD(aRegs,{cPerg,"01" ,"Prefixo			?","","","mv_ch1","C",03,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
   AADD(aRegs,{cPerg,"02","Do titulo			?","","","mv_ch2","C",06,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
   AADD(aRegs,{cPerg,"03","Ate titulo			?","","","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
   AADD(aRegs,{cPerg,"04","Da parcela			?","","","mv_ch4","C",02,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
   AADD(aRegs,{cPerg,"05","Ate a parcela		?","","","mv_ch5","C",02,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})

   DbSelectArea("SX1")
   DbSetOrder(1)
   For nConti:=1 to Len(aRegs)
       If !DbSeek(cPerg+aRegs[nConti,2])
		  RecLock("SX1",.T.)
		  For nContj:=1 to FCount()
			  If nContj<=Len(aRegs[nConti])
				 FieldPut(nContj,aRegs[nConti,nContj])
			  Endif
		  Next
		  MsUnlock()
	   Endif
   Next

   DbSelectArea(cAlias)

Return()

// #######################################################################################################
// Função que calcula o valor da retenção de imposto verificando o cadastro dos produtos da nota fiscal ##
// Regra para cálculo das retenções de PIS, COFINS e CSLL                                               ##
// Esta regra foi definina no dia 28/10/2015 juntamente com Paulo, Adriana e Harald                     ##
// Caso o Cliente tiver em seu cadastro congigurado o PIS = S ou COFINS = S ou CSLL = S, indica que   o ##
// cliente terá cálculo de retenção de Impostos.                                                        ##
// Caso  o  produto  da  nota estiver consigurado com PIS = S ou COFINS = S ou CSLL = S, sistema deverá ##
// calcular a retenção de impostos.                                                                     ##
// ####################################################################################################### 
Static Function SAbatimento()

   Local cSql       := ""
   Local nVlrPIS    := 0
   Local nVlrCofins := 0
   Local nVlrCSLL   := 0
   Local nVlrIRRF   := 0
   Local nVlrINSS   := 0   
   Local aRetencao  := {}

   // ############################################################################################
   // Verifica se o cliente da nota fiscal está parametrizado para cálcular retenção de imposto ##
   // ############################################################################################
   If Posicione("SA1",1,xFilial("SA1") + T_SE1->E1_CLIENTE + T_SE1->E1_LOJA,"A1_RECPIS")  == "S" .Or. ;
      Posicione("SA1",1,xFilial("SA1") + T_SE1->E1_CLIENTE + T_SE1->E1_LOJA,"A1_RECCSLL") == "S" .Or. ;   
      Posicione("SA1",1,xFilial("SA1") + T_SE1->E1_CLIENTE + T_SE1->E1_LOJA,"A1_RECCOFI") == "S"

      // ##############
      // Dados da NF ##
      // ##############
      If Select("T_ABATIMENTO") > 0
         T_ABATIMENTO->( dbCloseArea() )
      EndIf

      cSql := "SELECT SD2.D2_FILIAL ,"
      cSql += "       SD2.D2_DOC    ,"
      cSql += "       SD2.D2_SERIE  ,"
      cSql += "       SD2.D2_COD    ,"
      cSql += " 	  SB1.B1_PIS    ,"
      cSql += " 	  SD2.D2_BASEPIS,"
      cSql += " 	  SD2.D2_ALQPIS ,"
      cSql += " 	  SD2.D2_VALPIS ,"
      cSql += " 	  SD2.D2_BASEISS,"
      cSql += " 	  SD2.D2_ALIQISS,"
      cSql += " 	  SD2.D2_VALISS ,"
      cSql += " 	  SB1.B1_COFINS ,"
      cSql += " 	  SD2.D2_BASECOF,"
      cSql += " 	  SD2.D2_ALQCOF ,"
      cSql += " 	  SD2.D2_VALCOF ,"
      cSql += " 	  SB1.B1_CSLL   ,"
      cSql += " 	  SD2.D2_BASECSL,"
      cSql += " 	  SD2.D2_ALQCSL ,"
      cSql += " 	  SD2.D2_VALCSL ,"
      cSql += "       SB1.B1_IRRF   ,"
      cSql += "       SD2.D2_ALQIRRF,"
      cSql += "       SD2.D2_BASEIRR,"
      cSql += "       SD2.D2_VALIRRF,"
      cSql += "       SB1.B1_INSS   ,"
      cSql += "       SD2.D2_ALIQINS,"
      cSql += "       SD2.D2_BASEINS,"
      cSql += "       SD2.D2_VALINS  "
      cSql += "  FROM " + RetSqlName("SD2") + " SD2, "
      cSql += "       " + RetSqlName("SB1") + " SB1  "
      cSql += " WHERE SD2.D2_DOC     = '" + Alltrim(T_SE1->E1_NUM)     + "'"
      cSql += "   AND SD2.D2_SERIE   = '" + Alltrim(T_SE1->E1_PREFIXO) + "'"
      cSql += "   AND SD2.D2_FILIAL  = '" + Alltrim(T_SE1->E1_FILORIG) + "'"
      cSql += "   AND SD2.D_E_L_E_T_ = ''"
      cSql += "   AND SB1.B1_COD     = SD2.D2_COD"
      cSql += "   AND SB1.D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_ABATIMENTO", .T., .T. )

      T_ABATIMENTO->( DbGoTop() )

      aAdd( aRetencao, { 0, 0, 0, 0, 0 } )

      nVlrPIS    := 0
      nVlrCofins := 0
      nVlrCSLL   := 0
      nVlrIRRF   := 0
      nVlrINSS   := 0      
   
      WHILE !T_ABATIMENTO->( EOF() )
 
         // ######
         // PIS ##
         // ######
         If T_ABATIMENTO->B1_PIS == "1"
            nVlrPIS := nVlrPIS + T_ABATIMENTO->D2_VALPIS
            aRetencao[01,01] := nVlrPIS
         Endif   

         // ######### 
         // COFINS ##
         // #########
         If T_ABATIMENTO->B1_COFINS == "1"
            nVlrCofins := nVlrCofins + T_ABATIMENTO->D2_VALCOF
            aRetencao[01,02] := nVlrCofins
         Endif   

         // #######
         // CSLL ##
         // #######
         If T_ABATIMENTO->B1_CSLL == "1"
            nVlrCSLL := nVlrCSLL + T_ABATIMENTO->D2_VALCSL
            aRetencao[01,03] := nVlrCSLL
         Endif   

         // #######
         // IRRF ##
         // #######
         If T_ABATIMENTO->B1_IRRF == "S"
            nVlrIRRF := nVlrIRRF + T_ABATIMENTO->D2_VALIRRF
            aRetencao[01,04] := nVlrIRRF
         Endif   

         // #######
         // INSS ##
         // #######         
         If T_ABATIMENTO->B1_INSS == "S"
            nVlrINSS := nVlrINSS + T_ABATIMENTO->D2_VALINS
            aRetencao[01,05] := nVlrINSS
         Endif   

         T_ABATIMENTO->( DbSkip() )
      
      ENDDO
      
   Else

      aAdd( aRetencao, { 0, 0, 0, 0, 0 } )   
   
   Endif

Return aRetencao

// ###########################################
// Função que calcula o valor do abatimento ##
// ###########################################
Static Function xSAbatimento()

   Local cSql      := ""
   Local nImpostos := 0

   If Select("T_IMPOSTOS") > 0
      T_IMPOSTOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SUM(E1_VALOR) AS IMPOSTOS"
   cSql += "  FROM " + RetSqlName("SE1")
   cSql += " WHERE E1_NUM     = '" + Alltrim(T_SE1->E1_NUM)     + "'"
   cSql += "   AND E1_PREFIXO = '" + Alltrim(T_SE1->E1_PREFIXO) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"
   cSql += "   AND E1_TIPO IN ('CS-', 'PI-', 'CF-', 'IR-', 'IN-')"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_IMPOSTOS", .T., .T. )

   If T_IMPOSTOS->( EOF() )
      nImpostos := 0
   Else
      nImpostos := T_IMPOSTOS->IMPOSTOS
   Endif
   
Return nImpostos

// ##############################################
// Função que calcula o digíto do nosso número ##
// ##############################################
Static Function DigNossoNumero(kcNossoNum)

   Local nContar  := 0
   Local nSomaTot := 0
   Local nSomaDiv := 0
   Local nSoma01  := 0
   Local nSoma02  := 0
   Local nSoma03  := 0
   Local nSoma04  := 0
   Local nSoma05  := 0
   Local nSoma06  := 0
   Local nSoma07  := 0
   Local nSoma08  := 0
   Local nSoma09  := 0
   Local nSoma10  := 0
   Local nSoma11  := 0
   Local nSoma12  := 0
                                    
   nSoma01  := INT(VAL(Substr(kcNossoNum,01,01))) * 5
   nSoma02  := INT(VAL(Substr(kcNossoNum,02,01))) * 4
   nSoma03  := INT(VAL(Substr(kcNossoNum,03,01))) * 3
   nSoma04  := INT(VAL(Substr(kcNossoNum,04,01))) * 2
   nSoma05  := INT(VAL(Substr(kcNossoNum,05,01))) * 9                          
   nSoma06  := INT(VAL(Substr(kcNossoNum,06,01))) * 8
   nSoma07  := INT(VAL(Substr(kcNossoNum,07,01))) * 7
   nSoma08  := INT(VAL(Substr(kcNossoNum,08,01))) * 6
   nSoma09  := INT(VAL(Substr(kcNossoNum,09,01))) * 5
   nSoma10  := INT(VAL(Substr(kcNossoNum,10,01))) * 4                          
   nSoma11  := INT(VAL(Substr(kcNossoNum,11,01))) * 3
   nSoma12  := INT(VAL(Substr(kcNossoNum,12,01))) * 2                          

   nSomaTot := nSoma01 + nSoma02 + nSoma03 + nSoma04 + nSoma05 + nSoma06 + nSoma07 + nSoma08 + nSoma09 + nSoma10 + nSoma11 + nSoma12

   Do Case
      Case Mod(nSomaTot,11) == 10
           nSomaDig := 1
      Case Mod(nSomaTot,11) == 0
           nSomaDig := 0
      Case Mod(nSomaTot,11) == 1
           nSomaDig := 0   
      Otherwise     
           nSomaDig := 11 - Mod(nSomaTot,11)
   EndCase

Return(nSomaDig)

// ##################################################
// Função que calcula o digíto do código de barras ##
// ##################################################
Static Function DigCodBarras(_CodBarras)

   Local nSomaTot := 0
   Local nContar  := 0

   Local nSoma01 := 0 
   Local nSoma02 := 0 
   Local nSoma03 := 0 
   Local nSoma04 := 0 
   Local nSoma05 := 0 
   Local nSoma06 := 0 
   Local nSoma07 := 0 
   Local nSoma08 := 0 
   Local nSoma09 := 0 
   Local nSoma10 := 0
   Local nSoma11 := 0 
   Local nSoma12 := 0 
   Local nSoma13 := 0 
   Local nSoma14 := 0 
   Local nSoma15 := 0 
   Local nSoma16 := 0 
   Local nSoma17 := 0 
   Local nSoma18 := 0 
   Local nSoma19 := 0 
   Local nSoma20 := 0
   Local nSoma21 := 0 
   Local nSoma22 := 0 
   Local nSoma23 := 0 
   Local nSoma24 := 0 
   Local nSoma25 := 0 
   Local nSoma26 := 0 
   Local nSoma27 := 0 
   Local nSoma28 := 0 
   Local nSoma29 := 0 
   Local nSoma30 := 0
   Local nSoma31 := 0 
   Local nSoma32 := 0 
   Local nSoma33 := 0 
   Local nSoma34 := 0 
   Local nSoma35 := 0 
   Local nSoma36 := 0 
   Local nSoma37 := 0 
   Local nSoma38 := 0 
   Local nSoma39 := 0 
   Local nSoma40 := 0 
   Local nSoma41 := 0 
   Local nSoma42 := 0 
   Local nSoma43 := 0

   nSoma01 := INT(VAL(Substr(_CodBarras,01,01))) * 4
   nSoma02 := INT(VAL(Substr(_CodBarras,02,01))) * 3
   nSoma03 := INT(VAL(Substr(_CodBarras,03,01))) * 2
   nSoma04 := INT(VAL(Substr(_CodBarras,04,01))) * 9
   nSoma05 := INT(VAL(Substr(_CodBarras,05,01))) * 8
   nSoma06 := INT(VAL(Substr(_CodBarras,06,01))) * 7
   nSoma07 := INT(VAL(Substr(_CodBarras,07,01))) * 6
   nSoma08 := INT(VAL(Substr(_CodBarras,08,01))) * 5
   nSoma09 := INT(VAL(Substr(_CodBarras,09,01))) * 4
   nSoma10 := INT(VAL(Substr(_CodBarras,10,01))) * 3
   nSoma11 := INT(VAL(Substr(_CodBarras,11,01))) * 2
   nSoma12 := INT(VAL(Substr(_CodBarras,12,01))) * 9
   nSoma13 := INT(VAL(Substr(_CodBarras,13,01))) * 8
   nSoma14 := INT(VAL(Substr(_CodBarras,14,01))) * 7
   nSoma15 := INT(VAL(Substr(_CodBarras,15,01))) * 6
   nSoma16 := INT(VAL(Substr(_CodBarras,16,01))) * 5
   nSoma17 := INT(VAL(Substr(_CodBarras,17,01))) * 4
   nSoma18 := INT(VAL(Substr(_CodBarras,18,01))) * 3
   nSoma19 := INT(VAL(Substr(_CodBarras,19,01))) * 2
   nSoma20 := INT(VAL(Substr(_CodBarras,20,01))) * 9
   nSoma21 := INT(VAL(Substr(_CodBarras,21,01))) * 8
   nSoma22 := INT(VAL(Substr(_CodBarras,22,01))) * 7
   nSoma23 := INT(VAL(Substr(_CodBarras,23,01))) * 6
   nSoma24 := INT(VAL(Substr(_CodBarras,24,01))) * 5
   nSoma25 := INT(VAL(Substr(_CodBarras,25,01))) * 4
   nSoma26 := INT(VAL(Substr(_CodBarras,26,01))) * 3
   nSoma27 := INT(VAL(Substr(_CodBarras,27,01))) * 2
   nSoma28 := INT(VAL(Substr(_CodBarras,28,01))) * 9
   nSoma29 := INT(VAL(Substr(_CodBarras,29,01))) * 8
   nSoma30 := INT(VAL(Substr(_CodBarras,30,01))) * 7
   nSoma31 := INT(VAL(Substr(_CodBarras,31,01))) * 6
   nSoma32 := INT(VAL(Substr(_CodBarras,32,01))) * 5
   nSoma33 := INT(VAL(Substr(_CodBarras,33,01))) * 4
   nSoma34 := INT(VAL(Substr(_CodBarras,34,01))) * 3
   nSoma35 := INT(VAL(Substr(_CodBarras,35,01))) * 2
   nSoma36 := INT(VAL(Substr(_CodBarras,36,01))) * 9
   nSoma37 := INT(VAL(Substr(_CodBarras,37,01))) * 8
   nSoma38 := INT(VAL(Substr(_CodBarras,38,01))) * 7
   nSoma39 := INT(VAL(Substr(_CodBarras,39,01))) * 6
   nSoma40 := INT(VAL(Substr(_CodBarras,40,01))) * 5
   nSoma41 := INT(VAL(Substr(_CodBarras,41,01))) * 4
   nSoma42 := INT(VAL(Substr(_CodBarras,42,01))) * 3
   nSoma43 := INT(VAL(Substr(_CodBarras,43,01))) * 2
   
   nSomaTot := nSoma01 + nSoma02 + nSoma03 + nSoma04 + nSoma05 + nSoma06 + nSoma07 + nSoma08 + nSoma09 + nSoma10
   nSomaTot += nSoma11 + nSoma12 + nSoma13 + nSoma14 + nSoma15 + nSoma16 + nSoma17 + nSoma18 + nSoma19 + nSoma20
   nSomaTot += nSoma21 + nSoma22 + nSoma23 + nSoma24 + nSoma25 + nSoma26 + nSoma27 + nSoma28 + nSoma29 + nSoma30 
   nSomaTot += nSoma31 + nSoma32 + nSoma33 + nSoma34 + nSoma35 + nSoma36 + nSoma37 + nSoma38 + nSoma39 + nSoma40 
   nSomaTot += nSoma41 + nSoma42 + nSoma43 

   nSomaTot := nSomaTot * 10
   nSomaDiv := Mod(nSomaTot,11)

   If nSomaDiv == 0
      nSomaDiv := 1
   Endif                                                                

   If nSomaDiv == 1
      nSomaDiv := 1
   Endif   

   If nSomaDiv == 10
      nSomaDiv := 1
   Endif   
  
Return(nSomaDiv)


Static Function fPrintPDF() 

   Local lAdjustToLegacy := .F.
   Local lDisableSetup  := .T.
   Local oPrinter
   Local cLocal          := "c:\DANFE\"
   Local cCodINt25 := "34190184239878442204400130920002152710000053475"
   Local cCodEAN :=      "123456789012"   
   Local cFilePrint := ""

   oPrinter := FWMSPrinter():New('orcamento_000000.PD_', IMP_PDF, lAdjustToLegacy,cLocal, lDisableSetup, , , , , , .F., )
   oPrinter:FWMSBAR("INT25" /*cTypeBar*/,1/*nRow*/ ,1/*nCol*/, cCodINt25/*cCode*/,oPrinter/*oPrint*/,.T./*lCheck*/,/*Color*/,.T./*lHorz*/,0.02/*nWidth*/,0.8/*nHeigth*/,.T./*lBanner*/,"Arial"/*cFont*/,NIL/*cMode*/,.F./*lPrint*/,2/*nPFWidth*/,2/*nPFHeigth*/,.F./*lCmtr2Pix*/)
   oPrinter:FWMSBAR("EAN13" /*cTypeBar*/,5/*nRow*/ ,1/*nCol*/ ,cCodEAN  /*cCode*/,oPrinter/*oPrint*/,/*lCheck*/,/*Color*/,/*lHorz*/, /*nWidth*/,/*nHeigth*/,/*lBanner*/,/*cFont*/,/*cMode*/,.F./*lPrint*/,/*nPFWidth*/,/*nPFHeigth*/,/*lCmtr2Pix*/)
   oPrinter:Box( 130, 10, 500, 700, "-4")
   oPrinter:Say(210,10,"Teste para Code128C")

   cFilePrint := cLocal+"orcamento_000000.PD_"

   File2Printer( cFilePrint, "PDF" )
   oPrinter:cPathPDF:= cLocal 
   oPrinter:Preview()

Return(.T.)





