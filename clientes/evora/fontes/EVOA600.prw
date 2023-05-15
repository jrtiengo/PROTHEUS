#Include "XmlXFun.ch"
#Include "protheus.ch"
#Include "rwmake.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBEX.CH"
/*
+---------+-----------+-------+-------------------------------------+------+----------+
| Funcao    | EVOA600   | Autor | Manoel M Mariante                   | Data |out/2020  |
|-----------+-----------+-------+-------------------------------------+------+----------|
| Descricao | importação de nota fiscal de serviço eletrônica                           |
|           |                                                                           |
|           |                                                                           |
|-----------+---------------------------------------------------------------------------|
| Sintaxe   | executado via menu ou job                                                 |
+-----------+---------------------------------------------------------------------------+
rio novo florestal 05
evora matriz 01
terramar investimentos 12
terramar florestal 14
instituto ling 15
*/
User Function EVOA600(aEmp)

	Local cConteud		:=""
	Local cErro   		:= ""
	Local cWarning		:= ""
	Local lErro			:=.f.
	Local nP			:=1
	Local nN1

	Local nTela			:=0, nDX,nC,nTT
	Local aModelos		:={}
	Local cTblCab		:='SZU'
	Local cTblIte		:='SZV'
	Local nL			:=1

	Private oXML		:= Nil
	Private cPath		:=''
	PRIVATE cLayOut		:=''
	Private cTblLog		:='ZZ1'
	Private lJob		:=.f.
	Private cfile		:=""
	Private lPreDoc		:=.t.
	Private cLog		:=''
	DEFAULT aEmp 		:={'01','01'}

	If Select("SX2") <= 0
		RPCClearEnv()
		RPCSetEnv(aEmp[1],aEmp[2],"","","","")
		nTela		:=0
		lJob		:=.t.
	else
		nTela		:=1
		lJob		:=.f.
	END
	If ! SuperGetMV('ES_PPFRE',.F.,.F.)
		MsgAlert('Empresa não foi configurada para o Paper Free', 'Atenção')
		RETURN
	end

	/*
	IF !lJob
		IF !Msgbox("Deseja realizar a importacao de NFS-e ?","Atencao","YESNO")
			Return
		End
	End
	*/


	cPath:=GETMV('ES_NFSEPAS')

	dbSelectArea(cTblCab)
	DBGOTOP()
	While !Eof()

		If Empty(UPPER(ALLTRIM(SZU->ZU_IDPREST))).or.Empty(UPPER(alltrim(SZU->ZU_IDDESTI)))
			dbskip()
			loop
		end
		//tags de prestador e tomador
		aAuxP:=fTag2Array(UPPER(ALLTRIM(SZU->ZU_IDPREST)))
		aAuxD:=fTag2Array(UPPER(ALLTRIM(SZU->ZU_IDDESTI)))
		Aadd(aModelos,{SZU->ZU_COD,aAuxP,aAuxD,ALLTRIM(SZU->ZU_IDPREST),ALLTRIM(SZU->ZU_IDDESTI)})
		dbskip()
	END

	iF len(aModelos)==0
		fMyMsg("Não existem layouts cadastrados")
		Return
	End
