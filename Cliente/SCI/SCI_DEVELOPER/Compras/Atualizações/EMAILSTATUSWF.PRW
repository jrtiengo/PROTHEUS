#include 'protheus.ch'
/*___________________________________________________________________________
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
||-------------------------------------------------------------------------||
|| Função: Mt097End     || Autor: Ednei Silva           || Data: 10/07/17  ||
||-------------------------------------------------------------------------||
|| Descrição: PE após Liberação de Documento com Alçada                    ||
||-------------------------------------------------------------------------||
|| Uso: Envia email para o solicitante informando se foi liberado/bloqueado||
||-------------------------------------------------------------------------||
|||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯*/  

User Function StatuEmail(cPed,cSit)

Local cPedido	:= Alltrim(cPed)
Local cSituac   := Alltrim(cSit)
Local cAliasX   := GetNextAlias()
Local cUser     :=""
Local lBloq     :=.F.
cQuery := " SELECT C7_NUM,"
cQuery += "        C7_NUMSC, "
cQuery += "        C7_USER "
cQuery += " FROM " + RetSQLName("SC7")
cQuery += " WHERE C7_FILIAL = '" + xFilial("SC7") + "'"
cQuery += "   AND C7_NUM = '" + cPedido + "'"
cQuery += "   AND D_E_L_E_T_<>'*'"
cQuery += "   GROUP BY C7_NUM,C7_NUMSC,C7_USER "
cQuery := ChangeQuery( cQuery )
dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery ),cAliasX,.F.,.T. )

While ( cAliasX )->( !Eof() )
	
	If Alltrim(cUser)=""
		cUser:=( cAliasX )->C7_USER
	endif
	
	
	If Alltrim(( cAliasX )->C7_NUMSC)<>"" 
		
		IF  (cSituac == 'L')
			U_cEnvSC(( cAliasX )->C7_NUM,( cAliasX )->C7_NUMSC,"L")
		else
			U_cEnvSC(( cAliasX )->C7_NUM,( cAliasX )->C7_NUMSC,"B")
			lBloq:=.T.
		Endif
		
	Else //Valdir 16/05/2019 - Verifica se existe ou não NumSC
	
	    If cSituac == "B"
			lBloq := .T.	    
	    EndIf
		
	Endif
	( cAliasX )->( dbSkip() )
	
EndDo
( cAliasX )->( dbCloseArea() )
If !lBloq
	MEnviaMail("034",{cPedido,'PC'},cUser)
endif

Return


//U_cEnvSC("001778","002808")

User  function cEnvSC(cPc,cSC,cSit)
Local nDias		 := 0
Local nHoras	 := 0
Local nMinutos	 := 10
Local cCodProc   := "000002"
Local cCodStatus := ""
Local cNumPC	 := cPc
Local cNumSC	 := cSC
Local cSituac    := cSit
Local cAssunto   := AllTrim( GetMV("ES_WFTITST") ) + " " + cNumPC  //Status medicao/pedido
Local cHtmlMod 	 := AllTrim( GetMV("ES_WFHTMST") )                 //
Local cUsuSiga	 := __CUSERID
Local cTitulo	 := ""
Local cMailID	 := ""
Local cRet		 := ""
Local cTexto 	 := ""
Local cQuery	 := ""
Local cAliasT	 := GetNextAlias()
Local lIsAPW 	 := HttpIsAPW()
Local nValTotal	 := 0
Local aRet		 := {}
Local i 		 := 0

If (lIsAPW)
	cRet := "Iniciado com StartWebEX ou StartWeb"
Else
	cRet := "Chamado Via APL"
EndIf

oProcess := TWFProcess():New(cCodProc, cAssunto)
oProcess:NewTask(cTitulo, cHtmlMod)
oHtml	:= oProcess:oHtml

