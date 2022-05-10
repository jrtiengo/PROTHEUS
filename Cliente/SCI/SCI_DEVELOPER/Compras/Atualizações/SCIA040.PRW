#Include "Totvs.ch"
#Include "fileio.Ch"
#Include "TbiConn.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SCIA040  ³ Autor ³ Denis Rodrigues     ³ Data ³ 16/10/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Browse que configura permissao de acesso do cliente ao     ³±±
±±³          ³ Portal do Licenciado                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_SCIA040()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente S.C Internacional                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
User Function SCIA040()

	A0405BROW("SA1")//Passa o alias do cliente

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SCIA050  ³ Autor ³ Denis Rodrigues     ³ Data ³ 16/10/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Browse que configura a permissao de acesso do fornecedor ao³±±
±±³          ³ Portal do Licenciado                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_SCIA050()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente S.C Internacional                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/ 
User Function SCIA050()

	A0405BROW("SA2")// Passa o alias do fornecedor

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A0405BRW  ³ Autor ³ Denis Rodrigues    ³ Data ³  16/10/2014³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Monta o Browse do cliente ou do Fornecedor                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente  S.C Internacional                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A0405BROW( cTable )

	Private cCadastro := "Acessos ao Portal do Licenciado"
	Private aRotina   := MenuDef()//O MenuDef serve para exibir a rotina na tela maior do Protheus
	Private aCores    := {}
	
	If cTable = "SA1"
					
		 aAdd( aCores,{ '(SA1->A1_ACPORT = "N")' ,'BR_VERMELHO' })
		 aAdd( aCores,{ '(SA1->A1_ACPORT = "S")' ,'BR_VERDE'    })
		 aAdd( aCores,{ '(SA1->A1_ACPORT = " ")' ,'BR_PRETO'    })
	
	Else
	
		 aAdd( aCores,{ '(SA2->A2_ACPORT = "N")' ,'BR_VERMELHO' })
		 aAdd( aCores,{ '(SA2->A2_ACPORT = "S")' ,'BR_VERDE'    })
		 aAdd( aCores,{ '(SA2->A2_ACPORT = " ")' ,'BR_PRETO'    })
		 
	EndIf

	dbSelectArea( cTable )
	mBrowse( 6,1,22,75,cTable,,,,,,aCores )

Return

/*
+---------------+
|Menu do mBrowse|
+---------------+*/
Static Function MenuDef()

	Local aRotina := {}
	
	aAdd(aRotina,{ "Pesquisar" ,"AxPesqui"	 	, 0, 1})
	aAdd(aRotina,{ "Visualizar","AxVisual"	 	, 0, 2})
	aAdd(aRotina,{ "Liberar"  	,"U_A040PROC" 	, 0, 6})
	aAdd(aRotina,{ "Bloquear"  ,"U_A040PROC" 	, 0, 7})
	aAdd(aRotina,{ "Legenda"   ,"U_A045LG()"  , 0, 8})

Return( aRotina )

