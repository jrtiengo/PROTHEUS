#INCLUDE "TOTVS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "XMLXFUN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "PARMTYPE.CH"

/*/-----------------------------------------------------------------/
{Protheus.doc} MARS040
Rotina para execução via Schedule
Receber o XML da Sefaz das notas de entrada, verificar se possui as tags
de pedido de compra e item, se tiver, verificar se existe divergência,
e nesse caso deve gravar a divergência em uma tabela.

@type  User Function
@author Jean Rehermann - Solutio IT
@since 18/01/2021
@param aParam Array[2] - { [1] Empresa / [2] Filial }
@return Nil
/-----------------------------------------------------------------/*/

User Function MARS040( aParam )

	Default aParam := {"01","01"}
	RPCSetType( 3 ) //Nao consome licensa de uso
	Prepare Environment Empresa aParam[01] Filial aParam[02] Tables "ZX1","ZX2","ZX3","SA1","SA2","SA5","SA7","SF1","SF2"

	Conout( "Rotina MARS040" )
	Conout(	"Empresa logada: " + aParam[01] )
	Conout( "Filial logada: " + aParam[02] )

	Conout( "MARS040 - " + DtoC( Date() ) + " - " + Time() + " - Iniciando o processo de verificacao de divergencias" )
	U_MARS04_1( aParam )
	Conout( "MARS040 - Verificacao finalizada!" )

	Reset Environment

Return NIL