dbSelectArea("SC7")
dbSetOrder(1)//C7_FILIAL+C7_NUM+C7_ITEM+C1_SEQUEN
If dbSeek( xFilial("SC7") + cNumPC )
	
	if cSituac='L'
		
		ConOut(" EMAILSTATUSWF PC_PDF SITUACAO LIBERADA " + DtoC( Date() ) + ' ' + Time() + ' FunName() ' + FunName()  )
		
		oProcess:oHtml:ValByName( "SITUACAO"	, 'Liberada')
		//Tarasconi aqui vamos ter gerar o PDF do PC e depois colocar o Link no mesmo...
		u_SCIR082( "SC7", SC7->(Recno()), "4" )
		//oProcess:oHtml:ValByName( "ANEXOS" , u_PC_PDF(cNumPC, oProcess ) )
		
		//Tarasconi em 04/06/2020 - existem casos em que ele ou não consegue gerar o PDF, ou não consegue achar
		//Acaba indo um WF sem o link do anexo e o Bruno precisa gerar novamente
		ConOut(" EMAILSTATUSWF PC_PDF ANTES IF " + DtoC( Date() ) + ' ' + Time() + ' FunName() ' + FunName()  )
		If !Empty( u_PC_PDF(cNumPC, oProcess ) )
			ConOut(" EMAILSTATUSWF PC_PDF VEIO CDOC " + DtoC( Date() ) + ' ' + Time() + ' FunName() ' + FunName()  )
			oProcess:oHtml:ValByName( "ANEXOS" , u_PC_PDF(cNumPC, oProcess ) )
		Else
			ConOut(" EMAILSTATUSWF PC_PDF NAO VEIO CDOC " + DtoC( Date() ) + ' ' + Time() + ' FunName() ' + FunName()  )
			//10 tentativas
			For i := 1 to 10
				ConOut(" EMAILSTATUSWF PC_PDF TENTATIVA " + DtoC( Date() ) + ' ' + Time() + ' FunName() ' + FunName()  )
				Sleep(5000) //Aguarda 5 segundos
				u_SCIR082( "SC7", SC7->(Recno()), "4" )
				If !Empty( u_PC_PDF(cNumPC, oProcess ) )
					oProcess:oHtml:ValByName( "ANEXOS" , u_PC_PDF(cNumPC, oProcess ) )
					Exit
				EndIf
			Next i
		EndIf
		
		
		
		
	else
		oProcess:oHtml:ValByName( "SITUACAO"	, 'Rejeitada. Motivo: '+cQLibPC( cNumPC ))
		//oProcess:oHtml:ValByName( "SITUACAO"	, 'Rejeitada')
	endif
	
	oProcess:oHtml:ValByName( "C7_NUM"		, SC7->C7_NUM )
	oProcess:oHtml:ValByName( "C7_EMISSAO"	, SC7->C7_EMISSAO )
	oProcess:oHtml:ValByName( "C7_FORNECE"	, SC7->C7_FORNECE + " / " + SC7->C7_LOJA )
	
	dbSelectArea("SA2")
	dbSetOrder(1)//A2_FILIAL+A2_COD+A2_LOJA
	If dbSeek( xFilial("SA2") + SC7->C7_FORNECE + SC7->C7_LOJA )
		oProcess:oHtml:ValByName( "C7_NOME"	, SA2->A2_NOME )
	EndIf
	
	oProcess:oHtml:ValByName( "C7_MOEDA"	, GetMV("MV_MOEDA" + cValToChar( SC7->C7_MOEDA ) ) )
	
	dbSelectArea("SC1")
		dbSetOrder(1)//C1_FILIAL+C1_NUM+C1_ITEM
		If dbSeek( xFilial("SC1") + SC7->C7_NUMSC + SC7->C7_ITEMSC )			
			oProcess:oHtml:ValByName( "C1_USER"	 , Capital( UsrFullName( SC1->C1_USER ) ) )
		Endif

	oProcess:oHtml:ValByName( "C7_NUMSC"	, SC7->C7_NUMSC )
	oProcess:oHtml:ValByName( "C7_FILENT"	, SC7->C7_FILENT )
	
	dbSelectArea("SM0")
	oProcess:oHtml:ValByName( "C7_FILIAL" 	, AllTrim( SM0->M0_CODFIL ) )
	
	cQuery := " SELECT C7_ITEM,"
	cQuery += "        C7_PRODUTO,"
	cQuery += "        C7_DESCRI,"
	cQuery += "        C7_QUANT,"
	cQuery += "        C7_UM,"
	cQuery += "        C7_PRECO,"
	cQuery += "        C7_TOTAL,"
	cQuery += "        C7_DATPRF,"
	cQuery += "        C7_NUMSC,"
	cQuery += "        C7_CC"
	cQuery += " FROM " + RetSQLName("SC7")
	cQuery += " WHERE C7_FILIAL= '" + xFilial("SC7") + "'"
	cQuery += "   AND C7_NUM   = '" + cNumPC + "'"
	cQuery += "   AND C7_NUMSC = '" + cSC + "'"
	cQuery += "   AND D_E_L_E_T_<>'*'"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery ),cAliasT,.F.,.T. )
	
	While ( cAliasT )->( !Eof() )  .and. ( cAliasT )->C7_NUMSC=cNumSC
		
		aAdd( ( oProcess:oHtml:ValByName( "A.C7_ITEM" ) ) 		, ( cAliasT )->C7_ITEM )
		aAdd( ( oProcess:oHtml:ValByName( "A.C7_PRODUTO" ) ) 	, ( cAliasT )->C7_PRODUTO )
		aAdd( ( oProcess:oHtml:ValByName( "A.C7_DESCRI" ) ) 	,  AllTrim( ( cAliasT )->C7_DESCRI ) )
		aAdd( ( oProcess:oHtml:ValByName( "A.C7_UM" ) ) 		, ( cAliasT )->C7_UM )
		aAdd( ( oProcess:oHtml:ValByName( "A.C7_QUANT" ) ) 		, ( cAliasT )->C7_QUANT )
		aAdd( ( oProcess:oHtml:ValByName( "A.C7_CC" ) ) 		, ( cAliasT )->C7_CC )
		
		dbSelectArea("CTT")
		dbSetOrder(1)//CTT_FILIAL+CTT_CUSTO
		If dbSeek( xFilial("CTT") + ( cAliasT )->C7_CC )
			aAdd( ( oProcess:oHtml:ValByName( "A.C7_DESCCC" ) ) 	, AllTrim( CTT->CTT_DESC01 ) )
		Else
			aAdd( ( oProcess:oHtml:ValByName( "A.C7_DESCCC" ) ) 	, "" )
		EndIf
		
		
		( cAliasT )->( dbSkip() )
		
	EndDo
	
	( cAliasT )->( dbCloseArea() )
	
        
	oProcess :cTo := AllTrim(cEmilSC(cSC))+';'+AllTrim(cEmilPC(cPc)) 
	oProcess :csubject := cAssunto +" "+ AllTrim(cSC)
	oProcess :Start()
	                 
	
