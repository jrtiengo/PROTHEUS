#INCLUDE "TOTVS.ch"
#INCLUDE "TOPCONN.ch"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"

/*/{Protheus.doc} MT094END
PE executado após a Liberação de Documento ( Pedido de Compra ).
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 01/11/2021
/*/
User Function MT094END()

    Local aAreaSC7 := SC7->( GetArea() )
    Local aAreaSCR := SCR->( GetArea() )
    Local aParam   := PARAMIXB
    Local cAliAtu  := Alias()
    Local cNum     := aParam[1]
    Local cTipo    := aParam[2]
    Local cFilSCR  := aParam[4]
    Local nOpc     := aParam[3]

    If nOpc == 1 // Liberacao
        
        dbSelectArea("SCR")
        dbSetOrder(2) //CR_FILIAL+CR_TIPO+CR_NUM+CR_USER
        DbGoTop()
        If dbSeek( cFilSCR + cTipo + cNum + RetCodUsr() )

            dbSelectArea("SC7")
            dbSetOrder(1) //C7_FILIAL+C7_NUM
            If dbSeek( xFilial("SC7") + AllTrim( cNum ) )

                // Tipo do registro é PC
                If ( SC7->C7_TIPO == 1 .And. SCR->CR_TIPO == "PC")

                    // Totalmente liberado
                    If PCTotLib(SC7->C7_NUM)
                        MsgRun("Enviando PC para Fornecedor... Aguarde...", "MT094END",{|| EnviaEmail() })
                    EndIf
                EndIf
            EndIf
        EndIf
    EndIf

    If .NOT. Empty( cAliAtu )
        DbSelectArea( cAliAtu )
    EndIf

    RestArea( aAreaSC7 )
    RestArea( aAreaSCR )
Return


