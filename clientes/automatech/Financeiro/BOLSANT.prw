#INCLUDE "rwmake.Ch"
#INCLUDE "Protheus.Ch"
#include "ap5mail.ch"
#include "colors.ch"
#INCLUDE "jpeg.ch" 

//***********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                            *
// -------------------------------------------------------------------------------- *
// Referencia: BOLSANT.PRW                                                          *
// Parâmetros: Nenhum                                                               *
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                      *
// -------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                              *
// Data......: 27/04/2017                                                           *
// Objetivo..: Geração de boleto para o Banco Santander                             *
//***********************************************************************************

User Function BOLSANT(lBord, cNumNota, cNumSerie, cPorOnde)

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

      DEFINE MSDIALOG oDlg TITLE "Emissão Boleto Bancário - SANTANDER" FROM C(178),C(181) TO C(435),C(614) PIXEL

      @ C(004),C(002) Jpeg FILE "nlogoautoma.bmp" Size C(142),C(030) PIXEL NOBORDER OF oDlg
      @ C(041),C(003) Jpeg FILE "santander.bmp"   Size C(071),C(063) PIXEL NOBORDER OF oDlg
   
      @ C(036),C(002) GET oMemo1 Var cMemo1 MEMO Size C(209),C(001) PIXEL OF oDlg
      @ C(106),C(002) GET oMemo2 Var cMemo2 MEMO Size C(209),C(001) PIXEL OF oDlg

      @ C(043),C(076) Say "Informe dados abaixo para emissão de boletos" Size C(112),C(008) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(056),C(076) Say "Prefixo"                                      Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(070),C(076) Say "Do Título"                                    Size C(024),C(008) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(070),C(142) Say "Até o Título"                                 Size C(030),C(008) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(083),C(076) Say "Da Parcela"                                   Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
      @ C(083),C(140) Say "Até a Parcela"                                Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
   
      @ C(055),C(107) MsGet oGet1 Var cPrefixo Size C(016),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(068),C(107) MsGet oGet2 Var cNum01   Size C(030),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(068),C(179) MsGet oGet3 Var cNum02   Size C(030),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(082),C(107) MsGet oGet4 Var cPar01   Size C(014),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg
      @ C(082),C(179) MsGet oGet5 Var cPar02   Size C(014),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlg

      @ C(111),C(134) Button "Imprimir" Size C(037),C(012) PIXEL OF oDlg ACTION( CarregaMV() )
      @ C(111),C(173) Button "Voltar"   Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

      ACTIVATE MSDIALOG oDlg CENTERED 
      
   Endif

   // ##########################################
   //   //Se for geração de boleto pela NF.   ##
   //   If _lBord                             ##
   //      mv_par01 := cNumSerie              ##
   //      mv_par02 := cNumNota               ##
   //	   mv_par03 := cNumNota               ##
   //	   mv_par04 := ""                     ##
   //	   mv_par05 := "Z"                    ##
   //	   ImprimeDup()                       ##
   //   Else                                  ##
   //      cPerg	:= "BOLITAU   "           ##
   //	   ValidPerg()                        ##
   //	   cPerguntas := Pergunte(cPerg,.T.)  ##
   //	   If cPerguntas == .T.               ##
   //	   	 ImprimeDup()                     ##
   //	   Endif                              ##
   //   EndIf                                 ##
   // ##########################################

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
   
   Private aDadCli   := {}
   Private aDadTit   := {}
   Private aBarra    := {}

   Private aDadEmp   := {}
   Private aDadBco   := {}

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
   PRIVATE xMsg1      	:= ""
   PRIVATE xMsg2      	:= ""
   PRIVATE cCartNnDvDv	:= ""
   PRIVATE cCodCli    	:= ""
   PRIVATE xEmailTo   	:= ""
   Private cTabParc   	:= "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
   Private aAbatimento  := {}

   SM0->(DbSeek(cEmpAnt + cFilAnt))

//   aDadEmp  := {SM0->M0_NOMECOM,;	                                     // [1]Nome da Empresa
//                SM0->M0_ENDCOB,;						                 // [2]Endereço
//                AllTrim(SM0->M0_BAIRCOB) + ", " + ;
//                AllTrim(SM0->M0_CIDCOB)  + ", " + ;
//                SM0->M0_ESTCOB,;										 // [3]Complemento
//                "CEP: " + Transform(SM0->M0_CEPCOB,"@R 99.999-999"),; 	 // [4]CEP
//                "PABX/FAX: " + SM0->M0_TEL,; 							 // [5]Telefones
//                Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),; 		 // [6]CNPJ
//                "I.E.: " + Transform(SM0->M0_INSC,"@R 999/99999999999")} // [7]Insc Estadual

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
	
	  xMsg1       := "ATÉ O VENCIMENTO PAGUE PREFERENCIALMENTE NO ITAU"
	  xMsg2       := "APOS O VENCIMENTO PAGUE SOMENTE NO ITAU"
	
      Do Case
         // Grupo Empresa -> 01 - Porto Alegre/RS
         Case cEmpAnt == "01"
     	      xBanco 	  := "033"
	          xNomeBanco  := "BANCO SANTANDER"
	          xNumBanco   := "033"
	          xCartCob    := "109"
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
	
      // ##################################################
      // Envia para a função que carrega Empresa e banco ##
      // ##################################################
      TCDadBco(aDadEmp, aDadBco)
      
//	  aDadBco  := { xNumBanco        ,; // [1]Numero do Banco
//	                xNomeBanco       ,; // [2]Nome do Banco
//	                Alltrim(xAgencia),; // [3]Agência
//	                Alltrim(xConta)  ,;	// [4]Conta Corrente
//	                xDvConta         ,; // [5]Dígito da conta corrente
//	                xCartCob         ,; // [6]Codigo da Carteira
//	                xCodCedente } 		// [7]Codigo Cedente

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
	
	  //Se for da rotina chamada pela geração da NF, pega o nosso número do SEE.
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

//		 cQuery += "  WHERE EE_FILIAL  = '01' "
//		 cQuery += "    AND EE_CODIGO  = '341' "
//		 cQuery += "    AND EE_AGENCIA = '0296' "
//		 cQuery += "    AND EE_CONTA   = '890866' "
//		 cQuery += "    AND EE_SUBCTA  = '001' "
//		 cQuery += "    AND D_E_L_E_T_ <> '*' "

		 cQuery := ChangeQuery(cQuery)
		 dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'TEMPSEE',.T.,.T.)

		 DbSelectArea("TEMPSEE")
		 xNossoNum := TEMPSEE->EE_NUMBCO
		 DbSelectArea("TEMPSEE")
		 DbCloseArea()
		
		 // Caso não encontre, finaliza a operação.
		 If Empty(xNossoNum)
			MsgBox("Não foi possivel localizar o registro. Favor verificar!")
			Return()
		 EndIf

		 _cNossoNum := STRZERO(Val(xNossoNum),8)

         // Verifica se o nº capturado já existe na E1. Se existir, pesquisa  o próximo livre
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

			lBoleto := .t. //Caso o boleto seja gerado somento pelo financeiro.
			cQuery := {}
			cQuery := " SELECT EE_NUMBCO"
			cQuery += "   FROM "+ RETSQLNAME("SEE")
  		    cQuery += "  WHERE EE_FILIAL  = '" + Alltrim(kFilial)  + "'"
		    cQuery += "    AND EE_CODIGO  = '" + Alltrim(xBanco)   + "'"
		    cQuery += "    AND EE_AGENCIA = '" + Alltrim(xAgencia) + "'"
		    cQuery += "    AND EE_CONTA   = '" + Alltrim(xConta)   + "'"
		    cQuery += "    AND EE_SUBCTA  = '001' "
		    cQuery += "    AND D_E_L_E_T_ <> '*' "

//			cQuery += "  WHERE EE_FILIAL  = '01' "
//			cQuery += "    AND EE_CODIGO  = '341' "
//			cQuery += "    AND EE_AGENCIA = '0296' "
//			cQuery += "    AND EE_CONTA   = '890866' "
//			cQuery += "    AND EE_SUBCTA  = '001' "
//			cQuery += "    AND D_E_L_E_T_ <> '*' "

			cQuery := ChangeQuery(cQuery)
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),'TEMPSEE',.T.,.T.)

			DbSelectArea("TEMPSEE")
			xNossoNum := TEMPSEE->EE_NUMBCO
			DbSelectArea("TEMPSEE")
			DbCloseArea()
			
            // Verifica se o nº capturado já existe na E1. Se existir, pesquisa  o próximo livre
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

			//Caso esteja vazio o campo E1_NUMBCO, o título e a sequencia no SEE serão atualizados.
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
//   			  SEE->EE_NUMBCO := SOMA1(xNossoNum)
     			  SEE->EE_NUMBCO := SOMA1(Right(xNossoNum,6))
				  MsUnLock()
			   EndIf
				
			EndIf

 		 EndIf

		 _cNossoNum := xNossoNum

	  EndIf
	
 	  // Se for geração de boleto pela NF, atualiza o nosso número no título e parâmetro banco.
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
//				SEE->EE_NUMBCO := SOMA1(xNossoNum)
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

     // Calcula o valor do abatimento
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

     // #########################################################################
     // Linha digitável do boleto bancário ##                                  ##
     // #########################################################################
     // Codigo Banco         Agencia	C.Corrente     Digito C/C    Carteira  ##
     // #########################################################################
	 CB_RN_NN	:= Ret_cBarra(aDadBco[1],;
	                          aDadBco[3],;
	                          aDadBco[5],;
	                          aDadBco[6],;
	                          xCartCob  ,;
                              _cNossoNum,;
                             (T_SE1->E1_VALOR - nAbatimento + nCobraTaxa) )

     // ############################################ 
     // Gera a linha digitável do boleto bancário ##
     // ############################################

ccarteira := xCartCob
cNumDoc := '080108'

 	 aBarra	:= GetBarra(aDadBco[1], aDadBco[3], aDadBco[4], aDadBco[5], aDadBco[6],;
 	                    cCarteira     , cNumDoc       , (T_SE1->E1_VALOR - nAbatimento + nCobraTaxa)  ,;
 	                    T_SE1->E1_VENCREA, SEE->EE_CODEMP )

