#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE "FWPRINTSETUP.CH" 
#INCLUDE "RPTDEF.CH"  

#INCLUDE "RHNPMEURH.CH"


/*/{Protheus.doc}RHNPMEURH
   - Funções que possibilitam customizações futuras pelos clientes MeuRH;
/*/

User Function NoticeVacationReport( aDados, cLocal, cFileName )
Local oPrint
Local lRet        := .T.
Local nLin        := 0
Local nSizePage   := 0
Local nTamMarg    := 25
Local cArqLocal   := ""
Local oFont10n    := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)	//Normal negrito
Local oFont10     := TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)	//Normal s/ negrito

Default aDados    := {} //informações para a geração do recibo
Default cLocal    := "" //local para a gravação do arquivo
Default cFileName := "" //nome do arquivo pdf esperado na saida


//Informações sobre a estrutura esperada do array de dados
// aDados[1]  = tipo do aviso            (P=programado) (F=Férias) 
// aDados[2]  = cCompanyState            (estado federativo da empresa)
// aDados[3]  = dNoticeDate              (data do aviso)
// aDados[4]  = cEmployeeName            (nome do funcionário)
// aDados[5]  = cLaborCardNumber         (carteira de trabalho)
// aDados[6]  = cLaborCardSeries         (série da carteira de trabalho) 
// aDados[7]  = cFunctionDescription     (descrição da função)
// aDados[8]  = nPaydLeaveFollow         (dias de licença remunerada mês seguinte - férias calculadas)
// aDados[9]  = nPaydLeave               (dias de licença remunerada - férias calculadas)
// aDados[10] = dAcquisitiveStartDate   (data de inicio do período aquisitivo)
// aDados[11] = dAcquisitiveEndDate     (data de término do período aquisitivo)
// aDados[12] = dEnjoymentStart         (data de inicio do gozo de férias)
// aDados[13] = dEnjoymentEndDate       (data de término do gozo de férias)
// aDados[14] = cCompanyName            (nome descritivo da empresa)
// aDados[15] = cCompanyCNPJ            (CNPJ da empresa)
// aDados[16] = nPecuniaryAllowance     (dias de abono pecuniário - férias calculadas/programadas)
// aDados[17] = cAccept                 (informações do aceite - férias calculadas)
// aDados[18] = cBranch                 (filial do funcionário)
// aDados[19] = cMat                    (matricula do funconário)
// aDados[20] = cAdmissionDate          (admissão do funconário)
// aDados[21] = cReceiptDate            (data do recibo)


If valtype(aDados) != "A" .or. len(aDados) <> 21 .or. empty(cFileName)
   lRet := .F.
EndIf

//geração do html para o recibo de férias
If lRet

	oPrint := FWMSPrinter():New(cFileName+".rel", IMP_PDF, .F., cLocal, .T., , , , .T., , .F., )
	
	oPrint:SetPortrait()
    oPrint:SetPaperSize(DMPAPER_A4)
	oPrint:SetMargin(nTamMarg,nTamMarg,nTamMarg,nTamMarg)
	oPrint:StartPage()

	nSizePage := oPrint:nPageWidth / oPrint:nFactorHor

	nLin += 30
	oPrint:Say(nLin, 15, OemToAnsi(STR0001), oFont10n) //"Aviso de Férias"
	nLin += 05		
	oPrint:Line(nLin, 15, nLin, nSizePage-(nTamMarg*2))
	
	nLin += 50
	cMsgLine := AllTrim(aDados[2]) +', ' +SubStr(DtoC( aDados[3] ),1,2) +STR0002 +MesExtenso(Month(aDados[3])) +STR0002 +STR(Year(aDados[3]),4) 
	oPrint:Say(nLin, 15, cMsgLine, oFont10) 

	nLin += 40		
	cMsgLine := STR0003 //"A(o) Sr(a)" 
	oPrint:Say(nLin, 15, cMsgLine, oFont10) 
	nLin += 15		
	cMsgLine := Left(aDados[4],30) 
	oPrint:Say(nLin, 15, cMsgLine, oFont10) 
	nLin += 10		
	cMsgLine := STR0004 +aDados[5] +' - ' +aDados[6] +SPACE(8) +STR0005 +aDados[7]  //"CTPS: " / "Depto: "
	oPrint:Say(nLin, 15, cMsgLine, oFont10) 

	nLin += 40		
	oPrint:Say(nLin, 15, STR0006 +" " +STR0007, oFont10)  //"Nos termos da legislação vigente, suas férias serão" "concedidas conforme as informações abaixo:"

    If aDados[1] == "F" //Férias calculadas
       nLin += 15		
	   cMsgLine := STR0009 +Padr(DtoC(aDados[10]),10) +STR0013 +Padr(DtoC(aDados[11]),10) //"Período Aquisitivo: " " a "
	   oPrint:Say(nLin, 15, cMsgLine, oFont10)

       nLin += 10
       cMsgLine := STR0010 +Padr(DtoC(aDados[12]),10) +STR0013 +Padr(DtoC(aDados[13]),10) //"Período de Gozo: "  " a "
 	   oPrint:Say(nLin, 15, cMsgLine, oFont10)  

       If ( aDados[8] + aDados[9] ) > 0
          If aDados[9] == 30
              nLin += 10		
	          cMsgLine := STR0011 + CVALTOCHAR(aDados[8] + aDados[9]) //"Qtd Lic.remun.: " 
	          oPrint:Say(nLin, 15, cMsgLine, oFont10) 
          EndIf
       EndIf

    ElseIf aDados[1] == "P" //Férias programadas
        nLin += 15
	    cMsgLine := STR0010 +Padr(DtoC(aDados[12]),10) +STR0013 +Padr(DtoC(aDados[13]),10) //"Período de Gozo: "  " a "
	    oPrint:Say(nLin, 15, cMsgLine, oFont10)  
    EndIf

    nLin += 10
    cMsgLine := STR0015 + Padr(DtoC( aDados[13]+1 ),10) //"Retorno ao Trabalho: "
    oPrint:Say(nLin, 15, cMsgLine, oFont10)  

    //montagem para assinaturas
    nLin += 50
    cMsgLine := replicate("_",30) +space(20) +replicate("_",30)
    oPrint:Say(nLin, 30, cMsgLine, oFont10)  

    nLin += 15
    cMsgLine := aDados[14] +space(60) +aDados[4]
    oPrint:Say(nLin, 60, cMsgLine, oFont10)  

		
	oPrint:EndPage()

	cArqLocal		:= cLocal+cFileName+".PDF"		
	oPrint:cPathPDF := cLocal 
	oPrint:lViewPDF := .F.
	oPrint:Print()

