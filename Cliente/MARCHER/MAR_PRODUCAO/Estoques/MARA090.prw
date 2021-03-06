#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} MARA090
Gest?o de OP. Mostra as OPs e seus componentes e o Saldo em Estoque permitindo a impressao
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 30/12/2021
/*/
User Function MARA090()

	Local oGet1
	Local oGet2
	Local oGet3
	Local oGet4
	Local oGet5
	Local oGet6
	Local oGet7
	Local oGet8

	// Vari?veis Private da Fun??o
	Private cCliente      	:= 	Space(06)
	Private cLoja         	:=	Space(02)
	Private cProduto      	:= 	Space(30)
	Private cProducao     	:= 	Space(06)
	Private cPedido       	:= 	Space(06)
	Private cAtendimento  	:= 	Space(06)
	Private cNomeCliente  	:= 	Space(60)
	Private cNomeProduto  	:= 	Space(60)

	Private _dataIni      	:= 	DataValida(dDatabase-10,.F.)
	Private _dataFim	  	:= 	dDatabase

	Private nGet1	     	:= 	Space(06)
	Private nGet2	     	:= 	Space(03)
	Private nGet3        	:= 	Space(30)
	Private nGet4        	:= 	Space(06)
	Private nGet5        	:= 	Space(06)
	Private nGet6       	:= 	Space(06)
	Private nVias        	:= 	1

	// Di?logo Principal
	Private oDlgOP
	Private oDlg
	Private oList

	// Menu Radio para escolher tipos de OP
	Private oRadio
	Private aOptions := {"Previstas","Firmes","Ambas"}
	Private nRadio   :=  3

	Private _aEmpenho:=	{}

	Static aSaldo 	 := {}

	DEFINE MSDIALOG oDlgOP TITLE "Gest?o de Ordens de Produ??o" FROM C(178),C(181) TO C(380),C(600) PIXEL

	// Solicita os Par?metros para impress?o das Ordens de Produ??o
	@ C(010),C(005) Say "CLIENTE:        " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlgOP
	@ C(020),C(005) Say "PRODUTO:        " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlgOP
	@ C(030),C(005) Say "N? O.PRODU??O:  " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlgOP
	@ C(040),C(005) Say "N? PEDIDO VENDA:" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlgOP
	@ C(050),C(005) Say "Da Entrega Prevista" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlgOP
	@ C(060),C(005) Say "        at?     " Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlgOP
	@ C(070),C(005) Say "N? Vias  Requisi??o" Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlgOP	//	Pesagem
	@ C(010),C(105) Say cNomeCliente       Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlgOP
	@ C(020),C(105) Say cNomeProduto       Size C(100),C(020) COLOR CLR_BLACK PIXEL OF oDlgOP

	@ C(009),C(045) MsGet oGet1 Var cCliente     Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgOP F3("SA1")
	@ C(009),C(075) MsGet oGet2 Var cLoja        Size C(015),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgOP VALID( TrazNomeCliente(cCliente, cLoja) )
	@ C(019),C(045) MsGet oGet3 Var cProduto     Size C(055),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgOP F3("SB1") VALID( TrazNomeProd(cProduto) )
	@ C(029),C(045) MsGet oGet4 Var cProducao    Size C(040),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgOP F3("SC2")
	@ C(039),C(045) MsGet oGet5 Var cPedido      Size C(025),C(009) COLOR CLR_BLACK Picture "@!" PIXEL OF oDlgOP F3("SC5")
	@ C(049),C(045) MsGet oGet6 Var _dataIni     Size C(035),C(009) COLOR CLR_BLACK Picture "@D" PIXEL OF oDlgOP
	@ C(059),C(045) MsGet oGet7 Var _dataFim     Size C(035),C(009) COLOR CLR_BLACK Picture "@D" PIXEL OF oDlgOP
	@ C(069),C(045) MsGet oGet8 Var nVias        Size C(035),C(009) COLOR CLR_BLACK Picture "99" PIXEL OF oDlgOP
	@ C(045),C(090) Say "TIPOS DE OP's "         Size C(050),C(020) COLOR CLR_BLACK PIXEL OF oDlgOP
	oRadio:= tRadMenu():New(59,160,aOptions,{|u|if(PCount()>0,nRadio:=u,nRadio)},oDlgOP,,,,,,,,100,20,,,,.T.)

	@ 110,010 BUTTON "Avan?ar" 	Size 50,12 ACTION ( MsgRun( "Aguarde...... Selecionando Ordens de Produ??o ","Aguarde",;
														{|| ImpProducao( cCliente, cLoja, cProduto, cProducao, cPedido, cAtendimento)} )) Of oDlgOP PIXEL

	@ 110,100 BUTTON "  Sair    "  Size 50,12 ACTION ( oDlgOP:End() )  Of oDlgOP PIXEL

	ACTIVATE MSDIALOG oDlgOP CENTERED

Return


/*/{Protheus.doc} ImpProducao
Mostrar uma tela com as op??es de Impress?o e Consulta
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 30/12/2021
@param cCliente, character, C?digo do Cliente
@param cLoja, character, Loja do cliente
@param cProduto, character, C?digo do produto
@param cProducao, character, Ordem de Produ??o
@param cPedido, character, Numero do PV
@param cAtendimento, character, Atendimento
/*/
Static Function ImpProducao( cCliente, cLoja, cProduto, cProducao, cPedido, cAtendimento )

	Private oOk      := LoadBitmap( GetResources(), "LBOK" )
	Private oNo      := LoadBitmap( GetResources(), "LBNO" )
	Private aLista   := {}

	Private cSql   	:= ""
	Private nLista 	:= 0

	Private aEstDisp := {}		//	ARRAY CONTEM PRODUTO X QTD.ESTOQUE X QTD.OP X QTD.EMPENHO 
								//	ARRAY RESPONSAVEL POR IDENTIFICAR SE OUTRA OP ESTA CONSUMINDO SALDO DE OUTRA PRODUTO\OP
								// 	ARRAY COM QUANT DISPONIVEL EM ESTOQUE E QTD.JA UTILIZADA EM X OPs 

	A90SetKey( .T. )

	DEFINE MSDIALOG oDlg TITLE "Gest?o de Ordens de Produ??o" FROM 180,210 TO 700,1320 PIXEL

	oFontP	    := TFont():New( "Arial",0,14,,.F.,0,,700,.F.,.F.,,,,,, )
	cParametros := 'Par?metros da Consulta: '
	cParametros += IIF(!Empty(cCliente), 'Cliente: '+cCliente+'  Loja: '+cLoja, '')
	cParametros += IIF(!Empty(cProduto), 'Produto: '+cProduto,'')
	cParametros += IIF(!Empty(cProducao), 'Num.OP:  '+cProducao, '')
	cParametros += IIF(!Empty(cPedido), 'PV: '+cPedido, '')
	cParametros += 'Da Entrega Prevista: '+DtoC(_dataIni)+' At?: '+DtoC(_dataFim)+'  '
	cParametros += 'Tipo OP: '+IIF(nRadio==1, 'Prevista', (IIF(nRadio==2,'Firmes','Ambas')) )

	cPesq		:= Space(TamSx3('D4_OP')[01])
	oSayParam   := TSay():New( 002, 006,{|| cParametros },oDlg,,oFontP,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,480,008)

	//oSayParam   := TSay():New( 002, 0413,{|| 'Pesq.NumOP:' },oDlg,,oFontP,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,080,008)
	//oGetPesq    := TGet():New( 001, 0450,{|u| If(PCount()>0,cPesq :=u,cPesq)},oDlg,050,004,'',,CLR_BLACK,CLR_WHITE,oFontP,,,.T.,"",,{|| PesqNumOP(cPesq, aLista, oList)},.F.,.F.,,.F.,.F.,"SC2","cPesq",,)
	oSayHelp    := TSay():New( 002, 0520,{|| 'F11 - Help' },oDlg,,oFontP,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,080,008)


	@ 12,05 LISTBOX oList  FIELDS HEADER "" ,"N? O.Produ??o", "Produto", "Descri??o Produto",;
										"Emissao","Entrega Prevista","Entrega Real","Quantidade Original","Saldo a Entregar","Status OP","Tipo OP","Recurso";
	PIXEL SIZE 550,230 OF oDlg ON DblClick(aLista[oList:nAt,1] := !aLista[oList:nAt,1],oList:Refresh())

	oList:bHeaderClick 	:= 	{|| FMarkAll(aLista), oList:Refresh() }

	SQLxListBox(oDlg)

	nCol := 030
	@ 245,nCol BUTTON "Lista Faltas"        Size 40,12 ACTION ( MsgRun( "Aguarde... Imprimindo Lista de Faltas",	"Lista Faltas", {|| NewListFalta(_aEmpenho,aLista)}) )	Of oDlg PIXEL
	nCol += 050
	@ 245,nCol BUTTON "Imprime OP "        	Size 40,12 ACTION ( MsgRun( "Aguarde... Imprimindo Ordem de Produ??o",	"OP",  			{|| I_PRODUCAO(aLista)}) )         	Of oDlg PIXEL
	nCol += 050
	@ 245,nCol BUTTON "Imprime Requisi??o"	Size 50,12 ACTION ( MsgRun( "Aguarde... Imprimindo Requisi??o",			"Requisi??o",  	{|| I_REQUISICAO(aLista)}) )       	Of oDlg PIXEL		// Pesagem
	nCol += 060
	@ 245,nCol BUTTON "Imprime Consulta"   	Size 50,12 ACTION ( MsgRun( "Aguarde... Imprimindo Consulta",			"Consulta",  	{|| I_Consulta(aLista)}) )			Of oDlg PIXEL
	nCol += 060
	@ 245,nCol BUTTON "Visualizar OP"	  	Size 50,12 ACTION ( ViewSC2(aLista[oList:nAt, 3 ] ) ) Of oDlg PIXEL
	nCol += 060
	@ 245,nCol BUTTON "Estrutura X Saldo"  	Size 50,12 ACTION ( MsgRun( "Aguarde... Consultando saldos da Estrutura",			"Consulta",  	{|| ChkEstrXQtd('BTN',Nil,Nil), EstrutXSaldo() }) ) 	Of oDlg PIXEL
	nCol += 060
	@ 245,nCol BUTTON "Aglutinar OP's"		Size 40,12 ACTION ( U_MARA090A( aLista ) /*Fun??o em MARA090A.prw*/, oDlg:End() ) Of oDlg PIXEL
	nCol += 050
	@ 245,nCol BUTTON "Alt. Qtde Produzida"	Size 50,12 ACTION ( AltQtde( oList:nAt, oDlg ) ) Of oDlg PIXEL
	//nCol += 050
	//@ 245,480  BUTTON "help"          		Size 30,12 ACTION ( HelpPrw() )	Of oDlg PIXEL
	nCol += 065
	@ 245,nCol BUTTON "Voltar"         		Size 30,12 ACTION ( oDlg:End() ) Of oDlg PIXEL

	oList:SetFocus()
	ACTIVATE MSDIALOG oDlg CENTERED     

	IIF(Select('T_PRODUCAO')!=0, T_PRODUCAO->(DbCloseArea()), )

	A90SetKey( .F. )
	
Return(.T.)


/*/{Protheus.doc} A90SetKey
Mostra ou n?o as teclas de atalho
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 18/01/2022
@param lMostra, logical, Mostra ou n?o
/*/
Static Function A90SetKey( lMostra )

	Default lMostra := .F.

	If lMostra
		SetKey( VK_F5,  {|| MsgRun( "Aguarde...... Selecionando Ordens de Produ??o ","Aguarde", {|| SQLxListBox(oDlg) } ) })
		SetKey( VK_F11, {|| HelpPrw() })
	Else
		SetKey( VK_F5,  NIL )
		SetKey( VK_F11, NIL )
	EndIf

Return


