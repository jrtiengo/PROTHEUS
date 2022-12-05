#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"

WSRESTFUL AT_APONTA DESCRIPTION "Advpl Tools - Service Get OS"

	WSDATA cCodFil  AS STRING
	WSDATA cCodOS   AS STRING	
	WSDATA cTipoPsq AS STRING	
	
	WSMETHOD GET DESCRIPTION "Advpl Tools - Service Det OS" WSSYNTAX "/AT_APONTA || /AT_APONTA/{cCodFil}{cCodOS}{cTipoPsq}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE cCodFil, cCodOS, cTipoPsq WSSERVICE AT_APONTA

   Local cSql      := ""
   Local cString   := ""

   // #######################################
   // Pesquisa os Apontamento da Filial/OS ##
   // #######################################
   If (Select( "T_APONTAMENTO" ) != 0 )
      T_APONTAMENTO->( DbCloseArea() )
   EndIf
 
   // #########################
   // S - Pesquisa Sintética ##
   // A - Pesquisa Analítica ##
   // #########################
   If Alltrim(Self:cTipoPsq) == "S"

      cSql := ""
      cSql := "SELECT AB8.AB8_FILIAL,"
      cSql += "       AB8.AB8_NUMOS ,"
      cSql += "       AB8.AB8_ITEM  ,"
      cSql += "       AB8.AB8_CODPRO,"
      cSql += "       AB8.AB8_DESPRO,"
      cSql += "       AB8.AB8_CODSER,"
	  cSql += "       AA5.AA5_DESCRI "

      Do Case
         Case Alltrim(Self:cCodFil) == "01"
              cSql += "  FROM AB8010 AB8, "
              cSql += "       AA5010 AA5  "
         Case Alltrim(Self:cCodFil) == "02"
              cSql += "  FROM AB8020 AB8, "
              cSql += "       AA5010 AA5  "
         Case Alltrim(Self:cCodFil) == "03"
              cSql += "  FROM AB8030 AB8, "
              cSql += "       AA5010 AA5  "
      EndCase

      cSql += " WHERE AB8.AB8_FILIAL = '" + Alltrim(Self:cCodFil) + "'"
      cSql += "   AND AB8.AB8_NUMOS  = '" + Alltrim(Self:cCodOS)  + "'"
      cSql += "   AND AB8.D_E_L_E_T_ = ''"
      cSql += "   AND AA5.AA5_CODSER = AB8.AB8_CODSER"
      cSql += "   AND AA5.D_E_L_E_T_ = ''"

   Else

      cSql := ""
      cSql := "SELECT AB8.AB8_FILIAL,"
      cSql += "       AB8.AB8_NUMOS ,"
      cSql += "       AB8.AB8_ITEM  ,"
      cSql += "       AB8.AB8_CODPRO,"
      cSql += "       AB8.AB8_DESPRO,"
      cSql += "       AB8.AB8_CODSER,"
      cSql += "       AB8.AB8_QUANT ,"
      cSql += "       AB8.AB8_VUNIT ,"
      cSql += "       AB8.AB8_TOTAL ,"
      cSql += "       AB8.AB8_ENTREG," 
      cSql += "       AB8.AB8_DTGAR ,"
      cSql += "       AB8.AB8_NUMPV ,"
      cSql += "       AB8.AB8_PRCLIS,"
      cSql += "       AB8.AB8_CODCLI,"
      cSql += "       AB8.AB8_LOJA  ,"
      cSql += "       AB8.AB8_CODPRO,"
      cSql += "       AB8.AB8_NUMSER,"
      cSql += "       AB8.AB8_TIPO  ,"
      cSql += "       AB8.AB8_NUMPVF,"
      cSql += "       AB8.AB8_LOCAL ,"
      cSql += "       AB8.AB8_LOCALI,"
      cSql += "       AB8.AB8_SUBITE,"
      cSql += "       AA5.AA5_DESCRI "
      
      Do Case
         Case Alltrim(Self:cCodFil) == "01"
              cSql += "  FROM AB8010 AB8,"
              cSql += "       AA5010 AA5 "
         Case Alltrim(Self:cCodFil) == "02"
              cSql += "  FROM AB8020 AB8, "
              cSql += "       AA5010 AA5 "
         Case Alltrim(Self:cCodFil) == "03"
              cSql += "  FROM AB8030 AB8,"
              cSql += "       AA5010 AA5 "
      EndCase

      cSql += " WHERE AB8.AB8_FILIAL = '" + Alltrim(Self:cCodFil) + "'"
      cSql += "   AND AB8.AB8_NUMOS  = '" + Alltrim(Self:cCodOS)  + "'"
      cSql += "   AND AB8.D_E_L_E_T_ = ''"
      cSql += "   AND AA5.AA5_CODSER = AB8.AB8_CODSER"
      cSql += "   AND AA5.D_E_L_E_T_ = ''"
      
   Endif   
       
   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_APONTA",.T.,.T.)

   If T_APONTA->( EOF() )

      cString := ""

   Else
      
      cString   := ""

      T_APONTA->( DbGoTop() )

      WHILE !T_APONTA->( EOF() )

         // #############################################
         // Elabora a String de retorno da solicitação ##
         // #############################################
         If Alltrim(Self:cTipoPsq) == "S"
         
            cString := cString + T_APONTA->AB8_FILIAL + "|"  + ;
                                 T_APONTA->AB8_NUMOS  + "|"  + ;
                                 T_APONTA->AB8_ITEM   + "|"  + ;
                                 T_APONTA->AB8_CODPRO + "|"  + ;
                                 T_APONTA->AB8_DESPRO + "|"  + ;
                                 T_APONTA->AB8_CODSER + "|"  + ;
	                             T_APONTA->AA5_DESCRI + "|#"
         Else

            cString := cString + T_APONTA->AB8_FILIAL + "|" + ;
                                 T_APONTA->AB8_NUMOS  + "|" + ;
                                 T_APONTA->AB8_ITEM   + "|" + ;
                                 T_APONTA->AB8_CODPRO + "|" + ;
                                 T_APONTA->AB8_DESPRO + "|" + ;
                                 T_APONTA->AB8_CODSER + "|" + ;
                                 T_APONTA->AB8_QUANT  + "|" + ;
                                 T_APONTA->AB8_VUNIT  + "|" + ;
                                 T_APONTA->AB8_TOTAL  + "|" + ;
                                 T_APONTA->AB8_ENTREG + "|" + ;
                                 T_APONTA->AB8_DTGAR  + "|" + ;
                                 T_APONTA->AB8_NUMPV  + "|" + ;
                                 T_APONTA->AB8_PRCLIS + "|" + ;
                                 T_APONTA->AB8_CODCLI + "|" + ;
                                 T_APONTA->AB8_LOJA   + "|" + ;
                                 T_APONTA->AB8_CODPRO + "|" + ;
                                 T_APONTA->AB8_NUMSER + "|" + ;
                                 T_APONTA->AB8_TIPO   + "|" + ;
                                 T_APONTA->AB8_NUMPVF + "|" + ;
                                 T_APONTA->AB8_LOCAL  + "|" + ;
                                 T_APONTA->AB8_LOCALI + "|" + ;
                                 T_APONTA->AB8_SUBITE + "|" + ;
                                 T_APONTA->AA5_DESCRI + "|#"
         Endif
         
         T_APONTA->( DbSkip() )
         
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