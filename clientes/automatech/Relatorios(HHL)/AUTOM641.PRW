
#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TRYEXCEPTION.CH"

#IFNDEF CRLF
 #DEFINE CRLF Chr(13)+Chr(10)
#EndIF 

#DEFINE STR0001 "Serviço de consulta aos Documentos de Saída (NFSe)"
#DEFINE STR0002 "Método de consulta as informações do documento saida (NFSe)"
#DEFINE STR0003 "Cliente invalido"
#DEFINE STR0004 "CNPJ invalido"
#DEFINE STR0005 "Documento nao encontrado"
#DEFINE STR0006 "A Especie dessa nota nao e 'SPED'"
#DEFINE STR0007 "Problema na conexao com Totvs Sped Services"
#DEFINE STR0008 "Problema no Retorno da Nota Fiscal"
#DEFINE STR0009 "Nao foi Possivel Obter o Codigo da Entidade. Verifique a sua Configuracao do SPED"

/*/
WSSERVICE: u_wsGetXmlNFSe
Autor: Marinaldo de Jesus
Data: 01/07/2010
Descrição: Serviço de Constulta a Nota Fiscal de Saida ( Eletrônica )
/*/
WSSERVICE u_wsGetXmlNFSe DESCRIPTION STR0001 NAMESPACE "http://localhost/naldo/ws/u_wsgetxmlnfse.apw" //"Serviço de consulta aos Documentos de Saída (NFSe)"

 WSDATA CodEmp   AS String OPTIONAL
 WSDATA CodFil   AS String OPTIONAL
 WSDATA CNPJ   AS String
 WSDATA NumeroDaNFS AS String
 WSDATA XMLNFe   AS String OPTIONAL
 
 WSMETHOD GetXmlNFSe DESCRIPTION STR0002 //"Método de consulta as informações do documento saida (NFSe)"


ENDWSSERVICE

