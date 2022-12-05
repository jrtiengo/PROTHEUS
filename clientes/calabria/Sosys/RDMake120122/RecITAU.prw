#INCLUDE "PROTHEUS.CH"
#INCLUDE "RECITAU.CH"
#INCLUDE "RWMAKE.CH"

/*/{Protheus.doc} RecItau
//Emissao do Recibos de Pagamento Eletronico BCO Itaú
@author R.H
@since 28/10/2019
@version undefined
/*/
User Function RecItau()
	
	// Define Variaveis Locais ( Basicas )
	Local cString := "SRA" // alias do arquivo principal ( Base )
	
	// Define Variaveis Locais ( Programa )
	Local nExtra, cIndCond, cIndRc
	Local Baseaux 		:= "S"
	Local cDemit 		:= "N"
	Local cExist 		:= GetMV( 'MV_SEQITU',, 'NAOEXISTE' )
	
	Local aOfusca		:= IIf(FindFunction('ChkOfusca'), ChkOfusca(), {.T.,.F.}) // [1] Acesso; [2]Ofusca
	Local aFldRel		:= {"RA_NOME", 'RA_CIC'}
	Local lBlqAcesso	:= aOfusca[2] .And. !Empty( FwProtectedDataUtil():UsrNoAccessFieldsInList( aFldRel ) )
	
	If lBlqAcesso
		//"Dados Protegidos- Acesso Restrito: Este usuário não possui permissão de acesso aos dados dessa rotina. Saiba mais em {link documentação centralizadora}"
		Help(" ", 1, aOfusca[3,1], , aOfusca[3,2], 1, 0)
		Return
	EndIf
	
	PRIVATE cMesAnoRef
	
	/* 	Declaracao de variaveis utilizadas no programa atraves da funcao
		SetPrvt, que criara somente as variaveis definidas pelo usuario,
		identificando as variaveis publicas do sistema utilizadas no codigo
		Incluido pelo assistente de conversao do AP5 IDE */
	
	SetPrvt( "CSTRING, BASEAUX" )
	SetPrvt( "CDEMIT, ARETURN, NOMEPROG, ALINHA, NLASTKEY, CPERG" )
	SetPrvt( "CSEM_DE, CSEM_ATE, ALANCA, APROVE, ADESCO, ABASES" )
	SetPrvt( "AINFO, ACODFOL, LI, TITULO, WNREL" )
	SetPrvt( "DDATAREF, ESC, SEMANA, CFILDE, CFILATE" )
	SetPrvt( "CCCDE, CCCATE, CMATDE, CMATATE, CNOMDE, CNOMATE" )
	SetPrvt( "CHAPADE, CHAPAATE, MENSAG1, MENSAG2, MENSAG3, CSITUACAO" )
	SetPrvt( "CCATEGORIA, CBASEAUX, CMESANOREF, TAMANHO, LIMITE, AORDBAG" )
	SetPrvt( "CMESARQREF, CARQMOV, CALIASMOV, CACESSASR1, CACESSASRA, CACESSASRC" )
	SetPrvt( "CACESSASRD, LATUAL, CARQNTX, CINDCOND, ADRIVER, CCOMPAC" )
	SetPrvt( "CNORMAL, CINICIO, CFIM, TOTVENC, TOTDESC, FLAG" )
	SetPrvt( "CHAVE, DESC_FIL, DESC_END, DESC_CC, DESC_FUNC, DESC_MSG1" )
	SetPrvt( "DESC_MSG2, DESC_MSG3, CFILIALANT, CFUNCAOANT, CCCANT, VEZ" )
	SetPrvt( "ORDEMZ, NATELIM, NBASEFGTS, NFGTS, NBASEIR, NBASEIRFE" )
	SetPrvt( "ORDEM_REL, DESC_CGC, NCONTA, NCONTR, NCONTRT, NLINHAS" )
	SetPrvt( "CDET, NCOL, NTERMINA, NCONT, NCONT1, NVALIDOS, NSEQ_, CREG, LCONTINUA" )
	SetPrvt( "NVALSAL, DESC_BCO, CCHAVESEM, DESC_PAGA, NPOS, CARRAY, NHDL, CNOMEARQ" )
	SetPrvt( "CDEPTODE, CDEPTOATE", "CROTEIRO", "CPERIODO", "SEMANA", "CPROCESSO", "CTIPOROT", "DDATAPAG", "CCNPJ","CCCUSTO" )
	SetPrvt( "nAteLim", "nBaseFgts", "nFgts", "nBaseIr", "nBaseIrFe","nSequenc","cMsgInfoI","cMsgInfoII","cMsgInfoIII")
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis Private( Basicas )                            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private nomeprog :="RECITAU"
	Private aLinha   := { }, nLastKey := 0
	Private cPerg    := "RECITAU"
	Private cSem_De  := "  /  /    "
	Private cSem_Ate := "  /  /    "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Define Variaveis Private( Programa )                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Private aLanca 		:= {}
	Private aProve 		:= {}
	Private aDesco 		:= {}
	Private aBases 		:= {}
	Private aInfo  		:= {}
	Private aCodFol		:= {}
	Private li     		:= 0
	Private nHdl   		:= 0
	Private Titulo 		:= STR0001
	Private GERAOK
	Private aPerAberto	:= {}
	Private aPerFechado	:= {}
	Private cMes 		:= ''
	Private cAno 		:= ''
	Private aIncons		:= {}
	Private aRetSM0		:= {}
	Private	nSeqLanc	:= 0
	nSeq_	:= 0
	fDdsEmp()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica as perguntas selecionadas                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If ALLTRIM(cExist) == "NAOEXISTE"
		ShowHelpDlg( STR0019, {STR0025}, 5, {STR0028}, 5)   
		Return
	EndIf
	
	If ValidX1()
		return 
	EndIf
	
	Pergunte( cPerg, .F. )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Montagem da tela de processamento.                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	@ 000,000 TO 250,500 DIALOG GERAOK TITLE OemToAnsi(STR0002)
	
	@ 030,010 SAY OemtoAnsi(STR0003)
	@ 040,010 SAY OemtoAnsi(STR0004)
	
	@ 104,162 BMPBUTTON TYPE 5 ACTION Pergunte(cPerg,.T.)
	@ 104,190 BMPBUTTON TYPE 2 ACTION Close(GERAOK)
	@ 104,218 BMPBUTTON TYPE 1 ACTION GERRImp1()
	
	ACTIVATE DIALOG GERAOK CENTERED
	
Return

Static Function GERRImp1()
	
	Local aTitulo:={}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Carregando variaveis mv_par?? para Variaveis do Sistema.     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cProcesso  := mv_par01	//Processo
	cRoteiro   := mv_par02 	//Emitir Recibos(Roteiro)
	cPeriodo   := mv_par03 	//Periodo
	Semana     := mv_par04 	//Numero da Semana
	
	//Carregar os periodos abertos (aPerAberto) e/ou
	// os periodos fechados (aPerFechado), dependendo
	// do periodo (ou intervalo de periodos) selecionado
	RetPerAbertFech(cProcesso	,; // Processo selecionado na Pergunte.
	cRoteiro	,; // Roteiro selecionado na Pergunte.
	cPeriodo	,; // Periodo selecionado na Pergunte.
	Semana		,; // Numero de Pagamento selecionado na Pergunte.
	NIL			,; // Periodo Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um periodo.
	NIL			,; // Numero de Pagamento Ate - Passar "NIL", pois neste relatorio eh escolhido apenas um numero de pagamento.
	@aPerAberto	,; // Retorna array com os Periodos e NrPagtos Abertos
	@aPerFechado ) // Retorna array com os Periodos e NrPagtos Fechados
	
	// Retorna o mes e o ano do periodo selecionado na pergunte.
	AnoMesPer(	cProcesso	,; // Processo selecionado na Pergunte.
	cRoteiro	,; // Roteiro selecionado na Pergunte.
	cPeriodo	,; // Periodo selecionado na Pergunte.
	@cMes		,; // Retorna o Mes do Processo + Roteiro + Periodo selecionado
	@cAno		,; // Retorna o Ano do Processo + Roteiro + Periodo selecionado
	Semana		 ) // Retorna a Semana do Processo + Roteiro + Periodo selecionado
	
	dDataRef := CTOD("01/" + cMes + "/" + cAno)
	
	cFilDe     	:= mv_par05
	cFilAte    	:= mv_par06
	cCcDe     	:= mv_par07
	cCcAte     	:= mv_par08
	cMatDe     	:= mv_par09
	cMatAte    	:= mv_par10
	cNomDe     	:= mv_par11
	cNomAte    	:= mv_par12
	cSituacao  	:= mv_par13
	cCategoria 	:= mv_par14
	cNomeArq   	:= mv_par15
	cNum       	:= ''
	cMesAnoRef 	:= StrZero( Month( dDataRef ), 2 ) + StrZero( Year( dDataRef ), 4 )
	cDeptoDe   	:= mv_par16
	cDeptoAte  	:= mv_par17
	cCNPJ	   	:= mv_par18
	cNomeEmpr  	:= mv_par19
	cBancoEmp  	:= padL(RTRIM(mv_par20),3,"0")
	cAgencEmp  	:= padL(RTRIM(mv_par21),5,"0")
	cContaEmp  	:= mv_par22
	cDac		:= mv_par23
	cNomeBco   	:= SubStr(mv_par24,1,30)
	dDataPagto	:= mv_par25
	Mensag1    := mv_par26
	Mensag2    := mv_par27
	Mensag3    := mv_par28
	nAteLim 	:= nBaseFgts := nFgts := nBaseIr := nBaseIrFe :=  0.00
	
	cCodRec    	:= ""
	cNumLocal	:= ""
	cEndLocal	:= ""
	cCidLocal	:= ""
	cCepLocal	:= ""
	cUFLocal	:= ""
	cNumReg		:= ""
	nSequenc	:= 0
	cCcusto		:= ""
	lContinua 	:=IIf(Empty( cNomeArq ), .F., .T.)
	/*
	*TIPO PAGAMENTO

	Código	Descrição
	01	Folha Mensal
	02	Folha Quinzenal
	03	Folha Complementar
	04	13º Salário
	05	Participação de Resultados
	06	Informe de Rendimentos
	07	Férias
	08	Rescisão
	09	Rescisão Complementar
	10	Outros
	85	Débito Conta Investimento
	
	*/
	//CARREGA AS INFORMAÇÕES DE ENDEREÇO DA EMPRESA
	fDdsEmp()
	
	If Empty(cEndLocal) .Or. Empty(cCidLocal) .Or.  Empty(cNumLocal) .Or. Empty(cUFLocal) .Or. Empty(cCepLocal)
		ShowHelpDlg( STR0019, {STR0029}, 5, {STR0030}, 5)// Validação de informações de endereço da empresa.
        Return
	EndIf
	cTipoRot  :=  PosAlias("SRY",cRoteiro,SRA->RA_FILIAL,"RY_TIPO")
	dDataPag  :=  PosAlias("RCH",(cProcesso+cPeriodo+Semana+cRoteiro),SRA->RA_FILIAL,"RCH_DTPAGO")
	
	If cTipoRot == '1'			// Adiantamento
		cFinPgt := "02"
	ElseIf cTipoRot == '2'		// Folha
		cFinPgt := "01"
	ElseIf cTipoRot == '3'		// 1a Parcela
		cFinPgt := "04"
	ElseIf cTipoRot == '4'		// 2a Parcela
		cFinPgt := "04"
	Else						// Extras
		cFinPgt := "10"
	EndIf

	Processa({|| GERRImp() }, STR0012)
	
	//Gerar Arquivo
	If nHdl > 0
		If fClose( nHdl )
			
			If nSeq_ <> 0
				
				Aviso( STR0005, STR0010 + AllTrim( AllTrim( cNomeArq )) + CRLF + CRLF + STR0008 + cNum, {STR0009}, 3 )
				
				If Len(aIncons) > 0
					aadd(aTitulo, STR0011 + Titulo)
					fMakeLog(aIncons, aTitulo, Nil, Nil, FunName(), Titulo)
				endIf
			Else
				If fErase( cNomeArq ) == 0
					If lContinua
						Aviso( STR0005, STR0006 + AllTrim( AllTrim( cNomeArq ) ) + STR0007, {STR0009} )
					EndIf
				Else
					MsgAlert( STR0013 + AllTrim( cNomeArq ) + '.' )
				EndIf
			EndIf
		Else
			MsgAlert( STR0014 + AllTrim( cNomeArq ) + '.' )
		EndIf
	EndIf
	
	Close(GERAOK)
	