/*/{Protheus.doc} EnviaEmail
Enviar o PC por e-mail para o Fornecedor.
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 01/11/2021
/*/
Static Function EnviaEmail()

    Local cArqPDF       := ""
    //Local cDirLocal     := ""
	Local cQuery        := ""
	Local cEmailFor     := ""
	Local cEmailCC      := ""
	Local cMensagem     := ""
    Local lAdjustToLeg  := .T.
	Local lDisableSetup := .T.
    Local lTReport 		:= .T.	
	Local aStru         := {}
	Local aEmails       := {}
	Local nPos 		    := 0
    Local nLimiteItens  := 2500

    Private oPrint
	Private oFont10     := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
	Private oFont10b    := TFont():New( "Arial",,10,,.t.,,,,.f.,.f. )
    Private oFont12b    := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
	Private oFont14b    := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
	Private oFont20b    := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
    Private oFont08c    := TFont():New( "Courier New",,08,,.f.,,,,.f.,.f. )
    Private oFont09b    := TFont():New( "Courier New",,09,,.t.,,,,.f.,.f. )
    Private oFont09cb   := TFont():New( "Courier New",,09,,.t.,,,,.f.,.f. )
    Private oFont10cb   := TFont():New( "Courier New",,10,,.t.,,,,.f.,.f. )
    Private oFont12c    := TFont():New( "Courier New",,12,,.f.,,,,.f.,.f. )
    Private oFont14c    := TFont():New( "Courier New",,14,,.f.,,,,.f.,.f. )
    Private aTmItem     := TamSX3("C7_ITEM")
    Private aTmProd     := TamSX3("C7_PRODUTO")
    Private aTmPosIPI   := TamSX3("B1_POSIPI")
    Private aTmQuant    := TamSX3("C7_QUANT")
    Private aTmQtSegu   := TamSX3("C7_QTSEGUM")
    Private aTmPreco    := TamSX3("C7_PRECO")
    Private aTmIPI      := TamSX3("C7_IPI")
    Private aTmTotal    := TamSX3("C7_TOTAL")
	Private aObs        := {}
	Private cObs        := ""
	Private _nQuant     := 0
	Private _nTot       := 0
	Private _nIpi       := 0
    Private _nRetido    := 0
    Private _nFrete     := 0
    Private nNumeroPro  := 0  //Quantidade de produtos a serem impressos no pedido atual
    Private nMaxQtdProd := 24
    Private __Vertical  := 0
    Private nContar     := 0
	Private _nTamLin    := 50 // Tamanho da Linha Em Pixel 
	Private _nPagina    := 1
	Private _nIniLin    := 0
	Private _nLin       := 0
	Private _nCotDia    := 1
	Private _nMoeda     := 1
    Private nPCTipo     := 1
	Private _dCotDia    := dDataBase
    Private _TpFrete    := ""
    Private _Transporte := ""
	Private _cPrazoPag  := ""
    Private cAliQry     := GetNextAlias()
	Private lLiberado	:= .F.
    Private nDescProd   := 30
    Private aSM0Sirtec  := FWSM0Util():GetSM0Data()
    Private cPcC7Quant  := X3Picture("C7_QUANT")
    //Private cPcC7Preco  := X3Picture("C7_PRECO") // 6 casas decimais
    Private cPcC7IPI    := X3Picture("C7_IPI")
    Private cPcC7Total  := X3Picture("C7_TOTAL") // 2 casas decimais
    Private cDirPDF     := SuperGetMV( "ES_DIRPC",, '\DIRPDFPC\' )

    cArqPDF := 'PC_'+SC7->C7_NUM + ".PDF"

    If Empty( cDirPDF )
        MsgAlert( 'Parâmetro "ES_DIRPC" não foi informado portanto não será possível gerar o relatório.' )
        Return("")
    EndIf

	If !ExistDir( cDirPDF )
		MakeDir( cDirPDF )
	EndIf

    // Cria o diretório do Fornecedor
    If !ExistDir( cDirPDF )
		MakeDir( cDirPDF )
	EndIf

    If File( cDirPDF + cArqPDF )
        Erase( cDirPDF + cArqPDF )
    EndIf

    oPrint := FWMSPrinter():New( cArqPDF, IMP_PDF, lAdjustToLeg, cDirPDF/*Local PDF Salvo*/, lDisableSetup, lTReport,,,.T./*lServer*/,,, .F. /*lViewPDF*/ )
	oPrint:SetPortrait()   // Para Retrato
	oPrint:SetPaperSize(DMPAPER_A4)
    oPrint:cPathPDF:= cDirPDF
    oPrint:SetMargin(20,20,20,20) // nEsquerda, nSuperior, nDireita, nInferior

	cQuery := "SELECT C7_NUM, C7_ITEM, C7_PRODUTO, C7_UM, C7_QUANT, C7_SEGUM, C7_QTSEGUM, C7_PRECO, C7_TOTAL, C7_VALFRE, C7_ICMSRET, C7_IPI, C7_TIPO, C7_USER "
    cQuery +=      ", C7_IPI, C7_VALIPI, C7_DATPRF, C7_FORNECE, C7_LOJA, C7_COND, C7_EMISSAO, C7_TPFRETE, C7_MOEDA "
	cQuery +=      ", A2_COD, A2_LOJA, A2_CGC, A2_NOME, A2_END, A2_NR_END, A2_BAIRRO, A2_EST, A2_INSCR, A2_MUN, A2_CEP, A2_DDD, A2_TEL, A2_FAX, A2_EMAIL, A2_EMAILCC "
	cQuery +=      ", SA4.A4_NOME, SE4.E4_DESCRI, SB1.B1_DESC, SB1.B1_POSIPI, SA5.A5_CODPRF "
    cQuery += " FROM " + RetSqlName("SC7") + " SC7 "
    cQuery += "INNER JOIN " + RetSQLName("SA2") + " SA2 ON ( SC7.C7_FORNECE = SA2.A2_COD AND SC7.C7_LOJA = SA2.A2_LOJA AND SA2.A2_MSBLQL <> '1' AND SA2.D_E_L_E_T_ = ' ' ) "
    cQuery += "INNER JOIN " + RetSQLName("SB1") + " SB1 ON ( SC7.C7_FILIAL = SB1.B1_FILIAL AND SC7.C7_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ = ' ' ) "
    cQuery += "INNER JOIN " + RetSQLName("SE4") + " SE4 ON ( SC7.C7_COND = SE4.E4_CODIGO AND SE4.D_E_L_E_T_ = ' ' ) "
    cQuery += "LEFT OUTER JOIN " + RetSQLName("SA4") + " SA4 ON ( SC7.C7_TRANSP = SA4.A4_COD AND SA4.D_E_L_E_T_ = ' ' ) "
    cQuery += "LEFT OUTER JOIN " + RetSQLName("SA5") + " SA5 ON ( SA5.A5_FORNECE = SA2.A2_COD AND SA5.A5_LOJA = SA2.A2_LOJA AND SA5.A5_PRODUTO = SC7.C7_PRODUTO AND SA5.D_E_L_E_T_ = ' ' ) "
	cQuery += " WHERE SC7.C7_FILIAL = '" + xFilial("SC7") + "' "
    cQuery +=   " AND SC7.C7_NUM = '" + SC7->C7_NUM + "' "
	cQuery +=   " AND SC7.D_E_L_E_T_ = ' ' "
	cQuery += " ORDER BY C7_NUM, C7_ITEM "

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliQry, .T., .T. )

    // Formatar os campos para uso
	aStru := (cAliQry)->( dbStruct() )
    For nPos := 1 To Len( aStru )
        If aStru[ nPos, 2 ] <> "C" .And. (cAliQry)->( FieldPos( aStru[ nPos, 1 ] ) ) > 0
            TcSetField( cAliQry, aStru[ nPos, 1 ], aStru[ nPos, 2 ], aStru[ nPos, 3 ], aStru[ nPos, 4 ] )
        // Campos de Data vem como caracter
        ElseIf aStru[ nPos, 1 ] $ "C7_DATPRF/C7_EMISSAO"
            TcSetField( cAliQry, aStru[ nPos, 1 ], "D", 8, 0 )
        Endif
    Next

	_nQuant  := 0
    _nTot    := 0
    _nIpi    := 0
    _nRetido := 0
    _nFrete  := 0
    aObs     := {}
    
    DbSelectArea( cAliQry )
    Count to nNumeroPro // Busca quantidade de produtos a imprimir
    
    // Volta para o primeiro registro
    (cAliQry)->( dbGoTop() )

    If Empty( (cAliQry)->A2_EMAIL )
        MsgAlert( "Fornecedor não tem e-mail cadastrado para que seja enviado o PC.")
        (cAliQry)->( dbCloseArea() )
        If File( cDirPDF + cArqPDF )
            Erase( cDirPDF + cArqPDF )
        EndIf

        Return
    EndIf

    // Imprime o cabeçalho da pagina
    PrintCabec()

    _nMoeda     := (cAliQry)->C7_MOEDA
    _cPrazoPag  := (cAliQry)->E4_DESCRI
    _Transporte := (cAliQry)->A4_NOME
    nPCTipo     := (cAliQry)->C7_TIPO
	// #30903 Solicitado que fosse possível alterar o email antes do envio. Mauro - Solutio. 07/12/2021.
    cEmailFor   := SIRALTM((cAliQry)->A2_EMAIL) //(cAliQry)->A2_EMAIL
    cEmailCC    := (cAliQry)->A2_EMAILCC
	
    Do Case
        Case Alltrim((cAliQry)->C7_TPFRETE) == "C"
            _TpFrete   := "C I F"
        Case Alltrim((cAliQry)->C7_TPFRETE) == "F"
            _TpFrete   := "F O B"
        OtherWise 
            _TpFrete   := " --- "
    EndCase	        

    If _nMoeda > 1
        _dCotDia := (cAliQry)->C7_EMISSAO
        _nCotDia := Posicione( "SM2", 1, _dCotDia, "M2_MOEDA2" )
    Else
        _nCotDia := 1
    EndIf
    
    While !(cAliQry)->( Eof() )
    
        cDescrProd := Alltrim( (cAliQry)->B1_DESC ) + " ( " + AllTrim( (cAliQry)->A5_CODPRF) + " ) "
        
        If Len(cDescrProd) > nDescProd
            nLinDesc:= MLCount(cDescrProd,nDescProd)
        Else
            nLinDesc := 1
        EndIf
    
        //impressao itens
        oPrint:Say( _nLin, 0055,  (cAliQry)->C7_ITEM, oFont12c )
        oPrint:Say( _nLin, 0150,  (cAliQry)->C7_PRODUTO, oFont12c )
        oPrint:Say( _nLin, 0400,  PADR(MemoLine(cDescrProd,nDescProd,1),nDescProd), oFont12c )
        oPrint:Say( _nLin, 1000,  PADR( (cAliQry)->B1_POSIPI, aTmPosIPI[1] ), oFont12c )
        oPrint:Say( _nLin, 1190,  PADR((cAliQry)->C7_UM,4), oFont12c )
        oPrint:Say( _nLin, 1215,  Transform( (cAliQry)->C7_QUANT, cPcC7Quant ), oFont12c )
        oPrint:Say( _nLin, 1480,  DtoC( (cAliQry)->C7_DATPRF ), oFont12c )
        oPrint:Say( _nLin, 1620,  Transform( (cAliQry)->C7_PRECO * _nCotDia, cPcC7Total ), oFont12c )
        oPrint:Say( _nLin, 1930,  Transform( (cAliQry)->C7_IPI, cPcC7IPI ), oFont12c )
        oPrint:Say( _nLin, 2000,  Transform( (cAliQry)->C7_TOTAL * _nCotDia, cPcC7Total ), oFont12c )


        If nLinDesc > 1
            For nPos := 2 to nLinDesc
                SomaLinha(_nTamLin/2)
                oPrint:Say( _nLin, 0420,  PADR(MemoLine(cDescrProd,nDescProd,nPos),nDescProd), oFont12c )
            Next
        Endif

        If nNumeroPro > 0
            SomaLinha(_nTamLin/2) // soma meia linha
            oPrint:Line( _nLin, 050, _nLin, 2300 )
        EndIf

        SomaLinha(_nTamLin)

        _nQuant  := _nQuant   + (cAliQry)->C7_QUANT
        _nTot    := _nTot     + ( (cAliQry)->C7_TOTAL   * _nCotDia )
        _nIpi    := _nIpi     + ( (cAliQry)->C7_VALIPI  * _nCotDia )
        _nRetido := _nRetido  + ( (cAliQry)->C7_ICMSRET * _nCotDia )
        _nFrete  := _nFrete   + ( (cAliQry)->C7_VALFRE  * _nCotDia )

        nNumeroPro := nNumeroPro - 1

        If _nLin >= nLimiteItens
            // Imprime o cabeçalho da pagina
            PrintCabec()
        EndIf

        (cAliQry)->( dbSkip() )
    EndDo

    // Mantem o espaçamento entre os Produtos e o Rodapé
    If  __Vertical + (nMaxQtdProd * _nTamLin) > _nLin
        _nLin := __Vertical + (nMaxQtdProd * _nTamLin)
    Endif

    // Imprime o Rodapé do Pedido de Compra
    PrintRodape()
		
	(cAliQry)->( dbCloseArea() )

	oPrint:Preview()
	MS_FLUSH()

    FreeObj(oPrint)
	oPrint := Nil

    Sleep(2000)
    // cDirLocal := GetTempPath()
    // CpyS2T( cDirPDF + cArqPDF, cDirLocal, .T. )
    // Sleep(1000)
    // ShellExecute ( "open", cDirLocal + cArqPDF, "/open", "", 1 )

    cMensagem := ''
    cMensagem += '<html> '
    cMensagem += '<head> '
    cMensagem += '<title>Pedido de Compra nr ' + SC7->C7_NUM + '</title> '
    cMensagem += '</head> '
    cMensagem += '<body> '
    
    cMensagem += 'Segue pedido de compra, qual autoriza a emissão da nota, favor observar o número deste pedido nas informações complementares '
	cMensagem += ' da nota e enviá-la juntamente com o boleto e arquivo XML para o email nota@sirtec.com.br.<br/>'
	cMensagem += 'VENCIMENTOS: O vencimento dos títulos deverão seguir os prazos descritos no pedido e coincidir em QUINTAS-FEIRAS, '
	cMensagem += ' podendo então o prazo ser maior que 30 dias.<br/>'
	cMensagem += 'ATENÇÃO: O ENVIO DO XML DA NOTA DE PRODUTO E SERVIÇO CONSTANDO O NÚMERO DO PEDIDO É OBRIGATÓRIO, O NÃO ENVIO DAS MESMAS '
	cMensagem += 'PODERÁ NÃO OCORRER O PAGAMENTO.<br/></br/>'
	cMensagem += 'Este é um envio automático de e-mail, favor não responder. <br/><br/>'
	cMensagem += 'Att '

    cMensagem += '</body> '
    cMensagem += '</html> '

    AADD( aEmails, { GetMV("MV_RELFROM"), cEmailFor, 'Pedido de Compra nr ' + SC7->C7_NUM/*Assunto*/, cMensagem, cDirPDF + cArqPDF, "N"/*Formato HTML*/, cEmailCC } )

    // Envia o e-mail 
    U_STCA031( aEmails, 2/*Mostra alertas na tela para o usuário.*/ )

    If File( cDirPDF + cArqPDF )
        Erase( cDirPDF + cArqPDF )
    EndIf

