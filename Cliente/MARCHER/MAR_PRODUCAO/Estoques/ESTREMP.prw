#include 'protheus.ch'
/*/{Protheus.doc} EstrEmp
//TODO Gera relação de divergências entre estutura e Empenho
@author solutio02
@since 30/09/2019
@version 1.0
@return character, cMsg = Mensagem de crítica
@param cCod, characters, descricao
@param cRev, characters, descricao
@type function
/*/

Static lPCPREVATU	:= FindFunction('PCPREVATU')  .AND.  SuperGetMv("MV_REVFIL",.F.,.F.)

User Function EstrEmp(cOP,cProduto,cRev,nQtdPai,dDtRefOrig,cOpcOrig)

	Local aAreaSC2 := SC2->(GetArea())
	Local cMsg		:= ""

	//Local cTxt		:= ""
	//Local x

	Local  lMA_LOGD4AL	:= SuperGetMV("MA_LOGD4AL",,.T. )  //Loga Explosão de Empenho de tudo ou somente das divergências
	Local cAliasSQL 	:= GetNextAlias()


	Default cOp			:= ""
	Default cProduto 	:= Criavar("C2_PRODUTO")
	Default cRev    	:= Criavar("C2_REVISAO",.F.) //Revisão do Produto
	Default dDtRefOrig 	:= dDatabase	// Data de Referência
	Default cOpcOrig	:= Criavar("C2_OPC"	,.F.) //Opcional
	Default nQtdPai		:= 1 //Quantidade Pai (quantidade da OP para multiplicar)

	Private cENTER		:= CHR(13) + CHR(10)
	Private aParamBox := {}

	Private aEstruOri := {} // Explosão da estutura de produtos
	Private aEstruOP  := {} // Epllosão da Estutura de OP´s


	//cProduto := '08203065'
	//cRevOrig := '007'


	IF Empty(cProduto+cRev)

		If Empty(cOp)

			Perg()
			//cProduto := MV_PAR01
			cOp := MV_PAR01
			If Empty(cRev)
				cRev := IniRev(cProduto)
			Endif

		Endif

		DBSelectArea("SC2");DBSetOrder(1) //Ordem SC2
		If !SC2->(DBSeek(FWxFilial("SC2") + cOp ))
			cMsg += " -- Não localizado para análise Filial/OP: " + FWxFilial("SC2") + "/"+ cOp + cENTER
			Return cMsg
		Else
			cRevOrig 	:= SC2->C2_REVISAO
			cProduto	:= SC2->C2_PRODUTO
			nQtdPai		:= SC2->C2_QUANT
		Endif

	Endif

	//Monta Estrutura do Produto
	dbSelectArea("SG1")
	dbSetOrder(1)
	SG1->(DBSeek(FWxFilial("SG1")+cProduto))


	If SC2->C2_BATCH <> 'S' .and. SC2->C2_SEQPAI == SPACE(TamSX3("C2_SEQPAI")[1]) // Não Explodido
		cMsg += " -- OP Pai (" + SC2->C2_NUM + ")  não foi explodida" + cENTER
	Endif

	//Explosão do Empenho da OP


	aLog := v3EXPEstr() //Deve estar posicionado no SC2

	aSetField := {}



	aTamSX3 := TamSX3("ZX4_QUANT")
	AADD(aSetField,{"ZX4_QUANT",aTamSX3[3],aTamSX3[1],aTamSX3[2]})

	aTamSX3 := TamSX3("ZX4_QTDEMP")
	AADD(aSetField,{"ZX4_QTDEMP",aTamSX3[3],aTamSX3[1],aTamSX3[2]})


	aTamSX3 := TamSX3("ZX4_DATA")
	AADD(aSetField,{"ZX4_DATA",aTamSX3[3],aTamSX3[1],aTamSX3[2]})


	aTamSX3 := TamSX3("ZX4_DATAREF")
	AADD(aSetField,{"ZX4_DATAREF",aTamSX3[3],aTamSX3[1],aTamSX3[2]})



	cSql := 'SELECT * FROM ' + RetSqlName("ZX4") + " WHERE ZX4_OP = '" + aLog[1] + "' AND ZX4_DATA = '" + DTOS(aLog[2])+ "' AND ZX4_HORA = '" + aLog[3] + "' AND D_E_L_E_T_ <> '*' "
	cSql += " AND ZX4_QUANT > 0 "

	IF !lMA_LOGD4AL
		cSql += " AND ZX4_DIVERG = 'S' "
	ENDIF
	MPSysOpenQuery( cSql,cAliasSQL,aSetField )


	If (cAliasSQL)->(EOF())
		If !IsInCallStack("MATA650") .and. Empty(cMsg)
			MSGInfo(" Não localizado divergências na OP","Divergências")
		Endif

	Else
		While (cAliasSQL)->(!Eof())
			cMsg += " OP: " + (cAliasSQL)->ZX4_OP + cENTER
			cMsg += " Nível/Seq: " + (cAliasSQL)->ZX4_NIVEL + cENTER
			cMsg += " Prod.Pai: " + (cAliasSQL)->ZX4_CODIGO + cENTER
			cMsg += " Componente: " + (cAliasSQL)->ZX4_COMP + cENTER
			cMsg += " Qtd.Estrutura: " + STR((cAliasSQL)->ZX4_QUANT) + cENTER
			cMsg += " Qtd.Empenhada: " + STR((cAliasSQL)->ZX4_QTDEMP) + cENTER
			If !Empty( (cAliasSQL)->ZX4_MOTZERO)
				cMsg += " Inconsistência: "  + (cAliasSQL)->ZX4_DESCZ + cENTER
			ElseIf  (cAliasSQL)->ZX4_QUANT <> (cAliasSQL)->ZX4_QTDEMP
				cMsg += " Inconsistência: Quantidade Empenhada"  + cENTER
			Else
				cMsg += " Inconsistência: Sem inconsistência"  + cENTER
			Endif
			cMsg += " Usuario|Data-Hora: " + AllTrim((cAliasSQL)->ZX4_USER) + " | " + DTOC((cAliasSQL)->ZX4_DATA) + "-" + (cAliasSQL)->ZX4_HORA  + cENTER
			cMsg += " Rotina " + (cAliasSQL)->ZX4_ROTINA + cENTER

			cMsg += "----------------------------------------------- " + cENTER


			(cAliasSQL)->(DBSkip())
		Enddo


	Endif
	(cAliasSQL)->(DBCloseArea())
	SG1->(RestArea(aAreaSC2))

