#INCLUDE "rwmake.ch"



/*/{Protheus.doc} M410LIOK 
Tedesco - Validação de Linha do Pedido de Vendas
@type function
@version  25
@author Márcio Borges
@since 25/03/2021
@return logical, Permite ou não passar de linha
/*/
User Function M410LIOK()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaracao de Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local aArea			:= GetArea()
	Local cRotina   	:= FUNNAME()
	Local lViaExecauto 	:= IsBlind()
	Local cERROMASTER 	:= ""

	Local lPESONFS := SuperGetMV("ES_PESONFS",.F.,.F.) //Ativa Funcionalidade de Peso Liq/Bruto na Filial

	Local cProd			:= "" //Produto
	Local cTp   		:= "" //Tipo Produto

	Private lReturn 	:= .T. //Por padrão validação retorna Verdadeiro
	Private cCampo 		:= Alltrim(ReadVar())  // exemplo  "M->ZZB_AREA"
	Private Conteudo 	:= &(Alltrim(ReadVar()))
	Private nTolPTEO    := SuperGetMV("ES_DIFPTEO",.f.,0.05) //5% de tolerância

	//Validações de PESO LIQUIDO e PESO BRUTO
	cProd  := GDFieldGet("C6_PRODUTO",n)
	cTP    := Posicione( "SB1", 1, FWxFilial("SB1") + cProd, "SB1->B1_TIPO" )

	If lPESONFS
		// Efetua validação para Itens liberados para faturar, que forem PA e movimentem estoque
		IF GDFieldGet("C6_QTDLIB",N) > 0 .AND. cTP == "PA"  .AND. Posicione( "SF4", 1, FWxFilial("SF4") +  GDFieldGet("C6_TES",n), "SF4->F4_ESTOQUE" ) == 'S'

			//Se não estiver preenhido Peso Liquido , bloqueia
			If Empty(GDFieldGet("C6_PESO",N))
				If !lViaExecauto
					MsgInfo("É obrigatório informar Peso Liquido (C6_PESO) para Produto do tipo PA, em TES que movimente estoque","Campo Peso Líquido")
					lReturn := .F.
				//Else
				//	cERROMASTER := "(" + cRotina + ") É obrigatório informar Peso Liquido (C6_PESO) para Produto do tipo PA, em TES que movimente estoque - Campo C6_PESO"
				//	AutoGrLog(cERROMASTER)
				Endif
			/*	//Se estiver preenchido mas não estiver dentro da tolerânecia pergunta se deseja continuar assim mesmo.
			ElseIf GDFieldGet("C6_PESO",N) > SB1->B1_PESO * (1+nTolPTEO) .OR. GDFieldGet("C6_PESO",N) < SB1->B1_PESO * (1-nTolPTEO)
				If !lViaExecauto
					MsgInfo("O Peso Liquido (C6_PESO) informado está fora da margem máxima estabelecida de " + Alltrim(Str(nTolPTEO*100)) + "% em relação ao peso teórico (Peso liquido do Cadastro de Produto: " + AllTrim(TRANSFORM(SB1->B1_PESO,PESQPICT("SB1","B1_PESO")))+ ") ","Campo Peso Líquido")
					//lReturn := .F.
				Else
					cERROMASTER := "(" + cRotina + ") O Peso Liquido informado está fora da margem máxima estabelecida de " + Alltrim(Str(nTolPTEO*100)) + "% em relação ao peso teórico (Peso liquido do Cadastro de Produto: " + AllTrim(TRANSFORM(SB1->B1_PESO,PESQPICT("SB1","B1_PESO")))+ ") - Campo C6_PESO"
					AutoGrLog(cERROMASTER)
				Endif
			*/
			Endif

			//Se não estiver preenhido Peso BRUTO , bloqueia
			If Empty(GDFieldGet("C6_PBRUTO",N))
				If !lViaExecauto
					MsgInfo("É obrigatório informar Peso Bruto (C6_PBRUTO) para Produto do tipo PA, em TES que movimente estoque","Campo Peso Bruto")
					lReturn := .F.
				//Else
				//	cERROMASTER := "(" + cRotina + ") É obrigatório informar Peso Bruto (C6_PBRUTO) para Produto do tipo PA, em TES que movimente estoque - Campo Peso Bruto"
				//	AutoGrLog(cERROMASTER)
				Endif
				//Peso Bruto não pode ser menor do que o líquido
			ElseIf  GDFieldGet("C6_PBRUTO",N) < GDFieldGet("C6_PESO",N) 
				If !lViaExecauto
					MsgInfo("O Peso Bruto (C6_PBRUTO) informado Não pode ser menor do que o peso líquido","Campo Peso Bruto")
					lReturn := .F.
				//Else
				//	cERROMASTER := "(" + cRotina + ") O Peso Bruto  informado Não pode ser menor do que o peso líquido - Campo Peso Bruto"
				//	AutoGrLog(cERROMASTER)
				Endif
			Endif

		ENDIF

	Endif
	RestArea(aArea)

Return lReturn
