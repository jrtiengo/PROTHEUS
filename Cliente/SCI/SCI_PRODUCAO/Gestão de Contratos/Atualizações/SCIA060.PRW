#include "Totvs.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SCIA060  ³ Autor ³ Denis Rodrigues       ³ Data ³17/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Cadastro de Lançamentos de Vendas de Licenciados           ³±±
±±³          ³ somente visualizacao                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente S.C Internacional                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Giovanni   ³11/11/14³ Inclusao do AxInclui no cadastro                ³±±
±±³ Joao Mattos³17/12/14³ Inclusao da Funcao para conferir/gerar titulo CR³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function SCIA060()

Private cCadastro := "Cadastro de Lançamentos de Vendas de Licenciados"
Private aRotina   := MenuDef()//O MenuDef serve para exibir a rotina na tela maior do Protheus
Private aCores    := {}

aAdd( aCores,{ '(SZ9->Z9_STATUS = "A")' ,'BR_VERDE'   })
aAdd( aCores,{ '(SZ9->Z9_STATUS = "C")' ,'BR_AMARELO' })
aAdd( aCores,{ '(SZ9->Z9_STATUS = "E")' ,'BR_VERMELHO'})

mBrowse( 6,1,22,75,"SZ9",,,,,,aCores )

Return

/*
+---------------+
|Menu do mBrowse|
+---------------+*/
Static Function MenuDef()

Local aRotina := {}

aAdd( aRotina,{ "Pesquisar"  				,"AxPesqui"		, 0, 1} )
aAdd( aRotina,{ "Visualiza" 				,"AxVisual"		, 0, 2} )
aAdd( aRotina,{ "Confere/Encerrar" 			,"U_A060FEC()"	, 0, 3} )
aAdd( aRotina,{ "Incluir"    				,"U_A060Inc()"	, 0, 4} )
aAdd( aRotina,{ "Legenda"    				,"U_A060LG()"	, 0, 5} )
aAdd( aRotina,{ "Excluir"                   ,"U_A060EXC()"  , 0, 6} )

Return( aRotina )

/*
+------------------+
|Legenda do mBRowse|
+------------------+*/
User Function A060LG()

BrwLegenda( cCadastro,"Legenda",{{"BR_VERDE" 	,"Lanc. Aberto"},;
{"BR_AMARELO"		,"Conferido"},;
{"BR_VERMELHO"	,"Lanc. Encerrado"}} )

Return

User Function A060EXC()

IF Z9_STATUS $ "A/C"
	IF MSGBOX("Deseja excluir o registo selecionado ?","Excluir","YESNO")
		Reclock("SZ9",.f.)
		dbDelete()
		MsUnlock()
	END
END


Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A060Inc   ³ Autor ³Giovanni Melo          ³ Data ³11/11/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcao de tratamento de inclusao na tabela SZ9              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³U_A060Inc()                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function A060Inc()

Local aObjects    := {}
Local aPosObj     := {}
Local aEnchoice   := {}
Local aSizeAut    := MsAdvSize()
Local nI          := 0
Local aNoFields   := {}
Local nUsado      := 0
Local aHeader     := {}

dbSelectArea("SZ9")
dbSetOrder(1)

For nI := 1 To FCount()
	M->&(FieldName(nI)) := CriaVar(FieldName(nI))
Next nI

//dbSelectArea("SX3")
OpenSxs(,,,,,"SX3TRB","SX3",,.F.)
If Select("SX3TRB") > 0
	
	dbSelectArea('SX3TRB')
	SX3TRB->( dbSetOrder( 1 ) ) //ORDENA POR ALIAS
	SX3TRB->( dbGoTop(  ) )
	SX3TRB->( dbSeek("SZ9") )
	
	While ( !Eof() .And. SX3TRB->&('X3_ARQUIVO') == "SZ9" )
		
		If ( X3USO(SX3TRB->&('X3_USADO')) .And. cNivel >= SX3TRB->&('X3_NIVEL') )
			
			If aScan(aNoFields, AllTrim(SX3TRB->&('X3_CAMPO'))) == 0
				
				nUsado++
				Aadd(aHeader,{ TRIM(X3Titulo()),;
				TRIM(SX3TRB->&('X3_CAMPO')),;
				SX3TRB->&('X3_PICTURE'),;
				SX3TRB->&('X3_TAMANHO'),;
				SX3TRB->&('X3_DECIMAL'),;
				SX3TRB->&('X3_VALID'),;
				SX3TRB->&('X3_USADO'),;
				SX3TRB->&('X3_TIPO'),;
				SX3TRB->&('X3_ARQUIVO'),;
				SX3TRB->&('X3_CONTEXT') } )
			EndIf
		EndIf
		dbSelectArea("SX3TRB")
		dbSkip()
	EndDo
	
	SX3TRB->( DbCloseArea() )
