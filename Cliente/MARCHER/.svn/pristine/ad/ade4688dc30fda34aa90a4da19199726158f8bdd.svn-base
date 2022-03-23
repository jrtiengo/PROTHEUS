#Include "Totvs.ch"
#Include "Rwmake.ch"
#Include "topconn.ch"

//Posições das colunas do array 	
STATIC _nPosCod := 1
STATIC _nPosDes := 2
STATIC _nPosSal := 3
STATIC _nPosPre := 4
STATIC _nPosQtd := 5
STATIC _nPosPag := 6
STATIC _nPosUme := 7
STATIC _nPosLoc := 8
STATIC _nPosOp  := 9
STATIC _nPosLcz := 10
STATIC _nPosCC  := 11
STATIC _nPosRec := 12
STATIC _nPSalOr := 13 // Saldo original, conforme o SB2
STATIC _nPosApr := 14 // Apropriação Direta ou Indireta ( B1_APROPRI )
STATIC _nPosDEL := 15

/*/{Protheus.doc} MARA080
Tela de PickList de OP
@author Celso Rene
@since 18/03/2020
@version 1.0
@type function
/*/
User Function MARA080()

	Private cDeOP     := Space(14)
	Private cReq      := Space(6)
	Private cUser     := Alltrim(UsrFullName(RetCodUsr()))
	Private aHeader   := {}
	Private cNomeReq  := ""
	Private cOPImp    := ""
	Private cTitulo   := "Picking por Ordens de Produção"
	Private oDlgVis
	Private oFldDados

	oDlg := MSDialog():New( 0,0,250,480,cTitulo,,,.F.,,,,,,.T.,,,.T. )

	TGet():New( 005,020,{|u| If(PCount()>0,cDeOP:=u,cDeOP)},oDlg,050,010,'',{|| NaoVazio() .And. EXISTCPO("SC2",cDeOP) },CLR_BLACK,CLR_WHITE,,,,.T.,"O.P.",,{|| NIL }/*bWhen*/,.F.,.F.,,.F.,.F.,"SC2","cDeOP",,,,,,,"O.P.",1/*Label no topo*/)

	TGet():New( 035,020,{|u| If(PCount()>0,cReq:=u,cReq)},oDlg,050,010,'',{|| NaoVazio() },CLR_BLACK,CLR_WHITE,,,,.T.,"Requisitante",,{|| NIL }/*bWhen*/,.F.,.F.,{||cNomeReq := UsrFullName( cReq )}/*bChange*/,.F.,.F.,"USR","cReq",,,,,,,"Requisitante",1/*Label no topo*/)
	TGet():New( 042,075,{|u| If(PCount()>0,cNomeReq:=u,cNomeReq)},oDlg,080,010,'',{|| NIL },CLR_BLACK,CLR_WHITE,,,,.T.,"",,{|| .F. }/*bWhen*/,.F.,.F.,,.F.,.F.,"","cNomeReq")

	TGet():New( 065,020,{|u| If(PCount()>0,cUser:=u,cUser)},oDlg,080,010,'',{|| NIL }/*valid*/,CLR_BLACK,CLR_WHITE,,,,.T.,"Almoxarife",,{|| .F. }/*bWhen*/,.F.,.F.,,.F.,.F.,""/*Cons. Pad.*/,"cUser",,,,,,,"Almoxarife",1/*Label no topo*/)

	TButton():New( 100,010,"_Continuar",oDlg,{|| FContinua(), oDlg:End() },100,020,,,,.T.,,"",,,,.F. )
	TButton():New( 100,130,"_Retornar" ,oDlg,{|| oDlg:End()              },100,020,,,,.T.,,"",,,,.F. )

    oDlg:Activate(,,,.T.)

Return


