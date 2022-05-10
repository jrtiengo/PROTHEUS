#INCLUDE 'INKEY.CH'
#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'RWMAKE.CH'
#INCLUDE 'TOPCONN.CH'
#INCLUDE 'TBICONN.CH'
#INCLUDE 'FIVEWIN.CH'
#INCLUDE 'FONT.CH'
#INCLUDE 'COLORS.CH'
#INCLUDE "DBTREE.CH"

#DEFINE  ENTER CHR(13)+CHR(10)

/*

Observações sobre o layout:
1. Se não tiver a Conta, não será gravado na AK2;
2. Se não tiver TODOS os valores nos meses, não será gravado na AK2;
3. O valor deverá ser no formato como está no layout com a virgula separando o inteiro do decimal.

Filial;CC;Conta;Descricao; Jan ; Fev ; Mar ; Abr ; Mai ; Jun ; Jul ; Ago ; Set ; Out ; Nov ; Dez 
01;11030001;;DESPESAS DE MARKETING; -   ; -   ; -   ; -   ; -   ; -   ; -   ; -   ; -   ; -   ; -   ; -   
01;11030001;511001005;PROMOCOES, PERMUTAS E CORTESIAS;;;;;;;;;;;;
01;11030001;511001002;PUBLICIDADE E PROPAGANDA;;;;;;;;;;;;
01;11030001;;DESPESAS DIVERSAS; 150,00 ; 150,00 ; 150,00 ; 150,00 ; 150,00 ; 150,00 ; 150,00 ; 150,00 ; 150,00 ; 150,00 ; 150,00 ; 150,00 
01;11030001;512207007;ASSOCIACAO DE CLASSE;;;;;;;;;;;;
01;11030001;512207013;CONTRIBUICOES PATRONAIS;;;;;;;;;;;;
01;11030001;512207003;DONATIVOS DIVERSOS;;;;;;;;;;;;
01;11030001;512207010;FEIRAS E EXPOSICOES;;;;;;;;;;;;
01;11030001;512207004;FRETES/CARRETOS E TRANSP PESSOA JURIDICA;;;;;;;;;;;;
01;11030001;512207005;LIVROS JORNAIS E REVISTAS;;;;;;;;;;;;
01;11030001;512207011;MATERIAL DE CONSUMO;;;;;;;;;;;;
01;11030001;512207002;MATERIAL DE EXPEDIENTE; 150,00 ; 150,00 ; 150,00 ; 150,00 ; 150,00 ; 150,00 ; 150,00 ; 150,00 ; 150,00 ; 150,00 ; 150,00 ; 150,00 
01;11030001;512207001;MATERIAL DE HIGIENE E LIMPEZA;;;;;;;;;;;;
01;11030001;512207099;OUTRAS DESPESAS ADMINISTRATIVAS;;;;;;;;;;;;
01;11030001;512207006;PREMIOS DE SEGURO-EQUIPAMENTOS E OUTROS;;;;;;;;;;;;
01;11030001;512207012;TAXAS E EMOLUMENTOS CARTORIAIS;;;;;;;;;;;;
01;11030001;;DESPESAS TRIBUTARIAS; -   ; -   ; -   ; -   ; -   ; -   ; -   ; -   ; -   ; -   ; -   ; -   
01;11030001;512205002;ALVARAS, LICENCAS E TAXAS DIVERSAS;;;;;;;;;;;;
01;11030001;512205001;IPTU;;;;;;;;;;;;
01;11030001;512205006;IPVA;;;;;;;;;;;;
01;11030001;;INFORMATICA E COMUNICACAO; 3.600,00 ; 3.600,00 ; 3.600,00 ; 3.600,00 ; 3.600,00 ; 3.600,00 ; 3.600,00 ; 3.600,00 ; 3.600,00 ; 3.600,00 ; 3.600,00 ; 3.600,00 
01;11030001;512202002;CORREIOS E ENCOMENDAS; 300,00 ; 300,00 ; 300,00 ; 300,00 ; 300,00 ; 300,00 ; 300,00 ; 300,00 ; 300,00 ; 300,00 ; 300,00 ; 300,00 
01;11030001;512202003;MANUTENCAO DE INFORMATICA;;;;;;;;;;;;
01;11030001;512202001;SERVICOS DE TRANSMISSAO DE DADOS; 3.300,00 ; 3.300,00 ; 3.300,00 ; 3.300,00 ; 3.300,00 ; 3.300,00 ; 3.300,00 ; 3.300,00 ; 3.300,00 ; 3.300,00 ; 3.300,00 ; 3.300,00 
01;11030001;512202004;SERVICOS TELEFONICOS;;;;;;;;;;;;
01;11030001;;MANUT/CONS DE INSTAL E EQUIPAMENTOS; 2.500,00 ; 2.500,00 ; 2.500,00 ; 2.500,00 ; 2.500,00 ; 2.500,00 ; 2.500,00 ; 2.500,00 ; 2.500,00 ; 2.500,00 ; 2.500,00 ; 2.500,00 
01;11030001;512206007;BENS DEDUZIDOS COMO DESPESAS;;;;;;;;;;;;
01;11030001;512206001;LOCACAO DE BENS IMOVEIS;;;;;;;;;;;;
01;11030001;512206004;LOCACOES-BENS MOVEIS; 2.500,00 ; 2.500,00 ; 2.500,00 ; 2.500,00 ; 2.500,00 ; 2.500,00 ; 2.500,00 ; 2.500,00 ; 2.500,00 ; 2.500,00 ; 2.500,00 ; 2.500,00 
01;11030001;512206002;MANUTENCAO DE MAQU E EQUIPAMENTOS;;;;;;;;;;;;
01;11030001;512206005;MANUTENCAO DE PREDIOS E INSTALACOES;;;;;;;;;;;;
01;11030001;512206099;OUTRAS DESPESAS COM MANUT/CONSERV;;;;;;;;;;;;
01;11030001;;MATERIAL DE CONSUMO E PRODUCAO; -   ; -   ; -   ; -   ; -   ; -   ; -   ; -   ; -   ; -   ; -   ; -   
01;11030001;512301005;COMBUSTIVEIS;;;;;;;;;;;;
01;11030001;512301007;EMBALAGENS;;;;;;;;;;;;
01;11030001;512301008;FERRAMENTAS E DISP DE CONSUMO;;;;;;;;;;;;
01;11030001;512301014;GAS NATURAL E GLP;;;;;;;;;;;;
01;11030001;512301009;GASES INDUSTRIAIS;;;;;;;;;;;;
01;11030001;512301011;MATERIAL DE CONSUMO DA PRODUCAO;;;;;;;;;;;;
01;11030001;512301027;MATERIA-PRIMA CONSUMIDA;;;;;;;;;;;;
01;11030001;512301099;OUTRAS DESPESAS DE CONS/PRODUCAO;;;;;;;;;;;;
01;11030001;512301041;PRODUTO INTERMEDIARIO CONSUMIDO;;;;;;;;;;;;
01;11030001;512301012;PRODUTOS QUIMICOS;;;;;;;;;;;;
01;11030001;;OBRAS; -   ; -   ; -   ; -   ; -   ; -   ; -   ; -   ; -   ; -   ; -   ; -   
01;11030001;512400099;DESPESAS COM CONSTRUCAO CIVIL;;;;;;;;;;;;
01;11030001;512400013;MAQ/ EQUIP /FERR P/ OBRA;;;;;;;;;;;;
01;11030001;512400001;PROJETO INICIAL;;;;;;;;;;;;
01;11030001;;SERVICOS DE TERCEIROS; 10.500,00 ; 10.500,00 ; 10.500,00 ; 10.500,00 ; 10.500,00 ; 10.500,00 ; 10.500,00 ; 10.500,00 ; 10.500,00 ; 10.500,00 ; 10.500,00 ; 10.500,00 
01;11030001;512204003;ASSESSORIA CONTABIL DE PJ;;;;;;;;;;;;
01;11030001;512204004;ASSESSORIA EM INFORMATICA DE PJ;;;;;;;;;;;;
01;11030001;512204098;ASSESSORIA ENGENHARIA E ARQUITETURA PJ;;;;;;;;;;;;
01;11030001;512204002;ASSESSORIA JURIDICA PJ;;;;;;;;;;;;
01;11030001;512204099;OUTROS SERVICOS TERCEIROS DE PJ; 10.500,00 ; 10.500,00 ; 10.500,00 ; 10.500,00 ; 10.500,00 ; 10.500,00 ; 10.500,00 ; 10.500,00 ; 10.500,00 ; 10.500,00 ; 10.500,00 ; 10.500,00 
01;11030001;512204021;SERVICO DE PODA/DESRAMA;;;;;;;;;;;;
01;11030001;512204001;SERVICOS DE TERCEIROS-PF (RPA);;;;;;;;;;;;
01;11030001;512204005;SERVICOS DE VIGILANCIA/SEGURANCA;;;;;;;;;;;;
01;11030001;512204006;SERVICOS LIMPEZA/DETETIZ/HIGIENIZACAO PJ;;;;;;;;;;;;
01;11030001;;VIAGENS E VEICULOS; 16.380,00 ; 16.380,00 ; 16.380,00 ; 16.380,00 ; 16.380,00 ; 16.380,00 ; 16.380,00 ; 16.380,00 ; 16.380,00 ; 16.380,00 ; 16.380,00 ; 28.880,00 
01;11030001;512203003;LOCACAO DE VEICULOS; 3.380,00 ; 3.380,00 ; 3.380,00 ; 3.380,00 ; 3.380,00 ; 3.380,00 ; 3.380,00 ; 3.380,00 ; 3.380,00 ; 3.380,00 ; 3.380,00 ; 3.380,00 
01;11030001;512203001;MANUTENCAO DE VEICULOS;;;;;;;;;;;; 12.500,00 
01;11030001;512203099;OUTRAS DESPESAS C/VIAGENS/VEICULOS; 4.000,00 ; 4.000,00 ; 4.000,00 ; 4.000,00 ; 4.000,00 ; 4.000,00 ; 4.000,00 ; 4.000,00 ; 4.000,00 ; 4.000,00 ; 4.000,00 ; 4.000,00 
01;11030001;512203004;PASSAGENS / CONDUCAO / DESLOCAMENTO;;;;;;;;;;;;
01;11030001;512203002;VIAGENS E REPRESENTACOES; 9.000,00 ; 9.000,00 ; 9.000,00 ; 9.000,00 ; 9.000,00 ; 9.000,00 ; 9.000,00 ; 9.000,00 ; 9.000,00 ; 9.000,00 ; 9.000,00 ; 9.000,00 
01;11030001;
*/

