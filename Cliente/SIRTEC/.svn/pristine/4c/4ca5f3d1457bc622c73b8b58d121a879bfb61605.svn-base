#Include "folder.ch"
#Include "font.ch"
#Include "colors.ch"
#Include "rwmake.ch"
#Include "protheus.ch"
#Include "topconn.ch"

#define STR0001 'Sirtec - STCA014'
#define STR0002 'Sirtec - Relaciona OS x Tecnicos'
#define STR0003 'Criando relacionamento de técnicos...'
#define STR0004 'Consulta sem registros...' 
#define STR0005 'Não foram encontrados relacionamentos a serem apagados!'

/*/
+----------+----------+-------+-----------------------+------+------------+
|Função    |STCA014   | Autor |Microsiga Vitória      | Data |09.10.2007  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Atualização do relacionamento OS x Tecnicos                   |
+----------+--------------------------------------------------------------+
|Retorno   |                                                              |
+----------+--------------------------------------------------------------+
|Parâmetros|nOpc -> opção acessada (incluir/alterar/excluir)              |
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

User Function STCA014(nOpc) 
	
	//Variaveis de controle da rotina
	Private aCampos := {}
	Private aCpoBrw := {}
	Private cMarca  := GetMark()
	Private cNumOS  := M->AB9_NUMOS
	Private cEquipe := M->AB9_CODTEC
	Private cNomeEq := Posicione("AA1",1,xFilial("AA1")+M->AB9_CODTEC,"AA1_NOMTEC")
	Private _nIndex := 0
	
	//Variaveis de controle dos objetos
	Private oDlgSTC				//Dialog
	Private oBrowse
	Private oFont					//Fonte utilizada
	Private oGet01					//Getdados
	Private oTCab1					//Titulo no Cabeçalho
	Private oICab1					//Informação no Cabeçalho
	Private oTCab2					//Titulo no Cabeçalho
	Private oICab2					//Informação no Cabeçalho
	Private oTCab3
	Private oTCab4
	Private oCbx   
	Private _nCbx   := "0"//variável que guarda o indice do item
	Private _aItens := {"0=Equipe", "1=Nome", "2=Tecnico"}
	Private oTGet1
	Private _cTGet1 := Space(100) 
	Private oTButton1
	Private _nCont  := 0
	////////////////////
	//Montagem da tela//
	////////////////////

	//Processamento da tela. Verifica se é inclusão ou alteração
	MsAguarde({|| Iif(nOpc == 3,fSTCA0003(nOpc),fSTCA001(nOpc))},STR0001,STR0002)  
	
	//Caso seja exclusão, não apresenta a tela
	If nOpc == 3
		Return
	Endif
	
	//VERIFICA SE  A CONSULTA RETORNOU ALGUM ITEM
	If !Select("_ZZ4")>1	
	 	Alert(STR0004)
		Return
	End If
	
	//Definição da Fonte
	oFont  := tFont():new(,,-11,,.T.)
	
	DEFINE MSDIALOG oDlgSTC TITLE STR0002 FROM C(200),C(200) TO C(500),C(700) PIXEL

	// Cria as Groups do Sistema
	@ C(012),C(008) TO C(040),C(245) LABEL "Informações da OS: " PIXEL OF oDlgSTC
	
	//Informações do cabeçalho
	oTCab1 := tSay():New(025,015,{||"Numero OS: "},oDlgSTC,,,,,,.T.,,,270,20) 
	oICab1 := tSay():New(025,050,{||cNumOS}       ,oDlgSTC,,oFont,,,,.T.,CLR_RED,CLR_RED,270,20)
	
	oTCab2 := tSay():New(037,015,{||"Equipe: "}   ,oDlgSTC,,,,,,.T.,,,270,20) 
	oICab2 := tSay():New(037,050,{||cEquipe}      ,oDlgSTC,,oFont,,,,.T.,CLR_RED,CLR_RED,270,20)

	oTCab3 := tSay():New(037,085,{||"Nome: "}     ,oDlgSTC,,,,,,.T.,,,270,20) 
	oICab3 := tSay():New(037,120,{||cNomeEq}      ,oDlgSTC,,oFont,,,,.T.,CLR_RED,CLR_RED,270,20)

  
  
  	@ C(043),C(008) TO C(071),C(245) LABEL "Pesquisa....: " OF oDlgSTC PIXEL  
	
	//ComboBox com as opções de Busca por Matrícula ou Nome do Técnico		
	@64,12 COMBOBOX oCbx VAR _nCbx ITEMS _aItens SIZE 115,12 PIXEL OF oDlgSTC ON CHANGE _changeBox()   
	// Campo com a chave de busca
	oTGet1 := TGet():New(076,12,{|u|if(Pcount()>0,_cTGet1:=u,_cTGet1)},oDlgSTC,115,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"_cTGet1",,,, )
	// botão de pesquisa
	oTButton1 := TButton():New( 063, 130, "Buscar",oDlgSTC,{|| _buscTec()},40,12,,,.F.,.T.,.F.,,.F.,,,.F. )
	
	
	
	//Inclusao dos GetDados	
	oGet01 := MsSelect():New("ARQTRB","MARCA","",aCpoBrw,.F.,cMarca,{C(074),C(008),C(140),C(245)})
	oGet01:bAval := {|| fSTCA0002()}
	
	ACTIVATE MSDIALOG oDlgSTC On Init (EnchoiceBar(oDlgSTC,{||Processa({||U_STCA014A(nOpc)},STR0001,STR0003);
	,oDlgSTC:End()},{|| oDlgSTC:End()},,/*aButtons*/)) CENTERED