/*/{Protheus.doc} FContinua
Chama a carga de dados para o aCols e mostra a relação de empenhos
@author Celso Rene
@since 18/03/2020
@version 1.0
@type function
/*/
Static Function FContinua()

	Local cTitDialog	:= "Empenhos - Ordens de Produção: "+ Alltrim(cDeOP)
	Local nOpcA			:= 0

	Private oSize
	Private aColSSD4 	:= {}
	Private aHeadSD4	:= {}
	Private oGDSD4
	Private oDlgVis

	If Empty( cDeOP )
		MsgInfo( "Deve ser informada uma OP !", cTitulo )
		Return
	EndIf
	
	If Empty( cNomeReq )
		MsgInfo( "Deve ser informado um Usuário Requisitante !", cTitulo )
		Return
	EndIf

	oSize := FwDefSize():New( .F. )
    oSize:aMargins := { 3, 3, 3, 3 }
	oSize:AddObject( "OPCOES", 100, 10, .T., .T. )
	oSize:AddObject( "PRINCIPAL", 100, 90, .T., .T. )
    oSize:lProp := .T.
	oSize:Process()

	//monta tela principal
	oDlgVis := MSDialog():New(oSize:aWindSize[1],oSize:aWindSize[2],oSize:aWindSize[3],oSize:aWindSize[4],cTitDialog,,,,nOr(WS_VISIBLE,WS_POPUP),CLR_BLACK,CLR_WHITE,,,.T./*lPixel*/,,,,.T./*lTransparent*/ )
	// oDlgVis:lMaximized := .T.
	// oDlgVis:lEscClose := .T.

    TButton():New(  oSize:GetDimension("OPCOES","LININI")+5,oSize:GetDimension("OPCOES","COLINI"),;
                    "Sair",oDlgVis,{|| oDlgVis:End() },050,020,,,,.T.,,"",,,,.F. )
    
    TButton():New(  oSize:GetDimension("OPCOES","LININI")+5,oSize:GetDimension("OPCOES","COLINI") + 75,;
                    "Confirmar",oDlgVis,{|| IIF( OPFoiImpressa(), ( nOpcA:=1, oDlgVis:End() ), NIL ) },050,020,,,,.T.,,"",,,,.F. )

    TButton():New(  oSize:GetDimension("OPCOES","LININI")+5,oSize:GetDimension("OPCOES","COLINI") + 150,;
                    "Zera Qtd. Pagar",oDlgVis,{|| MsgRun( 'Atualizando coluna "Pagar"', "Atualizando", {|| AtuPag(0) } ) },050,020,,,,.T.,,"",,,,.F. )

    TButton():New(  oSize:GetDimension("OPCOES","LININI")+5,oSize:GetDimension("OPCOES","COLINI") + 225,;
                    "Pagar tudo",oDlgVis,{|| MsgRun( 'Atualizando coluna "Pagar"', "Atualizando", {|| AtuPag(1) } ) },050,020,,,,.T.,,"",,,,.F. )

    TButton():New(  oSize:GetDimension("OPCOES","LININI")+5,oSize:GetDimension("OPCOES","COLINI") + 300,;
                    "Imp. Recibo",oDlgVis,{|| Imprimir() },050,020,,,,.T.,,"",,,,.F. )

	//cria aHeader e preencha aCols
	Processa( {|| DadosSD4() }, cTitDialog, "Aguade..." )

	//cria o objeto na tela
	oGDSD4 := MsNewGetDados():New(	oSize:GetDimension("PRINCIPAL","LININI"),;
									oSize:GetDimension("PRINCIPAL","COLINI"),;
									oSize:GetDimension("PRINCIPAL","YSIZE"),;
									oSize:GetDimension("PRINCIPAL","XSIZE"),;
									GD_INSERT + GD_UPDATE + GD_DELETE,;
									,;
									,;
									,;
									{"D4_COD","D3_CC","D4_LOCAL","D4_QUANT","QUANT2","CFORNECE","D4_OP"},;
									,;
									999,"u_xPickCol()", , "u_xPickDel()" ,oDlgVis,@aHeadSD4,@aColsSD4)

    oDlgVis:Activate()

	//caso o usuario clique no OK
	If( nOpcA == 1 .And. Len( oGDSD4:aCols ) > 0 )
		If( oGDSD4:aCols[1][_nPosApr] == "I" )
			MsgInfo( "Produto da OP é de Apropriação Indireta e por isso não pode ser feita requisição dos materiais !", cTitulo )
		Else
			If (MSGYESNO( "Deseja gerar as requisições dos materias empenhados conforme quantidade a pagar informada ?", "# Requitar materiais?" ))
				MsAguarde({|| xProcessa()  },"Aguarde! Processando Requisições...")
			EndIf
		EndIf
	EndIf

	FreeObj( oGDSD4  )
	FreeObj( oDlgVis )

