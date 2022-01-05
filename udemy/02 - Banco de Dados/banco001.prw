#INCLUDE "protheus.ch"

User Function BANCO001()

    Local aArea := SB1->(GETAREA())

    DbSelectArea("SB1")
    SB1->(DbSetOrder(1)) //Posiciona no indíce 1 
    SB1->(dbGoTop())

    // Posiciona o produto de código 000000000000001

    IF SB1->(dbseek(FWXFilial("SB1") + "000000000000001"))
        Alert(SB1->B1_DESC)

    ENDIF

    RestArea(aArea)

RETURN


