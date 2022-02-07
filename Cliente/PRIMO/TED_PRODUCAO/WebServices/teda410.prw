#Include "TOTVS.CH"
#Include "RESTFUL.CH"

//Opcoes ExecAuto 
#Define PD_INCLUIR 3
#Define PD_ALTERAR 4
#Define PD_EXCLUIR 5

/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    | TEDA410 | Autor | Manoel Mariante        | Data |01/11/2019|||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao | Servico Web service para manutenï¿½ï¿½o do cadastro de     |||
|||           | DO PEDIDO DE VNDA - MATA410 -                              |||
|||-----------+------------------------------------------------------------|||
|||  Uso      | Especifico Primo Tedesco                                   |||
|||-----------+------------------------------------------------------------|||
|||                           ULTIMAS ALTERACOES                           |||
|||-------------+--------+-------------------------------------------------|||
||| Programador | Data   | Motivo da Alteracao                             |||
|||-------------+--------+-------------------------------------------------|||
|||Joao Mattos  |27/01/20| Incluido os campos C6_TES e C6_COMIS1           |||
|||Joao Mattos  |04/02/20| Na alteracao do Pedido de Venda pesquisar pelo  |||
|||             |        | campo da InfoBox C5_PVINFOB e nao pelo C5_NUM   |||
|||MarcioBorges |19/08/20| Ajuste de Logs e Erros, tratamento para o Padrão|||
|||-------------+--------+-------------------------------------------------|||
|============================================================================|
|============================================================================|
*/

WSRESTFUL TEDA410 DESCRIPTION "Pedido de Venda"

	WSDATA C5_NUM AS STRING
	WSDATA C5_TIPO AS STRING
	WSDATA C5_CLIENTE AS STRING
	WSDATA C5_LOJACLI AS STRING
	WSDATA C5_CLIENT AS STRING
	WSDATA C5_LOJAENT AS STRING
	WSDATA C5_TRANSP AS STRING
	WSDATA C5_CONDPAG AS FLOAT
	WSDATA C5_TABELA AS STRING
	WSDATA C5_EMISSAO AS STRING
	WSDATA C5_VEND1 AS FLOAT

	WSDATA C6_PRODUTO AS STRING
	WSDATA C6_QTDVEN AS STRING
	WSDATA C6_PRCVEN AS STRING
	WSDATA C6_OPER AS STRING
	WSDATA C6_TES AS STRING
	WSDATA C6_PRUNIT AS STRING
	WSDATA C5_PVINFOB AS FLOAT
	WSDATA C6_ENTREG AS STRING
	WSDATA C6_COMIS1 AS FLOAT

//WSMETHOD GET DESCRIPTION "Listar Pedido de Venda." WSSYNTAX "/"
	WSMETHOD POST DESCRIPTION "Incluir Pedido de Venda." WSSYNTAX "/"
	WSMETHOD PUT DESCRIPTION "Alterar Pedido de Venda." WSSYNTAX "/"
	WSMETHOD DELETE DESCRIPTION "Excluir Pedido de Venda." WSSYNTAX "/"

END WSRESTFUL


/*/{Protheus.doc} 
Metodo para incluir PV - MATA410-  
@type function
@version 
@author Manoel Mariante
@since 01/11/2019
/*/
WSMETHOD POST WSRECEIVE NULLPARAM WSSERVICE TEDA410

	Local lOk		:= .T.
	Local cBody		:= ::GetContent()
	/*
	Local cCampo	:= ""
	Local cAliasC5	:= ""
	Local cQuery	:= ""
	Local cPedido   := ""
	Local aMsg		:= {}
	Local nX		:= 0
	*/

	Private oJson

	::SetContentType("application/json")//Define o tipo de retorno do metodo

	u_LogConsole("TEDA410", "Acessando TEDA410 - Metodo  POST")
	u_LogInteg("TEDA410","Acessando TEDA410 - Metodo POST","SC5","",cBody,"",'')

	If !FWJsonDeserialize(cBody,@oJson)//Converte a estrutura Json em Objeto

		//u_LogConsole("TEDA410", "Erro nao Identificado" + cBody )
		lOk := .F.
		SetRestFault( 101, "Nao foi possivel processar a estrutura Json." )
		u_LogInteg("TEDA410","Erro","SC5","",cBody,"Nao foi possivel processar a estrutura Json.",time() )

	Else
		//-------------------------------
		//valida os dados do JSON
		//-----------------------------
		lOk:=TEDA410VLD(PD_INCLUIR)

	EndIf

	If lOk
		//-------------------------------
		//faz a inclusao do pedido
		//-----------------------------

		aRet:=TEDA410PV(PD_INCLUIR,cBody)

		If aRet[1]

			::SetResponse('{')
			::SetResponse('"code":"0",')
			::SetResponse('"message":"INCLUIDO",')
			::SetResponse('"C5_NUM":"'+SC5->C5_NUM+'"')
			::SetResponse('}')

		ELSE
			SetRestFault(114, "Erro ao INCLUIR o pedido ."+aRet[2]  )
		EndIf
	EndIf

Return( lOk )


