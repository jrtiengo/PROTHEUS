#Include "TOTVS.CH"
#include "topconn.ch"
#Include "RESTFUL.CH"

//Opcoes ExecAuto 
#Define PD_INCLUIR 3
#Define PD_ALTERAR 4
#Define PD_EXCLUIR 5

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    TEDX681     � Autor � Manoel Mariante       � Data � nov/19 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Servico Web service para manuten��o do                     ���
���          � APONTAMENTO PRODUCAO MODELO 2 - MATA681 - SH6              ���
���          �                                                            ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSRESTFUL TEDX681 DESCRIPTION "Apontamento de Produ��o Antigo"

	WSDATA H6_OP AS STRING
	WSDATA H6_OPERAC AS STRING
	WSDATA H6_DATAINI AS STRING
	WSDATA H6_HORAINI AS STRING
	WSDATA H6_DATAFIN AS STRING
	WSDATA H6_HORAFIN AS STRING
	WSDATA H6_RECURSO AS STRING
	WSDATA H6_QTDPROD AS FLOAT
	WSDATA H6_QTDPERD AS FLOAT
	WSDATA H6_DTAPONT AS STRING
	WSDATA H6_FERRAM AS STRING
	WSDATA H6_OFINFOB AS FLOAT
	WSDATA H6_IDINFOB AS FLOAT

//WSMETHOD GET DESCRIPTION "Listar Apontamento de Produ��o ." WSSYNTAX "/"
	WSMETHOD POST DESCRIPTION "Incluir Apontamento de Produ��o Antigo." WSSYNTAX "/"
//WSMETHOD PUT DESCRIPTION "Alterar Apontamento de Produ��o ." WSSYNTAX "/"
	WSMETHOD DELETE DESCRIPTION "Excluir Apontamento de Produ��o Antigo." WSSYNTAX "/"

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
WSMETHOD POST WSRECEIVE NULLPARAM WSSERVICE TEDX681

	Local lOk		:= .T.
	Local cBody		:= ::GetContent()
	Local cMsgErro
	Private oJson
	Private cRotina := 'TEDX681'
	Private nOper 	:= PD_INCLUIR
	Private aRestFault := {}

	cFilAnt := "0102"

	::SetContentType("application/json")//Define o tipo de retorno do metodo

	u_LogConsole(cRotina, "Entrei " + cRotina + "- POST")
	u_LogInteg(cRotina,'Info',"SH6","",cBody,"Acessando " + cRotina + " - M�todo POST",'')

	If !FWJsonDeserialize(cBody,@oJson)//Converte a Apontamento de Produ��o Json em Objeto

		lOk := .F.
		SetRestFault( 101, "Nao foi possivel processar Json." )
		u_LogInteg(cRotina,'Erro',"SH6","",cBody,"Nao foi possivel processar JSON",'')

	Else
		//-------------------------------
		//valida os dados do JSON
		//-----------------------------
		lOk:=VLD_JSON()

	EndIf

	If lOk

		aRet:=PROC_MOV()

		If aRet[1]

			::SetResponse('{')
			::SetResponse('"code":"0",')
			::SetResponse('"message":"INCLUIDO"')

			::SetResponse('}')

		ELSE
			If !Empty(aRestFault)
				SetRestFault( aRestFault[1],EncodeUTF8(aRestFault[2], "cp1252")  )
				lOk := .F.
			Else
				cMsgErro := "Erro ao incluir o apontamento de producao ."+aRet[2]
				SetRestFault( 115, EncodeUTF8(cMsgErro, "cp1252")  )
				u_LogInteg(cRotina,'Erro',"SH6","",cBody,EncodeUTF8(aRet[2], "cp1252") ,'')
				lOk := .F.
			Endif
		EndIf

	EndIf

