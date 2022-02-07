#INCLUDE "protheus.ch"
#INCLUDE "rwmake.ch"
//#Include "colors.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FB002TEC  ºAutor  ³Felipe S. Raota      º Data ³  16/10/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cadastro de Itens do CheckList                             º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FB002TEC()

Private cCadastro := "Itens CheckList"

Private aRotina := { {"Pesquisar","AxPesqui",0,1},;
		               {"Visualizar","AxVisual",0,2},;
		               {"Manutenção","U_FB002MAN",0,3}}

Private cDelFunc := "U__002VLDEXC(ZZG->ZZG_CODIGO)" // Validacao para a exclusao. Pode-se utilizar ExecBlock

dbSelectArea("ZZG")
ZZG->(dbSetOrder(5))

mBrowse( 6,1,22,75,"ZZG")

Return

User Function FB002MAN()

Local oDlgChk, oSay, oTGet, oSay2, oTBut, oTGet2
Local cClient     := Space(6)
Local cClient2    := Space(6)
Local npc      := 0
Local aHeadZG  := {}
Local aColsZG  := {}
Local aYesAlt  := {"ZZG_CODIGO", "ZZG_DESC"}
Local aYesCmp  := {"ZZG_CODIGO", "ZZG_DESC"}

Private oGetDChk
Private _cNomeCli := ""

aHeadZG := U_GeraHead("ZZG",.T.,,aYesCmp,.T.)

