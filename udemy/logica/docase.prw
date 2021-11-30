#INCLUDE "protheus.ch"
#INCLUDE "parmtype.ch"

User Function  DoCase()

    Local cData := "25/12/2021"

    Do Case 

    Case cData == "20/12/2021"
    Alert("Não é Natal" + cData)

    Case cData == "25/12/2021"
    Alert("É Natal" + cData)

    OtherWise 
    MsgAlert("Não sei qual dia é hoje!")

    EndCase

 Return
