#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AT_ATUALIZAPONTA.PRW                                                ##
// Par�metros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                             ##
// Data......: 17/11/2016                                                          ##
// Objetivo..: Web Service que grava os apontamentos da Ordem de Servi�o do App AT ##
// Par�metros: cParametros                                                         ##
//             01 - Opera��o (I - Inclus�o, A - Altera��o)                         ##                                                       
//             02 - C�digo da Empresa                                              ##
//             03 - C�digo da Filial                                               ##
//             04 - C�digo da OS                                                   ##
//             05 - Seq Item                                                       ##
//             06 - C�digo do Produto                                              ##
//             07 - Nome Produto                                                   ##
//             08 - Codigo Servico                                                 ##
//             09 - Quantidade                                                     ##
//             10 - Unitario                                                       ##
//             11 - Total                                                          ##
//             12 - Pre�o Lista                                                    ##
//             13 - Codigo Cliente                                                 ##
//             14 - Loja Cliente                                                   ##
//             15 - Produto Base                                                   ##
//             16 - Numero Serie                                                   ##
//             17 - SubItem                                                        ##
//             18 - T�cnico                                                        ##
// ##################################################################################
WSRESTFUL AT_ATUALIZAPONTA DESCRIPTION "Advpl Tools - Service Get OS"

	WSDATA cCodPar AS STRING
	
	WSMETHOD GET DESCRIPTION "Advpl Tools - Service Get OS" WSSYNTAX "/AT_ATUALIZAPONTA || /AT_ATUALIZAPONTA/{cCodPar}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE cCodPar WSSERVICE AT_ATUALIZAPONTA

   Local cSql     := ""
   Local cRetorno := ""
   Local cString  := ""
   Local nContar  := 0

   // ###################################
   // Carrega as vari�veis de trabalho ##
   // ###################################
   cCodOpe := U_P_CORTA(Self:cCodPar, "|", 01)
   cCodEmp := U_P_CORTA(Self:cCodPar, "|", 02)
   cCodFil := U_P_CORTA(Self:cCodPar, "|", 03)
   cCodOrd := U_P_CORTA(Self:cCodPar, "|", 04)
   cCodIte := U_P_CORTA(Self:cCodPar, "|", 05)
   cCodPro := U_P_CORTA(Self:cCodPar, "|", 06)
   cCodNom := U_P_CORTA(Self:cCodPar, "|", 07)
   cCodSer := U_P_CORTA(Self:cCodPar, "|", 08)
   cCodQua := U_P_CORTA(Self:cCodPar, "|", 09)
   cCodUni := U_P_CORTA(Self:cCodPar, "|", 10)
   cCodTot := U_P_CORTA(Self:cCodPar, "|", 11)
   cCodLis := U_P_CORTA(Self:cCodPar, "|", 12)
   cCodCli := U_P_CORTA(Self:cCodPar, "|", 13)
   cCodLoj := U_P_CORTA(Self:cCodPar, "|", 14)
   cCodBas := U_P_CORTA(Self:cCodPar, "|", 15)
   cCodNse := U_P_CORTA(Self:cCodPar, "|", 16)
   cCodSeq := U_P_CORTA(Self:cCodPar, "|", 17)
   cCodTec := U_P_CORTA(Self:cCodPar, "|", 18)

   // ##################################################################################
   // Se pre�o de lista for igual a zero, iguala o pre�o de lista pelo pre�o unit�rio ##
   // ##################################################################################
   If Val(cCodLis) == 0
      cCodLis := cCodUni
   Endif    

   // #####################################################################
   // Display dos valores dos par�metros no Web Service para confer�ncia ##
   // #####################################################################
   Conout("Operacao......:" + cCodOpe)
   Conout("Empresa.......:" + cCodEmp)
   Conout("Filial........:" + cCodFil)
   Conout("Ordem Servico.:" + cCodOrd)
   Conout("Item..........:" + cCodIte)
   Conout("Produto.......:" + cCodPro)
   Conout("Nome Produto..:" + cCodNom)
   Conout("Cod Servico...:" + cCodSer)
   Conout("Quantidade....:" + cCodQua)
   Conout("Unitario......:" + cCodUni)
   Conout("Total.........:" + cCodTot)
   Conout("Preco Lista...:" + cCodLis)
   Conout("Codigo Cliente:" + cCodCli)
   Conout("Loja Cliente..:" + cCodLoj)
   Conout("Produto Base..:" + cCodBas)
   Conout("Numero Serie..:" + cCodNse)
   Conout("Sequencia.....:" + cCodSeq)
   Conout("Codigo Tecnico:" + cCodTec)

   // ##########################
   // Inclus�o de Apontamento ##
   // ##########################
   If cCodOpe == "I"

      // ######################################################
      // Pesquisa a pr�xima sequencia de inclus�o do subitem ##
      // ######################################################
      If (Select( "T_SEQUENCIA" ) != 0 )
         T_SEQUENCIA->( DbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT TOP(1) AB8_SUBITE"

      Do Case
         Case cCodEmp == "01"
              cSql += "  FROM AB8010"
         Case cCodEmp == "02"
              cSql += "  FROM AB8020"
         Case cCodEmp == "03"
              cSql += "  FROM AB8030"
      EndCase        
              
      cSql += " WHERE AB8_FILIAL = '" + Alltrim(cCodFil) + "'"
      cSql += "   AND AB8_NUMOS  = '" + Alltrim(cCodOrd) + "'"
//    cSql += "   AND D_E_L_E_T_ = ''"
      cSql += " ORDER BY AB8_SUBITE DESC"

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_SEQUENCIA",.T.,.T.)

      cSubItem := IIF(T_SEQUENCIA->( EOF() ), "01", STRZERO((INT(VAL(T_SEQUENCIA->AB8_SUBITE)) + 1),2))

   Conout("Sequencia da tabela AB8:" + cSubItem)


      // #####################################
      // Inclui o Apontamento na tabela AB8 ##
      // #####################################
      DbSelectArea("AB8")
	  DbSetOrder(1)
					
	  RecLock("AB8",.T.)
      AB8->AB8_FILIAL := cCodFil 
      AB8->AB8_NUMOS  := cCodOrd
      AB8->AB8_ITEM   := cCodIte
      AB8->AB8_CODPRO := cCodPro
      AB8->AB8_DESPRO := cCodNom
      AB8->AB8_CODSER := cCodSer
      AB8->AB8_QUANT  := Int(Val(cCodQua))
      AB8->AB8_VUNIT  := Val(cCodUni)
      AB8->AB8_TOTAL  := Val(cCodTot)
      AB8->AB8_ENTREG := Date()
      AB8->AB8_PRCLIS := Val(cCodLis)
      AB8->AB8_CODCLI := cCodCli
      AB8->AB8_LOJA   := cCodLoj
      AB8->AB8_CODPRD := cCodBas
      AB8->AB8_NUMSER := cCodNse
      AB8->AB8_TIPO   := "1"
      AB8->AB8_LOCAL  := "01"
      AB8->AB8_SUBITE := cSubItem
      MsUnlock()

      // ###########################################################
      // Pesquisa a pr�xima sequencia da tabela ZZZ para inclus�o ##
      // ###########################################################
      If (Select( "T_SEQUENCIA" ) != 0 )
         T_SEQUENCIA->( DbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT TOP(1) ZZZ_ITEM"

      Do Case
         Case cCodEmp == "01"
              cSql += "  FROM ZZZ010"
         Case cCodEmp == "02"
              cSql += "  FROM ZZZ020"
         Case cCodEmp == "03"
              cSql += "  FROM ZZZ030"
      EndCase        
              
      cSql += " WHERE ZZZ_FILIAL = '" + Alltrim(cCodFil) + "'"
      cSql += "   AND ZZZ_NUMOS  = '" + Alltrim(cCodOrd) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"
      cSql += " ORDER BY ZZZ_ITEM DESC"

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_SEQUENCIA",.T.,.T.)

      cCodIte := IIF(T_SEQUENCIA->( EOF() ), "01", STRZERO((INT(VAL(T_SEQUENCIA->ZZZ_ITEM)) + 1),2))

      // ##############################
      // Inclui a requisi��o da pe�a ##
      // ##############################
      For nContar = 1 to Int(Val(cCodQua))

          DbSelectArea("ZZZ")
	      DbSetOrder(2)
 	      RecLock("ZZZ",.T.)
 	      ZZZ->ZZZ_FILIAL := cCodFil
 	      ZZZ->ZZZ_NUMOS  := cCodOrd
	      ZZZ->ZZZ_TECNIC := cCodTec
	      ZZZ->ZZZ_EMISSA := Date()
	      ZZZ->ZZZ_ITEM   := cCodIte
	      ZZZ->ZZZ_ITAB8  := cSubItem
	      ZZZ->ZZZ_LOCAL  := "01"
	      ZZZ->ZZZ_PRODUT := cCodPro
	      ZZZ->ZZZ_QUANT  := 1
	      ZZZ->ZZZ_QTDORI := Int(Val(cCodQua))
	      ZZZ->ZZZ_SALDO  := 1
	      ZZZ->ZZZ_STATUS := "A"
	      MsUnlock()
	      
          cCodIte := Strzero((Int(Val(cCodIte)) + 1),2)
	      
	  Next nContar    

      // ######################
      // Retorno da inclus�o ##
      // ######################
      cString := "0|Lancamento com Sucesso|"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)

   Endif

   // ######################################
   // Altera��o do Apontamento/Requisi��o ##
   // ######################################
   If cCodOpe == "A"

      // ###########################################
      // Verifica se lan�amento pode ser alterado ##
      // ###########################################
      If (Select( "T_PODEALTERAR" ) != 0 )
         T_PODEALTERAR->( DbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZZ_STATUS"
      cSql += "  FROM ZZZ010 ZZZ(NoLock) "
	  cSql += " WHERE ZZZ_FILIAL  = '" + Alltrim(cCodFil) + "'"
	  cSql += "   AND ZZZ_NUMOS   = '" + Alltrim(cCodOrd) + "'"
	  cSql += "   AND ZZZ_PRODUT  = '" + Alltrim(cCodPro) + "'"
	  cSql += "   AND ZZZ_STATUS <> 'A'"
	  cSql += "   AND D_E_L_E_T_ <> '*' "

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PODEALTERAR",.T.,.T.)

   	  If !T_PODEALTERAR->( Eof() )
         cString := "4|Nao permitido alteracao por ja ter movimento de requisicao para o produto.|"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         Return(.T.)
      Endif

      // ############################################################## 
      // Exclui lan�amento na tabela ZZZ para realizar nova inclus�o ##
      // ##############################################################
      cSql := ""      

      Do Case
         Case cCodEmp == "01"
              cSql := "UPDATE ZZZ010 SET D_E_L_E_T_ = '*' "
         Case cCodEmp == "02"
              cSql := "UPDATE ZZZ020 SET D_E_L_E_T_ = '*' "
         Case cCodEmp == "03"
              cSql := "UPDATE ZZZ030 SET D_E_L_E_T_ = '*' "
      EndCase           

 	  cSql += "WHERE ZZZ_FILIAL  = '" + Alltrim(cCodFil) + "'"
      cSql += "  AND ZZZ_NUMOS   = '" + Alltrim(cCodOrd) + "'"
      cSql += "  AND ZZZ_STATUS <> 'E'"
      cSql += "  AND ZZZ_ITAB8   = '" + Alltrim(cCodSeq) + "'"
	  cSql += "  AND D_E_L_E_T_ <> '*'"

   	  If TcSqlExec(cSql) < 0
         cString := "1|Erro exclusao tabela ZZZ|"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         Return(.T.)
	  EndIf

      // ###########################################################
      // Pesquisa a pr�xima sequencia da tabela ZZZ para inclus�o ##
      // ###########################################################
      If (Select( "T_SEQUENCIA" ) != 0 )
         T_SEQUENCIA->( DbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT TOP(1) ZZZ_ITEM"

      Do Case
         Case cCodEmp == "01"
              cSql += "  FROM ZZZ010"
         Case cCodEmp == "02"
              cSql += "  FROM ZZZ020"
         Case cCodEmp == "03"
              cSql += "  FROM ZZZ030"
      EndCase        
              
      cSql += " WHERE ZZZ_FILIAL = '" + Alltrim(cCodFil) + "'"
      cSql += "   AND ZZZ_NUMOS  = '" + Alltrim(cCodOrd) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"
      cSql += " ORDER BY ZZZ_ITEM DESC"

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_SEQUENCIA",.T.,.T.)

      xcCodIte := IIF(T_SEQUENCIA->( EOF() ), "01", STRZERO(INT(VAL(T_SEQUENCIA->ZZZ_ITEM)) + 1,2))

      // ##############################
      // Inclui a requisi��o da pe�a ##
      // ##############################
      For nContar = 1 to Int(Val(cCodQua))

          DbSelectArea("ZZZ")
	      DbSetOrder(2)
 	      RecLock("ZZZ",.T.)
 	      ZZZ->ZZZ_FILIAL := cCodFil
 	      ZZZ->ZZZ_NUMOS  := cCodOrd
	      ZZZ->ZZZ_TECNIC := cCodTec
	      ZZZ->ZZZ_EMISSA := Date()
	      ZZZ->ZZZ_ITEM   := xcCodIte
	      ZZZ->ZZZ_ITAB8  := cCodSeq
	      ZZZ->ZZZ_LOCAL  := "01"
	      ZZZ->ZZZ_PRODUT := cCodPro
	      ZZZ->ZZZ_QUANT  := 1
	      ZZZ->ZZZ_QTDORI := Int(Val(cCodQua))
	      ZZZ->ZZZ_SALDO  := 1
	      ZZZ->ZZZ_STATUS := "A"
	      MsUnlock()
	      
          xcCodIte := Strzero((Int(Val(cCodIte)) + 1),2)
	      
	  Next nContar    

      // ####################################
      // Atualiza o registro da tabela AB8 ##
      // ####################################           
 	  cSql := ""
            
      Do Case
         Case cCodEmp == "01"
        	  cSql := "UPDATE AB8010 SET "
         Case cCodEmp == "02"       
        	  cSql := "UPDATE AB8020 SET "
         Case cCodEmp == "03"
              cSql := "UPDATE AB8030 SET "
      EndCase 	    
             	    
      cSql += "   AB8_CODSER = '" + Alltrim(cCodSer)        + "', "
      cSql += "   AB8_QUANT  =  " + Str(Int(Val(cCodQua)))  + " , "
      cSql += "   AB8_VUNIT  =  " + Str(Val(cCodUni),10,02) + " , "
      cSql += "   AB8_TOTAL  =  " + Str(Val(cCodTot),10,02) + " , "
      cSql += "   AB8_PRCLIS =  " + Str(Val(cCodLis),10,02) + "   "
      cSql += " WHERE AB8_FILIAL = '" + Alltrim(cCodFil) + "'"
      cSql += "   AND AB8_NUMOS  = '" + Alltrim(cCodOrd) + "'"
      cSql += "   AND AB8_CODPRO = '" + Alltrim(cCodPro) + "'"
      cSql += "   AND AB8_ITEM   = '" + Alltrim(cCodIte) + "'"
      cSql += "   AND AB8_SUBITE = '" + Alltrim(cCodSeq) + "'"   
      cSql += "   AND D_E_L_E_T_ = ''"      

   Conout("Codigo Tecnico:" + cSql)

      If TcSqlExec(cSql) < 0
         cString := "3|Erro ao atualizar tabela AB8 (Alteracao)|"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         Return(.T.)
      EndIf

      // ########################
      // Retorno  conm sucesso ##
      // ########################
      cString := "0|Alteracao de registros realizada com sucesso|"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   
   Endif

   // #####################################
   // Exclus�o de Apontamento/Requisi��o ##
   // #####################################
   If cCodOpe == "E"

      // ###########################################
      // Verifica se lan�amento pode ser exclu�do ##
      // ###########################################
      If (Select( "T_PODEALTERAR" ) != 0 )
         T_PODEALTERAR->( DbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZZ_STATUS"
      cSql += "  FROM ZZZ010 ZZZ(NoLock) "
	  cSql += " WHERE ZZZ_FILIAL  = '" + Alltrim(cCodFil) + "'"
	  cSql += "   AND ZZZ_NUMOS   = '" + Alltrim(cCodOrd) + "'"
	  cSql += "   AND ZZZ_PRODUT  = '" + Alltrim(cCodPro) + "'"
	  cSql += "   AND ZZZ_STATUS <> 'A'"
	  cSql += "   AND D_E_L_E_T_ <> '*' "

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PODEALTERAR",.T.,.T.)

   	  If !T_PODEALTERAR->( Eof() )
         cString := "4|Nao permitido a exclusao por ja ter movimento de requisicao para este produto. Estorne o produto para depois realizar a exclusao.|"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         Return(.T.)
      Endif

      // #################################### 
      // Exclui o lan�amento na tabela ZZZ ##
      // ####################################
      cSql := ""      

      Do Case
         Case cCodEmp == "01"
              cSql := "UPDATE ZZZ010 SET D_E_L_E_T_ = '*' "
         Case cCodEmp == "02"
              cSql := "UPDATE ZZZ020 SET D_E_L_E_T_ = '*' "
         Case cCodEmp == "03"
              cSql := "UPDATE ZZZ030 SET D_E_L_E_T_ = '*' "
      EndCase           

 	  cSql += "WHERE ZZZ_FILIAL  = '" + Alltrim(cCodFil) + "'"
      cSql += "  AND ZZZ_NUMOS   = '" + Alltrim(cCodOrd) + "'"
      cSql += "  AND ZZZ_ITAB8   = '" + Alltrim(cCodSeq) + "'"
      cSql += "  AND ZZZ_STATUS <> 'E'"
	  cSql += "  AND D_E_L_E_T_ <> '*'"

   	  If TcSqlExec(cSql) < 0
         cString := "1|Erro ao excluir o produto na tabela de requisicao de produtos.|"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         Return(.T.)
	  EndIf

      // #################################
      // Exclui registros da tabela AB8 ##
      // #################################
      cSql := ""      

      Do Case
         Case cCodEmp == "01"
              cSql := "UPDATE AB8010 SET D_E_L_E_T_ = '*' "
         Case cCodEmp == "02"
              cSql := "UPDATE AB8020 SET D_E_L_E_T_ = '*' "
         Case cCodEmp == "03"
              cSql := "UPDATE AB8030 SET D_E_L_E_T_ = '*' "
      EndCase           

      cSql += " WHERE AB8_FILIAL = '" + Alltrim(cCodFil) + "'"
      cSql += "   AND AB8_NUMOS  = '" + Alltrim(cCodOrd) + "'"
      cSql += "   AND AB8_CODPRO = '" + Alltrim(cCodPro) + "'"
      cSql += "   AND AB8_ITEM   = '" + Alltrim(cCodIte) + "'"
      cSql += "   AND AB8_SUBITE = '" + Alltrim(cCodSeq) + "'"   
      cSql += "   AND D_E_L_E_T_ = ''"      

   	  If TcSqlExec(cSql) < 0
         cString := "1|Erro ao excluir o produto na tabela de apontamentos.|"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         Return(.T.)
	  EndIf

      cString := "0|Exclusao realizada com sucesso|"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	

   Endif

Return(.T.)