/*/{Protheus.doc} SQLxListBox
Consulta e carrega os dados no array para serem apresentados na tela
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 30/12/2021
@param oDlg, object, Objeto na tela
/*/
Static Function SQLxListBox(oDlg)

	Local cFilSB1    := FWFilial("SB1")
	Local cFilSB2    := FWFilial("SB2")
	Local cAliasEmp  := ""
	Local cSql       := ""
	Local _nOp       := 0
	Local aSetField  := {}
	Local aTmD4Data  := FWSX3Util():GetFieldStruct("D4_DATA")
	Local aTmD4Quant := FWSX3Util():GetFieldStruct("D4_QUANT")
	Local aTmC2DtPri := FWSX3Util():GetFieldStruct("C2_DATPRI")
	Local aTmC2DtFim := FWSX3Util():GetFieldStruct("C2_DATPRF")
	Local aTmC2DtEmi := FWSX3Util():GetFieldStruct("C2_EMISSAO")
	
	AADD(aSetField,{aTmD4Data[1] ,aTmD4Data[2] ,aTmD4Data[3] ,aTmD4Data[4] })
	AADD(aSetField,{aTmD4Quant[1],aTmD4Quant[2],aTmD4Quant[3],aTmD4Quant[4]})
	AADD(aSetField,{aTmC2DtPri[1],aTmC2DtPri[2],aTmC2DtPri[3],aTmC2DtPri[4]})
	AADD(aSetField,{aTmC2DtFim[1],aTmC2DtFim[2],aTmC2DtFim[3],aTmC2DtFim[4]})
	AADD(aSetField,{aTmC2DtEmi[1],aTmC2DtEmi[2],aTmC2DtEmi[3],aTmC2DtEmi[4]})

	IIF(Select('T_PRODUCAO')!=0, T_PRODUCAO->(DbCloseArea()), )

	// Pesquisa as Ordens de Produ??o conforme filtro informado
	cSql += "SELECT SC2.C2_FILIAL , SC2.C2_NUM, SC2.C2_ITEM, SC2.C2_PRODUTO, SC2.C2_LOCAL, SC2.C2_QUANT, SC2.C2_QUJE, SC2.C2_UM, " +Chr(13)
	cSql +=      "SB1.B1_DESC, SB1.B1_ESPECIF, SC2.C2_DATPRI, SC2.C2_DATPRF, SC2.C2_EMISSAO, SC2.C2_CC, SC2.C2_STATUS, " +Chr(13)
	cSql +=      "SC2.C2_SEQUEN, SC2.C2_ITEMGRD, SC2.C2_REVISAO, SC2.C2_ROTEIRO, SC2.C2_OBS, SC2.C2_PEDIDO, SC2.C2_TPOP, SC2.C2_RECURSO, SC2.C2_DATRF, " +Chr(13)
	cSql +=      "SC5.C5_CLIENTE, SC5.C5_LOJACLI, SC5.C5_VEND1, SA1.A1_NOME, SA1.A1_CGC, SA1.A1_EST, SA1.A1_MUN, C5_TRANSP, A4_NOME, A3_NOME " +Chr(13)
	cSql += "FROM " + RetSqlName("SC2") + " SC2 " +Chr(13)
	cSql += "INNER JOIN " + RetSqlName("SB1") + " SB1 ON ( SB1.B1_FILIAL =  '"+xFilial("SB1")+"' AND SC2.C2_PRODUTO = SB1.B1_COD AND SB1.D_E_L_E_T_ = ' ' ) " +Chr(13)
	cSql += "LEFT OUTER JOIN " + RetSqlName("SC5") + " SC5 ON ( SC5.C5_FILIAL =  SC2.C2_FILIAL AND SC5.C5_NUM = SC2.C2_PEDIDO  AND SC5.D_E_L_E_T_ = ' ' "
	If !Empty(cCliente) // Filtra pelo Cliente
		cSql += "AND SC5.C5_CLIENTE = '" + Alltrim(cCliente) + "' AND SC5.C5_LOJACLI = '" + Alltrim(cLoja) + "' "
	Endif
	cSql += " ) "  + chr(13)
	cSql += "LEFT OUTER JOIN " + RetSqlName("SA1") + " SA1 ON ( SA1.A1_FILIAL =  '"+xFilial("SA1")+"' AND SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA	= SC5.C5_LOJACLI AND SA1.D_E_L_E_T_ = ' ' ) " +Chr(13)
	cSql += "LEFT OUTER JOIN " + RetSqlName("SA4") + " SA4 ON ( SA4.A4_FILIAL = '"+xFilial("SA4")+"' AND SC5.C5_TRANSP = SA4.A4_COD AND SA4.D_E_L_E_T_ = ' ' ) " +Chr(13)
	cSql += "LEFT OUTER JOIN " + RetSqlName("SA3") + " SA3 ON ( SA3.A3_FILIAL = '"+xFilial("SA3")+"' AND SC5.C5_VEND1 = SA3.A3_COD AND SA3.D_E_L_E_T_ = ' ' ) " +Chr(13)
	cSql += "WHERE SC2.C2_FILIAL = '"+xFilial("SC2")+"' " +Chr(13)
	cSql += "AND SC2.C2_DATPRF BETWEEN '"+DTOS(_dataIni)+"' AND '"+DTOS(_dataFim)+"' " +Chr(13)
	cSql += "AND SC2.D_E_L_E_T_  =  ' ' " +Chr(13)

	If nRadio == 1
		cSql += "AND  SC2.C2_TPOP = 'P' " + chr(13)
	ElseIf nRadio == 2
		cSql += "AND  SC2.C2_TPOP = 'F' " + chr(13)
	EndIf

	If !Empty(cProducao)	// Filtra pela Ordem de Produ??o
		cSql += "AND SC2.C2_NUM = '" + Alltrim(cProducao) + "' " + chr(13)
	EndIf

	If !Empty(cPedido)		// Filtra pelo Pedido 
		cSql += "AND SC2.C2_PEDIDO = '" + Alltrim(cPedido) + "' " + chr(13)
	EndIf

	If !Empty(cProduto)		// Filtra pelo Produto
		cSql += "AND SC2.C2_PRODUTO = '" + Alltrim(cProduto) + "' " + chr(13)
	EndIf

	cSql += "ORDER BY SC2.C2_NUM, SC2.C2_DATPRI  " +Chr(13)

	//Memowrit( "C:\temp\mara090.sql", cSql )
	MPSysOpenQuery(cSql,"T_PRODUCAO",aSetField)

	// Carrega o Array aLista
	DbSelectArea("T_PRODUCAO")
	T_PRODUCAO->(DbGoTop())

	DbSelectArea("SB1")
	DbSetOrder(1)

	DbSelectArea("SB2")
	DbSetOrder(1)

	While T_PRODUCAO->(!EOF())
		
		xPedidoPv    := T_PRODUCAO->C2_PEDIDO								// Carrega o n? do Pedido de Venda
		xProducao    := T_PRODUCAO->(C2_NUM+C2_ITEM+C2_SEQUEN+C2_ITEMGRD)	// Carrega o N? da Ordem de Produ??o
		
		// Carrega os dados do Cliente
		xCnpj      := T_PRODUCAO->A1_CGC
		xCliente   := T_PRODUCAO->A1_NOME
		xMunicipio := T_PRODUCAO->A1_MUN
		xEstado    := T_PRODUCAO->A1_EST
		
		// Carrega a Qauntidade solicitada no Pedido de Venda
		xQuantidade  := T_PRODUCAO->C2_QUANT
		xQuantJaEnt  := T_PRODUCAO->C2_QUJE
		
		// Carre o c?digo e a descri??o do produto
		xProduto     := T_PRODUCAO->C2_PRODUTO
		xNomeProduto := Alltrim(T_PRODUCAO->B1_DESC)//+ " " + Alltrim(T_PRODUCAO->B1_ESPECIF)// RETIRADO B1_ESPECIF (SOLICITACAO ANDREIA - PCP)
		
		xTransp     := T_PRODUCAO->C5_TRANSP
		xNomeTransp := T_PRODUCAO->A4_NOME

		xCodVend  := T_PRODUCAO->C5_VEND1
		xVendedor := T_PRODUCAO->A3_NOME

		// Pesquisa a Nota Fiscal e data de Faturamento do Pedido de Venda
		cSql := ""
		cSql := "SELECT C6_NOTA  , "
		cSql += "       C6_DATFAT  "
		cSql += "  FROM " + RetSqlName("SC6")
		cSql += " WHERE C6_NUMOP = '" + Alltrim(T_PRODUCAO->C2_NUM) + "'"
		
		cSql := ChangeQuery( cSql )
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_NOTA", .T., .T. )
		
		xNotaFiscal := ""
		xDataFatu   := ""
		If .NOT. T_NOTA->( EOF() )
			xNotaFiscal := T_NOTA->C6_NOTA
			xDataFatu   := T_NOTA->C6_DATFAT
		EndIf

		T_NOTA->( dbCloseArea() )
				
		// Pesquisa os componentes do produto a ser produzido
		cSql := ""
		cSql := "SELECT A.G1_FILIAL, "
		cSql += "       A.G1_COD   , "
		cSql += "       A.G1_COMP  , "
		cSql += "       A.G1_QUANT , "
		cSql += "       B.B1_DESC  , "
		cSql += "       B.B1_ESPECIF"
		cSql += "  FROM " + RetSqlName("SG1") + " A, "
		cSql += "       " + RetSqlName("SB1") + " B  "
		cSql += " WHERE A.G1_COD    = '" + Alltrim(T_PRODUCAO->C2_PRODUTO) + "'"
		cSql += "   AND A.G1_FILIAL = '" + Alltrim(T_PRODUCAO->C2_FILIAL)  + "'"
		cSql += "   AND A.G1_COMP   = B.B1_COD "
		
		cSql := ChangeQuery( cSql )
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_COMPO", .T., .T. )
		
		xProFicha := ""
		xNomFicha := ""
		xQtdFicha := 0

		If .NOT. T_COMPO->( EOF())
			xProFicha := T_COMPO->G1_COMP
			xNomFicha := Alltrim(T_COMPO->B1_DESC)
			xQtdFicha := (T_PRODUCAO->C2_QUANT * T_COMPO->G1_QUANT)
		EndIf

		T_COMPO->( dbCloseArea() )
		
		// Prepara o documento do cliente
		If Len(Alltrim(xCnpj)) == 14
			xCnpj := Substr(xCnpj,01,02) + "." + Substr(xCnpj,03,03) + "." + Substr(xCnpj,06,03) + "/" + Substr(xCnpj,09,04) + "-" + Substr(xCnpj,13,02)
		Else
			xCnpj := Substr(xCnpj,01,03) + "." + Substr(xCnpj,04,03) + "." + Substr(xCnpj,07,03) + "-" + Substr(xCnpj,10,02)
		Endif
		
		Do Case
			Case T_PRODUCAO->C2_QUANT - T_PRODUCAO->C2_QUJE <= 0
				cStatusOP	:=	'ENCERRADA TOTAL'
			Case( T_PRODUCAO->C2_QUANT - T_PRODUCAO->C2_QUJE > 0 .And. .NOT. Empty(T_PRODUCAO->C2_DATRF) )
				cStatusOP	:=	'ENCERRADA PARCIALMENTE'		
			OtherWise
				cStatusOP	:=	'ABERTA'
		EndCase
		
		Do Case
			Case AllTrim(T_PRODUCAO->C2_TPOP) == 'P'
				cTipoOP	:=	'Prevista' 
			Case AllTrim(T_PRODUCAO->C2_TPOP) == 'F'
				cTipoOP	:=	'Firme'
			OtherWise
				cTipoOP	:=	''
		EndCase
		

		// Carrega o Array aLista com o conte?do da pesquisa
		Aadd(aLista, {	.F.     				,; 	// 01 - Marca??o
						xPedidoPV             	,; 	// 02 - N? do Pedido de Venda
						xProducao             	,; 	// 03 - N? da Ordem de Produ??o
						xCnpj	              	,; 	// 04 - CNPJ/CPF do Cliente
						LEFT(xCliente,30)    	,; 	// 05 - Nome do Cliente
						xQuantidade           	,; 	// 06 - Quantidade da Ordem de Produ??o
						xQuantJaEnt           	,; 	// 07 - Quantidade da Ordem de Produ??o
						xProduto              	,; 	// 08 - C?digo do Produto a ser produzido
						xNomeProduto          	,; 	// 09 - Nome do Produto
						xNotaFiscal           	,; 	// 10 - N? da Nota Fiscal
						xDataFatu             	,; 	// 11 - Data do Faturamento
						xTransp               	,; 	// 12 - C?digo da Transportadora
						xNomeTransp           	,; 	// 13 - Nome da Transportadora
						xMunicipio            	,; 	// 14 - Nome da Cidade do Cliente
						xEstado               	,; 	// 15 - Estado da Cidade do Cliente
						xCodVend              	,; 	// 16 - C?digo do Vendedor
						xVendedor             	,; 	// 17 - Nome do Vendedor
						T_PRODUCAO->C2_DATPRI 	,; 	// 18 - Data Inicial de Entrega
						T_PRODUCAO->C2_DATPRF 	,; 	// 19 - Data Final de Entrega
						T_PRODUCAO->C2_EMISSAO	,; 	// 20 - Data de Emiss?o da Ordem de Produ??o
						""		            	,; 	// 21 - DISPONIVEL PARA USO
						xProFicha             	,; 	// 22 - C?digo do Produto da Ficha T?cnica
						xNomFicha             	,; 	// 23 - Nome do Produto da Ficha T?cnica
						xQtdFicha             	,; 	// 24 - Quantidade a ser utilizada na produ??o
						T_PRODUCAO->C5_CLIENTE	,; 	// 25 - C?digo do Cliente
						T_PRODUCAO->C5_LOJACLI	,; 	// 26 - Loja do Cliente
						""                    	,; 	// 27 - Mensagem
						T_PRODUCAO->C2_RECURSO	,; 	// 28 - Recurso
						cStatusOP				,; 	// 29 - Status da OP // U=Suspensa;S=Sacramentada;N=Normal	[ T_PRODUCAO->C2_STATUS ]
						xQuantidade-xQuantJaEnt ,;	// 30 - Saldo a entregar da OP
						cTipoOP 				,;	// 31-  Tipo da OP - P=Prevista ou F=Firme 	[ T_PRODUCAO->C2_TPOP ]
						T_PRODUCAO->C2_REVISAO	,; 	// 32 - Revis?o da OP
						T_PRODUCAO->C2_ROTEIRO	,; 	// 33 - C?digo do Roteiro da OP
						xQuantidade-xQuantJaEnt ,;	// 34 - Saldo a entregar 	
						''	})						// 35 - Flag OP HAPTA A PRODUZIR(COM ESTOQUE) \ FALTA MATERIAL
		
		
		// Carrega array com os EMPENHOS da OP
		_cEmp := " SELECT D4_COD, D4_LOCAL, D4_OP, D4_DATA, D4_QUANT, 0 AS 'D4_RESERV', 0 AS 'D4_RESPED' "
		_cEmp += " FROM "+RetSqlname("SD4") + " "
		_cEmp += " WHERE D4_FILIAL = '"+xFilial("SD4")+"' "
		_cEmp += " AND D4_QUANT > 0 "
		_cEmp += " AND D4_OP = '"+xProducao+"' "
		_cEmp += " AND D_E_L_E_T_= ' ' 	"
		_cEmp += " ORDER BY D4_FILIAL, D4_COD, D4_DATA "

		cAliasEmp := MPSysOpenQuery(_cEmp,,aSetField )

		_aEmpenho := {}
		DbSelectArea(cAliasEmp)
		While !Eof()
				//				   		   [01]			    	[02]				   [03]				   [04] 		   		 [05]			  		[06]		[07]	        		[08]   [09]FLAG
			Aadd(_aEmpenho, { (cAliasEmp)->D4_COD, (cAliasEmp)->D4_LOCAL, (cAliasEmp)->D4_OP, (cAliasEmp)->D4_DATA, (cAliasEmp)->D4_QUANT, (cAliasEmp)->D4_RESERV,  (cAliasEmp)->D4_RESPED, 0   ,  '' 		} )

			If SB2->( DbSeek( cFilSB2 + (cAliasEmp)->D4_COD + (cAliasEmp)->D4_LOCAL, .F.) )

				nX := Len(_aEmpenho)
				
				//?????????????????????????????????????????????????Ŀ
				//?  _aEmpenho[nX][06] == QTD. DO EMPENHO       	?
				//?  _aEmpenho[nX][07] == QTD. PREVISTA P/ENTRAR	?
				//?  _aEmpenho[nX][08] == QTD.FICOU NEGATIVA    	?
				//???????????????????????????????????????????????????
				
				If (SB2->B2_QATU - (cAliasEmp)->D4_QUANT) >= 0
					// SE EU RESERVAR O SALDO ELE NAO FICA NEGATIVO
					_aEmpenho[nX][06] := (cAliasEmp)->D4_QUANT
				Else
					// TENTO RESERVAR AGORA O SALDO DE PEDIDOS DE COMPRA
					If (SB2->B2_SALPEDI - (cAliasEmp)->D4_QUANT) >= 0
						// SE EU RESERVAR O SALDO ELE NAO FICA NEGATIVO
						_aEmpenho[nX][07] := (cAliasEmp)->D4_QUANT
					Else
						//SE FICOU NEGATIVO, PRECISA COMPRAR... ALIMENTO A POSI??O 8 DO ARRAY
						_aEmpenho[nX][08] += (cAliasEmp)->D4_QUANT
					EndIf
				EndIf

			EndIf

			DbSelectArea(cAliasEmp)
			DbSkip()
		EndDo
		(cAliasEmp)->(DbCloseArea())
		
		T_PRODUCAO->( DbSkip() )
		
	EndDo
	T_PRODUCAO->(DbCloseArea())

	// Verifica se o Array est? carregado
	If Len(aLista) == 0
		MsgAlert("Aten??o !!" + chr(13) + chr(13) + "N?o existem dados a serem visualizados para este filtro.")
		Return()
	EndIf

	// Atualiza Array aLista com a libera??o ou n?o para a produ??o
	For _nOp := 1 To Len(aLista)

		_cProdOp :=	aLista[_nOp][08]
		_cOpx 	 :=	aLista[_nOp][03]
		
		_cMsg    :=	""
		_lImp    :=	.T.
		_lTemEmp :=	.F.
		
		//					   [01]			[02]			[03]		[04] 		   [05]			  [06]			  [07]	     [08]  [09]FLAG
		//aAdd(_aEmpenho, { EMP->D4_COD, EMP->D4_LOCAL, EMP->D4_OP, EMP->D4_DATA, EMP->D4_QUANT, EMP->D4_RESERV, EMP->D4_RESPED,  0   , '' })
		
		Do While .T.
			// nPos := Ascan(_aEmpenho, {|X| AllTrim(X[01]) == AllTrim(_cProdOp) .And. AllTrim(X[3]) == AllTrim(_cOpx) .And. Empty(X[09]) })
			nPos := Ascan(_aEmpenho, {|X| AllTrim(X[3]) == AllTrim(_cOpx) .And. Empty(X[09]) })
			If nPos > 0

				_lTemEmp 			:= 	.T.  	//	MARCA QUE TEM EMPENHOS, PARA PODER SABER SE PODE IMPRIMIR
				_aEmpenho[nPos][09]	:=	'X'		//	FLAG QUE JA PROCESSOU
				
				If _aEmpenho[nPos][06] == 0		//	(NAO TEM SALDO)(SB2->B2_QATU - EMP->D4_QUANT) >= 0   | _aEmpenho[nX][06] := EMP->D4_QUANT
					_lImp := .F.
					If SB1->( DbSeek( cFilSB1 + _aEmpenho[nPos][01] ) )
						_cMsg += AllTrim( SB1->B1_DESC )
					EndIf

					If _aEmpenho[nPos][07] > 0	 //	(SB2->B2_SALPEDI - EMP->D4_QUANT) >= 0 | _aEmpenho[nX][07] := EMP->D4_QUANT
						_cMsg += "(*)"
					EndIf
		
					_cMsg += "|"            
				EndIf			
				
			Else
				Exit
			EndIf
			
		EndDo
		
		// SE aLista[_nOp][01] == .T.                           // PODE CHECAR SA7 A7_CLIENTE+LOJA+PRODUTO
		// EXPLODE ESTRUTURA                                    // SE TEM EMPENHO NAO CONSIDERAR
		// VERIFICA QTD ESTOQUE                                 // TEM Q SER PRODUTO DE CLIENTE
		// (C2_QUANT * %G1_QUANT) >= SALDOSB2() - SE B2_QEMP > 0 NAO REALIZAR CALCULO \ PRODUTO FANTASMA
		aLista[_nOp][01] := (_lImp .And. _lTemEmp)						//	[01] - Flag IDENTIFICA QUE OP TEM SALDO E PODE SER PRODUZIDA
		aLista[_nOp][27] := _cMsg										//	[27] - MENSAGEM

		// VERIFICAR ChkEstrXQtd() SOMENTE OP PREVISTAS (SOLICITACAO ANDREIA - PCP)
		aLista[_nOp][01] := IIF(Left(cTipoOP,01) == 'F', .F., .T.)
		
		//????????????????????????????????????????????Ŀ
		//?  EXPLODE ESTRUTURA \ VERIFICA QUANTIDADES  ?
		//??????????????????????????????????????????????
		If aLista[_nOp][01]		//	SOMENTE PREVISTA
			aLista[_nOp][01] := ChkEstrXQtd('', aLista, _nOp)
		EndIf

		aLista[_nOp][35] := IIF(aLista[_nOp][01],'PRODUZIR','FALTAS')	//	[35] - Flag OP APTA A PRODUZIR(COM ESTOQUE) \ FALTA MATERIAL

	Next
	
	aSort(aLista,,, {|X, Y| X[03] < Y[03] })
	oList:SetArray( aLista )
	oList:bLine := {||{IIF(aLista[oList:nAt,01],oOk,oNo),;		// 01 - Marca??o
							AllTrim(aLista[oList:nAt,03]),;		// 03 - N? da Ordem de Produ??o
							AllTrim(aLista[oList:nAt,08]),;		// 08 - C?digo do Produto a ser produzido
							AllTrim(aLista[oList:nAt,09]),;		// 09 - Nome do Produto
							aLista[oList:nAt,20],;				// 20 - Data de Emiss?o da Ordem de Produ??o
							aLista[oList:nAt,18],;				// 18 - Data Inicial de Entrega
							aLista[oList:nAt,19],;				// 19 - Data Final de Entrega
							aLista[oList:nAt,06],;				// 06 - Quantidade da Ordem de Produ??o
							aLista[oList:nAt,34],;				// 34 - Saldo a entregar
							aLista[oList:nAt,29],;				// 29 - Status OP
							aLista[oList:nAt,31],;				// 31 - Tipo da OP - P=Prevista ou F=Firme 
							aLista[oList:nAt,28]}}				// 28 - Recurso

	oList:nAt := 1
	oList:Refresh()
	oDlg:Refresh()

Return



/*/{Protheus.doc} TrazNomeProd
Fun??o que tr?s a descri??o do produto selecionado
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 30/12/2021
@param cProduto, character, C?digo do Produto
/*/
Static Function TrazNomeProd( cProduto )

	Local cSql := ""
	
	cNomeProduto := ""

	If Empty(cProduto)
		Return .T.
	Endif

	cSql := "SELECT B1_DESC "
	cSql += "  FROM " + RetSqlName("SB1")
	cSql += " WHERE B1_COD = '" + Alltrim(cProduto) + "' AND D_E_L_E_T_ = ' ' "

	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTO", .T., .T. )

	If !T_PRODUTO->( EOF() )
		cNomeProduto := Alltrim(T_PRODUTO->B1_DESC)
	Endif
	T_PRODUTO->( dbCloseArea() )

Return .T.

/*/{Protheus.doc} TrazNomeCliente
Fun??o que tr?s a descri??o do cliente selecionado
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 30/12/2021
@param cCliente, character, C?digo do Cliente
@param cLoja, character, Loja do Cliente
/*/
Static Function TrazNomeCliente( cCliente, cLoja )

	Local cSql := ""

	If Empty(cCliente) .and. Empty(cLoja)
		cCliente     := Space(06)
		cLoja        := Space(03)
		cNomeCliente := ""
		Return .T.
	Endif

	cSql := "SELECT A1_COD , "
	cSql += "       A1_LOJA, "
	cSql += "       A1_NOME  "
	cSql += "  FROM " + RetSqlName("SA1")
	cSql += " WHERE A1_COD  = '" + Alltrim(cCliente) + "'"
	cSql += "   AND A1_LOJA = '" + Alltrim(cLoja)    + "'"
	cSql += "   AND D_E_L_E_T_ = '' "

	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

	If !T_CLIENTE->( EOF() )
		cCliente     := T_CLIENTE->A1_COD
		cLoja        := T_CLIENTE->A1_LOJA
		cNomeCliente := Alltrim(T_CLIENTE->A1_NOME)
	Else
		cCliente     := Space(06)
		cLoja        := Space(03)
		cNomeCliente := ""
	Endif

	T_CLIENTE->( dbCloseArea() )

Return .T.


/*/{Protheus.doc} ListFalta
Func??o que gera a impress?o da lista de faltas de MP
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 30/12/2021
@param _aEmpenho, array, Empenhos
@param aLista, array, Listagem
/*/
Static Function ListFalta(_aEmpenho,aLista)

	Local _n           := 0
	Local nX           := 0
	Local lTela		   := .F.
	Local lSelec	   := .F.
	
	Private _nLin      := 0
	Private aObs       := {}
	Private cObs       := ""
	Private _nQuant    := 0
	Private _nTot      := 0
	Private _nIpi      := 0
	Private _nTamLin   := 80
	Private _nLimVert  := 2300
	Private _nVia      := 1
	Private _nPagina   := 1
	Private _nIniLin   := 0
	Private _nCotDia   := 1
	Private _dCotDia   := DtoS( dDataBase )
	Private _cPrevisao := ""
	Private _cPrazoPag := ""
	Private _nMoeda    := 1
	Private oPrint, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont30

	// Cria o objeto de impressao
	oPrint := TmsPrinter():New()

	// Orienta??o da p?gina
	oPrint:SetLandScape() // Para Paisagem
	//oPrint:SetPortrait()    // Para Retrato

	// Tamanho da p?gina na impress?o
	//oPrint:SetPaperSize(8) // A3
	//oPrint:SetPaperSize(1) // Carta
	oPrint:SetPaperSize(9)   // A4

	// Cria os objetos de fontes que serao utilizadas na impressao do relatorio
	oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
	oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
	oFont08b  := TFont():New( "Arial",,08,,.t.,,,,.f.,.f. )
	oFont09   := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
	oFont09b  := TFont():New( "Arial",,09,,.t.,,,,.f.,.f. )
	oFont10   := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
	oFont10b  := TFont():New( "Arial",,10,,.t.,,,,.f.,.f. )
	oFont12   := TFont():New( "Arial",,12,,.f.,,,,.f.,.f. )
	oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
	oFont14b  := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
	oFont16b  := TFont():New( "Arial",,16,,.t.,,,,.f.,.f. )
	oFont20b  := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
	oFont30   := TFont():New( "Courier New",,8,,.t.,,,,.f.,.f. )

	_nLin := 0


	nOpcao := Aviso('Impress?o Lista de Falta',CRLF+'IMPRIMIR EM TELA(OPs do GRID) ou APENAS OP(s) SELECIONADA(s)',{'Em Tela','Selecionadas','Sair'}, 2)

	If nOpcao == 1
		lTela	:=	.T.
		cOpcao := '( Em Tela )'
	ElseIf nOpcao == 2
		lSelec	:=	.T. 
		cOpcao := '( Selecionadas )'
	Else
		Return()
	EndIf

	// In?cio do relat?rio
	oPrint:StartPage()
	_nLin := GoNew1Page(cOpcao)

	//					   [01]			[02]			[03]		[04] 		   [05]			  [06]			  [07]	     [08]  [09]FLAG
	//aAdd(_aEmpenho, { EMP->D4_COD, EMP->D4_LOCAL, EMP->D4_OP, EMP->D4_DATA, EMP->D4_QUANT, EMP->D4_RESERV, EMP->D4_RESPED,  0   , '' })

	If lTela
		_aSortEmp := aSort(_aEmpenho,,, { |x, y| x[1]+x[2] < y[1]+y[2] })
	Else
		_aSortEmp := {}
		cOpSelect := ''

		For nX := 1 To Len(aLista)  
			If aLista[nX][01]
				cOpSelect += AllTrim(aLista[nX][03])+'\'
			EndIf
		Next
			
		For nX := 1 To Len(_aEmpenho)  
			If AllTrim(_aEmpenho[nX][03]) $ cOpSelect 
				Aadd(_aSortEmp, _aEmpenho[nX])
			EndIf
		Next

	EndIf

	_cCodProd  	:= 	_aSortEmp[01][01]
	_cLocal		:=	_aSortEmp[01][02]
	_nSubtotal 	:= 	0
	lSubTotal	:=	.F.
	lTevePrint	:=	.F.
	cCodPrint	:=	''
	cLocPrint	:=	''

	//					   [01]			[02]			[03]		[04] 		   [05]			  [06]			  [07]	     [08]  [09]FLAG
	//aAdd(_aEmpenho, { EMP->D4_COD, EMP->D4_LOCAL, EMP->D4_OP, EMP->D4_DATA, EMP->D4_QUANT, EMP->D4_RESERV, EMP->D4_RESPED,  0   , '' })
	For _n := 1 To Len(_aSortEmp)
		

		cProdAtu 	:=	_aSortEmp[_n][01]
		cNumOP	 	:=	_aSortEmp[_n][03]
		nQtdEntrar	:=	_aSortEmp[_n][07]	//	QTD. PREVISTA P/ENTRAR	(SB2->B2_SALPEDI - EMP->D4_QUANT)
		nQtNegativo	:=	_aSortEmp[_n][08]	//	QTD.FICOU NEGATIVA
		lChkFalta	:=	_aSortEmp[_n][07] + _aSortEmp[_n][08] > 0


		// PESQUISA POR PRODUTO. VERIFICA SE NO ARRAY DOS EMPENHOS EXISTE O PRODUTO
		_nPosOP := Ascan(aLista,{|x| AllTrim(x[3])==AllTrim(cNumOP) })

		If (lSelec .Or. lTela) .And. _nPosOP == 0
			Loop
		EndIf
		
		If _nPosOP > 0
			_cCliente := Left(aLista[_nPosOp][05],25)
			_cProdOP  := AllTrim(aLista[_nPosOp][08])+' '+AllTrim(aLista[_nPosOp][09])
			lFalta	  := IIF(aLista[_nPosOp][35] == 'FALTAS', .T., .F.)				//_lPode 	  := IIF(aLista[_nPosOp][35] == 'FALTAS', .F., .T.)
		Else
			_cCliente 	:= 	""                  
			_cNumOP		:=	_aSortEmp[_n,3]

			DbSelectArea("SC2");DbSetOrder(1)
			If !DbSeek(xFilial("SC2")+_cNumOP)
				_cProdOP  := "PROBLEMA !- OP N?o encontrada"
			Else
				_cProdOP  := AllTrim(SC2->C2_PRODUTO)+' '+AllTrim(POSICIONE("SB1",1,xFilial("SB1")+SC2->C2_PRODUTO,"B1_DESC"))
			Endif

			If SC2->C2_TPOP == 'P'
				nPosOP	:= Ascan(aLista,{|X| AllTrim(X[03]) == AllTrim(SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN) })
				If nPosOP > 0
					lFalta	:= IIF(aLista[nPosOP][35] == 'FALTAS', .T., .F.)
				Else
					lFalta	:= .T.
				EndIf
			Else
				lFalta	:= .F.
			EndIf
			
		EndIf

		// IMPRIME SUBTOTAL DO ITEM QUE FOI IMPRESSO
		If cCodPrint  != cProdAtu .And. lTevePrint
			GoSubTotal(cCodPrint, cLocPrint, cOpcao)
			lSubTotal	:= 	.T. 
			lTevePrint	:=	.F.
		Else
			lSubTotal:= .F.
		EndIf

		If lFalta   //!_lPode

			// So considera os empenhos que faltam
			//If _aSortEmp[_n][07]+_aSortEmp[_n][08] > 0
						

				//					   [01]			[02]			[03]		[04] 		   [05]			  [06]			  [07]	     [08]  [09]FLAG
				//aAdd(_aEmpenho, { EMP->D4_COD, EMP->D4_LOCAL, EMP->D4_OP, EMP->D4_DATA, EMP->D4_QUANT, EMP->D4_RESERV, EMP->D4_RESPED,  0   , '' })
				
				lTevePrint	:=	.T.
				cCodPrint	:=	_aSortEmp[_n][01]
				cLocPrint	:=	_aSortEmp[_n][02]
				

				cCodMatPri	:= 	_aSortEmp[_n][01]
				cDescMP		:=	AllTrim(Posicione("SB1",1,xFilial("SB1")+_aSortEmp[_n][01],"B1_DESC"))
				cQtdEmp		:=	Transform(_aSortEmp[_n][05],"@R 9,999,999.9999")+IIF(_aSortEmp[_n][07] > 0,"(*)","")
				cNumOP		:=	_aSortEmp[_n][03]
				cDescOProd 	:= 	Left(_cProdOP,  52)
				cNomeCli	:=	Left(_cCliente, 30)


				// Das OP?s que faltam empenhos, so os que precisam ser comprados
				oPrint:Say( _nLin, 0110, cCodMatPri   	, oFont09)
				oPrint:Say( _nLin, 0400, cDescMP  		, oFont09)
				oPrint:Say( _nLin, 0960, cNumOP   		, oFont09)
				oPrint:Say( _nLin, 1210, cQtdEmp	 	, oFont09)
				oPrint:Say( _nLin, 1800, cDescOProd  	, oFont09)
				oPrint:Say( _nLin, 2800, cNomeCli 		, oFont09)

		
				_nLin += 40
				_nSubtotal += _aSortEmp[_n][5]
				
				IF _nLin >= _nLimVert
					oPrint:EndPage()   // Inicia uma nova p?gina
					_nLin := GoNew1Page(cOpcao)
				ENDIF

			//ENDIF
			
		ENDIF
		
		If _n == Len(_aSortEmp) .And. lTevePrint .And. !lSubTotal
			// ? o ultimo registro
			GoSubTotal(cCodPrint, cLocPrint, cOpcao)
		EndIf

	Next _n

	oPrint:Preview()
	MS_FLUSH()

