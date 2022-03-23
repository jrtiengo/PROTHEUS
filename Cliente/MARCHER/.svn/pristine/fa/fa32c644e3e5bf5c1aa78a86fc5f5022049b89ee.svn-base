#include 'protheus.ch'

User Function MT103NAT()
	
	Local cNat := PARAMIXB
	Local lRet := .T.
	Public cNatSF1 := cNat
	
	DbSelectArea("SED")
	DbSetOrder(1)
	If !MsSeek(xFilial("SED")+cNat)
		MsgInfo( "Natureza não encontrada no cadastro.", "PE_MT103NAT" )
		lRet := .F.
	EndIf
	
Return( lRet )