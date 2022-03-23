#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"

/*
Jean Rehermann - Solutio IT - 09/11/2021
Programa criado para fazer a conciliação automática do retorno do DDA
Execução será via Schedule, necessário ter feito os retornos do rastreamento
Original: Cristiano Machado
*/
User Function AUTODDA()

	Private lBlind   := Isblind()
	Private bProcInc := {||Iif(!lBlind,IncProc(),0) }
	Private nTotConc := 0
	Private aLogDDA	 := {}
	Private cCurACo	 := GetNextAlias()
	Private cCurSE2  := GetNextAlias()

	If lBlind
		CriaEnvDDA() // Cria Ambiente para executar o processo via Schedule
	Else
		ProcRegua(0)
	EndIf

	Eval( bProcInc )

	DdaFigCon() // Efetua a busca dos registros pendentes de conciliação

	Eval( bProcInc )

	AvalReg() // Avalia Registros para efetuar ou não a conciliação

	SendLog() // Envia o Log por e-mail

	Eval( bProcInc )

	If lBlind
		RpcClearEnv() // Encerra o Ambiente...
	Else
		MsgAlert("Conciliado com sucesso!")
	EndIf

Return Nil

/*
Cria o ambiente para a execução do processo no schedule
*/
Static Function CriaEnvDDA()

	Local cRpcEmp		:= "01"			// Empresa
	Local cRpcFil		:= "01"			// Filial Principal
	Local cEnvUser		:= ""
	Local cEnvPass		:= ""
	Local cEnvMod		:= "FIN"		// Modulo
	Local cFunName		:= "DDAConAut"	// Funcao
    Local aTables 		:= {"FIG","SE2","SA2"}

	//O comando RpcSetEnv() é utilizado para abertura de ambiente em rotinas automática
	RpcSetEnv( cRpcEmp , cRpcFil , cEnvUser, cEnvPass, cEnvMod, cFunName , aTables, , , ,  )

Return Nil

/*
Efetua a consulta dos registros pendentes de conciliação
*/
Static Function DdaFigCon()

	Local cSql      := ""
	Local sDtVenI   := DToS( DataRef( -1 , lUlt := .F.) )
	Local sDtVenF   := DToS( DataRef( +3 , lUlt := .T.) )

	cSql += "SELECT FIG.FIG_DATA, FIG.FIG_TITULO, FIG.FIG_CNPJ , FIG.FIG_VENCTO, FIG.FIG_VALOR , FIG.FIG_CODBAR , FIG.R_E_C_N_O_ RECFIG "
	cSql += "FROM "+ RetSqlName("FIG") +" FIG "
	cSql += "WHERE FIG.FIG_CONCIL = '2' " //-- Nao conciliado...
	cSql += "AND FIG.FIG_VENCTO BETWEEN '"+ sDtVenI +"' AND '"+ sDtVenF +"'  " //---- VENCIMENTO UM MES ANTERIOR ATE TRES MESES FUTUROS
	cSql += "AND FIG.D_E_L_E_T_ = ' ' "
	cSql += "ORDER BY FIG_VENCTO, FIG_DATA  "

	dbUseArea(.T., "TOPCONN", TCGenQry( NIL, NIL, cSql ), cCurACo, .F., .T. )

Return Nil

/*
Avaliação dos registros selecionados para efetuar a conciliação
*/
Static Function AvalReg() // Avalia Registros para conciliar...

	Local nRecSE2 := 0
	Local nRecFIG := 0
	Local cModo   := ""

	DbSelectArea(cCurACo)
	DbGotop()

	While !EOF()

		nRecSE2 := ConSE2(@cModo) // Consulta Registro DDA nos Titulos a Pagar...
		nRecFIG := (cCurACo)->RECFIG

		If nRecSE2 > 0 .And. nRecFIG > 0
			ConDDASE2( nRecFIG, nRecSE2, cModo ) // Concilia Registro DDA(FIG) com SE2
			nTotConc += 1
		EndIf

		nRecSE2 := nRecFIG := 0

		Eval(bProcInc)

		dbSelectArea(cCurACo)
		dbSkip()

	EndDo

	dbSelectArea(cCurACo)
	dbCloseArea()

Return Nil

