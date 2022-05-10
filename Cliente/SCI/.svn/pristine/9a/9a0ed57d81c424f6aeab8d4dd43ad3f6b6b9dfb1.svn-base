#Include "Totvs.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ SCI99A   ³ Autor ³  Ednei Silva          ³ Data ³29/06/2017³±±
±±³Funcao    ³ SCIF010  ³ Autor ³  Ednei Silva          ³ Data ³29/06/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que envia o E-mail de Workflow na inclusao de PA    ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function SCIF010( nOpcao,oProcess )

Default nOpcao := 0


Do Case
	Case nOpcao == 0
		A040Inicio( M->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA) )
	Case nOpcao == 1
		A040Retorno( oProcess )
	Case nOpcao == 2
		A040TimeOut( oProcess )
EndCase

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A040INICIO³ Autor ³ Ednei Silva           ³ Data ³29/06/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Esta funcao e responsavel por iniciar a criacao do         ³±±
±±³          ³ processo e por enviar a mensagem para o destinatario       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040INICIO( cNumPA )                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cNumPA = Numero da Filial e Pedido posicionado no PE       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente Internacional                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A040Inicio( cNumPA  )

Local nDias		 := 0
Local nHoras	 := 0
Local nMinutos	 := 10
Local nZ		 := 0
Local cCodProc   := "000003"
Local cCodStatus := ""
Local cNumPA	 := cNumPA
Local cAssunto   := AllTrim( GetMV("ES_WFTITPA") ) + " " + cNumPA  
Local cHtmlMod 	 := AllTrim( GetMV("ES_WFHTMPA") )
Local cUsuSiga	 := __CUSERID
Local cTitulo	 := ""
Local cMailID	 := ""
Local cRet		 := ""
Local cTexto 	 := ""
Local cQuery	 := ""
Local cAliasT	 := GetNextAlias()
Local cCondPgto	 := ""	
Local lIsAPW 	 := HttpIsAPW()
Local nValTotal	 := 0
Local aRet		 := {}
//Local aObsPed	 := {}
Local cObsPed	 := ""

If (lIsAPW)
	cRet := "Iniciado com StartWebEX ou StartWeb"
Else
	cRet := "Chamado Via APL"
EndIf


aRet := A040WfMail( cNumPA )//Funcao para retornar o e-mail e o nivel do usuario aprovador

