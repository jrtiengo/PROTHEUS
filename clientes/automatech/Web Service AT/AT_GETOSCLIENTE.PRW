#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"

//************************************************************************************
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                             *
// --------------------------------------------------------------------------------- *
// Referencia: AT_GETOSCLIENTE.PRW                                                   *
// Parâmetros: Nenhum                                                                *
// Tipo......: (X) Programa  ( ) Gatilho  (  ) Ponto de Entrada                      *
// --------------------------------------------------------------------------------- *
// Autor.....: Harald Hans Löschenkohl                                               *
// Data......: 21/11/2016                                                            *
// Objetivo..: Web Service que retorna as OS do Cliente passado no parâmetro         *
// Parâmetros: cCodCli - Código do Cliente                                           *
//             cCodLoj - Loja do Cliente                                             *
//             Se cCodLoj = 000, pesquisa todas as lojas do cliente                  *
//************************************************************************************

WSRESTFUL AT_GETOSCLIENTE DESCRIPTION "Advpl Tools - Service Get OS"

	WSDATA cCodCli AS STRING
	WSDATA cCodLoj AS STRING	
	WSDATA cCodSta AS STRING	
	WSDATA cDtaIni AS STRING	
	WSDATA cDtaFim AS STRING	
	WSDATA cTodos  AS STRING	
	
	WSMETHOD GET DESCRIPTION "Advpl Tools - Service Get OS" WSSYNTAX "/AT_GETOSCLIENTE || /AT_GETOSCLIENTE/{cCodCli}{cCodLoj}{cCodSta}{cDtaIni}{cDtaFim}{cTodos}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE cCodCli, cCodLoj, cCodSta, cDtaIni, cDtaFim, cTodos WSSERVICE AT_GETOSCLIENTE

   Local nQuantReg := 0	
   Local cSql      := ""
   Local cString   := ""

   // ############################################################################################################
   // Pesquisa no cadastro do cliente (Acesso a utilização de App AT Automatech, as empresas atendidas para ele ##
   // ############################################################################################################
   If Select("T_EMPRESAS") > 0
      T_EMPRESAS->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZTX.ZTX_EMP1,"
   cSql += "       ZTX.ZTX_EMP2 "
   cSql += "  FROM " + RetSqlName("ZTX") + " ZTX "
   cSql += " WHERE ZTX.ZTX_CLIE   = '" + Alltrim(Self:cCodCli) + "'"
   
   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_EMPRESAS", .T., .T. )

   If T_EMPRESAS->ZTX_EMP1 == "1"
      cPsqEmpresa := "01"
   Else
      cPsqEmpresa := "02"      
   Endif

   // ###############################
   // Prepara o campo data inicial ##
   // ###############################
   xReparteIni := Self:cDtaIni + "/"
   xDiaIni     := Strzero(INT(VAL(U_P_CORTA(xReparteIni, "/", 1))),2)
   xMesIni     := Strzero(INT(VAL(U_P_CORTA(xReparteIni, "/", 2))),2)
   xAnoIni     := Strzero(INT(VAL(U_P_CORTA(xReparteIni, "/", 3))),4)
   xDtaInicial := xAnoIni + xMesIni + xDiaIni

   // #############################
   // Prepara o campo data final ##
   // #############################
   xReparteFim := Self:cDtaFim + "/"
   xDiaFim     := Strzero(INT(VAL(U_P_CORTA(xReparteFim, "/", 1))),2)
   xMesFim     := Strzero(INT(VAL(U_P_CORTA(xReparteFim, "/", 2))),2)
   xAnoFim     := Strzero(INT(VAL(U_P_CORTA(xReparteFim, "/", 3))),4)
   xDtaFinal   := xAnoFim + xMesFim + xDiaFim

   // #####################################################
   // Pesquisa as Ordens de Serviços conforme parâmetros ##
   // #####################################################
   If (Select( "T_OSERVICOS" ) != 0 )
      T_OSERVICOS->( DbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT AB6.AB6_FILIAL AS FILIAL  ,"
   cSql += "       AB6.AB6_NUMOS  AS NUMEROOS,"
   cSql += "       SUBSTRING(AB6.AB6_EMISSA,07,02) + '/' + SUBSTRING(AB6.AB6_EMISSA,05,02) + '/' + SUBSTRING(AB6.AB6_EMISSA,01,04) AS EMISSAO,"
   cSql += "       SA1.A1_NOME AS CLIENTE    ,"
   cSql += "       CASE                       "
   cSql += "         WHEN AB6.AB6_POSI = 'F' THEN 'Fabricante Aguardando Orcamento'"
   cSql += "         WHEN AB6.AB6_POSI = 'P' THEN 'Aguardando Pecas'               "
   cSql += "         WHEN AB6.AB6_POSI = 'A' THEN 'Aguardando Aprovacao'           "
   cSql += "         WHEN AB6.AB6_POSI = 'B' THEN 'Em Bancada'                     "
   cSql += "         WHEN AB6.AB6_POSI = 'D' THEN 'Aguardando RMA'                 "
   cSql += "         WHEN AB6.AB6_POSI = 'E' THEN 'Encerrado'                      "
   cSql += "         WHEN AB6.AB6_POSI = 'M' THEN 'Aprovado'                       "
   cSql += "         WHEN AB6.AB6_POSI = 'N' THEN 'Reprovado'                      "
   cSql += "         WHEN AB6.AB6_POSI = 'C' THEN 'Aguardando NF'                  "
   cSql += "         WHEN AB6.AB6_POSI = 'G' THEN 'Fabricante Aguardando Aprovacao'"
   cSql += "         WHEN AB6.AB6_POSI = 'H' THEN 'Aguardando Retirada Fabricante' "
   cSql += "         WHEN AB6.AB6_POSI = 'I' THEN 'Entrada'                        "
   cSql += "         WHEN AB6.AB6_POSI = 'S' THEN 'Atestado'                       "
   cSql += "       END AS POSICAO ,"
   cSql += "       SA1.A1_BAIRRO  ,"
   cSql += "       SA1.A1_MUN     ,"
   cSql += "       SA1.A1_EST     ," 
   cSql += "       AB7.AB7_CODPRO ,"
   cSql += "       AB7.AB7_NUMSER ,"
   cSql += "       SB1.B1_DESC    ,"
   cSql += "       CASE                       "
   cSql += "         WHEN AB6.AB6_STATUS = 'A' THEN 'Aberta'   "
   cSql += "         WHEN AB6.AB6_STATUS = 'B' THEN 'Atendida' "
   cSql += "         WHEN AB6.AB6_STATUS = 'E' THEN 'Encerrada'"
   cSql += "       END  AS STATUS"
   cSql += "  FROM SB1010 SB1,"
   cSql += "       SA1010 SA1,"
   cSql += "       AB6010 AB6,"
   cSql += "       AB7010 AB7 "
   cSql += " WHERE AB6.D_E_L_E_T_ = ''  "
   cSql += "   AND SA1.A1_COD     = AB6.AB6_CODCLI"
   cSql += "   AND SA1.A1_LOJA    = AB6.AB6_LOJA  "
   cSql += "   AND SA1.D_E_L_E_T_ = ''            "
   cSql += "   AND AB7.AB7_FILIAL = AB6.AB6_FILIAL"
   cSql += "   AND AB7.AB7_NUMOS  = AB6.AB6_NUMOS "
   cSql += "   AND AB7.D_E_L_E_T_ = ''            "
   cSql += "   AND SB1.B1_COD     = AB7.AB7_CODPRO"
   cSql += "   AND SB1.D_E_L_E_T_ = ''            " 

   // ################################################
   // Seleciona OS do Cliente indicado no parâmetro ##
   // ################################################ 
   If Alltrim(Self:cTodos) == "S"
      cSql += " AND AB6.AB6_CODCLI = '" + Alltrim(Self:cCodCli) + "'"
   Else
      cSql += " AND AB6.AB6_CODCLI = '" + Alltrim(Self:cCodCli) + "'"
      cSql += " AND AB6.AB6_LOJA   = '" + Alltrim(Self:cCodLoj) + "'"
   Endif
      
   // #################################################
   // Seleciona OS pelo status indicado no parâmetro ##
   // ################################################# 
   If Self:cCodSta == "T"
   Else
      cSql += " AND AB6.AB6_STATUS = '" + Alltrim(Self:cCodSta) + "'"
   Endif

   cSql += "   AND AB6.AB6_EMISSA >= '" + Alltrim(xDtaInicial) + "'"
   cSql += "   AND AB6.AB6_EMISSA <= '" + Alltrim(xDtaFinal)   + "'"
   cSql += " ORDER BY AB6.AB6_EMISSA, AB6.AB6_NUMOS"

   cSql := ChangeQuery( cSql )
   dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_OSERVICOS",.T.,.T.)

   If T_OSERVICOS->( EOF() )
      cString := "1"      + "|" + ;
                 "999999" + "|" + ;
                 "000"    + "|" + ;
                 "X"      + "|" + ;
                 "X"      + "|" + ;
                 "X"      + "|" + ;
                 "X"      + "|" + ;
                 "X"      + "|" + ;
                 "X"      + "|" + ;
                 "X"      + "|" + ;
                 "X"      + "|" + ;
                 "X"      + "|" + ;
                 "X"      + "|" + ;
                 "X"      + "|#"

   Else
      
      T_OSERVICOS->( DbGoTop() )

      cImagem   := ""
      cString   := ""
      nQuantReg := 0
      
      WHILE !T_OSERVICOS->( EOF() )
         nQuantReg := nQuantReg + 1
         T_OSERVICOS->( DbSkip() )
      ENDDO

      T_OSERVICOS->( DbGoTop() )

      WHILE !T_OSERVICOS->( EOF() )

         cString := cString + Alltrim(Str(nQuantReg)) + "|" + ; // 01
                              T_OSERVICOS->FILIAL     + "|" + ; // 02
                              T_OSERVICOS->NUMEROOS   + "|" + ; // 03
                              T_OSERVICOS->EMISSAO    + "|" + ; // 04
                              T_OSERVICOS->CLIENTE    + "|" + ; // 05
                              T_OSERVICOS->POSICAO    + "|" + ; // 06
                              T_OSERVICOS->A1_BAIRRO  + "|" + ; // 07
                              T_OSERVICOS->A1_MUN     + "|" + ; // 08
                              T_OSERVICOS->A1_EST     + "|" + ; // 09
                              T_OSERVICOS->AB7_CODPRO + "|" + ; // 10
                              T_OSERVICOS->AB7_NUMSER + "|" + ; // 11
                              T_OSERVICOS->B1_DESC    + "|" + ; // 12
                              T_OSERVICOS->STATUS     + "|" + ; // 13
                              cPsqEmpresa             + "|#"    // 14
                              
         T_OSERVICOS->( DbSkip() )
         
      ENDDO

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