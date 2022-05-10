#Include "Totvs.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ SCI99A   ³ Autor ³  Ednei Silva          ³ Data ³29/06/2017³±±
±±³Funcao    ³ SCIF011  ³ Autor ³  Ednei Silva          ³ Data ³29/06/2017³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que envia o E-mail de Workflow na inclusao de PRESTACAO  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function SCIF011( nOpcao,oProcess )

Default nOpcao := 0



Do Case
	Case nOpcao == 0
		A040Inicio( Z02->Z02_CHAVE + ' ' + Z02->Z02_NUMRES )
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
Static Function A040Inicio( cNumChave  )

Local nDias		 := 0
Local nHoras	 := 0
Local nMinutos	 := 10
Local nZ		 := 0
Local cCodProc   := "000004"
Local cCodStatus := ""

Local cAssunto   := AllTrim( GetMV("ES_WFTITPR") ) + " " + cNumChave
Local cHtmlMod 	 := AllTrim( GetMV("ES_WFHTMPR") )
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

Private cNumChave	 := cNumChave

If (lIsAPW)
	cRet := "Iniciado com StartWebEX ou StartWeb"
Else
	cRet := "Chamado Via APL"
EndIf




aRet := A040WfMail( cNumChave )//Funcao para retornar o e-mail e o nivel do usuario aprovador