Return()


/*/{Protheus.doc} OPFoiImpressa
OP informada na tela tem que ter sido impressa para que seja feita a requisição
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 25/01/2022
@return logical, .T. se a OP foi impressa ou .F. caso contrario
/*/
Static Function OPFoiImpressa()

	Local lIguais := cOPImp == cDeOP

	If oGDSD4:aCols[1][_nPosApr] == "I"
		MsgInfo( "Produto da OP é de Apropriação Indireta e por isso não pode ser feita requisição dos materiais !", cTitulo )
		lIguais := .F.
	Else
		If !lIguais
			MsgInfo( "Realize a impressão da OP para que seja feita a requisição do Material !", cTitulo )
		EndIf
	EndIf


Return( lIguais )


/*/{Protheus.doc} DadosSD4
Listando dados para a tela de Picklist
@author Celso Rene
@since 18/03/2020
@version 1.0
@type function
/*/
Static Function DadosSD4()

	Local nSaldo   := 0
	Local cFilSC2  := FWFilial("SC2")
	Local cFilSD4  := FWFilial("SD4")
	Local cFilSB1  := FWFilial("SB1")
	Local cFilSB2  := FWFilial("SB2")

	dbSelectARea("SD4")

	aAdd( aHeadSD4 , { "Prod. Empenho"  , "D4_COD"    , "             "   , 15, 0, "ExistCpo('SB1')"    					, " ", "C", "SB1"   } )
	aAdd( aHeadSD4 , { "Descricao    "  , "B1_DESC"   , "             "   , 30, 0, ""			        					, " ", "C", ""      } )
	aAdd( aHeadSD4 , { "Disponível   "  , "B2_QATU"   , "@E 999,999.99"   , 10, 2, ""			        					, " ", "N", ""      } )	
	aAdd( aHeadSD4 , { "Qtd Orig.    "  , "D4_QTDEORI", "@E 999,999.9999" , 10, 2, ""			        					, " ", "N", ""      } )
	aAdd( aHeadSD4 , { "Qtd Saldo    "  , "D4_QUANT"  , "@E 999,999.9999" , 10, 2, ""			        					, " ", "N", ""      } )
	aAdd( aHeadSD4 , { "Pagar        "  , "QUANT2"    , "@E 999,999.9999" , 10, 2, "u_xD4PAG(n,M->QUANT2,.T.)"				, " ", "N", ""      } )
	aAdd( aHeadSD4 , { "U.M.         "  , "B1_UM"     , "             "   , 02, 0, ""			        					, " ", "C", ""      } )
	aAdd( aHeadSD4 , { "Local        "  , "D4_LOCAL"  , "             "   , 02, 0, ""			        					, "" , "C", ""      } )
	aAdd( aHeadSD4 , { "OP           "  , "D4_OP"     , "             "   , 11, 0, ""			        					, " ", "C", ""      } )
	aAdd( aHeadSD4 , { "Localizacao  "  , "B2_LOCALIZ", "             "   , 15, 0, ""			        					, " ", "C", ""      } )
	aAdd( aHeadSD4 , { "C. Custo     "  , "D3_CC"     , "             "   , 11, 0, "vazio() .or. ExistCpo('CTT')"			, " ", "C", "CTT"   } )
	aAdd( aHeadSD4 , { "Registro     "   ,"R_E_C_N_O_", "             "   , 10, 0, ""			        					, " ", "N", ""      } )			

	aColsSD4	:= {}

	dbSelectArea("SB1")
	dbSetOrder(1)

	dbSelectArea("SB2")
	dbsetOrder(1)

	dbSelectArea("SC2")
	dbsetOrder(1)
	dbSeek( cFilSC2 + cDeOP )

	dbSelectArea("SD4")
	dbsetOrder(2)
	dbSeek( cFilSD4 + cDeOP, .T. )

	While !SD4->( Eof() ) .And. SD4->D4_OP == cDeOP

		If ( SD4->D4_QUANT > 0 .And. Left( SD4->D4_COD, 3 ) <> "MOD" )

			SB1->( dbSeek( cFilSB1 + SD4->D4_COD ) )

			nSaldo := 0
			aItem  := {}

			If SB2->( dbSeek( cFilSB2 + SD4->D4_COD + SD4->D4_LOCAL ) )
				nSaldo := SaldoSb2()
			EndIf

			aAdd( aItem, SD4->D4_COD     		)
			aAdd( aItem, Left(SB1->B1_DESC,30)  )
			aAdd( aItem, nSaldo          		)
			aAdd( aItem, SD4->D4_QTDEORI 		)
			aAdd( aItem, SD4->D4_QUANT   		)
			aAdd( aItem, 0.0000          		)
			aAdd( aItem, SB1->B1_UM      		)
			aAdd( aItem, SD4->D4_LOCAL   		)
			aAdd( aItem, SD4->D4_OP      		)
			aAdd( aItem, SB2->B2_LOCALIZ 		)
			aAdd( aItem, Space(11)       		) 
			aAdd( aItem, SD4->( Recno() )		)
			aAdd( aItem, nSaldo          		)
			aAdd( aItem, SB1->B1_APROPRI   		)
			aAdd( aItem, nSaldo <= 0     		)

			aAdd( aColsSD4, aItem )
		EndIf

		SD4->( dbSkip() )
	EndDo

