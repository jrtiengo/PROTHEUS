#INCLUDE "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE 'TOPCONN.CH'
#INCLUDE "TBICONN.CH"
#INCLUDE "AP5MAIL.CH"
#INCLUDE "FILEIO.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MARS010  บAutor  ณ Cristiano Oliveira บ Data ณ 23/07/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Envia emails aos clientes informando os titulos vencidos   บฑฑ
ฑฑบ          ณ e/ou a vencer                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบExec.     ณ 07:00 AM                                                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ MARCHER                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MARS010()

Local lAuto := .T.

RPCSetType( 3 ) //Nao consome licensa de uso
PREPARE ENVIRONMENT EMPRESA '01' FILIAL '01' MODULO 'FIN' //USER 'cobranca' PASSWORD '102030' 
	U_MARM010(lAuto)
RESET ENVIRONMENT

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบ MARM010 - CHAMADA DIRETA VIA MENU                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MARM010(lAuto)

Local cTipo    := "" // V = VENCIDOS | A = A VENCER | H = HISTORICO

Local cqSE1V   := "" // QUERY TITULOS VENCIDOS
Local cqSE1A   := "" // QUERY TITULOS A VENCER
Local nDiaVenC := 0  // NR DIAS VENCIDOS
Local nDiaAVen := 0  // NR DIAS A VENCER
Local aTitVenC := {} // TITULOS VENCIDOS
Local aTitAVen := {} // TITULOS A VENCER
Local aCliVenC := {} // CLIENTES VENCIDOS
Local aCliAVen := {} // CLIENTES A VENCER
Local aTiHVenC := {} // TITULOS VENCIDOS HISTORICO
Local aTiHAVen := {} // TITULOS A VENCER HISTORICO
Local aClHVenC := {} // CLIENTES VENCIDOS HISTORICO
Local aClHAVen := {} // CLIENTES A VENCER HISTORICO

nDiaVenC := 2 // GetMV("ES_DIAVENC")
nDiaAVen := 10 // GetMV("ES_DIAAVEN")


//Envio E-mail Tํtulos VENCIDOS
cqSE1V := "SELECT SA1.A1_COD AS CODIGO,SA1.A1_LOJA AS LOJA,SA1.A1_NOME AS NOME,LOWER(SA1.A1_COBMAIL) AS EMAIL, " + CRLF
cqSE1V += "       SE1.E1_NUM AS DUPLICATA,SE1.E1_PARCELA AS PARCELA,SE1.E1_VENCREA AS VENCIMENTO,SE1.E1_SALDO AS VALOR " + CRLF
cqSE1V += "FROM  "+RetSqlName("SE1")+" SE1 INNER JOIN "+RetSqlName("SA1")+" SA1 ON SE1.E1_CLIENTE = SA1.A1_COD AND SE1.E1_LOJA = SA1.A1_LOJA " + CRLF
cqSE1V += "WHERE SE1.D_E_L_E_T_ <> '*' AND SA1.D_E_L_E_T_ <> '*' " + CRLF
cqSE1V += "  AND SE1.E1_SALDO > 0 " + CRLF
//Clientes que possuem RA nใo devem receber info
cqSE1V += "  AND SE1.E1_TIPO = 'NF' " + CRLF
cqSE1V += "  AND SE1.E1_VENCREA <= '"+ DtoS (dDataBase - nDiaVenc) + "'  " + CRLF
cqSE1V += "  AND SA1.A1_COBMAIL LIKE '%@%' AND SA1.A1_COBMAIL LIKE '%.%' " + CRLF
cqSE1V += "ORDER BY SA1.A1_COD,SA1.A1_NOME,SA1.A1_EMAIL " + CRLF

DbUseArea( .T., 'TOPCONN', TCGenQry(,,cqSE1V), 'T_SE1V', .F., .T. )
DBSelectArea("T_SE1V")
DBGoTop()

