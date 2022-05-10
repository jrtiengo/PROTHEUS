#Include "TOTVS.CH"

//Colunas ARQUIVO  TXT

#DEFINE P_PREFIXO	    01
#DEFINE P_SEQUENCIAL	02
#DEFINE P_PARCELA	    03
#DEFINE P_TIPO          04
#DEFINE P_FORNECEDOR	05
#DEFINE P_LOJA_FORNECE	06
#DEFINE P_VALOR  	    07
#DEFINE P_NATUREZA   	08
#DEFINE P_VENCIMENTO	09
#DEFINE P_EMISSAO   	10
#DEFINE P_HISTORICO  	11
#DEFINE P_DATAPAGA	    12
#DEFINE P_BANCO 	    13
#DEFINE P_AGENCIA	    14
#DEFINE P_CONTACORE	    15
//---------------------------------------------------------------------------
#DEFINE P_PAGINSS	    16 // Codigo de Pagamento INSS     - Ednei 15.09.16
#DEFINE P_RETDARF	    17 // Codigo de Retencao  DARF     - Ednei 15.09.16
#DEFINE P_OUTENTI	    18 // Valor Outras Entidades INSS  - Ednei 15.09.16
#DEFINE P_MULTJUR	    19 // Valor ATM/Multa e Juros INSS - Ednei 15.09.16
#DEFINE P_MULDARF	    20 // Valor Multa DARF 			   - Ednei 15.09.16
#DEFINE P_JURDARF	    21 // Valor Juros DARF             - Ednei 15.09.16
//---------------------------------------------------------------------------

