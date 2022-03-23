#include 'protheus.ch'

//��������������������������������������������������������Ŀ
//� Este ponto  de entrada  tem a finalidade de confirmar  �
//� ou nao a inclusao.                                     �
//����������������������������������������������������������

User Function MT380INC()
    Local cENTER	:= CHR(13)+ CHR(10)
    Local cUserId   := RetCodUsr()
    Local cCompName := ComputerName()
    Local cMsgAlt   := ""
    Local cNumOP    := SD4->D4_OP


//Regra: Se for Alterado empenho avisa os respons�veis por email
    If Altera
    /*
    V�ri�veis e campos de copara��o:
    nQtdAnt	   <=> M->D4_QUANT      // Sal. Empenho
    
    nQtdAnt2UM <=> M->D4_QTSEGUM    // Qtd Seg. UM
    nQtdOriAnt <=> M->D4_QTDEORI    // QTD EMPENHADA
    cLoteAnt   <=> M->D4_NUMLOTE
    cLotCtlAnt <=> M->D4_LOTECTL
    cLocal	   <=> M->D4_LOCAL
    */
        IF SD4->D4_QUANT <>  M->D4_QUANT
            cMsgAlt += "Sal. Empenho : Conte�do Anterior (" + AllTrim(STR(SD4->D4_QUANT)) + ") > Novo Conte�do: (" + AllTrim(STR(M->D4_QUANT)) + ")" + cENTER
        ENDIF
        IF SD4->D4_QTDEORI <> M->D4_QTDEORI
            cMsgAlt += "Qtd. Empenho : Conte�do Anterior (" + AllTrim(STR(SD4->D4_QTDEORI)) + ") > Novo Conte�do: (" + AllTrim(STR(M->D4_QTDEORI)) + ")" + cENTER
        ENDIF

    Endif

    IF !Empty(cMsgAlt)
        cMsgAlt := "- REALIZADO ALTERA��ES EM OP - " +  cENTER;
            + "Usu�rio: " + cUserId + " - " + cUserName + cENTER;
            + "Computador:" + cCompName + cENTER
        + "Rotina: " +  FunName() + cENTER
        + "Altera��es Efetuadas no Empenho da OP:  " + cNumOP + cENTER;
            + cMsgAlt

        _cMailFrom := "protheus@marcher.com.br"
        _cMailTo   := SuperGetMV("MA_EMLD4AL",,"marcio.borges@solutio.inf.br") //Envia email altera��o SD4
        _cCC       := ""
        _cSubject  := "Altera��es de Empenho - SD4"
        _cBody     := cMsgAlt
        SendWFMail(_cMailFrom,_cMailTo,_cCC,_cSubject,_cBody,_cAnexo)

    ENDIF



Return NIL


Static Function SendWFMail(_cMailFrom,_cMailTo,_cCC,_cSubject,_cBody,_cAnexo)
    Local _cProdAmb		:= SuperGetMV("MV_AMBPROD",,"PRODUCAO") // Ambientes para considerar como producao

    DEFAULT _cSubject 			:= "[sem assunto]"
    DEFAULT _cAnexo   	:= ""
    DEFAULT _cBody 	   	:= ""
    DEFAULT _cAnexo		:= ""
    DEFAULT _cMailFrom := SuperGetMV("MA_EMLCOM",,"compras@marcher.com.br") // Se n�o vier preenchido o email usar� o do compras


// ###########################################################################################
    // Informa o Codigo do Status do Processo Correspondente ao In�cio do envio do email  WF ##
    // ########################################################################################
    cCodigoStatus  := "100100"
    cDescricao     := "INICIO DO PROCESSO  PROCESSO DE ENVIO DE EMAIL"

    // ####################################################################
    // Ratreabilidade com o Codigo do Status, Descricao e Usuario Logado ##
    // ####################################################################
    oProcess:Track( cCodigoStatus, cDescricao )

// ####################
// Assunto do E-mail ##
// ####################
// Se n�o for ambientes de producao, adiciona mensagem de teste no assunto
    If !(UPPER(Alltrim(GetEnvServer())) $ UPPER(_cProdAmb ))
        _cSubject := "TESTE - FAVOR DESCONSIDERAR: " + _cSubject
    Endif

// ####################################################################
// Caminho e Arquivo HTML                                            ##
// ####################################################################
    cArqHtml := SuperGetMV("MA_HTMLBPC",,"\workflow\WFEmpenhoSD4.html")
// #####################################################
// Inicia o Processo de WorkFlow de Cota��o de Pre�os ##
// #####################################################
    oProcess := TWFProcess():New( "SENDML", _cSubject )
    oProcess:NewVersion(.T.)

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
// Carrega a Data de Refer�ncia para display no HTML ##
// ####################################################
    oHtml   := oProcess:oHTML

    cTitulo := "LOG DE ALTERA��O DE EMPENHO"
    oHtml:ValByName("TITULO", cTitulo)

    oHtml:ValByName("MENSAGEM", _cBody)

    oHtml:ValByName("PROGRAMA", "PE_MT380INC")

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