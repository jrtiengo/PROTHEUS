#INCLUDE "protheus.ch"
#INCLUDE "parmtype.ch"

    Static cStat := ''

User Function  escopo1()

//variaveis locais
    local nVar0 := 1 
    local nVar1 := 20

//variaveis private
    private cPri := 'private!'

//variaveis public
    public __cPublic := 'public!'

    TestEscop (nVar0, nVar1)

Return 

//função static

Static Function TestEscop (nValor1, nValor2)

    Local __cPublic := 'alterei'
    DEFAULT nValor1 := 0 

// alterando conteudo da variavel
    nValor2 := 10 

// mostrar conteudo da variavel private
    Alert("Private: " + cPri)

// mostrar conteudo da variavel public
    Alert("Publica: " + __cPublic)

    MsgAlert(nValor2)
    Alert("Variavel Static: " + cStat)

Return