If !aRet[1] == "OK"// Se nao tiver aprovadores nao gera o formulario
	
	oProcess := TWFProcess():New(cCodProc, cAssunto)
	oProcess:NewTask(cTitulo, cHtmlMod)
	oHtml	:= oProcess:oHtml
	
	cCodStatus := "004100"
	cTexto := "Iniciando o processamento da " + cAssunto + " do Codigo: " + cNumChave
	oProcess:Track(cCodStatus, cTexto, cUsuSiga)
	
	cTexto := "Gerando Pedido para envio..."
	cCodStatus := "004110"
	oProcess:Track(cCodStatus, cTexto, cUsuSiga)
	
	oProcess:oHtml:ValByName( "Z02_CHAVE"		, Z02->(Z02_CHAVE+' '+Z02_NUMRES) )
	If Z02->Z02_TPPA $ "1"
		dbSelectArea("SE2")
		SE2->(dbSetOrder(1))
		dbSeek(xFilial("SE2")+Z02->Z02_CHAVE,.f.)
		oProcess:oHtml:ValByName( "Z02_TITULAR"		, Alltrim(SE2->E2_CODUSR) + ' ' + Posicione("Z03",1,xFilial("Z03")+SE2->E2_CODUSR,"Z03_NOME")  )
		
	Else
		oProcess:oHtml:ValByName( "Z02_TITULAR"		, Alltrim(Z02->Z02_CODUSR) + ' ' + Posicione("Z03",1,xFilial("Z03")+Z02->Z02_CODUSR,"Z03_NOME")  )
	EndIf
	
	
	//Aqui pego todoas as DEspesas...
	aAreaZ02   := Z02->(GetArea())
	nTotalDesp := 0
	cChave := xFilial("Z02")+Z02->(Z02_CHAVE+Z02_NUMRES)
	dbSelectArea("Z02")
	dbSetOrder(1)
	dbSeek(xFilial("Z02")+Z02->(Z02_CHAVE+Z02_NUMRES),.f.)
	
	While !EOF() .and. cChave == xFilial("Z02")+Z02->(Z02_CHAVE+Z02_NUMRES)
		
		
		aAdd( ( oProcess:oHtml:ValByName( "A.Z02_NUM" ) ) 		, Z02->(Z02_PREF+Z02_NUMERO+Z02_PARC+Z02_TIPO) )
		//oProcess:oHtml:ValByName( "Z02_NUM"		, Z02->(Z02_PREF+Z02_NUMERO+Z02_PARC+Z02_TIPO) )
		aAdd( ( oProcess:oHtml:ValByName( "A.Z02_FORNECE" ) )	, Z02->(Z02_FORNEC+ ' / ' + Z02_LOJA) )
		
		dbSelectArea("SA2")
		dbSetOrder(1)//A2_FILIAL+A2_COD+A2_LOJA
		If dbSeek( xFilial("SA2") + Z02->Z02_FORNEC + Z02->Z02_LOJA )
			aAdd( ( oProcess:oHtml:ValByName( "A.Z02_NOME" ) )  , SA2->A2_NOME )
		EndIf
		aAdd( ( oProcess:oHtml:ValByName( "A.Z02_VALOR" ))	, Transform( Z02->Z02_VALOR, PesqPict("Z02","Z02_VALOR") ) )
		
		nTotalDesp += Z02->Z02_VALOR
		
		aAdd( ( oProcess:oHtml:ValByName( "A.Z02_NATUREZA" ) ), Alltrim(Z02->Z02_NAT) + ' ' + Posicione("SED",1,xFilial("SED")+Z02->Z02_NAT,"ED_DESCRIC")  )
		aAdd( ( oProcess:oHtml:ValByName( "A.Z02_CC"    )	) , Alltrim(Z02->Z02_CC) + ' ' + Posicione("CTT",1,xFilial("CTT")+Z02->Z02_CC,"CTT_DESC01")   )
		aAdd( ( oProcess:oHtml:ValByName( "A.ANEXOS"    )	) , u_S99AConhe(Z02->(Z02_CHAVE+Z02_NUMRES+Z02_ITEM),oProcess)   )
		
		dbSelectArea("Z02")
		Z02->(dbSkip())
	End
	RestArea(aAreaZ02)
	
	oProcess:oHtml:ValByName( "Z02_TOTAL"	, Transform( nTotalDesp, PesqPict("Z02","Z02_VALOR") ) )
	
	oProcess:oHtml:ValByName( "CR_NIVEL"	, aRet[2] )
	oProcess:oHtml:ValByName( "CR_CODUSR"	, cUsuSiga )
	oProcess:oHtml:ValByName( "CR_APROVADOR", aRet[3] )
	
	oProcess:cSubject := cAssunto
	oProcess:cTo := "siga"
	oProcess:UserSiga := WFCodUser("BI")
	
	oProcess:bReturn := "U_SCIF011(1)"
	oProcess:bTimeOut := {"U_SCIF011(2)", nDias, nHoras, nMinutos}
	cTexto := "Enviando Prestação de Contas..."
	cCodStatus := "004120"
	oProcess:Track(cCodStatus, cTexto , cUsuSiga)
	cMailID := oProcess:Start()
	
	// Envia o Numero do Processo para o formulario para ser solicitado no retorno
	oProcess:oHtml:ValByName( "CR_NUMPROC" , cMailID )
	
	oProcess :NewTask(cTitulo, AllTrim( GetMV("ES_WFLTMPR") ) )
	oProcess :ohtml:ValByName("titulo", "Aprovação de Prestação de Contas - Internacional" )
	oProcess :ohtml:ValByName("paragrafo", "Pagamento incluído pelo usuário" )
	oProcess :ohtml:ValByName("nome_usuario", Capital( RtFullName( cUsuSiga ) ) )
	oProcess :ohtml:ValByName("frase_link", "Clique no número do Pagamento para mais detalhes: " )
	oProcess :ohtml:ValByName("cod_sc", cNumChave )
	oProcess :ohtml:ValByName("proc_link", AllTrim( GetMV("ES_WFLINK") ) + "messenger/emp" +cEmpAnt + "/siga/" + cMailID + ".htm" )
	
	
	//Aqio pode vir mais de uma linha de aprovador...devo juntar os mails do pessoal antes do envio...
	cDest := ""
	For tt:=1 to Len(aRet) Step 4
        If !Alltrim(aRet[tt]) $ cDest
	        cDest += Alltrim(aRet[tt])+";"   
        EndIf
	Next tt
	
	oProcess :cTo := cDest //aRet[1] //Array com o e-mail do aprovador
	oProcess :csubject := AllTrim( GetMV("ES_WFTITPR") ) + " " + cNumChave
	oProcess :Start()
	
	cTexto := "Enviando o E-mail WF."
	cCodStatus := "004130"
	oProcess:Track(cCodStatus, cTexto , cUsuSiga)
	
	cTexto := "Aguarde retorno..."
	cCodStatus := "004140"
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

