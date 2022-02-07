#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"
#INCLUDE "APWIZARD.CH"

#DEFINE STR0001 "Sirtec - STCA022"
#DEFINE STR0002 "Criando relacionamento de técnicos..."
#DEFINE STR0003 "Consulta sem registros..."
#DEFINE STR0004 "Sirtec - Aglutina Pedidos de Venda"
#DEFINE STR0005 "Pedido não encontrado! "
#DEFINE STR0006 "Numero do pedido de venda gerado pela rotina: "
#DEFINE STR0007 "O código do produto não foi preenchido."

/*/
+----------+------------+-------------------+------+------------+
|Programa  |STCA022     | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Aglutina pedidos de venda                           |
|          |                                                    |
+----------+----------------------------------------------------+
|Sintaxe   |Processamento                                       |
+----------+----------------------------------------------------+
|Parametros|#                                                   |
+----------+----------------------------------------------------+
|Retorno   |#                                                   |
+----------+----------------------------------------------------+
|Uso       |Pedido de Venda -> Faturamento -> Sirtec            |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
/*/
User Function STCA022
 
	Local MV_YSTC09 := GetMv("MV_YSTC09")								//Parâmetro de controle da execução da rotina
 	
	Private nOpc := 0
 	
 	//Executa rotina de aglutinar pedidos
	If MV_YSTC09
		U_STCA022A()
	Endif

Return

/*/
+----------+------------+-------------------+------+------------+
|Programa  |STCA022A    | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Processamento da rotina de aglunitar pedidos        |
|          |                                                    |
+----------+----------------------------------------------------+
|Sintaxe   |Processamento                                       |
+----------+----------------------------------------------------+
|Parametros|#                                                   |
+----------+----------------------------------------------------+
|Retorno   |#                                                   |
+----------+----------------------------------------------------+
|Uso       |Pedido de Venda -> Faturamento -> Sirtec            |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
/*/
User Function STCA022A
	    
    //Variaveis Locais de Controle da rotina
	Local cPerg := padr("STC022", 10, " ")  //padr("STC022", LEN(SX1->X1_GRUPO), " ")
	
	//Variaveis de controle da rotina
	Private aCampos := {}				//Controla campos da MSSelect
	Private aCpoBrw := {}				//Controla cabeçalho da MSSelect
	Private aHeadA	:= {}				//Controla cabeçalho da GetDados
	Private aColsA	:= {}				//Controla campos da GetDados
	Private cMarca  := GetMark()
	Private aArea   := GetArea()
	Private MV_YTES := GetMv("MV_YTES")
	
	//Variaveis de controle dos objetos
	Private oDlgSTC			//Dialog
	Private oFont			//Fonte utilizada
	Private oGet01			//Getdados
	Private oTCab1			//Titulo no Cabeçalho
	Private oICab1			//Informação no Cabeçalho
	Private oTCab2			//Titulo no Cabeçalho
	Private oICab2			//Informação no Cabeçalho
	Private oTCab3			//Titulo no Cabeçalho
	Private oICab3			//Informação no Cabeçalho
	Private oGetDado		//Getdados
	
	//Parâmetros da rotina
	SetPrvt("cCliente","cLojaDe","cLojaAt","cPedIni","cPedFim","cTipo","cProduto","nAglu","cNome","cLojaPed")
	
	//Parâmetros iniciais
	If !Pergunte(cPerg,.T.)
		Return
	Else
		cCliente := MV_PAR01
		cLojaDe  := MV_PAR02
		cLojaAt  := MV_PAR03
		cLojaPed := MV_PAR04
		cPedIni  := MV_PAR05
		cPedFim  := MV_PAR06
		cTipo    := MV_PAR07
		cProduto := MV_PAR08
		nAglu    := MV_PAR09
		cNome	 := Posicione("SA1",1,xFilial("SA1")+cCliente+cLojaPed,"A1_NOME")
	Endif
	
	If !Empty(cTipo) .and. Empty(cProduto)
		MsgInfo(STR0007,STR0001)
		Return
	Endif
	//Processamento da tela. 
	MsAguarde({|| fSTCA001()},STR0001,STR0002)
	
	//////////////////////////////////////////
	// Monta Tela de seleção dos registros  //
	//////////////////////////////////////////
	Eval({||fSTCA003()})
	
	//////////////////////////////////////////
	// Monta Tela de confirmação dos dados  //
	//////////////////////////////////////////	
	If nOpc ==1    									//nOpc == 1 (OK); nOpc == 2 (Cancela)
		
		//Processamento da tela. 
		MsAguarde({|| fSTCA004()},STR0001,STR0002)

		Eval({|| fSTCA005()})
	EndIf

	//////////////////////////////////////////
	// Grava pedido de venda                //
	//////////////////////////////////////////	
	If nOpc ==1    									//nOpc == 1 (OK); nOpc == 2 (Cancela)
	
		//Processamento da tela. 
		MsAguarde({|| fSTCA006()},STR0001,STR0002)
	
	Endif

	
	RestArea(aArea)
Return

