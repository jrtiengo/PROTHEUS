#INCLUDE "PROTHEUS.CH"
// #INCLUDE "Acdv025.ch" 
#INCLUDE 'APVT100.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณTelaApont บAutor  ณ Mauro - Solutio    บ Data ณ  22/09/2014 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ   Tela para apontamento das ordens de produ็ใo, atrav้s    บฑฑ
ฑฑบ          ณ de telas toutch.                                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AUTOMATECH                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function TESTETELA()
// Variaveis Locais da Funcao
Local cCracha	 := Space(25)
Local oCracha

Local cMaquina	 := Space(25)
Local oMaquina

Local cOP	 := Space(25)
Local oOP

Local nQuant	 := 0
Local oQuant

Local oKeyb												// Objeto 
Local lTouch	:= .T. // If( LJGetStation("TIPTELA") == "2", .T., .F. )

Private oFont14n	:= TFont():New( "Arial",,14,,.t.,,,,.f.,.f. )
Private oFont18n	:= TFont():New( "Arial",,18,,.t.,,,,.f.,.f. )

// Variaveis Private da Funcao
Private _oDlg				// Dialog Principal
// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.                        
Private INCLUI := .F.                        
Private ALTERA := .F.                        
Private DELETA := .F.                        

DEFINE MSDIALOG _oDlg TITLE "Apontamento de Produ็ใo" FROM C(315),C(550) TO C(802),C(1336) PIXEL

	// Cria Componentes Padroes do Sistema
	@ C(011),C(175) Say "Automatech" Size C(040),C(008) COLOR CLR_BLUE FONT oFont18n PIXEL OF _oDlg
	@ C(030),C(075) Say "Apontamento de O.P." Size C(090),C(008) COLOR CLR_BLUE FONT oFont18n PIXEL OF _oDlg
	
	@ C(060),C(075) Say "Crachแ:" Size C(020),C(008) COLOR CLR_BLUE FONT oFont18n PIXEL OF _oDlg
	@ C(060),C(125) MsGet oCracha Var cCracha Size C(060),C(009) COLOR CLR_BLUE PIXEL OF _oDlg
	
	@ C(090),C(075) Say "Mแquina: " Size C(025),C(008) COLOR CLR_BLUE FONT oFont18n PIXEL OF _oDlg
	@ C(090),C(125) MsGet oMaquina Var cMaquina Size C(060),C(009) COLOR CLR_BLUE PIXEL OF _oDlg
	
	@ C(120),C(075) Say "OP :" Size C(012),C(008) COLOR CLR_BLUE FONT oFont18n PIXEL OF _oDlg
	@ C(120),C(125) MsGet oOP Var cOP Size C(060),C(009) COLOR CLR_BLUE PIXEL OF _oDlg
	
	@ C(150),C(075) Say "Quantidade: " Size C(032),C(008) COLOR CLR_BLUE FONT oFont18n PIXEL OF _oDlg
	@ C(150),C(125) MsGet oQuant Var nQuant Size C(060),C(009) COLOR CLR_BLUE PIXEL OF _oDlg
	
	oKeyb := TKeyboard():New( 100, 200, 1, _oDlg )
	oCracha:bGotFocus	:= {|| oKeyb:SetVars(oCracha	,TamSX3("ZH6_OPERAD")[1]) } 
	oMaquina:bGotFocus	:= {|| oKeyb:SetVars(oMaquina	,TamSX3("ZH6_RECURS")[1]) } 
	oOP:bGotFocus		:= {|| oKeyb:SetVars(oOP		,TamSX3("ZH6_OP")[1]) }
	oQuant:bGotFocus	:= {|| oKeyb:SetVars(oQuant		,TamSX3("ZH6_QTDPRO")[1]) }
	oOP:SetFocus() 
	
	@ C(210),C(090) Button "Confirma" Size C(050),C(015) FONT oFont18n PIXEL OF _oDlg
	@ C(210),C(250) Button "Cancela" Size C(050),C(015) FONT oFont18n PIXEL OF _oDlg

ACTIVATE MSDIALOG _oDlg CENTERED 

Return(.T.)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณPrograma   ณ   C()   ณ Autores ณ Norbert/Ernani/Mansano ณ Data ณ10/05/2005ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao  ณ Funcao responsavel por manter o Layout independente da       ณฑฑ
ฑฑณ           ณ resolucao horizontal do Monitor do Usuario.                  ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/

Static Function C(nTam)                                                         

Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
		nTam *= 0.8                                                                
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600                
		nTam *= 1                                                                  
	Else	// Resolucao 1024x768 e acima                                           
		nTam *= 1.28                                                               
	EndIf                                                                         
                                                                                
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ                                               
	//ณTratamento para tema "Flat"ณ                                               
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู                                               
	If "MP8" $ oApp:cVersion                                                      
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()                      
			nTam *= 0.90                                                            
		EndIf                                                                      
	EndIf                                                                         
Return Int(nTam)