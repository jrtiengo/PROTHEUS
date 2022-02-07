#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
/*/-----------------------------------------------------------------/
{Protheus.doc} TEDR020
Rotina para impressão de ficha financeira por cliente de títulos
baixados.
@type  User Function
@author Jean Rehermann - Solutio IT
@since 06/07/2020
@return Nil
/-----------------------------------------------------------------/*/
User Function TEDR020()

	Local cCadastro := "Geração de arquivo com dados das notas"
	Local aSays		:= {}
	Local aButtons	:= {}
	Local cPerg     := "TEDR020"

	Pergunte(cPerg,.F.)

	aAdd( aSays, OemToAnsi (' Este programa tem como objetivo gerar relatório de ficha  ') )
	aAdd( aSays, OemToAnsi (' financeira por cliente.                                   ') )
	aAdd( aSays, OemToAnsi ('                                                           ') )
	aAdd( aSays, OemToAnsi (' Selecione os parâmetros.                                  ') )

	aAdd( aButtons, { 5,.T.,{|o| Pergunte( cPerg,.T. ) } } )
	aAdd( aButtons, { 1,.T.,{|o| Processa( {|| RodaPrt()}, "Aguarde", "Gerando dados e relatório..."), FechaBatch() } } )
	aAdd( aButtons, { 2,.T.,{| | FechaBatch() } } )

	FormBatch( cCadastro, aSays, aButtons )

Return

/*/-----------------------------------------------------------------/
	{Protheus.doc} RodaPrt
	Geração dos dados para impressão e preparação do relatório
	@type  Static Function
	@author Jean Rehermann - Solutio IT
	@since 06/07/2020
	@return Nil
/-----------------------------------------------------------------/*/
Static Function RodaPrt()

	Local cDesc1  := "Este programa irá imprimir a ficha financeira de "
	Local cDesc2  := "clientes de títulos baixados."
	Local cDesc3  := ""
	Local cAliasTemp := ""

	Private nomeprog :="TEDR020"
	Private cabec1,cabec2,nLastKey:=0,titulo,wnrel,tamanho:="M",m_pag:=1
	Private aReturn:={"Zebrado",1,"Administracao",1,2,1,"",1}

	titulo:= "Ficha Financeira por Cliente (Baixado)"
	cabec1:= ""
	cabec2:= ""

	wnrel:="TEDR020"
	wnrel:=SetPrint(cAliasTemp,wnrel,"",@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho,,.F.)

	If nLastKey == 27
		Return
	Endif

	SetDefault(aReturn)

	If nLastKey == 27
		Return
	Endif

	cQuery := "SELECT E1_EMISSAO, E1_VALOR, E1_VENCTO, E1_BAIXA, E1_CLIENTE, E1_LOJA, "
	cQuery += " E1_PREFIXO, E1_NUM, E1_PARCELA, E1_VEND1, E1_SALDO, E1_PORTADO "
	cQuery += " FROM "+ RetSqlName("SE1")
	cQuery += " WHERE E1_FILIAL = '"+ If( Empty( Mv_par01 ), xFilial("SE1"), Mv_par01 ) +"' "
	cQuery += "   AND E1_EMISSAO BETWEEN '"+ DtoS( Mv_par02 ) +"' AND '"+ DtoS( Mv_par03 ) +"' "
	cQuery += "   AND E1_BAIXA   BETWEEN '"+ DtoS( Mv_par04 ) +"' AND '"+ DtoS( Mv_par05 ) +"' "
	If !Empty(Mv_par06+Mv_par07 )
		cQuery += "   AND E1_CLIENTE BETWEEN '"+ Mv_par06 +"' AND '"+ Mv_par07 +"' "
	Endif
	If !Empty(Mv_par08+Mv_par09 )
		cQuery += "   AND E1_LOJA    BETWEEN '"+ Mv_par08 +"' AND '"+ Mv_par09 +"' "
	Endif
	If !Empty(Mv_par10+Mv_par11 )
		cQuery += "   AND E1_VEND1   BETWEEN '"+ Mv_par10 +"' AND '"+ Mv_par11 +"' "
	Endif
	cQuery += "   AND D_E_L_E_T_ = ' ' "
	cQuery += "   AND E1_BAIXA <> ' ' "
	cQuery += "   AND E1_SALDO < E1_VALOR "
	cQuery += " ORDER BY E1_FILIAL, E1_VEND1, E1_CLIENTE, E1_NUM "

	TCQuery cQuery New Alias ( cAliasTemp := GetNextAlias() )

	RptStatus( { |lEnd| TR020IMP( @lEnd, wnRel, cAliasTemp ) }, Titulo )

	(cAliasTemp)->( dbCloseArea() )

Return

