#include "Totvs.ch"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TbiConn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao ³ PORTALLICENCIADO ³ Autor ³ Denis Rodrigues ³Data ³ 20/10/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ WebService de Controle de Contratos dos Licenciados        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente S.C Internacional                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSSERVICE PORTALLICENCIADO DESCRIPTION "Portal do Licenciado S.C Internacional"

	WSDATA LISTACONTRATOS  AS RetListaContratos
	WSDATA LOGINPORTALSCI  AS RetResultLogin
	WSDATA LISTALANCAVENDA AS RetListaLancaVenda
	WSDATA ATUALIZAVENDAS  AS RetAtualizaVendas
	WSDATA VISUALIZALANC   AS RetVisualizaLanc
	WSDATA LISTAETIQUETAS  AS RetListaEtiquetas
	WSDATA ATUALIZATIQUETA AS RetAtualizaEtiqueta
	WSDATA ESQUECISENHA	   AS RetEsqueciSenha
	WSDATA IMPRIMIBOLETO   AS RetImprimiBoleto
	WSDATA LISTAPRODUTOS   AS RetListaProdutos 
	WSDATA SALVAPRODUTOS   AS RetSalvaProdutos
	
	WSDATA cWEmpresa   AS String
	WSDATA cWFilial    AS String
	WSDATA cWSUsuario  AS String
	WSDATA cWSSenha    AS String
	
	WSDATA cCNPJ	   AS String
	WSDATA cTipoLogin  AS String
	WSDATA cChvPortal  AS String
	WSDATA cZ9_NUMCTO  AS String 
	WSDATA cZ9_REVCTO  AS String
	WSDATA cZ9_CODCLI  AS String
	WSDATA cZ9_LOJCLI  AS String
	WSDATA cZ9_PERIODO AS String
	WSDATA cZ9_DTINIPE AS String
	WSDATA cZ9_DTFIMPE AS String
	WSDATA cZ9_VALOR   AS String
	WSDATA cZ9_CGC	   AS String
	WSDATA cZ9_VLRLIQ  AS String
	WSDATA cZ9_QUANT   AS String 
	WSDATA cTipoOper   AS String
	
	WSDATA cCNPJCliente AS String
	WSDATA cDtEntrega   AS String
	WSDATA cQuantEtiq   AS String
	
	WSDATA cZ9_PREFIXO AS String
	WSDATA cZ9_NUM		 AS String
	WSDATA cZ9_PARCELA AS String
	WSDATA cZ9_TIPO	 AS String
	WSDATA cZ9_PORTADO AS String
	WSDATA cZ9_NUMBCO	 AS String
	WSDATA cZ9_CLIENTE AS String
	WSDATA cZ9_LOJA	 AS String
	
	WSDATA cZA_CODPDV  AS String
	WSDATA cZA_CODPRO  AS String
 	
	WSMETHOD GETLISTACONTRATOS  DESCRIPTION "Método para listar os contratos do Cliente logado."
	WSMETHOD GETLOGINPORTALSCI	 DESCRIPTION "Método para validar o login e senha do Licenciado ou Fornecedor."
	WSMETHOD GETLISTALANCAVENDA DESCRIPTION "Método para listar os Lançamentos de Venda do Licenciado."
	WSMETHOD GETATUALIZAVENDAS  DESCRIPTION "Método para incluir, alterar e excluir um lançamento de Venda do Licenciado."
	WSMETHOD GETVISUALIZALANC   DESCRIPTION "Método para visualizar o Lançamento de Venda."
	WSMETHOD GETLISTAETIQUETAS  DESCRIPTION "Método para Listar os Lançamentos de Etiquetas Holográficas."
	WSMETHOD GETATUALIZATIQUETA DESCRIPTION "Método para incluir, alterar e excluir um Lançamento de Etiquetas Holográficas."
	WSMETHOD GETESQUECISENHA	 DESCRIPTION "Método para enviar e-mail informando a nova senha do Fornecedor ou Licenciado." 
	WSMETHOD GETIMPRIMIBOLETO	 DESCRIPTION "Método que gera o boleto e disponibiliza em forma de link para download."
	WSMETHOD GETLISTAPRODUTOS	 DESCRIPTION "Método para listar os produtos do Licenciado."
	WSMETHOD GETSALVAPRODUTOS	 DESCRIPTION "Método para salvar a lista de produtos do Lançamento de Venda do Licenciado.	

ENDWSSERVICE

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao ³GETLOGINPORTALSCI³ Autor ³ Denis Rodrigues ³ Data ³  20/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida o login e senha do Fornecedor/Licenciado no Portal  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 - Codigo da Empresa no Sistema                       ³±±
±±³          ³ cExp2 - Codigo da Filial no Sistema                        ³±±
±±³          ³ cExp3 - Usuario de acesso ao Servico do WS                 ³±±
±±³          ³ cExp4 - Senha de acesso ao Servico do WS                   ³±±
±±³          ³ cExp5 - CNPJ do Fornecedor/Licenciado                      ³±±
±±³          ³ cExp6 - Chave de acesso ao Portal                          ³±±
±±³          ³ cExp7 - Tipo de Login L=Licenciado / F = Fornecedor        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente S.C Internacional                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD GETLOGINPORTALSCI WSRECEIVE cWEmpresa, cWFilial, cWSUsuario, cWSSenha, cCNPJ, cChvPortal, cTipoLogin WSSEND LOGINPORTALSCI WSSERVICE PORTALLICENCIADO

	Local cQuery 	 := ""
	Local cAliasTmp := GetNextAlias()
	Local aRet 		 := {"",""}
	Local oNewLogin
	
	RpcClearEnv()
	RpcSetType( 3 )
 	RpcSetenv( cWEmpresa, cWFilial,,,,GetEnvServer(),{"SA1","SA2"} )
	
	// Valida Usuario e Senha do Servico WebService
	If !WS10Login( cWEmpresa, cWFilial, cWSUsuario, cWSSenha )
	
  		LOGINPORTALSCI := WsClassNew( "RetResultLogin" )
  		LOGINPORTALSCI:RetLoginPortal := {}
  		
  		oNewLogin := WsClassNew("DadosLoginPortal")
  		oNewLogin:_cLoginSCI := "false"
  		oNewLogin:_cRetMsn	:= "Usuário ou senha do Serviço Web Services esta inválida." 
 		oNewLogin:cCliFor	   := ""
		oNewLogin:cCodLoja   := ""
		oNewLogin:cNomReduz  := ""
		oNewLogin:cCodCGC	   :=	""
		aAdd( ::LOGINPORTALSCI:RetLoginPortal, oNewLogin )
  	  	 	
  	 	LOGINPORTALSCI:RetLojaLic := {}	
		oNewLogin := WsClassNew("LojasLicenciado")
		oNewLogin:cCodLoja  := ""
  		oNewLogin:cDescLoja := ""
  		oNewLogin:cCGCLoja  := "" 
		aAdd( ::LOGINPORTALSCI:RetLojaLic, oNewLogin )  		
  		
		lOK := .F.
	
	Else// Se o login no servico estiver OK
	
		// Valida o CNPJ e senha do Licenciado
		aRet := WS10ValUser( cWEmpresa,cWFilial,cCNPJ,cChvPortal,cTipoLogin )
						
		If aRet[1][1] == "true"
	  		
	  		LOGINPORTALSCI := WsClassNew( "RetResultLogin" )
	  		LOGINPORTALSCI:RetLoginPortal := {}
	  		
	  		oNewLogin := WsClassNew("DadosLoginPortal")
	  		oNewLogin:_cLoginSCI := aRet[1][1]
	  		oNewLogin:_cRetMsn	:= aRet[1][2] 
	 		oNewLogin:cCliFor	   := aRet[1][3]
			oNewLogin:cCodLoja   := aRet[1][4]
			oNewLogin:cNomReduz  := aRet[1][5]
			oNewLogin:cCodCGC	   :=	aRet[1][6]
			aAdd( ::LOGINPORTALSCI:RetLoginPortal, oNewLogin )
	
	  		cQuery := " SELECT ZB_CODPDV,
		   cQuery += "        ZB_NOME,"
		   cQuery += "        ZB_CNPJ"
			cQuery += " FROM "+RetSQLName("SZB")
			cQuery += " WHERE ZB_FILIAL = '"+xFilial("SZB")+"'"
	  		cQuery += "   AND ZB_CODLIC = '"+aRet[1][3]+"'"
	  		cQuery += "   AND ZB_LOJLIC = '"+aRet[1][4]+"'"
	  		cQuery += "   AND D_E_L_E_T_<>'*'"
	  		cQuery := ChangeQuery(cQuery)
	  		dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T. )
	  		
	  		If ( cAliasTmp )->( !EOF() )
	  		
	  			While ( cAliasTmp )->( !EOF() )
  		  	 
			  	 	LOGINPORTALSCI:RetLojaLic := {}	
					oNewLogin := WsClassNew("LojasLicenciado")
					oNewLogin:cCodLoja  := ( cAliasTmp )->ZB_CODPDV
			  		oNewLogin:cDescLoja := AllTrim( ( cAliasTmp )->ZB_NOME )
			  		oNewLogin:cCGCLoja  := ( cAliasTmp )->ZB_CNPJ 
					aAdd( ::LOGINPORTALSCI:RetLojaLic, oNewLogin )
					
					( cAliasTmp )->( dbSkip() )
				
				EndDo
				
			Else

			  	 	LOGINPORTALSCI:RetLojaLic := {}	
					oNewLogin := WsClassNew("LojasLicenciado")
					oNewLogin:cCodLoja  := ""
			  		oNewLogin:cDescLoja := ""
			  		oNewLogin:cCGCLoja  := "" 
					aAdd( ::LOGINPORTALSCI:RetLojaLic, oNewLogin )
			
			EndIf
			
			( cAliasTmp )->( dbCloseArea() )
			  
			lOK := .T.
			
		Else

	  		LOGINPORTALSCI := WsClassNew( "RetResultLogin" )
	  		LOGINPORTALSCI:RetLoginPortal := {}
	  		
	  		oNewLogin := WsClassNew("DadosLoginPortal")
	  		oNewLogin:_cLoginSCI := aRet[1][1]
	  		oNewLogin:_cRetMsn	:= aRet[1][2] 
	 		oNewLogin:cCliFor	   := aRet[1][3]
			oNewLogin:cCodLoja   := aRet[1][4]
			oNewLogin:cNomReduz  := aRet[1][5]
			oNewLogin:cCodCGC	   :=	aRet[1][6]
			aAdd( ::LOGINPORTALSCI:RetLoginPortal, oNewLogin )
	  	 
	  	 	LOGINPORTALSCI:RetLojaLic := {}	
			oNewLogin := WsClassNew("LojasLicenciado")
			oNewLogin:cCodLoja  := ""
	  		oNewLogin:cDescLoja := ""
	  		oNewLogin:cCGCLoja  := "" 
			aAdd( ::LOGINPORTALSCI:RetLojaLic, oNewLogin )  	  		 
			lOK := .F.		
					
		EndIf
	
	EndIf	
		
Return( .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Estrutura do Metodo GETLOGINPORTALSCI  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSSTRUCT RetResultLogin
  WSDATA RetLoginPortal AS ARRAY OF DadosLoginPortal
  WSDATA RetLojaLic 		AS ARRAY OF LojasLicenciado 
ENDWSSTRUCT

WSSTRUCT DadosLoginPortal

	WSDATA _cLoginSCI AS String
	WSDATA _cRetMsn   AS String 
	WSDATA cCliFor	   AS String
	WSDATA cCodLoja   AS String
	WSDATA cNomReduz  AS String
	WSDATA cCodCGC	   AS String

ENDWSSTRUCT

WSSTRUCT LojasLicenciado

  WSDATA cCodLoja  AS String
  WSDATA cDescLoja AS String
  WSDATA cCGCLoja	 AS String  
  
ENDWSSTRUCT


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao ³GETLISTACONTRATOS³ Autor ³ Denis Rodrigues ³ Data ³  20/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Lista os contratos do Cliente                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 - Codigo da Empresa no Sistema                       ³±±
±±³          ³ cExp2 - Codigo da Filial no Sistema                        ³±±
±±³          ³ cExp3 - Usuario de acesso ao Servico do WS                 ³±±
±±³          ³ cExp4 - Senha de acesso ao Servico do WS                   ³±±
±±³          ³ cExp5 - CNPJ do Fornecedor/Licenciado                      ³±±
±±³          ³ cExp6 - Chave de acesso ao Portal                          ³±±
±±³          ³ cExp7 - Tipo de Login L=Licenciado / F = Fornecedor        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente S.C Internacional                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD GETLISTACONTRATOS WSRECEIVE cWEmpresa, cWFilial, cWSUsuario, cWSSenha, cCNPJ, cChvPortal, cTipoLogin WSSEND LISTACONTRATOS WSSERVICE PORTALLICENCIADO

	Local cQuery     := ""
	Local cMsg 		  := ""
	Local cAliasTmp  := GetNextAlias()
	Local cFormatAno := ""
	Local cFormatMes := ""
	Local cFormatDia := ""
	Local lOK		  := .T.	
	Local aRet		  := {}	
	Local oNewContrato

 	RpcClearEnv()
  	RpcSetType( 3 )
  	RpcSetenv( cWEmpresa, cWFilial,,,,GetEnvServer(),{"CN9","SA1"} )
	
	// Valida Usuario e Senha do Servico WebService
	If !WS10Login( cWEmpresa, cWFilial, cWSUsuario, cWSSenha )
	
  		LISTACONTRATOS := WsClassNew( "RetListaContratos" )
   	LISTACONTRATOS:_StatusSCI := {}	
   	
		oNewContrato := WsClassNew( "SCIStatus" )
		oNewContrato:_lRetorno := "false"
		oNewContrato:cSCIMsg   := "Usuário ou senha do Serviço Web Services esta inválida."
		aAdd( ::LISTACONTRATOS:_StatusSCI, oNewContrato )
				
		LISTACONTRATOS:RetDadosSCI := {}		
		oNewContrato := WsClassNew( "DadosContratos" )
		oNewContrato:cCN9_SITUAC := ""
		oNewContrato:cCN9_NUMERO := ""
		oNewContrato:cCN9_REVISA := ""
		oNewContrato:cCN9_DTINIC := ""
		oNewContrato:cCN9_DTFIM  := ""
		oNewContrato:cCN9_DTULST := ""
		aAdd( ::LISTACONTRATOS:RetDadosSCI, oNewContrato )
		lOK := .F.

	Else// Se o acesso ao Servico estiver OK, testa o login e senha do usuario
			
		// Valida o CNPJ e senha do Licenciado
		aRet := WS10ValUser( cWEmpresa,cWFilial,cCNPJ,cChvPortal,cTipoLogin )
			
		If aRet[1][1] == "false"
	
	  		LISTACONTRATOS := WsClassNew( "RetListaContratos" )
	   	LISTACONTRATOS:_StatusSCI := {}	
	   	
			oNewContrato := WsClassNew( "SCIStatus" )
			oNewContrato:_lRetorno := aRet[1][1]
			oNewContrato:cSCIMsg   := aRet[1][2]
			aAdd( ::LISTACONTRATOS:_StatusSCI, oNewContrato )
					
			LISTACONTRATOS:RetDadosSCI := {}		
			oNewContrato := WsClassNew( "DadosContratos" )
			oNewContrato:cCN9_SITUAC := ""
			oNewContrato:cCN9_NUMERO := ""
			oNewContrato:cCN9_REVISA := ""
			oNewContrato:cCN9_DTINIC := ""
			oNewContrato:cCN9_DTFIM  := ""
			oNewContrato:cCN9_DTULST := ""
			aAdd( ::LISTACONTRATOS:RetDadosSCI, oNewContrato )
			lOK := .F.
			
		EndIf
					
	EndIf	
	
	If lOK
	
		cQuery := " SELECT CN9.CN9_SITUAC,"
		cQuery += "			 CN9.CN9_NUMERO,"
		cQuery += "        CN9.CN9_REVISA,"
	   cQuery += "        CN9.CN9_DTINIC,"
		cQuery += "        CN9.CN9_DTFIM,"
		cQuery += "        CN9.CN9_DTULST,"
	   cQuery += "        SA1.A1_COD,"
	   cQuery += "        SA1.A1_CGC,"
		cQuery += "        SA1.A1_NOME"
	   cQuery += " FROM "+RetSQLName("CN9")+" CN9,"
	   cQuery +=         +RetSQLName("SA1")+" SA1"
		cQuery += " WHERE CN9.CN9_FILIAL = '"+xFilial( "CN9" )+"'"
	  	//cQuery += "   AND CN9.CN9_TPCTO  = '001'"
	  	cQuery += "   AND CN9.CN9_SITUAC = '05'"
	   cQuery += "   AND CN9.D_E_L_E_T_ <>'*'"
	   
	  	cQuery += "   AND SA1.A1_COD     =  CN9.CN9_CLIENT"
	   cQuery += "   AND SA1.A1_LOJA    =  CN9.CN9_LOJACL"
	   cQuery += "   AND SA1.A1_CGC     =  '"+AllTrim( cCNPJ )+"'"
	   cQuery += "   AND SA1.A1_ACPORT  =  'S'"
	   cQuery += "   AND SA1.A1_MSBLQL  <> 'S'"
	   cQuery += "   AND SA1.D_E_L_E_T_ <> '*'"
	   
	   cQuery += " ORDER BY CN9.CN9_NUMERO, CN9.CN9_REVISA "
	   cQuery := ChangeQuery( cQuery )
	   dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery), cAliasTmp,.F.,.T. )
   
	   If ( cAliasTmp )->( !EOF() )
	
	  		LISTACONTRATOS := WsClassNew("RetListaContratos")
	   	LISTACONTRATOS:_StatusSCI := {}	
	   	
			oNewContrato := WsClassNew("SCIStatus")
			oNewContrato:_lRetorno := "true"
			oNewContrato:cSCIMsg   := ""
			aAdd( ::LISTACONTRATOS:_StatusSCI, oNewContrato )
			
			While ( cAliasTmp )->( !EOF() )
						
				LISTACONTRATOS:RetDadosSCI  := {}		
				oNewContrato := WsClassNew("DadosContratos")
				
				oNewContrato:cCN9_SITUAC := ( cAliasTmp )->CN9_SITUAC
				oNewContrato:cCN9_NUMERO := ( cAliasTmp )->CN9_NUMERO
				oNewContrato:cCN9_REVISA := ( cAliasTmp )->CN9_REVISA
			
				cFormatAno := SubStr( ( cAliasTmp )->CN9_DTINIC, 1,4 )
				cFormatMes := SubStr( ( cAliasTmp )->CN9_DTINIC, 5,2 )
				cFormatDia := SubStr( ( cAliasTmp )->CN9_DTINIC, 7,2 )	
				oNewContrato:cCN9_DTINIC := cFormatAno+"-"+cFormatMes+"-"+cFormatDia
				
				cFormatAno := SubStr( ( cAliasTmp )->CN9_DTFIM, 1,4 )
				cFormatMes := SubStr( ( cAliasTmp )->CN9_DTFIM, 5,2 )
				cFormatDia := SubStr( ( cAliasTmp )->CN9_DTFIM, 7,2 )
				oNewContrato:cCN9_DTFIM  := cFormatAno+"-"+cFormatMes+"-"+cFormatDia

				If Empty( ( cAliasTmp )->CN9_DTULST )
					oNewContrato:cCN9_DTULST := AllTrim( ( cAliasTmp )->CN9_DTULST )
				Else
				
					cFormatAno := SubStr( ( cAliasTmp )->CN9_DTULST, 1,4 )
					cFormatMes := SubStr( ( cAliasTmp )->CN9_DTULST, 5,2 )
					cFormatDia := SubStr( ( cAliasTmp )->CN9_DTULST, 7,2 )				 
					oNewContrato:cCN9_DTULST := cFormatAno+"-"+cFormatMes+"-"+cFormatDia
									
				EndIf
				 
				aAdd( ::LISTACONTRATOS:RetDadosSCI, oNewContrato )
				
				( cAliasTmp )->( dbSkip() )
				
			EndDo
	   		
	   Else
	   
	     	cMsg := "Contratos não localizados. Verifique:\n"
	     	cMsg += "- Se existem contratos relacionados a seu CNPJ.\n"
	   	cMsg += "- Se o CNPJ encontra-se ativo.\n"
	   	cMsg += "- Se o CNPJ esta habilitado para acessar o Portal.\n"
	    	
	  		LISTACONTRATOS := WsClassNew( "RetListaContratos" )
	   	LISTACONTRATOS:_StatusSCI := {}	
	   	
			oNewContrato := WsClassNew( "SCIStatus" )
			oNewContrato:_lRetorno := "false"
			oNewContrato:cSCIMsg   := cMsg
			aAdd( ::LISTACONTRATOS:_StatusSCI, oNewContrato )
					
			LISTACONTRATOS:RetDadosSCI  := {}		
			oNewContrato := WsClassNew( "DadosContratos" )
			oNewContrato:cCN9_SITUAC := ""
			oNewContrato:cCN9_NUMERO := ""
			oNewContrato:cCN9_REVISA := ""
			oNewContrato:cCN9_DTINIC := ""
			oNewContrato:cCN9_DTFIM  := ""
			oNewContrato:cCN9_DTULST := ""
			aAdd( ::LISTACONTRATOS:RetDadosSCI, oNewContrato )			
				
	   EndIf
	   ( cAliasTmp )->( dbCloseArea() )	
	
	EndIf
	   
