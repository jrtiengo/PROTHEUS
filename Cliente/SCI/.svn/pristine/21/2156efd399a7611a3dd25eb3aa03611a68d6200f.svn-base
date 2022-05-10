#include "Totvs.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SCIA080  ³ Autor ³ Denis Rodrigues     ³ Data ³ 02/04/2015 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Tela de amarracao do Contrato do Licenciado X Pontos de    ³±±
±±³          ³ Venda. Rotina e chamada a partir do PE CTA100MNU           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_SCIA080()                                                ³±±
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
User Function SCIA080()

Local cCadastro:= "Licenciado x Pontos de Venda"
Local cNumCto	:= CN9->CN9_NUMERO
Local cNumRev	:= CN9->CN9_REVISA
Local cCodLic	:= CN9->CN9_CLIENT+" - "+CN9->CN9_LOJACL
Local cNomLic	:= ""
Local cMsg		:= ""
Local aAlter	:= {"ZB_CODPDV","ZB_NOME","ZB_CNPJ"}
Local aCabec	:= {}
Local aItens	:= {}
Local lOK		:= .F.
Local oGetDados
Local oPanel
Local oDlg2

nUsado := 0

//+-------------------------------+
//| Verifica o status do Contrato |
//+-------------------------------+
If CN9->CN9_SITUAC = '05'
	lOK := .T.
Else
	cMsg += "Só é permitida a amarração para contratos em situação de Vigência."+CRLF
	cMsg += "Altere seu Status e tenta novamente."
	lOK := .F.
EndIf

//+------------------------------+
//| Verifica o status do Cliente |
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
	
	dbSelectArea("SZB")
	//dbSelectArea("SX3")
	OpenSxs(,,,,,"SX3TRB","SX3",,.F.)
	If Select("SX3TRB") > 0
		
		dbSelectArea('SX3TRB')
		SX3TRB->( dbSetOrder( 1 ) ) //ORDENA POR ALIAS
		SX3TRB->( dbGoTop(  ) )
		SX3TRB->( dbSeek("SZ9") )
		
		While ( !Eof() .And. SX3TRB->&('X3_ARQUIVO') == "SZB" )
			
			If	!(AllTrim(SX3TRB->&('X3_CAMPO')) $ "ZB_FILIAL|ZB_CODLIC|ZB_LOJLIC|ZB_NUMCTO|ZB_REVISA")
				
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
	
	//+---------------------------------------------------------------+
	//| Funcao que preenche o array aItens com os dados da Tabela SZB |
	//+---------------------------------------------------------------+
	aItens := A080BROWSE( CN9->CN9_NUMERO,CN9->CN9_REVISA,CN9->CN9_CLIENT,CN9->CN9_LOJACL )
	
	If Empty(aItens)
		
		aAdd(aItens,Array(nUsado+1))
		For nCntFor := 1 To nUsado
			aItens[Len(aItens)][nCntFor] := CriaVar(aCabec[nCntFor][2])
		Next nCntFor
		aItens[Len(aItens)][Len(aCabec)+1] := .F.
		
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
	
	oGetDados := MsNewGetDados():New(055, 005, 220,400,+GD_INSERT+GD_UPDATE+GD_DELETE,"AllwaysTrue","AllwaysTrue","",;
	aAlter,0,,"AllwaysTrue","AllwaysTrue","AllwaysTrue",oDlg2 ,aCabec,aItens)
	
	@ 225,150 BUTTON oBtnConf PROMPT "&Salvar" 	SIZE 35,15 ACTION( Iif( A080SALVAR( oGetDados ),oDlg2:End(),) ) OF oDlg2 PIXEL
	@ 225,200 BUTTON oBtnCanc PROMPT "&Cancelar" SIZE 35,15 ACTION( oDlg2:End() ) OF oDlg2 PIXEL
	
	ACTIVATE MSDIALOG oDlg2 CENTERED
	
