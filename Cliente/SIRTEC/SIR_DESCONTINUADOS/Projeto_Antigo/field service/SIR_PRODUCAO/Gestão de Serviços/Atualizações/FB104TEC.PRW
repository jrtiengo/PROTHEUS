#INCLUDE "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FB104TEC º Autor ³ Diego Peruzzo      º Data ³  12/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Tela para preenchimento de tabela de preco x Tipo OS       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FB104TEC(_cTabela)
Local oDlg
Local oGetDad
Local aSizeAut  	:= MsAdvSize()
Local _lOk			:= .F.
Private aHeader	:= {}
Private aCols		:= {}

aPosObj  := {}
aObjects := {}

AAdd( aObjects, { 315,  50, .T., .T. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

_aYesFields := {"ZZL_TIPOOS"}
aHeader 	:= U_GeraHead ("ZZL",.T.,,_aYesFields,.T.)
aCols 	:= U_GeraCols(	"ZZL",;
									1, ;
									xFilial('ZZL') + _cTabela, ;
									"ZZL->(ZZL_FILIAL + ZZL_TABELA) == '" + xFilial('ZZL') + _cTabela + "' ", ;
									aHeader, ;
									.F.)
nGd1 := 2
nGd2 := 2
nGd3 := 150 //aPosObj[2,3]-aPosObj[2,1]-15
nGd4 := 350 //aPosObj[2,4]-aPosObj[2,2]-4

If Len(aCols) > 0
	
	DEFINE MSDIALOG oDlg TITLE "Tabela de Preço x Tipo OS" From 0,0 To 350,700 OF oMainWnd PIXEL
	
	oGetDad := MsNewGetDados():New(nGd1,nGd2,nGd3,nGd4,IIF(ALTERA,GD_INSERT+GD_UPDATE+GD_DELETE,0),"AllwaysTrue()","AllwaysTrue()",,/*aAlteraveis*/,/*freeze*/,,/*fieldok*/,/*superdel*/,/*delok*/,oDlg,aHeader,aCols)
	
	@ oDlg:nClientHeight / 2 - 30, oDlg:nClientWidth / 2 - 60 bmpbutton type 1 action ( ( oDlg:End(), _lOk:=.T.) )
	@ oDlg:nClientHeight / 2 - 30, oDlg:nClientWidth / 2 - 30 bmpbutton type 2 action ( ( oDlg:End(), _lOk:=.F.) )
	
	ACTIVATE DIALOG oDlg CENTERED
	
	If _lOk
		aCols := aClone(oGetDad:aCols)		
		_delZZL(_cTabela) //Limpa registros da ZZL para o cliente posicionado
		
		For _i := 1 to len(aCols)
			
			If !GdDeleted(_i) .and. !Empty(GdFieldGet("ZZL_TIPOOS",_i))
				
				RecLock("ZZL",.T.)
				ZZL->ZZL_FILIAL	:= xFilial("ZZL")
				ZZL->ZZL_TABELA	:= _cTabela
				ZZL->ZZL_TIPOOS	:= GdFieldGet("ZZL_TIPOOS",_i)
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
±±ºFunção    ³ _delZZL  º Autor ³ Diego Peruzzo      º Data ³  31/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função que limpa a tabela ZZL, somente do cliente passado  º±±
±±º          ³ pelo parâmetro.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function _delZZL(_cTabela)

DbSelectArea("ZZL")
DbSetOrder(1)
MsSeek( xFilial("ZZL") + _cTabela )

While ZZL->(!EoF()) .AND. xFilial("ZZL") + _cTabela == ZZL->(ZZL_FILIAL + ZZL_TABELA)
	
	RecLock("ZZL",.F.)
	DbDelete()
	MsUnLock()
	
	ZZL->(DbSkip())
Enddo

Return
