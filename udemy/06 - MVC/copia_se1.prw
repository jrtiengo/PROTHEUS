#include 'protheus.ch'
#include 'FwMvcDef.ch'

user function copiaSE1()

Local cSecondChar := 'CE123'

If Substring(cSecondChar,1,2) =='CE'
    // Adicione aqui o c�digo que ser� executado se a condi��o for verdadeira
    MsgInfo("Os dois primeiros caracteres s�o 'AB'")
Else
    // Adicione aqui o c�digo que ser� executado se a condi��o for falsa
    MsgInfo("Os dois primeiros caracteres n�o s�o 'AB'")
EndIf

Return()


