#include "protheus.ch"

USER FUNCTION gat02()

//Local cAreaAnt  :=alias()
//Local aAreaSA5  :=SE5->(Getarea())
Local nRet := 0 

IF ExistTrigger('E5_BANCO') .AND. funname() == "FINA100"
    
    RunTrigger(3,nil,nil,,'E5_BANCO')
   nRet := Posicione("SA6",1,XFILIAL("SA6")+M->(E5_BANCO+E5_AGENCIA+E5_CONTA),"A6_AGENCIA") 
                         
Endif
 
//Restarea(aAreaSE5)
//dbSelectArea(cAreaAnt) 

return (nRet)