Return( lOk )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Metodo    � DELETE   �Autor  � Manoel Mariante    � Data �  Nov/2019   ���
�������������������������������������������������������������������������͹��
���Desc.     � Metodo para deletar                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
WSMETHOD DELETE WSRECEIVE NULLPARAM WSSERVICE TEDX681

	Local lOk		:= .T.
	Local cBody		:= ::GetContent()
	Private oJson

	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile := .T.
	Private cRotina := 'TEDX681'
	Private nOper 	:= PD_EXCLUIR
	Private aRestFault := {}

	cFilAnt := "0102"

	::SetContentType("application/json")//Define o tipo de retorno do metodo

	u_LogConsole(cRotina, "Entrei " + cRotina + " - M�todo DELETE")
	u_LogInteg(cRotina,'Info',"SH6","",cBody,"Acessando " + cRotina + "  - M�todo DELETE",'')

	If !FWJsonDeserialize(cBody,@oJson)//Converte a Apontamento de Produ��o Json em Objeto

		lOk := .F.
		SetRestFault( 101, "Nao foi possivel processar Json." )
		u_LogInteg(cRotina,'Erro',"SH6","",cBody,"Nao foi possivel processar Json.",'')

	Else
		//-------------------------------
		//valida os dados do JSON
		//-----------------------------
		lOk:=VLD_JSON()

	EndIf

	If lOk
		aRet:=PROC_MOV()

		If aRet[1]

			::SetResponse('{')
			::SetResponse('"code":"0",')
			::SetResponse('"message":"ESTORNADO"')

			::SetResponse('}')

		ELSE
			If !Empty(aRestFault)
				SetRestFault( aRestFault[1],aRestFault[2] )
			Else
				SetRestFault(115, "Erro ao estornar o apontamento de producao ."+aRet[2]  )
				u_LogInteg(cRotina,'Erro',"SH6","",cBody,"Erro ao estornar o apontamento de producao",'')
			Endif
		EndIf


	EndIf
