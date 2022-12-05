#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MTA416PV ºAutor  ³ Cesar Mussi        º Data ³  24/06/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MTA416PV()
//apagar os gatilhos que recalculam valores e % comis
Local Ant_Area  := GetArea()
Local cOrc 		:= ""
Local nPosProd  := aScan(_aHeader,{|x| AllTrim(x[2])=="C6_PRODUTO"})
Local _nComis1  := 0
Local _nComis2  := 0

DbSelectArea("SCJ")   
cOrc 		:= SCJ->CJ_PROPOST
cNumOrcSCJ  := SCJ->CJ_NUM
	
DbSelectArea("AD1")   
DbSetOrder(6)
DbSeek(xFilial("AD1")+cOrc)               

IF FOUND()
    // Posicionar no ADZ
    DbSelectArea("ADZ")
    DbSeek(xFilial("ADZ")+cOrc)
    Do While xFilial("ADZ")+cOrc == ADZ->ADZ_FILIAL + ADZ->ADZ_PROPOS
       For _nx := 1 to Len(_aCols)
           IF ADZ->ADZ_PRODUT == _aCols[_nx,nPosProd]
              _nComis1 := ADZ->ADZ_COMIS1
              _nComis2 := ADZ->ADZ_COMIS2
           ENDIF
       Next _nx
       DbSelectArea("ADZ")
       DbSkip()
    Enddo

	M->C5_VEND1 := AD1->AD1_VEND
	M->C5_VEND2 := AD1->AD1_VEND2
	M->C5_COMIS1:= IIF(_nComis1 > 0 , 0 , AD1->AD1_COMIS1)
	M->C5_COMIS2:= IIF(_nComis2 > 0 , 0 , AD1->AD1_COMIS2)

    // Gravacao do campo AD1_NUMORC para garantir o Tracker
    RECLOCK("AD1",.f.)
    AD1_NUMORC := cNumOrcSCJ
    MSUNLOCK()

ENDIF

DbSelectArea("SCJ")   
RECLOCK("SCJ",.F.)
CJ_VEND1 := AD1->AD1_VEND
CJ_VEND2 := AD1->AD1_VEND2
CJ_COMIS1:= AD1->AD1_COMIS1
CJ_COMIS2:= AD1->AD1_COMIS2
MsUnlock()


DbSelectArea("ADY")   
DbSetOrder(1)
DbSeek(xFilial("ADY")+cOrc)               
IF FOUND()
	M->C5_OBSI	  := ADY->ADY_OBSI
	M->C5_TRANSP  := ADY->ADY_TRANSP
	M->C5_TPFRETE := ADY->ADY_TPFRETE
ENDIF

RestArea(Ant_Area)

Return(.T.)


User Function MT416FIM

nCesar := 0

Return(.t.)                                             


USER FUNCTION M415GRV

nCesar := 0      //ck_propost
DbSelectArea("TMP1")
DbGoTop()
Do While ! eof()




   DbSelectArea("TMP1")  
   DbSkip()

Enddo





Return(.t.)