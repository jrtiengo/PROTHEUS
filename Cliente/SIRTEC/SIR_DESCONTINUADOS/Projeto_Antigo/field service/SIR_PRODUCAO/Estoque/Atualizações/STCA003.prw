#INCLUDE "PROTHEUS.CH"
#include "topconn.ch"
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³STCA003   ³ Autor ³ Rafael Costa Leite    ³ Data ³01/08/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Avaliação do Fornecedor                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³#                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³#                                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³ Ponto de Entrada após digitação do Documento de Entrada    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ MATA103 - Estoque - Sirtec                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista Resp.³  Data  ³ Bops ³ Manutencao Efetuada                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³  /  /  ³      ³                                        ³±±
±±³              ³  /  /  ³      ³                                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function STCA003

Private MV_YFORM := Alltrim(GetMv("MV_YFORM"))
Private aNotas   := {}
Private aCab     := {}
Private aFat     := {}
Private aZZ2     := {}
Private aRecNT := {}

	If SA2->A2_YAVAL == "S" .and. SF1->F1_TIPO == "N"
	ZZ2->(DbSetOrder(1))
		If !ZZ2->(DbSeek(xFilial("ZZ2")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)))
		ZZ1->(DbSetOrder(1))
			If ZZ1->(DbSeek(xFilial("ZZ1")+MV_YFORM))
			
			aCab := {SA2->A2_NOME,SF1->F1_FORNECE,SF1->F1_LOJA,SF1->F1_DOC,SF1->F1_SERIE,ZZ1->ZZ1_FORM}
			
			//Array com fatores a serem avaliados
				While !ZZ1->(EOF()) .and. ZZ1->ZZ1_FORM == MV_YFORM
				AADD(aFat,{ZZ1->ZZ1_FATOR,ZZ1->ZZ1_NOME,0,.F.})
				ZZ1->(DbSkip())
				Enddo
			
			aNotas := U_STCA003A(aCab,aFat)
			
			//Array contendo as anotas a serem gravadas
			AADD(aRecNT,{"ZZ2_FILIAL",xFilial("ZZ2") })
			AADD(aRecNT,{"ZZ2_DOC"   ,SF1->F1_DOC    })
			AADD(aRecNT,{"ZZ2_SERIE" ,SF1->F1_SERIE  })
			AADD(aRecNT,{"ZZ2_FORNEC",SF1->F1_FORNECE})
			AADD(aRecNT,{"ZZ2_LOJA"  ,SF1->F1_LOJA   })
			AADD(aRecNT,{"ZZ2_TIPO"  ,SF1->F1_TIPO   })
			AADD(aRecNT,{"ZZ2_FORM"  ,ZZ1->ZZ1_FORM  })
			
				For i:=1 to Len(aNotas)
				ZZ1->(DbSetOrder(2))
					If ZZ1->(DbSeek(xFilial("ZZ1")+MV_YFORM+aNotas[i,1]))
					AADD(aRecNT,{ZZ1->ZZ1_CAMPO,aNotas[i][3]})
					Else
					MsgStop("Falha para gravação da avaliação. STCA003","STCA003")
					Endif
				Next i
			
			//Atualiza notas
			U_STCA003C("ZZ2",aRecNT,.T.)
			
			//Grava a media do fornecedor
			ZZ1->(DbSetOrder(1))
				If ZZ1->(DbSeek(xFilial("ZZ1")+MV_YFORM))
				ZZ2->(DbSetOrder(1))
					If ZZ2->(DbSeek(xFilial("ZZ2")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO)))
					DbSelectArea("ZZ2")
					cTemp  :=ZZ1->ZZ1_FORMUL
					nValor := (&cTemp)
					nValor := Round((nValor*10),1)
					Reclock("ZZ2",.F.)
					ZZ2->ZZ2_MEDIA := nValor
					ZZ2->(MsUnlock())
					Endif
				Endif
			
			Else
			MsgStop("Não foi possível encontrar a formula " + MV_YFORM ;
			+ " verifique o Cadastro de Fatores e o parâmetro MV_YFORM. STCA003.","STCA003")
			Endif
		Endif
	Endif
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³STCA003A  ³ Autor ³ Rafael Costa Leite    ³ Data ³01/08/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela de Avaliação do Fornecedor                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aPar1 -> array contendo as informações do cabeçalho        ³±±
±±³          ³ [1] - nome do fornecedor                                   ³±±
±±³          ³ [2] - codigo do fornecedor                                 ³±±
±±³          ³ [3] - loja do fornecedor                                   ³±±
±±³          ³ [4] - documento avaliado                                   ³±±
±±³          ³ [5] - serie do documento avaliado                          ³±±
±±³          ³ [6] - formula utilizada                                    ³±±
±±³          ³                                                            ³±±
±±³          ³ aPar2 -> fatores a serem avaliados                         ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ array contendo as notas digitadas                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Aplicacao ³ Avaliação do Fornecedor                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±*/
User Function STCA003A(aPar1,aPar2)

