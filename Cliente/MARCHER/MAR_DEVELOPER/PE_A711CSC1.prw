#INCLUDE "TOTVS.CH"

#DEFINE POS_TEMPOATRAVESSAMENTO 1
#DEFINE POS_TEMPOFRETE          2
#DEFINE POS_PRAZOENTREGA        3

/*/{Protheus.doc} A711CSC1
PE chamado no MRP, usado para adicionar campos no array das SC's.
@type function
@version 
@author Jorge Alberto - Solutio
@since 30/06/2020
@return array, Array com mais campos para serem gravados.
/*/
User Function A711CSC1()

    Local aItemC1 := PARAMIXB[1]
    Local aRetTA := {}
    Local nPosProduto := aScan( aItemC1, { |x| x[1] == 'C1_PRODUTO' } )
    Local nPosFornece := aScan( aItemC1, { |x| x[1] == 'C1_FORNECE' } )
    Local nPosLojaForn := aScan( aItemC1, { |x| x[1] == 'C1_LOJA' } )
    Local nPosDatPRF := aScan( aItemC1, { |x| x[1] == 'C1_DATPRF' } )
    Local dDatPRF := aItemC1[nPosDatPRF,2]
    Local nTempoAtravessamento := 0
    Local nTempoFrete := 0
    Local nPrazoEntrega := 0
    Local dData := CtoD("")
    
    aRetTA := U_GetTA( aItemC1[nPosProduto,2], aItemC1[nPosFornece,2], aItemC1[nPosLojaForn,2] )
    nTempoAtravessamento := aRetTA[ POS_TEMPOATRAVESSAMENTO ]
    nTempoFrete          := aRetTA[ POS_TEMPOFRETE ]
    nPrazoEntrega        := aRetTA[ POS_PRAZOENTREGA ]
    
    // C1_XTA – Tempo de Atravessamento
    // C1_XTF – Tempo de Frete
    // C1_XPE – Prazo de Entrega do Fornecedor (B1_PEBASE ou A5_PEBASE)
    // C1_XDTENTR – Data de Entregaoriginal (cópia do C1_DATPRF)
    AAdd( aItemC1, { "C1_XTA"    , nTempoAtravessamento , NIL } )
    AAdd( aItemC1, { "C1_XTF"    , nTempoFrete          , NIL } )
    AAdd( aItemC1, { "C1_XPE"    , nPrazoEntrega        , NIL } )
    AAdd( aItemC1, { "C1_XDTENTR", dDatPRF              , NIL } )
    
    // C1_XDTFABR – Data de Entrega na Fábrica (C1_XDTENTR – C1_XTA)
    dData := DaySub( dDatPRF, nTempoAtravessamento )
    AAdd( aItemC1, { "C1_XDTFABR", dData, NIL } )

    // C1_XDTCOMP – Melhor data de compra (C1_XDTENTR – C1_XTA – C1_XTF – C1_XPE)
    dData := CtoD("")
    dData := DaySub( dDatPRF, nTempoAtravessamento )
    dData := DaySub( dData, nTempoFrete )
    dData := DaySub( dData, nPrazoEntrega )
    AAdd( aItemC1, { "C1_XDTCOMP", dData, NIL } )
    
    // Substituir o C1_DATPRF pelo cálculo: C1_XDTENTR – C1_XTA – C1_XTF
    dData := CtoD("")
    dData := DaySub( dDatPRF, nTempoAtravessamento )
    //dData := DaySub( dData, nTempoFrete )
    aItemC1[ nPosDatPRF, 2 ] := dData

Return( {aItemC1} )