Return

/*/{Protheus.doc} GERRImp
//Processamento Para emissao do Recibo
@author eduardo.vicente
@since 28/10/2019
@version undefined
@return return, return_description
/*/
Static Function GERRImp()
	
	// Define Variaveis Locais ( Basicas )
	Local aOrdBag    	:= {}
	Local cArqMov     	:= ""
	
	Private alinhaFunc	:= {}
	Private nQtdComp   	:= 0
	Private nTotRLote  	:= 0
	Private lAbortFunc 	:= .F.
	Private nAteLim , nBaseFgts , nFgts , nBaseIr , nBaseIrFe, nTotVenEmp, nTotDesEmp, nTotLiqEmp
	
	nTotVenEmp := nTotDesEmp := nTotLiqEmp := 0
	
	cAcessaSR1  := &("{ || " + ChkRH("GPER030","SR1","2") + "}")
	cAcessaSRA  := &("{ || " + ChkRH("GPER030","SRA","2") + "}")
	cAcessaSRC  := &("{ || " + ChkRH("GPER030","SRC","2") + "}")
	cAcessaSRD  := &("{ || " + ChkRH("GPER030","SRD","2") + "}")
	
	// Selecionando a Ordem de impressao escolhida no parâmetro.
	SRA->(dbSetOrder( 1 ))
	SRA->(dbGoTop())
	
	// Registro Header de Arquivo
	aTipo0 := {}
	//              Descricao                                Ini  Fim   Tipo  Tam Dec Obrig	Conteudo
	aAdd( aTipo0, { 'CÓDIGO DO BANCO                      ', 001, 003,   'N',   3,  0, 	.T., 'cBancoEmp'							} ) //CÓDIGO DO BCO NA COMPENSAÇÃO
	aAdd( aTipo0, { 'CÓDIGO DO LOTE                       ', 004, 007,   'N',   4,  0, 	.T., '0000'	 								} ) //LOTE DO SERVIÇO
	aAdd( aTipo0, { 'TIPO DE REGISTRO 				      ', 008, 008,   'N',   1,  0, 	.T., '0' 									} ) //REGISTRO HEADER DE ARQUIVO
	aAdd( aTipo0, { 'BRANCOS	                          ', 009, 014,   'C',   6,  0, 	.F., 'SPACE(6)' 							} ) //COMPLEMENTO DE REGISTRO
	aAdd( aTipo0, { 'LAYOUT DE ARQUIVO					  ', 015, 017,   'N',   3,  0, 	.T., '081' 									} ) // N DA VERSÃO DO LAYOUT DO ARQUIVO
	aAdd( aTipo0, { 'EMPRESA –  INSCRIÇÃO                 ', 018, 018,   'N',   1,  0, 	.T., 'IIF(len(alltrim(cCNPJ)) < 14,"1","2")'} ) //TIPO DE INSCRIÇÃO DA EMPRESA
	aAdd( aTipo0, { 'INSCRIÇÃO NÚMERO                     ', 019, 032,   'N',  14,  0, 	.T., 'cCNPJ'								} ) //CNPJ EMPRESA DEBITADA
	aAdd( aTipo0, { 'BRANCOS				              ', 033, 052,   'C',  20,  0, 	.F., 'SPACE(20)' 							} ) //COMPLEMENTO DE REGISTRO
	aAdd( aTipo0, { 'AGÊNCIA							  ', 053, 057,   'N',   5,  0, 	.T., 'cAgencEmp'						 	} ) //NÚMERO AGÊNCIA DEBITADA
	aAdd( aTipo0, { 'BRANCOS					          ', 058, 058,   'C',   1,  0, 	.F., 'SPACE(1)' 							} ) //COMPLEMENTO DE REGISTRO
	aAdd( aTipo0, { 'CONTA								  ', 059, 070,   'N',  12,  0,  .T., 'cContaEmp'		 					} ) //NÚMERO DE C/C DEBITADA
	aAdd( aTipo0, { 'BRANCOS 							  ', 071, 071,   'C',   1,  0, 	.F., 'SPACE(1)' 							} ) //COMPLEMENTO DE REGISTRO
	aAdd( aTipo0, { 'DAC						          ', 072, 072,   'N',   1,  0, 	.T., 'cDac' 								} ) //DAC DA AGÊNCIA/CONTA DEBITADA
	aAdd( aTipo0, { 'NOME DA EMPRESA                      ', 073, 102,   'C',  30,  0,  .T., 'Upper(cNomeEmpr)'						} ) //NOME DA EMPRESA
	aAdd( aTipo0, { 'NOME DO BANCO				          ', 103, 132,   'C',  30,  0,	.T., 'cNomeBco' 							} ) //NOME DO BANCO
	aAdd( aTipo0, { 'BRANCOS 				              ', 133, 142,   'C',  10,  0,	.F., 'SPACE(10)' 							} ) //COMPLEMENTO DE REGISTRO
	aAdd( aTipo0, { 'ARQUIVO-CODIGO                       ', 143, 143,   'N',   1,  0,	.T., '1' 									} ) //1=REMESSA - 2=RETORNO
	aAdd( aTipo0, { 'DATA DE GERAÇÃO                      ', 144, 151,   'N',   8,  0,	.T., 'STRTRAN(DTOC(DATE()),"/","")'			} ) //DATA DE GERAÇÃO DO ARQUIVO DDMMAAAA
	aAdd( aTipo0, { 'HORA DE GERAÇÃO                      ', 152, 157,   'N',   6,  0,	.T., 'StrTran(TIME(),":","")' 				} ) //HORA DE GERAÇÃO DO ARQUIVO HHMMSS
	aAdd( aTipo0, { 'ZEROS			                      ', 158, 166,   'N',   9,  0,	.F., '0'				 					} ) //COMPLEMENTO DE REGISTRO
	aAdd( aTipo0, { 'UNIDADE DE DENSIDADE                 ', 167, 171,   'N',   5,  0,	.T., '0'									} ) //DENSIDADE DE GRAVAÇÃO DO ARQUIVO
	aAdd( aTipo0, { 'BRANCOS			                  ', 172, 240,   'C',  69,  0,	.F., 'SPACE(69)' 							} ) //COMPLEMENTO DE REGISTRO
	
	// Registro Header do Lote
	aTipo1 := {}
	//              Descricao                                Ini  Fim   Tipo  Tam Dec Obrig	Conteudo
	aAdd( aTipo1, { 'CÓDIGO DO BANCO                      ', 001, 003,   'N',  3,  0, .T., 'cBancoEmp'								} ) //CÓDIGO BANCO NA COMPENSAÇÃO
	aAdd( aTipo1, { 'CÓDIGO DO LOTE                       ', 004, 007,   'N',  4,  0, .T., 'cNum' 									} ) //LOTE IDENTIFICAÇÃO DE PAGTOS
	aAdd( aTipo1, { 'TIPO DE REGISTRO                     ', 008, 008,   'N',  1,  0, .T., '"1"' 									} ) //REGISTRO HEADER DE LOTE
	aAdd( aTipo1, { 'TIPO DE OPERAÇÃO				      ', 009, 009,   'C',  1,  0, .T., '"C"'	 								} ) //TIPO DA OPERAÇÃO --C=CRÉDITO
	aAdd( aTipo1, { 'TIPO DE PAGAMENTO					  ', 010, 011,   'N',  2,  0, .T., '30' 			 						} ) //TIPO DE PAGAMENTO
	aAdd( aTipo1, { 'FORMA DE PAGAMENTO               	  ', 012, 013,   'N',  2,  0, .T., '01' 								 	} ) //FORMA DE PAGAMENTO  "01=Credito CC"
	aAdd( aTipo1, { 'LAYOUT DO LOTE		                  ', 014, 016,   'N',  3,  0, .T., '040' 								 	} ) //N DA VERSÃO DO LAYOUT DO LOTE
	aAdd( aTipo1, { 'BRANCOS						      ', 017, 017,   'C',  1,  0, .F., 'SPACE(1)' 							 	} ) //COMPLEMENTO DE REGISTRO
	aAdd( aTipo1, { 'EMPRESA –  INSCRIÇÃO                 ', 018, 018,   'N',  1,  0, .T., 'IIF(len(alltrim(cCNPJ)) < 14,"1","2")' 	} ) //TIPO DE INSCRIÇÃO DA EMPRESA
	aAdd( aTipo1, { 'INSCRIÇÃO NÚMERO                     ', 019, 032,   'N', 14,  0, .T., 'cCNPJ'								 	} ) //CNPJ EMPRESA DEBITADA
	aAdd( aTipo1, { 'IDENTIFICAÇÃO DO LANÇAMENTO          ', 033, 036,   'C',  4,  0, .T., '"1707"' 								} ) //IDENTIFICAÇÃO DO LANÇAMENTO NO EXTRATO DO FAVORECIDO
	aAdd( aTipo1, { 'BRANCOS						      ', 037, 052,   'C', 16,  0, .F., 'SPACE(16)' 							 	} ) //COMPLEMENTO DE REGISTRO
	aAdd( aTipo1, { 'AGÊNCIA							  ', 053, 057,   'N',  5,  0, .T., 'cAgencEmp'							 	} ) //NÚMERO AGÊNCIA DEBITADA
	aAdd( aTipo1, { 'BRANCOS						      ', 058, 058,   'C',  1,  0, .f., 'SPACE(1)' 							 	} ) //COMPLEMENTO DE REGISTRO
	aAdd( aTipo1, { 'CONTA								  ', 059, 070,   'N', 12,  0, .T., 'cContaEmp'							 	} ) //NÚMERO DE C\C DEBITADA
	aAdd( aTipo1, { 'BRANCOS						      ', 071, 071,   'C',  1,  0, .F., 'SPACE(1)' 							 	} ) //COMPLEMENTO DE REGISTRO
	aAdd( aTipo1, { 'DAC			                      ', 072, 072,   'N',  1,  0, .T., 'cDac' 								 	} ) //DAC DA AGÊNCIA/CONTA DEBITADA
	aAdd( aTipo1, { 'NOME DA EMPRESA                      ', 073, 102,   'C', 30,  0, .T., 'Upper(cNomeEmpr)'						} ) //NOME DA EMPRESA DEBITADA
	aAdd( aTipo1, { 'FINALIDADE DO LOTE                   ', 103, 132,   'C', 30,  0, .T., 'cFinPgt'		    					} ) //FINALIDADE DOS PAGTOS DO LOTE
	aAdd( aTipo1, { 'HISTÓRICO DE C/C				      ', 133, 142,   'C', 10,  0, .F., 'SPACE(10)' 							 	} ) //COMPLEMENTO HISTÓRICO C/C DEBITADA
	aAdd( aTipo1, { 'ENDEREÇO DA EMPRESA                  ', 143, 172,   'C', 30,  0, .T., 'cEndLocal' 						 	 	} ) //ENDEREÇO DA EMPRESA
	aAdd( aTipo1, { 'NÚMERO	                              ', 173, 177,   'N',  5,  0, .T., 'cNumLocal' 							 	} ) //NUMERO DA EMPRESA
	aAdd( aTipo1, { 'COMPLEMENTO		                  ', 178, 192,   'C', 15,  0, .F., 'SPACE(15)' 							 	} ) //CASA, APTO, SALA, ETC...
	aAdd( aTipo1, { 'CIDADE 			                  ', 193, 212,   'C', 20,  0, .T., 'cCidLocal' 							 	} ) //CIDADE DA EMPRESA
	aAdd( aTipo1, { 'CEP                               	  ', 213, 220,   'N',  8,  0, .F., 'cCepLocal' 							 	} ) //CEP DA EMPRESA
	aAdd( aTipo1, { 'ESTADO				                  ', 221, 222,   'C',  2,  0, .T., 'cUFLocal' 							 	} ) //ESTADO DA EMPRESA
	aAdd( aTipo1, { 'BRANCOS						      ', 223, 230,   'C',  8,  0, .F., 'SPACE(8)' 							 	} ) //COMPLEMENTO DE REGISTRO
	aAdd( aTipo1, { 'OCORRÊNCIAS					      ', 231, 240,   'C', 10,  0, .F., 'SPACE(10)' 						 		} ) //CÓDIGO OCORRÊNCIAS P/RETORNO
	
	// REGISTRO DETALHES DO COMPROVANTE - SEGMENTO A - PAGAMENTOS ATRAVÉS DE CHEQUE, OP, DOC, TED E CRÉDITO EM CONTA CORRENTE
	aTipo2 := {}
	//              Descricao                                Ini  Fim   Tipo  Tam Dec Obrig	Conteudo
	aAdd( aTipo2, { 'CÓDIGO DO BANCO                     ',  001, 003,   'N',  	3,  0, 	.T., 'cBancoEmp'							 	} ) // CÓDIGO BANCO NA COMPENSAÇÃO
	aAdd( aTipo2, { 'CÓDIGO DO LOTE                      ',  004, 007,   'N',  	4,  0, 	.T., 'cNum' 								 	} ) // LOTE IDENTIFICAÇÃO DE PAGTOS
	aAdd( aTipo2, { 'TIPO DE REGISTRO             		 ',  008, 008, 	 "N",	1,	0,	.T., '"3"'									 	} ) // REGISTRO DETALHE DE LOTE
	aAdd( aTipo2, { 'NÚMERO DO REGISTRO           		 ',  009, 013,	 "N",	5,	0,	.T., "nSeq_"								 	} ) // Nº SEQUENCIAL REGISTRO NO LOTE
	aAdd( aTipo2, { 'SEGMENTO                     		 ',	 014, 014,	 "C",	1,	0,	.T., '"A"'									 	} ) // CÓDIGO SEGMENTO REG. DETALHE
	aAdd( aTipo2, { 'TIPO DE MOVIMENTO            		 ',	 015, 017, 	 "N",	3,	0,	.T., "000"									 	} ) // TIPO DE MOVIMENTO
	aAdd( aTipo2, { 'CÂMARA                       		 ',	 018, 020,	 "N",	3,	0,	.T., "0"									 	} ) // CÓDIGO DA CÂMARA CENTRALIZADORA
	aAdd( aTipo2, { 'BANCO FAVORECIDO             		 ',	 021, 023, 	 "N",	3,	0,	.T., "Left(SRA->RA_BCDEPSA,3)"				 	} ) // CÓDIGO BANCO FAVORECIDO
	aAdd( aTipo2, { 'AGÊNCIA CONTA                		 ',	 024, 043,	 "C",  20,	0,	.T., "Iif(Left(SRA->RA_BCDEPSA, 3) $ '341/409', '0' + StrZero(Val(SubStr(SRA->RA_BCDEPSA, 4, 4)), 4) + ' ' + '000000' + Left(StrZero(Val(StrTran(RA_CTDEPSA, '-', '')), 7), 6) + ' ' + Right(StrZero(Val(StrTran(RA_CTDEPSA, '-', '')), 7), 1), StrZero(Val(SubStr(SRA->RA_BCDEPSA, 5, 5)), 5) + ' ' + Left(StrZero(Val(StrTran(RA_CTDEPSA, '-', '')), 13), 12) + ' ' + Right(StrZero(Val(StrTran(RA_CTDEPSA, '-', '')), 13), 1))"				 	 } )//AGÊNCIA CONTA FAVORECIDO
	aAdd( aTipo2, { 'NOME DO FAVORECIDO           		 ',	 044, 073, 	 "C",  30,	0,	.T., "Left(SRA->RA_NOME,30)"					} )	// NOME DO FAVORECIDO
	aAdd( aTipo2, { 'SEU NÚMERO                   		 ',	 074, 093,	 "C",  20,	0,	.F., "Space(20)"								} )	// Nº DOCTO ATRIBUÍDO PELA EMPRESA
	aAdd( aTipo2, { 'DATA DE PAGTO            		 	 ',	 094, 101, 	 "N",	8,	0,	.T., "STRTRAN(DTOC(dDataPagto),'/','')"	 		} )	// DATA PREVISTA PARA PAGTO DDMMAAAA
	aAdd( aTipo2, { 'MOEDA – TIPO                 		 ',	 102, 104,	 "C",	3,	0,	.T., '"REA"'									} )	// REA OU 00
	aAdd( aTipo2, { 'CÓDIGO ISPB                  		 ',	 105, 112, 	 "N",	8,	0,	.T., "0"										} )	// IDENTIFICAÇÃO DA INSTITUIÇÃO PARA O SPB
	aAdd( aTipo2, { 'ZEROS                        		 ',	 113, 119, 	 "N",	7,	0,	.F., "0"										} )	// COMPLEMENTO DE REGISTRO
	aAdd( aTipo2, { 'VALOR DO PAGTO               		 ',	 120, 134, 	 "N",  15,	2,	.T., "TOTVENC-TOTDESC"							} ) //	VALOR PREVISTO DO PAGTO
	aAdd( aTipo2, { 'NOSSO NÚMERO                 		 ',	 135, 149, 	 "C",  15,	0,	.F., "SPACE(15)"								} ) //	Nº DOCTO ATRIBUÍDO PELO BANCO
	aAdd( aTipo2, { 'BRANCOS                      		 ',	 150, 154, 	 "C",	5,	0,	.F., "SPACE(15)"			 					} ) //	COMPLEMENTO DE REGISTRO
	aAdd( aTipo2, { 'DATA EFETIVA                 		 ',	 155, 162, 	 "N",	8,	0,	.F., "0"									 	} ) //	DATA REAL EFETIVAÇÃO DO PAGTO
	aAdd( aTipo2, { 'VALOR EFETIVO                		 ',	 163, 177, 	 "N",  15,	2,	.F., "0"										} ) // VALOR REAL EFETIVAÇÃO DO PAGTO
	aAdd( aTipo2, { 'FINALIDADE DETALHE          		 ',	 178, 195,	 "C",  18,	0,	.F., "SPACE(18)"								} ) // INFORMAÇÃO COMPLEMENTAR P/ HIST. DE C/C
	aAdd( aTipo2, { 'BRANCOS                      		 ',	 196, 197, 	 "C",	2,	0,	.F., "SPACE(2)"									} ) // COMPLEMENTO DE REGISTRO
	aAdd( aTipo2, { 'N DO DOCUMENTO               		 ',	 198, 203,	 "N",	6,	0,	.F., "0"									 	} ) // Nº DO DOC/TED/ OP/ CHEQUE NO RETORNO
	aAdd( aTipo2, { 'N DE INSCRIÇÃO               		 ',	 204, 217, 	 "N",  14,	0,	.T., "SRA->RA_CIC"							 	} ) // N DE INSCRIÇÃO DO FAVORECIDO (CPF/CNPJ)
	aAdd( aTipo2, { 'FINALIDADE DOC E STATUS FUNCIONÁRIO ',	 218, 219,	 "C",	2,	0,	.T., "'06'"								 		} ) // FINALIDADE DO DOC E STATUS DO FUNCIONÁRIO NA EMPRESA
	aAdd( aTipo2, { 'FINALIDADE TED		       		 	 ',  220, 224, 	 "C",	5,	0,	.T., "'00010'"								 	} ) // FINALIDADE DA TED
	aAdd( aTipo2, { 'BRANCOS                      		 ',	 225, 229, 	 "C",	5,	0,	.F., "SPACE(5)"								 	} ) // COMPLEMENTO DE REGISTRO
	aAdd( aTipo2, { 'AVISO 				          		 ',	 230, 230, 	 "C",	1,	0,	.T., "0"									 	} ) // AVISO AO FAVORECIDO
	aAdd( aTipo2, { 'OCORRÊNCIAS		          		 ',	 231, 240, 	 "C",	10,	0,	.F., "SPACE(10)"								} ) // CÓDIGO OCORRÊNCIAS NO RETORNO
	
	// REGISTRO DETALHES DO COMPROVANTE - SEGMENTO D - PAGAMENTOS DE SALÁRIOS ATRAVÉS DE CRÉDITO EM CONTA CORRENTE (HOLERITE)
	
	aTipoHE := {}
	//              Descricao                                Ini  Fim   Tipo  Tam Dec Obrig	Conteudo
	aAdd( aTipoHE, { 'CÓDIGO DO BANCO                    ',  001, 003,   'N',  	3,  0, 	.T., 'cBancoEmp'							 } ) //CÓDIGO BANCO NA COMPENSAÇÃO
	aAdd( aTipoHE, { 'CÓDIGO DO LOTE                     ',  004, 007,   'N',  	4,  0, 	.T., 'cNum' 								 } ) //LOTE IDENTIFICAÇÃO DE PAGTOS
	aAdd( aTipoHE, { 'TIPO DE REGISTRO         		  	 ',  008, 008, 	 "N",	1,	0,	.T., '3'									 } ) //REGISTRO DETALHE DE LOTE
	aAdd( aTipoHE, { 'NÚMERO DO REGISTRO           		 ',  009, 013,	 "N",	5,	0,	.T., "nSeq_"								 } ) //Nº SEQUENCIAL REGISTRO NO LOTE
	aAdd( aTipoHE, { 'CÓDIGO SEGMENTO              		 ',	 014, 014,	 "C",	1,	0,	.T., '"D"'									 } ) //CÓDIGO SEGMENTO REG. DETALHE
	aAdd( aTipoHE, { 'BRANCOS                      		 ',	 015, 017, 	 "C",	3,	0,	.F., "SPACE(3)"								 } ) //COMPLEMENTO DE REGISTRO
	aAdd( aTipoHE, { 'PERÍODO/COMPETÊNCIA	       		 ',	 018, 023, 	 "N",	6,	0,	.T., "Right(cPeriodo, 2) + Left(cPeriodo, 4)"} ) // MÊS / ANO DO PAGAMENTO MMAAAA
	aAdd( aTipoHE, { 'CENTRO DE CUSTO              		 ',	 024, 038,	 "C",  15,	0,	.T., "Left(cCcusto, 15)"					 } ) //ÓRGÃO / CENTRO DE CUSTO
	aAdd( aTipoHE, { 'CÓDIGO FUNCIONÁRIO           		 ',	 039, 053, 	 "C",  15,	0,	.T., "SRA->RA_MAT"							 } ) //CÓDIGO DO FUNCIONÁRIO
	aAdd( aTipoHE, { 'CARGO DO FUNCIONÁRIO         		 ',	 054, 083,	 "C",  30,	0,	.T., "Left(SRJ->(RJ_FUNCAO+RJ_DESC) + Space(30), 30)"	 } ) //CARGO DO FUNCIONÁRIO
	aAdd( aTipoHE, { 'FÉRIAS 			          		 ',	 084, 091, 	 "C",   8,	0,	.T., "fCheckFer( 'INI' )"					 } ) //PERÍODO DE FÉRIAS “DE” DDMMAAAA
	aAdd( aTipoHE, { 'FÉRIAS 			          		 ',	 092, 099, 	 "C",   8,	0,	.T., "fCheckFer( 'FIM' )"					 } ) //PERÍODO DE FÉRIAS “PARA” DDMMAAAA
	aAdd( aTipoHE, { 'DEPENDENTES I.R.             		 ',	 100, 101,	 "N",   2,	0,	.T., "SRA->RA_DEPIR"						 } ) //QUANTIDADE DE DEPENDENTES IMP.DE RENDA
	aAdd( aTipoHE, { 'DEPENDENTES S.F.         		 	 ',	 102, 103, 	 "N",   2,	0,	.T., "SRA->RA_DEPSF"						 } ) //QUANTIDADE DE DEPENDENTES SALÁRIO FAMÍLIA
	aAdd( aTipoHE, { 'HORAS				          		 ',	 104, 105,	 "N",   2,	0,	.T., "SRA->RA_HRSEMAN"						 } ) //HORAS SEMANAIS
	aAdd( aTipoHE, { 'SALÁRIO CONTRIBUIÇÃO         		 ',	 106, 120, 	 "N",  15,	2,	.T., "nAteLim"								 } ) //VALOR DO SALÁRIO CONTRIBUIÇÃO
	aAdd( aTipoHE, { 'F.G.T.S		               		 ',	 121, 135, 	 "N",  15,	2,	.T., "nFgts"								 } ) //VALOR DO F.G.T.S.
	aAdd( aTipoHE, { 'VALOR CRÉDITOS               		 ',	 136, 150, 	 "N",  15,	2,	.T., "TOTVENC"								 } ) //VALOR TOTAL DOS CRÉDITOS
	aAdd( aTipoHE, { 'VALOR DÉBITO                 		 ',	 150, 165, 	 "N",  15,	2,	.T., "TOTDESC"								 } ) //VALOR TOTAL DOS DÉBITOS
	aAdd( aTipoHE, { 'VALOR LIQUIDO               		 ',	 166, 180, 	 "N",  15,	2,	.T., "TOTVENC-TOTDESC"						 } ) //VALOR LIQUIDO DO PAGAMENTO
	aAdd( aTipoHE, { 'VALOR FIXO / BASE					 ',	 181, 195, 	 "N",  15,	2,	.T., "SRA->RA_SALARIO"						 } ) //VALOR FIXO / BASE
	aAdd( aTipoHE, { 'BASE DE CÁLCULO I.R.R.F      		 ',	 196, 210, 	 "N",  15,	2,	.T., "If(cTipoRot<>'6', nBaseIr, 0)"		 } ) //VALOR DA BASE DO I.R.R.F.
	aAdd( aTipoHE, { 'BASE DE CÁLCULO F.G.T.S.     		 ',	 211, 225, 	 "N",  15,	2,	.T., "nBaseFgts"							 } ) //VALOR DA BASE DO F.G.T.S.
	aAdd( aTipoHE, { 'DISPONIBILIZAÇÃO 					 ',	 226, 227, 	 "C",   2,	0,	.T., "01"								 	 } ) //PRAZO PARA DISPONIBILIZAÇÃO DO HOLERITE
	aAdd( aTipoHE, { 'BRANCOS		 					 ',	 228, 230, 	 "C",   3,	0,	.F., "Space(3)"								 } ) //COMPLEMENTO DE REGISTRO
	aAdd( aTipoHE, { 'OCORRÊNCIAS		          		 ',	 231, 240, 	 "C",  10,	0,	.F., "Space(10)"							 } ) //CÓDIGO OCORRÊNCIAS NO RETORNO
	
	// REGISTRO DETALHES DO COMPROVANTE - SEGMENTO E - PAGAMENTOS DE SALÁRIOS ATRAVÉS DE CRÉDITO EM CONTA CORRENTE (HOLERITE)
	aTipoCCE := {}
	//           	   Descricao                                Ini  Fim   Tipo  Tam  Dec Obrig	 Conteudo
	aAdd( aTipoCCE, { 'CÓDIGO DO BANCO                      ', 001, 003,   	'N',  	3,  0, 	.T., 'cBancoEmp'						} ) // CÓDIGO BANCO NA COMPENSAÇÃO
	aAdd( aTipoCCE, { 'CÓDIGO DO LOTE                       ', 004, 007,   	'N',  	4,  0, 	.T., 'cNum' 							} ) // LOTE IDENTIFICAÇÃO DE PAGTO
	aAdd( aTipoCCE, { 'TIPO DE REGISTRO             		', 008, 008,	'N',	1,	0,	.T., '3'								} ) // REGISTRO DETALHE DE LOTE
	aAdd( aTipoCCE, { 'NÚMERO DO REGISTRO           		', 009, 013,	'N',	5,	0,	.T., "nSeq_"							} ) // Nº SEQUENCIAL REGISTRO NO LOTE
	aAdd( aTipoCCE, { 'CÓDIGO SEGMENTO              		', 014, 014,	'C',	1,	0,	.T., '"E"'								} ) // CÓDIGO SEGMENTO REG. DETALHE
	aAdd( aTipoCCE, { 'BRANCOS                      		', 015, 017, 	'C',	3,	0,	.F., "SPACE(2)"							} ) // COMPLEMENTO DE REGISTRO
	aAdd( aTipoCCE, { 'MOVIMENTO            		 		', 018, 018, 	'C',	1,	0,	.T., "cIdLan"							} ) // TIPO DE MOVIMENTO
	//INFORMAÇÕES COMPLEMENTARES PARA HOLERITE OU COMPLEMENTARES INFORME DE RENDIMENTOS (ANEXO D)
	aAdd( aTipoCCE, { 'DESCRIÇÃO (1)                        ', 019, 048, 	'C',   30,	0,	.F., "aInfoPD[1][1]"					} ) // DESCRIÇÃO DO CRÉDITO / DESCONTO
	aAdd( aTipoCCE, { 'BRANCOS                              ', 049, 053, 	'C',    5,	0,	.F., "SPACE(5)"							} ) // COMPLEMENTO DE REGISTRO
	aAdd( aTipoCCE, { 'VALOR (1)        	                ', 054, 068, 	'N',   15,	2,	.F., "aInfoPD[1][2]"					} ) // VALOR DO CRÉDITO / DESCONTO
	aAdd( aTipoCCE, { 'DESCRIÇÃO (2)                        ', 069, 098, 	'C',   30,	0,	.F., "aInfoPD[2][1]"					} ) // DESCRIÇÃO DO CRÉDITO / DESCONTO
	aAdd( aTipoCCE, { 'BRANCOS                              ', 099, 103, 	'C',    5,	0,	.F., "SPACE(5)"							} ) // COMPLEMENTO DE REGISTRO
	aAdd( aTipoCCE, { 'VALOR (2)        	                ', 104, 118, 	'N',   15,	2,	.F., "aInfoPD[2][2]"					} ) // VALOR DO CRÉDITO / DESCONTO
	aAdd( aTipoCCE, { 'DESCRIÇÃO (3)                        ', 119, 148, 	'C',   30,	0,	.F., "aInfoPD[3][1]"					} ) // DESCRIÇÃO DO CRÉDITO / DESCONTO
	aAdd( aTipoCCE, { 'BRANCOS                              ', 149, 153, 	'C',    5,	0,	.F., "SPACE(5)"							} ) // COMPLEMENTO DE REGISTRO
	aAdd( aTipoCCE, { 'VALOR (3)        	                ', 154, 168, 	'N',   15,	2,	.F., "aInfoPD[3][2]"					} ) // VALOR DO CRÉDITO / DESCONTO
	aAdd( aTipoCCE, { 'DESCRIÇÃO (4)                        ', 169, 198, 	'C',   30,	0,	.F., "aInfoPD[4][1]"					} ) // DESCRIÇÃO DO CRÉDITO / DESCONTO
	aAdd( aTipoCCE, { 'BRANCOS                              ', 199, 203, 	'C',    5,	0,	.F., "SPACE(5)"							} ) // COMPLEMENTO DE REGISTRO
	aAdd( aTipoCCE, { 'VALOR (4)        	                ', 204, 218, 	'N',   15,	2,	.F., "aInfoPD[4][2]"					} ) // VALOR DO CRÉDITO / DESCONTO
	
	aAdd( aTipoCCE, { 'BRANCOS		 					 	', 219, 230, 	'C',   12,	0,	.F., "Space(12)"						} ) // COMPLEMENTO DE REGISTRO
	aAdd( aTipoCCE, { 'OCORRÊNCIAS		          		 	', 231, 240, 	'C',   10,	0,	.F., "SPACE(10)"						} ) // CÓDIGO OCORRÊNCIAS NO RETORNO
	
	If !Empty(Mensag1) .Or. !Empty(Mensag2) .Or. !Empty(Mensag3)
		// REGISTRO DETALHES DO COMPROVANTE - SEGMENTO F - PAGAMENTOS DE SALÁRIOS ATRAVÉS DE CRÉDITO EM CONTA CORRENTE (HOLERITE)
		aTipoCCF := {}
		//          	    Descricao                              Ini  Fim    Tipo  Tam  Dec Obrig	 Conteudo
		aAdd( aTipoCCF, { 'CÓDIGO DO BANCO                      ', 001, 003,   	'N',  	3,  0, 	.T., 'cBancoEmp'						} ) // CÓDIGO BANCO NA COMPENSAÇÃO
		aAdd( aTipoCCF, { 'CÓDIGO DO LOTE                       ', 004, 007,   	'N',  	4,  0, 	.T., 'cNum' 							} ) // LOTE IDENTIFICAÇÃO DE PAGTO
		aAdd( aTipoCCF, { 'TIPO DE REGISTRO             		', 008, 008,	'N',	1,	0,	.T., '"3"'								} ) // REGISTRO DETALHE DE LOTE
		aAdd( aTipoCCF, { 'NÚMERO DO REGISTRO           		', 009, 013,	'N',	5,	0,	.T., "nSeq_"							} ) // Nº SEQUENCIAL REGISTRO NO LOTE
		aAdd( aTipoCCF, { 'CÓDIGO SEGMENTO              		', 014, 014,	"C",	1,	0,	.T., '"F"'								} ) // CÓDIGO SEGMENTO REG. DETALHE
		aAdd( aTipoCCF, { 'BRANCOS                      		', 015, 017, 	"C",	3,	0,	.F., "SPACE(3)"							} ) // COMPLEMENTO DE REGISTRO
		aAdd( aTipoCCF, { 'MENSAGEM/INFORMAÇÕES COMPLEMENTARES	', 018, 065, 	"C", 	48,	0,	.F., "Left(DESC_MSG1+Space(48),48)"		} ) // INFORMAÇÕES COMPLEMENTARES PARA HOLERITE OU COMPLEMENTARES INFORME DE RENDIMENTOS
		aAdd( aTipoCCF, { 'MENSAGEM/INFORMAÇÕES COMPLEMENTARES	', 066, 113, 	"C", 	48,	0,	.F., "Left(DESC_MSG2+Space(48),48)"		} ) // INFORMAÇÕES COMPLEMENTARES PARA HOLERITE OU COMPLEMENTARES INFORME DE RENDIMENTOS
		aAdd( aTipoCCF, { 'MENSAGEM/INFORMAÇÕES COMPLEMENTARES	', 114, 161, 	"C", 	48,	0,	.F., "Left(DESC_MSG3+Space(48),48)"		} ) // INFORMAÇÕES COMPLEMENTARES PARA HOLERITE OU COMPLEMENTARES INFORME DE RENDIMENTOS
		aAdd( aTipoCCF, { 'BRANCOS		 					 	', 162, 230, 	"C",  	69,	0,	.F., "SPACE(69)"						} ) // COMPLEMENTO DE REGISTRO
		aAdd( aTipoCCF, { 'OCORRÊNCIAS		          		 	', 231, 240, 	"C",	10,	0,	.F., "SPACE(10)"						} ) // CÓDIGO OCORRÊNCIAS NO RETORNO
	EndIf
	
	// REGISTRO TRAILER DO LOTE 
	aTipo3 := {}
	//              Descricao                                Ini  Fim   Tipo  Tam Dec Obrig	Conteudo
	aAdd( aTipo3, { 'CÓDIGO DO BANCO                     ', 001, 003,  	'N',  	3,  0, 	.T., 'cBancoEmp'							 } ) // CÓDIGO BANCO NA COMPENSAÇÃO
	aAdd( aTipo3, { 'CÓDIGO DO LOTE                      ', 004, 007,  	'N',  	4,  0, 	.T., 'cNum' 								 } ) // LOTE IDENTIFICAÇÃO DE PAGTO
	aAdd( aTipo3, { 'TIPO DE REGISTRO             		 ', 008, 008,	'N',	1,	0,	.T., '5'									 } ) // REGISTRO DETALHE DE LOTE
	aAdd( aTipo3, { 'BRANCOS                      		 ', 009, 017, 	"C",	9,	0,	.F., "SPACE(9)"								 } ) // COMPLEMENTO DE REGISTRO
	aAdd( aTipo3, { 'TOTAL QTDE REGISTROS         		 ', 018, 023,	'N',	6,	0,	.T., "nTotRLote"							 } ) // QTDE REGISTROS DO LOTE
	aAdd( aTipo3, { 'TOTAL VALOR PAGTOS         		 ', 024, 041,	'N',   18,	2,	.T., "nTotLiqEmp"							 } ) // SOMA VALOR DOS PGTOS DO LOTE
	aAdd( aTipo3, { 'ZEROS	                      		 ', 042, 059, 	"N",   18,	0,	.T., "0"									 } ) // COMPLEMENTO DE REGISTRO
	aAdd( aTipo3, { 'BRANCOS		 					 ', 060, 230, 	"C",  171,	0,	.F., "SPACE(171)"							 } ) // COMPLEMENTO DE REGISTRO
	aAdd( aTipo3, { 'OCORRÊNCIAS		          		 ', 231, 240, 	"C",   10,	0,	.F., "SPACE(10)"							 } ) // CÓDIGO OCORRÊNCIAS NO RETORNO
	
	// REGISTRO TRAILER DE ARQUIVO
	aTipoTR := {}
	//              Descricao                                Ini  Fim   Tipo  Tam Dec Obrig	Conteudo
	aAdd( aTipoTR, { 'CÓDIGO DO BANCO                     ', 001, 003, 	'N',  	3,  0, 	.T., 'cBancoEmp'						 } ) // CÓDIGO BANCO NA COMPENSAÇÃO
	aAdd( aTipoTR, { 'CÓDIGO DO LOTE                      ', 004, 007, 	'N',  	4,  0, 	.T., '9999'								 } ) // LOTE DE SERVIÇO
	aAdd( aTipoTR, { 'TIPO DE REGISTRO                    ', 008, 008, 	'N',  	1,  0, 	.T., '9'								 } ) // REGISTRO TRAILER DE ARQUIVO
	aAdd( aTipoTR, { 'BRANCOS                             ', 009, 017, 	'C',  	9,  0, 	.F., 'Space(9)'							 } ) // COMPLEMENTO DE REGISTRO
	aAdd( aTipoTR, { 'TOTAL QTDE DE LOTES                 ', 018, 023, 	'N',  	6,  0, 	.T., '1'								 } ) // QTDE LOTES DO ARQUIVO
	aAdd( aTipoTR, { 'TOTAL QTDE REGISTROS                ', 024, 029, 	'N',  	6,  0, 	.T., '++nTotRLote'    					 } ) // QTDE REGISTROS DO ARQUIVO
	aAdd( aTipoTR, { 'BRANCOS                             ', 030, 240, 	'C',  211,  0, 	.F., 'Space(211)'						 } ) // COMPLEMENTO DE REGISTRO
	
	begin sequence
		
		//Verifica se Arquivo Existe
		If File( cNomeArq )
			If ( nAviso := Aviso( STR0005, STR0015 + AllTrim( cNomeArq ) + STR0016, {'Sim', 'Não'} ) ) == 1
				//Deleta Arquivo
				If fErase( cNomeArq ) <> 0
					MsgAlert( STR0017 +AllTrim( cNomeArq )+'.' )
					Return NIL
				EndIf
			Else
				Return NIL
			EndIf
		EndIf
		
		//Verifica se Nome de Arquivo em Branco
		If Empty( cNomeArq )
			MsgAlert( STR0018, STR0019 )
			Return NIL
		Else
			//Cria Arquivo
			nHdl := fCreate( cNomeArq )
			nSeq_ := 0
			lContinua := .T.
			
			//Verifica Criacao do Arquivo
			If nHdl == -1
				MsgAlert( STR0020 + AllTrim( cNomeArq )+STR0021, STR0019 )
				Return NIL
			EndIf
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Selecionando o Primeiro Registro e montando Filtro.          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSeek(cFilDe + cMatDe, .T. )
		cInicio := "SRA->RA_FILIAL + SRA->RA_MAT"
		cFim    := cFilAte + cMatAte
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Carrega Regua Processamento                                  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cAliasTMP := "QNRO"
		cSit     := "%"+fSqlIn(cSituacao,1)+"%"
		cCat     := "%"+fSqlIn(cCategoria,1)+"%"
		BeginSql alias cAliasTMP
			SELECT COUNT(*) as NROREG
			FROM %table:SRA% SRA
			WHERE      SRA.RA_FILIAL BETWEEN %exp:cFilDe%   AND %exp:cFilAte%
			AND SRA.RA_MAT    BETWEEN %exp:cMatDe%   AND %exp:cMatAte%
			AND SRA.RA_CC     BETWEEN %exp:cCCDe%    AND %exp:cCCAte%
			AND SRA.RA_DEPTO  BETWEEN %exp:cDeptoDe% AND %exp:cDeptoAte%
			AND SRA.RA_PROCES =  %exp:cProcesso%  
			AND SRA.RA_SITFOLH IN (%exp:cSit%)    
			AND SRA.RA_CATFUNC IN (%exp: cCat%)   
			AND SRA.%notDel%
		EndSql
		
		nRegProc := (cAliasTMP)->(NROREG)
		
		( cAliasTMP )->( dbCloseArea() )
		
		ProcRegua(nRegProc)	// Total de elementos da regua
		
		dbSelectArea("SRA")
		
		TOTVENC:= TOTDESC:= FLAG:= CHAVE := 0
		
		Desc_Fil := Desc_End := DESC_CC:= DESC_FUNC:= ""
		DESC_MSG1:= DESC_MSG2:= DESC_MSG3:= Space( 01 )
		cFilialAnt := space(FWGETTAMFILIAL)
		cFuncaoAnt := "    "
		cCcAnt     := Space( 9 )
		Vez        := 0
		OrdemZ     := 0
		
		GeraITU0() // CABEÇALHO DO ARQUIVO
		GeraITU1() // CABEÇALHO DO LOTE
		
		dbSelectArea( "SRA" )
		While SRA->(!EOF()) .AND. &cInicio <= cFim
			
			
			alinhaFunc	:= {}
			lAbortFunc  := .F.
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Movimenta Regua Processamento                                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			IncProc() // Anda a regua
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Consiste Parametrizacao do Intervalo de Impressao            ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			
			IF	( SRA->RA_NOME < cNomDe )  .OR. ( SRA->RA_NOME > cNomAte )    .OR. ;
			( SRA->RA_MAT < cMatDe )   .OR. ( SRA->RA_MAT > cMatAte )     .OR. ;
			( SRA->RA_CC < cCcDe )     .OR. ( SRA->RA_CC > cCcAte )      .Or. ;
			( SRA->RA_DEPTO < cDeptoDe ) .OR. ( SRA->RA_DEPTO > cDeptoAte )
				SRA->( dbSkip() )
				Loop
			EndIf
			
			If ALLTRIM(SRA->RA_PROCES)!= Alltrim(cProcesso)
				SRA->( dbSkip() )
				Loop
			EndIf
			// Se o funcionario nao tiver conta no Itaú nao envia
			If !(Subs( SRA->RA_BCDEPSA, 1, 3 ) $ '341/409')
				SRA->( dbSkip() )
				Loop
			EndIf
			
			aLanca:={}         // Zera Lancamentos
			aProve:={}         // Zera Lancamentos
			aDesco:={}         // Zera Lancamentos
			aBases:={}         // Zera Lancamentos
			//aVerbHrs:={}
			nAteLim := nBaseFgts := nFgts := nBaseIr := nBaseIrFe := 0.00
			
			Ordem_rel := 1     // Ordem dos Recibos
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica Data Demissao         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cSitFunc := SRA->RA_SITFOLH
			dDtPesqAf:= CTOD("01/" + Left(cMesAnoRef,2) + "/" + Right(cMesAnoRef,4),"DDMMYY")
			If cSitFunc == "D" .And. (!Empty(SRA->RA_DEMISSA) .And. MesAno(SRA->RA_DEMISSA) > MesAno(dDtPesqAf))
				cSitFunc := " "
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Consiste situacao e categoria dos funcionarios			     |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !( cSitFunc $ cSituacao ) .OR.  ! ( SRA->RA_CATFUNC $ cCategoria )
				SRA->(dbSkip())
				Loop
			Endif
			
			If cSitFunc $ "D" .And. Mesano(SRA->RA_DEMISSA) # Mesano(dDataRef)
				SRA->(dbSkip())
				Loop
			Endif
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Consiste controle de acessos e filiais validas				 |
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !(SRA->RA_FILIAL $ fValidFil()) .Or. !Eval(cAcessaSRA)
				SRA->(dbSkip())
				Loop
			EndIf
			
			If SRA->RA_CODFUNC #cFuncaoAnt           // Descricao da Funcao
				DescFun( Sra->Ra_Codfunc, Sra->Ra_Filial )
				cFuncaoAnt:= Sra->Ra_CodFunc
			EndIf
			
			If SRA->RA_CC #cCcAnt                   // Centro de Custo
				cCcusto:= DescCC( SRA->RA_CC, SRA->RA_FILIAL )
				cCcAnt:= SRA->RA_CC
			EndIf
			
			//-Busca o Salario Base do Funcionario
			nSalario := fBuscaSal(dDataRef,,,.F.)
			dbSelectArea( "SRA" )
			If nSalario == 0
				nSalario := SRA->RA_SALARIO
			EndIf
			
			If SRA->RA_Filial #cFilialAnt
				If ! Fp_CodFol( @aCodFol, SRA->RA_FILIAL ) .OR. ! fInfo( @aInfo, SRA->RA_FILIAL )
					Exit
				EndIf
				Desc_Fil := aInfo[3]
				Desc_End := aInfo[4]                // Dados da Filial
				Desc_CGC := aInfo[8]
				
				DESC_MSG1:= DESC_MSG2:= DESC_MSG3:= Space( 01 )
				
				// MENSAGENS
				If !Empty(MENSAG1)        
					nPosMsg1		:= fPosTab("S036",Alltrim(MENSAG1), "==", 4)
					If nPosMsg1 > 0 
						DESC_MSG1	:= fTabela("S036",nPosMsg1,5)
					EndIf
				Endif   
				
				If !Empty(MENSAG2)        
					nPosMsg2		:= fPosTab("S036",Alltrim(MENSAG2), "==", 4)
					If nPosMsg2 > 0 
						DESC_MSG2	:= fTabela("S036",nPosMsg2,5)
					EndIf  
				EndIf
				
				If !Empty(MENSAG3)        
					nPosMsg3		:= fPosTab("S036",Alltrim(MENSAG3), "==", 4)
					If nPosMsg3 > 0 
						DESC_MSG3	:= fTabela("S036",nPosMsg3,5)
					EndIf
				EndIf
				dbSelectArea( "SRA" )
				
				cFilialAnt := SRA->RA_FILIAL
				
			EndIf
			
			Totvenc := Totdesc := 0
			
			//Retorna as verbas do funcionario, de acordo com os periodos selecionados
			aVerbasFunc	:= RetornaVerbasFunc(	SRA->RA_FILIAL					,; // Filial do funcionario corrente
			SRA->RA_MAT	  					,; // Matricula do funcionario corrente
			NIL								,; //
			cRoteiro	  					,; // Roteiro selecionado na pergunte
			NIL			  					,; // Array com as verbas que deverão ser listadas. Se NIL retorna todas as verbas.
			aPerAberto	  					,; // Array com os Periodos e Numero de pagamento abertos
			aPerFechado	 	 				 ) // Array com os Periodos e Numero de pagamento fechados
			
			if len(aVerbasFunc) <= 0
				SRA->( dbSkip())
				loop
			EndIf
			
			dbSelectArea( "SRA" )
			nSequenc++
			
			GeraITU2() // SEGMENTO A
			GeraITU3() // SEGMENTO D
			GeraITU4() // SEGMENTO E
			
			If !Empty(Mensag1) .Or. !Empty(Mensag2) .Or. !Empty(Mensag3)
				GeraITU5() // SEGMENTO F 
			EndIf
			if !lAbortFunc
				AEval( alinhaFunc, { | clinhaFunc | FWrite( nHdl, clinhaFunc) } )
			endIf
			
			dbSelectArea("SRA")
			SRA->( dbSkip() )
			TOTDESC := TOTVENC := 0
			
		EndDo
		
		GeraITU6() // TRAILER DE LOTE
		GeraITU7() // TRAILER DE ARQUIVO
		
		GeraITU() // Atualiza MV_SEQITU
		
	end sequence
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Termino do relatorio                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea( "SRA" )
	SET FILTER TO
	RetIndex( "SRA" )
	
	If !( Type( "cArqNtx" ) == "U" )
		fErase( cArqNtx + OrdBagExt() )
	EndIf
	
	Set Device To Screen
	
	MS_FLUSH()
	
