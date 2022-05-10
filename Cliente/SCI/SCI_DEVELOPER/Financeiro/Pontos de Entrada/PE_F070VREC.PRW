#Include 'rwmake.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³F070VREC  ºAutor  ³Valdir              º Data ³  15/08/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³PE para tratamento integracao Inter x Society               º±±
±±º          ³Ao informar o valor deve buscar tx do cliente e colocar     º±±
±±º          ³como desconto                                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function F070VREC()

Local aArea   := GetArea()
Local aAreaSA1:= SA1->(GetArea())
Local lRet    := .T.  
Local nVlrREC := ParamIxb[1]

//Somente Operadores pode ocorrer 
If SubStr(SE1->E1_CLIENTE,1,3) == "OPE"
	dbSelectArea('SA1')
	dbSetOrder(1)
	dbSeek(xFilial('SA1')+SE1->(E1_CLIENTE+E1_LOJA),.f.)
    If SA1->A1_TAXA > 0
		
		nDescont := nVlrREC * ( SA1->A1_TAXA / 100 ) 
    EndIf
EndIf

RestArea(aAreaSA1)
RestArea(aArea)
Return(lRet)