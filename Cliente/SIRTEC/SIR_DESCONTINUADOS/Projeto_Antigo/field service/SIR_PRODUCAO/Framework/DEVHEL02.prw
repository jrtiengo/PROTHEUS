#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DEVHEL02  º Autor ³ HELITOM SILVA      º Data ³  19/03/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Executa comandos advpl em tempo de execução                 º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Fabrica TOTVS                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

//Escrito por Helitom Silva em 19 de Marco de 2012
//Este programa executa comandos advpl em tempo de execução

User Function DEVHEL02(p_lConAuto)

  Local   oFont := TFont():New('Courier',,-8,,.f.)
  Local   xMsg  := "Comando para Execução"

  Private cSay2    := Space(1)
  Private cMGetObs
  Private nHndTcp  := 0
  Private cCodEmp  := "99"
  Private cCodFil  := Padr("01", 8)
  Private cEOL     := "CHR(13)+CHR(10)"
  Private _lConect := .f.

  Default p_lConAuto := .T.
  
  If Empty(cEOL)
	 cEOL := CHR(13)+CHR(10)
  Else
     cEOL := Trim(cEOL)
     cEOL := &cEOL
  Endif

  OkLeTxt()
  CarrConfig()

	If .not. MsgSelEmp(p_lConAuto)
	   Return
	EndIf

  //_ConectBanco()

  bExec 		:= {|| Processa({|| fExecutar()}, "Aguarde... Executando Comando(s).","Executando", .F. )}
  bOk2  		:= {|| __FechaExec()}
  bTrocEmp  := {|| Iif(MsgSelEmp(),'Troca efetuada com Sucesso!', 'Não conseguiu trocar, tente novamente!')}

  SetPrvt("oDlg2","oPanel2","oSay2","oLBox1","oBtn1","oBtn2","oBtn3")

  oDlg2    := MSDialog():New( 199,416,345,0993,"Processador de Comandos ADVPL",,,.F.,,,,,,.T.,,,.T. )
  oPanel2  := TPanel():New( 000,000,"",oDlg2,,.F.,.F.,,,291,077,.T.,.F. )
  oSayMsg  := TSay():New( 004,004,{|| xMsg},oPanel2,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,284,008)
  oMGetObs := TMultiGet():New( 012,004,{|u| If(PCount()>0,cMGetObs:=u,cMGetObs)},oPanel2,234,061,,,CLR_BLACK,CLR_WHITE,,.T.,"",,,.F.,.F.,.F.,,,.F.,,  )
  oBtn2    := TButton():New( 012,246,"Executar",oPanel2,@bExec,037,012,,,,.T.,,"",,,,.F. )
  oBtn2:SetFocus()
  oBtn1    := TButton():New( 026,246,"Fechar",oPanel2,@bOk2,037,012,,,,.T.,,"",,,,.F. )
  oBtn3    := TButton():New( 040,246,"Trocar Emp./Fil.",oPanel2,@bTrocEmp,037,024,,,,.T.,,"",,,,.F. )
  
  oDlg2:Activate(,,,.T.,{|| __Desconect()})
  
Return

Static Function _ConectBanco()

	Local cTipo      := ""
	Local cBanco     := ""
	Local cServer    := ""
	Local cServerIni := ""

	cServerIni := "appserver.ini"

	If Empty( AllTrim ( cTipo + cBanco + cServer ) )
		cTipo   := GetPvProfString( "TopConnect", "Database", "", cServerIni )
		cBanco  := GetPvProfString( "TopConnect", "Alias"   , "", cServerIni )
		cServer := GetPvProfString( "TopConnect", "Server"  , "", cServerIni )
	EndIf

	If Empty( AllTrim ( cTipo + cBanco + cServer ) )
		cTipo   := GetPvProfString( "DBAccess", "Database", "", cServerIni )
		cBanco  := GetPvProfString( "DBAccess", "Alias"   , "", cServerIni )
		cServer := GetPvProfString( "DBAccess", "Server"  , "", cServerIni )
	EndIf

	If Empty( AllTrim ( cTipo + cBanco + cServer ) )
		cTipo   := GetSrvProfString( "TopDatabase", "" )
		cBanco  := GetSrvProfString( "TopAlias"   , "" )
		cServer := GetSrvProfString( "TopServer"  , "" )
	EndIf

	nHndTcp := TcLink( cTipo+"/"+cBanco,cServer,7890)

	If nHndTcp < 0
		UserException("Erro ("+Substr(Str(nHndTcp),1,4)+") ao conectar...")
	EndIf

	Set deleted off

	#IFDEF TOP
	    TCInternal( 5, '*OFF' ) // Desliga Refresh no Lock do Top
	#ENDIF

	RpcClearEnv()
	RpcSetType( 2 )
	RpcSetEnv(cCodEmp, cCodFil)

