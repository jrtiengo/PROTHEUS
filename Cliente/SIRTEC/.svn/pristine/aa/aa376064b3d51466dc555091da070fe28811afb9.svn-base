#Include "folder.ch"
#Include "font.ch"
#Include "colors.ch"
#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"

#define STR0001 'Sirtec - STCA019'
#define STR0002 'Sirtec - Replica de agendas'
#define STR0003 'Criando relacionamento de técnicos...'
#define STR0004 'Consulta sem registros...'
#define STR0005 'Não foram encontrados relacionamentos a serem apagados!'

/*/
+----------+----------+-------+-----------------------+------+------------+
|Função    |STCA019   | Autor |Microsiga Vitória      | Data |09.10.2007  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Replica os dados da agenda da equipe para os tecnicos         |
+----------+--------------------------------------------------------------+
|Retorno   |                                                              |
+----------+--------------------------------------------------------------+
|Parâmetros|                                                              |
+----------+--------------------------------------------------------------+
|Uso       |Field Service -> Sirtec                                       |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+----------+--------------------------------------------------------------+
| Data     | Descrição                                                    |
+----------+--------------------------------------------------------------+
|          |                                                              |
+----------+--------------------------------------------------------------+
/*/
User Function STCA019(nOpc)
	
	//Variaveis de controle da rotina
	Private aCampos := {}
	Private aCpoBrw := {}
	Private cMarca  := GetMark()
	Private cNumOS  := ABB_NUMOS 
	Private cEquipe := ABB_CODTEC
	Private cNomeEq := Posicione("AA1",1,xFilial("AA1")+ABB_CODTEC,"AA1_NOMTEC")
	
	//Variaveis de controle dos objetos
	Private oDlgSTC			//Dialog
	Private oFont			//Fonte utilizada
	Private oGet01			//Getdados
	Private oTCab1			//Titulo no Cabeçalho
	Private oICab1			//Informação no Cabeçalho
	Private oTCab2			//Titulo no Cabeçalho
	Private oICab2			//Informação no Cabeçalho
	
	////////////////////
	//Montagem da tela//
	////////////////////

	//Processamento da tela. Verifica se é inclusão ou alteração
	MsAguarde({|| fSTCA001(nOpc)},STR0001,STR0002) 
		
	//VERIFICA SE  A CONSULTA RETORNOU ALGUM ITEM
	If !Select("_ZZ4")>1	
	 	Alert(STR0004)
		Return
	End If
	
	//Definição da Fonte
	oFont  := tFont():new(,,-11,,.T.)
	oFont2  := tFont():new(,,-18,,.T.)
	
	DEFINE MSDIALOG oDlgSTC TITLE STR0002 FROM C(200),C(200) TO C(500),C(700) PIXEL

	// Cria as Groups do Sistema
	@ C(012),C(008) TO C(040),C(245) LABEL "Informações da OS: " PIXEL OF oDlgSTC
	
	//Informações do cabeçalho
	oTCab1 := tSay():New(025,015,{||"Numero OS: "},oDlgSTC,,,,,,.T.,,,270,20) 
	oICab1 := tSay():New(025,050,{||cNumOS}       ,oDlgSTC,,oFont,,,,.T.,If(nOpc==2,CLR_RED,CLR_GREEN),If(nOpc==2,CLR_RED,CLR_GREEN),270,20)
	
	oTCab2 := tSay():New(037,015,{||"Equipe: "}   ,oDlgSTC,,,,,,.T.,,,270,20) 
	oICab2 := tSay():New(037,050,{||cEquipe}      ,oDlgSTC,,oFont,,,,.T.,If(nOpc==2,CLR_RED,CLR_GREEN),If(nOpc==2,CLR_RED,CLR_GREEN),270,20)

	oTCab3 := tSay():New(037,085,{||"Nome: "}     ,oDlgSTC,,,,,,.T.,,,270,20) 
	oICab3 := tSay():New(037,120,{||cNomeEq}      ,oDlgSTC,,oFont,,,,.T.,If(nOpc==2,CLR_RED,CLR_GREEN),If(nOpc==2,CLR_RED,CLR_GREEN),270,20)
	
	If nOpc == 2
		oTCab4 := tSay():New(025,170,{||"CANCELAMENTO DE AGENDA"},oDlgSTC,,oFont2,,,,.T.,CLR_HRED,CLR_HRED,270,20)
	Endif
	
	//Inclusao dos GetDados	 
	oGet01 := MsSelect():New(_cTRB1,"MARCA","",aCpoBrw,.F.,cMarca,{C(045),C(008),C(140),C(245)})
	oGet01:bAval := {|| fSTCA0002()}
	
	ACTIVATE MSDIALOG oDlgSTC On Init (EnchoiceBar(oDlgSTC,{||Processa({||U_STCA019A(nOpc)},STR0001,STR0003);
	,oDlgSTC:End()},{|| oDlgSTC:End()},,/*aButtons*/)) CENTERED

