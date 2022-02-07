#Include "TOTVS.CH"
#Include "RESTFUL.CH"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³TEDA040     ³ Autor ³ Manoel Mariante       ³ Data ³ nov/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Servico Web service para listar os titulos em aberto       ³±±
±±³          ³                                                            ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSRESTFUL TEDA040 DESCRIPTION "Titulos em Aberto"

	WSDATA E1_LOJA AS STRING
	WSDATA E1_CLIENTE AS STRING
	WSDATA A1_CNPJ AS STRING


	WSMETHOD GET DESCRIPTION "Listar Titulos a Receber em Aberto" WSSYNTAX "/"
	//WSMETHOD POST DESCRIPTION "Incluir Pedido de Venda." WSSYNTAX "/"
	//WSMETHOD PUT DESCRIPTION "Alterar Pedido de Venda." WSSYNTAX "/"
	//WSMETHOD DELETE DESCRIPTION "Excluir Pedido de Venda." WSSYNTAX "/"

END WSRESTFUL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ GET      ºAutor  ³ Jeferson Dambros   º Data ³  Ago/2017   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Metodo para listar Pedido de venda.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ MAZWS030                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSMETHOD GET WSRECEIVE NULLPARAM WSSERVICE TEDA040

	Local lOk 		:= .T.
	Local cQuery	:= ""
	Local cArea		:= ""
	Local aCab		:= {}
	Local nX		:= 0
	Local nY		:= 0
	Local nStart	:= Seconds()

	// Define o tipo de retorno do metodo
	::SetContentType("application/json")

	u_LogConsole("TEDA040", "Entrei TEDA040 ")

	aAdd(aCab, {"E1_PREFIXO", "E1_PREFIXO"})
	aAdd(aCab, {"E1_NUM"    , "E1_NUM"})
	aAdd(aCab, {"E1_PARCELA", "E1_PARCELA"})
	aAdd(aCab, {"E1_TIPO"   , "TIP"})
	aAdd(aCab, {"E1_CLIENTE", "CLI"})
	aAdd(aCab, {"E1_LOJA"	, "LOJ"})
	aAdd(aCab, {"E1_VENCREA", "VCTO"})
	aAdd(aCab, {"E1_EMISSAO", "EMIS"})
	aAdd(aCab, {"E1_VALOR"	, "VLR"})
	aAdd(aCab, {"E1_SALDO"	, "SLD"})


	cQuery := " SELECT "
	aEval( aCab, { |Z| cQuery += "SE1." + Z[1] +" "+ Z[2] + ', ' } )
	cQuery += "	SE1.R_E_C_N_O_ REGSE1 ""
	cQuery += "	FROM " + RetSQLName("SE1") + " SE1, "+ RetSQLName("SA1") + " SA1"
	cQuery += " WHERE SE1.E1_FILIAL = '" + xFilial("SE1") + "'"
	cQuery += "  AND SE1.D_E_L_E_T_ <> '*'"
	cQuery += "  AND A1_FILIAL='"+XFILIAL('SA1')+"'"
	cQuery += "  AND E1_CLIENTE=A1_COD"
	cQuery += "  AND E1_LOJA=A1_LOJA"
	cQuery += "  AND SA1.D_E_L_E_T_ <> '*'"
	cQuery += "  AND E1_SALDO > 0 "

	If !Empty( ::E1_CLIENTE )
		cQuery += " AND SE1.E1_CLIENTE = '"+ Upper( ::E1_CLIENTE ) +"'"
	EndIf
	If !Empty( ::E1_LOJA )
		cQuery += " AND SE1.E1_LOJA = '"+ Upper( ::E1_LOJA ) +"'"
	EndIf
	If !Empty( ::A1_CNPJ )
		cQuery += " AND SA1.A1_CGC = '"+ Upper( ::A1_CNPJ ) +"'"
	EndIf

	//cQuery := ChangeQuery( cQuery )

	u_LogConsole("TEDA040",cQuery )

	MPSysOpenQuery( cQuery, (cArea := GetNextAlias()) )

	u_LogConsole("TEDA040", "Query Finalizada em (segundos):  " + STR((Seconds() - nStart )) + ". Montando dados para retorno.")


	If (cArea)->( Eof() )

		lOk := .F.
		SetRestFault( 100, "Nenhum Titulo Enontrado" )
		u_LogConsole("TEDA040", "Nao encontrei titulos")

	ELse

		dbSelectArea(cArea)
		dbGoTop()


		::SetResponse('{"TITULOS":[')

		While (cArea)->( !Eof() )

			If nY >= 1
				::SetResponse(',')
			EndIf

			nY++

			::SetResponse('{')

			For nX := 1 To Len(aCab)

				::SetResponse('"')
				::SetResponse(aCab[nX][1])
				::SetResponse('"')
				::SetResponse(':')
				::SetResponse('"')
				::SetResponse( AllTrim( cValToChar( (cArea)->&(aCab[nX][2]) ) ) )
				::SetResponse('"')
				If nX<Len(aCab)
					::SetResponse(',')
				End

			Next

			::SetResponse('}')

			dbskip()

		EndDo

		::SetResponse(']}')


		/*aret:={}
		While (cArea)->( !Eof() )
			For nX := 1 To Len(aCab)
			
				Aadd(aRet,aCab[nX][1],(cArea)->&(aCab[nX][2])})
			next
			//aadd(aRet, {ALLTRIM(TMPBAN->A6_COD),ALLTRIM(TMPBAN->A6_NOME), ALLTRIM(TMPBAN->A6_AGENCIA), ALLTRIM(TMPBAN->A6_NUMCON), ALLTRIM(TMPBAN->A6_DVCTA)})
			dbskip()
		EndDo
	//EndIf
	//TMPBAN->(DbClosearea())

	cJson := FWJsonSerialize(aRet, .F., .T.)

	conout('FINAL')

	::SetResponse(cJson)
		*/

		(cArea)->( dbCloseArea() )

	EndIf

	u_LogConsole("TEDA040", "Fim consulta SE1 protheus. Tempo execução (segundos):  " + STR((Seconds() - nStart )))

Return( lOk )
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³u_LogConsole  ³ Autor ³ Manoel Mariante       ³ Data ³ nov/19 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Funcao para gravar log no console.log                      ³±±
±±³          ³                                                            ³±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function LogConsole(cFuncao,cTexto)

	Conout( Funname()+"|"+Padr(cFuncao,15)+"|"+Dtoc(msdate())+"|"+ Time()+"|"+cTexto )

Return
