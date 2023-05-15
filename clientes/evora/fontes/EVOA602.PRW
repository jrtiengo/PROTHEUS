//Bibliotecas
#Include "Protheus.ch"
#Include "RWMake.ch"
#Include "Ap5Mail.ch"

/*
+---------+-----------+-------+-------------------------------------+------+----------+
| Funcao    | EVOA602   | Autor | Manoel M Mariante                   | Data |out/2020  |
|-----------+-----------+-------+-------------------------------------+------+----------|
| Descricao | download dos arquivos XML do email da empresa para posterior importaÁ„o   |
|           |                                                                           |
|           |                                                                           |
|-----------+---------------------------------------------------------------------------|
| Sintaxe   | executado via menu ou job                                                 |
+-----------+---------------------------------------------------------------------------+
*/
User Function EVOA602(aemp)
	Local cArqSem
	Private lJobProc   := .F.
	DEFAULT aEmp 		:={'01','01'}


	//Se n√£o tiver aberto o dicion√°rio (rotina executada sem abrir o Protheus)
	If Select("SX2") <= 0
		RPCClearEnv()

		RPCSetEnv(aEmp[1],aEmp[2],"","","","")
		lJobProc := .T.
		u_fMyAlert('Abrindo tabelas...')

	Else
		If ! MsgYesNo("Deseja acessar a caixa de entrada e baixar os arquivos XML?", "AtenÁ„o")
			Return
		EndIf
	EndIf
	If ! SuperGetMV('ES_PPFRE',.F.,.F.)
		MsgAlert('Empresa n„o foi configurada para o Paper Free', 'AtenÁ„o')
		RETURN
	end


	cArqSem     := getmv('ES_NFSEPAS')+"semaforo_email.lck"

	//Se existir o sem√°foro, d√° mensagem de erro
	If File(cArqSem)
		//u_fMyAlert("Sem·foro existente (" + MemoRead(cArqSem) + ")")

		//return
	else
		//MEMOWRIT(cArqSem,'processando '+dtoc(msdate())+"|"+time())
	End

	//Chamando o processamento de dados
	Processa({|| fProcessa() }, "Processando...")

	//Mostrando mensagem de conclus√£o
	u_fMyAlert("Processo concluÌdo.",.t.)

	//FErase(cArqSem)

Return

/*
---------------------------------------------------------------*
 | Func.: fProcessa                                              |
 | Desc.: Fun√ß√£o de processamento para buscar os arquivos        |
 *---------------------------------------------------------------
 */
