#INCLUDE "TOTVS.CH"
#INCLUDE "FWMVCDEF.CH"

#DEFINE POS_TEMPOATRAVESSAMENTO 1
#DEFINE POS_TEMPOFRETE          2
#DEFINE POS_PRAZOENTREGA        3

/*/{Protheus.doc} CalcPrazoEntrega
Função chamada no Gatilho dos campos abaixo conforme a Tabela:
Cadastro de Produtos (SB1):
    B1_PEBASE, B1_PEATR1 e B1_TIPE para que preencha o campo B1_PE.
    Ambos os campos estão na Aba "MRP / Suprimentos" do cadastro do Produto.
Cadastro de Produtos X Fornecedor (SA5):
    A5_PEBASE, A5_PEATR1 e A5_TIPE para que preencha o campo A5_PE.
@type function
@version 
@author Jorge Alberto - Solutio
@since 29/06/2020
@param caracter, Código da Tabela que foi chamada a função
@return numeric, Prazo para a Entrerga
/*/
User Function CalcPrazoEntrega( cTabela )

    Local nLinha := 0
    Local nPEAtr := 0
    Local nPEAtrMV := SuperGetMV("MA_PEATR1",,0)
    Local nPrazo := 1
    Local cTipo
    Local oModel_
    Local oGrid_

    If cTabela == "SB1"
        nPrazo := M->B1_PEBASE
        cTipo  := M->B1_TIPE
        nPEAtr := M->B1_PEATR1
    ElseIf cTabela == "SA5"
        oModel_ := FWModelActive() // FWLoadModel("MATA061")
        oGrid_  := oModel_:GetModel('MdGridSA5')
        nLinha  := oGrid_:GetLine()
        nPrazo  := oGrid_:GetValue('A5_PEBASE', nLinha )
        cTipo   := oGrid_:GetValue('A5_TIPE', nLinha )
        nPEAtr  := oGrid_:GetValue('A5_PEATR1', nLinha )
    EndIf

    If cTipo $ "M/4"		 // Mes
        nPrazo := nPrazo * 30
    ElseIf cTipo $ "S/3"	// Semana
        nPrazo := nPrazo * 7
    ElseIf cTipo $ "A/5"	// Ano
        nPrazo := nPrazo * 365
    ElseIf cTipo $ "H/1"	// Hora
        nPrazo := Int(nPrazo/24)
    EndIf

    If nPEAtr <= 0
        nPEAtr := nPEAtrMV
    EndIf

    If cTabela == "SA5"
        oGrid_:SetValue('A5_PE', nPrazo + nPEAtr )
        //FreeObj(oModel_)
        //FreeObj(oGrid_)
    EndIf

Return( nPrazo + nPEAtr )



