#Include "Protheus.ch"
#Include "rwmake.ch"
#Include "totvs.ch"
/*
Manutencao documentos pendentes de validacao
Ezequiel Pianegonda
07/11/2020
*/
User Function PS001COM()
	Local cFiltro:= ""

	Local aCores:= {{'SZ1->Z1_LIB == "S"', 'ENABLE'},;
		{'SZ1->Z1_LIB == "P"', 'BR_AMARELO'},;
		{'SZ1->Z1_LIB == "N"', 'DISABLE'}}
			If ! SuperGetMV('ES_PPFRE',.F.,.F.)
		MsgAlert('Empresa não foi configurada para o Paper Free', 'Atenção')
		RETURN
	end

	Private cCadastro:= "Documentos pendentes de validação"
	Private aRotina:= {{"Pesquisar", "axPesqui", 0, 1},;
		{"Libera Doc.", "u_Libera", 0, 4},;
		{"Bloqueia Doc.", "u_Bloqueia", 0, 4},;
		{"Observação", "U_Observa", 0, 4},;
		{"Conhecimento NF", "U_fmybanco", 0, 4},;
		{"Visualizar", "axVisual", 0, 2}}


	/*cFiltro:= "("
	cFiltro+= "(SELECT A2_EGESTOR FROM "+RetSqlTab("SA2")+" WHERE "+RetSqlFil("SA2")+" AND A2_COD = Z1_FORNECE AND A2_LOJA = Z1_LOJA AND "+RetSqlDel("SA2")+") = '"+__cUserID+"' "
	cFiltro+= " OR "
	cFiltro+= "(SELECT A2_EGESSUB FROM "+RetSqlTab("SA2")+" WHERE "+RetSqlFil("SA2")+" AND A2_COD = Z1_FORNECE AND A2_LOJA = Z1_LOJA AND "+RetSqlDel("SA2")+") = '"+__cUserID+"' "
	cFiltro+= ")"*/

	cFiltro+= " ( SELECT COUNT(*) "+chr(13)+chr(10)
	cFiltro+= " FROM "+RETSQLTAB("ZZ2,SA2") +chr(13)+chr(10)
	cFiltro+= " WHERE "+RETSQLDEL("ZZ2,SA2") +chr(13)+chr(10)
	cFiltro+= " AND "+RETSQLFIL("ZZ2,SA2") +chr(13)+chr(10)
	cFiltro+= " AND A2_COD = Z1_FORNECE AND A2_LOJA = Z1_LOJA" +chr(13)+chr(10)
	cFiltro+= " AND A2_GRPAPRO=ZZ2_GRUPO" +chr(13)+chr(10)
	cFiltro+= " AND ZZ2_USER = '"+__cUserID+"') > 0 " +chr(13)+chr(10)

	MEMOWRIT('\logs\filtro.txt',cFiltro)
	

	dbSelectArea("SZ1")
	dbSetOrder(1)

	//SET FILTER TO &(cFiltro)
	mBrowse(,,,,"SZ1",,,,,,aCores,,,,,,,,cFiltro)
Return

