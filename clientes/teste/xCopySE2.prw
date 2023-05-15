#INCLUDE "Protheus.ch"

User Function xCopySE2()

    Local aArray := {}
	Local nXErr  := 0
	Local nIx 	 := 0
	Local cCodFor  := ''
	Local cLoja    := ''
	Local aTitulos := {}
      
    Private lMsErroAuto := .F.
     
	If Len(aTitulos) = 0
       MsgStop('Não há títulos para gerar.','Erro')
       Return()
    EndIf   

	cCodFor  := Posicione("SA2",3,xFilial("SA2") + Substr(aTitulos[nIx][5],1, At("-", aTitulos[nIx][5])- 1), "A2_COD")
	cLoja  := Posicione("SA2",3,xFilial("SA2") + Substr(aTitulos[nIx][5],1, At("-", aTitulos[nIx][5])- 1), "A2_LOJA")
	
	For nIx := 1 To Len(aTitulos)
	    
	    If  Empty(aTitulos[nIx][10])
	    	
	    	aArray := { { "E2_PREFIXO"  , aTitulos[nIx][1]          				, NIL },;
	    				{ "E2_NUM"      , aTitulos[nIx][2]          				, NIL },;
	    				{ "E2_TIPO"     , aTitulos[nIx][3]          				, NIL },;
	    				{ "E2_NATUREZ"  , aTitulos[nIx][4]          				, NIL },;
	    				{ "E2_FORNECE"  , cCodFor                                   , NIL },;
	    				{ "E2_LOJA"     , cLoja                                     , NIL },;
	    				{ "E2_EMISSAO"  , cToD(aTitulos[nIx][6])    				, NIL },;
	    				{ "E2_VENCTO"   , cToD(aTitulos[nIx][7])    				, NIL },;
	    				{ "E2_VENCREA"  , CtoD(aTitulos[nIx][8])    				, NIL },;
	    				{ "E2_VALOR"    , Val(StrTran(aTitulos[nIx][9],",", "."))  	, NIL } }
      
    MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 3)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
      
	    	If lMSErroAuto
				aErr    := GetAutoGrLog()   
				cRetErr := ''  
				For nXErr := 1 To Len(aErr)
					cRetErr += aErr[nXErr] + Crlf
				Next nXErr
				aTitulos[nIx, 10] := cRetErr
			Else
                aTitulos[nIx, 10] := 'Titulo gerado Ok'
				nOk ++
			EndIf 
	    EndIf	
	Next nIx
Return
