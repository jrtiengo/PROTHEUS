#Include 'rwmake.ch'

/*
�����������������������������������������������������������������������������
���ADAPTADO  �COP319   �Autor  �Marcelo Tarasconi   � Data �  29/11/2008 ���
���Programa  �PLFF319   �Autor  �Marcelo Tarasconi   � Data �  12/04/2007 ���
�������������������������������������������������������������������������͹��
���Descricao �Funcao para declarar variaveis contadoras para cnab a pagar ���
�������������������������������������������������������������������������͹��
���Uso       � MP 8                                                      ���
�����������������������������������������������������������������������������
*/

User Function COP325()

Local cRet := Alltrim(SE2->E2_CODBAR)

If Len(cRet) <> 44 //44 posicoes � o c�digo de barras leitor , se tiver 48 entao o que temos � a linha digitavel
   cRet := Substr(Alltrim(SE2->E2_CODBAR) ,01,11)     
   cRet += Substr(Alltrim(SE2->E2_CODBAR) ,13,11)     
   cRet += Substr(Alltrim(SE2->E2_CODBAR) ,25,11)     
   cRet += Substr(Alltrim(SE2->E2_CODBAR) ,37,11)     
EndIf    

Return(cRet)