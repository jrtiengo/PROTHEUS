#Include "Totvs.ch"
#include "fileio.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � SCIM002  � Autor � MAIA			        � Data �25/09/2014|��
�������������������������������������������������������������������������Ď��
���Descricao � Rotina de integra��o para integra��o com Sistema Society   ���
���            (CWI) com o Movimento Financeiro via Web Service.     	  ���
�������������������������������������������������������������������������Ď��
���Sintaxe   � U_SCIM002(aParam)                                          ���
�������������������������������������������������������������������������Ď��
���Parametros� aParam = Indica se a rotina e chamada pelo schedule        ���
���          �                                                            ���
�������������������������������������������������������������������������Ď��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ď��
��� Uso      � Especifico Cliente Sport Club Internacional                ���
�������������������������������������������������������������������������Ď��
���                          ULTIMAS ALTERACOES                           ���
�������������������������������������������������������������������������Ď��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ď��
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function SCIM002(aParam)

Local oProcess
Local cCadastro   := "Integra��o com Sistema Society (CWI)"
Local cDescRot	   := ""
Local cPerg  	   := "SCIM002"
Local cCaminho    := GetMV("ES_LGSCI02")   // "\_integracoes"


Local aInfoCustom := {}
Local aMvParam	   := {}
Local aTabelas	   := {"SE5"}
Local bProcess 	:= {||}
Local nQTdDias    := 0
Local dDatafin    := MsDate()
Local dDataini 	:= dDatafin - nQtdDias

Private lAuto		  	:= ( ValType(aParam) = "A" )
Private lMsErroAuto 	:= .F.
Private aLogerro		:= {}
Private aLogFin   	:= {}
Private aBcoBol      := {}

Private aDadosBc  := StrTokArr( AllTrim( GetMV("ES_BCOSOCI" ) ),"|", .T. )


//aDadosBc[1] // EE_CODIGO (Codigo Banco)
//aDadosBc[2] // EE_AGENCIA (Agencia)
//aDadosBc[3] // EE_CONTA (Conta)
//aDadosBc[4] // EE_SUBCTA (Sub Conta)

//������������������������������������������Ŀ
//�NAO ALTERAR A ORDEM DA SINTAXE ABAIXO!!!! �
//��������������������������������������������
aAdd( aMvParam, "ES_DIAM002" ) // Indica a Quantidade de dias retroativos a Data Base para consulta ao WebService Society

If lAuto// Chamada via Schedule
	
	If RpcSetEnv(aParam[1],aParam[2],,,"FIN","SCIM002",aTabelas,,,,)
		
		nQTdDias    := GetMV(aMvParam[1])
		dDatafin    := date()
		dDataini 	:= dDatafin - nQtdDias
		
		BatchProcess(	cCadastro, cCadastro, "SCIM002", { || M002EXEC(oProcess, cCaminho, dDataini, dDatafin, aMvParam) }, { || .F. }  )
		
		RpcClearEnv()
		
	EndIf
	
Else
	
	cPerg := PadR("SCIM002", 10 /*TamSx3("X1_GRUPO")[1]*/ , "")
	
	CriaSx1(cPerg)
	
	Pergunte(cPerg,.F.)
	
	aAdd( aInfoCustom, { "Parametros Ambiente",	{ || VisualSX6( aMvParam ) }, 				"PROCESSA"	})
	aAdd( aInfoCustom, { "Historico",          	{ ||                       }, 				"PROCESSA"	})
	aAdd( aInfoCustom, { "Cancelar",           	{ |oPanelCenter| oPanelCenter:oWnd:End() }, "CANCEL"	})
	
	bProcess := {|oProcess| M002EXEC(oProcess, cCaminho, MV_PAR01, MV_PAR02, aMvParam) }
	
	cDescRot := " Este programa tem o objetivo, integra��o com Sistema"
	cDescRot += " Society (CWI) com o Movimento Financeiro via Web Service"
	
	oProcess := tNewProcess():New("SCIM002",cCadastro,bProcess,cDescRot,cPerg,aInfoCustom, .T.,5, "", .T. )
	
EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � M002EXEC � Autor � MAIA				   � Data � 19/09/2014|��
�������������������������������������������������������������������������Ď��
���Descricao � Rotina de processamento dos dados para a integracao Synchro���
�������������������������������������������������������������������������Ď��
���Sintaxe   � M002EXEC( oExp1, cExp1, cExp2, lExp1)                      ���
�������������������������������������������������������������������������Ď��
���Parametros� oProcess = Objeto da regua de processamento e log.         ���
���          � cCaminho = Caminho de origem do Arquivo TXT.               ���
���          � cDirGrava = Diretorio de gravacao do arquivo depois de lido���
���          � lAuto = indica se a rotina foi chamado pelo schedule ou    ���
���          � menu                                                       ���
�������������������������������������������������������������������������Ď��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ď��
��� Uso      � Especifico Cliente Sport Club Internacional                ���
�������������������������������������������������������������������������Ď��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function M002EXEC( oProcess,cCamLog, dDataini, dDatafin, aMvParam )

Local cDataini := ""
Local cDatafin := ""
Local cArquivo := ""
Local cArqlog  := ""
Local cErro    := ""
Local cFileLog := ""
Local cMsg     := ""
Local cLog		:= ""
Local lOK      := .F.
Local nInd     := 0

cCamLog := AllTrim(cCamLog)

If !lAuto
	oProcess:SaveLog("Inicio da Execucao")
	oProcess:SetRegua1( 0 )
EndIf

If Right(cCamlog,1) == "\"
	cArquivo := "SCIM002-" + (StrZero(Year(ddatabase),4)+'-'+StrZero(Month(ddatabase),2)+'-'+StrZero(Day(ddatabase),2)) +  '.log'
Else
	cArquivo := "\SCIM002-" + (StrZero(Year(ddatabase),4)+'-'+StrZero(Month(ddatabase),2)+'-'+StrZero(Day(ddatabase),2)) +  '.log'
EndIf

If lAuto// Chamada via Schedule
	
	cDataini := "20" + substr(dtoc(dDataini), 7, 2) + "-" + substr(dtoc(dDataini), 4, 2) + "-" + substr(dtoc(dDataini), 1, 2) + "T00:00:00"
	cDatafin := "20" + substr(dtoc(dDatafin), 7, 2) + "-" + substr(dtoc(dDatafin), 4, 2) + "-" + substr(dtoc(dDatafin), 1, 2) + "T23:59:59"
	
Else
	
	cDataini := substr(dtoc(dDataini), 7, 4) + "-" + substr(dtoc(dDataini), 4, 2) + "-" + substr(dtoc(dDataini), 1, 2) + "T00:00:00"
	cDatafin := substr(dtoc(dDatafin), 7, 4) + "-" + substr(dtoc(dDatafin), 4, 2) + "-" + substr(dtoc(dDatafin), 1, 2) + "T23:59:59"
	
EndIf

lOK := M002IMPWS( cDataini, cDatafin, cCamLog, "SCIM002.log",oProcess )// Funcao para ler o Arquivo TXT e gravar na area temporaria

If Len(aLogerro) > 0 // houve erros
	cArqlog := GravaLog(cArquivo)
EndIf

// gera o log final em tela monstrando ao usuario
If Len(aLogfin) > 0
	
	cErro:= ""
	
	For nInd := 1 To Len(aLogfin)
		
		cLog  := "Arquivo de log: " 		 + aLogfin[nInd][1]+CRLF
		cLog  += "Registros processados: "+ cValToChar( aLogfin[nInd][4] )
		if nInd < 50 // monstra apenas 50 primeiros erros
			cErro += "Linha: " 				    + cValToChar( aLogfin[nInd][2] ) + CRLF
			cErro += "Erro: "  					 + aLogfin[nInd][3] + CRLF
		endif
		
	Next nInd
	
	cErro := cLog + CRLF + cErro
	
	cFileLog:= cCamLog + cArquivo
	
	If cErro != "" .and. !lAuto
		
		nOpcao := Aviso("Erro Importa��o", cErro, { "Gravar", "Sair" }, 3)
		
		If nOpcao == 1
			
			MEMOWRITE( cFileLog ,cErro ) // Grava log na pasta c:\temp
			
			If !lAuto
				
				cMsg := cFileLog
				Aviso("Log gerado na pasta", cMsg, {"OK" }, 1)
				
			EndIf
			
		EndIf
		
	EndIf
	
