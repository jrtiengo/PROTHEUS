#INCLUDE "protheus.ch"
#include "TOPCONN.CH"
#INCLUDE "rwmake.ch"


User function CNABCODINSS(cPrefixo,cNumero,cParcela)

cCodInss:=0 

cQuery := " SELECT A2_CODINSS "
cQuery += " FROM " + RetSQLName("SE2") + " SE2 "
cQuery += " INNER JOIN SA2010 SA2 ON (LTRIM(RTRIM(SUBSTRING(SE2.E2_TITPAI,18,6)))=SA2.A2_COD "
cQuery += " AND LTRIM(RTRIM(SUBSTRING(SE2.E2_TITPAI,24,4)))=SA2.A2_LOJA AND SE2.E2_TITPAI<>'') "         
cQuery += " WHERE SE2.E2_TIPO='INS' " 
cQuery += " AND SE2.D_E_L_E_T_ <> '*' "    
cQuery += " AND SA2.D_E_L_E_T_ <> '*' "
cQuery += " AND SE2.E2_PREFIXO = '" + cPrefixo + "'"
cQuery += " AND SE2.E2_PARCELA = '" + cParcela + "'"
cQuery += " AND SE2.E2_NUM     = '" + cNumero + "'" 
cQuery += " AND SE2.E2_FILIAL    = '" + xFilial("SE2") + "'" 
cQuery := ChangeQuery(cQuery)
	
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TSE2",.F.,.T.)
DbSelectArea("TSE2")

cCodInss:=TSE2->A2_CODINSS
//DBCloseArea("TSE2")
Return  cCodInss

