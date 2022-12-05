//#Include "aarray.ch"
//#Include "json.ch"
#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"

// ######################################################################################
// Web Service que pesquisado os apontamentos da ordem de serviço passada no parâmetro ##
// Nome......: AT_GETCLIENTESLOJA                                                      ##
// Parâmetros: cCodCli - Código do Cliente                                             ##
// ######################################################################################
WSRESTFUL AT_GETCLIENTELOJA DESCRIPTION "Advpl Tools - Service Get OS"

	WSDATA cCodCli  AS STRING
	
	WSMETHOD GET DESCRIPTION "Advpl Tools - Service Get OS" WSSYNTAX "/AT_GETCLIENTELOJA || /AT_GETCLIENTELOJA/{cCodCli}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE cCodCli WSSERVICE AT_GETCLIENTELOJA

   Local cSql      := ""
   Local nQuantReg := 0
   Local cString   := ""

   // ######################################################
   // Pesquisa as lojas do Cliente informado no parâmetro ##
   // ######################################################
   If (Select( "T_CLIENTES" ) != 0 )
      T_CLIENTES->( DbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT SA1.A1_COD   ,"
   cSql += "       SA1.A1_LOJA  ,"
   cSql += "       SA1.A1_BAIRRO,"
   cSql += "       SA1.A1_NOME  ,"
   cSql += "       SA1.A1_MUN   ,"
   cSql += "       SA1.A1_EST    "
   cSql += "  FROM SA1010 SA1 "
   cSql += " WHERE SA1.A1_COD = '" + Alltrim(Self:cCodCli) + "'"
   cSql += "   AND SA1.D_E_L_E_T_ = ''"
   cSql += " ORDER BY SA1.A1_COD, SA1.A1_LOJA"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_CLIENTES",.T.,.T.)

   // Conta quantos registros estão sendo retornados
   T_CLIENTES->( DbGoTop() )

   cString := ""

   If T_CLIENTES->( EOF() )

      cString := "999999|#"
      cString := cString + "1"      + "|" + ; // 01
                           "999999" + "|" + ; // 02
                           "X"      + "|" + ; // 03
                           "X"      + "|" + ; // 04
                           "X"      + "|" + ; // 05
                           "X"      + "|" + ; // 06
                           "X"      + "|#"    // 07

   Else
   
      T_CLIENTES->( DbGoTop() )
      
      nQuantReg := 0
      
      WHILE !T_CLIENTES->( EOF() )
         nQuantReg := nQuantReg + 1
         T_CLIENTES->( DbSkip() )
      ENDDO

      cString := ""

      T_CLIENTES->( DbGoTop() )

      WHILE !T_CLIENTES->( EOF() )

         cString := cString + Alltrim(Str(nQuantReg)) + "|" + ; // 01
                              T_CLIENTES->A1_COD      + "|" + ; // 02
                              T_CLIENTES->A1_LOJA     + "|" + ; // 03
                              T_CLIENTES->A1_NOME     + "|" + ; // 04
                              T_CLIENTES->A1_MUN      + "|" + ; // 05
                              T_CLIENTES->A1_BAIRRO   + "|" + ; // 06
                              T_CLIENTES->A1_EST      + "|#"    // 07

         T_CLIENTES->( DbSkip() )
                              
      ENDDO

   Endif

   // ############################################
   // Retorna o conteúdo da pesquisa para o App ##
   // ############################################
   ::SetContentType("text/plain")
   ::SetResponse(cString)  	

Return(.T.)