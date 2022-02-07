#INCLUDE "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FB101TEC º Autor ³ Diego Peruzzo      º Data ³  31/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Tela para preenchimento de cliente x checklist             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Específico                                                 º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function FB101TEC(_cCli, _cLoj)

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

_aYesFields := {"ZZH_CODCHK","ZZH_DESCIT"}
aHeader 	:= U_GeraHead ("ZZH",.T.,,_aYesFields,.T.)
aCols 	:= U_GeraCols (	"ZZH",;
									1, ;
									xFilial('ZZH') + _cCli + _cLoj, ;
									"ZZH->(ZZH_FILIAL + ZZH_CODCLI + ZZH_LOJCLI) == '" + xFilial('ZZH') + _cCli + _cLoj + "' ", ;
									aHeader, ;
									.F.)
nGd1 := 2
nGd2 := 2
nGd3 := 150 //aPosObj[2,3]-aPosObj[2,1]-15
nGd4 := 350 //aPosObj[2,4]-aPosObj[2,2]-4

If Len(aCols) > 0
	
	DEFINE MSDIALOG oDlg TITLE "Cliente x CheckList" From 0,0 To 350,700 OF oMainWnd PIXEL
	
	oGetDad := MsNewGetDados():New(nGd1,nGd2,nGd3,nGd4,IIF(ALTERA,GD_INSERT+GD_UPDATE+GD_DELETE,0),"AllwaysTrue()","AllwaysTrue()",,/*aAlteraveis*/,/*freeze*/,,/*fieldok*/,/*superdel*/,/*delok*/,oDlg,aHeader,aCols)
	
	@ oDlg:nClientHeight / 2 - 30, oDlg:nClientWidth / 2 - 60 bmpbutton type 1 action ( ( oDlg:End(), _lOk:=.T.) )
	@ oDlg:nClientHeight / 2 - 30, oDlg:nClientWidth / 2 - 30 bmpbutton type 2 action ( ( oDlg:End(), _lOk:=.F.) )
	
	oTBut := TButton():New( oDlg:nClientHeight / 2 - 30, nGd1, " Padrão ",oDlg,{|| _BuscaPad(@oGetDad, _cCli, _cLoj) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	ACTIVATE DIALOG oDlg CENTERED
	
	If _lOk
		aCols := aClone(oGetDad:aCols)		
		_delZZH(_cCli, _cLoj) //Limpa registros da SZA para o cliente posicionado
		
		For _i := 1 to len(aCols)
			
			If !GdDeleted(_i) .and. !Empty(GdFieldGet("ZZH_CODCHK",_i))
				
				RecLock("ZZH",.T.)
				ZZH->ZZH_FILIAL	:= xFilial("ZZH")
				ZZH->ZZH_CODCLI	:= _cCli
				ZZH->ZZH_LOJCLI	:= _cLoj
				ZZH->ZZH_CODCHK	:= GdFieldGet("ZZH_CODCHK",_i)
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
±±ºFunção    ³ _delZZH  º Autor ³ Diego Peruzzo      º Data ³  31/07/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Função que limpa a tabela ZZH, somente do cliente passado  º±±
±±º          ³ pelo parâmetro.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function _delZZH(_cCli, _cLoj)

DbSelectArea("ZZH")
DbSetOrder(1)
MsSeek( xFilial("ZZH") + _cCli + _cLoj )

While ZZH->(!EoF()) .AND. xFilial("ZZH") + _cCli + _cLoj == ZZH->(ZZH_FILIAL + ZZH_CODCLI + ZZH_LOJCLI)
	
	RecLock("ZZH",.F.)
		DbDelete()
	MsUnLock()
	
	ZZH->(DbSkip())
Enddo

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºFunção    ³ _BuscaPadº Autor ³ Felipe S. Raota    º Data ³  09/10/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Busca itens padrões do cliente.                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function _BuscaPad(oObj, cCli)

Local aC := {}

If MsgYesNo("Deseja buscar a lista padrão para o cliente: " + Alltrim(cCli))

	dbSelectArea("ZZG")
	ZZG->(dbSetOrder(5)) // FILIAL + CLIENTE
	
	If ZZG->(MsSeek( xFilial("ZZG") + cCli ))
		
		While ZZG->(!EoF()) .AND. xFilial("ZZG") + cCli == ZZG->ZZG_FILIAL + ZZG->ZZG_CLIENT
			
			aADD(aC, { ZZG->ZZG_CODIGO, ZZG->ZZG_DESC, .F. } )
			
			ZZG->(dbSkip())
		Enddo
		
		oObj:aCols := aC
		oObj:ForceRefresh()
		
	Else
		Alert("Nenhum item encontrado para esse cliente.")
	Endif

Endif

Return