Return


/*/{Protheus.doc} GoNew1Page
Primeira ou Nova p?gina
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 30/12/2021
@param cOpcao, character, Op??o selecionado pelo usu?rio
/*/
Static Function GoNew1Page(cOpcao)

	oPrint:StartPage()   // Inicia uma nova p?gina
	oPrint:Box  (0050, 0100, 2340, 3400)    	// Box da borda da p?gina
	oPrint:Line (0240, 0100, 0240, 3400)        // Linha do Topo
	oPrint:Line (0320, 0100, 0320, 3400)        // Linha do Topo
	//oPrint:Box  (0050, 0100, 3540, 2500)    	// Box da borda da p?gina
	//oPrint:Line (0240, 0100, 0240, 2500)        // Linha do Topo
	//oPrint:Line (0320, 0100, 0320, 2500)        // Linha do Topo
	//oPrint:Line (0240, 2200, 3040, 2200)    	// Linha Coluna 3
	//oPrint:Line (0240, 2000, 3040, 2000)    	// Linha Coluna 2
	//oPrint:Line (0240, 1800, 3040, 1800)    	// Linha Coluna 1

	oPrint:Say  (0090, 0400, " ANALISE DE MP FALTANTES PARA INICIO PRODU??O ", oFont20b)

	oPrint:Say  (0110, 3150, cOpcao, oFont30)
	oPrint:Say  (0160, 3150, DtoC(Date()), oFont30)
	oPrint:Say  (0190, 3150, Time(), oFont30)

	oPrint:Say( 0260, 0110, "C?digo MP"  , oFont09b)
	oPrint:Say( 0260, 0400, "Descri??o"  , oFont09b)
	oPrint:Say( 0260, 0960, "Ord.Prod.Prev."   , oFont09b)
	oPrint:Say( 0260, 1210, "Qtd Emp."   , oFont09b)
	//oPrint:Say( 0260, 1400, "Cod.Prod.OP PA - Descri??o"      , oFont09b)
	//oPrint:Say( 0260, 2060, "Cliente"    , oFont09b)
	oPrint:Say( 0260, 1800, "Cod.Prod.OP PA - Descri??o"      , oFont09b)
	oPrint:Say( 0260, 2800, "Cliente"    , oFont09b)

Return(320)


/*/{Protheus.doc} GoSubTotal
Impress?o dos Saldos
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 30/12/2021
@param _cCodProd, variant, C?digo do Produto
@param _cLocal, variant, Local do Produto
@param cOpcao, character, Op??o selecionada pelo usu?rio
/*/
Static Function GoSubTotal(_cCodProd, _cLocal, cOpcao)

	_aArea 	  := GetArea()
	nSaldoSB2 := 0

	oPrint:Line (_nLin   , 0800, _nLin   , 1800)        // Linha do Topo
	_nLin += 15
	oPrint:Say( _nLin, 0110, _cCodProd+" - SUBTOTAL " , oFont09b)
	oPrint:Say( _nLin, 1210, TRANSFORM(_nSubtotal,"@R 9,999,999.9999") , oFont09b)

	// Busca o Saldo Atua e o Saldo em Pedidos de Compra
	_cSld := " SELECT SUM(B2_QATU) AS 'B2_QATU', SUM(B2_SALPEDI)  AS 'B2_SALPEDI',SUM(B2_QEMP)  AS 'B2_QEMP' FROM "+RetSqlName("SB2")"
	_cSld += " WHERE B2_FILIAL = '"+xFilial("SB2")+"'AND B2_COD = '"+_cCodProd+"' AND D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,_cSld), "SLD", .T., .T. )
	DbSelectArea("SLD")
	DbGoTop()
	_nB2QATU := SLD->B2_QATU
	_nB2QPED := SLD->B2_SALPEDI
	_nB2QEMP := SLD->B2_QEMP

	DbSelectArea("SLD")
	DbCloseArea()

	If SB2->(DbSeek(xFilial("SB2") + _cCodProd + '01', .F.))	// _cLocal:= '01'
		nSaldoSB2 := SaldoSB2()
	//	_nB2QEMP :=  SB2->B2_QEMP
	EndIf

	//oPrint:Say( _nLin, 1400, "Sld Atual     : "+TRANSFORM(_nB2QATU,"@R 9,999,999.9999")  , oFont30)
	oPrint:Say( _nLin, 1400, "Sld Atual     : "+Transform(nSaldoSB2,"@R 9,999,999.9999")  , oFont30)
	oPrint:Say( _nLin, 2000, "Empenhos Prev.: "+TRANSFORM(_nB2QEMP,"@R 9,999,999.9999")  , oFont30)
	_nLin += 40
	oPrint:Say( _nLin, 1400, "Prev Entrar   : "+TRANSFORM(_nB2QPED,"@R 9,999,999.9999")  , oFont30)

	cSql := " SELECT C7_FILIAL, C7_NUM, C7_QUANT, C7_QUJE , (C7_QUANT - C7_QUJE), C7_DATPRF 	"+CRLF
	cSql += " FROM 	"+RetSqlName("SC7")+" SC7					"+CRLF
	cSql += " WHERE SC7.C7_FILIAL 	=  '"+xFilial('SC7')+"'		"+CRLF
	cSql += " AND 	SC7.C7_PRODUTO	=  '"+_cCodProd+"'	   		"+CRLF
	cSql += " AND 	(SC7.C7_QUANT - SC7.C7_QUJE) > 0 			"+CRLF
	cSql += " AND 	SC7.C7_RESIDUO != 'S'						"+CRLF
	cSql += " AND 	SC7.D_E_L_E_T_ != '*'						"+CRLF
	cSql += " ORDER BY SC7.C7_DATPRF							"+CRLF

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),'TMPSC7',.T.,.T.)
	DbSelectArea('TMPSC7');DbGoTop()
	oPrint:Say( _nLin, 1900, "Dt Entrar : "+ DtoC(StoD(TMPSC7->C7_DATPRF)) , oFont30)

	TMPSC7->( DbCloseArea() )

	_nLin += 60
	oPrint:Line (_nLin   , 0100, _nLin   , 3400)        // Linha do Topo
	_nSubtotal := 0

	//_cCodProd  := _aSortEmp[_n,1]

	IF _nLin >= (_nLimVert - 200) .and. _n < LEN(_aSortEmp)
		// testo para ver seapos este subtotal, tenho espa?o at? o final da pagina para mais um item.. senao nova pagina
		oPrint:EndPage()   // Inicia uma nova p?gina
		_nLin := GoNew1Page(cOpcao)
	ENDIF

	RestArea(_aArea)

Return()

/*/{Protheus.doc} I_PRODUCAO
Func??o que gera a impress?o da OP
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 30/12/2021
@param aLista, array, Listagem a ser impressa
/*/
Static Function I_PRODUCAO(aLista)

	Local cC6SA		   := ""
	Local cClasPed	   := ""
	Local cC6Depo	   := ""
	Local cC6PedCli	   := ""
	Local cCodigos     := ""
	Local cEntresi     := ""
	Local cMsgOp       := ""
	Local cC2_DescCC   := ""
	Local cFilSC2      := FWFilial("SC2")
	Local cFilSD4      := FWFilial("SD4")
	Local cFilSB1      := FWFilial("SB1")
	Local cFilSG1      := FWFilial("SG1")
	Local cFilSA1      := FWFilial("SA1")
	Local cFilSC5      := FWFilial("SC5")
	Local cFilSC6      := FWFilial("SC6")
	Local cFilCTT      := FWFilial("CTT")
	Local _nLin        := 0
	Local nY           := 0
	Local nContar      := 0
	Local lExiste      := .F.

	Private aObs       := {}
	Private _nQuant    := 0
	Private _nTot      := 0
	Private _nIpi      := 0
	Private _nTamLin   := 80
	Private _nLimVert  := 3500
	Private _nVia      := 1
	Private _nPagina   := 1
	Private _nIniLin   := 0
	Private _nCotDia   := 1
	Private _nMoeda    := 1
	Private _dCotDia   := DtoS( dDataBase )
	Private _cPrevisao := ""
	Private cObs       := ""
	Private _cPrazoPag := ""
	Private cLogo      := "lgrl01.bmp"
	Private oPrint, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20b, oFont10x, oFont14x, oFont24b

	// Verifica se houve a marca??o de pelo menos um aordem de produ??o para impress?o
	lExiste  := .F.
	cCodigos := ""
	cEntresi := ""

	// Cria o objeto de impressao
	oPrint := TmsPrinter():New()

	// Orienta??o da p?gina
	//oPrint:SetLandScape() // Para Paisagem
	oPrint:SetPortrait()    // Para Retrato

	// Tamanho da p?gina na impress?o
	//oPrint:SetPaperSize(8) // A3
	//oPrint:SetPaperSize(1) // Carta
	oPrint:SetPaperSize(9)   // A4

	// Cria os objetos de fontes que serao utilizadas na impressao do relatorio
	oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
	oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
	oFont08C  := TFont():New("Courier New", 09, 08,.T.,.F., 5,.T., 5, .T., .F.)
	oFont08b  := TFont():New( "Arial",,08,,.t.,,,,.f.,.f. )
	oFont09   := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
	oFont09b  := TFont():New( "Arial",,09,,.t.,,,,.f.,.f. )
	oFont10   := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
	oFont10b  := TFont():New( "Arial",,10,,.t.,,,,.f.,.f. )
	oFont12   := TFont():New( "Arial",,12,,.f.,,,,.f.,.f. )
	oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
	oFont14b  := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
	oFont16b  := TFont():New( "Arial",,16,,.t.,,,,.f.,.f. )
	oFont20b  := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
	oFont24b  := TFont():New( "Arial",,24,,.t.,,,,.f.,.f. )
	oFont08x   := TFont():New( "Courier New",,8,,.t.,,,,.f.,.f. )
	oFont10x  := TFont():New( "Courier New",,10,,.t.,,,,.f.,.f. )
	oFont14x  := TFont():New( "Courier New",,12,,.t.,,,,.f.,.f. )
	oFont10y  := TFont():New( "Courier New",,10,,.f.,,,,.f.,.f. )

	If Ascan(aLista,{|X| Left(X[31],01) == 'P' .And. X[01] == .T. }) > 0
		lFirmaOP := MsgYesNo('Deseja Firmar OPs Selecionadas ???')
	Else
		lFirmaOP := .F.
	EndIf

	For nContar = 1 to Len(aLista)
		
		If aLista[nContar,1]
			
			_cOP 	:= aLista[nContar,3]
			_nLin 	:= 60
			
			// In?cio do relat?rio
			oPrint:StartPage()
			
			oPrint:Line( _nLin, 0100, _nLin, 2370 )
			_nLin += 30
			
			// Logotipo e identifica??o do pedido
			oPrint:SayBitmap( _nLin, 0100, cLogo, 550, 200 )
			_nLin += 90
			
			oPrint:Say( _nLin, 0800, "ORDEM DE PRODU??O", oFont20b  )
			oPrint:Say( _nLin+70, 1900, _cOP, oFont14x )
			
			_nLin += 140
			oPrint:Line( _nLin, 0100, _nLin, 2370 )
			_nLin += 20
			
			//Posiciona OP
			DbSelectArea("SC2")
			DbSetOrder(1)
			DbSeek( cFilSC2 + _cOP)
			
			IF SC2->C2_TPOP == "P"
				// Firma OP?s Previstas
				If lFirmaOP
					A651Do()
				EndIf
			EndIf
			
			//Re-Posiciona OP
			DbSelectArea("SC2")
			DbSetOrder(1)
			DbSeek( cFilSC2 + _cOP)
			
			xRPMOP   := {}
			xRMINMAX := {}
			xRECURSO := {}
			
			DBSELECTAREA('SB1')
			DBSETORDER(1)
			DBSEEK( cFilSB1 + SC2->C2_PRODUTO)
			_cBarProd := SB1->B1_CODBAR
			_nQb      := SB1->B1_QB
			cClasPed  := space(1)
			cMsgOp    := ""
			cC6SA     := ""
			cC6Depo	  := ""
			cC6PedCli := ""
			cSA1End   := ""
			cSA1Nome  := ""
			cSA1Mun   := ""
			cSA1CEP   := ""
			cSA1CGC   := ""
			cSA1Tel   := ""
			cSA1Email := ""
			
			//LOCALIZA CODIGO DO CLIENTE
			If .NOT. Empty( SC2->C2_PEDIDO )

				DBSELECTAREA('SC5')
				DBSETORDER(1)
				DBSEEK( cFilSC5 +SC2->C2_PEDIDO)

				//DADOS DO CLIENTE
				DBSELECTAREA('SA1')
				DBSETORDER(1)
				DBSEEK( cFilSa1 + SC5->C5_CLIENTE + SC5->C5_LOJACLI)
				cSA1End   := SA1->A1_END
				cSA1Nome  := SA1->A1_NOME
				cSA1Mun   := SA1->A1_MUN
				cSA1CEP   := SA1->A1_CEP
				cSA1CGC   := SA1->A1_CGC
				cSA1Tel   := SA1->A1_TEL
				cSA1Email := SA1->A1_EMAIL
				
				DbSelectArea('SC6')
				DbSetorder(1)
				DbSeek( cFilSC6 +SC2->C2_PEDIDO +SC2->C2_ITEMPV)
				IF SC6->C6_CLASPED == "1"
					cClasPed := space(1)
				ELSEIF SC6->C6_CLASPED == "2"
					cClasPed := "PRIMEIRA COMPRA"
				ELSEIF SC6->C6_CLASPED == "3"
					cClasPed := "CARGA TESTE"
				ELSEIF SC6->C6_CLASPED == "4"
					cClasPed := "VALIDA??O PADR?O"
				ENDIF

				cC6SA     := SC6->C6_SA
				cC6Depo   := SC6->C6_DEPOSIT
				cC6PedCli := SC6->C6_PEDCLI
			EndIf

			DbSelectArea("SC2")

			oPrint:Say( _nLin, 0110, "Pedido  : " + SC2->C2_PEDIDO + "  Cliente  : " + cSA1Nome , oFont10b)

			If .NOT. Empty(cClasPed)
				oPrint:Say( _nLin, 0500, cClasPed  , oFont10b)
			EndIf

			If .NOT. Empty(cC6SA)
				oPrint:Say( _nLin, 0700, "SA: " + cC6SA  , oFont10b)
			EndIf
			
			_nLin += 50
			oPrint:Say( _nLin, 0110, "Endere?o : " + cSA1End , oFont10)
			_nLin += 50
			oPrint:Say( _nLin, 0110, "Cidade   : " + Alltrim( cSA1Mun ) + "       CEP : " + cSA1CEP , oFont10)
			_nLin += 50
			oPrint:Say( _nLin, 0110, "CGC      : " + Transform(cSA1CGC ,"@R 99.999.999/9999-99")+"       Tel. : " + cSA1Tel + "      email : " + cSA1Email , oFont10)
			_nLin += 50
			oPrint:Line( _nLin, 0100, _nLin, 2370 )
			_nLin += 50
			
			//Dados da OP
			
			oPrint:Say( _nLin, 0110, "Numero OP : " + SC2->(C2_NUM+"."+C2_ITEM+"."+C2_SEQUEN)+" - "+IIF(C2_TPOP=="P","PREVISTA","FIRME") , oFont12b)
			oPrint:Say( _nLin, 1500, "Entrega   : " + DTOC(SC2->C2_DATPRF) , oFont10)

			_nLin += 50
			oPrint:Say( _nLin, 0110, "Produto   : " + SC2->C2_PRODUTO , oFont12b)
			oPrint:Say( _nLin, 1500, "Quantidade: " + Transform(SC2->C2_QUANT,"@R 999,999.99")+" "+SC2->C2_UM , oFont12b)
			_nLin += 50
			oPrint:Say( _nLin, 0110, "Descri??o : " + SB1->B1_DESC    , oFont12b)
			oPrint:Say( _nLin, 1500, "Cod.Barras: " , oFont10)
			_nLin += 50
			oPrint:Say( _nLin, 0110, "Vers?o    : " + SB1->B1_MODELO   , oFont10)
			oPrint:Say( _nLin, 1000, "[  ]Urgente  [  ]Estoque Cliente ", oFont10)
			_nLin += 50
			oPrint:Say( _nLin, 0110, "Deposito  : " + cC6Depo   , oFont10)
			oPrint:Say( _nLin, 0500, "O.Compra  : " + cC6PedCli , oFont10)
			
			_nLin += 150
			oPrint:Line( _nLin, 0100, _nLin, 2370 )
			_nLin += 50
			
			oPrint:Say( _nLin, 0110, "PCP   :__________ Produ??o :__________  CQ   :__________ Expedi??o :__________ " , oFont14x)
			_nLin += 75
			oPrint:Say( _nLin, 0110, "Data  :__________     Data :__________  Data :__________      Data :__________ " , oFont14x)
			_nLin += 75

			_cValid := ""
			IF SB1->B1_TIPE == "H"
				_cValid := " HORA(s)"
			ELSEIF SB1->B1_TIPE == "D"
				_cValid := " DIA(s)"
			ELSEIF SB1->B1_TIPE == "S"
				_cValid := " SEMANA(s)"
			ELSEIF SB1->B1_TIPE == "M"
				_cValid := " MESES"
			ELSEIF SB1->B1_TIPE == "A"
				_cValid := " ANO(s)"
			ENDIF
			
			cC2_DescCC	:= AllTrim(Left(Posicione("CTT",1, cFilCTT +SC2->C2_CC,"CTT_DESC01"),30))
			
			oPrint:Say( _nLin, 0110, "Centro de Custo: " + AllTrim(SC2->C2_CC)+' '+cC2_DescCC     + "  " + ;
									"Validade: " + TRANSFORM(SB1->B1_PRVALID,"@R 999") + _cValid      , oFont10x)
				
			//oPrint:Say( _nLin, 1500, "Validade : " + TRANSFORM(SB1->B1_PRVALID,"@R 999") + _cValid , oFont10x)

			_nLin += 100
			oPrint:Line( _nLin, 0100, _nLin, 2370 )
			//_nLin += 50
			oPrint:Say( _nLin, 0500, "Formula??o do Item", oFont10x)
			_nLin += 50
			oPrint:Say( _nLin, 0100, "Item                      Descri??o                                  Percentual             Quantidade          Lote     ", oFont10x)
			_nLin += 50
			oPrint:Line( _nLin, 0100, _nLin, 2370 )
			_nLin += 50
			
			// Zera Acumuladores para a impress?o
			TOTPER := 0
			TOTQTD := 0
			
			dbSelectArea("SD4")
			DbSetorder(2)
			dbSeek( cFilSD4 + _cOP  )
			Do While !Eof() .and. SD4->D4_OP = _cOP .AND. SD4->D4_FILIAL == cFilSD4
				
				dbSelectArea('SB1')
				dbSetOrder(1)
				dbSeek( cFilSB1 + SD4->D4_COD)
				
				oPrint:Say( _nLin, 0100, SD4->D4_COD           , oFont10y)
				oPrint:Say( _nLin, 0400, LEFT(SB1->B1_DESC,30) , oFont10y)
				
				oPrint:Say( _nLin, 1200, TRANSFORM(SD4->D4_QUANT/SC2->C2_QUANT, "99999.9999" )+"%" , oFont10y)
				TOTPER += SD4->D4_QUANT/SC2->C2_QUANT
				TOTQTD += SD4->D4_QUANT
				
				oPrint:Say( _nLin, 1500,TRANSFORM(SD4->D4_QUANT, "@E 99,999.9999" ) + " " + SB1->B1_UM , oFont10y)
				
				oPrint:Say( _nLin, 1800, "____________" , oFont10y)
				
				_nLin += 50
			
				DbSelectArea("SD4")
				DbSkip()
			Enddo
			
			// Varro a Estrutura "batendo" com o empenho
			dbSelectArea("SG1")
			DbSetorder(1)
			dbSeek( cFilSG1 + SC2->C2_PRODUTO )
			Do While !Eof() .and. SG1->G1_COD = SC2->C2_PRODUTO .and. SC2->C2_FILIAL == cFilSC2
				
				IF dDatabase >= SG1->G1_INI .and. dDatabase <= SG1->G1_FIM
					
					dbSelectArea("SD4")
					DbSetorder(2)
					dbSeek( cFilSD4 + _cOP + "  " + SG1->G1_COMP )
					
					IF EOF()
						// Nao esta empenhado
						dbSelectArea('SB1')
						dbSetOrder(1)
						dbSeek( cFilSB1 + SG1->G1_COMP )

						If SB1->B1_FANTASM == 'S'
						
							oPrint:Say( _nLin, 0060, "(*)" , oFont08x)
							oPrint:Say( _nLin, 0100, SG1->G1_COMP    , oFont10y)
							oPrint:Say( _nLin, 0400, LEFT(SB1->B1_DESC,30) , oFont10y)
							
							oPrint:Say( _nLin, 1200, TRANSFORM(SG1->G1_QUANT/_nQb, "@E 9999.9999" )+"%" , oFont10y)
							TOTPER += SG1->G1_QUANT/_nQb
							TOTQTD += (SG1->G1_QUANT/_nQb)*SC2->C2_QUANT
	
							oPrint:Say( _nLin, 1500,TRANSFORM((SG1->G1_QUANT/_nQb)*SC2->C2_QUANT, "@E 99,999.9999" ) + " " + SB1->B1_UM , oFont10y)
							
							oPrint:Say( _nLin, 1800, "____________" , oFont10y)

							_nLin += 50
						
						EndIf
						
					ENDIF
				ENDIF
				
				DbSelectArea("SG1")
				DbSkip()
			Enddo

			_nLin += 25
			oPrint:Say( _nLin, 0090, "(*) Estrutura sem empenho " , oFont08x)
			_nLin += 25
			oPrint:Say( _nLin, 1200, TRANSFORM(TOTPER, "@E 9999.9999"   )+"%" , oFont10x)
			oPrint:Say( _nLin, 1500, TRANSFORM(TOTQTD, "@E 99,999.9999" )     , oFont10x)
			_nLin += 50
			
			oPrint:Line( _nLin, 0100, _nLin, 2370 )
			
			oPrint:Say( _nLin, 0100, "Observacoes : ", oFont14x)
			_nLin += 50
			
			nLinhas := MlCount( cMsgOp , 100)
			For nY := 1 To nLinhas
				_cTxt := Memoline( cMsgOp, 100, nY)
				oPrint:Say( _nLin, 0100, _cTxt, oFont10x)
				_nLin += 50
			Next nY
			oPrint:Line( _nLin, 0100, _nLin, 2370 )

			MsBar3("CODE128",01,15,ALLTRIM(_cOP) ,oPrint,.F.,,.T.,0.030,1.0,.f.,,,.F.)
			
			oPrint:EndPage()
			
		Endif
		
	Next nContar

	If _nLin > 0
		oPrint:Preview()
	Else
		MsgInfo( "Marque uma ou mais OP's para que seja realizada a impress?o !" )
	EndIf
	
	MS_FLUSH()

	FreeObj( oPrint )

