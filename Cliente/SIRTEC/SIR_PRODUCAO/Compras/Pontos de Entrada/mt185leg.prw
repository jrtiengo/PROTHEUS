/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � mt185leg � Autor � Daniela Maria Uez     � Data �03/08/2010���
�������������������������������������������������������������������������Ĵ��
���Descricao � Ponto de entrada na rotina da baixa de requisi��es para    ���
���          � permitir a manipula��o e inclus�o de cores na legenda. As  ���
���          � defini��es ser�o feitas a partir do pe mt185cor.           ���
�������������������������������������������������������������������������Ĵ��
���Objetivo  �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function mt185leg()
	Local aItLeg := ParamIXB[1]
	Local aRet   := { 	{ "BR_CINZA", 'Sol. Compra Gerada' },;
						{ "BR_MARROM", 'Parcialmente atendida e Sol. Compra Gerada' }}
	
	aEval( aItLeg, { |x| aAdd( aRet, x ) } )

Return aRet