Return()


/*/{Protheus.doc} SomaLinha
Verifica se a soma de linhas não ultrapassa o limite
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 24/03/2021
@param nLinhas, numeric, Linha da impressão
/*/
Static Function SomaLinha(nLinhas)
	_nLin += nLinhas
Return


/*/{Protheus.doc} PrintCabec
Inicia nova página e imprime o cabeçalho, ajustando a linha para impressão
@type function
@version 12.1.25
@author AlbertoJ
@since 24/03/2021
/*/
Static Function PrintCabec()

    Local cTel  := ""
    Local cTxt  := ""
    Local cLogo := LogoSirtec()
    Local cEndEnt := AllTrim(aSM0Sirtec[ aScan( aSM0Sirtec, { |x| x[1]=="M0_ENDENT" } ), 2])+' '+;
                     AllTrim(aSM0Sirtec[ aScan( aSM0Sirtec, { |x| x[1]=="M0_COMPENT" } ), 2])

    Local cCidEnt := AllTrim(aSM0Sirtec[ aScan( aSM0Sirtec, { |x| x[1]=="M0_CIDENT" } ), 2])+' / '+;
                     aSM0Sirtec[ aScan( aSM0Sirtec, { |x| x[1]=="M0_ESTENT" } ), 2] + Space( 15 ) +'  CEP: '+;
                     Transform( AllTrim( aSM0Sirtec[ aScan( aSM0Sirtec, { |x| x[1]=="M0_CEPENT" } ), 2] ), "@R 99999-999")

	oPrint:StartPage()

    _nLin := 60
	oPrint:Line( _nLin, 050, _nLin, 2300 )
    _nLin := 80

	// Dados de cadastro
    
    oPrint:Say( _nLin, 1000,Substr( aSM0Sirtec[ aScan( aSM0Sirtec, { |x| x[1]=="M0_NOMECOM" } ), 2],1,42), oFont10b )
	
    If nPCTipo == 1
        oPrint:Say( _nLin, 1830, "ORDEM DE COMPRA", oFont14b )
    Else
        oPrint:Say( _nLin, 1830, "AUTORIZAÇÃO", oFont14b )
    Endif
    	    
    SomaLinha( _nTamLin/2 )

	oPrint:SayBitmap( _nLin, 50, cLogo, 750, (750*0.2427) )

    SomaLinha( _nTamLin/2 )

    // Endereço da Empresa
	oPrint:Say( _nLin, 1000, cEndEnt, oFont10b )

    If nPCTipo == 2
        oPrint:Say( _nLin, 1830, "DE ENTREGA", oFont14b )
    EndIf

    SomaLinha( _nTamLin )

    // Cidade / Estado / CEP
	oPrint:Say( _nLin, 1000, cCidEnt, oFont10b )

    // Imprime nº da ORDEM DE COMPRA
	oPrint:Say( _nLin, 1900, "Nº " + Alltrim((cAliQry)->C7_NUM), oFont20b )

    SomaLinha( _nTamLin )

    // Telfone
    cTel := Replace( aSM0Sirtec[ aScan( aSM0Sirtec, { |x| x[1]=="M0_TEL" } ), 2], '-', '' )
    oPrint:Say( _nLin, 1000, Transform( cTel, "@R (99) 9999-9999" ), oFont10b )

	oPrint:Say( _nLin, 1780, "Emissão:", oFont10 )
	oPrint:Say( _nLin, 1915, DtoC( (cAliQry)->C7_EMISSAO ), oFont10b )

    SomaLinha( _nTamLin )

    // CNPJ e IE
    cTxt := "CNPJ: " + Transform( aSM0Sirtec[ aScan( aSM0Sirtec, { |x| x[1]=="M0_CGC" } ), 2], "@R 99.999.999/9999-99") + Space( 15 ) + "IE:" + InscrEst()
	oPrint:Say( _nLin, 1000, cTxt, oFont10b )

	oPrint:Say( _nLin, 1780, "Comprador:", oFont10 )
	oPrint:Say( _nLin, 1950, Left( UsrFullName((cAliQry)->C7_USER), 25 ), oFont10b )
	
    SomaLinha( _nTamLin )

    // Linha vertical antes do NR do PC/AE
	oPrint:Line( 060, 1750, _nLin, 1750 )
	
    oPrint:Line( _nLin, 0050, _nLin, 2300 )

    SomaLinha( _nTamLin/2 )

	// Dados do fornecedor
	oPrint:Say( _nLin, 0060, "Fornecedor:", oFont10 )
	oPrint:Say( _nLin, 0230, "["+ (cAliQry)->A2_COD + "/" + (cAliQry)->A2_LOJA + "] "+ AllTrim( (cAliQry)->A2_NOME ) + " - " + Transform((cAliQry)->A2_CGC, "@R 99.999.999/9999-99"), oFont10b )
	oPrint:Say( _nLin, 1650, "Telefone:", oFont10 )
	oPrint:Say( _nLin, 1800, Transform( AllTrim( (cAliQry)->A2_DDD ) + Replace((cAliQry)->A2_TEL,'-',''), "@R (99) 9999-9999" ), oFont10b )

    SomaLinha( _nTamLin	)
	
	oPrint:Say( _nLin, 0060, "Endereço:", oFont10 )
	oPrint:Say( _nLin, 0230, AllTrim( (cAliQry)->A2_END ) +" "+AllTrim((cAliQry)->A2_NR_END)+ " - " + AllTrim( (cAliQry)->A2_BAIRRO ) +" "+ Transform( AllTrim( (cAliQry)->A2_CEP ), "@R 99999-999"), oFont10b )
	oPrint:Say( _nLin, 1650, "Cidade:", oFont10 )
	oPrint:Say( _nLin, 1800, AllTrim((cAliQry)->A2_MUN) + "/" + (cAliQry)->A2_EST, oFont10b )

    SomaLinha( _nTamLin	)
    	
	oPrint:Say( _nLin, 1650, "Insc. Est.:", oFont10 )
	oPrint:Say( _nLin, 1800, (cAliQry)->A2_INSCR , oFont10b )

	oPrint:Say( _nLin, 0060, "E-mail:", oFont10 )
	oPrint:Say( _nLin, 0230, AllTrim( (cAliQry)->A2_EMAIL ), oFont10b )

    SomaLinha( _nTamLin/2 )
 
	oPrint:Line( _nLin, 0050, _nLin, 2300 )

    SomaLinha( _nTamLin/2 )

    // Imprime o título dos produtos
    If (cAliQry)->C7_MOEDA == 1
       oPrint:Say( _nLin, 0850, "P R O D U T O S - Valores expressos em R$", oFont12b )    
    Else
       oPrint:Say( _nLin, 0850, "P R O D U T O S - Valores expressos em US$", oFont12b )    
    Endif

    SomaLinha( _nTamLin/2 )
	oPrint:Line( _nLin, 0050, _nLin, 2300 )
	__Vertical := _nLin //Seta o inicio das linhas verticais para produtos
	
	// If !Empty(nNumeroPro) // Só imprime o cabeçalho de produtos se falta produtos a imprimir.
	If nNumeroPro > 0 // Só imprime o cabeçalho de produtos se falta produtos a imprimir.
	    
	    SomaLinha( 20 )

		//impressao cabec
		oPrint:Say( _nLin, 0060,  "ITEM"				, oFont09cb)
		oPrint:Say( _nLin, 0150,  "CÓDIGO"				, oFont09cb)
		oPrint:Say( _nLin, 0400,  "DESCRIÇÃO DO PRODUTO", oFont09cb)
		oPrint:Say( _nLin, 1010,  "NCM"					, oFont09cb)
		oPrint:Say( _nLin, 1190,  "UM" 					, oFont09cb)
		oPrint:Say( _nLin, 1280,  "QUANTIDADE"			, oFont09cb)
		oPrint:Say( _nLin, 1480,  "DATA ENTREGA"		, oFont09cb)
		oPrint:Say( _nLin, 1720,  "PREÇO UNIT."			, oFont09cb)
		oPrint:Say( _nLin, 1950,  "% IPI"				, oFont09cb)
		oPrint:Say( _nLin, 2130,  "VLR.TOTAL"			, oFont09cb)
 
		SomaLinha( _nTamLin )

		oPrint:Line( _nLin, 0050, _nLin, 2300 )
	Endif

    SomaLinha( 30 )
