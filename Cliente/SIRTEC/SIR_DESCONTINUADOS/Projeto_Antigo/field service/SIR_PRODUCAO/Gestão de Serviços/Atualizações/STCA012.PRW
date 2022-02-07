#INCLUDE "rwmake.ch"
#INCLUDE "protheus.ch"
#INCLUDE "topconn.ch"       

#DEFINE STR0001 "Sirtec - STCA012"
#DEFINE STR0002 "Rotina somente poderá ser executada em nova linha"
#DEFINE STR0003 "Aguarde, criando arquivos temporários... "
#DEFINE STR0004 "Rotina somente poderá ser executada quando houver tabela de preço indicada"
#DEFINE STR0005 "Todos os produtos já estavam selecionados!"  
#DEFINE STR0006 "Item sem produto!"
#DEFINE STR0007 "Produdo não encontrado na tabela!"
#DEFINE STR0008 "Detalhamento da Estrutura de Produtos"
#DEFINE STR0009 "Informações da estrutura"
#DEFINE STR0010 "Codigo:"
#DEFINE STR0011 "Nome:" 
#DEFINE STR0012 "Quantidade:" 
#DEFINE STR0013 "Existem produtos com preço zerado." 
#DEFINE STR0014 "Existem produtos com sem serviço." 
#DEFINE STR0015 "Possível falha para encontrar os produtos na estrutura."  
#DEFINE STR0016 "Tabela de Preço:"

/*/
+----------+------------+-------------------+------+------------+
|Programa  |STCA012     | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Atualiza os apontamentos com os produtos            |
|          |contidos em uma Estrutura de Produtos               |
+----------+----------------------------------------------------+
|Sintaxe   |Gatilho                                             |
+----------+----------------------------------------------------+
|Parametros|#                                                   |
+----------+----------------------------------------------------+
|Retorno   |X7_CDOMIN                                           |
+----------+----------------------------------------------------+
|Uso       |APONTAMENTO ->ORÇAMENTO -> FIELD SERVICE ->SIRTEC   |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
/*/             
User Function STCA012 
	
	//Variaveis locais de controle da rotina
	Local nDel  	:= Len(aHeader)+1								   	//Posição do acols que indica se o item está deletado
	Local cItem     := GdFieldGet("AB5_SUBITE",n)						//Numero do item no aCols
	Local MV_YSTC04 := GetMv("MV_YSTC04")								//Parâmetro de controle da execução da rotina
	Local cRet 		:= Gdfieldget(&("SX7->X7_CDOMIN"),n)				//Retorno esperado
		 
	//Variaveis privadas de controle da rotina
	Private lExec   := .T. 												//Flag de controle da primeira execução
	Private lOk     := .F.
	Private cTabela := M->AB3_TABELA
	Private cTabela2:= M->AB3_YTAB2 
	Private nQuant  := 1 
	Private cTabT	:= Space(3)
	Private cEstru  := PARAMIXB                                         //Codigo da estrutura 
	Private cNome   := ''                                               //Codigo da estrutura 
	
	//Variaveis de controle da rotina
	Private aCampos := {}				//Controla campos da MSSelect
	Private aCpoBrw := {}				//Controla cabeçalho da MSSelect
	Private aHeadA	:= {}				//Controla cabeçalho da GetDados
	Private aColsA	:= {}				//Controla campos da GetDados
	Private aCpoAlt := {}				//Controla campos da GetDados
	Private cMarca  := GetMark()
	Private aArea   := GetArea()
	
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
	Private oTCab4			//Titulo no Cabeçalho
	Private oICab4			//Informação no Cabeçalho
	Private oGetDado		//Getdados
	
	//Verifica se a rotina está ativada e se é uma nova linha
	If MV_YSTC04 .and. n == Len(aCols) .and. !Empty(cTabela) 
		
		//Processamento da rotina
		Processa({||fSTCA001(1,cEstru),fSTCA003(1)},STR0001,STR0003)
		
		//Verifica conteudo da consulta
		If !Select("_SG1")>1	
			Alert(STR0006)
		 	Return 
		Else
			cEstru := _SG1->G1_COD
			cNome  := Posicione("SB1",1,xFilial("SB1")+_SG1->G1_COD,"B1_DESC") 
		End If
			
		
		//Monta tela de detalhamento da estrutura
		Eval({|| fSTCA004()})          	
		
		If lOk
		
		  	Processa({||lExec:=fSTCA002(cItem,nDel)},STR0001,STR0003)
		
			//Caso não tenha atualizado o item atual 
			If lExec
				MsAguarde({||Sleep(1500)},STR0001,STR0005) //"Todos os produtos já estavam selecionados!"
				aCols[n][nDel] := .T.		
			Endif				
		Endif
			
	//Caso a linha não esteja OK
	Elseif MV_YSTC04
		If n <> Len(aCols) 

			//Rotina somente pode ser executada quando for um novo item no aCols
			MsgInfo(STR0002,STR0001) //"Rotina somente poderá ser executada em nova linha"
		ElseIf Empty(cTabela)
			
			//Rotina somente pode ser executada quando houver tabela de preço digitada
			MsgInfo(STR0004,STR0001) //"Rotina somente poderá ser executada quando houver tabela de preço indicada"
		
		Endif
		//Retorna estrutura em branco
		cRet := ""
	Endif  
	