//campos obrigatorios
	aCabObrig	:={'F1_DOC','F1_TIPO','F1_FORMUL','F1_EMISSAO','F1_FORNECE','F1_LOJA','F1_ESPECIE','F1_COND'}
	aItemObrig	:={'D1_COD','D1_QUANT','D1_VUNIT'}

	aFile := Directory(cPath+"*.xml","D")

	for nN1:= 1 to Len(aFile)

		cFile	:=aFile[nN1,1]
		cFilePDF:=STRTRAN(cFile,'.XML','.PDF')
		fMyMsg("Processando arquivo "+cFile,' Arquivo '+CValToChar(nN1)+' de '+CValToChar(Len(aFile)))
		if !File(cPath+cFilePDF)
			cFilePDF:=''
		END

		aCab	:={}
		aItens	:={}
		aItem	:={}
		lErro	:=.f.
		cLog	:=''
		M->F1_DOC:=''
		M->F1_SERIE:=''

		oXML := xmlparserfile(cPath+cFile,"_",@cErro,@cWarning)

		If (oXML == NIL )
			fMyMsg("Falha ao gerar Objeto XML : "+cErro+" / "+cWarning)
			Return
		Endif

		if !XMLError() == XERROR_SUCCESS
			fMyMsg("Erro. Impossivel transformar em Objeto")
			loop
		end

		For nP:=1 to Len(aModelos)
			lNao		:=.f.
			cPrestador	:=''

			IF !fTemTag(aModelos[nP,4],@cPrestador)
				//fMyMsg('Modelo '+aModelos[nP,1]+' não tem Prestador '+aModelos[nP,4])
				loop
			end

			cTomador:=''
			IF !fTemTag(aModelos[nP,5],@cTomador)
				//fMyMsg('Modelo '+aModelos[nP,1]+' não tem Tomador '+aModelos[nP,5])
				loop
			end

			cDest	:=&(cTomador)

			//apos identificado o modelo,vejo se o destinatario é a filial posicionada

			IF alltrim(cDest)<>alltrim(SM0->M0_CGC)
				fMyMsg('Tomador diferente: XML = '+cDest+' x Empresa = '+SM0->M0_CGC)
				cLog+='Tomador diferente: XML = '+cDest+' x Empresa Atual = '+SM0->M0_CGC+chr(13)+chr(10)
				lNao:=.t.
				exit
			END

			//procuro para ver se todas as tags existem. se não existir eu pulo de modelo
			dbSelectArea("SZV")
			dbSetOrder(1)
			DBGOTOP()
			dbSeek(xFilial("SZV")+aModelos[nP,1])

			While !eof().AND.SZV->ZV_COD==aModelos[nP,1]
				cConteud:=''
				IF ":" $ SZV->ZV_TAG
					If !fTemTag(SZV->ZV_TAG,@cConteud)
						//fMyMsg('Modelo '+aModelos[nP,1]+' não tem tag '+SZV->ZV_TAG)
						lNao:=.t.
						exit
					end
				end
				dbskip()
			end
			If !lNao
				cLayOut	:=aModelos[nP,1]
				exit
			end
		Next

		If lNao
			cLog+='Não foi localizado nenhum layout Valido para Importar este XML. Inclua ou revise os layouts disponiveis'+chr(13)+chr(10)
			fMyMsg('Não foi localizado nenhum layout Valido para Importar este XML. Inclua ou revise os layouts disponiveis')
			SaveLog('2','Documento NÃO incluido, Ver motivo no Log.',cPath+cFile,cFilePDF,cLog)
			//fRenFiles(cFile,2)
			loop //prox arq
		End

		//processando os campos dos itens
		dbSelectArea("SZV")
		dbSetOrder(1)
		DBGOTOP()
		dbSeek(xFilial("SZV")+cLayOut)
		While !eof().AND.SZV->ZV_COD==cLayOut

			xVar	:="M->"+SZV->ZV_CAMPO
			PRIVATE &(xVar):=NIL
			cConteud:=ALLTRIM(ZV_TAG)
			cConteud:=STRTRAN(cConteud,'-','_')
			cConteud:=STRTRAN(cConteud,'_>','->')
			cConteud:=STRTRAN(cConteud,'M_>','M->')
			lEhTag	:=.f.

			IF ":" $ cConteud
				lEhTag	:=.t.

				IF !fTemTag(SZV->ZV_TAG,@cConteud)
					fMyMsg('Tag '+ALLTRIM(ZV_TAG) + ' não existe no modelo '+cLayOut+' selecionado automaticamente.')
					lErro:=.t.
					dbSelectArea("SZV")
					dbskip()
					Loop
				end

			else
				IF valtype(&(cConteud))='U'
					fMyMsg('Conteudo da Variavel '+ALLTRIM(ZV_TAG) + ' não existe')
					dbSelectArea("SZV")
					dbskip()
					lErro	:=.t.
					Loop
				end
			end

			cTipoCpo	:='C'
			dbSelectArea('SX3')
			dbSetOrder(2)
			IF dbSeek(SZV->ZV_CAMPO)
				//cTipoCpo	:=SX3->X3_TIPO - Solutio Tiengo - 13/04/2023
				cTipoCpo	:=	&('SX3->X3_TIPO')
			end
			dbSelectArea("SZV")

			If lEhTag
				If cTipoCpo='C' //CARACTER
					&(xVar):=Alltrim(&(cConteud))
				elseif cTipoCpo='N' //NUMERO
					&(xVar):=VAL(&(cConteud))
				elseif cTipoCpo='D' //DAT
					&(xVar):=STOD(STRTRAN(&(cConteud),'-',''))
				END
			else
				&(xVar):=&(cConteud)
			End
			//-----------------------------------------------
			//FACO A TRANSFORMACAO
			//----------------------------------------------
			IF !EMPTY(SZV->ZV_GRAVAR)
				&(xVar)	:=&(SZV->ZV_GRAVAR)
			end
			//----------------------------------------------
			//PROCURO CASO CHAVE DE PESQUISA TENHA SIDO DEFINIDA
			//----------------------------------------------
			IF !EMPTY(SZV->ZV_TAB).AND.SZV->ZV_ORDER<>0.AND.!EMPTY(SZV->ZV_CHAVE)
				lAchou		:=.f.
				lBloqueio	:=.f.

				cCpoChave:=Posicione('SIX',1,SZV->ZV_TAB+Str(SZV->ZV_ORDER,1),'alltrim(CHAVE)')
				cNomChave:=Posicione('SIX',1,SZV->ZV_TAB+Str(SZV->ZV_ORDER,1),'alltrim(DESCRICAO)')
				cNomeTab :=Posicione('SX2',1,SZV->ZV_TAB,'Alltrim(X2_NOME)')
				//alert('cLayOut='+cLayOut+'->'+&(SZV->ZV_CHAVE)+' len '+CValToChar(len(&(SZV->ZV_CHAVE))))
				//alert('chave completa="'+xFilial(SZV->ZV_TAB)+&(SZV->ZV_CHAVE)+'"')
				//alert('cCpoChave='+cCpoChave)

				dbSelectArea(SZV->ZV_TAB)
				dbSetOrder(SZV->ZV_ORDER)
				dbSeek(xFilial(SZV->ZV_TAB)+&(SZV->ZV_CHAVE),.t.)

				While alltrim(&(cCpoChave))==ALLTRIM(xFilial(SZV->ZV_TAB)+&(SZV->ZV_CHAVE)).and.!eof()
					cCpoBloq	:=SubStr(SZV->ZV_TAB, 2, 2)+"_MSBLQL"
					lTemMsBlq	:=.f.
					DbSelectArea('SX3')
					DbSetOrder(2)
					IF dbSeek(cCpoBloq)
						lTemMsBlq:=.t.
					END
					dbSelectArea(SZV->ZV_TAB)
					If lTemMsBlq
						If &(cCpoBloq)=='1' 
							//MsgInfo('tem bloqueio ','campo '+cCpoBloq+' codigo '+&(cCpoChave))
							dbSelectArea(SZV->ZV_TAB)
							dbSkip()
							lBloqueio:=.T.
							loop
						end
					end
					lAchou:=.t.
					Exit
				end

				IF SZV->ZV_VALIDA='1' .and. !lAchou.and.!lBloqueio    //TESTA NAO EXISTENCIA DO REGISTRO
					fMyMsg(cNomChave+":"+Alltrim(&(SZV->ZV_CHAVE))+' não encontrada na tabela '+cNomeTab+'('+SZV->ZV_TAB+')')
					lErro	:=.t.
					EXIT
				END

				IF SZV->ZV_VALIDA='1' .and. !lAchou.and.lBloqueio    //TESTA NAO EXISTENCIA DO REGISTRO
					fMyMsg(cNomChave+":"+Alltrim(&(SZV->ZV_CHAVE))+' foi localizado mas encontra-se bloqueado na tabela '+cNomeTab+'('+SZV->ZV_TAB+')')
					lErro	:=.t.
					EXIT
				END

				if SZV->ZV_VALIDA='2' .and. lAchou        //TESTA EXISTENCIA DO REGISTRO
					fMyMsg(cNomChave+":"+Alltrim(&(SZV->ZV_CHAVE))+' já existe na tabela '+cNomeTab+'('+SZV->ZV_TAB+')')
					lErro	:=.t.
					EXIT
				END
			end


			//----------------------------------------------
			//CARREGO OS ARRAYS PARA SEREM USADOS NO EXECAUTO
			//----------------------------------------------
			If SZV->ZV_TIPO=='1' //CABEC
				aAdd(aCab,	{ALLTRIM(SZV->ZV_CAMPO)		, &(xVar)	, NIL})
			else
				aAdd(aItem,	{ALLTRIM(SZV->ZV_CAMPO)		, &(xVar)	, NIL})
			END

			dbSelectArea(cTblIte)
			dbskip()
		end

		IF lErro
			SaveLog('2','Documento NÃO será incluido, Ver motivo no Log.',cPath+cFile,cFilePDF,cLog)
			fRenFiles(cFile,2)
			loop //prox arq
		End

		cMensErro:="Os seguintes campos são obrigatório e não foram configurados no layout:"+Chr(13)+Chr(10)
		lNoField:=.F.
		For nC:=1 to Len(aCabObrig)
			IF aScan(aCab,{|x| x[1] == aCabObrig[nC]})==0
				cMensErro+=padr(aCabObrig[nC],50,' ')+Chr(13)+Chr(10)
				lNoField:=.t.
			End
		Next
		For nTT:=1 to Len(aItemObrig)
			IF aScan(aItem,{|x| x[1] == aItemObrig[nTT]})==0
				cMensErro+=PADR(aItemObrig[nTT],50,' ')+Chr(13)+Chr(10)
				lNoField:=.t.
			End
		Next

		If lNoField
			SaveLog('2','Documento NÃO incluido, Ver motivo no Log.',cPath+cFile,cFilePDF,cLog)
			fRenFiles(cFile,2)
			loop //prox arq
		End

		aadd(aItem,{"AUTDELETA" 	, "N" 								, Nil})
		aAdd(aItens, aItem)

		lMsErroAuto := .F.
		If lPreDoc
			MSExecAuto({|x,y,z,w| MATA140(x,y,z,,w)},aCab,aItens,3,nTela)
		Else
			MSExecAuto({|x,y,z,w| MATA103(x,y,z,,w)},aCab,aItens,3,nTela)
		End

		If lMSErroAuto
			aMsg := GetAutoGRLog()
			For nL:=1 to Len(aMsg)
				cLog+=aMsg[nL]+Chr(13)+Chr(10)
			Next

			SaveLog('2','Documento NÃO incluido, Ver erro no Log.',cPath+cFile,cFilePDF,cLog)

			fRenFiles(cFile,2)
		else
			IF !(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA == ;
					M->F1_DOC+M->F1_SERIE+M->F1_FORNECE+M->F1_LOJA)

				//documento não foi gravado, mesmo sem erro (usuaio cancelou)
				cLog+='Documento não foi gravado, mesmo sem erro (usuario cancelou)'
				SaveLog('2','Documento Não Foi Incluido, Ver Log.',cPath+cFile,cFilePDF,cLog)
				fRenFiles(cFile,2)
				loop //prox XML
			End

			//cNewFile:=StrTran(UPPER(cFile),'.XML','.ok')
			SaveLog('1','Documento incluido com Sucesso',cPath+cFile,cFilePDF,clog)
		/*
		nStatus1:=FRenameEx(cPath+cFile,cPath+cNewFile)
		IF nStatus1 == -1
			fMyMsg('Falha na operação 1 : FError '+str(ferror(),4))
		Endif
		*/

			//vou ver todos os PDF que te
			aFilePDF := Directory(cPath+"*.pdf","D")

			for nDX:= 1 to Len(aFilePDF)

				cFilePDF:=aFilePDF[nDX,1]

				//existe o arquivo PDF
				cPathPDF:="\dirdoc\co"+alltrim(SM0->M0_CODIGO)+"\shared\"

				IF __CopyFile(cPath+cFilePDF, cPathPDF+cFilePDF)

					dbSelectArea('ACB')
					reclock('ACB',.t.)
					ACB->ACB_FILIAL:=xFilial('ACB')
					ACB->ACB_CODOBJ:=GETSXENUM('ACB','ACB_CODOBJ')
					ACB->ACB_OBJETO:=cFilePDF
					ACB->ACB_DESCRI:='PDF da NFS-e lançada automaticamente em '+Dtoc(msdate())
					msunlock()
					confirmsx8()

					dbSelectArea('AC9')
					reclock('AC9',.t.)
					AC9->AC9_FILIAL:=xFilial('AC9')
					AC9->AC9_FILENT:=SM0->M0_CODFIL
					AC9->AC9_ENTIDA:='SF1'
					AC9->AC9_CODENT:=SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
					AC9->AC9_CODOBJ:=ACB->ACB_CODOBJ
					msunlock()
					SaveLog('1','PDF Vinculado Sucesso',cPath+cFile,cFilePDF,clog)
				/*
				cNewFile:=StrTran(UPPER(cFilePDF),'.PDF',+"_"+dtos(dDataBase)+"_"+StrTran(time(),":","")+'.pdfnok')
				nStatus1:=FRenameEx(cPath+cFilePDF,cPath+cNewFile)
				IF nStatus1 == -1
					fMyMsg('Falha na operação 1 : FError '+str(ferror(),4))
				Endif
				*/

				Else
					fMyMsg('Não foi possivel copiar o arquivo '+cFilePDF+' para '+cPathPDF)
					SaveLog('2','Não foi possivel vincular PDF',cPath+cFile,cFilePDF,clog)
				/*
				cNewFile:=StrTran(UPPER(cFilePDF),'.PDF',+"_"+dtos(dDataBase)+"_"+StrTran(time(),":","")+'.pdfnok')
				nStatus1:=FRenameEx(cPath+cFilePDF,cPath+cNewFile)
				IF nStatus1 == -1
					fMyMsg('Falha na operação 1 : FError '+str(ferror(),4))
				Endif
				*/
				End
			next

			fRenFiles(cFile,1)

		EndIf

	next  //PROXIMO XML

