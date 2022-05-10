#INCLUDE "protheus.ch"

User Function MT110QRY()

	Local _cFiltro  := ""						// Filtro do browse
	//Local _cUsuario := RetCodUsr()				// Codigo de usuario
	Local cUsuarios  :=SUPERGETMV("ES_SOLSUP",.F.,"000000")
	IF ! RetCodUsr()$cUsuarios
		_cFiltro += "C1_USER ='"+RetCodUsr()+"'"
	end

Return( _cFiltro )