/*
Consulta Registro DDA nos Titulos a Pagar, de três maneiras diferentes
*/
Static Function ConSE2( cModo )

	Local nRecSE2   := 0

	// BUSCA HARD - É mais precisa porém tem menos chances de encontrar
	If nRecSE2 == 0

		GetSE2( cModo := "HARD" )

		DbSelectArea(cCurSE2);DbGoTop()
		If !EOF()
			nRecSE2 := (cCurSE2)->RECSE2
		EndIf

		DbSelectArea(cCurSE2)
		DbCloseArea()
	EndIf

	// BUSCA SOFT - É menos precisa pois permite uma abertura nos parâmetros
	If nRecSE2 == 0

		GetSE2( cModo := "SOFT" )
		DbSelectArea(cCurSE2);DbGoTop()
		If !EOF()
			nRecSE2 := (cCurSE2)->RECSE2
		EndIf

		DbSelectArea(cCurSE2)
		DbCloseArea()

	EndIf

	// BUSCA MAXIMA -- PERMITE UMA ABERTURA PEQUENA DOS PARAMETROS E GRANDE DE VENCIMENTO MAS ADICIONA O NUMERO DO TITULO NO FILTRO
	If nRecSE2 == 0

		GetSE2( cModo := "FMAX" )
		DbSelectArea(cCurSE2);DbGoTop()
		If !EOF()
			nRecSE2 := (cCurSE2)->RECSE2
		EndIf

		DbSelectArea(cCurSE2)
		DbCloseArea()

	EndIf

Return nRecSE2

/*
Tenta obter o título do SE2
*/
Static Function GetSE2( cModo )

	Local cSql      := ""
	Local nIdMax    := 6 // Intervalo Maximo de Dias a usar na Busca Maxima...
	Local sVenRI    := (cCurACo)->FIG_VENCTO
	Local sVenRF    := (cCurACo)->FIG_VENCTO
	Local nValI     := (cCurACo)->FIG_VALOR
	Local nValF     := (cCurACo)->FIG_VALOR
	Local cCnpjR    := SubStr( (cCurACo)->FIG_CNPJ,1,8) // CNPJ RAIZ
	Local cTitul    := Alltrim((cCurACo)->FIG_TITULO)

	If cModo == "SOFT" // No Modo SOFT Abre um pouco os parametros de FILTRO...

		sVenRI  := DToS(SToD(sVenRI) - 1)
		sVenRF  := DToS(SToD(sVenRF) + 1)
		nValI   := nValI - 1
		nValF   := nValF + 1

	ElseIf cModo == "FMAX" // Find Maxima

		sVenRI  := DToS(SToD(sVenRI) - nIdMax)
		sVenRF  := DToS(SToD(sVenRF) + nIdMax)
		nValI   := nValI - 1
		nValF   := nValF + 1

	EndIf

    cSql += "SELECT E2_EMISSAO, E2_FORNECE, E2_LOJA, E2_VENCTO, E2_VENCREA,"
	cSql += " E2_BAIXA, E2_VALOR, E2_SALDO, E2_CODBAR, R_E_C_N_O_ RECSE2 "
    cSql += "FROM "+ RetSqlName("SE2") +" SE2 "
    cSql += "WHERE D_E_L_E_T_ = ' ' "
    cSql += "AND   E2_VENCREA BETWEEN '"+ sVenRI +"' AND '"+ sVenRF +"' "
    cSql += "AND   E2_VALOR BETWEEN "+ cValToCHar( nValI ) +" AND "+ cValToCHar( nValF ) +"  "
    cSql += "AND   E2_FORNECE IN ( ( SELECT A2_COD FROM SA2010 WHERE A2_CGC LIKE '"+ cCnpjR +"%' ) )  "
    cSql += "AND   E2_CODBAR = ' ' "
    cSql += "AND   '"+ cTitul +"' LIKE '%'+ RIGHT( LTRIM( RTRIM( E2_NUM ) ), 6 ) +'%' "

	dbUseArea(.T., "TOPCONN", TCGenQry(NIL,NIL,cSql), cCurSE2, .F., .T. )

Return

/*
Concilia Registro DDA(FIG) com SE2
*/
Static Function ConDDASE2( nRecFIG, nRecSE2, cModo )

	Local nRecE2Va := 0 // Auxiliar pra Validar Recno SE2
	Local nRecIGVa := 0 // Auxiliar pra Validar Recno FIG

	Local lPosSE2  := .F. // Identifica se Posicionou no SE2
	Local lPosFIG  := .F. // Identifica se Posicionou no FIG


	DbSelectArea("SE2")
	DbGoto(nRecSE2)
	nRecE2Va := SE2->( Recno() )
	If nRecE2Va == nRecSE2
		lPosSE2 := .T.
	EndIf

	DbSelectArea("FIG")
	DbGoto(nRecFIG)
	nRecIGVa := FIG->( Recno() )
	If nRecIGVa == nRecFIG
		lPosFIG := .T.
	EndIf


	If lPosSE2 .And. lPosFIG