Return cRet

/*/
+----------+------------+-------------------+------+------------+
|Programa  |STCA012A    | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |janela para digitação de preço quando produto       |
|          |não encontrado na tabela de preço                   |
+----------+----------------------------------------------------+
|Sintaxe   |Dialogsamento                                       |
+----------+----------------------------------------------------+
|Parametros|#                                                   |
+----------+----------------------------------------------------+
|Retorno   |#                                                   |
+----------+----------------------------------------------------+
|Uso       |STCA012 ->ORÇAMENTOS ->FIELD SERVICE ->SIRTEC       |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
/*/             
User Function STCA012A(nNum)
	
 	@ 000,000 TO 210,400 DIALOG oDlgSTC TITLE STR0001

	@ 006,004 SAY "No item " + Alltrim(STR(nNum))
	@ 016,004 SAY "o produto " + Alltrim(aColsA[i][nDetPro])
	@ 026,004 SAY aColsA[i][nDetPro]
	@ 036,004 SAY "está sem preço cadastrado."
	@ 056,004 SAY "Indique o preço a ser utilizado."
    @ 066,004 TO 100, 160 TITLE "Digite o preço: "
    @ 080,040 GET nVUnit SIZE 100,300 Picture "@E 999,999.99"
    @ 080,168 BMPBUTTON TYPE 1 ACTION oDlgSTC:end()
    ACTIVATE DIALOG oDlgSTC CENTERED

Return

/*/
+----------+------------+-------------------+------+------------+
|Programa  |STCA012B    | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Calcula valor total do produto                      |
|          |                                                    |
+----------+----------------------------------------------------+
|Sintaxe   |Processamento                                       |
+----------+----------------------------------------------------+
|Parametros|nQuant e nVUnit                                     |
+----------+----------------------------------------------------+
|Retorno   |nTotal                                              |
+----------+----------------------------------------------------+
|Uso       |STCA012 ->ORÇAMENTOS ->FIELD SERVICE ->SIRTEC       |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
/*/             
User Function STCA012B(nValor,nQtd)

	nPreco := NoRound((nValor*nQtd),2)

Return(nPreco)     

