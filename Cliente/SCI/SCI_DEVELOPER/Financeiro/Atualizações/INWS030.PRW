#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±∫Programa  ≥INWS030   ∫Autor  ≥Microsiga           ∫ Data ≥  05/08/2019 ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Descricao ≥                                                            ∫±±
±±∫          ≥                                                            ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Uso       ≥ AP                                                         ∫±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/
WSRESTFUL INWS030 DESCRIPTION "ServiÁo REST para integraÁ„o Contas a Receber"

	WSDATA E1_NUM		AS STRING
	WSDATA E1_PARCELA	AS STRING
	WSDATA E1_NATUREZ	AS STRING
	WSDATA E1_CLIENTE	AS STRING
	WSDATA E1_LOJA	    AS STRING
	WSDATA E1_EMISSAO	AS STRING
	WSDATA E1_VENCTO	AS STRING
	WSDATA E1_HIST     	AS STRING
	WSDATA E1_MOEDA  	AS STRING

	WSMETHOD POST 	DESCRIPTION "Insere Contas a Receber do Protheus."	WSSYNTAX "/"
	//WSMETHOD PUT  	DESCRIPTION "Altera Contas a Receber do Protheus." 	WSSYNTAX "/"
	WSMETHOD DELETE	DESCRIPTION "Exclui Contas a Receber do Protheus." 	WSSYNTAX "/e1_num=1234566754&e1_parcela=1"
 
END WSRESTFUL


/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±≥Funcao    ≥ Metodo POST ≥ Autor ≥                 ≥ Data ≥             ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Metodo para inclusao de entidades no Contas a Receber      ≥±±
±±≥          ≥ do Protheus                                                ≥±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
WSMETHOD POST WSRECEIVE NULLPARAM WSSERVICE INWS030

Local lOK		:= .T.
Local cBody		:= ::GetContent()
Local cMsg		:= ""
Local cErrorLog	:= ""
Local cSeek		:= ""
Local cNumParc	:= ""
Local aVetor	:= {}
Local oJson

Private lMsErroAuto := .F.

::SetContentType("application/json")	// define o tipo de retorno do mÈtodo