EndIf

If lOK
	
	cMsg := "Integra��o realizada."
	Aviso("Integra��o com Sistema Society", cMsg, {"OK" }, 1)
	
EndIf

If !lAuto
	oProcess:SaveLog( "Fim da Execucao" )
EndIf

Return

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � M002IMPWS� Autor � MAIA			     � Data � 25/09/2014  ��
�������������������������������������������������������������������������Ď��
���Descricao � Funcao para Importar o Webservice 						  ���
�������������������������������������������������������������������������Ď��
���Sintaxe   � M002IMPWS(cCaminho)                                        ���
�������������������������������������������������������������������������Ď��
���Parametros� cCaminho = Caminho de origem do Arquivo                    ���
���          �                                                            ���
�������������������������������������������������������������������������Ď��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ď��
��� Uso      � Especifico Cliente Sport Club Internacional   			  ���
�������������������������������������������������������������������������Ď��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function M002IMPWS( ctDataInicial, ctDataFinal, cCamLog, cArquivo,oProcess )

Local lOK 		 := .F.
Local nX        := 0
Local nValor 	 := 0
Local cCaixa  	 := ""
Local cCtaBil   := ""
Local cConta 	 := ""
Local cData	    := ""
Local cDtaLan	 := ""
Local cDescricao:= ""
Local cTimeStamp:= ""
Local cTipoMov  := ""
Local cNatureza := ""
Local cDia 		 := ""
Local cMes 		 := ""
Local cAno 		 := ""
Local dData 	 := MsDate()
Local dDtaLan	 := MsDate()
Local aFina100   := {}
Local cError	 := ""
Local cWarning   := ""


Private oXML	:= Nil
Private cXml	:= ""

oSociety_ws_cwi := WSsociety_ws_139_totvs():New()
oSociety_ws_cwi:cttDataInicial        := ctDataInicial
oSociety_ws_cwi:cttDataFinal          := ctDataFinal
oSociety_ws_cwi:ctcTokenParceiro      := "alZTW1xFSW8="  // alZTW1xFSW8=
oSociety_ws_cwi:ltlBuscarJaImportados := .T.     // trazer os ja importados

oSociety_ws_cwi:ConsultaMovimentoRealizado( oSociety_ws_cwi:ctcTokenParceiro, oSociety_ws_cwi:cttDataInicial, oSociety_ws_cwi:cttDataFinal, oSociety_ws_cwi:ltlBuscarJaImportados )

WSDLDbgLevel(1)
cXml := oSociety_ws_cwi:CRESULT