While T_SE1V->(!EOF())

	cTipo := "V"
	cCodAnt := T_SE1V->CODIGO
	cLojAnt := T_SE1V->LOJA

	AAdd(aCliVenC, {T_SE1V->CODIGO, T_SE1V->LOJA, T_SE1V->NOME, T_SE1V->EMAIL}) // CLIENTE VENCIDOS
	AAdd(aClHVenC, {T_SE1V->CODIGO, T_SE1V->LOJA, T_SE1V->NOME, T_SE1V->EMAIL}) // CLIENTE VENCIDOS HISTORICO

	While T_SE1V->CODIGO == cCodAnt .and. T_SE1V->LOJA == cLojAnt //Mesmo Cliente e Loja
		AAdd(aTitVenC, {T_SE1V->DUPLICATA, T_SE1V->PARCELA, STOD(T_SE1V->VENCIMENTO), T_SE1V->VALOR}) // TITULOS VENCIDOS
		AAdd(aTiHVenC, {T_SE1V->DUPLICATA, T_SE1V->PARCELA, STOD(T_SE1V->VENCIMENTO), T_SE1V->VALOR}) // TITULOS VENCIDOS HISTORICO
		T_SE1V->(DbSkip())
	EndDo

	// ENVIA E-MAIL POR CLIENTE - VENCIDOS A N DIAS OU MAIS
	If Len(aTitVenC) > 0

	IF lauto == Nil
		//MsAguarde({|| U_MARE010(aCliVenC, aTitVenC, cTipo) },'Enviando E-mail de Cobran็a - VENCIDOS')
	ELSE
		U_MARE010(aCliVenC, aTitVenC, cTipo)
	ENDIF

		// LIMPA VENCIDOS
		aTitVenC := {}
		aCliVenC := {}
    EndIf

EndDo //Fim dos Vencidos
T_SE1V->(DbCloseArea())


////Envio E-mail Tํtulos A VENCER
cqSE1A := "SELECT SA1.A1_COD AS CODIGO,SA1.A1_LOJA AS LOJA,SA1.A1_NOME AS NOME,LOWER(SA1.A1_COBMAIL) AS EMAIL, " + CRLF
cqSE1A += "       SE1.E1_NUM AS DUPLICATA,SE1.E1_PARCELA AS PARCELA,SE1.E1_VENCREA AS VENCIMENTO,SE1.E1_SALDO AS VALOR " + CRLF
cqSE1A += "FROM  "+RetSqlName("SE1")+" SE1 INNER JOIN "+RetSqlName("SA1")+" SA1 ON SE1.E1_CLIENTE = SA1.A1_COD AND SE1.E1_LOJA = SA1.A1_LOJA " + CRLF
cqSE1A += "WHERE SE1.D_E_L_E_T_ <> '*' AND SA1.D_E_L_E_T_ <> '*' " + CRLF
cqSE1A += "  AND SE1.E1_SALDO > 0 " + CRLF
cQSE1A += "  AND SE1.E1_TIPO = 'NF' " + CRLF //Clientes que possuem RA nใo devem receber info
cqSE1A += "  AND SE1.E1_VENCREA = '" + DtoS(dDataBase + nDiaAVen) + "' "  + CRLF
cqSE1A += "  AND SA1.A1_COBMAIL LIKE '%@%' AND SA1.A1_COBMAIL LIKE '%.%' " + CRLF
cqSE1A += "ORDER BY SA1.A1_COD,SA1.A1_NOME,SA1.A1_EMAIL " + CRLF

DbUseArea( .T., 'TOPCONN', TCGenQry(,,cqSE1A), 'T_SE1A', .F., .T. )
DBSelectArea("T_SE1A")
DBGoTop()

