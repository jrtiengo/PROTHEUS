#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} MT103FIM
PE chamado no final da inclus�o da NF de Entrada.
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 21/03/2022
/*/
User Function MT103FIM()

    Local nOpcao := PARAMIXB[1]  // Op��o escolhida [1=Pesquisar/2=Visualiza/3=Inclui/4=Altera/5=Exclui]
    Local nAcao  := PARAMIXB[2]  // 0 = N�o confirmou a tela / 1 = Confirmou a tela

    If( ( nOpcao == 2 .Or. nOpcao == 3 ) .And. nAcao == 1 )

        // Chama a rotina de Impress�o de Etiquetas
        If MsgYesNo("Deseja realizar a impress�o das etiquetas da NF " + AllTrim(SF1->F1_DOC) + " ?", "Impress�o de Etiquetas")
            U_PrintEtiq( SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA )
        EndIf

    EndIf

Return