Return


/*/{Protheus.doc} I_REQUISICAO
Impress?o dos dados da Requisi??o
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 30/12/2021
@param aLista, array, Lista de requisi??es
/*/
Static Function I_REQUISICAO(aLista)

	Local nY		   := 0
	Local nX		   := 0
	Local nContar      := 0
	Local _nContaSac   := 0
	Local _nLin        := 0
	Local cCodigos     := ""
	Local cEntresi     := ""
	Local cClasPed     := space(1)
	Local cC6SA        := ""
	Local cSA1End      := ""
	Local cSA1Nome     := ""
	Local cSA1Mun      := ""
	Local cSA1CEP      := ""
	Local cSA1CGC      := ""
	Local cSA1Tel      := ""
	Local cSA1Email    := ""
	Local cFilSC2      := FWFilial("SC2")
	Local cFilSD4      := FWFilial("SD4")
	Local cFilSB1      := FWFilial("SB1")
	Local cFilSG2      := FWFilial("SG2")
	Local cFilSA1      := FWFilial("SA1")
	Local cFilSC5      := FWFilial("SC5")
	Local cFilSC6      := FWFilial("SC6")
	Local cFilCTT      := FWFilial("CTT")
	Local cFilSH1      := FWFilial("SH1")
	Local lExiste      := .F.

	Private aObs       := {}
	Private _nQuant    := 0
	Private _nTot      := 0
	Private _nIpi      := 0
	Private _nTamLin   := 80
	Private _nLimVert  := 3500
	Private _nVia      := 1
	Private _nPagina   := 1
	Private _nIniLin   := 0
	Private _nCotDia   := 1
	Private _nMoeda    := 1
	Private _dCotDia   := DtoS( dDataBase )
	Private _cPrevisao := ""
	Private cObs       := ""
	Private _cPrazoPag := ""
	Private _cMsgOp    := ""
	Private cLogo      := "lgrl01.bmp"
	Private oPrint, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20b, oFont10x, oFont14x, oFont24b

	// Verifica se houve a marca??o de pelo menos um aordem de produ??o para impress?o
	lExiste  := .F.
	cCodigos := ""
	cEntresi := ""

	// Cria o objeto de impressao
	oPrint := TmsPrinter():New()

	// Orienta??o da p?gina
	//oPrint:SetLandScape() // Para Paisagem
	oPrint:SetPortrait()    // Para Retrato

	// Tamanho da p?gina na impress?o
	//oPrint:SetPaperSize(8) // A3
	//oPrint:SetPaperSize(1) // Carta
	oPrint:SetPaperSize(9)   // A4

	// Cria os objetos de fontes que serao utilizadas na impressao do relatorio
	oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
	oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
	oFont08C  := TFont():New("Courier New", 09, 08,.T.,.F., 5,.T., 5, .T., .F.)
	oFont08b  := TFont():New( "Arial",,08,,.t.,,,,.f.,.f. )
	oFont09   := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
	oFont09b  := TFont():New( "Arial",,09,,.t.,,,,.f.,.f. )
	oFont10   := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
	oFont10b  := TFont():New( "Arial",,10,,.t.,,,,.f.,.f. )
	oFont12   := TFont():New( "Arial",,12,,.f.,,,,.f.,.f. )
	oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
	oFont14b  := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
	oFont16b  := TFont():New( "Arial",,16,,.t.,,,,.f.,.f. )
	oFont20b  := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
	oFont24b  := TFont():New( "Arial",,24,,.t.,,,,.f.,.f. )
	oFont08x   := TFont():New( "Courier New",,8,,.t.,,,,.f.,.f. )
	oFont10x  := TFont():New( "Courier New",,10,,.t.,,,,.f.,.f. )
	oFont14x  := TFont():New( "Courier New",,12,,.t.,,,,.f.,.f. )
	oFont10y  := TFont():New( "Courier New",,10,,.f.,,,,.f.,.f. )

	If Ascan(aLista,{|X| Left(X[31],01) == 'P' .And. X[01] == .T. }) > 0
		lFirmaOP := MsgYesNo('Deseja Firmar OPs Selecionadas ???')
	Else
		lFirmaOP := .F.
	EndIf

	For nContar = 1 to Len(aLista)

		If aLista[nContar,1]
			
			_cOP 	:= aLista[nContar,3]
			
			For _nContaSac := 1 to nVias
				
				_nLin 	:= 60
				
				// In?cio do relat?rio
				oPrint:StartPage()
				
				oPrint:Line( _nLin, 0100, _nLin, 2370 )
				_nLin += 30
				
				// Logotipo e identifica??o do pedido
				oPrint:SayBitmap( _nLin, 0100, cLogo, 550, 200 )
				_nLin += 90
				
				oPrint:Say( _nLin, 0900, "REQUISI??O - OP N? ", oFont20b  )	//PESAGEM
				oPrint:Say( _nLin+75 , 1900, _cOP + "     "+ALLTRIM(STR(_nContaSac,3,0)), oFont14x )
				
				_nLin += 140
				oPrint:Line( _nLin, 0100, _nLin, 2370 )
				_nLin += 20
				
				//Posiciona OP
				DbSelectArea("SC2")
				DbSetOrder(1)
				DbSeek( cFilSC2 + _cOP)
				
				IF SC2->C2_TPOP == "P"
					// Firma OP?s Previstas
					If lFirmaOP
						A651Do()
					EndIf
				ENDIF
				
				//Re-Posiciona OP
				DbSelectArea("SC2")
				DbSetOrder(1)
				DbSeek( cFilSC2 + _cOP)
				
				DBSELECTAREA('SB1')
				DBSETORDER(1)
				DBSEEK( cFilSB1 + SC2->C2_PRODUTO)
				_cBarProd := SB1->B1_CODBAR
				_nQb      := SB1->B1_QB
				_cMsgOP   := ""
				cClasPed  := space(1)
				cC6SA     := ""
				cSA1End   := ""
				cSA1Nome  := ""
				cSA1Mun   := ""
				cSA1CEP   := ""
				cSA1CGC   := ""
				cSA1Tel   := ""
				cSA1Email := ""
				
				//LOCALIZA CODIGO DO CLIENTE
				If .NOT. Empty( SC2->C2_PEDIDO )
					DBSELECTAREA('SC5')
					DBSETORDER(1)
					DBSEEK( cFilSC5 + SC2->C2_PEDIDO)

					//DADOS DO CLIENTE
					DBSELECTAREA('SA1')
					DBSETORDER(1)
					DBSEEK( cFilSa1 + SC5->C5_CLIENTE + SC5->C5_LOJACLI)
					cSA1End   := SA1->A1_END
					cSA1Nome  := SA1->A1_NOME
					cSA1Mun   := SA1->A1_MUN
					cSA1CEP   := SA1->A1_CEP
					cSA1CGC   := SA1->A1_CGC
					cSA1Tel   := SA1->A1_TEL
					cSA1Email := SA1->A1_EMAIL

					DbSelectArea('SC6')
					DbSetorder(1)
					DbSeek( cFilSC6 +SC2->C2_PEDIDO +SC2->C2_ITEMPV)
					cClasPed := space(1)
					IF SC6->C6_CLASPED == "1"
						cClasPed := space(1)
					ELSEIF SC6->C6_CLASPED == "2"
						cClasPed := "PRIMEIRA COMPRA"
					ELSEIF SC6->C6_CLASPED == "3"
						cClasPed := "CARGA TESTE"
					ELSEIF SC6->C6_CLASPED == "4"
						cClasPed := "VALIDA??O PADR?O"
					ENDIF
					
					cC6SA := SC6->C6_SA
				EndIf
				
				DbSelectArea("SC2")
				
				oPrint:Say( _nLin, 0110, "Pedido  : " + SC2->C2_PEDIDO + "  Cliente  : " + cSA1Nome , oFont10b)
				If .NOT. Empty( cClasPed )
					oPrint:Say( _nLin, 0500, cClasPed  , oFont10b)
				EndIf
				If .NOT. Empty( cC6SA )
					oPrint:Say( _nLin, 0700, "SA: " + cC6SA , oFont10b)
				EndIf
				
				_nLin += 50
				oPrint:Say( _nLin, 0110, "Endere?o : " + cSA1End , oFont10)
				_nLin += 50
				oPrint:Say( _nLin, 0110, "Cidade   : " + Alltrim( cSA1Mun ) + "       CEP : " + cSA1CEP , oFont10)
				_nLin += 50
				oPrint:Say( _nLin, 0110, "CGC      : " + Transform( cSA1CGC ,"@R 99.999.999/9999-99")+"       Tel. : " + cSA1TEL + "      email : " + cSA1Email , oFont10)
				_nLin += 50
				oPrint:Line( _nLin, 0100, _nLin, 2370 )
				_nLin += 50
				
				//Dados da OP
				oPrint:Say( _nLin, 0800, " REQUISI??O / CONSUMO DE MATERIAIS " , oFont14b)

				_nLin += 100
				oPrint:Say( _nLin, 0110, "Numero OP : " + SC2->(C2_NUM+"."+C2_ITEM+"."+C2_SEQUEN)+" - "+IIF(C2_TPOP=="P","PREVISTA","FIRME") , oFont12b)
				oPrint:Say( _nLin, 1500, "Entrega   : " + DTOC(SC2->C2_DATPRF) , oFont12b)

				_nLin += 50
				oPrint:Say( _nLin, 0110, "Produto   : " + SC2->C2_PRODUTO , oFont12b)
				oPrint:Say( _nLin, 1500, "Quantidade: " + Transform(SC2->C2_QUANT,"@R 999,999.99")+" "+SC2->C2_UM , oFont12b)
				_nLin += 50
				oPrint:Say( _nLin, 0110, "Descri??o : " + SB1->B1_DESC    , oFont12b)
				_nLin += 50
				oPrint:Say( _nLin, 1100, "Saldo:   " + Transform(SC2->C2_QUANT-SC2->C2_QUJE,"@R 999,999.99") , oFont12b)

				_nLin += 150

				cDescCC	:= AllTrim(Posicione("CTT",1, cFilCTT + SC2->C2_CC,"CTT_DESC01"))
				oPrint:Say( _nLin, 0110, "Centro de Custo : " + AllTrim(SC2->C2_CC)+' '+cDescCC , oFont12b)

				
				_nLin += 100
				oPrint:Line( _nLin, 0100, _nLin, 2370 )
				//_nLin += 50
				oPrint:Say( _nLin, 0500, "Formula??o do Item", oFont10x)
				_nLin += 50
				//oPrint:Say( _nLin, 0100, "Item                   Descri??o                  Percentual   Quantidade       Lote     ", oFont10x)
				oPrint:Say( _nLin, 0100, "Item                      Descri??o                                  Percentual             Quantidade          Lote     ", oFont10x)
				_nLin += 50
				oPrint:Line( _nLin, 0100, _nLin, 2370 )
				_nLin += 50
				
				// Zera Acumuladores para a impress?o
				TOTPER := 0
				TOTQTD := 0
				
				dbSelectArea("SD4")
				DbSetorder(2)
				dbSeek( cFilSD4 + _cOP  )
				Do While !Eof() .and. SD4->D4_OP == _cOP .AND. SD4->D4_FILIAL == cFilSD4
					
					dbSelectArea('SB1')
					dbSetOrder(1)
					dbSeek( cFilSB1 + SD4->D4_COD)
					
					oPrint:Say( _nLin, 0100, SD4->D4_COD           , oFont12b)
					oPrint:Say( _nLin, 0400, LEFT(SB1->B1_DESC,30) , oFont12b)
				
					oPrint:Say( _nLin, 1280, TRANSFORM(SD4->D4_QUANT/SC2->C2_QUANT, "@E 9999.9999" )+"%" , oFont12b)
					TOTPER += SD4->D4_QUANT/SC2->C2_QUANT
					TOTQTD += SD4->D4_QUANT

					oPrint:Say( _nLin, 1580,TRANSFORM(SD4->D4_QUANT, "@E 99,999.9999" ) + " " + SB1->B1_UM , oFont12b)
					oPrint:Say( _nLin, 1880, "____________" , oFont12b)

					_nLin += 80

					DbSelectArea("SD4")
					DbSkip()
				Enddo

				_nLin += 25
				oPrint:Say( _nLin, 0090, "(*) Estrutura sem empenho " , oFont08x)
				_nLin += 25
				oPrint:Say( _nLin, 1280, TRANSFORM(TOTPER, "@E 9999.9999"   )+"%" , oFont10x)
				oPrint:Say( _nLin, 1580, TRANSFORM(TOTQTD, "@E 99,999.9999" )     , oFont10x)
				_nLin += 50
				
				oPrint:Line( _nLin, 0100, _nLin, 2370 )
				
				oPrint:Say( _nLin, 0100, "Observacoes (OP/Produto): ", oFont14x)
				_nLin += 50
				
				nLinhas := MlCount( _cMsgOP , 100)
				For nY := 1 To nLinhas
					_cTxt := Memoline( _cMsgOP, 100, nY)
					oPrint:Say( _nLin, 0100, _cTxt, oFont10x)
					_nLin += 50
				Next nY
				oPrint:Line( _nLin, 0100, _nLin, 2370 )
				
				// Roteiro de Operacoes
				oPrint:Line( _nLin, 0100, _nLin, 2370 )
				//_nLin += 50
				oPrint:Say( _nLin, 0500, "ROTEIRO DE OPERA??ES", oFont10x)
				_nLin += 50
				oPrint:Say( _nLin, 0100, "Oper"        , oFont10x)
				oPrint:Say( _nLin, 0200, "Recurso"     , oFont10x)
				oPrint:Say( _nLin, 0400, "Descri??o"   , oFont10x)
				oPrint:Say( _nLin, 0850, " Inicio  "   , oFont10x)
				oPrint:Say( _nLin, 1060, "  Fim    "   , oFont10x)
				oPrint:Say( _nLin, 1300, " Hr.Inicio"  , oFont10x)
				oPrint:Say( _nLin, 1500, "  Hr.Fim"    , oFont10x)
				oPrint:Say( _nLin, 1800, "Operador"    , oFont10x)
				_nLin += 50
				oPrint:Line( _nLin, 0100, _nLin, 2370 )
				_nLin += 50
				
				aSG2 := {}
				DbSelectarea("SG2")
				DbSetOrder(1) //G2_FILIAL+G2_PRODUTO+G2_CODIGO+G2_OPERAC
				DbSeek(cFilSG2+SC2->C2_PRODUTO+SC2->C2_ROTEIRO)
				Do While cFilSG2+SC2->C2_PRODUTO+SC2->C2_ROTEIRO == SG2->(G2_FILIAL+G2_PRODUTO+G2_CODIGO)
					
					Aadd(aSG2, {SG2->G2_OPERAC, SG2->G2_RECURSO } )
					/*
					oPrint:Say( _nLin, 0100, SG2->G2_OPERAC        , oFont08x)
					oPrint:Say( _nLin, 0200, SG2->G2_RECURSO       , oFont08x)
					oPrint:Say( _nLin, 0350, Posicione("SH1",1,xFilial("SH1")+SG2->G2_RECURSO,"H1_DESCRI") , oFont08x)
					oPrint:Say( _nLin, 0850, "___/___/___"           , oFont08x)
					oPrint:Say( _nLin, 1060, "___/___/___"           , oFont08x)
					oPrint:Say( _nLin, 1300, "___:___"           , oFont08x)
					oPrint:Say( _nLin, 1500, "___:___"           , oFont08x)
					oPrint:Say( _nLin, 1800, "__________________"   , oFont08x)
					_nLin += 75
					*/
					DbSelectarea("SG2")
					DbSkip()
				Enddo

				For nX:=1 To Len(aSG2)
					
					
					cOperac := 	aSG2[nX][01]
					cRecurso:=	aSG2[nX][02]
					cDescCC	:=	AllTrim(Posicione("SH1",1, cFilSH1 + cRecurso,"H1_DESCRI"))
				
					If nX == Len(aSG2)
						cRecurso:=	SC2->C2_CC
						cDescCC	:=	AllTrim(Posicione("CTT",1, cFilCTT + cRecurso,"CTT_DESC01"))                
					EndIf
					
					oPrint:Say( _nLin, 0100,  cOperac, 	oFont08x)
					oPrint:Say( _nLin, 0200,  cRecurso,	oFont08x)
					oPrint:Say( _nLin, 0350,  cDescCC, 	oFont08x)
					oPrint:Say( _nLin, 0850, "___/___/___"           , oFont08x)
					oPrint:Say( _nLin, 1060, "___/___/___"           , oFont08x)
					oPrint:Say( _nLin, 1300, "___:___"           , oFont08x)
					oPrint:Say( _nLin, 1500, "___:___"           , oFont08x)
					oPrint:Say( _nLin, 1800, "__________________"   , oFont08x)
					_nLin += 75
									
				Next

				MsBar3("CODE128",01,15,ALLTRIM(_cOP),oPrint,.F.,,.T.,0.030,1.0,.f.,,,.F.)
				
				oPrint:EndPage()
				
			Next _nContaSac
			
		Endif
		
	Next nContar

	oPrint:Preview()
	MS_FLUSH()

Return


