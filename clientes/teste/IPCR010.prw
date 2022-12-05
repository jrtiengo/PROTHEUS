#INCLUDE "FIVEWIN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWIZARD.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "RPTDEF.CH"                                      
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "TOTVS.CH"
#INCLUDE "PARMTYPE.CH"
#include 'parmtype.ch'
#Include 'TopConn.ch'
#Include 'Rwmake.ch'
#include "ap5mail.ch"

#DEFINE IMP_SPOOL 2
#DEFINE IMP_PDF 6
#DEFINE ALIGN_H_LEFT   	0
#DEFINE ALIGN_H_RIGHT  	1
#DEFINE ALIGN_H_CENTER 	2
#DEFINE MAXMENLIN  150

/*/{Protheus.doc} IPCR010
Impress„o de pedido de venda.
@author Mauro - Solutio
@since 22/04/2021
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function IPCR010()


	Local aArq_				:= {}
	Local nCont				:= 0
	Local _cMen				:= ""
	Local nRet_				:= 0
	
	Private cPergP			:= Padr("IPCR010A",10)
	Private cPergO			:= Padr("IPCR010B",10)
	Private aItens_			:= {}
	Private oFont12,oFont14,oFont10n,oFont12n,oCour10n
	Private oPrinter  		:= Nil
	Private nTotalNF_		:= 0
	Private nTotIpi_		:= 0 
	Private nTotFre_		:= 0
	Private nValPrd_		:= 0
	Private nValTST_		:= 0
	Private nPesol_			:= 0
	Private _oDlg
	Private lPrp_			:= .F.
	Private lPed_			:= .F.
	Private cPathSrv_		:= "\IPCARQ\"
	Private cPathLoc_		:= Space(50)

	oFont12		:= TFont():New("Courier"	, 9, 09, .T., .F., 5, .T., 2, .T., .F.)
	oCour10n	:= TFont():New("Courier"	, 9, 10, .T., .T., 5, .T., 2, .T., .F.)
	oFont14		:= TFont():New("Arial"		, 9, 14, .T., .F., 5, .T., 2, .T., .F.)
	oFont10n	:= TFont():New("Arial"		, 9, 10, .T., .T., 5, .T., 2, .T., .F.)
	oFont12n	:= TFont():New("Arial"		, 9, 11, .T., .T., 5, .T., 2, .T., .F.)

	If !ExistDir(cPathSrv_)
		nRet_ := MakeDir(cPathSrv_)
		If nRet_ != 0
			MsgAlert( "N„o foi possÌvel criar o diretÛrio '"+_cNome+"'. Erro: " + cValToChar( FError() ) )
			Return()
		EndIf
	EndIf
	
	If !ExistDir(cPathSrv_+"\Enviados\")
		nRet_ := MakeDir(cPathSrv_+"\Enviados\")
		If nRet_ != 0
			MsgAlert( "N„o foi possÌvel criar o diretÛrio '"+_cNome+"\Enviados\'. Erro: " + cValToChar( FError() ) )
			Return()
		EndIf
	EndIf
	
	
	DEFINE MSDIALOG _oDlg TITLE "GeraÁ„o de RelatÛrios" FROM C(307),C(460) TO C(474),C(896) PIXEL

	// Cria Componentes Padroes do Sistema
	@ C(025),C(032) Button "Pedido" 	Size C(050),C(025)  ACTION( lPed_ := .T., _oDlg:End() ) PIXEL OF _oDlg
	@ C(025),C(130) Button "Orcamento" 	Size C(050),C(025)  ACTION( lPrp_ := .T., _oDlg:End() ) PIXEL OF _oDlg

	ACTIVATE MSDIALOG _oDlg CENTERED

	If lPed_
		If !Pergunte(cPergP)
			Return()
		EndIf
	EndIf

	If lPrp_
		If !Pergunte(cPergO)
			Return()
		EndIf
	EndIf

	// Valida o diretÛrio informado.
	If !ExistDir(Alltrim(MV_PAR05))
		Alert("Caminho informado, n„o existe. Verifique!")
		Return()
	EndIf

	// Ajusta o caminho.
	cPathLoc_ := Alltrim(MV_PAR05) + IIf(Right(Alltrim(MV_PAR05),1) <> "\","\","")

	If lPed_
		cQuery := " SELECT C5_FILIAL AS FILIAL, C5_NUM AS NUM, "
		//cQuery += " ISNULL(CAST(CAST(C5_OBS1 AS VARBINARY(8000)) AS VARCHAR(8000)),'') AS OBS "
		cQuery += " C5_OBSINT AS OBS, C5_MENNOTA AS MEN "
		cQuery += " FROM "+RETSQLNAME("SC5")+" SC5 "
		cQuery += " WHERE C5_FILIAL = '"+ xFilial("SC5") +"' "
		cQuery += " AND C5_NUM BETWEEN '"+ MV_PAR01 +"' AND '"+ MV_PAR02 +"' "
		cQuery += " AND SC5.D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY SC5.C5_NUM "
	ElseIf lPrp_
		cQuery := " SELECT CJ_FILIAL AS FILIAL, CJ_NUM AS NUM, "
		cQuery += " CJ_OBS AS OBS "
		cQuery += " FROM "+RETSQLNAME("SCJ")+" SCJ "
		cQuery += " WHERE CJ_FILIAL = '"+ xFilial("SCJ") +"' "
		cQuery += " AND CJ_NUM BETWEEN '"+ MV_PAR01 +"' AND '"+ MV_PAR02 +"' "
		cQuery += " AND SCJ.D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY SCJ.CJ_NUM "
	EndIf

	If Select("TMP") <>  0
		TMP->(DbCloseArea())
	EndIf
						
	TcQuery cQuery New Alias "TMP"

	DbSelectArea("TMP")
	DbGoTop()
	Do While !EOF()

		If lPrp_
			_cMen := Alltrim(TMP->OBS)
		Else
			_cMen := Alltrim(TMP->OBS) + " " + Alltrim(TMP->MEN)
		EndIf
		aadd(aArq_,{TMP->FILIAL,TMP->NUM,_cMen})

		TMP->(DbSkip())
	EndDo
	TMP->(DbCloseArea())

	For nCont := 1 To Len(aArq_)
		Processa( {|| IPCR010A(aArq_[nCont][1],aArq_[nCont][2],aArq_[nCont][3]) }," Processando arquivos..","Aguarde....." )
	Next nCont


Return()


/*/{Protheus.doc} IPCR010A
Pega os dados dos itens e monta corpo do arquivo.
@type function
@author Mauro - Solutio.
@since 
@versio1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Static Function IPCR010A(_cFil, _cNum,_cMens)
	
	Local _cArq		:= ""
	Local nCont_	:= 0
	Local cText		:= ""
	Local nAliqIcm_	:= 0
	Local nValST_	:= 0
	Local aVIPI_	:= {}
	Local aTransp_	:= {"",""}

	If lPrp_
		cQuery := " SELECT CJ_NUM AS NUM, CJ_EMISSAO AS EMISSAO, CJ_CLIENTE AS CLIENTE, CJ_LOJA AS LOJACLI, CJ_TRANSP AS TRANSP, "
		cQuery += " CJ_CONDPAG AS CONDPAG, CJ_VEND1 AS VEND1, 0 AS PESOL, CJ_TIPO AS TIPO, CJ_TIPOCLI AS TIPOCLI, "
		cQuery += " CJ_FRETE AS FRETE, CJ_TPFRETE AS TPFRETE, '         ' AS NFORI, '   ' AS SERIORI,"
		cQuery += " CJ_OBS AS OBS, "
		cQuery += " CK_PRODUTO AS PRODUTO, CK_ITEM AS ITEM, CK_QTDVEN AS QTDVEN, CK_PRCVEN AS PRCVEN, CK_VALOR AS VALOR , "
		cQuery += " CK_ENTREG AS ENTREG, CK_VALDESC AS VALDESC, CK_TES AS TES, "
		cQuery += " B1_DESC AS DESC_, B1_POSIPI AS POSIPI, B1_PESO AS PESO, A1_NOME AS NOME, A1_EMAIL AS EMAIL, A1_TEL AS TEL, A1_DDD AS DDD, "
		cQuery += " A1_CONTATO AS CONTATO, A1_CGC AS CGC, A1_END AS END_, A1_BAIRRO AS BAIRRO, A1_MUN AS MUN, A1_CEP AS CEP, A1_EST AS EST, "
		cQuery += " A1_ENDCOB AS ENDCOB, A1_BAIRROC AS BAIRROC, A1_MUNC AS MUNC, A1_CEPC AS CEPC, A1_ESTC AS ESTC, "
		cQuery += " A1_ENDENT AS ENDENT, A1_BAIRROE AS BAIRROE, A1_MUNE AS MUNE, A1_CEPE AS CEPE, A1_ESTE AS ESTE "
		cQuery += " FROM "+ RETSQLNAME("SCJ") +" SCJ, "+ RETSQLNAME("SCK") +" SCK , "+ RETSQLNAME("SB1") +" SB1, "+ RETSQLNAME("SA1") +" SA1 "
		cQuery += " WHERE SCJ.CJ_FILIAL = '"+ _cFil +"'  "
		cQuery += " AND SCJ.CJ_NUM = '"+ _cNum +"'  "
		cQuery += " AND SA1.A1_COD = SCJ.CJ_CLIENTE "
		cQuery += " AND SA1.A1_LOJA = SCJ.CJ_LOJA "
		cQuery += " AND SCK.CK_FILIAL = SCJ.CJ_FILIAL "
		cQuery += " AND SCK.CK_NUM = SCJ.CJ_NUM "
		cQuery += " AND SB1.B1_COD = SCK.CK_PRODUTO "
		cQuery += " AND SCJ.D_E_L_E_T_ <> '*' "
		cQuery += " AND SCK.D_E_L_E_T_ <> '*' "
		cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
		cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY SCK.CK_ITEM "
	ElseIf lPed_
		cQuery := " SELECT C5_NUM AS NUM, C5_EMISSAO AS EMISSAO, C5_CLIENTE AS CLIENTE, C5_LOJACLI AS LOJACLI, C5_TRANSP AS TRANSP, "
		cQuery += " C5_CONDPAG AS CONDPAG, C5_VEND1 AS VEND1, C5_PESOL AS PESOL, C5_TIPO AS TIPO, C5_TIPOCLI AS TIPOCLI, "
		cQuery += " C5_FRETE AS FRETE, C5_TPFRETE AS TPFRETE, C6_NFORI AS NFORI, C6_SERIORI AS SERIORI,"
		cQuery += " C6_PRODUTO AS PRODUTO, C6_ITEM AS ITEM, C6_QTDVEN AS QTDVEN, C6_PRCVEN AS PRCVEN, C6_VALOR AS VALOR , "
		cQuery += " C6_ENTREG AS ENTREG, C6_VALDESC AS VALDESC, C6_TES AS TES, "
		cQuery += " B1_DESC AS DESC_, B1_POSIPI AS POSIPI, B1_PESO AS PESO, A1_NOME AS NOME, A1_EMAIL AS EMAIL, A1_TEL AS TEL, A1_DDD AS DDD, "
		cQuery += " A1_CONTATO AS CONTATO, A1_CGC AS CGC, A1_END AS END_, A1_BAIRRO AS BAIRRO, A1_MUN AS MUN, A1_CEP AS CEP, A1_EST AS EST, "
		cQuery += " A1_ENDCOB AS ENDCOB, A1_BAIRROC AS BAIRROC, A1_MUNC AS MUNC, A1_CEPC AS CEPC, A1_ESTC AS ESTC, "
		cQuery += " A1_ENDENT AS ENDENT, A1_BAIRROE AS BAIRROE, A1_MUNE AS MUNE, A1_CEPE AS CEPE, A1_ESTE AS ESTE "
		cQuery += " FROM "+ RETSQLNAME("SC5") +" SC5, "+ RETSQLNAME("SC6") +" SC6 , "+ RETSQLNAME("SB1") +" SB1, "+ RETSQLNAME("SA1") +" SA1 "
		cQuery += " WHERE SC5.C5_FILIAL = '"+ _cFil +"'  "
		cQuery += " AND SC5.C5_NUM = '"+ _cNum +"'  "
		cQuery += " AND SA1.A1_COD = SC5.C5_CLIENTE "
		cQuery += " AND SA1.A1_LOJA = SC5.C5_LOJACLI "
		cQuery += " AND SC6.C6_FILIAL = SC5.C5_FILIAL "
		cQuery += " AND SC6.C6_NUM = SC5.C5_NUM "
		cQuery += " AND SB1.B1_COD = SC6.C6_PRODUTO "
		cQuery += " AND SC5.D_E_L_E_T_ <> '*' "
		cQuery += " AND SC6.D_E_L_E_T_ <> '*' "
		cQuery += " AND SB1.D_E_L_E_T_ <> '*' "
		cQuery += " AND SA1.D_E_L_E_T_ <> '*' "
		cQuery += " ORDER BY SC6.C6_ITEM "
	EndIf


	If Select("TMP1") <>  0
		TMP1->(DbCloseArea())
	EndIf
						
	TcQuery cQuery New Alias "TMP1"

	DbSelectArea("TMP1")

	SA4->(dbSetOrder(1))
	If SA4->(dbSeek(xFilial("SA4")+TMP1->TRANSP))
		aTransp_[01] := SA4->A4_EST
		aTransp_[02] := Iif(SA4->(FieldPos("A4_TPTRANS")) > 0,SA4->A4_TPTRANS,"")
	Endif

	MaFisEnd()
	MaFisIni(TMP1->CLIENTE,;               // 01 - Codigo Cliente/Fornecedor
    TMP1->LOJACLI,;                        // 02 - Loja do Cliente/Fornecedor
    Iif(TMP1->TIPO $ "D;B", "F", "C"),;    // 03 - C:Cliente , F:Fornecedor
    TMP1->TIPO,;                           // 04 - Tipo da NF
    TMP1->TIPOCLI,;                        // 05 - Tipo do Cliente/Fornecedor
    MaFisRelImp("MT100", {"SF2", "SD2"}),;    // 06 - Relacao de Impostos que suportados no arquivo
    ,;                                        // 07 - Tipo de complemento
    ,;                                        // 08 - Permite Incluir Impostos no Rodape .T./.F.
    "SB1",;                                   // 09 - Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
    "MATA461") 
	
	Do While !EOF()
				
		SB1->(DbSeek(FWxFilial("SB1")+TMP1->PRODUTO))
    	MaFisAdd(TMP1->PRODUTO,;    // 01 - Codigo do Produto                    ( Obrigatorio )
			TMP1->TES,;             // 02 - Codigo do TES                        ( Opcional )
			TMP1->QTDVEN,;          // 03 - Quantidade                           ( Obrigatorio )
			TMP1->PRCVEN,;          // 04 - Preco Unitario                       ( Obrigatorio )
			TMP1->VALDESC,;         // 05 - Desconto
			TMP1->NFORI,;           // 06 - Numero da NF Original                ( Devolucao/Benef )
			TMP1->SERIORI,;         // 07 - Serie da NF Original                 ( Devolucao/Benef )
			0,;                     // 08 - RecNo da NF Original no arq SD1/SD2
			0,;                     // 09 - Valor do Frete do Item               ( Opcional )
			0,;                     // 10 - Valor da Despesa do item             ( Opcional )
			0,;                     // 11 - Valor do Seguro do item              ( Opcional )
			0,;                     // 12 - Valor do Frete Autonomo              ( Opcional )
			TMP1->VALOR,;           // 13 - Valor da Mercadoria                  ( Obrigatorio )
			0,;                     // 14 - Valor da Embalagem                   ( Opcional )
			SB1->(RecNo()),;        // 15 - RecNo do SB1
			0)                      // 16 - RecNo do SF4


		TMP1->(DbSKIP())

	EndDo

	DbSelectArea("TMP1")
	DbGoTop()
	nN_ := 1

	Do While !EOF()
		
		nValPrd_	:= nValPrd_ + TMP1->VALOR
		nAliqIcm_	:= MaFisRet(nN_,"IT_ALIQICM")
		aVIPI_		:= MaFisRet(nN_,'IT_IPI')
		nTotIpi_	:= nTotIpi_ + aVIPI_[2]
		// nTotIcms_	:= nTotIcms_+ MaFisRet(nN_,'NF_VALICM')
		nPesol_		:= nPesol_ + (TMP1->PESO * TMP1->QTDVEN)
		nValST_		:= MaFisRet(nN_,"IT_VALSOL")
		
		aadd(aItens_,{TMP1->ITEM,TMP1->PRODUTO,TMP1->DESC_,TMP1->POSIPI,TMP1->QTDVEN,;
		TMP1->PRCVEN,MaFisRet(nN_,"IT_ALIQICM"),aVIPI_[2],nValST_,(TMP1->VALOR+aVIPI_[2]+nValST_),STOD(TMP1->ENTREG)})

		nN_++
		TMP1->(DbSKIP())

	EndDo
	
	nTotalNF_	:= MaFisRet(1,'NF_TOTAL')
	nValTST_	:= MaFisRet(1,'NF_VALSOL')


	DbSelectArea("TMP1")
	DbGoTop()

	nTotFre_	:= TMP1->FRETE

	If lPed_
		_cArq := "Pedido de Venda - "+ TMP1->NUM
	EndIf
		
	If lPrp_
		_cArq := "Proposta Comercial - "+ TMP1->NUM
	EndIf

	oPrinter:= FWMSPrinter():New(_cArq,6,.T.,      ,.T.,,,,.F.,.F.,,.F.,)
	oPrinter:SetResolution(78)
	oPrinter:SetPortrait()
	oPrinter:SetPaperSize(DMPAPER_A4)
	oPrinter:SetMargin(50,50,50,50)
	oPrinter:cPathPDF := cPathLoc_ // caminho onde ser· salvo o pdf.

	DbSelectArea("TMP1")
	DbGoTop()
	CAB010()

	nLItem := 580

	For nCont_ := 1 To Len(aItens_)
		
		// ITEM
		oPrinter:Say  (nLItem, 0060, aItens_[nCont_][01]	, oFont12)

		// ARTIGO
		oPrinter:Say  (nLItem, 0120, aItens_[nCont_][02]	, oFont12)

		// DESCRI«√O
		oPrinter:Say  (nLItem, 0370, aItens_[nCont_][03]	, oFont12)

		// NCM
		oPrinter:Say  (nLItem, 0810, aItens_[nCont_][04]	, oFont12)

		// QTD
		cText	:= TRANSFORM(aItens_[nCont_][05],"@E 999,999,999.99")
		oPrinter:Say  (nLItem, 1000, PADL(cText,14,Space(1))	, oFont12)

		// UNITARIO
		cText	:= TRANSFORM(aItens_[nCont_][06]	,"@E 99,999,999.9999")
		oPrinter:Say  (nLItem, 1185, PADL(cText,15,Space(1))	, oFont12)

		//ICMS %
		cText	:= TRANSFORM(aItens_[nCont_][07]	,"@E 99.99")
		oPrinter:Say  (nLItem, 1450, PADL(cText,05,Space(1))	, oFont12)

		//IPI R$
		cText	:= TRANSFORM(aItens_[nCont_][08]	,"@E 99,999,999,999.99")
		oPrinter:Say  (nLItem, 1550, PADL(cText,17,Space(1))	, oFont12)

		//ICMS ST
		cText	:= TRANSFORM(aItens_[nCont_][09]	,"@E 99,999,999,999.99")
		oPrinter:Say  (nLItem, 1810, PADL(cText,17,Space(1))	, oFont12)

		//Total
		cText	:= TRANSFORM(aItens_[nCont_][10]	,"@E 999,999,999.99")
		oPrinter:Say  (nLItem, 2030, PADL(cText,17,Space(1))	, oFont12)

		//Entrega
		oPrinter:Say  (nLItem, 2310, DTOC(aItens_[nCont_][11])	, oFont12)

		// Jorge Alberto - Solutio - 20/05/2021 - Ajuste na impress„o dos totais somente ma ultima pagina.
		If nLItem >= 2140

			nLItem := nLItem + 40
			oPrinter:Say  (nLItem, 0070,"CONTINUA...", oFont12n)
			CAB010()
			nLItem := 580
		EndIf

		nLItem := nLItem + 40

	Next nCont_

	ROD010(_cMens)

	oPrinter:Print()

	DbSelectArea("TMP1")
	DbGoTop()
	If MV_Par06 == 1
		EnviaMail(Alltrim(TMP1->EMAIL),_cArq)
	EndIf

	FreeObj(oPrinter)
	oPrinter := Nil
	
	TMP1->(DbCloseArea())

