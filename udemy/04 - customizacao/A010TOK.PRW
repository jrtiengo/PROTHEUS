#INCLUDE "totvs.ch"
#INCLUDE "parmtype.ch"

User Function A010TOK()

    Local lExecuta := .T.
    Local cTipo  := AllTrim(M->B1_TIPO)
    Local cConta := AllTrim(M->B1_CONTA)
    
    if (B1_TIPO = "PA" .and. B1_CONTA = "001")
        Alert("A conta <b> " + Cconta +" </b> não pode estar "+ ;
        "associada a um produto do tipo <b> "  + cTipo)
    EndIF

        lExecuta := .F.

Return (lExecuta)

/*
User Function A010TOK()

Local lExecuta := .T.// Validações do usuário para inclusão ou alteração do produto

    if (B1_TIPO = "PA" .and. B1_CONTA = "001" .and. Inclui)

        MsgInfo("Não é permitido, utilizar a conta 001 para o tipo de produto PA", "Customização")
        lExecuta := .F.
    Else 
        MsgInfo("Inclusão Permitida", "Customização")
    EndIF

Return (lExecuta)
*/
