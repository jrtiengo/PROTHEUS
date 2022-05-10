#Include 'Totvs.ch'
#Include 'FWMVCDef.ch'

/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    | SCIA120 | Autor | Joao Mattos            | Data |02/04/2019|||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao | Manutencao da Solicitacao de Compra                        |||
|||           |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | U_SCIA120()                                                |||
|||-----------+------------------------------------------------------------|||
||| Parametros| Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
|||  Uso      | Especifico Cliente Sport Clube Internacional               |||
|||-----------+------------------------------------------------------------|||
|||                           ULTIMAS ALTERACOES                           |||
|||-------------+--------+-------------------------------------------------|||
||| Programador | Data   | Motivo da Alteracao                             |||
|||-------------+--------+-------------------------------------------------|||
|||             |        |                                                 |||
|||-------------+--------+-------------------------------------------------|||
|============================================================================|
|============================================================================|*/
User Function SCIA120()

	Local aArea        := GetArea()
	Local lReturn      := .T.
	Local oBrowse      := Nil

	Private cCadastro  := "Pós Pago"
	Private aRotina    := MenuDef() 
		
	Public cSCI_APR  := space( 06 )    //Codigo grupo de aprovacao
	Public cDesc_APR := space( 20 )   //Descricao Grupo de Aprovacao

    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("SC1")
    oBrowse:SetDescription(cCadastro)

	//Definicao da legenda
	oBrowse:AddLegend('C1_FLAGGCT == "1" .And. C1_QUJE < C1_QUANT','BR_MARROM',"SC Totalmente Atendida pelo SIGAGCT")
	oBrowse:AddLegend('C1_TIPO == 2','BR_BRANCO',"Solicitacao de Importacao")
	oBrowse:AddLegend('!Empty(C1_RESIDUO)','BR_PRETO',"SC Eliminada por Residuo")
	oBrowse:AddLegend('C1_QUJE == C1_QUANT','DISABLE',"SC com Pedido Colocado")
	oBrowse:AddLegend('C1_QUJE == 0 .And. C1_COTACAO == Space(Len(C1_COTACAO)) .And. C1_APROV $ " ,L"','ENABLE',"SC em Aberto")
	oBrowse:AddLegend('C1_QUJE == 0 .And. C1_COTACAO == Space(Len(C1_COTACAO)) .And. C1_APROV == "R"','BR_LARANJA',"SC Rejeitada")
	oBrowse:AddLegend('C1_QUJE == 0 .And. C1_COTACAO == Space(Len(C1_COTACAO)) .And. C1_APROV == "B"','BR_CINZA',"SC Bloqueada")
	oBrowse:AddLegend('C1_QUJE > 0','BR_AMARELO',"SC com Pedido Colocado Parcial")
	oBrowse:AddLegend('C1_TPSC != "2" .And. C1_QUJE == 0 .And. C1_COTACAO <> Space(Len(C1_COTACAO)) .And. C1_IMPORT <>"S"','BR_AZUL',"SC em Processo de Cotacao")

	/* extraido do mata110 - solic de compras
	aAdd(aCores,{'C1_FLAGGCT == "1" .And. C1_QUJE < C1_QUANT','BR_MARROM'}) //-- SC Totalmente Atendida pelo SIGAGCT
	aAdd(aCores,{'C1_TIPO == 2','BR_BRANCO'	}) //-- Solicitacao de Importacao	
	aAdd(aCores,{'!Empty(C1_RESIDUO)','BR_PRETO'})	//-- SC Eliminada por Residuo
	aAdd(aCores,{'C1_QUJE == C1_QUANT','DISABLE'})	//-- SC com Pedido Colocado
	aAdd(aCores,{'C1_QUJE == 0 .And. C1_COTACAO == Space(Len(C1_COTACAO)) .And. C1_APROV $ " ,L"','ENABLE'})	//SC em Aberto
	aAdd(aCores,{'C1_QUJE == 0 .And. C1_COTACAO == Space(Len(C1_COTACAO)) .And. C1_APROV == "R"','BR_LARANJA'})		//SC Rejeitada
	aAdd(aCores,{'C1_QUJE == 0 .And. C1_COTACAO == Space(Len(C1_COTACAO)) .And. C1_APROV == "B"','BR_CINZA'})		//SC Bloqueada
	aAdd(aCores,{'C1_QUJE > 0','BR_AMARELO'})	//SC com Pedido Colocado Parcial                                                   
	aAdd(aCores,{'C1_TPSC != "2" .And. C1_QUJE == 0 .And. C1_COTACAO <> Space(Len(C1_COTACAO)) .And. C1_IMPORT <>"S"','BR_AZUL'})	//SC em Processo de Cotacao
	*/		

    //oBrowse:SetFilterDefault( "C1_POSPAGO == '1'  .and. AllTrim(C1_SOLICIT) = '"+AllTrim(cUserName)+"' " )
    //Valdirene em 01.08.2019 - Alteracao regra ticket 585813
    //Se não for usuario autorizado a ver todos...
    If !RetCodUsr() $ GetMv("ES_FILPP")
	    oBrowse:SetFilterDefault( "C1_POSPAGO == '1'  .and. AllTrim(C1_SOLICIT) $ '"+AllTrim(cUserName)+"' " )
    Else
	    oBrowse:SetFilterDefault( "C1_POSPAGO == '1'   " )
    EndIf
    
    oBrowse:Activate()
     
    RestArea(aArea)