#DEFINE TAM_REG		    21
#DEFINE TAM_LINHA	    214

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ SCIM001  ³ Autor ³ Andre Silveira      ³ Data ³ 17/09/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Importa TXT do contas a pagar - integrao com RH Senior     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ u_SCIM001                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SCI                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function SCIM001()

	Local oProcess
	Local cPerg		   :=  PadR("SCIM001", 10 /*TamSx3("X1_GRUPO")[1]*/)
	Local cCadastro	   := "Importação do Contas a pagar"
	Local cDescRot	   := ""
	Local cDirA		   := ""
	Local bProcess 	   := {||}
	Local aInfoCustom  := {}
	Local aMvParam	   := {}
	
	Private cInfTit1   :="" // Historico  - quando baixado pelo financeiro - Ednei 18.10.16
	Private cInfTit2   :="" // Fornecedor - quando baixado pelo financeiro - Ednei 18.10.16
	Private cInfTit3   :="" // Valor pago - quando baixado pelo financeiro - Ednei 18.10.16
	Private cInfTit4   :="" // Emisso 	  - quando baixado pelo financeiro - Ednei 18.10.16 
	
	Private aLinha      := {}
	Private cDoc        := ""
	Private lTiBaixado
	Private lTituloAber
	Private nQuanti     := 0
	Private nHdl        := 0
	Private cArqLog     := ""
	Private lLog        := .T.
	Private aArq	    := {}
	
	CriaSx1(cPerg)
	
	aAdd( aInfoCustom, { "Cancelar",            	{ |oPanelCenter| oPanelCenter:oWnd:End() }, 	"CANCEL"	})
	
	bProcess := {|oProcess| Executa(oProcess, cPerg) }
	
	cDescRot := " Este programa tem o objetivo, importar TXT para o contas a pagar "
	
	oProcess := tNewProcess():New("SCIM001",cCadastro,bProcess,cDescRot,cPerg,aInfoCustom, .T.,5, "", .T. )

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Excuta   ³ Autor ³ Andre Silveira      ³ Data ³ 17/09/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ excuta a rotina de importacao e importa os dados           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ u_SCIM001                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SCI                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Executa(oProcess, cPerg)

	Local cMsg		:= ""
	Local nCont		:= 0
	Local cMvPar    := "ES_E2NUMSQ"
	Local cE2Numsq  := ""
	Local lOkSequen := .T.
	Local nTotRecs  := 0
	Local nSc1      := 0   
	Local cDirHist  := "" 
	Local cArquivo  := ""
    Local dDtpg
	Local nTamCodFor := TamSx3("A2_COD")[1]
	Local nTamLojFor := TamSx3("A2_LOJA")[1]
	Local nTamE2Num  := TamSx3("E2_NUM")[1]

	Pergunte(cPerg,.F.)

	cDir     := AllTrim(MV_PAR01)
	cDirArq  := "" 
	
	If	!Empty( cDir )

		aArq := Directory( cDir )
		
		If Len(aArq) = 0
			
			cMsg := "Verifique os parametros! Nao ha arquivo a importar."
			Aviso("Importar", cMsg, {"Ok"}, 3)
			
		Else

			nPosBarra := RAt("\",cDir)
			cDirArq   := SubStr(cDir, 1, nPosBarra)
			nPosPonto := RAt(".",cDir)
			cArqLog   := SubStr(cDir, 1, nPosPonto) + "log"
			cDirHist  := cDirArq + "historico\"  
			cArquivo  := aArq[1][1]

			oProcess:SaveLog("Inicio da Execucao")

			If Ft_FUse( cDirArq+aArq[1][1] ) <> -1
				
				oProcess:SetRegua1(Len(aLinha))
				nCont := 0
				
				oProcess:SetRegua2(FT_FLastRec())
				
				Ft_FGoTop()
				
				dDtFin := getMV("MV_DATAFIN")
				
				While !Ft_FEof()
					
					nCont++
					oProcess:IncRegua1( cValToChar(nCont))
					oProcess:IncRegua2("Lendo linha... " + cValToChar(nCont)) 
					
					cLinha	:= Ft_FReadLn()
					dDtpg:=cToD(substr(cLinha,68,2)+"/"+ substr(cLinha,70,2)+"/"+substr(cLinha,72,4))
					//If	Len(AllTrim(cLinha)) = TAM_LINHA  .and. dDtpg > getMV("MV_DATAFIN")
					If	Len(AllTrim(cLinha)) = TAM_LINHA  .and. dDtpg > dDtFin 

						aAdd( aLinha , Array( TAM_REG ) )
						aLinha[Len(aLinha),P_PREFIXO]	   := substr(cLinha,1,3)   //prefixo do titulo
						aLinha[Len(aLinha),P_SEQUENCIAL]   := substr(cLinha,4,9)  //numero do titulo sequencial
						aLinha[Len(aLinha),P_PARCELA]	   := substr(cLinha,13,1)  //parcel do titulo:brancos
						aLinha[Len(aLinha),P_TIPO]	       := substr(cLinha,14,3)  //tipo de otitulo: fixo DP
						aLinha[Len(aLinha),P_FORNECEDOR]   := substr(cLinha,17,nTamCodFor) //condigo do fornecedor
						aLinha[Len(aLinha),P_LOJA_FORNECE] := substr(cLinha,17+nTamCodFor,nTamLojFor) //condigo do fornecedor
						
						aLinha[Len(aLinha),P_VALOR ]	   := val(substr(cLinha,31,20))/100 //valor, com zeros a esuqerda, duas casas decimais e sem ponto decimal
						aLinha[Len(aLinha),P_NATUREZA]	   := substr(cLinha,51,9)      //codigo da natureza fenanceira
						aLinha[Len(aLinha),P_VENCIMENTO]   := cToD(substr(cLinha,60,2)+"/"+substr(cLinha,62,2)+"/"+substr(cLinha,64,4))   //Data de vencimento, formato DDMMAAAA
						aLinha[Len(aLinha),P_EMISSAO]	   := cToD(substr(cLinha,68,2)+"/"+ substr(cLinha,70,2)+"/"+substr(cLinha,72,4))   //Data de Emissao, formato DDMMAAAA
						aLinha[Len(aLinha),P_HISTORICO]	   := substr(cLinha,76,25)   //Historico
						aLinha[Len(aLinha),P_DATAPAGA]	   := cToD(substr(cLinha,101,2)+"/"+substr(cLinha,103,2)+"/"+substr(cLinha,105,4))  //Data depagamento: quando o titulo ja deva nascer quitado
						aLinha[Len(aLinha),P_BANCO]	       := substr(cLinha,109,3)    //Banco de quitacao: banco que foi debitado o valor
						aLinha[Len(aLinha),P_AGENCIA]	   := substr(cLinha,112,5)    //agencia d equitacao
						aLinha[Len(aLinha),P_CONTACORE]	   := substr(cLinha,117,10)   //conta corrente da quitacao
					    //------------------------------------ Ednei 15.09.16 ---------------------------------------------
					    aLinha[Len(aLinha),P_PAGINSS]	   := substr(cLinha,127,4)    //Codigo de Pagamento INSS
					    aLinha[Len(aLinha),P_RETDARF]	   := substr(cLinha,131,4)    //Codigo de Pagamento INSS
					    aLinha[Len(aLinha),P_OUTENTI]	   := val(substr(cLinha,135,20))/100 //valor, com zeros a esuqerda, duas casas decimais e sem ponto decimal
					    aLinha[Len(aLinha),P_MULTJUR]	   := val(substr(cLinha,155,20))/100 //valor, com zeros a esuqerda, duas casas decimais e sem ponto decimal
					    aLinha[Len(aLinha),P_MULDARF]	   := val(substr(cLinha,175,20))/100 //valor, com zeros a esuqerda, duas casas decimais e sem ponto decimal
					    aLinha[Len(aLinha),P_JURDARF]	   := val(substr(cLinha,195,20))/100 //valor, com zeros a esuqerda, duas casas decimais e sem ponto decimal
					    
					Else
					
						nQuanti++
                        
                        //If dDtpg<=getMV("MV_DATAFIN") .and. Len(AllTrim(cLinha)) = TAM_LINHA
                        If dDtpg <= dDtFin .and. Len(AllTrim(cLinha)) = TAM_LINHA
							cMsg := " Historico/Valor " +substr(cLinha,76,25)+' / '+cValToChar(val(substr(cLinha,31,20))/100)+", Com data menor que o perido de fechamento. Titulo nao importado!"+CRLF
							CriaLog( cMsg , nCont )
						else
							cMsg := "Linha: " + cValToChar(nCont) + ", Com tamanho divergente do laytout"  +"Tam. Linha"+cValToChar(Len(AllTrim(cLinha)))+CRLF
					   		CriaLog( cMsg , nCont )
                        endif
					EndIf

					Ft_FSkip()
					
				EndDo
				
				Ft_FUse()
			EndIf
		EndIf
		
		

		If	Len(aLinha) > 0
			
			//dbSelectArea("SX6")
			//dbSetOrder(1)
			
			OpenSxs(,,,,,"SX6TRB","SX6",,.F.)
			If Select("SX6TRB") > 0
			
				lSeek := SX6TRB->( dbSeek( cFilAnt + cMvPar ) )
				
				If !lSeek
					
					lSeek := SX6TRB->( dbSeek( Space(Len(cFilAnt)) + cMvPar ) )
					
				EndIf
				
		  	
		  	
		  	
				If !lSeek .Or. Empty( SX6TRB->&('X6_CONTEUD') )
					
					cMsg := "Parametro: " + cMvPar + ", Inválido." + CRLF + CRLF
					cMsg := "Não foi possível continuar a importação." + cMvPar + CRLF
					
					Aviso("Parametro", cMsg, {"Ok"}, 3)
					
				Else
					
					oProcess :SetRegua2(Len(aLinha)) 
					oProcess :SetRegua1(nCont)
					nTotRecs := Len(aLinha)
					nCont:= 0
				
					For nSc1:=1 To nTotRecs
						
						nCont++
						oProcess:IncRegua1( cValToChar(nCont))
						oProcess:IncRegua2("Importando Registro... " + cValToChar(nCont))
						
						
						//dbSelectArea("SX6")
						//dbSetOrder(1)
						//dbSeek( xFilial("SX6") + cMvPar )					
   						SX6TRB->( dbSeek( xFilial("SX6") + cMvPar ) )
						cE2Numsq := SubStr(AllTrim(SX6TRB->&('X6_CONTEUD')),1,nTamE2Num)
						
						/*
						RecLock("SX6", .F.)
							SX6->X6_CONTEUD := Soma1(cE2Numsq)
						MsUnLock()
	                    */
	                    
	                    PutMv(cMvPar,cE2Numsq)
	                    
						//verifica se tem titulo
						If ExistTitul(nSc1) == .T.
							
							//se o titulo esta em aberto
							If lTituloAber == .T.
								
								//exluir o titulo anterior na rotina FINAN050
								lOkSequen:=ExeFina050(cDoc,5,nSc1)
								
								If lOkSequen == .T.
									
									//inlua o novo titulo titulo na rotina FINAN050
									lOkSequen := ExeFina050(cE2Numsq,3,nSc1)
									
									If lOkSequen == .T.
										
										//Se data de pagamento e banco estiver preenchido
										If !Empty(aLinha[nSc1,P_DATAPAGA]) .And.  !Empty(aLinha[nSc1,P_BANCO])
											
											//baixa o titulo na rotina FINA080
											ExeFina080(cE2Numsq,3,nSc1)
										EndIf
										cDoc := ""
									EndIf
								EndIf
								
							Else
								//titulo baixado pela rotina
								If lTiBaixado == .T.
									
									//excluir o titulo baixado na rotina FINA050
									lOkSequen := ExeFina080(cDoc,5,nSc1)
									If lOkSequen == .T.
										//excluir o titulo anterior na rotina FINA050
										lOkSequen := ExeFina050(cDoc,5,nSc1)
										
										If lOkSequen == .T.
											//inlua o novo titulo titulo na rotina FINA050
											lOkSequen := ExeFina050(cE2Numsq,3,nSc1)
											
											If lOkSequen == .T.
												If !Empty(aLinha[nSc1,P_DATAPAGA]) .And.  !Empty(aLinha[nSc1,P_BANCO])
													
													//baixa o titulo na rotina FINA080
													ExeFina080(cE2Numsq,3,nSc1)
												EndIf
											EndIf
										EndIf
										cDoc := ""
									EndIf
								Else
									
									
									
									cMsg := "Titulo foi baixado pelo financeiro." + CRLF
									cMsg += "Titulos quitados não podem ser alterados automaticamente." + CRLF  
									cMsg += "HISTORICO  Arq. Importacao " + aLinha[nSc1,P_HISTORICO]+ CRLF 
									cMsg += "FORNECEDOR Arq. Importacao " + aLinha[nSc1,P_FORNECEDOR] + CRLF
									cMsg += "VALOR      Arq. Importacao " + TRANSFORM(aLinha[nSc1,P_VALOR],"@E 999,999,999.99")+ CRLF
									cMsg += "EMISSAO    Arq. Importacao " + DTOC(aLinha[nSc1,P_EMISSAO] )+CRLF   
									cMsg += "------------------------------------"+ CRLF
									cMsg += cInfTit1+ CRLF     
									cMsg += cInfTit2+ CRLF	   
									cMsg += cInfTit3+ CRLF	  
									cMsg += cInfTit4+ CRLF	   
									cMsg += "------------------------------------"+ CRLF
									
									
									CriaLog(cMsg,nSc1)
									
								EndIf
								
							EndIf
						Else
							
							/*
							nao tem titulo.
							inclua o titulo pela rotina  FINA050
							*/
							
							lOkSequen := ExeFina050(cE2Numsq,3,nSc1)
							
							If lOkSequen == .T.
								If !Empty(aLinha[nSc1,P_DATAPAGA]) .And.  !Empty(aLinha[nSc1,P_BANCO])
									
									//baixa o titulo pela rotina FINA080
									ExeFina080(cE2Numsq,3,nSc1)
								EndIf
							EndIf
						EndIf
						    
	/*					   
						If lOkSequen
							//grava o sequencial
							PutMv("ES_E2NUMSQ",soma1(cE2Numsq))
							SuperGetMv("")
						EndIf
	*/										                  
	
					Next nSc1
				EndIf
			SX6TRB->( DbCloseArea() )  	
		  	EndIf			
			
		EndIf

		
		//Tiver registros que nao foram importados e mostrado o log
		If	nQuanti > 0
			FClose(nHdl)

			cMsg := "O arquivo importado teve um total " + cValToChar(nQuanti) + " registro não importado. " + CRLF
			cMsg += "O arquivo de log dos registros, se encontra no diretório " + cArqLog + CRLF
			Aviso("Atenção!", cMsg, {"Ok"}, 3)
		EndIf  
		
		If !File( cDirArq + "\historico\." )
			MakeDir ( cDirArq + "\historico" )
		EndIf
		If __CopyFile( cDir, cDirHist + cArquivo )
			FErase( cDir )
		Else
			Aviso("Atenção!", "Não foi possivel copiar o arquivo para a pasta histórico", {"Ok"}, 3)			
		EndIf

	Else

		cMsg := "Caminho ou Nome de Arquivo Invalido!" + CRLF
		cMsg += cDir + CRLF

		Aviso("Atenção!", cMsg, {"Ok"}, 3)

	EndIf 
	
	oProcess:SaveLog("Fim da Execucao")

Return()

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CriaLog   ³ Autor ³ Andre Silveira    ³ Data ³ 17/09/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Cria log dos registros que não foram importados             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ u_SCIM001                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SCI                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function CriaLog( cEstatus, nJ )

	Local cLog := ""
	
	If	lLog
		
		nHdl  := FCreate(cArqLog)
		lLog  := .F.
		
	EndIf
	
/*
	cLog := aLinha[nJ,P_PREFIXO]
	cLog += aLinha[nJ,P_SEQUENCIAL]
	cLog += aLinha[nJ,P_PARCELA]
	cLog += aLinha[nJ,P_TIPO]
	cLog += aLinha[nJ,P_FORNECEDOR]
	cLog += cValToChar(aLinha[nJ,P_VALOR])
	cLog += aLinha[nJ,P_NATUREZA]
	cLog += DtoC(aLinha[nJ,P_VENCIMENTO])
	cLog += DtoC(aLinha[nJ,P_EMISSAO])
	cLog += aLinha[nJ,P_HISTORICO]
	cLog += DtoC(aLinha[nJ,P_DATAPAGA])
	cLog += aLinha[nJ,P_BANCO]
	cLog += aLinha[nJ,P_AGENCIA]
	cLog += aLinha[nJ,P_CONTACORE]          +" "+ CRLF
	cLog += cEstatus
*/	

	cLog := "Linha: " + cValToChar(nJ) + CRLF
	cLog += cEstatus

	FWrite(nHdl, cLog)
	
	nQuanti += 1

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ExeFina080³ Autor ³ Andre Silveira     ³ Data ³ 17/09/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina que executa a rotina automatica FINA080:            ³±±
±±³            baixa o titulo                                             ³±±
±±³            excluir a baixa do titulo                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ u_SCIM001                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cNuSenq - Numero sequencial do titulo                      ³±±
±±³               nP   - opracao da rotina:                               ³±±
±±³                    -3  baixa                                          ³±±
±±³                    -5 excluir                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SCI                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ExeFina080( cNuSenq, nP, nJ )

	Local   aBaixa         := {}
	Local   lOk            := .T.
	Local   cMsg           := ""
	Local   aMsg           := {}
	Local  nInd            := 0

	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T.
	
	//verifica se o banco esta cadastrado.
	dbSelectarea("SA6")
	dbSetOrder(1)   //filial+codigo+agencia+numero da conta
	cBanco   := PadR(aLinha[nJ,P_BANCO],TamSx3("A6_COD")[1])
	cAgencia := PadR(aLinha[nJ,P_AGENCIA],TamSx3("A6_AGENCIA")[1])
	cConta   := PadR(aLinha[nJ,P_CONTACORE],TamSx3("A6_NUMCON")[1])

	If	!SA6->(dbSeek(xFilial("SA6") + cBanco + cAgencia + cConta ))
		
		cMsg := "Banco/Agência/Conta: " + cBanco + "/" + cAgencia + "/" + cConta + "não esta cadastrado!" + CRLF
		lOk := .F.
		
	EndIf
	
	If	lOk
		aAdd(aBaixa, {"E2_FILIAL"    , xFilial("SE2")				, Nil})
		aAdd(aBaixa, {"E2_PREFIXO"   , aLinha[nJ,P_PREFIXO]			, Nil})
		aAdd(aBaixa, {"E2_NUM"       , cNuSenq						, Nil})
		aAdd(aBaixa, {"E2_PARCELA"   , aLinha[nJ,P_PARCELA]			, Nil})
		aAdd(aBaixa, {"E2_TIPO"      , aLinha[nJ,P_TIPO]			, Nil})
		aAdd(aBaixa, {"E2_FORNECE"   , aLinha[nJ,P_FORNECEDOR]		, Nil})
		aAdd(aBaixa, {"E2_LOJA"      , aLinha[nJ,P_LOJA_FORNECE]	, Nil})
		aAdd(aBaixa, {"E2_CODINSS"   , aLinha[nJ,P_PAGINSS]         , NiL})
		aAdd(aBaixa, {"E2_CDRET"     , aLinha[nJ,P_RETDARF]         , NiL})
		aAdd(aBaixa, {"E2_OUTRASE"   , aLinha[nJ,P_OUTENTI]         , NiL})
		aAdd(aBaixa, {"E2_ATMMULT"   , aLinha[nJ,P_MULTJUR]         , NiL})
		aAdd(aBaixa, {"E2_DARFMLTT"  , aLinha[nJ,P_MULDARF]         , NiL})
		aAdd(aBaixa, {"E2_DARFJUR"   , aLinha[nJ,P_JURDARF]         , NiL})
		aAdd(aBaixa, {"AUTMOTBX"     , "NOR"						, Nil})
		aAdd(aBaixa, {"AUTBANCO"     , aLinha[nJ,P_BANCO]			, Nil})
		aAdd(aBaixa, {"AUTAGENCIA"   , aLinha[nJ,P_AGENCIA]			, Nil})
		aAdd(aBaixa, {"AUTCONTA"     , aLinha[nJ,P_CONTACORE]		, Nil})
		aAdd(aBaixa, {"AUTDTBAIXA"   , aLinha[nJ,P_DATAPAGA]		, Nil})
		aAdd(aBaixa, {"AUTDTCREDITO" , aLinha[nJ,P_DATAPAGA]		, Nil})
		aAdd(aBaixa, {"AUTHIST"      , aLinha[nJ,P_HISTORICO]		, Nil})
		aAdd(aBaixa, {"AUTVLRPG"     , aLinha[nJ,P_VALOR]           , Nil})
		
		AcessAperg("FIN080", .F.)
		MsExecAuto({|x,y| FINA080(x,y)}, aBaixa, nP) //baixa 3 exluir 5
		
		If lMsErroAuto
		    cMsg := ""
			cMsg += "FINA080(x,y,z)}, aArray,, " + cValToChar(nP) + ")" + CRLF
			
			For	nInd := 1 To Len(aBaixa)
		             If nInd==15
				     	cMsg += cValToChar(aArray[nInd,2]) + CRLF   
				     ElseIf nInd==12  .OR. nInd==13
				            
			            cMsg += DtoS(aArray[nInd,2]) + CRLF
				     Else
				          
				     	cMsg += aArray[nInd,2] + CRLF
				     EndIf	
			
		   	Next nInd 


			cMsg += CRLF
			cMsg += CRLF
			cMsg += CRLF + "ERRO.Verifique a mensagem abaixo:" + CRLF
			cMsg += CRLF
			cMsg += CRLF
			aMsg := GetAutoGRLog()
			aEval( aMsg, {|x| cMsg += x + CRLF })
			lOk := .F.
		EndIf
		
		If nP == 3 .And. lOk

			//altera o campo E5_BXINTEG para S.
			dbSelectArea("SE5")
			dbSetOrder(18)  //Filial + prefixo +  numero +  banco
			dbSeek( xFilial("SE5")+ aLinha[nJ,P_PREFIXO] + cNuSenq + aLinha[nJ,P_BANCO] )
			RecLock("SE5",.F.)
			SE5->E5_BXINTEG := "S"
			MsUnLock()

		EndIf
	EndIf
	
	//cria log de erro
	If	lOk
		CriaLog(cMsg,nJ)
	EndIf


Return(lOk)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ExeFina050³ Autor ³ Andre Silveira     ³ Data ³ 17/09/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ excuta a rotina  automatica FINA050:                       ³±±
±±³            -Incluir o titulo                                          ³±±
±±³            -excluir o titulo                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ u_SCIM001                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ cNuSenq - Numero sequencial do titulo                      ³±±
±±³               nP   - opracao da rotina:                               ³±±
±±³                    -3  incluir titulo                                 ³±±
±±³                    -5  excluir titulo                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SCI                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ExeFina050(cNuSenq,nP,nJ)

	Local aArray := {}
	Local lOk    := .T.
	Local aMsg   := {}
	Local cMsg   := "" 
	Local nInd   := 0
	
	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T.
	
	dbSelectArea("SA2")//FORNECEDOR
	dbSetOrder(1) //FILIAL+FORNECEDOR+ LOJA
	
	dbSelectArea("SED") //NATUREZA
	dbSetOrder(1) //FILIAL+FORNECEDOR+ LOJA
	
	/*
	verifica se os campos obrigatorios
	nao estao preenchidos e verifica os campos
	fornecedor e natureza, nao esta cadastrados.
	*/
	
	If Empty(AllTrim(aLinha[nJ,P_TIPO]))
		
		cMsg += Space(7) + "Campo tipo em Branco." + CRLF
		lOk := .F.
	EndIf
		
	If Empty(AllTrim(aLinha[nJ,P_NATUREZA]))
		
		cMsg += Space(7) + "Campo Natureza em Branco." + CRLF
		lOk := .F.

	Else
	
		If !SED->(dbSeek(xFilial("SED")+aLinha[nJ,P_NATUREZA]))
			
			cMsg += Space(7) + "Natureza " + aLinha[nJ,P_NATUREZA] + ", não cadastrado." + CRLF
			lOk := .F.
			
		EndIf
	EndIf
		
	If Empty(AllTrim(aLinha[nJ,P_FORNECEDOR])) .Or. Empty(AllTrim(aLinha[nJ,P_LOJA_FORNECE]))
		
		cMsg += Space(7) + "Campo Fornecedor ou Loja em Branco." + CRLF
		lOk := .F.

	Else
		cCodFor := aLinha[nJ,P_FORNECEDOR]
		cLojFor := aLinha[nJ,P_LOJA_FORNECE]

		If !SA2->( dbSeek( xFilial("SA2") + cCodFor + cLojFor ) )
			
			cMsg += Space(7) + "Fornecedor " + cCodFor + "-" + cLojFor + ", não cadastrado." + CRLF
			lOk := .F.
		
		EndIf
	EndIf
		
	If Empty(aLinha[nJ,P_EMISSAO])
		
		cMsg += Space(7) + "Campo Data de Emissao em Branco." + CRLF
		lOk := .F.
	EndIf
		
	If Empty(aLinha[nJ,P_VENCIMENTO])
		
		cMsg += Space(7) + "Campo Data de Vencimento em Branco." + CRLF
		lOk := .F.
	
	EndIf	
	
	If Empty(aLinha[nJ,P_VALOR])

		cMsg += Space(7) + " Campo Valor em Branco." + CRLF
		lOk := .F.

	EndIf
		
		
	
	If  lOk   
	        
		aAdd(aArray,{ "E2_FILIAL"   , XFILIAL("SE2")                      , NIL })
		aAdd(aArray,{ "E2_PREFIXO"  , padl(aLinha[nJ,P_PREFIXO],3)        , NIL })
		aAdd(aArray,{ "E2_NUM"      , cNuSenq                             , NIL })
		aAdd(aArray,{ "E2_PARCELA"  , padr(aLinha[nJ,P_PARCELA],2)        , NIL })
		aAdd(aArray,{ "E2_TIPO"     , padr(aLinha[nJ,P_TIPO],3)           , NIL })
		aAdd(aArray,{ "E2_FORNECE"  , aLinha[nJ,P_FORNECEDOR]             , NIL })
		aAdd(aArray,{ "E2_LOJA"     , aLinha[nJ,P_LOJA_FORNECE]           , NIL })
		aAdd(aArray,{ "E2_VALOR"    , aLinha[nJ,P_VALOR]                  , NIL })
		aAdd(aArray,{ "E2_VLCRUZ"   , aLinha[nJ,P_VALOR]                  , NIL })
		aAdd(aArray,{ "E2_NATUREZ"  , padr(aLinha[nJ,P_NATUREZA],10)      , NIL })
		aAdd(aArray,{ "E2_EMISSAO"  , aLinha[nJ,P_EMISSAO]                , NIL })
		aAdd(aArray,{ "E2_VENCTO"   , aLinha[nJ,P_VENCIMENTO]             , NIL })
		aAdd(aArray,{ "E2_VENCREA"  , aLinha[nJ,P_VENCIMENTO]             , NIL })
		aAdd(aArray,{ "E2_HIST"     , aLinha[nJ,P_HISTORICO]              , NIL })
		
		aAdd(aArray,{ "E2_CODINSS"  , aLinha[nJ,P_PAGINSS]                , NIL })
		aAdd(aArray,{ "E2_CDRET"    , aLinha[nJ,P_RETDARF]                , NIL })
		aAdd(aArray,{ "E2_OUTRASE"  , aLinha[nJ,P_OUTENTI]                , NIL })
		aAdd(aArray,{ "E2_ATMMULT"  , aLinha[nJ,P_MULTJUR]                , NIL })
		aAdd(aArray,{ "E2_DARFMLTT" , aLinha[nJ,P_MULDARF]                , NIL })
		aAdd(aArray,{ "E2_DARFJUR"  , aLinha[nJ,P_JURDARF]                , NIL })
		
		
		
		              
		
		MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, nP) // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
		
		If lMsErroAuto
		
			cMsg := ""
			cMsg += "FINA050(x,y,z)}, aArray,, " + cValToChar(nP) + ")" + CRLF
			For	nInd := 1 To Len(aArray)
		             If nInd==8 .Or. nInd==9
				     	cMsg += cValToChar(aArray[nInd,2]) + CRLF   
				     ElseIf nInd==11 .Or. nInd==12 .Or. nInd==13 
				            
			            cMsg += DtoS(aArray[nInd,2]) + CRLF
				     Else
				          
				 //    	cMsg += aArray[nInd,2] + CRLF
				     EndIf	
			
			Next nInd


			cMsg += CRLF
			cMsg += CRLF
			cMsg += CRLF + "ERRO.Verifique a mensagem abaixo:" + CRLF
			cMsg += CRLF
			cMsg += CRLF
			aMsg := GetAutoGRLog()
			aEval( aMsg, {|x| cMsg += x + CRLF })
			lOk := .F.
		EndIf
	EndIf
	
	//cria o log
	If lok==.F.
		
		CriaLog(cMsg,nJ)
	EndIf

