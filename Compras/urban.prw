#INCLUDE 'TOTVS.CH'
#INCLUDE 'RESTFUL.CH'

#DEFINE ERRORCODE_DEF	400
#DEFINE ERRORSRV_DEF	500

/*/
WebService REST para Inclusão e alteração do Statu do PV.
@version 12.1.25
@author Jorge Alberto - Solutio
@since 26/05/2021
/*/
WSRESTFUL PedidoVenda;
DESCRIPTION 'API personalizada para manutenção de Pedidos de Venda';
SECURITY 'MATA410';
FORMAT APPLICATION_JSON

	WSDATA entity_id	 As String
	WSDATA increment_id	 As String
	WSDATA Status   	 As String

    WSMETHOD POST IncluiPV;
	DESCRIPTION 'Inclusão de pedidos de venda';
	WSSYNTAX '/PedidoVenda/IncluiPV';
	PRODUCES APPLICATION_JSON

    WSMETHOD PUT AlteraStatusPV;
	DESCRIPTION 'Alteração do Status do pedido de venda';
	WSSYNTAX '/PedidoVenda/AlteraStatusPV'

    WSMETHOD DELETE ExcluiPV;
	DESCRIPTION 'Exclusão de pedido de venda';
	WSSYNTAX '/PedidoVenda/ExcluiPV'

ENDWSRESTFUL

