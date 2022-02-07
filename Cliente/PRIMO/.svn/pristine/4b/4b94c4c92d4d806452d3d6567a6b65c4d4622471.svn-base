#Include "TOTVS.CH"
#Include "RESTFUL.CH"
//Opcoes ExecAuto 
#Define PD_INCLUIR 3
#Define PD_ALTERAR 4
#Define PD_EXCLUIR 5
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณTEDA650     ณ Autor ณ Manoel Mariante       ณ Data ณ nov/19 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Servico Web service para manuten็ใo do cadastro de         ณฑฑ
ฑฑณ          ณ ORDEM DE PRODUCAO - MATA650 -                              ณฑฑ
ฑฑณ          ณ                                                            ณฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
WSRESTFUL TEDA650 DESCRIPTION "Manuten็ใo de Ordens de Produ็ใo"

	WSDATA C2_PRODUTO	AS STRING
	WSDATA C2_EMISSAO	AS STRING
	WSDATA C2_QUANT		AS FLOAT
	WSDATA C2_DATPRI	AS STRING
	WSDATA C2_DATPRF	AS STRING
	WSDATA C2_OBS 		AS STRING
	WSDATA C2_NUM		AS STRING
	WSDATA C2_ITEM		AS STRING
	WSDATA C2_SEQUEN	AS STRING
	WSDATA C2_OFINFOB	AS FLOAT

//WSMETHOD GET DESCRIPTION "Listar Pedido de Compra." WSSYNTAX "/"
	WSMETHOD POST DESCRIPTION "M้todo para inclusใo de Ordem de Produ~]ao" WSSYNTAX "/"
	WSMETHOD PUT DESCRIPTION "M้todo para altera็ใo de Ordem de Produ~]ao" WSSYNTAX "/"
	WSMETHOD DELETE DESCRIPTION "M้todo para exclusใo de Ordem de Produ~]ao" WSSYNTAX "/[num]/[item]/[sequen]"

