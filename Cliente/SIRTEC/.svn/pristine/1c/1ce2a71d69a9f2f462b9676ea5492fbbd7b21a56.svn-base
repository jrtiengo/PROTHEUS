#Include 'Totvs.ch'
#Include 'Topconn.ch'
#INCLUDE "FWBROWSE.CH"

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ FB103PPR ³ Autor ³ Felipe S. Raota             ³ Data ³ 14/05/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Unidade   ³ TRS              ³Contato ³ felipe.raota@totvs.com.br             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela de Consulta do Cálculo PPR.                                  ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Especifico para cliente Sirtec - Projeto PPR                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³  Data  ³ Manutencao Efetuada                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³  /  /  ³                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function FB103PPR()

Local oDlg
Local oLayer := FWLayer():New()
Local oSay1, oSay2, oSay3, oSay4
Local oTGet, oTGet2, oPane1, oPane2, oPane3
Local oTBut1, oTBut2, oTBut3, oTBut4, oTBut5, oTBut6

Local aSizeAut := MsAdvSize(.F.)

Local oFont14  := TFont():New( "Arial",,14,,.F.,,,,,.F. )
Local oFont15  := TFont():New( "Comic Sans",,15,,.F.,,,,,.F. )
Local oFont15N := TFont():New( "Comic Sans",,15,,.T.,,,,,.F. )
Local oFont16N := TFont():New( "Comic Sans",,16,,.T.,,,,,.F. )
Local oFont22N := TFont():New( "Comic Sans",,22,,.T.,,,,,.F. )

Private _cPerg := PADR("FB103PPR", 10, " ") //PADR("FB103PPR", LEN(SX1->X1_GRUPO), " ")

ValidPerg()
If !Pergunte(_cPerg,.T.)
	Return
Endif

Private _aMeses := {}
Private _aEstrut := {}
Private _aSelect := {}

Private _aTFolder := {}

Private _lFilOpen := .T.

Private _aObjects := {}

Private _cCodCalc := Space(6)
Private _cPeriodo := MV_PAR01
Private _cFilterZD  := ""
Private _cFilterZE  := ""

Private _oGD
Private _aHeadZ2  := {}
Private _aColsZ2  := {}

Private _nFold := 1 // Folder selecionado

Private _nPerc := 0

Private _aYesAlt  := {}
Private _aYesCmp  := {"ZD_FILMAT", "ZD_MAT", "ZD_UNIDADE", "ZD_NOME", "ZD_FUNCBC", "ZD_ENCARRE", "ZD_TOTDIAS", "ZD_FALTAS", "ZD_DIASTRB", "ZD_BC", "ZD_EQUIPE", "ZD_TOTPOS", "ZD_TOTNEG", "ZD_TOTAL", "ZD_PERALT"}

Private _aTipos   := {}
Private _cTipo    := "000001 - EQUIPE H"

_FilDados(.F.)

// Gera vetores usados nas divisões da tela
_GerVetor()

_aHeadZ2 := U_GeraHead("SZD",.T.,,_aYesCmp,.T.)

aADD( _aObjects, { aSizeAut[4], 035, .T., .T. } )
aADD( _aObjects, { aSizeAut[4], 162, .T., .T. } )
aADD( _aObjects, { aSizeAut[4], 014, .T., .T. } )

aInfo := { aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 3, 3 }
aPosObj := MsObjSize( aInfo, _aObjects, .T. )

dbSelectArea("SZD")
SZD->(dbSetOrder(1))

dbSelectArea("SZE")
SZE->(dbSetOrder(1))

