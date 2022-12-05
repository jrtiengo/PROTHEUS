//#Include "aarray.ch"
//#Include "json.ch"
#Include "restful.ch"
#Include "protheus.ch"
#Include "totvs.ch"              

// ######################################################################################
// AUTOMATECH SISTEMAS DE AUTOMAÇÃO LTDA                                               ##
// ----------------------------------------------------------------------------------- ##
// Referencia: AT_LOGIN.PRW                                                            ##
// Parâmetros: Nenhum                                                                  ##
// Tipo......: (X) Programa  ( ) Gatilho                                               ##
// ----------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans Löschenkohl                                                 ##
// Data......: 01/12/2016                                                              ##
// Objetivo..: Este Web Service tem por finalidade de realizar o login do App At       ##
// Parâmetros: Login e Senha                                                           ##
// Objetivo..: Inicialmente este web service verificará se o usuário está cadastrado   ##
//             no Sistema Protheus. Se existir, verifica se senha está correta.        ##
//             Se login não existir no cadastro de usuários do Sistema Protheus, WS    ##
//             pesquisará o login na tabela ZTX. Esta tabela contém os clientes que    ##
//             possuem autorização para acessar o App At Autuomatech.                  ##
// ######################################################################################

WSRESTFUL AT_LOGIN DESCRIPTION "Advpl Tools - Service Login"

	WSDATA cUser AS STRING
	WSDATA cPass AS STRING
	
	WSMETHOD GET DESCRIPTION "Advpl Tools - Service Login" WSSYNTAX "/AT_LOGIN || /AT_LOGIN/{cUser}{cPass}"

END WSRESTFUL

WSMETHOD GET WSRECEIVE cUser, cPass WSSERVICE AT_LOGIN

   Local cCodUser  := ""
                     
   If (! Empty(Self:cUser) .And. ! Empty(Self:cPass))
  	  cCodUser := AtConsLogin(Self:cUser, Self:cPass)
   Else
 	  cCodUser := "1|Preencha todos os parametros|"
   EndIf
	
   // ###################################################################
   // Verifica se o primeiro parâmetro do cCodUser for igual a 000000. ##
   // Se for, envia para a pesquisa de liberação para clientes.        ##
   // ###################################################################
   If U_P_CORTA(cCodUser, "|", 1) <> "0"
  	  cCodUser := AtCliLogin(Self:cUser, Self:cPass)
   EndIf

   ::SetContentType("text/plain")
   ::SetResponse(cCodUser)
			
Return(.T.)

// ############################################################
// Função que pesquisa o login e senha pelo Sistema Protheus ##
// ############################################################
Static Function AtConsLogin(cUserx, cSenhax)
                
   Local cSql         := ""
   Local cCUsuario    := ""
   Local cNomeUsua    := ""
   Local cCodTecnico  := ""
   Local cNomeTecnico := "" 
   Local cReturn      := ""
   Local ix           := 0
   Local Nx           := 0

   Nx := 0

   // #################################
   // Seleciona a Ordem de Indexação ##
   // #################################
   PswOrder(2)

   If PswSeek( cUserx, .T. )

       If PswName(Alltrim(cSenhax))
          cCUsuario := PswID()
          cNomeUsua := UsrRetName (cCUsuario)              

          // ##############################################################            
          // Pesquisa o código e nome do técnico para o login verificado ##
          // ##############################################################
          If (Select( "T_TECNICO" ) != 0 )
             T_TECNICO->( DbCloseArea() )
          EndIf

          cSql := ""
          cSql := "SELECT AA1_CODTEC,"
          cSql += "       AA1_NOMTEC,"
          cSql += "       AA1_CODUSR "
          cSql += "  FROM " + RetSqlName("AA1")
          cSql += " WHERE AA1_CODUSR = '" + Alltrim(cCUsuario) + "'"
          cSql += "   AND D_E_L_E_T_ = ''"
              
          cSql := ChangeQuery( cSql )
          dbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"T_TECNICO",.T.,.T.)
                                                                                                                  
          If T_TECNICO->( EOF() )
             cCodTecnico  := "000000"
             cNomeTecnico := "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" 
          Else
             cCodTecnico  := T_TECNICO->AA1_CODTEC
             cNomeTecnico := T_TECNICO->AA1_NOMTEC
          Endif

          // #################################################
          // Pesquisa o parametrizador do App At Automatech ##
          // #################################################
          If Select("T_PARAMETROS") > 0
             T_PARAMETROS->( dbCloseArea() )
          EndIf

          cSql := ""
          cSql := "SELECT ZTR_PESQ,"
          cSql += "       ZTR_OCOR,"
          cSql += "       ZTR_POSI "
          cSql += "  FROM " + RetSqlName("ZTR")
          cSql += " WHERE D_E_L_E_T_ = ''"

          cSql := ChangeQuery( cSql )
          dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PARAMETROS", .T., .T. )

          If T_PARAMETROS->( EOF() )
             cPesquisas := "N"
          Else

             cPesquisas := "N"                              

             For nX = 1 to U_P_OCCURS(T_PARAMETROS->ZTR_PESQ, "|", 1)

                 If Upper(Alltrim(U_P_CORTA(T_PARAMETROS->ZTR_PESQ, "|", nX))) == Upper(Alltrim(cNomeUsua))
                    cPesquisas := "S"           
                    Exit
                 Endif
              
              Next nX
              
          Endif    

          // ##############################
          // Elebora a string de retorno ##
          // ##############################   
          cReturn := "0|" + Alltrim(cCUsuario) + "|" + Alltrim(cNomeUsua) + "|" + cCodTecnico + "|" + cNomeTecnico + "|" + cPesquisas + "|" + "T" + "|"      
       Else
  	      cReturn := "1|Usuario ou Senha Invalidos|xxxxxxxxxxxxxxxxxxxx|000000|xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx|S|" + "T" + "|"      
       Endif

    Else
                                                                                       	
 	   cReturn := "1|Usuario ou Senha Invalidos|xxxxxxxxxxxxxxxxxxxx|000000|xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx|N|" + "T" + "|"      
    
    Endif

	PswOrder(1)

