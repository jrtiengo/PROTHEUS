#include 'rwmake.ch'
/*
 * Programa : RINDCVTV
 * Autor    : Leonel Vilaverde
 * Início   : 10junho2012
 * Descrição: Emissao de Indicador dos Custos dos Veiculos SIRTEC - CONTA - VEICULO
 */
User Function RINDCVTV()

Private cString, Titulo, cDesc1, cDesc2, cDesc3, cQtde ,vUnit, vTotal, cPedido ,Tamanho, aReturn, NomeProg, nLastKey, cQtdeV1, cQtdeV2, ;
		WnRel, lContinua, nTot_Jur, lConf, cVendedor, cComprador, vQtdeParc, vEntrada, cContaPedido, cPedido, cLinha, cQtdeVO,;
		cPed01, cPed02, cPed03, cPed04, cPed05, cPed06, cPed07, cPed08, cPed09, cPed10, cQtdeM, cQtdeF, vTotalM, vTotalF, ;
        cQtde01, cQtde02, cQtde03, cQtde04, cQtde05, cQtde06, cQtde07, cQtde08, cQtde09, cQtde10, cQtdeO, vTotalO, vBase, ;
        cGrupo01, cGrupo02, cGrupo03, cGrupo04, cGrupo05, cGrupo06, cGrupo07, cGrupo08, cGrupo09, cGrupo10, vDolar, vArrobas, ;
		vTotal01, vTotal02, vTotal03, vTotal04, vTotal05, vTotal06, vTotal07, vTotal08, vTotal09, vTotal10, vTComis, nComis, ;
		vTotalP, cCliente, vQtdeP, cNome, cQtdeA, vTotalA, cQtdeB, vTotalB, cQtdeOR, vTotalOR, vTCanal, vQCanal, nCanal,cClasP,;
		vDesc01, vDesc02, vDesc03, vDesc04, vDesc05, vDesc06, vDesc07, vDesc08, vDesc09, vDesc10, vDesc, vLin, vCol, cRacaP, cSexoP, ;
		cQtdeaV1, cQtdeaV2, cQtdeaVo, cCliente, cQtdeMC, cQtdeFC, cQtdeOC, vTotalC, cCCusto, qLinhas, cPerg := PadR('RINDCVTV',10)

@ 096,042 to 323,505 Dialog oDlg Title 'Emissão de  I N D I C A D O R E S   C U S T O   V E I C U L O S  -  S I R T E C '


@ 008,010 to 084,222
@ 018,020 Say 'Emissao dos Custos dos Veículos  - I N D I C A D O R E S' Size 175, 15
@ 030,020 Say 'SIRTEC SISTEMAS ELETRICOS'          Size 175, 15
@ 042,020 Say 'São Borja - RS'       Size 175, 15
@ 052,020 Say 'CONTA - Veiculos'       Size 175, 15

@ 095,130 bmpButton Type 5 Action ( Pergunte( cPerg, .t. ) )
@ 095,160 bmpButton Type 1 Action ( Pergunte( cPerg, .f. ), RptStatus( {|| Boleto() } ), Close( oDlg ) )
@ 095,190 bmpButton Type 2 Action Close( oDlg )

Activate Dialog oDlg Centered

Return

********************************************************************************
Static Function Boleto()
 ********************************************************************************

Private _cTRB	:= GetNextAlias() //Alias Tabela Temporaria
Private _cTRB3	:= GetNextAlias() //Alias Tabela Temporaria
Private _cTRB4	:= GetNextAlias() //Alias Tabela Temporaria

lContinua := .T.
oFont1 :=     TFont():New("Arial"      		,09,08,,.F.,,,,,.F.)	// Titulos dos Campos
oFont2 :=     TFont():New("Arial"      		,09,10,,.T.,,,,,.F.)	// Conteudo dos Campos
oFont3Bold := TFont():New("Arial Black"		,09,16,,.T.,,,,,.F.)	// Nome do Banco
oFont4 := 	  TFont():New("Arial"      		,09,12,,.T.,,,,,.F.)	// Dados do Recibo de Entrega
oFont5 := 	  TFont():New("Arial"      		,09,14,,.T.,,,,,.F.)	// Codigo de Compensação do Banco
oFont55 := 	  TFont():New("Arial"      		,09,16,,.T.,,,,,.F.)	// Codigo de Compensação do Banco
oFont6 := 	  TFont():New("Arial"      	    ,09,10,,.T.,,,,,.F.)	// Codigo de Compensação do Banco
oFont7 := 	  TFont():New("Arial"           ,09,10,,.T.,,,,,.F.)	// Conteudo dos Campos em Negrito
oFont8 := 	  TFont():New("Arial"           ,09,09,,.F.,,,,,.F.)	// Dados do Cliente
oFont9 := 	  TFont():New("Times New Roman" ,09,14,,.T.,,,,,.F.)	// Linha Digitavel

oPrn:=TMSPrinter():New()
oprn:setup()

aArq := {}
aAdd( aArq , { 'CONTA'      , 'C', 20, 0 } )
aAdd( aArq , { 'CT1DESC'    , 'C', 40, 0 } )
aAdd( aArq , { 'ITEM'       , 'C',  9, 0 } )
aAdd( aArq , { 'VALORD'     , 'N', 10, 2 } )
aAdd( aArq , { 'VALORC'     , 'N', 10, 2 } )
aAdd( aArq , { 'DESCEN'     , 'N', 15, 2 } )
aAdd( aArq , { 'HISTORICO'  , 'C', 60, 0} )

If (Select(_cTRB) > 0)
    oTempTab:Delete()
