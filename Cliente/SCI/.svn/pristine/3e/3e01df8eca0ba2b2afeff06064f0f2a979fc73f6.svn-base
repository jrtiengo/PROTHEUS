#include "Totvs.ch"

User Function CNTPRSE1()   

Local aArea := GetArea()

dbSelectArea("CNF")
dbSetOrder(3)
If dbSeek( xFilial("CNF") + SE1->E1_MDCONTR + SE1->E1_MDREVIS + SE1->E1_MDCRON + SE1->E1_MDPARCE )
                             
   RecLock('SE1',.F.)
   SE1->E1_DATAINC := Date()
   SE1->E1_HIST := 'Ctr. ' + CNF->CNF_CONTRA + ' Parc. ' + CNF->CNF_PARCEL +  ' Compet. ' + CNF->CNF_COMPET 
   SE1->(MsUnlock())   
EndIf
   
RestArea( aArea )

Return(.T.)