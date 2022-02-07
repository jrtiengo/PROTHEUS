#INCLUDE "rwmake.ch"
#Include "colors.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FB001TEC  ºAutor  ³Felipe S. Raota      º Data ³  09/10/12  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Cadastro de Equipe X Cidades                               º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function FB001TEC()

Private cCadastro := "Equipe x Cidades"

Private aRotina := { {"Pesquisar","AxPesqui",0,1},;
		               {"Visualizar","AxVisual",0,2},;
		               {"Manutenção","U_001TEC",0,3}}

//{"Incluir","AxInclui",0,3},;
//{"Alterar","AxAltera",0,4},;

Private cDelFunc := ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock

dbSelectArea("ZZE")
ZZE->(dbSetOrder(1))

mBrowse( 6,1,22,75,"ZZE")

Return

User Function 001TEC()

Local oDlg, oSay, oTGet, oSay2, oTBut, oTGet2
Local cEquip     := Space(6)
Local cEquip2    := Space(6)
Local npc      := 0
Local aHeadZ2  := {}
Local aColsZE  := {}
Local aYesAlt  := {"ZZE_EST", "ZZE_CODMUN"}
Local aYesCmp  := {"ZZE_EST", "ZZE_CODMUN", "ZZE_NOMMUN"}

Private oGetDEq
Private _cNomeEq := ""

aHeadZ2 := U_GeraHead("ZZE",.T.,,aYesCmp,.T.)

For _x:=1 to len(aHeadZ2)
	
	If Alltrim(aHeadZ2[_x,2]) == "ZZE_NOMMUN"
		aHeadZ2[_x,12] := ""
	Endif
	
	If Alltrim(aHeadZ2[_x,2]) == "ZZE_CODMUN"
		aHeadZ2[_x,6] := "(GdFieldPut('ZZE_NOMMUN', fBuscaCpo('CC2',1,xFilial('CC2') + GdFieldGet('ZZE_EST') + M->ZZE_CODMUN, 'CC2_MUN')),.T.) "
	Endif
	
Next

