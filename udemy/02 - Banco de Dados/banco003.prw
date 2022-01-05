#INCLUDE "protheus.ch"
#INCLUDE "TopConn.ch"

User Function BANCO003()

    Local aArea     := SB1->(GETAREA())
    Local cQuery    := ""
    Local aDados    := {}
    Local nCount    := 0

    cQuery := " SELECT "
    cQuery += " B1_COD AS CODIGO, "
    cQuery += " B1_DESC AS DESCRICAO "
    cQuery += " FROM "
    cQUery += " "+ RetSQLName("SB1")+ " SB1 "
    cQUery += " WHERE "
    cQUery += " B1_MSBLQL != 1 AND D_E_L_E_T_ = '' "

    //Executando a consulta acima

    TCQuery cQUery New Alias "TMP"

    while ! TMP->(EoF())
        AADD(aDados, TMP->CODIGO)
        AADD(aDados, TMP->DESCRICAO)
        TMP->(DbSkip())
    enddo

        Alert(Len(aDados))

        For nCount := 1 To Len(aDados)
            MsgInfo(aDados[nCount])
        Next nCount

        TMP-> (DbCloseArea())
        RestArea(aArea)

Return
