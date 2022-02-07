#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "Report.ch"
#INCLUDE "SRMT150.CH"
#INCLUDE "FILEIO.CH"

// Posições do array aPedidos
#DEFINE POS_NUMPC	1
#DEFINE POS_PLACA	2
#DEFINE POS_OBSERVA	3
#DEFINE POS_FORNECE	4
#DEFINE POS_LOJA	5
#DEFINE POS_NREDUZ	6
#DEFINE POS_EMAIL	7
#DEFINE POS_EMAILCC	8
#DEFINE POS_RECSA2	9
#DEFINE POS_RECSC7	10

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MNTA420I ³ Autor ³ Jorge Alberto-Solutio ³ Data ³25/02/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ PE para a criação de opções customizadas no menu padrão da ³±±
±±³          ³ rotina de Ordem de Serviço Corretiva.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_MNTA420I()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL											              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico para a empresa Sirtec                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
User Function MNTA420I()

	Local aRotina := PARAMIXB[1]

	AAdd( aRotina, { 'Enviar PC', 'U_M42ENVPC', 0, 4 } )

Return( aRotina )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ M42ENVPC ³ Autor ³ Jorge Alberto-Solutio ³ Data ³25/02/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Envio por e-mail para o Fornecedor do(s) PC('s) vinculadas ³±±
±±³          ³ a Orderm de Serviço posicionado.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_M42ENVPC()                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL											              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico para a empresa Sirtec                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
User Function M42ENVPC()

	Local aAreaSA2 := SA2->( GetArea() )
	Local aAreaSC7 := SC7->( GetArea() )
	Local aAreaSTJ := STJ->( GetArea() )
	Local aArea := GetArea()
	Local aPedidos := {}
	Local aEmails := {}
	Local nPedido := 0
	Local cAliAtu := Alias()
	Local cAnexo := ""
	Local cAssunto := ""
	Local cEmailFor := ""
	Local cEmailCC := Space(500)
	Local cMensagem := ""
	Local cDescMsg := ""
	Local cQuery := ""
	Local cAliPC := GetNextAlias()
	Local lSendMail := .F.

	DEFINE FONT oFont  NAME "Courier New" SIZE 0,-11

	Begin Sequence

		cQuery := ""
		cQuery += "SELECT STL.TL_NUMPC, SC7.C7_FORNECE, SC7.C7_LOJA, SA2.A2_NREDUZ, SA2.A2_EMAIL, SA2.A2_EMAILCC, SC7.R_E_C_N_O_ AS RECSC7, SA2.R_E_C_N_O_ AS RECSA2 "
		cQuery += ", STJ.TJ_ORDEM, STJ.TJ_VEICULO, CTD.CTD_DESC01 AS PLACA, ISNULL(CONVERT(VARCHAR(1024),CONVERT(VARBINARY(1024),STJ.TJ_OBSERVA)),'') AS TJ_OBSERVA "
		cQuery += "FROM " + RetSqlName("STJ") + " STJ "
		cQuery += "INNER JOIN " + RetSqlName("STL") + " STL ON ( STJ.TJ_FILIAL = STL.TL_FILIAL AND STJ.TJ_ORDEM = STL.TL_ORDEM AND STJ.TJ_PLANO = STL.TL_PLANO AND STL.D_E_L_E_T_ = ' ' ) "
		cQuery += "INNER JOIN " + RetSqlName("CTD") + " CTD ON ( STJ.TJ_VEICULO = CTD.CTD_ITEM AND CTD.D_E_L_E_T_ = ' ' ) "
		cQuery += "INNER JOIN " + RetSqlName("SC7") + " SC7 ON (SC7.C7_FILIAL = '" + xFilial("SC7") + "' AND STL.TL_NUMPC = SC7.C7_NUM AND SC7.D_E_L_E_T_ = ' ' ) "
		cQuery += "INNER JOIN " + RetSqlName("SA2") + " SA2 ON (SA2.A2_FILIAL = '" + xFilial("SA2") + "' AND SC7.C7_FORNECE = SA2.A2_COD AND SC7.C7_LOJA = SA2.A2_LOJA AND SA2.D_E_L_E_T_ = ' ' ) "
		cQuery += "WHERE STJ.D_E_L_E_T_ = ' ' "
		cQuery += "AND STJ.TJ_ORDEM = '" + STJ->TJ_ORDEM + "' "
		cQuery += "ORDER BY STL.TL_NUMPC "

		cQuery := ChangeQuery(cQuery)
		//MemoWrit( "c:\temp\PE_MNTA420I.sql ", cQuery )

		DbUseArea(.T.,"TOPCONECT",TcGenQry(,,cQuery),cAliPC,.F.,.F.)

		While (cAliPC)->( !EOF() )
			/*
			#DEFINE POS_NUMPC	1
			#DEFINE POS_PLACA	2
			#DEFINE POS_OBSERVA	3
			#DEFINE POS_FORNECE	4
			#DEFINE POS_LOJA	5
			#DEFINE POS_NREDUZ	6
			#DEFINE POS_EMAIL	7
			#DEFINE POS_EMAILCC	8
			#DEFINE POS_RECSA2	9
			#DEFINE POS_RECSC7	10
			*/
			If aScan( aPedidos, {|x| x[POS_NUMPC] == (cAliPC)->TL_NUMPC } ) <= 0
				AADD( aPedidos, { (cAliPC)->TL_NUMPC, (cAliPC)->PLACA, (cAliPC)->TJ_OBSERVA, (cAliPC)->C7_FORNECE, (cAliPC)->C7_LOJA, (cAliPC)->A2_NREDUZ, (cAliPC)->A2_EMAIL, (cAliPC)->A2_EMAILCC, (cAliPC)->RECSA2, (cAliPC)->RECSC7 } )
			EndIf

			(cAliPC)->( DbSkip() )
		EndDo
		(cAliPC)->( DbCloseArea() )

		If Len( aPedidos ) <= 0
			MsgAlert( "Não existem Pedidos de Compras para os Insumos da OS " + STJ->TJ_ORDEM )
			Break // Vai para o próximo comando após o End Sequence
		EndIf

		If !MsgYesNo( "Confirma o envio de e-mail para o Fornecedor do Pedido de Compra relacionada a OS posicionada ?", "Envio de PC" )
			Break // Vai para o próximo comando após o End Sequence
		EndIf

		For nPedido := 1 To Len( aPedidos )

			cAnexo := ""
			cEmailFor := Space(100)
			cEmailCC := Space(500)
			cAssunto := Space(300)
			cDescMsg := ""
			cMensagem := ""
			lSendMail := .F.

			cEmailFor := PadR( AllTrim( aPedidos[ nPedido, POS_EMAIL ] ), 100, "" )
			cEmailCC := StrTran( PadR( AllTrim( aPedidos[ nPedido, POS_EMAILCC ] ), 250, "" ), ",", ";" )
			cAssunto := PadR( AllTrim( aPedidos[ nPedido, POS_NREDUZ ] ) + " Placa " + AllTrim( aPedidos[ nPedido, POS_PLACA ] ) + " " + AllTrim( StrTran( aPedidos[ nPedido, POS_OBSERVA ], CRLF, "" ) ), 300, "" )
			cDescMsg := "Segue pedido de compra, qual autoriza a emissão da nota, favor observar o número deste pedido nas informações complementares "+;
						" da nota e enviá-la juntamente com o boleto e arquivo XML para o email nota@sirtec.com.br." + CRLF +;
						"VENCIMENTOS: O vencimento dos títulos deverão seguir os prazos descritos no pedido e coincidir em QUINTAS-FEIRAS, " +;
						" podendo então o prazo ser maior que 30 dias. " + CRLF +;
						"ATENÇÃO: O ENVIO DO XML DA NOTA DE PRODUTO E SERVIÇO CONSTANDO O NÚMERO DO PEDIDO É OBRIGATÓRIO, O NÃO ENVIO DAS MESMAS " +;
						"PODERÁ NÃO OCORRER O PAGAMENTO. " + CRLF + CRLF +;
						"Este é um envio automático de e-mail, favor não responder. " + CRLF + CRLF +;
						"Att "

			DEFINE MSDIALOG oDlg2 TITLE "Envio de e-mail" FROM 005,005 TO 515,675 PIXEL

			//@ 008,003 MSGET  oTxtPedido		VAR "Pedido: " When .F.						SIZE C(027),C(007) OF oDlg2 PIXEL font oFONT
			@   008,003 SAY    oSay1 PROMPT "Pedido:"                                       SIZE C(027),C(007) OF oDlg2 PIXEL font oFONT
			@ 008,040 MSGET  oPedido		VAR aPedidos[ nPedido, POS_NUMPC ] When .F.	SIZE C(220),C(007) OF oDlg2 PIXEL font oFONT
			//
			//@ 020,003 MSGET  oTxtPara		VAR "Para:   " When .F.						SIZE C(027),C(007) OF oDlg2 PIXEL font oFONT
            @   020,003 SAY    oSay2 PROMPT "Para:"                                       SIZE C(027),C(007) OF oDlg2 PIXEL font oFONT
			@ 020,040 MSGET  oEmail			VAR cEmailFor								SIZE C(220),C(007) OF oDlg2 PIXEL font oFONT
			//
			//@ 032,003 MSGET  oTxtCopia		VAR "Cópia:  " When .F.						SIZE C(027),C(007) OF oDlg2 PIXEL font oFONT
			@   032,003 SAY    oSay3 PROMPT "Copia:"                                       SIZE C(027),C(007) OF oDlg2 PIXEL font oFONT
			@ 032,040 MSGET  oCopia			VAR cEmailCC								SIZE C(220),C(007) OF oDlg2 PIXEL font oFONT


			//@ 044,003 MSGET  oTxtAssunto	VAR "Assunto:" When .F.						SIZE C(027),C(007) OF oDlg2 PIXEL font oFONT
			@   044,003 SAY    oSay4 PROMPT "Assunto:"                                       SIZE C(027),C(007) OF oDlg2 PIXEL font oFONT
			@ 044,040 MSGET  oAssunto		VAR cAssunto								SIZE C(220),C(007) OF oDlg2 PIXEL font oFONT

			oCorpoEmail:= tMultiget():New(056,03,{|u|if(Pcount()>0,cDescMsg:=u,cDescMsg)},oDlg2,310,160,,,,,,(.T.))

			@ 230,200 BUTTON "Enviar" Size 037,010 of oDlg2 Pixel Action(lSendMail := .T.,oDlg2:End())
			@ 230,270 BUTTON "Sair"   Size 037,010 of oDlg2 Pixel Action(lSendMail := .F., MsgAlert("Cancelado o envio de e-mail pelo usuário","Aviso"), oDlg2:End())

			ACTIVATE MSDIALOG oDlg2 CENTERED

			If !lSendMail
				Loop // Vai para o próximo Pedido
			EndIf

			If Empty( cEmailFor )
				MsgAlert( "Deve ser informado um endereço de e-mail para o envio." )
				Loop // Vai para o próximo Pedido
			EndIf

			If Empty( cAssunto )
				MsgAlert( "Deve ser informado um assunto no e-mail." )
				Loop // Vai para o próximo Pedido
			EndIf

			// O email do Fornecedor não pode ter só um ponto !
			If At( "@", cEmailFor ) > 0

				// Aqui deverá ter a atualização do e-mail do Fornecedor, se teve alteração com o que já está cadastrado
				If ( AllTrim( cEmailFor ) <> AllTrim( aPedidos[ nPedido, POS_EMAIL ] ) .Or.;
					 AllTrim( cEmailCC ) <> AllTrim( aPedidos[ nPedido, POS_EMAILCC ] );
				   )
					DbSelectArea("SA2")
					SA2->( DbGoTo( aPedidos[ nPedido, POS_RECSA2 ] ) )
					RecLock("SA2", .F.)
						SA2->A2_EMAIL   := AllTrim( cEmailFor )
						SA2->A2_EMAILCC := StrTran( AllTrim( cEmailCC ), ",", ";" )
					MsUnLock()
				EndIf

				cMensagem := ''
				cMensagem += '<html> '
				cMensagem += '<head> '
				cMensagem += '<title>' + cAssunto + '</title> '
				cMensagem += '</head> '
				cMensagem += '<body> '
				// Troca o Enter no Protheus pela quebra de linha no HTML
				cMensagem += StrTran( AllTrim(cDescMsg), CRLF, '<br />')
				cMensagem += '</body> '
				cMensagem += '</html> '

				Processa( { || cAnexo := GeraPDF( aPedidos[ nPedido, POS_NUMPC ], aPedidos[ nPedido, POS_RECSC7 ] ) }, "Gerando relatório para envio..." )

				If !Empty( cAnexo ) .And. File( cAnexo )

					AADD( aEmails, { MV_RELFROM, cEmailFor, cAssunto, cMensagem, cAnexo, "N", cEmailCC } )
					U_STCA031( aEmails, 2 )

					// Apaga o arquivo do Servidor
					fErase( cAnexo )
				Else
					MsgAlert( "Não foi possível gerar o arquivo PDF para anexar no e-mail." )
				EndIf
			EndIf

		Next // aPedidos

	End Sequence

	RestArea( aArea )
	RestArea( aAreaSA2 )
	RestArea( aAreaSC7 )
	RestArea( aAreaSTJ )

	If !Empty( cAliAtu )
		DbSelectArea( cAliAtu )
	EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ GeraPDF ³ Autor ³ Jorge Alberto-Solutio ³ Data ³25/02/2019³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gerar o PDF do pedido de compra.                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_GeraPDF()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ _NumPed -> Numero do Pedido de Compra                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ cFilePrint -> Diretorio e nome do arquivo gerado           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico para a empresa Sirtec                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function GeraPDF( _NumPed, nReg )

	Local cFilePrint := ""
	Local cTitle   := STR0003 // "Emissao dos Pedidos de Compras ou Autorizacoes de Entrega"
	Local oReport
	Local oSection1
	Local oSection2
	Local nTempo := 0
	Local nLimite := 30000 // 30 Segundos

	Pergunte("MTR110",.F.)

	oReport:= TReport():New("PC_ARQ",cTitle,, {|oReport| ReportPrint(oReport,nReg)},STR0001+" "+STR0002)
	oReport:SetPortrait()
	oReport:HideParamPage()
	oReport:HideHeader()
	oReport:HideFooter()
	oReport:SetTotalInLine( .F. )
	oReport:DisableOrientation()
	oReport:ParamReadOnly( .T. )
	oReport:SetPreview( .F. )
	oReport:SetDevice( 6 ) // Parametro para gerar o arquivo PDF
	oReport:nDevice := 6 // Parametro para gerar o arquivo PDF
	oReport:SetReportPortal( "pc_" + _NumPed ) // Parametro para gerar o arquivo PDF
	oReport:cPathPDF := GetTempPath() // Parametro para gerar o arquivo PDF

	oSection1:= TRSection():New(oReport,STR0102,{"SC7","SM0","SA2"}, /* <aOrder> */ ,;
				/* <.lLoadCells.> */ , , /* <cTotalText>  */, /* !<.lTotalInCol.>  */, /* <.lHeaderPage.>  */,;
				/* <.lHeaderBreak.> */, /* <.lPageBreak.>  */, /* <.lLineBreak.>  */, /* <nLeftMargin>  */,;
				.T./* <.lLineStyle.>  */, /* <nColSpace>  */,.T. /*<.lAutoSize.> */, /*<cSeparator> */,;
				/*<nLinesBefore>  */, /*<nCols>  */, /* <nClrBack> */, /* <nClrFore>  */)
	oSection1:SetReadOnly()
	oSection1:SetNoFilter("SA2")

	TRCell():New(oSection1,"M0_NOMECOM","SM0",STR0087      ,/*Picture*/,49,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"M0_ENDENT" ,"SM0",STR0088      ,/*Picture*/,48,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"M0_CEPENT" ,"SM0",STR0089      ,/*Picture*/,10,/*lPixel*/,{|| Trans(SM0->M0_CEPENT,PesqPict("SA2","A2_CEP")) })
	TRCell():New(oSection1,"M0_CIDENT" ,"SM0",STR0090      ,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"M0_ESTENT" ,"SM0",STR0091      ,/*Picture*/,11,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"M0_CGC"    ,"SM0",STR0124      ,/*Picture*/,18,/*lPixel*/,{|| Transform(SM0->M0_CGC,PesqPict("SA2","A2_CGC")) })
	If cPaisLoc == "BRA"
		TRCell():New(oSection1,"M0IE"  ,"   ",STR0041      ,/*Picture*/,18,/*lPixel*/,{|| InscrEst()})
	EndIf
	TRCell():New(oSection1,"M0_TEL"    ,"SM0",STR0092      ,/*Picture*/,14,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"M0_FAX"    ,"SM0",STR0093      ,/*Picture*/,34,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_NOME"   ,"SA2",/*Titulo*/   ,/*Picture*/,40,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_COD"    ,"SA2",/*Titulo*/   ,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_LOJA"   ,"SA2",/*Titulo*/   ,/*Picture*/,04,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_END"    ,"SA2",/*Titulo*/   ,/*Picture*/,40,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_BAIRRO" ,"SA2",/*Titulo*/   ,/*Picture*/,20,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_CEP"    ,"SA2",/*Titulo*/   ,/*Picture*/,08,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_MUN"    ,"SA2",/*Titulo*/   ,/*Picture*/,15,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_EST"    ,"SA2",/*Titulo*/   ,/*Picture*/,02,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"A2_CGC"    ,"SA2",/*Titulo*/   ,/*Picture*/,/*Tamanho*/,/*lPixel*/,/*{|| code-block de impressao }*/)
	TRCell():New(oSection1,"INSCR"     ,"   ",If( cPaisLoc$"ARG|POR|EUA",space(11) , STR0095 ),/*Picture*/,18,/*lPixel*/,{|| If( cPaisLoc$"ARG|POR|EUA",space(18), SA2->A2_INSCR ) })
	TRCell():New(oSection1,"FONE"      ,"   ",STR0094      ,/*Picture*/,25,/*lPixel*/,{|| "("+Substr(SA2->A2_DDD,1,3)+") "+Substr(SA2->A2_TEL,1,15)})
	TRCell():New(oSection1,"FAX"       ,"   ",STR0093      ,/*Picture*/,25,/*lPixel*/,{|| "("+Substr(SA2->A2_DDD,1,3)+") "+SubStr(SA2->A2_FAX,1,15)})

	oSection1:Cell("A2_BAIRRO"):SetCellBreak()
	oSection1:Cell("A2_CGC"   ):SetCellBreak()
	oSection1:Cell("INSCR"    ):SetCellBreak()

	oSection2:= TRSection():New(oSection1, STR0103, {"SC7","SB1"}, /* <aOrder> */ ,;
				/* <.lLoadCells.> */ , , /* <cTotalText>  */, /* !<.lTotalInCol.>  */, /* <.lHeaderPage.>  */,;
				/* <.lHeaderBreak.> */, /* <.lPageBreak.>  */, /* <.lLineBreak.>  */, /* <nLeftMargin>  */,;
				/* <.lLineStyle.>  */, /* <nColSpace>  */, /*<.lAutoSize.> */, /*<cSeparator> */,;
				/*<nLinesBefore>  */, /*<nCols>  */, /* <nClrBack> */, /* <nClrFore>  */)

	oSection2:SetCellBorder("ALL",,,.T.)
	oSection2:SetCellBorder("RIGHT")
	oSection2:SetCellBorder("LEFT")

	TRCell():New(oSection2,"C7_NUM"			,"SC7",STR0129   	,/*Picture*/)
	TRCell():New(oSection2,"C7_ITEM"    	,"SC7",/*Titulo*/	,/*Picture*/)
	TRCell():New(oSection2,"C7_PRODUTO" 	,"SC7",/*Titulo*/	,/*Picture*/)
	TRCell():New(oSection2,"DESCPROD"   	,"   ",STR0097   	,/*Picture*/,30,/*lPixel*/, {|| cDescPro},,,,,,.F.)
	TRCell():New(oSection2,"C7_UM"      	,"SC7",STR0115   	,/*Picture*/)
	TRCell():New(oSection2,"C7_QUANT"   	,"SC7",/*Titulo*/	,/*Picture*/)
	TRCell():New(oSection2,"C7_SEGUM"   	,"SC7",STR0118	,/*Picture*/)
	TRCell():New(oSection2,"C7_QTSEGUM" 	,"SC7",/*Titulo*/	,/*Picture*/)
	TRCell():New(oSection2,"PRECO"      	,"   ",STR0098	,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| nVlUnitSC7 },"RIGHT",,"RIGHT")
	TRCell():New(oSection2,"C7_IPI"     	,"SC7",STR0119	,/*Picture*/)
	TRCell():New(oSection2,"TOTAL"     	,"   ",STR0099	,/*Picture*/,/*Tamanho*/,/*lPixel*/,{|| nValTotSC7 },"RIGHT",,"RIGHT")
	TRCell():New(oSection2,"C7_DATPRF"  	,"SC7",/*Titulo*/	,/*Picture*/)
	TRCell():New(oSection2,"C7_CC"      	,"SC7",STR0066	,/*Picture*/)
	TRCell():New(oSection2,"C7_NUMSC"   	,"SC7",STR0123	,/*Picture*/)
	TRCell():New(oSection2,"OPCC"       	,"   ",STR0100  	,/*Picture*/,TamSX3("C7_OP")[1],/*lPixel*/,{|| cOPCC },,,,,,.F.)

	oSection2:Cell("C7_PRODUTO"):SetLineBreak()
	oSection2:Cell("DESCPROD"):SetLineBreak()
	oSection2:Cell("C7_CC"):SetLineBreak()
	oSection2:Cell("OPCC"):SetLineBreak()

	oReport:Print( .F. )

	If File( oReport:cPathPDF + "totvsprinter\pc_" + _NumPed + ".pdf" )

		cFilePrint :=  "\SPOOL\pc_" + _NumPed + ".pdf"

		// Apaga o arquivo se já existir no Servidor
		If File( cFilePrint )
			fErase( cFilePrint )
		EndIf

		// Copia o arquivo para o Servidor
		CpyT2S( oReport:cPathPDF + "totvsprinter\pc_" + _NumPed + ".pdf", "\SPOOL\" )

		// Aguarda até que tenha copiado o arquivo
		While nTempo < nLimite

			If File( cFilePrint )
				Exit
			EndIf

			Sleep( 5000 ) // Aguarda 5 seguntos
			nTempo := nTempo + 5000
		EndDo

		// Se não copiou o arquivo para o Servidor, tem que deixar vazio para avisar ao usuário.
		If !File( cFilePrint )
			cFilePrint := ""
		EndIf
	EndIf

	// Apaga o arquivo da máquina do usuário
	fErase( oReport:cPathPDF + "totvsprinter\pc_" + _NumPed + ".pdf" )

	FreeObj( oReport )
	oReport := NIL

Return(cFilePrint)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrin³ Autor ³Alexandre Inacio Lemes ³Data  ³06/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao do Pedido de Compras / Autorizacao de Entrega      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportPrint(ExpO1,ExpN1,ExpN2)                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oReport                      	              ³±±
±±³          ³ ExpN1 = Numero do Recno posicionado do SC7 impressao Menu  ³±±
±±³          ³ ExpN2 = Numero da opcao para impressao via menu do PC      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpO1: Objeto Report do Relatório                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport,nReg,nOpcX)

	Local oSection1   := oReport:Section(1)
	Local oSection2   := oReport:Section(1):Section(1)

	Local aRecnoSave  := {}
	Local aPedido     := {}
	Local aPedMail    := {}
	Local aValIVA     := {}

	Local cNumSC7		:= Len(SC7->C7_NUM)
	Local cFiltro		:= ""
	Local cComprador	:= ""
	LOcal cAlter		:= ""
	Local cAprov		:= ""
	Local cTipoSC7	    := ""
	Local cCondBus	    := ""
	Local cMensagem	    := ""
	Local cVar			:= ""
	Local cPictVUnit	:= PesqPict("SC7","C7_PRECO",16)
	Local cPictVTot	    := PesqPict("SC7","C7_TOTAL",, mv_par12)
	Local lNewAlc		:= .F.
	Local lLiber		:= .F.

	Local nRecnoSC7   := 0
	Local nRecnoSM0   := 0
	Local nX          := 0
	Local nY          := 0
	Local nVias       := 0
	Local nTxMoeda    := 0
	Local nTpImp	  := IIF(ValType(oReport:nDevice)!=Nil,oReport:nDevice,0) // Tipo de Impressao
	Local nPageWidth  := IIF(nTpImp==1.Or.nTpImp==6,2435,2435) // oReport:PageWidth()
	Local nPrinted    := 0
	Local nValIVA     := 0
	Local nTotIPI	  := 0
	Local nTotIcms    := 0
	Local nTotDesp    := 0
	Local nTotFrete   := 0
	Local nTotalNF    := 0
	Local nTotSeguro  := 0
	Local nLinPC	  := 0
	Local nLinObs     := 0
	Local nDescProd   := 0
	Local nTotal      := 0
	Local nTotMerc    := 0
	Local nPagina     := 0
	Local nOrder      := 1
	Local lImpri      := .F.
	Local cCident	  := ""
	Local cCidcob	  := ""
	Local nLinPC2	  := 0
	Local nLinPC3	  := 0

	Private cDescPro  := ""
	Private cOPCC     := ""
	Private nVlUnitSC7:= 0
	Private nValTotSC7:= 0

	Private cObs01    := ""
	Private cObs02    := ""
	Private cObs03    := ""
	Private cObs04    := ""
	Private cObs05    := ""
	Private cObs06    := ""
	Private cObs07    := ""
	Private cObs08    := ""
	Private cObs09    := ""
	Private cObs10    := ""
	Private cObs11    := ""
	Private cObs12    := ""
	Private cObs13    := ""
	Private cObs14    := ""
	Private cObs15    := ""
	Private cObs16    := ""

	dbSelectArea("SC7")
	dbGoto(nReg)
	mv_par01 := SC7->C7_NUM
	mv_par02 := SC7->C7_NUM
	mv_par03 := SC7->C7_EMISSAO
	mv_par04 := SC7->C7_EMISSAO
	mv_par05 := 2 // Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","05"),If(cCont == Nil,2,cCont) }) Imprime pedido Novo ou não
	mv_par06 := ""// Descrição do Produto
	MV_PAR07 := 1 // Unidade de Medida, nesse caso é a primária
	mv_par08 := 1 // Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","08"),If(cCont == Nil,C7_TIPO,cCont) }) 1=PC ou 2=AE
	mv_par09 := 1 // Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","09"),If(cCont == Nil,1,cCont) }) Quantidade de Vias impressas
	mv_par10 := 3 // Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","10"),If(cCont == Nil,3,cCont) }) Pedidos Liberados ou Bloqueados
	mv_par11 := 3 // Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","11"),If(cCont == Nil,3,cCont) }) Tipo de Solicitação (Firmes ou Previstas)
	mv_par12 := MAX(SC7->C7_MOEDA,1)
	MV_PAR13 := "" // Endereço de Entrega
	mv_par14 := 1 // Eval({|| cCont:=ChkPergUs(cUserId,"MTR110","14"),If(cCont == Nil,1,cCont) }) Todos os Itens do PC

	If SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3
		If ( cPaisLoc$"ARG|POR|EUA" )
			cCondBus := "1"+StrZero(Val(mv_par01),6)
			nOrder	 := 10
		Else
			cCondBus := mv_par01
			nOrder	 := 1
		EndIf
	Else
		cCondBus := "2"+StrZero(Val(mv_par01),6)
		nOrder	 := 10
	EndIf

	If mv_par14 == 2
		cFiltro := "SC7->C7_QUANT-SC7->C7_QUJE <= 0 .Or. !EMPTY(SC7->C7_RESIDUO)"
	Elseif mv_par14 == 3
		cFiltro := "SC7->C7_QUANT > SC7->C7_QUJE"
	EndIf

	oSection2:Cell("PRECO"):SetPicture(cPictVUnit)
	oSection2:Cell("TOTAL"):SetPicture(cPictVTot)

	TRPosition():New(oSection2,"SB1",1,{ || xFilial("SB1") + SC7->C7_PRODUTO })
	TRPosition():New(oSection2,"SB5",1,{ || xFilial("SB5") + SC7->C7_PRODUTO })

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa o CodeBlock com o PrintLine da Sessao 1 toda vez que rodar o oSection1:Init()   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport:onPageBreak( { || nPagina++ , nPrinted := 0 , CabecPCxAE(oReport,oSection1,nVias,nPagina) })

	oReport:SetMeter(SC7->(LastRec()))
	dbSelectArea("SC7")
	dbSetOrder(nOrder)
	dbSeek(xFilial("SC7")+cCondBus,.T.)

	oSection2:Init()

	cNumSC7 := SC7->C7_NUM

	While !oReport:Cancel() .And. !SC7->(Eof()) .And. SC7->C7_FILIAL == xFilial("SC7") .And. SC7->C7_NUM >= mv_par01 .And. SC7->C7_NUM <= mv_par02

		If (SC7->C7_CONAPRO == "B" .And. mv_par10 == 1) .Or.;
		(SC7->C7_CONAPRO <> "B" .And. mv_par10 == 2) .Or.;
		(SC7->C7_EMITIDO == "S" .And. mv_par05 == 1) .Or.;
		((SC7->C7_EMISSAO < mv_par03) .Or. (SC7->C7_EMISSAO > mv_par04)) .Or.;
		((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3) .And. mv_par08 == 2) .Or.;
		(SC7->C7_TIPO == 2 .And. (mv_par08 == 1 .OR. mv_par08 == 3)) .Or. !MtrAValOP(mv_par11, "SC7") .Or.;
		(SC7->C7_QUANT > SC7->C7_QUJE .And. mv_par14 == 3) .Or.;
		((SC7->C7_QUANT - SC7->C7_QUJE <= 0 .Or. !Empty(SC7->C7_RESIDUO)) .And. mv_par14 == 2 )

			dbSelectArea("SC7")
			dbSkip()
			Loop
		Endif

		If oReport:Cancel()
			Exit
		EndIf

		MaFisEnd()
		R110FIniPC(SC7->C7_NUM,,,cFiltro)

		cObs01    := " "
		cObs02    := " "
		cObs03    := " "
		cObs04    := " "
		cObs05    := " "
		cObs06    := " "
		cObs07    := " "
		cObs08    := " "
		cObs09    := " "
		cObs10    := " "
		cObs11    := " "
		cObs12    := " "
		cObs13    := " "
		cObs14    := " "
		cObs15    := " "
		cObs16    := " "

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Roda a impressao conforme o numero de vias informado no mv_par09 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		For nVias := 1 to mv_par09

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Dispara a cabec especifica do relatorio.                     ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			oReport:EndPage()

			nPagina  := 0
			nPrinted := 0
			nTotal   := 0
			nTotMerc := 0
			nDescProd:= 0
			nLinObs  := 0
			nRecnoSC7:= SC7->(Recno())
			cNumSC7  := SC7->C7_NUM
			aPedido  := {SC7->C7_FILIAL,SC7->C7_NUM,SC7->C7_EMISSAO,SC7->C7_FORNECE,SC7->C7_LOJA,SC7->C7_TIPO}

			While !oReport:Cancel() .And. !SC7->(Eof()) .And. SC7->C7_FILIAL == xFilial("SC7") .And. SC7->C7_NUM == cNumSC7

				If (SC7->C7_CONAPRO == "B" .And. mv_par10 == 1) .Or.;
				(SC7->C7_CONAPRO <> "B" .And. mv_par10 == 2) .Or.;
				(SC7->C7_EMITIDO == "S" .And. mv_par05 == 1) .Or.;
				((SC7->C7_EMISSAO < mv_par03) .Or. (SC7->C7_EMISSAO > mv_par04)) .Or.;
				((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3) .And. mv_par08 == 2) .Or.;
				(SC7->C7_TIPO == 2 .And. (mv_par08 == 1 .OR. mv_par08 == 3)) .Or. !MtrAValOP(mv_par11, "SC7") .Or.;
				(SC7->C7_QUANT > SC7->C7_QUJE .And. mv_par14 == 3) .Or.;
				((SC7->C7_QUANT - SC7->C7_QUJE <= 0 .Or. !Empty(SC7->C7_RESIDUO)) .And. mv_par14 == 2 )
					dbSelectArea("SC7")
					dbSkip()
					Loop
				Endif

				If oReport:Cancel()
					Exit
				EndIf

				oReport:IncMeter()

				If oReport:Row() > oReport:LineHeight() * 100
					oReport:Box( oReport:Row(),010,oReport:Row() + oReport:LineHeight() * 3, nPageWidth )
					oReport:SkipLine()
					oReport:PrintText(STR0101,, 050 ) // Continua na Proxima pagina ....
					oReport:EndPage()
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Salva os Recnos do SC7 no aRecnoSave para marcar reimpressao.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If Ascan(aRecnoSave,SC7->(Recno())) == 0
					AADD(aRecnoSave,SC7->(Recno()))
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inicializa o descricao do Produto conf. parametro digitado.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cDescPro :=  ""
				If Empty(mv_par06)
					mv_par06 := "B1_DESC"
				EndIf

				If AllTrim(mv_par06) == "B1_DESC"
					SB1->(dbSetOrder(1))
					SB1->(dbSeek( xFilial("SB1") + SC7->C7_PRODUTO ))
					cDescPro := SB1->B1_DESC
				ElseIf AllTrim(mv_par06) == "B5_CEME"
					SB5->(dbSetOrder(1))
					If SB5->(dbSeek( xFilial("SB5") + SC7->C7_PRODUTO ))
						cDescPro := SB5->B5_CEME
					EndIf
				ElseIf AllTrim(mv_par06) == "C7_DESCRI"
					cDescPro := SC7->C7_DESCRI
				EndIf

				If Empty(cDescPro)
					SB1->(dbSetOrder(1))
					SB1->(dbSeek( xFilial("SB1") + SC7->C7_PRODUTO ))
					cDescPro := SB1->B1_DESC
				EndIf

				SA5->(dbSetOrder(1))
				If SA5->(dbSeek(xFilial("SA5")+SC7->C7_FORNECE+SC7->C7_LOJA+SC7->C7_PRODUTO)) .And. !Empty(SA5->A5_CODPRF)
					cDescPro := cDescPro + " ("+Alltrim(SA5->A5_CODPRF)+")"
				EndIf

				If SC7->C7_DESC1 != 0 .Or. SC7->C7_DESC2 != 0 .Or. SC7->C7_DESC3 != 0
					nDescProd+= CalcDesc(SC7->C7_TOTAL,SC7->C7_DESC1,SC7->C7_DESC2,SC7->C7_DESC3)
				Else
					nDescProd+=SC7->C7_VLDESC
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inicializacao da Observacao do Pedido.                       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(SC7->C7_OBSM) .And. nLinObs < 17
					nLinObs++
					cVar:="cObs"+StrZero(nLinObs,2)
					Eval(MemVarBlock(cVar),SC7->C7_OBSM)
				Endif

				nTxMoeda   := IIF(SC7->C7_TXMOEDA > 0,SC7->C7_TXMOEDA,Nil)
				nValTotSC7 := xMoeda(SC7->C7_TOTAL,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)

				nTotal     := nTotal + SC7->C7_TOTAL
				nTotMerc   := MaFisRet(,"NF_TOTAL")

				If oReport:nDevice != 4 .Or. (oReport:nDevice == 4 .And. !oReport:lXlsTable .And. oReport:lXlsHeader)  //impressao em planilha tipo tabela
					oSection2:Cell("C7_NUM"):Disable()
				EndIf

				If MV_PAR07 == 2 .And. !Empty(SC7->C7_QTSEGUM) .And. !Empty(SC7->C7_SEGUM)
					oSection2:Cell("C7_SEGUM"  ):Enable()
					oSection2:Cell("C7_QTSEGUM"):Enable()
					oSection2:Cell("C7_UM"     ):Disable()
					oSection2:Cell("C7_QUANT"  ):Disable()
					nVlUnitSC7 := xMoeda((SC7->C7_TOTAL/SC7->C7_QTSEGUM),SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
				ElseIf MV_PAR07 == 1 .And. !Empty(SC7->C7_QUANT) .And. !Empty(SC7->C7_UM)
					oSection2:Cell("C7_SEGUM"  ):Disable()
					oSection2:Cell("C7_QTSEGUM"):Disable()
					oSection2:Cell("C7_UM"     ):Enable()
					oSection2:Cell("C7_QUANT"  ):Enable()
					nVlUnitSC7 := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
				Else
					oSection2:Cell("C7_SEGUM"  ):Enable()
					oSection2:Cell("C7_QTSEGUM"):Enable()
					oSection2:Cell("C7_UM"     ):Enable()
					oSection2:Cell("C7_QUANT"  ):Enable()
					nVlUnitSC7 := xMoeda(SC7->C7_PRECO,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda)
				EndIf

				If cPaisLoc <> "BRA" .Or. mv_par08 == 2
					oSection2:Cell("C7_IPI" ):Disable()
				EndIf

				If mv_par08 == 1 .OR. mv_par08 == 3
					oSection2:Cell("OPCC"):Disable()
				Else
					oSection2:Cell("C7_DATPRF"):SetSize(9)
					oSection2:Cell("C7_CC"):Disable()
					oSection2:Cell("C7_NUMSC"):Disable()
					If !Empty(SC7->C7_OP)
						cOPCC := STR0065 + " " + SC7->C7_OP
					ElseIf !Empty(SC7->C7_CC)
						cOPCC := STR0066 + " " + SC7->C7_CC
					EndIf
				EndIf

				oSection2:Cell("C7_ITEM"):SetSize(10)
				oSection2:Cell("DESCPROD"):SetSize(60)

				If MV_PAR07 == 1
					oSection2:Cell("C7_NUMSC"):SetSize(12.3)
					If nTpImp == 6
						oSection2:Cell("C7_DATPRF"):SetSize(23)
						oSection2:Cell("DESCPROD"):SetSize(80)
					EndIF
				ElseIf MV_PAR07 == 2 .And. !Empty(SC7->C7_QTSEGUM) .And. !Empty(SC7->C7_SEGUM)
					oSection2:Cell("C7_NUMSC"):SetSize(10.3)
					If nTpImp == 6
						oSection2:Cell("C7_DATPRF"):SetSize(24.7)
						oSection2:Cell("DESCPROD"):SetSize(80)
					EndIF
				Else
					oSection2:Cell("DESCPROD"):SetSize(44.3)
					oSection2:Cell("C7_NUMSC"):SetSize(10)
					If nTpImp == 6
						oSection2:Cell("C7_DATPRF"):SetSize(14.7)
						oSection2:Cell("DESCPROD"):SetSize(85)
						oSection2:Cell("C7_NUMSC"):SetSize(20.5)
					EndIF
				EndIF

				If nTpImp == 6
					oSection2:Cell("C7_UM"):SetSize(15)
					oSection2:Cell("C7_QUANT"):SetSize(30)
					oSection2:Cell("C7_SEGUM"):SetSize(15)
					oSection2:Cell("C7_QTSEGUM"):SetSize(30)
					oSection2:Cell("C7_ITEM"):SetSize(25)
					oSection2:Cell("C7_IPI"):SetSize(25)
					oSection2:Cell("TOTAL"):SetSize(25)
					oSection2:Cell("C7_CC"):SetSize(25)
				EndIf

				If oReport:nDevice == 4 .And. oReport:lXlsTable .And. !oReport:lXlsHeader  //impressao em planilha tipo tabela
					oSection1:Init()
					TRPosition():New(oSection1,"SA2",1,{ || xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA })
					oSection1:PrintLine()
					oSection2:PrintLine()
					oSection1:Finish()
				Else
					oSection2:PrintLine()
				EndIf

				nPrinted ++
				lImpri  := .T.
				dbSelectArea("SC7")
				dbSkip()

			EndDo

			SC7->(dbGoto(nRecnoSC7))

			If oReport:Row() > oReport:LineHeight() * 68

				oReport:Box( oReport:Row(),010,oReport:Row() + oReport:LineHeight() * 3, nPageWidth )
				oReport:SkipLine()
				oReport:PrintText(STR0101,, 050 ) // Continua na Proxima pagina ....

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Dispara a cabec especifica do relatorio.                     ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oReport:EndPage()
				oReport:PrintText(" ",1992 , 010 ) // Necessario para posicionar Row() para a impressao do Rodape

				oReport:Box( 280,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )

			Else
				oReport:Box( oReport:Row(),oReport:Col(),oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
			EndIf

			oReport:Box( 1990 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
			oReport:Box( 2080 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
			oReport:Box( 2200 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )
			oReport:Box( 2320 ,010,oReport:Row() + oReport:LineHeight() * ( 93 - nPrinted ) , nPageWidth )

			oReport:Box( 2200 , 1080 , 2320 , 1400 ) // Box da Data de Emissao
			oReport:Box( 2320 ,  010 , 2406 , 1220 ) // Box do Reajuste
			oReport:Box( 2320 , 1220 , 2460 , 1750 ) // Box do IPI e do Frete
			oReport:Box( 2320 , 1750 , 2460 , nPageWidth ) // Box do ICMS Despesas e Seguro
			oReport:Box( 2406 ,  010 , 2700 , 1220 ) // Box das Observacoes

			cMensagem:= Formula(SC7->C7_MSG)
			If !Empty(cMensagem)
				oReport:SkipLine()
				oReport:PrintText(PadR(cMensagem,129), , oSection2:Cell("DESCPROD"):ColPos() )
			Endif

			oReport:PrintText( STR0007 /*"D E S C O N T O S -->"*/ + " " + ;
			TransForm(SC7->C7_DESC1,"999.99" ) + " %    " + ;
			TransForm(SC7->C7_DESC2,"999.99" ) + " %    " + ;
			TransForm(SC7->C7_DESC3,"999.99" ) + " %    " + ;
			TransForm(xMoeda(nDescProd,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , PesqPict("SC7","C7_VLDESC",14, MV_PAR12) ),;
			2022 , 050 )

			oReport:SkipLine()
			oReport:SkipLine()
			oReport:SkipLine()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Posiciona o Arquivo de Empresa SM0.                          ³
			//³ Imprime endereco de entrega do SM0 somente se o MV_PAR13 =" "³
			//³ e o Local de Cobranca :                                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SM0->(dbSetOrder(1))
			nRecnoSM0 := SM0->(Recno())
			SM0->(dbSeek(SUBS(cNumEmp,1,2)+SC7->C7_FILENT))

			cCident := IIF(len(SM0->M0_CIDENT)>20,Substr(SM0->M0_CIDENT,1,15),SM0->M0_CIDENT)
			cCidcob := IIF(len(SM0->M0_CIDCOB)>20,Substr(SM0->M0_CIDCOB,1,15),SM0->M0_CIDCOB)

			If Empty(MV_PAR13) //"Local de Entrega  : "
				oReport:PrintText(STR0008 + SM0->M0_ENDENT+"  "+Rtrim(SM0->M0_CIDENT)+"  - "+SM0->M0_ESTENT+" - "+STR0009+" "+Trans(Alltrim(SM0->M0_CEPENT),PesqPict("SA2","A2_CEP")),, 050 )
			Else
				oReport:PrintText(STR0008 + mv_par13,, 050 ) //"Local de Entrega  : " imprime o endereco digitado na pergunte
			Endif
			SM0->(dbGoto(nRecnoSM0))
			oReport:PrintText(STR0010 + SM0->M0_ENDCOB+"  "+Rtrim(SM0->M0_CIDCOB)+"  - "+SM0->M0_ESTCOB+" - "+STR0009+" "+Trans(Alltrim(SM0->M0_CEPCOB),PesqPict("SA2","A2_CEP")),, 050 )

			oReport:SkipLine()
			oReport:SkipLine()

			SE4->(dbSetOrder(1))
			SE4->(dbSeek(xFilial("SE4")+SC7->C7_COND))

			nLinPC := oReport:Row()
			oReport:PrintText( STR0011+SubStr(SE4->E4_COND,1,40),nLinPC,050 )
			oReport:PrintText( STR0070,nLinPC,1120 ) //"Data de Emissao"
			oReport:PrintText( STR0013 +" "+ Transform(xMoeda(nTotal,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotal,14,MsDecimais(MV_PAR12)) ),nLinPC,1612 ) //"Total das Mercadorias : "
			oReport:SkipLine()
			nLinPC := oReport:Row()

			If cPaisLoc<>"BRA"
				aValIVA := MaFisRet(,"NF_VALIMP")
				nValIVA :=0
				If !Empty(aValIVA)
					For nY:=1 to Len(aValIVA)
						nValIVA+=aValIVA[nY]
					Next nY
				EndIf
				oReport:PrintText(SubStr(SE4->E4_DESCRI,1,34),nLinPC, 050 )
				oReport:PrintText( dtoc(SC7->C7_EMISSAO),nLinPC,1120 )
				oReport:PrintText( STR0063+ "   " + ; //"Total dos Impostos:    "
				Transform(xMoeda(nValIVA,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nValIVA,14,MsDecimais(MV_PAR12)) ),nLinPC,1612 )
			Else
				oReport:PrintText( SubStr(SE4->E4_DESCRI,1,34),nLinPC, 050 )
				oReport:PrintText( dtoc(SC7->C7_EMISSAO),nLinPC,1120 )
				oReport:PrintText( STR0064+ "  " + ; //"Total com Impostos:    "
				Transform(xMoeda(nTotMerc,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotMerc,14,MsDecimais(MV_PAR12)) ),nLinPC,1612 )
			Endif
			oReport:SkipLine()

			nTotIPI	  := MaFisRet(,'NF_VALIPI')
			nTotIcms  := MaFisRet(,'NF_VALICM')
			nTotDesp  := MaFisRet(,'NF_DESPESA')
			nTotFrete := MaFisRet(,'NF_FRETE')
			nTotSeguro:= MaFisRet(,'NF_SEGURO')
			nTotalNF  := MaFisRet(,'NF_TOTAL')

			oReport:SkipLine()
			oReport:SkipLine()
			nLinPC := oReport:Row()

			SM4->(dbSetOrder(1))
			If SM4->(dbSeek(xFilial("SM4")+SC7->C7_REAJUST))
				oReport:PrintText(  STR0014 + " " + SC7->C7_REAJUST + " " + SM4->M4_DESCR ,nLinPC, 050 )  //"Reajuste :"
			EndIf

			If cPaisLoc == "BRA"
				oReport:PrintText( STR0071 + Transform(xMoeda(nTotIPI ,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotIPI ,14,MsDecimais(MV_PAR12))) ,nLinPC,1320 ) //"IPI      :"
				oReport:PrintText( STR0072 + Transform(xMoeda(nTotIcms,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotIcms,14,MsDecimais(MV_PAR12))) ,nLinPC,1815 ) //"ICMS     :"
			EndIf
			oReport:SkipLine()

			nLinPC := oReport:Row()
			oReport:PrintText( STR0073 + Transform(xMoeda(nTotFrete,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotFrete,14,MsDecimais(MV_PAR12))) ,nLinPC,1320 ) //"Frete    :"
			oReport:PrintText( STR0074 + Transform(xMoeda(nTotDesp ,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotDesp ,14,MsDecimais(MV_PAR12))) ,nLinPC,1815 ) //"Despesas :"
			oReport:SkipLine()

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Inicializar campos de Observacoes.                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Empty(cObs02)
				If Len(cObs01) > 30
					cObs := cObs01
					cObs01 := Substr(cObs,1,30)
					For nX := 2 To 16
						cVar  := "cObs"+StrZero(nX,2)
						&cVar := Substr(cObs,(30*(nX-1))+1,30)
					Next nX
				EndIf
			Else
				cObs01:= Substr(cObs01,1,IIf(Len(cObs01)<30,Len(cObs01),30))
				cObs02:= Substr(cObs02,1,IIf(Len(cObs02)<30,Len(cObs01),30))
				cObs03:= Substr(cObs03,1,IIf(Len(cObs03)<30,Len(cObs01),30))
				cObs04:= Substr(cObs04,1,IIf(Len(cObs04)<30,Len(cObs01),30))
				cObs05:= Substr(cObs05,1,IIf(Len(cObs05)<30,Len(cObs01),30))
				cObs06:= Substr(cObs06,1,IIf(Len(cObs06)<30,Len(cObs01),30))
				cObs07:= Substr(cObs07,1,IIf(Len(cObs07)<30,Len(cObs01),30))
				cObs08:= Substr(cObs08,1,IIf(Len(cObs08)<30,Len(cObs01),30))
				cObs09:= Substr(cObs09,1,IIf(Len(cObs09)<30,Len(cObs01),30))
				cObs10:= Substr(cObs10,1,IIf(Len(cObs10)<30,Len(cObs01),30))
				cObs11:= Substr(cObs11,1,IIf(Len(cObs11)<30,Len(cObs01),30))
				cObs12:= Substr(cObs12,1,IIf(Len(cObs12)<30,Len(cObs01),30))
				cObs13:= Substr(cObs13,1,IIf(Len(cObs13)<30,Len(cObs01),30))
				cObs14:= Substr(cObs14,1,IIf(Len(cObs14)<30,Len(cObs01),30))
				cObs15:= Substr(cObs15,1,IIf(Len(cObs15)<30,Len(cObs01),30))
				cObs16:= Substr(cObs16,1,IIf(Len(cObs16)<30,Len(cObs01),30))
			EndIf

			cComprador:= ""
			cAlter	  := ""
			cAprov	  := ""
			lNewAlc	  := .F.
			lLiber 	  := .F.

			dbSelectArea("SC7")
			//Incluida validação para os pedidos de compras por item do pedido  (IP/alçada)
			cTipoSC7:= IIF((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),"PC","AE")

			If cTipoSC7 == "PC"

				dbSelectArea("SCR")
				dbSetOrder(1)
				If !dbSeek(xFilial("SCR")+cTipoSC7+SC7->C7_NUM)
					dbSeek(xFilial("SCR")+"IP"+SC7->C7_NUM)
				EndIf

			Else

				dbSelectArea("SCR")
				dbSetOrder(1)
				dbSeek(xFilial("SCR")+cTipoSC7+SC7->C7_NUM)
			EndIf

			If !Empty(SC7->C7_APROV) .Or. (Empty(SC7->C7_APROV) .And. SCR->CR_TIPO == "IP")

				lNewAlc := .T.
				cComprador := UsrFullName(SC7->C7_USER)
				If SC7->C7_CONAPRO != "B"
					lLiber := .T.
				EndIf

				While !Eof() .And. SCR->CR_FILIAL+Alltrim(SCR->CR_NUM) == xFilial("SCR")+Alltrim(SC7->C7_NUM) .And. SCR->CR_TIPO $ "PC|AE|IP"
					cAprov += AllTrim(UsrFullName(SCR->CR_USER))+" ["
					Do Case
						Case SCR->CR_STATUS=="02" //Pendente
						cAprov += "BLQ"
						Case SCR->CR_STATUS=="03" //Liberado
						cAprov += "Ok"
						Case SCR->CR_STATUS=="04" //Bloqueado
						cAprov += "BLQ"
						Case SCR->CR_STATUS=="05" //Nivel Liberado
						cAprov += "##"
						OtherWise                 //Aguar.Lib
						cAprov += "??"
					EndCase
					cAprov += "] - "
					dbSelectArea("SCR")
					dbSkip()
				Enddo
				If !Empty(SC7->C7_GRUPCOM)
					dbSelectArea("SAJ")
					dbSetOrder(1)
					dbSeek(xFilial("SAJ")+SC7->C7_GRUPCOM)
					While !Eof() .And. SAJ->AJ_FILIAL+SAJ->AJ_GRCOM == xFilial("SAJ")+SC7->C7_GRUPCOM
						If SAJ->AJ_USER != SC7->C7_USER
							If SAJ->(FieldPos("AJ_MSBLQL") > 0)
								If SAJ->AJ_MSBLQL == "1"
									dbSkip()
									LOOP
								EndIf
							EndIf
							cAlter += AllTrim(UsrFullName(SAJ->AJ_USER))+"/"
						EndIf
						dbSelectArea("SAJ")
						dbSkip()
					EndDo
				EndIf
			EndIf

			nLinPC := oReport:Row()
			oReport:PrintText( STR0077 ,nLinPC, 050 ) // "Observacoes "
			oReport:PrintText( STR0076 + Transform(xMoeda(nTotSeguro,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotSeguro,14,MsDecimais(MV_PAR12))) ,nLinPC, 1815 ) // "SEGURO   :"
			oReport:SkipLine()

			nLinPC2 := oReport:Row()
			oReport:PrintText(cObs01,,050 )
			oReport:PrintText(cObs02,,050 )

			nLinPC := oReport:Row()
			oReport:PrintText(cObs03,nLinPC,050 )

			If !lNewAlc
				oReport:PrintText( STR0078 + Transform(xMoeda(nTotalNF,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotalNF,14,MsDecimais(MV_PAR12))) ,nLinPC,1774 ) //"Total Geral :"
			Else
				If lLiber
					oReport:PrintText( STR0078 + Transform(xMoeda(nTotalNF,SC7->C7_MOEDA,MV_PAR12,SC7->C7_DATPRF,MsDecimais(SC7->C7_MOEDA),nTxMoeda) , tm(nTotalNF,14,MsDecimais(MV_PAR12))) ,nLinPC,1774 )
				Else
					oReport:PrintText( STR0078 + If((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),STR0051,STR0086) ,nLinPC,1390 )
				EndIf
			EndIf
			oReport:SkipLine()

			oReport:PrintText(cObs04,,050 )
			oReport:PrintText(cObs05,,050 )
			oReport:PrintText(cObs06,,050 )
			nLinPC3 := oReport:Row()
			oReport:PrintText(cObs07,,050 )
			oReport:PrintText(cObs08,,050 )
			oReport:PrintText(cObs09,nLinPC2,650 )
			oReport:SkipLine()
			oReport:PrintText(cObs10,,650 )
			oReport:PrintText(cObs11,,650 )
			oReport:PrintText(cObs12,,650 )
			oReport:PrintText(cObs13,,650 )
			oReport:PrintText(cObs14,,650 )
			oReport:PrintText(cObs15,,650 )
			oReport:PrintText(cObs16,,650 )

			If !lNewAlc

				oReport:Box( 2700 , 0010 , 3020 , 0400 )
				oReport:Box( 2700 , 0400 , 3020 , 0800 )
				oReport:Box( 2700 , 0800 , 3020 , 1220 )
				oReport:Box( 2600 , 1220 , 3020 , 1770 )
				oReport:Box( 2600 , 1770 , 3020 , nPageWidth )

				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()

				nLinPC := oReport:Row()
				oReport:PrintText( If((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3),STR0079,STR0084),nLinPC,1310) //"Liberacao do Pedido"##"Liber. Autorizacao "
				oReport:PrintText( STR0080 + IF( SC7->C7_TPFRETE $ "F","FOB",IF(SC7->C7_TPFRETE $ "C","CIF",IF(SC7->C7_TPFRETE $ "T","Por Conta Terceiros"," " ) )) ,nLinPC,1820 )
				oReport:SkipLine()

				oReport:SkipLine()
				oReport:SkipLine()

				nLinPC := oReport:Row()
				oReport:PrintText( STR0021 ,nLinPC, 050 ) //"Comprador"
				oReport:PrintText( STR0022 ,nLinPC, 430 ) //"Gerencia"
				oReport:PrintText( STR0023 ,nLinPC, 850 ) //"Diretoria"
				oReport:SkipLine()

				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()

				nLinPC := oReport:Row()
				oReport:PrintText( Replic("_",23) ,nLinPC,  050 )
				oReport:PrintText( Replic("_",23) ,nLinPC,  430 )
				oReport:PrintText( Replic("_",23) ,nLinPC,  850 )
				oReport:PrintText( Replic("_",31) ,nLinPC, 1310 )
				oReport:SkipLine()

				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()
				If SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3
					oReport:PrintText(STR0081,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras."
				Else
					oReport:PrintText(STR0083,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero da Autorizacao de Entrega."
				EndIf

			Else

				oReport:Box( 2570 , 1220 , 2700 , 1820 )
				oReport:Box( 2570 , 1820 , 2700 , nPageWidth )
				oReport:Box( 2700 , 0010 , 3020 , nPageWidth )
				oReport:Box( 2970 , 0010 , 3020 , 1340 )

				nLinPC := nLinPC3

				oReport:PrintText( If((SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3), If( lLiber , STR0050 , STR0051 ) , If( lLiber , STR0085 , STR0086 ) ),nLinPC,1290 ) //"     P E D I D O   L I B E R A D O"#"|     P E D I D O   B L O Q U E A D O !!!"
				oReport:PrintText( STR0080 + Substr(RetTipoFrete(SC7->C7_TPFRETE),3),nLinPC,1830 ) //"Obs. do Frete: "
				oReport:SkipLine()

				oReport:SkipLine()
				oReport:SkipLine()
				oReport:SkipLine()
				oReport:PrintText(STR0052+" "+Substr(cComprador,1,60),,050 ) 	//"Comprador Responsavel :" //"BLQ:Bloqueado"
				oReport:SkipLine()
				oReport:PrintText(STR0053+" "+If( Len(cAlter) > 0 , Substr(cAlter,001,130) , " " ),,050 ) //"Compradores Alternativos :"
				oReport:PrintText(            If( Len(cAlter) > 0 , Substr(cAlter,131,130) , " " ),,440 ) //"Compradores Alternativos :"
				oReport:SkipLine()
				oReport:PrintText(STR0054+" "+If( Len(cAprov) > 0 , Substr(cAprov,001,140) , " " ),,050 ) //"Aprovador(es) :"
				oReport:PrintText(            If( Len(cAprov) > 0 , Substr(cAprov,141,140) , " " ),,310 ) //"Aprovador(es) :"
				oReport:SkipLine()

				nLinPC := oReport:Row()
				oReport:PrintText( STR0082+" "+STR0060 ,nLinPC, 050 ) 	//"Legendas da Aprovacao : //"BLQ:Bloqueado"
				oReport:PrintText(       "|  "+STR0061 ,nLinPC, 610 ) 	//"Ok:Liberado"
				oReport:PrintText(       "|  "+STR0062 ,nLinPC, 830 ) 	//"??:Aguar.Lib"
				oReport:PrintText(       "|  "+STR0067 ,nLinPC,1070 )	//"##:Nivel Lib"
				oReport:SkipLine()

				oReport:SkipLine()
				If SC7->C7_TIPO == 1 .OR. SC7->C7_TIPO == 3
					oReport:PrintText(STR0081,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero do nosso Pedido de Compras."
				Else
					oReport:PrintText(STR0083,,050 ) //"NOTA: So aceitaremos a mercadoria se na sua Nota Fiscal constar o numero da Autorizacao de Entrega."
				EndIf
			EndIf

		Next nVias

		MaFisEnd()


		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava no SC7 as Reemissoes e atualiza o Flag de impressao.   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


		dbSelectArea("SC7")
		If Len(aRecnoSave) > 0
			For nX :=1 to Len(aRecnoSave)
				dbGoto(aRecnoSave[nX])
				If(SC7->C7_QTDREEM >= 99)
					If nRet == 1
						RecLock("SC7",.F.)
						SC7->C7_EMITIDO := "S"
						MsUnLock()
					Elseif nRet == 2
						RecLock("SC7",.F.)
						SC7->C7_QTDREEM := 1
						SC7->C7_EMITIDO := "S"
						MsUnLock()
					Elseif nRet == 3
						//cancelar
					Endif
				Else
					RecLock("SC7",.F.)
					SC7->C7_QTDREEM := (SC7->C7_QTDREEM + 1)
					SC7->C7_EMITIDO := "S"
					MsUnLock()
				Endif
			Next nX
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Reposiciona o SC7 com base no ultimo elemento do aRecnoSave. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbGoto(aRecnoSave[Len(aRecnoSave)])
		Endif

		Aadd(aPedMail,aPedido)

		aRecnoSave := {}

		dbSelectArea("SC7")
		dbSkip()

	EndDo

	oSection2:Finish()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Executa o ponto de entrada M110MAIL quando a impressao for   ³
	//³ enviada por email, fornecendo um Array para o usuario conten ³
	//³ do os pedidos enviados para possivel manipulacao.            ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ExistBlock("M110MAIL")
		lEnvMail := (oReport:nDevice == 3)
		If lEnvMail
			Execblock("M110MAIL",.F.,.F.,{aPedMail})
		EndIf
	EndIf

	If !lImpri
		Aviso(STR0104,STR0105,{"OK"})
	Endif

	dbSelectArea("SC7")
	dbClearFilter()
	dbSetOrder(1)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CabecPCxAE³ Autor ³Alexandre Inacio Lemes ³Data  ³06/09/2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emissao do Pedido de Compras / Autorizacao de Entrega      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CabecPCxAE(ExpO1,ExpO2,ExpN1,ExpN2)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpO1 = Objeto oReport                      	              ³±±
±±³          ³ ExpO2 = Objeto da sessao1 com o cabec                      ³±±
±±³          ³ ExpN1 = Numero de Vias                                     ³±±
±±³          ³ ExpN2 = Numero de Pagina                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CabecPCxAE(oReport,oSection1,nVias,nPagina)

	Local cMoeda		:= IIf( mv_par12 < 10 , Str(mv_par12,1) , Str(mv_par12,2) )
	Local nLinPC		:= 0
	Local nTpImp	  	:= IIF(ValType(oReport:nDevice)!=Nil,oReport:nDevice,0) // Tipo de Impressao
	Local nPageWidth	:= IIF(nTpImp==1.Or.nTpImp==6,2435,2435)
	Local cCident		:= IIF(len(SM0->M0_CIDENT)>20,Substr(SM0->M0_CIDENT,1,15),SM0->M0_CIDENT)
	Local cCGC			:= ""
	Public nRet		:= 0

	TRPosition():New(oSection1,"SA2",1,{ || xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA })
	cBitmap := R110Logo()

	SA2->(dbSetOrder(1))
	SA2->(dbSeek(xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA))

	oSection1:Init()

	oReport:Box( 010 , 010 ,  260 , 1000 )
	oReport:Box( 010 , 1010,  260 , nPageWidth-2 )

	oReport:PrintText( If(nPagina > 1,(STR0033)," "),,oSection1:Cell("M0_NOMECOM"):ColPos())

	nLinPC := oReport:Row()
	oReport:PrintText( If( mv_par08 == 1 , (STR0068), (STR0069) ) + " - " + GetMV("MV_MOEDA"+cMoeda) ,nLinPC,1030 )
	oReport:PrintText( If( mv_par08 == 1 , SC7->C7_NUM, SC7->C7_NUMSC + "/" + SC7->C7_NUM ) + " /" + Ltrim(Str(nPagina,2)) ,nLinPC,1910 )
	oReport:SkipLine()


	nLinPC := oReport:Row()
	If(SC7->C7_QTDREEM >= 99)
		nRet := Aviso("TOTVS", STR0125 +chr(13)+chr(10)+ "1- " + STR0126 +chr(13)+chr(10)+ "2- " + STR0127 +chr(13)+chr(10)+ "3- " + STR0128,{"1", "2", "3"},2)
		If(nRet == 1)
			oReport:PrintText( Str(SC7->C7_QTDREEM,2) + STR0034 + Str(nVias,2) + STR0035 ,nLinPC,1910 )
		Elseif(nRet == 2)
			oReport:PrintText( "1" + STR0034 + Str(nVias,2) + STR0035 ,nLinPC,1910 )
		Elseif(nRet == 3)
			oReport:CancelPrint()
		Endif
	Else
		oReport:PrintText( If( SC7->C7_QTDREEM > 0, Str(SC7->C7_QTDREEM+1,2) , "1" ) + STR0034 + Str(nVias,2) + STR0035 ,nLinPC,1910 )
	Endif

	oReport:SkipLine()

	_cFileLogo	:= GetSrvProfString('Startpath','') + cBitmap
	oReport:SayBitmap(25,25,_cFileLogo,150,60) // insere o logo no relatorio

	nLinPC := oReport:Row()
	oReport:PrintText(STR0087 + SM0->M0_NOMECOM,nLinPC,15)  // "Empresa:"
	oReport:PrintText(STR0106 + Substr(SA2->A2_NOME,1,50) + " " + STR0107 + SA2->A2_COD + " " + STR0108 + SA2->A2_LOJA ,nLinPC,1025)
	oReport:SkipLine()

	nLinPC := oReport:Row()
	oReport:PrintText(STR0088 + SM0->M0_ENDENT,nLinPC,15)
	oReport:PrintText(STR0088 + Substr(SA2->A2_END,1,49) + " " + STR0109 + Substr(SA2->A2_BAIRRO,1,25),nLinPC,1025)
	oReport:SkipLine()

	If cPaisLoc == "BRA"
		cCGC	:= Transform(SA2->A2_CGC,Iif(SA2->A2_TIPO == 'F',Substr(PICPES(SA2->A2_TIPO),1,17),Substr(PICPES(SA2->A2_TIPO),1,21)))
	Else
		cCGC	:= SA2->A2_CGC
	EndIf

	nLinPC := oReport:Row()
	oReport:PrintText(STR0089 + Trans(SM0->M0_CEPENT,PesqPict("SA2","A2_CEP"))+Space(2)+STR0090 + "  " + RTRIM(SM0->M0_CIDENT) + " " + STR0091 + SM0->M0_ESTENT ,nLinPC,15)
	oReport:PrintText(STR0110+Left(SA2->A2_MUN, 30)+" "+STR0111+SA2->A2_EST+" "+STR0112+SA2->A2_CEP+" "+STR0124+":"+cCGC,nLinPC,1025)
	oReport:SkipLine()

	nLinPC := oReport:Row()
	oReport:PrintText(STR0092 + SM0->M0_TEL + Space(2) + STR0093 + SM0->M0_FAX ,nLinPC,15)
	oReport:PrintText(STR0094 + "("+Substr(SA2->A2_DDD,1,3)+") "+Substr(SA2->A2_TEL,1,15) + " "+STR0114+"("+Substr(SA2->A2_DDD,1,3)+") "+SubStr(SA2->A2_FAX,1,15)+" "+If( cPaisLoc$"ARG|POR|EUA",space(11) , STR0095 )+If( cPaisLoc$"ARG|POR|EUA",space(18), SA2->A2_INSCR ),nLinPC,1025)
	oReport:SkipLine()

	nLinPC := oReport:Row()
	oReport:PrintText(STR0124 + Transform(SM0->M0_CGC,PesqPict("SA2","A2_CGC")) ,nLinPC,15)
	If cPaisLoc == "BRA"
		oReport:PrintText(Space(2) + STR0041 + InscrEst() ,nLinPC,415)
	Endif
	oReport:SkipLine()
	oReport:SkipLine()

	oSection1:Finish()

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³R110FIniPC³ Autor ³ Edson Maricate        ³ Data ³20/05/2000³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Inicializa as funcoes Fiscais com o Pedido de Compras      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ R110FIniPC(ExpC1,ExpC2)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 := Numero do Pedido                                  ³±±
±±³          ³ ExpC2 := Item do Pedido                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR110,MATR120,Fluxo de Caixa                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function R110FIniPC(cPedido,cItem,cSequen,cFiltro)

	Local aArea		:= GetArea()
	Local aAreaSC7	:= SC7->(GetArea())
	Local cValid		:= ""
	Local nPosRef		:= 0
	Local nItem		:= 0
	Local cItemDe		:= IIf(cItem==Nil,'',cItem)
	Local cItemAte	:= IIf(cItem==Nil,Repl('Z',Len(SC7->C7_ITEM)),cItem)
	Local cRefCols	:= ''
	DEFAULT cSequen	:= ""
	DEFAULT cFiltro	:= ""

	dbSelectArea("SC7")
	dbSetOrder(1)
	If dbSeek(xFilial("SC7")+cPedido+cItemDe+Alltrim(cSequen))
		MaFisEnd()
		MaFisIni(SC7->C7_FORNECE,SC7->C7_LOJA,"F","N","R",{})
		While !Eof() .AND. SC7->C7_FILIAL+SC7->C7_NUM == xFilial("SC7")+cPedido .AND. ;
		SC7->C7_ITEM <= cItemAte .AND. (Empty(cSequen) .OR. cSequen == SC7->C7_SEQUEN)

			// Nao processar os Impostos se o item possuir residuo eliminado
			If &cFiltro
				dbSelectArea('SC7')
				dbSkip()
				Loop
			EndIf

			// Inicia a Carga do item nas funcoes MATXFIS
			nItem++
			MaFisIniLoad(nItem)
			dbSelectArea("SX3")
			dbSetOrder(1)
			dbSeek('SC7')
			While !EOF() .AND. (SX3->X3_ARQUIVO == 'SC7')
				cValid	:= StrTran(UPPER(SX3->X3_VALID)," ","")
				cValid	:= StrTran(cValid,"'",'"')
				If "MAFISREF" $ cValid
					nPosRef  := AT('MAFISREF("',cValid) + 10
					cRefCols := Substr(cValid,nPosRef,AT('","MT120",',cValid)-nPosRef )
					// Carrega os valores direto do SC7.
					MaFisLoad(cRefCols,&("SC7->"+ SX3->X3_CAMPO),nItem)
				EndIf
				dbSkip()
			End
			MaFisEndLoad(nItem,2)
			dbSelectArea('SC7')
			dbSkip()
		End
	EndIf

	RestArea(aAreaSC7)
	RestArea(aArea)

Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³R110Logo  ³ Autor ³ Materiais             ³ Data ³07/01/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Retorna string com o nome do arquivo bitmap de logotipo    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ MATR110                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function R110Logo()

	Local cBitmap := "LGRL"+SM0->M0_CODIGO+SM0->M0_CODFIL+".BMP" // Empresa+Filial

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se nao encontrar o arquivo com o codigo do grupo de empresas ³
	//³ completo, retira os espacos em branco do codigo da empresa   ³
	//³ para nova tentativa.                                         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File( cBitmap )
		cBitmap := "LGRL" + AllTrim(SM0->M0_CODIGO) + SM0->M0_CODFIL+".BMP" // Empresa+Filial
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se nao encontrar o arquivo com o codigo da filial completo,  ³
	//³ retira os espacos em branco do codigo da filial para nova    ³
	//³ tentativa.                                                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File( cBitmap )
		cBitmap := "LGRL"+SM0->M0_CODIGO + AllTrim(SM0->M0_CODFIL)+".BMP" // Empresa+Filial
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se ainda nao encontrar, retira os espacos em branco do codigo³
	//³ da empresa e da filial simultaneamente para nova tentativa.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File( cBitmap )
		cBitmap := "LGRL" + AllTrim(SM0->M0_CODIGO) + AllTrim(SM0->M0_CODFIL)+".BMP" // Empresa+Filial
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se nao encontrar o arquivo por filial, usa o logo padrao     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !File( cBitmap )
		cBitmap := "LGRL"+SM0->M0_CODIGO+".BMP" // Empresa
	EndIf

Return cBitmap
