#INCLUDE "rwmake.Ch"
#INCLUDE "Protheus.Ch"
#include "ap5mail.ch"
#include "colors.ch"
#INCLUDE "jpeg.ch" 

// ###################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            ##
// -------------------------------------------------------------------------------- ##
// Referencia: SANTANDER.PRW                                                        ##
// Parâmetros: Nenhum                                                               ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      ##
// -------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                              ##
// Data......: 16/05/2017                                                           ##
// Objetivo..: Geração de boleto para o Banco Santander                             ##
// ###################################################################################

User Function SANTANDER(lBord, cNumNota, cNumSerie, cPorOnde)

   Local cMemo1	 := ""
   Local cMemo2	 := ""
   Local oMemo1
   Local oMemo2

   Private _lBord   := lBord
   Private lPorOnde := cPorOnde
   Private cQuery   := {}

   Private cPrefixo	 := Space(03)
   Private cNum01	 := Space(09)
   Private cNum02	 := Space(09)
   Private cPar01	 := Space(02)
   Private cPar02	 := Space(02)
   Private oGet1
   Private oGet2
   Private oGet3
   Private oGet4
   Private oGet5

   Private oDlg

   If lPorOnde == Nil
      lPorOnde := ""
   Endif

   // ####################################################################################
   // Se programa chamado pela nota fiscal, imprime pelos parâmetros passados na função ##
   // ####################################################################################
   If _lBord
      mv_par01 := cNumSerie
      mv_par02 := cNumNota
	  mv_par03 := cNumNota
	  mv_par04 := ""
	  mv_par05 := "ZZ"
	  ImprimeDup()
   Else

      mv_par01 := Space(03)
      mv_par02 := Space(09)
	  mv_par03 := "ZZZZZZZZZ"
	  mv_par04 := "  "
	  mv_par05 := "ZZ"

      cPrefixo	 := "   "
      cNum01	 := "         "
      cNum02	 := "ZZZZZZZZZ"
      cPar01	 := "  "
      cPar02	 := "ZZ"

      DEFINE MSDIALOG oDlg TITLE "Boleto Banco Santander" FROM C(178),C(181) TO C(512),C(430) PIXEL

      @ C(002),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(118),C(026) PIXEL NOBORDER OF oDlg
      @ C(036),C(022) Jpeg FILE "santander.bmp"   Size C(118),C(024) PIXEL NOBORDER OF oDlg

      @ C(032),C(002) GET oMemo1 Var cMemo1 MEMO Size C(117),C(001) PIXEL OF oDlg
      @ C(144),C(002) GET oMemo2 Var cMemo2 MEMO Size C(117),C(001) PIXEL OF oDlg
   
      @ C(064),C(020) Say "Informe dados abaixo para emissão de boletos" Size C(111),C(008) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(078),C(005) Say "Prefixo"                                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(099),C(005) Say "Do Título"                                    Size C(025),C(008) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(099),C(070) Say "Até o Título"                                 Size C(036),C(008) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(121),C(005) Say "Da Parcela"                                   Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(121),C(070) Say "Até a Parcela"                                Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlg

      @ C(087),C(005) MsGet oGet1 Var cPrefixo Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(109),C(005) MsGet oGet2 Var cNum01   Size C(050),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(109),C(070) MsGet oGet3 Var cNum02   Size C(050),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(130),C(005) MsGet oGet4 Var cPar01   Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(130),C(070) MsGet oGet5 Var cpar02   Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

      @ C(150),C(022) Button "Imprimir" Size C(037),C(012) PIXEL OF oDlg ACTION( CarregaMV() )
      @ C(150),C(061) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

      ACTIVATE MSDIALOG oDlg CENTERED 
      
   Endif

Return()

// ########################################################################
// Função que carrega os parâmetros para impressão dos boletos bancários ##
// ########################################################################
Static Function CarregaMV()

   mv_par01 := cPrefixo
   mv_par02 := cNum01
   mv_par03 := cNum02
   mv_par04 := cPar01
   mv_par05 := cPar02

   ImprimeDup()
  
Return(.T.)

