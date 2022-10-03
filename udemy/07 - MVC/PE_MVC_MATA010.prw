#include 'protheus.ch'
#include 'parmtype.ch'

/*** RCTI TREINAMENTOS
**** ADVPL AVANÇANDO COM MVC
***/

user function ITEM()
	
	Local aParam := PARAMIXB
	Local xRet := .T.
	Local oObj := ""
	Local cTipo := AllTrim(M->B1_TIPO)
	Local cConta := AllTrim(M->B1_CONTA)
	Local cIdPonto := ""
	Local cIdModel := ""
	
		If aParam <> Nil
			oObj := aParam[1]
			cIdPonto := aParam[2]
			cIdModel := aParam[3]
			
		If cIdPonto == "MODELPOS" .And. cTipo = "PA" .And. cConta = "001"
		
			MsgALert("A conta <b> "+ cConta + "</b> não pode estar associada a um produto do tipo <b>" + cTipo)
			xRet := .F.
		
		ElseIf cIdPonto == "BUTTONBAR"
			xRet := {{"Botão","BOTAO", {||U_BTN_PE()}}}
		
		EndIf
		EndIf
	
	
return xRet

User Function BTN_PE()
	//acao do botao
	
	MsgInfo("Você clicou no botão!")

Return Nil