Return(lOk)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ ExistTitul ³ Autor ³ Andre Silveira    ³ Data ³ 17/09/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Rotina que veriica: 1-verifica se tem titulo                ³±±
±±³                               2-titulos em abertos                    ³±±
±±³                               3-baixado pela rotina de integracao     ³±±
±±³                               4-baixado pelo financeiro               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ u_SCIM001                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ NIL                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ SCI                                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³                          ULTIMAS ALTERACOES                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ Motivo da Alteracao                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³            ³        ³                                                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ExistTitul(nJ)

	Local lExist  := .F. 
	Local cNvalor :=aLinha[nJ,P_VALOR]
	
	lTiBaixado   := .f.
	lTituloAber  := .f.
	
	cInfTit1 :=""
	cInfTit2 :=""
	cInfTit3 :=""
	cInfTit4 :=""
	
	cQuery := " SELECT E2_VENCTO, E2_FORNECE, E2_NATUREZ, E2_PREFIXO, E2_TIPO, E2_NUM, E2_BAIXA, "
	cQuery += " E2_HIST,(E2_VALOR - E2_SALDO+E2_ACRESC-E2_DECRESC) VLRPAGO, E2_EMISSAO "
	cQuery +=     " FROM "  + RetSQlName("SE2")
	cQuery +=         " WHERE "     
	cQuery +=            " E2_FILIAL  = '" + xFilial("SE2")                          + "'"
	cQuery +=            " AND E2_VENCTO  = '" + DtoS(aLinha[nJ,P_VENCIMENTO])       + "'"      //DATA DE VENCIMENTO
	cQuery +=            " AND E2_FORNECE = '" + aLinha[nJ,P_FORNECEDOR]             + "'"      //FORNECEDOR
	cQuery +=            " AND E2_LOJA    = '" + aLinha[nJ,P_LOJA_FORNECE]           + "'"      //FORNECEDOR
	cQuery +=            " AND E2_NATUREZ = '" + aLinha[nJ,P_NATUREZA]               + "'"     //NATUREZ
	cQuery +=            " AND E2_PREFIXO = '" + aLinha[nJ,P_PREFIXO]                + "'"     //PREFIXO
	cQuery +=            " AND E2_HIST    = '" + aLinha[nJ,P_HISTORICO]              + "'"     //Historico 
	cQuery +=            " AND E2_TIPO    = '" + aLinha[nJ,P_TIPO]                   + "'"     //TIPO 
    IF AllTrim(aLinha[nJ,P_PAGINSS])<>''
			cQuery +=            " AND E2_CODINSS = '" + aLinha[nJ,P_PAGINSS]                + "'"     //TIPO 
	Endif
	
	IF AllTrim(aLinha[nJ,P_RETDARF])<>''
   			cQuery +=            " AND E2_CODRET = '" + aLinha[nJ,P_RETDARF]                + "'"     //TIPO 
	Endif
    //	cQuery +=            " AND E2_VALOR   = '" +  cValToChar(cNvalor)                + "'"     //valor
	cQuery +=            " AND D_E_L_E_T_ <> '*'  "
	
	cQuery := ChangeQuery( cQuery )
	dbUseArea( .t., 'TOPCONN', TCGenQry(,,cQuery), 'TEMPSE2', .f., .t. )
	
	If !Eof()
		
		//tem titulo
		lExist:=.T.
		
		//pega o numero para dar baixa.
		cDoc:=TEMPSE2->E2_NUM
		
		If!Empty(TEMPSE2->E2_BAIXA)
			
			lTituloAber:=.F.
			
			dbSelectArea("SE5")
			dbSetOrder(18)       //Filial + prefixo +  numero +  banco
			dbSeek(xFilial("SE5")+aLinha[nJ,P_PREFIXO]+TEMPSE2->E2_NUM+aLinha[nJ,P_BANCO])
			
			If SE5->E5_BXINTEG=="S"
				
				//baixa pela rotina de integracao
				lTiBaixado:=.T.
				
			Else
				//baixa pelo financeiro
				
			   cInfTit1 := "HISTORICO  Base Protheus " + TEMPSE2->E2_HIST
			   cInfTit2 := "FORNECEDOR Base Protheus " + TEMPSE2->E2_FORNECE
			   cInfTit3 := "VALOR      Base Protheus " + TRANSFORM(TEMPSE2->VLRPAGO,"@E 999,999,999.99")
			   cInfTit5 := "EMISSAO    Base Protheus " + SUBSTR(TEMPSE2->E2_EMISSAO,7,2)+"/"+SUBSTR(TEMPSE2->E2_EMISSAO,5,2)+"/"+SUBSTR(TEMPSE2->E2_EMISSAO,1,4)
			   
			   lTiBaixado:=.F.
			EndIf
			
		Else
			//Titulo aberto
			lTituloAber:=.T.
		EndIf
		
	EndIf
	
	TEMPSE2->(DbCloseArea())