Return ( lReturn ) 

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |MenuDef   | Autor | Joao Mattos           | Data |02/04/2019|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Menu Def                                                   |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | MenuDef()                                                  |||
|||-----------+------------------------------------------------------------|||
||| Parametros| Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpA1 - Array contendo as rotinas deste programa           |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function MenuDef()

	Local aRotina := {}

	Aadd( aRotina,	{ "Pesquisar"	,	"AxPesqui" 	    	, 0, 1	})
	Aadd( aRotina,	{ "Visualizar"	,	"U_A120Manute(2)"	, 0, 2	})
	Aadd( aRotina,	{ "Incluir"		,	"U_A120Manute(3)"	, 0, 3	})
	Aadd( aRotina,	{ "Alterar"		,	"U_A120Manute(4)"	, 0, 4	})
	Aadd( aRotina,	{ "Excluir"		,	"U_A120Manute(5)"	, 0, 5	})
	Aadd( aRotina,	{ "Legenda"		,	"u_SCA120LEG"   	, 0, 6	})
	Aadd( aRotina,	{ "Conhecimento",	"u_SCA120bc()"      , 0, 4	}) //Ticket - 632568

Return ( aRotina )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |A120Manute| Autor | Joao Mattos           | Data |02/04/2019|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Manutencao da Solicitacao de Compra                        |||
|||------------------------------------------------------------------------|||
||| Sintaxe   | A120Manute()                                               |||
|||-----------+------------------------------------------------------------|||
||| Parametros| Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpO1 - Objeto modelo de dados                             |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
User Function A120Manute( nOpcao )

	Local aDimTop      := {}	// Array de dimensoes do topo
	Local aDimMid      := {}	// Array de dimensoes do meio
	Local oGrpTop      := Nil	// Grupo do Topo
	Local oGrpMid      := Nil	// Grupo do Meio
	Local nTop         := 0
	Local nLeft        := 0
	Local nBottom      := 0
	Local nRight       := 0
	Local bGravar      := Nil
	Local oSize        := Nil

	Private INCLUI     := .F.
	Private oDlg       := Nil

	//--< Cabecalho Solicitacao >--\\
	Private oNumSolici := Nil
	Private cNumSolici := SC1->C1_NUM
	Private oSolicitan := Nil
	Private cSolicitan := SC1->C1_SOLICIT
	Private oDtEmissao := Nil
	Private dDtEmissao := SC1->C1_EMISSAO
	Private cLinhaOk   := "u_A120LIOK()"	// Linha OK da getdados

	//--< Posicao dos Campos da GetDados >--\\
	Private nPosItSoli := 0
	Private nPosCodPro := 0
	Private nPosUMPro  := 0
	Private nPosDesPro := 0
	Private nPosQuanti := 0
	Private nPosCCusto := 0
	Private nPosObserv := 0
	Private nPosGruApr := 0
	Private nPosDesApr := 0

	//--< GetDados da tela Analitica >--\\
	Private aHeaSOLICI := A120AHEADE() // Montagem do aHeader
	Private aColSOLICI := {}
	Private oGetSOLICI := Nil

    cSCI_APR    := Posicione( "SAI", 2, xFilial( "SAI" ) + RetCodUsr(), "SAI->AI_GRUAPR" )
    cDesc_APR   := Posicione( "SAI", 2, xFilial( "SAI" ) + RetCodUsr(), "SAI->AI_DESCAPR" )


	If nOpcao == 3 .Or. nOpcao == 4 // Incluir ou Alterar 
	
		bGravar := {|| A120GRAVA(),oDlg:End()}
		
		If nOpcao == 4 // Alterar
		
			PRIVATE _INCLUI := .F.
			PRIVATE _ALTERA := .T.
		Else

			PRIVATE _INCLUI := .T.
			PRIVATE _ALTERA := .F.

			cNumSolici := CriaVar("C1_NUM")
			cSolicitan := cUserName
			dDtEmissao := dDataBase
		EndIf
	ElseIf nOpcao == 5 // Excluir
	
		bGravar := {|| A120EXCLUI(),oDlg:End()}
		
		PRIVATE _INCLUI := .F.
		PRIVATE _ALTERA := .F.
	Else // Outras
	
		bGravar := {|| oDlg:End()}

		PRIVATE _INCLUI := .F.
		PRIVATE _ALTERA := .F.
	EndIf

	//|===========================================|
	//| Calculo de dimensionamento da tela        |
	//|===========================================|
	oSize := FwDefSize():New(.T.)
	oSize:AddObject( "TOP"		,100, 10, .T., .T. ) // 15% do topo da tela
	oSize:AddObject( "MIDDLE"	,100, 90, .T., .T. ) // 85% do meio da tela
	oSize:lProp := .T.
	oSize:Process()	

	// Dimensoes das areas da tela
	aAdd( aDimTop, oSize:GetDimension("TOP","LININI") )
	aAdd( aDimTop, oSize:GetDimension("TOP","COLINI") )
	aAdd( aDimTop, oSize:GetDimension("TOP","LINEND") )
	aAdd( aDimTop, oSize:GetDimension("TOP","COLEND") )

	aAdd( aDimMid, oSize:GetDimension("MIDDLE","LININI") )
	aAdd( aDimMid, oSize:GetDimension("MIDDLE","COLINI") )
	aAdd( aDimMid, oSize:GetDimension("MIDDLE","LINEND") )
	aAdd( aDimMid, oSize:GetDimension("MIDDLE","COLEND") )

	// Dimensoes da tela
	nTop 	:= oSize:aWindSize[1]
	nLeft 	:= oSize:aWindSize[2]
	nBottom	:= oSize:aWindSize[3]
	nRight	:= oSize:aWindSize[4]

	oDlg := MSDialog():New(nTop,nLeft,nBottom,nRight,cCadastro,,,,,CLR_BLACK,CLR_WHITE,,,.T.)

	//>----- INICIO TOPO -----<	
	oGrpTop := TGroup():New( aDimTop[1],aDimTop[2],aDimTop[3],aDimTop[4],"",oDlg,,,.T. )

	@ aDimTop[1]+10,aDimTop[2]+010 Say OemToAnsi("Nro. Solicitação") OF oDlg PIXEL
	@ aDimTop[1]+06,aDimTop[2]+060 MSGET oNumSolici VAR cNumSolici Picture PesqPict("SC1","C1_NUM") VALID (A120NUMSOL(cNumSolici)) WHEN _INCLUI SIZE 60,10 OF oDlg PIXEL

	@ aDimTop[1]+10,aDimTop[2]+140 Say OemToAnsi("Solicitante") OF oDlg PIXEL
	@ aDimTop[1]+06,aDimTop[2]+190 MSGET oSolicitan VAR cSolicitan Picture PesqPict("SC1","C1_SOLICIT") VALID (.T.) WHEN _INCLUI SIZE 60,10 OF oDlg PIXEL

	@ aDimTop[1]+10,aDimTop[2]+270 Say OemToAnsi("Data de Emissão") OF oDlg PIXEL
	@ aDimTop[1]+06,aDimTop[2]+330 MSGET oDtEmissao VAR dDtEmissao Picture PesqPict("SC1","C1_SOLICIT") VALID (.T.) WHEN _INCLUI SIZE 60,10 OF oDlg PIXEL

	//>----- INICIO MEIO -----<	
	oGrpTop := TGroup():New( aDimMid[1],aDimMid[2],aDimMid[3],aDimMid[4],"",oDlg,,,.T. )

	oGetSOLICI := MsNewGetDados():New(	aDimMid[1]+10,;		// 01 - nTop - Numérico	Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contém.
										aDimMid[2]+04,;		// 02 - nLeft - Numérico	Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contém.
										aDimMid[3]-03,;		// 03 - nBottom - Numérico	Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contém.
										aDimMid[4]-04,;		// 04 - nRight - Numérico	Distancia entre a MsNewGetDados e o extremidade direita do objeto que a contém.
										GD_INSERT + GD_UPDATE + GD_DELETE,;	// 05 - nStyle - Numérico	Essa nova propriedade, passada via parâmetro, substitui a passagem das variáveis nOpc. Pode ser utilizada GD_INSERT + GD_UPDATE + GD_DELETE para criar a flexibilidade da MsNewGetdados.
										cLinhaOk,;			// 06 - cLinhaOk - Caracter	Função executada para validar o contexto da linha atual do aCols. 
										/*inicpos*/,;		// 07 - cTudoOk - Caracter	Função executada para validar o contexto geral da MsNewGetDados (todo aCols).
										"++_C1_ITEM",;		// 08 - cIniCpos - Caracter	Nome dos campos do tipo caracter que utilizarão incremento automático. Este parametro deve ser no formato “+++...”.
										Nil,;				// 09 - aAlter - Array of Record	Vetor com os campos que poderão ser alterados.
										0/*freeze*/,;		// 10 - nFreeze - Numérico	Congela a coluna da esquerda para a direita. Se 0 não congela, se 1 congela a primeira coluna. Obs: atualmente só é possivel congelar a primeira coluna, devido a limitação do objeto.
										999999999,;			// 11 - nMax - Numérico	Número máximo de linhas permitidas. Valor padrão 99.
										Nil,;				// 12 - cFieldOk - Caracter	Função executada na validação do campo.
										/*superdel*/,;		// 13 - cSuperDel - Caracter	Função executada quando pressionada as teclas +.
										/*delok*/,;			// 14 - cDelOk - Caracter	Função executada para validar a exclusão de uma linha do aCols.
										oDlg,;				// 15 - oWnd - Objeto	Objeto no qual a MsGetDados será criada.
										aHeaSOLICI,;		// 16 - aPartHeader - Array of Record	aHeader
										aColSOLICI,;		// 17 - aParCols Array of Record	Acols 
										Nil,;				// 18 - uChange - Bloco de código	Bloco de execução a ser executado na propriedade bChange do Objeto. 
										Nil;				// 19 - cTela	Caracter	String contendo os campos contidos no X3_TELA.  
									)
	
	IIf(!_INCLUI, A120CARGA(),.T.) // Carga do aCols
	
	oDlg:Activate(,,,.T.,,,EnchoiceBar(oDlg,bGravar,{||oDlg:End()}))