/*/
Método POST para a Inclusão do PV, utilizando jSonObject.
@example
Chamada via postman  http://localhost:8012/rest/PedidoVenda/IncluiPV
Se a chave 'Security' estiver habilitada deverá ser passado o usuário/senha ou token
No Header poderá ser passado o 'tenantid' com a Empresa e Filial sepadados por virgula. Exemplo: 99,02
Body 
{
    "C5_CLIENTE":"000001",
    "C5_LOJACLI":"01",
    "C5_STATMAG":"R",
    "C5_ENTITY":3,
    "C5_INCREME":1,
    "Items":[
        {
        "C6_PRODUTO":"000002",
        "C6_QTDVEN":100,
        "C6_PRCVEN":4.450,
        "C6_VALOR":445.000,
        "C6_TES":"501",
        "C6_ENTREG":"30/06/2021",
        "C6_HRENTRE":"15:00"
        }
    ]
}
/*/
WSMETHOD POST IncluiPV WSRECEIVE WSRESTFUL PedidoVenda

    Local aCabec
    Local aItens
    Local aLinha
    Local oJson
    Local oItems
    Local lRet      := .T.
    Local cJson     := Self:GetContent()
    Local cDirLog   := "\MAGENTO\"
    Local cEntity   := ''
    Local cIncrem   := ''
    Local cErro     := ''
    Local cArqLog   := ''
    Local cJsonRet  := ''
    Local cCliente  := ''
    Local cLoja     := ''
    Local cTES      := ''
    Local cObs      := ''
    Local cEntrega  := ''
    Local cStatus   := ''
    Local cDtEntreg := ''
    Local cAliQry   := ''
    Local cQuery    := ''
    Local cCondPG   := ''
    Local cNaturez  := ''
    Local cTESInter := ''
    Local cTESExter := ''
    Local cTpFrete  := ''
    Local cEmpWS    := '01'
    Local cFilWS    := '0104'
    Local ctenantid := ''
    Local cCodProd  := ''
    Local cTabPreco := ''
    Local nX        := 0
    Local nTamPrd   := 0
    Local aSM0Dados := {}
    Local nPosEst   := 0
    Local nDescItem := 0
    Local nPDesCab  := 0
    Local nQtdVen   := 0
    Local nPrcVen   := 0
    Local nVlrTot   := 0
    Local nValFrete := 0

    Private lMsErroAuto     := .F.
    Private lMsHelpAuto     := .T.
    Private lAutoErrNoFile  := .T.
    Private oError		:= Nil
    Private bError		:= { |e| oError := e, Break(e) }
    Private bErrorBlock	:= ErrorBlock( bError )

    ctenantid := Self:GetHeader("tenantid")
    cEmpWS := Left( ctenantid, At( ',', ctenantid ) -1 )
    cFilWS := SubStr( ctenantid, At( ',', ctenantid ) +1 )

    BEGIN SEQUENCE

        If .NOT. RpcSetEnv( cEmpWS, cFilWS,, "" , "FAT" , "AlteraStatusPV" , {"SC5","SC6","SA1","SB1","CC2"},,,, )
            lRet := .F.
            SetRestFault( ERRORCODE_DEF, EncodeUTF8("Não foi possível configurar a Empresa/Filial." ) )
            Break
        EndIf

        cNaturez  := SuperGetMV("ES_PVNATUR",, "1010103")
        cTESInter := SuperGetMV("ES_PVTESIN",, "501")
        cTESExter := SuperGetMV("ES_PVTESEX",, "503")
        cTpFrete  := SuperGetMV("ES_PVTPFRE",, "F")
        cTabPreco := SuperGetMV("ES_PVTABPR",, "001")
        aSM0Dados := FWSM0Util():GetSM0Data(,, { "M0_ESTENT" } )
        nPosEst   := aScan( aSM0Dados, { |x| x[1]=="M0_ESTENT" } )
        nTamPrd   := TamSX3("C6_PRODUTO")[1]

        //Se não existir o diretório de logs dentro da Protheus Data, será criado
        If .NOT. ExistDir(cDirLog)
            MakeDir(cDirLog)
        EndIf

        //Definindo o conteúdo como JSON, e pegando o content e dando um parse para ver se a estrutura está ok
        Self:SetContentType("application/json")
        oJson := JsonObject():New()
        cErro := oJson:FromJson(cJson)

        //Se tiver algum erro no Parse, encerra a execução
        IF .NOT. Empty(cErro)
            SetRestFault(ERRORSRV_DEF, EncodeUTF8( cErro ) )
            lRet := .F.
            Break
        EndIf

        //Se encontrar o cliente existente conforme dados do JSON
        DbSelectArea('SA1')
        dbSetOrder(1)
        cCliente := oJson:GetJsonObject('C5_CLIENTE')
        cLoja    := oJson:GetJsonObject('C5_LOJACLI')

        If .NOT. SA1->(dbSeek(xFilial("SA1")+PadR(cCliente,TamSX3("A1_COD")[1])+PadR(cLoja,TamSX3("A1_LOJA")[1])))
            SetRestFault( ERRORCODE_DEF, EncodeUTF8("Cliente não encontrado") )
            lRet := .F.
            Break
        EndIf

        If Empty( SA1->A1_CGC )
            SetRestFault( ERRORCODE_DEF, EncodeUTF8("Cliente sem CPF cadastrado") )
            lRet := .F.
            Break
        EndIf

        If Empty( SA1->A1_CEP )
            SetRestFault( ERRORCODE_DEF, EncodeUTF8("Cliente sem CEP cadastrado") )
            lRet := .F.
            Break
        EndIf

        If Empty( SA1->A1_COD_MUN )

            DbSelectArea("CC2")
            dbSetOrder(2)
            If dbSeek( xFilial("CC2") + Upper( AllTrim( SA1->A1_MUN ) ) )

                // Encontrou o Municipio pelo Nome, então atualiza o código
                SA1->( RecLock( "SA1", .F. ) )
                    SA1->A1_COD_MUN := CC2->CC2_CODMUN
                MsUnLock()

            Else
                SetRestFault( ERRORCODE_DEF, EncodeUTF8("Cliente sem Codigo de Municipio cadastrado e sem Descrição do Municipio correta") )
                lRet := .F.
                Break
            EndIf
        EndIf
    
        aCabec  := {}
        aItens  := {}

        cCondPG   := IIF( ValType(oJson:GetJsonObject('C5_CONDPAG'))=="C", oJson:GetJsonObject('C5_CONDPAG'), SuperGetMV("ES_PVCNDPG",, "001") )

        DbSelectArea("SE4")
        dbSetOrder(1)
        If .NOT. dbSeek( xFilial("SE4") + PadR(cCondPG,TamSX3("E4_CODIGO")[1]) )
            SetRestFault( ERRORCODE_DEF, EncodeUTF8("Condição de Pagamento " + cCondPG + " não localizada no cadastro no Protheus") )
            lRet := .F.
            Break
        EndIf

        cStatus   := oJson:GetJsonObject('C5_STATMAG')
        cEntity   := oJson:GetJsonObject('C5_ENTITY')
        cIncrem   := oJson:GetJsonObject('C5_INCREME')
        nValFrete := IIF( ValType(oJson:GetJsonObject('C5_FRETE'))=="N", oJson:GetJsonObject('C5_FRETE'), 0 )
        nPDesCab  := IIF( ValType(oJson:GetJsonObject('C5_PDESCAB'))=="N", oJson:GetJsonObject('C5_PDESCAB'), 0 )
        cObs      := AllTrim( DecodeUTF8( IIF( ValType(oJson:GetJsonObject('C5_OBS'))=="C", oJson:GetJsonObject('C5_OBS'), '' ) ) )
        
        cAliQry  := GetNextAlias()
        cQuery += "SELECT C5_NUM, R_E_C_N_O_ RECSC5 "
        cQuery += "FROM " + RetSQLName("SC5")  + " "
        cQuery += "WHERE C5_INCREME = '"+cIncrem+"' "
        cQuery += "AND C5_ENTITY = '"+cEntity+"' "
        cQuery += "AND D_E_L_E_T_ = ' ' "
        dbUseArea( .T.,"TOPCONN", TcGenQry(,,cQuery),cAliQry,.F.,.T. )
        If (cAliQry)->( !EOF() )
            SetRestFault( ERRORCODE_DEF, EncodeUTF8("Já existe PV com o entity_id = " + cEntity + " e increment_id = " + cIncrem ) )
            lRet := .F.
            (cAliQry)->( DbCloseArea() )
            Break
        EndIf
        (cAliQry)->( DbCloseArea() )

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
        // aAdd(aCabec,{"C5_DESCONT", nPDesCab         , NIL}) // Valor do desconto em R$
        // Caso o Produto tenha preço de venda B1_PRCV1, o Desconto será dado para todos os itens no PV
        aAdd(aCabec,{"C5_DESC1"  , nPDesCab         , NIL}) // % do desconto
        aAdd(aCabec,{"C5_INDPRES", "2"              , NIL})

        // Não deve gravar esse campo pois a função retIntermed() do NFESEFAZ.prw faz o preenchimento da TAG do XML.
        //aAdd(aCabec,{"C5_CODA1U" , "0"              , NIL})
        
        DbSelectArea("SB1")
        DbSetOrder(1)

        //Busca os itens no JSON, percorre eles e adiciona no array da SC6
        oItems := oJson:GetJsonObject('Items')
        For nX := 1 To Len (oItems)
            aLinha := {}
            cCodProd := AllTrim( oItems[nX]:GetJsonObject('C6_PRODUTO') )

            // cTES := IIF( SA1->A1_EST == aSM0Dados[nPosEst, 2], cTESInter, cTESExter )
			
			// #30827 Verifica se produto é bonificado. Trata se é cliente de dentro, ou fora do estado. Mauro - Solutio.
			If oItems[nX]:GetJsonObject('C6_BONIFICADO') == "1"
				If SA1->A1_EST == aSM0Dados[nPosEst, 2] // Dentro do estado.
					cTES := Posicione("SF4",4,xFilial("SF4")+"5910","SF4->F4_CODIGO")
				Else // Fora
					cTES := Posicione("SF4",4,xFilial("SF4")+"6910","SF4->F4_CODIGO")
				EndIf
			Else
				cTES := MaTesInt( 2/*Saida/Venda*/, "01"/*cOperac*/, cCliente, cLoja, "C"/*Cliente*/, cCodProd )
            EndIf
			
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

            If .NOT. SB1->( dbSeek( xFilial("SB1") + PadR( cCodProd, nTamPrd ) ) )
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

    RECOVER
		lRet := .F.
		ErrorBlock(bErrorBlock)
        If ValType( oError ) == "O"
            cErro := oError:Description
            MemoWrite( cDirLog + DtoS(Date()) + "_" + StrTran(Time(), ':', '')+".log", cErro + CRLF + "JSON recebido: " + cJson )
            SetRestFault(ERRORSRV_DEF, EncodeUTF8("Ocorreu uma falha interna do Servidor: ") + cErro + CRLF + "JSON recebido: " + cJson )
        EndIF
	END SEQUENCE

    RpcClearEnv()

