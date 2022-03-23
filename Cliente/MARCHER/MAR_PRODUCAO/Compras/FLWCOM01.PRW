#INCLUDE "TOTVS.ch"

/*/{Protheus.doc} FLWCOM01
Programa de Envio de  Workflow para FolowUP de Entrega dos fornec.
Chamado do MARWF001 - Rotina chamadora do Wf de Pedido de Compr.  
@type function
@version 12.1.25
@author Márcio Quevedo Borges
@since 11/10/2018  
/*/
User Function FLWCOM01()

	Local cSql     := ""
	Local aArea    := GetArea()
	Local dDataRef := dDataBase
	Local cForn    := ""
	Local cLoja    := ""
	Local cNome    := ""
	Local cPedido  := ""
	Local x        := 0
	Local lCenture := .F. // Alterou o Century //Necessário para sempre tratar com ano 4 posições

	If !(Len(DTOC(dDatabase)) == 10) // DD/MM/AAAA
		Set Century On
		lCenture := .F.
	EndIf

	Private nDiasFLW 	:= SuperGetMV("MA_DFLWF",,3) //Dias Folow-up PC x Fornec3edores  -- [3 dias úteis padrão]
	Private cSqlWhere 	:= " "

	CONOUT("FLWCOM01 - Inicio - Processo Workflow Folo-up Compras")

	// Busca data de Referência conforme dias uteis para folow
	For x := 1 To nDiasFLW
		dDataRef := DataValida(dDataRef+1)
	Next x

	// ######################################################################################################
	// Consulta agrupada por fornecedores para fazer whilede Processo WF - 1 Processo para cada Fornecedor ##
	// ######################################################################################################
	If Select("T_TMPFOR") > 0
		T_TMPFOR->( dbCloseArea() )
	EndIf

	cSql := ""
	cSql := "SELECT SC7.C7_FILIAL  ,"                             + CHR(13)
	cSql += "       SC7.C7_NUM     ,"                             + CHR(13)
	cSql += "       SC7.C7_FORNECE ,"                             + CHR(13)
	cSql += "       SC7.C7_LOJA    ,"                             + CHR(13)
	cSql += "       SA2.A2_NOME    ,"                             + CHR(13)
	cSql += "       SA2.A2_EMAIL   ,"                             + CHR(13)
	cSql += "       SA2.A2_EMLFLWU  "                             + CHR(13)
	cSql += "  FROM " + RetSqlName("SC7") + " SC7, "              + CHR(13)
	cSql += "       " + RetSqlName("SA2") + " SA2  "              + CHR(13)
	cSql += " WHERE SC7.C7_FILIAL  = '"  + Alltrim(cFilAnt) + "'" + CHR(13)
	cSql += "   AND CASE WHEN C7_DTFOLOW = ' ' THEN SC7.C7_DATPRF ELSE SC7.C7_DTFOLOW END = '"  + Dtos(dDataRef)   + "'" + CHR(13)
	cSql += "   AND SC7.C7_APROV  <> ''"                          + CHR(13)
	cSql += "   AND SC7.C7_WFID    = ''"                          + CHR(13)
	cSql += "   AND SC7.C7_QUJE    < SC7.C7_QUANT"                + CHR(13)
	cSql += "   AND SC7.D_E_L_E_T_ = ''"                          + CHR(13)
	cSql += "   AND SA2.A2_COD     = SC7.C7_FORNECE"              + CHR(13)
	cSql += "   AND SA2.A2_LOJA    = SC7.C7_LOJA   "              + CHR(13)
	cSql += "   AND SA2.D_E_L_E_T_ = ''            "              + CHR(13)
	cSql += " GROUP BY SC7.C7_FILIAL , SC7.C7_NUM , SC7.C7_FORNECE, SC7.C7_LOJA, SA2.A2_NOME, SA2.A2_EMAIL, SA2.A2_EMLFLWU" + CHR(13)
	cSql += " ORDER BY SC7.C7_FORNECE, SC7.C7_LOJA, SA2.A2_NOME"  + CHR(13)

	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TMPFOR", .T., .T. )

	While !T_TMPFOR->( Eof() )

		cForn   := T_TMPFOR->C7_FORNECE
		cLoja   := T_TMPFOR->C7_LOJA
		cPedido := T_TMPFOR->C7_NUM
		cNome   := T_TMPFOR->A2_NOME
		cMail   := IIF(EMPTY(Alltrim(T_TMPFOR->A2_EMLFLWUP)), T_TMPFOR->A2_EMAIL , T_TMPFOR->A2_EMLFLWUP)

		MsgRun("Gerando WorkFlow da(s) Ordem(ns) de Compra(s), Aguarde...","",{|| CursorWait(), FLWCOMWK(cPedido, cForn,cLoja,cNome,cMail,dDataRef), CursorArrow()})

		T_TMPFOR->(DBSkip())

	Enddo

	// ###############################################
	// Retorna o Posicionamento Original do Arquivo ##
	// ###############################################
	RestArea(aArea)
	CONOUT("FLWCOM01 - Fim -  Processo Workflow Folo-up Compras")

	If lCenture
		Set Century Off
	Endif
