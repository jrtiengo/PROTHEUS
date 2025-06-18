#include "protheus.ch"

User Function CN100COR()

	Local xParam := PARAMIXB[1]
	Local aRet := {}

	DO CASE

	CASE ValType(xParam) == "A"

		//- Alteração total da legenda vermelha (RED).
		nPos := aScan(xParam, {|x|UPPER(x[2]) == 'RED'})
		xParam[nPos,1] := "Alltrim(CN9->CN9_SITUAC) == 'Z1'" //- Condição
		xParam[nPos,2] := "BLACK" //- Cor
		xParam[nPos,3] := "Legenda Customizada 1" //- Texto

//- Inclui nova cor para legenda.
		aAdd(xParam,{"Alltrim(CN9->CN9_SITUAC) == 'Z2'","RED","Legenda Customizada 2"})

	CASE ValType(xParam) == "O"

//- Adição de legenda por Browser
		xParam:AddLegend("Alltrim(CN9->CN9_SITUAC) == 'Z3'","GREEN","Legenda Customizada 3")

	ENDCASE

	aRet := xParam

Return(aRet)