While T_SE1A->(!EOF())

	cTipo := "A"
	cCodAnt := T_SE1A->CODIGO
	cLojAnt := T_SE1A->LOJA

	AAdd(aCliAVen, {T_SE1A->CODIGO, T_SE1A->LOJA, T_SE1A->NOME, T_SE1A->EMAIL}) // CLIENTE A VENCER
	AAdd(aClHAVen, {T_SE1A->CODIGO, T_SE1A->LOJA, T_SE1A->NOME, T_SE1A->EMAIL}) // CLIENTE A VENCER HISTORICO

	While T_SE1A->CODIGO == cCodAnt .and. T_SE1A->LOJA == cLojAnt //Mesmo Cliente e Loja
		AAdd(aTitAVen, {T_SE1A->DUPLICATA, T_SE1A->PARCELA, STOD(T_SE1A->VENCIMENTO), T_SE1A->VALOR}) // TITULOS A VENCER
		AAdd(aTiHAVen, {T_SE1A->DUPLICATA, T_SE1A->PARCELA, STOD(T_SE1A->VENCIMENTO), T_SE1A->VALOR}) // TITULOS A VENCER HISTORICO
		T_SE1A->(DbSkip())
	EndDo

	// ENVIA E-MAIL POR CLIENTE - A VENCER DAQUI N DIAS
	If Len(aTitAVen) > 0
		IF lauto == Nil
			//MsAguarde({|| U_MARE010(aCliAVen, aTitAVen, cTipo) },'Enviando Email de Cobran็a - A VENCER')
		ELSE
			U_MARE010(aCliAVen, aTitAVen, cTipo)
		ENDIF

		// LIMPA A VENCER
		aTitAVen := {}
		aCliAVen := {}
	EndIf

EndDo
T_SE1A->(DbCloseArea())


// ENVIA E-MAIL DE HISTORICO PARA ADMINISTRADOR DE COBRANCAS
cTipo := "H"

If Len(aTiHVenC) > 0 .OR. Len(aTiHAVen) > 0
    IF lauto == Nil
    	MsAguarde({|| U_MARE010(aClHVenC, aTiHVenC, cTipo, aClHAVen, aTiHAVen) },'Enviando Email de Cobran็a - HISTORICO')
	ELSE
		U_MARE010(aClHVenC, aTiHVenC, cTipo, aClHAVen, aTiHAVen)
	ENDIF
	CONOUT("[MARS010] EXECUTADO EM " + DTOC(dDataBase) + " AS " + Time() + " - ENVIADO COM SUCESSO")
Else
	CONOUT("[MARS010] EXECUTADO EM " + DTOC(dDataBase) + " AS " + Time() + " - NAO HOUVE ENVIO...")
EndIf

Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ MARE010  บAutor  ณ Cristiano Oliveira บ Data ณ 23/07/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ ENVIA EMAILS. SENDMAIL                                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function MARE010(aCliVenC, aTitVenC, cTipo, aClHAven, aTitHAven)

Local cServer	:= GetMV("MV_RELSERV")
Local cUser		:= GetMV("ES_COBUSR") //Login Especํfico para a Rotina
Local cPass		:= GetMV("ES_COBPASS")//Senha Especํfica para a Rotina
Local lAuth		:= GetMV("MV_RELAUTH")
Local nI		:= 0
Local cHtml     := ""

IF cTipo == "H"
	cTo 		:= GetMV("ES_COBMAIL") //Email da Cobranca
	cCopia 		:= ""
	cCopiaOc	:= ""
ELSE
	cTo 		:= alltrim(aCliVenC[01, 04]) //Email do Cliente
	cCopia 		:= GetMV("ES_COBMAIL")		 //Email da Cobranca
	cCopiaOc	:= ""
ENDIF

// CABECALHO E ESTILO DE TABELA
cHtml += ' <!DOCTYPE html>                                                                           '
cHtml += ' <html>                                                                                    '
cHtml += ' <head>                                                                                    '
cHtml += ' <style>                                                                                   '
cHtml += ' table {                                                                                   '
cHtml += '     width:100%;                                                                           '
cHtml += ' }                                                                                         '
cHtml += ' table, th, td {                                                                           '
cHtml += '     border: 1px solid black;                                                              '
cHtml += '     border-collapse: collapse;                                                            '
cHtml += ' }                                                                                         '
cHtml += ' th, td {                                                                                  '
cHtml += '     padding: 15px;                                                                        '
cHtml += '     text-align: left;                                                                     '
cHtml += ' }                                                                                         '
cHtml += ' table#t01 tr:nth-child(even) {                                                            '
cHtml += '     background-color: #eee;                                                               '
cHtml += ' }                                                                                         '
cHtml += ' table#t01 tr:nth-child(odd) {                                                             '
cHtml += '    background-color: #fff;                                                                '
cHtml += ' }                                                                                         '
cHtml += ' table#t01 th {                                                                            '
cHtml += '     background-color: DARKRED;                                                            '
cHtml += '     color: white;                                                                         '
cHtml += ' }                                                                                         '
cHtml += ' </style>                                                                                  '
cHtml += ' </head>                                                                                   '
cHtml += ' <body>                                                                                    '