Return()


/*/{Protheus.doc} AtuPag
zerando quantidade a pagar
@author Celso Rene
@since 18/03/2020
@version 1.0
@param nTipo, numeric, Se 0 então vai zerar a quantidade, mas se for 1 então vai preencher com o Saldo
@type function
/*/
Static Function AtuPag( nTipo )

	Local nX    := 0

	If oGDSD4:aCols[1][_nPosApr] == "I"
		MsgInfo( "Produto da OP é de Apropriação Indireta e por isso não pode ser feita requisição dos materiais !", cTitulo )
		Return
	EndIf

	For nX := 1 to Len(oGDSD4:aCols)

		If !oGDSD4:aCols[nX][_nPosDEL]

			If nTipo == 0
				oGDSD4:aCols[nX][_nPosSal] := oGDSD4:aCols[nX][_nPSalOr] // Volta o saldo original
				oGDSD4:aCols[nX][_nPosPag] := 0
			Else
				// Se pode atualizar o valor
				If U_xD4PAG( nX, oGDSD4:aCols[nX][_nPosQtd], .F. )
					oGDSD4:aCols[nX][_nPosPag] := oGDSD4:aCols[nX][_nPosQtd]
				EndIf
			EndIf
		EndIf
	Next

	oGDSD4:Refresh()
	oDlgVis:Refresh()

Return() 