/*/{Protheus.doc} 
Metodo para alterar PV 
@type function
@version 
@author Manoel Mariante
@since 01/11/2019
/*/
WSMETHOD PUT WSRECEIVE NULLPARAM WSSERVICE TEDA410

	Local lOk		:= .T.
	Local cBody		:= ::GetContent()
	/*
	Local cErro  	:= ""
	Local cQuery	:= ""
	Local cArea		:= ""
	Local cBlCred	:= ""
	Local cItem		:= ""
	Local aMsg		:= {}
	Local aCabec	:= {}
	Local aItens	:= {}
	Local aLinha	:= {}
	Local aItemPro	:= {}
	Local nX		:= 0
	Local nItemPr	:= 0
	Local nItemWS	:= 0
	*/

	Private oJson

	::SetContentType("application/json")//Define o tipo de retorno do metodo

	u_LogConsole("TEDA410", "Acessando TEDA410 - Metodo  PUT")


	If !FWJsonDeserialize(cBody,@oJson)//Converte a estrutura Json em Objeto

		lOk := .F.
		SetRestFault( 101, "Nao foi possivel processar a estrutura Json." )

	Else
		//valida dos dados do JSON
		lOk:=TEDA410VLD(PD_ALTERAR)
	END

	If lOk

		u_LogInteg("TEDA410","Acessando TEDA410 - Metodo PUT","SC5","",cBody,"",'')
		aRet:=TEDA410PV(PD_ALTERAR,cBody)

		If aRet[1]

			::SetResponse('{')
			::SetResponse('"code":"0",')
			::SetResponse('"message":"ALTERADO"')
			::SetResponse('}')

		ELSE
			SetRestFault(114, "Erro ao ALTERAR o pedido ."+aRet[2]  )
		End

	END

Return( lOk )


/*/{Protheus.doc} 
Metodo para deletar PV
@type function
@version 
@author Manoel Mariante
@since 01/11/2019
/*/
WSMETHOD DELETE WSRECEIVE C5_NUM WSSERVICE TEDA410

	Local lOk		:= .T.
	Local cBody		:= ::GetContent()
	//Local oJson

	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile := .T.


	::SetContentType("application/json")//Define o tipo de retorno do metodo
	u_LogConsole("TEDA410", "Acessando TEDA410 - Metodo  DELETE")
	u_LogInteg("TEDA410","Acessando TEDA410 - Metodo DELETE","SC5","",cBody,"",'')

	IF VALTYPE(::C5_NUM)=="U".or.EMPTY(::C5_NUM)
		lOk := .F.
		cMsgErro := "Pedido nao foi enviado."
		SetRestFault( 100, EncodeUTF8(cMsgErro, "cp1252") )
	Else
		Private cTEDPV			:=::C5_NUM
		//valida os dados
		lOk:=TEDA410VLD(PD_EXCLUIR)
	Endif

	If lOk
		aRet:=TEDA410PV(PD_EXCLUIR,'')
		If aRet[1]

			::SetResponse('{')
			::SetResponse('"code":"0",')
			::SetResponse('"message":"EXCLUIDO"')
			::SetResponse('}')

		ELSE
			SetRestFault(114, "Erro ao EXCLUIR o pedido ."+aRet[2]  )
		Endif

	Endif

Return( lOk )