Return


/*/{Protheus.doc} PrintRodape
Imprime o rodapé e finaliza a página
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 24/03/2021
/*/
Static Function PrintRodape()

    Local nX      := 0
    Local n       := 0
    Local L       := 0
    Local aNotas  := {}
    Local cEndEnt := AllTrim( aSM0Sirtec[ aScan( aSM0Sirtec, { |x| x[1]=="M0_ENDENT" } ), 2] )+' - '+;
                     AllTrim( aSM0Sirtec[ aScan( aSM0Sirtec, { |x| x[1]=="M0_CIDENT" } ), 2] )+' - '+;
                     aSM0Sirtec[ aScan( aSM0Sirtec, { |x| x[1]=="M0_ESTENT" } ), 2]+' - '+;
                     aSM0Sirtec[ aScan( aSM0Sirtec, { |x| x[1]=="M0_CEPENT" } ), 2]
    
    Local cEndCob := AllTrim( aSM0Sirtec[ aScan( aSM0Sirtec, { |x| x[1]=="M0_ENDCOB" } ), 2] )+' - '+;
                        AllTrim( aSM0Sirtec[ aScan( aSM0Sirtec, { |x| x[1]=="M0_CIDCOB" } ), 2] )+' - '+;
                        aSM0Sirtec[ aScan( aSM0Sirtec, { |x| x[1]=="M0_ESTCOB" } ), 2]+' - '+;
                        aSM0Sirtec[ aScan( aSM0Sirtec, { |x| x[1]=="M0_CEPCOB" } ), 2]

	//Linha horizontal divisão parte produtos para o rodapé.
	oPrint:Line( _nLin, 0050, _nLin, 2300 )
	SomaLinha(15)

	oPrint:Say(_nLin, 0100,"End. Entrega:",oFont10 )
	oPrint:Say(_nLin, 0320, cEndEnt, oFont10 )
	SomaLinha(30)

	oPrint:Say(_nLin, 0100,"End.Cobrança:",oFont10 )
	oPrint:Say(_nLin, 0320, cEndCob, oFont10 )
	SomaLinha(30)
	
	//Inicio linha horizontal dos totalizadores
	oPrint:Line( _nLin, 0050, _nLin, 2300 )

    nLinVertical := _nLin

	SomaLinha(15)

    // Imprime a Condição de Pagamento
	oPrint:Say( _nLin, 0100, "Condição de Pagamento", oFont10 )

    // Imprime a quantidade total e o sub-total do pedido de compra
	oPrint:Say( _nLin, 0950, "Totais dos Produtos", oFont10 )
	oPrint:Say( _nLin, 1380, Transform( _nQuant, cPcC7Quant ), oFont10b )
	oPrint:SayAlign( _nLin-20, 1950, Transform( _nTot, cPcC7Total ), oFont10b,250,5,CLR_BLACK,1/*Alinhado a direita*/ )
    SomaLinha(_nTamLin)

	oPrint:Say( _nLin, 0100, _cPrazoPag, oFont10b )
    
    // Imprime o Valor Total do IPI
	oPrint:Say( _nLin, 0950, "Valor do IPI", oFont10 )
	oPrint:SayAlign( _nLin-20, 1950, Transform( _nIpi, cPcC7Total), oFont10b,250,5,CLR_BLACK,1/*Alinhado a direita*/ )
    SomaLinha(_nTamLin)

    // Imprime o Tipo de Frete
	oPrint:Say( _nLin, 0100, "Tipo de Frete", oFont10 )

    // Imprime o Valor Total do ICMS Retido do Pedido de Compra
	oPrint:Say( _nLin, 0950, "Valor ICMS ST", oFont10 )
	oPrint:SayAlign( _nLin-20, 1950, Transform( _nRetido, cPcC7Total), oFont10b,250,5,CLR_BLACK,1/*Alinhado a direita*/ )
    SomaLinha(_nTamLin)

    oPrint:Say( _nLin, 0100, _TpFrete, oFont10b )

    // Imprime o Sub-Total dos Produtos
	oPrint:Say( _nLin, 0950, "Sub-Total", oFont10 )
	oPrint:SayAlign( _nLin-20, 1950, Transform( _nTot + _nIpi + _nRetido, cPcC7Total), oFont10b,250,5,CLR_BLACK,1/*Alinhado a direita*/ )
    SomaLinha(_nTamLin)
	
    // Imprime o noe da transportadora se informado
    oPrint:Say( _nLin, 0100, "Transportadora", oFont10 )

    // Imprime o Valor Total do Frete
	oPrint:Say( _nLin, 0950, "Valor do Frete", oFont10 )
	oPrint:SayAlign( _nLin-20, 1950, Transform( _nFrete, cPcC7Total), oFont10b,250,5,CLR_BLACK,1/*Alinhado a direita*/ )
    SomaLinha(_nTamLin)

    oPrint:Say( _nLin, 0100, _Transporte, oFont10b )

    // Imprime o Valor Total do Pedido de Compra
	oPrint:Say( _nLin, 0950, "Valor Total do Pedido", oFont10 )
	oPrint:SayAlign( _nLin-20, 1950, Transform( _nTot + _nIpi + _nRetido + _nFrete , cPcC7Total), oFont10b,250,5,CLR_BLACK,1/*Alinhado a direita*/ )

	If _nMoeda > 1
        SomaLinha(_nTamLin)
		oPrint:Say( _nLin, 0100, "Cotação US$", oFont10 )
		oPrint:Say( _nLin, 0300, "R$ "+ AllTrim( Transform( _nCotDia, "@E 99.9999") ) +" - "+ DtoC( _dCotDia ), oFont10b )
	EndIf
    SomaLinha(_nTamLin)

    // Linha Vertical no meio da página
	oPrint:Line( nLinVertical, 900, _nLin, 900 )

    // Linha horizontal
	oPrint:Line( _nLin, 050, _nLin, 2300 )
	SomaLinha(_nTamLin/2)

	oPrint:Say( _nLin, 0100, "NOTAS: ", oFont10b )
	SomaLinha(_nTamLin)
	
	aNotas := {}
    AADD(aNotas,'Favor observar o número deste pedido nas informações complementares da nota e enviá-la juntamente com o boleto e arquivo XML para o email nota@sirtec.com.br.' )
	AADD(aNotas,'VENCIMENTOS: O vencimento dos títulos deverão seguir os prazos descritos no pedido e coincidir em QUINTAS-FEIRAS, podendo então o prazo ser maior que 30 dias.' )
	AADD(aNotas,'ATENÇÃO: o envio do xml da nota de produto e serviço constando o número do pedido é obrigatório, o não envio das mesmas poderá não ocorrer o pagamento.' )

	For n:= 1 TO Len(aNotas)
		nBuffer:= 150
		nX := mlcount(aNotas[n],nBuffer)
		For L:=1 To nX
			oPrint:Say( _nLin, 0130, memoline(aNotas[n],nBuffer,L), oFont10 )
			SomaLinha(40)
		Next L
	Next n

	//SomaLinha(_nTamLin)

    // Linha horizontal final
	oPrint:Line( _nLin, 0050, _nLin, 2300 )

	oPrint:EndPage()
	
	_nQuant := 0
	_nTot   := 0
	_nIpi   := 0
	aObs    := {}

