//#Include "aarray.ch"
//#Include "json.ch"
#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"

WSRESTFUL AT_GETPRCLISTA DESCRIPTION "Advpl Tools - Service Get OS"

	WSDATA cCodTab AS STRING
	WSDATA cCodPro AS STRING
	
	WSMETHOD GET DESCRIPTION "Advpl Tools - Service Get OS" WSSYNTAX "/AT_GETPRCLISTA || /AT_GETPRCLISTA/{cCodTab}{cCodPro}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE cCodTab, cCodPro WSSERVICE AT_GETPRCLISTA

   Local cSql      := ""
   Local cString   := ""

   // ######################################################
   // Verifica se foi informado código da tabela de preço ##
   // ######################################################
   If Empty(Alltrim(Self:cCodTab))
      cString := "0|"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Endif

   // ##############################################
   // Verifica se foi informado o código de preço ##
   // ##############################################
   If Empty(Alltrim(Self:cCodPro))
      cString := "0|"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   Endif

   // ###########################################################
   // Pesquisa o preço do produto na tabela de preço informada ##
   // ###########################################################
   If (Select( "T_PRECO" ) != 0 )
      T_PRECO->( DbCloseArea() )
   EndIf

   cSql := "SELECT DA1_CODTAB,"
   cSql += "       DA1_CODPRO,"
   cSql += "       DA1_MOEDA ,"
   cSql += "       DA1_PRCVEN "
   cSql += "  FROM DA1010"
   cSql += " WHERE DA1_CODTAB = '" + Alltrim(Self:cCodTab) + "'"
   cSql += "   AND DA1_CODPRO = '" + Alltrim(Self:cCodPro) + "'"
   cSql += "   AND D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PRECO",.T.,.T.)

   If T_PRECO->( EOF() )
      cString := "0|"
   Else
      T_PRECO->( DbGoTop() )

      cString := ""
      cString := cString + Str(T_PRECO->DA1_PRCVEN,10,02)+ "|"
                              
   Endif

   // ############################################
   // Retorna o conteúdo da pesquisa para o App ##
   // ############################################
   ::SetContentType("text/plain")
   ::SetResponse(cString)  	

Return(.T.)