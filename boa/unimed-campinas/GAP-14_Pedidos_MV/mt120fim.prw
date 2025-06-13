#Include "TopConn.CH"
#INCLUDE "TBICONN.CH"
#Include 'parmtype.ch'
#Include 'RestFul.ch'
#Include "APWEBSRV.CH"

/*/{Protheus.doc} MT120FIM
Ponto de Entrada na Inclusao do Pedido de compra - utilizado para integra็ใo com Fluig
ATENวรO: Este ponto de entrada deve ser compilado somente no ambiente COMPILA da DEMO-EZ4, pois 
estแ apontando para o FLUIG-DEV.
@type function
@version 1.0 
@author Carla Barbosa
@since 07/08/2023
/*/
User Function MT120FIM()

    Local nOpcao    := PARAMIXB[1]   // Op็ใo Escolhida pelo usuario 
    Local cNumPC    := PARAMIXB[2]   // Numero do Pedido de Compras
    Local nOpcA     := PARAMIXB[3]   // Indica se a a็ใo foi Cancelada = 0  ou Confirmada = 1.
    Local cAliasQry := GetNextAlias()
    Local cQuery    := ""
    Local lContinua := .T.
    Local aformField:= {}
    // Parametros do sistema
	Local cUsername  := GetNewPar( 'EZ_DEVUSER', 'poc.admin') // usuario utilizado para o XML \ SOAP
	Local cPassword  := GetNewPar( 'EZ_DEVPASS', 'Ez4@Admin@') // Password utilizado para o XML \ SOAP
	Local cIdRole    := GetNewPar( 'EZ_DEVROLE', 'poc.admin') // Identifica็ใo do usuario do Fluig com direitos a executar a tarefa
	Local cProcId    := GetNewPar( 'EZ_PROCID', 'WKF_MINHAS_APROVACOES') // Identifica็ใo do usuario do Fluig com direitos a executar a tarefa
    Local cCompId    := GetNewPar( 'EZ_DEVCOMP','2') // Identifica็ใo das empresa com direitos a executar a tarefa
    Local cAtivDest  := GetNewPar( 'EZ_ATVDEST','27')// N๚mero da Atividade de Destino

    //posicionamento das areas de trabalho
	Local aArea := GetArea()
	Local aAreaSA2 := SA2->(GetArea())
    Local aAreaSE4 := SE4->(GetArea())
    Local nB := 1
    Local cItens := ""
    Local nTotal := 0
    Local nCtn := 0

    Private cNomUser := UsrRetName(RetCodUsr())
	Private cMailUser := UsrRetMail(RetCodUsr())
    
    SA2->(dbSetOrder(1))
    SE4->(dbSetOrder(1))

    If nOpcao == 3 .or. nOpcao == 4 .or. nOpcao == 9 //Inclusใo ou Altera็ใo ou C๓pia
        
        If nOpcA == 1 .and. !ISINCALLSTACK( "CNTA121" )//Confirmada e nใo vier da medi็ใo de contrato
            
            cXMLReq := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.workflow.ecm.technology.totvs.com/">'
            cXMLReq += '    <soapenv:Header/>'
            cXMLReq += '    <soapenv:Body>'
            cXMLReq += '        <ws:startProcess>'
            cXMLReq += '            <username>'+ cUsername +'</username>'
            cXMLReq += '            <password>'+ cPassword +'</password>'
            cXMLReq += '            <companyId>'+ cCompId +'</companyId>' //Empresa na Sarepta 2 
            cXMLReq += '            <processId>'+ cProcId +'</processId>'
            cXMLReq += '            <choosedState>'+ cAtivDest +'</choosedState>'
            cXMLReq += '            <colleagueIds>'
            cXMLReq += '                <item>'+ cIdRole +'</item>'
            cXMLReq += '            </colleagueIds>'
            cXMLReq += '            <comments>Solicita็ใo gerada atrav้s do protheus.</comments>'
            cXMLReq += '            <userId>'+ cUsername +'</userId>'
            cXMLReq += '            <completeTask>true</completeTask>'
            cXMLReq += '            <attachments>'
            cXMLReq += '            </attachments>'
            cXMLReq += '            <cardData>'

            cQuery := " SELECT  * FROM " + RetSqlName('SC7')            + Chr(13)
            cQuery += " WHERE "                                         + Chr(13)
            cQuery += "   C7_FILIAL = '" + xFilial('SC7') + "' "        + Chr(13)
            cQuery += "   AND D_E_L_E_T_ = '' "                         + Chr(13)
            cQuery += "   AND C7_NUM = '" + cNumPC + "' "               + Chr(13)
            cQuery += "   AND C7_FORNECE = '" + SC7->C7_FORNECE + "'"   + Chr(13)
            cQuery += "   AND C7_LOJA = '" + SC7->C7_LOJA + "' "        

            PlsQuery(cQuery, cAliasQry)
            (cAliasQry)->(dbGoTop())

            If (cAliasQry)->(Eof())
                ApMsgAlert('Nใo hแ dados vแlidos a processar. Verifique se tem saldos para a reserva, se jแ foi realizando a integra็ใo ou o cliente estar cadastrado!!')
                lContinua := .f.
            EndIf

            If  lContinua

                While (cAliasQry)->(!Eof())

                    SA2->(dbSeek(xFilial("SA2") + (cAliasQry)->(C7_FORNECE+C7_LOJA)))
                    SE4->(dbSeek(xFilial("SE4") + (cAliasQry)->(C7_COND)))
                    SB1->(dbSeek(xFilial("SB1") + (cAliasQry)->(C7_PRODUTO)))


                    nTotal += (cAliasQry)->C7_TOTAL

                    If nB == 1
                        cItens +=  '{"C7_ITEM": "'+ (cAliasQry)->C7_ITEM +' ", "C7_PRODUTO": "'+ (cAliasQry)->C7_PRODUTO +' ", "C7_QUANT": "'+ cValToChar((cAliasQry)->C7_QUANT) +'", "B1_DESC": "'+ Alltrim((cAliasQry)->C7_DESCRI) +'", "C7_TOTAL": "'+ cValToChar((cAliasQry)->C7_TOTAL) + ' ", "C7_DATPRF": "'+ Dtoc((cAliasQry)->C7_DATPRF) +'", "C7_CONAPRO": "B", "C7_CC": "'+ Alltrim((cAliasQry)->C7_CC) +'", "C7_OPER": " ", "C7_REC_WT": "'+ cValToChar((cAliasQry)->R_E_C_N_O_) +'"}'
                    Else
                        cItens += ","+'{"C7_ITEM": "'+ (cAliasQry)->C7_ITEM +' ", "C7_PRODUTO": "'+ (cAliasQry)->C7_PRODUTO +' ", "C7_QUANT": "'+ cValToChar((cAliasQry)->C7_QUANT) +'", "B1_DESC": "'+ Alltrim((cAliasQry)->C7_DESCRI) +'", "C7_TOTAL": "'+ cValToChar((cAliasQry)->C7_TOTAL) + ' ", "C7_DATPRF": "'+ Dtoc((cAliasQry)->C7_DATPRF) +'", "C7_CONAPRO": "B", "C7_CC": "'+ Alltrim((cAliasQry)->C7_CC) +'", "C7_OPER": " ", "C7_REC_WT": "'+ cValToChar((cAliasQry)->R_E_C_N_O_) +'"}'
                    EndIf
                    AADD( aformField, {"txt_cod_processo"   , "1" })
                    AADD( aformField, {"txt_atribuicao"     , "" })
                    AADD( aformField, {"sl_status"          , "" })
                    AADD( aformField, {"txt_nome_processo"  , "Pedido de Compras" })
                    AADD( aformField, {"txt_rotina"         , "U_LibPedCom(aCab,aItens)" }) 
                    AADD( aformField, {"txt_indice"         , "PC"+ Alltrim((cAliasQry)->C7_FILIAL) + cNumPC })
                    AADD( aformField, {"txta_dados"         , '{"aCab":[{"C7_FILIAL" : "' + Alltrim((cAliasQry)->C7_FILIAL) + ' ", "C7_NUM" : "'+ Alltrim((cAliasQry)->C7_NUM) +' ", "C7_LOJA" : "'+ Alltrim((cAliasQry)->C7_LOJA) +' ", "C7_FORNECE" : "'+ Alltrim((cAliasQry)->C7_FORNECE) +' ", "A2_NOME" : "'+ NoChar(Alltrim(SA2->A2_NOME)) +' ", "C7_COND" : "'+ Alltrim((cAliasQry)->C7_COND) +' ", "E4_DESCRI" : "'+ NoChar(Alltrim(SE4->E4_DESCRI)) +' ", "TOTAL" : "'+ cValToChar(nTotal) + '", "USER_INCLUSAO" : "'+ Alltrim((cAliasQry)->C7_XUSERIN) +'", "USER_INCLUSAO_MAIL" : "'+ Alltrim(UsrRetMail((cAliasQry)->C7_USER)) + ' ",   "USER_SOLICIT" : "'+ (cAliasQry)->C7_XSOLICI +'", "USER_SOLICIT_MAIL" : "'+ ALLTRIM(Posicione("SZ5",1,xFilial("SZ5")+(cAliasQry)->C7_XSOLICI,"Z5_EMAIL")) + '","C7_EMISSAO": "'+ Dtoc((cAliasQry)->C7_EMISSAO) +'", "C7_CONTATO": "' + Alltrim((cAliasQry)->C7_CONTATO) + '", "C7_CC": "'+ Alltrim((cAliasQry)->C7_CC)+'", "C7_FILENT": "' + (cAliasQry)->C7_FILENT + '", "C7_ACCPROC": "' + (cAliasQry)->C7_ACCPROC + '", "B1_GRUPO": "' + SB1->B1_GRUPO + '", "C7_CC": "' + (cAliasQry)->C7_CC + '" }],"aItens" : [ ' + cItens + ' ]}'})
                    
                    AADD( aformField, {"txt_retorno"        , '{"aCab": [{"CAMPO":"C7_FILIAL"}, {"CAMPO":"C7_NUM"}], "aItens":[{"CAMPO":"C7_ITEM"},{"CAMPO":"C7_CONAPRO"}]}'})
                    
                    nB += 1
                    
                    (cAliasQry)->(dbSkip())
                EndDo

                For nCtn := 1 to Len(aformField)
                    cXMLReq += '				<item>'
                    cXMLReq += '					<item>'+aformField[nCtn][01]+'</item>'
                    cXMLReq += '					<item>'+aformField[nCtn][02]+'</item>'
                    cXMLReq += '				</item>'
                Next
                (cAliasQry)->(dbCloseArea())

            EndIf

            cXMLReq += '            </cardData>'
            cXMLReq += '            <appointment>'
            cXMLReq += '            </appointment>'
            cXMLReq += '            <managerMode>true</managerMode>'
            cXMLReq += '        </ws:startProcess>'
            cXMLReq += '    </soapenv:Body>'
            cXMLReq += '</soapenv:Envelope/>'

            oXMLRet := startProcess(FwCutOff(cXMLreq , .T.) )

            If oXMLRet[1]
                oXMLRet := oXMLRet[2]
                cNrFluig := oXMLRet:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_STARTPROCESSRESPONSE:_RESULT:_ITEM[6]:_ITEM[2]:TEXT
                MsgInfo ("Nr do pedido Fluig criado: " + cNrFluig, "Processo Fluig")

                FWMsgRun(, {|oSay| fGrvWsSC7(cNumPC,oSay,cNrFluig) }, "Processando", "Gravando dados na tabela da reserva")

            else
                conout(oXMLRet[2])
            endif

        EndIf
    EndIf

    SA2->(RestArea(aAreaSA2))
    SE4->(RestArea(aAreaSE4))
    RestARea(aArea)