EndIf

return



//----------------------------------------------------------------//
//Retorna o email do solicitante da solicitacao da linha do pedido//
//----------------------------------------------------------------//
static function cEmilSC(cNumSC)
Local cMail:=""

cQuery:=" SELECT *
cQuery+=" FROM "+ RetSQLName("SC1")+" "
cQuery+=" WHERE D_E_L_E_T_<>'*' "
cQuery+=" AND C1_NUM='"+cNumSC+"' "
cQuery := ChangeQuery(cQuery)
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TSCUSER",.F.,.T.)

cMail:= AllTrim(UsrRetMail(TSCUSER->C1_USER)) + AllTrim(GetMV("ES_WFMEDRE"))

TSCUSER->(dbcloseArea())

return cMail


//----------------------------------------------------------------//
//Retorna o email do comprador vinculado no pedido de compra      //
//----------------------------------------------------------------//
static function cEmilPC(cNumPC)
Local cMailPC:=""
Local cPedido:=""

cQuery := " SELECT C7_NUM,"
cQuery += "        C7_NUMSC, "
cQuery += "        C7_USER "
cQuery += " FROM " + RetSQLName("SC7")
cQuery += " WHERE C7_FILIAL = '" + xFilial("SC7") + "'"
cQuery += "   AND C7_NUM = '" + cNumPC + "'"
cQuery += "   AND D_E_L_E_T_<>'*'"
cQuery += "   GROUP BY C7_NUM,C7_NUMSC,C7_USER "
cQuery := ChangeQuery( cQuery )
DbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TPCUSER",.F.,.T.)

cMailPC:= AllTrim(UsrRetMail(TPCUSER->C7_USER)) 

TPCUSER->(dbcloseArea())

return cMailPC


User Function StEmailMD(cMED,cSit)
Local nDias		 := 0
Local nHoras	 := 0
Local nMinutos	 := 10
Local cCodProc   := "000002"
Local cCodStatus := ""
Local cNumMed	 := AllTrim(cMED)
Local cSituac    := cSit
Local cAssunto   := AllTrim( GetMV("ES_WFTITPC") ) + " " + cNumMed
Local cHtmlMod 	 := AllTrim( GetMV("ES_WFHTMST") )
Local cUsuSiga	 := __CUSERID
Local cTitulo	 := ""
Local cMailID	 := ""
Local cRet		 := ""
Local cTexto 	 := ""
Local cQuery	 := ""
Local cAliasT	 := GetNextAlias()
Local lIsAPW 	 := HttpIsAPW()
Local nValTotal	 := 0
Local aRet		 := {}
PRIVATE LAUTO    :=.F.
Private CFILCTR    :='0101'