EndIf

oTempTab := FWTemporaryTable():New( _cTRB, aArq  )
oTempTab:AddIndex("01", { aArq[1] + aArq[3] } )
oTempTab:AddIndex("02", { aArq[6] } )
oTempTab:Create()

dbSelectArea(_cTRB)
dbSetIndex( "01" )

aArq3 := {}
aAdd( aArq3 , { 'E5DATA'     , 'D',  8, 0 } )
aAdd( aArq3 , { 'E5BENEF'    , 'C', 40, 0 } )
aAdd( aArq3 , { 'E5NUMERO'   , 'C',  9, 0} )
aAdd( aArq3 , { 'E5TIPODOC'  , 'C',  2, 0} )
aAdd( aArq3 , { 'E5PREFIXO'  , 'C',  3, 0} )
aAdd( aArq3 , { 'E5PARCELA'  , 'C',  1, 0} )
aAdd( aArq3 , { 'E5CLIFOR'   , 'C',  6, 0} )
aAdd( aArq3 , { 'E5LOJA'     , 'C',  2, 0} )
aAdd( aArq3 , { 'E5VALOR'    , 'N', 15, 2} )
aAdd( aArq3 , { 'D1DOC'      , 'C',  9, 0} )
aAdd( aArq3 , { 'D1ITEM'     , 'C',  4, 0} )
aAdd( aArq3 , { 'D1COD'      , 'C', 15, 0} )
aAdd( aArq3 , { 'D1CONTA'    , 'C', 20, 0} )
aAdd( aArq3 , { 'D1ITEMCTA'  , 'C',  9, 0} )
aAdd( aArq3 , { 'D1CC'       , 'C', 20, 0} )
aAdd( aArq3 , { 'CTTDESC'    , 'C', 20, 0} )
aAdd( aArq3 , { 'D1TIPO'     , 'C',  1, 0} )
aAdd( aArq3 , { 'D1DTDIGIT'  , 'D',  8, 0} )
aAdd( aArq3 , { 'D1VALOR'    , 'N', 15, 2} )
aAdd( aArq3 , { 'D1DESC'     , 'C', 40, 2} )
aAdd( aArq3 , { 'HISTORICO'  , 'C', 60, 0} )

If (Select(_cTRB3) > 0)
    oTempTab3:Delete()
EndIf

oTempTab3 := FWTemporaryTable():New( _cTRB3, aArq3  )
oTempTab3:AddIndex("01", {aArq3[7] + aArq3[3] + DtoS(aArq3[1]) + aArq3[11] } )
oTempTab3:Create()

dbSelectArea(_cTRB3)
dbSetIndex( "01" )

aArq4 := {}
aAdd( aArq4 , { 'CT2DATA'    , 'D',  8, 0 } )
aAdd( aArq4 , { 'CT2LOTE'    , 'C',  6, 0 } )
aAdd( aArq4 , { 'CT2SBLOTE'  , 'C',  3, 0 } )
aAdd( aArq4 , { 'CT2DOC'     , 'C',  6, 0 } )
aAdd( aArq4 , { 'CT2LINHA'   , 'C',  3, 0 } )
aAdd( aArq4 , { 'CT2DC'      , 'C',  1, 0 } )
aAdd( aArq4 , { 'CT2DEBITO'  , 'C', 20, 0 } )
aAdd( aArq4 , { 'CT2CREDIT'  , 'C', 20, 0 } )
aAdd( aArq4 , { 'CT2VALOR'   , 'N', 17, 2 } )
aAdd( aArq4 , { 'CT2HIST'    , 'C', 40, 0 } )
aAdd( aArq4 , { 'CT2CCD'     , 'C', 20, 0 } )
aAdd( aArq4 , { 'CT2CCC'     , 'C', 20, 0 } )
aAdd( aArq4 , { 'CT2ITEMD'   , 'C',  9, 0 } )
aAdd( aArq4 , { 'CT2ITEMC'   , 'C',  9, 0 } )
aAdd( aArq4 , { 'CT2ORIGEM'  , 'C',100, 0 } )
aAdd( aArq4 , { 'CT2ROTINA'  , 'C', 10, 0 } )
aAdd( aArq4 , { 'CT2LP'      , 'C',  3, 0 } )
aAdd( aArq4 , { 'CT2KEY'     , 'C',200, 0 } )

If (Select(_cTRB4) > 0)
    oTempTab4:Delete()
EndIf

oTempTab4 := FWTemporaryTable():New( _cTRB4, aArq4  )
oTempTab4:AddIndex("01", { DtoS(aArq4[1]) + aArq4[2] + aArq4[3] + aArq4[4] + aArq4[5] } )
oTempTab4:Create()

dbSelectArea(_cTRB4)
dbSetIndex( "01" )

dbSelectArea( 'CT1' )
dbSetOrder( 1 )
dbSelectArea( 'CTT' )
dbSetOrder( 1 )
dbSelectArea( 'CTD' )
dbSetOrder( 1 )
dbSelectArea( 'CT2' )
dbSetOrder( 1 )
dbSeek( xFilial('CT2') + DTOS(MV_PAR01), .T. )

