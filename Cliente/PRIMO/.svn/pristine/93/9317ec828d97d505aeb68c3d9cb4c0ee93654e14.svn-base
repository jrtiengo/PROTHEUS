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
±±³Funcao    ³TEDA681     ³ Autor ³ Manoel Mariante       ³ Data ³ nov/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Servico Web service para manutenção do                     ³±±
±±³          ³ APONTAMENTO PRODUCAO MODELO 2 - MATA681 - SH6              ³±±
±±³          ³                                                            ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSRESTFUL teda681 DESCRIPTION "Apontamentos DE Produções "

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

//WSMETHOD GET DESCRIPTION "Listar Apontamento de Produção ." WSSYNTAX "/"
	WSMETHOD POST DESCRIPTION "Incluir Apontamento de Produção  ." WSSYNTAX "/"
//WSMETHOD PUT DESCRIPTION "Alterar Apontamento de Produção ." WSSYNTAX "/"
	WSMETHOD DELETE DESCRIPTION "Excluir Apontamento de Produção  ." WSSYNTAX "/"

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
WSMETHOD POST WSRECEIVE NULLPARAM WSSERVICE teda681

	Local lOk		:= .T.
	Local cBody		:= ::GetContent()

	Private oJson
	Private cRotina := 'TEDA681'
	Private nOper 	:= PD_INCLUIR
	Private aRestFault := {}

	::SetContentType("application/json")//Define o tipo de retorno do metodo

	u_LogConsole(cRotina, "Entrei " + cRotina + " POST")
	u_LogInteg(cRotina,'Info',"SH6","",cBody,"Acessando " + cRotina + " - Método POST",'')

	If !FWJsonDeserialize(cBody,@oJson)//Converte a Apontamento de Produção Json em Objeto

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

			SetRestFault(115, "Erro ao incluir o apontamento de producao ."+aRet[2]  )

		EndIf

	EndIf

Return( lOk )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºMetodo    ³ DELETE   ºAutor  ³ Manoel Mariante    º Data ³  Nov/2019   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Metodo para deletar                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD DELETE WSRECEIVE NULLPARAM WSSERVICE teda681

	Local lOk		:= .T.
	Local cBody		:= ::GetContent()
	Private oJson

	Private lMsErroAuto 	:= .F.
	Private lAutoErrNoFile := .T.
	Private cRotina := 'TEDA681'
	Private nOper 	:= PD_EXCLUIR
	Private aRestFault := {}

	::SetContentType("application/json")//Define o tipo de retorno do metodo

	u_LogConsole(cRotina, "Entrei " + cRotina + " - Método DELETE")
	u_LogInteg(cRotina,'Info',"SH6","",cBody,"Acessando " + cRotina + "  - Método DELETE",'')

	If !FWJsonDeserialize(cBody,@oJson)//Converte a Apontamento de Produção Json em Objeto

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

			SetRestFault(115, "Erro ao estornar o apontamento de producao ."+aRet[2]  )

			u_LogInteg(cRotina,'Erro',"SH6","",cBody,"Erro ao estornar o apontamento de producao",'')
		EndIf


	EndIf
