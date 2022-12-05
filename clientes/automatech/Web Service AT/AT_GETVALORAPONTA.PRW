#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"

// ##########################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                   ##
// --------------------------------------------------------------------------------------- ##
// Referencia: AT_GETVAORAPONTA.PRW                                                        ##
// Parâmetros: Nenhum                                                                      ##
// Tipo......: (X) Programa  ( ) Gatilho  (  ) Ponto de Entrada                            ##
// --------------------------------------------------------------------------------------  ##
// Autor.....: Harald Hans Löschenkohl                                                     ##
// Data......: 04/12/2016 - Domingo - 16:26:00                                             ##
// Objetivo..: Web Service que tem por objetivo de retornar o valor total dos apontamentos ##
// ##########################################################################################

WSRESTFUL AT_GETVALORAPONTA DESCRIPTION "Advpl Tools - Service Get OS"

	WSDATA cCodEmp  AS STRING
	WSDATA cCodFil  AS STRING
	WSDATA cCodOS   AS STRING	
	
	WSMETHOD GET DESCRIPTION "Advpl Tools - Service Det OS" WSSYNTAX "/AT_GETVALORAPONTA || /AT_GETVALORAPONTA/{cCodEmp}{cCodFil}{cCodOS}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE cCodEmp, cCodFil, cCodOS WSSERVICE AT_GETVALORAPONTA

   Local cSql             := ""
   Local nValorCliente    := 0
   Local nValorFabricante := 0
   Local nValorTotalOs    := 0  
   Local cString   := ""

   // #########################################################
   // Pesquisa os valores do apontamento da ordem de serviço ##
   // #########################################################
   If (Select( "T_VALORAPONTA" ) != 0 )
      T_VALORAPONTA->( DbCloseArea() )
   EndIf
 
   cSql := ""
   cSql := "SELECT AB8.AB8_FILIAL,
   cSql += "       AB8.AB8_NUMOS ,
   cSql += "       AB8.AB8_ITEM  ,
   cSql += "       AB8.AB8_CODPRO,             
   cSql += "       AB8.AB8_TOTAL ,
   cSql += "      (AB8.AB8_TOTAL * (SELECT AA5_PRCCLI FROM AA5010 WHERE AA5_CODSER = AB8.AB8_CODSER AND D_E_L_E_T_ = '')  / 100)  AS CLIENTE   ," 
   cSql += "      (AB8.AB8_TOTAL * (SELECT AA5_PRCFAB FROM AA5010 WHERE AA5_CODSER = AB8.AB8_CODSER AND D_E_L_E_T_ = '')  / 100)  AS FABRICANTE "

   Do Case
      Case Self:cCodEmp == "01"
           cSql += "  FROM AB8010 AB8"
      Case Self:cCodEmp == "02"
           cSql += "  FROM AB8020 AB8"
      Case Self:cCodEmp == "03"
           cSql += "  FROM AB8030 AB8"
   EndCase
   
   cSql += " WHERE AB8.AB8_FILIAL = '" + Alltrim(Self:cCodFil) + "'"
   cSql += "   AND AB8.AB8_NUMOS  = '" + Alltrim(Self:cCodOS)  + "'"
   cSql += "   AND AB8.D_E_L_E_T_ = ''"
       
   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_VALORAPONTA",.T.,.T.)

   If T_VALORAPONTA->( EOF() )

      cString := "0|0|0|"

   Else

      // ###############################
      // Soma os valores para retorno ##
      // ###############################
      cString   := ""

      T_VALORAPONTA->( DbGoTop() )

      WHILE !T_VALORAPONTA->( EOF() )
         nValorCliente    := nValorCliente    + T_VALORAPONTA->CLIENTE
         nValorFabricante := nValorFabricante + T_VALORAPONTA->FABRICANTE
         nValorTotalOs    := nValorTotalOs    + T_VALORAPONTA->AB8_TOTAL
         T_VALORAPONTA->( DbSkip() )
      ENDDO
         
      // #############################################
      // Elabora a String de retorno da solicitação ##
      // #############################################
      cString := Str(nValorCliente,10,02) + "|" + Str(nValorFabricante,10,02) + "|" + Str(nValorTotalOs) + "|"
         
   Endif

   // ############################################
   // Retorna o conteúdo da pesquisa para o App ##
   // ############################################
   ::SetContentType("text/plain")
   ::SetResponse(cString)  	

Return(.T.)