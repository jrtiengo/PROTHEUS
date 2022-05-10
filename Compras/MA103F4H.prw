#Include 'Protheus.ch'

User Function MA103F4H()

Local aRet := {}

    If A103GCDisp() .And. lNfMedic //Possui Registro na Tabela de Contratos e checkbox "Filtra Medicao" marcado

        aRet := { GetSx3Cache("C7_REVENDA","X3_TITULO") }

    Else

        aRet := { GetSx3Cache("C7_REVENDA","X3_TITULO") }

    EndIf

Return(aRet)