END WSRESTFUL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณ POST     บAutor  ณ Manoel Mariante    บ Data ณ  Nov/2019   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Metodo para incluir OP                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
WSMETHOD POST WSRECEIVE NULLPARAM WSSERVICE TEDA650

	//Local lPRODAUT  := SUPERGETMV("MV_PRODAUT",.F.,.T.) //Apontas OPดs intermediแrias segundo o apontamento da OP Pai
	Local lDisable  := .T. //Desabilita funcionalidade nใo realizando o procedimento do M้todo
	Local lOk		:= .T.
	Local cBody		:= ::GetContent()

	Local cErro 	:= ""
	Local cMsgErro := ""
	Local aMsg  :={}
	Local aMsgB

	Local aCabec	:= {}


	Private oJson

	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.

	Private __nnLock
	Private __CCARQ



	IF lDisable
		u_LogConsole("TEDA650", "Entrei TEDA650, M้todo POST (modo desabilitado)")
		Return( lOk )
	Endif


	u_LogConsole("TEDA650", "Entrei TEDA650, M้todo POST")

	::SetContentType("application/json")//Define o tipo de retorno do metodo

	If !FWJsonDeserialize(cBody,@oJson)//Converte a estrutura Json em Objeto

		lOk := .F.
		SetRestFault( 101, "Nao foi possivel processar a estrutura Json." )
		u_LogConsole("TEDA650", "JSON COM PROBLEMA")

	Else

		u_LogInteg("TEDA650","Acessando TEDA650 - M้todo POST","SC2",oJson:C2_OFINFOB,cBody,"","")

		If  Empty(oJson:C2_PRODUTO).or.;
				Empty(oJson:C2_EMISSAO).or.;
				Empty(oJson:C2_QUANT).or.;
				Empty(oJson:C2_DATPRI).or.;
				Empty(oJson:C2_OFINFOB).or.;
				Empty(oJson:C2_DATPRF)
			lOk := .F.
			
			cMsgErro := "Existem campos obrigat๓rios que nใo foram preenchidos."
			SetRestFault( 1,  EncodeUTF8(cMsgErro, "cp1252")  )
			
			u_LogInteg("TEDA650","Existem campos obrigat๓rios que nใo foram preenchidos.","SC2","","","","")
		End

		IF CTOD(oJson:C2_DATPRF) < dDataBase
			lOk := .F.
			SetRestFault( 105, "Data de Entrega menor que DataBase." )
			u_LogInteg("TEDA650","Data de Entrega menor que DataBase.","SC2","","","","")
		End


		dbSelectArea('SB1')
		dbSetOrder(1)
		IF !dbSeek(xFilial('SB1')+PadR( oJson:C2_PRODUTO, TamSX3("C2_PRODUTO")[01] ))
			lOk := .F.
			cMsgErro := "Produto Nใo Cadastrado" 
			SetRestFault( 2,  EncodeUTF8(cMsgErro, "cp1252")  )
			
			u_LogInteg("TEDA650","Produto Nใo Cadastrado","SC2","","","","")
		EndIf

		iF !EMPTY(u_fOPbyOF(oJson:C2_OFINFOB)[1])
			lOk := .F.
			cMsgErro := "OF jแ existe" 
			SetRestFault( 106,  EncodeUTF8(cMsgErro, "cp1252")  )

			u_LogInteg("TEDA650","OF jแ exist","SC2","","","","")
		EndIf

		If !lOk
			Return( lOk )
		End


		aAdd(aCabec,{"C2_PRODUTO" , oJson:C2_PRODUTO		,NIL})
		aAdd(aCabec,{"C2_EMISSAO" , CTOD(oJson:C2_EMISSAO)	,NIL})
		aAdd(aCabec,{"C2_QUANT"   , oJson:C2_QUANT			,NIL})
		aAdd(aCabec,{"C2_DATPRI"  , CTOD(oJson:C2_DATPRI)	,NIL})
		aAdd(aCabec,{"C2_DATPRF"  , CTOD(oJson:C2_DATPRF)	,NIL})
		aAdd(aCabec,{"C2_OBS" 	   , oJson:C2_OBS			,NIL})
		aAdd(aCabec,{"AUTEXPLODE" , 'S'						,NIL})
		aAdd(aCabec,{"C2_OFINFOB"  , oJson:C2_OFINFOB		,NIL}) //campo novo

		MsExecAuto( {|x,y| Mata650( x, y ) }, aCabec, PD_INCLUIR )

		//lMsErroAuto    := .F.
		//lAutoErrNoFile := .T.

		If lMsErroAuto

			aMsg := GetAutoGRLog()
			aEval(aMsg,{|x| cErro += x + CRLF })

			lOk := .F.

			If Empty(aMsg)
				cMsgErro := "Erro nใo Identificado - Protheus (execauto Mata650)"
			Else
				//Carrega somente primeiras linhas do erro
				aMsgB      := StrTokArr(aMsg[1], CRLF)
				If Len(aMsgB) >= 2
					cMsgErro := aMsgB[1] + " - " + aMsgB[2]
				Else
					cMsgErro := SUBSTR(aMsgB[1],1,(TamSX3("Z1_RETORNO")[1])-3) + "..."
				Endif

			Endif

			u_LogInteg("TEDA650","Erro","SC2",alltrim(str(::C2_OFINFOB)),cErro,cMsgErro,time())

			u_LogConsole("TEDA650", "Erro SC2 -" + CRLF + cErro )
			SetRestFault(102, EncodeUTF8(cMsgErro, "cp1252")   )

		Else

			::SetResponse('{')
			::SetResponse('"C2_NUM":"'   +SC2->C2_NUM+'",')
			::SetResponse('"C2_ITEM":"'  +SC2->C2_ITEM+'",')
			::SetResponse('"C2_SEQUEN":"'+SC2->C2_SEQUEN+'"')
			::SetResponse('}')

			u_LogConsole("TEDA650", 'OP GERADA='+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN))
			u_LogInteg("TEDA650","OP GERADA="+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN),"SC2","","","","")

			u_fCargaG2(SC2->C2_PRODUTO)

			//If lPRODAUT
			//u_fOPCharge(SC2->C2_PRODUTO,SC2->C2_NUM,PD_INCLUIR)
			//Endif
		EndIf

	EndIf

