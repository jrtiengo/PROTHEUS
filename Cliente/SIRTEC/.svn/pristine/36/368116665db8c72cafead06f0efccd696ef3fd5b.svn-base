#INCLUDE 'PROTHEUS.CH'

/*{ProtheusDoc} UPDSIX

Abstração do dicionario SX5

@author		helitom silva
@data		16 de Maio de 2012
@method		{create} 	cria um novo objeto
@method 	{add} 	 	adiciona um registro a tabela generica
@method 	{s}		 	seta os atributos do indice
@method 	{remove} 	remove uma tabela generica se existir
@method		{confirm}	comita uma tabela generica adicionada
@method		{setlog}	seta o objeto responsavel pelo log
*/

CLASS UPDSX5

	DATA STRUCT
	DATA MODEL
	DATA MODELS //ACUMULA OS MODELOS ATE O CONFIRMA
	DATA OLOG
	DATA CFILIAL

	METHOD CREATE() CONSTRUCTOR
	METHOD ADDTABELA()
	METHOD ADDITENS()
	METHOD S()
	METHOD REMOVE()
	METHOD CONFIRM()
	METHOD SETLOG()

ENDCLASS

/*{ProtheusDoc} CREATE

METODO CONSTRUTOR DA CLASSE UPDSX5

@author		helitom.silva
@data		20 de outubro de 2011
*/
METHOD CREATE() CLASS UPDSX5

	::STRUCT := {'FILIAL', 'TABELA', 'CHAVE', 'DESCRI', 'DSCSPA', 'DSCENG'}
	::MODELS := {}


	::CFILIAL := SPACE(POSICIONE('SX3', 2, 'A1_FILIAL', 'X3_TAMANHO'))

	IF TYPE("OLOG") != "U"
		::OLOG 	 := OLOG
	ELSE
		::OLOG 	 := UPDLOG():CREATE()
	ENDIF

RETURN SELF

/*{ProtheusDoc} ADDTABELA

Inclusão TABELA GENERICA

@author		helitom.silva
@data		16 de Maio de 2012
*/
METHOD ADDTABELA(CFILIAL, CTABELA, CDESCRI, CDSCSPA, CDSCENG) CLASS UPDSX5

    IF EMPTY(CFILIAL)
       CFILIAL := ::CFILIAL
    ENDIF

	::MODEL := 	{;
	::CFILIAL  	,;//FILIAL
	'00' 		,;//TABELA
	''			,;//CHAVE - TABELA
	''			,;//DESCRIC
	''			,;//DSCSPA
	''			} //DSCENG

	AADD(::MODELS, ::MODEL)	  //REGISTRA O MODELO NA LISTA DE MODELOS

	SELF:S('FILIAL'	, CFILIAL)
	SELF:S('CHAVE'  , CTABELA)
	SELF:S('DESCRI' , CDESCRI)
	SELF:S('DSCSPA' , CDSCSPA)
	SELF:S('DSCENG'	, CDSCENG)

RETURN SELF

/*{ProtheusDoc} ADDITENS

Inclusão ITEM DA TABELA GENERICA

@author		helitom.silva
@data		16 de Maio de 2012
*/
METHOD ADDITENS(CFILIAL, CTABELA, CCHAVE, CDESCRI, CDSCSPA, CDSCENG) CLASS UPDSX5

    IF EMPTY(CFILIAL)
       CFILIAL := ::CFILIAL
    ENDIF

	::MODEL := 	{;
	::CFILIAL  	,;//FILIAL
	'' 			,;//TABELA
	''			,;//CHAVE
	''			,;//DESCRIC
	''			,;//DSCSPA
	''			} //DSCENG

	AADD(::MODELS, ::MODEL)	  //REGISTRA O MODELO NA LISTA DE MODELOS

	SELF:S('FILIAL'	, CFILIAL)
	SELF:S('TABELA'	, CTABELA)
	SELF:S('CHAVE'  , CCHAVE)
	SELF:S('DESCRI' , CDESCRI)
	SELF:S('DSCSPA' , CDSCSPA)
	SELF:S('DSCENG'	, CDSCENG)

RETURN SELF

/*{ProtheusDoc} S

Altera atributo do dicionario SX5

@author		helitom.silva
@data		16 de Maio de 2012
*/
METHOD S(ATTR, VALOR) CLASS UPDSX5
	LOCAL I := ASCAN(::STRUCT, ATTR)

	IF I = 0
		::OLOG:LOG("ATENCAO: Não foi possível configurar o atributo: "+ATTR+"!")
	ELSE
		::MODEL[I] := VALOR
	ENDIF

RETURN SELF

/*{ProtheusDoc} CONFIRM

CONFIRMA A GRAVAÇÃO DO REGISTRO

@author		helitom.silva
@data		20 de outubro de 2011
*/
METHOD CONFIRM() CLASS UPDSX5

	LOCAL I

	::OLOG:LOG("Os seguintes paramêtros foram adicionados ao dicionário SX5")

	DBSELECTAREA("SX5")
	DBSETORDER(1)

	FOR I := 1 TO LEN(::MODELS)

		::OLOG:LOG(" TABELA GENERICA ["+::MODELS[I][02]+"]")

        DBGOTOP()
		IIF(DBSEEK(::MODELS[I][01]+::MODELS[I][02]+::MODELS[I][03]), RLOCK(), DBAPPEND())

			X5_FILIAL    	:= ::MODELS[I][01]
			X5_TABELA  		:= ::MODELS[I][02]
			X5_CHAVE     	:= ::MODELS[I][03]
			X5_DESCRI 	   := ::MODELS[I][04]
			X5_DESCSPA		:= ::MODELS[I][05]
			X5_DESCENG		:= ::MODELS[I][06]

		DBUNLOCK()

	NEXT

	::OLOG:LINE()

	::MODELS := {}

RETURN SELF


/*{ProtheusDoc} ADDTABELA

REMOVE TABELA DO DICIONARIO

@author		helitom.silva
@data		16 de Maio de 2012
*/
METHOD REMOVE(CFILIAL, CTABELA) CLASS UPDSX5

	::OLOG:LOG("As seguintes Tabelas Genericas foram excluidas do dicionário SX5")

    IF EMPTY(CFILIAL)
       CFILIAL := ::CFILIAL
    ENDIF

	DBSELECTAREA("SX5")
	DBSETORDER(1)
    DBGOTOP()

	::OLOG:LOG(" TABELA GENERICA FILIAL[" + CFILIAL + " TABELA: " + CTABELA + "]")

	WHILE .Not. SX5->(EOF())

	    IF SX5->X5_FILIAL = CFILIAL .and. (SX5->X5_TABELA == CTABELA .or. SX5->X5_CHAVE == CTABELA)

			RLOCK()
			   DBDELETE()
		    DBUNLOCK()

	    ENDIF

	    SX5->(DBSKIP())
	END

	::OLOG:LINE()

	::MODELS := {}

RETURN SELF