Return( lOk )

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
Static Function VLD_JSON()
	Local lOk := .T.
	Local aArea:=GetArea()
	Local cDescErro:='Erro Não Listado'


	If nOper=PD_ALTERAR.or.nOper=PD_INCLUIR



		cNumOP:=U_fOPbyOF(oJson:H6_OFINFOB)[1]
		//dbSelectArea("SC2")
		//dbSetOrder(1)
		DO CASE
		CASE EMPTY(cNumOP)
			lOk := .F.
			cDescErro:="Ordem de Produção "+ AllTrim(STR(oJson:H6_OFINFOB)) +" não existe"
			If Empty(aRestFault)
				aRestFault := {112,EncodeUTF8(cDescErro, "cp1252")}
			Endif

			u_LogInteg(cRotina,'Erro',"SH6",alltrim(str(oJson:H6_OFINFOB)),'',cDescErro,time())


		CASE !EMPTY(oJson:H6_RECURSO)
			dbSelectArea("SH1")
			dbSetOrder(1)
			If !dbSeek( xFilial("SH1") + PadR( oJson:H6_RECURSO, TamSX3("H6_RECURSO")[01] ) )

				lOk := .F.

				cDescErro:="Recurso "+oJson:H6_RECURSO+" não existe"
				If Empty(aRestFault)
					aRestFault := {113,EncodeUTF8(cDescErro, "cp1252")}
				Endif
				u_LogInteg(cRotina,'Erro',"SH6",alltrim(str(oJson:H6_OFINFOB)),'',cDescErro,time())

			EndIf


		CASE !EMPTY(oJson:H6_FERRAM)
			dbSelectArea("SH4")
			dbSetOrder(1)
			If !dbSeek( xFilial("SH4") + PadR( oJson:H6_FERRAM, TamSX3("H6_FERRAM")[01] ) )

				lOk := .F.

				cDescErro:="Ferramenta "+oJson:H6_FERRAM+" não existe"
				If Empty(aRestFault)
					aRestFault := {114,EncodeUTF8(cDescErro, "cp1252")}
				Endif
				u_LogInteg(cRotina,'Erro',"SH6",alltrim(str(oJson:H6_OFINFOB)),'',cDescErro,time())

			EndIf
		ENDCASE
	ENDIF

	If lOk .AND. (nOper=PD_EXCLUIR .or. nOper=PD_ALTERAR)

		cNumOP:=U_fOPbyOF(oJson:H6_OFINFOB)[1]

		dbSelectArea('SH6')
		dbSetOrder(1)
		//H6_OP+H6_PRODUTO+H6_OPERAC+H6_SEQ+DTOS(H6_DATAINI)+H6_HORAINI+DTOS(H6_DATAFIN)+H6_HORAFIN


		cChave:=cNumOP												+;
			PadR(oJson:H6_PRODUTO	, 15)		+;
			PadR(oJson:H6_OPERAC 	, 2)						+;
			SPACE(2)											+;
			DTOS(ctod(oJson:H6_DATAINI))						+;
			PadR(oJson:H6_HORAINI	, 5)						+;
			DTOS(ctod(oJson:H6_DATAFIN))						+;
			PadR(oJson:H6_HORAFIN	, 5)

		If !dbSeek( xFilial("SH6") + cChave )
			cDescErro:="Apontamento de Produção não cadastrado. CHAVE="+cChave
			u_LogInteg(cRotina,'Erro',"SH6",alltrim(str(oJson:H6_OFINFOB)),'',cDescErro,time())
			lOk := .F.
			If Empty(aRestFault)
				cDescErro :=  "Apontamento de Produção não cadastrado. CHAVE="+cChave
				aRestFault := {112,EncodeUTF8(cDescErro, "cp1252")}
			Endif
		EndIf
	ENDIF

	If lOk .AND. (nOper=PD_ALTERAR.or.nOper=PD_INCLUIR)
		If  Empty(oJson:H6_OFINFOB).or.;
				Empty(oJson:H6_HORAINI).or.;
				Empty(oJson:H6_HORAFIN).or.;
				Empty(oJson:H6_QTDPROD).or.;
				Empty(oJson:H6_DTAPONT)
			//Empty(oJson:H6_DATAINI).or.;
				//Empty(oJson:H6_DATAFIN).or.;
				cDescErro:="Campos obrigatórios não foram preenchidos."
			u_LogInteg(cRotina,'Erro',"SH6",alltrim(str(oJson:H6_OFINFOB)),'',cDescErro,time())

			lOk := .F.

			If Empty(aRestFault)
				cDescErro := "Existem campos obrigatórios no cabeçalho que não foram preenchidos."
				aRestFault := {1014,EncodeUTF8(cDescErro, "cp1252")}
			Endif

		EndIf
	EndIf
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
Static Function PROC_MOV()

	Local lPRODAUT := SUPERGETMV("MV_PRODAUT",.F.,.T.) //Apontar OP´s intermediárias segundo o apontamento da OP Pai
	Local aCabec:={}
	Local cErro := ""
	Local aMsg  :={}
	Local aMsgB
	Local cMsgOK := ""

	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.

	Private cMsgErro
	Private lOk       := .t.

	Private nPropPAI	:= 0 //Qtuantidade Proporção do PAI que está sendo apontada

	Begin Transaction
		aOP:=u_fOPbyOF(oJson:H6_OFINFOB)
		cNumOP:=aOP[1]
		nQtdOP:=aOP[2]
		nSldOP:=aOP[3]
		nRecno:=aOP[5] //recno da tabela sc2

		nPropPAI := oJson:H6_QTDPROD/nQtdOP  // proporção Percentual apontado

		If lPRODAUT
			DBSelectArea("SC2")
			dbSetOrder(1)
			SC2->(DBGoto(nRecno))
			u_fAponFilh(SC2->C2_NUM,SC2->C2_PRODUTO,SC2->C2_SEQUEN,nPropPAI)
		Endif


		aAdd( aCabec,{"H6_OP"      , cNumOP					,NIL})
		aAdd( aCabec,{"H6_OPERAC"  , oJson:H6_OPERAC		,NIL})
		aAdd( aCabec,{"H6_FERRAM"  , oJson:H6_FERRAM		,NIL})
		aAdd( aCabec,{"H6_DATAINI" , cTOD(oJson:H6_DATAINI),NIL})
		aAdd( aCabec,{"H6_HORAINI" , oJson:H6_HORAINI		,NIL})
		aAdd( aCabec,{"H6_DATAFIN" , CTOD(oJson:H6_DATAFIN),NIL})
		aAdd( aCabec,{"H6_HORAFIN" , oJson:H6_HORAFIN		,NIL})
		//aAdd( aCabec,{"H6_RECURSO"  , oJson:H6_RECURSO		,NIL})
		aAdd( aCabec,{"H6_QTDPROD"  , oJson:H6_QTDPROD		,NIL})
		aAdd( aCabec,{"H6_QTDPERD"  , oJson:H6_QTDPERD		,NIL})
		aAdd( aCabec,{"H6_DTAPONT"  , CTOD(oJson:H6_DTAPONT),NIL} )

