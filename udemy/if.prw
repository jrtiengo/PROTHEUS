#INCLUDE "protheus.ch"
#INCLUDE "parmtype.ch"

User Function  if()

    Local nNum1 := 22
    Local nNum2 := 100

    IF (nNum1 = nNum2)
    MsgInfo("A variavel nNum1 � igual a nNum2")

    elseif (nNum1 > nNum2)
    MsgInfo("A variavel nao � maior")
    
    elseif (nNum1 != nNum2)
    Alert("A Variavel nNum1 � diferente de nNum2") 

    ENDIF

Return        