Return


/*/
+----------+----------+-------+-----------------------+------+------------+
|Função    |STCA014A  | Autor |Microsiga Vitória      | Data |09.10.2007  |
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

User Function STCA014A(nOpc)
	
	Local cGrPPR := ""
	
	//Banco
	Begin Transaction
	
	//caso seja alteracao
	If nOpc == 2
		ZZ5->(DbSetOrder(1))
		If ZZ5->(DbSeek(xFilial("ZZ5")+M->AB9_NUMOS+M->AB9_CODTEC+M->AB9_SEQ))
			While !ZZ5->(EOF()) .and. ZZ5->ZZ5_NUMOS+ZZ5->ZZ5_EQUIPE+ZZ5->ZZ5_SEQ ==	M->AB9_NUMOS+M->AB9_CODTEC+M->AB9_SEQ
				Reclock("ZZ5",.F.)
					DbDelete()
				ZZ5->(MsUnlock())
				ZZ5->(DbSkip())
			Enddo
		Endif
	Endif
	
	ARQTRB->(DbGoTop())
	
	While ! ARQTRB->(EOF())
		If ARQTRB->MARCA == cMarca
			ZZ5->(DbSetOrder(2))
			If !ZZ5->(DbSeek(xFilial("ZZ5")+ARQTRB->TECNICO+M->AB9_NUMOS+M->AB9_SEQ+M->AB9_CODTEC))  
				
				cGrPPR := _GetZZ4(M->AB9_CODTEC)
				
				RecLock("ZZ5",.T.)
					ZZ5->ZZ5_FILIAL	:= xFilial("ZZ5")
					ZZ5->ZZ5_NUMOS 	:= M->AB9_NUMOS
					ZZ5->ZZ5_EQUIPE	:= M->AB9_CODTEC
					ZZ5->ZZ5_SEQ   	:= M->AB9_SEQ
					ZZ5->ZZ5_DTCHEG := M->AB9_DTCHEG
					ZZ5->ZZ5_CODTEC	:= ARQTRB->TECNICO
					ZZ5->ZZ5_ENCARR	:= IIF(ARQTRB->ENCARE == '2', 'S', ' ') // Adicionado por Felipe S. Raota - Projeto PPR - 24/04/13
					ZZ5->ZZ5_CODGRP	:= cGrPPR //ARQTRB->GRPPR // Adicionado por Felipe S. Raota - Projeto PPR - 01/07/13
				ZZ5->(MsUnlock())
			Endif
		Endif
		ARQTRB->(DbSkip())
	Enddo
	
	//Banco
	End Transaction

	
Return               

/*/
+----------+----------+-------+-----------------------+------+------------+
|Função    |fSTCA001  | Autor |Microsiga Vitória      | Data |09.10.2007  |
+----------+----------+-------+-----------------------+------+------------+
|Descrição |Cria informações para a consulta                              |
+----------+--------------------------------------------------------------+
`|Retorno   |                                                              |
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
	
	Local cEquipe := M->AB9_CODTEC   
	
	Local cSQL	:= ""			
	Local aTrab
	Local cZZ4 := RetSQLName("ZZ4") + " ZZ4 " 
	Local cAA1 := RetSQLName("AA1") + " AA1 "
	Local cSRJ := RetSQLName("SRJ") + " SRJ " 
	
	Local cGrpPPR := ""

	Private _cTRB1	 := GetNextAlias() //Alias Tabela Temporária
	
	//Cria arquivo temporário    		    
	aAdd(aCampos,{"MARCA"     ,"C",02,0})
	aAdd(aCampos,{"EQUIPE"    ,"C",TamSX3("ZZ4_EQUIPE")[1],0})
	aAdd(aCampos,{"TECNICO"   ,"C",TamSX3("AA1_CODTEC")[1],0})
	aAdd(aCampos,{"NOME"      ,"C",TamSX3("AA1_NOMTEC")[1],0}) 
	aAdd(aCampos,{"FUNCAO"    ,"C",TamSX3("RJ_DESC")[1],0})  
	aAdd(aCampos,{"ENCARE"    ,"C",TamSX3("ZZ4_ENCARE")[1],0}) // Adicionado por Felipe S. Raota - Projeto PPR - 24/04/13
	aAdd(aCampos,{"GRPPR"     ,"C",TamSX3("ZZ5_CODGRP")[1],0}) // Adicionado por Felipe S. Raota - Projeto PPR - 01/07/13
	
	
	/*If Select("ARQTRB")>1                     
		ARQTRB->(DbCloseArea())
	End If 
		ARQTRB := CriaTrab(aCampos,.T.)
	DbUseArea(.T.,,ARQTRB,"ARQTRB",.F.) */
	
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
	
	cSQL:= " SELECT " 														
	cSQL+= " AA1_CODTEC "
	cSQL+= " ,AA1_NOMTEC " 
	cSQL+= " ,ZZ4_EQUIPE "
	cSQL+= " ,ZZ4_CODTEC "
	cSQL+= " ,RJ_DESC, ZZ4_ENCARE, ZZ4_GRPPR " // Adicionado por Felipe S. Raota - Projeto PPR - 24/04/13
	
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
	
	//Memowrite('\STCA013-1.txt',cSQL)
	
	Memowrite('C:\temp\STCA013.txt',cSQL)
	
	If Select("_ZZ4")>1                     
		_ZZ4->(DbCloseArea())
	EndIf 
	
	TcQuery cSQL New Alias "_ZZ4"
	
	If !Select("_ZZ4")>1	
		//Alert(STR0004)
	 	Return
	End If
	
	//Controle da posição que o acols será exibido 
	nTemp := 0 	

	_ZZ4->(DbGoTop())
	While !_ZZ4->(Eof())
		
		//Reclock("ARQTRB",.T.)
		(_cTRB1)->(DBAppend())
			
			If nOpc == 1 //inclusão
				(_cTRB1)->MARCA := Iif(_ZZ4->ZZ4_EQUIPE <> cEquipe,"",cMarca)
			
			Elseif nOpc == 2 // alteração
				ZZ5->(DbSetOrder(1))
				If ZZ5->(DbSeek(xFilial("ZZ5")+M->AB9_NUMOS+M->AB9_CODTEC+M->AB9_SEQ+_ZZ4->AA1_CODTEC))
			
					//marca os registros já gravados no relacionamento
					(_cTRB1)->MARCA := cMarca
				Endif
			Endif
			
			(_cTRB1)->EQUIPE	 := _ZZ4->ZZ4_EQUIPE
			(_cTRB1)->TECNICO    := _ZZ4->AA1_CODTEC
			(_cTRB1)->NOME       := _ZZ4->AA1_NOMTEC
			(_cTRB1)->FUNCAO     := _ZZ4->RJ_DESC
			(_cTRB1)->ENCARE     := _ZZ4->ZZ4_ENCARE // Adicionado por Felipe S. Raota - Projeto PPR - 24/04/13
			(_cTRB1)->GRPPR  	 := _ZZ4->ZZ4_GRPPR // Adicionado por Felipe S. Raota - Projeto PPR - 01/07/13

			(_cTRB1)->(DBCommit())

		//MsUnlock()                                                       
		
		
		//Controle da posição que o acols será exibido	
		If (_cTRB1)->MARCA == cMarca .and. nTemp == 0
			nTemp := Recno()
		Endif
 		
   		_ZZ4->(Dbskip())
	EndDo
	
	//U_ShowTRB("ARQTRB")
	//ARQTRB->(dbGoTop())
	
	//Controle da posição que o acols será exibido
	DbSelectArea(_cTRB1)
	DbGoto(nTemp)

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
	
	RecLock((_cTRB1),.F.)
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
    
	ZZ5->(DbSetOrder(1))
	If ZZ5->(DbSeek(xFilial("ZZ5")+M->AB9_NUMOS+M->AB9_CODTEC+M->AB9_SEQ))
		//Banco
		Begin Transaction
	
			While !ZZ5->(EOF()) .and. ZZ5->ZZ5_NUMOS+ZZ5->ZZ5_EQUIPE+ZZ5->ZZ5_SEQ ==	M->AB9_NUMOS+M->AB9_CODTEC+M->AB9_SEQ
				Reclock("ZZ5",.F.)
					DbDelete()
				ZZ5->(MsUnlock())
				ZZ5->(DbSkip())
			Enddo
		//Banco
		End Transaction
		
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



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _buscTec ³ Autor ³ Everson da C. Almeida        Data ³ 29/03/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Busca o tecnico informado no campo chave                          ³±±
±±³          ³                                                                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ |STCA014                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function _buscTec()

Local _lFlag := .F.

If Alltrim(_nCbx) == '1'
	                       
	                       
	If (_cTRB1)->(!BoF())
		(_cTRB1)->(dbSkip())
	Endif
	
	While .T.
   
		If Alltrim(_cTGet1) $ Alltrim((_cTRB1)->NOME)  
			Exit
   	EndIf
   	
   	If (_cTRB1)->(EoF())
   		If !_lFlag
   			_lFlag := .T.
   			(_cTRB1)->(dbGoTop())
   			oGet01:oBrowse:Refresh()
   		Else
   			EXIT
   		Endif
   	Endif 
   	
   	//If !_lFlag
			(_cTRB1)->(dbSkip())
	   //EndIf
	   
	Enddo

Else
	If AllTrim(_nCbx) == '2' 
	
		If (_cTRB1)->(!BoF())
			(_cTRB1)->(dbSkip())
		Endif
	
  		While .T.//ARQTRB->(!EoF())
   
			If Alltrim(_cTGet1) $ Alltrim((_cTRB1)->TECNICO)  
		  		Exit
   	
     		EndIf 
   	
   	
   		If (_cTRB1)->(EoF())
   			If !_lFlag
   		  		_lFlag := .T.
   		  		(_cTRB1)->(dbGoTop())
   				oGet01:oBrowse:Refresh()
   	  		Else
   				EXIT
   			Endif
     		Endif

	  		//If !_lFlag
				(_cTRB1)->(dbSkip())
	   	//EndIf	
	   	              	
		Enddo
   
   Else
		If (_cTRB1)->(!BoF())
			(_cTRB1)->(dbSkip())
		Endif
	
  		While .T.//ARQTRB->(!EoF())
   
			If Alltrim(_cTGet1) $ Alltrim((_cTRB1)->EQUIPE)  
		  		Exit   	
     		EndIf    	
   	
   		If ARQTRB->(EoF())
   			If !_lFlag
   		  		_lFlag := .T.
   		  		(_cTRB1)->(dbGoTop())
   				oGet01:oBrowse:Refresh()
   	  		Else
   				EXIT
   			Endif
     		Endif

	  		//If !_lFlag
				(_cTRB1)->(dbSkip())
	   	//EndIf	
              	
		Enddo   
   Endif
EndIf


oGet01:oBrowse:Refresh()

Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _changeBox ³ Autor ³ Everson da C. Almeida        Data ³ 29/03/12 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Busca o tecnico informado no campo chave                          ³±±
±±³          ³                                                                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ |STCA014                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function _changeBox()
      
	cIndTRB := GetNextAlias() //Alias Tabela Temporária //CriaTrab(Nil, .F.)
	
	If Alltrim(_nCbx) == '1' 
		IndRegua(_cTRB1,cIndTRB,"NOME")		
	Else
		If Alltrim(_nCbx) == '2'
	  		IndRegua(_cTRB1,cIndTRB,"TECNICO")
	 	Else
	 		IndRegua(_cTRB1,cIndTRB,"EQUIPE + TECNICO + NOME")
	   EndIf		
	Endif
		
	dbClearIndex()
	dbSetIndex(cIndTRB + OrdBagExt())
	
   oGet01:oBrowse:Refresh()
   
Return

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Função    ³ _GetZZ4    ³ Autor ³ Felipe S. Raota              Data ³ 19/02/14 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descrição ³ Busca o Grupo PPR pela Equipe na tabela ZZ4.                      ³±±
±±³          ³                                                                   ³±±
±±³          ³                                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ |STCA014                                                          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function _GetZZ4(cEqp)

Local aArea := GetArea()
Local cGrp := ""

dbSelectArea("ZZ4")
ZZ4->(dbSetOrder(1))

If ZZ4->(MsSeek( xFilial("ZZ4") + cEqp ))
	cGrp := ZZ4->ZZ4_GRPPR
Endif

restArea(aArea)

Return cGrp
