#Include 'Protheus.ch'
#INCLUDE "TOPCONN.ch"    
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ VldCamp    ºAutor  ³ MARCIO Q BORGES º Data ³  08/01/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ PROGRAMA GENÉRICO PARA EXECUÇÃO DE VALIDAÇÕES DE USUÁRIO   º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Marcher                                                    º±±       
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function VldCamp(cVar)
	Local lRet := .T.
	Local xReturn := 0
	Local xConteudo
	//Local lInDark := HelpInDark( .T. )    //Desabilita a apresentação do Help

	Default cVar      := ReadVar()

	cVar:= UPPER(cVar)
	xConteudo := &(cVar)


	/********
	*  SC6  *
	*********/
	If  cVar $ "M->C6_QTDVEN/M->C6_PRODUTO/M->C6_OPER" //xReturn := GDFieldGet("C6_PRCVEN",n)
		//FORÇA REDIGITAÇÃO DA QUANTIDADE PARA REPROCESSAR VALORES
		/*
		__READVAR := "M->C6_QTDVEN"

		IIF(ExistTrigger("C6_QTDVEN"), RunTrigger(2,n,,"C6_QTDVEN"),"")
		__READVAR := cVar
		*/


		If !(gdFieldGet('C6_OPER',n, (__READVAR=="M->C6_OPER")) $ '51/52')
			//Retorna preço de ultima compra
			cSql := "SELECT "
			xReturn := Posicione("SB1",1,FWxFilial("SB1")+ GDFieldGet("C6_PRODUTO",n,(__READVAR=="M->C6_PRODUTO")), "SB1->B1_UPRC")
		Else
			//busca na tabela de preço
			cSql := "SELECT ISNULL(DA1_PRCVEN,0) DA1_PRCVEN"
			cSql += "	FROM "+ RetSqlName("DA0")+" DA0 INNER JOIN  "+ RetSqlName("DA1")+" DA1"
			cSql += '		ON DA0_FILIAL = DA1_FILIAL'
			cSql += '		AND DA0_CODTAB = DA1_CODTAB'
			cSql += "		AND DA0.D_E_L_E_T_ <> '*'"
			cSql += "		AND DA0_ATIVO = '1'"
			cSql += "			WHERE DA1_FILIAL = '"+ FWxFilial("DA1")+ "' AND DA1_CODTAB = '"+ M->C5_TABELA +"' AND DA1_CODPRO = '"+gdFieldGet('C6_PRODUTO',n, (__READVAR=="M->C6_PRODUTO")) +"' AND DA1.D_E_L_E_T_ <> '*'"
			
			MyQuery( cSql , "_TAB_PRC" )
			
			xReturn := _TAB_PRC->DA1_PRCVEN
			DBCloseArea("_TAB_PRC")
		Endif	
		If  "C6_QTDVEN" $ __READVAR 

			GDFieldPut("C6_PRUNIT",xReturn,n)
			M->C6_PRUNIT := GDFieldGet("C6_PRUNIT",n)
			GDFieldPut("C6_PRCVEN",xReturn,n)
			M->C6_PRCVEN := GDFieldGet("C6_PRCVEN",n)
			GDFieldPut("C6_VALOR",GDFieldGet("C6_PRUNIT",n) * M->C6_QTDVEN,n)
			M->C6_PRCVEN := GDFieldGet("C6_VALOR",n)
		ElseIf "C6_OPER" $ __READVAR .or. "C6_PRODUTO" $ __READVAR

			GDFieldPut("C6_PRUNIT",xReturn,n)
			M->C6_PRUNIT := xReturn
			GDFieldPut("C6_PRCVEN",xReturn,n)
			M->C6_PRCVEN := xReturn
			GDFieldPut("C6_VALOR",GDFieldGet("C6_PRUNIT",n) * gdFieldGet('C6_QTDVEN',n),n)
			M->C6_PRCVEN := GDFieldGet("C6_VALOR",n)
		Endif



	Endif

	__READVAR := cVar
	//GETDREFRESH()
	//HelpInDark(lInDark) //Reabilita estado anterior do Help
Return lRet


//####################################
//## Consulta SQL ao banco de dados ##
//####################################
Static Function MyQuery( cQuery , cursor )

   IF SELECT( cursor ) <> 0
      dbSelectArea(cursor)
	  DbCloseArea(cursor)
   Endif

   TCQUERY cQuery NEW ALIAS (cursor)

Return