Return
//-------------------------------------------------------------------------------------------------------------------------
Static Function fTemTag(cConteud,cValRet)
//-------------------------------------------------------------------------------------------------------------------------
	Local nT
	Local lRet:=.t.
	cValRet:=''
	cConteud:=STRTRAN(alltrim(cConteud),"::",":")

	aTags:=StrTokArr(cConteud, ":")

	cAuxObj	:="oXml"
	For nT:=1 to len(aTags)
		oAuxObj:=&(cAuxObj)
		cPesq:='oAuxObj:_'+aTags[Nt]
		if valtype(cPesq)=="U"//type(cPesq)=="U"
			lRet:=.F.
			exit
		end
		cAuxObj+=':_'+aTags[Nt]
	Next
	If lRet
		cValRet:="oXML:_"+STRTRAN(cConteud,":",":_")+":TEXT"
	end

Return lRet
//-----------------------------------------------
Static Function fMyMsg(cTexto,cCabec)
//----------------------------------
IF lJob
		//conout('EVOA600|'+alltrim(cFile)+'|'+dtoc(msdate())+'|'+left(time(),5)+'|'+cTexto) Solutio - Tiengo 13/03/2023
		FWLogMsg("INFO"																,;	//cSeverity      - Informe a severidade da mensagem de log. As opções possíveis são: INFO, WARN, ERROR, FATAL, DEBUG
        			  																,;	//cTransactionId - Informe o Id de identificação da transação para operações correlatas. Informe "LAST" para o sistema assumir o mesmo id anterior
        		"EVOA600"															,;	//cGroup         - Informe o Id do agrupador de mensagem de Log
        																			,;	//cCategory      - Informe o Id da categoria da mensagem
																					,; 	//cStep          - Informe o Id do passo da mensagem
																					,;	//cMsgId         - Informe o Id do código da mensagem
				"alltrim(cFile)+'|'+dtoc(msdate())+'|'+left(time(),5)+'|'+cTexto"	,;	//cMessage       - Informe a mensagem de log. Limitada à 10K
																					,; 	//nMensure       - Informe a uma unidade de medida da mensagem
																					,;	//nElapseTime    - Informe o tempo decorrido da transação
																					;  	//aMessage       - Informe a mensagem de log em formato de Array - Ex: { {"Chave" ,"Valor"} } 
				)
		
	else
		Msgbox(PADR(cTexto,150),padr(cFile,80,' '),'STOP')
		//conout('EVOA600|'+alltrim(cFile)+'|'+dtoc(msdate())+'|'+left(time(),5)+'|'+cTexto) Solutio - Tiengo 13/03/2023
		FWLogMsg("INFO"																,;	//cSeverity      - Informe a severidade da mensagem de log. As opções possíveis são: INFO, WARN, ERROR, FATAL, DEBUG
        			  																,;	//cTransactionId - Informe o Id de identificação da transação para operações correlatas. Informe "LAST" para o sistema assumir o mesmo id anterior
        		"EVOA600"															,;	//cGroup         - Informe o Id do agrupador de mensagem de Log
        																			,;	//cCategory      - Informe o Id da categoria da mensagem
																					,; 	//cStep          - Informe o Id do passo da mensagem
																					,;	//cMsgId         - Informe o Id do código da mensagem
				"alltrim(cFile)+'|'+dtoc(msdate())+'|'+left(time(),5)+'|'+cTexto"	,;	//cMessage       - Informe a mensagem de log. Limitada à 10K
																					,; 	//nMensure       - Informe a uma unidade de medida da mensagem
																					,;	//nElapseTime    - Informe o tempo decorrido da transação
																					;  	//aMessage       - Informe a mensagem de log em formato de Array - Ex: { {"Chave" ,"Valor"} } 
				)

	end
	cLog:=cLog+cTexto+chr(13)+chr(10)

