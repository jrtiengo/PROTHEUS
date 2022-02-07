#Include 'Protheus.ch'

#DEFINE	CR	Chr(13) + Chr(10)

/*{Protheus.doc} RUNUPD
	
@author Evandro Vendrametto
@since 25/11/2013
@version 1.0		

@return ${Nil}, ${Nil}

@description Selecionar os compatibilizadores que deseja executar.

Alterações:
Helitom Silva 27/11/2013 - Incluido uso da DbGrid e Conexão com empresa Inicial.
Helitom Silva 24/12/2013 - Incluido Pe e Combobox para selação de Grupos de Compatibilizadores.

*/
User Function RUNUPD()
	
	Local cRotina 	:= "Compatibilizador de Usuário."	
	Local nSuperior	:= 051
	Local nEsquerda	:= 000
	Local nInferior	:= 150
	Local nDireita	:= 300		

	Private _lConect  := .F.	
	Private cCodEmp   := '99'
	Private cCodFil   := '01'
	
	Private lExistPe	:= ExistBlock('RUNUPDPE') 
	Private aItGrupo	:= {}
	Private nItGrupo	:= 0
	Private cCompatib	:= Space(8)
	Private aHeader	:= {}
	Private aCols		:= {}		 			

	SetPrvt("oWindow","oDbGrid","oGetGrupo","oCombGrupo")	
		
	CarrConfig()
     		
	//Conexao com empresa Inicial para ter acesso as demais, pois as vezes alguns clientes não tem a empresa 99
	If !MsgSelEmp()
		Return
	EndIf	
	
	aHeader	:= MontaHeader()
	
	oWindow	:= MsDialog():New(000, 000, 350, 600, cRotina,,,.F.,,,,,,.T.,,,.T.)
	
	TSay():Create(oWindow,{||'Grupo Updates: '},  30, 10,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)

	If lExistPe
		
		aItGrupo := ExecBlock('RUNUPDPE', .F., .F.)
		
		If !Len(aItGrupo) > 0
			MsgInfo('Atenção o PE: RUNUPDPE não retornou Grupo(s) de Compatibilizadores, por favor exclua-o do RPO ou corrija-o para que retorne os Grupos!')
			Return
		EndIf
		
		oCombGrupo := TComboBox():New( 30,60,{|u| If(PCount()>0,cCompatib:=u,cCompatib)},aItGrupo,200,010,oWindow,,,,CLR_BLACK,CLR_WHITE,.T.,,"",,,,,,,cCompatib )		
		
		oCombGrupo:bChange := {|| MontaCols()}
	
		oCombGrupo:SetFocus()
		
	Else		
	
		oGetGrupo := TGet():New(30,60,	{|u| If(PCount()>0, cCompatib := u, cCompatib )},oWindow,030,009,"@!",,CLR_BLACK,CLR_WHITE,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cCompatib")
							   
		oGetGrupo:bChange	:= {|| MontaCols() }
		
		oGetGrupo:SetFocus()
		
	EndIf
	
	oDbGrid	:= DbGrid():Create(nSuperior,nEsquerda,nInferior,nDireita,/*/GD_INSERT+GD_DELETE+GD_UPDATE/*/,;
	 					,,,,,,,,;
	 					, oWindow, aHeader, aCols, 1, 0)
	
	TButton():New(155,090,"&Ok",		oWindow,{|| ExecUPDs(), oWindow:End() },040,015,,,,.T.,,"",,,,.F.)
	TButton():New(155,150,"&Fechar",	oWindow,{|| oWindow:End() },	040,015,,,,.T.,,"",,,,.F.)
		
	If lExistPe
		Eval(oCombGrupo:bChange)
	EndIf
			
	oWindow:lCentered := .T.	
	oWindow:Activate() 
		
Return

Static Function MontaHeader()
	
	aAdd(aHeader, {"Funcao",	"FUNC" , 	"@!", 		10,	0,"" ,,"C" ,,,,,,"V",,,.F.})
	aAdd(aHeader, {"Descricao",	"DESC" , 	"@!",		50,	0,"" ,,"C" ,,,,,,"V",,,.F.})
	
Return aHeader

Static Function MontaCols()
	
	Local N			:= 1 
	Local nX			:= 0
	Local nY			:= 0	
	Local aArrayRet	:= {}
	
	If ExistBlock(cCompatib)			
		
		aArrayRet := ExecBlock(cCompatib)
		
		If !Empty(aArrayRet)				
		
			aSize(oDbGrid:aCols, 0)                                                         	
			
			For nX := 1 to Len(aArrayRet) 										
				// Inicializando aCols
				aAdd(oDbGrid:aCols, Array(Len(oDbGrid:aHeader) + 1))									
			
				// Preenche o acols	 
				oDbGrid:aCols[nX, 1] := oDbGrid:hoNo 
				oDbGrid:aCols[nX, 2] := aArrayRet[nX, 1]
				oDbGrid:aCols[nX, 3] := aArrayRet[nX, 2]	
						
				oDbGrid:aCols[nX, len(oDbGrid:aheader) + 1] := .F.    
											
			Next
			
			oDbGrid:Refresh()			
		
		Else						
			MsgInfo("Verifique o grupo do Update!!!")
			
			If lExistPe
				oCombGrupo:SetFocus()
			Else
				oGetGrupo:SetFocus()
			EndIf
					
		EndIf	
	Else	
		aSize(oDbGrid:aCols, 0) 
		oDbGrid:Refresh()	
		  
		MsgInfo("Não foi encontrada a função: " + cCompatib)			
	EndIf
	 
Return

Static Function ExecUPDs()
	
	Local _i			:= 0 	
	Local _n			:= 0
	Local aEmpresas 	:= {}	
	Local aRetDados	:= {}
	
	For _i := 1 To Len(oDbGrid:aCols)
		//Verifica os marcados.	
		If oDbGrid:Marcado(_i) .and. !Empty(oDbGrid:aCols[_i, 2])
			aAdd(aRetDados, {oDbGrid:aCols[_i, 2]})			 
		EndIf
	
	Next _i
	
	If !Empty(aRetDados) 
		//Retorna as empresas selecionadas.
		aEmpresas 	:= U_DEVUPD0()	
		
		For _n := 1 To Len(aRetDados)
			//Executa a Update dos marcados.			
			U_DEVUPD1(aEmpresas, aRetDados[_n][1])			
		Next _n
		
		MsgAlert("Finalizou!")	
	Else
		MsgAlert('Nenhum compatibilizador válido marcado!')
	EndIf
	
Return Nil

//Funcao MsgSelEmp
//Autor Helitom Silva
//Data 27/11/2013
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

//Funcao SetaEmp
//Autor Helitom Silva
//Data 27/11/2013
Static Function SetaEmp()

	RpcClearEnv()
	RpcSetType( 2 )
	RpcSetEnv(cCodEmp, cCodFil)

	_lConect := .t.

   cDadosEmp := padr('cCodEmp = ' + cCodEmp + ' ', 60) + CR
   cDadosEmp += padr('cCodFil = ' + cCodFil + ' ', 60) + CR

   MemoWrite('C:\Temp\Config.txt', cDadosEmp)

	oDlgTab:End()

Return

//Funcao CarrConfig
//Autor Helitom Silva
//Data 27/11/2013
Static Function CarrConfig()

	Local nTamFile, nTamLin, cBuffer, nBtLidos, cTxtLin, cDLinha
	Local lEnc := .f.
	Local nK   := 0

	Private cArqConf := "C:\Temp\Config.txt"
	Private nHdl     := fOpen(cArqConf,68)

	If !File(cArqConf)
	   Return
	EndIf

	If nHdl == -1
	    MsgAlert("O arquivo de nome "+cArqTxt+" nao pode ser aberto! Verifique os parametros.","Atencao!")
	    Return
	Endif

	nTamFile := fSeek(nHdl,0,2)
	fSeek(nHdl,0,0)
	nTamLin  := 60+Len(CR)
	cBuffer  := Space(nTamLin) // Variavel para criacao da linha do registro para leitura
	cTxtLin	 := ""

	nBtLidos := fRead(nHdl,cBuffer,nTamLin) // Leitura da primeira linha do arquivo texto

	cTxtLin  := alltrim(SUBSTR(cBuffer, 1, nTamLin))

	ProcRegua(nTamFile) // Numero de registros a processar

	cCodEmp	 := ''
	cCodFil  := ''

	While nBtLidos >= nTamLin

		IncProc()
		IEnc := .f.

		If UPPER("cCodEmp") $ alltrim(UPPER(cTxtLin))
			For nK := 1 to Len(cTxtLin)
				 If Substr(cTxtLin, nK, 1) = '='
				 	 IEnc := .t.
				 EndIf
				 If IEnc = .t. .and. !(Substr(cTxtLin, nK, 1) = '=') .and. !(Substr(cTxtLin, nK, 1) = ' ')
				 	 cCodEmp += Substr(cTxtLin, nK, 1)
				 EndIf
				 If !Empty(cCodEmp) .and. (Substr(cTxtLin, nK, 1) = ' ')
				 	  Exit
				 EndIf
			Next
		EndIf

		If UPPER("cCodFil") $ alltrim(UPPER(cTxtLin))
			For nK := 1 to Len(cTxtLin)
				 If Substr(cTxtLin, nK, 1) = '='
				 	 IEnc := .t.
				 EndIf
				 If IEnc = .t. .and. !(Substr(cTxtLin, nK, 1) = '=') .and. !(Substr(cTxtLin, nK, 1) = ' ')
				 	 cCodFil += Substr(cTxtLin, nK, 1)
				 EndIf
				 If !Empty(cCodFil) .and. (Substr(cTxtLin, nK, 1) = ' ')
				 	  Exit
				 EndIf
			Next
		EndIf

	   nBtLidos := fRead(nHdl, @cBuffer, nTamLin) // Leitura da proxima linha do arquivo texto

		cTxtLin  := alltrim(SUBSTR(cBuffer, 1, nBtLidos))

	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ O arquivo texto deve ser fechado, bem como o dialogo criado na fun- ³
	//³ cao anterior.                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	fClose(nHdl)

Return