#INCLUDE "protheus.ch"
#include "TOPCONN.CH"
#INCLUDE "rwmake.ch"


User Function FA050UPD()

LOCAL cCodRet:=""

cQuery := " SELECT A2_CDRETIR "
cQuery += " FROM " + RetSQLName("SE2") + " SE2 "
cQuery += " INNER JOIN SA2010 SA2 ON (LTRIM(RTRIM(SUBSTRING(SE2.E2_TITPAI,18,6)))=SA2.A2_COD "
cQuery += " AND LTRIM(RTRIM(SUBSTRING(SE2.E2_TITPAI,24,4)))=SA2.A2_LOJA AND SE2.E2_TITPAI<>'') "         
cQuery += " WHERE SE2.E2_TIPO='IN-' " 
cQuery += " AND SE2.D_E_L_E_T_ <> '*' "    
cQuery += " AND SA2.D_E_L_E_T_ <> '*' "
cQuery += " AND SE2.E2_PREFIXO = '" + SE2->E2_PREFIXO + "'"
cQuery += " AND SE2.E2_PARCELA = '" + SE2->E2_PARCELA + "'"
cQuery += " AND SE2.E2_NUM     = '" + SE2->E2_NUM + "'" 
cQuery += " AND SE2.E2_FILIAL    = '" + xFilial("SE2") + "'" 
cQuery := ChangeQuery(cQuery)
	

DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TSE2",.F.,.T.)
DbSelectArea("TSE2")

cCOdRet:=TSE2->A2_CDRETIR

TSE2->(dbCloseArea())


If SE2->E2_PREFIXO='ADT'
	RecLock("SE2",.F.)
	SE2->E2_EMISSAO:= dDataBase
	SE2->E2_EMIS1  := dDataBase
	
	If SE2->E2_VENCTO  <dDataBase
		SE2->E2_VENCTO :=dDataBase
		SE2->E2_VENCREA:=dDataBase
	END
	MsUnlock()
END


/*

alert('TIPO '+SE2->E2_TIPO+' COD RET '+cCOdRet)

IF ALLTRIM(SE2->E2_TIPO)<>"TX"
	
	IF SE2->E2_VRETIRF>0
		RecLock("SE2",.F.)
		SE2->E2_DIRF  :='2'
		SE2->E2_CODRET:=cCOdRet
		MsUnlock()
	endif
else

		RecLock("SE2",.F.)
		SE2->E2_DIRF  :='1'
		SE2->E2_CODRET:=cCOdRet
endif*/





return(.T.)
