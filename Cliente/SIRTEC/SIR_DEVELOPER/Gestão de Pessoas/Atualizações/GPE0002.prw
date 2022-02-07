#include "rwmake.ch"
#include "topconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GPE0004   �Autor  �Julio Almeida       � Data � 25/01/2008  ���
�������������������������������������������������������������������������͹��
���Desc.     � Gratificacao - "Rotina de Ferias"                          ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8 - Gestao de Pessoal                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function GPE0002()
                       
Private nGratific := 0
                                                    
If SRA->RA_YVLRGRT > 0  
	
	nGratific := SRA->RA_YVLRGRT   // Retorna o Valor da Gratificacao
	
//If M->RH_YRECALC == .F.
		Salmes := M->RH_SALMES  := M->RH_SALMES + nGratific
		Saldia := M->RH_SALDIA  := M->RH_SALMES / 30
		SalHora:= M->RH_SALHORA := M->RH_SALMES / SRA->RA_HRSMES
//Endif
//	M->RH_YRECALC := .T.	
	
Endif

Return()