/*/{Protheus.doc} TEDA410VLD
Funcao que valida os dados do JSON enviados para criacao ou alteraco do pedido de venda - MATA410 -  
@type function
@version 
@author  Manoel Mariante
@since 01/11/2019
@param nOper, numeric, param_description
@return return_type, return_description
/*/
Static Function TEDA410VLD(nOper)
	Local c1DUPNAT := SuperGetMv("MV_1DUPNAT",,"") //Campo ou dado a ser gravado na natureza do titulo. Quando o mesmo for gerado automaticamente pelo mo-
	Local lOk := .T.
	Local aArea:=GetArea()
	Local nX := 0
	Local cMsgErro := ""

	/*
	iF nOper==PD_ALTERAR
		IF VALTYPE(oJson:C5_NUM)=='U'
			lOk := .F.						
			SetRestFault( 100, "Pedido nao foi enviado." )	
		END
	END
	*/

	//Só permitido itens vazio se for exclusão
	IF !nOper=PD_EXCLUIR .AND. Empty(oJson:itens)
		lOk := .F.
		cMsgErro := "Informe TI: Falha na Alteração do Pedido no Protheus. Para Excluir todos os itens utilize metodo de Exclusao"
		SetRestFault( 116, EncodeUTF8(cMsgErro, "cp1252")  )

	Endif

	If nOper=PD_INCLUIR
		//+---------------------------------------+
		//| Verifica atraves do pedido no Infobox
		//| mesmo pedido ja foi incluido
		//+---------------------------------------+

		cQuery := " SELECT IsNull( C5_NUM, '' ) C5_NUM "
		cQuery += " FROM " + RetSQLName("SC5")
		cQuery += " WHERE C5_FILIAL  = '" + xFilial("SC5") + "'"
		cQuery += "   AND C5_CDINFOB = " + STR(oJson:C5_PVINFOB)
		cQuery += "   AND D_E_L_E_T_ <> '*'"

		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), ( cAliasC5 := GetNextAlias() ), .F., .T. )

		cPedido := (cAliasC5)->C5_NUM

		(cAliasC5)->( dbCloseArea() )

		If !Empty( cPedido )
			lOk := .F.
			cMsgErro := "Pedido do Infobox : "+str(oJson:C5_PVINFOB)+" ja incluido anteriormente no pedido do Protheus: "+cPedido
			SetRestFault( 111,  EncodeUTF8(cMsgErro, "cp1252")  )

		EndIf
	EndIf

	If nOper=PD_ALTERAR

		//+-------------------------------------------------------+
		//| Pesquisa Pedido de Venda atraves do pedido no Infobox,|
		//| ou seja, campo C5_PVINFOB                             |
		//+-------------------------------------------------------+

		If VALTYPE(oJson:C5_PVINFOB) <> 'U'

			cQuery := " SELECT IsNull( C5_NUM, '' ) C5_NUM "
			cQuery += " FROM " + RetSQLName("SC5")
			cQuery += " WHERE C5_FILIAL  = '" + xFilial("SC5") + "'"
			cQuery += "   AND C5_CDINFOB = " + STR(oJson:C5_PVINFOB)
			cQuery += "   AND D_E_L_E_T_ <> '*'"

			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), ( cAliasC5 := GetNextAlias() ), .F., .T. )

			cPedido := (cAliasC5)->C5_NUM

			(cAliasC5)->( dbCloseArea() )

			If Empty( cPedido )

				lOk := .F.
				cMsgErro := "Pedido do Infobox : "+str(oJson:C5_PVINFOB)+" nao existe no Protheus "
				SetRestFault( 112,  EncodeUTF8(cMsgErro, "cp1252")  )


			Else

				SC5->( dbSetOrder(1)) // C5_FILIAL + C5_NUM
				SC5->( dbSeek(xFilial("SC5") + cPedido ))
			EndIf
		Else

			lOk := .F.
			cMsgErro := "Pedido do Infobox : Campo Pedido Infobox 'C5_PVINFOB' nao informado"
			SetRestFault( 112,  EncodeUTF8(cMsgErro, "cp1252")  )
		EndIf

		//Valida Itens duplicados -
		If VldC6Dupli(cPedido)
			lOk := .F.

			cMsgErro := "Pedido no Protheus (" + cPedido + ") com itens duplicados. Favor informar TI. PV Infobox: "+str(oJson:C5_PVINFOB) + "!"
			SetRestFault( 118,  EncodeUTF8(cMsgErro, "cp1252")  )
			u_LogInteg("TEDA410","Erro","SC5",alltrim(STR(oJson:C5_PVINFOB)) ,'',cMsgErro,time() )
		Endif




	EndIf

	If nOper=PD_EXCLUIR

		dbSelectArea("SC5")
		dbSetOrder(1)

		If !dbSeek( xFilial("SC5") + PadR( cTedPV, TamSX3("C5_NUM")[01] ) )
			lOk := .F.
			cMsgErro :=  "Pedido de Venda "+cTedPV+" nao existe no Protheus"
			SetRestFault( 112,  EncodeUTF8(cMsgErro, "cp1252")  )
		EndIf
	EndIf

	If nOper=PD_ALTERAR.or.nOper=PD_INCLUIR
		If  Empty(oJson:C5_CLIENTE) .or. Empty(oJson:C5_TIPO).or.	Empty(oJson:C5_LOJACLI) .or. Empty(oJson:C5_CLIENT).or. 		Empty(oJson:C5_LOJAENT) .or. Empty(oJson:C5_TPFRETE) .or. Empty(oJson:C5_LOJAENT) .or. Empty(oJson:C5_PVINFOB)

			lOk := .F.
			cMsgErro := "Existem campos obrigatórios no cabeçalho que nao foram preenchidos."
			SetRestFault( 104,  EncodeUTF8(cMsgErro, "cp1252")  )
		EndIf

		//+---------------------------------------+
		//| Verifica se o cliente esta cadastrado |
		//+---------------------------------------+
		dbSelectArea("SA1")
		dbSetOrder(1)//A1_FILIAL+A1_COD+A1_LOJA
		If !dbSeek( xFilial("SA1") + PadR( oJson:C5_CLIENTE, TamSX3("C5_CLIENTE")[01] ) + PadR( oJson:C5_LOJACLI , TamSX3("C5_LOJACLI")[01] ))
			lOk := .F.
			SetRestFault( 103, "Cliente (C5_CLIENTE+C5_LOJACLI) nao cadastrado: "  + PadR( oJson:C5_CLIENTE, TamSX3("C5_CLIENTE")[01] ) + " + " +  PadR( oJson:C5_LOJACLI , TamSX3("C5_LOJACLI")[01])  )
		EndIf

		If !Empty(c1DUPNAT)
			If Empty( &(c1DUPNAT) )
				lOk := .F.
				cMsgErro := "O  campo de Natureza (" + c1DUPNAT + ") nao foi preenchido no Cliente :" + SA1->A1_COD + "/" + SA1->A1_LOJA
				SetRestFault( 116,  EncodeUTF8(cMsgErro, "cp1252")  )
			Endif
		EndIf

		//+---------------------------------------+
		//| Verifica se o cliente esta cadastrado |
		//+---------------------------------------+
		dbSelectArea("SA1")
		dbSetOrder(1)//A1_FILIAL+A1_COD+A1_LOJA
		If !dbSeek( xFilial("SA1") + PadR( oJson:C5_CLIENT, TamSX3("C5_CLIENT")[01] ) + PadR( oJson:C5_LOJAENT , TamSX3("C5_LOJAENT")[01] ))
			lOk := .F.
			SetRestFault( 103, "Cliente de Entrega (C5_CLIENT+C5_LOJAENT) nao cadastrado." )
		EndIf

		//+----------------------------------------------+
		//| Verifica se a Condicao de pagamento e valida |
		//+----------------------------------------------+

		//dbSelectArea("SE4")
		//dbSetOrder(1)//E4_FILIAL+E4_CODIGO
		// If !dbSeek( xFilial("SE4") + oJson:C5_CONDPAG )

		If EMPTY(fCndInfo(oJson:C5_CONDPAG))
			lOk := .F.
			SetRestFault( 107, "Condicao de pagamento (C5_CONDPAG) nao cadastrada." )
		EndIf

		//dbSelectArea("SA3")
		//dbSetOrder(1)//E4_FILIAL+E4_CODIGO
		//If !dbSeek( xFilial("SA3") + oJson:C5_VEND1 )
		IF EMPTY(fRepInfo(oJson:C5_VEND1))
			lOk := .F.
			SetRestFault(105, "Vendedor (C5_VEND1) nao cadastrado." )
		EndIf

		//+-------------------------+
		//| Valida o Tipo do Pedido |
		//+-------------------------+
		If !AllTrim( oJson:C5_TIPO ) $ "N"
			lOk := .F.
			SetRestFault(108, "Tipos de Pedido (C5_TIPO) diferente de NORMAL" )
		EndIf

		//+---------------------------------------+
		//| Verifica Tipo de Frete                |
		//+---------------------------------------+
		If !Empty( oJson:C5_TPFRETE )
			If !( oJson:C5_TPFRETE $ "C|F|T|S" )
				lOk := .F.

				SetRestFault(109, "Tipo de frete (C5_TPFRETE) invalido." )
				u_LogInteg("TEDA410","Erro","SC5",alltrim(STR(oJson:C5_PVINFOB)) ,'',"Tipo de Entrada e Saida nao encontrado: "+ oJson:C5_TRANSP,time() )
			EndIf
		EndIf

		//+---------------------------------------+
		//| Verifica a transportadora
		//+---------------------------------------+
		If !Empty( oJson:C5_TRANSP )
			dbSelectArea("SA4")
			dbSetOrder(1)
			If !dbSeek( xFilial("SA4") + PadR( oJson:C5_TRANSP , TamSX3("C5_TRANSP")[01] ))
				lOk := .F.
				cMsgErro :=  "Transportadora (C5_TRANSP) nao Encontrada"
				SetRestFault( 110,  EncodeUTF8(cMsgErro, "cp1252")  )
				u_LogInteg("TEDA410","Erro","SC5",alltrim(STR(oJson:C5_PVINFOB)) ,'',"Transportadora (C5_TRANSP) nao Encontrada: "+ oJson:C5_TRANSP,time() )
			EndIf
		EndIf

		For nX := 1 To Len( oJson:itens )

			IF ValType( oJson:itens[nX]:C6_TES ) <> "U"
				dbSelectArea('SF4')
				dbSetOrder(1)
				IF !dbSeek(xFilial('SF4')+oJson:itens[nX]:C6_TES)
					lOk := .F.
					cMsgErro := "Tipo de Entrada e Saida nao encontrado "+oJson:itens[nX]:C6_TES
					SetRestFault( 115,  EncodeUTF8(cMsgErro, "cp1252")  )
					u_LogInteg("TEDA410","Erro","SC5",alltrim(STR(oJson:C5_PVINFOB)) ,'',cMsgErro,time() )
				EndIf
			EndIf


			IF EMPTY(oJson:itens[nX]:C6_PRODUTO)
				lOk := .F.
				cMsgErro := "Produto nao informado"
				SetRestFault( 106,  EncodeUTF8(cMsgErro, "cp1252")  )
			EndIf
			cAuxProd:=PadR( oJson:itens[nX]:C6_PRODUTO, TamSX3("C6_PRODUTO")[01] )

			dbSelectArea('SB1')
			dbSetOrder(1)
			IF !dbSeek(xFilial('SB1')+cAuxProd)
				lOk := .F.
				cMsgErro := "Produto "+cAuxProd+" nao Encontrado no Protheus"
				SetRestFault( 106,  EncodeUTF8(cMsgErro, "cp1252")  )
			Else
				If SB1->B1_MSBLQL == '1'
					lOk := .F.
					cMsgErro := "Produto "+cAuxProd+" Bloqueado (B1_MSBLQL)"
					SetRestFault( 106,  EncodeUTF8(cMsgErro, "cp1252")  )
				Endif
			EndIf

			IF EMPTY(oJson:itens[nX]:C6_ITEM)
				lOk := .F.
				cMsgErro := "Item nao informado"
				SetRestFault( 113, EncodeUTF8(cMsgErro, "cp1252") )
			EndIf

			IF EMPTY(oJson:itens[nX]:C6_PRCVEN) .or. EMPTY(oJson:itens[nX]:C6_PRUNIT)
				lOk := .F.
				cMsgErro :=  "Preco de Venda ou Preco Unitario nao informado"
				SetRestFault( 113, EncodeUTF8(cMsgErro, "cp1252") )
			EndIf

		Next
	Endif
	RestArea(aArea)
