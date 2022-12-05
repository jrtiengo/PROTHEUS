#Include "Protheus.ch"
#Include "TOTVS.ch"

/*/{Protheus.doc} AT500OK
 
@author Lucas Moresco
@since 08/09/2014
@version 1.0
/*/
User Function AT500OK()

   Local cQry  := ""
   Local aArea := GetArea()

   For ix := 1 To Len(aCols)
		
	   _nDel := Len( aHeader ) + 1 

	   If _nDel == Nil
	      Loop
       Endif

       // ######################################################################
       // Verificando última posição do acols para verificar deleção da linha ##
       // ######################################################################
	   _lDel := aCols[ ix, _nDel ] 
	
	   If _nDel == Nil
	      Loop
	   Endif
		
// 	   If (aCols[ix][GdFieldPos("ABB_REC_WT",aHeader) + 1])
  
       If _lDel

			If Select("TECA500ZZZ") > 0
				TECA500ZZZ->(dbCloseArea())
			EndIf
		
			cQry := "Select Top(1) ZZZ_NUMOS From "+RetSqlName("ZZZ")+" ZZZ(NoLock) "+chr(13)
			cQry += "Where ZZZ.ZZZ_NUMOS = '"+aCols[ix][GdFieldPos("ABB_NUMOS",aHeader)]+"' And "+chr(13)
			cQry += "ZZZ.ZZZ_FILIAL = '"+xFilial("ABB")+"' And "+chr(13)
			cQry += "ZZZ.D_E_L_E_T_ <> '*' "+chr(13)
			cQry := ChangeQuery(cQry)
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), "TECA500ZZZ", .T., .T. )
		
			TECA500ZZZ->( DbGoTop() )
	
			While ! Eof()
				MsgAlert("Atenção! Este Agendamento X O.S. não poderá ser exclúido. Existe uma Req. de Peças ativa para esta O.S.")	
//				aCols[ix][GdFieldPos("ABB_REC_WT",aHeader) + 1] := .F.
                aCols[ix,_nDel] := .F.
				DbSkip()
			EndDo
			
			TECA500ZZZ->(dbCloseArea())	
	
		EndIf

	Next
	
	RestArea(aArea)

Return() 