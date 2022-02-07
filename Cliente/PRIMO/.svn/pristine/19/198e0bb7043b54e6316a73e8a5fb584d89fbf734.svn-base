#Include "TOTVS.CH"
#Include "RESTFUL.CH"
//Opcoes ExecAuto 
#Define PD_INCLUIR 3
#Define PD_ALTERAR 4
#Define PD_EXCLUIR 5
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TEDA010     ³ Autor ³ Manoel Mariante       ³ Data ³ nov/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Servico Web service para manutenção do cadastro de         ³±±
±±³          ³ cadastro de produtos mata010                               ³±±
±±³          ³                                                            ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSRESTFUL TEDA010 DESCRIPTION "Cadastro de Produtos"

	WSDATA B1_COD AS STRING
	WSDATA B1_TIPO AS STRING
	WSDATA B1_UM AS STRING
	WSDATA B1_GRUPO AS STRING
	WSDATA B1_POSIPI AS STRING
	WSDATA B1_DESC AS STRING
	WSDATA B1_LOCPAD AS STRING
	WSDATA B1_CONTA AS STRING
	WSDATA B1_ORIGEM AS STRING

//WSMETHOD GET DESCRIPTION "Listar Pedido de Compra." WSSYNTAX "/"
	WSMETHOD POST DESCRIPTION "Método para inclusão de Cadastro de Produtos" WSSYNTAX "/"
	WSMETHOD PUT DESCRIPTION "Método para alteração de Cadastro de Produtos" WSSYNTAX "/"
	WSMETHOD DELETE DESCRIPTION "Método para exclusão de Cadastro de Produtos" WSSYNTAX "/"

END WSRESTFUL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³ POST     ºAutor  ³ Manoel Mariante    º Data ³  Nov/2019   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Metodo para incluir                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD POST WSRECEIVE NULLPARAM WSSERVICE TEDA010

	Local lOk		:= .T.
	Local cBody		:= ::GetContent()
	//Local cErro  	:= ""
	//Local aMsg		:= {}
	//Local nX		:= 0
	Private oJson

	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.

	Private __nnLock
	Private __CCARQ
	Private lSetResponse	:= .F.

	cFilAnt := "0102"

	u_LogConsole("TEDA010", "Entrei TEDA010 POST")

	::SetContentType("application/json")//Define o tipo de retorno do metodo

	If !FWJsonDeserialize(cBody,@oJson)//Converte a estrutura Json em Objeto

		lOk := .F.
		SetRestFault( 101, "Nao foi possivel processar a estrutura Json." )
		u_LogConsole("TEDA010", "JSON COM PROBLEMA")

	Else
		u_LogInteg("TEDA010","Acessando TEDA010 - Método POST","SB1","",cBody,"",'')
		//-------------------------------
		//valida os dados do JSON
		//-----------------------------
		lOk:=VLD_JSON(PD_INCLUIR)

	EndIf

	If lOk

		aRet:=PROC_MOV(PD_INCLUIR,cBody)

		If aRet[1]

			::SetResponse('{')
			::SetResponse('"code":"0",')
			::SetResponse('"message":"INCLUIDO"')

			::SetResponse('}')

			lSetResponse := .T.

		ELSE
			If !lSetResponse //Verifica se já não foi enviado um RestFAult
				SetRestFault(115, "Erro ao incluir o cadastro de produtos ."+aRet[2]  )
				lSetResponse := .T.
			Endif
		End

	EndIf