/*/
+----------+------------+-------------------+------+------------+
|Programa  |STCA012C    | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Verifica se produto está na tabela                  |
|          |                                                    |
+----------+----------------------------------------------------+
|Sintaxe   |Processamento                                       |
+----------+----------------------------------------------------+
|Parametros|cProduto, cTabela                                   |
+----------+----------------------------------------------------+
|Retorno   |nTotal                                              |
+----------+----------------------------------------------------+
|Uso       |STCA012 ->ORÇAMENTOS ->FIELD SERVICE ->SIRTEC       |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
/*/             
User Function STCA012C(cProd,cTabela)

	Local lRet := .F.
	
	Do Case
	
		Case Empty(cTabela)
			lRet := .T.
			
		Case Empty(cProd)
			MsgStop(STR0006,STR0001)
		
		Otherwise
		    
			DA1->(DbSetOrder(1))
			If DA1->(DbSeek(xFilial("DA1")+cTabela+cProd))
				lRet := .T.
			Else
				MsgStop(STR0007,STR0001)			
			Endif
	EndCase

Return(lRet)

/*/
+----------+----------+-------+-----------------------+------+------------+
|Função    |STCA012D  | Autor |Microsiga Vitória      | Data |09.10.2007  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Monta informações tela de detalhamento da estrutura           |
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
User Function STCA012D(nOpc)

	Local cSQL	:= ""			
	Local cSC6  := RetSQLName("SC6") + " SC6 "
	Local cSB1  := RetSQLName("SB1") + " SB1 "
	Local cTES  := cCF := ""
	
	Do Case
	
		//Não aglutina nenhum produto
		Case nOpc == 1
		    
			//Controle do aCols
			aColsA := {}
			nItem  := 0
			
			//Vai para o top da consulta
			_SG1->(DbGoTop())
			
			//Encontra a estrutura na tabela no banco, para o tratamento de duplicidade
			SG1->(DbSetOrder(1))
			If !SG1->(DbSeek(xFilial("SG1")+_SG1->G1_COD+_SG1->G1_COMP))
				MsgAlert(STR0015,STR0001)
			Endif
			
			//Preenche o acols
			While !_SG1->(Eof())
			    
				If SG1->G1_COMP == _SG1->G1_COMP
					nItem++	    
	
					//Atualiza aCols
					AADD(aColsA,Array(Len(aHeadA)+1))
					
					aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="ESTRUTURA" })] := _SG1->G1_COD 	    	
					aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="PRODUTO"   })] := _SG1->G1_COMP 	    	
					aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="DESCRICAO" })] := _SG1->B1_DESC 	    	
					aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="TABELA"    })] := _SG1->DA1_CODTAB 	    	
					aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="SERVICO"   })] := _SG1->DA1_ySRV 	    	
					aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="QUANTIDADE"})] := _SG1->G1_QUANT 	    	
					aColsA[nItem][aScan(aHeadA,{|x|AllTrim(x[02])=="VALOR"     })] := _SG1->DA1_PRCVEN 	
					aColsA[nItem][Len(aHeadA)+1] := .F.    	
				
					_SG1->(DbSkip())		
					SG1->(DbSkip())
				Else
					_SG1->(DbSkip())
				Endif
						
			EndDo
		EndCase 
			
	//Refresh nos objetos
	oGetDado:aCols:= aColsA                                                                                
	oGetDado:oBrowse:Refresh()
	
Return              

User Function STCA012E

	Local lRet := Existcpo("DA1",M->TABELA+aColsA[n][aScan(aHeadA,{|x|AllTrim(x[02])=="PRODUTO"   })])

	If lRet
	
		aColsA[n][aScan(aHeadA,{|x|AllTrim(x[02])=="VALOR"     })] := DA1->DA1_PRCVEN
	Endif	
Return lRet   

User Function STCA012F
    Local nQtdEst := 0
     
	For a:=1 To Len(aColsA)
		nQtdEst := Posicione("SG1",1,xFilial("SG1")+cEstru+aColsA[a][aScan(aHeadA,{|x|AllTrim(x[02])=="PRODUTO"})],"G1_QUANT")
		aColsA[a][aScan(aHeadA,{|x|AllTrim(x[02])=="QUANTIDADE"})] := ( nQtdEst * nQuant) 
	Next a
	
	//Refresh nos objetos
	oGetDado:aCols:= aColsA                                                                                
	oGetDado:oBrowse:Refresh()	
Return   

User Function STCA012G
    
	Local lRet := .T.
	Local nDetPrc := aScan( aHeadA , { |x| Alltrim(x[2])=="VALOR"     })		//Encontra posição do produto
	Local nDetSrv := aScan( aHeadA , { |x| Alltrim(x[2])=="SERVICO"   })		//Encontra posição do produto
	
	For s:=1 To Len(aColsA)
		
		If aColsA[s][nDetPrc] == 0
			MsgStop(STR0013,STR0001)
			lRet := .F.
			s := Len(aColsA)
		Endif
		
		If Empty(aColsA[s][nDetSrv])
			MsgStop(STR0014,STR0001)
			lRet := .F.
			s := Len(aColsA)
		Endif
	
	Next s   
	
	If lRet
		lOk:=.T.
		oDlgSTC:End()
	Endif

Return    

User Function STCA012H
    Local nPrc := 0
     
	For b:=1 To Len(aColsA)
		nPrc := 0	
		nPrc := Posicione("DA1",1,xFilial("DA1")+cTabT+aColsA[b][aScan(aHeadA,{|x|AllTrim(x[02])=="PRODUTO"})],"DA1_PRCVEN")
		
		If nPrc > 0
			aColsA[b][aScan(aHeadA,{|x|AllTrim(x[02])=="VALOR"})]  := nPrc 
			aColsA[b][aScan(aHeadA,{|x|AllTrim(x[02])=="TABELA"})] := cTabT 
		Endif
	Next a
	
	//Refresh nos objetos
	oGetDado:aCols:= aColsA                                                                                
	oGetDado:oBrowse:Refresh()	
Return   

/*
+----------+------------+-------------------+------+------------+
|Programa  |fSTCA001    | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Cria alias temporário para utilizar durante o       |
|          |gatilho                                             |
+----------+----------------------------------------------------+
|Sintaxe   |Processamento                                       |
+----------+----------------------------------------------------+
|Parametros|nOpc -> opção de processamento                      |
+----------+----------------------------------------------------+
|Retorno   |#                                                   |
+----------+----------------------------------------------------+
|Uso       |STCA012 ->ORÇAMENTOS ->FIELD SERVICE ->SIRTEC       |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
*/             
Static Function fSTCA001(nOpc,cEstru)

	Local cSQL := ""
	Local cSG1 := "" 
	Local cSB1 := "" 
	Local cDA1 := "" 
	
	Do Case 
		Case nOpc == 1
		    
		    //Alias a ser utilizado
			cSG1 := RetSQLName("SG1") + Space(1) + "SG1" + Space(1)			//Arquivo no banco de dados 
			cSB1 := RetSQLName("SB1") + Space(1) + "SB1" + Space(1)			//Arquivo no banco de dados 
			cDA1 := RetSQLName("DA1") + Space(1) + "DA1" + Space(1)			//Arquivo no banco de dados 

			//Cria consulta
			cSQL := " SELECT "
			cSQL += "  G1_COD "
			cSQL += " ,G1_COMP "
			cSQL += " ,G1_QUANT "
			cSQL += " ,B1_DESC "
			cSQL += " ,DA1_CODTAB "
			cSQL += " ,DA1_PRCVEN "
			cSQL += " ,DA1_YSRV "
			cSQL += " FROM " + cSG1 + " "
			
			cSQL += " INNER JOIN " + cSB1 + " ON "			
			cSQL += " SG1.G1_COMP = SB1.B1_COD "			
			cSQL += " AND SB1.D_E_L_E_T_ = '' "
			cSQL += " AND SB1.B1_FILIAL = '" + xFilial("SB1") + "' "
			
			cSQL += " LEFT OUTER JOIN " + cDA1 + " ON "			
			cSQL += " SG1.G1_COMP = DA1.DA1_CODPRO "			
		   	cSQL += " AND DA1.DA1_CODTAB IN ('" + cTabela + "','" + cTabela2 + "') "		
			cSQL += " AND DA1.D_E_L_E_T_ = '' " 
			cSQL += " AND DA1.DA1_FILIAL = '" + xFilial("DA1") + "' "
			
			cSQL += " WHERE SG1.G1_COD = '" + cEstru + "' "
			cSQL += " AND SG1.D_E_L_E_T_ = '' "
			cSQL += " AND SG1.G1_FILIAL = '" + xFilial("SG1") + "' "

			If cTabela < cTabela2
				cSQL += " ORDER BY G1_FILIAL, G1_COD, G1_COMP, DA1_CODTAB "
			Else
				cSQL += " ORDER BY G1_FILIAL, G1_COD, G1_COMP, DA1_CODTAB DESC "
			Endif
			
			//Log de controle
			Memowrite('\STCA012-1.TXT',cSQL)
		
			//Verifica se alias está em uso
			If chkfile("_SG1")                     
				DbselectArea("_SG1")
				DbCloseArea()
			End If
		
			//Cria query
			TcQuery cSQL New Alias "_SG1"
	End Case
