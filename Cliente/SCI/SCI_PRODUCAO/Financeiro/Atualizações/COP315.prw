#Include 'rwmake.ch'

/*
�����������������������������������������������������������������������������
���ADAPTADO  COP315   �Autor  �Marcelo Tarasconi   � Data �  29/11/2008 ���
���Programa  �PLFF315   �Autor  �Marcelo Tarasconi   � Data �  12/04/2007 ���
�������������������������������������������������������������������������͹��
���Descricao �Funcao para declarar variaveis contadoras para cnab a pagar ���
�������������������������������������������������������������������������͹��
���Uso       � MP 8                                                      ���
�����������������������������������������������������������������������������
*/

User Function COP315()

__cLinhas := StrZERO((Val(__cLinhas)+1),6) //Contador de linhas do arquivo

Return('9')