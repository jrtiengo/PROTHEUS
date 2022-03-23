#INCLUDE "TOTVS.CH"


User Function MT110QRY 

Local cSql   := ""
Local cQuery := ""
local cUsuario := RetCodUsr()//Funcao que retorna o Cod do Usuario     
local aArea := getArea()
//.. Customização do cliente

	cSql := "SELECT AI_CC "
	cSql += "  FROM " + RetSqlName("SAI") + " (NOLOCK)" // SAI - Solicitantes
	cSql += " WHERE D_E_L_E_T_ = ' ' "
	cSql += "   AND AI_USER = '" + cUsuario + "' "
	
	cSql := ChangeQuery(cSql)
	MemoWrit( "SOLUSER.sql", cSql )
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"SOLUSER",.T.,.T.)

	// Se está no final do arquivo, irá filtrar as solicitações do próprio usuário
	If SOLUSER->( EOF() )                                                         
		cQuery +=  " C1_USER = '" + cUsuario + "' "                       //enxergar tudo por opção           
	Else
		// Se a consulta retornou registro porém não tem nenhum Centro de Custo cadastrado para o usuário, irá filtrar as solicitações do próprio usuário
		If Empty( SOLUSER->AI_CC )
			cQuery +=  ""   
		Else
			//cQuery += " C1_FILIAL='"+xFilial("SC1")+"' AND C1_NUM >= '000003' "
			// O sistema irá filtrar todas as Solicitações existentes para o Centro de Custo do usuário
		   //	cFiltro +=  " C1_CC == '" + SOLUSER->AI_CC + "' "   
			cQuery += " ( C1_USER = '" + cUsuario + "' ) OR ( C1_CC IN (SELECT AI_CC FROM " + RetSqlName("SAI") + " (NOLOCK) "
	   		cQuery += "   	WHERE AI_USER = '" + cUsuario + "' " "
	   		cQuery += "   	AND D_E_L_E_T_ = ' ') ) "  
	   	   //	cQuery += " OR  C1_USER == '" + cUsuario + "' "
		EndIf
	EndIf

	SOLUSER->( DbCloseArea() )
	
    RestArea( aArea )

//cQuery += " C1_FILIAL='"+xFilial("SC1")+"' AND C1_NUM >= '000003' "

Return cQuery