Return( lOk )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �VLD_JSON    � Autor � Manoel Mariante       � Data � nov/19 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao que valida os dados do JSON enviados para           ���
���          � manutencao da informacao                                   ���
���          �                                                            ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function VLD_JSON()
	Local lOk           := .T.
	Local aArea         := GetArea()
	Local cDescErro     := 'Erro N�o Listado'
	Local lOPFinalizada := .F.
	Local lCriaOP       := .T.
	Local lFoundG1      := .F.
	Local lProdIntermed := .F.
	Local nPrcPRM       := SuperGetMV("MV_PERCPRM",.f.,0) //Percentual de Produ��o a Mais permitido
	Local dMVUlmes      := SUPERGETMV("MV_ULMES",.f.,SPACE(8))
	Local lJaApontou	:= .F.

	If nOper=PD_ALTERAR.or.nOper=PD_INCLUIR

		//Localiza Estrutra
		dbSelectArea("SG1")
		dbSetOrder(1) //G1_FILIAL+G1_COD+G1_COMP+G1_TRT
		lFoundG1 := MSSeek( xFilial("SG1") + PadR(oJson:H6_PRODUTO, TamSX3("G1_COD")[01] ))

		//Se encontrou como Produto e encontrou componente � Produto Intermedi�rio
		dbSelectArea("SG1")
		dbSetOrder(2) //G1_FILIAL+G1_COMP+G1_COD
		SG1->(DBGoTop())
		If lFoundG1 .AND.  MSSeek( xFilial("SG1") + PadR(oJson:H6_PRODUTO, TamSX3("G1_COD")[01] ))
			lProdIntermed := .T.
		Endif




		/*
			Local X_PRODUTO := 1
			Local X_EMISSAO := 2
			Local X_QUANT	:= 3
			Local X_DATPRI	:= 4
			Local X_OFINFOB := 5
			Local X_DATPRF 	:= 6
			Local X_OBS		:= 7

			aOp:={}
		*/

		lJaApontou := JaApontou()
		//retorna numero da OP do Protheus e Quantidade Original (c2_quant)
		//aOP		:=	u_fOPbyOF(oJson:H6_OFINFOB) // u_fOPbyOF(oJson:H6_OFINFOB,aOPNew) //Cria OP caso n�o exista
		aOP		:=	u_fOPbyOF(oJson:H6_OFINFOB,lCriaOP) //Cria OP caso n�o exista



		If EMPTY(aOP[1])

			If lProdIntermed
				lOk := .F.
				cDescErro:="Ignorado: OF " + alltrim(str(oJson:H6_OFINFOB)) + ". Produto intermedi�rios s�o ignorados. Cod." + oJson:H6_PRODUTO
				SetRestFault( 112, EncodeUTF8(cDescErro, "cp1252") )
				u_LogInteg(cRotina,'Alerta',"SH6",alltrim(str(oJson:H6_OFINFOB)),'',cDescErro,time())

			Else
				lOk := .F.
				cDescErro:= "Critica: OF " + alltrim(str(oJson:H6_OFINFOB)) + ".  N�o existe OF e n�o foi poss�vel ser criada via Refer�ncia do PV."
				SetRestFault( 110, EncodeUTF8(cDescErro, "cp1252") )
				u_LogInteg(cRotina,'Erro',"SH6",alltrim(str(oJson:H6_OFINFOB)),'',cDescErro,time())
			Endif
		Else
			cNumOP	:=	aOP[1]
			nQtdOP	:=	aOP[2]
			nSldOP	:=	aOP[3]
			nQtdJE	:=  nQtdOP - nSldOP

			lOPFinalizada := aOP[4]

			DO CASE

			CASE dMVUlmes >= ctod(oJson:H6_DATAINI)
				lOk := .F.
				cDescErro:="Ignorado: OF " + alltrim(str(oJson:H6_OFINFOB)) + ". Apontamento. DtApon " + oJson:H6_DATAINI + ". Per�odo Fechado em " + DTOC(dMVUlmes)+"."
				SetRestFault( 112, EncodeUTF8(cDescErro, "cp1252") )
				u_LogInteg(cRotina,'Alerta',"SH6",alltrim(str(oJson:H6_OFINFOB)),'',cDescErro,time())

			CASE lJaApontou
				lOk := .F.
				cDescErro:="Ignorado: OF " + alltrim(str(oJson:H6_OFINFOB)) + ". Apontamento IdUnico " + AllTrim(STR(oJson:H6_IDINFOB)) + " ja integrado anteriormente."
				SetRestFault( 112, EncodeUTF8(cDescErro, "cp1252") )
				//u_LogInteg(cRotina,'Alerta',"SH6",alltrim(str(oJson:H6_OFINFOB)),'',cDescErro,time())

			CASE lOPFinalizada
				lOk := .F.
				cDescErro:="Ignorado: OF " + alltrim(str(oJson:H6_OFINFOB)) + ". (OP Protheus " + cNumOP + ") ja finalizada."
				SetRestFault( 112, EncodeUTF8(cDescErro, "cp1252") )
				u_LogInteg(cRotina,'Alerta',"SH6",alltrim(str(oJson:H6_OFINFOB)),'',cDescErro,time())

			CASE !lFoundG1
				lOk := .F.
				cDescErro:="Critica: OF " + alltrim(str(oJson:H6_OFINFOB)) + ". N�o existe estrutura cadastrada no Protheus para o Produto " + AllTrim(oJson:H6_PRODUTO)
				SetRestFault( 112, EncodeUTF8(cDescErro, "cp1252") )
				u_LogInteg(cRotina,'Erro',"SH6",alltrim(str(oJson:H6_OFINFOB)),'',cDescErro,time())

			CASE !EMPTY(oJson:H6_RECURSO)
				dbSelectArea("SH1")
				dbSetOrder(1)
				If !dbSeek( xFilial("SH1") + PadR( oJson:H6_RECURSO, TamSX3("H6_RECURSO")[01] ) )
					lOk := .F.

					cDescErro:= "Critica: OF " + alltrim(str(oJson:H6_OFINFOB)) + ".(OP Protheus " + cNumOP + ") Recurso "+oJson:H6_RECURSO+" n�o existe"
					SetRestFault(113, EncodeUTF8(cDescErro, "cp1252") )
					u_LogInteg(cRotina,'Erro',"SH6",alltrim(str(oJson:H6_OFINFOB)),'',cDescErro,time())

				EndIf


			CASE !EMPTY(oJson:H6_FERRAM)
				dbSelectArea("SH4")
				dbSetOrder(1)
				If !dbSeek( xFilial("SH4") + PadR( oJson:H6_FERRAM, TamSX3("H6_FERRAM")[01] ) )
					lOk := .F.

					cDescErro:= "Critica: OF " + alltrim(str(oJson:H6_OFINFOB)) + ". (OP Protheus " + cNumOP + ") Ferramenta "+oJson:H6_FERRAM+" n�o existe"
					SetRestFault(114, EncodeUTF8(cDescErro, "cp1252") )
					u_LogInteg(cRotina,'Erro',"SH6",alltrim(str(oJson:H6_OFINFOB)),'',cDescErro,time())

				EndIf
			CASE (nQtdJE + oJson:H6_QTDPROD) > (nQtdOP * (1 + nPrcPRM/100))
				lOk := .F.

				cDescErro:= "Critica: OF " + alltrim(str(oJson:H6_OFINFOB)) + ". (OP Protheus " + cNumOP + ") Quantidade apontada a maior de " + AllTrim(Str(oJson:H6_QTDPROD)) + " supera limite definido no par�metro MV_PERCPRM."
				SetRestFault(112, EncodeUTF8(cDescErro, "cp1252") )
				u_LogInteg(cRotina,'Erro',"SH6",alltrim(str(oJson:H6_OFINFOB)),'',cDescErro,time())

			CASE !OPComEmp(cNumOP)

				lOk := .F.
				cDescErro:="Critica: OF "+ AllTrim(STR(oJson:H6_OFINFOB)) +". (OP Protheus " + cNumOP + ") N�o teve os empenhos/OPs intermediarias Criadas. Corrija a Estrutura do Produto. Exclua a OP. Re-Integre apontamento da OF."
				SetRestFault( 112, EncodeUTF8(cDescErro, "cp1252") )
				u_LogInteg(cRotina,'Erro',"SH6",alltrim(str(oJson:H6_OFINFOB)),'',cDescErro,time())


			ENDCASE
		Endif
	EndIf

	If lOk .AND. (nOper=PD_EXCLUIR .or. nOper=PD_ALTERAR)

		//retorna numero da OP do Protheus e Quantidade Original (c2_quant)
		aOP:=u_fOPbyOF(oJson:H6_OFINFOB)
		cNumOP:=aOP[1]
		nQtdOP:=aOP[2]
		nSldOP:=aOP[3]

		dbSelectArea('SH6')
		dbSetOrder(1)

		cChave:=cNumOP												+;
			PadR(oJson:H6_PRODUTO	, 15)		+;
			PadR(oJson:H6_OPERAC 	, 2)						+;
			SPACE(2)											+;
			DTOS(ctod(oJson:H6_DATAINI))						+;
			PadR(oJson:H6_HORAINI	, 5)						+;
			DTOS(ctod(oJson:H6_DATAFIN))						+;
			PadR(oJson:H6_HORAFIN	, 5)

		If !dbSeek( xFilial("SH6") + cChave )
			cDescErro:="Apontamento de Produ��o n�o cadastrado. CHAVE="+cChave
			u_LogInteg(cRotina,'Erro',"SH6",alltrim(str(oJson:H6_OFINFOB)),'',cDescErro,time())
			lOk := .F.
			SetRestFault( 112, "Apontamento de Produ��o n�o cadastrado. CHAVE="+cChave )
		EndIf
	EndIf

	If lOK .AND. (nOper=PD_ALTERAR.or.nOper=PD_INCLUIR)
		If  Empty(oJson:H6_OFINFOB).or.;
				Empty(oJson:H6_HORAINI).or.;
				Empty(oJson:H6_HORAFIN).or.;
				Empty(oJson:H6_QTDPROD).or.;
				Empty(oJson:H6_DTAPONT)
			cDescErro:="Campos obrigat�rios n�o foram preenchidos."
			u_LogInteg(cRotina,'Erro',"SH6",alltrim(str(oJson:H6_OFINFOB)),'',cDescErro,time())

			lOk := .F.
			SetRestFault( 104, "Existem campos obrigat�rios no cabe�alho que n�o foram preenchidos." )

		EndIf
	EndIf
	RestArea(aArea)
