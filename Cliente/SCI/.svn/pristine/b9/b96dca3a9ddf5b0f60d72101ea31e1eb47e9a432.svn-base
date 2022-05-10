#INCLUDE "TOTVS.CH"
#INCLUDE "RESTFUL.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³INWS040   ºAutor  ³Microsiga           º Data ³  12/08/2019 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
WSRESTFUL INWS040 DESCRIPTION "Serviço REST para integração Movimentos Bancários"

	WSDATA E5_DATA  	AS STRING
	WSDATA E5_VALOR 	AS STRING
	WSDATA E5_NATUREZ	AS STRING
	WSDATA E5_HIST     	AS STRING
	WSDATA E5_BANCO    	AS STRING
	WSDATA E5_AGENCIA  	AS STRING
	WSDATA E5_CONTA    	AS STRING
	WSDATA E5_CCCTB    	AS STRING

	WSMETHOD POST 	DESCRIPTION "Insere Movimentos Bancários do Protheus."	WSSYNTAX "/"
	WSMETHOD DELETE	DESCRIPTION "Exclui Movimentos Bancários do Protheus." 	WSSYNTAX "/" //e5_data=01/08/2019&e5_valor=105.87&e5_banco=123&e5_agencia=12345&e5_conta=1234567890"
 
END WSRESTFUL


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ Metodo POST ³ Autor ³                 ³ Data ³             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Metodo para inclusao de entidades no Contas a Receber      ³±±
±±³          ³ do Protheus                                                ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD POST WSRECEIVE NULLPARAM WSSERVICE INWS040

Local lOK		:= .T.
Local cBody		:= ::GetContent()
Local cMsg		:= ""
Local cErrorLog	:= ""
Local cSeek		:= ""
Local cNumParc	:= ""
Local aVetor	:= {}
Local oJson

Private lMsErroAuto := .F.

::SetContentType("application/json")	// define o tipo de retorno do método

If FWJsonDeserialize(cBody,@oJson)//Converte a estrutura jSon em Objeto
	
	If	Empty( oJson:E5_DATA )
		
		lOK := .F.
		SetRestFault( 1, "O campo data do movimento deve ser informado pois faz parte da chave do titulo." )
	EndIf
	
	If	Empty( oJson:E5_VALOR )
		
		lOK := .F.
		SetRestFault( 1, "O campo valor deve ser informado pois faz parte da chave do título." )
	EndIf

	//+------------------------------------------------------------------+
	//| Valida os campos Emissao, Vencimento e Vencimento Real do titulo |
	//+------------------------------------------------------------------+
	If Empty( oJson:E5_BANCO ) .Or. Empty( oJson:E5_AGENCIA ) .Or. Empty( oJson:E5_CONTA )
		
		lOK := .F.
		SetRestFault( 3, "Informar os campos de Banco, Agencia e Conta" )
	EndIf
	
	dbSelectArea("SED")
	dbSetOrder(1)
	If !dbSeek( xFilial("SED") + oJson:E5_NATUREZ )
		
		lOK := .F.
		SetRestFault( 5, "Natureza nao esta cadastrada no sistema" )
	EndIf

	dbSelectArea("CTT")
	dbSetOrder(1)
	If !dbSeek( xFilial("CTT") + oJson:E5_CCCTB )
		
		lOK := .F.
		SetRestFault( 5, "Natureza nao esta cadastrada no sistema" )
	EndIf

	dbSelectArea("SA6")
	dbSetOrder(1)
	If !dbSeek( xFilial("SA6") + PadR( oJson:E5_BANCO, TamSX3("E5_BANCO")[01] ) + PadR( oJson:E5_AGENCIA, TamSX3("E5_AGENCIA")[01] ) + PadR( oJson:E5_CONTA, TamSX3("E5_CONTA")[01] ),.f.)
		
		lOK := .F.
		SetRestFault( 6, "Banco nao esta cadastrado no sistema" )
	EndIf


	If lOK // Se as validacoes acima estiverem OK.
		
		aFINA100 := { 	{ "E5_FILIAL"   , xFilial("SE5")    	, Nil },;
						{ "E5_FILORIG"  , xFilial("SE5")    	, Nil },;
						{ "E5_DATA"		, CtoD( oJson:E5_DATA )	, Nil },;
						{ "E5_MOEDA"	, "M1"		        	, Nil },;
						{ "E5_RECPAG"	, "R"		        	, Nil },;
						{ "E5_ORIGEM"	, "FINA100"	        	, Nil },;
						{ "E5_VALOR"	, oJson:E5_VALOR    	, Nil },;
						{ "E5_NATUREZ"	, oJson:E5_NATUREZ   	, Nil },;
						{ "E5_CCCTB"	, PadR( oJson:E5_CCCTB , TamSX3("E5_CCCTB")[01] )  	, Nil },;
						{ "E5_BANCO"	, PadR( oJson:E5_BANCO, TamSX3("E5_BANCO")[01] )	, Nil },;
						{ "E5_AGENCIA"	, PadR( oJson:E5_AGENCIA, TamSX3("E5_AGENCIA")[01] ), Nil },;
						{ "E5_CONTA"	, PadR( oJson:E5_CONTA, TamSX3("E5_CONTA")[01] )	, Nil },;
						{ "E5_HISTOR"	, PadR( oJson:E5_HIST, TamSX3("E5_HISTOR")[01] )	, Nil }}
		
		lMsErroAuto := .F.
		lAutoErrNoFile := .T.
		MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,4) //Recebimento

		
		If lMsErroAuto
			
			aMsg := GetAutoGRLog()
			aEval(aMsg,{|x| cErrorLog += x + CRLF })
			SetRestFault( 8, "Erro ao incluir a movimentacao. Verifique o Log de Integracao do Protheus." + cErrorLog )
		Else
			
			::SetResponse('{')
			::SetResponse('"errorCode": "9",')
			::SetResponse('"errorMessage": "Movimento incluido com sucesso.",')
			::SetResponse('"id_protheus": ' + CHR(34) + "|" + SE5->E5_FILIAL + "|" + DTOC(SE5->E5_DATA) + "|" + Transform(SE5->E5_VALOR,"@E 999,999,999.99") + CHR(34) )
			::SetResponse('}')
			
		EndIf
		
	EndIf
	