EndIf

Return(lRet)

/*/{Protheus.doc}RHNPMEURH
   - Funções que possibilitam customizações futuras pelos clientes MeuRH;
   - Geracao dos arquivos PDF no App MeuRH dos recibos de Ferias com ou Abono e 1a. Parcela do 13o. 
/*/
User Function VacationReport( aCabec, aVerbas, aInfo, cLocal, cFileName )

Local cValor1     := ""
Local cValor2     := ""
Local cPdPens     := ""
Local cRet1       := ""
Local cRet2       := ""
Local cEndEmp     := ""
Local cLocalEmp   := ""
Local cVerb13o    := "0022"

Local nLin        := 0
Local nReg        := 0
Local nBenef      := 0
Local nPen13o     := 0
Local nVal13a     := 0
Local nVal13o     := 0
Local nValAb      := 0
Local nValAb13    := 0
Local nMaximo     := 0
Local nTotDesc    := 0
Local nTotProv    := 0
Local nLinAbI     := 0  //Linha inicial do Abono
Local nLinPcI     := 0  //Linha inicial do Parcela do 13o.
Local nLinPDI     := 0  //Linha inicial das verbas do recibo de ferias
Local nLinPDF     := 0  //Linha final impressao das verbas do recibo de ferias
Local nAligE      := 40 //Alinhamento do texto a esquerda
Local nSoma10     := 10 //Adiciona 10 espacos na linha
Local nSoma20     := 20 //Adiciona 20 espacos na linha
Local nSoma25     := 25 //Adiciona 25 espacos na linha

Local oFont14     := TFont():New("Courier new",14,14,,.F.,,,,.T.,.F.)

Local aProv       := {}
Local aDesc       := {}
Local aCodBenef   := {}
Local aVerbsAbo   := { "0074", "0617", "0622", "0623", "0632", "0633", "0634", "0635", ;
                       "1312", "1313", "1314", "1315", "1316", "1317", "1318", "1319", ;
                       "1320", "1321", "1322", "1323", "1324", "1325", "1326", "1327", ;
                       "1330", "1331", "1407", "1408", "1409", "1410", "0205", "0079", ;
                       "0206" }

Default aInfo     := {} //Matriz com os dados da Empresa/Filial
Default aCabec    := {} //informações para a geração do recibo
Default aVerbas   := {} //informações para a geração do recibo
Default cLocal    := "" //local para a gravação do arquivo
Default cFileName := "" //nome do arquivo pdf esperado na saida

