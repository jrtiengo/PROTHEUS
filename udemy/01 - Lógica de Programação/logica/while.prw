#INCLUDE "protheus.ch"
#INCLUDE "parmtype.ch"

User Function  while()

    Local nNum1 := 1
    Local cNome := "RCTI" 

    While nNum1 != 10 .AND. cNome != "PROTHEUS"
        nNum1++
        IF nNUm1 == 5
        cNome := "PROTHEUS"
        EndIF
    EndDo
        Alert("Numero: "+ cValToChar(nNum1))  
        Alert("Nome: "+ cValToChar(cNome))
Return
