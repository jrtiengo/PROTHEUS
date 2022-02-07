#INCLUDE 'PROTHEUS.CH'

/*{ProtheusDoc} UPDSX7

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

CLASS UPDSX7

	DATA STRUCT
	DATA MODEL
	DATA MODELS //ACUMULA OS MODELOS ATÉ O CONFIRMA
	DATA OLOG

	METHOD CREATE() CONSTRUCTOR
	METHOD ADD()
	METHOD S()
	METHOD REMOVE()
	METHOD CONFIRM()
	METHOD SETLOG()
	METHOD POSICIONA()
	METHOD PROXSEQ()
    METHOD SETSX3()

ENDCLASS

METHOD CREATE() CLASS UPDSX7

	::STRUCT := { 'CAMPO' , 'SEQUENC' , 'REGRA', 'CDOMIN', 'TIPO'  , ;
		'SEEK', 'ALIAS', 'ORDEM'   , 'CHAVE','CONDIC', 'PROPRI';
		}
	::MODELS := {}

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
METHOD ADD(CCAMPO, CSEQUENC, CREGRA, CDOMIN, CALIAS, NORDEM, CCHAVE, CCONDIC) CLASS UPDSX7

	DEFAULT CCONDIC := ""
	DEFAULT CALIAS  := NIL

	::MODEL := 	{;
		'' 			,;//CAMPO
	''			,;//SEQUENC
	''			,;//REGRA
	''			,;//CDOMIN
	'P'			,;//TIPO
	'N'			,;//SEEK
	''			,;//ALIAS
	0	  		,;//ORDEM
	''  		,;//CHAVE
	''  		,;//CONDIC
	'S'			};//PROPRI

	AADD(::MODELS, ::MODEL)						  			  	//REGISTRA O MODELO NA LISTA DE MODELOS

	SELF:S('CAMPO'	, CCAMPO)
	SELF:S('SEQUENC'	, CSEQUENC)
	SELF:S('REGRA'	, CREGRA)
	SELF:S('CDOMIN'	, CDOMIN)
	SELF:S('CONDIC'	, CCONDIC)

	IF CALIAS != NIL
		SELF:POSICIONA(CALIAS, NORDEM, CCHAVE)
	ENDIF

	RETURN SELF

/*
SETA O VALOR DO ATRIBUTO
*/
METHOD S(ATTR, VALOR) CLASS UPDSX7
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
METHOD CONFIRM() CLASS UPDSX7

	LOCAL I

	::OLOG:LOG("Os seguintes gatilhos foram adicionados ao dicionário SX7")

	DBSELECTAREA("SX7")
	DBSETORDER(1)

	FOR I := 1 TO LEN(::MODELS)

		::OLOG:LOG(" GATILHO [CAMPO:"+::MODELS[I][01]+", SEQ:"+::MODELS[I][02]+"]")

		dbGoTop()
		IIf(dbSeek(PADR(::MODELS[I][01],10)+PADR(::MODELS[I][02],3)),RLock(),dbAppend())
		X7_CAMPO  		:= ::MODELS[I][01]
		X7_SEQUENC    	:= ::MODELS[I][02]
		X7_REGRA     	:= ::MODELS[I][03]
		X7_CDOMIN 		:= ::MODELS[I][04]
		X7_TIPO		:= ::MODELS[I][05]
		X7_SEEK		:= ::MODELS[I][06]
		X7_ALIAS    	:= ::MODELS[I][07]
		X7_ORDEM		:= ::MODELS[I][08]
		X7_CHAVE  		:= ::MODELS[I][09]
		X7_CONDIC  	:= ::MODELS[I][10]
		X7_PROPRI  	:= ::MODELS[I][11]
		DBUNLOCK()

        SELF:SETSX3(PADR(::MODELS[I][01],10))

        DBSELECTAREA("SX7")
	NEXT

	::OLOG:LINE()

	::MODELS := {}
	RETURN SELF


/*{ProtheusDoc} UPDSX7:POSICIONA


@author		fernando.alencar
@data			20 de novembro de 2011
*/
METHOD POSICIONA(CALIAS, NORDEM, CCHAVE) CLASS UPDSX7

	SELF:S('SEEK'		, 'S')
	SELF:S('ALIAS'	, CALIAS)
	SELF:S('ORDEM'	, NORDEM)
	SELF:S('CHAVE'	, CCHAVE)

	RETURN SELF

/*{ProtheusDoc} UPDSX7:GETORDEM

NÃO UTILIZADO

Retorna a proxima ordem disponivel para a criação de um gatilho

@author		fernando.alencar
@data			20 de novembro de 2011
*/
METHOD PROXSEQ(CCAMPO) CLASS UPDSX7

	LOCAL CSEQUENCIA := "000"

	DBSELECTAREA("SX7")
	DBSETORDER(1)
	DBGOTOP()
	DBSEEK(PADR(CCAMPO,10))

	WHILE !SX7->(EOF())
		CSEQUENCIA := SOMA1(CSEQUENCIA)

		SX7->(DBSKIP())
	ENDDO

	DBCLOSEAREA("SX7")

	RETURN SOMA1(CSEQUENCIA)

/*{ProtheusDoc} UPDSX7:GETORDEM

NÃO UTILIZADO

Seta o campo Trigger com Valor 'S' referente ao gatilho na tabela SX3

@author		helitom.silva
@data			08 de Junho de 2012
*/
METHOD SETSX3(pField) CLASS UPDSX7

    DBSELECTAREA("SX3")
    DBSETORDER(2)
    DbGoTop()
    If DBSeek(PADR(pField,10))
        RLock()
           X3_TRIGGER := 'S'
        DBUNLOCK()
    EndIf
    SX3->(DbCloseArea())

RETURN
