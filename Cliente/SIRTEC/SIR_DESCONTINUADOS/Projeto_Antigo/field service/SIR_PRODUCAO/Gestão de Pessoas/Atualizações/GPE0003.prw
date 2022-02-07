#include "rwmake.ch"
#include "topconn.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �GPE0004   �Autor  �Julio Almeida       � Data � 25/01/2008  ���
�������������������������������������������������������������������������͹��
���Desc.     � Gratificacao - "Rotina de Rescisao"                        ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � MP8 - Gestao de Pessoal                                    ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
User Function GPE0003()

                       
Private nGratific := 0
                                                    
	nGratific := Posicione("SRA",1, xFilial('SRA') + RG_MAT, SRA->RA_YVLRGRT ) // Retorna o Valor do Salario da Categoria

//If SRA->RA_YVLRGRT > 0  

If nGratific > 0  
	
//If M->RG_YRECALC == .F.
		Salmes := M->RG_SALMES  := M->RG_SALMES + nGratific
		Saldia := M->RG_SALDIA  := M->RG_SALMES / 30
		SalHora:= M->RG_SALHORA := M->RG_SALMES / SRA->RA_HRSMES
//Endif
//	M->RG_YRECALC := .T.	
	
Endif

Return()