Return(.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Estrutura do Metodo GETLISTACONTRATOS  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSSTRUCT RetListaContratos
  WSDATA _StatusSCI  AS ARRAY OF SCIStatus
  WSDATA RetDadosSCI AS ARRAY OF DadosContratos 
ENDWSSTRUCT

WSSTRUCT SCIStatus

  WSDATA _lRetorno AS String
  WSDATA cSCIMsg   AS String
  
ENDWSSTRUCT

WSSTRUCT DadosContratos

	WSDATA cCN9_SITUAC AS String
	WSDATA cCN9_NUMERO AS String
	WSDATA cCN9_REVISA AS String
	WSDATA cCN9_DTINIC AS String
	WSDATA cCN9_DTFIM  AS String
	WSDATA cCN9_DTULST AS String
	
ENDWSSTRUCT

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao ³GETLISTALANCAVENDA³ Autor ³ Denis Rodrigues ³ Data ³ 20/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Lista os Lancamentos de Vendas do Licenciado               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 - Codigo da Empresa no Sistema                       ³±±
±±³          ³ cExp2 - Codigo da Filial no Sistema                        ³±±
±±³          ³ cExp3 - Usuario de acesso ao Servico do WS                 ³±±
±±³          ³ cExp4 - Senha de acesso ao Servico do WS                   ³±±
±±³          ³ cExp5 - CNPJ do Fornecedor/Licenciado                      ³±±
±±³          ³ cExp6 - Chave de acesso ao Portal                          ³±±
±±³          ³ cExp7 - Tipo de Login L=Licenciado / F = Fornecedor        ³±±
±±³          ³ cExp8 - Numero do Contrato                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente S.C Internacional                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD GETLISTALANCAVENDA WSRECEIVE cWEmpresa, cWFilial, cWSUsuario, cWSSenha,cCNPJ, cChvPortal, cTipoLogin,cZ9_NUMCTO WSSEND LISTALANCAVENDA WSSERVICE PORTALLICENCIADO

	Local cAliasTmp  := GetNextAlias()
	Local cQuery  	  := ""
	Local cMsg       := ""
	Local cFormatAno := ""
	Local cFormatMes := ""
	Local cFormatDia := ""
	Local aRet	  	  := {}
	Local lOK		  := .T.
	Local oLancVenda

	RpcClearEnv()
	RpcSetType( 3 )
	RpcSetenv( cWEmpresa, cWFilial,,,,GetEnvServer(),{"CN9","SA1","SA2","SZ9"} )
	
	// Valida Usuario e Senha do Servico WebService
	If !WS10Login( cWEmpresa, cWFilial, cWSUsuario, cWSSenha )
	
  		LISTALANCAVENDA := WsClassNew( "RetListaLancaVenda" )
   	LISTALANCAVENDA:_StatusLLV := {}	
   	
		oLancVenda := WsClassNew( "SCIStatusLLV" )
		oLancVenda:_lRetorno := "false"
		oLancVenda:cSCIMsg   := "Usuário ou senha do Serviço Web Services esta inválida."
		aAdd( ::LISTALANCAVENDA:_StatusLLV, oLancVenda )
				
		LISTALANCAVENDA:RetLancVendas  := {}		
		oLancVenda := WsClassNew( "DadosLancVendas" )
		oLancVenda:cZ9_NUMCTO   := ""
		oLancVenda:cZ9_REVCTO   := ""
		oLancVenda:cZ9_PERIODO  := ""
		oLancVenda:cZ9_DTINIPER := ""
	   oLancVenda:cZ9_DTFIMPER := ""
	   oLancVenda:cZ9_VALOR	   := ""
	   oLancVenda:cZ9_STATUS	:= ""
	   oLancVenda:cZ9_VLRLIQ	:= ""
		oLancVenda:cZ9_QUANT	   := ""
		oLancVenda:cZ9_PREFIXO  := ""
		oLancVenda:cZ9_NUM		:= ""
		oLancVenda:cZ9_PARCELA  := ""
		oLancVenda:cZ9_TIPO	   := ""		
		oLancVenda:cZ9_PORTADO	:= ""		
		oLancVenda:cZ9_NUMBCO	:= ""		
		aAdd( ::LISTALANCAVENDA:RetLancVendas, oLancVenda )
		lOK := .F.

	Else// Se o acesso ao Servico estiver OK, testa o login e senha do usuario
			
		// Valida o CNPJ e senha do Licenciado
		aRet := WS10ValUser( cWEmpresa,cWFilial,cCNPJ,cChvPortal,cTipoLogin )
			
		If aRet[1][1] == "false"
	
	  		LISTALANCAVENDA := WsClassNew( "RetListaLancaVenda" )
	   	LISTALANCAVENDA:_StatusLLV := {}	
	   	
			oLancVenda := WsClassNew( "SCIStatusLLV" )
			oLancVenda:_lRetorno := aRet[1][1]
			oLancVenda:cSCIMsg   := aRet[1][2]
			aAdd( ::LISTALANCAVENDA:_StatusLLV, oLancVenda )
					
			LISTALANCAVENDA:RetLancVendas  := {}		
			oLancVenda := WsClassNew( "DadosLancVendas" )
			oLancVenda:cZ9_NUMCTO   := ""
			oLancVenda:cZ9_REVCTO   := ""
			oLancVenda:cZ9_PERIODO  := ""
			oLancVenda:cZ9_DTINIPER := ""
		   oLancVenda:cZ9_DTFIMPER := ""
		   oLancVenda:cZ9_VALOR		:= ""
		   oLancVenda:cZ9_STATUS	:= ""
	   	oLancVenda:cZ9_VLRLIQ	:= ""
			oLancVenda:cZ9_QUANT		:= ""
			oLancVenda:cZ9_PREFIXO  := ""
			oLancVenda:cZ9_NUM		:= ""
			oLancVenda:cZ9_PARCELA  := ""
			oLancVenda:cZ9_TIPO	   := ""
			oLancVenda:cZ9_PORTADO	:= ""
			oLancVenda:cZ9_NUMBCO	:= ""
			aAdd( ::LISTALANCAVENDA:RetLancVendas, oLancVenda )
			lOK := .F.
			
		EndIf
					
	EndIf	
	
	If lOK
	
		cQuery := " SELECT  Z9_NUMCTO "
		cQuery += "        ,Z9_REVCTO "
		cQuery += "        ,Z9_PERIODO "
		cQuery += "        ,Z9_DTINIPE "
		cQuery += "        ,Z9_DTFIMPE "
		cQuery += "        ,Z9_VALOR "
		cQuery += "        ,Z9_STATUS "
		cQuery += "        ,Z9_VLRLIQ "
		cQuery += "        ,Z9_QUANT "
		cQuery += "        ,Z9_PREFIXO "
		cQuery += "        ,Z9_NUM "
		cQuery += "        ,Z9_PARCELA "
		cQuery += "        ,Z9_TIPO "
		cQuery += "        ,Z9_PORTADO "
		cQuery += "        ,Z9_NUMBCO "
		cQuery += " FROM "+RetSQLName("SZ9")
		cQuery += " WHERE Z9_FILIAL  = '"+ xFilial("SZ9") +"'"
		cQuery += "   AND Z9_CGC     = '"+ cCNPJ +"'"
		cQuery += "   AND Z9_NUMCTO  = '"+ cZ9_NUMCTO +"'"
		cQuery += "   AND D_E_L_E_T_ <> '*'"
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery), cAliasTmp,.F.,.T. )


	   If ( cAliasTmp )->( !EOF() )
	   
	   	LISTALANCAVENDA := WsClassNew( "RetListaLancaVenda" )
	   	LISTALANCAVENDA:_StatusLLV := {}	
	   	
			oLancVenda := WsClassNew( "SCIStatusLLV" )
			oLancVenda:_lRetorno := "true"
			oLancVenda:cSCIMsg   := "OK"
			aAdd( ::LISTALANCAVENDA:_StatusLLV, oLancVenda )
	   
	   	While ( cAliasTmp )->( !EOF() )

				LISTALANCAVENDA:RetLancVendas  := {}		
				oLancVenda := WsClassNew( "DadosLancVendas" )
				oLancVenda:cZ9_NUMCTO   := ( cAliasTmp )->Z9_NUMCTO
				oLancVenda:cZ9_REVCTO   := ( cAliasTmp )->Z9_REVCTO
				oLancVenda:cZ9_PERIODO  := SubStr( ( cAliasTmp )->Z9_PERIODO,1,4 )+"-"+SubStr( ( cAliasTmp )->Z9_PERIODO,5,2 )
				
				cFormatAno := SubStr( ( cAliasTmp )->Z9_DTINIPE, 1,4 )
				cFormatMes := SubStr( ( cAliasTmp )->Z9_DTINIPE, 5,2 )
				cFormatDia := SubStr( ( cAliasTmp )->Z9_DTINIPE, 7,2 )
				oLancVenda:cZ9_DTINIPER := cFormatAno+"-"+cFormatMes+"-"+cFormatDia
				
				cFormatAno := SubStr( ( cAliasTmp )->Z9_DTFIMPE, 1,4 )
				cFormatMes := SubStr( ( cAliasTmp )->Z9_DTFIMPE, 5,2 )
				cFormatDia := SubStr( ( cAliasTmp )->Z9_DTFIMPE, 7,2 )
			   oLancVenda:cZ9_DTFIMPER := cFormatAno+"-"+cFormatMes+"-"+cFormatDia
			   
			   oLancVenda:cZ9_VALOR	   := AllTrim( StrTran( StrTran( TransForm( ( cAliasTmp )->Z9_VALOR, PesqPict("SZ9","Z9_VALOR") ), ".",""),",","." ) )
			   oLancVenda:cZ9_STATUS	:= ( cAliasTmp )->Z9_STATUS
			  	oLancVenda:cZ9_VLRLIQ	:= AllTrim( StrTran( StrTran( TransForm( ( cAliasTmp )->Z9_VLRLIQ, PesqPict("SZ9","Z9_VLRLIQ") ), ".",""),",","." ) )
				oLancVenda:cZ9_QUANT	   := cValToChar( ( cAliasTmp )->Z9_QUANT )
				
				oLancVenda:cZ9_PREFIXO  := ( cAliasTmp )->Z9_PREFIXO
				oLancVenda:cZ9_NUM		:= ( cAliasTmp )->Z9_NUM
				oLancVenda:cZ9_PARCELA  := ( cAliasTmp )->Z9_PARCELA
				oLancVenda:cZ9_TIPO	   := ( cAliasTmp )->Z9_TIPO
				oLancVenda:cZ9_PORTADO	:= ( cAliasTmp )->Z9_PORTADO
				oLancVenda:cZ9_NUMBCO	:= ( cAliasTmp )->Z9_NUMBCO
				aAdd( ::LISTALANCAVENDA:RetLancVendas, oLancVenda )
				
	   		( cAliasTmp )->( dbSkip() )
	   		
	   	EndDo

	   Else

	   	LISTALANCAVENDA := WsClassNew( "RetListaLancaVenda" )
	   	LISTALANCAVENDA:_StatusLLV := {}	
	   	
			oLancVenda := WsClassNew( "SCIStatusLLV" )
			oLancVenda:_lRetorno := "false"
			oLancVenda:cSCIMsg   := "Nenhum Lançamento disponível para esse Contrato."
			aAdd( ::LISTALANCAVENDA:_StatusLLV, oLancVenda )
					
			LISTALANCAVENDA:RetLancVendas  := {}		
			oLancVenda := WsClassNew( "DadosLancVendas" )
			oLancVenda:cZ9_NUMCTO   := ""
			oLancVenda:cZ9_PERIODO  := ""
			oLancVenda:cZ9_REVCTO   := ""
			oLancVenda:cZ9_DTINIPER := ""
		   oLancVenda:cZ9_DTFIMPER := ""
		   oLancVenda:cZ9_VALOR		:= ""
		   oLancVenda:cZ9_STATUS	:= ""
			oLancVenda:cZ9_VLRLIQ	:= ""
			oLancVenda:cZ9_QUANT		:= ""
			oLancVenda:cZ9_PREFIXO  := ""
			oLancVenda:cZ9_NUM		:= ""
			oLancVenda:cZ9_PARCELA  := ""
			oLancVenda:cZ9_TIPO	   := ""		   
			oLancVenda:cZ9_PORTADO	:= ""		   
			oLancVenda:cZ9_NUMBCO	:= ""		   
			aAdd( ::LISTALANCAVENDA:RetLancVendas, oLancVenda )
				   
	   EndIf
	   ( cAliasTmp )->( dbCloseArea() )
	
	 
	EndIf
	
