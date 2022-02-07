#include 'protheus.ch'
#include 'parmtype.ch'

user function MT120SCR()

Local oNewDLG  := PARAMIXB

IF ALLTRIM(UsrRetName(RetCodUsr())) == U_CamposPC("CGC")

	oNewDLG:aControls[07]:lReadOnly := .t.
	oNewDLG:aControls[07]:lActive 	:= .f. //Bloqueia Fornecedor
	
	oNewDLG:aControls[09]:lReadOnly := .t.
	oNewDLG:aControls[09]:lActive 	:= .f. //Bloqueia Fornecedor
	
	oNewDLG:aControls[11]:lReadOnly := .t.
	oNewDLG:aControls[11]:lActive 	:= .f. //Bloqueia Fornecedor
	
	oNewDLG:aControls[14]:lReadOnly := .t.
	oNewDLG:aControls[14]:lActive 	:= .f. //Bloqueia Fornecedor
	
	oNewDLG:aControls[16]:lReadOnly := .t.
	oNewDLG:aControls[16]:lActive 	:= .f. //Bloqueia Fornecedor
	
	oNewDLG:aControls[18]:lReadOnly := .t.
	oNewDLG:aControls[18]:lActive 	:= .f. //Bloqueia Fornecedor
	
	oNewDLG:aControls[20]:lReadOnly := .t.
	oNewDLG:aControls[20]:lActive 	:= .f. //Bloqueia Fornecedor
	
ENDIF

	SysRefresh()
	GETDREFRESH()
	
return oNewDLG