#Include "Totvs.ch"
#include "fileio.ch"
#include "TbiConn.ch"

//Colunas ARQUIVO TXT

         //Posição Inicial	      Posição Final	Tipo	Nome do Campo
#DEFINE P_DTAEMI	291 //		291				296			N		Data de Emissão
#DEFINE P_VALOR		470 //		470				487			N		Valor Original
#DEFINE P_FLUXO		210 // 		210				234			A		Código de Fluxo de Caixa
#DEFINE P_CAIXA		460 //		460				469			A		Código da Conta Caixa
#DEFINE P_CCUSTO	260 // 		260				284			A		Código do C. Custos
#DEFINE P_HISTO		339 //   	339				438			A		Histórico do Lançamento
#DEFINE P_PAGREC	109 // 		109				109			N  		A Pagar ou A Receber

//Tamanho Linha Arquivo TXT
#DEFINE TAM_LIN_TXT 1580
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SCIM003  ³ Autor ³ MAIA			     ³ Data ³19/09/2014   |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ±±
±±³Descricao ³ Rotina de integração com Sistema da Ingresso.com com   	  ³±±
±±³            o Movimento Financeiro via arquivo formato texto        	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Sintaxe   ³ U_SCIM003(aParam)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Parametros³ aParam = Indica se a rotina e chamada pelo schedule        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³ Uso      ³ EspecIfico Cliente Sport Club Internacional                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function SCIM003(aParam)

	Local oProcess
	Local cCadastro    	:= "Integração com Sistema da Ingresso.com"
	Local cDescRot	   	:= ""
	Local cDirGrava	 	:= ""
	Local cDirOrigem   	:= ""
	Local cPerg        	:= ""
	Local aInfoCustom  	:= {}
	Local aMvParam	    := {}
	Local aTabelas	    := {"SE5"}
	Local bProcess 	 	:= {||}
	
	Private lAuto	   	:= ( ValType(aParam) = "A" )
	Private lMsErroAuto	:= .F.
	Private aLogerro   	:= {}
	Private aLogFin    	:= {}
	

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³NAO ALTERAR A ORDEM DA SINTAXE ABAIXO!!!! ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aAdd( aMvParam, "ES_M003DIR" ) // Diretorio de origem dos arquivos de integracao do ingressos.com e o protheus
	aAdd( aMvParam, "ES_M003ARQ" ) // Diretorio de Arquivamento dos arquivos de integracao do ingressos.com e o protheus


	If lAuto// Chamada via Schedule
	
		If RpcSetEnv(aParam[1],aParam[2],,,"FIN","SCIM003",aTabelas,,,,)
			
			cDirOrigem := AllTrim(SuperGetMV(aMvParam[1],.F.,""))
			cDirGrava  := AllTrim(SuperGetMV(aMvParam[2],.F.,""))
		 	
			BatchProcess(	cCadastro, cCadastro, "SCIM003", { || M003EXEC(oProcess, Alltrim(cDirOrigem), cDirGrava, lAuto, 1, aMvParam) }, { || .F. }  )
		
			RpcClearEnv()
		
		EndIf
	
	Else
	
		cPerg := PadR("SCIM003", 10 /*TamSx3("X1_GRUPO")[1]*/ , "")
		
		CriaSx1(cPerg)
		
		Pergunte(cPerg,.F.)
		
		SuperGetMV()
		
		cDirGrava:= AllTrim(SuperGetMV(aMvParam[2],.F.,""))
		
		aAdd( aInfoCustom, { "Parametros Ambiente", 	{ || VisualSX6( aMvParam ) }, 					"PROCESSA"	})
		aAdd( aInfoCustom, { "Historico",           	{ ||                       }, 					"PROCESSA"	})
		aAdd( aInfoCustom, { "Cancelar",            	{ |oPanelCenter| oPanelCenter:oWnd:End() }, 	"CANCEL"	})
		
		bProcess := {|oProcess| M003EXEC(oProcess, AllTrim(MV_PAR01), cDirGrava, lAuto, MV_PAR02, aMvParam) }
		
		cDescRot := " Este programa tem o objetivo, importar um arquivo txt,"
		cDescRot += " integração com Sistema da Ingresso.com ."
		
		oProcess := tNewProcess():New("SCIM003",cCadastro,bProcess,cDescRot,cPerg,aInfoCustom, .T.,5, "", .T. )
	
	EndIf