Return lOk


/*/{Protheus.doc} TEDA410PV
Funcao que faz a insercao/alteracao/exclusao do pedido de venda - MATA410 -
@type function
@version 
@author Manoel Mariante
@since 11/2019
@param nOper, numeric, param_description
@param cBody, character, param_description
@return return_type, return_description
/*/
Static Function TEDA410PV(nOper,cBody)
	Local aCabec:={}
	Local aItens:={}
	Local aLinha:={}
	Local lOk := .T.
	Local cErro:=""
	Local nX := 0

	Local cMsgErro := ""
	Local aMsgB

	Local cItem
	Local nQtdLib
	Local cNumOP
	Local cItemOp

	Local cUltItem := STRZERO(1,2) //STRZERO(Len( oJson:itens ), TamSX3("C6_ITEM")[01] ) // Inicializa o ultimo item do pedido com o tamanho do array de itens
	Local X_CONTEUDO
	Local X_C6ITEM


	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.
	If nOper==PD_ALTERAR .OR. nOper==PD_INCLUIR
		//u_LogConsole("TEDA410", "JSON Recebido" + cBody )
	EndIf

	If nOper==PD_EXCLUIR
		//+--------------------------------------------------+
		//| Faco o Estorno somente se existir                |
		//+--------------------------------------------------+

		dbSelectArea("SC9")
		dbSetOrder(1)
		dbSeek( xFilial("SC9") + cTedPV )

		Do While SC9->( !Eof() ) .And. SC9->C9_FILIAL == xFilial('SC9') .And. SC9->C9_PEDIDO == cTedPV
			SC9->( A460Estorna() )
			SC9->( dbSkip() )
		EndDo

		aAdd( aCabec,{"C5_NUM" 	, cTedPV				, Nil} )

	else

		If nOper==PD_ALTERAR
			aAdd( aCabec,{"C5_NUM" 	, SC5->C5_NUM				, Nil} )
		EndIf
		aAdd( aCabec,{"C5_TIPO" 	, oJson:C5_TIPO				, Nil} )
		aAdd( aCabec,{"C5_EMISSAO" 	, CTOD(oJson:C5_EMISSAO)	, Nil} )
		aAdd( aCabec,{"C5_CLIENTE"	, PadR( oJson:C5_CLIENTE, TamSX3("C5_CLIENTE")[01] ), Nil} )
		aAdd( aCabec,{"C5_LOJACLI"	, oJson:C5_LOJACLI			, Nil} )
		aAdd( aCabec,{"C5_CLIENT"	, PadR( oJson:C5_CLIENT, TamSX3("C5_CLIENT")[01] )	, Nil} )
		aAdd( aCabec,{"C5_LOJAENT"	, oJson:C5_LOJAENT			, Nil} )
		aAdd( aCabec,{"C5_TRANSP"	, oJson:C5_TRANSP			, Nil} )
		aAdd( aCabec,{"C5_CONDPAG"	, fCndInfo(oJson:C5_CONDPAG), Nil} )
		aAdd( aCabec,{"C5_VEND1"	, fRepInfo(oJson:C5_VEND1)  , Nil} )
		aAdd( aCabec,{"C5_FRETE"	, oJson:C5_FRETE			, Nil} )
		aAdd( aCabec,{"C5_TPFRETE"	, oJson:C5_TPFRETE			, Nil} )
		aAdd( aCabec,{"C5_MENNOTA"	, oJson:C5_MENNOTA			, Nil} )
		aAdd( aCabec,{"C5_CDINFOB"	, oJson:C5_PVINFOB			, Nil} )

		//cItem := StrZero( 0, TamSX3("C6_ITEM")[1] )

		DBSelectArea("SC6")
		DBSetOrder(7) // C6_FILIAL+C6_NUMOP+C6_ITEMOP
		For nX := 1 To Len( oJson:itens )
			aLinha:={}

			/*
			If nOper==PD_ALTERAR
	
				dbSelectArea('SC6')
				dbSetOrder(1)
				IF dbSeek(xFilial('SC6')+SC5->C5_NUM+PadR( oJson:itens[nX]:C6_ITEM, TamSX3("C6_ITEM")[01] ))
					aAdd( aLinha,{"LINPOS","C6_ITEM", PadR( oJson:itens[nX]:C6_ITEM, TamSX3("C6_ITEM")[01] ) } )  	
					u_LogConsole("TEDA410", "ACHEI ITEM" )
					IF ValType( oJson:itens[nX]:DELETE ) <> "U" .AND. oJson:itens[nX]:DELETE=='S'
						aAdd( aLinha,{"AUTDELETA","S",Nil})
						u_LogConsole("TEDA410", "DELETE=S" )
					ELSE
						aAdd( aLinha,{"AUTDELETA","N",Nil})
						u_LogConsole("TEDA410", "DELETE=N" )
					END
				END
			End
			*/

			//cItem := oJson:itens[nX]:C6_ITEM
			cAuxProd:=PadR( oJson:itens[nX]:C6_PRODUTO, TamSX3("C6_PRODUTO")[01] )
			cOp		:=u_fOPbyOF(val(oJson:itens[nX]:C6_NUMOP))[1] //Busca numero da OP do Protheus pela OP do Infobox
			cNumOP	:=Substr(cOp,1,6)
			cItemOp	:=Substr(cOp,7,2)

			/*
			Quando for ALTERAÇÃO, deve ser buscado pela chave 
			( que hoje é a OP no Protheus, mas iremos mudar para numero da of )  e quando nao encontrar, 
			realizar uma consulta no SC6, identificado o próximo C6_ITEM disponível, ou seja, 
			se é um novo item no pedido, ele teria que ir para o final da lista existente. 
			*/

			nQtdLib := oJson:itens[nX]:C6_QTDLIB
			cItem   := PADL(AllTrim(oJson:itens[nX]:C6_ITEM),TamSX3("C6_ITEM")[1],"0")


			If nOper==PD_ALTERAR // Se for ALTERAÇÃO // // Localiza item no pedido



				//Tratamento para ITEM
				//Nova Busca por número campo C6_OFINFOB
				lFound :=  BuscaC6Item(SC5->C5_NUM, val(oJson:itens[nX]:C6_NUMOP)) //SC6->(MsSeek( xFilial("SC6") +  cNumOP + cItemOp ))




				//------ pesquisa antiga
				If !lFound .AND. !Empty(cNumOP + cItemOp)
					lFound := SC6->(MsSeek( xFilial("SC6") +  cNumOP + cItemOp ))

					If !lFound // Pesquisa por item
						DBSelectArea("SC6")
						DBSetOrder(1) // C6_FILIAL + C6_NUM + C6_ITEM + C6_PRODUTO
						lFound := SC6->(MsSeek( xFilial("SB1") +  SC5->C5_NUM +  PADL(AllTrim(oJson:itens[nX]:C6_ITEM),TamSX3("C6_ITEM")[1],"0") + cAuxProd   ))
						If !lFound
							lFound := SC6->(MsSeek( xFilial("SB1") +  SC5->C5_NUM +  PadR( oJson:itens[nX]:C6_ITEM , TamSX3("C6_ITEM")[01] ) + cAuxProd   ))
						Endif

						//Retorna para o Indice anterior
						DBSelectArea("SC6")
						DBSetOrder(7) // C6_FILIAL+C6_NUMOP+C6_ITEMOP
					Endif
				Endif
				///-------- fim pesquisa antiga

				If lFound
					cItem 	:= SC6->C6_ITEM
					nQtdLib := MIN(oJson:itens[nX]:C6_QTDLIB, SC6->( C6_QTDVEN - C6_QTDENT)) // Liberar somente a quantidade pendente a ser liberada - evitar crítica  A440QTDL
				Endif

				If !lFound // se nao encontrou de nenhuma forma cria novo item

					cItem 	:= SOMA1(  MAXC6Item(cUltItem, SC5->C5_NUM) ) //compara ultimo item do array com ultimo da tabela
					nQtdLib := oJson:itens[nX]:C6_QTDLIB
					cUltItem := cItem
					u_LogInteg("TEDA410","Alteração","SC5",alltrim(str(oJson:C5_PVINFOB)),"criando novo Item:" + cItem ,"criado novo Item:" + cItem,time())

				Endif


			Endif

			aLinha := {}
			//Jorge Alberto - Solutio - 24/11/2020 - Criada a função para substituir o carregamento dos dados aqui.
			aLinha := addLinha( .F. /*lDeleta*/,cItem, cAuxProd, oJson:itens[nX]:C6_QTDVEN, oJson:itens[nX]:C6_PRCVEN, nQtdLib, oJson:itens[nX]:C6_OPER, oJson:itens[nX]:C6_PRUNIT,;
				cNumOP, cItemOp, oJson:itens[nX]:C6_ENTREG, oJson:itens[nX]:C6_NUMPCOM, oJson:itens[nX]:C6_ITEMPC, oJson:itens[nX]:C6_COMIS1,;
				oJson:itens[nX]:C6_TES, oJson:itens[nX]:C6_NUMOP )
			/*
			aAdd( aLinha,{"C6_ITEM"		, cItem							  , Nil} )
			aAdd( aLinha,{"C6_PRODUTO"	, cAuxProd						  , Nil} )
			aAdd( aLinha,{"C6_QTDVEN"	, oJson:itens[nX]:C6_QTDVEN 	  , Nil} )
			aAdd( aLinha,{"C6_QTDLIB"	, nQtdLib						  , Nil} )
			aAdd( aLinha,{"C6_PRCVEN"	, oJson:itens[nX]:C6_PRCVEN		  , Nil} )
			aAdd( aLinha,{"C6_OPER"		, oJson:itens[nX]:C6_OPER		  , Nil} )
			aAdd( aLinha,{"C6_PRUNIT"	, oJson:itens[nX]:C6_PRUNIT		  , Nil} )
			aAdd( aLinha,{"C6_NUMOP"	, cNumOP						  , Nil} )
			aAdd( aLinha,{"C6_ITEMOP"	, cItemOp						  , Nil} )
			aAdd( aLinha,{"C6_ENTREG"	, CTOD(oJson:itens[nX]:C6_ENTREG) , Nil} )
			aAdd( aLinha,{"C6_NUMPCOM"	, oJson:itens[nX]:C6_NUMPCOM	  , Nil} )
			aAdd( aLinha,{"C6_ITEMPC"	, oJson:itens[nX]:C6_ITEMPC		  , Nil} )

			IF ValType( oJson:itens[nX]:C6_COMIS1 ) <> "U"
				aAdd( aLinha,{"C6_COMIS1"	, oJson:itens[nX]:C6_COMIS1	  , Nil} )
			EndIf
			//aAdd( aLinha,{"C6_COMIS1"	, oJson:itens[nX]:C6_COMIS1		, Nil} )

			//aAdd( aLinha,{"C6_LOCAL"	, oJson:itens[nX]:C6_LOCAL		, Nil} )

			//If !Empty( oJson:itens[nX]:C6_OPER )
			//Else
			IF ValType( oJson:itens[nX]:C6_TES ) <> "U"
				aAdd( aLinha,{"C6_TES"	, oJson:itens[nX]:C6_TES	      , Nil} )
			EndIf

			aAdd( aLinha,{"C6_OFINFOB"	, val(oJson:itens[nX]:C6_NUMOP)	  , Nil} )

			//EndIf
			*/

			aAdd( aItens, aLinha )

		Next nX
	EndIf

