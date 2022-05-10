#Include "Totvs.ch"
#Include "Restful.ch"
/*
|============================================================================|
|============================================================================|
|||-----------+---------+-------+------------------------+------+----------|||
||| Funcao    | SCIWS020| Autor | Denis Rodrigues        | Data |02/04/2020|||
|||-----------+---------+-------+------------------------+------+----------|||
||| Descricao | API para integração da Rotina Solicitação ao Armazem com   |||
|||           | com o App E.D.Inter.                                       |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Parametros|                                                            |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|||  Uso      |                                                            |||
|||-----------+------------------------------------------------------------|||
|||                           ULTIMAS ALTERACOES                           |||
|||-------------+--------+-------------------------------------------------|||
||| Programador | Data   | Motivo da Alteracao                             |||
|||-------------+--------+-------------------------------------------------|||
|||             |        |                                                 |||
|||-------------+--------+-------------------------------------------------|||
|============================================================================|
|============================================================================|*/
WSRESTFUL SCIWS020 DESCRIPTION "API para integração da Rotina Solicitação ao Armazem com o App E.D.Inter." SECURITY "MATA105" FORMAT APPLICATION_JSON

    WSDATA CP_NUM     AS CHARACTER
    WSDATA CP_SOLICIT AS CHARACTER

    WSMETHOD GET  GET_LINK         DESCRIPTION "GET para testar a conexão com o Webservice Protheus."   WSSYNTAX "/get_link" PATH "/get_link"
    WSMETHOD GET  GET_SOLICITACAO  DESCRIPTION "GET para listar as Solicitações ao Armazem abertas."    WSSYNTAX "/get_solicitacao" PATH "/get_solicitacao"
    WSMETHOD POST POST_LOGIN       DESCRIPTION "POST para fazer o login na Aplicação Mobile."           WSSYNTAX "/post_login" PATH "/post_login"
    WSMETHOD POST ATUASOLIC        DESCRIPTION "POST para atualizar a Solicitação ao Armazem."          WSSYNTAX "/atuasolic" PATH "/atuasolic"
    
END WSRESTFUL

