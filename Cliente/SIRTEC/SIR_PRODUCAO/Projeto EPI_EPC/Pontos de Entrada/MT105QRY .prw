#Include "protheus.ch"
#Include "topconn.ch"

/*/{Protheus.doc} MT105QRY 
Ponto de entrada: Filtro de dados da Mbrowse para ambiente Top. 
@author Celso Rene
@since 28/01/2019
@version 1.0
@type function
/*/
User Function MT105QRY()

	Local nContar   := 0
	Local cSql      := ""
	Local _cQuery   := ""
	Local _Unidades := ""

	Private aLista  := {}
	Private oOk     := LoadBitmap( GetResources(), "LBOK" )
	Private oNo     := LoadBitmap( GetResources(), "LBNO" )
	Private oLista

	Private oDlg

	If ( FunName() == "U_XMATA105" )

		If Select("T_UNIDADES") > 0
			T_UNIDADES->( dbCloseArea() )
		EndIf

		cSql := ""
		cSql := "SELECT X5_TABELA,"
		cSql += "       X5_CHAVE ,"
		cSql += "       X5_DESCRI "
		cSql += "  FROM " + RetSqlName("SX5")
		cSql += " WHERE X5_TABELA = 'ZD'"
		cSql += "   AND D_E_L_E_T_ = '' "
		cSql += " ORDER BY X5_DESCRI    "

		cSql := ChangeQuery( cSql )
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_UNIDADES", .T., .T. )

		If T_UNIDADES->( EOF() )
			MsgAlert("Atenção!"                    + chr(13) + chr(10) + chr(13) + chr(10) + ;
				"Nenhuma unidade cadastrada." + chr(13) + chr(10) + chr(13) + chr(10) + ;
				"Verifique cadastro de unidades.")
			_cQuery := ""
			pergunte("MTA105",.F.)
			Return(_cQuery)
		Endif

		aLista := {}

		T_UNIDADES->( DbGoTop() )

		WHILE !T_UNIDADES->( EOF() )
			aAdd( aLista, { .F.,;
				T_UNIDADES->X5_CHAVE ,;
				T_UNIDADES->X5_DESCRI})
			T_UNIDADES->( DbSkip() )
		ENDDO

		If Len(aLista) == 0
			aAdd( aLista, { .F., "", "" } )
		Endif

		DEFINE MSDIALOG oDlg TITLE "Seleção de Unidades" FROM C(178),C(181) TO C(616),C(614) PIXEL

		@ C(201),C(005) Button "Marca Todas"    Size C(050),C(012) PIXEL OF oDlg ACTION(MRCUNIDADE(0))
		@ C(201),C(056) Button "Desmarca Todas" Size C(050),C(012) PIXEL OF oDlg ACTION(MRCUNIDADE(1))
		@ C(201),C(175) Button "OK"             Size C(037),C(012) PIXEL OF oDlg ACTION( ODLG:END() )

		@ 005,005 LISTBOX oLista FIELDS HEADER "Mrc", "Unidade", "Descrição Unidade" PIXEL SIZE 270,250 OF oDlg ON dblClick(aLista[oLista:nAt,1] := !aLista[oLista:nAt,1],oLista:Refresh())

		oLista:SetArray( aLista )

		oLista:bLine := {||{ Iif(aLista[oLista:nAt,01],oOk,oNo),;
			aLista[oLista:nAt,02]             ,;
			aLista[oLista:nAt,03]}}

		ACTIVATE MSDIALOG oDlg CENTERED

	EndIf

	// Carrega a variável _cQuery com as unidades selecionadas
	_cQuery   += "     CP_XROT = 'XMATA105' "
	_cQuery   += " AND CP_XUNID <> ''"

	_Unidades := ""

	For nContar = 1 to Len(aLista)
		If aLista[nContar,01] == .T.
			_Unidades += "'" + Alltrim(aLista[nContar,02]) + "',"
		Endif
	Next nContar

	If !Empty(Alltrim(_Unidades))
		_Unidades := Substr(_Unidades,01, Len(Alltrim(_Unidades)) - 1)
		_cQuery += " AND CP_XUNID IN (" + Alltrim(_Unidades) + ")"
	Else
		_cQuery += " AND CP_XUNID IN ('999999')"
	Endif

	pergunte("MTA105",.F.)

Return(_cQuery)


/*/{Protheus.doc} MRCUNIDADE
Função que marca ou desmarca unidades do grid conforme botão selecionado
@author Celso Rene
@since 28/01/2019
@version 1.0
@type function
@param kTipo, numerical, Opção selecionada pelo usuário na tela
/*/
Static Function MRCUNIDADE(kTipo)

	Local nContar := 0
	Local lMarca  := IIF(kTipo == 0, .T., .F.)

	For nContar := 1 To Len(aLista)
		aLista[nContar,01] := lMarca
	Next nContar

Return(.T.)