cCCusto   := PadR('',20)
cCC   := ''
cCustoC   := PadR('',20)
cQtde := 0
cQtdeA := 0
cQtdeB := 0
cQtdeM := 0
cQtdeF := 0
cQtdeO := 0
cQtdeOR := 0
vTotal := 0
vTotalM := 0
vTotalF := 0
vTotalA := 0
vTotalB := 0
vTotalO := 0
vTotalOR := 0
vQtdeP := 0
cPedido := 0
vTotalP := 0
cCliente := 0
cNome := '  '
vTCanal := 0
vQCanal := 0
nCanal  := ' '
cLinha  := 0
vTComis := 0
nComis  := ' '
vBase := 0
cRacaP := ' '
cSexoP := ' '
cClasP := ' '
cQtdeV1 := 0
cQtdeV2 := 0
cQtdeVO := 0
cQtdeaV1 := 0
cQtdeaV2 := 0
cQtdeaVO := 0
cQtdeMC := 0
cQtdeFC := 0
cQtdeOC := 0
vTotalC := 0
qLinhas := 0

While !eof() ;
	.and. CT2->CT2_FILIAL  == xFilial() ;
	.and. CT2->CT2_DATA     <= MV_PAR02 ;
	.and. lContinua

   IF  CT2->CT2_DC == '4'
		dbSelectArea( 'CT2' )
   		dbSkip()
		Loop
	EndIf

    IF MV_PAR03 == 1
	    IF CT2->CT2_DEBITO <> PadR(MV_PAR06,20) .AND. CT2->CT2_DC == '1'
			dbSelectArea( 'CT2' )
			dbSkip()
			Loop
		EndIf

	    IF CT2->CT2_CREDIT <> PadR(MV_PAR06,20) .AND. CT2->CT2_DC == '2'
			dbSelectArea( 'CT2' )
			dbSkip()
			Loop
		EndIf

	    IF CT2->CT2_DEBITO <> PadR(MV_PAR06,20)  .AND. CT2->CT2_CREDIT <> PadR(MV_PAR06,20) .AND. CT2->CT2_DC == '3'
			dbSelectArea( 'CT2' )
			dbSkip()
			Loop
		EndIf

    Else

   	    IF CT2->CT2_DEBITO <> PadR(MV_PAR06,20) .AND. CT2->CT2_DC == '1'
			dbSelectArea( 'CT2' )
			dbSkip()
			Loop
		EndIf

    	IF CT2->CT2_CREDIT <> PadR(MV_PAR06,20) .AND. CT2->CT2_DC == '2'
			dbSelectArea( 'CT2' )
			dbSkip()
			Loop
		EndIf

    	IF CT2->CT2_DEBITO <> PadR(MV_PAR06,20)  .AND. CT2->CT2_CREDIT <> PadR(MV_PAR06,20) .AND. CT2->CT2_DC == '3'
			dbSelectArea( 'CT2' )
			dbSkip()
			Loop
		EndIf

    	IF CT2->CT2_DEBITO <> PadR('3122301002',20)  .and.  MV_PAR06 <> PadR('3122301002',20)
			dbSelectArea( 'CT2' )
			dbSkip()
			Loop
		EndIf

    EndIF

    IF CT2->CT2_DEBITO == PadR('3122301002',20) .AND. CT2->CT2_CREDIT <> PadR('1520900007',20)
		dbSelectArea( 'CT2' )
		dbSkip()
		Loop
	EndIf

	oprn:startpage()

	If lABORTPRINT
		@ PRow()+1, 001 PSay '** CANCELADO PELO OPERADOR **'
		Exit
	EndIf

    IF MV_PAR03 == 1  .OR. MV_PAR06 == PadR('3122301002',20)
		cConta := IIF (SUBSTR(CT2->CT2_CREDIT,1,1) == '3', CT2->CT2_CREDIT,CT2->CT2_DEBITO)

		cITEM := IIF (SUBSTR(CT2->CT2_CREDIT,1,1) == '3', PadR(CT2->CT2_ITEMC,9),PadR(CT2->CT2_ITEMD,9))

	    IF (_cTRB)->( !DBSEEK(PadR(cConta,20)+PadR(cITEM,9), .F.))
	       (_cTRB)->(DBAPPEND())
		   (_cTRB)->CONTA     := PadR(cConta,20)
		   (_cTRB)->ITEM      := PadR(cITEM,9)
	    ENDIF
	    IF  SUBSTR(CT2->CT2_CREDIT,1,1) == '3'
	       (_cTRB)->VALORC      := (_cTRB)->VALORC + CT2->CT2_VALOR
	    Else
	       (_cTRB)->VALORD      := (_cTRB)->VALORD + CT2->CT2_VALOR
	    EndIF

    	(_cTRB)->DESCEN := (10000000 - (_cTRB)->VALORD)

	    IF mv_par04 == 1 .and. mv_par05 == 1
		    (_cTRB4)->(DBAPPEND())
			(_cTRB4)->CT2DATA      := CT2->CT2_DATA
			(_cTRB4)->CT2LOTE      := CT2->CT2_LOTE
			(_cTRB4)->CT2SBLOTE    := CT2->CT2_SBLOTE
			(_cTRB4)->CT2DOC       := CT2->CT2_DOC
			(_cTRB4)->CT2LINHA     := CT2->CT2_LINHA
			(_cTRB4)->CT2DC        := CT2->CT2_DC
			(_cTRB4)->CT2DEBITO    := CT2->CT2_DEBITO
			(_cTRB4)->CT2CREDIT    := CT2->CT2_CREDIT
			(_cTRB4)->CT2VALOR     := CT2->CT2_VALOR
			(_cTRB4)->CT2HIST      := CT2->CT2_HIST
			(_cTRB4)->CT2CCD       := CT2->CT2_CCD
			(_cTRB4)->CT2CCC       := CT2->CT2_CCC
			(_cTRB4)->CT2ITEMD     := CT2->CT2_ITEMD
			(_cTRB4)->CT2ITEMC     := CT2->CT2_ITEMC
			(_cTRB4)->CT2ORIGEM    := CT2->CT2_ORIGEM
			(_cTRB4)->CT2ROTINA    := CT2->CT2_ROTINA
			(_cTRB4)->CT2LP        := CT2->CT2_LP
			(_cTRB4)->CT2KEY       := CT2->CT2_KEY
			(_cTRB4)->(DBCommit())
	    EndIF

    EndIF

	dbSetOrder( 1 )
	dbSelectArea( 'CT2' )
	dbSkip()
