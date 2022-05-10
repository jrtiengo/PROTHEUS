#Include 'TOTVS.CH'
#Include 'FWMVCDEF.CH'
#Include 'RESTFUL.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณINWS020   บAutor  ณMicrosiga           บ Data ณ  29/07/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
WSRESTFUL INWS020 DESCRIPTION "Servi็o REST para integra็ใo Cliente Operadoras "

	WSDATA page			AS INTEGER OPTIONAL
	WSDATA pageSize		AS INTEGER OPTIONAL
	WSDATA A1_COD		AS STRING
	WSDATA A1_LOJA		AS STRING
	WSDATA A1_OPER		AS STRING
	WSDATA A1_BAND		AS STRING
	WSDATA A1_PARC		AS STRING

	//WSMETHOD GET	DESCRIPTION "Visualiza็ใo Cat x Nat x CC."	WSSYNTAX "/INWS020?E1_NUM=000000001-000000002&E1_CLIENTE=000001-000002&E1_EMISSAO=20180101-20180201&E1_VENCTO=20180101-20180201"
	WSMETHOD GET	DESCRIPTION "Visualiza็ใo Cliente Operadora."	WSSYNTAX "/"
	
END WSRESTFUL
                       
/*
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
|| WSMETHOD  | POST      | Autor |                      | Data |29/07/2017 ||
||-------------------------------------------------------------------------||
|| Descricao | Metodo POST para inclusao do Cat x Nat x CC.              ||
||           |                                                             ||
||-------------------------------------------------------------------------||
|| Parametros|                                                             ||
||-------------------------------------------------------------------------||
|| Retorno   |                                                             ||
-----------------------------------------------------------------------------
-----------------------------------------------------------------------------*/
WSMETHOD GET WSRECEIVE A1_COD WSSERVICE INWS020

	Local aArea		:= GetArea()
	Local lOk		:= .T.
	Local cCat		:= ""
	Local cNat		:= ""
	Local cCC		:= ""
	Local cQuery    := ""
	Local cAliasSA1 := ""
	Local cJsonCli	:= ""
	Local cWhere 	:= ""	
	
	Local aListSA1	:= {} 
	Local aCampo	:= {}
	Local aCat		:= {}
	Local aNat		:= {}
	Local aCC		:= {}
	 
	Local nCount	:= 0
	Local nStart	:= 1
	Local nReg		:= 0
	Local nAux 		:= 0
	Local nZ		:= 0
	 
	Local oJsonSA1	:= Nil 
	 
	Default self:page 		:= 1
	Default self:pageSize	:= 10  

	//Default Self:A1_CAT	:= ""
	//Default Self:Z04_NAT	:= ""
	//Default Self:Z04_CC		:= ""
	
	//cCat := Self:Z04_CAT
	//cNat := Self:Z04_NAT
	//cCC	 := Self:Z04_CC
	
	RpcClearEnv()
	RpcSetType(3)
	RpcSetEnv("01","0101",,,,GetEnvServer(),{ "SA1" } )	
	SetModulo( "SIGAFAT" , "FAT" ) 
	
	oJsonSA1 := JsonObject():New() 	
	
	aAdd( aCampo,{"A1_COD"})
	aAdd( aCampo,{"A1_LOJA"}) 
	aAdd( aCampo,{"A1_OPER"})
	aAdd( aCampo,{"A1_BAND"})
	aAdd( aCampo,{"A1_PARC"})
 
	//-------------------------------------------------------------------
	// Tratativas para a chave de busca
	//-------------------------------------------------------------------
	cWhere := " AND A1_FILIAL = '"+xFilial('SA1')+"'"
	cWhere := " AND SUBSTRING(A1_COD,1,3) = 'OPE'"

	/*
	If !Empty(cCat)

		aCat := StrTokArr(cCat,"-")
		cWhere += " AND Z04_CAT BETWEEN '" + aCat[1] + "' AND '" + aCat[2] + "'"
	EndIf
	If !Empty(cNat)

		aNat := StrTokArr(cNat,"-")
		cWhere += " AND Z04_NAT BETWEEN '" + aNat[1] + "' AND '" + aNat[2] + "'"
	EndIf
	If !Empty(cCC)

		aCC := StrTokArr(cCC,"-")
		cWhere += " AND Z04_CC  BETWEEN '" + aCC[1] + "' AND '" + aCC[2] + "'"
	EndIf
    */
    
    
	//-------------------------------------------------------------------
	// Query para selecionar registros
	//-------------------------------------------------------------------
	cQuery := " SELECT "
	aEval( aCampo, { |Z| nZ++, cQuery += Z[1]+ IIf( nZ < Len(aCampo), ', ', '') } )
	cQuery += "	FROM " + RetSQLName("SA1")
	cQuery += " WHERE D_E_L_E_T_ <> '*'"
	cQuery += cWhere                    
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery), (cAliasSA1 := GetNextAlias()), .F., .T. )

	If ( cAliasSA1 )->( ! Eof() )
	 
		//-------------------------------------------------------------------
		// Identifica a quantidade de registro no alias temporแrio
		//-------------------------------------------------------------------
		Count To nRecord
		 
		//-------------------------------------------------------------------
		// nStart -> primeiro registro da pagina
		// nReg -> numero de registros do inicio da pagina ao fim do arquivo
		//-------------------------------------------------------------------
		If self:page > 1
		 	nStart := ( ( self:page - 1 ) * self:pageSize ) + 1
			nReg := nRecord - nStart + 1
		Else
			nReg := nRecord
		EndIf
 
		//-------------------------------------------------------------------
		// Posiciona no primeiro registro.
		//-------------------------------------------------------------------
		( cAliasSA1 )->( dbGoTop() )
 
		//-------------------------------------------------------------------
		// Valida a exitencia de mais paginas
		//-------------------------------------------------------------------
		If nReg > self:pageSize
		 	oJsonSA1['hasNext'] := .T.
		Else
			oJsonSA1['hasNext'] := .F.
		EndIf
		 
	Else
	
		//-------------------------------------------------------------------
		// Nao encontrou registros
		//-------------------------------------------------------------------
		oJsonSA1['hasNext'] := .F.
	
	EndIf
 
	//-------------------------------------------------------------------
	// Alimenta array de titulos
	//-------------------------------------------------------------------
	While ( cAliasSA1 )->( !Eof() ) 
 
		nCount++
 
		If nCount >= nStart
	 
			nAux++ 
			aAdd( aListSA1, JsonObject():New() )			

			For nZ := 1 To Len(aCampo)
				aListSA1[nAux][aCampo[nZ,1]] := Alltrim(( cAliasSA1 )->&(aCampo[nZ,1]))
			Next nZ
	 
			If Len(aListSA1) >= self:pageSize
				Exit
			EndIf
	 
		EndIf
 
		(cAliasSA1)->(dbSkip())
 
	EndDo
 
	( cAliasSA1 )->( dbCloseArea() )
 
	oJsonSA1['ClienteOperador'] := aListSA1
 
	//-------------------------------------------------------------------
	// Serializa objeto Json
	//-------------------------------------------------------------------
	cJsonSA1:= FwJsonSerialize( oJsonSA1 )
 
	//-------------------------------------------------------------------
	// Elimina objeto da memoria
	//-------------------------------------------------------------------
	FreeObj(oJsonSA1)
 
	//-- Seta resposta
	Self:SetResponse( cJsonSA1 )		

	RestArea(aArea)
	
RETURN(lOk)