EndIf

// Dimensionamento da tabela
AADD( aObjects, { 0, 277, .T., .F. } )

aInfo := { aSizeAut[1], aSizeAut[2], aSizeAut[3], aSizeAut[4], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects, .T. )

DEFINE MSDIALOG oDlg TITLE cCadastro FROM aSizeAut[7],00 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL

Enchoice("SZ9",, 3, , , ,aEnchoice , aPosObj[1], , 3)

ACTIVATE MSDIALOG oDlg ON INIT Eval({ || EnchoiceBar(oDlg,{||U_A060Grav(M->Z9_NUMCTO,M->Z9_PERIODO,M->Z9_DTINIPE,M->Z9_DTFIMPE)},{||oDlg:End()},.F.) })

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A060Grav  ³ Autor ³Giovanni Melo          ³ Data ³11/11/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcao de inclusao na tabela SZ9                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³U_A060Grav(ExpC1,ExpD2,ExpD3)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Numero do Contrato                                   ³±±
±±³          ³ExpC2: Competencia                                          ³±±
±±³          ³ExpD3: Data Inicial do Periodo                              ³±±
±±³          ³ExpD4: Data Final do Periodo                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function A060Grav(cNumCto,cComp,dDtIniAtual,dDtFimAtual)

Local nI    := 0

If A060VlDt(cNumCto,cComp,dDtIniAtual,dDtFimAtual)
	RecLock("SZ9",.T.)
	
	SZ9->Z9_FILIAL := xFilial("SZ9")
	
	For nI := 1 To SZ9->(FCount())
		
		FieldPut(nI,M->&(FieldName(nI)))
		
	Next nI
	
	MsUnLock()
	
	oDlg:End()
Else
	Iw_MsgBox("Período inválido, verifique as datas informadas.","Atenção","Alert")
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A060VlDt  ³ Autor ³Leandro Marquardt      ³ Data ³11/11/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Funcao de validacao dos periodos                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³U_A060VlDt(ExpC1,ExpD2,ExpD3)                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Numero do Contrato                                   ³±±
±±³          ³ExpC2: Competencia                                          ³±±
±±³          ³ExpD3: Data Inicial do Periodo                              ³±±
±±³          ³ExpD4: Data Final do Periodo                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: lOk										          ³±±
±±³          ³          .T. Periodo Valido                                ³±±
±±³          ³          .F. Periodo Invalido                              ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function A060VlDt(cNumCto,cComp,dDtIniAtual,dDtFimAtual)

Local cSql      := ""
Local cAliasTmp := GetNextAlias()
Local dDtIni    := ""
Local dDtFim    := ""
Local lOk       := .T.




If !ALLTRIM(CN9->CN9_PERACE)$"F/1" 
	cSql := "SELECT Z9_DTINIPE, "
	cSql += "       Z9_DTFIMPE, "
	cSql += "       Z9_PERIODO "
	cSql += " FROM " + RetSqlName("SZ9")
	cSql += " WHERE Z9_FILIAL = '" + xFilial("SZ9") + "'"
	cSql += " AND Z9_PERIODO = '" + cComp + "'"
	cSql += " AND Z9_NUMCTO = '" + cNumCto + "'"
	cSql += " AND D_E_L_E_T_ <> '*'"
	cSql := ChangeQuery(cSql)
	
	dbUseArea(.T.,"TopConn",TcGenQry(,,cSql),cAliasTmp,.F.,.T.)
	
	If ( cAliasTmp )->(!EoF())
		
		While ( cAliasTmp )->(!EoF())
			
			dDtIni := StoD(( cAliasTmp )->Z9_DTINIPE)
			dDtFim := StoD(( cAliasTmp )->Z9_DTFIMPE)
			
			If dDtIniAtual >= dDtIni .And. dDtIniAtual <= dDtFim .Or. ;
				dDtIniAtual <= dDtIni .And. dDtFimAtual >= dDtIni
				lOk := .F.
			EndIf
			
			( cAliasTmp )->(dbSkip())
			
		EndDo
		
		( cAliasTmp )->(dbCloseArea())
		
	EndIf
Endif
Return(lOk)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A060FEC   ³ Autor ³Joao Mattos            ³ Data ³16.12.2014  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Funcao para Conferir / Encerrar                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function A060FEC()