/*
|============================================================================|
|============================================================================|
|||-----------+---------------+-------+------------------+------+----------|||
||| Funcao    |GET_SOLICITACAO| Autor | Denis Rodrigues  | Data |02/04/2020|||
|||-----------+---------------+-------+------------------+------+----------|||
||| Descricao | Metodo para listar as Solicitações ao Armazem em aberto    |||
|||           |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Parametros|                                                            |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
WSMETHOD GET GET_SOLICITACAO WSRECEIVE CP_NUM WSSERVICE SCIWS020
    
    Local cNumSA    := AllTrim( Self:CP_NUM )
    Local cQuery    := ""
    Local cAliasT   := GetNextAlias()
    Local nX        := 0

    ::SetContentType("application/json")
    
    If !Empty( cNumSA )
        ConOut("Metodo GET_SOLICITACAO - LISTA A SA " + cNumSA)
    Else
        ConOut("Metodo GET_SOLICITACAO - LISTA TUDO")
    EndIf
    
    Set(_SET_DATEFORMAT, 'dd/mm/yyyy')

    cQuery := " SELECT SCP.CP_NUM,"
    cQuery += "        SCP.CP_SOLICIT,"
    
    If !Empty( cNumSA )
    
        cQuery += " SCP.CP_QUJE,"
        cQuery += " SCP.CP_PRODUTO,"
        cQuery += " SCP.CP_DESCRI,"
        cQuery += " SCP.CP_CC,"        
        cQuery += " SCP.CP_ITEM,"
        cQuery += " SCP.CP_QUANT,"
        cQuery += " Sum( SD3.D3_QUANT ) AS QUANT,"
        
    EndIf

    cQuery += "        SCP.CP_EMISSAO"
    cQuery += " FROM " + RetSQLName("SCP") + " SCP, "
    cQuery +=            RetSQLName("SD3") + " SD3 "
    cQuery += " WHERE SCP.CP_FILIAL = '" + xFilial("SCP") + "'"

    If !Empty( cNumSA )
        cQuery += " AND SCP.CP_NUM = '" + cNumSA + "'"
    EndIf

    cQuery += "  AND SCP.CP_EMISSAO > 20191001"
    cQuery += "  AND SCP.CP_USUAREC = ''"
    cQuery += "  AND SCP.D_E_L_E_T_ = ''"
       
    cQuery += "  AND SD3.D3_FILIAL = SCP.CP_FILIAL"
    cQuery += "  AND SD3.D3_NUMSA  = SCP.CP_NUM"
    cQuery += "  AND SD3.D3_ITEMSA = SCP.CP_ITEM"

    If !Empty( cNumSA )
        cQuery += " AND SD3.D3_COD = SCP.CP_PRODUTO"
    EndIf 

    cQuery += "  AND SD3.D3_USUAREC = ''"
    cQuery += "  AND SD3.D3_ESTORNO = ''"
    cQuery += "  AND SD3.D_E_L_E_T_ = ''"
       
    If !Empty( cNumSA )

        //cQuery += " GROUP BY SCP.CP_NUM,SCP.CP_SOLICIT,SCP.CP_QUJE,SCP.CP_PRODUTO,SCP.CP_DESCRI,SCP.CP_CC,SCP.CP_ITEM,SCP.CP_QUANT,SD3.D3_QUANT,SCP.CP_EMISSAO"
        cQuery += " GROUP BY SCP.CP_NUM,SCP.CP_SOLICIT,SCP.CP_QUJE,SCP.CP_PRODUTO,SCP.CP_DESCRI,SCP.CP_CC,SCP.CP_ITEM,SCP.CP_QUANT,SCP.CP_EMISSAO"
        cQuery += " ORDER BY SCP.CP_ITEM"

    Else

        cQuery += " GROUP BY SCP.CP_NUM,SCP.CP_SOLICIT,SCP.CP_EMISSAO"
        cQuery += " ORDER  BY SCP.CP_NUM DESC"

    EndIf 
ConOut(cQuery)
    cQuery := ChangeQuery( cQuery )
    dbUseArea( .T., "TOPCONN",TcGenQry( ,,cQuery ),cAliasT,.F.,.T. )

    If ( cAliasT )->( !Eof() )//Se existir SA

        ::SetResponse('[')

        While ( cAliasT )->( !Eof() )

            If nX >= 1
                ::SetResponse(',')
            EndIf           
            
            If !Empty( cNumSA ) 

                dbSelectArea("CTT")
                dbSetOrder(1)//CTT_FILIAL+CTT_CUSTO
                dbSeek( xFilial("CTT") + PadR( ( cAliasT )->CP_CC, TamSX3("CTT_CUSTO")[01] ) )            
                                                            
                ::SetResponse( '{"CP_NUM":'     + CHR(34) + ( cAliasT )->CP_NUM                     + CHR(34) +;
                               ',"CP_SOLICIT":' + CHR(34) + ( cAliasT )->CP_SOLICIT                 + CHR(34) +;
                               ',"CP_ITEM":'    + CHR(34) + ( cAliasT )->CP_ITEM                    + CHR(34) +;
                               ',"CP_PRODUTO":' + CHR(34) + ( cAliasT )->CP_PRODUTO                 + CHR(34) +;
                               ',"CP_DESCRI":'  + CHR(34) + ( cAliasT )->CP_DESCRI                  + CHR(34) +;
                               ',"CP_QUANT":'   + CHR(34) + cValToChar( ( cAliasT )->CP_QUANT )     + CHR(34) +;
                               ',"CP_QUJE":'    + CHR(34) + cValToChar( ( cAliasT )->QUANT )        + CHR(34) +;
                               ',"CP_EMISSAO":' + CHR(34) + DtoC( StoD( ( cAliasT )->CP_EMISSAO ) ) + CHR(34) +;
                               ',"CP_CC":'      + CHR(34) + AllTrim( CTT->CTT_DESC01 )              + CHR(34) +;
                               ',"msgCode":'    + CHR(34) + "OK"                                    + CHR(34) +'}')
            
            Else

                ::SetResponse( '{"CP_NUM":'     + CHR(34) + ( cAliasT )->CP_NUM                     + CHR(34) +;
                               ',"CP_SOLICIT":' + CHR(34) + ( cAliasT )->CP_SOLICIT                 + CHR(34) +;
                               ',"CP_EMISSAO":' + CHR(34) + DtoC( StoD( ( cAliasT )->CP_EMISSAO ) ) + CHR(34) +;   
                               ',"msgCode":'    + CHR(34) + "OK"                                    + CHR(34) +'}')
                                        
            EndIf
                                               
            nX++
                                                                
            ( cAliasT )->( dbSkip() )

        EndDo

        ::SetResponse(']')
        ( cAliasT )->( dbCloseArea() )

    Else

        ::SetResponse('[{')
        ::SetResponse('"msgCode": "ERRO",')
        ::SetResponse('"msgReturn": '+ CHR(34)  + "Nao existe sa para exibir." + CHR(34) )
        ::SetResponse('}]')

    EndIf

Return(.T.)

/*
|============================================================================|
|============================================================================|
|||-----------+---------------+-------+------------------+------+----------|||
||| Funcao    |GET_LINK       | Autor | Denis Rodrigues  | Data |03/04/2020|||
|||-----------+---------------+-------+------------------+------+----------|||
||| Descricao | Metodo para testar a conexão com o Webservice Protheus     |||
|||           |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Parametros|                                                            |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
WSMETHOD GET GET_LINK WSRECEIVE NULLPARAM WSSERVICE SCIWS020
    
    ::SetContentType("application/json")
    
    ConOut("Metodo GET_LINK")

    ::SetResponse('[{')
    ::SetResponse('"msgCode": "OK",')
    ::SetResponse('"msgReturn": '+ CHR(34)  + "Metodo OK." + CHR(34) )
    ::SetResponse('}]')

Return(.T.)

/*
|============================================================================|
|============================================================================|
|||-----------+-----------------+-------+----------------+------+----------|||
||| Funcao    | POST_LOGIN      | Autor | Denis Rodrigues| Data |02/04/2020|||
|||-----------+-----------------+-------+----------------+------+----------|||
||| Descricao | Metodo para fazer login no Protheus a partir do App        |||
|||           | E.D.Inter                                                  |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Parametros|                                                            |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
WSMETHOD POST POST_LOGIN WSRECEIVE NULLPARAM WSSERVICE SCIWS020

    Local cBody   := ::GetContent()
    Local cIdUser := ""
    Local cRet    := ""
    Local cNomUser:= ""
    Local oJson
    Local lOK     := .T.
    
    ::SetContentType("application/json")

    ConOut("Metodo POST_LOGIN")
    ConOut( cBody )

    If FWJsonDeserialize(cBody,@oJson)
    
        PswOrder(2)//Procurar pelo nome do usuario
        If PswSeek( AllTrim( oJson[1]:CP_USUARIO ), .T. )
            cIdUser := PswID() // Retorna o ID do usuário
            
            PswOrder(1)//Procurar por senha
            If PswSeek( cIdUser)
            
                lOK := PswName( oJson[1]:CP_SENHA )             
                cNomUser := UsrRetName( cIdUser )
                
            EndIf
        
        Else
            lOK := .F.
        EndIf
        
        If lOK 

            ::SetResponse('{')
            ::SetResponse('"msgCode": "OK",')
            ::SetResponse('"msgReturn": '+ CHR(34)  + cNomUser +"|" + cIdUser + CHR(34) )
            ::SetResponse('}')

        Else
        
            cRet := "Usuario ou senha invalidos."
            ::SetResponse('{')
            ::SetResponse('"msgCode": "ERRO",')
            ::SetResponse('"msgReturn": '+ CHR(34)  + cRet + CHR(34) )
            ::SetResponse('}')
            
        EndIf

    Else
        
        cRet := "Erro no JSON."
        ::SetResponse('{')
        ::SetResponse('"msgCode": "ERRO",')
        ::SetResponse('"msgReturn": '+ CHR(34)  + cRet + " Entre em contato com o Administrador." + CHR(34) )
        ::SetResponse('}')

    EndIf

Return(.T.)

/*
|============================================================================|
|============================================================================|
|||-----------+-----------------+-------+----------------+------+----------|||
||| Funcao    | POST_ATUASOLIC  | Autor | Denis Rodrigues| Data |02/04/2020|||
|||-----------+-----------------+-------+----------------+------+----------|||
||| Descricao | Metodo para atualizar a Solicitacao ao Armazem com os dados|||
|||           | do usuario recebedor                                       |||
|||-----------+------------------------------------------------------------|||
||| Sintaxe   |                                                            |||
|||-----------+------------------------------------------------------------|||
||| Parametros|                                                            |||
|||-----------+------------------------------------------------------------|||
||| Retorno   |                                                            |||
|||-----------+------------------------------------------------------------|||
|============================================================================|
|============================================================================|*/
WSMETHOD POST ATUASOLIC WSRECEIVE NULLPARAM WSSERVICE SCIWS020

    Local cBody  := ::GetContent()    
    Local cRet   := ""
    Local cAliasT:= ""
    Local cQuery := ""
	Local aRet   := {}
    Local aDados := {}
    Local lOK    := .F.
    Local oJson
    
    ::SetContentType("application/json")

    ConOut("Metodo ATUASOLIC")
    ConOut( cBody )

    If FWJsonDeserialize(cBody,@oJson)

        //+--------------------------------------------------------+
        //| Verifica se o cracha existe no Cadastro do Funcionario |
        //+--------------------------------------------------------+
        aRet := VerifSRA( oJson[1]:CP_CRACHA )

		If aRet[1]

            dbSelectArea("SCP")
            dbSetOrder(1)
            If dbSeek(xFilial("SCP") + PadR( oJson[1]:CP_NUM, TamSX3("CP_NUM")[01] ) )

                While SCP->( !Eof() ) .And. AllTrim( SCP->CP_NUM ) == AllTrim( oJson[1]:CP_NUM ) 
                    
                    If SCP->CP_QUANT = SCP->CP_QUJE .And. Empty( SCP->CP_USUAREC ) .And. AllTrim( SCP->CP_STATUS ) == "E"

                        RecLock("SCP",.F.)
                            SCP->CP_USUAREC := oJson[1]:CP_CRACHA
                            SCP->CP_DATAREC := Date()
                            SCP->CP_HORAREC := Time()
                        MsUnlock()

                    EndIf 

                    SCP->( dbSkip() )
                        
                EndDo

                cAliasT := GetNextAlias()
                cQuery := " SELECT D3_FILIAL,"
                cQuery += "        D3_DOC,"
                cQuery += "        D3_COD,"
                cQuery += "        R_E_C_N_O_ AS RECNO"
                cQuery += " FROM " + RetSQLName("SD3")
                cQuery += " WHERE D3_FILIAL  = '" + xFilial("SD3")  + "'" 
                cQuery += "   AND D3_NUMSA   = '" + oJson[1]:CP_NUM + "'"
                cQuery += "   AND D3_SEQCALC = ''"
                cQuery += "   AND D_E_L_E_T_ = ''"

                cQuery := ChangeQuery( cQuery )                
                dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )

                While ( cAliasT )->( !Eof() )

                    dbSelectArea("SD3")
                    dbSetOrder(2)//D3_FILIAL+D3_DOC+D3_COD
                    If dbSeek( ( cAliasT )->D3_FILIAL + ( cAliasT )->D3_DOC + ( cAliasT )->D3_COD )

                        If Empty( SD3->D3_USUAREC )

                            aAdd( aDados,{ AllTrim( oJson[1]:CP_NUM ),;
                                           ( cAliasT )->RECNO } )

                            Reclock("SD3",.F.)
                                SD3->D3_USUAREC := oJson[1]:CP_CRACHA
                                SD3->D3_DATAREC := Date()
                                SD3->D3_HORAREC := Time()
                            Msunlock()
                        
                        EndIf 

                    EndIf                 

                    ( cAliasT )->( dbSkip() )

                EndDo 

                ( cAliasT )->( dbCloseArea() )

                lOK := .T.
				WS020EMAIL( aDados )  

            Else

                lOK := .F.
                cRet := "Solicitacao nao foi encontrada."            

            EndIf 
                            
        Else

            lOK := .F.
            cRet := "A matricula invalida."

        EndIf 
        
        If lOK 

            cRet := "Solicitacao atualizada com sucesso."
            ::SetResponse('{')
            ::SetResponse('"msgCode": "OK",')
            ::SetResponse('"msgReturn": '+ CHR(34)  + cRet + CHR(34) )
            ::SetResponse('}')
            ConOut(cRet)

        Else

            ::SetResponse('{')
            ::SetResponse('"msgCode": "ERRO",')
            ::SetResponse('"msgReturn": '+ CHR(34)  + cRet + CHR(34) )
            ::SetResponse('}')
            ConOut(cRet)
            
        EndIf

    Else
        
        cRet := "Erro ao converter o JSON."
        ::SetResponse('{')
        ::SetResponse('"msgCode": "ERRO",')
        ::SetResponse('"msgReturn": '+ CHR(34)  + cRet + " Entre em contato com o Administrador." + CHR(34) )
        ::SetResponse('}')

    EndIf

