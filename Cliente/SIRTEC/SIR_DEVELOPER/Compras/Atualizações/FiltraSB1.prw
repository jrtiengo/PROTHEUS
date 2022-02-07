#INCLUDE 'PROTHEUS.ch'

#DEFINE POS_CODPRO	1
#DEFINE POS_CODDES	2
#DEFINE POS_CODTIPO	3

Static _cProd := ""

/*/{Protheus.doc} FiltraSB1
Montar uma tela de Cadastro de Produtos para que seja possível fazer um Filtro com mais rapidez.
Consulta Padrão ESPECIFICA chamada FILSB1.
@author Jorge Alberto - Solutio
@since 14/08/2019
@version 1.0
@return Sempre VERDADEIRO mesmo que não tenha selecionado um Produto.
@type user function
/*/
User Function FiltraSB1()

	Local oDlg, oSayFiltro, oGetFiltro, oBtnOk, oBtnCancel, oLisProd
	Local cAliAtu := Alias()
	Local cGetFiltro := Space(50)
	Local nTamB1Cod := TamSX3("B1_COD")[1]	
	Local aProd := {}
	Local aProdOrig := {}
	Local cAliB1 := GetNextAlias()
	Local cQuery := ""
	Local cCodUsr := UsrRetName( RetCodUsr() )
	
	cQuery := "SELECT B1_COD, B1_DESC, B1_TIPO "
	cQuery += "  FROM " + RetSqlName("SB1") + " "
	cQuery += " WHERE D_E_L_E_T_ = ' ' "
	cQuery += "   AND B1_MSBLQL <> '1' "
	// Se o usuário logado for um Fornecedor então irá filtrar os produtos.
	If cCodUsr == U_CamposPC( "CGC" )
		cQuery += "   AND SUBSTRING(B1_COD,1,1) = 'F' "
	EndIf
	cQuery += " ORDER BY B1_COD "

	cQuery := ChangeQuery(cQuery)
	DbUseArea(.T.,"TOPCONECT",TcGenQry(,,cQuery),cAliB1,.F.,.F.)
	While (cAliB1)->( !EOF() )

		AADD( aProd, { (cAliB1)->B1_COD, (cAliB1)->B1_DESC, (cAliB1)->B1_TIPO } )
		(cAliB1)->( DbSkip() )
	EndDo
	(cAliB1)->( DbCloseArea() )
	
	aProdOrig := aClone( aProd )

	// Monta a tela para que o usuário possa selecionar um Produto
	oDlg := MSDialog():New( 095,169,603,1165,"Filtrar Produtos",,,.F.,,,,,,.T.,,,.T. )

	oSayFiltro := TSay():New( 008,008,{||"Filtro"},oDlg,,,.F.,.F.,.F.,.T.,CLR_BLACK,CLR_WHITE,020,008)
	oGetFiltro := TGet():New( 006,037,{|u| If(PCount()>0,cGetFiltro:=u,cGetFiltro)},oDlg,075,008,'',{|| Filtra( cGetFiltro, @aProd, aProdOrig, oLisProd ) },CLR_BLACK,CLR_WHITE,,,,.T.,"",,,.F.,.F.,,.F.,.F.,"","cGetFiltro",,)

	@028,008 ListBox oLisProd Fields HEADERS 'Código','Descrição','Tipo' Size 476,188 Pixel Of oDlg ;
	On dblClick( _cProd := PadR(aProd[ oLisProd:nAt, POS_CODPRO ],nTamB1Cod,""), oDlg:End() )

	oBtnOk     := TButton():New( 224,020,"Confirmar",oDlg,{|| _cProd := PadR(aProd[ oLisProd:nAt, POS_CODPRO ],nTamB1Cod,""), oDlg:End() },037,012,,,,.T.,,"",,,,.F. )
	oBtnCancel := TButton():New( 224,092,"Cancelar",oDlg,{|| _cProd := Space(nTamB1Cod), oDlg:End() },037,012,,,,.T.,,"",,,,.F. )

	// Antes de abrir a tela, carrega os registros
	Filtra( "", @aProd, aProdOrig, oLisProd )
	oDlg:Activate(,,,.T.)
	
	If !Empty( cAliAtu )
		DbSelectArea( cAliAtu )
	EndIf

Return( .T. )


/*/{Protheus.doc} Filtra
Filtra os Produtos conforme o que o usuário informar no campo do Filtro.
@author Jorge Alberto - Solutio
@since 14/08/2019
@version 1.0
@return NIL
@param cGetFiltro, characters, Campo onde o usuário poderá informar algo para filtrar
@param aProd, array, Produtos apresentados para o usuário
@param aProdOrig, array, Produtos originais
@param oLisProd, object, Lista com os produtos
@type static function
/*/
Static Function Filtra( cGetFiltro, aProd, aProdOrig, oLisProd )

	Local nProd := 0
	Local aNewProd := {}

	aProd := {}
	If !Empty( cGetFiltro )

		For nProd := 1 To Len( aProdOrig )

			// Filtra o que o usuário digitou na tela com o que está no array aInsOrig que é o conteudo original
			If ( Upper( AllTrim( cGetFiltro ) ) $ Upper( AllTrim( aProdOrig[ nProd, POS_CODPRO ] ) ) .Or.;
				 Upper( AllTrim( cGetFiltro ) ) $ Upper( AllTrim( aProdOrig[ nProd, POS_CODDES ] ) );
			   )

			   	AADD( aNewProd, { aProdOrig[ nProd, POS_CODPRO ], aProdOrig[ nProd, POS_CODDES ], aProdOrig[ nProd, POS_CODTIPO ] } )

			EndIf
		Next

		aProd := aClone( aNewProd )

	Else
		aProd := aClone( aProdOrig )
	EndIf
	
	If Empty( aProd )
		AADD( aProd, Array( 3 ) )
	EndIf

	oLisProd:SetArray( aProd )
	If Len( aProd ) > 0
		oLisProd:bLine:={||{ aProd[ oLisProd:nAt, POS_CODPRO  ],;
							 aProd[ oLisProd:nAt, POS_CODDES  ],;
							 aProd[ oLisProd:nAt, POS_CODTIPO  ];
						   } }
	EndIf
	oLisProd:nAt := 1
	oLisProd:Refresh()

Return

/*/{Protheus.doc} RetSB1Pr
Essa função é utilizada no Retorno da Consulta Padrão ESPECIFICA chamada FILSB1.
@author Jorge Alberto - Solutio
@since 14/08/2019
@version 1.0
@return _cProd, Codigo do produto selecionado
@type user function
/*/
User Function RetSB1Pr()
	If !Empty( _cProd )
		DbSelectArea("SB1")
		DbSetOrder(1)
		Dbseek(xFilial("SB1")+_cProd)
	EndIf
Return(_cProd)

