#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"

#DEFINE CRLF ( CHR(13) + CHR(10) )

/*
Jean Rehermann - Solutio IT - 05/08/2021
Programa monta arquivo excel baseado em query nas notas de entrada pesquisando as pré-notas
*/

User Function MARR005()

	Local cCadastro := "Geração de arquivo com dados das pré-notas"
	Local aSays		:= {}
	Local aButtons	:= {}
	Local aPergs    := {}
	Local dEmissDe  := dDataBase
	Local dEmissAt  := dDataBase

	aAdd( aPergs, {1, "Emissao De"  , dEmissDe, "", ".T.", ""   , ".T.", 40,  .F.} )
	aAdd( aPergs, {1, "Emissão Até" , dEmissAt, "", ".T.", ""   , ".T.", 40,  .F.} )

	aAdd( aSays, OemToAnsi(' Este programa tem como objetivo gerar arquivo em formato     ') )
	aAdd( aSays, OemToAnsi(' excel com dados de pré-notas fiscais de entrada.             ') )
	aAdd( aSays, OemToAnsi('                                                              ') )
	aAdd( aSays, OemToAnsi(' Selecione os parâmetros.                                     ') )

	aAdd( aButtons, { 5,.T.,{|o| ParamBox(aPergs, "Informe os parâmetros") } } )
	aAdd( aButtons, { 1,.T.,{|o| Processa( {|| CriaXls()}, "Aguarde", "Processando informações..."), FechaBatch() } } )
	aAdd( aButtons, { 2,.T.,{| | FechaBatch() } } )

	FormBatch( cCadastro, aSays, aButtons )

Return

// Função principal para geração dos dados
Static Function CriaXls()

	Local aCab   := {}
	Local aItem  := {}
	Local aItens := {}
	Local cQuery := ""
	Local cAlias := ""
	Local nCont  := 0
	Local nX     := 0

	// Montagem do cabeçalho
	aAdd( aCab, { "D1_EMISSAO","D", 10, 0 } )
	aAdd( aCab, { "D1_DOC"    ,"C", 09, 0 } )
	aAdd( aCab, { "D1_PEDIDO" ,"C", 06, 0 } )
	aAdd( aCab, { "D1_FORNECE","C", 06, 0 } )
	aAdd( aCab, { "NOMEFOR"   ,"C", 30, 0 } )
	aAdd( aCab, { "D1_ITEMPC" ,"C", 04, 0 } )
	aAdd( aCab, { "D1_COD"    ,"C", 30, 0 } )
	aAdd( aCab, { "DESCPRD"   ,"C", 40, 0 } )
	aAdd( aCab, { "C7_QUANT"  ,"N", 14, 3 } )
	aAdd( aCab, { "C7_UM"     ,"C", 02, 0 } )
	aAdd( aCab, { "C7_PRECO"  ,"N", 14, 3 } )
	aAdd( aCab, { "C7_TOTAL"  ,"N", 14, 3 } )
	aAdd( aCab, { "C7_ITEM"   ,"C", 04, 0 } )
	aAdd( aCab, { "C7_QUJE"   ,"N", 14, 3 } )
	aAdd( aCab, { "BRANCOS"   ,"C", 01, 0 } )

	cQuery := "SELECT D1_EMISSAO, D1_DOC, D1_PEDIDO, D1_FORNECE, C7_ITEM, "
	cQuery += "       (SELECT TOP 1 A2_NOME "
	cQuery += "        FROM   "+ RetSqlName("SA2") +" SA2 "
	cQuery += "        WHERE  D_E_L_E_T_ = ' ' "
	cQuery += "               AND A2_COD = D1_FORNECE "
	cQuery += "               AND A2_LOJA = D1_LOJA) NOMEFOR, "
	cQuery += "       D1_ITEMPC, D1_COD, "
	cQuery += "       (SELECT TOP 1 B1_DESC "
	cQuery += "        FROM   "+ RetSqlName("SB1") +" SB1 "
	cQuery += "        WHERE  D_E_L_E_T_ = ' ' "
	cQuery += "               AND B1_COD = D1_COD)   DESCPRD, "
	cQuery += "       C7_QUANT, C7_UM, C7_PRECO, C7_TOTAL, C7_ACCITEM, C7_QUJE "
	cQuery += "FROM   "+ RetSqlName("SD1") +" SD1 "
	cQuery += "       INNER JOIN "+ RetSqlName("SF1") +" SF1 "
	cQuery += "               ON D1_FILIAL = F1_FILIAL "
	cQuery += "                  AND D1_DOC = F1_DOC "
	cQuery += "                  AND D1_SERIE = F1_SERIE "
	cQuery += "                  AND D1_FORNECE = F1_FORNECE "
	cQuery += "                  AND D1_LOJA = F1_LOJA "
	cQuery += "       INNER JOIN "+ RetSqlName("SC7") +" SC7 "
	cQuery += "               ON C7_NUM = D1_PEDIDO "
	cQuery += "                  AND C7_ITEM = D1_ITEMPC "
	cQuery += "                  AND C7_FILIAL = '"+ xFilial("SC7") +"' "
	cQuery += "WHERE  SD1.D_E_L_E_T_ = ' ' "
	cQuery += "       AND SF1.D_E_L_E_T_ = ' ' "
	cQuery += "       AND F1_STATUS = ' ' "
	cQuery += "       AND D1_EMISSAO BETWEEN '"+ DtoS( MV_PAR01 ) +"' AND '"+ DtoS( MV_PAR02 ) +"' "

	cQuery:= ChangeQuery( cQuery )
	dbUseArea(.T., 'TOPCONNN', TcGenQry(,,cQuery), (cAlias:=GetNextAlias()), .F.,.T.)

	If !(cAlias)->( Eof() )

		Count To nCont
		(cAlias)->( dbGoTop() )

		ProcRegua( nCont )

		While (cAlias)->( !Eof() )

			aItem := Array( Len( aCab ) )

			For nX := 1 to Len( aCab )
				If aCab[ nX ][ 2 ] == "C" .And. aCab[ nX ][ 1 ] <> "BRANCOS"
					aItem[ nX ] := CHR(160) + (cAlias)->&( aCab[ nX ][ 1 ] )
				ElseIf aCab[ nX ][ 2 ] == "D"
					aItem[ nX ] := CHR(160) + DtoC( StoD( (cAlias)->&( aCab[ nX ][ 1 ] ) ) )
				Else
					If aCab[ nX ][ 1 ] <> "BRANCOS"
						aItem[ nX ] := (cAlias)->&( aCab[ nX ][ 1 ] )
					Else
						aItem[ nX ] := Space(1)
					EndIf
				EndIf
			Next nX

			aAdd( aItens, aItem )
			aItem := {}

			IncProc()
			(cAlias)->( dbSkip() )
		End

		MsgRun("Exportando para o Excel...", "Aguarde",{ || DlgToExcel( { { "GETDADOS", "Listagem das pré-notas de Entrada", aCab, aItens } } ) } )

	Else
		MsgAlert('Nenhum registro encontrado!')
	EndIf

	(cAlias)->( dbCloseArea() )
Return