Return                               

/*/
+----------+------------+-------------------+------+------------+
|Programa  |fSTCA002    | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Atualiza aCols                                      |
|          |                                                    |
+----------+----------------------------------------------------+
|Sintaxe   |Processamento                                       |
+----------+----------------------------------------------------+
|Parametros|cItem -> ultimo item do aCols                       |
+----------+----------------------------------------------------+
|Retorno   |#                                                   |
+----------+----------------------------------------------------+
|Uso       |STCA012 ->ORÇAMENTOS ->FIELD SERVICE ->SIRTEC       |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
/*/             
Static Function fSTCA002(cItem,nDel)
	
	Local lFlag := .T.				//Flag de controle da primeira execução
	Local nTotal:= 0				//Valor total do produto
	Local nProd := 0                //Variavel contendo a posição do produto no acols
	Local nCodPro := aScan( aHeader, { |x| Alltrim(x[2])=="AB5_CODPRO"})		//Encontra posição do produto
	Local nServ   := aScan( aHeader, { |x| Alltrim(x[2])=="AB5_CODSER"})		//Encontra posição do produto
	Local nValCol := aScan( aHeader, { |x| Alltrim(x[2])=="AB5_VUNIT" })		//Encontra posição do produto
	Local nTabp   := aScan( aHeader, { |x| Alltrim(x[2])=="AB5_YTABPR"})		//Encontra posição do produto
	Local nDetPro := aScan( aHeadA , { |x| Alltrim(x[2])=="PRODUTO"   })		//Encontra posição do produto
	Local nDetQtd := aScan( aHeadA , { |x| Alltrim(x[2])=="QUANTIDADE"})		//Encontra posição do produto
	Local nDetPrc := aScan( aHeadA , { |x| Alltrim(x[2])=="VALOR"     })		//Encontra posição do produto
	Local nDetEst := aScan( aHeadA , { |x| Alltrim(x[2])=="ESTRUTURA" })		//Encontra posição do produto
	Local nDetSrv := aScan( aHeadA , { |x| Alltrim(x[2])=="SERVICO"   })		//Encontra posição do produto
	Local nDetTab := aScan( aHeadA , { |x| Alltrim(x[2])=="TABELA"    })		//Encontra posição do produto
	Local nDetDes := aScan( aHeadA , { |x| Alltrim(x[2])=="DESCRICAO" })		//Encontra posição do produto
	Local nSoma := 0				//Controla numero do item adicionado no acols
	
	Local cServico := GetMv("MV_YORCSRV")
	
	If Empty(cServico)
		cServico := Space(TamSX3("AB5_CODSER")[1])
	Endif
	
	Private nVUnit:= 0				//Valor unitário do produto	
	
	For i:=1 To Len(aColsA)
        
        //Verifica se produto já está no acols
        nProd := 0
        For t:=1 To Len(aCols)
        
        	If	Alltrim(aColsA[i][nDetPro]) == Alltrim(aCols[t][nCodPro]);
				.and. aColsA[i][nDetSrv] == aCols[t][nServ]; 
 				.and. aColsA[i][nDetPrc] == aCols[t][nValCol];
 				.and. aColsA[i][nDetTab] == aCols[t][nTabp]
		        		
		        		nProd := t
		        	
		        	    //	Alert(	"Produto:"+aColsA[i][nDetPro]+"/"+aCols[t][nCodPro]+chr(13)+chr(10)+;
						//		"Servico:"+aColsA[i][nDetSrv]+"/"+aCols[t][nServ]  +chr(13)+chr(10)+;
						//		"Tabela:" +aColsA[i][nDetTab]+"/"+aCols[t][nTabp]  +chr(13)+chr(10)+;
						//		"Preco:"  +Alltrim(Str(aColsA[i][nDetPrc]))+"/"+Alltrim(Str(aCols[t][nValCol]))+chr(13)+chr(10)+;
						//		"Linha:"  +Alltrim(Str(t)))    
								
						t:= Len(aCols)    				
        	Endif
        Next t
 		
 		//Pega digitada quantidade
 		nQuant := aColsA[i][nDetQtd]
 		
 		
 		//Verifica se encontrou preço para o produto na tabela de venda
	    If aColsA[i][nDetPrc] > 0

			nVUnit := aColsA[i][nDetPrc]
			nTotal := U_STCA012B(nVUnit,nQuant)
		Else
			nVUnit := 0
			nTotal := 0
			
			//Tela para capturar preço do produto
			U_STCA012A(nProd)
			
			nTotal := U_STCA012B(nVUnit,nQuant)
	    Endif
	    
	    
	    //Atualiza aCols quando já existe o produto
	    If nProd > 0
			
			//Calcula valores
			nQuant := (GdFieldGet("AB5_QUANT",nProd)+nQuant) 
			nTotal := U_STCA012B(nVUnit,nQuant)
			
			//Atualiza
			GdFieldPut("AB5_YESTRU" ,aColsA[i][nDetEst],nProd)	    	
			GdFieldPut("AB5_QUANT"  ,nQuant,nProd)	    	
	    	//GdFieldPut("AB5_VUNIT"  ,nVUnit,nProd)	    	
	    	//GdFieldPut("AB5_PRCLIS" ,nVUnit,nProd)	    	
	    	GdFieldPut("AB5_TOTAL"  ,nTotal,nProd)	        
	    	//GdFieldPut("AB5_YTABPR" ,aColsA[i][nDetTab],nProd)	        
	    	//GdFieldPut("AB5_CODSER",If(!Empty(aColsA[i][nDetSrv]),aColsA[i][nDetSrv],cServico),nProd)	        
	    	    
	    //Atualiza linha atual do acols
	    Elseif lFlag
	    	GdFieldPut("AB5_CODPRO" ,aColsA[i][nDetPro]   ,n)	    	
	    	GdFieldPut("AB5_DESPRO" ,aColsA[i][nDetDes]   ,n)	    	
	    	GdFieldPut("AB5_CODSER" ,If(!Empty(aColsA[i][nDetSrv]),aColsA[i][nDetSrv],cServico),n)	    	
	    	GdFieldPut("AB5_QUANT"  ,nQuant,n)	    	
	    	GdFieldPut("AB5_VUNIT"  ,nVUnit,n)	    	
	    	GdFieldPut("AB5_PRCLIS" ,nVUnit,n)	    	
	    	GdFieldPut("AB5_TOTAL"  ,nTotal,n)	    	
	    	GdFieldPut("AB5_YTABPR" ,aColsA[i][nDetTab],n)	        
	    	lFlag := .F. //somente no primeiro item
	    Else
	    
		    //Pega numero do item no aCols
		    cItem := Soma1(cItem,TamSX3("AB5_SUBITE"))
		    
		    ++nSoma
			//Atualiza aCols
			AADD(aCols,Array(Len(aHeader)+1))
			
	    	GdFieldPut("AB5_SUBITE" ,cItem           ,nSoma + n)	    	
	    	GdFieldPut("AB5_YESTRU" ,aColsA[i][nDetEst]    ,nSoma + n)	    	
	    	GdFieldPut("AB5_CODPRO" ,aColsA[i][nDetPro]    ,nSoma + n)	    	
	    	GdFieldPut("AB5_DESPRO" ,aColsA[i][nDetDes]    ,nSoma + n)	    	
 		   	GdFieldPut("AB5_YTABPR" ,aColsA[i][nDetTab]    ,nSoma + n)	        
	    	GdFieldPut("AB5_CODSER" ,If(!Empty(aColsA[i][nDetSrv]),aColsA[i][nDetSrv],cServico),nSoma + n)	    	
	    	GdFieldPut("AB5_QUANT"  ,nQuant          ,nSoma + n)	    	
	    	GdFieldPut("AB5_VUNIT"  ,nVUnit          ,nSoma + n)	    	
	    	GdFieldPut("AB5_PRCLIS" ,nVUnit          ,nSoma + n)	    	
	    	GdFieldPut("AB5_TOTAL"  ,nTotal          ,nSoma + n)	    	
	    	GdFieldPut("AB5_ALI_WT" ,""              ,nSoma + n)	    	
	    	GdFieldPut("AB5_REC_WT" ,0               ,nSoma + n)  
	    	aCols[nSoma + n][Len(aHeadER)+1] := .F. 
		    
		Endif
		
	Next i
	
