#INCLUDE "MATR170.CH"
#INCLUDE "PROTHEUS.CH"

/*
Jean Rehermann - Solutio IT - 11/03/2021
Boletim de entrada baseado no MATR170 - Incluído o campo de classe de valor nos itens
*/
User Function TEDR170(cAlias,nReg,nOpcx)

	Local oReport

	oReport := ReportDef(cAlias,nReg,nOpcx)
	oReport:PrintDialog()

Return NIL

Static Function ReportDef(cAlias,nReg,nOpcx)

	Local oReport
	Local oEmpresa
	Local oFornec1
	Local oFornec2
	Local oClient1
	Local oClient2
	Local oNF
	Local oNFItem
	Local oEntCtb
	Local oQuali
	Local oDivPC
	Local oNFTot1
	Local oNFTot2
	Local oDupli
	Local oFisc1
	Local oFisc2
	Local oFisc3
	Local oCell
	Local aVencto	:= {}
	Local aImps		:= {}
	Local cAliasSF1 := "SF1"
	Local cAliasSD1 := "SD1"
	Local lAuto		:= ( nReg != Nil )

	oReport := TReport():New("TEDR170",STR0002,"MTR170", {|oReport| ReportPrint(oReport,@aVencto,@aImps,nReg,@cAliasSF1,@cAliasSD1)},STR0001)
	oReport:SetPortrait()	// Define a orientacao default de pagina do relatorio como Retrato.

	If lAuto
		oReport:ParamReadOnly() // Desabilita a edicao de parametros pelo usuario na tela de impressao
	EndIf

	oReport:HideParamPage()	// inibe impressao da pagina de parametros
	oReport:SetPageFooter(4,{|| ImpRoda(oReport)})  // define rodape

	Pergunte("MTR170",.F.)

	If lAuto
		dbSelectArea("SF1")
		dbGoto(nReg)
		MV_PAR01 := SF1->F1_DTDIGIT
		MV_PAR02 := SF1->F1_DTDIGIT
		MV_PAR03 := SF1->F1_DOC
		MV_PAR04 := SF1->F1_DOC
	EndIf

	// Secao 1 - Dados Boletim       			                               ³
	oSection1:= TRSection():New(oReport,STR0089,{"SF1"},/*Ordem*/)  //"Cabeçalho do Boletim (Parte 2)"
	oCell := TRCell():New(oSection1,"Tit"	,"",STR0002,,,,{|| STR0002+"   "+STR0047+(cAliasSD1)->D1_NUMSEQ ;  //"Boletim de Entrada"##"N. "
		+If((cAliasSF1)->F1_TIPO $ "DB", If( (cAliasSF1)->F1_TIPO=="D",STR0038,"  - "+AllTrim(STR0053)),"" ) })  //"Devolucao / Beneficiamento
	oCell:SetSize(3+Len(STR0002+STR0047)+TamSX3("D1_NUMSEQ")[1]+If((cAliasSF1)->F1_TIPO $ "DB",15,0) )
	oCell := TRCell():New(oSection1,"DtRec"	,"",STR0065,,,,{|| STR0065+dtoc((cAliasSF1)->F1_RECBMTO) }) //"Material recebido em: " //"Material Recebido em: "###"Material Recebido em: "
	oCell:SetSize(10+Len(STR0065)) //"Material Recebido em: "

	// Secao 0 - Cabecalho 	  	                                        	   ³
	oCabec:= TRSection():New(oSection1,STR0090,{"SF1"},/*Ordem*/) //"Cabeçalho do Boletim (Parte 1)"
	oCabec:SetHeaderSection(.F.)
		TRCell():New(oCabec,"Usu"	,"",STR0035,,Len(STR0035)+15,,{|| STR0035+CUSERNAME  })  //"Usuario: "
		TRCell():New(oCabec,"DtBase","",STR0036,,Len(STR0036)+10,,{|| STR0036+Dtoc(dDataBase) }) //" Data Base: "
		TRCell():New(oCabec,"DtImp" ,"",STR0048,,Len(STR0048)+35,,{|| Space(15)+STR0048+Dtoc(dDataBase) }) //"Data Impressao ")

	//³Secao 2 - Dados da Empresa			                                   ³
	oEmpresa := TRSection():New(oSection1,STR0091,{"SM0"},/*Ordem*/) //"Dados da Empresa/Filial"
		TRCell():New(oEmpresa,"M0_NOME","SM0","M0NOME",/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oEmpresa,"M0_FILIAL","SM0","M0FILIAL")
	oCell := TRCell():New(oEmpresa,"M0_CGC","SM0","M0CGC",,,,{|| "  - "+AllTrim(RetTitle("A1_CGC"))+": "+SM0->M0_CGC })
	oCell:SetSize(6+Len(AllTrim(RetTitle("A1_CGC")))+TamSX3("A1_CGC")[1])

	//³Secao 3 - Dados do Fornecedor - I	                                   ³
	oFornec1 := TRSection():New(oSection1,STR0092,{"SA2"},/*Ordem*/) //"Fornecedor (Parte 1)"
		TRCell():New(oFornec1,"A2_COD","SA2",/*Titulo*/,/*Picture*/,TamSX3("A2_COD")[1]+5,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oFornec1,"A2_LOJA","SA2",/*Titulo*/,/*Picture*/,TamSX3("A2_LOJA")[1]+5)
		TRCell():New(oFornec1,"A2_NOME","SA2",/*Titulo*/,/*Picture*/,60)
		TRCell():New(oFornec1,"A2_END","SA2")

	//³Secao 4 - Dados do Fornecedor - II	                                   ³
	oFornec2 := TRSection():New(oSection1,STR0093,{"SA2"},/*Ordem*/) //"Fornecedor (Parte 2)"
		TRCell():New(oFornec2,"A2_MUN","SA2")
		TRCell():New(oFornec2,"A2_EST","SA2")
	oCell := TRCell():New(oFornec2,"A2_CGC","SA2","@X",,,,{|| AllTrim(RetTitle("A2_CGC"))+': '+If(cPaisLoc<>"BRA",Transform(SA2->A2_CGC,PesqPict("SA2","A2_CGC")),Transform(SA2->A2_CGC,PicPesFJ(If(Len(AllTrim(SA2->A2_CGC))<14,"F","J")))) } )
	oCell:SetSize(10+Len(AllTrim(RetTitle("A2_CGC")))+TamSX3("A2_CGC")[1])
	If cPaisLoc <> "PTG"
		oCell := TRCell():New(oFornec2,"A2_INSCR","SA2",,,,,{|| AllTrim(RetTitle("A2_INSCR"))+': '+Transform(SA2->A2_INSCR,PesqPict("SA2","A2_INSCR")) } )
		oCell:SetSize(2+Len(AllTrim(RetTitle("A2_INSCR")))+TamSX3("A2_INSCR")[1])
		oCell := TRCell():New(oFornec2,"A2_INSCRM","SA2",,,,,{|| AllTrim(RetTitle("A2_INSCRM"))+': '+Transform(SA2->A2_INSCRM,PesqPict("SA2","A2_INSCRM")) } )
		oCell:SetSize(2+Len(AllTrim(RetTitle("A2_INSCRM")))+TamSX3("A2_INSCRM")[1])
	Endif

	//³Secao 5 - Dados do Cliente - I 		                                   ³
	oClient1 := TRSection():New(oSection1,STR0094,{"SA1"},/*Ordem*/) //"Cliente (Parte 1)"
		TRCell():New(oClient1,"A1_COD","SA1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oClient1,"A1_LOJA","SA1")
		TRCell():New(oClient1,"A1_NOME","SA1")
		TRCell():New(oClient1,"A1_END","SA1")

	//³Secao 6 - Dados do Cliente - II		                                   ³
	oClient2 := TRSection():New(oSection1,STR0095,{"SA1"},/*Ordem*/) //"Cliente (Parte 2)"
		TRCell():New(oClient2,"A1_MUN","SA1")
		TRCell():New(oClient2,"A1_EST","SA1")
	oCell := TRCell():New(oClient2,"CGCCLI","SA1",,,,,{|| AllTrim(RetTitle("A1_CGC"))+': '+Transform(SA1->A1_CGC,PicPesFJ(If(Len(AllTrim(SA1->A1_CGC))<14,"F","J"))) })
	oCell:SetSize(6+Len(AllTrim(RetTitle("A1_CGC")))+TamSX3("A1_CGC")[1])
	If cPaisLoc <> "PTG"
		oCell := TRCell():New(oClient2,"A1_INSCR","SA1",,,,,{|| AllTrim(RetTitle("A1_INSCR"))+': '+Transform(SA1->A1_INSCR,PesqPict("SA1","A1_INSCR")) } )
		oCell:SetSize(2+Len(AllTrim(RetTitle("A1_INSCR")))+TamSX3("A1_INSCR")[1])
		oCell := TRCell():New(oClient2,"A1_INSCRM","SA1",,,,,{|| AllTrim(RetTitle("A1_INSCRM"))+': '+Transform(SA1->A1_INSCRM,PesqPict("SA1","A1_INSCRM")) } )
		oCell:SetSize(2+Len(AllTrim(RetTitle("A2_INSCRM")))+TamSX3("A2_INSCRM")[1])
	Endif

	//³Secao 7 - Dados da Nota Fiscal	                                       ³
	oNF := TRSection():New(oSection1,STR0096,{"SF1"},/*Ordem*/) //"Cabeçalhos de documentos de entrada"
		TRCell():New(oNF,SerieNfId("SF1",3,"F1_SERIE"),"SF1",SerieNfId("SF1",7,"F1_SERIE"),/*Picture*/,SerieNfId("SF1",6,"F1_SERIE"),/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oNF,"F1_DOC"		,"SF1")
		TRCell():New(oNF,"F1_ESPECIE"	,"SF1")
		TRCell():New(oNF,"F1_TIPO"		,"SF1",/*Titulo*/,/*Picture*/,20)
		TRCell():New(oNF,"F1_EMISSAO"	,"SF1",/*Titulo*/,/*Picture*/,20)
		TRCell():New(oNF,"DTVENC"		,"",RetTitle("E2_VENCTO"),,20,,{|| If( Len(aVencto) == 1, Dtoc(aVencto[1]),If(Len(aVencto) ==0,STR0115,STR0040)) }) //"Diversos"
		TRCell():New(oNF,"F1_VALBRUT"	,"SF1")

	//³Secao 8 - Dados da Nota Fiscal - Itens                          	       ³
	oNFItem := TRSection():New(oSection1,STR0097,{"SD1","SB1"},/*Ordem*/) //"Itens de documentos de entrada"
		TRCell():New(oNFItem,"D1_COD"	,"SD1",/*Titulo*/,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oNFItem,"D1_UM"	,"SD1",STR0111)
		TRCell():New(oNFItem,"B1_DESC"	,"SB1",,,20)
	oNFItem:Cell("B1_DESC"):SetLineBreak()
		TRCell():New(oNFItem,"D1_LOCAL","SD1")
		TRCell():New(oNFItem,"D1_QUANT","SD1",/*Titulo*/,/*Picture*/,20)
		TRCell():New(oNFItem,"D1_VUNIT","SD1",,/*Picture*/,20)
		TRCell():New(oNFItem,"D1_TOTAL","SD1",,/*Picture*/,20)
		TRCell():New(oNFItem,"D1_IPI"	,"SD1",STR0112)
		TRCell():New(oNFItem,"D1_PICM"	,"SD1",STR0113)
		TRCell():New(oNFItem,"D1_CONTA","SD1")
		TRCell():New(oNFItem,"D1_CC"	,"SD1")
		TRCell():New(oNFItem,"D1_TES"	,"SD1",STR0110)
		TRCell():New(oNFItem,"D1_CF"	,"SD1",STR0114)
		TRCell():New(oNFItem,"D1_CUSTO","SD1",STR0013,,10,,{|| If( mv_par06==1,(cAliasSD1)->D1_CUSTO,(cAliasSD1)->D1_CUSTO / (cAliasSD1)->D1_QUANT ) }) //"Custo Total "
		TRCell():New(oNFItem,"D1_CLVL"	,"SD1","Classe Valor")

	//³Secao 9 - Entidades Contabeis 		                                   ³
	oEntCtb := TRSection():New(oSection1,STR0098,{"SDE"},/*Ordem*/) //"Entidades Contábeis"
	oCell := TRCell():New(oEntCtb,"DEITEMNF","")
	oCell:GetFieldInfo("DE_ITEMNF")
	oCell := TRCell():New(oEntCtb,"DEITEM"	,"")
	oCell:GetFieldInfo("DE_ITEM")
		TRCell():New(oEntCtb,"DEPERC"	,"",RetTitle("DE_PERC"),,6)
	oCell := TRCell():New(oEntCtb,"DECC"	,"")
	oCell:GetFieldInfo("DE_CC")
	oCell := TRCell():New(oEntCtb,"DECONTA"	,"")
	oCell:GetFieldInfo("DE_CONTA")
	oCell := TRCell():New(oEntCtb,"DEITEMCTA","")
	oCell:GetFieldInfo("DE_ITEMCTA")
	oCell := TRCell():New(oEntCtb,"DECLVL"	,"")
	oCell:GetFieldInfo("DE_CLVL")

	//³Secao 10 - Produtos Enviados ao Controle de Qualidade                   ³
	oQuali := TRSection():New(oSection1,STR0099,{"SD7"},/*Ordem*/) //"Produtos enviados ao CQ"
	oCell := TRCell():New(oQuali,"D7PRODUTO","",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	oCell:GetFieldInfo("D7_PRODUTO")
	oCell := TRCell():New(oQuali,"D7LOCAL"	,"")
	oCell:GetFieldInfo("D7_LOCAL")
	oCell := TRCell():New(oQuali,"D7LOCDEST","")
	oCell:GetFieldInfo("D7_LOCDEST")
	oCell := TRCell():New(oQuali,"D7DATA"	,"")
	oCell:GetFieldInfo("D7_DATA")
	oCell := TRCell():New(oQuali,"D7NUMERO"	,"")
	oCell:GetFieldInfo("D7_NUMERO")

	//³Secao 11 - Divergencia com Pedido de Compra                             ³
	oDivPC := TRSection():New(oSection1,STR0100,{"SC7"},/*Ordem*/) //"Divergência com Pedido de Compra"
	TRCell():New(oDivPC,"DivPC"	,"","Div",/*Picture*/,4,/*lPixel*/,/*{|| code-block de impressao }*/)
	oCell := TRCell():New(oDivPC,"C7NUM"	,"",RetTitle("C7_NUM"),,TamSX3("C7_NUM")[1]+TamSX3("C7_ITEM")[1]+10)
	oCell := TRCell():New(oDivPC,"C7DESCRI"	,"")
	oCell:GetFieldInfo("C7_DESCRI")
	If cPaisLoc == "BRA"
		oCell:SetSize(23)
	Else
		oCell:SetSize(18)
	EndIf
	oCell:SetLineBreak()
	oCell := TRCell():New(oDivPC,"C7QUANT"	,"",RetTitle("C7_QUANT"),,20)
	oCell := TRCell():New(oDivPC,"C7PRECO"	,"",RetTitle("C7_PRECO"),,20)
	oCell := TRCell():New(oDivPC,"C7EMISSAO","")
	oCell:GetFieldInfo("C7_EMISSAO")
	oCell:SetSize(20)
	oCell := TRCell():New(oDivPC,"C7DATPRF"	,"")
	oCell:GetFieldInfo("C7_DATPRF")
	oCell:SetSize(20)
	oCell := TRCell():New(oDivPC,"C7NUMSC"	,"")
	oCell:GetFieldInfo("C7_NUMSC")
	oCell:SetSize(20)
	oCell := TRCell():New(oDivPC,"C1SOLICIT","")
	oCell:GetFieldInfo("C1_SOLICIT")
	oCell := TRCell():New(oDivPC,"C1CC","")
	oCell:GetFieldInfo("C1_CC")
	oCell:SetSize(20)
	oCell := TRCell():New(oDivPC,"E4DESCRI"	,"")
	oCell:GetFieldInfo("E4_DESCRI")

	//³Secao 12 - TOTAIS DA NF (1/2)                                           ³
	oNFTot1 := TRSection():New(oSection1,STR0101,{"SF1"},/*Ordem*/) //"Totais da Nota Fiscal (Parte 1)"
	If cPaisLoc=="BRA"
		TRCell():New(oNFTot1,"F1_BASEICM"	,"SF1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
		TRCell():New(oNFTot1,"F1_VALICM"	,"SF1")
		TRCell():New(oNFTot1,"F1_BRICMS"	,"SF1")
		TRCell():New(oNFTot1,"F1_ICMSRET"	,"SF1")
	Else
		TRCell():New(oNFTot1,"QTIMP1"	,"",STR0067	,"@E 999,999,999,999.99",,,{|| aImps[1] }) //"Base de Calculo Imp."
		TRCell():New(oNFTot1,"VLIMP1"	,"",STR0068	,"@E 999,999,999,999.99",,,{|| aImps[2] }) //"Valor dos Impostos"
	EndIf
	TRCell():New(oNFTot1,"F1_VALMERC"	,"SF1")
	TRCell():New(oNFTot1,"F1_DESCONT"	,"SF1")

	//³Secao 13 - TOTAIS DA NF (2/2)                                           ³
	oNFTot2 := TRSection():New(oSection1,STR0102,{"SF1"},/*Ordem*/) //"Totais da Nota Fiscal (Parte 2)"
	TRCell():New(oNFTot2,"F1_FRETE"	,"SF1",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oNFTot2,"F1_SEGURO"	,"SF1")
	TRCell():New(oNFTot2,"F1_DESPESA"	,"SF1")
	If cPaisLoc=="BRA"
		TRCell():New(oNFTot2,"F1_VALIPI"	,"SF1")
	EndIf
	TRCell():New(oNFTot2,"F1_VALBRUT"	,"SF1")

	//³Secao 14 - DESDOBRAMENTO DAS DUPLICATAS                                 ³
	oDupli := TRSection():New(oSection1,STR0103,{"SE2"},/*Ordem*/) // "Contas a Pagar"
	oCell := TRCell():New(oDupli,"E2PREFIXO" ,"SE2",/*Titulo*/,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	oCell:GetFieldInfo("E2_PREFIXO")
	oCell := TRCell():New(oDupli,"E2NUM"	 ,"SE2")
	oCell:GetFieldInfo("E2_NUM")
	oCell := TRCell():New(oDupli,"E2PARCELA" ,"SE2")
	oCell:GetFieldInfo("E2_PARCELA")
	oCell := TRCell():New(oDupli,"E2VENCTO"	 ,"SE2")
	oCell:GetFieldInfo("E2_VENCTO")
	oCell := TRCell():New(oDupli,"E2VALOR"	 ,"SE2")
	oCell:GetFieldInfo("E2_VALOR")
	oCell := TRCell():New(oDupli,"E2NATUREZ" ,"SE2")
	oCell:GetFieldInfo("E2_NATUREZ")

	//³Secao 15 - DEMONSTRATIVO DOS LIVROS FISCAIS                             ³
	oFisc1 := TRSection():New(oSection1,STR0104,{"SF3"},/*Ordem*/) //"Livros Fiscais"
	oCell := TRCell():New(oFisc1,"IMP1" 	 ,"SF3"	,"IMP1",/*Picture*/,4,/*lPixel*/,/*{|| code-block de impressao }*/)
	oFisc1:Cell("IMP1"):HideHeader()
	oCell := TRCell():New(oFisc1,"CFOP" 	 ,"SF3")
	oCell:GetFieldInfo("F3_CFOP")
		TRCell():New(oFisc1,"ALIQ" 		,"SF3","Aliq","99")
		TRCell():New(oFisc1,"F3_VALCONT","SF3")
		TRCell():New(oFisc1,"BASEIMP1" ,"SF3",STR0069,"@E 999,999,999,999.99",16,.F.,,"RIGHT",.F.,"RIGHT") //"Base de Calculo"
		TRCell():New(oFisc1,"VALIMP1" 	,"SF3",STR0070,"@E 999,999,999,999.99",16,.F.,,"RIGHT",.F.,"RIGHT") //"Imposto"
		TRCell():New(oFisc1,"ISENTAS1" ,"SF3",STR0071,"@E 999,999,999,999.99",16,.F.,,"RIGHT",.F.,"RIGHT") //"Isentas"
		TRCell():New(oFisc1,"OUTRAS1" 	,"SF3",STR0072,"@E 999,999,999,999.99",16,.F.,,"RIGHT",.F.,"RIGHT") //"Outras"
		TRCell():New(oFisc1,"OBS1" 	,"SF3",STR0073,,22) //"Observacao"

	//³Secao 16 - DEMONSTRATIVO DOS DEMAIS IMPOSTOS - PIS / COFINS             ³
	oFisc2 := TRSection():New(oSection1,STR0105,{"SF1"},/*Ordem*/) //"Demais Impostos"
	oCell := TRCell():New(oFisc2,"IMP2"		,"","IMP2",/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)
	oFisc2:Cell("IMP2"):HideHeader()
		TRCell():New(oFisc2,"BASEIMP2","",STR0069,"@E 999,999,999,999.99") //"Base de Calculo"
		TRCell():New(oFisc2,"VALIMP2" ,"",STR0070,"@E 999,999,999,999.99",16,.F.,,"RIGHT",.F.,"RIGHT") //"Imposto"

	//³Secao 17 - DEMONSTRATIVO DOS LIVROS FISCAIS (LOCALIZADO)                ³
	oFisc3 := TRSection():New(oSection1,STR0106,{"SD1"},/*Ordem*/) //"Livros Fiscais (Localizado)"
	oCell := TRCell():New(oFisc3,"PRO3" ,"")
	oCell:GetFieldInfo("D1_COD")
		TRCell():New(oFisc3,"DESC3","",STR0074,,40) //"Descricao"
		TRCell():New(oFisc3,"IMP3"	,"",STR0075,,5) //"Imp"
		TRCell():New(oFisc3,"ALI3"	,"",STR0076,PesqPict("SD1","D1_ALQIMP6")) //"Aliq"
		TRCell():New(oFisc3,"BASEIMP3","",STR0069 ,"@E 999,999,999,999.99") //"Base de Calculo"
		TRCell():New(oFisc3,"VALORIMP3","",STR0077,"@E 999,999,999,999.99") //"Valor do imposto"

	oReport:HideHeader()

	oEmpresa:SetNoFilter({"SM0"})
	oClient1:SetNoFilter({"SA1"})
	oClient2:SetNoFilter({"SA1"})
	oFornec1:SetNoFilter({"SA2"})
	oFornec2:SetNoFilter({"SA2"})
	oFisc1:SetNoFilter({"SF3"})
	oQuali:SetNoFilter({"SD7"})
	oDivPC:SetNoFilter({"SC7"})
	oDupli:SetNoFilter({"SE2"})
	oNFItem:SetNoFilter({"SB1"})
	oEntCtb:SetNoFilter({"SDE"})

Return(oReport)


/*/
±±³Parametros³ExpO1: Objeto Report do Relatorio                           ³±±
±±³          ³ExpA1: Array contendo os vencimentos das duplicatas da NF   ³±±
±±³          ³ExpA2: Array c/ bases e valores de impostos (LOCALIZ.)	  ³±±
±±³          ³ExpN1 = Numero do registro   (ROT.AUT.)         	          ³±±
±±³          ³ExpC1 = Alias do arquivo SF1                  	          ³±±
±±³          ³ExpC2 = Alias do arquivo SD1                  	          ³±±
/*/
Static Function ReportPrint(oReport,aVencto,aImps,nReg,cAliasSF1,cAliasSD1)

	LOCAL aAreaSF3	:= SF3->(GetArea())
	LOCAL aAreaSF1	:= SF1->(GetArea())
	LOCAL aAreaSE2	:= SE2->(GetArea())
	LOCAL aAreaSC7	:= SC7->(GetArea())
	Local cAliasSB1 := "SB1"
	Local cAliasSF4 := "SF4"
	Local lQuery	:= .F.
	Local lQuali	:= .T.
	Local oSection1	:= oReport:Section(1)
	Local oCabec	:= oReport:Section(1):Section(1)
	Local oEmpresa	:= oReport:Section(1):Section(2)
	Local oFornec1	:= oReport:Section(1):Section(3)
	Local oFornec2	:= oReport:Section(1):Section(4)
	Local oClient1	:= oReport:Section(1):Section(5)
	Local oClient2	:= oReport:Section(1):Section(6)
	Local oNF 		:= oReport:Section(1):Section(7)
	Local oNFItem	:= oReport:Section(1):Section(8)
	Local oEntCtb	:= oReport:Section(1):Section(9)
	Local oQuali	:= oReport:Section(1):Section(10)
	Local oDivPC	:= oReport:Section(1):Section(11)
	Local oNFTot1	:= oReport:Section(1):Section(12)
	Local oNFTot2	:= oReport:Section(1):Section(13)
	Local oDupli	:= oReport:Section(1):Section(14)
	Local oFisc1	:= oReport:Section(1):Section(15)
	Local oFisc2	:= oReport:Section(1):Section(16)
	Local oFisc3	:= oReport:Section(1):Section(17)

	Local aAuxCombo1:= {"N","D","B","I","P","C","1","2","3"}
	Local aCombo1	:= {STR0051,;	//"Normal"
						STR0052,;	//"Devoluçao"
						STR0053,;	//"Beneficiamento"
						STR0054,;	//"Compl.  ICMS"
						STR0055,;	//"Compl.  IPI"
						STR0056,;	//"Compl. Preco/frete"
						STR0119,; //Compl. Preço
						STR0120,; //Compl. Quantidade
						STR0121}  //Compl. Frete
	Local cLocDest    := GetMV("MV_CQ")
	Local cForMunic   := GetMv("MV_MUNIC")
	Local aTotalNF    := {}
	Local aDivergencia:= {}
	Local aPedidos	  := {}
	Local aDescPed    := {}
	Local aCQ         := {}
	Local aEntCont    := {}
	Local cForAnt     := 0
	Local nDocAnt     := 0
	Local nX          := 0
	Local nImp        := 0
	Local nRecno      := 0
	Local lPedCom     := .F.
	Local cParcIR     := ""
	Local cParcINSS   := ""
	Local cParcISS    := ""
	Local cParcCof    := ""
	Local cParcPis    := ""
	Local cParcCsll   := ""
	Local cParcSest   := ""
	Local cDtEmis     := ""
	Local cPrefixo
	Local aItens      := {}
	Local nBasePis    := 0
	Local nValPis     := 0
	Local nBaseCof    := 0
	Local nValCof     := 0
	Local nCT         := 0
	Local nRec        := 0
	Local i           := 0
	Local nCell
	Local cFornece
	Local cLoja
	Local cDoc
	Local cSerie
	Local nISS
	Local lAuto	:= (nReg!=Nil)
	Local cFornIss 	  := ""
	Local cLojaIss    := ""
	Local cRemito     := ""
	Local cItemRem    := ""
	Local cSerieRem   := ""
	Local cFornRem    := ""
	Local cLojaRem    := ""
	Local cCodRem     := ""
	Local cPedido     := ""
	Local cItemPed    := ""
	Local cOrderBy
	Local cWhere	:= ""
	Local cCampos     := ""

	//impressao em planilha tipo tabela não disponível
	If oReport:nDevice == 4 .And. oReport:lXlsTable
		MsgAlert(STR0118,STR0117)
		oReport:CancelPrint()
	EndIf

	dbSelectArea("SB1")
	dbSetOrder(1)
	dbSelectArea("SF4")
	dbSetOrder(1)
	dbSelectArea("SD1")
	dbSetOrder(1)
	dbSelectArea("SC7")
	dbSetOrder(19)
	dbSelectArea("SC1")
	dbSetOrder(1)
	dbSelectArea("SE4")
	dbSetOrder(1)

	If lAuto
		dbSelectArea("SF1")
		dbGoto(nReg)
	Else
		dbSelectArea("SF1")
		dbSetOrder(1)
		//³Filtragem do relatorio                                                  ³
		cAliasSF1		:= GetNextAlias()
		cAliasSD1		:= cAliasSF1
		cAliasSB1		:= cAliasSF1
		cAliasSF4		:= cAliasSF1
		//³Transforma parametros Range em expressao SQL                            ³
		MakeSqlExpr(oReport:uParam)

		lQuery := .T.


		cWhere := "% NOT ("+IsRemito(3,'F1_TIPODOC')+ ")%"

		If mv_par07 == 1
			cOrderBy := "%F1_FILIAL,F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,D1_ITEM%"
		Else
			cOrderBy := "%F1_FILIAL,F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,D1_COD,D1_ITEM%"
		EndIf

		cCampos := "%F1_FILIAL,F1_DOC,F1_SERIE,F1_FORNECE,F1_LOJA,F1_DTDIGIT,F1_TIPO,F1_ESPECIE,F1_EMISSAO,F1_PREFIXO,F1_ISS,F1_VALBRUT,F1_BASEICM,F1_VALICM,F1_BRICMS,"
		cCampos += "F1_ICMSRET,F1_VALMERC,F1_DESCONT,F1_FRETE,F1_SEGURO,F1_DESPESA,F1_VALIPI,F1_VALBRUT,F1_TIPODOC,F1_RECBMTO,F1_BASIMP6,F1_VALIMP6,F1_BASIMP5,F1_VALIMP5, "
		If SF1->(FieldPos("F1_TPCOMPL")) >0
			cCampos += "F1_TPCOMPL, "
		EndIf
		cCampos += "D1_FILIAL,D1_DOC,D1_SERIE,D1_FORNECE,D1_LOJA,D1_ITEM,D1_TES,D1_PEDIDO,D1_ITEMPC,D1_QTDPEDI,D1_QUANT,D1_VUNIT,D1_DTDIGIT,D1_NUMCQ,D1_UM,D1_LOCAL, "
		cCampos += "D1_TOTAL,D1_IPI,D1_IPI,D1_PICM,D1_CONTA,D1_CC,D1_CF,D1_CLVL,D1_CUSTO,D1_RATEIO,D1_ITEMCTA,D1_CLVL,SD1.D1_NUMSEQ,D1_EMISSAO,D1_COD,"
		cCampos += "B1_COD,B1_DESC,F4_ESTOQUE,D1_REMITO,D1_ITEMREM,D1_SERIREM%"

		//³Query do relatorio da secao 1                                           ³
		oSection1:BeginQuery()
		BeginSql Alias cAliasSF1
			SELECT %Exp:cCampos%
			FROM  %table:SF1% SF1
			INNER JOIN %table:SD1% SD1 ON D1_FILIAL = F1_FILIAL	AND D1_DOC=F1_DOC AND D1_SERIE=F1_SERIE AND D1_FORNECE=F1_FORNECE AND D1_LOJA=F1_LOJA AND SD1.%NotDel%
			LEFT  JOIN %table:SF4% SF4 ON F4_FILIAL = %xFilial:SF4%	AND F4_CODIGO = D1_TES AND SF4.%NotDel%
			INNER JOIN %table:SB1% SB1 ON B1_FILIAL = %xFilial:SB1%	AND B1_COD = D1_COD AND SB1.%NotDel%
			WHERE F1_FILIAL=%xFilial:SF1% AND F1_DTDIGIT>=%Exp:Dtos(mv_par01)% AND F1_DTDIGIT<=%Exp:Dtos(mv_par02)% AND F1_DOC>=%Exp:mv_par03%	AND
				F1_DOC<= %Exp:mv_par04% AND %Exp:cWhere% AND SF1.%NotDel%
			ORDER BY %Exp:cOrderBy%
		EndSql
		oSection1:EndQuery()

		oNF:SetParentQuery()
		oNFItem:SetParentQuery()

	EndIf

	If !lQuery
		TRPosition():New(oNFItem,"SB1",1,{|| xFilial("SB1")+(cAliasSD1)->D1_COD })
	EndIf

	//³Inicio da impressao do fluxo do relatorio                               ³
	If !lAuto .And. !lQuery .And. !Empty(mv_par03)
		(cAliasSF1)->(dbSeek(xFilial("SF1")+mv_par03,.T.))
	ElseIf !lAuto
		(cAliasSF1)->(dbGoTop())
	EndIf

	oReport:SetMeter(SF1->(LastRec()))

	If mv_par06 == 2
		oNFItem:Cell("D1_CUSTO"):SetTitle(STR0012) // "Custo Unit. "
	EndIf
	If mv_par08 == 1
		oNFItem:Cell("B1_DESC"):SetSize(17)
	Else
		oNFItem:Cell("D1_LOCAL"):Disable()
	EndIf
	oNFItem:Cell("B1_DESC"):SetLineBreak()

	If cPaisLoc=="BRA"
		oNFItem:Cell("D1_TOTAL"):SetSize(12)
	Else
		oNFItem:Cell("D1_IPI"):Disable()
		oNFItem:Cell("D1_PICM"):Disable()
	EndIf
	If mv_par05 == 1
		oNFItem:Cell("D1_CC"):Disable()
	ElseIf mv_par05 == 2
		oNFItem:Cell("D1_CONTA"):Disable()
	Else
		oNFItem:Cell("D1_CONTA"):Disable()
		oNFItem:Cell("D1_CC"):Disable()
	EndIf
	dbSelectArea(cAliasSF1)

	While !oReport:Cancel() .And. !(cAliasSF1)->(Eof()) .And. ;
		(cAliasSF1)->F1_FILIAL == xFilial("SF1") .And. (cAliasSF1)->F1_DOC <= MV_PAR04
		If oReport:Cancel()
			Exit
		EndIf

		If (lAuto .And. (cAliasSF1)->(Recno()) <> nReg)
			(cAliasSF1)->(dbSkip())
			Loop
		EndIf

		oSection1:Init(.f.)
		oReport:IncMeter()

		If !lQuery
			dbSelectArea("SD1")
			dbSeek(xFilial("SD1")+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)
		Else
			dbSelectArea("SF1")
			dbSeek(xFilial("SF1")+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)
		EndIf

		//³Definicao do titulo do relatorio - muda a cada nota				³
		oReport:SetTitle(STR0002+" "+(cAliasSD1)->D1_NUMSEQ)

		aImps		 := {}
		aItens		 := {}
		aDivergencia := {}
		aPedidos     := {}
		aDescPed     := {}
		aEntCont     := {}
		aCQ			 := {}
		aVencto		 := {}
		aTotalNF	 := {}

		// Totais da NF
		aAdd(aTotalNF,(cAliasSF1)->F1_BASEICM)
		aAdd(aTotalNF,(cAliasSF1)->F1_VALICM)
		aAdd(aTotalNF,(cAliasSF1)->F1_ICMSRET)
		aAdd(aTotalNF,(cAliasSF1)->F1_VALMERC)
		aAdd(aTotalNF,(cAliasSF1)->F1_DESCONT)
		aAdd(aTotalNF,(cAliasSF1)->F1_FRETE)
		aAdd(aTotalNF,(cAliasSF1)->F1_SEGURO)
		aAdd(aTotalNF,(cAliasSF1)->F1_DESPESA)
		aAdd(aTotalNF,(cAliasSF1)->F1_VALIPI)
		aAdd(aTotalNF,(cAliasSF1)->F1_VALBRUT)
		If cPaisLoc <> "BRA"
			aImps	:= R170IMPT(cAliasSF1)
			aItens	:= R170IMPI(cAliasSF1)
		EndIf

		// Variaveis do cabecalho da NF
		cFornece := (cAliasSF1)->F1_FORNECE
		cLoja	 := (cAliasSF1)->F1_LOJA
		cDoc	 := (cAliasSF1)->F1_DOC
		cPrefixo := If(Empty((cAliasSF1)->F1_PREFIXO),&(GetMV("MV_2DUPREF")),(cAliasSF1)->F1_PREFIXO)
		cSerie	 := (cAliasSF1)->F1_SERIE
		cDtEmis  := (cAliasSF1)->F1_EMISSAO
		nISS	 := (cAliasSF1)->F1_ISS
		nBasePis := (cAliasSF1)->F1_BASIMP6
		nValPis  := (cAliasSF1)->F1_VALIMP6
		nBaseCof := (cAliasSF1)->F1_BASIMP5
		nValCof  := (cAliasSF1)->F1_VALIMP5

		//³Cabecalho 			  	                                        	   ³
		oCabec:Init(.F.)
		oCabec:PrintLine()
		oCabec:Finish()
		oReport:FatLine()
		//³Dados do Boletim		  	                                        	   ³
		oSection1:PrintLine()
		//³Dados da Empresa		  	                                        	   ³
		oEmpresa:Init(.f.)
		oEmpresa:PrintLine()
		oEmpresa:Finish()
		oReport:FatLine()

		If (cAliasSF1)->F1_TIPO $ "DB"
			dbSelectArea("SE1")
			dbSetOrder(2)
			dbSeek(xFilial("SE1")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_DOC)
			While !Eof() .And. E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM == ;
				xFilial("SE1")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_DOC
				If ALLTRIM(E1_ORIGEM)=="MATA100"
					aADD(aVencto,E1_VENCREA)
				EndIf
				dbSkip()
			EndDo

			oReport:PrintText(STR0078) //"Dados do Cliente"
			dbSelectArea("SA1")
			dbSetOrder(1)
			dbSeek(xFilial("SA1")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)
			oClient1:Init(.F.)
			oClient1:PrintLine()
			oClient2:Init(.F.)
			oClient2:PrintLine()
			oClient2:Finish()
			oClient1:Finish()
		Else
			dbSelectArea("SE2")
			dbSetOrder(6)
			dbSeek(xFilial("SE2")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+cPrefixo+(cAliasSF1)->F1_DOC)
			While !Eof() .And. E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM == ;
				xFilial("SE2")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA+cPrefixo+(cAliasSF1)->F1_DOC
				If ALLTRIM(E2_ORIGEM)=="MATA100"
					aADD(aVencto,E2_VENCTO)
				EndIf
				dbSkip()
			EndDo

			oReport:PrintText(STR0066) //"Dados do Fornecedor"
			dbSelectArea("SA2")
			dbSetOrder(1)
			dbSeek(xFilial("SA2")+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)
			nCell := Len(AllTrim(RetTitle("A2_CGC"))+': '+If(cPaisLoc<>"BRA",Transform(SA2->A2_CGC,PesqPict("SA2","A2_CGC")),Transform(SA2->A2_CGC,PicPesFJ(If(Len(AllTrim(SA2->A2_CGC))<14,"F","J")))))
			oFornec1:Init(.f.)
			oFornec1:PrintLine()
			oFornec2:Init(.f.)
			oFornec2:PrintLine()
			oFornec2:Finish()
			oFornec1:Finish()
		EndIf
		oReport:FatLine()

		//³ Impressao do cabecalho da Nota de Entrada                    ³
		oReport:SkipLine()
		oReport:PrintText(STR0006) // "------------------------------------------------------- DADOS DA NOTA FISCAL -------------------------------------------------------"
		oNF:Init(.t.)
		If SF1->(ColumnPos("F1_TPCOMPL")) > 0 .And. (cAliasSF1)->F1_TIPO == "C" .And. !Empty((cAliasSF1)->F1_TPCOMPL)
			oNF:Cell("F1_TIPO"):SetValue(aCombo1[aScan(aAuxCombo1,(cAliasSF1)->F1_TPCOMPL)])
		Else
			oNF:Cell("F1_TIPO"):SetValue(aCombo1[aScan(aAuxCombo1,(cAliasSF1)->F1_TIPO)])
		EndIf
		oNF:PrintLine()

		//³ Impressao dos itens da Nota de Entrada                       ³
		dbSelectArea(cAliasSD1)
		nDocAnt := D1_DOC+D1_SERIE
		cForAnt := D1_FORNECE+D1_LOJA

		oNFItem:Init(.t.)
		While (!oReport:Cancel() .And. !Eof() .And. (cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE == nDocAnt .And.;
			cForAnt == (cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA .And. (cAliasSD1)->D1_FILIAL == xFilial("SD1") )
			If oReport:Cancel()
				Exit
			EndIf
			aArea := GetArea()
			If !lQuery
				dbSelectArea("SF4")
				dbSetOrder(1)
				dbSeek(xFilial("SF4")+(cAliasSD1)->D1_TES)
			EndIf
			cPedido   := (cAliasSD1)->D1_PEDIDO
			cItemPed  := (cAliasSD1)->D1_ITEMPC

			If cPaisLoc <> "BRA" .And. !Empty((cAliasSD1)->D1_REMITO)
				cRemito   := (cAliasSD1)->D1_REMITO
				cItemRem  := (cAliasSD1)->D1_ITEMREM
				cSerieRem := (cAliasSD1)->D1_SERIREM
				cFornRem  := (cAliasSD1)->D1_FORNECE
				cLojaRem  := (cAliasSD1)->D1_LOJA
				cCodRem	  := (cAliasSD1)->D1_COD

				dbSelectArea("SD1")
				SD1->(dbSetOrder(1))
				If SD1->(dbSeek(xFilial("SD1")+cRemito+cSerieRem+cFornRem+cLojaRem+cCodRem+Alltrim(cItemRem)))
					If !Empty(SD1->D1_PEDIDO)
						cPedido   := SD1->D1_PEDIDO
						cItemPed  := SD1->D1_ITEMPC
					Endif
				Endif
				RestArea(aArea)
			Endif

			dbSelectArea("SC7")
			dbSetOrder(19)
			dbSeek(xFilial("SC7")+(cAliasSD1)->D1_COD+cPedido+cItemPed)
			If Empty(SC7->C7_NUM)
				aADD(aDivergencia,STR0079) //"Err"
				aADD(aPedidos,{"",STR0014,"","","","","","","",""}) //"Sem Pedido de Compra"
			Else
				dbSelectArea("SC1")
				dbSetOrder(2)
				dbSeek(xFilial("SC1")+SC7->C7_PRODUTO+SC7->C7_NUMSC+SC7->C7_ITEMSC)
				dbSelectArea("SE4")
				dbSetOrder(1)
				dbSeek(xFilial("SE4")+SC7->C7_COND)
				lPedCom := !Empty(IF(SC7->C7_TIPO == 1,SubStr(SC1->C1_SOLICIT,1,15), SubStr(UsrFullName(SC7->C7_USER),1,15))+SC7->C7_CC)
				cProblema := ""
				If ( (cAliasSD1)->D1_QTDPEDI > 0 .And. (SC7->C7_QUANT <> (cAliasSD1)->D1_QTDPEDI) ) .Or. ;
					SC7->C7_QUANT <> (cAliasSD1)->D1_QUANT
					cProblema += "Q"
				Else
					cProblema += " "
				EndIf
				If (SC7->C7_QUANT - SC7->C7_QUJE) < (cAliasSD1)->D1_QUANT  .AND. (cAliasSD1)->D1_TES == "   "
					n_proc1 :=-((cAliasSD1)->D1_QUANT - (SC7->C7_QUANT - SC7->C7_QUJE)) / SC7->C7_QUANT * 100
				EndIf
				If (cAliasSD1)->D1_TES != "   " .AND. (SC7->C7_QUANT - SC7->C7_QUJE) < 0
					N_PORC1 :=-(SC7->C7_QUANT - SC7->C7_QUJE) / SC7->C7_QUANT * 100
				EndIf
				If If(Empty(SC7->C7_REAJUST),SC7->C7_PRECO,Formula(SC7->C7_REAJUST)) # (cAliasSD1)->D1_VUNIT
					If SC7->C7_MOEDA <> 1
						cProblema := cProblema+"M"
					Else
						cProblema := cProblema+"P"
					EndIf
				Else
					cProblema := cProblema+" "
				EndIf
				If SC7->C7_DATPRF <> (cAliasSD1)->D1_DTDIGIT
					cProblema := cProblema+"E"
				Else
					cProblema := cProblema+" "
				EndIf
				If !Empty(cProblema)
					aADD(aDivergencia,cProblema)
				Else
					aADD(aDivergencia,"Ok ")
				Endif
				aADD(aPedidos,{SC7->C7_NUM+"/"+SC7->C7_ITEM,;
					SC7->C7_DESCRI,;
					TransForm(SC7->C7_QUANT,PesqPict("SC7","C7_QUANT",11)),;
					TransForm(SC7->C7_PRECO,PesqPict("SC7","C7_PRECO",13)),;
					DTOC(SC7->C7_EMISSAO),;
					DTOC(SC7->C7_DATPRF),;
					SC7->C7_NUMSC+"/"+SC7->C7_ITEMSC,;
					If(lPedCom,IF(SC7->C7_TIPO == 1,SubStr(SC1->C1_SOLICIT,1,15), SubStr(UsrFullName(SC7->C7_USER),1,15)),"") ,;
					If(lPedCom,SC7->C7_CC,""),;
					AllTrim(SE4->E4_DESCRI)} )
			Endif
			If !Empty((cAliasSD1)->D1_NUMCQ) .AND. (cAliasSF4)->F4_ESTOQUE == "S"
				AADD(aCQ,(cAliasSD1)->D1_NUMCQ+(cAliasSD1)->D1_COD+cLocDest+"001"+Dtos((cAliasSD1)->D1_DTDIGIT))
			Endif
			dbSelectArea(cAliasSD1)
			oNFItem:PrintLine()

			// Entidades Contabeis
			If ( mv_par05 == 3 )
				If ( (cAliasSD1)->D1_RATEIO == "1" )
					dbSelectArea("SDE")
					dbSetOrder(1)
					If MsSeek(xFilial("SDE")+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_ITEM)
						While !Eof() .And. DE_FILIAL+DE_DOC+DE_SERIE+DE_FORNECE+DE_LOJA+DE_ITEMNF ==;
							xFilial("SDE")+(cAliasSD1)->D1_DOC+(cAliasSD1)->D1_SERIE+(cAliasSD1)->D1_FORNECE+(cAliasSD1)->D1_LOJA+(cAliasSD1)->D1_ITEM
							aAdd(aEntCont,{SDE->DE_ITEMNF,SDE->DE_ITEM,Transform(SDE->DE_PERC,"@E 999.99"),SDE->DE_CC,SDE->DE_CONTA,SDE->DE_ITEMCTA,SDE->DE_CLVL})
							dbSkip()
						EndDo
					EndIf
				Else
					If !Empty((cAliasSD1)->D1_CC) .Or. !Empty((cAliasSD1)->D1_CONTA) .Or. !Empty((cAliasSD1)->D1_ITEMCTA)
						aAdd(aEntCont,{(cAliasSD1)->D1_ITEM," - ","   -  ",(cAliasSD1)->D1_CC,(cAliasSD1)->D1_CONTA,(cAliasSD1)->D1_ITEMCTA,(cAliasSD1)->D1_CLVL})
					EndIf
				EndIf
			EndIf
			dbSelectArea(cAliasSD1)
			dbSkip()
		EndDo
		oNFItem:Finish()
		oNF:Finish()
		oReport:FatLine()

		//³ Imprime Entidades Contabeis ³
		If Len(aEntCont) > 0
			oReport:SkipLine()
			oReport:PrintText(STR0061)  //"------------------------------------------------------- ENTIDADES CONTABEIS ---------------------------------------------------------"
			oEntCtb:Init()
			For nX:=1 to Len(aEntCont)
				oEntCtb:Cell("DEITEMNF"):SetValue(aEntCont[nX][1])
				oEntCtb:Cell("DEITEM"):SetValue(aEntCont[nX][2])
				oEntCtb:Cell("DEPERC"):SetValue(aEntCont[nX][3])
				oEntCtb:Cell("DECC"):SetValue(aEntCont[nX][4])
				oEntCtb:Cell("DECONTA"):SetValue(aEntCont[nX][5])
				oEntCtb:Cell("DEITEMCTA"):SetValue(aEntCont[nX][6])
				oEntCtb:Cell("DECLVL"):SetValue(aEntCont[nX][7])
				oEntCtb:PrintLine()
			Next
			oEntCtb:Finish()
			oReport:FatLine()
		EndIf

		//³ Imprime produtos enviados ao Controle de Qualidade SD7       ³
		If Len(aCQ) > 0
			oReport:SkipLine()
			oReport:PrintText(STR0015)//"------------------------------------------- PRODUTO(s) ENVIADO(s) AO CONTROLE DE QUALIDADE -----------------------------------------"
			lFirst := .T.
			For nX:=1 to Len(aCQ)
				dbSelectArea("SD7")
				dbSetOrder(1)
				If dbSeek(xFilial("SD7")+aCQ[nX])
					If lFirst
						oQuali:Init()
						lFirst := .F.
						lQuali := .T.
					EndIf
					oQuali:Cell("D7PRODUTO"):SetValue(SD7->D7_PRODUTO)
					oQuali:Cell("D7LOCAL"):SetValue(SD7->D7_LOCAL)
					oQuali:Cell("D7LOCDEST"):SetValue(SD7->D7_LOCDEST)
					oQuali:Cell("D7DATA"):SetValue(SD7->D7_DATA)
					oQuali:Cell("D7NUMERO"):SetValue(SD7->D7_NUMERO)
					oQuali:PrintLine()
				EndIf
			Next
			If lQuali
				oQuali:Finish()
				oReport:FatLine()
			EndIf
		EndIf

		//³ Imprime Divergencia com Pedido de Compra                     ³
		If !Empty(aPedidos) .And. !Empty(aDivergencia)
			oReport:SkipLine()
			oReport:PrintText(STR0019)  //"--------------------------------------------- DIVERGENCIAS COM O PEDIDO DE COMPRA --------------------------------------------------"
			oDivPC:Init()
			dbSelectArea("SC7")
			dbSetOrder(1)
			For nX := 1 To Len(aPedidos)
				dbSeek(xFilial("SC7")+Substr(aPedidos[nX][1],1,len(SC7->C7_NUM))+Substr(aPedidos[nX][1],len(SC7->C7_NUM)+2,len(SC7->C7_ITEM)))
				oDivPC:Cell("DivPC"):SetValue(aDivergencia[nX])
				oDivPC:Cell("C7NUM"):SetValue(aPedidos[nX][1])
				oDivPC:Cell("C7DESCRI"):SetValue(aPedidos[nX][2])
				oDivPC:Cell("C7QUANT"):SetValue(aPedidos[nX][3])
				oDivPC:Cell("C7PRECO"):SetValue(aPedidos[nX][4])
				oDivPC:Cell("C7EMISSAO"):SetValue(aPedidos[nX][5])
				oDivPC:Cell("C7DATPRF"):SetValue(aPedidos[nX][6])
				oDivPC:Cell("C7NUMSC"):SetValue(aPedidos[nX][7])
				oDivPC:Cell("C1SOLICIT"):SetValue(aPedidos[nX][8])
				oDivPC:Cell("C1CC"):SetValue(aPedidos[nX][9])
				oDivPC:Cell("E4DESCRI"):SetValue(aPedidos[nX][10])
				oDivPC:PrintLine()
			Next
			oDivPC:Finish()
			oReport:FatLine()
		EndIf

		//³ Imprime Totais da Nota Fiscal                                ³
		oReport:SkipLine()
		oReport:PrintText(STR0023) //"------------------------------------------------------- TOTAIS DA NOTA FISCAL ------------------------------------------------------"
		oNFTot1:Init()
		If cPaisLoc=="BRA"
			oNFTot1:Cell("F1_BASEICM"):SetValue(aTotalNF[1])
			oNFTot1:Cell("F1_VALICM"):SetValue(aTotalNF[2])
			oNFTot1:Cell("F1_ICMSRET"):SetValue(aTotalNF[3])
		EndIf
		oNFTot1:Cell("F1_VALMERC"):SetValue(aTotalNF[4])
		oNFTot1:Cell("F1_DESCONT"):SetValue(aTotalNF[5])
		oNFTot1:PrintLine()
		oReport:ThinLine()
		oNFTot2:Init()
		oNFTot2:Cell("F1_FRETE"):SetValue(aTotalNF[6])
		oNFTot2:Cell("F1_SEGURO"):SetValue(aTotalNF[7])
		oNFTot2:Cell("F1_DESPESA"):SetValue(aTotalNF[8])
		If cPaisLoc=="BRA"
			oNFTot2:Cell("F1_VALIPI"):SetValue(aTotalNF[9])
		EndIf
		oNFTot2:Cell("F1_VALBRUT"):SetValue(aTotalNF[10])
		oNFTot2:PrintLine()
		oNFTot2:Finish()
		oNFTot1:Finish()
		oReport:FatLine()

		//³ Imprime desdobramento de Duplicatas                          ³
		dbSelectArea("SE2")
		dbSetOrder(6)

		//³ Carrega array conforme parâmetros                            ³
		If nCT == 0
			aFornece := {{cFornece,cLoja,PadR(MVNOTAFIS,Len(SE2->E2_TIPO))},;
						{PadR(GetMv('MV_UNIAO')        ,Len(SE2->E2_FORNECE)),PadR(Replicate('0',Len(SE2->E2_LOJA)),Len(SE2->E2_LOJA)),PadR(MVTAXA,Len(SE2->E2_TIPO)) },;
						{PadR(GetMv('MV_FORINSS')      ,Len(SE2->E2_FORNECE)),PadR('00',Len(SE2->E2_LOJA)),PadR(MVINSS,Len(SE2->E2_TIPO))},;
						{PadR(GetMv('MV_MUNIC')        ,Len(SE2->E2_FORNECE)),PadR('00',Len(SE2->E2_LOJA)),PadR(MVISS ,Len(SE2->E2_TIPO))},;
						{PadR(GetMv('MV_FORSEST')      ,Len(SE2->E2_FORNECE)),PadR('00',Len(SE2->E2_LOJA)),PadR("SES" ,Len(SE2->E2_TIPO))} }

			nCT+=1
		EndIf

		If dbSeek(xFilial("SE2")+cFornece+cLoja+cPrefixo+cDoc)
			nRec:=RECNO()
			oReport:SkipLine()
			oReport:PrintText(STR0026)//"--------------------------------------------------- DESDOBRAMENTO DE DUPLICATAS ----------------------------------------------------"
			oDupli:Init()

			While !Eof() .And. xFilial('SE2')+cFornece+cLoja+cPrefixo+cDoc==;
				E2_FILIAL+E2_FORNECE+E2_LOJA+E2_PREFIXO+E2_NUM

				If SE2->E2_TIPO == aFornece[1,3]

					R170DupTR(oReport)
					cParcCSS := SE2->E2_PARCCSS
					cParcIR  := SE2->E2_PARCIR
					cParcINSS:= SE2->E2_PARCINS
					cParcISS := SE2->E2_PARCISS
					cParcCof := SE2->E2_PARCCOF
					cParcPis := SE2->E2_PARCPIS
					cParcCsll:= SE2->E2_PARCSLL
					cParcSest:= SE2->E2_PARCSES
					If !Empty(SE2->E2_FORNISS) .And. !Empty(SE2->E2_LOJAISS)
						cFornIss := SE2->E2_FORNISS
						cLojaIss := SE2->E2_LOJAISS
					Else
						cFornIss := aFornece[4,1]
						cLojaIss :=	aFornece[4,2]
					Endif

					nRecno   := SE2->(Recno())

					dbSelectArea('SE2')
					dbSetOrder(1)
					If (!Empty(cParcIR)).And.dbSeek(xFilial('SE2')+cPrefixo+cDoc+cParcIR+aFornece[2,3]+aFornece[2,1]+aFornece[2,2])
						R170DupTR(oReport)
					Endif
					If (!Empty(cParcINSS)).And.dbSeek(xFilial('SE2')+cPrefixo+cDoc+cParcINSS+aFornece[3,3])
						R170DupTR(oReport)
					Endif

					For i=1 to Len(aFornece)
						If AllTrim(aFornece[i,1])==alltrim(cForMunic)
							If (!Empty(cParcISS)).And.dbSeek(xFilial('SE2')+cPrefixo+cDoc+cParcISS+aFornece[i,3]+cFornIss+aFornece[i,2])
								IF cDtEmis == SE2->E2_EMISSAO
									R170DupTR(oReport)
								EndIf
							EndIf
						EndIf
					Next i

					If (!Empty(cParcCof)).And.dbSeek(xFilial('SE2')+cPrefixo+cDoc+cParcCof+aFornece[2,3])
						R170DupTR(oReport)
					Endif
					If (!Empty(cParcPis)).And.dbSeek(xFilial('SE2')+cPrefixo+cDoc+cParcPis+aFornece[2,3])
						R170DupTR(oReport)
					Endif
					If (!Empty(cParcCsll)).And.dbSeek(xFilial('SE2')+cPrefixo+cDoc+cParcCsll+aFornece[2,3])
						R170DupTR(oReport)
					Endif

					If (!Empty(cParcCSS)).And.dbSeek(xFilial('SE2')+cPrefixo+cDoc+cParcCSS+aFornece[2,3])
						While !Eof() .And. xFilial('SE2')+cPrefixo+cDoc+cParcCSS+aFornece[2,3] ==;
								SE2->E2_FILIAL+SE2->E2_PREFIXO+SE2->E2_NUM+SE2->E2_PARCELA+SE2->E2_TIPO

							If PadR(GetMv('MV_CSS'),Len(SE2->E2_NATUREZ)) == SE2->E2_NATUREZ
								R170DupTR(oReport)
							EndIf

							dbSelectArea('SE2')
							dbSetOrder(1)
							dbSkip()
						EndDo
					Endif
					If (!Empty(cParcSest)).And.dbSeek(xFilial('SE2')+cPrefixo+cDoc+cParcSest+aFornece[5,3])
						R170DupTR(oReport)
					Endif

					SE2->(dbGoto(nRecno))

				EndIf

				dbSelectArea('SE2')
				dbSetOrder(6)
				dbSkip()
			EndDo
			oDupli:Finish()
			oReport:FatLine()
		Endif

		//³ Imprime Dados dos Livros Fiscais                             ³
		If cPaisloc=="BRA"
			dbSelectArea("SF3")
			dbSetOrder(4)
			If dbSeek(xFilial("SF3")+cFornece+cLoja+cDoc+cSerie)
				lFirst := .T.
				While ! Eof() .And. xFilial("SF3")+cFornece+cLoja+cDoc+cSerie==F3_FILiAL+F3_CLiEFOR+F3_LOJA+F3_NFISCAL+F3_SERIE

					If Val(Substr(SF3->F3_CFO,1,1))<5

						If lFirst
							oReport:SkipLine()
							oReport:PrintText(STR0030) //"----------------------------------------------- DEMONSTRATIVO DOS LIVROS FISCAIS ---------------------------------------------------"
							oFisc1:Init(.t.)
							lFirst := .F.
						EndIf
						oFisc1:Cell("IMP1"):SetValue(If(!Empty(nISS) .And. SF3->F3_TIPO == "S" ,STR0087,STR0088)) //"ISS"##"ICMS"
						oFisc1:Cell("CFOP"):SetValue(SF3->F3_CFO)
						oFisc1:Cell("ALIQ"):SetValue(SF3->F3_ALIQICM)
						oFisc1:Cell("BASEIMP1"):SetValue(SF3->F3_BASEICM)
						oFisc1:Cell("VALIMP1"):SetValue(SF3->F3_VALICM)
						oFisc1:Cell("ISENTAS1"):SetValue(SF3->F3_ISENICM)
						oFisc1:Cell("OUTRAS1"):SetValue(SF3->F3_OUTRICM)
						oFisc1:Cell("OBS1"):SetValue("")
						oFisc1:PrintLine()
						If !Empty(SF3->F3_ICMSRET)
							oReport:PrintText(STR0080+Transform(SF3->F3_ICMSRET,"@E 9,999,999,999.99"), oReport:Row() ,oFisc1:Cell("OBS1"):ColPos() ) //"RET  "
							oReport:SkipLine()
						Endif
						If !EMPTY(SF3->F3_ICMSCOM)
							oReport:PrintText(STR0081+Transform(SF3->F3_ICMSCOM,"@E 9,999,999,999.99"), oReport:Row() ,oFisc1:Cell("OBS1"):ColPos() ) //"Compl"
							oReport:SkipLine()
						Endif
						If !Empty(SF3->F3_BASEIPI) .Or. !Empty(SF3->F3_ISENIPI) .Or. !Empty(SF3->F3_OUTRIPI)
							oFisc1:Cell("IMP1"):SetValue(STR0086) //"IPI"
							oFisc1:Cell("CFOP"):SetValue("")
							oFisc1:Cell("ALIQ"):SetValue(Posicione("SD1",1,xFilial("SD1")+nDocAnt+cForAnt,"D1_IPI"))
							oFisc1:Cell("BASEIMP1"):SetValue(SF3->F3_BASEIPI)
							oFisc1:Cell("VALIMP1"):SetValue(SF3->F3_VALIPI)
							oFisc1:Cell("ISENTAS1"):SetValue(SF3->F3_ISENIPI)
							oFisc1:Cell("OUTRAS1"):SetValue(SF3->F3_OUTRIPI)
							oFisc1:Cell("OBS1"):SetValue("")
							oFisc1:PrintLine()
						Endif
						If ! Empty(SF3->F3_VALOBSE)
							oReport:PrintText(STR0082+Transform(SF3->F3_VALOBSE,"@E 9,999,999,999.99"), oReport:Row() ,oFisc1:Cell("OBS1"):ColPos() ) //"OBS. "
							oReport:SkipLine()
						Endif
					Endif

					dbSkip()
				EndDo
				If ! lFirst
					oFisc1:Finish()
					oReport:FatLine()
				EndIf

			EndIf

			//³ Imprime Dados dos Demais Impostos                            ³
			oReport:SkipLine()
			If !Empty(nValPis) .Or. !Empty(nValCof)
				oReport:PrintText(STR0059) //  "----------------------------------------------- DEMONSTRATIVO DOS DEMAIS IMPOSTOS ---------------------------------------------------"
				oFisc2:Init(.t.)
				If !Empty(nValPis)

					//³ Imprime Dados ref ao PIS                                     ³
					oFisc2:Cell("IMP2"):SetValue(STR0083) //"PIS APURACAO"
					oFisc2:Cell("BASEIMP2"):SetValue(nBasePis)
					oFisc2:Cell("VALIMP2"):SetValue(nValPis)
					oFisc2:PrintLine()
				Endif

				//³ Imprime Dados ref ao COFINS                                  ³
				If !Empty(nValCof)
					oFisc2:Cell("IMP2"):SetValue(STR0084) //"COFINS APURACAO"
					oFisc2:Cell("BASEIMP2"):SetValue(nBaseCof)
					oFisc2:Cell("VALIMP2"):SetValue(nValCof)
					oFisc2:PrintLine()
				Endif
				oFisc2:Finish()
				oReport:FatLine()
			EndIf
		Else
			If Len(aItens[1])>=0
				oReport:SkipLine()
				oReport:PrintText(STR0042) //"-----------------------------------------------   RELACAO DE IMPOSTOS POR ITEM   ---------------------------------------------------"
				oFisc3:Init(.t.)
				For nImp:=1 to Len(aItens)
					oFisc3:Cell("PRO3"):SetValue(aItens[nImp][1])
					oFisc3:Cell("DESC3"):SetValue(aItens[nImp][2])
					oFisc3:Cell("IMP3"):SetValue(aItens[nImp][3])
					oFisc3:Cell("ALI3"):SetValue(aItens[nImp][4])
					oFisc3:Cell("BASEIMP3"):SetValue(aItens[nImp][5])
					oFisc3:Cell("VALORIMP3"):SetValue(aItens[nImp][6])
					oFisc3:PrintLine()
				Next
				oFisc2:Finish()
				oReport:FatLine()
			Endif
		EndIf
		oReport:SkipLine(4)
	/*
		oReport:PrintText(STR0033)//"------------------------------------------------------------------- VISTOS ---------------------------------------------------------"
		oReport:PrintText("|                               |                                |                                  |                              |")
		oReport:PrintText(STR0034) //"| Recebimento  Fiscal           | Contabil/Custos                | Departamento Fiscal              | Administracao                |"
		oReport:ThinLine()
	*/
		dbSelectArea(cAliasSF1)
		If !lQuery
			dbSkip()
		EndIf
		oReport:IncMeter()
		oSection1:Finish()

		If !lAuto .And. (cAliasSF1)->(!Eof())
			oReport:EndPage()
		Endif
	EndDo

	//³ Devolve a condicao original dos arquivos		             ³
	RestArea(aAreaSF3)
	RestArea(aAreaSF1)
	RestArea(aAreaSE2)
	RestArea(aAreaSC7)

	If !lAuto .And. !lQuery
		dbSelectArea("SD1")
		RetIndex("SD1")
		If File(cArqIndSD1+ OrdBagExt())
			FErase(cArqIndSD1+ OrdBagExt() )
		EndIf
	EndIf

Return NIL

Static Function ImpRoda(oReport)

	oReport:PrintText(STR0033) //"------------------------------------------------------------------- VISTOS ---------------------------------------------------------"
	oReport:PrintText("|                               |                                |                                  |                              |")
	oReport:PrintText(STR0034) //"| Recebimento  Fiscal           | Contabil/Custos                | Departamento Fiscal              | Administracao                |"
	oReport:ThinLine()

Return Nil

// Imprime o Desdobramento de duplicatas
Static Function R170DupTR(oReport)

	Local oDupli := oReport:Section(1):Section(14)

	oDupli:Cell("E2PREFIXO"):SetValue(SE2->E2_PREFIXO)
	oDupli:Cell("E2NUM"):SetValue(SE2->E2_NUM)
	oDupli:Cell("E2PARCELA"):SetValue(SE2->E2_PARCELA)
	oDupli:Cell("E2VENCTO"):SetValue(SE2->E2_VENCTO)
	oDupli:Cell("E2VALOR"):SetValue(SE2->E2_VALOR)
	oDupli:Cell("E2NATUREZ"):SetValue(SE2->E2_NATUREZ)
	oDupli:PrintLine()

Return NIL

// Faz a somatoria dos impostos da nota. Retornando um array com todas as informacoes a serem impressas
Static Function R170IMPT(cAliasSF1)

	Local aArea    := {}
	Local aAreaSD1 := {}
	Local aImp     := {}
	Local aImpostos:= {}
	Local nImpos:= 0
	Local nBase := 0
	Local nY,cCampImp,cCampBas

	aArea:=GetArea()

	dbSelectArea("SD1")
	aAreaSD1:=GetArea()

	dbSetOrder(3)

	cSeek:=(xFilial("SD1")+Dtos((cAliasSF1)->F1_EMISSAO)+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)

	If dbSeek(cSeek)
		While cSeek==xFilial("SD1")+dtos(D1_EMISSAO)+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA
			if empty(TesImpInf(D1_TES))
				exit
			endif
			aImpostos:=TesImpInf(D1_TES)
			For nY:=1 to Len(aImpostos)
				cCampImp:="SD1->"+(aImpostos[nY][2])
				cCampBas:="SD1->"+(aImpostos[nY][7])
				nImpos+=&cCampImp
			Next
			nBase +=&cCampBas
			dbSkip()
		Enddo
	EndIf

	RestArea(aAreaSD1)
	RestArea(aArea)

	aAdd(aImp,nBase)
	aAdd(aImp,nImpos)

Return aImp

// Retorna array com lista de impostos por item
Static Function R170IMPI(cAliasSF1)

	Local aArea    := {}
	Local aAreaSD1 := {}
	Local aImp     := {}
	Local aRet     := {}
	Local nY

	aArea:=GetArea()

	dbSelectArea("SD1")
	aAreaSD1:=GetArea()

	dbSetOrder(3)

	cSeek:=(xFilial("SD1")+Dtos((cAliasSF1)->F1_EMISSAO)+(cAliasSF1)->F1_DOC+(cAliasSF1)->F1_SERIE+(cAliasSF1)->F1_FORNECE+(cAliasSF1)->F1_LOJA)

	If dbSeek(cSeek)
		While cSeek==xFilial("SD1")+dtos(D1_EMISSAO)+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA
			aImp:=TesImpInf(D1_TES)

			// Pega a descricao do produto
			dbSelectArea("SB1")
			aAreaSB1:=GetArea()
			dbSetOrder(1)
			dbSeek(xFilial("SB1")+SD1->D1_COD)
			cDescProd:=B1_DESC
			RestArea(aAreaSB1)

			dbSelectArea("SD1")
			For nY:=1 to Len(aImp)
				AADD(aRet,{SD1->D1_COD,cDescProd,aImp[nY][1],&("SD1->"+aImp[nY][10]),&("SD1->"+(aImp[nY][7])),&("SD1->"+(aImp[nY][2]))})
			Next
			dbSkip()
		Enddo
	EndIf

	If Len(aRet)<= 0
		AADD(aRet,{"" ,"" ,"" ,0 ,0 ,0})
	EndIf

	RestArea(aAreaSD1)
	RestArea(aArea)

Return aRet
