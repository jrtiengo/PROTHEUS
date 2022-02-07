#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE 'TOPCONN.CH'

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DEVHEL04  º Autor ³ HELITOM SILVA      º Data ³  16/08/2012 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Atualizacao da estrutura de banco conforme o dicionario de  º±±
±±º          ³dados SX2 e SX3                                             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Fabrica TOTVS                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function DEVHEL04()

	Private cEOL     := "CHR(13)+CHR(10)"

	// Declaração de cVariable dos componentes
	Private cGetTable  := Space(3)
	Private lCBoxTodas := .F.
	Private cCodEmp  := "99"
	Private cCodFil  := Padr("01", 8)
	Private cEOL     := "CHR(13)+CHR(10)"
	Private _lConect := .f.

	If Empty(cEOL)
		cEOL := CHR(13)+CHR(10)
	Else
		cEOL := Trim(cEOL)
		cEOL := &cEOL
	Endif

	//HCONNECT()

	CarrConfig()

	If .not. MsgSelEmp()
	   Return
	EndIf

	bAtual := {|| ExecAtu()}

	// Declaração de Variaveis Private dos Objetos

	SetPrvt("oDlg1","oPanel1","oGrp1","oGetTable","oBtAtu","oGrp2","oCBoxTodas")


	// Definicao do Dialog e todos os seus componentes.

	oDlg1      := MSDialog():New( 091,232,161,644,"Atualizador de Estruturas de Tabelas no Banco de Dados",,,.F.,,,,,,.T.,,,.T. )
	oPanel1    := TPanel():New( 000,000,"",oDlg1,,.F.,.F.,,,200,028,.T.,.F. )

    //GroupBox Atualizar Todas as Tabelas
    oGrp2      := TGroup():New( 004,004,024,068," Atualizar ",oPanel1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oCBoxTodas := TCheckBox():New( 012,008,"Todas as Tabelas",{|u| If(PCount()>0,lCBoxTodas:=u,lCBoxTodas)},oGrp2,056,008,,,,,CLR_BLACK,CLR_WHITE,,.T.,"",, )

	//GroupBox Atualizar Somente a Tabela
	oGrp1      := TGroup():New( 004,072,025,144,"Atualizar Somente a Tabela ",oPanel1,CLR_BLACK,CLR_WHITE,.T.,.F. )
	oGetTable  := TGet():New( 012,076,{|u| If(PCount()>0,cGetTable:=u,cGetTable)},oGrp1,065,008,'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGetTable",,)

	//Botao Atualizar
	oBtAtu     := TButton():New( 008,153,"Atualizar",oPanel1,bAtual,037,012,,,,.T.,,"",,,,.F. )

	oDlg1:Activate(,,,.T.)

Return

Static Function ExecAtu()

	If .not. MsgSelEmp()
	   MsgInfo('Não foi possivel se conectar na Empresa e Filial informada')
	   Return
	EndIf

    //Processa({|| AtuBanco()}, 'Aguarde Atualizando Banco de Dados Conforme Estrutura SX2, SX3..', 'Atualização do Banco de Dados', .T. )
	RptStatus( {|| AtuBanco()},'Aguarde Atualizando Banco de Dados Conforme Estrutura SX2, SX3, SIX..', 'Atualização do Banco de Dados', .T. )

Return

Static Function ATUBANCO()

  Local iCont := 0
  Local i      := 0

  If lCBoxTodas = .t.
	  DbSelectArea('SX2')
	  SX2->(DbGoTop())

	  //Conta Registros da Query
	  SX2->(DbEval({|| i++},,))

	  SetRegua(i)

	  SX2->(DbGoTop())
	  While SX2->(!EOF())
	    //IncProc('Processandro Tabela: ' + alltrim(str(iCont++)) + ' de ' +  alltrim(str(i)))
	    IncRegua()
		
         DbselectArea('SX3')
         SX3(DbSetOrder(1))
         SX3->(DbGoTop())
         If SX3->(dbSeek(Substr(SX2->X2_ARQUIVO,1,3)))  
	    	   ATUTABELA(Substr(SX2->X2_ARQUIVO,1,3))
         EndIf
	    
	    SX2->(DbSkip())
	  End
	  
  ElseIf cGetTable <> ""
  
	  DbSelectArea('SX2')
  	  SX2->(DbSetOrder(1))
	  SX2->(DbGoTop())
	  
	  If SX2->(dbSeek(cGetTable))
	  	 SetRegua(1)
	  	 ATUTABELA(cGetTable)
	  	 IncRegua()
	  Else
		 MsgInfo('Arquivo ' + cGetTable + ' não encontrado! ')
		 Return
	  EndIf
	  
  EndIf

Return

Static Function ATUTABELA(PTABELA)
	
	Local cComand := ''
	
	// Salva bloco de código do tratamento de erro - Fonte: http://tdn.totvs.com/home#9598
	Local oError := ErrorBlock({|e|  Iif(MsgYesNo("Mensagem de Erro: " + chr(10) + e:Description + chr(13) + 'Desculpe alguns comandos não são aceitos!' + chr(13) + 'Deseja Continuar?'),.T.,.F.)})
	
	TcInternal( 25, 'CLOB' )
	
	X31UpdTable( PTABELA )
	
	cComand := 'DbSelectArea("' + AllTrim(PTABELA) + '"), ("' + AllTrim(PTABELA) + '")->(DbCloseArea())'
	eVal({|| &(cComand)})
	
	If __GetX31Error()
	   MsgAlert(__GetX31Trace())
	EndIf
	
	TcInternal( 25, 'OFF' )
	
	ErrorBlock(oError)
	   
Return

Static Function MSGSELEMP()

	Local lSair := .t.

  	bOk2 := {|| IIF(cCodEmp <> Space(2) .or. cCodFil <> Space(8), SETAEMP(.t.), msgInfo('Por favor, informe a Empresa e a Filial!'))  }
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

Static Function SETAEMP(pFechaMsg)

   Default pFechaMsg := .f.

   RpcClearEnv()
	RpcSetType( 2 )
	RpcSetEnv(cCodEmp, Alltrim(cCodFil))

	_lConect := .t.
	GrvComands()

	If pFechaMsg = .t.
	   oDlgTab:End()
	EndIf

Return

Static Function HCONNECT()

   Local cTipo     := ""
   Local cBanco    := ""
   Local cServer   := ""
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
		nHndTcp := TcLink( cTipo+"/"+cBanco, cServer, 7891)
	EndIf

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

Static Function GrvComands()
	Local cDadosEmp := ''

	cDadosEmp := padr("cCodEmp = " + cCodEmp + " ", 60) + cEOL
	cDadosEmp += padr("cCodFil = " + cCodFil + " ", 60) + cEOL

	MemoWrite('C:\Temp\Config.txt', cDadosEmp)
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