Return ( Nil )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |A120AHEADE| Autor | Joao Mattos           | Data |02/04/2019|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Montagem do aHeader                                        |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | A120AHEADE()                                               |||
|||-----------+------------------------------------------------------------|||
||| Parametros| Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpA1 - Array com dados do aHeader                         |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function A120AHEADE()

	Local aReturn  := {}

	//|==================================================|
	//| Montagem da Solicitacao de Compra                |
	//|==================================================|
	Aadd ( aReturn, A120ADDSX3("C1_ITEM") )
	aReturn[Len(aReturn)][02] := "_C1_ITEM"
	aReturn[Len(aReturn)][06] := ".F."
	nPosItSoli := Len(aReturn)
	
	Aadd ( aReturn, A120ADDSX3("C1_PRODUTO") )
	aReturn[Len(aReturn)][02] := "_C1_PRODUT"
	aReturn[Len(aReturn)][06] := ".T. .and. EXISTCPO('SB1') .AND. U_A120PROD(M->_C1_PRODUT) .and. A093Prod() .And. MTPVLSOLPD()"
	aReturn[Len(aReturn)][09] := "SB1PPG"
	nPosCodPro := Len(aReturn)

	Aadd ( aReturn, A120ADDSX3("C1_UM") )
	aReturn[Len(aReturn)][02] := "_C1_UM"
	aReturn[Len(aReturn)][06] := ".F."
	nPosUMPro := Len(aReturn)

	Aadd ( aReturn, A120ADDSX3("C1_DESCRI") )
	aReturn[Len(aReturn)][02] := "_C1_DESCRI"
	aReturn[Len(aReturn)][06] := ".T."
	nPosDesPro := Len(aReturn)

	Aadd ( aReturn, A120ADDSX3("C1_QUANT") )
	aReturn[Len(aReturn)][02] := "_C1_QUANT"
	aReturn[Len(aReturn)][06] := ".T."
	nPosQuanti := Len(aReturn)
	
	Aadd ( aReturn, A120ADDSX3("C1_CC") )
	aReturn[Len(aReturn)][02] := "_C1_CC"
	aReturn[Len(aReturn)][06] := "NAOVAZIO()"
	nPosCCusto := Len(aReturn)
	
	Aadd ( aReturn, A120ADDSX3("C1_OBS") )
	aReturn[Len(aReturn)][02] := "_C1_OBS"
	aReturn[Len(aReturn)][06] := ".T."
	nPosObserv := Len(aReturn)

	//Tarasconi em 23/02/2021 - adicao do grupo de aprovacao para escolha...
	//C1_GRUAPR 
	Aadd ( aReturn, A120ADDSX3("C1_GRUAPR") )
	aReturn[Len(aReturn)][02] := "_C1_GRUAPR"
	aReturn[Len(aReturn)][06] := ".T."
	nPosGruApr := Len(aReturn)

	//C1_DESCAPR
	Aadd ( aReturn, A120ADDSX3("C1_DESCAPR") )
	aReturn[Len(aReturn)][02] := "_C1_DESCAPR
	aReturn[Len(aReturn)][06] := ".T."
	nPosDesApr := Len(aReturn)
	