EndDo

cCLIFOR := ''
cNOTA   := ''

IF MV_PAR03 == 2

	DbSelectArea("SE5")
	Dbsetorder(6)

	ProcRegua( Reccount())

	DbSeek( xFilial("SE5") + Dtos(Mv_Par01), .t.)

	While !eof() .and. SE5->E5_FILIAL == xFilial( 'SE5' ) ;
			 .and. E5_DtDigit <= mv_par02

		IncProc()

		If SE5->E5_RECPAG == 'R'
			DbSelectArea("SE5")
			dbSkip()
			Loop
		EndIf

		If SE5->E5_TIPODOC == 'CH' // <> 'VL' //.and. SE5->E5_TIPODOC <> 'BA'
			DbSelectArea("SE5")
			dbSkip()
			Loop
		EndIf

		If SE5->E5_SITUACA == 'C'
			DbSelectArea("SE5")
			dbSkip()
			Loop
		EndIf

        	DbSelectarea("SF1")
		    DbSetOrder(1)
		    SF1->( dbSeek( SE5->E5_FILIAL + SE5->E5_NUMERO + SE5->E5_PREFIXO + SE5->E5_CLIFOR + SE5->E5_LOJA, .f. ) )

			DbSelectarea("SD1")
			DbSetOrder(1)

			SD1->( dbSeek( SE5->E5_FILIAL + SE5->E5_NUMERO + SE5->E5_PREFIXO + SE5->E5_CLIFOR + SE5->E5_LOJA, .f. ) )

		    While SD1->( !Eof() ) .and. SD1->D1_FILIAL  == SE5->E5_FILIAL ;
									  .and. SD1->D1_DOC     == SE5->E5_NUMERO ;
									  .and. SD1->D1_SERIE   == SE5->E5_PREFIXO ;
									  .and. SD1->D1_FORNECE == SE5->E5_CLIFOR ;
									  .and. SD1->D1_LOJA    == SE5->E5_LOJA

			      IF SD1->D1_CONTA == PadR(MV_PAR06,20)  //.OR.  SD1->D1_CONTA == PadR('3112102004',20) .OR. SD1->D1_CONTA == PadR('3112102007',20) .OR. SD1->D1_CONTA == PadR('3112102008',20) .OR. SD1->D1_CONTA == PadR('3112102009',20) .OR. SD1->D1_CONTA == PadR('3112102011',20)  .OR. SD1->D1_CONTA == PadR('3121103022',20)
                    Valor :=  (((((SD1->D1_TOTAL+SD1->D1_VALFRE-SD1->D1_VALDESC+SD1->D1_DESPESA) * 100)/ SF1->F1_VALBRUT) * (SE5->E5_VALOR+SE5->E5_VLDESCO-SE5->E5_VLJUROS)) /100)
					cITEM := PadR(SD1->D1_ITEMCTA,9)
					cConta := PadR(SD1->D1_CONTA,20)

    				IF (_cTRB)->( !DBSEEK(PadR(cConta,20)+PadR(cItem,9), .F.))
       					(_cTRB)->(DBAPPEND())
   					    (_cTRB)->CONTA       := PadR(cConta,20)
					   (_cTRB)->ITEM      := PadR(cITEM,9)
   					 ENDIF
   					    (_cTRB)->VALORD      := (_cTRB)->VALORD + Valor

	    				(_cTRB)->DESCEN := (10000000 - (_cTRB)->VALORD)

                    IF MV_PAR05 == 1
	                  		dbSelectArea( 'CTT' )
							dbSetOrder( 1 )
		    				IF !EMPTY(SD1->D1_CC)
								IF dbSeek( xFilial('CTT') + SD1->D1_CC, .F. )
	//		    	   				TRB->CTTDESC := CTT->CTT_DESC01
						   		EndIF
						    EndIF

							    (_cTRB3)->(DBAPPEND())
					   			(_cTRB3)->E5DATA       := SE5->E5_DATA
					   			(_cTRB3)->E5BENEF      := SE5->E5_BENEF
					   			(_cTRB3)->E5NUMERO     := SE5->E5_NUMERO
					   			(_cTRB3)->E5TIPODOC    := SE5->E5_TIPODOC
					   			(_cTRB3)->E5PREFIXO    := SE5->E5_PREFIXO
					   			(_cTRB3)->E5PARCELA    := SE5->E5_PARCELA
					   			(_cTRB3)->E5CLIFOR     := SE5->E5_CLIFOR
					   			(_cTRB3)->E5LOJA       := SE5->E5_LOJA
					   			(_cTRB3)->E5VALOR      := (SE5->E5_VALOR+SE5->E5_VLDESCO-SE5->E5_VLJUROS) //SE5->E5_VALOR
	    			   			(_cTRB3)->D1DOC        := SD1->D1_DOC
					   			(_cTRB3)->D1COD        := SD1->D1_COD
					   			(_cTRB3)->D1ITEM       := SD1->D1_ITEM
					   			(_cTRB3)->D1CONTA      := SD1->D1_CONTA
					   			(_cTRB3)->D1ITEMCTA    := SD1->D1_ITEMCTA
					   			(_cTRB3)->D1CC         := SD1->D1_CC
					   			(_cTRB3)->CTTDESC      := CTT->CTT_DESC01
					   			(_cTRB3)->D1TIPO       := SD1->D1_TIPO
					   			(_cTRB3)->D1DTDIGIT    := SD1->D1_DTDIGIT
					   			(_cTRB3)->D1VALOR      := Valor

                           		DbSelectArea("SB1")
								Dbsetorder(1)

								DbSeek( xFilial("SB1") + SD1->D1_COD, .F.)
								(_cTRB3)->D1DESC := SB1->B1_DESC

	                EndIF

                  EndIF

           		DbSelectArea("SD1")
    			SD1->( dbSkip() )

			End

		    IF PadR(MV_PAR06,20) == PadR('3112102013',20) .or. PadR(MV_PAR06,20) == PadR('3112102014',20) .or. PadR(MV_PAR06,20) == PadR('3112102015',20)   // PadR(MV_PAR06,20) == PadR('3121103025',20)
				DbSelectArea("SE2")
				DbSetorder(1)
				DbSeek( xFilial("SE2") + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + SE5->E5_FORNECE + SE5->E5_LOJA , .F.)

				IF SE2->E2_ORIGEM == PadR('FINA050',8)

					DbSelectArea("SED")
					Dbsetorder(1)
					DbSeek( xFilial("SED") + SE5->E5_NATUREZ, .F.)
					cConta := SED->ED_CONTA
					cITEM := PadR(SE5->E5_ITEMD,9)

					DbSelectarea("SEZ")
					DbSetOrder(1)

					IF SEZ->( dbSeek( SE5->E5_FILIAL + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + SE5->E5_CLIFOR + SE5->E5_LOJA, .f. ) )

					    While SEZ->( !Eof() ) .and. SEZ->EZ_FILIAL  == SE5->E5_FILIAL ;
										  .and. SEZ->EZ_NUM     == SE5->E5_NUMERO ;
										  .and. SEZ->EZ_PREFIXO == SE5->E5_PREFIXO ;
										  .and. SEZ->EZ_PARCELA == SE5->E5_PARCELA ;
										  .and. SEZ->EZ_TIPO    == SE5->E5_TIPO ;
										  .and. SEZ->EZ_CLIFOR  == SE5->E5_CLIFOR ;
										  .and. SEZ->EZ_LOJA    == SE5->E5_LOJA

							DbSelectArea("SED")
							Dbsetorder(1)
							IF DbSeek( xFilial("SED") + SEZ->EZ_NATUREZ, .F.)
								cConta  := SED->ED_CONTA
							Else
		     	                MsgBox("Natureza não cadastrada. Verifique!!!" +SEZ->EZ_NATUREZ,"ATENCAO!")
			                EndIf

						    IF PadR(cConta,20) == PadR('3112102013',20) .AND. PadR(MV_PAR06,20) == PadR('3112102013',20) .OR. PadR(cConta,20) == PadR('3112102014',20) .AND. PadR(MV_PAR06,20) ==  PadR('3112102014',20) .OR. PadR(cConta,20) == PadR('3112102015',20) .AND. PadR(MV_PAR06,20) ==  PadR('3112102015',20)

			                    PercEZ :=  (((SEZ->EZ_VALOR*SEZ->EZ_PERC) * 100)/SE5->E5_VALOR)
			                    Valor :=   (SE5->E5_VALOR*(PercEZ/100))

								cITEM   :=  SEZ->EZ_ITEMCTA

			    				IF (_cTRB)->( !DBSEEK(PadR(cConta,20)+PadR(cItem,9), .F.))
	    		   				   (_cTRB)->(DBAPPEND())
	   							   (_cTRB)->CONTA       := PadR(cConta,20)
								   (_cTRB)->ITEM      := PadR(cITEM,9)
	   							ENDIF
							       (_cTRB)->VALORD      := (_cTRB)->VALORD + Valor //(SE5->E5_VALOR+SE5->E5_VLDESCO-SE5->E5_VLJUROS)
		    	        	       (_cTRB)->DESCEN      := (10000000 - (_cTRB)->VALORD)

							    (_cTRB3)->(DBAPPEND())
			   					(_cTRB3)->E5DATA       := SE5->E5_DATA
			   					(_cTRB3)->E5BENEF      := SE5->E5_BENEF
			   					(_cTRB3)->E5NUMERO     := SE5->E5_NUMERO
			   					(_cTRB3)->E5TIPODOC    := SE5->E5_TIPODOC
			   					(_cTRB3)->E5PREFIXO    := SE5->E5_PREFIXO
			   					(_cTRB3)->E5PARCELA    := SE5->E5_PARCELA
			   					(_cTRB3)->E5CLIFOR     := SE5->E5_CLIFOR
			   					(_cTRB3)->E5LOJA       := SE5->E5_LOJA
			   					(_cTRB3)->E5VALOR      := Valor //(SE5->E5_VALOR+SE5->E5_VLDESCO-SE5->E5_VLJUROS) //SE5->E5_VALOR
	    	                EndIf
	    	    			DbSelectarea("SEZ")
							DbSetOrder(1)
	    	         		SEZ->( dbSkip() )

						End
	                ElseIF SE5->E5_NATUREZ == PadR('202072003',10) .AND. PadR(MV_PAR06,20) == PadR('3112102015',20) .or. SE5->E5_NATUREZ == PadR('202072006',10) .AND. PadR(MV_PAR06,20) == PadR('3112102014',20) .or. SE5->E5_NATUREZ == PadR('201081001',10) .AND. PadR(MV_PAR06,20) == PadR('3112102015',20)   // PadR(MV_PAR06,20) == PadR('3121103025',20)

	    				IF (_cTRB)->( !DBSEEK(PadR(cConta,20)+PadR(cItem,9), .F.))
		   				   (_cTRB)->(DBAPPEND())
						   (_cTRB)->CONTA       := PadR(cConta,20)
						   (_cTRB)->ITEM        := PadR(cITEM,9)
	   					ENDIF
						   (_cTRB)->VALORD      := (_cTRB)->VALORD + (SE5->E5_VALOR+SE5->E5_VLDESCO-SE5->E5_VLJUROS)
	    	               (_cTRB)->DESCEN := (10000000 - (_cTRB)->VALORD)

					    (_cTRB3)->(DBAPPEND())
			   			(_cTRB3)->E5DATA       := SE5->E5_DATA
			   			(_cTRB3)->E5BENEF      := SE5->E5_BENEF
			   			(_cTRB3)->E5NUMERO     := SE5->E5_NUMERO
			   			(_cTRB3)->E5TIPODOC    := SE5->E5_TIPODOC
			   			(_cTRB3)->E5PREFIXO    := SE5->E5_PREFIXO
			   			(_cTRB3)->E5PARCELA    := SE5->E5_PARCELA
			   			(_cTRB3)->E5CLIFOR     := SE5->E5_CLIFOR
			   			(_cTRB3)->E5LOJA       := SE5->E5_LOJA
			   			(_cTRB3)->E5VALOR      := (SE5->E5_VALOR+SE5->E5_VLDESCO-SE5->E5_VLJUROS) //SE5->E5_VALOR

	                EndIF
                 EndIF
         EndIf

		DbSelectArea("SE5")
		Dbsetorder(6)

		DbselectArea("SE5")
		Dbskip()

	EndDo
