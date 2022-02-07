#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} CamposPC
Função genérica para retornar uma informação do cadastro do Fornecedor.
@author Jorge Alberto - Solutio
@since 14/08/2019
@version 1.0
@param cTpRet, texto com o Tipo de retorno
@return cRet, texto com o conteúdo do campo solicitado no parâmetro de entrada
@example IIF(findfunction("U_CAMPOSPC"),U_CAMPOSPC("CODIGO"),"")
@type user function
/*/
User Function CamposPC( cTpRet )

	Local aArea := GetArea()
	Local aAreaSA2 := SA2->( GetArea() )
	Local cRet := ""
	Local cAliAtu := Alias()
	Local cCodUsr := UsrRetName( RetCodUsr() )
	
	Default cTpRet := "CODIGO"

	 // Só valida se o usuário é um Fornecedor ( acesso via CNPJ digitado no login )	
	If ( Len( cCodUsr ) == 14 .And. At( ".", cCodUsr ) <= 0 )
		DbSelectArea("SA2")
		DbSetOrder(3) // A2_FILIAL + A2_CGC
		If SA2->( DbSeek( xFilial("SA2") + cCodUsr ) )
			If cTpRet == "CONDPAGTO"
				cRet := SA2->A2_COND
			ElseIf cTpRet == "LOJA"
				cRet := SA2->A2_LOJA
			ElseIf cTpRet == "CODIGO"
				cRet := SA2->A2_COD
			ElseIf cTpRet == "CGC"
				cRet := SA2->A2_CGC
			EndIf
			// Preenche as informações na Aba "Inf. Fornecedor" da tela de PC.
			If Type( "aInfForn" ) == "A"
				aInfForn[1]	:= SA2->A2_NOME						// Nome
				aInfForn[2] := IIF(!Empty(SA2->A2_DDI),"( "+TransForm(SA2->A2_DDI,PesqPict("SA2","A2_DDI"))+") ","");
								+TransForm(alltrim(SA2->A2_DDD),PesqPict("SA2","A2_DDD"))+" "+TransForm(SA2->A2_TEL,PesqPict("SA2","A2_TEL")) // Telefone
				aInfForn[3]	:= SA2->A2_PRICOM	    			//Primeira Compra
				aInfForn[4] := SA2->A2_ULTCOM      				//Ultima Compra
				aInfForn[5]	:= SA2->A2_END+" - "+SA2->A2_MUN	//Endereco
				aInfForn[6]	:= SA2->A2_EST         				//Estado
				aInfForn[7]	:= SA2->A2_CGC         				//cnpj
			EndIf
		EndIf
	EndIf
	
	If !Empty( cAliAtu )
		DbSelectArea( cAliAtu )
	EndIf
	RestArea( aAreaSA2 )
	RestArea( aArea )

Return( cRet )


/*/{Protheus.doc} FornFrot
Função chamada no inicializador padrão do campo C7_FROTA, para indicar quando o PC for incluído pelo Fornecedor.
Sendo que o Fornecedor loga no Protheus com o próprio CNPJ
@author Jorge Alberto - Solutio
@since 14/08/2019
@version 1.0
@type user function
/*/
User Function FornFrot()
	
	Local cRet := "N"
	Local cUserLogado := AllTrim( UsrRetName( RetCodUsr() ) )
	// ATENÇÃO: Parametro é utilizado em outra função nesse mesmo fonte.
	Local cUserPermissao := AllTrim( Lower( SuperGetMV("ES_USRFROT",,"leandro.donato/roger.streck/alexandre.quevedo/andre.lazzeri/alison.cruz/rafael.dellaglio/solutio") ) )
	
	If ( cUserLogado == U_CamposPC( "CGC" ) .Or. cUserLogado $ cUserPermissao )
		cRet := "S"
	EndIf
	
Return( cRet )


/*/{Protheus.doc} InicVeic
Função chamada no inicializador padrão dos campos: C7_VEICULO, C7_ITEMCTA, C7_CC, C7_HORIMET, C7_ODOMETR e C7_TPMANUE.
Função utilizada para que seja preenchido automaticamente os campos a partir da 2a linha do grid do Pedido de Compra.
@author Jorge Alberto - Solutio
@since 14/08/2019
@version 1.0
@param cCampo, texto com o campo de origem
@return cRet, texto a ser retornado para o campo de origem
@example 
IIF(FindFunction("U_InicVeic"), U_InicVeic("C7_VEICULO"), "" )
IIF(FindFunction("U_InicVeic"), U_InicVeic("C7_ITEMCTA"), "" )
IIF(FindFunction("U_InicVeic"), U_InicVeic("C7_CC"), "" )
IIF(FindFunction("U_InicVeic"), U_InicVeic("C7_HORIMET"), "" )
IIF(FindFunction("U_InicVeic"), U_InicVeic("C7_ODOMETR"), "" )
IIF(FindFunction("U_InicVeic"), U_InicVeic("C7_TPMANUE"), "" )
IIF(FindFunction("U_InicVeic"), U_InicVeic("C7_OSFROTA"), "" )
@type user function
/*/
User Function InicVeic( cCampo )

	Local cRet := " "
	Local nPos := 0
	Local nQtdLinha := Len( aCols )
	
	If nQtdLinha > 1
		nPos := aScan( aHeader, {|x| AllTrim(Upper(x[2])) == cCampo })
		If nPos > 0
			// Para o campo "OS Frota", deverá copiar o conteúdo quando o usuário logado for Fornecedor.
			If AllTrim( Upper( cCampo ) ) == "C7_OSFROTA"
				If UsrRetName( RetCodUsr() ) == U_CamposPC( "CGC" )
					cRet := aCols[ nQtdLinha-1, nPos ]
				EndIf
			Else
				cRet := aCols[ nQtdLinha-1, nPos ]
			EndIf
		EndIf
	EndIf
	
Return( cRet )


/*/{Protheus.doc} VeicItCta
Função chamada no Gatilho 002 do campo C7_VEICULO
@author Jorge Alberto - Solutio
@since 14/08/2019
@param cPlaca, texto com a Placa do Bem ( T9_PLACA )
@return cItemCta, texto com o Item da Conta Contábil
@version 1.0
@type user function
/*/
User Function VeicItCta( cPlaca )

	Local cItemCta := ""
	If !Empty( cPlaca )
		cItemCta := AllTrim( Posicione("CTD",4,xFilial("CTD")+AllTrim(cPlaca), "CTD_ITEM") )
	EndIf

Return( cItemCta )


/*/{Protheus.doc} PedFrota
Função usada nos Filtros relacionada a tabela SCR ( via configurador ).
U_PedFrota(SCR->CR_NUM)
@author Jorge Alberto - Solutio
@since 14/08/2019
@param cPedido, texto com o número do Pedido de Compra
@return cRet, texto conforme o campo Frota do Pedido
@version 1.0
@type user function
/*/
User Function PedFrota( cPedido )
	Local cRet := Posicione( "SC7", 1, xFilial("SC7") + AllTrim(cPedido), "C7_FROTA" )
Return( cRet )


/*/{Protheus.doc} EdtItCta
Função usada nos campos 'Item Conta', 'Centro Custo' e 'Veiculo/Bem', para que possa ou não ser Editado.
@author Jorge Alberto - Solutio
@since 21/08/2019
@return lEdita, permite ou não a edição do campo.
@version 1.0
@type user function
/*/
User Function EdtItCta()

	Local lEdita := .F.
	
	If Len( aCols ) == 1
		lEdita := .T. // Habilita edição para todos os usuários.
	ElseIf Len( aCols ) > 1
		// Habilita a edição se o usuário não for um Fornecedor
		lEdita := UsrRetName( RetCodUsr() ) <> U_CamposPC( "CGC" )
	EndIf
	
Return( lEdita  )


/*/{Protheus.doc} EdtFrota
Função chamada na validação de "Perm Edição" do campo C7_FROTA, para validar se o campo poderá ou não ser editado.
IIF(FINDFUNCTION("U_EDTFROTA"),U_EDTFROTA(),.F.)
@author Jorge Alberto - Solutio
@since 02/09/2019
@version 1.0
@return lRet, Permite ou não a edição do campo
@type function
/*/
User Function EdtFrota()

	Local lRet := .F.
	// ATENÇÃO: Parametro é utilizado em outra função nesse mesmo fonte.
	Local cUserPermissao := AllTrim( Lower( SuperGetMV("ES_USRFROT",,"leandro.donato/roger.streck/alexandre.quevedo/andre.lazzeri/alison.cruz/rafael.dellaglio/solutio") ) )
		
	lRet := AllTrim( UsrRetName( RetCodUsr() ) ) $ cUserPermissao

Return( lRet )