Local aArea			:= GetArea()
Local aAreaCN9		:= CN9->( GetArea() )
Local nRet			:= 0
Local dDtFech		:= Ctod('')
Local dDtTemp		:= Ctod('')
Local aAnoMes		:= {}
Local cAnoMes		:= ""
Local nJ			:= 0
Local cQuery		:= ""
Local aPerMen		:= {}
Local lOk			:= .t.
Local nTaCpoCont	:= TamSx3("CN9_NUMERO")[1] // Numero do Contrato
Local nTaCpoRevi	:= TamSx3("CN9_REVISA")[1] // Revisao do Contrato
Local nQtMeses		:= 0
Local nScan			:= 0
Local nQtPerio		:= 0
//Local cAnoMesIni	:= ""
//Local cAnoMesFin	:= ""
Local dDtFecAtual	:= CToD('')
Local cAliasSZ9		:= GetNextAlias()
Local aLctos		:= {}
//Local nTotVendas	:= 0
Local nVlNoRoy	    := 0
Local nGarantMin	:= 0
Local nRoyalties	:= 0
Local nDiferenca	:= 0
Local cNumTitulo	:= ""
Local cHist			:= ""
Local aNaoConfer	:= {}
Local aNaoInclus	:= {}
Local cMesNConf		:= ""
Local cDesPeri      := space(12)
Local nModuloAux	:= nModulo//Salva o conteudo da variavel
Local cCpoVlrRoy	:= "" // Campo para vuscar valor do Royalt

Private aTituloCR	:= {}
Private lMsErroAuto := .F.
Private lMsHelpAuto := .F.
Private cAnoMesIni	:= ""
Private cAnoMesFin	:= ""
Private nTotVendas	:= 0

nModulo := 6 //numero do módulo FINANCEIRO

nRet := AxVisual( aArea[1], aArea[3], 2)  // Visualizar

