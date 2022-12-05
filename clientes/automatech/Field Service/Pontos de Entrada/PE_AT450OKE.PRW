#Include "Protheus.ch"
#INCLUDE "topconn.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AT450OKE.PRW                                                        ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 10/10/2011                                                          ##
// Objetivo..: Ponto de Entrada que verifica se a OS selecionada poderá se efeti-  ##
//             vada conforme regra abaixo:                                         ##
//             ------------------------------------------------------------------  ##
//             1º) Somente poderá ser efetivada OS que possuirem pelo menos um a-  ##
//                 pontamento realizado.                                           ##
//             2º) Somente poderá ser efetivada OS que estiverem  com  o campo da  ##
//                 tabela AB7 (AB7_STATUS) com o conteúdo B - OS Atendida.         ##
// Parâmetros: Sem Parâmetros                                                      ##
// Retorno...: .T./.F.                                                             ##
// ##################################################################################

User Function AT450OKE()

   Local _aArea     := GetArea()
   Local _aAreaSC5  := GetArea()
   Local cSql       := ""
   Local cCodPV     := ""
   Local cCodFL     := ""
   Local lSaldo     := .T.
   Local lServico   := .F.
   Local lServico50 := .T.
   
   Local _cQuery := ""
   Local _cQueryE:= ""
   
   Public _lEfetiva:= .F. //controle efetiva Os 0% cliente 0% fabricante
   
//   If MV_PAR05 <> MV_PAR06
//	  MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + "Nº de OS informada para pesquisa são diferentes." + chr(13) + Chr(10) + "Verifique!")
//	  Return(.F.)
//   Endif

   If Empty(Alltrim(AB7->AB7_FILIAL))
	  Return .T.
   Endif                                  

//   If Select("T_STATUS") > 0
//      T_STATUS->( dbCloseArea() )
//   EndIf

//   cSql := ""
//   cSql := "SELECT AB6_STATUS " 
//   cSql += "  FROM " + RetSqlName("AB6010")
//   cSql += " WHERE AB6_NUMOS  = '" + Alltrim(AB7->AB7_NUMOS)  + "'"
//   cSql += "   AND AB6_FILIAL = '" + Alltrim(AB7->AB7_FILIAL) + "'" 

//   cSql := ChangeQuery( cSql )
//   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_STATUS", .T., .T. )

//   If !T_STATUS->( Eof() )
//
//      IF ALLTRIM(UPPER(T_STATUS->AB6_STATUS)) <> "B"
//         MsgAlert("ATENÇÃO !!" + chr(13) + chr(13) + "O.S. não poderá ser efetivada pois a mesma ainda não foi ATENDIDA.")
//         Return .F.
//      Endif
//   Endif

   // ########################################################################
   // Verifica se apontamentos possuem saldo disponível antes da efetivação ##
   // ########################################################################
   If Select("T_APONTAMENTO") > 0
	  T_APONTAMENTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT A.AB8_FILIAL,"                                    + CHR(13)
   cSql += "       A.AB8_NUMOS ,"                                    + CHR(13)
   cSql += "       A.AB8_CODPRO,"                                    + CHR(13)
   cSql += "       A.AB8_CODSER,"                                    + CHR(13)
   cSql += "       A.AB8_ITEM  ,"                                    + CHR(13)
   cSql += "       A.AB8_QUANT ,"                                    + CHR(13)
   cSql += "       B.B1_TIPO   ,"                                    + CHR(13)
   cSql += "       B.B1_DESC    "                                    + CHR(13)
   cSql += "  FROM " + RetSqlName("AB8") + " A, "                    + CHR(13)
   cSql += "       " + RetSqlName("SB1") + " B  "                    + CHR(13)
   cSql += " WHERE A.AB8_FILIAL = '" + Alltrim(AB7->AB7_FILIAL) + "'" + CHR(13)