If !aRet[1] == "OK"// Se nao tiver aprovadores nao gera o formulario
	
	dbSelectArea("SA2")
	dbSetOrder(1)//A2_FILIAL+A2_COD+A2_LOJA
	dbSeek( xFilial("SA2") + M->E2_FORNECE + M->E2_LOJA )
	cAssunto += " " + Alltrim(SA2->A2_NOME)


    //Se for ultimo nivel, devo pegar modelo com tabela de bancos
	If !aRet[4]
		cHtmlMod 	 := AllTrim( GetMV("ES_WFHTMP1") )	
	EndIf

	oProcess := TWFProcess():New(cCodProc, cAssunto)
	oProcess:NewTask(cTitulo, cHtmlMod)
	oHtml	:= oProcess:oHtml
	
	cCodStatus := "003100"
	cTexto := "Iniciando o processamento da " + cAssunto + " do Codigo: " + cNumPA
	oProcess:Track(cCodStatus, cTexto, cUsuSiga)
	
	cTexto := "Gerando Pedido para envio..."
	cCodStatus := "003110"
	oProcess:Track(cCodStatus, cTexto, cUsuSiga)
 

	oProcess:oHtml:ValByName( "E2_CODUSR"	, Alltrim(M->E2_CODUSR) + ' ' + Posicione("Z03",1,xFilial("Z03")+M->E2_CODUSR,"Z03_NOME") )
	
	oProcess:oHtml:ValByName( "E2_NUM"		, M->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO) )
	oProcess:oHtml:ValByName( "E2_EMISSAO"	, M->E2_EMISSAO )
	oProcess:oHtml:ValByName( "E2_FORNECE"	, M->E2_FORNECE + "/" + M->E2_LOJA )
		
	dbSelectArea("SA2")
	dbSetOrder(1)//A2_FILIAL+A2_COD+A2_LOJA
	If dbSeek( xFilial("SA2") + M->E2_FORNECE + M->E2_LOJA )
		oProcess:oHtml:ValByName( "E2_NOME"	, SA2->A2_NOME )
	EndIf

	oProcess:oHtml:ValByName( "E2_MOEDA"	, GetMV("MV_MOEDA" + cValToChar( M->E2_MOEDA ) ) )
	oProcess:oHtml:ValByName( "E2_HIST"     , M->E2_HIST ) 
	oProcess:oHtml:ValByName( "E2_OBSERV"   , M->E2_OBSERV ) 
		
	dbSelectArea("SM0")
				
	oProcess:oHtml:ValByName( "E2_TOTAL"	, Transform( M->E2_VALOR, PesqPict("SE2","E2_VALOR") ) )
		
	oProcess:oHtml:ValByName( "CR_NIVEL"	, aRet[2] )
	oProcess:oHtml:ValByName( "CR_CODUSR"	, cUsuSiga )
	oProcess:oHtml:ValByName( "CR_APROVADOR", aRet[3] )

	//Se for ultimo nivel, tenho de enviar os bancos para escolher qual deles
	If !aRet[4]

		oProcess:oHtml:ValByName( "msgbanco" , "No último nível de aprovação é necessário escolher o banco de pagamento: " )
	
		dbSelectArea("SA6")
		dbGoTop()
		While !EOF() 
		
			If SA6->A6_WF == '1' //sOMENTE MARCADOS COMO sIM
				
				//aAdd( ( oProcess:oHtml:ValByName( "A.A6_COD" ) ) 		, SA6->A6_COD + ' ' + SA6->A6_AGENCIA +' ' +SA6->A6_NUMCON +' '+ SA6->A6_NOME)
				aAdd( ( oProcess:oHtml:ValByName( "A.banco" ) )           , SA6->(A6_COD+A6_AGENCIA+A6_NUMCON ) )
				aAdd( ( oProcess:oHtml:ValByName( "A.A6_COD" ) ) 		, SA6->A6_COD )
				aAdd( ( oProcess:oHtml:ValByName( "A.A6_AGENCIA" ) )	, SA6->A6_AGENCIA )
				aAdd( ( oProcess:oHtml:ValByName( "A.A6_NUMCON" ) )  	, SA6->A6_NUMCON )
				aAdd( ( oProcess:oHtml:ValByName( "A.A6_NOME" ) )   	, SA6->A6_NOME )
		    EndIf
		    
	    SA6->(dbSkip())
	    End
	EndIf
	
	oProcess:cSubject := cAssunto
	oProcess:cTo := "siga"
	oProcess:UserSiga := WFCodUser("BI")
	
	oProcess:bReturn := "U_SCIF010(1)"
	oProcess:bTimeOut := {"U_SCIF010(2)", nDias, nHoras, nMinutos}
	cTexto := "Enviando Pagamento Antecipado..."
	cCodStatus := "003120"
	oProcess:Track(cCodStatus, cTexto , cUsuSiga)
	cMailID := oProcess:Start()
	
	// Envia o Numero do Processo para o formulario para ser solicitado no retorno
	oProcess:oHtml:ValByName( "CR_NUMPROC" , cMailID )

	
	oProcess :NewTask(cTitulo, AllTrim( GetMV("ES_WFLTMPA") ) )
	oProcess :ohtml:ValByName("titulo", "Aprovação de Pagamento Antecipado - Internacional" )
	oProcess :ohtml:ValByName("paragrafo", "Pagamento incluído pelo usuário" )
	oProcess :ohtml:ValByName("nome_usuario", Capital( RtFullName( cUsuSiga ) ) )
	oProcess :ohtml:ValByName("frase_link", "Clique no número do Pagamento para mais detalhes: " )
	oProcess :ohtml:ValByName("cod_sc", cNumPA )
	oProcess :ohtml:ValByName("proc_link", AllTrim( GetMV("ES_WFLINK") ) + "messenger/emp" +cEmpAnt + "/siga/" + cMailID + ".htm" )
	
	
	//Aqio pode vir mais de uma linha de aprovador...devo juntar os mails do pessoal antes do envio...
	cDest := ""
	For tt:=1 to Len(aRet) Step 4
        If !Alltrim(aRet[tt]) $ cDest
	        cDest += Alltrim(aRet[tt])+";"   
        EndIf
	Next tt
	
	oProcess :cTo := cDest //aRet[1] //Array com o e-mail do aprovador
	oProcess :csubject := AllTrim( GetMV("ES_WFTITPA") ) + " " + cNumPA + " " + SA2->A2_NOME 
	oProcess :Start()
	
	cTexto := "Enviando o E-mail WF."
	cCodStatus := "003130"
	oProcess:Track(cCodStatus, cTexto , cUsuSiga)
	
	cTexto := "Aguarde retorno..."
	cCodStatus := "003140"
	oProcess:Track(cCodStatus, cTexto , cUsuSiga)
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A040RETORNO ³ Autor ³ Ednei Silva         ³Data ³29/06/2016 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Esta funcao e executada no retorno da mensagem enviada     ³±±
±±³          ³ pelo destinatario. O Workflow recria o processo em que     ³±±
±±³          ³ parou anteriormente na funcao A040Inicio e repassa a       ³±±
±±³          ³ variavel objeto oProcess por parametro.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  A040Retorno(oProcess)                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oProcess = Objeto do Workflow                              ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ String 		                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente Internacional  						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A040Retorno(oProcess)