Return(lRet)


/*/
Método PUT para alteração do campo Status Magento no PV.
@example
Chamada via postman  http://localhost:8012/rest/PedidoVenda/AlteraStatusPV?entity_id=3&increment_id=1&status=A
Se a chave 'Security' estiver habilitada deverá ser passado o usuário/senha ou token.
No Header poderá ser passado o 'tenantid' com a Empresa e Filial sepadados por virgula. Exemplo: 99,02
Os campos declarados na assinatura do método são obrigatórios.
/*/

WSMETHOD PUT AlteraStatusPV QUERYPARAM entity_id, increment_id, status WSRECEIVE WSRESTFUL PedidoVenda

    Local cJsonRet  := ""
    Local cEntity   := ""
    Local cIncrem   := ""
    Local cStatus   := ""
    Local cQuery    := ""
    Local cAliQry   := ""
    Local ctenantid := ""
    Local cEmpWS    := ""
    Local cFilWS    := ""
    Local lRet      := .T.

	Private bError      := { |e| oError := e, Break(e) }
	Private bErrorBlock := ErrorBlock( bError )
	Private oError

    ctenantid := Self:GetHeader("tenantid")
    cEmpWS := Left( ctenantid, At( ',', ctenantid ) -1 )
    cFilWS := SubStr( ctenantid, At( ',', ctenantid ) +1 )

    BEGIN SEQUENCE

        If .NOT. RpcSetEnv( cEmpWS, cFilWS,, "" , "FAT" , "AlteraStatusPV" , {"SC5","SC6","SA1","SB1","CC2"},,,, )
            lRet := .F.
            SetRestFault( ERRORCODE_DEF, EncodeUTF8("Não foi possível configurar a Empresa/Filial." ) )
            Break
        EndIf

        cEntity := Self:entity_id
        cIncrem := Self:increment_id
        cStatus := Self:status

        //Definindo o conteúdo como JSON, e pegando o content e dando um parse para ver se a estrutura está ok
        Self:SetContentType("application/json")

        If( Empty( cEntity ) .Or. Empty( cIncrem ) .Or. Empty( cStatus ) )
            lRet := .F.
            SetRestFault( ERRORCODE_DEF, EncodeUTF8("Obrigatório informar entity_id, increment_id e status." ) )
        Else
            cAliQry  := GetNextAlias()

            cQuery += "SELECT C5_NUM, C5_STATMAG, R_E_C_N_O_ RECSC5 "
            cQuery += "FROM " + RetSQLName("SC5")  + " "
            cQuery += "WHERE C5_INCREME = '"+cIncrem+"' "
            cQuery += "AND C5_ENTITY = '"+cEntity+"' "
            cQuery += "AND D_E_L_E_T_ = ' ' "
            
            dbUseArea( .T.,"TOPCONN", TcGenQry(,,cQuery),cAliQry,.F.,.T. )
            If (cAliQry)->( EOF() )
                (cAliQry)->( DbCloseArea() )
                lRet := .F.
                SetRestFault( ERRORCODE_DEF, EncodeUTF8("Não foi possível localizar o PV pelo entity_id = " + cEntity + " e increment_id = " + cIncrem  ) )

            ElseIf (cAliQry)->C5_STATMAG == 'F'
                (cAliQry)->( DbCloseArea() )
                lRet := .F.
                SetRestFault( ERRORCODE_DEF, EncodeUTF8("NF já emitida para o PV entity_id = " + cEntity + ", por isso não será possível alterar o Status." ) )

            Else
                DbSelectArea("SC5")
                DbGoTo( (cAliQry)->RECSC5 )
                RecLock( "SC5", .F. )
                    SC5->C5_STATMAG := cStatus
                MsUnLock()
                (cAliQry)->( DbCloseArea() )
                
                cJsonRet := '{"SucessoAlteracao":"'+SC5->C5_NUM+'"}'
                Self:SetResponse(cJsonRet)
            EndIf
        EndIf

    RECOVER
		lRet := .F.
		ErrorBlock(bErrorBlock)
		SetRestFault(ERRORSRV_DEF, EncodeUTF8("Ocorreu uma falha interna do Servidor: ") + oError:Description )

	END SEQUENCE

    RpcClearEnv()