/*
+------------------+
|Legenda do mBRowse|
+------------------+*/
User Function A045LG()

	BrwLegenda( cCadastro,"Legenda",{{"BR_VERDE" 	,"Acesso Liberado"},;
										      {"BR_VERMELHO"	,"Acesso Bloqueado"},;
                                    {"BR_PRETO" 	,"Acesso Não definido"}} )

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A040PROC ³ Autor ³ Denis Rodrigues     ³ Data ³ 16/10/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Libera/Desabilita o acesso do CLIENTE no Portal            ³±±
±±³Descricao ³ do Licenciado                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ U_A040PROC( cExp1,cExp2,cExp3,cExp4 )                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 - Tabela posicionada                                 ³±±
±±³          ³ cExp2 - Numero Recno posicionado                           ³±±
±±³          ³ cExp3 - Indica a operacao que esta sendo executada         ³±±
±±³          ³ cExp4 - Indica se a rotina foi chamada pelo WebService     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente S.C Internacional                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
User Function A040PROC( cTable, nRecno, nOpc, cWebServ  )

	Local lOK    := .T.
	Local cMsg   := ""
	Local cChave := ""
	Local aRet   := {}

	If nOpc = 3 // Clicou no botao para LIBERAR O ACESSO
	
		If cTable = "SA1"// Se estiver posicionado na tabela de CLIENTE
		
			If Empty( cWebServ )// Se vazio e por que foi chamado pelo mBrowse

				// Valida se o usuario esta bloqueado no cadastro
				If SA1->A1_MSBLQL <> "2"
				
					lOK := .F.
					cMsg += "- Não é possível realizar a liberação, pois o Licenciado se encontra bloqueado no sistema."
					cMsg += " Altere o cadastro e tente novamente."+CRLF
					
				EndIf
			
				// Verifica se o cliente esta habilitado
				If SA1->A1_ACPORT = "S"
				
					If !MSGYESNO( "Licenciado já possui senha, deseja reenvia-la novamente?","Liberar acesso" )
						lOK := .F.
					EndIf
		
				EndIf
			
				// Verifica se o campo E-mail foi preenchido
				If Empty( SA1->A1_EMAIL )
					
					lOK := .F.
					cMsg += "- O E-mail do Licenciado não foi encontrado."
					cMsg += " Preencha o campo de E-mail no cadastro e tente liberar o acesso novamente."+CRLF
				
				EndIf
				
				cChave := A040GeraID(8)
				cChave := Embaralha( cChave,1 ) //  1 - embaralha 0 -desembaralha
					
				If lOK
				
					//Grava a nova chave
					RecLock( cTable, .F.)
						SA1->A1_CHVPORT := cChave
						SA1->A1_ACPORT  := "S"
					MsUnLock()
					
					//Enviar e-mail
					aRet := A040GeraEmail( cTable,0,"" )
					
					If aRet[1]
					
						cMsg := "Licenciado liberado."+CRLF
						cMsg += "E-mail enviado com sucesso. "+CRLF
						Aviso("Portal Licenciado", cMsg+aRet[2], {"OK"}, 1)
						
					Else
						
						cMsg := "Liberação do Licenciado OK, porém as tarefas abaixo não foram concluídas: "+CRLF
						Aviso("Portal Licenciado", cMsg+aRet[2], {"OK"}, 3)
						
					EndIf
					
				Else
				
					If !Empty( cMsg )
						Aviso("Liberação Portal Licenciado", cMsg, {"OK"}, 3)
					EndIf
					
				EndIf							
			
			Else// Se for chamado pelo WEBSERVICE
			
				cChave := A040GeraID(8)
				cChave := Embaralha( cChave,1 ) //  1 - embaralha 0 -desembaralha
				
				//Grava a nova chave
				dbSelectArea("SA1")
				SA1->( dbGoTo( nRecno ) )
				RecLock( cTable, .F.)
					SA1->A1_CHVPORT := cChave
					SA1->A1_ACPORT  := "S"
				MsUnLock()
					
				//Enviar e-mail
				aRet := A040GeraEmail( cTable,nRecno,"WS" )
			
			EndIf
	 	
	   Else// Se estiver posicionado na tabela de FORNECEDORES
	   
	   	If Empty( cWebServ )// Se vazio e por que foi chamado pelo mBrowse

				// Valida se o usuario esta bloqueado no cadastro
				If SA2->A2_MSBLQL <> "2"
				
					lOK := .F.
					cMsg += "- Não é possível realizar a liberação, pois o Fornecedor se encontra bloqueado no sistema."
					cMsg += " Altere o cadastro e tente novamente."+CRLF
					
				EndIf
				
				// Verifica se o cliente esta habilitado
				If SA2->A2_ACPORT = "S"
										
					If !MSGYESNO( "Fornecedor já possui senha, deseja reenvia-la novamente?","Liberar acesso" )
						lOK := .F.
					EndIf
									
				EndIf
				
				// Verifica se o campo E-mail foi preenchido
				If Empty( SA2->A2_EMAIL )
					
					lOK := .F.
					cMsg += "- O E-mail do Fornecedor não foi encontrado."+CRLF
					cMsg += " Preencha o campo de E-mail no cadastro e tente liberar o acesso novamente."+CRLF
				
				EndIf
	
				cChave := A040GeraID(6)
				cChave := Embaralha(cChave,1) //  1 - embaralha 0 -desembaralha
			
				If lOK
				
					//Grava a nova chave
					RecLock( cTable, .F.)
						SA2->A2_CHVPORT := cChave
						SA2->A2_ACPORT  := "S"
					MsUnLock()
					
					//Enviar e-mail
					aRet := A040GeraEmail( cTable,0,"" )
					
					If aRet[1]
					
						cMsg := "Licenciado liberado."+CRLF
						cMsg += "E-mail enviado com sucesso. "+CRLF
						Aviso("Portal Licenciado", cMsg+aRet[2], {"OK"}, 1)
						
					Else
						
						cMsg := "Liberação do Fornecedor OK, porém as tarefas abaixo não foram concluídas: "+CRLF
						Aviso("Portal Licenciado", cMsg+aRet[2], {"OK"}, 3)
						
					EndIf
					
				Else
				
					If !Empty( cMsg )
						Aviso("Liberação Portal Licenciado", cMsg, {"OK"}, 3)
					EndIf
					
				EndIf
				
			Else// Foi chamado pelo WEB SERVICES
			
				cChave := A040GeraID(6)
				cChave := Embaralha(cChave,1) //  1 - embaralha 0 -desembaralha
				
				//Grava a nova chave
				dbSelectArea("SA2")
				SA2->( dbGoTop( nRecno ) )
				RecLock( cTable, .F.)
					SA2->A2_CHVPORT := cChave
					SA2->A2_ACPORT  := "S"
				MsUnLock()
				
				//Enviar e-mail
				aRet := A040GeraEmail( cTable,nRecno,"WS" )				
			
			EndIf
			
	   EndIf

	Else// Se Clicou no botao para bloquear o acesso
	
		If cTable = "SA1"// Se estiver posicionado na tabela de CLIENTE
		
			If SA1->A1_ACPORT <> "N"
						
				RecLock( cTable, .F.)
					SA1->A1_ACPORT  := "N"
					SA1->A1_CHVPORT := ""
				MsUnLock()
				Aviso("Bloqueio Portal Licenciado", "Cliente bloqueado" , {"OK"}, 1)
				
			Else
				Aviso("Bloqueio Portal Licenciado", "Cliente já esta bloqueado" , {"OK"}, 1)
			EndIf
		
		Else// Se estiver posicionado na tabela de FORNECEDORES
		
			If SA2->A2_ACPORT <> "N"
				
				RecLock( cTable, .F.)
					SA2->A2_ACPORT  := "N"
					SA2->A2_CHVPORT := ""
				MsUnLock()
				Aviso("Bloqueio Portal Licenciado", "Fornecedor bloqueado", {"OK"}, 1)
				
			Else
				Aviso("Bloqueio Portal Licenciado", "Fornecedor já esta bloqueado", {"OK"}, 1)
			EndIf		
		
		EndIf
	
	EndIf
   
