#INCLUDE "protheus.ch"

User Function MT105QRY()

	Local _cFiltro  := ""						// Filtro do browse
	Local cUsuarios  :=SUPERGETMV("ES_SCSUP",.F.,"000000")
	IF ! RetCodUsr()$cUsuarios
		_cFiltro += "CP_CODUSR ='"+RetCodUsr()+"'"
	end       

Return( _cFiltro )