EndIF

dbSelectArea(_cTRB)
dbSetIndex( "02" )

nVALORT := 0

DbGoTop()

while !EOF()

  nVALORT :=  nVALORT + (_cTRB)->VALORD
  nVALORT :=  nVALORT - (_cTRB)->VALORC

  dbSelectArea(_cTRB)
  (_cTRB)->(dbSkip())

EndDo

DbGoTop()
cITEMB  :=  'xx'
cCCusto  :=  'xx'
cCTA :=  ' '
cLinha := 0450
qLinhas := 0
aDados := {}

while !EOF()

    IF  qLinhas == 0
        oprn:=TMSPrinter():New()
        oprn:StartPage()
		cLinha := 0450
		oSend( oPrn, "SayBitmap", 044, 0050, "LGSIRTEC2.bmp", 600, 200 )//objeto,constante,linha,coluna,caminho,
		oprn:say(0050,0700,'I N D I C A D O R E S   D O S   C U S T O S   V E I C U L O S  ',oFont55,100)
	   	oprn:say(0180,1250,"SÃO BORJA,   " + Right(dtos(dDataBase),2) + '   de   ' + MesExtenso(str(month(dDataBase),2)) + '   de    ' + Str(Year(dDataBase),4) + '.'  ,oFont4,100)
		oprn:say(0200,0000,Repl("_",1800),oFont55,100)
		dbSelectArea( 'CT1' )
		dbSetOrder( 1 )
	    IF !EMPTY((_cTRB)->CONTA)
			IF dbSeek( xFilial('CT1') + (_cTRB)->CONTA, .F. )
	    	   (_cTRB)->CT1DESC := CT1->CT1_DESC01
	   		EndIF
	    EndIF
        If  mv_par03 == 1
			oprn:say(0300,0400,' C O N T A : ' + ALLTRIM((_cTRB)->CONTA)+'  '+ALLTRIM((_cTRB)->CT1DESC)+'     -    '+ dtoc(MV_PAR01)+ ' Até '+ dtoc(MV_PAR02)+ '     -    Regime de Competência' ,oFont5,100)
        Else
			oprn:say(0300,0400,' C O N T A : ' + ALLTRIM((_cTRB)->CONTA)+'  '+ALLTRIM((_cTRB)->CT1DESC)+'     -    '+ dtoc(MV_PAR01)+ ' Até '+ dtoc(MV_PAR02)+ '     -    Regime de Caixa' ,oFont5,100)
        EndIf
		oprn:say(0350,0000,Repl("_",1800),oFont55,100)
  		oprn:say(0450,0200,'V E I C U L O                    V a l o r       % Partic'  ,oFont5,100)
  		oprn:say(0450,1400,'V E I C U L O                    V a l o r       % Partic.'  ,oFont5,100)
    EndIF
    IF PadR(cITEMB,9) <> PadR((_cTRB)->ITEM,9)
       cLinha := cLinha + 100
    	oprn:say(cLinha,00650, Transform( (_cTRB)->VALORD-(_cTRB)->VALORC , '@E 9999,999.99' ),oFont6,100)
    	nPerc :=   (((_cTRB)->VALORD-(_cTRB)->VALORC)*100)/nVALORT
    	oprn:say(cLinha,01020, Transform( nPerc , '@E 999.99' ),oFont6,100)
		dbSelectArea( 'CTD' )
		dbSetOrder( 1 )
	    IF !EMPTY((_cTRB)->ITEM)
			IF dbSeek( xFilial('CTD') + (_cTRB)->ITEM, .F. )
	    	   (_cTRB)->CTDDESC := CTD->CTD_DESC01
	   		EndIF
	    EndIF
		oprn:say(cLinha,0200, AllTrim((_cTRB)->CTDDESC),oFont5,100)
        cITEMB  := PadR((_cTRB)->ITEM,9)
    EndIF
    IF PadR(cITEMB,9) == PadR((_cTRB)->ITEM,9)
       vTotalC := vTotalC + (_cTRB)->VALORD-(_cTRB)->VALORC
    EndIf
   vTotal := vTotal + (_cTRB)->VALORD-(_cTRB)->VALORC

   dbSelectArea(_cTRB)
   dbSkip()

   IF PadR(cITEMB,9) <> PadR((_cTRB)->ITEM,9)
    	oprn:say(cLinha,01920, Transform( (_cTRB)->VALORD-(_cTRB)->VALORC , '@E 9999,999.99' ),oFont6,100)
    	nPerc :=   (((_cTRB)->VALORD-(_cTRB)->VALORC)*100)/nVALORT
    	oprn:say(cLinha,02220, Transform( nPerc , '@E 999.99' ),oFont6,100)
		dbSelectArea( 'CTD' )
		dbSetOrder( 1 )
	    IF !EMPTY((_cTRB)->ITEM)
			IF dbSeek( xFilial('CTD') + (_cTRB)->ITEM, .F. )
	    	   (_cTRB)->CTDDESC := CTD->CTD_DESC01
	   		EndIF
	    EndIF
		oprn:say(cLinha,1400, AllTrim((_cTRB)->CTDDESC),oFont5,100)
        cITEMB  := PadR((_cTRB)->ITEM,9)
    EndIF
	IF PadR(cITEMB,9) == PadR((_cTRB)->ITEM,9)
       vTotalC := vTotalC + (_cTRB)->VALORD-(_cTRB)->VALORC
    EndIf
   	vTotal := vTotal + (_cTRB)->VALORD-(_cTRB)->VALORC

	dbSelectArea(_cTRB)
    (_cTRB)->(dbSkip())

    IF qLinhas ==  29
       oprn:preview()
       oprn:endpage()
	   cLinha := 0450
	   qLinhas := 0
    Else
	    qLinhas := qLinhas + 1
    EndIF