//	  aDadBco  := { xNumBanco        ,; // [1]Numero do Banco
//	                xNomeBanco       ,; // [2]Nome do Banco
//	                Alltrim(xAgencia),; // [3]Agência
//	                Alltrim(xConta)  ,;	// [4]Conta Corrente
//	                xDvConta         ,; // [5]Dígito da conta corrente
//	                xCartCob         ,; // [6]Codigo da Carteira
//	                xCodCedente } 		// [7]Codigo Cedente



	 // #########################################
	 // Alimenta array com os dados do cliente ##
	 // #########################################
	 aAdd( aDadCli,	SA1->A1_COD )
	 aAdd( aDadCli,	SA1->A1_LOJA)
	 aAdd( aDadCli,	SA1->A1_NOME)
	 aAdd( aDadCli,	SA1->A1_CGC)
	 aAdd( aDadCli,	SA1->A1_INSCR)
	 aAdd( aDadCli,	SA1->A1_PESSOA)

	 If !Empty(SA1->A1_ENDCOB)

		If !( "MESMO" $ UPPER( SA1->A1_ENDCOB ) )
		   aAdd( aDadCli, SA1->A1_ENDCOB)
		   aAdd( aDadCli, SA1->A1_BAIRROC)
		   aAdd( aDadCli, SA1->A1_MUNC)
		   aAdd( aDadCli, SA1->A1_ESTC)
		   aAdd( aDadCli, SA1->A1_CEPC)
		   aAdd( aDadCli, "")            //"CORREIO"
		Else
		   aAdd( aDadCli, SA1->A1_END)
		   aAdd( aDadCli, SA1->A1_BAIRRO)
		   aAdd( aDadCli, SA1->A1_MUN)
		   aAdd( aDadCli, SA1->A1_EST)
		   aAdd( aDadCli, SA1->A1_CEP)
		   aAdd( aDadCli, "")           //"CAMINHÃO"
		EndIf
	 Else
		aAdd( aDadCli, SA1->A1_END)
		aAdd( aDadCli, SA1->A1_BAIRRO)
		aAdd( aDadCli, SA1->A1_MUN)
		aAdd( aDadCli, SA1->A1_EST)
		aAdd( aDadCli, SA1->A1_CEP)
		aAdd( aDadCli, "")            //"CORREIO"
	 Endif

     // ###########################################################
     // Carrega Array com os dados a serem impressos dos títulos ##
     // ###########################################################
	 aDadTit 	:= {" " + AllTrim(T_SE1->E1_NUM) + " " + AllTrim(T_SE1->E1_PARCELA),;  // [1] Numero do titulo
	                T_SE1->E1_EMISSAO                              ,;                  // [2] Data da emissão do título
            	    Date()                                  	   ,;                  // [3] Data da emissão do boleto
	                T_SE1->E1_VENCREA							   ,;                  // [4] Data do vencimento
              	   (T_SE1->E1_VALOR + nCobraTaxa)      			   ,;                  // [5] Valor do título
	                CB_RN_NN[3]									   ,;                  // [6] Nosso número (Ver fórmula para calculo)
             	    T_SE1->E1_PREFIXO                              ,;                  // [7] Prefixo da NF
	                T_SE1->E1_TIPO	                               ,;                  // [8] Tipo do Titulo
	                T_SE1->E1_IRRF		                           ,;                  // [9] IRRF
           	        T_SE1->E1_ISS	                               ,;                  // [10] ISS
	                T_SE1->E1_INSS 	                               ,;                  // [11] INSS
	                T_SE1->E1_PIS                                  ,;                  // [12] PIS
	                T_SE1->E1_COFINS                               ,;                  // [13] COFINS
	                T_SE1->E1_CSLL                                 ,;                  // [14] CSLL
	                _nVlrAbat                                      ,;	       		   // [15] Abatimentos
                    T_SE1->E1_NUM                                  ,;                  // [16] Nº do Título
                    T_SE1->E1_PARCELA                              ,;                  // [17] Nº da Parcela
                    T_SE1->E1_FILORIG                              ,;                  // [18] Filial de Origem
                    T_SE1->E1_MOEDA                                ,;                  // [19] Moeda do Título
                    T_SE1->E1_CLIENTE                              ,;                  // [20] Código do Cliente
                    T_SE1->E1_LOJA}                                                    // [21] Código da Loja

	 nVlAtraso := ((aDadTit[5] * nTaxaDia )/100)
	 nVlMulta  := ((aDadTit[5] * nTaxaMul  )/100)
	
 	 //Instrucoes
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
  // Impress(oPrint,aBMP,aDadosEmp,aDadosTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)

	 ImpressBol(oPrint,aDadEmp,aDadBco,aDadTit,aDadCli,aBarra,1)

	 DbSelectArea("T_SE1")
	 lPrint := .T.
	 T_SE1->(DBSKIP())
  EndDo

  DbSelectArea("T_SE1")
  DbCloseArea()

  If lPrint
   	 oPrint:Preview()     // Visualiza antes de imprimir
  EndIf  

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Impress   ºAutor  ³Microsiga           º Data ³  05/13/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Impressão do boleto gráfico com código de barras            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Impress(oPrint,aBitmap,aDadosEmp,aDadTit,aDadosBanco,aDatSacado,aBolText,CB_RN_NN)

   Local cSql := ""

   //Parâmetros de TFont.New()
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

   // Verifica se nota fiscal é referente a uma nota fiscal de serviço.
   // Se for serviço, imprime nas instruções a referência da nota fiscal de serviço com o RPS
   // Somente fará para notas fiscais com séries 11 - Porto alegre e 13 - Pelotas
   If Alltrim(aDadTit[07]) == "11" .Or. Alltrim(aDadTit[07]) == "13"

      If Select("T_SERVICO") > 0
         T_SERVICO->( dbCloseArea() )
      EndIf

      cSql := ""                      
      cSql := "SELECT A.F2_COND   ,"
      cSql += "       A.F2_NFELETR "
      cSql += "  FROM " + RetSqlName("SF2") + " A "
      cSql += " WHERE A.F2_DOC     = '" + Alltrim(aDadTit[16]) + "'"
      cSql += "   AND A.F2_SERIE   = '" + Alltrim(aDadTit[07]) + "'"
      cSql += "   AND A.F2_FILIAL  = '" + Alltrim(aDadTit[18]) + "'"
      cSql += "   AND A.D_E_L_E_T_ = ''"
 
      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERVICO", .T., .T. )

      If T_SERVICO->( EOF() )
         _NfRelacao := ""
      Else
         If Alltrim(aDadTit[16]) == Alltrim(T_SERVICO->F2_NFELETR)
            _NfRelacao := ""         
         Else   
            _NfRelacao := IIF(Alltrim(T_SERVICO->F2_NFELETR) == "", "", "*** RPS Nº " + Alltrim(aDadTit[16]) + " refere-se a NFs-e Nº " + Alltrim(T_SERVICO->F2_NFELETR))
         Endif
      Endif
   Else
      _NfRelacao := ""                    
   Endif

   // ###############################################################
   // Pesquisa se vai ser acrescido o valor da taxa Administrativa ##
   // ###############################################################
   cCobraTaxa :=  Posicione("SA1",1,xFilial("SA1") + aDadTit[20] + aDadTit[21], "A1_COBTAX")

   // Pesquisa no parametrizador Automatech as instruções a serem impressas
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

   oPrint:StartPage()   // Inicia uma nova página

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
	
	   oPrint:Say  (nLinha + 0000,0100,"Local Pagamento"							,oFont8c)
	   oPrint:Say  (nLinha + 0020,0400,xMsg1										,oFont8a)
	   oPrint:Say  (nLinha + 0060,0400,xMsg2										,oFont8a)
	   oPrint:Say  (nLinha + 0000,1910,"Vencimento"									,oFont6)
	
	   oPrint:Say  (nLinha + 0040,2010,PadL(DTOC(aDadTit[4]),20)                  ,oFont8a)
	
	   oPrint:Say  (nLinha + 0100,0100,"Cedente"									,oFont6)
	   oPrint:Say  (nLinha + 0100,1355,"CNPJ"										,oFont6)
	   oPrint:Say  (nLinha + 0100,1910,"Agência/Código Cedente"						,oFont6)
	   oPrint:Say  (nLinha + 0200,0100,"Data do Documento"							,oFont6)
	   oPrint:Say  (nLinha + 0230,0100,DTOC(aDadTit[2])							,oFont8a) // Emissao do Titulo (E1_EMISSAO)
	   oPrint:Say  (nLinha + 0200,0505,"Nro.Documento"								,oFont6)
	   oPrint:Say  (nLinha + 0230,0605,aDadTit[7]+aDadTit[1]					,oFont8a) //Prefixo +Numero+Parcela
	   oPrint:Say  (nLinha + 0200,1005,"Espécie Doc."								,oFont6)
	   oPrint:Say  (nLinha + 0230,1050,"DM"											,oFont8a) //Tipo do Titulo
	   oPrint:Say  (nLinha + 0200,1355,"Aceite"										,oFont6)
	   oPrint:Say  (nLinha + 0230,1455,"N"											,oFont8a)
	   oPrint:Say  (nLinha + 0200,1555,"Data do Processamento"						,oFont6)
	   oPrint:Say  (nLinha + 0230,1655,DTOC(aDadTit[3])							,oFont8a) // Data impressao
	   oPrint:Say  (nLinha + 0200,1910,"Nosso Número"								,oFont6)

	   oPrint:Say  (nLinha + 0230,2010,PadL(xCartCob + "/" + STRZERO(Val(xNossoNum),8) + "-" + xDvNossoNum,20),oFont8a)
	
       Do Case
          Case cEmpAnt == "02"
     	       oPrint:Say  (nLinha + 0140,2010,PadL(xAgencia + "/" + Substr(xConta,1,5) + "-" + Alltrim(xDVConta),22),oFont8a)
          Otherwise
     	       oPrint:Say  (nLinha + 0140,2010,PadL(xAgencia + "/" + Substr(xConta,1,5) + "-" + Substr(xConta,6,1),22),oFont8a)
       EndCase	       
	
	   oPrint:Say  (nLinha + 0140,0100,aDadosEmp[1]              						,oFont8a) //Nome
	   oPrint:Say  (nLinha + 0140,1380,aDadosEmp[6]              						,oFont8a) //CNPJ
	
	   oPrint:Say  (nLinha + 0270,0100,"Uso do Banco"									,oFont6)
	   oPrint:Say  (nLinha + 0270,0505,"Carteira"										,oFont6)
	   oPrint:Say  (nLinha + 0300,0555,aDadosBanco[6]									,oFont8a)
	   oPrint:Say  (nLinha + 0270,0755,"Espécie"										,oFont6)
	   oPrint:Say  (nLinha + 0300,0805,"R$"											,oFont8a)
	   oPrint:Say  (nLinha + 0270,1005,"Quantidade"									,oFont6)
	   oPrint:Say  (nLinha + 0270,1555,"Valor"										,oFont6)
	   oPrint:Say  (nLinha + 0270,1910,"Valor do Documento"							,oFont6)

       // Calcula o valor do abatimento a ser descontado do valor total para impressão do boleto em caso de nota fiscal de serviço
       nAbatimento := 0
       nAbatimento := xSAbatimento()      

       If Alltrim(aDadTit[07]) == "11" .Or. Alltrim(aDadTit[07]) == "13"
          If nAbatimento < 10
             nAbatimento := 0
          Endif
       Endif

       // Notas Fiscal de Serviço Eletrônica de Porto Alegre/RS
       Do Case
          Case Alltrim(aDadTit[07]) == "11"
//     	       oPrint:Say  (nLinha + 0300,2010,Padl(AllTrim(Transform((aDadosTit[5] - (aDadosTit[12] + aDadosTit[13] + aDadosTit[14] + aDadosTit[15])) ,"@E 999,999,999.99")),20),oFont8a)      
     	       oPrint:Say  (nLinha + 0300,2010,Padl(AllTrim(Transform((aDadTit[5] - (aDadTit[15])) ,"@E 999,999,999.99")),20),oFont8a)      
          Case Alltrim(aDadTit[07]) == "13"
//     	       oPrint:Say  (nLinha + 0300,2010,Padl(AllTrim(Transform((aDadosTit[5] - (aDadosTit[12] + aDadosTit[13] + aDadosTit[14] + aDadosTit[15])) ,"@E 999,999,999.99")),20),oFont8a)      
     	       oPrint:Say  (nLinha + 0300,2010,Padl(AllTrim(Transform((aDadTit[5] - (aDadTit[15])) ,"@E 999,999,999.99")),20),oFont8a)      
          Otherwise
               If nAbatimento == 0                               
       	          oPrint:Say  (nLinha + 0300,2010,Padl(AllTrim(Transform(aDadTit[5],"@E 999,999,999.99")),20),oFont8a)      
   	           Else   
   	              oPrint:Say  (nLinha + 0300,2010,Padl(AllTrim(Transform((aDadTit[5] - nAbatimento),"@E 999,999,999.99")),20),oFont8a)
   	           Endif   
   	   EndCase        

	   oPrint:Say  (nLinha + 0340,0100,"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do cedente)",oFont6)
	   oPrint:Say  (nLinha + 0390,0100,aBolText[1]										,oFont8a)
	   oPrint:Say  (nLinha + 0440,0100,aBolText[2]										,oFont8a)
	   oPrint:Say  (nLinha + 0490,0100,aBolText[3]										,oFont8a)
	   oPrint:Say  (nLinha + 0540,0100,aBolText[4]										,oFont8a)
	   oPrint:Say  (nLinha + 0590,0100,aBolText[5]										,oFont8a)

	   oPrint:Say  (nLinha + 0640,0100,aBolText[6]										,oFont8a)
