#INCLUDE "TOTVS.CH"

#DEFINE POS_TEMPOATRAVESSAMENTO 1
#DEFINE POS_TEMPOFRETE          2
#DEFINE POS_PRAZOENTREGA        3

/*/{Protheus.doc} M110STTS
PE executado após a Inclusão/Alteração/Exclusao de uma Solicitação de Compra (SC1)
@type function
@version 
@author Jorge Alberto - Solutio
@since 22/07/2020
/*/
User Function M110STTS()
 
    Local cNumSol   := Paramixb[1]
    Local nOpt      := Paramixb[2] // 1 = Inclusão, 2 = Alteração e 3 = Exclusão
    Local lCopia    := Paramixb[3]
    Local nTempoAtravessamento := 0
    Local nTempoFrete          := 0
    Local nPrazoEntrega        := 0
    Local cFilSC1   := FWxFilial("SC1")
    Local aArea     := GetArea()
    Local aRetTA    := {}
    Local dData     := CtoD("")
    Local dDatPRF   := CtoD("")
    Local cAliAtu   := Alias()
    Local cProd     := ""
    Local cFornece  := ""
    Local cLoja     := ""
    
    If nOpt == 1 .And. !lCopia // Inclusao
        
        DbSelectArea("SC1")
        DbSetOrder(1)
        If DbSeek( cFilSC1 + cNumSol )

            While ( SC1->( !EOF() ) .And. SC1->C1_FILIAL == cFilSC1 .And. SC1->C1_NUM == cNumSol )

                // A função CalSC1TA() é chamada no Gatilho do campo C1_PRODUTO, porém pelo MRP esse gatilho não está sendo executado.
                //If ( Empty( SC1->C1_XDTENTR ) .And. Empty( SC1->C1_XDTFABR ) )
                
                // Cesar Mussi 10.08.2020 : Quando o MRP ja esta com as OPs geradas (manulamente ou pelo próprio) quando as SCs forem
                // geradas, ele considera as datas de entrega como a data base, sem chance... então temos que ir na CZI e tentar
                // Trazer as Datas Corretas que estão la gravadas

                DbSelectArea("CZI")
                DbSetOrder(4)
                DbSeek(xFilial("CZI")+"SC1"+SC1->C1_NUM)
                IF FOUND()
                   dDatPrf := CZI->CZI_DTOG
                   cProd     := SC1->C1_PRODUTO
                   cFornece  := SC1->C1_FORNECE
                   cLoja     := SC1->C1_LOJA
                   aRetTA    := u_GetTA( cProd, cFornece, cLoja )
                   //dData     := SC1->C1_DATPRF
                   //dDatPRF   := SC1->C1_DATPRF

                   nTempoAtravessamento := aRetTA[ POS_TEMPOATRAVESSAMENTO ]
                   nTempoFrete          := aRetTA[ POS_TEMPOFRETE ]
                   nPrazoEntrega        := aRetTA[ POS_PRAZOENTREGA ]

                   //	C1_XTA – Tempo Atravessamento
                   //	C1_XTF – Tempo de Frete
                   //	C1_XPE – Prazo de Entrega do Fornecedor (B1_PEBASE ou A5_PEBASE)

                   //	C1_XDTENTR – Data de Entrega original (cópia do C1_DATPRF)
                   //	C1_XDTFABR – Data de Entrega na Fábrica (C1_XDTENTR – C1_XTA )
                   //	C1_XDTCOMP – Melhor data de compra ( C1_XDTENTR – C1_XTA – C1_XTF – C1_XPE)

                   //	Substituir o C1_DATPRF pelo cálculo: C1_XDTENTR – C1_XTA – C1_XTF
                   dData1 := SOMAPRAZO( dDatPRF, - nTempoAtravessamento )   //C1_XDTFABR
                   dData2 := SOMAPRAZO( dDatPRF, - (nTempoAtravessamento + nTempoFrete + nPrazoEntrega) ) //C1_XDTCOMP
				   
				   //Alterado regra necessidade para não considera tempo frete 28/09/21
                   //dData3 := SOMAPRAZO( dDatPRF, - (nTempoAtravessamento + nTempoFrete ) )
				    dData3 := SOMAPRAZO( dDatPRF, - nTempoAtravessamento )
                   RecLock( "SC1", .F. )
                   SC1->C1_XTA      := nTempoAtravessamento
                   SC1->C1_XTF      := nTempoFrete
                   SC1->C1_XPE      := nPrazoEntrega
                   SC1->C1_XDTENTR  := dDatPRF
                   SC1->C1_XDTFABR  := dData1
                   SC1->C1_XDTCOMP  := dData2
                   SC1->C1_DATPRF   := dData3

                   MsUnLock()
                EndIf

                SC1->( DbSkip() )
            EndDo
        
        EndIf
    EndIf

    RestArea( aArea )
    If !Empty( cAliAtu )
        DbSelectArea( cAliAtu )
    EndIf

Return
