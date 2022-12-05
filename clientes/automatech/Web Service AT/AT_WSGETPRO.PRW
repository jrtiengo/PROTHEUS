//#Include "aarray.ch"
//#Include "json.ch"
#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"

WSRESTFUL AT_GETPRODUTOS DESCRIPTION "Advpl Tools - Service Get OS"

	WSDATA cCadastro AS STRING   
	WSDATA cCodPro   AS STRING
	WSDATA cTipoPsq  AS STRING
	
	WSMETHOD GET DESCRIPTION "Advpl Tools - Service Get OS" WSSYNTAX "/AT_GETPRODUTOS || /AT_GETPRODUTOS/{cCadastro}{cCodPro}{cTipoPsq}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE cCadastro, cCodPro, cTipoPsq WSSERVICE AT_GETPRODUTOS

   Local nQuantReg := 0	
   Local cSql      := ""
   Local cString   := ""

   If Empty(Alltrim(Self:cCodPro))

      cString := ""
      cString := "String a ser pesquisada nao foi informada."

      // ############################################
      // Retorna o conteúdo da pesquisa para o App ##
      // ############################################
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	

      Return(.T.)

   Endif

   // ################################
   // Pesquisa cadastro de produtos ##
   // ################################
   If Self:cCadastro == "1"
      If (Select( "T_PRODUTOS" ) != 0 )
         T_PRODUTOS->( DbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT B1_COD    AS CODIGO    ,"
      cSql += "       B1_PARNUM AS PARTNUMBER,"
      cSql += "       LTRIM(RTRIM(B1_DESC)) + ' ' + LTRIM(RTRIM(B1_DAUX)) AS DESCRICAO"
      cSql += "  FROM SB1010"

      Do Case
         Case Alltrim(Self:cTipoPsq) == "1"
              cSql += " WHERE B1_DESC LIKE '%" + Upper(Alltrim(Self:cCodPro)) + "%'"
         Case Alltrim(Self:cTipoPsq) == "2"
              cSql += " WHERE B1_COD = '" + Upper(AllTrim(Self:cCodPro)) + "'"
      EndCase     

      cSql += "   AND D_E_L_E_T_ = ''
      cSql += " ORDER BY B1_DESC"

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PRODUTOS",.T.,.T.)

      If T_PRODUTOS->( EOF() )
         cString := ""
      Else
      
         T_PRODUTOS->( DbGoTop() )

         cString   := ""
         nQuantReg := 0
      
         WHILE !T_PRODUTOS->( EOF() )
            nQuantReg := nQuantReg + 1
            T_PRODUTOS->( DbSkip() )
         ENDDO

         T_PRODUTOS->( DbGoTop() )
 
         WHILE !T_PRODUTOS->( EOF() )

            cString := cString + Alltrim(Str(nQuantReg)) + "|" + ;
                                 T_PRODUTOS->CODIGO      + "|" + ;
                                 T_PRODUTOS->PARTNUMBER  + "|" + ;
                                 T_PRODUTOS->DESCRICAO   + "|#"
                              
            T_PRODUTOS->( DbSkip() )
         
         ENDDO

      Endif
      
   Endif
   
   // #######################
   // Cadastro de Serviços ##
   // #######################  
   If Self:cCadastro == "2"
   
      If (Select( "T_SERVICOS" ) != 0 )
         T_SERVICOS->( DbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT AA5_CODSER,"
      cSql += "       AA5_DESCRI "
      cSql += "  FROM AA5010"
      cSql += " WHERE D_E_L_E_T_ = ''"

      Do Case
         Case Alltrim(Self:cTipoPsq) == "1"
              cSql += " AND AA5_DESCRI LIKE '%" + Upper(Alltrim(Self:cCodPro)) + "%'"
         Case Alltrim(Self:cTipoPsq) == "2"
              cSql += " AND AA5_CODSER = '" + Upper(AllTrim(Self:cCodPro)) + "'"
      EndCase     

      cSql += " ORDER BY AA5_DESCRI"

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_SERVICOS",.T.,.T.)

      If T_SERVICOS->( EOF() )
         cString := ""
      Else
      
         T_SERVICOS->( DbGoTop() )

         cString   := ""
         nQuantReg := 0
      
         WHILE !T_SERVICOS->( EOF() )
            nQuantReg := nQuantReg + 1
            T_SERVICOS->( DbSkip() )
         ENDDO

         T_SERVICOS->( DbGoTop() )
 
         WHILE !T_SERVICOS->( EOF() )

            cString := cString + Alltrim(Str(nQuantReg)) + "|" + ;
                                 T_SERVICOS->AA5_CODSER  + "|" + ;
                                 T_SERVICOS->AA5_DESCRI  + "|#"
                              
            T_SERVICOS->( DbSkip() )
         
         ENDDO

      Endif
      
   Endif

   // #################################################################
   // Pesquisa o produto pela informação direta do código do produto ##
   // #################################################################  
   If Self:cCadastro == "3"
   
      If (Select( "T_PRODUTO" ) != 0 )
         T_PRODUTO->( DbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT B1_COD AS CODIGO,"
      cSql += "       LTRIM(RTRIM(B1_DESC) + ' ' + LTRIM(RTRIM(B1_DAUX)) AS DESCRICAO"
      cSql += "  FROM SB1010"
      cSql += " WHERE B1_COD = '" + Alltrim(Self:cCodPro) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_PRODUTO",.T.,.T.)

      If T_PRODUTO->( EOF() )
         cString := ""
      Else
      
         T_PRODUTO->( DbGoTop() )

         cString := cString + "1|" + ;
                              T_PRODUTO->CODIGO    + "|" + ;
                              T_PRODUTO->DESCRICAO + "|#"
      Endif
      
   Endif

   // #################################################################
   // Pesquisa o SERVIÇO pela informação direta do código do produto ##
   // #################################################################  
   If Self:cCadastro == "4"
   
      If (Select( "T_SERVICO" ) != 0 )
         T_SERVICO->( DbCloseArea() )
      EndIf

      cSql := ""
      cSql := "SELECT AA5_CODSER AS CODIGO   ,"
      cSql += "       AA5_DESCRI AS DESCRICAO "
      cSql += "  FROM AA5010"
      cSql += " WHERE AA5_CODSER = '" + Alltrim(Self:cCodPro) + "'"
      cSql += "   AND D_E_L_E_T_ = ''"

      cSql := ChangeQuery( cSql )
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_SERVICO",.T.,.T.)

      If T_SERVICOS->( EOF() )
         cString := ""
      Else
      
         T_SERVICOS->( DbGoTop() )

         cString := cString + "1|" + ;
                              T_SERVICO->CODIGO    + "|" + ;
                              T_SERVICO->DESCRICAO + "|#"
      Endif
      
   Endif

   // ############################################
   // Retorna o conteúdo da pesquisa para o App ##
   // ############################################
   ::SetContentType("text/plain")
   ::SetResponse(cString)  	

Return(.T.)

/*
Static Function GetOS(cCodTec)


   // AQUI NESSA FUNCAO VC FAZ A CONSULTA QUE QUISER, O PARAMETRO EH O COD DO TECNICO.
   // BASTA RETORNAR O ARRAY NO MESMO FORMATO.

	Local cQry    := ""
	Local aItens  := {}
	Local nLinhas := 0
	Local aRet    := {}
	
	If (Select("TMPQRY")) > 0
		TMPQRY->(DbCloseArea())
	EndIf

	
	cQry := "SELECT A1_FILIAL, A1_COD, A1_LOJA FROM SA1990 "	
	
	cQry := ChangeQuery(cQry)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TMPQRY",.T.,.T.)

	Count To nLinhas

	DbSelectArea("TMPQRY");DbGoTop("TMPQRY")

	While !Eof()

	Aadd(aItens, {TMPQRY->A1_FILIAL, TMPQRY->A1_COD, TMPQRY->A1_LOJA})

		DbSkip()
	EndDo

	TMPQRY->(DbCloseArea())

	aRet := aItens
	
Return(aRet)
*/