/*
=============================================================================
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±|=======================================================================|±±
±±|Funcao    |INTE050   | Autor |                      | Data | 08/04/2014|±±
±±|=======================================================================|±±
±±|Descricao | Gatilho para mostrar no Browse o Cliente OU Fornecedor      |±±
±±|=======================================================================|±±
±±|Sintaxe   |                                                            |±±
±±|=======================================================================|±±
±±|Parametros|                                                            |±±
±±|          |                                                            |±±
±±|          |                                                            |±±
±±|=======================================================================|±±
±±|Retorno   |                                                            |±±
±±|=======================================================================|±±
±±| Uso      | Especifico para o cliente                                  |±±
±±|=======================================================================|±±
±±|                          ULTIMAS ALTERACOES                           |±±
±±|=======================================================================|±±
±±|Programador | Data   | Motivo da Alteracao                             |±±
±±|=======================================================================|±±
±±|            |        |                                                 |±±
±±|=======================================================================|±±
=============================================================================*/
User Function INTE050A()

	Local cNome := ""

	dbSelectArea("CN1")
	dbSetOrder(1)//CN1_FILIAL+CN1_CODIGO

	If dbSeek(xFilial("CN1") + CN9->CN9_TPCTO )  

		If  CN1->CN1_ESPCTR = "2" //Tipo de Contrato

			dbSelectArea("CNC")
			dbSetOrder(1)//CNC_FILIAL+CNC_NUMERO
			If dbSeek(xFilial("CNC") + CN9->CN9_NUMERO )
				dbSelectArea("SA1")
				dbSetOrder(1)//A1_FILIAL+A1_COD+A1_LOJA
				If dbSeek(xFilial("SA1") + CNC->CNC_CLIENT + CNC->CNC_LOJACL)			
				cNome := SA1->A1_NOME		
				EndIf
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