Static Function fProcessa()
	Local aArea := GetArea()
	Local cArqINI
	Local cBkpConf
	Local nRet
	Local nNumMsg
	Local nMsgAtu
	Local oManager
	Local oMessage
	Local nAnexoAtu
	Local nTotAnexo
	Local aInfAttach
	Local lDownOk
	Local lEntrou:=.f.

	Private cDirBase  := GetSrvProfString("RootPath", "")
	Private cDirPad   := getmv('ES_NFSEPAS')
	//Definindo dados da conta
	Private cConta    := GETMV('ES_NFSECTA') //"manoel.mariante@gmail.com"
	Private cSenha    := GETMV('ES_NFSEPSW') //"mRNT2003!"
	Private cSrvFull  := GETMV('ES_NFSESRV') //"pop.gmail.com:995"
	Private lSSL      := GETMV('ES_NFSESSL')
	Private lTLS      := GETMV('ES_NFSETLS')
	Private cServer   := Iif(':' $ cSrvFull, SubStr(cSrvFull, 1, At(':', cSrvFull)-1), cSrvFull)
	Private nPort     := Iif(':' $ cSrvFull, Val(SubStr(cSrvFull, At(':', cSrvFull)+1, Len(cSrvFull))), 110)

	//Se o √∫ltimo caracter n√£o for barra, retira ela
	If SubStr(cDirBase, Len(cDirBase), 1) == '\'
		cDirBase := SubStr(cDirBase, 1, Len(cDirBase)-1)
	EndIf

	//O diret√≥rio cheio, ser√° o caminho absoluto + conte√∫do do par√¢metro, por exemplo, D:\TOTVS\TOTVS Protheus\Protheus_Data\x_importacao_email
	cDirFull := cDirBase + cDirPad

	//Altera o arquivo appserver.ini, deixando como IMAP
	cArqINI  := GetSrvIniName()
	cBkpConf := GetPvProfString( "MAIL", "Protocol", "", cArqINI )
	WritePProString('MAIL', 'PROTOCOL', 'IMAP', cArqINI)

	/* Tiengo - 02/05/2023 CA1004: Uso n„o permitido de chamada de API de Console
	ConOut('EVOA602 - Conectando ao servidor de email com as seguintes configuraÁoes:') 
	ConOut('EVOA602 - cServer :'+CValToChar(cServer))
	ConOut('EVOA602 - cConta :'+CValToChar(cConta))
	ConOut('EVOA602 - cSenha :'+CValToChar(cSenha))
	ConOut('EVOA602 - nPort :'+CValToChar(nPort))
	ConOut('EVOA602 - lSSL :'+CValToChar(lSSL))
	ConOut('EVOA602 - lTLS :'+CValToChar(lTLS))
	*/

	//FWLogMsg( < cSeverity >,  [ cTransactionId ] , < cGroup > , [ cCategory ] , [ cStep ] , [ cMsgId ] , [ cMessage ] , [ nMensure ] , [ nElapseTime ] , [ aMessage ] )
	FwLogMsg("INFO", /**/, "EVOA602", "", "", "", "Conectando ao servidor de email com as seguintes configuraÁoes:", , , )
	FwLogMsg("INFO", /**/, "EVOA602", "", "", "", "cServer :+CValToChar(cServer)", , , )
	FwLogMsg("INFO", /**/, "EVOA602", "", "", "", "cConta :+CValToChar(cConta)", , , )
	FwLogMsg("INFO", /**/, "EVOA602", "", "", "", "cSenha :+CValToChar(cSenha)", , , )
	FwLogMsg("INFO", /**/, "EVOA602", "", "", "", "nPort :+CValToChar(nPort)", , , )
	FwLogMsg("INFO", /**/, "EVOA602", "", "", "", "lSSL :+CValToChar(lSSL)", , , )
	FwLogMsg("INFO", /**/, "EVOA602", "", "", "", "lTLS :+CValToChar(lTLS)", , , )

	//Cria a conex√£o base no gerenciamento
	oManager := tMailManager():New()
	oManager:SetUseSSL(lSSL)
	oManager:SetUseTLS(lTLS)
	oManager:Init(cServer, "", cConta, cSenha, nPort, 0)

	//oManager:SetOAuthToken( '111111' )

	//Caso n√£o consiga setar 120 segundJos como timeout (2 minutos), n√£o continua
	If oManager:SetPopTimeOut(120) != 0
		u_fMyAlert("Falha ao setar o timeout" )
		Return
	End

	//Faz a conex√£o com IMAP
	nRet := oManager:IMAPConnect()

	//Se n√£o conseguir conectar, mostra qual √© a mensagem de erro
	If nRet != 0
		u_fMyAlert("Falha ao conectar. Erro "+oManager:GetErrorString(nRet) )
		Return
	End

	u_fMyAlert("Sucesso ao conectar",.t. )

	//Busca o n√∫mero de mensagens na caixa de entrada
	nNumMsg := 0
	oManager:GetNumMsgs(@nNumMsg)

	//Se houver mensagens a serem processadas
	If nNumMsg == 0
		u_fMyAlert("N√o existem mensagens para processamento...")
		return
	EndIf

	nLastMsg:=GETMV('ES_NFSELST') //retirar depois

	u_fMyAlert("Numero de msgs na caixa: "+CValToChar(nNumMsg),.t. )
	u_fMyAlert("Numero da ultima msgs: "+CValToChar(nLastMsg),.t. )
	u_fMyAlert("Numero de msgs para processar: "+CValToChar(nNumMsg - nLastMsg),.t. )


	ProcRegua(nNumMsg - nLastMsg )

	//Percorre o n√∫mero de mensagens
	For nMsgAtu := nLastMsg To nNumMsg
		IncProc("Baixando e-Mail " + cValToChar(nMsgAtu) + " de " + cValToChar(nNumMsg) + "...")
		//Tiengo - 02/05/2023 CA1004: Uso n„o permitido de chamada de API de Console
		//conout('EVOA602 - baixando e-mail '+ cValToChar(nMsgAtu) + " de " + cValToChar(nNumMsg))
		FwLogMsg("INFO", /**/, "EVOA602", "", "", "", " Baixando e-mail + cValToChar(nMsgAtu) + 'de' + cValToChar(nNumMsg) ", , , )

		//Buscando a mensagem atual
		oMessage := tMailMessage():new()
		oMessage:Clear()
		oMessage:Receive(oManager, nMsgAtu)

		//Busca o total de Anexos
		nTotAnexo := oMessage:GetAttachCount()

		//Limpando a flag
		lDownOk := .T.
		lEntrou := .F.

		u_fMyAlert("Processando seguinte email: "+chr(13)+chr(10)+;
			"e-Mail Origem:      " + cConta+chr(13)+chr(10)+;
			"De:                 " + oMessage:cFrom+chr(13)+chr(10)+;
			"Assunto:            " + oMessage:cSubject+chr(13)+chr(10)+;
			"Numero da Msg:         " + StrZero(nMsgAtu)+chr(13)+chr(10)+;
			"Total de Anexos " + CValToChar(nTotAnexo) ,.t.)


		//Percorre todos os anexos
		For nAnexoAtu := 1 To nTotAnexo
			//Busca as informa√ß√µes do anexo
			aInfAttach := oMessage:GetAttachInfo(nAnexoAtu)

			//Se tiver conte√∫do, e for do tipo XML ou PDF
			If ! Empty(aInfAttach[1]) .And. (Upper(Right(AllTrim(aInfAttach[1]),4)) == '.XML' .or. Upper(Right(AllTrim(aInfAttach[1]),4))==".PDF" )
				lEntrou := .T.

				//Salva o arquivo na pasta correta
				If oMessage:SaveAttach(nAnexoAtu, cDirFull + aInfAttach[1])

					u_fMyAlert("e-Mail Lido com Anexo: "+chr(13)+chr(10)+;
						"e-Mail Origem:      " + cConta+chr(13)+chr(10)+;
						"De:                 " + oMessage:cFrom+chr(13)+chr(10)+;
						"Assunto:            " + oMessage:cSubject+chr(13)+chr(10)+;
						"Numero Msg:         " + StrZero(nMsgAtu)+chr(13)+chr(10)+;
						"Num Anexo " + CValToChar(nAnexoAtu) + ":          " + aInfAttach[1],.t.)

				Else

					u_fMyAlert("Erro ao salvar anexo: "+chr(13)+chr(10)+;
						"e-Mail Origem:      " + cConta+chr(13)+chr(10)+;
						"De:                 " + oMessage:cFrom+chr(13)+chr(10)+;
						"Assunto:            " + oMessage:cSubject+chr(13)+chr(10)+;
						"Numero Msg:         " + StrZero(nMsgAtu)+chr(13)+chr(10)+;
						"Num Anexo " + CValToChar(nAnexoAtu) + ":          " + aInfAttach[1] ,.t.)


					lDownOk := .F.
				EndIf
			else
				u_fMyAlert("N„o tem XML: "+chr(13)+chr(10)+;
					"e-Mail Origem:      " + cConta+chr(13)+chr(10)+;
					"De:                 " + oMessage:cFrom+chr(13)+chr(10)+;
					"Assunto:            " + oMessage:cSubject+chr(13)+chr(10)+;
					"Numero Msg:         " + CValToChar(nMsgAtu)+chr(13)+chr(10) ,.t.)


			EndIf

		Next nAnexoAtu

        //Se o anexo tiver sido salvo com sucesso

		If lDownOk.and.lEntrou
			If oManager:MoveMsg(nMsgAtu, "INBOX.importados")
				u_fMyAlert("Mensagem Nr. "+cValToChar(nMsgAtu)+"("+Alltrim(oMessage:cFrom)+") Movida para IMPORTADOS")
			else
				u_fMyAlert("N„o foi possÌvel mover mensagem Nr. "+cValToChar(nMsgAtu)+"("+Alltrim(oMessage:cFrom)+") para IMPORTADOS")
			EndIf
            /*
            If lEntrou
                xRet:=oManager:MoveMsg(nMsgAtu, "INBOX.importados")
                If xRet //oManager:MoveMsg(nMsgAtu, "importados")
                    u_fMyAlert("Mensagem Movida para pasta IMPORTADOS" + cValToChar(nMsgAtu) + "...")
                else
                    u_fMyAlert("N√£o foi possÌvel mover a mensagem para IMPORTADOS- " + cValToChar(nMsgAtu) + "...") 
                EndIf
            Else
                If oManager:MoveMsg(nMsgAtu, "INBOX.processados")
                    u_fMyAlert("n√£o tem anexo XML. Foi movido para pasta PROCESSADOS- " + cValToChar(nMsgAtu) + "...")
                ELSE
                     u_fMyAlert("n√£o tem anexo XML. N√£o foi possÌvel mover a mensagem para PROCESSAOD- " + cValToChar(nMsgAtu) + "...") 
                EndIf
            EndIf
            */
		EndIf


//processa a inclusao da NF-se
//alert("vou importar")
		

	Next nMsgAtu
	U_evoa600()

//registra a ultima msg lida
	PUTMV('ES_NFSELST', nMsgAtu-2)

//Desconecta do servidor IMAP
	oManager:IMAPDisconnect()

//Volta a configura√ß√£o de Protocol no arquivo appserver.ini
	WritePProString('MAIL', 'PROTOCOL', cBkpConf, cArqINI)

	RestArea(aArea)
Return