Return(.T.)


/*/{Protheus.doc} VerifSRA
    Função para validar o codigo da matricula do funcionario permitindo ou não a liberação de SA.
    @type  Static Function
    @author Denis Rodrigues
    @since 28/09/2020
    @version 1;0
    @param param_name, param_type, param_descr
           cCodMat   , caracter  , Codigo da matricula do colaborador
    @return return_var, return_type, return_description
            aRet[1]   , Booleano   , Permite a liberacao da SA
			aRet[2]   , String     , Nome do Funcionario 
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function VerifSRA( cCodMat )

    Local cQuery  := ""
    Local cAliasT := ""
	Local cNomFun := ""
    Local lOK     := .F.

    cAliasT := GetNextAlias()
    cQuery := " SELECT COUNT(RA_MAT) AS EXISTE,"
	cQuery += "        RA_NOME"
    cQuery += " FROM " + RetSQLName("SRA")
    cQuery += " WHERE RA_FILIAL = '" + xFilial("SRA") + "'"
    cQuery += "   AND RA_BARRA  = '" + cCodMat + "'"
    cQuery += "   AND D_E_L_E_T_ = ' '"
	cQuery += " GROUP BY RA_MAT, RA_NOME"

    cQuery := ChangeQuery( cQuery )
    dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )

    If ( cAliasT )->EXISTE > 0 

        lOK := .T.
		cNomFun := AllTrim( ( cAliasT )->RA_NOME )

    EndIf 

    ( cAliasT )->( dbCloseArea() )
    
Return( {lOK,cNomFun} )


/*/{Protheus.doc} WS020EMAIL
	Função para envio de e-mail após a entrega da SA pelo aplicativo EDInter
	@type  Static Function
	@author Denis Rodrigues
	@since 22/10/2020
	@version version
	         2.0 - Adaptação do fonte SCIA130 (cEnvEmail)
	@param param_name, param_type, param_descr
	       aDados[1] , String    , Numero da SA
           aDados[2] , String    , Recno do Registro gravado
	@return return_var, return_type, return_description
	@example(examples)
	@see (links_or_references)