Return lOk


/*/{Protheus.doc} JaApontou
Verifica identificar �nico do infobox para determinar se j� ocorreu o apontamento de produ��o
@type function
@version  
@author solutio
@since 01/10/2021
@return variant, return_description
/*/
Static Function JaApontou()
	Local lRet := .F.
	Local  cTRB := GetNextAlias()

	//N�o executa verifica��o se n�o existir passagem do campo no Json
	If Type("oJson:H6_IDINFOB") == 'U'
		Return .F.
	Endif

	If !Empty(oJson:H6_IDINFOB)
		cSQL := "SELECT TOP 1  '1'  AS ACHOU FROM " + RetSqlName("SH6") + " WHERE H6_FILIAL = '" + xFilial("SH6") + "' AND H6_IDINFOB = " + AllTrim(STR(oJson:H6_IDINFOB)) + " AND D_E_L_E_T_ = ' '"
		MPSysOpenQuery( cSql, cTRB )

		IF (cTRB)->(!EOF())
			lRet := .T.
		Endif
		(cTRB)->(DBCloseArea())

	Endif
Return lRet

Static Function OpComEmp(cOP)

	Local aAreaSD4 := SD4->(GetArea())
	Local lReturn  := .T.

	dbSelectArea("SD4")
	dbSetOrder(2)
	lReturn := SD4->(MsSeek(xFilial("SD4")+cOp))

	RestArea(aAreaSD4)

