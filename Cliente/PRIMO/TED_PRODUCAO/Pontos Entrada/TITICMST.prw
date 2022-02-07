#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} TITICMST
Ponto de Entrada localizado após a gravação das informações 
padrões do tributo para título a ser gerado no financeiro.
#28333
@author Mauro - Solutio 
@since 10/12/2020
@version 6
@return ${return}, ${return_description}

@type function
/*/
user function TITICMST()

	Local cOrigem	:= PARAMIXB[1]
	Local lConf		:= .F.
	Local nVal_	:= 0
	Local oVal_
	
	Private _oDlg
	
	If  AllTrim(cOrigem)=='MATA953' .And. SF6->F6_TIPOIMP == '1' .And. ( SE2->E2_PREFIXO == "PRD"  ) //Apuracao de ICMS
	
		nVal_ := SF6->F6_VALOR

		DEFINE MSDIALOG _oDlg TITLE "Valor do Título" FROM C(365),C(407) TO C(632),C(843) PIXEL

		@ C(010),C(065) Say "Por favor, confirme o valor do PRODEC." Size C(086),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(050),C(035) Say "Valor:" Size C(015),C(008) COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(047),C(080) MsGet oVal_ Var nVal_ Size C(060),C(009) PICTURE "@E 9,999,999.99" COLOR CLR_BLACK PIXEL OF _oDlg
		@ C(095),C(035) Button "Confirma" Action(lConf := .T.,  _oDlg:End() ) Size C(037),C(012) PIXEL OF _oDlg
		@ C(095),C(140) Button "Cancela" Action(lConf := .F.,  _oDlg:End() )Size C(037),C(012) PIXEL OF _oDlg

		ACTIVATE MSDIALOG _oDlg CENTERED 
		
		If lConf
			Reclock("SF6",.F.)
			SF6->F6_VALOR	:= nVal_
			SF6->F6_ACORDO	:= "145010000000236"
			SF6->F6_CODREC	:= "3000"
			SF6->F6_CLAVENC	:= "10405"
			SF6->F6_DTVENC	:= SE2->E2_VENCREA
			SF6->F6_DTARREC	:= SE2->E2_VENCREA
			MsUnlock()
			
			Reclock("SE2",.F.)
			SE2->E2_VALOR	:= nVal_
			SE2->E2_SALDO	:= nVal_
			SE2->E2_VLCRUZ	:= nVal_
			SE2->E2_NATUREZ	:= "20922"
			MsUnlock()
		
		EndIf

	EndIf 


Return({SE2->E2_NUM,SE2->E2_VENCTO})


/*/{Protheus.doc} C
//TODO Descrição auto-gerada.
@author Mauro - Solutio.
@since 10/12/2020
@version 6
@return ${return}, ${return_description}
@param nTam, numeric, descricao
@type function
/*/

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
