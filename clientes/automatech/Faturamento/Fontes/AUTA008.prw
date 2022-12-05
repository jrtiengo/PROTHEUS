#include "rwmake.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ AUTA008  ºAutor  ³ Cesar Mussi        º Data ³  01/07/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function AUTA008()

SetPrvt("CNOTAFIS,CSERIE,DEMISSAO,NPBRUTO,NPLIQ,CESPECIE")
SetPrvt("CVOLUME,CTRANSP,CNROCONH,CNROVOO,DDATEXP,CCLIENTE")
SetPrvt("NVALNOT,CCGC,CIE,")

   U_AUTOM628("AUTA008")

cNotaFis:= Space(6)
cSerie  := Space(3)
@ 00,000 TO 100,230 DIALOG FASPedA TITLE "Alteracao dos dados de Embarque das Notas Fiscais"
@ 10,005 Say "Nr.da Nota Fiscal:"
@ 10,60 Get cNotaFis VALID ExistCpo("SF2",cNotaFis) F3 "SF2"
@ 30,005  BUTTON "_Confirma" Size 50,10 ACTION FConfirma()
@ 30,060  BUTTON "_Abandona" Size 50,10 ACTION close(FasPedA)
ACTIVATE DIALOG FasPedA CENTER
Return

Static Function FConfirma()
DbSelectArea("SF2")
DbSetOrder(1)
DbSeek( xFilial("SF2") + cNotaFis)
dEmissao := SF2->F2_EMISSAO
nPbruto := SF2->F2_Pbruto
nPliq   := SF2->F2_Pliqui
cEspecie:= SF2->F2_Especi1
cVolume := SF2->F2_Volume1
cTransp := SF2->F2_Transp
cCliente:= SF2->F2_Cliente+SF2->F2_Loja
nValNot := SF2->F2_VALBRUT
DbSelectArea("SA1")
DbSetOrder(1)
DbSeek( xFilial("SA1") + cCliente)
If !EOF()
	cCliente := cCliente+" - "+SA1->A1_Nome
	cCGC := SA1->A1_CGC
	cIE := SA1->A1_INSCR
Endif
DbSelectArea("SF2")
@ 00,000 TO 300,450 DIALOG FASPedb TITLE "Alteracao dos dados de Embarque das Notas Fiscais"
@ 10,010 Say "Nr.da Nota Fiscal:"
@ 10,70 say cNotaFis
@ 10,95 SAY 'em '
@ 10,104 SAY dEmissao Pict '99/99/99'
@ 17,010 Say "Cliente :"
@ 17,70 Say cCliente
@ 24,010 say "CGC-MF/IE : "
@ 24,70 say cCGC+" / "+cIE
@ 31,010 say "Valor da Nota : "+TRANSFORM(nValNot,"@e R$9,999,999.99")
@ 042,010 Say "Peso Br: "
@ 042,70 Get nPbruto pict "@E 99999.99"
@ 050,010 Say "Peso Lq: "
@ 050,70 Get nPliq pict "@E 99999.99"
@ 060,010 Say "Especie: "
@ 060,70 Get cEspecie
@ 070,010 Say "Volume.: "
@ 070,70 Get cVolume pict "999999"
@ 080,010 Say "Transpor.: "
@ 080,70 Get cTransp VALID ExistCpo("SA4",cTransp) F3 "SA4"
@ 115,160  BUTTON "_Gravar"   Size 50,12 ACTION FGrava()
@ 130,160  BUTTON "_Abandona" Size 50,12 ACTION close(FasPedb)
ACTIVATE DIALOG FasPedb CENTER
Return

Static Function FGrava()
DbSelectArea("SF2")
RecLock("SF2",.f.)
SF2->F2_Pbruto := nPbruto
SF2->F2_Pliqui := nPliq
SF2->F2_Especi1:= cEspecie
SF2->F2_Volume1:= cVolume
SF2->F2_Transp := cTransp
MsUnlock()
DbSelectArea("SF2")
Close( FasPedb)
Return