Return ( aReturn )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |A120ADDSX3| Autor | Joao Mattos           | Data |02/04/2019|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Adciona campo do SX3                                       |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | A120ADDSX3()                                               |||
|||-----------+------------------------------------------------------------|||
||| Parametros| ExpC1 = Campo                                              |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpA1 - Array com dados do SX3                             |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function A120ADDSX3( cCampo )

	Local aReturn  := {}
	//Local aAreaSX3 := SX3->(GetArea())

	//dbSelectArea("SX3")	// Dicionario de Dados
	OpenSxs(,,,,,"SX3TRB","SX3",,.F.)
	If Select("SX3TRB") > 0
		
		dbSelectArea('SX3TRB')
		SX3TRB->( dbSetOrder( 2 ) ) //ORDENA POR CAMPO
		SX3TRB->( dbGoTop(  ) )
		SX3TRB->( dbSeek(cCampo) )
		
		AADD ( aReturn,	SX3TRB->&('X3_TITULO')  )				// 01-Titulo
		AADD ( aReturn,	SX3TRB->&('X3_CAMPO')   )				// 02-Campo
		AADD ( aReturn,	SX3TRB->&('X3_PICTURE') )				// 03-Picture
		AADD ( aReturn,	SX3TRB->&('X3_TAMANHO') )				// 04-Tamanho
		AADD ( aReturn,	SX3TRB->&('X3_DECIMAL') )				// 05-Decimal
		AADD ( aReturn,	SX3TRB->&('X3_VALID') 	)				// 06-Validacao
		AADD ( aReturn,	""              )				// 07-Usado							
		AADD ( aReturn,	SX3TRB->&('X3_TIPO')    )				// 08-Tipo
		AADD ( aReturn,	SX3TRB->&('X3_F3')      )				// 09-F3
		AADD ( aReturn,	""              )				// 10-Contexto
		AADD ( aReturn,	""              )				// 11-ComboBox
		AADD ( aReturn,	""              )				// 12-Relacao
					
		SX3TRB->( DbCloseArea() )
	EndIf

	//RestArea( aAreaSX3 )