Return


/*/{Protheus.doc} FLWCOMWK
Função que envia o workflow
@type function
@version 12.1.25
@author Márcio Quevedo Borges
@since 11/10/2018  
@param cPedido, character, Pedido
@param cForn, character, Fornecedor
@param cLoja, character, Loja
@param cNome, character, Nome 
@param cDestinatario, character, E-mail do destinatario
@param dDataRef, date, Data de Referência
/*/
Static Function FLWCOMWK(cPedido, cForn, cLoja, cNome, cDestinatario, dDataRef)

	Local _cProdAmb  := SuperGetMV("MV_AMBPROD",,"PRODUCAO") // Ambientes para considerar como producao
	Local cWfLinkSrv := SuperGetMV("MA_WFLINKS",,"http://172.16.0.7:8085/WorkFlow/Messenger/Emp01/")// Link do endereço do server
	Local cUser      := __cUserID

	DbSelectArea("SC7")
	DbSetOrder(1)

	// ####################
	// Assunto do E-mail ##
	// ####################
	cAssunto := "Confirmação Entrega de Pedidos para Data " + DTOC(dDataRef)

	// ##########################################################################
	// Se não for ambientes de producao, adiciona mensagem de teste no assunto ##
	// ##########################################################################
	If !(UPPER(Alltrim(GetEnvServer())) $ UPPER(_cProdAmb ))
		cAssunto := "TESTE - FAVOR DESCONSIDERAR: " + cAssunto
	Endif

	// ############################################################
	// Caminho e Arquivo HTML do Link de Formulario de Aprovacao ##
	// ############################################################
	cArqHtml := "\Workflow\WFSC7Envio.html"

	// #########################
	// Obtem o Usuario Logado ##
	// #########################
	cUsrCorrente := SubStr(cUsuario, 7, 15)

	// #####################################################
	// Inicia o Processo de WorkFlow de Cotação de Preços ##
	// #####################################################
	oProcess := TWFProcess():New( "FLWCOM", cAssunto )

	// #########################################################
	// Cria uma Nova Tarefa Informando o HTML do Link de Envio ##
	// ##########################################################
	oProcess:NewTask( "Confirmação Entega Ordem Compra", cArqHtml )
	CONOUT("FLWCOMWK - Inicio processo Confirmação Entega Ordem Compra")

	// ###################################################################################################
	// Informa o Codigo e Descricao do Status do Processo Correspondente ao Inicio do Start de WorkFlow ##
	// ###################################################################################################
	cCodigoStatus := "100100"
	cDescricao    := "Inicio do Processo de Folow Ordem de Compra."

	// ####################################################################
	// Ratreabilidade com o Codigo do Status, Descricao e Usuario Logado ##
	// ####################################################################
	oProcess:Track( cCodigoStatus, cDescricao, cUsrCorrente)
	CONOUT("FLWCOMWK -" + cCodigoStatus + " - " + cDescricao  )

	// ####################################################################
	// Função de Retorno com Dados enviados pelos Fornecedores           ##
	// ####################################################################
	oProcess:bReturn  := "U_RETWFC01"
	oProcess:cSubject := cAssunto

	// #####################################################################
	// Usuario Responsavel pelo Processo do WorkFlow de Folow Pedido Compra#
	// #####################################################################
	oProcess:UserSiga := WFCodUser( cUser )

	// ################################################################
	// Cria Objeto HTML do Processo de WorkFlow de Cotação de Preços ##
	// ################################################################
	oHtml := oProcess:oHTML

	// ###################################################################################################
	// Informa o Codigo e Descricao do Status do Processo Correspondente ao Inicio do Start de WorkFlow ##
	// ###################################################################################################
	cCodigoStatus := "100200"
	cDescricao    := "Gerando Processo de Ordem de Compra."

	// ####################################################################
	// Ratreabilidade com o Codigo do Status, Descricao e Usuario Logado ##
	// ####################################################################
	oProcess:Track(cCodigoStatus, cDescricao, cUsrCorrente )
	CONOUT("FLWCOMWK -" + cCodigoStatus + " - " + cDescricao  )

	// ######################################################################
	// Carrega as variáveis para preechimento do HTML de cotação de preços ##
	// ######################################################################

	// ##########################
	// Gera Id para o Processo ##
	// ##########################
	_cWFID := oProcess:fProcessID

	// #####################
	// Preenche Cabecalho ##
	// #####################
	oHtml:ValByName( "Cod_Fornecedor" , cForn + "/" + cLoja  )
	oHtml:ValByName( "Nome_Fornecedor" , cNome  )
	oHtml:ValByName( "Dt_Entrega" , DTOC(dDataRef)  )

	// ################
	// Carrega itens ##
	// ################

	// ################################################################################
	// Consulta Específica para dados dos ítens do fornecedor para a data em questão ##
	// ################################################################################
	If Select("T_TMPITENS") > 0
		T_TMPITENS->( dbCloseArea() )
	EndIf

	cSql := ""
	cSql += "SELECT C7_FILIAL ,"                                                     + CHR(13)
	cSql += "       C7_NUM    ,"                                                     + CHR(13)
	cSql += "       C7_ITEM   ,"                                                     + CHR(13)
	cSql += "       C7_PRODUTO,"                                                     + CHR(13)
	cSql += "       C7_DESCRI ,"                                                     + CHR(13)
	cSql += "       C7_UM     ,"                                                     + CHR(13)
	cSql += "       C7_QUANT  ,"                                                     + CHR(13)
	cSql += "       C7_YMOTIVA,"                                                     + CHR(13)
	cSql += "       C7_WFID   ,"                                                     + CHR(13)
	cSql += "       R_E_C_N_O_ NRECNO"                                               + CHR(13)
	cSql += "  FROM " + RetSqlName("SC7")                                            + CHR(13)
	cSql += " WHERE C7_FILIAL  = '"  + Alltrim(cFilAnt) + "'"                        + CHR(13)
	cSql += "   AND CASE WHEN C7_DTFOLOW = ' ' THEN C7_DATPRF ELSE C7_DTFOLOW END = CONVERT(DATETIME,'" + Dtoc(dDataRef)   + "', 103) " + CHR(13)
	cSql += "   AND C7_NUM     = '"  + Alltrim(cPedido) + "'"                        + CHR(13)
	cSql += "   AND C7_WFID    = ''"                                                 + CHR(13)
	cSql += "   AND D_E_L_E_T_ = ''"                                                 + CHR(13)
	cSql += "   AND C7_FORNECE = '"  + Alltrim(cForn)   + "'"                        + CHR(13)
	cSql += "   AND C7_LOJA    = '"  + Alltrim(cLoja)   + "'"                        + CHR(13)
	cSql += " ORDER BY C7_FORNECE,C7_LOJA, C7_FILIAL, C7_NUM, C7_ITEM "              + CHR(13)

	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TMPITENS", .T., .T. )

	If T_TMPITENS->(Eof())
		aAdd( (oHtml:ValByName( "it.Pedido"  ))		, "--- Sem dados ---"  )
		aAdd( (oHtml:ValByName( "it.Item"  ))		, "---" )
		aAdd( (oHtml:ValByName( "it.Codigo"  ))		, "---"   )
		aAdd( (oHtml:ValByName( "it.Unid"  ))		, "--"   )
		aAdd( (oHtml:ValByName( "it.Descricao"  ))	, "-------"   )
		aAdd( (oHtml:ValByName( "it.Qtd"  ))		, "--.--"   )
	Endif

	While ( T_TMPITENS->(!Eof()) )

		aAdd( (oHtml:ValByName( "it.Pedido"   )), T_TMPITENS->C7_NUM  )
		aAdd( (oHtml:ValByName( "it.Item"     )), T_TMPITENS->C7_ITEM  )
		aAdd( (oHtml:ValByName( "it.Codigo"   )), T_TMPITENS->C7_PRODUTO  )
		aAdd( (oHtml:ValByName( "it.Unid"     )), T_TMPITENS->C7_UM  )
		aAdd( (oHtml:ValByName( "it.Descricao")), T_TMPITENS->C7_DESCRI  )
		aAdd( (oHtml:ValByName( "it.Qtd"      )), TRANSFORM( T_TMPITENS->C7_QUANT,'@E 99,999.99' )  )

		SC7->(DBGoto(T_TMPITENS->NRECNO))

		If T_TMPITENS->NRECNO == SC7->(RECNO())
			SC7->(RecLock("SC7",.F.))
			SC7->C7_WFID := _cWFID
			SC7->(MsUnlock())
		Else
			Conout("Não localizou o registro no SC7 para fazer atualizar valores - " + cValToChar(T_TMPITENS->NRECNO) )
		Endif

		T_TMPITENS->(DBSkip())

	Enddo

	// #################################################
	// Salva o Processo de WorkFlow na Pasta FLWCOM01 ##
	// #################################################
	oProcess:cTo := "FLWCOM01"

	// #####################################################
	// Cria o Processo de WorkFlow para Cotação de Preços ##
	// #####################################################
	cMailID := oProcess:Start()

	// #################################
	// Associa o Arquivo HTML do Link ##
	// #################################
	cHtmlModelo := "\workflow\WFSC7Link.html"

	// #############################################################
	// Cria uma Nova Tarefa para ao Processo de Cotação de Preços ##
	// #############################################################
	oProcess:NewTask(cAssunto, cHtmlModelo)

	// ################################################
	// Destinatario do fornecedor Separado por Ponto e Virgulha(;) ##
	// ################################################
	oProcess:cTo := cDestinatario

	// ##############################################
	// Substitui as Macros do Arquivo HTML do Link ##
	// ##############################################
	oProcess:oHTML:ValByName("dDatPrf", DTOC(dDataRef))

	oProcess:oHTML:ValByName("proc_link", cWfLinkSrv + "FLWCOM01/" + cMailID + ".htm")

	// ###################################################################################################
	// Informa o Codigo e Descricao do Status do Processo Correspondente ao Inicio do Start de WorkFlow ##
	// ###################################################################################################
	cCodigoStatus := "100300"
	cDescricao    := "Enviando Processo de Ordem de Compra"

	// ###################################################################
	//Ratreabilidade com o Codigo do Status, Descricao e Usuario Logado ##
	// ###################################################################
	oProcess:Track( cCodigoStatus, cDescricao, cUsrCorrente )
	CONOUT("FLWCOMWK -" + cCodigoStatus + " - " + cDescricao  )

	// ########################################################################
	// Inicia o Processo de Envio de E-mail do WorkFlow de Cotação de Preços ##
	// ########################################################################
	oProcess:Start()

