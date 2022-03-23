#INCLUDE "TopConn.ch"
#INCLUDE 'tbiconn.ch'
#INCLUDE "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MARWF002 ºAutor  ³MarcioQuevedoBorges º Data ³  11/10/2018  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Schedule para Workflow de Email para Fornecedores de email iº±±
±±º          ³ folow-up de Compras                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Workflow - Email de Aviso Compradores - Fornecedor sem folow±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MARWF002(aParam)

	Private lViaSchedule
	Private cRotina   := "MARWF002"

	IF Type("dDatabase") == "U" // Se rodado via workflow a variável dDatabase estara disponivel somente apos o Prepare Environment
		lViaSchedule := .T.
	ELSE
		lViaSchedule := .F.
	ENDIF

	CONOUT(cRotina + " - Variével lViaSchedule :")
	CONOUT(lViaSchedule)


	IF lViaSchedule
		cEmp := aParam[01]
		cFil := aParam[02]
		//cUser:= aParam[03]

		conout( cRotina + " -  VIA Schedule - Preparando Environment")
		WFPrepEnv(cEmp,cFil,cRotina)	
	ELSE
		Conout( cRotina + " -  VIA MENU    - Preparando Environment ")
	ENDIF

	// Roda Rotina de Compras 
	RODA()


	IF lViaSchedule
		Conout( cRotina + " -  VIA SCHEDULE    -  Job executado com sucesso.. FINALIZANDO ENVIRONMENT ")
		Reset Environment
	ELSE
		Conout( cRotina + " -  VIA MENU -  Job executado com sucesso.. FINALIZANDO ENVIRONMENT ")
	ENDIF

Return

Static Function Roda()                

	Local _cProdAmb		:= SuperGetMV("MV_AMBPROD",,"PRODUCAO") // Ambientes para considerar como producao
	Local cDestinatario := SuperGetMV("MA_EMLCOM",,"compras@marcher.com.br")
	Local dDtRef 		:= dDatabase
	Local x:=1
                                                                                         
	Private nDiasSRT 	:= SuperGetMV("MA_DFLWF",,3) - 1 //Dias Folow-up PC x Fornecedores - 1 -- [1 dia após o dia do Follow-up]
	
    dDtRef += nDiasSRT 

	FOR x:= 1 to nDiasSRT
		dDtRef := DataValida(dDtRef+1)
	Next x

	// ####################
	// Assunto do E-mail ##
	// ####################
	cAssunto := "Folow-Up de Ordens de Compra SEM RETORNO - Data Entrega: " + DTOC(dDtRef)

	// Se não for ambientes de producao, adiciona mensagem de teste no assunto
	If !(UPPER(Alltrim(GetEnvServer())) $ UPPER(_cProdAmb ))
		cAssunto := "TESTE - FAVOR DESCONSIDERAR: " + cAssunto
	Endif
	// ####################################################################
	// Caminho e Arquivo HTML do Link de Formulario de Cotação de Preços ##
	// ####################################################################
	cArqHtml := "\Workflow\WFSC7AvisoSemRetorno.html"

	// #####################################################
	// Inicia o Processo de WorkFlow de Cotação de Preços ##
	// #####################################################
	o2Process := TWFProcess():New( "FLWCOM", cAssunto )

	// #########################################################
	// Cria uma Nova Tarefa Informando o HTML do Link de Envio ##
	// ##########################################################
	o2Process:NewTask( "Retorno de Ordem de Compra", cArqHtml )

	// ################################################################
	// Cria Objeto HTML do Processo de WorkFlow                      ##
	// ################################################################
	oHtml := o2Process:oHTML


	//Pesquisa Pedidos que foram enviados WF e não foram respondidos.
	cSql := ""
	cSql += "SELECT C7_FORNECE,"
	cSql += "       C7_LOJA   ,"
	cSql += "       A2_NOME   ,"
	cSql += "       C7_FILIAL ,"
	cSql += "       C7_NUM    ,"
	cSql += "       C7_ITEM   ,"
	cSql += "       C7_PRODUTO,"
	cSql += "       C7_DESCRI ,"
	cSql += "       C7_UM     ,"
	cSql += "       C7_QUANT  ,"
	cSql += "      (C7_QUANT - C7_QUJE) AS QUANTIDADE," 
	cSql += "       C7_DTFOLOW,"
	cSql += "       C7_DATPRF ,"
	cSql += "       C7_WFID   ,"
	cSql += "       C7.R_E_C_N_O_ NRECNO "
	cSql += "  FROM " + RetSqlName("SC7") + " C7 INNER JOIN 	" + RetSqlName("SA2") + " A2 " 
	cSql += "    ON C7_FORNECE = A2_COD AND C7_LOJA = A2_LOJA AND A2.A2_FILIAL = '"+ FWxFilial("SA2")+"' AND A2.D_E_L_E_T_ = ' '" 
	cSql += " WHERE C7_FILIAL >= '" + FWxFilial("SC7")+ "' 
	cSql += "   AND C7.D_E_L_E_T_ <> '*' 
	cSql += "   AND CASE WHEN C7_DTFOLOW = ' ' THEN C7_DATPRF ELSE C7_DTFOLOW END = '"+ DTOS(dDtRef)+"'   
	cSql += "   AND C7_YDTPRFO = '        '   
	cSql += "   AND C7_WFID <> '  ' "
	cSql += "ORDER BY C7_FORNECE,C7_LOJA "

	MyQuery(cSql,"TMPFOR")

	While ( TMPFOR->(!Eof()) )

		cForn := TMPFOR->C7_FORNECE
		cLoja := TMPFOR->C7_LOJA
		//cNome := TMPFOR->A2_NOME

		aAdd( (oHtml:ValByName( "it.Fornecedor"  ))		, cForn +"/"+cLoja  )
		aAdd( (oHtml:ValByName( "it.Nome"  ))		, TMPFOR->A2_NOME  )
		aAdd( (oHtml:ValByName( "it.Pedido"  ))		, TMPFOR->C7_NUM  )
		aAdd( (oHtml:ValByName( "it.Item"  ))		, TMPFOR->C7_ITEM  )
		aAdd( (oHtml:ValByName( "it.Codigo"  ))		, TMPFOR->C7_PRODUTO  )
		aAdd( (oHtml:ValByName( "it.Unid"  ))		, TMPFOR->C7_UM  )
		aAdd( (oHtml:ValByName( "it.Descricao"  ))	, TMPFOR->C7_DESCRI  )
		aAdd( (oHtml:ValByName( "it.Qtd"  ))		, TRANSFORM( TMPFOR->QUANTIDADE,'@E 99,999.99' )  )


		TMPFOR->(DBSkip())
	Enddo




	// ####################################################
	// Carrega a Data de Referência para display no HTML ##
	// ####################################################
	o2Process:oHTML:ValByName("Dt_Entrega", DTOC(dDtRef))




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

Return
//####################################
//## Consulta SQL ao banco de dados ##
//####################################
Static Function MyQuery( cQuery , cursor )

	IF SELECT( cursor ) <> 0
		dbSelectArea(cursor)
		DbCloseArea()
	Endif

	TCQUERY cQuery NEW ALIAS (cursor)

Return