/*/{Protheus.doc} xD4PAG
Validação da quantidade a pagar do empenho
@author Celso Rene
@since 18/03/2020
@version 1.0
@type function
/*/
User Function xD4PAG( nLinha, nQtdPago, lEditCampo )

	Local _lRet := .T.
	Local nDif  := 0

	//Apropriação Indireta
	If oGDSD4:aCols[nLinha][_nPosApr] == "I" 
		MsgInfo( "Produto da OP é de Apropriação Indireta e por isso não pode ser feita requisição dos materiais !", cTitulo )
		Return( .F. )
	EndIf
	
	//deletado
	If oGDSD4:aCols[nLinha][_nPosDEL]
		Return(_lRet)
	EndIf

	//verificando se o saldo suficiente
	If ((oGDSD4:aCols[nLinha][_nPosQtd] < nQtdPago .And. oGDSD4:aCols[nLinha][_nPosRec] > 0 ) .Or. oGDSD4:aCols[nLinha][_nPosSal] < nQtdPago )

		If lEditCampo
			If !MsgYesNo("Valor excede o saldo em estoque do produto ou quantidade empenhada na linha "+ cValToChar(n) +". Confirmar mesmo assim?")
				_lRet    := .F.
				nQtdPago := 0
				oGDSD4:aCols[nLinha][_nPosSal] := oGDSD4:aCols[nLinha][_nPSalOr]
			EndIf
		Else // Quando a rotina for chamada pelo botão "Pagar tudo", não atualiza
			_lRet := .F.
		EndIf

	EndIf
	
	If _lRet

		nDif := oGDSD4:aCols[nLinha][_nPosSal] - nQtdPago

		If nDif < 0
			If lEditCampo
				MsgInfo('Coluna "Disponivel" não pode ficar negativo !', cTitulo)
			EndIf
			_lRet := .F.
		Else
			oGDSD4:aCols[nLinha][_nPosSal] := nDif
		EndIf
		
        oGDSD4:Refresh()
        oDlgVis:Refresh()
        
	EndIf

Return(_lRet)


/*/{Protheus.doc} xPickCol
Validando coluna do newgetdados
@author Celso Rene
@since 18/03/2020
@version 1.0
@type function
/*/
User Function xPickCol()

	Local _lVldCol := .T.
	Local nSaldoB2 := 0

	//Apropriação Indireta
	If oGDSD4:aCols[n][_nPosApr] == "I" 
		MsgInfo( "Produto da OP é de Apropriação Indireta e por isso não pode ser feita requisição dos materiais !", cTitulo )
		Return( .F. )
	EndIf
	
	//deletado
	If oGDSD4:aCols[n][_nPosDEL]
		Return(_lRet)
	EndIf

	If (ReadVar() == "M->D4_COD")
		dbSelectArea("SB1")
		dbSetOrder(1)
		dbSeek(xFilial("SB1") + M->D4_COD)

		oGDSD4:aCols[n][_nPosDes] := LEFT(SB1->B1_DESC,35)
		oGDSD4:aCols[n][_nPosLoc] := SB1->B1_LOCPAD
		oGDSD4:aCols[n][_nPosUme] := SB1->B1_UM
		oGDSD4:aCols[n][_nPosOp]  := cDeOP

		dbSelectArea("SB2")
		dbsetOrder(1)
		If dbSeek( xFilial("SB2") + M->D4_COD + oGDSD4:aCols[n][_nPosLoc] )
			nSaldoB2 := SaldoSB2()
			oGDSD4:aCols[n][_nPosSal] := nSaldoB2
			oGDSD4:aCols[n][_nPosQtd] := 0
			oGDSD4:aCols[n][_nPosPag] := 0
			oGDSD4:aCols[n][_nPosLcz] := SB2->B2_LOCALIZ
		EndIf
	Else
		If (Empty(oGDSD4:aCols[n][_nPosCod]))
			MsgAlert("Não identificado o produto!","# Produto")
			_lVldCol := .F.
		EndIf
		If (_lVldCol .and. ReadVar() <> "M->D3_CC" .and. ReadVar() <> "M->CFORNECE" .and. ReadVar() <> "M->QUANT2" .and. oGDSD4:aCols[n][_nPosRec] > 0 .and. &(ReadVar()) <> oGDSD4:aCols[n][aScan(aHeadSD4, { |x| x[2] == Alltrim(Substring(ReadVar(),4,10))})])
			MsgAlert("Não é permitido alterar os registros que se originaram de um empenho da O.P.!","# Item empenho")
			_lVldCol := .F.
		EndIf
	EndIf

Return(_lVldCol)