If !Empty(aCabec) .And. !Empty(aVerbas) .And. !Empty(aInfo) 

	//Busca os codigos de pensao sob 13o. Salario definidos no cadastro beneficiario
	fBusCadBenef( @aCodBenef, "131", { fGetCodFol("0172") } )	
	For nBenef := 1 To Len(aCodBenef)
		cPdPens += aCodBenef[nBenef,1] + "|"
	Next nBenef	
	
	//Licenca remunerada
	If aCabec[1,10] + aCabec[1,11] > 0 
		nDiaFeQueb := aCabec[1,3] - Int(aCabec[1,3])
		DaAuxF := aCabec[1,5] + If(nDiaFeQueb>0 , 1, 0 )
	Else
		DaAuxF := aCabec[1,5]
    EndIf	
	
	//Periodos: Aquisitivo e gozo de Ferias
	PER_AQ_I := STRZERO( DAY( aCabec[1,08]),2) + STR0002 + MesExtenso(MONTH( aCabec[1,08])) + STR0002 + STR(YEAR( aCabec[1,08]),4)	//" De "###" De "
	PER_AQ_F := STRZERO( DAY( aCabec[1,09]),2) + STR0002 + MesExtenso(MONTH( aCabec[1,09])) + STR0002 + STR(YEAR( aCabec[1,09]),4)	//" De "###" De "
	PER_GO_I := STRZERO( DAY( aCabec[1,04]),2) + STR0002 + MesExtenso(MONTH( aCabec[1,04])) + STR0002 + STR(YEAR( aCabec[1,04]),4)	//" De "###" De "
	PER_GO_F := STRZERO( DAY( aCabec[1,05]),2) + STR0002 + MesExtenso(MONTH( aCabec[1,05])) + STR0002 + STR(YEAR( aCabec[1,05]),4)	//" De "###" De "

	cNameFun	:= If( !Empty(SRA->RA_NOMECMP), AllTrim( SRA->RA_NOMECMP ), AllTrim( SRA->RA_NOME ) )
	cCtps		:= If( Empty(SRA->RA_NUMCP),Space(7),AllTrim(SRA->RA_NUMCP))+" - "+SRA->RA_SERCP + SPACE(01) + STR0055 + Space(1) + SRA->RA_FILIAL+" "+SRA->RA_MAT //"Registro: "
	cDiasFMes 	:= If( (nPd := aScan( aVerbas, { |x| x[2] == "0072" }) ) > 0, Transform( aVerbas[nPd,5], "@E 999,999.99"), Transform( 0, "@E 999,999.99") )
	cDiasFMSeg 	:= If( (nPd := aScan( aVerbas, { |x| x[2] == "0073" }) ) > 0, Transform( aVerbas[nPd,5], "@E 999,999.99"), Transform( 0, "@E 999,999.99") )
	cDiasAbMes 	:= If( (nPd := aScan( aVerbas, { |x| x[2] == "0074" }) ) > 0, Transform( aVerbas[nPd,5], "@E 999,999.99"), Transform( 0, "@E 999,999.99") )
	cDiasAbMSeg	:= If( (nPd := aScan( aVerbas, { |x| x[2] == "0205" }) ) > 0, Transform( aVerbas[nPd,5], "@E 999,999.99"), Transform( 0, "@E 999,999.99") )	
	cLicRemun	:= cValToChar( aCabec[1,10] + aCabec[1,11] )

	//Dados da empresa e local de pagamento
	cRecEmp		:= STR0016 + Space(1) + SubStr(aInfo[3], 1, 50) //"Recebi da:"
	cEndEmp  	:= STR0017 + Space(1) + SubStr(AllTrim(aInfo[4]),1,30) + " - " + STR0018 + Space(1) + AllTrim(aInfo[7]) //"Estabelecida a"#"Cep:"
	cLocalEmp	:= STR0019 + Space(1) + SubStr(AllTrim(aInfo[5]),1,25) + " - " + STR0020 + Space(1) + AllTrim(aInfo[6]) //"Cidade:"#"UF:" 
	
	//Data de pagamento
	cDtPagExt	:= StrZero(Day(aCabec[1,7]),2) + STR0002 //" de " 
	cDtPagExt	+= MesExtenso(Month(aCabec[1,7])) + STR0002 //" de " 
	cDtPagExt	+= STR(YEAR(aCabec[1,7]),4) 
	
	cDtPag		:= ALLTRIM(aInfo[5]) + ", " + cDtPagExt
	cDtReceb	:= STR0021 + Space(1) + SubStr( AllTrim(aInfo[5]),1,25) + ", " + cDtPagExt + Space(1) + STR0022 //"em"#"a importancia Liquida de"

	cDescCC   := AllTrim(EncodeUTF8(fDesc('CTT',SRA->RA_CC,'CTT->CTT_DESC01',,SRA->RA_FILIAL)))
	cDescDpto := AllTrim(EncodeUTF8(fDesc('SQB',SRA->RA_DEPTO,'SQB->QB_DESCRIC',,SRA->RA_FILIAL)))

	//-----------------------------------------------------------------------
	//Avalia as verbas que serao impressas nos recibos 
	//-----------------------------------------------------------------------
	For nReg := 1 TO Len(aVerbas)
		
		//Proventos de ferias
		If aVerbas[nReg,1] == "1" .And. aScan( aVerbsAbo, aVerbas[nReg,2] ) == 0
			If !aVerbas[nReg,2] $ cVerb13o
				nTotProv +=	aVerbas[nReg,4]
				aAdd( aProv, { aVerbas[nReg,3], aVerbas[nReg,6], aVerbas[nReg,5], aVerbas[nReg,4] })
			EndIf
		EndIf

		//Descontos	(Nao considera pensao)
		If aVerbas[nReg,1] == "2" .And. aScan( aVerbsAbo, aVerbas[nReg,2] ) == 0 .And. !(aVerbas[nReg,3] $ cPdPens)
		  	If !aVerbas[nReg,2] $ "0102"
				nTotDesc += aVerbas[nReg,4]
				aAdd( aDesc, { aVerbas[nReg,3], aVerbas[nReg,6], aVerbas[nReg,5], aVerbas[nReg,4] })
			EndIf 		
		EndIf

		//Obtem os valores dde Abono
		If aScan( aVerbsAbo, aVerbas[nReg,2] ) > 0
			If aVerbas[nReg,2] $ "0079||0206"
				nValAb13 += aVerbas[nReg,4]
			Else 
				nValAb += aVerbas[nReg,4]
			EndIf
		EndIf
		
		//Obtem o valor da 1o. Parcela 13o. Salario
		If aVerbas[nReg,2] == cVerb13o 
			nVal13o += aVerbas[nReg,4]
		EndIf	

	Next nReg	
	
	//-----------------------------------------------------------------------
	//IMPRESSAO DO RECIBO DE FERIAS
	//-----------------------------------------------------------------------

	//Inicio da atribuicao dos objetos graficos do relatorio
	oPrint := FWMSPrinter():New(cFileName+".rel", IMP_PDF, .F., cLocal, .T., , , , .T., , .F., )
	
	oPrint:SetPortrait()
	oPrint:StartPage()

	nSizePage := oPrint:nPageWidth / oPrint:nFactorHor

	//Box superior
	nLin  	+= 60
	oPrint:Box( nLin-10,030,260,575)

	nLin  += 5	 
	oPrint:Say( nLin, 235, STR0023, 			oFont14) //"RECIBO DE FERIAS"
	nLin  += nSoma10
	oPrint:Say( nLin, 235, REPLICATE("=",16),	oFont14)

	nLin  += 30
	oPrint:Say( nLin, nAligE,	STR0024,		oFont14) //"Nome do Empregado.......:"
	oPrint:Say( nLin, 220,		cNameFun, 		oFont14)
	
	nLin  += nSoma10
	oPrint:Say( nLin, nAligE,	STR0025, 		oFont14) //"Carteira Trabalho.......:"
	oPrint:Say( nLin, 220,		cCtps, 			oFont14)

	nLin  += nSoma10
	oPrint:Say( nLin, nAligE,	STR0026, 		oFont14) //"Periodo Aquisitivo......:"
	oPrint:Say( nLin, 220,		PER_AQ_I + STR0027 + PER_AQ_F, 	oFont14) //" A "	
	
	nLin  += nSoma10
	oPrint:Say( nLin, nAligE,	STR0028, 		oFont14) //"Periodo Gozo das Ferias.:"
	oPrint:Say( nLin, 220,		PER_GO_I + STR0027 + PER_GO_F, 	oFont14) //" A "
	
	nLin  += nSoma10
	oPrint:Say( nLin, nAligE,	STR0029, 		oFont14) //"Qtde. Dias Lic. Remun...:"
	oPrint:Say( nLin, 220,		cLicRemun, 		oFont14)

	nLin  += nSoma10
	oPrint:Line(nLin,030,nLin,575)	//Linha horizontal
	nLin  += 15
	oPrint:Say( nLin, 160, 		STR0030, 		oFont14) //"DADOS PARA CALCULO DE PAGAMENTO DE FERIAS"
	nLin  += nSoma10
	oPrint:Line(nLin,030,nLin,575)	//Linha horizontal

	nLin  += 15
	oPrint:Say( nLin, nAligE, 	STR0031, 	 	oFont14) //"Salario Mes.............:"
	oPrint:Say( nLin, 220,		Transform(SRH->RH_SALMES,"@E 999,999.99"), 	oFont14)
	oPrint:Say( nLin, 315, 		STR0032, 		oFont14) //"Salario Hora.........:"
	oPrint:Say( nLin, 500,		Transform(SRH->RH_SALHRS,"@E 999,999.99"), 	oFont14)	

	nLin  += nSoma10
	oPrint:Say( nLin, nAligE,	STR0033,		oFont14) //"Valor Dia Mes...........:"
	oPrint:Say( nLin, 220,		Transform(SRH->RH_SALDIA,"@E 999,999.99"), 	oFont14)	
	oPrint:Say( nLin, 315, 		STR0034, 		oFont14) //"Valor Dia Mes Seg....:"
	oPrint:Say( nLin, 500,		Transform(SRH->RH_SALDIA1,"@E 999,999.99"), oFont14)

	nLin  += nSoma10
	oPrint:Say( nLin, nAligE, 	STR0035, 		oFont14) //"Dias Ferias Mes.........:"
	oPrint:Say( nLin, 220,		cDiasFMes, 		oFont14)	
	oPrint:Say( nLin, 315, 		STR0036, 		oFont14) //"Dias Ferias Mes Seg..:"
	oPrint:Say( nLin, 500,		cDiasFMSeg, 	oFont14)

	nLin  += nSoma10
	oPrint:Say( nLin, nAligE, 	STR0037, 		oFont14) //"Dias Abono Mes..........:"
	oPrint:Say( nLin, 220, 		cDiasAbMes, 	oFont14)
	oPrint:Say( nLin, 315, 		STR0038, 		oFont14) //"Dias Abono Mes Seg...:"
	oPrint:Say( nLin, 500, 		cDiasAbMSeg, 	oFont14)
	
	nLin  	+= nSoma10
	nLinPDI	:= nLin 

	oPrint:Line(nLin,030,nLin,575)	//Linha horizontal
	nLin  	+= 15
	nLinPDF	+= 15
	oPrint:Say( nLin, 105, 		STR0039, 		oFont14) //"P R O V E N T O S"
	oPrint:Say( nLin, 380, 		STR0040, 		oFont14) //"D E S C O N T O S"	
	nLin  	+= nSoma10
	nLinPDF	+= nSoma10
	oPrint:Line(nLin,030,nLin,575)	//Linha horizontal
	
	nLin  	+= 15
	nLinPDF	+= 15
	
	oPrint:Say( nLin, nAligE, 		STR0041,  	oFont14) //"Cód"
	oPrint:Say( nLin, nAligE+30,	STR0042,  	oFont14) //"Verba"
	oPrint:Say( nLin, nAligE+160,	STR0043,  	oFont14) //"Q/H"
	oPrint:Say( nLin, nAligE+220,	STR0044,  	oFont14) //"Valor"

	oPrint:Say( nLin, 310, 			STR0041,  	oFont14) //"Cód"
	oPrint:Say( nLin, 340,			STR0042,  	oFont14) //"Verba"
	oPrint:Say( nLin, 470,			STR0043,  	oFont14) //"Q/H"
	oPrint:Say( nLin, 530,			STR0044,  	oFont14) //"Valor"

	//-----------------------------------------------------------------------
	//Impressao das verbas do recibo de ferias 
	//-----------------------------------------------------------------------
	nMaximo := MAX(Len(aProv),Len(aDesc))
	For nReg := 1 TO nMaximo

		nLin  	+= nSoma10
		nLinPDF	+= nSoma10
		
		//Proventos de ferias
		If nReg <= Len(aProv)
			oPrint:Say( nLin, nAligE, 		aProv[nReg,1],								oFont14)
			oPrint:Say( nLin, nAligE+30,	SubStr(aProv[nReg,2],1,15),				oFont14)
			oPrint:Say( nLin, nAligE+150,	Transform(aProv[nReg,3], '@E 99.99'),		oFont14)
			oPrint:Say( nLin, nAligE+190,	Transform(aProv[nReg,4], '@E 999,999.99'),	oFont14)
		EndIf

		//Descontos	(Nao considera pensao)
		If nReg <= Len(aDesc)
			oPrint:Say( nLin, 310, 			aDesc[nReg,1],								oFont14)
			oPrint:Say( nLin, 340,			SubStr(aDesc[nReg,2],1,15),				oFont14)
			oPrint:Say( nLin, 460,			Transform(aDesc[nReg,3], '@E 99.99'),		oFont14)
			oPrint:Say( nLin, 500,			Transform(aDesc[nReg,4], '@E 999,999.99'),	oFont14)
		EndIf

	Next nReg
	
	//Tratamento do valor extenso
	//-----------------------------------------------------------------------
	cValor1	:= STR0045 + TRANSFORM(nTotProv-nTotDesc,"@E 999,999.99") + " (" //"R$"
	cValExt	:= Extenso(nTotProv-nTotDesc,.F.,1)
	nTamMax	:= 80 - Len(cValor1)
	SepExt(cValExt, nTamMax, 80, @cRet1, @cRet2)
	
	cValor1 += AllTrim(cRet1)
	If !Empty(cRet2)
		cValor2 += AllTrim(cRet2) + ".****)"
	Else
		cValor1 += ")"
	EndIf	
	//-----------------------------------------------------------------------
	
	//Total proventos e descontos
	nLin  	+= 30
	nLinPDF	+= 30
	oPrint:Say( nLin, nAligE, 		STR0046,		oFont14) //"Total Proventos......:"
	oPrint:Say( nLin, 310, 			STR0047,		oFont14) //"Total Descontos......:"

	oPrint:Say( nLin, nAligE+190,	Transform(nTotProv,'@E 999,999.99'),	oFont14)
	oPrint:Say( nLin, 500,			Transform(nTotDesc,'@E 999,999.99'),	oFont14)

	nLin  	+= nSoma10
	nLinPDF	+= nSoma10
	oPrint:Line(nLin,030,nLin,575)						//Linha horizontal
	oPrint:Line(nLinPDI, 030, nLinPDI+nLinPDF, 030)		//Linha vertical direita
	oPrint:Line(nLinPDI, 300, nLinPDI+nLinPDF, 300)		//Linha vertical centro
	oPrint:Line(nLinPDI, 575, nLinPDI+nLinPDF, 575)		//Linha vertical esquerda

	nLin  += 15
	oPrint:Say( nLin, nAligE, 		STR0048,		oFont14) //"Liquido a receber....:"
	oPrint:Say( nLin, nAligE+190,	Transform(nTotProv-nTotDesc,'@E 999,999.99'),	oFont14)
	
	nLin  += nSoma10
	oPrint:Line(nLin,030,nLin,575)	//Linha horizontal

	nLin  += 15
	oPrint:Say( nLin, nAligE+10, 	cRecEmp, 		oFont14)
	nLin  += nSoma10
	oPrint:Say( nLin, nAligE+10, 	cEndEmp, 		oFont14)
	nLin  += nSoma10	
	oPrint:Say( nLin, nAligE+10, 	cLocalEmp,			oFont14)
	nLin  += nSoma10	
	oPrint:Say( nLin, nAligE+10, 	cDtReceb, 		oFont14)
	nLin  += nSoma10	
	oPrint:Say( nLin, nAligE+10, 	cValor1,		oFont14)
	
	//Valor por extenso impresso em duas linhas
	If !Empty(cValor2)
		nLin  += nSoma10
		oPrint:Say( nLin, nAligE+10, 	cValor2,	oFont14)
	EndIf
	
	nLin  += nSoma10	
	oPrint:Say( nLin, nAligE+10, STR0049, 	oFont14) //"que me paga adiantadamente por motivo das minhas ferias regulamentares,"
	nLin  += nSoma10	
	oPrint:Say( nLin, nAligE+10, STR0050, 	oFont14) //"ora concedidas que vou gozar de acordo com a descricao acima, tudo"
	nLin  += nSoma10	
	oPrint:Say( nLin, nAligE+10, STR0051, 	oFont14) //"conforme o aviso que recebi em tempo, ao qual dei meu ciente."
	nLin  += nSoma10	
	oPrint:Say( nLin, nAligE+10, STR0052, 	oFont14) //"Para clareza e documento, firmo o presente recibo, dando a firma plena e"
	nLin  += nSoma10	
	oPrint:Say( nLin, nAligE+10, STR0053, 	oFont14) //"geral quitacao."
	nLin  += nSoma25	
	oPrint:Say( nLin, nAligE+10, cDtPag, 	oFont14)
	nLin  += nSoma25	
	oPrint:Say( nLin, nAligE+200, STR0054 + Space(1) + REPLICATE("_",25), 	oFont14) //"Assinatura do Empregado:"
	nLin  += nSoma20

	oPrint:Line(nLin, 030, nLin, 575)				//Linha horizontal
	oPrint:Line(nLinPDI+nLinPDF, 030, nLin, 030)	//Linha vertical direita
	oPrint:Line(nLinPDI+nLinPDF, 575, nLin, 575)	//Linha vertical esquerda

	oPrint:EndPage()
	
	
	//-----------------------------------------------------------------------
	//IMPRESSAO DO RECIBO DO ABONO
	//-----------------------------------------------------------------------	
	If nValAb > 0 .Or. nValAb13 > 0
	
		cRet1  := ""
		cRet2  := ""		
		lPage2 := .T.

		//Define se o periodo do abono pecuniario será considerado antes ou depois do gozo de ferias
		If !Empty(aCabec[1,13])
			cAbono 	:= aCabec[1,13]
		Else
			cAbono	:= GetMv("MV_ABOPEC")                   
			cAbono 	:= If(cAbono=="S","1","2")
		EndIF
		
		If cAbono == "1"
			cDtAbon  := PADR(DtoC(aCabec[1,4]-aCabec[1,12]),10) +" a "+ Dtoc(aCabec[1,4]-1) 
			cDtGzFer := PADR(Dtoc(aCabec[1,4]),10) +" a "+ PADR(DtoC(DaAuxF),10)
		Else
			cDtAbon  := PADR(DtoC( DaAuxF + 1),10) +" a "+ PADR(Dtoc(DaAuxF+aCabec[1,12]),10)
			cDtGzFer := PADR(Dtoc(aCabec[1,4]),10) +" a "+ PADR(DtoC(DaAuxF),10)
		EndIf
	
		PER_AQ_I := STRZERO( DAY( aCabec[1,08]),2) + STR0002 + MesExtenso(MONTH( aCabec[1,08])) + STR0002 + STR(YEAR( aCabec[1,08]),4)	//" De "###" De "
		PER_AQ_F := STRZERO( DAY( aCabec[1,09]),2) + STR0002 + MesExtenso(MONTH( aCabec[1,09])) + STR0002 + STR(YEAR( aCabec[1,09]),4)	//" De "###" De "
		PER_GO_I := STRZERO( DAY( aCabec[1,04]),2) + STR0002 + MesExtenso(MONTH( aCabec[1,04])) + STR0002 + STR(YEAR( aCabec[1,04]),4)	//" De "###" De "
		PER_GO_F := STRZERO( DAY( aCabec[1,05]),2) + STR0002 + MesExtenso(MONTH( aCabec[1,05])) + STR0002 + STR(YEAR( aCabec[1,05]),4)	//" De "###" De "
	
		oPrint:StartPage()
		
		//Inicio da atribuicao dos objetos graficos do relatorio
		nLin  	:= 60
		nLinAbI := nLin-10
	
		nLin  += 5	 
		oPrint:Say( nLin, 200, STR0056, 							oFont14) //"RECIBO DE ABONO DE FERIAS"
		nLin  += nSoma10
		oPrint:Say( nLin, 200, REPLICATE("=",25),					oFont14)
	
		nLin  += 30
		oPrint:Say( nLin, nAligE+50,	cNameFun,					oFont14) //Nome do Empregado
		
		nLin  += nSoma10
		oPrint:Say( nLin, nAligE+50,	cCtps, 						oFont14) //Carteira Trabalho
		oPrint:Say( nLin, 360,			STR0057 +" "+ cDescCC,		oFont14) //"C.CUSTO:"
	
		nLin  += nSoma10
		oPrint:Say( nLin, 360,			cDescDpto, 					oFont14) //Departamento
		
		nLin  += nSoma25
		oPrint:Say( nLin, 220,			STR0058, 					oFont14) //"D E M O N S T R A T I V O"
		
		nLin  += nSoma25
		oPrint:Say( nLin, nAligE,		STR0059,					oFont14) //"Periodo de ferias em abono pecuniario"	
		oPrint:Say( nLin, 350,			STR0060,	 				oFont14) //"Periodo de gozo de ferias"
	
		nLin  += nSoma10
		oPrint:Say( nLin, nAligE+50,	cDtAbon,					oFont14) //Periodo de abono
		oPrint:Say( nLin, 370,			cDtGzFer,					oFont14) //Periodo do gozo de ferias

		nLin  += 30
		oPrint:Say( nLin, nAligE+50,	STR0061 + " (" + STR(aCabec[1,12],3) + ") " + STR0062,	oFont14) //"Abono"#"Dias: "
		oPrint:Say( nLin, 310,			Transform(nValab, '@E 999,999.99'),						oFont14)
		nLin  += nSoma10
		oPrint:Say( nLin, nAligE+50,	STR0063,												oFont14) //"Acrescimo 1/3:"
		oPrint:Say( nLin, 310,			Transform(nValAb13,'@E 999,999.99'),					oFont14)
		nLin  += nSoma10
		oPrint:Say( nLin, nAligE+50,	STR0064,												oFont14) //"Liquido:"
		oPrint:Say( nLin, 310,			Transform(nValab+nValAb13,'@E 999,999.99'),				oFont14)

		nLin  += 30
		oPrint:Say( nLin, nAligE+100, 	cRecEmp, 					oFont14)
		nLin  += nSoma10		
		oPrint:Say( nLin, nAligE+50, 	STR0065, 					oFont14) //"a importancia Liquida de"		

		//Tratamento do valor extenso
		//-----------------------------------------------------------------------
		cValor1	:= STR0045 + TRANSFORM(nValab+nValAb13,"@E 999,999.99") + " (" //"R$"
		cValExt	:= Extenso(nValab+nValAb13,.F.,1)
		nTamMax	:= 40 - Len(cValor1)
		SepExt(cValExt, nTamMax, 80, @cRet1, @cRet2)
		
		cValor1 += AllTrim(cRet1)
		cValor2 := ""
		If !Empty(cRet2)
			cValor2 += AllTrim(cRet2) + ".****)"
		Else
			cValor1 += ")"
		EndIf	
		//-----------------------------------------------------------------------

		oPrint:Say( nLin, nAligE+230, 		cValor1,		oFont14)	
		//Valor por extenso impresso em duas linhas
		If !Empty(cValor2)
			nLin  += nSoma10
			oPrint:Say( nLin, nAligE+50, 	cValor2,		oFont14)
		EndIf		
		nLin  += nSoma10
		oPrint:Say( nLin, nAligE+50, 		STR0066, 		oFont14) //"conforme demonstrativo acima, referente ao abono pecuniario."
		
		nLin  += 30	
		oPrint:Say( nLin, nAligE, cDtPag, 					oFont14)
		nLin  += nSoma10	
		oPrint:Say( nLin, nAligE+300, REPLICATE("_",35), 	oFont14)
		nLin  += 15	
		oPrint:Say( nLin, nAligE+300, cNameFun, 			oFont14)
		nLin  += nSoma20

		oPrint:Line(nLinAbI, 030, nLinAbI, 575)	//Linha horizontal superior
		oPrint:Line(nLinAbI, 030, nLin, 030)	//Linha vertical direita
		oPrint:Line(nLinAbI, 575, nLin, 575)	//Linha vertical esquerda
		oPrint:Line(nLin,    030, nLin, 575)	//Linha horizontal inferior

	EndIf
	
	
	//-----------------------------------------------------------------------
	//IMPRESSAO DO RECIBO DA 1a. PARCELA DO 13o. SALARIO
	//-----------------------------------------------------------------------
	If nVal13o > 0
	
		cRet1 := ""
		cRet2 := ""		

		If !lPage2
			oPrint:StartPage()
			nLin  	:= 60
			nLinPcI := nLin-nSoma10
		Else
			nLin  	+= 30
			nLinPcI := nLin-nSoma10		
		EndIf

		//Obtem os valores de pensao do 13o. Salario
		For nReg := 1 To Len(aVerbas)
			If aVerbas[nReg,3] $ cPdPens
				nPen13o += aVerbas[nReg,4]
			EndIf
		Next nReg
		
		//Inicio da atribuicao dos objetos graficos do relatorio
	
		nLin  += 5	 
		oPrint:Say( nLin, 170, STR0067, 						oFont14) //"RECIBO DA 1a. PARCELA DO 13o SALARIO"
		nLin  += nSoma10
		oPrint:Say( nLin, 170, REPLICATE("=",36),				oFont14)
	
		nLin  += 30
		oPrint:Say( nLin, nAligE+50,	cNameFun,				oFont14) //Nome do Empregado
		
		nLin  += nSoma10
		oPrint:Say( nLin, nAligE+50,	cCtps, 					oFont14) //Carteira Trabalho
		oPrint:Say( nLin, 360,			STR0057 +" "+ cDescCC,	oFont14) //"C.CUSTO:"
	
		nLin  += nSoma10
		oPrint:Say( nLin, 360,			cDescDpto, 				oFont14) //Departamento
		
		nLin  += nSoma25
		oPrint:Say( nLin, 220,			STR0058, 				oFont14) //"D E M O N S T R A T I V O"
		
		nLin  += nSoma25
		oPrint:Say( nLin, nAligE+50,	STR0068,				oFont14) //"1a Parcela do 13o Salario:"
		oPrint:Say( nLin, 310,			Transform(nVal13o, '@E 999,999.99'),		oFont14)
		nLin  += nSoma10
		oPrint:Say( nLin, nAligE+50,	STR0069,									oFont14) //"Adiantamento:"
		oPrint:Say( nLin, 310,			Transform(nVal13a,'@E 999,999.99'),			oFont14)
		
		If nPen13o > 0
			nLin  += nSoma10
			oPrint:Say( nLin, nAligE+50,	STR0070,								oFont14) //"Pensao:"
			oPrint:Say( nLin, 310,			Transform(nPen13o,'@E 999,999.99'),		oFont14)		
		EndIf
		
		nLin  += nSoma10
		oPrint:Say( nLin, nAligE+50,	STR0064,									oFont14) //"Liquido:"
		oPrint:Say( nLin, 310,			Transform(nVal13o-nVal13a-nPen13o,'@E 999,999.99'),	oFont14)
		
		nLin  += 30
		oPrint:Say( nLin, nAligE+100, 	cRecEmp, 									oFont14)
		nLin  += nSoma10		
		oPrint:Say( nLin, nAligE+50, 	STR0065, 									oFont14) //"a importancia Liquida de"		

		//Tratamento do valor extenso
		//-----------------------------------------------------------------------
		cValor1	:= STR0045 + TRANSFORM(nVal13o-nVal13a-nPen13o,"@E 999,999.99") + " (" //"R$"
		cValExt	:= Extenso(nVal13o-nVal13a-nPen13o,.F.,1)
		nTamMax	:= 40 - Len(cValor1)
		SepExt(cValExt, nTamMax, 80, @cRet1, @cRet2)
		
		cValor1 += AllTrim(cRet1)
		cValor2 := ""
		If !Empty(cRet2)
			cValor2 += AllTrim(cRet2) + ".****)"
		Else
			cValor1 += ")"
		EndIf	
		//-----------------------------------------------------------------------

		oPrint:Say( nLin, nAligE+230, 	cValor1,			oFont14)			
		//Valor por extenso impresso em duas linhas
		If !Empty(cValor2)
			nLin  += nSoma10
			oPrint:Say( nLin, nAligE+50, 	cValor2,		oFont14)
		EndIf
				
		nLin  += nSoma10
		oPrint:Say( nLin, nAligE+50, 		STR0071, 		oFont14) //"conforme demonstrativo acima, referente a 1a parcela do 13o salario."
		
		nLin  += 30	
		oPrint:Say( nLin, nAligE, cDtPag, 					oFont14)
		nLin  += nSoma10	
		oPrint:Say( nLin, nAligE+300, REPLICATE("_",35), 	oFont14)
		nLin  += 15	
		oPrint:Say( nLin, nAligE+300, cNameFun, 			oFont14)
		nLin  += nSoma20

		oPrint:Line(nLinPcI, 030, nLinPcI, 575)	//Linha horizontal superior
		oPrint:Line(nLinPcI, 030, nLin, 030)	//Linha vertical direita
		oPrint:Line(nLinPcI, 575, nLin, 575)	//Linha vertical esquerda
		oPrint:Line(nLin,    030, nLin, 575)	//Linha horizontal inferior
	
	EndIf	

	oPrint:EndPage()	
	cArqLocal		:= cLocal+cFileName+".PDF"		
	oPrint:cPathPDF := cLocal 
	oPrint:lViewPDF := .F.
	oPrint:Print()

EndIf

Return()
