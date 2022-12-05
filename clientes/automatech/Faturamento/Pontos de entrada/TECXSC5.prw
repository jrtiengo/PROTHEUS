#Include "Protheus.ch"
#Include "Rwmake.ch"
#Include "Topconn.ch"

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: TECXSC5.PRW                                                         *
// Parâmetros: Nenhum                                                              *
// Tipo......: ( ) Programa  ( ) Gatilho  (X) Ponto de Entrada                     *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 11/05/2012                                                          *
// Objetivo..: Ponto de Entrada executado logo após a gravação do pedido de venda  *
//             das ordens de serviço que são efetivadas. Seu  objeivo  é gravar o  *                
//             código do vendedor conforme a filial logada.                        *
//             ------------------------------------------------------------------  *
//             Tarefa Nº 001114.01 - Após a gravação do pedido de venda pela efe-  *
//             tivação da Ordem de Serviço, é verificado, através da tabela AB8 -  *
//             apontamentos de ordens de serviço, se os serviços utilizados pos -  *
//             suem parametrização no grupo tributário  do  produtos apontado. Se  *
//             houver, atualiza a tabela SC6 com o TES que está parametrizado.     *
//**********************************************************************************

User Function TECXSC5()

   Local cNumOS   := ""
   Local cSql     := ""
   Local cCodPV   := ""
   Local cCodFL   := ""
   Local lTroca   := .F.
   Local eLogado  := Space(02)
   Local eCGC     := Space(14)
   Local eCliente := Space(06)
   Local eLoja    := Space(03)
   Local cString  := ""

   Local lResult

   U_AUTOM628("TECXSC5")
   
   cNumOs := ALLTRIM(M->AB6_NUMOS)

   If Select("T_PEDIDO") > 0
      T_PEDIDO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SC6.C6_FILIAL ,"
   cSql += "       SC6.C6_NUM    ,"
   cSql += "       SC6.C6_NUMOS  ,"
   cSql += "       SC6.C6_PRODUTO,"
   cSql += "       CONVERT(VARCHAR(8000),CONVERT(BINARY(8000), SC5.C5_MENNOTA)) AS MENSAGEM"
   cSql += "  FROM " + RetSqlName("SC6") + " SC6, "
   cSql += "       " + RetSqlName("SC5") + " SC5  "
   cSql += " WHERE SUBSTRING(SC6.C6_NUMOS,01,06) = '" + Alltrim(cNumOs) + "'"
   cSql += "   AND SC6.C6_FILIAL  = '" + Alltrim(cFilAnt) + "'"
   cSql += "   AND SC6.D_E_L_E_T_ = ''"
   cSql += "   AND SC5.C5_FILIAL = SC6.C6_FILIAL"
   cSql += "   AND SC5.C5_NUM    = SC6.C6_NUM"
   cSql += "   AND SC5.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PEDIDO", .T., .T. )

   T_PEDIDO->( DbGoTop() )

   If !T_PEDIDO->( Eof() )

      cCodPV := T_PEDIDO->C6_NUM
      cCodFL := T_PEDIDO->C6_FILIAL

      DbSelectArea("SC5")
      DbSetOrder(1)
               
      If DbSeek(cCodFL + cCodPV)

         Reclock("SC5",.f.)

         DO CASE
            CASE SC5->C5_FILIAL == "01"
                 SC5->C5_VEND1 := "000084"
            CASE SC5->C5_FILIAL == "02"
                 SC5->C5_VEND1 := "000085"
            CASE SC5->C5_FILIAL == "03"
                 SC5->C5_VEND1 := "000086"                         
         ENDCASE

         // ########################################################################
         // Atualiza o campo C5_MENNOTA com os dados informados no campo AB6_MENT ##
         // ########################################################################
         cString := ""
         cString := Alltrim(T_PEDIDO->MENSAGEM) + chr(13) + chr(10) 
         cString += M->AB6_MENT

         SC5->C5_MENNOTA := cString

         MsunLock()

      Endif
               
   Endif

   // #############################################################################
   // Grava na tabela ZZZ o Nº e a Filial do pedido de venda para a OS efetivada ##
   // #############################################################################
   T_PEDIDO->( DbGoTop() )
	
   WHILE !T_PEDIDO->( Eof() )

      DbSelectArea("ZZZ")
	  DbSetOrder(1)
		
	  If DbSeek(T_PEDIDO->C6_FILIAL + M->AB6_NUMOS + T_PEDIDO->C6_PRODUTO)
			
	  	 Reclock("ZZZ", .F.)
		 ZZZ->ZZZ_NUMPV := T_PEDIDO->C6_NUM
		 ZZZ->ZZZ_NUMFL := T_PEDIDO->C6_FILIAL
		 MsunLock()
			
  	  Endif
		 
	  T_PEDIDO->( DbSkip() )
		 
   ENDDO	 

   // Verifica se existe parametrização de TES pelo cadastro de serviço da Tabela AB8 - Apontamentos de Ordens de Serviço

   // Pesquisa o Estado da Empresa/Filial Logada
   dbSelectArea("SM0")
   SM0->( DbSeek( cEmpAnt + cFilAnt ) )

   elogado := SM0->M0_ESTENT
   eCGC    := SM0->M0_CGC   

   // Pesquisa se existem parametrização de TES por serviço
   If Select("T_SERVICOS") > 0
      T_SERVICOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AB8.AB8_FILIAL,"
   cSql += "       AB8.AB8_NUMOS ,"
   cSql += "       AB8.AB8_CODSER,"
   cSql += "       AB8.AB8_CODPRO,"
   cSql += "       AB8.AB8_CODCLI," 
   cSql += "       AB8.AB8_LOJA  ," 
   cSql += "       AB8.AB8_NUMPV ,"
   cSql += "       SA1.A1_EST    ,"
   cSql += "       SB1.B1_GRTRIB ,"
   cSql += "       ZP6.ZP6_TES   ,"
   cSql += "       ZP6.ZP6_TES2  ,"
   cSql += "       ZP6.ZP6_FATU   "
   cSql += "  FROM " + RetSqlName("AB8") + " AB8 (NOLOCK), " 
   cSql += "       " + RetSqlName("SB1") + " SB1 (NOLOCK), "
   cSql += "       " + RetSqlName("ZP6") + " ZP6 (NOLOCK), "
   cSql += "       " + RetSqlName("SA1") + " SA1 (NOLOCK)  "
   cSql += " WHERE AB8.AB8_FILIAL = '" + Alltrim(cFilAnt)      + "'"
   cSql += "   AND AB8.AB8_NUMOS  = '" + ALLTRIM(M->AB6_NUMOS) + "'"
   cSql += "   AND AB8.D_E_L_E_T_ = ''            "
   cSql += "   AND SB1.B1_COD     = AB8.AB8_CODPRO"
   cSql += "   AND SB1.D_E_L_E_T_ = ''            "
   cSql += "   AND ZP6.ZP6_SERV   = AB8.AB8_CODSER"
   cSql += "   AND ZP6.ZP6_GRUP   = SB1.B1_GRTRIB "
   cSql += "   AND AB8.AB8_CODCLI = SA1.A1_COD    "
   cSql += "   AND AB8.AB8_LOJA   = SA1.A1_LOJA   "
   cSql += "   AND SA1.D_E_L_E_T_ = ''            "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SERVICOS", .T., .T. )

   // Verifica se há a necessidade de trocar o código do cliente no pedido de venda para o código da Automatech
   // Se pelo menos um dos serviços estiver marcado para faturar como Automatech, vai valer esta indicação   

   T_SERVICOS->( DbGoTop() )

   lTroca := .F.
   
   // ----------------------------------------------------------------------------- //
   // Card 3010 -  AUTOMATECH - Alteração de Regra Cliente no Pedido de Venda da OS //
   // Alterado por Harald Hans Löschenkohl em 18/05/2021                            //
   // ----------------------------------------------------------------------------- //
   // Conforme solicitação do Cliente, não será mais utilizado o faturamento contra //
   // a Automatech em caso de localização de parametrização de TEs na tabela ZP6.   //
   // ----------------------------------------------------------------------------- //
   //   WHILE !T_SERVICOS->( EOF() )
   //   
   //      If T_SERVICOS->ZP6_FATU == "1"
   //         lTroca := .T.
   //         Exit
   //      Endif
   //         
   //      T_SERVICOS->( DbSkip() )
   //      
   //   ENDDO

   // Troca as TES conforme parametrização
   T_SERVICOS->( DbGoTop() )
   
   WHILE !T_SERVICOS->( EOF() )

      // Para Dentro do Estado
      If Alltrim(T_SERVICOS->A1_EST) == Alltrim(eLogado)

         If Alltrim(T_SERVICOS->ZP6_TES) == ""
         Else

            cCodFL := T_SERVICOS->AB8_FILIAL
            cCodPV := T_SERVICOS->AB8_NUMPV

            cSql := ""
            cSql := "UPDATE " + RetSqlName("SC6")
            cSql += "   SET "
            cSql += "   C6_TES = '" + Alltrim(T_SERVICOS->ZP6_TES)             + "'"

            // ----------------------------------------------------------------------------- //
            // Card 3010 -  AUTOMATECH - Alteração de Regra Cliente no Pedido de Venda da OS //
            // Alterado por Harald Hans Löschenkohl em 18/05/2021.                           // 
            // ----------------------------------------------------------------------------- //
            // Conforme solicitação do Cliente, não será mais utilizado o faturamento contra //
            // a Automatech em caso de localização de parametrização de TEs na tabela ZP6.   //
            // ----------------------------------------------------------------------------- //
            // Troca o Cliente nos ítens do pedido de venda
            // If lTroca == .T.
            //
            //    // Pesquisa os dados da Automatech para gravação no cabeçalho da Ordem de Serviço
            //    eCliente := Posicione("SA1", 3, xFilial("SA1") + eCGC, "A1_COD")
            //    eLoja    := Posicione("SA1", 3, xFilial("SA1") + eCGC, "A1_LOJA")
            //
            //    cSql += " , C6_CLI  = '" + Alltrim(eCliente) + "', "
            //    cSql += "   C6_LOJA = '" + Alltrim(eLoja)    + "'  "
            // 
            // Endif

            cSql += " WHERE C6_NUMOS LIKE '" + ALLTRIM(M->AB6_NUMOS)           + "%'"
            cSql += "   AND C6_FILIAL   = '" + Alltrim(cFilAnt)                + "'"
            cSql += "   AND C6_PRODUTO  = '" + Alltrim(T_SERVICOS->AB8_CODPRO) + "'"
            cSql += "   AND C6_CLI      = '" + Alltrim(T_SERVICOS->AB8_CODCLI) + "'"
            cSql += "   AND C6_LOJA     = '" + Alltrim(T_SERVICOS->AB8_LOJA)   + "'"
            cSql += "   AND D_E_L_E_T_  = ''"

            lResult := TCSQLEXEC(cSql)
            If lResult < 0
               Return MsgStop("Erro durante a gravação da TES parametrizada. Verifique Pedido de Venda se as TES estao corretas: " + TCSQLError())
            EndIf 
         Endif

      Else
      
         If Alltrim(T_SERVICOS->ZP6_TES2) == ""
         Else
            cSql := ""
            cSql := "UPDATE " + RetSqlName("SC6")
            cSql += "   SET "
            cSql += "   C6_TES = '" + Alltrim(T_SERVICOS->ZP6_TES2)            + "'"

            // ----------------------------------------------------------------------------- //
            // Card 3010 -  AUTOMATECH - Alteração de Regra Cliente no Pedido de Venda da OS //
            // Alterado por Harald Hans Löschenkohl em 18/05/2021                            //
            // ----------------------------------------------------------------------------- //
            // Conforme solicitação do Cliente, não será mais utilizado o faturamento contra //
            // a Automatech em caso de localização de parametrização de TEs na tabela ZP6.   //
            // ----------------------------------------------------------------------------- //
            // Troca o Cliente nos ítens do pedido de venda
            // If lTroca == .T.
            //
            //    // Pesquisa os dados da Automatech para gravação no cabeçalho da Ordem de Serviço
            //    eCliente := Posicione("SA1", 3, xFilial("SA1") + eCGC, "A1_COD")
            //    eLoja    := Posicione("SA1", 3, xFilial("SA1") + eCGC, "A1_LOJA")
            //
            //    cSql += " , C6_CLI  = '" + Alltrim(eCliente) + "', "
            //    cSql += "   C6_LOJA = '" + Alltrim(eLoja)    + "'  "
            //
            // Endif

            cSql += " WHERE C6_NUMOS LIKE '" + ALLTRIM(M->AB6_NUMOS)           + "%'"
            cSql += "   AND C6_FILIAL   = '" + Alltrim(cFilAnt)                + "'"
            cSql += "   AND C6_PRODUTO  = '" + Alltrim(T_SERVICOS->AB8_CODPRO) + "'"
            cSql += "   AND C6_CLI      = '" + Alltrim(T_SERVICOS->AB8_CODCLI) + "'"
            cSql += "   AND C6_LOJA     = '" + Alltrim(T_SERVICOS->AB8_LOJA)   + "'"
            cSql += "   AND D_E_L_E_T_  = ''"

            lResult := TCSQLEXEC(cSql)
            If lResult < 0
               Return MsgStop("Erro durante a gravação da TES parametrizada. Verifique Pedido de Venda se as TES estao corretas: " + TCSQLError())
            EndIf 
         Endif
      
      Endif

      // ----------------------------------------------------------------------------- //
      // Card 3010 -  AUTOMATECH - Alteração de Regra Cliente no Pedido de Venda da OS //
      // Alterado por Harald Hans Löschenkohl em 18/05/2021                            //
      // ----------------------------------------------------------------------------- //
      // Conforme solicitação do Cliente, não será mais utilizado o faturamento contra //
      // a Automatech em caso de localização de parametrização de TEs na tabela ZP6.   //
      // ----------------------------------------------------------------------------- //
      // Altera o código do cliente no pedido de venda se este foi indicado a ser alterado
      // If lTroca == .T.
      // 
      //    // Pesquisa os dados da Automatech para gravação no cabeçalho da Ordem de Serviço
      //    eCliente := Posicione("SA1", 3, xFilial("SA1") + eCGC, "A1_COD")
      //    eLoja    := Posicione("SA1", 3, xFilial("SA1") + eCGC, "A1_LOJA")
      // 
      //    // Troca o código do cliente no pedido de venda conforme parametrização
      //    If Empty(Alltrim(eCliente))
      //       eCliente := Space(06)
      //       eLoja    := Space(03)
      //    Else
      // 
      //       DbSelectArea("SC5")
      //       DbSetOrder(1)
      //          
      //       If DbSeek(cCodFL + cCodPV)
      // 
      //          Reclock("SC5",.f.)
      //          SC5->C5_CLIENTE := eCliente         
      //          SC5->C5_LOJACLI := eLoja
      //          SC5->C5_CLIENT  := eCliente         
      //          SC5->C5_LOJAENT := eLoja
      //          MsunLock()
      // 
      //      Endif
      //      
      //   Endif
      //   
      //Endif   

      T_SERVICOS->( DbSkip() )
      
   ENDDO

Return(.T.)