/*/
Static Function WS020EMAIL( aNumSA )

    Local cSolic  := ""
    Local cTo     := ""
	Local cHtml   := "" 
    Local cAliasT := ""
    Local cQuery  := ""
    Local cCodSA  := aNumSA[1][1]
    Local aRet    := {}
    Local aDados  := {}
    Local nX      := 0
    Local nPos    := 0
	
	cHtml := '<!DOCTYPE html>'
	cHtml += '<html>'
	cHtml += '	<head>'
	cHtml += '		<style>'
	cHtml += '			table {font-family: arial, sans-serif;border-collapse: collapse;width: 100%;}'
	cHtml += '			td, th {border: 1px solid #FF6347;text-align: left;padding: 8px;}'
	cHtml += '			tr:nth-child(even) {background-color: #dddddd;}'
	cHtml += '			#borda { margin: 30px;}'
	cHtml += '			thead{ background-color: #F08080; }'
	cHtml += '			body { border: 1px solid #FF6347; padding: 10px;border-radius: 25px; }'
	cHtml += '		</style>'
	cHtml += '	</head>'
	cHtml += '	<body>'
	cHtml += '		<div id="borda">'
	cHtml += '			<h2>EDInter</h2>'

	dbSelectArea("SCP")
	dbSetOrder(1)//CP_FILIAL+CP+NUM+CP_ITEM+CP_EMISSAO
	dbSeek( xFilial("SCP") + PadR( cCodSA, TamSX3("CP_NUM")[01] ) )

    cSolic := UsrRetMail( SCP->CP_CODSOLI )
    
    cTo := AllTrim( GetMv("ES_EDIMAIL") ) + ";" + AllTrim( cSolic )
    
    cHtml += '			<p>A SA numero <b>' + AllTrim( SCP->CP_NUM ) + '</b> foi entregue.</p>'
    cHtml += '			<table>'
    cHtml += '				<thead>'
    cHtml += '					<th>Item</th>'
    cHtml += '					<th>Produto</th>'
    cHtml += '					<th>Descrição</th>'
    cHtml += '					<th>Qtd.Entregue</th>'
    cHtml += '					<th>Centro Custo</th>'
    cHtml += '					<th>Entregue para</th>'
    cHtml += '					<th>Data</th>'
    cHtml += '				</thead>'
    cHtml += '				<tbody>'

    For nX := 1 To Len( aNumSA )

        cAliasT := GetNextAlias()
        cQuery := " SELECT SCP.CP_NUM,"
        cQuery += "        SCP.CP_SOLICIT,"
        cQuery += "        SCP.CP_PRODUTO,"
        cQuery += "        SCP.CP_DESCRI,"
        cQuery += "        SCP.CP_CC,"
        cQuery += "        SCP.CP_ITEM,"
        cQuery += "        Sum(SD3.D3_QUANT) AS D3_QUANT,"
        cQuery += "        SD3.D3_USUAREC,"
        cQuery += "        SD3.D3_DATAREC"
        cQuery += " FROM " + RetSQLName("SCP") + " SCP, "
        cQuery +=            RetSQLName("SD3") + " SD3 "
        cQuery += " WHERE SCP.CP_FILIAL  = '" + xFilial("SCP") + "'"
        cQuery += "   AND SCP.CP_NUM     = '" + cCodSA         + "'"              
        cQuery += "   AND SD3.R_E_C_N_O_ = '" + cValToChar(aNumSA[nX][02]) + "'"
        cQuery += "   AND SCP.D_E_L_E_T_ = ''"
        cQuery += "   AND SD3.D3_FILIAL  = SCP.CP_FILIAL"
        cQuery += "   AND SD3.D3_NUMSA   = SCP.CP_NUM"
        cQuery += "   AND SD3.D3_ITEMSA  = SCP.CP_ITEM"
        cQuery += "   AND SD3.D3_COD     = SCP.CP_PRODUTO"
        cQuery += "   AND SD3.D3_ESTORNO = ''"
        cQuery += "   AND SD3.D_E_L_E_T_ = ''"
        cQuery += " GROUP BY SCP.CP_NUM,SCP.CP_SOLICIT,SCP.CP_PRODUTO,SCP.CP_DESCRI,SCP.CP_CC,SCP.CP_ITEM,SD3.D3_QUANT,SD3.D3_USUAREC,SD3.D3_DATAREC"
        cQuery += " ORDER  BY SCP.CP_ITEM  "

        cQuery := ChangeQuery( cQuery )                
        dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )

        While ( cAliasT )->( !Eof() )

            nPos := aScan( aDados,{|x|  x[1] = AllTrim( ( cAliasT )->CP_NUM )    .And.;
                                        x[2] = AllTrim( ( cAliasT )->CP_SOLICIT ).And.;
                                        x[3] = AllTrim( ( cAliasT )->CP_PRODUTO ).And.;
                                        x[4] = AllTrim( ( cAliasT )->CP_DESCRI ) .And.;
                                        x[5] = AllTrim( ( cAliasT )->CP_CC )     .And.;
                                        x[6] = AllTrim( ( cAliasT )->CP_ITEM )   .And.; 
                                        x[7] = AllTrim( ( cAliasT )->D3_USUAREC ).And.;
                                        x[8] = AllTrim( ( cAliasT )->D3_DATAREC ) } )

            If nPos = 0

                aAdd( aDados,{ AllTrim( ( cAliasT )->CP_NUM ),;     //01
                               AllTrim( ( cAliasT )->CP_SOLICIT ),; //02
                               AllTrim( ( cAliasT )->CP_PRODUTO ),; //03
                               AllTrim( ( cAliasT )->CP_DESCRI ),;  //04
                               AllTrim( ( cAliasT )->CP_CC ),;      //05
                               AllTrim( ( cAliasT )->CP_ITEM ),;    //06                           
                               AllTrim( ( cAliasT )->D3_USUAREC ),; //07
                               AllTrim( ( cAliasT )->D3_DATAREC ),; //08
                               ( cAliasT )->D3_QUANT             } )//09

            Else 
                aDados[nPos][09] := aDados[nPos][09] + ( cAliasT )->D3_QUANT        
            EndIf

            ( cAliasT )->( dbSkip() )

        EndDo 

        ( cAliasT )->( dbCloseArea() )
    
    Next nX 

    nX := 0
    For nX := 1 To Len( aDados )

        dbSelectArea("CTT")
        dbSetOrder(1)//CTT_FILIAL+CTT_CUSTO
        dbSeek( xFilial("CTT") + PadR( aDados[nX][05], TamSX3("CTT_CUSTO")[01] ) )

        aRet := VerifSRA( aDados[nX][07] )

        cHtml += '	<tr>'
        cHtml += '		<td>' + AllTrim( aDados[nX][06] )                          + '</td>'
        cHtml += '		<td>' + AllTrim( aDados[nX][03] )                          + '</td>'
        cHtml += '		<td>' + AllTrim( aDados[nX][04] )                          + '</td>'
        cHtml += '		<td>' + Transform( aDados[nX][09] ,"@E 999,999,999.99" )   + '</td>'
        cHtml += '	    <td>' + AllTrim( CTT->CTT_CUSTO ) + " - " + AllTrim( CTT->CTT_DESC01 ) + '</td>'
        cHtml += '      <td>' + Capital( aRet[2] )                                 + '</td>'
        cHtml += '      <td>' + DtoC( StoD( aDados[nX][08] ) )                     + '</td>'
        cHtml += '  </tr>'															
        
    Next nX

    cHtml += '				</tbody>'
    cHtml += '			</table>'
    cHtml += '		</div>'
    cHtml += '	</body>'
    cHtml += '</html>'
    
    /*Envia email - Funcao EnvMail, encontra-se no fonte SCIXFUN*/
    U_EnvMail("","","",cTo,"","Entrega de SA - " + AllTrim( cCodSA ) + " - EDInter",cHtml,"")
    