/*/{Protheus.doc} ImpPlanOrc
Importa Plano Orçamentário. Créditos de referência para  criação de solução. Samuel Scheider, Walter Carvalho
@type function
@version  1
@author Márcio Borges
@since 11/01/2022
/*/
User Function IMPPLPCO()

	//Pré-requisitos:
	//Fonte XLSXTOARR.PRW - Efetua a automação do processo de gerar o EXCEL para CSV antes da importação dos dados
	//XLXTOCSV.EXE - Executável deve ser disponibilizado no System do servidor. Recurso gerado de Sctipt do PowerShell emcapsulado em executável para rodar processo de XLS to CSV.
	// Referência: 	https://github.com/walterfcarvalho/advpl-xlsxtocsv


	Local lRoda		:= .T. // Libera a rotina para uso
	Local oGrp, oSay1, nTamGet, oGet1, nColIni, oBtn1, oBtn2, oBtn3, oBtn4
	Private lImpTodoPlanAK3	:= .T.  // Se Falso monta somente estrutura das contas importadas
	Private _cAnoAtu := cValToChar( Year( dDataBase ) )
	Private aPeriodos := {"01/01/"+_cAnoAtu,;
		"01/02/"+_cAnoAtu,;
		"01/03/"+_cAnoAtu,;
		"01/04/"+_cAnoAtu,;
		"01/05/"+_cAnoAtu,;
		"01/06/"+_cAnoAtu,;
		"01/07/"+_cAnoAtu,;
		"01/08/"+_cAnoAtu,;
		"01/09/"+_cAnoAtu,;
		"01/10/"+_cAnoAtu,;
		"01/11/"+_cAnoAtu,;
		"01/12/"+_cAnoAtu}
	Private oGreen   := LoadBitmap( GetResources(), "BR_VERDE")
	Private oRed     := LoadBitmap( GetResources(), "BR_VERMELHO")

	//Private cTrab
	Private cDirDocs := MsDocPath() //"\dirdoc\co01\shared"
	Private cSPatch  := "" //Patch do Servidor - Full
	Private cTPatch  := Space(200) //Patch do Terminal - Full
	Private cArqCsv  := Space(200)
	Private cLOGERRO := ""

	//Tabela temporária
	//------ tab temporaria
	Private oTempTable
	Private oTempAK3
	Private cArqTrab	:= GetNextAlias()


	Private cMarca   := GetMark()
	Private aCurvas  :={'' }
	Private cCBox    := ''
	Private oDlg1    := NIL
	Private aArqTemp := {}
	Private aBrowse  := {}
	Private oBrw1
	Private cTitulo  := 'Importa Planilha de Orçamento'
	Private cModAK1  := Posicione("SX2",1,"AK1","X2_MODO")+SX2->X2_MODOUN + SX2->X2_MODOEMP


	//Posição dos campos dentro do arquivo CSV
	//Filial;CC;Conta;Descricao; Jan ; Fev ; Mar ; Abr ; Mai ; Jun ; Jul ; Ago ; Set ; Out ; Nov ; Dez
	PRIVATE A_FILIAL := 1
	PRIVATE A_CC     := 2
	PRIVATE A_CONTA  := 3
	PRIVATE A_P01    := 4
	PRIVATE A_P02    := 5
	PRIVATE A_P03    := 6
	PRIVATE A_P04    := 7
	PRIVATE A_P05    := 8
	PRIVATE A_P06    := 9
	PRIVATE A_P07    := 10
	PRIVATE A_P08    := 11
	PRIVATE A_P09    := 12
	PRIVATE A_P10    := 13
	PRIVATE A_P11    := 14
	PRIVATE A_P12    := 15



	If lRoda

		oDlg1      := MSDialog():New( D(095),D(232),D(427),D(740), cTitulo,,,.F.,,,,,,.T.,,,.T. )
		oGrp       := TGroup():New( D(004),D(004),D(146),D(250),"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
		oSay1      := TSay():New( D(009),D(008),{|| cTitulo+" ARQUIVO"},oGrp,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,D(064),D(016) )
		nTamGet	   := 230
		oGet1      := TGet():New( D(020),D(008),{|u| If(PCount()>0,cTPatch :=u,cTPatch)},oGrp,D(nTamGet),D(008),'',,CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,{|| /**/ },.F.,.F.,"","",,)
		nColIni    := 238
		oBtn1      := TButton():New( D(020),D(nColIni),"...",oGrp,{ || Arquivo()}, D(010), D(010),,,,.T.,,"",,,,.F. )

		oBrw1      := TWBrowse():New(D(032),D(008),D(235),D(110),,{'','Filial','Codigo','Descrição','Versão','Data Ini','Data Fim'},{20,20,20,30,20,20,20},oGrp,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )
		aBrowse    := LoadDados() // Carrega dados já processados da AK1
		oBrw1:SetArray(aBrowse)

		If Len(aBrowse) > 0
			oBrw1:bLine := {||{If(aBrowse[oBrw1:nAt,01],oGreen,oRed),;
				aBrowse[oBrw1:nAt,02],;
				aBrowse[oBrw1:nAt,03],;
				aBrowse[oBrw1:nAt,04],;
				aBrowse[oBrw1:nAt,05],;
				aBrowse[oBrw1:nAt,06],;
				aBrowse[oBrw1:nAt,07]} }
		EndIf

		//oBrw1:bLDblClick := {|| MostraArvore(),oBrw1:REFRESH()} //Comentado funcionalidade por gerar erro na montagem da árvore

		oBtn2      := TButton():New( D(150),D(036),"Importa Arquivo"  ,oDlg1,{|| Processa({||  OkLeTxt()},'Importando'+' Arquivo...','Processando...', .F.), oDlg1:Refresh()},D(037),D(012),,,,.T.,,"",,,,.F. )
		//oBtn4      := TButton():New( D(150),D(106),"Gera AK3"  ,oDlg1,{|| Processa({|| GeraAK3()},'Gerando'+' AK3...','Processando...', .F.), oDlg1:Refresh()},D(037),D(012),,,,.T.,,"",,bWhen,,.F. )
		oBtn4      := TButton():New( D(150),D(106),"Gera Estr.(AK3)"  ,oDlg1,{|| Processa({|| GeraAK3()},'Gerando estrutura (AK3)...','Processando...', .F.), oDlg1:Refresh()},D(037),D(012),,,,.T.,,"",,,,.F. )
		oBtn3      := TButton():New( D(150),D(166),"Sair",oDlg1,{|| oDlg1:End() },D(037),D(012),,,,.T.,,"",,,,.F. )

		oDlg1:Activate(,,,.T.,{||.T.})
	Else
		MsgInfo("Rotina esta desabilitada","Atenção")
	EndIf

Return



Static Function LoadDados(_aAK1)

	Local cQuery := ""
	Local nReg := 0

	DEFAULT _aAK1 := {}


	// Se a AK1 for Compartilhada ( como é na EMPRESA ), então sempre irá gravar como "  ", caso contrário pega da filial atual.
	//Local _cFil := IIF( cModAK1 == "CCC", "  ", xFilial( "AK1" ) )

	cQuery += "	SELECT AK1_FILIAL, AK1_CODIGO, AK1_VERSAO, AK1_DESCRI, AK1_INIPER, AK1_FIMPER "
	cQuery += "	  FROM " +RetSqlName('AK1')+" "
	cQuery += "	 WHERE D_E_L_E_T_ != '*' "
	cQuery += "	   AND AK1_FILIAL = '"+ xFilial( "AK1" )+"' "
	cQuery += "	 ORDER BY AK1_FILIAL, AK1_CODIGO "

	IIF(Select("SQL") != 0, SQL->( DbCloseArea() ), )

	MsAguarde({|| DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),'SQL',.F.,.F.)},'Aguarde...','' )

	DbSelectArea('SQL');DbGoTop()
	Do While SQL->( !Eof() )
		nReg++
		Aadd(aBrowse,{IIF(dDataBase > stod(SQL->AK1_FIMPER),.F.,.T.),;
			SQL->AK1_FILIAL,;
			SQL->AK1_CODIGO,;
			SQL->AK1_DESCRI,;
			SQL->AK1_VERSAO,;
			stod(SQL->AK1_INIPER),;
			stod(SQL->AK1_FIMPER)})

		// Depois de importado o arquivo, posiciona no mesmo

		If !Empty(_aAK1) .AND. AllTrim(SQL->AK1_CODIGO) + SQL->AK1_VERSAO == AllTrim(_aAK1[1]) + AllTrim(_aAK1[2])
			oBrw1:nAt := nReg
		EndIf

		DbSelectArea("SQL")
		DbSkip()
	EndDo

	If Empty(_aAK1)
		oBrw1:nAt := nReg
	Endif



Return( aBrowse )