// Variaveis Locais da Funcao

// Variaveis da Funcao de Controle e GertArea/RestArea
Local _aArea   		:= {}
Local _aAlias  		:= {}

// Variaveis Private da Funcao
Private oDlg				// Dialog Principal
Private aRet    := {}
Private lJanela := .T.

// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.
Private INCLUI := .F.
Private ALTERA := .F.
Private DELETA := .F.

// Privates das NewGetDados
Private oGetDados1

	While lJanela
	DEFINE MSDIALOG oDlg TITLE "Qualidade dos Fornecedores" FROM C(194),C(245) TO C(534),C(685) PIXEL
	
	// Defina aqui a chamada dos Aliases para o GetArea
	CtrlArea(1,@_aArea,@_aAlias,{"SF1","SD1","SA2"}) // GetArea
	
	// Cria as Groups do Sistema
	@ C(002),C(002) TO C(035),C(215) LABEL "Informações do Fornecedor " PIXEL OF oDlg
	@ C(040),C(002) TO C(067),C(215) LABEL "Documento a ser Avaliado" PIXEL OF oDlg
	@ C(070),C(002) TO C(165),C(215) LABEL "Avaliação do Forncedor " PIXEL OF oDlg
	
	// Cria Componentes Padroes do Sistema
	@ C(012),C(007) Say "Fornecedor :"	Size C(034),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	@ C(012),C(041) Say aPar1[1]       	Size C(170),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	
	@ C(022),C(007) Say "Código :"		Size C(029),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	@ C(022),C(030) Say aPar1[2]	  		Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	
	@ C(022),C(060) Say "Loja :" 		Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	@ C(023),C(077) Say aPar1[3] 		Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	
	@ C(052),C(007) Say "Documento :"	Size C(035),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	@ C(052),C(042) Say aPar1[4]			Size C(031),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	
	@ C(052),C(100) Say "Serie : "		Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	@ C(052),C(117) Say aPar1[5]			Size C(018),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	
	@ C(082),C(008) Say "Formula: " 	Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	@ C(082),C(031) Say aPar1[6]			Size C(021),C(008) COLOR CLR_BLACK PIXEL OF oDlg
	
	DEFINE SBUTTON FROM C(115),C(185) TYPE 1 ENABLE OF oDlg ACTION(fOK(aPar1[6]))
	DEFINE SBUTTON FROM C(135),C(185) TYPE 2 ENABLE OF oDlg ACTION(fCancela())
	
	// Chamadas das GetDados do Sistema
	fGetDados1(aPar2)
	
	CtrlArea(2,_aArea,_aAlias) // RestArea
	
	ACTIVATE MSDIALOG oDlg CENTERED
	Enddo

Return aRet

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³fGetDados1()³ Autor ³ Ricardo Mansano           ³ Data ³01/08/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Montagem da GetDados                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao ³ O Objeto oGetDados1 foi criado como Private no inicio do Fonte   ³±±
±±³           ³ desta forma voce podera trata-lo em qualquer parte do            ³±±
±±³           ³ seu programa:                                                    ³±±
±±³           ³                                                                  ³±±
±±³           ³ Para acessar o aCols desta MsNewGetDados: oGetDados1:aCols[nX,nY]³±±
±±³           ³ Para acessar o aHeader: oGetDados1:aHeader[nX,nY]                ³±±
±±³           ³ Para acessar o "n"    : oGetDados1:nAT                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fGetDados1(aFatores)
// Variaveis deste Form
Local nX			:= 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis da MsNewGetDados()      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
// Vetor responsavel pela montagem da aHeader
Local aCpoGDa       := {"ZZ1_FATOR","ZZ1_NOME","ZZ2_MEDIA"}

