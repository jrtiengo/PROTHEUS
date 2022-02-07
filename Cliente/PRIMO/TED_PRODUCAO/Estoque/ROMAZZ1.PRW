//Bibliotecas
#Include "Protheus.ch"
#Include "TopConn.ch"

//Constantes
#Define STR_PULA		Chr(13)+Chr(10)

/*/{Protheus.doc} RomaZZ1
Relatório - Relatorio Romaneio Caçador    
@author zReport
@since 13/05/2021
@version 1.0
	@example
	u_RomaZZ1()
	@obs Função gerada pelo zReport()
/*/

User Function RomaZZ1(cVar1, cVar2,cVar3)
	Local aArea   := GetArea()
	Local oReport
	Local lEmail  := .F.
	Local cPara   := ""
	Private cPerg := Nil
	Private cFil    := cVar1
	Private cExped  := cVar2
	Private cDocSD3:= cVar3

    /*
	//Definições da pergunta
	cPerg := "PERGTESTE "
	
	//Se a pergunta não existir, zera a variável
	DbSelectArea("SX1")
	SX1->(DbSetOrder(1)) //X1_GRUPO + X1_ORDEM
	If ! SX1->(DbSeek(cPerg))
		cPerg := Nil
	EndIf
	*/

	//Cria as definições do relatório
	oReport := fReportDef()

	//Será enviado por e-Mail?
	If lEmail
		oReport:nRemoteType := NO_REMOTE
		oReport:cEmail := cPara
		oReport:nDevice := 3 //1-Arquivo,2-Impressora,3-email,4-Planilha e 5-Html
		oReport:SetPreview(.F.)
		oReport:Print(.F., "", .T.)
		//Senão, mostra a tela
	Else
		oReport:PrintDialog()
	EndIf

	RestArea(aArea)
Return

/*-------------------------------------------------------------------------------*
 | Func:  fReportDef                                                             |
 | Desc:  Função que monta a definição do relatório                              |
 *-------------------------------------------------------------------------------*/
	
Static Function fReportDef()
	Local oReport
	Local oSectDad := Nil
	Local oBreak := Nil
	Local oFunTot1 := Nil
	
	//Criação do componente de impressão
	oReport := TReport():New(	"RomaZZ1",;		//Nome do Relatório
								"Relatorio Romaneio " + ZZ1->ZZ1_NEXPE + " - Caçador ",;		//Título
								cPerg,;		//Pergunte ... Se eu defino a pergunta aqui, será impresso uma página com os parâmetros, conforme privilégio 101
								{|oReport| fRepPrint(oReport)},;		//Bloco de código que será executado na confirmação da impressão
								)		//Descrição
	oReport:SetTotalInLine(.F.)
	oReport:lParamPage := .F.
	oReport:oPage:SetPaperSize(9) //Folha A4
	oReport:SetLandscape()


    
    //Se a fonte for tamanho 8
	//oReport:SetLineHeight(50)
	//oReport:nFontBody := 08
		
	//Se a fonte for tamanho 12
	oReport:SetLineHeight(60)
	oReport:nFontBody := 10 // 12


	//Criando a seção de dados
	oSectDad := TRSection():New(	oReport,;		//Objeto TReport que a seção pertence
									"Dados",;		//Descrição da seção
									{"QRY_AUX"})		//Tabelas utilizadas, a primeira será considerada como principal da seção
	oSectDad:SetTotalInLine(.F.)  //Define se os totalizadores serão impressos em linha ou coluna. .F.=Coluna; .T.=Linha
	
	//Colunas do relatório
	//TRCell():New(oSectDad, "ZZ1_FILIAL", "QRY_AUX", "Filial", /*Picture*/, 4, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
