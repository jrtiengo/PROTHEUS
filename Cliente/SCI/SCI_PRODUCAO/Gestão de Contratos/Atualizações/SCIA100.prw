#include "Totvs.ch"
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SCIA100  ³ Autor ³ Denis Rodrigues     ³ Data ³ 06/04/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela de amarracao do Contrato do Licenciado X Produts      ³±±
±±³          ³ Rotina e chamada a partir do PE CTA100MNU                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_SCIA100()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente SCI                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function SCIA100()

Local cCadastro:= "Licenciado x Produtos"
Local cNumCto	:= CN9->CN9_NUMERO
Local cNumRev	:= CN9->CN9_REVISA
Local cCodLic	:= CN9->CN9_CLIENT+" - "+CN9->CN9_LOJACL
Local cNomLic	:= ""
Local cMsg		:= ""
Local aAlter	:= {"ZC_CODPRO"}
Local aCabec	:= {}
Local aItens	:= {}
Local lOK		:= .F.
Local oGetDados
Local oPanel
Local oDlg2

nUsado := 0

//+-------------------------------+
//|Verifica o status do Contrato. |
//+-------------------------------+
If CN9->CN9_SITUAC = '05'
	lOK := .T.
Else
	lOK := .F.
	cMsg += "Só é permitida a amarração para contratos em situação de Vigência."+CRLF
	cMsg += "Altere seu Status e tenta novamente."
EndIf

//+------------------------------+
//|Verifica o status do Cliente. |
//+------------------------------+
dbSelectArea("SA1")
dbSetOrder(1)//A1_FILIAL+A1_COD+A1_LOJA
If dbSeek( xFilial("SA1") + CN9->CN9_CLIENT + CN9->CN9_LOJACL )
	
	If  SA1->A1_MSBLQL  <> "S"
		cNomLic := SA1->A1_NOME
	Else
		cMsg += "Cliente do Contrato encontra-se bloqueado no sistema"
		lOK := .F.
	EndIf
	
EndIf

