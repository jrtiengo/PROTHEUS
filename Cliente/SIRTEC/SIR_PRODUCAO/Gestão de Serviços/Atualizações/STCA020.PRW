#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"          

#DEFINE STR0001 "Sirtec - STCA020"
#DEFINE STR0002 "Rotina somente poderá ser executada em nova linha"
#DEFINE STR0003 "Aguarde, criando arquivos temporários... "
#DEFINE STR0004 "Rotina somente poderá ser executada quando houver tabela de preço indicada"
#DEFINE STR0005 "Todos os produtos já estavam selecionados!"
#DEFINE STR0006 "Item sem produto!"
#DEFINE STR0007 "Produdo não encontrado na tabela!"

/*/
+----------+------------+-------------------+------+------------+
|Programa  |STCA020     | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Atualiza as despesas do Atendimento de OS           |
|          |com os produtos contidos na Estrutura de Produtos   |
+----------+----------------------------------------------------+
|Sintaxe   |Gatilho                                             |
+----------+----------------------------------------------------+
|Parametros|#                                                   |
+----------+----------------------------------------------------+
|Retorno   |X7_CDOMIN                                           |
+----------+----------------------------------------------------+
|Uso       |DESPESA->ATENDIMENTO->FIELD SERVICE->SIRTEC         |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
/*/             
User Function STCA020
	
	//Variaveis locais de controle da rotina
	Local cEstru    := PARAMIXB                                         //Codigo da estrutura
	Local nDel  	:= Len(aHeader)+1								    //Posição do acols que indica se o item está deletado
	Local cItem     := GdFieldGet("ABC_ITEM",n)						//Numero do item no aCols
	Local MV_YSTC07 := GetMv("MV_YSTC07")								//Parâmetro de controle da execução da rotina
		
	//Variaveis privadas de controle da rotina
	Private lExec := .T. 												//Flag de controle da primeira execução
	Private cTabela := Posicione("AB6",1,xFilial("AB6")+Left(M->AB9_NUMOS,6),"AB6_TABELA")
	Private cTabela2:= Posicione("AB6",1,xFilial("AB6")+Left(M->AB9_NUMOS,6),"AB6->AB6_YTAB2")
	
	//Verifica se a rotina está ativada e se é uma nova linha
	If MV_YSTC07 .and. n == Len(aCols) .and. !Empty(cTabela) .and. !Empty(M->AB9_NUMOS)
		
		//Processamento da rotina
		Processa({||fSTCA001(1,cEstru),lExec:=fSTCA002(cItem,nDel)},STR0001,STR0003)
		
		//Caso não tenha atualizado o item atual 
		If lExec
			MsAguarde({||Sleep(1500)},STR0001,STR0005) //"Todos os produtos já estavam selecionados!"
			aCols[n][nDel] := .T.		
		Endif				
		
	//Caso a linha não esteja OK
	Elseif MV_YSTC07
		If n <> Len(aCols) 

			//Rotina somente pode ser executada quando for um novo item no aCols
			MsgInfo(STR0002,STR0001) //"Rotina somente poderá ser executada em nova linha"
		ElseIf Empty(cTabela)
			
			//Rotina somente pode ser executada quando houver tabela de preço digitada
			MsgInfo(STR0004,STR0001) //"Rotina somente poderá ser executada quando houver tabela de preço indicada"
		
		Endif
	Endif
	
