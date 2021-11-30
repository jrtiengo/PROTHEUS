#INCLUDE "protheus.ch"
#INCLUDE "parmtype.ch"

User Function  operador1()

    Local nNum1 := 10 
    Local nNum2 := 20 

/* operadores matematicos
    Alert (nNum1 + nNum2)
    Alert (nNum2 - nNum1)
    Alert (nNum1 * nNum2)
    Alert (nNum2 / nNum1)
    Alert (nNum2 % nNum1)
*/
//operadores relacionais
    Alert (nNum1 < nNum2)
    Alert (nNum1 > nNum2)
    Alert (nNum1 = nNum2)
    Alert (nNum1 == nNum2)
    Alert (nNum1 <= nNum2)
    Alert (nNum1 >= nNum2)
    Alert (nNum1 != nNum2)

/* operadores de atribuicoes
    nNum1 := 10     //atribuicao simples
    nNum1 += nNum2  //nNum1 = nNum1 + nNum2 
    nNum2 -= nNum1  //nNum2 = nNum1 - nNum2 
    nNum1 *= nNum2  //nNum1 = nNum1 * nNum2 
    nNum2 /= nNum1  //nNum2 = nNum2 / nNum1
    nNum2 %= nNum1  //nNum2 = nNum2 % nNum1
*/

Return
