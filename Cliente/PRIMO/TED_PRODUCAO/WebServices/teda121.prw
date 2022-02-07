#include "Totvs.ch"
#include "RESTFUL.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TEDA121     ³ Autor ³ Manoel Mariante       ³ Data ³ nov/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Servico Web service para manutenção do cadastro de         ³±±
±±³          ³ CLIENTE do Infobox                                         ³±±
±±³          ³                                                            ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function teda121(nOper)

	Local nK
	Local lAuth := GETMV('ES_INFOAUT',,.F.)
	Local lINFOBOX := GetMv('ES_INFOBOX') == "S" // Integra com o infobox

	DEFAULT  __SpecialKey := Upper(GetSrvProfString("SpecialKey", "")) //identificia se é base de teste ou produção - TESTE: BHZV62_TESTE

	IF SA1->A1_MSFIL<>'0102'
		Return
	End

	If !lINFOBOX .OR. 'TESTE' $ __SpecialKey
		Return
	End

	PRIVATE oRestClient := FWRest():New(alltrim(GETMV('ES_INFOURL'))) //"http://172.16.31.214:8085"
	PRIVATE oObj   	:= Nil
	PRIVATE cBody 	:= ""
	PRIVATE lRet		:= .t.
	PRIVATE aFields	:=LoadMapper()
	PRIVATE aHeader 	:= {}
	Private oJson
	//oRestClient:nTimeOut := 120


	If Empty(SA1->A1_DATINFO).And.nOper==5
		Return .t.
	end

	If lAuth
		// inclui o campo Authorization no formato <usuario>:<senha> na base64
		Aadd(aHeader, "Authorization: Basic " + Encode64(AllTrim(GETMV('ES_INFOUSR'))+ ':' + AllTrim(GETMV('ES_INFOPSW')) ))
	Endif
	aadd(aHeader,'Content-Type: application/json')


	If nOper==3
		oRestClient:setPath("/datasnap/rest/TInfoBox/cliente")
	else
		oRestClient:setPath("/datasnap/rest/TInfoBox/cliente/"+Str(Val(SA1->A1_COD)))
	END


	//-----------------------
	//carrego  o JSON
	//-----------------------

	If !Empty(aFields)
		cBody := '{'

		For nK:=1 to Len(aFields)
			IF Valtype(&(aFields[nK,2]))=='N'
				cText:=STR(&(aFields[nK,2]))
			elseif Valtype(&(aFields[nK,2]))=='D'
				cText:='"'+DTOC(&(aFields[nK,2]))+'"'
			elseif Valtype(&(aFields[nK,2]))=='C'
				cText='"'+ALLTRIM(&(aFields[nK,2]))+'"'
			End
			cBody += '"'+aFields[nK,1]+'":'+ALLTRIM(cText)+chr(13)+chr(10)
			If nK<Len(aFields)
				cBody +=','
			End
		Next

		cBody += '}'

		MEMOWRITE("c:\temp\teda121-post.txt", cBody)

		oRestClient:SetPostParams(cBody)
		Processa({|| OkProc(nOper) },"Integrando com Infobox.")
	Else
		MsgAlert("Não foi possivel realizar a integração do Cliente com o Infobox. Revise o Cadastro de Cliente antes de realizar nova integração","TEDA121-Dados incompletos no Cadastro do Cliente")
		lret := .F. 
	Endif
	

