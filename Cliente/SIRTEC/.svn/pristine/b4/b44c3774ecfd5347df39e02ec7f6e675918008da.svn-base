#INCLUDE 'PROTHEUS.CH'

/*{ProtheusDoc} UPDSXB

Abstração do dicionario SXB

@author		helitom.silva
@data			27 de abril de 2012
@method		{create} 	cria um novo objeto
@method 		{add} 	 	adiciona uma etapa da consulta
@method 		{s}		 	seta os atributos do indice
@method 		{remove} 	remove um indice se existir
@method		{confirm}	comita os indices adicionados
@method		{setlog}	seta o objeto responsavel pelo log
*/

CLASS UPDSXB

	DATA STRUCT
	DATA MODEL
	DATA MODELS //ACUMULA OS MODELOS ATÉ O CONFIRMA
	DATA OLOG

	METHOD CREATE() CONSTRUCTOR
	METHOD ADDCONSULT()
    METHOD ADDINDICE()
    METHOD ADDCOLUNA()
    METHOD ADDFILTRO()
    METHOD ADDRETORN()
	METHOD S()
	METHOD REMOVE()
	METHOD CONFIRM()
	METHOD SETLOG()

ENDCLASS

/*  Breve descricao de como se comporta cada etapa para
    criacao de uma consulta Padrao.

    Exemplo: Consulta Posto de Coleta

	*** XB_TIPO := "1" - Primeira e segunda etapa
	    Tipo que define informacoes de nome, descricoes e Tabela da consulta

		XB_ALIAS  := cAlias                      //Nome da consulta
		XB_TIPO   := "1"                         //Tipo que define informacoes de nome, descricoes e Tabela da consulta
		XB_SEQ    := "01"                        //Sequencia da consulta, neste caso 01.
		XB_COLUNA := "DB"                        //DB, define arquivo de banco
		XB_DESCRI := "Posto de Coleta"           //Descricao da consulta
		XB_CONTEM := "Z07"                       //Tabela a ser consultada

   *** XB_TIPO   := "2" - Terceira etapa
       Tipo que define os indices utilizados para consulta

		XB_ALIAS  := cAlias                      //Nome da consulta
		XB_TIPO   := "2"                         //Tipo que define os indices utilizados para consulta
		XB_SEQ    := "01"                        //Sequencia ordem que ira aparecer o indice
		XB_COLUNA := "01"                        //Numero de Ordem do Indice na Tabela de Consulta(Dicionario)
		XB_DESCRI := "Codigo do Posto"           //Descricao do Indice
		XB_CONTEM := ""

   *** XB_TIPO   := "4" - Quarta etapa
       Tipo que define os campos que aparecerao conforme os indices

		XB_ALIAS  := cAlias                      //Nome da consulta
		XB_TIPO   := "4"                         //Tipo que define os campos que aparecerao conforme os indices
		XB_SEQ    := "01"                        //Informe aqui o codigo da sequencia informada para a sequencia do indice do Tipo 2 (APPENDA ANTERIOR)
		XB_COLUNA := "01"                        //Sequencia ordem que ira aparecer o campo na consulta da esquerda para direita
		XB_DESCRI := "Codifo Posto"              //Descriçao da coluna
		XB_CONTEM := "Z07_CODIGO"                //Field da tabela correspondente a coluna da consulta

   *** XB_TIPO   := "4" - Quarta etapa
       Tipo que define os campos que aparecerao conforme os indices

		XB_ALIAS  := cAlias                      //Nome da consulta
		XB_TIPO   := "4"                         //Tipo que define os campos que aparecerao conforme os indices
		XB_SEQ    := "01"                        //Informe aqui o codigo da sequencia informada para a sequencia do indice do Tipo 2
		XB_COLUNA := "02"                        //Sequencia ordem que ira aparecer o campo na consulta da esquerda para direita
		XB_DESCRI := "Descricao"                 //Descriçao da coluna
		XB_CONTEM := "Z07_NOME"                  //Field da tabela correspondente a coluna da consulta

   *** XB_TIPO   := "5" - Quinta etapa
       Tipo que define o retorno da consulta

		XB_ALIAS  := cAlias                      //Nome da consulta
		XB_TIPO   := "5"                         //Tipo que define o retorno da consulta
		XB_SEQ    := "02"                        //Sequencia do Retorno
		XB_COLUNA := ""
		XB_DESCRI := ""
		XB_CONTEM := "Z07->Z07_CODIGO"           //Campo a ser retornado na consulta
*/

METHOD CREATE() CLASS UPDSXB

	::STRUCT := { 'ALIAS' , 'TIPO' , 'SEQ', 'COLUNA', 'DESCRI'  , ;
		          'DESCSPA'  ,'DESCENG'  ,'CONTEM'}
	::MODELS := {}

	IF TYPE("OLOG") != "U"
		::OLOG 	 := OLOG
	ELSE
		::OLOG 	 := UPDLOG():CREATE()
	ENDIF

RETURN SELF