Return()


/*/{Protheus.doc} CAB010
Gera o cabeÁalho do arquivo.
@type function
@author Mauro - Solutio.
@since 
@versio1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Static Function CAB010()

	oPrinter:startpage()

	// Linhas verticais
	oPrinter:Line( 0545, 0110, 540+(40*40)+15, 0110 )
	oPrinter:Line( 0545, 0350, 540+(40*40)+15, 0350 )
	oPrinter:Line( 0545, 0800, 540+(40*40)+15, 0800 )
	oPrinter:Line( 0545, 0990, 540+(40*40)+15, 0990 )
	oPrinter:Line( 0545, 1210, 540+(40*40)+15, 1210 )
	oPrinter:Line( 0545, 1410, 540+(40*40)+15, 1410 )
	oPrinter:Line( 0545, 1540, 540+(40*40)+15, 1540 )
	oPrinter:Line( 0545, 1800, 540+(40*40)+15, 1800 )
	oPrinter:Line( 0545, 2060, 540+(40*40)+15, 2060 )
	oPrinter:Line( 0545, 2300, 540+(40*40)+15, 2300 )

	_nLin := 0 //50
	
	// oPrinter:Box  (_nLin, 0100, 3000, 2330)
	
	_nLin := _nLin + 30
	//oPrinter:SayBitmap ( _nLin + 0000, 0050, "logipc.png", 0276, 0150)
	oPrinter:SayBitmap ( _nLin + 0000, 0050, "logipc.png", 0394, 0225)
	//oPrinter:SayBitmap ( _nLin + 0020, 0350, "gipp.png", 0253, 0087)
	//oPrinter:SayBitmap ( _nLin + 0040, 0650, "tecnoink.png", 0220, 0061)
	
	oPrinter:Say  (_nLin + 0040, 0850, Alltrim(SM0->M0_NOMECOM), oFont10n)
	//oPrinter:Say  (_nLin + 0040, 0850, Alltrim("IPC BRASIL IMPORTADORA DE PRODUTOS CERTIFICADOS LTDA"), oFont10n)
	oPrinter:Say  (_nLin + 0080, 0850, "CNPJ:" + Alltrim(SM0->M0_CGC) + " - " + "INSC.ESTADUAL:" + Alltrim(SM0->M0_INSC), oFont10n)
	//oPrinter:Say  (_nLin + 0080, 0850, "CNPJ:"+"09520471000103" + " - " + "INSC.ESTADUAL:" + "255665300", oFont10n)
	oPrinter:Say  (_nLin + 0120, 0850, Alltrim(SM0->M0_ENDCOB) , oFont10n)
	//oPrinter:Say  (_nLin + 0120, 0850, Alltrim("RUA JOS… PEREIRA LIBERATO, 377")   , oFont10n)
	oPrinter:Say  (_nLin + 0160, 0850, "CEP: " + Alltrim(SM0->M0_CEPCOB) + " - " + Alltrim(SM0->M0_CIDCOB )+ " - " + Alltrim(SM0->M0_ESTCOB) + " - " +"FONE: " + Alltrim(SM0->M0_TEL)  , oFont10n)
	//oPrinter:Say  (_nLin + 0160, 0850, "CEP:" + "88305390" + "-" + "ITAJAÕ" + "-" + "SC" + "-" +"FONE:" + "51-30864040"  , oFont10n)
	
	// Box do pedido/proposta.
	oPrinter:Box  (_nLin, 1900, 0230, 2450)
	
	_nLin := _nLin + 40

	If lPrp_
		oPrinter:Say  (_nLin + 0000, 1970, "PROPOSTA COMERCIAL", oFont14)
	Else
		oPrinter:Say  (_nLin + 0000, 1970, "PEDIDO DE VENDA", oFont14)
	EndIf
	oPrinter:Say  (_nLin + 0050, 2030, "N∫: "+TMP1->NUM, oFont14)
	oPrinter:Say  (_nLin + 0100, 1970, "Emiss„o: "+DTOC(STOD(TMP1->EMISSAO)), oFont14)
	
	_nLin := _nLin + 200
	
	oPrinter:Say  (_nLin + 0000, 0050, "Cliente:", oFont10n)
	oPrinter:Say  (_nLin + 0000, 0390, Alltrim(TMP1->NOME), oFont10n)

	oPrinter:Say  (_nLin + 0000, 1400, "Contato Cliente:", oFont10n)
	oPrinter:Say  (_nLin + 0000, 1700, Alltrim(TMP1->CONTATO), oFont10n)
	
	oPrinter:Say  (_nLin + 0040, 0050, "CNPJ/CPF:", oFont10n)
	oPrinter:Say  (_nLin + 0040, 0390, Alltrim(TMP1->CGC), oFont10n)
	
	// Adicionado o DDD. Mauro - Solutio. 23/09/2021.
	oPrinter:Say  (_nLin + 0040, 1400, "Telefone:", oFont10n)
	oPrinter:Say  (_nLin + 0040, 1700, IIf(!Empty(Alltrim(TMP1->DDD)),"("+TMP1->DDD+")","") + TMP1->TEL, oFont10n)
	
	oPrinter:Say  (_nLin + 0080, 0050, "EndereÁo:", oFont10n)
	oPrinter:Say  (_nLin + 0080, 0390, Alltrim(TMP1->END_)+" - "+Alltrim(TMP1->BAIRRO), oFont10n)
	oPrinter:Say  (_nLin + 0120, 0390, "CEP: "+Alltrim(TMP1->CEP)+" - "+Alltrim(TMP1->MUN)+" - "+Alltrim(TMP1->EST), oFont10n)

	oPrinter:Say  (_nLin + 0080, 1400, "E-mail:", oFont10n)
	oPrinter:Say  (_nLin + 0080, 1700, TMP1->EMAIL, oFont10n)
	
	oPrinter:Line( _nLin + 0150, 0050, _nLin + 0150, 2450)
	If lPed_
		oPrinter:Say  (_nLin + 0190, 0070, "Itens do Pedido", oFont12n)
	EndIf
	If lPrp_
		oPrinter:Say  (_nLin + 0190, 0070, "Itens da Proposta", oFont12n)
	EndIf
	oPrinter:Line( _nLin + 0210, 0050, _nLin + 0210, 2450)

	// Colunas
	oPrinter:Say  (_nLin + 0260, 0050, "Item"		, oFont12n)
	oPrinter:Say  (_nLin + 0260, 0190, "Artigo"		, oFont12n)
	oPrinter:Say  (_nLin + 0260, 0500, "DescriÁ„o"	, oFont12n)
	oPrinter:Say  (_nLin + 0260, 0860, "NCM"		, oFont12n)
	oPrinter:Say  (_nLin + 0260, 1070, "Qtd"		, oFont12n)
	oPrinter:Say  (_nLin + 0260, 1250, "Unit·rio"	, oFont12n)
	oPrinter:Say  (_nLin + 0260, 1420, "ICMS %"		, oFont12n)
	oPrinter:Say  (_nLin + 0260, 1620, "IPI R$"		, oFont12n)
	oPrinter:Say  (_nLin + 0260, 1840, "ICMS ST R$"	, oFont12n)
	oPrinter:Say  (_nLin + 0260, 2130, "Total $"	, oFont12n)
	oPrinter:Say  (_nLin + 0260, 2310, "DisponÌvel"	, oFont12n)


Return()


/*/{Protheus.doc} ROD010
Gera o rodapÈ do arquivo.
@type function
@author Mauro - Solutio.
@since 
@versio1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Static Function ROD010(cAux_)


	Local aMens_	:= {}
	Local nContM	:= 0
	Local nLinM		:= 0
	Local nLenM		:= 0

	oPrinter:Line( 2200, 0050, 2200, 2450)

	oPrinter:Say  (2240, 0070,"EndereÁo de Entrega:", oFont10n)
	If !Empty(Alltrim(TMP1->ENDENT))
		cEEnt := Alltrim(TMP1->ENDENT) + " - " + Alltrim(TMP1->MUNE) + " - " + Alltrim(TMP1->ESTE) + " - " + Alltrim(TMP1->CEPE)
	Else
		cEEnt := Alltrim(TMP1->END_) + " - " + Alltrim(TMP1->MUN) + " - " + Alltrim(TMP1->EST) + " - " + Alltrim(TMP1->CEP)
	EndIf
	oPrinter:Say  (2240, 0390,cEEnt, oFont10n)
	
	oPrinter:Say  (2280, 0070,"EndereÁo de CobranÁa:", oFont10n)
	If !Empty(Alltrim(TMP1->ENDCOB))
		cECob := Alltrim(TMP1->ENDCOB) + " - " + Alltrim(TMP1->MUNC) + " - " + Alltrim(TMP1->ESTC) + " - " + Alltrim(TMP1->CEPC)
	Else
		cECob := Alltrim(TMP1->END_) + " - " + Alltrim(TMP1->MUN) + " - " + Alltrim(TMP1->EST) + " - " + Alltrim(TMP1->CEP)
	EndIf
	oPrinter:Say  (2280, 0390,cECob, oFont10n)

	oPrinter:Say  (2320, 0070,"Redespacho:", oFont10n)

	oPrinter:Box  (2350, 0050, 2610, 2450)
	oPrinter:Line( 2350, 1200, 2610, 1200 )

	// Inicio Box.
	// Esquerda Box.
	oPrinter:Say  (2390, 0070,"Cond. Pagamento:", oFont10n)
	cCond_ := Posicione('SE4',1,xFilial('SE4')+TMP1->CONDPAG,'E4_DESCRI')
	oPrinter:Say  (2390, 0390,Alltrim(cCond_), oFont10n)

	oPrinter:Say  (2430, 0070,"Frete:", oFont10n)
	If TMP1->TPFRETE == "C"
		cTFrete_ := "CIF"
	ElseIf TMP1->TPFRETE == "F"
		cTFrete_ := "FOB"
	ElseIf TMP1->TPFRETE == "T"
		cTFrete_ := "Por Conta de Terceiros"
	Else
		cTFrete_ := "Sem Frete"
	EndIf
	oPrinter:Say  (2430, 0390,cTFrete_, oFont10n)
		
	oPrinter:Say  (2470, 0070,"Transportadora:", oFont10n)
	cTransp_ := IF(!EMPTY(TMP1->TRANSP),Posicione('SA4',1,xFilial('SA4')+TMP1->TRANSP,'A4_NOME'),'')
	oPrinter:Say  (2470, 0390,Alltrim(cTransp_), oFont10n)

	oPrinter:Say  (2510, 0070,"Prazo Faturamento:", oFont10n)
	oPrinter:Say  (2510, 0390," 3 dias uteis", oFont10n)
	
	oPrinter:Say  (2550, 0070,"Vendedor:", oFont10n)
	cVend_ := Posicione('SA3',1,xFilial('SA3')+TMP1->VEND1,'A3_NOME')
	oPrinter:Say  (2550, 0390,Alltrim(cVend_), oFont10n)

	oPrinter:Say  (2590, 0070,"Contato:", oFont10n)
	cCont_ := Alltrim(Posicione('SA3',1,xFilial('SA3')+TMP1->VEND1,'A3_EMAIL'))+" - "+"("+Alltrim(Posicione('SA3',1,xFilial('SA3')+TMP1->VEND1,'A3_DDDTEL'))+")"+Space(1)+Alltrim(Posicione('SA3',1,xFilial('SA3')+TMP1->VEND1,'A3_TEL'))
	oPrinter:Say  (2590, 0390,cCont_, oFont10n)
	
	// Direta Box.
	oPrinter:Say  (2390, 1220,"Valor Produto:", oFont10n)
	cText	:= TRANSFORM(nValPrd_	,"@E 99,999,999,999.99")
	oPrinter:Say  (2390, 1540, PADL(cText,17,Space(1))	, oCour10n)

	oPrinter:Say  (2430, 1220,"Valor IPI:", oFont10n)
	cText	:= TRANSFORM(nTotIpi_	,"@E 99,999,999,999.99")
	oPrinter:Say  (2430, 1540, PADL(cText,17,Space(1))	, oCour10n)

	oPrinter:Say  (2470, 1220,"Valor ICMS ST:", oFont10n)
	cText	:= TRANSFORM(nValTST_	,"@E 99,999,999,999.99")
	oPrinter:Say  (2470, 1540, PADL(cText,17,Space(1))	, oCour10n)
	
	oPrinter:Say  (2510, 1220,"Valor do Frete:", oFont10n)
	cText	:= TRANSFORM(nTotFre_	,"@E 99,999,999,999.99")
	oPrinter:Say  (2510, 1540, PADL(cText,17,Space(1))	, oCour10n)
	
	// Adicionado o valor do frete ao total. Mauro - Solutio. 23/09/2021.
	oPrinter:Say  (2550, 1220,"Valor Total R$:", oFont10n)
	cText	:= TRANSFORM((nTotalNF_ + nTotFre_)	,"@E 99,999,999,999.99")
	oPrinter:Say  (2550, 1540, PADL(cText,17,Space(1))	, oCour10n)

	oPrinter:Say  (2590, 1220,"Peso LÌquido:", oFont10n)
	cText	:= TRANSFORM(nPesol_	,"@E 99,999,999,999.99")
	oPrinter:Say  (2590, 1540, PADL(cText,17,Space(1))	, oCour10n)
	// Fim Box.


	// Monta a mensagem.
	cAux_ := replace(cAux_,CHAR(10),', ')
	cAux_ := replace(cAux_,CHAR(13),'')
	Do While !Empty(cAux_)
		aadd(aMens_,SubStr(cAux_,1,IIf(EspacoAt(cAux_, MAXMENLIN) > 1, EspacoAt(cAux_, MAXMENLIN) - 1, MAXMENLIN)))
		cAux_ := SubStr(cAux_,IIf(EspacoAt(cAux_, MAXMENLIN) > 1, EspacoAt(cAux_, MAXMENLIN), MAXMENLIN) + 1)
	EndDo

	oPrinter:Say  (2640, 0070,"ObservaÁıes:", oFont10n)
	nLenM := Len(aMens_)
	nLinM := 2680
	For nContM := 1 To nLenM

		oPrinter:Say  (nLinM, 0070, aMens_[nContM], oFont10n)

		nLinM := nLinM + 40

		If nContM == 3
			nContM := nLenM
		EndIf

	Next nContM

	oPrinter:Line( 2790, 0050, 2790, 2450)

	If lPrp_
		oPrinter:Say  (2830, 0070, "Proposta v·lida por 5 dias ˙teis.", oFont10n)
	EndIf
	oPrinter:Say  (2870, 0070, "CrÈdito sujeito a aprovaÁ„o.", oFont10n)
	oPrinter:Say  (2910, 0070, "Valores e disponibilidade sujeitos a alteraÁ„o sem aviso prÈvio.", oFont10n)

	oPrinter:Say  (2920, 2000, "Marcas PrÛprias:", oFont10n)
	oPrinter:SayBitmap ( 2970, 1900, "gipp.png", 0253, 0087)
	oPrinter:SayBitmap ( 2970, 2200, "tecnoink.png", 0220, 0061)