Return(cReturn)

// ######################################################################################################
// Função que pesquisa o login e senha na tabela de Clientes Autorizados a acessar o App AT Automaetch ##
// ######################################################################################################
Static Function AtCliLogin(cUserx, cSenhax)
                
   Local cSql         := ""
   Local cCUsuario    := ""
   Local cNomeUsua    := ""
   Local cCodTecnico  := ""
   Local cNomeTecnico := "" 
   Local cReturn      := ""
   Local ix           := 0

   // #################################
   // Seleciona a Ordem de Indexação ##
   // #################################
   If Select("T_CLIENTES") > 0
      T_CLIENTES->( dbCloseArea() )
   EndIf

   cSql := ""
   cSql := "SELECT ZTX.ZTX_FILIAL,"
   cSql += "       ZTX.ZTX_CLIE  ,"
   cSql += "       ZTX.ZTX_LOJA  ,"
   cSql += "       SA1.A1_NOME   ,"
   cSql += "       ZTX.ZTX_LOGI  ,"
   cSql += " 	   ZTX.ZTX_SENH  ,"
   cSql += "       ZTX.ZTX_UTIL  ,"
   cSql += "       ZTX.ZTX_DELE  ,"
   cSql += "       ZTX.ZTX_BLOQ   "
   cSql += "  FROM " + RetSqlName("ZTX") + " ZTX, "
   cSql += "       " + RetSqlName("SA1") + " SA1  "
   cSql += " WHERE RTRIM(LTRIM(UPPER(ZTX.ZTX_LOGI))) = '" + Alltrim(UPPER(cUserx)) + "'"
   cSql += "   AND ZTX.ZTX_DELE = ''
   cSql += "   AND SA1.A1_COD   = ZTX.ZTX_CLIE "
   cSql += "   AND SA1.A1_LOJA  = ZTX.ZTX_LOJA "

   cSql := ChangeQuery( cSql )
   dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTES", .T., .T. )

   If T_CLIENTES->( EOF() )

      cReturn := "1|Usuario ou Senha Invalidos|xxxxxxxxxxxxxxxxxxxx|000000|xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx|N|C|"   

   Else

      If Alltrim(Upper(T_CLIENTES->ZTX_SENH)) <> Alltrim(Upper(cSenhax))
         cReturn := "1|Usuario ou Senha Invalidos|xxxxxxxxxxxxxxxxxxxx|000000|xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx|N|C|"      
         Return(cReturn)
      Endif
      
      If Empty(Alltrim(T_CLIENTES->ZTX_UTIL))
         cReturn := "1|Nenhuma loja parametrizada para visualizacao|xxxxxxxxxxxxxxxxxxxx|000000|xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx|N|C|"
         Return(cReturn)
      Endif
      
      // #####################################
      // Verifica se cliente está bloqueado ##
      // #####################################
      If Alltrim(T_CLIENTES->ZTX_BLOQ) == "S"
         cReturn := "1|Seu acesso esta bloqueado|xxxxxxxxxxxxxxxxxxxx|000000|xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx|N|C|"
         Return(cReturn)
      Endif
     
      cReturn := "0|" + Alltrim(T_CLIENTES->ZTX_CLIE)    + "|" + ;
                        Alltrim(T_CLIENTES->A1_NOME)     + "|" + ;
                        "000000"                         + "|" + ;
                        "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx" + "|" + ;
                        "N"                              + "|" + ;
                        "C"                              + "|"
   Endif          

Return(cReturn)