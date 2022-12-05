#Include "Protheus.ch"
#Include "TOTVS.ch"

/*/{Protheus.doc} AUTG013
 
@author Lucas Moresco
@since 30/06/2014
@version 1.0
/*/
User Function AUTG013()

Local aArea    := GetArea()
Local aAreaZZZ := GetArea("ZZZ")

Local cStatus := M->AB6_APROV
Local cQry    := ""

	If (! M->AB6_APROV $ "SN")
		cStatus := AB6->AB6_APROV
		MsgAlert("Atenção, não é possível a troca para este status.")
	EndIf

	If (M->AB6_APROV $ "SN")
	

		Iif(Select("ZZZSTAT")!=0, ZZZSTAT->(DbCloseArea()),)

		cQry := "Select ZZZ_NUMOS From "+RetSqlName("ZZZ")+" ZZZ(NoLock) "+chr(13)
		cQry += "Where "+chr(13) 
		cQry += "ZZZ.ZZZ_NUMOS =  '"+M->AB6_NUMOS+"' And "+chr(13)
		If (M->AB6_APROV == "S")
			cQry += "ZZZ.ZZZ_SALDO <> 0 And "+chr(13)
		Else
			cQry += "ZZZ.ZZZ_SALDO = 0 And "+chr(13)
		EndIf
		cQry += "ZZZ.ZZZ_FILIAL = '"+xFilial("ZZZ")+"' And "
		cQry += "ZZZ.D_E_L_E_T_ <> '*' "
		cQry := ChangeQuery(cQry)
	
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cQry), "ZZZSTAT", .T., .T. )
	
		DbSelectArea("ZZZSTAT"); DbGoTop()
	
		While ! Eof()
			MsgAlert("Atenção, Não é possível alterar o status da OS, existe req. de peças pendente.")
			cStatus := AB6->AB6_APROV
			Exit
		EndDo
	
		
		Iif(Select("ZZZSTAT")!=0, ZZZSTAT->(DbCloseArea()),)
		
	EndIf
	

	RestArea(aAreaZZZ)	
	RestArea(aArea)  
	
Return(cStatus)