/*/{Protheus.doc} xPickDel
validando delete linha
@author Celso Rene
@since 18/03/2020
@version 1.0
@type function
/*/
User Function xPickDel()

	Local lVldDEL := .T.

	If oGDSD4:aCols[n][_nPosRec] > 0
		MsgAlert("Não é permitido deletar os registros que se originaram de um empenho da O.P.!","# Item empenho")
		lVldDEL := .F.
	EndIf

Return(lVldDEL)


/*/{Protheus.doc} xProcessa
Processamaneto - gera requisicoes
@author Celso Rene
@since 18/03/2020
@version 1.0
@type function
/*/
Static Function xProcessa()

	Local _nSaldo   := 0
	Local _nQuant   := 0
	Local _x        := 0
	Local aItem     := {}
	Local _cDoc     := ""
	Local cTRT		:= ""
	Local cObs		:= ""
	Local cTM    	:= SuperGetMV("ES_TMPICKI",, "")
	Local cFilSC2 	:= FWFilial("SC2")
	Local cFilSB1 	:= FWFilial("SB1")
	Local cFilSB2 	:= FWFilial("SB2")
	Local cFilSD3 	:= FWFilial("SD3")

	Private lMsErroAuto := .F.

	If Empty( cTM )
		MsgAlert("Não foi preenchido o parâmetro ES_TMPICKI !", "Picking")
		Return
	EndIf

	dbSelectArea("SB1")
	dBSetOrder(1)

	dbSelectArea("SB2")
	dBSetOrder(1)

	dbSelectArea("SC2")
	dbSetOrder(1)

	dbSelectArea("SD4")

	For _x := 1 To Len(oGDSD4:aCols)

		If ( oGDSD4:aCols[_x][_nPosPag] > 0 .and. !oGDSD4:aCols[_x][_nPosDEL])  //quantidade a pagar e nao deletado

			SB1->( dbSeek( cFilSB1 + oGDSD4:aCols[_x][_nPosCod] ) )

			SB2->( dbSeek( cFilSB2 + oGDSD4:aCols[_x][_nPosCod] + oGDSD4:aCols[_x][_nPosLoc] ) )
			
			SC2->( dbSeek( cFilSC2 + oGDSD4:aCols[_x][_nPosOp] ) )
			
			SD4->( dbGoto( oGDSD4:aCols[_x][_nPosRec] ) )

			If ( oGDSD4:aCols[_x][_nPosPag] > oGDSD4:aCols[_x][_nPosQtd] )
				_nSaldo += oGDSD4:aCols[_x][_nPosPag] - oGDSD4:aCols[_x][_nPosQtd]
				_nQuant := oGDSD4:aCols[_x][_nPosQtd]
			Else
				_nQuant := oGDSD4:aCols[_x][_nPosPag]
			EndIf

			cTRT := IIF(oGDSD4:aCols[_x][_nPosRec] > 0 ,SD4->D4_TRT , "")
			cObs := cNomeReq + " BX PICKING"

			aAdd( aItem , { {"D3_FILIAL" , cFilSD3		     			, NIL },;
							{"D3_COD"    , oGDSD4:aCols[_x][_nPosCod]	, NIL },;
							{"D3_LOCAL"  , oGDSD4:aCols[_x][_nPosLoc]   , NIL },;
							{"D3_LOCALIZ", oGDSD4:aCols[_x][_nPosLcz]   , NIL },;
							{"D3_UM"     , SB1->B1_UM 					, NIL },;
							{"D3_QUANT"  , _nQuant    					, NIL },;
							{"D3_USUARIO", cUserName            		, NIL },;
							{"D3_GRUPO"  , SB1->B1_GRUPO        		, NIL },;
							{"D3_CONTA"  , SB1->B1_CONTA        		, NIL },;
							{"D3_OP"     , cDeOP                		, NIL },;
							{"D3_CF"     , "RE0"                		, NIL },;
							{"D3_CHAVE"  , "E0"                 		, NIL },;
							{"D3_CC"     , oGDSD4:aCols[_x][_nPosCC]    , NIL },;
							{"D3_TIPO"   , SB1->B1_TIPO		         	, NIL },;
							{"D3_TRT"    , cTRT  						, NIL },;
							{"D3_OBSERVA", cObs							, NIL } } )

		EndIf

	Next _x

	If Len( aItem ) > 0

		// Adiciona no último item o saldo restante.
		If _nSaldo > 0
			nColQtde := aScan(aHeadSD4, { |x| x[2] == "D3_QUANT"})
			If nColQtde > 0
				aItem[ Len(aItem), nColQtde, 2 ] := _nSaldo
			EndIf
		EndIf

		_cDoc := GetSX8Num("SD3", "D3_DOC",,1)

		DBSelectArea("SD3")
        DBSetOrder(2) //D3_FILIAL+D3_DOC+D3_COD
        MsSeek(xFilial("SD3")+_cDoc)

        // Se já existe essa numeração, deverá pegar um novo
        While Found()
            ConfirmSx8()
            _cDoc := GetSX8Num("SD3", "D3_DOC",,1)
            MsSeek(xFilial("SD3")+_cDoc)
        EndDo


		aCab := { 	{"D3_TM"     , cTM       , NIL},;
					{"D3_DOC"    , _cDoc     , NIL},;
					{"D3_EMISSAO", dDataBase , NIL}}

		Pergunte("MTA240",.F.)

		lMsErroAuto = .F.
		MsExecAuto( { |x,y,z| MATA241(x,y,z) }, aCab, aItem, 3 )

		If lMsErroAuto
			MostraErro()
		Else
			MsgInfo( "Requisições geradas com sucesso !", cTitulo )
			
			//atualizando tela do browse
			DadosSD4()
		EndIf
	
	EndIf