/*
Faz a liberacao do documento
*/
user Function Libera()
	Local nOpc:= 0
	Local cTo:= getmv('ES_MAILFIS')  //"ezequiel.pianegonda@primmeti.com.br"
	Local cCC:= ""
	Local cSubject:= "Documento liberado"
	Local cBody:= ""
	Local aAttach:= {}
	Local cSitAtual:=''
	Local cPerfil
	Private lLiberador

	lLiberador:=fQuePerfil(SZ1->Z1_FORNECE,SZ1->Z1_LOJA,__cUserID)

	iF !lLiberador
		MsgInfo('Perfil de '+UsrRetName(__cUserID)+" não é LIBERADOR !")
		Return
	End

	iF lLiberador
		cPerfil:='LIBERADOR'
	ELSE
		cPerfil:='CONTRATANTE'
	END
	If SZ1->Z1_LIB=='P'
		cSitAtual:='Pendente'
	Elseif SZ1->Z1_LIB=='S'
		cSitAtual:='Liberado'
	Elseif SZ1->Z1_LIB=='N'
		cSitAtual:='Bloqueado'
	End

	If SZ1->Z1_LIB <> "P"
		IF !MSGBOX('Documento se encontra '+cSitAtual+chr(13)+chr(10)+;
				'Deseja liberá-lo ?',cSitAtual,'YESNO')
			Return .t.
		End
	End
	RegToMemory("SZ1",.F.,.F.)

	M->Z1_LIB:= "S"

	//Manoel, 24/12. Posicionei SA2 para usar inicializador do campo Z1_CNPJ
	M->Z1_CNPJ:=POSICIONE('SA2',1,xFilial('SA2')+SZ1->Z1_FORNECE+SZ1->Z1_LOJA,'A2_CGC')

	oDlg:= MSDIALOG():New(000, 000, 800, 900, "PERFIL:"+cPerfil+"  |  Liberar documento "+SZ1->Z1_DOC+'/'+SZ1->Z1_SERIE,,,,,,,,,.T.)

	oMsGet:= Msmget():New("SZ1", , 2,,,,,,{"Z1_TIPO","Z1_COND","Z1_BANCO","Z1_AG","Z1_CONTA","Z1_CC","Z1_CNPJ","Z1_OBS"},,,,,oDlg,,.T.)

	oMsGet:oBox:Align:= CONTROL_ALIGN_ALLCLIENT
	TButton():New(20, 10, "Confirmar" , oDlg, {|| nOpc:= 1, oDlg:End()}, 40, 010,,,.F.,.T.,.F.,,.F.,,,.F. )
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, {|| IIf(ValLib(), (nOpc:= 1, oDlg:End()), nOpc:= 0)},{|| nOpc:= 0, oDlg:End()},,)) CENTERED

	If nOpc != 0
		RecLock("SZ1", .F.)

		SZ1->Z1_TIPO:= &("M->Z1_TIPO")
		SZ1->Z1_COND:= &("M->Z1_COND")
		SZ1->Z1_BANCO:= &("M->Z1_BANCO")
		SZ1->Z1_AG:= &("M->Z1_AG")
		SZ1->Z1_CONTA:= &("M->Z1_CONTA")
		SZ1->Z1_LIB:= "S"
		SZ1->Z1_VENCTO:= &("M->Z1_VENCTO")
		SZ1->Z1_CC:= &("M->Z1_CC")
		SZ1->Z1_CNPJ:= &("M->Z1_CNPJ")
		SZ1->Z1_OBS:= &("M->Z1_OBS")
		SZ1->(MsUnLock())

		IF lLiberador
			cBody:=fMontaBody('Documento LIBERADO',1)
			U_EnvMail(cTo, cCC, cSubject, cBody, aAttach)
		END
	Else
		MsgInfo("Cancelado pelo usuário")
	EndIf

Return


//------------------------------------------------------------
//altera a observacao
//----------------------------------------
user Function observa()
	Local nOpc:= 0
	Local cSitAtual:=''
	Local cPerfil
	Private lLiberador

	lLiberador:=fQuePerfil(SZ1->Z1_FORNECE,SZ1->Z1_LOJA,__cUserID)

	iF lLiberador
		cPerfil:='LIBERADOR'
	ELSE
		cPerfil:='CONTRATANTE'
	END

	If SZ1->Z1_LIB=='P'
		cSitAtual:='Pendente'
	Elseif SZ1->Z1_LIB=='S'
		cSitAtual:='Liberado'
	Elseif SZ1->Z1_LIB=='N'
		cSitAtual:='Bloqueado'
	End

	RegToMemory("SZ1",.F.,.F.)

	oDlg:= MSDIALOG():New(000, 000, 800, 900, "PERFIL:"+cPerfil+"  |  Alterar Observação "+SZ1->Z1_DOC+'/'+SZ1->Z1_SERIE,,,,,,,,,.T.)
	//oMsGet:= Msmget():New("SZ1", , 2,,,,,,{"Z1_OBS"},,,,,oDlg,,.T.)
	oMsGet:= Msmget():New("SZ1", , 2,,,,,,{"Z1_TIPO","Z1_COND","Z1_BANCO","Z1_AG","Z1_CONTA","Z1_CC","Z1_CNPJ","Z1_OBS"},,,,,oDlg,,.T.)

	oMsGet:oBox:Align:= CONTROL_ALIGN_ALLCLIENT
	TButton():New(20, 10, "Confirmar" , oDlg, {|| nOpc:= 1, oDlg:End()}, 40, 010,,,.F.,.T.,.F.,,.F.,,,.F. )
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, {|| nOpc:= 1, oDlg:End() },{|| nOpc:= 0, oDlg:End()},,)) CENTERED

	If nOpc != 0
		RecLock("SZ1", .F.)
		SZ1->Z1_TIPO:= &("M->Z1_TIPO")
		SZ1->Z1_COND:= &("M->Z1_COND")
		SZ1->Z1_BANCO:= &("M->Z1_BANCO")
		SZ1->Z1_AG:= &("M->Z1_AG")
		SZ1->Z1_CONTA:= &("M->Z1_CONTA")
		SZ1->Z1_VENCTO:= &("M->Z1_VENCTO")
		SZ1->Z1_CC:= &("M->Z1_CC")
		SZ1->Z1_CNPJ:= &("M->Z1_CNPJ")
		SZ1->Z1_OBS:= &("M->Z1_OBS")
		SZ1->(MsUnLock())
	Else
		MsgInfo("Cancelado pelo usuário")
	EndIf

