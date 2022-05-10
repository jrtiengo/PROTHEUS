#INCLUDE "TOTVS.CH"

/*/{Protheus.doc} SF1140I
PE chamado no final da inclusão e alteração da Pre Nota de Entrada.
@type function
@version 12.1.27
@author Jorge Alberto - Solutio
@since 31/03/2022
/*/
User Function SF1140I()

    Local lInclui := PARAMIXB[1]
    Local lAltera := PARAMIXB[2]

    If( lInclui .Or. lAltera )

        // Chama a rotina de Impressão de Etiquetas
        If MsgYesNo("Deseja realizar a impressão das etiquetas da NF " + AllTrim(SF1->F1_DOC) + " ?", "Impressão de Etiquetas")
            U_PrintEtiq( SF1->F1_DOC, SF1->F1_SERIE, SF1->F1_FORNECE, SF1->F1_LOJA )
        EndIf

    EndIf

Return
