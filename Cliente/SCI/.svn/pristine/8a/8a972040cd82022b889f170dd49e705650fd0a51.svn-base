#INCLUDE "protheus.ch"
#include "TOPCONN.CH"
#INCLUDE "rwmake.ch"


User function VLRCTRPC(cContrato)

nVlCont:=0
cQuery:=''
cQryPc:=''
cQryUp:=''
nVlIni:=0.00
nVlAtu:=0.00
cRevisa:=''
// Valor do total do contrato

cQuery := " SELECT CN9_VLINI, CN9_VLATU, CN9_VLADIT, CN9_REVISA "
cQuery += " FROM CN9010 "         
cQuery += " WHERE CN9_FILIAL = '" + xFilial("CN9") + "'"
cQuery += " AND CN9_SITUAC='05' "
cQuery += " AND CN9_NUMERO= '" + cContrato + "'"
cQuery += " AND CN9_SCILA<>'S' "  
cQuery += " AND D_E_L_E_T_ <> '*' "    
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"CN9PC",.F.,.T.)
DbSelectArea("CN9PC")

nVlIni :=CN9PC->CN9_VLINI
nVlAtu :=CN9PC->CN9_VLATU
cRevisa:=CN9PC->CN9_REVISA 

DBCloseArea("CN9PC")

cQryPc := " SELECT SUM(CNW_VLPREV) VALOR FROM CNW010 CNW"
cQryPc += " INNER JOIN CNV010 CNV ON ( CNW.CNW_FILIAL=CNV.CNV_FILIAL AND CNW.CNW_CONTRA=CNV.CNV_CONTRA AND "
cQryPc += " CNW.CNW_REVISA=CNV.CNV_REVISA AND CNW.CNW_NUMERO=CNV.CNV_NUMERO AND CNV.D_E_L_E_T_<>'*') "         
cQryPc += " INNER JOIN CNB010 CNB ON ( CNB.CNB_FILIAL=CNV.CNV_FILIAL AND CNB.CNB_CONTRA=CNV.CNV_CONTRA AND "       
cQryPc += " CNB.CNB_REVISA=CNV.CNV_REVISA AND CNB.CNB_NUMERO=CNV.CNV_PLANIL AND CNB.D_E_L_E_T_<>'*') "                                  
cQryPc += " WHERE CNV.CNV_CONTRA     ='" + cContrato + "'"      
cQryPc += " AND RTRIM(CNV.CNV_REVISA)='" + Alltrim(cRevisa) + "'" 
cQryPc += " AND CNV.CNV_FILIAL       ='0101' "
cQryPc += " AND CNW.CNW_FGLPCP       ='C' " 
cQryPc += " AND CNW.D_E_L_E_T_   <>'*' "                                                 

cQryPc := ChangeQuery(cQryPc)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQryPc),"PC",.F.,.T.)
DbSelectArea("PC")



IF (nVlIni >0) 
   nVlCont:=PC->VALOR
End  
     
DBCloseArea("PC")   

IF (nVlIni >0)
	cQryUp :=''
	cQryUp := " UPDATE CN9010 SET CN9_SCILA='S' "         
	cQryUp += " WHERE  CN9_FILIAL       = '" + xFilial("CN9") + "'"
	cQryUp += " AND    CN9_SITUAC='05' "
	cQryUp += " AND    CN9_NUMERO= '" + cContrato + "'" 
	cQryUp += " AND    CN9_SCILA<>'S' " 
	cQryUp += " AND    D_E_L_E_T_ <> '*' "    
	TcSqlExec(cQryUp)
end




Return  nVlCont
