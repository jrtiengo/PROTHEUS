#Include "Rwmake.ch"
#Include "Protheus.ch"

User Function CreateCVD

Local cQry        := ""
Local nCount      := 0
Local aArea       := GetArea()
Local aAreaCT1    := CT1->(GetArea())
Local aAreaCVD    := CVD->(GetArea())

	If (Select("TMPCVD")) > 0
		TMPCVD->(DbCloseArea())
	EndIf

	cQry := "SELECT * FROM "+RetSqlName("CT1")+" CT1 "+chr(13)
	cQry += "WHERE "+chr(13)
	cQry += "CT1.CT1_CONTA NOT IN "+chr(13) 
	cQry += "(SELECT CVD_CONTA FROM "+RetSqlName("CVD")+" CVD WHERE CVD.CVD_FILIAL = '"+xFilial("CVD")+"' AND CVD.D_E_L_E_T_ <> '*') AND "+chr(13)
	cQry += "CT1.CT1_CLASSE = '2' AND "+chr(13)
	cQry += "CT1.CT1_FILIAL = '"+xFilial("CT1")+"' AND "+chr(13)
	cQry += "CT1.D_E_L_E_T_ <> '*' "
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"TMPCVD",.T.,.T.)
	
	DbSelectArea("TMPCVD");DbGoTop()
	
	While !Eof()
	
			If (SubStr(TMPCVD->CT1_CONTA,1,1) == "1")
				CVD->(RecLock("CVD",.T.))
				    CVD->CVD_FILIAL := xFilial("CVD")
				    CVD->CVD_CONTA  := TMPCVD->CT1_CONTA
				    CVD->CVD_ENTREF := "10"
				    CVD->CVD_CODPLA := "001"
				    CVD->CVD_CTAREF := "1.01.02.02.05" //"1.01.02.02.01"
				    CVD->CVD_TPUTIL := "A"
				    CVD->CVD_CLASSE := "2"
				    CVD->CVD_NATCTA := "01"
					CVD->CVD_CTASUP := "1.01.02.02"
				CVD->(MsUnlock())   
			ElseIf(SubStr(TMPCVD->CT1_CONTA,1,1) == "2")
				CVD->(RecLock("CVD",.T.))
					CVD->CVD_FILIAL := xFilial("CVD")
					CVD->CVD_CONTA  := TMPCVD->CT1_CONTA
					CVD->CVD_ENTREF := "10"
					CVD->CVD_CODPLA := "001"
					CVD->CVD_CTAREF := "2.01.01.03.01"
					CVD->CVD_TPUTIL := "A"
					CVD->CVD_CLASSE := "2"
					CVD->CVD_NATCTA := "02"
					CVD->CVD_CTASUP := "2.01.01.03"
				CVD->(MsUnlock())   
			EndIf
		
		nCount++
		TMPCVD->(DbSkip())
	EndDo

	If (Select("TMPCVD")) > 0
		TMPCVD->(DbCloseArea())
	EndIf

	RestArea(aArea)
	RestArea(aAreaCT1)
	RestArea(aAreaCVD)

	MsgAlert("Operação realizada com sucesso! "+cValToChar(nCount)+" Registros gerados na tabela CVD.")

Return()