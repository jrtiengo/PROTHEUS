#Include "Totvs.ch"

/*/{Protheus.doc} User Function MA106VLG
	O ponto de entrada verifica as validações internas de bloqueio orçamentário antes de Gerar a Pré-Requisição.
	O ponto de entrada é verificado na função A106Proc no momento de Gerar a Pré-Requisição. (Variável nOpcA = 1).
	Neste customização é responsavel por gravar os dados da Solicitação ao Armazem na tabela ZZ0	
	@type  Function'
	@author Dênis Rodrigues
	@since 20/05/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see https://tdn.totvs.com/display/public/PROT/PEST07673_MA106VLG_GERAR_PRE_REQUISICAO
/*/
User Function MA106VLG()

	Local aArea	   := GetArea()
	Local aDados   := {}
	Local aValor   := {}
	Local aLibera  := {}	
	Local cQuery   := ""
	Local cAliasCP := ""
	Local cAliasB8 := ""
	Local cAliasBF := ""
	Local cSeek	   := ""
	Local cCodSA   := ""
	Local nItem	   := 0
	Local nPos	   := 0
	Local nPosAux  := 0
	Local nCnt	   := 0
	Local lOK	   := .T.
	
	cAliasCP := GetNextAlias() 
	cQuery += " SELECT SCP.CP_NUM,"
    cQuery += "        SCP.CP_PRODUTO,"
	cQuery += "        SCP.CP_DESCRI,"
	cQuery += "        Sum(SCP.CP_QUANT) AS CP_QUANT,"
	cQuery += "        SCP.CP_LOCAL,"
	cQuery += " 	   SB1.B1_RASTRO,"
	cQuery += "        SB1.B1_LOCALIZ" 
	cQuery += " FROM " + RetSQLName("SCP") + " SCP,"
	cQuery += 		     RetSQLName("SB1") + " SB1"
	cQuery += " WHERE SCP.CP_OK = '" + cMarca + "'"
	cQuery += "   AND SCP.CP_FILIAL  = '" + xFilial("SCP") + "'"
	cQuery += "   AND SCP.CP_STATUS  <>'E'"
	cQuery += "   AND SCP.D_E_L_E_T_ = ' '"
	cQuery += "   AND SB1.B1_COD = SCP.CP_PRODUTO"
	cQuery += "   AND SB1.D_E_L_E_T_<>'*'"
	cQuery += " GROUP BY SCP.CP_NUM,SCP.CP_PRODUTO,SCP.CP_DESCRI,SCP.CP_LOCAL,SB1.B1_RASTRO,SB1.B1_LOCALIZ"
	cQuery += " ORDER BY SCP.CP_NUM"

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCP,.F.,.T. )
	
	While ( cAliasCP )->( !Eof() )
	
		//Verificar o saldo atual.
		dbSelectArea("SB2")
		dbSetOrder(1)//B2_FILIAL+B2_COD+B2_LOCAL
		If dbSeek( xFilial("SB2") + ( cAliasCP )->CP_PRODUTO + ( cAliasCP )->CP_LOCAL )
			
			If ( cAliasCP )->B1_LOCALIZ == "S"

				nItem := 0
			
				/*
				+---------------------------------------+
				| Armazena os Saldos por endereço atual |
				+---------------------------------------+*/
				cAliasBF := GetNextAlias()
				cQuery := " SELECT BF_PRODUTO,"
				cQuery += "        BF_LOCAL,"
				cQuery += "        BF_LOCALIZ,"
				cQuery += "        BF_LOTECTL,"
				cQuery += "        SUM(BF_QUANT) AS BF_QUANT"
				cQuery += " FROM " + RetSQLName("SBF") 
				cQuery += " WHERE BF_FILIAL  = '" + xFilial("SBF") 			 + "'"
				cQuery += "   AND BF_PRODUTO = '" + ( cAliasCP )->CP_PRODUTO + "'"  
				cQuery += "   AND BF_LOCAL   = '" + ( cAliasCP )->CP_LOCAL   + "'"
				cQuery += "   AND BF_LOCALIZ <>'PALLET'"
				cQuery += "   AND BF_QUANT > 0"
				cQuery += "   AND D_E_L_E_T_<>'*'"
				cQuery += " GROUP BY BF_PRODUTO,BF_LOCAL,BF_LOCALIZ,BF_LOTECTL"

				cQuery := ChangeQuery( cQuery )
				dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasBF,.F.,.T. )
					
				If ( cAliasBF )->( !Eof() )

					While ( cAliasBF )->( !Eof() )
					
						nItem++
						cSeek := AllTrim( ( cAliasCP )->CP_NUM )
						cSeek += StrZero( nItem,2 )
						cSeek += AllTrim( ( cAliasCP )->CP_PRODUTO ) 
						cSeek += AllTrim( ( cAliasCP )->CP_LOCAL )
							
						//Localiza a Chave no array
						nPos := 0
							
						If nPos > 0
						
							//aDados[nPos][01] := ( cAliasCP )->CP_NUM		//01-CP_NUM
							//aDados[nPos][02] := StrZero( nItem,2 )		//02-NUMERO_ITEM
							//aDados[nPos][03] := ( cAliasCP )->CP_PRODUTO	//03-CP_PRODUTO
							//aDados[nPos][04] := ( cAliasCP )->CP_DESCRI	//04-CP_DESCRI
							//aDados[nPos][05] := ( cAliasCP )->CP_QUANT	//05-CP_QUANT
							aDados[nPos][06] := ( cAliasBF )->BF_LOCAL		//06-BF_LOCALIZ
							aDados[nPos][07] := ( cAliasBF )->BF_LOCALIZ	//07-BF_LOCALIZ
							aDados[nPos][08] := ( cAliasBF )->BF_QUANT		//08-BF_QUANT
							//aDados[nPos][09] := ""						//09-B8_LOTECTL
							//aDados[nPos][10] := 0   				 		//10-B8_SALDO
							//aDados[nPos][11] := ""						//11-B8_DTVALID
							aDados[nPos][12] := dDataBase					//12-DATA INCLUSAO
							aDados[nPos][13] := Time()						//13-HORA INCLUSAO
							aDados[nPos][14] := __CUSERID					//14-USUARIO SEPARADOR	
						
						Else
							
							aAdd( aDados,{ ( cAliasCP )->CP_NUM,; 	  //01-CP_NUM		
											StrZero( nItem,2 ),;	  //02-NUMERO_ITEM					  
											( cAliasCP )->CP_PRODUTO,;//03-CP_PRODUTO
											( cAliasCP )->CP_DESCRI,; //04-CP_DESCRI
											( cAliasCP )->CP_QUANT,;  //05-CP_QUANT
											( cAliasBF )->BF_LOCAL,;  //06-BF_LOCAL
											( cAliasBF )->BF_LOCALIZ,;//07-BF_LOCALIZ
											( cAliasBF )->BF_QUANT,;  //08-BF_QUANT
											( cAliasBF )->BF_LOTECTL,;//09-B8_LOTECTL
											0,;					 	  //10-B8_SALDO
											StoD("//"),;			  //11-B8_DTVALID
											dDataBase,;				  //12-DATA INCLUSAO
											Time(),;				  //13-HORA INCLUSAO
											__CUSERID,;				  //14-USUARIO SEPARADOR							
											"END"} )				  //15-ENDERECO
							
						EndIf
																														
						( cAliasBF )->( dbSkip() )
							
					EndDo
					
				Else 
					aAdd( aLibera, .F. )
				EndIf 
					
				( cAliasBF )->( dbCloseArea() )
					
			EndIf

			If ( cAliasCP )->B1_RASTRO $ "L|S"
				
				nItem := 0
			
				/*
				+-----------------------------------+
				| Armazena os Saldos por Lote atual |
				+-----------------------------------+*/
				cAliasB8 := GetNextAlias()
				cQuery := " SELECT B8_PRODUTO,"
				cQuery += "        B8_DTVALID,"
				cQuery += "        B8_LOTECTL,"
				cQuery += "        B8_SALDO"  
				cQuery += " FROM " + RetSQLName("SB8")
				cQuery += " WHERE B8_FILIAL  = '" + xFilial("SB8") + "'"
				cQuery += "   AND B8_PRODUTO = '" + ( cAliasCP )->CP_PRODUTO + "'" 
				cQuery += "   AND B8_LOCAL   = '" + ( cAliasCP )->CP_LOCAL   + "'"
				cQuery += "   AND B8_SALDO > 0"
				cQuery += "   AND D_E_L_E_T_<>'*'"
					
				cQuery := ChangeQuery( cQuery )
				dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasB8,.F.,.T. )
					
				If ( cAliasB8 )->( !Eof() )

					While ( cAliasB8 )->( !Eof() )

						nItem++
													
						cSeek := AllTrim( ( cAliasCP )->CP_PRODUTO ) 
						cSeek += AllTrim( ( cAliasCP )->CP_LOCAL )
						cSeek += AllTrim( ( cAliasB8 )->B8_LOTECTL )
							
						//Localiza a Chave no array
						nPos := 0
							
						If nPos > 0
						
							//aDados[nPos][01] := ( cAliasCP )->CP_NUM			//01-CP_NUM
							//aDados[nPos][02] := StrZero(nItem,2) 				//02-NUMERO_ITEM
							//aDados[nPos][03] := ( cAliasCP )->CP_PRODUTO		//03-CP_PRODUTO
							//aDados[nPos][04] := ( cAliasCP )->CP_DESCRI		//04-CP_DESCRI
							//aDados[nPos][05] := ( cAliasCP )->CP_QUANT		//05-CP_QUANT
							//aDados[nPos][06] := ( cAliasBF )->BF_LOCAL		//06-BF_LOCAL
							//aDados[nPos][07] := ( cAliasBF )->BF_LOCALIZ		//07-BF_LOCALIZ
							//aDados[nPos][08] := ( cAliasBF )->BF_QUANT		//08-BF_QUANT
							aDados[nPos][09] := ( cAliasB8 )->B8_LOTECTL		//09-B8_LOTECTL
							aDados[nPos][10] := ( cAliasB8 )->B8_SALDO 			//10-B8_SALDO
							aDados[nPos][11] := StoD( ( cAliasB8 )->B8_DTVALID )//11-B8_DTVALID
							aDados[nPos][12] := dDataBase						//12-DATA INCLUSAO
							aDados[nPos][13] := Time()							//13-HORA INCLUSAO
							aDados[nPos][14] := __CUSERID						//14-USUARIO SEPARADOR	 
						
						Else

							nPosAux := aScan( aDados,{|x|  AllTrim( x[3] ) + x[6] + x[9] = cSeek } )

							aAdd( aDados,{ ( cAliasCP )->CP_NUM,; 	 	//01-CP_NUM		
										StrZero( nItem,2 ),;		 	//02-NUMERO_ITEM					  
										( cAliasCP )->CP_PRODUTO,;		//03-CP_PRODUTO
										( cAliasCP )->CP_DESCRI,; 		//04-CP_DESCRI
										( cAliasCP )->CP_QUANT,;  		//05-CP_QUANT
										"",; 					 		//06-BF_LOCAL
										"",;//Iif(nPosAux>0,aDados[nPosAux][07],""),;						 	//07-BF_LOCALIZ
										0,;	 					 		//08-BF_QUANT
										( cAliasB8 )->B8_LOTECTL,;		//09-B8_LOTECTL
										( cAliasB8 )->B8_SALDO,;	 	//10-B8_SALDO
										StoD(( cAliasB8 )->B8_DTVALID),;//11-B8_DTVALID
										dDataBase,;				 		//12-DATA INCLUSAO
										Time(),;					 	//13-HORA INCLUSAO
										__CUSERID,; 				 	//14-USUARIO SEPARADOR						
										"LOT"})							//15-LOTE
							
						EndIf
														
						( cAliasB8 )->( dbSkip() )
							
					EndDo
					
				Else 
					aAdd( aLibera, .F. )
				EndIf 
					
				( cAliasB8 )->( dbCloseArea() )
									
			EndIf	
			
		Else
		
			MsgAlert("O saldo do produto " + AllTrim( ( cAliasCP )->CP_PRODUTO ) + " em estoque é inexistente.","Não existe saldo.")
			lOK := .F.
			aAdd( aLibera, .F. )
			
		EndIf
	
		( cAliasCP )->( dbSkip() )
		
	EndDo
	
	( cAliasCP )->( dbCloseArea() )

	If Len( aLibera ) = 0

		aSort( aDados,,,{|x,y| x[07] < y[07] } )

		For nCnt := 1 To Len( aDados )

			//+---------------------------------------------+
			//| Retorna os saldos disponiveis na tabela Z00 |
			//| ExpA01[1] = Saldo do Endereço               |
			//| ExpA01[2] = Saldo do Lote                   |
			//| ESTA FUNCAO NAO ESTA SENDO UTILIZADA        |
			//| foi construida inicialmente para controlar  |
			//| o saldo ja gerado                           |
			//+---------------------------------------------+
			aValor := MA106VLZ00( {aDados[nCnt][03],; //01-Produto
								   aDados[nCnt][06],; //02-Local
								   aDados[nCnt][07],; //03-Endereco
								   aDados[nCnt][09],; //04-Lote
								   aDados[nCnt][08],; //05-BF_QUANT
								   aDados[nCnt][10]}) //06-B8_SALDO

			dbSelectArea("Z00")
			Reclock("Z00",.T.)
				Z00->Z00_FILIAL := xFilial("Z00")
				Z00->Z00_NUMSA  := aDados[nCnt][01]	//01-CP_NUM
				Z00->Z00_PROD	:= aDados[nCnt][03]	//02-CP_PRODUTO
				Z00->Z00_DESCRI := aDados[nCnt][04]	//03-CP_DESCRI
				Z00->Z00_QTDSA  := aDados[nCnt][05]	//04-CP_QUANT
				Z00->Z00_LOCAL	:= aDados[nCnt][06] //05-BF_LOCAL
				Z00->Z00_ENDER	:= aDados[nCnt][07] //06-BF_LOCALIZ
				Z00->Z00_QTDEND	:= aDados[nCnt][08] //aValor[01]		//07-BF_QUANT
				Z00->Z00_LOTE 	:= aDados[nCnt][09]	//08-B8_LOTECTL
				Z00->Z00_SALOTE := aDados[nCnt][10] //aValor[02] 		//09-B8_SALDO
				Z00->Z00_DAVALO := aDados[nCnt][11]	//10-B8_DTVALID
				Z00->Z00_DATINC := aDados[nCnt][12]	//11-DATA INCLUSAO
				Z00->Z00_HORA	:= aDados[nCnt][13]	//12-HORA INCLUSAO
				Z00->Z00_USRSEP	:= aDados[nCnt][14]	//13-USUARIO SEPARADOR
				Z00->Z00_TIPO 	:= aDados[nCnt][15] //14-TIPO (ENDERECO/LOTE)
			MsUnlock()

			cCodSA := aDados[nCnt][01]
								
		Next nCnt

		//Limpa as informações da SA em caso de Copia.
		dbSelectArea("SCP")
		dbSetOrder(1)//CP_FILIAL+CP_NUM
		If dbSeek( xFilial("SCP") + PadR( cCodSA,TamSX3("CP_NUM")[01] ) )

			While SCP->( !Eof() ) .And. AllTrim( SCP->CP_NUM ) == AllTrim( cCodSA )

				Reclock("SCP",.F.)
					SCP->CP_USUAREC := ""
					SCP->CP_HORAREC := ""
					SCP->CP_STACONF := ""
				Msunlock()

				SCP->( dbSkip() )

			EndDo 

		EndIf 

	Else

		MsgAlert("Verifique se existe saldo no endereço nos itens da SA selecionada.","Geração cancelada.")
		lOK := .F. 

	EndIf 
		
	RestArea( aArea )