/*/{Protheus.doc} CalSC1TA
Função chamada no gatilho do campo C1_PRODUTO, que irá fazer o cálculo do Prazo de Entrega
@type function
@version 
@author Jorge Alberto - Solutio
@since 01/07/2020
@return number, Sempre retornará o Produto
/*/
User Function CalSC1TA()

    Local nTempoAtravessamento := 0
    Local nTempoFrete           := 0
    Local nPrazoEntrega         := 0
    Local nPosProduto   := aScan( aHeader, { |x| AllTrim(x[2]) == 'C1_PRODUTO' } )
    Local nPosFornece   := aScan( aHeader, { |x| AllTrim(x[2]) == 'C1_FORNECE' } )
    Local nPosLojaForn  := aScan( aHeader, { |x| AllTrim(x[2]) == 'C1_LOJA' } )
    Local nPosDatPRF    := aScan( aHeader, { |x| AllTrim(x[2]) == 'C1_DATPRF' } )
    Local nPosDatEmi    := aScan( aHeader, { |x| AllTrim(x[2]) == 'C1_EMISSAO' } )
    Local nPosXTA       := aScan( aHeader, { |x| AllTrim(x[2]) == 'C1_XTA' } )
    Local nPosXTF       := aScan( aHeader, { |x| AllTrim(x[2]) == 'C1_XTF' } )
    Local nPosXPE       := aScan( aHeader, { |x| AllTrim(x[2]) == 'C1_XPE' } )
    Local nPosXDEntr    := aScan( aHeader, { |x| AllTrim(x[2]) == 'C1_XDTENTR' } )
    Local nPosXDFabr    := aScan( aHeader, { |x| AllTrim(x[2]) == 'C1_XDTFABR' } )
    Local nPosXDComp    := aScan( aHeader, { |x| AllTrim(x[2]) == 'C1_XDTCOMP' } )
   	Local dDatPRF   := aCols[n,nPosDatPRF]
    Local dDatEmi   := aCols[n,nPosDatEmi]
   // Local dData     := CtoD("")
    Local aRetTA    := {}

	//Alterado regra 28/09/21
	If Altera
	  	   dDatPRF   :=  dDatEmi       
	EndIf

    aRetTA := U_GetTA( aCols[n,nPosProduto], aCols[n,nPosFornece], aCols[n,nPosLojaForn] )
    nTempoAtravessamento := aRetTA[ POS_TEMPOATRAVESSAMENTO ]
    nTempoFrete          := aRetTA[ POS_TEMPOFRETE ]
    nPrazoEntrega        := aRetTA[ POS_PRAZOENTREGA ]
    
    // C1_XTA – Tempo de Atravessamento
    // C1_XTF – Tempo de Frete
    // C1_XPE – Prazo de Entrega do Fornecedor (B1_PEBASE ou A5_PEBASE)
    // C1_XDTENTR – Data de Entrega original (cópia do C1_DATPRF)
    aCols[n,nPosXTA   ] := nTempoAtravessamento
    aCols[n,nPosXTF   ] := nTempoFrete
    aCols[n,nPosXPE   ] := nPrazoEntrega
    aCols[n,nPosXDEntr] := dDatPRF
    
    // C1_XDTFABR – Data de Entrega na Fábrica (C1_XDTENTR – C1_XTA)
    dData1 := SOMAPRAZO( dDatPRF, -nTempoAtravessamento )
    aCols[n,nPosXDFabr] := dData1

    // C1_XDTCOMP – Melhor data de compra (C1_XDTENTR – C1_XTA – C1_XTF – C1_XPE)
    dData2 := SOMAPRAZO( dDatPRF, - (nTempoAtravessamento + nTempoFrete + nPrazoEntrega) )
    aCols[n,nPosXDComp] := dData2
    
    // Substituir o C1_DATPRF pelo cálculo: C1_XDTENTR – C1_XTA – C1_XTF
	
	//Alterado regra necessidade para não considera tempo frete 28/09/21
    //dData3 := SOMAPRAZO( dDatPRF, - (nTempoAtravessamento + nTempoFrete) )
		dData3 := SOMAPRAZO( dDatPRF, - nTempoAtravessamento )
    aCols[n, nPosDatPRF ] := dData3

Return( aCols[n,nPosProduto] )



