#INCLUDE "protheus.ch"
#INCLUDE "jpeg.ch" 

//**********************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           *
// ------------------------------------------------------------------------------- *
// Referencia: AUTOM521.PRW                                                        *
// Parâmetros: Nenhum                                                              *
// Tipo......: (X) Programa  ( ) Gatilho                                           *
// ------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                             *
// Data......: 27/12/2016                                                          *
// Objetivo..: Gatilho que retiorna o grupo do usuário para bloqueio do campo      *
//             C6_COMIS1 do Pedido de Venda                                        * 
//**********************************************************************************

User Function GravaAb8()

   Local cSql     := ""
   Local cRetorno := ""
   Local cString  := ""
   Local nContar  := 0

   // ###################################
   // Carrega as variáveis de trabalho ##
   // ###################################
   cCodOpe := "A"
   cCodEmp := "01"
   cCodFil := "01"
   cCodOrd := "044243"
   cCodIte := "01"
   cCodPro := "003000"
   cCodNom := "PRODUTO DE TESTE"
   cCodSer := "000006"
   cCodQua := "1"
   cCodUni := "120"
   cCodTot := "120"
   cCodLis := "120"
   cCodCli := "006004"
   cCodLoj := "006"
   cCodBas := "007859"
   cCodNse := "S11287521120451"
   cCodSeq := "07"
   cCodTec := "000078"

   // #####################################################################
   // Display dos valores dos parâmetros no Web Service para conferência ##
   // #####################################################################
   MsgAlert("Operacao......:" + cCodOpe + chr(13) + ;
            "Empresa.......:" + cCodEmp + chr(13) + ;
            "Filial........:" + cCodFil + chr(13) + ;
            "Ordem Servico.:" + cCodOrd + chr(13) + ;
            "Item..........:" + cCodIte + chr(13) + ;
            "Produto.......:" + cCodPro + chr(13) + ;
            "Nome Produto..:" + cCodNom + chr(13) + ;
            "Cod Servico...:" + cCodSer + chr(13) + ;
            "Quantidade....:" + cCodQua + chr(13) + ;
            "Unitario......:" + cCodUni + chr(13) + ;
            "Total.........:" + cCodTot + chr(13) + ;
            "Preco Lista...:" + cCodLis + chr(13) + ;
            "Codigo Cliente:" + cCodCli + chr(13) + ;
            "Loja Cliente..:" + cCodLoj + chr(13) + ;
            "Produto Base..:" + cCodBas + chr(13) + ;
            "Numero Serie..:" + cCodNse + chr(13) + ;
            "Sequencia.....:" + cCodSeq + chr(13) + ;
            "Codigo Tecnico:" + cCodTec)

   // ##########################
   // Inclusão de Apontamento ##
   // ##########################
   If cCodOpe == "I"

      // ######################################################
      // Pesquisa a próxima sequencia de inclusão do subitem ##
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
      cSql += "   AND D_E_L_E_T_ = ''"
      cSql += " ORDER BY AB8_SUBITE DESC"

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_SEQUENCIA",.T.,.T.)

      cSubItem := IIF(T_SEQUENCIA->( EOF() ), "01", STRZERO(INT(VAL(T_SEQUENCIA->AB8_SUBITE)) + 1,2))

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
      // Pesquisa a próxima sequencia da tabela ZZZ para inclusão ##
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
      // Inclui a requisição da peça ##
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

   Endif

   // ######################################
   // Alteração do Apontamento/Requisição ##
   // ######################################
   If cCodOpe == "A"
       
      // ###########################################
      // Verifica se lançamento pode ser alterado ##
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
//       cString := "4|Nao permitido alteracao por ja ter movimento de requisicao para o produto.|"
         MsgAlert("4|Nao permitido alteracao por ja ter movimento de requisicao para o produto.|")
         Return(.T.)
      Endif

      // ############################################################## 
      // Exclui lançamento na tabela ZZZ para realizar nova inclusão ##
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
         Return(.T.)
	  EndIf

      // ###########################################################
      // Pesquisa a próxima sequencia da tabela ZZZ para inclusão ##
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
      // Inclui a requisição da peça ##
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
	      ZZZ->ZZZ_ITAB8  := cCodSeq
	      ZZZ->ZZZ_LOCAL  := "01"
	      ZZZ->ZZZ_PRODUT := cCodPro
	      ZZZ->ZZZ_QUANT  := 1
	      ZZZ->ZZZ_QTDORI := Int(Val(cCodQua))
	      ZZZ->ZZZ_SALDO  := 1
	      ZZZ->ZZZ_STATUS := "A"
	      MsUnlock()
	      
          cCodIte := Strzero((Int(Val(cCodIte)) + 1),2)
	      
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
      cSql += "   AB8_QUANT  =  " + Str(int(val(cCodQua)))  + " , "
      cSql += "   AB8_VUNIT  =  " + Str(val(cCodUni),10,02) + " , "
      cSql += "   AB8_TOTAL  =  " + Str(val(cCodTot),10,02) + " , "
      cSql += "   AB8_PRCLIS =  " + Str(val(cCodLis),10,02) + "   "
      cSql += " WHERE AB8_FILIAL = '" + Alltrim(cCodFil)    + "'"
      cSql += "   AND AB8_NUMOS  = '" + Alltrim(cCodOrd)    + "'"
      cSql += "   AND AB8_CODPRO = '" + Alltrim(cCodPro)    + "'"
      cSql += "   AND AB8_ITEM   = '" + Alltrim(cCodIte)    + "'"
      cSql += "   AND AB8_SUBITE = '" + Alltrim(cCodSeq)    + "'"   
      cSql += "   AND D_E_L_E_T_ = ''"      

      If TcSqlExec(cSql) < 0
         cString := "3|Erro ao atualizar tabela AB8 (Alteracao)|"
         Return(.T.)
      EndIf

      // ########################
      // Retorno  conm sucesso ##
      // ########################
      cString := "0|Alteracao de registros realizada com sucesso|"
      Return(.T.)
   
   Endif

   // #####################################
   // Exclusão de Apontamento/Requisição ##
   // #####################################
   If cCodOpe == "E"

      // #################################
      // Exclui registros da tabela ZZZ ##
      // #################################
      cSql := ""      
 	  cSql := "UPDATE " + RetSqlName("ZZZ")+" Set D_E_L_E_T_ = '*' "

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

   	  If TcSqlExec(cQry) < 0
         cString := "1|Erro exclusao tabela ZZZ|"
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

   	  If TcSqlExec(cQry) < 0
         cString := "1|Erro exclusao tabela AB8|"
         Return(.T.)
	  EndIf

      cString := "3|Exclusao realizada com sucesso|"

   Endif

Return(.T.)