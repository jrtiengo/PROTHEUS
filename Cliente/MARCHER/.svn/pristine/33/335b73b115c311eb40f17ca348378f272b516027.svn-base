#Include "protheus.ch"
#Include "topconn.ch"
#Include "rwmake.ch"
#Include "tbiconn.ch"


/*/{Protheus.doc} xGPRODSC1()
//Gatilhl SC1 - disparado no produto
//atualiza fornecedor e loja - conceito fornecedor padrao
@author Celso Rene
@since 30/01/2019
@version 1.0
@type function
/*/
User Function xGPRODSC1()

	Local _aArea	:= GetArea()
	Local _nFornece := Ascan( aHeader, {|x| AllTrim(x[2]) == "C1_FORNECE" })
	Local _nLoja    := Ascan( aHeader, {|x| AllTrim(x[2]) == "C1_LOJA"    })
	Local _cCodFor  := aCols[n][_nFornece]
	Local _cProduto := M->C1_PRODUTO
	Local _cQuery	:= ""
	Local _cAlias   := ""

	If !Empty( _cProduto ) .And. Empty( _cCodFor )

		_cQuery := "SELECT TOP 1 AIB_CODFOR, AIB_LOJFOR "
		_cQuery += "FROM "+ RetSqlName("AIB") +" AIB, "+ RetSqlName("AIA") +" AIA "
		_cQuery += "WHERE AIA.D_E_L_E_T_ = ' ' "
		_cQuery += "  AND AIB.D_E_L_E_T_ = ' ' "
		_cQuery += "  AND AIA_FILIAL = AIB_FILIAL "
		_cQuery += "  AND AIA_CODFOR = AIB_CODFOR "
		_cQuery += "  AND AIA_CODTAB = AIB_CODTAB "
		_cQuery += "  AND AIB_FILIAL = '"+ xFilial("AIB") +"' "
		_cQuery += "  AND "+ DtoS( dDataBase ) +" > AIB_DATVIG "
		_cQuery += "  AND "+ DtoS( dDataBase ) +" BETWEEN AIA_DATDE AND AIA_DATATE "
		_cQuery += "  AND AIB_CODPRO = '"+ _cProduto +"' "
		_cQuery += "  ORDER BY AIB_PRCCOM ASC "

		TCQuery _cQuery New Alias ( _cAlias := GetNextAlias() )

		If !(_cAlias)->( Eof() )

			_cCodFor			:= (_cAlias)->AIB_CODFOR
			aCols[n][_nFornece] := (_cAlias)->AIB_CODFOR
			aCols[n][_nLoja] 	:= (_cAlias)->AIB_LOJFOR

			GetDRefresh()

		Else

			dbSelectArea("SB1")
			dbSetOrder(1)

			If ( dbSeek( xFilial("SB1") + _cProduto ) )

				_cCodFor			:= SB1->B1_PROC
				aCols[n][_nFornece] := SB1->B1_PROC
				aCols[n][_nLoja] 	:= SB1->B1_LOJPROC

			EndIf

			GetDRefresh()

		EndIf

		(_cAlias)->( dbCloseArea() )

	EndIf

	RestArea( _aArea )

Return( _cCodFor )