Return

/*/
+----------+----------+-------+-----------------------+------+------------+
|Função    |STCA019A  | Autor |Microsiga Vitória      | Data |09.10.2007  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Grava o relacionamento                                        |
+----------+--------------------------------------------------------------+
|Retorno   |                                                              |
+----------+--------------------------------------------------------------+
|Parâmetros|                                                              |
+----------+--------------------------------------------------------------+
|Uso       |Field Service -> Sirtec                                       |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+----------+--------------------------------------------------------------+
| Data     | Descrição                                                    |
+----------+--------------------------------------------------------------+
|          |                                                              |
+----------+--------------------------------------------------------------+
/*/
User Function STCA019A(nOpc)

	Local cChave := DTOS(ABB->ABB_DTINI)+ABB->ABB_HRINI+DTOS(ABB->ABB_DTFIM)+ABB->ABB_HRFIM	
	Local cChave2:= ABB->ABB_YCONTA
	Local cData  := DTOS(ABB->ABB_DTINI)
	Local cNumOS := ABB->ABB_NUMOS
	Local dDTIni := ABB->ABB_DTINI
	Local cHrIni := ABB->ABB_HRINI
	Local dDTFim := ABB->ABB_DTFIM
	Local cHrFim := ABB->ABB_HRFIM
	Local cHrTot := ABB->ABB_HRTOT
	Local cOBS   := ABB->ABB_OBSERV
	Local cSacra := ABB->ABB_SACRA 
	Local cChegou:= ABB->ABB_CHEGOU
	Local dData  := ABB->ABB_DATA  
	Local cAtende:= ABB->ABB_ATENDE
	Local cConta := GetSX8Num("ABB","ABB_YCONTA")  
    
	//Banco
	Begin Transaction

	If nopc == 1
	
		//Grava contador para a serie
		Reclock("ABB",.F.)
			ABB->ABB_YCONTA := cConta
		ABB->(MsUnlock()) 
		
		//Confirmar contador 
		ConfirmSx8()
		
		ABB->(DbSetOrder(1))
		//ARQTRB->(DbGoTop())
		dbSelectArea(_cTRB1)
		dbGoTop()
		While ! (_cTRB1)->(EOF())
			If (_cTRB1)->MARCA == cMarca
				If ABB->(DbSeek(xFilial("ABB")+(_cTRB1)->TECNICO+cChave))   
	                If MsgYesNo("O tecnico : " + (_cTRB1)->TECNICO          ;
	                			+ " - "        + (_cTRB1)->NOME             + Chr(10) + Chr(13) ;
	                			+ "foi encontrado em outra agenda."       + Chr(10) + Chr(13) + Chr(10) + Chr(13) ;
	                			+ "OS: " + ABB->ABB_NUMOS                 + Chr(10) + Chr(13) ;
	                			+ "Data Inicial: " + DTOC(ABB->ABB_DTINI) + Chr(10) + Chr(13) ; 
	                			+ "Hora Inicial: " + ABB->ABB_HRINI       + Chr(10) + Chr(13) ; 
		               			+ "Data Final:   " + DTOC(ABB->ABB_DTINI) + Chr(10) + Chr(13) ; 
	                			+ "Hora Final:   " + ABB->ABB_HRINI       + Chr(10) + Chr(13) + Chr(10) + Chr(13) ; 
	                			+ " Confirma alteração ?",STR0001)
						
						RecLock("ABB",.F.)
				
							ABB->ABB_NUMOS  := cNumOS
							ABB->ABB_DTINI  := dDTIni
							ABB->ABB_HRINI  := cHrIni                          `
							ABB->ABB_DTFIM  := dDTFim
							ABB->ABB_HRFIM  := cHrFim
							ABB->ABB_HRTOT  := cHrTot
							ABB->ABB_OBSERV := cOBS  
							ABB->ABB_SACRA  := cSacra
							ABB->ABB_CHEGOU := cChegou
							ABB->ABB_DATA   := dData 
							ABB->ABB_ATENDE := cAtende
							ABB->ABB_YCONTA := cConta
						ABB->(MsUnlock())
					Endif	                     
	            
	/*/
				ElseIf ABB->(DbSeek(xFilial("ABB")+ARQTRB->TECNICO+cData))   
					MsgInfo("O tecnico " + ARQTRB->TECNICO + " - " + ARQTRB->NOME + " foi encontrado em outra agenda." +;
	                " Não será possível alterar esse tecnico!",STR0001)
	/*/
				Else					
					RecLock("ABB",.T.)
						
						ABB->ABB_FILIAL := xFilial("ABB")
						ABB->ABB_CODTEC := (_cTRB1)->TECNICO
						ABB->ABB_NOMTEC := (_cTRB1)->NOME
						ABB->ABB_NUMOS  := cNumOS
						ABB->ABB_DTINI  := dDTIni
						ABB->ABB_HRINI  := cHrIni                          `
						ABB->ABB_DTFIM  := dDTFim
						ABB->ABB_HRFIM  := cHrFim
						ABB->ABB_HRTOT  := cHrTot
						ABB->ABB_OBSERV := cOBS  
						ABB->ABB_SACRA  := cSacra
						ABB->ABB_CHEGOU := cChegou
						ABB->ABB_DATA   := dData 
						ABB->ABB_ATENDE := cAtende        
						ABB->ABB_YCONTA := cConta
					ABB->(MsUnlock())                     
				Endif
			Endif
			(_cTRB1)->(DbSkip())		
		Enddo

	ElseIf nOpc == 2
		ABB->(DbOrderNickName("CONTADOR"))
		(_cTRB1)->(DbGoTop())
		While ! (_cTRB1)->(EOF())
			If (_cTRB1)->MARCA == cMarca
				If ABB->(DbSeek(xFilial("ABB")+(_cTRB1)->TECNICO+cChave2))   
					Reclock("ABB",.F.)
						DbDelete()
					ABB->(MsUnlock())
				Endif
			Endif
			(_cTRB1)->(DbSkip())		
		Enddo
	Endif

	//Banco
	End Transaction
	
