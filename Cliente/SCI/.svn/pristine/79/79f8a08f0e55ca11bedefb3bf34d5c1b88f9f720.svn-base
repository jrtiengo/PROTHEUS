
User Function INTE050()

Local cNome := ""



dbSelectArea("CN1")
dbSetOrder(1)//CN1_FILIAL+CN1_CODIGO

If dbSeek(xFilial("CN1") + CN9->CN9_TPCTO )
	
	If  CN1->CN1_ESPCTR = "2" //Tipo de Contrato
		
		dbSelectArea("SA1")
		dbSetOrder(1)//A1_FILIAL+A1_COD+A1_LOJA
		If dbSeek(xFilial("SA1") + CN9->CN9_CLIENT + CN9->CN9_LOJACL)
			cNome := SA1->A1_NOME
		EndIf
		
	Else
		
		dbSelectArea("CNC")
		dbSetOrder(1)//CNC_FILIAL+CNC_NUMERO
		
		If dbSeek(xFilial("CNC") + CN9->CN9_NUMERO )
			
			dbSelectArea("SA2")
			dbSetOrder(1)//A2_FILIAL+A2_COD+A2_LOJA
			If dbSeek(xFilial("SA2") + CNC->CNC_CODIGO + CNC->CNC_LOJA)
				cNome := SA2->A2_NOME
			EndIf
			
		EndIf
		
	EndIf
	
EndIf



Return(cNome)


User Function INTE051(cCN9)

Local cCodigo := ""


dbSelectArea("CNC")
dbSetOrder(1)//CNC_FILIAL+CNC_NUMERO

If dbSeek(xFilial("CNC") + cCN9 )
	
	dbSelectArea("SA2")
	dbSetOrder(1)//A2_FILIAL+A2_COD+A2_LOJA
	If dbSeek(xFilial("SA2") + CNC->CNC_CODIGO + CNC->CNC_LOJA)
		cCodigo := SA2->A2_COD
	EndIf
	
EndIf


User Function INTE052(cCN9)

Local cNome := ""


dbSelectArea("CNC")
dbSetOrder(1)//CNC_FILIAL+CNC_NUMERO

If dbSeek(xFilial("CNC") + cCN9 )
	
	dbSelectArea("SA2")
	dbSetOrder(1)//A2_FILIAL+A2_COD+A2_LOJA
	If dbSeek(xFilial("SA2") + CNC->CNC_CODIGO + CNC->CNC_LOJA)
		cNome := SA2->A2_COD +' - '+SA2->A2_NOME
	EndIf
	
EndIf



Return(cNome)
