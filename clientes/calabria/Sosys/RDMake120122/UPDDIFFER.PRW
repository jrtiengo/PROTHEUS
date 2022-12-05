#INCLUDE "PROTHEUS.CH"

User Function UPDDIFFER()

Local aButtons      := {}
Local aSays         := {}
Local nOpcA         := 0

Private aLogUPD     := {}
Private aTitle      := {}

aAdd(aSays,OemToAnsi( "Este programa tem como objetivo ajustar a data de pagamento das verbas de diferença de " ))
aAdd(aSays,OemToAnsi( "férias no acumulado do ano de 2020 afim de corrigir as informações que serão geradas na" ))
aAdd(aSays,OemToAnsi( "DIRF."))

aAdd(aButtons, { 1,.T.,{|o| nOpcA := 1,IF(gpconfOK(), FechaBatch(), nOpcA := 0 ) }} )
aAdd(aButtons, { 2,.T.,{|o| FechaBatch() }} )

//Abre a tela de processamento
FormBatch( "Ajuste das verbas de diferença de férias no acumulado", aSays, aButtons )

//Efetua o processamento de geração
If nOpcA == 1
    Aadd( aTitle, OemToAnsi( "Funcionários que tiveram a data de pagamento das verbas alteradas:" ) )
    Aadd( aLogUPD, {} )
    ProcGpe( {|lEnd| fProcessa()},,,.T. )
    If !Empty(aLogUPD[1])
        fMakeLog(aLogUPD,aTitle,,,"UPDDIFFER",OemToAnsi("Log de Ocorrências"),"M","P",,.F.)
    EndIf
EndIf

Return

/*/{Protheus.doc} fProcessa
Função que efetua a alteração das datas de referências das verbas de diferença de férias
/*/
Static Function fProcessa()

Local aArea         := GetArea()
Local aAreaSRA      := SRA->( GetArea() )
Local aAreaSRD      := SRD->( GetArea() )
Local cAliasQry     := GetNextAlias()
Local cWhere        := ""
Local cJoin         := ""
Local cVerbaIR      := ""
Local dDataPag      := CtoD("")

DbSelectArea("SRD")
DbSetOrder(1) //RD_FILIAL, RD_MAT, RD_DATARQ, RD_PD, RD_SEMANA, RD_SEQ, RD_CC, RD_PROCES, R_E_C_N_O_, D_E_L_E_T_
DbSelectArea("SRV")
DbSetOrder(2) //RV_FILIAL, RV_CODFOL, R_E_C_N_O_, D_E_L_E_T_

cWhere := "%"
cWhere += " SRV.RV_CODFOL IN ('0088','0090','0092','0094','0095','0096','0098','0161','1416','1417') AND "
cWhere += " SRD.RD_PERIODO >= '202001' AND "
cWhere += " SRD.RD_TIPO2 = 'F'"
cWhere += "%"

cJoin := "%"
cJoin += FWJoinFilial( "SRV", "SRD" )
cJoin += "%"

BeginSql alias cAliasQry
    SELECT RD_FILIAL, RD_MAT, RD_DATARQ, RD_SEMANA, RD_PERIODO, RD_DATPGT, RD_PD, SRD.R_E_C_N_O_ NRECNO
    FROM
        %Table:SRD% SRD
    INNER JOIN %Table:SRV% SRV
    ON %exp:cJoin%
    AND SRV.RV_COD = SRD.RD_PD
    WHERE
        SRD.%NotDel% AND
        SRV.%NotDel% AND
        %Exp:cWhere%
    ORDER BY RD_PERIODO,RD_PD
EndSql

If (cAliasQry)->( !Eof() )
    Do While (cAliasQry)->( !Eof() )

        If SRV->(DbSeek(xFilial("SRV",(cAliasQry)->RD_FILIAL) + "0015")) //Busca verba de BASE IR

            cVerbaIR := SRV->RV_COD

            If SRD->(DbSeek((cAliasQry)->(RD_FILIAL + RD_MAT + SubMesAno(RD_DATARQ) + cVerbaIR + RD_SEMANA)))

                //Se a data de pagamento da base de IR for diferente da data de pagamento da verba de diferença de férias, altera a data da verba de diferença
                If DtoS(SRD->RD_DATPGT) <> (cAliasQry)->RD_DATPGT

                    dDataPag := SRD->RD_DATPGT
                    SRD->(DbGoTo((cAliasQry)->NRECNO))

                    RecLock("SRD",.F.)
                    SRD->RD_DATPGT := dDataPag
                    MsUnLock()
                    aAdd( aLogUPD[1], "Filial: " + SRD->RD_FILIAL + "  -  Matrícula: " + SRD->RD_MAT + " - Período: "  + SRD->RD_PERIODO + " - Verba: " + SRD->RD_PD )
                EndIf
            EndIf
        EndIf

        (cAliasQry)->( DbSkip() )
    EndDo
EndIf

(cAliasQry)->(dbCloseArea())

RestArea( aAreaSRA )
RestArea( aAreaSRD )
RestArea( aArea)

Return
