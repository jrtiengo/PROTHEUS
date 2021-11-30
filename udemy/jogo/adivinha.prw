#INCLUDE "protheus.ch"

User Function adivinha()

    Local nDif   := 0 
    Local nOpc   := 0
    Local nNumF  := RANDOMIZE(1,30)
    Local nNumM  := RANDOMIZE(1,50)
    Local nNumD  := RANDOMIZE(1,100)
    Local nChute := 0
    Local nTent  := 0
    Local cDif   := ""

    nDif := Val(FWInputBox("Escolha a Dificuldade: 1 - F�cil, 2 - M�dio, 3 - Dif�cil ", ""))

    If nDif = 1
        nOpc := nNumF
        cDif := "Dificuldade: F�cil - [ 1 - 30 ]"
    ElseIf nDif = 2
        nOpc := nNumM
        cDif := "Dificuldade: M�dia - [ 1 - 50 ]"
    ElseIf nDif = 3
        nOpc := nNumD
        cDif := "Dificuldade: Dif�cil - [ 1 - 100 ]"
    EndIF

    While nOpc != nChute
    nChute := Val(FWInputBox(" Acerte um numero: " + (cDif), ""))
        If nChute == nOpc
            MsgInfo("Parab�ns, voc� acertou! N�mero: <b>" + CValToChar(nChute) + "</b><b> Erros: " + CValToChar(nTent), "Fim de Jogo")
        ElseIf  nChute > nOpc 
            MsgAlert("Valor Alto", "Tente Novamente") 
            nTent += 1 
        Else 
            MsgAlert("Valor Baixo", "Tente Novamente")
            nTent += 1
        EndIf
    End 

Return