Return

/*/{Protheus.doc} GeraITU0
//PREENCHIMENTO DO CABEÇALHO DO ARQUIVO
@author RH
@since 04/11/2019
@version undefined
@return return, return_description
/*/
Static Function GeraITU0()
	
	cNum := GetMV( 'MV_SEQITU',, 'NAOEXISTE' )
	
	If  cNum == 'NAOEXISTE' .OR. Empty(cNum) 
		cNum := '0000'
	EndIf
	
	cNum  := Soma1( cNum )
	
	FWrite( nHdl, GeraLinhas( aTipo0 ) )
	
Return NIL

/*/{Protheus.doc} GeraITU1
//CABEÇALHO DO LOTE
@author RH
@since 04/11/2019
@version undefined
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GeraITU1()
	
	FWrite( nHdl, GeraLinhas( aTipo1 ) )
	
Return NIL

/*/{Protheus.doc} GeraITU2
SEGMENTO A
@author RH
@since 04/11/2019
@version undefined
@return return, return_description
/*/
Static Function GeraITU2()
	
	Local   nReg
	Local   cAux     := ''
	
	Private cCtaFunc   := ''
	Private cDgCtaFunc := ''
	Private cNumCP     := ''
	
	Private cCodLan  := ''
	Private nValLan  := 0
	
	cAux       := AllTrim( SRA->RA_CTDEPSA )
	cCtaFunc   := StrTran(SubStr( cAux, 1, Len( cAux  ) - 1 ), "-", "")
	cDgCtaFunc := SubStr( cAux, Len( cAux ), 1 )
	cNumCP     := StrZero( Val( SRA->RA_NUMCP ), 6 ) + IIF(!Empty(SRA->RA_UFCP), "-" + SRA->RA_UFCP, "" )
	
	nSeq_++
	
	For nReg := 1 to Len(aVerbasFunc)
		
		If (Len(aPerAberto) > 0 .AND. !Eval(cAcessaSRC)) .OR. (Len(aPerFechado) > 0 .AND. !Eval(cAcessaSRD)) .Or.;
		( aVerbasFunc[nReg,7] <= 0 )
			dbSkip()
			Loop
		EndIf
		
		cCodLan    := aVerbasFunc[nReg][3]
		nValLan    := aVerbasFunc[nReg][7]
		If PosSrv( cCodLan, SRA->RA_FILIAL, "RV_TIPOCOD" ) == "1"
			TOTVENC += nValLan
		Elseif SRV->RV_TIPOCOD == "2"
			TOTDESC += nValLan
		Else
			Loop
		Endif
	Next nReg
	
	nSeqLanc++
	nQtdComp++
	
	Aadd(alinhaFunc, GeraLinhas( aTipo2 ))
	
Return NIL

/*/{Protheus.doc} GeraITU3
PREENCHIMENTO DO BLOCO D
@author RH
@since 04/11/2019
/*/
Static Function GeraITU3()
	
	Local   nReg
	
	Local   cAux       := ''
	Private cCtaFunc   := ''
	Private cDgCtaFunc := ''
	Private cNumCP     := ''
	
	Private cCodLan  := ''
	Private cDescLan := ''
	Private nValLan  := 0
	Private nQtdLan  := 0
	Private cTipoLan := ''
	
	nQtdComp         := 0
	
	If TOTDESC + TOTVENC > 0
		TOTDESC	:= 0
		TOTVENC	:= 0
	EndIf
	
	If lAbortFunc
		Return
	EndIf
	
	cAux       := AllTrim( SRA->RA_CTDEPSA )
	cCtaFunc   := SubStr( cAux, 1, Len( cAux  ) - 1 )
	cDgCtaFunc := SubStr( cAux, Len( cAux ), 1 )
	cNumCP     := StrZero( Val( SRA->RA_NUMCP ), 6 ) + IIF(!Empty(SRA->RA_UFCP), "-" + SRA->RA_UFCP, "" )
	
	For nReg := 1 to Len(aVerbasFunc)
		
		If (Len(aPerAberto) > 0 .AND. !Eval(cAcessaSRC)) .OR. (Len(aPerFechado) > 0 .AND. !Eval(cAcessaSRD)) .Or. ( aVerbasFunc[nReg,7] <= 0 )
			dbSkip()
			Loop
		EndIf
		
		cCodLan    := aVerbasFunc[nReg][3]
		cDescLan   := DescPd(aVerbasFunc[nReg][3],Sra->Ra_Filial)
		nQtdLan	   := aVerbasFunc[nReg][6]
		nValLan    := aVerbasFunc[nReg][7]
		
		If (aVerbasFunc[nReg,3] $ aCodFol[10,1] + '*' + aCodFol[15,1] + '*' + aCodFol[27,1])
			nBaseIr += aVerbasFunc[nReg,7]
		ElseIf (aVerbasFunc[nReg,3] $ aCodFol[13,1] + '*' + aCodFol[19,1])
			nAteLim += aVerbasFunc[nReg,7]
			// BASE FGTS SAL, 13.SAL E DIF DISSIDIO E DIF DISSIDIO 13
		Elseif aVerbasFunc[nReg,3] $ aCodFol[108,1] + '*' + aCodFol[17,1] + '*' + aCodFol[337,1] + '*' + aCodFol[398,1]
			nBaseFgts += aVerbasFunc[nReg,7]
			// VALOR FGTS SAL, 13.SAL E DIF DISSIDIO E DIF.DISSIDIO 13
		Elseif aVerbasFunc[nReg,3] $ aCodFol[109,1] + '*' + aCodFol[18,1] + '*' + aCodFol[339,1] + '*' + aCodFol[400,1]
			nFgts += aVerbasFunc[nReg,7]
		Elseif (aVerbasFunc[nReg,3] == aCodFol[16,1])
			nBaseIrFe += aVerbasFunc[nReg,7]
		Endif
		
		If PosSrv( cCodLan, SRA->RA_FILIAL, "RV_TIPOCOD" ) == "1"
			TOTVENC += nValLan
		Elseif SRV->RV_TIPOCOD == "2"
			TOTDESC += nValLan
		Else
			LOOP
		Endif
		
	Next nReg
	
	nSeqLanc++
	
	Aadd(alinhaFunc, GeraLinhas( aTipoHE ))
	
	nQtdComp++
	
	nTotVenEmp += TOTVENC
	nTotDesEmp += TOTDESC
	nTotLiqEmp += (TOTVENC - TOTDESC)
	
Return NIL

/*/{Protheus.doc} GeraITU4
Preenchimento do bloco E
@author RH
@since 04/11/2019
@version undefined
@return return, return_description
/*/
Static Function GeraITU4()
	
	Local nI, nJ      		:= 1
	Local nReg
	Local aInfoP     	:= {} // Informações das verbas de Provento
	Local aInfoD     	:= {} // Informações das verbas de Desconto
	Local aAux			:= {}
	
	Local   cAux       	:= ''
	Private cCtaFunc   	:= ''
	Private cDgCtaFunc 	:= ''
	Private cNumCP     	:= ''
	Private aInfoPD    	:= {}
	Private cIdLan   	:= ''
	
	nQtdComp         := 0
	
	If lAbortFunc
		return
	EndIf
	
	cAux       := AllTrim( SRA->RA_CTDEPSA )
	cCtaFunc   := SubStr( cAux, 1, Len( cAux  ) - 1 )
	cDgCtaFunc := SubStr( cAux, Len( cAux ), 1 )
	cNumCP     := StrZero( Val( SRA->RA_NUMCP ), 6 ) + IIF(!Empty(SRA->RA_UFCP), "-" + SRA->RA_UFCP, "" )
	
	For nReg := 1 to Len(aVerbasFunc)
		
		If (Len(aPerAberto) > 0 .AND. !Eval(cAcessaSRC)) .OR. (Len(aPerFechado) > 0 .AND. !Eval(cAcessaSRD)) .Or.;
		( aVerbasFunc[nReg,7] <= 0 )
			dbSkip()
			Loop
		EndIf
		
		cCodLan    := aVerbasFunc[nReg][3]
		cDescLan   := DescPd(aVerbasFunc[nReg][3], SRA->RA_FILIAL, 30)
		nQtdLan	   := aVerbasFunc[nReg][6]
		nValLan    := aVerbasFunc[nReg][7]
		
		If (aVerbasFunc[nReg,3] $ aCodFol[10,1] + '*' + aCodFol[15,1] + '*' + aCodFol[27,1])
			nBaseIr += aVerbasFunc[nReg,7]
		ElseIf (aVerbasFunc[nReg,3] $ aCodFol[13,1] + '*' + aCodFol[19,1])
			nAteLim += aVerbasFunc[nReg,7]
			// BASE FGTS SAL, 13.SAL E DIF DISSIDIO E DIF DISSIDIO 13
		Elseif aVerbasFunc[nReg,3] $ aCodFol[108,1] + '*' + aCodFol[17,1] + '*' + aCodFol[337,1] + '*' + aCodFol[398,1]
			nBaseFgts += aVerbasFunc[nReg,7]
			// VALOR FGTS SAL, 13.SAL E DIF DISSIDIO E DIF.DISSIDIO 13
		Elseif aVerbasFunc[nReg,3] $ aCodFol[109,1] + '*' + aCodFol[18,1] + '*' + aCodFol[339,1] + '*' + aCodFol[400,1]
			nFgts += aVerbasFunc[nReg,7]
		Elseif (aVerbasFunc[nReg,3] == aCodFol[16,1])
			nBaseIrFe += aVerbasFunc[nReg,7]
		Endif
		
		If PosSrv( cCodLan , SRA->RA_FILIAL , "RV_TIPOCOD" ) == "1"
			aAdd(aInfoP, {cDescLan, nValLan})
		Elseif SRV->RV_TIPOCOD == "2"
			aAdd(aAux, {cDescLan, nValLan})
		Else
			Loop
		Endif
		
		If Len(aInfoP) == 4
			aInfoPD := aInfoP
			cIdLan  := "1" 
			Aadd(alinhaFunc, GeraLinhas( aTipoCCE ))
			aInfoP 	:= {}
			aInfoPD := {}
		ElseIf Len(aAux) == 4
			Aadd(aInfoD, aAux)
			aAux := {}
		EndIf
		
		nSeqLanc++
		nQtdComp++
		
	Next nReg
	
	If Len(aInfoP) > 0 // Alguma verba de Provento que não foi gerada no arquivo
		
		// Garante que o array terá 4 posições
		For nI := Len(aInfoP) TO 4
			aAdd(aInfoP, {Space(30), 0})
		Next
		
		aInfoPD := aInfoP
		cIdLan  := "1" 
		
		Aadd(alinhaFunc, GeraLinhas( aTipoCCE ))
		
		aInfoPD := {}
		
	EndIf
	
	If Len(aInfoD) > 0 .Or. Len(aAux) > 0// Alguma verba de Desconto que não foi gerada no arquivo
		cIdLan  := "2" 
		
		If Len(aAux) > 0
			Aadd(aInfoD, aAux)
		EndIf
		
		// Garante que o array terá 4 posições
		For nI := 1 TO Len(aInfoD)
			For nJ := Len(aInfoD[nI]) TO 4
				aAdd(aInfoD[nI], {Space(30), 0})
			Next nJ
			
			aInfoPD := aInfoD[nI]
			
			Aadd(alinhaFunc, GeraLinhas( aTipoCCE ))
			
			aInfoPD := {} 
		Next nI
		
	EndIf
	
Return NIL

/*/{Protheus.doc} GeraITU5
//CARREGANDO AS INFORMAÇÕES DO BLOCO F
@author RH
@since 04/11/2019
@version undefined
@return return, return_description
/*/
Static Function GeraITU5()
	
	if lAbortFunc
		return
	endIf
	
	Aadd(alinhaFunc,GeraLinhas( aTipoCCF ))
	
Return NIL

/*/{Protheus.doc} GeraITU6
ROTINA QUE CARREGA OS DADOS DO TRAILER DO LOTE
@author RH
@since 04/11/2019
@version undefined
@return return, return_description
/*/
Static Function GeraITU6()
	
	If lAbortFunc
		return
	EndIf
	
	FWrite( nHdl, GeraLinhas( aTipo3 ))
	
Return NIL

/*/{Protheus.doc} GeraITU7
Gera o Registro Trailer de Arquivo
@author Cícero Alves
@since 22/03/2021
/*/
Static Function GeraITU7()
	
	If lAbortFunc
		Return
	EndIf
	
	FWrite( nHdl, GeraLinhas( aTipoTR ))
	
Return

/*/{Protheus.doc} GeraITU
CARREGA O NÚMERO UTILIZADO DO LOTE NO PARÂMETRO
@author RH
@since 04/11/2019
@version undefined
@return return, return_description
/*/
Static Function GeraITU()
	
	PutMV( 'MV_SEQITU', cNum  )
	
Return NIL

/*/{Protheus.doc} GeraLinhas
//Geracao de linhas de texto 
@author edvf8
@since 12/11/2019
@version undefined
@return return, return_description
@param aTipo, array, descricao
/*/
Static Function GeraLinhas( aTipo )
	
	Local cLinha     	:= ''
	Local nTamMaxLin 	:= 240
	Local nI         	:= 0
	local cNomCampo		:= ""
	
	For nI := 1 To Len( aTipo )
		
		bAux      := &( '{ || ' + aTipo[nI][8] + ' } ' )
		
		cTipo     := aTipo[nI][4]
		nTamanho  := aTipo[nI][5]
		nDecimal  := aTipo[nI][6]
		lObrigat  := aTipo[nI][7]
		cNomCampo := aTipo[nI][1]
		
		uConteudo := EVal( bAux )
		uConteudo := IIf( ValType( uConteudo ) == 'U' , '', EverChar( uConteudo ) )
		
		If cTipo == 'C' .AND. (!lObrigat .OR. !empty(uConteudo) )
			uConteudo := PADR( FwNoAccent(SubStr( AllTrim( uConteudo ), 1, nTamanho )), nTamanho )
		ElseIf cTipo == 'N'
			uConteudo := StrZero( Val( uConteudo ) * (10^nDecimal), nTamanho ) 
		ElseIf cTipo == 'X' .AND. (!lObrigat .OR. !empty(uConteudo))
			uConteudo := PADL( SubStr( AllTrim( uConteudo ), 1, nTamanho ), nTamanho )
		Else
			Aadd(aIncons,{STR0024+ cNomCampo +STR0023+ SRA->RA_FILIAL + ' - ' + SRA->RA_MAT   + STR0022,""})
			lAbortFunc := .T.
			return cLinha
		EndIf
		
		cLinha += uConteudo
		
	Next
	
	nTotRLote++
	
	cLinha += Replicate( ' ', nTamMaxLin - Len( cLinha ) ) + CRLF
	
Return cLinha


/*/{Protheus.doc} EverChar
//Funcao auxiliar para transformar um campo de qualquer tipo em caracter
@author RH
@since 12/11/2019
@version undefined
@return return, return_description
@param uCpoConver, undefined, descricao

