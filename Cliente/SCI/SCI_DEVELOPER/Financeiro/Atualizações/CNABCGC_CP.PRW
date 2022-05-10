#INCLUDE "protheus.ch"
#include "TOPCONN.CH"
#INCLUDE "rwmake.ch"


User function CNABCGC(cPrefixo,cNumero,cParcela)

cCgc:="" 

cQuery := " SELECT A2_CGC,A2_CDCEI "
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
	
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"XSE2",.F.,.T.)
DbSelectArea("XSE2")

IF ALLTRIM(XSE2->A2_CGC)<>""                           
cCgc:=STRZERO(VAL(XSE2->A2_CGC),14)
ELSE
cCgc:=STRZERO(VAL(XSE2->A2_CDCEI),14)
ENDIF

DBCloseArea("XSE2")
Return  cCgc

