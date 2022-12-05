#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'

#DEFINE  ENTER CHR(13)+CHR(10)

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    �ConvHora    � Autor � Fabiano Pereira     � Data � 21/05/13 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Converte Horas do Padra para padrao HH.MM Protheus         ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � P11    												      ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
*********************************************************************
User Function ConvHora()
*********************************************************************
Local 	aArea 		:= 	GetArea()
Local 	nHorario	:=	ParamIxb[1]
Local 	aValor		:=	{}
Local 	nTempConv	:=	0
Local 	nLotePad	:=	0
Local 	nSegundos	:=	0
  
//���������������������������������������������Ŀ
//� SEPARA O HORARIO EM HORAS:MINUTOS           �
//�����������������������������������������������


// ******************* CONVERTE INTEIRO PARA CARACTER

//�����������������������������������������Ŀ
//�	   HORAS:MINUTOS          - NUMERICO	�
//�������������������������������������������
nHoras		:=	Int(nHorario)       
nMinutos	:=	(nHorario - nHoras)




// ******************* AJUSTE MASCARA HORARIO (CHAR) 

//�������������Ŀ
//�	   HORAS	�
//���������������
nPonto		:=	AT('.', cHorario ) 
nPonto		:=	IIF(nPonto>0, nPonto, AT(':', cHorario ) )
cHoras		:=	Left(cHorario, nPonto-1)

//�������������Ŀ
//�	  MINUTOS	�
//���������������
cMinutos	:=	SubStr(cHorario, nPonto+1, Len(cHorario) )
nPonto		:=	AT('.', cMinutos ) - 1 
nPonto		:=	IIF(nPonto>0, nPonto, AT(':', cMinutos ) -1 )
cMinutos	:=	IIF(Len(cMinutos)==2, cMinutos+':00', cMinutos)




//�����������������������������������������Ŀ
//�	   HORAS:MINUTOS          - NUMERICO	�
//�������������������������������������������
nHoras		:=	Int(nHorario)       
nMinutos	:=	(nHorario - nHoras)

cHorario :=  PadL(cHoras,2,"0")+':'+ PadL(cMinutos, 2, "0" )



RestArea(aArea)
Return(cHorario)