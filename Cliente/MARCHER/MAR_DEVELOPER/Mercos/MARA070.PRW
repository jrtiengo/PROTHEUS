#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
/*
{Protheus.doc} MARA070
Programa que fará a atualização dos pedidos de venda no Protheus pelo
webservice da Mercos
@type User function
@author Jean Rehermann - Solutio
@since 15/11/2021
*/
User Function MARA070()

	Private lBlind   := IsBlind()
	Private bProcInc := {|| Iif( !lBlind, IncProc(), 0 ) }
	Private aLogMerc := {}

	If lBlind
		EnvMercos() // Criar o ambiente de execução
	Else
		ProcRegua(0) // Atualizar a régua de processamento
	EndIf

	Eval( bProcInc )

	// Buscar os pedidos
	ApiPVMerc()

Return

/*
Cria o ambiente para a execução do processo no schedule
*/
Static Function EnvMercos()

	Local cRpcEmp		:= "99"	     // Empresa
	Local cRpcFil		:= "01"	     // Filial Principal
	Local cEnvUser		:= "admin"
	Local cEnvPass		:= ""
	Local cEnvMod		:= "FAT"     // Modulo
	Local cFunName		:= "MARA060" // Funcao
    Local aTables 		:= {"SB1","SA1"}

	RpcSetEnv( cRpcEmp , cRpcFil , cEnvUser, cEnvPass, cEnvMod, cFunName , aTables, , , ,  )

Return Nil

