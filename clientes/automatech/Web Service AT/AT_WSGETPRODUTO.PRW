#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"

WSRESTFUL AT_GETPRODUTO DESCRIPTION "Advpl Tools - Service Get OS"

	WSDATA cCodProduto AS STRING
	WSDATA cTipoPsq    AS STRING	
	
	WSMETHOD GET DESCRIPTION "Advpl Tools - Service Det OS" WSSYNTAX "/AT_GETPRODUTO || /AT_GETPRODUTO/{cCodProduto}{cTipoPsq}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE cCodProduto, cTipoPsq WSSERVICE AT_GETPRODUTO

   Local cSql      := ""
   Local cString   := ""

   // #####################################################
   // Pesquisa os Produtos conform parâmetro de pesquisa ##
   // #####################################################
   If (Select( "T_PRODUTOS" ) != 0 )
      T_PRODUTOS->( DbCloseArea() )
   EndIf
 
   // ###########################################
   // 0 - Pesquisa por parte de nome informado ##
   // 1 - Pesquisa pelo Código Informado       ##
   // ###########################################
   If Alltrim(Self:cTipoPsq) == "0"

      cSql := ""
      cSql := "SELECT B1_COD                                              AS CODIGO    ,"
      cSql += "       LTRIM(RTRIM(B1_DESC)) + ' ' + LTRIM(RTRIM(B1_DAUX)) AS DESCRICAO ,"
      cSql += "	      B1_PARNUM                                           AS PARTNUMBER,"
	  cSql += "       B1_UM                                               AS UNIDADE    "
      cSql += "  FROM SB1010"
      cSql += " WHERE LTRIM(RTRIM(B1_DESC)) + ' ' + LTRIM(RTRIM(B1_DAUX)) LIKE '%" + Alltrim(Self:cCodProduto) + "%'"
      cSql += "   AND D_E_L_E_T_  = '' "
      cSql += "   AND B1_MSBLQL  <> '1'" 
      cSql += " ORDER BY B1_DESC       "

   Else

      cSql := ""
      cSql := "SELECT B1_COD                                              AS CODIGO    ,"
      cSql += "       LTRIM(RTRIM(B1_DESC)) + ' ' + LTRIM(RTRIM(B1_DAUX)) AS DESCRICAO ,"
      cSql += "	      B1_PARNUM                                           AS PARTNUMBER,"
	  cSql += "       B1_UM                                               AS UNIDADE    "
      cSql += "  FROM SB1010"
      cSql += " WHERE B1_COD      = '" + Alltrim(Self:cCodProduto) + "'"
      cSql += "   AND D_E_L_E_T_  = '' "
      cSql += "   AND B1_MSBLQL  <> '1'" 
      cSql += " ORDER BY B1_DESC       "
      
   Endif   
       
   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PRODUTO",.T.,.T.)

   If T_PRODUTO->( EOF() )

      cString := ""

   Else
      
      cString   := ""

      T_PRODUTO->( DbGoTop() )

      WHILE !T_PRODUTO->( EOF() )

         // #############################################
         // Elabora a String de retorno da solicitação ##
         // #############################################
         cString := cString + T_PRODUTO->CODIGO     + "|"  + ;
                              T_PRODUTO->DESCRICAO  + "|"  + ;
                              T_PRODUTO->PARTNUMBER + "|"  + ;
                              T_PRODUTO->UNIDADE    + "|#"
         
         T_PRODUTO->( DbSkip() )
         
      ENDDO   

   Endif

   // ############################################
   // Retorna o conteúdo da pesquisa para o App ##
   // ############################################
   ::SetContentType("text/plain")
   ::SetResponse(cString)  	

Return(.T.)

// #########################################################################
// Função que elimina caracteres gráficos da string passada no parâmetros ##
// #########################################################################
Static Function LimpaStringGrafico(_Frase)

   Local aLetras := {}
   Local nContar := 0
   
   cRetorno01 := STRTRAN(_Frase    , "Ç", "C")
   cRetorno02 := STRTRAN(cRetorno01, "ç", "c")
   cRetorno03 := STRTRAN(cRetorno02, "Ã", "A")
   cRetorno04 := STRTRAN(cRetorno03, "ã", "a")
   cRetorno05 := STRTRAN(cRetorno04, "Ó", "O")
   cRetorno06 := STRTRAN(cRetorno05, "ó", "o")
   cRetorno07 := STRTRAN(cRetorno06, "Á", "A")
   cRetorno08 := STRTRAN(cRetorno07, "á", "a")
   cRetorno09 := STRTRAN(cRetorno08, "É", "E")
   cRetorno10 := STRTRAN(cRetorno09, "é", "e")        
   cRetorno11 := STRTRAN(cRetorno10, "º", "o")        
   cRetorno12 := STRTRAN(cRetorno11, "Â", "A")        
   cRetorno13 := STRTRAN(cRetorno12, "â", "a")        
   cRetorno14 := STRTRAN(cRetorno13, "Í", "I")        
   cRetorno15 := STRTRAN(cRetorno14, "í", "i")                    

Return(cRetorno15)