//	u_LogConsole(cRotina, "vou processar")		

		MSExecAuto( {|x,y| MATA681(x,y)}, aCabec, nOper )//3- Inclusão, 4- Alteração, 5- Exclusão

		If lMsErroAuto



			aMsg := GetAutoGRLog()
			aEval(aMsg,{|x| cErro += x + CRLF })

			lOk := .F.

			If Empty(aMsg)
				cMsgErro := "Erro não Identificado - Protheus (execauto MATA681)"
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

			u_LogConsole(cRotina,  EncodeUTF8(cMsgErro , "cp1252"))

			//Roolback da Transação
			DisarmTransaction()


			u_LogInteg(cRotina,"Erro","SH6",alltrim(str(oJson:H6_OFINFOB)),cErro,cMsgErro,time())

			//u_LogConsole("TEDA410", "Erro não Identificado" + CRLF + cErro )
			If Empty(aRestFault)
				aRestFault := {102,EncodeUTF8(cMsgErro, "cp1252")}
			Endif

			Break //Vai para o EndTransaction

		else
			cMsgOK := ""
			DO CASE
			CASE  nOper  == 3 //3- Inclusão, 4- Alteração, 5- Exclusão
				cMsgOK := "Apontamento Realizado."
			CASE  nOper  == 4
				cMsgOK := "Alteração de Apontamento Realizada."
			CASE  nOper  == 5
				cMsgOK := "Exclusão de Apontamento Realizada."
			ENDCASE

			u_LogInteg(cRotina,"Info","SH6",alltrim(str(oJson:H6_OFINFOB)),'',cMsgOK + " Qtd = "+ AllTrim(TRANSFORM(nAponQtd,"@E 99,999.9999")),time())
		end

	End Transaction

	If !Empty(aRestFault)
		SetRestFault( aRestFault[1],aRestFault[2] )
		Return {.F.,aRestFault[2]}
	Endif


Return {lOk,cErro}

