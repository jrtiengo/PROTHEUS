#Include "TOTVS.CH"
#Include "RESTFUL.CH"

//Opcoes ExecAuto 
#Define PD_INCLUIR 3
#Define PD_ALTERAR 4
#Define PD_EXCLUIR 5
#Define CRLF CHR(13)+CHR(10)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �TEDA200     � Autor � Manoel Mariante       � Data � nov/19 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Servico Web service para manuten��o do cadastro de         ���
���          � ESTRUTURA DE PRODUTOS - MATA200 - SG1                      ���
���          �                                                            ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSRESTFUL TEDA200 DESCRIPTION "Estrutura de Produtos"

	WSDATA G1_COD AS STRING
	WSDATA G1_QUANT AS FLOAT
	WSDATA G1_COMP AS STRING
	WSDATA G1_PERDA AS FLOAT
	WSDATA G1_INI AS STRING
	WSDATA G1_FIM AS STRING
	WSDATA G1_TRT AS STRING
	WSDATA G1_OBSERV AS STRING

//WSMETHOD GET DESCRIPTION "Listar Estrutura ." WSSYNTAX "/"
	WSMETHOD POST DESCRIPTION "Incluir Estrutura ." WSSYNTAX "/"
	WSMETHOD PUT DESCRIPTION "Alterar Estrutura ." WSSYNTAX "/"
	WSMETHOD DELETE DESCRIPTION "Excluir Estrutura ." WSSYNTAX "/"

END WSRESTFUL

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    � POST     �Autor  � Manoel Mariante    � Data �  Nov/2019   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo para incluir                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD POST WSRECEIVE NULLPARAM WSSERVICE TEDA200

	Local lOk		:= .T.
	Local cBody		:= ::GetContent()
	Local cMsg		:= ""
	Local cErro  	:= ""
	Local cQuery	:= ""
	Local aMsg		:= {}
	Local nX		:= 0


	Private oJson
	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.


	::SetContentType("application/json")//Define o tipo de retorno do metodo

	If !FWJsonDeserialize(cBody,@oJson)//Converte a estrutura Json em Objeto
		u_LogConsole("TEDA200", "Erro n�o Identificado" + cBody )
		lOk := .F.
		SetRestFault( 101, "Nao foi possivel processar a estrutura Json." )

	Else
		//-------------------------------
		//valida os dados do JSON
		//-----------------------------
		lOk:=VLD_JSON(PD_INCLUIR)

	EndIf

	If lOk

		lRet:=PROC_MOV(PD_INCLUIR)

		If lRet

			::SetResponse('{')
			::SetResponse('"code":"0",')
			::SetResponse('"message":"INCLUIDO"')

			::SetResponse('}')

		ELSE
			SetRestFault(114, "Erro ao INCLUIR a Estrutura ."  )
		End

	EndIf

Return( lOk )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    � PUT      �Autor  � Manoel Mariante    � Data �  Nov/2019   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo para alterar PV                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD PUT WSRECEIVE NULLPARAM WSSERVICE TEDA200

	Local lOk		:= .T.
	Local cBody		:= ::GetContent()
	Local cErro  	:= ""
	Local cQuery	:= ""
	Local cArea		:= ""
	Local cBlCred	:= ""
	Local cItem		:= ""
	Local aMsg		:= {}
	Local nX		:= 0
	Local nItemPr	:= 0
	Local nItemWS	:= 0
	Private oJson

	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.

	::SetContentType("application/json")//Define o tipo de retorno do metodo

	u_LogConsole("TEDA200",'ENTREI' )

	If !FWJsonDeserialize(cBody,@oJson)//Converte a estrutura Json em Objeto
		u_LogConsole("TEDA200", "Erro n�o Identificado" + cBody )

		lOk := .F.
		SetRestFault( 101, "Nao foi possivel processar a estrutura Json." )

	Else
		//-------------------------------
		//valida os dados do JSON
		//-----------------------------
		lOk:=VLD_JSON(PD_ALTERAR)
		u_LogConsole("TEDA200",'VALID OK' )

	EndIf

	If lOk
		//-------------------------------
		//faz a inclusao do pedido
		//-----------------------------
		u_LogConsole("TEDA200",'VOU GRAVAAR' )
		lRet:=PROC_MOV(PD_ALTERAR)
		If lRet
			u_LogConsole("TEDA200",'GRAVOU OK' )

			::SetResponse('{')
			::SetResponse('"code":"0",')
			::SetResponse('"message":"ALTERADA"')
			::SetResponse('}')

		ELSE
			SetRestFault(114, "Erro ao ALTERAR a Estrutura ."  )
			u_LogConsole("TEDA200",'NAO GRAVOU' )
		End


	EndIf
	u_LogConsole("TEDA20",'FIM' )
