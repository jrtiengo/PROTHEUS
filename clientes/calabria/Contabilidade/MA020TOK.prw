
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �MA020TOK     �Autor  �Samuel Schneider � Data �  14/11/13   ���
�������������������������������������������������������������������������͹��
���Desc.     � Cadastra conta conforme codigo do fornecedor               ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Calbria                                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function MA020TOK()

Local lRet := .F.
	
	If (INCLUI)

	    DbSelectArea("CT1")  
		DbSetOrder(1)             
	
		If !(DbSeek(xFilial("CT1")+ALLTRIM(M->A2_CONTA)))
		
			 CT1->(RecLock("CT1",.T.))
			      CT1->CT1_FILIAL  := xFilial("CT1")
			      CT1->CT1_CONTA   := M->A2_CONTA
				  CT1->CT1_DESC01  := M->A2_NOME	
				  CT1->CT1_BLOQ    := "2"
				  CT1->CT1_CLASSE  := "2"
				  CT1->CT1_NORMAL  := "2"
				  CT1->CT1_CTASUP  := SUBSTRING(M->A2_CONTA,1,4)+xFilial("SA2")	      	
				  CT1->CT1_RES     := "2"+M->A2_COD
				  CT1->CT1_NTSPED  := "02"
				  CT1->CT1_NATCTA  := "02"
				  CT1->CT1_ITOBRG := "1"
			CT1->(MsUnlock())	  
			lRet := .T.
		
		EndIf                
		
		CT1->(DbCloseArea())	
		
		If (lRet)
	
			DbSelectArea("CVD")
			DbSetOrder(1)
			
			If !(DbSeek(xFilial("CVD")+AllTrim(M->A2_CONTA)))
				 CVD->(RecLock("CVD",.T.))
				    CVD->CVD_FILIAL := xFilial("CVD")
				    CVD->CVD_CONTA  := M->A2_CONTA
				    CVD->CVD_ENTREF := "10"
				    CVD->CVD_CODPLA := "001"
				    CVD->CVD_VERSAO := "0001"
				    CVD->CVD_CTAREF := "2.01.01.03.01"
				    CVD->CVD_TPUTIL := "A"
				    CVD->CVD_CLASSE := "2"
				    CVD->CVD_NATCTA := "02"
					CVD->CVD_CTASUP := "2.01.01.03"   
				CVD->(MsUnlock())
			EndIf
		
			CVD->(DbCloseArea())
	    
	    EndIf
		
	EndIf

Return(.T.)