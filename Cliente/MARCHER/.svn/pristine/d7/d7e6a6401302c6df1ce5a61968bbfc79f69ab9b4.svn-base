#include 'protheus.ch'
//#include 'parmtype.ch'


/*/{Protheus.doc} PE_A650PROC
//TODO Rotina: Ordem de Produção (MATA650 
O ponto de entrada 'A650PROC' é executado após o processamento da inclusão da(s) Op(s) 
e/ou solicitação de compra(s). Dependendo do número de Op´s ou solicitações de compras que 
foram processadas não é possível estar posicionado em tais registros, ou seja, se o cliente necessitar 
posicionar em um Op ou solicitação de compras específica, este deverá se encarregar disso.
@author MárcioQBorges
@since 13/09/2019
@version 1.0

@type function
/*/

user function A650PROC()
	Local cENTER      := CHR(13)+ CHR(10)
	Local cUserId     := RetCodUsr()
	Local cCompName   := ComputerName()
	Local cDif        := "" //Diferenças entre Estrutura e Empenho
	Local cTxt        := ""
	Local x
	Local cFirmPrev   := " "
	Local lMA_LOGD4FP := SuperGetMV("MA_LOGD4FP",,"F" ) //Indica o tipo de OP que deve logar a explosão 

	//paramixb[1] // produto
	//Alert('A650PROC - teste mais de uma op:'+ SC2->(C2_NUM + C2_ITEM + C2_SEQUEN))

	If !(SC2->C2_TPOP $ lMA_LOGD4FP)
		Return NIL
	Endif 


	If  SC2->C2_TPOP == 'P'
		cFirmPrev := " PREVISTA "
	Else
		cFirmPrev := " FIRME "
	Endif


	If Type("aOPEMP") <> 'U' //OP´s Empenhadas
		//aOPEMP := {} //Cria variável publica no contexto do MATA650 (PE_MA650EMP.PRW)

		cTxt := ArrTokStr(aOPEMP)
		cTxt := STRTRAN(cTxt,"|",cENTER) + cENTER
		MemoWrite("c:\temp\A650PROC-ArrTokStr-aOPEMP.txt",cTxt)

		For x:= 1 TO LEN(aOPEMP)

			cDif :=  u_ESTREMP(aOPEMP[x])   // u_VLD_OPG1(aOPEMP[x])

			If !Empty(cDif)
				cMsgAlt := "Empenho x Estrutura - Divergência encontrada - OP " + cFirmPrev +  aOPEMP[x] +  cENTER;
					+ "Usuário: " + cUserId + " - " + cUserName + cENTER;
					+ "Computador:" + cCompName + cENTER;
					+ "Diferenças entre Estrutura e Empenho da OP:  " + aOPEMP[x] + cENTER;
					+ cDif

				_cMailFrom := "protheus@marcher.com.br"
				_cMailTo   := SuperGetMV("MA_EMLD4AL",,"protheus@marcher.com.br") //Envia email alteração SD4
				_cCC       := ""
				_cSubject  := "Empenho x Estrutura - Divergência encontrada - OP " + cFirmPrev + aOPEMP[x]
				_cBody     := cMsgAlt
				_cAnexo	   := ""
				SendWFMail(_cMailFrom,_cMailTo,_cCC,_cSubject,_cBody,_cAnexo)
			Else
				cMsgAlt := "Empenho x Estrutura -  Nenhuma Divergência (log) - OP " + cFirmPrev +  aOPEMP[x] +  cENTER;
					+ "Usuário: " + cUserId + " - " + cUserName + cENTER;
					+ "Computador:" + cCompName + cENTER;
					+ "Rotina: " +  FunName() + cENTER;
					+ "OP:  " + aOPEMP[x] + cENTER

				//"---------------------";
					//"       Empenho:";
					//"---------------------";


				_cMailFrom := "protheus@marcher.com.br"
				_cMailTo   := SuperGetMV("MA_EMLD4AL",,"protheus@marcher.com.br") //Envia email alteração SD4
				_cCC       := ""
				_cSubject  := "Empenho x Estrutura -  Nenhuma Divergência (log) - OP " + cFirmPrev + aOPEMP[x]
				_cBody     := cMsgAlt
				_cAnexo	   := ""
				SendWFMail(_cMailFrom,_cMailTo,_cCC,_cSubject,_cBody,_cAnexo)

			Endif
		Next x

	Endif




