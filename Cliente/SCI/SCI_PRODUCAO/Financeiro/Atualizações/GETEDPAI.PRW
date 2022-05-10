#Include 'Protheus.ch'

User Function getEdPai()
Local aArea    := GetArea()

Alert ('TIPO'+E2_TIPO)
Alert ('TITPAI'+E2_TITPAI)

IF E2_TIPO="IN-"
	
	cQuery := " SELECT E2_NATUREZ "
	cQuery += " FROM " + RetSQLName("SE2") + " SE2 "
	cQuery += " WHERE SE2.E2_TIPO<>'IN-' "
	cQuery += " AND SE2.D_E_L_E_T_ <> '*' "
	cQuery += " AND SE2.E2_PREFIXO = '" + E2_PREFIXO + "'"
	cQuery += " AND SE2.E2_PARCELA = '" + E2_PARCELA + "'"
	cQuery += " AND SE2.E2_NUM     = '" + E2_NUM + "'"
	cQuery += " AND SE2.E2_FILIAL    = '" + xFilial("SE2") + "'"
	cQuery := ChangeQuery(cQuery)
	
	
	DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TSE2",.F.,.T.)
	DbSelectArea("TSE2")
	E2_NATUREZ:=TSE2->E2_NATUREZ	
    DBCloseArea("TSE2")
endif
RestArea(aArea)

return .t.

