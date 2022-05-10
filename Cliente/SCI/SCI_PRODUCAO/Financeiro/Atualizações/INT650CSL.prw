#INCLUDE "RWMAKE.CH"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � INT650CSL Autor  Victor Giannoccaro  � Data �  05/10/06    ���
�������������������������������������������������������������������������͹��
���Desc.     �  CSLL - Busca para contabiliza��o de Reten��o              ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function INT650CSL()

Local _aArea := GetArea()
Local nCSLL := 0

cPref := SF1->F1_SERIE
cNota := SF1->F1_DOC

DbSelectArea("SE2")
DbSetOrder(1)
DbSeek(xFilial("SE2")+CPREF+CNOTA )
While !eof() .And. SE2->E2_FILIAL + SE2->E2_PREFIXO + SE2->E2_NUM == xFilial("SE2")+CPREF+CNOTA
	If SE2->E2_NATUREZ == "73141     "
		nCSLL := SE2->E2_VALOR
	
	EndIf
    dbskip()
enddo
RestArea(_aArea)           

Return(nCSLL)
