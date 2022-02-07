#INCLUDE 'PROTHEUS.CH'

/*{ProtheusDoc} UPDLOG

	Ferramenta de LOG
	
	@author		fernando.alencar
	@data			11 de outubro de 2011
	@method		{create} 	cria um novo objeto
	@method 		{LINE} 	imprime uma linha no log 	
	@method 		{GETLOG}		 	
	@method 		{SAVE} 	
	@method		{SETPATH}	
*/
CLASS UPDLOG 
                
	DATA LOG
	DATA PATH
	
	METHOD CREATE() CONSTRUCTOR
	METHOD LOG()
	METHOD LINE()
    METHOD GETLOG()
    METHOD SAVE()
	METHOD SETPATH()
	
ENDCLASS           

METHOD CREATE(LOG) CLASS UPDLOG                  
	IF LOG == NIL .OR. TYPE(LOG) != 'C'
		::LOG := ""
	ELSE 
		::LOG := LOG
	ENDIF
RETURN ::SELF   

METHOD LOG(MSG) CLASS UPDLOG
	IF MSG == NIL .OR. EMPTY(MSG)
		RETURN ::LOG
	ENDIF
	CONOUT(MSG)//ENVIA PARA O LOG DO APPSERVER
	::LOG += MSG + CRLF
RETURN ::LOG           

METHOD LINE() CLASS UPDLOG  
	::LOG += REPLICATE( '-', 128 ) + CRLF
RETURN ::LOG

METHOD SETPATH(PATH) CLASS UPDLOG 
    ::PATH := PATH
RETURN NIL

METHOD SAVE() CLASS UPDLOG 
	MEMOWRITE(::PATH, ::LOG)
RETURN .F.