#INCLUDE "protheus.ch"
#INCLUDE "parmtype.ch"

// arrays são coleções de valores, semelhantes a uma lista, cada item em um array é referenciado pela indicação
// de sua posição numerica, iniciando pelo numero 1 

User Function  aVetor()

    Local dData     := Date()
    Local aValores := {"João", dData, 100}

    Alert(aValores[2])
    Alert(aValores[3])

Return