Return( aRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ A040GeraID ³ Autor ³ Jeferson Dambros  ³ Data ³ 16/10/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ gera uma senha aleatoria                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040GeraID( nExp )                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ nExp - Tamanho da chave que deve ser gerado                ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente S.C Internacional                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A040GeraID( nTam )

	Local aArea		:= GetArea()
	Local cString	:= ""
	Local cId		:= ""
	Local nVez		:= 0
	Local nPos		:= 0
	Local nTamStr	:= 0
	Local lOk		:= .T.
	
	If ValType(nTam) != "N"
		lOk := .F.
	Else
		
		If nTam < 0
			nTam := 0
		EndIf
		
	EndIf
	
	If lOk
		
		cString := "Aa0Bb1Cc2Dd3Ee4Ff5Gg6Hh7Ii8Jj9Kk0LlMmNnOoPpQqRrSsTtUuVvWwXxYyZz"
		
		nTamStr := Len(cString)
		
		For nVez := 1 To nTam
	
			nPos := Randomize(1,nTamStr)
	
			cId += SubStr(cString, nPos, 1)
			
		Next nVez
		
	EndIf
	
	RestArea(aArea)

Return( cId )


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao  ³ A070GeraEmail ³ Autor ³ Jeferson Dambros ³ Data ³ 16/10/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera o arquivo HTML e  envia o e-mail com a liberacao      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040GeraEmail( cExp1,nExp1,cExp2 )                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 - Tabela posicionada                                 ³±±
±±³          ³ nExp1 - Numero do Recno Posicionado                        ³±±
±±³          ³ cExp2 - Informa se esta sendo chamado do WebServices       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente S.C Internacional                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A040GeraEmail( cTable,nNumRecno,cWebServ )

	Local cHtml     := ""
	Local cArqMod   := ""
	Local cError    := ""
	Local aConteudo := {}
	Local aRet      := {}
	Local lOK       := .F.
	
	If cTable = "SA1"// Posicionado no CLIENTE

		If cWebServ = "WS"// Se a funcao for chamada pelo Web Services
		
			dbSelectArea("SA1")
			SA1->( dbGoTo( nNumRecno) )	
			cCliForn      := SA1->A1_COD
			cCnpj         := Transform(SA1->A1_CGC,"@r 99.999.999/9999-99")
			cContato      := SA1->A1_CONTATO
			cNomCliFor	  := SA1->A1_NOME
			cNReduz       := SA1->A1_NREDUZ
			cEmail        := SA1->A1_EMAIL
			cChaveAcesso  := Embaralha(SA1->A1_CHVPORT,0) //  1 - embaralha 0 -desembaralha
			cArqMod		  := "\portal_licenciado\modelos_html\scia040.html"
			
		Else

			cCliForn      := SA1->A1_COD
			cCnpj         := Transform(SA1->A1_CGC,"@r 99.999.999/9999-99")
			cContato      := SA1->A1_CONTATO
			cNomCliFor	  := SA1->A1_NOME
			cNReduz       := SA1->A1_NREDUZ
			cEmail        := SA1->A1_EMAIL
			cChaveAcesso  := Embaralha(SA1->A1_CHVPORT,0) //  1 - embaralha 0 -desembaralha
			cArqMod		  := "\portal_licenciado\modelos_html\scia040.html"		
			
		EndIf
		
	Else// Posicionado no FORNECEDOR

		If cWebServ = "WS"
		
			dbSelectArea("SA2")
			SA2->( dbGoTo( nNumRecno) )	
			cCliForn      := SA2->A2_COD
			cCnpj         := Transform(SA2->A2_CGC,"@r 99.999.999/9999-99")
			cContato      := SA2->A2_CONTATO
			cNomCliFor	  := SA2->A2_NOME
			cNReduz       := SA2->A2_NREDUZ
			cEmail        := SA2->A2_EMAIL
			cChaveAcesso  := Embaralha(SA2->A2_CHVPORT,0) //  1 - embaralha 0 -desembaralha
			cArqMod		  := "\portal_licenciado\modelos_html\scia050.html"
		
		Else

			cCliForn      := SA2->A2_COD
			cCnpj         := Transform(SA2->A2_CGC,"@r 99.999.999/9999-99")
			cContato      := SA2->A2_CONTATO
			cNomCliFor	  := SA2->A2_NOME
			cNReduz       := SA2->A2_NREDUZ
			cEmail        := SA2->A2_EMAIL
			cChaveAcesso  := Embaralha(SA2->A2_CHVPORT,0) //  1 - embaralha 0 -desembaralha
			cArqMod		  := "\portal_licenciado\modelos_html\scia050.html"
						
		EndIf	
		
	EndIf
	
	// Monta o Array com as Variveis no Html a serem substituidas
	aAdd( aConteudo,{ "%cCnpj%"           , cCnpj 		 } )
	aAdd( aConteudo,{ "%cCnpjf%"          , cCnpj		 } )
	aAdd( aConteudo,{ "%cContato%"        , cContato	 } )
	aAdd( aConteudo,{ "%cNomeFornecedor%" , cNomCliFor	 } )
	aAdd( aConteudo,{ "%cMail%"           , cEmail		 } )
	aAdd( aConteudo,{ "%cChaveAcesso%"    , cChaveAcesso} )
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Le Arquivo Modelo substituindo as macros pelo conteudo das variaveis³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	If File( cArqMod )
	
		cHtml := A040MontaHtml( cArqMod, aConteudo )
		aRet  := A040EnviaMail( cHTML, cEmail, cTable )
		
	Else
	
		cError := "- Arquivo modelo não encontrado. " + CRLF
		cError += "Caminho: "+cArqMod + CRLF 
		aRet:= {.F.,cError}
		
	Endif

Return( aRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao  ³ A040MontaHtml ³ Autor ³ Fabio Briddi     ³ Data ³            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Insere informacoes no Arquivo HTML                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040MontaHtml( cExp1, aExp1 )                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 - Caminho do Arquivo modelo HTML                     ³±±
±±³          ³ aExp1 - Variavel com o conteudo a ser apendada             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente S.C Internacional                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A040MontaHtml( cArqMod, aConteudo )

	Local cHtml     := ""
	Local cLinha    := "" 
	Local cLinhaNew := ""
	
	FT_FUse(cArqMod)
	FT_FGOTOP()
	
	Do While !FT_FEOF()
	
		cLinha := FT_FREADLN()
		
		nAchou := AT('%',cLinha)// Verifica se a Linha Tem Campo a Substituir
		
		If nAchou > 0
		
			For nA := 1 To Len(aConteudo)
			
				nAchou := AT(Upper(aConteudo[nA,1]),Upper(cLinha))
				cLinhaNew := ""
				
				If nAchou > 0
					cLinhaNew := Substr(cLinha,1,nAchou-1)
					cLinhaNew += aConteudo[nA,2]
					cLinhaNew += Substr(cLinha,nAchou+Len(aConteudo[nA,1]))
					cLinha    := cLinhaNew
				Endif
				
			Next
			
		Endif
		
		cHtml += cLinha
		FT_FSKIP()
		
	EndDo

Return( cHtml )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao  ³ A040EnviaMail ³ Autor ³ Jeferson Dambros ³ Data ³ 16/10/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera o arquivo HTML e  envia o e-mail com a liberacao      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ A040GeraEmail( cExp1, cExp2 )                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cExp1 -  Tabela posicionada                                ³±±
±±³          ³ cExp2 -  endereco de e-mail                                ³±±
±±³          ³ cExp3 -  Indica a tabela que esta sendo utilizada          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Especifico Cliente S.C Internacional                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function A040EnviaMail( cHTML,cEmail,cTable )

	Local cError     := ""
	Local cMsg       := ""
	Local cBuffer    := ""
	Local lOK        := .F.
	Local lMsgError  := .T.	
	Local lAuth      := Getmv( "MV_RELAUTH" )
	Local cServer    := GetMV( "MV_RELSERV" )
	Local cAccount   := GetMv( "MV_RELACNT" )
	Local cPassword  := GetMv( "MV_RELPSW"  )	
	
	//-- Usar e-mail temporario para homologacao
	cTo      := AllTrim( cEmail )
	
	If cTable = "SA1"
		cSubject	:= "Chave de Acesso ao Portal do Licenciado (Cliente)"
	Else
		cSubject	:= "Chave de Acesso ao Portal do Licenciado (Fornecedor)"	
	EndIf
	                               	
	// conectando-se com o servidor de e-mail
	CONNECT SMTP SERVER cServer ACCOUNT cAccount PASSWORD cPassword RESULT lResult
	
		// Fazendo autenticacao
		If lResult .And. lAuth
		
			lResult := MailAuth( cAccount,cPassword )
			If !lResult
			
				If lMsgError// Erro na conexao com o SMTP Server
				
					GET MAIL ERROR cError
					cMsg += "- Erro na autenticação da conta do e-mail. " + cError + CRLF
					lOK:= .F.
					
				EndIf
				
			EndIf
			
		Else
		
			If !lResult
				
				If lMsgError//Erro na conexao com o SMTP Server
				
					GET MAIL ERROR cError
					cMsg += "- Erro de conexão com servidor SMTP. " + cError + CRLF
					lOK:= .F.
					
				EndIf
				
			EndIf
			
		EndIf
		
		If !lResult
		
			GET MAIL ERROR cError
			cMsg += "- Erro ao conectar a conta de e-mail. " + cError
			lOK:= .F.
			
		Else
		
			SEND MAIL FROM cAccount TO cTo SUBJECT cSubject BODY cHTML RESULT lResult

			If !lResult
			
				GET MAIL ERROR cError
				cMsg := "- Erro no Envio do e-mail. " + cError + CRLF
				lOK  := .F.
				
			EndIf
			
			lOK := .T.
			
		EndIf
	
		DISCONNECT SMTP SERVER

Return( {lOK, cMsg} )