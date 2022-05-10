#Include 'Protheus.ch'

User Function MA103F4I()

Local aRet := {}

    If A103GCDisp() .And. lNfMedic //Possui Registro na Tabela de Contratos e checkbox "Filtra Medicao" marcado

        aRet := { SC7->C7_REVENDA }

    Else

        aRet := { SC7->C7_REVENDA }

    EndIf

Return(aRet)