Return()


/*/{Protheus.doc} IPCR010C
Gera uma vari·vel p˙blica, com o caminho do diretÛrio selecionado.
@type function
@author Mauro - Solutio.
@since 
@versio1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

User Function IPCR010C()

	Public _cRetIPC := cGetFile( "", "Selecione o DiretÛrio",,, .F., GETF_NETWORKDRIVE + GETF_LOCALFLOPPY + GETF_LOCALHARD + GETF_RETDIRECTORY,.F. )

Return(.T.)


/*/{Protheus.doc} EnviaMail
Dispara email com o arquivo para o cliente.
@type function
@author Mauro - Solutio.
@since 
@versio1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Static Function EnviaMail(_cMail,_cArq)

	Local _cHtm		:= ""
	Local _cAssun	:= _cArq
	Local _cConta	:= GetMv("MV_RELACNT")
	Local _cDe		:= GetMv("MV_RELFROM")
	Local _cServer	:= GetMv("MV_RELSERV")
	Local _cSenha	:= GetMv("MV_RELPSW ")
	
	Local cMsg := ""
	Local xRet
	Local oServer, oMessage
	Local lMailAuth	:= SuperGetMv("MV_RELAUTH",,.F.)
	Local nPorta	:= 587
	Local nStatus	:= 0

	_cHtm := "<html></html>"


							  
	  
 
	oMessage:= TMailMessage():New()
	oMessage:Clear() 
   
	oMessage:cDate	 := strzero(month(date()),2)+"/"+strzero(day(date()),2)+"/"+strzero(year(date()),4)
	oMessage:cFrom 	 := _cDe
	oMessage:cTo 	 := _cMail
	oMessage:cSubject:= _cAssun
	oMessage:cBody 	 := _cHtm
	
	// Move arquivo para o servidor, para poder enviar por email.
	CpyT2S(cPathLoc_+_cArq+".pdf", cPathSrv_)
	_cAnexo := cPathSrv_+_cArq+".pdf"

	xRet := oMessage:AttachFile( _cAnexo )
	If xRet < 0
		cMsg := "O arquivo " + _cArq + ", n„o foi anexado!"
		Alert( cMsg )
		Return()
	EndIf
	

	oServer := tMailManager():New()
	oServer:SetUseTLS( .F. ) //Indica se ser· utilizar· a comunicaÁ„o segura atravÈs de SSL/TLS (.T.) ou n„o (.F.)
   
	xRet := oServer:Init( "", _cServer, _cConta, _cSenha, 0, nPorta ) //inicilizar o servidor
	If xRet != 0
		Alert("O servidor SMTP n„o foi inicializado: " + oServer:GetErrorString( xRet ) )
		Return()
	EndIf
   
	xRet := oServer:SetSMTPTimeout( 60 ) //Indica o tempo de espera em segundos.
	If xRet != 0
		Alert("N„o foi possÌvel definir " + cProtocol + " tempo limite para " + cValToChar( nTimeout ))
	EndIf
   
	xRet := oServer:SMTPConnect()
	If xRet <> 0
		Alert("N„o foi possÌvel conectar ao servidor SMTP: " + oServer:GetErrorString( xRet ))
		Return()
	EndIf
   
	If lMailAuth
		//O mÈtodo SMTPAuth ao tentar realizar a autenticaÁ„o do 
		//usu·rio no servidor de e-mail, verifica a configuraÁ„o 
		//da chave AuthSmtp, na seÁ„o [Mail], no arquivo de 
		//configuraÁ„o (INI) do TOTVS Application Server, para determinar o valor.
		xRet := oServer:SmtpAuth( _cConta, _cSenha )
		If xRet <> 0
			cMsg := "Could not authenticate on SMTP server: " + oServer:GetErrorString( xRet )
			Alert( cMsg )
			oServer:SMTPDisconnect()
			return
		EndIf
	Endif
	xRet := oMessage:Send( oServer )
	If xRet <> 0
		Alert("N„o foi possÌvel enviar mensagem: " + oServer:GetErrorString( xRet ))
		If FERASE(cPathSrv_+_cArq+".pdf") == -1
			MsgStop('Falha na deleÁ„o do Arquivo')
		EndIf
	Else
		nStatus := frenameex(cPathSrv_+_cArq+".pdf",cPathSrv_+"enviados\"+_cArq+".pdf")
		If nStatus == -1
			MsgStop('Falha na operaÁ„o 3 : FError '+str(ferror(),4))
		Endif
	EndIf
   
	xRet := oServer:SMTPDisconnect()
	If xRet <> 0
		Alert("N„o foi possÌvel desconectar o servidor SMTP: " + oServer:GetErrorString( xRet ))
	EndIf

Return()


Static Function EspacoAt(cString, nTam)

Local nRetorno := 0
Local nX       := 0

/**
* Caso a posiÁ„o (nTam) for maior que o tamanho da string, ou for um valor
* inv·lido, retorna 0.
*/
If nTam > Len(cString) .Or. nTam < 1
	nRetorno := 0
	Return nRetorno
EndIf

/**
* Procura pelo caractere de espaÁo anterior a posiÁ„o e retorna a posiÁ„o
* dele.
*/
nX := nTam
While nX > 1
	If Substr(cString, nX, 1) == " "
		nRetorno := nX
		Return nRetorno
	EndIf
	
	nX--
EndDo


/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±⁄ƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¬ƒƒƒƒƒƒ¬ƒƒƒƒƒƒƒƒƒƒø±±
±±≥Programa   ≥   C()   ≥ Autores ≥ Norbert/Ernani/Mansano ≥ Data ≥10/05/2005≥±±
±±√ƒƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao  ≥ Funcao responsavel por manter o Layout independente da       ≥±±
±±≥           ≥ resolucao horizontal do Monitor do Usuario.                  ≥±±
±±¿ƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function C(nTam)                                                         
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
		nTam *= 0.8                                                                
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600                
		nTam *= 1                                                                  
	Else	// Resolucao 1024x768 e acima                                           
		nTam *= 1.28                                                               
	EndIf                                                                         
                                                                                
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø                                               
	//≥Tratamento para tema "Flat"≥                                               
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ                                               
	If "MP8" $ oApp:cVersion                                                      
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()                      
			nTam *= 0.90                                                            
		EndIf                                                                      
	EndIf                                                                         
Return Int(nTam)