@ 000, 000 TO 300, 700 DIALOG oDlg TITLE  "Equipe x Cidades"
	
	oSay := TSay():New(005,005,{||'Informe abaixo a equipe e após as cidades que deseja vincular..'},oDlg,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	
	@ 020, 005 Say "Equipe:"
	oTGet := TGet():New( 018,025,{|u| If(Pcount()>0,cEquip:=u,cEquip ) },oDlg,030,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,{|| (_GerCols(cEquip, @aColsZE, @oSay2), oGetDEq:Enable(), oGetDEq:ForceRefresh()) },.F.,.F.,"AA1ZZ4","cEquip",,,, )
	
	oSay2 := TSay():New( 019,080,{|| _cNomeEq },oDlg,,,,,,.T.,CLR_RED,CLR_WHITE,200,20)
	
	oGetDEq := MsNewGetDados():New(35,005,133,348,GD_UPDATE+GD_INSERT+GD_DELETE,"AllwaysTrue()","AllwaysTrue()",,aYesAlt,/*freeze*/,,/*fieldok*/,/*superdel*/,/*delok*/,/*oFolder:aDialogs[1]*/,aHeadZ2,aColsZE)
	
	oTBut := TButton():New( 136, 005, "Copiar para: ",oDlg,{|| IIF(!Empty(cEquip2), _CopyEquip(cEquip, oGetDEq:aCols, cEquip2), Alert("Informe a Equipe que deseja copiar.") ) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTGet2 := TGet():New( 136,055,{|u| If(Pcount()>0,cEquip2:=u,cEquip2 ) },oDlg,030,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,{||  },.F.,.F.,"AA1ZZ4",cEquip2,,,, )
	
	@ 136, 292 BMPBUTTON TYPE 1 ACTION ( nOpc := 1, oDlg:END() )
	@ 136, 322 BMPBUTTON TYPE 2 ACTION ( nOpc := 2, oDlg:END() )
	
ACTIVATE DIALOG oDlg CENTERED

If nOpc == 1
	
	_aC := oGetDEq:aCols
	
	dbSelectArea("ZZE")
	ZZE->(dbSetOrder(1))
	
	For _x:=1 to len(_aC)
		
		If ZZE->(MsSeek( xFilial("ZZE") + cEquip + _aC[_x,1] + _aC[_x,2] ))
			RecLock("ZZE", .F.)
				dbDelete()
			MsUnLock()
		Endif
		
	Next
	
	For _x:=1 to len(_aC)
		
		If !_aC[_x,4]
			RecLock("ZZE", .T.)
				ZZE->ZZE_EQUIPE := cEquip
				ZZE->ZZE_NOMEQU := _cNomeEq
				ZZE->ZZE_EST := _aC[_x,1]
				ZZE->ZZE_CODMUN := _aC[_x,2]
				ZZE->ZZE_NOMMUN := _aC[_x,3]
			MsUnLock()
		Endif
		
	Next

Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GerCols   ³ Autor ³ Felipe S. Raota            ³ Data ³ 15/08/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Gera linhas do aCols para a grid.                                 ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB108PCP                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GerCols(cEquip, aC, oSay2)

dbSelectArea("AA1")
AA1->(dbSetOrder(1))

If AA1->(MsSeek( xFilial("AA1") + cEquip ))
	
	_cNomeEq := Alltrim(AA1->AA1_NOMTEC)
	oSay2:SetText( Alltrim(AA1->AA1_NOMTEC) )
	oSay2:CtrlRefresh()
	
	dbSelectArea("ZZE")
	ZZE->(dbSetOrder(1))
	
	If ZZE->(MsSeek( xFilial("ZZE") + cEquip ))
		
		SET FILTER TO Alltrim(ZZE->ZZE_EQUIPE) == Alltrim(cEquip)
		
		ZZE->(dbGoTop())
		
		aC := {}
		
		While ZZE->(!EoF())
			
			_cDesc := fBuscaCpo("CC2", 1, xFilial("CC2") + ZZE->ZZE_EST + ZZE->ZZE_CODMUN, "CC2_MUN")
			aADD(aC, {ZZE->ZZE_EST, ZZE->ZZE_CODMUN, Alltrim(_cDesc), .F.})
			
			ZZE->(dbSkip())
		Enddo
		
		SET FILTER TO
		
		oGetDEq:aCols := aC
		oGetDEq:ForceRefresh()
		
	Else
		aC := {}
		aADD(aC, {Space(2), Space(5), Space(60), .F.})
		oGetDEq:aCols := aC
		oGetDEq:ForceRefresh()
	Endif
	
	ZZE->(dbCloseArea())
	
Else
	
	oSay:SetText( "" )
	oSay:CtrlRefresh()
	aADD(aC, {Space(2), Space(5), Space(60), .F.})
	oGetDEq:aCols := aC
	oGetDEq:ForceRefresh()
	Alert("Equipe não encontrada!")
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _CopyEquip ³ Autor ³ Felipe S. Raota            ³ Data ³ 15/08/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Copia cidades de uma equipe para outra.                           ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB108PCP                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _CopyEquip(cEquip, aC, cEquip2)

If Empty(cEquip) .OR. Empty(cEquip2)
	Alert("Preencha os campos de Equipe corretamente.")
	Return
Endif

dbSelectArea("AA1")
AA1->(dbSetOrder(1))

If !AA1->(MsSeek( xFilial("AA1") + cEquip2 ))
	Alert("Equipe informada para cópia não existe.")
	Return
Endif

dbSelectArea("ZZE")
ZZE->(dbSetOrder(1))

If ZZE->(MsSeek( xFilial("ZZE") + cEquip2 ))

	If MsgYesNo("A equipe: " + Alltrim(cEquip2) + " já possui cidades vinculadas. Deseja sobrepor as informações?")
			
		If ZZE->(MsSeek( xFilial("ZZE") + cEquip2 ))
			While ZZE->(!EoF()) .AND. xFilial("ZZE")+cEquip2 == ZZE->ZZE_FILIAL+ZZE->ZZE_EQUIPE
		
				RecLock("ZZE", .F.)
					dbDelete()
				MsUnLock()
				
				ZZE->(dbSkip())
			Enddo
		Endif
		
		For _x:=1 to len(aC)
			If !aC[_x,4]
				RecLock("ZZE", .T.)
					ZZE->ZZE_EQUIPE := cEquip2
					ZZE->ZZE_NOMEQU := fBuscaCPO("AA1", 1, xFilial("AA1") + cEquip2, "AA1_NOMTEC")
					ZZE->ZZE_EST 	:= aC[_x,1]
					ZZE->ZZE_CODMUN := aC[_x,2]
					ZZE->ZZE_NOMMUN := aC[_x,3]
				MsUnLock()
				
			Endif
		Next
	
	Endif

Else

	For _x:=1 to len(aC)
		If !aC[_x,4]
			RecLock("ZZE", .T.)
				ZZE->ZZE_EQUIPE := cEquip2
				ZZE->ZZE_NOMEQU := fBuscaCPO("AA1", 1, xFilial("AA1") + cEquip2, "AA1_NOMTEC")
				ZZE->ZZE_EST 	:= aC[_x,1]
				ZZE->ZZE_CODMUN := aC[_x,2]
				ZZE->ZZE_NOMMUN := aC[_x,3]
			MsUnLock()
		Endif
	Next

Endif

MsgInfo("Copiado com sucesso!")

Return