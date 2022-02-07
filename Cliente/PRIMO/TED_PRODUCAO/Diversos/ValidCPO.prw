#INCLUDE "Protheus.ch"



/*/{Protheus.doc} ValidCPO
Tedesco - Validação de Campos. Executado pelo Valid de USUÁRIO
@type function
@version 25
@author Márcio Borges
@since 05/01/2021
@return logical, Retorno da vlidação 
/*/
User Function ValidCPO(cCampo)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea			:= GetArea()
	Local cRotina   	:= FUNNAME()
	Local lViaExecauto 	:= IsBlind()
	Local cERROMASTER 	:= ""

	Local xReturn := 0
	Local xConteudo

	//Validação PESO
	Local lPESONFS := SuperGetMV("ES_PESONFS",.F.,.F.) //Ativa Funcionalidade de Peso Liq/Bruto na Filial
	Local dMVUlmes := SUPERGETMV("MV_ULMES",.f.,SPACE(8))

	Local cProd			:= "" //Produto
	Local cTp   		:= "" //Tipo Produto

	//Validação TES
	Local lPodEm3 		:= .F.

	Private lReturn 	:= .T. //Por padrão validação retorna Verdadeiro

	Default cCampo 		:= Alltrim(ReadVar())  // exemplo  "M->ZZB_AREA"

	cCampo 		:= UPPER(cCampo)
	xConteudo 	:= &(cCampo)

	DO CASE
	/*
	CASE 'D4_COD' $ cCampo
		IF Alltrim(ReadVar()) == AllTrim(GdFieldGet("D4_COD"))
			lReturn := .T.
		ElseIf cRotina == 'MATA381' .AND. !lViaExecauto
			If MSGYESNO("Deseja Trocar o empenho do Produto " + Alltrim(GdFieldGet("D4_COD")) + " para o produto " + Alltrim(ReadVar()) + " ?")
				lReturn := .T.
				//msgBox("Use o código do Centro de Custo completo ou o grupo de Centro de Custo ( 3 primeiros caracteres)","Informação","INFO")
				
			Endif
		Endif
	*/

	CASE 'C6_TPESO' $ cCampo
		If lPESONFS
			cProd  := GDFieldGet("C6_PRODUTO")

			//veririca se foi informado quantidade
			If Empty(GDFieldGet("C6_QTDVEN"))
				If !lViaExecauto
					MsgInfo("Antes de informar o peso, informe a Quantidade do Item","Campo " + cCampo)
					lReturn := .F.
				Else
					cERROMASTER := "(" + cRotina + ") Antes de informar o peso, informe a Quantidade do Item - Campo " + cCampo
					AutoGrLog(cERROMASTER)
				Endif
			Endif
			cTP  := Posicione( "SB1", 1, FWxFilial("SB1") + cProd, "SB1->B1_TIPO" )
			// Verifica se já foi informado a Quantidade do Produto


			IF Empty(xConteudo) .AND. cTP == "PA"  .AND. Posicione( "SF4", 1, FWxFilial("SF4") +  GDFieldGet("C6_TES"), "SF4->F4_ESTOQUE" ) == 'S'
				If !lViaExecauto
					MsgInfo("É obrigatório informar Peso Liquido para Produto do tipo PA, em TES que movimente estoque","Campo " + cCampo)
					lReturn := .F.
				Else
					cERROMASTER := "(" + cRotina + ") É obrigatório informar Peso Liquido para Produto do tipo PA, em TES que movimente estoque - Campo " + cCampo
					AutoGrLog(cERROMASTER)
				Endif
			ENDIF
		Endif

	CASE 'C6_TPBRUTO' $ cCampo
		If lPESONFS
			cProd  := GDFieldGet("C6_PRODUTO")

			//veririca se foi informado quantidade
			If Empty(GDFieldGet("C6_QTDVEN"))
				If !lViaExecauto
					MsgInfo("Antes de informar o peso, informe a Quantidade do Item","Campo " + cCampo)
					lReturn := .F.
				Else
					cERROMASTER := "(" + cRotina + ") Antes de informar o peso, informe a Quantidade do Item - Campo " + cCampo
					AutoGrLog(cERROMASTER)
				Endif
			Endif

			cTP  := Posicione( "SB1", 1, FWxFilial("SB1") + cProd, "SB1->B1_TIPO" )
			IF Empty(xConteudo) .AND. cTP == "PA"  .AND. Posicione( "SF4", 1, FWxFilial("SF4") +  GDFieldGet("C6_TES"), "SF4->F4_ESTOQUE" ) == 'S'
				If !lViaExecauto
					MsgInfo("É obrigatório informar Peso Bruto para Produto do tipo PA, em TES que movimente estoque","Campo " + cCampo)
					lReturn := .F.
				Else
					cERROMASTER := "(" + cRotina + ") É obrigatório informar Peso Bruto para Produto do tipo PA, em TES que movimente estoque - Campo " + cCampo
					AutoGrLog(cERROMASTER)
				Endif
			ElseIf  xConteudo < GDFieldGet("C6_TPESO")
				If !lViaExecauto
					MsgInfo("O T.Peso Bruto (C6_TPBRUTO) informado Não pode ser menor do que o peso Líquido","Campo Peso Bruto")
					lReturn := .F.
				Else
					cERROMASTER := "(" + cRotina + ") O t.Peso Bruto  informado Não pode ser menor do que o peso Líquido - Campo Peso Bruto"
					AutoGrLog(cERROMASTER)
				Endif
			ENDIF


		Endif
	CASE 'C6_QTDLIB' $ cCampo

		//Busca custo de transferência de materiais de Caçador para Canoas
		If 	cFilAnt == '0101' .AND. GDFIELDGET('C6_TES') == '509' .and. M->C5_CLIENTE == '000462' .and. M->C5_LOJACLI == '0002'
			xReturn := 0

			//Busca Custo de transferência na SB9
			DBSelectArea("SB9")
			DBSetOrder(1)
			lFound := SB9->(MSSeek(xFilial("SC6") + GDFIELDGET('C6_PRODUTO',n) +  GDFIELDGET('C6_LOCAL',n) + DTOS(dMVUlmes)))
			If lFound
				xReturn :=  SB9->B9_CM1
			Endif

			If Empty(xReturn)
				DBSelectArea("SB2")
				DBSetOrder(1)
				lFound := SB2->(MSSeek(xFilial("SC6") + GDFIELDGET('C6_PRODUTO',n) +  GDFIELDGET('C6_LOCAL',n)))
				If lFound
					xReturn :=  SB2->B2_CM1
				Endif
			Endif
			//Acrescenta o ICMS DE 12%
			xReturn := xReturn / (1- 0.12) 

			//Aplica nos campos
			If !Empty(xReturn)
				GDFieldPut("C6_PRUNIT",xReturn,n)
				M->C6_PRUNIT := GDFieldGet("C6_PRUNIT",n)
				GDFieldPut("C6_PRCVEN",xReturn,n)
				M->C6_PRCVEN := GDFieldGet("C6_PRCVEN",n)
				GDFieldPut("C6_VALOR", GDFieldGet("C6_PRUNIT",n) * GDFieldGet("C6_QTDVEN") ,n)
				M->C6_PRCVEN := GDFieldGet("C6_VALOR",n)

				IIF(ExistTrigger("C6_PRUNIT"), RunTrigger(2,n,,"C6_PRUNIT"),"")
				CheckSX3( "C6_PRUNIT", GDFieldGet("C6_PRUNIT",n) )
				A410MultT("C6_PRUNIT",GDFieldGet("C6_PRUNIT",n))
			Endif
		Endif

	CASE 'C6_TES' $ cCampo
		//Regra poder Em Terceiro - Remessa
		lPodEm3 := Posicione("SF4",1,xFilial("SF4") + M->C6_TES,"SF4->F4_PODER3") == 'R'
		If lPodEm3 .AND. M->C5_TIPO <> 'B'
			If !lViaExecauto
				MsgInfo("Só é permitido uso de TES que controla Remessa para Poder de Terceiro em pedidos do Tipo 'B-Utiliza Fornecedor'!","Campo " + cCampo)
				lReturn := .F.
			Else
				cERROMASTER := "(" + cRotina + ") Só é permitido uso de TES que controla Remessa para Poder de Terceiro em pedidos do Tipo 'B-Utiliza Fornecedor'!- Campo " + cCampo
				AutoGrLog(cERROMASTER)
			Endif
		Endif

	OTHERWISE
		MsgAlert("Não há Validação específica para o campo " + cCampo + " no programa u_ValidCpo(). Ignorando validação...","Contate o Administrador ")
		lReturn := .T.
	ENDCASE

	RestArea(aArea)

Return lReturn