oXML := XmlParser( cXml , "_", @cError, @cWarning )
If (oXml == NIL )
	MsgStop("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
	Return
Endif


If !lAuto
	oProcess:IncRegua1("Integrando... ")
EndIf

If Type("oXML:_VFPDATASET:_CRSRESPOSTA") <> "U"    // "OK"
	
	lNatur := Type("oXML:_VFPDATASET:_CRSRESPOSTA:_NATUREZA")<>"U"
	lData  := Type("oXML:_VFPDATASET:_CRSRESPOSTA:_DATA")<>"U"
	lDtaLan:= Type("oXML:_VFPDATASET:_CRSRESPOSTA:_DATALANCAMENTO")<>"U"
	lDesc  := Type("oXML:_VFPDATASET:_CRSRESPOSTA:_DESCRICAO")<>"U"
	lTime  := Type("oXML:_VFPDATASET:_CRSRESPOSTA:_TIMESTAMP")<>"U"
	lTipo  := Type("oXML:_VFPDATASET:_CRSRESPOSTA:_TIPOMOVIMENTO")<>"U"
	lValor := Type("oXML:_VFPDATASET:_CRSRESPOSTA:_VALOR")<>"U"
	
	For nX := 1 To Len(oXML:_VFPDATASET:_CRSRESPOSTA)
		
		
		lOK := .T.
		
		cCaixa :=""
		
		cNatureza := ""
		
		//https://devforum.totvs.com.br/369-sonarqube-validando-type
		If lNatur
			//If Type("oXML:_VFPDATASET:_CRSRESPOSTA["+cValToChar(nX)+"]:_NATUREZA:TEXT")<>"U"
			cNatureza := oXML:_VFPDATASET:_CRSRESPOSTA[nX]:_NATUREZA:TEXT
		EndIf
		
		cConta := ""
		
		cData := ""
		If lData
			//If Type("oXML:_VFPDATASET:_CRSRESPOSTA["+cValToChar(nX)+"]:_DATA:TEXT")<>"U"
			cData := oXML:_VFPDATASET:_CRSRESPOSTA[nX]:_DATA:TEXT // A Data vem desta forma 2014-01-01T13:56:59
		EndIf
		
		cDtaLan := ""
		If lDtaLan
			//If Type("oXML:_VFPDATASET:_CRSRESPOSTA["+cValToChar(nX)+"]:_DATALANCAMENTO:TEXT")<>"U"
			cDtaLan := oXML:_VFPDATASET:_CRSRESPOSTA[nX]:_DATALANCAMENTO:TEXT
		EndIf
		
		cDescricao := ""
		If lDesc
			//If Type("oXML:_VFPDATASET:_CRSRESPOSTA["+cValToChar(nX)+"]:_DESCRICAO:TEXT")<>"U"
			
			cDescricao := oXML:_VFPDATASET:_CRSRESPOSTA[nX]:_DESCRICAO:TEXT
			
			If !lAuto
				oProcess:IncRegua2( "Movimento: "+AllTrim( cDescricao ) )
			EndIf
			
		EndIf
		
		cTimeStamp := ""
		If lTime
			//If Type("oXML:_VFPDATASET:_CRSRESPOSTA["+cValToChar(nX)+"]:_TIMESTAMP:TEXT")<>"U"
			cTimeStamp := oXML:_VFPDATASET:_CRSRESPOSTA[nX]:_TIMESTAMP:TEXT
		EndIf
		
		cTipoMov := ""
		If lTipo
			//If Type("oXML:_VFPDATASET:_CRSRESPOSTA["+cValToChar(nX)+"]:_TIPOMOVIMENTO:TEXT")<>"U"
			cTIPOMOV := oXML:_VFPDATASET:_CRSRESPOSTA[nX]:_TIPOMOVIMENTO:TEXT  // C ou D
		EndIf
		
		nValor := 0
		If lValor
			//If Type("oXML:_VFPDATASET:_CRSRESPOSTA["+cValToChar(nX)+"]:_VALOR:TEXT")<>"U"
			nValor := Val(oXML:_VFPDATASET:_CRSRESPOSTA[nX]:_VALOR:TEXT)
		EndIf
		
		cDia  := SubStr( cData, 9, 2 )// A Data vem desta forma 2014-01-01T13:56:59
		cMes  := SubStr( cData, 6, 2 )
		cAno  := SubStr( cData, 3, 2 )
		dData := CtoD( cDia +  "/" + cMes + "/" + cAno )
		
		If dData == CtoD("  /  /  ")
			
			aAdd( aLogerro, {cArquivo,nX,"A Data emiss�o "+cValToChar(dData)+" n�o existe.", 1 } )
			lOK := .F.
			
		EndIf
		
		cDia := SubStr( cDtaLan, 9, 2 )// 2014-01-01T13:56:59
		cMes := SubStr( cDtaLan, 6, 2 )
		cAno := SubStr( cDtaLan, 3, 2 )
		dDtaLan := CtoD( cDia +  "/" + cMes + "/" + cAno )
		
		If Empty( dDtaLan )// == ctod("  /  /  ")
			
			aAdd(aLogerro, {cArquivo,nX,"A Data de Lan�amento "+cValToChar(dDtaLan)+" n�o existe.",1 })
			lok := .F.
			
		EndIf
		
		If nValor == 0
			
			aAdd(aLogerro, {cArquivo,nX,"O valor  "+cValToChar(nValor)+" esta zerado.",1 })
			lok := .F.
			
		EndIf
		
		If cTipoMov != "C" .And. cTipoMov != "D"//   C = A Receber D = A Pagar
			
			aAdd(aLogerro, {cArquivo,nX,"O Movimento  "+cValToChar(cTipoMov) + " N�o e (C = A Receber D = A Pagar).",1 })
			lok := .F.
			
		EndIf
		
		//aBcoBol[01] := aDadosBc[1]// EE_CODIGO (Codigo Banco)
		//aBcoBol[02] := aDadosBc[2]// EE_AGENCIA (Agencia)
		//aBcoBol[03] := aDadosBc[3]// EE_CONTA (Conta)
		//aBcoBol[04] := aDadosBc[4]// EE_SUBCTA (Sub Conta)
		
		cCaixa   := aDadosBc[1]
		cAgencia := aDadosBc[2]
		cConta   := aDadosBc[3]
		
		dbSelectArea("SED")
		dbSetOrder(1)
		If dbseek(xFilial("SED")+cNatureza)
			lok := .T.
		Else
			
			aAdd( aLogerro, {cArquivo,nX,"Natureza "+cNatureza+" n�o existe no cadastro de Naturezas(SED)!", 1 } )
			lok := .F.
			
		EndIf
		
		dbSelectArea("SA6")
		dbSetOrder(1)
		If !dbseek(xFilial("SA6")+cCaixa)
			
			aAdd( aLogerro, {cArquivo,nX,"O Banco "+cCaixa+" n�o existe no cadastro de Bancos(SA6)", 1 } )
			lok := .F.
			'
		Endif
		
		
		If Empty(cCaixa)
			aAdd( aLogerro, {cArquivo,nX,"O Caixa  "+cCaixa+" esta em branco.",1 })
			lok := .F.
		Endif
		
		if 	lOK
			// cAgencia := SA6->A6_AGENCIA
			//	cNumCon  := SA6->A6_NUMCON
			
			If cTipoMov == "D"  // 2 = A Pagar
				
				aFina100 := {}
				aAdd( aFina100, {"E5_FILIAL"  , xFilial("SE5") ,Nil} )
				aAdd( aFina100, {"E5_DATA"    , dData	        ,Nil} )
				aAdd( aFina100, {"E5_MOEDA"   , "M1"			  ,Nil} )
				aAdd( aFina100, {"E5_VALOR"   , nValor         ,Nil} )
				aAdd( aFina100, {"E5_NATUREZ" , cNatureza      ,Nil} )
				aAdd( aFina100, {"E5_BANCO"   , cCaixa         ,Nil} )
				aAdd( aFina100, {"E5_AGENCIA" , cAgencia       ,Nil} )
				aAdd( aFina100, {"E5_CONTA"   , cConta         ,Nil} )
				aAdd( aFina100, {"E5_HISTOR"  , cDescricao     ,Nil} )
				
				lMsErroAuto := .F.
				MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFina100,3)
				
				If lMsErroAuto
					
					//cArquivolog := "SCIM002-2.LOG"
					cErro:= MostraErro(cCamLog,"")
					aAdd( aLogerro, {cArquivo,nX,cErro,1} )
					lOK := .F.
					
				Else
					lok := .T.
				EndIf
				
			ElseIf cTipoMov == "C"  // 1 = A Receber
				
				aFina100 := {}
				aAdd( aFina100, {"E5_FILIAL"  , xFilial("SE5") ,Nil} )
				aAdd( aFina100, {"E5_DATA"    , dData	        ,Nil} )
				aAdd( aFina100, {"E5_MOEDA"   , "M1"			  ,Nil} )
				aAdd( aFina100, {"E5_VALOR"   , nValor         ,Nil} )
				aAdd( aFina100, {"E5_NATUREZ" , cNatureza      ,Nil} )
				aAdd( aFina100, {"E5_BANCO"   , cCaixa         ,Nil} )
				aAdd( aFina100, {"E5_AGENCIA" , cAgencia       ,Nil} )
				aAdd( aFina100, {"E5_CONTA"   , cConta         ,Nil} )
				aAdd( aFina100, {"E5_HISTOR"  , cDescricao     ,Nil} )
				
				lMsErroAuto := .F.
				MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFina100,4)
				
				If lMsErroAuto
					
					//cArquivolog := "SCIM002-1.LOG"
					cErro:= MostraErro(cCamLog, "")
					aAdd( aLogerro, {cArquivo,nX,cErro,1} )
					lOK := .F.
					
				Else
					lOK := .T.
				EndIf
				
			EndIf
			
		EndIf
		
		
		
	Next nX
	
