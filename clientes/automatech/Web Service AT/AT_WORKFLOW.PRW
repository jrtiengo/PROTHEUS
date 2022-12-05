#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"

// ###############################################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                                        ##
// ------------------------------------------------------------------------------------------------------------ ##
// Referencia: AT_WORKFLOW.PRW                                                                                  ##
// Parâmetros: Nenhum                                                                                           ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                                                  ##
// ------------------------------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                                          ##
// Data......: 17/01/2017                                                                                       ##
// Objetivo..: Programa que envia o orçamento ao cliente pelo App Automatech AT                                 ##
// Parâmetros: Empresa, Filial, Ordem de Serviço                                                                ##
// ###############################################################################################################

WSRESTFUL AT_WORKFLOW DESCRIPTION "Advpl Tools - Service Get OS"

	WSDATA cCodPar AS STRING
	
	WSMETHOD GET DESCRIPTION "Advpl Tools - Service Get OS" WSSYNTAX "/AT_WORKFLOW || /AT_WORKFLOW/{cCodPar}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE cCodPar WSSERVICE AT_WORKFLOW

   Local aOS       := {}
   Local aOSRet    := {}
   Local nQuantReg := 0	
   Local cSql      := ""
   Local cString   := ""
   Local cImagem   := ""
   Local xEmpresa  := ""
   Local xFilial   := ""
   Local xTecnico  := ""

   xEmpresa     := U_P_CORTA(Self:cCodPar, "|", 1)
   xFilial      := U_P_CORTA(Self:cCodPar, "|", 2)
   xOServico    := U_P_CORTA(Self:cCodPar, "|", 3)
   xResponsavel := U_P_CORTA(Self:cCodPar, "|", 4)
   xDocumento   := U_P_CORTA(Self:cCodPar, "|", 5)

   Conout("Empresa......:" + xEmpresa)
   Conout("Filial.......:" + xFilial)
   Conout("Ordem Servico:" + xOservico)
   Conout("Responsavel..:" + xResponsavel)   
   Conout("Documento....:" + xDocumento)

   // ##########################################################################
   // Grava nome completo da assinatura e nº do documento na ordem de serviço ##
   // ##########################################################################

   cSql := ""

   Do Case
      Case xEmpresa == "01"
           cSql := "UPDATE AB6010"
      Case xEmpresa == "02"
           cSql := "UPDATE AB6020"
      Case xEmpresa == "03"
           cSql := "UPDATE AB6030"
   EndCase
              
   cSql += "   SET"
   cSql += "   AB6_RESPA      = '" + Alltrim(xResponsavel) + "', "
   cSql += "   AB6_NDOCU      = '" + Alltrim(xDocumento)   + "'  "
   cSql += " WHERE AB6_FILIAL = '" + Alltrim(xFilial)      + "'"
   cSql += "   AND AB6_NUMOS  = '" + Alltrim(xOservico)    + "'"

   Conout("Update....:" + csql)

   If TcSqlExec(cSql) < 0
      cString := "9|Erro no atualiza nome responsavel e numero do docuemnto.|"
      ::SetContentType("text/plain")
      ::SetResponse(cString)  	
      Return(.T.)
   EndIf

   // ##############################################
   // Envia para o programa que envia o Work Flow ##
   // ##############################################
   U_AUTOM530(xEmpresa, xFilial, xOservico)

   cString := "0|Work Flow Enviado.|"

   // ############################################
   // Retorna o conteúdo da pesquisa para o App ##
   // ############################################
   ::SetContentType("text/plain")
   ::SetResponse(cString)  	

Return(.T.)