Else
	
	lOK := .F.
	SetRestFault( 10, "Nao foi possivel processar a estrutura Json." )
	
EndIf

Return( lOK )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±³Funcao    ³ Metodo DELETE ³ Autor ³   ³ Data  ±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Metodo para exclusao de entidades no Contas a Receber      ³±±
±±³          ³ do Protheus                                                ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
WSMETHOD DELETE WSRECEIVE E5_DATA,E5_VALOR,E5_BANCO,E5_AGENCIA,E5_CONTA WSSERVICE INWS040

Local lOK	    := .T.
Local cMsg		:= ""
Local cErrorLog := ""
Local cSeek		:= ""
Local cNumParc	:= ""

Local aVetor		:= {}
Local oJson

Private lMsErroAuto := .F.

::SetContentType("application/json")	// define o tipo de retorno do método

If Empty( ::E5_DATA ) .or. Empty( ::E5_VALOR ) .or. Empty( ::E5_BANCO ).or. Empty( ::E5_AGENCIA ).or. Empty( ::E5_CONTA )
	
	lOK := .F.
	SetRestFault( 1, "Faltam parametros para fazer exclusao." )
Else
	
	cSeek := xFilial("SE5")
	cSeek += SubStr(::E5_DATA,7,4)+SubStr(::E5_DATA,4,2)+SubStr(::E5_DATA,1,2)
	cSeek += PadR( ::E5_BANCO, TamSX3("E5_BANCO")[01] ) 				
	cSeek += PadR( ::E5_AGENCIA, TamSX3("E5_AGENCIA")[01] ) 				
	cSeek += PadR( ::E5_CONTA, TamSX3("E5_CONTA")[01] ) 				
	
	dbSelectArea("SE5")
	dbSetOrder(1) //Data + Baco + Agencia + Conta
	If !dbSeek( cSeek )
		
		lOK := .F.
		SetRestFault( 2, "Titulo nao encontrado." )
	
	
	Else
		
		//Se achar parte da chave ainda tenho de ver o valor dele
		cChave := SE5->E5_FILIAL + dtos(SE5->E5_DATA) + SE5->E5_BANCO + SE5->E5_AGENCIA + SE5->E5_CONTA
	    While !EOF() .and. cChave == SE5->E5_FILIAL + dtos(SE5->E5_DATA) + SE5->E5_BANCO + SE5->E5_AGENCIA + SE5->E5_CONTA

			If  ( Val(::E5_VALOR) == SE5->E5_VALOR .and. !SE5->E5_SITUACA $ "C/X/E" )
				Exit
			EndIf

	    dbSkip()
	    End
	EndIf
	
EndIf

If lOK// Se estiver tudo OK nas validacoes acima
	
	aFINA100 := { 	{ "E5_FILIAL"	, SE5->E5_FILIAL    	, Nil },;
					{ "E5_FILORIG"	, SE5->E5_FILORIG    	, Nil },;
					{ "E5_DATA"		, SE5->E5_DATA			, Nil },;
					{ "E5_MOEDA"	, "M1"		        	, Nil },;
					{ "E5_RECPAG"	, "R"		        	, Nil },;
					{ "E5_VALOR"	, SE5->E5_VALOR    		, Nil },;
					{ "E5_NATUREZ"	, SE5->E5_NATUREZ   	, Nil },;
					{ "E5_BANCO"	, SE5->E5_BANCO			, Nil },;
					{ "E5_AGENCIA"	, SE5->E5_AGENCIA		, Nil },;
					{ "E5_CONTA"	, SE5->E5_CONTA			, Nil },;
					{ "E5_HISTOR"	, SE5->E5_HISTOR   		, Nil },;
					{ "E5_IDMOVI"	, SE5->E5_IDMOVI   		, Nil },;
					{ "E5_TIPOLAN"	, SE5->E5_TIPOLAN   	, Nil }}

	
	lMsErroAuto := .F.
	lAutoErrNoFile := .T.
	MSExecAuto({|x,y,z| FinA100(x,y,z)},0,aFINA100,5) //Exclusao

	If lMsErroAuto
		
		aMsg := GetAutoGRLog()
		aEval(aMsg,{|x| cErrorLog += x + CRLF })
		
		lOK := .F.
		SetRestFault( 3, "Erro ao excluir o Titulo. Verifique o Log de Integracao do Protheus." + cErrorLog )
		
	Else
		
		::SetResponse('{')
		::SetResponse('"errorCode": "4",')
		::SetResponse('"errorMessage": "Titulo excluido com sucesso.')
		::SetResponse('}')
	EndIf
	
EndIf

Return( lOK )
