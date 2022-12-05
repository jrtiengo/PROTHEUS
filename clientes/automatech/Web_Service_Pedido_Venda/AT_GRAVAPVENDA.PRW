#Include "protheus.ch"
#Include "restful.ch"
#Include "totvs.ch"
#INCLUDE "rwmake.ch"
#include "topconn.ch"
#INCLUDE "TBICONN.CH"

// ##################################################################################
// AUTOMATECH SISTEMAS DE AUTOMA��O LTDA                                           ##
// ------------------------------------------------------------------------------- ##
// Referencia: AT_GRAVAPVENDA.PRW                                                  ##
// Par�metros: Nenhum                                                              ##
// Tipo......: (X) Programa  ( ) Gatilho                                           ##
// ------------------------------------------------------------------------------- ##
// Autor.....: Harald Hans L�schenkohl                                             ##
// Data......: 19/01/2017                                                          ##
// Objetivo..: Web Service que gera a inclus�o do pedido de venda no Protheus.     ##
// Par�metros: Vide rela��o abaixo                                                 ##
// ##################################################################################

WSRESTFUL AT_GRAVAPVENDA DESCRIPTION "Advpl Tools - Service Pedido de Venda"

WSDATA cCodEmp   AS STRING 	// C�digo da Empresa
WSDATA cCodFil   AS STRING 	// C�digo da Filial
WSDATA cTipPed   AS STRING 	// Tipo do Pedido de Venda  
WSDATA cCGCCli   AS STRING 	// Cnpj do Cliente
WSDATA cDadosCli AS STRING 	// Dados Cadastrais do Cliente para inclus�o na Tabela SA1
WSDATA cDadosCon AS STRING 	// Dados do Contato do Cliente
WSDATA cCodCon   AS STRING 	// C�digo da Condi��o de Pagamento  
WSDATA cTipFre   AS STRING 	// Tipo de Frete  
WSDATA cValFre   AS STRING 	// Valor do Frete  
WSDATA cCodTra   AS STRING 	// Transportadora
WSDATA cCodVen1  AS STRING 	// C�digo do Vendedor 1
WSDATA cCodVen2  AS STRING 	// C�digo do Vendedor 2
WSDATA cCodMoe   AS STRING 	// C�digo da Moeda
WSDATA cForExt   AS STRING 	// C�digo do Distribuidor Externo
WSDATA cLojExt   AS STRING 	// C�digo da Loja do Distribuidor Externo
WSDATA cCodPro   AS STRING 	// String com os C�digos dos produtos (004442|003102|001372|)
WSDATA cQtdPro   AS STRING 	// String com os C�digos dos produtos (1|1.5|3|) 
WSDATA cPrcPro   AS STRING 	// String com as Quantidades dos produtos (1075.25|750.00|100.00|) 
WSDATA cTotPro   AS STRING 	// String com os Pre�os Unit�rios dos produtos (1075.25|1125.00|300.00|) 
WSDATA cIsento   AS STRING 	// Indica se a IE do cliente � Isenta ou n�o
WSDATA cContrib  AS STRING 	// Indica se o cliente � ou n�o contribuinte
WSDATA cProposta AS STRING 	// N� da proposta comercial SaleMachine
WSDATA cObsNota  AS STRING 	// Observa��es para Nota Fiscal
WSDATA cObsInte  AS STRING 	// Observa��es Internas
WSDATA cObsDanf  AS STRING 	// Observa��es para Danfe
WSDATA cQtdExata AS STRING 	// Indica se quantidade � exata (para pedidos de venda de etiquetas)
WSDATA cTipoSrv  AS STRING 	// Indica o tipo de servi�o em caso de transportadora = Correios (000008)
WSDATA cTipoOpe  AS STRING 	// Indica o tipo de opera��o a ser utilizada para pesquisa do TES de venda dos produtos
WSDATA cFGratis  AS STRING 	// Indica se o frete � gr�tis
WSDATA AlteraCad AS STRING	// Altera o cadastro do pedido
WSDATA IPQID  	 AS STRING 	//
WSDATA IPDMID 	 AS STRING 	//
WSDATA cTiplib	 AS STRING	// Tip Liberacao

WSMETHOD GET DESCRIPTION "Advpl Tools - Service Pedido de Venda" WSSYNTAX "/AT_GRAVAPVENDA || /AT_GRAVAPVENDA/{cCodEmp}{cCodFil}{cTipPed}{cCGCCli}{cDadosCli}{cDadosCon}{cCodCon}{cTipFre}{cValFre}{cCodTra}{cCodVen1}{cCodVen2}{cCodMoe}{cForExt}{cLojExt}{cCodPro}{cQtdPro}{cPrcPro}{cTotPro}{cIsento}{cContrib}{cProposta}{cObsNota}{cObsInte}{cObsDanf}{cQtdExata}{cTipoSrv}{cTipoOpe}{cFGratis}{IPQID}{IPDMID}{AlteraCad}{cTiplib}"
END WSRESTFUL

