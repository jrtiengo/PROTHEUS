#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AT_CELULAR.PRW                                                      ##
// Parâmetros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                             ##
// Data......: 10/01/2017                                                          ##
// Objetivo..: Web Service que verifica se o celular que está acessando o App      ##
//             é válido.                                                           ##
// Parâmetros: cParametros                                                         ##
//             01 - DDD                                                            ##
//             02 - Nº do Celular                                                  ##
// ##################################################################################
WSRESTFUL AT_CELULAR DESCRIPTION "Advpl Tools - Service Get OS"

	WSDATA cCodPar AS STRING
	
	WSMETHOD GET DESCRIPTION "Advpl Tools - Service Get OS" WSSYNTAX "/AT_CELULAR || /AT_CELULAR/{cCodPar}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE cCodPar WSSERVICE AT_CELULAR

   Local cSql      := ""
   Local cRetorno  := ""
   Local cString   := ""
   Local xControle := ""

   Local cCodDDD  := U_P_CORTA(Self:cCodPar, "|", 02) 
   Local cCodCel  := U_P_CORTA(Self:cCodPar, "|", 03) 
   Local cCelular := Alltrim(cCodDDD) + " " + Alltrim(cCodCel)

   // #######################################################################################
   // Pesquisa se o celular passado no parâmetro existe. Se existe, verifica se´está ativo ##
   // #######################################################################################
   If Select("T_CELULAR") > 0
      T_CONSULTA->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZTZ_CELU ,"
   cSql += "       ZTZ_ATIVO "
   cSql += "  FROM ZTZ010"
   cSql += " WHERE ZTZ_DELE = ''"
   cSql += "   AND ZTZ_CELU = '" + Alltrim(cCelular) + "'"

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CELULAR", .T., .T. )
      
   If T_CONSULTA->( EOF() )
      cString := "9|Celular não autorizado a executar o App.|"
   Else
      If T_CELULAR->ZTZ_ATIVO == "N"
         cString := "9|Celular está inativo para executar o App. Entre em contato com o Administrador do App.|"
      Else
         cString := "0|Celular Ativo.|"         
      Endif
   Endif

   // ############################################
   // Retorna o conteúdo da pesquisa para o App ##
   // ############################################
   ::SetContentType("text/plain")
   ::SetResponse(cString)  	

Return(.T.)