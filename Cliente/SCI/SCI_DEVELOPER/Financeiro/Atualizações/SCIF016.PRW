#include 'protheus.ch'
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³SCIF016   ºAutor  ³Microsiga           º Data ³  06/26/19   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Status do Processo                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function StaPR(cNumProc,cSit)

Local cSituac   := Alltrim(cSit)
Local cAliasX   := GetNextAlias()
Local cUser     := ""
Local cCodProc   := "000004"
Local cCodStatus := ""
Local cAssunto   := AllTrim( GetMV("ES_WFSTPR") ) + " " + cNumProc
Local cHtmlMod 	 := AllTrim( GetMV("ES_WFHTPR") )                 //
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
aRet := cQLibPC( cNumProc )

if cSituac == 'L'
	oProcess:oHtml:ValByName( "SITUACAO"	, 'Liberada')
else
	//oProcess:oHtml:ValByName( "SITUACAO"	, 'Rejeitada. Motivo: '+cQLibPC( cNumProc ))
	oProcess:oHtml:ValByName( "SITUACAO"	, 'Rejeitada')
endif

	oProcess:oHtml:ValByName( "Z02_NUM"		, cNumProc )


	//Aqui pego todoas as DEspesas...
	aAreaZ02   := Z02->(GetArea())
	nTotalDesp := 0
	cChave := xFilial("Z02")+Z02->(Z02_CHAVE+Z02_NUMRES)
	dbSelectArea("Z02")
	dbSetOrder(1)
	dbSeek(xFilial("Z02")+Z02->(Z02_CHAVE+Z02_NUMRES),.f.)

	While !EOF() .and. cChave == xFilial("Z02")+Z02->(Z02_CHAVE+Z02_NUMRES)
		
		aAdd( ( oProcess:oHtml:ValByName( "A.Z02_NUMERO" ) ) 		, Z02->(Z02_PREF+Z02_NUMERO+Z02_PARC+Z02_TIPO) )
		aAdd( ( oProcess:oHtml:ValByName( "A.Z02_FORNECE" ) )	, Z02->(Z02_FORNEC+ ' / ' + Z02_LOJA) )
		
		dbSelectArea("SA2")
		dbSetOrder(1)//A2_FILIAL+A2_COD+A2_LOJA
		If dbSeek( xFilial("SA2") + Z02->Z02_FORNEC + Z02->Z02_LOJA )
			aAdd( ( oProcess:oHtml:ValByName( "A.Z02_NOME" ) )  , SA2->A2_NOME )
		EndIf
		aAdd( ( oProcess:oHtml:ValByName( "A.Z02_VALOR" ))	, Transform( Z02->Z02_VALOR, PesqPict("Z02","Z02_VALOR") ) )
		
		nTotalDesp += Z02->Z02_VALOR
		
		aAdd( ( oProcess:oHtml:ValByName( "A.Z02_NATUREZA" ) ), Alltrim(Z02->Z02_NAT) + ' ' + Posicione("SED",1,xFilial("SED")+Z02->Z02_NAT,"ED_DESCRIC")  )
		aAdd( ( oProcess:oHtml:ValByName( "A.Z02_CC"    )	) , Alltrim(Z02->Z02_CC) + ' ' + Posicione("CTT",1,xFilial("CTT")+Z02->Z02_CC,"CTT_DESC01")   )
		aAdd( ( oProcess:oHtml:ValByName( "A.ANEXOS"    )	) , u_S99AConhe(Z02->(Z02_CHAVE+Z02_NUMRES+Z02_ITEM),oProcess)   )
		
		dbSelectArea("Z02")
		Z02->(dbSkip())
	End
	RestArea(aAreaZ02)
	                   
	oProcess:oHtml:ValByName( "Z02_TOTAL"	, Transform( nTotalDesp, PesqPict("Z02","Z02_VALOR") ) )

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
Static Function  cQLibPC( cNumProc )

Local cOBS   		:= ""
Local cQuery		:= ""
Local cAliasZ		:= GetNextAlias()
Local aRet		    := {}

cQuery := " SELECT CR_OBS, CR_USER "
cQuery += " FROM " + RetSQLName("SCR")
cQuery += " WHERE CR_FILIAL	  = '" + xFilial("SCR") + "'"

If Z02->Z02_TPPA $ "1"
	cQuery += "   AND CR_TIPO	  = 'D1'"
Else
	cQuery += "   AND CR_TIPO	  = 'D2'"
EndIf

//cQuery += "   AND CR_TIPO	  = 'PA'"
cQuery += "   AND CR_NUM      = '" + cNumProc + "'"
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