If FWJsonDeserialize(cBody,@oJson)//Converte a estrutura jSon em Objeto
	
	//+-----------------------------------------------------+
	//| Valida os campos Numero do Titulo                   |
	//+-----------------------------------------------------+
	If	Empty( oJson:E1_NUM )
		
		lOK := .F.
		SetRestFault( 1, "O campo numero do titulo deve ser informado pois faz parte da chave do titulo." )
	EndIf
	
	//+-----------------------------------------------------+
	//| Valida os campos Numero do Titulo                   |
	//+-----------------------------------------------------+
	//If	Empty( oJson:E1_PARCELA )
		
	//	lOK := .F.
	//	SetRestFault( 1, "O campo parcela deve ser informado pois faz parte da chave do tÌtulo." )
	//EndIf

	//+----------------------+
	//| Valida o campo Valor |
	//+----------------------+
	If Empty( oJson:E1_VALOR ) .Or. oJson:E1_VALOR = 0
		
		lOK := .F.
		SetRestFault( 2, "Informar o valor do titulo." )
	EndIf
	
	//+------------------------------------------------------------------+
	//| Valida os campos Emissao, Vencimento e Vencimento Real do titulo |
	//+------------------------------------------------------------------+
	If Empty( oJson:E1_EMISSAO ) .Or. Empty( oJson:E1_VENCTO )
		
		lOK := .F.
		SetRestFault( 3, "Informar os campos de Emissao e/ou Vencimento" )
	EndIf
	
	
	//+------------------------------------------------+
	//| Valida se o cliente e a Loja estao cadastradas |
	//+------------------------------------------------+
	dbSelectArea("SA1")
	dbSetOrder(1)//A1_FILIAL+A1_LOJA
	If !dbSeek( xFilial("SA1") + oJson:E1_CLIENTE + oJson:E1_LOJA )
		
		lOK := .F.
		SetRestFault( 5, "Cliente nao esta cadastrado no sistema" )
	EndIf
	
	//+------------------------------------------------+
	//| Valida se o cliente e a Loja estao cadastradas |
	//+------------------------------------------------+
	dbSelectArea("SED")
	dbSetOrder(1)
	If !dbSeek( xFilial("SED") + oJson:E1_NATUREZ )
		
		lOK := .F.
		SetRestFault( 5, "Natureza nao esta cadastrado no sistema" )
	EndIf

	//+--------------------------------------+
	//| Valida se o titulo existe no sistema |
	//+--------------------------------------+
	cSeek := xFilial("SE1")
	cSeek += PadR( "SCT", TamSX3("E1_PREFIXO")[01] )
	cSeek += PadR( oJson:E1_NUM, TamSX3("E1_NUM")[01] )
	cSeek += PadR( oJson:E1_PARCELA, TamSX3("E1_PARCELA")[01] ) 
	cSeek += PadR( "NF", TamSX3("E1_TIPO")[01] )
	
	dbSelectArea("SE1")
	dbSetOrder(1)//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If dbSeek( cSeek )
		
		lOK := .F.        
		SetRestFault( 7, "Titulo ja cadastrado." )
	EndIf
	
	If lOK // Se as validacoes acima estiverem OK.
		
		aAdd( aVetor, { "E1_FILIAL"		, xFilial("SE1")			, NIl } )
		aAdd( aVetor, { "E1_PREFIXO"	, "SCT"		  				, NIL } )
		aAdd( aVetor, { "E1_NUM"    	, oJson:E1_NUM		   		, NIL } )
		aAdd( aVetor, { "E1_PARCELA"	, PadR( oJson:E1_PARCELA, TamSX3("E1_PARCELA")[01] ) , NIL } )
		aAdd( aVetor, { "E1_TIPO"   	, "NF"						, NIL } )
		aAdd( aVetor, { "E1_NATUREZ"	, oJson:E1_NATUREZ			, NIL } )
		aAdd( aVetor, { "E1_CLIENTE"	, oJson:E1_CLIENTE			, NIL } )
		aAdd( aVetor, { "E1_LOJA"		, oJson:E1_LOJA		  		, NIL } )
		aAdd( aVetor, { "E1_EMISSAO"	, CtoD( oJson:E1_EMISSAO )	, NIL } )
		aAdd( aVetor, { "E1_VENCTO"		, CtoD( oJson:E1_VENCTO )	, NIL } )
		aAdd( aVetor, { "E1_VENCREA"	, DataValida( CtoD( oJson:E1_VENCTO ) )	, NIL } )
		aAdd( aVetor, { "E1_VALOR"		, oJson:E1_VALOR			, NIL } )
		aAdd( aVetor, { "E1_HIST"		, oJson:E1_HIST				, NIL } )
		
		lMsErroAuto    := .F.
		lAutoErrNoFile := .T.
		MsExecAuto( { |x,y| FINA040(x,y)} , aVetor, 3 )// 3 - Inclusao, 4 - AlteraÁ„o, 5 - Exclus„o
		
		If lMsErroAuto
			
			aMsg := GetAutoGRLog()
			aEval(aMsg,{|x| cErrorLog += x + CRLF })
			SetRestFault( 8, "Erro ao incluir um titulo. Verifique o Log de Integracao do Protheus." + cErrorLog )
		Else
			
			::SetResponse('{')
			::SetResponse('"errorCode": "9",')
			::SetResponse('"errorMessage": "Titulo incluido com sucesso.",')
			::SetResponse('"id_protheus": ' + CHR(34) + SE1->E1_FILIAL + "|" + SE1->E1_PREFIXO + "|" + SE1->E1_NUM + "|" + SE1->E1_PARCELA + "|" + SE1->E1_TIPO + CHR(34) )
			::SetResponse('}')
			
		EndIf
		
	EndIf
	