/*/
+----------+----------+-------+-----------------------+------+------------+
|Função    |STCA022B  | Autor |Microsiga Vitória      | Data |09.10.2007  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Monta informações tela de seleção dos pedidos                 |
+----------+--------------------------------------------------------------+
|Retorno   |#                                                             |
+----------+--------------------------------------------------------------+
|Parâmetros|#                                                             |
+----------+--------------------------------------------------------------+
|Uso       |Field Service -> Sirtec                                       |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+----------+--------------------------------------------------------------+
| Data     | Descrição                                                    |
+----------+--------------------------------------------------------------+
|          |                                                              |
+----------+--------------------------------------------------------------+
/*/
User Function STCA022B

	Local cSQL	:= ""
	Local cSC6  := RetSQLName("SC6") + " SC6 "
	Local cSB1  := RetSQLName("SB1") + " SB1 "
	Local cTES  := cCF := ""
	
	Do Case
	
		//Não aglutina nenhum produto
	Case Empty(cTipo) .and. nAglu == 2
		    
			//Controle do aCols
		aColsA := {}
		nItem  := 0
			
			//Monta Consulta
		cSQL:= " SELECT "
		cSQL+= " C6_PRODUTO "
		cSQL+= ",C6_PRCVEN "
		cSQL+= ",C6_QTDVEN "
		cSQL+= ",C6_VALOR "
		cSQL+= " FROM " + cSC6 + " "
		cSQL+= " WHERE  "
		cSQL+= " SC6.C6_NUM IN ("
			
		//ARQTRB->(DbGoTop())
		dbSelectArea(_cTRB1)
		dbGoTop()
		While !_cTRB1->(EOF())
			If _cTRB1->MARCA == _cTRB1
				cSQL+= " '"	+ _cTRB1->PEDIDO + "', "
			EndIf
			_cTRB1->(DbSkip())
		EndDo
				
			//Ajusta querry
		cSQL:= SubStr(cSQL,1,Len(cSQL)-2) + ") "
			
		cSQL+= " AND SC6.D_E_L_E_T_ = '' "
		cSQL+= " ORDER BY SC6.C6_PRODUTO "
			
		Memowrite('\STCA022-2.txt',cSQL)
		
		If Select("_SC6")>1
			_SC6->(DbCloseArea())
		End If
			
		TcQuery cSQL New Alias "_SC6"
			 
		If !Select("_SC6")>1
			Alert(STR0003)
			Return
		End If
					
		_SC6->(DbGoTop())
		While !_SC6->(Eof())
			
			nItem++

				//Atualiza aCols
			AADD(aColsA,Array(Len(aHeadA)+1))
				
			aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_PRODUTO"})] := _SC6->C6_PRODUTO
			aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_QTDVEN" })] := _SC6->C6_QTDVEN
			aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_PRCVEN" })] := _SC6->C6_PRCVEN
			aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_VALOR"  })] := _SC6->C6_VALOR
		
			_SC6->(DbSkip())
		EndDo
			
		//Algutina sem sintético 
	Case Empty(cTipo) .and. nAglu == 1
			
			//Controle do aCols
		aColsA := {}
		nItem  := 0
			
			//Monta Consulta para os demais produtos
		cSQL:= " SELECT "

		cSQL+= " C6_PRODUTO "
		cSQL+= ",SUM(SC6.C6_QTDVEN) C6_QTDVEN "
		cSQL+= ",SUM(SC6.C6_VALOR) C6_VALOR "

		cSQL+= " FROM " + cSC6 + " "
            			
		cSQL+= " WHERE  "
		cSQL+= " SC6.C6_NUM IN ("
			
		//ARQTRB->(DbGoTop())
		dbSelectArea(_cTRB1)
		dbGoTop()
		While !(_cTRB1)->(EOF())
			If (_cTRB1)->MARCA == cMarca
				cSQL+= " '"	+ (_cTRB1)->PEDIDO + "', "
			EndIf
			(_cTRB1)->(DbSkip())
		EndDo
				
			//Ajusta querry
		cSQL:= SubStr(cSQL,1,Len(cSQL)-2) + ") "
			
		cSQL+= " AND SC6.D_E_L_E_T_ = '' "
			
		cSQL+= " GROUP BY SC6.C6_PRODUTO "
			
		cSQL+= " ORDER BY SC6.C6_PRODUTO "
			
		Memowrite('\STCA022-4.txt',cSQL)
		
		If Select("_SC6")>1
			_SC6->(DbCloseArea())
		End If
			
		TcQuery cSQL New Alias "_SC6"
			 
		If !Select("_SC6")>1
			Alert(STR0003)
			Return
		End If
					
		_SC6->(DbGoTop())
		While !_SC6->(Eof())
			
			nItem++

				//Atualiza aCols
			AADD(aColsA,Array(Len(aHeadA)+1))
				
			nTemp := NoRound((_SC6->C6_VALOR/_SC6->C6_QTDVEN),5)
				
			aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_PRODUTO"})] := _SC6->C6_PRODUTO
			aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_QTDVEN" })] := _SC6->C6_QTDVEN
			aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_PRCVEN" })] := nTemp //NoRound((_SC6->C6_VALOR/_SC6->C6_QTDVEN),2)
			aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_VALOR"  })] := Round(nTemp*_SC6->C6_QTDVEN,2) //_SC6->C6_VALOR
		
			_SC6->(DbSkip())
		EndDo

	    //Algutina mão de obra
	Case !Empty(cTipo) .and. nAglu == 2
			
			//Controle do aCols
		aColsA := {}
		nItem  := 0
			
			//Monta Consulta para os produtos que serão aglutinados cTipo			
		cSQL:= " SELECT "
			
		cSQL+= " SB1.B1_TIPO "
		cSQL+= ",SUM(SC6.C6_QTDVEN) C6_QTDVEN "
		cSQL+= ",SUM(SC6.C6_VALOR) C6_VALOR "
			
		cSQL+= " FROM " + cSC6 + " "
			
		cSQL+= " INNER JOIN " + cSB1 + " ON "
		cSQL+= " SB1.B1_COD = SC6.C6_PRODUTO "
		cSQL+= " AND SB1.B1_TIPO = '" + cTipo + "' "
		cSQL+= " AND SB1.D_E_L_E_T_ = '' "

		cSQL+= " WHERE  "
		cSQL+= " SC6.C6_NUM IN ("
			
		//ARQTRB->(DbGoTop())
		dbSelectArea(_cTRB1)
		dbGoTop()
		While !(_cTRB1)->(EOF())
			If (_cTRB1)->MARCA == cMarca
				cSQL+= " '"	+ (_cTRB1)->PEDIDO + "', "
			EndIf
			(_cTRB1)->(DbSkip())
		EndDo
				
			//Ajusta querry
		cSQL:= SubStr(cSQL,1,Len(cSQL)-2) + ") "
			
		cSQL+= " AND SC6.D_E_L_E_T_ = '' "
			
		cSQL+= " GROUP BY SB1.B1_TIPO "

		cSQL+= " ORDER BY SB1.B1_TIPO "
			
		Memowrite('\STCA022-3.txt',cSQL)
		
		If Select("_SC6")>1
			_SC6->(DbCloseArea())
		End If
			
		TcQuery cSQL New Alias "_SC6"
			 
		If !Select("_SC6")>1
			Alert(STR0003)
			Return
		End If
			
		_SC6->(DbGoTop())
		While !_SC6->(Eof())
			
			nItem++

				//Atualiza aCols
			AADD(aColsA,Array(Len(aHeadA)+1))
				
			nTemp := NoRound((_SC6->C6_VALOR/_SC6->C6_QTDVEN),5)
				
			aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_PRODUTO"})] := cProduto
			aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_QTDVEN" })] := _SC6->C6_QTDVEN
			aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_PRCVEN" })] := nTemp //NoRound((_SC6->C6_VALOR/_SC6->C6_QTDVEN),2)
			aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_VALOR"  })] := Round(nTemp*_SC6->C6_QTDVEN,2) //_SC6->C6_VALOR
		
			_SC6->(DbSkip())
		EndDo
			
			//Monta Consulta para os demais produtos
		cSQL:= " SELECT "

		cSQL+= " C6_PRODUTO "
		cSQL+= ",C6_PRCVEN "
		cSQL+= ",C6_QTDVEN "
		cSQL+= ",C6_VALOR "

		cSQL+= " FROM " + cSC6 + " "
            
		cSQL+= " INNER JOIN " + cSB1 + " ON "
		cSQL+= " SB1.B1_COD = SC6.C6_PRODUTO "
		cSQL+= " AND SB1.B1_TIPO <> '" + cTipo + "' "
		cSQL+= " AND SB1.D_E_L_E_T_ = '' "
			
		cSQL+= " WHERE  "
		cSQL+= " SC6.C6_NUM IN ("
			
		//ARQTRB->(DbGoTop())
		dbSelectArea(_cTRB1)
		dbGoTop()
		While !_cTRB1->(EOF())
			If _cTRB1->MARCA == cMarca
				cSQL+= " '"	+ _cTRB1->PEDIDO + "', "
			EndIf
			_cTRB1->(DbSkip())
		EndDo
				
			//Ajusta querry
		cSQL:= SubStr(cSQL,1,Len(cSQL)-2) + ") "
			
		cSQL+= " AND SC6.D_E_L_E_T_ = '' "

		cSQL+= " ORDER BY SC6.C6_PRODUTO "
			
		Memowrite('\STCA022-5.txt',cSQL)
		
		If Select("_SC6")>1
			_SC6->(DbCloseArea())
		End If
			
		TcQuery cSQL New Alias "_SC6"
			 
		If !Select("_SC6")>1
			Alert(STR0003)
			Return
		End If
					
		_SC6->(DbGoTop())
		While !_SC6->(Eof())
			
			nItem++

				//Atualiza aCols
			AADD(aColsA,Array(Len(aHeadA)+1))
				
			aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_PRODUTO"})] := _SC6->C6_PRODUTO
			aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_QTDVEN" })] := _SC6->C6_QTDVEN
			aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_PRCVEN" })] := _SC6->C6_PRCVEN
			aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_VALOR"  })] := _SC6->C6_VALOR
		
			_SC6->(DbSkip())
		EndDo

	    //Algutina tudo
	Case !Empty(cTipo) .and. nAglu == 1
			
			//Controle do aCols
		aColsA := {}
		nItem  := 0
			
			//Monta Consulta para os produtos que serão aglutinados cTipo			
		cSQL:= " SELECT "
			
		cSQL+= " SB1.B1_TIPO "
		cSQL+= ",SUM(SC6.C6_QTDVEN) C6_QTDVEN "
		cSQL+= ",SUM(SC6.C6_VALOR) C6_VALOR "
			
		cSQL+= " FROM " + cSC6 + " "
			
		cSQL+= " INNER JOIN " + cSB1 + " ON "
		cSQL+= " SB1.B1_COD = SC6.C6_PRODUTO "
		cSQL+= " AND SB1.B1_TIPO = '" + cTipo + "' "
		cSQL+= " AND SB1.D_E_L_E_T_ = '' "

		cSQL+= " WHERE  "
		cSQL+= " SC6.C6_NUM IN ("
			
		//ARQTRB->(DbGoTop())
		dbSelecArea(_cTRB1)
		dbGoTop()

		While !(_cTRB1)->(EOF())
			If (_cTRB1)->MARCA == cMarca
				cSQL+= " '"	+ (_cTRB1)->PEDIDO + "', "
			EndIf
			(_cTRB1)->(DbSkip())
		EndDo
				
			//Ajusta querry
		cSQL:= SubStr(cSQL,1,Len(cSQL)-2) + ") "
			
		cSQL+= " AND SC6.D_E_L_E_T_ = '' "
			
		cSQL+= " GROUP BY SB1.B1_TIPO "

		cSQL+= " ORDER BY SB1.B1_TIPO "
			
		Memowrite('\STCA022-3.txt',cSQL)
		
		If Select("_SC6")>1
			_SC6->(DbCloseArea())
		End If
			
		TcQuery cSQL New Alias "_SC6"
			 
		If !Select("_SC6")>1
			Alert(STR0003)
			Return
		End If
			
		_SC6->(DbGoTop())
		While !_SC6->(Eof())
			
			nItem++

				//Atualiza aCols
			AADD(aColsA,Array(Len(aHeadA)+1))
				
			nTemp := NoRound((_SC6->C6_VALOR/_SC6->C6_QTDVEN),5)
				
			aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_PRODUTO"})] := cProduto
			aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_QTDVEN" })] := _SC6->C6_QTDVEN
			aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_PRCVEN" })] := nTemp //NoRound((_SC6->C6_VALOR/_SC6->C6_QTDVEN),2)
			aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_VALOR"  })] := Round(nTemp*_SC6->C6_QTDVEN,2) //_SC6->C6_VALOR
		
			_SC6->(DbSkip())
		EndDo
			
			//Monta Consulta para os demais produtos
		cSQL:= " SELECT "

		cSQL+= " C6_PRODUTO "
		cSQL+= ",SUM(SC6.C6_QTDVEN) C6_QTDVEN "
		cSQL+= ",SUM(SC6.C6_VALOR) C6_VALOR "

		cSQL+= " FROM " + cSC6 + " "
            
		cSQL+= " INNER JOIN " + cSB1 + " ON "
		cSQL+= " SB1.B1_COD = SC6.C6_PRODUTO "
		cSQL+= " AND SB1.B1_TIPO <> '" + cTipo + "' "
		cSQL+= " AND SB1.D_E_L_E_T_ = '' "
			
		cSQL+= " WHERE  "
		cSQL+= " SC6.C6_NUM IN ("
			
		//ARQTRB->(DbGoTop())
		dbSelecArea(_cTRB1)
		dbGoTop()		
		While !(_cTRB1)->(EOF())
			If (_cTRB1)->MARCA == cMarca
				cSQL+= " '"	+ (_cTRB1)->PEDIDO + "', "
			EndIf
			(_cTRB1)->(DbSkip())
		EndDo
				
			//Ajusta querry
		cSQL:= SubStr(cSQL,1,Len(cSQL)-2) + ") "
			
		cSQL+= " AND SC6.D_E_L_E_T_ = '' "
			
		cSQL+= " GROUP BY SC6.C6_PRODUTO "
			
		cSQL+= " ORDER BY SC6.C6_PRODUTO "
			
		Memowrite('\STCA022-4.txt',cSQL)
		
		If Select("_SC6")>1
			_SC6->(DbCloseArea())
		End If
			
		TcQuery cSQL New Alias "_SC6"
			 
		If !Select("_SC6")>1
			Alert(STR0003)
			Return
		End If
					
		_SC6->(DbGoTop())
		While !_SC6->(Eof())
			
			nItem++

				//Atualiza aCols
			AADD(aColsA,Array(Len(aHeadA)+1))
				
			nTemp := NoRound((_SC6->C6_VALOR/_SC6->C6_QTDVEN),5)
				
			aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_PRODUTO"})] := _SC6->C6_PRODUTO
			aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_QTDVEN" })] := _SC6->C6_QTDVEN
			aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_PRCVEN" })] := nTemp //NoRound((_SC6->C6_VALOR/_SC6->C6_QTDVEN),2)
			aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_VALOR"  })] := Round(nTemp*_SC6->C6_QTDVEN,2) //_SC6->C6_VALOR
		
			_SC6->(DbSkip())
		EndDo
	EndCase
		
	SB1->(DbSetOrder(1))
	For i:=1 To Len(aColsA)
		If SB1->(DbSeek(xFilial("SB1")+aColsA[i][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_PRODUTO"})]))
			If Empty(SB1->B1_TS)
				cTES := MV_YTES
				cCF  := Posicione("SF4",1,xFilial("SF4")+MV_YTES,"F4_CF")
			Else
				cTES := SB1->B1_TS
				cCF  := Posicione("SF4",1,xFilial("SF4")+SB1->B1_TS,"F4_CF")
			Endif
		  		
			aColsA[i][aScan(aHeadA,{|x|AllTrim(x[02])=="B1_TIPO"   })] := SB1->B1_TIPO
			aColsA[i][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_UM"     })] := SB1->B1_UM
			aColsA[i][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_SEGUM"  })] := SB1->B1_SEGUM
			aColsA[i][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_TES"    })] := cTES
			aColsA[i][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_LOCAL"  })] := SB1->B1_LOCPAD
			aColsA[i][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_CF"     })] := cCF
			aColsA[i][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_ENTREG" })] := DTOC(DDataBase)
			aColsA[i][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_DESCRI" })] := SB1->B1_DESC
			aColsA[i][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_TPOP"   })] := "F"
			aColsA[i][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_SUGENTR"})] := DTOC(DDataBase)
			aColsA[i][Len(aHeadA)+1] := .F.
				
		EndIf

	Next i
	
	//Refresh nos objetos
	oGetDado:aCols:= aColsA
	oGetDado:oBrowse:Refresh()
Return

/*/
+----------+----------+-------+-----------------------+------+------------+
|Função    |STCA022C  | Autor |Microsiga Vitória      | Data |09.10.2007  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Apaga os relacionamentos entre os Pedidos de Venda aglutinados|
+----------+--------------------------------------------------------------+
|Retorno   |#                                                             |
+----------+--------------------------------------------------------------+
|Parâmetros|#                                                             |
+----------+--------------------------------------------------------------+
|Uso       |Field Service -> Sirtec                                       |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+----------+--------------------------------------------------------------+
| Data     | Descrição                                                    |
+----------+--------------------------------------------------------------+
|          |                                                              |
+----------+--------------------------------------------------------------+
/*/
User Function STCA022C

	Local cSQL	:= ""
	Local aArea := GetArea()
	Local aASC5 := SC5->(GetArea())
	Local cSC5  := RetSQLName("SC5") + " SC5 "
	
	cSQL := " SELECT SC5.C5_NUM
	cSQL += " FROM " + cSC5 + " "
	cSQL += " WHERE "
	cSQL += " SC5.C5_YPED = '" + SC5->C5_NUM + "' "
	cSQL += " AND SC5.D_E_L_E_T_ = '' "
	cSQL += " ORDER BY SC5.C5_NUM "

	Memowrite('\STCA022-5.txt',cSQL)

	If Select("_SC5")>1
		_SC5->(DbCloseArea())
	End If
	
	TcQuery cSQL New Alias "_SC5"
	 
	If !Select("_SC5")>1
		Return
	Else
		SC5->(DbSetOrder(1))
		SC6->(DbSetOrder(1))
		_SC5->(DbGoTop())
		While !_SC5->(EOF())
		    
			//Pesquisa cabeçalho
			If SC5->(DbSeek(xFilial("SC5")+_SC5->C5_NUM))
				RecLock("SC5",.F.)
				SC5->C5_YPED   := Space(1)
				SC5->C5_YAGLUTI:= Space(1)
				SC5->C5_NOTA   := Space(1)
				SC5->(MsUnlock())
				
				//Pesquisa itens
				If SC6->(DbSeek(xFilial("SC6")+_SC5->C5_NUM))
					While SC6->C6_NUM == _SC5->C5_NUM ;
							.and. !SC6->(EOF())
					    
					   	//Limpa bloqueio do item
						RecLock("SC6",.F.)
						SC6->C6_BLQ   	:= Space(1)
						SC6->(MsUnlock())
						
						//proximo registro
						SC6->(DbSkip())
					EndDo
				Endif
			Endif

			_SC5->(DbSkip())
		EndDo
	End If

	RestArea(aArea)
	RestArea(aASC5)
Return
/*/
+----------+----------+-------+-----------------------+------+------------+
|Função    |fSTCA001  | Autor |Microsiga Vitória      | Data |09.10.2007  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Cria informações para a consulta                              |
+----------+--------------------------------------------------------------+
|Retorno   |#                                                             |
+----------+--------------------------------------------------------------+
|Parâmetros|#                                                             |
+----------+--------------------------------------------------------------+
|Uso       |Field Service -> Sirtec                                       |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+----------+--------------------------------------------------------------+
| Data     | Descrição                                                    |
+----------+--------------------------------------------------------------+
|          |                                                              |
+----------+--------------------------------------------------------------+
/*/

Static Function fSTCA001(nOpc)
	
	Local cSQL	:= ""
	Local cSC5 := RetSQLName("SC5") + " SC5 "

	Private _cTRB1	 := GetNextAlias() //Alias Tabela Temporária

	
	//Cria arquivo temporário   		    
	aAdd(aCampos,{"MARCA"     ,"C",02,0})
	aAdd(aCampos,{"PEDIDO"    ,"C",TamSX3("C5_NUM")[1]    ,0})
	aAdd(aCampos,{"CLIENTE"   ,"C",TamSX3("C5_CLIENTE")[1],0})
	aAdd(aCampos,{"LOJA"      ,"C",TamSX3("C5_LOJACLI")[1],0})
	aAdd(aCampos,{"NUMOS"     ,"C",TamSX3("C5_YOS")[1] ,0})
	
	
	//-------------------
	//Criação do objeto
	//-------------------
	If (Select(_cTRB1) > 0)
	    oTempTab1:Delete()
	EndIf
	oTempTab1 := FWTemporaryTable():New( _cTRB1, aCampos  )
	oTempTab1:AddIndex("01", {aCampos[1] + aCampos[2] + aCampos[3]} )	
	oTempTab1:Create()	

	/*If Select("ARQTRB")>1
		ARQTRB->(DbCloseArea())
	End If
	ARQTRB := CriaTrab(aCampos,.T.)
	DbUseArea(.T.,,ARQTRB,"ARQTRB",.F.)*/

	aAdd(aCpoBrw,{"MARCA"     ,,""})
	aAdd(aCpoBrw,{"PEDIDO"    ,,RetTitle("C5_NUM"    )})
	aAdd(aCpoBrw,{"CLIENTE"   ,,RetTitle("C5_CLIENTE")})
	aAdd(aCpoBrw,{"LOJA"      ,,RetTitle("C5_LOJACLI")})
	aAdd(aCpoBrw,{"NUMOS"     ,,RetTitle("C5_YOS"    )})
	
	cSQL:= " SELECT "
	cSQL+= " C5_NUM "
	cSQL+= " ,C5_CLIENTE "
	cSQL+= " ,C5_LOJACLI "
	
	cSQL+= " FROM " + cSC5 + " "
	
	cSQL+= " WHERE  "
	cSQL+= " C5_NUM BETWEEN '" + cPedIni + "' AND '" + cPedFim + "' "
	cSQL+= " AND C5_CLIENTE = '" + cCliente + "' "
	cSQL+= " AND C5_LOJACLI BETWEEN '" + cLojaDe + "' AND '" + cLojaAt + "' "
	cSQL+= " AND C5_YAGLUTI <> 'S' "
	cSQL+= " AND C5_NOTA    =  ''  "
	cSQL+= " AND SC5.D_E_L_E_T_ = '' "
	
	cSQL+= " 	ORDER BY C5_NUM "
	
	Memowrite('\STCA022-1.txt',cSQL)

	If Select("_SC5")>1
		_SC5->(DbCloseArea())
	End If
	
	TcQuery cSQL New Alias "_SC5"
	 
	If !Select("_SC5")>1
		Alert(STR0003)
		Return
	End If
	
	_SC5->(DbGoTop())
	While !_SC5->(Eof())

		(_cTRB1)->(DBAppend())
		(_cTRB1)->MARCA	  := ""
		(_cTRB1)->PEDIDO  := _SC5->C5_NUM
		(_cTRB1)->CLIENTE := _SC5->C5_CLIENTE
		(_cTRB1)->LOJA    := _SC5->C5_LOJACLI
		(_cTRB1)->NUMOS   := Left(Posicione("SC6",1,XFilial("SC6")+_SC5->C5_NUM,"C6_NUMOS"),6)
		(_cTRB1)->(DBCommit())
		
		/*Reclock("ARQTRB",.T.)	
		ARQTRB->MARCA	:= ""
		ARQTRB->PEDIDO	:= _SC5->C5_NUM
		ARQTRB->CLIENTE	:= _SC5->C5_CLIENTE
		ARQTRB->LOJA    := _SC5->C5_LOJACLI
		ARQTRB->NUMOS   := Left(Posicione("SC6",1,XFilial("SC6")+_SC5->C5_NUM,"C6_NUMOS"),6)
		MsUnlock()*/

		_SC5->(Dbskip())
	EndDo

	//Controle da posição que o acols será exibido
	//DbSelectArea("ARQTRB")
	DbSelectArea(_cTRB1)
	DbGoTop()
Return

/*/
+----------+----------+-------+-----------------------+------+------------+
|Função    |fSTCA002  | Autor |Microsiga Vitória      | Data |09.10.2007  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Atualiza campo de controle (marca)                            |
+----------+--------------------------------------------------------------+
|Retorno   |                                                              |
+----------+--------------------------------------------------------------+
|Parâmetros|                                                              |
+----------+--------------------------------------------------------------+
|Uso       |Field Service -> Sirtec                                       |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+----------+--------------------------------------------------------------+
| Data     | Descrição                                                    |
+----------+--------------------------------------------------------------+
|          |                                                              |
+----------+--------------------------------------------------------------+
/*/
Static Function fSTCA002
	
	Local nSay4 := 0
	Local aArea := {}
	
	/*RecLock("ARQTRB",.F.)
	ARQTRB->MARCA := Iif(ARQTRB->MARCA!=cMarca,cMarca,"")
	MsUnlock()*/

	RecLock(_cTRB1,.F.)
	(_cTRB1)->MARCA := Iif((_cTRB1)->MARCA!=cMarca,cMarca,"")
	(_cTRB1)->(MsUnlock())
	
	oGet01:oBrowse:Refresh()

Return
    
/*/
+----------+----------+-------+-----------------------+------+------------+
|Função    |fSTCA003  | Autor |Microsiga Vitória      | Data |09.10.2007  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Monta tela de seleção dos pedidos                             |
+----------+--------------------------------------------------------------+
|Retorno   |#                                                             |
+----------+--------------------------------------------------------------+
|Parâmetros|#                                                             |
+----------+--------------------------------------------------------------+
|Uso       |Field Service -> Sirtec                                       |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+----------+--------------------------------------------------------------+
| Data     | Descrição                                                    |
+----------+--------------------------------------------------------------+
|          |                                                              |
+----------+--------------------------------------------------------------+
/*/
Static Function fSTCA003

	//Definição da Fonte
	oFont  := tFont():new(,,-11,,.T.)
	
	DEFINE MSDIALOG oDlgSTC TITLE STR0004 FROM C(200),C(200) TO C(500),C(700) PIXEL

	// Cria as Groups do Sistema
	@ C(012),C(008) TO C(040),C(245) LABEL "Informações do Pedido: " PIXEL OF oDlgSTC
	
	//Informações do cabeçalho
	oTCab1 := tSay():New(025,015,{||"Cliente: "},oDlgSTC,,,,,,.T.,,,270,20)
	oICab1 := tSay():New(025,050,{||cCliente}       ,oDlgSTC,,oFont,,,,.T.,CLR_RED,CLR_RED,270,20)
	
	oTCab2 := tSay():New(025,085,{||"Loja: "}   ,oDlgSTC,,,,,,.T.,,,270,20)
	oICab2 := tSay():New(025,120,{||cLojaPed}      ,oDlgSTC,,oFont,,,,.T.,CLR_RED,CLR_RED,270,20)

	oTCab3 := tSay():New(037,015,{||"Nome: "}     ,oDlgSTC,,,,,,.T.,,,270,20)
	oICab3 := tSay():New(037,050,{||cNome}      ,oDlgSTC,,oFont,,,,.T.,CLR_RED,CLR_RED,270,20)
	
	//Inclusao dos GetDados	
	oGet01 := MsSelect():New("_cTRB1","MARCA","",aCpoBrw,.F.,cMarca,{C(045),C(008),C(140),C(245)})
	//oGet01 := MsSelect():New("ARQTRB","MARCA","",aCpoBrw,.F.,cMarca,{C(045),C(008),C(140),C(245)})
	oGet01:bAval := {|| fSTCA002()}
	
	ACTIVATE MSDIALOG oDlgSTC On Init (EnchoiceBar(oDlgSTC,{|| nOpc:=1,oDlgSTC:End()},{|| nOpc:=2,oDlgSTC:End()},,/*aButtons*/)) CENTERED

Return

/*/
+----------+----------+-------+-----------------------+------+------------+
|Função    |fSTCA004  | Autor |Microsiga Vitória      | Data |09.10.2007  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Monta cabeçalho da tela de confirmação dos dados do pedido    |
+----------+--------------------------------------------------------------+
|Retorno   |#                                                             |
+----------+--------------------------------------------------------------+
|Parâmetros|#                                                             |
+----------+--------------------------------------------------------------+
|Uso       |Field Service -> Sirtec                                       |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+----------+--------------------------------------------------------------+
| Data     | Descrição                                                    |
+----------+--------------------------------------------------------------+
|          |                                                              |
+----------+--------------------------------------------------------------+
/*/
Static Function fSTCA004

	//Variavies locais de controle dos getdados(s)
	Local cUsado	:= "€€€€€€€€€€€€€€ "
	Local _cSX3 	:= GetNextAlias()
		
	//primeiro aCols                                        
	/*/
	DbSelectArea("SX3")
	DbSetOrder(1)
	DbSeek("SC6")
	While !SX3->(EOF()) .and. SX3->X3_ARQUIVO == "SC6"
		If SX3->X3_USADO == cUsado .and. SX3->X3_CONTEXT <> "V"
			aAdd(aHeadA,{SX3->X3_TITULO,SX3->X3_campo,SX3->X3_picture,SX3->X3_tamanho,SX3->X3_decimal,,SX3->X3_usado,SX3->X3_tipo,SX3->X3_arquivo,SX3->X3_context})
		Endif
		SX3->(DbSkip())
	Enddo
	/*/
	
	//primeiro aCols                                        
	aArqHdA := {  "C6_PRODUTO";
		,"C6_DESCRI";
		,"B1_TIPO"  ;
		,"C6_UM"    ;
		,"C6_QTDVEN";
		,"C6_PRCVEN";
		,"C6_VALOR" ;
		,"C6_SEGUM" ;
		,"C6_TES"   ;
		,"C6_LOCAL" ;
		,"C6_CF"    ;
		,"C6_ENTREG" ;
		,"C6_TPOP"   ;
		,"C6_SUGENTR"}

	//SX3
	OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX3,"SX3",Nil,.F.)
	lOpen := Select(_cSX3) > 0
	If (lOpen)
		For i:=1 to Len(aArqHdA)
  			dbSelectArea(_cSX3)
	  		(_cSX3)->(dbSetOrder(2)) //X3_CAMPO
  			(_cSX3)->(dbSeek(aArqHdA[i]))
			If (Found())
				aAdd(aHeadA,{&("(_cSX3)->X3_TITULO"), &("(_cSX3)->X3_campo"), &("(_cSX3)->X3_picture"), &("(_cSX3)->X3_tamanho"), &("(_cSX3)->X3_decimal"),,;
				&("(_cSX3)->X3_usado"), &("(_cSX3)->X3_tipo"), &("(_cSX3)->X3_arquivo"), &("(_cSX3)->X3_context") })
			EndIf
		Next i	
	EndIf
	(_cSX3)->(dbCloseArea())

	
	/*SX3->(DbSetOrder(2))
	For i:=1 to Len(aArqHdA)
		SX3->(DbSeek(aArqHdA[i]))
		aAdd(aHeadA,{SX3->X3_TITULO,SX3->X3_campo,SX3->X3_picture,SX3->X3_tamanho,SX3->X3_decimal,,SX3->X3_usado,SX3->X3_tipo,SX3->X3_arquivo,SX3->X3_context})
	Next i
	*/

Return

/*/
+----------+----------+-------+-----------------------+------+------------+
|Função    |fSTCA005  | Autor |Microsiga Vitória      | Data |09.10.2007  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Monta tela de seleção dos pedidos                             |
+----------+--------------------------------------------------------------+
|Retorno   |#                                                             |
+----------+--------------------------------------------------------------+
|Parâmetros|#                                                             |
+----------+--------------------------------------------------------------+
|Uso       |Field Service -> Sirtec                                       |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+----------+--------------------------------------------------------------+
| Data     | Descrição                                                    |
+----------+--------------------------------------------------------------+
|          |                                                              |
+----------+--------------------------------------------------------------+
/*/
Static Function fSTCA005

	//Tela de confirmação dos dados 
	DEFINE MSDIALOG oDlgSTC TITLE STR0004 FROM C(200),C(200) TO C(500),C(700) PIXEL

	// Cria as Groups do Sistema
	@ C(012),C(008) TO C(040),C(245) LABEL "Informações do Pedido: " PIXEL OF oDlgSTC
	
	//Informações do cabeçalho
	oTCab1 := tSay():New(025,015,{||"Cliente: "},oDlgSTC,,,,,,.T.,,,270,20)
	oICab1 := tSay():New(025,050,{||cCliente}       ,oDlgSTC,,oFont,,,,.T.,CLR_RED,CLR_RED,270,20)
	
	oTCab2 := tSay():New(025,085,{||"Loja: "}   ,oDlgSTC,,,,,,.T.,,,270,20)
	oICab2 := tSay():New(025,120,{||cLojaPed}      ,oDlgSTC,,oFont,,,,.T.,CLR_RED,CLR_RED,270,20)

	oTCab3 := tSay():New(037,015,{||"Nome: "}     ,oDlgSTC,,,,,,.T.,,,270,20)
	oICab3 := tSay():New(037,050,{||cNome}      ,oDlgSTC,,oFont,,,,.T.,CLR_RED,CLR_RED,270,20)
	
	//Inclusao dos GetDados	
	oGetDado := MsNewGetDados():New(C(045),C(008),C(140),C(245),,,,,,,120,,,,oDlgSTC,aHeadA, aColsA)
	oGetDado:aCols:= {}
	
	//Atualiza informações do GetDados
	U_STCA022B()
	
	ACTIVATE MSDIALOG oDlgSTC On Init (EnchoiceBar(oDlgSTC,{|| nOpc:=1,oDlgSTC:End()},{|| nOpc:=2,oDlgSTC:End()},,/*aButtons*/)) CENTERED

Return

/*/
+----------+----------+-------+-----------------------+------+------------+
|Função    |fSTCA006  | Autor |Microsiga Vitória      | Data |09.10.2007  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Grava Pedido de Venda                                         |
+----------+--------------------------------------------------------------+
|Retorno   |#                                                             |
+----------+--------------------------------------------------------------+
|Parâmetros|#                                                             |
+----------+--------------------------------------------------------------+
|Uso       |Field Service -> Sirtec                                       |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+----------+--------------------------------------------------------------+
| Data     | Descrição                                                    |
+----------+--------------------------------------------------------------+
|          |                                                              |
+----------+--------------------------------------------------------------+
/*/
Static Function fSTCA006
	
	Local aCabPv  := aItemPV	:= {}
	Local cNumPed := GetSXENum("SC5","C5_NUM")
	Local nItem   := 0
	
	If Len(aColsA) == 0
		Return
	Endif
		
	aCabPV:={	{"C5_NUM"    ,cNumped	,Nil},; // Numero do pedido
	{"C5_TIPO"   ,"N"		,Nil},; // Tipo de pedido
	{"C5_CLIENTE",cCliente	,Nil},; // Codigo do cliente
	{"C5_LOJACLI",cLojaPed  ,Nil},; // Loja do cliente
	{"C5_CLIENT",cCliente	,Nil},; // Codigo do cliente
	{"C5_LOJAENT",cLojaPed 	,Nil},; // Loja para entrada
	{"C5_EMISSAO",dDatabase ,Nil},; // Data de emissao
	{"C5_TABELA" ,""	    ,".T."},; // Codigo da Tabela de Preco
	{"C5_CONDPAG","001"		,".T."}}  // Codigo da condicao de pagamanto*
	
	For i:=1 To Len(aColsA)
		nItem++
		AAdd(aItemPV,{	{"C6_NUM"    ,cNumped			                                        		,Nil},; // Numero do Pedido
		{"C6_ITEM"   ,StrZero(nItem,2)	                                        		,Nil},; // Numero do Item no Pedido
		{"C6_PRODUTO",aColsA[i][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_PRODUTO"})]		,Nil},; // Codigo do Produto
		{"C6_QTDVEN" ,aColsA[i][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_QTDVEN" })]		,Nil},; // Quantidade Vendida
		{"C6_PRUNIT" ,aColsA[i][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_PRCVEN" })]		,Nil},; // PRECO DE LISTA
		{"C6_PRCVEN" ,aColsA[i][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_PRCVEN" })]		,Nil},; // Preco Unitario Liquido
		{"C6_VALOR"  ,aColsA[i][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_VALOR"  })]	 	,Nil},; // Valor Total do Item
		{"C6_ENTREG" ,CTOD(aColsA[i][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_ENTREG"  })])	,Nil},; // Data da Entrega
		{"C6_SUGENTR",CTOD(aColsA[i][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_SUGENTR" })])	,Nil},; // Data da Entrega
		{"C6_UM"     ,aColsA[i][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_UM"     })]		,Nil},; // Unidade de Medida Primar.
		{"C6_TES"    ,aColsA[i][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_TES"	 })]		,Nil},; // Tipo de Entrada/Saida do Item
		{"C6_LOCAL"  ,aColsA[i][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_LOCAL"  })]		,Nil},; // Almoxarifado
		{"C6_CLI"    ,cCliente												    		,Nil},; // Cliente
		{"C6_LOJA"   ,cLojaPed															,Nil},; // Loja do Cliente
		{"C6_SEGUM"  ,aColsA[i][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_SEGUM"  })]		,".T."},;
			{"C6_DESCRI" ,aColsA[i][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_DESCRI" })]		,Nil},;
			{"C6_TPOP"   ,aColsA[i][aScan(aHeadA,{|x|AllTrim(x[02])=="C6_TPOP"   })]		,Nil},;
			{"C6_QTDLIB" ,0                                                        			,Nil}})  // Quantidade Liberada})
						
			
	Next i


	
	//Banco
	Begin Transaction
		lTemp := .F.
		//lintemb := .F.    --- Teste EXS   
		//MSExecAuto({|x,y,z| Mata410(x,y,z)},aCabPv,aItemPV,2)
		//lTemp := AVMata410(aCabPv,aItemPV,3)
		
		lMsErroAuto := .F.
		lMsHelpAuto := .F.
		
		MSExecAuto({|x,y,z| Mata410(x,y,z)},aCabPv,aItemPV,3)
		
		If lMsErroAuto

            MostraErro()
			DisarmTransaction()

		Else
			
			lTemp := .T.
			
		EndIF
		
		
		If lTemp
			ConfirmSx8()
	
			//ARQTRB->(DbGoTop())
			dbSelectArea(_cTRB1)
			dbGoTop()
			SC5->(DbSetOrder(1))
			SC6->(DbSetOrder(1))
			While !_cTRB1->(EOF())
				If _cTRB1->MARCA == cMarca
					If SC5->(DbSeek(xFilial("SC5")+_cTRB1->PEDIDO))
						RecLock("SC5",.F.)
						SC5->C5_YPED   	:= cNumPed
						SC5->C5_YAGLUTI	:= "S"
						SC5->C5_NOTA	:= "XXXXXXXXX"
						SC5->(MsUnlock())
		 				
		 				//Atualiza pedidos
						If SC6->(DbSeek(xFilial("SC6")+_cTRB1->PEDIDO))
							While !SC6->(EoF());
									.and. SC6->C6_FILIAL == xFilial("SC6") ;
									.and. SC6->C6_NUM == _cTRB1->PEDIDO

								If SC6->C6_NUM == _cTRB1->PEDIDO
									
									RecLock("SC6",.F.)
									SC6->C6_BLQ   	:= "R"
									SC6->(MsUnlock())
								    		
								EndIf
								SC6->(DbSkip())
							EndDo
						Else
							MsgAlert(STR0005+_cTRB1->PEDIDO+"(item)",STR0001)
						EndIf
		 					
					Else
						MsgAlert(STR0005+_cTRB1->PEDIDO,STR0001)
					Endif
				Endif
				_cTRB1->(DbSkip())
			EndDo
		EndIf

	//Banco
	End Transaction

	If lTemp
		MsgInfo(STR0006+cNumPed,STR0001)
	Endif

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C(nTam)
	
	Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
	
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.8
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
		nTam *= 1
	Else	// Resolucao 1024x768 e acima
		nTam *= 1.28
	EndIf
                                                                                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                               
	//³Tratamento para tema "Flat"³                                               
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                               
	If "MP8" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf
Return Int(nTam)
