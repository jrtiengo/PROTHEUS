#Include 'rwmake.ch'

/*
�����������������������������������������������������������������������������
���ADAPTADO  �COP311   �Autor  �Marcelo Tarasconi   � Data �  29/11/2008  ���
���Programa  �PLFF311   �Autor  �Marcelo Tarasconi   � Data �  05/04/2007 ���
�������������������������������������������������������������������������͹��
���Descricao �Funcao para declarar variaveis contadoras para cnab a pagar ���
�������������������������������������������������������������������������͹��
���Uso       � MP 8                                                      ���
�����������������������������������������������������������������������������
*/

User Function COP311()

If SE2->E2_NUMBOR <> __cNumBor //J� estou no proximo bordero //Var Public que sabe qual bordero anterior
   __cNumbor := SE2->E2_NUMBOR
   __cNum := StrZERO((Val(__cNum)+1),4)
EndIf

Return(__cNum)