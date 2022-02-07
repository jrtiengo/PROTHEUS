#Include 'Protheus.ch'

User Function MT160TEL()
Local aArea		:= GetArea()
Local oDlgNew		:= ParamIxb[1]
Local aPosGet	:= ParamIxb[2]
Local nOpcx		:= ParamIxb[3]
Local nReg		:= ParamIxb[4]

//alert(xFilial("SC8")+SC8->C8_NUM+"num"+SC8->C8_FORNECE+"forn"+SC8->C8_LOJA+"loja"+SC8->C8_ITEM+"item-produto"+SC8->C8_PRODUTO+"__"+cValToChar(nReg)+"-"+cValToChar(SC8->C8_IPICOT))
SC8->(dbSetOrder(1))
//SC8->(MsSeek(xFilial("SC8")+SC8->C8_NUM+SC8->C8_FORNECE+SC8->C8_LOJA+SC8->C8_ITEM+SC8->C8_NUMPRO ))
//alert(xFilial("SC8")+SC8->C8_NUM+"num"+SC8->C8_FORNECE+"forn"+SC8->C8_LOJA+"loja"+SC8->C8_ITEM+"item-"+cValToChar(SC8->C8_IPICOT))
SC8->(dbGoTo(nReg))

@ 16,500 SAY   "Valor IPI" PIXEL OF oScrollBox 
@ 16,550 MSGET Round(SC8->C8_IPICOT,2) PICTURE PesqPict("SC8","C8_IPICOT",30) SIZE 60,09 WHEN .F. PIXEL OF oScrollBox  

@ 32,500 SAY   "ST Workflow" PIXEL OF oScrollBox 
@ 32,550 MSGET Round(SC8->C8_STCOT,2) PICTURE PesqPict("SC8","C8_STCOT",30) SIZE 60,09 WHEN .F. PIXEL OF oScrollBox  
oDlgNew:Refresh()
oDlg := oDlgNew
oDlg:Refresh()


RestArea(aArea)
Return (NIL)