If nRet == 1	// 1=Confirma 2=Encerra
	
	// Verifica se esta encerrado
	If SZ9->Z9_STATUS == "E" // Encerrado
		
		lOk := .f.
		Aviso( "Atenção!","Encerramento já efetuado para este período.", { "OK" } )
	EndIf
	
	If lOk
		
		// Posiciona no contrato
		CN9->( DbSetOrder(1) ) // CN9_FILIAL + CN9_NUMERO + CN9_REVISA
		If CN9->( DbSeek( xFilial("CN9") +  PadR(SZ9->Z9_NUMCTO, nTaCpoCont) + PadR(SZ9->Z9_REVCTO, nTaCpoRevi) ) )
			
			dDtFech	:= CN9->CN9_ULTFEC
		Else
			
			lOk	:= .f.
			Aviso( "Atenção!","Contrato número: " + SZ9->Z9_NUMCTO + " - Revisao: " + SZ9->Z9_REVCTO + " não localizado.", { "OK" } )
		EndIf
		
		// Verifica a data de fechamento
		If Empty( dDtFech ) .and. lOk
			
			lOk	:= .f.
			Aviso( "Atenção!","Última data de Fechamento não informada.", { "OK" } )
		Else
			
			dDtFech	:= LastDay( CN9->CN9_ULTFEC )
		EndIf
		
		// Verifica o valor minimo, tem que ser maior que zero.
		/*If Empty( CN9->CN9_VLMIGR ) .and. lOk
		
		lOk	:= .f.
		Aviso( "Atenção!","Valor mínimo de garantia / parcela Royaltie não informada.)", { "OK" } )
	EndIf*/
	
	// Verifica o percentual de royaltie
	If Empty( CN9->CN9_TXROY ) .and. lOk
		lOk	:= .f.
		Aviso( "Atenção!","Percentual Royaltie não informado.", { "OK" } )
	EndIf
	
	If lOk
		
		//1=Mensal;2=Bimestral;3=Trimestral;6=Semestral;A=Anual
		// aPerMen
		// Elemento 1 = Periodo Acerto
		// Elemento 2 = Quantidade meses
		aAdd ( aPerMen, { "1", 01 			  } )			// 1=Mensal		= um mes
		aAdd ( aPerMen, { "2", 02 			  } )			// 2=Bimestral	= dois meses
		aAdd ( aPerMen, { "3", 03			  } )			// 3=Trimestral	= tres meses
		aAdd ( aPerMen, { "6", 06 			  } )			// 6=Semestral	= seis meses
		aAdd ( aPerMen, { "A", 12 			  } )			// A=Anual		= doze meses
		aAdd ( aPerMen, { "F", CN9->CN9_VIGE  } )			// F=Fim Ctr	= CN9_VIGE
		
		// Quantidade de meses do periodo de acerto
		nQtMeses	:= 0
		If ( nScan := AsCan( aPerMen, { |X| X[1] == CN9->CN9_PERACE } ) ) > 0
			
			nQtMeses	:= aPerMen[nScan][2]
		Else
			
			Aviso( "Atenção!","Quantidade de meses do periodo inválida. Verifique a informação que consta no campo CN9_PERACE do contrato. Opções válidas: 1=Mensal;2=Bimestral;3=Trimestral;6=Semestral;A=Anual.", { "OK" } )
		EndIf
		
		If nQtMeses > 0
			
			dDtTemp	:= dDtFech
			
			While Len(aAnoMes) < nQtMeses
				
				dDtTemp ++
				cAnoMes	:= Substr(Dtos(dDtTemp), 1, 4) + Substr(Dtos(dDtTemp), 5, 2)
				
				If ( nScan := AsCan( aAnoMes, { |X| X[1] == cAnoMes } ) ) == 0
					
					// Array aAnoMes
					// Elemento 1 = Ano + Mes
					aAdd ( aAnoMes, { cAnoMes } )
				EndIf
			EndDo
			aSort( aAnoMes 	,,, { |X,Y| X[1] < Y[1] } )
			
			// Verificar o periodo inicial e final
			For nJ	:= 1 to Len( aAnoMes )
				
				// Ano + Mes Inicial            
				If nJ == 1
					
					cAnoMesIni	:= aAnoMes[nJ][1]
				EndIf
				
				// Ano + Mes Final
				If nJ == Len( aAnoMes )
					
					cAnoMesFin	:= aAnoMes[nJ][1]
					dDtFecAtual	:= LastDay ( SToD( aAnoMes[nJ][1] + "01" ) )
				EndIf
			Next nJ
			
			// Atualiza o Status para conferido
			If SZ9->Z9_STATUS == "A" // Aberto
				
				SZ9->( RecLock( "SZ9", .f. ) )
				SZ9->Z9_STATUS	:= "C" // Conferido
				SZ9->( MsUnLock() )
			EndIf
			
			// Query para verificar os lancamentos deste contrato para o proximo periodo
			// estao confirmados.
			cQuery	:= " SELECT * "
			cQuery	+= " FROM " + RetSqlName("SZ9") + " SZ9 "
			cQuery	+= " WHERE SZ9.Z9_FILIAL = '" + xFilial("SZ9")  + "' "
			cQuery	+= "   AND SZ9.Z9_NUMCTO = '" + CN9->CN9_NUMERO + "' "
			cQuery	+= "   AND SZ9.Z9_REVCTO = '" + CN9->CN9_REVISA + "' "
			cQuery	+= "   AND SZ9.Z9_PERIODO BETWEEN ('" + cAnoMesIni + "') AND ('" + cAnoMesFin + "') "
			cQuery	+= "   AND SZ9.D_E_L_E_T_ = ' ' "
			
			cQuery := ChangeQuery(cQuery)
			dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasSZ9, .F., .T.)
			nx:=0
			While !Eof()
				
				// Nao conferido
				//If (cAliasSZ9)->Z9_STATUS <> "C" 
				If (cAliasSZ9)->Z9_STATUS <> "C" .and. CN9->CN9_TPROYA = "1" //Valdir em 13/05/2019 - Colocado a condicao tproya
					
					aAdd ( aNaoConfer, { AllTrim((cAliasSZ9)->Z9_PERIODO) } )
				EndIf
				
				If ( CN9->CN9_TPROYA = "2" .and.  Len(aLctos) == 0 .and. (cAliasSZ9)->Z9_STATUS <> 'E' ) .or. CN9->CN9_TPROYA = "1" //Valdir em 13/05/2019 - Colocado este IF para processa  o mult para cada linha da SZ9
					//aAdd( Atail(aLctos), (cAliasSZ9)->R_E_C_N_O_ )
					aAdd( aLctos, { (cAliasSZ9)->R_E_C_N_O_, AllTrim((cAliasSZ9)->Z9_PERIODO), AllTrim((cAliasSZ9)->Z9_DTFIMPE) }  )
					//Add( Atail(aLctos), AllTrim((cAliasSZ9)->Z9_PERIODO) )
					//aAdd( aLctos, AllTrim((cAliasSZ9)->Z9_PERIODO) )
					//aAdd( Atail(aLctos), AllTrim((cAliasSZ9)->Z9_DTFIMPE) )
					//aAdd( aLctos, AllTrim((cAliasSZ9)->Z9_DTFIMPE) )
                EndIf

				nx:=nx+1
				DbSelectArea(cAliasSZ9)
				DbSkip()
				
				
			EndDo
			DbSelectArea(cAliasSZ9)
			DbCloseArea(cAliasSZ9)
			If Len ( aLctos ) == 0 .and. CN9->CN9_TPROYA = "1" //Valdir em 13/05/2019
				
				lOk	:= .f.
				Aviso( "Atenção!","Não existe nenhum lançamento para período: Mes/Ano Inicio: " + Substr(cAnoMesIni,5,2) + "/" + Left(cAnoMesIni,4) + " - Mes/Ano Fim: " +  Substr(cAnoMesFin,5,2) + "/" + Left(cAnoMesFin,4) + ".", { "OK" } )
			EndIf
			
			If lOk .AND. CN9->CN9_PERACE<>'F' .and. CN9->CN9_TPROYA = "1" //Valdir em 13/05/2019
				
				If Len(aNaoConfer) > 0  // Existem lançamentos ainda nao conferidos ou não incluidos
					
					cMesNConf	:= ""
					For nJ	:= 1 to Len(aNaoConfer)
						
						cMesNConf	+= Substr(aNaoConfer[nJ][1],5,2) + "/" + Left(aNaoConfer[nJ][1],4) + Iif ( nJ == Len(aNaoConfer), "", ", " )
					Next nJ
					
					lOk	:= .f.
					Aviso( "Atenção!","Existem lançamentos a serem conferidos para período: Mes/Ano Inicio: " + Substr(cAnoMesIni,5,2) + "/" + Left(cAnoMesIni,4) + " - Mes/Ano Fim: " +  Substr(cAnoMesFin,5,2) + "/" + Left(cAnoMesFin,4) + ", por isto não será gerado o título a receber. Porém este lançamento terá seu status alterado para 'CONFERIDO'.", { "OK" } )
				EndIf
			EndIf
			
			// Verificar se existem lançamentos ainda não inclusos
			If lOk .and. CN9->CN9_TPROYA = "1" //Valdir em 13/05/2019
				
				For nJ	:= 1 to Len( aAnoMes )
					
					If ( nScan := AsCan( aLctos, { |X| X[2] == aAnoMes[nJ][1] } ) ) == 0
						
						aAdd ( aNaoInclus, { aAnoMes[nJ][1] } )
					EndIf
				Next nJ
				
				If Len(aNaoInclus) > 0 // Existem lançamentos que ainda não foram inclusos para este periodo
					
					lOk	:= MsgYesNo( "Existem lançamentos a serem incluidos para este período: Mes/Ano Inicio: " + Substr(cAnoMesIni,5,2) + "/" + Left(cAnoMesIni,4) + " - Mes/Ano Fim: " +  Substr(cAnoMesFin,5,2) + "/" + Left(cAnoMesFin,4) + ", mesmo assim deseja efetuar o encerramento para este período?" )
				EndIf
			EndIf
			
			If lOk
				
				//lOk	:= MsgYesNo( "Deseja gerar o título a receber neste momento?" )
				
				//If lOk
				
				cAliasSZ9	:= GetNextAlias()
				// Query para totalizar as vendas
				cQuery	:= " SELECT Z9_FILIAL, Z9_TTXROY, Z9_VLRLIQ, Z9_VALOR,Z9_CALCROY, Z9_PERCROY "
				cQuery	+= " FROM " + RetSqlName("SZ9") + " SZ9 "
				cQuery	+= " WHERE SZ9.Z9_FILIAL = '" + xFilial("SZ9")  + "' "
				cQuery	+= "   AND SZ9.Z9_NUMCTO = '" + CN9->CN9_NUMERO + "' "
				cQuery	+= "   AND SZ9.Z9_REVCTO = '" + CN9->CN9_REVISA + "' "
				cQuery	+= "   AND SZ9.Z9_PERIODO BETWEEN ('" + cAnoMesIni + "') AND ('" + cAnoMesFin + "') "
				cQuery	+= "   AND SZ9.Z9_STATUS = 'C' " // somente os conferidos
				cQuery	+= "   AND SZ9.D_E_L_E_T_ <> '*' "
				//cQuery	+= " GROUP BY Z9_FILIAL "
				cQuery	+= " ORDER BY Z9_FILIAL "
				
				cQuery := ChangeQuery(cQuery)
				dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasSZ9, .F., .T.)
				nTotVendas	:= 0
				nAuxTot     := 0
				nAuxTotA    := 0
				nTotAnual   := 0
				Do Case
					Case CN9->CN9_PERACE=="1"
						cDesPeri:="Mensal"
					Case CN9->CN9_PERACE=="2"
						cDesPeri:="Bimestral"
					Case CN9->CN9_PERACE=="3"
						cDesPeri:="Trimestral"
					Case CN9->CN9_PERACE=="6"
						cDesPeri:="Semestral"
					Case CN9->CN9_PERACE=="A"
						cDesPeri:="Anual"
					Case CN9->CN9_PERACE=="F"
						cDesPeri:="Fim Contrato"
				EndCase
				
				
				nTotLan:=0.00
				nTotRoy:=0.00
				nTotGar:=0.00
				While !Eof()
					
					cCpoVlrRoy := IIF(CN9->CN9_TTXROY == '2','Z9_VALOR','Z9_VLRLIQ') //Campo para buscar valor do Royalt
					If CN9->CN9_TPROYA="1" //Royalties Unico - Apenas um Royaltie para o Contrato
						
						//--- Se o lancamento estiver no periodo de sazonalidade, ou seja
						//--- isento da cobranca, sera cobrado apenas o percentual das vendas.
						If (cAliasSZ9)->Z9_CALCROY='2'
							If (cAliasSZ9)->(cCpoVlrRoy)>0
								nVlNoRoy+=( (cAliasSZ9)->(cCpoVlrRoy) * CN9->CN9_TXROY  / 100 )
							Endif
						Endif
						
						//--- Se o lancamento nao estiver no periodo de sazonalidade, ou seja
						//--- sera cobrado royaltie integral.
						If (cAliasSZ9)->Z9_CALCROY<>'2'
							nTotLan+= (cAliasSZ9)->(cCpoVlrRoy)
							nTotRoy+=((cAliasSZ9)->(cCpoVlrRoy) * CN9->CN9_TXROY  / 100 )
							nTotGar+=((cAliasSZ9)->(cCpoVlrRoy) * CN9->CN9_TXROY  / 100 ) - CN9->CN9_VLMIGR
							nAuxTotA	  := ( (cAliasSZ9)->(cCpoVlrRoy) * CN9->CN9_TXROY  / 100 ) - CN9->CN9_VLMIGR
							If nAuxTotA >0
								nTotGar+=((cAliasSZ9)->(cCpoVlrRoy) * CN9->CN9_TXROY  / 100 ) - CN9->CN9_VLMIGR
								nTotAnual+=nAuxTotA
							Endif
						Endif
						
					Else  //Royalties Multiplos - Mais de um % de Royaltie para o Contrato.
						//--- Se o lancamento estiver no periodo de sazonalidade, ou seja
						//--- isento da cobranca, sera cobrado apenas o percentual das vendas.
						If (cAliasSZ9)->Z9_CALCROY='2'
							If (cAliasSZ9)->(cCpoVlrRoy)>0
								nVlNoRoy+=( (cAliasSZ9)->(cCpoVlrRoy) * (cAliasSZ9)->Z9_PERCROY  / 100 )
							Endif
						Endif
						
						//--- Se o lancamento nao estiver no periodo de sazonalidade, ou seja
						//--- sera cobrado royaltie integral.
						If (cAliasSZ9)->Z9_CALCROY<>'2'
							nTotLan+= (cAliasSZ9)->(cCpoVlrRoy)
							nTotRoy+=((cAliasSZ9)->(cCpoVlrRoy) * (cAliasSZ9)->Z9_PERCROY  / 100 )
							nTotGar+=((cAliasSZ9)->(cCpoVlrRoy) * (cAliasSZ9)->Z9_PERCROY  / 100 ) - CN9->CN9_VLMIGR
							nAuxTotA	  := ( (cAliasSZ9)->(cCpoVlrRoy) * (cAliasSZ9)->Z9_PERCROY  / 100 ) - CN9->CN9_VLMIGR
							If nAuxTotA >0
								nTotGar+=((cAliasSZ9)->(cCpoVlrRoy) * (cAliasSZ9)->Z9_PERCROY  / 100 ) - CN9->CN9_VLMIGR
								nTotAnual+=nAuxTotA
							Endif
						Endif
						
					Endif
					
					DbSelectArea(cAliasSZ9)
					DbSkip()
				EndDo
				DbSelectArea(cAliasSZ9)
				DbCloseArea(cAliasSZ9)
				nTotAnual+=nVlNoRoy
				nTotVendas:=nTotRoy
				
				
				
				
				If cDesPeri="Fim Contrato"
					nTotVendas:=nTotRoy - CN9->CN9_VLMIGR // Valdir em 15/09/17
					nTotVendas:=nTotVendas-CN9->CN9_VLTOTG
				Else
					If cDesPeri="Anual"
						nTotVendas:=nTotAnual 
						nTotVendas:=nTotRoy - CN9->CN9_VLTOTG
					
					endif
					
					If (cDesPeri="Mensal") .or.(cDesPeri="Bimestral") .or.(cDesPeri="Semestral") .or. (cDesPeri="Trimestral")
						
						nTotVendas:=nTotAnual 
						
					endif
				Endif
				
				If CN9->CN9_TPROYAL="2" // Multiplos Royalties
					nTotVendas:=0.00
					nTotVendas:=nTotAnual  
				Endif
				
				
				
				msg:=""
				msg:=' - Valor Total Apurado periodo sazonal: '+Transform(nVlNoRoy,"@E 99,999,999,999.99")+Chr(13)+Chr(10)+' - '
				msg+='Valor Total Apurado periodo s/ sazonalidade: '+Transform(nTotLan,"@E 99,999,999,999.99")+Chr(13)+Chr(10)+' - '
				msg+='Valor Total Apurado periodo sazonal + periodo s/ sazonalidade: '+Transform(nTotLan+nVlNoRoy,"@E 99,999,999,999.99")+Chr(13)+Chr(10)+' - '
				msg+='Valor Total aplicando o % de Royalties: '+Transform(nTotRoy,"@E 99,999,999,999.99")+Chr(13)+Chr(10)+' - '
				If cDesPeri="Fim Contrato" .or. cDesPeri="Anual"
					msg+='Garantia minima do periodo:'+Transform(CN9->CN9_VLTOTG,"@E 99,999,999,999.99")+Chr(13)+Chr(10)+' - '
					msg+=' - Valor Total Apurado Anual(Valor Total aplicando o % de Royalties-Garantia minima do periodo: '+Transform(nTotVendas,"@E 99,999,999,999.99")
				Else
					msg+=' - Valor Total descontando a Garantia Mínima: '+Transform(nTotAnual,"@E 99,999,999,999.99")
				Endif
				If CN9->CN9_TPROYAL="2" // Multiplos Royalties
					msg+=Chr(13)+Chr(10)+' Obs.: Este contrato possui multiplos % de royalties nos lancamentos! '
					
				Endif
				
				
				
				alert(msg)
				cNumTitulo	:= GetMv( "ES_E1SQCTV")
				If nTotVendas > 0
					lOk	:= MsgYesNo("Deseja gerar o título:"+cNumTitulo+" a receber, periodo: "+AllTrim(cDesPeri)+" no valor de: "+ Transform(nTotVendas,"@E 99,999,999,999.99")+" ?")
								If lOk
						//	"string linha1" + Chr(13) + Chr(10) + "string linha2"
						If nTotVendas > 0 // Gera titulo do contas a receber
							cHist		:= "ROYALTIES CONTRATO No. " + CN9->CN9_NUMERO + " - Rev.: " + CN9->CN9_REVISA
							cNumTitulo	:= GetMv( "ES_E1SQCTV" ) // proximo numero do titulo
							If Empty( cNumTitulo )
								cNumTitulo := Replicate ("0", TamSx3("E1_NUM")[1] )
							EndIf
	
							cNumTitulo := Soma1(cNumTitulo)
							PutMV ( "ES_E1SQCTV", cNumTitulo  ) // atualiza o ultimo numero usado
							
							dbSelectArea("CNB")
							dbSetOrder(1)
							dbSeek(CN9->(CN9_FILIAL+CN9_NUMERO+CN9_REVISA),.T. )

							aTituloCR	:= {}

							dbSelectArea("CNC")
                            dbSetOrder(1)//CNC_FILIAL+CNC_NUMERO
	                        dbSeek(xFilial("CNC") + CN9->CN9_NUMERO )
           
							
							
							AAdd( aTituloCR, {	"E1_PREFIXO"	, "CTV"				       , NIL	} )
							AAdd( aTituloCR, {	"E1_NUM"		, AllTrim(cNumTitulo)      , NIL	} )
							AAdd( aTituloCR, {	"E1_PARCELA"	, Space(1)			       , Nil	} )
							AAdd( aTituloCR, {	"E1_CCCTB "		, CNB->CNB_CC              , NIL	} )
							AAdd( aTituloCR, {	"E1_ITCTB "	    , CNB->CNB_ITEMCT          , Nil	} )
							AAdd( aTituloCR, {	"E1_CLVLCTB"	, CNB->CNB_CLVL		       , Nil	} )
							AAdd( aTituloCR, {	"E1_TIPO"		, "DP"				       , Nil	} )
							AAdd( aTituloCR, {	"E1_CLIENTE"	, CNC->CNC_CLIENT	       , Nil	} )
							AAdd( aTituloCR, {	"E1_LOJA"		, CNC->CNC_LOJACL	       , Nil	} )
							AAdd( aTituloCR, {	"E1_NATUREZ"	, "110902"			       , Nil	} )
							AAdd( aTituloCR, {	"E1_EMISSAO"	, dDataBase			       , Nil	} )
							AAdd( aTituloCR, {	"E1_VENCTO"		, dDataBase + 7		       , Nil	} )
							AAdd( aTituloCR, {	"E1_VENCREA"	, DataValida(dDataBase + 7), Nil	} )
							AAdd( aTituloCR, {	"E1_VALOR"		, nTotVendas		       , Nil	} )
							AAdd( aTituloCR, {	"E1_HIST"		, cHist				       , Nil	} )
							AAdd( aTituloCR, {	"E1_ORIGEM"		, "SCIA060"			       , Nil	} )
							
							MsExecAuto( { |x,y| FINA040(x,y)} , aTituloCR, 3)  // 3 - Inclusao, 4 - Alteracao, 5 - Exclusao
							If lMsErroAuto
								MostraErro()
							Else
								// Atualiza o status dos lancamentos das vendas como ENCERRADO
								AtuStatus( aLctos, dDtFecAtual )
								Aviso( "Atenção!","Título Contas a Receber gerado com sucesso.", { "OK" } )
							Endif
							
						Else
							
							// O valor minimo garantido foi maior que o valor do royaltie, por isto
							// será atualizado o status, mas não sera gerado o titulo a receber.
							// Atualiza o status dos lancamentos das vendas como ENCERRADO
							AtuStatus( aLctos, dDtFecAtual )
							Aviso( "Atenção!","O Valor Mínimo pago foi maior que o Royaltie, portanto o título contas a receber não será gerado, mas os status foram atualizados para 'ENCERRADO'.", { "OK" } )
							
						EndIf
						CNB->(dbclosearea())
					EndIf
				Else
					AtuStatus( aLctos, dDtFecAtual )
					Aviso( "Atenção!","O Valor Mínimo pago foi maior que o Royaltie, portanto o título contas a receber não será gerado, mas os status foram atualizados para 'ENCERRADO'.", { "OK" } )
				Endif
			EndIf
		EndIf
	EndIf