return NIL


Static Function SendWFMail(_cMailFrom,_cMailTo,_cCC,_cSubject,_cBody,_cAnexo)
	Local cENTER	:= CHR(13)+ CHR(10)
	Local _cProdAmb	:= SuperGetMV("MV_AMBPROD",,"PRODUCAO") // Ambientes para considerar como producao


	DEFAULT _cSubject 			:= "[sem assunto]"
	DEFAULT _cAnexo   	:= ""
	DEFAULT _cBody 	   	:= ""
	DEFAULT _cAnexo		:= ""
	DEFAULT _cMailFrom := SuperGetMV("MA_EMLCOM",,"compras@marcher.com.br") // Se não vier preenchido o email usará o do compras




// ####################
// Assunto do E-mail ##
// ####################
// Se não for ambientes de producao, adiciona mensagem de teste no assunto
	If !(UPPER(Alltrim(GetEnvServer())) $ UPPER(_cProdAmb ))
		_cSubject := "TESTE - FAVOR DESCONSIDERAR: " + _cSubject
	Endif

// ####################################################################
// Caminho e Arquivo HTML                                            ##
// ####################################################################
	cArqHtml := SuperGetMV("MA_HTMLD4A",,"\workflow\WFEmpenhoSD4.html")
// #####################################################
// Inicia o Processo de WorkFlow de Cotação de Preços ##
// #####################################################
	oProcess := TWFProcess():New( "SENDML", _cSubject )
	oProcess:NewVersion(.T.)

	// ###########################################################################################
	// Informa o Codigo do Status do Processo Correspondente ao Início do envio do email  WF ##
	// ########################################################################################
	cCodigoStatus  := "100100"
	cDescricao     := "INICIO DO PROCESSO  PROCESSO DE ENVIO DE EMAIL"

	// ####################################################################
	// Ratreabilidade com o Codigo do Status, Descricao e Usuario Logado ##
	// ####################################################################
	oProcess:Track( cCodigoStatus, cDescricao )

// #########################################################
// Cria uma Nova Tarefa Informando o HTML do Link de Envio ##
// ##########################################################
	oProcess:NewTask( "Envio", cArqHtml )

// ################################################################
// Cria Objeto HTML do Processo de WorkFlow                      ##
// ################################################################
//oHtml := o2Process:oHTML


// ###################
// ## Anexa arquivo ##
// ###################
	If FILE(_cAnexo)
		oProcess:AttachFile(_cAnexo)
	Endif

// #####################################################################################
// E-mail que Ira Receber a Notificacao de Aprovacao/Rejeicao do Processo de WorkFlow ##
// #####################################################################################
	oProcess:cTo      := _cMailTo
	oProcess:cCC      := _cCC

// ################################################################################################
// Assunto do E-mail que Ira Receber a Notificacao de Aprovacao/Rejeicao do Processo de WorkFlow ##
// ################################################################################################
	oProcess:cSubject := _cSubject


// ####################################################
// Carrega a Data de Referência para display no HTML ##
// ####################################################
	oHtml   := oProcess:oHTML

	cTitulo := "LOG DE ALTERAÇÃO DE EMPENHO"
	oHtml:ValByName("TITULO", cTitulo)




	_cBody := STRTRAN(_cBody, cENTER,"<br>") ////Altera ENTER por <br>
	oHtml:ValByName("MENSAGEM", _cBody)

	oHtml:ValByName("PROGRAMA", "PE_A650PROC")

// #############################################################################
// Cria e Inicia o Processo de Envio de E-mail do WorkFlow de Ordem de Compra ##
// #############################################################################
	oProcess:Start()

// #######################
// Finaliza o Processo  ##
// #######################
	oProcess:Finish()


// #######################################################################################
// Informa o Codigo do Status do Processo Correspondente ao Final do envio do email  WF ##
// #######################################################################################
	cCodigoStatus  := "100400"
	cDescricao     := "FINALIZANDO PROCESSO DE ENVIO DE EMAIL"

	// ####################################################################
	// Ratreabilidade com o Codigo do Status, Descricao e Usuario Logado ##
	// ####################################################################
	oProcess:Track( cCodigoStatus, cDescricao )

Return