// Vetor com os campos que poderao ser alterados
Local aAlter       	:= {"ZZ2_MEDIA"}
Local nSuperior    	:= C(092)           // Distancia entre a MsNewGetDados e o extremidade superior do objeto que a contem
Local nEsquerda    	:= C(005)           // Distancia entre a MsNewGetDados e o extremidade esquerda do objeto que a contem
Local nInferior    	:= C(160)           // Distancia entre a MsNewGetDados e o extremidade inferior do objeto que a contem
Local nDireita     	:= C(174)           // Distancia entre a MsNewGetDados e o extremidade direita  do objeto que a contem

// Posicao do elemento do vetor aRotina que a MsNewGetDados usara como referencia
Local nOpc         	:= GD_UPDATE        //GD_INSERT+GD_DELETE+GD_UPDATE
Local cLinOk       	:= "AllwaysTrue"    // Funcao executada para validar o contexto da linha atual do aCols
Local cTudoOk      	:= "AllwaysTrue"    // Funcao executada para validar o contexto geral da MsNewGetDados (todo aCols)
Local cIniCpos     	:= ""               // Nome dos campos do tipo caracter que utilizarao incremento automatico.
// Este parametro deve ser no formato "+<nome do primeiro campo>+<nome do
// segundo campo>+..."
Local nFreeze      	:= 000              // Campos estaticos na GetDados.
Local nMax         	:= 999              // Numero maximo de linhas permitidas. Valor padrao 99
Local cFieldOk     	:= "AllwaysTrue"    // Funcao executada na validacao do campo
Local cSuperDel     	:= ""              // Funcao executada quando pressionada as teclas <Ctrl>+<Delete>
Local cDelOk        	:= "AllwaysFalse"   // Funcao executada para validar a exclusao de uma linha do aCols

// Objeto no qual a MsNewGetDados sera criada
Local oWnd          := oDlg
Local aHead        	:= {}               // Array a ser tratado internamente na MsNewGetDados como aHeader
Local aCol         	:= {}               // Array a ser tratado internamente na MsNewGetDados como aCols
Local _cSX3 		:= GetNextAlias()


// Carrega aHead

OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX3,"SX3",Nil,.F.)
lOpen := Select(_cSX3) > 0
If (lOpen)
  dbSelectArea(_cSX3)
  (_cSX3)->(dbSetOrder(2)) //X3_CAMPO
	For nX := 1 to Len(aCpoGDa)
		If (_cSX3)->(dbSeek(aCpoGDa[nX]))
	  		Aadd(aHead,{ AllTrim( &("(_cSX3)->X3_TITULO")),;
			&("(_cSX3)->X3_CAMPO")	,;
			&("(_cSX3)->X3_PICTURE"),;
			&("(_cSX3)->X3_TAMANHO"),;
			&("(_cSX3)->X3_DECIMAL"),;
			&("(_cSX3)->X3_VALID")	,;
			&("(_cSX3)->X3_USADO")	,;
			&("(_cSX3)->X3_TIPO")	,;
			&("(_cSX3)->X3_F3")		,;
			&("(_cSX3)->X3_CONTEXT"),;
			&("(_cSX3)->X3_CBOX")	,;
			&("(_cSX3)->X3_RELACAO")})
	
			//Ajusta informações para o campo Nota
			If Alltrim(aCpoGDa[nX]) == "ZZ2_MEDIA"
				aHead[nX][1] := "Notas"
				aHead[nX][6] := "U_STCA003B(n,Alltrim(GetMv('MV_YFORM'))+GdfieldGet('ZZ1_FATOR',n),M->ZZ2_MEDIA)"
			Endif
		Endif
	Next nX
Endif


