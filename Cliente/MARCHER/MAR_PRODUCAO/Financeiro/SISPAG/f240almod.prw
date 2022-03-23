#include "rwmake.ch"       

User Function F240AlMod()       


/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Rotina    � F420ALMOD.PRW                                               ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Ponto de Entrada para zerar a variavel publica que sera  ���
���          � utilizada para totalizar o valor de outras entidades na   ���
���          � geracao do SISPAG                                         ���
�������������������������������������������������������������������������Ĵ��
���Desenvolvi� Marciane Gennari                                           ���
���mento     � 08/11/2010                                                 ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Utilizado no sispag do Itau para zerar a  variavel publica ���
���            outras entidades                                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

Local _cModelo := Paramixb[1]

_nTotGPS   := 0     
_nTotEnt     := 0 
_nTotAcres := 0       
_nTotAbat   := 0                          
   
//--- Quando bordero para envio de tributos com codigo de barras. For�ar o modelo 28 para gerar o segmento O.
If _cModelo == "91" 
   _cModelo := "28"
EndIf

Return  (_cModelo)      
