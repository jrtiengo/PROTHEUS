#Include "TOTVS.CH"
#INCLUDE "PROTHEUS.CH"

#INCLUDE "RWMAKE.CH"
#include "ap5mail.ch"


#define ENTER Chr(13)+Chr(10)


/*/{Protheus.doc} MT410TOK
Ponto de Entrada na Validação do botão OK da gravação do Pedido de Vendas. 
Utilizado para consistências do Peso Liq e Bruto
@type function
@version  25
@author solutio
@since 22/03/2021
@return logical, Grava ou não o pedido
/*/
User Function MT410TOK()
	Local lRet      := .T.
	Local cAlerta  := "" //Variável de aviso mas NÃO bloqueia
	Local cBloqueio:= "" //Variável de aviso E  bloqueia

	Local lPESONFS 		:= SuperGetMV("ES_PESONFS",.F.,.F.) //Ativa Funcionalidade de Peso Liq/Bruto na Filial
	Local lFoundPeso	:= .F. //Se encontrou registros na Regra de pesos
	Local nTPesoLiq 	:= 0
	Local nTPesoBrut 	:= 0

	Local aArea			:= GetArea()
	Local lViaExecauto 	:= IsBlind()
	//Local cRotina   	:= FUNNAME()
	//Local cERROMASTER 	:= ""

	Local nX

	//Variáveis para Controle Suspensão de IPI
	Local nCont		:= 0
	//Local aVIPI_	:= 0
	Local nTotIpi_	:= 0
	Local cSUSIPI	:= ""
	Local dVSUSIPI	:= ""
	Local cCliFor		:= Iif(M->C5_TIPO $ "D;B", "F", "C")
	//Local cCF_SUSIPI 	:= SuperGetMV("ES_SUSIPI",.F.,"122/151/911/922/949")


	Private nTolPTEO    := SuperGetMV("ES_DIFPTEO",.f.,0.05) //5% de tolerância

	DEFAULT __SpecialKey := Upper(GetSrvProfString("SpecialKey", "")) //identificia se é base de teste ou produção - TESTE: BHZV62_TESTE