Return               

/*/
+----------+----------+-------+-----------------------+------+------------+
|Função    |fSTCA001  | Autor |Microsiga Vitória      | Data |09.10.2007  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Cria informações para a consulta                              |
+----------+--------------------------------------------------------------+
|Retorno   |                                                              |
+----------+--------------------------------------------------------------+
|Parâmetros|                                                              |
+----------+--------------------------------------------------------------+
|Uso       |Field Service -> Sirtec                                       |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+----------+--------------------------------------------------------------+
| Data     | Descrição                                                    |
+----------+--------------------------------------------------------------+
|          |                                                              |
+----------+--------------------------------------------------------------+
/*/

Static Function fSTCA001(nOpc)
	
	Local cEquipe := ABB_CODTEC 
	
	Local cSQL	:= ""			
	Local aTrab
	Local cZZ4 := RetSQLName("ZZ4") + " ZZ4 "
	Local cAA1 := RetSQLName("AA1") + " AA1 "
	Local cSRJ := RetSQLName("SRJ") + " SRJ "
	Local cABB := RetSQLName("ABB") + " ABB "

	Private _cTRB1	 := GetNextAlias() //Alias Tabela Temporária
	
	//Cria arquivo temporário   		    
	aAdd(aCampos,{"MARCA"     ,"C",02,0})
	aAdd(aCampos,{"EQUIPE"    ,"C",TamSX3("ZZ4_EQUIPE")[1],0})
	aAdd(aCampos,{"TECNICO"   ,"C",TamSX3("AA1_CODTEC")[1],0})
	aAdd(aCampos,{"NOME"      ,"C",TamSX3("AA1_NOMTEC")[1],0})
	aAdd(aCampos,{"FUNCAO"    ,"C",TamSX3("RJ_DESC")[1],0})
	
	
	/*If Select("ARQTRB")>1                     
		ARQTRB->(DbCloseArea())
	End If 
	ARQTRB := CriaTrab(aCampos,.T.)
	DbUseArea(.T.,,ARQTRB,"ARQTRB",.F.)*/

	//-------------------
	//Criação do objeto
	//-------------------
	If (Select(_cTRB1) > 0)
	    oTempTab1:Delete()
	EndIf
	oTempTab1 := FWTemporaryTable():New( _cTRB1, aCampos  )
	oTempTab1:AddIndex("01", {aCampos[1] + aCampos[2] + aCampos[3]} )	
	oTempTab1:Create()

	
	aAdd(aCpoBrw,{"MARCA"     ,,""})
	aAdd(aCpoBrw,{"EQUIPE"    ,,RetTitle("ZZ4_EQUIPE")})
	aAdd(aCpoBrw,{"TECNICO"   ,,RetTitle("AA1_CODTEC")})
	aAdd(aCpoBrw,{"NOME"      ,,RetTitle("AA1_NOMTEC")})
	aAdd(aCpoBrw,{"FUNCAO"    ,,RetTitle("AA1_FUNCAO")})

	If nOpc == 1
		cSQL:= " SELECT " 														
		cSQL+= " AA1_CODTEC "
		cSQL+= " ,AA1_NOMTEC " 
		cSQL+= " ,ZZ4_EQUIPE "
		cSQL+= " ,ZZ4_CODTEC "
		cSQL+= " ,RJ_DESC "
			
		cSQL+= " FROM " + cAA1 + " "
		
		cSQL+= " LEFT OUTER JOIN " + cZZ4 + " ON  "
		cSQL+= " AA1_CODTEC = ZZ4_CODTEC "
		cSQL+= " AND ZZ4.D_E_L_E_T_ = '' "
	
		cSQL+= " LEFT OUTER JOIN " + cSRJ + " ON "
		cSQL+= " RJ_FUNCAO = AA1_FUNCAO  "
		cSQL+= " AND SRJ.D_E_L_E_T_ = '' "
		
		cSQL+= " WHERE  "
		cSQL+= " AA1_YEQUIP <> 'S'   "
		cSQL+= " AND AA1.D_E_L_E_T_ = '' "
		
		cSQL+= " 	ORDER BY ZZ4_EQUIPE, ZZ4_CODTEC, AA1_CODTEC "

	Elseif nOpc == 2

		cSQL:= " SELECT "
		cSQL+= " AA1_CODTEC  "
		cSQL+= " ,AA1_NOMTEC   "
		cSQL+= " ,ZZ4_EQUIPE   "
		cSQL+= " ,ZZ4_CODTEC   "
		cSQL+= " ,RJ_DESC  "

		cSQL+= " FROM " + cABB + " "

		cSQL+= " INNER JOIN " + cAA1 + " ON "
		cSQL+= " AA1_CODTEC = ABB_CODTEC "
		cSQL+= " AND AA1_YEQUIP <> 'S' "
		cSQL+= " AND AA1.D_E_L_E_T_ = '' "

		cSQL+= " LEFT OUTER JOIN " + cZZ4 + " ON  "
		cSQL+= " ZZ4_CODTEC = ABB_CODTEC "
		cSQL+= " AND ZZ4.D_E_L_E_T_ = '' "

		cSQL+= " LEFT OUTER JOIN " + cSRJ + " ON "
		cSQL+= " RJ_FUNCAO = AA1_FUNCAO "
		cSQL+= " AND SRJ.D_E_L_E_T_ = '' "

		cSQL+= " WHERE  "
		cSQL+= "      ABB_YCONTA = '" + ABB->ABB_YCONTA + "' "
		
		/*/
		cSQL+= "      ABB_NUMOS = '" + ABB->ABB_NUMOS + "' "
		cSQL+= "  AND ABB_DTINI = '" + DTOS(ABB->ABB_DTINI) + "' "
		cSQL+= "  AND ABB_DTFIM = '" + DTOS(ABB->ABB_DTFIM) + "' "
		cSQL+= "  AND ABB_HRINI = '" + ABB->ABB_HRINI + "' "
		cSQL+= "  AND ABB_HRFIM = '" + ABB->ABB_HRFIM + "' "
        /*/
		
		cSQL+= " ORDER BY ZZ4_EQUIPE, ZZ4_CODTEC, AA1_CODTEC  "
	Endif
	
	
	Memowrite('\STCA019-1.txt',cSQL)
	If Select("_ZZ4")>1                     
		_ZZ4->(DbCloseArea())
	End If 
	
	TcQuery cSQL New Alias "_ZZ4"
	 
	If !Select("_ZZ4")>1	
		Alert(STR0004)
	 	Return
	End If
	
	//Controle da posição que o acols será exibido
	nTemp := 0 	

	_ZZ4->(DbGoTop())
	While !_ZZ4->(Eof())

		//Reclock("ARQTRB",.T.)
		(_cTRB1)->(DBAppend())
	
			If nOpc == 1
				(_cTRB1)->MARCA := Iif(_ZZ4->ZZ4_EQUIPE <> cEquipe,"",cMarca)
			ElseIf nOpc == 2
				(_cTRB1)->MARCA := ""
			Endif
			(_cTRB1)->EQUIPE	 := _ZZ4->ZZ4_EQUIPE
			(_cTRB1)->TECNICO    := _ZZ4->AA1_CODTEC
			(_cTRB1)->NOME       := _ZZ4->AA1_NOMTEC
			(_cTRB1)->FUNCAO     := _ZZ4->RJ_DESC 

		(_cTRB1)->(DBCommit())
		//MsUnlock()                                                       

		//Controle da posição que o acols será exibido	
		If (_cTRB1)->MARCA == cMarca .and. nTemp == 0
			nTemp := Recno()
		Endif
 
   		_ZZ4->(Dbskip())
	EndDo

	//Controle da posição que o acols será exibido
	//DbSelectArea("ARQTRB")
	dbSelectArea(_cTRB1)
	dbGoTop()
	If nOpc == 1
		DbGoto(nTemp) 
	ElseIf nOpc == 2
		DbGoTop()
	Endif