Return( lOK )

/*
|============================================================================|
|============================================================================|
|||-----------+----------+-------+-----------------------+------+----------|||
||| Funcao    |MA106VLZ00| Autor | Denis Rodrigues       | Data |20/05/2020|||
|||-----------+----------+-------+-----------------------+------+----------|||
||| Descricao |  Função para calcular o saldo do endereço e lote restante  |||
|||-----------+------------------------------------------------------------|||
||| Parametros| ExpA01[1] - Codigo do Produto                              |||
|||           | ExpA01[2] - Local                                          |||
|||           | ExpA01[3] - Endereco                                       |||
|||           | ExpA01[4] - Lote                                           |||
|||           | ExpA01[5] - BF_QUANT                                       |||
|||-----------+------------------------------------------------------------|||
||| Retorno   | ExpA1[1] - Saldo Endereco / ExpA1[2] - Saldo Lote          |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
Static Function MA106VLZ00( aDados )

	Local cQuery  := ""
	Local cAliasT := GetNextAlias()
	Local aRet	  := {}
	
	cQuery := " SELECT TOP(1) Z00_PROD,"
	cQuery += "        Z00_QTDEND,"
	cQuery += "        Z00_SALOTE,"
	cQuery += "        Z00_QTDSEP,"
	cQuery += "        Z00_QTDSA" 
	cQuery += " FROM " + RetSQLName("Z00")
	cQuery += " WHERE Z00_FILIAL = '" + xFilial("Z00") 	+ "'"
	cQuery += "   AND Z00_PROD   = '" + aDados[1]   	+ "'"
	cQuery += "   AND Z00_LOCAL  = '" + aDados[2]  		+ "'"
	cQuery += "   AND Z00_ENDER  = '" + aDados[3]  		+ "'"
	cQuery += "   AND Z00_LOTE   = '" + aDados[4]  		+ "'"
	cQuery += "   AND Z00_STACON <> 'OK'"
	cQuery += "   AND D_E_L_E_T_<>'*'"
	cQuery += " ORDER BY Z00_QTDEND "

	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )
	
	If ( cAliasT )->( !Eof() ) 

		While ( cAliasT )->( !Eof() )

			If ( ( cAliasT )->Z00_QTDEND - ( cAliasT )->Z00_QTDSEP ) > 0
		
				aAdd( aRet, aDados[5] - ( ( cAliasT )->Z00_QTDEND - ( cAliasT )->Z00_QTDSA) )
				aAdd( aRet, aDados[6] - ( ( cAliasT )->Z00_SALOTE - ( cAliasT )->Z00_QTDSA) )
			
			Else 

				aAdd( aRet, 0 )
				aAdd( aRet, 0 )

			EndIf 
		
			( cAliasT )->( dbSkip() )
			
		EndDo
		
		( cAliasT )->( dbCloseArea() )

		If Empty( aRet[1] )

			aRet := {}

			aAdd( aRet, aDados[05] )
			aAdd( aRet, aDados[06] )

		EndIf
	
	Else

		If Empty( aRet )

			aRet := {}

			aAdd( aRet, aDados[05] )
			aAdd( aRet, aDados[06] )

		EndIf

	EndIf 

Return( aRet )