Local cNumPA		:= oProcess:oHtml:RetByName("E2_NUM") + StrTran( oProcess:oHtml:RetByName("E2_FORNECE"), "/", "" ) //M->E2_FORNECE + "/" + M->E2_LOJA
Local cObs			:= oProcess:oHtml:RetByName("E2_OBS")
Local cOpcao		:= oProcess:oHtml:RetByName("opcao")
Local cNivelUsr		:= oProcess:oHtml:RetByName("CR_NIVEL")
Local cUsuSiga		:= oProcess:oHtml:RetByName("CR_CODUSR")
Local cUsuAprov		:= oProcess:oHtml:RetByName("CR_APROVADOR")
Local cBanco		:= oProcess:oHtml:RetByName("banco")
Local cCNAB 		:= oProcess:oHtml:RetByName("cnab")
Local cCodStatus	:= ""
Local cTexto		:= ""
Local cSeek			:= ""
Local cTitulo 		:= "Aprovação do Pagamento Antecipado"
Local cMailID		:= oProcess:oHtml:RetByName("CR_NUMPROC")
Local aRet			:= {}
Local lResid        :=.F.
Local cTipo			:= ""
Local cPc  			:= ""
Local cNivel		:= ""

Private lAutoErrNoFile := .T.     				
Private lMsErroAuto    := .F.
Private lMsHelpAuto	:= .T. 

Default cBanco := ''


cTexto := "Executando funcao de retorno"
cCodStatus := "003150"
oProcess:Track(cCodStatus, cTexto , cUsuSiga)

//+-----------------------------------------------------+
//| Verifica a alcada de Compras para reenviar o e-mail |
//| de acordo com a selecao do usuario no retorno do    |
//| formulario                                          |
//+-----------------------------------------------------+
If AllTrim( cOpcao ) == "1"//Se o usuario liberou o Pedido
	
	cSeek := xFilial("SCR")
	cSeek += PadR( "PA", TamSX3("CR_TIPO")[01] )
	cSeek += PadR( cNumPA, TamSX3("CR_NUM")[01] )
	cSeek += PadR( cNivelUsr, TamSX3("CR_NIVEL")[01] )
	
	cTipo := PadR( "PA", TamSX3("CR_TIPO")[01] )
	cPc   := PadR( cNumPA, TamSX3("CR_NUM")[01] )
	cNivel:= PadR( cNivelUsr, TamSX3("CR_NIVEL")[01] )
	
	dbSelectArea("SCR")
	dbSetOrder(1)//CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
	If dbSeek( cSeek )
		While SCR->( !Eof() ) .and. SCR->CR_FILIAL	== xFilial( 'SCR' );
			.and. SCR->CR_NUM == cPc .and. SCR->CR_TIPO == cTipo .and. SCR->CR_NIVEL == cNivel
			
			RecLock("SCR",.F.)
			SCR->CR_STATUS	:= "03"
			SCR->CR_DATALIB	:= Date()
			SCR->CR_USERLIB	:= cUsuAprov
			SCR->CR_LIBAPRO	:= cUsuAprov
			MsUnLock()
			
			SCR->( dbSkip() )
			
		Enddo
	EndIf
	//+----------------------------------+
	//| Altera o status do proximo nivel |
	//+----------------------------------+
	cNivelUsr := Soma1( cNivelUsr )
	cSeek := xFilial("SCR")
	cSeek += PadR( "PA", TamSX3("CR_TIPO")[01] )
	cSeek += PadR( cNumPA, TamSX3("CR_NUM")[01] )
	cSeek += PadR( cNivelUsr, TamSX3("CR_NIVEL")[01] )
	
	dbSelectArea("SCR")
	dbSetOrder(1)//CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
	If dbSeek( cSeek )
		While SCR->( !Eof() ) .and. SCR->CR_FILIAL	== xFilial( 'SCR' );
			.and. SCR->CR_NUM == cPc .and. SCR->CR_TIPO == cTipo .and. SCR->CR_NIVEL == cNivelUsr
		
			RecLock("SCR",.F.)
			SCR->CR_STATUS	:= "01"
			MsUnLock()

		SCR->( dbSkip() )
		Enddo
		
	EndIf
	
	//+---------------------------------------------------+
	//| Funcao para retornar o e-mail e o nivel do usuario|
	//| aprovador caso ainda existam niveis a aprovar     |
	//+---------------------------------------------------+
	aRet := A040WfMail( cNumPA )


Else// Se nao liberou

	
	cSeek := xFilial("SCR")
	cSeek += PadR( "PA", TamSX3("CR_TIPO")[01] )
	cSeek += PadR( cNumPA, TamSX3("CR_NUM")[01] )
	cSeek += PadR( cNivelUsr, TamSX3("CR_NIVEL")[01] )
	
	dbSelectArea("SCR")
	dbSetOrder(1)//CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
	If dbSeek( cSeek )
	      
          
		RecLock("SCR",.F.)
		SCR->CR_STATUS	:= "04"
		SCR->CR_DATALIB	:= Date()
		SCR->CR_OBSERV	:= cObs
		MsUnLock()
    
			
	EndIf
	
	aAdd( aRet, "OK")
	aAdd( aRet, "")
	aAdd( aRet, "")
	aAdd( aRet, .f.)
	
EndIf

