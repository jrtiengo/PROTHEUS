#Include 'rwmake.ch'

/*
�����������������������������������������������������������������������������
���ADAPTADO  �COP313   �Autor  �Marcelo Tarasconi   � Data �  29/11/2008  ���
���Programa  �PLFF313   �Autor  �Marcelo Tarasconi   � Data �  12/04/2007 ���
�������������������������������������������������������������������������͹��
���Descricao �Funcao para declarar variaveis contadoras para cnab a pagar ���
�������������������������������������������������������������������������͹��
���Uso       � MP 8                                                      ���
�����������������������������������������������������������������������������
*/

User Function COP313()

__cLinhas := StrZERO((Val(__cLinhas)+1),6) //Contador de linhas do arquivo
__cLinBor := StrZERO((Val(__cLinBor)+1),6)

Return('3')