/*/{Protheus.doc} fOPbyOF
Funcao que retorna o numero da OP a partir do numero da OF do Infobox 
@type function
@version  
@author solutio
@since 06/04/2021
@param nOpInfo, numeric, param_description
@param lCriaOP, logical, param_description
@return return_type, return_description
/*/
User Function fOPbyOF(nOpInfo, lCriaOP)
	Local cQuery	:=""
	Local cNum		:=space(6)
	Local cItem		:='  '
	Local cSequen	:="   "
	Local aArea		:=GetArea()
	Local nSldOP    :=0
	Local nQtdOP    :=0
	Local nRecno	:= 0
	Local lOPFinalizada := .F.
	Local aOp := {}

	DEFAULT lCriaOP := .F.


	cQuery := " SELECT R_E_C_N_O_ NREG, SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_SEQUEN,C2_QUANT,C2_QUJE, C2_TPOP, C2_DATRF "
	cQuery += " FROM "+RetSqlName("SC2")+" SC2"
	cQuery += " WHERE SC2.D_E_L_E_T_ = ' ' "
	cQuery += " AND C2_OFINFOB="+STR(nOpInfo)
	cQuery += " AND C2_FILIAL='"+xfilial("SC2")+"'"

	DbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),"ALIASSC2" ,.T. , .F. )

	If !eof()
		cNum	:=ALIASSC2->C2_NUM
		cItem	:=ALIASSC2->C2_ITEM
		cSequen	:=ALIASSC2->C2_SEQUEN
		nQtdOP  :=ALIASSC2->C2_QUANT
		nSldOP  :=ALIASSC2->C2_QUANT-ALIASSC2->C2_QUJE
		nRecno	:= ALIASSC2->NREG
		lOPFinalizada := ALIASSC2->C2_TPOP == "F" .And. !Empty(ALIASSC2->C2_DATRF) .And. ALIASSC2->(C2_QUJE >= C2_QUANT)
	EndIf
	dbCloseArea()
	REstArea(aArea)

	//Cria a OP Caso a OP não exista
	If  EMPTY(cNum) .and. lCriaOP // Se OP não existe, cria antes do apontamento
		If CriaOP(MontaOP(nOpInfo))
			aOp := u_fOPbyOF(nOpInfo) //Faz chamada Recursiva para localizar Op Criada parâmetro de Criação caso não exista
		Else
			aOp := {cNum+cItem+cSequen,nQtdOP,nSldOP, lOPFinalizada,nRecno}
		Endif
	Else
		aOp := {cNum+cItem+cSequen,nQtdOP,nSldOP, lOPFinalizada,nRecno}
	Endif

Return  aOp

