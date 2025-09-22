#Include "PROTHEUS.CH"

/*/{Protheus.doc} MT103MNT
Ponto de entrada para carregar automaticamente o aCols de múltiplas naturezas
Versão 2 - Com detecção automática da posição dos campos
@type function
@version 12.1.33
@author Sistema
@since 2024
@return array, Array com os dados do rateio das naturezas para o aCols
/*/
User Function MT103MNT()
    Local aArea     := GetArea()
    Local aAreaSD1  := SD1->(GetArea())
    Local aAreaSB1  := SB1->(GetArea())
    Local aAreaSF4  := SF4->(GetArea())
    Local aAreaCTT  := CTT->(GetArea())
    Local aColsRet  := {}
    Local aRateio   := {}
    Local aAglut    := {}
    Local nTotNF    := 0
    Local nTotPerc  := 0
    Local nDifPerc  := 0
    Local nMaiorVal := 0
    Local cNatMaior := ""
    Local cNatureza := ""
    Local nX        := 0
    Local nPos      := 0
    Local lTemNat   := .T.
    Local cMsgErro  := ""
    Local cQuebraLin := Chr(13) + Chr(10)
    Local cMsg      := ""
    
    // Variáveis do MATA103 - Itens da NF
    Local nPosCod   := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_COD"})
    Local nPosTes   := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_TES"})
    Local nPosCC    := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_CC"})
    Local nPosTotal := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_TOTAL"})
    Local nPosItem  := aScan(aHeader, {|x| AllTrim(x[2]) == "D1_ITEM"})
    Local cProduto  := ""
    Local cTes      := ""
    Local cCCusto   := ""
    Local nValor    := 0
    Local cItem     := ""
    
    // Variáveis para posição dos campos da SEV no aCols
    Local aHeaderSEV := {}
    Local nPosNat   := 0
    Local nPosPerc  := 0
    Local nPosVal   := 0
    Local nPosRat   := 0
    Local aLinha    := {}
    
    // Tenta obter o aHeader da SEV (múltiplas naturezas)
    If Type("aColsSev") == "A"
        // Se já existe um aCols de SEV, usa ele como referência
        If Len(aColsSev) > 0
            // Cria uma linha modelo baseada no aCols existente
            aLinha := aClone(aColsSev[1])
            // Limpa os valores
            For nX := 1 To Len(aLinha)
                Do Case
                    Case ValType(aLinha[nX]) == "C"
                        aLinha[nX] := Space(Len(aLinha[nX]))
                    Case ValType(aLinha[nX]) == "N"
                        aLinha[nX] := 0
                    Case ValType(aLinha[nX]) == "L"
                        aLinha[nX] := .F.
                EndCase
            Next nX
        EndIf
    EndIf
    
    // Se tem aHeaderSev, usa para identificar posições
    If Type("aHeaderSev") == "A"
        aHeaderSEV := aHeaderSev
        nPosNat  := aScan(aHeaderSEV, {|x| AllTrim(x[2]) == "EV_NATUREZ"})
        nPosPerc := aScan(aHeaderSEV, {|x| AllTrim(x[2]) == "EV_PERC"})
        nPosVal  := aScan(aHeaderSEV, {|x| AllTrim(x[2]) == "EV_VALOR"})
        nPosRat  := aScan(aHeaderSEV, {|x| AllTrim(x[2]) == "EV_RATEICC"})
    Else
        // Usa posições padrão se não encontrou o aHeaderSev
        // AJUSTE AQUI: A ordem padrão mais comum é Natureza, Percentual, Valor
        nPosNat  := 1  // EV_NATUREZ
        nPosPerc := 2  // EV_PERC (vem ANTES do valor)
        nPosVal  := 3  // EV_VALOR
        nPosRat  := 4  // EV_RATEICC
    EndIf
    
    // Verifica se os campos necessários existem no aCols da NF
    If nPosCod == 0 .Or. nPosTes == 0 .Or. nPosTotal == 0
        MsgInfo("Campos obrigatórios não encontrados no documento.", "MT103MNT")
        Return aColsRet
    EndIf
    
    // Processa cada item do aCols
    For nX := 1 To Len(aCols)
        
        // Ignora linhas deletadas
        If aCols[nX,Len(aHeader)+1]
            Loop
        EndIf
        
        // Pega os valores do item atual
        cProduto := aCols[nX,nPosCod]
        cTes     := aCols[nX,nPosTes]
        cCCusto  := If(nPosCC > 0, aCols[nX,nPosCC], "")
        nValor   := aCols[nX,nPosTotal]
        cItem    := If(nPosItem > 0, aCols[nX,nPosItem], StrZero(nX,3))
        
        // Posiciona no produto
        SB1->(DbSetOrder(1))
        If !SB1->(DbSeek(xFilial("SB1") + cProduto))
            cMsgErro += "- Item " + cItem + ": Produto " + AllTrim(cProduto) + " não encontrado" + cQuebraLin
            lTemNat := .F.
            Loop
        EndIf
        
        // Posiciona no TES
        SF4->(DbSetOrder(1))
        If !SF4->(DbSeek(xFilial("SF4") + cTes))
            cMsgErro += "- Item " + cItem + ": TES " + cTes + " não encontrado" + cQuebraLin
            lTemNat := .F.
            Loop
        EndIf
        
        // Determina qual natureza usar conforme as regras
        cNatureza := ""
        
        // Regra 1: F4_DUPLIC = 'S' E F4_ESTOQUE = 'S'
        If SF4->F4_DUPLIC == 'S' .And. SF4->F4_ESTOQUE == 'S'
            cNatureza := AllTrim(SB1->B1_XNATUREZA)
            If Empty(cNatureza)
                cMsgErro += "- Item " + cItem + ": Campo B1_XNATUREZA vazio (TES gera duplicata com estoque)" + cQuebraLin
            EndIf
            
        // Regra 2: F4_ATUATF = 'S' (Gera Ativo)
        ElseIf SF4->F4_ATUATF == 'S'
            cNatureza := AllTrim(SB1->B1_XNATATF)
            If Empty(cNatureza)
                cMsgErro += "- Item " + cItem + ": Campo B1_XNATATF vazio (TES gera ativo)" + cQuebraLin
            EndIf
            
        // Regra 3: CTT_XTIPOC = '1' (Centro de Custo tipo Despesa)
        ElseIf !Empty(cCCusto)
            CTT->(DbSetOrder(1))
            If CTT->(DbSeek(xFilial("CTT") + cCCusto))
                If CTT->CTT_XTIPOC == '1'
                    cNatureza := AllTrim(SB1->B1_XNATDES)
                    If Empty(cNatureza)
                        cMsgErro += "- Item " + cItem + ": Campo B1_XNATDES vazio (CC tipo despesa)" + cQuebraLin
                    EndIf
                Else
                    cMsgErro += "- Item " + cItem + ": Centro de Custo não é tipo despesa e TES não define natureza" + cQuebraLin
                EndIf
            Else
                cMsgErro += "- Item " + cItem + ": Centro de Custo " + cCCusto + " não encontrado" + cQuebraLin
            EndIf
        Else
            cMsgErro += "- Item " + cItem + ": Nenhuma regra de natureza se aplica a este item" + cQuebraLin
        EndIf
        
        // Validação: todos os itens devem ter natureza
        If Empty(cNatureza)
            lTemNat := .F.
        Else
            // Adiciona no array para processamento
            aAdd(aRateio, {;
                cNatureza,;  // Natureza
                nValor,;     // Valor
                0,;          // Percentual (será calculado)
                cItem,;      // Item de origem
                cProduto;    // Código do produto
            })
            nTotNF += nValor
        EndIf
    Next nX
    
    // Se algum item não tem natureza, mostra os erros e não prossegue
    If !lTemNat .Or. Len(aRateio) == 0
        If !Empty(cMsgErro)
            Aviso("MT103MNT - Problemas na Definição de Naturezas", ;
                  "Os seguintes problemas foram encontrados:" + cQuebraLin + cQuebraLin + ;
                  cMsgErro + cQuebraLin + ;
                  "Corrija os cadastros antes de prosseguir.", ;
                  {"Ok"}, 3)
        EndIf
        Return aColsRet
    EndIf
    
    // Aglutina naturezas iguais
    For nX := 1 To Len(aRateio)
        nPos := aScan(aAglut, {|x| x[1] == aRateio[nX,1]})
        If nPos == 0
            aAdd(aAglut, {;
                aRateio[nX,1],;                     // Natureza
                aRateio[nX,2],;                     // Valor
                0,;                                 // Percentual
                "Itens: " + aRateio[nX,4];         // Descrição dos itens
            })
        Else
            aAglut[nPos,2] += aRateio[nX,2]
            aAglut[nPos,4] += ", " + aRateio[nX,4]
        EndIf
    Next nX
    
    // Calcula percentuais e arredonda para 2 casas decimais
    For nX := 1 To Len(aAglut)
        aAglut[nX,3] := Round((aAglut[nX,2] / nTotNF) * 100, 2)
        nTotPerc += aAglut[nX,3]
        
        // Identifica a natureza de maior valor
        If aAglut[nX,2] > nMaiorVal
            nMaiorVal := aAglut[nX,2]
            cNatMaior := aAglut[nX,1]
        EndIf
    Next nX
    
    // Ajusta diferença de arredondamento no maior valor
    If nTotPerc != 100
        nDifPerc := 100 - nTotPerc
        nPos := aScan(aAglut, {|x| x[1] == cNatMaior})
        If nPos > 0
            aAglut[nPos,3] += nDifPerc
        EndIf
    EndIf
    
    // Monta array de retorno baseado na estrutura detectada
    For nX := 1 To Len(aAglut)
        // Se tem linha modelo, usa ela
        If Len(aLinha) > 0
            aAdd(aColsRet, aClone(aLinha))
            nLin := Len(aColsRet)
            
            // Preenche os campos nas posições corretas
            If nPosNat > 0
                aColsRet[nLin,nPosNat] := aAglut[nX,1]  // Natureza
            EndIf
            If nPosPerc > 0
                aColsRet[nLin,nPosPerc] := aAglut[nX,3]  // Percentual
            EndIf
            If nPosVal > 0
                aColsRet[nLin,nPosVal] := Round(nTotNF * aAglut[nX,3] / 100, 2)  // Valor
            EndIf
            If nPosRat > 0
                aColsRet[nLin,nPosRat] := "1"  // Flag customizado
            EndIf
            // Última posição é sempre o flag de deletado
            aColsRet[nLin,Len(aColsRet[nLin])] := .F.
        Else
            // Usa estrutura padrão se não tem modelo
            // IMPORTANTE: Percentual ANTES do Valor na maioria das configurações
            aAdd(aColsRet, {;
                aAglut[nX,1],;                           // EV_NATUREZ
                aAglut[nX,3],;                          // EV_PERC (Percentual)
                Round(nTotNF * aAglut[nX,3] / 100, 2),; // EV_VALOR (Valor)
                "1",;                                    // EV_RATEICC
                .F.;                                     // Deletado
            })
        EndIf
    Next nX
    
    // Se definiu a natureza principal, atualiza variável pública se existir
    If !Empty(cNatMaior) .And. Type("cNatureza") == "C"
        cNatureza := cNatMaior
    EndIf
    
    // Mostra resumo do rateio para o usuário
    If Len(aColsRet) > 0
        cMsg := "Rateio de Naturezas Gerado Automaticamente:" + cQuebraLin + cQuebraLin
        
        // Ajusta índices baseado na estrutura detectada
        nIdxNat  := If(nPosNat > 0, nPosNat, 1)
        nIdxPerc := If(nPosPerc > 0, nPosPerc, 2)
        nIdxVal  := If(nPosVal > 0, nPosVal, 3)
        
        For nX := 1 To Len(aColsRet)
            cMsg += "Natureza: " + aColsRet[nX,nIdxNat] + ;
                   " - Perc: " + Transform(aColsRet[nX,nIdxPerc], "@E 999.99") + "%" + ;
                   " - Valor: R$ " + Transform(aColsRet[nX,nIdxVal], "@E 999,999,999.99") + cQuebraLin
        Next nX
        
        // Debug - mostra soma dos percentuais
        nTotPerc := 0
        For nX := 1 To Len(aColsRet)
            nTotPerc += aColsRet[nX,nIdxPerc]
        Next nX
        cMsg += cQuebraLin + "Total dos Percentuais: " + Transform(nTotPerc, "@E 999.99") + "%"
        
        If MsgYesNo(cMsg + cQuebraLin + cQuebraLin + "Confirma o rateio automático?", "MT103MNT")
            // Retorna o array para popular o aCols
        Else
            aColsRet := {}
        EndIf
    EndIf
    
    RestArea(aAreaCTT)
    RestArea(aAreaSF4)
    RestArea(aAreaSB1)
    RestArea(aAreaSD1)
    RestArea(aArea)
    
Return aColsRet

/*/{Protheus.doc} ValidaNat
Função auxiliar para validar se todas as naturezas estão cadastradas
@type function
@version 12.1.33
@author Sistema
@since 2024
@param cNatureza, character, Código da natureza a validar
@return logical, Indica se a natureza é válida
/*/
Static Function ValidaNat(cNatureza)
    Local lRet := .T.
    Local aAreaSED := SED->(GetArea())
    
    If !Empty(cNatureza)
        DbSelectArea("SED")
        SED->(DbSetOrder(1))
        If !SED->(DbSeek(xFilial("SED") + cNatureza))
            lRet := .F.
        EndIf
    Else
        lRet := .F.
    EndIf
    
    RestArea(aAreaSED)
    
Return lRet