Return ( aReturn )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |A120PROD  | Autor | Joao Mattos           | Data |03/04/2019|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Preenchimento Automatico de campos relativos ao codigo do  |||
|||           | Produto                                                    |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | A120PROD()                                                 |||
|||-----------+------------------------------------------------------------|||
||| Parametros| ExpC1 = Codigo do Produto                                  |||
|||           | ExpL2 = Indica se funcao eh executada pelo MATA110         |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpL1 = Verdadeiro ou Falso                                |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
User Function A120PROD( _cProduto, l_MATA110 )

	Local lReturn   := .T.
	Local cProblema := ""
	Local aSolucao  := {}
	Local nPosDes   := 0
	Local nPosUM    := 0
	
	Default l_MATA110 := .F.
	
	SB1->( dbSetOrder(1) )
	SB1->( MsSeek( xFilial("SB1") + _cProduto ))
	If l_MATA110 
		
		If AllTrim(FunName()) == "MATA110"
		
			If SB1->B1_GRUPO == "0028"
			
				nPosDes := AScan( aHeader, { |x| Alltrim(x[2]) == 'C1_DESCRI'	})
				nPosUM  := AScan( aHeader, { |x| Alltrim(x[2]) == 'C1_UM'		})
				aCols[n][nPosDes] := ""
				aCols[n][nPosUM]  := ""
	
				cProblema := "Produto pertence ao Grupo '0028' - Pos Pago. " + Funname()
				aSolucao  := {}
				AADD ( aSolucao, "Informe um produto com grupo de produto diferente de '0028' - Pos Pago." )
				Help( Nil, Nil, "SCIA120_07", Nil, cProblema, 1, 0, Nil, Nil, Nil, Nil, Nil, aSolucao ) 	
				lReturn := .F.
			EndIf
		EndIf
	Else

		If SB1->B1_GRUPO <> "0028"

			cProblema := "Produtos não pertence ao Grupo '0028' - Pos Pago."
			aSolucao  := {}
			AADD ( aSolucao, "Informe um produto com grupo de produto igual a '0028' - Pos Pago." )
			Help( Nil, Nil, FunName()+"_01", Nil, cProblema, 1, 0, Nil, Nil, Nil, Nil, Nil, aSolucao ) 	
			lReturn := .F.

			oGetSOLICI:aCols[oGetSOLICI:nAt][nPosDesPro] := ""
			oGetSOLICI:aCols[oGetSOLICI:nAt][nPosUMPro]  := ""
		Else

			oGetSOLICI:aCols[oGetSOLICI:nAt][nPosDesPro] := SB1->B1_DESC
			oGetSOLICI:aCols[oGetSOLICI:nAt][nPosUMPro]  := SB1->B1_UM
		EndIf

		oGetSOLICI:oBrowse:Refresh(.T.)
		oGetSOLICI:Refresh()
	EndIf

Return ( lReturn )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |A120NUMSOL| Autor | Joao Mattos           | Data |02/04/2019|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Validacao do Numero da Solicitacao                         |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | A120NUMSOL(cNumSolici)                                     |||
|||-----------+------------------------------------------------------------|||
||| Parametros| ExpC1 - Numero da Solicitacao                              |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpL1 - Verdadeiro ou Falso                                |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function A120NUMSOL(_cNumSolici)

	Local aArea     := GetArea()
	Local aAreaSC1  := SC1->( GetArea())
	Local lReturn   := .T.
	Local cProblema := ""
	Local aSolucao  := {}

	SC1->( dbSetOrder(1) )	// C1_FILIAL + C1_NUM + C1_ITEM + C1_ITEMGRD
	If SC1->( MsSeek( xFilial("SC1") + _cNumSolici ))
	
		cProblema := "Solicitação de Compra já Cadastrada!"
		aSolucao  := {}
		AADD ( aSolucao, "Informe um número de solicitação válido." )
		Help( Nil, Nil, FunName()+"_01", Nil, cProblema, 1, 0, Nil, Nil, Nil, Nil, Nil, aSolucao ) 	
		lReturn := .F.
	EndIf

	RestArea( aAreaSC1 )
	RestArea( aArea )

Return ( lReturn )


