#INCLUDE "TOTVS.CH"

User Function MT110APV

Local cSql := ""
Local cMsg := ""
local lRet := .f.
local cUsuario := RetCodUsr()//Funcao que retorna o Cod do Usuario
local aArea := getArea()

	cSql := "SELECT count(AI_CC) as CONTADOR"
	cSql += "  FROM " + RetSqlName("SAI") + " (NOLOCK)" // SAI - Solicitantes
	cSql += " WHERE D_E_L_E_T_ = ' ' "
	cSql += "   AND AI_USER = '" + cUsuario + "' "
	cSql += "   AND AI_CC = '" + SC1->C1_CC + "' "
		
	cSql := ChangeQuery(cSql)

	MemoWrit( "SOLUSER.sql", cSql )
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cSql),"SOLUSER",.T.,.T.)

	If SOLUSER->( EOF() )
		lRet := .f.
	Else          
		If SOLUSER->CONTADOR > 0
			lRet := .t.
		Else      
			cMsg := "Este usuário não está cadastrado para aprovação "
			cMsg += "das solicitações de compra referentes ao centro de custo " + SC1->C1_CC   
			msgInfo(cMsg, "Atenção")                               
			lRet := .f.
		EndIf
	EndIf

	SOLUSER->( DbCloseArea() )
	
    RestArea( aArea )

Return lRet