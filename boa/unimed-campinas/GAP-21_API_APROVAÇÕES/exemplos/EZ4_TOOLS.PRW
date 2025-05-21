#INCLUDE "FWMVCDEF.CH"
#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FILEIO.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH" 
#INCLUDE "FONT.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "TRYEXCEPTION.CH"
#include "fivewin.ch"
#INCLUDE "TOPCONN.CH"
#include "TBICONN.CH"

/*/{Protheus.doc} FindFolder
Localiza a Pasta na Tabela TABFOLDER
@type function
@author Carla Barbosa
@since 02/08/2023
/*/
User Function FindFolder(cTip,cFornece,cDocId,cCompId,cUsername,cPassword,cURL)

Local aFolder := {}

// Cria e Abre a Tabela de Folders


// Busca o Folder do Fornecedor
cQRY := "SELECT IDPASTA FROM TABFOLDER "
cQRY += " WHERE CODIGO ='"+cFornece+"' AND "
cQRY += "       TIPO   in ('1','"+cTip+"') "
cQRY += " ORDER BY TIPO "
IF Select("TMPQRY") <> 0
   TMPQRY->(dbCloseArea())
ENDIF

cQRY := changequery(cQRY) 
dbUsearea(.T.,"TOPCONN",TCGenQry(,,cQRY), "TMPQRY") 

COUNT TO nTotReg

If nTotReg == 0
    TMPQRY->(dbCloseArea())
Else
    TMPQRY->(dbGoTop())
    while TMPQRY->(!eof())
        aadd(aFolder,TMPQRY->IDPASTA)
        TMPQRY->(DBSKIP())
    enddo
    TMPQRY->(dbCloseArea())
Endif

if len(aFolder) == 0

   aFolder:= U_CriaFldPai(cTip,cFornece,cDocId,cCompId,cUsername,cPassword,cURL)

Endif
Return aFolder

/*/{Protheus.doc} FindEntidade
Localiza a Entidade na Tabela TABFOLDER
@type function
@author Carla Barbosa
@since 02/08/2023
/*/
User Function FindDoc(cNomeArq,cFornece,cEntidade,cTabOri) 
Local lRet := .t.

cQRY := "SELECT IDDOC FROM TABDOC "
cQRY += " WHERE ENTIDADE ='"+cEntidade+"' AND "
cQRY += "       CODIGO  = '"+cFornece+"'  AND "
cQRY += "       LTRIM(RTRIM(FILENAME))  = '"+Alltrim(cNomeArq)+"'   AND "
cQRY += "       TABELA   = '"+cTabOri+"' "
cQRY += " ORDER BY IDDOC "
IF Select("TMPQRY") <> 0
   TMPQRY->(dbCloseArea())
ENDIF

cQRY := changequery(cQRY) 
dbUsearea(.T.,"TOPCONN",TCGenQry(,,cQRY), "TMPQRY") 

COUNT TO nTotReg

If nTotReg == 0
    lRet := .f.
Endif
TMPQRY->(dbCloseArea())
Return lRet

/*/{Protheus.doc} FindEntidade
Localiza a Entidade na Tabela TABFOLDER
@type function
@author Carla Barbosa
@since 02/08/2023
/*/
User Function FindEntidade(cEntidade,nVal) 
Local cIdFolder
Local cTipo := cValtoChar(nVal)
cQRY := "SELECT IDPASTA FROM TABFOLDER "
cQRY += " WHERE ENTIDADE ='"+cEntidade+"' AND "
cQRY += "       TIPO   = '"+cTipo+"' "
cQRY += " ORDER BY TIPO "
IF Select("TMPQRY") <> 0
   TMPQRY->(dbCloseArea())
ENDIF

cQRY := changequery(cQRY) 
dbUsearea(.T.,"TOPCONN",TCGenQry(,,cQRY), "TMPQRY") 

COUNT TO nTotReg

If nTotReg == 0
    TMPQRY->(dbCloseArea())
Else
    TMPQRY->(dbGoTop())
    cIdFolder:= TMPQRY->IDPASTA
    TMPQRY->(dbCloseArea())
Endif
Return cIdFolder

/*/{Protheus.doc} CriaFldPai
WS para criação da Pasta PAI do Fornecedor no Fluig
@type function
@version 1.0 
@since 01/08/2023
@author Carla Barbosa
*/

User Function CriaFldPai(cTip,cFornece,cDocId,cCompId,cUsername,cPassword,cURL)
Local aFolder := {}
Local n       := 0
Local lContinua := .T.
Local cXMLRetFol:= ""
Local cTamCod  := TamSx3("A2_COD")[1]
Local cTamLoj  := TamSx3("A2_LOJA")[1]
Local cDescricao:= Substr(cFornece,1,cTamCod)+"-"+Substr(cFornece,cTamCod+1,cTamLoj )


