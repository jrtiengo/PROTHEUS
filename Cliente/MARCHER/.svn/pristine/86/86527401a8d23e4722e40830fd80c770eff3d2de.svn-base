#Include "Protheus.ch"
#Include "Rwmake.ch"
#Include "Topconn.ch"
#INCLUDE "TBICONN.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ Imp_SB1     ºAutor  ³Celso Rene     º Data ³    17/07/14  	º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Importacao Limite de Credito   		   						º±±
±±º          ³ Tarefa: 9824                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Schneider-Electric                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function Imp_SB1()

Private oDlg1 //tela 1
Private oDlg2 //tela importacao
Private oDlg3 //tela exportacao

Private oButton1
Private oButton2
Private oButton3
Private oGet1
Private oGet2
Private oGet3
Private cGet1 		:= Space(5) //"Define variable value"
Private cGet2 		:= Space(130) //"Define variable value"
Private cGet3 		:= Space(5) //"Define variable value"
Private oGet2
Private oGet4
Private oSay1
Private oSay2
Private oSay3
Private oSay4

Private _lReturn	:= .F. //Usada na validação de senha
Private	oTButton1 	:= Nil
Private	oTButton2 	:= Nil



//Verificação via senha - solic. Glaucia Ziegler
#IFDEF TOP
    IF !fDigSenha()
       Return
    Endif
#ELSE
    MsgStop("Essa rotina funciona somente no ambiente TOP.")
    Return
#ENDIF


//Tela inicial - Importa ou Exporta Dados
DEFINE DIALOG oDlg TITLE "MARCHER - IMPORT/EXPORT PRODUTOS" FROM 180,180 TO 350,480 PIXEL

oTButton1 := TButton():New(10,010,"EXPORTAR"	,oDlg,{|| Exporta() },60,20,,,.F.,.T.,.F.,,.F.,,,.F. )
oTButton2 := TButton():New(10,080,"IMPORTAR"	,oDlg,{|| Importa() },60,20,,,.F.,.T.,.F.,,.F.,,,.F. )

ACTIVATE DIALOG oDlg CENTERED


Return


//===================================================================================================================================================//
// ROTINAS DE EXPORTAÇÃO PARA EXCEL - MARCHER - JULHO 2018 - RAFAEL SCHEIBLER = SOLUTIO IT                                                           //
//===================================================================================================================================================//
Static Function Exporta() //Exportação para Excel

Local cCabec 	:= ""
Local cDir 		:= GetSrvProfString ("STARTPATH","") // Retorna o StartPath definido no ini do server
Local cPath		:= GetTempPath()
Local cDia   	:= SUBSTR(DTOS(DATE()),7,2)
Local cMes   	:= SUBSTR(DTOS(DATE()),5,2)
Local cAno   	:= SUBSTR(DTOS(DATE()),1,4)

Local cCrLf      := Chr(13) + Chr(10)
Local nX
Local nHandle

Private aCabExcel 	:={}
Private aItensExcel :={}
Private _cAliasX3 	:= GetNextAlias()

//DbSelectArea("SX3")
//DbSetOrder(1)
//MsSeek("SB1")

/*While SX3->(!EOF()) .AND. SX3->X3_ARQUIVO == "SB1"

	IF SX3->X3_TIPO <> 'M' .AND. SX3->X3_CONTEXT <> 'V' .AND. X3USO(SX3->X3_USADO) .OR. ("_FILIAL" $ SX3->X3_CAMPO .OR. "B1_EMIN" $ SX3->X3_CAMPO)
		// AADD(aCabExcel, {"TITULO DO CAMPO", "TIPO"      , NTAMANHO       , NDECIMAIS      , PICTURE})
		   AADD(aCabExcel, {alltrim(SX3->X3_CAMPO), SX3->X3_TIPO, SX3->X3_TAMANHO, SX3->X3_DECIMAL, SX3->X3_PICTURE})
	ENDIF

	SX3->(DBSkip())

EndDo*/

	///////////////////////////
	OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cAliasX3,"SX3",Nil,.F.)
	lOpen := Select(_cAliasX3) > 0	
	if (lOpen)
		dbSelectArea(_cAliasX3)
		(_cAliasX3)->(dbSetOrder(1))
		(_cAliasX3)->(dbSeek("SB1"))
		While ( !(_cAliasX3)->(Eof()) .And. (_cAliasX3)->X3_ARQUIVO == "SB1" )
			if (_cAliasX3)->X3_TIPO <> 'M' .AND. (_cAliasX3)->X3_CONTEXT <> 'V' .AND. X3USO((_cAliasX3)->X3_USADO) .OR. ("_FILIAL" $ (_cAliasX3)->X3_CAMPO .OR. "B1_EMIN" $ (_cAliasX3)->X3_CAMPO)
			   AADD(aCabExcel, {alltrim((_cAliasX3)->X3_CAMPO), (_cAliasX3)->X3_TIPO, (_cAliasX3)->X3_TAMANHO, (_cAliasX3)->X3_DECIMAL, (_cAliasX3)->X3_PICTURE})
			endif 
		(_cAliasX3)->(DBSkip())
		EndDo
	endif
	(_cAliasX3)->(dbCloseArea())
	//////////////////////////


