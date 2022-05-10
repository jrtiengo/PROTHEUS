#Include "Totvs.ch"
#Include "fileio.Ch"
#Include "TbiConn.ch"

//ARRAY RETORNO DO WORKFLOW ITENS

#DEFINE NUMPC 01 // NUMERO PEDIDO
#DEFINE ITEPC 02 // ITEM PEDIDO
#DEFINE PROPC 03 // PRODUTO PEDIDO
#DEFINE UNMPC 04 // UNIDADE MEDIDA
#DEFINE QUANT 05 // QUANTIDAD
#DEFINE PRECO 06 // PRECO
#DEFINE TOTAL 07 // VALOR TOTAL
#DEFINE DATPR 08 // DATA PREVISTA
#DEFINE CECPC 09 // CENTRO DE CUSTO
#DEFINE SEQPC 10 // SEQUENCIA PEDIDO
#DEFINE CONPG 11 // CONDICAO DE PAGAMENTO


/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � SCI99A   � Autor �  Ednei Silva          � Data �29/06/2017���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao que envia o E-mail de Workflow na inclusao de       ���
���          � Pedido de Compra - Essa funcao e chamada pelo Ponto		  ���
���          � de Entrada MT120GRV                                        ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � U_SCI99A( nOpcao,oProcess )                                ���
�������������������������������������������������������������������������Ĵ��
���Parametros� nOpcao = Opcao chamada pelo Retorno do Workflow            ���
���          � oProcess = Objeto utilizado pelas funcoes de Workflow      ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico Cliente Internacional                           ���
�������������������������������������������������������������������������Ĵ��
���                          ULTIMAS ALTERACOES                           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
User Function SCI99A( nOpcao,oProcess )

Default nOpcao := 0

FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " Opcao:" + cValToChar( nOpcao ) , 0, 0, {}) 

Do Case
	Case nOpcao == 0
		A040Inicio( SC7->C7_NUM )
	Case nOpcao == 1
		A040Retorno( oProcess )
	Case nOpcao == 2
		A040TimeOut( oProcess )
EndCase

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A040INICIO� Autor � Ednei Silva           � Data �29/06/2017���
�������������������������������������������������������������������������Ĵ��
���Descricao � Esta funcao e responsavel por iniciar a criacao do         ���
���          � processo e por enviar a mensagem para o destinatario       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A040INICIO( cNumPC )                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� cNumPC = Numero da Filial e Pedido posicionado no PE       ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico Cliente Internacional                           ���
�������������������������������������������������������������������������Ĵ��
���                          ULTIMAS ALTERACOES                           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function A040Inicio( cFilPC  )

Local nDias		 := 0
Local nHoras	 := 0
Local nMinutos	 := 10
Local nZ		 := 0
Local cCodProc   := "000002"
Local cCodStatus := ""
Local cNumPC	 := cFilPC
Local cAssunto   := AllTrim( GetMV("ES_WFTITPC") ) + " " + cNumPC
Local cHtmlMod 	 := AllTrim( GetMV("ES_WFHTMLC") )
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
Local aDocs      := {}
Local lEnv       := .F.
//Local aObsPed	 := {}
Local cObsPed	 := ""

Local nDescProd := 0
Local nFrtPC    := 0
If (lIsAPW)
	cRet := "Iniciado com StartWebEX ou StartWeb"
Else
	cRet := "Chamado Via APL"
EndIf

FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " A040Inicio - Tipo Retorno " + cRet , 0, 0, {}) 
FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " A040Inicio - Processando Pedido " + cNumPC , 0, 0, {}) 

aRet := A040WfMail( cNumPC )//Funcao para retornar o e-mail e o nivel do usuario aprovador

//aadd(aRet,'samuel.schneider@totvs.com.br')
//aadd(aRet,'1')
//aadd(aRet,__cUserId)