Return( lOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณ PUT      บAutor  ณ Manoel Mariante    บ Data ณ  Nov/2019   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Metodo para alterar OP                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
WSMETHOD PUT WSRECEIVE NULLPARAM WSSERVICE TEDA650

	Local lDisable  := .T. //Desabilita funcionalidade nใo realizando o procedimento do M้todo
	Local lPRODAUT 	:= SUPERGETMV("MV_PRODAUT",.F.,.T.) //Apontas OPดs intermediแrias segundo o apontamento da OP Pai
	Local lOk		:= .T.
	Local cBody		:= ::GetContent()

	Local cErro := ""
	Local cMsgErro := ""
	Local aMsg  :={}
	Local aMsgB

	Local aCabec	:= {}
	Private oJson

	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.

	Private __nnLock
	Private __CCARQ


	IF lDisable
		u_LogConsole("TEDA650", "Entrei TEDA650, M้todo PUT (modo desabilitado)")
		Return( lOk )
	Endif
	u_LogConsole("TEDA650", "Entrei TEDA650, M้todo PUT ")

	::SetContentType("application/json")//Define o tipo de retorno do metodo

	If !FWJsonDeserialize(cBody,@oJson)//Converte a estrutura Json em Objeto

		lOk := .F.
		SetRestFault( 101, "Nao foi possivel processar a estrutura Json." )
		u_LogConsole("TEDA650", "JSON COM PROBLEMA")

	Else

		u_LogInteg("TEDA650","Acessando TEDA650 - M้todo PUT","SC2","",cBody,"","")

		If  Empty(oJson:C2_PRODUTO).or.;
				Empty(oJson:C2_EMISSAO).or.;
				Empty(oJson:C2_QUANT).or.;
				Empty(oJson:C2_OFINFOB).or.;
				Empty(oJson:C2_DATPRI).or.;
				Empty(oJson:C2_DATPRF)
			lOk := .F.
			SetRestFault( 104, "Existem campos obrigat๓rios que nใo foram preenchidos." )
			u_LogInteg("TEDA650","Existem campos obrigat๓rios que nใo foram preenchidos.","SC2","","","","")
		End

		dbSelectArea('SB1')
		dbSetOrder(1)
		IF !dbSeek(xFilial('SB1')+PadR( oJson:C2_PRODUTO, TamSX3("C2_PRODUTO")[01] ))
			lOk := .F.
			SetRestFault( 106, "Produto Nใo Cadastrado" )
			u_LogInteg("TEDA650","Produto Nใo Cadastrado","SC2","","","","")
		EndIf

		cNumOP:=u_fOPbyOF(oJson:C2_OFINFOB)[1]

		dbSelectArea('SC2')
		dbSetOrder(1)
		IF !dbSeek(xFilial('SC2')+cNumOP )

			lOk := .F.
			cMsgErro := "OP nใo encontrada"
			SetRestFault( 105,  EncodeUTF8(cMsgErro, "cp1252")  )

			u_LogInteg("TEDA650","OP nใo encontrada","SC2","","","","")
		EndIf

		If !lOk
			Return( lOk )
		End

		aAdd(aCabec,{"C2_NUM"	 	, SC2->C2_NUM,nil})
		aAdd(aCabec,{"C2_ITEM"		 ,SC2->C2_ITEM,nil})
		aAdd(aCabec,{"C2_SEQUEN" , SC2->C2_SEQUEN,nil})
		aAdd(aCabec,{"C2_PRODUTO" , oJson:C2_PRODUTO,nil})
		aAdd(aCabec,{"C2_EMISSAO" , ctod(oJson:C2_EMISSAO),nil})
		aAdd(aCabec,{"C2_QUANT"   , oJson:C2_QUANT,nil})
		aAdd(aCabec,{"C2_DATPRI"  , ctod(oJson:C2_DATPRI),nil})
		aAdd(aCabec,{"C2_DATPRF"  , ctod(oJson:C2_DATPRF),nil})
		aAdd(aCabec,{"C2_OBS" 	   , oJson:C2_OBS,nil})
		aAdd(aCabec,{"C2_OFINFOB"  , oJson:C2_OFINFOB,NIL}) //campo novo
		aAdd(aCabec,{"AUTEXPLODE" , 'S',NIL})

		MsExecAuto( {|x,y| Mata650( x, y ) }, aCabec, PD_ALTERAR )

		//lMsErroAuto    := .F.
		//lAutoErrNoFile := .T.

		If lMsErroAuto

			aMsg := GetAutoGRLog()
			aEval(aMsg,{|x| cErro += x + CRLF })

			lOk := .F.

			If Empty(aMsg)
				cMsgErro := "Erro nใo Identificado - Protheus (execauto Mata650)"
			Else
				//Carrega somente primeiras linhas do erro
				aMsgB      := StrTokArr(aMsg[1], CRLF)
				If Len(aMsgB) >= 2
					cMsgErro := aMsgB[1] + " - " + aMsgB[2]
				Else
					cMsgErro := SUBSTR(aMsgB[1],1,(TamSX3("Z1_RETORNO")[1])-3) + "..."
				Endif

			Endif

			u_LogInteg("TEDA650","Erro","SC2",alltrim(str(::C2_OFINFOB)),cErro,cMsgErro,time())

			u_LogConsole("TEDA650", "Erro SC2 -" + CRLF + cErro )
			SetRestFault(102, EncodeUTF8(cMsgErro, "cp1252")   )

		Else

			::SetResponse('{')
			::SetResponse('"STATUS"')
			::SetResponse(':')
			::SetResponse('"ALTERADA"')
			::SetResponse('}')

			u_LogConsole("TEDA650", 'OP ALTERADA='+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN))
			u_LogInteg("TEDA650","OP ALTERADA="+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN),"SC2","","","","")
			If lPRODAUT
				u_fOPCharge(SC2->C2_PRODUTO,SC2->C2_NUM,PD_ALTERAR)
			EndIf


		EndIf

	EndIf