// ############################################
// Função que imprime o boleto do Banco Itaú ##
// ############################################
Static Function ImprimeDup()

   LOCAL lPrimVez    := .T.
   LOCAL aDadosEmp   := {}
   LOCAL xMensg1	 := ""
   LOCAL xMensg2	 := ""
   LOCAL lBoleto   	 := .f. //Caso o boleto seja gerado somento pelo financeiro.
   Local cSql        := ""
   Local cCondicao   := ""
   Local cEZero      := .F.
   Local nContar     := 0
   Local cCompara    := ""
   Local cSql        := ""
   Local lJaImpresso := .F.
   Local cMensagem   := ""
   
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

   If Select("T_SE1") > 0
      T_SE1->( dbCloseArea() )
   EndIf

   cQuery := {}
   cQuery := " SELECT SE1.E1_TIPO   , "
   cQuery += "        SE1.E1_VALOR  , " 
   cQuery += "        SE1.E1_PREFIXO, "
   cQuery += "        SE1.E1_NUM    , "
   cQuery += "        SE1.E1_FILORIG, "
   cQuery += "        SE1.E1_PEDIDO , "
   cQuery += "        SE1.E1_CLIENTE, "
   cQuery += "        SE1.E1_LOJA   , "
   cQuery += "        SE1.E1_PARCELA, "
   cQuery += "        SE1.E1_EMISSAO, "
   cQuery += "        SE1.E1_VENCTO , "
   cQuery += "        SE1.E1_VENCREA, "
   cQuery += "        SE1.E1_NUMBCO , "
   cQuery += "        SE1.E1_PORTADO, "
   cQuery += "        SE1.E1_IRRF   , "
   cQuery += "        SE1.E1_ISS    , "
   cQuery += "        SE1.E1_INSS   , "
   cQuery += "        SE1.E1_PIS    , "
   cQuery += "        SE1.E1_COFINS , "
   cQuery += "        SE1.E1_CSLL   , "
   cQuery += "        SE1.E1_FILORIG, "
   cQuery += "        SE1.E1_MOEDA  , "
   cQuery += "        SE1.E1_NUMBOR , "
   cQuery += "        SE1.E1_IDCNAB , "
   cQuery += "        SA1.A1_BOLET  , "
   cQuery += "        SA1.A1_NOME     "   
   cQuery += "   FROM " + RetSqlName("SE1") + " SE1, "
   cQuery += "        " + RetSqlName("SA1") + " SA1  "
   cQuery += "  WHERE SE1.E1_PREFIXO     = '"   + MV_PAR01 + "' "
   cQuery += "    AND SE1.E1_NUM     BETWEEN '" + MV_PAR02 + "' AND '" + MV_PAR03 + "' "
   cQuery += "    AND SE1.E1_PARCELA BETWEEN '" + MV_PAR04 + "' AND '" + MV_PAR05 + "' "
   cQuery += "    AND SE1.E1_TIPO = 'NF'"
   cQuery += "    AND (SE1.E1_ORIGEM     = 'MATA460' OR SE1.E1_ORIGEM = 'FINA280' OR SE1.E1_ORIGEM = 'FINA040') " // Incluida validação para a origem do título. Boletos serão gerados apenas para títulos gerados pelo faturamento.
   cQuery += "    AND SE1.D_E_L_E_T_ = ' '  "                                                         // Por solicitação do Harald, titulos faturados também poderão gerar boletos. 03/10/2011.
   cQuery += "    AND SA1.A1_COD     = SE1.E1_CLIENTE"
   cQuery += "    AND SA1.A1_LOJA    = SE1.E1_LOJA"
   cQuery += "    AND SA1.D_E_L_E_T_ = ''"
   cQuery += "  ORDER BY SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO "

   cQuery := ChangeQuery(cQuery)
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"T_SE1",.T.,.T.)

   TCSetField("T_SE1","E1_EMISSAO","D",08,00)
   TCSetField("T_SE1","E1_VENCTO" ,"D",08,00)
   TCSetField("T_SE1","E1_VENCREA","D",08,00)
   TCSetField("T_SE1","E1_IRRF"   ,"N",14,02)
   TCSetField("T_SE1","E1_ISS"    ,"N",14,02)                                                                                                        
   TCSetField("T_SE1","E1_INSS"   ,"N",14,02)
   TCSetField("T_SE1","E1_PIS"    ,"N",14,02)
   TCSetField("T_SE1","E1_COFINS" ,"N",14,02)
   TCSetField("T_SE1","E1_CSLL"   ,"N",14,02)
   TCSetField("T_SE1","E1_VALOR"  ,"N",14,02)

   DbSelectArea("T_SE1")
 
   // ################
   // Count to nReg ##
   // ################
   If EOF()
      MsgAlert("Não existem dados a serem visualizados.")
      Return(.T.)
   Endif

   // ##################################################################################################
   // Veririca se filial/pedido já tiveram seus boletos impressos pelo vendedor                       ##
   //   DbGoTop()                                                                                     ##
   //   Do While !EOF()                                                                               ##
   //                                                                                                 ##
   //      DbSelectArea("ZS0")                                                                        ##
   //	  DbSetOrder(1)                                                                               ##
   //	  If DbSeek( T_SE1->E1_FILORIG + T_SE1->E1_PEDIDO )                                           ##
   //         lJaImpresso := .T.                                                                      ##
   //         Exit                                                                                    ##
   //	  EndIf                                                                                       ##
   //                                                                                                 ##
   //      DbSelectArea("T_SE1")                                                                      ##
   //      T_SE1->( DbSkip() )                                                                        ##
   //                                                                                                 ##
   //   Enddo                                                                                         ##
   //                                                                                                 ##
   //   If lJaImpresso                                                                                ##
   //      MsgAlert("Atenção! Boleto bancário para este documento/pedido já impresso pelo vendedor.") ##
   //      Return(.T.)                                                                                ##
   //   Endif                                                                                         ##
   // ##################################################################################################  

   // ############################################################################################################
   // Verifica se existem boletos que não serão impressos pela indicação de Boleto = Não no cadastro do Cliente ##
   // ############################################################################################################
   DbSelectArea("T_SE1")
   DbGoTop()

   lPrimeiro := .T.
   cMensagem := ""

   Do While !EOF()
      If T_SE1->A1_BOLET <> "S"
         If lPrimeiro == .T.
            cMensagem := "ATENÇÃO!" + chr(13) + chr(10) + chr(13) + chr(10) 
            cMensagem += "Documentos abaixo não serão impresso -> Imprime Boleto = NÂO" + chr(13) + chr(10) + chr(13) + chr(10) 
            lPrimeiro := .F.
         Endif   
         cMensagem += "Doc Nº " + Alltrim(T_SE1->E1_NUM) + "/" + Alltrim(T_SE1->E1_PARCELA) + " - Cliente: " + Alltrim(T_SE1->A1_NOME) + CHR(13) + CHR(10)
	  Endif   
      T_SE1->(DBSKIP())
   Enddo

   If Empty(Alltrim(cMensagem))
   Else
      MsgAlert(cMensagem)
   Endif
 
   // ##################################
   // Início da Impressão dos Boletos ##
   // ##################################        
   DbSelectArea("T_SE1")
   DbGoTop()

   Do While !EOF()

      // ###########################################################
      // Despreza clientes com indicação de Imprime Boleto == Não ##
      // ###########################################################
      If T_SE1->A1_BOLET <> "S"
		 T_SE1->(DBSKIP())
	     Loop
	  Endif   

      // #####################################
      // Verifica se boleto já foi impresso ##
      // #####################################
      DbSelectArea("ZS0")
	  DbSetOrder(1)
	  If DbSeek( T_SE1->E1_FILORIG + T_SE1->E1_PEDIDO )
         If !MsgYesNo("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "O boleto do documento nº " + Alltrim(T_SE1->E1_NUM) + " já foi impresso." + chr(13) + chr(10) + "Deseja reimprimí-lo?")
   		    T_SE1->(DBSKIP())
		    Loop
		 Endif   
	  EndIf

      // ###################################################################
      // Verifica se condição de pagamento permite emitir boleto bancário ##
      // ###################################################################
      If Select("T_PODEEMITIR") > 0
         T_PODEEMITIR->( dbCloseArea() )
      EndIf
      
      cSql := ""         
      cSql := "SELECT A.F2_COND  ,"
      cSql += "       B.E4_COND  ,"
      cSql += "       B.E4_BOLET ,"
      cSql += "       B.E4_DESCRI "
      cSql += "  FROM " + RetSqlName("SF2") + " A, "
      cSql += "       " + RetSqlName("SE4") + " B  "
      cSql += " WHERE A.F2_DOC       = '" + Alltrim(T_SE1->E1_NUM)     + "'"
      cSql += "   AND A.F2_SERIE     = '" + Alltrim(T_SE1->E1_PREFIXO) + "'"
      cSql += "   AND A.F2_FILIAL    = '" + Alltrim(T_SE1->E1_FILORIG) + "'"
      cSql += "   AND A.R_E_C_D_E_L_ = '0'"
      cSql += "   AND A.F2_COND = B.E4_CODIGO"
      cSql += "   AND B.R_E_C_D_E_L_ = '0'"
      cSql += "   AND B.E4_FILIAL    = '' "

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PODEEMITIR", .T., .T. )

      If T_PODEEMITIR->E4_BOLET == "N"
         If _lBord
            Return(.T.)
         Else
            MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + ;
                     "Boleto bancário não será impresso devido a condição de pagamento " + T_PODEEMITIR->F2_COND + " - " + ;
	                     Alltrim(T_PODEEMITIR->E4_DESCRI) + " estar parametrizada para NÃO EMITIR BOLETO BANCÁRIO.")
            Return(.T.)            
         Endif   
      Endif

      // #########################################################################################
      // Verifica se boleto bancário já pertence a um borderô.                                  ##
      // Se pertencer, avisa o usuário que a impressão somente poderá ser feita pelo financeiro ##
      // Este teste somente será realizado quando lPorOnde = "U" (Solicitação pelo usuário)     ##
      // #########################################################################################
      If lPorOnde == "U"
         If Empty(Alltrim(T_SE1->E1_IDCNAB))
         Else

            // #################################################################
            // Se o grupo do usuário logado for o 000026, permite a impressão ##
            // #################################################################

            PswOrder(2)
     
            If PswSeek(cUserName,.F.)

               // ###################################
               // Obtem o resultado conforme vetor ##
               // ###################################
               _aRetUser := PswRet(1)
               _Grupo    := _aRetUser[1][10][1]
               _lLibera  := .F.

               If _Grupo$("000026")
                  _lLibera := .T.
               Endif

            Else
               _lLibera := .F. 
            Endif

            If _lLibera == .F.
