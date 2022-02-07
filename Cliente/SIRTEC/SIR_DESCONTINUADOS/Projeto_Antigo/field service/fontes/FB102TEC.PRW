#INCLUDE "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FB102TEC º Autor ³ Diego Peruzzo      º Data ³  12/09/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Tela para preenchimento de cliente x tabela de preco       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FB102TEC(_cCli, _cLoj)
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

_aYesFields := {"ZZJ_TABELA","ZZJ_DESC"}
aHeader 	:= U_GeraHead ("ZZJ",.T.,,_aYesFields,.T.)
aCols 	:= U_GeraCols (	"ZZJ",;
									1, ;
									xFilial('ZZJ') + _cCli + _cLoj, ;
									"ZZJ->(ZZJ_FILIAL + ZZJ_CLIENT + ZZJ_LOJA) == '" + xFilial('ZZJ') + _cCli + _cLoj + "' ", ;
									aHeader, ;
									.F.)
nGd1 := 2
nGd2 := 2
nGd3 := 150 //aPosObj[2,3]-aPosObj[2,1]-15
nGd4 := 350 //aPosObj[2,4]-aPosObj[2,2]-4

If Len(aCols) > 0
	
	DEFINE MSDIALOG oDlg TITLE "Cliente x Tabela de Preço" From 0,0 To 350,700 OF oMainWnd PIXEL
	
	oGetDad := MsNewGetDados():New(nGd1,nGd2,nGd3,nGd4,IIF(ALTERA,GD_INSERT+GD_UPDATE+GD_DELETE,0),"AllwaysTrue()","AllwaysTrue()",,/*aAlteraveis*/,/*freeze*/,,/*fieldok*/,/*superdel*/,/*delok*/,oDlg,aHeader,aCols)
	
	@ oDlg:nClientHeight / 2 - 30, oDlg:nClientWidth / 2 - 60 bmpbutton type 1 action ( ( oDlg:End(), _lOk:=.T.) )
	@ oDlg:nClientHeight / 2 - 30, oDlg:nClientWidth / 2 - 30 bmpbutton type 2 action ( ( oDlg:End(), _lOk:=.F.) )
	
	ACTIVATE DIALOG oDlg CENTERED
	
	If _lOk
		aCols := aClone(oGetDad:aCols)		
		_delZZJ(_cCli, _cLoj) //Limpa registros da ZZJ para o cliente posicionado
		
		For _i := 1 to len(aCols)
			
			If !GdDeleted(_i) .and. !Empty(GdFieldGet("ZZJ_TABELA",_i))
				
				RecLock("ZZJ",.T.)
				ZZJ->ZZJ_FILIAL	:= xFilial("ZZJ")
				ZZJ->ZZJ_CLIENT	:= _cCli
				ZZJ->ZZJ_LOJA		:= _cLoj
				ZZJ->ZZJ_TABELA	:= GdFieldGet("ZZJ_TABELA",_i)
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
±±ºFunção    ³ _delZZJ  º Autor ³ Diego Peruzzo      º Data ³  31/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função que limpa a tabela ZZJ, somente do cliente passado  º±±
±±º          ³ pelo parâmetro.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function _delZZJ(_cCli, _cLoj)

DbSelectArea("ZZJ")
DbSetOrder(1)
MsSeek( xFilial("ZZJ") + _cCli + _cLoj )

While ZZJ->(!EoF()) .AND. xFilial("ZZJ") + _cCli + _cLoj == ZZJ->(ZZJ_FILIAL + ZZJ_CLIENT + ZZJ_LOJA)
	
	RecLock("ZZJ",.F.)
	DbDelete()
	MsUnLock()
	
	ZZJ->(DbSkip())
Enddo

Return