Return

/*
Validacao da rotian de liberacao
*/
Static Function ValLib()
	Local lRet:= .T.

	If Empty(&("M->Z1_TIPO"))
		MsgInfo("Um ou mais campos obrigatórios não foram preenchidos, verifique.", "PS001COM")
		lRet:= .F.
	EndIf

	If &("M->Z1_TIPO") == "D"
		If Empty(&("M->Z1_COND")) .OR. Empty(&("M->Z1_BANCO")) .OR. Empty(&("M->Z1_AG")) .OR. Empty(&("M->Z1_CONTA")) .OR. Empty(&("M->Z1_CNPJ"))
			MsgInfo("Os campos Vencimento, Banco, Agencia, Conta e CNPJ Destino são obrigatórios para a condição Deposito, verifique.", "PS001COM")
			lRet:= .F.
		EndIf
	EndIf


Return lRet

/*
Faz o bloqueio do documento
*/
user Function Bloqueia()
	Local nOpc:= 0
	Local cTo:= getmv('ES_MAILFIS') //"ezequiel.pianegonda@primmeti.com.br"
	Local cCC:= ""
	Local cSubject:= "Documento bloqueado"
	Local cBody:= ""
	Local aAttach:= {}
	Local cPerfil
	Private lLiberador

	lLiberador:=fQuePerfil(SZ1->Z1_FORNECE,SZ1->Z1_LOJA,__cUserID)

	iF !lLiberador
		MsgInfo('Perfil de '+UsrRetName(__cUserID)+" não é LIBERADOR !")
		Return
	End

	iF lLiberador
		cPerfil:='LIBERADOR'
	ELSE
		cPerfil:='CONTRATANTE'
	END

	If SZ1->Z1_LIB=='P'
		cSitAtual:='Pendente'
	Elseif SZ1->Z1_LIB=='S'
		cSitAtual:='Liberado'
	Elseif SZ1->Z1_LIB=='N'
		cSitAtual:='Bloqueado'
	End
	If SZ1->Z1_LIB <> "P"
		IF !MSGBOX('Documento se encontra '+cSitAtual+chr(13)+chr(10)+;
				'Deseja bloqueá-lo ?',cSitAtual,'YESNO')
			Return .t.
		End
	End

	RegToMemory("SZ1",.F.,.F.)
	M->Z1_LIB:= "N"
	//oDlg:= MSDIALOG():New(000, 000, 500, 600, "Bloquear documento",,,,,,,,,.T.)
	oDlg:= MSDIALOG():New(000, 000, 800, 900, "PERFIL:"+cPerfil+"  |  BLOQUEAR documento "+SZ1->Z1_DOC+'/'+SZ1->Z1_SERIE,,,,,,,,,.T.)
	oMsGet:= Msmget():New("SZ1", , 2,,,,,,{"Z1_MOTREJE"},,,,,oDlg,,.T.)
	oMsGet:oBox:Align:= CONTROL_ALIGN_ALLCLIENT
	TButton():New(20, 10, "Confirmar" , oDlg, {|| nOpc:= 1, oDlg:End()}, 40, 010,,,.F.,.T.,.F.,,.F.,,,.F. )
	ACTIVATE MSDIALOG oDlg ON INIT (EnchoiceBar(oDlg, {|| nOpc:= 1, oDlg:End()},{|| nOpc:= 0, oDlg:End()},,)) CENTERED

	If nOpc != 0
		If Empty(&("M->Z1_MOTREJE"))
			MsgInfo('Motivo da Rejeição Não Informado','Motivo da Rejeição')
			Return
		End

		RecLock("SZ1", .F.)
		SZ1->Z1_MOTREJE:= &("M->Z1_MOTREJE")
		SZ1->Z1_LIB:= "N"
		SZ1->(MsUnLock())
		POSICIONE('SA2',1,xFilial('SA2')+SZ1->Z1_FORNECE+SZ1->Z1_LOJA,'A2_NOME')
        /*cBody:= "Informamos que o documento abaixo foi BLOQUEADO pelo Gestor Responsável"+Chr(13)+chr(10)+;
            "Documento:"+Alltrim(SZ1->Z1_DOC)+" série "+Alltrim(SZ1->Z1_SERIE)+chr(13)+chr(10)+;
            "Fornecedor "+SZ1->Z1_FORNECE+"/"+SZ1->Z1_LOJA+" - "+SA2->A2_NOME+CHR(13)+CHR(10)+;
            "Motivo: "+SZ1->Z1_MOTREJE
            */
		cBody:=fMontaBody('Documento BLOQUEADO',2)

		U_EnvMail(cTo, cCC, cSubject, cBody, aAttach)
	Else
		MsgInfo("Cancelado pelo usuário")
	EndIf