Return cMsg


Static Function Perg()
	Local aRet
	// --------------------------------------------------------------
	// Abaixo está a montagem do vetor que será passado para a função
	// --------------------------------------------------------------

	aAdd(aParamBox,{1,"OP ",space(tamsx3("C2_NUM")[1]),"","","SC2","",0,.F.}) // Tipo caractere
	//aAdd(aParamBox,{1,"Até OP",space(tamsx3("C2_NUM")[1]),"","","SC2","",0,.F.}) // Tipo caractere
	//aAdd(aParamBox,{10,"OP",Criavar("C2_NUM"),"SC2",20,"C",6,".T."})
	// Tipo 10 -> Range de busca
	//            [2] = Título
	//            [3] = Inicializador padrão
	//            [4] = Consulta F3
	//            [5] = Tamanho do GET
	//            [6] = Tipo do dado, somente (C=caractere e D=data)
	//            [7] = Tamanho do espaço
	//            [8] = Condição When

	If ParamBox(aParamBox,"Analisa OP´s Explodidas...",@aRet)
		/*
		For i:=1 To Len(aRet)
		MsgInfo(aRet[i],"Opção escolhida")
		Next
		*/
	Endif

Return aRet


Static Function IniRev(cProduto)
	Local cRevAtu := ""

	Default cProduto := SG1->G1_COD


	DBSelectArea("SB1")
	SB1->(dbSetOrder(1))
	If SB1->(dbSeek(FWxFilial("SB1")+cProduto))
		cRevAtu := IIF(lPCPREVATU , PCPREVATU(SB1->B1_COD), SB1->B1_REVATU)
	Else
		cRevAtu := CriaVar('B1_REVATU')
	EndIf



Return cRevAtu

