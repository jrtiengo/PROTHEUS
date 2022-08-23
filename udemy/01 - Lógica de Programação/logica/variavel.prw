#INCLUDE "protheus.ch"

/*
TIPOS DE DADOS
NUMEROS: 3 / 21.000 / 0.4 / 21000
LÓGICOS: .T. / .F. 
CARACTERE: " CARACTER " (aspas simples ou dulas)
DATA: DATE() (função que retorna a data)
ARRAY: ("VALOR1", "VALOR2", "VALOR3")
BLOCO DE CÓDIGO: {||VALOR : = 1, MSGALERT("VALOR É IGUAL A: "+cValToChar(VALOR))}
*/

User Function  VARIAVEL()
    
    Local nNum      := 66
    Local lLogic    := .T.
    Local cCarac    := "String"
    Local dData     := DATE()
    Local aArray    := {"Joao", "Maria", "Jose"}
    Local bBloco    := {|| nValor := 2, MsgAlert("O n�mero �: "+ cValToChar(nValor))}

    Alert(nNum)
    Alert(lLogic)
    Alert(CValToChar(cCarac))
    Alert(dData)
    Alert(aArray[1])
    Eval(bBloco) 

Return 