Return lReturn


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
Static Function PROC_MOV()
	Local aCabec:={}
	Local cErro := ""
	Local aMsg  :={}
	Local aMsgB

	Local cNumOP    := ""
	Local nQtdOP    := 0
	Local nSldOP    := 0
	Local nAponQtd  := 0
	Local lPRODAUT := SUPERGETMV("MV_PRODAUT",.F.,.T.) //Apontas OP�s intermedi�rias segundo o apontamento da OP Pai

	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.
	Private cMsgErro
	Private lOk       := .t.


	Private nPropPAI	:= 0 //Qtuantidade Propor��o do PAI que est� sendo apontada

	Begin Transaction
		//retorna numero da OP do Protheus e Quantidade Original (c2_quant)
		aOP:=u_fOPbyOF(oJson:H6_OFINFOB)
		cNumOP:=aOP[1]
		nQtdOP:=aOP[2]
		nSldOP:=aOP[3]
		nRecno:=aOP[5] //recno da tabela sc2

		//IF oJson:H6_QTDPROD > nSldOP
		//	nAponQtd:=nSldOP
		//Else
		nAponQtd:=oJson:H6_QTDPROD
		//EndIf

		nPropPAI := nAponQtd/nQtdOP  // propor��o Percentual apontado

		If lPRODAUT
			DBSelectArea("SC2")
			dbSetOrder(1)
			SC2->(DBGoto(nRecno))

			u_fAponFilh(SC2->C2_NUM,SC2->C2_PRODUTO,SC2->C2_SEQUEN,nPropPAI)

		Endif

		// Antes de Apontar o PAI, aponta os filhos

		aAdd( aCabec,{"H6_OP"      , cNumOP					,NIL})
		aAdd( aCabec,{"H6_OPERAC"  , oJson:H6_OPERAC		,NIL})
		aAdd( aCabec,{"H6_FERRAM"  , oJson:H6_FERRAM		,NIL})
		aAdd( aCabec,{"H6_DATAINI" , cTOD(oJson:H6_DATAINI),NIL})
		aAdd( aCabec,{"H6_HORAINI" , oJson:H6_HORAINI		,NIL})
		aAdd( aCabec,{"H6_DATAFIN" , CTOD(oJson:H6_DATAFIN),NIL})
		aAdd( aCabec,{"H6_HORAFIN" , oJson:H6_HORAFIN		,NIL})
		//aAdd( aCabec,{"H6_RECURSO"  , oJson:H6_RECURSO		,NIL})
		aAdd( aCabec,{"H6_QTDPROD"  , nAponQtd      		,NIL})
		aAdd( aCabec,{"H6_QTDPERD"  , oJson:H6_QTDPERD		,NIL})
		aAdd( aCabec,{"H6_DTAPONT"  , CTOD(oJson:H6_DTAPONT),NIL} )
		If Type("oJson:H6_IDINFOB") <> 'U'
			aAdd( aCabec,{"H6_IDINFOB"  , oJson:H6_IDINFOB,NIL} )
			aAdd( aCabec,{"H6_PT"  , 'P',NIL} ) // Quando apontamento por id �nico aponta sempre mantendo a OP aberta (apontamento parcial)
		Endif 

		//N�o utiliza o recurso em caso de erro de gerar apontamento Pendente na T4K
		// 1 - N�o gera apontamento pendente
		// 2 - Faz Apontamento Pendente somente se houver Erros. [padr�o]
		// 3 - Sempre Pendente - todos os apontamentos ficam como pendente

		aAdd(aCabec,{"PENDENTE","1",Nil}) // doc: https://centraldeatendimento.totvs.com/hc/pt-br/articles/360051976953-MP-ADVPL-Apontamentos-Pendentes-Tabela-T4K

		dDataBase:=CTOD(oJson:H6_DTAPONT)

		u_LogConsole(cRotina, "vou processar apontamento")

		MSExecAuto( {|x,y| MATA681(x,y)}, aCabec, nOper )//3- Inclus�o, 4- Altera��o, 5- Exclus�o

		If lMsErroAuto

			aMsg := GetAutoGRLog()
			aEval(aMsg,{|x| cErro += x + CRLF })

			lOk := .F.

			If Empty(aMsg)
				cMsgErro := "Erro n�o Identificado - Protheus (execauto MATA681)"
			Else
				//Carrega somente primeiras linhas do erro
				aMsgB      := StrTokArr(aMsg[1], CRLF)
				If Len(aMsgB) >= 2
					cMsgErro := aMsgB[1] + " - " + aMsgB[2]
				Else
					cMsgErro := SUBSTR(aMsgB[1],1,TamSX3("Z1_RETORNO")[1]) + "..."
				Endif

				cMsgErro := STRTRAN(cMsgErro,":", "-") // retira dois pontos
				cMsgErro := FwCutOff(cMsgErro, .t.)
			Endif

			//Roolback da Transa��o
			DisarmTransaction()

			u_LogInteg(cRotina,"Erro","SH6",alltrim(str(oJson:H6_OFINFOB)),cErro,cMsgErro,time())

			//u_LogConsole("TEDA410", "Erro n�o Identificado" + CRLF + cErro )

			If Empty(aRestFault)
				aRestFault := {102,cMsgErro} // retira caracteres especiais do texto
			Endif
			Break
		else
			u_LogInteg(cRotina,"Info","SH6",alltrim(str(oJson:H6_OFINFOB)),'', IIF(nOper == PD_EXCLUIR, "Estorno de ","") +  "Apontamento Realizado. Qtd = "+ AllTrim(TRANSFORM(nAponQtd,"@E 99,999.9999")),time())
		Endif
	End Transaction

	If !Empty(aRestFault)
		Return {.F.,aRestFault[2]}
	Endif

Return {lOk,cErro}