// ****** VALIDAÇÃO PESO LIQUIDO E BRUTO *********

	//Validações Apenas para Canoas
	IF lPESONFS
		For nX := 1 To Len(aCols)

			//Validações de PESO LIQUIDO e PESO BRUTO
			cProd  := GDFieldGet("C6_PRODUTO",nX)
			cTP    := Posicione( "SB1", 1, FWxFilial("SB1") + cProd, "SB1->B1_TIPO" )

			// Efetua validação para Itens liberados para faturar, que Forem PA e movimentem estoque
			IF GDFieldGet("C6_QTDLIB",nX) > 0 .AND. cTP == "PA"  .AND. Posicione( "SF4", 1, FWxFilial("SF4") +  GDFieldGet("C6_TES",nX), "SF4->F4_ESTOQUE" ) == 'S'

				//Totalizadores:
				nTPesoLiq  += GDFieldGet("C6_TPESO",nX)
				nTPesoBrut += GDFieldGet("C6_TPBRUTO",nX)
				lFoundPeso := .T.


				//***** Peso Liquido ***********
				//Se não estiver preenhido , bloqueia
				If Empty(GDFieldGet("C6_PESO",nX))
					If !lViaExecauto
						cBloqueio += "Item '" + GDFieldGet("C6_ITEM",nX) +  "' - "
						cBloqueio += " É obrigatório informar Peso Liquido (C6_PESO) para Produto liberado para faturamento, do tipo PA, em TES que movimente estoque." + ENTER
						lRet := .F.
						//Else
						//	cERROMASTER := "(" + cRotina + ") É obrigatório informar Peso Liquido (C6_PESO) para Produto liberado para faturamento, do tipo PA, em TES que movimente estoque."
						//	AutoGrLog(cERROMASTER)
					Endif

				Endif
				//Se estiver preenchido mas não estiver dentro da tolerânecia pergunta se deseja continuar assim mesmo.
				If GDFieldGet("C6_PESO",nX) > SB1->B1_PESO * (1+nTolPTEO) .OR. GDFieldGet("C6_PESO",nX) < SB1->B1_PESO * (1-nTolPTEO)
					If !lViaExecauto
						cAlerta += "Item '" + GDFieldGet("C6_ITEM",nX) +  "' - "
						cAlerta += " O Peso Liquido (C6_PESO) informado está fora da margem máxima estabelecida de " + Alltrim(Str(nTolPTEO*100)) + "% em relação ao peso teórico (Peso liquido do Cadastro de Produto: " + AllTrim(TRANSFORM(SB1->B1_PESO,PESQPICT("SB1","B1_PESO")))+ ")." + ENTER
						lRet := .F.
						//Else
						//	cERROMASTER := "(" + cRotina + ") O Peso Liquido (C6_PESO) informado está fora da margem máxima estabelecida de " + Alltrim(Str(nTolPTEO*100)) + "% em relação ao peso teórico (Peso liquido do Cadastro de Produto: " + AllTrim(TRANSFORM(SB1->B1_PESO,PESQPICT("SB1","B1_PESO")))+ ")."
						//	AutoGrLog(cERROMASTER)
					Endif
				Endif
				//***** Peso Bruto ***********
				//Se não estiver preenhido, bloqueia
				If Empty(GDFieldGet("C6_PBRUTO",nX))
					If !lViaExecauto
						cBloqueio += "Item '" + GDFieldGet("C6_ITEM",nX) +  "' - "
						cBloqueio += " É obrigatório informar Peso Bruto (C6_PBRUTO) para Produto do tipo PA, em TES que movimente estoque." + ENTER
						lRet := .F.
						//Else
						//	cERROMASTER := "(" + cRotina + ") É obrigatório informar Peso Bruto (C6_PBRUTO) para Produto do tipo PA, em TES que movimente estoque."
						//	AutoGrLog(cERROMASTER)
					Endif

				Endif

				//Peso Bruto não pode ser menor do que o líquido // bloqueia
				If  GDFieldGet("C6_PBRUTO",nX) < GDFieldGet("C6_PESO",nX)
					If !lViaExecauto
						cBloqueio += "Item '" + GDFieldGet("C6_ITEM",nX) +  "' - "
						cBloqueio += " O Peso Bruto (C6_PBRUTO) informado Não pode ser menor do que o peso líquido (C6_PESO)" + ENTER
						lRet := .F.
						//Else
						//	cERROMASTER := "(" + cRotina + ") O Peso Bruto (C6_PBRUTO) informado Não pode ser menor do que o peso líquido (C6_PESO)"
						//	AutoGrLog(cERROMASTER)
					Endif
				Endif

			ENDIF


		Next nX
		If lFoundPeso .AND. Empty(cBloqueio)  //Se não teve críticas de validação.
			IF nTPesoLiq <> M->C5_PESOL  .OR. nTPesoBrut  <> M->C5_PBRUTO
				If !lViaExecauto
					If MSGYESNO("Somatório do Peso Liquido ("+ AllTrim(Transform(nTPesoLiq,PesqPict("SC5","C5_PESOL"))) + ") ou Peso Bruto ("+ AllTrim(Transform(nTPesoBrut,PesqPict("SC5","C5_PBRUTO"))) +") dos itens liberados diferem do Cabeçalho do Pedido." + ENTER + "Deseja atualizar os Pesos no Cabeçalho do Pedido automaticamente? ")
						M->C5_PESOL		:= nTPesoLiq
						M->C5_PBRUTO	:= nTPesoBrut
					Else
						lRet := .F.
					Endif
				Endif
			Endif
		Endif

	ENDIF