//Jorge Alberto - Solutio - 24/11/2020 - Tratamento para Comparar linhas com Pedido e enviar registro de deleção
	If nOper==PD_ALTERAR

		X_C6ITEM 	  := 01 // aScan( aItens[1], {|x| X[1] == "C6_ITEM" } ) //Pesquisa posiçaõ do campo Item do array // sempre vai ser 01
		X_CONTEUDO	  := 02

		DBSelectArea("SC6")
		DBSetOrder(1)
		DbSeek( xFilial("SC6") + SC5->C5_NUM )
		While SC6->( !EOF() ) .And. SC6->C6_NUM == SC5->C5_NUM

			// PV que está no Protheus nao existe no array dos Itens a ser transmitido para o EXECAUTO, então será excluído
			If aScan( aItens, {|Y| Y[X_C6ITEM][X_CONTEUDO] == SC6->C6_ITEM } ) <= 0 //PESQU

				aLinha := {}
				aLinha := addLinha( .T. /*lDeleta*/ , SC6->C6_ITEM)

				aAdd( aItens, aLinha )
			EndIf

			SC6->( dbSkip() )
		EndDo

		//aItens := aSort( aItens,,,{ |x,y| x[X_C6ITEM] < y[X_C6ITEM] } )
	EndIf

	MSExecAuto( {|x,y,z| MATA410(x,y,z)}, aCabec, aItens, nOper )//3- Inclusao, 4- Alteracao, 5- Excluscao

	If lMsErroAuto

		aMsg := GetAutoGRLog()
		aEval(aMsg,{|x| cErro += x + CRLF })

		lOk := .F.

		If Empty(aMsg)
			cMsgErro := "Erro nao Identificado - Protheus (execauto MATA410)"
		Else
			//Carrega somente primeiras linhas do erro
			aMsgB      := StrTokArr(aMsg[1], CRLF)
			If Len(aMsgB) >= 2
				cMsgErro := aMsgB[1] + " - " + aMsgB[2]
			Else
				cMsgErro := SUBSTR(aMsgB[1],1,(TamSX3("Z1_RETORNO")[1])-3) + "..."
			Endif
			cMsgErro := STRTRAN(cMsgErro,":", "-") // retira dois pontos
			cMsgErro := FwCutOff(cMsgErro, .t.)
		Endif

		u_LogInteg("TEDA410","Erro","SC5",alltrim(str(oJson:C5_PVINFOB)),cErro,cMsgErro,time())

		//u_LogConsole("TEDA410", "Erro nao Identificado" + CRLF + cErro )
		SetRestFault(102, EncodeUTF8(cMsgErro, "cp1252")   )

	else
		If nOper==PD_ALTERAR .OR. nOper==PD_INCLUIR
			fAjuSC9(SC5->C5_NUM)
		Endif
		u_LogInteg("TEDA410","Aviso","SC5",alltrim(str(oJson:C5_PVINFOB)),cBody,"Pedido de Venda:" + SC5->C5_NUM + " processado com sucesso",time())
		conout("Pedido de Venda numero: " + SC5->C5_NUM + " processado com sucesso. Data: " + Dtoc( MsDate() ) + " - Hora: " + Time())
	EndIf
