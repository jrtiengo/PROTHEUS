#include "Totvs.ch"
#include "rwmake.ch"

/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    | TEDA122 | Autor | Manoel Mariante        | Data |10/11/2019|||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao | Servico Web service para inclusao das NOTAS DE SAIDA       |||
|||           | no sistema Infobox                                         |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   | U_TEDA122()                                                |||
|||-----------+------------------------------------------------------------|||
||| Parametros| ExpN01 - Operaao                                           |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpL01 - Verdadeiro ou Falso                               |||
|||-----------+------------------------------------------------------------|||
|||  Uso      | Especifico Cliente Primo Tedesco                           |||
|||-----------+------------------------------------------------------------|||
|||                           ULTIMAS ALTERACOES                           |||
|||-------------+--------+-------------------------------------------------|||
||| Programador | Data   | Motivo da Alteracao                             |||
|||-------------+--------+-------------------------------------------------|||
||| Joao Mattos |15/01/20| Nova regra para envio do pedido p/Infobox       |||
|||-------------+--------+-------------------------------------------------|||
|============================================================================|
|============================================================================|*/
User Function teda122(nOper)
	
	Local nK 
	Local lAuth := GETMV('ES_INFOAUT',,.F.) //Efetua auutenticação com o WS
	Local lINFOBOX := GetMv('ES_INFOBOX') == "S" // Integra com o infobox

	DEFAULT  __SpecialKey := Upper(GetSrvProfString("SpecialKey", "")) //identificia se é base de teste ou produção - TESTE: BHZV62_TESTE

	IF SF2->F2_MSFIL<>'0102'
		Return
	End
	
	If !lINFOBOX .OR. 'TESTE' $ __SpecialKey
		Return
	End

	PRIVATE oRestClient := FWRest():New(alltrim(GETMV('ES_INFOURL'))) //http://200.183.172.2:9090
	PRIVATE cBody 		:= ""
	PRIVATE lRet		:= .t.
	PRIVATE aHeader 	:= {}
	Private oJson
	Private aDetField:={} //usado na function LoadMapper
	Private aCabField:={} //usado na function LoadMapper
	Private nTipoNF:=1

	oRestClient:nTimeOut:= 240 //forcando o TimeOut que por padrao vem como 120


	//oRestClient:setPath("/datasnap/rest/TInfoBox/cliente")
	//oRestClient:nTimeOut := 120
	//oRestClient:SetChkStatus(.f.)

	LoadMapper()

	
	//--< Inicio - Nova regra para envio dos pedidos de venda para InfoBox - Joao Mattos - 15/01/2020 >--\\
	
	// Pesquisa item da nota fiscal
	SD2->( dbSetOrder( 3 ))	// D2_FILIAL + D2_DOC + D2_SERIE + D2_CLIENTE + D2_LOJA + D2_COD + D2_ITEM
	SD2->( dbSeek( SF2->F2_FILIAL + SF2->F2_DOC + SF2->F2_SERIE + SF2->F2_CLIENTE + SF2->F2_LOJA ) )

	// Pesquisa pedido de venda
	SC5->( dbSetOrder (1) )	// C5_FILIAL + C5_NUM
	SC5->( dbSeek( SF2->F2_FILIAL + SD2->D2_PEDIDO ))

	// Regra se envia pedido para InfoBox
	// Ou seja, se o campo C5_CDINFOB , estiver preenchido , deve ser enviado para o Infobox, conforme Valdir
	If Empty(SC5->C5_CDINFOB)
		
		Return .t.
	EndIf

	//--< Fim - Nova regra para envio dos pedidos de venda para InfoBox - Joao Mattos - 15/01/2020 >--\\

	If Empty(SF2->F2_DATINFO).And.nOper==5
		Return .t.
	End

	If Empty(SF2->F2_DATINFO)
		noper:=3 //inclusao
	End
	
	If Empty(SF2->F2_DUPL)
		Return .t.
	End


	If lAuth
		// inclui o campo Authorization no formato <usuario>:<senha> na base64
		Aadd(aHeader, "Authorization: Basic " + Encode64(AllTrim(GETMV('ES_INFOUSR'))+ ':' + AllTrim(GETMV('ES_INFOPSW')) ))
		               
	Endif
	aadd(aHeader,'Content-Type: application/json')

	If nOper==3
		oRestClient:setPath("/datasnap/rest/TInfoBox/nfs")
	else
		oRestClient:setPath("/datasnap/rest/TInfoBox/nfs?chavefilial=1&numero="+str(val(sf2->f2_doc))+"&serie="+sf2->f2_serie)
	END

	Posicione('SA1',1,xFilial('SA1')+SF2->F2_CLIENTE+SF2->F2_LOJA,'A1_NOME')

	//-----------------------
	//carrego  o JSON
	//-----------------------

	dbSelectArea('SD2')
	dbSetOrder(3)
	dbSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA))

	nTipoNF:=Posicione('SF4',1,xFilial('SF4')+SD2->D2_TES,'F4_TPNFIBO')
	If nTipoNF==0
		nTipoNF:=1
	end

	cBody := '{'

	For nK:=1 to Len(aCabField)
		IF Valtype(&(aCabField[nK,2]))=='N'
			cText:=STR(&(aCabField[nK,2]))
		elseif Valtype(&(aCabField[nK,2]))=='D'
			cText:='"'+DTOC(&(aCabField[nK,2]))+'"'
		elseif Valtype(&(aCabField[nK,2]))=='C'
			cText='"'+ALLTRIM(&(aCabField[nK,2]))+'"'
		End

		cBody += '"'+aCabField[nK,1]+'":'+ALLTRIM(cText) + ',' +chr(13)+chr(10)
		//If nK<Len(aCabField)
		//	cBody += ','
		//End
		//cBody +=chr(13)+chr(10)
	Next

	cBody +='"itens":[{'"
	lFirst:=.t.

	dbSelectArea('SD2')
	dbSetOrder(3)
	dbSeek(SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA))
	While SF2->(F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA) == SD2->(D2_FILIAL+D2_DOC+D2_SERIE+D2_CLIENTE+D2_LOJA) .and. !eof()
		If lFirst
			lFirst:=.f.
		else
			cBody += ',{'
		End
		
		Posicione('SF4',1,xFilial('SF4')+SD2->D2_TES,'F4_CODIGO')
		Posicione('SB1',1,xFilial('SB1')+SD2->D2_COD,'B1_DESC')
		Posicione('SC6',1,xFilial('SC6')+SD2->D2_PEDIDO+SD2->D2_ITEMPV,'C6_NUM')


		For nK:=1 to Len(aDetField)
			IF Valtype(&(aDetField[nK,2]))=='N'
				cText:=STR(&(aDetField[nK,2]))
			elseif Valtype(&(aDetField[nK,2]))=='D'
				cText:='"'+DTOC(&(aDetField[nK,2]))+'"'
			elseif Valtype(&(aDetField[nK,2]))=='C'
				cText='"'+ALLTRIM(&(aDetField[nK,2]))+'"'
			End
			cBody += '"'+aDetField[nK,1]+'":'+ALLTRIM(cText)+IF(nK<Len(aDetField),',','')+chr(13)+chr(10)
		Next

		cBody += '}'

		dbSkip()
	End
	cBody += ']}'
	
	If Type('aHeader[1]') <> 'U'
		MEMOWRITE("c:\temp\teda122a-post-Header.txt", aHeader[1])
	Endif
	MEMOWRITE("c:\temp\teda122a-post-Body.txt", cBody)
	
	// define o conteúdo do body
	oRestClient:SetPostParams(cBody)
	

	Processa({|| OkProc(nOper) },"Integrando com Infobox.")

