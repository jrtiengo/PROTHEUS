#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"

// ###############################################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                                                        ##
// ------------------------------------------------------------------------------------------------------------ ##
// Referencia: AT_CAPTAIMAGEM.PRW                                                                               ##
// Parâmetros: Nenhum                                                                                           ##
// Tipo......: (X) Programa  ( ) Gatilho  ( ) Ponto de Entrada                                                  ##
// ------------------------------------------------------------------------------------------------------------ ##
// Autor.....: Harald Hans Löschenkohl                                                                          ##
// Data......: 06/02/2017                                                                                       ##
// Objetivo..: Web Service que captra imagem passada pelo comando PostFile do App Inventor                      ##
// Parâmetros: Empresa, Filial, Ordem de Serviço, Nome da Imagem                                                ##
// ###############################################################################################################

WSRESTFUL AT_CAPTAIMAGEM DESCRIPTION "Advpl Tools - Service Get OS"

	WSDATA cCodEmp AS STRING
	WSDATA cCodFil AS STRING
	WSDATA cCodOrd AS STRING
	WSDATA cImagem AS STRING
	
	WSMETHOD PUT DESCRIPTION "Advpl Tools - Service Get OS" WSSYNTAX "/AT_CAPTAIMAGEM || /AT_CAPTAIMAGEM/{cCodEmp}{cCodFil}{cCodOrd}{cImagem}"

END WSRESTFUL

WSMETHOD PUT WSRECEIVE cCodEmp, cCodFil, cCodOrd, cImagem WSSERVICE AT_CAPTAIMAGEM

   Local aOS       := {}
   Local aOSRet    := {}
   Local nQuantReg := 0	
   Local cSql      := ""
   Local cString   := ""
   Local cImagem   := ""
   Local xEmpresa  := ""
   Local xFilial   := ""
   Local xTecnico  := ""

   xEmpresa     := Self:cCodEmp
   xFilial      := Self:cCodFil
   xOServico    := Self:cCodOrd
   xImagem      := Self:cImagem

   Conout("Empresa......:" + xEmpresa)
   Conout("Filial.......:" + xFilial)
   Conout("Ordem Servico:" + xOservico)
   Conout("Imagem.......:" + xImagem)

   cString := "Deu Certo ate aqui " + xEmpresa + " " + xFilial + " " + xOservico + " " + xImagem

   // ############################################
   // Retorna o conteúdo da pesquisa para o App ##
   // ############################################
   ::SetContentType("text/plain")
   ::SetResponse(cString)  	

Return(.T.)