Return
//--------------------------------------------------------------------------
// fmybanco | mostra o banco de conhecimento
// Autor    | Manoel, dez/2020
//------------------------------------------------------------------------------

user Function fmybanco()
	Local aArea:=GetArea()
	Local nOper:=2 //2=altera, 1=  3=

	dbSelectArea('SF1')
	dbSetOrder(1)
	IF !dbSeek(SZ1->(Z1_FILIAL+Z1_DOC+Z1_SERIE+Z1_FORNECE+Z1_LOJA))
		MsgInfo('Documento não encontrado')
		Return
	End
	nRecno:=SF1->(RECNO())

	RestArea(aArea)

	MsDocument('SF1',nRecno,nOper)


Return

//------------------------------------------------------------------------------
Static Function fMontaBody(cTitulo,nOper)
//------------------------------------------------------------------------------
	lOCAL aArea:=GetArea()
	dbSelectArea('SF1')
	dbSetOrder(1)
	dbSeek(SZ1->(Z1_FILIAL+Z1_DOC+Z1_SERIE+Z1_FORNECE+Z1_LOJA))

	dbSelectArea('SD1')
	dbSetOrder(1)
	dbSeek(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))

	dbSelectArea('SB1')
	dbSetOrder(1)
	dbSeek(xfilial('SB1')+SD1->D1_COD)

	nTotNota:=u_fQueTotal() //precisa estar em cima da SF1

	cMensagem := '<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"> '
	cMensagem += '<html> '
	cMensagem += '<head> '
	cMensagem += '  <meta content="text/html; charset=ISO-8859-1" http-equiv="content-type"> '
	cMensagem += '  <title> '+cTitulo+'</title> '
	cMensagem += '</head> '
	cMensagem += '<body> '
	cMensagem += '<hr>'
	cMensagem += '<img src="https://www.evora.com/images/logo@2x.png" > '
	cMensagem += '<br> '
	cMensagem += '<br> '
	cMensagem += '<hr>'
	cMensagem += '<FONT COLOR=BLACK SIZE="4"> '+cTitulo+' </FONT>'
	cMensagem += '<br> '
	cMensagem += '<hr>'
	cMensagem += '<tit> Empresa:'+SM0->M0_CODIGO+'-'+SM0->M0_NOME+'</tit>'
	cMensagem += '<hr>'
	cMensagem += '<table> '
	cMensagem += '<TABLE BORDER=1 BORDERCOLOR=BLUE >'
	cMensagem += '<tr>'
	cMensagem += '<th ROWSPAN=2 WIDTH=300 BGCOLOR=YELLOW><FONT COLOR=BLACK>Documento</th>'
	cMensagem += '<th ROWSPAN=2 WIDTH=400 BGCOLOR=YELLOW><FONT COLOR=BLACK>Fornecedor</th>'
	cMensagem += '<th ROWSPAN=2 WIDTH=100 BGCOLOR=YELLOW><FONT COLOR=BLACK>Emissão</th>'
	cMensagem += '<th ROWSPAN=2 WIDTH=150 BGCOLOR=YELLOW><FONT COLOR=BLACK>Valor</th>'
	cMensagem += '<th ROWSPAN=2 WIDTH=150 BGCOLOR=YELLOW><FONT COLOR=BLACK>Serviço</th>'
	cMensagem += '<th ROWSPAN=2 WIDTH=150 BGCOLOR=YELLOW><FONT COLOR=BLACK>Observação</th>'
	If nOper=2 //rejeicao
		cMensagem += '<th ROWSPAN=2 WIDTH=150 BGCOLOR=YELLOW><FONT COLOR=BLACK>Motivo Rejeição</th>'
	end
	cMensagem += '</tr>'
	cMensagem += '<tr>'
	cMensagem += '</tr>'
	cMensagem += '<tr>'
	cMensagem += '<td <FONT COLOR=BLACK> '+SF1->F1_DOC+'/'+SF1->F1_SERIE+'</td>'
	cMensagem += '<td <FONT COLOR=BLACK>'+SA2->A2_NOME+'</td>'
	cMensagem += '<td <FONT COLOR=BLACK ALIGN=MIDDLE>'+dtoc(SF1->F1_EMISSAO)+'</td>'
	cMensagem += '<td <FONT COLOR=BLACK ALIGN=MIDDLE>'+TRANSFORM(nTotNota,"@E 9999,999,999.99")+'</td>'
	//cMensagem += '<td <FONT COLOR=BLACK ALIGN=MIDDLE>'+TRANSFORM(SD1->D1_TOTAL,"@E 9999,999,999.99")+'</td>'
	cMensagem += '<td <FONT COLOR=BLACK ALIGN=MIDDLE>'+alltrim(SB1->B1_DESC)+'</td>'
	cMensagem += '<td <FONT COLOR=BLACK ALIGN=MIDDLE>'+SZ1->Z1_OBS+'</td>'
	If nOper=2 //rejeicao
		cMensagem += '<td <FONT COLOR=BLACK ALIGN=MIDDLE>'+SZ1->Z1_MOTREJE+'</td>'
	END
	cMensagem += '</tr>'
	cMensagem += '</table> '
	cMensagem += '<br> '
	cMensagem += '<hr>'
	cMensagem += 'E-mail gerado automaticamente pelo Protheus em '+dtoc(msdate())+' as '+left(time(),5)
	cMensagem += '<br> '
	RestArea(aArea)
