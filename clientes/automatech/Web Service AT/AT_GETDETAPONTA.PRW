//#Include "aarray.ch"
//#Include "json.ch"
#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"

// ######################################################################################
// Web Service que pesquisado os apontamentos da ordem de serviço passada no parâmetro ##
// Nome......: AT_GETDETAPONTA                                                         ##
// Parâmetros: cCodEmp - Código da Empresa                                             ##
//             cCodFil - Código da Filial                                              ##
//             cCodOS  - Código da Ordem de Seriço                                     ##
//             cCodPro - Código do Produto                                             ##
//             cItemSQ - Sequencia do Produto no Apontamento                           ##
// ######################################################################################
WSRESTFUL AT_GETDETAPONTA DESCRIPTION "Advpl Tools - Service Get OS"

	WSDATA cCodEmp  AS STRING
	WSDATA cCodFil  AS STRING
	WSDATA cCodOS   AS STRING
	WSDATA cCodPro  AS STRING	
	WSDATA cItemSQ  AS STRING
	
	WSMETHOD GET DESCRIPTION "Advpl Tools - Service Get OS" WSSYNTAX "/AT_GETDETAPONTA || /AT_GETDETAPONTA/{cCodEmp}{cCodFil}{cCodOS}{cCodPro}{cItemSQ}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE cCodEmp, ccodFil, cCodOS, cCodPro, cItemSQ WSSERVICE AT_GETDETAPONTA

   Local cSql       := ""
   Local cString    := ""

   // ###########################################################
   // Pesquisa o preço do produto na tabela de preço informada ##
   // ###########################################################
   If (Select( "T_APONTAMENTO" ) != 0 )
      T_APONTAMENTO->( DbCloseArea() )
   EndIf

   cSql := "SELECT AB8.AB8_FILIAL,"
   cSql += "       AB8.AB8_NUMOS ,"
   cSql += "       AB8.AB8_ITEM  ,"
   cSql += "       AB8.AB8_CODPRO,"
   cSql += "       AB8.AB8_DESPRO,"
   cSql += "       AB8.AB8_CODSER,"
   cSql += "       AA5.AA5_DESCRI,"
   cSql += "       AB8.AB8_QUANT ,"
   cSql += "       AB8.AB8_VUNIT ," 
   cSql += "       AB8.AB8_TOTAL ,"
   cSql += "       AB8.AB8_ENTREG,"
   cSql += "       AB8.AB8_DTGAR ,"
   cSql += "       AB8.AB8_NUMPV ,"
   cSql += "       AB8.AB8_PRCLIS,"
   cSql += "       AB8.AB8_CODCLI,"
   cSql += "       AB8.AB8_LOJA  ,"
   cSql += "       AB8.AB8_CODPRD,"
   cSql += "       AB8.AB8_NUMSER,"
   cSql += "       AB8.AB8_TIPO  ,"
   cSql += "       AB8.AB8_NUMPVF,"
   cSql += "       AB8.AB8_LOCAL ,"
   cSql += "       AB8.AB8_LOCALI,"
   cSql += "       AB8.AB8_SUBITE "
   
   Do Case
      Case Self:cCodEmp == "01"
           cSql += "  FROM AB8010 AB8,"
           cSql += "       AA5010 AA5 "
      Case Self:cCodEmp == "02"
           cSql += "  FROM AB8020 AB8,"
           cSql += "       AA5010 AA5 "
      Case Self:cCodEmp == "03"
           cSql += "  FROM AB8030 AB8,"
           cSql += "       AA5010 AA5 "
   EndCase           
           
   cSql += " WHERE AB8.AB8_FILIAL = '" + Alltrim(Self:cCodFil) + "'"
   cSql += "   AND AB8.AB8_NUMOS  = '" + Alltrim(Self:cCodOS)  + "'"
   cSql += "   AND AB8.AB8_CODPRO = '" + Alltrim(Self:cCodPro) + "'"
   cSql += "   AND AB8.AB8_SUBITE = '" + Alltrim(Self:cItemSQ) + "'"
   cSql += "   AND AB8.D_E_L_E_T_ = ''"
   cSql += "   AND AA5.AA5_CODSER = AB8.AB8_CODSER"
   cSql += "   AND AA5.D_E_L_E_T_ = ''"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_APONTAMENTO",.T.,.T.)

   // Conta quantos registros estão sendo retornados
   T_APONTAMENTO->( DbGoTop() )

   cString := ""

   If T_APONTAMENTO->( EOF() )

      cString := "999999|"

   Else

      cString := cString + T_APONTAMENTO->AB8_FILIAL            + "|" + ; // 01
                           T_APONTAMENTO->AB8_NUMOS             + "|" + ; // 02
                           T_APONTAMENTO->AB8_ITEM              + "|" + ; // 03
                           T_APONTAMENTO->AB8_CODPRO            + "|" + ; // 04
                           T_APONTAMENTO->AB8_DESPRO            + "|" + ; // 05
                           T_APONTAMENTO->AB8_CODSER            + "|" + ; // 06
                           T_APONTAMENTO->AA5_DESCRI            + "|" + ; // 07
                           Str(T_APONTAMENTO->AB8_QUANT,10)     + "|" + ; // 08
                           Str(T_APONTAMENTO->AB8_VUNIT,10,02)  + "|" + ; // 09
                           Str(T_APONTAMENTO->AB8_TOTAL,10,02)  + "|" + ; // 10
                           T_APONTAMENTO->AB8_ENTREG            + "|" + ; // 11
                           T_APONTAMENTO->AB8_DTGAR             + "|" + ; // 12
                           T_APONTAMENTO->AB8_NUMPV             + "|" + ; // 13
                           Str(T_APONTAMENTO->AB8_PRCLIS,10,02) + "|" + ; // 14
                           T_APONTAMENTO->AB8_CODCLI            + "|" + ; // 15
                           T_APONTAMENTO->AB8_LOJA              + "|" + ; // 16
                           T_APONTAMENTO->AB8_CODPRD            + "|" + ; // 17
                           T_APONTAMENTO->AB8_NUMSER            + "|" + ; // 18
                           T_APONTAMENTO->AB8_TIPO              + "|" + ; // 19
                           T_APONTAMENTO->AB8_NUMPVF            + "|" + ; // 20
                           T_APONTAMENTO->AB8_LOCAL             + "|" + ; // 21
                           T_APONTAMENTO->AB8_LOCALI            + "|" + ; // 22
                           T_APONTAMENTO->AB8_SUBITE            + "|"     // 23

   Endif

   // ############################################
   // Retorna o conteúdo da pesquisa para o App ##
   // ############################################
   ::SetContentType("text/plain")
   ::SetResponse(cString)  	

Return(.T.)