// #29002 >>> Validação para suspensão do IPI. Mauro - Solutio. <<<
	// Pega os dados do cliente.


	// Executa controle de Suspensão de IPI somente para Cliente
	If cCliFor == 'C'  .AND. cFilAnt == '0102'
		cSUSIPI		:= Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"SA1->A1_SUSIPI")
		dVSUSIPI	:= Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"SA1->A1_VSUSIPI")

		// Valida se a data da validade está preenchida, quando o campo de contro for igual a S.
		If cSUSIPI == "S" .And. Empty(dVSUSIPI)
			lRet := .F.
			MsgAlert("Cliente com Suspensão de IPI sem data de suspensão preenchida (A1_VSUSIPI). Verifique!", "Atenção!")
			RestArea(aArea)
			Return(lRet)
		EndIf

		// Mafisadd.
		For nCont := 1 to Len(aCols)

			If Posicione("SF4",1,xFilial("SF4") + GDFieldGet("C6_TES",nCont),"SF4->F4_DUPLIC" ) == 'S' //SUBSTRING(GDFieldGet("C6_CF",nCont),2,3) $ cCF_SUSIPI // Verifica Classificações fiscais de Venda

				// Inicia as chamadas para o Mafisret. No Primeiro Registro
				If nCont == 1
					// >>> Para pegar valor do IPI.

					MaFisEnd()
					MaFisIni(M->C5_CLIENTE,;               // 01 - Codigo Cliente/Fornecedor
					M->C5_LOJACLI,;                        // 02 - Loja do Cliente/Fornecedor
					Iif(M->C5_TIPO $ "D;B", "F", "C"),;    // 03 - C:Cliente , F:Fornecedor
					M->C5_TIPO,;                           // 04 - Tipo da NF
					M->C5_TIPOCLI,;                        // 05 - Tipo do Cliente/Fornecedor
					MaFisRelImp("MT100", {"SF2", "SD2"}),;    // 06 - Relacao de Impostos que suportados no arquivo
					,;                                        // 07 - Tipo de complemento
					,;                                        // 08 - Permite Incluir Impostos no Rodape .T./.F.
					"SB1",;                                   // 09 - Alias do Cadastro de Produtos - ("SBI" P/ Front Loja)
					"MATA461")

				Endif

				SB1->(DbSeek(FWxFilial("SB1")+  GDFieldGet("C6_PRODUTO",nCont) ))
				MaFisAdd( GDFieldGet("C6_PRODUTO",nCont),;	// 01 - Codigo do Produto                    ( Obrigatorio )
				GDFieldGet("C6_TES",nCont),;       			// 02 - Codigo do TES                        ( Opcional )
				GDFieldGet("C6_QTDVEN",nCont),;       		// 03 - Quantidade                           ( Obrigatorio )
				GDFieldGet("C6_PRCVEN",nCont),;      		 // 04 - Preco Unitario                       ( Obrigatorio )
				GDFieldGet("C6_VALDESC",nCont),;       		// 05 - Desconto
				GDFieldGet("C6_NFORI",nCont),;       		// 06 - Numero da NF Original                ( Devolucao/Benef )
				GDFieldGet("C6_SERIORI",nCont),;       		// 07 - Serie da NF Original                 ( Devolucao/Benef )
				0,;                     					// 08 - RecNo da NF Original no arq SD1/SD2
				M->C5_FRETE/Len(aCols),;  					// 09 - Valor do Frete do Item               ( Opcional )
				M->C5_DESPESA/Len(aCols),;                  // 10 - Valor da Despesa do item             ( Opcional )
				M->C5_SEGURO/Len(aCols),;                   // 11 - Valor do Seguro do item              ( Opcional )
				0,;                     					// 12 - Valor do Frete Autonomo              ( Opcional )
				GDFieldGet("C6_VALOR",nCont),;       		// 13 - Valor da Mercadoria                  ( Obrigatorio )
				0,;                     					// 14 - Valor da Embalagem                   ( Opcional )
				SB1->(RecNo()),;        					// 15 - RecNo do SB1
				SF4->(Recno()))                      		// 16 - RecNo do SF4

				// Mafisret.  // MaFisRet(,'NF_VALIPI')
				nTotIpi_ := MaFisRet(nCont,'IT_IPI')[2]
				// <<< Para pegar valor do IPI.

				// Valida o valor do IPI conforme as regras solicitadas.

				DO CASE
					// Venda sem suspensão de IPI e não calculou
				CASE  cSUSIPI == "N" .AND. nTotIpi_ == 0
					cBloqueio += "Item '" + GDFieldGet("C6_ITEM",nCont) +  "' - "
					cBloqueio += "CFOP de Venda ("+  GDFieldGet("C6_CF",nCont) + ") não Calcula  IPI. Cliente sem suspensão de IPI"  + ENTER
					lRet := .F.
				CASE lRet .AND. cSUSIPI == "S" .AND. nTotIpi_ == 0 .AND.  dVSUSIPI < M->C5_EMISSAO
					cBloqueio += "Item '" + GDFieldGet("C6_ITEM",nCont) +  "' - "
					cBloqueio += "Validade da Suspensão de IPI do cliente está expirada. Verifique Cadastro do Cliente"  + ENTER
					lRet := .F.
				ENDCASE
			Endif
		Next nCont

	Endif