Return


/*/{Protheus.doc} RETWFC01
Funcao de Retorno da Aprovacao/Rejeicao do WorkFlow 
@type function
@version 12.1.25
@author Márcio Quevedo Borges
@since 11/10/2018  
@param oProcess, object, Processo
/*/
User Function RETWFC01(oProcess)

	Local _cWFID 	     := oProcess:fProcessID
	Local cCodigoStatus := ""
	Local cDescricao    := ""
	Local cDescWork     := ""
	Local cMotivo       := ""
	Local cNRPedidos    := ""

	// #####################################
	// Varáveis para Manipulação de Dados ##
	// #####################################
	Local dNovaData
	Local cDtRef  := ""

	// ##################################################################
	// Recupera a Data de Entrega (referencia do WF)e Nome Fornecedor  ##
	// ##################################################################
	cDtRef := oProcess:oHtml:RetByName("Dt_Entrega")

	// ###################################################################################################
	// Informa o Codigo e Descricao do Status do Processo Correspondente ao Inicio do Start de WorkFlow ##
	// ###################################################################################################
   /*cAssunto      := "Ordem de Compra ref. data" + cDtRef
   // Se não for ambientes de producao, adiciona mensagem de teste no assunto
   If !(UPPER(Alltrim(GetEnvServer())) $ UPPER(_cProdAmb ))
	  cAssunto := "TESTE - FAVOR DESCONSIDERAR: " + cAssunto
   Endif
   */

	cCodigoStatus := "100400"
	cDescricao    := "Aguardando retorno da Ordem de Compras "

	// #########################
	// Obtem o Usuario Logado ##
	// #########################
	cUsrCorrente := SubStr(cUsuario, 7, 15)

	// ####################################################################
	// Ratreabilidade com o Codigo do Status, Descricao e Usuario Logado ##
	// ####################################################################
	oProcess:Track( cCodigoStatus, cDescricao,cUsrCorrente )
	CONOUT("RETWFC01 -" + cCodigoStatus + " - " + cDescricao  )

	// #####################################################################################
	// Recupera se foi informado nova data  no WorkFlow ou se irá atender na data prevista##
	// #####################################################################################
	lNoPrazo :=  (oProcess:oHtml:RetByName("DTPRFOK")) == 'Sim'

	// ########################################################################
	// Tratando dado do campo de Data que vem no formato String "AAAA-MM-DD" ##
	// ########################################################################
	conout("FLWCOM01-Retorno- nova data: "+ oProcess:oHtml:RetByName("NOVADATA"))
	dNovaData :=  strtran(oProcess:oHtml:RetByName("NOVADATA"),"-","")
	dNovaData :=  STOD(dNovaData)
	cMotivo   :=  oProcess:oHtml:RetByName("CMOTIVO")
	conout("FLWCOM01-Retorno- Motivo: "+ cMotivo)

	// ###################################################
	// Captura dados para pesquisa da cotação retornada ##
	// ###################################################

	// ############################################################################################################
	// Será feito a pesquisa pelo WFID, porém se o controle fosse por item teria que ser pesquisado os registros ##
	// ############################################################################################################
	If Select("T_TMP_RET") > 0
		T_TMP_RET->( dbCloseArea() )
	EndIf

	cSql := ""
	cSql := "SELECT R_E_C_N_O_ AS NRECNO"
	cSql += "  FROM " + RetSqlName("SC7")
	cSql += " WHERE C7_FILIAL   = '" + Alltrim(cFilAnt) + "'"
	cSql += "   AND C7_WFID     = '" + AllTrim(_cWFID)  + "'"
	cSql += "   AND D_E_L_E_T_ <> '*'"

	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_TMP_RET", .T., .T. )

	DBSelectArea("SC7")
	DBSetOrder(1)

	cNRPedidos := ""

	While ( T_TMP_RET->(!Eof()) )

		SC7->(DBGoto(T_TMP_RET->NRECNO))

		If T_TMP_RET->NRECNO == SC7->(RECNO())
			ctmpDt     := SC7->C7_DATPRF
			cNRPedidos := SC7->C7_NUM
			SC7->(RecLock("SC7",.F.))
			If !lNoPrazo
				// Jorge Alberto - Solutio - 16/12/2021 - Alterada a gravação da nova data de Entrega.
				// SC7->C7_DATPRF  := dNovaData
				SC7->C7_DTFOLOW  := dNovaData
				SC7->C7_YMOTIVA := cMotivo
			Endif
			SC7->C7_YDTPRFO := ctmpDt
			SC7->(MsUnlock())
		Else
			Conout("FLWCOM01 - Erro Retorno -Não localizou o registro no SC7 para atualizar valores - " + cValToChar(T_TMP_RET->NRECNO ))
		Endif

		T_TMP_RET->(DBSkip())

	EndDo

	// ########################################################
	// Associa a Descricao do Track ao Titulo da Notificacao ##
	// ########################################################
	cDescWork := cDescricao

	// ####################################################################
	// Ratreabilidade com o Codigo do Status, Descricao e Usuario Logado ##
	// ####################################################################
	oProcess:Track( cCodigoStatus, cDescricao )
	CONOUT("RETWFC01 -" + cCodigoStatus + " - " + cDescricao  )

	// ########################################################################
	// Execute a função responsável pela notificação ao usuário solicitante. ##
	// ########################################################################
	U_NOTWFC01( oProcess, cDescWork, cNRPedidos )

