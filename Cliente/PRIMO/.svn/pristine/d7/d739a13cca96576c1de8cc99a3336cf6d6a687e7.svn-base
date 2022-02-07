
#Include "Totvs.ch"

User function M040SE1()

Local aArea    := GetArea()
Local aAreaSM2 := SM2->(GetArea())

If SE1->E1_MOEDA > 1
  DbselectArea("SM2")             
  DbsetOrder(1)
  Dbseek( Dtos(SE1->E1_EMISSAO))

  DbselectArea("SE1")

  RecLock("SE1",.F.)
  If SE1->E1_MOEDA == 2
     SE1->E1_TXMOEDA := SM2->M2_MOEDA2
  Else
    If SE1->E1_MOEDA == 3 
     SE1->E1_TXMOEDA := SM2->M2_MOEDA3
    Endif
  Endif  
  MsUnlock()
Endif 

Restarea(aAreaSM2)
Restarea(aArea)

Return