WSMETHOD GET WSRECEIVE cCodEmp, cCodFil, cTipPed, cCGCCli, cDadosCli, cDadosCon, cCodCon, cTipFre, cValFre, cCodTra, cCodVen1, cCodVen2, cCodMoe, cForExt, cLojExt, cCodPro, cQtdPro, cPrcPro, cTotPro, cComis1, cComis2, cIsento, cContrib, cProposta, cObsNota, cObsInte, cObsDanf, cQtdExata, cTipoSrv, cTipoOpe, cFGratis, AlteraCad, IPQID, IPDMID, cTiplib  WSSERVICE AT_GRAVAPVENDA

	Local cSql       := ""
	Local cRetorno   := ""
	Local cString    := ""
	Local xControle  := ""
	Local _aCabec    := {}
	Local _aItens    := {}
	Local _aItem     := {}
	Local aItens	    := {}
	Local aLinha     := {}
	Local nX         := 0
	Local nY         := 0
	Local cDoc       := ""
	Local lOk        := .T.
	Local nContar    := 0
	Local nVezes     := 0
	Local xCodEmp    := Self:cCodEmp
	Local xCodFil    := Self:cCodFil
	Local xTipPed    := Self:cTipPed
	Local xCGCCli    := ""
	Local xDadosCli  := Self:cDadosCli
	Local xDadosCon  := Self:cDadosCon
	Local xCodCon    := Self:cCodCon
	Local xTipFre    := Self:cTipFre
	Local xValFre    := Self:cValFre
	Local xCodTra    := Self:cCodTra
	Local xCodVen1   := Self:cCodVen1
	Local xCodVen2   := Self:cCodVen2
	Local xCodMoe    := Self:cCodMoe
	Local xForExt    := Self:cForExt
	Local xLojExt    := Self:cLojExt
	Local xCodPro    := Self:cCodPro
	Local xQtdPro    := Self:cQtdPro
	Local xPrcPro    := Self:cPrcPro
	Local xTotPro    := Self:cTotPro
	Local xIsento    := Self:cIsento
	Local xContrib   := Self:cContrib
	Local xProposta  := Self:cProposta
	Local xObsNota   := Self:cObsNota
	Local xObsInte   := Self:cObsInte
	Local xObsDanf   := Self:cObsDanf
	Local xIDContato := Space(06)
	Local xComis1    := 0
	Local xComis2    := 0
	Local xQtdExata  := Self:cQtdExata
	Local xTipoSrv   := Self:cTipoSrv
	Local xNomeSrv   := ""
	Local xTipoOpe   := Self:cTipoOpe
	Local xFGratis   := Self:cFGratis 
	Local xcAltCad   := Self:AlteraCad 
	Local xIPQID   	:= Self:IPQID
	Local xIPDMID   	:= Self:IPDMID 
	Local xTipLib	:= Self:cTipLib
	Local lCadastrado:= .F.
	Local cLogin   	:= "admin"//GetMv("WS_PVLOGIN")
	Local cSenha   	:= "@tech15021"//GetMv("WS_PVPASS")
	Local aCli	  	:= {} 
	Local aCabec	:= {}

	Private lMsErroAuto := .F. 
	Private lMsHelpAuto := .F. 

	// #############################
	// Carrega a vari�vel xCGCCli ##
	// #############################
	
	If (Self:cCGCCLI) != nil
	
		If Len(Self:cCGCCLI) == 18
			xCGCCli := Substr(Self:cCGCCLI,01,02) + Substr(Self:cCGCCLI,04,03) + Substr(Self:cCGCCLI,08,03) + Substr(Self:cCGCCLI,12,04) + Substr(Self:cCGCCLI,17,02)
		Else
			xCGCCli := Substr(Self:cCGCCLI,01,03) + Substr(Self:cCGCCLI,05,03) + Substr(Self:cCGCCLI,09,03) + Substr(Self:cCGCCLI,13,02)
		Endif
	
	Else
	
		Return (.T.)
		
	EndIf

	Conout("=================================================")
	Conout("==        Parametros recebidos pela URL        ==")
	Conout("=================================================")
	Conout("Codigo da empresa......: " + xCodEmp)
	Conout("Codigo da filial.......: " + xCodFil)
	Conout("Tipo de Pedido.........: " + xTipPed)
	Conout("CNPJ/CPF...............: " + xCGCCli)
	Conout("Dados do Cliente.......: " + xDadosCli)
	Conout("Dados do Contato.......: " + xDadosCon)
	Conout("Condicao de Pagamento..: " + xCodCon)
	Conout("Tipo de Frete..........: " + xTipFre)
	Conout("Valor do Frete.........: " + xValFre)
	Conout("Transportadora.........: " + xCodTra)
	Conout("Vendedor 1.............: " + xCodVen1)
	Conout("Vendedor 2.............: " + xCodVen2)
	Conout("Moeda xCodMoe..........: " + xCodMoe)
	Conout("Distribuidor...........: " + xForExt)
	Conout("Loja Distribuidor......: " + xLojExt)
	Conout("Codigo Produtos........: " + xCodPro)
	Conout("Quantidade Produtos....: " + xQtdPro)
	Conout("Preco Unitario Produtos: " + xPrcPro)
	Conout("Total dos Produtos.....: " + xTotPro)
	Conout("Insc.Estadual Isenta...: " + xIsento)
	Conout("Contribuinte...........: " + xContrib)
	Conout("Proposta Comercial.....: " + xProposta)
	Conout("Obs. Para NF...........: " + xObsNota)
	Conout("Obs. Interna...........: " + xObsInte)
	Conout("Obs. Danfe.............: " + xObsDanf)      
	Conout("Qtd Exata..............: " + xQtdExata)      
	Conout("Tipo de Servico........: " + xTipoSrv)      
	Conout("Tipo de Operacao.......: " + xTipoOpe) 
	Conout("Tipo de Liberacao......: " + xTipLib)     

	// ###############################################################################
	// Seta o c�digo da Empresa conforme par�metro para inclus�o do pedido de venda ##
	// ###############################################################################
	//PREPARE ENVIRONMENT EMPRESA xCodEmp FILIAL xCodFil USER cLogin PASSWORD cSenha TABLES "SFM", "SC5","SC6","SA1","SA2","SB1","SB2","SF4" MODULO 'FAT'

	RPCClearEnv()
	RPCSetType(3)
	RPCSetEnv(xCodEmp,xCodFil)
	
	//ALTEMPFIL(xCodEmp, xCodFil)

	// ################################################################################
	// Gera a consist�ncias dos dados recebidos antes da inclus�o do Pedido de Venda ##
	// ################################################################################

	// ###################################################################################################
	// Tabela de retornos do Web Service Pedido de Venda Protheus                                       ##      
	// ###################################################################################################
	// 000 - Inclus�o de pedido de venda com sucesso                                                    ##
	// 001 - C�digo da Empresa n�o informada                                                            ##
	// 002 - C�digo da Filial n�o informada                                                             ##
	// 003 - Tipo de Pedido de Venda n�o informado                                                      ##
	// 004 - CNPJ/CPF do Cliente n�o informado                                                          ##
	// 005 - Condi��o de Pagamento n�o informada                                                        ##
	// 006 - Dispon�vel                                                                                 ##
	// 007 - Tipo de frete n�o informado                                                                ##
	// 008 - Valor do Frete                                                                             ##
	// 009 - Transportadora                                                                             ##
	// 010 - C�digo vendedor 1 n�o informado                                                            ##
	// 011 - C�digo da moeda n�o informada                                                              ##
	// 011 - C�digo do fornecedor externo n�o informado                                                 ##
	// 012 - C�digo da loja do fornecedor externo n�o informada                                         ##
	// 013 - C�digo(s) do(s) produto(s) do pedido de venda n�o informado(s)                             ##
	// 014 - Informa��o do(s) c�digo(s) do(s) produto(s) inconsist�nte (Sem informa��o do |)            ##
	// 015 - C�digo(s) do(s) produto(s) do pedido de venda n�o informado(s)                             ##
	// 016 - Informa��o da(s) quantidade(s) do(s) produto(s) inconsist�nte (Sem informa��o do |)        ##
	// 017 - Pre�o(s) unit�rio(s) do(s) produto(s) n�o informado(s)                                     ##
	// 018 - Informa��o do(s) pre�o(s) unit�rio(s) do(s) produto(s) inconsist�nte (Sem informa��o do |) ##
	// 019 - Valor Total do(s) produto(s) n�o informado(s)                                              ##
	// 020 - Informa��o do(s) total(is) do(s) produto(s) inconsist�nte (Sem informa��o do |)            ##
	// 021 - Dispon�vel                                                                                 ##
	// 022 - Dispon�vel                                                                                 ##
	// 023 - Conte�do do tipo de pedido de venda � inv�lido (Aceitos 1 ou 2)                            ##
	// 024 - Dados Cadastrais do Cliente                                                                ##
	// 025 - Nome do cliente n�o informado                                                              ##
	// 026 - Endere�o do cliente n�oo informado                                                         ##
	// 027 - UF do cliente n�o informado                                                                ##
	// 028 - Bairro do cliente n�o informado                                                            ##
	// 029 - Munic�pio do cliente n�o informado                                                         ##
	// 030 - CEP do endere�o do cliente n�o informado                                                   ##
	// 031 - DDD do telefone do cliente n�o informado                                                   ##
	// 032 - Telefone do cliente n�o informado                                                          ##
	// 033 - Inscri��o Estadual do cliente n�o informada                                                ##
	// 034 - E-mail do cliente n�o informado                                                            ##
	// 035 - Contato do cliente n�o informado                                                           ##
	// 036 - Indica��o de IE Isenta n�o informada                                                       ##
	// 037 - Informa��o do campo IE Isenta inconsistente (Aceitos somenete 0 ou 1)                      ##
	// 038 - Cliente contribuinte n�o informado                                                         ##   
	// 039 - Informa��o do campo Cliente Contribuinte inconsistente (Aceitos somenete 0 ou 1)           ##
	// 040 - Dispon�vel                                                                                 ##
	// 041 - Dispon�vel                                                                                 ##
	// 042 - Erro ao gravar pedido de venda                                                             ##
	// 043 - N� da proposta comercial n�o informada                                                     ##
	// 044 - Cliente inexistente no Protheus                                                            ##
	// 045 - Informa��o da(s) moeda(s) inconsist�nte (Sem informa��o do |)                              ##
	// 046 - Vendedor 1 n�o cadastrado                                                                  ##
	// 047 - Vendedor 2 n�o cadastrado                                                                  ##
	// 048 - Dados Cadastrais do cliente (Par�metros aguardados n�o recebidos)                          ##
	// 049 - Dados de Contato n�o recebidos                                                             ##
	// 050 - Nome do Contato n�o recebido                                                               ##
	// 051 - E-mail do Contato n�o recebido                                                             ## 
	// 052 - DDD do telefone do contato n�o recebido                                                    ##
	// 053 - N� do telefone do contato n�o recebido                                                     ##
	// 054 - Produtos de Suprimentos e Servi�os devem estar em pedidos separados.                       ##
	// 055 - Produtos n�o s�o produtos de Suprimentos.                                                  ##
	// 056 - Condi��o de Pagamento n�o localizada no cadastro (SE4)                                     ##
	// 057 - Quantidade exata n�o informada (S/N)                                                       ##
	// 058 - Se Quantidade Exata diferente de S/N                                                       ## 
	// 059 - C�digo IBGE do Munic�pio n�o localizado                                                    ## 
	// 060 - Tipo de Servi�o em caso de transportadora = Correios (000008)                              ## 
	// 061 - Tipo de Servi�o inv�lido. Aceitos (0, 1 - Correios 40068-PAC, 2 - Correios 40436-SEDEX)    ##
	// 062 - Tipo de Opera��o n�o informado                                                             ##
	// 063 - Tipo de Opera��o in�valido. Aceitos (02, 03 ou 35)                                         ##
	// 064 - Tipo de Opera��o somente permitido para pedidos de agenciamento                            ##
	// 065 - Tipo de opera��o inv�lido para pedidos de agenciamento                                     ##
	// 066 - Esta opera��o n�o pode ser selecionada para este cliente. Utilize Opera��o 03              ##
	// 067 - Esta opera��o n�o pode ser selecionada para este cliente. Utilize Opera��o 02              ##
	// 068 - Indica��o de frete gratuito n�o informado. (Informar S/N)                                  ##
	// 069 - Indica��o de frete gratuito inconsistente. Aceitos somente S ou N)                         ##
	// ###################################################################################################

	// #############################
	// Consiste c�digo da Empresa ##
	// #############################
	If Empty(Alltrim(xCodEmp))
		Conout("001 - Codigo da Empresa n�o informada")      
		cString := "001 - C�digo da Empresa n�o informada"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		//RESET ENVIRONMENT
		Return(.T.)
	Endif

	// ############################
	// Consiste c�digo da Filial ##
	// ############################
	If Empty(Alltrim(xCodFil))
		Conout("002 - C�digo da Filial n�o informada")
		cString := "002 - C�digo da Filial n�o informada"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		//RESET ENVIRONMENT
		Return(.T.)
	Endif

	// #####################################
	// Consiste o tipo de pedido de venda ##
	// #####################################
	If Empty(Alltrim(xTipPed))
		Conout("003 - Tipo de Pedido de Venda n�o informado")
		cString := "003 - Tipo de Pedido de Venda n�o informado"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		//RESET ENVIRONMENT

		Return(.T.)
	Endif

	// #################################################
	// Consiste o conte�do do tipo de pedido de venda ##
	// #################################################
	If Alltrim(xTipPed) <> "1" .And. Alltrim(xTipPed) <> "2"
		Conout("023 - Conte�do do tipo de pedido de venda � inv�lido (Aceitos 1 ou 2)")
		cString := "023 - Conte�do do tipo de pedido de venda � inv�lido (Aceitos 1 ou 2)"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		//RESET ENVIRONMENT

		Return(.T.)
	Endif   

	// ###############################
	// Consiste CNPJ/CPF do cliente ##
	// ###############################
	If Empty(Alltrim(xCGCCli))
		Conout("004 - CNPJ/CPF do Cliente n�o informado")
		cString := "004 - CNPJ/CPF do Cliente n�o informado"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		//RESET ENVIRONMENT

		Return(.T.)
	Endif

	// ###################################
	// Consiste a Condi��o de Pagamento ##
	// ###################################
	If Empty(Alltrim(xCodCon))
		Conout("005 - Condi��o de Pagamento n�o informada")
		cString := "005 - Condi��o de Pagamento n�o informada"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		//RESET ENVIRONMENT

		Return(.T.)
	Endif

	// #######################################################
	// Consiste dados do Contato do Cliente/Pedido de Venda ##
	// #######################################################
	If Empty(Alltrim(xDadosCon))
		Conout("049 - Dados de Contato do Pedido de Venda n�o informados")
		cString := "049 - Dados de Contato do Pedido de Venda n�o informados"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		//RESET ENVIRONMENT

		Return(.T.)
	Endif

	// #############################################
	// Separa os dados de contato para utiliza��o ##
	// #############################################
	kNomeCon := U_P_CORTA(xDadosCon,"|",01)
	kEmaiCon := U_P_CORTA(xDadosCon,"|",02)
	kNDDDCon := U_P_CORTA(xDadosCon,"|",03)
	kTel1Con := U_P_CORTA(xDadosCon,"|",04)
	kTel2Con := U_P_CORTA(xDadosCon,"|",05)   

	// ############################
	// Consistem nome do contato ##
	// ############################
	If Empty(Alltrim(kNomeCon))
		Conout("050 - Nome do Contato n�o informado")
		cString := "050 - Nome do Contato n�o informado"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		//RESET ENVIRONMENT

		Return(.T.)
	Endif

	// ##############################
	// Consistem e-mail do contato ##
	// ##############################
	If Empty(Alltrim(kEmaiCon))
		Conout("051 - E-mail do Contato n�o informado")
		cString := "051 - E-mail do Contato n�o informado"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		//RESET ENVIRONMENT

		Return(.T.)
	Endif

	// #######################################
	// Consistem DDD do telefone do contato ##
	// #######################################
	If Empty(Alltrim(kNDDDCon))
		Conout("052 - DDD do telefone do Contato n�o informado")
		cString := "052 - DDD do telefone do Contato n�o informado"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		//RESET ENVIRONMENT

		Return(.T.)
	Endif

	// #######################################
	// Consistem DDD do telefone do contato ##
	// #######################################
	If Empty(Alltrim(kTel1Con))
		Conout("053 - Telefone do Contato n�o informado")
		cString := "053 - Telefone do Contato n�o informado"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		//RESET ENVIRONMENT

		Return(.T.)
	Endif

	// #######################################
	// Consiste a Administradora de Cart�es ##
	// #######################################
	// If U_P_OCCURS(Upper(xCodCon), "CARTAO", 1) <> 0
	//    If Empty(Alltrim(xCodAdm))
	//       Conout("Administradora de Cartoes...........: " + xCodAdm)
	//       cString := "006 - Administradora de Cart�es n�o informada"
	//       ::SetContentType("text/plain")
	//       ::SetResponse(cString)  	
	//       //RESET ENVIRONMENT
	//        
	//       Return(.T.)
	//    Endif
	// Endif

	// ###########################
	// Consiste o Tipo de Frete ##
	// ###########################
	If Empty(Alltrim(xTipFre))
		Conout("007 - Tipo de frete n�o informado")
		cString := "007 - Tipo de frete n�o informado"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		//RESET ENVIRONMENT

		Return(.T.)
	Endif

	// ############################
	// Consiste o Valor do frete ##
	// ############################
	// If Empty(Alltrim(xValFre))
	//    Conout("Valor do Frete...........: " + xValFre)
	//    cString := "008 - Valor do Frete n�o informado"
	//    ::SetContentType("text/plain")
	//    ::SetResponse(cString)  	
	//    //RESET ENVIRONMENT
	//     
	//    Return(.T.)
	// Endif

	// ############################
	// Consiste a Transportadora ##
	// ############################
	// If Empty(Alltrim(xCodTra))
	//    Conout("Transportadora...........: " + xCodTra)
	//    cString := "009 - Transportadora n�o informada"
	//    ::SetContentType("text/plain")
	//    ::SetResponse(cString)  	
	//    //RESET ENVIRONMENT
	//     
	//    Return(.T.)
	// Endif

	// ###################################
	// Consiste o Campo Tipo de Servi�o ##
	// ###################################
	If xTipoSrv$("0#1#2")
		Do Case
			Case xTipoSrv == "0"
			nNomeSrv := ""
			Case xTipoSrv == "1"
			nNomeSrv := "CORREIOS 41068-PAC"
			Case xTipoSrv == "2"
			nNomeSrv := "CORREIOS 40436-SEDEX"
		EndCase        
	Else
		Conout("Tipo de Servi�o..........: " + xTipoSrv)
		cString := "061 - Tipo de Servi�o com informa��o incorreta, Aceitos 0,1 ou 2"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		//RESET ENVIRONMENT
		Return(.T.)
	Endif

	// #######################################
	// Consiste o tipo de Opera��o de Venda ##
	// #######################################
	If Empty(Alltrim(xTipoOpe))
		Conout("Tipo de Operacao.........: " + xTipoOpe)
		cString := "062 - Tipo de Opera��o n�o informado."
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		//RESET ENVIRONMENT
		Return(.T.)
	Endif

	// ##########################################################
	// Verifica se os tipos de opera��o informados s�o v�lidos ##
	// ##########################################################
	lTipoOpe := .T.

	For nContar = 1 to U_P_OCCURS(xTipoOpe, "|", 1)

		If U_P_CORTA(xTipoOpe, "|", nContar)$("02#03#35#04")
		Else
			lTipoOpe := .F.
			Exit
		Endif
	Next nContar    

	If lTipoOpe == .T.
	Else
		Conout("Tipo de Operacao........: " + xTipoOpe)
		cString := "063 - Tipo de Opera��o informado inv�lido. Aceitos 02, 03 ou 35"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		//RESET ENVIRONMENT
		Return(.T.)
	Endif

	// ###########################################################################
	// Verifica se o Tipo de Opera��o est� correto pelo tipo de pedido de venda ##
	// ###########################################################################
	If xTipoOpe == "35" .And. xTipPed <> "1"
		Conout("Tipo de Operacao........: " + xTipoOpe)
		cString := "064 - Tipo de Opera��o somente permitido para pedidos de agenciamento."
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		//RESET ENVIRONMENT
		Return(.T.)
	Endif

	If xTipoOpe <> "35" .And. xTipPed == "1"
		Conout("Tipo de Operacao........: " + xTipoOpe)
		cString := "065 - Tipo de opera��o inv�lido para pedidos de agenciamento."
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		////RESET ENVIRONMENT
		Return(.T.)
	Endif

	// ############################################################################
	// Consiste o |Tipo de Servi�o em caso de Transportadora = 000008 = Correios ##
	// ############################################################################
	If Empty(Alltrim(xCodTra))
	Else
		If xCodTra == "000008"
			If xTipoSrv$("1#2")
				Do Case
					Case xTipoSrv == "0"
					nNomeSrv := ""
					Case xTipoSrv == "1"
					nNomeSrv := "CORREIOS 41068-PAC"
					Case xTipoSrv == "2"
					nNomeSrv := "CORREIOS 40436-SEDEX"
				EndCase        
			Else
				Conout("Tipo de Servi�o..........: " + xTipoSrv)
				cString := "061 - Tipo de Servi�o com informa��o incorreta, Aceitos 1 ou 2"
				::SetContentType("text/plain")
				::SetResponse(cString)  	
				////RESET ENVIRONMENT
				Return(.T.)
			Endif   
		Endif   
	Endif

	// ################################
	// Consiste o c�digo do Vendedor ##
	// ################################
	If Empty(Alltrim(xCodVen1))
		Conout("010 - C�digo vendedor 1 n�o informado")
		cString := "010 - C�digo vendedor 1 n�o informado"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		//RESET ENVIRONMENT

		Return(.T.)
	Else

		// ##################################
		// Verifica se o vendedor � v�lido ##
		// ##################################
		If Select("T_VENDEDOR") > 0
			T_VENDEDOR->( dbCloseArea() )
		EndIf

		cSql := ""
		cSql := "SELECT A3_COD ,"
		cSql += "       A3_NOME " 
		cSql += "  FROM " + RetSqlName("SA3") + " (Nolock) "
		cSql += " WHERE A3_COD     = '" + Alltrim(xCodVen1) + "'"
		cSql += "   AND D_E_L_E_T_ = ''"

		cSql := ChangeQuery( cSql )
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

		If T_VENDEDOR->( EOF() )
			Conout("046 - Vendedor 1 n�o cadastrado")
			cString := "046 - Vendedor 1 n�o cadastrado"
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			////RESET ENVIRONMENT

			Return(.T.)
		Endif

	Endif

	// #############################
	// Consiste o c�digo da moeda ##
	// #############################
	If Int(Val(xCodMoe)) == 0
		Conout("011 - C�digo da moeda n�o informada")
		cString := "011 - C�digo da moeda n�o informada"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		////RESET ENVIRONMENT

		Return(.T.)
	Endif

	If Empty(Alltrim(xCodMoe))
		Conout("011 - Moeda n�o informada")
		cString := "011 - Moeda n�o informada"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		////RESET ENVIRONMENT

		Return(.T.)
	Else
		If U_P_OCCURS(xCodMoe, "|", 1) == 0
			Conout("045 - Informa��o da(s) moeda(s) inconsist�nte (Sem informa��o do |)")
			cString := "045 - Informa��o da(s) moeda(s) inconsist�nte (Sem informa��o do |)"
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			////RESET ENVIRONMENT

			Return(.T.)
		Endif
	Endif

	// ###################################################################
	// Consiste o c�digo e loja do fornecedor em caso de pedido externo ##
	// ###################################################################
	If Alltrim(xTipPed) == "1"

		If Empty(Alltrim(xForExt))
			Conout("011 - C�digo do fornecedor externo n�o informado")
			cString := "011 - C�digo do fornecedor externo n�o informado"
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			////RESET ENVIRONMENT

			Return(.T.)
		Endif

		If Empty(Alltrim(xLojExt))
			Conout("012 - C�digo da loja do fornecedor externo n�o informada")
			cString := "012 - C�digo da loja do fornecedor externo n�o informada"
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			////RESET ENVIRONMENT

			Return(.T.)
		Endif

	Endif

	// ####################################
	// Consiste o campo Quantidade Exata ##
	// ####################################
	If Empty(Alltrim(xQtdExata))
		Conout("057 - Informa��o da Quantidade Exata n�o informada.")
		cString := "057 - Informa��o da Quantidade Exata n�o informada."
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		////RESET ENVIRONMENT

		Return(.T.)                      
	Endif

	If xQtdExata$("N#S")
	Else
		Conout("058 - Informa��o da Quantidade Exata � inconsistente. Aceitos somente S ou N.")
		cString := "058 - Informa��o da Quantidade Exata � inconsistente. Aceitos somente S ou N."
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		////RESET ENVIRONMENT

		Return(.T.)                      
	Endif

	// #################################
	// Consiste o c�digo dos produtos ##
	// #################################
	If Empty(Alltrim(xCodPro))
		Conout("013 - C�digo(s) do(s) produto(s) do pedido de venda n�o informado(s)")
		cString := "013 - C�digo(s) do(s) produto(s) do pedido de venda n�o informado(s)"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		////RESET ENVIRONMENT

		Return(.T.)
	Else
		If U_P_OCCURS(xCodPro, "|", 1) == 0
			Conout("014 - Informa��o do(s) c�digo(s) do(s) produto(s) inconsist�nte (Sem informa��o do #)")
			cString := "014 - Informa��o do(s) c�digo(s) do(s) produto(s) inconsist�nte (Sem informa��o do #)"
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			////RESET ENVIRONMENT

			Return(.T.)
		Endif
	Endif

	// #####################################
	// Consiste a quantidade dos produtos ##
	// #####################################
	If Empty(Alltrim(xQtdPro))
		Conout("015 - C�digo(s) do(s) produto(s) do pedido de venda n�o informado(s)")
		cString := "015 - C�digo(s) do(s) produto(s) do pedido de venda n�o informado(s)"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		////RESET ENVIRONMENT

		Return(.T.)
	Else
		If U_P_OCCURS(xQtdPro, "|", 1) == 0
			Conout("Quantidade dos produtos sem |......: " + xQtdPro)
			cString := "016 - Informa��o da(s) quantidade(s) do(s) produto(s) inconsist�nte (Sem informa��o do #)"
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			//RESET ENVIRONMENT

			Return(.T.)
		Endif
	Endif      

	// #######################################
	// Consiste o pre�o un�rio dos produtos ##
	// #######################################
	If Empty(Alltrim(xPrcPro))
		Conout("017 - Pre�o(s) unit�rio(s) do(s) produto(s) n�o informado(s)")
		cString := "017 - Pre�o(s) unit�rio(s) do(s) produto(s) n�o informado(s)"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		/////RESET ENVIRONMENT

		Return(.T.)
	Else
		If U_P_OCCURS(xPrcPro, "|", 1) == 0
			Conout("Preco unitario dos produtos sem |......: " + xPrcPro)
			cString := "018 - Informa��o do(s) pre�o(s) unit�rio(s) do(s) produto(s) inconsist�nte (Sem informa��o do #)"
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			////RESET ENVIRONMENT

			Return(.T.)
		Endif
	Endif      

	// ######################################
	// Consiste o valor total dos produtos ##
	// ######################################
	If Empty(Alltrim(xTotPro))
		Conout("019 - Valor Total do(s) produto(s) n�o informado(s)")
		cString := "019 - Valor Total do(s) produto(s) n�o informado(s)"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		//R/ESET ENVIRONMENT

		Return(.T.)
	Else
		If U_P_OCCURS(xTotPro, "|", 1) == 0
			Conout("020 - Informa��o do(s) total(is) do(s) produto(s) inconsist�nte (Sem informa��o do #)")
			cString := "020 - Informa��o do(s) total(is) do(s) produto(s) inconsist�nte (Sem informa��o do #)"
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			////RESET ENVIRONMENT

			Return(.T.)
		Endif
	Endif      

	// ##################################################
	// Consiste o percentual de comiss�o do vendedor 1 ##
	// ##################################################
	//If !Empty(Alltrim(xCodVen1))
	//   If Empty(Alltrim(xComis1))
	//      Conout("021 - Percentual de comiss�o para o vendedor 1 n�o informada")
	//      cString := "021 - Percentual de comiss�o para o vendedor 1 n�o informada"
	//      ::SetContentType("text/plain")
	//      ::SetResponse(cString)  	
	//      //RESET ENVIRONMENT
	//       
	//      Return(.T.)
	//   Endif
	//Endif   

	// ##################################################
	// Consiste o percentual de comiss�o do vendedor 2 ##
	// ##################################################
	If !Empty(Alltrim(xCodVen2))

		// ##################################
		// Verifica se o vendedor � v�lido ##
		// ##################################
		If Select("T_VENDEDOR") > 0
			T_VENDEDOR->( dbCloseArea() )
		EndIf

		cSql := ""
		cSql := "SELECT A3_COD ,"
		cSql += "       A3_NOME " 
		cSql += "  FROM " + RetSqlName("SA3") + " (Nolock) "
		cSql += " WHERE A3_COD     = '" + Alltrim(xCodVen2) + "'"
		cSql += "   AND D_E_L_E_T_ = ''"

		cSql := ChangeQuery( cSql )
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VENDEDOR", .T., .T. )

		If T_VENDEDOR->( EOF() )
			Conout("047 - Vendedor 2 n�o cadastrado")
			cString := "047 - Vendedor 2 n�o cadastrado"
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			////RESET ENVIRONMENT

			Return(.T.)
		Endif

		// #####################################################
		// Verifica se a comiss�o do vendedor 2 foi informada ##
		// #####################################################
		//If Empty(Alltrim(xComis2))
		//   Conout("022 - Percentual de comiss�o para o vendedor 2 n�o informada")
		//   cString := "022 - Percentual de comiss�o para o vendedor 2 n�o informada"
		//   ::SetContentType("text/plain")
		//   ::SetResponse(cString)  	
		//   //RESET ENVIRONMENT
		//    
		//   Return(.T.)
		//Endif
	Endif   

	// #############################
	// Consiste o campo IE Isento ##
	// #############################
	If Empty(Alltrim(xIsento))
		Conout("036 - Indica��o de IE Isenta n�o informada")
		cString := "036 - Indica��o de IE Isenta n�o informada"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		////RESET ENVIRONMENT

		Return(.T.)
	Endif

	If Alltrim(xIsento) <> "0" .And. Alltrim(xIsento) <> "1"
		Conout("037 - Informa��o do campo IE Isenta inconsistente (Aceitos somenete 0 ou 1)")
		cString := "037 - Informa��o do campo IE Isenta inconsistente (Aceitos somenete 0 ou 1)"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		////RESET ENVIRONMENT

		Return(.T.)
	Endif

	// ################################
	// Consiste o campo Contribuinte ##
	// ################################
	If Empty(Alltrim(xContrib))
		Conout("038 - Cliente contribuinte n�o informado")
		cString := "038 - Cliente contribuinte n�o informado"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		////RESET ENVIRONMENT

		Return(.T.)
	Endif

	If Alltrim(xContrib) <> "0" .And. Alltrim(xContrib) <> "1"
		Conout("039 - Informa��o do campo Cliente Contribuinte inconsistente (Aceitos somenete 0 ou 1)")
		cString := "039 - Informa��o do campo Cliente Contribuinte inconsistente (Aceitos somenete 0 ou 1)"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		//////RESET ENVIRONMENT

		Return(.T.)
	Endif

	// ######################################
	// Consiste o campo forma de pagamento ##
	// ######################################
	//   If Empty(Alltrim(xFormaPG))
	//      Conout("040 - Campo forma de pagamento n�o informado")
	//      cString := "040 - Campo forma de pagamento n�o informado"
	//      ::SetContentType("text/plain")
	//      ::SetResponse(cString)  	
	//      //RESET ENVIRONMENT
	//       
	//      Return(.T.)
	//   Endif

	//   If Empty(Alltrim(xFormaPG))
	//      Conout("Forma de Pagamento somente 1 ou 2......: " + xFormaPG)
	//  /    cString := "041 - Informa��o do campo forma de pagamento inconsistente (Aceitos somenete 1 ou 2)"
	//      ::SetContentType("text/plain")
	//      ::SetResponse(cString)  	
	//      //RESET ENVIRONMENT
	//       
	//      Return(.T.)
	//   Else   
	//      //If xFormaPG$("1#2")
	//      If U_P_OCCURS(Upper(xCodCon), "CARTAO", 1) == 0      
	//         xFormaPG := "1"
	//         xCodAdm  := "  "
	//      Else
	//         xFormaPG := "2"
	//         xCodAdm  := "02"
	//      Endif   
	//   Endif

	// #######################################################################
	// Consiste o n� da proposta comercial de v�nculo com o pedido de venda ##
	// #######################################################################
	If Empty(Alltrim(xProposta))
		Conout("043 - N� da proposta comercial SM n�o informada")
		cString := "043 - N� da proposta comercial SM n�o informada"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		////RESET ENVIRONMENT

		Return(.T.)
	Endif

	// #####################################
	// Se o cliente n�o existir, o inclui ##
	// #####################################
	If Select("T_CLIENTE") > 0
		T_CLIENTE->( dbCloseArea() )
	EndIf

	cSql := ""
	cSql := "SELECT A1_COD ,"
	cSql += "       A1_LOJA,"
	cSql += "       A1_NOME "
	cSql += "  FROM SA1010 (Nolock)"
	cSql += " WHERE A1_CGC     = '" + Alltrim(xCGCCLI) + "'"
	cSql += "   AND D_E_L_E_T_ = ''"

	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CLIENTE", .T., .T. )

	If T_CLIENTE->( EOF() )

		// ########################################################################################
		// Ativar linhas abaixo em caso de ser retirado a inclus�o de clientes por este processo ##
		// ------------------------------------------------------------------------------------- ##
		//      Conout("044 - Cliente informado inexistente no Protheus")                        ##
		//      cString := "044 - Cliente informado inexistente no Protheus"                     ##
		//      ::SetContentType("text/plain")                                                   ##
		//      ::SetResponse(cString)  	                                                       ##
		//      //RESET ENVIRONMENT                                                                ##
		//       
		//      Return(.T.)                                                                      ##
		// ########################################################################################

		// #################################################
		// Vefifica se os dados do cliente foram enviados ##
		// #################################################
		If Empty(Alltrim(xDadosCli))

			// ###############################################################
			// Verifica se os dados do cliente foram enviados para inclus�o ##
			// ###############################################################
			If Empty(Alltrim(xDadosCli))
				Conout("024 - Dados Cadastrais do Cliente n�o informados.")
				cString := "024 - Dados Cadastrais do Cliente para inclus�o n�o informados."
				::SetContentType("text/plain")
				::SetResponse(cString)  	
				////RESET ENVIRONMENT 

				Return(.T.)
			Endif

			// ################################################################################
			// Verifica a quantidade de par�metros recebidos nos dados cadastrais do cliente ##
			// ################################################################################
			If U_P_OCCURS(xDadosCli, "|", 1) <> 13
				Conout("048 - Dados Cadastrais do Cliente (Par�metros aguardados n�o recebidos.)")
				cString := "048 - Dados Cadastrais do Cliente (Par�metros aguardados n�o recebidos.)"
				::SetContentType("text/plain")
				::SetResponse(cString)  	
				////RESET ENVIRONMENT 

				Return(.T.)
			Endif

		Endif   

		// ########################################################
		// Separa os campos do cliente para valida��o e inclus�o ##
		// ########################################################
		kNome      := UPPER(U_P_CORTA(xDadosCli,"|",01))
		kEndereco  := UPPER(U_P_CORTA(xDadosCli,"|",02))
		kEstado    := UPPER(U_P_CORTA(xDadosCli,"|",03))
		kBairro    := UPPER(U_P_CORTA(xDadosCli,"|",04))
		kCidade    := UPPER(U_P_CORTA(xDadosCli,"|",05))
		kCep       := UPPER(U_P_CORTA(xDadosCli,"|",06))
		kDDD       := UPPER(U_P_CORTA(xDadosCli,"|",07))
		kTelefone  := UPPER(U_P_CORTA(xDadosCli,"|",08))
		kInscricao := UPPER(U_P_CORTA(xDadosCli,"|",09))
		kEmail     := UPPER(U_P_CORTA(xDadosCli,"|",10))
		kContato   := UPPER(U_P_CORTA(xDadosCli,"|",11))
		kIsenta    := UPPER(U_P_CORTA(xDadosCli,"|",12))
		kContribui := UPPER(U_P_CORTA(xDadosCli,"|",13))
		kComplEnde := UPPER(U_P_CORTA(xDadosCli,"|",14))

		// ############################################
		// Verifica se nome do cliente foi informado ##
		// ############################################
		If Empty(Alltrim(kNome))
			Conout("025 - Nome do Cliente inexistente.")
			cString := "025 - Nome do Cliente inexistente."
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			////RESET ENVIRONMENT 

			Return(.T.)
		Endif

		// ################################################
		// Verifica se endere�o do cliente foi informado ##
		// ################################################
		If Empty(Alltrim(kEndereco))
			Conout("026 - Endere�o do Cliente inexistente.")
			cString := "026 - Endere�o do Cliente inexistente."
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			////RESET ENVIRONMENT 

			Return(.T.)
		Endif

		// ##########################################
		// Verifica se UF do cliente foi informado ##
		// ##########################################
		If Empty(Alltrim(kEstado))
			Conout("027 - Estado do Cliente inexistente.")
			cString := "027 - Estado do Cliente inexistente."
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			////RESET ENVIRONMENT 

			Return(.T.)
		Endif

		// ##############################################
		// Verifica se Bairro do cliente foi informado ##
		// ##############################################
		If Empty(Alltrim(kBairro))
			Conout("028 - Bairro do Cliente inexistente.")
			cString := "028 - Bairro do Cliente inexistente."
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			////RESET ENVIRONMENT 

			Return(.T.)
		Endif

		// #################################################
		// Verifica se Munic�pio do cliente foi informado ##
		// #################################################
		If Empty(Alltrim(kCidade))
			Conout("029 - Munic�pio do Cliente inexistente.")
			cString := "029 - Munic�pio do Cliente inexistente."
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			////RESET ENVIRONMENT 
			Return(.T.)
		Endif

		// ################################################################
		// Verifica se o c�digo do munic�pio est� cadastrado no Protheus ##
		// ################################################################
		If Select("T_IBGE") > 0
			T_IBGE->( dbCloseArea() )
		EndIf

		cSql := ""
		cSql := "SELECT CC2_CODMUN"
		cSql += "  FROM " + RetSqlName("CC2")
		cSql += " WHERE CC2_EST    = '" + Alltrim(kEstado) + "'"
		cSql += "   AND CC2_MUN    = '" + Alltrim(kCidade) + "'"
		cSql += "   AND D_E_L_E_T_ = ''"

		cSql := ChangeQuery( cSql )
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_IBGE", .T., .T. )

		If T_IBGE->( EOF() )
			Conout("059 - C�digo IBGE do Munic�pio n�o localizado.")
			cString := "059 - C�digo IBGE do Munic�pio n�o localizado."
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			////RESET ENVIRONMENT 
		Endif

		// ###############################
		// CEP do cliente foi informado ##
		// ###############################
		If Empty(Alltrim(kCEP))
			Conout("030 - CEP do Cliente inexistente.")
			cString := "030 - CEP do Cliente inexistente."
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			////RESET ENVIRONMENT 

			Return(.T.)
		Endif

		// ###############################
		// DDD do cliente foi informado ##
		// ###############################
		If Empty(Alltrim(kDDD))
			Conout("031 - DDD do Cliente inexistente.")
			cString := "031 - DDD do Cliente inexistente."
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			////RESET ENVIRONMENT 

			Return(.T.)
		Endif

		// ####################################
		// Telefone do cliente foi informado ##
		// ####################################
		If Empty(Alltrim(kTelefone))
			Conout("032 - Telefone do Cliente inexistente.")
			cString := "032 - Telefone do Cliente inexistente."
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			/////RESET ENVIRONMENT 

			Return(.T.)
		Endif

		// ###############################
		// IE  do cliente foi informado ##
		// ###############################
		If Empty(Alltrim(kInscricao))
			Conout("033 - IE do Cliente inexistente.")
			cString := "033 - IE do Cliente inexistente."
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			////RESET ENVIRONMENT 

			Return(.T.)
		Endif

		// ##################################
		// E-mail do cliente foi informado ##
		// ##################################
		If Empty(Alltrim(kInscricao))
			Conout("034 - E-mail do Cliente inexistente.")
			cString := "034 - E-mail do Cliente inexistente."
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			//RESET ENVIRONMENT 

			Return(.T.)
		Endif

		// ###################################
		// Contato do cliente foi informado ##
		// ###################################
		If Empty(Alltrim(kContato))
			Conout("035 - Contato do Cliente inexistente.")
			cString := "035 - Contato do Cliente inexistente."
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			//RESET ENVIRONMENT 

			Return(.T.)
		Endif

		// #########################
		// Indica��o de IE Isenta ##
		// #########################
		If Empty(Alltrim(kIsenta))
			Conout("036 - Indica��o de IE Isenta n�o informada")
			cString := "036 - Indica��o de IE Isenta n�o informada"
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			//RESET ENVIRONMENT 

			Return(.T.)
		Else
			If Alltrim(kIsenta)$("0#1")
			Else
				Conout("037 - Informa��o do campo IE Isenta inconsistente (Aceitos somenete 0 ou 1)")
				cString := "037 - Informa��o do campo IE Isenta inconsistente (Aceitos somenete 0 ou 1)"
				::SetContentType("text/plain")
				::SetResponse(cString)  	
				//RESET ENVIRONMENT 

				Return(.T.)
			Endif   
		Endif

		// #########################
		// Indica��o Contribuinte ##
		// #########################
		If Empty(Alltrim(kContribui))
			Conout("038 - Cliente contribuinte n�o informado")
			cString := "038 - Cliente contribuinte n�o informado"
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			//RESET ENVIRONMENT 

			Return(.T.)
		Else
			If Alltrim(kIsenta)$("0#1")
			Else
				Conout("039 - Informa��o do campo Cliente Contribuinte inconsistente (Aceitos somenete 0 ou 1)")
				cString := "039 - Informa��o do campo Cliente Contribuinte inconsistente (Aceitos somenete 0 ou 1)"
				::SetContentType("text/plain")
				::SetResponse(cString)  	
				//RESET ENVIRONMENT 

				Return(.T.)
			Endif   
		Endif

		// ##############################################
		// Realiza a inclus�o do cliente na tabela SA1 ##
		// ##############################################

		// ###############################################################
		// Prepara o pr�ximo c�digo de cliente dispon�vel para inclus�o ##
		// ###############################################################
		If Select("T_PROXIMO") > 0
			T_PROXIMO->( dbCloseArea() )
		EndIf

		cSql := ""
		cSql := "SELECT A1_COD ,"
		cSql += "       A1_LOJA,"
		cSql += "       A1_NOME,"
		cSql += "       A1_CGC  "
		cSql += "  FROM " + RetSqlName("SA1")
		cSql += " WHERE D_E_L_E_T_ = ''"
		cSql += " ORDER BY A1_COD DESC "

		cSql := ChangeQuery( cSql )
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PROXIMO", .T., .T. )

		If T_PROXIMO->( EOF() )
			nProximoCod := "000001"
		Else
			nProximoCod := STRZERO((INT(VAL(T_PROXIMO->A1_COD)) + 1),6)
		Endif

		// ########################################################################
		// Verifica se o raiz do CNPJ j� est� cadastrado no Cadastro de Clientes ##
		// ########################################################################
		If Select("T_RAIZ") > 0
			T_RAIZ->( dbCloseArea() )
		EndIf

		cSql := ""
		cSql := "SELECT A1_COD ,"
		cSql += "       A1_LOJA,"
		cSql += "       A1_NOME,"
		cSql += "       A1_CGC  "
		cSql += "  FROM " + RetSqlName("SA1")

		If Len(xCGCCLI) == 14
			cSql += " WHERE SUBSTRING(A1_CGC,1,8) = '" + Substr(xCGCCLI,1,8) + "'"
		Else
			cSql += " WHERE A1_CGC = '" + Alltrim(xCGCCLI) + "'"
		Endif            

		cSql += "   AND D_E_L_E_T_ = ''"     
		cSql += " ORDER BY A1_COD, A1_LOJA DESC"

		cSql := ChangeQuery( cSql )
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_RAIZ", .T., .T. )

		If T_RAIZ->( EOF() )
			kCodigo     := nProximoCod
			kLoja       := "001"
			lNovo       := .T.
		Else       
			kCodigo := T_RAIZ->A1_COD
			kLoja   := Strzero((INT(VAL(T_RAIZ->A1_LOJA)) + 1),3)
			lNovo       := .F.
		Endif

		// ####################################################################
		// Pesquisa o c�digo e nome do munic�pio na Tabela CC2 - C�digo IBGE ##
		// ####################################################################
		If Select("T_IBGE") > 0
			T_IBGE->( dbCloseArea() )
		EndIf

		cSql := ""
		cSql := "SELECT CC2_CODMUN"
		cSql += "  FROM " + RetSqlName("CC2")
		cSql += " WHERE CC2_EST    = '" + Alltrim(kEstado) + "'"
		cSql += "   AND CC2_MUN    = '" + Alltrim(kCidade) + "'"
		cSql += "   AND D_E_L_E_T_ = ''"

		cSql := ChangeQuery( cSql )
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_IBGE", .T., .T. )

		If T_IBGE->( EOF() )
			cMunicipio := ""
		Else
			cMunicipio := T_IBGE->CC2_CODMUN
		Endif

		Conout("KISENTA:" + kIsenta)

		// ########################
		// Inclui o novo cliente ##
		// ########################

		If lNovo  
			//aAdd(aCli, {"A1_FILIAL" , "" , Nil}) 
			aAdd(aCli, {"A1_COD" , kCodigo , Nil}) 
			aAdd(aCli, {"A1_LOJA" , kLoja , Nil})  
			aAdd(aCli, {"A1_NOME" , SUBSTR(kNome,1,TamSX3("A1_NOME")[1])  , Nil}) 
			aAdd(aCli, {"A1_NREDUZ" , SUBSTR(kNome,1,TamSX3("A1_NREDUZ")[1]) , Nil}) 
			aAdd(aCli, {"A1_TIPO" , "F" , NIL}) 
			aAdd(aCli, {"A1_END" , kEndereco , Nil})
			aAdd(aCli, {"A1_BAIRRO" , kBairro , Nil})
			aAdd(aCli, {"A1_EST" , kEstado , Nil})
			aAdd(aCli, {"A1_MUN" , kCidade , Nil})
			aAdd(aCli, {"A1_PESSOA" , IIF(Len(Alltrim(xCGCCLI)) == 14, "J", "F") , Nil})			
			aAdd(aCli, {"A1_ESTADO" , kEstado , Nil}) 
			aAdd(aCli, {"A1_COD_MUN" , cMunicipio , Nil}) 
			aAdd(aCli, {"A1_DDD" , kDDD , Nil}) 
			aAdd(aCli, {"A1_TEL" , kTelefone , Nil}) 
			aAdd(aCli, {"A1_CGC" , xCGCCLI , Nil}) 
			aAdd(aCli, {"A1_INSCR" , kInscricao , Nil}) 
			aAdd(aCli, {"A1_CEP" , kCep , Nil}) 
			aAdd(aCli, {"A1_CODPAIS" , "01058" , Nil})
			aAdd(aCli, {"A1_PAIS" , "105" , Nil}) 
			aAdd(aCli, {"A1_EMAIL" , kEmail , Nil})
			aAdd(aCli, {"A1_NATUREZ" , "10101" , Nil})
			aAdd(aCli, {"A1_GRPTRIB" , IIF(kIsenta == "0", "003", "002") , Nil})
			aAdd(aCli, {"A1_RISCO" , "E" , Nil})
			aAdd(aCli, {"A1_CONTRIB" , IIF(kContribui == "0", "2", "1") , Nil})
			aAdd(aCli, {"A1_VEND" , xCodVen1 , Nil})
			aAdd(aCli, {"A1_ZVEND2" , xCodVen2 , Nil})   
			aAdd(aCli, {"A1_ZCOMP" , "N" , Nil})
			aAdd(aCli, {"A1_COMPLEM" , kComplEnde , Nil})
			aAdd(aCli, {"A1_NCONT",	kContato, Nil })
			aAdd(aCli, {"A1_TABELA", "001", Nil})
		Else
			aAdd(aCli, {"A1_COD" , kCodigo , Nil}) 
			aAdd(aCli, {"A1_LOJA" , kLoja , Nil}) 
			aAdd(aCli, {"A1_NOME" , SUBSTR(kNome,1,TamSX3("A1_NOME")[1]) , Nil}) 
			aAdd(aCli, {"A1_NREDUZ" , SUBSTR(kNome,1,TamSX3("A1_NREDUZ")[1]) , Nil}) 
			aAdd(aCli, {"A1_END" , kEndereco , Nil}) 
			aAdd(aCli, {"A1_EST" , kEstado , Nil})	  
			aAdd(aCli, {"A1_COD_MUN" , cMunicipio , Nil}) 
			aAdd(aCli, {"A1_MUN" , kCidade , Nil}) 
			aAdd(aCli, {"A1_BAIRRO" , kBairro , Nil})
			aAdd(aCli, {"A1_DDD" , kDDD , Nil}) 
			aAdd(aCli, {"A1_TEL" , kTelefone , Nil}) 
			aAdd(aCli, {"A1_INSCR" , kInscricao , Nil}) 
			aAdd(aCli, {"A1_CEP" , kCep , Nil}) 
			aAdd(aCli, {"A1_EMAIL" , kEmail , Nil})
			aAdd(aCli, {"A1_VEND" , xCodVen1 , Nil})
			aAdd(aCli, {"A1_ZVEND2" , xCodVen2 , Nil})   
			aAdd(aCli, {"A1_COMPLEM" , kComplEnde , Nil})
			aAdd(aCli, {"A1_NCONT",	kContato, Nil })
		EndIf	
		lMsErroAuto := .F.

		If lNovo 
			//MSExecAuto({|a,b,c| MATA030(a,b,c)}, aCli, 3)
			MsExecAuto({|x,y| MATA030(x,y)}, aCli, 3)
			//MSExecAuto({|a,b,c| CRMA980(a,b,c)}, aCli, 3) //ExecAuto pra novas releases segundo TOTVS
		Else
			//MsExecAuto({|x,y| MATA030}, aCli, 4)
			MsExecAuto({|x,y| MATA030(x,y)}, aCli, 4)
		EndIf 

		If lMsErroAuto 
			//MostraErro()
			Conout("Erro na inclus�o do cliente")
			//cString := MostraErro()
			cString := Mostraerro("at_gravapvenda","Error WS_AT_GRAVAPVENDA.txt")
			ConOut(cString)	
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			//RESET ENVIRONMENT

			Return(.T.)
		EndIf 


		cCodigo := kCodigo
		cLoja   := kLoja

		_Juridico := IIF(Len(Alltrim(xCGCCli)) == 14, "S", "N")

	Else

		cCodigo := T_CLIENTE->A1_COD
		cLoja   := T_CLIENTE->A1_LOJA

		// ##########################################################################
		// Verifica se o cliente � jur�dico ou f�sico para pesquisa do novo c�digo ##
		// ##########################################################################
		_Juridico := IIF(Len(Alltrim(xCGCCli)) == 14, "S", "N")

	Endif

	// ##########################################################################################
	// Verifica se o contato do cliente j� est� cadastrado. Verifica��o pelo e-mail do contato ##
	// ##########################################################################################
	If Select("T_CONTATO") > 0
		T_CONTATO->( dbCloseArea() )
	EndIf

	cSql := "SELECT U5_CODCONT,"                                    	
	cSql += "       U5_CONTAT ,"
	cSql += "       U5_DDD    ,"
	cSql += "       U5_FONE   ,"
	cSql += "       U5_FCOM1  ," 
	cSql += "       U5_EMAIL   "
	cSql += "     FROM " + RetSqlName("SU5")
	cSql += "    WHERE UPPER(U5_EMAIL) = '" + Upper(Alltrim(kEmaiCon)) + "'"
	cSql += "       AND U5_NIVEL   = '07'"
	cSql += "       AND D_E_L_E_T_ = ''  "

	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONTATO", .T., .T. )

	If T_CONTATO->( EOF() )

		// #######################################
		// Inclui o Contato de Venda - N�vel 07 ##
		// #######################################
		Cod_Cnt_VDA := NEWNUMCONT()

		xIDContato  := Cod_Cnt_VDA

		DbSelectArea("SU5")
		RecLock("SU5",.T.)
		SU5->U5_FILIAL  := ""
		SU5->U5_CODCONT := Cod_Cnt_VDA
		SU5->U5_CONTAT  := kNomeCon
		SU5->U5_DDD     := kNDDDCon
		SU5->U5_FONE    := kTel1Con
		SU5->U5_FCOM1   := kTel2Con
		SU5->U5_EMAIL   := kEmaiCon
		SU5->U5_NIVEL   := "07"
		SU5->U5_ATIVO   := "1"
		SU5->U5_STATUS  := "2"
		SU5->U5_TIPO    := "2"
		Msunlock()

		// #######################################
		// Cadastra o V�nculo Contato X Cliente ##
		// #######################################
		DbSelectArea("AC8")
		RecLock("AC8",.T.)
		AC8->AC8_FILIAL := ""
		AC8->AC8_FILENT := ""       
		AC8->AC8_ENTIDA := "SA1"
		AC8->AC8_CODENT := cCodigo + cLoja
		AC8->AC8_CODCON := Cod_Cnt_VDA
		Msunlock()

		// ##########################################
		// Inclui o Contato de Cobranca - N�vel 08 ##
		// ##########################################
		Cod_Cnt_COB := NEWNUMCONT()

		DbSelectArea("SU5")
		RecLock("SU5",.T.)
		SU5->U5_FILIAL  := ""
		SU5->U5_CODCONT := Cod_Cnt_COB
		SU5->U5_CONTAT  := kNomeCon
		SU5->U5_DDD     := kNDDDCon
		SU5->U5_FONE    := KTel1Con
		SU5->U5_FCOM1   := KTel2Con
		SU5->U5_EMAIL   := kEmaiCon
		SU5->U5_NIVEL   := "08"      
		SU5->U5_ATIVO   := "1"
		SU5->U5_STATUS  := "2"
		SU5->U5_TIPO    := "3"
		Msunlock()

		// #######################################
		// Cadastra o V�nculo Contato X Cliente ##
		// #######################################
		DbSelectArea("AC8")
		RecLock("AC8",.T.)
		AC8->AC8_FILIAL := ""
		AC8->AC8_FILENT := ""       
		AC8->AC8_ENTIDA := "SA1"
		AC8->AC8_CODENT := cCodigo + cLoja
		AC8->AC8_CODCON := Cod_Cnt_COB
		Msunlock()

	Else      

		xIDContato := T_CONTATO->U5_CODCONT

		cSql := ""
		cSql := "UPDATE " + RetSqlName("SU5")
		cSql += "  SET U5_CONTAT  = '" + Alltrim(kNomeCon)   + "', "
		cSql += "      U5_DDD     = '" + Alltrim(kNDDDCon)   + "', "
		cSql += "      U5_FONE    = '" + Alltrim(kTel1Con)   + "', "
		cSql += "      U5_FCOM1   = '" + Alltrim(kTel2Con)   + "', "
		cSql += "      U5_EMAIL   = '" + Alltrim(kEmaiCon)   + "'  "
		cSql += "WHERE U5_CODCONT = '" + Alltrim(xIDContato) + "'"

		_nErro := TcSqlExec(cSql) 

		If TCSQLExec(cSql) < 0 
			alert(TCSQLERROR())
			Return(.T.)
		Endif

		// ##################################################################################
		// Verifica se existe Contato Vinculado com a tabela AC8 para o contato pesquisado ##
		// ##################################################################################
		If Select("T_VINCULO") > 0
			T_VINCULO->( dbCloseArea() )
		EndIf

		cSql := ""
		cSql := "SELECT AC8_FILIAL,"
		cSql += "       AC8_FILENT," 
		cSql += "       AC8_ENTIDA,"
		cSql += "       AC8_CODENT,"
		cSql += "       AC8_CODCON "
		cSql += "  FROM " + RetSqlName("AC8")
		cSql += " WHERE AC8_CODENT = '" + cCodigo + cLoja + "'"
		cSql += "   AND D_E_L_E_T_ = ''"

		cSql := ChangeQuery( cSql )
		dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_VINCULO", .T., .T. )

		If T_VINCULO->( EOF() )

			// #######################################
			// Cadastra o V�nculo Contato X Cliente ##
			// #######################################
			DbSelectArea("AC8")
			RecLock("AC8",.T.)
			AC8->AC8_FILIAL := ""
			AC8->AC8_FILENT := ""       
			AC8->AC8_ENTIDA := "SA1"
			AC8->AC8_CODENT := cCodigo + cLoja
			AC8->AC8_CODCON := xIDContato
			Msunlock()

			// ##########################################
			// Inclui o Contato de Cobranca - N�vel 08 ##
			// ##########################################
			Cod_Cnt_COB := NEWNUMCONT()

			// #######################################
			// Cadastra o V�nculo Contato X Cliente ##
			// #######################################
			DbSelectArea("AC8")
			RecLock("AC8",.T.)
			AC8->AC8_FILIAL := ""
			AC8->AC8_FILENT := ""       
			AC8->AC8_ENTIDA := "SA1"
			AC8->AC8_CODENT := cCodigo + cLoja
			AC8->AC8_CODCON := Cod_Cnt_COB
			Msunlock()

		Endif   

	Endif

	// ###################################################################################################
	// Verifica se o tipo de Opera��o pode ser utilizada para o grupo tribut�rio do cadastro do cliente ##
	// ###################################################################################################
	For nContar = 1 to U_P_OCCURS(xTipoOpe, "|", 1)

		If Alltrim(Posicione("SA1", 1, xFilial("SA1") + cCodigo + cLoja, "A1_GRPTRIB")) == "002" // IE ATIVO

			If Alltrim( U_P_CORTA(xTipoOpe, "|", nContar)) =="02" // Isento
				Conout("066 - Esta opera��o n�o pode ser selecionada para este cliente. Utilize Opera��o 03")
				cString := "066 - Esta opera��o n�o pode ser selecionada para este cliente. Utilize Opera��o 03"
				::SetContentType("text/plain")
				::SetResponse(cString)  	
				//RESET ENVIRONMENT 
				Return(.T.)
			EndIf

		ElseIf Alltrim(Posicione("SA1", 1, xFilial("SA1") + cCodigo + cLoja, "A1_GRPTRIB")) == "003" // IE ISENTO

			If Alltrim( U_P_CORTA(xTipoOpe, "|", nContar)) =="03" // Isento
				Conout("067 - Esta opera��o n�o pode ser selecionada para este cliente. Utilize Opera��o 02")
				cString := "067 - Esta opera��o n�o pode ser selecionada para este cliente. Utilize Opera��o 02"
				::SetContentType("text/plain")
				::SetResponse(cString)  	
				//RESET ENVIRONMENT 
				Return(.T.)
			EndIf

		EndIf

	Next nContar       

	// #################################################
	// Verifica se foi informado Frete Gratuito (S/N) ##
	// #################################################
	If Empty(Alltrim(xFGratis))   
		Conout("068 - Indica��o de frete gratuito n�o informado. (Informar S/N)")
		cString := "068 - Indica��o de frete gratuito n�o informado. (Informar S/N)"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		//RESET ENVIRONMENT 
		Return(.T.)
	EndIf

	If Alltrim(xFGratis) <> "S" .And. Alltrim(xFGratis) <> "N"
		Conout("069 - Indica��o de frete gratuito inconsistente. Aceitos somente S ou N)")
		cString := "069 - Indica��o de frete gratuito inconsistente. Aceitos somente S ou N)"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		//RESET ENVIRONMENT 
		Return(.T.)
	EndIf

	// ###############################################################
	// Verifica se a proposta comercial j� est� inclu�da no Sistema ##
	// ###############################################################   
	//   If xCodGrv == "N"
	//
	If Select("T_JACADASTRADO") > 0
		T_JACADASTRADO->( dbCloseArea() )
	EndIf
	//
	cSql := ""
	cSql := "SELECT C5_FILIAL,"
	cSql += "       C5_NUM   ,"
	cSql += "       C5_ZPNUV "
	cSql += "  FROM " + RetSqlName("SC5") + " (Nolock) "
	cSql += " WHERE C5_FILIAL  = '" + Alltrim(xCodFil)   + "'"
	cSql += "   AND C5_ZPNUV   = '" + Alltrim(xProposta) + "'"
	cSql += "   AND D_E_L_E_T_ = ''"
	//
	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_JACADASTRADO", .T., .T. )
	//

	//      
	//   Endif   

	// ################################################################
	// Teste retirado em 30/05/2018 conforme orienta��o do Sr. Roger ##
	// ################################################################

	// ########################################################################################################################
	// Verifica se existem produtos de Hardware junto com produtos de Suprimentos                                            ##
	// --------------------------------------------------------------------------------------------------------------------- ##
	// Regra de preenchimento do c�digo do vendedor no pedido de venda                                                       ##
	// --------------------------------------------------------------------------------------------------------------------- ##
	// Se Empresa logada for 03 - Atech e Filial 01 ou Empresa 01 e Filial 04, aplica-se a seguinte regra                    ##
	// --------------------------------------------------------------------------------------------------------------------- ##
	// 1) Se pedido de venda tiver somente produtos de servi�o, o vendedor ser� o vendedor Hardware do cadastro de clientes. ##
	// 2) Se pedido de venda tiver somente produtos de suprimentos (Grupo de 0200 ao 0299) o vendedor � do Suprimentos       ##
	// 3) Se no pedido de venda tiver produtos de suprimentos junto com produtos de servi�o , sistema dever� dar um aviso    ##
	//    que o mesmos dever� ser desdobrado e n�o permitir a grava��o do mesmo.                                             ##
	// Nova regra para venda compartilhada                                                                                   ##
	// Quando o cliente for um cliente com venda compartilhada, n�o se aplica a regra abaixo ou seja, o pedido de venda po-  ##
	// der� vender os produtos todos juntos.                                                                                 ##            
	// ########################################################################################################################
	//If Posicione("SA1", 1, xFilial("SA1") + cCodigo + cLoja, "A1_ZCOMP") == "S"
	//Else
	//
	//   If (xCodEmp == "01" .And. xCodFil == "04") .Or. (xCodEmp == "03" .And. xCodFil == "01") .Or. (xCodEmp == "01" .And. xCodFil == "07")
	//
	//      // ############################################################################
	//      // Verifica se todos os produtos do pedido de venda s�o produtos de servi�os ##
	//      // ############################################################################
	//      nTotalProdutos := 0
	//      nTotalServicos := 0
	//
	//      For nContar = 1 to U_P_OCCURS(xCodPro, "|", 1)
	//
	//          yyProduto := Alltrim(U_P_CORTA(xCodPro,"|", nContar)) + Space(30 - Len(Alltrim(U_P_CORTA(xCodPro,"|", nContar))))
	//
	//          If Alltrim(Posicione("SB1", 1, xFilial("SB1") + yyProduto, "B1_TIPO")) == "MO"
	//             nTotalServicos := nTotalServicos + 1
	//          Else
	//             nTotalProdutos := nTotalProdutos + 1
	//          Endif                   
	//
	//      Next nContar
	//
	//      // ##################################################################
	//      // Aplica a regra quando o pedido de venda somente possui servi�os ##
	//      // ##################################################################
	//      If nTotalServicos <> 0 .And. nTotalProdutos == 0
	//
	//         xCodVen1 := POSICIONE("SA1",1,XFILIAL("SA1") + cCodigo + cLoja, "A1_VEND")       
	//            
	//      Else
	//
	//         If nTotalServicos <> 0 .And. nTotalProdutos <> 0          
	//
	//            Conout("054 - Produtos de Suprimentos e Servi�os devem estar em pedidos separados.")
	//            cString := "054 - Produtos de Suprimentos e Servi�os devem estar em pedidos separados."
	//            ::SetContentType("text/plain")
	//            ::SetResponse(cString)  	
	//            //RESET ENVIRONMENT
	//             
	//            Return(.T.)
	//
	//         Else   
	//   
	//            // #############################################################################
	//            // Verifica se os produtos pertencem aos grupos de suprimentos (0200 ao 0299) ##
	//            // #############################################################################
	//            lTodosSuprimentos := .F.
	//
	//            For nContar = 1 to U_P_OCCURS(xCodPro, "|", 1)
	//                                                                        
	//                // ############################################
	//                // Prepara o c�digo do produto para pesquisa ##
	//                // ############################################
	//                yyProduto := Alltrim(U_P_CORTA(xCodPro,"|", nContar)) + Space(30 - Len(Alltrim(U_P_CORTA(xCodPro,"|", nContar))))
	//
	//                k_Grupo_Produto := Posicione("SB1", 1, xFilial("SB1") + yyProduto, "B1_GRUPO")
	//
	//                If (k_Grupo_Produto >= "0200" .And. k_Grupo_Produto <= "0299") .Or. (k_Grupo_Produto >= "0400")
	//                   lTodosSuprimentos := .T.                       
	//                Else
	//                   lTodosSuprimentos := .F.                                              
	//                   Exit
	//                Endif
	//
	//            Next nContar
	//
	//            // ####################################################################################################
	//            // N�o permite venda de produtos que n�o sejam de suprimentos na Empresa 03 ou Empresa 01, Filial 04 ##
	//            // ####################################################################################################
	//            If lTodosSuprimentos == .F.
	//               Conout("055 - Produtos n�o s�o produtos de Suprimentos.")
	//               cString := "055 - Produtos n�o s�o produtos de Suprimentos."
	//               ::SetContentType("text/plain")
	//               ::SetResponse(cString)  	
	//               //RESET ENVIRONMENT
	//                
	//               Return(.T.)
	//            Endif
	//
	//            // #############################################################################
	//            // Pesquisa o vendedor suprimentos para popular o vendedor do pedido de venda ##
	//            // #############################################################################
	//            // xCodVen2 := POSICIONE("SA1",1,XFILIAL("SA1") + cCodigo + cLoja, "A1_ZVEND2")
	//
	//         Endif
	//       
	//      Endif
	//       
	//   Endif   
	//
	//Endif

	// ###########################
	// Inclui o Pedido de Venda ##
	// ###########################

	// #############################################
	// Pesquisa o c�digo da condi��o de pagamento ##
	// #############################################
	If Select("T_CONDICAO") > 0
		T_CONDICAO->( dbCloseArea() )
	EndIf

	cSql := ""
	cSql := "SELECT E4_CODIGO,"
	cSql += "       E4_DESCRI "
	cSql += "  FROM SE4010    "
	//cSql += " WHERE E4_DESCRI = '" + Alltrim(xCodCon) + "'"
	cSql += " WHERE E4_CODIGO  = '" + Alltrim(xCodCon) + "'"   
	cSql += "   AND D_E_L_E_T_ = ''"

	cSql := ChangeQuery( cSql )
	dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_CONDICAO", .T., .T. )

	// ###################################
	// Consiste a Condi��o de Pagamento ##
	// ###################################
	If T_CONDICAO->( EOF() )
		Conout("056 - Condi��o de Pagamento inexistente")
		cString := "056 - Condi��o de Pagamento inexistente"
		::SetContentType("text/plain")
		::SetResponse(cString)  	
		//RESET ENVIRONMENT

		Return(.T.)
	Else
		nCodigoCond := IIF(T_CONDICAO->( EOF() ), "", T_CONDICAO->E4_CODIGO)
	Endif 

	/*dbselectarea("T_JACADASTRADO")
	If !T_JACADASTRADO->( EOF() )
	lCadastrado:=.T.
	If xcAltCad=="1"
	aAdd(_aCabec,{"C5_NUM"    , T_JACADASTRADO->C5_NUM   , Nil}) // N�mero do Pedido de Venda
	aAdd(_aCabec,{"C5_CLIENTE", cCodigo          , Nil}) // Codigo do Cliente
	aAdd(_aCabec,{"C5_LOJACLI", cLoja            , Nil}) // Loja do Cliente
	aAdd(_aCabec,{"C5_CLIENT" , cCodigo          , Nil}) // Codigo do Cliente de Entrega
	aAdd(_aCabec,{"C5_LOJAENT", cLoja            , Nil}) // Loja do Cliente de Entrega
	aAdd(_aCabec,{"C5_CLIRET" , cCodigo          , Nil}) // Codigo do Cliente de Retirada
	aAdd(_aCabec,{"C5_LOJARET", cLoja            , Nil}) // Loja do Cliente de Retirada
	aAdd(_aCabec,{"C5_CONDPAG", nCodigoCond      , Nil}) // Condi��o de Pagamento
	aAdd(_aCabec,{"C5_VEND1"  , xCodVen1         , Nil}) // C�digo do Vendedor 1  
	aAdd(_aCabec,{"C5_TPFRETE", xTipFre          , Nil}) // Tipo do frete
	//aAdd(_aCabec,{"C5_TABELA" , "500"            , Nil}) // Tabela de Pre�o
	aAdd(_aCabec,{"C5_ZCON"   , kNomeCon         , Nil}) // Nome do Contato
	aAdd(_aCabec,{"C5_ZEMA"   , kEmaiCon         , Nil}) // E-maildo Contato
	aAdd(_aCabec,{"C5_ZDD1"   , kNDDDCon         , Nil}) // DDD do Telefone do Contato
	aAdd(_aCabec,{"C5_ZTE1"   , kTel1Con         , Nil}) // Telefone 1 do Contato
	aAdd(_aCabec,{"C5_ZTE2"   , kTel2Con         , Nil}) // Telefone 2 do Contato
	aAdd(_aCabec,{"C5_ZIDC"   , xIDContato       , Nil}) // ID do Contato de Venda do Cliente
	aAdd(_aCabec,{"C5_QEXAT"  , xQtdExata        , Nil}) // Indica se Qtd do Pedido � exata ou n�o (S/N)
	aAdd(_aCabec,{"C5_OBSI"   , Alltrim(xObsInte), Nil}) // Observa��es Internas
	aAdd(_aCabec,{"C5_OBSNT"  , Alltrim(xObsDanf), Nil}) // Observa��es para DANFE
	aAdd(_aCabec,{"C5_MENNOTA", Alltrim(xObsNota), Nil}) // Observa��es para a Nota Fiscal	  
	Else
	aAdd(_aCabec,{"C5_NUM"    , T_JACADASTRADO->C5_NUM   , Nil}) // N�mero do Pedido de Venda
	aAdd(_aCabec,{"C5_ZCON"   , kNomeCon         , Nil}) // Nome do Contato
	aAdd(_aCabec,{"C5_ZEMA"   , kEmaiCon         , Nil}) // E-maildo Contato
	aAdd(_aCabec,{"C5_ZDD1"   , kNDDDCon         , Nil}) // DDD do Telefone do Contato
	aAdd(_aCabec,{"C5_ZTE1"   , kTel1Con         , Nil}) // Telefone 1 do Contato
	aAdd(_aCabec,{"C5_ZTE2"   , kTel2Con         , Nil}) // Telefone 2 do Contato
	aAdd(_aCabec,{"C5_ZIDC"   , xIDContato       , Nil}) // ID do Contato de Venda do Cliente
	EndIf

	MsExecAuto({|x, y, z| MATA410(x, y, z)}, _aCabec, , 4)

	//         Conout("999 - Proposta comercial j� cadastrada no pedido de venda nr. " + Alltrim(T_JACADASTRADO->C5_NUM))
	//         cString := "999 - Proposta comercial j� cadastrada no pedido de venda nr. " + Alltrim(T_JACADASTRADO->C5_NUM)
	//         ::SetContentType("text/plain")
	//         ::SetResponse(cString)  	
	//         //RESET ENVIRONMENT 
	//         Return(.T.)
	Endif     
	*/
	// ######################################################################################################   
	// Verifica quantos pedidos de venda ser�o abertos conforme a quantidade de moeda enviada no par�metro ##
	// ######################################################################################################
	nNumeroPedido := 0

	kMoeda1 := U_P_OCCURS(xCodMoe, "1", 1) 
	kMoeda2 := U_P_OCCURS(xCodMoe, "2", 1) 

	If kMoeda1 <> 0
		nNumeroPedido := nNumeroPedido + 1
	Endif

	If kMoeda2 <> 0
		nNumeroPedido := nNumeroPedido + 1
	Endif

	// ##############################################
	// Faz o la�o de abertura dos pedidos de venda ##
	// ##############################################
	For nVezes = 1 to nNumeroPedido

		// ###############################################
		// Pesquisa o pr�ximo c�digo de pedido de venda ##
		// ###############################################
		cNumPed := GetSX8Num("SC5","C5_NUM")
		ConfirmSx8()

		Conout("=================================================")
		Conout("==        Cabe�alho do Pedido de Venda         ==")
		Conout("=================================================")
		Conout("Filial.........: " + xCodFil)
		Conout("Num Pedido.....: " + cNumPed)
		Conout("Proposta.......: " + xProposta)
		Conout("Tipo PV........: " + "N")
		Conout("Cliente........: " + cCodigo)
		Conout("Loja...........: " + cLoja)
		Conout("CL Entrega.....: " + cCodigo)
		Conout("Loja Entrega...: " + cLoja)
		Conout("TP Cliente.....: " + "F")
		Conout("Cond.Pagto.....: " + nCodigoCond)
		Conout("Nome Contato...: " + kNomeCon)
		Conout("Email Contato..: " + kEmaiCon)
		Conout("DDD Telefones..: " + kNDDDCon)
		Conout("Telefone 01....: " + kTel1Con)
		Conout("Telefone 02....: " + kTel2Con)
		Conout("ID Contato.....: " + xIDContato)
		Conout("Emissao........: " + Dtoc(dDatabase))
		Conout("Moeda..........: " + xCodMoe)
		Conout("Tipo de Pedido.: " + xTipPed)
		Conout("Cod.Vendedora 1: " + xCodVen1)
		Conout("Tipo Liberacao.: " + "1")
		Conout("Tipo de Frete..: " + xTipFre)
		Conout("Transportadora.: " + xCodTra)
		Conout("Valor do Frete.: " + xValFre)
		Conout("Cod.Vendedor 2 : " + xCodVen2)
		Conout("Distribuidor...: " + xForExt)
		Conout("Loja Dist. ....: " + xLojExt)
		Conout("Loja Dist. ....: " + xQtdExata)
		Conout("ID Contato.....: " + xIDContato)
		Conout("Tipo Servi�o...: " + xTipoSrv)
		Conout("Tipo Opera��o..: " + xTipoOpe)  
		Conout("Tip. Liberacao.: " + xTipLib)     

		// ##########################################################
		// Cria array com os dados do cabe�alho do pedido de venda ##
		// ##########################################################
		aAdd(_aCabec,{"C5_FILIAL" , PADR( xCodFil, TAMSX3("C5_FILIAL")[1] )          , Nil}) // N�mero do Pedido de Venda
		aAdd(_aCabec,{"C5_NUM"    , PADR( cNumPed, TAMSX3("C5_NUM")[1] )          , Nil}) // N�mero do Pedido de Venda
		aAdd(_aCabec,{"C5_TIPO"   , "N"              , Nil}) // Tipo do Pedido de Venda
		aAdd(_aCabec,{"C5_CLIENTE", PADR( cCodigo, TAMSX3("C5_CLIENTE")[1] )          , Nil}) // Codigo do Cliente
		aAdd(_aCabec,{"C5_LOJACLI", PADR( cLoja, TAMSX3("C5_LOJACLI")[1] )            , Nil}) // Loja do Cliente
		aAdd(_aCabec,{"C5_LOJAENT", PADR( cLoja, TAMSX3("C5_LOJAENT")[1] )            , Nil}) // Loja do Cliente de Entrega
		aAdd(_aCabec,{"C5_CONDPAG", PADR( nCodigoCond, TAMSX3("C5_CONDPAG")[1] )      , Nil}) // Condi��o de Pagamento
		aAdd(_aCabec,{"C5_ZCON"   , PADR( kNomeCon, TAMSX3("C5_ZCON")[1] )         , Nil}) // Nome do Contato
		aAdd(_aCabec,{"C5_ZEMA"   , PADR( kEmaiCon, TAMSX3("C5_ZEMA")[1] )         , Nil}) // E-maildo Contato		
		aAdd(_aCabec,{"C5_ZPNUV"  , PADR( xProposta, TAMSX3("C5_ZPNUV")[1] )        , Nil}) // C�digo da proposta do SaleMachine
		aAdd(_aCabec,{"C5_TIPOCLI", "F"              , Nil}) // Tipo do Cliente
		aAdd(_aCabec,{"C5_EMISSAO", dDatabase        , Nil}) // Data de Emissao
		aAdd(_aCabec,{"C5_MOEDA"  , nVezes           , Nil}) // Moeda
		aAdd(_aCabec,{"C5_EXTERNO", PADR( xTipPed, TAMSX3("C5_EXTERNO")[1] )          , Nil}) // Tipo de Pedido de Venda (Interno/Externo) Grava inicialmente 2 N�o. Abaixo trata este campo
		aAdd(_aCabec,{"C5_FORMA"  , "1"              , Nil}) // Forma de Pagamento
		aAdd(_aCabec,{"C5_VEND1"  , PADR( xCodVen1, TAMSX3("C5_VEND1")[1] )         , Nil}) // C�digo do Vendedor 1  
		aAdd(_aCabec,{"C5_TIPLIB" , PADR( xTipLib, TAMSX3("C5_TIPLIB")[1] )          , Nil}) // Tipo de Libera��o do Pedido (1 = Por Item)
		aAdd(_aCabec,{"C5_TPFRETE", PADR( xTipFre, TAMSX3("C5_TPFRETE")[1] )          , Nil}) // Tipo do frete
		aAdd(_aCabec,{"C5_CLIENT" , PADR( cCodigo, TAMSX3("C5_CLIENT")[1] )          , Nil}) // Codigo do Cliente de Entrega		
		aAdd(_aCabec,{"C5_CLIRET" , PADR( cCodigo, TAMSX3("C5_CLIRET")[1] )          , Nil}) // Codigo do Cliente de Retirada
		aAdd(_aCabec,{"C5_LOJARET", PADR( cLoja, TAMSX3("C5_LOJARET")[1] )            , Nil}) // Loja do Cliente de Retirada

		//     aAdd(_aCabec,{"C5_FORNEXT", xForExt          , Nil}) // Tipo de Pedido de Venda (Interno/Externo) Grava inicialmente 2 N�o. Abaixo trata este campo
		//     aAdd(_aCabec,{"C5_LOJAEXT", xLojExt          , Nil}) // Tipo de Pedido de Venda (Interno/Externo) Grava inicialmente 2 N�o. Abaixo trata este campo
		//     aAdd(_aCabec,{"C5_EXTERNO", "2"              , Nil}) // Tipo de Pedido de Venda (Interno/Externo) Grava inicialmente 2 N�o. Abaixo trata este campo

		//aAdd(_aCabec,{"C5_TABELA" , "500"            , Nil}) // Tabela de Pre�o
		aAdd(_aCabec,{"C5_ZDD1"   , PADR( kNDDDCon, TAMSX3("C5_ZDD1")[1] )         , Nil}) // DDD do Telefone do Contato
		aAdd(_aCabec,{"C5_ZTE1"   , PADR( kTel1Con, TAMSX3("C5_ZTE1")[1] )         , Nil}) // Telefone 1 do Contato
		aAdd(_aCabec,{"C5_ZTE2"   , PADR( kTel2Con, TAMSX3("C5_ZTE2")[1] )         , Nil}) // Telefone 2 do Contato
		aAdd(_aCabec,{"C5_ZIDC"   , PADR( xIDContato, TAMSX3("C5_ZIDC")[1] )       , Nil}) // ID do Contato de Venda do Cliente
		aAdd(_aCabec,{"C5_QEXAT"  , PADR( xQtdExata, TAMSX3("C5_QEXAT")[1] )        , Nil}) // Indica se Qtd do Pedido � exata ou n�o (S/N)
		aAdd(_aCabec,{"C5_OBSI"   , PADR( Alltrim(xObsInte), TAMSX3("C5_OBSI")[1] ), Nil}) // Observa��es Internas
		aAdd(_aCabec,{"C5_OBSNT"  , PADR( Alltrim(xObsDanf), TAMSX3("C5_OBSNT")[1] ), Nil}) // Observa��es para DANFE
		aAdd(_aCabec,{"C5_MENNOTA", PADR( Alltrim(xObsNota), TAMSX3("C5_MENNOTA")[1] ), Nil}) // Observa��es para a Nota Fiscal
		aAdd(_aCabec,{"C5_IPQID"  , PADR( Alltrim(xIPQID), TAMSX3("C5_IPQID")[1] )	, Nil}) //
		aAdd(_aCabec,{"C5_IPDMID" , PADR( Alltrim(xIPDMID), TAMSX3("C5_IPDMID")[1] )	, Nil}) //

		// ###############################################################
		// Grava o c�digo da transportadora se foi passado no par�metro ##
		// ###############################################################
		If !Empty(Alltrim(xCodTra))
			aAdd(_aCabec,{"C5_TRANSP" , PADR( Alltrim(xCodTra), TAMSX3("C5_TRANSP")[1] )          , Nil}) // C�digo da transportadora

			// #############################################################
			// Grava o nome do servi�o quando transportadora for Correios ##
			// #############################################################
			If xCodTra == "000008"

				If xTipoSrv == "1"
					aAdd(_aCabec,{"C5_TSRV" , PADR( "CORREIOS 41068-PAC", TAMSX3("C5_TSRV")[1] ), Nil}) 
				Endif

				If xTipoSrv == "2"
					aAdd(_aCabec,{"C5_TSRV" , PADR( "CORREIOS 40436-SEDEX", TAMSX3("C5_TSRV")[1] ), Nil}) // Indica o tipo de servi�o em caso de transportadora = 000008 (Correios)
				Endif

			Endif   

		Endif   

		aAdd(_aCabec,{"C5_FRETE"  , VAL(xValFre)     , Nil}) // Valor do frete

		// ####################################################################
		// Grava o tipo de servi�o quando transportadora = 000008 (Correios) ##
		// ####################################################################
		If !Empty(Alltrim(xCodTra))
			If xCodTra == "000008"
				aAdd(_aCabec,{"C5_TSRV" , PADR( xNomeSrv, TAMSX3("C5_TSRV")[1] )          , Nil}) // Indica o tipo de servi�o em caso de transportadora = 000008 (Correios)
			Endif   
		Endif   

		// ###########################################################
		// Grava o c�digo do vendedor 2 se foi passado no par�metro ##
		// ###########################################################
		If !Empty(Alltrim(xCodVen2))
			aAdd(_aCabec,{"C5_VEND2", PADR( xCodVen2, TAMSX3("C5_VEND2")[1] ) , Nil}) // C�digo do Vendedor 2  
		Endif
		
		// #######################################################
		// Verifica se existe registro do produto na tabela SB2 ##
		// #######################################################
		For nContar = 1 to U_P_OCCURS(xCodPro, "|", 1)

			SB2_Produto := Alltrim(U_P_CORTA(xCodPro ,"|", nContar)) + Space(30 - Len(Alltrim(U_P_CORTA(xCodPro,"|", nContar))))

			// ##############################################
			// Verifica se existe o registro na tebala SB2 ##
			// ##############################################
			dbSelectArea("SB2")
			dbSetOrder(1)
			If !MsSeek(xCodFil + SB2_Produto + "01")
				CriaSB2(SB2_Produto, "01")
			EndIf

		Next nContar    

		Conout("=================================================")
		Conout("==        Itens do Pedido de Venda             ==")
		Conout("=================================================")

		// #########################################################
		// Cria o array com os dados dos itens do pedido de venda ##
		// #########################################################
		For nContar = 1 to U_P_OCCURS(xCodPro, "|", 1)

			// ####################################
			// Considera produtos da mesma moeda ##
			// ####################################

			If Int(Val(U_P_CORTA(xCodMoe, "|", nContar)))  == nVezes
			Else
				Loop
			Endif   

			// ###################################################
			// Pesquisa o TES correspondente ao cliente/produto ##
			// ###################################################
			If xTipPed == "1"
				kTES := "543"
			Else   

				yyProduto := Alltrim(U_P_CORTA(xCodPro ,"|", nContar)) + Space(30 - Len(Alltrim(U_P_CORTA(xCodPro,"|", nContar))))
				yyTipoOpe := Alltrim(U_P_CORTA(xTipoOpe,"|", nContar))

				Conout("Produto: " + yyProduto) 
				Conout("Cliente: " + cCodigo) 
				Conout("Loja...: " + cLoja)            
				Conout("Tipo Oper: " + yyTipoOpe)
				Conout("Cliente..: " + cCodigo)
				Conout("Loja.....: " + cLoja)               
				Conout("Produto..: " + yyProduto)

				kTES := MaTesInt(2, yyTipoOpe, cCodigo, cLoja, "C", yyProduto)

				Conout("TES..: " + kTES)


				// ######################################################################################################################
				// Linhas substitu�das porque no dia 05/04/2018, o tipo de opera��o passou a ser um �r�metro na chamada do web service ##
				// ######################################################################################################################
				//              Do Case                                                                                                ##
				//                 Case _Juridico == "S" .And. xIsento == "0"                                                          ##
				//                      kTES := MaTesInt(2, "03", cCodigo, cLoja, "C", yyProduto)                                      ##
				//                                                                                                                     ##
				//                 Case _Juridico == "S" .And. xIsento == "1"                                                          ##
				//                      kTES := MaTesInt(2, "02", cCodigo, cLoja, "C", yyProduto)                                      ##
				//                                                                                                                     ##
				//                 Case _Juridico == "N"                                                                               ##
				//                      kTES := MaTesInt(2, "02", cCodigo, cLoja, "C", yyProduto)                                      ##
				//              EndCase                                                                                                ##
				// ######################################################################################################################

			Endif

			// ########################################################## 
			// Pesquisa a Situa��o Tribut�ria do produto para grava��o ##
			// ##########################################################
			yyProduto := Alltrim(U_P_CORTA(xCodPro,"|", nContar)) + Space(30 - Len(Alltrim(U_P_CORTA(xCodPro,"|", nContar))))
			xSituacao := Posicione( "SB1", 1, xFilial("SB1") + yyProduto, "B1_ORIGEM" ) + ;
			Posicione( "SF4", 1, xFilial("SF4") + kTES     , "F4_SITTRIB")

			// ##########################################################
			// Pesquisa o c�digo do produto pela leitura do ID enviado ##
			// ##########################################################
			If Select("T_PRODUTO") > 0
				T_PRODUTO->( dbCloseArea() )
			EndIf

			cSql := ""
			cSql := "SELECT B1_COD   ,"
			cSql += "       B1_DESC  ,"
			cSql += "       B1_GRUPO ,"
			cSql += "       B1_DESC  ,"
			cSql += "       B1_UM     "
			cSql += "  FROM " + RetSqlName("SB1") + " (Nolock) "
			cSql += " WHERE D_E_L_E_T_ = ''"
			cSql += "   AND B1_COD     = '" + Alltrim(U_P_CORTA(xCodPro,"|", nContar)) + "'"

			cSql := ChangeQuery( cSql )
			dbUseArea( .T., "TOPCONN", TcGenQry(,,cSql), "T_PRODUTO", .T., .T. )

			kk_Produto   := T_PRODUTO->B1_COD
			kk_Grupo     := T_PRODUTO->B1_GRUPO
			kk_Descricao := T_PRODUTO->B1_DESC
			kk_Unidade   := T_PRODUTO->B1_UM

			// ##########################################
			// Pesquisa o % de comiss�o dos vendedores ##
			// ##########################################
			kTipoVen1 := Posicione("SA3",1,xFilial("SA3") + xCodVen1       , "A3_TIPOV")
			kTipoVen2 := Posicione("SA3",1,xFilial("SA3") + xCodVen2       , "A3_TIPOV")
			kTipoComp := Posicione("SA1",1,xFilial("SA1") + cCodigo + cLoja, "A1_ZCOMP")
			kGerente  := Posicione("SBM",1,xFilial("SBM") + kk_Grupo       , "BM_COMIS")
			kExecut1  := Posicione("SBM",1,xFilial("SBM") + kk_Grupo       , "BM_COME1")
			kExecut2  := Posicione("SBM",1,xFilial("SBM") + kk_Grupo       , "BM_COME2")

			// ######################################################
			// Carrega comiss�o quando cliente n�o � compartilhado ##
			// ######################################################
			If kTipoComp == "N"

				If Empty(Alltrim(xCodVen1))
				Else
					Do Case 

						// #######################################
						// Se vendedor for Executivo de Venda 1 ##
						// #######################################
						Case kTipoVen1 == "1"
						xComis1 := kExecut1

						// ####################################
						// Se vendedor for Gerente de Vendas ##
						// ####################################
						Case kTipoVen1 == "2"
						xComis1 := kGerente

						// ########################################
						// Se vendedor for Executivo de Vendas 2 ##
						// ########################################
						Case kTipoVen1 == "3"
						xComis1 := kExecut2

					EndCase
				Endif

				If Empty(Alltrim(xCodVen2))
				Else

					Do Case 

						// #######################################
						// Se vendedor for Executivo de Venda 1 ##
						// #######################################
						Case kTipoVen2 == "1"
						xComis2 := kExecut1

						// ####################################
						// Se vendedor for Gerente de Vendas ##
						// ####################################
						Case kTipoVen2 == "2"
						xComis2 := kGerente

						// ########################################
						// Se vendedor for Executivo de Vendas 2 ##
						// ########################################
						Case kTipoVen2 == "3"
						xComis2 := kExecut2

					EndCase

				Endif

			Else   

				Do Case 

					// ##########################
					// Se vendedor for gerente ##
					// ##########################
					Case kTipoVen1 == "1"
					xComis1 := (kExecut1 * 70) / 100
					xComis2 := (kGerente * 30) / 100

					// ##########################
					// Se vendedor Executivo 2 ##
					// ##########################
					Case kTipoVen1 == "3"
					xComis1 := (kExecut2 * 70) / 100
					xComis2 := (kGerente * 30) / 100

				EndCase

			Endif

			// ##########################################################################
			// Prepara campo de grava��o de frete gratu�to se este indicado como sendo ##
			// ##########################################################################
			If xFGratis == "S"
				_FreteGratis    := "S"
				_FreteLegenda   := "SIM-"
				_FreteBloqueado := "S"
			Else
				_FreteGratis    := ""
				_FreteLegenda   := ""
				_FreteBloqueado := " "
			Endif   

			// ###############################
			// Carrega o array dos produtos ##
			// ###############################
			If xFGratis == "S"
				aAdd(_aItens, {"C6_FILIAL" , PADR( xCodFil, TAMSX3("C6_FILIAL")[1] )                                                                    	, Nil}) // C�digo da Filial
				aAdd(_aItens, {"C6_NUM"    , PADR( cNumPed, TAMSX3("C6_NUM")[1] )                                                                    	, Nil}) // N� do Pedido de Venda
				aAdd(_aItens, {"C6_ITEM"   , Strzero(nContar,02)                                                        	, Nil}) // C�digo do Produto
				aAdd(_aItens, {"C6_PRODUTO", PADR( Alltrim(kk_Produto), TAMSX3("C6_PRODUTO")[1] )                                                        	, Nil}) // C�digo do Produto
				aAdd(_aItens, {"C6_QTDVEN" , VAL(U_P_CORTA(xQtdPro,"|", nContar))                                       	, Nil}) // Quantidade vendida do produto
				aAdd(_aItens, {"C6_PRCVEN" , VAL(U_P_CORTA(xPrcPro,"|", nContar))                                       	, Nil}) // Preco venda do produto
				aAdd(_aItens, {"C6_PRUNIT" , VAL(U_P_CORTA(xPrcPro,"|", nContar))                                       	, Nil}) // Preco unitario
				aadd(_aItens, {"C6_VALOR" ,	 (VAL(U_P_CORTA(xQtdPro,"|", nContar)) * VAL(U_P_CORTA(xPrcPro,"|", nContar)) )	,Nil})
				aAdd(_aItens, {"C6_TES"    , PADR( Alltrim(kTES), TAMSX3("C6_TES")[1] )                                                                       	, Nil}) // TES
				aAdd(_aItens, {"C6_DESCRI" , PADR( Alltrim(kk_Descricao), TAMSX3("C6_DESCRI")[1] )                                                              		, Nil}) // Descri��o do Produto
				aAdd(_aItens, {"C6_UM"     , PADR( Alltrim(kk_Unidade), TAMSX3("C6_UM")[1] )                                                                 	, Nil}) // Unidade de medida (primeira)
				aAdd(_aItens, {"C6_LOCAL"  , "01"   		                                                            	, Nil}) // Armazem				
				aAdd(_aItens, {"C6_CLI"    , PADR( Alltrim(cCodigo), TAMSX3("C6_CLI")[1] )                                                                    	, Nil}) // C�digo do cliente 
				aAdd(_aItens, {"C6_LOJA"   , PADR( Alltrim(cLoja), TAMSX3("C6_LOJA")[1] )                                                                      	, Nil}) // Loja do cliente
				aAdd(_aItens, {"C6_CHASSI" , "X"                                                                        	, Nil}) // % comiss�o vendedor 2
				aAdd(_aItens, {"C6_TURNO"  , "M"                                                                        	, Nil}) // % comiss�o vendedor 2                                                                              
				aAdd(_aItens, {"C6_ZTBL"   , PADR( Alltrim(_FreteLegenda), TAMSX3("C6_ZTBL")[1] )                                                               	, Nil}) // Legenda Frete Gratu�to
				aAdd(_aItens, {"C6_ZGRA"   , PADR( Alltrim(_FreteGratis), TAMSX3("C6_ZGRA")[1] )                                                                	, Nil}) // Indica��o de Frete Gratu�to
				aAdd(_aItens, {"C6_BLQ"    , PADR( Alltrim(_FreteBloqueado), TAMSX3("C6_BLQ")[1] )                                                             	, Nil}) // Indica Bloqueio Margem
				aAdd(_aItens, {"C6_ENTREG" , Date()                                                                     	, Nil}) // Data de Entrega
				aAdd(_aItens, {"C6_SUGENTR", Date()                                                                     	, Nil}) // Data Sugerida
				aAdd(_aItens, {"C6_COMIS1" , xComis1                                                                    	, Nil}) // % comiss�o vendedor 1
				aAdd(_aItens, {"C6_COMIS2" , xComis2                                                                    	, Nil}) // % comiss�o vendedor 2
				
				aadd(aItens, _aItens)
			Else
				aAdd(_aItens, {"C6_FILIAL" , xCodFil   								 , Nil}) // C�digo da Filial	
				aAdd(_aItens, {"C6_NUM"    , cNumPed                                 , Nil}) // N� do Pedido de Venda
				aAdd(_aItens, {"C6_ITEM"   , Strzero(nContar,02)                     , Nil}) // C�digo do Produto
				aAdd(_aItens, {"C6_PRODUTO", Alltrim(kk_Produto)                     , Nil}) // C�digo do Produto
				aAdd(_aItens, {"C6_QTDVEN" , VAL(U_P_CORTA(xQtdPro,"|", nContar))    , Nil}) // Quantidade vendida do produto
				aAdd(_aItens, {"C6_PRCVEN" , VAL(U_P_CORTA(xPrcPro,"|", nContar))    , Nil}) // Preco venda do produto
				aAdd(_aItens, {"C6_PRUNIT" , VAL(U_P_CORTA(xPrcPro,"|", nContar))    , Nil}) // Preco unitario
				aadd(_aItens, {"C6_VALOR" ,	 (VAL(U_P_CORTA(xQtdPro,"|", nContar)) * VAL(U_P_CORTA(xPrcPro,"|", nContar)))	,Nil})	
				aAdd(_aItens, {"C6_TES"    , kTES                                    , Nil}) // TES
				aAdd(_aItens, {"C6_DESCRI" , kk_Descricao                            , Nil}) // Descri��o do Produto
				aAdd(_aItens, {"C6_UM"     , kk_Unidade                              , Nil}) // Unidade de medida (primeira)
				aAdd(_aItens, {"C6_LOCAL"  , "01"   		                         , Nil}) // Armazem
				aAdd(_aItens, {"C6_CLI"    , cCodigo                                 , Nil}) // C�digo do cliente 
				aAdd(_aItens, {"C6_LOJA"   , cLoja                                   , Nil}) // Loja do cliente
				aAdd(_aItens, {"C6_CHASSI" , "X"                                     , Nil}) // % comiss�o vendedor 2
				aAdd(_aItens, {"C6_TURNO"  , "M"                                     , Nil}) // % comiss�o vendedor 2                                                                              
				aAdd(_aItens, {"C6_ENTREG" , Date()                                  , Nil}) // Data de Entrega
				aAdd(_aItens, {"C6_SUGENTR", Date()                                  , Nil}) // Data Sugerida
				aAdd(_aItens, {"C6_COMIS1" , xComis1                                 , Nil}) // % comiss�o vendedor 1
				aAdd(_aItens, {"C6_COMIS2" , xComis2                                 , Nil}) // % comiss�o vendedor 2	
				aadd(aItens, _aItens)
			Endif           

			// #################################################################################################################################################
			// Cfop deve ser deixado em branco. O pr�prio sistema pesquisa o CF adequado                                                                      ##
			// {"C6_CF"     , Alltrim(Posicione( "SF4", 1, xFilial("SF4") + kTES, "F4_CF"))              , Nil},; // Classifica��o fiscal do produto pela tes ##
			// #################################################################################################################################################

			// #################################
			// Display dos dados para analise ##
			// #################################
			Conout("Filial...............: " + xCodFil)                
			Conout("Numero PV............: " + cNumPed)
			Conout("Item.................: " + Strzero(nContar,02))
			Conout("Produto..............: " + Alltrim(U_P_CORTA(xCodPro,"|", nContar)))
			Conout("Unidade Medida.......: " + Alltrim(Posicione( "SB1", 1, xFilial("SB1") + kk_Produto, "B1_UM" )))
			Conout("Quantidade...........: " + U_P_CORTA(xQtdPro,"|", nContar))                                                     
			Conout("Preco Venda..........: " + U_P_CORTA(xPrcPro,"|", nContar))                                                     
			Conout("Preco Unitario.......: " + U_P_CORTA(xPrcPro,"|", nContar))                                                     
			Conout("Total Produto........: " + U_P_CORTA(xTotPro,"|", nContar))                                                     
			Conout("Tipo de Opera��o.....: " + xTipoOpe)
			Conout("TES..................: " + kTES)
			Conout("Classificacao Fiscal.: " + Alltrim(Posicione( "SF4", 1, xFilial("SSF4") + kTES, "F4_CF")))                           
			Conout("Armazem..............: " + "01")                                                                                                                                                                
			Conout("Codigo Cliente.......: " + cCodigo)
			Conout("Loja Cliente.........: " + cLoja)
			Conout("Data Entrega.........: " + Dtoc(dDataBase))
			Conout("Data Sugerida........: " + Dtoc(dDataBase))
			Conout("Descricao Produto....: " + Alltrim(Posicione( "SB1", 1, xFilial("SB1") + kk_Produto, "B1_DESC")))  
			Conout("Part Number..........: " + Alltrim(Posicione( "SB1", 1, xFilial("SB1") + kk_Produto, "B1_PARNUM")))
			Conout("Codigo Fabricante....: " + Posicione( "SB1", 1, xFilial("SB1") + kk_Produto, "B1_PROC"))           
			Conout("Loja Fabricante......: " + Posicione( "SB1", 1, xFilial("SB1") + kk_Produto, "B1_LOJPROC"))        
			Conout("Situacao Tributaria..: " + xSituacao)
			Conout("Status do Pedido.....: " + "01")
			Conout("Tem Documento........: " + "N")                                                                                       
			Conout("Rateio...............: " + "2")
			Conout("Tipo Ordem Producao..: " + "F")
			Conout("Nome da funcao.......: " + Alltrim(FUNNAME()))

		Next nContar

		// ##############################################################
		// Executa o comando de inclus�o autom�tica do pedido de venda ##
		// ##############################################################
		nModulo := 5  
		MsExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, _aCabec, aItens, 3, .F.) 
		//lMsErroAuto := U_MyMata410(_aCabec,_aItens,3)
		If lMsErroAuto
			Conout("Erro na inclus�o do pedido")
			//cString := MostraErro()
			cString := Mostraerro("at_gravapvenda","Error WS_AT_GRAVAPVENDA.txt")
			ConOut(cString)
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			////RESET ENVIRONMENT

			Return(.T.)
		Else

			If Alltrim(xTipPed) == "1"

				DbSelectArea("SC5")
				DbSetOrder(1)
				If DbSeek( xFilial("SC5") + cNumPed )
					Reclock("SC5",.F.)           
					//             SC5->C5_EXTERNO := "1"
					SC5->C5_FORNEXT := xForExt
					SC5->C5_LOJAEXT := xLojExt         
					SC5->C5_SDIS    := "1"
					//             SC5->C5_MENNOTA := xObsNota
					//             SC5->C5_OBSI    := xObsInte
					//             SC5->C5_OBSNT   := xObsDanf
					MsUnlock()

				Endif

			Else

				// #############################################
				// Se houve frete gratuito, bloqueia o pedido ##
				// #############################################
				If _FreteGratis == "S"

					DbSelectArea("SC5")
					DbSetOrder(1)
					If DbSeek( xFilial("SC5") + cNumPed )
						Reclock("SC5",.F.)           
						SC5->C5_BLQ := "3"
						MsUnlock()
					Endif

				Endif   

			Endif   

			// ##################################################################
			// Se transportadora = 000008 -> Correios, grava o tipo de servi�o ##
			// ##################################################################
			If xCodTra == "000008"

				DbSelectArea("SC5")
				DbSetOrder(1)
				If DbSeek( xFilial("SC5") + cNumPed )
					Reclock("SC5",.F.)           
					Do Case
						Case xTipoSrv == "1"
						SC5->C5_TSRV := "CORREIOS 41068-PAC"
						Case xTipoSrv == "2"
						SC5->C5_TSRV := "CORREIOS 40436-SEDEX"
						oTherwise 
						SC5->C5_TSRV := ""
					EndCase
					MsUnlock()
				Endif                

			Endif   

			Conout("Numero do pedido gerado: " + Alltrim(cNumPed))
			cString := "000 - " + Alltrim(cNumPed)
			::SetContentType("text/plain")
			::SetResponse(cString)  	
			////RESET ENVIRONMENT

			Return(.T.)
		EndIf

	Next nVezes   

	////RESET ENVIRONMENT