// Função para o schedule de baixa dos arquivos
User Function MARS04_1( aParam )

	Private cLog      := ""
	Private cWorkDir  := ""
	Private lBxXmlAnt := .F.
	Private lTesIntOp := .F.
	Private cNomFile  := "" // Variável utilizada no download de arquivo único
	Private cPedComp  := "" // Valida pedidos (importação ou classificação)
	Private cValProd  := "" // Valida produtos (importação ou classificação)
	Private cPrdFrtV  := "" // Produto utilizado no frete sobre vendas/remessas
	Private cTesFrtV  := "" // Tes utilizado no frete sobre vendas/remessas
	Private cTesFrtC  := "" // Tes utilizado no frete sobre compras
	Private cPagFrtV  := "" // Condição utilizado no frete sobre vendas/remessas
	Private cPagFrtC  := "" // Condição utilizado no frete sobre compras
	Private lCadFImp  := .T.// Flag se cadastra fornecedor/cliente na importação
	Private nDiasJob  := 7  // Dias a considerar na validação das notas feita pelo job
	Private cMailJob  := "" // Conterá o(s) email(s) para onde será enviado o resultado do Job
	Private cCondPad  := "" // Condição de pagamento padrão para permitir a execução da rotina Execauto
	Private XMLCFCLI  := "" // CFOP que exige cadastro de cliente na entrada (tipo B)
	Private XMLCFRET  := "" // CFOPs de retorno (fornecedor, com nota referenciada)
	Private cPathPFX  := "" // Path do certificado pfx exportado
	Private cPassPFX  := "" // Senha do certificado em base64
	Private cCertPEM  := "" // Path do certificado em formato PEM
	Private cPKeyPEM  := "" // Path da chave privada em formato PEM
	Private cCaPEM    := "" // Path da autoridade certificadora em formato PEM
	Private cNsuCTe   := "" // NSU atual do CT-e
	Private cNsuNFe   := "" // NSU atual da NF-e
	Private cLoteEv   := "" // Lote atual do envio de eventos de manifestação
	Private cUsaLote  := "" // Usa lote nos documentos de entrada (lê a tag de lote e validade)
	Private cCodFMax  := "" // Maior código de fornecedor possível na inclusão automática
	Private cCodCMax  := "" // Maior código de cliente possível na inclusão automática
	Private cHorVer   := "" // Horario de verão
	Private cNatPadr  := "" // Código de natureza padrão quando não houver cadastrado no fornecedor
	Private cCNPJAtu  := ""
	Private nQtdDwld  := 0  // Indica a quantidade de notas que deve fazer download a cada ciclo para evitar excesso de uso no sefaz
	Private aEstados  := {{"11","RO"},{"12","AC"},{"13","AM"},{"14","RR"},{"15","PA"},{"16","AP"},{"17","TO"},{"21","MA"},{"22","PI"},{"23","CE"},{"24","RN"},{"25","PB"},{"26","PE"},{"27","AL"},{"28","SE"},{"29","BA"},{"31","MG"},{"32","ES"},{"33","RJ"},{"35","SP"},{"41","PR"},{"42","SC"},{"43","RS"},{"50","MS"},{"51","MT"},{"52","GO"},{"53","DF"}}

	cCNPJAtu := SM0->M0_CGC //"06221454000179"//

	// Diretorio de trabalho do programa
	cWorkDir := SuperGetMv("SOL_XML003",.F.,"\system\gestorxml\")

	// Se não existir, cria o diretório de trabalho e o de backup dos arquivos importados
	// Se não existir, cria o diretório de trabalho e o de backup dos arquivos importados por empresa cadastrada
	If !ExistDir( cWorkDir )
		MakeDir( cWorkDir )
		MakeDir( cWorkDir + AllTrim(cCNPJAtu) +"\" )
		MakeDir( cWorkDir + AllTrim(cCNPJAtu) +"\importados\" )
		MakeDir( cWorkDir + AllTrim(cCNPJAtu) +"\log\" )
		MakeDir( cWorkDir + AllTrim(cCNPJAtu) +"\problemas\" )
		MakeDir( cWorkDir + AllTrim(cCNPJAtu) +"\certs\" )
	Else
		If !ExistDir( cWorkDir + AllTrim(cCNPJAtu) +"\" )
			MakeDir( cWorkDir + AllTrim(cCNPJAtu) +"\" )
			MakeDir( cWorkDir + AllTrim(cCNPJAtu) +"\importados\" )
			MakeDir( cWorkDir + AllTrim(cCNPJAtu) +"\log\" )
			MakeDir( cWorkDir + AllTrim(cCNPJAtu) +"\problemas\" )
			MakeDir( cWorkDir + AllTrim(cCNPJAtu) +"\certs\" )
		Else
			If !ExistDir( cWorkDir + AllTrim(cCNPJAtu) +"\importados\" )
				MakeDir( cWorkDir + AllTrim(cCNPJAtu) +"\importados\" )
			EndIf
			If !ExistDir( cWorkDir + AllTrim(cCNPJAtu) +"\log\" )
				MakeDir( cWorkDir + AllTrim(cCNPJAtu) +"\log\" )
			EndIf
			If !ExistDir( cWorkDir + AllTrim(cCNPJAtu) +"\problemas\" )
				MakeDir( cWorkDir + AllTrim(cCNPJAtu) +"\problemas\" )
			EndIf
			If !ExistDir( cWorkDir + AllTrim(cCNPJAtu) +"\certs\" )
				MakeDir( cWorkDir + AllTrim(cCNPJAtu) +"\certs\" )
			EndIf
		EndIf
	EndIf

	// Parâmetro que indica se deve baixar o XML dos registros da C00 já manifestados anteriormente
	lBxXmlAnt := SuperGetMv("SOL_XML005",.F.,"N") == "S"

	// Parâmetro que indica o momento que será feita a validação do pedido de compras (importação ou classificação)
	cPedComp := AllTrim( SuperGetMv("SOL_XML006",.F.,"N") )

	// Parâmetro que indica o momento que será feita a validação dos produtos (importação ou classificação)
	cValProd := AllTrim( SuperGetMv("SOL_XML007",.F.,"N") )

	// Parâmetro que indica se cadastra cliente / fornecedor na tela de importação
	lCadFImp := AllTrim( SuperGetMv("SOL_XML008",.F.,"N") ) == "S"

	// Parâmetro que indica o produto do frete sobre venda/remessa
	cPrdFrtV := AllTrim( SuperGetMv("SOL_XML009",.F.,"") )

	// Parâmetro que indica a tes do frete sobre venda/remessa
	cTesFrtV := AllTrim( SuperGetMv("SOL_XML010",.F.,"") )

	// Parâmetro que indica a condição de pagamento do frete sobre venda/remessa
	cPagFrtV := PadR( SuperGetMv("SOL_XML011",.F.,""), 3 )

	// Parâmetro que indica a tes do frete sobre compra
	cTesFrtC := AllTrim( SuperGetMv("SOL_XML012",.F.,"") )

	// Parâmetro que indica a condição de pagamento do frete sobre compra
	cPagFrtC := Padr( SuperGetMv("SOL_XML013",.F.,""), 3 )

	// Dias a considerar na validação das notas feita pelo job
	nDiasJob := SuperGetMv("SOL_XML014",.F., 7 )

	// E-mail para enviar o resultado do Job
	cMailJob := SuperGetMv("SOL_XML015",.F., "" )

	// Parâmetro que indica a condição de pagamento padrão de documentos de entrada
	cCondPad := AllTrim( SuperGetMv("SOL_XML016",.F.,"001") )

	// Parâmetro que contém as CFOPs para tipo B e cadastro de cliente
	XMLCFCLI := AllTrim( SuperGetMv("SOL_XML017",.F.,"901/") )

	// Parâmetro que contém as CFOPs de retorno (fornecedor, com nota referenciada)
	XMLCFRET := AllTrim( SuperGetMv("SOL_XML018",.F.,"902/903/921/") )

	// Path do certificado pfx exportado
	cPathPFX := AllTrim( SuperGetMv("SOL_XML019",.F.,"") )

	// Senha do certificado em base64
	cPassPFX := AllTrim( SuperGetMv("SOL_XML020",.F.,"") )

	// Path do certificado em formato PEM
	cCertPEM := AllTrim( SuperGetMv("SOL_XML021",.F.,"") )

	// Path da chave privada em formato PEM
	cPKeyPEM := AllTrim( SuperGetMv("SOL_XML022",.F.,"") )

	// Path da autoridade certificadora em formato PEM
	cCaPEM := AllTrim( SuperGetMv("SOL_XML023",.F.,"") )

	// NSU atual do CT-e
	cNsuCTe := AllTrim( SuperGetMv("SOL_XML024",.F.,"000000000000000") )

	// Maior código de fornecedor possível na inclusão automática
	cCodFMax := AllTrim( SuperGetMv("SOL_XML025",.F.,Replicate( "9", Len( SA2->A2_COD ) ) ) )

	// Maior código de cliente possível na inclusão automática
	cCodCMax := AllTrim( SuperGetMv("SOL_XML026",.F.,Replicate( "9", Len( SA1->A1_COD ) ) ) )

	// Considera lote do XML
	cUsaLote := AllTrim( SuperGetMv("SOL_XML027",.F., "N" ) )

	// NSU atual da NF-e
	cNsuNFe := AllTrim( SuperGetMv("SOL_XML028",.F.,"000000000000000") )

	// Numeração dos lotes de envio de eventos (manifestação)
	cLoteEv := AllTrim( SuperGetMv("SOL_XML029",.F.,"000000000000000") )

	// Horário de verão (S/N)
	cHorVer := AllTrim( SuperGetMv("SOL_XML030",.F.,"N") )

	// Código de natureza padrão para a nota de entrada (caso não encontre no fornecedor)
	cNatPadr := AllTrim( SuperGetMv("SOL_XML031",.F.,"") )

	// Indica a quantidade de notas que deve fazer download a cada ciclo para evitar excesso de uso no sefaz
	nQtdDwld := SuperGetMv("SOL_XML032",.F.,10)

	// Flag que indica se deve ativar o download por schedule, caso .T., no botão de Download do gestor baixa apenas CT-e
	lAtivar := SuperGetMv("SOL_XML033",.F.,.F.)

	If lAtivar

		// Download da Sefaz com manifestação de ciência
		U_DXMLSEF()

		// Importação do diretório e análise de pedido de compras
		U_IMPXMLD( cWorkDir + cCNPJAtu + "\" )
	
	EndIf

Return

// Faz a leitura do diretório de trabalho do XML e importa as informações para a base de dados
User Function IMPXMLD( cDir )

	Local _cDir    := Iif( !Empty( cDir ),cDir,"\system\gestorxml\" + AllTrim(cCNPJAtu) + "\")
	Local _n       := 0
	Local cXMLPath := ""
	Local _cErr    := ""
	Local _cWrn    := ""
	Local aXML     := {}
	Local _lOk     := .T.

	Private _oXml   := Nil
	Private cBuffer := ""

	aXML := DIRECTORY( _cDir + "*.XML" )

	For _n := 1 To Len( aXML )

		cXMLPath := _cDir + aXML[ _n, 1 ]
		_lOk     := .F.

		If File( Alltrim( cXMLPath ) )

			_oXml := Nil

			// Cria o objeto XML
			_aObjXml := xCriaXML( Alltrim( cXMLPath ) )

			If Len( _aObjXml ) > 0
				_cErr := _aObjXml[ 1 ]
				_cWrn := _aObjXml[ 2 ]
			EndIf

			If _oXml != Nil
				If Type("_oXml:_NFEPROC") == "U" .And. Type("_oXml:_CTEPROC") == "U"
					// Formato de XML inválido!
					cLog += CXMLPATH + " | Formato de XML inválido" + CHR(13) + CHR(10)
				Else
					If ( Type("_oXml:_NFEPROC") != "U" .And. !(_oXml:_NFEPROC:_VERSAO:TEXT $ "3.10/4.00") ) .Or. ( Type("_oXml:_CTEPROC") != "U" .And. !(_oXml:_CTEPROC:_VERSAO:TEXT $ "3.00/2.00") )
						cLog += CXMLPATH + " | Versão de documento não suportada: "+ Iif( Type("_oXml:_NFEPROC") != "U",_oXml:_NFEPROC:_VERSAO:TEXT, Iif( Type("_oXml:_CTEPROC") != "U", _oXml:_CTEPROC:_VERSAO:TEXT, "" ) ) + CHR(13) + CHR(10)
						Loop
					EndIf

					// Processa as informações do XML
					If Type("_oXml:_NFEPROC") != "U"
						_lOk := LerXMLNfe( _oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT )
					EndIf
				EndIf
			Else
				cLog += CXMLPATH + " | Ocorreu um erro ao tentar carregar o arquivo" + CHR(13) + CHR(10)
			EndIf

		EndIf

		If _lOk
			If !File( _cDir +"importados\"+ aXML[ _n, 1 ] )
				frename( cXMLPath, _cDir +"importados\"+ aXML[ _n, 1 ] )
			Else
				FErase( cXMLPath )
			EndIf
		Else
			If !File( _cDir +"problemas\"+ aXML[ _n, 1 ] )
				frename( cXMLPath, _cDir +"problemas\"+ aXML[ _n, 1 ] )
			Else
				FErase( cXMLPath )
			EndIf
		EndIf

	Next

	If !Empty( cLog )
		MemoWrite( cWorkDir + AllTrim(cCNPJAtu) + "\log\"+Dtos(dDataBase)+StrTran(Time(),":","")+".txt", cLog )
		cLog := ""
	EndIf

Return()

// Função que analisa o conteúdo do xml e valida o documento fiscal NF-e
Static Function LerXMLNfe( cChvXml )

	Local nQtdEnt    := 0
	Local cQtdNF     := 0
	Local nBaseICM   := 0
	Local nValICM    := 0
	Local nPICM      := 0
	Local nBaseICMST := 0
	Local nValICMST  := 0
	Local nPICMST    := 0
	Local nBaseIPI   := 0
	Local nValIPI    := 0
	Local nPIPI      := 0
	Local nItNoPrd   := 0
	Local nItNoTes   := 0
	Local nTamSer    := 0
	Local _nCF       := 0
	Local _nPosCf    := 0
	Local _nLot      := 0
	Local aDet       := {}
	Local aLotes     := {}
	Local aNfRef     := {}
	Local cTpNf      := ""
	Local cFinNFe    := ""
	Local cTpAmb     := ""
	Local cNf        := ""
	Local cSerie     := ""
	Local cUf        := ""
	Local cF1_STATUS := ""
	Local cCodTes    := Space(3)
	Local cInfAdic   := ""
	Local cCST       := ""
	Local cCFOPCod   := ""
	Local cChvLog    := ""
	Local cPedXml    := ""
	Local cItPedXml  := ""
	Local lPnOk      := .F.
	Local lNfOk      := .F.
	Local lCfopRet   := .F.
	Local lCfopCli   := .F.
	Local _lStsA5A7  := .F.
	Local _lStsPedC  := .F.
	Local lUsaLote   := ( cUsaLote == "S" )
	Local aProds     := {}
	Local aCFOPItm   := {}
	Local aItemRet   := {}
	Local aDiverg    := {}
	Local dDtEmi     := CtoD("//")
	Local aSitTrib   := {"00","10","20","30","40","41","45","50","51","60","70","90"}
	Local _nX
	Local nY
	Local lResNfe := .F.
	Local nRecZX1 := 0
	Local cRegEmit   := ""
	Local cNomEmit   := ""

	Private aRetEnt := {}
	Private cTipoNf := ""

	oNF       := _oXml:_NFEPROC:_NFE
	oIdent    := oNF:_INFNFE:_IDE
	oEmitente := oNF:_INFNFE:_EMIT
	oDestino  := oNF:_INFNFE:_DEST
	oDet      := oNF:_INFNFE:_DET
	oTransp   := Iif( Type("oNF:_INFNFE:_TRANSP") == "U", Nil, oNF:_INFNFE:_TRANSP )
	oTotal    := Iif( Type("oNF:_INFNFE:_TOTAL") == "U", Nil, oNF:_INFNFE:_TOTAL )
	oDuplic   := Iif( Type("oNF:_INFNFE:_COBR") == "U", Nil, oNF:_INFNFE:_COBR )
	oInfAdic  := Iif( Type("oNF:_INFNFE:_INFADIC") == "U", Nil, oNF:_INFNFE:_INFADIC )
	oRefNfe   := Iif( Type("oIdent:_NFREF:_REFNFE") == "U", Nil, oIdent:_NFREF:_REFNFE )
	cUf       := Iif( Type("oEmitente:_ENDEREMIT:_UF") == "U", " ", oEmitente:_ENDEREMIT:_UF:TEXT )
	cInfAdic  := Iif( Type("oInfAdic:_INFCPL") == "U", " ", AllTrim( oInfAdic:_INFCPL:TEXT ) )
	oProtNfe  := _oXml:_NFEPROC:_PROTNFE:_INFPROT
	cChvLog   := oProtNfe:_CHNFE:TEXT

	aDet    := Iif( ValType( oDet ) == "O", {oDet}, oDet ) // Produtos
	aNfRef  := Iif( oRefNfe == Nil, {}, Iif( ValType( oRefNfe ) == "O", {oRefNfe}, oRefNfe ) ) // Notas referenciadas

	cTpNf   := oIdent:_TPNF:TEXT
	cFinNFe := oIdent:_FINNFE:TEXT
	cTpAmb  := oIdent:_TPAMB:TEXT
	dDtEmi  := StoD( StrTran( Left( oIdent:_DHEMI:TEXT, 10 ), "-", "" ) )

	lCfopCli := .F. // flag que define se a CFOP da nota exige cliente ao invés de fornecedor na entrada
	lCfopRet := .F. // flag que indica se a CFOP da nota é de retorno, com nota referenciada

	// Verificar se a nota foi emitida em ambiente de produção na Sefaz
	If cTpAmb == "2"
		cLog += cChvLog + " | Documento emitido em ambiente de homologação" + CHR(13) + CHR(10)
		ConOut( cChvLog +" - Documento emitido em ambiente de homologacao"  )
		Return( .F. )
	EndIf

	// Verificar o CNPJ do destinatário
	dbSelectArea("SM0")
	If cCNPJAtu != oDestino:_CNPJ:TEXT
		cLog += cChvLog + " | CNPJ do destinatário diferente de "+ cCNPJAtu + CHR(13) + CHR(10)
		ConOut( cChvLog +" - CNPJ do destinatario diferente de "+ cCNPJAtu  )
		Return( .F. )
	EndIf

	// Verifica se é uma nota de saída (uma nota de saída emitida no sistema não precisa ser importada e uma nota de entrada de outras
	// empresas não deve ser importada).
	If Type("oIdent:_TPNF:TEXT") == "U"
		cLog += cChvLog + " | Tag TPNF inexistente" + CHR(13) + CHR(10)
		ConOut( cChvLog +" - Tag TPNF inexistente"  )
		Return( .F. )
	Else
		If oIdent:_TPNF:TEXT == "0"
			cLog += cChvLog + " | Documento não é uma nota de saída" + CHR(13) + CHR(10)
			ConOut( cChvLog +" - Documento nao eh uma nota de saida"  )
			Return( .F. )
		EndIf
	EndIf

	// Procuro também pela chave da nfe caso esteja com formato numerico diferente do numero na SF1
	cQuery := "SELECT COUNT(*) AS TOT, F1_STATUS FROM " + RetSqlName("SF1")
	cQuery += " WHERE F1_CHVNFE  = '"+ oProtNfe:_CHNFE:TEXT +"'"
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery += "GROUP BY F1_STATUS"
	cQuery := ChangeQuery(cQuery)

	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
	cQtdNF     := (cAlias)->TOT
	cF1_STATUS := (cAlias)->F1_STATUS
	(cAlias)->( DbCloseArea() )

    // Também pesquiso pela chave na tabela de XML
	cQuery := "SELECT COUNT(*) AS TOT FROM " + RetSqlName("ZX1")
	cQuery += " WHERE ZX1_CHVNFE  = '"+ oProtNfe:_CHNFE:TEXT +"'"
	cQuery += " AND ZX1_STATUS <> '5' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
	cQtdXml := (cAlias)->TOT
	(cAlias)->( DbCloseArea() )

    // Verificar se tem resumo de NFe cadastrado = Status 5
	lResNfe := .F.
	nRecZX1 := 0
	cQuery := "SELECT R_E_C_N_O_ AS RECZX1 FROM " + RetSqlName("ZX1")
	cQuery += " WHERE ZX1_CHVNFE  = '"+ oProtNfe:_CHNFE:TEXT +"'"
	cQuery += " AND ZX1_STATUS = '5' "
	cQuery += " AND D_E_L_E_T_ = ' ' "

	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
	If !(cAlias)->(Eof())
		lResNfe := .T.
		nRecZX1 := (cAlias)->RECZX1
	EndIf
	(cAlias)->( DbCloseArea() )

	If cQtdXml > 0
		cLog += cChvLog + " | XML já foi importado " + CHR(13) + CHR(10)
		ConOut( cChvLog +" - XML ja foi importado"  )
		Return( .F. )
	Else
		If cQtdNF > 0 .And. !Empty( cF1_STATUS )
			lNfOk := .T.
		ElseIf cQtdNF > 0 .And. Empty( cF1_STATUS )
			lPnOk := .T.
		EndIf
	EndIf

	// Verifica a tag do CNPJ Emissor
	If Type("oEmitente:_CNPJ:TEXT") == "U"
		cLog += cChvLog + " | Tag CNPJ do emitente não existe " + CHR(13) + CHR(10)
		ConOut( cChvLog +" - Tag CNPJ do emitente nao existe" )
		Return( .F. )
	EndIf

	// Verifica se é devolução e prepara os dados para fazer o link com a nota original
	For _nCF := 1 To Len( aDet )

		cCFOPCod := AllTrim( aDet[_nCF]:_PROD:_CFOP:TEXT ) // Código da CFOP do item

		If Right( cCFOPCod, 3 ) $ XMLCFCLI // Se CFOP faz parte do grupo de CFOPs que exigem cliente na entrada, altera o flag
			lCfopCli := .T.
		EndIf

		If Right( cCFOPCod, 3 ) $ XMLCFRET // Se CFOP faz parte do grupo de CFOPs de retorno com nota referenciada, altera o flag
			lCfopRet := .T.
			aAdd( aItemRet, .T. ) // Marca que este item do XML prevê amarração de retorno com nota original
		Else
			aAdd( aItemRet, .F. ) // Este item não tem CFOP de retorno e não precisa de amarração
		EndIf

		_nPosCf := aScan( aCFOPItm, {|o| o == cCFOPCod } ) // Verifica se CFOP já está no array

		If _nPosCf == 0 // Se não estiver no array de CFOPs insere a mesma
			aAdd( aCFOPItm, cCFOPCod )
		EndIf

	Next

	// Verifica o tipo de nota
	cTipoNf := Iif( cFinNFe == "4", Iif( lCfopCli, "D", "N" ), Iif( cFinNFe == "2", "C", Iif( cFinNFe == "1", Iif( lCfopCli, "B", "N" ), " "  ) ) )

	// Valida quando é nota de devolução de venda (cliente)
	If cTipoNf =="D"

		// Sem notas Nf-e referenciadas
		If Len( aNfRef ) == 0
			cLog += cChvLog + " | Nota de devolução sem nota referenciada" + CHR(13) + CHR(10)
			ConOut( cChvLog +" - Nota de devolucao sem nota referenciada" )
			Return(.F.)
		EndIf

	EndIf

	// Verificar se existe o fornecedor ou o cliente cadastrado, através do CNPJ.
	cRegEmit := Iif( Type("oEmitente:_CNPJ:TEXT") != "U", oEmitente:_CNPJ:TEXT, oEmitente:_CPF:TEXT )
	cNomEmit := oEmitente:_XNOME:TEXT

	// Verificar se existe o fornecedor ou o cliente cadastrado, através do CNPJ.
	If cTipoNf $ "CN"
		cQuery := "SELECT A2_COD, A2_LOJA, A2_NOME FROM "+ RetSqlName("SA2") +" WHERE A2_MSBLQL <> '1' AND A2_CGC = '"+ cRegEmit +"' AND D_E_L_E_T_ = ' ' "
	Else
		cQuery := "SELECT A1_COD, A1_LOJA, A1_NOME FROM "+ RetSqlName("SA1") +" WHERE A1_MSBLQL <> '1' AND A1_CGC = '"+ cRegEmit +"' AND D_E_L_E_T_ = ' ' "
	EndIf

	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )

	If !(cAlias)->( Eof() )
		While !(cAlias)->( Eof() )
			nQtdEnt++
			(cAlias)->( dbSkip() )
		End
		(cAlias)->( dbGoTop() )
	EndIf

	If nQtdEnt == 0
		cLog += cChvLog + " | Cliente ou fornecedor não cadastrado (1)" + CHR(13) + CHR(10)
		ConOut( cChvLog +" - Cliente ou fornecedor nao cadastrado (1)" )
		Return .F.
	EndIf

	// Caso tenha mesmo CNPJ mais de uma vez no cadastro, selecionar qual fornecedor/cliente
	If nQtdEnt > 1
		cLog += cChvLog + " | Mais de um cliente ou fornecedor com mesmo CNPJ." + CHR(13) + CHR(10)
		ConOut( cChvLog +" - Mais de um cliente ou fornecedor com mesmo CNPJ" )
		Return .F.
	Else
		If cTipoNf $ "CN"

			dbSelectArea("SA2")
			dbSetOrder(3)
			dbSeek( xFilial("SA2") + cRegEmit )

			While !SA2->( Eof() ) .And. xFilial("SA2") + cRegEmit == SA2->A2_FILIAL + SA2->A2_CGC

				If SA2->A2_MSBLQL <> '1'
					aRetEnt := { { SA2->A2_COD, SA2->A2_LOJA } }
					Exit
				EndIf

				SA2->( dbSkip() )
			End

		Else

			dbSelectArea("SA1")
			dbSetOrder(3)
			dbSeek( xFilial("SA1") + cRegEmit )

			While !SA1->( Eof() ) .And. xFilial("SA1") + cRegEmit == SA1->A1_FILIAL + SA1->A1_CGC

				If SA1->A1_MSBLQL <> '1'
					aRetEnt := { { SA1->A1_COD, SA1->A1_LOJA } }
					Exit
				EndIf

				SA1->( dbSkip() )
			End

		EndIf
	EndIf

	// Verifica se existe algum valor no array
	If Empty( aRetEnt[ 1 ][ 1 ] )
		cLog += cChvLog + " | Cliente ou fornecedor não cadastrado (3)" + CHR(13) + CHR(10)
		ConOut( cChvLog +" - Cliente ou fornecedor nao cadastrado (3)" )
		Return( .F. )
	EndIf

	If Select( cAlias ) > 0
		(cAlias)->( DbCloseArea() )
	EndIf

	// Já com o código de cliente ou fornecedor definido, avalio os itens de retorno ou devolução
	If lCfopRet // Existe nos itens pelo menos um com CFOP de retorno
		If Len( aNfRef ) > 0 // Tenho que avaliar se no XML existe nota referenciada por ser retorno
			aRetRes := VerNfOri( aNfRef, aItemRet, aDet ) // Faz as devidas amarrações com a nota original
		Else
			cLog += cChvLog + " | Existe nos itens pelo menos um com CFOP de retorno e sem nota referenciada" + CHR(13) + CHR(10)
			ConOut( cChvLog +" - Existe nos itens pelo menos um com CFOP de retorno e sem nota referenciada" )
			Return( .F. )
		EndIf
	EndIf

	// Verificar se a nota fiscal já consta cadastrada no sistema
	If Type("oIdent:_NNF") == "O"
		cNf := StrZero( Val( oIdent:_NNF:TEXT ), TamSx3("F1_DOC")[ 1 ] )
	EndIf

	If Type("oIdent:_SERIE") == "O"
		nTamSer := TamSx3("F1_SERIE")[ 1 ]
		cSerie  := Right( Replicate( "0", nTamSer ) + AllTrim( oIdent:_SERIE:TEXT ), nTamSer )//PadR( AllTrim( oIdent:_SERIE:TEXT ), TamSx3("F1_SERIE")[ 1 ] )
	EndIf

	// Pesquisa na tabela de XML
	cQuery := "SELECT COUNT(*) AS TOT FROM " + RetSqlName("ZX1")
	cQuery += " WHERE ZX1_FILIAL = '"+ xFilial("ZX1") +"'"
	cQuery += " AND ZX1_DOC      = '"+ cNf +"'"
	cQuery += " AND ZX1_SERIE    = '"+ cSerie +"'"
	cQuery += " AND ZX1_CLIFOR   = '"+ aRetEnt[ 1 ][ 1 ] +"'"
	cQuery += " AND ZX1_LOJA     = '"+ aRetEnt[ 1 ][ 2 ] +"'"
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery := ChangeQuery(cQuery)

	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
	cQtdNF := (cAlias)->TOT
	(cAlias)->( DbCloseArea() )

	If cQtdNF > 0
		cLog += cChvLog + " | Nota já cadastrada no sistema (ZX1)" + CHR(13) + CHR(10)
		ConOut( cChvLog +" - Nota ja cadastrada no sistema (ZX1)" )
		Return( .F. )
	EndIf

	// Verificando os itens
	If ValType( aDet ) != "A"
		cLog += cChvLog + " | Documento sem itens identificados (1)" + CHR(13) + CHR(10)
		ConOut( cChvLog +" - Documento sem itens identificados (1)" )
		Return( .F. )
	Else
		If Len( aDet ) == 0
			cLog += cChvLog + " | Documento sem itens identificados (2)" + CHR(13) + CHR(10)
			ConOut( cChvLog +" - Documento sem itens identificados (2)" )
			Return( .F. )
		EndIf
	EndIf

	// Verificar se os produtos estão cadastrados no Produto x Fornecedor (SA5) ou Produto x Cliente (SA7)
	If cTipoNf $ "CN"
		dbSelectArea("SA5")
		dbSetOrder(14)
	Else
		dbSelectArea("SA7")
		dbSetOrder(3)
	EndIf

	lErro := .F.

	For _nX := 1 To Len( aDet )

		oProd    := aDet[ _nX ]
		cCodProd := Space( TamSX3("B1_COD")[ 1 ] )
		cCodPrf  := ""
		cDescPrf := ""

		cCodPrf  := oProd:_PROD:_CPROD:TEXT // Pego o código de produto do fornecedor/cliente
		cDescPrf := oProd:_PROD:_XPROD:TEXT // Pego a descrição do produto do fornecedor/cliente

		If !Empty( cCodPrf )

			If cTipoNf $ "CN"
				SA5->( dbSetOrder(14) )
			Else
				SA7->( dbSetOrder(3) )
			EndIf

			If ( cTipoNf $ "CN" .And. SA5->( dbSeek( xFilial("SA5") + aRetEnt[ 1 ][ 1 ] + aRetEnt[ 1 ][ 2 ] + cCodPrf ) ) ) .Or. ( cTipoNf $ "DB" .And. SA7->( dbSeek( xFilial("SA7") + aRetEnt[ 1 ][ 1 ] + aRetEnt[ 1 ][ 2 ] + cCodPrf ) ) )
				// Usa o código cadastrado na tabela SA5/SA7
				cCodProd := Iif( cTipoNf $ "CN", SA5->A5_PRODUTO, SA7->A7_PRODUTO )
			Else
				_lStsA5A7 := .T.
			EndIf

		EndIf

		If aScan( aProds, {|o| AllTrim( o[1] ) == AllTrim( cCodPrf ) } ) == 0
			aAdd( aProds, { cCodPrf, cCodProd, cDescPrf } )
		EndIf

	Next

	Begin Transaction

		// Gravar ZX2
		For _nX := 1 To Len( aDet )

			oProd    := aDet[ _nX ]

			// Verificação dos impostos
			nBaseICM   := 0
			nValICM    := 0
			nPICM      := 0
			nBaseICMST := 0
			nValICMST  := 0
			nPICMST    := 0
			nBaseIPI   := 0
			nValIPI    := 0
			nPIPI      := 0

			If Type("oProd:_IMPOSTO") == "O"

				If Type("oProd:_IMPOSTO:_ICMS") == "O"

					// Verifica em todas as situações tributárias
					For nY := 1 To Len( aSitTrib )

				 		If Type("oProd:_IMPOSTO:_ICMS:_ICMS"+ aSitTrib[ nY ] ) == "O" // Verifica a tag de cada situação tributária

				 			cCST := "0"+ &("oProd:_IMPOSTO:_ICMS:_ICMS"+ aSitTrib[ nY ] +":_CST:TEXT")

				 			If Type("oProd:_IMPOSTO:_ICMS:_ICMS"+ aSitTrib[ nY ] +":_VBC") == "O" // Verifica se tem a tag da base de cálculo do ICMS

					 			nBaseICM := Val( &("oProd:_IMPOSTO:_ICMS:_ICMS"+ aSitTrib[ nY ] +":_VBC:TEXT") )

					 			If Type("oProd:_IMPOSTO:_ICMS:_ICMS"+ aSitTrib[ nY ] +":_VICMSOP") == "O" // Verifica qual tag de imposto existe
									nValICM  := Val( &("oProd:_IMPOSTO:_ICMS:_ICMS"+ aSitTrib[ nY ] +":_VICMSOP:TEXT") )
								Else
									nValICM  := Val( &("oProd:_IMPOSTO:_ICMS:_ICMS"+ aSitTrib[ nY ] +":_VICMS:TEXT") )
								EndIf

								If Type("oProd:_IMPOSTO:_ICMS:_ICMS"+ aSitTrib[ nY ] +":_PICMS") == "O"
									nPICM    := Val( &("oProd:_IMPOSTO:_ICMS:_ICMS"+ aSitTrib[ nY ] +":_PICMS:TEXT") )
								EndIf
					 		EndIf

				 			If Type("oProd:_IMPOSTO:_ICMS:_ICMS"+ aSitTrib[ nY ] +":_VBCST") == "O" // Verifica se tem a tag da base de cálculo do ICMS ST

					 			nBaseICMST := Val( &("oProd:_IMPOSTO:_ICMS:_ICMS"+ aSitTrib[ nY ] +":_VBCST:TEXT") )
					 			nValICMST  := Val( &("oProd:_IMPOSTO:_ICMS:_ICMS"+ aSitTrib[ nY ] +":_VICMSST:TEXT") )
					 			nPICMST    := Val( &("oProd:_IMPOSTO:_ICMS:_ICMS"+ aSitTrib[ nY ] +":_PICMSST:TEXT") )

					 		EndIf

				 		EndIf

					Next nY

				EndIf

				// Verifica o IPI
				If Type("oProd:_IMPOSTO:_IPI") == "O"

					If Type("oProd:_IMPOSTO:_IPI:_IPITRIB:_VIPI") == "O"
						nValIPI := Val( oProd:_IMPOSTO:_IPI:_IPITRIB:_VIPI:TEXT )
					EndIf

					If Type("oProd:_IMPOSTO:_IPI:_IPITRIB:_PIPI") == "O"
						nPIPI := Val( oProd:_IMPOSTO:_IPI:_IPITRIB:_PIPI:TEXT )
					EndIf

					If Type("oProd:_IMPOSTO:_IPI:_IPITRIB:_VBC") == "O"
						nBaseIPI := Val( oProd:_IMPOSTO:_IPI:_IPITRIB:_VBC:TEXT )
					EndIf

				EndIf

			EndIf

			cCodPrf  := oProd:_PROD:_CPROD:TEXT // Pego o código de produto do fornecedor
			cCodProd := Space( TamSX3("B1_COD")[ 1 ] )
			_nPos    := aScan( aProds, {|o| AllTrim( o[1] ) == AllTrim( cCodPrf ) } )
			cTesInt  := ""

			If lCfopRet .And. aItemRet[ _nX ] .And. aScan( aRetRes, {|o| o[1] == _nX } ) > 0
				cCodProd := aRetRes[ aScan( aRetRes, {|o| o[1] == _nX } ), 5 ]
				SB1->( dbSetOrder(1) )
				SB1->( dbSeek( xFilial("SB1") + cCodProd ) )
			ElseIf _nPos > 0
				cCodProd := aProds[ _nPos, 2 ]
				SB1->( dbSetOrder(1) )
				SB1->( dbSeek( xFilial("SB1") + cCodProd ) )
			EndIf

			If !Empty( cCodProd )
				If lTesIntOp // Integrado ao TES inteligente
					If ValType( aTesIntOp ) == "A" .And. Len( aTesIntOp ) > 0 .And. !Empty( aTesIntOp[ 1, 1 ] )
						// Pesquiso pela CFOP qual a operação a utilizar para identificar a TES
						nPosOp := aScan( aTesIntOp, {|o| AllTrim( oProd:_PROD:_CFOP:TEXT ) $ AllTrim( o[2] ) } )
						If nPosOp > 0
							cTesInt := MaTesInt( 1, AllTrim( aTesIntOp[ nPosOp, 1 ] ), aRetEnt[ 1 ][ 1 ], aRetEnt[ 1 ][ 2 ], Iif( cTipoNf $ "CN", "F", "C" ), cCodProd, Nil )
						EndIf
					EndIf
				EndIf
				cCodTES := Iif( !Empty( cTesInt ), cTesInt, cCodTES )
			EndIf

			If Empty( cCodTES )
				cCodTES := Iif( Empty( cCodProd ), Space( Len( SD1->D1_TES ) ), SB1->B1_TE ) // TES de entrada padrão do produto
			EndIf

			// Tratamento do numero do pedido e item do pedido de compras
			If Type("oProd:_PROD:_XPED") == "O" .And. Type("oProd:_PROD:_NITEMPED") == "O"

				cPedXml   := AllTrim( oProd:_PROD:_XPED:TEXT )
				cItPedXml := AllTrim( oProd:_PROD:_NITEMPED:TEXT )

				If !Empty( cPedXml ) .And. !Empty( cItPedXml )
					cPedXml := StrZero( Val( cPedXml ), TamSX3("C7_NUM")[1] )
					cItPedXml := StrZero( Val( cItPedXml ), TamSX3("C7_ITEM")[1] )
					SC7->( dbSetOrder(1) )
					If !SC7->( dbSeek( xFilial("SC7") + cPedXml + cItPedXml ) )
						cPedXml   := ""
						cItPedXml := ""
						_lStsPedC := .T.
					EndIf
				Else
					_lStsPedC := .T.
				EndIf
			Else
				_lStsPedC := .T.
			EndIf

			// Tratamento para leitura de lote
			If lUsaLote .And. Type("oProd:_PROD:_RASTRO") != "U"

				oLotes := oProd:_PROD:_RASTRO
				aLotes := Iif( oLotes != Nil, Iif( ValType( oLotes ) == "O", {oLotes}, oLotes ), {} ) // Lotes

			EndIf

			nItNoPrd += Iif( Empty( cCodProd ), 1, 0 )
			nItNoTes += Iif( Empty( cCodTES ), 1, 0 )

			If lUsaLote .And. Len( aLotes ) > 0

				nBIPIOr   := nBaseIPI
				nVIPIOr   := nValIPI
				nBICMOr   := nBaseICM
				nVICMOr   := nValICM
				nBICMSTOr := nBaseICMST
				nVICMSTOr := nValICMST

				For _nLot := 1 To Len( aLotes )

					nBaseIPI   := Iif( nBIPIOr   > 0, ( nBIPIOr   / Val( oProd:_PROD:_QTRIB:TEXT ) ) * Val( aLotes[ _nLot ]:_QLOTE:TEXT ), 0 )
					nValIPI    := Iif( nVIPIOr   > 0, ( nVIPIOr   / Val( oProd:_PROD:_QTRIB:TEXT ) ) * Val( aLotes[ _nLot ]:_QLOTE:TEXT ), 0 )
					nBaseICM   := Iif( nBICMOr   > 0, ( nBICMOr   / Val( oProd:_PROD:_QTRIB:TEXT ) ) * Val( aLotes[ _nLot ]:_QLOTE:TEXT ), 0 )
					nValICM    := Iif( nVICMOr   > 0, ( nVICMOr   / Val( oProd:_PROD:_QTRIB:TEXT ) ) * Val( aLotes[ _nLot ]:_QLOTE:TEXT ), 0 )
					nBaseICMST := Iif( nBICMSTOr > 0, ( nBICMSTOr / Val( oProd:_PROD:_QTRIB:TEXT ) ) * Val( aLotes[ _nLot ]:_QLOTE:TEXT ), 0 )
					nValICMST  := Iif( nVICMSTOr > 0, ( nVICMSTOr / Val( oProd:_PROD:_QTRIB:TEXT ) ) * Val( aLotes[ _nLot ]:_QLOTE:TEXT ), 0 )

					dbSelectArea("ZX2")
					dbSetOrder(3)
					lGravaZX2 := dbSeek( xFilial("ZX2") + oProtNfe:_CHNFE:TEXT + PadR( cCodProd, Len(SB1->B1_COD) ) + StrZero( Val( oProd:_NITEM:TEXT ), 4 ))
					
					RecLock("ZX2",!lGravaZX2)
						ZX2->ZX2_FILIAL := xFilial("ZX2")
						ZX2->ZX2_ITEM   := StrZero( Val( oProd:_NITEM:TEXT ), 4 )
						ZX2->ZX2_COD    := cCodProd
						ZX2->ZX2_CODFOR := cCodPrf
						ZX2->ZX2_DESCF  := Iif( Empty( cCodProd ), aProds[ _nPos, 3 ], SB1->B1_DESC )
						ZX2->ZX2_QUANT  := Val( aLotes[ _nLot ]:_QLOTE:TEXT )
						ZX2->ZX2_VUNIT  := Val( oProd:_PROD:_VUNCOM:TEXT )
						ZX2->ZX2_TOTAL  := Val( aLotes[ _nLot ]:_QLOTE:TEXT ) * Val( oProd:_PROD:_VUNCOM:TEXT )
						ZX2->ZX2_CF     := oProd:_PROD:_CFOP:TEXT
						ZX2->ZX2_UM     := Iif( Empty( cCodProd ), oProd:_PROD:_UCOM:TEXT, SB1->B1_UM )
						ZX2->ZX2_BASIPI := nBaseIPI
						ZX2->ZX2_VALIPI := nValIPI
						ZX2->ZX2_PERIPI := nPIPI
						ZX2->ZX2_BASICM := nBaseICM
						ZX2->ZX2_VALICM := nValICM
						ZX2->ZX2_PERICM := nPICM
						ZX2->ZX2_BICMST := nBaseICMST
						ZX2->ZX2_VICMST := nValICMST
						ZX2->ZX2_PICMST := nPICMST
						ZX2->ZX2_CHVNFE := oProtNfe:_CHNFE:TEXT
						ZX2->ZX2_BLOQ   := If( _lStsA5A7, "3", If( _lStsPedC, "2", "0" ) )
						ZX2->ZX2_TES    := cCodTES
						ZX2->ZX2_CST    := cCST
						ZX2->ZX2_NFSORI := Iif( lCfopRet .And. aItemRet[ _nX ] .And. aScan( aRetRes, {|o| o[1] == _nX } ) > 0, aRetRes[ aScan( aRetRes, {|o| o[1] == _nX } ), 2 ], Space( Len( ZX2->ZX2_NFSORI ) ) )
						ZX2->ZX2_SERORI := Iif( lCfopRet .And. aItemRet[ _nX ] .And. aScan( aRetRes, {|o| o[1] == _nX } ) > 0, aRetRes[ aScan( aRetRes, {|o| o[1] == _nX } ), 3 ], Space( Len( ZX2->ZX2_SERORI ) ) )
						ZX2->ZX2_ITMORI := Iif( lCfopRet .And. aItemRet[ _nX ] .And. aScan( aRetRes, {|o| o[1] == _nX } ) > 0, aRetRes[ aScan( aRetRes, {|o| o[1] == _nX } ), 4 ], Space( Len( ZX2->ZX2_ITMORI ) ) )
						If !Empty( cPedXml ) .And. !Empty( cItPedXml )
							ZX2->ZX2_PC     := cPedXml
							ZX2->ZX2_ITEMPC := cItPedXml
						EndIf
						ZX2->ZX2_LOTECT := aLotes[ _nLot ]:_NLOTE:TEXT
						ZX2->ZX2_DTVLOT := StoD( StrTran( aLotes[ _nLot ]:_DVAL:TEXT, "-", "" ) )
						ZX2->ZX2_DTFLOT := StoD( StrTran( aLotes[ _nLot ]:_DFAB:TEXT, "-", "" ) )
						ZX2->ZX2_QTDLOT := Val( aLotes[ _nLot ]:_QLOTE:TEXT )
					ZX2->( MsUnLock() )

				Next

			Else

				dbSelectArea("ZX2")
				dbSetOrder(3)
				lGravaZX2 := dbSeek( xFilial("ZX2") + oProtNfe:_CHNFE:TEXT + PadR( cCodProd, Len(SB1->B1_COD) ) + StrZero( Val( oProd:_NITEM:TEXT ), 4 ))
				
				RecLock("ZX2",!lGravaZX2)
					ZX2->ZX2_FILIAL := xFilial("ZX2")
					ZX2->ZX2_ITEM   := StrZero( Val( oProd:_NITEM:TEXT ), 4 )
					ZX2->ZX2_COD    := cCodProd
					ZX2->ZX2_CODFOR := cCodPrf
					ZX2->ZX2_DESCF  := Iif( Empty( cCodProd ), aProds[ _nPos, 3 ], SB1->B1_DESC )

					If !Empty( cCodProd ) .And. !Empty( SB1->B1_SEGUM ) .And. SB1->B1_CONV > 0
						ZX2->ZX2_QUANT  := ConvUm( cCodProd, 0, Val( oProd:_PROD:_QTRIB:TEXT  ), 1 )
						ZX2->ZX2_VUNIT  := Round( Val( oProd:_PROD:_VUNCOM:TEXT ) / ConvUm( cCodProd, 0, Val( oProd:_PROD:_QTRIB:TEXT  ), 1 ), TamSX3("ZX2_VUNIT")[2] )
					Else
						// Jorge Alberto - Solutio - 06/04/2020 - #26648 - Alterada a Quantidade
						ZX2->ZX2_QUANT  := Val( oProd:_PROD:_QCOM:TEXT  ) // Val( oProd:_PROD:_QTRIB:TEXT  )
						ZX2->ZX2_VUNIT  := Val( oProd:_PROD:_VUNCOM:TEXT )
					EndIf

					ZX2->ZX2_TOTAL  := Val( oProd:_PROD:_VPROD:TEXT  )
					ZX2->ZX2_CF     := oProd:_PROD:_CFOP:TEXT
					ZX2->ZX2_UM     := Iif( Empty( cCodProd ), oProd:_PROD:_UCOM:TEXT, SB1->B1_UM )
					ZX2->ZX2_BASIPI := nBaseIPI
					ZX2->ZX2_VALIPI := nValIPI
					ZX2->ZX2_PERIPI := nPIPI
					ZX2->ZX2_BASICM := nBaseICM
					ZX2->ZX2_VALICM := nValICM
					ZX2->ZX2_PERICM := nPICM
					ZX2->ZX2_BICMST := nBaseICMST
					ZX2->ZX2_VICMST := nValICMST
					ZX2->ZX2_PICMST := nPICMST
					ZX2->ZX2_CHVNFE := oProtNfe:_CHNFE:TEXT
					ZX2->ZX2_BLOQ   := If( _lStsA5A7, "3", If( _lStsPedC, "2", "0" ) )
					ZX2->ZX2_TES    := cCodTES
					ZX2->ZX2_CST    := cCST
					ZX2->ZX2_NFSORI := Iif( lCfopRet .And. aItemRet[ _nX ] .And. aScan( aRetRes, {|o| o[1] == _nX } ) > 0, aRetRes[ aScan( aRetRes, {|o| o[1] == _nX } ), 2 ], Space( Len( ZX2->ZX2_NFSORI ) ) )
					ZX2->ZX2_SERORI := Iif( lCfopRet .And. aItemRet[ _nX ] .And. aScan( aRetRes, {|o| o[1] == _nX } ) > 0, aRetRes[ aScan( aRetRes, {|o| o[1] == _nX } ), 3 ], Space( Len( ZX2->ZX2_SERORI ) ) )
					ZX2->ZX2_ITMORI := Iif( lCfopRet .And. aItemRet[ _nX ] .And. aScan( aRetRes, {|o| o[1] == _nX } ) > 0, aRetRes[ aScan( aRetRes, {|o| o[1] == _nX } ), 4 ], Space( Len( ZX2->ZX2_ITMORI ) ) )
					If !Empty( cPedXml ) .And. !Empty( cItPedXml )
						ZX2->ZX2_PC     := cPedXml
						ZX2->ZX2_ITEMPC := cItPedXml
					EndIf
				ZX2->( MsUnLock() )

	        EndIf
		Next

		lCriaZX1 := .T.

		If lResNfe .And. nRecZX1 > 0
			ZX1->( dbGoTo( nRecZX1 ) )
		EndIf

		// Gravar ZX1
		dbSelectArea("ZX1")
		RecLock("ZX1", !lResNfe )
			ZX1->ZX1_FILIAL := xFilial("ZX1")
			ZX1->ZX1_TPDOC  := "NFE"
			ZX1->ZX1_TIPO   := cTipoNf
			ZX1->ZX1_DOC    := cNf
			ZX1->ZX1_SERIE  := cSerie
			ZX1->ZX1_CLIFOR := aRetEnt[ 1 ][ 1 ]
			ZX1->ZX1_LOJA   := aRetEnt[ 1 ][ 2 ]
			ZX1->ZX1_EMISSA := dDtEmi
			ZX1->ZX1_EST    := cUf
			ZX1->ZX1_ESPECI := "SPED "
			ZX1->ZX1_STATUS := Iif( lNfOk, "2", Iif( lPnOk, "1", Iif( nItNoPrd > 0, "3", "0" ) ) )
			ZX1->ZX1_BLOQ   := Iif( nItNoPrd > 0, "3", Iif( _lStsPedC, "2", "0" ) )
			ZX1->ZX1_CHVNFE := oProtNfe:_CHNFE:TEXT
			ZX1->ZX1_XML    := cBuffer
			ZX1->ZX1_DTIMP  := dDataBase
			ZX1->ZX1_XMLAUT := cInfAdic
			ZX1->ZX1_TOTAL  := Iif( Type("oTotal:_ICMSTOT:_VNF") <> "U", Val( oTotal:_ICMSTOT:_VNF:TEXT ), 0 )
			ZX1->ZX1_CNPJ   := cRegEmit
			ZX1->ZX1_NOMECF := cNomEmit
		ZX1->( MsUnLock() )

	End Transaction

	// Se tem pedido e tem amarração SA5 em todos os itens
	If !_lStsPedC .And. !_lStsA5A7
		
		// Realiza a avaliação do conteúdo do pedido de compras com o XML
		aDiverg := AvalPcIt( oProtNfe:_CHNFE:TEXT )

		// Se não houver divergências cria a pré nota
		If Len( aDiverg ) == 0
			xGerPreN()
		Else
			// Se houver divergências, grava as mesmas
			GravaDiv( aDiverg )
		EndIf

	EndIf

Return( .T. )


// Grava divergência e atualiza o status da nota
Static Function GravaDiv( aDiverg )

	Local nX      := 0
	Local cDescri := ""
	Local cSql    := ""
	Local cCodDiv := 0

	For nX := 1 To Len( aDiverg )

		cCodDiv := aDiverg[ nX, 3 ]

		cDescri := "Divergencia item "+ AllTrim( aDiverg[ nX, 6 ] ) +", referente "
		If cCodDiv == "1"
			cDescri += "quantidade"
		ElseIf cCodDiv == "2"
			cDescri += "valor"
		ElseIf cCodDiv == "3"
			cDescri += "condicao"
		ElseIf cCodDiv == "4"
			cDescri += "imposto"
		ElseIf cCodDiv == "5"
			cDescri += "CFOP"
		ElseIf cCodDiv == "6"
			cDescri += "fornecedor"
		ElseIf cCodDiv == "9"
			cDescri += "data de entrega"
		EndIf

		RecLock("ZX3", .T.)
			ZX3_FILIAL := xFilial("ZX3")
			ZX3_CODIGO := cCodDiv
			ZX3_CHVNFE := ZX1->ZX1_CHVNFE
			ZX3_ITEM   := aDiverg[ nX, 6 ]
			ZX3_PEDIDO := aDiverg[ nX, 1 ]
			ZX3_ITEMPC := aDiverg[ nX, 2 ]
			ZX3_STATUS := "1"
			ZX3_DTINCL := dDataBase
			ZX3_DESCRI := cDescri
		MsUnLock()

		RecLock("ZX1",.F.)
			ZX1->ZX1_BLOQ := Iif( cCodDiv == "9", "9", "1")
		MsUnLock()

		cSql := "UPDATE "+ RetSqlName("ZX2") 
		cSql += " SET ZX2_BLOQ = '"+ Iif( cCodDiv == "9", "9", "1") +"' "
		cSql += " WHERE ZX2_CHVNFE = '"+ ZX1->ZX1_CHVNFE +"' "
		cSql += "   AND ZX2_ITEM = '"+ aDiverg[ nX, 6 ] +"' "
		cSql += "   AND D_E_L_E_T_ = ' ' "

		TcSqlExec( cSql )

	Next

Return


// Verifica as notas originais dos itens no retorno com nota referenciada
Static Function VerNfOri( aNotRef, aItmRet, aDetPrd )

	Local aNfeRef := {}
	Local _aItens := {}
	Local _cNfRef := "("
	Local _nN     := 0
	Local _nG     := 0
	Local cCodProd:= ""
	Local cQuery  := ""
	Local cAlias  := ""
	Local cCodPrf := ""
	Local cDescPrf:= ""

	For _nN := 1 To Len( aNotRef )
		_cNfRef += "'"+ aNotRef[ _nN ]:TEXT +"',"
	Next
	_cNfRef := Left( _cNfRef, Len( _cNfRef ) - 1 ) + ")"

	cQuery := "SELECT F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, D2_ITEM, D2_COD, D2_QUANT, D2_PRCVEN, D2_CF "
	cQuery += "  FROM "+ RetSqlName("SF2") +" SF2 "
	cQuery += " INNER JOIN "+ RetSqlName("SD2") +" SD2 "
	cQuery += " ON F2_FILIAL = D2_FILIAL AND F2_DOC = D2_DOC AND F2_SERIE = D2_SERIE AND F2_CLIENTE = D2_CLIENTE AND F2_LOJA = D2_LOJA "
	cQuery += " WHERE F2_CHVNFE IN "+ _cNfRef
	cQuery += "   AND SF2.D_E_L_E_T_ <> '*' AND SD2.D_E_L_E_T_ <> '*' "
	cQuery += "   AND F2_FILIAL = '"+ xFilial("SF2") +"' "
	cQuery += " ORDER BY F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, D2_ITEM "

	cQuery := ChangeQuery(cQuery)
	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
	(cAlias)->( dbGotop() )

	While !(cAlias)->( Eof() )

		aAdd( _aItens, { F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, D2_ITEM, D2_COD, D2_QUANT, D2_PRCVEN, D2_CF } ) // Todos os itens das notas referenciadas

		(cAlias)->( dbSkip() )
	End
	(cAlias)->( dbCloseArea() )

	For _nN := 1 To Len( aDetPrd ) // Percorrer o array de itens do XML

		cCodProd := ""

		If aItmRet[ _nN ] // Se este item tem CFOP de devolução

			cCodPrf  := aDetPrd[ _nN ]:_PROD:_CPROD:TEXT
			cDescPrf := aDetPrd[ _nN ]:_PROD:_XPROD:TEXT

			If !Empty( cCodPrf )

				If cTipoNf $ "CN"
					SA5->( dbSetOrder(14) )
				Else
					SA7->( dbSetOrder(3) )
				EndIf

				If ( cTipoNf $ "CN" .And. SA5->( dbSeek( xFilial("SA5") + aRetEnt[ 1 ][ 1 ] + aRetEnt[ 1 ][ 2 ] + cCodPrf ) ) ) .Or. ( cTipoNf $ "DB" .And. SA7->( dbSeek( xFilial("SA7") + aRetEnt[ 1 ][ 1 ] + aRetEnt[ 1 ][ 2 ] + cCodPrf ) ) )
					// Usa o código cadastrado na tabela SA5/SA7
					cCodProd := Iif( cTipoNf $ "CN", SA5->A5_PRODUTO, SA7->A7_PRODUTO )
				EndIf

			EndIf

			For _nG := 1 To Len( _aItens ) // Percorro o array dos itens das notas referenciadas

				// Se o preço na remessa foi igual ao do retorno e código do produto corresponder com o da nota de remessa
				If Val( aDetPrd[ _nN ]:_PROD:_VUNCOM:TEXT ) == _aItens[ _nG, 8 ] .And. cCodProd == _aItens[ _nG, 6 ]
					aAdd( aNfeRef, { _nN, _aItens[ _nG, 1 ], _aItens[ _nG, 2 ], _aItens[ _nG, 5 ], _aItens[ _nG, 6 ] } ) // Adiciono o item com as informações da nota
					Exit // Na primeira ocorrência já sai do loop
				EndIf

			Next

		EndIf

	Next

Return( aNfeRef )

// Faz a comunicação com a SEFAZ via webservice para download da NF-e
User Function DXMLSEF()

	Local _cErr     := ""
	Local _cWrn     := ""
	Local cCnpj     := AllTrim(cCNPJAtu)
	Local cPass     := Decode64( cPassPFX )
	Local cPFX      := cPathPFX
	Local cKey      := cPKeyPEM
	Local cCert     := cCertPEM
	Local cCA       := cCaPEM
	Local cPath     := cWorkDir + cCnpj + "\"
	Local cUltNSU   := cNsuNFe
	Local cUrl      := 'https://www1.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx'
	Local aHeadOut  := {'SOAPAction: http://www.portalfiscal.inf.br/nfe/wsdl/NFeDistribuicaoDFe/nfeDistDFeInteresse','Content-Type:text/xml; charset=utf-8','User-Agent: Mozilla/4.0 (compatible; Protheus 7.00.100812P-20101227; ADVPL WSDL Client 1.101007)'}
	Local cSoapSend := ""
	Local XMLHeadRet:= ""
	Local cXmlRes   := ""
	Local cMaxNSU   := ""
	Local _cNSU     := ""
	Local _cTpZip   := ""
	Local _cTxt     := ""
	Local cChave    := ""
	Local aDocs     := {}
	Local lContinua := .T.
	Local nPosUf    := 0
	Local nTamSer   := 0
	Local nQtdNfD   := 0
	Local cUfOri    := ""
	Local cCNPJ_CPF := ""
	Local oXml
	Local oXmlParse
	Local _nC
	Private oXMLType // Criada para testar o conteúdo com a função TYPE

	// Verifica o arquivo PEM com o corpo do certificado
	If Empty( cCert ) .Or. !File( cCert )
		If !Empty( cPFX ) .And. File( cPFX ) .And. !Empty( cPass )
			cCert    := ExtraiCer( cPFX, cPass )
			cCertPEM := cCert
			PutMv( "SOL_XML021", cCertPEM )
		Else
			Conout("Nao foi possivel gerar o certificado digital - NF-e")
			lContinua := .F.
		EndIf
	EndIf

	// Verifica o arquivo PEM com a chave privada
	If Empty( cKey ) .Or. !File( cKey )
		If !Empty( cPFX ) .And. File( cPFX ) .And. !Empty( cPass )
			cKey     := ExtraiKey( cPFX, cPass )
			cPKeyPEM := cKey
			PutMv( "SOL_XML022", cPKeyPEM )
		Else
			Conout("Nao foi possivel gerar a chave privada do certificado digital - NF-e")
			lContinua := .F.
		EndIf
	EndIf

	// Verifica o arquivo PEM com a cadeia de autoridades de certificação (Certificate Authority)
	If Empty( cCA ) .Or. !File( cCA )
		If !Empty( cPFX ) .And. File( cPFX ) .And. !Empty( cPass )
			cCA    := ExtraiCca( cPFX, cPass )
			cCaPEM := cCA
			PutMv( "SOL_XML023", cCaPEM )
		Else
			Conout("Nao foi possivel extrair a autoridade certificadora do certificado digital - NF-e")
			lContinua := .F.
		EndIf
	EndIf

	While lContinua

		// Monta a requisição SOAP
		cSoapSend := '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
		cSoapSend += '<soap:Body>'
		cSoapSend += '<nfeDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeDistribuicaoDFe">'
		cSoapSend += '<nfeDadosMsg>'
		cSoapSend += '<distDFeInt versao="1.00" xmlns="http://www.portalfiscal.inf.br/nfe">'
		cSoapSend += '<tpAmb>1</tpAmb>'
		cSoapSend += '<cUFAutor>43</cUFAutor>'
		cSoapSend += '<CNPJ>'+ cCnpj +'</CNPJ>'
		cSoapSend += '<distNSU><ultNSU>'+ cUltNSU +'</ultNSU></distNSU>'
		cSoapSend += '</distDFeInt>'
		cSoapSend += '</nfeDadosMsg>'
		cSoapSend += '</nfeDistDFeInteresse>'
		cSoapSend += '</soap:Body>'
		cSoapSend += '</soap:Envelope>'

		//MemoWrite( "c:\Temp\XML\"+cUltNSU+"-soapsend_nfe.xml", cSoapSend )

		// Estabelece o canal de conexão segura SSL com o certificado
		HTTPSSLClient( 0, 1, 1, cPass, cCert, cKey, 0, , , 1, , cCA )

		oXmlParse := Nil
		oXml      := Nil
		Sleep(1000)

		// Faz a requisição via POST e recebe o conteúdo do retorno
		XMLPostRet := HTTPSPost( cUrl, cCert, cKey, cPass, "", cSoapSend, 120, aHeadOut, @XMLHeadRet )

		If ValAtrib("XMLPostRet") != "U" .And. ValType( XMLPostRet ) == "C"

			//MemoWrite( "c:\Temp\XML\"+cUltNSU+"-xmlpostret_nfe.xml", XMLPostRet )

			// Crio um objeto XML com toda a resposta da requisição
			oXmlParse := XmlParser( XMLPostRet, "_", @_cErr, @_cWrn )

			// Se existir a tag RETDISTDFEINT no Buffer de retorno significa que a comunicação ocorreu com sucesso podendo ter documentos a processar
			oXml := Iif( At( "<RETDISTDFEINT", Upper( XMLPostRet ) ) > 0, oXmlParse:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT, Nil )

		EndIf

		// Se o objeto XML for NIL é poque não há o que processar
		If oXml != Nil

			// Código de retorno 138 - Documento localizado
			If oXml:_CSTAT:TEXT == "138"

				cMaxNSU := oXml:_MAXNSU:TEXT // Processar requisições até chegar a este NSU
				cUltNSU := oXml:_ULTNSU:TEXT // Último NSU retornado na requisição

				// Quando o último NSU for igual ao NSU máximo, não continua requisitando
				lContinua := cMaxNSU != cUltNSU

				If ValType( oXml:_LOTEDISTDFEINT:_DOCZIP ) == "O"
					aDocs := {oXml:_LOTEDISTDFEINT:_DOCZIP}
				ElseIf ValType( oXml:_LOTEDISTDFEINT:_DOCZIP ) == "A"
					aDocs := oXml:_LOTEDISTDFEINT:_DOCZIP
				Else
					aDocs := {}
				EndIf

				For _nC := 1 To Len( aDocs )

					oXml := Nil
					oXml := aDocs[ _nC ]

					_cTpZip := oXml:_SCHEMA:TEXT // resEvento_v1.00.xsd, procEventoNFe_v1.00.xsd, resNFe_v1.00.xsd, procNFe_v3.10.xsd
					_cNSU   := oXml:_NSU:TEXT    // Numero sequencial unico deste documento
					_cTxt   := oXml:TEXT

					cXmlRes := ""
					_lDecGz := GzStrDecomp( Decode64( _cTxt ), Len( _cTxt ), @cXmlRes )

					If _lDecGz // Convertido com sucesso

						// Salvo o xml de NF-e, gravo os dados de resumo de NF-e
						If !( "evento" $ Lower( _cTpZip ) )

							If "resnfe" $ Lower( _cTpZip ) // Resumo da nota fiscal, precisa ser manifestada

								// Crio um objeto XML do resumo para pegar a chave e manifestar
								oXml := XmlParser( cXmlRes, "_", @_cErr, @_cWrn )
								oXMLType := oXml
								cChave := ""

								If oXMLType != Nil

									cChave := oXMLType:_RESNFE:_CHNFE:TEXT

									ManifSend( cChave, '210210', cCnpj ) // Envia a manifestação de ciência (Sem TSS)
									Sleep(8000) // Aguarda algum tempo após a manifestação

									DwldXMLCp( cChave ) // Efetua o download da nota fiscal completa (sem TSS)
									Sleep(3000) // Aguarda algum tempo após o download

								Else
									Loop
								EndIf

							Else
								// Crio um objeto XML com o documento apenas para extrair a chave do mesmo
								oXml := XmlParser( cXmlRes, "_", @_cErr, @_cWrn )
								oXMLType := oXml
								cChave := ""

								// Se criou o objeto corretamente gravo o XML
								If oXMLType != Nil
									cChave := oXMLType:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT
									MemoWrite( cPath + cChave +"-procNfe.xml", cXmlRes )
								Else
									Loop
								EndIf
							EndIf

							nTamSer := TamSx3("F1_SERIE")[ 1 ]

							cAliZX1 := ""
							cQuery := "SELECT R_E_C_N_O_ AS REGZX1 "
							cQuery +=  " FROM " + RetSqlName("ZX1") + " "
							cQuery += " WHERE ZX1_FILIAL = '"+ xFilial("ZX1") +"' "
							cQuery +=   " AND ( ZX1_NSU = '"+ _cNSU +"' OR ZX1_CHVNFE = '"+ cChave +"' ) "
							cQuery +=   " AND D_E_L_E_T_ = ' ' "
							//cQuery +=   " AND ZX1_STATUS NOT IN ('5','0','2','3','1','8','9','6') "

							TCQuery cQuery New Alias ( cAliZX1 := GetNextAlias() )

							// Deve gravar apenas quando não existir o registro
							If (cAliZX1)->( EOF() )

								cCNPJ_CPF := " "

								If "resnfe" $ Lower( _cTpZip ) // XML de resumo
									If Type("oXMLType:_RESNFE:_CNPJ") != "U"
										cCNPJ_CPF := oXMLType:_RESNFE:_CNPJ:TEXT
									Else
										If Type("oXMLType:_RESNFE:_CPF") != "U"
											cCNPJ_CPF := oXMLType:_RESNFE:_CPF:TEXT
										EndIf
									EndIf
								Else // XML Completo
									If Type("oXmlType:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ") != "U"
										cCNPJ_CPF := oXmlType:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT
									Else
										If Type("oXmlType:_NFEPROC:_NFE:_INFNFE:_EMIT:_CPF") != "U"
											cCNPJ_CPF := oXmlType:_NFEPROC:_NFE:_INFNFE:_EMIT:_CPF:TEXT
										EndIf
									Endif
								EndIf

								nPosUf := aScan( aEstados, {|o| o[1] == Left( cChave, 2 ) } )

								If nPosUf > 0
									cUfOri := aEstados[ nPosUf, 2 ]
								Else
									cUfOri := Space(2)
								EndIf

								dbSelectArea("ZX1") // Gravar ZX1
								RecLock("ZX1",.T.)
									ZX1->ZX1_FILIAL := xFilial("ZX1")
									ZX1->ZX1_TPDOC  := "NFE"
									ZX1->ZX1_EMISSA := StoD( StrTran( Left( Iif( "resnfe" $ Lower( _cTpZip ), oXMLType:_RESNFE:_DHEMI:TEXT, oXMLType:_NFEPROC:_NFE:_INFNFE:_IDE:_DHEMI:TEXT ), 10 ), "-", "" ) )
									ZX1->ZX1_STATUS := "5"
									ZX1->ZX1_CHVNFE := cChave
									ZX1->ZX1_DTIMP  := dDataBase
									ZX1->ZX1_NSU    := _cNSU
									ZX1->ZX1_DOC    := StrZero( Val( SubStr( cChave, 26, 9 ) ), TamSx3("F1_DOC")[ 1 ] )
									ZX1->ZX1_SERIE  := Right( Replicate( "0", nTamSer ) + SubStr( cChave, 23, 3 ), nTamSer )
									ZX1->ZX1_ESPECI := "SPED"
									ZX1->ZX1_EST    := cUfOri
									ZX1->ZX1_CNPJ   := cCNPJ_CPF
									ZX1->ZX1_NOMECF := Iif( "resnfe" $ Lower( _cTpZip ), oXMLType:_RESNFE:_XNOME:TEXT, oXMLType:_NFEPROC:_NFE:_INFNFE:_EMIT:_XNOME:TEXT )
								ZX1->( MsUnLock() )

							EndIf

							(cAliZX1)->( DbCloseArea() )

							nQtdNfD++

						EndIf

					EndIf

					cNsuNFe := _cNSU

					PutMv( "SOL_XML028", cNsuNFe )

					If nQtdNfD == nQtdDwld
						nQtdNfD := 0
						lContinua := .F.
					EndIf

				Next

			Else
				ConOut("Retorno do Sefaz - Codigo: "+ oXml:_CSTAT:TEXT +" | Motivo: "+ oXml:_XMOTIVO:TEXT )
				lContinua := .F.
			EndIf

		Else
			ConOut("Problema na consulta ao Sefaz: "+ XMLPostRet )
			lContinua := .F.
		EndIf

	End

Return

// Função que extrai o certificado PEM do PFX
Static Function ExtraiCer( cFilePfx, cPass )

	Local cCert  := cWorkDir + AllTrim(cCNPJAtu) + "\certs\cert.pem"
	Local cError := ""
	Local lRet

	If !File( cCert )

		lRet := PFXCERT2PEM( cFilePfx, cCert, @cError, cPass )

		If !lRet
			Conout("Nao foi possivel extrair o certificado PEM")
			cCert := ""
		EndIf

	EndIf

Return cCert

// Função que extrai a chave privada PEM do PFX
Static Function ExtraiKey( cFilePfx, cPass )

	Local cKey   := cWorkDir + AllTrim(cCNPJAtu) + "\certs\key.pem"
	Local cError := ""
	Local lRet

	If !File( cKey )

		lRet := PFXKEY2PEM( cFilePfx, cKey, @cError, cPass )

		If !lRet
			Conout("Nao foi possivel extrair a chave privada PEM")
			cKey := ""
		EndIf

	EndIf

Return cKey

// Função que extrai a cadeia de certificação PEM do PFX
Static function ExtraiCca( cFilePfx, cPass )

	Local cCA    := cWorkDir + AllTrim(cCNPJAtu) + "\certs\ca.pem"
	Local cError := ""
	Local lRet

	If !File( cCA )

		lRet := PFXCA2PEM( cFilePfx, cCA, @cError, cPass )

		If !lRet
			Conout("Nao foi possivel extrair a cadeia de certificacao PEM")
			cCA := ""
		EndIf

	EndIf

Return cCA

// Analisa as divergencias entre a nota e o pedido de compras
Static Function AvalPcIt( cChvNfDiv )

	Local aDiverg := {} // -- { PEDIDO, ITEM, COD. DIV, #NF, #PEDIDO, ITEM NF, PRODUTO, PROD.FORN, UM, R$TOTAL }
	Local aPedido := {} // -- { PEDIDO, ITEM, SALDO, QUANT.NF, PREÇO PC, PREÇO NF, ITEM NF, PRODUTO, PROD.FORN, UM, %TOL.QTD, %TOL.PRECO, TOL. ENTREGA, % IPI, % ICMS, TES, RECNO ZX2 }
	Local nPosPC  := 0
	Local nX      := 0

	dbSelectArea("ZX2")
	dbSetOrder(1)
	dbSeek( xFilial("ZX2") + cChvNfDiv )

	While !ZX2->( Eof() ) .And. ZX2->ZX2_CHVNFE == cChvNfDiv

		If !Empty( ZX2->ZX2_PC ) .And. !Empty( ZX2->ZX2_ITEMPC )

			nPosPC := aScan( aPedido, {|o| o[1] == ZX2->ZX2_PC .And. o[2] == ZX2->ZX2_ITEMPC } )

			If nPosPC == 0
				aAdd( aPedido, { ZX2->ZX2_PC, ZX2->ZX2_ITEMPC, 0, ZX2->ZX2_QUANT, 0, ZX2->ZX2_VUNIT, ZX2->ZX2_ITEM, ZX2->ZX2_COD, AllTrim(ZX2->ZX2_CODFOR), AllTrim(ZX2->ZX2_UM), 0, 0, 0, 0, 0, "", ZX2->( Recno() ) } )
			Else
				aPedido[ nPosPC, 4 ] += ZX2->ZX2_QUANT
			EndIf

		EndIf

		ZX2->( dbSkip() )
	End

	For nX := 1 To Len( aPedido )

		SC7->( dbSetOrder(1) )
		If SC7->( dbSeek( xFilial("SC7") + aPedido[ nX, 1 ] + aPedido[ nX, 2 ] ) )

			AIC->( dbSetOrder(1) )
			If AIC->( dbSeek( xFilial("AIC") + SC7->C7_FORNECE + SC7->C7_LOJA + SC7->C7_PRODUTO ) )
				aPedido[ nX, 11 ] := AIC->AIC_PQTDE
				aPedido[ nX, 12 ] := AIC->AIC_PPRECO
				aPedido[ nX, 13 ] := AIC->AIC_TOLENT
			EndIf

			aPedido[ nX, 3 ] := ( SC7->C7_QUANT - SC7->C7_QUJE )
			aPedido[ nX, 5 ] := SC7->C7_PRECO

			aPedido[ nX, 14 ] := SC7->C7_IPI
			aPedido[ nX, 15 ] := SC7->C7_PICM
			aPedido[ nX, 16 ] := SC7->C7_TES

			Exit // Se encontrou o pedido no sistema já sai na primeira
		Else
			aPedido[ nX, 3 ] := 0
			aPedido[ nX, 4 ] := 0
			aPedido[ nX, 5 ] := 0
			aPedido[ nX, 6 ] := 0
		EndIf

	Next

	// Realiza as validações de quantidade e valor, impostos e CFOP
	For nX := 1 To Len( aPedido )

		// AValia a quantidade entre o produto na nota e o pedido
		If aPedido[ nX, 4 ] > aPedido[ nX, 3 ]
			If aPedido[ nX, 11 ] > 0 // Se tem tolerância cadastrada para a quantidade
				If aPedido[ nX, 4 ] > ( aPedido[ nX, 3 ] + ( aPedido[ nX, 3 ] * ( aPedido[ nX, 11 ] / 100 ) ) )
					aAdd( aDiverg, { aPedido[ nX, 1 ], aPedido[ nX, 2 ], "1", aPedido[ nX, 4 ], aPedido[ nX, 3 ], aPedido[ nX, 7 ], aPedido[ nX, 8 ], aPedido[ nX, 9 ], aPedido[ nX, 10 ], ( aPedido[ nX, 5 ] * ( aPedido[ nX, 4 ] - aPedido[ nX, 3 ] ) ) } )
				EndIf
			Else // Se nao tem tolerância já considera como divergência
				aAdd( aDiverg, { aPedido[ nX, 1 ], aPedido[ nX, 2 ], "1", aPedido[ nX, 4 ], aPedido[ nX, 3 ], aPedido[ nX, 7 ], aPedido[ nX, 8 ], aPedido[ nX, 9 ], aPedido[ nX, 10 ], ( aPedido[ nX, 5 ] * ( aPedido[ nX, 4 ] - aPedido[ nX, 3 ] ) ) } )
			EndIf
		Endif

		// Avalia o valor entre o produto na nota e o pedido
		If aPedido[ nX, 6 ] > aPedido[ nX, 5 ]
			If aPedido[ nX, 12 ] > 0 // Se tem tolerância cadastrada para o valor
				If aPedido[ nX, 6 ] > ( aPedido[ nX, 5 ] + ( aPedido[ nX, 5 ] * ( aPedido[ nX, 12 ] / 100 ) ) )
					aAdd( aDiverg, { aPedido[ nX, 1 ], aPedido[ nX, 2 ], "2", aPedido[ nX, 6 ], aPedido[ nX, 5 ], aPedido[ nX, 7 ], aPedido[ nX, 8 ], aPedido[ nX, 9 ], aPedido[ nX, 10 ], ( aPedido[ nX, 4 ] * ( aPedido[ nX, 6 ] - aPedido[ nX, 5 ] ) ) } )
				EndIf
			Else
				aAdd( aDiverg, { aPedido[ nX, 1 ], aPedido[ nX, 2 ], "2", aPedido[ nX, 6 ], aPedido[ nX, 5 ], aPedido[ nX, 7 ], aPedido[ nX, 8 ], aPedido[ nX, 9 ], aPedido[ nX, 10 ], ( aPedido[ nX, 4 ] * ( aPedido[ nX, 6 ] - aPedido[ nX, 5 ] ) ) } )
			EndIf

		Endif

		If !Empty( aPedido[ nX, 16 ] ) // Se a TES foi informada no PEDIDO

			dbSelectArea("SF4")
			dbSetOrder(1)
			dbSeek( xFilial("SF4") + aPedido[ nX, 16 ] )

			dbSelectArea("ZX2")
			ZX2->( dbGoTo( aPedido[ nX, 17 ] ) )

			If SubStr( AllTrim( ZX2->ZX2_CF ), 2, 3 ) != SubStr( AllTrim( SF4->F4_CF ), 2, 3 )
				aAdd( aDiverg, { aPedido[ nX, 1 ], aPedido[ nX, 2 ], "5", aPedido[ nX, 6 ], aPedido[ nX, 5 ], aPedido[ nX, 7 ], aPedido[ nX, 8 ], aPedido[ nX, 9 ], aPedido[ nX, 10 ] } )
			EndIf

			If aPedido[ nX, 14 ] <> ZX2->ZX2_PERIPI
				aAdd( aDiverg, { aPedido[ nX, 1 ], aPedido[ nX, 2 ], "4", aPedido[ nX, 6 ], aPedido[ nX, 5 ], aPedido[ nX, 7 ], aPedido[ nX, 8 ], aPedido[ nX, 9 ], aPedido[ nX, 10 ] } )
			EndIf

			If aPedido[ nX, 15 ] <> ZX2->ZX2_PERICM
				aAdd( aDiverg, { aPedido[ nX, 1 ], aPedido[ nX, 2 ], "4", aPedido[ nX, 6 ], aPedido[ nX, 5 ], aPedido[ nX, 7 ], aPedido[ nX, 8 ], aPedido[ nX, 9 ], aPedido[ nX, 10 ] } )
			EndIf

		EndIf

	Next

Return( aDiverg )


// Função que retorna o objeto xml do conteúdo do arquivo
Static Function xCriaXML( cXMLPath )

	Local _cErr     := ""
	Local _cWrn     := ""
	Local nHandle   := 0
	Local nTamArq   := 0

	nHandle := fOpen( cXMLPath, FO_READ + FO_COMPAT,,.T. )

	If ( fError() == 0 )
		FSEEK( nHandle, 0, 0 )
		nTamArq := FSEEK( nHandle, 0, FS_END )
		FSEEK( nHandle, 0, 0 )
		cBuffer := Space( nTamArq )
		FREAD( nHandle, @cBuffer, nTamArq )
		fClose( nHandle )
		_oXml := XmlParser( cBuffer, "_", @_cErr, @_cWrn ) // Crio o objeto XML
	EndIf

Return( { _cErr, _cWrn } )

// Envia a manifestação de destinatario (sem TSS)
Static Function ManifSend( cChave, cEvento, cCnpj )

	Local XMLHeadRet := ""
	Local cXml       := ""
	Local cXmlRet    := ""
	Local cXmltoSign := ""
	Local cIdEvento  := ""
	Local cDescEv    := ""
	Local cKey       := cPKeyPEM
	Local cCert      := cCertPEM
	Local cCA        := cCaPEM
	Local cPass      := Decode64( cPassPFX )
	Local lSumTime   := ( cHorVer == "S" )
	Local cLote      := StrZero( Val( cLoteEv ) + 1, 15 )
	Local cTag       := 'infEvento'
	Local cUrl       := 'https://www.nfe.fazenda.gov.br/NFeRecepcaoEvento4/NFeRecepcaoEvento4.asmx'
	Local cSoap1     := '<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope"><soap12:Body><nfeDadosMsg xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeRecepcaoEvento4">'
	Local cSoap2     := '</nfeDadosMsg></soap12:Body></soap12:Envelope>'
	Local aHeadOut   := {'SOAPAction:http://www.portalfiscal.inf.br/nfe/wsdl/NFeRecepcaoEvento4/nfeRecepcaoEventoNF','Content-Type:text/xml; charset=utf-8','User-Agent: Mozilla/4.0 (compatible; Protheus 7.00.100812P-20101227; ADVPL WSDL Client 1.101007)'}

	cXmltoSign := '<envEvento xmlns="http://www.portalfiscal.inf.br/nfe" versao="1.00">'
	cXmltoSign += '<idLote>##IDLOTE##</idLote>'
	cXmltoSign += '<evento versao="1.00">'
	cXmltoSign += '<infEvento Id="##IDEVENTO##">'
	cXmltoSign += '<cOrgao>91</cOrgao>'
	cXmltoSign += '<tpAmb>1</tpAmb>'
	cXmltoSign += '<CNPJ>##CNPJ##</CNPJ>'
	cXmltoSign += '<chNFe>##CHAVE##</chNFe>'
	cXmltoSign += '<dhEvento>##YEAR##-##MONTH##-##DAY##T##HOUR##:##MIN##:##SEC##-##ZTIME##:00</dhEvento>'
	cXmltoSign += '<tpEvento>##EVENTCODE##</tpEvento>'
	cXmltoSign += '<nSeqEvento>1</nSeqEvento>'
	cXmltoSign += '<verEvento>1.00</verEvento>'
	cXmltoSign += '<detEvento versao="1.00">'
	cXmltoSign += '<descEvento>##EVENTDESC##</descEvento>'
	cXmltoSign += '</detEvento>'
	cXmltoSign += '</infEvento>'
	cXmltoSign += '</evento>'
	cXmltoSign += '</envEvento>'

	// Atualiza a variável global e o parâmetro do lote de evento
	cLoteEv := cLote
	PutMv( "SOL_XML029", cLoteEv )

	cIdEvento := "ID"+ cEvento + cChave +"01"

	Do Case
		Case cEvento == "210200"
			cDescEv := "Confirmacao da Operacao"
		Case cEvento == "210210"
			cDescEv := "Ciencia da Operacao"
		Case cEvento == "210220"
			cDescEv := "Desconhecimento da Operacao"
		Case cEvento == "210240"
			cDescEv := "Operacao nao Realizada"
	End Case

	cXmltoSign := StrTran( cXmltoSign, '##IDLOTE##'   , cLote )
	cXmltoSign := StrTran( cXmltoSign, '##IDEVENTO##' , cIdEvento )
	cXmltoSign := StrTran( cXmltoSign, '##CNPJ##'     , cCnpj )
	cXmltoSign := StrTran( cXmltoSign, '##CHAVE##'    , cChave )
	cXmltoSign := StrTran( cXmltoSign, '##YEAR##'     , cValToChar( Year( dDataBase ) ) )
	cXmltoSign := StrTran( cXmltoSign, '##MONTH##'    , StrZero( Month( dDataBase ), 2 ) )
	cXmltoSign := StrTran( cXmltoSign, '##DAY##'      , StrZero( Day( dDataBase ), 2 ) )
	cXmltoSign := StrTran( cXmltoSign, '##HOUR##'     , Left( Time(), 2 ) )
	cXmltoSign := StrTran( cXmltoSign, '##MIN##'      , SubStr( Time(), 4, 2 ) )
	cXmltoSign := StrTran( cXmltoSign, '##SEC##'      , Right( Time(), 2 ) )
	cXmltoSign := StrTran( cXmltoSign, '##ZTIME##'    , Iif( lSumTime, "02", "03" ) )
	cXmltoSign := StrTran( cXmltoSign, '##EVENTCODE##', cEvento )
	cXmltoSign := StrTran( cXmltoSign, '##EVENTDESC##', cDescEv )

	// Assina o XML para envio do evento de manifestação
	cXmlRet := xSignXML( cXmltoSign, cTag, cKey, cCert, cPass, cIdEvento )
	// Envelopa o XML assinado para envio ao webservice de eventos da sefaz
	cXml := cSoap1 + cXmlRet + cSoap2
    // Cria a conexão SSL e faz o envio do xml da manifestação
	HTTPSSLClient( 1, 1, 1, cPass, cCert, cKey, 0, , , 1, , cCA )
	XMLPostRet := HTTPSPost( cUrl, cCert, cKey, cPass, "", cXml, 600, aHeadOut, @XMLHeadRet )

Return

// Assina o XML para envio do evento de manifestação
Static Function xSignXML( cXML, cTag, cKey, cCert, cPassCert, cURI )

	Local cXmlToSign  := ""
	Local cMacro      := ""
	Local cError      := ""
	Local cWarning    := ""
	Local cDigest     := ""
	Local cSignature  := ""
	Local cSignInfo   := ""
	Local cIniXml     := ""
	Local cFimXml     := ""
	Local cNameSpace  := ""
	Local cNewTag     := ""
	Local nAt         := 0

	Default cURI      := ""

	If FindFunction("EVPPrivSign")

		cXmlToSign := XmlC14N(cXml, "", @cError, @cWarning)

		cXmlToSign := StrTran(cXmlToSign,"&lt;/","</")
		cXmlToSign := StrTran(cXmlToSign,"/&gt;","/>")
		cXmlToSign := StrTran(cXmlToSign,"&lt;","<")
		cXmlToSign := StrTran(cXmlToSign,"&gt;",">")
		cXmlToSign := StrTran(cXmlToSign,"<![CDATA[[ ","<![CDATA[")


		If Empty( cError ) .And. Empty( cWarning )

			nAt        := At( "<"+ cTag, cXmlToSign )
			cIniXML    := SubStr( cXmlToSign, 1, nAt - 1 )
			cXmlToSign := SubStr( cXmlToSign, nAt )

			nAt        := At( "</"+ cTag +">", cXmltoSign )
			cFimXML    := SubStr( cXmltoSign, nAt + Len( cTag ) + 3 )
			cXmlToSign := SubStr( cXmlToSign, 1, nAt + Len( cTag ) + 2 )

			cNewTag    := AllTrim(cIniXml)
			cNewTag    := SubStr( cIniXml, 2, At( " ", cIniXml ) - 2 )
			cNameSpace := StrTran( cIniXml, "<"+ cNewTag, "" )
			cNameSpace := AllTrim( StrTran( cNameSpace, ">", "" ) )

			nAtver := At( "versao", cNameSpace )

			If nAtver > 0
				cNameSpace := SubStr( cNameSpace, 1, nAtver - 1 ) // -2 por causa do espaco
				cNameSpace := RTrim( cNameSpace )
			Endif

			// Calcula o DigestValue da assinatura
			cDigest := StrTran( cXmlToSign, "<"+ cTag +" ", "<"+ cTag +" "+ cNameSpace +" " )
			cDigest := XmlC14N( cDigest, "", @cError, @cWarning)
			cMacro  := "EVPDigest"
			cDigest := Encode64( &cMacro.( cDigest , 3 ) )

			// Calcula o SignedInfo  da assinatura
			cSignInfo := xSignInf( cUri, cDigest )
			cSignInfo := XmlC14N( cSignInfo, "", @cError, @cWarning )

			// Assina o XML
			cMacro   := "EVPPrivSign"
			cSignature := &cMacro.( cKey, cSignInfo, 3, cPassCert, @cError )
			cSignature := Encode64( cSignature )

			// Envelopa a assinatura
			cXmlToSign += '<Signature xmlns="http://www.w3.org/2000/09/xmldsig#">'
			cXmltoSign += cSignInfo
			cXmlToSign += '<SignatureValue>'+ cSignature +'</SignatureValue>'
			cXmltoSign += '<KeyInfo>'
			cXmltoSign += '<X509Data>'
			cXmltoSign += '<X509Certificate>'+ xGetCert( cCert, .F. ) +'</X509Certificate>'
			cXmltoSign += '</X509Data>'
			cXmltoSign += '</KeyInfo>'
			cXmltoSign += '</Signature>'

			cXmlToSign := cIniXML + cXmlToSign + cFimXML
		Else
			cXmlToSign := cXml
			ConOut("Sign Error thread: "+ cError +"/"+ cWarning )
		EndIf

	Else
		cXmlToSign := "Falha"
		ConOut("Falha ao tentar assinar xml de manifestacao.")
	EndIf

Return( cXmlToSign )

// Efetua o download da nota fiscal completa (sem TSS)
Static Function DwldXMLCp( cChave, lDownload, lUnitario )

	Local _cErr     := ""
	Local _cWrn     := ""
	Local cCnpj     := AllTrim(cCNPJAtu)
	Local cPass     := Decode64( cPassPFX )
	Local cKey      := cPKeyPEM
	Local cCert     := cCertPEM
	Local cCA       := cCaPEM
	Local cPath     := cWorkDir + cCnpj + "\"
	Local cUrl      := 'https://www1.nfe.fazenda.gov.br/NFeDistribuicaoDFe/NFeDistribuicaoDFe.asmx'
	Local aHeadOut  := {'SOAPAction: http://www.portalfiscal.inf.br/nfe/wsdl/NFeDistribuicaoDFe/nfeDistDFeInteresse','Content-Type:text/xml; charset=utf-8','User-Agent: Mozilla/4.0 (compatible; Protheus 7.00.100812P-20101227; ADVPL WSDL Client 1.101007)'}
	Local cSoapSend := ""
	Local XMLHeadRet:= ""
	Local cXmlRes   := ""
	Local _cTpZip   := ""
	Local _cTxt     := ""
	Local cNSU      := ""
	Local lTenta    := .T.
	Local nVezes    := 0
	Local oXml

	Local _nC		:= 0

	Private oXmlParse

	Default lDownload := .T.
	Default lUnitario := .F.

	If lUnitario
		cNSU := Posicione("ZX1",1,xFilial("ZX1")+cChave,"ZX1->ZX1_NSU")
		lUnitario := !Empty( cNSU )
	EndIf

	// Monta a requisição SOAP
	cSoapSend := '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
	cSoapSend += '<soap:Body>'
	cSoapSend += '<nfeDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeDistribuicaoDFe">'
	cSoapSend += '<nfeDadosMsg>'
	cSoapSend += '<distDFeInt versao="1.01" xmlns="http://www.portalfiscal.inf.br/nfe">'
	cSoapSend += '<tpAmb>1</tpAmb>'
	cSoapSend += '<cUFAutor>43</cUFAutor>'
	cSoapSend += '<CNPJ>'+ cCnpj +'</CNPJ>'
	If lUnitario
		cSoapSend += '<consNSU><NSU>'+ cNSU +'</NSU></consNSU>'
	Else
		cSoapSend += '<consChNFe><chNFe>'+ cChave +'</chNFe></consChNFe>'
	EndIf
	cSoapSend += '</distDFeInt>'
	cSoapSend += '</nfeDadosMsg>'
	cSoapSend += '</nfeDistDFeInteresse>'
	cSoapSend += '</soap:Body>'
	cSoapSend += '</soap:Envelope>'

	// Estabelece o canal de conexão segura SSL com o certificado
	HTTPSSLClient( 1, 1, 1, cPass, cCert, cKey, 0, , , 1, , cCA )

	// Faz a requisição via POST e recebe o conteúdo do retorno
	While lTenta

		XMLPostRet := HTTPSPost( cUrl, cCert, cKey, cPass, "", cSoapSend, 1500, aHeadOut, @XMLHeadRet )
		Sleep(5000)
		nVezes++

		If Type("XMLPostRet") != "U" .And. ValType( XMLPostRet ) == "C"
			If !( At( "<LOTEDISTDFEINT>", Upper( XMLPostRet ) ) > 0 )
				If nVezes == 3
					lTenta := .F.
				EndIf
			Else
				lTenta := .F.
			EndIf
		Else
			If nVezes == 3
				lTenta := .F.
			EndIf
		EndIf
	End

	If Type("XMLPostRet") != "U" .And. ValType( XMLPostRet ) == "C"

		// Crio um objeto XML com toda a resposta da requisição
		oXmlParse := XmlParser( XMLPostRet, "_", @_cErr, @_cWrn )

		// Se existir a tag LOTEDISTDFEINT no Buffer de retorno significa que a comunicação ocorreu com sucesso e que há documentos a processar
		oXml := Iif( At( "<LOTEDISTDFEINT>", Upper( XMLPostRet ) ) > 0, oXmlParse:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT, Nil )

	EndIf

	// Se o objeto XML for NIL é poque não há o que processar
	If oXml != Nil

		If !lDownload
			If oXml:_CSTAT:TEXT == "138"
				Return("100")
			ElseIf oXml:_CSTAT:TEXT == "653"
				Return("101")
			Else
				Return("999")
			EndIf
		EndIf

		// Código de retorno 138 - Documento localizado
		If oXml:_CSTAT:TEXT == "138"

			If ValType( oXml:_LOTEDISTDFEINT:_DOCZIP ) == "O"
				aDocs := {oXml:_LOTEDISTDFEINT:_DOCZIP}
			ElseIf ValType( oXml:_LOTEDISTDFEINT:_DOCZIP ) == "A"
				aDocs := oXml:_LOTEDISTDFEINT:_DOCZIP
			Else
				aDocs := {}
			EndIf

			For _nC := 1 To Len( aDocs )

				oXml := Nil
				oXml := aDocs[ _nC ]

				_cTpZip := oXml:_SCHEMA:TEXT // resEvento_v1.00.xsd, procEventoNFe_v1.00.xsd, resNFe_v1.00.xsd, procNFe_v3.10.xsd
				_cNSU   := oXml:_NSU:TEXT    // Numero sequencial unico deste documento
				_cTxt   := oXml:TEXT

				cXmlRes := ""
				_lDecGz := GzStrDecomp( Decode64( _cTxt ), Len( _cTxt ), @cXmlRes )

				If _lDecGz .And. "procnfe" $ Lower( _cTpZip ) // Convertido com sucesso e se trata de documento completo

					// Crio um objeto XML com o documento apenas para extrair a chave do mesmo
					oXml := XmlParser( cXmlRes, "_", @_cErr, @_cWrn )

					// Se criou o objeto corretamente, uso a chave como nome do arquivo, senão uso o NSU
					If oXml != Nil
						MemoWrite( cPath + oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT +"-procNfe.xml", cXmlRes )
					Else
						MemoWrite( cPath + _cNSU +"-procNfe.xml", cXmlRes )
					EndIf
				EndIf

			Next

		EndIf

	Else
		lContinua := .F.
	EndIf

Return("999")


// Calcula o SignedInfo  da assinatura
Static Function xSignInf( cUri, cDigest )

	Local cSignedInfo := ""

	cSignedInfo += '<SignedInfo xmlns="http://www.w3.org/2000/09/xmldsig#">'
	cSignedInfo += '<CanonicalizationMethod Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"></CanonicalizationMethod>'
	cSignedInfo += '<SignatureMethod Algorithm="http://www.w3.org/2000/09/xmldsig#rsa-sha1"></SignatureMethod>'
	cSignedInfo += '<Reference URI="#'+ cUri +'">'
	cSignedInfo += '<Transforms>'
	cSignedInfo += '<Transform Algorithm="http://www.w3.org/2000/09/xmldsig#enveloped-signature"></Transform>'
	cSignedInfo += '<Transform Algorithm="http://www.w3.org/TR/2001/REC-xml-c14n-20010315"></Transform>'
	cSignedInfo += '</Transforms>'
	cSignedInfo += '<DigestMethod Algorithm="http://www.w3.org/2000/09/xmldsig#sha1"></DigestMethod>'
	cSignedInfo += '<DigestValue>'+ cDigest +'</DigestValue></Reference></SignedInfo>'

Return( cSignedInfo )


// Obtém o conteúdo do certificado PEM
Static Function xGetCert( cFile, lHSM )

	Local cCertificado := cFile
	Local nAT          := 0
	Local nRAT         := 0
	Local nHandle      := 0
	Local nBuffer      := 0

	If File( cfile )

		nHandle   := FOpen( cFile, 0 )
		nBuffer   := FSEEK(nHandle,0,FS_END)

		FSeek( nHandle, 0 )
		FRead( nHandle , cCertificado , nBuffer )
		FClose( nHandle )

		nAt := AT( "BEGIN CERTIFICATE", cCertificado )

		If ( nAt > 0 )
			nAt := nAt + 22
			cCertificado := SubStr( cCertificado, nAt )
		EndIf

		nRat := AT( "END CERTIFICATE", cCertificado )

		If ( nRAt > 0 )
			nRat := nRat - 6
			cCertificado := SubStr( cCertificado, 1, nRat )
		EndIf

		cCertificado := StrTran( cCertificado, CHR(13), "" )
		cCertificado := StrTran( cCertificado, CHR(10), "" )
		cCertificado := StrTran( cCertificado, CHR(13) + CHR(10), "" )

	Else
		ConOut("Certificado nao encontrado no diretorio Certs.")
	EndIf

Return( cCertificado )


//-------------------------
// Gera pré-nota de NF-e
//-------------------------
Static Function xGerPreN()

	Local cTipDoc := ZX1->ZX1_TPDOC  // Tipo de documento (NF-e ou CT-e)
	Local lNoOk   := .F.
	Local cAlias  := ""
	Local cQuery  := ""
	Local aCabec    := {}
	Local aLinha    := {}
	Local aItens    := {}

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .F.

	SF1->( dbSetOrder(8) )
	If SF1->( dbSeek( xFilial("SF1") + ZX1->ZX1_CHVNFE ) )
		ConOut("Nota fiscal ou pre-nota já foi gerada no sistema! Chave: "+ ZX1->ZX1_CHVNFE )
		Return(.F.)
	EndIf

	If cTipDoc != "NFE"
		ConOut("Documento não eh nota fiscal! Chave: "+ ZX1->ZX1_CHVNFE )
		Return(.F.)
	EndIf

	// Verifica se o código de produto foi informado (a tes não é necessária para a pré-nota
	cQuery := "SELECT COUNT(*) AS TOT FROM " + RetSqlName("ZX2")
	cQuery += " WHERE ZX2_COD  = ' '"
	cQuery += " AND ZX2_CHVNFE = '"+ ZX1->ZX1_CHVNFE +"' "
	cQuery += " AND D_E_L_E_T_ = ' ' "
	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
	lNoOk := (cAlias)->TOT > 0
	(cAlias)->( DbCloseArea() )

	If lNoOk // Tem itens a serem revisados, ajusta o status
		ZX1->( RecLock("ZX1",.F.) )
			ZX1->ZX1_STATUS := "3"
		ZX1->( MsUnLock() )
		ConOut("XML precisa ter os produtos amarrados: Chave: "+ ZX1->ZX1_CHVNFE )
		Return(.F.)
	EndIf

	cQuery := "SELECT * FROM "+ RetSqlName("ZX2")
	cQuery += " WHERE ZX2_CHVNFE = '"+ ZX1->ZX1_CHVNFE +"' "
	cQuery += " AND D_E_L_E_T_ = ' ' "

	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )

	While !(cAlias)->( Eof() )

		aLinha := {}

		aAdd( aLinha, { "D1_ITEM"   , Strzero( Len( aItens ) + 1, TamSX3("D1_ITEM")[1] ), Nil, Nil } )
		aAdd( aLinha, { "D1_COD"    , (cAlias)->ZX2_COD   , Nil, Nil } )
		aAdd( aLinha, { "D1_QUANT"  , (cAlias)->ZX2_QUANT , Nil, Nil } )
		aAdd( aLinha, { "D1_VUNIT"  , (cAlias)->ZX2_VUNIT , Nil, Nil } )
		aAdd( aLinha, { "D1_TOTAL"  , (cAlias)->ZX2_TOTAL , Nil, Nil } )

		If !Empty( (cAlias)->ZX2_PERICM )
			aAdd( aLinha, { "D1_VALICM" , (cAlias)->ZX2_VALICM, Nil, Nil } )
			aAdd( aLinha, { "D1_PICM"   , (cAlias)->ZX2_PERICM, Nil, Nil } )
			aAdd( aLinha, { "D1_BASEICM", (cAlias)->ZX2_BASICM, Nil, Nil } )
		EndIf

		If !Empty( (cAlias)->ZX2_VICMST )
			aAdd( aLinha, { "D1_ICMSRET", (cAlias)->ZX2_VICMST, Nil, Nil } )
		EndIf

		If !Empty( (cAlias)->ZX2_PERIPI )
			aAdd( aLinha, { "D1_VALIPI" , (cAlias)->ZX2_VALIPI, Nil, Nil } )
			aAdd( aLinha, { "D1_IPI"    , (cAlias)->ZX2_PERIPI, Nil, Nil } )
			aAdd( aLinha, { "D1_BASEIPI", (cAlias)->ZX2_BASIPI, Nil, Nil } )
		EndIf

		If !Empty( (cAlias)->ZX2_PC )
			aAdd( aLinha, { "D1_PEDIDO", (cAlias)->ZX2_PC    , Nil, Nil } )
			aAdd( aLinha, { "D1_ITEMPC", (cAlias)->ZX2_ITEMPC, Nil, Nil } )
		EndIf

		If !Empty( (cAlias)->ZX2_LOTECT )
			aAdd( aLinha, { "D1_LOTECTL", (cAlias)->ZX2_LOTECT, Nil, Nil } )
			aAdd( aLinha, { "D1_LOTEFOR", (cAlias)->ZX2_LOTECT, Nil, Nil } )
			aAdd( aLinha, { "D1_DTVALID", StoD( (cAlias)->ZX2_DTVLOT ), Nil, Nil } )
			aAdd( aLinha, { "D1_DFABRIC", Iif( Empty( (cAlias)->ZX2_DTFLOT ), dDataBase, StoD( (cAlias)->ZX2_DTFLOT ) ), Nil, Nil } )
		EndIf

		aAdd( aItens, aLinha )

		(cAlias)->( dbSkip() )
	End
	(cAlias)->( dbCloseArea() )

	aAdd( aCabec, { "F1_TIPO"   , ZX1->ZX1_TIPO  , Nil, Nil } )
	aAdd( aCabec, { "F1_FORMUL" , "N"            , Nil, Nil } )
	aAdd( aCabec, { "F1_DOC"    , ZX1->ZX1_DOC   , Nil, Nil } )
	aAdd( aCabec, { "F1_CHVNFE" , ZX1->ZX1_CHVNFE, Nil, Nil } )
	aAdd( aCabec, { "F1_SERIE"  , ZX1->ZX1_SERIE , Nil, Nil } )
	aAdd( aCabec, { "F1_EMISSAO", ZX1->ZX1_EMISSA, Nil, Nil } )
	aAdd( aCabec, { "F1_FORNECE", ZX1->ZX1_CLIFOR, Nil, Nil } )
	aAdd( aCabec, { "F1_LOJA"   , ZX1->ZX1_LOJA  , Nil, Nil } )
	aAdd( aCabec, { "F1_ESPECIE", ZX1->ZX1_ESPECI, Nil, Nil } )

	Begin Transaction

		MSExecAuto( { | v,w,x,y,z | MATA140( v,w,x,y,z ) }, aCabec, aItens, 3, .F., 0 )

		If lMsErroAuto
			DisarmTran()
			ConOut("Ocorreu um problema na execucao automatica da pre-nota.")
		Else
			SF1->( dbSetOrder(1) )
			If SF1->( dbSeek( xFilial("SF1") + ZX1->ZX1_DOC + ZX1->ZX1_SERIE + ZX1->ZX1_CLIFOR + ZX1->ZX1_LOJA ) )
				ZX1->( RecLock("ZX1",.F.) )
					ZX1->ZX1_STATUS := "1" // Pré-Nota incluída
				ZX1->( MsUnLock() )
				SF1->( RecLock("SF1",.F.) )
					SF1->F1_CHVNFE := ZX1->ZX1_CHVNFE
				SF1->( MsUnLock() )
			EndIf
		EndIf

	End Transaction

Return

/*/{Protheus.doc} ValAtrib
Função utilizada para substituir o type onde não seja possivél a sua retirada para não haver
ocorrencia indevida pelo SonarQube.

@author 	valter Silva
@since 		09/01/2018
@version 	12
@return 	Nil
/*/
//-----------------------------------------------------------------------
static Function ValAtrib(atributo)
Return (type(atributo) )
