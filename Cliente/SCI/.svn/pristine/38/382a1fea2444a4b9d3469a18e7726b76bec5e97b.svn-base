#include 'protheus.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SCIF015   ºAutor  ³Microsiga           º Data ³  06/19/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Status do PA                                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function StatuPA(cNumPA,cSit,cObs)

Local cSituac   := Alltrim(cSit)
Local cAliasX   := GetNextAlias()
Local cUser     := ""
Local cCodProc   := "000003"
Local cCodStatus := ""
Local cAssunto   := AllTrim( GetMV("ES_WFSTPA") ) + " " + cNumPA
Local cHtmlMod 	 := AllTrim( GetMV("ES_WFHTPA") )                 //
Local cUsuSiga	 := __CUSERID
Local cTitulo	 := ""
Local cRet		 := ""
Local cQuery	 := ""
Local cAliasT	 := GetNextAlias()
Local lIsAPW 	 := HttpIsAPW()

If (lIsAPW)
	cRet := "Iniciado com StartWebEX ou StartWeb"
Else
	cRet := "Chamado Via APL"
EndIf

oProcess := TWFProcess():New(cCodProc, cAssunto)
oProcess:NewTask(cTitulo, cHtmlMod)
oHtml	:= oProcess:oHtml

aRet := {}
aRet := cQLibPC( cNumPA )

if cSituac == 'L'
	oProcess:oHtml:ValByName( "SITUACAO"	, 'Liberada')
else
	//oProcess:oHtml:ValByName( "SITUACAO"	, 'Rejeitada. Motivo: '+cQLibPC( cNumPA ))
	oProcess:oHtml:ValByName( "SITUACAO"	, 'Rejeitada. Motivo: '+Alltrim( cObs ))
	//oProcess:oHtml:ValByName( "SITUACAO"	, 'Rejeitada')
endif

	oProcess:oHtml:ValByName( "E2_NUM"		, SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA+E2_TIPO) )
	oProcess:oHtml:ValByName( "E2_EMISSAO"	, SE2->E2_EMISSAO )
	oProcess:oHtml:ValByName( "E2_FORNECE"	, SE2->E2_FORNECE + "/" + SE2->E2_LOJA )
		
	dbSelectArea("SA2")
	dbSetOrder(1)//A2_FILIAL+A2_COD+A2_LOJA
	If dbSeek( xFilial("SA2") + SE2->E2_FORNECE + SE2->E2_LOJA )
		oProcess:oHtml:ValByName( "E2_NOME"	, SA2->A2_NOME )
	EndIf
		
	cAssunto += " " + Alltrim(SA2->A2_NOME)
	
	oProcess:oHtml:ValByName( "E2_MOEDA"	, GetMV("MV_MOEDA" + cValToChar( SE2->E2_MOEDA ) ) )
	oProcess:oHtml:ValByName( "E2_USER"     , Capital( UsrFullName( SE2->E2_SOLPA ) ) ) 

	cDest := ""
	For tt:=1 to Len(aRet) //Step 4
        If !Alltrim(aRet[tt]) $ cDest
	        cDest += Alltrim(aRet[tt])+";"   
        EndIf
	Next tt

oProcess :cTo := cDest 
oProcess :csubject := cAssunto 
oProcess :Start()


return

*****************************************************************************************************************************************************
*****************************************************************************************************************************************************
*****************************************************************************************************************************************************
Static Function  cQLibPC( cNumPA )

Local cOBS   		:= ""
Local cQuery		:= ""
Local cAliasZ		:= GetNextAlias()
Local aRet		    := {}

cQuery := " SELECT CR_OBS, CR_USER "
cQuery += " FROM " + RetSQLName("SCR")
cQuery += " WHERE CR_FILIAL	  = '" + xFilial("SCR") + "'"
cQuery += "   AND CR_TIPO	  = 'PA'"
cQuery += "   AND CR_NUM      = '" + cNumPA + "'"
cQuery += "   AND CR_DATALIB <> ''"
//cQuery += "   AND CR_OBS     <> ''"
cQuery += "   AND D_E_L_E_T_ <> '*'"
cQuery += " ORDER BY CR_NIVEL"
cQuery := ChangeQuery( cQuery )
dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZ,.F.,.T. )
While !EOF()

	IF ( cAliasZ )->( !Eof() )
	
		//cOBS := ( cAliasZ )->CR_OBS
		aRet := {}
		aAdd( aRet, AllTrim( UsrRetMail( ( cAliasZ )->CR_USER ) ) )
	
	Endif

( cAliasZ )->( dbSkip() )	
End
( cAliasZ )->( dbCloseArea() )

//Return( cObs )
Return( aRet )