If lOK// Se os Status estiverem OK
	
	//+-----------------------------------------------+
	//|Monta o aHeader conforme o dicionario de dados |
	//+-----------------------------------------------+
	dbSelectArea("SZC")
	//dbSelectArea("SX3")
	OpenSxs(,,,,,"SX3TRB","SX3",,.F.)
	If Select("SX3TRB") > 0
		
		dbSelectArea('SX3TRB')
		SX3TRB->( dbSetOrder( 1 ) ) //ORDENA POR ALIAS
		SX3TRB->( dbGoTop(  ) )
		SX3TRB->( dbSeek("SZC") )
		
		While ( !Eof() .And. X3TRB->&('X3_ARQUIVO') == "SZC" )
			
			If	!(AllTrim(SX3TRB->&('X3_CAMPO')) $ "ZC_FILIAL|ZC_CODLIC|ZC_LOJLIC|ZC_NUMCTO|ZC_REVISA")
				
				If ( X3USO(SX3TRB->&('X3_USADO')) .And. cNivel >= SX3TRB->&('X3_NIVEL') )
					
					If aScan(aNoFields, AllTrim(SX3TRB->&('X3_CAMPO'))) == 0
						
						nUsado++
						Aadd(aHeader,{ TRIM(X3Titulo()),;
						TRIM(SX3TRB->&('X3_CAMPO')),;
						SX3TRB->&('X3_PICTURE'),;
						SX3TRB->&('X3_TAMANHO'),;
						SX3TRB->&('X3_DECIMAL'),;
						SX3TRB->&('X3_VALID'),;
						SX3TRB->&('X3_USADO'),;
						SX3TRB->&('X3_TIPO'),;
						SX3TRB->&('X3_ARQUIVO'),;
						SX3TRB->&('X3_CONTEXT') } )
					EndIf
				EndIf
			EndIf
			
			dbSelectArea("SX3TRB")
			dbSkip()
		EndDo
		
		SX3TRB->( DbCloseArea() )
	EndIf
	
	//+--------------------------------------------------------------+
	//|Funcao que preenche o array aItens com os dados da Tabela SZB |
	//+--------------------------------------------------------------+
	aItens := A100BROWSE( CN9->CN9_NUMERO,CN9->CN9_REVISA,CN9->CN9_CLIENT,CN9->CN9_LOJACL )
	
	If Empty(aItens)
		
		aAdd(aItens,Array(nUsado+1))
		aItens[Len(aItens)][Len(aCabec)+1] := .F.
		
		For nCntFor := 1 To nUsado
			
			If aCabec[nCntFor,2] = "ZC_ITEM"
				aItens[1,nCntFor] := "001"
			Else
				aItens[1][nCntFor] := CriaVar(aCabec[nCntFor][2])
			EndIf
			
		Next nCntFor
		
	EndIf
	
	DEFINE MSDIALOG oDlg2 TITLE cCadastro FROM 001,001 TO 500,800 PIXEL
	@ 005,005 To 050,400 Label "" PIXEL OF oPanel//Linha do Cabecalho
	
	@ 012,010 SAY "Contrato: " SIZE 050,007 OF oDlg2 PIXEL
	@ 010,045 MSGET oNumCto VAR cNumCto SIZE 070,010 OF oDlg2 PIXEL READONLY
	
	@ 012,125 SAY "Revisão: " SIZE 050,007 OF oDlg2 PIXEL
	@ 010,160 MSGET oNumRev VAR cNumRev SIZE 55,010 OF oDlg2 PIXEL READONLY
	
	@ 032,010 SAY "Licenc.: " SIZE 055,007 OF oDlg2 PIXEL
	@ 030,045 MSGET oCodLic VAR cCodLic SIZE 070,010 OF oDlg2 PIXEL READONLY
	
	@ 032,125 SAY "Nome: " SIZE 055,007 OF oDlg2 PIXEL
	@ 030,160 MSGET oNomLic VAR cNomLic SIZE 160,010 OF oDlg2 PIXEL READONLY
	
	oGetDados := MsNewGetDados():New(055, 005, 220,400,+GD_INSERT+GD_UPDATE+GD_DELETE,"AllwaysTrue","AllwaysTrue","++ZC_ITEM",;
	aAlter,0,,"AllwaysTrue","AllwaysTrue","AllwaysTrue",oDlg2 ,aCabec,aItens)
	
	@ 225,150 BUTTON oBtnConf PROMPT "&Salvar" 	SIZE 35,15 ACTION( Iif( A100SALVAR( oGetDados ) , oDlg2:End(),) ) OF oDlg2 PIXEL
	@ 225,200 BUTTON oBtnCanc PROMPT "&Cancelar" SIZE 35,15 ACTION( oDlg2:End() ) OF oDlg2 PIXEL
	
	ACTIVATE MSDIALOG oDlg2 CENTERED
	
Else
	Aviso( "Mensagem", cMsg, {"OK"},2)
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A100BROWSE ³ Autor ³ Denis Rodrigues   ³ Data ³  02/04/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para retornar os dados para o GetDados              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A100BROWSE(cExp1,cExp2,cExp3,cExp4)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 = Numero do Contrato                                 ³±±
±±³          ³ cExp2 = Revisao do Contrato                                ³±±
±±³          ³ cExp3 = Codigo do Licenciado                               ³±±
±±³          ³ cExp4 = Loja do Licenciado                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ array com dados do contrato                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente Internacional                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A100BROWSE( cNumCto,cNumRev,cCodLic, cLojCli )

Local cQuery 	 := ""
Local cAliasTmp := GetNextAlias()
Local aItem		 := {}

cQuery := " SELECT SZC.ZC_ITEM,"
cQuery += "        SZC.ZC_CODPRO,"
cQuery += "        SB1.B1_DESC"
cQuery += " FROM "+RetSQLName("SZC")+" SZC, "
cQuery +=          RetSQLName("SB1")+" SB1 "
cQuery += " WHERE SZC.ZC_FILIAL  = '"+xFilial("SZC")+"'"
cQuery += "   AND SZC.ZC_CODPRO  = SB1.B1_COD"
cQuery += "   AND SZC.ZC_CODLIC  = '"+ cCodLic 		  +"'"
cQuery += "   AND SZC.ZC_LOJLIC  = '"+ cLojCli 		  +"'"
cQuery += "   AND SZC.ZC_NUMCTO  = '"+ cNumCto 		  +"'"
cQuery += "   AND SZC.ZC_REVISA  = '"+ cNumRev 		  +"'"
cQuery += "   AND SZC.D_E_L_E_T_ <>'*' "

