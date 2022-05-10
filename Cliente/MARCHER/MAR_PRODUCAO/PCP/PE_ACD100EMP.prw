#INCLUDE "TOTVS.ch"

/*/{Protheus.doc} ACD100EMP
PE chamado na rotina padrão "Ordens Separação", usado para validar se o Empenho pode ou não ser usado para gerar a Ordem
@type  Function
@author Jorge Alberto - Solutio
@since 25/02/2022
@version 12.1.25
@return logical, .F. se o Empenho não pode ser usado ou .T. se pode usar
/*/
User Function ACD100EMP()

    Local lUsaEmp  := .T.
    Local aArea    := GetArea()
    Local aAreaSG1 := SG1->(GetArea())
    Local cAliAtu  := Alias()
    Local cProd    := PARAMIXB[2]
    //Local cOP     := PARAMIXB[1]
    //Local nQuant  := PARAMIXB[3]
    
    DbSelectArea( "SG1" )
    dbSetOrder(1) // G1_FILIAL + G1_COD + G1_COMP + G1_TRT
    If DbSeek( xFilial("SG1") + SD4->D4_PRODUTO + cProd )
        If .NOT. Empty( SG1->G1_TPKIT )
            lUsaEmp := .F.
        EndIf
    EndIf

    RestArea( aAreaSG1 )
    RestArea( aArea )
    If .NOT. Empty( cAliAtu )
        DbSelectArea( cAliAtu )
    EndIf

Return( lUsaEmp )