Return()


/*/{Protheus.doc} Imprimir
Efetua a impressão do Recibo de Entrega de materiais para a produção
@author Celso Rene
@since 18/03/2020
@version 1.0
@type function
/*/
Static Function Imprimir()

	Private Titulo   := "Recibo de Entrega de Materiais da OP: " + Alltrim(cDeOP)
	Private Tamanho  := "M"
	Private cDesc1   := OemToAnsi("Emissão do Resumo de Materiais a retirar dos almoxarifados")
	Private cDesc2   := OemToAnsi("")
	Private cDesc3   := OemToAnsi("")
	Private aReturn  := {"Zebrado",1,"Administracao",1/*1 = Retrato e 2 = Paisagem*/,2,1,"",1 }
	//Private aLinha   := {}
	Private NomeProg := "MARA080"
	Private cstring  := "SD4"
	Private wnrel    := "MARA080"

	If( oGDSD4:aCols[1][_nPosApr] == "I" )
		MsgInfo( "Produto da OP é de Apropriação Indireta e por isso não pode ser feita requisição dos materiais !", cTitulo )
		Return
	EndIf

	wnrel := SetPrint(cstring,wnrel,,titulo,cdesc1,cdesc2,cdesc3,.T.,,,Tamanho)

	If nLastKey == 27
		Return
	Endif

	SetDefault( aReturn, cString )

	If nLastKey == 27
		Return
	Endif
	nTipo := If( aReturn[4] == 1, 15, 18 )

	Processa( {|| XImp() },"Imprimindo o Recibo ","Aguarde....." )

	Set Filter To

	If aReturn[5] == 1
		Set Printer To
		Commit
		OurSpool( wnrel )
	EndIf

	MS_FLUSH() //Libera fila de relatorios em spool
Return