//             MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + ;
//                      "Boleto bancário para o documento Nº " + Alltrim(T_SE1->E1_NUM) + " - Prefixo Nº " + Alltrim(T_SE1->E1_PREFIXO) + " somente poderá ser impresso pelo Financeiro pois o mesmo já encontra-se associado a um borderô de cobrança.")
//             Return(.T.)
            Endif
         
         Endif

      Endif

      // #############################################################################################################
      // Pesquisa a Condição de Pagamento da Nota Fiscal e verifica se existe a parametrização 00 no campo E4_COND. ##
      // Em caso positivo, verifica se a parcela lida é = Branco, 1 ou 01. Neste Caso, não imprime boleto  bancario ##
      // para esta parcela pois representa a parcela A Vista ou Entrada.                                            ##
      // Em caso de condição 107 = Negociável Valor não entra nesta condição.                                       ##
      // #############################################################################################################
      If Select("T_COND107") > 0
         T_COND107->( dbCloseArea() )
      EndIf
 
      cSql := ""
      cSql := "SELECT A.F2_COND   ,"
      cSql += "       A.F2_NFELETR "
      cSql += "  FROM " + RetSqlName("SF2") + " A "
      cSql += " WHERE A.F2_DOC     = '" + Alltrim(T_SE1->E1_NUM)     + "'"
      cSql += "   AND A.F2_SERIE   = '" + Alltrim(T_SE1->E1_PREFIXO) + "'"
      cSql += "   AND A.F2_FILIAL  = '" + Alltrim(T_SE1->E1_FILORIG) + "'"
      cSql += "   AND A.D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COND107", .T., .T. )

      // ########################################################
      // Verifica condição de pagamento 107 - Negociável Valor ##
      // ########################################################
      If T_COND107->F2_COND <> "107"

         If T_SE1->E1_PARCELA == "01" .OR. T_SE1->E1_PARCELA == "1" .OR. Alltrim(T_SE1->E1_PARCELA) == ""
            If Select("T_CONDICAO") > 0
               T_CONDICAO->( dbCloseArea() )
            EndIf
      
            cSql := ""         
            cSql := "SELECT A.F2_COND ,"
            cSql += "       B.E4_COND ,"
            cSql += "       B.E4_BOLET "
            cSql += "  FROM " + RetSqlName("SF2") + " A, "
            cSql += "       " + RetSqlName("SE4") + " B  "
            cSql += " WHERE A.F2_DOC       = '" + Alltrim(T_SE1->E1_NUM)     + "'"
            cSql += "   AND A.F2_SERIE     = '" + Alltrim(T_SE1->E1_PREFIXO) + "'"
            cSql += "   AND A.F2_FILIAL    = '" + Alltrim(T_SE1->E1_FILORIG) + "'"
            cSql += "   AND A.R_E_C_D_E_L_ = '0'"
            cSql += "   AND A.F2_COND = B.E4_CODIGO"
            cSql += "   AND B.R_E_C_D_E_L_ = '0'"
            cSql += "   AND B.E4_FILIAL    = '' "

            cSql := ChangeQuery( cSql )
            dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONDICAO", .T., .T. )

            If !T_CONDICAO->( EOF() )

               If T_CONDICAO->E4_BOLET == "S"
               Else
                  MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + ;
                           "A condição de pagamento do documento " + Alltrim(Alltrim(T_SE1->E1_NUM)) + "/" + Alltrim(T_SE1->E1_PREFIXO) + " está parametrizada" + chr(13) + chr(10) + ;
                           "para não emitir boleto bancário." + chr(13) + chr(10) + ;
                           "Boleto Bancário não será impresso para este documento.")
                  T_SE1->(DBSKIP())                           
                  Loop
               Endif

               cCondicao := ""
               cEZero    := .F.
               For nContar = 1 To Len(T_CONDICAO->E4_COND)
                   If SubStr(T_CONDICAO->E4_COND,nContar,1) <> "," .AND. ;
                     SubStr(T_CONDICAO->E4_COND,nContar,1) <> " "                
                      cCondicao := cCondicao + SubStr(T_CONDICAO->E4_COND,nContar,1)
                   Else
                      If Alltrim(cCondicao) == "0" .OR. Alltrim(cCondicao) == "00"
                         cEZero := .T.
                         Exit
                      Endif
                      cCondicao := ""
                   Endif
               Next nContar
               If cEZero
                  T_SE1->(DBSKIP())                           
                  Loop
               Endif
            Endif
         Endif
      Endif   

      DbSelectArea("SA1")
	  DbSetOrder(1)

	  If !DbSeek(xFilial("SA1")+T_SE1->E1_CLIENTE+T_SE1->E1_LOJA)
	   	 DbSelectArea("T_SE1")
		 T_SE1->(DBSKIP())
		 Loop
	  EndIf

	  aDatSacado := {}
	  cCodCli    := AllTrim(SA1->A1_COD) + AllTrim(SA1->A1_LOJA)
	
	  If !Empty(SA1->A1_ENDCOB)
	   	 aDatSacado := 	{AllTrim(SA1->A1_NOME),;					// [1]Razão Social
		 AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA,;					// [2]Código
		 AllTrim(SA1->A1_ENDCOB )+" - "+AllTrim(SA1->A1_BAIRROC),;	// [3]Endereço
		 AllTrim(SA1->A1_MUNC ),;									// [4]Cidade
		 SA1->A1_ESTC,;												// [5]Estado
		 SA1->A1_CEPC,;												// [6]CEP
		 SA1->A1_CGC}												// [7]CGC
	  Else
		 aDatSacado := 	{AllTrim(SA1->A1_NOME),;					// [1]Razão Social
		 AllTrim(SA1->A1_COD )+"-"+SA1->A1_LOJA,;					// [2]Código
		 AllTrim(SA1->A1_END )+" - "+AllTrim(SA1->A1_BAIRRO),;		// [3]Endereço
		 AllTrim(SA1->A1_MUN ),;										// [4]Cidade
		 SA1->A1_EST,;												// [5]Estado
		 SA1->A1_CEP,;												// [6]CEP
		 SA1->A1_CGC}												// [7]CGC
	  EndIf
	
	  xMsg1       := "ATÉ O VENCIMENTO PAGUE PREFERENCIALMENTE NO SANTANDER"
	  xMsg2       := "APOS O VENCIMENTO PAGUE SOMENTE NO SANTANDER"
	
      Do Case
         // Grupo Empresa -> 01 - Porto Alegre/RS
         Case cEmpAnt == "01"
     	      xBanco 	  := "033"
	          xNomeBanco  := "BANCO SANTANDER"
	          xNumBanco   := "033"
	          xCartCob    := "101"
	          xCodCedente := "130015489 "
	          xConta      := "130015489 "
	          xDVConta    := ""
	          xAgencia    := "1011 "
              kFilial     := "01"

         // Grupo Empresa -> 02 - TI AUTOMAÇÃO
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

         // Grupo Empresa -> 03 - Atech
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
	                    Alltrim(xAgencia),; // [3]Agência
	                    Alltrim(xConta)  ,;	// [4]Conta Corrente
	                    xDvConta         ,; // [5]Dígito da conta corrente
	                    xCartCob         ,; // [6]Codigo da Carteira
	                    xCodCedente       } // [7]Codigo Cedente
	
      If cEmpAnt == "02"
         xx_SubConta := "005"
      Else
         xx_SubConta := "001"         
      Endif

      DbSelectArea("SEE")
	  DbSetOrder(1)
	  If !DbSeek(kFilial + xNumBanco + xAgencia + xConta + xx_SubConta) 
	     Alert("Conta Cobrança Sem Parâmetros !")
	     Set Century Off
	     DbSelectArea("T_SE1")
	     DbCloseArea()
	     Return()
	  EndIf

	  DbSelectArea("T_SE1")
	  If !Empty(T_SE1->E1_PARCELA)
	   	 nPos := AT(T_SE1->E1_PARCELA,cTabParc)
		 cParcela := StrZero(nPos,2)
	  Else
		 cParcela := "00"
	  EndIf
	
      // ###########################################################################
	  // Se for da rotina chamada pela geração da NF, pega o nosso número do SEE. ##
      // ###########################################################################
	  If _lBord

	   	 cQuery := {}
		 cQuery := " SELECT EE_NUMBCO "
		 cQuery += "   FROM " + RETSQLNAME("SEE")
		 cQuery += "  WHERE EE_FILIAL  = '" + Alltrim(kFilial)  + "'"
		 cQuery += "    AND EE_CODIGO  = '" + Alltrim(xBanco)   + "'"
		 cQuery += "    AND EE_AGENCIA = '" + Alltrim(xAgencia) + "'"
		 cQuery += "    AND EE_CONTA   = '" + Alltrim(xConta)   + "'"
		 cQuery += "    AND EE_SUBCTA  = '001' "
		 cQuery += "    AND D_E_L_E_T_ <> '*' "

		 cQuery := ChangeQuery(cQuery)
		 dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'TEMPSEE',.T.,.T.)

		 DbSelectArea("TEMPSEE")
		 j := TEMPSEE->EE_NUMBCO
		 DbSelectArea("TEMPSEE")
		 DbCloseArea()
		
         // ########################################## 
		 // Caso não encontre, finaliza a operação. ##
		 // ##########################################
		 If Empty(xNossoNum)
			MsgBox("Não foi possivel localizar o registro. Favor verificar!")
			Return()
		 EndIf

		 _cNossoNum := STRZERO(Val(xNossoNum),8)

         // ####################################################################################
         // Verifica se o nº capturado já existe na E1. Se existir, pesquisa  o próximo livre ##
         // ####################################################################################
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

	  Else

		 xNossoNum := Left(T_SE1->E1_NUMBCO, 8)

		 If Empty(xNossoNum)

			lBoleto := .t. //Caso o boleto seja gerado somente pelo financeiro.
			cQuery := {}
			cQuery := " SELECT EE_NUMBCO"
			cQuery += "   FROM "+ RETSQLNAME("SEE")
  		    cQuery += "  WHERE EE_FILIAL  = '" + Alltrim(kFilial)  + "'"
		    cQuery += "    AND EE_CODIGO  = '" + Alltrim(xBanco)   + "'"
		    cQuery += "    AND EE_AGENCIA = '" + Alltrim(xAgencia) + "'"
		    cQuery += "    AND EE_CONTA   = '" + Alltrim(xConta)   + "'"
		    cQuery += "    AND EE_SUBCTA  = '001' "
		    cQuery += "    AND D_E_L_E_T_ <> '*' "

			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'TEMPSEE',.T.,.T.)

			DbSelectArea("TEMPSEE")
			xNossoNum := TEMPSEE->EE_NUMBCO
			DbSelectArea("TEMPSEE")
			DbCloseArea()
			
            // ####################################################################################
            // Verifica se o nº capturado já existe na E1. Se existir, pesquisa  o próximo livre ##
            // ####################################################################################
      	    cCompara := STRZERO(INT(VAL(xNossoNum)),8)

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

   		    xNossoNum := cCompara

            // ########################################################################################
			// Caso esteja vazio o campo E1_NUMBCO, o título e a sequencia no SEE serão atualizados. ##
			// ########################################################################################
			DbSelectArea("SE1")
			DbSetOrder(1)
			If DbSeek(xFilial("SE1") + T_SE1->E1_PREFIXO + T_SE1->E1_NUM + T_SE1->E1_PARCELA + T_SE1->E1_TIPO)
				
			   RecLock("SE1",.F.)
			   SE1->E1_NUMBCO  := StrZero(Val(xNossoNum),8) //+ xDvNossoNum
			   MsUnLock()
				
			   DbSelectArea("SEE")
			   DbSetOrder(1)
			   If DbSeek(kFilial + xNumBanco + xAgencia + xConta + "001")
			   	  RecLock("SEE",.F.)
     			  SEE->EE_NUMBCO := SOMA1(Right(xNossoNum,j6))
				  MsUnLock()
			   EndIf
				
			EndIf

 		 EndIf

		 _cNossoNum := xNossoNum

	  EndIf
	
      // #########################################################################################
 	  // Se for geração de boleto pela NF, atualiza o nosso número no título e parâmetro banco. ##
 	  // #########################################################################################
	  If _lBord

	   	 DbSelectArea("SE1")
		 DbSetOrder(1)
		 If DbSeek(xFilial("SE1") + T_SE1->E1_PREFIXO + T_SE1->E1_NUM + T_SE1->E1_PARCELA + T_SE1->E1_TIPO)
			
			RecLock("SE1",.F.)
			SE1->E1_NUMBCO  := StrZero(Val(xNossoNum),8)// + xDvNossoNum
			MsUnLock()
			
			DbSelectArea("SEE")
			DbSetOrder(1)
			If DbSeek(kFilial + xNumBanco + xAgencia + xConta + "001")
				RecLock("SEE",.F.)
   			    SEE->EE_NUMBCO := SOMA1(Right(xNossoNum,6))
				MsUnLock()
			EndIf
			
		 EndIf

  	  EndIf
	
	  DbSelectArea("T_SE1")
	
	  If lPrimVez
		 lPrimVez	:= .f.
		 If lBoleto
			MsgBox("Não havia boleto gerado pelo faturamento para este título. Um boleto será gerado pelo financeiro.")
			lBoleto		:= .f.
		EndIf
		oPrint:=TMSPrinter():New( "Boleto Bancario" )
		oPrint:SetPortrait()
	 EndIf
	
	 DbSelectArea("T_SE1")
	 _nVlrAbat := T_SE1->E1_IRRF + T_SE1->E1_INSS + T_SE1->E1_PIS + T_SE1->E1_COFINS + T_SE1->E1_CSLL

     // ################################
     // Calcula o valor do abatimento ##
     // ################################
     nAbatimento := 0
     nAbatimento := xSAbatimento()      

     If Alltrim(T_SE1->E1_PREFIXO) == "11" .Or. Alltrim(T_SE1->E1_PREFIXO) == "13"
        If nAbatimento < 10
           nAbatimento := 0
        Endif
     Endif

     // ##################################################
     // Verifica se deve ser cobrado a Despesa Bancária ##
     // ##################################################
     If Posicione("SA1",1,xFilial("SA1") + T_SE1->E1_CLIENTE + T_SE1->E1_LOJA, "A1_COBTAX") == "S"

        If Select("T_PARAMETROS") > 0
           T_PARAMETROS->( dbCloseArea() )
        EndIf
   
        cSql := ""
        cSql := "SELECT ZZ4_DTAX FROM ZZ4010"

        cSql := ChangeQuery( cSql )
        dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

        nCobraTaxa := IIF(T_PARAMETROS->( EOF() ), 0, T_PARAMETROS->ZZ4_DTAX)

     Else

        ncCobraTaxa :=  0        

     Endif

     // #####################################
     // Linha digitável do boleto bancário ##
     // #####################################

     // ##################################################
     // Prepara o nosso número para o formato Santander ##
     // ##################################################
     _cNossoNum  := Strzero(Int(Val(_cNossoNum)),12)
     _DigNossoN  := Alltrim(Str(DigNossoNumero(_cNossoNum)))
     xNossoNum   := _cNossoNum
     xDvNossoNum := _DigNossoN

     // #######################################
     // Prepara os grupos da linha digitável ##
     // #######################################
     kGrupo01 := "033" + "9" + "9" + "8680" + "." + Alltrim(Str(modulo10("033998680")))
     kGrupo02 := "922" + Substr(xNossoNum,01,07) + "." + Alltrim(Str(modulo10("922" + Substr(xNossoNum,01,07))))
     kGrupo03 := Substr((xNossoNum + xDvNossoNum),08,06) + "0" + "101" + "." + Alltrim(Str(modulo10(Substr((xNossoNum + xDvNossoNum),08,06) + "0" + "101")))

     // ###################################################
     // Calcula o dígito verificador do código de Barras ##
     // ###################################################
     cFatorVencto  := Str(T_SE1->E1_VENCREA - Ctod("07/10/1997"),4)
     cValorNominal := STRZERO(INT((T_SE1->E1_VALOR + nCobraTaxa) * 100),10)
     kGrupo04      := Alltrim(Str(DigCodBarras("033" + "9" + cFatorVencto + cValorNominal + "9" + "8680922" + (xNossoNum + xDvNossoNum) + "0" + "101")))
     kGrupo05      := cFatorVencto + cValorNominal
     nLinhaDig     := kGrupo01 + " " + kGrupo02 + " " + kGrupo03 + " " + kGrupo04 + " " + kGrupo05
 
	 //						      Codigo Banco        Agencia	      C.Corrente     Digito C/C     Carteira
	 CB_RN_NN  := Ret_cBarra(Subs(aDadosBanco[1],1,3),aDadosBanco[3],aDadosBanco[4],aDadosBanco[5],aDadosBanco[6],_cNossoNum,( T_SE1->E1_VALOR - nAbatimento + nCobraTaxa) )

	 aDadosTit := {" " + AllTrim(T_SE1->E1_NUM) + " " + AllTrim(T_SE1->E1_PARCELA),;  // [1] Numero do titulo
	               T_SE1->E1_EMISSAO                                              ,;  // [2] Data da emissão do título
	               Date()                                  		                  ,;  // [3] Data da emissão do boleto
	               T_SE1->E1_VENCREA								              ,;  // [4] Data do vencimento
	              (T_SE1->E1_VALOR + nCobraTaxa)      			                  ,;  // [5] Valor do título
 	               CB_RN_NN[3]									                  ,;  // [6] Nosso número (Ver fórmula para calculo)
	               T_SE1->E1_PREFIXO                                              ,;  // [7] Prefixo da NF
	               T_SE1->E1_TIPO	                               	              ,;  // [8] Tipo do Titulo
	               T_SE1->E1_IRRF		                           	              ,;  // [9] IRRF
	               T_SE1->E1_ISS	                             	              ,;  // [10] ISS
	               T_SE1->E1_INSS 	                                              ,;  // [11] INSS
	               T_SE1->E1_PIS                                                  ,;  // [12] PIS
	               T_SE1->E1_COFINS                                               ,;  // [13] COFINS
	               T_SE1->E1_CSLL                               	              ,;  // [14] CSLL
	               _nVlrAbat                                                      ,;// [15] Abatimentos
                   T_SE1->E1_NUM                                                  ,;// [16] Nº do Título
                   T_SE1->E1_PARCELA                                              ,;// [17] Nº da Parcela
                   T_SE1->E1_FILORIG                                              ,;// [18] Filial de Origem
                   T_SE1->E1_MOEDA                                                ,;// [19] Moeda do Título
                   T_SE1->E1_CLIENTE                                              ,;// [20] Código do Cliente
                   T_SE1->E1_LOJA}                                                  // [21] Código da Loja

	 nVlAtraso := ((aDadosTit[5] * nTaxaDia )/100)
	 nVlMulta  := ((aDadosTit[5] * nTaxaMul  )/100)
	
     // #############
 	 // Instrucoes ##
 	 // #############
	 aBolText  := {	""     ,;	// [1]
  	                "  " +  ;
	                "  " +  ;
	                "  "   ,;   // [2]
	                "  " +  ;
	                "  "   ,;
	                xMensg1,; 	// [4]
                    xMensg2,; 	// [5]
         	        "",; 		// [6]
	                "",; 		// [7]
	                "",; 		// [8]
	                "" }		// [9]
	 aBMP := {}
	 Impress(oPrint,aBMP,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)
	 DbSelectArea("T_SE1")
	 lPrint := .T.
	 T_SE1->(DBSKIP())
  EndDo

  DbSelectArea("T_SE1")
  DbCloseArea()

  // ##############################
  // Visualiza antes de imprimir ##
  // ##############################
  If lPrint
   	 oPrint:Preview()
  EndIf  