//Chamo O WS para criar a pasta no FLUIG - CRIANDO A PASTA PAI DO FORNECEDOR
cXMLRetFol += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.dm.ecm.technology.totvs.com/">'
cXMLRetFol += '<soapenv:Header/>'
cXMLRetFol += '<soapenv:Body>'
cXMLRetFol += '    <ws:createSimpleFolder>'
cXMLRetFol += '        <username>'+ cUsername +'</username>'
cXMLRetFol += '        <password>'+ cPassword +'</password>'
cXMLRetFol += '        <companyId>'+ cCompId +'</companyId>'
cXMLRetFol += '        <parentDocumentId>'+ Alltrim(cDocId) +'</parentDocumentId>'
cXMLRetFol += '        <publisherId>'+ cUsername +'</publisherId>'
cXMLRetFol += '        <documentDescription>'+ AllTrim(cDescricao) +'</documentDescription>'
cXMLRetFol += '    </ws:createSimpleFolder>'
cXMLRetFol += '</soapenv:Body>'
cXMLRetFol += '</soapenv:Envelope>'

aXMLRetFol := startFol(FwCutOff(cXMLRetFol , .T.), cURL)
If aXMLRetFol[1]  
    cDirFluig := aXMLRetFol[2]
    cDirFluSol := u_SXTagCont("documentId",cDirFluig)    
    cTexto := "Nr. Folder Fluig criado: " + cDirFluSol + " Processo Fluig Diretório"
    FWLogMsg("INFO",,"FLUIG INTEG",,,,cTexto,,,) 
else
    lContinua := .F.
endif

if lContinua
    // Grava a pasta do Forneecedor na TABFOLDER
    U_GrvTabFolder("1",cFornece,cDocId,cDirFluSol)
    aadd(aFolder,cDirFluSol)  // 
    cPastaPai := cDirFluSol
    // Cria Folders Filhas
    for n:= 2 to 5
        aResult:= U_CriaFldFilha(n,cFornece,cPastaPai,cCompId,cUsername,cPassword,cURL) 
        if n==Val(cTipDoc)
            aadd(aFolder,aResult[2])
        endif
        if aResult[1]  
            cDescricao:= BuscaDescr(n)
            U_GrvTabFolder(cValtoChar(n),cFornece,cPastaPai,aResult[2],cDescricao)
        Endif
    next
endif
Return aFolder


/*/{Protheus.doc} startFol
Transmissão do XML via Soap para Criação do Pasta no Fluig
@type function
@version 1.0 
@since 01/08/2023
@author Carla Barbosa
*/

Static function startFol(cXMLRetFol,cURL)
	
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
		cTexto:= "Erro ParseURL: " + oWsdl:cError
        FWLogMsg("INFO",,"FLUIG INTEG",,,,cTexto,,,) 
		lContinua := .F.
	EndIf

	If lContinua
		lRet := oWsdl:SetOperation("createSimpleFolder")
		If ! lRet
			cTexto := "Erro SetOperation: " + oWsdl:cError
            FWLogMsg("INFO",,"FLUIG INTEG",,,,cTexto,,,) 
			lContinua := .F.
		EndIf
	EndIf

	If lContinua
		lRet := oWsdl:SendSoapMsg( cXMLRetFol )
		cXMLResp := oWsdl:GetSoapResponse()
		oXml := XmlParser(cXMLResp, "", @cError, @cWarning)
		if AT( "<documentId>0</documentId>", cXMLResp ) != 0
			cTexto := "Erro de retorno" 
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
return {lContinua, cXMLResp}
 
/*/{Protheus.doc} CriaFldFilha
WS para Criar Folder Filhas no Fluig [COMPRAS - CONTRATOS - NF - TITULOS]
@type function
@version 1.0 
@since 01/08/2023
@author Carla Barbosa
*/
User Function CriaFldFilha(cTip,cFornece,cPastaPai,cCompId,cUsername,cPassword,cURL,cENTIDADE)
Local cDocIdF    := Alltrim(cPastaPai)
Local lContinua := .T.
Local cXMLRetFol:= ""
Local cDescricao:= "" 
DEFAULT cENTIDADE := "" 
cDescricao:= BuscaDescr(cTip,cENTIDADE)

