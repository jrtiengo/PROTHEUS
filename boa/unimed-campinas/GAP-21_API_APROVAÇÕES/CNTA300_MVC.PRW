#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TOPCONN.CH"
#include "TBICONN.CH"

/*/{Protheus.doc} CNTA300
Ponto de Entrada MVC CNTA300
@type function
@version 1.0 
@author Tiengo Jr.
@since 05/05/2025
@Obs PARAMIXB[1] O - FORMCOMMITTTSPOS - Objeto do formul�rio ou do modelo, conforme o caso
@Obs PARAMIXB[2] C - FORMCOMMITTTSPOS - ID do local de execu��o do ponto de entrada
@Obs PARAMIXB[3] C - FORMCOMMITTTSPOS - ID do formul�rio
@Obs PARAMIXB[4] L - FORMCOMMITTTSPOS - Se .T. indica novo registro (Inclus�o) se .F. registro j� existente (Altera��o / Exclus�o)
/*/

User Function CNTA300()

	Local aParam  		:= PARAMIXB
	Local xRet    		:= .T.
	Local oObj    		:= ''
	Local cIdPonto		:= ''
	Local cIdModel		:= ''
	//Private cDocId    	:= SUPERGETMV( "EZ_IDFLDFO",.f.,"85")
	//Private cCompId 	:= SUPERGETMV( 'EZ_DEVCOMP',.f.,'2') // Identifica��o das empresa com direitos a executar a tarefa
	//Private cUsername  	:= SUPERGETMV( 'EZ_DEVUSER', .f., 'poc.admin') // usuario utilizado para o XML \ SOAP
	//Private cPassword  	:= SUPERGETMV( 'EZ_DEVPASS', .f., 'Ez4@Admin@') // Password utilizado para o XML \ SOAP
	//Private cURL    	:= SUPERGETMV( "EZ_DEVURLF",.f., "https://10.33.195.8/webdesk/ECMFolderService?wsdl") //URL WS de cria��o de Folder
	//Private cURLDOC    	:= SUPERGETMV( "EZ_DEVURLD",.f., "https://10.33.195.8/webdesk/ECMDocumentService?wsdl") //URL WS de cria��o de Folder

	If aParam <> NIL

		oObj       := aParam[1]
		cIdPonto   := aParam[2]
		cIdModel   := aParam[3]

		If     cIdPonto == 'MODELPOS'
		ElseIf cIdPonto == 'FORMPOS'

		ElseIf cIdPonto == 'FORMLINEPRE'

		ElseIf cIdPonto == 'FORMLINEPOS'

		ElseIf cIdPonto == 'MODELCOMMITTTS'

		ElseIf cIdPonto == 'MODELCOMMITNTTS'

		ElseIf cIdPonto == 'FORMCOMMITTTSPOS' //Ap�s a grava��o da tabela do formul�rio.

			lOperacao := aParam[4]

			//GAP112 - Se o contrato tiver origem do novo fluxo de compras, ir� nascer como 2N = Em Elabora��o Area Neg�cio.
			If FWIsInCallStack('PGCA010')
				If lOperacao .and. cIdModel == 'CN9MASTER'
					Reclock("CN9", .F.)
					CN9->CN9_XSITUA := '2N'
					CN9->(msUnlock())
				Endif
			Else
				Reclock("CN9", .F.)
				CN9->CN9_XSITUA := CN9->CN9_SITUAC
				CN9->(msUnlock())
			Endif

		ElseIf cIdPonto == 'MODELCANCEL'

		ElseIf cIdPonto == 'BUTTONBAR' //Para a inclus�o de bot�es na ControlBar.

		EndIf

/*
		If  cIdPonto == 'FORMCOMMITTTSPOS' //Chamada apos a grava��o da tabela do formul�rio

			//Verifica se o contrato est� aguardando aprova��o
			If CN9->CN9_SITUAC == '4' .or. CN9->CN9_SITUAC == '9' .and. ! Empty(CN9->CN9_APROV)

				cContrato := CN9->CN9_NUMERO
				If fEnviaAprov(cContrato, cUsername,cPassword)
					FWLogMsg("INFO",,"FLUIG INTEG",,,,"Solicita��o de Aprova��o enviada com sucesso para o Fluig",,,)
				ELse
					FWLogMsg("INFO",,"FLUIG INTEG",,,,"Solicita��o de Aprova��o n�o enviada para o Fluig",,,)
				Endif
			EndIf
		EndIf
*/
	Endif

Return(xRet)


