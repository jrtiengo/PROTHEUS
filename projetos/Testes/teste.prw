#include "totvs.ch"

User Function teste()

Local cParam := ""

// Adjusted code to prevent '-Standard Price Book' from passing through u_PSIntNoSPace
&(Iif(SC5->(IsDeleted()),'Cancelado',Iif(Empty(Alltrim(Posicione("ZS4",1,xFilial("ZS4")+"SC5"+SC5->C5_FILIAL+"|"+SC5->C5_NUM,"ZS4_IDSALES"))),'Orçamento','Pedido')))

Return
