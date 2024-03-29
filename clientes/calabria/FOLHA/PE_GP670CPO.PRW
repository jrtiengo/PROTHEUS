#Include 'Protheus.ch'

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � GP670CPO �Autor  � Reiner            � Data �  05/03/21   ���
�������������������������������������������������������������������������͹��
���Desc.     � PE na integracao - grava nome e matricula na SE2           ���
�������������������������������������������������������������������������͹��
���Uso       � CALABRIA                                                   ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/   
User Function GP670CPO() 

Local aArea     := GetArea()
Local aAreaSRA	:= SRA->(GetArea())
Local aAreaSE2	:= SE2->(GetArea())

// So se tiver informado a matricula no t�tulo
// Se n�o sai da rotina.
If !Empty(RC1->RC1_MAT)

	Dbselectarea("SRA")
	Dbsetorder(1) 
	If cEmpAnt<>"85"      
		//Dbseek(xFilial("SRA") + RC1->RC1_MAT, .F.)       
		Dbseek(RC1->RC1_FILIAL + RC1->RC1_MAT, .F.)
	Else
       Dbseek(xfilial("SRA") + RC1->RC1_MAT, .F.)
	EndIf
	If found()

		Dbselectarea("SE2") 
		Reclock("SE2",.f.)
			SE2->E2_MAT  := SRA->RA_MAT
			SE2->E2_NOME := SRA->RA_NOME
		MsUnlock()
	Else
		Msgstop('Nao encontrou a Matr�cula ' + RC1->RC1_MAT + ' no Cadastro de Funcion�rios.'  )
	Endif	
EndIf	

RestArea(aArea)
RestArea(aAreaSRA)
RestArea(aAreaSE2) 

Return