Return( lOk )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณ DELETE   บAutor  ณ Manoel Mariante    บ Data ณ  Nov/2019   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Metodo para excluir OP                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
WSMETHOD DELETE WSRECEIVE C2_OFINFOB WSSERVICE TEDA650

	Local lDisable  := .T. //Desabilita funcionalidade nใo realizando o procedimento do M้todo
	Local lPRODAUT 	:= SUPERGETMV("MV_PRODAUT",.F.,.T.) //Apontas OPดs intermediแrias segundo o apontamento da OP Pai
	Local lOK		:= .T.

	Local cErro := ""
	Local cMsgErro := ""
	Local aMsg  :={}
	Local aMsgB

	Private oJson
	Private cBody		:= ::GetContent()
	Private lMsErroAuto := .F.


	IF lDisable
		u_LogConsole("TEDA650", "Entrei TEDA650, M้todo DELETE (modo desabilitado)")
		Return( lOk )
	Endif

	u_LogConsole("TEDA650", 'Entrei na rotina, M้todo DELETE')

	::SetContentType("application/json")	// define o tipo de retorno do m้todo

	//+-------------------------------------------------+
	//| Verifica se foi informado os parametros no link |
	//+-------------------------------------------------+
	If valtype(::C2_OFINFOB)='U' .OR. ::C2_OFINFOB==0 //!FWJsonDeserialize(cBody,@oJson)//Converte a estrutura Json em Objeto

		lOk := .F.
		SetRestFault( 101, "Nao foi informado o numero da OF do Infobox" )
		u_LogConsole("TEDA650", "Nao foi informado o numero da OF do Infobox")

	else

		//+-----------------------------+
		//| Verifica se existe  |
		//+-----------------------------+
		cNumOP:=u_fOPbyOF(::C2_OFINFOB)[1]

		dbSelectArea('SC2')
		dbSetOrder(1)
		IF !dbSeek(xFilial('SC2')+cNumOP)
			lOk := .F.
			cMsgErro := "OP nใo encontrada"
			SetRestFault(105, EncodeUTF8(cMsgErro, "cp1252")   )
			
		EndIf

	EndIf

	If lOK// Se todas as validacoes acima estiverem OK

		aAdd(aCabec,{"C2_NUM" 		, SC2->C2_NUM})
		aAdd(aCabec,{"C2_ITEM" 		, SC2->C2_ITEM})
		aAdd(aCabec,{"C2_SEQUEN"   ,  SC2->C2_SEQUEN})

		cProdExc	:=SC2->C2_PRODUTO
		cNumOpExc	:=SC2->C2_NUM

		MsExecAuto( {|x,y| Mata650( x, y ) }, aCabec, PD_EXCLUIR )

		//lMsErroAuto    := .F.
		//lAutoErrNoFile := .T.


		If lMsErroAuto

			aMsg := GetAutoGRLog()
			aEval(aMsg,{|x| cErro += x + CRLF })

			lOk := .F.

			If Empty(aMsg)
				cMsgErro := "Erro nใo Identificado - Protheus (execauto Mata650)"
			Else
				//Carrega somente primeiras linhas do erro
				aMsgB      := StrTokArr(aMsg[1], CRLF)
				If Len(aMsgB) >= 2
					cMsgErro := aMsgB[1] + " - " + aMsgB[2]
				Else
					cMsgErro := SUBSTR(aMsgB[1],1,(TamSX3("Z1_RETORNO")[1])-3) + "..."
				Endif

			Endif

			u_LogInteg("TEDA650","Erro","SC2",alltrim(str(::C2_OFINFOB)),cErro,cMsgErro,time())

			u_LogConsole("TEDA650", "Erro SC2 -" + CRLF + cErro )
			SetRestFault(102, EncodeUTF8(cMsgErro, "cp1252")   )

		Else

			::SetResponse('{')
			::SetResponse('"STATUS"')
			::SetResponse(':')
			::SetResponse('"EXCLUIDA"')
			::SetResponse('}')

			u_LogConsole("TEDA650", 'OP EXCLUIDA='+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN))

			If lPRODAUT
				u_fOPCharge(cProdExc,cNumOpExc,PD_EXCLUIR)
			Endif

		EndIf

	EndIf

