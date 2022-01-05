#INCLUDE "protheus.ch"

User Function BANCO002()

    Local aArea := SB1->(GETAREA())
    Local cMsg  := ""

    DbSelectArea("SB1")
    SB1->(DbSetOrder(1)) //Posiciona no indíce 1 
    SB1->(dbGoTop())

    // 
    cMsg := Posicione(  "SB1",;
                        1,;   
                        FWXFilial("SB1") + "000000000000001",;
                        "B1_DESC")
    Alert("Descrição do Produto: " +cMsg, "AVISO")

    RestArea(aArea)
Return
