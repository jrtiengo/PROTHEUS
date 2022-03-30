#INCLUDE "protheus.ch"

User Function RelTXT()

        If MsgYesNo("Deseja gerar um arquivo TXT", "Gera TXT")
           //GeraArq()      
           Processa({|| MntQry() },,"Processando...")
           MsAguarde({|| GeraArq() },, "O arquivo TXT está sendo gerado...")
   
        else
            MsgAlert("Cancelada pelo operador", "Cancelada")
   
        EndIF

Return NIL

Static Function MntQry()

    local cQuery := ""

    cQuery := " SELECT B1_FILIAL AS FILIAL, B1_COD AS CODIGO, "
    cQuery += " B1_DESC AS DESCRICAO "
    cQuery += " FROM SB1990 WHERE D_E_L_E_T_ = '' "

    cQuery := ChangeQuery(cQuery)
        DbUseArea(.T., "TOPCONN", TCGENQRY(,,cQuery), "TMP", .F., .T.)
Return NIL

Static Function GeraArq()

    Local cDir      := "C:\temp\"
    Local cArq      := "arquivo2.txt"
    Local nHandle   := FCreate(cDir+cArq)
   // Local nLinha    := 0

        If nHandle < 0 
            MsgAlert("Erro ao criar o arquivo", "Erro")

        Else 
            While TMP->(!EOF())
                FWrite(nHandle, TMP->(FILIAL)+ " | " + TMP->(CODIGO) + " | " + TMP->(DESCRICAO) + CRLF)
                TMP->(dbSkip())
            EndDo
/*
            For nLinha := 1 to 200 
                FWrite(nHandle,"Gravando a linha " + StrZero(nLinha,3)+ CRLF)
            Next nLinha
*/
            FClose(nHandle)

        EndIF

        If FILE("C:\temp\arquivo2.txt")
            MsgInfo("Arquivo Criado com Sucesso", "Sucesso!")
        
        Else 
            MsgAlert("Não foi possível criar o arquivo", "Alerta")

        EndIF
Return