Local cNumChave		:= oProcess:oHtml:RetByName("Z02_CHAVE") //Z02->(Z02_CHAVE+' '+Z02_NUMRES)   temos de tirar este espaço do meio....
Local cOpcao		:= oProcess:oHtml:RetByName("opcao")
Local cNivelUsr		:= oProcess:oHtml:RetByName("CR_NIVEL")
Local cUsuSiga		:= oProcess:oHtml:RetByName("CR_CODUSR")
Local cUsuAprov		:= oProcess:oHtml:RetByName("CR_APROVADOR")
Local cCodStatus	:= ""
Local cTexto		:= ""
Local cSeek			:= ""
Local cTitulo 		:= "Aprovação da Prestação de Contas"
Local cMailID		:= oProcess:oHtml:RetByName("CR_NUMPROC")
Local aRet			:= {}
Local lResid        :=.F.
Local cTipo			:= ""
Local cPc  			:= ""
Local cNivel		:= ""



cTexto := "Executando funcao de retorno"
cCodStatus := "004150"
oProcess:Track(cCodStatus, cTexto , cUsuSiga)

//+-----------------------------------------------------+
//| Verifica a alcada de Compras para reenviar o e-mail |
//| de acordo com a selecao do usuario no retorno do    |
//| formulario                                          |
//+-----------------------------------------------------+
cNumChave := SubStr(cNumChave,1,27) + SubStr(cNumChave,29)
If AllTrim( cOpcao ) == "1"//Se o usuario liberou o Pedido
	
	dbSelectArea("Z02")
	dbSetOrder(1)
	
	If dbSeek( xFilial("Z02")+cNumChave, .f. )
	
		

		cTipo := If(Z02->Z02_TPPA $ "1", "D1", "D2")
		
		cSeek := xFilial("SCR")
		cSeek += PadR( cTipo, TamSX3("CR_TIPO")[01] )
		cSeek += PadR( cNumChave, TamSX3("CR_NUM")[01] )
		cSeek += PadR( cNivelUsr, TamSX3("CR_NIVEL")[01] )
		
		cTipo := PadR( cTipo, TamSX3("CR_TIPO")[01] )
		cPc   := PadR( cNumChave, TamSX3("CR_NUM")[01] )
		cNivel:= PadR( cNivelUsr, TamSX3("CR_NIVEL")[01] )
		
		dbSelectArea("SCR")
		dbSetOrder(1)//CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
		If dbSeek( cSeek )
			Do While SCR->( !Eof() ) .and. SCR->CR_FILIAL	== xFilial( 'SCR' );
				.and. SCR->CR_NUM == cPc .and. SCR->CR_TIPO == cTipo .and. SCR->CR_NIVEL == cNivel

				RecLock("SCR",.F.)
				SCR->CR_STATUS	:= "03"
				SCR->CR_DATALIB	:= Date()
				SCR->CR_USERLIB	:= cUsuAprov
				SCR->CR_LIBAPRO	:= cUsuAprov
				SCR->(MsUnLock())

				SCR->( dbSkip() )
				
			Enddo
		EndIf
		//+----------------------------------+
		//| Altera o status do proximo nivel |
		//+----------------------------------+
		cNivelUsr := Soma1( cNivelUsr )
		cSeek := xFilial("SCR")
		cSeek += PadR( cTipo, TamSX3("CR_TIPO")[01] )
		cSeek += PadR( cNumChave, TamSX3("CR_NUM")[01] )
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
   		
		aRet := A040WfMail( cNumChave )
		
	EndIf
	
