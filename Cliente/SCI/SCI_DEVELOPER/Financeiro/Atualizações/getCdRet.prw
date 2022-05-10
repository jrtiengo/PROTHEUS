#Include 'Protheus.ch'

//User Function getEdPai()
User Function getCdRet()
Local aArea    := GetArea()
Local cEdPai   := SA2->A2_CDRETIR


IF E2_TIPO<>"IN-"
	
cQuery := " SELECT A2_CODINSS "
cQuery += " FROM " + RetSQLName("SE2") + " SE2 "
cQuery += " INNER JOIN SA2010 SA2 ON (LTRIM(RTRIM(SUBSTRING(SE2.E2_TITPAI,18,6)))=SA2.A2_COD "
cQuery += " AND LTRIM(RTRIM(SUBSTRING(SE2.E2_TITPAI,24,4)))=SA2.A2_LOJA AND SE2.E2_TITPAI<>'') "         
cQuery += " WHERE SE2.E2_TIPO='INS' " 
cQuery += " AND SE2.D_E_L_E_T_ <> '*' "    
cQuery += " AND SA2.D_E_L_E_T_ <> '*' "
cQuery += " AND SE2.E2_PREFIXO = '" + E2_PREFIXO + "'"
cQuery += " AND SE2.E2_PARCELA = '" + E2_PARCELA + "'"
cQuery += " AND SE2.E2_NUM     = '" + E2_NUM + "'" 
cQuery += " AND SE2.E2_FILIAL    = '" + xFilial("SE2") + "'" 
cQuery := ChangeQuery(cQuery)
	

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TSE2",.F.,.T.)
DbSelectArea("TSE2")

endif
RestArea(aArea)

return .t.