Else
	Aviso( "Mensagem", cMsg, {"OK"},2 )
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A080BROWSE ³ Autor ³ Denis Rodrigues   ³ Data ³  02/04/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para retornar os dados para o GetDados              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³  U_A080BROWSE( cExp1,cExp2,cExp3,cExp4)                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 = Numero do Contrato                                 ³±±
±±³          ³ cExp2 = Revisao do Contrato                                ³±±
±±³          ³ cExp3 = Codigo do Licenciado                               ³±±
±±³          ³ cExp4 = Loja do Licenciado                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ array com itens                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente Internacional                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A080BROWSE( cNumCto,cNumRev,cCodLic, cLojCli )

Local cQuery 	 := ""
Local cAliasTmp := GetNextAlias()
Local aItem		 := {}

cQuery := " SELECT ZB_CODPDV,"
cQuery += "        ZB_NOME,"
cQuery += "        ZB_CNPJ"
cQuery += " FROM "+RetSQLName("SZB")
cQuery += " WHERE ZB_FILIAL  = '"+xFilial("SZB")+"'"
cQuery += "   AND ZB_CODLIC  = '"+cCodLic+"'"
cQuery += "   AND ZB_LOJLIC  = '"+cLojCli+"'"
cQuery += "   AND ZB_NUMCTO  = '"+cNumCto+"'"
cQuery += "   AND ZB_REVISA  = '"+cNumRev+"'"
cQuery += "   AND D_E_L_E_T_ <>'*' "
cQuery := ChangeQuery(cQuery)
dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasTmp,.F.,.T. )