If cTipo == "V"
	cSubject := "MARCHER - Tํtulos Vencidos"
	cHtml += ' <p>Prezado ' + aCliVenC[01, 03] + ',</p>                                                  '
	cHtml += ' <p>Segue a listagem da(s) duplicata(s) vencida(s) abaixo. Favor verificar.</p>            '
	cHtml += ' <table id="t01">                                                                          '
	cHtml += '   <tr>                                                                                    '
	cHtml += '     <th>DUPLICATA</th>                                                                    '
	cHtml += '     <th>PARCELA</th>                                                                      '
	cHtml += '     <th>VENCIMENTO</th>                                                                   '
	cHtml += '     <th>VALOR</th>                                                                        '
	cHtml += '   </tr>                                                                                   '
	For nI := 1 To Len(aTitVenC)
		cHtml += '   <tr>                                                                                	'
		cHtml += '     <td>' + aTitVenC[nI, 01] + '</td>                                                 	'
		cHtml += '     <td>' + aTitVenC[nI, 02] + '</td>                                                 	'
		cHtml += '     <td>' + DTOC(aTitVenC[nI, 03]) + '</td>                                                 	'
		cHtml += '     <td>' + Transform(aTitVenC[nI, 04], "@E 999,999,999.99" ) + '</td>                                                 	' //Transform(nValue, "@E 999,999.99" )
		cHtml += '   </tr>                                                                               	'
    Next nI
	cHtml += ' </table>                                                                                  '
ElseIf cTipo == "A"
	cSubject	:= "MARCHER - Tํtulos a Vencer"
	cHtml += ' <p>Prezado ' + aCliVenC[01, 03] + ',</p>                                                  '
	cHtml += ' <p>Segue a listagem da(s) duplicata(s) a vencer nos pr๓ximos dias abaixo. Favor verificar.</p> '
	cHtml += ' <table id="t01">                                                                          '
	cHtml += '   <tr>                                                                                    '
	cHtml += '     <th>DUPLICATA</th>                                                                    '
	cHtml += '     <th>PARCELA</th>                                                                      '
	cHtml += '     <th>VENCIMENTO</th>                                                                   '
	cHtml += '     <th>VALOR</th>                                                                        '
	cHtml += '   </tr>                                                                                   '
	For nI := 1 To Len(aTitVenC)
		cHtml += '   <tr>                                                                                	'
		cHtml += '     <td>' + aTitVenC[nI, 01] + '</td>                                                 	'
		cHtml += '     <td>' + aTitVenC[nI, 02] + '</td>                                                 	'
		cHtml += '     <td>' + DTOC(aTitVenC[nI, 03]) + '</td>                                                 	'
		cHtml += '     <td>' + Transform(aTitVenC[nI, 04], "@E 999,999,999.99" ) + '</td>                                                 	'
		cHtml += '   </tr>                                                                               	'
    Next nI
	cHtml += ' </table>                                                                                  '
