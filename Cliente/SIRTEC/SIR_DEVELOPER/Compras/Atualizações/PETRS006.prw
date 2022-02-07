#Include "Protheus.ch"
#Include "RwMake.ch"

User Function PETRS006()
	Local aRet	    := {}
	Local aArea		:= GetArea()
	Local _aTRS006	:= PARAMIXB
	Local _aCabec	:= _aTRS006[3]
	Local _aLinha	:= _aTRS006[4]
	Local nPosQtd	:= 0
	Local nPosQtSeg := 0
	Local nPosProd 	:= 0
	Local cLog 		:= ''
	Local nN 		:= 1
	
	ConOut('PETRS006')
	ConOut('************************************************')
	// Alimenta log
	For nN := 1 To Len(_aCabec)
		cLog += cValToChar(_aCabec[nN, 1]) +  ': ' + cValToChar(_aCabec[nN, 2]) + ' | '
	Next
	//

	If aScan(_aLinha,{|x| x[1] == "D1_QUANT"}) > 0 
		nPosQtd	:= aScan(_aLinha,{|x| x[1] == "D1_QUANT"})
	EndIf
	
	If aScan(_aLinha,{|x| x[1] == "D1_QTSEGUM"}) > 0 
		nPosQtSeg := aScan(_aLinha,{|x| x[1] == "D1_QTSEGUM"})
	EndIf

	If aScan(_aLinha,{|x| x[1] == "D1_COD"}) > 0 
		nPosProd := aScan(_aLinha,{|x| x[1] == "D1_COD"})
	EndIf
	
	// Alert(xFilial('SB1') + PadR(_aLinha[nPosProd, 2], TamSX3('B1_COD')[1]))
	SB1->(dbSetOrder(1))
	If SB1->(MsSeek(xFilial('SB1') + PadR(_aLinha[nPosProd, 2], TamSX3('B1_COD')[1])))
		cLog := ''
		// Alert('Found')
		If nPosQtSeg > 0
			If SB1->B1_TIPCONV == 'M'
				AADD(aLinha, {"D1_QUANT", _aLinha[nPosQtSeg, 2] / SB1->B1_CONV, Nil, Nil})
			Else
				AADD(aLinha, {"D1_QUANT", _aLinha[nPosQtSeg, 2] * SB1->B1_CONV, Nil, Nil})
			EndIf
		Else
			If SB1->B1_TIPCONV == 'M'
				AADD(aLinha, {"D1_QTSEGUM", _aLinha[nPosQtd, 2] * SB1->B1_CONV, Nil, Nil})
			Else
				AADD(aLinha, {"D1_QTSEGUM", _aLinha[nPosQtd, 2] / SB1->B1_CONV, Nil, Nil})
			EndIf
		EndIf
		
		AADD(_aLinha, {"D1_UM"		,SB1->B1_UM 	,Nil, Nil})
		If !Empty(AllTrim(SB1->B1_SEGUM))
			AADD(_aLinha, {"D1_SEGUM"	,SB1->B1_SEGUM 	,Nil, Nil})
		EndIf
		
		AADD(_aLinha, {"D1_TDESCPR"	,SB1->B1_DESC 	,Nil, Nil})
		AADD(_aLinha, {"D1_CONTA"	,SB1->B1_CONTA 	,Nil, Nil})
		AADD(_aLinha, {"D1_CC"		,SB1->B1_CC 	,Nil, Nil})
		AADD(_aLinha, {"D1_LOCAL"	,SB1->B1_LOCPAD ,Nil, Nil})
		AADD(_aLinha, {"D1_ITEMCTA"	,"" 			,Nil, Nil})
		
		cLog += 'Encontrou SB1'
	Else
		cLog += 'Não encontrou SB1'
	EndIf

	aRet := {_aCabec,_aLinha}
	RestArea(aArea)
	MemoWrite(AllTrim(_aCabec[3,2]) + '.txt', cLog)
Return aRet