Return cMensagem

//-------------------------------------------------------------------
Static Function fQuePerfil(cForn,cLoja,cUSR)
//-------------------------------------------------------------------
	Local cQuery:='',lLib:=.t.
	Local aArea:=GetArea()

	cQuery+=" SELECT * "
	cQuery+=" FROM "+RetSqlTab("ZZ2,SA2")
	cQuery+=" WHERE "+RetSqlFil("ZZ2,SA2")
	cQuery+=" AND "+RetSqlDel("ZZ2,SA2")
	cQuery+=" AND ZZ2_GRUPO=A2_GRPAPRO "
	cQuery+=" AND ZZ2_USER='"+cUSR+"' "
	cQuery+=" AND A2_COD='"+cForn+"' "
	cQuery+=" AND A2_LOJA='"+cLoja+"' "

	//MEMOWRIT('\logs\evoa603.SQL', cQuery)

	dbUseArea(.t., "TOPCONN", TcGenQry(,,cQuery), "TRBZ", .t., .t.)

	dbSelectArea('TRBZ')
	If TRBZ->ZZ2_TIPO='1'
		lLib:=.f.
	ELSEIf TRBZ->ZZ2_TIPO='2'
		lLib:=.t.
	end
	dbclosearea()
	RestArea(aArea)

Return lLib
