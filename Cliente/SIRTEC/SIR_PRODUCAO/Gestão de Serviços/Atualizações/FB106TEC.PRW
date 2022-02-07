#INCLUDE "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FB106TEC º Autor ³ Diego Peruzzo      º Data ³  12/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Tela para preenchimento de tabela de preco x Tipo OS       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FB106TEC(_cNumOrc)
Local oDlg
Local oGetDad
Local aSizeAut  	:= MsAdvSize()
Private aHeader	:= {}
Private aCols		:= {}

aPosObj  := {}
aObjects := {}

AAdd( aObjects, { 315,  50, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

_aYesFields := { "ZZP_ITEM","ZZP_SUBITE","ZZP_CODPRO","ZZP_DESPRO","ZZP_CODSER","ZZP_QUANT","ZZP_VUNIT","ZZP_TOTAL","ZZP_PRCLIS","ZZP_YTABPE"}
aHeader 	:= U_GeraHead ("ZZP",.T.,,_aYesFields,.T.)
aCols 		:= U_GeraCols (	"ZZP",;
									1, ;
									xFilial('ZZP') + _cNumOrc, ;
									"ZZP->(ZZP_FILIAL + ZZP_NUMORC) == '" + xFilial('ZZP') + _cNumOrc + "' ", ;
									aHeader, ;
									.F.)
nGd1 := 2
nGd2 := 2
nGd3 := 150 //aPosObj[2,3]-aPosObj[2,1]-15
nGd4 := 350 //aPosObj[2,4]-aPosObj[2,2]-4

If Len(aCols) > 0
	
	DEFINE MSDIALOG oDlg TITLE "Itens Vistoriados - Orçamento " + _cNumOrc From 0,0 To 350,700 OF oMainWnd PIXEL
	
	oGetDad := MsNewGetDados():New(nGd1,nGd2,nGd3,nGd4,0,"AllwaysTrue()","AllwaysTrue()",,/*aAlteraveis*/,/*freeze*/,,/*fieldok*/,/*superdel*/,/*delok*/,oDlg,aHeader,aCols)
	
	@ oDlg:nClientHeight / 2 - 30, oDlg:nClientWidth / 2 - 60 bmpbutton type 1 action ( ( oDlg:End(), _lOk:=.T.) )
//	@ oDlg:nClientHeight / 2 - 30, oDlg:nClientWidth / 2 - 30 bmpbutton type 2 action ( ( oDlg:End(), _lOk:=.F.) )
	
	ACTIVATE DIALOG oDlg CENTERED
else
	MsgInfo("Não existem itens Vistoriados.")	
Endif

Return