/*{ProtheusDoc} UPDSXB

Adiciona para inclusão ou atualização na base

@author		helitom.silva
@data			27 de abril de 2012
*/
METHOD ADDCONSULT(CCONSULTA, CDESCRI, CDESCSPA, CDESCENG, CTABELA) CLASS UPDSXB
	/*
	*** XB_TIPO := "1" - Primeira e segunda etapa
	    Tipo que define informacoes de nome, descricoes e Tabela da consulta

		XB_ALIAS   := cAlias                      //Nome da consulta
		XB_TIPO    := "1"                         //Tipo que define informacoes de nome, descricoes e Tabela da consulta
		XB_SEQ     := "01"                        //Sequencia da consulta, neste caso 01.
		XB_COLUNA  := "DB"                        //DB, define arquivo de banco
		XB_DESCRI  := "Posto de Coleta"           //Descricao da consulta PORTUGUES
		XB_DESCSPA := "Posto de Coleta"           //Descricao da consulta ESPANHOL
		XB_DESCENG := "Posto de Coleta"           //Descricao da consulta INGLES
		XB_CONTEM  := "Z07"                       //Tabela a ser consultada
	*/

	::MODEL := 	{;
	'' 			,;//XB_ALIAS
	'1'			,;//XB_TIPO
	'01'		,;//XB_SEQ
	'DB'	    ,;//XB_COLUNA
	''			,;//XB_DESCRI
	''			,;//XB_DESCSPA
	''			,;//XB_DESCENG
	''			} //XB_CONTEM

	AADD(::MODELS, ::MODEL)	 //REGISTRA O MODELO NA LISTA DE MODELOS

	SELF:S('ALIAS'	, CCONSULTA)
	SELF:S('DESCRI'	, CDESCRI)
	SELF:S('DESCSPA', CDESCSPA)
	SELF:S('DESCENG', CDESCENG)
	SELF:S('CONTEM'	, CTABELA)

RETURN SELF

/*
@author		helitom.silva
@data			27 de abril de 2012
*/
METHOD ADDINDICE(CCONSULTA, CSEQINDEX, CCODINDEX, CDESCRI, CDESCSPA, CDESCENG) CLASS UPDSXB
   /*
   *** XB_TIPO   := "2" - Terceira etapa
       Tipo que define os indices utilizados para consulta

		XB_ALIAS   := cAlias                      //Nome da consulta
		XB_TIPO    := "2"                         //Tipo que define os indices utilizados para consulta
		XB_SEQ     := "01"                        //Sequencia ordem que ira aparecer o indice
		XB_COLUNA  := "01"                        //Numero de Ordem do Indice na Tabela de Consulta(Dicionario)
		XB_DESCRI  := "Posto de Coleta"          //Descricao da consulta PORTUGUES
		XB_DESCSPA := "Posto de Coleta"          //Descricao da consulta ESPANHOL
		XB_DESCENG := "Posto de Coleta"          //Descricao da consulta INGLES
   */

	::MODEL := 	{;
	'' 			,;//XB_ALIAS
	'2'			,;//XB_TIPO
	''			,;//XB_SEQ
	''	        ,;//XB_COLUNA
	''			,;//XB_DESCRI
	''			,;//XB_DESCSPA
	''			,;//XB_DESCENG
	''			} //XB_CONTEM

	AADD(::MODELS, ::MODEL)	 //REGISTRA O MODELO NA LISTA DE MODELOS

	SELF:S('ALIAS'	, CCONSULTA)
	SELF:S('SEQ'	, CSEQINDEX)
	SELF:S('COLUNA'	, CCODINDEX)
	SELF:S('DESCRI'	, CDESCRI)
	SELF:S('DESCSPA', CDESCSPA)
	SELF:S('DESCENG', CDESCENG)

RETURN SELF

/*
@author		helitom.silva
@data			27 de abril de 2012
*/
METHOD ADDCOLUNA(CCONSULTA, CSEQINDEX, CSEQCOLUNA, CDESCRI, CDESCSPA, CDESCENG, CFIELDTAB) CLASS UPDSXB
   /*
   *** XB_TIPO   := "4" - Quarta etapa
       Tipo que define os campos que aparecerao conforme os indices

		XB_ALIAS   := cAlias                      //Nome da consulta
		XB_TIPO    := "4"                         //Tipo que define os campos que aparecerao conforme os indices
		XB_SEQ     := "01"                        //Informe aqui o codigo da sequencia informada para a sequencia do indice do Tipo 2
		XB_COLUNA  := "02"                        //Sequencia ordem que ira aparecer o campo na consulta da esquerda para direita
		XB_DESCRI  := "Posto de Coleta"          //Descricao da consulta PORTUGUES
		XB_DESCSPA := "Posto de Coleta"          //Descricao da consulta ESPANHOL
		XB_DESCENG := "Posto de Coleta"          //Descricao da consulta INGLES
		XB_CONTEM  := "Z07_NOME"                  //Field da tabela correspondente a coluna da consulta
   */

	::MODEL := 	{;
	'' 			,;//XB_ALIAS
	'4'			,;//XB_TIPO
	''			,;//XB_SEQ
	'DB'	    ,;//XB_COLUNA
	''	        ,;//XB_DESCRI
	''		    ,;//XB_DESCSPA
	''		    ,;//XB_DESCENG
	''			} //XB_CONTEM

	AADD(::MODELS, ::MODEL)	 //REGISTRA O MODELO NA LISTA DE MODELOS

	SELF:S('ALIAS'	, CCONSULTA)
	SELF:S('SEQ'	, CSEQINDEX)
	SELF:S('COLUNA'	, CSEQCOLUNA)
	SELF:S('DESCRI'	, CDESCRI)
	SELF:S('DESCSPA', CDESCSPA)
	SELF:S('DESCENG', CDESCENG)
	SELF:S('CONTEM'	, CFIELDTAB)