Return()

// ##############################################################
// Função que impressão do boleto gráfico com código de barras ##
// ##############################################################

Static Function Impress(oPrint,aBitmap,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)

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

   // ##########################################################################################
   // Verifica se nota fiscal é referente a uma nota fiscal de serviço.                       ##
   // Se for serviço, imprime nas instruções a referência da nota fiscal de serviço com o RPS ##
   // Somente fará para notas fiscais com séries 11 - Porto alegre e 13 - Pelotas             ##
   // ##########################################################################################
   If Alltrim(aDadosTit[07]) == "11" .Or. Alltrim(aDadosTit[07]) == "13"

      If Select("T_SERVICO") > 0
         T_SERVICO->( dbCloseArea() )
      EndIf

      cSql := ""                      
      cSql := "SELECT A.F2_COND   ,"
      cSql += "       A.F2_NFELETR "
      cSql += "  FROM " + RetSqlName("SF2") + " A "
      cSql += " WHERE A.F2_DOC     = '" + Alltrim(aDadosTit[16]) + "'"
      cSql += "   AND A.F2_SERIE   = '" + Alltrim(aDadosTit[07]) + "'"
      cSql += "   AND A.F2_FILIAL  = '" + Alltrim(aDadosTit[18]) + "'"
      cSql += "   AND A.D_E_L_E_T_ = ''"
 
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERVICO", .T., .T. )

      If T_SERVICO->( EOF() )
         _NfRelacao := ""
      Else
         If Alltrim(aDadosTit[16]) == Alltrim(T_SERVICO->F2_NFELETR)
            _NfRelacao := ""         
         Else   
            _NfRelacao := IIF(Alltrim(T_SERVICO->F2_NFELETR) == "", "", "*** RPS Nº " + Alltrim(aDadosTit[16]) + " refere-se a NFs-e Nº " + Alltrim(T_SERVICO->F2_NFELETR))
         Endif
      Endif
   Else
      _NfRelacao := ""                    
   Endif

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
      aBolText[6] := IIF(T_PARAMETROS->ZZ4_DTAX == 0, "", IIF(cCobraTaxa == "S", "DESPESA BANCÁRIA DE R$ " + Alltrim(Str(T_PARAMETROS->ZZ4_DTAX,10,02)), ""))
      aBolText[7] := ""
      aBolText[8] := ""
      aBolText[9] := _NfRelacao
   Else
      aBolText[1] := IIF(T_PARAMETROS->ZZ4_DTAX == 0, "", IIF(cCobraTaxa == "S", "DESPESA BANCÁRIA DE R$ " + Alltrim(Str(T_PARAMETROS->ZZ4_DTAX,10,02)), ""))
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
	   oPrint:Say  (nLinha + 0230,0100,DTOC(aDadosTit[2])							,oFont09) // Emissao do Titulo (E1_EMISSAO)
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
  	   oPrint:Say  (nLinha + 0140,1910,Alltrim(xAgencia) + "/" + Alltrim(xConta),oFont09)
	
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
       nAbatimento := xSAbatimento()      

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
   // Elabota o código de barras para impressão ##
   // ############################################
   cCodigoBarras := "033" + "9" + kGrupo04 + cFatorVencto + cValorNominal + "9" + "8680922" + xNossoNum + xDvNossoNum + "0" + "101"

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
                                    
   nSoma01  := INT(VAL(Substr(kcNossoNum,01,01))) * 2
   nSoma02  := INT(VAL(Substr(kcNossoNum,02,01))) * 3
   nSoma03  := INT(VAL(Substr(kcNossoNum,03,01))) * 4
   nSoma04  := INT(VAL(Substr(kcNossoNum,04,01))) * 5
   nSoma05  := INT(VAL(Substr(kcNossoNum,05,01))) * 6                           
   nSoma06  := INT(VAL(Substr(kcNossoNum,06,01))) * 7
   nSoma07  := INT(VAL(Substr(kcNossoNum,07,01))) * 8
   nSoma08  := INT(VAL(Substr(kcNossoNum,08,01))) * 9
   nSoma09  := INT(VAL(Substr(kcNossoNum,09,01))) * 2
   nSoma10  := INT(VAL(Substr(kcNossoNum,10,01))) * 3                           
   nSoma11  := INT(VAL(Substr(kcNossoNum,11,01))) * 4
   nSoma12  := INT(VAL(Substr(kcNossoNum,12,01))) * 5                           

   nSomaTot := nSoma01 + nSoma02 + nSoma03 + nSoma04 + nSoma05 + nSoma06 + nSoma07 + nSoma08 + nSoma09 + nSoma10 + nSoma11 + nSoma12
   nSomaDig := 11 - Mod(nSomaTot,11)

   Do Case
      Case nSomaDig == 10
           nSomaDig := 1
      Case nSomaDig == 0
           nSomaDig := 0
      Case nSomaDig == 1
           nSomaDig := 0
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
  
Return(nSomaDiv)