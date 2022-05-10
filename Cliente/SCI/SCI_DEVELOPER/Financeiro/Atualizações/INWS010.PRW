#Include 'TOTVS.CH'
#Include 'FWMVCDEF.CH'
#Include 'RESTFUL.CH'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑบPrograma  ณINWS010   บAutor  ณMicrosiga           บ Data ณ  29/07/2019 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                         บฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
WSRESTFUL INWS010 DESCRIPTION "Servi็o REST para integra็ใo Cat x Nat x CC"

	WSDATA page			AS INTEGER OPTIONAL
	WSDATA pageSize		AS INTEGER OPTIONAL
	WSDATA Z04_CAT		AS STRING
	WSDATA Z04_NAT		AS STRING
	WSDATA Z04_CC		AS STRING

	//WSMETHOD GET	DESCRIPTION "Visualiza็ใo Cat x Nat x CC."	WSSYNTAX "/INWS010?E1_NUM=000000001-000000002&E1_CLIENTE=000001-000002&E1_EMISSAO=20180101-20180201&E1_VENCTO=20180101-20180201"
	WSMETHOD GET	DESCRIPTION "Visualiza็ใo Cat x Nat x CC."	WSSYNTAX "/"
	
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
WSMETHOD GET WSRECEIVE Z04_CAT, Z04_NAT, Z04_CC WSSERVICE INWS010

	Local aArea		:= GetArea()
	Local lOk		:= .T.
	Local cCat		:= ""
	Local cNat		:= ""
	Local cCC		:= ""
	Local cQuery    := ""
	Local cAliasZ04 := ""
	Local cJsonCli	:= ""
	Local cWhere 	:= ""	
	
	Local aListZ04	:= {} 
	Local aCampo	:= {}
	Local aCat		:= {}
	Local aNat		:= {}
	Local aCC		:= {}
	 
	Local nCount	:= 0
	Local nStart	:= 1
	Local nReg		:= 0
	Local nAux 		:= 0
	Local nZ		:= 0
	 
	Local oJsonZ04	:= Nil 
	 
	Default self:page 		:= 1
	Default self:pageSize	:= 10  
	Default Self:Z04_CAT	:= ""
	Default Self:Z04_NAT	:= ""
	Default Self:Z04_CC		:= ""
	
	cCat := Self:Z04_CAT
	cNat := Self:Z04_NAT
	cCC	 := Self:Z04_CC
	
	RpcClearEnv()
	RpcSetType(3)
	RpcSetEnv("01","0101",,,,GetEnvServer(),{ "Z04" } )	
	SetModulo( "SIGAFIN" , "FIN" ) 
	
	oJsonZ04 := JsonObject():New() 	
	
	aAdd( aCampo,{"Z04_CAT"})
	aAdd( aCampo,{"Z04_NAT"}) 
	aAdd( aCampo,{"Z04_CC"})
 
	//-------------------------------------------------------------------
	// Tratativas para a chave de busca
	//-------------------------------------------------------------------
	cWhere := " AND Z04_FILIAL = '"+xFilial('Z04')+"'"

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
 
	//-------------------------------------------------------------------
	// Query para selecionar registros
	//-------------------------------------------------------------------
	cQuery := " SELECT "
	aEval( aCampo, { |Z| nZ++, cQuery += Z[1]+ IIf( nZ < Len(aCampo), ', ', '') } )
	cQuery += "	FROM " + RetSQLName("Z04")
	cQuery += " WHERE D_E_L_E_T_ <> '*'"
	cQuery += cWhere                    
	dbUseArea( .T., "TOPCONN", TcGenQry( ,,cQuery), (cAliasZ04 := GetNextAlias()), .F., .T. )

	If ( cAliasZ04 )->( ! Eof() )
	 
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
		( cAliasZ04 )->( dbGoTop() )
 
		//-------------------------------------------------------------------
		// Valida a exitencia de mais paginas
		//-------------------------------------------------------------------
		If nReg > self:pageSize
		 	oJsonZ04['hasNext'] := .T.
		Else
			oJsonZ04['hasNext'] := .F.
		EndIf
		 
	Else
	
		//-------------------------------------------------------------------
		// Nao encontrou registros
		//-------------------------------------------------------------------
		oJsonZ04['hasNext'] := .F.
	
	EndIf
 
	//-------------------------------------------------------------------
	// Alimenta array de titulos
	//-------------------------------------------------------------------
	While ( cAliasZ04 )->( !Eof() ) 
 
		nCount++
 
		If nCount >= nStart
	 
			nAux++ 
			aAdd( aListZ04, JsonObject():New() )			

			For nZ := 1 To Len(aCampo)
				aListZ04[nAux][aCampo[nZ,1]] := Alltrim(( cAliasZ04 )->&(aCampo[nZ,1]))
			Next nZ
	 
			If Len(aListZ04) >= self:pageSize
				Exit
			EndIf
	 
		EndIf
 
		(cAliasZ04)->(dbSkip())
 
	EndDo
 
	( cAliasZ04 )->( dbCloseArea() )
 
	oJsonZ04['CatxNatxCC'] := aListZ04
 
	//-------------------------------------------------------------------
	// Serializa objeto Json
	//-------------------------------------------------------------------
	cJsonZ04:= FwJsonSerialize( oJsonZ04 )
 
	//-------------------------------------------------------------------
	// Elimina objeto da memoria
	//-------------------------------------------------------------------
	FreeObj(oJsonZ04)
 
	//-- Seta resposta
	Self:SetResponse( cJsonZ04 )		

	RestArea(aArea)
	
RETURN(lOk)