Return                                 

/*/
+----------+----------+-------+-----------------------+------+------------+
|Função    |fSTCA002  | Autor |Microsiga Vitória      | Data |09.10.2007  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Atualiza campo de controle (marca)                            |
+----------+--------------------------------------------------------------+
|Retorno   |                                                              |
+----------+--------------------------------------------------------------+
|Parâmetros|                                                              |
+----------+--------------------------------------------------------------+
|Uso       |Field Service -> Sirtec                                       |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+----------+--------------------------------------------------------------+
| Data     | Descrição                                                    |
+----------+--------------------------------------------------------------+
|          |                                                              |
+----------+--------------------------------------------------------------+
/*/
Static Function fSTCA0002
	
	Local nSay4 := 0
	Local aArea := {}
	
	RecLock(_cTRB1,.F.)
		(_cTRB1)->MARCA := Iif((_cTRB1)->MARCA!=cMarca,cMarca,"")
	MsUnlock()
	
	oGet01:oBrowse:Refresh()
Return

/*/
+----------+----------+-------+-----------------------+------+------------+
|Função    |fSTCA003  | Autor |Microsiga Vitória      | Data |09.10.2007  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Apaga relacionamento quando nOpc == 3                         |
+----------+--------------------------------------------------------------+
|Retorno   |                                                              |
+----------+--------------------------------------------------------------+
|Parâmetros|                                                              |
+----------+--------------------------------------------------------------+
|Uso       |Field Service -> Sirtec                                       |
+----------+--------------------------------------------------------------+
| Atualizacoes sofridas desde a Construcao Inicial.                       |
+----------+--------------------------------------------------------------+
| Data     | Descrição                                                    |
+----------+--------------------------------------------------------------+
|          |                                                              |
+----------+--------------------------------------------------------------+
/*/
Static Function fSTCA0003

	If ZZ5->(DbSeek(xFilial("ZZ5")+M->AB9_NUMOS))
		While !ZZ5->(EOF()) .and. ZZ5->ZZ5_NUMOS ==	M->AB9_NUMOS
			Reclock("ZZ5",.F.)
				DbDelete()
			ZZ5->(MsUnlock())
			ZZ5->(DbSkip())
		Enddo
	Else
		MsgInfo(STR0005,STR0001)
	Endif

Return
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa   ³   C()   ³ Autores ³ Norbert/Ernani/Mansano ³ Data ³10/05/2005³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao  ³ Funcao responsavel por manter o Layout independente da       ³±±
±±³           ³ resolucao horizontal do Monitor do Usuario.                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function C(nTam)                                                         
	
	Local nHRes	:=	oMainWnd:nClientWidth	// Resolucao horizontal do monitor     
	
	If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)  
		nTam *= 0.8                                                                
	ElseIf (nHRes == 798).Or.(nHRes == 800)	// Resolucao 800x600                
		nTam *= 1                                                                  
	Else	// Resolucao 1024x768 e acima                                           
		nTam *= 1.28                                                               
	EndIf                                                                         
                                                                                
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿                                               
	//³Tratamento para tema "Flat"³                                               
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ                                               
	If "MP8" $ oApp:cVersion                                                      
		If (Alltrim(GetTheme()) == "FLAT") .Or. SetMdiChild()                      
			nTam *= 0.90                                                            
		EndIf                                                                      
	EndIf                                                                         
Return Int(nTam)