/*
		dbSelectArea("SE2")
		RecLock("SE2",.F.)
			SE2->E2_CODBAR := FIG->FIG_CODBAR
		MsUnLock()

		dbSelectArea("FIG")
		RecLock("FIG",.F.)
			FIG->FIG_FORNEC 	:= SE2->E2_FORNECE
			FIG->FIG_LOJA 	    := SE2->E2_LOJA
			FIG->FIG_NOMFOR 	:= SE2->E2_NOMFOR
			FIG->FIG_CONCIL 	:= '1'
			FIG->FIG_DTCONC     := dDataBase
			FIG->FIG_USCONC     := "PROTHEUS"
			FIG->FIG_DDASE2     := xFilial("SE2") +"|"+ SE2->E2_PREFIXO+"|"+SE2->E2_NUM+"|"+SE2->E2_PARCELA+"|"+SE2->E2_TIPO+"|"+SE2->E2_FORNECE+"|"+SE2->E2_LOJA+"|"
		MsUnLock()
*/
		// Adiciona ao LOG
		aIte := {}
		aAdd( aIte, cModo                                                    )
		aAdd( aIte, SE2->E2_PREFIXO                                          )
		aAdd( aIte, SE2->E2_NUM                                              )
		aAdd( aIte, SE2->E2_PARCELA                                          )
		aAdd( aIte, SE2->E2_TIPO                                             )
		aAdd( aIte, SE2->E2_FORNECE +"-"+ SE2->E2_LOJA                       )
		aAdd( aIte, Alltrim(Transform( SE2->E2_VALOR , "@E 999,999,999.99")) )
		aAdd( aIte, cValToChar(SE2->E2_VENCREA)                              )
		aAdd( aIte, SE2->E2_CODBAR                                           )
		aAdd( aIte, Alltrim( cValToChar(nRecFIG))                            )
		aAdd( aIte, Alltrim( cValToChar(nRecSE2))                            )

		AAdd( aLogDDA , aIte )

	EndIf

Return Nil

/*
Envia o Log
*/
Static Function SendLog()

    Local cFrom 	:= AllTrim( GetMV("MV_RELACNT") )
	Local cTo		:= SuperGetMv( "ES_DDAMAIL", .F., "jean.rehermann@solutio.inf.br;vbarros@marcher.com.br" )
	Local cSubject 	:= "Conciliação Automatica DDA"
	Local cHtml    	:= ""
    Local nTC       := 0

    // Cabecalho HTML
    CabHtml(@cHtml)

    // Detalhe HTML
    For nTC := 1 To Len(aLogDDA)
        DetHtml( nTC, aLogDDA[nTC],  @cHtml )
    Next

	// Rodapé
    cHtml += '</table></body </html>'

	// Faz o envio do e-mail
	If Len(aLogDDA) > 0
	    SndLogMail( cFrom, cTo, cSubject, cHtml )
	EndIf

Return Nil

/*
Monta Cabecalho Html
*/
Static Function CabHtml( cHtm )

	Default cHtm := ""

	cHtm += '<!DOCTYPE html>'
	cHtm += '<html>'
	cHtm += '<head>'
	cHtm += '<body><h2 style="font-family: Calibri">Abaixo segue lista de títulos à pagar conciliados pelo DDA...:</h2>'
	cHtm += '<table style="font-family: Calibri;border-collapse: collapse;width: 100%;">'

	cHtm += '<tr style="border: 1px solid #dddddd; text-align: center;padding: 4px">'
	cHtm +=     '<th style="background-color: #dddddd">METODO</th>'
	cHtm +=     '<th style="background-color: #dddddd">PREFIXO</th>'
	cHtm +=     '<th style="background-color: #dddddd">N.TITULO</th>'
	cHtm +=     '<th style="background-color: #dddddd">PARCELA</th>'
	cHtm +=     '<th style="background-color: #dddddd">TIPO</th>'
	cHtm +=     '<th style="background-color: #dddddd">FORNECEDOR</th>'
	cHtm +=     '<th style="background-color: #dddddd">VALOR</th>'
	cHtm +=     '<th style="background-color: #dddddd">VENCIMENTO</th>'
	cHtm +=     '<th style="background-color: #dddddd">CODIGO BARRAS</th>'
	cHtm +=     '<th style="background-color: #dddddd">REG DDA</th>'
	cHtm +=     '<th style="background-color: #dddddd">REG FIN</th>'
	cHtm += '</tr>'

Return Nil