If AllTrim( aRet[1] ) == "OK"

	nCount:=0
	dbSelectArea("SE2")
	dbSetOrder(1) 
	If dbSeek( xFilial("SE2") + cNumPA ) //pref + num + parcela + tipo + fornece + loja 
		



			If AllTrim( cOpcao ) == "1"
				
			    //Se for o ultimo nivel, entao já grava o banco neste PA ?!
			    If !Empty(cBanco)
			
			       If cCNAB == "1" //Somente grava o banco no PA, pois será pago via CNAB
			       
						RecLock( "SE2", .F. )
						SE2->E2_BCOPAG := SubStr(cBanco,1,3)
						SE2->E2_MSBLQL := "2"
						MsUnLock()


			       ElseIf cCNAB == "2" //Faz o Mov Bancário para este banco...e baixa o PA
			
						//Se for banco que gera Mov Bancario
						//If cGet $ GetMv('ES_BCOSE5')
						
							aFINA100 := {   { "E5_FILIAL"	, xFilial("SE5")    , Nil },;
											{ "E5_DATA"		, Date()	        , Nil },;
											{ "E5_MOEDA"	, "M1"			    , Nil },;
											{ "E5_VALOR"	, SE2->E2_VALOR	    , Nil },;
											{ "E5_NATUREZ"	, SE2->E2_NATUREZ   , Nil },;
											{ "E5_BANCO"	, SubStr(cBanco,1,3)  , Nil },;
											{ "E5_AGENCIA"	, SubStr(cBanco,4,5)  , Nil },;
											{ "E5_CONTA"	, SubStr(cBanco,9,10) , Nil },;
											{ "E5_MOVFKS"	, "S"			    , Nil },; //nao criou mov na FK, abrir chamado...											
											{ "E5_HISTOR"	, SE2->E2_HIST        , Nil }}


											/*											
											{ "E5_DTDIGIT"	, Date()		    , Nil },;
											{ "E5_DTDISPO"	, Date()		    , Nil },;
											{ "E5_FILORIG"	, xFilial("SE5")    , Nil },;
											{ "E5_RECPAG"	, "P"               , Nil },;
											{ "E5_TIPODOC"	, "PA"              , Nil },;
											{ "E5_ORIGEM"	, "FINA050"         , Nil },;
											{ "E5_MOTBX"	, "NOR"             , Nil },;
											{ "E5_PREFIXO"	, SE2->E2_PREFIXO   , Nil },;
											{ "E5_NUMERO"	, SE2->E2_NUM	    , Nil },;
											{ "E5_PARCELA"	, SE2->E2_PARCELA   , Nil },;
											{ "E5_CLIFOR"	, SE2->E2_FORNECE   , Nil },;
											{ "E5_FORNECE"	, SE2->E2_FORNECE   , Nil },;
											{ "E5_LOJA"	    , SE2->E2_LOJA	    , Nil },;
											{ "E5_CCD"	    , SE2->E2_CCD	    , Nil },;
											{ "E5_KEY"   	, SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)   , Nil },;
											{ "E5_BENEF"	, SE2->E2_NOMEFOR     , Nil },;
											*/
					       
					     	lAutoErrNoFile := .T.     				
							lMsErroAuto    := .F.
							lMsHelpAuto	:= .T. 
							MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,3) //Pagamento
							
							// -- trecho de validacao e gravacao apos rotina automatica
							If lMsErroAuto
								
								cErr := ''
								MostraErro()
								aMsg := GetAutoGRLog()
								aEval(aMsg,{|x| cErr += x + CRLF})
								DisarmTransaction()


							Else

                                Reclock("SE5",.f.)
								SE5->E5_DTDIGIT	:= Date()
								SE5->E5_DTDISPO := Date()		    
								SE5->E5_FILORIG := xFilial("SE5")   
								SE5->E5_RECPAG  := "P"              
								SE5->E5_TIPODOC := "PA"             
								SE5->E5_ORIGEM  := "FINA050"        
								SE5->E5_MOTBX   := "NOR"            
								SE5->E5_PREFIXO := SE2->E2_PREFIXO  
								SE5->E5_NUMERO  := SE2->E2_NUM	    
								SE5->E5_PARCELA := SE2->E2_PARCELA  
								SE5->E5_CLIFOR  := SE2->E2_FORNECE  
								SE5->E5_FORNECE := SE2->E2_FORNECE  
								SE5->E5_LOJA    := SE2->E2_LOJA	    
								SE5->E5_CCD     := SE2->E2_CCD	    
								SE5->E5_KEY     := SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO+E2_FORNECE+E2_LOJA)  
								SE5->E5_BENEF   := SE2->E2_NOMEFOR 
                                SE5->(MsUnlock())

								RecLock( "SE2", .F. )
								SE2->E2_BCOPAG := SubStr(cBanco,1,3)
								SE2->E2_MSBLQL := "2"
								MsUnLock()
		

							EndIf
						//EndIf
			       EndIf
			    EndIf
			
				if nCount=0
					U_StatuPA(cNumPA,"L")
					nCount=nCount+1
				endif
			Else
				
				RecLock( "SE2", .F. )
				SE2->E2_MSBLQL := "1"
				MsUnLock()

				if nCount=0
					U_StatuPA(cNumPA,"B",cObs)
					nCount=nCount+1
				endif
				
			EndIf
			
		
		cTexto := "Atualizando Pagamento Antecipado: " + cNumPA
		cCodStatus := "003160"
		oProcess:Track(cCodStatus, cTexto, oProcess:cRetFrom)
		
	Else
		



		cTexto := "Não foi possível encontrar o PA: " + cNumPA
		cCodStatus := "003170"
		oProcess:Track(cCodStatus, cTexto, oProcess:cRetFrom)
		
	EndIf
	