/*/{Protheus.doc} I_Consulta
Fun??o que gera a impress?o da tela de consulta
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 30/12/2021
@param aLista, array, Lista a ser impressa
/*/
Static Function I_Consulta(aLista)

	Local _n           := 0
	
	Private aObs       := {}
	Private _nLin      := 0
	Private _nQuant    := 0
	Private _nTot      := 0
	Private _nIpi      := 0
	Private _nTamLin   := 80
	Private _nLimVert  := 3500
	Private _nVia      := 1
	Private _nPagina   := 1
	Private _nIniLin   := 0
	Private _nCotDia   := 1
	Private _nMoeda    := 1
	Private nPagina    := 1
	Private cObs       := ""
	Private _cPrevisao := ""                 
	Private _cPrazoPag := ""
	Private _dCotDia   := DtoS( dDataBase )
	Private oPrint, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont30

	nOpcao := Aviso('Impress?o Consulta',CRLF+'IMPRIMIR ITEM(s) EM FALTA, OP(s) SELECIONADA(s), P/ PRODUZIR OU AMBAS ???',;
					{'Faltas','Selecionadas','Produzir','Todas','Sair'}, 2)

	If nOpcao == 1
		cOpcao := 'FALTAS'
	ElseIf nOpcao == 2
		cOpcao := 'SELECIONADAS'
	ElseIf nOpcao == 3
		cOpcao := 'PRODUZIR'
	ElseIf nOpcao == 4
		cOpcao := 'TODAS'
	Else
		Return()
	EndIf

	// Cria os objetos de fontes que serao utilizadas na impressao do relatorio
	oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
	oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
	oFont08b  := TFont():New( "Arial",,08,,.t.,,,,.f.,.f. )
	oFont09   := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
	oFont09b  := TFont():New( "Arial",,09,,.t.,,,,.f.,.f. )
	oFont10   := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
	oFont10b  := TFont():New( "Arial",,10,,.t.,,,,.f.,.f. )
	oFont12   := TFont():New( "Arial",,12,,.f.,,,,.f.,.f. )
	oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
	oFont14b  := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
	oFont16b  := TFont():New( "Arial",,16,,.t.,,,,.f.,.f. )
	oFont20b  := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
	oFont30   := TFont():New( "Courier New",,8,,.t.,,,,.f.,.f. )

	// Cria o objeto de impressao
	oPrint := TmsPrinter():New()

	// Orienta??o da p?gina

	//oPrint:SetPortrait()    // Para Retrato
	// Tamanho da p?gina na impress?o
	//oPrint:SetPaperSize(8) // A3
	//oPrint:SetPaperSize(1) // Carta
	//oPrint:SetPaperSize(9)   // A4
	oPrint:SetLandScape() // Para Paisagem

	_nLin := 0

	// In?cio do relat?rio
	oPrint:StartPage()
	_nLin := GoCabecTela(cOpcao)

	For _n := 1 To Len(aLista)  

		If cOpcao == 'SELECIONADAS'	.And. !aLista[_n][01]
			Loop
		ElseIf cOpcao == 'FALTAS' 	.And. aLista[_n][35] != 'FALTAS'
			Loop
		ElseIf cOpcao == 'PRODUZIR'	.And. aLista[_n][35] != 'PRODUZIR'
			Loop
		EndIf

		nTamDesc	:= Len(AllTrim(aLista[_n,9]))

		cNumOP 	 	:= 	Left(aLista[_n][3],06)+'.'+SubStr(aLista[_n][3],07,02)+'.'+Right(aLista[_n][3],03) 
		oPrint:Say( _nLin, 0015, cNumOP,  		oFont08)									//	OP
		oPrint:Say( _nLin, 0220, aLista[_n,8],  oFont08)									//	PRODUTO
		oPrint:Say( _nLin, 0430, aLista[_n,9],  oFont08)									//	DESCRICAO
		oPrint:Say( _nLin, 0910, aLista[_n,5],  oFont08)									// 	CLIENTE
		oPrint:Say( _nLin, 1500, aLista[_n,33], oFont08)									//	VEICULO
		oPrint:Say( _nLin, 1710, aLista[_n,32], oFont08)									//	RECURSO

		// dData		:=	aLista[_n,20]
		// cDtEmissao 	:= PadL(cValToChar(Day(dData)),  02,'0')+'/'
		// cDtEmissao 	+= PadL(cValToChar(Month(dData)),02,'0')+'/'
		// cDtEmissao 	+= Right(cValToChar(Year(dData)),02)
		oPrint:Say( _nLin, 2430, DtoC(aLista[_n,20]), oFont08)
		
		// dData		:=	aLista[_n,18]
		// cDtEntreg 	:= PadL(cValToChar(Day(dData)),  02,'0')+'/'
		// cDtEntreg 	+= PadL(cValToChar(Month(dData)),02,'0')+'/'
		// cDtEntreg 	+= Right(cValToChar(Year(dData)),02)
		oPrint:Say( _nLin, 2600, DtoC(aLista[_n,18]), oFont08)
		
		// dData		:=	aLista[_n,19]
		// cDtReal 	:= PadL(cValToChar(Day(dData)),  02,'0')+'/'
		// cDtReal 	+= PadL(cValToChar(Month(dData)),02,'0')+'/'
		// cDtReal 	+= Right(cValToChar(Year(dData)),02)    
		oPrint:Say( _nLin, 2770, DtoC(aLista[_n,19]), oFont08)


		
		oPrint:Say( _nLin, 2940, Transform(aLista[_n,06],"@E 999,999.9999"), oFont08)		// 	QTD.ORIG
		oPrint:Say( _nLin, 3100, Transform(aLista[_n,34],"@E 999,999.9999"), oFont08)		//	SALDO A ENTR
	//  oPrint:Say( _nLin, 3160, aLista[_n,29], oFont08)							   		//	STATUS
		oPrint:Say( _nLin, 3260, aLista[_n,31], oFont08)							   		//	TIPO
		_nLin:= _nLin + 50

		If _nLin > 2300
		nPagina++ 
		oPrint:EndPage()
		_nLin := GoCabecTela(cOpcao)                             
		n_Lin := 320     
		Endif

	Next _n

	oPrint:Preview()
	MS_FLUSH()             

Return


/*/{Protheus.doc} GoCabecTela
Imprime o cabe?alho da impress?o
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 30/12/2021
@param cOpcao, character, Op??o selecionada pelo usu?rio
/*/
Static Function GoCabecTela(cOpcao)

	oPrint:StartPage()   // Inicia uma nova p?gina
	oPrint:Box  (0050, 0010, 2340, 3380)    	// Box da borda da p?gina		// 2550
	oPrint:Line (0240, 0010, 0240, 3380)        // Linha do Topo
	oPrint:Line (0320, 0010, 0320, 3380)        // Linha do Topo
	oPrint:Say  (0090, 0400, Space(20)+"GERENCIAMENTO DE ORDENS DE PRODU??O", oFont20b)

	oPrint:Say  (0100, 3200, '('+cOpcao+')', oFont30)
	oPrint:Say  (0130, 3200, DtoC(Date()), oFont30)
	oPrint:Say  (0160, 3200, Time(), oFont30)
	oPrint:Say  (0190, 3200, "P?gina:  " + AllTrim(Str(nPagina,3)), oFont30)

	oPrint:Say( 0260, 0025, "OP" 		, oFont08b)
	oPrint:Say( 0260, 0220, "Produto" 	, oFont08b)
	oPrint:Say( 0260, 0430, "Descri??o" , oFont08b)
	oPrint:Say( 0260, 0910, "Cliente"  	, oFont08b)
	oPrint:Say( 0260, 1500, "Veiculo"   , oFont08b)
	oPrint:Say( 0260, 1710, "Recurso"   , oFont08b)

	oPrint:Say( 0260, 2430, "Emiss?o"   , oFont08b)
	oPrint:Say( 0260, 2600, "Entr.Prev" , oFont08b)
	oPrint:Say( 0260, 2770, "Entr.Real" , oFont08b)
	oPrint:Say( 0260, 2950, "Qtd.Orig"  , oFont08b)
	oPrint:Say( 0260, 3100, "Saldo a Entr"   , oFont08b)
	//oPrint:Say( 0260, 3160, "Status", oFont08b) //"ST"
	oPrint:Say( 0260, 3265, "Tipo"  , oFont08b)	//"TP"

Return(320)


/*/{Protheus.doc} FMarkAll
Fun??o que ir? marcar ou Desmarcar todas as op??es na tela
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 30/12/2021
@param aLista, array, Listagem do que ser? marcado ou desmarcado
/*/
Static Function FMarkAll(aLista)
	
	Local nX := 0

	For nX := 1 To Len(aLista)
		aLista[nX][01] := .NOT. aLista[nX][01]
	Next

Return


/*/{Protheus.doc} ChkNumOP
Retorna um texto com o N?mero e o produto da OP posicionada na tela.
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 30/12/2021
@return character, Texto
/*/
Static Function ChkNumOP()
	
	Local cNumOP := ""
	cNumOP += 'NUM.OP:  '+ xFilial('SC2')+oList:aArray[oList:nAt][03]+CRLF
	cNumOP += 'PRODUTO: '+ oList:aArray[oList:nAt][08]

Return(cNumOP)


/*/{Protheus.doc} ChkEstrXQtd
EXPLODE ESTRUTURA \ VERIFICA QUANTIDADES
UTILIZADO PARA VERIFICAR SE EXISTE QTD SUFICIENTE DO "PRODUTO CLIENTE" EM ESTOQUE
"PRODUTO CLIENTE" NAO GERA EMPENHO PARA VERIFICAR QTD x ESTOQUE EXPLODE ESTRUTURA E BUSCA PRODUTO A PRODUTO E
VERIFICA O SEU SALDO ATUAL ISSO Eh FEITO PARA NAO TRAZER A OP JA MARCADA NO BROWSER (OP MARCADA = PRONTA PARA PRODUZIR
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 30/12/2021
@param cOpcao, character, Op??o selecionada pelo usu?rio
@param aLista, array, Listagem
@param nI, numeric, Linha da posi??o do array
@param _cProdAtu, variant, Produto da OP
@param _cNumOPAtu, variant, N?mero da OP
/*/
Static Function ChkEstrXQtd(cOpcao, aLista, nI, _cProdAtu, _cNumOPAtu)

	Local aArea		 :=	GetArea()
	Local lProduzir  :=	.F.
	Local nPProd	 :=	08
	Local nPosOP     :=	03
	Local nX		 := 0
	Local nS		 := 0
	Local nE		 := 0
	Local nH		 := 0

	Private nEstru 	 :=	0
			aSaldo 	 := {}

	Default _cProdAtu  := ''
	Default _cNumOPAtu := ''

	DbSelectArea('SB2');DbSetOrder(1);DbGoTop()	//	B2_FILIAL+B2_COD+B2_LOCAL
	IIF(Empty(Alias()).Or.Select('SG1')==0, (ChkFile('SG1'),DbSelectArea('SG1')),)

	If cOpcao == 'BTN'
		cProdOP := oList:aArray[oList:nAt][nPProd]
		cNumOP 	:= oList:aArray[oList:nAt][nPosOP]
	ElseIf cOpcao == 'LISTA_FALTA'
		cProdOP := _cProdAtu
		cNumOP 	:= _cNumOPAtu
	Else
		cProdOP := aLista[nI][nPProd]
		cNumOP 	:= aLista[nI][nPosOP]
	EndIf

	aEstruG1 :=	Estrut(cProdOP)

	//????????????????????????????????????Ŀ
	//? VERIFICA ESTRUTURA X SALDO ESTOQUE ?
	//??????????????????????????????????????
	For nX := 1 To Len(aEstruG1)    

		nNivel	 := aEstruG1[nX][01]
		cProdSG1 := aEstruG1[nX][02]
		cCompSG1 := aEstruG1[nX][03]
		nQtdSG1	 := IIF(aEstruG1[nX][04] > 0, aEstruG1[nX][04], Posicione('SG1',1,xFilial('SG1')+cProdSG1+cCompSG1,'G1_QUANT')) 
		
		//?????????????????????????????????Ŀ
		//? aSALDO PRODUTO ESTRUTURA - [01] ?
		//???????????????????????????????????
		If Ascan(aSaldo, {|X| AllTrim(X[01]) == AllTrim(cProdSG1) }) == 0
				
			cFantasma := IIF(Posicione('SB1',1,xFilial('SB1')+cProdSG1,'B1_FANTASM')=='S','FANTASMA','')
			cFilhoPai := IIF(nX==1, 'PROD_INI_ESTRUT', IIF(Ascan(aEstruG1, {|X| AllTrim(X[01]) == cProdSG1}) > 0, 'PAI', 'FILHO'	))
			cPaiFilho := IIF(nX==1, '', 				IIF(Ascan(aEstruG1, {|X| AllTrim(X[02]) == cCompSG1}) > 0, 'PAI', ''		))
			cHeranca  := cFilhoPai+IIF(!Empty(cPaiFilho),';'+cPaiFilho,'')
			
			cCodFilho := IIF(nX==1, '', cCompSG1)
			cLocPad	  := Posicione('SB1',1,xFilial('SB1')+cProdSG1,'B1_LOCPAD')+'/01'

			If SB2->(DbSeek(xFilial('SB2') + cProdSG1 + cLocPad, .F.))
				Do While !Eof() .And. xFilial('SB2') == SB2->B2_FILIAL .And. AllTrim(cProdSG1) == AllTrim(SB2->B2_COD)
					
					If AllTrim(SB2->B2_LOCAL) $ AllTrim(cLocPad)              
					
						cSaldo 	:= 	'{'+AllTrim(SB2->B2_LOCAL)+';'+AllTrim(Str(SaldoSB2()))+'}'		//+AllTrim(Transform(SaldoSB2(),"@R 999.999,99"))+'}'
						
						nPos 	:=	Ascan(aSaldo, {|X| AllTrim(X[01]) == AllTrim(SB2->B2_COD) })
						If nPos == 0
							Aadd(aSaldo, {cProdSG1, cHeranca, cCodFilho, cSaldo, nQtdSG1, Nil})
						Else
							aSaldo[nPos][04] += cSaldo
						EndIf
					EndIf
					
					DbSelectArea('SB2')
					DbSkip()
				EndDo
			EndIf

		EndIf


		//????????????????????????????????????Ŀ
		//? aSALDO COMPONENTE ESTRUTURA - [01] ?
		//??????????????????????????????????????			
		If Ascan(aSaldo, {|X| AllTrim(X[01]) == AllTrim(cCompSG1) }) == 0   

			cFantasma := IIF(Posicione('SB1',1,xFilial('SB1')+cCompSG1,'B1_FANTASM')=='S','FANTASMA','')
			cFilhoPai := 'FILHO'
			cPaiFilho := IIF(Ascan(aEstruG1, {|X| AllTrim(X[02]) == AllTrim(cCompSG1) }) > 0, 'PAI', '')
			cHeranca  := cFilhoPai+IIF(!Empty(cPaiFilho),';'+cPaiFilho,'')
					
			cLocPad	  := Posicione('SB1',1,xFilial('SB1')+cCompSG1,'B1_LOCPAD')+'/01'

			If SB2->(DbSeek(xFilial('SB2') + cCompSG1 + cLocPad, .F.))
				Do While !Eof() .And. xFilial('SB2') == SB2->B2_FILIAL .And. AllTrim(cCompSG1) == AllTrim(SB2->B2_COD)
					
					If AllTrim(SB2->B2_LOCAL) $ AllTrim(cLocPad) 
					
						cSaldo 	:= 	'{'+AllTrim(SB2->B2_LOCAL)+';'+AllTrim(Str(SaldoSB2()))+'}'	//	+AllTrim(Transform(SaldoSB2(),"@R 999.999,99"))+'}'
						
						nPos 	:=	Ascan(aSaldo, {|X| AllTrim(X[01]) == AllTrim(SB2->B2_COD) })
						If nPos == 0
							Aadd(aSaldo, {cCompSG1, cHeranca, cProdSG1, cSaldo, nQtdSG1, Nil})
						Else
							aSaldo[nPos][04] += cSaldo
						EndIf
					EndIf
					
					DbSelectArea('SB2')
					DbSkip()
				EndDo

			ElseIf SB2->(DbSeek(xFilial('SB2') + cCompSG1 /*+ cLocPad*/, .F.))
				
				cSaldo 	:= 	'{'+AllTrim(SB2->B2_LOCAL)+';'+AllTrim(Str(SaldoSB2()))+'}'	//+AllTrim(Transform(SaldoSB2(),"@R 999.999,99"))+'}'
				
				nPos 	:=	Ascan(aSaldo, {|X| AllTrim(X[01]) == AllTrim(SB2->B2_COD) })
				If nPos == 0
					Aadd(aSaldo, {cCompSG1, cHeranca, cProdSG1, cSaldo, nQtdSG1, Nil})
				Else
					aSaldo[nPos][04] += cSaldo
				EndIf			
			EndIf

		EndIf

	Next


	//?????????????????????????????????????????????????????????????????????????????????????????Ŀ
	//? VERIFICA NOS FILHOS SE EXISTE QUANT DISPONIVEL PARA PRODUZIR PAI (PRODUTO DE CLIENTES)	?
	//???????????????????????????????????????????????????????????????????????????????????????????
	For nS:=1 To Len(aSaldo)

		//					[01]	  [02]       [03]     [04]   [05]     [06]
		//	Aadd(aSaldo, {cProdSG1, cHeranca, cCodFilho, cSaldo, nQtdSG1, Nil})
		//	Aadd(aSaldo, {cCompSG1, cHeranca, cProdSG1,  cSaldo, nQtdSG1, Nil})
		cCodComp  := aSaldo[nS][01]
		cHeranca  := aSaldo[nS][02]	
		cCodProd  := aSaldo[nS][03]
		nEstLoc   := 0

		//?????????????????????????????????????????????????????????????????????????Ŀ
		//|  PROD_INI_ESTRUT = 1o ITEM DA ESTUTURA									|
		//?  aSaldo[nS][06] != Nil IDENTIFICA QUE ITEM DO ARRAY JA FOI PROCESSADO 	?
		//???????????????????????????????????????????????????????????????????????????
		If cHeranca == 'PROD_INI_ESTRUT' .Or. aSaldo[nS][06] != Nil
		
			If cHeranca == 'PROD_INI_ESTRUT'
				aSaldo[nS][06] := .T.	// FLAG PARA NAO VERIFICAR 1o ITEM DA ESTRUTURA
			EndIf
					
			Loop
		EndIf
		
		aHeranca  := StrTokArr(aSaldo[nS][02],";")	// SE Eh FILHO ou PAI
		For nH:=1 To Len(aHeranca)
			
			If aSaldo[nS][06] != Nil
				Loop // PARA NAO PROCESSAR O ITEM PAI QUE JA FOI VERIFICADO
			EndIf
		
			nQtdSG1	 := aSaldo[nS][05]
			aEstoque := StrTokArr(aSaldo[nS][04],"{}")  
			nQtdSB2  :=	0
			nPriSaldo:=	0
			cPriLoc  :=	''
			For nE:=1 To Len(aEstoque)        
				aEstSB2 := 	StrTokArr(aEstoque[nE],";")
				cLocSB2	:=	aEstSB2[01]
				nQtdSB2 += 	IIF(Len(aEstSB2)>=2, Val(aEstSB2[02]), 0)

				cPriLoc		:=	IIF(Empty(cPriLoc), cLocSB2, cPriLoc)
				nPriSaldo	:=	IIF(nPriSaldo==0, nQtdSB2, nPriSaldo)
				ChkSaldoDisp('PESQUISA', cCodComp, cLocSB2, nQtdSB2, 0, cNumOP)
			Next


			//aSaldo[nS][06] := IIF(nQtdSB2 >= nQtdSG1, .T., .F.)	// 	ATUALIZA FLAG INFO QDT.DISP SUFICIENTE PARA PRODUZIR OP
			aSaldo[nS][06] := ChkSaldoDisp('VALIDA_OPxSALDO', cCodComp, cPriLoc, nPriSaldo, 0, cNumOP)

			If Ascan(aHeranca, 'PAI') > 0 .And. !aSaldo[nS][06]	// 	SE NAO TEM QTD.SUFICIENTE NO FILHO E ITEM Eh PAI DE OUTROS COMPONENTES VERIFICO 
																	//	NOS FILHOS SE TEM QUANT.SUFICIENTE PARA PRODUZIR O SEU PAI
				//?????????????????????????????????????????????????????????????????????Ŀ
				//? VERIFICA NOS FILHOS SE EXISTE QUANT DISPONIVEL PARA PRODUZIR PAI	|
				//???????????????????????????????????????????????????????????????????????
				nQtdPaiSG1		:= aSaldo[nS][05]		// 	QTD PAI
				lQtdDispFilhos 	:=	.T.					//	FLAG VERIFICA SE ALGUMA QTD DO(s) FILHO(s) Eh OU NAO SUFICIENTE
				Do While .T.
					nPosFilho := Ascan(aSaldo, {|X| X[03] == cCodComp .And. X[06] == Nil })	// PESQUISA CODIGO DO COMPONENTE COMO PAI
					If nPosFilho > 0
		
						cCodFilho := aSaldo[nPosFilho][01]
						aEstoque  := StrTokArr(aSaldo[nPosFilho][04],"{}")
						nQtdFilho := aSaldo[nPosFilho][05]
						nQtdSB2	  := 0
						nPriSaldo := 0
						cPriLoc   := ''
						
						For nE:=1 To Len(aEstoque)
							aEstSB2 := 	StrTokArr(aEstoque[nE],";")  
							cLocSB2	:=	aEstSB2[01]
							nQtdSB2 += 	Val(aEstSB2[02])
							
							cPriLoc		:=	IIF(Empty(cPriLoc), cLocSB2, cPriLoc)
							nPriSaldo	:=	IIF(nPriSaldo==0, nQtdSB2, nPriSaldo)
							ChkSaldoDisp('PESQUISA',cCodComp, cLocSB2, nQtdSB2, 0, cNumOP)	
						Next

						//aSaldo[nPosFilho][06]	:=	IIF(nQtdSB2 >= nQtdFilho, .T., .F.)
						aSaldo[nPosFilho][06]	:=	ChkSaldoDisp('VALIDA_OPxSALDO', cCodComp, cPriLoc, nPriSaldo, 0, cNumOP)
						lQtdDispFilhos         	:= 	IIF(lQtdDispFilhos, aSaldo[nPosFilho][06], lQtdDispFilhos)	//	FLAG VERIFICA SE EXISTE QTD.FILHOS SUFICIENTES PARA PRODUZIR PAI
					
					Else
						aSaldo[nS][06] := lQtdDispFilhos
						Exit
					EndIf

				EndDo

			EndIf

		Next

		

		//??????????????????????????????????????????????????????????????????????????????????????????????Ŀ
		//?  NAO ENCONTROU NENHUM ELEMENTO[06] == Nil SIGNIFICA QUE TODOS OS ITENS JA FORAM PROCESSADOS  ?
		//????????????????????????????????????????????????????????????????????????????????????????????????
		If Ascan(aSaldo, {|X| X[06] == Nil }) == 0
			Exit
		EndIf

	Next


	//???????????????????????????????????????????????????????????Ŀ
	//?  VERIFICA SE EXISTE ALGUM ITEM DA ESTRUTURA QUE NAO TENHA ?
	//?  QUANT SUFICIENTE PARA PRODUZIR A ORDEM DE PRODUCAO       ?
	//?????????????????????????????????????????????????????????????
	lProduzir := IIF(Ascan(aSaldo, {|X| X[06] == .F. }) > 0, .F., .T.)

	// VERIFICA EstrutXSaldo() PQ COMPARA QTD.ESTUTURA X QTD.ESTOQUE X QTD.OP
	If cOpcao != 'BTN'
		If cOpcao == 'LISTA_FALTA'
			lProduzir := EstrutXSaldo('LISTA_FALTA', aLista, nI)	//----IIF(!lProduzir, EstrutXSaldo('LISTA_FALTA', aLista, nI), lProduzir)	
		Else
			lProduzir := EstrutXSaldo('CHK_PRODUZIR', aLista, nI) // UTILIZAR EstrutXSaldo PQ   NAO VERIFICA QTD.OP X QTD.EMPENHO 
		EndIf
	EndIf

	RestArea(aArea)

