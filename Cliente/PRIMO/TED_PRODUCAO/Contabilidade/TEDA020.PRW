#INCLUDE "PROTHEUS.CH"

User Function TEDA020()

	Local oDlg1,oGet1,oGet2,oCBox1,oSBtn1
	Private _mvDataFis := GetMv("MV_DATAFIS")
	Private _mvDataFin := GetMv("MV_DATAFIN")
	Private _mvDtBxFin := GetMv("MV_BXDTFIN")

	cCodUser := Upper( AllTrim( SuperGetMV( "ES_APMVCTB",, "000000" ) ) )

	// APENAS USUARIO NO PARAMENTRO ES_APMVCTB
	If !RetCodUsr() $ cCodUser
		Alert("Você Não Tem Permissão Para Acessar Essa Rotina!")
		Return
	EndIf

	oDlg1  := MSDialog():New(108,372,281,668,"Bloqueio de Parâmetros",,,.F.,,,,,,.T.,,,.T. )
	oGet1  := TGet():New(006,008,{|u|Iif(PCount()>0,_mvDataFis:=u,_mvDataFis)},oDlg1,050,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","_mvDataFis",,,,.F.,.F.,,"MV_DATAFIS = Data limite p/operações fiscais",1)
	oGet2  := TGet():New(030,008,{|u|Iif(PCount()>0,_mvDataFin:=u,_mvDataFin)},oDlg1,050,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","_mvDataFin",,,,.F.,.F.,,"MV_DATAFIN = Data limite p/operações financeiras",1)
	oCBox1 := TComboBox():New(054,008,{|o|Iif(PCount()>0,_mvDtBxFin:=o,_mvDtBxFin)},{"1=Permite","2=Não Permite"},060,010,oDlg1,,,,CLR_BLACK,CLR_WHITE,.T.,,,,,,,,,"_mvDtBxFin","MV_BXDTFIN = Permite baixa em data após MV_DATAFIN",1)
	oSBtn1 := SButton():New(065,112,1,{||UpdMVCtb(),oDlg1:End()},oDlg1,,"",)

	oDlg1:Activate(,,,.T.)

Return

Static Function UpdMVCtb()

	// Faz validações e Altera os parâmetros.
	If !Empty(_mvDataFis)
		PutMv("MV_DATAFIS",_mvDataFis)
	EndIf

	If !Empty(_mvDataFin)
		PutMv("MV_DATAFIN",_mvDataFin)
	EndIf

	If !Empty(_mvDtBxFin)
		PutMv("MV_BXDTFIN",_mvDtBxFin)
	EndIf

Return
