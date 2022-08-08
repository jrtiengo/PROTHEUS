#include 'protheus.ch'

user function TESTE()

Local Npreco := 30

if Npreco <= 10
  MsgAlert("Promo 10")

Elseif Npreco > 10 .or. Npreco < 50
  MsgAlert("Promo 20")

else
  MsgAlert("Promo 30")

ENDIF

return ()