Else
	
	lOK := .F.
	SetRestFault( 10, "Nao foi possivel processar a estrutura Json." )
	
EndIf

Return( lOK )

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±≥Funcao    ≥ Metodo PUT ≥ Autor ≥   ≥ Data ≥    ≥±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Metodo para alteracao de entidades no Contas a Receber     ≥±±
±±≥          ≥ do Protheus                                                ≥±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
/*
WSMETHOD PUT WSRECEIVE NULLPARAM WSSERVICE INWS030

Local lOK		:= .T.
Local cBody		:= ::GetContent()
Local cMsg		:= ""
Local cErrorLog := ""
Local cSeek		:= ""
Local cNumParc	:= ""

Local aVetor	:= {}
Local oJson

Private lMsErroAuto := .F.

::SetContentType("application/json")	// define o tipo de retorno do mÈtodo

If FWJsonDeserialize(cBody,@oJson)//Converte a estrutura Json para objeto
	
	//+-----------------------------------------------------+
	//| Valida os campos Numero do Titulo, Prefixo, Parcela |
	//+-----------------------------------------------------+
	If	Empty( oJson:E1_NUM ) .Or. Empty( oJson:E1_PARCELA )
		
		lOK := .F.
		
		//+--------------------------------------------+
		//| Grava o processamento em uma tabela de LOG |
		//+--------------------------------------------+
		cMsg := "Os campos Numero do Titulo, Parcela devem ser informados. Pois fazem parte da chave do Titulo." + CRLF
		
		SetRestFault( 1, "campos Numero do Titulo, Parcela devem ser informados." )
		
	EndIf
	
	//+----------------------+
	//| Valida o campo Valor |
	//+----------------------+
	If Empty( oJson:E1_VALOR ) .Or. oJson:E1_VALOR = 0
		
		lOK := .F.
		
		//+--------------------------------------------+
		//| Grava o processamento em uma tabela de LOG |
		//+--------------------------------------------+
		cMsg := "Informar um valor para o Titulo."
		SetRestFault( 2, "Informar um valor ao titulo" )
		
	EndIf
	
	//+------------------------------------------------------------------+
	//| Valida os campos Emissao, Vencimento e Vencimento Real do titulo |
	//+------------------------------------------------------------------+
	If Empty( oJson:E1_EMISSAO ) .Or. Empty( oJson:E1_VENCTO ) .Or. Empty( oJson:E1_VENCREA )
		
		lOK := .F.
		
		SetRestFault( 2, "Informar os campos Emissao, Vencimento e Vencimento Real." )
		
	EndIf
	
	//+---------------------------------+
	//| Verifica o campo tipo do Titulo |
	//+---------------------------------+
	dbSelectArea("SX5")
	dbSetOrder(1)//X5_TABELA+X5_CHAVE
	If !dbSeek( xFilial("SX5") + "05" + oJson:E1_TIPO )
		
		lOK := .F.
		SetRestFault( 4, "Tipo do Titulo invalido." )
		
	EndIf
	
	//+------------------------------------------------+
	//| Valida se o cliente e a Loja estao cadastradas |
	//+------------------------------------------------+
	dbSelectArea("SA1")
	dbSetOrder(1)//A1_FILIAL+A1_LOJA
	If !dbSeek( xFilial("SA1") + oJson:E1_CLIENTE + oJson:E1_LOJA )
		
		lOK := .F.
		SetRestFault( 5, "Cliente nao cadastrado no sistema." )
	EndIf
	
	//+--------------------------------------+
	//| Valida se o titulo existe no sistema |
	//+--------------------------------------+
	cSeek := xFilial("SE1")
	cSeek += PadR( oJson:E1_PREFIXO, TamSX3("E1_PREFIXO")[01] )
	cSeek += PadR( oJson:E1_NUM, TamSX3("E1_NUM")[01] )
	cSeek += Iif( AllTrim( oJson:E1_PARCELA ) == "0", Space( TamSX3("E1_PARCELA")[01] ), PadR( oJson:E1_PARCELA, TamSX3("E1_PARCELA")[01] ) )
	cSeek += PadR( oJson:E1_TIPO, TamSX3("E1_TIPO")[01] )
	
	dbSelectArea("SE1")
	dbSetOrder(1)//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If !dbSeek( cSeek )
		
		lOK := .F.
		SetRestFault( 7, "Titulo nao encontrado no sistema." )
	EndIf
	
	If lOK// Se todas as validacoes estiverem OK
		
		If AllTrim( oJson:E1_PARCELA ) == "0"
			cNumParc := Space( TamSX3("E1_PARCELA")[01] )
		Else
			cNumParc := PadR( oJson:E1_PARCELA, TamSX3("E1_PARCELA")[01] )
		EndIf
		
		aAdd( aVetor, { "E1_FILIAL"		, xFilial("SE1")										, NIl } )
		aAdd( aVetor, { "E1_PREFIXO"	, PadR( oJson:E1_PREFIXO, TamSX3("E1_PREFIXO")[01] )	, NIL } )
		aAdd( aVetor, { "E1_NUM"    	, PadR( oJson:E1_NUM, TamSX3("E1_NUM")[01] )			, NIL } )
		aAdd( aVetor, { "E1_PARCELA"	, cNumParc										, NIL } )
		aAdd( aVetor, { "E1_TIPO"   	, PadR( oJson:E1_TIPO, TamSX3("E1_TIPO")[01] )		, NIL } )
		aAdd( aVetor, { "E1_CLIENTE"	, oJson:E1_CLIENTE									, NIL } )
		aAdd( aVetor, { "E1_LOJA"		, oJson:E1_LOJA									, NIL } )
		aAdd( aVetor, { "E1_EMISSAO"	, CtoD( oJson:E1_EMISSAO )							, NIL } )
		aAdd( aVetor, { "E1_VENCTO"		, CtoD( oJson:E1_VENCTO )							, NIL } )
		aAdd( aVetor, { "E1_VENCREA"	, CtoD( oJson:E1_VENCREA )							, NIL } )
		aAdd( aVetor, { "E1_VALOR"		, oJson:E1_VALOR									, NIL } )
		aAdd( aVetor, { "E1_HIST"		, oJson:E1_HIST									, NIL } )
		aAdd( aVetor, { "E1_VALOR"		, oJson:E1_VALOR									, NIL } )
		aAdd( aVetor, { "E1_MULTA"		, oJson:E1_MULTA									, NIL } )
		aAdd( aVetor, { "E1_ZENIMP"		, oJson:E1_ZENIMP									, NIL } )
		aAdd( aVetor, { "E1_ZENINTE"	, oJson:E1_ZENINTE									, NIL } )
		aAdd( aVetor, { "E1_ZENINCL"	, oJson:E1_ZENINCL									, NIL } )
		aAdd( aVetor, { "E1_ZENCTRO"	, oJson:E1_ZENCTRO									, NIL } )
		aAdd( aVetor, { "E1_ZENCHVU"	, oJson:E1_ZENCHVU									, NIL } )
		
		lMsErroAuto    := .F.
		lAutoErrNoFile := .T.
		MsExecAuto( { |x,y| FINA040(x,y)} , aVetor, 4 )// 3 - Inclusao, 4 - AlteraÁ„o, 5 - Exclus„o
		
		If lMsErroAuto
			
			aMsg := GetAutoGRLog()
			aEval(aMsg,{|x| cErrorLog += x + CRLF })
			lOK := .F.
			SetRestFault( 8, "Erro ao alterar o titulo. Verifique o Log de Integracao do Protheus." )
		Else
			
			::SetResponse('{')
			::SetResponse('"errorCode": "9",')
			::SetResponse('"errorMessage": "Titulo alterado com sucesso."')
			::SetResponse('}')
			
		EndIf
		
	EndIf
	
Else
	
	lOK := .F.
	
	::SetResponse('{')
	::SetResponse('"errorCode": "10",')
	::SetResponse('"errorMessage": "Nao foi possivel converter os dados."')
	::SetResponse('}')
	
EndIf

Return( lOK )
*/