If (lIsAPW)
	cRet := "Iniciado com StartWebEX ou StartWeb"
Else
	cRet := "Chamado Via APL"
EndIf

oProcess := TWFProcess():New(cCodProc, cAssunto)
oProcess:NewTask(cTitulo, cHtmlMod)
oHtml	:= oProcess:oHtml

dbSelectArea("CND")
dbSetOrder(4)//C7_FILIAL+C7_NUM+C7_ITEM+C1_SEQUEN
If dbSeek( xFilial("CND") + cNumMed )
	
	if cSituac='L'
		oProcess:oHtml:ValByName( "SITUACAO"	, 'Liberada')
	else
		oProcess:oHtml:ValByName( "SITUACAO"	, 'Rejeitada. Motivo: '+CND->CND_MOTREJ)
	endif
	
	oProcess:oHtml:ValByName( "C7_NUM"		, CND->CND_NUMMED )
	oProcess:oHtml:ValByName( "C7_EMISSAO"	, CND->CND_DTINIC )
	oProcess:oHtml:ValByName( "C7_FORNECE"	, CND->CND_FORNEC + " / " + CND->CND_LJFORN )
	
	dbSelectArea("SA2")
	dbSetOrder(1)//A2_FILIAL+A2_COD+A2_LOJA
	If dbSeek( xFilial("SA2") + CND->CND_FORNEC + CND->CND_LJFORN )
		oProcess:oHtml:ValByName( "C7_NOME"	, SA2->A2_NOME )
	EndIf
	
	oProcess:oHtml:ValByName( "C7_MOEDA"	, GetMV("MV_MOEDA" + cValToChar( CND->CND_MOEDA ) ) )
	
	dbSelectArea("CN9")
	dbSetOrder(1)//A2_FILIAL+A2_COD+A2_LOJA
	If dbSeek( xFilial("CN9") + CND->CND_CONTRA+CND->CND_REVISA+CND->CND_NUMERO+CND->CND_NUMMED)
		oProcess:oHtml:ValByName( "C7_USER"		, Capital( UsrFullName( CN9->CN9_CODUSU ) ) )
	EndIf
	oProcess:oHtml:ValByName( "C7_NUMSC"	, CND->CND_CONTRA )
	oProcess:oHtml:ValByName( "C7_FILENT"	, CND->CND_FILCTR )
	
	dbSelectArea("SM0")
	oProcess:oHtml:ValByName( "C7_FILIAL" 	, AllTrim( SM0->M0_CODFIL ) )
	
	cQuery := " SELECT CNE_ITEM,"
	cQuery += "        CNE_PRODUT,"
	cQuery += "        CNE_QUANT,"
	cQuery += "        CNE_VLUNIT,"
	cQuery += "        CNE_VLTOT,"
	cQuery += "        CNE_DTENT,"
	cQuery += "        CNE_CC"
	cQuery += " FROM " + RetSQLName("CNE")
	cQuery += " WHERE CNE_FILIAL = '" + xFilial("CNE") + "'"
	cQuery += "   AND CNE_NUMMED = '" + cNumMed + "'"
	cQuery += "   AND D_E_L_E_T_<>'*'"
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery ),cAliasT,.F.,.T. )
	
	While ( cAliasT )->( !Eof() )
		
		aAdd( ( oProcess:oHtml:ValByName( "A.C7_ITEM" ) ) 		, ( cAliasT )->CNE_ITEM )
		aAdd( ( oProcess:oHtml:ValByName( "A.C7_PRODUTO" ) ) 	, ( cAliasT )->CNE_PRODUT )
		dbSelectArea("SB1")
		dbSetOrder(1)//A2_FILIAL+A2_COD+A2_LOJA
		If dbSeek( xFilial("SB1") + CNE->CNE_PRODUT)
			aAdd( ( oProcess:oHtml:ValByName( "A.C7_DESCRI" ) ) 	, AllTrim( SB1->B1_DESC ) )
			aAdd( ( oProcess:oHtml:ValByName( "A.C7_UM" ) ) 		, SB1->B1_UM)
		EndIf
		aAdd( ( oProcess:oHtml:ValByName( "A.C7_QUANT" ) ) 	, ( cAliasT )->CNE_QUANT )
		aAdd( ( oProcess:oHtml:ValByName( "A.C7_CC" ) ) 		, ( cAliasT )->CNE_CC )
		
		dbSelectArea("CTT")
		dbSetOrder(1)//CTT_FILIAL+CTT_CUSTO
		If dbSeek( xFilial("CTT") + ( cAliasT )->CNE_CC )
			aAdd( ( oProcess:oHtml:ValByName( "A.C7_DESCCC" ) ) 	, AllTrim( CTT->CTT_DESC01 ) )
		Else
			aAdd( ( oProcess:oHtml:ValByName( "A.C7_DESCCC" ) ) 	, "" )
		EndIf
		
		( cAliasT )->( dbSkip() )
		
	EndDo
	
	( cAliasT )->( dbCloseArea() )
	
	oProcess :cTo := AllTrim(GetMV("ES_WFMEDRE"))
	oProcess :csubject := cAssunto +" "+ AllTrim(cNumMed)
	oProcess :Start()
	if cSituac='L'
	 cn120MedEnc(CND->(RECNO()))
	endif
    