Return(.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Estrutura do Metodo GETLISTALANCAVENDA ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSSTRUCT RetListaLancaVenda
  WSDATA _StatusLLV    AS ARRAY OF SCIStatusLLV
  WSDATA RetLancVendas AS ARRAY OF DadosLancVendas 
ENDWSSTRUCT

WSSTRUCT SCIStatusLLV

  WSDATA _lRetorno AS String
  WSDATA cSCIMsg   AS String
  
ENDWSSTRUCT

WSSTRUCT DadosLancVendas

	WSDATA cZ9_NUMCTO   AS String
	WSDATA cZ9_REVCTO   AS String
	WSDATA cZ9_PERIODO  AS String
	WSDATA cZ9_DTINIPER AS String
   WSDATA cZ9_DTFIMPER AS String
	WSDATA cZ9_VALOR    AS String
	WSDATA cZ9_STATUS   AS String
	WSDATA cZ9_VLRLIQ	  AS String
	WSDATA cZ9_QUANT	  AS String
	WSDATA cZ9_PREFIXO  AS String
	WSDATA cZ9_NUM		  AS String
	WSDATA cZ9_PARCELA  AS String
	WSDATA cZ9_TIPO	  AS String
	WSDATA cZ9_PORTADO  AS String
	WSDATA cZ9_NUMBCO	  AS String
	
ENDWSSTRUCT

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao ³GETATUALIZAVENDAS³ Autor ³ Denis Rodrigues ³ Data ³  20/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inclui, altera e exclui um Fornecedor/Licenciado no Portal ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 - Codigo da Empresa no Sistema                       ³±±
±±³          ³ cExp2 - Codigo da Filial no Sistema                        ³±±
±±³          ³ cExp3 - Usuario de acesso ao Servico do WS                 ³±±
±±³          ³ cExp4 - Senha de acesso ao Servico do WS                   ³±±
±±³          ³ cExp5 - CNPJ do Fornecedor/Licenciado                      ³±±
±±³          ³ cExp6 - Chave de acesso ao Portal                          ³±±
±±³          ³ cExp7 - Tipo de Login L=Licenciado / F = Fornecedor        ³±±
±±³          ³ cExp8 - Numero do Contrato                                 ³±±
±±³          ³ cExp9 - Numero da Revisao                                  ³±±
±±³          ³ cExp10 - Codigo do cliente                                 ³±±
±±³          ³ cExp11 - Loja do cliente                                   ³±±
±±³          ³ cExp12 - Periodo                                           ³±±
±±³          ³ cExp13 - Data Inicial                                      ³±±
±±³          ³ cExp14 - Data Final                                        ³±±
±±³          ³ cExp15 - Valor Bruto                                       ³±±
±±³          ³ cExp16 - CNPJ                                              ³±±
±±³          ³ cExp17 - Operacao I-Incluir/A-Alterar/E-Exclui             ³±±
±±³          ³ cExp18 - Valor Liquido                                     ³±±
±±³          ³ cExp19 - Quantidade                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente S.C Internacional                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD GETATUALIZAVENDAS WSRECEIVE cWEmpresa, cWFilial, cWSUsuario, cWSSenha, cCNPJ, cChvPortal, cTipoLogin,;
                                     cZ9_NUMCTO, cZ9_REVCTO,cZ9_CODCLI, cZ9_LOJCLI,cZ9_PERIODO,cZ9_DTINIPE,;
                                     cZ9_DTFIMPE,cZ9_VALOR,cZ9_CGC, cTipoOper, cZ9_VLRLIQ, cZ9_QUANT WSSEND ATUALIZAVENDAS WSSERVICE PORTALLICENCIADO

	Local lOK 	     := .T.
	Local lExiste	  := .T.
	Local cQuery     := ""	
	Local cDtPeriodo := ""
	Local cAliasTmp  := GetNextAlias()	
	Local nExisteReg := 0
	Local nNumRecno  := 0
	                                     
	RpcClearEnv()
	RpcSetType( 3 )
	RpcSetenv( cWEmpresa, cWFilial,,,,GetEnvServer(),{"CN9","SA1","SZ9"} )
	
	// Valida Usuario e Senha do Servico WebService
	If !WS10Login( cWEmpresa, cWFilial, cWSUsuario, cWSSenha )
	
		::ATUALIZAVENDAS := WsClassNew("RetAtualizaVendas")
		::ATUALIZAVENDAS:_lRetAtu := "false"
		::ATUALIZAVENDAS:cMsgAtu  := "Usuário ou senha do Serviço Web Services esta inválida."   
		lOK := .F.

	Else// Se o acesso ao Servico estiver OK, testa o login e senha do usuario
			
		// Valida o CNPJ e senha do Licenciado
		aRet := WS10ValUser( cWEmpresa,cWFilial,cCNPJ,cChvPortal,cTipoLogin )
			
		If aRet[1][1] == "false"

			::ATUALIZAVENDAS := WsClassNew("RetAtualizaVendas")
			::ATUALIZAVENDAS:_lRetAtu := aRet[1][1]
			::ATUALIZAVENDAS:cMsgAtu  := aRet[1][2]
			lOK := .F.
			
		EndIf
					
	EndIf	
	
	If lOK
			
		Do Case
			Case AllTrim( cTipoOper ) = "I"// Incluindo um registro novo
			
				cDtPeriodo := StrTran( cZ9_PERIODO, "-","" )
				
				// Verifica a existencia do Periodo na tabela SZ9
				cQuery := " SELECT Z9_PERIODO,"
       		cQuery += "        MIN(Z9_DTINIPE) AS DTINI,"
       		cQuery += "        MAX(Z9_DTFIMPE) AS DTFIM"
				cQuery += " FROM "+RetSQLName("SZ9")
				cQuery += " WHERE Z9_FILIAL  =  '"+ xFilial("SZ9")	+"'"
       		cQuery += "   AND Z9_NUMCTO  =  '"+ cZ9_NUMCTO		+"'"
       		cQuery += "	  AND Z9_REVCTO  =  '"+ cZ9_REVCTO		+"'"
       		cQuery += "   AND Z9_CODCLI  =  '"+ cZ9_CODCLI		+"'"
       		cQuery += "   AND Z9_LOJCLI  =  '"+ cZ9_LOJCLI 		+"'"
       		cQuery += "   AND Z9_PERIODO =  '"+ cDtPeriodo		+"'"
       		cQuery += "   AND Z9_CGC 	  =  '"+ cZ9_CGC			+"'"
       		cQuery += "   AND D_E_L_E_T_ <> '*'"
				cQuery += " GROUP BY Z9_PERIODO"
				cQuery := ChangeQuery(cQuery)
				
				dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T. )
				TcSetField( cAliasTmp,"DTINI","D",08,00 )
				TcSetField( cAliasTmp,"DTFIM","D",08,00 )				
				
				If ( cAliasTmp )->( !EOF() )// Se existir o registro
				
					While ( cAliasTmp )->( !EOF() )
						     
						If ( StoD( StrTran( cZ9_DTINIPE, "-","") ) < ( cAliasTmp )->DTINI .And. ;
						     StoD( StrTran( cZ9_DTFIMPE, "-","") ) < ( cAliasTmp )->DTFIM ).Or.;
						   ( StoD( StrTran( cZ9_DTINIPE, "-","") ) > ( cAliasTmp )->DTFIM  .And.;
						     StoD( StrTran( cZ9_DTFIMPE, "-","") ) > ( cAliasTmp )->DTFIM )

							lExiste := .F.
						
						EndIf						
					
						( cAliasTmp )->( dbSkip() )
						
					EndDo
					
					If lExiste
					
						::ATUALIZAVENDAS := WsClassNew("RetAtualizaVendas")
						::ATUALIZAVENDAS:_lRetAtu := "false"
						::ATUALIZAVENDAS:cMsgAtu  := "Atualização cancelada. O Período do Lançamento já existe."
						
					Else

						dbSelectArea("SZ9")
						RecLock("SZ9",.T.)
							SZ9->Z9_FILIAL  := xFilial("SZ9")
							SZ9->Z9_NUMCTO	 := cZ9_NUMCTO
							SZ9->Z9_REVCTO	 := cZ9_REVCTO
							SZ9->Z9_CODCLI	 := cZ9_CODCLI
							SZ9->Z9_LOJCLI	 := cZ9_LOJCLI
							SZ9->Z9_NOMCLI  := Posicione( "SA1",1,xFilial("SA1") + cZ9_CODCLI + cZ9_LOJCLI, "A1_NOME" )
							SZ9->Z9_PERIODO := cDtPeriodo
							SZ9->Z9_DTINIPE := StoD( StrTran( cZ9_DTINIPE,"-","" ) )
							SZ9->Z9_DTFIMPE := StoD( StrTran( cZ9_DTFIMPE,"-","" ) )
							SZ9->Z9_VALOR 	 := Val( cZ9_VALOR )
							SZ9->Z9_STATUS  := "A"
							SZ9->Z9_CGC		 := cZ9_CGC
							SZ9->Z9_VLRLIQ	 := Val( cZ9_VLRLIQ )
							SZ9->Z9_QUANT	 := Val( cZ9_QUANT )
						MsUnLock()
				
						::ATUALIZAVENDAS := WsClassNew("RetAtualizaVendas")
						::ATUALIZAVENDAS:_lRetAtu := "true"
						::ATUALIZAVENDAS:cMsgAtu  := "Inclusão do Lançamento realizado com sucesso."
										
					EndIf
				
				Else// Se nao existir registro pode 
				
					dbSelectArea("SZ9")
					RecLock("SZ9",.T.)
						SZ9->Z9_FILIAL  := xFilial("SZ9")
						SZ9->Z9_NUMCTO	 := cZ9_NUMCTO
						SZ9->Z9_REVCTO	 := cZ9_REVCTO
						SZ9->Z9_CODCLI	 := cZ9_CODCLI
						SZ9->Z9_LOJCLI	 := cZ9_LOJCLI
						SZ9->Z9_NOMCLI  := Posicione( "SA1",1,xFilial("SA1") + cZ9_CODCLI + cZ9_LOJCLI, "A1_NOME" )
						SZ9->Z9_PERIODO := cDtPeriodo
						SZ9->Z9_DTINIPE := StoD( StrTran( cZ9_DTINIPE,"-","" ) )
						SZ9->Z9_DTFIMPE := StoD( StrTran( cZ9_DTFIMPE,"-","" ) )
						SZ9->Z9_VALOR 	 := Val( cZ9_VALOR )
						SZ9->Z9_STATUS  := "A"
						SZ9->Z9_CGC		 := cZ9_CGC	
						SZ9->Z9_VLRLIQ	 := Val( cZ9_VLRLIQ )
						SZ9->Z9_QUANT	 := Val( cZ9_QUANT )
					MsUnLock()
				
					::ATUALIZAVENDAS := WsClassNew("RetAtualizaVendas")
					::ATUALIZAVENDAS:_lRetAtu := "true"
					::ATUALIZAVENDAS:cMsgAtu  := "Inclusão do Lançamento realizado com sucesso."				
				
				EndIf
				( cAliasTmp )->( dbCloseArea() )
					
			Case AllTrim( cTipoOper ) = "A"// Alterando o registro
			
				cDtPeriodo := StrTran( cZ9_PERIODO, "-","" )//SubStr( cZ9_PERIODO ,6,2)+SubStr( cZ9_PERIODO ,1,4)
				
				cQuery := " SELECT COUNT(*) AS EXISTE,"
				cQuery += "        R_E_C_N_O_ AS RECNO 
				cQuery += " FROM "+RetSQLName("SZ9")
				cQuery += " WHERE Z9_FILIAL  = '"+ xFilial("SZ9") +"'"
				cQuery += "   AND Z9_NUMCTO  = '"+ cZ9_NUMCTO     +"'"
				cQuery += "   AND Z9_REVCTO  = '"+ cZ9_REVCTO     +"'"
				cQuery += "   AND Z9_CODCLI  = '"+ cZ9_CODCLI     +"'"
			  	cQuery += "   AND Z9_LOJCLI  = '"+ cZ9_LOJCLI     +"'"
				cQuery += "   AND Z9_PERIODO = '"+ cDtPeriodo	  +"'"
				cQuery += "   AND Z9_DTINIPE = '"+ AllTrim( StrTran( cZ9_DTINIPE, "-","") ) +"'"
				cQuery += "   AND Z9_DTFIMPE = '"+ AllTrim( StrTran( cZ9_DTFIMPE, "-","") ) +"'"
				cQuery += "   AND Z9_CGC     = '"+ cZ9_CGC        +"'"
				cQuery += "   AND D_E_L_E_T_ <>'*'"
				cQuery += " GROUP BY R_E_C_N_O_ "
				cQuery := ChangeQuery( cQuery )
				dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery), cAliasTmp,.F.,.T. )

				nExisteReg := ( cAliasTmp )->EXISTE
				nNumRecno  := ( cAliasTmp )->RECNO
				
				( cAliasTmp )->( dbCloseArea() )			
			
				If nExisteReg > 0// Se existir o registro
				
					dbSelectArea("SZ9")
					SZ9->( dbGoTo( nNumRecno ) )
					
					RecLock("SZ9",.F.)
						SZ9->Z9_VALOR	:= Val( cZ9_VALOR )
						SZ9->Z9_VLRLIQ	:= Val( cZ9_VLRLIQ )
						SZ9->Z9_QUANT	:= Val( cZ9_QUANT )
					MsUnLock()
						
					::ATUALIZAVENDAS := WsClassNew("RetAtualizaVendas")
					::ATUALIZAVENDAS:_lRetAtu := "true"
					::ATUALIZAVENDAS:cMsgAtu  := "Lançamento alterado com sucesso."
					
				Else
				
					::ATUALIZAVENDAS := WsClassNew("RetAtualizaVendas")
					::ATUALIZAVENDAS:_lRetAtu := "false"
					::ATUALIZAVENDAS:cMsgAtu  := "Lançamento não encontrado."
										
				EndIF
									
			Case AllTrim( cTipoOper ) = "E"// Excluindo o Registro
			
				cDtPeriodo := StrTran( cZ9_PERIODO, "-","" )
				
				//+----------------------------------------------------------+
				//| Excluindo registro da tabela de Lancamento de Venda (SZ9)|
				//+----------------------------------------------------------+
				cQuery := " SELECT COUNT(*) AS EXISTE,"
				cQuery += "        R_E_C_N_O_ AS RECNO 
				cQuery += " FROM "+RetSQLName("SZ9")
				cQuery += " WHERE Z9_FILIAL  = '"+ xFilial("SZ9") +"'"
				cQuery += "   AND Z9_NUMCTO  = '"+ cZ9_NUMCTO     +"'"
				cQuery += "   AND Z9_REVCTO  = '"+ cZ9_REVCTO     +"'"
				cQuery += "   AND Z9_CODCLI  = '"+ cZ9_CODCLI     +"'"
			  	cQuery += "   AND Z9_LOJCLI  = '"+ cZ9_LOJCLI     +"'"
				cQuery += "   AND Z9_PERIODO = '"+ cDtPeriodo	  +"'"
				cQuery += "   AND Z9_DTINIPE = '"+ AllTrim( StrTran( cZ9_DTINIPE, "-","") ) +"'"
				cQuery += "   AND Z9_DTFIMPE = '"+ AllTrim( StrTran( cZ9_DTFIMPE, "-","") ) +"'"
				cQuery += "   AND Z9_CGC     = '"+ cZ9_CGC        +"'"
				cQuery += "   AND D_E_L_E_T_ <>'*'"
				cQuery += " GROUP BY R_E_C_N_O_ "
				cQuery := ChangeQuery( cQuery )
				dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery), cAliasTmp,.F.,.T. )
				
				nExisteReg := ( cAliasTmp )->EXISTE
				nNumRecno  := ( cAliasTmp )->RECNO
				
				( cAliasTmp )->( dbCloseArea() )			
			
				If nExisteReg > 0 
				
					dbSelectArea("SZ9")
					SZ9->( dbGoTo( nNumRecno ) )
						
					RecLock("SZ9",.F.)
						dbDelete()
					MsUnLock()
				
					//+----------------------------------------------------------+
					//| Excluindo registro da tabela de Lancamento de Venda (SZA)|
					//+----------------------------------------------------------+
					cAliasTmp := GetNextAlias()
			
					cQuery := " SELECT COUNT(*) AS EXISTE,"
					cQuery += "        R_E_C_N_O_ AS RECNO"
					cQuery += " FROM "+RetSQLName("SZA")
					cQuery += " WHERE ZA_FILIAL  = '"+ xFilial("SZA")+"'"
			  		cQuery += "   AND ZA_NUMCTO  = '"+ cZ9_NUMCTO    +"'"
			  		cQuery += "   AND ZA_REVISA  = '"+ cZ9_REVCTO    +"'"
			  		cQuery += "   AND ZA_PERIODO = '"+ cDtPeriodo    +"'"
			  		cQuery += "   AND ZA_DTINIPE = '"+ StrTran( cZ9_DTINIPE, "-","" )+"'"
			  		cQuery += "   AND ZA_DTFIMPE = '"+ StrTran( cZ9_DTFIMPE, "-","" )+"'"
				  	cQuery += "   AND D_E_L_E_T_ <>'*'"
				  	cQuery += " GROUP BY R_E_C_N_O_"
					cQuery := ChangeQuery( cQuery )
					dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery), cAliasTmp,.F.,.T. )
					
					If ( cAliasTmp )->EXISTE > 0
					
						While ( cAliasTmp )->( !EOF() )
						
							dbSelectArea("SZA")
							SZA->( dbGoTo( ( cAliasTmp )->RECNO ) )
					
							RecLock("SZA",.F.)
								dbDelete()
							MsUnLock()
							
							( cAliasTmp )-> ( dbSkip() )
							
						EndDo
					
					EndIf
					
					( cAliasTmp )->( dbCloseArea() )			
			
				EndIf
				
				::ATUALIZAVENDAS := WsClassNew("RetAtualizaVendas")
				::ATUALIZAVENDAS:_lRetAtu := "true"
				::ATUALIZAVENDAS:cMsgAtu  := "Lançamento deletado."
				
		EndCase                                     
                                     
	EndIf
	                                  
