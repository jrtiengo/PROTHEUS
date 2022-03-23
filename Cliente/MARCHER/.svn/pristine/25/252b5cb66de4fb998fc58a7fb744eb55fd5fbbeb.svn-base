#INCLUDE "TopConn.ch"
#INCLUDE 'tbiconn.ch'
#INCLUDE "Protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณMARWF001 บAutor  ณMarcioQuevedoBorges บ Data ณ  11/10/2018   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณSchedule para Startar Workflow de Email para Fornecedores  iบฑฑ
ฑฑบ          ณ folow-up de Compras                                        บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MARWF001(aParam)

	Private lViaSchedule
	Private cRotina   := "MARWF001"

	IF Type("dDatabase") == "U" // Se rodado via workflow a variแvel dDatabase estara disponivel somente apos o Prepare Environment
		lViaSchedule := .T.
	ELSE
		lViaSchedule := .F.
	ENDIF

	CONOUT(cRotina + " - Vari้vel lViaSchedule :")
	CONOUT(lViaSchedule)


	IF lViaSchedule
		cEmp := aParam[01]
		cFil := aParam[02]
		//cUser:= aParam[03]

		conout( cRotina + " -  VIA Schedule - Preparando Environment")
		WFPrepEnv(cEmp,cFil,cRotina)	
	ELSE
		Conout( cRotina + " -  VIA MENU    - Preparando Environment ")
	ENDIF

	// Roda Rotina de Compras 
	U_FLWCOM01()


	IF lViaSchedule
		Conout( cRotina + " -  VIA SCHEDULE    -  Job executado com sucesso.. FINALIZANDO ENVIRONMENT ")
		Reset Environment
	ELSE
		Conout( cRotina + " -  VIA MENU -  Job executado com sucesso.. FINALIZANDO ENVIRONMENT ")
	ENDIF

Return