/*/{Protheus.doc} fAponFilh
Aponta OP´s Filhas com recursividade
@type function
@version 
@author Márcio Borges
@since 06/04/2021
@param cNumOp, character, Número da Op
@param cProd, character, Produto Pai
@param cSeqPai, character, Sequencia da OP Pai
@param nPropPAI, numeric, Fator de proporção da Quantidade a ser apontada
@return return_type, nill
/*/
User Function fAponFilh(cNumOp,cProd,cSeqPai,nPropPAI)
/*
nFullPai = 420 //Quantidade total da OP do Pai
nQtdApontadaPai = 120
			
nQtd APfilho = 27,5577
			
Proporcional_apontado_pai: = nQtdApontadaPai/nFullPai
Proporcional_apontado_filho = Proporcional_apontado_pai * nOpFilho
*/
	Local aAreaSC2		:=SC2->(GetArea())

	Local cTRB	:= GetNextAlias() //Alias Tabela Temporária
	Local aSetField := {}
	Local aTamSX3



	Local nApont	:= 0 //Apontamento proporcionalidado ao pai
	Default nPropPAI	:= 0

	aTamSX3 := TAMSX3("C2_QUANT")
	AADD(aSetField,{"C2_QUANT", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
	aTamSX3 := TAMSX3("C2_QUJE")
	AADD(aSetField,{"C2_QUJE", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })


	// Busca Filhos para Serem Apontados
	cQuery :=  "SELECT C2_FILIAL, C2_NUM, C2_ITEM, C2_PRODUTO, C2_SEQUEN, C2_ITEMGRD, C2_QUANT, C2_QUJE  FROM " + RetSqlName("SC2") + " WHERE C2_FILIAL = '"+ xFilial("SC2") + "'  AND C2_NUM = '" + cNumOp + "' AND C2_SEQPAI = '" + cSeqPai + "' AND D_E_L_E_T_  <> '*'"
	MPSysOpenQuery( cQuery, cTRB,aSetField  )



	Do While (cTRB)->(!EOF())


		dbSelectArea('SC2')
		dbSetOrder(1) //C2_FILIAL+C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD
		If dbSeek(xFilial('SC2')+ (cTRB)->(C2_NUM+C2_ITEM+C2_SEQUEN))

			//Verifica Se roteiro de operação está cadastrado
			u_fCargaG2(SC2->C2_PRODUTO)

			//Recursividade para apontar os filhos dos filhos
			u_fAponFilh(SC2->C2_NUM,SC2->C2_PRODUTO,SC2->C2_SEQUEN,nPropPAI)

			//Efetua o Apontamento

			nApont := (cTRB)->C2_QUANT * nPropPAI

			//Faz ajustes se a quantidade a ser apontada, tirando a 'incerteza do número' se são iguais.
			If NOROUND( (cTRB)->(C2_QUANT-C2_QUJE),aTamSx3[02]-1) == NOROUND(nApont,aTamSx3[02]-1)
				nApont := (cTRB)->(C2_QUANT-C2_QUJE)
			Endif
			fAponSH6(nApont)

			(cTRB)->(DBSKIP())
		Endif
	Enddo


	RestArea(aAreaSC2)

Return

/*/{Protheus.doc} fAponSH6
Realiza apontamento de Produção 
@type function
@version 
@author Manoel Mariante
@since 01/12/2019
@param nQuant, numeric, param_description
@return return_type, return_description
/*/
Static Function fAponSH6(nQuant)
	Local nX
	Local aCabec:={}
	Local aArea		:=GetArea()
	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.

	If Type("aRestFault") == "U"
		aRestFault := {}
	Endif

	cErro:=""

	aAdd( aCabec,{"H6_OP"      , SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)	,NIL})
	aAdd( aCabec,{"H6_OPERAC"  , "10"					,NIL})
//	aAdd( aCabec,{"H6_FERRAM"  , ""	            	,NIL})
	aAdd( aCabec,{"H6_DATAINI" , cTOD(oJson:H6_DATAINI),NIL})
	aAdd( aCabec,{"H6_HORAINI" , oJson:H6_HORAINI		,NIL})
	aAdd( aCabec,{"H6_DATAFIN" , CTOD(oJson:H6_DATAFIN),NIL})
	aAdd( aCabec,{"H6_HORAFIN" , oJson:H6_HORAFIN		,NIL})
	//aAdd( aCabec,{"H6_RECURSO"  , oJson:H6_RECURSO	,NIL})
	aAdd( aCabec,{"H6_QTDPROD"  , nQuant				,NIL})
	//aAdd( aCabec,{"H6_QTDPERD"  , oJson:H6_QTDPERD		,NIL})
	aAdd( aCabec,{"H6_DTAPONT"  , CTOD(oJson:H6_DTAPONT),NIL} )
	If Type("oJson:H6_IDINFOB") <> 'U'
		aAdd( aCabec,{"H6_IDINFOB"  , oJson:H6_IDINFOB,NIL} )
		aAdd( aCabec,{"H6_PT"  , 'P',NIL} ) // Quando apontamento por id único aponta sempre mantendo a OP aberta (apontamento parcial)
	Endif

	//Não utiliza o recurso em caso de erro de gerar apontamento Pendente na T4K
	// 1 - Não gera apontamento pendente
	// 2 - Faz Apontamento Pendente somente se houver Erros. [padrão]
	// 3 - Sempre Pendente - todos os apontamentos ficam como pendente

	aAdd(aCabec,{"PENDENTE","1",Nil}) // doc: https://centraldeatendimento.totvs.com/hc/pt-br/articles/360051976953-MP-ADVPL-Apontamentos-Pendentes-Tabela-T4K


	u_LogConsole(cRotina, "vou processar op filha "+sc2->c2_sequen)

	dDatabase := CTOD(oJson:H6_DTAPONT)
	MSExecAuto( {|x,y| MATA681(x,y)}, aCabec, 3 )//3- Inclusão, 4- Alteração, 5- Exclusão

	If lMsErroAuto

		aMsg := GetAutoGRLog()
		aEval(aMsg,{|x| cErro += x + CRLF })

		lOk := .F.

		If Empty(aMsg)
			cMsgErro := "Erro não Identificado - Protheus (execauto MATA681)"
		Else
			For nX := 1 to Len(aMsg)
				cMsgErro := aMsg[nX] + CRLF
			Next nX

			cMsgErro := SUBSTR("Problema na Geração da OP Filha. " + CRLF + cMsgErro,1,(TamSX3("Z1_RETORNO")[1])-3) + "..."
		Endif



		If InTransact()
			//Roolback da Transação
			DisarmTransaction()
			u_LogInteg(cRotina,'Erro',"SH6",SC2->(C2_NUM+C2_ITEM+C2_SEQUEN),cErro,cMsgErro,time())

			If Empty(aRestFault)
				aRestFault := {102,EncodeUTF8(cMsgErro, "cp1252")}
			Endif

			Break
		Else

			u_LogInteg(cRotina,'Erro',"SH6",SC2->(C2_NUM+C2_ITEM+C2_SEQUEN),cErro,cMsgErro,time())
			If Empty(aRestFault)
				aRestFault := {102,EncodeUTF8(cMsgErro, "cp1252")}
			Endif

		Endif
	else

		cMsgOK := ""
		DO CASE
		CASE  nOper  == 3 //3- Inclusão, 4- Alteração, 5- Exclusão
			cMsgOK := "Apontamento Realizado."
		CASE  nOper  == 4
			cMsgOK := "Alteração de Apontamento Realizada."
		CASE  nOper  == 5
			cMsgOK := "Exclusão de Apontamento Realizada."
		ENDCASE

		u_LogInteg(cRotina,"Info","SH6",SC2->(C2_NUM+C2_ITEM+C2_SEQUEN),'',cMsgOK + " Qtd = "+AllTrim(TRANSFORM(nQuant,"@E 99,999.9999")),time())
	end
	RestArea(aArea)
Return

Static Function MontaOP(nOpInfo)  //versão 03

	Local cSql := ""
	Local aOP := array(7)
	Local aSetField := {}

	Local X_PRODUTO := 1
	Local X_EMISSAO := 2
	Local X_QUANT	:= 3
	Local X_DATPRI	:= 4
	Local X_OFINFOB := 5
	Local X_DATPRF 	:= 6
	Local X_OBS		:= 7

	Private cTRB := GetNextAlias()


	AADD(aSetField,{"C5_EMISSAO","D",8,0})
	AADD(aSetField,{"C6_ENTREG","D",8,0}) //Data prevista de entrega
	AADD(aSetField,{"C6_DATFAT","D",8,0})
	AADD(aSetField,{"C6_SUGENTR","D",8,0})


// Busca OF no Pedido de Venda.
	cSql := "SELECT TOP 1 C5_EMISSAO, C6_PRODUTO,C6_QTDVEN,C6_ENTREG,C6_DATFAT,C6_SUGENTR "
	cSql += "             FROM " + RetSqlName("SC6") + " C6 "
	cSql += " 		INNER JOIN SC5980 C5 "
	cSql += "					ON	C5_FILIAL = C6_FILIAL
	cSql += "			       	AND	C5_NUM = C6_NUM
	cSql += "					AND C5.D_E_L_E_T_  <> '*'
	cSql += "					  WHERE C6_FILIAL > CHAR(0) AND C6.D_E_L_E_T_  <> '*' AND C6_OFINFOB =  " + STR(nOpInfo)
	MPSysOpenQuery( cSql, cTRB,aSetField)

	IF (cTRB)->(!EOF())
		aOP[X_PRODUTO] 	:= (cTRB)->C6_PRODUTO
		aOP[X_EMISSAO] 	:= (cTRB)->C5_EMISSAO
		aOP[X_QUANT] 	:= (cTRB)->C6_QTDVEN
		aOP[X_DATPRI] 	:= (cTRB)->C6_SUGENTR
		aOP[X_OFINFOB] 	:= nOpInfo
		aOP[X_DATPRF] 	:= (cTRB)->C6_ENTREG
		aOP[X_OBS] 		:= "OP recuperada do SC6 "
	ELSE
		aOP := {}  // Caso não tenha localizado dados para a OP, Efetua limpeza da variável

		cErro   := "Função CriaOP - Falha montagem dados"
		cMsgErro:= "Não localizado referência da OP infobox no SC6 (MontaOP) -  op info: " + AllTrim(str(nOpInfo))
		u_LogInteg(cRotina,"Erro","SC2",alltrim(str(nOpInfo)),cErro,cMsgErro,time())

	ENDIF

Return aOP


/*/{Protheus.doc} CriaOP
Cria a Op faltante
@type function
@version 1.0
@author Márcio Borges
@since 24/08/2020
@param aOP, array, Array com informações da OP a ser criada
@return return_type, return_description
/*/
Static Function CriaOP(aOP)
	//Local lPRODAUT := SUPERGETMV("MV_PRODAUT",.F.,.T.) //Apontas OP´s intermediárias segundo o apontamento da OP Pai
	Local lOk		:= .T.

	Local aCabec	:= {}


	Local X_PRODUTO := 1
	Local X_EMISSAO := 2
	Local X_QUANT	:= 3
	Local X_DATPRI	:= 4
	Local X_OFINFOB := 5
	Local X_DATPRF 	:= 6
	Local X_OBS		:= 7


	Local aMsg  :={}
	Local aMsgB
	Local _cSQL 	:= ""

	Local dDataAnt := dDatabase

	Private oJson

	Private lMsErroAuto := .F.
	Private lAutoErrNoFile := .T.

	Private __nnLock
	Private __CCARQ





	If Empty(aOP)
		lOk := .F.

		cMsgErro := "Criação de OP: sem dados para criação da OP"
		If Empty(aRestFault)
			aRestFault := {105,EncodeUTF8(cMsgErro, "cp1252")}
		Endif

	Else
		u_LogConsole(cRotina, "Criação de OP Inexistentes (CriaOP)- Início. op info: " + AllTrim(str(aOP[X_OFINFOB])))
		If  Empty(aOP[X_PRODUTO]).or.;
				Empty(aOP[X_EMISSAO]).or.;
				Empty(aOP[X_QUANT]).or.;
				Empty(aOP[X_DATPRI]).or.;
				Empty(aOP[X_OFINFOB]).or.;
				Empty(aOP[X_DATPRF])
			lOk := .F.


			cMsgErro := "Criação de OP: Existem campos obrigatórios que não foram preenchidos."
			If Empty(aRestFault)
				aRestFault := {1,EncodeUTF8(cMsgErro, "cp1252")}
			Endif
		Endif


		dDataBase := aOP[X_EMISSAO]

		IF aOP[X_DATPRF] < aOP[X_EMISSAO]
			lOk := .F.

			cMsgErro := "Criação de OP: Data de Entrega menor que Data de Emissão(database)"
			If Empty(aRestFault)
				aRestFault := {105,EncodeUTF8(cMsgErro, "cp1252")}
			Endif
		Endif


		dbSelectArea('SB1')
		dbSetOrder(1)
		IF !dbSeek(xFilial('SB1')+PadR(aOP[X_PRODUTO], TamSX3("C2_PRODUTO")[01] ))
			lOk := .F.

			cMsgErro := "Criação de OP: Produto Não Cadastrado"
			If Empty(aRestFault)
				aRestFault := {2,EncodeUTF8(cMsgErro, "cp1252")}
			Endif
		EndIf

		iF !EMPTY(u_fOPbyOF(aOP[X_OFINFOB])[1])
			lOk := .F.

			cMsgErro := "Criação de OP: OF já existe"
			If Empty(aRestFault)
				aRestFault := {106,EncodeUTF8(cMsgErro, "cp1252")}
			Endif
		EndIf

		If !lOk
			return lOk
		End


		aAdd(aCabec,{"C2_PRODUTO" , aOP[X_PRODUTO]		,NIL})
		aAdd(aCabec,{"C2_EMISSAO" , aOP[X_EMISSAO]	,NIL})
		aAdd(aCabec,{"C2_QUANT"   , aOP[X_QUANT]			,NIL})
		aAdd(aCabec,{"C2_DATPRI"  , aOP[X_DATPRI]	,NIL})
		aAdd(aCabec,{"C2_DATPRF"  , aOP[X_DATPRF]	,NIL})
		aAdd(aCabec,{"C2_OBS" 	   , aOP[X_OBS]			,NIL})
		aAdd(aCabec,{"AUTEXPLODE" , 'S'						,NIL})
		aAdd(aCabec,{"C2_OFINFOB"  , aOP[X_OFINFOB]		,NIL}) //campo novo

		MsExecAuto( {|x,y| Mata650( x, y ) }, aCabec, PD_INCLUIR )

		//lMsErroAuto    := .F.
		//lAutoErrNoFile := .T.

		If lMsErroAuto

			aMsg := GetAutoGRLog()
			aEval(aMsg,{|x| cErro += x + CRLF })

			lOk := .F.
			If Empty(aMsg)
				cMsgErro := "Erro não Identificado - Protheus (execauto MATA650)"
			Else
				//Carrega somente primeiras linhas do erro
				aMsgB      := StrTokArr(aMsg[1], CRLF)
				If Len(aMsgB) >= 2
					cMsgErro := aMsgB[1] + " - " + aMsgB[2]
				Else
					cMsgErro := SUBSTR("Problema na Geração da OP Filha. " + CRLF + aMsgB[1],1,(TamSX3("Z1_RETORNO")[1])-3) + "..."
				Endif

			Endif

			u_LogConsole(cRotina + '-criaop()',  EncodeUTF8(cMsgErro , "cp1252"))
			// criar a op não é a operação principal, se gerar falha, loga e continua operação
			u_LogInteg(cRotina,'Erro',"SC2",alltrim(str(aOP[X_OFINFOB])),cErro,cMsgErro,time())
			//lOk := .F.


		Else


			u_LogConsole(cRotina, 'Criação de OP: OP GERADA='+SC2->(C2_NUM+C2_ITEM+C2_SEQUEN))

			//Atualiza os pedidos de venda com a OF.

			_cSQL := "UPDATE " + RetSqlName("SC6") + " SET C6_NUMOP = '" + SC2->C2_NUM + "', C6_ITEMOP = '" + SC2->C2_ITEM + "' FROM " + RetSqlName("SC6") + " WHERE C6_FILIAL > CHAR(0) AND D_E_L_E_T_  <> '*' AND C6_OFINFOB =  " + STR(aOP[X_OFINFOB]) + ";"

			if TcSQLExec(_cSQL) < 0
				lErro := .T.
				cMsgErro := "Erro Atualizando SC6 com numero OF: "+ CRLF
				cMsgErro += "Erro retornado pelo Top Connect: " + TcSqlError()

				cMsgErro := SUBSTR("Problema na Geração da OP Filha. " + CRLF + cMsgErro,1,(TamSX3("Z1_RETORNO")[1])-3) + "..."
				u_LogInteg(cRotina,'Erro',"SC6",alltrim(str(aOP[X_OFINFOB])),cMsgErro,"Erro Atualizando SC6 com numero OF",time())

			Endif

			//Cria Roteiro para Produto
			u_fCargaG2(SC2->C2_PRODUTO)
			//Obs: //A explosão das ops filhas é feita no padrão, o apontamento das ops filhas não, por isto é realizado neste programa

		EndIf

	EndIf

	dDataBase := dDataAnt

Return( lOk )