Return(.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Estrutura do Metodo GETATUALIZAVENDAS  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSSTRUCT RetAtualizaVendas

	WSDATA _lRetAtu AS String
	WSDATA cMsgAtu  AS String
	 
ENDWSSTRUCT

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao ³ GETVISUALIZALANC ³ Autor ³ Denis Rodrigues ³ Data ³ 23/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Visualiza o Lancamento selecionado                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 - Codigo da Empresa no Sistema                       ³±±
±±³          ³ cExp2 - Codigo da Filial no Sistema                        ³±±
±±³          ³ cExp3 - Usuario de acesso ao Servico do WS                 ³±±
±±³          ³ cExp4 - Senha de acesso ao Servico do WS                   ³±±
±±³          ³ cExp5 - CNPJ do Fornecedor/Licenciado                      ³±±
±±³          ³ cExp6 - Chave de acesso ao Portal                          ³±±
±±³          ³ cExp7 - Tipo de Login L=Licenciado / F = Fornecedor        ³±±
±±³          ³ cExp8 - Numero do Contrato                                 ³±±
±±³          ³ cExp9 - Numero da Revisao                                  ³±±
±±³          ³ cExp10 - Codigo do cliente                                 ³±±
±±³          ³ cExp11 - Loja do cliente                                   ³±±
±±³          ³ cExp12 - Periodo                                           ³±±
±±³          ³ cExp13 - Data Inicial                                      ³±±
±±³          ³ cExp14 - Data Final                                        ³±±
±±³          ³ cExp15 - CNPJ                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente S.C Internacional                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD GETVISUALIZALANC WSRECEIVE cWEmpresa, cWFilial, cWSUsuario, cWSSenha, cCNPJ, cChvPortal, cTipoLogin,;
                                    cZ9_NUMCTO,cZ9_REVCTO,cZ9_CODCLI,cZ9_LOJCLI,cZ9_PERIODO,cZ9_DTINIPE,;
                                    cZ9_DTFIMPE,cZ9_CGC WSSEND VISUALIZALANC WSSERVICE PORTALLICENCIADO

	Local lOK        := .T.
	Local cQuery     := ""
	Local cDtPeriodo := ""
	Local cFormatAno := ""
	Local cFormatMes := ""
	Local cFormatDia := ""
	Local cAliasTmp  := GetNextAlias()
	Local oVisual 
	
	RpcClearEnv()
	RpcSetType(3)
	RpcSetenv( cWEmpresa, cWFilial,,,,GetEnvServer(),{"SZ9"} )
	
	// Valida Usuario e Senha do Servico WebService
	If !WS10Login( cWEmpresa, cWFilial, cWSUsuario, cWSSenha )
	
		VISUALIZALANC := WsClassNew("RetVisualizaLanc")
		VISUALIZALANC:_lRetStatusVis := {}
		
		oVisual := WsClassNew("StatusVisual")
		oVisual:_lStatusVis := "false"
		oVisual:cMsgRetVis  := "Usuário ou senha do Serviço Web Services esta inválida."
		aAdd( ::VISUALIZALANC:_lRetStatusVis, oVisual )
		
		VISUALIZALANC:cRetVisuaLanc := {}
		oVisual := WsClassNew("StrutVisualLanc")
		oVisual:cZ9_NUMCTO 	:= "" 
		oVisual:cZ9_REVCTO 	:= ""
		oVisual:cZ9_CODCLI 	:= ""
		oVisual:cZ9_LOJCLI 	:= ""
		oVisual:cZ9_PERIODO	:= ""
		oVisual:cZ9_DTINIPE	:= ""
		oVisual:cZ9_DTFIMPE	:= ""
		oVisual:cZ9_VALOR		:= ""
		oVisual:cZ9_STATUS	:= ""
		oVisual:cZ9_VLRLIQ	:= ""
		oVisual:cZ9_QUANT		:= ""
		aAdd( ::VISUALIZALANC:cRetVisuaLanc, oVisual )
		
		lOK := .F.

	Else// Se o acesso ao Servico estiver OK, testa o login e senha do usuario
			
		// Valida o CNPJ e senha do Licenciado
		aRet := WS10ValUser( cWEmpresa,cWFilial,cCNPJ,cChvPortal,cTipoLogin )
			
		If aRet[1][1] == "false"

			VISUALIZALANC := WsClassNew("RetVisualizaLanc")
			VISUALIZALANC:_lRetStatusVis := {}
			
			oVisual := WsClassNew("StatusVisual")
			oVisual:_lStatusVis := aRet[1][1]
			oVisual:cMsgRetVis  := aRet[1][2]
			aAdd( ::VISUALIZALANC:_lRetStatusVis, oVisual )
			
			VISUALIZALANC:cRetVisuaLanc := {}
			oVisual := WsClassNew("StrutVisualLanc")
			oVisual:cZ9_NUMCTO  := "" 
			oVisual:cZ9_REVCTO  := ""
			oVisual:cZ9_CODCLI  := ""
			oVisual:cZ9_LOJCLI  := ""
			oVisual:cZ9_PERIODO := ""
			oVisual:cZ9_DTINIPE := ""
			oVisual:cZ9_DTFIMPE := ""
			oVisual:cZ9_VALOR   := ""
			oVisual:cZ9_STATUS  := ""
			oVisual:cZ9_VLRLIQ  := ""
			oVisual:cZ9_QUANT	  := ""			
			aAdd( ::VISUALIZALANC:cRetVisuaLanc, oVisual )

			lOK := .F.
			
		EndIf
					
	EndIf
	
	If lOK
	
		cDtPeriodo := StrTran( cZ9_PERIODO, "-","" )//SubStr(cZ9_PERIODO,6,2)+SubStr(cZ9_PERIODO,1,4)
				
		cQuery := " SELECT Z9_NUMCTO,"
		cQuery += "        Z9_REVCTO,"
		cQuery += "        Z9_CODCLI,"
		cQuery += "        Z9_LOJCLI,"
		cQuery += "        Z9_PERIODO,"
		cQuery += "        Z9_DTINIPE,"
		cQuery += "        Z9_DTFIMPE,"
		cQuery += "        Z9_CGC,"
		cQuery += "        Z9_VALOR,"
		cQuery += "        Z9_STATUS,"
		cQuery += "        Z9_VLRLIQ,"
		cQuery += "        Z9_QUANT" 
		cQuery += " FROM "+RetSQLName("SZ9")
		cQuery += " WHERE Z9_FILIAL  = '"+ xFilial("SZ9") +"'"
		cQuery += "   AND Z9_NUMCTO  = '"+ cZ9_NUMCTO     +"'"
		cQuery += "   AND Z9_REVCTO  = '"+ cZ9_REVCTO     +"'"
		cQuery += "   AND Z9_CODCLI  = '"+ cZ9_CODCLI     +"'"
	  	cQuery += "   AND Z9_LOJCLI  = '"+ cZ9_LOJCLI     +"'"
		cQuery += "   AND Z9_PERIODO = '"+ cDtPeriodo	  +"'"
		cQuery += "   AND Z9_DTINIPE = '"+ StrTran( cZ9_DTINIPE,"-","" ) +"'"
		cQuery += "   AND Z9_DTFIMPE = '"+ StrTran( cZ9_DTFIMPE,"-","" ) +"'"
		cQuery += "   AND Z9_CGC     = '"+ cZ9_CGC        +"'"
		cQuery += "   AND D_E_L_E_T_ <>'*'"
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery), cAliasTmp,.F.,.T. )	

		If ( cAliasTmp )->( !EOF() )
		
			VISUALIZALANC := WsClassNew("RetVisualizaLanc")
			VISUALIZALANC:_lRetStatusVis := {}
			
			While ( cAliasTmp )->( !EOF() )
			
				oVisual := WsClassNew("StatusVisual")
				oVisual:_lStatusVis := "true"
				oVisual:cMsgRetVis  := "OK"
				aAdd( ::VISUALIZALANC:_lRetStatusVis, oVisual )
				
				VISUALIZALANC:cRetVisuaLanc := {}
				oVisual := WsClassNew("StrutVisualLanc")
				oVisual:cZ9_NUMCTO  := ( cAliasTmp )->Z9_NUMCTO 
				oVisual:cZ9_REVCTO  := ( cAliasTmp )->Z9_REVCTO
				oVisual:cZ9_CODCLI  := ( cAliasTmp )->Z9_CODCLI
				oVisual:cZ9_LOJCLI  := ( cAliasTmp )->Z9_LOJCLI
				
				
				oVisual:cZ9_PERIODO := SubStr( ( cAliasTmp )->Z9_PERIODO,4,4 )+"-"+SubStr( ( cAliasTmp )->Z9_PERIODO,1,2 )
				
				cFormatAno := SubStr( ( cAliasTmp )->Z9_DTINIPE,1,4 )
				cFormatMes := SubStr( ( cAliasTmp )->Z9_DTINIPE,5,2 )
				cFormatDia := SubStr( ( cAliasTmp )->Z9_DTINIPE,7,2 )
				oVisual:cZ9_DTINIPE := cFormatAno +"-"+ cFormatMes +"-"+ cFormatDia
				
				cFormatAno := SubStr( ( cAliasTmp )->Z9_DTFIMPE,1,4 )
				cFormatMes := SubStr( ( cAliasTmp )->Z9_DTFIMPE,5,2 )
				cFormatDia := SubStr( ( cAliasTmp )->Z9_DTFIMPE,7,2 )
				oVisual:cZ9_DTFIMPE := cFormatAno +"-"+ cFormatMes +"-"+ cFormatDia
				 
				oVisual:cZ9_VALOR  := StrTran( StrTran( TransForm( ( cAliasTmp )->Z9_VALOR, PesqPict("SZ9","Z9_VALOR") ),".",""),",","." )
				oVisual:cZ9_STATUS := ( cAliasTmp )->Z9_STATUS
				oVisual:cZ9_VLRLIQ := ( cAliasTmp )->Z9_VLRLIQ
				oVisual:cZ9_QUANT  := ( cAliasTmp )->Z9_QUANT
				aAdd( ::VISUALIZALANC:cRetVisuaLanc, oVisual )
				
				( cAliasTmp )->( dbSkip() )
			
			EndDo
			
		Else
		
			VISUALIZALANC := WsClassNew("RetVisualizaLanc")
			VISUALIZALANC:_lRetStatusVis := {}
			
			oVisual := WsClassNew("StatusVisual")
			oVisual:_lStatusVis := "false"
			oVisual:cMsgRetVis  := "Não existem registros para exibir."
			aAdd( ::VISUALIZALANC:_lRetStatusVis, oVisual )
			
			VISUALIZALANC:cRetVisuaLanc := {}
			oVisual := WsClassNew("StrutVisualLanc")
			oVisual:cZ9_NUMCTO  := "" 
			oVisual:cZ9_REVCTO  := ""
			oVisual:cZ9_CODCLI  := ""
			oVisual:cZ9_LOJCLI  := ""
			oVisual:cZ9_PERIODO := ""
			oVisual:cZ9_DTINIPE := ""
			oVisual:cZ9_DTFIMPE := ""
			oVisual:cZ9_VALOR   := ""
			oVisual:cZ9_STATUS  := ""
			oVisual:cZ9_VLRLIQ  := ""
			oVisual:cZ9_QUANT   := ""			
			aAdd( ::VISUALIZALANC:cRetVisuaLanc, oVisual )		
		
		EndIf	
		
		( cAliasTmp )->( dbCloseArea() )
		 
	EndIf
                                      