/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |A120CARGA | Autor | Joao Mattos           | Data |03/04/2019|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Carga do Acols                                             |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | A120CARGA()                                                |||
|||-----------+------------------------------------------------------------|||
||| Parametros| Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | Nenhum                                                     |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function A120CARGA()

	Local aArea    := GetArea()
	Local aAreaSC1 := SC1->( GetArea())
	Local nLinha   := 0

	oGetSOLICI:aCols := {}
	
	dbSelectArea("SC1")	// Solicitacao de Compra
	dbSetOrder(1)		// C1_FILIAL + C1_NUM + C1_ITEM + C1_ITEMGRD 
	If MsSeek( xFilial("SC1") + cNumSolici )

		While !Eof() .and. C1_FILIAL == xFilial("SC1") .and. C1_NUM == cNumSolici
		
			Aadd( oGetSOLICI:aCols, Array(Len(aHeaSOLICI)+1) )
			nLinha := Len(oGetSOLICI:aCols)

			oGetSOLICI:aCols[nLinha][nPosItSoli] := SC1->C1_ITEM
			oGetSOLICI:aCols[nLinha][nPosCodPro] := SC1->C1_PRODUTO
			oGetSOLICI:aCols[nLinha][nPosUMPro]  := SC1->C1_UM
			oGetSOLICI:aCols[nLinha][nPosDesPro] := SC1->C1_DESCRI
			oGetSOLICI:aCols[nLinha][nPosQuanti] := SC1->C1_QUANT
			oGetSOLICI:aCols[nLinha][nPosCCusto] := SC1->C1_CC
			oGetSOLICI:aCols[nLinha][nPosObserv] := SC1->C1_OBS
			oGetSOLICI:aCols[nLinha][nPosGruApr] := SC1->C1_GRUAPR
			oGetSOLICI:aCols[nLinha][nPosDesApr] := SC1->C1_DESCAPR
						
			dbSelectArea("SC1")
			dbSkip()
		EndDo
	EndIf

	oGetSOLICI:oBrowse:Refresh(.T.)
	oGetSOLICI:Refresh()

	RestArea( aAreaSC1 )
	RestArea( aArea )

Return ( Nil )
	
/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |A120GRAVA | Autor | Joao Mattos           | Data |03/04/2019|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Validacao do Numero da Solicitacao                         |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | A120GRAVA()                                                |||
|||-----------+------------------------------------------------------------|||
||| Parametros| ExpC1 - Numero da Solicitacao                              |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpL1 - Verdadeiro ou Falso                                |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function A120GRAVA()

	Local lReturn   := .T.
	Local aCab      := {}
	Local aItem     := {}
	Local aLinha    := {}
	Local nSaveSX8  := GetSX8Len()
	Local nJ        := 0
	Local cProblema := ""
	Local aSolucao  := {}
	Local nPosDelet := Len(aHeaSOLICI)+1

	PRIVATE lMsErroAuto	:= .F. //Determina se houve algum tipo de erro durante a execucao do ExecAuto
	PRIVATE N:=0
	
	If !_INCLUI
	
		// Verificar se pode alterar
		For nJ := 1 to Len(oGetSOLICI:aCols)
		
			dbSelectArea("SC1")
			dbSetOrder(1)	// C1_FILIAL + C1_NUM + C1_ITEM + C1_ITEMGRD
			If MsSeek(xFilial("SC1") + cNumSolici + oGetSOLICI:aCols[nJ][nPosItSoli] )

				If !Empty(oGetSOLICI:aCols[nJ][nPosCodPro]) .and. !oGetSOLICI:aCols[nJ][nPosDelet]
				
					If (SC1->C1_QUJE > 0 .and. SC1->C1_QUANT <> oGetSOLICI:aCols[nJ][nPosQuanti]) .Or. (SC1->C1_QUJE > 0 .and. SC1->C1_PRODUTO <> oGetSOLICI:aCols[nJ][nPosCodPro])
					
						cProblema := "Item desta solicitação já foi entregue, não poderá ser alterado!"
						aSolucao  := {}
						AADD ( aSolucao, "" )
						Help( Nil, Nil, FunName()+"_05", Nil, cProblema, 1, 0, Nil, Nil, Nil, Nil, Nil, aSolucao ) 	
						lReturn := .F.
						Exit
					EndIf
				EndIf
			EndIf
		Next nJ

		If lReturn
		
			lReturn := A120EXCLUI(4)
		EndIf
	EndIf

	If lReturn

		Begin Transaction

			aCab  := {}                  
			aItem := {}
			
			
			Aadd( aCab, { "C1_NUM",		cNumSolici      ,	Nil	})
			Aadd( aCab, { "C1_EMISSA",	dDtEmissao      ,	Nil	})
			aAdd( aCab,	{ "C1_DATPRF", 	dDtEmissao      ,   Nil })
			Aadd( aCab, { "C1_SOLICIT",	cSolicitan      ,   Nil	})
				
			For nJ := 1 to Len(oGetSOLICI:aCols)
		
				If !Empty(oGetSOLICI:aCols[nJ][nPosCodPro]) .and. !oGetSOLICI:aCols[nJ][nPosDelet]
				
					aLinha := {}
					Aadd( aLinha, { "C1_ITEM",		oGetSOLICI:aCols[nJ][nPosItSoli],	Nil	})
					Aadd( aLinha, { "C1_PRODUTO",	oGetSOLICI:aCols[nJ][nPosCodPro],	Nil	})
					Aadd( aLinha, { "C1_QUANT",		oGetSOLICI:aCols[nJ][nPosQuanti],	Nil	})
					Aadd( aLinha, { "C1_UM",		oGetSOLICI:aCols[nJ][nPosUMPro],	Nil	})
					Aadd( aLinha, { "C1_DESCRI",	oGetSOLICI:aCols[nJ][nPosDesPro],	Nil	})
					Aadd( aLinha, { "C1_CC",		oGetSOLICI:aCols[nJ][nPosCCusto],	Nil	})
					Aadd( aLinha, { "C1_OBS",		oGetSOLICI:aCols[nJ][nPosObserv],	Nil	})
					Aadd( aLinha, { "C1_POSPAGO",	"1",								Nil	})

					//tarasconi em 23/02/2021 adicao grupo de aprovacao no pos pago para escolha do usuario
					If cSCI_APR <> oGetSOLICI:aCols[nJ][nPosGruApr] .and. !Empty(oGetSOLICI:aCols[nJ][nPosGruApr])
						Aadd( aLinha, { "C1_GRUAPR",	oGetSOLICI:aCols[nJ][nPosGruApr],	Nil	})
						Aadd( aLinha, { "C1_DESCAPR",	oGetSOLICI:aCols[nJ][nPosDesApr],	Nil	})
					Else
						Aadd( aLinha, { "C1_GRUAPR",	cSCI_APR,	Nil	})
						Aadd( aLinha, { "C1_DESCAPR",	cDesc_APR,	Nil	})
					EndIf
		
					Aadd( aItem, aLinha)
				EndIf
			Next nJ
		
			If Len(aItem) > 0
			
				MSExecAuto( {|x,y| MATA110(x,y)}, aCab, aItem, 3 )
				IF ! lMSErroAuto
		
					While ( GetSX8Len() > nSaveSX8 )
		
						ConfirmSX8()
					EndDo
				Else
		
					While ( GetSX8Len() > nSaveSX8 )
		
						RollBackSx8()
					EndDo
					MostraErro()
					DisarmTransaction()
				EndIF
			Else
			
				cProblema := "Solicitação de Compra não será gravada!"
				aSolucao  := {}
				AADD ( aSolucao, "Informe pelo menos um item." )
				Help( Nil, Nil, FunName()+"_02", Nil, cProblema, 1, 0, Nil, Nil, Nil, Nil, Nil, aSolucao ) 	
				lReturn := .F.
			EndIf
		End Transaction
	EndIf