/*/{Protheus.doc} XImp
Rotina para impressao do relatorio recibo
@author Celso Rene
@since 18/03/2020
@version 1.0
@type function
/*/
Static Function XImp()

	Local nSld 		:= 0
	Local nSaldoB2  := 0
	Local nn  	    := 0
	Local Li        := 99
	Local aPrint    := oGDSD4:aCols
	Local cOPant 	:= "xyz"
	Local cFilSC2 	:= FWFilial("SC2")
	Local cFilSB1 	:= FWFilial("SB1")
	Local cFilSB2 	:= FWFilial("SB2")
	Local cabec1    := "Codigo               Material                          Local      Estoque  Localiz.          Qtd. Emp    Um   Qtd. Emp    Quantidade"
	Local cabec2    := "		                                                                                             Original           Saldo      Entregue "
	      //            012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012323456789012345
	      //                      1         2         3         4         5         6         7         8         9        10        11        12        13        14        1

	m_pag := 1 //variavel de controle de numeracao da pagina do relatorio
	cString := "SC2"
	

	//ordenando registros a serem impressos por O.P.
	aPrint := ASort(aPrint ,,,{|x,y| y[_nPosOp] + y[_nPosCod] > x[_nPosOp] + x[_nPosCod] })

	ProcRegua( Len( aPrint ) )

	dbSelectArea("SC2")
	dbSetOrder(1)

	dbSelectArea("SB1")
	dbSetOrder(1)

	dbSelectArea("SB2")
	dbSetOrder(1)

	For nn := 1 To Len( aPrint )

		IncProc( AllTrim( aPrint[nn][_nPosCod] ) )

		// quantidade a pagar e nao deletado
		If( aPrint[ nn, _nPosPag] > 0 .and. !aPrint[ nn, _nPosDEL] )

			If( Li > 60 .or. cOPant <> aPrint[nn][_nPosOp] ) 

				SC2->( dbSeek( cFilSC2 + aPrint[nn][_nPosOp] ) )
				
				SB1->( dbSeek( cFilSB1 + SC2->C2_PRODUTO ) )

				Li := Cabec( titulo, cabec1, cabec2, nomeprog, Tamanho, nTipo ) + 1
				@ Li, 00 PSay "O.P.: "
				@ Li, 06 PSay SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN
				@ Li, 20 PSay "Prev. Entrega: "
				@ Li, 35 PSay cValtoChar(SC2->C2_DATPRF)
				@ Li, 48 PSay "Produto : "+ Alltrim(SC2->C2_PRODUTO) + " - " + Left( SB1->B1_DESC, 40 )
				Li := Li + 1

			EndIf

			Li := Li + 1
			nSld := ( aPrint[ nn, _nPosPre ] - aPrint[ nn, _nPosQtd ] )

			If SB2->( dbSeek( cFilSB2 + aPrint[ nn, _nPosCod ] + aPrint[ nn, _nPosLoc ] ) )

				nSaldoB2 := SaldoSB2()

				@ Li, 000 PSay aPrint[ nn, _nPosCod ]
				@ Li, 023 PSay Left( aPrint[ nn, _nPosDes ], 30 )
				@ Li, 056 PSay aPrint[ nn, _nPosLoc ]
				@ Li, 064 PSay Transform( nSaldoB2,"@E 999,999.99 " )
				@ Li, 076 PSay aPrint[ nn, _nPosLcz ]
				@ Li, 093 PSay Transform( aPrint[ nn, _nPosPre ], "@E 999,999.99 " )
				@ Li, 106 PSay aPrint[ nn, _nPosUme ]
				@ Li, 109 PSay Transform( aPrint[ nn, _nPosQtd ], "@E 999,999.99 " )
				@ Li, 120 PSay Transform(aPrint[ nn, _nPosPag ], "@E 999,999.99 " )

			Else
				@ Li, 000 PSay "Não encontrado saldo para o Produto e armazém!"
			EndIf

			cOPImp := aPrint[nn][_nPosOp]

		EndIf

		cOPant := aPrint[nn][_nPosOp]

	Next nn

	If Li > 60
		Li := Cabec( titulo, cabec1, cabec2, nomeprog, Tamanho, nTipo ) + 2
	EndIf

	//imprime rodape com assintaturas
	@ Li + 5, 10 PSay Replicate( "_", Len( "Requisitante: "+ AllTrim(cNomeReq) ) )
	@ Li + 5, 70 PSay Replicate( "_", Len( "Almox: "+ AllTrim(cUser) ) )
	@ Li + 6, 10 PSay "Requisitante: "+ cNomeReq
	@ Li + 6, 70 PSay "Almox: "+ cUser

Return()
