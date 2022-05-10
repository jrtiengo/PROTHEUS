#include 'protheus.ch'
#include 'parmtype.ch'

user function GP670ARR()
Local aRet := {}

_cNome:=POSICIONE("SRA",1,RC1->RC1_FILTIT+RC1->RC1_MAT,"RA_NOME")

aadd(aRet,{"E2_HIST",_cNome,NIL})



Return aRet