Return( lOk )


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    � DELETE   �Autor  � Manoel Mariante    � Data �  Nov/2019   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo para deletar PV                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD DELETE WSRECEIVE G1_COD WSSERVICE TEDA200

	Local lOk		:= .T.
	//Local cBody		:= ::GetContent()
	Local cErro  	:= ""
	Local aMsg		:= {}
	Local oJson

	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile := .T.
	Private cCodSG1			:=::G1_COD

	::SetContentType("application/json")//Define o tipo de retorno do metodo

	If EMPTY(::G1_COD) //!FWJsonDeserialize(cBody,@oJson)//Converte a estrutura Json em Objeto

		lOk := .F.
		SetRestFault( 105, "Codigo n�o Informado" )

	Else
		//-------------------------------
		//valida os dados do JSON
		//-----------------------------
		lOk:=VLD_JSON(PD_EXCLUIR)

	EndIf

	If lOk
		//-------------------------------
		//faz a EXCLUSAO do pedido
		//-----------------------------

		lRet:=PROC_MOV(PD_EXCLUIR)

		If lRet

			::SetResponse('{')
			::SetResponse('"code":"0",')
			::SetResponse('"message":"EXCLUIDA"')
			::SetResponse('}')

		ELSE
			SetRestFault(114, "Erro ao EXCLUIR a Estrutura ."  )
		End
	EndIf
Return( lOk )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �VLD_JSON     � Autor � Manoel Mariante       � Data � nov/19 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao que valida os dados do JSON enviados para           ���
���          � manutencao da informacao                                   ���
���          �                                                            ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VLD_JSON(nOper)
	Local lOk := .T.
	Local aArea:=GetArea()

	If nOper=PD_ALTERAR

		dbSelectArea("SG1")
		dbSetOrder(1)
		If !dbSeek( xFilial("SG1") + PadR( oJson:G1_COD, TamSX3("G1_COD")[01] ) )
			lOk := .F.
			SetRestFault( 112, "Estrutura "+oJson:G1_COD+" nao cadastrada" )
		EndIf
	END

	If nOper=PD_INCLUIR

		dbSelectArea("SG1")
		dbSetOrder(1)
		If dbSeek( xFilial("SG1") + PadR( oJson:G1_COD, TamSX3("G1_COD")[01] ) )
			lOk := .F.
			SetRestFault( 113, "Estrutura "+oJson:G1_COD+" ja cadastrada" )
		EndIf
	END
	If nOper=PD_EXCLUIR

		dbSelectArea("SG1")
		dbSetOrder(1)
		If !dbSeek( xFilial("SG1") + cCodSG1 )
			lOk := .F.
			SetRestFault( 112, "Estrutura "+cCodSG1+" nao existe" )
		EndIf
	END

	If nOper=PD_ALTERAR.or.nOper=PD_INCLUIR
		If  Empty(oJson:G1_COD).or.;
				Empty(oJson:G1_QUANT)
			lOk := .F.
			SetRestFault( 104, "Existem campos obrigat�rios no cabe�alho que n�o foram preenchidos." )
		End

		//+---------------------------------------+
		//| Verifica se o cliente esta cadastrado |
		//+---------------------------------------+
		dbSelectArea("SB1")
		dbSetOrder(1)
		If !dbSeek( xFilial("SB1") + PadR( oJson:G1_COD, TamSX3("G1_COD")[01] )  )
			lOk := .F.
			SetRestFault( 103, "Produto nao cadastrado." )
		EndIf

		For nX := 1 To Len( oJson:itens )

			IF CTOD(oJson:itens[nX]:G1_INI) > CTOD(oJson:itens[nX]:G1_FIM)
				lOk := .F.
				SetRestFault( 116, "Data Final menor que Data Inicial" )
			END


			IF EMPTY(oJson:itens[nX]:G1_COMP)
				lOk := .F.
				SetRestFault( 106, "Componente n�o informado" )
			END

			IF oJson:itens[nX]:G1_QUANT == 0
				lOk := .F.
				SetRestFault( 107, "Quantidade do componente n�o informado" )
			END

			cAuxProd:=PadR( oJson:itens[nX]:G1_COMP, TamSX3("G1_COMP")[01] )

			dbSelectArea('SB1')
			dbSetOrder(1)
			IF !dbSeek(xFilial('SB1')+cAuxProd)
				lOk := .F.
				SetRestFault( 106, "Produto "+cAuxProd+" N�o Encontrado" )
			End

		Next
	End
	RestArea(aArea)