Return lFlag

/*/
+----------+----------+-------+-----------------------+------+------------+
|Função    |fSTCA003  | Autor |Microsiga Vitória      | Data |09.10.2007  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Monta cabeçalho da tela de detalhamento da estrutura          |
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
Static Function fSTCA003(nOpc)

	//Variavies locais de controle dos getdados(s)
	Local cUsado	:= "€€€€€€€€€€€€€€ "
	Local _cSX3 	:= GetNextAlias()
	
	Do Case
		Case nOpc ==  1
		
			//primeiro aCols                                        
			aArqHdA := {  "G1_COD";
						,"AB5_CODPRO";
						,"AB5_DESPRO";
						,"AB5_YTABPR";
						,"AB5_CODSER";
						,"AB5_QUANT" ;
						,"AB5_VUNIT" }
			
			//primeiro aCols                                        
			aTitHdA := { "ESTRUTURA" ;
						,"PRODUTO"   ;
						,"DESCRICAO" ;
						,"TABELA"    ;
						,"SERVICO"   ;
						,"QUANTIDADE";
						,"VALOR"      } 
		
				//SX3
				OpenSXs(Nil,Nil,Nil,Nil,cEmpAnt,_cSX3,"SX3",Nil,.F.)
				lOpen := Select(_cSX3) > 0
				If (lOpen)
					For i:=1 to Len(aArqHdA)
  						dbSelectArea(_cSX3)
  						(_cSX3)->(dbSetOrder(2)) //X3_CAMPO
  						(_cSX3)->(dbSeek(aArqHdA[i]))
						If (Found())
							aAdd(aHeadA,{ &("(_cSX3)->X3_TITULO") ,;
							aTitHdA[i]  	,;
							&("(_cSX3)->X3_PICTURE"),;
							&("(_cSX3)->X3_TAMANHO"),;
							&("(_cSX3)->X3_DECIMAL"),;
							iif(aArqHdA[i] == "AB5_YTABPR", "U_STCA012E()", &("(_cSX3)->X3_VALID")),;
							&("(_cSX3)->X3_USADO")	,;
							&("(_cSX3)->X3_TIPO")	,;
							iif(aArqHdA[i] == "AB5_YTABPR", "DA1-DT", &("(_cSX3)->X3_F3"))	     ,;
							&("(_cSX3)->X3_CONTEXT"),;
							&("(_cSX3)->X3_CBOX")   ,;
							&("(_cSX3)->X3_RELACAO")})
						EndIf	
					Next i 		
				Endif
				(_cSX3)->(dbCloseArea())


			/*SX3->(DbSetOrder(2))
				SX3->(DbSeek(aArqHdA[i]))	
				aAdd(aHeadA,{SX3->X3_TITULO ,;
							 aTitHdA[i]  	,;
							 SX3->X3_PICTURE,;
							 SX3->X3_TAMANHO,;
							 SX3->X3_DECIMAL,;
							 IF(aArqHdA[i] == "AB5_YTABPR", "U_STCA012E()",SX3->X3_VALID),;
							 SX3->X3_USADO	,;
							 SX3->X3_TIPO	,;
							 IF(aArqHdA[i] == "AB5_YTABPR", "DA1-DT",SX3->X3_F3)	     ,;
							 SX3->X3_CONTEXT,;
							 SX3->X3_CBOX   ,;
							 SX3->X3_RELACAO})			
			Next i*/

			
	   		aCpoAlt := {"TABELA","SERVICO","QUANTIDADE","VALOR"}
		EndCase 