/*
Efetua a atualização dos produtos no site da Mercos
*/
Static Function ApiPVMerc()

		Local nX := 0

        aAdd(aCabec,{"C5_TIPO"   , 'N'              , NIL})
        aAdd(aCabec,{"C5_CLIENTE", cCliente         , NIL})
        aAdd(aCabec,{"C5_LOJACLI", cLoja            , NIL})
        aAdd(aCabec,{"C5_CLIENT ", cCliente         , NIL})
        aAdd(aCabec,{"C5_LOJAENT", cLoja            , NIL})
        aAdd(aCabec,{"C5_CONDPAG", cCondPG          , NIL})
        aAdd(aCabec,{"C5_TABELA" , cTabPreco        , NIL})
        aAdd(aCabec,{"C5_NATUREZ", cNaturez         , NIL})
        aAdd(aCabec,{"C5_TPFRETE", cTpFrete         , NIL})
        aAdd(aCabec,{"C5_FRETE"  , nValFrete        , NIL})
        aAdd(aCabec,{"C5_TIPOCLI", SA1->A1_TIPO     , NIL})
        aAdd(aCabec,{"C5_STATMAG", cStatus          , NIL})
        aAdd(aCabec,{"C5_ENTITY" , cEntity          , NIL})
        aAdd(aCabec,{"C5_INCREME", cIncrem          , NIL})
        aAdd(aCabec,{"C5_DESC1"  , nPDesCab         , NIL}) // % do desconto
        aAdd(aCabec,{"C5_INDPRES", "2"              , NIL})

        DbSelectArea("SB1")
        DbSetOrder(1)

        //Busca os itens no JSON, percorre eles e adiciona no array da SC6
        oItems := oJson:GetJsonObject('Items')
        For nX := 1 To Len (oItems)
            aLinha := {}
            cCodProd := AllTrim( oItems[nX]:GetJsonObject('C6_PRODUTO') )

            // cTES := IIF( SA1->A1_EST == aSM0Dados[nPosEst, 2], cTESInter, cTESExter )
            cTES := MaTesInt( 2/*Saida/Venda*/, "01"/*cOperac*/, cCliente, cLoja, "C"/*Cliente*/, cCodProd )
            If Empty( cTES )
                SetRestFault( ERRORCODE_DEF, EncodeUTF8( "Para o Produto " + cCodProd + " não foi localizada TES conforme as regras da TES Inteligente." ) )
                lRet := .F.
                Break
            EndIf

            If( ValType( oItems[nX]:GetJsonObject('C6_ENTREG') ) <> "C" .Or. Empty( oItems[nX]:GetJsonObject('C6_ENTREG') ) )
                SetRestFault( ERRORCODE_DEF, EncodeUTF8( "Data de entrega não informada." ) )
                lRet := .F.
                Break
            EndIf

            If( ValType( oItems[nX]:GetJsonObject('C6_HRENTRE') ) <> "C"  .Or. Empty( oItems[nX]:GetJsonObject('C6_HRENTRE') ) )
                SetRestFault( ERRORCODE_DEF, EncodeUTF8( "Hora de entrega não informada." ) )
                lRet := .F.
                Break
            EndIf

            If ! SB1->( dbSeek( xFilial("SB1") + PadR( cCodProd, nTamPrd ) ) )
                SetRestFault( ERRORCODE_DEF, EncodeUTF8("Produto " + cCodProd + " não localizado no cadastro.") )
                lRet := .F.
                Break
            EndIf

            cDtEntreg := Replace( oItems[nX]:GetJsonObject('C6_ENTREG'), "\", "" )

            If Empty( cEntrega )
                cEntrega := "Entrega prevista em " + cDtEntreg + " entre " + oItems[nX]:GetJsonObject('C6_HRENTRE')
            EndIf

            nQtdVen   := IIF( ValType(oItems[nX]:GetJsonObject('C6_QTDVEN'))=="N", oItems[nX]:GetJsonObject('C6_QTDVEN'), 0 )
            nPrcVen   := IIF( ValType(oItems[nX]:GetJsonObject('C6_PRCVEN'))=="N", oItems[nX]:GetJsonObject('C6_PRCVEN'), 0 )
            nVlrTot   := IIF( ValType(oItems[nX]:GetJsonObject('C6_VALOR'))=="N" , oItems[nX]:GetJsonObject('C6_VALOR') , 0 )

            // % de Desconto
            nDescItem := IIF( ValType(oItems[nX]:GetJsonObject('C6_DESCONT'))=="N", oItems[nX]:GetJsonObject('C6_DESCONT'), 0 )

            aAdd(aLinha,{"C6_ITEM"   , StrZero(nX,2)                                  , NIL})
            aAdd(aLinha,{"C6_PRODUTO", cCodProd                                       , NIL})
            aAdd(aLinha,{"C6_QTDVEN" , nQtdVen                                        , NIL})
            aAdd(aLinha,{"C6_QTDLIB" , nQtdVen                                        , NIL})
            aAdd(aLinha,{"C6_PRCVEN" , nPrcVen                                        , NIL})
            aAdd(aLinha,{"C6_VALOR"  , nVlrTot                                        , NIL})
            aAdd(aLinha,{"C6_TES"    , cTES                                           , NIL})
            aAdd(aLinha,{"C6_ENTREG" , CtoD(cDtEntreg)                                , NIL})
            aAdd(aLinha,{"C6_HRENTRE", oItems[nX]:GetJsonObject('C6_HRENTRE')         , NIL})
            aAdd(aLinha,{"C6_DESCONT", nDescItem                                      , NIL})
            aAdd(aItens,aLinha)
        Next nX

        aAdd(aCabec,{"C5_MENNOTA", cEntrega , NIL})
        aAdd(aCabec,{"C5_OBS", cObs, NIL})

        //Chama a inclusão automática de pedido de venda
        MsExecAuto( { |x, y, z| MATA410( x, y, z ) }, aCabec, aItens, 3 )

        //Se houve erro, gera um arquivo de log dentro do diretório da protheus data
        IF lMsErroAuto

            cArqLog   := cCliente + cLoja + "_" + DtoS(Date()) + "_" + StrTran(Time(), ':', '')+".log"
            cErro     := ""
            aLogAuto  := {}
            aLogAuto  := GetAutoGrLog()
            For nX := 1 To Len(aLogAuto)
                cErro += aLogAuto[nX] + CRLF
            Next
            MemoWrite( cDirLog + cArqLog, cErro + CRLF + "JSON recebido: " + cJson )
            lRet    := .F.
            SetRestFault(ERRORSRV_DEF, EncodeUTF8(cErro) )
        Else

			DbSelectArea("SC5")
			DbSetOrder(1)

			// Mesmo dando ok o PV pode não ter sido incluído
			If SC5->( dBSeek( cFilWS + SC5->C5_NUM ) )

                cJsonRet := '{"Sucesso":"'+SC5->C5_NUM+'"}'
                Self:SetResponse(cJsonRet)
			Else
                lRet    := .F.
                MemoWrite( cDirLog + DtoS(Date()) + "_" + StrTran(Time(), ':', '')+".log", cErro + CRLF + "JSON recebido: " + cJson )
                SetRestFault(ERRORSRV_DEF, EncodeUTF8("Erro na execução da rotina automática MATA410") + CRLF + "JSON recebido: " + cJson )

			EndIf

        EndIF

Return
