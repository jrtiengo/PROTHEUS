#INCLUDE "protheus.ch"

User Function BANCO004()

    Local aArea := SB1->(GETAREA())

    DbSelectArea("SB1")
    SB1->(DbSetOrder(1)) //Posiciona no indíce 1 
    SB1->(dbGoTop())

    // Iniciar a Transasão 

    Begin Transaction 

        MsgInfo("A descrição do produto será alterada", "Atenção")

    IF  SB1->(dbSeek(FWxFilial('SB1') + "000000000000001"))
        RecLock('SB1', .F.) // .F. trava registro para alteração - .T. trava para inclusão
        Replace B1_DESC With "PRODUTO 01 - REC"
        SB1->(MsUnlock())
    ENDIF

        MsgAlert("Alteração efetuada", "Atenção")

    End Transaction // Disarm Transaction(), cancela a operação
    RestArea(aArea)
Return