Return

/* transmissao do Xml via Soap */
Static function startProcess(cXMLReq)
	
    Local cURL      := GetNewPar( 'EZ_DEVWSDL', "http://10.33.195.8/webdesk/ECMWorkflowEngineService?wsdl")
	Local lContinua := .T.
	Local cXMLResp 	:= ""
	Local cError    := ""
	Local cWarning  := ""
	Local oXml      := ""

	// Cria o objeto da classe TWsdlManager
	oWsdl := TWsdlManager():New()
    oWsdl:bNoCheckPeerCert := .T.
	lRet := oWsdl:ParseURL(cURL)

	If !lRet
		ConOut("Erro ParseURL: " + oWsdl:cError)
		APMsgAlert("Erro ParseURL: " + oWsdl:cError)
		lContinua := .F.
	EndIf

	If lContinua
		lRet := oWsdl:SetOperation("startProcess")
		If ! lRet
			ConOut("Erro SetOperation: " + oWsdl:cError)
			APMsgAlert("Erro SetOperation: " + oWsdl:cError)
			lContinua := .F.
		EndIf
	EndIf

	If lContinua
        oWsdl:lSSLInsecure := .T.
		lRet := oWsdl:SendSoapMsg( cXMLreq )
		cXMLResp := oWsdl:GetSoapResponse()
		oXml := XmlParser(cXMLResp, "_", @cError, @cWarning)
		if AT( "<item>ERROR</item>", cXMLResp ) != 0
			APMsgAlert(oXml:_SOAP_ENVELOPE:_SOAP_BODY:_NS1_STARTPROCESSRESPONSE:_RESULT:_ITEM:_ITEM[2]:TEXT,"Processo Fluig: ")
			lContinua := .F.
		else
			If !Empty(cWarning)
				APMsgAlert("Alerta cWarning: " + cWarning)
				ConOut("Alerta cWarning: " + cWarning)
			EndIf
			If !Empty(cError)
				ConOut("Erro cError: " + cError)
				APMsgAlert("Erro cError: " + cError)
				lContinua := .F.
			EndIf
		EndIf

	EndIf
