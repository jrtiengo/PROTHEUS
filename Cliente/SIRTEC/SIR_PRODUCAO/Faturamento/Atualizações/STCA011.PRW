#INCLUDE "rwmake.ch"

/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA011     | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Rotina que recalculo os valores da tabela de preço  |
|          |quando alterado o valor da USS                      |
+----------+----------------------------------------------------+
|Sintaxe   |Atualiza o SE2                                      |
+----------+----------------------------------------------------+
|Parametros|#                                                   |
+----------+----------------------------------------------------+
|Retorno   |#                                                   |
+----------+----------------------------------------------------+
|Uso       |Compras - Sirtec                                    |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
*/             
User Function STCA011 
Local j := 0
Local oModel := FWModelActive()
Local oGrid := oModel:GetModel("DA1DETAIL")
Local nPos1 := aScan(oGrid:aHeader,{|x|alltrim(x[2]) == "DA1_YQUSS"}) //aScan(aHeader, { |x| AllTrim(x[02]) == "DA1_YQUSS" }) 
Local nPos2 := aScan(oGrid:aHeader,{|x|alltrim(x[2]) == "DA1_PRCVEN"})
Local nPos3 := aScan(oGrid:aHeader,{|x|alltrim(x[2]) == "DA1_VLRDES"})
Local nPos4 := aScan(oGrid:aHeader,{|x|alltrim(x[2]) == "DA1_PERDES"}) 

//Declaracao de Variaveis Private                                           
//Private nTemp := 0     


//Para controle da rotina
//nTemp := n

//Percorre o aCols
For j := 1 To Len(ogrid:Acols)
	
	//Caso a quantidade esteja preenchida
	If ogrid:getvalue("DA1_YQUSS") > 0
		/*
		//Altera valor da variavel de controle do aCols
		n := j
		
		
		//Cria variaveis para execução dos gatilhos
		y := 0
		For y:= 1 to Len(oGrid:aHeader)
			If ! oGrid:aHeader[Y][2] $ 'DA1_ALI_WT/DA1_REC_WT'
		   		CriaVar(oGrid:aHeader[y,2],.F.)
				M->&(oGrid:aHeader[y,2]) := GdFieldGet(oGrid:aHeader[y,2],j)		
			Endif
		Next y	
		
		//Executa os gatilhos do campo Tabela
		y := 0	
		For y:= 1 to Len(oGrid:aHeader)
			If Alltrim(oGrid:aHeader[y,2]) $ "DA1_YQUSS" .and. ExistTrigger(oGrid:aHeader[y,2])
				RunTrigger(2,j)
			EndIf
		Next y
		*/
		
		ogrid:GoLine(j)
		ogrid:setvalue("DA1_VLRDES",0)
		ogrid:setvalue("DA1_PERDES",0)
		ogrid:setvalue("DA1_PRCVEN",Round( ogrid:getvalue("DA1_YQUSS") * M->DA0_YVUSS,2)  )

	Endif      
Next J

ogrid:GoLine(1)
//n := nTemp

//Objeto contendo a getdados
//oGetDad:oBrowse:Refresh()

Return(M->DA0_YVUSS)

/*
+----------+------------+-------------------+------+------------+
|Programa  |STCA011A    | Microsiga Vitória | Data | 01.08.2007 |
+----------+------------+-------------------+------+------------+
|Descrição |Valida a edição do campo                            |
|          |                                                    |
+----------+----------------------------------------------------+
|Sintaxe   |Verifica se usuário está habilitado                 |
+----------+----------------------------------------------------+
|Parametros|#                                                   |
+----------+----------------------------------------------------+
|Retorno   |Logico                                              |
+----------+----------------------------------------------------+
|Uso       |Compras - Sirtec                                    |
+----------+----------------------------------------------------+
|        ATUALIZAÇÕES SOFRIDAS DESDE A CONSTRUÇÃO INCIAL        |
+------------+--------+-----------+-----------------------------+
|Função      |Data    |Programador| Mutivo da Alteraçao         |
+------------+--------+-----------+-----------------------------+
|            |00.00.00|           |                             |
+------------+--------+-----------+-----------------------------+
*/             
User Function STCA011A

	//Declaracao de variveis Locais
	Local lRet := .F.  							//Retorno esperado
	Local MV_YUSRUSS := GetMv("MV_YUSRUSS")		//Usuário habilitados

	If __CUSERID $ MV_YUSRUSS
		lRet := .T.	
	Endif	

Return lRet 