Return(lRet)


/*/
Método DELETE para exclusão do PV.
@example
Chamada via postman  http://localhost:8012/rest/PedidoVenda?entity_id=3&increment_id=1
Se a chave 'Security' estiver habilitada deverá ser passado o usuário/senha ou token.
No Header poderá ser passado o 'tenantid' com a Empresa e Filial sepadados por virgula. Exemplo: 99,02
Os campos declarados na assinatura do método são obrigatórios.
/*/

WSMETHOD DELETE ExcluiPV QUERYPARAM entity_id, increment_id WSRECEIVE WSRESTFUL PedidoVenda

    Local cArqLog   := ""
    Local cErro     := ""
    Local cJsonRet  := ""
    Local cEntity   := ""
    Local cIncrem   := ""
    Local cQuery    := ""
    Local cAliQry   := ""
    Local ctenantid := ""
    Local cEmpWS    := ""
    Local cFilWS    := ""
    Local cDirLog   := "\MAGENTO\"
    Local aCabec    := {}
    Local aLogAuto  := {}
    Local nX        := 0
    Local lRet      := .T.

    Private lMsErroAuto     := .F.
    Private lMsHelpAuto     := .T.
    Private lAutoErrNoFile  := .T.
	Private bError          := { |e| oError := e, Break(e) }
	Private bErrorBlock     := ErrorBlock( bError )
	Private oError

    ctenantid := Self:GetHeader("tenantid")
    cEmpWS := Left( ctenantid, At( ',', ctenantid ) -1 )
    cFilWS := SubStr( ctenantid, At( ',', ctenantid ) +1 )

    BEGIN SEQUENCE

        If .NOT. RpcSetEnv( cEmpWS, cFilWS,, "" , "FAT" , "ExcluiPV" , {"SC5","SC6","SA1","SB1","CC2"},,,, )
            lRet := .F.
            SetRestFault( ERRORCODE_DEF, EncodeUTF8("Não foi possível configurar a Empresa/Filial." ) )
            Break
        EndIf

        //Se não existir o diretório de logs dentro da Protheus Data, será criado
        If .NOT. ExistDir(cDirLog)
            MakeDir(cDirLog)
        EndIf

        cEntity := Self:entity_id
        cIncrem := Self:increment_id

        //Definindo o conteúdo como JSON, e pegando o content e dando um parse para ver se a estrutura está ok
        Self:SetContentType("application/json")

        If( Empty( cEntity ) .Or. Empty( cIncrem ))
            lRet := .F.
            SetRestFault( ERRORCODE_DEF, EncodeUTF8("Obrigatório informar entity_id e increment_id." ) )
        Else
            cAliQry  := GetNextAlias()

            cQuery += "SELECT C5_NUM, R_E_C_N_O_ RECSC5 "
            cQuery += "FROM " + RetSQLName("SC5")  + " "
            cQuery += "WHERE C5_INCREME = '"+cIncrem+"' "
            cQuery += "AND C5_ENTITY = '"+cEntity+"' "
            cQuery += "AND D_E_L_E_T_ = ' ' "
            
            dbUseArea( .T.,"TOPCONN", TcGenQry(,,cQuery),cAliQry,.F.,.T. )
            If (cAliQry)->( EOF() )
                lRet := .F.
                SetRestFault( ERRORCODE_DEF, EncodeUTF8("Não foi possível localizar o PV pelo entity_id = " + cEntity + " e increment_id = " + cIncrem  ) )
            Else
                DbSelectArea("SC5")
                DbGoTo( (cAliQry)->RECSC5 )

                If .NOT. Empty( SC5->C5_NOTA )
                    lRet := .F.
                    SetRestFault( ERRORCODE_DEF, EncodeUTF8("Já foi gerada NF para o PV " + AllTrim(SC5->C5_INCREME) + " e não será possível a exclusão.") )
                Else

                    DbSelectArea("SC6")
                    dbSetOrder(1)
                    dbSeek( SC5->C5_FILIAL + SC5->C5_NUM )
                    While SC6->(!EOF()) .AND. SC6->C6_FILIAL == SC5->C5_FILIAL .AND. SC6->C6_NUM == SC5->C5_NUM
                        
                        // tenta estornar as liberações do item
                        MaAvalSC6( "SC6", 4, "SC5" )

                        SC6->( dbSkip() )
                    EndDo
                    
                    aAdd( aCabec, {"C5_FILIAL" , SC5->C5_FILIAL , Nil} )
                    aAdd( aCabec, {"C5_NUM"    , SC5->C5_NUM    , Nil} )

                    MsExecAuto( { |x, y, z| MATA410( x, y, z ) }, aCabec, {}, 5 )

                    If lMsErroAuto

                        cArqLog   := SC5->C5_NUM + "_" + DtoS(Date()) + "_" + StrTran(Time(), ':', '')+".log"
                        cErro     := ""
                        aLogAuto  := {}
                        aLogAuto  := GetAutoGrLog()
                        For nX := 1 To Len(aLogAuto)
                            cErro += aLogAuto[nX] + CRLF
                        Next
                        MemoWrite( cDirLog + cArqLog, cErro )
                        lRet    := .F.
                        SetRestFault(ERRORSRV_DEF, EncodeUTF8(cErro) )
                    Else
                        cJsonRet := '{"SucessoExclusao":"'+SC5->C5_NUM+'"}'
                        Self:SetResponse(cJsonRet)
                    EndIF
                EndIF
                
            EndIf
            (cAliQry)->( DbCloseArea() )
        EndIf

    RECOVER
		lRet := .F.
		ErrorBlock(bErrorBlock)
		SetRestFault(ERRORSRV_DEF, EncodeUTF8("Ocorreu uma falha interna do Servidor: ") + oError:Description )

	END SEQUENCE

    RpcClearEnv()

Return(lRet)