Return

//-----------------------------------------------
Static Function SaveLog(cStatus,cTexto,cFile,cPdf,cLogx)
//----------------------------------
	Local aCpos	:={}
	Local nTam	:=IF(Left(cTblLog,1)=='S',2,3)
	Local nK	:=1
	Aadd(aCpos,{"_FILIAL"	,"xFilial(cTblLog)"})
	Aadd(aCpos,{"_EMPORI"	,"SM0->M0_CODIGO"})
	Aadd(aCpos,{"_STATUS"	,"cStatus"})
	Aadd(aCpos,{"_DESCRI"	,"cTexto"})
	Aadd(aCpos,{"_DOC"		,"M->F1_DOC"})
	Aadd(aCpos,{"_SERIE"	,"M->F1_SERIE"})
	Aadd(aCpos,{"_XML"		,"cFile"})
	Aadd(aCpos,{"_PDF"		,"cPdf"})
	Aadd(aCpos,{"_DATA"		,"dDataBase"})
	Aadd(aCpos,{"_HORA"		,"time()"})
	Aadd(aCpos,{"_IDEMIT"	,"SA2->A2_CGC"})
	Aadd(aCpos,{"_LOG"		,"cLogx"})
	Aadd(aCpos,{"_LAYOUT"	,"clayout"})
	Aadd(aCpos,{"_FILORI"	,"SM0->M0_CODFIL"})

	dbSelectArea(cTblLog)
	reclock(cTblLog,.t.)
	For nK:=1 to Len(aCpos)
		cCampo		:=cTblLog+"->"+Right(cTblLog,nTam)+aCpos[nK,1]
		&(cCampo)	:=&(aCpos[nK,2])
	Next
	msunlock()