Return()

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M003EXEC ³ Autor ³ MAIA				    ³ Data ³19/09/2014|±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ±±
±±³Descricao ³ Rotina de processamento dos dados para a integracao Synchro³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Sintaxe   ³ M003EXEC( oExp1, cExp1, cExp2, lExp1)                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Parametros³ oProcess = Objeto da regua de processamento e log.         ³±±
±±³          ³ cCaminho = Caminho de origem do Arquivo TXT.               ³±±
±±³          ³ cDirGrava = Diretorio de gravacao do arquivo depois de lido³±±
±±³          ³ lAuto = indica se a rotina foi chamado pelo schedule ou    ³±±
±±³          ³ menu                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³ Uso      ³ EspecIfico Cliente Sport Club Internacional                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M003EXEC( oProcess,cCaminho, cDirGrava, lAuto, nOpcRel, aMvParam )

	Local aArq 		 := {}
	Local aArqAux    := {}
	Local aRet		 := {}
	Local nPosBarra  := 0
	Local nInd	 	 := 0
	Local nX		 := 0
	Local cDirOrig   := AllTrim(SuperGetMV(aMvParam[1],.F.,""))
	Local cMsg       := "" 
	Local cArqlog    := ""
	Local cErro      := ""
	Local cLogExec   := ""
	Local lArqOK     := .T.

	cCaminho := AllTrim(cCaminho)

	If Right(cCaminho,3) == "txt" .or. Right(cCaminho,3) == "TXT" // Se for selecionado um unico arquivo
	
		aAdd(aArq, {cCaminho})
	
		If	Empty(cDirGrava)// Se o parametro de destino estiver em branco
		
			nPosBarra := Rat("\",cCaminho)
			cDirGrava := SubStr(cCaminho, 1, nPosBarra)
			
		EndIf
	
	Else// Se for seleciona um diretorio com varios arquivos
	
		If Right(cCaminho,1) != "\"
			cCaminho := cCaminho + "\"
		EndIf
		
		aArqAux := Directory( cCaminho + "*.TXT" )
		
		For nX := 1 To Len( aArqAux )
		
			aAdd(aArq,{Lower( 	cCaminho +;
			  					aArqAux[nX][1] ),;
								aArqAux[nX][2],;
								aArqAux[nX][3],;
								aArqAux[nX][4],;
								aArqAux[nX][5]}	)
			
		Next nX
		
		If	Empty(cDirGrava)//Se o parametro de destino estiver em branco
			cDirGrava := cCaminho
		EndIf
	
	EndIf	

	If Len(aArq) = 0
	
		If !lAuto
		
			cMsg := "Verifique os parâmetros. Não há arquivo(s) para importar "
			cMsg += "ou não esta no layout para a integração ingressos.com e Protheus."
			Aviso("Arquivo(s) não encontrados.", cMsg, {"OK" }, 1)
			
		EndIf
		
	Else

		If !lAuto
			oProcess:SaveLog("Inicio da Execucao")
			oProcess:SetRegua1( 0 )
		EndIf
	
		For nInd := 1 To Len( aArq )
			
			If !lAuto
				oProcess:IncRegua1("Arquivo... " + cValToChar(aArq[nInd][1]) )
			EndIf
			
			cLogExec += M003LeArq(cDirOrig, aArq[nInd][1] )// Funcao para ler o Arquivo TXT e gravar na area temporaria
			
			If len(aLogerro) == 0 // nao houve erros no arquivos, devo move-lo para parametro ES_M003ARQ
				aRet := RENOMARQ( lArqOK, aArq[nInd][1], lAuto, cDirGrava,cDirOrig )
			Else
				cArqlog := GravaLog(aArq[nInd][1])
			EndIf
			
		Next nInd
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³  gera o log final em tela monstrando ao usuario  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Len(aLogfin) > 0
	
			cErro:= ""
			
			If !Empty(cLogExec)
				cErro += cLogExec + CRLF
			EndIf

			For nInd := 1 To Len(aLogfin)
				cErro+= "Arquivo " + aLogfin[nInd][1] + CRLF+ "Linha " + cValToChar(aLogfin[nInd][2]) + " Erro " + aLogfin[nInd][3] + CRLF
			Next nInd
							
			cFileLog:= cCaminho + "_SCIM003-" + (StrZero(Year(ddatabase),4)+'-'+StrZero(Month(ddatabase),2)+'-'+StrZero(Day(ddatabase),2)) +  '.log'
			
			If cErro != "" .and. !lAuto
			
				nOpcao := Aviso("Erro Importação", cErro, { "Gravar", "Sair" }, 3)
			
				If nOpcao == 1
				
					MEMOWRITE( cFileLog ,cErro ) // Grava log na pasta c:\temp
				
					If !lAuto
					
						cMsg := cFileLog 
						Aviso("Log gerado na pasta", cMsg, { "OK" }, 1)
						
					EndIf
					
				EndIf
			
			EndIf
		
		Else
			Aviso("Integração finalizada", cLogExec , {"OK"}, 3)	
		EndIf
	
		If !lAuto
			oProcess:SaveLog( "Fim da Execucao" )
		EndIf
		
	EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±ÄÄ¿±±
±±³Funcao    ³ M003LEARQ³ Autor ³ MAIA			     ³ Data ³ 19/09/2014  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ±±
±±³Descricao ³ Funcao para ler o Arquivo CSV  e gravar na area temporaria ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Sintaxe   ³ M003LEARQ(cCaminho)                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Parametros³ cCaminho = Caminho de origem do Arquivo                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³ Uso      ³ EspecIfico Cliente Sport Club Internacional   			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function M003LEARQ( cCaminho, cArquivo )

	Local cFluxo	:= ""
	Local cCcusto	:= ""
	Local cDia 	    := ""
	Local cMes 	    := ""
	Local cAno 	    := ""
	Local cHisto	:= ""
	Local cCaixa	:= ""
	Local cBuff     := ""
	Local cMsg      := ""
	Local cErro		:= ""
	Local cStatus   := ""
	Local nPagRec   := 0
	Local nValor	:= 0
	Local nLinArq   := 0
	Local nTamFile  := 0        
	Local nBtLidos  := 0   
	Local nHdl		:= 0
	Local nLinOK	:= 0  
	Local nLinErro	:= 0
	Local aFina100  := {}
	Local lOk       := .F.
	Local dDtaEmi	:= dDatabase                                            
	
	Private nHdl    := fOpen(cArquivo)

	If nHdl == -1
	
		If !lAuto
		
			cMsg := "O arquivo de nome "+cArquivo+" não pode ser aberto." +CRLF
			cMsg += "Verifique os parâmetros."
			Aviso("Arquivo Inválido", cMsg, {"OK" }, 1)
			Return
			
		EndIf
		
	EndIf

	nTamFile := fSeek(nHdl,0,2)
	fSeek(nHdl,0,0)
	
	nTamLin  := TAM_LIN_TXT
	cBuff	 := Space(nTamLin) // Variavel para criacao da linha do registro para leitura
	nBtLidos := FREAD(nHdl,@cBuff,nTamLin) // Leitura da primeira linha do arquivo texto

	While nBtLidos >= nTamLin

		cDia 	:= Substr(cBuff, P_DTAEMI,02)
		cMes 	:= Substr(cBuff, P_DTAEMI+2,02)
		cAno 	:= Substr(cBuff, P_DTAEMI+4,02)
		dDtaEmi := CtoD(cDia + "/" + cMes + "/" + cAno)    // CToD("02/16/05")	  
		cFluxo  := Trim(Substr(cBuff, P_FLUXO ,25))	
		cCaixa  := Trim(Substr(cBuff, P_CAIXA ,3))  // Codigo do Banco	
		cCcusto := Trim(Substr(cBuff, P_CCUSTO,25))
		cHisto  := Trim(Substr(cBuff, P_HISTO ,100))
		nPagRec := Val( Substr(cBuff, P_PAGREC,1))	
		nValor  := Val( Substr(cBuff, P_VALOR ,17))
	
		nLinArq := nLinArq + 1
	
		If dDtaEmi == CtoD("  /  /  ")
		
			aAdd( aLogerro,{ cArquivo,nLinArq, "A Data emissão "+cValToChar(dDtaEmi)+" não existe no arquivo !" })
			lOk := .F.
			
		EndIf
	
		If nValor == 0
		
			aAdd( aLogerro, { cArquivo,nLinArq,"O valor  "+cValToChar(nValor)+" esta zerado no arquivo !" })
			lOk := .F.
			
		EndIf
	
		If nPagRec != 1 .And. nPagRec != 2//   1 = A Receber 2 = A Pagar
		
			aAdd( aLogerro, {	cArquivo,nLinArq,"O Movimento  "+cvaltochar(nPagRec) + " Não é (1 = A Receber ou 2 = A Pagar) no arquivo !" })
			lOk := .F.
			
		EndIf
		
		If Empty(cFluxo)
		
			aAdd(aLogerro, { cArquivo,nLinArq,"O Caixa  "+cCaixa+" esta em branco no arquivo !" })
			lOk := .F.
			
		Else
	
			dbselectarea("SED")
			dbsetorder(1)
			If dbseek(xFilial("SED")+cFluxo)
				lOk := .T.
			Else
			
				aAdd( aLogerro, {	cArquivo,nLinArq,"Natureza "+cFluxo+" nao existe no cadastro de Naturezas(SED)!" })
				lOk := .F.
				
			EndIf
		
			If Empty(cCaixa)
			
				aAdd(aLogerro, { cArquivo,nLinArq,"O Caixa  "+cCaixa+" esta em branco no arquivo !" })
				lOk := .F.
				
			ElseIf lOk
			
				dbselectarea("SA6")
				dbsetorder(1)
				If !dbseek(xFilial("SA6")+cCaixa)
				
					aAdd( aLogerro, {	cArquivo,nLinArq,"O Banco "+cCaixa+" não existe no Cadastro de Bancos(SA6)!" })
					lOk := .F.
					
				Else
				
					cAgencia := SA6->A6_AGENCIA
					cNumCon  := SA6->A6_NUMCON

					If nPagRec == 2  // 2 = A Pagar
					
				   		aFina100 := {}
				   	
					   	aAdd( aFina100, {"E5_FILIAL" , xFilial("SE5") ,Nil} )
						aAdd( aFina100, {"E5_DATA"   , dDtaEmi        ,Nil} )
						aAdd( aFina100, {"E5_MOEDA"  , "M1"			  ,Nil} )
						aAdd( aFina100, {"E5_VALOR"  , nValor         ,Nil} )
						aAdd( aFina100, {"E5_NATUREZ", cFluxo         ,Nil} )
						aAdd( aFina100, {"E5_BANCO"  , cCaixa         ,Nil} )
						aAdd( aFina100, {"E5_AGENCIA", cAgencia       ,Nil} )
						aAdd( aFina100, {"E5_CONTA"  , cNumCon        ,Nil} )
						aAdd( aFina100, {"E5_CCCTB"  , cCcusto        ,Nil} )
						aAdd( aFina100, {"E5_HISTOR" , cHisto         ,Nil} ) 

						lMsErroAuto := .F.
						MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFina100,3)  
					
						If lMsErroAuto
						
							cArqlog := "SCIM003-2.LOG"
							cErro := CRLF + MostraErro(cCaminho, cArqlog)
							aAdd( aLogerro, { cArquivo,nLinArq,cErro} )		
							nLinErro++
							
						Else
						
							lOk := .T.
							nLinOK++
						
						EndIf
					
					ElseIf nPagRec == 1  // 1 = A Receber
					
						aFina100 := {}
					
					   	aAdd( aFina100, {"E5_FILIAL" , xFilial("SE5") ,Nil} )
						aAdd( aFina100, {"E5_DATA"   , dDtaEmi        ,Nil} )
						aAdd( aFina100, {"E5_MOEDA"  , "M1"			  ,Nil} )
						aAdd( aFina100, {"E5_VALOR"  , nValor         ,Nil} )
						aAdd( aFina100, {"E5_NATUREZ", cFluxo         ,Nil} )
						aAdd( aFina100, {"E5_BANCO"  , cCaixa         ,Nil} )
						aAdd( aFina100, {"E5_AGENCIA", cAgencia       ,Nil} )
						aAdd( aFina100, {"E5_CONTA"  , cNumCon        ,Nil} )
						aAdd( aFina100, {"E5_CCCTB"  , cCcusto        ,Nil} )
						aAdd( aFina100, {"E5_HISTOR" , cHisto         ,Nil} )					
				   					              					
						lMsErroAuto := .F.
						MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFina100,4)
					
						If lMsErroAuto
							
							cArqlog := "SCIM003-1.LOG"
							cErro := CRLF + MostraErro(cCaminho, cArqlog)
							aAdd( aLogerro, { cArquivo,nLinArq,cErro} ) 
							nLinErro++
							
						Else
						
							lOk := .T.
							nLinOK++
							
						EndIf
					
					EndIf
				
				EndIf
			
			EndIf
		
		EndIf
	
		nBtLidos := FREAD(nHdl,@cBuff,nTamLin) // Leitura da proxima linha do arquivo texto
		dbSkip()
		
	EndDo

	If lOk 
		cStatus := "Linhas processadas com sucesso: "+cValToChar(nLinOK)+CRLF
		cStatus += "Linhas processadas com erro: "+cValToChar(nLinErro)+CRLF
		cStatus += "Arquivo integrado: "+cArquivo+CRLF
	EndIf

	// Fecha o arquivo 
	fClose( nHdl )