DEFINE MSDIALOG oDlg TITLE "Consulta Cálculo PPR" From aSizeAut[7],00 To aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL
	
	// Inicializa o FWLayer com a janela que ele pertencera e se sera exibido o botão de fechar
	oLayer:Init(oDlg,.T.) //Cria as colunas do Layer
	
	oLayer:addCollumn('Col01',100,.F.)
	
	_aTam := {}
	
	_aTam := _GetTamRes()
	
	oLayer:addLine('Lin01',_aTam[1],.T.)
	oLayer:addLine('Lin02',_aTam[2],.F.)
	oLayer:addLine('Lin03',_aTam[3],.T.)
	
	// Adiciona Janelas
	oLayer:addWindow('Col01','C1_Win01','Filtros'    ,_aTam[1],.T.,.T.,{|| _MudaTam(@oPane1) },,   {|| /*Quando recebe foco*/ })
	oLayer:addWindow('Col01','C1_Win02','Cálculo PPR',_aTam[2],.T.,.F.,{|x| /*Clique na janela*/ },,{|| /*Quando recebe foco*/ })
	oLayer:addWindow('Col01','C1_Win03',''           ,_aTam[3],.F.,.T.,{|| /*Clique na janela*/ },,{|| /*Quando recebe foco*/ })
	
	oObjWin1 := oLayer:getWinPanel('Col01','C1_Win01')
	oObjWin2 := oLayer:getWinPanel('Col01','C1_Win02')
	oObjWin3 := oLayer:getWinPanel('Col01','C1_Win03')
	
	// Painel 1
	oPane1 := TPanel():New(aPosObj[1,1],aPosObj[1,2],"",oObjWin1,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,080),aPosObj[1,4],aPosObj[1,3]-aPosObj[1,1],.F.,.F.)
	
	oSay1 	:= TSay():New(003,002,{||"Grupo PPR:    "  },oPane1,,oFont15N,,,,.T.,CLR_WHITE,CLR_WHITE,200,10)
	//oTGet  := TGet():New(002,050,{|u| If(Pcount()>0,_cCodCalc:=u,_cCodCalc) },oPane1,050,008,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,{|| },.F.,.F.,"SZD",_cCodCalc,,,,)
	oCombo := TComboBox():New(002,045,{|u|if(PCount()>0,_cTipo:=u,_cTipo)},_aTipos,100,45,oPane1,,{|| _cFilterZD  := "SZD->ZD_CODCALC == '"+_cCodCalc+"' .AND. SZD->ZD_CODGRP == '"+Left(_cTipo,6)+"'" },,,,.T.,oFont14,,,{|| "" },,,,,'_cTipo')
	
	//oSay2 	:= TSay():New(018,020,{||"Período: "  },oPane1,,oFont15N,,,,.T.,CLR_WHITE,CLR_WHITE,200,10)
	//oTGet2 := TGet():New(017,050,{|u| If(Pcount()>0,_cPeriodo:=u,_cPeriodo) },oPane1,050,008,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,{|| },.F.,.F.,"",_cPeriodo,,,, )
	
	oTBut1 := TButton():New( 34, 008, "&Filtrar", oPane1,{|| _GerFilter() },38,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTBut2 := TButton():New( 34, 050, "&Buscar", oPane1,{|| _BuscaDad() },38,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	// Cria a Folder
	oTFolder := TFolder():New( 0,0,_aTFolder,,oObjWin2,,,,.T.,,aPosObj[2,4],aPosObj[2,3]/*-aPosObj[2,1]*/ ) // Deixo altura maior que a tela.
	oTFolder:bSetOption := {|z| _nFold := z }
	
	_nAltVar := (len(_aEstrut) - 1) * 14.5
	
	// Cria os componentes tPanel
	For _x:=1 to len(_aMeses)
	
		aADD(_aSelect, { _aMeses[_x,1], 1 })
		
		For _y:=1 to len(_aEstrut)
			
			If Val(_aMeses[_x,1]) <= 6
				_nDialog := Alltrim(Str(Val(_aMeses[_x,1])))
			Else
				_nDialog := Alltrim(Str(Val(_aMeses[_x,1])-6))
			Endif
			
			&('oPanel'+_aMeses[_x,1]+_aEstrut[_y,1]+' := TPanel():New(002,002,"",oTFolder:aDialogs['+_nDialog+'],,.F.,.F.,,'+Alltrim(Str(SetTransparentColor(CLR_BLUE ,030)))+',aPosObj[2,4],100,.F.,.F.)')
			
			&('_oGD'+_aMeses[_x,1]+_aEstrut[_y,1]+' := MsNewGetDados():New(000,001,'+Alltrim(Str(_aTam[6] - _nAltVar))+','+Alltrim(Str(aPosObj[2,4]-6))+','+Alltrim(Str(GD_UPDATE))+',"AllwaysTrue()","AllwaysTrue()",,_aYesAlt,,,,,, &("oPanel"+_aMeses[_x,1]+_aEstrut[_y,1]) ,_aHeadZ2,_aColsZ2)')
			
			&('_oGD'+_aMeses[_x,1]+_aEstrut[_y,1]+":oBrowse:bRClicked := {|o,x,y| _MenuPop(o, x, y, "+'_oGD'+_aMeses[_x,1]+_aEstrut[_y,1]+")}")
			
		Next
	Next
	
	// Cria componentes ToolBox e adiciona os painéis
	For _x:=1 to len(_aMeses)
		
		If Val(_aMeses[_x,1]) <= 6
			_nDialog := Alltrim(Str(Val(_aMeses[_x,1])))
		Else
			_nDialog := Alltrim(Str(Val(_aMeses[_x,1])-6))
		Endif
		
		&('oTB'+_aMeses[_x,1]+' := TToolBox():New(002,002,oTFolder:aDialogs['+_nDialog+'],aPosObj[2,4],'+Alltrim(Str(aPosObj[2,3]-aPosObj[2,1]-_aTam[4]))+')')
		
		_nPos := _x
		
		&('oTB'+_aMeses[_x,1]+':bChangeGrp := {|x| U__MudaSelec(x) }') 
		
		For _y:=1 to len(_aEstrut)
			&('oTb'+_aMeses[_x,1]+':AddGroup( oPanel'+_aMeses[_x,1]+_aEstrut[_y,1]+', "'+_aEstrut[_y,2]+'", )')
		Next
	Next
	
	// Painel 3
	oPane3 := TPanel():New(aPosObj[3,1],aPosObj[3,2],"",oObjWin3,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,080),aPosObj[3,4],aPosObj[3,3]-aPosObj[3,1]+100,.F.,.F.)
	
	//oTBu3 	:= TButton():New( 02, 010, "&Gravar", oObjWin3,{|| Alert(_nFold) },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	//oTBu4 	:= TButton():New( 02, 055, "&Limpar", oObjWin3,{|| U_ShowArray(_aSelect)},40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	oTBu5 	:= TButton():New( 02, 200, "&Valores Finais", oObjWin3,{|| _ConsTot() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTBu6 	:= TButton():New( 02, 250, "&Modificar Valores Totais", oObjWin3,{|| _AltVal() },70,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	oTBu8 	:= TButton():New( 02, 330, "&Fechar Período", oObjWin3,{|| MsAguarde({|| _FechaPer() },'Efetuando fechamento de período...') },50,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	oTBu9 	:= TButton():New( 02, 390, "&Abrir Período", oObjWin3,{|| MsAguarde({|| _AbrePer() },'Efetuando reabertura de período...') },50,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	oTBuA 	:= TButton():New( 02, 450, "&Pagamento", oObjWin3,{|| _GerFolha() },50,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	oTBu7 	:= TButton():New( 02, aPosObj[3,4] - 50, "&Fechar", oObjWin3,{|| oDlg:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

ACTIVATE MSDIALOG oDlg CENTERED ON INIT _BuscaDad()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _MudaTam   ³ Autor ³ Felipe S. Raota            ³ Data ³ 14/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Aumenta tamanho do ToolBox, ao minimizar filtros.                 ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB103PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _MudaTam(oPane1)

Local aTam := _GetTamRes()
Private oPn := oPane1

If _lFilOpen
	
	For _x:=1 to len(_aMeses)
		&('oTb'+_aMeses[_x,1]+':nHeight += ' + Alltrim(Str(aTam[5])))
		&('oTb'+_aMeses[_x,1]+':Refresh()')
	Next
	
Else
	
	For _x:=1 to len(_aMeses)
		&('oTb'+_aMeses[_x,1]+':nHeight -= ' + Alltrim(Str(aTam[5])))
		&('oTb'+_aMeses[_x,1]+':Refresh()')
	Next
	
Endif

// Altera tamenhos das Grids
_AltTamGrd() 

_lFilOpen := !_lFilOpen

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _AltTamGrd ³ Autor ³ Felipe S. Raota            ³ Data ³ 20/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Altera altura do componente MsNewGetDados.                        ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB103PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _AltTamGrd()

Local aTam := _GetTamRes()

For _x:=1 to len(_aMeses)
	For _y:=1 to len(_aEstrut)
		
		If _lFilOpen
			&('_oGD'+_aMeses[_x,1]+_aEstrut[_y,1]+':oBrowse:nHeight := _oGD'+_aMeses[_x,1]+_aEstrut[_y,1]+':oBrowse:nHeight + ' + Alltrim(Str(aTam[7])))
			&('_oGD'+_aMeses[_x,1]+_aEstrut[_y,1]+':ForceRefresh()')
		
		Else
			&('_oGD'+_aMeses[_x,1]+_aEstrut[_y,1]+':oBrowse:nHeight := _oGD'+_aMeses[_x,1]+_aEstrut[_y,1]+':oBrowse:nHeight - ' + Alltrim(Str(aTam[7])))
			&('_oGD'+_aMeses[_x,1]+_aEstrut[_y,1]+':ForceRefresh()')
		Endif
		
	Next
Next

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _BuscaDad  ³ Autor ³ Felipe S. Raota            ³ Data ³ 20/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Busca informações conforme campos e perguntas.                    ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB103PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _BuscaDad()

Local aC := {}

// Efetua filtro dos dados
_FilDados(.F.)

// Gera novos aCols para as Grids
MsAguarde({|| _RecrTela() },'Carregando informações do período...')

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _FilDados  ³ Autor ³ Felipe S. Raota            ³ Data ³ 21/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Filtra as tabelas de cálculo para posterior uso.                  ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB103PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _FilDados(lIni)

Local lAchou := .F.
Local cQuery := ''

Local cCalc := ''

// Busco último cálculo
If lIni
	
	cQuery := " SELECT TOP 1 TTT.ZD_CODCALC "
	cQuery += " FROM ( "
	cQuery += " 	SELECT DISTINCT SZD.ZD_PERIODO, SZD.ZD_CODCALC "
	cQuery += " 	FROM "+RetSqlName("SZD")+" SZD WITH (NOLOCK) "
	cQuery += " 	WHERE " + RetSqlCond("SZD")
	cQuery += " ) TTT "
	cQuery += " ORDER BY RIGHT(TTT.ZD_PERIODO,4) DESC , LEFT(TTT.ZD_PERIODO,2) DESC "
	
	dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TRB", .F., .T.)
	
	If !TRB->(EoF())
		cCalc := TRB->ZD_CODCALC
		lAchou := .T.
	Endif
	
	TRB->(dbCloseArea())
	
Else
	
	dbSelectArea("SZD")
	SET FILTER TO
	
	dbSelectArea("SZE")
	SET FILTER TO
	
	SZD->(dbGoTop())
	SZE->(dbGoTop())
	
	SZD->(dbSetOrder(4))
	
	If SZD->(MsSeek( xFilial("SZD") + _cPeriodo )) 
		lAchou := .T.
		cCalc := SZD->ZD_CODCALC
	Endif
	
Endif

If !lAchou
	MsgAlert("Cálculo não encontrado com as condições informadas!")
	Return
Endif

_cCodCalc := cCalc
_cPeriodo := SZD->ZD_PERIODO

// Garante que irá manter o cálculo informado no campo
If Empty(_cFilterZD)
	_cFilterZD  := "SZD->ZD_CODCALC == '"+_cCodCalc+"' .AND. SZD->ZD_CODGRP == '"+Left(_cTipo,6)+"'"
Endif
If Empty(_cFilterZE)
	_cFilterZE  := "SZE->ZE_CODCALC == '"+_cCodCalc+"' "
Endif

dbSelectArea("SZD")
SET FILTER TO &(_cFilterZD)

dbSelectArea("SZE")
SET FILTER TO &(_cFilterZE)

// Devo ir para o primeiro registro pois o SET FILTER TO varre toda a tabela
SZD->(dbGoTop())
SZE->(dbGoTop())

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GerFilter ³ Autor ³ Felipe S. Raota            ³ Data ³ 21/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Gera expressão utilizada para filtro nas tabelas de cálculo.      ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB103PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GerFilter()

Local aRet := {}
Local aPergs := {}

aADD(aPergs, {7, "Filtro Cálculo",       "SZD","SZD->ZD_CODCALC == '"+_cCodCalc+"'",})
aADD(aPergs, {7, "Filtro Comp. Cálculo", "SZE","SZE->ZE_CODCALC == '"+_cCodCalc+"'",})

If ParamBox(aPergs, "Cálculo PPR", aRet)
	_cFilterZD := Alltrim(aRet[1])
	_cFilterZE := Alltrim(aRet[2])
	
	// Garante que irá manter o cálculo informado no campo
	If Empty(_cFilterZD)
		_cFilterZD  := "SZD->ZD_CODCALC == '"+_cCodCalc+"' .AND. SZD->ZD_CODGRP == '"+Left(_cTipo,6)+"'"
	Endif
	If Empty(_cFilterZE)
		_cFilterZE  := "SZE->ZE_CODCALC == '"+_cCodCalc+"'"
	Endif
	
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GerVetor  ³ Autor ³ Felipe S. Raota            ³ Data ³ 21/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Gera vetores utilizados nas divisões da tela.                     ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB103PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GerVetor()

Local cQuery := ''
Local nCont := 0
Local cQry := ""
Local aPerFech := {}

If Select("FECH") > 0
	FECH->(dbCloseArea())
Endif

cQry := " SELECT DISTINCT SZD.ZD_MESCALC, " 
cQry += " ( SELECT COUNT(*) "
cQry += " 	FROM "+RetSqlName("SZD")+" AUX "
cQry += " 	WHERE AUX.D_E_L_E_T_ = ' ' "
cQry += "     AND AUX.ZD_FILIAL = '"+xFilial("SZD")+"' "
cQry += "     AND AUX.ZD_CODCALC = SZD.ZD_CODCALC "
cQry += "     AND AUX.ZD_BLQ = 'F' "
cQry += "     AND AUX.ZD_MESCALC = SZD.ZD_MESCALC "
cQry += " ) as QTDFECH "
cQry += " FROM "+RetSqlName("SZD")+" SZD "
cQry += " WHERE " + RetSqlCond("SZD")
cQry += "   AND SZD.ZD_CODCALC = '"+_cCodCalc+"' "
cQry += " ORDER BY SZD.ZD_MESCALC "

cQry := ChangeQuery(cQry)
dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), "FECH", .F., .T.)

