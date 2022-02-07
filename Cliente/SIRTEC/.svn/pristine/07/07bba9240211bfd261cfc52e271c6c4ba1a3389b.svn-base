#include "protheus.ch"
#INCLUDE "rwmake.ch"
#INCLUDE "tbiconn.ch"

/*{Protheus.doc} AFPUPD

Ferramenta de atualização do dicionário

Ações:

	browser para selecionar as empresas
	executa
	exibe log com opção de salvar

@developer	Helitom Silva
@version 	P11 e P10
@since   	16/09/2013
@author  	Helitom Silva - helitom.silva@hotmail.com
@obs

*/
User Function AFPUPD()
	
/*	Local aData 		:= {}
	Local aEmpresas 	:= {}
		
	Private cCodEmp   := '99'
	Private cCodFil   := '01'
	Private _lConect  := .F.
	
	Private oLog 		:= UPDLOG():CREATE()
	
	If !Findfunction("U_DEVUPD0")
		MsgAlert("Aplique o patch do compatibilizador! Qualquer Duvida consulte a Fábrica de Software!")
		Return
	EndIf
	
	//U_FCONECT('99','01')
	
	//Conexao com empresa Inicial para ter acesso as demais, pois as vezes alguns clientes não tem a empresa 99
	If !MsgSelEmp()
		Return
	EndIf
	
	aEmpresas 		:= U_DEVUPD0()	
	aData			   := U_DEVUPD1(aEmpresas, "AFPUPD06") //Cadastros (Bomba, Bico, Lacre, Tanque, Armazem)
	aData			   := U_DEVUPD1(aEmpresas, "AFPUPD07") //Lançamentos da AsFrete
			
 	SalvaLog(oLog:log())*/
 	
	Local aData := {}

	aAdd(aData, {"AFPUPD01", "Cadastros (Area, Municipio) "})
	
Return aData

Static Function SalvaLog(cLog)

	Local cFile := "C:/TEMP/codupd.txt"

	MemoWrite( cFile, cLog )
	
Return

Static Function MsgSelEmp()

	Local lSair := .t.

  	bOk2 := {|| IIF(cCodEmp <> Space(2) .or. cCodFil <> Space(8), SetaEmp(), msgInfo('Por favor, informe a Empresa e a Filial!'))  }
	bCancel2 := {|| lSair := .f., oDlgTab:End()}

	cCodEmp := PadR(cCodEmp, 2)
	cCodFil := PadR(cCodFil, 8)

	/*Declaração de Variaveis Private dos Objetos*/
	SetPrvt("oDlgTab","oPanelTab","oSayC","oSayR","oBtnOk","oBtnCc","oGtCons","oGtReve")


	/*Definicao do Dialog e todos os seus componentes.*/

	oDlgTab      := MSDialog():New( 091,232,160,540,"Selecione a Empresa e a Filial",,,.F.,,,,,,.T.,,,.T. )
	oPanelTab    := TPanel():New( 000,000,"",oDlgTab,,.F.,.F.,,,148,036,.T.,.F. )
	oSayC      := TSay():New( 009,006,{||"Empresa"},oPanelTab,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,029,008)
	oSayR      := TSay():New( 022,011,{||"Filial"},oPanelTab,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,023,008)

	oBtnOk     := TButton():New( 006,107,"Ok",oPanelTab,@bOk2,037,012,,,,.T.,,"",,,,.F. )
	oBtnCc     := TButton():New( 020,107,"Cancelar",oPanelTab,@bCancel2,037,012,,,,.T.,,"",,,,.F. )

	oGtCons    := TGet():New( 008,036,{|u|if(PCount()>0,cCodEmp:=u,cCodEmp)},oPanelTab,060,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,Iif(_lConect,"EMP",Nil),"cCodEmp",,)
	oGtCons:bValid := {|| IIF(cCodEmp <> Space(2), .T., .F.)}

	oGtReve    := TGet():New( 021,036,{|u|if(PCount()>0,cCodFil:=u,cCodFil)},oPanelTab,060,008,'@!',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,Iif(_lConect,"DLB",Nil),"cCodFil",,)
	oGtReve:bValid := {|| IIF(cCodFil <> Space(6), .T., .F.)}

	oDlgTab:Activate(,,,.T.)

Return (lSair)

Static Function SetaEmp()

	RpcClearEnv()
	RpcSetType( 2 )
	RpcSetEnv(cCodEmp, cCodFil)
	
	_lConect := .T.
	
	oDlgTab:End()

Return