/*DbSelectArea("SX3")
SX3->(DbSetOrder(2)) // Campo
For nX := 1 to Len(aCpoGDa)
	If SX3->(DbSeek(aCpoGDa[nX]))
		Aadd(aHead,{ AllTrim(X3Titulo()),;
		SX3->X3_CAMPO	,;
		SX3->X3_PICTURE,;
		SX3->X3_TAMANHO,;
		SX3->X3_DECIMAL,;
		SX3->X3_VALID	,;
		SX3->X3_USADO	,;
		SX3->X3_TIPO	,;
		SX3->X3_F3 		,;
		SX3->X3_CONTEXT,;
		SX3->X3_CBOX	,;
		SX3->X3_RELACAO})
		
		//Ajusta informações para o campo Nota
		If Alltrim(aCpoGDa[nX]) == "ZZ2_MEDIA"
			aHead[nX][1] := "Notas"
			aHead[nX][6] := "U_STCA003B(n,Alltrim(GetMv('MV_YFORM'))+GdfieldGet('ZZ1_FATOR',n),M->ZZ2_MEDIA)"
		Endif
	Endif
Next nX
*/

// Carregue aqui a Montagem da sua aCol
aAux := {}
For nX := 1 to Len(aCpoGDa)
	If DbSeek(aCpoGDa[nX])
		Aadd(aAux,CriaVar(&("(_cSX3)->X3_CAMPO")))
	Endif
Next nX
Aadd(aAux,.F.)
Aadd(aCol,aAux)

(_cSX3)->(dbCloseArea())

/*
FUNCOES PARA AUXILIO NO USO DA NEWGETDADOS
PARA MAIORES DETALHES ESTUDE AS FUNCOES AO FIM DESTE FONTE
==========================================================

// Retorna numero da coluna onde se encontra o Campo na NewGetDados
Ex: NwFieldPos(oGet1,"A1_COD")

// Retorna Valor da Celula da NewGetDados
// OBS: Se nLinha estiver vazia ele acatara o oGet1:nAt(Linha Atual) da NewGetDados
Ex: NwFieldGet(oGet1,"A1_COD",nLinha)

// Alimenta novo Valor na Celula da NewGetDados
// OBS: Se nLinha estiver vazia ele acatara o oGet1:nAt(Linha Atual) da NewGetDados
Ex: NwFieldPut(oGet1,"A1_COD",nLinha,"Novo Valor")

// Verifica se a linha da NewGetDados esta Deletada.
// OBS: Se nLinha estiver vazia ele acatara o oGet1:nAt(Linha Atual) da NewGetDados
Ex: NwDeleted (oGet1,nLinha)
*/

oGetDados1:= MsNewGetDados():New(nSuperior,nEsquerda,nInferior,nDireita,nOpc,cLinOk,cTudoOk,cIniCpos,;
	aAlter,nFreeze,nMax,cFieldOk,cSuperDel,cDelOk,oWnd,aHead,aCol)

// Alimenta o aCols
oGetDados1:aCols:=aFatores
oGetDados1:oBrowse:Refresh()
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C(nTam)
Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
	nTam *= 0.8
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
	nTam *= 1
	Else	// Resolucao 1024x768 e acima
	nTam *= 1.28
	EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Tratamento para tema "Flat"³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If "MP8" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
		nTam *= 0.90
		EndIf
	EndIf