If !FECH->(EoF())
	
	While !FECH->(EoF())
		
		_cFech := ""
		
		If FECH->QTDFECH > 0
			_cFech := "F"
		Else
			_cFech := "A"
		Endif
		
		aADD( aPerFech, {FECH->ZD_MESCALC, _cFech} )
		
		FECH->(dbSkip())
	Enddo
	
Endif

_aMeses := {}
_aEstrut := {}

If Left(SZD->ZD_PERIODO,1) == "1"
	aADD(_aMeses, {'01', 'Janeiro'})
	aADD(_aMeses, {'02', 'Fevereiro'})
	aADD(_aMeses, {'03', 'Março'})
	aADD(_aMeses, {'04', 'Abril'})
	aADD(_aMeses, {'05', 'Maio'})
	aADD(_aMeses, {'06', 'Junho'})
	
	_aTFolder := { '01 - Janeiro'+_retFech(aPerFech,'01'), '02 - Fevereiro'+_retFech(aPerFech,'02'), '03 - Março'+_retFech(aPerFech,'03'), '04 - Abril'+_retFech(aPerFech,'04'), '05 - Maio'+_retFech(aPerFech,'05'), '06 - Junho'+_retFech(aPerFech,'06') }
	
Else
	aADD(_aMeses, {'07', 'Julho'})
	aADD(_aMeses, {'08', 'Agosto'})
	aADD(_aMeses, {'09', 'Setembro'})
	aADD(_aMeses, {'10', 'Outubro'})
	aADD(_aMeses, {'11', 'Novembro'})
	aADD(_aMeses, {'12', 'Dezembro'})
	
	_aTFolder := { '07 - Julho'+_retFech(aPerFech,'07'), '08 - Agosto'+_retFech(aPerFech,'08'), '09 - Setembro'+_retFech(aPerFech,'09'), '10 - Outubro'+_retFech(aPerFech,'10'), '11 - Novembro'+_retFech(aPerFech,'11'), '12 - Dezembro'+_retFech(aPerFech,'12') }
	