Return( lret )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³LoadMapper  ³ Autor ³ Manoel Mariante       ³ Data ³ nov/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ faz o de...para de campos do Infobox e Protheus            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function LoadMapper()
	Local aField:={}

	If SA1->A1_EST <> 'EX' .AND. Empty(fEstado(SA1->A1_EST))
		MsgAlert("Não foi possível localizar o estado cadastrado para o Cliente " + SA1->A1_COD + "/"+ SA1->A1_LOJA + "(A1_EST).")
		Return aField
	Endif

	If SA1->A1_EST <> 'EX' .and. Empty(SA1->A1_COD_MUN) //Só permite codigo do municipio vazio se for Cliente Exterior
		MsgAlert("Não foi possível localizar código do município do Cliente " + SA1->A1_COD + "/"+ SA1->A1_LOJA + "(A1_COD_MUN).")
		Return aField
	Endif

	Aadd(aField,{"Id","VAL(SA1->A1_COD)"})  //999, (código do cliente)
	Aadd(aField,{"cnpj_cpf","SA1->A1_CGC"})  //"00000000000000",
	Aadd(aField,{"pessoa","SA1->A1_PESSOA"})  //"J", ("F" ou "J")
	Aadd(aField,{"ie","SA1->A1_INSCR"})  //"123",
	Aadd(aField,{"nome","SA1->A1_NOME"})  //"Aa",
	Aadd(aField,{"fantasia","SA1->A1_NREDUZ"})  //"Aa",
	Aadd(aField,{"endereco","FisGetEnd(SA1->A1_END)[1]"})  // "Aa",
	Aadd(aField,{"numero_logr","str(FisGetEnd(SA1->A1_END)[2],8)"})  //"123A",
	Aadd(aField,{"compl_logr","FisGetEnd(SA1->A1_END)[4]"})  //"123A",
	Aadd(aField,{"bairro","SA1->A1_BAIRRO"})  //"Aa",
	Aadd(aField,{"ibge_cidade","IF(SA1->A1_EST $'EX','9999999',VAL(fEstado(SA1->A1_EST)+SA1->A1_COD_MUN))"})  //9999999,
	Aadd(aField,{"cep","SA1->A1_CEP"})  //"99999999",
	Aadd(aField,{"ddd_fone","SA1->A1_DDD"})  //"51",
	Aadd(aField,{"telefone","SA1->A1_TEL"})  //"9999999",
	Aadd(aField,{"celular","''"})  //"",
	Aadd(aField,{"email","SA1->A1_EMAIL"})  //"a@com.br;b@com.br",
	Aadd(aField,{"emailcompras","''"})  //"",
	Aadd(aField,{"homepage","SA1->A1_HPAGE"})  //"www.com.br",
	Aadd(aField,{"cnpjentrega",""})  //"",
	Aadd(aField,{"enderecoentrega","FisGetEnd(SA1->A1_ENDENT)[1]"})  //"",
	Aadd(aField,{"numeroentrega","Str(FisGetEnd(SA1->A1_ENDENT)[2])"})  //"",
	Aadd(aField,{"complentrega","FisGetEnd(SA1->A1_ENDENT)[4]+' '+SA1->A1_COMPENT"})  //"",
	Aadd(aField,{"bairroentrega","SA1->A1_BAIRROE"})  //"",
	Aadd(aField,{"cepentrega","''"})  //"",
	Aadd(aField,{"ibge_cid_entrega","0"})  //0,
	Aadd(aField,{"foneentrega","''"})  //"",
	Aadd(aField,{"emailentrega","''"})  //"",
	Aadd(aField,{"dt_cad","DTOC(SA1->A1_DTCAD)"})  //"31/12/19", (data cadastro do cliente)
	Aadd(aField,{"id_rep","posicione('SA3',1,xFilial('SA3')+SA1->A1_VEND,'A3_CDINFOB')"})  //0, (código do representante)
	Aadd(aField,{"comissao","0"})  //0, (percentual de comissão do cliente quando existe especialmente para o cliente,senão segue padrão a comissão do representante do cliente)
	Aadd(aField,{"id_cond_pgto","0"})  //0, (código da condição de pagamento opcional)
	Aadd(aField,{"descr_cond_pgto","''"})  //"30/60/90",
	Aadd(aField,{"id_ramo","0"})  //0, (código de ramo de atividade)
	Aadd(aField,{"limitecredito","SA1->A1_LC"})  //0,
	Aadd(aField,{"prazomedio","0"})  //0,
	Aadd(aField,{"obs","''"})  //""
	Aadd(aField,{"obs_pedido","''"})  //"" (obs a ser impressa no pedido do cliente)
	Aadd(aField,{"obs_financ","''"})  //"" (obs do setor financeiro, visível para a liberação de pedidos pelo financeiro)
	Aadd(aField,{"laudo","'S'"})  //"N" ("S"ou "N" (cliente exige laudo técnico)