Return(lOk)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณ fCarga   บAutor  ณ Manoel Mariante    บ Data ณ  Nov/2019   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ajusta cadastro de roteiro                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function fCargaG2(cProduto)
	Local aArea:=GetArea()
	Local cCodigo:='01'
	Local cOperac:='10'

	dbSelectArea('SG2')
	dbSetOrder(1)
	IF !dbSeek(xFilial('SG2')+cProduto+cCodigo+cOperac)
		RecLock('SG2',.t.)
		SG2->G2_FILIAL	:=XFILIAL('SG2')
		SG2->G2_CODIGO	:=cCodigo
		SG2->G2_PRODUTO	:=cProduto
		SG2->G2_OPERAC	:=cOperac
		SG2->G2_RECURSO	:='PALETI'
		SG2->G2_MAOOBRA	:=40
		SG2->G2_LOTEPAD	:=1000
		SG2->G2_TEMPAD	:=1
		SG2->G2_DESCRI	:='PALETIZACAO'
		msUnlock()
	End
	RestArea(aArea)

Return


/*/{Protheus.doc} fOPCharge
Cria OPดs Intermediแrias automaticamente na cria็ใo da OP PAI. 
@type function
@version 
@author Manoel Mariante
@since 01/11/2019
@param cProduto, character, param_description
@param cNumOP, character, param_description
@param nOper, numeric, param_description
@return return_type, return_description
/*/
User Function fOPCharge(cProduto,cNumOP,nOper)
	Local aArea  :=GetArea()
	Local cSequen:='001'
	//u_LogConsole("TEDA650", "ENTREI "+cProduto+'  '+cNumOP)

	dbSelectArea('SG1')
	dbSetOrder(1)
	dbSeek(xFilial('SG1')+cProduto)
	WHILE G1_FILIAL==xFilial('SG1') .AND. G1_COD==cProduto .AND. !EOF()
		//u_LogConsole("TEDA650", "ENTREI SG1 ")
		cSequen:=soma1(cSequen)

		fOpManage(cNumOP,SG1->G1_COMP,SG1->G1_QUANT,cSequen,nOper)

		dbskip()

	End
	RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบMetodo    ณ fOpManage  บAutor  ณ Manoel Mariante    บ Data ณ  Nov/2019   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ajusta cadastro de roteiro                                 บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fOpManage(cNum,cCod,nQuant,cSequen,nOper)
	Local lPRODAUT := SUPERGETMV("MV_PRODAUT",.F.,.T.) //Apontas OPดs intermediแrias segundo o apontamento da OP Pai
	Local aArea  :=GetArea()
	lOCAL lMsErroAuto:=.F.