return {lContinua, oXml}

/* funcใo para gravar os dados da integra็ใo */

Static Function fGrvWsSC7(cNumPC,oSay,cNrFluig)
	
    Local aArea    := GetArea()
	Local aAreaSC7 := SC7->(getArea())

    SC7->(dbSetOrder(3)) 
	SC7->(dbSeek(xFilial("SC7") + SC7->C7_FORNECE + SC7->C7_LOJA + cNumPC)) //C7_FILIAL+C7_FORNECE+C7_LOJA+C7_NUM

	While SC7->(!Eof() .And. C7_NUM == cNumPC)
		if !ISINCALLSTACK( "CNTA121" )
            oSay:SetText('atualizando pedido de compra: ' + cNumPC)
            ProcessMessages()
        Endif


		RecLock("SC7", .F.)
		SC7->C7_CONAPRO := "B"
        SC7->C7_XSOLFLU := cNrFluig
		SC7->(MsUnlock())
		
        SC7->(dbSkip())
	EndDo

	SC7->(RestArea(aAreaSC7))
	RestArea(aArea)

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMT120FIM  บAutor  ณFabio Santana	     บ Data ณ  04/10/10   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณConverte caracteres espceiais						          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
*/
STATIC FUNCTION NoChar(cString,lConverte)

	//Default lConverte := .F.

	If lConverte
		cString := (StrTran(cString,"&lt;","<"))
		cString := (StrTran(cString,"&gt;",">"))
		cString := (StrTran(cString,"&amp;","&"))
		cString := (StrTran(cString,"&quot;",'"'))
		cString := (StrTran(cString,"&#39;","'"))
	Else
		cString := (StrTran(cString,"&","E"))
	EndIf