Return aField

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³OkProc      ³ Autor ³ Manoel Mariante       ³ Data ³ nov/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ faz o de...para de campos do Infobox e Protheus            ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function OkProc(nOper)
	LOCAL nTentativas:=0
	LOCAL lSucesso	  := .F.
	Local lRetWs     := .f.

	ProcRegua(30)

	While nTentativas<=30
		If nTentativas
			IncProc('Tentativa '+Str(nTentativas,4) )
		Else
			IncProc(AllTrim(oRestClient:GetLastError()) + '. Evetuando nova Tentativa :'+Str(nTentativas,4) )
		Endif
		If nOper==3
			lRetWs:=oRestClient:Post(aHeader)
		End
		If nOper==5
			lRetWs:=oRestClient:Delete(aHeader)
		End

		IF lRetWs
			cGetResult:=oRestClient:GetResult()

			IF !FWJsonDeserialize(cGetResult,@oJson)
				Alert('Problema com JSON de Retorno')
			Else
				cRetorno:=oJson:errorcode
				cMessage:=oJson:errormessage
				If alltrim(cRetorno)=="0"
					lSucesso:=.T.
				End
			End
			Exit
		Else
			Conout("TEDA122 - Erro Autenticação:" + oRestClient:GetLastError())
		EndIf

		//inkey(1)
		nTentativas++

	Enddo

	IF lSucesso
		If nOper<5
			RecLock('SA1',.f.)
			SA1->A1_DATINFO:=msDate()
			SA1->A1_HRINFO :=TIME()
			MSUNLOCK()
		end

		MSGINFO('Integrado com Sucesso no Infobox')
	Else
		If lRetWs
			MSGINFO('Problemas na Integração com Infobox. Contate a TI. '+chr(10)+chr(13)+'Erro ='+cRetorno+' - '+cMessage)
		else
			MSGINFO('Problemas na Integração com Infobox. Contate a TI. '+chr(10)+chr(13)+'Erro ='+oRestClient:GetlastError())
		End
		lRet:=.f.
	End

Return

Static Function fEstado(cEst)

	Local aEstados:={}
	Local cReturn :=""

	Aadd(aEstados,{"AC","12"})
	Aadd(aEstados,{"AL","27"})
	Aadd(aEstados,{"AP","16"})
	Aadd(aEstados,{"AM","13"})
	Aadd(aEstados,{"BA","29"})
	Aadd(aEstados,{"CE","23"})
	Aadd(aEstados,{"DF","53"})
	Aadd(aEstados,{"ES","32"})
	Aadd(aEstados,{"GO","52"})
	Aadd(aEstados,{"MA","21"})
	Aadd(aEstados,{"MT","51"})
	Aadd(aEstados,{"MS","50"})
	Aadd(aEstados,{"MG","31"})
	Aadd(aEstados,{"PA","15"})
	Aadd(aEstados,{"PB","25"})
	Aadd(aEstados,{"PR","41"})
	Aadd(aEstados,{"PE","26"})
	Aadd(aEstados,{"PI","22"})
	Aadd(aEstados,{"RN","24"})
	Aadd(aEstados,{"RS","43"})
	Aadd(aEstados,{"RJ","33"})
	Aadd(aEstados,{"RO","11"})
	Aadd(aEstados,{"RR","14"})
	Aadd(aEstados,{"SC","42"})
	Aadd(aEstados,{"SP","35"})
	Aadd(aEstados,{"SE","28"})
	Aadd(aEstados,{"TO","17"})

	Aadd(aEstados,{"EX","99"}) //Exterior/Exportação

	nPos:=Ascan(aEstados, { |x| x[1] == cEst })

	If !Empty(nPos)
		cReturn := aEstados[nPos,2]
	Endif

Return cReturn