//	   oPrint:Say  (nLinha + 0540,0100,aBolText[7]										,oFont8a)
//	   oPrint:Say  (nLinha + 0590,0100,aBolText[8]										,oFont8a)
//	   oPrint:Say  (nLinha + 0640,0100,aBolText[9]										,oFont16n)
	
	   oPrint:Say  (nLinha + 0340,1910,"(-)Desconto/Abatimento"						,oFont6)

       // Este teste abaixo foi retirado temporariamente.
       // Este bloqueio foi autorizado pela Controladoria no dia 20/08/2014 em função de estarem fechando a regra do abatimento
	   //If aDadTit[15] > 0
	   //   oPrint:Say  (nLinha + 0270,2010,AllTrim(Transform(aDadTit[15],"@E 999,999,999.99")),oFont8a)
	   //Endif

	   oPrint:Say  (nLinha + 0410,1910,"(-)Outras Deduções"							,oFont6)
	   oPrint:Say  (nLinha + 0480,1910,"(+)Mora/Multa"								,oFont6)
	   oPrint:Say  (nLinha + 0550,1910,"(+)Outros Acréscimos"						,oFont6)
	   oPrint:Say  (nLinha + 0620,1910,"(=)Valor Cobrado"							,oFont6)
	
	   oPrint:Say  (nLinha + 0690,0100,"Sacado"										,oFont6)
	   oPrint:Say  (nLinha + 0700,0300,aDatSacado[1]+" ("+aDatSacado[2]+") - " + TRANSFORM(aDatSacado[7],"@R 99.999.999/9999-99") ,oFont8a)
	   oPrint:Say  (nLinha + 0735,0300,aDatSacado[3]								,oFont8a)
	   oPrint:Say  (nLinha + 0770,0300,Transform(aDatSacado[6],"@R 99.999-999")+"    "+aDatSacado[4]+" - "+aDatSacado[5],oFont8a) // CEP+Cidade+Estado
	
	   oPrint:Say  (nLinha + 0818,0100,"Sacador/Avalista"							,oFont6)
	
	   oPrint:Line (nLinha + 0000,1900,nLinha + 0690,1900)
	   oPrint:Line (nLinha + 0410,1900,nLinha + 0410,2300)
	
	   oPrint:Line (nLinha + 0480,1900,nLinha + 0480,2300)
	   oPrint:Line (nLinha + 0550,1900,nLinha + 0550,2300)
	   oPrint:Line (nLinha + 0620,1900,nLinha + 0620,2300)
	
	   oPrint:Line (nLinha + 0690,0100,nLinha + 0690,2300)
	   oPrint:Line (nLinha + 0840,0100,nLinha + 0840,2300)
	
	   If nInd = 1
		  oPrint:Say  (nLinha - 0070,2000,"Recibo do Sacado",oFont10)
		  oPrint:Say  (nLinha + 0850,1500,"Autenticação Mecânica",oFont8a)
		  nLinha += 1065
   	   ElseIf nInd = 2
		  oPrint:Say  (nLinha - 0140,0100,"#",oFontW)
		  For i := 100 to 2300 step 10
			  oPrint:Line( nLinha - 0100, i, nLinha - 0100, i+5)
		  Next i
		  oPrint:Say  (nLinha - 0066,0820,CB_RN_NN[2],oFont16n)	// Linha Digitavel do Codigo de Barras
		  oPrint:Say  (nLinha + 0850,1500,"Autenticação Mecânica - Ficha de Compensação",oFont8a)
	   EndIf
	
   Next

   MSBAR3("INT25",18.4,0.8,CB_RN_NN[1],oPrint,.F.,,,,1.5,,,,.F.)

   oPrint:EndPage() // Finaliza a página

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Modulo10  ºAutor  ³Microsiga           º Data ³  05/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Mod11CB   ºAutor  ³Microsiga           º Data ³  05/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Modulo 11 CB                                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Ret_cBarraºAutor  ³Microsiga           º Data ³  05/12/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Retorna Linha Digitavel, Linha Codigo Barras e Nosso Numero º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
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

   //Calculo do Fator de Vencimento do Titulo
   cFatorVencto := Str(T_SE1->E1_VENCREA - dDtBase,4)

   // - Montagem do Nosso Numero
   snn  := cAgencia + SubStr(cConta,1,5) + cCarteira + bldocnufinal     // Agencia + Conta + Carteira + Nosso Numero
   dvnn := modulo10(snn)    // Digito verificador no Nosso Numero
   NN   := cCarteira + BlDocNuFinal + AllTrim(Str(dvnn))
   xDvNossoNum := AllTrim(Str(dvnn))

   // - MONTAGEM DOS DADOS PARA O CODIGO DE BARRAS
   scb  := cBanco + "9" + cFatorVencto + blvalorfinal + NN + cAgencia + cConta + cDacCC + "000"
   dvcb := mod11CB(scb)	//digito verificador do codigo de barras
   CB   := SubStr(scb,1,4) + AllTrim(Str(dvcb)) + SubStr(scb,5,39)

   // - Montagem da Linha Digitavel
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

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ValidPerg ºAutor  ³Mauro JPC           º Data ³  03/05/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao das perguntas.                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Protheus11                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
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

// ---------------------------------------------------------------------------------------------------- //
// Função que calcula o valor da retenção de imposto verificando o cadastro dos produtos da nota fiscal //
// Regra para cálculo das retenções de PIS, COFINS e CSLL                                               //
// Esta regra foi definina no dia 28/10/2015 juntamente com Paulo, Adriana e Harald                     //
// Caso o Cliente tiver em seu cadastro congigurado o PIS = S ou COFINS = S ou CSLL = S, indica que   o //
// cliente terá cálculo de retenção de Impostos.                                                        //
// Caso  o  produto  da  nota estiver consigurado com PIS = S ou COFINS = S ou CSLL = S, sistema deverá //
// calcular a retenção de impostos.                                                                     //
// ---------------------------------------------------------------------------------------------------- //
Static Function SAbatimento()

   Local cSql       := ""
   Local nVlrPIS    := 0
   Local nVlrCofins := 0
   Local nVlrCSLL   := 0
   Local nVlrIRRF   := 0
   Local nVlrINSS   := 0   
   Local aRetencao  := {}

   // Verifica se o cliente da nota fiscal está parametrizado para cálcular retenção de imposto
   If Posicione("SA1",1,xFilial("SA1") + T_SE1->E1_CLIENTE + T_SE1->E1_LOJA,"A1_RECPIS")  == "S" .Or. ;
      Posicione("SA1",1,xFilial("SA1") + T_SE1->E1_CLIENTE + T_SE1->E1_LOJA,"A1_RECCSLL") == "S" .Or. ;   
      Posicione("SA1",1,xFilial("SA1") + T_SE1->E1_CLIENTE + T_SE1->E1_LOJA,"A1_RECCOFI") == "S"

      // Dados da NF
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
 
         // PIS
         If T_ABATIMENTO->B1_PIS == "1"
            nVlrPIS := nVlrPIS + T_ABATIMENTO->D2_VALPIS
            aRetencao[01,01] := nVlrPIS
         Endif   

         // COFINS
         If T_ABATIMENTO->B1_COFINS == "1"
            nVlrCofins := nVlrCofins + T_ABATIMENTO->D2_VALCOF
            aRetencao[01,02] := nVlrCofins
         Endif   

         // CSLL
         If T_ABATIMENTO->B1_CSLL == "1"
            nVlrCSLL := nVlrCSLL + T_ABATIMENTO->D2_VALCSL
            aRetencao[01,03] := nVlrCSLL
         Endif   

         // IRRF
         If T_ABATIMENTO->B1_IRRF == "S"
            nVlrIRRF := nVlrIRRF + T_ABATIMENTO->D2_VALIRRF
            aRetencao[01,04] := nVlrIRRF
         Endif   

         // INSS
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

// #################################################
// Função que imprime o boleto do Banco Santander ##
// #################################################
//User Function ImpressBol(oPrint,aDadEmp,aDadosBanco,aDadTit,aDadCli,aBarra,nTpImp)
Static Function ImpressBol(oPrint,aDadEmp,aDadosBanco,aDadTit,aDadCli,aBarra,nTpImp)
   Local oFont8
   Local oFont10
   Local oFont11c
   Local oFont14
   Local oFont14n
   Local oFont15
   Local oFont15n
   Local oFont16n
   Local oFont20
   Local oFont21
   Local oFont24
   Local nLin		:= 0
   Local nLoop		:= 0
   Local cBmp		:= ""
   Local cStartPath	:= AllTrim(GetSrvProfString("StartPath",""))

   // ##################################################################################
   // Parametro que verifica se o Banco será o Cedente do Titulo, através dos campos  ##
   // Cod. Banco, Agência e Número de conta, que devem ser informados sequencialmente ##
   // no parametro.                                                                   ##
   // ##################################################################################
   Local cCedente  := ''//IF(ValType(GetMv("MC_BCEDEN")) <> "C","",ALLTRIM(GetMv("MC_BCEDEN")))   
   Local cAvalista := ""

   // #############################################################################
   // Posiciona no registro do contas a receber a ser impresso o boleto bancário ##
   // #############################################################################
//   SE1->(dbSetOrder(1), dbSeek(xFilial("SE1") + aDadTit[7] + Substr(Alltrim(aDadTit[1]),01,06) + "   " + Substr(Alltrim(aDadTit[1]),08,02) + aDadTit[8]))

   DbSelectArea("SE1")
   DbSetOrder(1)
   DbSeek(xFilial("SE1") + aDadTit[7] + Substr(Alltrim(aDadTit[1]),01,06) + "   " + Substr(Alltrim(aDadTit[1]),08,02) + aDadTit[8])

   SA1->(dbSetOrder(1), dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))

   Private cFilename := 'BOL'+AllTrim(SE1->E1_NUM)+AllTrim(E1_PARCELA)	//Criatrab(Nil,.F.)

   MAKEDIR('C:\TEMP')
   lAdjustToLegacy := .T.   //.F.
   lDisableSetup   := .T.

   oPrint:=TMSPrinter():New( "Boleto Bancario" )
   oPrint:SetPortrait()