/*/{Protheus.doc} OkLeTxt
Funcao chamada pelo botao OK na tela inicial de processamento. Executa a leitura do arquivo texto. 
@type function
@version 1
@author solutio
@since 08/07/2020
/*/
Static Function OkLeTxt
	Private lValidArq := .T.
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Abertura do arquivo texto                                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



	Private nHdl    := FT_FUSE(cTPatch)

	Private cEOL    := "CHR(13)+CHR(10)"

	If Empty(cEOL)
		cEOL := CHR(13)+CHR(10)
	Else
		cEOL := Trim(cEOL)
		cEOL := &cEOL
	Endif

	If nHdl == -1
		MsgAlert("O arquivo de nome "+ cTPatch +" nao pode ser aberto! Verifique os parametros.","Atencao!")
		Return
	Endif


	Processa({|| CopyToServer()},"Copiando Arquivo para o Servidor...")

	//If  Select(cArqTrab) <= 0
	Processa({|| Ler() },"Gerando Arquivo de Trabalho...")
	//Endif


	If !Empty(cLOGERRO)
		cLOGERRO := "*** Processamento Realizado com Inconsistências encontradas  ***" + ENTER + cLOGERRO
		GeraLog(cLOGERRO)
		cLOGERRO := ""

	Else

		Begin Transaction
			Processa({|| GeraAK2() },"Processando Arquivo...")
		End Transaction

		MsgInfo('ARQUIVO IMPORTADO COM SUCESSO!!!')
	EndIf



	IF SELECT( cArqTrab ) <> 0
		oTempTable:Delete()//(cArqTrab)->(DBCloseArea())
	ENDIF



Return