Else
	
	//+---------------------------------------+
	//| Executa novamente o envio do Workflow |
	//+---------------------------------------+

	A040Alcada( cNumPA,cUsuSiga )
	
EndIf

cTexto := "Processo Finalizado"
cCodStatus := "003180"
oProcess:Track(cCodStatus, cTexto, oProcess:cRetFrom)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A040TIMEOUT³ Autor ³ Ednei Silva           ³Data ³29/06/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Esta funcao sera executada a partir do Scheduler no tempo  ³±±
±±³          ³ estipulado pela propriedade :bTimeout da classe TWFProcess.³±±
±±³          ³ Caso o processo tenha sido respondido em tempo habil, essa ³±±
±±³          ³ execucao sera descartada automaticamente.                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente Interncaional                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A040TimeOut(oProcess)

Local nDias  		:= 0
Local nHoras 		:= 0
Local nMinutos	    := 10
Local cCodStatus	:= ""
Local cHtmlMod	    := ""
Local cTexto		:= ""
Local cTitulo		:= ""
Local aRet		    := A040WfMail( cNumPA )

cHtmlMod := AllTrim( GetMV("ES_WFHTMPA") )
cTitulo := "Aprovação do Pagamento Antecipado"

cTexto := "Executando Funcao de TIMEOUT..."
cCodStatus := "003190"
oProcess:Track(cCodStatus, cTexto)

cNumPA := oProcess:oHtml:ValByName("E2_NUM")
oProcess:Finish()

dbSelectArea("SE2")
dbSetOrder(1)
If dbSeek( xFilial("SE2") + cNumPA )
	
	oProcess:NewTask(cTitulo, cHtmlMod, .T.)
	
	If (Left(oProcess:cSubject,9) != "(REENVIO)")
		oProcess:cSubject := "(REENVIO)" + oProcess:cSubject
	EndIf
	
	oProcess:cTo 		:= aRet[1]
	oProcess:UserSiga	:= WFCodUser("BI")
	oProcess:bReturn 	:= "U_SCIF010(1)"
	oProcess:bTimeOut	:= {"U_SCIF010(2)", nDias, nHoras, nMinutos}// Redefina a funcao de timeout a ser executada.
	
	cTexto := "Reenviando o Pagamento..."
	cCodStatus := "003200"
	oProcess:Track(cCodStatus, cTexto)
	oProcess:Start()		// Inicie o processo
	
Else
	
	cTexto := "Não foi possível encontrar o Pedido: " + cNumPA
	cCodStatus := "003170" // Codigo do cadastro de status de processo
	oProcess:Track(cCodStatus, cTexto)
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A040WfMail³ Autor ³ Ednei Silva           ³ Data ³29/06/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Envia o e-mail Workflow conforme alcada de aprovacao       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040WfMail( ExpC01 )                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC01 = Codigo do Pedido de Compra                        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Array                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente Internacional                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function  A040WfMail( cNumPA )

Local aRet		:= {"OK","","",.f.}
Local cQuery		:= ""
Local cAliasT		:= GetNextAlias()
Local cAliasA		:= GetNextAlias()



cQuery := " SELECT CR_NUM,"
cQuery += "        CR_USER,"
cQuery += "        CR_APROV,"
cQuery += "        CR_NIVEL,"
cQuery += "        CR_STATUS"
cQuery += " FROM " + RetSQLName("SCR")
cQuery += " WHERE CR_FILIAL	  = '" + xFilial("SCR") + "'"
cQuery += "   AND CR_TIPO	  = 'PA'"
cQuery += "   AND CR_NUM     = '" + cNumPA + "'"
cQuery += "   AND CR_DATALIB = ''"
cQuery += "   AND CR_USERLIB = ''"
cQuery += "   AND D_E_L_E_T_ <>'*'"
cQuery += " ORDER BY CR_NIVEL"
cQuery := ChangeQuery( cQuery )
dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )


lPri := .T.
While !EOF()

	If ( cAliasT )->( !Eof() )
		If lPri
			aRet := {}
			lPri := .f.
		EndIf

		aAdd( aRet, AllTrim( UsrRetMail( ( cAliasT )->CR_USER ) ) )
		aAdd( aRet, ( cAliasT )->CR_NIVEL )
		aAdd( aRet, ( cAliasT )->CR_USER )
		aAdd( aRet, .f. )
		
		
		//Se achou pelo menos 1 nivel, verifico se tem mais algum, senão é ultimo nivel e devo enviar os bancos...
		cQuery := " SELECT CR_NUM,"
		cQuery += "        CR_USER,"
		cQuery += "        CR_APROV,"
		cQuery += "        CR_NIVEL,"
		cQuery += "        CR_STATUS"
		cQuery += " FROM " + RetSQLName("SCR")
		cQuery += " WHERE CR_FILIAL	  = '" + xFilial("SCR") + "'"
		cQuery += "   AND CR_TIPO	  = 'PA'"
		cQuery += "   AND CR_NUM      = '" + cNumPA + "'"
		cQuery += "   AND CR_NIVEL    = '" + SOMA1(( cAliasT )->CR_NIVEL) + "'"
		cQuery += "   AND CR_DATALIB = ''"
		cQuery += "   AND CR_USERLIB = ''"
		cQuery += "   AND D_E_L_E_T_ <>'*'"
		cQuery += " ORDER BY CR_NIVEL"
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasA,.F.,.T. )
				
		lTemMais := .F.
		While !EOF()
		
			If ( cAliasA )->( !Eof() )
		       lTemMais := .T.
				aRet[4] := .T.
		       
		       Exit
		    EndIf
		    
		( cAliasA )->( dbSkip() )	
		End
		( cAliasA )->( dbCloseArea() )
		
		
	Else

		aAdd( aRet, "OK" )
		aAdd( aRet, "" )
		aAdd( aRet, "" )
		aAdd( aRet, .f. )
		
	EndIf