//--------------------------
Static Function v3EXPEstr() //deve estar posicionado no SC2
	Local aAreaSB1      := SB1->(GetArea())
	Local aAreaSG1      := SG1->(GetArea())
	Local lAsShow       := .T. //nil //.F. //Monta a estrutura exatamente como visualizado na tela (pode ser Nil).
	Local lPreEstru     := .F. //Determina se será considerada uma pré-estrutura (SGG) em vez de uma estrutura (SG1) (pode ser Nil).
	Local lVldData      := .T. //Consiste na estrutura se os componentes estão fora das datas de início e fim (DEFAULT=True).
	Local oTempTable    := NIL //Nome do objeto utilizado para tabela temporária (pode ser Nil).

	Local _cUsuario     := If(!Empty(CUSERNAME),CUSERNAME,PswChave( RetCodUsr()))//FwGetUserName( RetCodUsr() )
	Local _cRotina      := Alltrim(FunName())
	Local _dData        := Date()
	Local _cHora        := Time()


	Local cSql          := ""
	Local cAliasSQL     := GetNextAlias() // Gera novo Alias para Consulta
	Local nQtdEmp       := 0
	Local lGeraOPI      := SuperGETMV("MV_GERAOPI",,.F.)

	Private nEstru      := 0 // Como ESTRUT2 é uma funcao recursiva, precisa ser criada uma variavel private nEstru com valor 0 antes da chamada da função
	Private cAliasEstru := GetNextAlias() // Gera novo Alias para ser utilizado na tabela temporária




	POSICIONE("SB1",1,xFilial("SB1"+ SC2->C2_PRODUTO),'SB1->B1_REVATU')

	//ESTRUT2 ( < cProduto>, < nQuantidade>, < cAliasEstru>, < oTempTable>, [ lAsShow], [ lPreEstru], [lVldData] )

	//ESTRUT2(SC2->C2_PRODUTO, SC2->C2_QUANT, cAliasEstru,  @oTempTable,  lAsShow,  lPreEstru, lVldData)
	//FimEstrut2(cAliasEstru,oTempTable)

	ESTRUT3(SC2->C2_PRODUTO, SC2->C2_QUANT, SC2->C2_REVISAO, SC2->C2_EMISSAO,  cAliasEstru,  @oTempTable,  lAsShow,  lPreEstru, lVldData)

	(cAliasEstru)->(DBGoTop())

	While (cAliasEstru)->(!EOF())


		//If  (cAliasEstru)->QUANT > 0
		cSql := "SELECT  D4_QTDEORI, R_E_C_N_O_ NREG  FROM " + RetSqlName("SD4")
		cSql += "	WHERE D4_FILIAL = '" + xFilial("SD4") + "' AND D_E_L_E_T_  <> '*' AND D4_OP LIKE '" + SC2->C2_NUM + "%"+  (cAliasEstru)->NIVEL + "' AND D4_PRODUTO = '"+  (cAliasEstru)->CODIGO +"' AND D4_COD = '"+  (cAliasEstru)->COMP +"'"

		MPSysOpenQuery( cSql,cAliasSQL )

		If Empty((cAliasSQL)->D4_QTDEORI)
			nQtdEmp := 0
		Else
			nQtdEmp := (cAliasSQL)->D4_QTDEORI
		Endif

		RecLock(cAliasEstru,.F.)
		Replace OP    		With SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN
		Replace REVOP		With SC2->C2_REVISAO
		Replace TPOP		With SC2->C2_TPOP
		Replace QTDEMP 		With nQtdEmp
		Replace RECSD4   	With (cAliasSQL)->NREG
		Do Case
		Case !Empty((cAliasEstru)->MOTZERO)
			Replace DIVERG 		With 'N'
		Case !lGeraOPI .AND.  (cAliasEstru)->NIVEL <> '001'
			Replace DIVERG 		With 'N'
		Case SC2->C2_REVISAO <>  (cAliasEstru)->REVISAO .AND. Empty(nQtdEmp)
			Replace DIVERG 		With 'N'
			Replace MOTZERO		With 9
			Replace DESCZ		With "Componente fora revisão OP"
		Case nQtdEmp <> (cAliasEstru)->QUANT
			Replace DIVERG 		With 'S'
			Replace MOTZERO		With 9
			Replace DESCZ		With "Quantidade Empenhada divergente"
		OTHERWISE
			Replace DIVERG 		With 'N'
		EndCase
		MsUnlock()
		//Endif
		(cAliasEstru)->(DBSkip())

	End

	DBSelectArea("ZX4") //Log de Explosão de OP
	(cAliasEstru)->(DBGoTop())

	While (cAliasEstru)->(!EOF())

		ZX4->(RecLock("ZX4",.T.))
		ZX4->ZX4_FILIAL 	:= xFilial("ZX4")
		ZX4->ZX4_OP	   		:= (cAliasEstru)->OP
		If Type("ZX4->ZX4_TPOP") <> "U"
			ZX4->ZX4_TPOP		:= (cAliasEstru)->TPOP
		Endif
		ZX4->ZX4_REVOP		:= (cAliasEstru)->REVOP
		ZX4->ZX4_NIVEL		:= (cAliasEstru)->NIVEL
		ZX4->ZX4_CODIGO 	:= (cAliasEstru)->CODIGO
		ZX4->ZX4_COMP		:= (cAliasEstru)->COMP
		ZX4->ZX4_QUANT		:= (cAliasEstru)->QUANT
		ZX4->ZX4_TRT		:= (cAliasEstru)->TRT
		ZX4->ZX4_GROPC		:= (cAliasEstru)->GROPC
		ZX4->ZX4_OPC		:= (cAliasEstru)->OPC
		ZX4->ZX4_RECSG1		:= (cAliasEstru)->REGISTRO
		ZX4->ZX4_DATAREF	:= (cAliasEstru)->DATAREF
		ZX4->ZX4_REVISAO	:= (cAliasEstru)->REVISAO
		ZX4->ZX4_MOTZERO	:= (cAliasEstru)->MOTZERO
		ZX4->ZX4_DESCZ		:= (cAliasEstru)->DESCZ
		ZX4->ZX4_QTDEMP		:= (cAliasEstru)->QTDEMP
		ZX4->ZX4_DIVERG		:= (cAliasEstru)->DIVERG
		ZX4->ZX4_RECSD4		:= (cAliasEstru)->RECSD4
		ZX4->ZX4_ROTINA		:= _cRotina
		ZX4->ZX4_USER 		:= _cUsuario
		ZX4->ZX4_DATA		:= _dData
		ZX4->ZX4_HORA		:= _cHora
		ZX4->(MsUnLock())

		(cAliasEstru)->(DBSkip())

	End

	//oTempTable:GetRealName() //Pega o nome real da tabela temporária para fazer
	FimEstrut2(cAliasEstru,oTempTable) //Encerra arquivo utilizado na explosao de uma estrutura


	SG1->(RestArea(aAreaSG1))
	SB1->(RestArea(aAreaSB1))



	If Select(cAliasSQL) > 0
		(cAliasSQL)->(DBCloseArea())
	EndIf
