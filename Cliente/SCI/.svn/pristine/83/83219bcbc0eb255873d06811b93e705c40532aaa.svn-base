//Autor Leonel Vilaverde
//Objetivo: Acerta data em transferencia bancárias nos dias (sabados, domingos e feriados)
#include 'protheus.ch'
#include 'parmtype.ch'

user function A100TR02()

IF  Alltrim(SE5->E5_ORIGEM) == 'FINA100'
    IF  Alltrim(SE5->E5_TIPODOC)=='TR' .AND. SE5->E5_BANCO $ '041/CX1' .AND. SE5->E5_DTDISPO <> dDatabase
//        Alert("Estou no A100TR02 ")
        RecLock('SE5',.F.)
        SE5->E5_DTDISPO := dDatabase 
        MsUnlock()
    ENDIF
ENDIF	
return