Endif

dbSelectArea("SZ4")
SZ4->(dbSetOrder(1))

// Adiciono um grupo em branco para os registros com falha na tabela...

While SZ4->(!EoF())
	nCont++
	//If SZ4->Z4_COD == Left(_cTipo, 6)
	//	aADD(_aEstrut, {Alltrim(Str(nCont)), SZ4->Z4_DESC, SZ4->Z4_COD})
	//Endif
	aADD(_aTipos, Alltrim(SZ4->Z4_COD) + " - " + SZ4->Z4_DESC)
	SZ4->(dbSkip())
Enddo

//nCont++
aADD(_aEstrut, {Alltrim(Str(1)), "Grupos PPR", "999999"})
//aADD(_aEstrut, {Alltrim(Str(2)), 'Grupo não encontrado.', Space(6)})

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _RetFech   ³ Autor ³ Felipe S. Raota            ³ Data ³ 24/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Identifica abas se estão com mês fechado ou não.                  ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB103PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _retFech(aPerFech, cMes)

Local cChar := ""
Local nPos := aScan(aPerFech,{|x| x[1] == cMes })

If nPos <> 0
	cChar := "("+aPerFech[nPos,2]+")"
Endif

Return cChar

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _RecrTela  ³ Autor ³ Felipe S. Raota            ³ Data ³ 21/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Gera novos aCols para as Grids da tela.                           ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB103PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _RecrTela()

Local nPosAux := 0
Local nPosEst := 0
Local aCposAux := {}

Local nGrpTBox := 0

Private aMaster := {} //{ MES, GRUPO, {aCols}}

_aColsZ2 := {}

SZD->(dbGoTop())

While !SZD->(EoF())
	
	nGrpTBox := 0
	aCposAux := {}
	
	If len(aMaster) > 0
		//nPosAux := aScan(aMaster,{|x| x[1] == SZD->ZD_MESCALC .AND. x[3] == SZD->ZD_CODGRP })
		nPosAux := aScan(aMaster,{|x| x[1] == SZD->ZD_MESCALC .AND. x[3] == "999999" })
	Else
		nPosAux := 0
	Endif
	
	// Varre aHead e gera aCols
	For _x:=1 to len(_aHeadZ2)
		
		If Alltrim(_aHeadZ2[_x,2]) == "ZD_TOTAL"
			aADD(aCposAux, &("SZD->"+_aHeadZ2[_x,2]) + (&("SZD->"+_aHeadZ2[_x,2]) * (SZD->ZD_PERALT / 100)) )
		Else
			aADD(aCposAux, &("SZD->"+_aHeadZ2[_x,2]))
		Endif
		
	Next
	// Coluna de deletado
	aADD(aCposAux, .F.)
	
	If nPosAux <> 0
				
		aADD(aMaster[nPosAux, 4], aCposAux)
	Else
		
		//nPosEst := aScan(_aEstrut,{|x| x[3] == SZD->ZD_CODGRP })
		nPosEst := aScan(_aEstrut,{|x| x[3] == "999999" })
		
		If nPosEst <> 0
			nGrpTBox := _aEstrut[nPosEst, 1]
			//aADD(aMaster, {SZD->ZD_MESCALC, nGrpTBox, SZD->ZD_CODGRP, {aCposAux}})
			aADD(aMaster, {SZD->ZD_MESCALC, nGrpTBox, "999999", {aCposAux}})
		Endif
		
	Endif
	
	SZD->(dbSkip())
Enddo

For _x:=1 to len(_aMeses)
	For _y:=1 to len(_aEstrut)
		&('_oGD'+_aMeses[_x,1]+_aEstrut[_y,1]+':aCols := {}')
		&('_oGD'+_aMeses[_x,1]+_aEstrut[_y,1]+':ForceRefresh()')
	Next
Next

For _x:=1 to len(aMaster)
	
	&('_oGD'+aMaster[_x,1]+aMaster[_x,2]+':aCols := aMaster[_x,4]')
	&('_oGD'+aMaster[_x,1]+aMaster[_x,2]+':ForceRefresh()')
	
Next

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _MudaSelec ³ Autor ³ Felipe S. Raota            ³ Data ³ 22/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Altera vetor _aSelect, para informar o ToolBox aberto em cada     ³±±
±±³          ³ folder/mês.                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB103PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

User Function _MudaSelec(nSel)

