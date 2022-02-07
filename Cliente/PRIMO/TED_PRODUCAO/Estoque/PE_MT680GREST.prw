#Include "Protheus.ch"
#Include "topconn.ch"


/*/{Protheus.doc} MT680GREST
Ponto de entrada. 
É executado após o estorno do movimento da produção, e permite executar qualquer ação definida pelo operador. 
OBS Para a compilação do PE é necessário que o nome do fisico do aquivo fonte não seja o mesmo nome que MT680GREST.
@author Celso Renee
@since 13/01/2021
@version 1.0
@type function
/*/

User Function MT680GREST()

Local _aArea        := GetArea()

    //dbSelectArea("SB1")
    //dbSetOrder(1)
    //dbSeek(xFilial("SB1") + SH6->H6_PRODUTO)

    if (SD3->D3_ESTORNO == "S" .and. SD3->D3_CF == "PR0" .and. !Empty(SD3->D3_OP))
        dbSelectArea("CB0")
        dbSetOrder(1) //CB0_FILIAL + CB0_CODETIQ
        dbSeek(xFilial("CB0") + SH6->H6_XETIQ)
        if  CB0->(found())
            //Do While (CB0->(!EOF()) //.and. CB0->CB0_OP == SH6->H6_OP .and. CB0->CB0_NUMSEQ == SD3->D3_NUMSEQ)
                RECLOCK("CB0",.F.)
                CB0->(dbDelete())
                CB0->(MsUnlock())
            //CB0->(dbSkip())
            //Enddo
        endif        
    endif


RestArea(_aArea)


Return()