Return(lExist)



/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ CriaSx1  ³ Autor ³ Andre Silveira      ³ Data ³ 17/09/2014 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Criar o grupo de perguntas.                                ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
Static Function CriaSx1(cPerg)

	Local aP	 := {}
	Local aHelp	 := {}
	Local nI	 := 0
	Local cSeq	 := ""
	Local cMvCh  := ""
	Local cMvPar := ""
	
	/*
	Parametros da funcao padrao
	---------------------------
	PutSX1(cGrupo,;
	cOrdem,;
	cPergunt,cPerSpa,cPerEng,;
	cVar,;
	cTipo,;
	nTamanho,;
	nDecimal,;
	nPresel,;
	cGSC,;
	cValid,;
	cF3,;
	cGrpSxg,;
	cPyme,;
	cVar01,;
	cDef01,cDefSpa1,cDefEng1,;
	cCnt01,;
	cDef02,cDefSpa2,cDefEng2,;
	cDef03,cDefSpa3,cDefEng3,;
	cDef04,cDefSpa4,cDefEng4,;
	cDef05,cDefSpa5,cDefEng5,;
	aHelpPor,aHelpEng,aHelpSpa,;
	cHelp)
	*/
	
	//			Texto Pergunta	       Tipo 	Tam 	  Dec  	G=get ou C=Choice  	Val   	F3		Def01 	  Def02 	 Def03   Def04   Def05
	aAdd(aP,{	"Pasta ou Arquivo ?",	"C",	60,			0,		"G",					"",	 "DIR",		   "",		"",		"",		"",		""})
	
	//           012345678912345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
	//                    1         2         3         4         5         6         7         8         9        10        11        12
	aAdd(aHelp,{"Informe a pasta ou apenas o arquivo,","para importacao."                          ,"Ex.: c:\TEMP\ ou c:\TEMP\arquivo.txt"})
	
	For nI := 1 To Len(aP)
		
		cSeq	:= StrZero(nI,2,0)
		cMvPar	:= "mv_par"+cSeq
		cMvCh	:= "mv_ch"+IIF(nI<=9,Chr(nI+48),Chr(nI+87))
		/*
		PutSx1(cPerg,;
		cSeq,;
		aP[nI,1],aP[nI,1],aP[nI,1],;
		cMvCh,;
		aP[nI,2],;
		aP[nI,3],;
		aP[nI,4],;
		1,;
		aP[nI,5],;
		aP[nI,6],;
		aP[nI,7],;
		"",;
		"",;
		cMvPar,;
		aP[nI,8],aP[nI,8],aP[nI,8],;
		"",;
		aP[nI,9],aP[nI,9],aP[nI,9],;
		aP[nI,10],aP[nI,10],aP[nI,10],;
		aP[nI,11],aP[nI,11],aP[nI,11],;
		aP[nI,12],aP[nI,12],aP[nI,12],;
		aHelp[nI],;
		{},;
		{},;
		"")
		*/
	Next nI

Return()