Return(.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Estrutura do Metodo GETVISUALIZALANC        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSSTRUCT RetVisualizaLanc
	WSDATA _lRetStatusVis AS ARRAY Of StatusVisual
	WSDATA cRetVisuaLanc  AS ARRAY Of StrutVisualLanc
ENDWSSTRUCT

WSSTRUCT StatusVisual  
	WSDATA _lStatusVis AS String
	WSDATA cMsgRetVis  AS String	
ENDWSSTRUCT  

WSSTRUCT StrutVisualLanc
	WSDATA cZ9_NUMCTO  AS String 
	WSDATA cZ9_REVCTO  AS String
	WSDATA cZ9_CODCLI  AS String
	WSDATA cZ9_LOJCLI  AS String
	WSDATA cZ9_PERIODO AS String
	WSDATA cZ9_DTINIPE AS String
	WSDATA cZ9_DTFIMPE AS String
	WSDATA cZ9_VALOR   AS String
	WSDATA cZ9_STATUS  AS String
	WSDATA cZ9_VLRLIQ  AS String
	WSDATA cZ9_QUANT   AS String
ENDWSSTRUCT


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ WS10Login ³ Autor ³ Denis Rodrigues    ³ Data ³  20/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida o usuario e senha de acesso ao servico WS           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ WS10Login(cExp1, cExp2,cExp3,cExp4)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 - Codigo da empresa do sistema                       ³±±
±±³          ³ cExp2 - Codigo da filial do sistema                        ³±±
±±³          ³ cExp3 - Usuario de acesso ao servico do WebService         ³±±
±±³          ³ cExp4 - Senha de acesso ao servico do WebService           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ variavel logica                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente S.C Internacional                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function WS10LOGIN( cWEmpresa, cWFilial, cWSUsuario, cWSSenha )

	Local lOK       := .F.
	Local cWSUser   := ""
	Local cWSPasswd := ""
	
	RpcClearEnv()
	RpcSetType( 3 )
	RpcSetenv( cWEmpresa, cWFilial,,,,GetEnvServer(),{"SM0"} )
	
	cWSUser   := GetMV("ES_WSUSRPL")
	cWSPasswd := GetMV("ES_WSPSWPL")
	
	If AllTrim( Lower( cWSUser ) ) == AllTrim( Lower( cWSUsuario ) )
	
		If AllTrim( Lower( cWSPasswd ) ) == AllTrim( Lower( cWSSenha ) )
			lOK := .T.
		EndIf	
		
	EndIf

Return( lOK )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ WS10VALUSER ³ Autor ³ Denis Rodrigues  ³ Data ³  18/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Valida o Usuario e senha do Portal                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ WS10VALUSER( cExp1,cExp2, cExp3, cExp4 )                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 - Codigo da empresa no sistema                       ³±±
±±³          ³ cExp2 - Codigo da filial no sistema                        ³±±
±±³          ³ cExp3 - CNPJ do Licenciado                                 ³±±
±±³          ³ cExp4 - Chave de acesso                                    ³±±
±±³          ³ cExp5 - Tipo de Login L = Licenciado / F = Fornecedor      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ variavel booleana                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente S.C Internacional                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function WS10VALUSER( cWSEmpresa,cWSFilial,cCNPJ,cChvPortal,cTipoLogin )

	Local cTabela	 := IIf( AllTrim( cTipoLogin ) == "L", "SA1","SA2" )
	Local cAliasTmp := GetNextAlias()
	Local cQuery  	 := ""
	Local cMsg      := ""
	Local aRet	  	 := {}
	
	RpcClearEnv()
	RpcSetType( 3 )
	If	RpcSetenv( cWSEmpresa, cWSFilial,,,,GetEnvServer(),{cTabela} )
	
		If AllTrim( cTabela ) == "SA1"//Se o login for de um LICENCIADO
			
			cQuery := " SELECT A1_COD,"
       	cQuery += "        A1_LOJA,"
       	cQuery += "        A1_NOME,"
       	cQuery += "        A1_CGC"
			cQuery += " FROM "+RetSQLName("SA1")
			cQuery += " WHERE A1_FILIAL   =  '"+ xFilial("SA1") +"'"
  			cQuery += "   AND A1_ACPORT   =  'S'"
  			cQuery += "   AND A1_MSBLQL   <> '1'"
  			cQuery += "   AND A1_CGC      =  '"+ cCNPJ +"'"
  			cQuery += "   AND A1_CHVPORT  =  '"+ Embaralha( AllTrim( cChvPortal ),1 ) +"'" //1 - embaralha 0 - desembaralha|
  			cQuery += "   AND D_E_L_E_T_  <> '*'"
			cQuery := ChangeQuery( cQuery )
			dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T. )
			
			If ( cAliasTmp )->( !EOF() )//Se existir registro
			
				aAdd( aRet,{"true",;
				            "Registro OK",;
				            ( cAliasTmp )->A1_COD,;
				            ( cAliasTmp )->A1_LOJA,;
				            ( cAliasTmp )->A1_NOME,;
				            TransForm( ( cAliasTmp )->A1_CGC, PesqPict("SA1","A1_CGC") ) })
			
			Else// Se a query retornar vazia
							
				cMsg := "Não foi possível fazer login no Portal.<br>"
				cMsg += "Verifique sua senha ou CNPJ.<br>"
				cMsg += "Ou verifique junto ao S.C. Internacional as seguintes condições:<br>"
				cMsg += "- Se o CNPJ esta habilitado para acessar o Portal.<br>"
				cMsg += "- Se o CNPJ esta bloqueado no sistema.<br>"
				cMsg += "- Se o CNPJ esta correto."
			
				aAdd( aRet, {"false",cMsg,"","","",""})
					
			EndIf
			
			( cAliasTmp )->( dbCloseArea() )
		
		Else// Se o login for de um FORNECEDOR
					
			cQuery := " SELECT A2_COD,"
       	cQuery += "        A2_LOJA,"
       	cQuery += "        A2_NOME,"
       	cQuery += "        A2_CGC"
			cQuery += " FROM "+RetSQLName("SA2")
			cQuery += " WHERE A2_FILIAL   =  '"+ xFilial("SA2") +"'"
  			cQuery += "   AND A2_ACPORT   =  'S'"
  			cQuery += "   AND A2_MSBLQL   <> '1'"
  			cQuery += "   AND A2_CGC      =  '"+ cCNPJ +"'"
  			cQuery += "   AND A2_CHVPORT  =  '"+ Embaralha( AllTrim( cChvPortal ),1 ) +"'" //1 - embaralha 0 - desembaralha|
  			cQuery += "   AND D_E_L_E_T_  <> '*'"
			cQuery := ChangeQuery( cQuery )
			dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T. )

			If ( cAliasTmp )->( !EOF() )//Se existir registro
			
				aAdd( aRet, {"true",;
				             "Registro OK",;
				             ( cAliasTmp )->A2_COD,;
				             ( cAliasTmp )->A2_LOJA,;
				             ( cAliasTmp )->A2_NOME,;
				             TransForm( ( cAliasTmp )->A2_CGC, PesqPict("SA2","A2_CGC") )})
			
			Else// Se a query retornar vazia
				
				cMsg := "Não foi possível fazer login no Portal.<br>"
				cMsg += "Verifique sua senha ou CNPJ.<br>"				
				cMsg += "Ou verifique junto ao S.C. Internacional as seguintes condições:<br>"
				cMsg += "- Se o CNPJ esta habilitado para acessar o Portal.<br>"
				cMsg += "- Se o CNPJ esta bloqueado no sistema.<br>"
				cMsg += "- Se o CNPJ esta correto."
			
				aAdd( aRet, {"false",cMsg,"","","",""})	
			
			EndIf
			
			( cAliasTmp )->( dbCloseArea() )
		
		EndIf
	
	EndIf

Return( aRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao ³GETLISTAETIQUETAS³ Autor ³ Denis Rodrigues ³ Data ³  10/11/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Lista Lancamentos do Controle de Etiquetas Holograficas    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 - Codigo da Empresa no Sistema                       ³±±
±±³          ³ cExp2 - Codigo da Filial no Sistema                        ³±±
±±³          ³ cExp3 - Usuario de acesso ao Servico do WS                 ³±±
±±³          ³ cExp4 - Senha de acesso ao Servico do WS                   ³±±
±±³          ³ cExp5 - CNPJ do Fornecedor/Licenciado                      ³±±
±±³          ³ cExp6 - Chave de acesso ao Portal                          ³±±
±±³          ³ cExp7 - Tipo de Login L=Licenciado / F = Fornecedor        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente S.C Internacional                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD GETLISTAETIQUETAS WSRECEIVE cWEmpresa, cWFilial, cWSUsuario, cWSSenha, cCNPJ, cChvPortal, cTipoLogin WSSEND LISTAETIQUETAS WSSERVICE PORTALLICENCIADO

	Local cQuery    := ""
	Local cFormatAno:= ""
	Local cFormatMes:= ""
	Local cFormatDia:= ""
	Local cAliasTmp := GetNextAlias()
	Local lOK 		 := .T.
	Local oEtiquetas
	
	RpcClearEnv()
	RpcSetType( 3 )
	If	RpcSetenv( cWEmpresa, cWFilial,,,,GetEnvServer(),{"SZ0","SA2"} )
	
		// Valida Usuario e Senha do Servico WebService
		If !WS10Login( cWEmpresa, cWFilial, cWSUsuario, cWSSenha )
	
			LISTAETIQUETAS := WsClassNew("RetListaEtiquetas")
			LISTAETIQUETAS:_lRetListaEtq := {}
			
			oEtiquetas := WsClassNew("StatusEtiqueta")
			oEtiquetas:_lStatusEtq := "false"
			oEtiquetas:cMsgRetEtq  := "Usuário ou senha do Serviço Web Services esta inválida."
			aAdd( ::LISTAETIQUETAS:_lRetListaEtq, oEtiquetas )
			
			LISTAETIQUETAS:cRetListaEtq := {}
			oEtiquetas := WsClassNew("StrutListaEtq")
			oEtiquetas:cZ0_STATUS := ""
			oEtiquetas:cZ0_DATA	 := "" 
			oEtiquetas:cZ0_CNPJ	 := ""
			oEtiquetas:cA2_NOME   := ""
			oEtiquetas:cZ0_QTDE	 := ""
			aAdd( ::LISTAETIQUETAS:cRetListaEtq, oEtiquetas )
			
			lOK := .F.

		Else// Se o acesso ao Servico estiver OK, testa o login e senha do usuario
			
			// Valida o CNPJ e senha do Licenciado
			aRet := WS10ValUser( cWEmpresa,cWFilial,cCNPJ,cChvPortal,cTipoLogin )
				
			If aRet[1][1] == "false"
	
				LISTAETIQUETAS := WsClassNew("RetListaEtiquetas")
				LISTAETIQUETAS:_lRetListaEtq := {}
				
				oEtiquetas := WsClassNew("StatusEtiqueta")
				oEtiquetas:_lStatusEtq := aRet[1][1]
				oEtiquetas:cMsgRetEtq  := aRet[1][2]
				aAdd( ::LISTAETIQUETAS:_lRetListaEtq, oEtiquetas )
				
				LISTAETIQUETAS:cRetListaEtq := {}
				oEtiquetas := WsClassNew("StrutListaEtq")
				oEtiquetas:cZ0_STATUS := ""
				oEtiquetas:cZ0_DATA	 := "" 
				oEtiquetas:cZ0_CNPJ	 := ""
				oEtiquetas:cA2_NOME   := ""
				oEtiquetas:cZ0_QTDE	 := ""
				aAdd( ::LISTAETIQUETAS:cRetListaEtq, oEtiquetas )
				
				lOK := .F.
				
			EndIf
					
		EndIf
		
		If lOK
		
			cQuery := " SELECT SZ0.Z0_DATA,"
       	cQuery += "        SZ0.Z0_CNPJ,"
       	cQuery += "        SZ0.Z0_QTDE,"
       	cQuery += "        SZ0.Z0_STATUS,"
       	cQuery += "        SZ0.Z0_CNPJFOR,"
       	cQuery += "        SA1.A1_NOME"
			cQuery += " FROM "+RetSQLName("SZ0")+" SZ0, "
			cQuery +=          RetSQLName("SA1")+" SA1"
			cQuery += " WHERE SZ0.Z0_FILIAL  = '"+ xFilial("SZ0")+"'"
  			cQuery += "   AND SZ0.Z0_CNPJFOR = '"+ cCNPJ         +"'"
  			cQuery += "   AND SZ0.D_E_L_E_T_ <>'*'"
  
		  	cQuery += "   AND SA1.A1_FILIAL =  '"+xFilial("SA1")+"'"
			cQuery += "	  AND SA1.A1_CGC    =  SZ0.Z0_CNPJ"
		   cQuery += "   AND SA1.A1_ACPORT =  'S'"
  			cQuery += "   AND SA1.A1_MSBLQL <> '1'"
		  	cQuery += "   AND SA1.D_E_L_E_T_<>'*'"
		  	cQuery := ChangeQuery( cQuery )
		  	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T. )

		  	If ( cAliasTmp )->( !EOF() )

				LISTAETIQUETAS := WsClassNew("RetListaEtiquetas")
				LISTAETIQUETAS:_lRetListaEtq := {}

				oEtiquetas := WsClassNew("StatusEtiqueta")
				oEtiquetas:_lStatusEtq := "true"
				oEtiquetas:cMsgRetEtq  := ""
				aAdd( ::LISTAETIQUETAS:_lRetListaEtq, oEtiquetas )				
							  	
		  		While ( cAliasTmp )->( !EOF() )

					LISTAETIQUETAS:cRetListaEtq := {}
					oEtiquetas := WsClassNew("StrutListaEtq")
					oEtiquetas:cZ0_STATUS := ( cAliasTmp )->Z0_STATUS
					
					cFormatAno := SubStr( ( cAliasTmp )->Z0_DATA,1,4 )
					cFormatMes := SubStr( ( cAliasTmp )->Z0_DATA,5,2 )
					cFormatDia := SubStr( ( cAliasTmp )->Z0_DATA,7,2 )
					oEtiquetas:cZ0_DATA := cFormatAno +"-"+ cFormatMes +"-"+ cFormatDia
					 
					oEtiquetas:cZ0_CNPJ	 := ( cAliasTmp )->Z0_CNPJ
					oEtiquetas:cA2_NOME   := ( cAliasTmp )->A1_NOME
					oEtiquetas:cZ0_QTDE	 := cValToChar( ( cAliasTmp )->Z0_QTDE )
					aAdd( ::LISTAETIQUETAS:cRetListaEtq, oEtiquetas )
		  		
		  			( cAliasTmp )->( dbSkip() )
		  			
		  		EndDo
		  		
		  	Else
		  	
				LISTAETIQUETAS := WsClassNew("RetListaEtiquetas")
				LISTAETIQUETAS:_lRetListaEtq := {}
				
				oEtiquetas := WsClassNew("StatusEtiqueta")
				oEtiquetas:_lStatusEtq := "false"
				oEtiquetas:cMsgRetEtq  := "Não existem registros relacionados a esse Fornecedor."
				aAdd( ::LISTAETIQUETAS:_lRetListaEtq, oEtiquetas )
				
				LISTAETIQUETAS:cRetListaEtq := {}
				oEtiquetas := WsClassNew("StrutListaEtq")
				oEtiquetas:cZ0_STATUS := ""
				oEtiquetas:cZ0_DATA	 := "" 
				oEtiquetas:cZ0_CNPJ	 := ""
				oEtiquetas:cA2_NOME   := ""
				oEtiquetas:cZ0_QTDE	 := ""
				aAdd( ::LISTAETIQUETAS:cRetListaEtq, oEtiquetas )		  	
		  		
		  	EndIf
		  	( cAliasTmp )->( dbCloseArea() )
  
		EndIf	
	
	EndIf