Return ( lReturn )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |A120EXCLUI| Autor | Joao Mattos           | Data |03/04/2019|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Validacao do Numero da Solicitacao                         |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | A120EXCLUI(cNumSolici)                                     |||
|||-----------+------------------------------------------------------------|||
||| Parametros| ExpC1 - Numero da Solicitacao                              |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpL1 - Verdadeiro ou Falso                                |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function A120EXCLUI(nOpcao)

	Local lReturn   := .T.
	Local aCab      := {}
	Local aItem     := {}
	Local nJ        := 0
	Local cProblema := ""
	Local aSolucao  := {}
	Local nPosDelet := Len(aHeaSOLICI)+1
	Local aArea     := GetArea()
	Local aAreaSC1  := SC1->( GetArea())

	PRIVATE lMsErroAuto	:= .F. //Determina se houve algum tipo de erro durante a execucao do ExecAuto

	Default nOpcao := 0
	
	// Verificar se pode excluir itens
	For nJ := 1 to Len(oGetSOLICI:aCols)
	
		dbSelectArea("SC1")
		dbSetOrder(1)	// C1_FILIAL + C1_NUM + C1_ITEM + C1_ITEMGRD
		If MsSeek(xFilial("SC1") + cNumSolici + oGetSOLICI:aCols[nJ][nPosItSoli] )

			If !Empty(oGetSOLICI:aCols[nJ][nPosCodPro]) .and. oGetSOLICI:aCols[nJ][nPosDelet]

				If SC1->C1_QUJE > 0
				
					If nOpcao == 4
					
						cProblema := "Item desta solicitação já foi entregue, não poderá ser alterada!"
					Else
					
						cProblema := "Item desta solicitação já foi entregue, não poderá ser excluido!"
					EndIf
					aSolucao  := {}
					AADD ( aSolucao, "" )
					Help( Nil, Nil, FunName()+"_04", Nil, cProblema, 1, 0, Nil, Nil, Nil, Nil, Nil, aSolucao ) 	
					lReturn := .F.
					Exit
				EndIf
			ElseIf !Empty(oGetSOLICI:aCols[nJ][nPosCodPro])

				If SC1->C1_QUJE > 0
				
					If nOpcao == 4
					
						cProblema := "Item desta solicitação já foi entregue. Esta solicitação não poderá ser alterada!"
					Else
					
						cProblema := "Item desta solicitação já foi entregue. Esta solicitação não poderá ser excluida!"
					EndIf

					aSolucao  := {}
					AADD ( aSolucao, "" )
					Help( Nil, Nil, FunName()+"_06", Nil, cProblema, 1, 0, Nil, Nil, Nil, Nil, Nil, aSolucao ) 	
					lReturn := .F.
					Exit
				EndIf
			EndIf
		EndIf
	Next nJ

	If lReturn

		Begin Transaction

			dbSelectArea("SC1")
			dbSetOrder(1)	// C1_FILIAL + C1_NUM + C1_ITEM + C1_ITEMGRD
			If MsSeek(xFilial("SC1") + cNumSolici )
	
				Aadd(aCab ,{"C1_NUM"	, SC1->C1_NUM,	Nil})
				Aadd(aItem,{{"C1_NUM"	, SC1->C1_NUM,	Nil}})
				
				MSExecAuto({|x,y,z| MATA110(x,y,z)},aCab,aItem,5)		
				//+---------------------------------------------------------------------+
				//| Verifica se houveram erros durante a execucao da rotina automatica. |
				//+---------------------------------------------------------------------+
				If lMsErroAuto
			
					DisarmTransaction()
					MostraErro()
					lReturn := .F.
				Endif
			EndIf
		End Transaction
	EndIf 

	RestArea(aAreaSC1)
	RestArea(aArea)