Return {lOk,cErro}


Static Function addLinha( lDeleta, cItem, cAuxProd, nQtdVen, nPrcVen, nQtdLib, cOper, nPrUnit, cNumOP, cItemOp, cDtEntreg, cNumpCom, cItemPC, nComis1, cTES, cOFINFOB )

	Local aLinha := {}

	Default lDeleta := .F.


	If lDeleta
		aadd( aLinha,{ "LINPOS"   , "C6_ITEM"		, SC6->C6_ITEM } )
		aadd( aLinha,{ "AUTDELETA", "S"      		, Nil          } )
	Else
		aadd( aLinha,{ "AUTDELETA"	, "N"      			, Nil } )
		aAdd( aLinha,{"C6_ITEM"		, cItem		        , Nil } )
		aAdd( aLinha,{"C6_PRODUTO"	, cAuxProd	        , Nil } )
		aAdd( aLinha,{"C6_QTDVEN"	, nQtdVen 	        , Nil } )
		aAdd( aLinha,{"C6_QTDLIB"	, nQtdLib	        , Nil } )
		aAdd( aLinha,{"C6_PRCVEN"	, nPrcVen	        , Nil } )
		aAdd( aLinha,{"C6_OPER"		, cOper		        , Nil } )
		aAdd( aLinha,{"C6_PRUNIT"	, nPrUnit	        , Nil } )
		aAdd( aLinha,{"C6_NUMOP"	, cNumOP	        , Nil } )
		aAdd( aLinha,{"C6_ITEMOP"	, cItemOp	        , Nil } )
		aAdd( aLinha,{"C6_ENTREG"	, CTOD( cDtEntreg ) , Nil } )
		aAdd( aLinha,{"C6_NUMPCOM"	, cNumpCom	        , Nil } )
		aAdd( aLinha,{"C6_ITEMPC"	, cItemPC	        , Nil } )


		If ValType( nComis1 ) <> "U"
			aAdd( aLinha,{"C6_COMIS1", nComis1       	, Nil } )
		EndIf

		If ValType( cTES ) <> "U"
			aAdd( aLinha,{"C6_TES"	, cTES	            , Nil } )
		EndIf

		aAdd( aLinha,{"C6_OFINFOB"	, val( cOFINFOB )     , Nil } )
	Endif