// >>> Fim da validação para suspensão do IPI. Mauro - Solutio. <<<

	If !Empty(cBloqueio)
		cBloqueio := "*** Encontrado Alertas que impendem a gravação do Pedido ***" + ENTER + cBloqueio
		GeraLog(cBloqueio)
	Else
		//Gera tela de LOG de Avisos // Não bloqueiam gravação do Pedido
		If !Empty(cAlerta)
			cAlerta := "*** Encontrado Alertas no Pedido ***" + ENTER + cAlerta
			GeraLog(cAlerta)

			If !IsBlind()
				If MSGYESNO("Deseja continuar a gravação do Pedido de Vendas mesmo assim? SIM para Continuar, NÃO para editar pedido")
					lRet := .T.
				Endif
			Endif

		Endif
	Endif



	RestArea(aArea)

Return  lRet




//*************************************************************************************************************

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GeraLog   ºAutor  ³Márcio.Borges   º Data ³      05/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function GeraLog( cLogTxt )

	If IsBlind()
		If IsInCallStack("TEDA410")
			u_LogInteg("TEDA410","Erro","SC5",alltrim(STR(M->C5_PVINFOB)) ,'',cLogTxt,time() )
		Else
			CONOUT(cLogTxt)
		Endif
	Else
		
		__cFileLog := MemoWrite(Criatrab(,.F.)+".LOG",cLogTxt)

		Define FONT oFont NAME "Tahoma" Size 6,12
		Define MsDialog oDlgMemo Title "Consistência dos Dados" From 3,0 to 340,550 Pixel

		@ 5,5 Get oMemo  Var cLogTxt MEMO Size 265,145 Of oDlgMemo Pixel
		oMemo:bRClicked := {||AllwaysTrue()}
		oMemo:oFont:=oFont
		//Define SButton  From 153,205 Type 13 Action (cFile := cGetFile(cMask,""), Iif(cFile="",.T.,MemoWrite(cFile,cLogTxt)) ) Enable Of oDlgMemo Pixel
		//Define SButton  From 153,205 Type 13 Action ({oDlgMemo:End(),Mysend(cLogTxt)}) Enable Of oDlgMemo Pixel
		Define SButton  From 153,235 Type 1 Action oDlgMemo:End() Enable Of oDlgMemo Pixel

		Activate MsDialog oDlgMemo Center
	Endif
Return()
	*********************************************************************
Static Function Mysend(cTxt)
	*********************************************************************
	Static oDlg
	Static oButton1
	Static oButton2
	Static oGet1
	Static cGet1 := Space(200)
	Static oSay

	DEFINE MSDIALOG oDlg TITLE "Envio de Log" FROM 000, 000  TO 150, 300 COLORS 0, 12632256 PIXEL

	@ 031, 015 MSGET oGet1 VAR cGet1 SIZE 114, 010 OF oDlg PICTURE "@!" VALID !Empty(Alltrim(cGet1)) COLORS 0, 16777215 PIXEL
	@ 016, 015 SAY oSay PROMPT "Por favor, entre com seu email ABAIXO:" SIZE 100, 007 OF oDlg PICTURE "@!" COLORS 0, 12632256 PIXEL

	@ 050, 025 BUTTON oButton1 PROMPT "Enviar" SIZE 040, 012 OF oDlg ACTION {||oDlg:End(),DISMAILX(cGet1,cTxt)} PIXEL
	@ 050, 075 BUTTON oButton2 PROMPT "Sair" SIZE 040, 012 OF oDlg ACTION oDlg:End()  PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return
	*********************************************************************
Static Function DISMAILX(cMail,cTxt)
	*********************************************************************

	CONNECT SMTP SERVER GETMV("MV_RELSERV") ACCOUNT GETMV("MV_RELACNT") PASSWORD GETMV("MV_RELPSW") RESULT lResult

	If !lResult
		MsgBox('Erro no Envio')
		Return()
	EndIf

	cAccount := GETMV("MV_RELACNT")

	SEND MAIL FROM cAccount 	;
		TO      cMail	        	;
		SUBJECT FUNDESC()       	;//SUBJECT "Log Sx3 vs Banco" 	;
		BODY cTxt + CRLF + CRLF + FUNNAME() + " - " + FUNDESC()

	DISCONNECT SMTP SERVER

	MsgInfo("Email Enviado com Sucesso!")

Return()
