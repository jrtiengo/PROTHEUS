#Include"Protheus.ch"


User Function OS010BTN()
Local aArea	:= GetArea()
Local aRet	:= {}
// #19604 Alterada a chamada do campo. O Protheus está se perdendo com chamada M->. Mauro - Solutio - 25/04/2018.
aADD(aRet,{"PENDENTE", 	{|| U_FB104TEC(DA0->DA0_CODTAB) }, "Tipo OS" })

RestArea(aArea)
Return aRet