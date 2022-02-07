#INCLUDE 'PROTHEUS.CH'

/*{ProtheusDoc} UPDSIX

Abstração do dicionario SX6

@author		fernando.alencar
@data			11 de novembro de 2011
@method		{create} 	cria um novo objeto
@method 		{add} 	 	adiciona um indice
@method 		{s}		 	seta os atributos do indice
@method 		{remove} 	remove um indice se existir
@method		{confirm}	comita os indices adicionados
@method		{setlog}	seta o objeto responsavel pelo log
*/

CLASS UPDSX6

	DATA STRUCT
	DATA MODEL
	DATA MODELS //ACUMULA OS MODELOS ATÉ O CONFIRMA
	DATA OLOG
	DATA CFILIAL

	METHOD CREATE() CONSTRUCTOR
	METHOD ADD()
	METHOD S()
	METHOD REMOVE()
	METHOD CONFIRM()
	METHOD SETLOG()

ENDCLASS

METHOD CREATE() CLASS UPDSX6

	::STRUCT := { 'FIL' , 'VAR' , 'TIPO', 'DESCRIC', 'DSCSPA'  , ;
		'DSCENG', 'DESC1', 'DSCSPA1'   , 'DSCENG1','DESC2', 'DSCSPA2'   , 'DSCENG2',;
		'CONTEUD','CONTSPA' , 'CONTENG' , 'PROPRI', 'PYME', 'VALID', 'INIT','DEFPOR',;
		'DEFSPA', 'DEFENG' }
	::MODELS := {}


	::CFILIAL := SPACE(POSICIONE('SX3', 2, 'A1_FILIAL', 'X3_TAMANHO'))

	IF TYPE("OLOG") != "U"
		::OLOG 	 := OLOG
	ELSE
		::OLOG 	 := UPDLOG():CREATE()
	ENDIF

	RETURN SELF

/*{ProtheusDoc} UPDSIX

Adiciona para inclusão ou atualização na base

@author		fernando.alencar
@data			20 de outubro de 2011
*/
METHOD ADD(CVAR, CTIPO, CDESCRICAO, CONTEUDO) CLASS UPDSX6

	::MODEL := 	{;
		::CFILIAL  		,;//FIL
	'' 			,;//VAR
	''			,;//TIPO
	''			,;//DESCRIC
	''			,;//DSCSPA
	''			,;//DSCENG
	''			,;//DESC1
	''			,;//DSCSPA1
	''  		,;//DSCENG1
	''  		,;//DESC2
	''  		,;//DSCSPA2
	''  		,;//DSCENG2
	''  		,;//CONTEUD
	''  		,;//CONTSPA
	''  		,;//CONTENG
	'S'  		,;//PROPRI
	'S'  		,;//PYME
	''  		,;//VALID
	''  		,;//INIT
	''  		,;//DEFPOR
	''  		,;//DEFSPA
	''			};//DEFENG

	AADD(::MODELS, ::MODEL)						  			  	//REGISTRA O MODELO NA LISTA DE MODELOS

	SELF:S('VAR'		, CVAR)
	SELF:S('TIPO'		, CTIPO)
	SELF:S('CONTEUD'	, CONTEUDO)
	SELF:S('DEFPOR'	, CONTEUDO)
	SELF:S('DESCRIC'	, CDESCRICAO)
	SELF:S('DESC1'	, SUBSTR(CDESCRICAO,051))
	SELF:S('DESC2'	, SUBSTR(CDESCRICAO,101))

	RETURN SELF

/*
SETA O VALOR DO ATRIBUTO
*/
METHOD S(ATTR, VALOR) CLASS UPDSX6
	LOCAL I := ASCAN(::STRUCT, ATTR)

	IF I = 0
		::OLOG:LOG("ATENCAO: Não foi possível configurar o atributo: "+ATTR+"!")
	ELSE
		::MODEL[I] := VALOR
	ENDIF

	RETURN SELF

/*
CONFIRMA A GRAVAÇÃO DO REGISTRO
*/
METHOD CONFIRM() CLASS UPDSX6

	LOCAL I

	::OLOG:LOG("Os seguintes paramêtros foram adicionados ao dicionário SX6")

	DBSELECTAREA("SX6")
	DBSETORDER(1)

	FOR I := 1 TO LEN(::MODELS)

		::OLOG:LOG(" PARAMÊTRO ["+::MODELS[I][02]+"]")

		IIF(DBSEEK(::MODELS[I][01]+::MODELS[I][02]),RLock(),dbAppend())
		X6_FIL    		:= ::MODELS[I][01]
		X6_VAR     		:= ::MODELS[I][02]
		X6_TIPO     	:= ::MODELS[I][03]
		X6_DESCRIC 	:= ::MODELS[I][04]
		X6_DSCSPA		:= ::MODELS[I][05]
		X6_DSCENG		:= ::MODELS[I][06]
		X6_DESC1    	:= ::MODELS[I][07]
		X6_DSCSPA1		:= ::MODELS[I][08]
		X6_DSCENG1  	:= ::MODELS[I][09]
		X6_DESC2  		:= ::MODELS[I][10]
		X6_DSCSPA2  	:= ::MODELS[I][11]
		X6_DSCENG2  	:= ::MODELS[I][12]
		X6_CONTEUD		:= ::MODELS[I][13]
		X6_CONTSPA		:= ::MODELS[I][14]
		X6_CONTENG		:= ::MODELS[I][15]
		X6_PROPRI 		:= ::MODELS[I][16]
		X6_PYME  		:= ::MODELS[I][17]
		X6_VALID  		:= ::MODELS[I][18]
		X6_INIT  		:= ::MODELS[I][19]
		X6_DEFPOR 		:= ::MODELS[I][20]
		X6_DEFSPA 		:= ::MODELS[I][21]
		X6_DEFENG 		:= ::MODELS[I][22]
		DBUNLOCK()

	NEXT

	::OLOG:LINE()

	::MODELS := {}
	RETURN SELF