Return( aLinha )

Static Function fRepInfo(nRep)
	Local cRep:=""

	cQuery := " SELECT IsNull( A3_COD, '' ) A3_COD "
	cQuery += " FROM " + RetSQLName("SA3")
	cQuery += " WHERE A3_FILIAL  = '" + xFilial("SA3") + "'"
	cQuery += "   AND A3_CDINFOB = " + STR(oJson:C5_VEND1)
	cQuery += "   AND D_E_L_E_T_ <> '*'"

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), ( cAliasC5 := GetNextAlias() ), .F., .T. )

	IF !EOF()
		cRep := (cAliasC5)->A3_COD
	EndIf

	(cAliasC5)->( dbCloseArea() )

Return cRep

Static Function fCndInfo(nRep)
	Local cRep:=""

	cQuery := " SELECT IsNull( E4_CODIGO, '' ) E4_CODIGO "
	cQuery += " FROM " + RetSQLName("SE4")
	cQuery += " WHERE E4_FILIAL  = '" + xFilial("SE4") + "'"
	cQuery += "   AND E4_CDINFOB = " + STR(oJson:C5_CONDPAG)
	cQuery += "   AND D_E_L_E_T_ <> '*'"

	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), ( cAliasC5 := GetNextAlias() ), .F., .T. )

	IF !EOF()
		cRep := (cAliasC5)->E4_CODIGO
	EndIf

	(cAliasC5)->( dbCloseArea() )