/*/{Protheus.doc} Ler
Faz a Leitura do Arquivo de Texto csv
@type function
@version  1
@author solutio
@since 03/02/2022
/*/
Static Function Ler()
	Local aTemp        := {}
	//Local cChave
	Local aTamSx3
	Local nTamSX3
	Local nCount       := 0
	Local nX
	Local lFilial      := .F.

	Local lPrim        := .T. //Pula Primeira Linha

	Local _id          := REPLICATE("0",TamSX3("AK2_ID" )[1])
	Local cCC_DESCR    := ""
	Local cCTA_DESCR   := ""

	Local cDadoTratado := "" //Variável de apoio na cruação do dado a ser preenchido na tabela

	//Verifica se arquivo pode ser aberto
	nHandle := FT_FUSE(cSPatch)
	if nHandle = -1
		MSGAlert("Erro abertura arquivo")
		//lValidArq := .F.
		return
	endif

	//Monta estrutura do arquivo de Trabalho

	aTamSx3 := TamSX3("AK2_ID" )
	AADD(aTemp,{ "ID"   ,  aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })

	aTamSx3 := TamSX3("AK2_FILIAL" )
	AADD(aTemp,{ "FILIAL"   , "C" ,aTamSx3[01], aTamSx3[02] })

	// Centro de Custo
	aTamSx3 := TamSX3("AK2_CC" )
	AADD(aTemp,{ "CC"      , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
	aTamSx3 := TamSX3("CTT_DESC01" )
	AADD(aTemp,{ "CC_DESCR"      , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })

	//Conta Orçamentária
	aTamSx3 := TamSX3("AK2_CO" )
	AADD(aTemp,{ "CTA_ORC"     , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] }) //F3 AK5
	TamSx3 := TamSX3("AK5_DESCRI" )
	AADD(aTemp,{ "CTA_DESCR"      , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })



	//Períodos
	aTamSx3 := TamSX3("AK2_VALOR" )
	AADD(aTemp,{ "P01"       , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
	AADD(aTemp,{ "P02"       , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
	AADD(aTemp,{ "P03"       , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
	AADD(aTemp,{ "P04"       , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
	AADD(aTemp,{ "P05"       , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
	AADD(aTemp,{ "P06"       , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
	AADD(aTemp,{ "P07"       , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
	AADD(aTemp,{ "P08"       , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
	AADD(aTemp,{ "P09"       , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
	AADD(aTemp,{ "P10"       , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
	AADD(aTemp,{ "P11"       , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })
	AADD(aTemp,{ "P12"       , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })



	//-------------------
	//Criação do objeto
	//-------------------
	//oTempTable := FWTemporaryTable():New( cAlias )

	oTempTable := FWTemporaryTable():New( cArqTrab, aTemp )
	oTempTable:AddIndex("01", {"ID"} )

	//oTempTable := FWTemporaryTable():New( cArqTrab, aTemp )
	//oTempTable:AddIndex("02", {"FILIAL","CC","CTA_ORC"} )


	//------------------
	//Criação da tabela
	//------------------
	oTempTable:Create()




	nTamFile := FT_FLastRec()
	ProcRegua(nTamFile)

	FT_FGOTOP()
	While !FT_FEOF()


		nCount++
		IncProc('Processando '+cValToChar(nCount)+' de '+cValToChar(nTamFile))


		If lPrim .AND.  nCount == 1 // Flag pula primeira linha - Cabeçalho
			cLinha := FT_FREADLN()
			aLinha:= StrTokArr2( cLinha , ";",.t. ) //Quebra considerando espaços vazios
			lFilial := UPPER(AllTrim(aLinha[A_FILIAL])) == 'FILIAL'
			FT_FSKIP()
			Loop
		EndIf

		cLinha := FT_FREADLN()

		//Se não tem coluna filial adiciona no arquivo de Linha
		If !lFilial
			cLinha := ";"+cLinha
		Endif
		aLinha:= StrTokArr2( cLinha , ";",.t. ) //Quebra considerando espaços vazios


		//Se não for numérico pula e volta para o laço
		If !Empty(aLinha[A_FILIAL]) .AND. IsAlpha(aLinha[A_FILIAL])
			FT_FSKIP()
			IW_MsgBox("Linha " + Alltrim(Str(nCount)) + ": Desconsiderada. Clique Ok para continuar.","Aviso","INFO")
			Loop
		Endif



		_id := Soma1(_id) // Para o campo AK2_ID

		aLinha:= StrTokArr2( cLinha , ";",.t. ) //Quebra considerando espaços vazios
		//AJUSTA REGISTROS PARA LAYOUT
		RecLock(cArqTrab,.T.) // Cria Registro
		(cArqTrab)->ID        := _id

		If lFilial
			cDadoTratado    := AllTrim(aLinha[A_FILIAL])
			cDadoTratado    := IF(Empty(cDadoTratado),xFilial("AK2"),cDadoTratado)
			If Len(cDadoTratado) > TamSX3("AK2_FILIAL" )[1]
				cLOGERRO += "Linha " + Alltrim(Str(nCount)) + ": Dado de Filial informado incorreto: " + AllTrim(aLinha[A_FILIAL]) + ENTER
			Endif
			(cArqTrab)->FILIAL    := cDadoTratado
		Else
			(cArqTrab)->FILIAL    := xFilial("AK2")
		Endif


		//CENTRO DE CUSTOS----------------------------------
		nTamSx3 := TamSX3("AK2_CC" )[1]
		cDadoTratado := AllTrim(SUBSTR(aLinha[A_CC],1,nTamSx3))
		cCC_DESCR := Posicione("CTT",1,xFilial("CTT")+cDadoTratado,"CTT->CTT_DESC01")
		(cArqTrab)->CC             := PadR(cDadoTratado , TamSX3("AK2_CC")[01] )
		(cArqTrab)->CC_DESCR       := cCC_DESCR


		IF Empty(cDadoTratado)
			cLOGERRO += "Linha " + Alltrim(Str(nCount)) + ": Centro de Custo Não Informado" + ENTER
		Endif
		If CTT->(!found())
			cLOGERRO += "Linha " + Alltrim(Str(nCount)) + ": Centro de Custo "+ cDadoTratado + " Inexistente" + ENTER
		Endif

		// CONTA ORÇAMENTÁRIA ------------------------------------------
		nTamSx3 := TamSX3("AK2_CO" )[1]
		cDadoTratado := SUBSTR(aLinha[A_CONTA],1,nTamSx3)
		cDadoTratado := AllTrim(STRTRAN(cDadoTratado,"-",""))
		cCTA_DESCR   := Posicione("AK5",1,xFilial("AK5")+cDadoTratado,"AK5->AK5_DESCRI") //AllTrim(SUBSTR(aLinha[A_CC],nTamSx3+1,TamSX3("CTT_DESC01")[01])) //retira a descrição do campo de Centtro de custo

		(cArqTrab)->CTA_ORC      := PadR(cDadoTratado , TamSX3("AK2_CO")[01] )
		(cArqTrab)->CTA_DESCR      := cCTA_DESCR

		IF Empty(cDadoTratado)
			cLOGERRO += "Linha " + Alltrim(Str(nCount)) + ": Conta Orçamentária Não Informada" + ENTER
		Endif
		If !Empty(cDadoTratado) .AND. AK5->(!found())
			cLOGERRO += "Linha " + Alltrim(Str(nCount)) + ": Conta Orçamentária"+ cDadoTratado + " Inexistente" + ENTER
		Endif



		//Períodos -------------------------------------------------------

		//Tratamento para ajustar campo lido para numérico antes de gravar
		FOR nX := 1 to 12
			aLinha[&("A_P"+AllTrim(StrZero(nX,2)))] := STRTRAN(aLinha[&("A_P"+AllTrim(StrZero(nX,2)))],"-","0") //Numero negativo ou sinal de negativo, transforma em ZERO
			aLinha[&("A_P"+AllTrim(StrZero(nX,2)))] := STRTRAN(aLinha[&("A_P"+AllTrim(StrZero(nX,2)))],"R$","") //Retira Moeda
			aLinha[&("A_P"+AllTrim(StrZero(nX,2)))] := STRTRAN( STRTRAN( AllTrim( aLinha[&("A_P"+AllTrim(StrZero(nX,2)))] ), '.', '' ), ',', '.' ) //Trata números: Retira ponto de Milhar e substitui virgula por ponto
		NEXT nX

		If IsDigit(AllTrim(aLinha[A_P01]))
			(cArqTrab)->P01        := VAL(aLinha[A_P01])
		Else
			cLOGERRO += "Linha " + Alltrim(Str(nCount)) + ": Dado de Janeiro inconsistente: " + AllTrim(aLinha[A_P01]) + ENTER
		Endif
		If IsDigit(AllTrim(aLinha[A_P02]))
			(cArqTrab)->P02        := VAL(aLinha[A_P02])
		Else
			cLOGERRO += "Linha " + Alltrim(Str(nCount)) + ": Dado de Fevereiro inconsistente" + AllTrim(aLinha[A_P02]) + ENTER
		Endif
		If IsDigit(AllTrim(aLinha[A_P03]))
			(cArqTrab)->P03        := VAL(aLinha[A_P03])
		Else
			cLOGERRO += "Linha " + Alltrim(Str(nCount)) + ": Dado de Março inconsistente" + AllTrim(aLinha[A_P03]) + ENTER
		Endif
		If IsDigit(AllTrim(aLinha[A_P04]))
			(cArqTrab)->P04        := VAL(aLinha[A_P04])
		Else
			cLOGERRO += "Linha " + Alltrim(Str(nCount)) + ": Dado de Abril inconsistente" + AllTrim(aLinha[A_P04]) + ENTER
		Endif
		If IsDigit(AllTrim(aLinha[A_P05]))
			(cArqTrab)->P05        := VAL(aLinha[A_P05])
		Else
			cLOGERRO += "Linha " + Alltrim(Str(nCount)) + ": Dado de Maio inconsistente" + AllTrim(aLinha[A_P05]) + ENTER
		Endif
		If IsDigit(AllTrim(aLinha[A_P06]))
			(cArqTrab)->P06        := VAL(aLinha[A_P06])
		Else
			cLOGERRO += "Linha " + Alltrim(Str(nCount)) + ": Dado de Junho inconsistente" + AllTrim(aLinha[A_P06]) + ENTER
		Endif
		If IsDigit(AllTrim(aLinha[A_P07]))
			(cArqTrab)->P07        := VAL(aLinha[A_P07])
		Else
			cLOGERRO += "Linha " + Alltrim(Str(nCount)) + ": Dado de Julho inconsistente" + AllTrim(aLinha[A_P07]) + ENTER
		Endif
		If IsDigit(AllTrim(aLinha[A_P08]))
			(cArqTrab)->P08        := VAL(aLinha[A_P08])
		Else
			cLOGERRO += "Linha " + Alltrim(Str(nCount)) + ": Dado de Agosto inconsistente" + AllTrim(aLinha[A_P08]) + ENTER
		Endif
		If IsDigit(AllTrim(aLinha[A_P09]))
			(cArqTrab)->P09        := VAL(aLinha[A_P09])
		Else
			cLOGERRO += "Linha " + Alltrim(Str(nCount)) + ": Dado de Setembro inconsistente" + AllTrim(aLinha[A_P09]) + ENTER
		Endif
		If IsDigit(AllTrim(aLinha[A_P10]))
			(cArqTrab)->P10        := VAL(aLinha[A_P10])
		Else
			cLOGERRO += "Linha " + Alltrim(Str(nCount)) + ": Dado de Outubro inconsistente" + AllTrim(aLinha[A_P10]) + ENTER
		Endif
		If IsDigit(AllTrim(aLinha[A_P11]))
			(cArqTrab)->P11        := VAL(aLinha[A_P11])
		Else
			cLOGERRO += "Linha " + Alltrim(Str(nCount)) + ": Dado de Novembro inconsistente" + AllTrim(aLinha[A_P11]) + ENTER
		Endif
		If IsDigit(AllTrim(aLinha[A_P12]))
			(cArqTrab)->P12        := VAL(aLinha[A_P12])
		Else
			cLOGERRO += "Linha " + Alltrim(Str(nCount)) + ": Dado de Dezembro inconsistente" + AllTrim(aLinha[A_P12]) + ENTER
		Endif

		MSUnLock()

		FT_FSKIP()
	EndDo
	FT_FUSE()


Return

/*/{Protheus.doc} GeraAK2
Rotina que gera a Planilha e chama outras funções auxiliares
@type function
@version  1
@author solutio
@since 03/02/2022
/*/
Static Function GeraAK2()


	//Local cLinha	:= ""
	//Local aContCsv	:= {}
	Local _lRet		:= .T.
	Local _a		:= 0
	//Local _z		:= 0
	//Local _aDados	:= {}
	Local nCount	:= 0
	Local _id		:= "0000"
	//Local aErro		:= {}

	Local _aAK1		:= {}
	Local _lAk1		:= .T.


	DBSelectArea(cArqTrab)
	(cArqTrab)->(DBGotop())

	If (cArqTrab)->(EOF())
		MsgInfo('Não foi possivel gerar o arquivo de trabalho ou arquivo de trabalho vazio. Criação de Planilha abortada')
		lRet := .F.
	Endif

	nTotReg := (cArqTrab)->(RecCount())
	Do While (cArqTrab)->(!EOF())

		nCount++
		IncProc('Processando '+cValToChar(nCount)+' de '+cValToChar(nTotReg))

		If _lAk1
			_aAK1 := GeraAK1((cArqTrab)->FILIAL )
			_lak1 := .F.
		EndIf

		_id := Soma1(_id) // Para o campo AK2_ID

		If Len(_aAK1) > 0
			DbSelectArea('AK2')

			For _a := 1 To 12
				RecLock('AK2',.T.)
				AK2->AK2_FILIAL := (cArqTrab)->FILIAL
				AK2->AK2_ID     := _id
				AK2->AK2_ORCAME := _aAK1[1]
				AK2->AK2_VERSAO := _aAK1[2]
				AK2->AK2_CO     := (cArqTrab)->CTA_ORC
				AK2->AK2_CLASSE := "000001"
				AK2->AK2_OPER   := "10"
				AK2->AK2_MOEDA  := 1
				AK2->AK2_CC	    := (cArqTrab)->CC
				AK2->AK2_DESCRI := (cArqTrab)->CC_DESCR
				AK2->AK2_PERIOD := CTOD(aPeriodos[_a])

				//SCI não usa item conta
				//If cModAK1 == "CCC"
				//	AK2->AK2_ITCTB := AllTrim( SM0->M0_CODIGO ) + aContCsv[A_FILIAL]
				//EndIf

				AK2->AK2_VALOR :=  (cArqTrab)->&("P"+AllTrim(STRZERO(_a,2)))
				AK2->AK2_DATAI  := CTOD(aPeriodos[_a])
				AK2->AK2_DATAF  := LastDay(CTOD(aPeriodos[_a]),0)
				AK2->(MsUnlock())
			Next
			AK2->(DbCloseArea())
		Else

			MsgInfo('Não foi possivel importar planilha pois já foi criada/Importada planilha do período. Importaçao abortada')
			_lRet := .F.
			EXIT
		EndIf
		(cArqTrab)->(DBSkip())
	EndDo

	If SELECT(cArqTrab) > 0
		(cArqTrab)->(DBCloseArea())
	Endif

   /*
	If _lRet
		Processa({|| GeraAK3(xFilial("AK1"),aAK1[1])},'Gerando Estrutura da Planiha(AK3) Filial ' + xFilial("AK1") + ' Código ' + aAK1[1] + '...','Processando...', .F.)
	Endif
	*/


	// Atualiza o Browse com o os dados da AK1
	aBrowse := {}
	LoadDados(_aAK1)
	oBrw1:SetArray(aBrowse)
	If Len(aBrowse) > 0
		oBrw1:bLine := {||{If(aBrowse[oBrw1:nAt,01],oGreen,oRed),;
			aBrowse[oBrw1:nAt,02],;
			aBrowse[oBrw1:nAt,03],;
			aBrowse[oBrw1:nAt,04],;
			aBrowse[oBrw1:nAt,05],;
			aBrowse[oBrw1:nAt,06],;
			aBrowse[oBrw1:nAt,07]} }
	EndIf


Return( _lRet )


/*/{Protheus.doc} GeraAK1
Gera Cabeçalho de Panilha (AK1)
@type function
@version  1
@author solutio
@since 03/02/2022
@param _cFilial, variant, filial
/*/
Static Function GeraAK1(_cFilial)

	Local _lRet := .F.
	Local _cVersao := "0001"
	Local _nSeq    := CountTotPla(_cFilial)
	Local _cCodigo := ""

	Local _Tipo    := "3"
	Local _dDtaYIni := FirstYDate( dDataBase )
	Local _dDtaYFim := LastYDate( dDataBase )
	//Local _cTrUsr  := "1"
	Local _cStatus := "1"

	Local _aRet := {}
	Local nTamCod := TamSX3("AK1_CODIGO")[1]


	_nSeq := StrZero(_nSeq,8)

	// Preenche com espaços o que vai gravar no campo Codigo conforme o tamanho do próprio campo
	// Na EMPRESA o compartilhamento das tabelas da AK* são Compartilhadas, então será colocado o "00" no lugar da filial.
//		_cCodigo := PadR( IIF( cModAK1 == "C", "00", _cFilial )+_cVersao+cValToChar(_nSeq), nTamCod, "" )
	_cCodigo := PadR( YEAR(dDataBase), nTamCod, "" )

	//MsgInfo("_cCodigo: " + _cCodigo + ENTER + "Chave: " + _cFilial+_cCodigo+_cVersao )

	DbSelectArea('AK1')
	AK1->(DbSetOrder(1))
	If !DbSeek(_cFilial+_cCodigo+_cVersao)
		If RecLock('AK1', .T.)
			AK1->AK1_FILIAL :=  xFilial("AK1")
			AK1->AK1_CODIGO	:=  _cCodigo
			AK1->AK1_VERSAO	:=  _cVersao
			AK1->AK1_NMAX	:=  2
			AK1->AK1_DESCRI	:=  "ORCAMENTO EXERCICIO " + StrZero(YEAR(dDataBase),4) + " - Imp CSV: " + cArqCsv
			AK1->AK1_TPREV	:=  "1"
			AK1->AK1_FASE	:=  "001"
			AK1->AK1_TPPERI :=  _Tipo
			AK1->AK1_INIPER	:=  _dDtaYIni
			AK1->AK1_FIMPER	:=  _dDtaYFim
			AK1->AK1_CTRUSR :=  "2"
			AK1->AK1_STATUS :=  _cStatus
			AK1->(MsUnLock())
			_lRet := .T.
		EndIf
	EndIf
	AK1->(DbCloseArea())

	If _lRet
		_aRet := {_cCodigo,_cVersao}
		Return( _aRet )
	EndIf


Return( _aRet )

//NOVA VERSÃO 
Static Function GeraAK3(_cFilial,_cCodigo )
	//Local cQry       := ""

	Local cQuery     := ""

	Local aTemp      := {}
	Local aSetField  := {}


	Local nCount     := 0
	Local nTotReg    := 0

	Local cTempFil   := cFilAnt


	Private aCtaPlan := {}
	Private nNivAtu  := 1

	Private cTrabAK3 := GETNEXTALIAS()

	DEFAULT _cFilial := aBrowse[oBrw1:nAt][2]
	DEFAULT _cCodigo := aBrowse[oBrw1:nAt][3]

	If Empty( aBrowse )
		MsgInfo( "Sem dados para gerar a AK3" )
		Return
	EndIf

	//Begin Transaction
	If ValidaAK3( _cFilial, _cCodigo )

		cQuery:=" SELECT "
		cQuery+="	  AK1_FILIAL, "
		cQuery+="	  AK1_CODIGO, "
		cQuery+="	  AK1_VERSAO, "
		cQuery+="	  AK1_DESCRI "
		cQuery+=" FROM "
		cQuery+= RETSQLNAME("AK1")+" AK1 "
		cQuery+=" WHERE "
		cQuery+="	  AK1_FILIAL      = '"+ xFilial("AK1") +"' "
		cQuery+="	  AND AK1_CODIGO  = '"+ _cCodigo +"' "
		cQuery+="	  AND AK1.D_E_L_E_T_ = ' ' "

		IIF(Select('TMPAK1') != 0, TMPAK1->( DbCLoseArea() ), )

		MsAguarde({|| DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),'TMPAK1',.F.,.F.)},'Aguarde...','' )

		DbSelectArea('TMPAK1')
		TMPAK1->(DbGoTop())
		Do While TMPAK1->(!Eof())

			//Gera arquivo de trabalho
			//Campos
			aTamSx3 := TamSX3("AK5_CODIGO" )
			AADD(aTemp,{ "AK5_CODIGO"       , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })

			aTamSx3 := TamSX3("AK5_DESCRI" )
			AADD(aTemp,{ "AK5_DESCRI"       , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })

			aTamSx3 := TamSX3("AK5_TIPO" )
			AADD(aTemp,{ "AK5_TIPO"       , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })


			aTamSx3 := TamSX3("AK5_COSUP" )
			AADD(aTemp,{ "AK5_COSUP"       , aTamSx3[03] ,aTamSx3[01], aTamSx3[02] })


			//Variáveis de controle
			AADD(aTemp,{ "NIVEL"       , "N" ,2, 0 })
			//AADD(aTemp,{ "GRAVA"       , "N" ,1, 0 })




			//-------------------
			//Criação do objeto
			//-------------------
			//oTempTable := FWTemporaryTable():New( cAlias )

			oTempAK3 := FWTemporaryTable():New( cTrabAK3, aTemp )
			oTempAK3:AddIndex("01", {"AK5_CODIGO","AK5_COSUP"} )

			//oTempAK3 := FWTemporaryTable():New( cTrabAK3, aTemp )
			//oTempAK3:AddIndex("02", {"AK5_COSUP","AK5_CODIGO")


			//------------------
			//Criação da tabela
			//------------------
			oTempAK3:Create()


			aSetField := {}
			AADD(aSetField,{"NIVEL","N",4,0})

			//Consulta Recursiva em SQL para gerar AK3: vide https://comunidadesqlserver.wordpress.com/2014/09/17/trabalhando-com-dados-hierarquicos-parte-iii/
			cQuery :=  ""
			cQuery+=" WITH ESTR AS ("
			//-- MEMBRO ÂNCORA - COMEÇA EM 2 POIS O NIVEL 1 É O CABEÇALHO
			cQuery+=" 	SELECT AK5_CODIGO, AK5_DESCRI , AK5_TIPO, AK5_COSUP, 2 AS NIVEL FROM AK5010 WHERE AK5_FILIAL = '  ' AND D_E_L_E_T_ = ' ' AND AK5_COSUP =  ' ' AND AK5_MSBLQL  = '2'"
			cQuery+="   	 UNION ALL"
			//-- FILHOS
			cQuery+=" 	SELECT FILHO.AK5_CODIGO, FILHO.AK5_DESCRI , FILHO.AK5_TIPO, FILHO. AK5_COSUP, PAI.NIVEL +1  NIVEL "
			cQuery+=" 			FROM ESTR AS PAI "
			cQuery+=" 					JOIN AK5010 AS FILHO "
			cQuery+=" 					  ON PAI.AK5_CODIGO = FILHO.AK5_COSUP "
			cQuery+=" 					WHERE FILHO. AK5_FILIAL = '  ' AND FILHO.D_E_L_E_T_ = ' ' "

			cQuery+=" )

			//-- FAZENDO O JOIN PARA TRAZER OS DADOS

			cQuery+=" 			SELECT S.* FROM ESTR AS S JOIN AK5010  AS P ON S.AK5_CODIGO = P.AK5_CODIGO WHERE P.AK5_FILIAL = ' ' AND P.D_E_L_E_T_  = ' ' AND P.AK5_MSBLQL  = '2' ORDER BY NIVEL,P.AK5_CODIGO

			MPSysOpenQuery( cQuery, 'TMPNIVEL',aSetField  ) // TcQuery cQuery New Alias "QRY"




			Do While TMPNIVEL->(!Eof())
				RecLock(cTrabAK3, .T.)
				(cTrabAK3)->AK5_CODIGO := TMPNIVEL->AK5_CODIGO
				(cTrabAK3)->AK5_DESCRI := TMPNIVEL->AK5_DESCRI
				(cTrabAK3)->AK5_TIPO   := TMPNIVEL->AK5_TIPO
				(cTrabAK3)->AK5_COSUP  := TMPNIVEL->AK5_COSUP
				(cTrabAK3)->NIVEL      := TMPNIVEL->NIVEL
				//(cTrabAK3)->GRAVA      := 0
				MsUnLock()

				TMPNIVEL->(DbSkip())
			EndDo

			If !lImpTodoPlanAK3
				//****************************************************
				// LIMPA EXTRUTURA SEM VÍNCULO COM CONTAS IMPORTADAS
				//****************************************************


				// Limpa todas as contas analiticas que não estão dentro da AK2
				cQryDel := 'DELETE ' + oTempAK3:GetRealName() + " WHERE AK5_TIPO = '2' AND NOT EXISTS (SELECT * FROM " + RetSqlName("AK2") + " AS AK2 WHERE"
				cQryDel+="	  AK2.AK2_FILIAL     = '"+TMPAK1->AK1_FILIAL+"' "
				cQryDel+="	  AND AK2.AK2_ORCAME = '"+TMPAK1->AK1_CODIGO+"' "
				cQryDel+="	  AND AK2.AK2_VERSAO = '" +TMPAK1->AK1_VERSAO+"' "
				cQryDel+="	  AND AK2.AK2_CO = AK5_CODIGO"
				cQryDel+="	  AND AK2.D_E_L_E_T_ = ' ' "
				cQryDel+="   )"

				nStatus := TCSqlExec(cQryDel)
				if (nStatus < 0)
					If !isBlind()
						MsgInfo("Falha ao apagar registros da tabela temporária. TCSQLError(): " + TCSQLError(),"Atenção")
					Else
						conout("TCSQLError() " + TCSQLError())
					Endif
				endif


				lContinua := .T.

				Do While lContinua
					cSql := "SELECT '1' FOUND FROM " + oTempAK3:GetRealName() + " WHERE AK5_TIPO = '1' "
					cSql += "        AND NOT EXISTS (SELECT '1' FOUND FROM " + oTempAK3:GetRealName() + " FILHO WHERE FILHO.AK5_COSUP = " + oTempAK3:GetRealName() + ".AK5_CODIGO )"

					lContinua := MpSysExecScalar( cSql, "FOUND" ) == '1'

					If lContinua
						cQryDel := "DELETE " + oTempAK3:GetRealName() + " WHERE AK5_TIPO = '1' "
						cQryDel += "        AND NOT EXISTS (SELECT '1' FOUND FROM " + oTempAK3:GetRealName() + " FILHO WHERE FILHO.AK5_COSUP = " + oTempAK3:GetRealName() + ".AK5_CODIGO )"


						nStatus := TCSqlExec(cQryDel)
						if (nStatus < 0)
							If !isBlind()
								MsgInfo("Falha ao apagar registros da tabela temporária. TCSQLError(): " + TCSQLError(),"Atenção")
							Else
								conout("TCSQLError() " + TCSQLError())
							Endif
						endif

					Endif

				Enddo

			Endif

			(cTrabAK3)->(DBGotop())
			nTotReg    := (cTrabAK3)->(RecCount())
			nCount     := 0

			Do While (cTrabAK3)->(!EOF())
				nCount++

				If nCount == 1
					//Cria cabeçalho do Plano Orç
					If !AK3->( dbSeek(xFilial("AK3")+TMPAK1->AK1_CODIGO+TMPAK1->AK1_VERSAO+TMPAK1->AK1_CODIGO) )
						RecLock("AK3", .T.)
						AK3_FILIAL := xFilial("AK3")
						AK3_ORCAME := TMPAK1->AK1_CODIGO
						AK3_VERSAO := TMPAK1->AK1_VERSAO
						AK3_CO     := TMPAK1->AK1_CODIGO
						AK3_NIVEL  := StrZero(1, Len(AK3->AK3_NIVEL))
						AK3_DESCRI := TMPAK1->AK1_DESCRI
						MsUnLock()
					Endif
				Endif


				If !AK3->( dbSeek(xFilial("AK3")+TMPAK1->AK1_CODIGO+TMPAK1->AK1_VERSAO+(cTrabAK3)->AK5_CODIGO) )
					RecLock("AK3", .T.)
					AK3_FILIAL := xFilial("AK3")
					AK3_ORCAME := TMPAK1->AK1_CODIGO
					AK3_VERSAO := TMPAK1->AK1_VERSAO
					AK3_DESCRI := (cTrabAK3)->AK5_DESCRI
					AK3_TIPO   := (cTrabAK3)->AK5_TIPO
					AK3_NIVEL  := StrZero((cTrabAK3)->NIVEL, Len(AK3->AK3_NIVEL))
					AK3_CO     := (cTrabAK3)->AK5_CODIGO
					If (cTrabAK3)->NIVEL == 2
						AK3_PAI    := TMPAK1->AK1_CODIGO
					Else
						AK3_PAI    := (cTrabAK3)->AK5_COSUP
					Endif
					MsUnLock()
				Endif





				(cTrabAK3)->(DbSkip())
			EndDo


			IF SELECT( cTrabAK3 ) <> 0
				oTempAK3:Delete()//(cTrabAK3)->(DBCloseArea())
			ENDIF


			TMPNIVEL->(DbCloseArea())


			TMPAK1->(DbSkip())

		Enddo
		TMPAK1->(DbCloseArea())
	Else
		MsgInfo("Já foram gerados registros para esta planilha na tabela de Estrutura do Orçamento(AK3). A rotina não sera executada","Atenção")
	EndIf

//End Transaction

	cFilAnt := cTempFil
Return
/*/{Protheus.doc} GeraAK3
Gera a Estrutura orçamentária para apresentação em Tela
@type function
@version  1
@author solutio
@since 03/02/2022
@param _cFilial, variant, Filial
@param _cCodigo, variant, Planilha
/*/
/*
Static Function GeraAK3(_cFilial,_cCodigo )
	//Local cQry       := ""

	Local cQuery   := ""

	Local aSetField := {}


	Local nCount     := 0
	Local nTotReg    := 0

	Local cTempFil   := cFilAnt


	Private aCtaPlan := {}
	Private nNivAtu  := 1

	DEFAULT  _cFilial := aBrowse[oBrw1:nAt][2]
	DEFAULT _cCodigo  := aBrowse[oBrw1:nAt][3]

	If Empty( aBrowse )
		MsgInfo( "Sem dados para gerar a AK3" )
		Return
	EndIf

	//Begin Transaction
	If ValidaAK3( _cFilial, _cCodigo )

		cQuery:=" SELECT "
		cQuery+="	  AK1_FILIAL, "
		cQuery+="	  AK1_CODIGO, "
		cQuery+="	  AK1_VERSAO, "
		cQuery+="	  AK1_DESCRI "
		cQuery+=" FROM "
		cQuery+= RETSQLNAME("AK1")+" AK1 "
		cQuery+=" WHERE "
		cQuery+="	  AK1_FILIAL      = '"+ xFilial("AK1") +"' "
		cQuery+="	  AND AK1_CODIGO  = '"+ _cCodigo +"' "
		cQuery+="	  AND AK1.D_E_L_E_T_ = ' ' "

		IIF(Select('TMPAK1') != 0, TMPAK1->( DbCLoseArea() ), )

		MsAguarde({|| DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),'TMPAK1',.F.,.F.)},'Aguarde...','' )

		DbSelectArea('TMPAK1')
		TMPAK1->(DbGoTop())
		Do While TMPAK1->(!Eof())

			DBSelectArea("AK3")
			DBSetOrder(1)


			aSetField := {}
			AADD(aSetField,{"NIVEL","N",4,0})

			//Consulta Recursiva em SQL para gerar AK3: vide https://comunidadesqlserver.wordpress.com/2014/09/17/trabalhando-com-dados-hierarquicos-parte-iii/
			cQuery :=  ""
			cQuery+=" WITH ESTR AS ("
			//-- MEMBRO ÂNCORA - COMEÇA EM 2 POIS O NIVEL 1 É O CABEÇALHO
			cQuery+=" 	SELECT AK5_CODIGO, AK5_DESCRI , AK5_TIPO, AK5_COSUP, 2 AS NIVEL FROM AK5010 WHERE AK5_FILIAL = '  ' AND D_E_L_E_T_ = ' ' AND AK5_COSUP =  ' ' AND AK5_MSBLQL  = '2'"
			cQuery+="   	 UNION ALL"
			//-- FILHOS
			cQuery+=" 	SELECT FILHO.AK5_CODIGO, FILHO.AK5_DESCRI , FILHO.AK5_TIPO, FILHO. AK5_COSUP, PAI.NIVEL +1  NIVEL "
			cQuery+=" 			FROM ESTR AS PAI "
			cQuery+=" 					JOIN AK5010 AS FILHO "
			cQuery+=" 					  ON PAI.AK5_CODIGO = FILHO.AK5_COSUP "
			cQuery+=" 					WHERE FILHO. AK5_FILIAL = '  ' AND FILHO.D_E_L_E_T_ = ' ' "

			cQuery+=" )

			//-- FAZENDO O JOIN PARA TRAZER OS DADOS

			cQuery+=" 			SELECT S.* FROM ESTR AS S JOIN AK5010  AS P ON S.AK5_CODIGO = P.AK5_CODIGO WHERE P.AK5_FILIAL = ' ' AND P.D_E_L_E_T_  = ' ' AND P.AK5_MSBLQL  = '2' ORDER BY NIVEL,P.AK5_CODIGO

			MPSysOpenQuery( cQuery, 'TMPAK3',aSetField  ) // TcQuery cQuery New Alias "QRY"


			nCount     := 0
			nTotReg    := TMPAK3->(RecCount())

			Do While TMPAK3->(!Eof())
				nCount++
				If nCount == 1
					//Cria cabeçalho do Plano Orç
					If !AK3->( dbSeek(xFilial("AK3")+TMPAK1->AK1_CODIGO+TMPAK1->AK1_VERSAO+TMPAK1->AK1_CODIGO) )
						RecLock("AK3", .T.)
						AK3_FILIAL := xFilial("AK3")
						AK3_ORCAME := TMPAK1->AK1_CODIGO
						AK3_VERSAO := TMPAK1->AK1_VERSAO
						AK3_CO     := TMPAK1->AK1_CODIGO
						AK3_NIVEL  := StrZero(1, Len(AK3->AK3_NIVEL))
						AK3_DESCRI := TMPAK1->AK1_DESCRI
						MsUnLock()
					Endif
				Else
					If !AK3->( dbSeek(xFilial("AK3")+TMPAK1->AK1_CODIGO+TMPAK1->AK1_VERSAO+TMPAK3->AK5_CODIGO) )
						RecLock("AK3", .T.)
						AK3_FILIAL := xFilial("AK3")
						AK3_ORCAME := TMPAK1->AK1_CODIGO
						AK3_VERSAO := TMPAK1->AK1_VERSAO
						AK3_DESCRI := TMPAK3->AK5_DESCRI
						AK3_TIPO   := TMPAK3->AK5_TIPO
						AK3_NIVEL  := StrZero(TMPAK3->NIVEL, Len(AK3->AK3_NIVEL))
						AK3_CO     := TMPAK3->AK5_CODIGO
						If TMPAK3->NIVEL == 2
							AK3_PAI    := TMPAK1->AK1_CODIGO
						Else
							AK3_PAI    := TMPAK3->AK5_COSUP
						Endif
						MsUnLock()
					Endif
				Endif

				TMPAK3->(DbSkip())
			EndDo



			aCtaPlan:={}
			TMPAK1->(DbSkip())
		EndDo

		TMPAK3->(DbCloseArea())
		TMPAK1->(DbCloseArea())

		AK5->(DbCloseArea())
	Else
		MsgInfo("Já foram gerados registros para esta planilha na tabela de Estrutura do Orçamento(AK3). A rotina não sera executada","Atenção")
	EndIf

//End Transaction

	cFilAnt := cTempFil
Return
*/
/*
Static Function old_GeraAK3(_cFilial,_cCodigo )
	Local cQry       := ""
	Local cQuery     := ""
	Local nCount     := 0
	Local nTotReg    := 0

	Local cTempFil   := cFilAnt


	Private aCtaPlan := {}
	Private nNivAtu  := 1

	DEFAULT  _cFilial := aBrowse[oBrw1:nAt][2]
	DEFAULT _cCodigo  := aBrowse[oBrw1:nAt][3]

	If Empty( aBrowse )
		MsgInfo( "Sem dados para gerar a AK3" )
		Return
	EndIf

	//Begin Transaction
	If ValidaAK3( _cFilial, _cCodigo )

		cQuery:=" SELECT "
		cQuery+="	  AK1_FILIAL, "
		cQuery+="	  AK1_CODIGO, "
		cQuery+="	  AK1_VERSAO "
		cQuery+=" FROM "
		cQuery+= RETSQLNAME("AK1")+" AK1 "
		cQuery+=" WHERE "
		cQuery+="	  AK1_FILIAL      = '"+ xFilial("AK1") +"' "
		cQuery+="	  AND AK1_CODIGO  = '"+ _cCodigo +"' "
		cQuery+="	  AND AK1.D_E_L_E_T_ = ' ' "

		IIF(Select('TMPAK1') != 0, TMPAK1->( DbCLoseArea() ), )

		MsAguarde({|| DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQuery),'TMPAK1',.F.,.F.)},'Aguarde...','' )

		DbSelectArea('TMPAK1')
		TMPAK1->(DbGoTop())
		Do While TMPAK1->(!Eof())
			nNivAtu := 1
			aCtaPlan:={}
			aAdd(aCtaPlan, {"AK1",nNivAtu})
			aAdd(aCtaPlan, {"AK1"+TMPAK1->AK1_CODIGO,nNivAtu})
			nNivAtu++

			cQry:=" SELECT "
			cQry+="	  DISTINCT(AK2.AK2_CO), "
			cQry+="	  AK2.AK2_ORCAME, "
			cQry+="	  AK2.AK2_VERSAO "
			cQry+=" FROM "
			cQry+= RETSQLNAME("AK2")+" AK2 "
			cQry+=" WHERE "
			cQry+="	  AK2.AK2_FILIAL     = '"+TMPAK1->AK1_FILIAL+"' "
			cQry+="	  AND AK2.AK2_ORCAME = '"+TMPAK1->AK1_CODIGO+"' "
			cQry+="	  AND AK2.AK2_VERSAO = '" +TMPAK1->AK1_VERSAO+"' "
			cQry+="	  AND AK2.D_E_L_E_T_ = ' ' "

			IIF(Select('TMPAK2') != 0, TMPAK2->( DbCLoseArea() ), )

			MsAguarde({|| DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQry),'TMPAK2',.F.,.F.)},'Aguarde...','' )

			nTotReg := TMPAK2->(RecCount())


			DbSelectArea('TMPAK2')
			TMPAK2->(DbGoTop())
			Do While TMPAK2->(!Eof())
				nCount++
				IncProc('Processando '+cValToChar(nCount)+' de '+cValToChar(nTotReg))
				DbSelectArea("AK5")
				AK5->(DbSetOrder(1))
				If DbSeek(xFilial("AK5")+TMPAK2->AK2_CO)

					PcoCtaAddPlan(TMPAK2->AK2_ORCAME, AK5->AK5_COSUP, @nNivAtu,.F.)
					aAdd(aCtaPlan, {"AK5"+AK5->AK5_CODIGO, nNivAtu})


					PCOChkDir(aCtaPlan,TMPAK1->AK1_CODIGO)
					nNivAtu:=1
					aCtaPlan:={}
					aAdd(aCtaPlan, {"AK1"+TMPAK1->AK1_CODIGO,1})
					nNivAtu++

				EndIf
				TMPAK2->(DbSkip())
			EndDo
			aCtaPlan:={}
			TMPAK1->(DbSkip())
		EndDo

		TMPAK2->(DbCloseArea())
		TMPAK1->(DbCloseArea())

		AK5->(DbCloseArea())
	Else
		MsgInfo("Já foram gerados registros para esta planilha na tabela de Estrutura do Orçamento(AK3). A rotina não sera executada","Atenção")
	EndIf

	//End Transaction

	cFilAnt := cTempFil
Return
*/


/*/{Protheus.doc} ValidaAK3
Verifica a existência de registro na AK3
@type function
@version  1
@author solutio
@since 03/02/2022
@param _cFilial, variant, filial
@param _cCodigo, variant, código planilha
/*/
Static Function ValidaAK3(_cFilial,_cCodigo)
	Local lRet := .F.

	DbSelectArea("AK3")
	AK3->(DbSetOrder(1))
	If !DbSeek(_cFilial+_cCodigo,.F.)
		lRet := .T.
	EndIf
Return lRet



/*/{Protheus.doc} PCOChkDir
Função chamada na versão antiga do montagem do AK3
@type function
@version  1
@author solutio
@since 03/02/2022
@param aCtaPlan, array, conta
@param _cCodigo, variant, codigo da planilha

/*/
Static Function PCOChkDir(aCtaPlan,_cCodigo)

	Local nX
	//Local lRet := .T.
	Local cRevisa := "0001"
	Local aPlanCta := aClone(aCtaPlan)

	ASORT(aCtaPlan,,, { |x, y| y[2] < x[2] })
	ASORT(aPlanCta,,, { |x, y| x[2] < y[2] })

	DbSelectArea('AK5')
	AK5->(DbGoTop())

	dbSelectArea("AK3")
	dbSetOrder(1)

	For nX := 2 TO Len(aPlanCta)
		If !AK3->( dbSeek(xFilial("AK3")+_cCodigo+cRevisa+Subs(aPlanCta[nX][1],4)) )
			RecLock("AK3", .T.)
			AK3_FILIAL := xFilial("AK3")
			AK3_ORCAME := _cCodigo
			AK3_VERSAO := cRevisa
			AK3_CO := Subs(aPlanCta[nX][1],4)
			AK3_PAI := Subs(aPlanCta[nX-1][1],4)

			If AK5->(dbSeek(xFilial("AK5")+Subs(aPlanCta[nX][1],4)))
				AK3_TIPO := AK5->AK5_TIPO
				AK3_NIVEL := StrZero(aPlanCta[nX][2], Len(AK3->AK3_NIVEL))
				AK3_DESCRI := AK5->AK5_DESCRI
			EndIf
			MsUnLock()
		Endif

	Next

return(nil)



/*/{Protheus.doc} CountTotPla
Usado no GeraAK1 para contagem de planilhas geradas
@type function
@version  1
@author solutio
@since 03/02/2022
@param _cFilial, variant, filial
/*/
Static Function CountTotPla(_cFilial)
	Local nTot  := 0
	Local _cQry := ""

	// Alterado para pegar o maior CODIGO existente
	_cQry := "SELECT MAX( SUBSTRING( AK1_CODIGO, 7, 8 ) ) AS TOTAL "
//	_cQry := "SELECT COUNT(*) AS TOTAL "
	_cQry += "FROM "+ RETSQLNAME("AK1") +" "
	_cQry += "WHERE D_E_L_E_T_ = ' ' "
	_cQry += "AND AK1_FILIAL = '"+_cFilial+"' "

	IIF(Select('TMPAK1') != 0, TMPAK1->( DbCLoseArea() ), )

	MsAguarde({|| DbUseArea(.T.,'TOPCONN',TcGenQry(,,_cQry),'TMPAK1',.F.,.F.)},'Aguarde...','' )

	DbSelectArea('TMPAK1');DbGoTop()
	If !Eof()
		nTot := Val( TMPAK1->TOTAL ) + 1
	EndIf
	TMPAK1->( DbCLoseArea() )

Return nTot


/*/{Protheus.doc} Arquivo
Escolhe arquivo para carga
@type function
@version 1
@author solutio
@since 09/07/2020
/*/
Static Function Arquivo()

	Local cEscolheuFile := .F.


	cEscolheuFile := .F.

	WHILE !cEscolheuFile

		CTIPO := " "
		CTIPO += "Todos os arquivos   (*.*)    | *.*   | "
		//cTPatch  := CGETFILE( CTIPO , "Selecione Arquivo de .CSV ",,"C:\" ) //,.T.,GETF_LOCALHARD+GETF_NETWORKDRIVE+GETF_RETDIRECTORY+GETF_LOCALFLOPPY)
		cTPatch  := 	cGetFile("Anexos (*csv)|*csv|","Arquivo (*csv)",0,'',.T.,)

		cTPatch  := LOWER(ALLTRIM(cTPatch))


		If File(cTPatch)
			cEscolheuFile := .T.
		ELSE
			IW_MsgBox("Não foi possível localizar o arquivo",OemToAnsi("Arquivo..."),"Aviso","INFO" )

		ENDIF

	Enddo

Return


/*/{Protheus.doc} CopyToServer
Copia arquivo de Texto para o Server
@type function
@version  1
@author solutio
@since 03/02/2022
/*/
Static Function CopyToServer()

// cDirDocs := MsDocPath() //\dirdoc\co01\shared
	//Local aArq := {}
	Local cDrive, cDir, cNome, cExt
	SplitPath( cTPatch, @cDrive, @cDir, @cNome, @cExt )  //busca dados do endereço do arquivo

	cSPatch := cDirDocs +"\"+ cNome + cExt

	cArqCsv:= cNome+cExt //Nome Com Extensão do arquivo selecionado.

	//Apaga arquivo no Servidor se já exsitir.
	IF FILE(cSPatch)
		FERASE(cSPatch)
	ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Coloca o Ponteiro do Cursos do Mouse em estado de Espera	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	CursorWait()
	CpyT2S(cTPatch, cDirDocs, .T. )
	CursorArrow()	  	// Libera o Cursor

Return


/*/{Protheus.doc} D
Função para tratar posição da Tela conforme monitor
@type function
@version  1
@author solutio
@since 03/02/2022
@param nTam, numeric, retorna posição segundo resolução
/*/
Static Function D(nTam)	//	QDO TELA Eh DESENVOLVIDA COM RESOLUCAO 1080

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ajusta Tamanho dos Objetos            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local nHRes := oMainWnd:nClientWidth		// Resolucao horizontal do monitor

	If nHRes == 640                            	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam := (nTam / 1.38 )
	ElseIf (nHRes == 798).Or.(nHRes == 800)    	// Resolucao 800x600
		nTam := (nTam / 1.28 )
	Else                                        // Resolucao 1024x768 e acima
		nTam := (nTam * 1.28)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Tratamento para tema "Flat"³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If "MP8" $ oApp:cVersion .Or. '10' $ cVersao
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam /= 1.04
		EndIf
		//ElseIf Alltrim(GetTheme()) == 'OCEAN'
		//nTam *= 50
	EndIf

Return Int(nTam)

/*
Static Function MostraArvore()

	Local oDlg, oFont
	//Local oPanelCta
	//Local nTop      := oMainWnd:nTop+35
	//Local nLeft     := oMainWnd:nLeft+10
	//Local nBottom   := oMainWnd:nBottom-12
	//Local nRight    := oMainWnd:nRight-10
	//Local aButtons := {}
	//Local oPanTree
	Local oPanFix
	Local oTree
	Local lRet := .F.
	//Local oSay
	Local cQry
	Local nNivAtu

	If Len( aBrowse ) <= 0
		Return
	EndIf

	cQry:=" SELECT "
	cQry+="	  DISTINCT(AK2.AK2_CO), "
	cQry+="	  AK2.AK2_ORCAME, "
	cQry+="	  AK2.AK2_VERSAO, "
	cQry+="	  AK2.AK2_FILIAL "
	cQry+=" FROM "
	cQry+= RETSQLNAME("AK2")+" AK2 "
	cQry+=" WHERE "
	cQry+="	  AK2.AK2_FILIAL     = '"+ xFilial("AK2") +"' "
	cQry+="	  AND AK2.AK2_ORCAME = '"+aBrowse[oBrw1:nAt][3]+"' "
	cQry+="	  AND AK2.AK2_VERSAO = '" +aBrowse[oBrw1:nAt][5]+"' "
	cQry+="	  AND AK2.D_E_L_E_T_ = ' ' "

	IIF(Select('TMPAK2') != 0, TMPAK2->( DbCLoseArea() ), )

	MsAguarde({|| DbUseArea(.T.,'TOPCONN',TcGenQry(,,cQry),'TMPAK2',.F.,.F.)},'Aguarde...','' )

	DEFINE FONT oFont NAME "Arial" SIZE 0, -11 BOLD
	DEFINE MSDIALOG oDlg TITLE 'Arvore de Contas' OF oMainWnd PIXEL FROM 0,0 TO D(450),D(450)  //" - Inclusao de contas"

	oPanFix := TPanel():New(D(10),D(10),'',oDlg,oDlg:oFont, .T., .T., CLR_BLACK, RGB(245, 245, 240), D(048), D(030),.T.,.T. )
	oPanFix:Align := CONTROL_ALIGN_TOP

	// Informacoes para montagem do Tree
	oTree:= dbTree():New( D(3), D(3), D(100), D(100), oDlg ,,, .T.)
	oTree:Align := CONTROL_ALIGN_ALLCLIENT
	oTree:BeginUpdate()
	oTree:Reset()
	oTree:EndUpdate()

	oTree:BeginUpdate()

	DbSelectArea('TMPAK2')
	TMPAK2->(DbGoTop())
	Do While TMPAK2->(!Eof())

		DbSelectArea("AK5")
		AK5->(DbSetOrder(1))

		If DbSeek(xFilial("AK5")+TMPAK2->AK2_CO)
			aCtaPlan := {}
			nNivAtu := 1
			oTree:AddTree( Alltrim(aBrowse[oBrw1:nAt][3]) + "- " + aBrowse[oBrw1:nAt][4], .F., "PMSEXPALL","PMSEXPCMP",,, "AK1"+aBrowse[oBrw1:nAt][3],,,nNivAtu)
			nNivAtu++

			PcoCtaAddPlan(AK1->AK1_CODIGO,AK5->AK5_COSUP, @nNivAtu,.T.,oTree)

			oTree:AddTree( Alltrim(AK5->AK5_CODIGO) + " - " + AK5->AK5_DESCRI, .F., "", "",,, "AK5"+AK5->AK5_CODIGO,,,nNivAtu)
			oTree:TreeSeek("AK5"+AK5->AK5_CODIGO)
			lRet := .T.
		EndIf
		TMPAK2->(DbSkip())
	EndDo

	If lRet // Isso evita que não de erro quando não encontra registro na AK5.
		dbEndTree oTree
	EndIf
	oTree:EndUpdate()
	oTree:Refresh()
	oDlg:Activate(,,,.T.,{||.T.})

	TMPAK2->( DbCLoseArea() )

Return
*/


/*/{Protheus.doc} PcoCtaAddPlan
Função obsoleta. utilizada an versão anterior do GeraAK3
@type function
@version  1
@author solutio
@since 03/02/2022
@param cCtaOrc, character, Conta Orçamentária
@param cCtaSup, character, Conta Superior
@param nNivAtu, numeric, Nivel Atual
@param _lTree, variant, boolean Gera Arvore
@param oTree, object, objeto arvore 
/*/
Static Function PcoCtaAddPlan(cCtaOrc,cCtaSup,nNivAtu,_lTree,oTree)

	Local aAreaAK5 := AK5->(GetArea())
	Local cCtaTree := ""
	Local lAdItem := .F.

	dbSelectArea("AK5")
	dbSetOrder(1)
	MsSeek(xFilial("AK5")+cCtaSup)

	While !Eof() .And. AK5->AK5_FILIAL+AK5->AK5_CODIGO==xFilial("AK5")+cCtaSup

		lAdItem := .T.
		cCtaTree := AK5->AK5_CODIGO

		If !Empty(AK5->AK5_COSUP)
			If !_LTree
				PcoCtaAddPlan(AK5->AK5_CODIGO, AK5->AK5_COSUP, @nNivAtu)
			Else
				oTree:AddTree( Alltrim(AK5->AK5_CODIGO) + " - " + AK5->AK5_DESCRI, .F., "MDIVISIO_PQ", "MDIVISIO_PQ",,, "AK5"+AK5->AK5_CODIGO,,,nNivAtu)
			EndIf
		Else
			If _lTree
				oTree:AddTree( Alltrim(AK5->AK5_CODIGO) + " - " + AK5->AK5_DESCRI, .F., "MDIVISIO_PQ", "MDIVISIO_PQ",,, "AK5"+AK5->AK5_CODIGO,,,nNivAtu)
			EndIf
			Exit
		EndIf

		dbSelectArea("AK5")
		dbSkip()
	EndDo

	If lAdItem
		If !_lTree
			aAdd(aCtaPlan, {"AK5"+cCtaTree, nNivAtu})
		EndIf
		nNivAtu++
	EndIf

	RestArea(aAreaAK5)

Return NIL


/*/{Protheus.doc} GeraLog
Mostra tela - Gera Log e Apresenta para o usuário
@type function
@version  1
@author solutio
@since 03/02/2022
@param cLogTxt, character, Mensagem de Erro para apresentar ao usuário
/*/	
Static Function GeraLog( cLogTxt )

	__cFileLog := MemoWrite(Criatrab(,.F.)+".LOG",cLogTxt)

	Define FONT oFont NAME "Tahoma" Size 6,12
	Define MsDialog oDlgMemo Title "Consistência dos Dados" From 3,0 to 340,550 Pixel

	@ 5,5 Get oMemo  Var cLogTxt MEMO Size 265,145 Of oDlgMemo Pixel
	oMemo:bRClicked := {||AllwaysTrue()}
	oMemo:oFont:=oFont
//Define SButton  From 153,205 Type 13 Action (cFile := cGetFile(cMask,""), Iif(cFile="",.T.,MemoWrite(cFile,cLogTxt)) ) Enable Of oDlgMemo Pixel
	Define SButton  From 153,205 Type 13 Action ({oDlgMemo:End(),Mysend(cLogTxt)}) Enable Of oDlgMemo Pixel
	Define SButton  From 153,235 Type 1 Action oDlgMemo:End() Enable Of oDlgMemo Pixel

	Activate MsDialog oDlgMemo Center

Return()
	*********************************************************************
Static Function Mysend(cTxt)
	*********************************************************************
	Static oDlg
	Static oButton1
	Static oButton2
	Static oGet1
	Static cGet1 := Space(200)
	Static oSay

	DEFINE MSDIALOG oDlg TITLE "Envio de Log" FROM 000, 000  TO 150, 300 COLORS 0, 12632256 PIXEL

	@ 031, 015 MSGET oGet1 VAR cGet1 SIZE 114, 010 OF oDlg PICTURE "@!" VALID !Empty(Alltrim(cGet1)) COLORS 0, 16777215 PIXEL
	@ 016, 015 SAY oSay PROMPT "Por favor, entre com seu email ABAIXO:" SIZE 100, 007 OF oDlg PICTURE "@!" COLORS 0, 12632256 PIXEL

	@ 050, 025 BUTTON oButton1 PROMPT "Enviar" SIZE 040, 012 OF oDlg ACTION {||oDlg:End(),DISMAILX(cGet1,cTxt)} PIXEL
	@ 050, 075 BUTTON oButton2 PROMPT "Sair" SIZE 040, 012 OF oDlg ACTION oDlg:End()  PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return
	*********************************************************************
Static Function DISMAILX(cMail,cTxt)
	*********************************************************************

	CONNECT SMTP SERVER GETMV("MV_RELSERV") ACCOUNT GETMV("MV_RELACNT") PASSWORD GETMV("MV_RELPSW") RESULT lResult

	If !lResult
		IW_MsgBox('Erro no Envio do Email', "Alerta","STOP")
		Return()
	EndIf

	cAccount := GETMV("MV_RELACNT")

	SEND MAIL FROM cAccount 	;
		TO      cMail	        	;
		SUBJECT FUNDESC()       	;//SUBJECT "Log Sx3 vs Banco" 	;
		BODY cTxt + CRLF + CRLF + FUNNAME() + " - " + FUNDESC()

	DISCONNECT SMTP SERVER

	IW_MsgBox("Email Enviado com Sucesso!","Aviso","INFO")

Return()