EndIf

Return


Static Function  cQLibPC( cNumPC )

Local cOBS   		:= ""
Local cQuery		:= ""
Local cAliasZ		:= GetNextAlias()

FwLogMsg("INFO", /*cTransactionId*/, "REST", FunName(), "", "01", "Verificando quem ja liberou", 0, 0, {}) 

cQuery := " SELECT CR_OBSERV,CR_NIVEL "

cQuery += " FROM " + RetSQLName("SCR")
cQuery += " WHERE CR_FILIAL	  = '" + xFilial("SCR") + "'"
cQuery += "   AND CR_TIPO	  = 'PC'"
cQuery += "   AND CR_NUM      = '" + cNumPC + "'"
cQuery += "   AND CR_DATALIB <> ''"
cQuery += "   AND CR_OBSERV     <> ''"
cQuery += "   AND D_E_L_E_T_ <> '*'"
cQuery += " ORDER BY CR_NIVEL"
cQuery := ChangeQuery( cQuery )
dbUseArea( .T.,"TOPCONN",TcGenQry(,,cQuery),cAliasZ,.F.,.T. )


	IF ( cAliasZ )->( !Eof() )		
		cOBS:=( cAliasZ )->CR_OBSERV
	
	
	dbSelectArea("SC7")
	dbSetOrder(1)
	
	If dbSeek( xFilial("SC7") + cNumPC )
			    
	RecLock( "SC7", .F. )
	SC7->C7_CONAPRO := "R"
	MsUnLock()           

  	Endif
	    

Endif
( cAliasZ )->( dbCloseArea() ) 

Return( cObs )
                  
*****************************************************************************************************************************
*****************************************************************************************************************************
*****************************************************************************************************************************
User Function PC_PDF(cC7Num,oProcess)

Local cQry     := ""
Local cAliasA  := GetNextAlias()
Local cLogoAnx := ""
Local cAnex    := "http://aprovacao.internacional.net.br:9090/workflow/dirdoc/co01/shared/"
Local cImgRoot := "http://aprovacao.internacional.net.br:9090/workflow/img-workflow/"
Local cLocFile :="\workflow\dirdoc\co01\shared\"
Local cDoc	   :=""
Local a        := 0
Local nCont    := 0
Local aExt     := {}
Local nSize    := 0
Local cImg     := ''
Local aRetFile := {'',''}
Local cGetFile := ""
Local cFile    := ""
Local cExten   := ""
Local cScs     := ""

ConOut(" EMAILSTATUSWF PC_PDF " + DtoC( Date() ) + ' ' + Time() + ' FunName() ' + FunName()  )	