//Chamo O WS para criar a pasta no FLUIG - CRIANDO A PASTA PAI DO FORNECEDOR
cXMLRetFol += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ws="http://ws.dm.ecm.technology.totvs.com/">'
cXMLRetFol += '<soapenv:Header/>'
cXMLRetFol += '<soapenv:Body>'
cXMLRetFol += '    <ws:createSimpleFolder>'
cXMLRetFol += '        <username>'+ cUsername +'</username>'
cXMLRetFol += '        <password>'+ cPassword +'</password>'
cXMLRetFol += '        <companyId>'+ cCompId +'</companyId>'
cXMLRetFol += '        <parentDocumentId>'+ Alltrim(cDocIdf) +'</parentDocumentId>'
cXMLRetFol += '        <publisherId>'+ cUsername +'</publisherId>'
cXMLRetFol += '        <documentDescription>'+AllTrim(cDescricao) +'</documentDescription>'
cXMLRetFol += '    </ws:createSimpleFolder>'
cXMLRetFol += '</soapenv:Body>'
cXMLRetFol += '</soapenv:Envelope>'

aXMLRetFol := startFol(FwCutOff(cXMLRetFol , .T.),cURL )
If aXMLRetFol[1]  
    cDirFluig := aXMLRetFol[2]
    cDirFluSol := u_SXTagCont("documentId",cDirFluig)   //ubstr(cDirFluig,275,3) //Substr(cDirFluig,274,3) -> Sarepta
    cTexto:= "Nr. Folder Fluig criado: " + cDirFluSol + " Processo Fluig Diretório"
    FWLogMsg("INFO",,"FLUIG INTEG",,,,cTexto,,,) 
else
    lContinua := .F.
endif
Return {lContinua,cDirFluSol }


/*/{Protheus.doc} GrvTabFolder
Grava o Registro na Tabela TABFOLDER
@type function
@version 1.0 
@since 01/08/2023
@author Carla Barbosa
*/
User Function GrvTabFolder(cTip,cFornece,cPastaPai,cPasta,cDescricao,cENTIDADE)

DEFAULT cDescricao := ""
DEFAULT cPastaPai  := 0
DEFAULT cENTIDADE  := ""

RecLock('TABFOLDER',.t.)
TABFOLDER->CODIGO  := cFornece
TABFOLDER->IDPASTA := cPasta
TABFOLDER->FLDPAI  := cPastaPai
TABFOLDER->FLDNAME := cDescricao 
TABFOLDER->TIPO    := cTip
TABFOLDER->ENTIDADE:= cENTIDADE
TABFOLDER->(MSUNLOCK())
Return .t.

/*/{Protheus.doc} GrvTabDoc
Grava o Registro na Tabela TABDOC
@type function
@version 1.0 
@since 04/08/2023
@author Carla Barbosa
*/
User Function GrvTabDoc(cFornece,cPastaPai,cIDDOC,cFileName,cTabOrig,cENTIDADE)

RecLock('TABDOC',.t.)
TABDOC->CODIGO  := cFornece
TABDOC->IDPASTA := cPastaPai
TABDOC->IDDOC   := cIDDOC
TABDOC->FILENAME:= cFileName 
TABDOC->TABELA  := cTabOrig
TABDOC->ENTIDADE:= cENTIDADE
TABDOC->(MSUNLOCK())
Return .t.

/*/{Protheus.doc} EzTabFolder
Cria ou Abre a Tabela TABFOLDER no Banco de Dados
@type function
@version 1.0 
@since 01/08/2023
@author Carla Barbosa
*/
User Function EzTabFolder(cTabela) // Cria/abre as tabelas

Local aStru := {}
Local cTamCod  := TamSx3("A2_COD")[1]
Local cTamLoj  := TamSx3("A2_LOJA")[1]
If Select(cTabela) == 0

        aStru := {  { "CODIGO"  , "C" , cTamCod+cTamLoj , 0 },;  // Código+Loja do Fornecedor
                    { "IDPASTA" , "C" , 10 , 0 },;    // ID DA PASTA DO FORNECEDOR NO FLUIG
                    { "FLDPAI"  , "C" , 10 , 0 },;    // ID DA PASTA PAI NO FLUIG
                    { "FLDNAME" , "C" , 100 , 0 },;   // NOME DA PASTA
                    { "TIPO"    , "C" , 50 , 0 },;    // TIPO DA PASTA [FORNECEDOR - SUBPASTA - CONTRATOS - PEDIDOS - NF - TITULOS]
                    { "ENTIDADE", "C" , 100 , 0 }}    // CÓDIGO DA ENTIDADE 
        
        cTabela := upper(AllTrim(cTabela))

        If !MsFile(cTabela,,"TOPCONN")
            dbCreate(cTabela, aStru, "TOPCONN")
            dbUseArea(.T.,"TOPCONN",cTabela,cTabela,.F.)
            (cTabela)->(dbCreateIndex( cTabela+'1' , "CODIGO" , {||CODIGO}) )
            (cTabela)->(dbCreateIndex( cTabela+'2' , "ENTIDADE" , {||ENTIDADE}) )
            (cTabela)->(dbCloseArea())
        EndIf
        dbUseArea(.T.,"TOPCONN",cTabela,cTabela,.T.)
        (cTabela)->(DbSetIndex(cTabela+'1'))
        
