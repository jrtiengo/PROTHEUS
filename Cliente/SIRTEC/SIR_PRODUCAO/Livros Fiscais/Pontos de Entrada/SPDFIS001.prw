#include"protheus.ch"


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �SPDFIS001 �Autor  �Amanda V. da Silva  � Data �  12/01/10   ���
�������������������������������������������������������������������������͹��
���Desc.     �Altera os tipos de produtos para a geracao do arquivo do    ���
���          �SPED Fiscal                                                 ���
�������������������������������������������������������������������������͹��
���Uso       � Sirtec                                                     ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function SPDFIS001()
Local _aTipo 	:= ParamIXB[1]
Local _aTpUser 	:= {}

AADD(_aTpUser,{"PV","00"})
AADD(_aTpUser,{"MS","99"})
AADD(_aTpUser,{"PI","06"})
AADD(_aTpUser,{"CR","99"})
AADD(_aTpUser,{"ME","10"})

For _x := 1 To Len (_aTpUser)
	_nLin := aScan(_aTipo,{|x|x[1]==_aTpUser[_x,1]})
	IF _nLin >0
		_aTipo[_nLin,2] := _aTpUser[_x,2]
	else
		aADD (_aTipo,aClone(_aTpUser[_x]))
	endif
next              

//U_ShowArray(_aTipo)
Return _aTipo