MsgRun("Favor Aguardar.....", "Selecionando os Registros",{|| GProcItens(aCabExcel, @aItensExcel)})

//Gravação TXT
cArqXls	:= "Produtos_" + cvaltochar(cDIa) + "-" + cvaltochar(cMes) + "-" + cvaltochar(cAno) + ".CSV"
nHandle := MsfCreate(cDir+cArqXls,0)

If nHandle > 0

	// Grava o cabecalho do arquivo
	aEval(aCabExcel, {|e, nX| fWrite(nHandle, e[1] + If(nX < Len(aCabExcel), ";", "") ) } )
	fWrite(nHandle, cCrLf ) // Pula linha

	for x:=1 to len(aItensExcel)

		_uLinha := ""
		For y:=1 to len(aCabExcel)

			if y < len(aCabExcel)
				if aCabExcel[y][2] == "D"
					_uLinha += DTOC(aItensExcel[x][y]) + ";"
				elseif aCabExcel[y][2] == "N"
					_uLinha += cValtoChar(aItensExcel[x][y])+ ";"
				else
					_uLinha += alltrim(aItensExcel[x][y]) + ";"
				endif
			else
				if aCabExcel[y][2] == "D"
					_uLinha += DTOC(aItensExcel[x][y])
				elseif aCabExcel[y][2] == "N"
					_uLinha += cValtoChar(aItensExcel[x][y])
				else
					_uLinha += alltrim(aItensExcel[x][y])
				endif
			endif

		Next y

		 fWrite(nHandle, _uLinha + cCrLf )

	Next x

	fClose(nHandle)

    CpyS2T( cDir+cArqXls , cPath, .T. ) //copia para o temp do user

	If FERASE(cDir+cArqXls) == -1 //apago arquivo do system
		MsgStop('Falha na deleção do Arquivo da pasta SYSTEM.')
	Endif

     If ! ApOleClient( 'MsExcel' )
     	MsgAlert( 'MsExcel nao instalado')
     	Return
     EndIf

     oExcelApp := MsExcel():New()
     oExcelApp:WorkBooks:Open( cPath+cArqXls ) // Abre uma planilha
     oExcelApp:SetVisible(.T.)

     MsgInfo ( "Exportação concluída com sucesso! Arquivo: " + cCrLf + cPath+cArqXls, "Informação" )

Else
	MsgAlert("Falha na criação do arquivo.")
Endif

Return


//--------------------------------------------------------------------------//
Static Function GProcItens(aHeader, aCols)

Local aItem
Local nX

DbSelectArea("SB1")
DbSetOrder(1)
SB1->(DbGotop())

While SB1->(!EOF())

	aItem := Array(Len(aHeader))

	For nX := 1 to Len(aHeader)
		IF aHeader[nX][2] == "C"
			aItem[nX] := CHR(160)+SB1->&(aHeader[nX][1])
		ELSE
			aItem[nX] := SB1->&(aHeader[nX][1])
		ENDIF
	Next nX

	AADD(aCols,aItem)
	aItem := {}
	SB1->(dbSkip())

EndDo

Return


//===================================================================================================================================================//
// ROTINAS DE IMPORTAÇÃO PARA EXCEL - MARCHER - JULHO 2018 - RAFAEL SCHEIBLER = SOLUTIO IT                                                           //
//===================================================================================================================================================//
Static Function Importa()

DEFINE MSDIALOG oDlg2 TITLE "Importando - Dados Cadastro de Produtos" FROM 000, 000  TO 200, 420 COLORS 0, 16777215 PIXEL