Return(cString)

User Function fluigCan(cNum)

    Local xmlC := ''
    Local cAliasQry  := GetNextAlias()
    Local cQuery := ""
    Local cFluig := ""
    Local cSolic := ""

	Local cUsername  := GetNewPar( 'EZ_DEVUSER', 'poc.admin') 
	Local cPassword  := GetNewPar( 'EZ_DEVPASS', 'Ez4@Admin@') 

    Local cMsg := 'Solicita็ใo cancelada via protheus.'

    cQuery += "SELECT C7_XSOLFLU, C7_XSOLICI "
    cQuery += " FROM"
    cQuery += "    " + RetSqlName('SC7') + " SC7"
    cQuery += " WHERE"
    cQuery += "    SC7.C7_FILIAL = '" + xFilial('SC7') + "' AND"
    cQuery += "    SC7.C7_XSOLFLU = '"+cNum+"' AND"
    cQuery += "    SC7.D_E_L_E_T_ = ' ' "
    PlsQuery(cQuery, cAliasQry)
    (cAliasQry)->(dbGoTop())
    ConOut( cQuery )

    While (cAliasQry)->(!Eof())

        cFluig := (cAliasQry)->C7_XSOLFLU
        cSolic := (cAliasQry)->C7_XSOLICI

        xmlC := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.workflow.ecm.technology.totvs.com/">'
        xmlC += '<soapenv:Header/>'
        xmlC += '<soapenv:Body>'
        xmlC += '    <ws:cancelInstance>'
        xmlC += '        <username>'+cUsername+'</username>'
        xmlC += '        <password>'+cPassword+'</password>'
        xmlC += '        <companyId>1</companyId>'
        xmlC += '        <processInstanceId>'+AllTrim(cFluig)+'</processInstanceId>'
        xmlC += '        <userId>'+cUsername+'</userId>'
        xmlC += '        <cancelText>'+cMsg+'</cancelText>'
        xmlC += '    </ws:cancelInstance>'
        xmlC += '</soapenv:Body>'
        xmlC += '</soapenv:Envelope>'

        oXMLRet := cancelInstance(FwCutOff(xmlC , .T.) )
        conout(oXMLRet[2])

        (cAliasQry)->(dbSkip())
    EndDo
    (cAliasQry)->(dbCloseArea())