Return


/*/{Protheus.doc} LogoSirtec
Retorna o nome do arquivo onde está o logo
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 01/11/2021
@return character, Nome do arquivo com o Logo
/*/
Static Function LogoSirtec()

	Local cBitmap := "LGRL" + AllTrim(SM0->M0_CODIGO) + AllTrim(SM0->M0_CODFIL) + ".BMP"

	If !File( cBitmap )
		cBitmap := "LGRL"+SM0->M0_CODIGO+".BMP" // Empresa
	EndIf

Return( cBitmap )


/*/{Protheus.doc} PCTotLib
Verifica se o PC está totalmente liberado
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 01/11/2021
@param cNumPC, variant, Numero do PC
@return logical, .T. se o PC está totalmente liberado, .F. caso ainda falte alguma liberação.
/*/
Static Function PCTotLib(cNumPC)

	Local lRet := .T.
	
	dbSelectArea("SCR")
	dbSetOrder(2) //CR_FILIAL+CR_TIPO+CR_NUM+CR_USER
	DbGoTop()
	If ( dbSeek(xFilial("SCR") + "PC" + cNumPC ) )
		While ( !SCR->(EOF()) .And. SCR->CR_TIPO == "PC" .And. Alltrim(SCR->CR_NUM) == cNumPC )
			If ( SCR->CR_STATUS == "01" .Or. SCR->CR_STATUS == "02" .Or. SCR->CR_STATUS == "04" .Or. SCR->CR_STATUS == "06" )
				lRet := .F.
				Exit
			EndIf
			SCR->(dbSkip())
		EndDo
	EndIf