RETURN SELF

/*
@author		helitom.silva
@data			27 de abril de 2012
*/
METHOD ADDFILTRO(CCONSULTA, CFILTRO) CLASS UPDSXB
   /*
   *** XB_TIPO   := "5" - Quinta etapa
       Tipo que define o retorno da consulta

		XB_ALIAS  := cAlias                      //Nome da consulta
		XB_TIPO   := "6"                         //Tipo que define o filtro que será realizado na consulta
		XB_SEQ    := "01"                        //Sequencia
		XB_CONTEM := "tabela->campo = 1"       //Filtro da consulta
   */

	::MODEL := 	{;
	'' 			,;//XB_ALIAS
	'6'			,;//XB_TIPO
	'01'		,;//XB_SEQ
	''	        ,;//XB_COLUNA
	''			,;//XB_DESCRI
	''			,;//XB_DESCSPA
	''			,;//XB_DESCENG
	''			} //XB_CONTEM

	AADD(::MODELS, ::MODEL)	 //REGISTRA O MODELO NA LISTA DE MODELOS

	SELF:S('ALIAS'	, CCONSULTA)
	SELF:S('CONTEM'	, CFILTRO)

RETURN SELF

/*
@author		helitom.silva
@data			27 de abril de 2012
*/
METHOD ADDRETORN(CCONSULTA, CSEQRET, CRETORNO) CLASS UPDSXB
   /*
   *** XB_TIPO   := "5" - Quinta etapa
       Tipo que define o retorno da consulta

		XB_ALIAS  := cAlias                      //Nome da consulta
		XB_TIPO   := "5"                         //Tipo que define o retorno da consulta
		XB_SEQ    := "02"                        //Sequencia do Retorno
		XB_CONTEM := "Z07->Z07_CODIGO"           //Campo a ser retornado na consulta
   */

	::MODEL := 	{;
	'' 			,;//XB_ALIAS
	'5'			,;//XB_TIPO
	''			,;//XB_SEQ
	''	        ,;//XB_COLUNA
	''			,;//XB_DESCRI
	''			,;//XB_DESCSPA
	''			,;//XB_DESCENG
	''			} //XB_CONTEM

	AADD(::MODELS, ::MODEL)	 //REGISTRA O MODELO NA LISTA DE MODELOS

	SELF:S('ALIAS'	, CCONSULTA)
	SELF:S('SEQ'	, CSEQRET)
	SELF:S('CONTEM'	, CRETORNO)

RETURN SELF

/*
SETA O VALOR DO ATRIBUTO
*/
METHOD S(ATTR, VALOR) CLASS UPDSXB
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
METHOD CONFIRM() CLASS UPDSXB

	LOCAL I

	::OLOG:LOG("As seguintes Etapas da consulta foram adicionados ao dicionário SXB")

	DBSELECTAREA("SXB")
	DBSETORDER(1)

	FOR I := 1 TO LEN(::MODELS)

		::OLOG:LOG(" A Etapa Tipo:"+::MODELS[I][02]+", SEQ:"+::MODELS[I][03]+"]")

		dbGoTop()
		IIf(dbSeek(PADR(::MODELS[I][01],06)+::MODELS[I][02]+::MODELS[I][03]+::MODELS[I][04]),RLock(),dbAppend())
			XB_ALIAS   := ::MODELS[I][01]
			XB_TIPO    := ::MODELS[I][02]
			XB_SEQ     := ::MODELS[I][03]
			XB_COLUNA  := ::MODELS[I][04]
			XB_DESCRI  := ::MODELS[I][05]
			XB_DESCSPA := ::MODELS[I][06]
			XB_DESCENG := ::MODELS[I][07]
			XB_CONTEM  := ::MODELS[I][08]
		DBUNLOCK()

	NEXT

	::OLOG:LINE()

	::MODELS := {}

RETURN SELF

METHOD REMOVE(CCONSULTA) CLASS UPDSXB

	DBSELECTAREA("SXB")
	DBSETORDER(1)

	dbGoTop()
	If dbSeek(CCONSULTA)
		While .Not. Eof() .And. XB_ALIAS = CCONSULTA
			If RLock()
				dbDelete()
				dbUnLock()
			EndIf
			dbSkip()
		EndDo
	EndIf

RETURN SELF

METHOD SETLOG(OLOG) CLASS UPDSXB

	::OLOG := OLOG

RETURN SELF
