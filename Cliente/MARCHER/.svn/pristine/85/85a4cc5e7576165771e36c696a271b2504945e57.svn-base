#INCLUDE "TOTVS.ch"
#INCLUDE "FWMVCDef.ch"

/*/{Protheus.doc} CM010TOK
Validação na Confirmação da Tabela de Preços - Cria Produto X Fornecedor
CM010TOK.PRW - Cadastro de Tabela de Preço
@type function
@version 12.1.25
@author Márcio Quevedo Borges
@since 10/10/2018
@return logical, .T. ou .F.
/*/
User Function CM010TOK()

	Local nContar       := 0
	Local lDataVigencia := .F.
	Local aComboBx1	    := {"Não","Sim"}
	Local cMemo1	    := ""
	Local cMemo2	    := ""
	Local cFilSB1       := xFilial("SB1")
	Local lTudoOk       := PARAMIXB[1] // Recebe variável lógica se bloqueia ou aprova inclusão/alteração dos registros
	Local aProdutos     := {}
	Local nPosVigencia  := aScan( aHeader, { |x| x[2] == 'AIB_DATVIG' } )
	Local nPosProduto   := aScan( aHeader, { |x| x[2] == 'AIB_CODPRO' } )
	Local cComboBx1
	Local oMemo1
	Local oMemo2

	Private oDlg

	// ###########################
	// Envia para a função Roda ##
	// ###########################
	Processa({|| (lTudoOk := Roda())},"Produto x Fornecedor","Criando e atualizando amarrações...")

	//IW_MsgBox("Passou pelo PE_CM010TOK",OemToAnsi("Informativo"),"INFO" )

	// ###################################################################################################################
	// Validação sobre a data de vegência dos produtos em relação da data final de vigência da tabela de preço          ##
	// Se houver produtos da lista de preço com a data de vigência <> do cabeçalho, sistema pergunta se deseja alterar  ##
	// as datas de vigência dos produtos com a data inicial de vigência do cabeçalho.                                   ##
	// ###################################################################################################################
	lDataVigencia := .F.

	For nContar = 1 to Len(acols)
		If aCols[nContar, nPosVigencia] > M->AIA_DATDE
			lDataVigencia := .T.
			Exit
		Endif
	Next nContar

	If lDataVigencia == .T.

		DEFINE MSDIALOG oDlg TITLE "Tabela de Preços" FROM C(178),C(181) TO C(328),C(516) PIXEL

		@ C(005),C(005) Say "DATA DE VIGÊNCIA DOS PRODUTOS DA LISTA DE PREÇO"                  Size C(115),C(008) COLOR CLR_BLACK PIXEL OF oDlg
		@ C(017),C(005) Say "Existem produtos que estão com sua data de vigência maior do que a" Size C(160),C(008) COLOR CLR_BLACK PIXEL OF oDlg
		@ C(025),C(005) Say "data de vigência inicial da tabela de preço."                       Size C(100),C(008) COLOR CLR_BLACK PIXEL OF oDlg
		@ C(034),C(034) Say "Desejo atualizar a data de vigência dos produtos pela"            Size C(127),C(008) COLOR CLR_BLACK PIXEL OF oDlg
		@ C(042),C(034) Say "data de vigência Inicial da tabela de preço ?"                       Size C(101),C(008) COLOR CLR_BLACK PIXEL OF oDlg

		@ C(013),C(005) GET oMemo1 Var cMemo1 MEMO Size C(159),C(001) PIXEL OF oDlg
		@ C(052),C(005) GET oMemo2 Var cMemo2 MEMO Size C(159),C(001) PIXEL OF oDlg

		@ C(033),C(005) ComboBox cComboBx1 Items aComboBx1 Size C(027),C(010) PIXEL OF oDlg

		@ C(057),C(066) Button "Continuar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

		ACTIVATE MSDIALOG oDlg CENTERED

		If cComboBx1 == "Sim"

			For nContar = 1 to Len(aCols)
				aCols[nContar,nPosVigencia] := M->AIA_DATDE
			Next nContar

		Endif

	Endif

	// #############################################################################################################
	// Verifica se existe algum produto da lista de preço sem o vínculo com o fornecedor no cadastro de produtos. ##
	// Se existir produto sem vínculo, solicita ao usuário se deseja realizar o vínculo destes produtos.          ##
	// #############################################################################################################
	For nContar := 1 to Len(acols)

		If Empty(Alltrim(Posicione( "SB1", 1, cFilSB1 + aCols[nContar, nPosProduto], "B1_PROC")))
			aAdd( aProdutos, aCols[nContar, nPosProduto] )
		Endif

	Next nContar

	If Len(aProdutos) <> 0

		DEFINE MSDIALOG oDlg TITLE "Tabela de Preços" FROM C(178),C(181) TO C(304),C(516) PIXEL

		@ C(005),C(005) Say "FORNECEDOR PADRÃO PRODUTOS DA TABELA DE PREÇO"                        Size C(115),C(008) COLOR CLR_BLACK PIXEL OF oDlg
		@ C(017),C(005) Say "Existem produtos desta lista que não estão vinculados ao fornecedor." Size C(200),C(008) COLOR CLR_BLACK PIXEL OF oDlg
		@ C(028),C(034) Say "Desejo vincular este fornecedor aos produtos desta lista de preço."   Size C(130),C(008) COLOR CLR_BLACK PIXEL OF oDlg

		@ C(013),C(005) GET oMemo1 Var cMemo1 MEMO Size C(179),C(001) PIXEL OF oDlg
		@ C(040),C(005) GET oMemo2 Var cMemo2 MEMO Size C(179),C(001) PIXEL OF oDlg

		@ C(027),C(005) ComboBox cComboBx1 Items aComboBx1 Size C(027),C(010) PIXEL OF oDlg

		@ C(044),C(066) Button "Continuar" Size C(037),C(012) PIXEL OF oDlg ACTION( oDlg:End() )

		ACTIVATE MSDIALOG oDlg CENTERED

		If cComboBx1 == "Sim"

         DbSelectArea("SB1")
         DbSetOrder(1)

			For nContar := 1 to Len(aProdutos)

				If DbSeek( cFilSB1 + aProdutos[nContar])
					RecLock("SB1",.F.)
					SB1->B1_PROC    := M->AIA_CODFOR
					SB1->B1_LOJPROC := M->AIA_LOJFOR
					MsUnLock()
				EndIf

			Next nContar

		EndIf

	EndIf

