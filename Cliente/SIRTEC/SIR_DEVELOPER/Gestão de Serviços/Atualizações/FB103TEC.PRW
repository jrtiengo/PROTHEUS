#INCLUDE "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FB103TEC º Autor ³ Diego Peruzzo      º Data ³  02/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Tela para preenchimento de OS x Equipes                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FB103TEC(_cOS)
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

_aYesFields := {"ZZM_EQUIPE","ZZM_NOMEQU"}
aHeader 	:= U_GeraHead ("ZZM",.T.,,_aYesFields,.T.)
aCols 	:= U_GeraCols (	"ZZM",;
									1, ;
									xFilial('ZZM') + _cOS, ;
									"ZZM->(ZZM_FILIAL + ZZM_NUMOS) == '" + xFilial('ZZM') + _cOS + "' ", ;
									aHeader, ;
									.F.)
nGd1 := 2
nGd2 := 2
nGd3 := 150 //aPosObj[2,3]-aPosObj[2,1]-15
nGd4 := 350 //aPosObj[2,4]-aPosObj[2,2]-4

If Len(aCols) > 0
	
	DEFINE MSDIALOG oDlg TITLE "Ordem de Serviço x Equipes" From 0,0 To 350,700 OF oMainWnd PIXEL
	
	oGetDad := MsNewGetDados():New(nGd1,nGd2,nGd3,nGd4,IIF(ALTERA,GD_INSERT+GD_UPDATE+GD_DELETE,0),"AllwaysTrue()","AllwaysTrue()",,/*aAlteraveis*/,/*freeze*/,,/*fieldok*/,/*superdel*/,/*delok*/,oDlg,aHeader,aCols)
	
	@ oDlg:nClientHeight / 2 - 30, oDlg:nClientWidth / 2 - 60 bmpbutton type 1 action ( ( oDlg:End(), _lOk:=.T.) )
	@ oDlg:nClientHeight / 2 - 30, oDlg:nClientWidth / 2 - 30 bmpbutton type 2 action ( ( oDlg:End(), _lOk:=.F.) )
	
	ACTIVATE DIALOG oDlg CENTERED
	
	If _lOk
		aCols := aClone(oGetDad:aCols)		
		_delZZM(_cOS) //Limpa registros da ZZM
		
		For _i := 1 to len(aCols)
			
			If !GdDeleted(_i) .and. !Empty(GdFieldGet("ZZM_EQUIPE",_i))
				
				RecLock("ZZM",.T.)
				ZZM->ZZM_FILIAL	:= xFilial("ZZM")
				ZZM->ZZM_NUMOS		:= _cOS
				ZZM->ZZM_EQUIPE	:= GdFieldGet("ZZM_EQUIPE",_i)
				MsUnlock()
			Endif
		Next _i
	Endif
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunção    ³ _delZZM  º Autor ³ Diego Peruzzo      º Data ³  31/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função que limpa a tabela ZZM, somente do cliente passado  º±±
±±º          ³ pelo parâmetro.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function _delZZM(_cOS)

DbSelectArea("ZZM")
DbSetOrder(1)
MsSeek( xFilial("ZZM") + _cOS )

While ZZM->(!EoF()) .AND. xFilial("ZZM") + _cOS == ZZM->(ZZM_FILIAL + ZZM_EQUIPE)
	
	RecLock("ZZM",.F.)
	DbDelete()
	MsUnLock()
	
	ZZM->(DbSkip())
Enddo

Return
