#include "Totvs.ch"

User Function CNTPRSE2()   

Local aArea := GetArea()


dbSelectArea("CNF")
dbSetOrder(3)
If dbSeek( xFilial("CNF") + SE2->E2_MDCONTR + SE2->E2_MDREVIS + SE2->E2_MDCRON + SE2->E2_MDPARCE )
                             
   RecLock('SE2',.F.)
   SE2->E2_DATAINC := Date()
   SE2->E2_HIST := 'Ctr. ' + CNF->CNF_CONTRA + ' Parc. ' + CNF->CNF_PARCEL +  ' Compet. ' + CNF->CNF_COMPET 
   SE2->(MsUnlock())
EndIf

RestArea( aArea )

Return(.T.)