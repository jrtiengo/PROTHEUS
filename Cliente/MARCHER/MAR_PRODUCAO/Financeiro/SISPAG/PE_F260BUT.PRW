#INCLUDE "PROTHEUS.CH"

/*
Jean Rehermann - Solutio IT - 09/11/2021
PE que Inclui botões no menu Padrão. Rotina FINA260 - Conciliação DDA
Inserida a opção de conciliação customizada (roda pelo schedule mas poide ser chamada pelo menu)
Essa substitui a conciliação padrão do sistema, sendo que a mesma é jogada para o final do menu de opções
*/
User Function F260BUT()

    Local nO        := 0
    Local aRotina   := {}                   // Novo aRotina que sera Retornado
    Local aConcPad  := {}                   // Backup da Rotina Padrao de Conciliacao
    Local nTotOpc   := Len(ParamIxb)        // Total de Opcoes Padroes


    For nO := 1 To nTotOpc

        If nO == nTotOpc .And. !Empty(aConcPad) // Conciliacao Padrão Sera Incluida no Final da Fila...

             Aadd( aRotina, { aConcPad[1] , aConcPad[2], aConcPad[3], nO } )
             Aadd( aRotina, { ParamIxb[nO][1] , ParamIxb[nO][2], ParamIxb[nO][3], (nO + 1) } )

        Else

            If Alltrim(ParamIxb[nO][2]) == "F260Conc"  // Substitui Conciliacao Padrao pela Customizada ...
                Aadd( aRotina, { "Conciliar AUTO"	,"U_DDAConMan()" , 0 , nO } )
                aConcPad := ParamIxb[nO] // Backup da Conciliacao Padrao...
            Else
                Aadd( aRotina, ParamIxb[nO] )
            EndIf

        EndIf

    Next nO

Return aRotina