_aSelect[_nFold, 2] := nSel

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _MenuPop   ³ Autor ³ Felipe S. Raota            ³ Data ³ 22/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Mostra PopUp, com diversas opções.                                ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB103PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _MenuPop(oObjeto, x, y, oGet)

Local nLinha  := oGet:oBrowse:nAt
Local oMenu   := NIL
Local cMat    := oGet:aCols[nLinha, GdFieldPos("ZD_MAT", oGet:aHeader)]

Menu oMenu PopUp
	MenuItem oMenuItem1 Prompt "Indicadores   " Action _TelaInd(cMat, _aMeses[_nFold, 1])
	MenuItem oMenuItem1 Prompt "Log Cálculo   " Action _TelaLog(cMat, _aMeses[_nFold, 1])
EndMenu

oMenu:Activate (x, y, oObjeto)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _TelaInd   ³ Autor ³ Felipe S. Raota            ³ Data ³ 22/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Apresenta tela com os indicadores do funcionário selecionado.     ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB103PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _TelaInd(cMat, cMes)

Local oDlgInd, oSay1, oSay2, oTGet, oPane1, oPane2, oPane3, oTButton1, oTButton2, oTButton3
Local nOpc     := 0
Local aColsZE  := {}
Local aYesAlt  := {}
Local aYesCmp  := {"ZE_CODIND", "ZE_QTDIND", "ZE_PERMETA", "ZE_PREMIO", "ZE_VALPREM", "ZE_OK"}
Local aSizeAut := MsAdvSize() 

Local oGetDInd

Private aHeadZE := {}

Private _aPosObj := {{002,002,499,243},; // TPanel 1
						{245,002,499,014},; // TPanel 2
						{002,002,497,239}}  // MsNewGetDados

aHeadZE := U_GeraHead("SZE",.T.,,aYesCmp,.T.)

If SZE->(MsSeek( xFilial("SZE") + _cCodCalc + cMat + cMes ))

	While SZE->(!EoF()) .AND. xFilial("SZE") + _cCodCalc + cMat + cMes == SZE->ZE_FILIAL + SZE->ZE_CODCALC + SZE->ZE_MAT + SZE->ZE_MESCALC
	
		aADD( aColsZE, {SZE->ZE_CODIND, SZE->ZE_QTDIND, SZE->ZE_PERMETA, SZE->ZE_PREMIO, SZE->ZE_VALPREM, SZE->ZE_OK, .F.} )
		
		SZE->(dbSkip())
	Enddo

Endif