/*
Static Function fEnviaAprov(cContrato,cUsername,cPassword,cURL)

	Local lRet			:= .T.	as logical
	Local cXMLRetDoc	:= ""	as character

	While ! SCR->(Eof()) .and. SCR->CR_NUM == cContrato .and. SCR->CR_STATUS == '2'

		cXMLRetDoc += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.dm.ecm.technology.totvs.com/">'
		cXMLRetDoc += '<soapenv:Header/>'
		cXMLRetDoc += '<soapenv:Body>'
		cXMLRetDoc += '    <ws:createSimpleDocument>'
		cXMLRetDoc += '        <username>'+ cUsername +'</username>'
		cXMLRetDoc += '        <password>'+ cPassword +'</password>'
		cXMLRetDoc += '        <companyId>'+ cCompId +'</companyId>'
		cXMLRetDoc += '        <parentDocumentId>'+ cPastaPai +'</parentDocumentId>'
		cXMLRetDoc += '        <publisherId>'+ cUsername +'</publisherId>'
		cXMLRetDoc += '        <documentDescription>'+ cDescArq +'</documentDescription>'
		cXMLRetDoc += '                <Attachments>'
		cXMLRetDoc += '                   <!--Zero or more repetitions:-->'
		cXMLRetDoc += '                   <item>'
		cXMLRetDoc += '                   <attach>true</attach>'
		cXMLRetDoc += '                   <fileName>'+ AllTrim(cFileName) +'</fileName>'
		cXMLRetDoc += '                   <filecontent>'+cArqBase64+'</filecontent>'
		cXMLRetDoc += '                   <mobile>true</mobile>'
		cXMLRetDoc += '                   <principal>true</principal>'
		cXMLRetDoc += '                   </item>'
		cXMLRetDoc += '                 </Attachments>'
		cXMLRetDoc += '    </ws:createSimpleDocument>'
		cXMLRetDoc += '</soapenv:Body>'
		cXMLRetDoc += '</soapenv:Envelope>'

		aXMLRetDoc := startDoc(FwCutOff(cXMLRetDoc , .T.), cURL)

		SCR->(DbSkip())
	Enddo

	If aXMLRetDoc[1]
		cDocFluig := aXMLRetDoc[2]
		cDocFluSol := u_SXTagCont("documentId",cDocFluig)
		cTexto:= "Nr. Documento Fluig criado: " + cDocFluSol + " Processo Fluig Diret�rio"
		FWLogMsg("INFO",,"FLUIG INTEG",,,,cTexto,,,)
		lRet := .t.
	Else
		lRet := .F.
	Endif

Return (lRet)

Static function startDoc(cXMLRetDoc,cUrl)

	Local lContinua := .T.
	Local cXMLResp 	:= ""
	Local cError    := ""
	Local cWarning  := ""
	Local oXml      := ""

	// Cria o objeto da classe TWsdlManager
	oWsdl := TWsdlManager():New()
	oWsdl:nTimeout 			:= 120
	oWsdl:nSOAPVersion 		:= 0
	oWsdl:bNoCheckPeerCert 	:= .T.
	oWsdl:lSSLInsecure 		:= .T.
	lRet := oWsdl:ParseURL(cURL)

	If !lRet
		cTexto := "Erro ParseURL: " + oWsdl:cError
		FWLogMsg("INFO",,"FLUIG INTEG",,,,cTexto,,,)
		lContinua := .F.
	EndIf

	If lContinua
		lRet := oWsdl:SetOperation("createSimpleDocument")
		If ! lRet
			cTexto:= "Erro SetOperation: " + oWsdl:cError
			FWLogMsg("INFO",,"FLUIG INTEG",,,,cTexto,,,)
			lContinua := .F.
		EndIf
	EndIf

	If lContinua
		lRet := oWsdl:SendSoapMsg( cXMLRetDoc )
		cXMLResp := oWsdl:GetSoapResponse()
		oXml := XmlParser(cXMLResp, "_", @cError, @cWarning)
		if AT( "<documentId>0</documentId>", cXMLRetDoc ) != 0
			cTexto := "Erro retorno"
			FWLogMsg("INFO",,"FLUIG INTEG",,,,cTexto,,,)
			lContinua := .F.
		else
			If !Empty(cWarning)

				cTexto := "Alerta cWarning: " + cWarning
				FWLogMsg("INFO",,"FLUIG INTEG",,,,cTexto,,,)
			EndIf
			If !Empty(cError)

				cTexto := "Erro cError: " + cError
				FWLogMsg("INFO",,"FLUIG INTEG",,,,cTexto,,,)
				lContinua := .F.
			EndIf
		EndIf

	EndIf

return{lContinua, cXMLResp}

user function  SXTagCont( cTag , cXML )

	local cU_XMl:= Alltrim(Upper(cXMl))  // tudo em maisculo para
	local cU_Tag:= Alltrim(Upper(cTag))  // facilitar a busca
	local cRet:="", nPosIni:=0, nTamCtd:=0
	local i:=0, nMax:=Len(cU_XML)

	cXML := AllTrim(cXML)

	nPosIni := At("<"+cU_Tag+">", cU_XML)       // acha o 1� inicio da tag de abertura
	if nPosIni = 0
		nPosIni := At("<"+cU_Tag+" ", cU_XML)   // caso a TAG tenha atributos
	endif
	If nPosIni > 0
		nPosIni += len("<"+cU_Tag)           // busca o inicio do conteudo da tag
		while nMax >= nPosINI .and. ;        // evitar estouro devido a XML mal definido
			Substr(cU_XML,nPosIni,1) <> ">"
			nPosINI++                      // acha o final da tag de abertura
		end
		nPosINI++                            // inicio do conteudo
		i := At("</"+cU_Tag+'>', cU_XML)         // acha o final do conteudo ou inicio da tag de fechamento
		if i = 0
			i := At("</"+cU_Tag+" ", cU_XML)   // caso a TAG tenha atributos
		endif
		nTamCtd := i - nPosINI               // calcula o tamanho do conteudo
		if nTamCtd > 0                                 // Se existe conte�do
			cRet:= Substr( cXML, nPosINI, nTamCtd )     // extrai do xml original
		endif                                          // para n�o retornar tudo em mai�sculo

	endif
return cRet
