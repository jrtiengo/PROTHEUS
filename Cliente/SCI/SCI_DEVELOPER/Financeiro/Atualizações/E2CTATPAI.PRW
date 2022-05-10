#INCLUDE "protheus.ch"
#include "TOPCONN.CH"
#INCLUDE "rwmake.ch"


User function CTATPAI(cNumero,cParcela,cTitPai)

cCtaCtb:="" 

cQuery := " SELECT E1_CTACTB"
cQuery += " FROM " + RetSQLName("SE1") + " SE1 "
cQuery += " WHERE " 
cQuery += " SE1.D_E_L_E_T_ <> '*' "    
cQuery += " AND SE1.E1_PARCELA = '" + (SUBSTR(cTitPai,13,2)) + "'"
cQuery += " AND SE1.E1_NUM     = '" + (SUBSTR(cTitPai,4,9))  + "'" 
cQuery += " AND SE1.E1_FILIAL    = '" + xFilial("SE1") + "'" 
cQuery := ChangeQuery(cQuery)
	
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TSE1",.F.,.T.)
DbSelectArea("TSE1")

cCtaCtb:=ALLTRIM(TSE1->E1_CTACTB)
DBCloseArea("TSE1")
Return  cCtaCtb