Return Nil



/*/{Protheus.doc} NOTWFC01
Funcao de Notificacao ao comprador
@type function
@version 12.1.25
@author Márcio Quevedo Borges
@since 11/10/2018  
@param oProcess, object, Processo
@param cDescWork, character, Descrição
@param cNRPedidos, character, Número Pedidos
/*/
User Function NOTWFC01( oProcess, cDescWork, cNRPedidos )

	Local _cWFID 	   := oProcess:fProcessID
	Local cCodigoStatus := ""
	Local cDescricao    := ""
	Local cArqHtml      := ""
	Local cAssunto      := ""
	Local cDestinatario := SuperGetMV("MA_EMLCOM",,"compras@marcher.com.br")

	// #######################################################################################
	// Informa o Codigo do Status do Processo Correspondente ao Inicio do Start de WorkFlow ##
	// #######################################################################################
	cCodigoStatus  := "100700"
	cDescricao   := "Notifica recebimento da Ordem de Compras "

	// ####################################################################
	// Ratreabilidade com o Codigo do Status, Descricao e Usuario Logado ##
	// ####################################################################
	oProcess:Track( cCodigoStatus, cDescricao )
	Conout("NOTWFC01 - Iniciando processo de notificaçã da Ordem de Compra")

	// ##################################################################
	// Recupera a Data de Entrega (referencia do WF)e Nome Fornecedor  ##
	// ##################################################################
	cForn		:= oProcess:oHtml:RetByName("Cod_Fornecedor")
	cNome  		:= oProcess:oHtml:RetByName("Nome_Fornecedor")
	cDtRef 		:= oProcess:oHtml:RetByName("Dt_Entrega")

	// ########
	// Itens ##
	// ########
	cNovaData :=  DTOC(STOD(strtran(oProcess:oHtml:RetByName("NOVADATA"),"-","")))
	cMotivo 	 :=  oProcess:oHtml:RetByName("CMOTIVO")
	cMensagem := ""

	If Empty(cMotivo)
		If !Empty(Alltrim(cNRPedidos))
			cMensagem += "Retorno referente ao Pedido Nr. " + Alltrim(cNRPedidos) + "<br><br>"
		Endif
		cMensagem += "Previsão de Entrega Original Confirmada : " + cDtRef
	Else
		If !Empty(Alltrim(cNRPedidos))
			cMensagem += "Retorno referente ao Pedido Nr. " + Alltrim(cNRPedidos) + "<br><br>"
		Endif
		cMensagem += "Previsão de Entrega Original : " + cDtRef + ;
			"<br>Nova Previsão de Entrega: "  + cNovaData + "<br><br> Justificativa: " + cMotivo
	Endif

	// ################################################################
	// Cria Objeto HTML do Processo de WorkFlow de Cotação de Preços ##
	// ################################################################
	// oHtml := oProcess:oHtml

	// ####################
	// Assunto do E-mail ##
	// ####################
	cAssunto := "Folow-Up de Ordens de Compra"

	// ##########################################################################
	// Se não for ambientes de producao, adiciona mensagem de teste no assunto ##
	// ##########################################################################
   /*If !(UPPER(Alltrim(GetEnvServer())) $ UPPER(_cProdAmb ))
   	  cAssunto := "TESTE - FAVOR DESCONSIDERAR: " + cAssunto
   Endif*/

   // ####################################################################
   // Caminho e Arquivo HTML do Link de Formulario de Cotação de Preços ##
   // ####################################################################
   cArqHtml := "\Workflow\WFSC7AvisoRetPC.html"

   // #####################################################
   // Inicia o Processo de WorkFlow de Cotação de Preços ##
   // #####################################################
   o2Process := TWFProcess():New( "FLWCOM", cAssunto )

   // #########################################################
   // Cria uma Nova Tarefa Informando o HTML do Link de Envio ##
   // ##########################################################
   o2Process:NewTask( "Retorno de Ordem de Compra", cArqHtml )

   // ####################################################
   // Carrega a Data de Referência para display no HTML ##
   // ####################################################
   o2Process:oHTML:ValByName("Dt_Entrega", cDtRef)

   // #####################################################
   // Pesquisa o nome do Fornecedor para display no HTML ##
   // #####################################################
   o2Process:oHTML:ValByName("Nome_Fornecedor", cNome)

   // #####################################################
   // Informa a mensagem de alt. data e justificativa    ##
   // #####################################################
   o2Process:oHTML:ValByName("MENSAGEM",cMensagem)
   o2Process:oHTML:ValByName("ID",_cWFID)

   // ##############################################
   // Substitui as Macros do Arquivo HTML do Link ##
   // ##############################################
   //o2Process:oHTML:ValByName("proc_link", "http://localhost:8085/WorkFlow/Messenger/Emp99/FLWCOM01/" + _cWFID + ".htm")

   // #####################################################################################
   // E-mail que Ira Receber a Notificacao de Aprovacao/Rejeicao do Processo de WorkFlow ##
   // #####################################################################################
   o2Process:cTo      := cDestinatario

   // ################################################################################################
   // Assunto do E-mail que Ira Receber a Notificacao de Aprovacao/Rejeicao do Processo de WorkFlow ##
   // ################################################################################################
   o2Process:cSubject := cAssunto

   // #############################################################################
   // Cria e Inicia o Processo de Envio de E-mail do WorkFlow de Ordem de Compra ##
   // #############################################################################
   o2Process:Start()

   // #######################
   // Finaliza o Processo  ##
   // #######################
   o2Process:Finish()

   // ###################################################################################################
   // Informa o Codigo e Descricao do Status do Processo Correspondente ao Inicio do Start de WorkFlow ##
   // ###################################################################################################
   cCodigoStatus := "100800"
   cDescricao := "Finalização do Processo de Ordem de Compras"

   // ####################################################################
   // Ratreabilidade com o Codigo do Status, Descricao e Usuario Logado ##
   // ####################################################################
   oProcess:Track( cCodigoStatus, cDescricao )
   CONOUT("NOTWFC01 -" + cCodigoStatus + " - " + cDescricao  )

Return Nil