Return(.T.)        

// ############################################################################
// Fun��o que seta a Empresa e Filial conforme par�metros recebidos pela URL ##
// ############################################################################
Static Function ALTEMPFIL(K_Empresa, k_Filial)

	Local cEmp := k_Empresa
	Local cFil := k_Filial

	dbcloseall()
	cempant := cEmp
	cfilant := cFil 
	cNumEmp := cEmp  + cFil
	Opensm0(cempant  + cfil)
	Openfile(cempant + cfil)
	lrefresh :=.T.

Return

// ------------------------------------------------------------------------------------------------------------------------------------------------------- ##
// Par�metros para testar o web service                                                                                                                    ##
// ------------------------------------------------------------------------------------------------------------------------------------------------------- ##
// Exemplo de chamada da URL + Par�mentros
// http://54.94.245.225:8094/rest/AT_GRAVAPVENDA?cCodEmp=01&cCodFil=01&cTipPed=2&cCGCCli=02.836.152/0001-54&cCodCon=A VISTA - DINHEIRO&cCodAdm=02&cTipFre=C&cValFre=50.00&cCodTra=000008&cCodVen1=000001&cCodVen2=&cCodMoe=1|&cForExt=000011&cLojExt=001&cCodPro=13493|&cQtdPro=1|&cPrcPro=1000.00|&cTotPro=1000.00|&cComis1=0.50|&cComis2=0.00|&cIsento=0&cContrib=1&cFormaPG=1&cProposta=000001&cObsNota=&cObsInte=&cObsDanf=&cCodGrv=N
// Static Function imppvsp(P01, P02, P03, P04, P05, P06, P07, P08, P09, P10, P11, P12, P13, P14, P15, P16, P17, P18, P19, P20, P21, P22, P23, P24, P25)    ##
// imppvsp("01",; // Empresa                                                                                                                               ##
//         "01",; // Filial                                                                                                                                ##
//         "1" ,; // Tipo de Pedido                                                                                                                        ##
//         "02836152000154",;                                                                                                                              ##
//         "HARALD HANS LOSCHENKOHL#AV CARLOS VENTURA, 440 AP 202#RS#ENGENHO#GUAIBA#92500000#51#984825852#147/8243616#harald@automatech.com.br#HARALD#",;  ##
//         "A VISTA - DINHEIRO                      "     ,;                                                                                               ##
//         "02"      ,;                                                                                                                                    ##
//         "C"       ,;                                                                                                                                    ##
//         "50.00"   ,;                                                                                                                                    ##
//         "000008"  ,;                                                                                                                                    ##
//         "000001"  ,;                                                                                                                                    ##
//         "      "  ,;                                                                                                                                    ##
//         "1"       ,;                                                                                                                                    ##
//         "000011"  ,; //                                                                                                                                 ##
//         "001"     ,; //                                                                                                                                 ##
//         "004442#" ,;                                                                                                                                    ##
//         "1#"      ,;                                                                                                                                    ##
//         "1000.00#",;                                                                                                                                    ##
//         "1000.00#",;                                                                                                                                    ##
//         "0.50#"   ,;                                                                                                                                    ##
//         "0.00#"   ,;                                                                                                                                    ##
//         "0"       ,;                                                                                                                                    ##
//         "1"       ,;                                                                                                                                    ##
//         "1"       ,;                                                                                                                                    ##
//         "000001")                                                                                                                                       ##
// ------------------------------------------------------------------------------------------------------------------------------------------------------- ##