/*
Monta Detalhe Html
*/
Static Function DetHtml( nL, aItem, cHtm )

    Local cColor := ""
    Local cSpace := "&nbsp;"

    Default cHtm    := ""
    Default aItem   := {}
    Default nL      := 0

    If Empty(cHtm) .Or. Empty(cHtm) .Or. nL == 0
        Return  Nil
    EndIf

    cHtm += '<tr style="border: 1px solid #dddddd; text-align: center;padding: 4px;'

    // Tratamento Zebrado...
    If (nL % 2) == 0 // Linha PAR
        cHtm += 'background-color: #dddddd">'
    Else // Linha IMPAR
        cHtm += '">'
    EndIf

    If Alltrim(aItem[1]) == "HARD" // Tenta Obter o Titulo com os parametros exatos...
        cColor := "Blue"
    ElseIf Alltrim(aItem[1])== "SOFT" // Tenta Obter Titulo abrindo os parametros ...
        cColor := "Orange"
    ElseIf Alltrim(aItem[1]) == "FMAX" // Tenta Obter Titulo abrindo os parametros ao Maximo ...
        cColor := "Red"
    EndIf

    cHtm +=     '<td style="color:'+cColor+';"><b>' + aItem[01] +'</b></td>'
    cHtm +=     '<td>'+ aItem[02] +'</td>'
    cHtm +=     '<td>'+ aItem[03] +'</td>'
    cHtm +=     '<td>'+ aItem[04] +'</td>'
    cHtm +=     '<td>'+ aItem[05] +'</td>'
    cHtm +=     '<td>'+ aItem[06] +'</td>'
    cHtm +=     '<td style="text-align: rigth;">R$'+ StrTran(PadL(aItem[07],14,Space(1)),Space(1),cSpace) + '</td>'
    cHtm +=     '<td>'+ aItem[08] +'</td>'
    cHtm +=     '<td>'+ aItem[09] +'</td>'
    cHtm +=     '<td>'+ aItem[10] +'</td>'
    cHtm +=     '<td>'+ aItem[11] +'</td>'
    cHtm += '</tr>'

Return Nil

/*
Chamada do Processo de Conciliacao de Forma Manual pelo PE F260BUT
*/
User Function DDAConMan(ParamIXB)

    Processa( {|lEnd| U_AUTODDA() }, "Aguarde...", "Conciliando os Títulos com o DDA...",.F.)

Return Nil

/*
Avança ou Retroage a data conforme nMeses
*/
Static Function DataRef( nMeses, lUlt, dDataAlvo )

 	Local dDataAux 	:= dDataBase
 	Local nI		:= 0

 	Default nMeses 		:= 0			// Meses : Inteiro positivo avança , Inteiro Negativo Retroage apartir da DataAlvo ou dDataBase.
 	Default lUlt 		:= .F.			// Ultimo dia do Mês ?  .T. -> Retorna Ultimo dia do Mês .F. -> Retorna Primeiro dia do Mês
	Default dDataAlvo 	:= dDataBase    // Data Alvo : Qual a dataBase para Avançar ou Retroagir ? Default dDataBase

	// Inicializa Data Auxiliar com Data Alvo...
	dDataAux := dDataAlvo

	// Verifica se deseja Avançar ou Retroagir e Ajusta os Parametros...
	If nMeses < 0
		nTipo 	:= 1 	// 1 - Primeiro dia útil do mês;
		nFator 	:= (-7)
	ElseIf nMeses >= 0
		nTipo 	:= 0 		// 0 ou Branco - Último dia do mês em Pauta;
		nFator 	:= (+1)
	EndIf

	// Percorre Periodo
 	For nI := 1 To Abs( nMeses )
 		dDataAux := LastDay( dDataAux , nTipo ) + nFator
 	Next

	// Joga a Data Final para o Primeiro Dia...
 	dDataAux := CToD( '01/' + Substr( dToC( dDataAux ) , 4, 7 ) )

	// Se deseja Ultimo dia Faz a Troca neste momento...
 	If lUlt
 		dDataAux := LastDay( dDataAux , 0 )
 	EndIf

Return dDataAux  // Retorno data em Formato Data.

/*
Faz o envio de e-mail
*/
Static Function SndLogMail( cFrom, cTo, cSubject, cHtml )

	Local cServer   := AllTrim( GetMV("MV_RELSERV") )
	Local cAccount  := cFrom
	Local cEmailTo  := cTo
	Local cPassword := AllTrim( GetMV("MV_RELPSW")  )
	Local lAuth     := GetMV("MV_RELAUTH")
	Local cAssunto  := cSubject
	Local lResult   := .F.
	Local cError    := ""

	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult

	If lResult .And. lAuth
		lResult := MailAuth( cAccount, cPassword )
		If !lResult
			GET MAIL ERROR cError
			Conout("AUTODDA - Erro de autenticacao email : "+ cError )
			Return Nil
		Endif
	Else
		If !lResult
			GET MAIL ERROR cError
			Conout("AUTODDA - Erro de conexao com servidor SMTP : "+ cError )
			Return Nil
		Endif
	EndIf

	If lResult

		SEND MAIL FROM cAccount;
		TO cEmailTo;
		SUBJECT cAssunto;
		BODY cHtml;
		RESULT lResult

		If !lResult
			GET MAIL ERROR cError
			Conout("AUTODDA - Erro no envio do e-mail : "+ cError )
		EndIf

		DISCONNECT SMTP SERVER

	Else
		Conout('AUTODDA - Ocorreu um erro durante o envio do Email!')
	EndIf

Return