// cSql += "   AND A.AB8_NUMOS  = '" + Alltrim(AB7->AB7_NUMOS)  + "'" + CHR(13)
   cSql += "   AND A.AB8_NUMOS  = '" + Alltrim(MV_PAR05)             + "'" + CHR(13)
   cSql += "   AND A.D_E_L_E_T_ = ''      "                          + CHR(13)
   cSql += "   AND A.AB8_CODPRO = B.B1_COD"                          + CHR(13)
   cSql += "   AND B.B1_FILIAL  = ''      "                          + CHR(13)
   cSql += "   AND B.D_E_L_E_T_ = ''      "                          + CHR(13)

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_APONTAMENTO", .T., .T. )

   If T_APONTAMENTO->( EOF() )
	  MsgAlert("Atenção! Não houve informação de apontamento. Efetivação não permitida.")      
	  RestArea(_aArea)
	  RestArea(_aAreaSC5)
	  Return(.F.)
   Endif
	  
   T_APONTAMENTO->( DbGoTop() )

   lSaldo := .T.
   
   WHILE !T_APONTAMENTO->( EOF() )
   
	  If Alltrim(T_APONTAMENTO->B1_TIPO) <> "PA"
		 T_APONTAMENTO->( DbSkip() )
		 Loop
	  Endif
   
	  If T_APONTAMENTO->AB8_CODSER == "000056"
		 T_APONTAMENTO->( DbSkip() )
		 Loop
	  Endif

      // ########################################
	  // Pesquisa o saldo do produto informado ##
	  // ########################################
	  If Select("T_SALDO") > 0
		 T_SALDO->( dbCloseArea() )
	  EndIf
	  
	  cSql := ""
	  cSql := "SELECT SUM(B2_QATU) AS SALDO "
	  cSql += "  FROM " + RetSqlName("SB2")
	  cSql += " WHERE B2_FILIAL    = '" + Alltrim(T_APONTAMENTO->AB8_FILIAL) + "'"
	  cSql += "   AND B2_COD       = '" + Alltrim(T_APONTAMENTO->AB8_CODPRO) + "'"
	  cSql += "   AND R_E_C_D_E_L_ = ''"

	  cSql := ChangeQuery( cSql )
	  dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_SALDO", .T., .T. )

	  If T_SALDO->( EOF() )
		 MsgAlert("ATENÇÃO !!" + Chr(13) + Chr(13) + "Não existe saldo disponível para o produto " + Alltrim(T_APONTAMENTO->AB8_CODPRO) + " - " + Alltrim(T_APONTAMENTO->B1_DESC))
		 lSaldo := .F.
		 Exit
	  Endif
   
	  If T_APONTAMENTO->AB8_QUANT > T_SALDO->SALDO 
		 MsgAlert("ATENÇÃO !!" + Chr(13) + Chr(13) + "Quantidade informada é superior ao saldo disponível do produto." + CHR(13) + Alltrim(T_APONTAMENTO->AB8_CODPRO) + " - " + Alltrim(T_APONTAMENTO->B1_DESC) + chr(13) + chr(13) + "Quantidade Informada: " + Str(T_APONTAMENTO->AB8_QUANT,10,02) + Chr(13) + "Saldo Disponível: " + Str(T_SALDO->SALDO,10,02))
		 lSaldo := .F.
		 Exit
	  Endif
	  
	  T_APONTAMENTO->( DbSkip() )
	  
   ENDDO
   
   // ############################################################
   // VERIFICANDO SE EXISTE SERVICOS 0% CLIENTE E 0% FABRICANTE ##
   // ############################################################ 
   _cQuery := " SELECT * "+ CHR(13) 
   _cQuery += " FROM " + RetSqlName("AB8") + " AB8 WITH(NOLOCK) " + CHR(13)
   _cQuery += " INNER JOIN " + RetSqlName("AA5") + " AA5 WITH(NOLOCK) " + CHR(13)
   _cQuery += " ON AA5.AA5_CODSER = AB8.AB8_CODSER AND AA5.D_E_L_E_T_ = ''  "+ CHR(13) //AND AA5.AA5_PRCCLI > 0  AND AA5.AA5_PRCFAB > 0 
   _cQuery += " WHERE AB8.D_E_L_E_T_ = '' AND AB8.AB8_NUMOS = '"+AB6->AB6_NUMOS+"' AND AB8_FILIAL = '"+AB6->AB6_FILIAL+"' "+ CHR(13)

   If( Select( "TMPAB8" ) <> 0 )
     TMPAB8->( DbCloseArea() )
   EndIf

   TcQuery _cQuery New Alias "TMPAB8"

   DbSelectArea("TMPAB8")
   TMPAB8->(dbGoTop())
   If !TMPAB8->( EOF() ) 
	  If lSaldo 
		
		 //NAO PODE SER ALTERADO AB6->AB6_STATUS NESSE PONTO DE ENTRADA (ROTINA PADRAO VALIDA COM A QUERY TESTANDO O RESGISTRO AB6_STATUS = 'B')
		 // -> (CONTROLE _lEfetiva = .T. - ALTERACAO EXECUTADA NO PE = AT450GRV - PE_TECA450.PRW)
		 _lEfetiva:= .T.
		
		 /*
		 DBSelectArea("AB6")
		 RecLock("AB6",.F.)
		 AB6->AB6_STATUS := "E"
		 AB6->(MsUnlock())
		 */ 
		
	  EndIf
   EndIf	 
	  
   RestArea(_aArea)
   RestArea(_aAreaSC5)

   If !lSaldo
	  Return(.F.)
   Endif

   // #######################################################################################################################
   // Tarefa #3372 -Ajustes Armazéns Técnicos e Procedimentos Estoque                                                      ##
   // -------------------------------------------------------------------------------------------------------------------- ##
   // No momento da efetivação da Ordem de Serviço se tiver o serviço 000056, deve ser verificado na tabela ZZZ            ## 
   // se esta foi atendida, ou seja, na tabela ZZZ o campo SALDO se estiver = 0 (Está atendido) não permitir a efetivação. ##
   // #######################################################################################################################
   T_APONTAMENTO->( DbGoTop() )

   lServico := .F.
   
   WHILE !T_APONTAMENTO->( EOF() )
   
      If T_APONTAMENTO->AB8_CODSER == "000056"

   	     If Select("T_DEVOLVEU") > 0
		    T_DEVOLVEU->( dbCloseArea() )
   	     EndIf

         cSql := ""
         cSql := "SELECT ZZZ_SALDO  "
         cSql += "  FROM " + RetSqlName("ZZZ")
         cSql += " WHERE ZZZ_FILIAL   = '" + Alltrim(AB7->AB7_FILIAL) + "'"
         cSql += "   AND ZZZ_NUMOS  = '" + Alltrim(MV_PAR05)        + "'"
         cSql += "   AND ZZZ_PRODUT = '" + Alltrim(T_APONTAMENTO->AB8_CODPRO) + "'"
         cSql += "   AND ZZZ_ITAB8  = '" + Alltrim(T_APONTAMENTO->AB8_ITEM)   + "'"
         cSql += "   AND D_E_L_E_T_ = ''"

         cSql := ChangeQuery( cSql )
         dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_DEVOLVEU", .T., .T. )

         IF T_DEVOLVEU->( EOF() )
            lServico := .F.
         Else
            If T_DEVOLVEU->ZZZ_SALDO == 0
               lServico := .T.
               Exit
            Else
               lServico := .F.               
            Endif
         Endif
               
      Endif
      
      T_APONTAMENTO->( DbSkip() )
      
   ENDDO

   If lServico == .T.
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Esta Ordem de Serviço possui apontamento(s) reprovado(s) pelo Cliente"       + chr(13) + chr(10) + ;
               "porém, a(s) peça(s) desta reprovação ainda não foram devolvidas ao estoque." + chr(13) + chr(10) + ;
               "Efeitivação não será concluída em razão disso. Verifique!")   
      Return(.F.)
   Endif

   // ########################################################################################################################
   // Tarefa #3372 -Ajustes Armazéns Técnicos e Procedimentos Estoque                                                       ##
   // --------------------------------------------------------------------------------------------------------------------- ##
   // somente poderá ser efetivada ordens de serviço que no apontamento de peças tenham a informação dos serviços de código ## 
   // 000003, 000049,000061, 000056                                                                                         ##   
   // #######################################################################################################################
   If Select("T_VERSERVICOS") > 0
      T_VERSERVICOS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AB8.AB8_FILIAL,
   cSql += "       AB8.AB8_NUMOS ,
   cSql += "       AB8.AB8_ITEM  ,
   cSql += "       AB8.AB8_CODPRO,
   cSql += "       AB8.AB8_CODSER,
   cSql += "       SB1.B1_TIPO
   cSql += "  FROM " + RetSqlName("AB8") + " AB8, "
   cSql += "       " + RetSqlName("SB1") + " SB1  "
   cSql += " WHERE AB8.AB8_FILIAL = '" + Alltrim(AB7->AB7_FILIAL) + "'"
   cSql += "   AND AB8.AB8_NUMOS  = '" + Alltrim(MV_PAR05)        + "'"
   cSql += "   AND AB8.D_E_L_E_T_ = ''"
   cSql += "   AND SB1.B1_COD     = AB8.AB8_CODPRO"
   cSql += "   AND SB1.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VERSERVICOS", .T., .T. )

   T_VERSERVICOS->( DbGoTop() )

   lServico := .F.
   
   WHILE !T_VERSERVICOS->( EOF() )
   
      If Alltrim(T_VERSERVICOS->B1_TIPO) == "MO"
      Else

         If Alltrim(T_VERSERVICOS->AB8_CODSER)$("000003#000049#000061#000056#000007#000006")
            lServico := .F.
         Else
            lServico := .T.
            Exit
         Endif

      Endif

      T_VERSERVICOS->( DbSkip() )         

   ENDDO

   If lServico == .T.
      MsgAlert("Atenção!" + chr(13) + chr(10) + chr(13) + chr(10) + ;
               "Esta Ordem de Serviço possui apontamento(s) de peças" + chr(13) + chr(10) + ;
               "com indicação de serviços inconsistentes."            + chr(13) + chr(10) + ;
               "Códigos permitidos: 000003, 000049, 000061,000056,000006 e 000007. Verifique!")   
      Return(.F.)
   Endif

   // ##########################################################################################
   // Tarefa #3182 - Validação do campo Pagamento Antecipado                                  ##
   // Se Pagamento Antecipado Com PV, apontamento necessariamente deve haver o serviço 000050 ##
   // ##########################################################################################
   If Select("T_PAGAMENTO") > 0
      T_PAGAMENTO->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AB6_PANT, " 
   cSql += "       AB6_PVAN  "
   cSql += "  FROM " + RetSqlName("AB6010")
   cSql += " WHERE AB6_NUMOS  = '" + Alltrim(AB7->AB7_NUMOS)  + "'"
   cSql += "   AND AB6_FILIAL = '" + Alltrim(AB7->AB7_FILIAL) + "'" 
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PAGAMENTO", .T., .T. )

   // #####################################################################
   // Se pagamento antecipado com pedido de venda, verifica apontamentos ##
   // #####################################################################
   If T_PAGAMENTO->AB6_PANT == "C"

      If Select("T_APONTAMENTO") > 0
         T_APONTAMENTO->( dbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT A.AB8_FILIAL,"                                     + CHR(13)
      cSql += "       A.AB8_NUMOS ,"                                     + CHR(13)
      cSql += "       A.AB8_CODPRO,"                                     + CHR(13)
      cSql += "       A.AB8_CODSER,"                                     + CHR(13)
      cSql += "       A.AB8_ITEM  ,"                                     + CHR(13)
      cSql += "       A.AB8_QUANT ,"                                     + CHR(13)
      cSql += "       B.B1_TIPO   ,"                                     + CHR(13)
      cSql += "       B.B1_DESC    "                                     + CHR(13)
      cSql += "  FROM " + RetSqlName("AB8") + " A, "                     + CHR(13)
      cSql += "       " + RetSqlName("SB1") + " B  "                     + CHR(13)
      cSql += " WHERE A.AB8_FILIAL = '" + Alltrim(AB7->AB7_FILIAL) + "'" + CHR(13)
      cSql += "   AND A.AB8_NUMOS  = '" + Alltrim(MV_PAR05)              + "'" + CHR(13)
      cSql += "   AND A.D_E_L_E_T_ = ''      "                           + CHR(13)
      cSql += "   AND A.AB8_CODPRO = B.B1_COD"                           + CHR(13)
      cSql += "   AND B.B1_FILIAL  = ''      "                           + CHR(13)
      cSql += "   AND B.D_E_L_E_T_ = ''      "                           + CHR(13)

      cSql := ChangeQuery( cSql )
      dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_APONTAMENTO", .T., .T. )

      lServico50 := .T.
      
      T_APONTAMENTO->( DbGoTop() )
      
      WHILE !T_APONTAMENTO->( EOF() )
      
         If T_APONTAMENTO->AB8_CODSER == "000050"
         Else
            lServico50 := .F.
            Exit
         Endif
         
         T_APONTAMENTO->( DbSkip() )
         
      ENDDO
      
      If lServico50 == .F.
         MsgAlert("Atenção!"                                                                         + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "O pagamento desta OS foi realizado antecipadamente com Pedido de Venda, porém,"   + chr(13) + chr(10)                     + ;
                  "o(s) apontamento(s) desta estão inconsistentes. (Serviços diferentes de 000050)." + chr(13) + chr(10) + chr(13) + chr(10) + ;
                  "Efetivação não permitida. Verifique!")
         Return(.F.)
      Endif            
         
   Endif

Return(.T.)
