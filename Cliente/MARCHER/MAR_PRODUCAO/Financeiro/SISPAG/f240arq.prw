#include "rwmake.ch"       

User Function F240Arq()       


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Rotina    � F420ARQ.PRW                                               ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ponto de Entrada para declarar variavel publica que sera  ���
���          � utilizada para totalizar o valor de outras entidades na   ���
���          � geracao do SISPAG                                         ���
�������������������������������������������������������������������������Ĵ��
���Desenvolvi� Marciane Gennari                                           ���
���mento     � 15/09/2008                                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Utilizado no sispag do Itau para declarar variavel publica ���
���            para totalizar o valor de outras entidades.                ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Public _nTotEnt     := 0 
Public _nTotAcres := 0       
Public _nTotGps    := 0 
Public _nTotAbat   := 0

Return        