DEFINE MSDIALOG oDlgInd TITLE "Indicadores do Cálculo" From 00,00 To 520,1000 OF oMainWnd PIXEL
	
	// Painel 1
	oPane1  := TPanel():New(_aPosObj[1,1],_aPosObj[1,2],"",oDlgInd,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,030),_aPosObj[1,3],_aPosObj[1,4],.F.,.F.)
	
	oGetDad := MsNewGetDados():New(_aPosObj[3,1],_aPosObj[3,2],_aPosObj[3,4],_aPosObj[3,3],GD_UPDATE+GD_INSERT+GD_DELETE,"AllwaysTrue()",/*Tok*/,,aYesAlt,/*freeze*/,,/*fieldok*/,/*superdel*/,,oPane1,aHeadZE,aColsZE)
	oGetDad:Disable()
	
	// Painel 2
	oPane2 	:= TPanel():New(_aPosObj[2,1],_aPosObj[2,2],"",oDlgInd,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,080),_aPosObj[2,3],_aPosObj[2,4],.F.,.F.)
	
	oTButton3 	:= TButton():New( 02, 450, "Sair", oPane2,{|| oDlgInd:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

ACTIVATE MSDIALOG oDlgInd CENTERED

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _TelaLog   ³ Autor ³ Felipe S. Raota            ³ Data ³ 24/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Apresenta tela com o log do cálculo.                              ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB103PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _TelaLog(cMat, cMes)

Local oDlgLog, oSay1, oSay2, oTGet, oPane1, oPane2, oPane3, oTButton1, oTButton2, oTButton3
Local nOpc     := 0
Local aColSZQ  := {}
Local aYesAlt  := {"ZQ_LOG"}
Local aYesCmp  := {"ZQ_DATA", "ZQ_HORA", "ZQ_USER", "ZQ_CODGRP", "ZQ_MAT", "ZQ_EQUIPE", "ZQ_CODIND", "ZQ_LOG"}
Local aSizeAut := MsAdvSize()

Local oGetDInd

Private aHeadZF := {}

Private _aPosObj := {{002,002,499,243},; // TPanel 1
						{245,002,499,014},; // TPanel 2
						{002,002,497,239}}  // MsNewGetDados

aHeadZF := U_GeraHead("SZQ",.T.,,aYesCmp,.T.)

dbSelectArea("SZQ")
SZQ->(dbSetOrder(1))

If SZQ->(MsSeek( xFilial("SZE") + _cCodCalc + cMes + cMat ))

	While SZQ->(!EoF()) .AND. xFilial("SZE") + _cCodCalc + cMes + cMat == SZQ->ZQ_FILIAL + SZQ->ZQ_CODCALC + SZQ->ZQ_MES + SZQ->ZQ_MAT
	
		aADD( aColSZQ, {SZQ->ZQ_DATA, SZQ->ZQ_HORA, SZQ->ZQ_USER, SZQ->ZQ_CODGRP, SZQ->ZQ_MAT, SZQ->ZQ_EQUIPE, SZQ->ZQ_CODIND, SZQ->ZQ_LOG, .F.} )
		
		SZQ->(dbSkip())
	Enddo

Endif

DEFINE MSDIALOG oDlgLog TITLE "Log do Cálculo" From 00,00 To 520,1000 OF oMainWnd PIXEL
	
	// Painel 1
	oPane1  := TPanel():New(_aPosObj[1,1],_aPosObj[1,2],"",oDlgLog,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,030),_aPosObj[1,3],_aPosObj[1,4],.F.,.F.)
	
	oGetDad := MsNewGetDados():New(_aPosObj[3,1],_aPosObj[3,2],_aPosObj[3,4],_aPosObj[3,3],GD_UPDATE,"AllwaysTrue()",/*Tok*/,,aYesAlt,/*freeze*/,,/*fieldok*/,/*superdel*/,,oPane1,aHeadZF,aColSZQ)
	//oGetDad:Disable()
	
	// Painel 2
	oPane2 	:= TPanel():New(_aPosObj[2,1],_aPosObj[2,2],"",oDlgLog,,.F.,.F.,,SetTransparentColor(CLR_BLUE ,080),_aPosObj[2,3],_aPosObj[2,4],.F.,.F.)
	
	oTButton3 	:= TButton():New( 02, 450, "Sair", oPane2,{|| oDlgLog:End() },40,10,,,.F.,.T.,.F.,,.F.,,,.F. )

ACTIVATE MSDIALOG oDlgLog CENTERED

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _ConsTot   ³ Autor ³ Felipe S. Raota            ³ Data ³ 24/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Apresenta tela com os totais por Grupo PPR                        ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB103PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _ConsTot()

Local oDlgCons
Local aTot := {}
Local aItens := {}

Local nPosAux := 0
Local nPosTot := 0

Local nTotGeral := 0

Private aAux := {}
Private aHeadAux := {}

// Cria Fonte para visualização
oFont := TFont():New('Courier new',,-12,.T.)

DEFINE MSDIALOG oDlgCons FROM 5, 5 TO 300, 610 PIXEL TITLE OemToAnsi("Totalizador por Grupo PPR")

	For _x:=1 to len(_aMeses)
		For _y:=1 to len(_aEstrut)
			
			&('aAux := _oGD'+_aMeses[_x,1]+_aEstrut[_y,1]+':aCols')
			&('aHeadAux := _oGD'+_aMeses[_x,1]+_aEstrut[_y,1]+':aHeader')
			
			For _z:=1 to len(aAux)
				
				nPosAux := aScan(aTot,{|x| x[1] == _aMeses[_x,1] .AND. x[2] == _aEstrut[_y,3] })
				
				nPosTot := GdFieldPos("ZD_TOTAL", aHeadAux)
				
				If nPosAux <> 0
					aTot[nPosAux, 4] += aAux[_z, nPosTot]
				Else
					aADD(aTot, { _aMeses[_x,1], _aEstrut[_y,3], Alltrim(_aEstrut[_y,2]), aAux[_z, nPosTot] })
				Endif
				
				nTotGeral += aAux[_z, nPosTot]
				
			Next
			
		Next
	Next
	
	DEFINE FONT oFont2 NAME "Mono AS" SIZE 6,15
	
	@ 012, 005 LISTBOX oList FIELDS HEADER "Mês Cálculo","Grupo PPR","Descrição","Total" SIZE 294, 120 OF oDlgCons PIXEL
	oList:SetArray(aTot)
	oList:bLine:= {|| {aTot[oList:nAt,1],aTot[oList:nAt,2],aTot[oList:nAt,3],aTot[oList:nAt,4]}}
	oList:oFont := oFont2
	oList:SetFocus()
	
	DEFINE SBUTTON FROM 135, 270 TYPE 1 ACTION (oDlgCons:End()) ENABLE
	
ACTIVATE MSDIALOG oDlgCons CENTERED

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _CalcTotal ³ Autor ³ Felipe S. Raota            ³ Data ³ 27/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Retorna total do cálculo PPR.                                     ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB103PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _CalcTotal()

Local nPosTot := 0
Local nValTot := 0

Private aAux := {}
Private aHeadAux := {}

For _x:=1 to len(_aMeses)
	For _y:=1 to len(_aEstrut)
		
		&('aAux := _oGD'+_aMeses[_x,1]+_aEstrut[_y,1]+':aCols')
		&('aHeadAux := _oGD'+_aMeses[_x,1]+_aEstrut[_y,1]+':aHeader')
		
		For _z:=1 to len(aAux)
			
			nPosTot := GdFieldPos("ZD_TOTAL", aHeadAux)
			nValTot += aAux[_z, nPosTot]
			
		Next
		
	Next
Next

Return nValTot

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _AltVal    ³ Autor ³ Felipe S. Raota            ³ Data ³ 27/05/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Altera valores totais, somente com senha.                         ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB103PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _AltVal()

Local lRet := .T.
Local oDlgTot, oSay, oSay2, oTGet

Local lGrv := .F.

Local cUsrSen := Space(25)
Local cUser   := Space(25)
Local cCodigo := ""

Local nTot := 0
Local nPosTot := 0
Local nPosAlt := 0

Local oFont15N := TFont():New( "Comic Sans",,15,,.T.,,,,,.F. )

lRet := .F.
If U__ValidPass(@cUsrSen,@cUser)
	
	// Posiciona no usuario digitado - Na P11 nao pode mais procurar somente pela senha
	PswOrder(2)
	If PswSeek(cUser)
		If PswName(cUsrSen)
			
			cCodigo := PswRet(1)[1][1]
			
			If !(cCodigo $ AllTrim(GetMV("MV_USUAPPR")))
				MsgStop("Usuário não autorizado à alterar valores do PPR","Bloqueio Sirtec - PPR")
				lRet := .F.
			Else
				lRet := .T.
			Endif
		Else
			HELP("   ",1,"INVSENHA")
			lRet := .F.
		Endif
	Else
		HELP("   ",1,"USR_EXIST")
		lRet := .F.
	Endif
Endif

If lRet
	
	oFont := TFont():New('Courier New',,-12,.T.)
	
	nTot := _CalcTotal()
	
	DEFINE MSDIALOG oDlgTot FROM 5, 5 TO 300, 410 PIXEL TITLE OemToAnsi("Alteração de Valores Totais")
	
	oSay := TSay():New(005,005,{|| "Valor Atual:" + " R$ " + Transform(nTot,"@E 999,999,999.99")},oDlgTot,,oFont,,,,.T.,CLR_BLUE,CLR_GREEN,200,20)
	
	oSay1 := TSay():New(020,005,{||"% de alteração: "  },oDlgTot,,oFont15N,,,,.T.,CLR_RED,CLR_BLACK,200,10)
	
	oSay2 := TSay():New(045,005,{|| " Novo Valor:" + " R$ " + Transform(nTot + (nTot * (_nPerc/100)),"@E 999,999,999.99")},oDlgTot,,oFont,,,,.T.,CLR_BLUE,CLR_GREEN,200,20)
	
	oTGet2 := TGet():New(030,005,{|u| If(Pcount()>0,( _nPerc:=u, _SetText(@oSay2, nTot, _nPerc) ),_nPerc)},oDlgTot,050,008,"@e 999.99",{|| },0,,,.F.,,.T.,,.F.,,.F.,.F.,{|| },.F.,.F.,,"_nPerc",,,, )
	
	DEFINE SBUTTON FROM 135, 145 TYPE 1 ACTION (lGrv := .T., oDlgTot:End()) ENABLE
	DEFINE SBUTTON FROM 135, 175 TYPE 2 ACTION (oDlgTot:End()) ENABLE
	
	ACTIVATE MSDIALOG oDlgTot CENTERED
	
Endif

If lGrv
	
	If MsgYesNo("Deseja aplicar o percentual do valor para todos os funcionários?")
		
		For _y:=1 to len(_aEstrut)
			
			&('aAux := _oGD'+_aMeses[_nFold,1]+_aEstrut[_y,1]+':aCols')
			&('aHeadAux := _oGD'+_aMeses[_nFold,1]+_aEstrut[_y,1]+':aHeader')
			
			For _z:=1 to len(aAux)
				
				nPosTot := GdFieldPos("ZD_TOTAL", aHeadAux)
				nPosAlt := GdFieldPos("ZD_PERALT", aHeadAux)
				
				nPosPos := GdFieldPos("ZD_TOTPOS", aHeadAux)
				nPosNeg := GdFieldPos("ZD_TOTNEG", aHeadAux)
				
				If _nPerc <> 0
					aAux[_z, nPosTot] := aAux[_z, nPosTot] + (aAux[_z, nPosTot] * (_nPerc / 100))
					aAux[_z, nPosAlt] := _nPerc
				Else
					aAux[_z, nPosTot] := aAux[_z, nPosPos] - aAux[_z, nPosNeg]
					aAux[_z, nPosAlt] := _nPerc
				Endif
				
			Next
			
		Next
		
		TcSQLExec("UPDATE "+RetSqlName("SZD")+" SET ZD_PERALT = "+Alltrim(Str(_nPerc))+" WHERE ZD_CODCALC = '"+ _cCodCalc +"'")
		
	Endif

Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _FechaPer  ³ Autor ³ Felipe S. Raota            ³ Data ³ 24/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Fecha péríodo calculado do PPR.                                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB103PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _FechaPer()

Local aM := {}
Local cMes := ""
Local nMes := 0
Local cPeri := ""

aADD(aM, {'01', 'Janeiro'})
aADD(aM, {'02', 'Fevereiro'})
aADD(aM, {'03', 'Março'})
aADD(aM, {'04', 'Abril'})
aADD(aM, {'05', 'Maio'})
aADD(aM, {'06', 'Junho'})
aADD(aM, {'07', 'Julho'})
aADD(aM, {'08', 'Agosto'})
aADD(aM, {'09', 'Setembro'})
aADD(aM, {'10', 'Outubro'})
aADD(aM, {'11', 'Novembro'})
aADD(aM, {'12', 'Dezembro'})

dbSelectArea("SZD")
SZD->(dbSetOrder(1))

dbSelectArea("SZ4")
SZ4->(dbSetOrder(1))

nMes := aScan(aM,{|x| x[1] == StrZero(_nFold,2) })

If nMes <> 0
	cMes := aM[nMes,2]
Endif

If SZD->(MsSeek( xFilial("SZD") + _cCodCalc ))
	
	If MsgYesNo("Deseja fechar o mês: " + StrZero(_nFold,2) + " - " + cMes)
		
		cPeri := SZD->ZD_PERIODO
		
		If SZD->(MsSeek( xFilial("SZD") + _cCodCalc + cPeri + StrZero(_nFold,2) ))
			
			While !SZD->(EoF()) .AND. xFilial("SZD") + _cCodCalc + cPeri + StrZero(_nFold,2) == SZD->ZD_FILIAL + SZD->ZD_CODCALC + SZD->ZD_PERIODO + SZD->ZD_MESCALC
				
				If SZ4->(MsSeek( xFilial("SZ4") + SZD->ZD_CODGRP )) .AND. SZ4->Z4_RECALC <> "S"
					
					RecLock("SZD", .F.)
						SZD->ZD_BLQ := "F"
					MsUnLock()
					
					TcSQLExec("UPDATE "+RetSqlName("SZE")+" SET ZE_BLQ = 'F' WHERE ZE_CODCALC = '"+SZD->ZD_CODCALC+"' AND ZE_MESCALC = '"+SZD->ZD_MESCALC +"' AND ZE_MAT = '"+SZD->ZD_MAT +"' ")
					
				Endif
				
				SZD->(dbSkip())
			Enddo
			
		Endif
	
		MsgInfo("Período fechado com sucesso!")
		
	Endif
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _AbrePer   ³ Autor ³ Felipe S. Raota            ³ Data ³ 24/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Reabre período PPR.                                               ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB103PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _AbrePer()

Local aM := {}
Local cMes := ""
Local nMes := 0
Local cPeri := ""

aADD(aM, {'01', 'Janeiro'})
aADD(aM, {'02', 'Fevereiro'})
aADD(aM, {'03', 'Março'})
aADD(aM, {'04', 'Abril'})
aADD(aM, {'05', 'Maio'})
aADD(aM, {'06', 'Junho'})
aADD(aM, {'07', 'Julho'})
aADD(aM, {'08', 'Agosto'})
aADD(aM, {'09', 'Setembro'})
aADD(aM, {'10', 'Outubro'})
aADD(aM, {'11', 'Novembro'})
aADD(aM, {'12', 'Dezembro'})

dbSelectArea("SZD")
SZD->(dbSetOrder(1))

nMes := aScan(aM,{|x| x[1] == StrZero(_nFold,2) })

If nMes <> 0
	cMes := aM[nMes,2]
Endif

If SZD->(MsSeek( xFilial("SZD") + _cCodCalc ))
	
	If MsgYesNo("Deseja reabrir o mês: " + StrZero(_nFold,2) + " - " + cMes) 
		
		cPeri := SZD->ZD_PERIODO
		
		If SZD->(MsSeek( xFilial("SZD") + _cCodCalc + cPeri + StrZero(_nFold,2) ))
			
			While !SZD->(EoF()) .AND. xFilial("SZD") + _cCodCalc + cPeri + StrZero(_nFold,2) == SZD->ZD_FILIAL + SZD->ZD_CODCALC + SZD->ZD_PERIODO + SZD->ZD_MESCALC
				
				RecLock("SZD", .F.)
					SZD->ZD_BLQ := "A"
				MsUnLock()
				
				TcSQLExec("UPDATE "+RetSqlName("SZE")+" SET ZE_BLQ = 'A' WHERE ZE_CODCALC = '"+SZD->ZD_CODCALC+"' AND ZE_MESCALC = '"+SZD->ZD_MESCALC +"' AND ZE_MAT = '"+SZD->ZD_MAT +"' ")
				
				SZD->(dbSkip())
			Enddo
			
		Endif
		
		MsgInfo("Período reaberto com sucesso!")
		
	Endif
Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GerFolha  ³ Autor ³ Felipe S. Raota            ³ Data ³ 24/07/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Gera verba 178 na folha com o total do período.                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB103PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GerFolha()

dbSelectArea("SZD")
SZD->(dbSetOrder(1))

// Verificar se o período está fechado...
U_FB107PPR(_cCodCalc)

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³_SetText   ³ Autor ³ Felipe S. Raota            ³ Data ³ 27/05/13  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Altera texto do novo valor.                                       ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB103PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _SetText(oS, nT, nP)

oS:SetText( " Novo Valor:" + " R$ " + Transform(nT + (nT * (nP/100)),"@E 999,999,999.99") ) 
oS:CtrlRefresh()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³_GetTamRes ³ Autor ³ Felipe S. Raota            ³ Data ³ 11/06/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Verifica tamanho correto para os componentes, conforme a          ³±±
±±³          ³ resolução da tela.                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB103PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GetTamRes()

Local aRet := {}
Local nAlt :=	oMainWnd:nClientHeight 
/*
 1 - Percentual Layer 1
 2 - Percentual Layer 2
 3 - Percentual Layer 3
 4 - Valor a diminuir da altura do ToolBox, quando Layer 1 Maximizada 
 5 - Valor a diminuir da altura do ToolBox, quando Layer 1 Minimizada
 6 - Altura máxima da GRID quando tem 2 linhas.
*/

//MsgInfo(nAlt)

Do Case
	
	Case nAlt == 591 .OR. nAlt == 604 .OR. nAlt == 598
		aRet := {28,58,14,39,000,152,000}
		
	Case nAlt == 623 .OR. nAlt == 636
		aRet := {27,60,13,34,000,170,000}
		
	Case nAlt == 723
		aRet := {23,65,12,27,000,215,000} 
		
	Case nAlt == 783
		aRet := {21,68,11,20,000,245,000}
				
	Case nAlt == 847
		aRet := {19,71,10,64,100,225,100}
		
	Case nAlt == 873
		aRet := {19,71,10,64,105,236,105}
		
	Case nAlt == 903
		aRet := {18,73,09,55,103,256,103}
		
EndCase

/*
591 - 1360 x 768
591 - 1366 x 768
623 - 1280 x 800
723 - 1440 x 900
723 - 1600 x 900
783 - 1280 x 960
847 - 1280 x 1024
873 - 1400 x 1050
873 - 1680 x 1050
903 - 1920 x 1080
*/

Return aRet


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ ValidPerg  ³ Autor ³ Felipe S. Raota            ³ Data ³ 24/04/13 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Grupo de Perguntas.                                               ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ FB007PPR                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function ValidPerg()

local _aArea  := GetArea ()
local _aRegs  := {}
local _aHelps := {}
local _i      := 0
local _j      := 0

_aRegs = {}
//             	   GRUPO ORDEM  PERGUNT         			       PERSPA  PERENG 	   VARIAVL    TIPO 	TAM DEC PRESEL 	   GSC   VALID           	  VAR01       DEF01                DEFSPA1 DEFENG1   CNT01   VAR02               DEF02         DEFSPA2    DEFENG2   CNT02 	  VAR03 					DEF03   DEFSPA3 DEFENG3 CNT03 	VAR04 	     DEF04     DEFSPA4     DEFENG4 CNT04             VAR05      DEF05 DEFSPA5 DEFENG5 CNT05   F3  	GRPSXG    
AADD (_aRegs, {_cPerg, "01", "Período (Ex.: 1/2014 ou 2/2014)?", 	"",    "",    "mv_ch1", 	"C", 06, 0,  	0,     "G", 	"",          "mv_par01", 				"",        		"",     "",     "",		"",   				"",             "",			"",		"",		"",     					"",     "",   	"",   "",      "",     		"",     	"",   		"",   "",   			"",     	"",     "",    "",	"",   	"",   	""})

// Definicao de textos de help (versao 7.10 em diante): uma array para cada linha.
_aHelps = {}    //               1         2         3         4             1         2         3         4             1         2         3         4
//              Ordem   1234567890123456789012345678901234567890    1234567890123456789012345678901234567890    1234567890123456789012345678901234567890
//AADD (_aHelps, {"01", {"Informar Data Inicial         ","",""}})

/*
DbSelectArea ("SX1")
DbSetOrder (1)
For _i := 1 to Len (_aRegs)
	If ! DbSeek (_cPerg + _aRegs [_i, 2])
		RecLock("SX1", .T.)
	Else
		RecLock("SX1", .F.)
	Endif
	For _j := 1 to FCount ()
		// Campos CNT nao sao gravados para preservar conteudo anterior.
		If _j <= Len (_aRegs [_i]) .and. left (FieldName (_j), 6) != "X1_CNT" .and. FieldName (_j) != "X1_PRESEL"
			FieldPut(_j, _aRegs [_i, _j])
		Endif
	Next
	MsUnlock()
Next

// Deleta do SX1 as perguntas que nao constam em _aRegs
DbSeek (_cPerg, .T.)
do while ! eof () .and. x1_grupo == _cPerg
	if ascan (_aRegs, {|_aVal| _aVal [2] == sx1 -> x1_ordem}) == 0
		reclock("SX1", .F.)
		dbdelete()
		msunlock()
	endif
	dbskip()
enddo

// Gera helps das perguntas
For _i := 1 to Len (_aHelps)
	PutSX1Help ("P." + AllTrim(_cPerg) + _aHelps [_i, 1] + ".", _aHelps [_i, 2], {}, {})
Next
*/

Restarea(_aArea)

Return