Else
	
	lOK := .F.
	cMsg := "O Web Service n�o retornou nenhum registro."
	Aviso("Integra��o com Sistema Society", cMsg, {"OK"}, 1)
	
	If !Empty( GETWSCERROR(1) )
		MsgAlert( GETWSCERROR(1),"Mensagem GetWSCERROR" )
	EndIf
	
EndIf

Return(lOK)

/*
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �VisualSX6 � Autor � Jeferson Dambros      � Data � Mar/2014 ���
�������������������������������������������������������������������������Ď��
���Descricao � Visualizar os parametros da rotina.                        ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Static Function VisualSX6( aMvParam )

Local oDlgSX6
Local oLbSx6
Local oTBtCancel
Local bCancel
Local nInd		:= 0
Local lSeek	   := .F.
Local aLbSx6   := {}

//dbSelectArea("SX6")
//dbSetOrder(1)
OpenSxs(,,,,,"SX6TRB","SX6",,.F.)
If Select("SX6TRB") > 0
	
	For nInd := 1 To Len(aMvParam)
		
		dbSelectArea('SX6TRB')
		SX6TRB->( dbSetOrder( 1 ) ) //ORDENA POR ALIAS
		SX6TRB->( dbGoTop(  ) )
		
		If SX6TRB->( dbSeek( cFilAnt + aMvParam[nInd] ) )
			
			lSeek := .T.
			
		Else
			
			If	SX6TRB->( dbSeek( "  " + aMvParam[nInd] ) )
				lSeek := .T.
			EndIf
			
		EndIf
		
		aAdd( aLbSx6, Array(7) )
		
		If	lSeek
			
			aLbSx6[Len(aLbSx6)][1] := AllTrim(SX6TRB->&('X6_VAR'))
			aLbSx6[Len(aLbSx6)][2] := AllTrim(SX6TRB->&('X6_TIPO'))
			aLbSx6[Len(aLbSx6)][3] := AllTrim(SX6TRB->&('X6_CONTEUD'))
			aLbSx6[Len(aLbSx6)][4] := AllTrim(SX6TRB->&('X6_DESCRIC'))
			aLbSx6[Len(aLbSx6)][5] := AllTrim(SX6TRB->&('X6_DESC1'))
			aLbSx6[Len(aLbSx6)][6] := AllTrim(SX6TRB->&('X6_DESC2'))
			aLbSx6[Len(aLbSx6)][7] := ""
		Else
			
			aLbSx6[Len(aLbSx6)][1] := aMvParam[nInd]
			aLbSx6[Len(aLbSx6)][2] := ""
			aLbSx6[Len(aLbSx6)][3] := "N�o Preenchido"
			aLbSx6[Len(aLbSx6)][4] := ""
			aLbSx6[Len(aLbSx6)][5] := ""
			aLbSx6[Len(aLbSx6)][6] := ""
			aLbSx6[Len(aLbSx6)][7] := ""
			
		EndIf
		
	Next nInd
	
	SX6TRB->( DbCloseArea() )
EndIf


oDlgSX6 := MSDialog():New( 000, 000, 500, 1000, "Parametros Ambiente" ,,,,,,,,,.T.,,, )

oLbSx6 := TWBrowse():New( 000, 000, 500, 230,,,, oDlgSX6,,,,,{||},,,,,,,.F.,,.T.,,.F.,,, )

oLbSx6:aHeaders  := {	"Par�metro",;
"Tipo",;
"Conte�do",;
"Descri��o",;
"Descri��o",;
"Descri��o",;
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
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Original  � CriaSx1  � Autor � Fabio Briddi        � Data � Mar/2014    ��
�������������������������������������������������������������������������Ď��
���Funcao    � CriaSx1  � Autor � Denis Rodrigues     � Data � 30/04/2014  ��
�������������������������������������������������������������������������Ď��
���Descricao � Cria o Grupo de Perguntas                                  ���
�������������������������������������������������������������������������Ď��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ď��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ď��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ď��
��� Uso      � Especifico Cliente Sport Club Internacional                ���
�������������������������������������������������������������������������Ď��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function CriaSx1(cPerg)

Local aP		:= {}
Local aHelp	:= {}
Local nI		:= 0
Local cSeq	:= ""
Local cMvCh	:= ""
Local cMvPar:= ""

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
aAdd(aP,{ "Data Inicial ?"  		 ,"D", 10,	0,	"G"               ,	"",	 	"",	    "",		"",		 "",	   "",	""       })
aAdd(aP,{ "Data Final ?" 	 		 ,"D", 10,	0,	"G"               ,	"",	 	"",	    "",		"",		 "",	   "",	""       })

//           012345678912345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
//                    1         2         3         4         5         6         7         8         9        10        11        12
aAdd(aHelp,{"Informe a Data Inicial do Periodo a ser importado ,","para importacao."                          ,"Ex.: 01/01/2014"})
aAdd(aHelp,{"Informe a Data Final	do Periodo a ser importado ,","para importacao."                          ,"Ex.: 05/01/2014"})

For nI := 1 To Len(aP)
	
	cSeq	:= StrZero(nI,2,0)
	cMvPar	:= "mv_par"+cSeq
	cMvCh	:= "mv_ch"+IIF(nI<=9,Chr(nI+48),Chr(nI+87))
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
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �GravaLog  � Autor � MAIA				    � Data � Set/2014 ���
�������������������������������������������������������������������������Ď��
���Descricao � Gravar Log de processamento.                               ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������*/
Static Function GravaLog( cArq)