dbSelectArea('SC7')
dbSetOrder(1)
If dbSeek(xFilial('SC7')+cC7Num)
	
	ConOut(" EMAILSTATUSWF PC_PDF " + DtoC( Date() ) + ' ' + Time() + ' cC7Num ' + cC7Num  )	

	cGetFile := AllTrim( cLocFile +"Pedido_Compra_Num_"+Alltrim(cC7Num)+".pdf" )

	ConOut(" EMAILSTATUSWF PC_PDF " + DtoC( Date() ) + ' ' + Time() + ' cGetFile ' + cGetFile  )	

	SplitPath( cGetFile, , , @cFile, @cExten )
	
	cNameTerm := cFile + cExten
	cNameServ := cNameTerm
	
	cDirDocs := MsDocPath()

	ConOut(" EMAILSTATUSWF PC_PDF " + DtoC( Date() ) + ' ' + Time() + ' cDirDocs ' + cDirDocs  )	
	ConOut(" EMAILSTATUSWF PC_PDF " + DtoC( Date() ) + ' ' + Time() + ' cNameServ ' + cNameServ  )	

	//If File( Alltrim(cDirDocs) + "\" + cNameServ )
	If File( cGetFile )
		
		nCont++
		
		do case
			case UPPER(cExten) == '.PDF'
				cImg := "<img src='"+cImgRoot+"pdf-icon.png' style='padding:0px 1px 0px 0px;'>"
			case UPPER(cExten) == '.TXT'
				cImg := "<img src='"+cImgRoot+"txt-icon.png' style='padding:0px 1px 0px 0px;'>"
			case UPPER(cExten) == '.XLS'
				cImg := "<img src='"+cImgRoot+"xls-icon.png' style='padding:0px 1px 0px 0px;'>"
			case UPPER(cExten) == '.DOC'
				cImg := "<img src='"+cImgRoot+"doc-icon.png' style='padding:0px 1px 0px 0px;'>"
			case UPPER(cExten) == '.JPG'
				cImg := "<img src='"+cImgRoot+"jpg-icon.png' style='padding:0px 1px 0px 0px;'>"
			case UPPER(cExten) == '.JPEG'
				cImg := "<img src='"+cImgRoot+"jpeg-icon.png' style='padding:0px 1px 0px 0px;'>"
			case UPPER(cExten) == '.PNG'
				cImg := "<img src='"+cImgRoot+"png-icon.png' style='padding:0px 1px 0px 0px;'>"
			case UPPER(cExten) == '.DOCX'
				cImg := "<img src='"+cImgRoot+"docx-icon.png' style='padding:0px 1px 0px 0px;'>"
			case UPPER(cExten) == '.CSV'
				cImg := "<img src='"+cImgRoot+"csv-icon.png' style='padding:0px 1px 0px 0px;'>"
			case UPPER(cExten) == '.PPT'
				cImg := "<img src='"+cImgRoot+"ppt-icon.png' style='padding:0px 1px 0px 0px;'>"
			case UPPER(cExten) == '.XLSX'
				cImg := "<img src='"+cImgRoot+"xlsx-icon.png' style='padding:0px 1px 0px 0px;'>"
			otherwise
				cImg := "<img src='"+cImgRoot+"no-file.png' style='padding:0px 1px 0px 0px;'>"
		EndCase
		
		//nSize := RetSize(Alltrim(cDirDocs) + "\" + cNameServ)
		nSize := RetSize( cGetFile )
				
		cDoc +="<span style='padding:5px;'>
		
		If !Empty(cImg)
			
			cDoc += cImg
			
		EndIf
		
		cDoc +="	<b id='anexo_item'><a href='"+cAnex+cNameServ+"' download='"+cNameServ+"' style='font-size: 14px;'>
		//cDoc +="		Anexo "+cValToChAR(nCont)+" "+ IIF(nSize > 0 ,"("+cValToChar(round(nSize/1000,0))+" KB)",'')+"</a> "
		  cDoc +="      Pedido_Compra_Num_"+Alltrim(cC7Num)+".pdf"+" "+ IIF(nSize > 0 ,"("+cValToChar(round(nSize/1000,0))+" KB)",'')+"</a> "
		//cDoc  +=" 	"+( cAliasA )->(ACB_OBJETO)+"</a> "
		cDoc +="	</b>"
		cDoc +="</span>"
		
		//oProcess:oHtml:ValByName( "ANEXOS", cDoc )
		//ConOut(" EMAILSTATUSWF PC_PDF " + DtoC( Date() ) + ' ' + Time() + ' cDoc ' + cDoc  )	

		aDocs := {}
		
	EndIf

EndIf

Return(cDoc)


Static Function RetSize(cArqObj)

	Local oFile := Nil
	Local nSize := 0
    Local nSize := 0

	oFile := FWFileReader():New(cArqObj)

	If (oFile:Open())

   		nSize:= oFile:getFileSize()
   		oFile:Close()

	EndIf


Return nSize