/*/{Protheus.doc} CalTempoAtravessamento
Função chamada no gatilho do campo C7_PRECO, que irá fazer o cálculo do Prazo de Entrega
@type function
@version 
@author Jorge Alberto - Solutio
@since 01/07/2020
@return number, Retornará sempre zero para o campo Preço (C7_PRECO)
/*/
/*User Function CalTempoAtravessamento()

    Local aArea     := GetArea()
    Local aRetTA	:= {}
    Local cAliAtu   := Alias()
    Local cProduto	:= GdFieldGet('C7_PRODUTO') // preco unitario
    Local dDatPRF 	:= GdFieldGet('C7_DATPRF') // Data Entrega
    Local nPreco 	:= GdFieldGet('C7_PRECO')
    Local cNumSC 	:= GdFieldGet('C7_NUMSC')
    Local cItemSC 	:= GdFieldGet('C7_ITEMSC')
    Local dData		:= dDatPRF
    Local lAtualiza := .T.
    Local lRecalculaDatas      := .F.
    Local nTempoAtravessamento := 0
    Local nTempoFrete          := 0
    Local nPrazoEntrega        := 0

    If aCols[n,Len(aHeader) + 1]
        Return( nPreco )
    EndIf

    If ( !Empty( cNumSC ) .And. !Empty( cItemSC ) )

        DbSelectArea("SC1")
        DbSetOrder(1)
        If DbSeek( FWxFilial("SC1") + cNumSC + cItemSC )

            // Se as datas estiverem vazias então não fará nada.
            If ( !Empty( SC1->C1_XDTENTR ) .And. !Empty( SC1->C1_XDTFABR ) )

                GdFieldPut( "C7_XTA"	, SC1->C1_XTA    , n )
            
                // Mesmo que os dados já estejam gravados na SC, aqui precisará recalcular as datas pois o Frete da SC poderá
                // ser ZERO se os campo SB1->B1_PROC e SB1->B1_LOJPROC não estiverem preenchidos no momento de executar o MRP.
                nTempoFrete := SC1->C1_XTF
                If nTempoFrete == 0 .And. SA2->A2_PEFRET > 0
                    nTempoFrete := SA2->A2_PEFRET
                    lRecalculaDatas := .T.
                EndIf

                GdFieldPut( "C7_XTF"    , nTempoFrete    , n )
                GdFieldPut( "C7_XPE"    , SC1->C1_XPE    , n )
                GdFieldPut( "C7_XDTENTR", SC1->C1_XDTENTR, n )
                GdFieldPut( "C7_XDTFABR", SC1->C1_XDTFABR, n )

                dData := SC1->C1_XDTCOMP
                If lRecalculaDatas
                    dDatPRF := SC1->C1_DATPRF
                    dData := CtoD("")
                    dData := SOMAPRAZO( dDatPRF, -SC1->C1_XTA )
                    dData := SOMAPRAZO( dData  , -nTempoFrete )
                    dData := SOMAPRAZO( dData  , -SC1->C1_XPE )
                EndIf
                GdFieldPut( "C7_XDTCOMP", dData, n )


                dData := SC1->C1_DATPRF
                If lRecalculaDatas
                    dDatPRF := SC1->C1_DATPRF
                    // Função abaixo declarada em PE_A711CSC1.prw
                    nTempoAtravessamento := U_GetTA( cProduto, cA120Forn, cA120Loj )[POS_TEMPOATRAVESSAMENTO]
                    dData := CtoD("")
                    dData := SOMAPRAZO( dDatPRF, -nTempoAtravessamento )
                    dData := SOMAPRAZO( dData  , -nTempoFrete )
                EndIf
                GdFieldPut( "C7_DATPRF" , dData , n )
            EndIf
        EndIf
        lAtualiza := .F.
    
    // Se não tem SC e a data de Entrega Original está preenchida é porque já foi feito
    // o cálculo das datas, então o usuário deverá informar para recalcular ou não.
    ElseIf( Empty( cNumSC ) .And. !Empty( GdFieldGet('C7_XDTENTR') ) )
        lAtualiza := MSGYESNO( "Deseja recalcular as Datas de Entregas ?", "Tempo de Atravessamento" )
    EndIf
    
    If lAtualiza

        // Função abaixo declarada em PE_A711CSC1.prw
        aRetTA := U_GetTA( cProduto, cA120Forn, cA120Loj )
        nTempoAtravessamento := aRetTA[ POS_TEMPOATRAVESSAMENTO ]
        nTempoFrete          := aRetTA[ POS_TEMPOFRETE ]
        nPrazoEntrega        := aRetTA[ POS_PRAZOENTREGA ]

        /*
        C7_XTA – Tempo Atravessamento
        C7_XTF – Tempo de Frete
        C7_XPE – Prazo de Entrega do Fornecedor (B1_PEBASEou A5_PEBASE)
        C7_XDTENTR – Data de Entrega original (cópia do C7_DATPRF)
        
        GdFieldPut( "C7_XTA"	, nTempoAtravessamento , n )
        GdFieldPut( "C7_XTF"    , nTempoFrete          , n )
        GdFieldPut( "C7_XPE"    , nPrazoEntrega        , n )
        GdFieldPut( "C7_XDTENTR", dDatPRF			   , n )

        /*
        C7_XDTFABR – Data de Entrega na Fábrica (C7_XDTENTR – C7_XTA)
        
        dData := SOMAPRAZO( dDatPRF, -nTempoAtravessamento )
        GdFieldPut( "C7_XDTFABR", dData, n )

        /*
        C7_XDTCOMP – Melhor data de compra (C7_XDTENTR – C7_XTA – C7_XTF – C7_XPE)
        
        dData := CtoD("")
        dData := SOMAPRAZO( dDatPRF, -nTempoAtravessamento )
        dData := SOMAPRAZO( dData  , -nTempoFrete )
        dData := SOMAPRAZO( dData  , -nPrazoEntrega )
        GdFieldPut( "C7_XDTCOMP", dData, n )

        /*
        Substituir o C7_DATPRF pelo cálculo: C7_XDTENTR – C7_XTA – C7_XTF
        
        dData := CtoD("")
        dData := SOMAPRAZO( dDatPRF, -nTempoAtravessamento )
        dData := SOMAPRAZO( dData  , -nTempoFrete )
        GdFieldPut( "C7_DATPRF", dData, n )
    
    EndIf

    RestArea( aArea )
    If !Empty( cAliAtu )
        DbSelectArea( cAliAtu )
    EndIf

Return( nPreco )
*/