@ 028, 011 SAY oSay3 PROMPT "Caminho Arq:" SIZE 104, 011 OF oDlg2 COLORS 0, 16777215 PIXEL
@ 025, 060 MSGET oGet2 VAR cGet2 SIZE 097, 012 OF oDlg2 COLORS 0, 16777215 PIXEL
@ 028, 160 BUTTON oButton1 PROMPT "..." SIZE 019, 010 OF oDlg2 PIXEL action PesqArq()
@ 074, 045 BUTTON oButton2 PROMPT "Processar" SIZE 050, 015 OF oDlg2 PIXEL Action Process()
@ 074, 118 BUTTON oButton3 PROMPT "Limpar Campo" SIZE 050, 015 OF oDlg2 PIXEL Action (_Limpa())

ACTIVATE MSDIALOG oDlg2 CENTERED

Return()


//======================================================//
Static Function Process()

Local oFile
Local nLinha := 0
Local aDadImp := {}
Local lCab := .f.
Local aErros := {}

//Classe FW para leitura de CSV
//Antiga classe possui limitação de 1022bytes por linha
oFile := FWFileReader():New(cGet2)

if (oFile:Open())
	While (oFile:hasLine())
		nLinha ++
		if nLinha == 1 //Cabeçalho
			AADD(aDadImp,StrTokArr(oFile:GetLine(),";")) //Criação do Array de cabeçalho
			_nTamCab := len(aDadImp[1])
			IF "B1_FILIAL" <> ALLTRIM(aDadImp[1][1]) .AND. "B1_COD" <> ALLTRIM(aDadImp[1][2])
				Alert("Processo abortado, pois o arquivo não possui um cabeçalho válido! Verifique o arquivo!!!")
				Close( oDlg2 )
				Return
			ENDIF
		else
			AADD(aDadImp,StrTokArr(oFile:GetLine(),";")) //Criação do Array de dados
			IF len(aDadImp[nLinha]) < _nTamCab
				_nDif := _nTamCab - len(aDadImp[nLinha])
				for i:=1 to _nDif
					AAdd(aDadImp[nLinha]," ")
				Next i
			ENDIF
		endif
	EndDo
   oFile:Close()
endif


//Inicio da Validação dos Dados
nColFim:= len(aDadImp[1]) //Nro de colunas do primeiro registro

For nColuna:=1 to nColFim

	//Acerto dos dados conforme tipo de dados
	/*DBSelectArea("SX3")
	DBSetOrder(2)//X3_CAMPO
	MsSeek(aDadImp[1][nColuna])
	if found()
		cTipo := SX3->X3_TIPO
		nTam  := SX3->X3_TAMANHO
		nDec  := SX3->X3_DECIMAL
		cPic  := ALLTRIM(SX3->X3_PICTURE)
	endif
	*/
	
	////////////////////////
	_cSX32 := GetNextAlias()
	OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX32,"SX3",Nil,.F.)
	lOpen := Select(_cSX32) > 0	
	If (lOpen)
		dbSelectArea(_cSX32)
		(_cSX32)->(dbSetOrder(2)) //X3_CAMPO
		(_cSX32)->(dbSeek(aDadImp[1][nColuna]))
		if (Found())
			cTipo := (_cSX32)->X3_TIPO
			nTam  := (_cSX32)->X3_TAMANHO
			nDec  := (_cSX32)->X3_DECIMAL
			cPic  := ALLTRIM((_cSX32)->X3_PICTURE)
		endif
	endif
	(_cSX32)->(dbCloseArea())
	///////////////////////////////

	For nLinha:= 2 to len(aDadImp)
		if cTipo == "C"

			cConteudo := aDadImp[nLinha][nColuna]

			While asc(substr(cConteudo,1,1)) == 160 .or. asc(substr(cConteudo,1,1)) == 34
				cConteudo := substr(cConteudo,2,len(cconteudo))
			EndDo

			//Tratamento simbolo de polegadas
			cConteudo := StrTran( cConteudo, '""', '!@')
			cConteudo := StrTran( cConteudo, '"', '')
			cConteudo := StrTran( cConteudo, '!@', '"')
			//tratamento do primeiro caractere em branco

			aDadImp[nLinha][nColuna] := PadR(cConteudo,nTam)

		elseif cTipo == "N"
			nValor := VAL(aDadImp[nLinha][nColuna])
			aDadImp[nLinha][nColuna] := nValor
		elseif cTipo == "D"
			dData := CTOD(aDadImp[nLinha][nColuna])
			aDadImp[nLinha][nColuna] := dData
		endif
	Next i

Next nColuna