Return(cStatus)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ RENOMARQ ³ Autor ³ Denis Rodrigues       ³ Data ³12/05/2014|±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ renomeia e move os arquivos apos integracao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ RENOMARQ( lExp1,cExp1,cExp2,cExp3 )                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lExp1 = Booleano que indica se o arquivo esta OK           ³±±
±±³          ³ cExp1 = Nome do arquivo                                    ³±±
±±³          ³ cExp2 = Diretorio de Destino do Arquivo                    ³±±
±±³          ³ cExp3 = Diretorio de Origem do Arquivo                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array com a mensagem                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ EspecIfico Cliente Sport Club Internacional                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function RENOMARQ( lOk, cArq, lAuto, cDirArq, cDir )

	Local cFileRe	:= ""
	Local cFileOr	:= ""
	Local aRet		:= {Nil, Nil}
	Local cMsg		:= ""
	Local cExt		:= IIf( lOk, "ok", "err" )
	Local cErro		:= "0"
	Local nUltDig	:= 0

	cFileOr := SubStr( cArq, ( RAt( "\", cArq )+1 ) )
	cFileRe := Left( cFileOr, RAt( ".",cFileOr ) ) + cExt
	
	nUltDig := IIf( lOk,Len( cFileRe ),( Len( cFileRe )-1 ) )

	While .T.
	
		If File( cDirArq+cFileRe )
		
			cErro	:= Soma1( cErro )
			cFileRe:= SubStr( cFileRe, 1, nUltDig ) + cErro
			
		Else
			Exit
		EndIf
		
	EndDo

	//Copia o arquivo para pasta definida no parametro
	If	Empty( cDirArq )
		cDirArq := cDir
	EndIf

	If Right( cDirArq,1 )  != "\"
		cDirArq := cDirArq + "\"
	EndIf

	If	__CopyFile( cArq , cDirArq + cFileRe )
	
		cMsg 	:= "Arquivo movido para o diretório: "  + cDirArq + CRLF
		cMsg 	+= "Nome do arquivo alterado para: " + cFileRe + CRLF
		aRet[1] := .T.
		aRet[2] := cMsg
		
		//Apaga o arquivo
		fErase( cArq )
		
	Else
	
		cMsg 	:= " Não foi possível copiar arquivo: "  + cFileRe + CRLF
		cMsg 	+= " Verifique o diretório de arquivamento."
		aRet[1] := .F.
		aRet[2] := cMsg
		
	EndIf

Return( aRet )

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VisualSX6 ³ Autor ³ Jeferson Dambros      ³ Data ³ Mar/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ±±
±±³Descricao ³ Visualizar os parametros da rotina.                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function VisualSX6( aMvParam )

	Local oDlgSX6
	Local oLbSx6
	Local oTBtCancel
	Local bCancel
	Local nInd	:= 0
	Local lSeek	:= .F.
	Local aLbSx6:= {}
	
	dbSelectArea("SX6")
	dbSetOrder(1)

	For nInd := 1 To Len(aMvParam)
		
		If	dbSeek( cFilAnt + aMvParam[nInd] )
			lSeek := .T.
		Else
		
			If	dbSeek( "  " + aMvParam[nInd] )
				lSeek := .T.
			EndIf
			
		EndIf
		
		aAdd( aLbSx6, Array(7) )
		
		If	lSeek
		
			//Denis - Compatibilização Lobo Guara
			/*aLbSx6[Len(aLbSx6)][1] := AllTrim(SX6->X6_VAR)
			aLbSx6[Len(aLbSx6)][2] := AllTrim(SX6->X6_TIPO)
			aLbSx6[Len(aLbSx6)][3] := AllTrim(SX6->X6_CONTEUD)
			aLbSx6[Len(aLbSx6)][4] := AllTrim(SX6->X6_DESCRIC)
			aLbSx6[Len(aLbSx6)][5] := AllTrim(SX6->X6_DESC1)
			aLbSx6[Len(aLbSx6)][6] := AllTrim(SX6->X6_DESC2)
			aLbSx6[Len(aLbSx6)][7] := ""*/
			
		Else
		
			aLbSx6[Len(aLbSx6)][1] := aMvParam[nInd]
			aLbSx6[Len(aLbSx6)][2] := ""
			aLbSx6[Len(aLbSx6)][3] := "Não Preenchido"
			aLbSx6[Len(aLbSx6)][4] := ""
			aLbSx6[Len(aLbSx6)][5] := ""
			aLbSx6[Len(aLbSx6)][6] := ""
			aLbSx6[Len(aLbSx6)][7] := ""
			
		EndIf
		
	Next nInd

	oDlgSX6 := MSDialog():New( 000, 000, 500, 1000, "Parametros Ambiente" ,,,,,,,,,.T.,,, )
	
	oLbSx6 := TWBrowse():New( 000, 000, 500, 230,,,, oDlgSX6,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

	oLbSx6:aHeaders  := {	"Parâmetro",;
							"Tipo",;
							"Conteúdo",;
							"Descrição",;
							"Descrição",;
							"Descrição",;
							"" }

	oLbSx6:aColSizes := { 30, 50, 50, 50, 50, 50, 5}
	
	oLbSx6:SetArray( aLbSx6 )
	
	oLbSx6:bLine := { || aLbSx6[oLbSx6:nAt] }
	
	oLbSx6:Refresh()
	
	bCancel := { || oDlgSX6:End() }
	
	oTBtCancel := TButton():New( 235, 440, "Sair",oDlgSX6, bCancel ,40,10,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	oDlgSX6:Activate( {||.T.} , , ,.T., , , )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Original  ³ CriaSx1  ³ Autor ³ Fabio Briddi          ³ Data ³ Mar/2014 |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄ±±
±±³Funcao    ³ CriaSx1  ³ Autor ³ Denis Rodrigues       ³ Data ³30/04/2014|±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ±±
±±³Descricao ³ Cria o Grupo de Perguntas                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±³ Uso      ³ EspecIfico Cliente Sport Club Internacional                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function CriaSx1(cPerg)

	Local aP	 := {}
	Local aHelp	 := {}
	Local nI	 := 0
	Local cSeq	 := ""
	Local cMvCh	 := ""
	Local cMvPar := ""

	/*
	Parametros da funcao padrao
	---------------------------
	PutSX1(cGrupo,;
	cOrdem,;
	cPergunt,cPerSpa,cPerEng,;
	cVar,;
	cTipo,;
	nTamanho,;
	nDecimal,;
	nPresel,;
	cGSC,;
	cValid,;
	cF3,;
	cGrpSxg,;
	cPyme,;
	cVar01,;
	cDef01,cDefSpa1,cDefEng1,;
	cCnt01,;
	cDef02,cDefSpa2,cDefEng2,;
	cDef03,cDefSpa3,cDefEng3,;
	cDef04,cDefSpa4,cDefEng4,;
	cDef05,cDefSpa5,cDefEng5,;
	aHelpPor,aHelpEng,aHelpSpa,;
	cHelp)
	*/
	
	//			Texto Pergunta	         Tipo Tam  Dec 	G=get ou C=Choice  	Val 	F3	 Def01 	 Def02 	 Def03    Def04   Def05
	aAdd(aP,{ "Caminho do Arquivo ?"    ,"C", 60,	0,	"G"               ,	"",	 "DIR",	    "",		"",		 "",	   "",	""       })
	aAdd(aP,{ "Exibir relatorio de Log?","N", 01,	0,	"C"               ,	"",	 	"",	  "Ok",	"Erro",	"Todos",	"Nao",	"", 	4})
	
	//           012345678912345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//                    1         2         3         4         5         6         7         8         9        10        11        12
	aAdd(aHelp,{"Informe a pasta ou apenas o arquivo,","para importacao."                          ,"Ex.: c:\arquivos\ ou c:\arquivos\importacao.txt"})
	aAdd(aHelp,{"Ao final da importacao, exibir rela","torio conforme opcao.", "Ok = Somente os registros ok", "Erro = Somente erro", "Todos = Erro + Ok", "Nao = Nao exibir relatorio"})
	
	For nI := 1 To Len(aP)
		
		cSeq	:= StrZero(nI,2,0)
		cMvPar	:= "mv_par"+cSeq
		cMvCh	:= "mv_ch"+IIf(nI<=9,Chr(nI+48),Chr(nI+87))
		/*
		PutSx1(cPerg,;
		cSeq,;
		aP[nI,1],aP[nI,1],aP[nI,1],;
		cMvCh,;
		aP[nI,2],;
		aP[nI,3],;
		aP[nI,4],;
		1,;
		aP[nI,5],;
		aP[nI,6],;
		aP[nI,7],;
		"",;
		"",;
		cMvPar,;
		aP[nI,8],aP[nI,8],aP[nI,8],;
		"",;
		aP[nI,9],aP[nI,9],aP[nI,9],;
		aP[nI,10],aP[nI,10],aP[nI,10],;
		aP[nI,11],aP[nI,11],aP[nI,11],;
		aP[nI,12],aP[nI,12],aP[nI,12],;
		aHelp[nI],;
		{},;
		{},;
		"")
		*/
	Next nI

Return()

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GravaLog  ³ Autor ³ MAIA				    ³ Data ³ Set/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ±±
±±³Descricao ³ Gravar Log de processamento.                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±*/
Static Function GravaLog( cArq)

	Local cFileRe := ""
	Local cFileOr := ""
	Local cExt	  := "err"
	Local cErro	  := "0"
	Local nUltDig := 0

	cFileOr := cArq
	cFileRe := Left( cFileOr, RAt(".",cFileOr)) + cExt

	nHd2 := fOpen( cFileRe, 0 )
	
	If nHd2 == -1
		nHd2 := fCreate( cFileRe , 0 )
	EndIf

	FSeek( nHd2, 0, FS_END) // Posiciona no fim do arquivo

	/* gera o arquivo de log */
	cErro:= ""

	For nInd := 1 to Len(aLogerro)
	
		cErro+= "Arquivo " + aLogerro[nInd][1] + " Linha " + cvaltochar(aLogerro[nInd][2]) + " Erro " + aLogerro[nInd][3] + CRLF
		
		aAdd(aLogFin, {aLogerro[nInd][1],;
					   aLogerro[nInd][2],;
					   aLogerro[nInd][3] })
							
	Next nInd

	fWrite( nHd2 , cErro + CRLF )
	
	fClose( nHd2 )// Fecha o arquivo log
	
	aLogerro  := {}

Return(cFileRe)