ElseIf cTipo == "H"
	// HISTORICO CLIENTES VENCIDOS --------------------------------------------------------------------------------
	cSubject	:= "MARCHER - Tํtulos Hist๓rico"
	cHtml += ' <p>Prezado ADMINISTRADOR,</p>                                        '
	cHtml += ' <p>Segue o hist๓rico de e-mails enviados em ' + DtoC(dDataBase) + ' </p> '
	cHtml += ' <table id="t01">                                                                          '
	cHtml += '   <tr>                                                                                    '
	cHtml += '     <th>CODIGO</th>                                                                    '
	cHtml += '     <th>LOJA</th>                                                                      '
	cHtml += '     <th>NOME</th>                                                                   '
	cHtml += '     <th>EMAIL</th>                                                                        '
	cHtml += '   </tr>                                                                                   '
	For nI := 1 To Len(aCliVenC)
		cHtml += '   <tr>                                                                                	'
		cHtml += '     <td>' + aCliVenC[nI, 01] + '</td>                                                 	'
		cHtml += '     <td>' + aCliVenC[nI, 02] + '</td>                                                 	'
		cHtml += '     <td>' + aCliVenC[nI, 03] + '</td>                                                 	'
		cHtml += '     <td>' + aCliVenC[nI, 04] + '</td>                                                 	'
		cHtml += '   </tr>                                                                               	'
    Next nI
	cHtml += ' </table>                                                                                  '
	// HISTORICO TITULOS VENCIDOS --------------------------------------------------------------------------------
	cHtml += ' <table id="t01">                                                                          '
	cHtml += '   <tr>                                                                                    '
	cHtml += '     <th>DUPLICATA</th>                                                                    '
	cHtml += '     <th>PARCELA</th>                                                                      '
	cHtml += '     <th>VENCIMENTO</th>                                                                   '
	cHtml += '     <th>VALOR</th>                                                                        '
	cHtml += '   </tr>                                                                                   '
	For nI := 1 To Len(aTitVenC)
		cHtml += '   <tr>                                                                                	'
		cHtml += '     <td>' + aTitVenC[nI, 01] + '</td>                                                 	'
		cHtml += '     <td>' + aTitVenC[nI, 02] + '</td>                                                 	'
		cHtml += '     <td>' + DTOC(aTitVenC[nI, 03]) + '</td>                                                 	'
		cHtml += '     <td>' + Transform(aTitVenC[nI, 04], "@E 999,999,999.99" ) + '</td>                                                 	'
		cHtml += '   </tr>                                                                               	'
    Next nI
	cHtml += ' </table>                                                                                  '
EndIf

// MENSAGEM PADRAO
cHtml += ' <p>Caso necess&aacute;rio, entrar em contato atrav&eacute;s do telefone (51) 3484-5500 ou e-mail <a href="mailto:cobranca@marcher.com.br">cobranca@marcher.com.br</a></p> '
cHtml += ' <p>Informamos que se o t&iacute;tulo n&atilde;o for pago ap&oacute;s 5 dias do vencimento, o mesmo ser&aacute; encaminhado a cart&oacute;rio.<br />Caso haja t&iacute;tulos protestados, o faturamento de novos pedidos ser&aacute; bloqueado.</p> '
cHtml += ' <p>Se o(s) t&iacute;tulo(os) acima listado(s) j&aacute; foram pagos, favor enviar o comprovante de pagamento para a correta baixa em nosso sistema.<br />Nos colocamos a disposi&ccedil;&atilde;o para qualquer d&uacute;vida e desde j&aacute;, agradecemos a sua aten&ccedil;&atilde;o e parceria mantida at&eacute; o momento.</p> '
cHtml += ' <p></p>'

//Assinatura
cHtml += ' <p> Atenciosamente, <br> '
cHtml += ' Marcher Brasil Agroindustrial SA </p> '

//Finaliza็ใo Html
cHtml += ' </body>                                                                                   '
cHtml += ' </html>                                                                                   '

// conectando-se com o servidor de e-mail
CONNECT SMTP SERVER cServer ACCOUNT cUser PASSWORD cPass RESULT lResult

// fazendo autenticacao
If lResult .And. lAuth
	lResult := MailAuth( cUser, cPass )
	If !lResult
		GET MAIL ERROR cError
      	ConOut( 'Erro de Conectando a conta de e-mail: ' + cError )
    	Return
	EndIf
EndIf

If !lResult
	GET MAIL ERROR cError
	ConOut( 'Erro de Autenticacao no Envio de e-mail: ' + cError )
	Return
EndIf

SEND MAIL FROM cUser TO cTo CC cCopia BCC cCopiaOc SUBJECT cSubject BODY cHTML	/*ATTACHMENT cAttach */ /*FORMAT TEXT*/ RESULT lResult

If ! lResult
	GET MAIL ERROR cError
	ConOut( 'Erro no Envio do e-mail: ' + cError )
EndIf

DISCONNECT SMTP SERVER

Return(Nil)