dbSelectArea(cAliasT)
( cAliasT )->( dbSkip() )	
End
( cAliasT )->( dbCloseArea() )

Return( aRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³A040Alcada³ Autor ³ Ednei Silva           ³ Data ³29/06/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao de envio do Workflow com alcada                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040Alcada(ExpC01,ExpC02)                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC01 = Numero do Pedido de Compra                        ³±±
±±³          ³ ExpC02 = Codigo do Usuario que inclui do Pedido            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente Internacional                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function  A040Alcada( cNumPA,cUsuSiga )

Local nDias		:= 0
Local nHoras	:= 0
Local nMinutos	:= 10
Local nZ		:= 0
Local cCodProc 	:= "000003"
Local cCodStatus:= ""
Local cAssunto 	:= AllTrim( GetMV("ES_WFTITPA") ) + " " + cNumPA
Local cHtmlMod 	:= AllTrim( GetMV("ES_WFHTMPA") )
Local cTitulo	:= ""
Local cMailID	:= ""
Local cRet		:= ""
Local cTexto 	:= ""
Local cQuery	:= ""
Local cQaprovou	:= ""              
Local cAliasT	:= GetNextAlias()
Local cAliasL	:= GetNextAlias()
Local cCondPgto	:= ""
Local nValTotal	:= 0
Local aRet 		:= {}
//Local aObsPed	:= {}
Local lSetCentury := __SetCentury()
Local cQuery1	:=""
Local cObsPed	:= ""

Local cVarAux1 := GetMV("MV_MOEDA" + cValToChar( SE2->E2_MOEDA ) )
Local cVarAux2 := GetMV("ES_WFLINK")
Local cVarAux3 := GetMV("ES_WFLTMPA")
Local cVarAux4 := GetMV("ES_WFTITPA")

If	!lSetCentury
	__SetCentury("ON")
EndIf



aRet := A040WfMail( cNumPA )//Funcao para retornar o e-mail e o nivel do usuario aprovador

If !aRet[1] == "OK"// Se houver aprovadores envia o formulario

    //Se for ultimo nivel, devo pegar modelo com tabela de bancos
	If !aRet[4]
		cHtmlMod 	 := AllTrim( GetMV("ES_WFHTMP1") )	
	EndIf

	cQuery1 := " SELECT CR_NUM,"
	cQuery1 += "        CR_USER,"
	cQuery1 += "        CR_APROV,"
	cQuery1 += "        CR_NIVEL,"
	cQuery1 += "        CR_STATUS"
	cQuery1 += " FROM " + RetSQLName("SCR")
	cQuery1 += " WHERE CR_FILIAL	  = '" + xFilial("SCR") + "'"
	cQuery1 += "   AND CR_TIPO	  = 'PA'"
	cQuery1 += "   AND CR_NUM     = '" + cNumPA + "'"
	//cQuery1 += "   AND CR_USER    = '" + aRet[3] + "'"
	cQuery1 += "   AND CR_NIVEL   = '" + aRet[2] + "'"
	cQuery1 += "   AND CR_DATALIB = ''"
	cQuery1 += "   AND CR_USERLIB = ''"
	cQuery1 += "   AND D_E_L_E_T_ <>'*'"
	cQuery1 += " ORDER BY CR_NIVEL"
	cQuery1 := ChangeQuery( cQuery1 )
	//MemoWrite("testeEdy.SQL",cQuery1)
	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery1),cAliasL,.F.,.T. )
	
	While ( cAliasL )->( !Eof() )
		
		cTitulo		:= ""
		cMailID		:= ""
		cRet		:= ""
		cTexto 		:= ""
		cQuery		:= ""
		cQaprovou	:= ""
		nValTotal	:= 0
		cCodStatus 	:= ""
		//aObsPed	:= {}
		cObsPed		:= ""
		
		oProcess := TWFProcess():New(cCodProc, cAssunto)
		oProcess:NewTask(cTitulo, cHtmlMod)
		oHtml	:= oProcess:oHtml
		
		cCodStatus := "003100"
		cTexto := "Iniciando o processamento da " + cAssunto + " do Código: " + cNumPA
		oProcess:Track(cCodStatus, cTexto, cUsuSiga)
		
		cTexto := "Gerando Pedido para envio..."
		cCodStatus := "003110"
		oProcess:Track(cCodStatus, cTexto, cUsuSiga)
		
		dbSelectArea("SE2")
		dbSetOrder(1)
		If dbSeek( xFilial("SE2") + cNumPA )
			
			oProcess:oHtml:ValByName( "E2_NUM"		, SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO) )
			oProcess:oHtml:ValByName( "E2_EMISSAO"	, SE2->E2_EMISSAO )
			oProcess:oHtml:ValByName( "E2_FORNECE"	, SE2->E2_FORNECE + "/" + SE2->E2_LOJA )
		
			dbSelectArea("SA2")
			dbSetOrder(1)//A2_FILIAL+A2_COD+A2_LOJA
			If dbSeek( xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA )
				oProcess:oHtml:ValByName( "E2_NOME"	, SA2->A2_NOME )
			EndIf
		
			oProcess:oHtml:ValByName( "E2_MOEDA"	, cVarAux1 )
			oProcess:oHtml:ValByName( "E2_HIST"     , SE2->E2_HIST ) 
			oProcess:oHtml:ValByName( "E2_OBSERV"   , SE2->E2_OBSERV ) 
				
			dbSelectArea("SM0")
						
			oProcess:oHtml:ValByName( "E2_TOTAL"	, Transform( SE2->E2_VALOR, PesqPict("SE2","E2_VALOR") ) )
				
			oProcess:oHtml:ValByName( "CR_NIVEL"	, aRet[2] )
			oProcess:oHtml:ValByName( "CR_CODUSR"	, cUsuSiga )
			oProcess:oHtml:ValByName( "CR_APROVADOR", aRet[3] )
		
			//Se for ultimo nivel, tenho de enviar os bancos para escolher qual deles
			If !aRet[4]
		
				oProcess:oHtml:ValByName( "msgbanco" , "No último nível de aprovação é necessário escolher o banco de pagamento: " )
			
				dbSelectArea("SA6")
				dbGoTop()
				While !EOF() 
				
					If SA6->A6_WF == '1' //sOMENTE MARCADOS COMO sIM
						//aAdd( ( oProcess:oHtml:ValByName( "A.A6_COD" ) ) 		, SA6->A6_COD + ' ' + SA6->A6_AGENCIA +' ' +SA6->A6_NUMCON +' '+ SA6->A6_NOME)
						aAdd( ( oProcess:oHtml:ValByName( "A.banco" ) )           , SA6->(A6_COD+A6_AGENCIA+A6_NUMCON ) )
						aAdd( ( oProcess:oHtml:ValByName( "A.A6_COD" ) ) 		, SA6->A6_COD )
						aAdd( ( oProcess:oHtml:ValByName( "A.A6_AGENCIA" ) )	, SA6->A6_AGENCIA )
						aAdd( ( oProcess:oHtml:ValByName( "A.A6_NUMCON" ) )  	, SA6->A6_NUMCON )
						aAdd( ( oProcess:oHtml:ValByName( "A.A6_NOME" ) )   	, SA6->A6_NOME )
				    EndIf
				    
			    SA6->(dbSkip())
			    End
			EndIf
			
		
		EndIf
		
		oProcess:cSubject := cAssunto
		oProcess:cTo := "siga"
		oProcess:UserSiga	:= WFCodUser("BI")
		
		oProcess:bReturn	:= "U_SCIF010(1)"
		oProcess:bTimeOut	:= {"U_SCIF010(2)", nDias, nHoras, nMinutos}
		cTexto := "Enviando Pagamento Antecipado..."
		cCodStatus := "003120"
		oProcess:Track(cCodStatus, cTexto , cUsuSiga)
		cMailID := oProcess:Start()
		
		// Envia o Numero do Processo para o formulario para ser solicitado no retorno
		oProcess:oHtml:ValByName( "CR_NUMPROC" , cMailID )
	
		
		oProcess :NewTask(cTitulo, AllTrim( cVarAux3 ) )
		oProcess :ohtml:ValByName("titulo", "Aprovação de Pagamento Antecipado - Internacional" )
		oProcess :ohtml:ValByName("paragrafo", "Pagamento incluído pelo usuário" )
		oProcess :ohtml:ValByName("nome_usuario", Capital( RtFullName( cUsuSiga ) ) )
		oProcess :ohtml:ValByName("frase_link", "Clique no número do Pagamento para mais detalhes: " )
		oProcess :ohtml:ValByName("cod_sc", cNumPA )
		oProcess :ohtml:ValByName("proc_link", AllTrim( cVarAux2 ) + "messenger/emp" +cEmpAnt + "/siga/" + cMailID + ".htm" )
		
		cQliberou:=""
		cQliberou:=Alltrim(cQLibPC( cNumPA ))
		if cQliberou<>""
			oProcess :ohtml:ValByName("liberadopor","Quem já aprovou este pedido: "+cQliberou)
		endif
		oProcess :cTo := AllTrim( UsrRetMail(( cAliasL )->CR_USER ) ) //Array com o e-mail do aprovador
		oProcess :csubject := AllTrim( cVarAux4 ) + " " + cNumPA
		oProcess :Start()
		
		cTexto := "Enviando o E-mail WF."
		cCodStatus := "003130"
		oProcess:Track(cCodStatus, cTexto , cUsuSiga)
		
		cTexto := "Aguarde retorno..."
		cCodStatus := "003140"
		oProcess:Track(cCodStatus, cTexto , cUsuSiga)
		
		( cAliasL )->( dbSkip() )
	Enddo
	
	( cAliasL )->( dbCloseArea() )
	