EndIf
EndIf

nModulo := nModuloAux//Restaura o conteudo da variavel
RestArea ( aAreaCN9 )
RestArea ( aArea )

Return ( Nil )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³AtuStatus ³ Autor ³Joao Mattos            ³ Data ³19.12.2014  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Funcao para atualizar status e data de fechamento no contrato³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpA01 - Lancamentos para atualizar o status                 ³±±
±±³          ³ ExpD02 - Data de fechamento atual                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ PROGRAMADOR  ³ DATA   ³ BOPS ³  MOTIVO DA ALTERACAO                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³              ³        ³      ³                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function AtuStatus( aLctos, dDtFecAtual )

Local nJ	:= 0
Local cAliasSZ9		:= GetNextAlias()

Begin Transaction

//Valdir - 13/05/2019 - Se for um TPRoya == '2', só posso atualizar o fechamento no ultimo reg da SZ9 daquel emesm corrente...
If CN9->CN9_TPROYA = "2" //Valdir em 13/05/2019 - Colocado a condicao tproya

	cQuery	:= " SELECT count(*) nTpRoyUlt "
	cQuery	+= " FROM " + RetSqlName("SZ9") + " SZ9 "
	cQuery	+= " WHERE SZ9.Z9_FILIAL = '" + xFilial("SZ9")  + "' "
	cQuery	+= "   AND SZ9.Z9_NUMCTO = '" + CN9->CN9_NUMERO + "' "
	cQuery	+= "   AND SZ9.Z9_REVCTO = '" + CN9->CN9_REVISA + "' "
	cQuery	+= "   AND SZ9.Z9_STATUS <> 'E' "
	cQuery	+= "   AND SZ9.Z9_PERIODO BETWEEN ('" + cAnoMesIni + "') AND ('" + cAnoMesFin + "') "
	cQuery	+= "   AND SZ9.D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., 'TOPCONN', TCGENQRY(,,cQuery), cAliasSZ9, .F., .T.)
	nx:=0
	
	If (cAliasSZ9)->nTpRoyUlt == 1 //Se for o ultimo regidstro
		CN9->( RecLock( "CN9", .f. ) )
		CN9->CN9_ULTFEC	:= dDtFecAtual
		CN9->( MsUnLock() )
    EndIf
	DbCloseArea(cAliasSZ9)


Else
	CN9->( RecLock( "CN9", .f. ) )
	CN9->CN9_ULTFEC	:= dDtFecAtual
	CN9->( MsUnLock() )
EndIf


// Atualiza o Status dos Lancamentos
aSort(aLctos,,, { |x, y| x[3] < y[3] }) // Ordem DATA FIM PERIODO - Z9_DTFIMPE
For nJ	:= 1 to Len(aLctos)
	
	SZ9->( DbGoTo( aLctos[nJ][1] ) )
	SZ9->( RecLock( "SZ9", .f. ) )
	SZ9->Z9_STATUS	:= "E"
	
	If nJ == Len(aLctos) .and. nTotVendas > 0
		
		SZ9->Z9_PREFIXO	:= SE1->E1_PREFIXO
		SZ9->Z9_NUM		:= SE1->E1_NUM
		SZ9->Z9_PARCELA	:= SE1->E1_PARCELA
		SZ9->Z9_TIPO	:= SE1->E1_TIPO
	EndIf
	SZ9->( MsUnLock() )
Next nJ

// Atualiza a data de fechamento no Contrato


End Transaction
Return Nil
