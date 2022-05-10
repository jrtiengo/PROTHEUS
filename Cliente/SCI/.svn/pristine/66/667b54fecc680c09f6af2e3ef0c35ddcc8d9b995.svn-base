#INCLUDE "protheus.ch"

User Function CN100FIL()
	Local _cFiltro := "1=2"						// Filtro do browse
	LOCAL cGrupo   :=""
	
	dbSelectArea("SZ5")
	dbSetOrder(3)
	if dbSeek(xFilial("SZ5")+RetCodUsr(),.F.)
		cGrupo:=Alltrim(SZ5->Z5_GRUPO)
	End
	
	IF ! RetCodUsr() $ GetMV("ES_CTOSUP").And.!Empty(cGrupo)    
		_cFiltro := "CN9->CN9_GRPCTR='"+cGrupo+"'"
	   //	Alert('Filtrando Contratos Somente do Grupo de Contratos '+cGrupo)
	END
	IF RetCodUsr() $ GetMV("ES_CTOSUP")              
		_cFiltro := ""
	END                                           
Return( _cFiltro )