Return( .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Estrutura do Metodo GETLISTAETIQUETAS  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSSTRUCT RetListaEtiquetas
	WSDATA _lRetListaEtq AS ARRAY Of StatusEtiqueta
	WSDATA cRetListaEtq  AS ARRAY Of StrutListaEtq
ENDWSSTRUCT

WSSTRUCT StatusEtiqueta  
	WSDATA _lStatusEtq AS String
	WSDATA cMsgRetEtq  AS String	
ENDWSSTRUCT  

WSSTRUCT StrutListaEtq
	WSDATA cZ0_STATUS  AS String
	WSDATA cZ0_DATA	 AS String 
	WSDATA cZ0_CNPJ	 AS String
	WSDATA cA2_NOME	 AS String
	WSDATA cZ0_QTDE	 AS String
ENDWSSTRUCT

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao ³GETATUALIZATIQUETA³ Autor ³ Denis Rodrigues ³ Data ³ 11/11/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Metodo de Manutencao das Etiquetas Holograficas            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 - Codigo da Empresa no Sistema                       ³±±
±±³          ³ cExp2 - Codigo da Filial no Sistema                        ³±±
±±³          ³ cExp3 - Usuario de acesso ao Servico do WS                 ³±±
±±³          ³ cExp4 - Senha de acesso ao Servico do WS                   ³±±
±±³          ³ cExp5 - CNPJ do Fornecedor/Licenciado                      ³±±
±±³          ³ cExp6 - Chave de acesso ao Portal                          ³±±
±±³          ³ cExp7 - Tipo de Login L=Licenciado / F = Fornecedor        ³±±
±±³          ³ cExp8 - Operacao I-Incluir/A-Alterar/E-Exclui              ³±±
±±³          ³ cExp9 - Data de Entrega                                    ³±±
±±³          ³ cExp10 - Quantidade de Etiquetas                           ³±±
±±³          ³ cExp11 - CNPJ do Cliente                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente S.C Internacional                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD GETATUALIZATIQUETA WSRECEIVE cWEmpresa, cWFilial, cWSUsuario, cWSSenha, ;
                                      cCNPJ, cChvPortal, cTipoLogin, cTipoOper, cDtEntrega,;
                                      cQuantEtiq, cCNPJCliente WSSEND ATUALIZATIQUETA WSSERVICE PORTALLICENCIADO

	Local lOK        := .T.
	Local cQuery     := ""
	Local cAliasTmp  := GetNextAlias()
	Local nExisteReg := 0
	Local nNumRecno  := 0
	
	RpcClearEnv()
	RpcSetType( 3 )
	RpcSetenv( cWEmpresa, cWFilial,,,,GetEnvServer(),{"SZ0","SA2"} )
	
	// Valida Usuario e Senha do Servico WebService
	If !WS10Login( cWEmpresa, cWFilial, cWSUsuario, cWSSenha )
	
		::ATUALIZATIQUETA := WsClassNew("RetAtualizaEtiqueta")
		::ATUALIZATIQUETA:_lStatusRet := "false"
		::ATUALIZATIQUETA:cMsgRet  	:= "Usuário ou senha do Serviço Web Services esta inválida."   
		lOK := .F.

	Else// Se o acesso ao Servico estiver OK, testa o login e senha do usuario
			
		// Valida o CNPJ e senha do Licenciado
		aRet := WS10ValUser( cWEmpresa,cWFilial,cCNPJ,cChvPortal,cTipoLogin )
			
		If aRet[1][1] == "false"

			::ATUALIZATIQUETA := WsClassNew("RetAtualizaEtiqueta")
			::ATUALIZATIQUETA:_lStatusRet := aRet[1][1]
			::ATUALIZATIQUETA:cMsgRet	   := aRet[1][2]
			lOK := .F.
			
		EndIf
					
	EndIf
	
	If lOK
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  Valida se o CNPJ do Licenciado e valido     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery := " SELECT COUNT(*) AS EXISTE"
		cQuery += " FROM "+RetSQLName("SA1")
		cQuery += " WHERE A1_FILIAL  =  '"+ xFilial("SA1")+"'"
	  	cQuery += "   AND A1_CGC     =  '"+ cCNPJCliente	+"'"
	  	cQuery += "	  AND A1_ACPORT  =  'S'"
	  	cQuery += "   AND A1_MSBLQL  <> '1'"
	  	cQuery += "   AND D_E_L_E_T_ <> '*'"
	  	cQuery := ChangeQuery( cQuery )
		dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery), cAliasTmp,.F.,.T. )
	
		If ( cAliasTmp )->EXISTE = 0
		
			::ATUALIZATIQUETA := WsClassNew("RetAtualizaEtiqueta")
			::ATUALIZATIQUETA:_lStatusRet := "false"
			::ATUALIZATIQUETA:cMsgRet  	:= "CNPJ do Licenciado inválido."
			lOK := .F.
		
		EndIf
		( cAliasTmp )->( dbCloseArea() )
  
		If lOK
	
			cDtEntrega := StrTran( cDtEntrega, "-","" )
			
			cQuery := " SELECT COUNT(*) AS EXISTE,"
		   cQuery += "        R_E_C_N_O_ AS RECNO"
			cQuery += " FROM "+RetSQLName("SZ0")
			cQuery += " WHERE Z0_FILIAL  = '"+ xFilial("SZ0") +"'"
	  		cQuery += "   AND Z0_CNPJ    = '"+ cCNPJCliente   +"'"
	  		cQuery += "   AND Z0_DATA    = '"+ cDtEntrega     +"'"
	  		cQuery += "   AND Z0_CNPJFOR = '"+ cCNPJ		     +"'"
	  		cQuery += "   AND D_E_L_E_T_ <> '*'"
			cQuery += " GROUP BY R_E_C_N_O_ "
			cQuery := ChangeQuery( cQuery )
			dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery), cAliasTmp,.F.,.T. )
		
			nExisteReg := ( cAliasTmp )->EXISTE
			nNumRecno  := ( cAliasTmp )->RECNO
		
			( cAliasTmp )->( dbCloseArea() )
		
			Do Case
				Case cTipoOper = "I"// Se estiver incluindo

					If nExisteReg > 0// Se existir o registro
	
						::ATUALIZATIQUETA := WsClassNew("RetAtualizaEtiqueta")
						::ATUALIZATIQUETA:_lStatusRet := "false"
						::ATUALIZATIQUETA:cMsgRet	   := "Atualização cancelada. Lançamento já existe."
											
					Else

						dbSelectArea("SZ0")
						RecLock("SZ0",.T.)
							SZ0->Z0_FILIAL  := xFilial("SZ0")
							SZ0->Z0_DATA	 := StoD( cDtEntrega )
							SZ0->Z0_CNPJ	 := cCNPJCliente
							SZ0->Z0_QTDE	 := Val( cQuantEtiq )
							SZ0->Z0_STATUS	 := "A"
							SZ0->Z0_CNPJFOR := cCNPJ
						MsUnLock()
						
						::ATUALIZATIQUETA := WsClassNew("RetAtualizaEtiqueta")
						::ATUALIZATIQUETA:_lStatusRet := "true"
						::ATUALIZATIQUETA:cMsgRet	   := "Inclusão do Lançamento realizado com sucesso."					
													
					EndIf			
				
				Case cTipoOper = "A"// Se estiver alterando
			
					If nExisteReg > 0// Se existir o registro
					
						dbSelectArea("SZ0")
						SZ0->( dbGoTo( nNumRecno ) )
						
						RecLock("SZ0",.F.)
							SZ0->Z0_DATA	 := StoD( cDtEntrega )
							SZ0->Z0_CNPJ	 := cCNPJCliente
							SZ0->Z0_QTDE	 := Val( cQuantEtiq )
						MsUnLock()
	
						::ATUALIZATIQUETA := WsClassNew("RetAtualizaEtiqueta")
						::ATUALIZATIQUETA:_lStatusRet := "true"
						::ATUALIZATIQUETA:cMsgRet	   := "Registro alterado com sucesso."
																	
					Else
	
						::ATUALIZATIQUETA := WsClassNew("RetAtualizaEtiqueta")
						::ATUALIZATIQUETA:_lStatusRet := "false"
						::ATUALIZATIQUETA:cMsgRet	   := "Registro não encontrado."
										
					EndIF			
			
				Case cTipoOper = "E"// Se estivere excluindo

					If nExisteReg > 0// Se encontrar o registro
					
						dbSelectArea("SZ0")
						SZ0->( dbGoTo( nNumRecno ) )
							
						RecLock("SZ0",.F.)
							dbDelete()
						MsUnLock()
								
						::ATUALIZATIQUETA := WsClassNew("RetAtualizaEtiqueta")
						::ATUALIZATIQUETA:_lStatusRet := "true"
						::ATUALIZATIQUETA:cMsgRet	   := "Registro excluído."			
				
					Else
	
						::ATUALIZATIQUETA := WsClassNew("RetAtualizaEtiqueta")
						::ATUALIZATIQUETA:_lStatusRet := "false"
						::ATUALIZATIQUETA:cMsgRet	   := "Registro não encontrado."
										
					EndIf
			
				EndCase
		
		EndIf
		
	EndIf
		
Return( .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Estrutura Simples do Metodo GETATUALIZATIQUETA ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSSTRUCT RetAtualizaEtiqueta
	WSDATA _lStatusRet	AS String
	WSDATA cMsgRet 		AS String
ENDWSSTRUCT

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao ³ GETESQUECISENHA ³ Autor ³ Denis Rodrigues ³ Data ³ 14/11/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Metodo para resetar a senha do Licenciado ou Fornecedor    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 - Codigo da Empresa no Sistema                       ³±±
±±³          ³ cExp2 - Codigo da Filial no Sistema                        ³±±
±±³          ³ cExp3 - Usuario de acesso ao Servico do WS                 ³±±
±±³          ³ cExp4 - Senha de acesso ao Servico do WS                   ³±±
±±³          ³ cExp5 - CNPJ do Fornecedor/Licenciado                      ³±±
±±³          ³ cExp6 - Tipo de Login L=Licenciado / F = Fornecedor        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente S.C Internacional                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD GETESQUECISENHA WSRECEIVE cWEmpresa, cWFilial, cWSUsuario, cWSSenha, cCNPJ, cTipoLogin WSSEND ESQUECISENHA WSSERVICE PORTALLICENCIADO

	Local lOK 		 := .T.
	Local cTabela	 := Iif( AllTrim( cTipoLogin ) == "L", "SA1", "SA2" )
	Local cQuery 	 := ""
	Local cMsg 		 := ""
	Local cAliasTmp := GetNextAlias()
	Local nNumRecno := 0
	Local aRet		 := {}
	 
	RpcClearEnv()
	RpcSetType( 3 )
	RpcSetenv( cWEmpresa, cWFilial,,,,GetEnvServer(),{"SZ1","SA2"} )
	
	// Valida Usuario e Senha do Servico WebService
	If !WS10Login( cWEmpresa, cWFilial, cWSUsuario, cWSSenha )
	
		::ESQUECISENHA := WsClassNew("RetEsqueciSenha")
		::ESQUECISENHA:_lEsqueciSenha := "false"
		::ESQUECISENHA:cMsgEsqueci  	:= "Usuário ou senha do Serviço Web Services esta inválida."   
		lOK := .F.

	EndIf
	
	If Empty( cCNPJ )
	
		::ESQUECISENHA := WsClassNew("RetEsqueciSenha")
		::ESQUECISENHA:_lEsqueciSenha := "false"
		::ESQUECISENHA:cMsgEsqueci  	:= "Favor informar um CNPJ."   
		lOK := .F.
		
	EndIf
			
	If cTabela = "SA1"// Verifica o CNPJ do Licenciado 
	
		cQuery := " SELECT COUNT(*) AS EXISTE,"
		cQuery += "        R_E_C_N_O_ AS RECNO"		
		cQuery += " FROM "+RetSQLName("SA1")
		cQuery += " WHERE A1_FILIAL  =  '"+xFilial("SA1")+"'"
		cQuery += "   AND A1_CGC     =  '"+cCNPJ+"'"		
  		cQuery += "   AND A1_ACPORT  =  'S'"
  		cQuery += "   AND A1_EMAIL   <> ' '"
		cQuery += "   AND A1_MSBLQL  <> '1'"  		
		cQuery += "   AND D_E_L_E_T_ <> '*'"
		cQuery += " GROUP BY R_E_C_N_O_"		
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T. )
		
		If ( cAliasTmp )->EXISTE = 0
		
			cMsg := "Não foi possível reenviar senha.<br>"
			cMsg += " Verifique junto ao S.C. Internacional as seguintes condições:<br>"
			cMsg += "- Se o CNPJ esta habilitado para acessar o Portal.<br>"
			cMsg += "- Se o CNPJ esta bloqueado no sistema.<br>"
			cMsg += "- Se o E-mail do Licenciado esta cadastrado.<br>"
			cMsg += "- Se o CNPJ esta correto."			
			
			::ESQUECISENHA := WsClassNew("RetEsqueciSenha")
			::ESQUECISENHA:_lEsqueciSenha := "false"
			::ESQUECISENHA:cMsgEsqueci  	:= cMsg   
			lOK := .F.
			
		Else
			nNumRecno := ( cAliasTmp )->RECNO					
		EndIf
		
		( cAliasTmp )->( dbCloseArea() )
	
	Else// Verifica o CNPJ do Fornecedor

		cQuery := " SELECT COUNT(*) AS EXISTE,"
		cQuery += "        R_E_C_N_O_ AS RECNO"
		cQuery += " FROM "+RetSQLName("SA2")
		cQuery += " WHERE A2_FILIAL  =  '"+xFilial("SA2")+"'"
		cQuery += "   AND A2_CGC     =  '"+cCNPJ+"'"
  		cQuery += "   AND A2_ACPORT  =  'S'"
  		cQuery += "   AND A2_EMAIL   <> ' '"
		cQuery += "   AND A2_MSBLQL  <> '1'"		
		cQuery += "   AND D_E_L_E_T_ <> '*'"
		cQuery += " GROUP BY R_E_C_N_O_"
		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T. )
		
		If ( cAliasTmp )->EXISTE = 0

			cMsg := "Não foi possível reenviar senha.<br>"
			cMsg += "Verifique junto ao S.C. Internacional as seguintes condições:<br>"
			cMsg += "- Se o CNPJ esta habilitado para acessar o Portal.<br>"
			cMsg += "- Se o CNPJ esta bloqueado no sistema.<br>"
			cMsg += "- Se o E-mail do Fornecedor esta cadastrado.<br>"
			cMsg += "- Se o CNPJ esta correto."
						
			::ESQUECISENHA := WsClassNew("RetEsqueciSenha")
			::ESQUECISENHA:_lEsqueciSenha := "false"
			::ESQUECISENHA:cMsgEsqueci  	:= cMsg   
			lOK := .F.
			
		Else
			nNumRecno := ( cAliasTmp )->RECNO
		EndIf  					
		
		( cAliasTmp )->( dbCloseArea() )  			
	
	EndIf
	
	If lOK
	
		aRet := U_A040PROC( cTabela,nNumRecno,3,"WS" )//Rotina para enviar reenviar o e-mail de acesso
		
		If !aRet[1]
		
			::ESQUECISENHA := WsClassNew("RetEsqueciSenha")
			::ESQUECISENHA:_lEsqueciSenha := "false"
			::ESQUECISENHA:cMsgEsqueci  	:= aRet[2]
			
		Else
					
			::ESQUECISENHA := WsClassNew("RetEsqueciSenha")
			::ESQUECISENHA:_lEsqueciSenha := "true"
			::ESQUECISENHA:cMsgEsqueci  	:= "Informações de login reenviadas com sucesso."					
			
		EndIf
		
	EndIf
	