If !aRet[1] == "OK"// Se nao tiver aprovadores nao gera o formulario

	oProcess := TWFProcess():New(cCodProc, cAssunto)
	oProcess:NewTask(cTitulo, cHtmlMod)
	oHtml	:= oProcess:oHtml

	cCodStatus := "002100"
	cTexto := "Iniciando o processamento da " + cAssunto + " do Codigo: " + cNumPC
	oProcess:Track(cCodStatus, cTexto, cUsuSiga)

	cTexto := "Gerando Pedido para envio..."
	cCodStatus := "002110"
	oProcess:Track(cCodStatus, cTexto, cUsuSiga)


	dbSelectArea("SC7")
	dbSetOrder(1)//C7_FILIAL+C7_NUM+C7_ITEM+C1_SEQUEN
	If dbSeek( xFilial("SC7") + cNumPC )

		oProcess:oHtml:ValByName( "C7_NUM"		, SC7->C7_NUM )
		oProcess:oHtml:ValByName( "C7_EMISSAO"	, SC7->C7_EMISSAO )
		oProcess:oHtml:ValByName( "C7_FORNECE"	, SC7->C7_FORNECE + " / " + SC7->C7_LOJA )

		dbSelectArea("SA2")
		dbSetOrder(1)//A2_FILIAL+A2_COD+A2_LOJA
		If dbSeek( xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA )
			oProcess:oHtml:ValByName( "C7_NOME"	, SA2->A2_NOME )
		EndIf

		oProcess:oHtml:ValByName( "C7_MOEDA"	, GetMV("MV_MOEDA" + cValToChar( SC7->C7_MOEDA ) ) )

		dbSelectArea("SC1")
		dbSetOrder(1)//C1_FILIAL+C1_NUM+C1_ITEM
		If dbSeek( xFilial("SC1") + SC7->C7_NUMSC + SC7->C7_ITEMSC )
			oProcess:oHtml:ValByName( "C1_USER"	 , Capital( RtFullName( SC1->C1_USER ) ) )
		Endif
		oProcess:oHtml:ValByName( "C7_NUMSC"	, SC7->C7_NUMSC )
		oProcess:oHtml:ValByName( "C7_FILENT"	, SC7->C7_FILENT )

		dbSelectArea("SM0")
		oProcess:oHtml:ValByName( "C7_FILIAL" 	, AllTrim( SM0->M0_CODFIL ) )

		//Busca Documentos do Banco de conhecimento

		cQuery := " SELECT C7_ITEM,"
		cQuery += "        C7_PRODUTO,"
		cQuery += "        C7_DESCRI,"
		cQuery += "        C7_QUANT,"
		cQuery += "        C7_UM,"
		cQuery += "        C7_PRECO,"
		cQuery += "        C7_TOTAL,"
		cQuery += "        C7_DATPRF,"
		cQuery += "        C7_CC,"
        cQuery += "        C7_COND,"
        cQuery += "        C7_NUM,"
        cQuery += "        C7_NUMSC,"
        cQuery += "        C7_ITEMSC,"
        cQuery += "        C7_SEQUEN,"
        cQuery += "        C7_DTHRENV,"
         cQuery += "        C7_DTHRALT,"
         cQuery += "        C7_DESC1,"
         cQuery += "        C7_DESC2,"
         cQuery += "        C7_DESC3,"
         cQuery += "        C7_TOTAL,"
         cQuery += "        C7_VALFRE,"
         cQuery += "        C7_VLDESC,"
        cQuery += "		   ISNULL( CONVERT( VARCHAR(8000), CONVERT(BINARY(8000), C7_OBSM ) ), '' ) C7_OBSM"
        cQuery += " FROM " + RetSQLName("SC7")
		cQuery += " WHERE C7_FILIAL = '" + xFilial("SC7") + "'"
		cQuery += "   AND C7_NUM = '" + cNumPC + "'"
		cQuery += "   AND D_E_L_E_T_<> '*'"
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery ),cAliasT,.F.,.T. )

		While ( cAliasT )->( !Eof() )

			aAdd( ( oProcess:oHtml:ValByName( "A.C7_ITEM" ) ) 	, cValtoChar(val(( cAliasT )->C7_ITEM )))
			aAdd( ( oProcess:oHtml:ValByName( "A.C7_PRODUTO" ) ), ( cAliasT )->C7_PRODUTO )
			aAdd( ( oProcess:oHtml:ValByName( "A.C7_DESCRI" ) ) , AllTrim( ( cAliasT )->C7_DESCRI ) )
			aAdd( ( oProcess:oHtml:ValByName( "A.C7_UM" ) ) 	, ( cAliasT )->C7_UM )
			aAdd( ( oProcess:oHtml:ValByName( "A.C7_QUANT" ) ) 	, ( cAliasT )->C7_QUANT )
			aAdd( ( oProcess:oHtml:ValByName( "A.C7_PRECO" ) ) 	, Transform( ( cAliasT )->C7_PRECO , PesqPict("SC7","C7_PRECO") ) )
			aAdd( ( oProcess:oHtml:ValByName( "A.C7_TOTAL" ) ) 	, Transform( ( cAliasT )->C7_TOTAL , PesqPict("SC7","C7_TOTAL") ) )
			aAdd( ( oProcess:oHtml:ValByName( "A.C7_DATPRF" ) ) , DtoC( StoD( ( cAliasT )->C7_DATPRF ) ) )
			aAdd( ( oProcess:oHtml:ValByName( "A.C7_CC" ) ) 	, ( cAliasT )->C7_CC )
			aAdd( ( oProcess:oHtml:ValByName( "A.C7_SEQUEN" ) ) , ( cAliasT )->C7_SEQUEN )
			aAdd( ( oProcess:oHtml:ValByName( "A.C7_COND" ) )   , ( cAliasT )->C7_COND )

			dbSelectArea("CTT")
			dbSetOrder(1)//CTT_FILIAL+CTT_CUSTO
			If dbSeek( xFilial("CTT") + ( cAliasT )->C7_CC  )
				aAdd( ( oProcess:oHtml:ValByName( "A.C7_DESCCC" ) ) , AllTrim( CTT->CTT_DESC01 ) )
			Else
				aAdd( ( oProcess:oHtml:ValByName( "A.C7_DESCCC" ) ) , "" )
			EndIf

			dbSelectArea("SE4")
 			dbSetOrder(1)//SE4_FILIAL+SE4_CODIGO
 			If dbSeek( xFilial("SE4") + ( cAliasT )->C7_COND  )
				cCondPgto := AllTrim( ( cAliasT )->C7_COND ) +"-"+ AllTrim( SE4->E4_DESCRI )
 			Else
 				cCondPgto := ""
 			EndIf

			If !Empty( ( cAliasT )->C7_OBSM )
				cObsPed += AllTrim( ( cAliasT )->C7_OBSM ) //NoAcento( AllTrim( ( cAliasT )->C7_OBSM ) )
				cObsPed += '<br>'
			EndIf

			nValTotal += ( cAliasT )->C7_TOTAL
			nFrtPC    += ( cAliasT )->C7_VALFRE
			If ( cAliasT )->C7_DESC1 != 0 .Or. ( cAliasT )->C7_DESC2 != 0 .Or. ( cAliasT )->C7_DESC3 != 0
				nDescProd+= CalcDesc(( cAliasT )->C7_TOTAL,( cAliasT )->C7_DESC1,( cAliasT )->C7_DESC2,( cAliasT )->C7_DESC3)
			Else
				nDescProd+=( cAliasT )->C7_VLDESC
			Endif
            /*
			Aadd(aDocs,{SC7->C7_FILIAL+( cAliasT )->C7_NUM+( cAliasT )->C7_ITEM,; //CHAVE SC7
						SC7->C7_FILIAL+( cAliasT )->C7_NUMSC+( cAliasT )->C7_ITEMSC,;                    //CHAVE SC1
						( cAliasT )->C7_NUMSC,;
						( cAliasT )->C7_ITEMSC})
            */

		     If !Empty(( cAliasT )->C7_DTHRALT)
				lEnv:=.T.
		     EndIf
		     u_AtuEnvio(( cAliasT )->C7_NUM,( cAliasT )->C7_ITEM,( cAliasT )->C7_SEQUEN,lEnv)


			( cAliasT )->( dbSkip() )

		EndDo

		( cAliasT )->( dbCloseArea() )

		oProcess:oHtml:ValByName( "C7_DESPAG"	, cCondPgto )
		oProcess:oHtml:ValByName( "C7_DESPESA"	, Transform( SC7->C7_DESPESA, PesqPict("SC7","C7_DESPESA") ) )
		//oProcess:oHtml:ValByName( "C7_FRETE"	, Transform( SC7->C7_FRETE  , PesqPict("SC7","C7_FRETE") ) )
		oProcess:oHtml:ValByName( "C7_FRETE"	, Transform( nFrtPC  , PesqPict("SC7","C7_FRETE") ) )
		oProcess:oHtml:ValByName( "nC7_VLDESC"	, Transform( nDescProd, PesqPict("SC7","C7_VLDESC") ) )

		If !Empty( cObsPed )
			aAdd( oProcess:oHtml:ValByName("B.C7_OBSM"), cObsPed )
		Else
			aAdd( oProcess:oHtml:ValByName("B.C7_OBSM"), "" )
		EndIf

		If lEnv
			oProcess:oHtml:ValByName( "REENVIO"	, "<b>(REENVIO)</b>" )
		Else
			oProcess:oHtml:ValByName( "REENVIO"	, "" )
		EndIf
		oProcess:oHtml:ValByName( "C7_PCTOTAL"	, Transform( nValTotal, PesqPict("SC7","C7_TOTAL") ) )
		oProcess:oHtml:ValByName( "nTotGeral"	, Transform( nValTotal+SC7->C7_DESPESA+nFrtPC-nDescProd, PesqPict("SC7","C7_TOTAL") ) )
		oProcess:oHtml:ValByName( "C7_NIVEL"	, aRet[2] )
		oProcess:oHtml:ValByName( "C7_CODUSR"	, cUsuSiga )
		oProcess:oHtml:ValByName( "C7_APROVADOR", aRet[3] )

		S99AConhe(cNumPC,oProcess)


	EndIf

	oProcess:cSubject := cAssunto
	oProcess:cTo := "siga"
	oProcess:UserSiga := WFCodUser("BI")

	oProcess:bReturn := "U_SCI99A(1)"
	oProcess:bTimeOut := {"U_SCI99A(2)", nDias, nHoras, nMinutos}
	cTexto := "Enviando Pedido de Compra..."
	cCodStatus := "002120"
	oProcess:Track(cCodStatus, cTexto , cUsuSiga)
	cMailID := oProcess:Start()

	// Envia o Numero do Processo para o formulario para ser solicitado no retorno
	oProcess:oHtml:ValByName( "C7_NUMPROC" , cMailID )

	oProcess :NewTask(cTitulo, AllTrim( GetMV("ES_WFLHTML") ) )
	oProcess :ohtml:ValByName("titulo", "Aprova��o de Pedido de Compra - Internacional" )
	oProcess :ohtml:ValByName("paragrafo", "Pedido inclu�do pelo usu�rio" )
	oProcess :ohtml:ValByName("nome_usuario", Capital( RtFullName( cUsuSiga ) ) )
	oProcess :ohtml:ValByName("frase_link", "Clique no n�mero do Pedido de Compra para mais detalhes: " )
	oProcess :ohtml:ValByName("cod_sc", cNumPC )
	oProcess :ohtml:ValByName("proc_link", AllTrim( GetMV("ES_WFLINK") ) + "messenger/emp" +cEmpAnt + "/siga/" + cMailID + ".htm" )
	
	cQliberou:=""
	cQliberou:=Alltrim(cQLibPC( cNumPC ))
	if cQliberou<>""
		oProcess :ohtml:ValByName("liberadopor","Quem j� aprovou este pedido: "+cQliberou)
	endif
	
	oProcess :cTo := aRet[1] //Array com o e-mail do aprovador
	oProcess :csubject := AllTrim( GetMV("ES_WFTITPC") ) + " " + cNumPC
	oProcess :Start()

	cTexto := "Enviando o E-mail WF."
	cCodStatus := "002130"
	oProcess:Track(cCodStatus, cTexto , cUsuSiga)

	cTexto := "Aguarde retorno..."
	cCodStatus := "002140"
	oProcess:Track(cCodStatus, cTexto , cUsuSiga)

EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A040RETORNO � Autor � Ednei Silva         �Data �29/06/2016 ���
�������������������������������������������������������������������������Ĵ��
���Descricao � Esta funcao e executada no retorno da mensagem enviada     ���
���          � pelo destinatario. O Workflow recria o processo em que     ���
���          � parou anteriormente na funcao A040Inicio e repassa a       ���
���          � variavel objeto oProcess por parametro.                    ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �  A040Retorno(oProcess)                                     ���
�������������������������������������������������������������������������Ĵ��
���Parametros� oProcess = Objeto do Workflow                              ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � String 		                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico Cliente Internacional  						  ���
�������������������������������������������������������������������������Ĵ��
���                          ULTIMAS ALTERACOES                           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/
Static Function A040Retorno(oProcess)

Local cNumPC		:= oProcess:oHtml:RetByName("C7_NUM")
Local cObs			:= oProcess:oHtml:RetByName("C7_OBS")
Local cOpcao		:= oProcess:oHtml:RetByName("opcao")
Local cNivelUsr		:= oProcess:oHtml:RetByName("C7_NIVEL")
Local cUsuSiga		:= oProcess:oHtml:RetByName("C7_CODUSR")
Local cUsuAprov		:= oProcess:oHtml:RetByName("C7_APROVADOR")
Local cCodStatus	:= ""
Local cTexto		:= ""
Local cSeek			:= ""
Local cTitulo 		:= "Aprova��o do Pedido de Compra"
Local cMailID		:= oProcess:oHtml:RetByName("C7_NUMPROC")
Local aRet			:= {}
Local lResid        :=.F.
Local cTipo			:= ""
Local cPc  			:= ""
Local cNivel		:= ""
Local nLoop         :=""
Local nQtdRet       := oProcess:oHtml:RetByName("A.C7_ITEM")
Local aRetWF        := {}

FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " Executando o RETORNO" , 0, 0, {}) 


	If Len(nQtdRet) > 0

		For nLoop := 1 To len(nQtdRet)

			Aadd(aRetWF,{cNumPC,;
						 oProcess:oHtml:RetByName("A.C7_ITEM")[nLoop],;
						 oProcess:oHtml:RetByName("A.C7_PRODUTO")[nLoop],;
						 oProcess:oHtml:RetByName("A.C7_UM")[nLoop],;
						 oProcess:oHtml:RetByName("A.C7_QUANT")[nLoop],;
						 oProcess:oHtml:RetByName("A.C7_PRECO")[nLoop],;
						 oProcess:oHtml:RetByName("A.C7_TOTAL")[nLoop],;
						 oProcess:oHtml:RetByName("A.C7_DATPRF")[nLoop],;
						 oProcess:oHtml:RetByName("A.C7_CC")[nLoop],;
						 oProcess:oHtml:RetByName("A.C7_SEQUEN")[nLoop],;
						 oProcess:oHtml:RetByName("A.C7_COND")[nLoop]})
		Next nLoop

		If len(aRetWF) > 0

			If PedidoOK(aRetWF)

				FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " PEDIDO OK"  , 0, 0, {}) 

				cTexto := "Executando funcao de retorno"
				cCodStatus := "002150"
				oProcess:Track(cCodStatus, cTexto , cUsuSiga)

				//+-----------------------------------------------------+
				//| Verifica a alcada de Compras para reenviar o e-mail |
				//| de acordo com a selecao do usuario no retorno do    |
				//| formulario                                          |
				//+-----------------------------------------------------+
				If AllTrim( cOpcao ) == "1"//Se o usuario liberou o Pedido

					cSeek := xFilial("SCR")
					cSeek += PadR( "PC", TamSX3("CR_TIPO")[01] )
					cSeek += PadR( cNumPC, TamSX3("CR_NUM")[01] )
					cSeek += PadR( cNivelUsr, TamSX3("CR_NIVEL")[01] )

					cTipo := PadR( "PC", TamSX3("CR_TIPO")[01] )
					cPc   := PadR( cNumPC, TamSX3("CR_NUM")[01] )
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
					cSeek += PadR( "PC", TamSX3("CR_TIPO")[01] )
					cSeek += PadR( cNumPC, TamSX3("CR_NUM")[01] )
					cSeek += PadR( cNivelUsr, TamSX3("CR_NIVEL")[01] )

					dbSelectArea("SCR")
					dbSetOrder(1)//CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
					If dbSeek( cSeek )

						RecLock("SCR",.F.)
						SCR->CR_STATUS	:= "01"
						MsUnLock()

					EndIf

					//+---------------------------------------------------+
					//| Funcao para retornar o e-mail e o nivel do usuario|
					//| aprovador caso ainda existam niveis a aprovar     |
					//+---------------------------------------------------+
					aRet := A040WfMail( cNumPC )

				Else// Se nao liberou


					cSeek := xFilial("SCR")
					cSeek += PadR( "PC", TamSX3("CR_TIPO")[01] )
					cSeek += PadR( cNumPC, TamSX3("CR_NUM")[01] )
					cSeek += PadR( cNivelUsr, TamSX3("CR_NIVEL")[01] )

					dbSelectArea("SCR")
					dbSetOrder(1)//CR_FILIAL+CR_TIPO+CR_NUM+CR_NIVEL
					If dbSeek( cSeek )


						RecLock("SCR",.F.)
						SCR->CR_STATUS	:= "04"
						SCR->CR_DATALIB	:= Date()
						SCR->CR_OBSERV	:= cObs
						MsUnLock()


					//	dbSelectArea("SC7")
				    //  	dbSetOrder(1)// C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
				    //	If dbSeek( xFilial("SC7") + cNumPC )  .and. SCR->CR_STATUS = "04"

						cUpDate := " UPDATE " + RetSqlName("SC7")
						//cUpDate += " SET C7_CONAPRO = '2'"
						cUpDate += " SET C7_CONAPRO='R'" //Valdir em 15/05/2019
						cUpDate += " FROM " + RetSqlName("SC7")+" SC7 "
						cUpDate += "  INNER JOIN "+RETSQLNAME("SCR")+" SCR ON (C7_FILIAL=SCR.CR_FILIAL and C7_NUM=SCR.CR_NUM) "
						cUpDate += " WHERE C7_FILIAL='" + xFilial("SC7") + "'"
						cUpDate += "  AND C7_TIPO=1 "
						cUpDate += "  AND SCR.CR_STATUS='04' "
						cUpDate += "  AND SC7.D_E_L_E_T_<>'*' "
						cUpDate += "  AND SCR.D_E_L_E_T_<>'*' "
				
						FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " Executanto UPDATE " + cUpDate , 0, 0, {}) 
				
						If TcSqlExec( cUpDate ) < 0
							FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " TCSQLError() " + TCSQLError() , 0, 0, {}) 

				        Else
							FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " TCSQLError() OK" , 0, 0, {}) 
						EndIf

					//    EndIf
					EndIf

					aAdd( aRet, "OK")
					aAdd( aRet, "")
					aAdd( aRet, "")

				EndIf

				If AllTrim( aRet[1] ) == "OK"
					nCount:=0
					dbSelectArea("SC7")
					dbSetOrder(1)// C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
					If dbSeek( xFilial("SC7") + cNumPC )

						While SC7->( !Eof() ) .And. AllTrim( SC7->C7_NUM ) == AllTrim( cNumPC )

							If AllTrim( cOpcao ) == "1"

								RecLock( "SC7", .F. )
								SC7->C7_CONAPRO := "L"
								MsUnLock()
								if nCount=0
									U_StatuEmail(SC7->C7_NUM,"L")
									nCount=nCount+1
								endif
							Else

								RecLock( "SC7", .F. )
								//SC7->C7_CONAPRO:="B"
								SC7->C7_CONAPRO:="R" //Valdir em 16/05/2019
								SC7->C7_OBS    :=cObs
								//	SC7->C7_RESIDUO:='S'
								//	SC7->C7_ENCER  :='E'
								//	lResid:=.T.
								MsUnLock()

								if nCount=0
									U_StatuEmail(SC7->C7_NUM,"B")
									nCount=nCount+1
								endif

							EndIf

							SC7->( dbSkip() )

						EndDo

						cTexto := "Atualizando Pedido de Compra: " + cNumPC
						cCodStatus := "002160"
						oProcess:Track(cCodStatus, cTexto, oProcess:cRetFrom)

					Else

						cTexto := "N�o foi poss�vel encontrar o Pedido: " + cNumPC
						cCodStatus := "002170"
						oProcess:Track(cCodStatus, cTexto, oProcess:cRetFrom)

					EndIf

				Else

					//+---------------------------------------+
					//| Executa novamente o envio do Workflow |
					//+---------------------------------------+
					FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " Executando o envio para outro aprovador"  , 0, 0, {}) 

					A040Alcada( cNumPC,cUsuSiga )

				EndIf

				cTexto := "Processo Finalizado"
				cCodStatus := "002180"
				oProcess:Track(cCodStatus, cTexto, oProcess:cRetFrom)

			Else
				FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " Pedido n�o OK"  , 0, 0, {}) 

			EndIf
		Endif
	EndIf
Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A040TIMEOUT� Autor � Ednei Silva           �Data �29/06/2017���
�������������������������������������������������������������������������Ĵ��
���Descricao � Esta funcao sera executada a partir do Scheduler no tempo  ���
���          � estipulado pela propriedade :bTimeout da classe TWFProcess.���
���          � Caso o processo tenha sido respondido em tempo habil, essa ���
���          � execucao sera descartada automaticamente.                  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Parametros�                                                            ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico Cliente Interncaional                           ���
�������������������������������������������������������������������������Ĵ��
���                          ULTIMAS ALTERACOES                           ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � Motivo da Alteracao                             ���
�������������������������������������������������������������������������Ĵ��
���            �        �                                                 ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function A040TimeOut(oProcess)

Local nDias  		:= 0
Local nHoras 		:= 0
Local nMinutos	    := 10
Local cCodStatus	:= ""
Local cHtmlMod	    := ""
Local cTexto		:= ""
Local cTitulo		:= ""
Local aRet		    := A040WfMail( cNumPC )

cHtmlMod := AllTrim( GetMV("ES_WFHTMLC") )
cTitulo := "Aprova��o do Pedido de Compra"

cTexto := "Executando Funcao de TIMEOUT..."
cCodStatus := "002190"
oProcess:Track(cCodStatus, cTexto)

cNumPC := oProcess:oHtml:ValByName("C7_NUM")
oProcess:Finish()

dbSelectArea("SC7")
dbSetOrder(1)// C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
If dbSeek( xFilial("SC7") + cNumPC )

	oProcess:NewTask(cTitulo, cHtmlMod, .T.)

	If (Left(oProcess:cSubject,9) != "(REENVIO)")
		oProcess:cSubject := "(REENVIO)" + oProcess:cSubject
	EndIf

	oProcess:cTo 		:= aRet[1]
	oProcess:UserSiga	:= WFCodUser("BI")
	oProcess:bReturn 	:= "U_SCI99A(1)"
	oProcess:bTimeOut	:= {"U_SCI99A(2)", nDias, nHoras, nMinutos}// Redefina a funcao de timeout a ser executada.

	cTexto := "Reenviando o Pedido..."
	cCodStatus := "002200"
	oProcess:Track(cCodStatus, cTexto)
	oProcess:Start()		// Inicie o processo

Else

	cTexto := "N�o foi poss�vel encontrar o Pedido: " + cNumPC
	cCodStatus := "002170" // Codigo do cadastro de status de processo
	oProcess:Track(cCodStatus, cTexto)

EndIf

Return

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A040WfMail� Autor � Ednei Silva           � Data �29/06/2017���
�������������������������������������������������������������������������Ĵ��
���Descricao � Envia o e-mail Workflow conforme alcada de aprovacao       ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A040WfMail( ExpC01 )                                       ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC01 = Codigo do Pedido de Compra                        ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   � Array                                                      ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico Cliente Internacional                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function  A040WfMail( cNumPC )

Local aRet		:= {}
Local cQuery		:= ""
Local cAliasT		:= GetNextAlias()

FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " Verificando as al�adas"  , 0, 0, {}) 

cQuery := " SELECT CR_NUM,"
cQuery += "        CR_USER,"
cQuery += "        CR_APROV,"
cQuery += "        CR_NIVEL,"
cQuery += "        CR_STATUS"
cQuery += " FROM " + RetSQLName("SCR")
cQuery += " WHERE CR_FILIAL	  = '" + xFilial("SCR") + "'"
cQuery += "   AND CR_TIPO	  = 'PC'"
cQuery += "   AND CR_NUM     = '" + cNumPC + "'"
cQuery += "   AND CR_DATALIB = ''"
cQuery += "   AND CR_USERLIB = ''"
cQuery += "   AND D_E_L_E_T_ <>'*'"
cQuery += " ORDER BY CR_NIVEL"
cQuery := ChangeQuery( cQuery )
dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )

If ( cAliasT )->( !Eof() )
	FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " Tem aprovadores"  , 0, 0, {}) 

	aAdd( aRet, AllTrim( UsrRetMail( ( cAliasT )->CR_USER ) ) )
	aAdd( aRet, ( cAliasT )->CR_NIVEL )
	aAdd( aRet, ( cAliasT )->CR_USER )

Else
	FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " N�o tem aprovadores"  , 0, 0, {}) 
	aAdd( aRet, "OK" )
	aAdd( aRet, "" )
	aAdd( aRet, "" )

EndIf
( cAliasT )->( dbCloseArea() )

Return( aRet )

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �A040Alcada� Autor � Ednei Silva           � Data �29/06/2017���
�������������������������������������������������������������������������Ĵ��
���Descricao � Funcao de envio do Workflow com alcada                     ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � A040Alcada(ExpC01,ExpC02)                                  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� ExpC01 = Numero do Pedido de Compra                        ���
���          � ExpC02 = Codigo do Usuario que inclui do Pedido            ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �                                                            ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Especifico Cliente Internacional                           ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������*/
Static Function  A040Alcada( cNumPC,cUsuSiga )

Local nDias		:= 0
Local nHoras	:= 0
Local nMinutos	:= 10
Local nZ		:= 0
Local cCodProc 	:= "000002"
Local cCodStatus:= ""
Local cAssunto 	:= AllTrim( GetMV("ES_WFTITPC") ) + " " + cNumPC
Local cHtmlMod 	:= AllTrim( GetMV("ES_WFHTMLC") )
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
Local aDocs     := {}
Local lEnv      := .F.
//Local aObsPed	:= {}
Local lSetCentury := __SetCentury()
Local cQuery1	:=""
Local cObsPed	:= ""

Local cVarAux1 := GetMV("MV_MOEDA" + cValToChar( SC7->C7_MOEDA ) )

If	!lSetCentury
	__SetCentury("ON")
EndIf

FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " A040Alcada - Processando Pedido " + cNumPC  , 0, 0, {}) 

aRet := A040WfMail( cNumPC )//Funcao para retornar o e-mail e o nivel do usuario aprovador

