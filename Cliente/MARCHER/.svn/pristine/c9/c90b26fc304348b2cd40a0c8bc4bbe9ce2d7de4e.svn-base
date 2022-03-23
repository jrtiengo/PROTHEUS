#Include 'Protheus.ch'
#Include 'TopConn.ch'
#Include "Totvs.ch"
#Include "TOPCONN.CH"
#Include "Rwmake.ch"
#define USADO CHR(0)+CHR(0)+CHR(1)
#define DS_MODALFRAME   128

/*/{Protheus.doc} MARSPD54
Exporta os dados da tabela SPED054, conforme o periodo informado.
@type function
@author Mauro - Solutio
@since 09/04/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

User Function MARSPD54()
	
	Local oDataD
	Local oDataA
	Local nOpc		:= 0
	
	Private cDataD	:= date()
	Private cDataA	:= date()
	Private _oDlg

	DEFINE MSDIALOG _oDlg TITLE "Relatorio SPED054" FROM C(294),C(413) TO C(557),C(949) PIXEL

	@ C(020),C(020) Say "Informe o periodo do relatorio." 	Size C(073),C(008) COLOR CLR_BLACK 						PIXEL OF _oDlg
	@ C(057),C(020) Say "Data inicial:" 					Size C(029),C(008) COLOR CLR_BLACK 						PIXEL OF _oDlg
	@ C(055),C(050) MsGet oDataD Var cDataD 				Size C(060),C(009) COLOR CLR_BLACK PICTURE "@!" 		PIXEL OF _oDlg
	@ C(057),C(150) Say "Data final:" 						Size C(026),C(008) COLOR CLR_BLACK 						PIXEL OF _oDlg
	@ C(055),C(180) MsGet oDataA Var cDataA 				Size C(060),C(009) COLOR CLR_BLACK PICTURE "@!" 		PIXEL OF _oDlg
	@ C(100),C(035) Button "Confirma" 						Size C(037),C(012) ACTION ( nOpc := 1, _oDlg:End() )	PIXEL OF _oDlg
	@ C(100),C(190) Button "Cancela" 						Size C(037),C(012) ACTION ( nOpc := 2, _oDlg:End() )	PIXEL OF _oDlg

	ACTIVATE MSDIALOG _oDlg CENTERED
	
	If nOpc == 1
		Processa( {|| MARPROC() }, "Gerando relatorio...", "Processando aguarde...", .f.)
	EndIf

Return(.T.)


/*/{Protheus.doc} MARSPD54
Exporta os dados da tabela SPED054, conforme o periodo informado.
@type function
@author Mauro - Solutio
@since 09/04/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Static Function MARPROC()
	
	Local oDlgXLS
	Local cDirDocs	:= MsDocPath()
	Local cArquivo	:= CriaTrab(Nil, .F.)
	Local cPath		:= AllTrim(GetTempPath())
	Local cCrLf		:= Chr(13) + Chr(10)
	Local nHandle	:= 0
	Local oExcelApp
	Local cCab 		:= ""
	Local cQuery 	:= ""
	Local aHeader	:= {}
	
	Local cBDSped	:= "@!!@MSSQL/TOTVS_TSS"
	Local cBDProd	:= "@!!@MSSQL/TOTVS_PRODUCAO" 
	Local cIPBD		:= "172.16.0.2"
	Local _nTcConn	:= ""
	Local _nTcConn2	:= ""
		
	TCCONTYPE("TCPIP")
	_nTcConn  := TCLink(cBDSped,cIPBD,7892)
	_nTcConn2 := TCLink(cBDProd,cIPBD,7890)
	If (_nTcConn < 0) .OR. (_nTcConn2 < 0)
		Alert ("Erro de Conexao com o Banco de Dados!")
		Return()
	Endif

	nHandle := MsfCreate(cDirDocs + "\" + cArquivo + ".CSV", 0)
	
	If nHandle > 0
	
		// Monta cabecalho.
		AADD(aHeader,{"Serie/Nota"	,"SERIENOTA"	,"@X"	,12,0,".f.",USADO,"C","",""})
		AADD(aHeader,{"Chave NFE"	,"CHAVE"		,"@X"	,99,0,".f.",USADO,"C","",""})
		AADD(aHeader,{"Codigo"		,"CODIGO"		,"@X"	,03,0,".f.",USADO,"C","",""})
		AADD(aHeader,{"Motivo"		,"MOTIVO"		,"@X"	,99,0,".f.",USADO,"C","",""})
		AADD(aHeader,{"Data"		,"DATA"			,"@X"	,10,0,".f.",USADO,"C","",""})
		
		For nCont := 1 To Len(aHeader)
			cCab += aHeader[nCont][1]
			If nCont<>Len(aHeader)
				cCab += ";"
			Else
				cCab += cCrLf
			EndIf
		Next nCont
		FWrite(nHandle,cCab)
		cCab := ""
		
		// Pega os dados conforme filtro informado.
		TCSETCONN (_nTcConn) // Conecta na base do sped.
		cQuery := " SELECT NFE_ID, NFE_CHV, CSTAT_SEFR, XMOT_SEFR, DTREC_SEFR "
		cQuery += " FROM SPED054 "
		cQuery += " WHERE DTREC_SEFR BETWEEN '"+ Dtos(cDataD) +"' AND '"+ Dtos(cDataA) +"' "
		
		If Select("TMP") <>  0
			TMP->(DbCloseArea())
		EndIf
						
		TcQuery cQuery New Alias "TMP"
				
		DbSelectArea("TMP")
		Do While !EOF()
			Fwrite(nHandle,AllTrim(TMP->NFE_ID)		+";")
			Fwrite(nHandle,AllTrim(TMP->NFE_CHV)+" "+";")
			Fwrite(nHandle,AllTrim(TMP->CSTAT_SEFR)	+";")
			Fwrite(nHandle,AllTrim(TMP->XMOT_SEFR)	+";")
			Fwrite(nHandle,Dtoc(Stod(TMP->DTREC_SEFR))	+";")
			Fwrite(nHandle,cCrLf)
			FWrite(nHandle,cCab)
		
			DbSelectArea("TMP")
			DbSkip()
		EndDo
		TMP->(DbCloseArea())
		
		TCSETCONN (_nTcConn2) // Conecta na base producao
	
		Fclose(nHandle)
		CpyS2T( cDirDocs + "\" + cArquivo + ".CSV", cPath, .T. )

		If !ApOleClient('MsExcel')
			MsgAlert('MsExcel nao instalado')
			Return()
		EndIf

		oExcelApp := MsExcel():New()
		oExcelApp:WorkBooks:Open(cPath + "\" + cArquivo + ".CSV" )
		oExcelApp:SetVisible(.T.)
	Else
		MsgAlert("Falha na criacao do arquivo!")
	EndIf

Return()


/*/{Protheus.doc} MARSPD54
Exporta os dados da tabela SPED054, conforme o periodo informado.
@type function
@author Mauro - Solutio
@since 09/04/2019
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Static Function C(nTam)
	Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
		nTam *= 0.8
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600
		nTam *= 1
	Else	// Resolucao 1024x768 e acima
		nTam *= 1.28
	EndIf
                                                                                
	//旼컴컴컴컴컴컴컴컴컴컴컴컴컴?                                              
	//쿟ratamento para tema "Flat"?                                              
	//읕컴컴컴컴컴컴컴컴컴컴컴컴컴?                                              
	If "MP8" $ oApp:cVersion
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()
			nTam *= 0.90
		EndIf
	EndIf
Return Int(nTam)