Return( .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Estrutura Simples do Metodo GETESQUECISENHA ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSSTRUCT RetEsqueciSenha
	WSDATA _lEsqueciSenha AS String
	WSDATA cMsgEsqueci    AS String
ENDWSSTRUCT


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao ³ GETIMPRIMIBOLETO ³ Autor ³ Denis Rodrigues ³ Data ³ 20/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Usa Funcoes de usuario para gerar boleto e disponibiliza   ³±±
±±³          ³ em um link para download.                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 - Codigo da Empresa no Sistema                       ³±±
±±³          ³ cExp2 - Codigo da Filial no Sistema                        ³±±
±±³          ³ cExp3 - Usuario de acesso ao Servico do WS                 ³±±
±±³          ³ cExp4 - Senha de acesso ao Servico do WS                   ³±±
±±³          ³ cExp5 - CNPJ do Fornecedor/Licenciado                      ³±±
±±³          ³ cExp6 - Chave de acesso ao Portal                          ³±±
±±³          ³ cExp7 - Tipo de Login L=Licenciado / F = Fornecedor        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente S.C Internacional                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD GETIMPRIMIBOLETO WSRECEIVE cWEmpresa, cWFilial, cWSUsuario, cWSSenha, cCNPJ,; 
												cChvPortal, cTipoLogin, cZ9_PERIODO, cZ9_PREFIXO, cZ9_NUM, cZ9_PARCELA,;
												cZ9_TIPO, cZ9_CLIENTE, cZ9_LOJA  WSSEND IMPRIMIBOLETO WSSERVICE PORTALLICENCIADO
	Local lOK       := .T.
	Local aBcoBol   := Array(4)
	Local aTitBol   := Array(18)
	Local aDadosBc
	Local cArqOrig  := ""
	Local cArqDest  := ""
	Local cArqRen   := ""
	Local cPathPDF  := ""
	Local cFileName := ""
	Local cWSDir    := GetMV("ES_WSTMP")

	RpcClearEnv()
	RpcSetType( 3 )
	RpcSetenv( cWEmpresa, cWFilial,,,,GetEnvServer(),{"SE1","SZ9"} )

	Default cZ9_PARCELA := Space(TamSX3("E1_PARCELA")[1])
		
	// Valida Usuario e Senha do Servico WebService
	If !WS10Login( cWEmpresa, cWFilial, cWSUsuario, cWSSenha )
	
		::IMPRIMIBOLETO := WsClassNew("RetImprimiBoleto")
		::IMPRIMIBOLETO:_lRetBoleto := "false"
		::IMPRIMIBOLETO:cLinkBoleto := "Usuário ou senha do Serviço Web Services esta inválida."   
		lOK := .F.

	Else// Se o acesso ao Servico estiver OK, testa o login e senha do usuario
			
 		// Valida o CNPJ e senha do Licenciado
		aRet := WS10ValUser( cWEmpresa,cWFilial,cCNPJ,cChvPortal,cTipoLogin )
			
		If aRet[1][1] == "false"

			::IMPRIMIBOLETO := WsClassNew("RetImprimiBoleto")
			::IMPRIMIBOLETO:_lRetBoleto := aRet[1][1]
			::IMPRIMIBOLETO:cLinkBoleto := aRet[1][2]
			lOK := .F.
			
		EndIf
					
	EndIf
	
	If lOK

		aDadosBc  := StrTokArr( AllTrim( GetMV("ES_WSBANCO" ) ),"|", .T. )

		aBcoBol[01] := PadR(aDadosBc[1], TamSX3("EE_CODIGO")[1]  , " ") // EE_CODIGO (Codigo Banco)
		aBcoBol[02] := PadR(aDadosBc[2], TamSX3("EE_AGENCIA")[1] , " ") // EE_AGENCIA (Agencia)
		aBcoBol[03] := PadR(aDadosBc[3], TamSX3("EE_CONTA")[1]   , " ") // EE_CONTA (Conta)
		aBcoBol[04] := PadR(aDadosBc[4], TamSX3("EE_SUBCTA")[1]  , " ") // EE_SUBCTA (Sub Conta)

		dbSelectArea("SEE")
		dbSetOrder(1)//EE_FILIAL+EE_CODIGO+EE_AGENCIA+EE_CONTA+EE_SUBCTA
		If	!dbSeek( xFilial("SEE") + aBcoBol[01] + aBcoBol[02] + aBcoBol[03] + aBcoBol[04] )

			::IMPRIMIBOLETO := WsClassNew("RetImprimiBoleto")
			::IMPRIMIBOLETO:_lRetBoleto := "false"
			::IMPRIMIBOLETO:cLinkBoleto := "Boleto Indisponível para Impressão. <br> Contate o Financeiro."
			lOk := .F.
		
		EndIf

	EndIf
	
	If lOK

		If	!Empty( cZ9_PREFIXO + cZ9_NUM + cZ9_PARCELA + cZ9_TIPO )

			dbSelectArea("SE1")
			dbSetOrder(2)	//-- E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			
			cChaveSE1 := xFilial("SE1")
			cChaveSE1 += PadR(cZ9_CLIENTE , TamSX3("E1_CLIENTE")[1] , " ")
			cChaveSE1 += PadR(cZ9_LOJA    , TamSX3("E1_LOJA")[1]    , " ")
			cChaveSE1 += PadR(cZ9_PREFIXO , TamSX3("E1_PREFIXO")[1] , " ")
			cChaveSE1 += PadR(cZ9_NUM     , TamSX3("E1_NUM")[1]     , " ")
			cChaveSE1 += PadR(cZ9_PARCELA , TamSX3("E1_PARCELA")[1] , " ")
			cChaveSE1 += PadR(cZ9_TIPO    , TamSX3("E1_TIPO")[1]    , " ")

			If	dbSeek( cChaveSE1 )
			
				If	SE1->E1_PORTADO = "041" .And. !Empty(SE1->E1_NUMBCO)
		
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Array com os Paramentros dos Titulos a Serem Impressos³
					//³                                                      ³
					//³Manter essa Ordem                                      ³
					//³                                                      ³
					//³01 - Prefixo Inicial                                  ³
					//³02 - Prefixo Final                                    ³
					//³03 - Titulo Inical                                    ³
					//³04 - Titulo Final                                     ³
					//³05 - Parcela Inicial                                  ³
					//³06 - Parcela Final                                    ³
					//³07 - Tipo Titulo Inicial                              ³
					//³08 - Tipo Titulo Final                                ³
					//³09 - Data Emissao Inicial                             ³
					//³10 - Data Emissao Final                               ³
					//³11 - Data Vencimento Real Inicial                     ³
					//³12 - Data Vencimento Real Final                       ³
					//³13 - Bordero Inicial                                  ³
					//³14 - Bordero Final                                    ³
					//³15 - Cliente Inicial                                  ³
					//³16 - Loja Inicial                                     ³
					//³17 - Cliente Inicial                                  ³
					//³18 - Loja Inicial                                     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					aTitBol[01] := SE1->E1_PREFIXO
					aTitBol[02] := SE1->E1_PREFIXO
					aTitBol[03] := SE1->E1_NUM
					aTitBol[04] := SE1->E1_NUM
					aTitBol[05] := SE1->E1_PARCELA
					aTitBol[06] := SE1->E1_PARCELA
					aTitBol[07] := SE1->E1_TIPO
					aTitBol[08] := SE1->E1_TIPO
					aTitBol[09] := SE1->E1_EMISSAO
					aTitBol[10] := SE1->E1_EMISSAO + 3650
					aTitBol[11] := SE1->E1_VENCREA
					aTitBol[12] := SE1->E1_VENCREA + 3650
					aTitBol[13] := ""
					aTitBol[14] := "ZZZZZZ"
					aTitBol[15] := SE1->E1_CLIENTE
					aTitBol[16] := SE1->E1_LOJA
					aTitBol[17] := SE1->E1_CLIENTE
					aTitBol[18] := SE1->E1_LOJA

					oBoleto := U_TRSF001D( aTitBol, aBcoBol )//Rotina para gerar o boleto

					If	ValType(oBoleto) = "O"
						
						oBoleto:Preview()

						cPathPDF  := AllTrim( oBoleto:cPathPDF )
						cFileName := StrTran( Lower( AllTrim( oBoleto:cFileName ) ) , ".rel" , ".pdf" )

						FreeObj(oBoleto)
						oBoleto   := Nil
						lExistBol := .F.
			
					EndIf

					cArqOrig := cPathPDF + cFileName
					cArqDest := "\portal_licenciado\boletos\boleto_"
					cArqDest += AllTrim( cCNPJ )+"_"
					cArqDest += AllTrim( StrTran( cZ9_PERIODO, "-","" ) )
					cArqDest += "_"+StrTran( Time(), ":","" )+".pdf"
					
					cArqRen	 := cWSDir
					cArqRen  += AllTrim( cCNPJ )
					cArqRen  += "_"+AllTrim( StrTran( cZ9_PERIODO, "-","" ) )
					cArqRen  += "_"+StrTran( Time(), ":","" )+".pdf"
					
					If FILE( cArqOrig )// Se encontrou o arquivo
					
						If frename( cArqOrig, cArqDest ) = 0
						
							::IMPRIMIBOLETO := WsClassNew("RetImprimiBoleto")
							::IMPRIMIBOLETO:_lRetBoleto := "true"
							::IMPRIMIBOLETO:cLinkBoleto := cArqRen 						
						
						Else

							::IMPRIMIBOLETO := WsClassNew("RetImprimiBoleto")
							::IMPRIMIBOLETO:_lRetBoleto := "false"
							::IMPRIMIBOLETO:cLinkBoleto := "Erro ao renomear o arquivo."
													
						EndIf
					
					Else
					
						::IMPRIMIBOLETO := WsClassNew("RetImprimiBoleto")
						::IMPRIMIBOLETO:_lRetBoleto := "false"
						::IMPRIMIBOLETO:cLinkBoleto := "Arquivo"+AllTrim( cArqOrig )+" não encontrado."
					
					EndIf
							
				EndIf
				
			Else

				::IMPRIMIBOLETO := WsClassNew("RetImprimiBoleto")
				::IMPRIMIBOLETO:_lRetBoleto := "false"
				::IMPRIMIBOLETO:cLinkBoleto := "Lançamento não possuí título no financeiro."
		
			EndIf
			
		Else
		
			::IMPRIMIBOLETO := WsClassNew("RetImprimiBoleto")
			::IMPRIMIBOLETO:_lRetBoleto := "false"
			::IMPRIMIBOLETO:cLinkBoleto := "Lançamento não possuí título no financeiro."

		EndIf

	EndIf
	
Return( .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Estrutura Simples do Metodo GETIMPRIMIBOLETO ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSSTRUCT RetImprimiBoleto
	WSDATA _lRetBoleto AS String
	WSDATA cLinkBoleto AS String
ENDWSSTRUCT


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao ³ GETLISTAPRODUTOS ³ Autor ³ Denis Rodrigues ³ Data ³ 08/04/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Listagem de Produtos  do Lancamento de Venda    no Portal  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 - Codigo da Empresa no Sistema                       ³±±
±±³          ³ cExp2 - Codigo da Filial no Sistema                        ³±±
±±³          ³ cExp3 - Usuario de acesso ao Servico do WS                 ³±±
±±³          ³ cExp4 - Senha de acesso ao Servico do WS                   ³±±
±±³          ³ cExp5 - CNPJ do Fornecedor/Licenciado                      ³±±
±±³          ³ cExp6 - Chave de acesso ao Portal                          ³±±
±±³          ³ cExp7 - Tipo de Login L=Licenciado / F = Fornecedor        ³±±
±±³          ³ cExp8 - Numero do Contrato                                 ³±±
±±³          ³ cExp9 - Revisao do Contrato                                ³±±
±±³          ³ cExp10- Codigo do Cliente                                  ³±±
±±³          ³ cExp11- Codigo da Loja                                     ³±±
±±³          ³ cExp12- Periodo do Lancamento                              ³±±
±±³          ³ cExp13- Data Inicial do Periodo                            ³±±
±±³          ³ cExp14- Data Final do Periodo                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente S.C Internacional                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD GETLISTAPRODUTOS WSRECEIVE cWEmpresa, cWFilial, cWSUsuario, cWSSenha, cCNPJ, cChvPortal, cTipoLogin,;
                                    cZ9_NUMCTO,cZ9_REVCTO,cZ9_CODCLI,cZ9_LOJCLI,cZ9_PERIODO,cZ9_DTINIPE,;
                                    cZ9_DTFIMPE,cZA_CODPDV WSSEND LISTAPRODUTOS WSSERVICE PORTALLICENCIADO

	Local cQuery 	   := ""
	Local cAlias1   	:= GetNextAlias()
	Local cAlias2		:= GetNextAlias()
	Local cDtPeriodo  := StrTran( cZ9_PERIODO, "-","" )
	Local aRet 		   := {"",""}
	Local lOK			:= .T.
	Local oNewProduto
	
	RpcClearEnv()
	RpcSetType( 3 )
	RpcSetenv( cWEmpresa, cWFilial,,,,GetEnvServer(),{"SZB","SZC"} )
	
	// Valida Usuario e Senha do Servico WebService
	If !WS10Login( cWEmpresa, cWFilial, cWSUsuario, cWSSenha )
	
  		LISTAPRODUTOS := WsClassNew( "RetListaProdutos" )
	   LISTAPRODUTOS:aRetProduto := {}	
   	
		oNewProduto := WsClassNew( "StrutProdutos" )
		oNewProduto:_lRetorno  := "false"
		oNewProduto:cRetMsg    := "Usuário ou senha do Serviço Web Services esta inválida."
		oNewProduto:cZC_CODLIC := ""
		oNewProduto:cZC_LOJLIC := ""
		oNewProduto:cZC_NUMCTO := ""
		oNewProduto:cZC_REVISA := ""
		oNewProduto:cZC_CODPRO := ""
		oNewProduto:cB1_DESC	  := ""
		oNewProduto:cZC_VALOR  := ""
		oNewProduto:cZC_QUANT  := ""
		oNewProduto:cZC_VLRLIQ := ""
		aAdd( ::LISTAPRODUTOS:aRetProduto, oNewProduto )
		lOK := .F.

	Else// Se o acesso ao Servico estiver OK, testa o login e senha do usuario
			
		// Valida o CNPJ e senha do Licenciado
		aRet := WS10ValUser( cWEmpresa,cWFilial,cCNPJ,cChvPortal,cTipoLogin )
			
		If aRet[1][1] == "false"
	
	  		LISTAPRODUTOS := WsClassNew( "RetListaProdutos" )
		   LISTAPRODUTOS:aRetProduto := {}	
	   	
			oNewProduto := WsClassNew( "StrutProdutos" )
			oNewProduto:_lRetorno  := aRet[1][1]
			oNewProduto:cRetMsg    := aRet[1][2]
			oNewProduto:cZC_CODLIC := ""
			oNewProduto:cZC_LOJLIC := ""
			oNewProduto:cZC_NUMCTO := ""
			oNewProduto:cZC_REVISA := ""
			oNewProduto:cZC_CODPRO := ""
			oNewProduto:cB1_DESC	  := ""			
			oNewProduto:cZC_VALOR  := ""
			oNewProduto:cZC_QUANT  := ""
			oNewProduto:cZC_VLRLIQ := ""
			aAdd( ::LISTAPRODUTOS:aRetProduto, oNewProduto )
			lOK := .F.
			
		EndIf
					
	EndIf	
	
	If lOK
	
		cQuery := " SELECT SZC.ZC_CODLIC,"
	   cQuery += "        SZC.ZC_LOJLIC,"
      cQuery += "        SZC.ZC_NUMCTO,"
	   cQuery += "        SZC.ZC_REVISA,"
	   cQuery += "        SZC.ZC_CODPRO,"
	   cQuery += "        SB1.B1_DESC"
		cQuery += " FROM "+RetSQLName("SZC")+" SZC, "
		cQuery +=          RetSQLName("SB1")+" SB1"
		cQuery += " WHERE SZC.ZC_FILIAL  = '"+ xFilial("SZC")+"'"
  		cQuery += "   AND SZC.ZC_CODLIC  = '"+ cZ9_CODCLI    +"'"
  		cQuery += "   AND SZC.ZC_LOJLIC  = '"+ cZ9_LOJCLI    +"'"
  		cQuery += "   AND SZC.ZC_NUMCTO  = '"+ cZ9_NUMCTO    +"'"
  		cQuery += "   AND SZC.ZC_REVISA  = '"+ cZ9_REVCTO    +"'"
  		cQuery += "   AND SZC.D_E_L_E_T_ <> '*'"
	
  		cQuery += "   AND SB1.B1_FILIAL  = '"+ xFilial("SB1")+"'"
  		cQuery += "   AND SB1.B1_COD     = SZC.ZC_CODPRO"
  		cQuery += "   AND SB1.D_E_L_E_T_ <> '*'"
  		cQuery += " ORDER BY SZC.ZC_CODPRO"
  		cQuery := ChangeQuery( cQuery )
  		dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1,.F.,.T. )	

  		If ( cAlias1 )->( !EOF() )
  		
  			LISTAPRODUTOS := WsClassNew( "RetListaProdutos" )
			LISTAPRODUTOS:aRetProduto := {}
  			
  			While ( cAlias1 )->( !EOF() ) 
  			
  		  		cAlias2 := GetNextAlias()
  		  			
	  			cQuery := " SELECT SZA.ZA_CODPRO,"
		   	cQuery += "        SB1.B1_DESC,"
	       	cQuery += "        SZA.ZA_QUANT,"
	       	cQuery += "        SZA.ZA_VLRLIQ,"
	       	cQuery += "        SZA.ZA_VALOR"
				cQuery += " FROM "+RetSQLName("SZA")+" SZA,"
				cQuery +=          RetSQLName("SB1")+" SB1"
				cQuery += " WHERE SZA.ZA_FILIAL  = '"+ xFilial("SZA")+"'"
	  			cQuery += "   AND SZA.ZA_NUMCTO  = '"+ cZ9_NUMCTO    +"'"
	  			cQuery += "   AND SZA.ZA_REVISA  = '"+ cZ9_REVCTO    +"'"
	  			cQuery += "   AND SZA.ZA_CODPRO  = '"+ ( cAlias1 )->ZC_CODPRO +"'"
	  			cQuery += "   AND SZA.ZA_PERIODO = '"+ cDtPeriodo    +"'"
	  			cQuery += "   AND SZA.ZA_DTINIPE = '"+ StrTran( cZ9_DTINIPE, "-","" )+"'"
	  			cQuery += "   AND SZA.ZA_DTFIMPE = '"+ StrTran( cZ9_DTFIMPE, "-","" )+"'"
		  		cQuery += "   AND SZA.ZA_CODPDV  = '"+ cZA_CODPDV    +"'"
		  		
	  		  	cQuery += "   AND SZA.D_E_L_E_T_ <> '*'"
	  			cQuery += "   AND SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
	  			cQuery += "   AND SZA.ZA_CODPRO = SB1.B1_COD"
	  			cQuery += "   AND SB1.D_E_L_E_T_ <> '*'"
	  			cQuery := ChangeQuery( cQuery )
	  			dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAlias2,.F.,.T. )
	  			
	  			If ( cAlias2 )->( !EOF() )// Se existir registro na SZA vai retornar o valor dos Itens
  					   					   				  	
					oNewProduto := WsClassNew( "StrutProdutos" )  			
					oNewProduto:_lRetorno  := "true"
					oNewProduto:cRetMsg    := "OK"
					oNewProduto:cZC_CODLIC := ( cAlias1 )->ZC_CODLIC
					oNewProduto:cZC_LOJLIC := ( cAlias1 )->ZC_LOJLIC
					oNewProduto:cZC_NUMCTO := ( cAlias1 )->ZC_NUMCTO
					oNewProduto:cZC_REVISA := ( cAlias1 )->ZC_REVISA
					oNewProduto:cZC_CODPRO := AllTrim( ( cAlias2 )->ZA_CODPRO )
					oNewProduto:cB1_DESC   := AllTrim( ( cAlias2 )->B1_DESC )
					oNewProduto:cZC_VALOR  := cValToChar( ( cAlias2 )->ZA_VALOR  )
					oNewProduto:cZC_QUANT  := cValToChar( ( cAlias2 )->ZA_QUANT  ) 
					oNewProduto:cZC_VLRLIQ := cValToChar( ( cAlias2 )->ZA_VLRLIQ ) 
					aAdd( ::LISTAPRODUTOS:aRetProduto, oNewProduto )				
  			  	
  			  	Else//Retorna os itens da SZC com valor e quantidade zerados

			  		LISTAPRODUTOS := WsClassNew( "RetListaProdutos" )
					LISTAPRODUTOS:aRetProduto := {}
			   					   				  	
					oNewProduto := WsClassNew( "StrutProdutos" )  			
					oNewProduto:_lRetorno  := "true"
					oNewProduto:cRetMsg    := "OK"
					oNewProduto:cZC_CODLIC := ( cAlias1 )->ZC_CODLIC
					oNewProduto:cZC_LOJLIC := ( cAlias1 )->ZC_LOJLIC
					oNewProduto:cZC_NUMCTO := ( cAlias1 )->ZC_NUMCTO
					oNewProduto:cZC_REVISA := ( cAlias1 )->ZC_REVISA
					oNewProduto:cZC_CODPRO := AllTrim( ( cAlias1 )->ZC_CODPRO )
					oNewProduto:cB1_DESC	  := AllTrim( ( cAlias1 )->B1_DESC  )
					oNewProduto:cZC_VALOR  := "0"
					oNewProduto:cZC_QUANT  := "0"
					oNewProduto:cZC_VLRLIQ := "0"
					aAdd( ::LISTAPRODUTOS:aRetProduto, oNewProduto )	  			  	
  			  					
  				EndIf
  				
  				( cAlias2 )->( dbCloseArea() )
  			
  			 	( cAlias1 )->( dbSkip() )
  			 	
  			EndDo  				
	
		Else
		  			
	  		LISTAPRODUTOS := WsClassNew( "RetListaProdutos" )
		   LISTAPRODUTOS:aRetProduto := {}	
	   	
			oNewProduto := WsClassNew( "StrutProdutos" )
			oNewProduto:_lRetorno  := "false"
			oNewProduto:cRetMsg    := "Nenhum registro localizado."
			oNewProduto:cZC_CODLIC := ""
			oNewProduto:cZC_LOJLIC := ""
			oNewProduto:cZC_NUMCTO := ""
			oNewProduto:cZC_REVISA := ""
			oNewProduto:cZC_CODPRO := ""
			oNewProduto:cB1_DESC	  := ""
			oNewProduto:cZC_VALOR  := ""
			oNewProduto:cZC_QUANT  := ""
			oNewProduto:cZC_VLRLIQ := ""
			aAdd( ::LISTAPRODUTOS:aRetProduto, oNewProduto )		  			
			
  		EndIf
  		
  		( cAlias1 )->( dbCloseArea() )
	
	EndIf
	