/*/
WSMETHOD: GetXmlNFSe
Autor: Marinaldo de Jesus
Data:16/07/2010
Descrição: Obter e retornar a Nota Fiscal de Saida Eletrônica
/*/
WSMETHOD GetXmlNFSe WSRECEIVE CodEmp,CodFil,CNPJ,NumeroDaNFS WSSEND XMLNFe WSSERVICE u_wsGetXmlNFSe

 Local cUrl    := ""
 Local cDoc    := ""
 Local cSerie   := ""
 Local cIdEnt   := "" 
 Local cCliente   := ""
 Local cLojaCli   := ""
 Local cSA1Filial  := ""
 Local cSF2Filial  := ""
 Local cGetIdEntErr  := ""
 Local cMsgSoapFault := ""

 Local lReturn   := .T.
 Local lRetornaFxOk := .F.

 Local oException
 Local oWsNFeSBRA
 
 TRYEXCEPTION
 
  DEFAULT Self:CodEmp := "01"
  DEFAULT Self:CodFil := "01"
  
  RpcSetType(3)

  
  IF FindFunction("WfPrepEnv")
  
   WfPrepEnv( Self:CodEmp , Self:CodFil )

  
  Else
  
   PREPARE ENVIRONMENT EMPRESA Self:CodEmp FILIAL Self:CodFil
  
  EndIF
  
  TRYEXCEPTION
  
   IF Empty(Self:CNPJ)

    cMsgSoapFault := STR0003 //"Cliente invalido"
    BREAK
   EndIF
   
   Self:CNPJ := UnMaskCNPJ( Self:CNPJ )

   
   cSA1Filial := xFilial( "SA1" )
   cSF2Filial := xFilial( "SF2" )

   
   SA1->( dbSetOrder( RetOrder( "SA1" , "A1_FILIAL+A1_CGC" ) ) )

   
   IF SA1->( !dbSeek( cSA1Filial + Self:CNPJ , .F. ) )

    cMsgSoapFault := STR0004 + " :: " + TransForm( Self:CNPJ , GetSx3Cache( "A1_CGC" , "X3_PICTURE" ) ) //"CNPJ invalido"

    BREAK
   EndIF
   
   SA1->( dbSetOrder( RetOrder( "SA1" , "A1_FILIAL+A1_COD+A1_LOJA" ) ) )

   
   cCliente := SA1->A1_COD 
   
   cLojaCli := SA1->A1_LOJA
   
   cDoc := Padr( AllTrim( Self:NumeroDaNFS ) , GetSx3Cache( "D2_DOC" , "X3_TAMANHO" ) )

   
   SF2->( dbSetOrder( RetOrder( "SF2" , "F2_FILIAL+F2_CLIENTE+F2_LOJA+F2_DOC+F2_SERIE" ) ) )

   
   IF SF2->( !dbSeek( cSF2Filial + cCliente + cLojaCli + cDoc , .F.) )

    cMsgSoapFault := STR0005 + " :: " + TransForm( Self:CNPJ , GetSx3Cache( "A1_CGC" , "X3_PICTURE" ) ) + "Self:" + cSF2Filial+cCliente+cLojaCli+cDoc //"Documento nao encontrado"

    BREAK
   EndIF
   
   IF !( "SPED" $ SF2->F2_ESPECIE )

    cMsgSoapFault := STR0006 + " :: " + TransForm( Self:CNPJ , GetSx3Cache( "A1_CGC" , "X3_PICTURE" ) ) + "Self:" + cSF2Filial+cCliente+cLojaCli+cDoc //"A Especie dessa nota nao e 'SPED'"

    BREAK
   EndIF
   
   cSerie := SF2->F2_SERIE
   
   SF2->( dbSetOrder(1) )

   
   IF SF2->( !dbSeek(cSF2Filial+cDoc+cSerie+cCliente+cLojaCli,.F.) )

    cMsgSoapFault := STR0005 + "Self:" + cSF2Filial+cDoc+cSerie+cCliente+cLojaCli //"Documento nao encontrado"

    BREAK
   EndIF
   
   cURL := PadR(GetNewPar("MV_SPEDURL","http://"),250)

   
   IF !( CTIsReady(cURL) )
    cMsgSoapFault := STR0007 + " :: " + cURL //"Problema na conexao com Totvs Sped Services"

    BREAK
   EndIF
   
   cURL := AllTrim(cURL)+"/NFeSBRA.apw"
   
   IF !( CTIsReady(cURL) )

    cMsgSoapFault := STR0007 + " :: " + cURL //"Problema na conexao com Totvs Sped Services"
    BREAK
   EndIF

   
   cIdEnt := GetIdEnt( @cGetIdEntErr )
   
   IF Empty( cIdEnt )

    IF Empty( cGetIdEntErr )
     cGetIdEntErr := STR0009 //"Nao foi Possivel Obter o Codigo da Entidade. Verifique a sua Configuracao do SPED"
    EndIF

    cMsgSoapFault := cGetIdEntErr
    BREAK
   EndIF
   
   oWsNFeSBRA       := WSNFeSBRA():New()

   oWsNFeSBRA:cUSERTOKEN   := "TOTVS"
   oWsNFeSBRA:cID_ENT     := cIdEnt 
   oWsNFeSBRA:_URL     := cURL
   oWsNFeSBRA:cIdInicial    := cSerie+cDoc
   oWsNFeSBRA:cIdFinal    := cSerie+cDoc
   oWsNFeSBRA:dDataDe     := Stod("19701512") //SF2->F2_EMISSAO

   oWsNFeSBRA:dDataAte    := Stod("20701512") //SF2->F2_EMISSAO
   oWsNFeSBRA:cCNPJDESTInicial  := Self:CNPJ
   oWsNFeSBRA:cCNPJDESTFinal   := Self:CNPJ
   oWsNFeSBRA:nDiasparaExclusao := 0

   
   lRetornaFxOk      := oWsNFeSBRA:RetornaFX()
   
   DEFAULT lRetornaFxOk := .F.
   
   IF !( lRetornaFxOk )

    cMsgSoapFault := STR0008 //"Problema no Retorno da Nota Fiscal"
    BREAK
   EndIF
   
   nItens := Len( oWsNFeSBRA:oWsRetornaFxResult:oWsNotas:oWsNFES3 )

   
   For nItem := 1 To nItens
    Self:XMLNFe := oWsNFeSBRA:oWsRetornaFxResult:oWsNotas:oWsNFES3[nItem]:oWsNFE:cXML
    Exit

   Next nItem
  
  CATCHEXCEPTION USING oException 
  
   lReturn := .F.
  
   IF ( ValType( oException ) == "O" )

  
   cMsgSoapFault += IF( !Empty( oException:Description ) , oException:Description , "" )

   cMsgSoapFault += IF( !Empty( oException:ErrorStack ) , oException:ErrorStack , "" )

  
   EndIF 
  
   SetSoapFault( "GetXmlNFSe" , cMsgSoapFault )
  
  ENDEXCEPTION
 
 CATCHEXCEPTION USING oException
 
  lReturn := .F.
 
  IF ( ValType( oException ) == "O" )

   cMsgSoapFault += IF( !Empty( oException:Description ) , oException:Description , "" )

   cMsgSoapFault += IF( !Empty( oException:ErrorStack ) , oException:ErrorStack , "" )

  EndIF 
 
  SetSoapFault( "GetXmlNFSe" , cMsgSoapFault )
 
 ENDEXCEPTION
 
 RESET ENVIRONMENT

Return( lReturn )

