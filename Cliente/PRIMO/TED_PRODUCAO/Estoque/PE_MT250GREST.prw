#Include "Protheus.ch"
#Include "topconn.ch"


/*/{Protheus.doc} MT250GREST
//Ponto de entrada: Grava e ou exclui em tabelas eou campos especificos do usuario apos realizar o estorno
@author Celso Renee
@since 13/01/2021
@version 1.0
@type function
/*/
User Function MT250GREST()

	// Desenvolvido PE SD3250E para atender necessidade de exclusão de Etiqueta. Este ponto entrada (MT250GREST) será desativado.
	Local _aArea    := GetArea()

	if (SD3->D3_ESTORNO == "S" .and. SD3->D3_CF == "PR0" .and. !Empty(SD3->D3_OP))
		dbSelectArea("CB0")
		dbSetOrder(7) //CB0_FILIAL + CB0_OP
		dbSeek(xFilial("CB0") + SD3->D3_OP)
		if (found())
			Do While (CB0->(!EOF()) .and. CB0->CB0_OP == SD3->D3_OP  .and. CB0->CB0_NUMSEQ == SD3->D3_NUMSEQ)
				RECLOCK("CB0",.F.)
				CB0->(dbDelete())
				CB0->(MsUnlock())
				CB0->(dbSkip())
			Enddo
		endif
	endif


	RestArea(_aArea)

Return()