Else// Se nao liberou
	
	
	cSeek := xFilial("SCR")
	cSeek += PadR( cTipo, TamSX3("CR_TIPO")[01] )
	cSeek += PadR( cNumChave, TamSX3("CR_NUM")[01] )
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

If AllTrim( aRet[1] ) == "OK" .and. !aRet[4] //Se for ultimo nivel, liberar z02 e pagar...
	
	nCount:=0
		
		If AllTrim( cOpcao ) == "1"
			
			
			//Aqui vamos desbloquer a Z02
			cQuery := " UPDATE " +RetSQLName("Z02") + " "
			cQuery += " SET Z02_STATUS = '2' " //1=Bloqueado;2=Liberado
			cQuery += " WHERE Z02_FILIAL = '" + xFilial("Z02") + "'"
			cQuery += " AND Z02_CHAVE = '" + Z02->Z02_CHAVE + "'"
			cQuery += " AND Z02_NUMRES = '" + Z02->Z02_NUMRES + "'"
			cQuery += " AND D_E_L_E_T_= '' "
			
			nRet := TcSqlExec(cQuery)
			If nRet<>0
				Alert(TCSQLERROR())
				
	
			Else //Se deu certo update, 

				cQuery := " UPDATE " +RetSQLName("Z02") + " "
				cQuery += " SET Z02_STWF = '3' " //1=Não enviado;2=Enviado não aprovado;3=Aprovado                                                                                                                                                              
				cQuery += " WHERE Z02_FILIAL = '" + xFilial("Z02") + "'"
				cQuery += " AND Z02_CHAVE = '" + Z02->Z02_CHAVE + "'"
				cQuery += " AND Z02_NUMRES = '" + Z02->Z02_NUMRES + "'"
				cQuery += " AND D_E_L_E_T_= '' "
				nRet := TcSqlExec(cQuery)

				
				u_SCIF040(If(Z02->Z02_TPPA $ "1", "2", "3"))
			EndIf
					
			dbSelectArea("Z02")
			dbSetOrder(1)
			if nCount=0
				
				u_StaPR(Z02->(Z02_CHAVE+Z02_NUMRES),"L")     


				nCount=nCount+1
			endif
		Else
			
			if nCount=0
				u_StaPR(Z02->Z02_CHAVE+Z02->Z02_NUMRES,"B")
				nCount=nCount+1
			endif
			
		EndIf
		
		//
		//cTexto := "Atualizando Processo de Pagamento: " + cNumChave
		//cCodStatus := "004160"
		//oProcess:Track(cCodStatus, cTexto, oProcess:cRetFrom)
		//
	
Else
	
	//+---------------------------------------+
	//| Executa novamente o envio do Workflow |
	//+---------------------------------------+
	
	A040Alcada( cNumChave,cUsuSiga )
	
EndIf

cTexto := "Processo Finalizado"
cCodStatus := "004180"
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
Local aRet		    := A040WfMail( cNumChave )

cHtmlMod := AllTrim( GetMV("ES_WFHTMPR") )
cTitulo := "Aprovação do Pagamento Antecipado"

cTexto := "Executando Funcao de TIMEOUT..."
cCodStatus := "004190"
oProcess:Track(cCodStatus, cTexto)

cNumChave := oProcess:oHtml:ValByName("E2_NUM")
oProcess:Finish()

