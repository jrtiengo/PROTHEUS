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

/*
Gestor XML - SOLUTIO IT - 2018
Para detalhes do programa ver descritivo técnico
*/
User Function SXUF_001()

	Local cBanco := Alltrim( Upper( TCGetDb() ) )

	Private _cAlias1  := "ZX1"
	Private _cAlias2  := "ZX2"
	Private cLog      := ""
	Private cWorkDir  := ""
	Private lBxXmlAnt := .F.
	Private lORACLE   := "ORACLE" $ cBanco
	Private lMSSQL    := "MSSQL"  $ cBanco
	Private aTesIntOp := {}
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
	Private lGrvBloq  := .F. // Informa se deve bloquear classificar ou gerar pré nota se existir divergência
	Private lAtivar   := .F. // Flag que indica se deve ativar o download por schedule, caso .T., no botão de Download do gestor baixa apenas CT-e

	dbSelectArea( _cAlias2 )
	dbSelectArea( _cAlias1 )
	dbSelectArea("ZX3")

	// Verificação do parâmetro do diretório de trabalho

	// Diretorio de trabalho do programa
	cWorkDir := SuperGetMv("SOL_XML003",.F.,"\system\gestorxml\")

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

	// Informa se deve bloquear classificar ou gerar pré nota se existir divergência
	lGrvBloq := SuperGetMv("SOL_XMLC01",.F.,.F.)

	// Flag que indica se deve ativar o download por schedule, caso .T., no botão de Download do gestor baixa apenas CT-e
	lAtivar := SuperGetMv("SOL_XML033",.F.,.F.)

	// Função de browse
	SXSF_001()

Return

//--------------------------------------------------------------------------------------
// Função de browse dos XML's
//--------------------------------------------------------------------------------------
Static Function SXSF_001()

	Local aCores  := {}
    Local aCorAux := {}
    Local aRot1   := {}
    Local aRot2   := {}

	Private aLegenda  := {}
	Private cCadastro := "Gestor XML"
	Private cString   := _cAlias1
	Private cMark     := GetMark(,"ZX1","ZX1_OK")

	If Empty( cString )
		MsgAlert("Estrutura de dados não definida!")
		Return
	EndIf

	dbSelectArea(cString)
	dbSetOrder(1)

	aCorAux := {{ "ZX1_STATUS=='5'", "BR_BRANCO"  , "Resumo NF-e"        },;
				{ "ZX1_STATUS=='0'", "BR_VERDE"   , "XML Importado"      },;
				{ "ZX1_STATUS=='1'", "BR_AMARELO" , "Pré-Nota Gerada"    },;
				{ "ZX1_STATUS=='2'", "BR_VERMELHO", "Doc. Classificado"  },;
				{ "ZX1_STATUS=='3'", "BR_AZUL"    , "Falta Produto/TES " },;
				{ "ZX1_STATUS=='8'", "BR_MARROM"  , "Doc. Recusado"      },;
				{ "ZX1_STATUS=='9'", "BR_PRETO"   , "Cancelado no Sefaz" } }

				//{ "1=1", "BR_BRANCO"  , "Nome Legenda 6" },;

	For _nCor := 1 To Len( aCorAux )
		aAdd( aCores  , { aCorAux[ _nCor, 1 ], aCorAux[ _nCor, 2 ] } )
		aAdd( aLegenda, { aCorAux[ _nCor, 2 ], aCorAux[ _nCor, 3 ] } )
	Next ni

	aRot1  := { { "Classificar"      , "U_SXUF_005"   , 0, 4, 0, Nil },;
				{ "Gera Pré-Nota"    , "U_SXUF_011"   , 0, 4, 0, Nil },;
				{ "Consulta Doc."    , "U_SXUF_008(2)", 0, 4, 0, Nil },;
				{ "Pedido de Compras", "U_SXUF_013"   , 0, 4, 0, Nil },;
				{ "Produtos"         , "U_SXUF_014"   , 0, 4, 0, Nil },;
				{ "Conferencia TES"  , "U_SXUF_016"   , 0, 4, 0, Nil },;
				{ "Excluir XML"      , "U_SXUF_021"   , 0, 4, 0, Nil },;
				{ "Recusar"          , "U_SXUF_015"   , 0, 4, 0, Nil } }

	aRot2  := { { "Download XML"  , "U_SXUF_020"   , 0, 3, 0, Nil },;
				{ "Consulta Chave", "U_SXUF_008(1)", 0, 3, 0, Nil },;
				{ "Status Sefaz"  , "SpedNFeStatus", 0, 3, 0 ,NIL },;
				{ "Wizard Config.", "SpedNFeCfg"   , 0, 3, 0 ,NIL } }

	Private aRotina := {{ "Pesquisar"     , "AxPesqui"     , 0, 1, 0, Nil },;
						{ "Importar XML"  , "U_SXUF_012"   , 0, 3, 0, Nil },;
						{ "Exportar"      , "U_SXUF_004"   , 0, 4, 0, Nil },;
						{ "Visualizar"    , "U_SXUF_010"   , 0, 2, 0, Nil },;
						{ "Documento"     , aRot1          , 0, 3, 0, Nil },;
						{ "Sefaz"         , aRot2          , 0, 3, 0 ,NIL },;
						{ "Configurações" , "U_SXUF_006"   , 0, 3, 0, Nil },;
						{ "Legenda"       , "U_SXUF_002"   , 0, 3, 0, Nil } }

						//{ "Incluir"   , "AxInclui"  , 0, 3, 0, Nil },;
						//{ "Alterar"   , "AxAltera"  , 0, 4, 0, Nil },;
						//{ "Excluir"   , "AxDeleta"  , 0, 5, 0, .F. },;

	//mBrowse( 6, 1, 22, 75, cString,,,,,, aCores )
	MarkBrow( cString,"ZX1_OK","!ZX1->ZX1_STATUS$'123895 '",,.F.,cMark,,,,,,,,,aCores )

Return

//--------------------------------------------------------------------------------------
// Função de exibição da legenda
//--------------------------------------------------------------------------------------
User Function SXUF_002()

	BrwLegenda( cCadastro, "Legenda", aLegenda )

Return(.T.)


//-------------------------------------------------------------------
// Exportação de XML
//-------------------------------------------------------------------
User Function SXUF_004()

	Local _cXML  := ""
	Local _cSave := ""
	Local cQuery := ""
	Local cAlias := ""
	Local _cDir  := cGetFile( 'Pastas|*.*' , 'Salvar Arquivo', 1, "", .T., GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY )

	If !Empty( _cDir )

		If MsgYesNo("Exportar apenas o documento selecionado?")
			_cXML := ZX1->ZX1_XML
			_cSave := _cDir + ZX1->ZX1_CHVNFE +"-"+ ZX1->ZX1_TPDOC +".xml"

			If !File( _cSave )
				MemoWrite( _cSave, _cXML )
			EndIf
		Else
			If Pergunte("XMLEXP    ")

				cQuery := "SELECT "
				If lORACLE
					cQuery += "SUBSTR(REPLACE(REPLACE(UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(ZX1_XML,1000,1)),CHR(13),''),CHR(10),''),268,8) ZX1_XML,"
				ElseIf lMSSQL
					cQuery += "ISNULL(CONVERT(VARCHAR(2047),CONVERT(VARBINARY(2047),ZX1_XML)),'') ZX1_XML,"
				EndIf
				cQuery += " ZX1_CHVNFE, ZX1_TPDOC FROM " + RetSqlName("ZX1")
				cQuery += " WHERE ZX1_FILIAL  = '"+ xFilial("ZX1") +"'"
				cQuery += "   AND ZX1_EMISSA BETWEEN '"+ DtoS( mv_par01 ) +"' AND '"+ DtoS( mv_par02 ) +"'"
				cQuery += "   AND ZX1_DOC    BETWEEN '"+ mv_par04 +"' AND '"+ mv_par05 +"'"
				cQuery += "   AND ZX1_SERIE  BETWEEN '"+ mv_par06 +"' AND '"+ mv_par07 +"'"
				cQuery += "   AND ZX1_CLIFOR BETWEEN '"+ mv_par08 +"' AND '"+ mv_par09 +"'"
				cQuery += "   AND ZX1_LOJA   BETWEEN '"+ mv_par10 +"' AND '"+ mv_par11 +"'"
				cQuery += "   AND ZX1_CHVNFE BETWEEN '"+ mv_par12 +"' AND '"+ mv_par13 +"'"
				cQuery += "   AND ZX1_DTIMP  BETWEEN '"+ DtoS( mv_par14 ) +"' AND '"+ DtoS( mv_par15 ) +"'"
				If mv_par03 < 3
					cQuery += " AND ZX1_TPDOC = '"+ Iif( mv_par03 == 1, "CTE", "NFE" ) +"'"
				Endif
				cQuery += " AND D_E_L_E_T_ = ' ' "

				TCQuery cQuery New Alias ( cAlias := GetNextAlias() )

				While !(cAlias)->( Eof() )

					_cXML := (cAlias)->ZX1_XML
					_cSave := _cDir + (cAlias)->ZX1_CHVNFE +"-"+ (cAlias)->ZX1_TPDOC +".xml"

					If !File( _cSave )
						MemoWrite( _cSave, _cXML )
					EndIf

					(cAlias)->( dbSkip() )
				End

				(cAlias)->( DbCloseArea() )

			EndIf
		EndIf
	Else
		MsgAlert("É necessário escolher um diretório para salvar os arquivos exportados!")
	EndIf

Return

//-------------------------------------------------------------------
// Configurações da rotina
//-------------------------------------------------------------------
User Function SXUF_006()

	Local oSBtn1, oSBtn2, oBtn1, oSay1
	Local oSayE1, oSayE2, oSayE3, oSayE4, oSayE5, oSayE6, oSayE8, oSayE9
	Local _cPathXML := cWorkDir
	Local aSettings := U_SXUF_007()
	Local lChkPath  := .F.
	Local lImpSef   := aSettings[13]=="S"
	Local lSincAll  := aSettings[14]=="S"
	Local lReSincr  := aSettings[15]=="S"
	Local lSSLCon   := aSettings[11]=="S"
	Local lTLSCon   := aSettings[12]=="S"
	Local lAutCon   := aSettings[10]=="S"
	Local lImpMail  := aSettings[01]=="S"
	Local lTesInt   := aSettings[16]=="S"
	Local _nOptImp  := 0
	Local _cTmpPath := ""
	Local _cValPCo  := cPedComp
	Local _cValPro  := cValProd
	Local lIncEnt   := lCadFImp
	Local _cProto   := PadR( aSettings[02], 04 )
	Local _cConta   := PadR( aSettings[03], 60 )
	Local _cSenha   := PadR( aSettings[04], 25 )
	Local _cServerE := PadR( aSettings[06], 60 )
	Local _cServerS := PadR( aSettings[08], 60 )
	Local _cPortaE  := PadR( aSettings[07], 05 )
	Local _cPortaS  := PadR( aSettings[09], 05 )
	Local _cRemFol  := PadR( aSettings[05], 20 )
	Local bSavConf  := {|| SXSF_010( { Iif(lImpMail,"S","N"),_cProto,_cConta,_cSenha,_cRemFol,_cServerE,_cPortaE,_cServerS,_cPortaS,Iif(lAutCon,"S","N"),Iif(lSSLCon,"S","N"),Iif(lTLSCon,"S","N"), Iif(lImpSef,"S","N"),Iif(lSincAll,"S","N"),Iif(lReSincr,"S","N"), Iif(lTesInt,"S","N"), cLinConf } ) }

	Private oDlgImp, oFolder1, oGetPath, oCBoxDef, oSayE7
	Private aFolder1 := {"&Diretório","&E-mail","&Sefaz","&Geral","&Tes Inteligente"}
	Private _nDefOpt := 1
	Private _cPrdFrV := Iif( Empty( cPrdFrtV ), Space( Len( SB1->B1_COD ) ), cPrdFrtV )
	Private _cTesFrV := Iif( Empty( cTesFrtV ), Space( Len( SD1->D1_TES ) ), cTesFrtV )
	Private _cPagFrV := Iif( Empty( cPagFrtV ), Space( Len( SF1->F1_COND ) ), cPagFrtV )
	Private _cTesFrC := Iif( Empty( cTesFrtC ), Space( Len( SD1->D1_TES ) ), cTesFrtC )
	Private _cPagFrC := Iif( Empty( cPagFrtC ), Space( Len( SF1->F1_COND ) ), cPagFrtC )
	Private _nDiaJob := Iif( nDiasJob == 0, 1, nDiasJob )
	Private _cMailJb := Iif( Empty( cMailJob ), Space( 150 ), cMailJob )
	Private cLinConf := aSettings[17]
	Private aBrwTesI := {}

	oDlgImp  := MSDialog():New( 137,360,443,1025,"Configurações de Importação",,,.F.,,,,,,.T.,,,.T. )
	oFolder1 := TFolder():New( 001,002,aFolder1,{},oDlgImp,,,,.T.,.F.,330,122)
	oSBtn1   := SButton():New( 130,296,1,{|| _nOptImp := 1, oDlgImp:End() },oDlgImp,,"", )
	oSBtn2   := SButton():New( 130,267,2,{|| _nOptImp := 0, oDlgImp:End() },oDlgImp,,"", )
	oFolder1:bSetOption := ( { |nNewOption| SXSF_007( nNewOption, oFolder1:nOption ) } )

	oGetPath := TGet():New( 024,020,{|u| Iif( PCount() > 0, _cPathXML := u, _cPathXML ) },oFolder1:aDialogs[1],248,008,'@!',{||.T.},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","_cPathXML")
	oSay1    := TSay():New( 009,020,{|| "Selecione o diretório de origem dos arquivos XML para importação"},oFolder1:aDialogs[1],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,240,008)
	oCBoxDef := TCheckBox():New( 048,020,"Definir como padrão",{|o| Iif( PCount() > 0, lChkPath := o, lChkPath ) },oFolder1:aDialogs[1],104,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
	oBtn1    := TButton():New( 024,272," ... ",oFolder1:aDialogs[1],{|| _cTmpPath := "", _cTmpPath := cGetFile( 'Pastas|*.*' , 'Diretório XML', 1, _cPathXML, .T., GETF_LOCALHARD + GETF_NETWORKDRIVE + GETF_RETDIRECTORY ), _cPathXML := AllTrim( Iif( Empty( _cTmpPath ), _cPathXML, _cTmpPath ) ), oGetPath:Refresh() },020,010,,,,.T.,,"",,,,.F. )

	oGetPath:lReadOnly := .T. // Não permite digitação no campo, apenas seleção do diretório pelo botão

	oCBoxE1 := TCheckBox():New( 007,012,"Importar de e-mail",{|o| Iif( PCount() > 0, lImpMail := o, lImpMail ) },oFolder1:aDialogs[2],056,008,,{|| oSBtn1:SetFocus(), oCBoxE1:SetFocus() },,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
	oBtnE2  := TButton():New( 007,300,"Salvar",oFolder1:aDialogs[2],{|| MsgRun('Salvando', 'Aguarde... ', bSavConf )},025,008,,,,.T.,,"",,,,.F. )

	oSayE1  := TSay():New( 023,012,{||"Protocolo"},oFolder1:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,048,008)
	oCBoxE2 := TComboBox():New( 032,012,{|o| Iif( PCount() > 0, _cProto := o, _cProto )},{"POP","IMAP","MAPI","SMTP"},042,010,oFolder1:aDialogs[2],,,,CLR_BLACK,CLR_WHITE,.T.,,,,{||lImpMail},,,,,"_cProto" )

	oSayE2  := TSay():New( 023,066,{||"Conta de e-mail"},oFolder1:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oGetE1  := TGet():New( 032,066,{|u| Iif( PCount() > 0, _cConta  := u, _cConta  ) },oFolder1:aDialogs[2],100,008,'',{||.T.},CLR_BLACK,CLR_WHITE,,,,.T.,"",,{||lImpMail},.F.,.F.,,.F.,.F.,"","_cConta")

	oSayE3  := TSay():New( 023,180,{||"Senha"},oFolder1:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oGetE2  := TGet():New( 032,180,{|u| Iif( PCount() > 0, _cSenha  := u, _cSenha  ) },oFolder1:aDialogs[2],050,008,'',{||.T.},CLR_BLACK,CLR_WHITE,,,,.T.,"",,{||lImpMail},.F.,.F.,,.F.,.F.,"","_cSenha")
	oGetE2:lPassword := .T.

	oSayE6  := TSay():New( 023,240,{||"Pasta remota"},oFolder1:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oGetE5  := TGet():New( 032,240,{|u| Iif( PCount() > 0, _cRemFol := u, _cRemFol ) },oFolder1:aDialogs[2],060,008,'',{||.T.},CLR_BLACK,CLR_WHITE,,,,.T.,"",,{||lImpMail},.F.,.F.,,.F.,.F.,"","_cRemFol")

	oSayE4  := TSay():New( 048,012,{||"Servidor Entrada"},oFolder1:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oGetE3  := TGet():New( 057,012,{|u| Iif( PCount() > 0, _cServerE := u, _cServerE ) },oFolder1:aDialogs[2],105,008,'',{||.T.},CLR_BLACK,CLR_WHITE,,,,.T.,"",,{||lImpMail},.F.,.F.,,.F.,.F.,"","_cServerE")

	oSayE5  := TSay():New( 048,130,{||"Porta"},oFolder1:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oGetE4  := TGet():New( 057,130,{|u| Iif( PCount() > 0, _cPortaE  := u, _cPortaE  ) },oFolder1:aDialogs[2],030,008,'',{||.T.},CLR_BLACK,CLR_WHITE,,,,.T.,"",,{||lImpMail},.F.,.F.,,.F.,.F.,"","_cPortaE")

	oSayE8  := TSay():New( 048,170,{||"Servidor Saída"},oFolder1:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,060,008)
	oGetE6  := TGet():New( 057,170,{|u| Iif( PCount() > 0, _cServerS := u, _cServerS ) },oFolder1:aDialogs[2],105,008,'',{||.T.},CLR_BLACK,CLR_WHITE,,,,.T.,"",,{||lImpMail},.F.,.F.,,.F.,.F.,"","_cServerS")

	oSayE9  := TSay():New( 048,288,{||"Porta"},oFolder1:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
	oGetE7  := TGet():New( 057,288,{|u| Iif( PCount() > 0, _cPortaS  := u, _cPortaS  ) },oFolder1:aDialogs[2],030,008,'',{||.T.},CLR_BLACK,CLR_WHITE,,,,.T.,"",,{||lImpMail},.F.,.F.,,.F.,.F.,"","_cPortaS")

	oCBoxE5 := TCheckBox():New( 085,012,"Autenticação",{|o| Iif( PCount() > 0, lAutCon := o, lAutCon ) },oFolder1:aDialogs[2],050,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, {||lImpMail} )
	oCBoxE3 := TCheckBox():New( 085,080,"SSL",{|o| Iif( PCount() > 0, lSSLCon := o, lSSLCon ) },oFolder1:aDialogs[2],032,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, {||lImpMail} )
	oCBoxE4 := TCheckBox():New( 085,115,"TLS",{|o| Iif( PCount() > 0, lTLSCon := o, lTLSCon ) },oFolder1:aDialogs[2],036,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, {||lImpMail} )

	oBtnE1  := TButton():New( 083,160,"Testar Conexão",oFolder1:aDialogs[2],{|| MsgRun('Teste conexão e-mail', 'Aguarde... ',{|| SXSF_009(_cServerE,_cServerS,_cPortaE,_cPortaS,_cConta,_cSenha,lAutCon,lSSLCon,lTLSCon,_cProto,_cRemFol) })},051,012,,,,.T.,,"",,{||lImpMail},,.F. )
	oSayE7  := TSay():New( 85,215,{||""},oFolder1:aDialogs[2],,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,100,008)

	oCBoxS1 := TCheckBox():New( 007,012,"Importar da Sefaz                             ",{|o| Iif( PCount() > 0, lImpSef  := o, lImpSef  ) },oFolder1:aDialogs[3],200,008,,{|| oBtnS1:SetFocus(), oCBoxS1:SetFocus()},,,,,,.T.,"Marque esta caixa para importar o xml diretamente da Sefaz (últimos 3 meses)",, )
	oCBoxS2 := TCheckBox():New( 027,012,"Sincronizar até finalizar todos os documentos.",{|o| Iif( PCount() > 0, lSincAll := o, lSincAll ) },oFolder1:aDialogs[3],200,008,,,,,,,,.T.,"Esta opção sincroniza todos documentos, aumentando o processamento e o tempo para finalização.",,{||lImpSef})
	oCBoxS3 := TCheckBox():New( 047,012,"Refaz a sincronização dos documentos.         ",{|o| Iif( PCount() > 0, lReSincr := o, lReSincr ) },oFolder1:aDialogs[3],200,008,,,,,,,,.T.,"Esta opção irá refazer a sincronização de todos os documentos disponíveis na Sefaz.",,{||lImpSef})
	oBtnS1  := TButton():New( 007,300,"Testar",oFolder1:aDialogs[3],{|| MsgAlert( Iif( CTIsReady(), "Ambiente configurado e OK", "Executar a configuração do ambiente" ) ) },025,008,,,,.T.,,"",,,,.F. )

	oGrpG   := TGroup():New( 007,004,090,130,"|   Validações   |",oFolder1:aDialogs[4],CLR_BLACK,CLR_WHITE,.T.,.F. )
	oGrpG1  := TGroup():New( 007,140,090,230,"| Frete Venda/Remessa |",oFolder1:aDialogs[4],CLR_BLACK,CLR_WHITE,.T.,.F. )
	oGrpG2  := TGroup():New( 007,240,065,300,"| Frete Compras |",oFolder1:aDialogs[4],CLR_BLACK,CLR_WHITE,.T.,.F. )
	oGrpG3  := TGroup():New( 070,240,098,320,"| Dias/Mail para o Job |",oFolder1:aDialogs[4],CLR_BLACK,CLR_WHITE,.T.,.F. )
	oSay2G  := TSay():New( 027,008,{||"Pedido de Compras"},oGrpG,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,048,008)
	oSay1G  := TSay():New( 045,008,{||"Produtos         "},oGrpG,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,048,008)
	oCBoxG1 := TCheckBox():New( 063,008,"Cadastra cliente/fornecedor na importação",{|o| Iif( PCount() > 0, lIncEnt := o, lIncEnt  ) },oGrpG,120,008,,,,,,,,.T.,"Marque esta caixa para cadastrar automaticamente cliente ou fornecedor na importação",, )
	oCBox1G := TComboBox():New( 024,060,{|o| Iif( PCount() > 0, _cValPCo := o, _cValPCo )},{"I=Importação","C=Classificação"},060,010,oGrpG,,,,CLR_BLACK,CLR_WHITE,.T.,,,,{||.T.},,,,,"_cValPCo" )
	oCBox2G := TComboBox():New( 042,060,{|o| Iif( PCount() > 0, _cValPro := o, _cValPro )},{"I=Importação","C=Classificação"},060,010,oGrpG,,,,CLR_BLACK,CLR_WHITE,.T.,,,,{||.T.},,,,,"_cValPro" )
	oGetG1 := TGet():New( 021,150,{|u| If(Pcount()>0,_cPrdFrV:=u,_cPrdFrV)},oGrpG1,060,008,'@!',{|| Vazio().Or.ExistCpo("SB1",_cPrdFrV) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SB1","_cPrdFrV" ,,,,.F.,.F.,,"Produto",1)
	oGetG2 := TGet():New( 042,150,{|u| If(Pcount()>0,_cTesFrV:=u,_cTesFrV)},oGrpG1,015,008,'@!',{|| Vazio().Or.ExistCpo("SF4",_cTesFrV) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SF4","_cTesFrV" ,,,,.F.,.F.,,"Tes",1)
	oGetG3 := TGet():New( 063,150,{|u| If(Pcount()>0,_cPagFrV:=u,_cPagFrV)},oGrpG1,015,008,'@!',{|| Vazio().Or.ExistCpo("SE4",_cPagFrV) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SE4","_cPagFrV" ,,,,.F.,.F.,,"Cond.Pagamento",1)
	oGetG4 := TGet():New( 021,250,{|u| If(Pcount()>0,_cTesFrC:=u,_cTesFrC)},oGrpG2,015,008,'@!',{|| Vazio().Or.ExistCpo("SF4",_cTesFrC) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SF4","_cTesFrC" ,,,,.F.,.F.,,"Tes",1)
	oGetG5 := TGet():New( 042,250,{|u| If(Pcount()>0,_cPagFrC:=u,_cPagFrC)},oGrpG2,015,008,'@!',{|| Vazio().Or.ExistCpo("SE4",_cPagFrC) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SE4","_cPagFrC" ,,,,.F.,.F.,,"Cond.Pagamento",1)
	oGetG6 := TGet():New( 082,250,{|u| If(Pcount()>0,_nDiaJob:=u,_nDiaJob)},oGrpG3,015,008,'99',{|| NaoVazio()                          },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,""   ,"_nDiaJob" ,,,,.F.,.F.,,"",1)
	oGetG7 := TGet():New( 082,265,{|u| If(Pcount()>0,_cMailJb:=u,_cMailJb)},oGrpG3,050,008,''  ,{|| .T.                                 },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,""   ,"_cMailJb" ,,,,.F.,.F.,,"",1)

	oCBoxTI1 := TCheckBox():New( 007,012,"Utiliza Tes Inteligente",{|o| Iif( PCount() > 0, lTesInt := o, lTesInt ) },oFolder1:aDialogs[5],060,008,,{|| oSBtn1:SetFocus(), oCBoxTI1:SetFocus(), oBrwTesI:lActive := lTesInt },,,CLR_BLACK,CLR_WHITE,,.T.,"",, )
	oBtnTI1  := TButton():New( 007,220,"Incluir",oFolder1:aDialogs[5],{|| SXSF_060(1), oBrwTesI:DrawSelect() },025,010,,,,.T.,,"",,{||lTesInt},,.F. )
	oBtnTI2  := TButton():New( 007,260,"Excluir",oFolder1:aDialogs[5],{|| SXSF_060(2, aBrwTesI[ oBrwTesI:nAt ]), oBrwTesI:DrawSelect() },025,010,,,,.T.,,"",,{||lTesInt},,.F. )
	oBtnTI3  := TButton():New( 007,300,"Salvar ",oFolder1:aDialogs[5],{|| MsgRun('Salvando', 'Aguarde... ', bSavConf )},025,010,,,,.T.,,"",,,,.F. )

	oBrwTesI := TWBrowse():New( 20, 04, 330, 080,,{' Operação',' CFOPs a considerar'},{20,80},oFolder1:aDialogs[5],,,,,{||},,,,,,,.F.,,.T.,,.F.)
	aBrwTesI := SXSF_059()
	oBrwTesI:SetArray( aBrwTesI )
	oBrwTesI:bLine := {|| { aBrwTesI[ oBrwTesI:nAt, 01 ], aBrwTesI[ oBrwTesI:nAt, 02 ] } }
	oBrwTesI:bLDblClick := {|| SXSF_060(3, aBrwTesI[ oBrwTesI:nAt ] ), oBrwTesI:DrawSelect()  }
	oBrwTesI:lHScroll := .F.
	oBrwTesI:lActive := lTesInt

	oDlgImp:Activate(,,,.T.,{|| SXSF_008() } )

	If _nOptImp == 1

		If _cPathXML != cWorkDir

			cWorkDir := _cPathXML

			If lChkPath
				PutMv( "SOL_XML003", cWorkDir )
			EndIf

		EndIf

		// Salva todas as informações no arquivo de configuração
		Eval( bSavConf )

		aTesIntOp := SXSF_059() // Atualizo o array global da aplicação com estas informaçoes
		lTesIntOp := lTesInt  // Atualizo o flag de uso da TES inteligente para integração

		If _cValPCo == "I" .And. _cValPro == "C"
			MsgAlert("Não é possível selecionar os pedidos antes de configurar os produtos, portanto também será configurado para validar na classificação do documento!")
			_cValPCo := "C"
		EndIf

		PutMv( "SOL_XML006", _cValPCo )
		PutMv( "SOL_XML007", _cValPro )
		PutMv( "SOL_XML008", Iif( lIncEnt, "S", "N" ) )
		PutMv( "SOL_XML009", _cPrdFrV )
		PutMv( "SOL_XML010", _cTesFrV )
		PutMv( "SOL_XML011", _cPagFrV )
		PutMv( "SOL_XML012", _cTesFrC )
		PutMv( "SOL_XML013", _cPagFrC )
		PutMv( "SOL_XML014", _nDiaJob )
		PutMv( "SOL_XML015", _cMailJb )

		// Atualiza as variáveis privadas principais
		cValProd := _cValPro
		cPedComp := _cValPCo
		lCadFImp := lIncEnt
		cPrdFrtV := _cPrdFrV
		cTesFrtV := _cTesFrV
		cPagFrtV := _cPagFrV
		cTesFrtC := _cTesFrC
		nDiasJob := _nDiaJob
		cMailJob := _cMailJb

	EndIf

Return
//----------------------------------------------------------------------------
// Inicia o processo de importação, verificando sefaz, e-mail e diretório
//----------------------------------------------------------------------------
User Function SXUF_012()

	Local aSettings := U_SXUF_007()
	Local lImpSef   := aSettings[13]=="S"
	Local lSincAll  := aSettings[14]=="S"
	Local lReSincr  := aSettings[15]=="S"
	Local lImpMail  := aSettings[01]=="S"

	Private oProcReg
	Private cLinConf := aSettings[17]

	aTesIntOp := SXSF_059() // Carrega as informações de Tes Inteligente ( CFOP x Operação )

	// Importar do e-mail e salvar no diretório
	If lImpMail
		oProcReg := MsNewProcess():New( {|| SXSF_024() },"Importação de E-mail","Importando arquivos XML de e-mail",.F. )
		oProcReg:Activate()
	EndIf

	// Importar da Sefaz e salvar no diretório
	If lImpSef
		oProcReg := MsNewProcess():New( {|| SXSF_017(lSincAll,lReSincr) },"Importação da Sefaz","Importando arquivos XML da Sefaz",.F. )
		oProcReg:Activate()
	EndIf

	// Importar do diretório, tratar o arquivo e salvar o XML
	oProcReg := MsNewProcess():New( {|| U_SXUF_009( cWorkDir + AllTrim(SM0->M0_CGC) + "\" ) },"Importação do XML","Importando arquivos XML do diretório",.F. )
	oProcReg:Activate()

	MBrChgLoop(.F.) // Evita que o comando de inclusão do mbrowse se repita automaticamente

Return()

//-----------------------------------------------------------------------
// Validação da tela de configurações ao clicar em OK
//-----------------------------------------------------------------------
Static Function SXSF_008()

	Local _lRet := .T.

	If _nDefOpt == Nil .Or. ValType( _nDefOpt ) != "N" .Or. _nDefOpt <= 0 .Or. _nDefOpt > 5
		_lRet := .F.
	Else
		Do Case
			Case _nDefOpt == 1
				If !ExistDir( cWorkDir )
					MsgAlert("Diretório informado não é válido!")
					_lRet := .F.
				EndIf
			Case _nDefOpt == 2

			Case _nDefOpt == 3

			Case _nDefOpt == 4

			Case _nDefOpt == 5

			OtherWise
				_lRet := .F.

		EndCase

	EndIf

Return( _lRet )

//-------------------------------------------------------------------
// Validação do folder da tela de importação de xml para a base
// nNewOpt = Aba que foi clicada
// nAtuOpt = Aba que está atualmente selecionada
//-------------------------------------------------------------------
Static Function SXSF_007( nNewOpt, nAtuOpt )

	_nDefOpt := nNewOpt

Return( .T. )

//-------------------------------------------------------------------
// Valida se o alias escolhido no combo do wizard existe no SX2
//-------------------------------------------------------------------
Static Function SXSF_006( cTab, cCmb )

	Local lOk := .T.
	Local aArea := GetArea()
	Local aAreaSX2 := SX2->( GetArea() )

	If Empty( cTab )
		MsgAlert("Selecionar uma tabela!")
		lOk := .F.
	EndIf

	If lOk .And. cTab == cCmb
		MsgAlert("Selecionar tabelas diferentes para Cabeçalho e Itens!")
		lOk := .F.
	EndIf

	If lOk
		dbSelectArea("SX2")
		dbSetOrder(1)
		If dbSeek(cTab)
			MsgAlert("Tabela "+ cTab +"  já existente!")
			lOk := .F.
		EndIf
    EndIf

	RestArea(aArea)
	RestArea(aAreaSX2)

Return lOk

//----------------------------------------------------------------------------
// Efetua teste de conexão de conta de e-mail configurada para download de xml
//----------------------------------------------------------------------------
Static Function SXSF_009( cServerE, cServerS, cPortaE, cPortaS, cConta, cSenha, lAutCon, lSSLCon, lTLSCon, cProt, cFolder )

	Local oMail  := TMailManager():New()
	Local nDelay := 0
	Local nConn  := 0
	Local nStat  := 0
	Local nQtMsg := 0
	Local cRet   := ""
	Local lFld   := .F.
	Local cProt  := AllTrim( cProt )

	oSayE7:SetText(" ")
	oSayE7:Refresh()

	// Segurança SSl e TLS
	If lSSLCon .And. lTLSCon
		oMail:SetUseSSL( lSSLCon )
		oMail:SetUseTLS( lTLSCon )
	EndIf

	// Inicialização do objeto
	nStat := oMail:Init( AllTrim( cServerE ), AllTrim( cServerS ), AllTrim( cConta ), AllTrim( cSenha ), Val( cPortaE ), Val( cPortaS ) )

	If nStat > 0
		cRet := 'Problema na inicialização'
	EndIf

	If Empty( cRet )

		// TimeOut
		If cProt == 'SMTP'
			nDelay := oMail:GetSMTPTimeOut()
			nDelay := Iif( nDelay != 0, nDelay, 60 )
			oMail:SetSMTPTimeout( nDelay )
		Else
			nDelay := oMail:GetPOPTimeOut()
			nDelay := Iif( nDelay != 0, nDelay, 60 )
			oMail:SetPOPTimeout( nDelay )
		EndIf

		// Conectar ao e-mail
		If cProt == 'POP'
			nConn := oMail:POPConnect()
		ElseIf cProt == 'MAPI' .Or. cProt == 'IMAP'
			nConn := oMail:IMAPConnect()
		ElseIf cProt == 'SMTP'
			nConn := oMail:SmtpConnect()
		EndIf

		If nConn == 0

			// Autenticação
			If lAutCon .And. cProt == 'SMTP'
				nStat := oMail:SMTPAuth( AllTrim( cConta ), AllTrim( cSenha ) )
				If nStat > 0
					cRet := 'Problema na autenticação'
				EndIf
			EndIf

			// Localização de pasta remota
			If cProt == 'IMAP' .And. Empty( cRet ) .And. nStat == 0 .And. !Empty( cFolder )
				lFld := oMail:ChangeFolder( AllTrim( cFolder ) )
				If !lFld
					cRet := 'Erro pasta remota'
				EndIf
			EndIf

			// Desconexão do e-mail
			If cProt == 'IMAP'
				oMail:IMAPDisconnect()
			ElseIf cProt == 'POP '
				oMail:POPDisconnect()
			ElseIf cProt == 'MAPI'
				oMail:SMTPDisconnect()
			ElseIf cProt == 'SMTP'
				oMail:SMTPDisconnect()
			EndIf

			If Empty( cRet )
				cRet := 'Conectado com Sucesso'
			EndIf
		Else
	       cRet := 'Houve um problema: '+ Alltrim( oMail:GetErrorString( nConn ) )
		EndIf

	EndIf

	oSayE7:SetText( cRet )
	oSayE7:Refresh()

Return()

//----------------------------------------------------------------------------
// Retorna os valores contidos no arquivo de configuração de e-mail e Sefaz
//----------------------------------------------------------------------------
User Function SXUF_007()

	Local aRetConf := {}
	Local aConfigs := {}
	Local nPos     := 0
	Local cLinha   := ""
	Local cArqTxt  := cEmpAnt +"_xmlconfigmail.icx"

	// Valida se o arquivo selecionado existe
	If !File( cArqTxt )
		SXSF_010( {"N","IMAP","","","Caixa de Entrada","","143","","25","N","N","N","N","N","N","S",""} ) // Cria o arquivo de configuração com os valores default
	EndIf

	// Abre o arquivo
	nHandle := Ft_Fuse( cArqTxt )

	// Valida erro de abertura do arquivo
	If nHandle == -1
		MsgAlert("Ocorreu um erro na abertura do arquivo de configuração, valores padrão selecionados.", "Atencao!")
		aRetConf := {"N","IMAP","","","Caixa de Entrada","","143","","25","N","N","N","N","N","N","S",""}
		Return( aRetConf )
	EndIf

	// Posiciono no início da primeira linha do arquivo
	Ft_FGoTop()

	// Percorre todas linhas do arquivo
	Do While !Ft_FEof()

		// Lê a linha
		cLinha := Ft_FReadLn()

		// Armazena as informações no array
		aTmp := StrTokArr2( AllTrim( cLinha ), "=", .T. )
		aAdd( aConfigs, aTmp )

		// Passa para a próxima linha
		FT_FSkip()

	EndDo

	// Libera o arquivo lido
	FT_FUse()

	nPos := aScan( aConfigs, {|o| o[1] == "HABILITA" } )
	aAdd( aRetConf, Iif( nPos > 0, aConfigs[ nPos, 2 ], "N" ) )
	nPos := aScan( aConfigs, {|o| o[1] == "PROTOCOLO" } )
	aAdd( aRetConf, Iif( nPos > 0, aConfigs[ nPos, 2 ], "IMAP" ) )
	nPos := aScan( aConfigs, {|o| o[1] == "CONTA" } )
	aAdd( aRetConf, Iif( nPos > 0, aConfigs[ nPos, 2 ], "" ) )
	nPos := aScan( aConfigs, {|o| o[1] == "SENHA" } )
	aAdd( aRetConf, Iif( nPos > 0, aConfigs[ nPos, 2 ], "" ) )
	nPos := aScan( aConfigs, {|o| o[1] == "PASTAREMOTA" } )
	aAdd( aRetConf, Iif( nPos > 0, aConfigs[ nPos, 2 ], "Caixa de Entrada" ) )
	nPos := aScan( aConfigs, {|o| o[1] == "SERVERENTRADA" } )
	aAdd( aRetConf, Iif( nPos > 0, aConfigs[ nPos, 2 ], "" ) )
	nPos := aScan( aConfigs, {|o| o[1] == "PORTAENTRADA" } )
	aAdd( aRetConf, Iif( nPos > 0, aConfigs[ nPos, 2 ], "143" ) )
	nPos := aScan( aConfigs, {|o| o[1] == "SERVERSAIDA" } )
	aAdd( aRetConf, Iif( nPos > 0, aConfigs[ nPos, 2 ], "" ) )
	nPos := aScan( aConfigs, {|o| o[1] == "PORTASAIDA" } )
	aAdd( aRetConf, Iif( nPos > 0, aConfigs[ nPos, 2 ], "25" ) )
	nPos := aScan( aConfigs, {|o| o[1] == "AUTENTICA" } )
	aAdd( aRetConf, Iif( nPos > 0, aConfigs[ nPos, 2 ], "N" ) )
	nPos := aScan( aConfigs, {|o| o[1] == "SSL" } )
	aAdd( aRetConf, Iif( nPos > 0, aConfigs[ nPos, 2 ], "N" ) )
	nPos := aScan( aConfigs, {|o| o[1] == "TLS" } )
	aAdd( aRetConf, Iif( nPos > 0, aConfigs[ nPos, 2 ], "N" ) )
	nPos := aScan( aConfigs, {|o| o[1] == "SEFAZ" } )
	aAdd( aRetConf, Iif( nPos > 0, aConfigs[ nPos, 2 ], "N" ) )
	nPos := aScan( aConfigs, {|o| o[1] == "SINCALL" } )
	aAdd( aRetConf, Iif( nPos > 0, aConfigs[ nPos, 2 ], "N" ) )
	nPos := aScan( aConfigs, {|o| o[1] == "RESINC" } )
	aAdd( aRetConf, Iif( nPos > 0, aConfigs[ nPos, 2 ], "N" ) )
	nPos := aScan( aConfigs, {|o| o[1] == "TESINTELIG" } )
	aAdd( aRetConf, Iif( nPos > 0, aConfigs[ nPos, 2 ], "S" ) )
	nPos := aScan( aConfigs, {|o| o[1] == "OPERCFOP" } )
	aAdd( aRetConf, Iif( nPos > 0, aConfigs[ nPos, 2 ], "" ) )

Return( aRetConf )

//---------------------------------------------------------------------------------------
// Cria o arquivo de configuração de e-mail e Sefaz com valores padrão ou predeterminados
//---------------------------------------------------------------------------------------
Static Function SXSF_010( aSet )

	Local aSettings := aSet
	Local cArqDes   := cEmpAnt +"_xmlconfigmail.icx"

	nArqDes := FCreate( cArqDes )

	If nArqDes < 1
		MsgAlert("Erro na criação do arquivo de configuração de e-mail!","Atencao!")
		Return
	EndIf

	// Grava a linha no arquivo destino
	fWrite( nArqDes, 'HABILITA='+      aSet[ 01 ] + CRLF )
	fWrite( nArqDes, 'PROTOCOLO='+     aSet[ 02 ] + CRLF )
	fWrite( nArqDes, 'CONTA='+         aSet[ 03 ] + CRLF )
	fWrite( nArqDes, 'SENHA='+         aSet[ 04 ] + CRLF )
	fWrite( nArqDes, 'PASTAREMOTA='+   aSet[ 05 ] + CRLF )
	fWrite( nArqDes, 'SERVERENTRADA='+ aSet[ 06 ] + CRLF )
	fWrite( nArqDes, 'PORTAENTRADA='+  aSet[ 07 ] + CRLF )
	fWrite( nArqDes, 'SERVERSAIDA='+   aSet[ 08 ] + CRLF )
	fWrite( nArqDes, 'PORTASAIDA='+    aSet[ 09 ] + CRLF )
	fWrite( nArqDes, 'AUTENTICA='+     aSet[ 10 ] + CRLF )
	fWrite( nArqDes, 'SSL='+           aSet[ 11 ] + CRLF )
	fWrite( nArqDes, 'TLS='+           aSet[ 12 ] + CRLF )
	fWrite( nArqDes, 'SEFAZ='+         aSet[ 13 ] + CRLF )
	fWrite( nArqDes, 'SINCALL='+       aSet[ 14 ] + CRLF )
	fWrite( nArqDes, 'RESINC='+        aSet[ 15 ] + CRLF )
	fWrite( nArqDes, 'TESINTELIG='+    aSet[ 16 ] + CRLF )
	fWrite( nArqDes, 'OPERCFOP='+      aSet[ 17 ] + CRLF )

    // Libero o arquivo gerado
	fClose( nArqDes )

Return

//-------------------------------------------------------------------------
// Exibe interface para consulta de nota fiscal por meio da chave de acesso
//-------------------------------------------------------------------------
User Function SXUF_008( nTip )

	Local oDlgKey, oBtnOut, oBtnCon
	Local cIdEnt    := ""
	Local cChaveNFe := If( nTip == 1, Space(44), ZX1->ZX1_CHVNFE )

	If CTIsReady()

		cIdEnt := SXSF_012() // Retorna o código da Entidade no TSS

		If !Empty(cIdEnt)

			If nTip == 1

				DEFINE MSDIALOG oDlgKey TITLE "Consulta NF-e" FROM 0,0 TO 150,305 PIXEL OF GetWndDefault()

				@ 12,008 SAY "Informe a Chave de acesso da NF-e: " PIXEL OF oDlgKey
				@ 20,008 MSGET cChaveNFe SIZE 140,10 PIXEL OF oDlgKey

				@ 46,035 BUTTON oBtnCon PROMPT "&Consultar" SIZE 38,11 PIXEL ACTION SXSF_011( cChaveNFe, cIdEnt )
				@ 46,077 BUTTON oBtnOut PROMPT "&Sair" SIZE 38,11 PIXEL ACTION oDlgKey:End()

				ACTIVATE DIALOG oDlgKey CENTERED

			Else
				SXSF_011( cChaveNFe, cIdEnt )
			EndIf
		Else
			Aviso("SPED","Execute o módulo de configuração do serviço, antes de utilizar esta opção.",{"OK"},3)
		EndIf
	Else
		Aviso("SPED","Execute o módulo de configuração do serviço, antes de utilizar esta opção.",{"OK"},3)
	EndIf

Return

//-----------------------------------------------------------------
// Efetua a consulta e retorna o resultado
//-----------------------------------------------------------------
Static Function SXSF_011( cChaveNFe, cIdEnt, lBlind, lJob )

	Local cURL     := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local cMensagem:= ""
	Local oWS

	Default lBlind := .F.
	Default lJob   := .F.

	// Cria o objeto da classe NFE
	oWs:= WsNFeSBra():New()
	oWs:cUserToken := "TOTVS"
	oWs:cID_ENT    := cIdEnt
	ows:cCHVNFE	   := cChaveNFe
	oWs:_URL       := AllTrim(cURL)+"/NFeSBRA.apw"

	// Chama o método de consulta pela chave da nota
	If oWs:ConsultaChaveNFE()

		cMensagem := ""

		If !Empty( oWs:oWSCONSULTACHAVENFERESULT:cVERSAO )
			cMensagem += "Versão: "+ oWs:oWSCONSULTACHAVENFERESULT:cVERSAO+CRLF
		EndIf

		cMensagem += "Ambiente: "   + Iif(oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE==1,"Produção","Homologação")+CRLF
		cMensagem += "Cód.Retorno: "+ oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE+CRLF
		cMensagem += "Situação: "   + oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE+CRLF

		If !Empty( oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO )
			cMensagem += "Protocolo: "+ oWs:oWSCONSULTACHAVENFERESULT:cPROTOCOLO+CRLF
		EndIf

	    If !Empty( oWs:oWSCONSULTACHAVENFERESULT:cDIGVAL )
			cMensagem += "Digest Value: "+ oWs:oWSCONSULTACHAVENFERESULT:cDIGVAL+CRLF
		EndIf

		If !lBlind
			Aviso("SPED",cMensagem,{"OK"},3)
		Else
			If lJob
				// { AMBIENTE, CÓDIGO RETORNO, SITUAÇÃO }
				Return( {oWs:oWSCONSULTACHAVENFERESULT:nAMBIENTE, oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE, oWs:oWSCONSULTACHAVENFERESULT:cMSGRETNFE } )
			Else
				Return( AllTrim( oWs:oWSCONSULTACHAVENFERESULT:cCODRETNFE ) )
			EndIf
		EndIf

	Else
		If !lBlind
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
		Else
			Return("")
		EndIf
	EndIf

Return


//-----------------------------------------------------------------
// Retorna o código da entidade cadastrada na configuração do TSS
//-----------------------------------------------------------------
Static Function SXSF_012( lUsaColab )

	Local aArea      := GetArea()
	Local aEndereco  := FisGetEnd(SM0->M0_ENDENT)
	Local aTelefone  := FisGetTel(SM0->M0_TEL)
	Local cFax       := FisGetTel(SM0->M0_FAX)[3]
	Local cURL       := PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local lUsaGesEmp := IIF(FindFunction("FWFilialName") .And. FindFunction("FWSizeFilial") .And. FWSizeFilial() > 2,.T.,.F.)
	Local lEnvCodEmp := GetNewPar("MV_ENVCDGE",.F.)
	Local cGetIdEnt  := ""
	Local oWs

	Default lUsaColab := .F.

	If !Empty( AllTrim( cURL ) )

		oWS := WsSPEDAdm():New()
		oWS:cUSERTOKEN := "TOTVS"

		oWS:oWSEMPRESA:cCNPJ       := IIF(SM0->M0_TPINSC==2 .Or. Empty(SM0->M0_TPINSC),SM0->M0_CGC,"")
		oWS:oWSEMPRESA:cCPF        := IIF(SM0->M0_TPINSC==3,SM0->M0_CGC,"")
		oWS:oWSEMPRESA:cIE         := SM0->M0_INSC
		oWS:oWSEMPRESA:cIM         := SM0->M0_INSCM
		oWS:oWSEMPRESA:cNOME       := SM0->M0_NOMECOM
		oWS:oWSEMPRESA:cFANTASIA   := IIF(lUsaGesEmp,FWFilialName(),Alltrim(SM0->M0_NOME))
		oWS:oWSEMPRESA:cENDERECO   := FisGetEnd(SM0->M0_ENDENT)[1]
		oWS:oWSEMPRESA:cNUM        := FisGetEnd(SM0->M0_ENDENT)[3]
		oWS:oWSEMPRESA:cCOMPL      := FisGetEnd(SM0->M0_ENDENT)[4]
		oWS:oWSEMPRESA:cUF         := SM0->M0_ESTENT
		oWS:oWSEMPRESA:cCEP        := SM0->M0_CEPENT
		oWS:oWSEMPRESA:cCOD_MUN    := SM0->M0_CODMUN
		oWS:oWSEMPRESA:cCOD_PAIS   := "1058"
		oWS:oWSEMPRESA:cBAIRRO     := SM0->M0_BAIRENT
		oWS:oWSEMPRESA:cMUN        := SM0->M0_CIDENT
		oWS:oWSEMPRESA:cCEP_CP     := Nil
		oWS:oWSEMPRESA:cCP         := Nil
		oWS:oWSEMPRESA:cDDD        := Str(FisGetTel(SM0->M0_TEL)[2],3)
		oWS:oWSEMPRESA:cFONE       := AllTrim(Str(FisGetTel(SM0->M0_TEL)[3],15))
		oWS:oWSEMPRESA:cFAX        := AllTrim(Str(FisGetTel(SM0->M0_FAX)[3],15))
		oWS:oWSEMPRESA:cEMAIL      := UsrRetMail(RetCodUsr())
		oWS:oWSEMPRESA:cNIRE       := SM0->M0_NIRE
		oWS:oWSEMPRESA:dDTRE       := SM0->M0_DTRE
		oWS:oWSEMPRESA:cNIT        := IIF(SM0->M0_TPINSC==1,SM0->M0_CGC,"")
		oWS:oWSEMPRESA:cINDSITESP  := ""
		oWS:oWSEMPRESA:cID_MATRIZ  := ""

		If lUsaGesEmp .And. lEnvCodEmp
			oWS:oWSEMPRESA:CIDEMPRESA:= FwGrpCompany()+FwCodFil()
		EndIf

		oWS:oWSOUTRASINSCRICOES:oWSInscricao := SPEDADM_ARRAYOFSPED_GENERICSTRUCT():New()
		oWS:_URL := AllTrim(cURL)+"/SPEDADM.apw"
		If oWs:ADMEMPRESAS()
			cGetIdEnt  := oWs:cADMEMPRESASRESULT
		Else
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"Aviso"},3)
		EndIf

		FreeObj(oWs)
		oWs := nil

	EndIf

Return( cGetIdEnt )

//-------------------------------------------------------------------------
// Prepara os dados para o manifesto de ciência e a baixa dos arquivos XML
//-------------------------------------------------------------------------
Static function SXSF_017( lSincAll, lReSincr )

	Local aChave	 := {}
	Local aDocs		 := {}
	Local aProc	     := {}
	Local lRefazSinc := lReSincr
	Local cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
//	Local cIdEnt	:= SXSF_012()
	Local cChave	:= ""
	Local cCancNSU	:= ""
	Local cAlert	:= ""
	Local cSitConf	:= ""
	Local cAmbiente	:= ""
	Local cQuery    := ""
	Local cAlias    := ""
	Local lContinua	:= .T.
	Local lOk       := .F.
	Local nX		:= 0
	Local nZ		:= 0
	Local aChvSinc  := {}

	Private oWs		:= Nil
/*
	If CTIsReady()

		oProcReg:SetRegua1(5)
		oProcReg:IncRegua1("Preparando conexão...")

		oWs := WSMANIFESTACAODESTINATARIO():New()
		oWs:cUserToken := "TOTVS"
		oWs:cIDENT	   := cIdEnt
		oWs:cINDNFE    := "0"
		oWs:cINDEMI    := "0"
		oWs:_URL       := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"

		cAmbiente      := SXSF_013()

		// Refaz a sincronização de todos os documentos disponiveis na SEFAZ
		If lReSincr
			oWs:cUltNSU	:= "0"
		Endif

		// Configura e retorna os parâmetros configurados para a sincronização e manutenção dos documentos da Manifestação do Destinatário
		oWs:CONFIGURARPARAMETROS()

		oProcReg:IncRegua1("Realizando a sincronização de dados (C00)...")

		//Tratamento para solicitar a sincronização enaquanto o IDCONT não retornar zero.
		While lContinua

			lOk		:= .F.
			aChave	:= {}
			aProc	:= {}

			If oWs:SINCRONIZARDOCUMENTOS()
				If Type ("oWs:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO") <> "U"
					If Type("oWs:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO") == "A"
						aDocs := oWs:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO
					Else
						aDocs := {oWs:OWSSINCRONIZARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSSINCDOCUMENTOINFO}
					EndIf

					For nX := 1 To Len( aDocs )
						If Type( aDocs[nX]:CCHAVE ) <> "U" .And. Type( aDocs[nX]:CSITCONF ) <> "U"
							cSitConf  := aDocs[Nx]:CSITCONF
							cChave    := aDocs[Nx]:CCHAVE
							cCancNSU  := aDocs[Nx]:CCANCNSU

							// Atualiza a tabela C00 com as informações do estado da sincronização
							If SXSF_014( cChave, cSitConf, cCancNSU )
								aAdd( aChave, cChave )
								lOk := .T.
							Endif

						EndIf
					Next

					If lOk

						oProcReg:SetRegua2( Len( aChave ) )

						For nZ := 1 To Len( aChave )

							aAdd( aProc, aChave[nZ] )

							oProcReg:IncRegua2("Monitorando a sincronização "+ cValToChar( nZ ) +" de "+ cValToChar( Len( aChave ) ) )

							// Monitoramento da sincronização a cada 30 documentos
							If Len( aProc ) >= 30
								SXSF_016( aProc, cAmbiente, cIdEnt, cUrl )
								aProc := {}
							Endif

						Next

						// Monitoramento da sincronização - documentos restantes
						If Len( aProc ) > 0
							SXSF_016( aProc, cAmbiente, cIdEnt, cUrl )
						Endif

					EndIf

					If Type("oWs:OWSSINCRONIZARDOCUMENTOSRESULT:CINDCONT") <> "U"
						If oWs:OWSSINCRONIZARDOCUMENTOSRESULT:CINDCONT == "0"
							lContinua := .F.
						EndIf
					Else
						lContinua := .F.
					EndIf

					If Empty( aDocs ) .And. !lContinua .And. !lOk
						cAlert:= "Não há documentos para serem sincronizados"
						Aviso("Sincronização",cAlert,{"OK"},3)
					EndIF

					If lContinua .And. !lReSincr .And. !lSincAll
						lContinua := MsgYesNo("Ainda existem documentos na SEFAZ a serem sincronizados, deseja solicitar novamente a sincronização ?")
					EndIf

					Sleep(500)

				EndIf
			Else

				Aviso("SPED",Iif( Empty( GetWscError(3)), GetWscError(1), GetWscError(3) ), {"OK"}, 3 )
				lContinua := .F.

			EndIf
		EndDo

		aChave := Iif( ValType(aChave) == "A", aChave, {} )

		// Verifica se existem registros no C00 pendentes de monitoramento
		cQuery := "SELECT C00_CHVNFE "
		cQuery += " FROM "+ RetSqlName("C00")
		cQuery += " WHERE C00_FILIAL='"+ xFilial("C00") +"' "
		cQuery += " AND C00_CNPJEM = ' '  "

		TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
		(cAlias)->( dbGotop() )

		While !(cAlias)->( Eof() )

			If aScan( aChave, {|o| AllTrim( o ) == (cAlias)->C00_CHVNFE } ) == 0
				aAdd( aChave, (cAlias)->C00_CHVNFE )
			EndIf

			(cAlias)->( dbSkip() )
		End
		(cAlias)->( dbCloseArea() )

		aProc := {}

		For nZ := 1 To Len( aChave )

			aAdd( aProc, aChave[nZ] )

			// Monitoramento da manifestação a cada 30 documentos
			If Len( aProc ) >= 30
				SXSF_016( aProc, cAmbiente, cIdEnt, cUrl )
				aProc := {}
			Endif

		Next

		// Monitoramento da manifestação - documentos restantes
		If Len( aProc ) > 0
			SXSF_016( aProc, cAmbiente, cIdEnt, cUrl )
		Endif

	Else
		Aviso("SPED","Execute o módulo de configuração do serviço, antes de utilizar esta opção.",{"Atenção"},3)
	EndIf

	oWs := Nil
	DelClassIntf()

	// Retorna todas as chaves sincronizadas ainda não manifestadas (não feito o download)
	// Alterado para manifestar apenas as notas que acabaram de ser sincronizadas
	aChvSinc := aChave //SXSF_034()

	oProcReg:IncRegua1("Realizando a manifestação de Ciência da Operação...")

	If Len( aChvSinc ) > 0 // Chaves sincronizadas que não foram manifestadas

		aProc := {}

		For nF := 1 To Len( aChvSinc )

			aAdd( aProc, aChvSinc[nF] )

			// Montagem do XML para manifestação de ciência
			If Len( aProc ) >= 20
				SXSF_018( aProc, .F. )
				aProc := {}
			Endif

		Next

		// Montagem do XML para manifestação de ciência
		If Len( aProc ) > 0
			SXSF_018( aProc, .F. )
		Endif

	EndIf
*/
	// Baixa os arquivos que foram manifestados com sucesso
	oProcReg:IncRegua1("Realizando o download dos arquivos...")
	//SXSF_021( aChvSinc )
	If !lAtivar // Download de nota apenas se desativar o schedule do check de notas
		Processa({|| U_SXUF_024() },"Processando","Aguarde, realizando download de NF-e",.T.)
	EndIf

	// Realiza a comunicação com o Sefaz para download do CT-e
	oProcReg:IncRegua1("Realizando o download de CT-e...")
	Processa({|| U_SXUF_023() },"Processando","Aguarde, realizando download de CT-e",.T.)

Return


//-------------------------------------------------------------------------------------------
// Retorna todas as chaves sincronizadas ainda não manifestadas (também não feito o download)
//-------------------------------------------------------------------------------------------
Static Function SXSF_034()

	Local aArea		:= GetArea()
	Local cAliasTemp:= GetNextAlias()
	Local aChaves	:= {}
	Local cWhere	:= ""

	cWhere += "%"
	cWhere += " C00_FILIAL='"+ xFilial("C00") +"'"
	cWhere += " AND C00_STATUS IN ('0') "
	cWhere += "%"

	BeginSql Alias cAliasTemp
		SELECT C00_CHVNFE
		FROM %Table:C00%
		WHERE %Exp:cWhere% AND
		%notdel%
	EndSql

	(cAliasTemp)->( dbGotop() )

	While !(cAliasTemp)->(Eof())
		aAdd( aChaves, (cAliasTemp)->C00_CHVNFE )
		(cAliasTemp)->( dbSkip() )
	End

	(cAliasTemp)->(dbCloseArea())
	RestArea(aArea)

Return( aChaves )

//---------------------------------------------------
// Retorna o ambiente da configuração atual do TSS
//---------------------------------------------------
Static Function SXSF_013()

	Local cAmbiente := ""
	Local cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local oWs

	If CTIsReady()

		oWs :=WSMANIFESTACAODESTINATARIO():New()

		oWs:cUserToken   := "TOTVS"
		oWs:cIDENT       := retIdEnti()
		oWs:cAMBIENTE    := ""
		oWs:cVERSAO      := ""
		oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"

		oWs:CONFIGURARPARAMETROS()
		cAmbiente        := oWs:OWSCONFIGURARPARAMETROSRESULT:CAMBIENTE

		FreeObj(oWs)
		oWs := nil

	EndIf

Return( cAmbiente )

//--------------------------------------------------------------------
// Atualiza a tabela C00 com as informações do estado da sincronização
//--------------------------------------------------------------------
Static Function SXSF_014( cChave, cSitConf, cCancNSU )

	Local _dData := CtoD("01/"+ Substr( cChave, 5, 2 ) +"/"+ Substr( cChave, 3, 2 ) )
	Local _lOk   := .F.

	C00->( dbSetOrder(1) )
	If !C00->( DbSeek( xFilial("C00") + cChave ) )

		RecLock("C00",.T.)
			C00->C00_FILIAL := xFilial("C00")
			C00->C00_STATUS := cSitConf
			C00->C00_CHVNFE := cChave
			C00->C00_ANONFE := StrZero( Year( _dData ), 4 )
			C00->C00_MESNFE := StrZero( Month( _dData ), 2 )
			C00->C00_SERNFE := SubStr( cChave, 23, 3 )
			C00->C00_NUMNFE := SubStr( cChave, 26, 9 )
			C00->C00_CODEVE := Iif( cSitConf $ "0", "1", "3" )
		MsUnLock()

		lOk := .T.

	Else
		If !Empty( cCancNSU )
			RecLock("C00",.F.)
				C00->C00_SITDOC := "3"
			MsUnLock()
		EndIf
	EndIf

Return( _lOk )

//--------------------------------------------------------
// Atualiza a tabela C00 com as informações das entidades
//--------------------------------------------------------
Static Function SXSF_015( cChave, cCNPJEmit, cIeEmit, cNomeEmit, cSitConf, cSituacao, cDesResp, cDesCod, dDtEmi, dDtRec, nValDoc )

	C00->( dbSetOrder(1) )
	If C00->( DbSeek( xFilial("C00") + cChave ) )
		RecLock("C00",.F.)
			C00->C00_CNPJEM := Alltrim(cCNPJEmit)
			C00->C00_IEEMIT := AllTrim(cIeEmit)
			C00->C00_NOEMIT := Alltrim(cNomeEmit)
			C00->C00_STATUS := cSitConf
			C00->C00_SITDOC := cSituacao
			C00->C00_DESRES := Alltrim(cDesResp)
			C00->C00_CODRET := cDesCod
			C00->C00_DTEMI  := dDtEmi
			C00->C00_DTREC  := dDtRec
			C00->C00_VLDOC  := nValDoc
			C00->C00_CODEVE := Iif( Alltrim( C00->C00_STATUS ) $ "0", "1", "3" )
		C00->( MsUnLock() )
	EndIf

Return( Nil )

//----------------------------------------------------------------
// Realiza o monitoramento da Manifestação ao sincronizar os dados
//----------------------------------------------------------------
Static Function SXSF_016( aChave, cAmbiente, cIdEnt, cUrl, lJob )

	Local cChave    := ""
	Local cCNPJEmit := ""
	Local cIeEmit   := ""
	Local cNomeEmit := ""
	Local cSitConf  := ""
	Local cSituacao := ""
	Local cDesResp  := ""
	Local cDesCod   := ""
	Local dDtEmi    := CtoD("//")
	Local dDtRec    := CtoD("//")
	Local nValDoc   := 0
	Local nZ        := 0
	Local nY        := 0
	Local aMonDoc   := {}

	Private oWS     := Nil

	Default lJob    := .F.

	If CTIsReady()

		oWs := WSMANIFESTACAODESTINATARIO():New()
		oWs:cUserToken   := "TOTVS"
		oWs:cIDENT       := cIdEnt
		oWs:cAMBIENTE    := cAmbiente
		oWs:OWSMONDADOS:OWSDOCUMENTOS := MANIFESTACAODESTINATARIO_ARRAYOFMONDOCUMENTO():New()

		For nY := 1 to Len(aChave)
			aadd(oWs:OWSMONDADOS:OWSDOCUMENTOS:OWSMONDOCUMENTO,MANIFESTACAODESTINATARIO_MONDOCUMENTO():New())
			oWs:OWSMONDADOS:OWSDOCUMENTOS:OWSMONDOCUMENTO[nY]:CCHAVE := aChave[nY]
		Next

		oWs:_URL := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"

		If oWs:MONITORARDOCUMENTOS()

			If Type ("oWs:OWSMONITORARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSMONDOCUMENTORET") <> "U"
				If Type ("oWs:OWSMONITORARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSMONDOCUMENTORET") == "A"
					aMonDoc := oWs:OWSMONITORARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSMONDOCUMENTORET
				Else
					aMonDoc := {oWs:OWSMONITORARDOCUMENTOSRESULT:OWSDOCUMENTOS:OWSMONDOCUMENTORET}
				EndIf
			EndIF

			For nZ := 1 to Len( aMonDoc )

				If Type( aMonDoc[ nZ ]:CCHAVE ) <> "U"

					cChave    := aMonDoc[nZ]:CCHAVE
					cCNPJEmit := Iif( !Empty( Alltrim( aMonDoc[nZ]:CEMITENTECNPJ ) ), Alltrim( aMonDoc[nZ]:CEMITENTECNPJ ), Alltrim( aMonDoc[nZ]:CEMITENTECPF ) )
					cIeEmit   := AllTrim( aMonDoc[nZ]:CEMITENTEIE )
					cNomeEmit := Alltrim( aMonDoc[nZ]:CEMITENTENOME )
					cSitConf  := aMonDoc[nZ]:CSITUACAOCONFIRMACAO
					cSituacao := aMonDoc[nZ]:CSITUACAO
					cDesResp  := Alltrim( aMonDoc[nZ]:CRESPOSTADESCRICAO )
					cDesCod   := aMonDoc[nZ]:CRESPOSTASTATUS
					dDtEmi    := StoD( StrTran(aMonDoc[nZ]:CDATAEMISSAO,"-","") )
					dDtRec    := StoD( StrTran(aMonDoc[nZ]:CDATAAUTORIZACAO,"-","") )
					nValDoc   := aMonDoc[nZ]:NVALORTOTAL

					// Atualizo os dados para o documento na C00
					SXSF_015( cChave, cCNPJEmit, cIeEmit, cNomeEmit, cSitConf, cSituacao, cDesResp, cDesCod, dDtEmi, dDtRec, nValDoc )

				EndIf

			Next

		Else
			If !lJob
				Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)), {"OK"}, 3 )
			EndIf
		EndIf
	Else
		If !lJob
			Aviso("SPED","Execute o módulo de configuração do serviço, antes de utilizar esta opção.", {"Atenção"}, 3 )
		EndIf
	EndIf

	// Zerar todos os objetos da classe
	oWs := Nil
	DelClassIntf()

Return( Nil )


//---------------------------------------------------------------
// Monta o XML de manifestação de ciência para envio ao Sefaz
//---------------------------------------------------------------
Static Function SXSF_018( aMontXml, lRecusa )

	Local aRet       := {}
	Local cAmbiente  := ""
	Local cXml       := ""
	Local cTpEvento  := Iif( lRecusa, "210220", "210210" )// Evento de desconhecimento ou ciência da operação
	Local cIdEnt     := SXSF_012()
	Local cURL       := PadR( GetNewPar("MV_SPEDURL","http://"), 250 )
	Local cChavesMsg := ""
	Local cMsgManif  := ""
	Local cIdEven    := ""
	Local cErro      := ""
	Local cRetPE     := ""
	Local aNfe       := {}
	Local lRetOk     := .T.
	Local nX         := 0
	Local nZ         := 0

	Private oWs := Nil

	If CTIsReady()

		oWs :=WSMANIFESTACAODESTINATARIO():New()
		oWs:cUserToken   := "TOTVS"
		oWs:cIDENT	     := cIdEnt
		oWs:cAMBIENTE	 := ""
		oWs:cVERSAO      := ""
		oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"

		If oWs:CONFIGURARPARAMETROS()

			cAmbiente		 := oWs:OWSCONFIGURARPARAMETROSRESULT:CAMBIENTE

			cXml+='<envEvento>'
			cXml+='<eventos>'

			For nX:=1 To Len( aMontXml )

				cXml+='<detEvento>'
				cXml+='<tpEvento>'+ cTpEvento                +'</tpEvento>'
				cXml+='<chNFe>'   + Alltrim( aMontXml[ nX ] )+'</chNFe>'
				cXml+='<ambiente>'+ cAmbiente                +'</ambiente>'
				cXml+='</detEvento>'

			Next

			cXml+='</eventos>'
			cXml+='</envEvento>'

			lRetOk := SXSF_019( cXml, cIdEnt, cUrl, @aRet )

		Else
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
		EndIf

		If lRetOk .And. Len( aRet ) > 0

			For nZ:=1 to Len(aRet)
				aRet[nZ] := Substr( aRet[nZ], 9, 44 )
				cChavesMsg += aRet[nZ] + Chr(10) + Chr(13)
			Next

			cMsgManif := "Transmissão da Manifestação concluída com sucesso!"+ Chr(10) + Chr(13)
			cMsgManif += "Chave(s): "+ Chr(10) + Chr(13)
			cMsgManif += cChavesMsg

			cRetorno := Alltrim( cMsgManif )

			// Atualiza o status da C00
			SXSF_020( aRet, cTpEvento )

		EndIf

	Else
		Aviso( "SPED", "Execute o módulo de configuração do serviço, antes de utilizar esta opção.", {"Atenção"}, 3 )
	EndIf

Return lRetOk

//---------------------------------------------------------------
// Realiza o envio do XML de manifestação e retorna o resultado
//---------------------------------------------------------------
Static Function SXSF_019( cXmlReceb, cIdEnt, cUrl, aRet )

	Local lRetOk := .T.
	Default aRet := {}

	If CTIsReady()

		oWs:= WsNFeSBra():New()
		oWs:cUserToken	:= "TOTVS"
		oWs:cID_ENT		:= cIdEnt
		oWs:cXML_LOTE	:= cXmlReceb
		oWS:_URL		:= AllTrim( cURL ) +"/NFeSBRA.apw"

		If oWs:RemessaEvento()
			If Type("oWS:oWsRemessaEventoResult:cString") <> "U"
				If Type("oWS:oWsRemessaEventoResult:cString") <> "A"
					aRet:={oWS:oWsRemessaEventoResult:cString}
				Else
					aRet:=oWS:oWsRemessaEventoResult:cString
				EndIf
			EndIf
		Else
			lRetOk := .F.
			Aviso("SPED",IIf(Empty(GetWscError(3)),GetWscError(1),GetWscError(3)),{"OK"},3)
		Endif
	Else
		Aviso("SPED","Execute o módulo de configuração do serviço, antes de utilizar esta opção.",{"Atenção"},3)
	EndIf

Return lRetOk

//------------------------------------------------
// Atualiza o status da manifestação na tabela C00
//------------------------------------------------
Static Function SXSF_020( aRet, cTpEvento )

	Local aArea := GetArea()
	Local cStat := ""
	Local nX    := 0

	If cTpEvento $ '210200'
		cStat:= "1"  //Confirmada operação
	ElseIf cTpEvento $ '210220'
		cStat:= "2"  //Desconhecimento da Operação
	ElseIf cTpEvento $ '210240'
		cStat:= "3"  //Operação não Realizada
	ElseIf cTpEvento $ '210210'
		cStat:= "4"  //Ciência da operação
	EndIf

	For nX:=1 to Len( aRet )

		C00->( dbSetOrder(1) )

		If C00->( dbSeek( xFilial("C00") + aRet[ nX ] ) )
			RecLock("C00")
				C00->C00_STATUS := cStat
				C00->C00_CODEVE := "2"
			MsUnlock()
		EndIf

	Next

	RestArea( aArea )

Return

//-------------------------------------------------------
// Seleciona as chaves que foram manifestadas com sucesso
//-------------------------------------------------------
Static Function SXSF_021( aRet, lRegua )

	Local aArea		:= GetArea()
	Local cAliasTemp:= GetNextAlias()
	Local cURL		:= PadR(GetNewPar("MV_SPEDURL","http://"),250)
	Local cIdEnt	:= SXSF_012()
	Local aChaves	:= {}
	Local aChvTmp   := Iif( aRet == Nil, {}, Iif( ValType( aRet ) != "A", {}, aRet ) )
	Local aXmlRet	:= {}
	Local cChaves   := ""
	Local cAmbiente	:= ""
	Local cAviso	:= ""
	Local cChvTmp   := ""
	Local lRet		:= .F.
	Local lOkChv    := .F.
	Local nX		:= 0
	Local nY		:= 0
	Local nZ		:= 0
	Local nL        := 0
	Local nW		:= 0
	Local nXAux		:= 0
	Local nQtdChv	:= 0
	Local aNoChave  := {}
	Local cDestino  := SuperGetMv("SOL_XML003",.F.,"\system\gestorxml\")
	Local aXML      := DIRECTORY( cDestino + "*.XML" )

	Private oRet

	Default lRegua := .T.

	If CTIsReady()

		// Armazenar o nome dos arquivos xmls já baixados
		For nL := 1 To Len( aXML )
			If File( Alltrim( cDestino + aXML[ nL, 1 ] ) )
				aAdd( aNoChave, aXML[ nL, 1 ] )
			EndIf
		Next

		// Seleciona na C00 apenas as chaves
		cQuery := "SELECT C00_CHVNFE "
		cQuery += " FROM "+ RetSqlName("C00")
		cQuery += " WHERE C00_XMLOK <> '1' "
		cQuery += " AND C00_FILIAL='"+ xFilial("C00") +"' "
		//cQuery += " AND C00_CODEVE = '3' "

		TCQuery cQuery New Alias ( cAliasTemp := GetNextAlias() )
		(cAliasTemp)->( dbGotop() )

		If (cAliasTemp)->( Eof() )
			MsgAlert("Nenhuma chave apta a baixar XML!")
			Return( .F. )
		Else
			While !(cAliasTemp)->( Eof() )

				lOkChv := .T.
				cChvTmp := (cAliasTemp)->C00_CHVNFE

				If aScan( aChvTmp, {|o| o == cChvTmp } ) == 0
					aAdd( aChvTmp, cChvTmp )
				EndIf

				(cAliasTemp)->( dbSkip() )
			End
		EndIf
		(cAliasTemp)->( dbCloseArea() )
		RestArea(aArea)

		For nL := 1 To Len( aChvTmp )

			lOkChv := .T.
			cChvTmp := aChvTmp[ nL ]

			For nG := 1 To Len( aNoChave )
				If AllTrim( cChvTmp ) $ aNoChave[ nG ]
					lOkChv := .F.
					Exit
				EndIf
			Next

			If lOkChv
				aAdd( aChaves, cChvTmp )
			EndIf

		Next

		oWs := WSMANIFESTACAODESTINATARIO():New()
		oWs:cUserToken   := "TOTVS"
		oWs:cIDENT	     := cIdEnt
		oWs:cAMBIENTE	 := ""
		oWs:cVERSAO      := ""
		oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"
		oWs:CONFIGURARPARAMETROS()
		cAmbiente		 := oWs:OWSCONFIGURARPARAMETROSRESULT:CAMBIENTE

		oWs:cUserToken   := "TOTVS"
		oWs:cIDENT	     := cIdEnt
		oWs:cAMBIENTE	 := cAmbiente
		oWs:_URL         := AllTrim(cURL)+"/MANIFESTACAODESTINATARIO.apw"

		cAviso := "Arquivos gerados: "+ CRLF + CRLF + "Série  Número" + CRLF

		If lRegua
			oProcReg:SetRegua2( Len( aChaves ) )
		EndIf

		While nQtdChv < Len( aChaves )

			If lRegua
				oProcReg:IncRegua2("Processando documentos...")
			EndIf

			oWs:oWSDOCUMENTOS:oWSDOCUMENTO  := MANIFESTACAODESTINATARIO_ARRAYOFBAIXARDOCUMENTO():New()

			If ( Len( aChaves ) - nQtdChv ) < 5

				nXAux := 1

				For nX:= nQtdChv+1 to Len(aChaves)
					aAdd(oWs:oWSDOCUMENTOS:oWSDOCUMENTO:oWSBAIXARDOCUMENTO,MANIFESTACAODESTINATARIO_BAIXARDOCUMENTO():New())
					oWs:oWSDOCUMENTOS:oWSDOCUMENTO:oWSBAIXARDOCUMENTO[nXAux]:CCHAVE := aChaves[nX]
					nXAux++
					nQtdChv++
				Next nX

				If oWs:BAIXARXMLDOCUMENTOS()
					If Type ("oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET") <> "U"
						If Type ("oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET") == "A"
							aXmlRet := oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET
						Else
							aXmlRet := {oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET}
						EndIf
					EndIf

					Processa({|| lRet := SXSF_022( oRet, aXmlRet, @cAviso ) },"Processando","Aguarde, baixando arquivos",.T.)

				EndIf

			Else

				For nY := 1 to 5
					aAdd(oWs:oWSDOCUMENTOS:oWSDOCUMENTO:oWSBAIXARDOCUMENTO,MANIFESTACAODESTINATARIO_BAIXARDOCUMENTO():New())
					oWs:oWSDOCUMENTOS:oWSDOCUMENTO:oWSBAIXARDOCUMENTO[nY]:CCHAVE := aChaves[nY+nQtdChv]
				Next nY

				nQtdChv := nQtdChv + 5

				If oWs:BAIXARXMLDOCUMENTOS()
					If Type ("oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET") <> "U"
						If Type ("oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET") == "A"
							aXmlRet := oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET
						Else
							aXmlRet := {oWs:OWSBAIXARXMLDOCUMENTOSRESULT:OWSDOCUMENTORET:OWSBAIXARDOCUMENTORET}
						EndIf
					EndIF

					Processa({|| lRet := SXSF_022( oRet, aXmlRet, @cAviso ) },"Processando","Aguarde, baixando arquivos",.T.)

				EndIf
			EndIf
		EndDo

	Else
		Aviso("SPED","Execute o módulo de configuração do serviço, antes de utilizar esta opção!",{"Aviso"},3)
	EndIf

Return( lRet )


//------------------------------------------------------------------
// Função auxiliar para o processamento da exportação do arquivo zip
//------------------------------------------------------------------
Static Function SXSF_022( oRet, aXmlRet, cAviso )

	Local nZ   := 0
	Local lRet := .F.

	ProcRegua( Len( aXmlRet ) )

	For nZ := 1 To Len( aXmlRet )

		IncProc()

		oRet := aXmlRet[nZ]

		If SXSF_023( oRet )
			lRet := .T.
		 	cAviso += SubStr( oRet:CCHAVE, 23, 3 ) +"    "+ SubStr( oRet:CCHAVE, 26, 9 ) + CRLF
		EndIf

	Next

Return(lRet)

//----------------------------------------------------------
// Função que baixa os arquivos conforme o retorno do método
//----------------------------------------------------------
Static Function SXSF_023( oRetorno )

	Local cDestino   := ""
	Local cDrive     := ""
	Local cNfeProt   := ""
	Local cNfe       := ""
	Local cNfeProc   := ""
	Local cChave     := ""
	Local cNfeProtzi := ""
	Local cNfeZip    := ""
	Local cNfeProcZi := ""
	Local lRet       := .F.
	Local nHandle    := 0
	Local nLen       := 0
	Local cUn        := ""
	Local lDecGz     := .F.

	oRet := oRetorno
	cDestino := SuperGetMv("SOL_XML003",.F.,"\system\gestorxml\")

	If Type("oRet:CCHAVE") <> "U" .and. !Empty( oRet:CCHAVE )
		cChave := oRet:CCHAVE
	EndIf

	//140: Download disponibilizado - 656:Consumo indevido
	//If Type("oRet:CCHVSTATUS") <> "U" .And. ( !Empty( oRet:CCHVSTATUS ) .And. ( '140' $ oRet:CCHVSTATUS .Or. '656' $ oRet:CCHVSTATUS ) )
		If Type("oRet:CNFEPROTZIP") <> "U" .And. !Empty( oRet:CNFEPROTZIP )
			cNfeProtZi := oRet:CNFEPROTZIP
		EndIf
		If Type("oRet:CNFEZIP") <> "U" .And. !Empty( oRet:CNFEZIP )
			cNfeZip := oRet:CNFEZIP
		EndIf
		If Type("oRet:CNFEPROCZIP") <> "U" .And. !Empty( oRet:CNFEPROCZIP )
			cNfeProcZi := oRet:CNFEPROCZIP
		EndIf
	//EndIf

	If !Empty( cChave )

		If !Empty( cNfeProtZi ) .And. !'<protNFe' $ cNfeProtZi
			nLen := Len( cNfeProtZi )
			lDecGz := GzStrDecomp( cNfeProtZi, nLen, @cUn )
			If lDecGz
				cNfeProt := cUn
				cNomFile := cDestino + cChave +"-protNFe.xml"
				If !File( cNomFile )
					nHandle  := FCreate( cNomFile )
					If nHandle > 0
						FWrite( nHandle, cNfeProt )
						FClose( nHandle )
						lRet := .T.
					EndIf
				Endif
			EndIf
		ElseIf !Empty( cNfeProtZi ) .And. '<protNFe' $ cNfeProtZi
			cNomFile := cDestino + cChave +"-protNFe.xml"
			If !File( cNomFile )
				nHandle := FCreate( cNomFile )
				If nHandle > 0
					FWrite( nHandle, cNfeProtZi )
					FClose( nHandle )
					lRet := .T.
				EndIf
			EndIf
		EndIf

		If !Empty(cNfeZip) .And. !'<NFe' $ cNfeZip
			nLen := Len( cNfeZip )
			lDecGz := GzStrDecomp( cNfeZip, nLen, @cUn )
			If lDecGz
				cNfe := cUn
				cNomFile := cDestino + cChave +"-xmlNFe.xml"
				If !File( cNomFile )
					nHandle  := FCreate( cNomFile )
					If nHandle > 0
						FWrite( nHandle, cNfe )
						FClose( nHandle )
						lRet := .T.
					EndIf
				EndIf
			EndIf
		ElseIf !Empty(cNfeZip) .And. '<NFe' $ cNfeZip
			cNomFile := cDestino + cChave +"-xmlNFe.xml"
			If !File( cNomFile )
				nHandle := FCreate( cNomFile )
				If nHandle > 0
					FWrite( nHandle, cNfeZip )
					FClose( nHandle )
					lRet := .T.
				EndIf
			EndIf
		EndIf

		If !Empty( cNfeProcZi ) .And. !'<nfeProc' $ cNfeProcZi
			nLen := Len( cNfeProcZi )
			lDecGz := GzStrDecomp( cNfeProcZi, nLen, @cUn )
			If lDecGz
				cNfeProc := cUn
				cNomFile := cDestino + cChave +"-procNFe.xml"
				If !File( cNomFile )
					nHandle  := FCreate( cNomFile )
					If nHandle > 0
						FWrite( nHandle, cNfeProc )
						FClose( nHandle )
						lRet := .T.
					EndIf
				EndIf
			EndIf
		ElseIf !Empty( cNfeProcZi ) .And. '<nfeProc' $ cNfeProcZi
			cNfeProc := cDestino+cChave+"-"+"procNFe.xml"
			If !File( cNfeProc )
				nHandle  := FCreate( cNfeProc )
				If nHandle > 0
					FWrite ( nHandle, cNfeProcZi)
					FClose(nHandle)
					lRet	:= .T.
				EndIf
			EndIf
		EndIf

		If lRet
			cSql := "UPDATE "+ RetSqlName("C00") +" SET C00_XMLOK = '1' WHERE C00_CHVNFE = '"+ cChave +"' AND D_E_L_E_T_ = ' ' "
			TcSqlExec( cSql )
		Else
			cNfeProc := ""
		EndIf

	EndIf

Return lRet

//--------------------------------------------------------------------------------------------
// Faz a leitura do diretório de trabalho do XML e importa as informações para a base de dados
//--------------------------------------------------------------------------------------------
User Function SXUF_009( cDir, lRegua )

	Local _cDir    := Iif( !Empty( cDir ),cDir,"\system\gestorxml\" + AllTrim(SM0->M0_CGC) + "\")
	Local _n       := 0
	Local cXMLPath := ""
	Local _cErr    := ""
	Local _cWrn    := ""
	Local aXML     := {}
	Local _lOk     := .T.
	Local nStFile  := 0

	Private _oXml   := Nil
	Private cBuffer := ""

	Default lRegua := .T.

	aXML := DIRECTORY( _cDir + "*.XML" )

	If lRegua
		oProcReg:SetRegua1( Len( aXML ) )
	EndIf

	For _n := 1 To Len( aXML )

		If lRegua
			oProcReg:IncRegua1("Processando arquivo "+ cValToChar( _n ) +" de "+ cValToChar( Len( aXML ) ) )
		EndIf

		cXMLPath := _cDir + aXML[ _n, 1 ]
		_lOk     := .F.
		nStFile  := 0

		If File( Alltrim( cXMLPath ) )

			_oXml := Nil

			// Cria o objeto XML
			_aObjXml := SXSF_025( Alltrim( cXMLPath ) )

			If Len( _aObjXml ) > 0
				_cErr := _aObjXml[ 1 ]
				_cWrn := _aObjXml[ 2 ]
			EndIf

			If _oXml != Nil
				If Type("_oXml:_NFEPROC") == "U" .And. Type("_oXml:_CTEPROC") == "U" .And. Type("_oXml:_CTEOSPROC") == "U"
					// Formato de XML inválido!
					cLog += CXMLPATH + " | Formato de XML inválido" + CHR(13) + CHR(10)
				Else
					If ( Type("_oXml:_NFEPROC") != "U" .And. !(_oXml:_NFEPROC:_VERSAO:TEXT $ "3.10/4.00") ) .Or. ( Type("_oXml:_CTEPROC") != "U" .And. !(_oXml:_CTEPROC:_VERSAO:TEXT $ "3.00/2.00") ) .Or. ( Type("_oXml:_CTEOSPROC") != "U" .And. !(_oXml:_CTEOSPROC:_VERSAO:TEXT $ "3.00/2.00") )
						cLog += CXMLPATH + " | Versão de documento não suportada: "+ Iif( Type("_oXml:_NFEPROC") != "U",_oXml:_NFEPROC:_VERSAO:TEXT, Iif( Type("_oXml:_CTEPROC") != "U", _oXml:_CTEPROC:_VERSAO:TEXT, Iif( Type("_oXml:_CTEOSPROC") != "U", _oXml:_CTEOSPROC:_VERSAO:TEXT, "" ) ) ) + CHR(13) + CHR(10)
						Loop
					EndIf

					// Processa as informações do XML
					If Type("_oXml:_NFEPROC") != "U"
						_lOk := SXSF_026("NFE",_oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT)
					ElseIf Type("_oXml:_CTEPROC") != "U"
						_lOk := SXSF_026("CTE",_oXml:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT)
					ElseIf Type("_oXml:_CTEOSPROC") != "U"
						_lOk := SXSF_026("CTE",_oXml:_CTEOSPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT)
					EndIf
				EndIf
			Else
				cLog += CXMLPATH + " | Ocorreu um erro ao tentar carregar o arquivo" + CHR(13) + CHR(10)
			EndIf

		EndIf

		If _lOk
			If !File( _cDir +"importados\"+ aXML[ _n, 1 ] )
				nStFile := frename( cXMLPath, _cDir +"importados\"+ aXML[ _n, 1 ] )
				If nStFile == -1
					cLog += CXMLPATH + " | Ocorreu uma falha ao tentar mover o arquivo para a pasta de xml importados" + CHR(13) + CHR(10)
				Endif
			Else
				FErase( cXMLPath )
			EndIf
		Else
			If !File( _cDir +"problemas\"+ aXML[ _n, 1 ] )
				nStFile := frename( cXMLPath, _cDir +"problemas\"+ aXML[ _n, 1 ] )
				If nStFile == -1
					cLog += CXMLPATH + " | Ocorreu uma falha ao tentar mover o arquivo para a pasta de xml com problemas" + CHR(13) + CHR(10)
				Endif
			Else
				FErase( cXMLPath )
			EndIf
		EndIf

	Next

	If !Empty( cLog )
		MemoWrite( cWorkDir + AllTrim(SM0->M0_CGC) + "\log\"+Dtos(dDataBase)+StrTran(Time(),":","")+".txt", cLog )
		cLog := ""
	EndIf

Return()

//--------------------------------------------------------------------
// Função que analisa o conteúdo do xml e direciona para as validações
//--------------------------------------------------------------------
Static Function SXSF_026( cTipo, cChvXml )

	Local cCodRet := ""
	Local _lRet   := .F.
	//Local cIdEnt  := SXSF_012() // Retorna o código da Entidade no TSS

	If cTipo == "CTE"
		cCodRet := "100" /* Na importação do CTe não será preciso */ //SXSF_011( cChvXml, cIdEnt, .T. ) // Retorna situação no Sefaz
	ElseIf cTipo == "NFE"
		cCodRet := SXSF_055( cChvXml, .F. ) // Verifica se nota está disponível
    EndIf

	If cCodRet $ "100/101"

		If cTipo == "NFE"
			_lRet := SXSF_027( cCodRet )
		ElseIf cTipo == "CTE"
			_lRet := SXSF_028( cCodRet )
		EndIf

	Else
		cLog += cTipo + "-"+ cChvXml + " | Documento não localizado no SEFAZ" + CHR(13) + CHR(10)
	EndIf

Return( _lRet )

//------------------------------------------
// Função que valida o documento fiscal NF-e
//------------------------------------------
Static Function SXSF_027( cCodRet )

	Local cQtdEnt    := 0
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
	Local cIdDest    := ""
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
	Local lOkEnt     := .T.
	Local lPnOk      := .F.
	Local lNfOk      := .F.
	Local lCfopRet   := .F.
	Local lCfopCli   := .F.
	Local lIncEnt    := lCadFImp
	Local cValPro    := cValProd
	Local cValPed    := cPedComp
	Local lUsaLote   := ( cUsaLote == "S" )
	Local aProds     := {}
	Local aCFOPItm   := {}
	Local aItemRet   := {}
	Local aRetOrig   := {}
	Local dDtEmi     := CtoD("//")
	Local aSitTrib   := {"00","10","20","30","40","41","45","50","51","60","70","90"}

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
		Return( .F. )
	EndIf

	// Verificar o CNPJ do destinatário
	dbSelectArea("SM0")
	If SM0->M0_CGC != Iif( Type("oDestino:_CNPJ") == "U", oDestino:_CPF:TEXT, oDestino:_CNPJ:TEXT )
		cLog += cChvLog + " | CNPJ do destinatário diferente de "+ SM0->M0_CGC + CHR(13) + CHR(10)
		Return( .F. )
	EndIf

	// Verifica se é uma nota de saída (uma nota de saída emitida no sistema não precisa ser importada e uma nota de entrada de outras
	// empresas não deve ser importada).
	If Type("oIdent:_TPNF:TEXT") == "U"
		cLog += cChvLog + " | Tag TPNF inexistente" + CHR(13) + CHR(10)
		Return( .F. )
	Else
		If oIdent:_TPNF:TEXT == "0"
			cLog += cChvLog + " | Documento não é uma nota de saída" + CHR(13) + CHR(10)
			Return( .F. )
		EndIf
	EndIf

	// Procuro também pela chave da nfe caso esteja com formato numerico diferente do numero na SF1
	cQuery := "SELECT COUNT(*) AS TOT, F1_STATUS FROM " + RetSqlName("SF1")
	cQuery += " WHERE F1_CHVNFE  = '"+ oProtNfe:_CHNFE:TEXT +"'"
	cQuery += " AND D_E_L_E_T_ = ' ' "
	cQuery += "GROUP BY F1_STATUS"

	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
	cQtdNF     := (cAlias)->TOT
	cF1_STATUS := (cAlias)->F1_STATUS
	(cAlias)->( DbCloseArea() )

    // Também pesquiso pela chave na tabela de XML
	cQuery := "SELECT COUNT(*) AS TOT FROM " + RetSqlName("ZX1")
	cQuery += " WHERE ZX1_CHVNFE  = '"+ oProtNfe:_CHNFE:TEXT +"'"
	cQuery += " AND ZX1_STATUS NOT IN ('5') " // Status 5 e 6 = Resumo NFE
	cQuery += " AND D_E_L_E_T_ = ' ' "

	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
	cQtdXml := (cAlias)->TOT
	(cAlias)->( DbCloseArea() )

	If cQtdXml > 0
		cLog += cChvLog + " | XML já foi importado " + CHR(13) + CHR(10)
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
			Return(.F.)
		EndIf

	EndIf

	// Verificar se existe o fornecedor ou o cliente cadastrado, através do CNPJ.
	If cTipoNf $ "CN"
		cQuery := "SELECT A2_COD, A2_LOJA, A2_NOME FROM "+ RetSqlName("SA2") +" WHERE A2_CGC = '"+ oEmitente:_CNPJ:TEXT +"' AND D_E_L_E_T_ = ' ' "
	Else
		cQuery := "SELECT A1_COD, A1_LOJA, A1_NOME FROM "+ RetSqlName("SA1") +" WHERE A1_CGC = '"+ oEmitente:_CNPJ:TEXT +"' AND D_E_L_E_T_ = ' ' "
	EndIf

	aAreaTmp := GetArea()
	If cTipoNf $ "CN"
		dbSelectArea("SA2")
		If FieldPos("A2_MSBLQL") > 0
			cQuery +=" AND A2_MSBLQL <> '1'"
		EndIf
	Else
		dbSelectArea("SA1")
		If FieldPos("A1_MSBLQL") > 0
			cQuery +=" AND A1_MSBLQL <> '1'"
		EndIf
	EndIf
	RestArea( aAreaTmp )

	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )

	While !(cAlias)->( Eof() )
		cQtdEnt++
		(cAlias)->( dbSkip() )
	End
	(cAlias)->( dbGoTop() )

	If cQtdEnt == 0
		If lIncEnt
			If cTipoNf $ "CN"
				lOkEnt := SXSF_038("F")
			Else
				lOkEnt := SXSF_038("C")
			EndIf

			If !lOkEnt
				cLog += cChvLog + " | Cliente ou forncedor não foi cadastrado (2)" + CHR(13) + CHR(10)
				Return .F.
			EndIf
		Else
			cLog += cChvLog + " | Cliente ou fornecedor não cadastrado (1)" + CHR(13) + CHR(10)
			Return .F.
		Endif
	EndIf

	// Caso tenha mesmo CNPJ mais de uma vez no cadastro, selecionar qual fornecedor/cliente
	If cQtdEnt > 1
		aRetEnt := SXSF_029( oEmitente:_CNPJ:TEXT, cAlias, cTipoNf )
	Else
		If cTipoNf $ "CN"
			dbSelectArea("SA2")
			// Jorge Alberto - Solutio - 18/05/2020 - Alterada a consulta para que posicione conforme o Alias.
			//dbSetOrder(3)
			//If dbSeek( xFilial("SA2") + oEmitente:_CNPJ:TEXT )
			dbSetOrder(1)
			If dbSeek( xFilial( "SA2") +  (cAlias)->A2_COD + (cAlias)->A2_LOJA )
				aRetEnt := { { A2_COD, A2_LOJA } }
			Else
				cLog += cChvLog + " | Fornecedor não cadastrado (3)" + CHR(13) + CHR(10)
				Return( .F. )
			EndIf
		Else
			dbSelectArea("SA1")
			dbSetOrder(3)
			If dbSeek( xFilial("SA1") + oEmitente:_CNPJ:TEXT )
				aRetEnt := { { A1_COD, A1_LOJA } }
			Else
				cLog += cChvLog + " | Cliente não cadastrado (3)" + CHR(13) + CHR(10)
				Return( .F. )
			EndIf
		EndIf
	EndIf

	// Verifica se existe algum valor no array
	If Empty( aRetEnt[ 1 ][ 1 ] )
		cLog += cChvLog + " | Cliente ou fornecedor não cadastrado (4)" + CHR(13) + CHR(10)
		Return( .F. )
	EndIf

	If Select( cAlias ) > 0
		(cAlias)->( DbCloseArea() )
	EndIf

	// Já com o código de cliente ou fornecedor definido, avalio os itens de retorno ou devolução
	If lCfopRet // Existe nos itens pelo menos um com CFOP de retorno
		If Len( aNfRef ) > 0 // Tenho que avaliar se no XML existe nota referenciada por ser retorno
			aRetRes := SXSF_050( aNfRef, aItemRet, aDet ) // Faz as devidas amarrações com a nota original
		Else
			cLog += cChvLog + " | Existe nos itens pelo menos um com CFOP de retorno e sem nota referenciada" + CHR(13) + CHR(10)
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

	/*
	// Pesquisa na tabela de notas de entrada
	cQuery := "SELECT COUNT(F1_FILIAL) AS TOT FROM " + RetSqlName("SF1")
	cQuery += " WHERE F1_FILIAL  = '"+ xFilial("SF1") +"'"
	cQuery += " AND F1_DOC       = '"+ cNf +"'"
	cQuery += " AND F1_SERIE     = '"+ cSerie +"'"
	cQuery += " AND F1_FORNECE   = '"+ aRetEnt[ 1 ][ 1 ] +"'"
	cQuery += " AND F1_LOJA      = '"+ aRetEnt[ 1 ][ 2 ] +"'"
	cQuery += " AND D_E_L_E_T_ = ' ' "

	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
	cQtdNF := (cAlias)->TOT
	(cAlias)->( DbCloseArea() )

	If cQtdNF > 0
		cLog += cChvLog + " | Nota já cadastrada no sistema (SF1)" + CHR(13) + CHR(10)
		Return( .F. )
	EndIf
	*/

	// Pesquisa na tabela de XML
	cQuery := "SELECT COUNT(*) AS TOT FROM " + RetSqlName("ZX1")
	cQuery += " WHERE ZX1_FILIAL = '"+ xFilial("ZX1") +"'"
	cQuery += " AND ZX1_DOC      = '"+ cNf +"'"
	cQuery += " AND ZX1_SERIE    = '"+ cSerie +"'"
	cQuery += " AND ZX1_CLIFOR   = '"+ aRetEnt[ 1 ][ 1 ] +"'"
	cQuery += " AND ZX1_LOJA     = '"+ aRetEnt[ 1 ][ 2 ] +"'"
	cQuery += " AND D_E_L_E_T_ = ' ' "

	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
	cQtdNF := (cAlias)->TOT
	(cAlias)->( DbCloseArea() )

	If cQtdNF > 0
		cLog += cChvLog + " | Nota já cadastrada no sistema (ZX1)" + CHR(13) + CHR(10)
		Return( .F. )
	EndIf

	// Verificando os itens
	If ValType( aDet ) != "A"
		cLog += cChvLog + " | Documento sem itens identificados (1)" + CHR(13) + CHR(10)
		Return( .F. )
	Else
		If Len( aDet ) == 0
			cLog += cChvLog + " | Documento sem itens identificados (2)" + CHR(13) + CHR(10)
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

			If ( cTipoNf $ "CN" .And. SA5->( dbSeek( xFilial("SA5") + aRetEnt[ 1 ][ 1 ] + aRetEnt[ 1 ][ 2 ] + cCodPrf ) ) ) .Or. ( cTipoNf $ "D" .And. SA7->( dbSeek( xFilial("SA7") + aRetEnt[ 1 ][ 1 ] + aRetEnt[ 1 ][ 2 ] + cCodPrf ) ) )
				// Usa o código cadastrado na tabela SA5/SA7
				cCodProd := Iif( cTipoNf $ "CN", SA5->A5_PRODUTO, SA7->A7_PRODUTO )
			Else
				// Incluir item no cadastro Produto x Fornecedor (SA5) / Cliente (SA7)
				If cValPro == "I" // Valida na Importação
					cCodProd := SXSF_030( cCodPrf, cDescPrf, .F., cTipoNf )
				EndIf
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
					EndIf
				EndIf

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
					RecLock("ZX2",.T.)
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
				RecLock("ZX2",.T.)
					ZX2->ZX2_FILIAL := xFilial("ZX2")
					ZX2->ZX2_ITEM   := StrZero( Val( oProd:_NITEM:TEXT ), 4 )
					ZX2->ZX2_COD    := cCodProd
					ZX2->ZX2_CODFOR := cCodPrf
					ZX2->ZX2_DESCF  := Iif( Empty( cCodProd ), aProds[ _nPos, 3 ], SB1->B1_DESC )

					If !Empty( cCodProd ) .And. !Empty( SB1->B1_SEGUM ) .And. SB1->B1_CONV > 0
						ZX2->ZX2_QUANT  := ConvUm( cCodProd, 0, Val( oProd:_PROD:_QTRIB:TEXT  ), 1 )
						ZX2->ZX2_VUNIT  := Round( Val( oProd:_PROD:_VUNCOM:TEXT ) / ConvUm( cCodProd, 0, Val( oProd:_PROD:_QTRIB:TEXT  ), 1 ), TamSX3("ZX2_VUNIT")[2] )
					Else
						ZX2->ZX2_QUANT  := Val( oProd:_PROD:_QTRIB:TEXT  )
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

		// Gravar ZX1
		dbSelectArea("ZX1")
		RecLock("ZX1",.T.)
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
			ZX1->ZX1_STATUS := Iif( cCodRet == "101", "9", Iif( lNfOk, "2", Iif( lPnOk, "1", Iif( nItNoPrd > 0, "3", "0" ) ) ) )
			ZX1->ZX1_CHVNFE := oProtNfe:_CHNFE:TEXT
			ZX1->ZX1_XML    := cBuffer
			ZX1->ZX1_DTIMP  := dDataBase
			ZX1->ZX1_XMLAUT := cInfAdic
		ZX1->( MsUnLock() )

	End Transaction

	// Verifica se valida a inserção de pedido de compra na importação
	If cTipoNf $ "N" .And. cValPed == "I"
		U_SXUF_013()
	EndIf

Return( .T. )


//------------------------------------------------------------------------------------------------------
// Função para inclusão do produto no cadastro SA5 - Produto x Fornecedor ou SA7 - Produto x Cliente
//------------------------------------------------------------------------------------------------------
Static Function SXSF_030( cProdFor, cDescFor, lMenu, cTpNf )

	Local cCodFor   := cProdFor
	Local cNomFor   := cDescFor
	Local cCodPro   := Space( TamSX3("B1_COD")[ 1 ] )
	Local _lRetorno := .F.
	Local aRet      := {}
	Local _nOpca    := 0
	Local _nLin     := 24
	Local cForn     := Iif( lMenu, ZX1->ZX1_CLIFOR, aRetEnt[ 1 ][ 1 ] )
	Local cLoja     := Iif( lMenu, ZX1->ZX1_LOJA  , aRetEnt[ 1 ][ 2 ] )
	Local cTipoNf   := cTpNf
	Local bOk       := { || _nOpca := 1, aRet := SXSF_031( cCodPro, cCodFor, cForn, cLoja, cTipoNf ), _lRetorno := aRet[1].Or.aRet[2], oDlgSA5:End() }
	Local bCancel   := { || cCodPro := "", oDlgSA5:End() }
	Local oGet1
	Local oGet2
	Local oGet3

	Private oGet4
	Private cNomPro := Space( TamSX3("B1_DESC")[ 1 ] )

	Private oDlgSA5

	Define MsDialog oDlgSA5 Title "Cadastro Produto X "+ Iif( cTipoNf $ "CN", "Fornecedor", "Cliente" ) From 178,181 To 475,695 Pixel

		@011+_nLin,002 TO 064+_nLin,250 LABEL "[ Produto do "+ Iif( cTipoNf $ 'CN', 'Fornecedor', 'Cliente' ) +" ]" Pixel Of oDlgSA5
		@070+_nLin,002 TO 122+_nLin,250 LABEL "[     Nosso Produto     ]" COLOR CLR_BLUE Pixel Of oDlgSA5

		@021+_nLin,006 Say "Codigo do Produto"          Size 060,008 COLOR CLR_BLACK Pixel Of oDlgSA5
		@029+_nLin,006 MsGet oGet1 Var cCodFor When .F. Size 100,009 COLOR CLR_BLUE Picture "@!" Pixel Of oDlgSA5
		@042+_nLin,006 Say "Descrição do Produto"       Size 070,008 COLOR CLR_BLACK Pixel Of oDlgSA5
		@050+_nLin,006 MsGet oGet2 Var cNomFor When .F. Size 240,009 COLOR CLR_BLUE Picture "@!" Pixel Of oDlgSA5

		@079+_nLin,006 Say "Código do Produto" Size 060,008 COLOR CLR_BLUE Pixel Of oDlgSA5
		@087+_nLin,006 MsGet oGet3 Var cCodPro Size 100,009 COLOR CLR_BLUE Picture "@!" Pixel Of oDlgSA5 F3("SB1") Valid( ExistCpo( "SB1", cCodPro ) ) On Change ( cNomPro := Posicione("SB1", 1, xFilial("SB1") + cCodPro, "B1_DESC"), oGet4:Refresh() )
		@100+_nLin,006 Say "Descrição Produto" Size 060,008 COLOR CLR_BLUE Pixel Of oDlgSA5
		@108+_nLin,006 MsGet oGet4 Var cNomPro When .F. Size 240,009 COLOR CLR_BLUE Picture "@!" Pixel Of oDlgSA5

	Activate MsDialog oDlgSA5 On Init ( EnchoiceBar( oDlgSA5, bOk, bCancel,, ) ) Centered Valid _lRetorno

	If _nOpca == 1 .And. aRet[1]
		If cTipoNf $ "CN"
			dbSelectArea("SA5")
			RecLock( "SA5", .T. )
				A5_FILIAL  := xFilial("SA5")
				A5_FORNECE := cForn
				A5_LOJA    := cLoja
				A5_NOMEFOR := Posicione("SA2", 1, xFilial("SA2") + cForn + cLoja, "A2_NREDUZ")
				A5_PRODUTO := cCodPro
				A5_NOMPROD := cNomPro
				A5_CODPRF  := cCodFor
			MsUnLock()
		Else
			dbSelectArea("SA7")
			RecLock( "SA7", .T. )
				A7_FILIAL  := xFilial("SA7")
				A7_CLIENTE := cForn
				A7_LOJA    := cLoja
				A7_PRODUTO := cCodPro
				A7_DESCCLI := cNomPro
				A7_CODCLI  := cCodFor
			MsUnLock()
		EndIf
	EndIf

Return( cCodPro )

//---------------------------------------------------------------------------------------
// Valida o produto selecionado no cadastro do Produto x Fornecedor ou Produto x Cliente
//---------------------------------------------------------------------------------------
Static Function SXSF_031( cCodPro, cProFor, cForn, cLoja, cTipNf )

	Local _lInclui := .T.
	Local _lAltera := .F.
	Local _cCodEnt := ""
	Local _cAlias  := Iif( cTipNf $ "CN", "SA5", "SA7" )

	dbSelectArea(_cAlias)
	dbSetOrder(1)
	If !( (_cAlias)->( dbSeek( xFilial(_cAlias) + cForn + cLoja + cCodPro ) ) )
		_lInclui := .T.
	Else
		_lInclui := .F.
		_cCodEnt := Iif( cTipNf $ "CN", SA5->A5_CODPRF, SA7->A7_CODCLI )
		If Empty( _cCodEnt )
			_lAltera := .T.
			RecLock(_cAlias,.F.)
				If cTipNf $ "CN"
					SA5->A5_CODPRF := cProFor
				Else
					SA7->A7_CODCLI := cProFor
				EndIf
			MsUnLock()
			Aviso( "Atenção", "Este produto já foi utilizado para este "+ Iif( cTipNf $ "CN", "fornecedor", "cliente" ) +", mas o código do produto do "+ Iif( cTipNf $ "CN", "fornecedor", "cliente" ) +" estava em branco e foi atualizado.", { "Ok" } )

		ElseIf !Empty( _cCodEnt ) .And. AllTrim( cProFor ) != AllTrim( _cCodEnt )

			Aviso( "Atenção", "Este produto já foi utilizado para este "+ Iif( cTipNf $ "CN", "fornecedor", "cliente" ) +" com o código "+ AllTrim( _cCodEnt ) +".", { "Ok" } )
			_lInclui := .F.
			_lAltera := .F.
		Else
			_lAltera := .T.
		EndIf
	EndIf

Return( { _lInclui, _lAltera } )


//-----------------------------------------------------------------
// Selecionar o cliente ou fornecedor quando cnpj estiver duplicado
//-----------------------------------------------------------------
Static Function SXSF_029( cCNPJ, cAlias, cTpNF )

	Local _lRetorno := .F.
	Local _nOpca    := 0
	Local bOk       := {|| _nOpca:=1, _lRetorno := SXSF_036(), oDlgF:End() }
	Local bCancel   := {|| _nOpca:=0, oDlgF:End() }
	Local _cArqEmp  := ""  //Arquivo temporário com os fornecedores/clientes
	Local _aStruTrb := {}  //Estrutura do temporario
	Local _aBrowse  := {}  //Array do Browse para seleção dos fornecedores/clientes
	Local aRetEnt   := {}  //Array de retorno com o fornecedor/cliente escolhido

	Private lInverte := .F. //Variaveis para o MsSelect
	Private cMarca   := ""  //Variaveis para o MsSelect
	Private oBrwTrb         //Objeto do MsSelect
	Private oDlgF
	Private _cTRB	 := GetNextAlias() //Alias Tabela Temporária

	If cTpNf $ "CN"

		aAdd( _aStruTrb, { "A2_COD" , "C", TamSX3("A2_COD" )[1] , 0} )
		aAdd( _aStruTrb, { "A2_LOJA", "C", TamSX3("A2_LOJA")[1] , 0} )
		aAdd( _aStruTrb, { "A2_NOME", "C", TamSX3("A2_NOME")[1] , 0} )
		aAdd( _aStruTrb, { "A2_OK"  , "C", 02, 0 } )

		aAdd( _aBrowse, { "A2_OK"  , "", ""      } )
		aAdd( _aBrowse, { "A2_COD" , "", "Código"} )
		aAdd( _aBrowse, { "A2_LOJA", "", "Loja  "} )
		aAdd( _aBrowse, { "A2_NOME", "", "Nome  "} )

	Else
		aAdd( _aStruTrb, { "A1_COD" , "C", TamSX3("A1_COD" )[1] , 0} )
		aAdd( _aStruTrb, { "A1_LOJA", "C", TamSX3("A1_LOJA")[1] , 0} )
		aAdd( _aStruTrb, { "A1_NOME", "C", TamSX3("A1_NOME")[1] , 0} )
		aAdd( _aStruTrb, { "A1_OK"  , "C", 02, 0 } )

		aAdd( _aBrowse, { "A1_OK"  , "", ""      } )
		aAdd( _aBrowse, { "A1_COD" , "", "Código"} )
		aAdd( _aBrowse, { "A1_LOJA", "", "Loja  "} )
		aAdd( _aBrowse, { "A1_NOME", "", "Nome  "} )

	EndIf

	//If Select("TRBENT") > 0
		//TRBENT->( DbCloseArea() )
	//Endif

	//_cArqEmp := CriaTrab( _aStruTrb )
	//dbUseArea( .T., __LocalDriver, _cArqEmp, "TRBENT" )

	///////////////////////
	oTempTable := FWTemporaryTable():New( _cTRB, _aStruTrb  )
    oTempTable:AddIndex("01", {_aStruTrb[1][1]} )
	oTempTable:Create()

	While (cAlias)->( !Eof() )

		//RecLock("TRBENT",.T.)
		(_cTRB)->(DBAppend())

			If cTpNf $ "CN"
				(_cTRB)->A2_OK   := " " //TRBENT->A2_OK   := " "
				(_cTRB)->A2_COD  := (cAlias)->A2_COD
				(_cTRB)->A2_LOJA := (cAlias)->A2_LOJA
				(_cTRB)->A2_NOME := (cAlias)->A2_NOME
			Else
				(_cTRB)->A1_OK   := " "
				(_cTRB)->A1_COD  := (cAlias)->A1_COD
				(_cTRB)->A1_LOJA := (cAlias)->A1_LOJA
				(_cTRB)->A1_NOME := (cAlias)->A1_NOME
			EndIf

		(_cTRB)->(DBCommit())

		( cAlias )->( dbSkip() )

	Enddo

	cMarca := GetMark( .F., _cTRB, Iif( cTpNf $ "CN", "A2_OK", "A1_OK" ) ) // Define a marca para o campo
	cEnt   := Iif( cTpNf $ "CN", "Fornecedor", "Cliente" )

	Define MsDialog oDlgF Title cEnt +" com o mesmo CNPJ: "+ Transform( cCNPJ, PesqPict("SA2","A2_CGC") ) From C(001),C(001) To C(300),C(600) Pixel

		@ 2.5,002 SAY OemToAnsi("Selecione o "+ cEnt +" que deseja utilizar")
		oBrwTrb := MsSelect():New(_cTRB,Iif( cTpNf $ "CN", "A2_OK", "A1_OK" ),"",_aBrowse,@lInverte,@cMarca,{042,001,190,380})
		oBrwTrb:bMark := { || SXSF_035( cMarca ) }
		Eval(oBrwTrb:oBrowse:bGoTop)
		oBrwTrb:oBrowse:Refresh()

	Activate MsDialog oDlgF On Init ( EnchoiceBar( oDlgF, bOk, bCancel,,) ) Centered Valid _lRetorno

	(_cTRB)->(dbGoTop()) //TRBENT->( DbGotop() )

	If _nOpca == 1

		//dbSelectArea("TRBENT")
		//dbGoTop()
		dbSelectArea(_cTRB)
		(_cTRB)->(dbGoTop())
		Do While (_cTRB)->( !Eof() ) //TRBENT->( !Eof() )

			If cTpNf $ "CN"
				If !Empty( (_cTRB)->A2_OK )//se usuario marcou o registro
					aAdd( aRetEnt, { (_cTRB)->A2_COD, (_cTRB)->A2_LOJA } )
				EndIf
			Else
				If !Empty( (_cTRB)->A1_OK )//se usuario marcou o registro
					aAdd( aRetEnt, { (_cTRB)->A1_COD, (_cTRB)->A1_LOJA } )
				EndIf
			EndIf

			(_cTRB)->( DbSkip() )

		EndDo

	Else
		aAdd( aRetEnt, { "", "" } )
	Endif

	/*If Select("TRBENT") > 0
		DbSelectArea("TRBENT")
		DbCloseArea()
		Ferase( _cArqEmp + OrdBagExt() )
	Endif*/

	If (Select(_cTRB) > 0)
		oTempTable:Delete()
	EndIf


Return( aRetEnt )


//------------------------------------------
// Função que valida o documento fiscal CT-e
//------------------------------------------
Static Function SXSF_028( cCodRet )

	Local cCST    := ""
	Local cTpAmb  := ""
	Local cToma   := ""
	Local cCnpjT  := ""
	Local cCt     := ""
	Local cSerie  := ""
	Local cUf     := ""
	Local cCodEnt := ""
	Local cLojEnt := ""
	Local cQtdEnt := 0
	Local nBaseICM:= 0
	Local nValICM := 0
	Local nPICM   := 0
	Local nBaseICMST := 0
	Local nValICMST  := 0
	Local nPICMST := 0
	Local nVTPrest:= 0
	Local lNfOk   := .F.
	Local aRetEnt := {}
	Local aNfRef  := {}
	Local aTipos  := {}
	Local cQuery  := ""
	Local cAlias  := ""
	Local _cNfRef := "("
	Local cTiposFor := "NC"
	Local cTiposCli := "BD"
	Local lTpCli    := .F.
	Local lTpFor    := .F.
	Local dDtEmi    := CtoD("//")
	Local aDadosCli := Array(2)
	Local aDadosFor := Array(2)
	Local aSitTrib  := {"00","20","45","60","90"}
	Local cChvLog    := ""
	Local lIncEnt   := lCadFImp
	Local nTamSer    := 0

	aDadosCli[1] := CriaVar("A1_COD",.F.)
	aDadosCli[2] := CriaVar("A1_LOJA",.F.)

	aDadosFor[1] := CriaVar("A2_COD",.F.)
	aDadosFor[2] := CriaVar("A2_LOJA",.F.)

	oNF       := Iif( Type("_oXml:_CTEOSPROC") != "U", _oXml:_CTEOSPROC:_CTEOS, _oXml:_CTEPROC:_CTE )
	oIdent    := oNF:_INFCTE:_IDE
	oEmitente := oNF:_INFCTE:_EMIT
	oRemet    := Iif( Type("oNF:_INFCTE:_REM") == "U", Nil, oNF:_INFCTE:_REM )
	oDestino  := Iif( Type("oNF:_INFCTE:_DEST") == "U", Nil, oNF:_INFCTE:_DEST )
	oExped    := Iif( Type("oNF:_INFCTE:_EXPED") == "U", Nil, oNF:_INFCTE:_EXPED )
	oReceb    := Iif( Type("oNF:_INFCTE:_RECEB") == "U", Nil, oNF:_INFCTE:_RECEB )
	oVPrest   := Iif( Type("oNF:_INFCTE:_VPREST") == "U", Nil, oNF:_INFCTE:_VPREST )
	oCompl    := Iif( Type("oNF:_INFCTE:_COMPL") == "U", Nil, oNF:_INFCTE:_COMPL )
	oImposto  := Iif( Type("oNF:_INFCTE:_IMP") == "U", Nil, oNF:_INFCTE:_IMP )
	oInfNorma := Iif( Type("oNF:_INFCTE:_INFCTENORM") == "U", Nil, oNF:_INFCTE:_INFCTENORM )
	oInfCompl := Iif( Type("oNF:_INFCTE:_INFCTECOMP") == "U", Nil, oNF:_INFCTE:_INFCTECOMP )
	oNfRef := Iif( Type("oInfNorma:_INFDOC") == "U", Nil, oInfNorma:_INFDOC )
	oProtNfe  := Iif( Type("_oXml:_CTEOSPROC") != "U", _oXml:_CTEOSPROC:_PROTCTE:_INFPROT, _oXml:_CTEPROC:_PROTCTE:_INFPROT )
	cChvLog   := oProtNfe:_CHCTE:TEXT
	cUf       := Iif( Type("oEmitente:_ENDEREMIT:_UF") == "U", " ", oEmitente:_ENDEREMIT:_UF:TEXT )

	aNfRef := Iif( oNfRef == Nil, {}, Iif( ValType( oNfRef ) == "O", {oNfRef}, oNfRef ) ) // Notas fiscais referenciadas

	If Len( aNfRef ) == 0
		cLog += cChvLog + " | Nenhum documento referenciado no frete" + CHR(13) + CHR(10)
		Return( .F. )
	EndIf

	dDtEmi  := StoD( StrTran( Left( oIdent:_DHEMI:TEXT, 10 ), "-", "" ) )
	cTpAmb  := oIdent:_TPAMB:TEXT
	cToma   := Iif( Type("oIdent:_TOMA3") == "U", Iif( Type("oIdent:_TOMA4") == "U", "", oIdent:_TOMA4:_TOMA:TEXT ), oIdent:_TOMA3:_TOMA:TEXT )

	// Verificar se a nota foi emitida em ambiente de produção na Sefaz
	If cTpAmb == "2"
		cLog += cChvLog + " | Documento emitido em ambiente de homologação" + CHR(13) + CHR(10)
		Return( .F. )
	EndIf

	// Procuro pela chave da cte no sistema para ver se foi importada anteriormente
	cQuery := "SELECT COUNT(*) AS TOT FROM " + RetSqlName("SF1")
	cQuery += " WHERE F1_CHVNFE  = '"+ oProtNfe:_CHCTE:TEXT +"'"
	cQuery += " AND D_E_L_E_T_ = ' ' "

	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
	cQtdNF := (cAlias)->TOT
	(cAlias)->( DbCloseArea() )

	If cQtdNF > 0
		lNfOk := .T.
	EndIf

    // Também pesquiso pela chave na tabela de XML
	cQuery := "SELECT COUNT(*) AS TOT FROM " + RetSqlName("ZX1")
	cQuery += " WHERE ZX1_CHVNFE  = '"+ oProtNfe:_CHCTE:TEXT +"'"
	cQuery += " AND D_E_L_E_T_ = ' ' "

	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
	cQtdNF := (cAlias)->TOT
	(cAlias)->( DbCloseArea() )

	If cQtdNF > 0
		cLog += cChvLog + " | CTE já importado" + CHR(13) + CHR(10)
		Return( .F. )
	EndIf

	// Verificar se conseguiu identificar o tomador
	If Empty( cToma )
		cLog += cChvLog + " | Não consegui identificar o tomador do frete (1)" + CHR(13) + CHR(10)
		Return( .F. )
	EndIf

	// Define qual entidade é o tomador ( 0-Remetente, 1-Expedidor, 2-Recebedor, 3-Destinatário ou 4-Outros )
	If cToma == "0"
		oToma := oRemet
	ElseIf cToma == "1"
		oToma := oExped
	ElseIf cToma == "2"
		oToma := oReceb
	ElseIf cToma == "3"
		oToma := oDestino
	ElseIf cToma == "4"
		oToma := Iif( Type("oIdent:_TOMA4") == "U", Nil, oIdent:_TOMA4 )
	EndIf

	// Verificar se conseguiu identificar o tomador
	If oToma == Nil
		cLog += cChvLog + " | Não consegui identificar o tomador do frete (2)" + CHR(13) + CHR(10)
		Return( .F. )
	EndIf

	cCnpjT := AllTrim( Iif( Type("oToma:_CNPJ") == "U", Iif( Type("oToma:_CPF") == "U", "", oToma:_CPF:TEXT ), oToma:_CNPJ:TEXT ) )

	If Empty( cCnpjT )
		cLog += cChvLog + " | Não consegui identificar o CNPJ do tomador do frete (1)" + CHR(13) + CHR(10)
		Return( .F. )
	EndIf

	// Verificar o CNPJ do tomador
	dbSelectArea("SM0")
	If SM0->M0_CGC != cCnpjT
		cLog += cChvLog + " | Tomador diferente de "+ SM0->M0_CGC + CHR(13) + CHR(10)
		Return( .F. )
	EndIf

	// Verifica a tag do CNPJ Emissor
	If Type("oEmitente:_CNPJ:TEXT") == "U"
		cLog += cChvLog + " | Tag do CNPJ do emitente não encontrada" + CHR(13) + CHR(10)
		Return( .F. )
	EndIf

	// Verificar se existe o fornecedor do emitente cadastrado, através do CNPJ.
	cQuery := "SELECT A2_COD, A2_LOJA, A2_NOME FROM "+ RetSqlName("SA2") +" WHERE A2_CGC = '"+ oEmitente:_CNPJ:TEXT +"' AND D_E_L_E_T_ = ' ' "

	aAreaTmp := GetArea()
	dbSelectArea("SA2")
	If SA2->( FieldPos("A2_MSBLQL") ) > 0
		cQuery +=" AND A2_MSBLQL <> '1'"
	EndIf
	RestArea( aAreaTmp )

	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )

	While !(cAlias)->( Eof() )
		cQtdEnt++
		(cAlias)->( dbSkip() )
	End
	(cAlias)->( dbGoTop() )

	If cQtdEnt == 0

		If lIncEnt
			lOkEnt := SXSF_038("F")

			If !lOkEnt
				(cAlias)->( dbCloseArea() )
				cLog += cChvLog + " | Transportadora não cadastrada" + CHR(13) + CHR(10)
				Return( .F. )
			EndIf
		Else
			(cAlias)->( dbCloseArea() )
			cLog += cChvLog + " | Transportadora não cadastrada" + CHR(13) + CHR(10)
			Return( .F. )
		Endif

	EndIf

	// Caso tenha mesmo CNPJ mais de uma vez no cadastro, selecionar qual fornecedor
	If cQtdEnt > 1
		aRetEnt := SXSF_029( oEmitente:_CNPJ:TEXT, cAlias, "C" )
	Else
		(cAlias)->( dbCloseArea() )
		dbSelectArea("SA2")
		dbSetOrder(3)
		If dbSeek( xFilial("SA2") + oEmitente:_CNPJ:TEXT )
			aRetEnt := { { A2_COD, A2_LOJA } }
		Else
			cLog += cChvLog + " | Transportadora não encontrada (1)" + CHR(13) + CHR(10)
			Return( .F. )
		EndIf
	EndIf

	// Verifica se existe algum valor no array
	If Empty( aRetEnt[ 1 ][ 1 ] )
		cLog += cChvLog + " | Transportadora não encontrada (2)" + CHR(13) + CHR(10)
		Return( .F. )
	EndIf

	If Select( cAlias ) > 0
		(cAlias)->( DbCloseArea() )
	EndIf

	// Verificar se o cte já consta cadastrado no sistema
	If Type("oIdent:_NCT") == "O"
		cCt := StrZero( Val( oIdent:_NCT:TEXT ), TamSx3("F1_DOC")[ 1 ] )
	EndIf

	If Type("oIdent:_SERIE") == "O"
		nTamSer := TamSx3("F1_SERIE")[ 1 ]
		cSerie  := Right( Replicate( "0", nTamSer ) + AllTrim( oIdent:_SERIE:TEXT ), nTamSer )//PadR( AllTrim( oIdent:_SERIE:TEXT ), TamSx3("F1_SERIE")[ 1 ] )
	EndIf

	// Pesquisa na tabela de notas de entrada
	cQuery := "SELECT COUNT(*) AS TOT FROM " + RetSqlName("SF1")
	cQuery += " WHERE F1_FILIAL  = '"+ xFilial("SF1") +"'"
	cQuery += " AND F1_DOC       = '"+ cCt +"'"
	cQuery += " AND F1_SERIE     = '"+ cSerie +"'"
	cQuery += " AND F1_FORNECE   = '"+ aRetEnt[ 1 ][ 1 ] +"'"
	cQuery += " AND F1_LOJA      = '"+ aRetEnt[ 1 ][ 2 ] +"'"
	cQuery += " AND D_E_L_E_T_ = ' ' "

	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
	cQtdNF := (cAlias)->TOT
	(cAlias)->( DbCloseArea() )

	If cQtdNF > 0
		lNfOk := .T.
	EndIf

	// Pesquisa na tabela de XML
	cQuery := "SELECT COUNT(*) AS TOT FROM " + RetSqlName("ZX1")
	cQuery += " WHERE ZX1_FILIAL = '"+ xFilial("ZX1") +"'"
	cQuery += " AND ZX1_DOC      = '"+ cCt +"'"
	cQuery += " AND ZX1_SERIE    = '"+ cSerie +"'"
	cQuery += " AND ZX1_CLIFOR   = '"+ aRetEnt[ 1 ][ 1 ] +"'"
	cQuery += " AND ZX1_LOJA     = '"+ aRetEnt[ 1 ][ 2 ] +"'"
	cQuery += " AND D_E_L_E_T_ = ' ' "

	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
	cQtdNF := (cAlias)->TOT
	(cAlias)->( DbCloseArea() )

	If cQtdNF > 0
		lNfOk := .T.
	EndIf

	// Verificar o CNPJ do remetente das notas
	cCnpjR := AllTrim( Iif( Type("oRemet:_CNPJ") == "U", Iif( Type("oRemet:_CPF") == "U", "", oRemet:_CPF:TEXT ), oRemet:_CNPJ:TEXT ) )

	// Preciso verificar se o remetente é a própria empresa para saber o tipo de frete
	// Se sim, significa que as notas contidas no conhecimento sao notas de saida (venda, devolucao de compras ou devolucao de remessa para beneficiamento)
	// Se nao, significa que as notas contidas no conhecimento sao notas de entrada (notas de compra, devolucao de vendas ou remessa para beneficiamento)
	If AllTrim(SM0->M0_CGC) == (cCnpjR)
		// CNPJ do destinatário
		cCnpjX := AllTrim( Iif( Type("oDestino:_CNPJ") == "U", Iif( Type("oDestino:_CPF") == "U", "", oDestino:_CPF:TEXT ), oDestino:_CNPJ:TEXT ) )
		cTpFrete := "F" // Faturamento (frete sobre saídas)
	Else
		// CNPJ do remetente
		cCnpjX := cCnpjR
		cTpFrete := "C" // Compras (frete sobre entradas)

		// Idenficar se o destinatário é fornecedor ou cliente
		SA1->( dbSetOrder(3) )
		If SA1->( dbSeek( xFilial("SA1") + cCnpjX ) )
			aDadosCli[1] := SA1->A1_COD
			aDadosCli[2] := SA1->A1_LOJA
		EndIf

		SA2->( dbSetOrder(3) )
		If SA2->( dbSeek( xFilial("SA2") + cCnpjX ) )
			aDadosFor[1] := SA2->A2_COD
			aDadosFor[2] := SA2->A2_LOJA
		EndIf

		If Empty( aDadosCli[1] ) .And. !Empty( aDadosFor[1] )
			cCodEnt := aDadosFor[1]
			cLojEnt := aDadosFor[2]
		ElseIf !Empty( aDadosCli[1] ) .And. Empty( aDadosFor[1] )
			cCodEnt := aDadosCli[1]
			cLojEnt := aDadosCli[2]
		ElseIf !Empty( aDadosCli[1] ) .And. !Empty( aDadosFor[1] )

			// Verificar as notas de entrada pois tem tanto fornecedor quanto cliente com o CNPJ do remetente
			For _nF := 1 To Len( aNfRef )
				_cNfRef += "'"+ aNfRef[ _nF ]:TEXT +"',"
			Next
			_cNfRef := Left( _cNfRef, Len( _cNfRef ) - 1 ) + ")"

			cQuery := "SELECT F1_TIPO FROM "+ RetSqlName("SF1")
			cQuery += " WHERE F1_CHVNFE IN "+ _cNfRef
			cQuery += " AND F1_FILIAL = '"+ xFilial("SF1") +"' AND D_E_L_E_T_ <> '*' GROUP BY F1_TIPO "

			TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
			(cAlias)->( dbGotop() )

			While !(cAlias)->( Eof() )
				aAdd( aTipos, F1_TIPO ) // Todos os tipos das notas referenciadas
				(cAlias)->( dbSkip() )
			End
			(cAlias)->( dbCloseArea() )

			If Len( aTipos ) == 0
				cLog += cChvLog + " | Problema em determinar o tipo da nota referenciada" + CHR(13) + CHR(10)
				cCodEnt := ""
				cLojEnt := ""

			ElseIf Len( aTipos ) == 1

				If aTipos[1] $ cTiposFor // "NC"
					cCodEnt := aDadosFor[1]
					cLojEnt := aDadosFor[2]
				ElseIf aTipos[1] $ cTiposCli // "BD"
					cCodEnt := aDadosCli[1]
					cLojEnt := aDadosCli[2]
				EndIf

			ElseIf Len( aTipos ) > 1

				For _nF := 1 To Len( aTipos )

					If aTipos[_nF] $ cTiposFor // "NC"
						lTpFor :=.T.
					ElseIf aTipos[_nF] $ cTiposCli // "BD"
						lTpCli :=.T.
					EndIf

				Next

				If lTpCli .And. !lTpFor
					cCodEnt := aDadosCli[1]
					cLojEnt := aDadosCli[2]
				ElseIf !lTpCli .And. lTpFor
					cCodEnt := aDadosFor[1]
					cLojEnt := aDadosFor[2]
				ElseIf (!lTpCli .And. !lTpFor) .Or. (lTpCli .And. lTpFor)
					cLog += cChvLog + " | Problema em determinar o tipo da nota referenciada" + CHR(13) + CHR(10)
					cCodEnt := ""
					cLojEnt := ""
				EndIf
			EndIf

		Endif

	EndIf

	// Gravar ZX1
	Begin Transaction

		dbSelectArea("ZX1")
		RecLock("ZX1",.T.)
			ZX1->ZX1_FILIAL := xFilial("ZX1")
			ZX1->ZX1_TPDOC  := "CTE"
			ZX1->ZX1_TIPO   := Iif( cTpFrete == "F", "N", "C" )
			ZX1->ZX1_DOC    := cCt
			ZX1->ZX1_SERIE  := cSerie
			ZX1->ZX1_CLIFOR := aRetEnt[ 1 ][ 1 ]
			ZX1->ZX1_LOJA   := aRetEnt[ 1 ][ 2 ]
			ZX1->ZX1_EMISSA := dDtEmi
			ZX1->ZX1_EST    := cUf
			ZX1->ZX1_ESPECI := "CTE  "
			ZX1->ZX1_STATUS := Iif( cCodRet == "101", "9", Iif( lNfOk, "2", "0" ) )
			ZX1->ZX1_CHVNFE := oProtNfe:_CHCTE:TEXT
			ZX1->ZX1_XML    := cBuffer
			ZX1->ZX1_CGCREM := cCnpjX
			ZX1->ZX1_TPFRET := cTpFrete
			ZX1->ZX1_CODENT := cCodEnt // Entidade é o fornecedor ou cliente destinatário do frete
			ZX1->ZX1_LOJENT := cLojEnt // É o código e loja que será utilizado no filtro do execauto da rotina de conhecimento de frete
			ZX1->ZX1_DTIMP  := dDataBase
		ZX1->( MsUnLock() )

		If Type('oNf:_INFCTE:_IMP:_ICMS') == 'O'

			// Verifica em todas as situações tributárias
			For nY := 1 To Len( aSitTrib )

		 		If Type("oNf:_INFCTE:_IMP:_ICMS:_ICMS"+ aSitTrib[ nY ] ) == "O" // Verifica a tag de cada situação tributária

		 			cCST := "0"+ &("oNf:_INFCTE:_IMP:_ICMS:_ICMS"+ aSitTrib[ nY ] +":_CST:TEXT")

		 			If Type("oNf:_INFCTE:_IMP:_ICMS:_ICMS"+ aSitTrib[ nY ] +":_VBC") == "O" // Verifica se tem a tag da base de cálculo do ICMS

			 			nBaseICM := Val( &("oNf:_INFCTE:_IMP:_ICMS:_ICMS"+ aSitTrib[ nY ] +":_VBC:TEXT") )
			 			nValICM  := Val( &("oNf:_INFCTE:_IMP:_ICMS:_ICMS"+ aSitTrib[ nY ] +":_VICMS:TEXT") )
			 			nPICM    := Val( &("oNf:_INFCTE:_IMP:_ICMS:_ICMS"+ aSitTrib[ nY ] +":_PICMS:TEXT") )

			 		EndIf

		 			If Type("oNf:_INFCTE:_IMP:_ICMS:_ICMS"+ aSitTrib[ nY ] +":_VBCSTRET") == "O" // Verifica se tem a tag da base de cálculo do ICMS ST

			 			nBaseICMST := Val( &("oNf:_INFCTE:_IMP:_ICMS:_ICMS"+ aSitTrib[ nY ] +":_VBCSTRET:TEXT") )
			 			nValICMST  := Val( &("oNf:_INFCTE:_IMP:_ICMS:_ICMS"+ aSitTrib[ nY ] +":_VICMSSTRET:TEXT") )
			 			nPICMST    := Val( &("oNf:_INFCTE:_IMP:_ICMS:_ICMS"+ aSitTrib[ nY ] +":_PICMSSTRET:TEXT") )

			 		EndIf

		 		EndIf

			Next nY

		EndIf

		nVTPrest := IIF( Type("oNf:_INFCTE:_VPREST:_VTPREST")=='O', Val( oNf:_INFCTE:_VPREST:_VTPREST:TEXT ), 0 )

		dbSelectArea("ZX2")
		RecLock("ZX2",.T.)
			ZX2->ZX2_FILIAL := xFilial("ZX2")
			ZX2->ZX2_ITEM   := StrZero( 1, 4 )
			ZX2->ZX2_COD    := Iif( cTpFrete == "F", cPrdFrtV, "" )
			ZX2->ZX2_DESCF  := Iif( cTpFrete == "F", Posicione("SB1",1,xFilial("SB1")+cPrdFrtV,"B1_DESC"), "" )
			ZX2->ZX2_QUANT  := Iif( cTpFrete == "F", 1, 0 )
			ZX2->ZX2_VUNIT  := nVTPrest
			ZX2->ZX2_TOTAL  := nVTPrest
			ZX2->ZX2_CF     := Posicione( "SF4", 1, xFilial("SF4") + Iif( cTpFrete == "F", cTesFrtV, cTesFrtC ), "F4_CF" )
			ZX2->ZX2_UM     := Iif( cTpFrete == "F", Posicione("SB1",1,xFilial("SB1")+cPrdFrtV,"B1_UM"), "" )
			ZX2->ZX2_CHVNFE := oProtNfe:_CHCTE:TEXT
			ZX2->ZX2_BASICM := nBaseICM
			ZX2->ZX2_VALICM := nValICM
			ZX2->ZX2_PERICM := nPICM
			ZX2->ZX2_BICMST := nBaseICMST
			ZX2->ZX2_VICMST := nValICMST
			ZX2->ZX2_PICMST := nPICMST
			ZX2->ZX2_CST    := cCST
			ZX2->ZX2_TES    := Iif( cTpFrete == "F", cTesFrtV, cTesFrtC )
		ZX2->( MsUnLock() )

	End Transaction

Return( .T. )

//-----------------------------------------------
// Função que baixa arquivos xml anexos em e-mail
//-----------------------------------------------
Static Function SXSF_024()

	Local oMail    := TMailManager():New()
	Local nConn    := 0
	Local nStat    := 0
	Local nQtMsg   := 0
	Local nMess    := 0
	Local nResul   := 0
	Local nAtach   := 0
	Local nDelay   := 0
	Local nNOK     := 0
	Local nOK      := 0
	Local cRet     := ""
	Local lFld     := .F.
	Local lSave    := .F.
	Local lDelMsg  := .T.
	Local aAttInfo := {}
	Local aConfigs := U_SXUF_007() // Retorna as configurações de e-mail
	Local lAutCon  := aConfigs[10] == "S"
	Local lSSLCon  := aConfigs[11] == "S"
	Local lTLSCon  := aConfigs[12] == "S"
	Local cServerE := PadR( aConfigs[06], 60 )
	Local cServerS := PadR( aConfigs[08], 60 )
	Local cConta   := PadR( aConfigs[03], 60 )
	Local cSenha   := PadR( aConfigs[04], 25 )
	Local cProt    := PadR( aConfigs[02], 04 )
	Local cPortaE  := PadR( aConfigs[07], 05 )
	Local cPortaS  := PadR( aConfigs[09], 05 )
	Local cFolder  := PadR( aConfigs[05], 20 )
	Local cRPath   := GetSrvProfString( "RootPath", "" )

	oProcReg:SetRegua1(5)

	If Right( cRPath, 1 ) <> '\'
		If Left( cWorkDir, 1 ) != '\'
			cRPath += '\'
		EndIf
	Endif
	cRPath += cWorkDir + AllTrim(SM0->M0_CGC) + "\" // Diretório root do Protheus + Diretório de trabalho do XML

  	// Segurança SSl e TLS
	If lSSLCon .And. lTLSCon
		oMail:SetUseSSL( lSSLCon )
		oMail:SetUseTLS( lTLSCon )
	EndIf

	oProcReg:IncRegua1("Inicializando objeto de e-mail...")

	// Inicialização do objeto
	nStat := oMail:Init( AllTrim( cServerE ), AllTrim( cServerS ), AllTrim( cConta ), AllTrim( cSenha ), Val( cPortaE ), Val( cPortaS ) )

	If nStat > 0
		cRet := 'Problema na inicialização'
	EndIf

	If Empty( cRet )

		// TimeOut
		If cProt == 'SMTP'
			nDelay := oMail:GetSMTPTimeOut()
			nDelay := Iif( nDelay != 0, nDelay, 60 )
			oMail:SetSMTPTimeout( nDelay )
		Else
			nDelay := oMail:GetPOPTimeOut()
			nDelay := Iif( nDelay != 0, nDelay, 60 )
			oMail:SetPOPTimeout( nDelay )
		EndIf

		oProcReg:IncRegua1("Conectando...")

		// Conectar ao e-mail
		If cProt == 'POP'
			nConn := oMail:POPConnect()
		ElseIf cProt == 'MAPI' .Or. cProt == 'IMAP'
			nConn := oMail:IMAPConnect()
		ElseIf cProt == 'SMTP'
			nConn := oMail:SmtpConnect()
		EndIf

		If nConn == 0

			// Autenticação
			oProcReg:IncRegua1("Autenticando...")
			If lAutCon .And. cProt == 'SMTP'
				nStat := oMail:SMTPAuth( AllTrim( cConta ), AllTrim( cSenha ) )
				If nStat > 0
					cRet := 'Problema na autenticação'
				EndIf
			EndIf

			// Localização de pasta remota
			If cProt == 'IMAP' .And. Empty( cRet ) .And. nStat == 0 .And. !Empty( cFolder )

				lFld := oMail:ChangeFolder( AllTrim( cFolder ) )

				If !lFld
					cRet := 'Erro pasta remota'
				EndIf

			EndIf

			If Empty( cRet )

				oProcReg:IncRegua1("Processando mensagens de e-mail...")

				//Conta quantas mensagens há no servidor
				oMail:GetNumMsgs(@nQtMsg)

				If( nQtMsg > 0 )

					oProcReg:SetRegua2(nQtMsg)

					oMessage := TMailMessage():New()

					//Verifica todas mensagens no servidor
					For nMess := 1 To nQtMsg

						oMessage:Clear()
						lDelMsg := .T.
						nResul := oMessage:Receive( oMail, nMess )

						If ( nResul == 0 ) //Recebido com sucesso

							oProcReg:IncRegua2("Processando mensagem "+ cValToChar(nMess) +" de "+ cValToChar(nQtMsg) +" com "+ cValToChar(oMessage:getAttachCount()) +" anexos...")

							//Verifica todos anexos da mensagem
							For nAtach := 1 To oMessage:getAttachCount()

								aAttInfo := oMessage:getAttachInfo( nAtach )

								If aAttInfo != Nil .And. ValType( aAttInfo ) == "A" .And. Len( aAttInfo ) > 0 .And. ".XML" $ Upper( aAttInfo[ 1 ] )

									If !File( cRPath + aAttInfo[ 1 ] )

										lSave := oMessage:SaveAttach( nAtach, cRPath + aAttInfo[ 1 ] )

										If !lSave
											nNOK++
											lDelMsg := .F.
										Else
											nOK++
										EndIf

									Else
										nNOK++
									EndIf

								EndIf

							Next

							oMessage:SetConfirmRead(.T.)

							// Deleta mensagem
							If lDelMsg
								//oMail:DeleteMsg( nMess )
							EndIf

						EndIf

					Next

			     EndIf

			Else
				MsgAlert( cRet )
			EndIf

		Else
			cRet := 'Houve um problema ao tentar baixar do e-mail: '+ Alltrim( oMail:GetErrorString( nConn ) )
			MsgAlert( cRet )
		EndIf

	Else
		MsgAlert( cRet )
	EndIf

	oProcReg:IncRegua1("Desconectando da conta de e-mail...")

	// Desconexão do e-mail
	If cProt == 'IMAP'
		oMail:IMAPDisconnect()
	ElseIf cProt == 'POP '
		oMail:POPDisconnect()
	ElseIf cProt == 'MAPI'
		oMail:SMTPDisconnect()
	ElseIf cProt == 'SMTP'
		oMail:SMTPDisconnect()
	EndIf

Return()

//--------------------------------------------------------
// Função que retorna o objeto xml do conteúdo do arquivo
//--------------------------------------------------------
Static Function SXSF_025( cXMLPath )

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

//--------------------------------------------
// Função que cria a interface de visualização
//--------------------------------------------
User Function SXUF_010( cAlias, nReg, nOpcx )

	Local oDlg
	Private	aHeader := {}
	Private aCols   := {}

	SetKey( VK_F11, { || SXSF_049(ZX1->ZX1_CHVNFE) } )

	FillGetDados(nOpcx,"ZX2",1,,,,{"ZX2_FILIAL","ZX2_CHVNFE"},,,,{|| SXSF_032() },.F.,,,,,,)

	aSize := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 050, .t., .t. } )
	AAdd( aObjects, { 100, 050, .t., .t. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
		EnChoice( cAlias, nReg, nOpcx, , , , , aPosObj[1],,3,,,,,,,,,,)
		MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,,,"",,,,,,,,,,,)
		oDlg:lMaximized := .T.
	ACTIVATE MSDIALOG oDlg On INIT SXSF_033( oDlg,{||oDlg:End()},{||oDlg:End()},nOpcx)

	SetKey( VK_F11, Nil )

Return( nOpcx )


//--------------------------------------------------------------------
// Monta o array aCols com os itens na visualização e exclusão de NFE
//--------------------------------------------------------------------
Static Function SXSF_032()

	Local _nI    := 0
	Local nUsado := Len( aHeader )

	aCols := {}

	dbSelectArea("ZX2")
	dbSetOrder(1)
	dbSeek( xFilial("ZX2") + ZX1->ZX1_CHVNFE )

	While !ZX2->( Eof() ) .And. ZX2->ZX2_FILIAL + ZX2->ZX2_CHVNFE == xFilial("ZX2") + ZX1->ZX1_CHVNFE

		aAdd( aCols, Array( nUsado + 1 ) )

		For _ni := 1 to nUsado - 2
			If AllTrim( aHeader[ _ni, 2 ] ) == "ZX2_OPER"
				aCols[ Len( aCols ), _ni ] := Space(2)
			Else
				aCols[ Len( aCols ), _ni ] := FieldGet( FieldPos( aHeader[ _ni, 2 ] ) )
			EndIf
		Next
		aCols[ Len( aCols ) ][ nUsado - 1 ] := "ZX2"
		aCols[ Len( aCols ) ][ nUsado     ] := ZX2->( Recno() )
		aCols[ Len( aCols ) ][ nUsado + 1 ] := .F.

  	  	ZX2->( dbSkip() )
	End

Return


//---------------------------------------
// Cria opções no menu Ações Relacionadas
//---------------------------------------
Static Function SXSF_033( oDlg, bOk, bCancel, nOpc )

	Local aButtons   := {}
	/*
	If nOpc == 1
		AAdd( aButtons, { "S4WB004N", { || ZeraTudo() }, "&Zerar", "ZERAR TELA" } )
	EndIf
    */
Return( EnchoiceBar( oDlg, bOK, bcancel,, aButtons ) )


//-------------------------------------
// Classificação de documento fiscal
//-------------------------------------
User Function SXUF_005()

	Local cQuery := ""
	Local cAlias := ""

	Private cCondPg := ""
	Private cCndFor := ""
	Private nTotParc := 0
	Private nTotDup  := 0
	cQuery := "SELECT R_E_C_N_O_ FROM "+ RetSqlName("ZX1") +" WHERE ZX1_OK = '"+ cMark +"' "

	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )

	If (cAlias)->( Eof() )
		Processa({|| SXSF_044() },"Executando Ação","Aguarde, classificando documento "+ZX1->ZX1_DOC,.F.)
	Else
		While !(cAlias)->( Eof() )

			ZX1->( dbGoTo( (cAlias)->R_E_C_N_O_ ) )
			Processa({|| SXSF_044() },"Executando Ação","Aguarde, classificando documento "+ZX1->ZX1_DOC,.F.)

			(cAlias)->( dbSkip() )
		End
	EndIf

	(cAlias)->( DbCloseArea() )

Return

//-------------------------------------------
// Classifica o documento individualmente
//-------------------------------------------
Static Function SXSF_044()

	Local cTipDoc := ZX1->ZX1_TPDOC  // Tipo de documento (NF-e ou CT-e)
	Local cTpFrete:= ZX1->ZX1_TPFRET // Tipo de frete
	Local cCodEnt := ZX1->ZX1_CODENT // Código do remetente (pode ser fornecedor ou cliente)
	Local cLojEnt := ZX1->ZX1_LOJENT // Loja do remetente
	Local cCnpjX  := ZX1->ZX1_CGCREM // CNPJ do remetente
	Local cForCTe := ZX1->ZX1_CLIFOR
	Local cLojCTe := ZX1->ZX1_LOJA
	Local lDevBen := .F. // Se é devolução ou beneficiamento
	Local lComp   := .F. // Se é CT-e complementar
	Local lTemPN  := .F.
	Local nTamFil := 0
	Local lNoOk   := .F.
	Local _cErr   := ""
	Local _cWrn   := ""
	Local cTpAmb  := ""
	Local cToma   := ""
	Local cCnpjR  := ""
	Local cCnpjT  := ""
	Local cAlias  := ""
	Local cQuery  := ""
	Local cTmpCond:= ""
	Local cNaturez:= ""
	Local cCodRet := ""
	Local cCondEnt:= Iif( cTipDoc == "NFE" .And. ZX1->ZX1_TIPO $ "NC", Posicione("SA2",1,xFilial("SA2")+cForCTe+cLojCTe,"A2_COND"), Space( Len( SF1->F1_COND ) ) )
	Local cChaveNF:= "" // Chave da nota associada ao Cte
	Local aItens116 := {} // Itens para o execauto (nfs)
	Local aCabec116 := {} // Cabeçalho para filtro no ExecAuto
	Local aCabec    := {}
	Local aLinha    := {}
	Local aItens    := {}
	Local aCondPag  := {}
	Local _oXml     := XmlParser( ZX1->ZX1_XML, "_", @_cErr, @_cWrn ) // Crio o objeto XML
	Local cIdEnt    := SXSF_012() // Retorna o código da Entidade no TSS
	Local cChavCTE  := ""
	Local oDlgPG, oSBtnPG, oGetPG
	Local aHead2    := {} // Array a ser tratado internamente na MsNewGetDados como aHeader
	Local aCol2     := {} // Array a ser tratado internamente na MsNewGetDados como aCols
	Local oFontC    := TFont():New('Courier new',,22,,.T.)
	Local _aTmpParc  := {}
	Local _oParcDup

	Private oGetDados2
	Private oTotParc
	Private _aParcNfe := {}

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .F.

	If lGrvBloq .And. ZX1->ZX1_BLOQ $ ("139")
		MsgAlert("Documento não pode ser gerado pois possui divergência!")
		Return(.F.)
	EndIf

	If !( ZX1->ZX1_STATUS $ "0" ) // Verifica o status
		MsgAlert("Este documento não pode ser classificado. Motivo: Verificar o Status (legenda)")
		Return(.F.)
	EndIf

	SF1->( dbSetOrder(8) )
	If SF1->( dbSeek( xFilial("SF1") + ZX1->ZX1_CHVNFE ) .And. !Empty( SF1->F1_STATUS ) ) // Nota já classificada
		MsgAlert("Este documento já encontra-se classificado, o status será atualizado.")
		RecLock("ZX1",.F.)
			ZX1->ZX1_STATUS := "2"
		MsUnLock()
		Return(.F.)
	EndIf

	If cTipDoc == "CTE"
		cCodRet := "100" /* Na importação não será necessário */ //SXSF_011( ZX1->ZX1_CHVNFE, cIdEnt, .T. ) // Retorna situação no Sefaz
	Else
		cCodRet := SXSF_055( ZX1->ZX1_CHVNFE, .F. ) // Verifica se nota está disponível
	EndIf

	If cCodRet == "101" // Rejeição
		MsgAlert("Nota fiscal está cancelada! Status Atualizado!")
		RecLock("ZX1",.F.)
			ZX1->ZX1_STATUS := "9"
		MsUnLock()
		Return( .F. )
	EndIf

	// Verificar se este documento tem os itens (Nota fiscal ou ct-e de venda/remessa)
	If cTipDoc == "NFE" .Or. cTipDoc == "CTE" .And. ZX1->ZX1_TIPO == "N"

		cQuery := "SELECT COUNT(*) AS TOT FROM " + RetSqlName("ZX2")
		cQuery += " WHERE ZX2_CHVNFE  = '"+ ZX1->ZX1_CHVNFE +"'"
		cQuery += " AND D_E_L_E_T_ = ' ' "

		TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
		nQtdItens := (cAlias)->TOT
		(cAlias)->( DbCloseArea() )

		If nQtdItens == 0
			MsgAlert("Este documento não possui itens, favor copiar a chave, exluir este XML e reimportar.")
			Return( .F. )
		EndIf

	EndIf

	// Verifica se pode mudar de status (preenchidos todos os produtos e todos os tipos de entrada)
	If ZX1->ZX1_TPDOC == "CTE" .And. ZX1->ZX1_TIPO == "C"
		cQuery := "SELECT COUNT(*) TOT FROM "+ RetSqlName("ZX2") +" WHERE ZX2_CHVNFE = '"+ ZX1->ZX1_CHVNFE +"' AND D_E_L_E_T_ = ' ' AND ZX2_TES = ' ' "
	Else
		cQuery := "SELECT COUNT(*) TOT FROM "+ RetSqlName("ZX2") +" WHERE ZX2_CHVNFE = '"+ ZX1->ZX1_CHVNFE +"' AND D_E_L_E_T_ = ' ' AND ( ZX2_COD = ' ' OR ZX2_TES = ' ' )"
	EndIf
	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
	lNoOk := (cAlias)->TOT > 0
	(cAlias)->( DbCloseArea() )

	If lNoOk // Tem itens a serem revisados, ajusta o status
		MsgAlert("Este documento tem itens a serem revisados (produto ou TES), seu status será atualizado")
		ZX1->( RecLock("ZX1",.F.) )
			ZX1->ZX1_STATUS := "3"
		ZX1->( MsUnLock() )
		Return(.F.)
	EndIf

	If cTipDoc == "NFE"

		SF1->( dbSetOrder(8) )
		If SF1->( dbSeek( xFilial("SF1") + ZX1->ZX1_CHVNFE ) .And. Empty( SF1->F1_STATUS ) ) // prénota
			lTemPN := .T.
		EndIf

		cQuery := "SELECT * FROM "+ RetSqlName("ZX2")
		cQuery += " WHERE ZX2_CHVNFE = '"+ ZX1->ZX1_CHVNFE +"' "
		cQuery += " AND D_E_L_E_T_ = ' ' "

		TCQuery cQuery New Alias ( cAlias := GetNextAlias() )

		While !(cAlias)->( Eof() )

			aLinha := {}

			aAdd( aLinha, { "D1_COD"    , (cAlias)->ZX2_COD   , Nil, Nil } )
			aAdd( aLinha, { "D1_QUANT"  , (cAlias)->ZX2_QUANT , Nil, Nil } )
			aAdd( aLinha, { "D1_VUNIT"  , (cAlias)->ZX2_VUNIT , Nil, Nil } )
			aAdd( aLinha, { "D1_TOTAL"  , (cAlias)->ZX2_TOTAL , Nil, Nil } )
			aAdd( aLinha, { "D1_TES"    , (cAlias)->ZX2_TES   , Nil, Nil } )

			cNaturez := Posicione("SB1",1,xFilial("SB1")+(cAlias)->ZX2_COD,"B1_NATUREZ")
			If !Empty( cNaturez )
				aAdd( aLinha, { "D1_NATUREZ", cNaturez, Nil, Nil } )
			EndIf

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

				If aScan( aCondPag, { |o| o[1] == (cAlias)->ZX2_PC } ) == 0
					cTmpCond := Posicione("SC7", 1, xfilial("SC7") + (cAlias)->ZX2_PC, "C7_COND")
					If !Empty( cTmpCond )
						aAdd( aCondPag, { (cAlias)->ZX2_PC, cTmpCond } )
					EndIf
				EndIf
			EndIf

			If !Empty( (cAlias)->ZX2_NFSORI )
				aAdd( aLinha, { "D1_NFORI"   , (cAlias)->ZX2_NFSORI, Nil, Nil } )
				aAdd( aLinha, { "D1_SERIORI" , (cAlias)->ZX2_SERORI, Nil, Nil } )
				aAdd( aLinha, { "D1_ITEMORI" , (cAlias)->ZX2_ITMORI, Nil, Nil } )
			EndIf

			If !Empty( (cAlias)->ZX2_LOTECT )
				aAdd( aLinha, { "D1_LOTECTL", (cAlias)->ZX2_LOTECT, Nil, Nil } )
				aAdd( aLinha, { "D1_DTVALID", StoD( (cAlias)->ZX2_DTVLOT ), Nil, Nil } )
			EndIf

			aAdd( aItens, aLinha )

			(cAlias)->( dbSkip() )
		End
		(cAlias)->( dbCloseArea() )

		cCondEnt := Iif( Empty( cCondEnt ), cCondPad, cCondEnt )
		cTmpCond := Iif( Len( aCondPag ) > 1, SXSF_045( aCondPag ), Iif( Len( aCondPag ) == 1, aCondPag[ 1, 2 ], cCondEnt ) )

		aAdd( aCabec, { "F1_TIPO"   , ZX1->ZX1_TIPO  , Nil, Nil } )
		aAdd( aCabec, { "F1_FORMUL" , "N"            , Nil, Nil } )
		aAdd( aCabec, { "F1_DOC"    , ZX1->ZX1_DOC   , Nil, Nil } )
		aAdd( aCabec, { "F1_CHVNFE" , ZX1->ZX1_CHVNFE, Nil, Nil } )
		aAdd( aCabec, { "F1_SERIE"  , ZX1->ZX1_SERIE , Nil, Nil } )
		aAdd( aCabec, { "F1_EMISSAO", ZX1->ZX1_EMISSA, Nil, Nil } )
		aAdd( aCabec, { "F1_FORNECE", ZX1->ZX1_CLIFOR, Nil, Nil } )
		aAdd( aCabec, { "F1_LOJA"   , ZX1->ZX1_LOJA  , Nil, Nil } )
		aAdd( aCabec, { "F1_ESPECIE", ZX1->ZX1_ESPECI, Nil, Nil } )
		If !Empty( cTmpCond )
			aAdd( aCabec, { "F1_COND", cTmpCond } )
		EndIf

		// Tratamento das parcelas
		If XmlChildEx( _oXml:_NFEPROC:_NFE:_INFNFE, "_COBR" ) != Nil
			If XmlChildEx( _oXml:_NFEPROC:_NFE:_INFNFE:_COBR, "_DUP" ) != Nil
				_oParcDup := _oXml:_NFEPROC:_NFE:_INFNFE:_COBR:_DUP
				_aTmpParc := Iif( _oParcDup == Nil, {}, Iif( ValType( _oParcDup ) == "O", {_oParcDup}, _oParcDup ) ) // Duplicatas /Parcelas
				_aParcNfe := {}
				For _nX := 1 To Len( _aTmpParc )
					aAdd( _aParcNfe, { StoD( StrTran( _aTmpParc[ _nX ]:_DVENC:TEXT, "-", "" ) ), Val( _aTmpParc[ _nX ]:_VDUP:TEXT ) } )
				Next
			EndIf
		EndIf

		Begin Transaction

			SetKey( VK_F5 , { || A103ForF4(NIL,NIL,.F.,.F.,{},{},{},{},.F.,0)})
			SetKey( VK_F6 , { || A103ItemPC(NIL,NIL,NIL,.F.,.F.,{},{},,.F.,0)})

			MSExecAuto( { | w, x, y, z | MATA103( w, x, y, z ) }, aCabec, aItens, Iif( lTemPN, 4, 3 ), .T. )

			SetKey(VK_F5,Nil)
			SetKey(VK_F6,Nil)

			If lMsErroAuto
				DisarmTran()
				If MsgYesNo("Ocorreu um problema na execução automática. Deseja ver o erro?")
					MostraErro()
				EndIf
			Else
				SF1->( dbSetOrder(8) )
				If SF1->( dbSeek( xFilial("SF1") + ZX1->ZX1_CHVNFE ) )
					ZX1->( RecLock("ZX1",.F.) )
						ZX1->ZX1_STATUS := "2" // Documento Classificado
					ZX1->( MsUnLock() )
				EndIf

			EndIf

		End Transaction

	ElseIf cTipDoc == "CTE"

		oNF       := Iif( Type("_oXml:_CTEOSPROC") != "U", _oXml:_CTEPROC:_CTE, _oXml:_CTEPROC:_CTE )
		oIdent    := oNF:_INFCTE:_IDE
		oEmitente := oNF:_INFCTE:_EMIT
		oRemet    := Iif( Type("oNF:_INFCTE:_REM") == "U", Nil, oNF:_INFCTE:_REM )
		oDestino  := Iif( Type("oNF:_INFCTE:_DEST") == "U", Nil, oNF:_INFCTE:_DEST )
		oExped    := Iif( Type("oNF:_INFCTE:_EXPED") == "U", Nil, oNF:_INFCTE:_EXPED )
		oReceb    := Iif( Type("oNF:_INFCTE:_RECEB") == "U", Nil, oNF:_INFCTE:_RECEB )
		oVPrest   := Iif( Type("oNF:_INFCTE:_VPREST") == "U", Nil, oNF:_INFCTE:_VPREST )
		oCompl    := Iif( Type("oNF:_INFCTE:_COMPL") == "U", Nil, oNF:_INFCTE:_COMPL )
		oImposto  := Iif( Type("oNF:_INFCTE:_IMP") == "U", Nil, oNF:_INFCTE:_IMP )
		oInfNorma := Iif( Type("oNF:_INFCTE:_INFCTENORM") == "U", Nil, oNF:_INFCTE:_INFCTENORM )
		oNfRef    := Iif( Type("oInfNorma:_INFDOC:_INFNFE") == "U", Nil, oInfNorma:_INFDOC:_INFNFE )

		// Notas fiscais referenciadas
		aNfRef := Iif( oNfRef == Nil, {}, Iif( ValType( oNfRef ) == "O", {oNfRef}, oNfRef ) )

		cTpAmb := oIdent:_TPAMB:TEXT

		// Verificar se a nota foi emitida em ambiente de produção na Sefaz
		If cTpAmb == "2"
			MsgAlert("CT-e emitido em ambiente de homologação")
			Return( .F. )
		EndIf

		cChavCTE := ZX1->ZX1_CHVNFE

		// Consulta ao Sefaz a situação da nota na importação
		cCodRet := "100" // /* Na classificação do CTe não será preciso */SXSF_011( cChavCTE, cIdEnt, .T. ) // Retorna situação no Sefaz

		If cCodRet == "101" // Rejeição
			RecLock("ZX1",.F.)
				ZX1->ZX1_STATUS := "9"
			MsUnLock()
			Return( .F. )
		ElseIf cCodRet <> "100" // Não apto
			Return(.F.)
		EndIf

		// Verifica se CTe é do tipo complementar
		If Type("oNF:_INFCTE:_INFCTECOMP") != "U"
			lComp := .T.
			// Quando for CTE complementar, informa a chave do CTE original
			aCtRef := Iif( ValType(oNF:_INFCTE:_INFCTECOMP) == "O", {oNF:_INFCTE:_INFCTECOMP}, oNF:_INFCTE:_INFCTECOMP )
		EndIf

		// Verificar se conseguiu identificar o tomador
		cToma   := Iif( Type("oIdent:_TOMA3") == "U", Iif( Type("oIdent:_TOMA4") == "U", "", oIdent:_TOMA4:_TOMA:TEXT ), oIdent:_TOMA3:_TOMA:TEXT )
		If Empty( cToma )
			MsgAlert("Tag do tomador [ TOMA3 ou TOMA4 ] vazia ou inexistente")
			Return( .F. )
		EndIf

		// Define qual entidade é o tomador ( 0-Remetente, 1-Expedidor, 2-Recebedor, 3-Destinatário ou 4-Outros )
		If cToma == "0"
			oToma := oRemet
		ElseIf cToma == "1"
			oToma := oExped
		ElseIf cToma == "2"
			oToma := oReceb
		ElseIf cToma == "3"
			oToma := oDestino
		ElseIf cToma == "4"
			oToma := Iif( Type("oIdent:_TOMA4") == "U", Nil, oIdent:_TOMA4 )
		EndIf

		// Verificar se conseguiu identificar o tomador
		If oToma == Nil
			MsgAlert("Tomador do frete não foi identificado")
			Return( .F. )
		EndIf

		// Verificar o CNPJ do tomador do frete
		cCnpjT := AllTrim( Iif( Type("oToma:_CNPJ") == "U", Iif( Type("oToma:_CPF") == "U", "", oToma:_CPF:TEXT ), oToma:_CNPJ:TEXT ) )

		If Empty( cCnpjT )
			MsgAlert("CNPJ do tomador não identificado")
			Return( .F. )
		EndIf

		// Verificar o CNPJ do remetente das notas
		If Empty( cCnpjX )
			MsgAlert("CNPJ do remetente não identificado")
			Return( .F. )
		EndIf

		ZX2->( dbSetOrder(1) )
		ZX2->( dbSeek( xFilial("ZX2") + ZX1->ZX1_CHVNFE ) )

		// Limpa filtro da tabela SF1 para pesquisar pelo fornecedor correto
		SF1->( dbClearFilter() )

		If Len( aNfRef ) > 0

			If cTpFrete == "C"
				// Verificar cada nota referenciada para o filtro
				For nX := 1 To Len( aNfRef )

					SF1->( dbSetOrder(8) )
					cChaveNF :=	Padr( AllTrim( aNfRef[ nX ]:_CHAVE:TEXT ), TamSX3("F1_CHVNFE")[1] )

					//Verifica existência da nota
					If SF1->( dbSeek( xFilial("SF1") + cChaveNF ) ) //Se nota existir, preenche informações do Remetente com dados da nota
						cCodEnt  := SF1->F1_FORNECE
						cLojaRem := SF1->F1_LOJA
						lDevBen  := SF1->F1_TIPO $ "D*B"
					Else
						MsgAlert("Nota original ainda não classificada no sistema! ["+ cChaveNF +"]")
						Return( .F. )
					EndIf

					//-- Registra notas que farao parte do conhecimento
					SF1->( dbSetOrder(1) )
					nTamFil := Len( xFilial("SF1") )
					aAdd( aItens116,{ { "PRIMARYKEY", SubStr( SF1->&( IndexKey() ), nTamFil + 1 ) } } )

				Next nX

				// Escolha/confirmação da condição de pagamento e das parcelas (possibilidade de ajuste de valores e vencimentos)
				cCndFor := Posicione("SA2",1,xFilial("SA2")+cForCTe+cLojCTe,"A2_COND")
				cCondPg := Iif( !Empty( cCndFor ), cCndFor, Iif( !Empty( cPagFrtC ), PadR( cPagFrtC, 3 ), Space(3) ) )

				nTotParc := ZX2->ZX2_TOTAL
				nTotDup  := ZX2->ZX2_TOTAL

				aAdd( aHead2, { "Parcela   "      , "PARCEL", PesqPict("SE2","E2_PARCELA"), TamSX3("E2_PARCELA")[1], 0                    , ""              ,, "C" } )
				aAdd( aHead2, { "Vencimento"      , "VENCTO", PesqPict("SE2","E2_VENCTO") , TamSX3("E2_VENCTO")[1] , 0                    , "U_AtuArrParc()",, "D" } )
				aAdd( aHead2, { "Valor da Parcela", "VALORE", PesqPict("SE2","E2_VALOR")  , TamSX3("E2_VALOR")[1]  , TamSX3("E2_VALOR")[2], "U_AtuArrParc()",, "N" } )
				aAdd( aCol2, { "", CtoD(""), 0, .F. } )

				oDlgPG := MSDialog():New( 092,232,366,694,"Condição de Pagamento",,,.F.,,,,,,.T.,,,.T. )
				oDlgPG:lEscClose := .F.
				oSBtnPG  := SButton():New( 108,188,1,{||oDlgPG:End() },oDlgPG,,"", {|| nTotParc == nTotDup } )
				oGetPG   := TGet():New( 010,008,{|u| If(Pcount()>0,cCondPg:=u,cCondPg)},oDlgPG,060,008,"@!",{|| IF( ExistCpo("SE4",cCondPg), FillCond( cCondPg, .T. ), .F. ) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"SE4","cCondPg",,,,.F.,.F.,,"Condição de Pagamento",1)
				oGetDados2 := MsNewGetDados():New(036,008,096,216,GD_INSERT+GD_DELETE+GD_UPDATE,"U_ValLinParc()","AllwaysTrue","+PARCEL",{"VENCTO","VALORE"},0,999,"AllwaysTrue","","U_DelArrParc()",oDlgPG,aHead2,aCol2)

				oTotParc := TSay():New(018,088, {|| "R$ "+ Transform( nTotParc, "@E 99,999,999.99" ) },oDlgPG,,oFontC,,,,.T.,CLR_GREEN,CLR_WHITE,100,20)

				If !Empty( cCondPg )
					FillCond( cCondPg, .T. )
				EndIf

				oDlgPG:Activate(,,,.T.,{|| !Empty(cCondPg) } )

				// Preenchimento do cabeçalho do frete
				aAdd( aCabec116, { ""          , dDataBase-120                  }) // Data inicial para filtro das notas (atual até 120 dias atrás)
				aAdd( aCabec116, { ""          , dDataBase                      }) // Data final para filtro das notas
				aAdd( aCabec116, { ""          , 2                              }) // 2-Inclusao ; 1=Exclusao
				aAdd( aCabec116, { ""          , IIf( lComp, cForCTe, cCodEnt ) }) // Remetente das notas contidas no conhecimento
				aAdd( aCabec116, { ""          , IIf( lComp, cLojCTe, cLojEnt ) }) // Loja do remetente das notas contidas no conhecimento
				aAdd( aCabec116, { ""          , IIf( lDevBen, 2, 1 )           }) // Tipo das notas contidas no conhecimento: 1=Normal ; 2=Devol/Benef
				aAdd( aCabec116, { ""          , 2                              }) // 1=Aglutina itens ; 2=Nao aglutina itens
				aAdd( aCabec116, { "F1_EST"    , ""                             }) // UF das notas contidas no conhecimento
				aAdd( aCabec116, { ""          , ZX2->ZX2_TOTAL                 }) // Valor do conhecimento
				aAdd( aCabec116, { "F1_FORMUL" , 1                              }) // Formulario proprio: 1=Nao ; 2=Sim
				aAdd( aCabec116, { "F1_DOC"    , ZX1->ZX1_DOC                   }) // Numero da nota de conhecimento
				aAdd( aCabec116, { "F1_SERIE"  , ZX1->ZX1_SERIE                 }) // Serie da nota de conhecimento
				aAdd( aCabec116, { "F1_FORNECE", cForCTe                        }) // Fornecedor da nota de conhecimento
				aAdd( aCabec116, { "F1_LOJA"   , cLojCTe                        }) // Loja do fornecedor da nota de conhecimento
				aAdd( aCabec116, { ""          , cTesFrtC                       }) // TES a ser utilizada nos itens do conhecimento
				aAdd( aCabec116, { "F1_BASERET", ZX2->ZX2_BICMST                }) // Valor da base de calculo do ICMS retido
				aAdd( aCabec116, { "F1_ICMRET" , ZX2->ZX2_VICMST                }) // Valor do ICMS retido
				aAdd( aCabec116, { "F1_COND"   , cCondPg                        }) // Condicao de pagamento
				aAdd( aCabec116, { "F1_EMISSAO", ZX1->ZX1_EMISSA                }) // Data de emissao do conhecimento
				aAdd( aCabec116, { "F1_ESPECIE", ZX1->ZX1_ESPECI                }) // Especie do documento
				aAdd( aCabec116, { "F1_NATUREZ", "40113"                        }) // Natureza
				aAdd( aCabec116, { "DT_PICM"   , 0                              }) // DT_PICM
				aAdd( aCabec116, { "F1_CHVNFE" , cChavCte                       }) // Chave Sefaz
				aAdd( aCabec116, { "F1_TPCTE"  , "N"                            }) // Tipo de CT-e (N/C/S/A)
				aAdd( aCabec116, { "COLAB"     , "N"                            }) // Totvs Colaboração - Não

				Begin Transaction

					// Executa a ExecAuto do MATA116 para gravar o frete
					MsExecAuto( { |x,y| MATA116( x, y ) }, aCabec116, aItens116 )

					If lMsErroAuto
						DisarmTran()
						If MsgYesNo("Ocorreu um problema na execução automática. Deseja ver o erro?")
							MostraErro()
						EndIf
					Else
						SF1->( dbSetOrder(8) )
						If SF1->( dbSeek( xFilial("SF1") + cChavCte ) )
							ZX1->( RecLock("ZX1",.F.) )
								ZX1->ZX1_STATUS := "2" // Documento Classificado
							ZX1->( MsUnLock() )
						EndIf
					EndIf

				End Transaction

			Else
				// Frete quando remetente é a própria empresa (venda/remessa/devolução)

				cTmpCond := Iif( Len( aCondPag ) > 1, SXSF_045( aCondPag ), Iif( Len( aCondPag ) == 1, aCondPag[ 1, 2 ], cPagFrtV ) )

				aAdd( aCabec, { "F1_TIPO"   , ZX1->ZX1_TIPO  , Nil, Nil } )
				aAdd( aCabec, { "F1_FORMUL" , "N"            , Nil, Nil } )
				aAdd( aCabec, { "F1_DOC"    , ZX1->ZX1_DOC   , Nil, Nil } )
				aAdd( aCabec, { "F1_CHVNFE" , ZX1->ZX1_CHVNFE, Nil, Nil } )
				aAdd( aCabec, { "F1_SERIE"  , ZX1->ZX1_SERIE , Nil, Nil } )
				aAdd( aCabec, { "F1_EMISSAO", ZX1->ZX1_EMISSA, Nil, Nil } )
				aAdd( aCabec, { "F1_FORNECE", ZX1->ZX1_CLIFOR, Nil, Nil } )
				aAdd( aCabec, { "F1_LOJA"   , ZX1->ZX1_LOJA  , Nil, Nil } )
				aAdd( aCabec, { "F1_ESPECIE", ZX1->ZX1_ESPECI, Nil, Nil } )
				aAdd( aCabec, { "F1_TPCTE"  , "C"            , Nil, Nil } )
				If !Empty( cTmpCond )
					aAdd( aCabec, { "F1_COND", cTmpCond } )
				EndIf

				aLinha := {}

				aAdd( aLinha, { "D1_COD"    , ZX2->ZX2_COD   , Nil, Nil } )
				aAdd( aLinha, { "D1_QUANT"  , ZX2->ZX2_QUANT , Nil, Nil } )
				aAdd( aLinha, { "D1_VUNIT"  , ZX2->ZX2_VUNIT , Nil, Nil } )
				aAdd( aLinha, { "D1_TOTAL"  , ZX2->ZX2_TOTAL , Nil, Nil } )
				aAdd( aLinha, { "D1_TES"    , ZX2->ZX2_TES   , Nil, Nil } )

				If !Empty( ZX2->ZX2_PERICM )
					aAdd( aLinha, { "D1_VALICM" , ZX2->ZX2_VALICM, Nil, Nil } )
					aAdd( aLinha, { "D1_PICM"   , ZX2->ZX2_PERICM, Nil, Nil } )
					aAdd( aLinha, { "D1_BASEICM", ZX2->ZX2_BASICM, Nil, Nil } )
				EndIf

				If !Empty( ZX2->ZX2_VICMST )
					aAdd( aLinha, { "D1_ICMSRET", ZX2->ZX2_VICMST, Nil, Nil } )
				EndIf

				If !Empty( ZX2->ZX2_PC )

					aAdd( aLinha, { "D1_PEDIDO", ZX2->ZX2_PC    , Nil, Nil } )
					aAdd( aLinha, { "D1_ITEMPC", ZX2->ZX2_ITEMPC, Nil, Nil } )

					If aScan( aCondPag, { |o| o[1] == ZX2->ZX2_PC } ) == 0
						cTmpCond := Posicione("SC7", 1, xfilial("SC7") + ZX2->ZX2_PC, "C7_COND")
						If !Empty( cTmpCond )
							aAdd( aCondPag, { ZX2->ZX2_PC, cTmpCond } )
						EndIf
					EndIf
				Else
					// Campo Tipo de Frete na aba: DANFE não poderá ser preenchido quando houver pedido vinculado a nota
					aAdd( aCabec, { "F1_TPFRETE", "C" } )
					aAdd( aCabec, { "F1_TPCTE"  , "N" } )
				EndIf

				aAdd( aItens, aLinha )

				Begin Transaction

					SetKey( VK_F5 , { || A103ForF4(NIL,NIL,.F.,.F.,{},{},{},{},.F.,0)})
					SetKey( VK_F6 , { || A103ItemPC(NIL,NIL,NIL,.F.,.F.,{},{},,.F.,0)})

					MSExecAuto( { | w, x, y, z | MATA103( w, x, y, z ) }, aCabec, aItens, 3, .T. )

					SetKey(VK_F5,Nil)
					SetKey(VK_F6,Nil)

					If lMsErroAuto
						DisarmTran()
						If MsgYesNo("Ocorreu um problema na execução automática. Deseja ver o erro?")
							MostraErro()
						EndIf
					Else
						SF1->( dbSetOrder(8) )
						If SF1->( dbSeek( xFilial("SF1") + ZX1->ZX1_CHVNFE ) )
							ZX1->( RecLock("ZX1",.F.) )
								ZX1->ZX1_STATUS := "2" // Documento Classificado
							ZX1->( MsUnLock() )
						EndIf

					EndIf

				End Transaction

			EndIf
        Else
			MsgAlert("Não existe nota fiscal eletrônica referenciada")
		EndIf

    EndIf

Return()


//------------------------------------------------------------------
// Função para marcar apenas uma linha no MsSelect dos fornecedores
//------------------------------------------------------------------
Static Function SXSF_035( cMarca )

	Local nReg := (_cTRB)->(( Recno() ))//TRBENT->( Recno() )

	If (_cTRB)->A2_OK ==  cMarca

		//dbSelectArea('TRBENT')
		//dbGotop()
		dbSelectArea(_cTRB)
		(_cTRB)->(dbGoTop())

		While !(_cTRB)->(Eof() ) //TRBENT->( Eof() )

			If (_cTRB)->( Recno() ) != nReg
				(_cTRB)->(DBAppend()) //RecLock( (_cTRB), .F. )
					(_cTRB)->A2_OK := Space(2)
				(_cTRB)->(DBCommit()) //MsUnLock()
			EndIf

			(_cTRB)->( dbSkip() )
		EndDo

		(_cTRB)->( dbGoto( nReg ) )

	EndIf

	oBrwTrb:oBrowse:Refresh()

Return

//--------------------------------------------------------------------
// Função para validar que exista somente um fornecedor marcado
//--------------------------------------------------------------------
Static Function SXSF_036()

	Local _lOk  := .F.
	Local _nReg := (_cTRB)->( Recno() ) //TRBENT->( Recno() )
	Local _nSel := 0

	//DbSelectArea("TRBENT")
	//dbGoTop()

	DbSelectArea(_cTRB)
	(_cTRB)->(DbGoTop())

	While !(_cTRB)->( Eof() )
		If !Empty( (_cTRB)->A2_OK )
			_nSel++
		EndIf
		(_cTRB)->( dbSkip() )
	End

	If _nSel == 0
		MsgAlert("Nenhum fornecedor selecionado!")
	ElseIf _nSel > 1
		MsgAlert("Selecionar apenas um fornecedor!")
	Else
		_lOk := ( _nSel == 1 )
	EndIf

	(_cTRB)->( dbGoTo( _nReg ) )

	oBrwTrb:oBrowse:Refresh()

Return _lOk


//---------------------------------------------------------------
// Verificar se XML já está importado para a tabela de xmls
//---------------------------------------------------------------
Static Function SXSF_037( cChave )

	Local cQuery := ""
	Local cAlias := ""

	// Pesquisa na tabela de notas de entrada
	cQuery := "SELECT COUNT(ZX1_CHVNFE) AS TOT FROM " + RetSqlName("ZX1")
	cQuery += " WHERE ZX1_FILIAL  = '"+ xFilial("ZX1") +"'"
	cQuery += "   AND ZX1_CHVNFE  = '"+ cChave +"'"
	cQuery += " AND D_E_L_E_T_ = ' ' "

	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
	_lOk := (cAlias)->TOT == 0
	(cAlias)->( DbCloseArea() )

Return( _lOk )


//-------------------------------------------------------------------
// Abre a janela com os itens para associar o pedido de compras
//-------------------------------------------------------------------
User Function SXUF_013()

	Local oSize
	Local aDimen := {}
	Local aCols  := {}
	Local aHead  := {}
	Local aButt  := {}
	Local aStru  := {}
	Local nOpcA  := 0
	Local nItem  := 0
	Local _nP    := 0
	Local _nPPc  := 0
	Local _nPPIt := 0
	Local cAlias := "ZX2TMP"

	Private oGetDad
	Private _cAliasX3 := GetNextAlias()

	If ZX1->ZX1_TPDOC == "CTE" .And. ZX1->ZX1_TIPO == "C"
		MsgAlert("Pedido de compras apenas para NF-e ou CT-e de saída")
		Return
	EndIf

	If !IsInCallStack("U_SXSF_027") // Se não foi chamado automaticamente pela importação
		If ZX1->ZX1_STATUS == "9"
			MsgAlert("Documento cancelado no Sefaz")
			Return( .F. )
		ElseIf ZX1->ZX1_STATUS == "8"
			MsgAlert("Esta nota já foi recusada, não pode mais ser alterada")
			Return( .F. )
		ElseIf ZX1->ZX1_STATUS == "2"
			MsgAlert("Esta nota já foi classificada")
			Return( .F. )
		EndIf
	EndIf

	SetKey( VK_F5, { || SXSF_040(0) } )
	SetKey( VK_F6, { || SXSF_040(1) } )
	SetKey( VK_F9, { || DUPLITEM() } )

	aAdd( aButt, { "PEDIDO", {|| SXSF_040(0) }, "F5 - Pedido de Compra" } )
	aAdd( aButt, { "PEDIDO", {|| SXSF_040(1) }, "F6 - Item Pedido Compra" } )
	aAdd( aButt, { "PEDIDO", {|| SXSF_041(0) }, "Limpar Pedidos" } )
	aAdd( aButt, { "PEDIDO", {|| SXSF_041(1) }, "Limpar Pedido Item" } )
	aAdd( aButt, { "PEDIDO", {|| DUPLITEM()  }, "F9 - Duplicar Item" } )

	OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cAliasX3,"SX3",Nil,.F.)
	
	lOpen := Select(_cAliasX3) > 0
	
	If (lOpen)
		dbSelectArea(_cAliasX3)
		(_cAliasX3)->(dbSetOrder(1))
		(_cAliasX3)->(dbSeek("ZX2"))
		While ( !(_cAliasX3)->(Eof()) .And. (_cAliasX3)->X3_ARQUIVO == "ZX2" )
			if (X3USO((_cAliasX3)->X3_USADO) .AND. cNivel >= (_cAliasX3)->X3_NIVEL .And. !AllTrim((_cAliasX3)->X3_CAMPO) $ "ZX2_FILIAL#ZX2_CHVNFE")
			   aAdd(aHead,{ Alltrim((_cAliasX3)->X3_TITULO),(_cAliasX3)->X3_CAMPO,(_cAliasX3)->X3_PICTURE,(_cAliasX3)->X3_TAMANHO,(_cAliasX3)->X3_DECIMAL,(_cAliasX3)->X3_VALID,;
			   (_cAliasX3)->X3_USADO,(_cAliasX3)->X3_TIPO,(_cAliasX3)->X3_F3,(_cAliasX3)->X3_CONTEXT})
			endif
		(_cAliasX3)->(DBSkip())
		EndDo
	Endif
	(_cAliasX3)->(dbCloseArea())
	
	ADHeadRec( "ZX2", aHead ) // Campos adicionais

	_nPPc  := aScan( aHead, {|o| AllTrim( o[2] ) == "ZX2_PC" } )
	_nPPIt := aScan( aHead, {|o| AllTrim( o[2] ) == "ZX2_ITEMPC" } )
	_nPPrd := aScan( aHead, {|o| AllTrim( o[2] ) == "ZX2_COD" } )
	_nPItm := aScan( aHead, {|o| AllTrim( o[2] ) == "ZX2_ITEM" } )

	aStru  := ZX2->( dbStruct() )

	cQuery := "SELECT ZX2.*,ZX2.R_E_C_N_O_ ZX2RECNO "
	cQuery += "FROM "+RetSqlName("ZX2")+" ZX2 "
	cQuery += "WHERE ZX2_FILIAL='"+xFilial("ZX2")+"' AND "
	cQuery += "ZX2.ZX2_CHVNFE='"+ZX1->ZX1_CHVNFE+"' AND "
	cQuery += "ZX2.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY ZX2.ZX2_ITEM "

	cQuery := ChangeQuery(cQuery)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.T.,.T.)
	For nX := 1 To Len(aStru)
		If aStru[ nX, 2 ] <> "C"
			TcSetField( cAlias, aStru[ nX, 1 ], aStru[ nX, 2 ], aStru[ nX, 3 ], aStru[ nX, 4 ] )
		EndIf
	Next nX

	dbSelectArea(cAlias)
	While (cAlias)->( !Eof() )

		nItem++
		aAdd( aCols, Array( Len( aHead ) + 1 ) )

		For nY := 1 to Len( aHead )
			If IsHeadRec( aHead[ nY ][ 2 ] )
				aCols[ nItem ][ nY ] := (cAlias)->ZX2RECNO
			ElseIf IsHeadAlias( aHead[ nY ][ 2 ] )
				aCols[ nItem ][ nY ] := "ZX2"
			ElseIf ( aHead[ nY ][ 10 ] <> "V" )
				aCols[ nItem ][ nY ] := (cAlias)->( FieldGet( FieldPos( aHead[nY][2] ) ) )
			Else
				aCols[ nItem ][ nY ] := (cAlias)->( CriaVar( aHead[nY][2] ) )
			EndIf
			aCols[ nItem ][ Len( aHead ) + 1 ] := .F.
		Next nY
		(cAlias)->( dbSkip() )
	EndDo
	(cAlias)->( dbCloseArea() )

	oSize := FwDefSize():New()
	oSize:aMargins  := { 3, 3, 3, 3 }
	oSize:aWorkArea := {000,000, 350, 160 }
	oSize:AddObject( "CAB", 100, 10, .T., .T. )
	oSize:AddObject( "GET", 100, 80, .T., .T. )
	oSize:AddObject( "ROD", 100, 10, .T., .T. )
	oSize:lProp := .T.
	oSize:Process()

	aAdd( aDimen, { oSize:GetDimension("CAB","LININI")+30, oSize:GetDimension("CAB","COLINI"), 0, 0 } )
	aAdd( aDimen, { oSize:GetDimension("GET","LININI")+28, oSize:GetDimension("GET","COLINI"), oSize:GetDimension("GET","LINEND"), oSize:GetDimension("GET","COLEND") } )
	aAdd( aDimen, { oSize:GetDimension("ROD","LININI"), oSize:GetDimension("ROD","COLINI"), 0, 0 } )

	DEFINE MSDIALOG oDlg FROM 000,000 TO 300,700 TITLE "Associar Pedido de Compras aos Itens" Of oMainWnd PIXEL

	@aDimen[1][1],aDimen[1][2]    SAY "Documento: "+ ZX1->ZX1_DOC +"/"+ ZX1->ZX1_SERIE Of oDlg PIXEL SIZE 90 ,9
	@aDimen[1][1],aDimen[1][2]+120 SAY Posicione("SA2", 1, xFilial("SA2")+ZX1->ZX1_CLIFOR+ZX1->ZX1_LOJA,"A2_NREDUZ") Of oDlg PIXEL SIZE 250,009

	oGetDad := MsNewGetDados():New(aDimen[2][1],aDimen[2][2],aDimen[2][3],aDimen[2][4],0,"","","",,,Len(aCols),,,,oDlg,aHead,aCols)

	ACTIVATE MSDIALOG oDlg CENTERED ON INIT EnchoiceBar( oDlg,{|| Iif( oGetDad:TudoOk(),( nOpcA:=1,oDlg:End() ),( nOpcA:=0 ) ) },{|| oDlg:End() },,aButt )

	If nOpcA == 1

		For _nP := 1 To Len( aCols )

			If _nPPc > 0 .And. _nPPIt > 0 .And. _nPPrd > 0 .And. _nPItm > 0 .And. !Empty( oGetDad:aCols[ _nP, _nPPc ] ) .And. !Empty( oGetDad:aCols[ _nP, _nPPIt ] )

				ZX2->( dbSetOrder(3) )
				If ZX2->( dbSeek( xFilial("ZX2") + ZX1->ZX1_CHVNFE + oGetDad:aCols[ _nP, _nPPrd ] + oGetDad:aCols[ _nP, _nPItm ] ) )
					ZX2->( RecLock( "ZX2", .F. ) )
						ZX2->ZX2_PC     := oGetDad:aCols[ _nP, _nPPc ]
						ZX2->ZX2_ITEMPC := oGetDad:aCols[ _nP, _nPPIt ]
					ZX2->( MsUnLock() )
                EndIf
			EndIf
		Next
	EndIf

	SetKey( VK_F5, Nil )
	SetKey( VK_F6, Nil )
	SetKey( VK_F9, Nil )

Return

//----------------------------------------------
// Seleciona o pedido de compras
//----------------------------------------------
Static Function SXSF_040( nOp )

	Local cQuery    := ""
	Local _nOpca    := 0
	Local nItem     := 0
	Local bOk       := { || _nOpca:=1, _lRetorno:=.T., oDlgF5:End() }
	Local bCancel   := { || _nOpca:=0, oDlgF5:End() }
	Local aButtons  := {}
	Local _aStruTrb := {}  //Estrutura do temporario
	Local _aBrowse  := {}  //Array do Browse para seleção dos pedidos
	Local cMarca    := ""  //Variaveis para o MsSelect
	Local _cArqEmp  := ""  //Arquivo temporário
	Local lInverte  := .F. //Variaveis para o MsSelect
	Local _lRetorno := .F.
	Local nPIte     := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_ITEM" } )
	Local nPPco     := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_PC" } )
	Local nPPit     := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_ITEMPC" } )

	Private oBrwF5 //Objeto do MsSelect
	Private oDlgF5
	Private _cTRB2	:= GetNextAlias() //Alias Tabela Temporária

	aAdd( aButtons, { "HISTORIC", { || SXSF_042() }, "Visualizar Pedido", "Visualizar Pedido" , { || .T. } } )

	If nOp == 0

		aAdd( _aStruTrb, { "PC_OK"     , "C", 02 , 0 } )
		aAdd( _aStruTrb, { "PC_NUM"    , "C", TamSX3("C7_NUM" )[1] , 0 } )
		aAdd( _aStruTrb, { "PC_EMISSAO", "D", 08 , 0} )
		aAdd( _aStruTrb, { "PC_COND"   , "C", 03 , 0 } )
		aAdd( _aStruTrb, { "PC_CONTATO", "C", 20 , 0} )
		aAdd( _aStruTrb, { "PC_TOTAL"  , "C", 03 , 0 } )

		aAdd( _aBrowse, { "PC_OK"     , "", ""        } )
		aAdd( _aBrowse, { "PC_NUM"    , "", "Número"  } )
		aAdd( _aBrowse, { "PC_EMISSAO", "", "Emissão" } )
		aAdd( _aBrowse, { "PC_COND"   , "", "Condição"} )
		aAdd( _aBrowse, { "PC_CONTATO", "", "Contato" } )
		// Jorge Alberto - Solutio - 08/07/2019 - Alterado título da coluna de "Itens", para não confundir com o item do PC.
		aAdd( _aBrowse, { "PC_TOTAL"  , "", "Total de Itens do Pedido" } )
	Else

		aAdd( _aStruTrb, { "PC_OK"     , "C", 02                     , 0 , 0 } )
		aAdd( _aStruTrb, { "PC_NUM"    , "C", TamSX3("C7_NUM")[1]    , 0 , 0 } )
		aAdd( _aStruTrb, { "PC_ITEM"   , "C", TamSX3("C7_ITEM")[1]   , 0 , 0 } )
		aAdd( _aStruTrb, { "PC_PRODUTO", "C", TamSX3("C7_PRODUTO")[1], 0 } )
		aAdd( _aStruTrb, { "PC_PRECO"  , "N", TamSX3("C7_PRECO")[1]  , TamSX3("C7_PRECO")[2] , 2 } )
		aAdd( _aStruTrb, { "PC_SALDO"  , "N", TamSX3("C7_QUANT")[1]  , TamSX3("C7_QUANT")[2] , 2 } )
		aAdd( _aStruTrb, { "PC_DATPRF" , "D", 08                     , 0 , 0} )

		aAdd( _aBrowse, { "PC_OK"     , "", ""              } )
		aAdd( _aBrowse, { "PC_NUM"    , "", "Número"        } )
		aAdd( _aBrowse, { "PC_ITEM"   , "", "Item"          } )
		aAdd( _aBrowse, { "PC_PRODUTO", "", "Produto"       } )
		aAdd( _aBrowse, { "PC_PRECO"  , "", "Preço Unit."   } )
		aAdd( _aBrowse, { "PC_SALDO"  , "", "Saldo do Item" } )
		aAdd( _aBrowse, { "PC_DATPRF" , "", "Prev.Entrega"  } )

	EndIf

	/*If Select("TRB") > 0
		TRB->(DbCloseArea())
	Endif
	_cArqEmp := CriaTrab(_aStruTrb)
	dbUseArea(.T.,__LocalDriver,_cArqEmp,"TRB")*/
	oTempT2 := FWTemporaryTable():New( _cTRB2, _aStruTrb  )
    oTempT2:AddIndex("01", {"PC_NUM"} )
    oTempT2:Create()


	If nOp == 1
		// Jorge Alberto - Solutio - 10/07/2019 - Para alguns pedidos o campo C7_QTDACLA está negativo,
		// fazendo assim o sistema trocar o sinal para positivo e mostrar na tela.
		// ( C7_QUANT - C7_QUJE - C7_QTDACLA )
		cQuery := "SELECT C7_NUM, C7_ITEM, C7_PRODUTO, C7_PRECO, CASE WHEN C7_QTDACLA < 0 THEN C7_QUANT - C7_QUJE ELSE C7_QUANT - C7_QUJE - C7_QTDACLA END SALDO, C7_DATPRF "
    Else
	    cQuery := "SELECT C7_NUM, C7_EMISSAO, C7_COND, C7_CONTATO, COUNT(*) TOTAL "
    EndIf
    cQuery += " FROM "+ RetSqlName("SC7")
	cQuery += " WHERE "
	cQuery += " C7_FORNECE = '"+ ZX1->ZX1_CLIFOR +"' AND C7_LOJA = '"+ ZX1->ZX1_LOJA +"' AND "
	// Jorge Alberto - Solutio - 10/07/2019 - Para alguns pedidos o campo C7_QTDACLA está negativo,
	// fazendo assim o sistema trocar o sinal para positivo e mostrar na tela.
	// cQuery += " ( C7_QUANT - C7_QUJE - C7_QTDACLA ) > 0 AND "
	cQuery += " CASE WHEN C7_QTDACLA < 0 THEN C7_QUANT - C7_QUJE ELSE C7_QUANT - C7_QUJE - C7_QTDACLA END > 0 AND "
	cQuery += " C7_RESIDUO = ' ' AND "
	cQuery += " C7_TPOP <> 'P' AND "
	cQuery += " C7_FILIAL = '"+ xFilial("SC7") +"' AND "
	If nOp == 1
		cQuery += " C7_PRODUTO = '"+ oGetDad:aCols[ oGetDad:nAt ][ aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_COD" } ) ] +"' AND "
	EndIf
	cQuery += " D_E_L_E_T_ = ' ' "
	If nOp != 1
		cQuery += "GROUP BY C7_NUM, C7_EMISSAO, C7_COND, C7_CONTATO "
	EndIf
	If nOp == 1
		cQuery += "ORDER BY C7_DATPRF "
    Else
		cQuery += "ORDER BY C7_NUM "
    EndIf

	TCQuery cQuery new Alias ( cAlias:=GetNextAlias() )

	If (cAlias)->( Eof() )
		If nOp == 0
			Aviso( "Atenção", "Não há pedidos com saldo para este fornecedor!", { "Ok" } )
		Else
			Aviso( "Atenção", "Não há pedidos com saldo para este fornecedor e produto!", { "Ok" } )
		EndIf
	Else

		While (cAlias)->( !Eof() )

			(_cTRB2)->(DBAppend()) //RecLock("TRB",.T.)

			If nOp == 0

				(_cTRB2)->PC_OK      := " "
				(_cTRB2)->PC_NUM     := (cAlias)->C7_NUM
				(_cTRB2)->PC_EMISSAO := StoD( (cAlias)->C7_EMISSAO )
				(_cTRB2)->PC_COND    := (cAlias)->C7_COND
				(_cTRB2)->PC_CONTATO := (cAlias)->C7_CONTATO
				(_cTRB2)->PC_TOTAL   := StrZero( (cAlias)->TOTAL, 3 )

			Else

				(_cTRB2)->PC_OK      := " "
				(_cTRB2)->PC_NUM     := (cAlias)->C7_NUM
				(_cTRB2)->PC_ITEM    := (cAlias)->C7_ITEM
				(_cTRB2)->PC_PRODUTO := (cAlias)->C7_PRODUTO
				(_cTRB2)->PC_PRECO   := (cAlias)->C7_PRECO
				(_cTRB2)->PC_SALDO   := (cAlias)->SALDO
				(_cTRB2)->PC_DATPRF  := StoD( (cAlias)->C7_DATPRF )

			EndIf
			(_cTRB2)->(DBCommit()) //MsUnlock()

			(cAlias)->( DbSkip() )

		Enddo

		cMarca := GetMark(.F.,_cTRB2,"PC_OK")  //GetMark(.F.,"TRB","PC_OK") // Define a marca para o campo

		Define MsDialog oDlgF5 Title Iif( nOp == 1, "Item do ", "" ) +"Pedido de Compra" From C(001),C(001) To C(300),C(600) Pixel

			@ 2.5,002 SAY OemToAnsi("Selecione o pedido que deseja utilizar")
			oBrwF5 := MsSelect():New( _cTRB2,"PC_OK","",_aBrowse,@lInverte,@cMarca,{042,001,190,380} )
			oBrwF5:bMark := { || Nil }
			Eval( oBrwF5:oBrowse:bGoTop )
			oBrwF5:oBrowse:Refresh()

		Activate MsDialog oDlgF5 On Init ( EnchoiceBar( oDlgF5, bOk, bCancel,, aButtons ) ) Centered Valid _lRetorno

		(_cTRB2)->( DbGotop() )

	EndIf

	(cAlias)->(DbCloseArea())

	If _nOpca == 1

		//dbSelectArea("TRB")
		//dbGoTop()
		dbSelectArea(_cTRB2)
		(_cTRB2)->(dbGoTop())
		Do While (_cTRB2)->( !Eof() )

			If !Empty( (_cTRB2)->PC_OK )//se usuario marcou o registro

				aArea1 := GetArea()

				dbSelectArea("SC7")
				dbSetOrder(1)
				If dbSeek( xFilial("SC7") + (_cTRB2)->PC_NUM + Iif( nOp == 1, (_cTRB2)->PC_ITEM, "" ) )

					If nOp != 1

						While !SC7->( Eof() ) .And. SC7->C7_FILIAL + SC7->C7_NUM == xFilial("SC7") + (_cTRB2)->PC_NUM

								aItpc := SXSF_043( oGetDad:aCols, oGetDad:aHeader )

								If aItpc[ 1 ] .And. ( SC7->C7_QUANT - SC7->C7_QUJE - SC7->C7_QTDACLA ) > 0 .And. SC7->C7_RESIDUO = ' '

									nItem := aScan( oGetDad:aCols,{|o| AllTrim( o[ nPIte ] ) == aItpc[ 2 ] } )

									If Empty( oGetDad:aCols[ nItem ][ nPPco ] )
										oGetDad:aCols[ nItem ][ nPPco ] := SC7->C7_NUM
										oGetDad:aCols[ nItem ][ nPPit ] := SC7->C7_ITEM
									EndIf

								EndIf

								oGetDad:Refresh() // Atualiza o browse dos itens

							SC7->( dbSkip() )
						End
					Else

						If ( SC7->C7_QUANT - SC7->C7_QUJE - SC7->C7_QTDACLA ) > 0 .And. SC7->C7_RESIDUO = ' '

							oGetDad:aCols[ oGetDad:nAt ][ nPPco ] := SC7->C7_NUM
							oGetDad:aCols[ oGetDad:nAt ][ nPPit ] := SC7->C7_ITEM

						EndIf

						oGetDad:Refresh() // Atualiza o browse dos itens

					EndIf
				EndIf

				RestArea( aArea1 )

			EndIf

			(_cTRB2)->( DbSkip() )

		EndDo

	Endif

	/*If Select("TRB") > 0
		DbSelectArea("TRB")
		DbCloseArea()
		fErase( _cArqEmp + OrdBagExt() )
	Endif*/
	If (Select(_cTRB2) > 0)
		oTempT2:Delete()
	EndIf

Return

//--------------------------------------------------------------------------------------
// Verifica a cada item do pedido selecionado, se existe produto correspondente na nota
//--------------------------------------------------------------------------------------
Static Function SXSF_043( aProdutos, aCabec )

	Local _lRet := .F.
	Local _cIte := ""
	Local nPIte := aScan( aCabec, { |o| AllTrim( o[2] ) == "ZX2_ITEM" } )
	Local nPPro := aScan( aCabec, { |o| AllTrim( o[2] ) == "ZX2_COD" } )

	For nX := 1 To Len( aProdutos )
		If AllTrim( aProdutos[ nX, nPPro ] ) == AllTrim( SC7->C7_PRODUTO )
			_lRet := .T.
			_cIte := aProdutos[ nX, nPIte ]
			Exit
		EndIf
	Next

Return { _lRet, _cIte }

//---------------------------------------------------------------------------
// Função que vizualiza o pedido de compras na caixa de seleção de pedidos
//---------------------------------------------------------------------------
Static Function SXSF_042()

	Local aArea := GetArea()

	dbSelectArea("SC7")
	dbSetOrder(1)
	If dbSeek( xFilial("SC7") + (_cTRB2)->PC_NUM )
		Mata120( 1, Nil,, 2, .T. )
	Else
		MsgAlert("Não foi possível encontrar o pedido solicitado para visualização!")
	EndIf

	RestArea( aArea )

	SetKey( VK_F5, { || SXSF_040(0) } )
	SetKey( VK_F6, { || SXSF_040(1) } )
	SetKey( VK_F9, { || DUPLITEM() } )

Return

//-------------------------------------------------------------------
// Função para efetuar o cadastro automático de fornecedor/cliente
//-------------------------------------------------------------------
Static Function SXSF_038( cTipEnt )

	Local aArea
	Local PARAMIXB2 := 3
	Local PARAMIXB1 := {}
	Local aButtons	:= {} // Array de botoes do EnchoiceBar
	Local aAcho		:= {}
	Local aCpos		:= {}
	Local aEdit     := {}
	Local bOK       := {|| Iif( A020TudoOk(),( nOpt := 1, oDlg:End() ), Nil ) }
	Local bCancel   := {|| nOpt := 0, Iif( MsgYesNo("Se cancelar esta tela, o XML atual não será importado!"+CHR(13)+CHR(10)+"Tem certeza que deseja sair?"), oDlg:End(), Nil ) }
	Local cCod      := ""
	Local cTipo     := "J"
	Local cQuery    := cAliasCad := ""
	Local cEntidade := Iif( cTipEnt == "F", "SA2", "SA1" )
	Local cLoja     := StrZero( 1, TamSX3(Iif(cTipEnt=="F","A2_LOJA","A1_LOJA"))[1] )
	Local nLoops    := nOptF := 0
	Local _lRet     := lLoop := .T.
	Local cCnpj     := oEmitente:_CNPJ:TEXT
	Local cNome     := PadR( oEmitente:_XNOME:TEXT, TamSX3(Iif(cTipEnt=="F","A2_NOME","A1_NOME"))[1] )
	Local cNRed     := PadR( Iif( Type("oEmitente:_XFANT:TEXT") <> "U", oEmitente:_XFANT:TEXT, oEmitente:_XNOME:TEXT ), TamSX3(Iif(cTipEnt=="F","A2_NREDUZ","A1_NREDUZ"))[1] )
	Local cEnd      := PadR( AllTrim( oEmitente:_ENDEREMIT:_XLGR:TEXT ), TamSX3(Iif(cTipEnt=="F","A2_END","A1_END"))[1] )
	Local cCep      := PadR( oEmitente:_ENDEREMIT:_CEP:TEXT, TamSX3(Iif(cTipEnt=="F","A2_CEP","A1_CEP"))[1] )
	Local cBairro   := PadR( oEmitente:_ENDEREMIT:_XBAIRRO:TEXT, TamSX3(Iif(cTipEnt=="F","A2_BAIRRO","A1_BAIRRO"))[1] )
	Local cEst      := oEmitente:_ENDEREMIT:_UF:TEXT
	Local cMun      := PadR( oEmitente:_ENDEREMIT:_XMUN:TEXT, TamSX3(Iif(cTipEnt=="F","A2_MUN","A1_MUN"))[1] )
	Local cMunIbge  := SubStr( oEmitente:_ENDEREMIT:_CMUN:TEXT, 3, 5 )
	Local cTel      := PadR( Iif( Type("oEmitente:_ENDEREMIT:_FONE") <> "U", oEmitente:_ENDEREMIT:_FONE:TEXT, " " ), TamSX3(Iif(cTipEnt=="F","A2_TEL","A1_TEL"))[1] )
	Local cInscr    := PadR( oEmitente:_IE:TEXT, TamSX3(Iif(cTipEnt=="F","A2_INSCR","A1_INSCR"))[1] )
	Local cPais     := Iif( Type("oEmitente:_ENDEREMIT:_CPAIS:TEXT") <> "U", oEmitente:_ENDEREMIT:_CPAIS:TEXT, "1058" )
	Local nOpt      := 0
	Local oEnChoice
	Local oSize

	Private oDlg
	Private Inclui      := .T.
	Private lMsErroAuto := .F.
	Private lCGCValido  := .F.
	Private aCmps       := {}
	Private LINTLOX     := .F.
	Private _cSX32		:= GetNextAlias()

	aArea := GetArea()

	// Define o código a ser utilizado
	If cTipEnt == "F"
		cQuery := "SELECT MAX(A2_COD) CODIGO FROM "+ RetSqlName("SA2") +" WHERE A2_FILIAL = '"+ xFilial("SA2") +"' AND A2_COD <= '"+ cCodFMax +"' "
	Else
		cQuery := "SELECT MAX(A1_COD) CODIGO FROM "+ RetSqlName("SA1") +" WHERE A1_FILIAL = '"+ xFilial("SA1") +"' AND A1_COD <= '"+ cCodCMax +"' "
	Endif
	TCQuery cQuery New Alias ( cAliasCad := GetNextAlias() )
	cCod := (cAliasCad)->CODIGO
	(cAliasCad)->( DbCloseArea() )

	dbSelectArea( cEntidade )
	dbSetOrder(1)
	While lLoop
	    If dbSeek( xFilial( cEntidade ) + cCod )
			nLoops++
			cCod := Soma1( cCod )
		Else
			lLoop := .F.
		EndIf
		If lLoop .And. nLoops == 100 // Tento encontrar 100 códigos que não existam e que estejam na sequencia
			lLoop := .F.
			cCod := Space(6)
		EndIf
	End

	RestArea( aArea )

	If cTipEnt == "F"
		aEdit := {"A2_COD","A2_LOJA","A2_NOME","A2_NREDUZ","A2_END","A2_EST","A2_MUN","A2_COD_MUN","A2_CEP","A2_BAIRRO","A2_CGC","A2_TIPO","A2_PAIS","A2_CODPAIS","A2_TEL","A2_INSCR"}
	Else
		aEdit := {"A1_COD","A1_LOJA","A1_NOME","A1_NREDUZ","A1_END","A1_EST","A1_MUN","A1_COD_MUN","A1_CEP","A1_BAIRRO","A1_CGC","A1_TIPO","A1_PAIS","A1_CODPAIS","A1_TEL","A1_INSCR"}
	Endif

	/*dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek(cEntidade)

	While !SX3->( Eof() ) .And. SX3->X3_ARQUIVO == cEntidade

		If X3Usado( SX3->X3_CAMPO )

			aAdd( aAcho, SX3->X3_CAMPO )

			If X3Obrigat( SX3->X3_CAMPO ) .Or. aScan( aEdit, {|o| o == AllTrim( SX3->X3_CAMPO ) } ) > 0
				aAdd( aCpos, SX3->X3_CAMPO )
			EndIf

		EndIf

		SX3->( dbSkip() )
	End*/

	///////////////////////////
	OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX32,"SX3",Nil,.F.)
	lOpen := Select(_cSX32) > 0
	if (lOpen)
		dbSelectArea(_cSX32)
		(_cSX32)->(dbSetOrder(1))
		(_cSX32)->(dbSeek(cEntidade))
		While ( !(_cSX32)->(Eof()) .And. (_cSX32)->X3_ARQUIVO == cEntidade )

			If X3Usado( (_cSX32)->X3_CAMPO )

				aAdd( aAcho, (_cSX32)->X3_CAMPO )

				If X3Obrigat( (_cSX32)->X3_CAMPO ) .Or. aScan( aEdit, {|o| o == AllTrim( (_cSX32)->X3_CAMPO ) } ) > 0
					aAdd( aCpos, (_cSX32)->X3_CAMPO )
				EndIf

			EndIf

		(_cSX32)->(DBSkip())
		EndDo
	endif
	(_cSX32)->(dbCloseArea())
	//////////////////////////


	oSize := FwDefSize():New() 						//Criação de objeto para tamanhos pre definidos
	oSize:AddObject( "MGET", 090, 090, .T., .T. )	//Criação do tamanho do MsMGet
	oSize:lProp := .T.								//Variavel de valor proporcional
	oSize:Process() 								//Processamento da proporção dos tamanhos

    DEFINE MSDIALOG oDlg TITLE "Cadastrar "+ Iif( cTipEnt=="F"," fornecedor"," cliente" ) FROM oSize:aWindSize[1],oSize:aWindSize[2] TO oSize:aWindSize[3],oSize:aWindSize[4] PIXEL

	    dbselectarea(cEntidade)
		RegToMemory( cEntidade, .T.)

		oEnChoice:= MsMGet():New( 	cEntidade, 0, 3, , , ,aAcho , ;
									{	oSize:GetDimension("MGET","LININI"),;
										oSize:GetDimension("MGET","COLINI"),;
										oSize:GetDimension("MGET","LINEND"),;
										oSize:GetDimension("MGET","COLEND")},;
										aCpos, 1, , , ,oDlg, .F., .T. )

		For nX := 1 To Len( aCpos )

			Do Case
				Case "_COD" $ aCpos[ nX ].And.!"_COD_MUN" $ aCpos[ nX ].And.!"_CODPAIS" $ aCpos[ nX ]
					&("M->"+ aCpos[ nX ] ) := cCod
				Case "_LOJA" $ aCpos[ nX ]
					&("M->"+ aCpos[ nX ] ) := cLoja
				Case "_NOME" $ aCpos[ nX ]
					&("M->"+ aCpos[ nX ] ) := cNome
				Case "_NREDUZ" $ aCpos[ nX ]
					&("M->"+ aCpos[ nX ] ) := cNRed
				Case "_END" $ aCpos[ nX ] .And. !"_NR_END" $ aCpos[ nX ]
					&("M->"+ aCpos[ nX ] ) := AllTrim( cEnd )
				Case "_NR_END" $ aCpos[ nX ]
					&("M->"+ aCpos[ nX ] ) := PadR( AllTrim( oEmitente:_ENDEREMIT:_NRO:TEXT ), 6 )
				Case "_EST" $ aCpos[ nX ]
					&("M->"+ aCpos[ nX ] ) := cEst
				Case "_MUN" $ aCpos[ nX ].And.!"_COD_MUN" $ aCpos[ nX ]
					&("M->"+ aCpos[ nX ] ) := AllTrim( cMun )
				Case "_COD_MUN" $ aCpos[ nX ]
					&("M->"+ aCpos[ nX ] ) := cMunIbge
				Case "_CEP" $ aCpos[ nX ]
					&("M->"+ aCpos[ nX ] ) := cCep
				Case "_BAIRRO" $ aCpos[ nX ]
					&("M->"+ aCpos[ nX ] ) := AllTrim( cBairro )
				Case "_CGC" $ aCpos[ nX ]
					&("M->"+ aCpos[ nX ] ) := cCnpj
				Case "_TIPO" $ aCpos[ nX ]
					&("M->"+ aCpos[ nX ] ) := cTipo
				Case "_PAIS" $ aCpos[ nX ].And.!"_CODPAIS" $ aCpos[ nX ]
					&("M->"+ aCpos[ nX ] ) := Left( cPais, 3 )
				Case "_CODPAIS" $ aCpos[ nX ]
					&("M->"+ aCpos[ nX ] ) := "0"+ cPais
				Case "_TEL" $ aCpos[ nX ]
					&("M->"+ aCpos[ nX ] ) := AllTrim( cTel )
				Case "_INSCR" $ aCpos[ nX ]
					&("M->"+ aCpos[ nX ] ) := AllTrim( cInscr )
				Case "_NATUREZ" $ aCpos[ nX ]
					&("M->"+ aCpos[ nX ] ) := "204001    "
				Case "_CONTA" $ aCpos[ nX ]
					&("M->"+ aCpos[ nX ] ) := "211000001           "
				Case "_TPESSOA" $ aCpos[ nX ]
					&("M->"+ aCpos[ nX ] ) := "OS"
				Case "_CONTRIB" $ aCpos[ nX ]
					&("M->"+ aCpos[ nX ] ) := "1"
			EndCase

		Next

	ACTIVATE MSDIALOG oDlg ON INIT Eval( { || EnchoiceBar( oDlg, bOK, bCancel, .F., aButtons ) } )

	If nOpt == 1

		Begin Transaction

			PARAMIXB1 := {}

			For nX := 1 To Len( aCpos )
				aAdd( PARAMIXB1, { aCpos[ nX ], &("M->"+ aCpos[ nX ] ), Nil } )
			Next

			If cTipEnt == "F"
				MSExecAuto( { | x, y | MATA020( x, y ) }, PARAMIXB1, PARAMIXB2 )
			Else
				MSExecAuto( { | x, y | MATA030( x, y ) }, PARAMIXB1, PARAMIXB2 )
			EndIf

			_lRet := !lMsErroAuto
			If lMsErroAuto
				If MsgYesNo("Ocorreu um problema na execução automática. Deseja ver o erro?")
					MostraErro()
				EndIf
			EndIf

		End Transaction

	Else
		_lRet := .F.
	EndIf

Return _lRet


//----------------------------------------------------------------------------
// Função que valida o código + loja no cadastro de fornecedores/clientes
//----------------------------------------------------------------------------
Static Function SXSF_039( cChave1, cChave2, cTipEnt )

    Local _lRet  := .T.
    Local cQuery := ""
    Local nQtd   := 0

	If Empty( cChave1 ) .Or. Empty( cChave2 )
		_lRet := .F.
		 MsgAlert("Código ou Loja em branco!")
	Else
		If cTipEnt == "F"
			cQuery := "SELECT COUNT(*) TOT FROM "+ RetSqlName("SA2") +" WHERE "+ Iif( lORACLE, "CONCAT(A2_COD, A2_LOJA)", "A2_COD + A2_LOJA") +" = '"+ cChave1 + cChave2 +"' AND A2_FILIAL = '"+ xFilial("SA2") +"' AND D_E_L_E_T_ = ' '"
		Else
			cQuery := "SELECT COUNT(*) TOT FROM "+ RetSqlName("SA1") +" WHERE "+ Iif( lORACLE, "CONCAT(A1_COD, A1_LOJA)", "A1_COD + A1_LOJA") +" = '"+ cChave1 + cChave2 +"' AND A1_FILIAL = '"+ xFilial("SA1") +"' AND D_E_L_E_T_ = ' '"
		EndIf

		TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
		nQtd := (cAlias)->TOT
		(cAlias)->( DbCloseArea() )

		If nQtd > 0
			_lRet := .F.
			 MsgAlert("Código/Loja informados já existe no cadastro!")
		EndIf
	EndIf

Return _lRet


//----------------------------------------------------------
// Remove um pedido de compras anteriormente associado
//----------------------------------------------------------
Static Function SXSF_041( nTipo )

	Local _nV   := 0
	Local nPPco := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_PC" } )
	Local nPPit := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_ITEMPC" } )

	If nTipo == 1
		oGetDad:aCols[ oGetDad:nAt ][ nPPco ] := Space( Len( SC7->C7_NUM ) )
		oGetDad:aCols[ oGetDad:nAt ][ nPPit ] := Space( Len( SC7->C7_ITEM ) )
	Else
		For _nV := 1 To Len( oGetDad:aCols )
			oGetDad:aCols[ _nV ][ nPPco ] := Space( Len( SC7->C7_NUM ) )
			oGetDad:aCols[ _nV ][ nPPit ] := Space( Len( SC7->C7_ITEM ) )
		Next
	EndIf

	oGetDad:Refresh()

Return


//----------------------------------------------------------
// Faz a avaliação dos produtos sem amarração no SA5/SA7
//----------------------------------------------------------
User Function SXUF_014()

	Local nNoTes := 0
	Local nNoPrd := 0
	Local cQuery := ""
	Local cAlias := ""
	Local cTpNf  := ZX1->ZX1_TIPO

	If ZX1->ZX1_TPDOC == "CTE"
		MsgAlert("Associar produtos apenas para NF-e")
		Return
	EndIf

	If ZX1->ZX1_STATUS == "9"
		MsgAlert("Documento cancelado no Sefaz")
		Return( .F. )
	ElseIf ZX1->ZX1_STATUS == "8"
		MsgAlert("Esta nota já foi recusada, não pode mais ser alterada")
		Return( .F. )
	ElseIf ZX1->ZX1_STATUS == "2"
		MsgAlert("Esta nota já foi classificada")
		Return( .F. )
	EndIf

	cQuery := "SELECT ZX2_COD, ZX2_CODFOR, ZX2_DESCF, R_E_C_N_O_, ZX2_TES FROM "+ RetSqlName("ZX2") +" WHERE ZX2_CHVNFE = '"+ ZX1->ZX1_CHVNFE +"' AND D_E_L_E_T_ = ' '"
	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )

	While !(cAlias)->( Eof() )

		If Empty( (cAlias)->ZX2_COD )

			cCodProd := Space( TamSX3("B1_COD")[1] )

			If !Empty( (cAlias)->ZX2_CODFOR )

				If cTpNf $ "CN"
					SA5->( dbSetOrder(14) )
				Else
					SA7->( dbSetOrder(3) )
				EndIf

				If ( cTpNf $ "CN" .And. SA5->( dbSeek( xFilial("SA5") + ZX1->ZX1_CLIFOR + ZX1->ZX1_LOJA + (cAlias)->ZX2_CODFOR ) ) ) .Or.;
					( cTpNf $ "D" .And. SA7->( dbSeek( xFilial("SA7") + ZX1->ZX1_CLIFOR + ZX1->ZX1_LOJA + (cAlias)->ZX2_CODFOR ) ) )
					// Usa o código cadastrado na tabela SA5 ou SA7
					cCodProd := Iif( cTpNf $ "CN", SA5->A5_PRODUTO, SA7->A7_PRODUTO )
				Else
					// Incluir item no cadastro Produto x Fornecedor (SA5) ou Produto x Cliente (SA7)
					cCodProd := SXSF_030( (cAlias)->ZX2_CODFOR, (cAlias)->ZX2_DESCF, .T., cTpNf )
				EndIf

			EndIf

			If !Empty( cCodProd )
				SB1->( dbSetOrder(1) )
				SB1->( dbSeek( xFilial("SB1") + cCodProd ) )

				ZX2->( dbGoTo( (cAlias)->R_E_C_N_O_ ) )
				ZX2->( RecLock("ZX2",.F.) )
				ZX2->ZX2_COD := cCodProd
				ZX2->ZX2_TES := Iif( Empty( ZX2->ZX2_TES ), SB1->B1_TE, ZX2->ZX2_TES )

				If !Empty( SB1->B1_SEGUM ) .And. SB1->B1_CONV > 0
					ZX2->ZX2_QUANT  := ConvUm( cCodProd, 0, ZX2->ZX2_QUANT, 1 )
					ZX2->ZX2_VUNIT  := Round( ZX2->ZX2_VUNIT / ConvUm( cCodProd, 0, ZX2->ZX2_QUANT, 1 ), TamSX3("ZX2_VUNIT")[2] )
					ZX2->ZX2_UM     := SB1->B1_UM
				EndIf

				ZX2->( MsUnLock() )
			Else
				nNoPrd++
			EndIf

			If Empty( (cAlias)->ZX2_TES )
				nNoTes++
			EndIf

		Else
			If Empty( (cAlias)->ZX2_TES )
				nNoTes++
			EndIf
		EndIf

		(cAlias)->( dbSkip() )
	End

	(cAlias)->( DbCloseArea() )

	// Verifica se pode mudar de status (preenchidos todos os produtos e todos os tipos de entrada)
	cQuery := "SELECT COUNT(*) TOT FROM "+ RetSqlName("ZX2") +" WHERE ZX2_CHVNFE = '"+ ZX1->ZX1_CHVNFE +"' AND D_E_L_E_T_ = ' ' AND ( ZX2_COD = ' ' OR ZX2_TES = ' ' )"
	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )

	ZX1->( RecLock("ZX1",.F.) )
		ZX1->ZX1_STATUS := Iif( (cAlias)->TOT == 0, "0", "3" )
	ZX1->( MsUnLock() )

	(cAlias)->( DbCloseArea() )

Return


//------------------------------
// Recusa de documento fiscal
//------------------------------
User Function SXUF_015()

	If ZX1->ZX1_STATUS $ '2'
		MsgAlert("Documento já foi classificado, não é possível recusar!")
		Return(.F.)
	EndIf

	If MsgYesNo("Tem certeza que quer recusar o documento e manifestar ao Sefaz?")
		// Faz o manifesto de operação não reconhecida
		SXSF_018( {ZX1->ZX1_CHVNFE}, .T. )

		// Atualiza o status do documento
		ZX1->( RecLock( "ZX1", .F. ) )
			ZX1->ZX1_STATUS := "8"
		ZX1->( MsUnLock() )

	EndIf

Return


//-------------------------
// Gera pré-nota de NF-e
//-------------------------
User Function SXUF_011()

	Local cQuery := ""
	Local cAlias := ""

	cQuery := "SELECT R_E_C_N_O_ FROM "+ RetSqlName("ZX1") +" WHERE ZX1_OK = '"+ cMark +"' "

	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )

	If (cAlias)->( Eof() )
		SXSF_046()
	Else
		While !(cAlias)->( Eof() )

			ZX1->( dbGoTo( (cAlias)->R_E_C_N_O_ ) )
			SXSF_046()

			(cAlias)->( dbSkip() )
		End
	EndIf

	(cAlias)->( DbCloseArea() )

//-------------------------
// Gera pré-nota de NF-e
//-------------------------
Static Function SXSF_046()

	Local cTipDoc := ZX1->ZX1_TPDOC  // Tipo de documento (NF-e ou CT-e)
	Local cForCTe := ZX1->ZX1_CLIFOR
	Local cLojCTe := ZX1->ZX1_LOJA
	Local lDevBen := .F. // Se é devolução ou beneficiamento
	Local nItNoPrd:= 0
	Local lNoOk   := .F.
	Local _cErr   := ""
	Local _cWrn   := ""
	Local cTpAmb  := ""
	Local cAlias  := ""
	Local cQuery  := ""
	Local cCodRet := ""
	Local aCabec    := {}
	Local aLinha    := {}
	Local aItens    := {}
	//Local _oXml     := XmlParser( ZX1->ZX1_XML, "_", @_cErr, @_cWrn ) // Crio o objeto XML
	//Local cIdEnt    := SXSF_012() // Retorna o código da Entidade no TSS

	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .F.

	If lGrvBloq .And. ZX1->ZX1_BLOQ $ ("139")
		MsgAlert("Documento não pode ser gerado pois possui divergência!")
		Return(.F.)
	EndIf

	//If !( ZX1->ZX1_STATUS $ "0" ) // Verifica o status
	//	Return(.F.)
	//EndIf

	SF1->( dbSetOrder(8) )
	If SF1->( dbSeek( xFilial("SF1") + ZX1->ZX1_CHVNFE ) )
		MsgAlert("Nota fiscal ou pré nota já foi gerada no sistema!")
		Return(.F.)
	EndIf

	If cTipDoc != "NFE"
		MsgAlert("Documento não é nota fiscal!")
		Return(.F.)
	EndIf

	//cCodRet := SXSF_011( ZX1->ZX1_CHVNFE, cIdEnt, .T. ) // Retorna situação no Sefaz
	cCodRet := SXSF_055( ZX1->ZX1_CHVNFE, .F. ) // Verifica se nota está disponível

	If cCodRet == "101" // Rejeição
		MsgAlert("Este documento está cancelado no Sefaz.")
		RecLock("ZX1",.F.)
			ZX1->ZX1_STATUS := "9"
		MsUnLock()
		Return( .F. )
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
		MsgAlert("Este documento tem itens a serem revisados (produto ou TES), seu status será atualizado")
		ZX1->( RecLock("ZX1",.F.) )
			ZX1->ZX1_STATUS := "3"
		ZX1->( MsUnLock() )
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

		MSExecAuto( { | v,w,x,y,z | MATA140( v,w,x,y,z ) }, aCabec, aItens, 3, .F., 1 )

		If lMsErroAuto
			DisarmTran()
			If MsgYesNo("Ocorreu um problema na execução automática. Deseja ver o erro?")
				MostraErro()
			EndIf
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

//-------------------------------------------------------------------
// Selecionar condição de pagamento dos pedidos de compra informados
//-------------------------------------------------------------------
Static Function SXSF_045( aOptions )

	Local oDlgPgt
	Local aListBox1 := {}
	Local oListBox1
	Local cOptEsc   := Space(3)

	DEFINE MSDIALOG oDlgPgt TITLE "Condições de Pagamento" FROM C(327),C(448) TO C(456),C(869) PIXEL

		@ C(003),C(004) Say "Várias condições de pagamento nos pedidos de compras selecionados. Escolha uma das opções." Size C(203),C(015) COLOR CLR_BLACK PIXEL OF oDlgPgt
		@ C(027),C(162) Button "Cancelar" Size C(037),C(012) Action( cOptEsc := aOptions[ 1, 2 ], oDlgPgt:End() ) PIXEL OF oDlgPgt
		@ C(044),C(162) Button "Selecionar" Size C(037),C(012) Action( cOptEsc := aOptions[ oListBox1:nAt, 2 ], oDlgPgt:End() ) PIXEL OF oDlgPgt

		For nX := 1 To Len( aOptions )
			aAdd( aListBox1, { aOptions[ nX, 1 ], aOptions[ nX, 2 ], Posicione("SE4", 1, xFilial("SE4") + aOptions[ nX, 2 ], "E4_DESCRI") } )
		Next

		@ C(021),C(005) ListBox oListBox1 Fields HEADER "Pedido","Condição","Descrição da condição" Size C(147),C(036) Of oDlgPgt Pixel ColSizes 20,80
		oListBox1:SetArray( aListBox1 )
		oListBox1:bLine := { || { aListBox1[ oListBox1:nAT, 01 ], aListBox1[ oListBox1:nAT, 02 ], aListBox1[ oListBox1:nAT, 03 ] } }

	ACTIVATE MSDIALOG oDlgPgt CENTERED

Return( cOptEsc )

//-------------------------------
// Tela de conferência das TES
//-------------------------------
User Function SXUF_016( cAlias, nReg, nOpcx )

	Local nRet      := 0
	Local _nX       := 0
	Local nPosRec   := 0
	Local nPosTes   := 0
	Local aArea     := GetArea()
	Private oDlg
	Private	aHeader := {}
	Private aCols   := {}

	If ZX1->ZX1_STATUS == "9"
		MsgAlert("Documento cancelado no Sefaz")
		Return( .F. )
	ElseIf ZX1->ZX1_STATUS == "8"
		MsgAlert("Esta nota já foi recusada, não pode mais ser alterada")
		Return( .F. )
	ElseIf ZX1->ZX1_STATUS == "5"
		MsgAlert("Este documento é um resumo, ainda não foi realizado o download do XML")
		Return( .F. )
	ElseIf ZX1->ZX1_STATUS == "2"
		MsgAlert("Esta nota já foi classificada")
		Return( .F. )
	EndIf

	FillGetDados(nOpcx,"ZX2",1,,,,{"ZX2_FILIAL","ZX2_CHVNFE","ZX2_PC","ZX2_ITEMPC"},,,,{|| SXSF_032() },.F.,,,,,,)

	aSize := MsAdvSize()
	aObjects := {}
	AAdd( aObjects, { 100, 050, .t., .t. } )
	AAdd( aObjects, { 100, 050, .t., .t. } )

	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )

	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
		RegToMemory( cAlias, .F., .F. )
		EnChoice( cAlias, nReg, nOpcx, , , , , aPosObj[1],,3,,,)
		MsGetDados():New(aPosObj[2,1],aPosObj[2,2],aPosObj[2,3],aPosObj[2,4],nOpcx,"U_SXUF_017","","",,,,,,,,,,,)
		oDlg:lMaximized := .T.
	ACTIVATE MSDIALOG oDlg On INIT SXSF_033( oDlg,{|| nRet:=1,oDlg:End()},{|| nRet:=0,oDlg:End()},nOpcx)

	If nRet == 1

		nPosRec := aScan( aHeader, {|o| AllTrim(o[2]) == "ZX2_REC_WT" } )
		nPosTes := aScan( aHeader, {|o| AllTrim(o[2]) == "ZX2_TES" } )

		If nPosRec > 0

			For _nX := 1 To Len( aCols )

				ZX2->( dbGoTo( aCols[ _nX, nPosRec ] ) )
				ZX2->( RecLock("ZX2",.F.) )
					ZX2->ZX2_TES := aCols[ _nX, nPosTes ]
				ZX2->( MsUnLock() )

			Next

			RestArea( aArea )

		EndIf

		// Verifica se pode mudar de status (preenchidos todos os produtos e todos os tipos de entrada)
		If ZX1->ZX1_TPDOC == "CTE" .And. ZX1->ZX1_TIPO == "C"
			cQuery := "SELECT COUNT(*) TOT FROM "+ RetSqlName("ZX2") +" WHERE ZX2_CHVNFE = '"+ ZX1->ZX1_CHVNFE +"' AND D_E_L_E_T_ = ' ' AND ZX2_TES = ' ' "
        Else
			cQuery := "SELECT COUNT(*) TOT FROM "+ RetSqlName("ZX2") +" WHERE ZX2_CHVNFE = '"+ ZX1->ZX1_CHVNFE +"' AND D_E_L_E_T_ = ' ' AND ( ZX2_COD = ' ' OR ZX2_TES = ' ' )"
		EndIf
		TCQuery cQuery New Alias ( cAlias := GetNextAlias() )

		ZX1->( RecLock("ZX1",.F.) )
			ZX1->ZX1_STATUS := Iif( (cAlias)->TOT == 0, "0", "3" )
		ZX1->( MsUnLock() )

		(cAlias)->( DbCloseArea() )

	EndIf

Return( nOpcx )

//------------------------------------------------------
// Valida a linha atual da tela de conferência das TES
//------------------------------------------------------
User Function SXUF_017()

	Local nPosTes := 0
	Local lRet    := .T.
	Local aArea   := GetArea()

	nPosTes := aScan( aHeader, {|o| AllTrim(o[2]) == "ZX2_TES" } )

	If nPosTes > 0
		dbSelectArea("SF4")
		dbSetOrder(1)
		If !Empty( aCols[ n, nPosTes ] )
			If !dbSeek( xFilial("SF4") + aCols[ n, nPosTes ] )
				MsgAlert("TES informado não existe no cadastro")
				lRet := .F.
			Else
				If SF4->F4_MSBLQL == "1"
					MsgAlert("TES bloqueado para uso!")
					lRet := .F.
				ElseIf SF4->F4_TIPO != "E"
					MsgAlert("TES informado não é de entrada!")
					lRet := .F.
				EndIf
			EndIf
		Else
			MsgAlert("Informar a TES no item "+ cValToChar(n) )
		EndIf
	EndIf

	RestArea( aArea )

Return( lRet )



//*******************************************************************************
// Job que verifica a situação da nota via chave de acesso da base de XML local
//*******************************************************************************
User Function SXUF_019( aParam )

	Prepare Environment Empresa aParam[01] Filial aParam[02] Modulo "COM" tables "ZX1","SX6"

	Conout( "Rotina SXUF_019()" )
	Conout(	"Empresa logada: " + aParam[01] )
	Conout( "Filial logada: " + aParam[02] )

	Conout( "SXUF_019 - " + DtoC( Date() ) + " - " + Time() + " - Processando verificação de chaves na Sefaz..." )
	SXSF_047()
	Conout( "SXUF_019 - Verificação finalizada!" )

	Reset Environment

Return NIL


//***********************************************************************
// Chamado pelo Job de verificação das chaves de acesso
//***********************************************************************
Static Function SXSF_047()

	Local cQuery  := ""
	Local cAlias  := ""
	Local cIdEnt  := ""
	Local cLinhas := ""
	Local cTab1   := ""
	Local lTss    := .T.
	Local aNfErr  := {}
	Local aRet    := {}
	Local nDias   := SuperGetMv("SOL_XML014",.F., 7 )
	Local cMailTo := SuperGetMv("SOL_XML015",.F., "" )

	If CTIsReady()

		cIdEnt := SXSF_012() // Retorna o código da Entidade no TSS

		If !Empty(cIdEnt)

			cTab1 := "<html><head></head><body><p><b>Verificação Agendada de Notas Fiscais Eletrônicas</b></p><br />"
			cTab1 += "<table width='100%'><tr><th>Nota Fiscal</th><th>Série</th><th>Emissão</th><th>Cli/For</th>"
			cTab1 += "<th>Nome</th><th>Retorno</th><th>Situação</th><th>Chave</th></tr>"

			cQuery := "SELECT F1_FILIAL, F1_CHVNFE, F1_DOC, F1_SERIE, F1_EMISSAO, F1_FORNECE, F1_LOJA "
			cQuery += " FROM "+ RetSqlName("SF1")
			cQuery += " WHERE F1_FILIAL='"+ xFilial("F1") +"' "
			cQuery += " AND D_E_L_E_T_ = ' ' "
			cQuery += " AND F1_EMISSAO > '"+ DtoS( dDataBase - nDias ) +"' "
			cQuery += " AND F1_CHVNFE <> ' ' "

			TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
			(cAlias)->( dbGotop() )

			While !(cAlias)->( Eof() )

				// aRet = [1]Ambiente, [2]Código, [3]Situação
				aRet := SXSF_011( (cAlias)->F1_CHVNFE, cIdEnt, .T., .T. )

				If aRet[1] == 1 .And. aRet[2] != "100"
					cLinhas += "<tr><td>"+ (cAlias)->F1_DOC +"</td>"
					cLinhas += "<td>"+ (cAlias)->F1_SERIE +"</td>"
					cLinhas += "<td>"+ DtoC( StoD( (cAlias)->F1_SERIE ) ) +"</td>"
					cLinhas += "<td>"+ (cAlias)->F1_FORNECE +"/"+(cAlias)->F1_LOJA +"</td>"
					cLinhas += "<td>"+ Posicione("SA2",1,(cAlias)->F1_FILIAL + (cAlias)->F1_FORNECE + (cAlias)->F1_LOJA,"A2_NREDUZ") +"</td>"
					cLinhas += "<td>"+ aRet[2] +"</td>"
					cLinhas += "<td>"+ aRet[3] +"</td>"
					cLinhas += "<td>"+ (cAlias)->F1_CHVNFE +"</td></tr>"
				EndIf

				(cAlias)->( dbSkip() )
			End
			(cAlias)->( dbCloseArea() )

		Else
			lTss := .F.
			cLinhas += "<tr><td>Não foi possivel identificar a entidade no TSS</td></tr>"
		EndIf
	Else
		lTss := .F.
		cLinhas += "<tr><td>O serviço do TSS está indisponível ou não está configurado</td></tr>"
	EndIf

	If !Empty( cLinhas )
		If lTss
			cLinhas := cTab1 + cLinhas +"</table></body></html>"
		Else
			cLinhas := "<html><head></head><body><table width='100%'><tr><th>Problemas na conexão ao TSS</th></tr>"+ cLinhas +"</table></body></html>"
		EndIf

		If !Empty( cMailTo )
			SXSF_048( cLinhas, lTss, cMailTo )
	    EndIf

	EndIf

Return


//*********************************************************
// Faz o envio de e-mail com as notas canceladas no sefaz
//*********************************************************
Static Function SXSF_048( cBody, lTss, cEmailTo )

	Local cServer   := AllTrim( GetMV("MV_RELSERV") )
	Local cAccount  := AllTrim( GetMV("MV_RELACNT") )
	Local cPassword := AllTrim( GetMV("MV_RELPSW")  )
	Local cEmailFrom:= AllTrim( GetMV("MV_RELACNT") )
	Local lAuth     := GetMV("MV_RELAUTH")
	Local cAssunto  := "Schedule Chave Sefaz - "+ Iif( lTss, "Existe(m) nota(s) com problema!", "Problema no TSS" )
	Local cMensagem := ""
	Local lResult   := .F.
	Local cError    := ""
	Local cCRLF     := Chr(13) + Chr(10)

	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

	If lResult .And. lAuth
		lResult := MailAuth( cAccount, cPassword )
		If !lResult
			GET MAIL ERROR cError
			Conout("SXUF_001 - Erro de autenticacao email : "+ cError )
			Return Nil
		Endif
	Else
		If !lResult
			GET MAIL ERROR cError
			Conout("SXUF_001 - Erro de conexao com servidor SMTP : "+ cError )
			Return Nil
		Endif
	EndIf

	If lResult

		SEND MAIL FROM cAccount;
		TO cEmailTo;
		SUBJECT cAssunto;
		BODY cBody;
		RESULT lResult

		If !lResult
			GET MAIL ERROR cError
			Conout("SXUF_001 - Erro no envio do e-mail : "+ cError )
		EndIf

		DISCONNECT SMTP SERVER

	Else
		Conout('SXUF_001 - Ocorreu um erro durante o envio do Email!')
	EndIf

Return


//*****************************************************
// Efetua o download de um arquivo específico
//*****************************************************
User Function SXUF_020()

	Local oDlgKey, oBtnOut, oBtnCon
	Local cChaveNFe := Iif( ZX1->ZX1_STATUS == "5", ZX1->ZX1_CHVNFE, Space(44) )
	Local nOpc      := 0
	Local _lOk      := .F.

	Private oProcReg

	DEFINE MSDIALOG oDlgKey TITLE "Download XML" FROM 0,0 TO 150,305 PIXEL OF GetWndDefault()

	@ 12,008 SAY "Informe a Chave de acesso da NF-e: " PIXEL OF oDlgKey
	@ 20,008 MSGET cChaveNFe SIZE 140,10 PIXEL OF oDlgKey

	@ 46,035 BUTTON oBtnCon PROMPT "&Download" SIZE 38,11 PIXEL ACTION (nOpc:=1,oDlgKey:End())
	@ 46,077 BUTTON oBtnOut PROMPT "&Sair" SIZE 38,11 PIXEL ACTION oDlgKey:End()

	ACTIVATE DIALOG oDlgKey CENTERED

	If nOpc == 1

		ProcRegua( 3 )

		// Faz a manifestação de ciencia
		IncProc("Aguarde, realizando manifestação...")
		SXSF_054( cChaveNFe, '210210', SM0->M0_CGC )

		// Faz o download do arquivo XML da chave lida
		IncProc("Aguarde, realizando download...")
		SXSF_055( cChaveNFe )

		// Importa o arquivo do diretório
		IncProc("Aguarde, importando XML...")
		U_SXUF_009( "", .F. )

	EndIf

Return


//*******************************************************
// Mostra as observações da nota fiscal
//*******************************************************
Static Function SXSF_049( cChave )

	Local cQuery := ""
	Local _cObs  := ""

	cQuery := "SELECT "
	If lORACLE
		cQuery += "SUBSTR(REPLACE(REPLACE(UTL_RAW.CAST_TO_VARCHAR2(DBMS_LOB.SUBSTR(ZX1_XMLAUT,1000,1)),CHR(13),''),CHR(10),''),268,8) ZX1_OBS "
	ElseIf lMSSQL
		cQuery += "ISNULL(CONVERT(VARCHAR(2047),CONVERT(VARBINARY(2047),ZX1_XMLAUT)),'') ZX1_OBS "
	EndIf
	cQuery += " FROM " + RetSqlName("ZX1")
	cQuery += " WHERE ZX1_FILIAL = '"+ xFilial("ZX1") +"'"
	cQuery += "   AND ZX1_CHVNFE = '"+ cChave +"'"
	cQuery += "   AND D_E_L_E_T_ = ' ' "

	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )

	_cObs := (cAlias)->ZX1_OBS

	(cAlias)->( DbCloseArea() )

	Define MsDialog oDlg01 Title "Informacoes complementares da Nota"  From 001,001 TO 200,630 PIXEL

		@ 008,010 Say OemToAnsi("Observacoes") Size 050,008 of oDlg01  PIXEL
		@ 018,010 Get _cObs MEMO Size 300,050 of oDlg01 PIXEL HSCROLL READONLY

		@ 075,270 Button 'Ok' Size 030,010 of oDlg01 PIXEL Action ( oDlg01:End() )

	ACTIVATE MSDIALOG oDlg01 CENTERED

Return


//*************************************
// Exclusão do XML da base de dados
//*************************************
User Function SXUF_021()

	Local cChave := ZX1->ZX1_CHVNFE
	Local cSql   := ""

	MsgAlert("Excluir o XML não afeta o lançamento do documento no sistema."+CHR(13)+CHR(10)+"Este XML pode ser re-importado a qualquer tempo.")

	If MsgYesNo("Tem certeza que quer excluir este XML da base?")

		cSql := "UPDATE "+ RetSqlName("ZX2") +" SET D_E_L_E_T_ = '*' WHERE ZX2_CHVNFE = '"+ cChave +"' AND D_E_L_E_T_ = ' ' "
		TcSqlExec( cSql )

		// Elimina o registro do cabeçalho
		ZX1->( RecLock( "ZX1", .F. ) )
			ZX1->( dbDelete() )
		ZX1->( MsUnLock() )

	EndIf

Return


//********************************************************************************
// Verifica as notas originais dos itens no retorno com nota referenciada
//********************************************************************************
Static Function SXSF_050( aNotRef, aItmRet, aDetPrd )

	Local aNfeRef := {}
	Local _aItens := {}
	Local _cNfRef := "("
	Local _nN     := 0
	Local _nG     := 0
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

	TCQuery cQuery New Alias ( cAlias := GetNextAlias() )
	(cAlias)->( dbGotop() )

	While !(cAlias)->( Eof() )

		aAdd( _aItens, { F2_DOC, F2_SERIE, F2_CLIENTE, F2_LOJA, D2_ITEM, D2_COD, D2_QUANT, D2_PRCVEN, D2_CF } ) // Todos os itens das notas referenciadas

		(cAlias)->( dbSkip() )
	End
	(cAlias)->( dbCloseArea() )

	For _nN := 1 To Len( aDetPrd ) // Percorrer o array de itens do XML

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
				Else
					// Incluir item no cadastro Produto x Fornecedor (SA5) / Cliente (SA7)
					cCodProd := SXSF_030( cCodPrf, cDescPrf, .F., cTipoNf )
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


//*********************************************************************
// Inicializador do browse do campo de nome do fornecedor ou cliente
//*********************************************************************
User Function SXUF_022( cTipo, CCliFor, cLoja )

	Local cNome := Left( Iif( cTipo $ "BD", Posicione("SA1",1,xFilial("SA1")+CCliFor+cLoja,"A1_NREDUZ"), Posicione("SA2",1,xFilial("SA2")+CCliFor+cLoja,"A2_NREDUZ") ), 30 )

Return cNome


//*********************************************************************
// Função que extrai o certificado PEM do PFX
//*********************************************************************
Static Function SXSF_051( cFilePfx, cPass )

	Local cCert  := cWorkDir + AllTrim(SM0->M0_CGC) + "\certs\cert.pem"
	Local cError := ""
	Local lRet

	If !File( cCert )

		lRet := PFXCERT2PEM( cFilePfx, cCert, @cError, cPass )

		If !lRet
			MsgAlert("Não foi possível extrair o certificado PEM")
			cCert := ""
		EndIf

	EndIf

Return cCert

//*********************************************************************
// Função que extrai a chave privada PEM do PFX
//*********************************************************************
Static Function SXSF_052( cFilePfx, cPass )

	Local cKey   := cWorkDir + AllTrim(SM0->M0_CGC) + "\certs\key.pem"
	Local cError := ""
	Local lRet

	If !File( cKey )

		lRet := PFXKEY2PEM( cFilePfx, cKey, @cError, cPass )

		If !lRet
			MsgAlert("Não foi possível extrair a chave privada PEM")
			cKey := ""
		EndIf

	EndIf

Return cKey

//*********************************************************************
// Função que extrai a cadeia de certificação PEM do PFX
//*********************************************************************
Static function SXSF_053( cFilePfx, cPass )

	Local cCA    := cWorkDir + AllTrim(SM0->M0_CGC) + "\certs\ca.pem"
	Local cError := ""
	Local lRet

	If !File( cCA )

		lRet := PFXCA2PEM( cFilePfx, cCA, @cError, cPass )

		If !lRet
			MsgAlert("Não foi possível extrair a cadeia de certificação PEM")
			cCA := ""
		EndIf

	EndIf

Return cCA

//********************************************************************************
// Faz a comunicação com a SEFAZ via webservice para download dos CTe
//********************************************************************************
User Function SXUF_023()

	Local _cErr     := ""
	Local _cWrn     := ""
	Local cPass     := Decode64( cPassPFX )
	Local cPFX      := cPathPFX
	Local cKey      := cPKeyPEM
	Local cCert     := cCertPEM
	Local cCA       := cCaPEM
	Local cPath     := cWorkDir + AllTrim(SM0->M0_CGC) + "\"
	Local cUltNSU   := cNsuCTe
	Local cUrl      := 'https://www1.cte.fazenda.gov.br/CTeDistribuicaoDFe/CTeDistribuicaoDFe.asmx'
	Local aHeadOut  := {'SOAPAction: http://www.portalfiscal.inf.br/cte/wsdl/CTeDistribuicaoDFe/cteDistDFeInteresse','Content-Type:text/xml; charset=utf-8','User-Agent: Mozilla/4.0 (compatible; Protheus 7.00.100812P-20101227; ADVPL WSDL Client 1.101007)'}
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
	Local oXml

	// Verifica o arquivo PEM com o corpo do certificado
	If Empty( cCert ) .Or. !File( cCert )
		If !Empty( cPFX ) .And. File( cPFX ) .And. !Empty( cPass )
			cCert    := SXSF_051( cPFX, cPass )
			cCertPEM := cCert
			PutMv( "SOL_XML021", cCertPEM )
		Else
			MsgAlert("Não foi possível gerar o certificado digital - CT-e")
		EndIf
	EndIf

	// Verifica o arquivo PEM com a chave privada
	If Empty( cKey ) .Or. !File( cKey )
		If !Empty( cPFX ) .And. File( cPFX ) .And. !Empty( cPass )
			cKey     := SXSF_052( cPFX, cPass )
			cPKeyPEM := cKey
			PutMv( "SOL_XML022", cPKeyPEM )
		Else
			MsgAlert("Não foi possível gerar a chave privada do certificado digital - CT-e")
		EndIf
	EndIf

	// Verifica o arquivo PEM com a cadeia de autoridades de certificação (Certificate Authority)
	If Empty( cCA ) .Or. !File( cCA )
		If !Empty( cPFX ) .And. File( cPFX ) .And. !Empty( cPass )
			cCA    := SXSF_053( cPFX, cPass )
			cCaPEM := cCA
			PutMv( "SOL_XML023", cCaPEM )
		Else
			MsgAlert("Não foi possível extrair a autoridade certificadora do certificado digital - CT-e")
		EndIf
	EndIf

	While lContinua

		// Monta a requisição SOAP
		cSoapSend := '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
		cSoapSend += '<soap:Body>'
		cSoapSend += '<cteDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/cte/wsdl/CTeDistribuicaoDFe">'
		cSoapSend += '<cteDadosMsg>'
		cSoapSend += '<distDFeInt versao="1.00" xmlns="http://www.portalfiscal.inf.br/cte">'
		cSoapSend += '<tpAmb>1</tpAmb>'
		cSoapSend += '<cUFAutor>43</cUFAutor>'
		cSoapSend += '<CNPJ>'+ SM0->M0_CGC +'</CNPJ>'
		cSoapSend += '<distNSU><ultNSU>'+ cUltNSU +'</ultNSU></distNSU>'
		cSoapSend += '</distDFeInt>'
		cSoapSend += '</cteDadosMsg>'
		cSoapSend += '</cteDistDFeInteresse>'
		cSoapSend += '</soap:Body>'
		cSoapSend += '</soap:Envelope>'

		//MemoWrite( "c:\Temp\XML\"+cUltNSU+"-soapsend_cte.xml", cSoapSend )

		// Estabelece o canal de conexão segura SSL com o certificado
		HTTPSSLClient( 0, 1, 1, cPass, cCert, cKey, 0, , , 1, , cCA )

		// Faz a requisição via POST e recebe o conteúdo do retorno
		XMLPostRet := HTTPSPost( cUrl, cCert, cKey, cPass, "", cSoapSend, 60, aHeadOut, @XMLHeadRet )

		If Type("XMLPostRet") != "U" .And. ValType( XMLPostRet ) == "C"

			// MemoWrite( "c:\Temp\XML\"+cUltNSU+"-xmlpostret_cte.xml", XMLPostRet )

			// Crio um objeto XML com toda a resposta da requisição
			oXml := XmlParser( XMLPostRet, "_", @_cErr, @_cWrn )

			// Se existir a tag LOTEDISTDFEINT no Buffer de retorno significa que a comunicação ocorreu com sucesso e que há documentos a processar
			oXml := Iif( At( "<LOTEDISTDFEINT>", Upper( XMLPostRet ) ) > 0, oXml:_SOAP_ENVELOPE:_SOAP_BODY:_CTEDISTDFEINTERESSERESPONSE:_CTEDISTDFEINTERESSERESULT:_RETDISTDFEINT, Nil )

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

					_cTpZip := oXml:_SCHEMA:TEXT // procEventoCTe_v9.99.xsd ou procCTe_v9.99.xsd
					_cNSU   := oXml:_NSU:TEXT    // Numero sequencial unico deste documento
					_cTxt   := oXml:TEXT

					cXmlRes := ""
					_lDecGz := GzStrDecomp( Decode64( _cTxt ), Len( _cTxt ), @cXmlRes )

					If _lDecGz // Convertido com sucesso

						If !( "evento" $ Lower( _cTpZip ) ) // Baixo apenas o xml de CT-e, dos eventos ainda não

							// Crio um objeto XML com o documento apenas para extrair a chave do mesmo
							oXml := XmlParser( cXmlRes, "_", @_cErr, @_cWrn )

							// Se criou o objeto corretamente, uso a chave como nome do arquivo, senão uso o NSU
							If oXml != Nil
								If "cteOSProc" $ cXmlRes
									MemoWrite( cPath + oXml:_CTEOSPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT +"-procCte.xml", cXmlRes )
								ElseIf "cteProc" $ cXmlRes
									MemoWrite( cPath + oXml:_CTEPROC:_PROTCTE:_INFPROT:_CHCTE:TEXT +"-procCte.xml", cXmlRes )
								Else
									MemoWrite( cPath + _cNSU +"-procCte.xml", cXmlRes )
								EndIf
							Else
								MemoWrite( cPath + _cNSU +"-procCte.xml", cXmlRes )
							EndIf

						EndIf

					EndIf

					cNsuCTe := _cNSU

					PutMv( "SOL_XML024", cNsuCTe )

				Next

			EndIf

		Else
			lContinua := .F.
		EndIf

	End

Return

//********************************************************************************
// Faz a comunicação com a SEFAZ via webservice para download da NF-e
//********************************************************************************
User Function SXUF_024()

	Local _cErr     := ""
	Local _cWrn     := ""
	Local cCnpj     := AllTrim(SM0->M0_CGC)
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
	Local aManif    := {}
	Local aDwlNfe   := {}
	Local lContinua := .T.
	Local oXml
	Local oXmlParse

	// Verifica o arquivo PEM com o corpo do certificado
	If Empty( cCert ) .Or. !File( cCert )
		If !Empty( cPFX ) .And. File( cPFX ) .And. !Empty( cPass )
			cCert    := SXSF_051( cPFX, cPass )
			cCertPEM := cCert
			PutMv( "SOL_XML021", cCertPEM )
		Else
			MsgAlert("Não foi possível gerar o certificado digital - NF-e")
			lContinua := .F.
		EndIf
	EndIf

	// Verifica o arquivo PEM com a chave privada
	If Empty( cKey ) .Or. !File( cKey )
		If !Empty( cPFX ) .And. File( cPFX ) .And. !Empty( cPass )
			cKey     := SXSF_052( cPFX, cPass )
			cPKeyPEM := cKey
			PutMv( "SOL_XML022", cPKeyPEM )
		Else
			MsgAlert("Não foi possível gerar a chave privada do certificado digital - NF-e")
			lContinua := .F.
		EndIf
	EndIf

	// Verifica o arquivo PEM com a cadeia de autoridades de certificação (Certificate Authority)
	If Empty( cCA ) .Or. !File( cCA )
		If !Empty( cPFX ) .And. File( cPFX ) .And. !Empty( cPass )
			cCA    := SXSF_053( cPFX, cPass )
			cCaPEM := cCA
			PutMv( "SOL_XML023", cCaPEM )
		Else
			MsgAlert("Não foi possível extrair a autoridade certificadora do certificado digital - NF-e")
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
		HTTPSSLClient( 1, 1, 1, cPass, cCert, cKey, 0, , , 1, , cCA )

		oXmlParse := Nil
		oXml      := Nil
		Sleep(1000)

		// Faz a requisição via POST e recebe o conteúdo do retorno
		XMLPostRet := HTTPSPost( cUrl, cCert, cKey, cPass, "", cSoapSend, 90, aHeadOut, @XMLHeadRet )

		If Type("XMLPostRet") != "U" .And. ValType( XMLPostRet ) == "C"

			// MemoWrite( "c:\Temp\XML\"+cUltNSU+"-xmlpostret_nfe.xml", XMLPostRet )

			// Crio um objeto XML com toda a resposta da requisição
			oXmlParse := XmlParser( XMLPostRet, "_", @_cErr, @_cWrn )

			// Se existir a tag LOTEDISTDFEINT no Buffer de retorno significa que a comunicação ocorreu com sucesso e que há documentos a processar
			oXml := Iif( At( "<LOTEDISTDFEINT>", Upper( XMLPostRet ) ) > 0, oXmlParse:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT, Nil )

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

						// Salvo o xml de NF-e, gravo os dados de resumo de NF-e, eventos ainda não
						If !( "evento" $ Lower( _cTpZip ) )

							If "resnfe" $ Lower( _cTpZip ) // Resumo da nota fiscal, precisa ser manifestada

								// Crio um objeto XML do resumo para pegar a chave e manifestar
								oXml := XmlParser( cXmlRes, "_", @_cErr, @_cWrn )

								If oXml != Nil

									cChave := oXml:_RESNFE:_CHNFE:TEXT

									If aScan( aManif, cChave ) == 0
										aAdd( aManif, cChave ) // Chaves para manifestar
										aAdd( aDwlNfe, cChave )// Chaves para download
									EndIf

									/*
									dbSelectArea("ZX1") // Gravar ZX1
									RecLock("ZX1",.T.)
										ZX1->ZX1_FILIAL := xFilial("ZX1")
										ZX1->ZX1_TPDOC  := "NFE"
										ZX1->ZX1_EMISSA := StoD( StrTran( Left( oXml:_RESNFE:_DHEMI:TEXT, 10 ), "-", "" ) )
										ZX1->ZX1_STATUS := "5"
										ZX1->ZX1_CHVNFE := cChave
										ZX1->ZX1_DTIMP  := dDataBase
									ZX1->( MsUnLock() )
								    */
								EndIf

							Else
								// Crio um objeto XML com o documento apenas para extrair a chave do mesmo
								oXml := XmlParser( cXmlRes, "_", @_cErr, @_cWrn )

								// Se criou o objeto corretamente, uso a chave como nome do arquivo, senão uso o NSU
								If oXml != Nil
									MemoWrite( cPath + oXml:_NFEPROC:_PROTNFE:_INFPROT:_CHNFE:TEXT +"-procNfe.xml", cXmlRes )
								Else
									MemoWrite( cPath + _cNSU +"-procNfe.xml", cXmlRes )
								EndIf
							EndIf

						EndIf

					EndIf

					cNsuNFe := _cNSU

					PutMv( "SOL_XML028", cNsuNFe )

				Next

				For _nD := 1 To Len( aManif )
					SXSF_054( aManif[ _nD ], '210210', cCnpj ) // Envia a manifestação de ciência (Sem TSS)
				Next

				aManif := {}

			EndIf

		Else
			lContinua := .F.
		EndIf

	End

	For _nD := 1 To Len( aDwlNfe )
		SXSF_055( aDwlNfe[ _nD ] ) // Efetua o download da nota fiscal completa (sem TSS)
	Next

Return

// Efetua o download da nota fiscal completa (sem TSS)
Static Function SXSF_055( cChave, lDownload )

	Local _cErr     := ""
	Local _cWrn     := ""
	Local cCnpj     := AllTrim(SM0->M0_CGC)
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
	Local _cTpZip   := ""
	Local _cTxt     := ""
	Local oXml
	Local oXmlParse

	Default lDownload := .T.

	// Monta a requisição SOAP
	cSoapSend := '<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">'
	cSoapSend += '<soap:Body>'
	cSoapSend += '<nfeDistDFeInteresse xmlns="http://www.portalfiscal.inf.br/nfe/wsdl/NFeDistribuicaoDFe">'
	cSoapSend += '<nfeDadosMsg>'
	cSoapSend += '<distDFeInt versao="1.01" xmlns="http://www.portalfiscal.inf.br/nfe">'
	cSoapSend += '<tpAmb>1</tpAmb>'
	cSoapSend += '<cUFAutor>43</cUFAutor>'
	cSoapSend += '<CNPJ>'+ cCnpj +'</CNPJ>'
	cSoapSend += '<consChNFe><chNFe>'+ cChave +'</chNFe></consChNFe>'
	cSoapSend += '</distDFeInt>'
	cSoapSend += '</nfeDadosMsg>'
	cSoapSend += '</nfeDistDFeInteresse>'
	cSoapSend += '</soap:Body>'
	cSoapSend += '</soap:Envelope>'

	// Estabelece o canal de conexão segura SSL com o certificado
	HTTPSSLClient( 1, 1, 1, cPass, cCert, cKey, 0, , , 1, , cCA )
	// Faz a requisição via POST e recebe o conteúdo do retorno
	XMLPostRet := HTTPSPost( cUrl, cCert, cKey, cPass, "", cSoapSend, 90, aHeadOut, @XMLHeadRet )

	If Type("XMLPostRet") != "U" .And. ValType( XMLPostRet ) == "C"

		// Crio um objeto XML com toda a resposta da requisição
		oXmlParse := XmlParser( XMLPostRet, "_", @_cErr, @_cWrn )

		If ValType( oXmlParse ) <> "O"
			FreeObj( oXmlParse )
			MsgAlert( "Erro no retorno pelo Sefaz." )// XmlChildEx( oXmlParse, "_SOAP_ENVELOPE" )

		ElseIf XmlChildEx( oXmlParse, "_HTML" ) <> NIL

			If "403" $ oXmlParse:_HTML:_HEAD:_TITLE:TEXT
				MsgAlert( "Acesso negado ao Sefaz, favor verificar a validade do Certificado Digital." )
			Else
				MsgAlert( "Erro na estrutura de retorno do Sefaz." )
			EndIf
			FreeObj( oXmlParse )

		ElseIf XmlChildEx( oXmlParse, "_SOAP_ENVELOPE" ) <> NIL

			If oXmlParse:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT:_CSTAT:TEXT == "656"
				FreeObj( oXmlParse )
				MsgAlert( "Rejeicao do Sefaz por consumo indevido, favor aguardar alguns minutos para fazer uma nova consulta." )
			Else
				// Se existir a tag LOTEDISTDFEINT no Buffer de retorno significa que a comunicação ocorreu com sucesso e que há documentos a processar
				oXml := Iif( At( "<LOTEDISTDFEINT>", Upper( XMLPostRet ) ) > 0, oXmlParse:_SOAP_ENVELOPE:_SOAP_BODY:_NFEDISTDFEINTERESSERESPONSE:_NFEDISTDFEINTERESSERESULT:_RETDISTDFEINT, Nil )
			EndIf

		EndIf
	Else
		MsgAlert( "Erro de comunicação com a Sefaz" )
	EndIf

	// Se o objeto XML for NIL é poque não há o que processar
	If oXml <> Nil

		If !lDownload
			If oXml:_CSTAT:TEXT == "138"
				Return("100")
			ElseIf oXml:_CSTAT:TEXT == "653"
				Return("101")
			Else
				Return("999")
			EndIf
		EndIf

		// Código de retorno com algum problema
		If oXml:_CSTAT:TEXT <> "138"
			MsgAlert( "Status " + oXml:_CSTAT:TEXT + " de retorno do Sefaz." )

		// Código de retorno 138 - Documento localizado
		Else

			If ValType( oXml:_LOTEDISTDFEINT:_DOCZIP ) == "O"
				aDocs := {oXml:_LOTEDISTDFEINT:_DOCZIP}
			ElseIf ValType( oXml:_LOTEDISTDFEINT:_DOCZIP ) == "A"
				aDocs := oXml:_LOTEDISTDFEINT:_DOCZIP
			Else
				aDocs := {}
				MsgAlert( "Sem documento no XML do Sefaz." )
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
				Else
					MsgInfo( "Problema na conversão do XML do retorno do Sefaz." )
				EndIf

			Next

		EndIf

	Else
		lContinua := .F.
	EndIf

Return("999")

// Envia a manifestação de destinatario (sem TSS)
Static Function SXSF_054( cChave, cEvento, cCnpj )

	Local XMLHeadRet := ""
	Local cError     := ""
	Local cWarning   := ""
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
	cXmlRet := SXSF_056( cXmltoSign, cTag, cKey, cCert, cPass, cIdEvento )
	// Envelopa o XML assinado para envio ao webservice de eventos da sefaz
	cXml := cSoap1 + cXmlRet + cSoap2
    // Cria a conexão SSL e faz o envio do xml da manifestação
	HTTPSSLClient( 1, 1, 1, cPass, cCert, cKey, 0, , , 1, , cCA )
	XMLPostRet := HTTPSPost( cUrl, cCert, cKey, cPass, "", cXml, 120, aHeadOut, @XMLHeadRet )

Return

// Assina o XML para envio do evento de manifestação
Static Function SXSF_056( cXML, cTag, cKey, cCert, cPassCert, cURI )

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
	Local cTipoSig    := "1"
	Local cIdent      := ""

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
			cSignInfo := SXSF_057( cUri, cDigest )
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
			cXmltoSign += '<X509Certificate>'+ SXSF_058( cCert, .F. ) +'</X509Certificate>'
			cXmltoSign += '</X509Data>'
			cXmltoSign += '</KeyInfo>'
			cXmltoSign += '</Signature>'

			cXmlToSign := cIniXML + cXmlToSign + cFimXML
		Else
			cXmlToSign := cXml
			MsgAlert("Sign Error thread: "+ cError +"/"+ cWarning )
		EndIf

	Else
		cXmlToSign := "Falha"
		MsgAlert("Falha ao tentar assinar xml de manifestação.","Necessario Build "+ GetBuild() +" ou superior.")
	EndIf

Return( cXmlToSign )

// Obtém o conteúdo do certificado PEM
Static Function SXSF_058( cFile, lHSM )

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
		MsgAlert("Certificado nao encontrado no diretorio Certs.")
	EndIf

Return( cCertificado )

// Calcula o SignedInfo  da assinatura
Static Function SXSF_057( cUri, cDigest )

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

// Gera o array de Operações x Tes Inteligente na tela de configurações
Static Function SXSF_059()

	Local aRet := {}
	Local aTmp1 := {}
	Local aTmp2 := {}

	If Empty( cLinConf )
		aRet := { { Space(2), Space(10) } }
	Else
		aTmp1 := StrTokArr2( AllTrim( cLinConf ), "|", .F. )

		For _nC := 1 To Len( aTmp1 )

			aTmp2 := StrTokArr2( aTmp1[ _nC ], "_", .T. )

			If Len( aTmp2 ) > 0
				aAdd( aRet, { aTmp2[ 1 ], aTmp2[ 2 ] } )
			EndIf

		Next

	EndIf

    // Garantindo que o retorno será em formato de array
	If Len( aRet ) == 0
		aRet := { { Space(2), Space(10) } }
	EndIf

Return( aRet )

// Atualiza o browse das operações x CFOP
Static Function SXSF_060( nAcao, aItem )

	Local cLCTemp := "|"
	Local aLCTemp := {}
	Local lOk     := .F.
	Local cOper   := Space(2)
	Local cCFOP   := Space(250)
	Local oDlg1, oSay1, oSay2, oGet1, oGet2, oBtn1
	Local bOkButI := {|| Iif( !Empty(cOper).And.ExistCpo("SX5","DJ"+AllTrim(cOper)).And.aScan( aBrwTesI,{|o| AllTrim(o[1]) == AllTrim(cOper) } )==0, ( lOk := .T., oDlg1:End() ), MsgAlert("Verificar a operação") ) }
	Local bOkButA := {|| lOk := .T., oDlg1:End() }

	If nAcao == 1 // Inclusão

		oDlg1 := MSDialog():New( 212,260,295,777,"Operação X CFOP - INCLUIR",,,.F.,,,,,,.T.,,,.T. )
		oSay1 := TSay():New( 008,004,{||"Operação"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oSay2 := TSay():New( 008,043,{||"CFOP's"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
		oGet1 := TGet():New( 019,005,{|u| If(Pcount()>0,cOper:=u,cOper)},oDlg1,027,008,'@!',{|| .T. },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"DJ","",,)
		oGet2 := TGet():New( 019,043,{|u| If(Pcount()>0,cCFOP:=u,cCFOP)},oDlg1,165,008,'@!',{|| .T. },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
		oBtn1 := TButton():New( 008,220,"OK",oDlg1,bOkButI,024,016,,,,.T.,,"",,,,.F. )
		oDlg1:Activate(,,,.T.,{||},,{||})

		If lOk
			aAdd( aBrwTesI, { cOper, AllTrim( cCFOP ) } )
			cLCTemp := cLinConf + cOper +"_"+ AllTrim( cCFOP ) +"|"
		Else
			cLCTemp := cLinConf
		EndIf
		aLCTemp := aBrwTesI

	ElseIf nAcao == 2 // Exclusão

		If ValType( aItem ) == "A" .And. Len( aItem ) > 0 .And. !Empty( aItem[ 1 ] )
			If MsgYesNo("Confirmar exclusão do relacionamento da operação "+ AllTrim( aItem[ 1 ] ) )
				For _nC := 1 To Len( aBrwTesI )
					If AllTrim( aBrwTesI[ _nC, 1 ] ) != AllTrim( aItem[ 1 ] )
						cLCTemp += aBrwTesI[ _nC, 1 ] +"_"+ AllTrim( aBrwTesI[ _nC, 2 ] ) +"|"
						aAdd( aLCTemp, aBrwTesI[ _nC ] )
					EndIf
				Next
			Else
				cLCTemp := cLinConf
				aLCTemp := aBrwTesI
			EndIf
		Else
			cLCTemp := cLinConf
			aLCTemp := aBrwTesI
		EndIf

	ElseIf nAcao == 3 // Alteração

		If !Empty( aItem[ 1 ] )
			cLCTemp := "|"
			cOper := aItem[ 1 ]
			cCFOP := AllTrim( aItem[ 2 ] ) + Space(50)

			oDlg1 := MSDialog():New( 212,260,295,777,"Operação X CFOP - ALTERAR",,,.F.,,,,,,.T.,,,.T. )
			oSay1 := TSay():New( 008,004,{||"Operação"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
			oSay2 := TSay():New( 008,043,{||"CFOP's"},oDlg1,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,032,008)
			oGet1 := TGet():New( 019,005,{|| cOper  },oDlg1,027,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,{||.F.},.F.,.F.,,.F.,.F.,"DJ","",,)
			oGet2 := TGet():New( 019,043,{|u| If(Pcount()>0,cCFOP:=u,cCFOP)},oDlg1,165,008,'@!',{|| .T. },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","",,)
			oBtn1 := TButton():New( 008,220,"OK",oDlg1,bOkButA,024,016,,,,.T.,,"",,,,.F. )
			oDlg1:Activate(,,,.T.,{||},,{||})

			If lOk
				aLCTemp := aBrwTesI
				aLCTemp[ aScan( aBrwTesI,{|o| AllTrim(o[1]) == AllTrim( aItem[ 1 ] ) } ), 2 ] := cCFOP
				For _nC := 1 To Len( aLCTemp )
					cLCTemp += aBrwTesI[ _nC, 1 ] +"_"+ AllTrim( aBrwTesI[ _nC, 2 ] ) +"|"
				Next
			Else
				cLCTemp := cLinConf
				aLCTemp := aBrwTesI
			EndIf
		Else
			cLCTemp := cLinConf
			aLCTemp := aBrwTesI
		EndIf

	EndIf

	aBrwTesI := aLCTemp // Atualizo o array do browse
	cLinConf := cLCTemp // Atualizo a string que vai gravar no arquivo de configuração

	oBrwTesI:SetArray( aBrwTesI )
	oBrwTesI:bLine := {|| { aBrwTesI[ oBrwTesI:nAt, 01 ], aBrwTesI[ oBrwTesI:nAt, 02 ] } }

Return

// Ponto de entrada A103CND2 para ajuste da condição de pagamento
User Function A103CND2()

	Local _aParcXml := {}
	Local _aParcRet := PARAMIXB

	If ( Type("l116Auto") == "L" .And. l116Auto ) .And. IsInCallStack("U_SXUF_001") .And. Type("oGetDados2") == "O"

		For _nX := 1 To Len( oGetDados2:aCols )
			If !oGetDados2:aCols[ _nX ][ Len( oGetDados2:aCols[ _nX ] ) ]
				aAdd( _aParcXml, { DataValida( oGetDados2:aCols[ _nX ][ 2 ] ), oGetDados2:aCols[ _nX ][ 3 ] } )
			EndIf
		Next

		If Len( _aParcXml ) > 0
			_aParcRet := _aParcXml
		EndIf

	ElseIf ( Type("l103Auto") == "L" .And. l103Auto ) .And. !IsInCallStack("MATA140") .And. Type("_aParcNfe") == "A"

		If Len( _aParcNfe ) > 0
			_aParcRet := _aParcNfe
		EndIf

	EndIf

Return _aParcRet

// Função que atualiza o array das parcelas de acordo com a condição selecionada
Static Function FillCond( cCondic, lAtuBrw )

	Local aVencto := Iif( lAtuBrw, Condicao( nTotDup, cCondic, 0 /*Valor IPI*/, dDataBase ), oGetDados2:aCols )
	Local nTotVal := 0

	If Len( aVencto ) > 0

		If lAtuBrw
			oGetDados2:aCols := {}
		EndIf

		For nX := 1 To Len( aVencto )
			If lAtuBrw
				aAdd( oGetDados2:aCols, { AllTrim( StrZero( nX, 3 ) ), aVencto[ nX, 1 ], aVencto[ nX, 2 ], .F. } )
				nTotVal += aVencto[ nX, 2 ]
			Else
				If !aVencto[ nX, Len( aVencto[ nX ] ) ]
					nTotVal += Iif( nX == oGetDados2:nAt, Iif( !( "VALORE" $ ReadVar() ), aVencto[ nX, 3 ], M->VALORE ), aVencto[ nX, 3 ] )
				EndIf
			EndIf
		Next

		nTotParc := nTotVal // nTotVal é a variável private que armazena o valor da soma das pacelas a cada atualização do browse
		oGetDados2:Refresh()

		oTotParc:SetText( "R$ "+ Transform( nTotParc, "@E 99,999,999.99" ) )
		oTotParc:nClrText := Iif( nTotParc != nTotDup, CLR_RED, CLR_GREEN )
		oTotParc:CtrlRefresh()

	EndIf

Return .T.

// Função para completar os campos do acols de parcelas de pagamento
User Function AtuArrParc()

	oGetDados2:Refresh()

	If Empty( oGetDados2:aCols[ oGetDados2:nAt, 1 ] )
		oGetDados2:aCols[ oGetDados2:nAt, 2 ] := Iif( "VENC" $ ReadVar(), &( ReadVar() ), CtoD("") )
		oGetDados2:aCols[ oGetDados2:nAt, 3 ] := Iif( "VALO" $ ReadVar(), &( ReadVar() ), 0 )
	EndIf

	FillCond("",.F.)

Return .T.

// Função para atualizar o valor na deleção de parcela de pagamento
User Function DelArrParc()

	If !oGetDados2:aCols[ oGetDados2:nAt, Len( oGetDados2:aCols[ oGetDados2:nAt ] ) ]
		nTotParc -= oGetDados2:aCols[ oGetDados2:nAt, 3 ]
	Else
		nTotParc += oGetDados2:aCols[ oGetDados2:nAt, 3 ]
	EndIf

	oTotParc:SetText( "R$ "+ Transform( nTotParc, "@E 99,999,999.99" ) )
	oTotParc:nClrText := Iif( nTotParc != nTotDup, CLR_RED, CLR_GREEN )
	oTotParc:CtrlRefresh()

Return .T.

// Função para validar a mudança de linha nas parcelas a pagar
User Function ValLinParc()

    Local _nLin := oGetDados2:nAt
	Local _lRet := !oGetDados2:aCols[ _nLin, Len( oGetDados2:aCols[ _nLin ] ) ]
    Local _cEmi := dDataBase

	If _lRet .And. oGetDados2:aCols[ _nLin, 3 ] <= 0
		MsgAlert("Valor precisa ser Positivo!")
		_lRet := .F.
	EndIf

	If _lRet .And. oGetDados2:aCols[ _nLin, 2 ] == Ctod("")
		MsgAlert("Vencimento precisa ser informado!")
		_lRet := .F.
	EndIf

	If _lRet .And. oGetDados2:aCols[ _nLin, 2 ] != Ctod("") .And. oGetDados2:aCols[ _nLin, 2 ] < _cEmi
		MsgAlert("Vencimento não pode ser menor que emissão do documento!")
		_lRet := .F.
	EndIf

	If _lRet .And. oGetDados2:aCols[ _nLin, 2 ] != Ctod("") .And. oGetDados2:aCols[ _nLin, 2 ] < dDataBase
		_lRet := MsgYesNo("Vencimento menor que a data atual! Confirma?")
	EndIf

Return _lRet

// Função de replicação de TES nos itens
User Function ReplOper( cCampo )

	Local nPosTes := aScan( aHeader, {|o| AllTrim(o[2]) == "ZX2_TES" } )
	Local nPosPro := aScan( aHeader, {|o| AllTrim(o[2]) == "ZX2_COD" } )
	Local cTes    := ""

	cTes := Iif( cCampo == "O", MaTesInt( 1, M->ZX2_OPER, M->ZX1_CLIFOR, M->ZX1_LOJA, Iif( M->ZX1_TIPO $ 'CN', 'F', 'C' ), aCols[ n, nPosPro ] ), M->ZX2_TES )

	If !Empty( cTes ) .And. Len( aCols ) > 1 .And. MsgYesNo("Deseja replicar o tes "+ cTes +" para os itens SEM tes informado?")

		For _nX := 1 To Len( aCols )

			If Empty( aCols[ _nX, nPosTes ] )
				aCols[ _nX, nPosTes ] := cTes
			EndIf

		Next

	EndIf

Return cTes

// Na tela de seleção de pedido de compras, permite criar itens baseado em item existente para
// amarrar mais pedidos e selecionar a quantidade em cada item
Static Function DUPLITEM()

	Local oDlgSpl,oSay1,oSay2,oSay3,oSay4,oGet1,oGet2,oSBtn1,oSBtn2
	Local cProduto := ""
	Local nQtdOri  := 0
	Local nQtdNew  := 0
	Local nQtdAtu  := 0
	Local nY       := 0
	Local nItemAtu := oGetDad:nAt
	Local lOk      := .F.
	Local aNewLin  := {}
	Local nPProd   := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_COD"    } )
	Local nPQtdd   := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_QUANT"  } )
	Local nPItem   := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_ITEM"   } )
	Local nPVUni   := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_VUNIT"  } )
	Local nPVTot   := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_TOTAL"  } )
	Local nPVIcm   := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_VALICM" } )
	Local nPVIpi   := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_VALIPI" } )
	Local nPBIcm   := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_BASICM" } )
	Local nPBIpi   := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_BASIPI" } )
	Local nPVIcS   := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_VICMST" } )
	Local nPBIcS   := aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == "ZX2_BICMST" } )

	If nPProd > 0 .And. nPQtdd > 0
		cProduto := oGetDad:aCols[ nItemAtu ][ nPProd ]
		nQtdOri  := oGetDad:aCols[ nItemAtu ][ nPQtdd ]
	EndIf

	If !Empty( cProduto )
		cProduto := AllTrim( cProduto ) +" - "+ AllTrim( Posicione("SB1",1,xFilial("SB1")+cProduto,"SB1->B1_DESC") )
	EndIf

	oDlgSpl:= MSDialog():New( 191,301,310,727,"Duplicar Item",,,.F.,,,,,,.T.,,,.T. )
	oSay1  := TSay():New( 004,004,{||"Produto"},oDlgSpl,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,024,008)
	oSay2  := TSay():New( 004,032,{|| cProduto },oDlgSpl,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,168,008)
	oSay3  := TSay():New( 020,004,{||"Quantidade Original"},oDlgSpl,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,056,008)
	oSay4  := TSay():New( 037,004,{||"Quantidade Novo Item"},oDlgSpl,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,056,008)
	oGet2  := TGet():New( 036,068,{|u| If(Pcount()>0, nQtdNew:=u, nQtdNew)},oDlgSpl,052,008,'@E 999,999,999.99',{|| VldNewQtd(nQtdOri,nQtdNew)},CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","nQtdNew")
	oSBtn1 := SButton():New( 036,176,1,{|| lOk := .T., oDlgSpl:End() },oDlgSpl,,"", )
	oGet1  := TGet():New( 020,068,{|| nQtdOri },oDlgSpl,052,008,'@E 999,999,999.99',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.T.,.F.,"","nQtdOri")
	oSBtn2 := SButton():New( 036,144,2,{|| lOk := .F., oDlgSpl:End() },oDlgSpl,,"", )
	oDlgSpl:Activate(,,,.T.)

	If lOk

		aAdd( aNewLin, Array( Len( oGetDad:aHeader ) + 1 ) )

		For nY := 1 to Len( aNewLin[ 1 ] )
			aNewLin[ 1, nY ] := oGetDad:aCols[ nItemAtu, nY ]
		Next nY

		// Aqui atualizar o item, as quantidades, valores e gravar nos registros da ZX2 e atualizar o recno do novo registro
		
		nQtdAtu := nQtdOri - nQtdNew // Quantidade do item alterada

		oGetDad:aCols[ nItemAtu, nPQtdd ] := nQtdAtu // Atualizar quantidade do item que foi alterado
		oGetDad:aCols[ nItemAtu, nPVTot ] := nQtdAtu * oGetDad:aCols[ nItemAtu ][ nPVUni ] // Valor total 
		oGetDad:aCols[ nItemAtu ][ nPBIcm ] := Iif( oGetDad:aCols[ nItemAtu, nPBIcm ] > 0, Round( ( oGetDad:aCols[ nItemAtu ][ nPBIcm ] / nQtdOri ) * nQtdAtu, 2 ), 0 )
		oGetDad:aCols[ nItemAtu ][ nPBIpi ] := Iif( oGetDad:aCols[ nItemAtu, nPBIpi ] > 0, Round( ( oGetDad:aCols[ nItemAtu ][ nPBIpi ] / nQtdOri ) * nQtdAtu, 2 ), 0 )
		oGetDad:aCols[ nItemAtu ][ nPVIcm ] := Iif( oGetDad:aCols[ nItemAtu, nPVIcm ] > 0, Round( ( oGetDad:aCols[ nItemAtu ][ nPVIcm ] / nQtdOri ) * nQtdAtu, 2 ), 0 )
		oGetDad:aCols[ nItemAtu ][ nPVIpi ] := Iif( oGetDad:aCols[ nItemAtu, nPVIpi ] > 0, Round( ( oGetDad:aCols[ nItemAtu ][ nPVIpi ] / nQtdOri ) * nQtdAtu, 2 ), 0 )
		oGetDad:aCols[ nItemAtu ][ nPVIcS ] := Iif( oGetDad:aCols[ nItemAtu, nPVIcS ] > 0, Round( ( oGetDad:aCols[ nItemAtu ][ nPVIcS ] / nQtdOri ) * nQtdAtu, 2 ), 0 )
		oGetDad:aCols[ nItemAtu ][ nPBIcS ] := Iif( oGetDad:aCols[ nItemAtu, nPBIcS ] > 0, Round( ( oGetDad:aCols[ nItemAtu ][ nPBIcS ] / nQtdOri ) * nQtdAtu, 2 ), 0 )

		// Atualiza o registro no ZX2 atual, diminuindo a quantidade que foi colocada em outro item e atualizando os valores
		ZX2->( dbSetOrder(3) )
		If ZX2->( dbSeek( xFilial("ZX2") + ZX1->ZX1_CHVNFE + oGetDad:aCols[ nItemAtu, nPProd ] + oGetDad:aCols[ nItemAtu, nPItem ] ) )
			ZX2->( RecLock( "ZX2", .F. ) )

			For nY := 1 to Len( oGetDad:aHeader )
				If !IsHeadRec( oGetDad:aHeader[ nY ][ 2 ] ) .And. !IsHeadAlias( oGetDad:aHeader[ nY ][ 2 ] ) .And. oGetDad:aHeader[ nY ][ 10 ] <> "V"
					ZX2->&(oGetDad:aHeader[ nY ][ 2 ]) := oGetDad:aCols[ nItemAtu ][ aScan( oGetDad:aHeader, { |o| AllTrim( o[2] ) == AllTrim(oGetDad:aHeader[ nY ][ 2 ]) } ) ]
				EndIf
			Next nY

			ZX2->( MsUnLock() )
		EndIf

		aNewLin[ 1, nPItem ] := Soma1( oGetDad:aCols[ Len( oGetDad:aCols ), nPItem ] ) // Item
		aNewLin[ 1, nPQtdd ] := nQtdNew // Quantidade do novo item
		aNewLin[ 1, nPVTot ] := nQtdNew * oGetDad:aCols[ nItemAtu ][ nPVUni ] // Valor total 
		aNewLin[ 1, nPBIcm ] := Iif( aNewLin[ 1, nPBIcm ] > 0, Round( ( oGetDad:aCols[ nItemAtu ][ nPBIcm ] / nQtdOri ) * nQtdNew, 2 ), 0 )
		aNewLin[ 1, nPBIpi ] := Iif( aNewLin[ 1, nPBIpi ] > 0, Round( ( oGetDad:aCols[ nItemAtu ][ nPBIpi ] / nQtdOri ) * nQtdNew, 2 ), 0 )
		aNewLin[ 1, nPVIcm ] := Iif( aNewLin[ 1, nPVIcm ] > 0, Round( ( oGetDad:aCols[ nItemAtu ][ nPVIcm ] / nQtdOri ) * nQtdNew, 2 ), 0 )
		aNewLin[ 1, nPVIpi ] := Iif( aNewLin[ 1, nPVIpi ] > 0, Round( ( oGetDad:aCols[ nItemAtu ][ nPVIpi ] / nQtdOri ) * nQtdNew, 2 ), 0 )
		aNewLin[ 1, nPVIcS ] := Iif( aNewLin[ 1, nPVIcS ] > 0, Round( ( oGetDad:aCols[ nItemAtu ][ nPVIcS ] / nQtdOri ) * nQtdNew, 2 ), 0 )
		aNewLin[ 1, nPBIcS ] := Iif( aNewLin[ 1, nPBIcS ] > 0, Round( ( oGetDad:aCols[ nItemAtu ][ nPBIcS ] / nQtdOri ) * nQtdNew, 2 ), 0 )

		// Inclui um novo registro na ZX2 com a quantidade que foi retirada do item original
		ZX2->( RecLock( "ZX2", .T. ) )

		ZX2->ZX2_FILIAL := xFilial("ZX2")
		ZX2->ZX2_CHVNFE := ZX1->ZX1_CHVNFE

		For nY := 1 to Len( oGetDad:aHeader )

			If IsHeadRec( oGetDad:aHeader[ nY ][ 2 ] )
				aNewLin[ 1 ][ nY ] := ZX2->( Recno() )
			ElseIf IsHeadAlias( oGetDad:aHeader[ nY ][ 2 ] )
				ZX2->&( oGetDad:aHeader[ nY ][ 2 ] ) := "ZX2"
				//aNewLin[ 1 ][ nY ] := "ZX2"
			ElseIf ( oGetDad:aHeader[ nY ][ 10 ] <> "V" )
				ZX2->&( oGetDad:aHeader[ nY ][ 2 ] ) := aNewLin[ 1, nY ]
			Else
				ZX2->&( oGetDad:aHeader[ nY ][ 2 ] ) := CriaVar( oGetDad:aHeader[ nY, 2 ] )
			EndIf
			
		Next nY

		ZX2->( MsUnLock() )

		// Atualiza o browse dos itens
		aColsTmp := oGetDad:aCols
		aAdd( aColsTmp, aNewLin[ 1 ] )
		oGetDad:nMax  := Len( aColsTmp )
		oGetDad:aCols := aColsTmp
		oGetDad:nAt := nItemAtu
		oGetDad:Refresh()

	EndIf

Return

// Valida a quantidade a ser dividida do item original para amarrar mais de um pedido de compras
Static Function VldNewQtd( nOri, nNew )

	Local _lRet := .T.

	If nNew >= nOri
		MsgAlert("Nova quantidade precisa ser menor que a quantidade do item original")
		_lRet := .F.
	EndIf

	If nNew <= 0
		MsgAlert("Nova quantidade precisa ser positiva")
		_lRet := .F.
	EndIf

Return( _lRet )