Return(Gdfieldget(&("SX7->X7_CDOMIN"),n))  

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
|Uso       |STCA020 ->ORÇAMENTOS ->FIELD SERVICE ->SIRTEC       |
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
			cSQL += " ,B1_LOCPAD "
			cSQL += " ,DA1_CODTAB "
			cSQL += " ,DA1_PRCVEN "
			cSQL += " ,DA1_YSRV "
			cSQL += " FROM " + cSG1 + " "
			
			cSQL += " INNER JOIN " + cSB1 + " ON "			
			cSQL += " SG1.G1_COMP = SB1.B1_COD "			
			cSQL += " AND SB1.D_E_L_E_T_ = '' "
			
			cSQL += " LEFT OUTER JOIN " + cDA1 + " ON "			
			cSQL += " SG1.G1_COMP = DA1.DA1_CODPRO "			
		   	cSQL += " AND DA1.DA1_CODTAB IN ('" + cTabela + "','" + cTabela2 + "') "		
			cSQL += " AND DA1.D_E_L_E_T_ = '' "
			
			cSQL += " WHERE SG1.G1_COD = '" + cEstru + "' "
			cSQL += " AND SG1.D_E_L_E_T_ = '' "

			cSQL += " ORDER BY G1_FILIAL, G1_COD, G1_COMP "
			
			//Log de controle
			Memowrite('\STCA020-1.TXT',cSQL)
		
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
|Uso       |STCA020 ->ORÇAMENTOS ->FIELD SERVICE ->SIRTEC       |
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
	Local nQuant:= 0                //Quantidade do produto
	Local nProd := 0                //Variavel contendo a posição do produto no acols
	Local nCodPro := aScan( aHeader, { |x| Alltrim(x[2])=="ABC_CODPRO" } )		//Encontra posição do produto
	Local nSoma := 0				//Controla numero do item adicionado no acols
	
	Local cServico := GetMv("MV_YORCSRV")
	
	Private nVUnit:= 0				//Valor unitário do produto	
	
	_SG1->(DbGoTop())
	While !_SG1->(EOF())
        
        //Verifica se produto já está no acols
        nProd := aScan( aCols, { |x| x[nCodPro]==_SG1->G1_COMP .and. !x[nDel]})
 		nQuant := _SG1->G1_QUANT
 		
 		//Verifica se encontrou preço para o produto na tabela de venda
	    If _SG1->DA1_PRCVEN > 0

			nVUnit := _SG1->DA1_PRCVEN
			nTotal := U_STCA020B(nVUnit,nQuant)
		Else
			nVUnit := 0
			nTotal := 0
			
			//Tela para capturar preço do produto
			U_STCA020A(nProd)
			
			nTotal := U_STCA020B(nVUnit,nQuant)
	    Endif
	    
	    //Atualiza aCols quando já existe o produto
	    If nProd > 0
			
			//Calcula valores
			nQuant := (GdFieldGet("ABC_QUANT",nProd)+nQuant) 
			nTotal := U_STCA020B(nVUnit,nQuant)
			
			//Atualiza
			GdFieldPut("ABC_YESTRU" ,_SG1->G1_COD    ,nProd)	    	
			GdFieldPut("ABC_QUANT"  ,nQuant,nProd)	    	
	    	GdFieldPut("ABC_VLUNIT" ,nVUnit,nProd)	    	
	    	GdFieldPut("ABC_VALOR"  ,nTotal,nProd)	        
	    	GdFieldPut("ABC_YTABPR" ,_SG1->DA1_CODTAB,nProd)	        
	    	GdFieldPut("ABC_CODSER",If(!Empty(_SG1->DA1_YSRV),_SG1->DA1_YSRV,cServico),nProd)	        
	    	    
	    //Atualiza linha atual do acols
	    Elseif lFlag
	    	GdFieldPut("ABC_CODPRO" ,_SG1->G1_COMP  ,n)	    	
	    	GdFieldPut("ABC_DESCRI" ,_SG1->B1_DESC  ,n)	    	
	    	GdFieldPut("ABC_CODSER" ,If(!Empty(_SG1->DA1_YSRV),_SG1->DA1_YSRV,cServico),n)	    	
	    	GdFieldPut("ABC_QUANT"  ,nQuant         ,n)	    	
	    	GdFieldPut("ABC_VLUNIT" ,nVUnit         ,n)	    	
	    	GdFieldPut("ABC_VALOR"  ,nTotal         ,n)
	    	GdFieldPut("ABC_YTABPR" ,_SG1->DA1_CODTAB,n)	        
	    	lFlag := .F. //somente no primeiro item
	    Else
	    
		    //Pega numero do item no aCols
		    cItem := Soma1(cItem,TamSX3("ABC_ITEM"))
			      
			++nSoma
			//Atualiza aCols
			AADD(aCols,Array(Len(aHeader)+1))
			
	    	GdFieldPut("ABC_ITEM"   ,cItem           ,nSoma + n)	    	
	    	GdFieldPut("ABC_YESTRU" ,_SG1->G1_COD    ,nSoma + n)	    	
	    	GdFieldPut("ABC_CODPRO" ,_SG1->G1_COMP   ,nSoma + n)	    	
	    	GdFieldPut("ABC_DESCRI" ,_SG1->B1_DESC   ,nSoma + n)	    	
 		   	GdFieldPut("ABC_YTABPR" ,_SG1->DA1_CODTAB,nSoma + n)	        
	    	GdFieldPut("ABC_CODSER" ,If(!Empty(_SG1->DA1_YSRV),_SG1->DA1_YSRV,cServico),nSoma + n)	    	
	    	GdFieldPut("ABC_QUANT"  ,nQuant          ,nSoma + n)	    	
	    	GdFieldPut("ABC_VLUNIT" ,nVUnit          ,nSoma + n)	    	
	    	GdFieldPut("ABC_VALOR"  ,nTotal          ,nSoma + n)	    	
	    	GdFieldPut("ABC_ALI_WT" ,""              ,nSoma + n)	    	
	    	GdFieldPut("ABC_REC_WT" ,0               ,nSoma + n)
		Endif
		
		_SG1->(DbSkip())     
	Enddo
Return lFlag

/*/
+----------+------------+-------------------+------+------------+
|Programa  |STCA020A    | Microsiga Vitória | Data | 01.08.2007 |
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
|Uso       |STCA020 ->ORÇAMENTOS ->FIELD SERVICE ->SIRTEC       |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
/*/             
User Function STCA020A(nNum)
	
 	@ 000,000 TO 210,400 DIALOG oDlgSTC TITLE STR0001

	@ 006,004 SAY "No item " + Alltrim(STR(nNum))
	@ 016,004 SAY "o produto " + Alltrim(_SG1->G1_COMP)
	@ 026,004 SAY _SG1->B1_DESC
	@ 036,004 SAY "está sem preço cadastrado."
	@ 056,004 SAY "Indique o preço a ser utilizado."
    @ 066,004 TO 100, 160 TITLE "Digite o preço: "
    @ 080,040 GET nVUnit SIZE 100,300 Picture "@E 999,999.99"
    @ 080,168 BMPBUTTON TYPE 1 ACTION oDlgSTC:end()
    ACTIVATE DIALOG oDlgSTC CENTERED

Return

/*/
+----------+------------+-------------------+------+------------+
|Programa  |STCA020B    | Microsiga Vitória | Data | 01.08.2007 |
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
|Uso       |STCA020 ->ORÇAMENTOS ->FIELD SERVICE ->SIRTEC       |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
/*/             
User Function STCA020B(nValor,nQtd)

	nPreco := NoRound((nValor*nQtd),2)

Return(nPreco)

/*/
+----------+------------+-------------------+------+------------+
|Programa  |STCA020C    | Microsiga Vitória | Data | 01.08.2007 |
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
|Uso       |STCA020 ->ORÇAMENTOS ->FIELD SERVICE ->SIRTEC       |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
/*/             
User Function STCA020C(cProd,cTabela)

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