Return(.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Estrutura do Metodo GETLISTAPRODUTOS   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSSTRUCT RetListaProdutos
	WSDATA aRetProduto AS ARRAY Of StrutProdutos
ENDWSSTRUCT

WSSTRUCT StrutProdutos

	WSDATA _lRetorno	AS String
	WSDATA cRetMsg		AS String
	WSDATA cZC_CODLIC AS String
	WSDATA cZC_LOJLIC AS String
	WSDATA cZC_NUMCTO AS String
	WSDATA cZC_REVISA AS String
	WSDATA cZC_CODPRO AS String
	WSDATA cB1_DESC	AS String
	WSDATA cZC_VALOR  AS String
	WSDATA cZC_QUANT  AS String
	WSDATA cZC_VLRLIQ AS String
	
ENDWSSTRUCT

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao ³ GETLISTAPRODUTOS ³ Autor ³ Denis Rodrigues ³ Data ³ 08/04/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Listagem de Produtos  do Lancamento de Venda    no Portal  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 - Codigo da Empresa no Sistema                       ³±±
±±³          ³ cExp2 - Codigo da Filial no Sistema                        ³±±
±±³          ³ cExp3 - Usuario de acesso ao Servico do WS                 ³±±
±±³          ³ cExp4 - Senha de acesso ao Servico do WS                   ³±±
±±³          ³ cExp5 - CNPJ do Fornecedor/Licenciado                      ³±±
±±³          ³ cExp6 - Chave de acesso ao Portal                          ³±±
±±³          ³ cExp7 - Tipo de Login L=Licenciado / F = Fornecedor        ³±±
±±³          ³ cExp8 - Numero do Contrato                                 ³±±
±±³          ³ cExp9 - Revisao do Contrato                                ³±±
±±³          ³ cExp10- Codigo do Cliente                                  ³±±
±±³          ³ cExp11- Codigo da Loja                                     ³±±
±±³          ³ cExp12- Periodo do Lancamento                              ³±±
±±³          ³ cExp13- Data Inicial do Periodo                            ³±±
±±³          ³ cExp14- Data Final do Periodo                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente S.C Internacional                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD GETSALVAPRODUTOS WSRECEIVE cWEmpresa, cWFilial, cWSUsuario, cWSSenha, cCNPJ, cChvPortal, cTipoLogin,;
                                    cZ9_NUMCTO,cZ9_REVCTO,cZ9_CODCLI,cZ9_LOJCLI,cZ9_PERIODO,cZ9_DTINIPE,;
                                    cZ9_DTFIMPE,cZA_CODPDV,cZA_CODPRO WSSEND SALVAPRODUTOS WSSERVICE PORTALLICENCIADO

	Local cQuery 	 := ""
	Local cAlias1	 := ""
	Local cAlias2	 := ""
	Local cDtPeriodo:= StrTran( cZ9_PERIODO, "-","" )
	Local aRet 		 := {"",""}
	Local aLinha 	 := {}
	Local aArrayFim := {}	
	Local lOK		 := .T.
	Local nCnt 		 := 0
	Local nX 		 := 0
	Local nY			 := 0
	Local oGravaProd

	RpcClearEnv()
	RpcSetType( 3 )
	RpcSetenv( cWEmpresa, cWFilial,,,,GetEnvServer(),{"SZA"} )    
	
	// Valida Usuario e Senha do Servico WebService
	If !WS10Login( cWEmpresa, cWFilial, cWSUsuario, cWSSenha )
		
		SALVAPRODUTOS := WsClassNew( "RetSalvaProdutos" )
	   SALVAPRODUTOS:aRetGravaProd := {}	
   	
		oGravaProd := WsClassNew( "StrutProd" )
		oGravaProd:_lRet	     := "false"
		oGravaProd:cStatMsg    := "Usuário ou senha do Serviço Web Services esta inválida."
		oGravaProd:cZC_NUMCTO  := ""
		oGravaProd:cZC_REVISA  := ""
		oGravaProd:cZC_CODLIC  := ""
		oGravaProd:cZC_LOJLIC  := ""
		oGravaProd:cZ9_PERIODO := ""
		oGravaProd:cZ9_DTINIPER:= ""
	   oGravaProd:cZ9_DTFIMPER:= ""
		oGravaProd:cZC_CODPRO  := ""
		oGravaProd:cZC_VALOR   := ""
		oGravaProd:cZC_VLRLIQ  := ""
		oGravaProd:cZC_QUANT   := ""
		oGravaProd:cZA_CODPDV  := ""
		aAdd( ::SALVAPRODUTOS:aRetGravaProd, oGravaProd )
		
		lOK := .F.
	
	Else// Se o acesso ao Servico estiver OK, testa o login e senha do usuario
			
		// Valida o CNPJ e senha do Licenciado
		aRet := WS10ValUser( cWEmpresa,cWFilial,cCNPJ,cChvPortal,cTipoLogin )
			
		If aRet[1][1] == "false"

			SALVAPRODUTOS := WsClassNew( "RetSalvaProdutos" )
		   SALVAPRODUTOS:aRetGravaProd := {}	
	   	
			oGravaProd := WsClassNew( "StrutProd" )
			oGravaProd:_lRet	     := aRet[1][1]
			oGravaProd:cStatMsg    := aRet[1][2]
			oGravaProd:cZC_NUMCTO  := ""
			oGravaProd:cZC_REVISA  := ""
			oGravaProd:cZC_CODLIC  := ""
			oGravaProd:cZC_LOJLIC  := ""
			oGravaProd:cZ9_PERIODO := ""
			oGravaProd:cZ9_DTINIPER:= ""
		   oGravaProd:cZ9_DTFIMPER:= ""
			oGravaProd:cZC_CODPRO  := ""
			oGravaProd:cZC_VALOR   := ""
			oGravaProd:cZC_VLRLIQ  := ""
			oGravaProd:cZC_QUANT   := ""
			oGravaProd:cZA_CODPDV  := ""
			aAdd( ::SALVAPRODUTOS:aRetGravaProd, oGravaProd )	
	  		
			lOK := .F.
			
		EndIf
					
	EndIf	
	
	If lOK// Se o login estiver OK

	//+------------------------------------------------------+
	//| Transforma o array Unidimensional para Bidimensional |
	//+------------------------------------------------------+
		aLinha := StrTokArr( cZA_CODPRO,"|", .F. ) 

		For nCnt := 1 to Len(aLinha) Step 4		
			aAdd(aArrayFim,{})	
			For nX := nCnt To nCnt + 3           
				aAdd(Atail(aArrayFim),aLinha[nX])
			Next nX
		Next	
	
	//+--------------------------------------------------------------+
	//| Executa o processo de gravacao conforme a quantidade de Itens|
	//+--------------------------------------------------------------+
		For nY := 1 To Len( aArrayFim )
		
			cAlias1 := GetNextAlias()
		
			cQuery := " SELECT COUNT(*) AS EXISTE,"
			cQuery += "        R_E_C_N_O_ AS RECNO"
			cQuery += " FROM "+RetSQLName("SZA")
			cQuery += " WHERE ZA_FILIAL  = '"+ xFilial("SZA")   +"'"
	  		cQuery += "   AND ZA_NUMCTO  = '"+ cZ9_NUMCTO       +"'"
	  		cQuery += "   AND ZA_REVISA  = '"+ cZ9_REVCTO       +"'"
	  		cQuery += "   AND ZA_CODPRO  = '"+ aArrayFim[nY][1] +"'"
	  		cQuery += "   AND ZA_PERIODO = '"+ cDtPeriodo    +"'"
	  		cQuery += "   AND ZA_DTINIPE = '"+ StrTran( cZ9_DTINIPE, "-","" )+"'"
	  		cQuery += "   AND ZA_DTFIMPE = '"+ StrTran( cZ9_DTFIMPE, "-","" )+"'"
		  	cQuery += "   AND ZA_CODPDV  = '"+ cZA_CODPDV    +"'"
		  	cQuery += "   AND D_E_L_E_T_ <>'*'"
		  	cQuery += " GROUP BY R_E_C_N_O_"
	  		cQuery := ChangeQuery( cQuery )
	  		dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1,.F.,.T. )
	  		
			
			If ( cAlias1 )->EXISTE > 0//Se existe vai apenas fazer o update dos valores
				
				dbSelectArea("SZA")
				SZA->( dbGoTo( ( cAlias1 )->RECNO ) )
				Reclock("SZA",.F.)
					SZA->ZA_QUANT  := Val( aArrayFim[nY][2] )
					SZA->ZA_VLRLIQ := Val( aArrayFim[nY][4] )
					SZA->ZA_VALOR  := Val( aArrayFim[nY][3] )
				MsUnLock()	
				
			Else	
			
				dbSelectArea("SZA")
				Reclock("SZA",.T.)
					SZA->ZA_FILIAL := xFilial("SZA")
					SZA->ZA_NUMCTO := cZ9_NUMCTO
					SZA->ZA_REVISA := cZ9_REVCTO 
					SZA->ZA_CODPRO := aArrayFim[nY][1]										
					SZA->ZA_PERIODO:= cDtPeriodo
					SZA->ZA_DTINIPE:= StoD( StrTran( cZ9_DTINIPE,"-","" ) )
					SZA->ZA_DTFIMPE:= StoD( StrTran( cZ9_DTFIMPE,"-","" ) )
					SZA->ZA_QUANT  := Val( aArrayFim[nY][2] )
					SZA->ZA_VLRLIQ := Val( aArrayFim[nY][4] )
					SZA->ZA_VALOR  := Val( aArrayFim[nY][3] )
					SZA->ZA_CODPDV :=	cZA_CODPDV
				MsUnLock()
						
			EndIf
			
			( cAlias1 )->( dbCloseArea() )
					
		Next nY
		
		//+--------------------------------------------------------------------------+
		//| Faz a soma dos valores dos produtos para atualizar no Lancamento de Venda|
		//+--------------------------------------------------------------------------+
		cAlias1 := GetNextAlias()
		
		cQuery := " SELECT SUM(ZA_VALOR) AS VALOR,"
      	cQuery += "        SUM(ZA_VLRLIQ) AS VLRLIQ,"
	    cQuery += "        SUM(ZA_QUANT) AS QUANT"
		cQuery += " FROM "+RetSQLName("SZA")
		cQuery += " WHERE ZA_FILIAL  = '"+ xFilial("SZA")+"'"
  		cQuery += "   AND ZA_NUMCTO  = '"+ cZ9_NUMCTO    +"'"
  		cQuery += "   AND ZA_REVISA  = '"+ cZ9_REVCTO    +"'"
  		cQuery += "   AND ZA_PERIODO = '"+ cDtPeriodo    +"'"
  		cQuery += "   AND ZA_DTINIPE = '"+ StrTran( cZ9_DTINIPE,"-","" ) +"'"
  		cQuery += "   AND ZA_DTFIMPE = '"+ StrTran( cZ9_DTFIMPE,"-","" ) +"'"
  		cQuery += "   AND ZA_VALOR   > 0 "
  		cQuery += "   AND ZA_VLRLIQ  > 0 "
  		cQuery += "   AND ZA_QUANT   > 0 "  		  		
  		cQuery += "   AND D_E_L_E_T_ <> '*'"
	  	cQuery := ChangeQuery( cQuery )
	  	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1,.F.,.T. )
	  	
	  	If ( cAlias1 )->( !EOF() )
	  		
	  			//+---------------------------------------------------+
				//| Atualiza os valores totais no lancamento de venda |
				//+---------------------------------------------------+
	  			cAlias2 := GetNextAlias()
	  			cQuery := " SELECT R_E_C_N_O_ AS RECNO"
				cQuery += " FROM "+RetSQLName("SZ9")
				cQuery += " WHERE Z9_FILIAL  = '"+ xFilial("SZ9") +"'"
				cQuery += "   AND Z9_NUMCTO  = '"+ cZ9_NUMCTO     +"'"
				cQuery += "   AND Z9_REVCTO  = '"+ cZ9_REVCTO     +"'"
				cQuery += "   AND Z9_CODCLI  = '"+ cZ9_CODCLI     +"'"
			  	cQuery += "   AND Z9_LOJCLI  = '"+ cZ9_LOJCLI     +"'"
				cQuery += "   AND Z9_PERIODO = '"+ cDtPeriodo	  +"'"
				cQuery += "   AND Z9_DTINIPE = '"+ StrTran( cZ9_DTINIPE, "-","")+"'"
				cQuery += "   AND Z9_DTFIMPE = '"+ StrTran( cZ9_DTFIMPE, "-","")+"'"
				cQuery += "   AND D_E_L_E_T_ <>'*'"
				cQuery := ChangeQuery( cQuery )
				dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery), cAlias2,.F.,.T. )
				
				If ( cAlias2 )->( !EOF() )
				
					dbSelectArea("SZ9")
					SZ9->( dbGoTo( ( cAlias2 )->RECNO ) )
					Reclock("SZ9",.F.)
						SZ9->Z9_QUANT  := ( cAlias1 )->QUANT
						SZ9->Z9_VLRLIQ := ( cAlias1 )->VLRLIQ
						SZ9->Z9_VALOR  := ( cAlias1 )->VALOR
					MsUnLock()				
				
				EndIf
				
				( cAlias2 )->( dbCloseArea() )
	  	
	  	EndIf
	  	
	  	( cAlias1 )->( dbCloseArea() )

		SALVAPRODUTOS := WsClassNew( "RetSalvaProdutos" )
	   SALVAPRODUTOS:aRetGravaProd := {}	
   	
		oGravaProd := WsClassNew( "StrutProd" )
		oGravaProd:_lRet	   := "true"
		oGravaProd:cStatMsg    := "Registros incluidos com sucesso."
		oGravaProd:cZC_NUMCTO  := ""
		oGravaProd:cZC_REVISA  := ""
		oGravaProd:cZC_CODLIC  := ""
		oGravaProd:cZC_LOJLIC  := ""
		oGravaProd:cZ9_PERIODO := ""
		oGravaProd:cZ9_DTINIPER:= ""
	    oGravaProd:cZ9_DTFIMPER:= ""
		oGravaProd:cZC_CODPRO  := ""
		oGravaProd:cZC_VALOR   := ""
		oGravaProd:cZC_VLRLIQ  := ""
		oGravaProd:cZC_QUANT   := ""
		oGravaProd:cZA_CODPDV  := ""
		aAdd( ::SALVAPRODUTOS:aRetGravaProd, oGravaProd )		
			
	EndIf
	
Return( .T. )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³  Estrutura do Metodo GETSALVAPRODUTOS   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
WSSTRUCT RetSalvaProdutos
	WSDATA aRetGravaProd AS ARRAY Of StrutProd
ENDWSSTRUCT

WSSTRUCT StrutProd

	WSDATA _lRet			AS String
	WSDATA cStatMsg		AS String
	WSDATA cZC_NUMCTO 	AS String
	WSDATA cZC_REVISA 	AS String
	WSDATA cZC_CODLIC 	AS String
	WSDATA cZC_LOJLIC		AS String
	WSDATA cZ9_PERIODO	AS String
	WSDATA cZ9_DTINIPER	AS String
   WSDATA cZ9_DTFIMPER	AS String
	WSDATA cZC_CODPRO 	AS String
	WSDATA cZC_VALOR  	AS String
	WSDATA cZC_VLRLIQ 	AS String
	WSDATA cZC_QUANT  	AS String
	WSDATA cZA_CODPDV 	AS String
	
ENDWSSTRUCT