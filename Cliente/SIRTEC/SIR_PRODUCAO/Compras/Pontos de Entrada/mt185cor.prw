/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � mt185cor � Autor � Daniela Maria Uez     � Data �03/08/2010���
�������������������������������������������������������������������������Ĵ��
���Descricao � Ponto de entrada na rotina da baixa de requisi��es para    ���
���          � permitir a manipula��o e inclus�o dos itens da legenda.    ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Objetivo  �                                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function mt185cor()
	
	Local aCores := ParamIXB[1]       
	
	Local aRet := {	{ "Empty(SCP->CP_STATUS) .And. SCP->CP_PREREQU == 'S' .And. QtdComp(SCP->CP_QUJE) == QtdComp(0) .and. !EMPTY(ALLTRIM(SCP->CP_NUMSC))", "BR_CINZA" },;
					{ "Empty(SCP->CP_STATUS) .And. SCP->CP_PREREQU == 'S' .And. QtdComp(SCP->CP_QUJE) >  QtdComp(0) .and. !EMPTY(ALLTRIM(SCP->CP_NUMSC))", "BR_MARROM"}}
					     
	aEval( aCores, { |x| aAdd( aRet, x ) } )

Return aRet
