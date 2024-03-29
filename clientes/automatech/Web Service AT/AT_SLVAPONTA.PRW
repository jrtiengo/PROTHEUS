#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AT_WSGRVAPONBTA.PRW                                                 ##
// Par�metros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                             ##
// Data......: 17/11/2016                                                          ##
// Objetivo..: Web Service que grava os apontamentos da Ordem de Servi�o do App AT ##
// Par�metros: cParametros                                                         ##
//             01 - Opera��o                                                       ##
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
WSRESTFUL XAT_SLVAPONTA DESCRIPTION "Advpl Tools - Service Get OS"

	WSDATA cCodPar AS STRING
	
	WSMETHOD GET DESCRIPTION "Advpl Tools - Service Get OS" WSSYNTAX "/XAT_SLVAPONTA || /XAT_SLVAPONTA/{cCodPar}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE cCodPar WSSERVICE XAT_SLVAPONTA

   Local cSql      := ""
   Local cRetorno  := ""
   Local cString   := ""

   // ###################################
   // Carrega as vari�veis de trabalho ##
   // ###################################
   cCodOpe := U_P_CORTA(Self:cCodPar, "|", 01)
   cCodEmp := U_P_CORTA(Self:cCodPar, "|", 02)
   cCodFil := U_P_CORTA(Self:cCodPar, "|", 03)
   cCodOS  := U_P_CORTA(Self:cCodPar, "|", 04)
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

   // ##########################
   // Inclus�o de Apontamento ##
   // ##########################
   If cCodOpe == "I"

      // ###########################################################
      // Pesquisa a pr�xima sequencia da tabela ZZZ para inclus�o ##
      // ###########################################################
      If (Select( "T_SEQUENCIA" ) != 0 )
         T_SEQUENCIA->( DbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT TOP(1) ZZZ_ITEM"

      Do Case
         Case Self:cCodEmp == "01"
              cSql += "  FROM ZZZ010"
         Case Self:cCodEmp == "02"
              cSql += "  FROM ZZZ020"
         Case Self:cCodEmp == "03"
              cSql += "  FROM ZZZ030"
      EndCase        
              
      cSql += " WHERE ZZZ_FILIAL = '" + Alltrim(cCodFil) + "'"
      cSql += "   AND ZZZ_NUMOS  = '" + Alltrim(cCodOS)  + "'"
      cSql += "   AND D_E_L_E_T_ = ''"
      cSql += " ORDER BY ZZZ_ITEM DESC"

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_SEQUENCIA",.T.,.T.)

      cCodIte := IIF(T_SEQUENCIA->( EOF() ), "01", STRZERO(INT(VAL(T_SEQUENCIA->ZZZ_ITEM)) + 1,2))

      // ##############################
      // Inclui a requisi��o da pe�a ##
      // ##############################
      DbSelectArea("ZZZ")
	  DbSetOrder(2)
					
	  RecLock("ZZZ",.T.)
	  ZZZ->ZZZ_FILIAL := cCodFil
	  ZZZ->ZZZ_NUMOS  := cCodOS
	  ZZZ->ZZZ_TECNIC := cCodTec
	  ZZZ->ZZZ_EMISSA := Date()
	  ZZZ->ZZZ_ITEM   := cCodIte
	  ZZZ->ZZZ_ITAB8  := cCodSeq
	  ZZZ->ZZZ_LOCAL  := "01"
	  ZZZ->ZZZ_PRODUT := cCodPro
	  ZZZ->ZZZ_QUANT  := cCodQua
	  ZZZ->ZZZ_QTDORI := cCodQua
	  ZZZ->ZZZ_SALDO  := cCodQua
	  ZZZ->ZZZ_STATUS := "A"
	  MsUnlock()

      // ######################################################
      // Pesquisa a pr�xima sequencia de inclus�o do subitem ##
      // ######################################################
      If (Select( "T_SEQUENCIA" ) != 0 )
         T_SEQUENCIA->( DbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT TOP(1) AB8_SUBITE"

      Do Case
         Case Self:cCodEmp == "01"
              cSql += "  FROM AB8010"
         Case Self:cCodEmp == "02"
              cSql += "  FROM AB8020"
         Case Self:cCodEmp == "03"
              cSql += "  FROM AB8030"
      EndCase        
              
      cSql += " WHERE AB8_FILIAL = '" + Alltrim(Self:cCodFil) + "'"
      cSql += "   AND AB8_NUMOS  = '" + Alltrim(Self:cCodOS)  + "'"
      cSql += "   AND D_E_L_E_T_ = ''"
      cSql += " ORDER BY AB8_SUBITE DESC"

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_SEQUENCIA",.T.,.T.)

      cSubItem := IIF(T_SEQUENCIA->( EOF() ), "01", STRZERO(INT(VAL(T_SEQUENCIA->AB8_SUBITE)) + 1,2))

      // #######################
      // Inclui o Apontamento ##
      // #######################
      DbSelectArea("AB8")
	  DbSetOrder(1)
					
	  RecLock("AB8",.T.)
      AB8->AB8_FILIAL := cCodFil 
      AB8->AB8_NUMOS  := cCodOS
      AB8->AB8_ITEM   := cCodIte
      AB8->AB8_CODPRO := cCodPro
      AB8->AB8_DESPRO := cCodNom
      AB8->AB8_CODSER := cCodSer
      AB8->AB8_QUANT  := cCodQua
      AB8->AB8_VUNIT  := cCodUni
      AB8->AB8_TOTAL  := cCodTot
      AB8->AB8_ENTREG := Ctod(Date())
      AB8->AB8_PRCLIS := cCodLis
      AB8->AB8_CODCLI := cCodCli
      AB8->AB8_LOJA   := cCodLoj
      AB8->AB8_CODPRO := cCodBas
      AB8->AB8_NUMSER := cCodNse
      AB8->AB8_TIPO   := "2"
      AB8->AB8_LOCAL  := "01"
      AB8->AB8_SUBITE := cSubItem
      MsUnlock()

      // ######################
      // Retorno da inclus�o ##
      // ######################
      cString := "0|"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)

   Endif

   // ######################################
   // Altera��o do Apontamento/Requisi��o ##
   // ######################################
   If cCodOpe == "A"

      If (Select( "T_REQUISICAO" ) != 0 )
         T_REQUISICAO->( DbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT ZZZ_FILIAL,"
      cSql += "       ZZZ_NUMOS ,"
      cSql += "	      ZZZ_PRODUT,"
      cSql += "	      ZZZ_ITAB8 ,"
      cSql += "	      ZZZ_QUANT ,"
      cSql += "	      ZZZ_SALDO ,"
      cSql += "	      ZZZ_STATUS "
   
      Do Case
         Case Self:cCodEmp == "01"
              cSql += "  FROM ZZZ010 "
         Case Self:cCodEmp == "02"
              cSql += "  FROM ZZZ020 "
         Case Self:cCodEmp == "03"
              cSql += "  FROM ZZZ030 "
      EndCase           
           
      cSql += " WHERE ZZZ_FILIAL = '" + Alltrim(cCodFil) + "'"
      cSql += "   AND ZZZ_NUMOS  = '" + Alltrim(cCodOS)  + "'"
      cSql += "   AND ZZZ_PRODUT = '" + Alltrim(cCodPro) + "'"
      cSql += "   AND ZZZ_ITAB8  = '" + Alltrim(cCodSeq) + "'"
      cSql += "   AND D_E_L_E_T_ = ''                                                                                             

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_REQUISICAO",.T.,.T.)

      // ######################################
      // Se n�o existir, inclui a requisi��o ##
      // ######################################
      If T_REQUISICAO->( EOF() ) 
      
		 DbSelectArea("ZZZ")
		 DbSetOrder(2)
					
		 RecLock("ZZZ",.T.)
		 ZZZ->ZZZ_FILIAL := cCodFil
		 ZZZ->ZZZ_NUMOS  := cCodOS
		 ZZZ->ZZZ_TECNIC := cCodTec
		 ZZZ->ZZZ_EMISSA := Date()
		 ZZZ->ZZZ_ITEM   := ""
		 ZZZ->ZZZ_ITAB8  := cCodSeq
		 ZZZ->ZZZ_LOCAL  := "01"
		 ZZZ->ZZZ_PRODUT := cCodPro
		 ZZZ->ZZZ_QUANT  := cCodQua
		 ZZZ->ZZZ_QTDORI := cCodQua
		 ZZZ->ZZZ_SALDO  := cCodQua
		 ZZZ->ZZZ_STATUS := "A"
		 MsUnlock()

      Else
      
         If T_REQUISICAO->ZZZ_STATUS == "A"
             
            // #################################################
            // Elimina o registro para realizar nova inclus�o ##
            // #################################################
     	    cSql := ""
            
            Do Case
               Case Self:cCodEmp == "01"
             	    cSql := "UPDATE ZZZ010"
               Case Self:cCodEmp == "02"
             	    cSql := "UPDATE ZZZ020"
               Case Self:cCodEmp == "03"
             	    cSql := "UPDATE ZZZ030"
            EndCase 	    
             	    
     	    cSql += "   SET D_E_L_E_T_  = '*' "
 	        cSql += " WHERE ZZZ_NUMOS   = '" + Alltrim(cCodOS)  + "'"
 	        cSql += "   AND ZZZ_STATUS <> 'E'"
 	        cSql += "   AND ZZZ_ITAB8   = '" + Alltrim(cCodSeq) + "'" 
 	        cSql += "   AND ZZZ_FILIAL  = '" + Alltrim(cCodFil) + "'"
 	        cSql += "   AND D_E_L_E_T_  = ''"

	        If TcSqlExec(cQry) < 0
		       cString := "2|"
               ::SetContentType("text/plain")
               ::SetResponse(cString)  	
               Return(.T.)
	        EndIf

            // #########################
            // Inclui nova requisi��o ##
            // #########################
   	 	    DbSelectArea("ZZZ")
		    DbSetOrder(2)
					
		    RecLock("ZZZ",.T.)
		    ZZZ->ZZZ_FILIAL := cCodFil
		    ZZZ->ZZZ_NUMOS  := cCodOS
		    ZZZ->ZZZ_TECNIC := cCodTec
		    ZZZ->ZZZ_EMISSA := Date()
		    ZZZ->ZZZ_ITEM   := ""
		    ZZZ->ZZZ_ITAB8  := cCodSeq
		    ZZZ->ZZZ_LOCAL  := "01"
		    ZZZ->ZZZ_PRODUT := cCodPro
		    ZZZ->ZZZ_QUANT  := cCodQua
		    ZZZ->ZZZ_QTDORI := cCodQua
		    ZZZ->ZZZ_SALDO  := cCodQua
		    ZZZ->ZZZ_STATUS := "A"
		    MsUnlock()

         Else

            // ###########################################################################
            // Retorna informando o c�digo 1 que indica que requisi��o j� foi atendida. ##
            // ###########################################################################        
            cString := "1|"
            ::SetContentType("text/plain")
            ::SetResponse(cString)  	
            Return(.T.)
            
         Endif

      Endif
            
      // ####################################
      // Atualiza o registro da tabela AB8 ##
      // ####################################           
 	  cSql := ""
            
      Do Case
         Case Self:cCodEmp == "01"
        	  cSql := "UPDATE AB8010 SET "
         Case Self:cCodEmp == "02"       
        	  cSql := "UPDATE AB8020 SET "
         Case Self:cCodEmp == "03"
              cSql := "UPDATE AB8030 SET "
      EndCase 	    
             	    
      cSql += "   AB8_CODSER = '" + Alltrim(cCodSer) + "', "
      cSql += "   AB8_QUANT  =  " + Str(cCodQua)     + " , "
      cSql += "   AB8_VUNIT  =  " + Str(cCodUni)     + " , "
      cSql += "   AB8_TOTAL  =  " + Str(cCodTot)     + " , "
      cSql += "   AB8_PRCLIS =  " + Str(cCodLis)     + "   "
      cSql += " WHERE AB8_FILIAL = '" + Alltrim(cCodFil) + "'"
      cSql += "   AND AB8_NUMOS  = '" + Alltrim(cCodOS)  + "'"
      cSql += "   AND AB8_CODPRO = '" + Alltrim(cCodPro) + "'"
      cSql += "   AND AB8_ITEM   = '" + Alltrim(cCodIte) + "'"
      cSql += "   AND AB8_SUBITE = '" + Alltrim(cCodSeq) + "'"   
      cSql += "   AND D_E_L_E_T_ = ''"      

      If TcSqlExec(cQry) < 0
         cString := "3|"
         ::SetContentType("text/plain")
         ::SetResponse(cString)  	
         Return(.T.)
      EndIf

      // #######################
      // Retorno  con sucesso ##
      // #######################
      cString := "0|"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   
   Endif

   // #####################################
   // Exclus�o de Apontamento/Requisi��o ##
   // #####################################
   If cCodOpe == "E"
   Endif

Return(.T.)