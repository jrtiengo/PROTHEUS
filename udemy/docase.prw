#INCLUDE "protheus.ch"
#INCLUDE "parmtype.ch"

User Function  DoCase()

    Local cData := "25/12/2021"

    Do Case 

    Case cData == "20/12/2021"
    Alert("N�o � Natal" + cData)

    Case cData == "25/12/2021"
    Alert("� Natal" + cData)

    OtherWise 
    MsgAlert("N�o sei qual dia � hoje!")

    EndCase

 Return