/*/
Funcao: UnMaskCNPJ
Autor: Marinaldo de Jesus
Data: 16/07/2010

Descrição: Retirar a Máscara do CNPJ
/*/
Static Function UnMaskCNPJ( cCNPJ )

 Local cCNPJClear := CNPJ
 
 BEGIN SEQUENCE
 
  IF Empty( cCNPJClear )
   BREAK
  EndIF

  
  cCNPJClear := StrTran( cCNPJClear , "." , "" )

  cCNPJClear := StrTran( cCNPJClear , "/" , "" )

  cCNPJClear := StrTran( cCNPJClear , "-" , "" )

  cCNPJClear := AllTrim( cCNPJClear )
  
 END SEQUENCE

Return( cCNPJClear )

/*/
Funcao: GetIdEnt
Autor: Marinaldo de Jesus
Data: 06/07/2010

/*/
Static Function GetIdEnt( cError )

 Local aArea := GetArea()

 Local cIdEnt := ""
 Local cURL := PadR(GetNewPar("MV_SPEDURL","http://"),250)

 Local lMethodOk := .F.
 
 Local oWsSPEDAdm
 
 BEGIN SEQUENCE
 
  IF !( CTIsReady(cURL) )
   BREAK
  EndIF
  
  cURL := AllTrim(cURL)+"/SPEDADM.apw"
  
  IF !( CTIsReady(cURL) )
   BREAK
  EndIF
  
  oWsSPEDAdm          := WsSPEDAdm():New()

  oWsSPEDAdm:cUSERTOKEN       := "TOTVS"
  oWsSPEDAdm:oWsEmpresa:cCNPJ     := SM0->( IF(M0_TPINSC==2 .Or. Empty(M0_TPINSC),M0_CGC,"") )
  oWsSPEDAdm:oWsEmpresa:cCPF      := SM0->( IF(M0_TPINSC==3,M0_CGC,"") )
  oWsSPEDAdm:oWsEmpresa:cIE      := SM0->M0_INSC
  oWsSPEDAdm:oWsEmpresa:cIM      := SM0->M0_INSCM 
  oWsSPEDAdm:oWsEmpresa:cNOME     := SM0->M0_NOMECOM
  oWsSPEDAdm:oWsEmpresa:cFANTASIA    := SM0->M0_NOME
  oWsSPEDAdm:oWsEmpresa:cENDERECO    := FisGetEnd(SM0->M0_ENDENT)[1]
  oWsSPEDAdm:oWsEmpresa:cNUM      := FisGetEnd(SM0->M0_ENDENT)[3]
  oWsSPEDAdm:oWsEmpresa:cCOMPL     := FisGetEnd(SM0->M0_ENDENT)[4]
  oWsSPEDAdm:oWsEmpresa:cUF      := SM0->M0_ESTENT
  oWsSPEDAdm:oWsEmpresa:cCEP      := SM0->M0_CEPENT
  oWsSPEDAdm:oWsEmpresa:cCOD_MUN     := SM0->M0_CODMUN
  oWsSPEDAdm:oWsEmpresa:cCOD_PAIS    := "1058"
  oWsSPEDAdm:oWsEmpresa:cBAIRRO     := SM0->M0_BAIRENT
  oWsSPEDAdm:oWsEmpresa:cMUN      := SM0->M0_CIDENT
  oWsSPEDAdm:oWsEmpresa:cCEP_CP     := NIL
  oWsSPEDAdm:oWsEmpresa:cCP      := NIL
  oWsSPEDAdm:oWsEmpresa:cDDD      := Str(FisGetTel(SM0->M0_TEL)[2],3)
  oWsSPEDAdm:oWsEmpresa:cFONE     := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
  oWsSPEDAdm:oWsEmpresa:cFAX      := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
  oWsSPEDAdm:oWsEmpresa:cEMAIL     := UsrRetMail(RetCodUsr())
  oWsSPEDAdm:oWsEmpresa:cNIRE     := SM0->M0_NIRE
  oWsSPEDAdm:oWsEmpresa:dDTRE     := SM0->M0_DTRE
  oWsSPEDAdm:oWsEmpresa:cNIT      := SM0->( IF(M0_TPINSC==1,M0_CGC,"") )
  oWsSPEDAdm:oWsEmpresa:cINDSITESP    := ""
  oWsSPEDAdm:oWsEmpresa:cID_MATRIZ    := ""
  oWsSPEDAdm:oWsOutrasInscricoes:oWsInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
  oWsSPEDAdm:_URL        := cURL

  lMethodOk := oWsSPEDAdm:AdmEmpresas()

  DEFAULT lMethodOk := .F.
  
  IF !( lMethodOk )
   cError := IF( Empty( GetWscError(3) ) , GetWscError(1) , GetWscError(3) )
   BREAK
  EndIF
  
  cIdEnt := oWsSPEDAdm:cAdmEmpresasResult
  
 END SEQUENCE
 
 RestArea(aArea)

Return( cIdEnt )
      


Read more: http://www.blacktdn.com.br/2010/07/protheus-retornando-o-xml-do-documento.html#ixzz4uLh0Ml5y