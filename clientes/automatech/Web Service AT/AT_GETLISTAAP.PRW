//#Include "aarray.ch"
//#Include "json.ch"
#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"

// ######################################################################################
// Web Service que pesquisado os apontamentos da ordem de serviço passada no parâmetro ##
// Nome......: AT_GETLISTAAP                                                           ##
// Parâmetros: cCodEmp - Código da Empresa                                             ##
//             cCodFil - Código da Filial                                              ##
//             cCodOS  - Código da Ordem de Seriço                                     ##
// ######################################################################################
WSRESTFUL AT_GETLISTAAP DESCRIPTION "Advpl Tools - Service Get OS"

	WSDATA cCodEmp  AS STRING
	WSDATA cCodFil  AS STRING
	WSDATA cCodOS   AS STRING
	
	WSMETHOD GET DESCRIPTION "Advpl Tools - Service Get OS" WSSYNTAX "/AT_GETLISTAAP || /AT_GETLISTAAP/{cCodEmp}{cCodFil}{cCodOS}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE cCodEmp, ccodFil, cCodOS WSSERVICE AT_GETLISTAAP

   Local cSql        := ""
   Local cString     := ""
   Local nRegistros  := 0
   Local cProximaSeq := 0
   
   // ###########################################################
   // Pesquisa o preço do produto na tabela de preço informada ##
   // ###########################################################
   If (Select( "T_APONTAMENTO" ) != 0 )
      T_APONTAMENTO->( DbCloseArea() )
   EndIf

   cSql := "SELECT AB8_FILIAL,"
   cSql += "       AB8_NUMOS ,"
   cSql += "       AB8_ITEM  ,"
   cSql += "       AB8_CODPRO,"
   cSql += "       AB8_DESPRO,"
   cSql += "       AB8_SUBITE "
   
   Do Case
      Case Self:cCodEmp == "01"
           cSql += "  FROM AB8010
      Case Self:cCodEmp == "02"
           cSql += "  FROM AB8020
      Case Self:cCodEmp == "03"
           cSql += "  FROM AB8030
   EndCase           
           
   cSql += " WHERE AB8_FILIAL = '" + Alltrim(Self:cCodFil) + "'"
   cSql += "   AND AB8_NUMOS  = '" + Alltrim(Self:cCodOS)  + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_APONTAMENTO",.T.,.T.)

   // Conta quantos registros estão sendo retornados
   T_APONTAMENTO->( DbGoTop() )

   nRegistros := 0
   
   WHILE !T_APONTAMENTO->( EOF() )
      nRegistros := nRegistros + 1
      T_APONTAMENTO->( DbSkip() )
   ENDDO
      
   // ##############################################
   // Elabora a String para retorno o Web Service ##
   // ##############################################
   T_APONTAMENTO->( DbGoTop() )   

   cString := ""
   
   WHILE !T_APONTAMENTO->( EOF() )

      cString := cString + Alltrim(Str(nRegistros))             + "|" + ; // 01
                           T_APONTAMENTO->AB8_FILIAL            + "|" + ; // 02
                           T_APONTAMENTO->AB8_NUMOS             + "|" + ; // 03
                           T_APONTAMENTO->AB8_ITEM              + "|" + ; // 04
                           T_APONTAMENTO->AB8_CODPRO            + "|" + ; // 05
                           T_APONTAMENTO->AB8_DESPRO            + "|" + ; // 06
                           T_APONTAMENTO->AB8_SUBITE            + "|#"    // 07
                           
      T_APONTAMENTO->( DbSkip() )
       
   ENDDO

   // ############################################
   // Retorna o conteúdo da pesquisa para o App ##
   // ############################################
   ::SetContentType("text/plain")
   ::SetResponse(cString)  	

Return(.T.)