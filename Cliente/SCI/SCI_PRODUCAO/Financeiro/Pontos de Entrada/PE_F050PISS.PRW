#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³NOVO9     ºAutor  ³Microsiga           º Data ³  05/17/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function F050PISS()

Local aArea    := GetArea()
Local aAreaSED := SED->(GetArea())
Local aAreaSA2 := SA2->(GetArea())

Local nPercISS := GetMV("MV_ALIQISS")

//Pega a Aliq do Contrato
If IsinCallStack("CNTA120")  .or. IsinCallStack("CNTA121") 

    dbSelectArea('SA2')
    dbSetOrder(1)
    dbSeek(xFilial('SA2')+CNA->(CNA_FORNEC+CNA_LJFORN),.f.)

    dbSelectArea('SED')
    dbSetOrder(1)
    dbSeek(xFilial('SED')+CNB->CNB_NATURE,.f.)

	If SA2->A2_RECISS == 'N' .and. SED->ED_CALCISS == 'S'
	                                               
		//+----------------------------------------------------+	                                
		//|Denis Rodrigues - Solicitação do Valdir - 27/05/2019|
		//|Pegar o ISS diretamente do Produto x Fornecedor     |
		//+----------------------------------------------------+
		dbSelectArea("SA5")
		dbSetOrder(1)//A5_FILIAL+A5_FORNECEDOR+A5_LOJA+A5_PRODUTO
		If dbSeek( xFilial("SA5") + CNA->CNA_FORNEC + CNA->CNA_LJFORN + CNE->CNE_PRODUT ) 
			nPercISS := SA5->A5_ALIQISS
		EndIf

		/*If SB1->B1_ALIQISS > 0
			nPercISS := SB1->B1_ALIQISS
		EndIf*/

	EndIf
		
//Pega a Aliq do SE2 - Campo personalizado
//ElseIf IsinCallStack("FINA750") .or. FunName() $ "FINA050"
	//If M->E2_INTISS > 0 
//		nPercISS := 5 //M->E2_INTISS
	//EndIf
EndIf

RestArea(aAreaSA2)
RestArea(aAreaSED)
RestArea(aArea)
Return(nPercISS)