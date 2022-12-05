#include "RWMAKE.CH"
#include "PROTHEUS.CH"
#include "TOPCONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³PE_MA260D3FºAutor  ³Microsiga           º Data ³  10/29/14   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function MA260D3F()

Local _aArea    := GetArea()
Local _aAreaSD3 := SD3->(GetArea())
Local _aCabec   := {}
Local _aItens   := {}
Local _cBody    := ""
Local _cDest    := Alltrim(GEtMv("AU_EMTRANS"))

_cTitulo := "Transferência entre Armazéns"
If Alltrim(FunName()) == "MATA260"
aAdd(_aCabec,"Código")
aAdd(_aCabec,"Descrição")
aAdd(_aCabec,"Nro. Série")
aAdd(_aCabec,"Arm. Orig.")
aAdd(_aCabec,"Arm.Dest.")
aAdd(_aCabec,"Quantidade")
aAdd(_aCabec,"Usuário")

aAdd(_aItens,{ cCodOrig, ; 
			   Posicione("SB1",1,xFilial("SB1")+cCodOrig,"B1_DESC") ,;
			   cNumSerie,;
			   cLocOrig,;
			   cLocDest,;
			   nQuant260,;
			   UsrRetName(RetCodUsr());
			})
			   	

/*
cCodOrig 	:= SD3->D3_COD
cUmOrig  	:= SD3->D3_UM
cLocOrig 	:= SD3->D3_LOCAL
cLoclzOrig 	:= SD3->D3_LOCALIZ
cNumLote    := SD3->D3_NUMLOTE
cNumSerie   := SD3->D3_NUMSERI

dbSkip()
cCodDest 	:= SD3->D3_COD
cUmDest  	:= SD3->D3_UM
cLocDest 	:= SD3->D3_LOCAL
cLoclzDest 	:= SD3->D3_LOCALIZ
nQuant260   := SD3->D3_QUANT
nQuant260D  := SD3->D3_QTSEGUM
cLoteDigi	:= SD3->D3_LOTECTL
dDtValid 	:= SD3->D3_DTVALID
nPotencia 	:= SD3->D3_POTENCI
cDocto   	:= SD3->D3_DOC
dEmis260 	:= SD3->D3_EMISSAO

*/
_cBody := U_AutomHTML(_cTitulo,_aCabec,_aItens)

U_AUTOMR20(_cBody, _cDest, "", _cTitulo)

EndIf

RestArea(_aArea)
RestArea(_aAreaSD3)

Return


