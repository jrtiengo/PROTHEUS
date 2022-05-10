#include "protheus.ch"

/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �FA100OKR       �Autor  �Marllon Figueiredo       11/05/2011 ���
�������������������������������������������������������������������������͹��
���Desc. Permite validar a inclusao de mov. a receber                      ��
���                                                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
User Function FA100OKR()
Local aArea       := GetArea()
Local aAreaCT1    := CT1->( GetArea() )
Local aAreaSED    := SED->( GetArea() )
Local lReturn     := .t.
Local cE5_Naturez := M->E5_NATUREZ
Local cE5_ccd     := M->E5_CCCTB

// posiciona na natureza para pegar a conta contabil
SED->( dbSetOrder(1) )
If SED->( dbSeek(xFilial('SED')+cE5_Naturez) )
	
	// posiciona no CT1 para verificar obrigatoriedades
	CT1->( dbSetOrder(1) )
	If CT1->( dbSeek(xFilial('CT1')+SED->ED_CONTA) )
		
		If CT1->CT1_CCOBRG == '1' .and. Empty(cE5_ccd)
			
			Alert("Obrigat�rio informar o Centro de Custo!")
			lReturn := .f.
			
		EndIf
		
		// CC nao obrig. e nao aceita e o usuario preencheu, nao deixo!
		If CT1->CT1_CCOBRG <> '1' .and. CT1->CT1_ACCUST == '2' .and. ! Empty(cE5_ccd)

	    	Alert("Centro de Custo n�o � aceito neste lan�amento!")
			lReturn := .f.

		EndIf
		
	EndIf
EndIf

// reposiciona alias
RestArea(aAreaSED)
RestArea(aAreaCT1)
RestArea(aArea)

Return( lReturn )