dbSelectArea("SE2")
dbSetOrder(1)
If dbSeek( xFilial("SE2") + cNumChave )
	
	oProcess:NewTask(cTitulo, cHtmlMod, .T.)
	
	If (Left(oProcess:cSubject,9) != "(REENVIO)")
		oProcess:cSubject := "(REENVIO)" + oProcess:cSubject
	EndIf
	
	//Aqio pode vir mais de uma linha de aprovador...devo juntar os mails do pessoal antes do envio...
	cDest := ""
	For tt:=1 to Len(aRet) Step 4
        If !Alltrim(aRet[tt]) $ cDest
	        cDest += Alltrim(aRet[tt])+";"   
        EndIf
	Next tt
	
	oProcess :cTo := cDest //aRet[1] //Array com o e-mail do aprovador
	//oProcess:cTo 		:= aRet[1]
	oProcess:UserSiga	:= WFCodUser("BI")
	oProcess:bReturn 	:= "U_SCIF011(1)"
	oProcess:bTimeOut	:= {"U_SCIF011(2)", nDias, nHoras, nMinutos}// Redefina a funcao de timeout a ser executada.
	
	cTexto := "Reenviando o Pagamento..."
	cCodStatus := "004200"
	oProcess:Track(cCodStatus, cTexto)
	oProcess:Start()		// Inicie o processo
	
Else
	
	cTexto := "Não foi possível encontrar o Pedido: " + cNumChave
	cCodStatus := "004170" // Codigo do cadastro de status de processo
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
Static Function  A040WfMail( cNumChave )

Local aRet		:= {"OK","","",.f.}
Local cQuery		:= ""
Local cAliasT		:= GetNextAlias()
Local cAliasA		:= GetNextAlias()


cNumChave := SubStr(cNumChave,1,27) + SubStr(cNumChave,29)

cQuery := " SELECT CR_NUM,"
cQuery += "        CR_USER,"
cQuery += "        CR_APROV,"
cQuery += "        CR_NIVEL,"
cQuery += "        CR_STATUS"
cQuery += " FROM " + RetSQLName("SCR")
cQuery += " WHERE CR_FILIAL	  = '" + xFilial("SCR") + "'"

If Z02->Z02_TPPA $ "1"
	cQuery += "   AND CR_TIPO	  = 'D1'"
Else
	cQuery += "   AND CR_TIPO	  = 'D2'"
EndIf

cQuery += "   AND CR_NUM     = '" + cNumChave + "'"
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


		//Se achou pelo menos 1 nivel, verifico se tem mais algum, senão é ultimo nivel devo liberar o registro na Z02 e pagar
		cQuery := " SELECT CR_NUM,"
		cQuery += "        CR_USER,"
		cQuery += "        CR_APROV,"
		cQuery += "        CR_NIVEL,"
		cQuery += "        CR_STATUS"
		cQuery += " FROM " + RetSQLName("SCR")
		cQuery += " WHERE CR_FILIAL	  = '" + xFilial("SCR") + "'"
		If Z02->Z02_TPPA $ "1"
			cQuery += "   AND CR_TIPO	  = 'D1'"
		Else
			cQuery += "   AND CR_TIPO	  = 'D2'"
		EndIf
		cQuery += "   AND CR_NUM     = '" + cNumChave + "'"
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
Static Function  A040Alcada( cNumChave,cUsuSiga )

Local nDias		:= 0
Local nHoras	:= 0
Local nMinutos	:= 10
Local nZ		:= 0
Local cCodProc 	:= "000004"
Local cCodStatus:= ""
Local cAssunto 	:= AllTrim( GetMV("ES_WFTITPR") ) + " " + cNumChave
Local cHtmlMod 	:= AllTrim( GetMV("ES_WFHTMPR") )
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

Local cVarAux1 := GetMV("MV_MOEDA" + cValToChar( SC7->C7_MOEDA ) )
Local cVarAux2 := GetMV("ES_WFLHTPA")
Local cVarAux3 := GetMV("ES_WFLINPA")
Local cVarAux4 := GetMV("ES_WFTITPR")

If	!lSetCentury
	__SetCentury("ON")
EndIf



aRet := A040WfMail( cNumChave )//Funcao para retornar o e-mail e o nivel do usuario aprovador