/*/
Static Function EverChar( uCpoConver )

	Local cRet  := NIL
	Local cTipo := ''

	cTipo := ValType( uCpoConver )

	If     cTipo == 'C'                    // Tipo Caracter
		cRet := uCpoConver

	ElseIf cTipo == 'N'                    // Tipo Numerico
		cRet := AllTrim( Str( uCpoConver ) )

	ElseIf cTipo == 'L'                    // Tipo Logico
		cRet := IIf( uCpoConver, '.T.', '.F.' )

	ElseIf cTipo == 'D'                    // Tipo Data
		cRet := DToC( uCpoConver )

	ElseIf cTipo == 'M'                    // Tipo Memo
		cRet := 'MEMO'

	ElseIf cTipo == 'A'                    // Tipo Array
		cRet := 'ARRAY[' + AllTrim( Str( Len( uCpoConver ) ) ) + ']'

	ElseIf cTipo == 'U'                    // Indefinido
		cRet := 'NIL'

	EndIf

Return(cRet)

/*/{Protheus.doc} fDdsEmp
//Função gerada para a consulta de dados da empresa
@author eduardo.vicente
@since 30/10/2019
/*/
Static Function fDdsEmp()
	Local aArea			:= SM0->( GetArea() )
	Local nPos			:= 0
	Local aAux			:= {}

	Local lFWCodFilSM0 	:= .T.

	If Empty(aRetSM0)
		aRetSM0	:= FWLoadSM0()
	Else
		If (nPos:= aScan(aRetSM0,{|x| x[18] == cCNPJ })) >= 1
			DbSelectArea( "SM0" )
			SM0->( DbGoTop())
			SM0->(DBSEEK(aRetSM0[nPos][1]+aRetSM0[nPos][2]))
			if at(",",M0_ENDENT) > 0
				cNumLocal	:= SUBSTR(M0_ENDENT,at(",",M0_ENDENT)+1,LEN(M0_ENDENT))
			endif
			if at(",",M0_ENDENT) > 0
				cEndLocal	:= SUBSTR(M0_ENDENT,1,at(",",M0_ENDENT)-1)
			endif
			cCidLocal	:= SM0->M0_CIDENT
			cCepLocal	:= SM0->M0_CEPENT
			cUFLocal	:= SM0->M0_ESTENT
		EndIf
	EndIf
	RestArea( aArea )
Return aRetSM0

/*/{Protheus.doc} fCheckFer
//Checagem de Inicio e Fim de Férias.
@author RH	
@since 04/11/2019
@return return, return_description
@param cTipo, characters, descricao
/*/
Static Function fCheckFer( cTipo )
	
	Local aOld := GETAREA()
	Local cRet := Replicate("0",08)
	
	If SRA->RA_SITFOLH == "F"
		If SRF->(dbSeek( SRA->(RA_FILIAL+RA_MAT) ))
			If SRH->(dbSeek( SRA->(RA_FILIAL+RA_MAT)+Dtos(SRF->RF_DATABAS) ))
				If cTipo == "INI"
					cRet := STRTRAN(DTOC(SRH->RH_DATAINI),"/","")
				ElseIf cTipo == "FIM"
					cRet := STRTRAN(DTOC(SRH->RH_DATAFIM),"/","")
				EndIf
			EndIf
		EndIf
	EndIf
	
	RESTAREA( aOld )
	
Return( cRet )
/*/{Protheus.doc} ValidX1
//Validação do Grupo de Perguntas, para não gerar error.log
@since 12/11/2019
@version undefined
@return return, return_description
@param cPergunte, characters, descricao
/*/
Static Function ValidX1(cPergunte)
Local lRet	:= .F.
Local oSX1 	:= nil
Local cPergunte:= "RECITAU"

If GetApoInfo("MSLIB.PRW")[4] >= CTOD("04/09/2018")
	oSX1 := FWSX1Util():New()
	
	oSX1:AddGroup(cPergunte)
	oSX1:SearchGroup()
	
	If Len(oSX1:aGrupo) >= 1 .And. Len(oSX1:aGrupo[1][2]) < 28
		lRet:= .T.
	EndIf

	FreeObj(oSX1) 
ElseIf Posicione( 'SX1', 1, Left(cPergunte+Space(10),10)+"01", 'X1Pergunt()') != "Processo ?"
	lRet := .T.
EndIf

If lRet
		
		ShowHelpDlg( STR0019   , ;           // Atenção
                   { STR0027} , 5 ,{STR0028},5)   
EndIf
Return lRet