cQuery += "   AND SB1.B1_FILIAL  = '"+ xFilial("SB1")+"'"
cQuery += "   AND SB1.D_E_L_E_T_ <>'*'"
cQuery += " ORDER BY SZC.ZC_ITEM"
cQuery := ChangeQuery(cQuery)
dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T. )

If ( cAliasTmp )->( !EOF() )
	
	While ( cAliasTmp )->( !EOF() )
		
		aAdd( aItem, { ( cAliasTmp )->ZC_ITEM,;
		( cAliasTmp )->ZC_CODPRO,;
		( cAliasTmp )->B1_DESC,;
		.F.})
		
		( cAliasTmp )->( dbSkip() )
		
	EndDo
	
EndIf

( cAliasTmp )->( dbCloseArea() )

Return( aItem )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A100SALVAR ³ Autor ³ Denis Rodrigues   ³ Data ³  02/04/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para salvar, editar ou excluir os dados do GetDados ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A100SALVAR(oExp1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oExp1 - Objeto GetDados                                    ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente SCI                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A100SALVAR( oGetDados )

Local cSeek	   := ""
Local nCont    := 0
Local nOpc     := 0
Local nPosIte  := aScan(oGetDados:aHeader,{|x| x[2] = "ZC_ITEM"})
Local nPosPrd  := aScan(oGetDados:aHeader,{|x| x[2] = "ZC_CODPRO"})
Local lOK 	   := .F.
Local lContinua:= .T.

//+--------------------------------------------------------------------+
//| Verifica se os campos estao sendo preenchidos                      |
//+--------------------------------------------------------------------+
If aScan( oGetDados:aCols, {|x| AllTrim( x[2] ) == ""} ) > 0
	Help("",1,"Prencher Campo",,"Existem campos que não foram preenchidos.",1,0)
	lContinua := .F.
EndIf

//+-------------------------------------------------------------------------+
//| Se a validacao do GetDados estiver OK, segue com o processo de gravacao |
//+-------------------------------------------------------------------------+
If lContinua
	
	nOpc := Aviso( "Salvar", "Deseja salvar?", {"Sim","Não"},1)
	
	If nOpc = 1
		
		For nCont := 1 To Len( oGetDados:aCols )
			
			cSeek := xFilial("SZC")
			cSeek += CN9->CN9_CLIENT
			cSeek += CN9->CN9_LOJACL
			cSeek += CN9->CN9_NUMERO
			cSeek += CN9->CN9_REVISA
			cSeek += oGetDados:aCols[nCont][nPosIte]
			
			If !oGetDados:aCols[nCont][4]//Se não estiver deletado
				
				dbSelectArea("SZC")
				dbSetOrder(1)//ZC_FILIAL+ZC_CODLIC+ZC_LOJLIC+ZC_NUMCTO+ZC_REVISA+ZC_CODPRO
				If dbSeek( cSeek )
					Reclock("SZC",.F.)
				Else
					Reclock("SZC",.T.)
				EndIf
				
				SZC->ZC_FILIAL := xFilial("SZC")
				SZC->ZC_CODLIC := CN9->CN9_CLIENT
				SZC->ZC_LOJLIC := CN9->CN9_LOJACL
				SZC->ZC_NUMCTO := CN9->CN9_NUMERO
				SZC->ZC_REVISA := CN9->CN9_REVISA
				SZC->ZC_ITEM 	:= oGetDados:aCols[nCont][nPosIte]
				SZC->ZC_CODPRO := oGetDados:aCols[nCont][nPosPrd]
				
				MsUnLock()
				
			Else
				
				dbSelectArea("SZC")
				dbSetOrder(1)//ZC_FILIAL+ZC_CODLIC+ZC_LOJLIC+ZC_NUMCTO+ZC_REVISA+ZC_CODPRO
				If dbSeek( cSeek )
					
					Reclock("SZC",.F.)
					dbDelete()
					Msunlock()
					
				EndIf
				
			EndIf
			
		Next nCont
		
		lOK := .T.
		
	EndIf
	
EndIf

Return( lOK )
