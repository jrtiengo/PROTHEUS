#INCLUDE "totvs.ch"
#INCLUDE "parmtype.ch"

User Function A010TOK()

    Local lExecuta := .T.
    Local cTipo  := AllTrim(M->B1_TIPO)
    Local cConta := AllTrim(M->B1_CONTA)
    
    if (B1_TIPO = "PA" .and. B1_CONTA = "001")
        Alert("A conta <b> " + Cconta +" </b> n�o pode estar "+ ;
        "associada a um produto do tipo <b> "  + cTipo)
    EndIF

        lExecuta := .F.

Return (lExecuta)

/*
User Function A010TOK()

Local lExecuta := .T.// Valida��es do usu�rio para inclus�o ou altera��o do produto

    if (B1_TIPO = "PA" .and. B1_CONTA = "001" .and. Inclui)

        MsgInfo("N�o � permitido, utilizar a conta 001 para o tipo de produto PA", "Customiza��o")
        lExecuta := .F.
    Else 
        MsgInfo("Inclus�o Permitida", "Customiza��o")
    EndIF

Return (lExecuta)
*/