Return cRep

Static Function fAjuSC9(cPedido)
	Local aArea:=GetArea()
	dbSelectArea("SC9")
	dbSetOrder(1)
	dbSeek(xFilial("SC9")+cPedido,.t.)
	Do While !eof() .and. C9_PEDIDO == cPedido
		reclock("SC9" ,.f.)
		SC9->C9_BLCRED:="  "
		MSUNLOCK()
		DBSKIP()
	EndDo

	RESTAREA(aArea)

Return
//------------------------------------------------------------------------------------------
User Function LogInteg(cZ1Rotina,cZ1Descric,cZ1Tabela,cZ1Chave,CZ1JSON,cZ1Retorno,cZ1HoraRet)
//------------------------------------------------------------------------------------------
	dbSelectArea('SZ1')
	RecLock('SZ1',.t.)
	SZ1->Z1_FILIAL 	:=xFilial('SZ1')
	SZ1->Z1_ROTINA	:=cZ1Rotina
	SZ1->Z1_DATA	:=msdate()
	SZ1->Z1_HORA	:=Time()
	SZ1->Z1_DECRIC	:=cZ1Descric
	SZ1->Z1_RETORNO	:=cZ1Retorno
	SZ1->Z1_HORARET	:=cZ1HoraRet
	SZ1->Z1_TABELA	:=cZ1Tabela
	SZ1->Z1_CHAVE	:=cZ1Chave
	SZ1->Z1_JSON	:=cZ1JSON
	MSUNLOCK()

RETURN


/*/{Protheus.doc} VldC6Dupli
Busca Itens duplicados nos itens do Pedido e retorna .T. se encontrar. 
nao deve existir duplicados
@type function
@version 
@author solutio
@since 20/11/2020
@param cPedido, character, param_description
@return return_type, return_description
/*/
Static Function VldC6Dupli(cPedido)
	Local lRet := .F.
	Local cSql := ''
	Private cTRB := GetNextAlias()

	DEFAULT cPedido := " "

	cSql += "SELECT R_E_C_N_O_ , C6_NUM ,* FROM ("
	cSql += "					SELECT  cast(C6_ITEM as integer ) teste, DENSE_RANK () OVER ( PARTITION  BY C6_FILIAL, C6_NUM, cast(C6_ITEM as integer )  ORDER BY C6_FILIAL, C6_NUM, cast(C6_ITEM as integer ), R_E_C_N_O_ ) NEWITEM, * "
	cSql += "					FROM " + RetSqlName("SC6") + " WHERE C6_FILIAL = '"+  xFilial("SC6")+"'  AND D_E_L_E_T_  <> '*'  AND C6_NUM = '" + cPedido + "'"
	cSql += "				) TMP WHERE NEWITEM > 1   order by C6_FILIAL, 2, C6_ITEM"


	MPSysOpenQuery( cSql, cTRB)

	IF (cTRB)->(!EOF())
		lRet := .T.
	ENDIF

Return  lRet


/*/{Protheus.doc} BuscaC6Item
Busca Maior item dos ITENS recebidos no Json de ITENS 
@type function
@version 
@author solutio
@since 23/11/2020
@param cNumSC5, character, param_description
@param nNumOFInfobox, numeric, param_description
@return return_type, return_description
/*/
Static Function BuscaC6Item(cNumSC5,nNumOFInfobox)
	Local lRet := .F.
	Local cSql := ''
	Private cTRB := GetNextAlias()

	DEFAULT cNumSC5 := " "
	DEFAULT nNumOFInfobox := 0


	cSql += "SELECT R_E_C_N_O_ NREG FROM " + RetSqlName("SC6") + " WHERE C6_FILIAL = '"+  xFilial("SC6")+"'  AND D_E_L_E_T_  <> '*'  AND C6_OFINFOB = " + AllTrim(STR(nNumOFInfobox))



	MPSysOpenQuery( cSql, cTRB)

	IF (cTRB)->(!EOF())
		DBSelectArea("SC6")
		SC6->(DBGoto( (cTRB)->NREG))
		lRet := (cTRB)->NREG == SC6->(Recno())
	ENDIF
	(cTRB)->(dbCloseArea())
Return  lRet

/*/{Protheus.doc} MAXC6Item
Busca Maior item dos ITENS já gravados no SC6
@type function
@version 
@author solutio
@since 23/11/2020
@param cNumSC5, character, Ultimo Item do Array
@param cNumSC5, character, Número do PV para localizar o ultimo item do mesmo
@return return_type, return_description
/*/
Static Function MAXC6Item(cUltItem, cNumSC5)
	Local cRet := ""
	Local cSql := ''
	Private cTRB := GetNextAlias()

	DEFAULT cUltItem:= " "
	DEFAULT cNumSC5 := " "



	cSql += "SELECT MAX(C6_ITEM) ITEM FROM " + RetSqlName("SC6") + " WHERE C6_FILIAL = '"+  xFilial("SC6")+"'  AND D_E_L_E_T_  <> '*'  AND C6_NUM = '" + cNumSC5 + "'"


	MPSysOpenQuery( cSql, cTRB)

	IF (cTRB)->(!EOF())
		cRet := (cTRB)->ITEM
	ELSE
		cRet := REPLICATE("0", TamSX3("C6_ITEM")[01]) // caso nao encontre irá retornar zero
	ENDIF

	(cTRB)->(dbCloseArea())


	If cUltItem > cRet
		cRet := cUltItem
	Endif
Return  cRet