Return

/*/
+----------+----------+-------+-----------------------+------+------------+
|Função    |fSTCA004  | Autor |Microsiga Vitória      | Data |09.10.2007  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Monta tela de detalhamento da estrutura                       |
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

	//Tela de confirmação dos dados 
	DEFINE MSDIALOG oDlgSTC TITLE STR0008 FROM C(0),C(0) TO C(400),C(900) PIXEL //"Detalhamento da Estrutura de Produtos"

	// Cria as Groups do Sistema
	@ C(012),C(008) TO C(040),C(430) LABEL STR0009 PIXEL OF oDlgSTC //"Informações da estrutura"
	
	//Informações do cabeçalho
	oTCab1 := tSay():New(C(020),C(015),{||STR0010} ,oDlgSTC,,,,,,.T.,,,270,20) 
	oICab1 := tSay():New(C(020),C(050),{||cEstru},oDlgSTC,,oFont,,,,.T.,CLR_RED,CLR_RED,270,20)
	
	oTCab2 := tSay():New(C(032),C(015),{||STR0011},oDlgSTC,,,,,,.T.,,,270,20) 
	oICab2 := tSay():New(C(032),C(050),{||cNome}  ,oDlgSTC,,oFont,,,,.T.,CLR_RED,CLR_RED,270,20)

	oTCab3 := tSay():New(C(020),C(100),{||STR0012},oDlgSTC,,,,,,.T.,,,270,20) 
	@ C(020),C(150) MsGet oICab3 Var nQuant Size C(060),C(009) COLOR CLR_BLACK Picture "@E 999,999,99.99" PIXEL OF oDlgSTC 
	
	oTCab4 := tSay():New(C(020),C(250),{||STR0016},oDlgSTC,,,,,,.T.,,,270,20) 
	@ C(020),C(300) MsGet oICab4 Var cTabT COLOR CLR_BLACK Picture "@!" F3 "DA0" PIXEL OF oDlgSTC

	// Cria ExecBlocks dos Componentes Padroes do Sistema
	oICab3:bChange:= {|| U_STCA012F()}
	oICab4:bChange:= {|| U_STCA012H()}
	//oQuant:bValid	:= {|| U_STCA012F()}
	//oQuant:bWhen	:= {|| bWhen }
	
	//Inclusao dos GetDados	
	oGetDado := MsNewGetDados():New(C(045),C(008),C(190),C(430),2,,,,aCpoAlt,,999,,,,oDlgSTC,aHeadA, aColsA) 
	oGetDado:aCols:= {}                                                                               
	
	//Atualiza informações do GetDados
	U_STCA012D(1)
	
	ACTIVATE MSDIALOG oDlgSTC On Init (EnchoiceBar(oDlgSTC,{|| U_STCA012G()},{|| lOk:=.F.,oDlgSTC:End()},,/*aButtons*/)) CENTERED

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