//   oPrint          := FWMSPrinter():New(cFilename, "", lAdjustToLegacy, , lDisableSetup)
//   oPrint:Setup()
//   oPrint:SetResolution(78)
//   //oPrint:SetPortrait() // ou SetLandscape()
//   oPrint:SetLandscape()
//   oPrint:SetPaperSize(DMPAPER_A4) 
//   oPrint:SetMargin(10,10,10,10) // nEsquerda, nSuperior, nDireita, nInferior 
//   oPrint:cPathPDF := "C:\TEMP\" // Caso seja utilizada impressão em IMP_PDF 
//   cDiretorio      := oPrint:cPathPDF

   If ALLTRIM( SA6->A6_COD + alltrim(SA6->A6_AGENCIA) + SA6->A6_NUMCON ) $ cCedente
	  cAvalista := SM0->M0_NOMECOM
   Endif

   If Right(cStartPath,1) <> "\"
	  cStartPath+= "\"
   EndIf

   // ##################################################
   // Monta string com o caminho do logotipo do banco ##
   // O Tamanho da figura tem que ser 381 x 68 pixel  ##
   // para que a impressãi sai correta                ##
   // ##################################################
   cBmp	:= cStartPath+'santander.bmp' //aDadBco[9]

   // ######################################
   // Define as fontes a serem utilizadas ##
   // ######################################
   oFont8	:= TFont():New("Arial",			9,08,.T.,.F.,5,.T.,5,.T.,.F.)
   oFont10	:= TFont():New("Arial",			9,10,.T.,.T.,5,.T.,5,.T.,.F.)
   oFont11c	:= TFont():New("Courier New",	9,11,.T.,.T.,5,.T.,5,.T.,.F.)
   oFont14	:= TFont():New("Arial",			9,14,.T.,.T.,5,.T.,5,.T.,.F.)
   oFont14n	:= TFont():New("Arial",			9,14,.T.,.F.,5,.T.,5,.T.,.F.)
   oFont15	:= TFont():New("Arial",			9,15,.T.,.T.,5,.T.,5,.T.,.F.)
   oFont15n	:= TFont():New("Arial",			9,15,.T.,.F.,5,.T.,5,.T.,.F.)
   oFont16n	:= TFont():New("Arial",			9,16,.T.,.F.,5,.T.,5,.T.,.F.)
   oFont20	:= TFont():New("Arial",			9,20,.T.,.T.,5,.T.,5,.T.,.F.)
   oFont21	:= TFont():New("Arial",			9,21,.T.,.T.,5,.T.,5,.T.,.F.)
   oFont24	:= TFont():New("Arial",			9,24,.T.,.T.,5,.T.,5,.T.,.F.)

   // #########################
   // Inicia uma nova página ##
   // #########################
   oPrint:StartPage()

   nLin := nLin - 620

   // ############################################
   // Define o Segundo Bloco - Recibo do Sacado ##
   // ############################################
   oPrint:Line (nLin+0690,0100,nLin+0690,2300)														// Quadro
   oPrint:Line (nLin+0690,0500,nLin+0610,0500)														// Quadro
   oPrint:Line (nLin+0690,0710,nLin+0610,0710)														// Quadro

   //If !Empty(aDadBco[9])
  
     oPrint:SayBitMap(nLin+0624,0100,cBmp,350,060)													// Logotipo do Banco