/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±≥Funcao    ≥ Metodo DELETE ≥ Autor ≥   ≥ Data  ±±
±±√ƒƒƒƒƒƒƒƒƒƒ≈ƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ¡ƒƒƒƒƒƒ¡ƒƒƒƒƒƒƒƒƒƒ¥±±
±±≥Descricao ≥ Metodo para exclusao de entidades no Contas a Receber      ≥±±
±±≥          ≥ do Protheus                                                ≥±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
WSMETHOD DELETE WSRECEIVE E1_NUM,E1_PARCELA WSSERVICE INWS030

Local lOK	    := .T.
Local cMsg		:= ""
Local cErrorLog := ""
Local cSeek		:= ""
Local cNumParc	:= ""

Local aVetor		:= {}
Local oJson

Private lMsErroAuto := .F.

::SetContentType("application/json")	// define o tipo de retorno do mÈtodo

If Empty( ::E1_NUM ) .and. Empty( ::E1_PARCELA )
	
	lOK := .F.
	SetRestFault( 1, "Nao foi informado nenhum parametro." )
Else
	
	cSeek := xFilial("SE1")
	cSeek += PadR( "SCT", TamSX3("E1_PREFIXO")[01] )
	cSeek += PadR( ::E1_NUM, TamSX3("E1_NUM")[01] ) 				
	cSeek += PadR( Upper( ::E1_PARCELA ) , TamSX3("E1_PARCELA")[01] ) 
	cSeek += PadR( "NF", TamSX3("E1_TIPO")[01] ) 		
	
	dbSelectArea("SE1")
	dbSetOrder(1)//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
	If !dbSeek( cSeek )
		
		lOK := .F.
		SetRestFault( 2, "Titulo nao encontrado." )
	EndIf
	
