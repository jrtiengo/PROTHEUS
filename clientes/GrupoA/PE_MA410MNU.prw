#include 'protheus.ch'
#Include 'Totvs.ch'
#include 'parmtype.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � MA410MNU  � Autor � Maicom Rigo          � Data �11/05/2016��� 
�������������������������������������������������������������������������Ĵ��
���Descricao� Ponto de entrada para adicionar item no "A��es Relacionadas"���
��� na tela de pedido de venda                                			  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � U_MA410MNU()                                               ���
�������������������������������������������������������������������������Ĵ��
���Parametros� Nenhum                                                     ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Nulo                                                       ���
�������������������������������������������������������������������������Ĵ��
���Uso       � Especifico cliente Grupo A                                 ���
�������������������������������������������������������������������������Ĵ��
���                          ULTIMAS ALTERACOES                           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/

User Function MA410MNU()


aadd(aRotina,{'Flag Envia Dragon'   ,'U_GTIF001()'  ,0,4,0,NIL})  
aadd(aRotina,{"#Imprimir Pedido"     ,"U_IMPPV"      ,0,2,0,NIL})
 
	
Return()