EndDo
If  qLinhas == 0
		oSend( oPrn, "SayBitmap", 044, 0050, "LGSIRTEC2.bmp", 600, 200 )//objeto,constante,linha,coluna,caminho,
		oprn:say(0050,0700,'I N D I C A D O R  -  C U S T O S   V E I C U L O S  -  S  I  R  T  E  C  - ',oFont55,100)
	   	oprn:say(0180,1250,"SÃO BORJA,   " + Right(dtos(dDataBase),2) + '   de   ' + MesExtenso(str(month(dDataBase),2)) + '   de    ' + Str(Year(dDataBase),4) + '.'  ,oFont4,100)
		oprn:say(0200,0000,Repl("_",1800),oFont55,100)
		dbSelectArea( 'CT1' )
		dbSetOrder( 1 )
	    IF !EMPTY((_cTRB)->CONTA)
			IF dbSeek( xFilial('CT1') + (_cTRB)->CONTA, .F. )
	    	   (_cTRB)->CT1DESC := CT1->CT1_DESC01
	   		EndIF
	    EndIF

        If  mv_par03 == 1
			oprn:say(0300,0400,' C O N T A : ' + ALLTRIM((_cTRB)->CONTA)+'  '+ALLTRIM((_cTRB)->CT1DESC)+'     -    '+ dtoc(MV_PAR01)+ ' Até '+ dtoc(MV_PAR02)+ '     -    Regime de Competência' ,oFont5,100)
        Else
			oprn:say(0300,0400,' C O N T A : ' + ALLTRIM((_cTRB)->CONTA)+'  '+ALLTRIM((_cTRB)->CT1DESC)+'     -    '+ dtoc(MV_PAR01)+ ' Até '+ dtoc(MV_PAR02)+ '     -    Regime de Caixa' ,oFont5,100)
        EndIf
		oprn:say(0350,0000,Repl("_",1800),oFont55,100)
  		oprn:say(0450,0200,'V E I C U L O                    V a l o r       % Partic'  ,oFont5,100)
  		oprn:say(0450,1400,'V E I C U L O                    V a l o r       % Partic.'  ,oFont5,100)