//Tabela de retornos do Web Service Pedido de Venda Protheus                                       
//-------------------------------------------------------------------------------------------------
//000 - Inclus�o de pedido de venda com sucesso                                                    
//001 - C�digo da Empresa n�o informada                                                            
//002 - C�digo da Filial n�o informada                                                             
//003 - Tipo de Pedido de Venda n�o informado                                                      
//004 - CNPJ/CPF do Cliente n�o informado                                                          
//005 - Condi��o de Pagamento n�o informada                                                        
//006 - Reservado
//007 - Tipo de frete n�o informado                                                                
//008 - Valor do Frete                                                                             
//009 - Transportadora                                                                             
//010 - C�digo vendedor 1 n�o informado                                                            
//011 - C�digo da moeda n�o informada                                                              
//011 - C�digo do fornecedor externo n�o informado                                                 
//012 - C�digo da loja do fornecedor externo n�o informada                                         
//013 - C�digo(s) do(s) produto(s) do pedido de venda n�o informado(s)                             
//014 - Informa��o do(s) c�digo(s) do(s) produto(s) inconsist�nte (Sem informa��o do |)            
//015 - C�digo(s) do(s) produto(s) do pedido de venda n�o informado(s)                             
//016 - Informa��o da(s) quantidade(s) do(s) produto(s) inconsist�nte (Sem informa��o do |)        
//017 - Pre�o(s) unit�rio(s) do(s) produto(s) n�o informado(s)                                     
//018 - Informa��o do(s) pre�o(s) unit�rio(s) do(s) produto(s) inconsist�nte (Sem informa��o do |) 
//019 - Valor Total do(s) produto(s) n�o informado(s)                                              
//020 - Informa��o do(s) total(is) do(s) produto(s) inconsist�nte (Sem informa��o do |)            
//021 - Percentual de comiss�o para o vendedor 1 n�o informada                                     
//022 - Percentual de comiss�o para o vendedor 2 n�o informada                                     
//023 - Conte�do do tipo de pedido de venda � inv�lido (Aceitos 1 ou 2)                            
//024 - Dados Cadastrais do Cliente                                                                
//025 - Nome do cliente n�o informado                                                              
//026 - Endere�o do cliente n�oo informado                                                         
//027 - UF do cliente n�o informado                                                                
//028 - Bairro do cliente n�o informado                                                            
//029 - Munic�pio do cliente n�o informado                                                         
//030 - CEP do endere�o do cliente n�o informado                                                   
//031 - DDD do telefone do cliente n�o informado                                                   
//032 - Telefone do cliente n�o informado                                                          
//033 - Inscri��o Estadual do cliente n�o informada                                                
//034 - E-mail do cliente n�o informado                                                            
//035 - Contato do cliente n�o informado                                                           
//036 - Indica��o de IE Isenta n�o informada                                                       
//037 - Informa��o do campo IE Isenta inconsistente (Aceitos somenete 0 ou 1)                      
//038 - Cliente contribuinte n�o informado                                                            
//039 - Informa��o do campo Cliente Contribuinte inconsistente (Aceitos somenete 0 ou 1)           
//040 - Reservado
//041 - Reservado
//042 - Erro ao gravar pedido de venda                                                             
//043 - N� da proposta comercial n�o informada                                                     
//044 - Cliente inexistente no Protheus                                                            
//045 - Informa��o da(s) moeda(s) inconsist�nte (Sem informa��o do |)                              
//046 - Vendedor 1 n�o cadastrado                                                                  
//047 - Vendedor 2 n�o cadastrado                                                                  
//048 - Dados Cadastrais do cliente (Par�metros aguardados n�o recebidos)                          
//
//URL
//
//http://54.94.245.225:8094/rest/AT_GRAVAPVENDA?cCodEmp=01&cCodFil=01&cTipPed=2&cCGCCli=02.836.152/0001-54&cCodCon=A VISTA - DINHEIRO&cTipFre=C&cValFre=50.00&cCodTra=000008&cCodVen1=000001&cCodVen2=&cCodMoe=1|&cForExt=000011&cLojExt=001&cCodPro=13493|&cQtdPro=1|&cPrcPro=1000.00|&cTotPro=1000.00|&cComis1=0.50|&cComis2=0.00|&cIsento=0&cContrib=1&cProposta=000001&cObsNota=&cObsInte=&cObsDanf=
//
//onde or par�metros s�o:
//
//?cCodEmp=01                 -> C�digo da Empresa a que se refere a proposta comercial
//&cCodFil=01                 -> C�digo da Filial a que se refere a proposta comercial
//&cTipPed=2                  -> Tipo da Proposta Comercial (1 = Pedido de Intermedia��o, 2 = Pedido Normal)
//&cCGCCli=02.836.152/0001-54 -> CNPJ do Cliente
//&cDadosCli=<Nome do Cliente>|<Endere�o do Cliente>|<Estado>|<Bairro>|<Cidade>|<Cep>|<DDD>|<Telefone>|<Inscri��o Estadual>|<E-mail>|<Nome Contato>|<Indica��o IE Isenta>|<Indica��o Contribuinte>|Complementos Endere�o|
//                            -> Dados cadastrais para inclus�o do cliente
//&cCodCon=A VISTA - DINHEIRO -> Condi��o de Pagamento
//&cTipFre=C                  -> Tipo de Frete (C = CIF, F = FOB)
//&cValFre=50.00              -> Valor do Frete
//&cCodTra=000008             -> C�digo da Transportadora
//&cCodVen1=000001            -> C�digo Vendedor 1
//&cCodVen2=                  -> C�digo vendedor 2
//&cCodMoe=1|                 -> Moeda da proposta
//&cForExt=000011             -> C�digo Fornecedor Externo
//&cLojExt=001                -> Loja Fornecedor Externo
//&cCodPro=13493|             -> N� do Registro do Produto na tabela SB1
//&cQtdPro=1|                 -> Quantidade dos Produtos
//&cPrcPro=1000.00|           -> Pre�o Unit�rio dos Produtos
//&cTotPro=1000.00|           -> Valor Total dos Produtos
//&cComis1=0.50|              -> % Comiss�o vendedor 1
//&cComis2=0.00|              -> % Comiss�o vendedor 2
//&cIsento=0                  -> Indica se IE do cliente � Isento onde 0 = Isento, 1 = N�o Isento
//&cContrib=1                 -> Indica se Cliente � contribuinte onde 0 = N�o Contribuinte, 1 = Contribuinte
//&cProposta=000001           -> N� da Proposta Comercial
//&cObsNota=                  -> Campo Observa��es que ser�o impressos na nota fiscal
//&cObsInte=                  -> Campo Observa��es Internas
//&cObsDanf=                  -> Campo Observa��es para Danfe


//&cDadosCli=<Nome do Cliente>|<Endere�o do Cliente>|<Estado>|<Bairro>|<Cidade>|<Cep>|<DDD>|<Telefone>|<Inscri��o Estadual>|<E-mail>|<Nome Contato>|<Indica��o IE Isenta>|<Indica��o Contribuinte>|

//HARALD HANS LOSCHENKOHL|AV CARLOS VENTURA, 440 AP 202|RS|ENGENHO|GUAIBA|92500000|51|984825852|147/8243616|harald@automatech.com.br|HARALD|1|1|