EndIf

Return


Static Function  cQLibPC( cNumPA )

Local cUsers		:= ""
Local cQuery		:= ""
Local cAliasZ		:= GetNextAlias()



cQuery := " SELECT CR_NUM,"
cQuery += "        CR_USER,"
cQuery += "        CR_APROV,"
cQuery += "        CR_NIVEL,"
cQuery += "        CR_STATUS"
cQuery += " FROM " + RetSQLName("SCR")
cQuery += " WHERE CR_FILIAL	  = '" + xFilial("SCR") + "'"
cQuery += "   AND CR_TIPO	  = 'PA'"
cQuery += "   AND CR_NUM      = '" + cNumPA + "'"
cQuery += "   AND CR_DATALIB <> ''"
cQuery += "   AND CR_USERLIB <> ''"
cQuery += "   AND D_E_L_E_T_ <> '*'"
cQuery += " ORDER BY CR_NIVEL"
cQuery := ChangeQuery( cQuery )
dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZ,.F.,.T. )
While ( cAliasZ )->( !Eof() )
	
	If cUsers=""
		
		cUsers:=Capital( RtFullName( ( cAliasZ )->CR_USER ) )
		
	else
		cUsers:=cUsers+';'+Capital( RtFullName( ( cAliasZ )->CR_USER ) )
	endif
	
	
	( cAliasZ )->( dbSkip() )
