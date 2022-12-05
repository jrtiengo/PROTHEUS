#INCLUDE 'RWMAKE.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TOPCONN.CH'

#DEFINE  ENTER CHR(13)+CHR(10)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ConvHora    ³ Autor ³ Fabiano Pereira     ³ Data ³ 21/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Converte Horas do Padra para padrao HH.MM Protheus         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ P11    												      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ SEPARA O HORARIO EM HORAS:MINUTOS           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


// ******************* CONVERTE INTEIRO PARA CARACTER

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	   HORAS:MINUTOS          - NUMERICO	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHoras		:=	Int(nHorario)       
nMinutos	:=	(nHorario - nHoras)




// ******************* AJUSTE MASCARA HORARIO (CHAR) 

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	   HORAS	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nPonto		:=	AT('.', cHorario ) 
nPonto		:=	IIF(nPonto>0, nPonto, AT(':', cHorario ) )
cHoras		:=	Left(cHorario, nPonto-1)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	  MINUTOS	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cMinutos	:=	SubStr(cHorario, nPonto+1, Len(cHorario) )
nPonto		:=	AT('.', cMinutos ) - 1 
nPonto		:=	IIF(nPonto>0, nPonto, AT(':', cMinutos ) -1 )
cMinutos	:=	IIF(Len(cMinutos)==2, cMinutos+':00', cMinutos)




//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³	   HORAS:MINUTOS          - NUMERICO	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nHoras		:=	Int(nHorario)       
nMinutos	:=	(nHorario - nHoras)

cHorario :=  PadL(cHoras,2,"0")+':'+ PadL(cMinutos, 2, "0" )



RestArea(aArea)
Return(cHorario)