Return(lRet)


/*/{Protheus.doc} SIRALTM
Para confirmar e/ou alterar o email do fornecedor.
@type function
@version 12.1.25
@author Mauro - Solutio
@since 07/12/2021
@param cEdit1
@return cRet_, e-mail confirmado, ou alterado.
/*/

Static Function SIRALTM(_cMail)

	Local cEdit1	:= Space(40)
	Local oEdit1
	Local nOpc_		:= 0
	Local cRet_		:= Space(40)

	Private _oDlg

	cEdit1	:= _cMail
	cRet_	:= _cMail

	DEFINE MSDIALOG _oDlg TITLE "Endereços de E-mail." FROM C(343),C(506) TO C(590),C(1042) PIXEL

		@ C(012),C(065) Say "Abaixo, o endereço para o qual será enviado o e-mail.." Size C(130),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(025),C(075) Say "Caso haja necessidade, altere o campo abaixo." Size C(113),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(050),C(035) Say "Para:" Size C(014),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(050),C(070) MsGet oEdit1 Var cEdit1 Size C(150),C(009) COLOR CLR_BLACK PIXEL OF _oDlg 
		@ C(085),C(045) Button "Confirma" Size C(037),C(012) Action(nOpc_ := 1, _oDlg:End()) PIXEL OF _oDlg
		@ C(085),C(185) Button "Cancela" Size C(037),C(012) Action(nOpc_ := 2, _oDlg:End()) PIXEL OF _oDlg

	ACTIVATE MSDIALOG _oDlg CENTERED
	
	If nOpc_ == 1 .And. !Empty(Alltrim(cEdit1))
		cRet_ := cEdit1
	EndIf

Return(cRet_)

/*/{Protheus.doc} C
Ajuste automático da tela.
@type function
@version 12.1.25
@author Mauro - Solutio
@since 07/12/2021
@param 
@return 
/*/
Static Function C(nTam)                                                         
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
		nTam *= 0.8                                                                
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600                
		nTam *= 1                                                                  
	Else	// Resolucao 1024x768 e acima                                           
		nTam *= 1.28                                                               
	EndIf                                                                         
                                                                                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                               
	//³Tratamento para tema "Flat"³                                               
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                               
	If "MP8" $ oApp:cVersion                                                      
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()                      
			nTam *= 0.90                                                            
		EndIf                                                                      
	EndIf                                                                         
Return Int(nTam)