Enddo
( cAliasZ )->( dbCloseArea() )

Return( cUsers )

//+-------------------------------------------------+
//| Funcao para retornar o nome completo do usuario |
//| Denis - 02/12/2019                              |
//+-------------------------------------------------+
Static Function RtFullName( cCodUser )
	
	Local cRet := ""
	
	cRet := UsrFullName( cCodUser )
	
Return( cRet )

/* Retirar caracteres especiais */
/*
User Function NoCharEsp(cString,lEspaco)

	Local cChar  := ""
	Local nX     := 0 
	Local nY     := 0
	Local cVogal := "aeiouAEIOU"
	Local cAgudo := "áéíóú"+"ÁÉÍÓÚ"
	Local cCircu := "âêîôû"+"ÂÊÎÔÛ"
	Local cTrema := "äëïöü"+"ÄËÏÖÜ"
	Local cCrase := "àèìòù"+"ÀÈÌÒÙ" 
	Local cTio   := "ãõÃÕ"
	Local cCecid := "çÇ"
	
	Local cMaior := ">"     
	Local cMenor := "<"
	
	Default lEspaco := .T.     
	
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
	
	If cMaior $ cString 
		cString := strTran( cString, cMaior, IIf( lEspaco, " ", "" ) ) 
	EndIf
	If cMenor $ cString 
		cString := strTran( cString, cMenor, IIf( lEspaco, " ", "" ) )
	EndIf
	
	//Chr das teclas abaixo
	//Seta para Esquerda: 37                        
	//Seta para Cima: 38
	//Seta para Direita: 39
	//Seta para Baixo: 40
	//Delete: 46
							
	cString := StrTran( cString, CRLF, IIf( lEspaco, " ", "" ) )
	
	cString := StrTran( cString, "&", "e" ) 
	
	cString := StrTran( cString, "'", IIf( lEspaco, " ", "" ) ) 
	
	cString := StrTran( cString, '"', IIf( lEspaco, " ", "" ) ) 
	 
	cString := StrTran( cString, ";", IIf( lEspaco, " ", "" ) )
	
	cString := StrTran( cString, Chr(40), IIf( lEspaco, " ", "" ) ) // Seta para baixo
	
	cString := StrTran( cString, '°', IIf( lEspaco, " ", "" ) )
	
	cString := StrTran( cString, Chr(176), IIf( lEspaco, " ", "" ) )

	cString := StrTran( cString, 'º', IIf( lEspaco, " ", "" ) )

	cString := StrTran( cString, 'ª', IIf( lEspaco, " ", "" ) )
	                 
	For nX:=1 To Len(cString)     
	
		cChar := SubStr(cString, nX, 1)
		
		If (Asc(cChar) < 45) .Or. ;  					 // caracteres 45-48 e numeros 48-57
		   (Asc(cChar) > 57 .and. Asc(cChar) < 65) .or.; // letras 65-90
		   (Asc(cChar) > 90 .and. Asc(cChar) < 97) .or.; // letras 97-122
		   (Asc(cChar) > 122) 
			cString := StrTran( cString, cChar, IIf( lEspaco, " ", "" ) )
		Endif
		
	Next nX       
        
Return( cString )         

u_ATUSC7()
*/
