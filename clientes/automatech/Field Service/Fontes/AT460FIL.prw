#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
��������������������������������������������������������������������������"��
���Programa  �AT460FIL  �Autor  �Fabiano Pereira     � Data �  07/05/14   ���
�������������������������������������������������������������������������͹��
���Desc.     �                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                         ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
******************************************************************************
User Function AT460FIL()
******************************************************************************
Local cFilter := ''

If FunName() == 'TECA450' // CHAMADA VIA ROTINA ALTERACAO OS. ( PE_AT450BUT.PRW \ AT450BUT()
	cFilter += " AB9_FILIAL == '"+xFilial('AB9')+"' .AND. "
	cFilter += " AB9_NUMOS  == '"+AllTrim(M->AB6_NUMOS)+'01'+"'
EndIf


Return(cFilter)