Return( lOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³ PUT      ºAutor  ³ Manoel Mariante    º Data ³  Nov/2019   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Metodo para alterar                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD PUT WSRECEIVE NULLPARAM WSSERVICE TEDA010

	Local lOk		:= .T.
	Local cBody		:= ::GetContent()
	//Local cErro  	:= ""
	//Local aMsg		:= {}
	//Local nX		:= 0
	Private oJson

	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T.
	Private lSetResponse   := .F.

	Private __nnLock
	Private __CCARQ

	cFilAnt := "0102"

	u_LogConsole("TEDA010", "Entrei TEDA010,put ")


	::SetContentType("application/json")//Define o tipo de retorno do metodo

	If !FWJsonDeserialize(cBody,@oJson)//Converte a estrutura Json em Objeto

		lOk := .F.
		SetRestFault( 101, "Nao foi possivel processar a estrutura Json." )
		u_LogConsole("TEDA010", "JSON COM PROBLEMA")
	Else
		u_LogInteg("TEDA010","Acessando TEDA010 - Método PUT","SB1","",cBody,"",'')
		//-------------------------------
		//valida os dados do JSON
		//-----------------------------
		lOk:=VLD_JSON(PD_ALTERAR)

	End

	If lOk

		aRet:=PROC_MOV(PD_ALTERAR,cBody)

		If aRet[1]

			::SetResponse('{')
			::SetResponse('"code":"0",')
			::SetResponse('"message":"ALTERADO"')

			::SetResponse('}')

		ELSE
			If !lSetResponse
				SetRestFault(115, "Erro ao alterar o cadastro de produtos ."+aRet[2]  )
				lSetResponse := .T.
			Endif
		End
	end

Return( lOk )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³ DELETE   ºAutor  ³ Manoel Mariante    º Data ³  Nov/2019   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Metodo para excluir OP                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD DELETE WSRECEIVE B1_COD WSSERVICE TEDA010

	Local lOK		 	:= .T.
	//Local cMsg		:= ""
	//Local cErrorLog	:= ""
	//Local cBody		:= ::GetContent()
	Private cB1Cod       := ::B1_COD
	Private lMsErroAuto  := .F.
	Private lSetResponse := .F.
	Private oJson

	cFilAnt := "0102"

	u_LogConsole("TEDA010", 'Entrei na rotina, delete')

	::SetContentType("application/json")	// define o tipo de retorno do método

	//+-------------------------------------------------+
	//| Verifica se foi informado os parametros no link |
	//+-------------------------------------------------+
	If VALTYPE(::B1_COD)=="U" .OR. EMPTY(::B1_COD)

		lOk := .F.
		SetRestFault( 115, "Codigo B1_COD não informado" )
		u_LogConsole("TEDA010", "B1_COD não informado para deletar")

	else
		//-------------------------------
		//valida os dados do JSON
		//-----------------------------
		lOk:=VLD_JSON(PD_EXCLUIR)

	END

	If lOk

		aRet:=PROC_MOV(PD_EXCLUIR,"")

		If aRet[1]

			::SetResponse('{')
			::SetResponse('"code":"0",')
			::SetResponse('"message":"EXCLUIDO"')

			::SetResponse('}')

		ELSE
			If !lSetResponse
				SetRestFault(115, "Erro ao excluir o cadastro de produtos ."+aRet[2]  )
				lSetResponse := .T.
			Endif
		End
	end

Return(lOk)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VLD_JSON    ³ Autor ³ Manoel Mariante       ³ Data ³ nov/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que valida os dados do JSON enviados para           ³±±
±±³          ³ manutencao da informacao                                   ³±±
±±³          ³                                                            ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function VLD_JSON(nOper)
	Local lOk := .T.
	Local aArea:=GetArea()
	Local cMsgErro := ""

	If nOper=PD_ALTERAR.or.nOper=PD_INCLUIR

		//Validação de Campos obrigatórios
		cMsgErro := ""
		If  Empty(oJson:B1_COD)
			cMsgErro := " B1_COD"
		Endif
		IF	Empty(oJson:B1_DESC)
			cMsgErro := " B1_DESC"
		Endif
		IF	Empty(oJson:B1_TIPO)
			cMsgErro := " B1_TIPO"
		Endif
		IF	Empty(oJson:B1_UM)
			cMsgErro := " B1_UM"
		Endif
		IF	Empty(oJson:B1_GRUPO)
			cMsgErro := " B1_GRUPO"
		Endif
		IF	Empty(oJson:B1_POSIPI)
			cMsgErro := " B1_POSIPI"
		Endif
		IF	Empty(oJson:B1_CONTA)
			cMsgErro := " B1_CONTA"
		Endif
		IF	Empty(oJson:B1_ORIGEM)
			cMsgErro := " B1_ORIGEM"
		Endif
		IF	Empty(oJson:B1_LOCPAD)
			cMsgErro := " B1_LOCPAD"
		Endif
		IF	Empty(oJson:B1_AREA)
			cMsgErro := " B1_AREA"
		Endif

		IF	Empty(oJson:B1_PESO)
			cMsgErro := " B1_PESO"
		Endif

		If !Empty(cMsgErro)
			lOk := .F.
			If !lSetResponse
				cMsgErro :=  "Existem campos obrigatórios que não foram preenchidos: " + cMsgErro
				SetRestFault( 104, EncodeUTF8(cMsgErro, "cp1252") )
				lSetResponse := .T.
			Endif
			u_LogConsole("TEDA010", "problemas...:"+cMsgErro)

		End

		dbSelectArea('SBM')
		dbSetOrder(1)
		IF !dbSeek(xFilial('SBM')+PadR( oJson:B1_GRUPO, TamSX3("B1_GRUPO")[01] ))
			lOk := .F.
			If !lSetResponse
				cMsgErro := "Grupo não cadastrado"
				SetRestFault( 102, EncodeUTF8(cMsgErro, "cp1252") )
				lSetResponse := .T.
			Endif
		EndIf

		dbSelectArea('SAH')
		dbSetOrder(1)
		IF !dbSeek(xFilial('SAH')+PadR( oJson:B1_UM, TamSX3("B1_UM")[01] ))
			lOk := .F.
			If !lSetResponse
				cMsgErro := "Unidade de Medida não cadastrado"
				SetRestFault( 103, EncodeUTF8(cMsgErro, "cp1252") )
				lSetResponse := .T.
			Endif
		EndIf

		dbSelectArea('NNR')
		dbSetOrder(1)
		IF !dbSeek(xFilial('NNR')+PadR( oJson:B1_LOCPAD, TamSX3("B1_LOCPAD")[01] ))
			lOk := .F.
			If !lSetResponse
				cMsgErro := "Local Padrão não cadastrado"
				SetRestFault( 105, EncodeUTF8(cMsgErro, "cp1252") )
			Endif

		EndIf

		dbSelectArea('SYD')
		dbSetOrder(1)
		IF !dbSeek(xFilial('SYD')+PadR( oJson:B1_POSIPI, TamSX3("B1_POSIPI")[01] ))
			lOk := .F.
			If !lSetResponse
				cMsgErro := "NCM não cadastrado"
				SetRestFault( 106, EncodeUTF8(cMsgErro, "cp1252") )
				lSetResponse := .T.
			Endif
		EndIf
		dbSelectArea('CT1')
		dbSetOrder(1)
		IF !dbSeek(xFilial('CT1')+PadR( oJson:B1_CONTA, TamSX3("B1_CONTA")[01] ))
			lOk := .F.
			If !lSetResponse
				cMsgErro := "Conta Contábil não cadastrado"
				SetRestFault( 107, EncodeUTF8(cMsgErro, "cp1252") )
				lSetResponse := .T.
			Endif
		EndIf

	End

	If nOper=PD_INCLUIR

		dbSelectArea('SB1')
		dbSetOrder(1)
		IF dbSeek(xFilial('SB1')+PadR( oJson:B1_COD, TamSX3("B1_COD")[01] ))
			lOk := .F.
			If !lSetResponse
				cMsgErro := "Produto Já Cadastrado"
				SetRestFault( 108, EncodeUTF8(cMsgErro, "cp1252") )
				lSetResponse := .T.
			Endif
		EndIf
	end

	If nOper=PD_ALTERAR
		dbSelectArea('SB1')
		dbSetOrder(1)
		IF !dbSeek(xFilial('SB1')+PadR( oJson:B1_COD, TamSX3("B1_COD")[01] ))
			lOk := .F.
			If !lSetResponse
				cMsgErro := "Produto não Cadastrado"
				SetRestFault( 115, EncodeUTF8(cMsgErro, "cp1252") )
				lSetResponse := .T.
			Endif
		EndIf

	end
	If nOper=PD_EXCLUIR
		dbSelectArea('SB1')
		dbSetOrder(1)
		IF !dbSeek(xFilial('SB1')+PadR( cB1Cod, TamSX3("B1_COD")[01] ))
			lOk := .F.
			If !lSetResponse
				cMsgErro := "Produto não Cadastrado"
				SetRestFault( 115, EncodeUTF8(cMsgErro, "cp1252") )
				lSetResponse := .T.
			Endif
		EndIf

	end

	RestArea(aArea)
Return lOk

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PROC_MOV    ³ Autor ³ Manoel Mariante       ³ Data ³ nov/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que faz a insercao/alteracao/exclusoa do            ³±±
±±³          ³ da rotina                                                  ³±±
±±³          ³                                                            ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function PROC_MOV(nOper,cBody)
	Local aCabec:={}
	//Local aItens:={}
	//Local aLinha:={}
	Local cErro := ""
	Local aMsg  :={}
	Local cMsgErro := ""
	Local aMsgB
	//Local nX	 := 0
	Local lOk  	 := .T.

	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.

	DO CASE
	CASE  AllTrim(oJson:B1_POSIPI) $ '48191000/'     //CAIXA
		nIpi := 15
	CASE  AllTrim(oJson:B1_POSIPI) $ '48239091/48239990' //ACESSORIOS
		nIpi := 15
	CASE  AllTrim(oJson:B1_POSIPI) $ '48081000/'    //CHAPA
		nIpi := 5
	OTHERWISE
		nIpi := 0
	END CASE


	If nOper=PD_ALTERAR .OR. nOper==PD_INCLUIR

		Aadd(aCabec,{'B1_COD'		, PadR( oJson:B1_COD, TamSX3("B1_COD")[01] ) 		, Nil })
		Aadd(aCabec,{'B1_DESC'		, PadR( oJson:B1_DESC, TamSX3("B1_DESC")[01] ) 		, Nil })
		Aadd(aCabec,{'B1_TIPO'		, PadR( oJson:B1_TIPO, TamSX3("B1_TIPO")[01] ) 		, Nil })
		Aadd(aCabec,{'B1_UM'		, PadR( oJson:B1_UM, TamSX3("B1_UM")[01] ) 			, Nil })
		Aadd(aCabec,{'B1_GRUPO'		, PadR( oJson:B1_GRUPO, TamSX3("B1_GRUPO")[01] ) 	, Nil })
		Aadd(aCabec,{'B1_POSIPI'	, PadR( oJson:B1_POSIPI, TamSX3("B1_POSIPI")[01] ) 	, Nil })
		Aadd(aCabec,{'B1_IPI'		, nIpi												, Nil })
		Aadd(aCabec,{'B1_LOCPAD'	, PadR( oJson:B1_LOCPAD, TamSX3("B1_LOCPAD")[01] ) 	, Nil })
		Aadd(aCabec,{'B1_CONTA'		, PadR( oJson:B1_CONTA, TamSX3("B1_CONTA")[01] ) 	, Nil })
		Aadd(aCabec,{'B1_ORIGEM'	, PadR( oJson:B1_ORIGEM, TamSX3("B1_ORIGEM")[01] ) 	, Nil })
		Aadd(aCabec,{'B1_AREA'		, oJson:B1_AREA										, Nil })
		Aadd(aCabec,{'B1_PESO'		, oJson:B1_PESO 									, Nil })
	END
	If nOper=PD_EXCLUIR

		Aadd(aCabec,{'B1_COD'		, PadR( cB1Cod, TamSX3("B1_COD")[01] ) 		, Nil })
	END


	lMsErroAuto := .f.

	u_LogConsole("TEDA010", "vou processar operação "+Str(nOper,1))

	MSExecAuto( { |x,y| MatA010( x, y )}, aCabec, nOper )

	If lMsErroAuto

		aMsg := GetAutoGRLog()
		aEval(aMsg,{|x| cErro += x + CRLF })

		lOk := .F.

		If Empty(aMsg)
			cMsgErro := "Erro não Identificado - Protheus (execauto MATA010)"
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

		u_LogInteg("TEDA010","Erro","SB1",alltrim(oJson:B1_COD),cErro,cMsgErro,time())
		u_LogConsole("TEDA010", "problemas...:"+cMsgErro)

		//u_LogConsole("TEDA410", "Erro não Identificado" + CRLF + cErro )

		SetRestFault(116, EncodeUTF8(cMsgErro, "cp1252")   )
		lSetResponse := .T.
	else
		u_LogInteg("TEDA010","Aviso","SB1",alltrim(oJson:B1_COD),cBody,"Produto " + oJson:B1_COD + " cadastrado com sucesso",time())
		If nOper=PD_ALTERAR .OR. nOper==PD_INCLUIR
			//Cria Complemento do Produto MATA180

		Endif
	Endif



Return {lOk,cErro}