If ( cAliasTmp )->( !EOF() )
	
	While ( cAliasTmp )->( !EOF() )
		
		aAdd( aItem, { ( cAliasTmp )->ZB_CODPDV,;
		( cAliasTmp )->ZB_NOME,;
		( cAliasTmp )->ZB_CNPJ,;
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
±±³Funcao    ³ A080SALVAR ³ Autor ³ Denis Rodrigues   ³ Data ³  02/04/2015³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para salvar, editar ou excluir os dados do GetDados ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A080SALVAR(oExp1)                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ oExp1 = Objeto do MsGetDados                               ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente SCI                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A080SALVAR( oGetDados )

Local cSeek	  := ""
Local cMsg	  := ""
Local nCont   := 0
Local nOpc 	  := 0
Local nPosPDV := aScan(oGetDados:aHeader,{|x| x[2] = "ZB_CODPDV"})
Local nPosNom := aScan(oGetDados:aHeader,{|x| x[2] = "ZB_NOME"})
Local nPosCGC := aScan(oGetDados:aHeader,{|x| x[2] = "ZB_CNPJ"})
Local lOK	  := .F.
Local lContin := .T.

//+-----------------------------------------------+
//| Verifica se os campos estao sendo preenchidos |
//+-----------------------------------------------+
If aScan( oGetDados:aCols, {|x| AllTrim( x[1] ) == ""} ) > 0 .Or.;
	aScan( oGetDados:aCols, {|x| AllTrim( x[2] ) == ""} ) > 0 .Or.;
	aScan( oGetDados:aCols, {|x| AllTrim( x[3] ) == ""} ) > 0
	
	Help("",1,"Prencher Campo",,"Existem campos que não foram preenchidos.",1,0)
	lContin := .F.
	
EndIf

//+-----------------------------------------------+
//| Verifica os registros marcados como deletados |
//| e impede a gravacao dos mesmos caso ja exista |
//| apontamento na tabela SZA                     |
//+-----------------------------------------------+
If !A080VeriGetDados( oGetDados:aCols )
	
	cMsg := "O registro marcado para ser excluido"
	cMsg += " possui lançamentos salvos pelo Portal do Licenciado."
	cMsg += " A manutenção não poderá ser efetivada."
	Aviso( "Inconsistência",cMsg, {"OK"},1)
	lContin := .F.
	
EndIf


//+-----------------------------------------------+
//| Se passar pelas validacores do GetDados       |
//| continua o processo de gravacao               |
//+-----------------------------------------------+
If lContin
	
	nOpc := Aviso( "Salvar", "Deseja salvar?", {"Sim","Não"},1)
	
	If nOpc = 1
		
		For nCont := 1 To Len( oGetDados:aCols )
			
			cSeek := xFilial("SZB")
			cSeek += CN9->CN9_CLIENT
			cSeek += CN9->CN9_LOJACL
			cSeek += CN9->CN9_NUMERO
			cSeek += CN9->CN9_REVISA
			cSeek += oGetDados:aCols[nCont][nPosPDV]
			cSeek += oGetDados:aCols[nCont][nPosCGC]
			
			If !oGetDados:aCols[nCont][4]//Se não estiver deletado
				
				dbSelectArea("SZB")
				dbSetOrder(1)//ZB_FILIAL+ZB_CODLIC+ZB_LOJLIC+ZB_NUMCTO+ZB_REVISA+ZB_CODPDV+ZB_CNPJ
				If dbSeek( cSeek )
					Reclock("SZB",.F.)
				Else
					Reclock("SZB",.T.)
				EndIf
				
				SZB->ZB_FILIAL := xFilial("SZB")
				SZB->ZB_CODLIC := CN9->CN9_CLIENT
				SZB->ZB_LOJLIC := CN9->CN9_LOJACL
				SZB->ZB_NUMCTO := CN9->CN9_NUMERO
				SZB->ZB_REVISA := CN9->CN9_REVISA
				SZB->ZB_CODPDV := oGetDados:aCols[nCont][nPosPDV]
				SZB->ZB_NOME	:=	oGetDados:aCols[nCont][nPosNom]
				SZB->ZB_CNPJ	:= oGetDados:aCols[nCont][nPosCGC]
				
				MsUnLock()
				
			Else
				
				dbSelectArea("SZB")
				dbSetOrder(1)//ZB_FILIAL+ZB_CODLIC+ZB_LOJLIC+ZB_NUMCTO+ZB_REVISA+ZB_CODPDV+ZB_CNPJ
				If dbSeek( cSeek )
					Reclock("SZB",.F.)
					dbDelete()
					Msunlock()
				EndIf
				
			EndIf
			
		Next nCont
		
		lOK := .T.
		
	EndIf
	
EndIf

Return( lOK )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A080VeriGetDados ³Autor ³ Denis Rodrigues ³ Data ³ 09/04/15³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao que verifica se existe lancamento do Ponto de Venda ³±±
±±³          ³ na tabela SZA e nao permite a exclusao do registro         ³±±
±±³          ³ previnindo a inconsistencia de dados                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A080VERIGETDADOS(aExp1)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ aExp1 - Array com os itens                                 ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente Internacional                           ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A080VERIGETDADOS( aGetDados )

Local cQuery := ""
Local cAlias1:= ""
Local nCnt   := 0
Local lOK 	 := .T.

For nCnt := 1 To Len( aGetDados )
	
	//+-----------------------------------------------------------------------------+
	//| Se estiver marcado para deletar verifica se existe lancamento na tabela SZA |
	//+-----------------------------------------------------------------------------+
	If aGetDados[nCnt][4]
		
		cAlias1:= GetNextAlias()
		cQuery := " SELECT COUNT(*) AS EXISTE"
		cQuery += " FROM "+RetSQLName("SZA")
		cQuery += " WHERE ZA_CODPDV = '"+aGetDados[nCnt][1]+"'"
		cQuery += "   AND D_E_L_E_T_ <> '*'"
		cQuery := ChangeQuery( cQuery )
		dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAlias1,.F.,.T. )
		
		If ( cAlias1 )->EXISTE > 0
			lOK := .F.
		EndIf
		
		( cAlias1 )->( dbCloseArea() )
		
	EndIf
	
Next nCont

Return( lOK )