Local cFileRe	:= ""
Local cFileOr	:= ""
Local cExt		:= "err"
Local cErro		:= ""
Local nLinPrc  := 0
Local nUltDig	:= 0

cFileOr := cArq
cFileRe := Left( cFileOr, RAt(".",cFileOr)) + cExt

nHd2 := fOpen( cFileRe, 0 )

If nHd2 == -1
	nHd2 := fCreate( cFileRe , 0 )
EndIf

FSeek( nHd2, 0, FS_END) // Posiciona no fim do arquivo

/* gera o arquivo de log */
For nInd := 1 To Len(aLogerro)
	
	if nInd < 50   // grava 50 primeiros erros apenas
		cErro   += "Arquivo de log: " + aLogerro[nInd][1] + CRLF
		cErro   += "Linha: " + cValToChar(aLogerro[nInd][2]) + CRLF
		cErro   += "Erro: "  + aLogerro[nInd][3] + CRLF
		nLinPrc += aLogerro[nInd][4]
		
		aAdd( aLogFin, {aLogerro[nInd][1],aLogerro[nInd][2],aLogerro[nInd][3],nLinPrc } )
	endif
	
Next nInd

fWrite( nHd2 , cErro + CRLF )

// Fecha o arquivo log
fClose( nHd2 )