Return ( lReturn )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |A120LIOK  | Autor | Joao Mattos           | Data |03/04/2019|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao | Validacao da linha da getdados                             |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | U_A120LIOK()                                               |||
|||-----------+------------------------------------------------------------|||
||| Parametros| ExpC1 - Numero da Solicitacao                              |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpL1 - Verdadeiro ou Falso                                |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
User Function A120LIOK()

	Local lReturn   := .T.
	Local nPosDelet := Len(aHeaSOLICI)+1
	Local cProblema := ""
	Local aSolucao  := {}
	Local nLinhaAtu := oGetSOLICI:nAt

	If !oGetSOLICI:aCols[nLinhaAtu][nPosDelet]
	
		If !Empty(oGetSOLICI:aCols[nLinhaAtu][nPosCodPro])

			If Empty(oGetSOLICI:aCols[nLinhaAtu][nPosQuanti])
			
				cProblema := "Obrigatório a digitação da quantidade!"
				aSolucao  := {}
				AADD ( aSolucao, "" )
				Help( Nil, Nil, FunName()+"_03", Nil, cProblema, 1, 0, Nil, Nil, Nil, Nil, Nil, aSolucao ) 	
				lReturn := .F.
			EndIf

			If Empty(oGetSOLICI:aCols[nLinhaAtu][nPosCCusto])
			
				cProblema := "Obrigatório a digitação do Centro de Custo!"
				aSolucao  := {}
				AADD ( aSolucao, "" )
				Help( Nil, Nil, FunName()+"_07", Nil, cProblema, 1, 0, Nil, Nil, Nil, Nil, Nil, aSolucao ) 	
				lReturn := .F.
			EndIf
		EndIf
	EndIf
Return ( lReturn )

********************************************************************************************************************************************
********************************************************************************************************************************************
********************************************************************************************************************************************
User Function SCA120LEG()

/*
	oBrowse:AddLegend('C1_FLAGGCT == "1" .And. C1_QUJE < C1_QUANT','BR_MARROM',"SC Totalmente Atendida pelo SIGAGCT")
	oBrowse:AddLegend('C1_TIPO == 2','BR_BRANCO',"Solicitacao de Importacao")
	oBrowse:AddLegend('!Empty(C1_RESIDUO)','BR_PRETO',"SC Eliminada por Residuo")
	oBrowse:AddLegend('C1_QUJE == C1_QUANT','DISABLE',"SC com Pedido Colocado")
	oBrowse:AddLegend('C1_QUJE == 0 .And. C1_COTACAO == Space(Len(C1_COTACAO)) .And. C1_APROV $ " ,L"','ENABLE',"SC em Aberto")
	oBrowse:AddLegend('C1_QUJE == 0 .And. C1_COTACAO == Space(Len(C1_COTACAO)) .And. C1_APROV == "R"','BR_LARANJA',"SC Rejeitada")
	oBrowse:AddLegend('C1_QUJE == 0 .And. C1_COTACAO == Space(Len(C1_COTACAO)) .And. C1_APROV == "B"','BR_CINZA',"SC Bloqueada")
	oBrowse:AddLegend('C1_QUJE > 0','BR_AMARELO',"SC com Pedido Colocado Parcial")
	oBrowse:AddLegend('C1_TPSC != "2" .And. C1_QUJE == 0 .And. C1_COTACAO <> Space(Len(C1_COTACAO)) .And. C1_IMPORT <>"S"','BR_AZUL',"SC em Processo de Cotacao")
*/

BrwLegenda(cCadastro,"Legendas", 	{{"BR_MARROM" 		,"SC Totalmente Atendida pelo SIGAGCT"		},;
   								     {"BR_BRANCO"   	,"Solicitacao de Importacao"				},;
   									 {"BR_PRETO" 		,"SC Eliminada por Residuo"	   				},;
   									 {"DISABLE" 		,"SC com Pedido Colocado"	   				},;
   									 {"ENABLE" 			,"SC em Aberto"	   			  				},;
   									 {"BR_LARANJA" 		,"SC Rejeitada"	   							},;
   									 {"BR_CINZA" 		,"SC Bloqueada"	   							},;
   									 {"BR_AMARELO" 		,"SC com Pedido Colocado Parcial"   		},;
   									 {"BR_AZUL" 		,"SC em Processo de Cotacao"	   			}})
Return ( Nil )
                                                      

********************************************************************************************************************************************
********************************************************************************************************************************************
********************************************************************************************************************************************
User Function SCA120BC()

MsDocument('SC1',SC1->(RecNo()), 4)

Return()