If !aRet[1] == "OK"// Se houver aprovadores envia o formulario

	cQuery1 := " SELECT CR_NUM,  "
	cQuery1 += "        CR_USER, "
	cQuery1 += "        CR_APROV,"
	cQuery1 += "        CR_NIVEL,"
	cQuery1 += "        CR_STATUS"
	cQuery1 += " FROM " + RetSQLName("SCR")
	cQuery1 += " WHERE CR_FILIAL	  = '" + xFilial("SCR") + "'"
	cQuery1 += "   AND CR_TIPO	  = 'PC'"
	cQuery1 += "   AND CR_NUM     = '" + cNumPC + "'"
	//cQuery1 += "   AND CR_USER    = '" + aRet[3] + "'"
	cQuery1 += "   AND CR_NIVEL   = '" + aRet[2] + "'"
	cQuery1 += "   AND CR_DATALIB = ''"
	cQuery1 += "   AND CR_USERLIB = ''"
	cQuery1 += "   AND D_E_L_E_T_ <>'*'"
	cQuery1 += " ORDER BY CR_NIVEL "
	cQuery1 := ChangeQuery( cQuery1 )
	MemoWrite("testeEdy.SQL",cQuery1)
	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery1),cAliasL,.F.,.T. )

	cAju := AllTrim( GetMV("ES_WFLHTML") )
	cCapi:= Capital( RtFullName( cUsuSiga ) )	
	cAjuLin := AllTrim( GetMV("ES_WFLINK") )	
	cAjuSub := AllTrim( GetMV("ES_WFTITPC") )	
	
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

		cCodStatus := "002100"
		cTexto := "Iniciando o processamento da " + cAssunto + " do C�digo: " + cNumPC
		oProcess:Track(cCodStatus, cTexto, cUsuSiga)

		cTexto := "Gerando Pedido para envio..."
		cCodStatus := "002110"
		oProcess:Track(cCodStatus, cTexto, cUsuSiga)

		dbSelectArea("SC7")
		dbSetOrder(1)//C7_FILIAL+C7_NUM+C7_ITEM+C1_SEQUEN
		If dbSeek( xFilial("SC7") + cNumPC )

			oProcess:oHtml:ValByName( "C7_NUM"		, SC7->C7_NUM )
			oProcess:oHtml:ValByName( "C7_EMISSAO"	, SC7->C7_EMISSAO )
			oProcess:oHtml:ValByName( "C7_FORNECE"	, SC7->C7_FORNECE + " / " + SC7->C7_LOJA )

			dbSelectArea("SA2")
			dbSetOrder(1)//A2_FILIAL+A2_COD+A2_LOJA
			If dbSeek( xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA )
			oProcess:oHtml:ValByName( "C7_NOME"	, SA2->A2_NOME )
			EndIf

			oProcess:oHtml:ValByName( "C7_MOEDA" , cVarAux1 )

			dbSelectArea("SC1")
			dbSetOrder(1)//C1_FILIAL+C1_NUM+C1_ITEM
			If dbSeek( xFilial("SC1") + SC7->C7_NUMSC + SC7->C7_ITEMSC )
			oProcess:oHtml:ValByName( "C1_USER"	 , Capital( RtFullName( SC1->C1_USER ) ) )//Funcao para retornar o nome do usuario
			Endif

			oProcess:oHtml:ValByName( "C7_NUMSC" , SC7->C7_NUMSC )
			oProcess:oHtml:ValByName( "C7_FILENT", SC7->C7_FILENT )

			dbSelectArea("SM0")
			oProcess:oHtml:ValByName( "C7_FILIAL" 	, AllTrim( SM0->M0_CODFIL ) )

			cQuery := " SELECT C7_ITEM,"
			cQuery += "        C7_PRODUTO,"
			cQuery += "        C7_DESCRI,"
			cQuery += "        C7_QUANT,"
			cQuery += "        C7_UM,"
			cQuery += "        C7_PRECO,"
			cQuery += "        C7_TOTAL,"
			cQuery += "        C7_DATPRF,"
			cQuery += "        C7_CC,"
	        cQuery += "        C7_COND,"
	        cQuery += "        C7_NUM,"
	        cQuery += "        C7_NUMSC,"
	        cQuery += "        C7_ITEMSC,"
	        cQuery += "        C7_SEQUEN,"
	        cQuery += "        C7_DTHRENV,"
	        cQuery += "        C7_DTHRALT,"
			cQuery += "		   ISNULL( CONVERT( VARCHAR(8000), CONVERT(BINARY(8000), C7_OBSM ) ), '' ) C7_OBSM"
			cQuery += " FROM " + RetSQLName("SC7")
			cQuery += " WHERE C7_FILIAL = '" + xFilial("SC7") + "'"
			cQuery += "   AND C7_NUM = '" + cNumPC + "'"
			cQuery += "   AND D_E_L_E_T_<>'*'"
			dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery ),cAliasT,.F.,.T. )


			While ( cAliasT )->( !Eof() )

				aAdd( ( oProcess:oHtml:ValByName( "A.C7_ITEM" ) ) 		, ( cAliasT )->C7_ITEM )
				aAdd( ( oProcess:oHtml:ValByName( "A.C7_PRODUTO" ) ) 	, ( cAliasT )->C7_PRODUTO )
				aAdd( ( oProcess:oHtml:ValByName( "A.C7_DESCRI" ) ) 	, AllTrim( ( cAliasT )->C7_DESCRI ) )
				aAdd( ( oProcess:oHtml:ValByName( "A.C7_UM" ) ) 		, ( cAliasT )->C7_UM )
				aAdd( ( oProcess:oHtml:ValByName( "A.C7_QUANT" ) ) 	, ( cAliasT )->C7_QUANT )
				aAdd( ( oProcess:oHtml:ValByName( "A.C7_PRECO" ) ) 	, Transform( ( cAliasT )->C7_PRECO , PesqPict("SC7","C7_PRECO") ) )
				aAdd( ( oProcess:oHtml:ValByName( "A.C7_TOTAL" ) ) 	, Transform( ( cAliasT )->C7_TOTAL , PesqPict("SC7","C7_TOTAL") ) )
				aAdd( ( oProcess:oHtml:ValByName( "A.C7_DATPRF" ) ) 	, DtoC( StoD( ( cAliasT )->C7_DATPRF ) ) )
				aAdd( ( oProcess:oHtml:ValByName( "A.C7_CC" ) ) 		, ( cAliasT )->C7_CC )
				aAdd( ( oProcess:oHtml:ValByName( "A.C7_SEQUEN" ) ) , ( cAliasT )->C7_SEQUEN )
				aAdd( ( oProcess:oHtml:ValByName( "A.C7_COND" ) )   , ( cAliasT )->C7_COND )

				dbSelectArea("CTT")
				dbSetOrder(1)//CTT_FILIAL+CTT_CUSTO
				If dbSeek( xFilial("CTT") + ( cAliasT )->C7_CC )
					aAdd( ( oProcess:oHtml:ValByName( "A.C7_DESCCC" ) ) , AllTrim( CTT->CTT_DESC01 ) )
				Else
					aAdd( ( oProcess:oHtml:ValByName( "A.C7_DESCCC" ) ) , "" )
				EndIf

				dbSelectArea("SE4")
				dbSetOrder(1)//SE4_FILIAL+SE4_CODIGO
				If dbSeek( xFilial("SE4") + ( cAliasT )->C7_COND  )
					cCondPgto := AllTrim( ( cAliasT )->C7_COND ) +"-"+ AllTrim( SE4->E4_DESCRI )
				Else
					cCondPgto := ""
				EndIf

				nValTotal += ( cAliasT )->C7_TOTAL

				If !Empty( ( cAliasT )->C7_OBSM )
					cObsPed +=  AllTrim( ( cAliasT )->C7_OBSM ) //NoAcento( AllTrim( ( cAliasT )->C7_OBSM ) )
					cObsPed += '<br>'
				EndIf

				/*
				Aadd(aDocs,{SC7->C7_FILIAL+( cAliasT )->C7_NUM+( cAliasT )->C7_ITEM,; //CHAVE SC7
						    SC7->C7_FILIAL+( cAliasT )->C7_NUMSC+( cAliasT )->C7_ITEMSC,; //CHAVE SC1
						    ( cAliasT )->C7_NUMSC,;
						    ( cAliasT )->C7_ITEMSC})

			    */
				If !Empty(( cAliasT )->C7_DTHRALT)
			    	lEnv:=.T.
				EndIf


				( cAliasT )->( dbSkip() )

			EndDo

			( cAliasT )->( dbCloseArea() )

			oProcess:oHtml:ValByName( "C7_DESPAG", cCondPgto )

			If !Empty( cObsPed )
				aAdd( oProcess:oHtml:ValByName("B.C7_OBSM"), cObsPed )
			Else
				aAdd( oProcess:oHtml:ValByName("B.C7_OBSM"), "" )
			EndIf

			If lEnv
				oProcess:oHtml:ValByName( "REENVIO"	, "<b>(REENVIO)</b>" )
			Else
				oProcess:oHtml:ValByName( "REENVIO"	, "" )
			EndIf

			oProcess:oHtml:ValByName( "C7_PCTOTAL"	 , Transform( nValTotal, PesqPict("SC7","C7_TOTAL") ) )
			oProcess:oHtml:ValByName( "C7_NIVEL"	 , ( cAliasL )->CR_NIVEL )
			oProcess:oHtml:ValByName( "C7_CODUSR"	 , cUsuSiga )
			oProcess:oHtml:ValByName( "C7_APROVADOR", ( cAliasL )->CR_USER )

			S99AConhe(cNumPC,oProcess)

		EndIf

		oProcess:cSubject := cAssunto
		oProcess:cTo := "siga"
		oProcess:UserSiga	:= WFCodUser("BI")

		oProcess:bReturn	:= "U_SCI99A(1)"
		oProcess:bTimeOut	:= {"U_SCI99A(2)", nDias, nHoras, nMinutos}
		cTexto := "Enviando Pedido de Compra..."
		cCodStatus := "002120"
		oProcess:Track(cCodStatus, cTexto , cUsuSiga)
		cMailID := oProcess:Start()

		// Envia o Numero do Processo para o formulario para ser solicitado no retorno
		oProcess:oHtml:ValByName( "C7_NUMPROC" , cMailID )

		oProcess :NewTask(cTitulo, cAju )
		//oProcess :NewTask(cTitulo, AllTrim( GetMV("ES_WFLHTML") ) )
		oProcess :ohtml:ValByName("titulo", "Aprova��o de Pedido de Compra - Internacional" )
		oProcess :ohtml:ValByName("paragrafo", "Pedido inclu�do pelo usu�rio" )
		oProcess :ohtml:ValByName("nome_usuario", cCapi )
		//oProcess :ohtml:ValByName("nome_usuario", Capital( UsrFullName( cUsuSiga ) ) )

		oProcess :ohtml:ValByName("frase_link", "Clique no n�mero do Pedido de Compra para mais detalhes: " )
		oProcess :ohtml:ValByName("cod_sc", cNumPC )
		oProcess :ohtml:ValByName("proc_link", cAjuLin + "messenger/emp" +cEmpAnt + "/siga/" + cMailID + ".htm" )
		//oProcess :ohtml:ValByName("proc_link", AllTrim( GetMV("ES_WFLINK") ) + "messenger/emp" +cEmpAnt + "/siga/" + cMailID + ".htm" )
		cQliberou:=""
		cQliberou:=Alltrim(cQLibPC( cNumPC ))
		if cQliberou<>""
			oProcess :ohtml:ValByName("liberadopor","Quem j� aprovou este pedido: "+cQliberou)
		endif
		oProcess :cTo := AllTrim( UsrRetMail(( cAliasL )->CR_USER ) ) //Array com o e-mail do aprovador
		oProcess :csubject := cAjuSub + " " + cNumPC
		//oProcess :csubject := AllTrim( GetMV("ES_WFTITPC") ) + " " + cNumPC
		oProcess :Start()

		cTexto := "Enviando o E-mail WF."
		cCodStatus := "002130"
		oProcess:Track(cCodStatus, cTexto , cUsuSiga)

		cTexto := "Aguarde retorno..."
		cCodStatus := "002140"
		oProcess:Track(cCodStatus, cTexto , cUsuSiga)

		( cAliasL )->( dbSkip() )
	Enddo

	( cAliasL )->( dbCloseArea() )