/*/{Protheus.doc} GetTA
Função que faz a verificação da ordem de prioridades de preenchimento das informações,
conforme a sequencia: SA5 -> SB1 -> SA2 -> Parâmetros
Função é chamada pelo PE_M110STTS.prw
@type function
@version 
@author Jorge Alberto - Solutio
@since 30/06/2020
@param cProd, character, Código do Produto
@param cForn, character, Código do Fornecedor
@param cLoja, character, Loja do Fornecedor
@return array, Dados do Tempo de Atravessamento
/*/
User Function GetTA( cProd, cForn, cLoja )

    Local aTA := { 0, 0, 0 }
    Local aAreaSB1 := SB1->( GetArea() )
    Local aAreaSA2 := SA2->( GetArea() )
    Local aAreaSA5 := SA5->( GetArea() )
    Local aArea    := GetArea()
    Local cAliAtu  := Alias()

    DbSelectArea("SA5")
    DbSetOrder( 2 ) // A5_FILIAL + A5_PRODUTO + A5_FORNECE + A5_LOJA
    If DbSeek( FWxFilial("SA5") + cProd + cForn + cLoja )
        aTA[POS_TEMPOATRAVESSAMENTO] := SA5->A5_PEATR1
        aTA[POS_TEMPOFRETE]          := SA5->A5_PEFRET
        aTA[POS_PRAZOENTREGA]        := SA5->A5_PEBASE
    EndIf
    
    DbSelectArea("SB1")
    DbSetOrder( 1 ) // B1_FILIAL + B1_COD
    If DbSeek( FWxFilial("SB1") + cProd )
        aTA[POS_TEMPOATRAVESSAMENTO] := IIF( aTA[POS_TEMPOATRAVESSAMENTO] <= 0, SB1->B1_PEATR1, aTA[POS_TEMPOATRAVESSAMENTO] )
        aTA[POS_PRAZOENTREGA]        := IIF( aTA[POS_PRAZOENTREGA] <= 0, SB1->B1_PEBASE, aTA[POS_PRAZOENTREGA] )
    EndIf

    DbSelectArea("SA2")
    SA2->( DbSetOrder( 1 ) ) // A2_FILIAL + A2_COD + A2_LOJA
    If SA2->( DbSeek( FWxFilial("SA2") + cForn + cLoja ) )
        aTA[POS_TEMPOFRETE]          := IIF( aTA[POS_TEMPOFRETE] <= 0, SA2->A2_PEFRET, aTA[POS_TEMPOFRETE] )
    EndIf

    If aTA[POS_TEMPOATRAVESSAMENTO] <= 0
        aTA[POS_TEMPOATRAVESSAMENTO] := SuperGetMV("MA_PEATR1",,0)
    EndIf

    RestArea( aAreaSA5 )
    RestArea( aAreaSA2 )
    RestArea( aAreaSB1 )
    RestArea( aArea )
    If !Empty( cAliAtu )
        DbSelectArea( cAliAtu )
    EndIf

Return( aTA )