//Processa as alterações
For nLinha:=2 to len(aDadImp)

	DBSelectArea("SB1")
	DBSetOrder(1)
	DBSeek(aDadImp[nLinha][1]+aDadImp[nLinha][2]) //Posições devem ser fixas de Filial e Código do Produto

	if found()

		 //Campos
		For nColuna:=1 to len(aDadImp[1])
			If SB1->&(aDadImp[1][nColuna]) <> aDadImp[nLinha][nColuna]
				_ContAnt := SB1->&(aDadImp[1][nColuna])
				_ContNew := aDadImp[nLinha][nColuna]

				RecLock("SB1",.f.)
					SB1->&(aDadImp[1][nColuna]) := aDadImp[nLinha][nColuna]
				MsUnlock()

				if VALTYPE( _ContAnt ) == "C"
					_clog := "Alteração Produto Código: " + alltrim(aDadImp[nLinha][2]) +" - Campo " +(aDadImp[1][nColuna])+ " - " + alltrim(_ContAnt)+ " >> " + alltrim(_ContNew) + " - Usuário: " +alltrim(cUserName)
				elseif VALTYPE( _ContAnt ) == "D"
					_clog := "Alteração Produto Código: " + alltrim(aDadImp[nLinha][2]) +" - Campo " +(aDadImp[1][nColuna])+ " - " + dtoc(_ContAnt)+ " >> " + dtoc(_ContNew) + " - Usuário: " +alltrim(cUserName)
				elseif VALTYPE( _ContAnt ) == "N"
					_clog := "Alteração Produto Código: " + alltrim(aDadImp[nLinha][2]) +" - Campo " +(aDadImp[1][nColuna])+ " - " + cvaltochar(_ContAnt)+ " >> " + cvaltochar(_ContNew) + " - Usuário: " +alltrim(cUserName)
				endif

				AADD(aErros, _clog)

			endif
		Next nColuna

	endif

Next nLinha

//Grava no TXT
IF len(aErros) > 0
	nHandle := FCREATE("\system\LogAlteracao_"+DTOS(DDATABASE)+"_"+StrTran( Time(), ":", "" )+".txt")
	If nHandle < 0
		MsgAlert("Erro durante criação do arquivo.")
	Else
		For nLinha := 1 to len(aErros)
			FWrite(nHandle, aErros[nlinha] + CRLF)
		Next nLinha
		FClose(nHandle)
	EndIf

	MSGINFO( "Importação concluída com sucesso. Log em \system\", "F.I.M !" )

ELSE
	MSGINFO( "Importação concluída com sucesso. Não há log de alterações", "F.I.M !" )
ENDIF

Close(oDlg2)//fecha janela de importação
Close(oDlg)

Return



//----------------------------------------------------------
Static Function PesqArq()

Private cNomArq:= ""

cNomArq := cGetFile("*.csv","Selecione o Arquivo a ser importado...",1,"C:\",.T.,16,.F.)
cGet2:=Alltrim(cNomArq)

Return .T.

//----------------------------------------------------------
Static Function _Limpa()

	cGet2 := Space(130)

Return()

//----------------------------------------------------------
/*/{Protheus.doc} fDigSenha
Função fDigSenha
@param Não recebe parâmetros
@return Não retorna nada
@author Rafael Scheibler
@owner Solutio IT
@obs Funcao para solicitar a senha para acessar a rotina de analise.
@history

/*/
//----------------------------------------------------------
Static Function fDigSenha()

Private cSenha   := Space(10)
Private cSenhAce := "MRCH102030"

@ 067,020 To 169,312 Dialog Senhadlg Title OemToAnsi("Liberação de Acesso")
@ 015,005 Say OemToAnsi("Informe a senha para o acesso ?") Size 80,8
@ 015,089 Get cSenha Size 50,10 Password
@ 037,106 BmpButton Type 1 Action fOK()
@ 037,055 BmpButton Type 2 Action Close(Senhadlg)
Activate Dialog Senhadlg CENTERED

Return(_lReturn)


//----------------------------------------------------------
/*/{Protheus.doc} fOK
Função fOK
@param Não recebe parâmetros
@return Não retorna nada
@author Rafael Scheibler
@owner Solutio IT
@obs Funcao para validar a senha digitada
@history

/*/
//----------------------------------------------------------
Static Function fOK()

If ALLTRIM(cSenha)<> cSenhAce
   MsgStop("Senha incorreta, verifique !!!")
   cSenha  := Space(10)
   dlgRefresh(Senhadlg)
Else
   _lReturn  := .T.
   Close(Senhadlg)
Endif
Return