EndIf

If lOK// Se estiver tudo OK nas validacoes acima
	
	aAdd( aVetor, { "E1_FILIAL"		, xFilial("SE1")							, NIl } )
	aAdd( aVetor, { "E1_PREFIXO"	, PadR( "SCT", TamSX3("E1_PREFIXO")[01] )	, NIL } )
	aAdd( aVetor, { "E1_NUM"    	, PadR( ::E1_NUM, TamSX3("E1_NUM")[01] )	, NIL } )
	aAdd( aVetor, { "E1_PARCELA"  	, PadR( Upper( ::E1_PARCELA ) , TamSX3("E1_PARCELA")[01] )									, NIL } )
	aAdd( aVetor, { "E1_TIPO"   	, PadR( "NF", TamSX3("E1_TIPO")[01] )		, NIL } )
	
	lMsErroAuto    := .F.
	lAutoErrNoFile := .T.
	MsExecAuto( { |x,y| FINA040(x,y)} , aVetor, 5 )// 3 - Inclusao, 4 - AlteraÁ„o, 5 - Exclus„o
	
	If lMsErroAuto
		
		aMsg := GetAutoGRLog()
		aEval(aMsg,{|x| cErrorLog += x + CRLF })
		
		lOK := .F.
		SetRestFault( 3, "Erro ao excluir o Titulo. Verifique o Log de Integracao do Protheus." )
		
	Else
		
		::SetResponse('{')
		::SetResponse('"errorCode": "4",')
		::SetResponse('"errorMessage": "Titulo excluido com sucesso.')
		::SetResponse('}')
	
	EndIf
	
EndIf

Return( lOK )