//   oPrint:SayBitMap(nLin+0624,0100,"santander.bmp",350,060)													// Logotipo do Banco

   //Else
   //	oPrint:Say  (nLin+0644,0100,	aDadBco[8],											oFont14)	// Nome do Banco
   //EndIf

   // ##############
   // Nº do Banco ##
   // ##############
   oPrint:Say  (nLin+0625,0513,	aDadosBanco[1] + "-" + aDadosBanco[2], oFont16n)

   //oPrint:Say  (nLin+0644,0755,	aBarra[2],												oFont15n)	// Linha Digitavel do Codigo de Barras

   // ####################
   // Recibo do Pagador ##
   // ####################
   oPrint:Say  (nLin+0634,1900,	"Recibo do Pagador", oFont10)

   // ##########################################
   // Imprime os quadrados do boleto bancário ##
   // ##########################################
   oPrint:Line (nLin+0790,0100,nLin+0790,2300)														// Quadro
   oPrint:Line (nLin+0890,0100,nLin+0890,2300)														// Quadro
   oPrint:Line (nLin+0960,0100,nLin+0960,2300)														// Quadro
   oPrint:Line (nLin+1030,0100,nLin+1030,2300)														// Quadro

   oPrint:Line (nLin+0890,0500,nLin+1030,0500)														// Quadro
   oPrint:Line (nLin+0960,0750,nLin+1030,0750)														// Quadro
   oPrint:Line (nLin+0890,1000,nLin+1030,1000)														// Quadro
   oPrint:Line (nLin+0890,1300,nLin+0960,1300)														// Quadro
   oPrint:Line (nLin+0890,1480,nLin+1030,1480)														// Quadro

   // #####################
   // Local de Pagamento ##
   // #####################
   oPrint:Say  (nLin+0710,0100,	"Local de Pagamento", oFont8)

   If Alltrim(SA6->A6_COD) == "001"
	  oPrint:Say  (nLin+0725,0400 ,	"Pagável em qualquer banco até o vencimento.", oFont10)
   Else																		
	  oPrint:Say  (nLin+0725,0400 ,	"ATÉ O VENCIMENTO, PREFERENCIALMENTE NO " + Upper(aDadosBanco[8]), oFont10)
  	  oPrint:Say  (nLin+0765,0400 ,	"APÓS O VENCIMENTO, SOMENTE NO "+Upper(aDadosBanco[8]), oFont10)
   EndIf																			 			

   // #######################
   // Vencimengo do Título ##
   // #######################
   oPrint:Say  (nLin+0710,1810,	"Vencimento", oFont8)
   oPrint:Say  (nLin+0750,2000,	StrZero(Day(aDadTit[4]),2) + "/" + StrZero(Month(aDadTit[4]),2) + "/" + StrZero(Year(aDadTit[4]),4), oFont11c)

   // ###############
   // Beneficiário ##
   // ###############
   oPrint:Say  (nLin+0810,0100,	"Beneficiário", oFont8)
   oPrint:Say  (nLin+0850,0100,	AllTrim(aDadEmp[1])+If(!Empty(cAvalista),""," - CNPJ: " + Transform(aDadEmp[9], "@R 99.999.999/9999-99")), oFont10)

   // ##############################
   // Agência/Código Beneficiário ##
   // ##############################
   oPrint:Say  (nLin+0810,1810,	"Agência/Código Beneficiário", oFont8)
   oPrint:Say  (nLin+0850,1900,	AllTrim(aDadosBanco[15]), oFont11c)

   // ####################
   // Data do Documento ##
   // ####################
   oPrint:Say  (nLin+0910,0100,	"Data do Documento", oFont8)
   oPrint:Say  (nLin+0940,0150,	StrZero(Day(aDadTit[2]),2) +"/" + StrZero(Month(aDadTit[2]),2) + "/" + Right(Str(Year(aDadTit[2])),4), oFont10)

   // ######################
   // Número do Documento ##
   // ######################
   oPrint:Say  (nLin+0910,0505,	"Nro.Documento", oFont8)
   oPrint:Say  (nLin+0940,0605,	aDadTit[16] + "/" + aDadTit[17], oFont10)

   // ####################
   // Espécie Documento ##
   // ####################
   oPrint:Say  (nLin+0910,1005,	"Espécie Doc.", oFont8)
   oPrint:Say  (nLin+0940,1055,	aDadBco[14], oFont10)

   // #########
   // Aceite ##
   // #########
   oPrint:Say  (nLin+0910,1305,	"Aceite", oFont8)
   oPrint:Say  (nLin+0940,1400,	"N", oFont10)

   // ########################
   // Data do Processamento ##
   // ########################
   oPrint:Say  (nLin+0910,1485,	"Data do Processamento", oFont8)
   oPrint:Say  (nLin+0940,1550,	StrZero(Day(dDataBase),2) + "/" + StrZero(Month(dDataBase),2) + "/" + StrZero(Year(dDataBase),4), oFont10)

   // ###############
   // Nosso Número ##
   // ###############
   oPrint:Say  (nLin+0910,1810,	"Nosso Número", oFont8)
  
   //If Alltrim(SA6->A6_COD)$ "033"
   //	oPrint:Say  (nLin+0940,1900, SubStr(aBarra[4],5,9), oFont11c)
   //Else	
   oPrint:Say  (nLin+0940,1900,	aBarra[4], oFont11c)
   //EndIf 

   // ###############
   // Uso do Banco ##
   // ###############
   oPrint:Say  (nLin+0980,0100,	"Uso do Banco", oFont8)
   oPrint:Say  (nLin+1010,0150,	aDadBco[13], oFont10)

   // ###########
   // Carteira ##
   // ###########
   oPrint:Say  (nLin+0980,0505,	"Carteira", oFont8)

   If Alltrim(SA6->A6_COD)$ "033"
      oPrint:Say  (nLin+1010,0555,	"109" + " - RCR",	oFont10)
   Else	
      oPrint:Say  (nLin+1010,0555,	aDadTit[10], oFont10)
   EndIf	

   // ##########
   // Espécie ##
   // ##########
   oPrint:Say  (nLin+0980,0755,	"Espécie", oFont8)
   oPrint:Say  (nLin+1010,0805,	"R$", oFont10)

   // ############
   // Quanidade ##
   // ############
   oPrint:Say  (nLin+0980,1005,	"Quantidade", oFont8)
   oPrint:Say  (nLin+0980,1485,	"Valor", oFont8)

   // #####################
   // Valor do Documento ##
   // #####################
   oPrint:Say  (nLin+0980,1810,	"Valor do Documento", oFont8)
   oPrint:Say  (nLin+1010,1900,	Transform(aDadTit[5],"@E 9999,999,999.99"), oFont11c)
   
   // #############
   // Instruções ##
   // #############
   oPrint:Say  (nLin+1050,0100,	"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do beneficiário)", oFont8)
   oPrint:Say  (nLin+1100,0100,	"Juros / Mora por dia : 0,33%,  R$ " +  alltrim(Transform((0.0033*aDadTit[5]),"@E 9999,999,999.99")) + " ao dia ", oFont10)
   oPrint:Say  (nLin+1150,0100,	"Protesto Automático após 5 dias de atraso", oFont10)
   oPrint:Say  (nLin+1200,0100,	"Depósito em conta não quita o boleto.", oFont10)
   oPrint:Say  (nLin+1250,0100,	"Dúvidas: envie e-mail para contasareceber@vitasons.com.br", oFont10)
   //oPrint:Say  (nLin+1300,0100, aDadTit[15], oFont10)
   //oPrint:Say  (nLin+1350,0100, aDadTit[16], oFont10)

   // ######################
   // Títulos dos Quadros ##
   // ######################
   oPrint:Say  (nLin+1050,1810,	"(-)Desconto/Abatimento", oFont8)
   oPrint:Say  (nLin+1120,1810,	"(-)Outras Deduções"    , oFont8)
   oPrint:Say  (nLin+1190,1810,	"(+)Mora/Multa"         , oFont8)
   oPrint:Say  (nLin+1260,1810,	"(+)Outros Acréscimos"  , oFont8)
   oPrint:Say  (nLin+1330,1810,	"(=)Valor Cobrado"      , oFont8)

   // ##########
   // Pagador ##
   // ##########
   oPrint:Say  (nLin+1400,0100,	"Pagador", oFont8)
   oPrint:Say  (nLin+1430,0200,	aDadCli[3], oFont10)
   //oPrint:Say  (nLin+1430,0200,	" ("+aDaDCli[1]+"-"+aDadCli[2]+") "+aDadCli[3],		oFont10)	// Código + Nome do Cliente

   // #############
   // CNPJ / CPF ##
   // #############
   If aDadCli[6] = "J"
	  oPrint:Say  (nLin+1430,1850,"CNPJ: "+Transform(aDadCli[4],"@R 99.999.999/9999-99"), oFont10)
   Else
	  oPrint:Say  (nLin+1430,1850,"CPF: "+Transform(aDadCli[4],"@R 999.999.999-99"), oFont10)
   EndIf

   // ###########
   // Endereço ##
   // ###########
   oPrint:Say  (nLin+1483,0200,	AllTrim(aDadCli[7])+" "+AllTrim(aDadCli[8]), oFont10)	// Endereço + Bairro
   //oPrint:Say	(nLin+1483,1850,	"Entrega: "+aDadCli[12],								oFont10)	// Forma de Envio do Boleto
   oPrint:Say  (nLin+1536,0200,	Transform(aDadCli[11],"@R 99999-999") + " - " + AllTrim(aDadCli[9]) + " - " + AllTrim(aDadCli[10]), oFont10) // CEP + Cidade + Estado
   oPrint:Say  (nLin+1589,1850,	aBarra[4], oFont10)	// Nosso Número

   // ###########################################
   // Pagador/Avalista - Autenticação Mecânica ##
   // ###########################################
   oPrint:Say  (nLin+1605,0100,	"Pagador/Avalista"+ if( !empty(cAvalista)," - " + Rtrim(cAvalista),""), oFont8)
   oPrint:Say  (nLin+1645,1500,	"Autenticação Mecânica", oFont8)

   // #############################
   // Quadros do Boleto Bancário ##
   // #############################
   oPrint:Line (nLin+0690,1800,nLin+1380,1800)
   oPrint:Line (nLin+1100,1800,nLin+1100,2300)
   oPrint:Line (nLin+1170,1800,nLin+1170,2300)
   oPrint:Line (nLin+1240,1800,nLin+1240,2300)
   oPrint:Line (nLin+1310,1800,nLin+1310,2300)
   oPrint:Line (nLin+1380,0100,nLin+1380,2300)
   oPrint:Line (nLin+1620,0100,nLin+1620,2300)

   // #######################
   // Pontilhado separador ##
   // #######################
   //nLin	:= 100
   nLin	:= 010

   nLin:= nLin - 740

   For nLoop := 100 To 2300 Step 50
	   oPrint:Line(nLin+1860, nLoop, nLin+1860, nLoop+30) // Linha Pontilhada
   Next nI
                 
   // #################################################
   // Define o Terceiro Bloco - Ficha de Compensação ##
   // #################################################
   oPrint:Line (nLin+1980,0100,nLin+1980,2300)														// Quadro
   oPrint:Line (nLin+1980,0500,nLin+1900,0500)														// Quadro
   oPrint:Line (nLin+1980,0710,nLin+1900,0710)														// Quadro
   
   // ####################
   // Logotipo do Banco ##
   // ####################
   //If !Empty(aDadBco[9])
   oPrint:SayBitMap(nLin+1914,0100,cBmp,350,060)													// Logotipo do Banco 	
   //Else
   //	oPrint:Say  (nLin+1934,100,	aDadBco[8],												oFont14)	// Nome do Banco
   //EndIf

   // ###########################
   // Número do Banco + Dígito ##
   // ###########################
   oPrint:Say  (nLin+1945,0533,	aDadosBanco[1]+"-"+aDadosBanco[2], oFont21)	// Numero do Banco + Dígito

   // ######################################
   // Linha Digitável do Código de Barras ##
   // ######################################
   oPrint:Say  (nLin+1954,0755,	aBarra[2],												oFont15n)	// Linha Digitavel do Codigo de Barras
   
   // #######################
   // Quandrados do Boleto ##
   // #######################
   oPrint:Line (nLin+2080,100,nLin+2080,2300 )
   oPrint:Line (nLin+2180,100,nLin+2180,2300 )
   oPrint:Line (nLin+2250,100,nLin+2250,2300 )
   oPrint:Line (nLin+2320,100,nLin+2320,2300 )
   oPrint:Line (nLin+2180,0500,nLin+2320,0500)
   oPrint:Line (nLin+2250,0750,nLin+2320,0750)
   oPrint:Line (nLin+2180,1000,nLin+2320,1000)
   oPrint:Line (nLin+2180,1300,nLin+2250,1300)
   oPrint:Line (nLin+2180,1480,nLin+2320,1480)

   // #####################
   // Local de Pagamento ##
   // #####################
   oPrint:Say  (nLin+2000,0100,	"Local de Pagamento", oFont8)

   If Alltrim(SA6->A6_COD) == "001"
	  oPrint:Say  (nLin+2015,0400,	"Pagável em qualquer banco até o vencimento.", oFont10)
   Else 	
      oPrint:Say  (nLin+2015,0400,	"ATÉ O VENCIMENTO, PREFERENCIALMENTE NO " + aDadBco[8], oFont10)
	  oPrint:Say  (nLin+2055,0400 ,	"APÓS O VENCIMENTO, SOMENTE NO " + aDadBco[8], oFont10)
   EndIf
           
   // #######################
   // Vencimento do Título ##
   // #######################
   oPrint:Say  (nLin+2000,1810,	"Vencimento", oFont8)
   oPrint:Say  (nLin+2040,1900,	StrZero(Day(aDadTit[4]),2) + "/" + StrZero(Month(aDadTit[4]),2) + "/" + StrZero(Year(aDadTit[4]),4), oFont11c)
                                                 
   // ###############
   // Beneficiário ##
   // ###############
   oPrint:Say  (nLin+2100,0100,	"Beneficiário", oFont8)
   oPrint:Say  (nLin+2140,0100,	AllTrim(aDadEmp[1]) + If(!Empty(cAvalista),""," - CNPJ: " + Transform(aDadEmp[9], "@R 99.999.999/9999-99")), oFont10)

   // #################################
   // Agência/Código do Beneficiário ##
   // #################################
   oPrint:Say  (nLin+2100,1810,	"Agência/Código Beneficiário", oFont8)
   oPrint:Say  (nLin+2140,1900,	AllTrim(aDadBco[15]), oFont11c)

   // #################### 
   // Data do Documento ##
   // ####################
   oPrint:Say  (nLin+2200,0100,	"Data do Documento", oFont8)
   oPrint:Say	(nLin+2230,0100, StrZero(Day(aDadTit[2]),2) + "/" + StrZero(Month(aDadTit[2]),2) + "/" + StrZero(Year(aDadTit[2]),4), oFont10)

   // ######################
   // Número do Documento ##
   // ######################
   oPrint:Say  (nLin+2200,0505,	"Nro.Documento", oFont8)
   oPrint:Say  (nLin+2230,0605,	aDadTit[16] + "/" + aDadTit[17], oFont10)
  
   // ####################
   // Espécie Documento ##
   // ####################
   oPrint:Say  (nLin+2200,1005,	"Espécie Doc.", oFont8)
   oPrint:Say  (nLin+2230,1050,	"DM", oFont10)

   // #########
   // Aceite ##
   // #########
   oPrint:Say  (nLin+2200,1305,	"Aceite", oFont8)
   oPrint:Say  (nLin+2230,1400,	"N", oFont10)

   // ########################
   // Data do Processamento ##
   // ########################
   oPrint:Say  (nLin+2200,1485,	"Data do Processamento", oFont8)
   oPrint:Say  (nLin+2230,1550,	StrZero(Day(dDataBase),2) + "/" + StrZero(Month(dDataBase),2) + "/" + StrZero(Year(dDataBase),4), oFont10)

   // ###############
   // Nosso Número ##
   // ###############
   oPrint:Say  (nLin+2200,1810,	"Nosso Número",	oFont8)

   //If Alltrim(SA6->A6_COD)$ "033"
   //	oPrint:Say  (nLin+2230,1900,	SubStr(aBarra[4],5,9),								oFont11c)	// Nosso Número  
   //Else	
   oPrint:Say  (nLin+2230,1900,	aBarra[4], oFont11c)	// Nosso Número
   //EndIf

   // ###############
   // Uso do Banco ##
   // ###############
   oPrint:Say  (nLin+2270,0100,	"Uso do Banco", oFont8)
   oPrint:Say  (nLin+2300,0150,	aDadBco[13], oFont10)

   // ###########
   // Carteira ##
   // ###########
   oPrint:Say  (nLin+2270,0505,	"Carteira", oFont8)

   If Alltrim(SA6->A6_COD)$ "033"
      oPrint:Say  (nLin+2300,0555,	"109" + " - RCR", oFont10)
   Else	
      oPrint:Say  (nLin+2300,0555,	aDadTit[10], oFont10) 
   EndIf	

   // ##########
   // Espécie ##
   // ##########
   oPrint:Say  (nLin+2270,0755,	"Espécie", oFont8)
   oPrint:Say  (nLin+2300,0805,	"R$", oFont10)

   // #############
   // Quantidade ##
   // #############
   oPrint:Say  (nLin+2270,1005,	"Quantidade", oFont8)
   oPrint:Say  (nLin+2270,1485,	"Valor", oFont8)

   // #####################
   // Valor do Documento ##
   // #####################
   oPrint:Say  (nLin+2270,1810,	"Valor do Documento", oFont8)
   oPrint:Say  (nLin+2300,1900,	Transform(aDadTit[5], "@E 9999,999,999.99"), oFont11c)

   // #############
   // Instruções ##
   // #############
   oPrint:Say  (nLin+2340,0100,	"Instruções (Todas informações deste bloqueto são de exclusiva responsabilidade do beneficiário)", oFont8)
   oPrint:Say  (nLin+1100,0100,	"Juros / Mora por dia : 0,33%,  R$ " + alltrim(	Transform((0.0033*aDadTit[5]),"@E 9999,999,999.99")) + " ao dia ", oFont10)
   oPrint:Say  (nLin+1150,0100,	"Protesto Automático após 5 dias de atraso", oFont10)
   oPrint:Say  (nLin+1200,0100,	"Depósito em conta não quita o boleto.", oFont10)
   oPrint:Say  (nLin+1250,0100,	"Dúvidas: envie e-mail para contasareceber@vitasons.com.br", oFont10)
   //oPrint:Say  (nLin+2550,0100,	aDadTit[14],											oFont10)	// 4a. Linha Instrução
   //oPrint:Say  (nLin+2600,0100,	aDadTit[15],											oFont10)	// 5a. Linha Instrução
   //oPrint:Say  (nLin+2650,0100,	aDadTit[16],											oFont10)	// 6a. Linha Instrução

   // ################################
   // Imprime títulos dos quadrados ##
   // ################################
   oPrint:Say  (nLin+2340,1810,	"(-)Desconto/Abatimento", oFont8)
   oPrint:Say  (nLin+2410,1810,	"(-)Outras Deduções"    , oFont8)
   oPrint:Say  (nLin+2480,1810,	"(+)Mora/Multa"         , oFont8)
   oPrint:Say  (nLin+2550,1810,	"(+)Outros Acréscimos"  , oFont8)
   oPrint:Say  (nLin+2620,1810,	"(=)Valor Cobrado"      , oFont8)

   // ##########
   // Pagador ##
   // ##########
   oPrint:Say  (nLin+2690,0100,	"Pagador", oFont8)
   oPrint:Say  (nLin+2700,0200,	aDadCli[3], oFont10)
   //oPrint:Say  (nLin+2700,0200,	" ("+aDadCli[1]+"-"+aDadCli[2]+") "+aDadCli[3],		oFont10)	// Nome Cliente + Código

   // #############
   // CNPJ / CPF ##
   // #############
   If aDadCli[6] = "J"
	  oPrint:Say  (nLin+2700,1850,	"CNPJ: "+Transform(aDadCli[4],"@R 99.999.999/9999-99"), oFont10)	// Endereço
   Else
	  oPrint:Say  (nLin+2700,1850,	"CPF: "+Transform(aDadCli[4],"@R 999.999.999-99"), oFont10)	// Endereço
   EndIf

   oPrint:Say  (nLin+2753,0200,	Alltrim(aDadCli[7]) + " " + AllTrim(aDadCli[8]), oFont10)	// Endereço
   oPrint:Say  (nLin+2806,0200,	Transform(aDadCli[11],"@R 99999-999") + " - " + AllTrim(aDadCli[9]) + " - " + AllTrim(aDadCli[10]), oFont10) // CEP + Cidade + Estado

   // ##########################
   // Carteira / Nosso Número ##
   // ##########################
   oPrint:Say  (nLin+2806,1850,	aBarra[4],												oFont10)	// Carteira + Nosso Número

   // #####################
   // Pagador / Avalista ##
   // #####################
   oPrint:Say  (nLin+2855,0100,	"Pagador/Avalista" + if( !empty(cAvalista)," - " + Rtrim(cAvalista),""), oFont8)		// Texto Fixo + Sacador Avalista
   oPrint:Say  (nLin+2895,1500,	"Autenticação Mecânica - Ficha de Compensação",			oFont8)		// Texto Fixo
   
   // #############################
   // Quadros do Boleto Bancário ##
   // #############################
   oPrint:Line (nLin+1980,1800,nLin+2670,1800)
   oPrint:Line (nLin+2390,1800,nLin+2390,2300)
   oPrint:Line (nLin+2460,1800,nLin+2460,2300)
   oPrint:Line (nLin+2530,1800,nLin+2530,2300)
   oPrint:Line (nLin+2600,1800,nLin+2600,2300)
   oPrint:Line (nLin+2670,0100,nLin+2670,2300)
   oPrint:Line (nLin+2870,0100,nLin+2870,2300)

   // ############################
   // Se Impressão em polegadas ##
   // Guarabira                 ##
   // ############################