EndIf 
Return

/*/{Protheus.doc} EzTabDoc
Cria ou Abre a Tabela TABDOC no Banco de Dados
@type function
@version 1.0 
@since 04/08/2023
@author Carla Barbosa
*/
User Function EzTabDoc(cTabDoc) // Cria/abre as tabelas

Local aStru := {}
Local cTamCod  := TamSx3("A2_COD")[1]
Local cTamLoj  := TamSx3("A2_LOJA")[1]
If Select(cTabDoc) == 0

        aStru := {  { "CODIGO"  , "C" , cTamCod+cTamLoj , 0 },;  // Código+Loja do Fornecedor
                    { "IDPASTA" , "C" , 10 , 0 },;    // ID DA PASTA EM QUE O DOCUMENTO ESTA LOCALIZADO
                    { "IDDOC"   , "C" , 10 , 0 },;    // ID DO DOCUMENTO NO FLUIG
                    { "FILENAME", "C" , 100 , 0},;    // NOME DO DOCUMENTO COM A EXTENSAO
                    { "TABELA"  , "C" , 50 , 0 },;    // TABELA DA ENTIDADE PODENDO SER [CN9 - CND - SC7 - SF1 - SE2]
                    { "ENTIDADE", "C" , 100 , 0}}     // CÓDIGO DA ENTIDADE 
        
        cTabDoc := upper(AllTrim(cTabDoc))

        If !MsFile(cTabDoc,,"TOPCONN")
            dbCreate(cTabDoc, aStru, "TOPCONN")
            dbUseArea(.T.,"TOPCONN",cTabDoc,cTabDoc,.F.)
            (cTabDoc)->(dbCreateIndex( cTabDoc+'1' , "FILENAME" , {||FILENAME}) )
            (cTabDoc)->(dbCloseArea())
        EndIf
        dbUseArea(.T.,"TOPCONN",cTabDoc,cTabDoc,.T.)
        (cTabDoc)->(DbSetIndex(cTabDoc+'1'))
        
EndIf 
Return


Static Function BuscaDescr(cTip,cEntidade)
Local cDescricao
DEFAULT cEntidade := ""
if cTip == 2
    cDescricao := "COMPRAS"
Elseif cTip == 3
    cDescricao := "CONTRATOS"
Elseif cTip == 4
    cDescricao := "NF"
Elseif cTip == 5 
    cDescricao := "TITULOS"
Else
    cDescricao := cEntidade
Endif
Return cDescricao


User Function EnviaDoc(cTip,cFornece,cCompId,cUsername,cPassword,cPastaPai,cDescArq,cFileName,cArqBase64,cUrlDoc,cENTIDADE,cTABORIG)
Local lContinua := .T.
Local cXMLRetDoc:= "" 
DEFAULT cENTIDADE := "" 
 

//Chamo o WS para Anexar os arquivos na pasta criada pelo WS anterior
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
aXMLRetDoc := startDoc(FwCutOff(cXMLRetDoc , .T.), cUrlDoc)
If aXMLRetDoc[1]
    cDocFluig := aXMLRetDoc[2]
    cDocFluSol := u_SXTagCont("documentId",cDocFluig)
    cTexto:= "Nr. Documento Fluig criado: " + cDocFluSol + " Processo Fluig Diretório"
    FWLogMsg("INFO",,"FLUIG INTEG",,,,cTexto,,,) 
    lContinua := .t.
else
    lContinua := .F.
endif
if lContinua
   U_GrvTabDoc(cFornece,cPastaPai,cDocFluSol,cFileName,cTABORIG,cENTIDADE)
Endif
Return lContinua


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
return {lContinua, cXMLResp}

/*

/*=====================================================================================================================================*/

user function  SXTagCont( cTag , cXML ) // retorna o sá conteádo da TAG
local cU_XMl:= Alltrim(Upper(cXMl))  // tudo em maisculo para
local cU_Tag:= Alltrim(Upper(cTag))  // facilitar a busca
local cRet:="", nPosIni:=0, nTamCtd:=0
local i:=0, nMax:=Len(cU_XML)

cXML := AllTrim(cXML)

nPosIni := At("<"+cU_Tag+">", cU_XML)       // acha o 1á inicio da tag de abertura
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
   if nTamCtd > 0                                 // Se existe conteádo
      cRet:= Substr( cXML, nPosINI, nTamCtd )     // extrai do xml original
   endif                                          // para náo retornar tudo em maiásculo

endif
return cRet