Return

/*/{Protheus.doc} User Function WS020NOME
    Funcao que estara no campo D3_NOMEREC para retornar o nome do usuario na consulta generica SD3
    @type  Function
    @author Denis Rodrigues
    @since 17/02/2021
    @version version
    @param param_name, param_type, param_descr
            cCracha  , String    , Codigo do Cracha do usuario
    @return return_var, return_type, return_description
            cNome     , String     , Nome do Funcionario
    @example U_WS020NOME()
    @see (links_or_references)
/*/
User Function WS020NOME( cCracha )

    Local cNome   := ""
    Local cAliasT := ""
    Local cQuery  := ""

    If !Empty( cCracha )

        ConOut("WS020NOME")
        ConOut(cCracha)

        cAliasT := GetNextAlias()
        cQuery := " SELECT RA_NOME"
        cQuery += " FROM " + RetSQLName("SRA")
        cQuery += " WHERE RA_FILIAL = '" + xFilial("SRA") + "'"
        cQuery += "   AND RA_BARRA  = '" + cCracha        + "'"
        cQuery += "   AND D_E_L_E_T_=''"
        cQuery += ChangeQuery( cQuery )
        dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasT,.F.,.T. )

        If ( cAliasT )->( !Eof() )
            cNome := AllTrim( ( cAliasT )->RA_NOME )    
        Else 
            cNome := ""
        EndIf 

        ( cAliasT )->( dbCloseArea() )
    
    EndIf
    
Return( cNome )