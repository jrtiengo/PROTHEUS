#Include "rwmake.ch"

/*����������������������������������������������������������������������������������
������������������������������������������������������������������������������������
��������������������������������������������������������������������������������Ŀ��
���Programa  � FB011PPR � Autor � Felipe S. Raota             � Data � 11/04/13  ���
��������������������������������������������������������������������������������Ĵ��
���Unidade   � TRS              �Contato � felipe.raota@totvs.com.br             ���
��������������������������������������������������������������������������������Ĵ��
���Descricao � Cadastro de Relacionamento de Indicadores.                        ���
���          �                                                                   ���
��������������������������������������������������������������������������������Ĵ��
���Uso       � Especifico para cliente Sirtec - Projeto PPR                      ���
��������������������������������������������������������������������������������Ĵ��
���Analista  �  Data  � Manutencao Efetuada                                      ���
��������������������������������������������������������������������������������Ĵ��
���          �  /  /  �                                                          ���
���������������������������������������������������������������������������������ٱ�
������������������������������������������������������������������������������������
����������������������������������������������������������������������������������*/

User Function FB011PPR()

Local cVldAlt := ".T." // Operacao: ALTERACAO
Local cVldExc := ".T." // Operacao: EXCLUSAO

dbSelectArea("SZH")
SZH->(dbSetOrder(1))

AxCadastro("SZH", "Cadastro de Relacionamento de Indicadores", cVldExc, cVldAlt)

Return