//   If nTpImp == 1
//	  oPrint:FwMSBAR("INT25" ,52,1   ,aBarra[1],oPrint,.F.   ,Nil  ,Nil  ,0.017     ,1   ,Nil    ,Nil,"A"  ,.F. ) //datasupri
//   Else        
//	  oPrint:FwMSBAR("INT25" ,52,1   ,aBarra[1],oPrint,.F.   ,Nil  ,Nil  ,0.017     ,1   ,Nil    ,Nil,"A"  ,.F. ) //datasupri
//   EndIf

   oPrint:EndPage() // Finaliza a página
   oPrint:Preview() // Visualiza antes de imprimir

// SE1->(dbSetOrder(1), dbSeek(xFilial("SE1") + aDadTit[1] + aDadTit[2] + aDadTit[3]))

   DbSelectArea("SE1")
   DbSetOrder(1)
   DbSeek(xFilial("SE1") + aDadTit[7] + Substr(Alltrim(aDadTit[1]),01,06) + "   " + Substr(Alltrim(aDadTit[1]),08,02) + aDadTit[8])

   SA1->(dbSetOrder(1), dbSeek(xFilial("SA1") + SE1->E1_CLIENTE + SE1->E1_LOJA))

//   cArquivo := 'C:\TEMP\'+cFilename+'.PDF' //AllTrim('\system\bol'+SE1->E1_NUM+"_pag1.jpg")
   
Return(Nil)

// #########################################################################################
// Função que gera o Cálcula o código de barras, linha digitável e dígito do nosso número ##
// Parâmetros  ExpC1 = Código do Banco                                                    ## 
//             ExpC2 = Número da Agência                                                  ##
//             ExpC3 = Dígito da Agência                                                  ##
//             ExpC4 = Número da Conta Corrente                                           ##
//             ExpC5 = Dígito da Conta Corrente                                           ##
//             ExpC6 = Carteira                                                           ##
//             ExpC7 = Nosso Número sem dígito                                            ##
//             ExpN1 = Valor do Título                                                    ##
//             ExpD1 = Data de Vencimento                                                 ##
//             ExpC8 = Número do Contrato                                                 ##
// #########################################################################################
Static Function GetBarra(cBanco,cAgencia,cDigAgencia,cConta,cDigConta,cCarteira,cNNum,nValor,dVencto,cContrato)

   Local cValorFinal := StrZero(Int(NoRound(nValor*100)),10)
   Local cDvCB		 := 0
   Local cDv		 := 0
   Local cNN		 := ""
   Local cNNForm	 := ""
   Local cRN		 := ""
   Local cCB		 := ""
   Local cS			 := ""
   Local cDvNN		 := "" 
   Local cContra	 := "" 
   Local cFator		 := StrZero(dVencto - CToD("07/10/97"),4)
   Local cCpoLivre	 := Space(25)

   // ##########################################
   // Definicao do NOSSO NÚMERO E CAMPO LIVRE ##
   // ##########################################

   // #########
   // BRASIL ##
   // #########
   If cBanco $ "001"
	  // ######################################################################
	  // Composicao do Campo Livre (25 posições)                             ## 
	  //                                                                     ## 
	  // SOMENTE PARA AS CARTEIRAS 16/18 (com convênios de 6 posições)       ## 
	  // 20 a 25 - (06) - Número do Convênio                                 ## 
	  // 26 a 42 - (17) - Nosso Número                                       ## 
	  // 43 a 44 - (02) - Carteira de cobrança                               ## 
	  //                                                                     ## 
	  // SOMENTE PARA AS CARTEIRAS 17/18                                     ## 
	  // 20 a 25 - (06) - Fixo 0                                             ## 
	  // 26 a 32 - (07) - Número do convênio                                 ## 
	  // 33 a 42 - (10) - Nosso Numero (sem o digito verificador)            ## 
	  // 43 a 44 - (02) - Carteira de cobrança                               ## 
	  //                                                                     ## 
	  // Composicao do Nosso Número                                          ## 
	  // 01 a 06 - (06) - Número do Convênio (SEE->EE_CODEMP)                ## 
	  // 07 a 11 - (05) - Nosso Número (SEE->EE_FAXATU)                      ## 
	  // 12 a 12 - (01) - Dígito do Nosso Número (Modulo 11)                 ## 
	  // ######################################################################
	  
	  // ###########################################
	  // Carteira 16/18 - Convênio com 6 posiçoes ##
	  // ###########################################
	  If Len(AllTrim(cContrato)) > 6
		 Cs	:= AllTrim(cContrato) + cNNum + cCarteira

    	 // ###################################################
	     // Carteira 17/18 - Convênio com mais de 6 posiçoes ##
	     // ###################################################
	  Else
		 Cs	:= "000000" + AllTrim(cContrato) + cNNum + cCarteira
 	  EndIf

	  cDvNN		:= U_TCCalcDV( cBanco, cS )		//Modulo11(cS)
	  cNN		:= AllTrim(cContrato) + cNNum + cDvNN
	  cNNForm	:= AllTrim(cContrato) + cNNum
//	  cNNForm	:= AllTrim(cContrato) + cNNum + "-" + cDvNN
	  cCpoLivre	:= ""

      // ###########
      // BRADESCO ##
      // ###########
   ElseIf cBanco $ "237"

	  // ########################################################################
	  // Composicao do Campo Livre (25 posições)                               ##
	  //                                                                       ##
	  // 20 a 23 - (04) - Agencia cedente (sem o digito), completar com zeros  ##
	  //                  a esquerda se necessario	                           ##
	  // 24 a 25 - (02) - Carteira                                             ##
	  // 26 a 36 - (11) - Nosso Numero (sem o digito verificador)              ##
	  // 37 a 43 - (07) - Conta do cedente, sem o digito verificador, complete ##
	  //                  com zeros a esquerda, se necessario                  ##
	  // 44 a 44 - (01) - Fixo "0"                                             ##
	  //                                                                       ##
	  // Composicao do Nosso Número                                            ##
	  // 01 a 02 - (02) - Número da Carteira (SEE->EE_SUBCTA)                  ##
	  //                  06 para Sem Registro 19 para Com Registro            ##
	  // 03 a 13 - (11) - Nosso Número (SEE->EE_FAXATU)                        ##
	  // 04 a 14 - (01) - Dígito do Nosso Número (Modulo 11)                   ##
	  // ########################################################################
	  
	  cS		:= AllTrim(cCarteira) + cNNum
	  cDvNN		:= U_TCCalcDV( cBanco, cS )			//Mod11237(cS)
	  cNN		:= AllTrim(cCarteira) + cNNum + cDvNN
//	  cNNForm	:= AllTrim(cCarteira) + "/"+ Substr(cNNum,1,2)+"/"+Substr(cNNum,3,9) + "-" + cDvnn
 	  cNNForm	:= AllTrim(cCarteira) + "/"+ Substr(cNNum,1,2)+Substr(cNNum,3,9) + "-" + cDvnn
	  cCpoLivre	:= StrZero(Val(AllTrim(cAgencia)),4)+StrZero(Val(AllTrim(cCarteira)),2)+cNNum+StrZero(Val(AllTrim(cConta)),7)+"0"

      // #######
      // ITAÚ ##
      // #######
   ElseIf cBanco $ "341"
   
	  // #######################################################################
	  // Composicao do Campo Livre (25 posições)                              ##
	  //                                                                      ##
	  // 20 a 22 - (03) - Carteira                                            ##
	  // 23 a 30 - (08) - Nosso Número (sem o dígito verificador)             ##
	  // 31 a 31 - (01) - Digito verificador                                  ##
	  // 32 a 35 - (04) - Agência                                             ##
	  // 36 a 40 - (05) - Conta (sem o dígito verificador                     ##
	  // 41 a 41 - (01) - Dígito verificador da conta                         ##
	  // 42 a 44 - (03) - Fixo "000"                                          ##
	  //                                                                      ##
	  // Composicao do Nosso Número                                           ##
	  // Se carteira for 126/131/146/150/168                                  ##
	  // 01 a 03 - (03) - Carteira                                            ##
	  // 04 a 11 - (08) - Nosso Número (EE_FAXATU)                            ##
	  // Demais carteiras                                                     ##
	  // 01 a 04 - (04) - Agência sem dígito verificador                      ##
	  // 05 a 09 - (05) - Conta Corrente sem dígito verificador               ##
	  // 10 a 12 - (03) - Carteira                                            ##
	  // 13 a 20 - (08) - Nosso Número (EE_FAXATU)                            ##
	  // #######################################################################
	  If cCarteira $ "126/131/146/150/168"
		 cS	:=  AllTrim(cCarteira) + cNNum
	  Else
		 cS	:=  AllTrim(cAgencia) + AllTrim(cConta) + AllTrim(cCarteira) + cNNum
	  EndIf

	  If Mv_PAR15 == 2
		 cDvNN		:= U_TCCalcDV( cBanco, cS )			//Modulo10(cS)
		 cNN			:= AllTrim(cCarteira) + cNNum + cDvNN
	  Else
		 cDvNN		:= SubStr(cNNum,9,1)			//Modulo10(cS)
		 cNNum		:= SubStr(cNNum,1,8)
		 cNN			:= AllTrim(cCarteira) + cNNum + cDvNN
	  EndIf	

	  cNNForm	:= AllTrim(cCarteira) + "/"+ cNNum + "-" + cDvNN
	  cCpoLivre	:= StrZero(Val(AllTrim(cCarteira)),3)+cNNum+cDvNN+StrZero(Val(Alltrim(cAgencia)),4)+StrZero(Val(AllTrim(cConta)),5)+cDigConta+"000"

      // ###########
      // CITIBANK ##
      // ###########
   ElseIf cBanco $ "745"
   
	  // ########################################################################
	  // Composicao do Campo Livre (25 posições)                               ##
	  //                                                                       ##
	  // 20 a 20 - (01) - Código do Produto (3=Cobrança com/sem registro       ##
	  //                  4=Cobrança de seguro sem registro)                   ##
	  // 21 a 23 - (03) - Portifólio 3 últimos dígitos do campo código Empresa ##
	  //                  Segundo Douglas (Citigroup) enviar neste campo o     ##
	  //                  número da carteira.                                  ##
	  //                  O número do contrato é chamado de Conta Cosmos e é   ##
	  //                  formado por 10 posições com A.BBBBBB.CC.D, onde      ##
	  //                  A      = Não utilizado                               ##
	  //                  BBBBBB = Base                                        ##
	  //                  CC     = Sequencia                                   ##
	  //                  D      = Dígito                                      ##
	  // 24 a 29 - (06) - Base (Contrato)                                      ##
	  // 30 a 31 - (02) - Sequencia (Contrato)                                 ##
	  // 32 a 32 - (01) - Dígito da conta Cosmos (Contrato)                    ##
	  // 33 a 44 - (12) - Nosso Número com dígito verificador                  ##
	  //                                                                       ##
	  // Composicao do Nosso Número                                            ##
	  // 01 a 11 - (11) - Nosso Número (EE_FAXATU)                             ##
	  // ########################################################################
	  cS		:= cNNum
	  cDvNN		:= U_TCCalcDV( cBanco, cS )			//modulo11(cS)
   	  cNN		:= cNNum + cDvNN
	  cNNForm	:= cNNum + "-" + cDvNN
   	  cCpoLivre	:= "3" + StrZero(Val(cCarteira),3) + SubStr(AllTrim(cContrato), 2, 9) + cNN  
	  
     // ############
     // Santander ##
     // ############
   ElseIf cBanco $ "033"
	  cCart	  := Alltrim(SEE->EE_CODCART)
	  cContra := Alltrim(SEE->EE_CODEMP)
	  
