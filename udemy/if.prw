#INCLUDE "protheus.ch"
#INCLUDE "parmtype.ch"

User Function  if()

    Local nNum1 := 22
    Local nNum2 := 100

    IF (nNum1 = nNum2)
    MsgInfo("A variavel nNum1 é igual a nNum2")

    elseif (nNum1 > nNum2)
    MsgInfo("A variavel nao é maior")
    
    elseif (nNum1 != nNum2)
    Alert("A Variavel nNum1 é diferente de nNum2") 

    ENDIF

Return        