Return

//--------------------------------------------------------------
Static Function fTag2Array(cAux)
//-----------------------------------------
	Local cAuxAdd:=""
	Local aAux:={}
	Local nPos:=0

	While !Empty(cAux)
		nPos:=AT(":",cAux)
		If nPos==0
			Exit
		end
		cAuxAdd:=Substr(cAux,1,nPos-1)
		cAux:=Substr(cAux,nPos+1)
		cAuxAdd:=StrTran(cAuxAdd,'-','_')
		Aadd(aAux,cAuxAdd)
	End

	cAux:=StrTran(cAux,'-','_')
	Aadd(aAux,cAux)
Return aAux
//------------------------------------------------------------------------
Static Function fRenFiles(cFile,nSucesso)
//--------------------------------------------
	local nDR
	If nSucesso==1
		cExten:='.OK'
	else
		cExten:='.NOK'
	end
	aFileRen := Directory(cPath+"*.pdf","D")
	for nDR:= 1 to Len(aFileRen)
		cFilePDF:=aFileRen[nDR,1]
		cNewFile:=StrTran(UPPER(cFilePDF),'.PDF',+"_"+dtos(dDataBase)+"_"+StrTran(time(),":","")+'.pdf'+cExten)
		nStatus1:=FRenameEx(cPath+cFilePDF,cPath+cNewFile)
		IF nStatus1 == -1
			fMyMsg('Falha na operação 1 : FError '+str(ferror(),4))
		Endif
	next

	cNewFile:=StrTran(UPPER(cFile),'.XML',+"_"+dtos(dDataBase)+"_"+StrTran(time(),":","")+cExten)
	nStatus1:=FRenameEx(cPath+cFile,cPath+cNewFile)
	IF nStatus1 == -1
		fMyMsg('Falha na operação 1 : FError '+str(ferror(),4))
	Endif
return