// If Mv_Par15 == 2 .Or. Len(AllTrim(cNNum)) < 8
   If Len(AllTrim(cNNum)) < 8
		 cS		 :=  cCart + cNNum  
		 cS		 :=  cNNum  
	 	 cDvnn	 := modulo11(cS)
		 cNN	 := cCart + cNNum + '-' + cDvnn  
		 cNNForm := cNNum + "-" +cDvnn 	//cCart + "/"+ 
	  Else
	 	 cDvnn	 := SubStr(cNNum,8,1)
	 	 cNNum	 := SubStr(cNNum,1,7)
		 cNN	 := cCart + cNNum + '-' + cDvnn  
		 cNNForm := cNNum + "-" +cDvnn 	//cCart + "/"+ 
	  EndIf
   EndIf
	
   // #######################################
   // Definicao do DÍGITO CODIGO DE BARRAS ##
   // #######################################
   If cBanco $ "001"
	  cS	:= cBanco + "9" + cFator + cValorFinal + "000000" + Left(AllTrim(cNN),17) + AllTrim(cCarteira)
	  cDvCB	:= Modulo11(cS) 
	
   ElseIf cBanco $ "033"
                                                                                                                               
	  cCpoLivre	:= "9" + alltrim(right(SEE->EE_CODEMP,7)) + Strzero(val(cNNum),12) + AllTrim(cDvnn) + "0101"
//	  cCpoLivre	:= "91327283"+Strzero(val(cNNum),12)+AllTrim(cDvnn)+"0101"
	
   Else
      cS	:= cBanco + "9" + cFator + cValorFinal + cCpoLivre
	  cDvCB	:= Modulo11(cS)
   EndIf

   If cBanco $ "001"
	  cCB	:= cBanco+"9"+cDVCB+cFator+cValorFinal+"000000"+Left(AllTrim(cNN),17)+AllTrim(cCarteira) 
   ElseIf cBanco $ "033"
	  cS	:= cBanco+"9"+"8"+cFator+cValorFinal+cCpoLivre
	  nDvCb := Modulo11(Substr(cS,1,4)+Substr(cS,6,39))
//	  cCB	:= cBanco+"9"+STR(nDVCb,1)+cFator+cValorFinal+cCpoLivre
 	  cCB	:= cBanco + "9" + nDVCb + cFator + cValorFinal + cCpoLivre
   Else
	  cCB	:= cBanco + "9" + cDVCB + cFator + cValorFinal + cCpoLivre
   EndIf

   // ##########################################################################
   //                   Definicao da LINHA DIGITÁVEL                          ## 
   // Campo 1       Campo 2        Campo 3        Campo 4   Campo 5           ##
   // AAABC.CCCCX   CCCCC.CCCCCY   CCCCC.CCCCCZ   W	      UUUUVVVVVVVVVV      ##
   // ##########################################################################
   // AAA                       = Código do Banco na Câmara de Compensação    ##
   // B                         = Código da Moeda, sempre 9                   ##
   // CCCCCCCCCCCCCCCCCCCCCCCCC = Campo Livre                                 ##
   // X                         = Digito Verificador do Campo 1               ##
   // Y                         = Digito Verificador do Campo 2               ##
   // Z                         = Digito Verificador do Campo 3               ##
   // W                         = Digito Verificador do Codigo de Barras      ##
   // UUUU                      = Fator de Vencimento                         ##
   // VVVVVVVVVV                = Valor do Título                             ##
   // ##########################################################################

   // ###########################################
   // CALCULO DO DÍGITO VERIFICADOR DO CAMPO 1 ##
   // ###########################################
   If cBanco $ "001|033"
	  cS	:= cBanco + "9" +"9"  +Substr(cCB,20,5)
	  cDv	:= modulo10(cS)
	  cRN1	:= SubStr(cS, 1, 5) + "." + SubStr(cS, 7, 4) + Alltrim(Str(cDv))
   Else
	  cS	:= cBanco + "9" +Substr(cCpoLivre,1,5)
	  cDv	:= modulo10(cS)
	  cRN1	:= SubStr(cS, 1, 5) + "." + SubStr(cS, 6, 4) + Alltrim(Str(cDv))
   EndIf

   // ###########################################
   // CALCULO DO DÍGITO VERIFICADOR DO CAMPO 2 ##
   // ###########################################
   If cBanco $ "001"
	  cS	:= Substr(cCB,25,10)
	  cDv 	:= modulo10(cS)
	  cRN2	:= cS + cDv
	  cRN2	:= SubStr(cS, 1, 5) + "." + Substr(cS, 6, 5) + Alltrtim(Str(cDv))
   ElseIf cBanco $ "033"
	  cS   := Substr(cCpoLivre,6,10)
	  cDv  := modulo10(cS)
	  cRN2 := cS + Alltrim(cDv)
	  cRN2 := Substr(cRN2,1,3) + " " + Substr(cCpoLivre,9,7) + Alltrim(Str(cDv))
   Else
	  cS	:= Substr(cCpoLivre,6,10)
	  cDv	:= modulo10(cS)
	  cRN2	:= cS + cDv
	  cRN2	:= SubStr(cS, 1, 5) + "." + Substr(cS, 6, 5) + Alltrim(Str(cDv))
   EndIf

   // ###########################################
   // CALCULO DO DÍGITO VERIFICADOR DO CAMPO 3 ##
   // ###########################################
   If cBanco $ "001"
	  cS		:= Substr(cCB,35,10)
	  cDv		:= modulo10(cS)
	  cRN3	:= SubStr(cS, 1, 5) + "." + Substr(cS, 6, 5) + Alltrim(Str(cDv))
   ElseIf cBanco $ "033"
	  cS    := Substr(cCpoLivre,17,5)
	  cDv   := modulo10(cS)
	  cRN3  := cS + Alltrim(Str(cDv))
	  cRN3  := Substr(cS,1,5) + " 0 " + "101" 
	  cRN3  :=cRN3 + Alltrim(Str(modulo10(cRN3)))
   Else
      cS	:= Substr(cCpoLivre,16,10)
	  cDv	:= modulo10(cS)
	  cRN3	:= SubStr(cS, 1, 5) + "." + Substr(cS, 6, 5) + Alltrim(Str(cDv))
   EndIf

   // #####################
   // CALCULO DO CAMPO 4 ##
   // #####################
   If cBanco $ "033"
      cRN4 := Substr(cCb,5,1)
   Else	
	  cRN4 := cDvCB
   EndIf

   // #####################
   // CALCULO DO CAMPO 5 ##
   // #####################
   cRN5	:= cFator + cValorFinal

   cRN	:= cRN1 + " " + cRN2 + ' '+ cRN3 + ' ' + cRN4 + ' ' + cRN5

Return({cCB,cRN,cNNum,cNNForm,cDvNN})

// ##########################################################################################
// Programa    |TOPCONCNAB³ Biblioteca de funções genéricas para utilização na geração de  ##
//             |          ³ boleto de cobrança em formato gráfico, e nos arquivos de       ##
//             ³          ³ comunicação bancária (remessa e retorno) do Cnab               ##
// ##########################################################################################
// Autor       | Flávio Macieira                                                 26.08.13³ ##
// ##########################################################################################
// Observações | Os arquivos SE1, SA1 e SA6 devem estar posicionados no registro a ser     ##
//             | impresso                                                                  ##
//             |                                                                           ##
//             |         ANTES DE QUALQUER PROCESSAMENTO CRIAR CAMPOS/PARÂMETROS           ##
//             | ***************************** CAMPOS NOVOS ****************************   ##
//             | A6_DIGBCO  - C - 01,0 - OBRIGATÓRIO - Dígito do banco perante a câmara    ##
//             |              de compensação (FEBRABAN).                                   ##
//             | A6_ARQLOG  - C - 15,0 - OPCIONAL - Nome do arquivo com o logotipo do      ##
//             |              banco que deve obrigatoriamente estar no diretório \SYSTEM\  ##
//             |              se não existir, colocará no lugar do logo o nome reduzido    ##
//             |              do cadastro de bancos.                                       ##
//             | ****************************** PARÂMETROS *****************************   ##
//             | TC_TXJBOL - Taxa de juros de mora ao mês por atraso no pagamento, se não  ##
//             |             existir não irá colocar a mensagem com o valor dos juros que  ##
//             |             deverá ser cobrado por dia de atraso.                         ##
//             | TC_TXMBOL - Taxa de multa por atraso no pagamento, se não existir não     ##
//             |             irá colocar a mensagem com o percentual de multa a ser que    ##
//             |             deverá ser cobrado por atraso no pagamento                    ##
//             | TC_DIABOL - Número de dias para envio do título ao cartório, se não       ##
//             |             existir não irá colocar a mensagem com o prazo de envio do    ##
//             |             título ao cartório                                            ##
//             | MC_BCEDEN - Parametro que indica se o Banco será o Cedente do Boleto.     ##
//             |                   CAMPOS ATUALIZADOS NA ROTINA                            ##
//             | E1_PORTADO - com o banco selecionado no parâmetro da rotina               ##
//             | E1_AGENCIA - com a agência selecionada no parâmetro da rotina             ##
//             | E1_CONTA   - com a conta selecionada no parâmetro da rotina               ##
//             | EE_FAXATU  - com ó próximo número disponível para utilização              ##
//             | ******************************* DIVERSOS ******************************   ##
//             | 1. O campo EE_FAXATU deve conter o próximo número do boleto SEM o dígito  ##
//             |    verificador e no tamanho exato do número definido no manual do banco,  ##
//             |    NÃO deve haver caracteres separadores (.;,-etc...)                     ##
//             |    Citibank  - 11 posiçoes                                                ##
//             |    Itaú      - 08 Posições                                                ##
//             |    Brasil    - 10 Posições                                                ##
//             |    Bradesco  - 11 Posições                                                ##
//             |    Santander - 11 Posições                                                ##
//             | 2. Carteira  - para definição do código da carteira é utilizado o campo   ##
//             |    EE_SUBCTA                                                              ##
//             |                                                                           ##
// ##########################################################################################