/*/-----------------------------------------------------------------/
	{Protheus.doc} TR020IMP
	Função que realiza a impressão do detalhe.
	@type  Static Function
	@author Jean Rehermann - Solutio IT
	@since 06/07/2020
	@return Nil
/-----------------------------------------------------------------/*/
Static Function TR020IMP( lEnd, wnRel, cAliasTemp )

	Local nRecs    := 0
	Local nValAcum := 0
	Local lFirst   := .T.
	Local cCliAtu  := ""

	Private li := 2

	Count To nRecs
	(cAliasTemp)->( dbGotop() )

	SetRegua( nRecs )

	While !(cAliasTemp)->( Eof() )

		If Empty( cCliAtu ) .Or. cCliAtu != (cAliasTemp)->E1_CLIENTE + (cAliasTemp)->E1_LOJA

			If !lFirst
				li+=2
				@li,001 PSAY Repl("-",120)
				li++
				@li,002 PSAY "Total acumulado para este cliente : "+ Transform( nValAcum, "@E 999,999,999.99" )
				li++
				@li ,001 PSAY Repl("-",120)
				nValAcum := 0
			Else
				lFirst := .F.
			EndIf

			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=6
			cCliAtu := (cAliasTemp)->E1_CLIENTE + (cAliasTemp)->E1_LOJA
			SA1->( dbSetOrder(1) )
			SA1->( dbSeek( xFilial("SA1") + cCliAtu ) )

			@li,001 PSAY "Razao Social: "+ SubStr( SA1->A1_NOME, 1, 30 )
			@li,045 PSAY "CNPJ/CPF: "+ Transform( SA1->A1_CGC, Iif( SA1->A1_PESSOA=="J","@R 99.999.999/9999-99" ,"@R 999.999.999-99" ) )
			@li,072 PSAY "Insc.Est.: "+ AllTrim( SA1->A1_INSCR )
			li++
			@li,001 PSAY "End. Entrega: "+ AllTrim( SA1->A1_ENDENT )
			@li,045 PSAY "Bairro: "+ AllTrim( SA1->A1_BAIRROE )
			@li,065 PSAY "Cidade: "+ AllTrim( SA1->A1_MUNE ) +" - "+ SA1->A1_ESTE
			li++
			@li,001 PSAY "End. Cobranca: "+ AllTrim( SA1->A1_ENDCOB )
			@li,045 PSAY "Bairro: "+ AllTrim( SA1->A1_BAIRROC )
			@li,065 PSAY "Cidade: "+ AllTrim( SA1->A1_MUNC ) +" - "+ SA1->A1_ESTC
			li++
			@li,001 PSAY "Telefone: "+ SA1->A1_TEL +"   Fax : "+ SA1->A1_FAX
			li++
			@li,001 PSAY "Representante: "+ (cAliasTemp)->E1_VEND1
			li++
			@li,001 PSAY "Limite Cred. (R$) : "+ Transform( SA1->A1_LC, "@E 999,999,999.99" )
			li++
			@li,001 PSAY "Saldo L.Cred.(R$) : "+ Transform( SA1->A1_LC - SA1->A1_SALDUP, "@E 999,999,999.99" )
			li++
			@li,001 PSAY Repl("-",120)
			li+=2
			@li,001 PSAY "Emissão   Nro. Título  Valor Nominal  Vencimento Pagamento  Portador   Acumulado R$"
			li+=2
		EndIf

		If lEnd
			@li+1,001 PSAY "CANCELADO PELO OPERADOR"
			lContinua := .F.
			Exit
		EndIf

		IncRegua()

		@li,01 PSay DTOC( STOD( (cAliasTemp)->E1_EMISSAO ) )
		@li,12 PSay (cAliasTemp)->E1_NUM
		@li,23 PSay Transform( (cAliasTemp)->E1_VALOR, "@E 999,999,999.99" )
		@li,39 PSay DTOC( STOD( (cAliasTemp)->E1_VENCTO ) )
		@li,50 PSay DTOC( STOD( (cAliasTemp)->E1_BAIXA ) )
		@li,64 PSay (cAliasTemp)->E1_PORTADOR
		@li,71 PSay Transform( nValAcum += (cAliasTemp)->E1_VALOR, "@E 999,999,999.99" )

		li ++

		If li >= 60
			cabec(titulo,cabec1,cabec2,nomeprog,tamanho,18);li:=6

			@li,001 PSAY "Razao Social: "+ SubStr( SA1->A1_NOME, 1, 30 )
			@li,045 PSAY "CNPJ/CPF: "+ Transform( SA1->A1_CGC, Iif(SA1->A1_PESSOA=="J","@S 99.999.999/9999-99" ,"@S 999.999.999-99" ) )
			@li,072 PSAY "Insc.Est.: "+ AllTrim( SA1->A1_INSCR )
			li++
			@li,001 PSAY "End. Entrega: "+ AllTrim( SA1->A1_ENDENT )
			@li,045 PSAY "Bairro: "+ AllTrim( SA1->A1_BAIRROE )
			@li,065 PSAY "Cidade: "+ AllTrim( SA1->A1_MUNE ) +" - "+ SA1->A1_ESTE
			li++
			@li,001 PSAY "End. Cobranca: "+ AllTrim( SA1->A1_ENDCOB )
			@li,045 PSAY "Bairro: "+ AllTrim( SA1->A1_BAIRROC )
			@li,065 PSAY "Cidade: "+ AllTrim( SA1->A1_MUNC ) +" - "+ SA1->A1_ESTC
			li++
			@li,001 PSAY "Telefone: "+ SA1->A1_TEL +"   Fax : "+ SA1->A1_FAX
			li++
			@li,001 PSAY "Representante: "+ (cAliasTemp)->E1_VEND1
			li++
			@li,001 PSAY "Limite Cred. (R$) : "+ Transform( SA1->A1_LC, "@E 999,999,999.99" )
			li++
			@li,001 PSAY "Saldo L.Cred.(R$) : "+ Transform( SA1->A1_LC - SA1->A1_SALDUP, "@E 999,999,999.99" )
			li++
			@li,001 PSAY Repl("-",120)
			li+=2
			@li,001 PSAY "Emissão   Nro. Título  Valor Nominal  Vencimento Pagamento  Portador   Acumulado R$"
			li+=2
		EndIf


		(cAliasTemp)->( dbSkip() )
	End

	If nValAcum > 0
		li+=2
		@li,001 PSAY Repl("-",120)
		li++
		@li,002 PSAY "Total acumulado para este cliente : "+ Transform( nValAcum, "@E 999,999,999.99" )
		li++
		@li ,001 PSAY Repl("-",120)
	EndIf

	If aReturn[5] = 1
		Set Printer TO
		dbCommitAll()
		ourspool(wnrel)
	Endif

	MS_FLUSH()

Return Nil