If !aRet[1] == "OK"// Se houver aprovadores envia o formulario
	
	cQuery1 := " SELECT CR_NUM,"
	cQuery1 += "        CR_USER,"
	cQuery1 += "        CR_APROV,"
	cQuery1 += "        CR_NIVEL,"
	cQuery1 += "        CR_STATUS"
	cQuery1 += " FROM " + RetSQLName("SCR")
	cQuery1 += " WHERE CR_FILIAL	  = '" + xFilial("SCR") + "'"
	cQuery1 += "   AND CR_TIPO	  = 'PA'"
	cQuery1 += "   AND CR_NUM     = '" + cNumChave + "'"
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
		
		cCodStatus := "004100"
		cTexto := "Iniciando o processamento da " + cAssunto + " do Código: " + cNumChave
		oProcess:Track(cCodStatus, cTexto, cUsuSiga)
		
		cTexto := "Gerando Pedido para envio..."
		cCodStatus := "004110"
		oProcess:Track(cCodStatus, cTexto, cUsuSiga)
		
		dbSelectArea("SE2")
		dbSetOrder(1)
		If dbSeek( xFilial("SE2") + cNumChave )
			
			oProcess:oHtml:ValByName( "C7_NUM"		, SC7->C7_NUM )
			oProcess:oHtml:ValByName( "C7_EMISSAO"	, SC7->C7_EMISSAO )
			oProcess:oHtml:ValByName( "C7_FORNECE"	, SC7->C7_FORNECE + " / " + SC7->C7_LOJA )
			
			dbSelectArea("SA2")
			dbSetOrder(1)//A2_FILIAL+A2_COD+A2_LOJA
			If dbSeek( xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA )
				oProcess:oHtml:ValByName( "C7_NOME"	, SA2->A2_NOME )
			EndIf
			
			oProcess:oHtml:ValByName( "C7_MOEDA" , cVarAUx1 )
			
			dbSelectArea("SC1")
			dbSetOrder(1)//C1_FILIAL+C1_NUM+C1_ITEM
			If dbSeek( xFilial("SC1") + SC7->C7_NUMSC + SC7->C7_ITEMSC )
				oProcess:oHtml:ValByName( "C1_USER"	 , Capital( RtFullName( SC1->C1_USER ) ) )
			Endif
			
			oProcess:oHtml:ValByName( "C7_NUMSC" , SC7->C7_NUMSC )
			oProcess:oHtml:ValByName( "C7_FILENT", SC7->C7_FILENT )
			
			dbSelectArea("SM0")
			oProcess:oHtml:ValByName( "C7_FILIAL" 	, AllTrim( SM0->M0_CODFIL ) )
			
			If !Empty( cObsPed )
				aAdd( oProcess:oHtml:ValByName("B.C7_OBSM"), cObsPed )
			Else
				aAdd( oProcess:oHtml:ValByName("B.C7_OBSM"), "" )
			EndIf
			
			oProcess:oHtml:ValByName( "C7_PCTOTAL"	 , Transform( nValTotal, PesqPict("SC7","C7_TOTAL") ) )
			oProcess:oHtml:ValByName( "C7_NIVEL"	 , ( cAliasL )->CR_NIVEL )
			oProcess:oHtml:ValByName( "C7_CODUSR"	 , cUsuSiga )
			oProcess:oHtml:ValByName( "C7_APROVADOR", ( cAliasL )->CR_USER )
			
		EndIf
		
		oProcess:cSubject := cAssunto
		oProcess:cTo := "siga"
		oProcess:UserSiga	:= WFCodUser("BI")
		
		oProcess:bReturn	:= "U_SCIF011(1)"
		oProcess:bTimeOut	:= {"U_SCIF011(2)", nDias, nHoras, nMinutos}
		cTexto := "Enviando Pagamento Antecipado..."
		cCodStatus := "004120"
		oProcess:Track(cCodStatus, cTexto , cUsuSiga)
		cMailID := oProcess:Start()
		
		// Envia o Numero do Processo para o formulario para ser solicitado no retorno
		oProcess:oHtml:ValByName( "C7_NUMPROC" , cMailID )
		
		oProcess :NewTask(cTitulo, AllTrim( cVarAux2 ) )
		oProcess :ohtml:ValByName("titulo", "Aprovação de Pagamento Antecipado - Internacional" )
		oProcess :ohtml:ValByName("paragrafo", "Pedido incluído pelo usuário" )
		oProcess :ohtml:ValByName("nome_usuario", Capital( RtFullName( cUsuSiga ) ) )
		
		oProcess :ohtml:ValByName("frase_link", "Clique no número do Pagamento Antecipado para mais detalhes: " )
		oProcess :ohtml:ValByName("cod_sc", cNumChave )
		oProcess :ohtml:ValByName("proc_link", AllTrim( cVarAux3 ) + "messenger/emp" +cEmpAnt + "/siga/" + cMailID + ".htm" )
		cQliberou:=""
		cQliberou:=Alltrim(cQLibPC( cNumChave ))
		if cQliberou<>""
			oProcess :ohtml:ValByName("liberadopor","Quem já aprovou este pedido: "+cQliberou)
		endif
		oProcess :cTo := AllTrim( UsrRetMail(( cAliasL )->CR_USER ) ) //Array com o e-mail do aprovador
		oProcess :csubject := AllTrim( cVarAux4 ) + " " + cNumChave
		oProcess :Start()
		
		cTexto := "Enviando o E-mail WF."
		cCodStatus := "004130"
		oProcess:Track(cCodStatus, cTexto , cUsuSiga)
		
		cTexto := "Aguarde retorno..."
		cCodStatus := "004140"
		oProcess:Track(cCodStatus, cTexto , cUsuSiga)
		
		( cAliasL )->( dbSkip() )
	Enddo
	
	( cAliasL )->( dbCloseArea() )
	