// ##########################################################################################
// Programa    | TCDadBco ³ Retorna array com os dados do banco e da empresa               ##
//             |          ³                                                                ##
// ##########################################################################################
// Autor       | Flávio Macieira                                                 26.08.13  ##
// ##########################################################################################
// Parâmetros  | ExpA1 = Array vazio passado por referência para ser atualizado com os     ##
//             |         dados do cadastro de empresa (SigaMat)                            ##
//             | ExpA2 = Array Vazio passado por referência para ser atualizado com os     ##
//             |         dados so cadastro do banco (SA6)                                  ##
// ##########################################################################################
// Retorno     | ExpL1 = .T. montou os arrays corretamento, .F. não montou os arrays       ##
// ##########################################################################################
// Observações | Os arquivos devem estar posicionados SM0, SA6, SEE                        ##
// ##########################################################################################
// Alterações  | 99.99.99 - Consultor - Descrição da alteração                             ##
//             |                                                                           ##
// ##########################################################################################
//User Function TCDadBco(aDadEmp, aDadBco)
Static Function TCDadBco(aDadEmp, aDadBco)

   Local aAreaAtu	:= GetArea()
   Local lRet		:= .T.     

   // ##################################################################################
   // Parametro que verifica se o Banco será o Cedente do Titulo, através dos campos  ##
   // Cod. Banco, Agência e Número de conta, que devem ser informados sequencialmente ##
   // no parametro.                                                                   ##
   // ##################################################################################
   Local cCedente  := ''//IF(ValType(GetMv("MC_BCEDEN")) <> "C","",ALLTRIM(GetMv("MC_BCEDEN")))   

   // #################################################
   // Verifica se passou os parâmetros para a função ##
   // #################################################
   If (aDadEmp == Nil .Or. ValType(aDadEmp) <> "A") .Or. (aDadBco == Nil .Or. ValType(aDadBco) <> "A")
	  Aviso("Biblioteca de Funções",;
			"Os parâmetros passados por referência estão fora dos padrões."+Chr(13)+Chr(10)+;
			"Verifique a chamada da função no programa de origem.",;
			{"&Continua"},2,;
			"Chamada Inválida" )
	  lRet	:= .F.
   EndIf

   // #############################################
   // Verifica se os arquivos estão posicionados ##
   // #############################################
   If SM0->(Eof()) .Or. SM0->(Bof())
	  Aviso("Biblioteca de Funções",;
			"O arquivo de Empresas não esta posicionado.",;
			{"&Continua"},,;
			"Registro Inválido" )
	  lRet	:= .F.
   EndIf

   If SA6->(Eof()) .Or. SA6->(Bof())
	  Aviso("Biblioteca de Funções",;
			"O arquivo de Bancos não esta posicionado.",;
			{"&Continua"},,;
			"Registro Inválido" )
	  lRet	:= .F.
   EndIf

   // ###############################################################
   // Cria array vazio para que não dê erro se não encontrar dados ##
   // ###############################################################
   aDadEmp	:= { "",;	// [1] Nome da Empresa
				 "",;	// [2] Endereço
				 "",;	// [3] Bairro
				 "",;	// [4] Cidade
				 "",;	// [5] Estado
				 "",;	// [6] Cep
				 "",;	// [7] Telefone
				 "",;	// [8] Fax
				 "",;	// [9] CNPJ
				 "" ;	// [10]Inscrição Estadual
				 }

   aDadBco	:= { "",;	// [1] Código do Banco
				 "",;	// [2] Dígito do Banco
				 "",;	// [3] Código da Agência
				 "",;	// [4] Dígito da Agência
				 "",;	// [5] Número da Conta Corrente
				 "",;	// [6] Dígito da Conta Corrente
				 "",;	// [7] Nome Completo do Banco
				 "",;	// [8] Nome Reduzido do Banco
				 "",;	// [9] Nome do Arquivo com o Logotipo do Banco
				 0,;	// [10]Taxa de juros a ser utilizado no cálculo de juros de mora
				 0,;	// [11]Taxa de multa a ser impressa no boleto
				 0,;	// [12]Número de dias para envio do título ao cartório
				 "",;	// [13]Dado para o campo "Uso do Banco"
				 "",;	// [14]Dado para o campo "Espécie do Documento"
				 "",;	// [15]Código do Cedente
				 "" ;   // [16]Contrato banco\Convênio
				 }


   If lRet			 
	  // #########################################
	  // Alimenta array com os dados da Empresa ##
	  // #########################################
      SM0->(DbSeek(cEmpAnt + cFilAnt))
   
	  If !Empty(SM0->M0_ENDCOB)
	 	 aDadEmp[2]	:= SM0->M0_ENDCOB
		 aDadEmp[3]	:= SM0->M0_BAIRCOB
		 aDadEmp[4]	:= SM0->M0_CIDCOB
		 aDadEmp[5]	:= SM0->M0_ESTCOB
		 aDadEmp[6]	:= SM0->M0_CEPCOB
	  Else
		 aDadEmp[2]	:= SM0->M0_ENDENT
		 aDadEmp[3]	:= SM0->M0_BAIRENT
		 aDadEmp[4]	:= SM0->M0_CIDENT
		 aDadEmp[5]	:= SM0->M0_ESTENT
		 aDadEmp[6]	:= SM0->M0_CEPENT
	  EndIf

	  If ALLTRIM( SA6->A6_COD + alltrim(SA6->A6_AGENCIA) + SA6->A6_NUMCON ) $ cCedente
		 aDadEmp[1]	 := SA6->A6_CEDENTE
	  Else
		 aDadEmp[1]	 := SM0->M0_NOMECOM
		 aDadEmp[7]	 := SM0->M0_TEL
		 aDadEmp[8]	 := SM0->M0_FAX
		 aDadEmp[9]	 := SM0->M0_CGC
		 aDadEmp[10] := SM0->M0_INSC
	 Endif
	
	 // #######################################
	 // Alimenta array com os dados do Banco ##
	 // #######################################

	 DbSelectArea( "SA6" )
	 DbSetOrder(1)
	 DbSeek( xFilial("SA6") + xNumBanco + xAgencia + xConta)

	 If SA6->(FieldPos("A6_DIGBCO")) > 0
		aDadBco[1]	:= SA6->A6_COD
		aDadBco[2]	:= SA6->A6_DIGBCO
	 Else
		aDadBco[1]	:= SA6->A6_COD
		aDadBco[2]	:= '7'
	 EndIf
	 If SA6->(FieldPos("A6_DVAGE")) > 0
		aDadBco[3]	:= SA6->A6_AGENCIA
		aDadBco[4]	:= SA6->A6_DVAGE //SA6->A6_DIGAGE
	 Else
		If At( "-", SA6->A6_AGENCIA ) > 1
			aDadBco[3]	:= SubStr( SA6->A6_AGENCIA, 1, At( "-", SA6->A6_AGENCIA ) - 1 )
			aDadBco[4]	:= SubStr( SA6->A6_AGENCIA, At( "-", SA6->A6_AGENCIA ) + 1, 1 )
		Else
			aDadBco[3]	:= Alltrim(	SA6->A6_AGENCIA	)
			aDadBco[4]	:= ""
		EndIf
	 EndIf
	
	 If SA6->(FieldPos("A6_DVCTA")) > 0 
		If At( "-", SA6->A6_NUMCON ) > 1   
			aDadBco[5]	:= SubStr( SA6->A6_NUMCON, 1, At( "-", SA6->A6_NUMCON ) - 1)   
			aDadBco[6]	:= SubStr( SA6->A6_NUMCON, At( "-", SA6->A6_NUMCON ) + 1, 1)   
		Else	    
		aDadBco[5]	:= SA6->A6_NUMCON
		aDadBco[6]	:= SA6->A6_DVCTA  //SA6->A6_DIGCON
		EndIf
	 Else
		If At( "-", SA6->A6_NUMCON ) > 1
			aDadBco[5]	:= SubStr( SA6->A6_NUMCON, 1, At( "-", SA6->A6_NUMCON ) - 1)
			aDadBco[6]	:= SubStr( SA6->A6_NUMCON, At( "-", SA6->A6_NUMCON ) + 1, 1)
		Else
			aDadBco[5]	:= AllTrim( SA6->A6_NUMCON )
			aDadBco[6]	:= ""
		EndIf
	 EndIf

	 /*
	 If Alltrim(SEE->EE_CODIGO) == "341"       // Tratamento especifico para Dimep  - Flávio
		aDadBco[5] := SubStr(aDadBco[5],1,5)
		aDadBco[6] := IIf (SubStr(SEE->EE_CONTA,6,1)== "-",SubStr(SEE->EE_CONTA,7,1), SubStr(SEE->EE_CONTA,6,1))
	 EndIf				
	 */

 	 aDadBco[7]	:= SA6->A6_NOME

 //	 aDadBco[8]	:= Iif( AllTrim(SA6->A6_COD) == "001","BANCO DO BRASIL SA",SA6->A6_NREDUZ ) 

     If  AllTrim(SA6->A6_COD) == "001"
		aDadBco[8]	:= "BANCO DO BRASIL SA"   
		
	 ElseIf 	AllTrim(SA6->A6_COD) == "341"
		aDadBco[8]  := "BANCO ITAÚ S.A." 
		
	 ElseIf 	AllTrim(SA6->A6_COD) == "237"
		aDadBco[8]  := "BRADESCO"  
		
	 ElseIf  AllTrim(SA6->A6_COD) == "033" 
		aDadBco[8]	:= "SANTANDER" 
				
	 EndIf
			
	 If SA6->(FieldPos("A6_ARQLOG")) > 0
	 	aDadBco[9]	:= SA6->A6_ARQLOG                      
	 Else
	  	aDadBco[9]	:= ""
	 EndIf

	 // ################################################################
	 // Define as taxas a serem utilizadas nos cálculos das mensagens ##
	 // ################################################################
	 aDadBco[10]	:= SuperGetMv("TC_TXJBOL", .F., 0.00)
	 aDadBco[11]	:= SuperGetMv("TC_TXMBOL", .F., 0.00)
	 aDadBco[12]	:= SuperGetMv("TC_DIABOL", .F., 1)

	 // #############################################
	 // Define o campo Para Uso do Banco do boleto ##
	 // #############################################
	 If SA6->A6_COD $ "745#"
		aDadBco[13]	:= "CLIENTE"
	 EndIf

	 // ################################################
	 // Define o campo Espécio do Documento do boleto ##
	 // ################################################
	 If SA6->A6_COD $ "745#"
		aDadBco[14]	:= "DMI"
	 ElseIf SA6->A6_COD $ "001#|033"
		aDadBco[14]	:= "DM"
	 Else
		aDadBco[14]	:= "NF"
	 EndIf
    
	 // ############################################
	 // Define o campo da Conta/Cedente do boleto ##
	 // ############################################
	 If SA6->A6_COD $ "745#"

		// ##########################################
		// Agência + Conta Cosmos (Código Empresa) ##
		// ##########################################
		aDadBco[15]	:= AllTrim(aDadBco[3])
		If !Empty(aDadBco[4])
			aDadBco[15]	+= "-"+Alltrim(aDadBco[4])
		EndIf
		If !Empty(SEE->EE_CODEMP)
			aDadBco[15]	+= "/"+StrZero(Val(EE_CODEMP),10)
		EndIf
	 Else
	 
		// ###########################
		// Agência + Conta Corrente ##
		// ###########################
		aDadBco[15]	:= AllTrim(aDadBco[3])
		aDadBco[16] := SEE->EE_CODEMP
		If !Empty(aDadBco[4])
			aDadBco[15]	+= "-"+Alltrim(aDadBco[4])
		EndIf
		//If !Empty(aDadBco[5]) .AND. !SA6->A6_COD $ "033"
		aDadBco[15] += "/"+alltrim(right(SEE->EE_CODEMP,7))
			//If !Empty(aDadBco[6])
				//aDadBco[15] += "-"+AllTrim(aDadBco[6])
			//EndIf
		//Else
			//aDadBco[15] += "/"+AllTrim(aDadBco[16])	
		//EndIf
 	 EndIf

   EndIf

   RestArea(aAreaAtu)

Return(lRet)
