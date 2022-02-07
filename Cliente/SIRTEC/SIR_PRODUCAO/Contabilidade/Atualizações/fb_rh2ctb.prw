#include "rwmake.ch"

User Function FB_RH2CTB()

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  � FB_RH2CTB� Autor � Evandro Mugnol        � Data � 21.06.10 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Montagem dos historicos para contabilizacao da folha de    ���
���          � pagamento                                                  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Utilizacao� Especifico para Sirtec                                     ���
�������������������������������������������������������������������������Ĵ��
���   Data   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/

_aArea := GetArea()

_cHistor := Space(40)
_cVerba  := SRZ->RZ_PD

DbSelectArea("SRV")
DBSetorder(1)
DbSeek(xFilial("SRV") + _cVerba)
If Found()
   If !Empty(SRV->RV_FORMULA)
       _cHistor := Formula(SRV->RV_FORMULA)
   Endif
Else
   MsgAlert("Nao foi encontrado hist�rico contabil para a Verba " + _cVerba)
Endif

RestArea(_aArea)

Return(_cHistor)