EndIF
oprn:say(cLinha,0000,Repl("_",1800),oFont55,100)
cLinha := cLinha + 0100

oprn:say(cLinha,01200, 'Total:',oFont5,100)
oprn:say(cLinha,01570, Transform( vTotal , '@E 9999,999.99' ),oFont5,100)
oprn:say(cLinha,01900, '100,00%',oFont5,100)

cLinha := cLinha + 0050
oprn:say(cLinha,0000,Repl("_",1800),oFont55,100)

If (Select(_cTRB) > 0)
    oTempTab:Delete()
EndIf

oprn:PREVIEW()
oprn:end()

Ms_Flush()

cCLIFOR := ''
cNOTA   := ''
dDataE5 := CtoD("")

IF  MV_PAR04 == 1  .AND.  MV_PAR05 == 1

	dbSelectArea(_cTRB3)
	DbGoTop()

	while !EOF()
		IF  (_cTRB3)->E5NUMERO <> PadR(cNOTA,9) .OR. (_cTRB3)->E5NUMERO == PadR(cNOTA,9) .AND. (_cTRB3)->E5CLIFOR <> PadR(cCLIFOR,6) .or. (_cTRB3)->E5NUMERO == PadR(cNOTA,9) .AND. (_cTRB3)->E5CLIFOR == PadR(cCLIFOR,6) .and. (_cTRB3)->E5DATA <> dDataE5
		  	AAdd(aDados, {(_cTRB3)->E5DATA,(_cTRB3)->E5BENEF,(_cTRB3)->E5PREFIXO,(_cTRB3)->E5NUMERO,(_cTRB3)->E5PARCELA,(_cTRB3)->E5TIPODOC,(_cTRB3)->E5CLIFOR,(_cTRB3)->E5LOJA,(_cTRB3)->E5VALOR,(_cTRB3)->D1DOC,(_cTRB3)->D1ITEM,(_cTRB3)->D1COD,(_cTRB3)->D1CONTA,(_cTRB3)->D1ITEMCTA,(_cTRB3)->D1CC,(_cTRB3)->CTTDESC,(_cTRB3)->D1TIPO,(_cTRB3)->D1DTDIGIT,(_cTRB3)->D1VALOR}) //adiciona aos dados
	    ELSE
		  	AAdd(aDados, {(_cTRB3)->E5DATA,(_cTRB3)->E5BENEF,(_cTRB3)->E5PREFIXO,(_cTRB3)->E5NUMERO,(_cTRB3)->E5PARCELA,(_cTRB3)->E5TIPODOC,(_cTRB3)->E5CLIFOR,(_cTRB3)->E5LOJA,' ',(_cTRB3)->D1DOC,(_cTRB3)->D1ITEM,(_cTRB3)->D1COD,(_cTRB3)->D1CONTA,(_cTRB3)->D1ITEMCTA,(_cTRB3)->D1CC,(_cTRB3)->CTTDESC,(_cTRB3)->D1TIPO,(_cTRB3)->D1DTDIGIT,(_cTRB3)->D1VALOR}) //adiciona aos dados
	    ENDIF
		    IF  mv_par03 == 2
				cCLIFOR := (_cTRB)->E5CLIFOR
 				cNOTA   := (_cTRB)->E5NUMERO
            	dDATAE5 := (_cTRB)->E5DATA
            EndIf

	  dbSelectArea(_cTRB3)
	  (_cTRB3)->(dbSkip())

	EndDo