Return( lret )

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
	LOCAL nTentativas	:=0
	LOCAL cRetorno	:="99999"
	LOCAL cMessage	:='Erro Não Identificado'
	LOCAL lSucesso	:= .F.
	Local lRetWs   := .f.

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
			ConOut("POST", cGetResult)

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
			RecLock('SF2',.f.)
			SF2->F2_DATINFO:=msDate()
			SF2->F2_HRINFO :=TIME()
			MSUNLOCK()
		end

		MSGINFO('Integrado com Sucesso no Infobox')
	Else
		If lRetWs
			MSGINFO('Problemas na Integração com Infobox. Contate a TI. '+chr(10)+chr(13)+'Erro ='+cRetorno+' - '+cMessage)
		else
			MSGINFO('Problemas na Integração com Infobox. Contate a TI. '+chr(10)+chr(13)+'Erro ='+oRestClient:GetlastError())
		End
	End

Return

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

	Aadd(aCabField,{"chavefilial","1" } ) //:1,
	Aadd(aCabField,{"numero","VAL(SF2->F2_DOC)" } ) //:999999,
	Aadd(aCabField,{"serie","SF2->F2_SERIE "} )  //1","SF2->F2_ "} ) //,
	Aadd(aCabField,{"tipodoc",'"55"' } )  //55","SF2->F2_ "} ) //,
	Aadd(aCabField,{"codsitdoc",'"00"'} )  //00","SF2->F2_ "} ) //,
	Aadd(aCabField,{"chavenfe","SF2->F2_CHVNFE "} )   //00000000000000000000000000000000000000000000","SF2->F2_ "} ) //,
	Aadd(aCabField,{"cliente","VAL(SF2->F2_CLIENTE) "} ) //:999999,
	Aadd(aCabField,{"emissao","SF2->F2_EMISSAO "} )   //31/12/19","SF2->F2_ "} ) //,
	Aadd(aCabField,{"hremissao","SF2->F2_HORA "} )   //07:00","SF2->F2_ "} ) //,
	Aadd(aCabField,{"hrsaida","SF2->F2_HORA "} )   //07:00","SF2->F2_ "} ) //,
	Aadd(aCabField,{"cfop","Left(SD2->D2_CF,1)+'.'+Substr(SD2->D2_CF,2,3)"} )   //5.101","SF2->F2_ "} ) //,
	Aadd(aCabField,{"pesoliquido","SF2->F2_PLIQUI  "} ) //:999,
	Aadd(aCabField,{"pesobruto","SF2->F2_PBRUTO  "} ) //:999,
	Aadd(aCabField,{"valorprodutos","SF2->F2_VALMERC "} ) //:999.99,
	Aadd(aCabField,{"valoripi","SF2->F2_VALIPI "} ) //:999.99,
	Aadd(aCabField,{"valoricms","SF2->F2_VALICM "} ) //:999.99,
	Aadd(aCabField,{"valorpis","SF2->F2_VALIMP6 "} ) //:999.99,
	Aadd(aCabField,{"valorcofins","SF2->F2_VALIMP5 "} ) //:999.99,
	Aadd(aCabField,{"valorfrete","SF2->F2_FRETE "} ) //:999.99,
	Aadd(aCabField,{"valoroutros","SF2->F2_SEGURO "} ) //:999.99,
	Aadd(aCabField,{"valordesconto","SF2->F2_DESCONT "} ) //:999.99,
	Aadd(aCabField,{"valortotal","SF2->F2_VALBRUT "} ) //:999.99,
	Aadd(aCabField,{"cancelada",'"N"'} )   //N","SF2->F2_ "} )
	Aadd(aCabField,{"id_tiponf","nTipoNF" } ) //:1,
	Aadd(aCabField,{"id_rep","0" } ) //:0,
	//Aadd(aCabField,{"itens","SF2->F2_ "} ) //:[{

	Aadd(aDetField,{"descricao","SB1->B1_DESC"} ) //:","SD2->D2_ "} ) //Aa","SD2->D2_ "} ) //,
	Aadd(aDetField,{"numeroOF","SC6->C6_OFINFOB" } )
	//Aadd(aDetField,{"numeroOF","POSICIONE('SC2',1,XFILIAL('SC2')+SC6->C6_NUMOP,'C2_OFINFOB')"} ) //:999999,
	Aadd(aDetField,{"ncm","SB1->B1_POSIPI"} ) //:","SD2->D2_ "} ) //48191000","SD2->D2_ "} ) //,
	Aadd(aDetField,{"cst","SD2->D2_CLASFIS "} ) //:","SD2->D2_ "} ) //000","SD2->D2_ "} ) //,
	Aadd(aDetField,{"un","SD2->D2_UM "} ) //:","SD2->D2_ "} ) //UN","SD2->D2_ "} ) //,
	Aadd(aDetField,{"quantidade","SD2->D2_QUANT "} ) //:999.99,
	Aadd(aDetField,{"preco","SD2->D2_PRCVEN "} ) //:999.999","SD2->D2_ "} ) //,
	Aadd(aDetField,{"icms","SD2->D2_PICM "} ) //:18,
	Aadd(aDetField,{"redbaseicms","SF4->F4_BASEICM "} ) //:999.999,
	Aadd(aDetField,{"aliqicmsdif","SF4->F4_BSICMST "} ) //:0,
	Aadd(aDetField,{"ipi","SD2->D2_IPI "} ) //:15,
	Aadd(aDetField,{"valorprodutos","SD2->D2_TOTAL "} ) //:999.99","SD2->D2_ "} ) //,
	Aadd(aDetField,{"valoripi","SD2->D2_VALIPI "} ) //:999.99,
	Aadd(aDetField,{"valoricms","SD2->D2_VALICM "} ) //:999.99","SD2->D2_ "} ) //,
	Aadd(aDetField,{"valorpis","SD2->D2_VALIMP6 "} ) //:999.99,
	Aadd(aDetField,{"valorcofins","SD2->D2_VALIMP5 "} ) //:999.99,
	Aadd(aDetField,{"valorfrete","SD2->D2_VALFRE "} ) //:999.99,
	Aadd(aDetField,{"valoroutros","SD2->D2_SEGURO "} ) //:999.99,
	Aadd(aDetField,{"valordesconto","SD2->D2_DESCON "} ) //:999.99,
	Aadd(aDetField,{"peso","SD2->D2_PESO*SD2->D2_QUANT "} ) //:999.99,
	Aadd(aDetField,{"id_laudo","0" } ) //:999,
	Aadd(aDetField,{"un_trib","SD2->D2_UM "} ) //:","SD2->D2_ "} ) //UN","SD2->D2_ "} ) //,
	Aadd(aDetField,{"quant_trib","SD2->D2_QUANT "} ) //:999.999,
	Aadd(aDetField,{"preco_trib","SD2->D2_PRCVEN "} ) //:999.999}]

Return .T.