//	LOCAL lAutoErrNoFile := .T.
	Local aCabec:={}

	Local cErro := ""
	Local cMsgErro := ""
	Local aMsg  :={}
	Local aMsgB


	If nOper==PD_ALTERAR .or. nOper==PD_EXCLUIR
		dbSelectArea("SC2")
		dbSetOrder(1)
		dbSeek(xFilial('SC2')+cNum+'01'+cSequen)
	End

	//u_LogConsole("TEDA650", "ENTREI CRIAOP ")
	aAdd(aCabec,{"C2_NUM" 	  , cNum					,NIL})
	aAdd(aCabec,{"C2_ITEM"	  , '01'					,NIL})
	aAdd(aCabec,{"C2_SEQUEN"  , cSequen					,NIL})
	If nOper==PD_ALTERAR .or. nOper==PD_INCLUIR
		aAdd(aCabec,{"C2_PRODUTO" , cCod					,NIL})
		aAdd(aCabec,{"C2_EMISSAO" , CTOD(oJson:C2_EMISSAO)	,NIL})
		aAdd(aCabec,{"C2_QUANT"   , oJson:C2_QUANT*nQuant	,NIL})
		aAdd(aCabec,{"C2_DATPRI"  , CTOD(oJson:C2_DATPRI)	,NIL})
		aAdd(aCabec,{"C2_DATPRF"  , CTOD(oJson:C2_DATPRF)	,NIL})
		aAdd(aCabec,{"C2_OBS" 	   , 'OP DE ACESSORIOS CRIADA AUTOMATICAMENTE'			,NIL})
		aAdd(aCabec,{"AUTEXPLODE" , 'S'						,NIL})
		//aAdd(aCabec,{"C2_OFINFOB"  , oJson:C2_OFINFOB		,NIL}) //campo novo
	End
	MsExecAuto( {|x,y| Mata650( x, y ) }, aCabec, nOper )

	If lMsErroAuto

		aMsg := GetAutoGRLog()
		aEval(aMsg,{|x| cErro += x + CRLF })

		lOk := .F.

		If Empty(aMsg)
			cMsgErro := "Erro nใo Identificado - Protheus (execauto Mata650)"
		Else
			//Carrega somente primeiras linhas do erro
			aMsgB      := StrTokArr(aMsg[1], CRLF)
			If Len(aMsgB) >= 2
				cMsgErro := aMsgB[1] + " - " + aMsgB[2]
			Else
				cMsgErro := SUBSTR(aMsgB[1],1,(TamSX3("Z1_RETORNO")[1])-3) + "..."
			Endif

		Endif

		u_LogInteg("TEDA650","Erro","SC2",alltrim(str(::C2_OFINFOB)),cErro,cMsgErro,time())

		u_LogConsole("TEDA650", "Erro SC2 -" + CRLF + cErro )
		SetRestFault(102, EncodeUTF8(cMsgErro, "cp1252")   )

	Else

		u_LogConsole("TEDA650", 'OP AUTOMATICA GERADA='+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN))
		If lPRODAUT
			u_fOPCharge(SC2->C2_PRODUTO,SC2->C2_NUM,nOper)
		Endif

	EndIf
	RestArea(aArea)

Return