Return Int(nTam)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CtrlArea º Autor ³Ricardo Mansano     º Data ³ 18/05/2005  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºLocacao   ³ Fab.Tradicional  ³Contato ³ mansano@microsiga.com.br       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Static Function auxiliar no GetArea e ResArea retornando   º±±
±±º          ³ o ponteiro nos Aliases descritos na chamada da Funcao.     º±±
±±º          ³ Exemplo:                                                   º±±
±±º          ³ Local _aArea  := {} // Array que contera o GetArea         º±±
±±º          ³ Local _aAlias := {} // Array que contera o                 º±±
±±º          ³                     // Alias(), IndexOrd(), Recno()        º±±
±±º          ³                                                            º±±
±±º          ³ // Chama a Funcao como GetArea                             º±±
±±º          ³ P_CtrlArea(1,@_aArea,@_aAlias,{"SL1","SL2","SL4"})         º±±
±±º          ³                                                            º±±
±±º          ³ // Chama a Funcao como RestArea                            º±±
±±º          ³ P_CtrlArea(2,_aArea,_aAlias)                               º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ nTipo   = 1=GetArea / 2=RestArea                           º±±
±±º          ³ _aArea  = Array passado por referencia que contera GetArea º±±
±±º          ³ _aAlias = Array passado por referencia que contera         º±±
±±º          ³           {Alias(), IndexOrd(), Recno()}                   º±±
±±º          ³ _aArqs  = Array com Aliases que se deseja Salvar o GetArea º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºAplicacao ³ Generica.                                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CtrlArea(_nTipo,_aArea,_aAlias,_aArqs)
Local _nN
// Tipo 1 = GetArea()
	If _nTipo == 1
	_aArea   := GetArea()
		For _nN  := 1 To Len(_aArqs)
		DbSelectArea(_aArqs[_nN])
		AAdd(_aAlias,{ Alias(), IndexOrd(), Recno()})
		Next
	// Tipo 2 = RestArea()
	Else
		For _nN := 1 To Len(_aAlias)
		DbSelectArea(_aAlias[_nN,1])
		DbSetOrder(_aAlias[_nN,2])
		DbGoto(_aAlias[_nN,3])
		Next
	RestArea(_aArea)
	Endif
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ NwFieldPos ³ Autor ³ Ricardo Mansano       ³ Data ³06/09/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Retorna numero da coluna onde se encontra o Campo na         ³±±
±±³           ³ NewGetDados                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ oObjeto := Objeto da NewGetDados                             ³±±
±±³           ³ cCampo  := Nome do Campo a ser localizado                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ Numero da coluna localizada pelo aScan                       ³±±
±±³           ³ OBS: Se retornar Zero significa que nao localizou o Registro ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function NwFieldPos(oObjeto,cCampo)
Local nCol := aScan(oObjeto:aHeader,{|x| AllTrim(x[2]) == Upper(cCampo)})
Return(nCol)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ NwFieldGet ³ Autor ³ Ricardo Mansano       ³ Data ³06/09/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Retorna Valor da Celula da NewGetDados                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ oObjeto := Objeto da NewGetDados                             ³±±
±±³           ³ cCampo  := Nome do Campo a ser localizado                    ³±±
±±³           ³ nLinha  := Linha da GetDados, caso o parametro nao seja      ³±±
±±³           ³            preenchido o Default sera o nAt da NewGetDados    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ xRet := O Valor da Celula independente de seu TYPE           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function NwFieldGet(oObjeto,cCampo,nLinha)
Local nCol := aScan(oObjeto:aHeader,{|x| AllTrim(x[2]) == Upper(cCampo)})
Local xRet
// Se nLinha nao for preenchida Retorna a Posicao de nAt do Objeto
Default nLinha := oObjeto:nAt
xRet := oObjeto:aCols[nLinha,nCol]
Return(xRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ NwFieldPut ³ Autor ³ Ricardo Mansano       ³ Data ³06/09/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Alimenta novo Valor na Celula da NewGetDados                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ oObjeto := Objeto da NewGetDados                             ³±±
±±³           ³ cCampo  := Nome do Campo a ser localizado                    ³±±
±±³           ³ nLinha  := Linha da GetDados, caso o parametro nao seja      ³±±
±±³           ³            preenchido o Default sera o nAt da NewGetDados    ³±±
±±³           ³ xNewValue := Valor a ser inputado na Celula.                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function NwFieldPut(oObjeto,cCampo,nLinha,xNewValue)
Local nCol := aScan(oObjeto:aHeader,{|x| AllTrim(x[2]) == Upper(cCampo)})
// Se nLinha nao for preenchida Retorna a Posicao de nAt do Objeto
Default nLinha := oObjeto:nAt
// Alimenta Celula com novo Valor se este foi preenchido
	If !Empty(xNewValue)
	oObjeto:aCols[nLinha,nCol] := xNewValue
	Endif
Return Nil

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³ NwDeleted  ³ Autor ³ Ricardo Mansano       ³ Data ³06/09/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Verifica se a linha da NewGetDados esta Deletada.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ oObjeto := Objeto da NewGetDados                             ³±±
±±³           ³ nLinha  := Linha da GetDados, caso o parametro nao seja      ³±±
±±³           ³            preenchido o Default sera o nAt da NewGetDados    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³ lRet := True = Linha Deletada / False = Nao Deletada         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function NwDeleted(oObjeto,nLinha)
Local nCol := Len(oObjeto:aCols[1])
Local lRet := .T.
// Se nLinha nao for preenchida Retorna a Posicao de nAt do Objeto
Default nLinha := oObjeto:nAt
// Alimenta Celula com novo Valor
lRet := oObjeto:aCols[nLinha,nCol]
Return(lRet)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função     ³ fCancela   ³ Autor ³ Rafael Costa Leite    ³ Data ³02/08/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Função a ser executada na tela de Avaliação do Fornecedor.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³                                                              ³±±
±±³           ³                                                              ³±±
±±³           ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fCancela
MsgInfo("Opção não liberada para uso, devem ser preenchido todos os fatores de avalição com confirmação para gravação. STCA003A.";
,"STCA003A")
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função     ³ fOk        ³ Autor ³ Rafael Costa Leite    ³ Data ³02/08/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Função a ser executada na tela de Avaliação do Fornecedor.   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³                                                              ³±±
±±³           ³                                                              ³±±
±±³           ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³aCols, quando validação dos dasdos estiver Ok.                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function fOk(cCod)

Local lControl := .T.

	For j:=1 to Len(oGetDados1:aCols)
	//Validação do aCols
		If !U_STCA003B(j,cCod+NwFieldGet(oGetDados1,"ZZ1_FATOR",j),NwFieldGet(oGetDados1,"ZZ2_MEDIA",j))
		lControl := .F.
		Endif
	Next j

	If lControl
	lJanela := .F.
	aRet := oGetDados1:aCols
	oDlg:End()
	Return oGetDados1:aCols
	Else
	MsgStop("Verifique a avaliação digitada, existem notas incorretas. STCA003A.","STCA003A")
	Endif
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função     ³ STCA003B   ³ Autor ³ Rafael Costa Leite    ³ Data ³02/08/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Validação das notas que podem ser utilizadas             .   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³                                                              ³±±
±±³           ³                                                              ³±±
±±³           ³                                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³                                                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function STCA003B(nLin,cFator,nValor)

Local cMsg := ""
Private aVal := {}
Private lRet := .F.

ZZ1->(DbSetOrder(2))
	If ZZ1->(DbSeek(xFilial("ZZ1")+cFator))
	aVal := U_STCA001D(ZZ1->ZZ1_NOTAS)
	
	//Valida as notas
		For k:=1 to Len(aVal)
			If aVal[k][2] == nValor
			lRet := .T.
			Endif
		Next k
	Else
	MsgStop("Não foi possível encontrar a formula " + cFator ;
	+ " verifique o Cadastro de Fatores e o parâmetro MV_YFORM. STCA003.","STCA003")
	Endif

	If !lRet
	MsgStop("Essa nota não é valida, utilize as notas " + Alltrim(ZZ1->ZZ1_NOTAS) + ". STCA003B","STCA003B")
	Endif

Return lRet

/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA003C    | Microsiga Vitória | Data | 05.04.2007 |
+----------+------------+-------------------+------+------------+
|Descrição | Efetua a gravação de registros                     |
|          |                                                    |
+----------+----------------------------------------------------+
|Sintaxe   |função a ser executada                              |
+----------+----------------------------------------------------+
|Parametros| 1 - cParm1: alias a ser utilizado                  |
+          | 2 - aParm2: parametro contendo os campos e valores |
+          | 3 - lParm3: inclusão .T., alteração .F.            |
+----------+----------------------------------------------------+
|Retorno   |Logico                                              |
+----------+----------------------------------------------------+
|Uso       |Sirtec                                              |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
*/
User Function STCA003C(cAlias, aArray, lAppend)

	Local cOldAlias:=Alias()
	Local lRet:=.T.

//Pega as informações do execblock
	If Empty(cAlias)
		cAlias := PARAMIXB[1]
		aArray := PARAMIXB[2]
		lAppend := PARAMIXB[3]
	Endif

	DbSelectArea(cAlias)

//Verifica se pode grava o registro
	lRet := RecLock(cAlias, lAppend)

	If lRet
		AEval(aArray, {|x| FieldPut(FieldPos(x[1]), x[2])})
	Else
		//ConOut("STCA003C - Impossible lock on file "+cAlias+" Record:"+AllTrim(Str(Recno()))+".")
		FWLogMsg("INFO", , "INTEGRATION", FunName() , "SENDER", , "STCA003C - Impossible lock on file "+cAlias+" Record:"+AllTrim(Str(Recno()))+".")
	EndIf

	If lRet
		DbCommit()
		MsUnLock()
	EndIf

	If !Empty(cOldAlias)
		DbSelectArea(cOldAlias)
	EndIf

Return(lRet)
