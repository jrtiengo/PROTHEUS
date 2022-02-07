#INCLUDE "rwmake.ch"
#INCLUDE "topconn.ch"          

#DEFINE STR0001 "Sirtec - STCA021"
#DEFINE STR0002 "Função deve ser executada em uma Requisição sem nenhum item digitado."
#DEFINE STR0003 "Consultando a Ordem de Serviço (Apontamentos)."

/*/
+----------+------------+-------------------+------+------------+
|Programa  |STCA021     | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Carrega os produtos contidos no Apontamento para    |
|          |a Requisição de OS                                  |
+----------+----------------------------------------------------+
|Sintaxe   |Processamento                                       |
+----------+----------------------------------------------------+
|Parametros|#                                                   |
+----------+----------------------------------------------------+
|Retorno   |#                                                   |
+----------+----------------------------------------------------+
|Uso       |REQUISIÇÃO DE OS -> FIELD SERVICE -> SIRTEC         |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
/*/             
User Function STCA021
 
 	Local MV_YSTC08 := GetMv("MV_YSTC08")								//Parâmetro de controle da execução da rotina   
	Local cSQL := ""
	
	Private aItem := aCols[1]
	
	If MV_YSTC08 ;
	.and. Len(aCols) = 1 ;
	.and. Empty(GdFieldGet("ABG_CODPRO",n)) ;
	.and. !Empty(M->ABF_NUMOS) ;
	.and. !Empty(M->ABF_ITEMOS)
	
		//Processamento da rotina
		Processa({||fSTCA001(),fSTCA002()},STR0001,STR0003)
	
	ElseIf MV_YSTC08 
		MsgInfo(STR0002,STR0001)
	Endif

Return
/*
+----------+------------+-------------------+------+------------+
|Programa  |fSTCA001    | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Cria alias temporário para utilizar durante o       |
|          |processamento                                       |
+----------+----------------------------------------------------+
|Sintaxe   |Processamento                                       |
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
*/             
Static Function fSTCA001
    
	//Variaveis locai de controle da rotina
	Local cSQL := ""
	Local cAB8 := "" 
	
    //Alias a ser utilizado
	cAB8 := RetSQLName("AB8") + Space(1) + "AB8" + Space(1)			//Arquivo no banco de dados 
	cSB1 := RetSQLName("SB1") + Space(1) + "SB1" + Space(1)			//Arquivo no banco de dados 
	cAA5 := RetSQLName("AA5") + Space(1) + "AA5" + Space(1)			//Arquivo no banco de dados 

	//Cria consulta
	cSQL := " SELECT "
	
	cSQL += " AB8.AB8_NUMOS "
	cSQL += " , AB8.AB8_SUBITE "
	cSQL += " , AB8.AB8_CODPRO "
	cSQL += " , AB8.AB8_DESPRO "
	cSQL += " , AB8.AB8_CODSER "
	cSQL += " , AB8.AB8_QUANT "
	cSQL += " , SB1.B1_UM "
	cSQL += " , SB1.B1_SEGUM "
	
	cSQL += " FROM " + cAB8 + " "
	
	cSQL += " INNER JOIN " + cSB1 + " ON "
	cSQL += " AB8.AB8_CODPRO = SB1.B1_COD "			 
	cSQL += " AND SB1.D_E_L_E_T_ = '' " 
	
	cSQL += " WHERE  "
	
	cSQL += " AB8.AB8_NUMOS = '" + M->ABF_NUMOS + "' "
	cSQL += " AND AB8.AB8_ITEM = '" + M->ABF_ITEMOS + "' "
	cSQL += " AND AB8.D_E_L_E_T_ = '' "
	
	cSQL += " ORDER BY AB8_SUBITE "
	
	//Log de controle
	Memowrite('\STCA021-1.TXT',cSQL)

	//Verifica se alias está em uso
	If chkfile("_AB8")                     
		DbselectArea("_AB8")
		DbCloseArea()
	End If

	//Cria query
	TcQuery cSQL New Alias "_AB8"
Return                               

/*/
+----------+------------+-------------------+------+------------+
|Programa  |fSTCA002    | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Adiciona itens no aCols                             |
|          |                                                    |
+----------+----------------------------------------------------+
|Sintaxe   |Processamento                                       |
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
Static Function fSTCA002
	
	Local lFlag := .T. 				  							  		//Flag de controle da rotina (primeiro item)    
	Local cItem := "00" //GdFieldGet("ABG_ITEM",n) 						//Controla itens a serem criados
	Local nSoma := 0
	Local aTemp := {}
	
	aCols := {} 
	oGetdReq:Refresh()
	
	AA5->(DbSetOrder(1))
	SF4->(DbSetOrder(1))
	_AB8->(DbGoTop())
	While !_AB8->(EOF())
		
		cEst := ""
		If AA5->(DbSeek(xFilial("AA5")+_AB8->AB8_CODSER))
			If SF4->(DbSeek(xFilial("SF4")+AA5->AA5_TES))
				cEst := SF4->F4_ESTOQUE
			Endif
		Endif
		
		If cEst <> "S"
			++nSoma
			
			//Pega numero do item no aCols
			cItem := Soma1(cItem,TamSX3("ABG_SUBITE"))
			
			aTemp := Array((Len(aHeader)+1)) 
			
			aTemp[aScan(aHeader,{|x|AllTrim(x[02])=="ABG_ITEM"  })]	:= cItem 	    	
			aTemp[aScan(aHeader,{|x|AllTrim(x[02])=="ABG_CODPRO"})]	:= _AB8->AB8_CODPRO	    	
			aTemp[aScan(aHeader,{|x|AllTrim(x[02])=="ABG_DESCRI"})]	:= _AB8->AB8_DESPRO   	
			aTemp[aScan(aHeader,{|x|AllTrim(x[02])=="ABG_QUANT" })]	:= _AB8->AB8_QUANT   	
			aTemp[aScan(aHeader,{|x|AllTrim(x[02])=="ABG_CODSER"})]	:= _AB8->AB8_CODSER	
			aTemp[aScan(aHeader,{|x|AllTrim(x[02])=="ABG_UM"    })]	:= _AB8->B1_UM
			aTemp[aScan(aHeader,{|x|AllTrim(x[02])=="ABG_SEGUM" })]	:= _AB8->B1_SEGUM
			aTemp[aScan(aHeader,{|x|AllTrim(x[02])=="ABG_QSEGUM"})]	:= ConvUm(_AB8->AB8_CODPRO,_AB8->AB8_QUANT,0,2)
			aTemp[aScan(aHeader,{|x|AllTrim(x[02])=="ABG_CODTEC"})]	:= ""
			aTemp[aScan(aHeader,{|x|AllTrim(x[02])=="ABG_SEQ"   })]	:= ""
			aTemp[aScan(aHeader,{|x|AllTrim(x[02])=="ABG_ALI_WT"})]	:= ""
			aTemp[aScan(aHeader,{|x|AllTrim(x[02])=="ABG_REC_WT"})]	:= 0
			aTemp[(Len(aHeader)+1)] := .F.
		 	
		 	AADD(aCols,aTemp)
		 	
			oGetdReq:Refresh()
  		EndIf
		_AB8->(DbSkip())
	EndDo 
	
	oGetdReq:Refresh()
Return