Return

Static Function __Desconect()
   GrvComands()
   If nHndTcp > 0
	  TcUnLink(nHndTcp)
   EndIf
Return .t.

Static Function __FechaExec()
   oDlg2:End()
Return .t.

Static Function OkLeTxt

	Local nTamFile, nTamLin, cBuffer, nBtLidos, cTxtLin
	Private cArqTxt := "C:\Temp\Log.txt"
	Private nHdl    := fOpen(cArqTxt,68)

    If !File(cArqTxt)
	   Return
	EndIf

	If nHdl == -1
	    MsgAlert("O arquivo de nome "+cArqTxt+" nao pode ser aberto! Verifique os parametros.","Atencao!")
	    Return
	Endif

	nTamFile := fSeek(nHdl,0,2)
	fSeek(nHdl,0,0)
	nTamLin  := 72+Len(cEOL)
	cBuffer  := Space(nTamLin) // Variavel para criacao da linha do registro para leitura
	cTxtLin := ""

	nBtLidos := fRead(nHdl, cBuffer, nTamLin) // Leitura da primeira linha do arquivo texto

	cTxtLin := alltrim(SUBSTR(cBuffer, 1, nTamLin))

	ProcRegua(nTamFile) // Numero de registros a processar

	While nBtLidos >= nTamLin
	    IncProc()

	    nBtLidos := fRead(nHdl, @cBuffer, nTamLin) // Leitura da proxima linha do arquivo texto

		cTxtLin += alltrim(SUBSTR(cBuffer, 1, nTamLin))

	    FT_FSKIP() //dbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ O arquivo texto deve ser fechado, bem como o dialogo criado na fun- ³
	//³ cao anterior.                                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	fClose(nHdl)

	cMGetObs := cTxtLin

Return

Static Function GrvComands()

   Local cDadosEmp := ''

   cDadosEmp := padr('cCodEmp = ' + cCodEmp + '', 60) + cEOL
   cDadosEmp += padr('cCodFil = ' + cCodFil + '', 60) + cEOL

   MemoWrite('C:\Temp\Config.txt', cDadosEmp)
   MemoWrite('C:\Temp\Log.txt', cMGetObs)

Return

Static Function fExecutar

	Local nLines   := 0
	Local cComando := ''
	Local cLinCod  := ''
	Local	nX			:= 0
	// Salva bloco de código do tratamento de erro - Fonte: http://tdn.totvs.com/home#9598
	Local oError := ErrorBlock({|e|  Iif(MsgYesNo("Mensagem de Erro: " + chr(10) + e:Description + chr(13) + 'Desculpe alguns comandos não são aceitos!' + chr(13) + 'Deseja Continuar?'),.T.,.F.)})

	nLines := MLCount(cMGetObs)
	
	If !_lConect
		If .not. MsgSelEmp()
		   Return
		EndIf
	EndIf
	
   GrvComands()

   ProcRegua(nLines)

	If nLines > 0
		For nX := 1 To nLines

	        IncProc()

		    cLinCod := alltrim(MemoLine(cMGetObs,, nX))

		    If Empty(cComando)
		       If .Not. alltrim(cLinCod) = ''
			      cComando += cLinCod
			   EndIf
			Else
		       If .Not. alltrim(cLinCod) = ''
			      cComando += ' , ' + cLinCod
			   EndIf
			EndIf
		Next nX
	EndIf

   If .Not. Empty(cComando)
	   MemoWrite("C:\Temp\LogExecução.txt", cComando)

	   eval({|| &(cComando)})
	EndIf

   ErrorBlock(oError)

Return

Static Function MsgSelEmp(p_lConAuto)

	Local lSair := .t.

   Default p_lConAuto := .F.
  
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

	oDlgTab:Activate(,,,.T.,,,{|| Iif(p_lConAuto, oBtnOk:Click(), Nil)})

Return (lSair)

Static Function SetaEmp()

	RpcClearEnv()
	RpcSetType( 2 )
	RpcSetEnv(cCodEmp, cCodFil)

	_lConect := .t.

   cDadosEmp := padr('cCodEmp = ' + cCodEmp + ' ', 60) + cEOL
   cDadosEmp += padr('cCodFil = ' + cCodFil + ' ', 60) + cEOL

   MemoWrite('C:\Temp\Config.txt', cDadosEmp)

	oDlgTab:End()

Return

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
	nTamLin  := 60+Len(cEOL)
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