EndIF

IF  MV_PAR04 == 1  .AND.  MV_PAR05 == 1 .AND. MV_PAR03 == 1

	dbSelectArea(_cTRB4)
	(_cTRB4)->(DbGoTop())

	while !EOF()

	  AAdd(aDados, {(_cTRB4)->CT2DATA,(_cTRB4)->CT2LOTE,(_cTRB4)->CT2SBLOTE,(_cTRB4)->CT2DOC,(_cTRB4)->CT2LINHA,(_cTRB4)->CT2DC,(_cTRB4)->CT2DEBITO,(_cTRB4)->CT2CREDIT,(_cTRB4)->CT2VALOR,(_cTRB4)->CT2HIST,(_cTRB4)->CT2CCD,(_cTRB4)->CT2CCC,(_cTRB4)->CT2ITEMD,(_cTRB4)->CT2ITEMC,(_cTRB4)->CT2ORIGEM,(_cTRB4)->CT2ROTINA,(_cTRB4)->CT2LP,(_cTRB4)->CT2KEY}) //adiciona aos dados
	  dbSelectArea(_cTRB4)
	  (_cTRB4)->(dbSkip())

	EndDo

EndIF

If mv_par04 == 1

  IF mv_par05 == 2
     aCabec := {"Centro Custo","Desc. Custo","Valor","Data Inic","Data Final"} //Criação de um cabeçalho
  ElseIF mv_par03 == 2
	aCabec := {"DATA BAIXA","BENEF","PREFIXO","NUMERO","PARCELA","TIPODOC","CLIFOR","LOJA","VALOR BX","DOCUMEN","ITEM","COD"," CONTA"," ITEMCTA"," CCUSTO","CTTDESC"," TIPO"," DTDIGIT"," VALOR ITEM "} //Criação de um cabeçalho
  ElseIF mv_par03 == 1
	aCabec := {"DATA ","LOTE","SBLOTE","DOC","LINHA","DC","CTADEBITO","CTACREDIT","VALOR","HISTORICO","CCUSTO DEB","CCUSTO CRE"," ITEM DEB"," ITEM CRE"," ORIGEM","ROTINA"," LP"," KEY"} //Criação de um cabeçalho
  EndIF
    IF  mv_par03 == 1
		DlgToExcel({ {"ARRAY", "RINDCVGC - Indicadores Sirtec - Veículos - Regime de Competencia", aCabec, aDados} }) // utiiliza a função
    Else
		DlgToExcel({ {"ARRAY", "RINDCVGC - Indicadores Sirtec - Veículos - Regime de Caixa", aCabec, aDados} }) // utiiliza a função
    EndIF
EndIF

Return

********************************************************************************
Static Function VerImp()
********************************************************************************

If aReturn[ 5 ] # 2
	Return
EndIf

While .T.
	SetPrc( 0, 0 )

	@ PRow(), 000 PSay ' '
	@ PRow(), 000 PSay '*'
	@ PRow(), 000 PSay '*'

	lConf := MsgBox( 'Formulario esta posiciondado ?', 'Impressora', 'YESNO' )
	If lConf
		lContinua := .T.
		Exit
	Else
		lConf := MsgBox( 'Tentar novamente ?', 'Impressora', 'YESNO' )
		If lConf
			Loop
		Else
			lContinua := .F.
			Return
		EndIf
	EndIf
EndDo

Return( .T. )