#INCLUDE "protheus.ch"

User Function adivinha()

    Local nDif   := 0 
    Local nOpc   := 0
    Local nNumF  := RANDOMIZE(1,30)
    Local nNumM  := RANDOMIZE(1,50)
    Local nNumD  := RANDOMIZE(1,100)
    Local nNumS  := RANDOMIZE(1,1000)
    Local nChute := 0
    Local nTent  := 0
    Local cDif   := ""

    nDif := Val(FWInputBox("Escolha a Dificuldade: 1 - Fácil, 2 - Médio, 3 - Difícil, 4 - Super Difícil ", ""))

    If nDif = 1
        nOpc := nNumF
        cDif := "Dificuldade: Fácil - [ 1 - 30 ]"
    ElseIf nDif = 2
        nOpc := nNumM
        cDif := "Dificuldade: Média - [ 1 - 50 ]"
    ElseIf nDif = 3
        nOpc := nNumD
        cDif := "Dificuldade: Difícil - [ 1 - 100 ]"
    ElseIF nDif = 4
        nOpc := nNumS
        cDif := "Dificuldade: Difícil - [ 1 - 1000]"
    EndIF

    While nOpc != nChute
    nChute := Val(FWInputBox(" Acerte um numero: " + (cDif), ""))
        If nChute == nOpc
            MsgInfo("Parabéns, você acertou! Número: <b>" + CValToChar(nChute) + "</b><b> Erros: " + CValToChar(nTent), "Fim de Jogo")
        ElseIf  nChute > nOpc 
            MsgAlert("Valor Alto", "Tente Novamente") 
            nTent += 1 
        Else 
            MsgAlert("Valor Baixo", "Tente Novamente")
            nTent += 1
        EndIf
    End 

Return