EndIf

Return


Static Function  cQLibPC( cNumChave )

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
cQuery += "   AND CR_NUM      = '" + cNumChave + "'"
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


User Function S99AConhe(cNumChave,oProcess)

Local cQry     := ""
Local cAliasA  := GetNextAlias()
Local cLogoAnx := ""
Local cAnex    := "http://aprovacaop.internacional.net.br:9191/workflow/dirdoc/co01/shared/"
Local cImgRoot := "http://aprovacaop.internacional.net.br:9191/workflow/img-workflow/"
Local cLocFile :="\workflow\dirdoc\co01\shared\"
Local cDoc	   :=""
Local a        := 0
Local nCont    := 0
Local aExt     := {}
Local nSize    := 0
Local cImg     := ''
Local aRetFile := {'',''}
Local cGetFile := ""
Local cFile    := ""
Local cExten   := ""
Local cScs     := ""


cQry := " SELECT 	ACB_OBJETO,"
cQry += " 			ACB_DESCRI "

cQry += " FROM "+ RetSqlName("AC9") +" AC9 "
cQry += " INNER JOIN "+ RetSqlName("ACB") +" ACB "
cQry += "	ON  AC9.AC9_FILIAL = ACB.ACB_FILIAL "
cQry += "	AND AC9.AC9_CODOBJ = ACB.ACB_CODOBJ "
cQry += "	AND ACB.D_E_L_E_T_ <> '*' "

cQry += " WHERE AC9.AC9_FILENT = '"+ PADR( xFilial("SE2"), TAMSX3("E2_FILIAL")[1]) + "' "
cQry += "	AND SUBSTRING(AC9.AC9_CODENT,1,41) = '" + cNumChave + "' "
cQry += "	AND AC9.AC9_ENTIDA IN ('Z02') "
cQry += "	AND AC9.D_E_L_E_T_ <> '*' "

cQry := ChangeQuery( cQry )


dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQry),cAliasA,.F.,.T. )
While ( cAliasA )->( !Eof() )
	
	cGetFile := AllTrim( ( cAliasA )->(ACB_OBJETO) )
	SplitPath( cGetFile, , , @cFile, @cExten )
	
	cNameTerm := cFile + cExten
	cNameServ := cNameTerm
	
	cDirDocs := MsDocPath()
	
	
	If File( Alltrim(cDirDocs) + "\" + cNameServ )
		
		nCont++
		
		do case
			case UPPER(cExten) == '.PDF'
				cImg := "<img src='"+cImgRoot+"pdf-icon.png' style='padding:0px 1px 0px 0px;'>"
			case UPPER(cExten) == '.TXT'
				cImg := "<img src='"+cImgRoot+"txt-icon.png' style='padding:0px 1px 0px 0px;'>"
			case UPPER(cExten) == '.XLS'
				cImg := "<img src='"+cImgRoot+"xls-icon.png' style='padding:0px 1px 0px 0px;'>"
			case UPPER(cExten) == '.DOC'
				cImg := "<img src='"+cImgRoot+"doc-icon.png' style='padding:0px 1px 0px 0px;'>"
			case UPPER(cExten) == '.JPG'
				cImg := "<img src='"+cImgRoot+"jpg-icon.png' style='padding:0px 1px 0px 0px;'>"
			case UPPER(cExten) == '.JPEG'
				cImg := "<img src='"+cImgRoot+"jpeg-icon.png' style='padding:0px 1px 0px 0px;'>"
			case UPPER(cExten) == '.PNG'
				cImg := "<img src='"+cImgRoot+"png-icon.png' style='padding:0px 1px 0px 0px;'>"
			case UPPER(cExten) == '.DOCX'
				cImg := "<img src='"+cImgRoot+"docx-icon.png' style='padding:0px 1px 0px 0px;'>"
			case UPPER(cExten) == '.CSV'
				cImg := "<img src='"+cImgRoot+"csv-icon.png' style='padding:0px 1px 0px 0px;'>"
			case UPPER(cExten) == '.PPT'
				cImg := "<img src='"+cImgRoot+"ppt-icon.png' style='padding:0px 1px 0px 0px;'>"
			case UPPER(cExten) == '.XLSX'
				cImg := "<img src='"+cImgRoot+"xlsx-icon.png' style='padding:0px 1px 0px 0px;'>"
			otherwise
				cImg := "<img src='"+cImgRoot+"no-file.png' style='padding:0px 1px 0px 0px;'>"
		EndCase
		
		
		//nSize := RetSize(Alltrim(cDirDocs) + "\" + cNameServ)
		nSize := Len(Alltrim(cDirDocs) + "\" + cNameServ)
		
		cDoc +="<span style='padding:5px;'>
		
		If !Empty(cImg)
			
			cDoc += cImg
			
		EndIf
		
		cDoc +="	<b id='anexo_item'><a href='"+cAnex+cNameServ+"' download='"+cNameServ+"' style='font-size: 14px;'>
		cDoc +="		Anexo "+cValToChAR(nCont)+" "+ IIF(nSize > 0 ,"("+cValToChar(round(nSize/1000,0))+" KB)",'')+"</a> "
		//cDoc  +=" 	"+( cAliasA )->(ACB_OBJETO)+"</a> "
		cDoc +="	</b>"
		cDoc +="</span>"
		
	EndIf
	
	( cAliasA )->( dbSkip() )
	
Enddo

( cAliasA )->( dbCloseArea() )

//oProcess:oHtml:ValByName( "ANEXOS", cDoc )
aDocs := {}


Return(cDoc)


//+-------------------------------------------------+
//| Funcao para retornar o nome completo do usuario |
//| Denis - 02/12/2019                              |
//+-------------------------------------------------+
Static Function RtFullName( cCodUser )
	
	Local cRet := ""
	
	cRet := UsrFullName( cCodUser )
	
Return( cRet )