EndIf

Return


Static Function  cQLibPC( cNumPC )

Local cUsers		:= ""
Local cQuery		:= ""
Local cAliasZ		:= GetNextAlias()


FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " Verificando quem j� liberou"  , 0, 0, {}) 

cQuery := " SELECT CR_NUM,"
cQuery += "        CR_USER,"
cQuery += "        CR_APROV,"
cQuery += "        CR_NIVEL,"
cQuery += "        CR_STATUS"
cQuery += " FROM " + RetSQLName("SCR")
cQuery += " WHERE CR_FILIAL	  = '" + xFilial("SCR") + "'"
cQuery += "   AND CR_TIPO	  = 'PC'"
cQuery += "   AND CR_NUM      = '" + cNumPC + "'"
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

		cUpDate := " UPDATE " + RetSqlName("SC7")
		//cUpDate += " SET C7_CONAPRO = '2'"
		cUpDate += " SET C7_CONAPRO='R'" //Valdir em 15/05/2019
		cUpDate += " FROM " + RetSqlName("SC7")+" SC7 "
		cUpDate += "  INNER JOIN "+RETSQLNAME("SCR")+" SCR ON (C7_FILIAL=SCR.CR_FILIAL and C7_NUM=SCR.CR_NUM) "
		cUpDate += " WHERE C7_FILIAL='" + xFilial("SC7") + "'"
		cUpDate += "  AND C7_TIPO=1 "
		cUpDate += "  AND SCR.CR_STATUS='04' "
		cUpDate += "  AND SC7.D_E_L_E_T_<>'*' "
		cUpDate += "  AND SCR.D_E_L_E_T_<>'*' "

		FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " Executanto UPDATE cQLibPC " + cUpDate  , 0, 0, {}) 

		If TcSqlExec( cUpDate ) < 0
			FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " TCSQLError() " + TCSQLError()  , 0, 0, {}) 
        Else
			FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", " TCSQLError() OK" , 0, 0, {}) 
		EndIf

Return( cUsers )

/* Retirar caracteres especiais */
User Function NoCharEsp(cString,lEspaco)

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

	cString := StrTran( cString, '�', IIf( lEspaco, " ", "" ) )

	cString := StrTran( cString, Chr(176), IIf( lEspaco, " ", "" ) )

	cString := StrTran( cString, '�', IIf( lEspaco, " ", "" ) )

	cString := StrTran( cString, '�', IIf( lEspaco, " ", "" ) )

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