Return( lTudoOk )


/*/{Protheus.doc} Roda
Executar a verificação no cadastro de Produto X Fornecedor.
@type function
@version 12.1.25
@author Jorge Alberto - Solutio
@since 16/12/2021
@return logical, Sempre .T.
/*/
Static Function Roda()

	Local _cMensagem  := ""
	Local cNomeAjus   := ""
	Local cCmpoCodRef := Space( Len( SA5->A5_CODPRF ) )
	Local cFilSA2     := xFilial("SA2")
	Local cFilSA5     := xFilial("SA5")
	Local cFilSB1     := xFilial("SB1")
	Local x           := 0
	Local nQtdReg     := Len( oGetDad:aCols )
	Local aErro       := {}
	Local oDlgErro
	Local oModel
	Local oFont

   ProcRegua( nQtdReg )

   DbSelectArea("SA5")
   DBSetOrder(1)

   DbSelectArea("SB1")
   DBSetOrder(1)

	For x := 1 To nQtdReg

		SB1->( DbSeek( cFilSB1 + oGetDad:aCols[x][GDFieldPos( "AIB_CODPRO" )] ) )

		If SB1->B1_MSBLQL == '1'
			_cMensagem += "Produto "+ alltrim(oGetDad:aCols[x][GDFieldPos( "AIB_CODPRO" )]) + " está Bloquado para uso." + CRLF
		Else

			If .NOT. SA5->( DbSeek( cFilSA5 + M->AIA_CODFOR + M->AIA_LOJFOR + oGetDad:aCols[x][GDFieldPos( "AIB_CODPRO" )] ) )

				Begin Transaction

					oModel := FWLoadModel('MATA061')

					oModel:SetOperation(3)
					oModel:Activate()

					//Cabeçalho
					oModel:SetValue('MdFieldSA5','A5_PRODUTO',oGetDad:aCols[x][GDFieldPos("AIB_CODPRO")] )
					cNomeAjus := SubStr( Posicione("SB1",1,cFilSB1+oGetDad:aCols[x][GDFieldPos( "AIB_CODPRO" )],"SB1->B1_DESC"), 1, TamSX3("A5_NOMPROD")[1] )
					oModel:SetValue('MdFieldSA5','A5_NOMPROD', cNomeAjus )

					cNomeAjus := SubStr( Posicione("SA2",1,cFilSA2+M->AIA_CODFOR+M->AIA_LOJFOR,"SA2->A2_NOME"), 1, TamSX3("A5_NOMEFOR")[1] )

					//Grid
					oModel:GetModel( 'MdGridSA5'):AddLine()
					oModel:SetValue( 'MdGridSA5','A5_CODPRF' , cCmpoCodRef )
					oModel:SetValue( 'MdGridSA5','A5_FORNECE', M->AIA_CODFOR )
					oModel:SetValue( 'MdGridSA5','A5_LOJA'   , M->AIA_LOJFOR )
					oModel:SetValue( 'MdGridSA5','A5_NOMEFOR', cNomeAjus )
					oModel:SetValue( 'MdGridSA5','A5_CODTAB' , M->AIA_CODTAB )

					If oModel:VldData()

						oModel:CommitData()

						// dbSelectArea("SA5")
						// DbsetOrder(2)
						// If dbSeek( cFilSA5 + oGetDad:aCols[x][GDFieldPos("AIB_CODPRO")] + M->AIA_CODFOR + M->AIA_LOJFOR )
						// 	RecLock("SA5",.F.)
						// 	If SA5->A5_CODTAB <> M->AIA_CODTAB
						// 		SA5->A5_CODTAB := M->AIA_CODTAB
						// 	EndIf
						// 	SA5->( MsUnlock() )
						// EndIf

						_cMensagem += "Produto "+ AllTrim( oGetDad:aCols[x][GDFieldPos("AIB_CODPRO")]) + " foi cadastrado para o fornecedor "+ AllTrim( M->AIA_CODFOR ) + CRLF

					Else
						// Jorge Alberto - Solutio - 16/12/2021 - Alterando o tratamento do erro.
						aErro := oModel:GetErrorMessage()

						_cMensagem += "ERRO NA INCLUSAO DO PRODUTO X FORNECEDOR!" +CRLF

						If Len( aErro ) > 0
							_cMensagem += "Produto "+AllTrim( oGetDad:aCols[x][GDFieldPos("AIB_CODPRO")]) +CRLF
							_cMensagem += aErro[MODEL_MSGERR_IDFORM]+": "+;
										aErro[MODEL_MSGERR_IDFIELD]+": "+;
										aErro[MODEL_MSGERR_IDFORMERR]+": "+;
										aErro[MODEL_MSGERR_IDFIELDERR]+": "+;
										aErro[MODEL_MSGERR_ID]+" "+;
										aErro[MODEL_MSGERR_MESSAGE]+" / "+aErro[MODEL_MSGERR_SOLUCTION] + CRLF
						EndIf
					EndIf

					oModel:DeActivate()
					oModel:Destroy()
					FreeObj(oModel)

				End Transaction

			ElseIf SA5->A5_CODTAB <> M->AIA_CODTAB

				_cMensagem += "Alterado tabela de preço do Produto "+ alltrim(oGetDad:aCols[x][GDFieldPos( "AIB_CODPRO" )]) + " De: "+ SA5->A5_CODTAB + " Para: " + M->AIA_CODTAB +  CRLF

				RecLock("SA5",.F.)
					SA5->A5_CODTAB := M->AIA_CODTAB
				SA5->( MsUnlock() )

			EndIf // If .NOT. SA5->( DbSeek() )

		EndIf // If SB1->B1_MSBLQL == '1'

		IncProc( "Verificando produto " + AllTrim( oGetDad:aCols[x][GDFieldPos( "AIB_CODPRO" )] ) )

	Next x

	If .NOT. Empty( _cMensagem )
		oFont := TFont():New( "Tahoma",0,-12,,.F.,0,,700,.F.,.F.,,,,,, )
		oDlgErro := MSDialog():New( 092,232,395,789,"Mensagens sobre a atualização Produto x Fornecedor",,,.F.,,,,,,.T.,,,.T. )
			tMultiget():new(008,008,{| u | if( pCount() > 0, _cMensagem := u, _cMensagem )},oDlgErro,256/*nLargura*/,084/*nAltura*/,oFont,,,,,.T./*lPixel*/,,,,,,.F./*lReadOnly*/)
			TButton():New( 112,108,"Voltar",oDlgErro,{||oDlgErro:END()},037,012,,,,.T.,,"",,,,.F. )
		oDlgErro:Activate(,,,.T.)
	EndIf

Return .T.
