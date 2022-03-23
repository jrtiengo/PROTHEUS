#INCLUDE "TOTVS.ch"

/*/{Protheus.doc} MT241SE
PE utilizado dentro da opção "1º nivel" na tela de Inclusão da rotina "Movi. Multipla" ( MATA241 ).
Esse PE irá retirar alguns Componentes da lista somente quanto o TM usado for 555.
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 30/11/2021
@return array, Array com os componentes.
/*/
User Function MT241SE()

    Local aCompAtu  := PARAMIXB
    Local aColsRet  := {}
    Local aArea     := {}
    Local aAreaSB1  := {}
    Local aAreaSD3  := {}
    Local cAliAtu   := ''
    Local cCampo    := ''
    Local cFilSB1   := ''
    Local cFilSB2   := ''
    Local cLocProc  := ''
    Local nTotReg   := 0
    Local nPos      := 0
    Local nSaldo    := 0
    Local nQtdPrj   := 0
    Local nPosCod   := 0
    Local nPosQuant := 0
    Local nPosLocal := 0
    Local lBaixaEmp := SF5->F5_ATUEMP == "S"

    If cTM <> "555"
        Return( aCompAtu )
    EndIf

    aArea     := GetArea()
    aAreaSB1  := SB1->( GetArea() )
    aAreaSD3  := SD3->( GetArea() )
    cAliAtu   := Alias()
    cFilSB1   := xFilial("SB1")
    cFilSB2   := xFilial("SB2")
    cLocProc  := GetMV("MV_LOCPROC")
    nTotReg   := Len( aCompAtu )
    nPosCod   := aScan( aHeader, { |x| AllTrim(x[2]) == "D3_COD"   } )
    nPosQuant := aScan( aHeader, { |x| AllTrim(x[2]) == "D3_QUANT" } )
    nPosLocal := aScan( aHeader, { |x| AllTrim(x[2]) == "D3_LOCAL" } )

    DbSelectArea( "SB1" )
    DbSetOrder( 1 )

    DbSelectArea( "SB2" )
    DbSetOrder( 1 )
			 
    For nPos := 1 To nTotReg

        SB1->( DbSeek( cFilSB1 + aCompAtu[ nPos, nPosCod ] ) )

        SB2->( DbSeek( cFilSB2 + aCompAtu[ nPos, nPosCod ] + aCompAtu[ nPos, nPosLocal] ) )

        nQtdPrj := If(lBaixaEmp, aCompAtu[nPos, nPosQuant], 0)

        nSaldo := SaldoMov(Nil,!lBaixaEmp,Nil,mv_par03==1,If(lBaixaEmp,aCompAtu[nPos,nPosQuant],Nil),nQtdPrj,Nil, dDataBase )

        If( Left( aCompAtu[ nPos, nPosCod ], 3 ) <> "MOD" .And. SB1->B1_APROPRI == "I" .And. SB1->B1_LOCPAD <> cLocProc .And. nSaldo > 0 .And. aCompAtu[ nPos, nPosQuant ] <= nSaldo )
            AADD( aColsRet, aCompAtu[ nPos ] )
        EndIf
    Next

    If Len( aColsRet ) <= 0

        // Adiciona uma linha vazia no aColsRet
        AADD(aColsRet, Array( Len(aHeader)+1 ) )

        // Preenche conteudo do aColsRet
        For nPos := 1 to Len(aHeader)
            cCampo := Alltrim(aHeader[nPos,2])
            If IsHeadRec(cCampo)
                aColsRet[1][nPos] := 0
            ElseIf IsHeadAlias(cCampo)
                aColsRet[1][nPos] := "SD3"
            Else
                aColsRet[1][nPos] := CriaVar(cCampo,.F.)
            EndIf
        Next
    EndIf

    If .NOT. Empty( cAliAtu )
        DbSelectArea( cAliAtu )
    EndIf
    RestArea( aArea    )
    RestArea( aAreaSB1 )
    RestArea( aAreaSD3 )

Return( aColsRet )
