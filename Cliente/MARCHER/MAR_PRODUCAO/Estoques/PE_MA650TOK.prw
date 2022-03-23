#include 'protheus.ch'
//#include 'parmtype.ch'

User Function MA650TOK()
	Local lRet 		:= .T.
	Local cENTER	:= CHR(13)+ CHR(10)
	Local nStart	:= Seconds()
	Local cErro		:= ""
	Local cAliasTemp := GetNextAlias()
	//Local cProduto  := M->C2_PRODUTO
	//Local dEmissao	:= M->C2_EMISSAO

	IF M->C2_TPOP == "F" .Or. Posicione('SB1',1,xFilial("SB1")+M->C2_PRODUTO,"SB1->B1_REVATU") == ''
        // Caso seja uma OP Prevista ou então a revisão do produto esteja vazia (não tem estrutura)
		cSql := ""
		cSql += "SELECT MAX(G5_REVISAO) ULT_REV   FROM " + RetSqlName("SG5") + " WHERE G5_FILIAL = '"+ FWxFilial("SG5") +"' AND D_E_L_E_T_ <> '*' AND G5_PRODUTO = '" + M->C2_PRODUTO + "' AND G5_DATAREV <= '" + DTOS(M->C2_EMISSAO) + "' "
		MPSysOpenQuery( cSql, cAliasTemp,)

		IF EMPTY((cAliasTemp)->ULT_REV) //Se não localizou revisão de estrutura não permite continuar
			cErro+= "-  Não localizado revisão de estrutura válida na data de emissão da OP."  + cENTER
			ApMsgStop(cErro)
			
			Return .F.
		ElseIF M->C2_DATPRI < M->C2_EMISSAO //Data de inicio Produção não pode ser menor que data da emissao da OP
			cErro+= "-  'Data Prev. Ini' da Produção da OP não pode ser menor que data de Emissão."  + cENTER
		ELSEIF M->C2_REVISAO < (cAliasTemp)->ULT_REV 
			If !ApMsgNoYes("A revisão da estrutura informada (" + M->C2_REVISAO + ") é menor do que a revisão vigente (" + (cAliasTemp)->ULT_REV  + "). Continuar gerando a OP na revisão informada?")
				Return .F.
			Endif
		ENDIF

		If !Empty(cErro)
			cErro := "Revise inconsistência(s) a seguir:" + cENTER + cErro
			FwLogMsg("WARN" , /*cTransactionId*/, "MA650TOK", FunName(), "", "01",cErro, 0, (nStart - Seconds()), {}) // nStart é declarada no inicio da função			
			lRet := .F.
		Endif
		(cAliasTemp)->(DbCloseArea())
	ENDIF

Return lRet
