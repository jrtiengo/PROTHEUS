#include 'protheus.ch'
#include 'FwMvcDef.ch'

user function copiaSE1()

Local cSecondChar := 'CE123'

If Substring(cSecondChar,1,2) =='CE'
    // Adicione aqui o código que será executado se a condição for verdadeira
    MsgInfo("Os dois primeiros caracteres são 'AB'")
Else
    // Adicione aqui o código que será executado se a condição for falsa
    MsgInfo("Os dois primeiros caracteres não são 'AB'")
EndIf

Return()