aLogerro  := {}

Return(cFileRe)

static FUNCTION NoAcento(cString)
Local cChar  := ""
Local nX     := 0
Local nY     := 0
Local cVogal := "aeiouAEIOU"
Local cAgudo := "�����"+"�����"
Local cCircu := "�����"+"�����"
Local cTrema := "�����"+"�����"
Local cCrase := "�����"+"�����"
Local cTio   := "����"
Local cCecid := "��"
Local cMaior := "&lt;"
Local cMenor := "&gt;"

For nX:= 1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	IF cChar$cAgudo+cCircu+cTrema+cCecid+cTio+cCrase
		nY:= At(cChar,cAgudo)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCircu)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTrema)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cCrase)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr(cVogal,nY,1))
		EndIf
		nY:= At(cChar,cTio)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("aoAO",nY,1))
		EndIf
		nY:= At(cChar,cCecid)
		If nY > 0
			cString := StrTran(cString,cChar,SubStr("cC",nY,1))
		EndIf
	Endif
Next

If cMaior$ cString
	cString := strTran( cString, cMaior, "" )
EndIf
If cMenor$ cString
	cString := strTran( cString, cMenor, "" )
EndIf

cString := StrTran( cString, CRLF, " " )

For nX:=1 To Len(cString)
	cChar:=SubStr(cString, nX, 1)
	If (Asc(cChar) < 32 .Or. Asc(cChar) > 123) .and. !cChar $ '|'
		cString:=StrTran(cString,cChar,".")
	Endif
Next nX
Return cString



