#Include "Topconn.ch"
#Include "Rwmake.ch"
#Include "Protheus.ch"

/*/{Protheus.doc} SD3250I
//Atualizações das tabelas de apontamento de produção
@author Celso Rene
@since 09/10/2018
@version 1.0
@type function
/*/
User Function SD3250I()

	Local _cDOC	 := SD3->D3_DOC
	Local _aArea := GetArea()	
	

	If ( !Empty(_cDOC) .and. FunName() == "MATA250" )
	
		DBSELECTAREA("SD3")
		DBSETORDER(2) //DOC
		DBSEEK(xFilial("SD3") + _cDOC)
		DO WHILE (!SD3->(EOF() .and. SD3->D3_DOC == _cDOC))
		
		If (SD3->D3_DOC <> _cDOC) //forcando a saida do While -- condicao acima nao saiu
			RestArea(_aArea)
			exit
		EndIf

			Do Case
				Case (SD3->D3_CUSTO1 == 0 .and. SD3->D3_QUANT == 0 .and. SD3->D3_CF = "RE2" .and. SD3->D3_ESTORNO <> "S")  
				RECLOCK("SD3",.F.)
				SD3->(DBDELETE())
				SD3->(MSUNLOCK())  	
			Case (SD3->D3_TM  == "080" .and. SD3->D3_CF == "PR0")
				RECLOCK("SD3",.F.)
				SD3->D3_TM := GETMV("MV_TMPAD")
				SD3->(MSUNLOCK())
			EndCase

			SD3->(dbSkip())
		EndDo

	EndIf


	RestArea(_aArea)

Return()