Return(lProduzir)


/*/{Protheus.doc} EstrutXSaldo
MONTA BROWSER COM A ESTRUTURA DO PRODUTO E VERIFICA SE EXISTE QUANTIDADE SUFICIENTE PARA PRODUZIR OP VERIFICA PRODUTO ALTERNATIVO 
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 30/12/2021
@param cOpcao, character, Op??o seleciionada pelo usu?rio
@param aLista, array, Listagem
@param nI, numeric, Posi??o da linha do array
/*/
Static Function EstrutXSaldo(cOpcao, aLista, nI)

	Local nQtdAProd	 :=	0
	Local nQtdBaseEst:=	0
	Local nY 		 :=	0
	Local nX 		 :=	0
	Local nE 		 :=	0
	Local aConteudo  :=	{}
	Local aTMD4OP    := TamSx3('D4_OP')
	Local nPProd	 :=	08
	Local nPQtdOP	 :=	06
	Local nPQtdEnt	 := 07
	Local nPNumOp 	 := 03

	Local nQuantOP	 := IIF(cOpcao!='CHK_PRODUZIR', oList:aArray[IIF(cOpcao=='LISTA_FALTA',nI,oList:nAt)][nPQtdOP],	aLista[nI][nPQtdOP]	)
	Local nQtdJEnt	 := IIF(cOpcao!='CHK_PRODUZIR', oList:aArray[IIF(cOpcao=='LISTA_FALTA',nI,oList:nAt)][nPQtdEnt],	aLista[nI][nPQtdEnt])
	Local cProdSelec := IIF(cOpcao!='CHK_PRODUZIR', oList:aArray[IIF(cOpcao=='LISTA_FALTA',nI,oList:nAt)][nPProd], 	aLista[nI][nPProd] 	)
	Local nPos 		 := Ascan(aSaldo, {|X| AllTrim(X[01]) = AllTrim(cProdSelec)})
	Local cOPSelec	 := IIF(cOpcao!='CHK_PRODUZIR', oList:aArray[IIF(cOpcao=='LISTA_FALTA',nI,oList:nAt)][nPNumOp],	aLista[nI][nPNumOp]	)

	Local lProduzir	 :=	.T.      
	Default cOpcao	 :=	''


	If nPos > 0

		cUltPai:= ''
		For nX :=1 To Len(aSaldo)      

			cPai	:=	IIF(aSaldo[nX][02] == 'PROD_INI_ESTRUT', aSaldo[nX][01], aSaldo[nX][03])
			cFilho	:=	IIF(aSaldo[nX][02] != 'PROD_INI_ESTRUT', aSaldo[nX][01], '')


			aQtdLoc  := StrTokArr(aSaldo[nX][04],"{}")  
			cQtdLoc	 := ''
			For nY:=1 To Len(aQtdLoc)		
				aArray  := StrTokArr(aQtdLoc[nY],";") 
				_cLocal := IIF(Len(aArray)>=1, AllTrim(aArray[01]), '')
				_cQuant := IIF(Len(aArray)>=2, AllTrim(aArray[02]), '')
				cQtdLoc += 'Local: '+_cLocal+' Quant: '+_cQuant+' | '
			Next
			cQtdLoc		:=	Left(cQtdLoc, Len(AllTrim(cQtdLoc))-1)
															
			If aSaldo[nX][02] == 'PROD_INI_ESTRUT'
				nQtdEstrut 	:=	Posicione('SG1',1,xFilial('SG1')+cPai,'G1_QUANT')  // G1_FILIAL+G1_COD+G1_COMP+G1_TRT
			Else
				nQtdEstrut 	:=	aSaldo[nX][05]
			EndIf
			
																
			cProdEstrut := 	IIF(aSaldo[nX][02] == 'PROD_INI_ESTRUT', cPai, cFilho)
			cDescr		:=	AllTrim(Posicione("SB1",1,xFilial("SB1")+cProdEstrut,"B1_DESC"))
			nPesq := Ascan(aConteudo,{|X| AllTrim(X[01]) == AllTrim(cPai)})
			If nPesq > 0
				If AllTrim(aConteudo[nPesq][01]) == AllTrim(cUltPai)
					cPai 	 := ' || '
				EndIf
			EndIf
			cUltPai := IIF(cPai==' || ', cUltPai, cPai)
			
		
			lAlternativo := .F.
			
			If aSaldo[nX][02] == 'PROD_INI_ESTRUT'
				SB1->(DbSetOrder(1),DbSeek(xFilial('SB1') + cPai))		//	QTD BASE ESTRUTURA
				nQtdBaseEst := 	SB1->B1_QB
				nQtdAProd 	:=	(nQuantOP - nQtdJEnt)					//	QTD A PRODUZIR
				nQtdNecess	:=	''
				nQtdEstrut 	:= 	''
				nQtdEmp 	:= 	''

			Else                 

				lChkAlter 	:= .F.
				
				DbSelectArea('SD4');DbSetOrder(2)		//	D4_FILIAL+D4_OP+D4_COD+D4_LOCAL
				If DbSeek(xFilial('SD4') + PadR(cOPSelec, aTMD4OP[01],'') + cFilho /*+ cAlmox, .F.*/ )

					nQtdEmp		:=	SD4->D4_QUANT
					nQtdAProd 	:=	(nQuantOP - nQtdJEnt)
					nQtdNecess 	:=  nQtdAProd * nQtdEstrut

					aEstoque  := StrTokArr(aSaldo[nX][04],"{}")
					nQtdSB2	  := 0
					nPriSaldo := 0
					cPriLoc   := ''
					For nE:=1 To Len(aEstoque)
						aEstSB2 := 	StrTokArr(aEstoque[nE],";")  
						cLocSB2	:=	aEstSB2[01] 
						nQtdSB2 += 	IIF(Len(aEstSB2)>=2, IIF(valType(aEstSB2[02])=='C',Val(aEstSB2[02]), aEstSB2[02]), 0)
						
						cPriLoc		:=	IIF(Empty(cPriLoc), cLocSB2, cPriLoc)
						nPriSaldo	:=	IIF(nPriSaldo==0, nQtdSB2, nPriSaldo)
						ChkSaldoDisp('PESQUISA', cFilho, cLocSB2, nQtdSB2, nQtdEmp, cOPSelec)	
					Next

					// aSaldo[nX][06] := 	IIF(nQtdNecess > nQtdSB2, .F., .T.)
					aSaldo[nX][06]	:= 	ChkSaldoDisp('VALIDA_OPxSALDO', cFilho, cPriLoc, nPriSaldo, nQtdEmp, cOPSelec)
					lChkAlter 		:= 	IIF(!aSaldo[nX][06], .T., .F.)
				
				Else
					nQtdNecess 	:= ((nQuantOP - nQtdJEnt) * nQtdEstrut)
					nQtdEmp	   	:=	0
					lChkAlter 	:= .T.
				EndIf
				
				
				//????????????????????????????????Ŀ
				//?  VERIFICA PRODUTO ALTERNATIVO  ?
				//??????????????????????????????????
				If lChkAlter
					DbSelectArea('SGI');DbSetOrder(1)		//	GI_FILIAL+GI_PRODORI+GI_ORDEM+GI_PRODALT
					If DbSeek(xFilial('SGI') + cFilho, .F.)

						DbSelectArea('SD4');DbSetOrder(2)		//	D4_FILIAL+D4_OP+D4_COD+D4_LOCAL
						If DbSeek(xFilial('SD4') + PadR(cOPSelec, aTMD4OP[01],'') + SGI->GI_PRODALT, /*.F.*/ )
							nQtdEmp := SD4->D4_QUANT
										
							DbSelectArea('SB2');DbSetOrder(1)	//	B2_FILIAL+B2_COD+B2_LOCAL
							If DbSeek(xFilial('SB2') + SGI->GI_PRODALT )

								nSaldoSB2 	:= 	SaldoSB2()
								nQtdAProd 	:=	(nQuantOP - nQtdJEnt)
								nQtdNecess 	:=  nQtdAProd * nQtdEstrut
								
								
								//					[01]	  [02]       [03]     [04]   [05]     [06]
								//	Aadd(aSaldo, {cProdSG1, cHeranca, cCodFilho, cSaldo, nQtdSG1, Nil})
								//	Aadd(aSaldo, {cCompSG1, cHeranca, cProdSG1,  cSaldo, nQtdSG1, Nil})  									
								aSaldo[nX][03] 	:= 	SGI->GI_PRODALT
								
								If Empty(SB2->B2_LOCAL)
									cLocPesq := AllTrim(Posicione("SB1",1,xFilial("SB1")+SGI->GI_PRODALT,"B1_LOCPAD"))
									If DbSeek(xFilial('SB2') + SGI->GI_PRODALT + cLocPesq, .F.)
										cLocAlt	:=	SB2->B2_LOCAL
									Else
										cLocAlt	:=	'XX'
									EndIf
								Else
									cLocAlt	:=	SB2->B2_LOCAL
								EndIf
								
								aSaldo[nX][04] 	:= 	'{'+AllTrim(cLocAlt)+';'+AllTrim(Str(nSaldoSB2))+'}'

								aSaldo[nX][06] 	:= 	ChkSaldoDisp('VALIDA_OPxSALDO',SGI->GI_PRODALT, SB2->B2_LOCAL, nSaldoSB2, nQtdEmp, cOPSelec)
								lAlternativo	:=	.T.
								cQtdLoc 		:= 	'Local: '+AllTrim(SB2->B2_LOCAL)+' Quant: '+AllTrim(Str(nSaldoSB2))	//	+AllTrim(Transform(nSaldoSB2,"@R 999.999,99"))
											
								cDescr			+=	' (Alternativo: '+AllTrim(SGI->GI_PRODALT)+' - '+AllTrim(Posicione("SB1",1,xFilial("SB1")+SGI->GI_PRODALT,"B1_DESC"))+')'

							EndIf

						EndIf

					EndIf
				EndIf

			EndIf


			cAtende		:=	IIF(aSaldo[nX][06],'SIM','N?O')

			// SE PRODUTO NAO TEM ESTOQUE VERIFICA SE PI ATENDE
			If cAtende == 'N?O'                                         
				cProdPI:= aSaldo[nX][03]
				nPosPI := Ascan(aSaldo, {|X| AllTrim(X[01]) == AllTrim(cProdPI) })
				If nPosPI > 0
					If aSaldo[nPosPI][06] .And. Alltrim(aSaldo[nPosPI][02]) == 'FILHO;PAI'
						cAtende			:= 	'PI'
						aSaldo[nX][06] 	:= 	.T.
					EndIf
				EndIf
			EndIf
			
			cLocxSB2:=	aSaldo[nX][04]
			cFantF 	:= 	IIF(lAlternativo,'', IIF(Posicione('SB1',1,xFilial('SB1')+cFilho,'B1_FANTASM')=='S',' (Fantasma)',''))
			Aadd(aConteudo, {cPai, cFilho, cDescr+cFantF, nQtdEstrut, cAtende, cQtdLoc, nQtdNecess, cLocxSB2/*, nQtdEmp*/ })

		Next

	EndIf



	If !(cOpcao $ 'CHK_PRODUZIR\LISTA_FALTA')

		If Len(aConteudo) > 0
		
			Define Dialog oDlgDiv Title "Estrutura Produto X Saldo" From 120,120 To 360,960 Pixel 
			
				oFont1	:= TFont():New( "Arial",0,16,,.T.,0,,700,.F.,.F.,,,,,, )
				oBrowse := TcBrowse():New(010, 001, 420, 093,,{'Codigo','Componente','Descri??o','Quant.Estrut','Qtd.OP x Estr.','Atende','Saldo'/*,'Qtd.Emp'*/},{/*50,50,50*/},oDlgDiv,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
				oBrowse:SetArray(aConteudo)
			
				oBrowse:AddColumn( TcColumn():New('Codigo'			,{|| aConteudo[oBrowse:nAt][01] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
				oBrowse:AddColumn( TcColumn():New('Componente'		,{|| aConteudo[oBrowse:nAt][02] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
				oBrowse:AddColumn( TcColumn():New('Descri??o'		,{|| aConteudo[oBrowse:nAt][03] },,,,"LEFT",,.F.,.T.,,,,.F.,) )	    
				oBrowse:AddColumn( TcColumn():New('Quant.Estrut'	,{|| aConteudo[oBrowse:nAt][04] },,,,"CENTER",,.F.,.T.,,,,.F.,))
				oBrowse:AddColumn( TcColumn():New('Qtd.Estr X OP'	,{|| aConteudo[oBrowse:nAt][07] },,,,"CENTER",,.F.,.T.,,,,.F.,))
				oBrowse:AddColumn( TcColumn():New('Atende'			,{|| aConteudo[oBrowse:nAt][05] },,,,"CENTER",,.F.,.T.,,,,.F.,))
				oBrowse:AddColumn( TcColumn():New('Saldo'			,{|| aConteudo[oBrowse:nAt][06] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
				//oBrowse:AddColumn( TcColumn():New('Qtd.Emp'			,{|| aConteudo[oBrowse:nAt][08] },,,,"RIGHT",,.F.,.T.,,,,.F.,) )
				
				cNumOP 	 := Left(cOPSelec,06)+'.'+SubStr(cOPSelec,07,02)+'.'+Right(cOPSelec,03)
				cQtdOP	 :=	AllTrim(Str(nQuantOP - nQtdJEnt))
				oSayOP   := TSay():New( 110, 002,{||"Ordem Produ??o:  "+cNumOP+" |  QTD.: "+cQtdOP},oDlgDiv,,oFont1,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,200,008)

				oBtnSG1	 :=	TButton():New( 108, 140, '&Estrutura',  oDlgDiv,{|| ViewSG1(cProdSelec) },30,010,,,.F.,.T.,.F.,,.F.,,,.F.)
				oBtnChk	 :=	TButton():New( 108, 190, '&Utilizado',  oDlgDiv,{|| ChkSC2xSD4xSB2(cProdSelec, aConteudo[oBrowse:nAt][02], aConteudo[oBrowse:nAt][03]) },032,010,,,.F.,.T.,.F.,,.F.,,,.F.)
				oBtnSair := TButton():New( 108, 378, '&Voltar',   oDlgDiv,{|| oDlgDiv:End() },030,010,,,.F.,.T.,.F.,,.F.,,,.F.)
		
		
			Activate Dialog oDlgDiv Centered
		
		Else
			Alert('N?o h? dados para apresentar.')
		EndIf

	Else
		//	Aadd(aConteudo, {cPai, cFilho, cDescr, nQtdEstrut, cAtende, cQtdLoc, nQtdNecess/*, nQtdEmp*/ })
		If cOpcao $ 'BTN\CHK_PRODUZIR'
			lProduzir := IIF(Ascan(aConteudo, {|X| X[05] == 'N?O'}) > 0, .F., .T.)
		ElseIf cOpcao == 'LISTA_FALTA'
			lProduzir := aConteudo
		EndIf
	EndIf
	
Return(lProduzir)


/*/{Protheus.doc} ChkOpMark
Carrega um array ordenado
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 30/12/2021
@return array, Dados ordenados
/*/
Static Function ChkOpMark()

	Local aRetorno	:= {.F.,{}}
	Local aOpMark 	:= {}
	Local aArray 	:= {}
	Local nX		:= 0
	Local nPMarca	:= 01
	Local nPOP		:= 03
	Local nPProd	:= 08
	Local nPDtOP	:= 20
	Local nPTpOp	:= 31               
						
	For nX:=1 To Len(oList:aArray)
		If oList:aArray[nX][nPMarca] .And. Left(AllTrim(oList:aArray[nX][nPTpOp]),01) == 'F'
			Aadd(aArray, {oList:aArray[nX][nPDtOP], oList:aArray[nX][nPOP], oList:aArray[nX][nPProd] })
		EndIf
	Next

	If Len(aArray) > 0
		
		// MENOR DATA
		aSort(aArray,,, {|X,Y| X[1] < Y[1]})
		Aadd(aOpMark, aArray[01][01])
		// MAIOR DATA
		aSort(aArray,,, {|X,Y| X[1] > Y[1]})
		Aadd(aOpMark, aArray[01][01])
		
		// MENOR OP
		aSort(aArray,,, {|X,Y| X[2] < Y[2]})
		Aadd(aOpMark, aArray[01][02])
		// MAIOR OP
		aSort(aArray,,, {|X,Y| X[2] > Y[2]})
		Aadd(aOpMark, aArray[01][02])

		For nX:=1 To Len(aArray)
			Aadd(aOpMark, {aArray[nX][02], aArray[nX][03]})
		Next
		
		aRetorno[01] := .T.
		aRetorno[02] :=	aOpMark
		
	Else
		MsgAlert('Nenhuma OP - Firme selecinada.  Verifique.')    
	EndIf

Return(aRetorno)



/*/{Protheus.doc} NewListFalta
Fun??o que gera a impress?o da lista de faltas de MP
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 30/12/2021
@param _aEmpenho, array, Empenhos
@param aLista, array, Listagem que ser? impressa
/*/
Static Function NewListFalta(_aEmpenho,aLista)

	Local aTMD4OP      := TamSx3('D4_OP')
	Local nI		   := 0
	Local nX		   := 0
	Local nE		   := 0
	Local nOpcao       := 0
	Local cFilSB1	   := FWFilial("SB1")
	Local lTela		   := .F.
	Local lSelec	   := .F.

	Private aObs       := {}
	Private _nLin      := 0
	Private _nQuant    := 0
	Private _nTot      := 0
	Private _nIpi      := 0
	Private _nTamLin   := 80
	Private _nLimVert  := 2300
	Private _nVia      := 1
	Private _nPagina   := 1
	Private _nIniLin   := 0
	Private _nCotDia   := 1
	Private _nMoeda    := 1
	Private cObs       := ""
	Private _cPrevisao := ""
	Private _cPrazoPag := ""
	Private _dCotDia   := DtoS( dDataBase )
	Private oPrint, oFont08, oFont08b, oFont09, oFont09b, oFont10, oFont10b, oFont12, oFont12b, oFont14b, oFont16b, oFont20, oFont30

	nOpcao := Aviso('Impress?o Lista de Falta',CRLF+"IMPRIMIR TODAS OP's DA TELA ou APENAS OP(s) SELECIONADA(s)",{'Selecionadas',"TODAS OP's",'Sair'}, 2)

	If nOpcao == 1
		lSelec	:=	.T. 
		cOpcao := '( Selecionadas )'
	ElseIf nOpcao == 2
		lTela	:=	.T.
		cOpcao := "( TODAS OP's )"
	Else
		Return()
	EndIf

	oPrint := TmsPrinter():New()
	oPrint:SetLandScape() 	// Para Paisagem
	oPrint:SetPaperSize(9)	// A4

	oFont06   := TFont():New( "Arial",,06,,.f.,,,,.f.,.f. )
	oFont08   := TFont():New( "Arial",,08,,.f.,,,,.f.,.f. )
	oFont08b  := TFont():New( "Arial",,08,,.t.,,,,.f.,.f. )
	oFont09   := TFont():New( "Arial",,09,,.f.,,,,.f.,.f. )
	oFont09b  := TFont():New( "Arial",,09,,.t.,,,,.f.,.f. )
	oFont10   := TFont():New( "Arial",,10,,.f.,,,,.f.,.f. )
	oFont10b  := TFont():New( "Arial",,10,,.t.,,,,.f.,.f. )
	oFont12   := TFont():New( "Arial",,12,,.f.,,,,.f.,.f. )
	oFont12b  := TFont():New( "Arial",,12,,.t.,,,,.f.,.f. )
	oFont14b  := TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
	oFont16b  := TFont():New( "Arial",,16,,.t.,,,,.f.,.f. )
	oFont20b  := TFont():New( "Arial",,20,,.t.,,,,.f.,.f. )
	oFont30   := TFont():New( "Courier New",,8,,.t.,,,,.f.,.f. )

	// In?cio do relat?rio
	oPrint:StartPage()
	_nLin := GoNew1Page(cOpcao)

	nPMarca	:=	01		//	MARCADO
	nPosOP	:=	03		//	NUM.OP
	nPProd	:=	08		//	CODIGO PRODUTO
	nPCli	:=	05		//	NOME CLIENTE
	nPTpOp	:=	31		//	TIPO OP (PREVISTA \ FIRME)
	nPDescP	:=	09		//	DESCRICAO PRODUTO
	aOPxFalta := {}

	For nI := 1 To Len(aLista)  
		If aLista[nI][nPMarca] .Or. lTela
			If Left(aLista[nI][nPTpOp],01) == 'P'		//	SOMENTE LISTA FALTA QDO TIPO DA OP == PREVISTA
				Aadd(aOPxFalta, aLista[nI])
			EndIf
		EndIf
	Next

	_nSubtotal 	:= 	0
	lSubTotal	:=	.F.
	lTevePrint	:=	.F.
	cCodPrint	:=	''
	cLocPrint	:=	''

	aPrint		:=	{}
	aSaldoSB2	:=	{}	//	ARRAY COM QUANT DISP.NO ESTOQUE E QTD.JA UTILIZADA EM X OPs	
	//????????????????????????????????????????????????????????????????Ŀ
	//? Aadd(aSaldoSB2, {cG1Comp, cAlmox, nSaldoSB2,    nQtdEmp })     ?
	//?	Aadd(aSaldoSB2[nPos], {cNumOP, nQtdEmp})                       ?
	//?	PRODUTO 		[01]                                           ?
	//?	ALMOX			[02]                                           ?
	//?	SALDO ATUAL 	[03]                                           ?
	//?	QTD.UTILIZADA	[04]                                           ?
	//?		NUM.OP		[01][01]                                       ?
	//?		QTD.EMP		[01][02]	                                   ?
	//??????????????????????????????????????????????????????????????????

	DbSelectArea("SB1")
	DbSetOrder(1)

	For nI := 1 To Len(aOPxFalta)

		//	SOMENTE LISTA FALTA QDO TIPO DA OP == PREVISTA	

		nLinha		:=	Ascan(aLista, {|X| AllTrim(X[03]) == AllTrim(aOPxFalta[nI][03]) })
		cNumOP	 	:=	aOPxFalta[nI][nPosOP]
		cProdOP 	:=	aOPxFalta[nI][nPProd]
		cNomeCli	:=	Left(aOPxFalta[nI][nPCli], 30)
		cDescOProd 	:= 	Left(AllTrim(aOPxFalta[nI][nPDescP]), 52)

		//--->>>> PODE SUBSTITUIR A FUNCAO ChkEstrXQtd PELO ARRAY aEstDisp
		aEstrutura	:=	ChkEstrXQtd('LISTA_FALTA', aOPxFalta[nI], nLinha, cProdOP, cNumOP)
		If ValType(aEstrutura) == 'L'	//	.T. == QTD SUFICIENTE PARA PRODUZIR (TODOS OS ITENS DA ESTRUTURA TEM QTD.SUFIENTE EM ESTOQUE)
			Loop
		EndIf

		//aEstrutura := Aadd(aConteudo, {cPai, cFilho, cDescr, nQtdEstrut, cAtende, cQtdLoc, nQtdNecess, cLocxSB2/*, nQtdEmp*/ })

		For nE := 1 To Len(aEstrutura)
			
			lUltReg 	:= 	IIF(nE == Len(aEstrutura), .T., .F.)	
			cG1Codigo	:=	IIF(IsDigit(aEstrutura[nE][01]), aEstrutura[nE][01], '')
			cG1Comp		:=	aEstrutura[nE][02]
			nQtdOPxG1	:=	aEstrutura[nE][07] 
			cDescMP		:=	aEstrutura[nE][03] 
							
			If AllTrim(cG1Codigo) == AllTrim(cProdOP)
				Loop // PA
			EndIf
			
			
			// ARRAY COM PRODUTO E SALDO JA UTILIZADO... CASO OUTRA ESTRUTURA USE O MESMO PRODUTO E TAL....
			// PARA IR VERIFICANDO SE O SALDO AUTAL DO PRODUTO JA NAO FOI TODO "CONSUMIDO" 
			aEstoque 	:= 	StrTokArr(aEstrutura[nE][08],"{}")
			For nX := 1 To Len(aEstoque)

				// ANALISAR QDO TIVER + DE 1 ALMOX PARA O MESMO PRODUTO            

				aEstSB2   	:= 	StrTokArr(aEstoque[nX],";")  
				If Len(aEstSB2) < 2
					Alert('Problema com Local\Saldo do Produto!!!')
				EndIf
				cAlmox 		:= 	aEstSB2[01]
				nSaldoSB2	:=	Val(aEstSB2[02])
				nQtdEmp 	:= 	0
				DbSelectArea('SD4');DbSetOrder(2)		//	D4_FILIAL+D4_OP+D4_COD+D4_LOCAL
				If DbSeek(xFilial('SD4') + PadR(cNumOP, aTMD4OP[01],'') + cG1Comp + cAlmox, .F. )
					nQtdEmp :=  SD4->D4_QUANT
				EndIf

				nPos :=	Ascan(aSaldoSB2, {|X| X[01] == cG1Comp .And. X[02] ==  cAlmox})
				If nPos == 0
					//				   [01]     [02]       [03]      [04]
					//				 PRODUTO   ALMOX   SALDO ATUAL  QTD.UTILIZADA
					Aadd(aSaldoSB2, {cG1Comp, cAlmox, nSaldoSB2,    nQtdEmp })
					nPos := Len(aSaldoSB2)
					Aadd(aSaldoSB2[nPos], {cNumOP, nQtdEmp})
					
				Else
					aSaldoSB2[nPos][04]	+=	nQtdEmp
					Aadd(aSaldoSB2[nPos], {cNumOP, nQtdEmp})

				EndIf

				If nSaldoSB2 < nQtdOPxG1
					lFalta  := .T.
				Else
					nTotEmp	:=	aSaldoSB2[nPos][04]
					lFalta  :=	IIF(nTotEmp > nSaldoSB2, .T., .F.)
				EndIf
			Next
					
			
			If lFalta 
				//					   [01]			[02]			[03]		[04] 		   [05]			  [06]			  [07]	     [08]  [09]FLAG
				//aAdd(_aEmpenho, { EMP->D4_COD, EMP->D4_LOCAL, EMP->D4_OP, EMP->D4_DATA, EMP->D4_QUANT, EMP->D4_RESERV, EMP->D4_RESPED,  0   , '' })
				
				lTevePrint	:= .T.
				cCodPrint	:= cG1Comp
				cLocPrint	:= ''

				cCodMatPri	:= cG1Comp
				
				SB1->( DbSeek( cFilSB1 + cCodMatPri ) )
				cFantF 		:= IIF( SB1->B1_FANTASM == 'S', ' (F)', '' )
				cDescMP		:= AllTrim( SB1->B1_DESC ) + cFantF
				
				//cQtdEmp		:=	Transform(nQtdEmp,"@R 9,999,999.9999")// +IIF(_aSortEmp[_n][07] > 0,"(*)","")
				Aadd(aPrint, {cCodMatPri, cDescMP, cNumOP, nQtdEmp, cDescOProd, cNomeCli})
			EndIf

		Next
		
	Next

	//??????????????????????????Ŀ
	//?  IMPRIME LISTA DE FALTA  ?
	//????????????????????????????
	aSort(aPrint,,, {|X,Y| X[01] < Y[01]})
	For nX := 1 To Len(aPrint)

		// Aadd(aPrint, {cCodMatPri, cDescMP, cNumOP, cQtdEmp, cDescOProd, cNomeCli} )
		cCodMatPri	:=	aPrint[nX][01]
		cDescMP		:=	aPrint[nX][02]
		cNumOP		:=	Left(aPrint[nX][03],06)+'.'+SubStr(aPrint[nX][03],07,02)+'.'+Right(aPrint[nX][03],03)    
		nQtdEmp		:=	aPrint[nX][04]
		cDescOProd	:=	aPrint[nX][05]
		cNomeCli	:=	aPrint[nX][06]

		
		oPrint:Say( _nLin, 0110, cCodMatPri   	, oFont09)
		oPrint:Say( _nLin, 0400, cDescMP  		, oFont09)
		oPrint:Say( _nLin, 0960, cNumOP   		, oFont09)
		oPrint:Say( _nLin, 1210, Transform(nQtdEmp,"@R 9,999,999.9999"), oFont09)
		oPrint:Say( _nLin, 1800, cDescOProd  	, oFont09)
		oPrint:Say( _nLin, 2800, cNomeCli 		, oFont09)
		
		_nLin 		+= 	40
		_nSubtotal 	+= 	nQtdEmp
		
		If _nLin >= _nLimVert
			oPrint:EndPage() 
			_nLin := GoNew1Page(cOpcao)
		EndIf     
		
		lLast := IIF(Len(aPrint) == nX, .T., .F.)
		nNext := nX + IIF(!lLast, 01, 00)
		If cCodMatPri != aPrint[nNext][01] .Or. lLast
			NewGoSubTotal(cCodMatPri, aSaldoSB2, cOpcao, nX)
		EndIf

		If _nLin >= _nLimVert
			oPrint:EndPage() 
			_nLin := GoNew1Page(cOpcao)
		EndIf     

	Next

	oPrint:Preview()
	MS_FLUSH()

Return


/*/{Protheus.doc} NewGoSubTotal
Impress?o do Sub Total
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 30/12/2021
@param cCodPrint, character, C?digo para impress?o
@param aSaldoSB2, array, Saldo do SB2
@param cOpcao, character, Op??o selecionada pelo usu?rio 
@param nLnFor, numeric, Linha
/*/
Static Function NewGoSubTotal(cCodPrint, aSaldoSB2, cOpcao, nLnFor)

	Local aArea     := GetArea()
	Local nB2QPED   := 0
	Local nB2QEMP   := 0
	Local nSaldoSB2 := 0

	oPrint:Line (_nLin   , 0800, _nLin   , 1800) 
	_nLin += 15
	oPrint:Say( _nLin, 0110, cCodPrint+" - SUBTOTAL " , oFont09b)
	oPrint:Say( _nLin, 1210, Transform(_nSubTotal,"@R 9,999,999.9999") , oFont09b)

	// BUSCA QUANT.EMPENHO PREVISTO E SALDO PEDIDO (TOTAL DE TODOS OS ALMOX)
	_cSld := " SELECT SUM(B2_QATU) AS 'B2_QATU', SUM(B2_SALPEDI)  AS 'B2_SALPEDI',SUM(B2_QEMP)  AS 'B2_QEMP' FROM "+RetSqlName("SB2")"
	_cSld += " WHERE B2_FILIAL = '"+xFilial("SB2")+"'AND B2_COD = '"+cCodPrint+"' AND D_E_L_E_T_ = ' ' "
	dbUseArea( .T., "TOPCONN", TcGenQry(,,_cSld), "SLD", .T., .T. )
	If SLD->( .NOT. EOF() )
		nB2QPED := SLD->B2_SALPEDI
		nB2QEMP := SLD->B2_QEMP
	EndIf
	/*
	If SB2->(DbSeek(xFilial("SB2") + cCodPrint + cLocPrint, .F.))	// _cLocal:= '01'
		nSaldoSB2 := SaldoSB2()
	EndIf
	*/

	//				   [01]     [02]       [03]      [04]
	//				 PRODUTO   ALMOX   SALDO ATUAL  QTD.UTILIZADA
	//Aadd(aSaldoSB2, {cG1Comp, cAlmox, nSaldoSB2,    nQtdEmp })
	nPos := Ascan(aSaldoSB2, {|X| AllTrim(X[01]) == AllTrim(cCodPrint) })
	If nPos > 0
		nSaldoSB2 := aSaldoSB2[nPos][03]
	Else
		nSaldoSB2 := 0
	EndIf
					
	oPrint:Say( _nLin, 1400, "Sld Atual     : "+TransForm(nSaldoSB2,"@R 9,999,999.9999")  , oFont30)
	oPrint:Say( _nLin, 2000, "Empenhos Prev.: "+TransForm(nB2QEMP,"@R 9,999,999.9999")  , oFont30)
	_nLin += 40
	oPrint:Say( _nLin, 1400, "Prev Entrar   : "+TransForm(nB2QPED,"@R 9,999,999.9999")  , oFont30)


	cSql := " SELECT C7_FILIAL, C7_NUM, C7_QUANT, C7_QUJE , (C7_QUANT - C7_QUJE), C7_DATPRF 	"+CRLF
	cSql += " FROM 	"+RetSqlName("SC7")+" SC7					"+CRLF
	cSql += " WHERE SC7.C7_FILIAL 	=  '"+xFilial('SC7')+"'		"+CRLF
	cSql += " AND 	SC7.C7_PRODUTO	=  '"+cCodPrint+"'	   		"+CRLF
	cSql += " AND 	(SC7.C7_QUANT - SC7.C7_QUJE) > 0 			"+CRLF
	cSql += " AND 	SC7.C7_RESIDUO != 'S'						"+CRLF
	cSql += " AND 	SC7.D_E_L_E_T_ != '*'						"+CRLF
	cSql += " ORDER BY SC7.C7_DATPRF							"+CRLF

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),'TMPSC7',.T.,.T.)

	DbSelectArea('TMPSC7')
	DbGoTop()
	oPrint:Say( _nLin, 2000, "Dt Entrar : "+ DtoC(StoD(TMPSC7->C7_DATPRF)) , oFont30)

	_nLin += 60
	oPrint:Line (_nLin, 0100, _nLin, 3400)  
	_nSubTotal := 0

	IF _nLin >= (_nLimVert - 200) .and. nLnFor < Len(aOPxFalta)
		oPrint:EndPage() 
		_nLin := GoNew1Page(cOpcao)
	ENDIF

	SLD->(DbCloseArea())
	TMPSC7->(DbCloseArea())
	
	RestArea(aArea)

Return()


/*/{Protheus.doc} ViewSG1
Visualizar a Estrutura de Produto posicionado
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 30/12/2021
@param cProduto, character, C?digo do Produto
/*/
Static Function ViewSG1(cProduto)

	Local oExecView

	If Empty( cProduto )
		Return
	EndIf

	DbSelectArea('SG1')
	DbSetOrder(1)	// G1_FILIAL+G1_COD+G1_COMP+G1_TRT
	Dbseek(xFilial('SG1') + cProduto)

	oExecView := FWViewExec():New()
	oExecView:setSource("PCPA200")
	oExecView:setOperation(MODEL_OPERATION_VIEW)
	oExecView:openView(.T.)

	FreeObj( oExecView )

Return


/*/{Protheus.doc} ViewSC2
Visualizar a OP posicionada
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 30/12/2021
@param cOP, character, OP posicionada
/*/
Static Function ViewSC2( cOP )

	Local aArea := GetArea()
	Private cCadastro := "Visualizar Ordem de Produ??o"

	If Empty( cOP )
		Return
	EndIf

	A90SetKey( .F. )

	DbSelectArea("SC2")
	DbSetOrder(1)
	DbSeek( FWFilial("SC2") + cOP )
	
	Pergunte("MTA650", .F.)
	AxVisual( "SC2", Recno() )
	
	RestArea(aArea)
	
	A90SetKey( .T. )

Return


/*/{Protheus.doc} ChkSaldoDisp
Verifica o Saldo dispon?vel
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 30/12/2021
@param cOpcao, character, Op??o selecionada pelo usu?rio
@param cProduto, character, Produto
@param cAlmox, character, Almorarifado
@param nSaldoSB2, numeric, Saldo do SB2
@param nQtdEmp, numeric, Quantidade Empenhada
@param cNumOP, character, N?mero da OP
/*/
Static Function ChkSaldoDisp(cOpcao, cProduto, cAlmox, nSaldoSB2, nQtdEmp, cNumOP)

	Local nPosOP := 0
	Local nOP    := 0

	// aEstDisp	ARRAY COM QUANT DISPONIVEL EM ESTOQUE E QTD.JA UTILIZADA EM X OPs
	//????????????????????????????????????????????????????????????????Ŀ
	//? Aadd(aEstDisp, {cG1Comp, cAlmox, nSaldoSB2,    nQtdEmp })      ?
	//?	Aadd(aEstDisp[nPos], {cNumOP, nQtdEmp})                        ?
	//?	PRODUTO 		[01]                                           ?
	//?	ALMOX			[02]                                           ?
	//?	SALDO ATUAL 	[03]                                           ?
	//?	QTD.UTILIZADA	[04]                                           ?
	//?		NUM.OP		[01][01]                                       ?
	//?		QTD.EMP		[01][02]	                                   ?
	//?					[01][03] <- UTILIZOU SALDO\EMPENHO	           ?
	//??????????????????????????????????????????????????????????????????

	If nQtdEmp == 0      
		DbSelectArea('SD4');DbSetOrder(2)		//	D4_FILIAL+D4_OP+D4_COD+D4_LOCAL
		If DbSeek(xFilial('SD4') + PadR(cNumOP, TamSx3('D4_OP')[01],'') + cProduto + cAlmox, .F. )
			nQtdEmp :=  SD4->D4_QUANT
		EndIf
	EndIf
		
	nPos :=	Ascan(aEstDisp, {|X| X[01] == cProduto .And. X[02] ==  cAlmox})
	If nPos == 0
		//				   [01]     [02]       [03]      [04]
		//				 PRODUTO   ALMOX   SALDO ATUAL  QTD.UTILIZADA
		Aadd(aEstDisp, {cProduto, cAlmox, nSaldoSB2,    nQtdEmp })
		nPos := Len(aEstDisp)
		Aadd(aEstDisp[nPos], {cNumOP, nQtdEmp, ''})
		
	ElseIf cOpcao == 'VALIDA_OPxSALDO'

		nPosOP := 0
		For nOP:=1 To Len(aEstDisp[nPos])  
			If ValType(aEstDisp[nPos][nOP]) == 'A'
				If AllTrim(aEstDisp[nPos][nOP][01]) == AllTrim(cNumOP)
					If cOpcao == 'VALIDA_OPxSALDO'
						//?????????????????????????????????????????????????????????????????????????????????????????????????Ŀ
						//?	FLAG SALDO DO PRODUTO COMO JA CONSUMIDO.                                                		?
						//?	UTILIZADO NOS CASOS ONDE EXISTE O MESMO PRODUTO NA ESTRUTURA DE OPs DIFERENTE           		?
						//?	EX.: 	PRODUTO XXXXX SALDO 10KG                                                          		?
						//?			ORDEM DE PRODUCAO NUM. 046660 UTILIZA 5KG DO SALDO DE 10 (SALDO 5)                    	?
						//?			ORDEM DE PRODUCAO NUM. 046771 UTILIZA 5KG DO SALDO DE 10 (SALDO 0)                    	?
						//?			ORDEM DE PRODUCAO NUM. 046999 SALDO QUE EXISTIA JA FOI TODO CONSUMIDO PELAS OUTRAS OPs	?
						//???????????????????????????????????????????????????????????????????????????????????????????????????
						nPosOP 		:= 	nOP
						nSaldoSB2	:=	aEstDisp[nPos][03]
						nTotEmp		:=	aEstDisp[nPos][04]
						lQtdDisp 	:= 	IIF(nSaldoSB2 > 0, IIF(nTotEmp > nSaldoSB2, .F., .T.), .F.)
						aEstDisp[nPos][nOP][03] := IIF(ValType(aEstDisp[nPos][nOP][03])!='L', lQtdDisp, aEstDisp[nPos][nOP][03])
					EndIf
					
					Exit
				EndIf
			EndIf
		Next

		If nPosOP == 0
			aEstDisp[nPos][04]	+=	nQtdEmp
			nSaldoSB2	:=	aEstDisp[nPos][03]
			nTotEmp		:=	aEstDisp[nPos][04]
			lQtdDisp 	:= 	IIF(nTotEmp > nSaldoSB2, .F., .T.)
			Aadd(aEstDisp[nPos], {cNumOP, nQtdEmp, lQtdDisp})
			nPosOP := Len(aEstDisp[nPos])
		EndIf

	EndIf

	If cOpcao == 'VALIDA_OPxSALDO' .And. nPosOP > 0
		lQtdDisp := aEstDisp[nPos][nPosOP][03]
	Else
		nSaldoSB2	:=	aEstDisp[nPos][03]
		nTotEmp		:=	aEstDisp[nPos][04]
		lQtdDisp 	:= 	IIF(nSaldoSB2 > 0, IIF(nTotEmp > nSaldoSB2, .F., .T.), .F.)
	EndIf

Return(lQtdDisp)


/*/{Protheus.doc} ChkSC2xSD4xSB2
Verifica o saldo e quantidade entre Produto X Ordem de Produ??o X Qtd.Empenho
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 30/12/2021
@param cNumOP, character, N?mero da OP
@param cCodComp, character, Produto
@param cDescr, character, Descri??o do Produto
/*/
Static Function ChkSC2xSD4xSB2(cNumOP, cCodComp, cDescr)

	Local aUtiliz 	:= {}
	Local nAtuSaldo	:= 0
	Local nTotEmp	:= 0
	Local nOP    	:= 0
	Local oDlgUt, oBrwUtil, oFont1

	nPos :=	Ascan(aEstDisp, {|X| X[01] == cCodComp })
	If nPos > 0

		nSaldoSB2 := aEstDisp[nPos][03]

		For nOP := 1 To Len(aEstDisp[nPos])  

			If ValType(aEstDisp[nPos][nOP]) == 'A'

				cNumOP 		:=	Left(aEstDisp[nPos][nOP][01],06)+'.'+SubStr(aEstDisp[nPos][nOP][01],07,02)+'.'+Right(aEstDisp[nPos][nOP][01],03) 
				nQtdEmp		:=	aEstDisp[nPos][nOP][02]
				nTotEmp		+=	nQtdEmp
				nAtuSaldo	:=	nSaldoSB2 - nQtdEmp
				
				cQtdEmp		:=	AllTrim(Transform(nQtdEmp,"@E 999,999.9999"))
				cSaldoSB2	:=	AllTrim(Transform(nSaldoSB2,"@E 999,999.9999")) 
				cAtuSaldo	:=	AllTrim(Transform(nAtuSaldo,"@E 999,999.9999"))
										
				Aadd(aUtiliz, {cNumOP, cQtdEmp, cSaldoSB2, cAtuSaldo})
				nSaldoSB2 := (nSaldoSB2 - nTotEmp)

			EndIf

		Next

		Define Dialog oDlgUt Title "Produto X Ordem de Produ??o X Qtd.Empenho" From 120,120 To 360,960 Pixel 
		
			oFont1	:= TFont():New( "Arial",0,16,,.T.,0,,700,.F.,.F.,,,,,, )
			oBrwUtil := TcBrowse():New(010, 001, 420, 093,,{'OP','Quant.Emp','','Saldo','Saldo - Emp'},{/*50,50,50*/},oDlgUt,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
			oBrwUtil:SetArray(aUtiliz)
		
			oBrwUtil:AddColumn( TcColumn():New('OP'			,{|| aUtiliz[oBrwUtil:nAt][01] },,,,"LEFT",,.F.,.T.,,,,.F.,) )
			oBrwUtil:AddColumn( TcColumn():New('Qtd.Emp'	,{|| aUtiliz[oBrwUtil:nAt][02] },,,,"CENTER",,.F.,.T.,,,,.F.,))
			oBrwUtil:AddColumn( TcColumn():New('Saldo'		,{|| aUtiliz[oBrwUtil:nAt][03] },,,,"CENTER",,.F.,.T.,,,,.F.,))
			oBrwUtil:AddColumn( TcColumn():New('Saldo - Emp'	,{|| aUtiliz[oBrwUtil:nAt][04] },,,,"LEFT",,.F.,.T.,,,,.F.,))
									
			TSay():New( 110, 002,{||"Produto:  "+cCodComp+' - '+cDescr},oDlgUt,,oFont1,.F.,.F.,.F.,.T.,CLR_HBLUE,CLR_WHITE,200,008)
			TButton():New( 108, 378, '&Voltar',  oDlgUt,{|| oDlgUt:End() },030,010,,,.F.,.T.,.F.,,.F.,,,.F.)

		Activate Dialog oDlgUt Centered
	Else
		MsgAlert('Sem dados para apresentar.')    
	EndIf

Return()


/*/{Protheus.doc} PesqNumOP
Pesquisar e posicionar a OP no array
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 30/12/2021
@param cPesq, character, N?mero da OP
@param aLista, array, Listagem a ser procurada
@param oList, object, Objeto em tela
/*/
Static Function PesqNumOP(cPesq, aLista, oList)

	Local nPos := Ascan(aLista, {|X| AllTrim(X[03]) == AllTrim(cPesq) })

	oList:nAT := IIF(nPos > 0, nPos, oList:nAT)
	oList:Refresh()

Return


/*/{Protheus.doc} AltQtde
Alterar a Quantidade da OP
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 18/01/2022
@param nLin, numeric, Linha do array aLista
@param oDlg, object, Objeto da tela atual
/*/
Static Function AltQtde( nLin, oDlg )

	Local cNumOP   := ""
	Local cItemOP  := ""
	Local cSequen  := ""
	Local cItemGrd := ""
	Local cProdut  := ""
	Local cUM	   := ""
	Local cObs     := ""
	Local cLocal   := ""
	Local cMsg     := ""
	Local cCC      := ""
	Local cSegum   := ""
	Local cRoteiro := ""
	Local cTpOP    := ""
	Local cRevisao := ""
	Local cPrior   := ""
	Local cFilSD3  := FWFilial("SD3")
	Local dDataI   := dDatabase
	Local dDataF   := dDatabase
	Local nQuant   := 0

 	ProcLogIni({},"MARA090", "Alt. Quantidade")
 	ProcLogAtu("INICIO")

    dbSelectArea("SD3")
	dbSetOrder(1) // D3_FILIAL + D3_OP + D3_COD + D3_LOCAL

    dbSelectArea("SH6")
	dbSetOrder(1) // H6_FILIAL + H6_OP + H6_PRODUTO + H6_OPERAC + H6_SEQ + DTOS(H6_DATAINI) + H6_HORAINI + DTOS(H6_DATAFIN) + H6_HORAFIN

	DbSelectArea("SC2")
	DbSetorder(1)

	If .NOT. DbSeek( FWFilial("SC2") + aLista[ nLin, 3 ] )
		cMsg := "OP n?o localizada no cadastro"
	Else

		If .NOT. Empty( SC2->C2_DATRF )
			cMsg += "OP foi encerrada em " + DtoC( SC2->C2_DATRF ) + CRLF
		EndIf
		If SC2->C2_QUJE > 0
			cMsg += "OP foi atendida com a Quantidade parcial ou total de " + cValToChar( SC2->C2_QUJE ) + CRLF
		EndIf
		If SC2->C2_ENSENAI == "S"
			cMsg += "OP enviada para Senai n?o pode ser alterada a Quantidade" + CRLF
		EndIf

		If SD3->( dbSeek( cFilSD3 + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + SC2->C2_ITEMGRD ) )
			
			While SD3->( .NOT. EOF() ) .And. SD3->D3_FILIAL + SD3->D3_OP == cFilSD3 + SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN + SC2->C2_ITEMGRD
				
				If SD3->D3_ESTORNO <> "S"
					cMsg += "OP com movimenta??o interna sem Estorno" + CRLF
					Exit 
				EndIf

				SD3->( DbSkip() )
			EndDo
		EndIf
	
		// H6_FILIAL + H6_OP + H6_PRODUTO + H6_OPERAC + H6_SEQ + DTOS(H6_DATAINI) + H6_HORAINI + DTOS(H6_DATAFIN) + H6_HORAFIN
		If SH6->( dbSeek( FWFilial("SH6") + SC2->C2_NUM ) )
			cMsg += "OP com Apontamento" + CRLF
		EndIf
		
	EndIf

	If Empty( cMsg )

		While nQuant <= 0
			nQuant := Val( FWInputBox("Informe a nova Quantidade", cValTochar( aLista[ nLin, 6 ] ) ) )
		EndDo

		cNumOP   := SC2->C2_NUM
		cItemOP  := SC2->C2_ITEM
		cSequen  := SC2->C2_SEQUEN
		cItemGrd := SC2->C2_ITEMGRD
		cProdut  := SC2->C2_PRODUTO
		dDataI   := IIF( SC2->C2_DATPRI < dDataBase, dDataBase, SC2->C2_DATPRI )
		// Data final n?o pode ser menor que a data atual
		dDataF   := IIF( SC2->C2_DATPRF < dDataBase, dDataBase, SC2->C2_DATPRF )
		cUM	     := SC2->C2_UM
		cObs     := SC2->C2_OBS
		cLocal   := SC2->C2_LOCAL
		cCC      := SC2->C2_CC
		cSegum   := SC2->C2_SEGUM
		cRoteiro := SC2->C2_ROTEIRO
		cTpOP    := SC2->C2_TPOP
		cRevisao := SC2->C2_REVISAO
		cPrior   := SC2->C2_PRIOR

		ProcLogAtu("MENSAGEM", "Situa??o atual da OP " + cNumOP, "Situa??o atual da OP " + cNumOP + cItemOP + cSequen + cItemGrd + CRLF +;
		"Produto: " + cProdut + CRLF +;
		"Local: " + cLocal + CRLF +;
		"Roteiro: " + cRoteiro + CRLF +;
		"Tipo de OP: " + cTpOP + CRLF +;
		"Revis?o: " + cRevisao + CRLF +;
		"Quantidade: " + cValTochar( aLista[ nLin, 6 ] ) + CRLF +;
		"Data de Emiss?o: " + DtoC( SC2->C2_EMISSAO ) + CRLF +;
		"Data de Inicio Previsto: " + DtoC( SC2->C2_DATPRI ) + CRLF +;
		"Data Final Previsto: " + DtoC( SC2->C2_DATPRF ) + CRLF +;
		"Observa??o: " + cObs )

		Processa({|| AlteraOP( oDlg, cNumOP, cItemOP, cSequen, cItemGrd, nQuant, cProdut, dDataI, dDataF, cUM, cObs, cLocal, cCC, cSegum, cRoteiro, cTpOP, cRevisao, cPrior )}, "Alterando a Quantidade", "Aguarde..." )
		
	Else
		ProcLogAtu("MENSAGEM", "Foram localizados os problemas", cMsg )
		MsgAlert( "Foram localizados os problemas abaixo: " + CRLF + cMsg )
	EndIf

	ProcLogAtu("FIM")

Return


/*/{Protheus.doc} AlteraOP
Fun??o respons?vel pela Exclus?o e Inclus?o da OP 
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 18/01/2022
@param oDlg, object, Objeto da tela atual
@param cNumOP, character, Numero da OP
@param cItemOP, character, Item
@param cSequen, character, Sequencia
@param cItemGrd, character, Item Grid
@param nQuant, numeric, Quantidade
@param cProdut, character, Produto
@param dDataI, date, Data de Inicio
@param dDataF, date, Data fim 
@param cUM, character, Unidade de Medida
@param cObs, character, Observa??o
@param cLocal, character, Local 
@param cCC, character, Centro de Custo
@param cSegum, character, Segunda UM
@param cRoteiro, character, Roteiro
@param cTpOP, character, Tipo de Op
@param cRevisao, character, Revis?o
@param cPrior, character, Prioridade
/*/
Static Function AlteraOP( oDlg, cNumOP, cItemOP, cSequen, cItemGrd, nQuant, cProdut, dDataI, dDataF, cUM, cObs, cLocal, cCC, cSegum, cRoteiro, cTpOP, cRevisao, cPrior )

	Local aMTA650  := {}
	Local cFilSC2  := FWFilial("SC2")
	Local cErro    := ""

	Private lMsErroAuto := .F.

	ProcRegua( 2 )

	aAdd(aMTA650,{"C2_FILIAL"	, cFilSC2			,NIL})
	aAdd(aMTA650,{"C2_NUM"		, cNumOP			,NIL})
	aAdd(aMTA650,{"C2_ITEM"		, cItemOP			,NIL})
	aAdd(aMTA650,{"C2_SEQUEN"	, cSequen			,NIL})
	aAdd(aMTA650,{"C2_ITEMGRD"	, cItemGrd			,NIL})
	aAdd(aMTA650,{"AUTEXPLODE"  , "S"				,NIL})

	IncProc( "Excluindo OP " + cNumOP )

	//mv_par01 - 1 = ALOCACAO PELO FIM      2 = ALOCACAO PELO INICIO
	//mv_par02 - Considera saldo apenas Local Padrao ? 1-sim  2-nao
	//mv_par03 - Almoxarifado de (Usado p/compor o estoque atual)
	//mv_par04 - Almoxarifado ate
	//mv_par05 - Altera Prioridade das OPs Filhas tambem ?
	//mv_par06 - Gera SC - Por Empenho / Por OP / Por Data
	//mv_par07 - Altera Data Empenho/Ops Filhas ? Sim / Nao
	//mv_par08 - Sugere Lotes a Empenhar Sim / Nao
	//mv_par09 - Grava Obs Ops Inter Sim / Nao
	//mv_par10 - Exclui OPs Filhas ? 1-Sim 2-N?o
	//mv_par11 - Alt.todos Prod. Grd?
	//mv_par12 - Exc.todos Prod. Grd?
	//mv_par13 - Mostra tela alteracao empenhos
	//mv_par14 - Qtd. Nossa Poder 3o.  1-Ignora / 2-Soma
	//mv_par15 - Qtd. 3o. Nosso Poder  1-Ignora / 2-Subtrai
	Pergunte("MTA650", .F.)

	MSExecAuto( {|x,y| MATA650(x,y) }, aMTA650, 5 /*Exclus?o de OP*/ )
	
	If lMsErroAuto
		cErro := Mostraerro()
		ProcLogAtu("MENSAGEM", "Erro na exclus?o da OP " + cNumOP, cErro )
	Else

		// incluir a OP com a mesma numera??o mas com a Nova Quantidade
		aMTA650 := {}

		aAdd(aMTA650,{"C2_FILIAL"	, cFilSC2			,NIL})
		aAdd(aMTA650,{"C2_NUM"		, cNumOP			,NIL})
		aAdd(aMTA650,{"C2_ITEM"		, cItemOP			,NIL})
		aAdd(aMTA650,{"C2_SEQUEN"	, cSequen			,NIL})
		aAdd(aMTA650,{"C2_ITEMGRD"	, cItemGrd			,NIL})
		aAdd(aMTA650,{"C2_QUANT"	, nQuant			,NIL})
		aAdd(aMTA650,{"C2_QUJE"		, 0					,NIL})
		aAdd(aMTA650,{"C2_PRODUTO"	, cProdut			,NIL})
		aAdd(aMTA650,{"C2_EMISSAO"	, dDataBase			,NIL})
		aAdd(aMTA650,{"C2_DATPRI"	, dDataI			,NIL})
		aAdd(aMTA650,{"C2_DATPRF"	, dDataF			,NIL})
		aAdd(aMTA650,{"C2_UM"		, cUM				,NIL})
		aAdd(aMTA650,{"C2_CC"		, cCC				,NIL})
		aAdd(aMTA650,{"C2_OBS"		, cObs				,NIL})
		aAdd(aMTA650,{"C2_LOCAL"	, cLocal			,NIL})
		aAdd(aMTA650,{"C2_SEGUM"	, cSegum			,NIL})
		aAdd(aMTA650,{"C2_ROTEIRO"	, cRoteiro			,NIL})
		aAdd(aMTA650,{"C2_TPOP"  	, cTpOP				,NIL})
		aAdd(aMTA650,{"C2_REVISAO" 	, cRevisao			,NIL})
		aAdd(aMTA650,{"C2_PRIOR"	, cPrior			,NIL})
		aAdd(aMTA650,{"AUTEXPLODE"  , "S"				,NIL})

		IncProc( "Incluindo OP " + cNumOP )

		MSExecAuto( {|x,y| MATA650(x,y) }, aMTA650, 3 /*Inclus?o de OP*/ )
	
		If lMsErroAuto
			cErro  := Mostraerro()
			ProcLogAtu("MENSAGEM", "Erro na inclus?o da OP " + cNumOP, cErro )
		Else
			ProcLogAtu("MENSAGEM", "Nova situa??o da OP " + cNumOP, "Nova situa??o da OP " + cNumOP + cItemOP + cSequen + cItemGrd + CRLF +;
			"Produto: " + cProdut + CRLF +;
			"Local: " + cLocal + CRLF +;
			"Roteiro: " + cRoteiro + CRLF +;
			"Tipo de OP: " + cTpOP + CRLF +;
			"Revis?o: " + cRevisao + CRLF +;
			"Nova Quantidade: " + cValTochar( nQuant ) + CRLF +;
			"Data de Emiss?o: " + DtoC( dDataBase ) + CRLF +;
			"Data de Inicio Previsto: " + DtoC( dDataI ) + CRLF +;
			"Data Final Previsto: " + DtoC( dDataF ) + CRLF +;
			"Observa??o: " + cObs )

			MsgInfo( "Altera??o realizada com sucesso !" )
			
		EndIf

		MsgRun( "Aguarde...... Atualizando Ordens de Produ??o ","Aguarde", {|| SQLxListBox(oDlg) } )
	EndIf
Return


/*/{Protheus.doc} HelpPrw
Apresentar uma tela de Help
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 30/12/2021
/*/
Static Function HelpPrw()

	Local oDlgH
	Local oFolder
	Local aPastas       := {"Objetivo","Lista de Faltas","Imprime OP","Imprime Requisi??o","Imprime Consulta","Visualizar OP","Estrutura X Saldo","Aglutinar OP's","Alt. Qtde Produzida"}
	Local cMGFaltas 	:= ""
	Local cMGPrintOP	:= ""
	Local cMGObjetivo	:= ""
	Local cMGReqImp		:= ""
	Local cMGConsImp	:= ""
	Local cMGOpenOP		:= ""
	Local cMGEstxSal	:= ""
	Local cMGAglutina	:= ""
	Local cMGAltQtde	:= ""

	cMGObjetivo	:=	'OBJETIVO:'+CRLF
	cMGObjetivo	+=	'Apresentar uma tela com as Ordem de Produ??o, conforme par?metro informado pelo usu?rio.'+CRLF
	cMGObjetivo	+=	'A tela mostra marcado com [X] as Ordem de Produ??o (APENAS OPs PREVISTAS) com saldo suficiente para serem produzidas.'+CRLF
	cMGObjetivo	+=	'(No bot?o "Estrutura X Saldo" ? poss?vel verificar o saldo dos produtos.'+CRLF+CRLF
	cMGObjetivo	+=	'Existem 2 teclas de Atalho conforme detalhamento abaixo:'+CRLF
	cMGObjetivo	+=	"F5  -> Consulta e atualiza na tela as OP's conforme os par?metros informados na tela inicial;"+CRLF
	cMGObjetivo	+=	"F11 -> Mostra essa tela de HELP."+CRLF

	cMGFaltas	:=	'LISTA DE FALTAS:'+CRLF
	cMGFaltas	+=	'somente imprime as faltas das op PREVISTAS.'+CRLF
	cMGFaltas	+=	'opcao de mostra as faltas dos itens selecionados (ops previstas com qtd suficiente para serem produzidas)'+CRLF
	cMGFaltas	+=	'ou em tela que sao todas as op que estao no grid.'+CRLF
	cMGFaltas	+=	'explode estrutura q verifica se o item tem qtd suficiente para producao'+CRLF
	cMGFaltas	+=	'se produto estiver em falta imprime.'+CRLF
	cMGFaltas	+=	'eh verificado se o saldo ja foi consumido por outra(s) OP.'+CRLF

	cMGPrintOP	:=	'Realizar a impress?o da(s) OP(s) que est?o marcadas/selecionadas'

	cMGReqImp	:=	'Realizar a impress?o das Requisi??es da OP posicionada'
	cMGReqImp	+=	'QUANDO OP DE ACERTO NAO MOSTRA PRODUTO FANTASMA DA ESTRUTURA' 

	cMGConsImp	:=	'Realizar a impress?o da Consulta'

	cMGOpenOP	:=	'Visualizar a Ordem de Produ??o posicionada'

	cMGEstxSal	:=	'Browser com Estrutura do Produto da OP que esta posicionada.'+CRLF
	cMGEstxSal  +=  'Explode a Estrutura e verifica item a item se tem quantidade em Estoque'+CRLF
	cMGEstxSal  +=  'suficiente para produzir OP.'

	cMGAglutina :=  "Somente as OP's listadas na tela ? que ser?o utilizadas para a Compara??o dos campos abaixo para uma poss?vel Aglutina??o:" + CRLF
	cMGAglutina +=  "Tipo OP ( C2_TPOP) + Produto ( C2_PRODUTO ) + Roteiro ( C2_ROTEIRO ) + Revis?o ( C2_REVISAO )" + CRLF + CRLF
	cMGAglutina +=  "O sistema ir? aglutinar OP's para que possa somar as Quantidades em uma ?nica OP, alterando tamb?m o campo de OP nas Solicita??es "
	cMGAglutina +=  "de Compras ( SC1 ), nos Empenhos ( SD4 ) e nas Movimenta??es Internas ( SD3 )." + CRLF + CRLF
	cMGAglutina +=  "Por?m para que isso ocorra a OP deve estar Aberta e com Saldo total ( sem nenhuma Quantidade j? entregue ), al?m disso tamb?m n?o pode ter sido realizado nenhum Apontamento ou Movimenta??o sem Estorno." + CRLF + CRLF
	cMGAglutina +=  'Foi desenvolvida a rotina customizada "#Logs Gestor OP" para que seja poss?vel consultar os Logs das Aglutina??es realizadas e est? dispon?vel no mesmo menu da op??o "#Gestao de OP".'
	
	cMGAltQtde  +=  "Alterar a Quantidade da OP posicionada na tela." + CRLF
	cMGAltQtde  +=  "Aten??o para a Data Inicial e Data Final, pois essas datas n?o podem ser menores do que a Data Atual." + CRLF
	cMGAltQtde  +=  "Caso a OP posicionada tiver datas menores, a OP alterada ter?o as novas datas diferentes." + CRLF+CRLF
	cMGAltQtde  +=  'Foi desenvolvida a rotina customizada "#Logs Gestor OP" para que seja poss?vel consultar os Logs das Aglutina??es realizadas e est? dispon?vel no mesmo menu da op??o "#Gestao de OP".'

	oDlgH := MSDialog():New( 091,232,522,1026,"Help",,,.F.,,,,,,.T.,,,.T. )

		oFolder := TFolder():New( 012,004,aPastas,{},oDlgH,,,,.T.,.F.,384,176,) 
		TMultiGet():New( 004,004,{|u| If(PCount()>0,cMGObjetivo	:=u,cMGObjetivo	)},	oFolder:aDialogs[01],372,152,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
		TMultiGet():New( 004,004,{|u| If(PCount()>0,cMGFaltas	:=u,cMGFaltas	)},	oFolder:aDialogs[02],372,152,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
		TMultiGet():New( 004,004,{|u| If(PCount()>0,cMGPrintOP	:=u,cMGPrintOP	)},	oFolder:aDialogs[03],372,152,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
		TMultiGet():New( 004,004,{|u| If(PCount()>0,cMGReqImp	:=u,cMGReqImp	)},	oFolder:aDialogs[04],372,152,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
		TMultiGet():New( 004,004,{|u| If(PCount()>0,cMGConsImp	:=u,cMGConsImp	)},	oFolder:aDialogs[05],372,152,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
		TMultiGet():New( 004,004,{|u| If(PCount()>0,cMGOpenOP	:=u,cMGOpenOP	)},	oFolder:aDialogs[06],372,152,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
		TMultiGet():New( 004,004,{|u| If(PCount()>0,cMGEstxSal	:=u,cMGEstxSal	)},	oFolder:aDialogs[07],372,152,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
		TMultiGet():New( 004,004,{|u| If(PCount()>0,cMGAglutina	:=u,cMGAglutina	)},	oFolder:aDialogs[08],372,152,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
		TMultiGet():New( 004,004,{|u| If(PCount()>0,cMGAltQtde	:=u,cMGAltQtde	)},	oFolder:aDialogs[09],372,152,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )

		TButton():New( 192,348,"Voltar",oDlgH,{|| oDlgH:End() },037,012,,,,.T.,,"",,,,.F. )
					
	oDlgH:Activate(,,,.T.)

Return
