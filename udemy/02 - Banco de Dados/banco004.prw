#INCLUDE "protheus.ch"

User Function BANCO004()

    Local aArea := SB1->(GETAREA())

    DbSelectArea("SB1")
    SB1->(DbSetOrder(1)) //Posiciona no ind�ce 1 
    SB1->(dbGoTop())

    // Iniciar a Transas�o 

    Begin Transaction 

        MsgInfo("A descri��o do produto ser� alterada", "Aten��o")

    IF  SB1->(dbSeek(FWxFilial('SB1') + "000000000000001"))
        RecLock('SB1', .F.) // .F. trava registro para altera��o - .T. trava para inclus�o
        Replace B1_DESC With "PRODUTO 01 - REC"
        SB1->(MsUnlock())
    ENDIF

        MsgAlert("Altera��o efetuada", "Aten��o")

    End Transaction // Disarm Transaction(), cancela a opera��o
    RestArea(aArea)
Return