Return(nil)

/* transmissao do Xml via Soap */
Static function cancelInstance(cXMLReq)
	
    Local cURL      := GetNewPar( 'EZ_DEVWSDL', "https://gedeon.ez4.com.br/webdesk/ECMWorkflowEngineService?wsdl")
	Local lContinua := .T.
	Local cXMLResp 	:= ""
	Local cError    := ""
	Local cWarning  := ""
	Local oXml      := ""

	// Cria o objeto da classe TWsdlManager	
	oWsdl := TWsdlManager():New()
    oWsdl:bNoCheckPeerCert := .T.
	lRet := oWsdl:ParseURL(cURL)

	If !lRet
		ConOut("Erro ParseURL: " + oWsdl:cError)
		APMsgAlert("Erro ParseURL: " + oWsdl:cError)
		lContinua := .F.
	EndIf

	If lContinua
		lRet := oWsdl:SetOperation("cancelInstance")
		If ! lRet
			ConOut("Erro SetOperation: " + oWsdl:cError)
			APMsgAlert("Erro SetOperation: " + oWsdl:cError)
			lContinua := .F.
		EndIf
	EndIf

	If lContinua
        oWsdl:lSSLInsecure := .T.
		lRet := oWsdl:SendSoapMsg( cXMLreq )
		cXMLResp := oWsdl:GetSoapResponse()
		oXml := XmlParser(cXMLResp, "_", @cError, @cWarning)
		if AT( "<item>ERROR</item>", cXMLResp ) != 0
			APMsgAlert(oXml:_SOAP_ENVELOPE:_SOAP_BODY:NS1_CANCELINSTANCERESPONSE:RESULT,"Processo Fluig: ")
			lContinua := .F.
		else
			If !Empty(cWarning)
				APMsgAlert("Alerta cWarning: " + cWarning)
				ConOut("Alerta cWarning: " + cWarning)
			EndIf
			If !Empty(cError)
				ConOut("Erro cError: " + cError)
				APMsgAlert("Erro cError: " + cError)
				lContinua := .F.
			EndIf
		EndIf

	EndIf
return {lContinua, oXml}