Static Function S99AConhe(cC7Num,oProcess)

	Local cQry     := ""
	Local cAliasA  := GetNextAlias()
	Local cLogoAnx := ""
	Local cAnex    := "http://aprovacao.internacional.net.br:9090/workflow/dirdoc/co01/shared/"
	Local cImgRoot := "http://aprovacao.internacional.net.br:9090/workflow/img-workflow/"
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

	dbSelectArea('SC7')
	dbSetOrder(1)
	If dbSeek(xFilial('SC7')+cC7Num)

		Do While SC7->(!Eof()) .and. SC7->C7_FILIAL+SC7->C7_NUM == xFilial('SC7')+cC7Num
		   If !Empty(SC7->C7_NUMSC)
				If !SC7->C7_NUMSC $ cScs
					cScs +=SC7->C7_FILIAL+SC7->C7_NUMSC+","
				EndIf
		   EndIf
		   cC7Key := SC7->C7_FILIAL+SC7->C7_NUM
		 SC7->(dbSkip())

		EndDo

		cScs := SubStr(cScs,1,Len(cScs)-1)

		cQry := " SELECT 	ACB_OBJETO,"
		cQry += " 			ACB_DESCRI "

		cQry += " FROM "+ RetSqlName("AC9") +" AC9 "
		cQry += " INNER JOIN "+ RetSqlName("ACB") +" ACB "
		cQry += "	ON  AC9.AC9_FILIAL = ACB.ACB_FILIAL "
		cQry += "	AND AC9.AC9_CODOBJ = ACB.ACB_CODOBJ " 
		cQry += "	AND ACB.D_E_L_E_T_ <> '*' "

		cQry += " WHERE AC9.AC9_FILENT = '"+ PADR( xFilial("SC7"), TAMSX3("C7_FILIAL")[1]) + "' "
		cQry += "	AND SUBSTRING(AC9.AC9_CODENT,1,10) = '" + cC7Key + "' "
		cQry += "	AND AC9.AC9_ENTIDA IN ('SC7') "
		cQry += "	AND AC9.D_E_L_E_T_ <> '*' "
		
		/* ESTE IF ANEXA TAMBEM ARQUIVOS REFERENTE A TABELA SC1
		If  !Empty(cScs)

				//cQry += "AND AC9.AC9_CODENT IN ('"+PADR(aDocs[a,1],TAMSX3("AC9_CODENT")[1])+"','"+PADR(aDocs[a,2],TAMSX3("AC9_CODENT")[1])+"') "
				cQry += "AND SUBSTRING(AC9.AC9_CODENT,1,10) IN "+formatin(cScs,',')
				cQry += "AND AC9.AC9_ENTIDA IN ('SC1')  AND 	AC9.D_E_L_E_T_ <> '*' "
				cQry += "OR SUBSTRING(AC9.AC9_CODENT,1,10) = '"+cC7Key+"' "
				cQry += "AND AC9.AC9_ENTIDA IN ('SC7') AND 	AC9.D_E_L_E_T_ <> '*' "

		Else

			//cQry += "AND AC9.AC9_CODENT = '"+PADR(aDocs[a,1],TAMSX3("AC9_CODENT")[1])+"' "
			cQry += "AND SUBSTRING(AC9.AC9_CODENT,1,10) = '"+cC7Key+"' "
			cQry += "AND AC9.AC9_ENTIDA IN ('SC7') "
			cQry += "AND AC9.D_E_L_E_T_ <> '*' "
			
		EndIf
		*/
	
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


				    nSize := RetSize(Alltrim(cDirDocs) + "\" + cNameServ)

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

		oProcess:oHtml:ValByName( "ANEXOS", cDoc )
		aDocs := {}                       
		
	EndIf

Return


Static Function PedidoOK(aDados)

	Local nX   := 0
	Local lRet := .T.
	Local nPrc := 0
	Local aRet := {}
	Local lEmail := .F.

	dbSelectArea('SC7')
	dbSetOrder(1)

	For nX := 1 To Len(aDados)

		If dbSeek(xFilial('SC7')+PADR(aDados[nX,NUMPC],TAMSX3("C7_NUM")[1])+;
		          PADR(STRZERO(VAL(aDados[nX,ITEPC]),TAMSX3("C7_ITEM")[1]),TAMSX3("C7_ITEM")[1])+PADR(aDados[nX,SEQPC],TAMSX3("C7_SEQUEN")[1]))

			If SC7->C7_COND <> aDados[nX,CONPG]

				lRet:= .F.
				cMsg := "Condi��o de pagameto original diferente da cadastrada no sistema"
				FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", cMsg  , 0, 0, {}) 

				lEmail:= .T.
				Exit

			ElseIf SC7->C7_QUANT <> aDados[nX,QUANT]

				lRet:= .F.
				cMsg := "Quantidade original diferente da cadastrada no sistema"
				FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", cMsg  , 0, 0, {}) 
				lEmail:= .T.
				Exit

			ElseIf Transform( SC7->C7_PRECO , PesqPict("SC7","C7_PRECO") ) <> aDados[nX,PRECO]


				lRet:= .F.
				cMsg := "Pre�o original diferente do cadastrado no sistema"
				FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", cMsg  , 0, 0, {}) 

				lEmail:= .T.
				Exit

			ElseIf SC7->C7_PRODUTO <> aDados[nX,PROPC]

				lRet:= .F.
				cMsg:="Produto original diferente da cadastrada no sistema"
				FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", cMsg  , 0, 0, {}) 

				lEmail:= .T.
				Exit

			EndIf

		Else

			lRet:= .F.
			FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", 'N�o Encontrou o registro'  , 0, 0, {}) 

			Exit

		EndIf

	Next nX

	If lEmail

		aRet := AvisGestor(SC7->C7_NUM,SC7->C7_ITEM,cMsg)
        If Len(aRet) > 0
        	If aRet[1]
				FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", 'Email enviado para o Aprovador e Gestor'  , 0, 0, {}) 
				FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", aRet[2]  , 0, 0, {}) 
        	Else
				FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", 'Email n�o enviado para o Aprovador e Gestor'  , 0, 0, {}) 
				FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", aRet[2]  , 0, 0, {}) 

        	EndIf
   		EndIf

   	EndIf

Return lRet


Static Function AvisGestor(cC7Num,cC7It,cMsg)

	Local cHTML    := MontaHtml(cC7Num,cC7It,cMsg)
	Local cEmail   := RetComMail(cC7Num)//Retorna email do comprado
	Local cError   := ""
	Local cMsg     := ""
	Local cBuffer  := ""
	Local lOK      := .F.
	Local lMsgError:= .T.
	Local lAuth    := Getmv( "MV_RELAUTH" )
	Local cServer  := GetMV( "MV_RELSERV" )
	Local cAccount := GetMv( "MV_RELACNT" )
	Local cPassword:= GetMv( "MV_RELPSW"  )
	Local cSubject := "Pedido de Compra | Problemas Aprova��o"

	FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", 'Preparando Envio do Email para aprovador e gestor'  , 0, 0, {}) 

	//-- Usar e-mail temporario para homologacao
   	cTo := Alltrim(cEmail)

	// conectando-se com o servidor de e-mail
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

		// Fazendo autenticacao
		If lResult .And. lAuth

			lResult := MailAuth( cAccount,cPassword )
			If !lResult

				If lMsgError// Erro na conexao com o SMTP Server

					GET MAIL ERROR cError
					cMsg += "- Erro na autentica��o da conta do e-mail. " + cError + CRLF
					lOK:= .F.

				EndIf

			EndIf

		Else

			If !lResult

				If lMsgError//Erro na conexao com o SMTP Server

					GET MAIL ERROR cError
					cMsg += "- Erro de conex�o com servidor SMTP. " + cError + CRLF
					lOK:= .F.

				EndIf

			EndIf

		EndIf

		If !lResult

			GET MAIL ERROR cError
			cMsg += "- Erro ao conectar a conta de e-mail. " + cError
			lOK:= .F.

		Else

			SEND MAIL FROM cAccount TO cTo SUBJECT cSubject BODY cHTML RESULT lResult

			If !lResult

				GET MAIL ERROR cError
				cMsg := "- Erro no Envio do e-mail. " + cError + CRLF
				lOK  := .F.

			EndIf

			lOK := .T.

		EndIf

		DISCONNECT SMTP SERVER

Return( {lOK, cMsg} )

Static Function MontaHtml(cNum,cIt,Cmsg)

	Local cHtml := ""

	FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", 'Montando corpo do email para envio'  , 0, 0, {}) 

	cHtml:="<h2>Aten��o|Pedido n�o pode ser Aprovado</h2>"
	cHtml+="<span><p>Pedido numero "+cNum+", item "+cIt+" ,sofreu altera��oes e n�o poder� ser aprovado.</p></span>"
	cHtml+="<span><p>Log de Retorno do WorkFlow</p></span>"
	cHtml+="<span><p><b>"+Cmsg+"</b></p></span>"


Return cHtml

User Function AtuEnvio(cNum,cItem,cSequen,lEnv,lInt)

	Local aSC7  := SC7->(GetArea())
	Local cDtHr := alltrim(cValToChar(day(date())) +'/'+  cValToChar(Month(date())) +'/'+ substr(cvaltochar(year(date())),3,2) +' '+time())
    Local cQuery := ""

   	default lInt := .T.

	If lInt  //Se chamou nesta funcao mesmo

		dbSelectArea('SC7')
		dbSetOrder(1)
		If dbSeek(xFilial('SC7')+cNum+cItem+cSequen)
			SC7->(RecLock('SC7',.F.))
				If !lEnv
					SC7->C7_DTHRENV := cDtHr
				Else
					SC7->C7_DTHRENV := cDtHr
				EndIf
			SC7->(MsUnlock())
		EndIf

	Else //Chamou pelo ponto de entrada da gravacao do pedido de compras

		cQuery:=" UPDATE "+RETSQLNAME("SC7")+" "
		cQuery+=" SET C7_DTHRALT='"+cDtHr+"', C7_DTHRENV=' ' "
		cQuery += " FROM "+RetSqlName('SC7')+" SC7 "
		cQuery += "  WHERE C7_FILIAL = '"+xFilial("SC7")+"' "
		cQuery += "  AND SC7.C7_NUM ='"+cNum+"' "
		cQuery += "  AND SC7.D_E_L_E_T_<>'*' "

   		TcSqlExec(cQuery)

	EndIf

   RestArea(aSC7)


Return

Static Function RetComMail(cC7Num)

	Local aASC7 := SC7->(GetArea())
	Local cUsrMail := ""

	dbSelectArea("SC7")
	dbSetOrder(1)//C7_FILIAL+C7_NUM+C7_ITEM+C1_SEQUEN
	If dbSeek( xFilial("SC7") + cC7Num )

		cUsrMail := UsrRetMail(SC7->C7_USER)

	EndIf


	RestArea(aASC7)



Return cUsrMail

Static Function RetSize(cArqObj)

	Local oFile := Nil
	Local nSize := 0
    Local nSize := 0

	oFile := FWFileReader():New(cArqObj)

	If (oFile:Open())

   		nSize:= oFile:getFileSize()
   		oFile:Close()

	EndIf


Return nSize


//+-------------------------------------------------+
//| Funcao para retornar o nome completo do usuario |
//| Denis - 02/12/2019                              |
//+-------------------------------------------------+
Static Function RtFullName( cCodUser )
	
	Local cRet := ""
	
	cRet := UsrFullName( cCodUser  )
	
Return( cRet )