Return {SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN,_dData,_cHora}




//-------------------------
Static Function Estrut3(cProduto,nQuant,cRevisao,dDataStru,cAliasEstru,oTempTable,lAsShow,lPreEstru,lVldData,lVldRev,lVlOpc)

	Local aAreaSB1 := SB1->(GetArea())
	Local cMotivo := ""
	Local nMotivo := 0

	LOCAL nRegi:=0,nQuantItem:=0
	LOCAL aCampos:={},aTamSX3:={},lAdd:=.F.
	LOCAL nRecno
	LOCAL cCodigo,cComponente,cTrt,cGrOpc,cOpc
	DEFAULT lPreEstru  := .F.
	DEFAULT oTempTable := NIL
	DEFAULT lVldData   := .T.
	DEFAULT lVldRev    := .T.
	DEFAULT lVlOpc    := .T.

	cAliasEstru:=IF(cAliasEstru == NIL,"ESTRUT",cAliasEstru)
	nQuant:=IF(nQuant == NIL,1,nQuant)
	lAsShow:=IF(lAsShow==NIL,.F.,lAsShow)
	nEstru++
	If nEstru == 1
		// Cria arquivo de Trabalho
		//--- CUSTOMIZADOS
		aTamSX3:=TamSX3("D4_OP")
		AADD(aCampos,{"OP","C",aTamSX3[1],0})
		AADD(aCampos,{"NIVEL","C",3,0})
		//--FIM CUSTOMIZADOS

		//AADD(aCampos,{"NIVEL","C",6,0})
		aTamSX3:=TamSX3(If(lPreEstru,"GG_COD","G1_COD"))
		AADD(aCampos,{"CODIGO","C",aTamSX3[1],0})
		aTamSX3:=TamSX3(If(lPreEstru,"GG_COMP","G1_COMP"))
		AADD(aCampos,{"COMP","C",aTamSX3[1],0})
		aTamSX3:=TamSX3(If(lPreEstru,"GG_QUANT","G1_QUANT"))
		AADD(aCampos,{"QUANT","N",Max(aTamSX3[1],18),aTamSX3[2]})
		aTamSX3:=TamSX3(If(lPreEstru,"GG_TRT","G1_TRT"))
		AADD(aCampos,{"TRT","C",aTamSX3[1],0})
		aTamSX3:=TamSX3(If(lPreEstru,"GG_GROPC","G1_GROPC"))
		AADD(aCampos,{"GROPC","C",aTamSX3[1],0})
		aTamSX3:=TamSX3(If(lPreEstru,"GG_OPC","G1_OPC"))
		AADD(aCampos,{"OPC","C",aTamSX3[1],0})
		// NUMERO DO REGISTRO ORIGINAL
		AADD(aCampos,{"REGISTRO","N",14,0})

		//--- CUSTOMIZADOS
		AADD(aCampos,{"DATAREF","D",8,0})
		aTamSX3:=TamSX3("C2_REVISAO")
		AADD(aCampos,{"REVISAO","C",aTamSX3[1],0}) // Revisão Estrutura
		AADD(aCampos,{"REVOP","C",aTamSX3[1],0})   // Revisão op
		AADD(aCampos,{"MOTZERO","N",3,1})
		AADD(aCampos,{"DESCZ","C",40,0}) //Campo de Log Adicionado, motivo do zeramento
		AADD(aCampos,{"TPOP","C",1,0})
		aTamSX3:=TamSX3("D4_QTDEORI")
		AADD(aCampos,{"QTDEMP","N",aTamSX3[1],aTamSX3[2]})
		AADD(aCampos,{"DIVERG","C",1,0})
		AADD(aCampos,{"RECSD4","N",14,0})
		//--FIM CUSTOMIZADOS



		oTempTable := FWTemporaryTable():New( cAliasEstru )
		oTempTable:SetFields( aCampos )
		oTempTable:AddIndex("INDICE1", {"NIVEL","CODIGO","COMP","TRT"} )
		oTempTable:Create()
	EndIf

	dbSelectArea(If(lPreEstru,"SGG","SG1"))
	dbSetOrder(1)
	dbSeek(xFilial()+cProduto)
	While !Eof() .And. If(lPreEstru,GG_FILIAL+GG_COD,G1_FILIAL+G1_COD) == xFilial()+cProduto
		nRegi:=Recno()
		cCodigo    :=If(lPreEstru,GG_COD,G1_COD)
		cComponente:=If(lPreEstru,GG_COMP,G1_COMP)
		cTrt       :=If(lPreEstru,GG_TRT,G1_TRT)
		cGrOpc     :=If(lPreEstru,GG_GROPC,G1_GROPC)
		cOpc       :=If(lPreEstru,GG_OPC,G1_OPC)
		If cCodigo != cComponente
			lAdd:=.F.
			If !(&(cAliasEstru)->(dbSeek(StrZero(nEstru,3)+cCodigo+cComponente+cTrt))) .Or. (lAsShow) // !(&(cAliasEstru)->(dbSeek(StrZero(nEstru,6)+cCodigo+cComponente+cTrt))) .Or. (lAsShow)
				nMotivo := 0 //Zera variável para ser alimentada em seguida
				nQuantItem:=ExplEstr(nQuant,dDataStru,nil,cRevisao,@nMotivo,lPreEstru,,,,,,lVldData,lVlOpc,,lVldRev)
				//IF nQuantItem != 0
				DO CASE
				CASE nQuantItem > 0
					cMotivo := ' '
				CASE  nMotivo == 1
					cMotivo := 'Componente fora das datas inicio / fim'
				CASE  nMotivo == 2
					cMotivo := 'Componente fora dos grupos de opcionais'
				CASE  nMotivo == 3
					cMotivo := 'Componente fora das revisoes'
				OTHERWISE
					cMotivo := 'Produto Bloqueado ou Fantasma'
				ENDCASE
				RecLock(cAliasEstru,.T.)
				Replace NIVEL    With StrZero(nEstru,3) //StrZero(nEstru,6)
				Replace CODIGO   With cCodigo
				Replace COMP     With cComponente
				Replace QUANT    With nQuantItem
				Replace TRT      With cTrt
				Replace GROPC    With cGrOpc
				Replace OPC      With cOpc
				Replace DATAREF  With dDataStru
				Replace REVISAO  With cRevisao
				Replace MOTZERO  With nMotivo
				Replace DESCZ    With cMotivo
				Replace REGISTRO With If(lPreEstru,SGG->(Recno()),SG1->(Recno()))
				MsUnlock()
				lAdd:=.T.
				//EndIf
				dbSelectArea(If(lPreEstru,"SGG","SG1"))
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se existe sub-estrutura                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nRecno:=Recno()
			IF dbSeek(xFilial()+cComponente)
				cCodigo:=If(lPreEstru,GG_COD,G1_COD)
				If nQuantItem != 0
					//Estrut2(cCodigo,nQuantItem,cAliasEstru,@oTempTable,lAsShow,lPreEstru,lVldData,lVldRev,lVlOpc)
					cRevComp := POSICIONE("SB1",1,xFilial("SB1")+ cComponente,'SB1->B1_REVATU')
					Estrut3(cCodigo,nQuantItem,cRevComp,dDataStru,cAliasEstru,@oTempTable,lAsShow,lPreEstru,lVldData,lVldRev,lVlOpc)
					nEstru --
				EndIf
			Else
				MsGoto(nRecno)
				If !(&(cAliasEstru)->(dbSeek(StrZero(nEstru,3)+cCodigo+cComponente+cTrt))) .Or. (lAsShow.And.!lAdd)
					//nQuantItem:=ExplEstr(nQuant,nil,nil,nil,nil,lPreEstru,,,,,,lVldData,lVlOpc,,lVldRev)
					nMotivo := 0 //Zera variável para ser alimentada em seguida
					nQuantItem:=ExplEstr(nQuant,dDataStru,nil,cRevisao,@nMotivo,lPreEstru,,,,,,lVldData,lVlOpc,,lVldRev)
					//If nQuantItem != 0
					DO CASE
					CASE nQuantItem > 0
						cMotivo := ' '
					CASE  nMotivo == 1
						cMotivo := 'Componente fora das datas inicio / fim'
					CASE  nMotivo == 2
						cMotivo := 'Componente fora dos grupos de opcionais'
					CASE  nMotivo == 3
						cMotivo := 'Componente fora das revisoes'
					OTHERWISE
						cMotivo := 'Produto Bloqueado ou Fantasma'
					ENDCASE
					RecLock(cAliasEstru,.T.)
					Replace NIVEL    With StrZero(nEstru,3) //StrZero(nEstru,6)
					Replace CODIGO   With cCodigo
					Replace COMP     With cComponente
					Replace QUANT    With nQuantItem
					Replace TRT      With cTrt
					Replace GROPC    With cGrOpc
					Replace OPC      With cOpc
					Replace DATAREF  With dDataStru
					Replace REVISAO  With cRevisao
					Replace MOTZERO  With nMotivo
					Replace DESCZ    With cMotivo
					Replace REGISTRO With If(lPreEstru,SGG->(Recno()),SG1->(Recno()))
					MsUnlock()
					//EndIf
					dbSelectArea(If(lPreEstru,"SGG","SG1"))
				EndIf
			Endif
		EndIf
		MsGoto(nRegi)
		dbSkip()
	Enddo

	SB1->(RestArea(aAreaSB1))
Return NIL