Return lOk

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �PROC_MOV    � Autor � Manoel Mariante       � Data � nov/19 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao que faz a insercao/alteracao/exclusoa do            ���
���          � da rotina                                                  ���
���          �                                                            ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function PROC_MOV(nOper)
	Local aCabec:={}
	Local aItens:={}
	Local aLinha:={}
	Local cErro := ""
	Local aMsg  :={}
	Local aMsgB
	Local cMsgErro
	lOCAL lOk 	 := .t.

	If nOper<>PD_EXCLUIR

		aAdd( aCabec,{"G1_COD"  	, PadR( oJson:G1_COD, TamSX3("G1_COD")[01] ),NIL})
		aAdd( aCabec,{"G1_QUANT"  	, oJson:G1_QUANT							,NIL})
		aAdd( aCabec,{"NIVALT"		,"S"										,NIL})

		For nX := 1 To Len( oJson:itens )
			aLinha:={}

			aAdd( aLinha,{"G1_COD"   , PadR( oJson:itens[nX]:G1_COD  , TamSX3("G1_COD")[01] )	, NIL})
			aAdd( aLinha,{"G1_COMP"  , PadR( oJson:itens[nX]:G1_COMP , TamSX3("G1_COMP")[01] )	, NIL})
			aAdd( aLinha,{"G1_TRT"   , oJson:itens[nX]:G1_TRT   	, NIL})
			aAdd( aLinha,{"G1_QUANT" , oJson:itens[nX]:G1_QUANT 	, NIL})
			aAdd( aLinha,{"G1_PERDA" , oJson:itens[nX]:G1_PERDA   	, NIL})
			aAdd( aLinha,{"G1_INI"   , CTOD(oJson:itens[nX]:G1_INI), NIL})
			aAdd( aLinha,{"G1_FIM"   , CTOD(oJson:itens[nX]:G1_FIM), NIL})
			aAdd( aLinha,{"G1_OBSERV", oJson:itens[nX]:G1_OBSERV   	, NIL})

			aAdd( aItens, aLinha )

		Next nX
	ELSE
		aAdd( aCabec,{"G1_COD"  	, SG1->G1_COD	,NIL})
		aAdd( aCabec,{"G1_QUANT"  	, SG1->G1_QUANT	,NIL})
		aAdd( aCabec,{"NIVALT"		,"S"			,NIL})

		/*WHILE SG1->G1_COD==cCodSG1.AND.!EOF()
			aLinha:={}
			
		    aAdd( aLinha,{"G1_COD"   , PadR( oJson:itens[nX]:G1_COD  , TamSX3("G1_COD")[01] )	, NIL})  
		    aAdd( aLinha,{"G1_COMP"  , PadR( oJson:itens[nX]:G1_COMP , TamSX3("G1_COMP")[01] )	, NIL})
		    aAdd( aLinha,{"G1_TRT"   , oJson:itens[nX]:G1_TRT   	, NIL})
		    aAdd( aLinha,{"G1_QUANT" , oJson:itens[nX]:G1_QUANT 	, NIL})
		    aAdd( aLinha,{"G1_PERDA" , oJson:itens[nX]:G1_PERDA   	, NIL})
		    aAdd( aLinha,{"G1_INI"   , CTOD(oJson:itens[nX]:G1_INI), NIL})                                                                                     
		    aAdd( aLinha,{"G1_FIM"   , CTOD(oJson:itens[nX]:G1_FIM), NIL}) 						    	
			aAdd( aLinha,{"G1_OBSERV", oJson:itens[nX]:G1_OBSERV   	, NIL})
			
			aAdd( aItens, aLinha )
	
	Next nX
		*/

END
lMsErroAuto    := .F.
lAutoErrNoFile := .T.

MSExecAuto( {|x,y,z| MATA200(x,y,z)}, aCabec, aItens, nOper )//3- Inclus�o, 4- Altera��o, 5- Exclus�o

If lMsErroAuto



	aMsg := GetAutoGRLog()
	aEval(aMsg,{|x| cErro += x + CRLF })

	lOk := .F.

	If Empty(aMsg)
		cMsgErro := "Erro n�o Identificado - Protheus (execauto MATA200)"
	Else
		//Carrega somente primeiras linhas do erro
		aMsgB      := StrTokArr(aMsg[1], CRLF)
		If Len(aMsgB) >= 2
			cMsgErro := aMsg[1] + " - " + aMsg[2]
		Else
			cMsgErro := SUBSTR(aMsgB[1],1,TamSX3("Z1_RETORNO")[1]) + "..."
		Endif

	Endif

	u_LogInteg("TEDA200","Erro","SG1","Erro ao "+If(nOper==PD_INCLUIR,"Incluir",If(nOper==PD_ALTERAR,"Alterar","Excluir"))+" a Estrutura do Produto" ,cErro,cMsgErro,time())

	//u_LogConsole("TEDA410", "Erro n�o Identificado" + CRLF + cErro )
	SetRestFault(114, EncodeUTF8(cMsgErro + CRLF, "cp1252")   )

EndIf

Return lOk
