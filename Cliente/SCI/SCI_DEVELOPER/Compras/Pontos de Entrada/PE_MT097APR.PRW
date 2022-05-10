#Include 'rwmake.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³NOVO8     ºAutor  ³Microsiga           º Data ³  04/30/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function MT097APR()

Local aArea    := GetArea()
Local aAreaSCR := SCR->(GetArea())
Local lTudoOK  := .T.

If SCR->CR_TIPO $ "PA/D1/D2" //Tipos criados para processo de Despesas Inter
	
	dbSelectArea('SCR')
	dbSetOrder(1)
	dbSeek(xFilial('SCR')+SCR->(CR_FILIAL+CR_TIPO+CR_NUM),.f.)
	
	cChave := SCR->(CR_FILIAL+CR_TIPO+CR_NUM)
	
	While SCR->(!Eof()) .And. cChave == SCR->(CR_FILIAL+CR_TIPO+CR_NUM)
		
		If SCR->CR_STATUS != "03" .And. SCR->CR_STATUS != "05" .And. SCR->CR_STATUS != "04"
			lTudoOK := .F.
			Exit
		EndIf
		SCR->(dbSkip())
	EndDo
	
	If lTudoOK //Aqui devo fazer as integrações das despesas
		
		RestArea(aArea)
		RestArea(aAreaSCR)
		
		u_SCIF040('1') //Função que lança titulos e faz a compensacao //'1'-MATA097 SCR     '2'-SCIA130 Z02
	EndIf
EndIf

RestArea(aAreaSCR)
RestArea(aArea)
Return()