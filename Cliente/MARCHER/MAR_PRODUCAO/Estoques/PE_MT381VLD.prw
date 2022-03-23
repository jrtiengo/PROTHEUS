#include 'protheus.ch'

////Rotina: Empenho Multiplo (MATA381)
//��������������������������������������������������������Ŀ
//� Este ponto  de entrada  tem a finalidade de confirmar  �
//� ou nao a inclusao.                                     �
//����������������������������������������������������������

User Function MT381VLD()
    Local cENTER	:= CHR(13)+ CHR(10)
    Local cUserId   := RetCodUsr()
    Local cCompName := ComputerName()
    Local cMsg      := ""
    Local lRet		:= .T.
    Local i 


    //Regra: Se for Alterado empenho avisa os respons�veis por email
    If l381Alt //Altera��o
        For i:=1 to Len(aColsOri) // aColsValid <- acols atual
            IF	aCols[i,Len(aCols[i])] == .T. //registro deletado
            	cMsg += "Linha " + STRZERO(i,3) + " |  Cod. produto:  Registro Exclu�do" + cENTER
            ELSEIF aColsOri[i,nPosCod] <> aCols[i,nPosCod]
                cMsg += "Linha " + STRZERO(i,3) + " |  Cod. produto: Conte�do Anterior (" + aColsOri[i,nPosCod] + ") > Novo Conte�do: (" + aCols[i,nPosCod] + ")" + cENTER

            ELSE
                IF aColsOri[i,nPosQuant] <> aCols[i,nPosQuant]
                    cMsg += "Linha " + STRZERO(i,3) + " | Produto: " + aCols[i,nPosCod] + " | Sal. Empenho : Conte�do Anterior (" + AllTrim(STR(aColsOri[i,nPosQuant])) + ") > Novo Conte�do: (" + AllTrim(STR(aCols[i,nPosQuant])) + ")" + cENTER
                ENDIF
                IF aColsOri[i,nPosQtdOri] <> aCols[i,nPosQtdOri]
                    cMsg += "Linha " + STRZERO(i,3) + " | Produto: " + aCols[i,nPosCod] + " | Qtd. Empenho : Conte�do Anterior (" + AllTrim(STR(aColsOri[i,nPosQtdOri])) + ") > Novo Conte�do: (" + AllTrim(STR(aCols[i,nPosQtdOri])) + ")" + cENTER
                ENDIF

            ENDIF
        Next i

    ELSEIF l381Exc //Exclus�o // MT381EXC
        cMsg := " *** EMPENHO EXCLU�DO *** "
    ENDIF
    
    IF !Empty(cMsg)
        cMsg := "- REALIZADO ALTERA��ES EM OP - " +  cENTER;
            + "Usu�rio: " + cUserId + " - " + cUserName + cENTER;
            + "Computador:" + cCompName + cENTER;
            + "Rotina: " +  FunName() + cENTER;
            + "Ambiente: " + UPPER(Alltrim(GetEnvServer())) + cENTER;
            + "Altera��es Efetuadas no Empenho da OP:  " + cOP + cENTER;
            + cMsg

        _cMailFrom := "protheus@marcher.com.br"
        _cMailTo   := SuperGetMV("MA_EMLD4AL",,"marcio.borges@solutio.inf.br") //Envia email altera��o SD4
        _cCC       := ""
        _cSubject  := "Altera��es de Empenho na OP " + cOP
        _cBody     := cMsg
        _cAnexo	   := ""
        SendWFMail(_cMailFrom,_cMailTo,_cCC,_cSubject,_cBody,_cAnexo)

    ENDIF



Return lRet


Static Function SendWFMail(_cMailFrom,_cMailTo,_cCC,_cSubject,_cBody,_cAnexo)
	Local cENTER	:= CHR(13)+ CHR(10)
    Local _cProdAmb		:= SuperGetMV("MV_AMBPROD",,"PRODUCAO") // Ambientes para considerar como producao

    DEFAULT _cSubject 			:= "[sem assunto]"
    DEFAULT _cAnexo   	:= ""
    DEFAULT _cBody 	   	:= ""
    DEFAULT _cAnexo		:= ""
    DEFAULT _cMailFrom := SuperGetMV("MA_EMLCOM",,"compras@marcher.com.br") // Se n�o vier preenchido o email usar� o do compras




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
    cArqHtml := SuperGetMV("MA_HTMLD4A",,"\workflow\WFEmpenhoSD4.html")
// #####################################################
// Inicia o Processo de WorkFlow de Cota��o de Pre�os ##
// #####################################################
    oProcess := TWFProcess():New( "SENDML", _cSubject )
    oProcess:NewVersion(.T.)

    // ###########################################################################################
    // Informa o Codigo do Status do Processo Correspondente ao In�cio do envio do email  WF ##
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
// Carrega a Data de Refer�ncia para display no HTML ##
// ####################################################
    oHtml   := oProcess:oHTML

    cTitulo := "LOG DE ALTERA��O DE EMPENHO"
    oHtml:ValByName("TITULO", cTitulo)

    
    _cBody := STRTRAN(_cBody, cENTER,"<br>") ////Altera ENTER por <br>
    oHtml:ValByName("MENSAGEM", _cBody)

    oHtml:ValByName("PROGRAMA", "PE_MT381VLD")

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