//	TRCell():New(oSectDad, "ZZ1_NEXPE", "QRY_AUX", "Num.Exp. ", /*Picture*/, TamSX3("ZZ1_NEXPE" )[1], /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/.T. ,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
    TRCell():New(oSectDad, "ITEM", "QRY_AUX", "Item", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/1,/*lAutoSize*/.T.,/*nClrBack*/,/*nClrFore*/,/*lBold*/)	
	TRCell():New(oSectDad, "ZZ1_ITEM", "QRY_AUX", "Itm.Exp", /*Picture*/, 3, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/1,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)	
	TRCell():New(oSectDad, "ZZ1_ETIQ", "QRY_AUX", "Etiqueta", /*Picture*/,  TamSX3("ZZ1_ETIQ" )[1], /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/1,/*lAutoSize*/.T.,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
    TRCell():New(oSectDad, "ZZ1_PROD", "QRY_AUX", "Produto", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/1,/*lAutoSize*/.T.,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
    TRCell():New(oSectDad, "ZZ1_DESC", "QRY_AUX", "Descr.", /*Picture*/, 30, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/1,/*lAutoSize*/.T.,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
    TRCell():New(oSectDad, "ZZ1_LOCAL", "QRY_AUX", "Local", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/1,/*lAutoSize*/.T.,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
    TRCell():New(oSectDad, "ZZ1_QUANT", "QRY_AUX", "Qtd.", /*Picture*/"@E 999.9999", 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/1,/*lAutoSize*/.T.,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	TRCell():New(oSectDad, "ZZ1_OP", "QRY_AUX", "OP", /*Picture*/, 14, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/1,/*lAutoSize*/.T.,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	//TRCell():New(oSectDad, "ZZ1_OBS", "QRY_AUX", "OBSERVAÇÃO", /*Picture*/, 80, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	If Empty(cDocSD3)
		TRCell():New(oSectDad, "TIPO", "QRY_AUX", "TP", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/1,/*lAutoSize*/.T.,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
		TRCell():New(oSectDad, "CLI_FOR", "QRY_AUX", "Cli_Forn/Loja", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
		//TRCell():New(oSectDad, "ZZ1_LOJA", "QRY_AUX", "Loja", /*Picture*/, 4, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
		TRCell():New(oSectDad, "NREDUZ", "QRY_AUX", "Nome", /*Picture*/, 30, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)


			//TRCell():New(oSectDad, "ZZ1_USER", "QRY_AUX", "Usuário", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
		TRCell():New(oSectDad, "ZZ1_PEDVEN", "QRY_AUX", "Ped.Venda", /*Picture*/, 6, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
		TRCell():New(oSectDad, "ZZ1_DATAPV", "QRY_AUX", "Data PV", /*Picture*/, 10, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	Else
		TRCell():New(oSectDad, "ZZ1_DOCSD3", "QRY_AUX", "N.º Transf.SD3", /*Picture*/, TamSX3("ZZ1_QUANT" )[1], /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
		TRCell():New(oSectDad, "ZZ1_LOCDES", "QRY_AUX", "Local Dest.", /*Picture*/, 2, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	Endif
	
	//TRCell():New(oSectDad, "ZZ1_DATA", "QRY_AUX", "Data Emissão", /*Picture*/, 8, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
    //TRCell():New(oSectDad, "ZZ1_DOCSD3", "QRY_AUX", "DOC SD3", /*Picture*/, 9, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	//TRCell():New(oSectDad, "R_E_C_N_O_", "QRY_AUX", "R_e_c_n_o_", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	//TRCell():New(oSectDad, "R_E_C_D_E_L_", "QRY_AUX", "R_e_c_d_e_l_", /*Picture*/, 15, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	//TRCell():New(oSectDad, "ZZ1_COLET", "QRY_AUX", "Registro Col", /*Picture*/, 1, /*lPixel*/,/*{|| code-block de impressao }*/,/*cAlign*/,/*lLineBreak*/,/*cHeaderAlign */,/*lCellBreak*/,/*nColSpace*/,/*lAutoSize*/,/*nClrBack*/,/*nClrFore*/,/*lBold*/)
	
	
	//Definindo a quebra
	oBreak := TRBreak():New(oSectDad,{|| QRY_AUX->(ZZ1_NEXPE) + QRY_AUX->(ZZ1_PROD)  },{|| "Quebra: Romaneio + Produto" })
	oSectDad:SetHeaderBreak(.T.)
	
	//Totalizadores
	oFunTot1 := TRFunction():New(oSectDad:Cell("ZZ1_QUANT"),,"SUM",oBreak,,"@E 9,999,999.9999")
	oFunTot1:SetEndReport(.F.)
Return oReport
	
/*-------------------------------------------------------------------------------*
 | Func:  fRepPrint                                                              |
 | Desc:  Função que imprime o relatório                                         |
 *-------------------------------------------------------------------------------*/
	
Static Function fRepPrint(oReport)
	//Local nX	   := 0
	Local aArea    := GetArea()
	//Local cQryAux  := ""
	Local oSectDad := Nil
	Local nAtual   := 0
	Local nTotal   := 0
	
	//Pegando as seções do relatório
	oSectDad := oReport:Section(1)
	
	
	if select("QRY_AUX") > 0
    QRY_AUX->(DBCLOSEAREA())
	endif
//-------------------
//Criação do objeto
//-------------------
oTempTable := FWTemporaryTable():New( "QRY_AUX" )
//--------------------------
//Monta os campos da tabela
//--------------------------
aFields := {}

aTamSx3 := TamSX3("ZZ1_NEXPE" )
AADD(aFields,{ "ZZ1_NEXPE", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })

//Item do Relatório 
AADD(aFields,{ "ITEM", "N" ,3, 0 })


aTamSx3 := TamSX3("ZZ1_ITEM" )
AADD(aFields,{ "ZZ1_ITEM", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })

aTamSx3 := TamSX3("ZZ1_ETIQ" )
AADD(aFields,{ "ZZ1_ETIQ", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })

aTamSx3 := TamSX3("ZZ1_PROD" )
AADD(aFields,{ "ZZ1_PROD", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })

aTamSx3 := TamSX3("ZZ1_DESC" )
AADD(aFields,{ "ZZ1_DESC", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })

aTamSx3 := TamSX3("ZZ1_LOCAL" )
AADD(aFields,{ "ZZ1_LOCAL", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })

aTamSx3 := TamSX3("ZZ1_QUANT" )
AADD(aFields,{ "ZZ1_QUANT", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })

aTamSx3 := TamSX3("ZZ1_OP" )
AADD(aFields,{ "ZZ1_OP", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })

aTamSx3 := TamSX3("A1_COD" )
AADD(aFields,{ "CLI_FOR", aTamSx3[03],aTamSx3[01]+ 1 +TamSX3("A1_LOJA" )[1] , aTamSx3[02] })

aTamSx3 := TamSX3("A1_NREDUZ" )
AADD(aFields,{ "NREDUZ", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })

AADD(aFields,{ "TIPO", 'C',1, 0})

aTamSx3 := TamSX3("ZZ1_PEDVEN" )
AADD(aFields,{ "ZZ1_PEDVEN", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })

aTamSx3 := TamSX3("ZZ1_DATAPV" )
AADD(aFields,{ "ZZ1_DATAPV", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })

aTamSx3 := TamSX3("ZZ1_DOCSD3" )
AADD(aFields,{ "ZZ1_DOCSD3", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })

aTamSx3 := TamSX3("ZZ1_LOCDES" )
AADD(aFields,{ "ZZ1_LOCDES", aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })

oTemptable:SetFields( aFields )
oTempTable:AddIndex("01", {"ZZ1_NEXPE","ZZ1_PROD","ZZ1_ITEM"} ) //Ordenado por Produto
//oTempTable:AddIndex("02", {"ZZ1_NEXPE","ZZ1_ITEM","ZZ1_PROD"} ) //Ordenado por Item
//------------------
//Criação da tabela
//------------------
oTempTable:Create()


//conout('inserindo dados no arquivo temporario por SQL')
    cQuery := "INSERT INTO " + oTempTable:GetRealName() + ' ( '
	//Campos
	/*
	For nX := 1 To Len(aFields)
        cQuery += aFields[nX][1] + ","
	Next nX
    cQuery := SubStr(cQuery,1,Len(cQuery)-1)
	*/
	cQuery +='ZZ1_NEXPE, ITEM, ZZ1_ITEM, ZZ1_ETIQ,  ZZ1_PROD , ZZ1_DESC, ZZ1_LOCAL,ZZ1_QUANT, ZZ1_OP,'
	If Empty(cDocSD3)
		cQuery += " TIPO, CLI_FOR,NREDUZ,  ZZ1_PEDVEN, ZZ1_DATAPV"
	Else
		cQuery += "ZZ1_DOCSD3, ZZ1_LOCDES"
	Endif
    cQuery += ") "
	//Consulta
    	cQuery += "SELECT ZZ1_NEXPE, ROW_NUMBER() OVER (ORDER BY ZZ1_NEXPE,ZZ1_PROD,ZZ1_ITEM) AS ITEM, ZZ1_ITEM, ZZ1_ETIQ,  ZZ1_PROD ,' ' AS ZZ1_DESC, ZZ1_LOCAL,ZZ1_QUANT, ZZ1_OP,"
	If Empty(cDocSD3)
		cQuery += " CASE WHEN ZZ1_TPPV = 'N' THEN 'C' WHEN ZZ1_TPPV = 'B' THEN 'F' ELSE ' ' END AS TIPO, ZZ1_CLIENT+'/'+ZZ1_LOJA AS CLI_FOR,' ' AS NREDUZ,  ZZ1_PEDVEN, ZZ1_DATAPV"
	Else
		cQuery += "ZZ1_DOCSD3, ZZ1_LOCDES"
	Endif

    	cQuery += "  FROM " + RetSqlName("ZZ1")+ " WHERE ZZ1_FILIAL = '" + cFil + "' AND ZZ1_NEXPE = '" + cExped + "' AND D_E_L_E_T_  <> '*' " 		+ STR_PULA
	    

	MemoWrite("c:\temp\romazzi-"+ZZ1->ZZ1_NEXPE+".sql",cQuery)
    //conout(cQuery)
	if TCSqlExec(cQuery) > 0
        MsgAlert('ERRO AO INSERIR DADOS NA TABELA TEMPORARIA')
        return .t.
	endif

    /*
	//Montando consulta de dados
	cQryAux := ""
	cQryAux += "SELECT ZZ1_NEXPE, ZZ1_ITEM, ZZ1_ETIQ,  ZZ1_PROD ,ZZ1_LOCAL,ZZ1_QUANT, ZZ1_OP, ZZ1_CLIENT+'/'+ZZ1_LOJA AS CLI_FOR,CASE WHEN ZZ1_TPPV = 'N' THEN 'C' WHEN ZZ1_TPPV = 'B' THEN 'F' ELSE ' ' END AS TIPO,  ZZ1_PEDVEN, ZZ1_DATAPV , ZZ1_LOCDES " //ZZ1_FILIAL,ZZ1_NEXPE
    cQryAux += "  FROM ZZ1980 WHERE ZZ1_FILIAL = '" + cFil + "' AND ZZ1_NEXPE = '" + cExped + "' AND D_E_L_E_T_  <> '*' " 		+ STR_PULA
	cQryAux := ChangeQuery(cQryAux)
	*/



	DbSelectArea('QRY_AUX')

	//Executando consulta e setando o total da régua
	//TCQuery cQryAux New Alias "QRY_AUX"
	Count to nTotal



	oReport:SetMeter(nTotal)
	//TCSetField("QRY_AUX", "ZZ1_DATA", "D")
	//TCSetField("QRY_AUX", "ZZ1_DATAPV", "D")

	dbSelectArea("SA1")
	dbSetOrder(1)

	dbSelectArea("SA2")
	dbSetOrder(1)

	dbSelectArea("SB1")
	dbSetOrder(1)


	//Enquanto houver dados
	oSectDad:Init()
	QRY_AUX->(DbGoTop())
	While ! QRY_AUX->(Eof())

		If SB1->(MSSeek(xFilial("SB1") + QRY_AUX->ZZ1_PROD))
			RecLock("QRY_AUX",.F.)
			QRY_AUX->ZZ1_DESC := SB1->B1_DESC
			MsUnlock()
		Endif

		IF QRY_AUX->TIPO == 'C'
			If SA1->(MSSeek(xFilial("SA1") + STRTRAN(QRY_AUX->CLI_FOR,"/","")))
				RecLock("QRY_AUX",.F.)
				QRY_AUX->NREDUZ := SA1->A1_NREDUZ
				MsUnlock()
			Else
				RecLock("QRY_AUX",.F.)
				QRY_AUX->NREDUZ := 'n/d'
				MsUnlock()
			Endif

		ElseIf QRY_AUX->TIPO == 'F'
			If SA2->(MSSeek(xFilial("SA2") + STRTRAN(QRY_AUX->CLI_FOR,"/","")))
				RecLock("QRY_AUX",.F.)
				QRY_AUX->NREDUZ := SA2->A2_NREDUZ
				MsUnlock()
			Else
				RecLock("QRY_AUX",.F.)
				QRY_AUX->NREDUZ := 'n/d'
				MsUnlock()
			Endif
		ElseIf  !Empty(QRY_AUX->ZZ1_LOCDES)
			RecLock("QRY_AUX",.F.)
			QRY_AUX->NREDUZ := 'Transf.Sacos'
			MsUnlock()
		ELSE
			RecLock("QRY_AUX",.F.)
			QRY_AUX->NREDUZ := '---'
			MsUnlock()
		ENDIF

		//Incrementando a régua
		nAtual++
		oReport:SetMsgPrint("Imprimindo registro "+cValToChar(nAtual)+" de "+cValToChar(nTotal)+"...")
		oReport:IncMeter()

		//Imprimindo a linha atual
		oSectDad:PrintLine()

		QRY_AUX->(DbSkip())
	EndDo
	oSectDad:Finish()
	QRY_AUX->(DbCloseArea())

	RestArea(aArea)
Return