@ 000, 000 TO 300, 700 DIALOG oDlgChk TITLE  "Itens CheckList"
	
	oSay := TSay():New(005,005,{||'Informe abaixo o cliente e após os itens da CheckList que pertencem..'},oDlgChk,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	
	@ 020, 005 Say "Cliente:"
	oTGet := TGet():New( 018,025,{|u| If(Pcount()>0,cClient:=u,cClient ) },oDlgChk,030,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,{|| _GerCols(cClient, @aColsZG, @oSay2, @cClient2) },.F.,.F.,"SA1",cClient,,,, )
	
	oSay2 := TSay():New( 019,080,{|| _cNomeCli },oDlgChk,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	
	oGetDChk := MsNewGetDados():New(35,005,133,348,GD_INSERT+GD_UPDATE+GD_DELETE,"AllwaysTrue()","AllwaysTrue()",,aYesAlt,/*freeze*/,,/*fieldok*/,/*superdel*/,"U__002VLDEXC(GdFieldGet('ZZG_CODIGO'))",/*oFolder:aDialogs[1]*/,aHeadZG,aColsZG)
	
	oTBut := TButton():New( 136, 005, "Copiar para: ",oDlgChk,{|| IIF(!Empty(cClient2), _CopyClient(cClient, oGetDChk:aCols, cClient2), Alert("Informe o Cliente que deseja copiar.") ) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTGet2 := TGet():New( 136,055,{|u| If(Pcount()>0,cClient2:=u,cClient2 ) },oDlgChk,030,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,{||  },.F.,.F.,"SA1",cClient2,,,, )
	
	@ 136, 292 BMPBUTTON TYPE 1 ACTION ( nOpc := 1, oDlgChk:END() )
	@ 136, 322 BMPBUTTON TYPE 2 ACTION ( nOpc := 2, oDlgChk:END() )
	
ACTIVATE DIALOG oDlgChk CENTERED

If nOpc == 1
	
	_aC := oGetDChk:aCols
	
	dbSelectArea("ZZG")
	ZZG->(dbSetOrder(5))
	
	If ZZG->(MsSeek( xFilial("ZZG") + cClient ))
		
		While ZZG->(!EoF()) .AND. xFilial("ZZG") + cClient == ZZG->ZZG_FILIAL + ZZG->ZZG_CLIENT
		
			RecLock("ZZG", .F.)
				dbDelete()
			MsUnLock()
			
			ZZG->(dbSkip())
		Enddo
		
	Endif
	
	For _x:=1 to len(_aC)
		
		If !_aC[_x,3]
			RecLock("ZZG", .T.)
				ZZG->ZZG_client := cClient
				ZZG->ZZG_CODIGO := _aC[_x,1]
				ZZG->ZZG_DESC   := _aC[_x,2]
			MsUnLock()
		Endif
		
	Next

Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GerCols   ³ Autor ³ Felipe S. Raota            ³ Data ³ 16/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Gera linhas do aCols para a grid.                                 ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB002TEC                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GerCols(cClient, aC, oSay, cClient2)

dbSelectArea("SA1")
SA1->(dbSetOrder(1))

If SA1->(MsSeek( xFilial("SA1") + cClient ))
	
	oSay:SetText( Alltrim(SA1->A1_NOME) )
	oSay:CtrlRefresh()
	_cNomeCli := Alltrim(SA1->A1_NOME)
	
	dbSelectArea("ZZG")
	ZZG->(dbSetOrder(5))
	
	If ZZG->(MsSeek( xFilial("ZZG") + cClient ))
		
		SET FILTER TO Alltrim(ZZG->ZZG_CLIENT) == Alltrim(cClient)
		
		ZZG->(dbGoTop())
		
		aC := {}
		
		While ZZG->(!EoF())
			
			aADD(aC, {ZZG->ZZG_CODIGO, ZZG->ZZG_DESC, .F.})
			
			ZZG->(dbSkip())
		Enddo
		
		SET FILTER TO
		
		oGetDChk:aCols := aC
		oGetDChk:ForceRefresh()
		
	Else
		aC := {}
		aADD(aC, {Space(6), Space(250), .F.})
		oGetDChk:aCols := aC
		oGetDChk:ForceRefresh()
	Endif
	
	ZZG->(dbCloseArea())
	
Else
	
	oSay:SetText( "" )
	oSay:CtrlRefresh()
	aADD(aC, {Space(6), Space(250), .F.})
	oGetDChk:aCols := aC
	oGetDChk:ForceRefresh()
	Alert("Cliente não encontrado!")
Endif

cClient2 := Space(6)

Return

/*
Valida a Exclusao do Item
*/
User Function _002VLDEXC(cCod)
Local lRet := .T.

dbSelectArea("ZZH")
ZZH->(dbSetOrder(2))
IF ZZH->(MsSeek(xFilial("ZZH") + cCod))
	lRet := .F.
	MsgStop("Item ja associado a um cliente, sua exclusão não é permitida.")
Endif

Return lRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _CopyClient³ Autor ³ Felipe S. Raota            ³ Data ³ 16/10/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Copia itens de checklist para outro cliente.                      ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB002TEC                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _CopyClient(cClient, aC, cClient2)

If Empty(cClient) .OR. Empty(cClient2)
	Alert("Preencha os campos de Cliente corretamente.")
	Return
Endif

dbSelectArea("SA1")
SA1->(dbSetOrder(1))

If !SA1->(MsSeek( xFilial("SA1") + cClient2 ))
	Alert("Cliente informado para cópia não existe.")
	Return
Endif

dbSelectArea("ZZG")
ZZG->(dbSetOrder(5))

If ZZG->(MsSeek( xFilial("ZZG") + cClient2 ))

	If MsgYesNo("O cliente: " + Alltrim(cClient2) + " já possui itens cadastrados. Deseja sobrepor as informações?")
			
		If ZZG->(MsSeek( xFilial("ZZG") + cClient2 ))
			While ZZG->(!EoF()) .AND. xFilial("ZZG")+cClient2 == ZZG->ZZG_FILIAL+ZZG->ZZE_CLIENT
			
				RecLock("ZZE", .F.)
					dbDelete()
				MsUnLock()
				
				ZZG->(dbSkip())
			Enddo
		Endif
		
		For _x:=1 to len(aC)
			If !aC[_x,3]
				RecLock("ZZG", .T.)
					ZZG->ZZG_client := cClient2
					ZZG->ZZG_CODIGO := aC[_x,1]
					ZZG->ZZG_DESC   := aC[_x,2]
				MsUnLock()
			Endif
		Next
	
	Endif

Else

	For _x:=1 to len(aC)
		If !aC[_x,3]
			RecLock("ZZG", .T.)
				ZZG->ZZG_client := cClient2
				ZZG->ZZG_CODIGO := aC[_x,1]
				ZZG->ZZG_DESC   := aC[_x,2]
			MsUnLock()
		Endif
	Next

Endif

MsgInfo("Copiado com sucesso!")

Return