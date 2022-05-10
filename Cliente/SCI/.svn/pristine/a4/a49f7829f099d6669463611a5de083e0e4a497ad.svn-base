#include 'protheus.ch'
#include 'parmtype.ch'

User Function FA100TRF
 
Local ddtdisp   := ParamIXB[16]
Local ddtcred   := dDatabase
Local lGrava    := ParamIXB[15]
Local cBcoOrig  := ParamIXB[01]
Local cBcoDest  := ParamIXB[04]
IF cBcoOrig=='CX1' .AND. cBcoDest = '041' .AND. ParamIXB[16] <> dDatabase
    ParamIXB[16] := dDatabase
    lGrava    := .T.
//  Alert(ParamIXB[16])
EndIf
lGrava    := .T.
Return lGrava
