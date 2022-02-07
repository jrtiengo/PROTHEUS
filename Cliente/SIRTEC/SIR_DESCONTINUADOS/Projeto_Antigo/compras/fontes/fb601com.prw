#INCLUDE "MATR440.CH"
#INCLUDE "PROTHEUS.CH"
/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    � fab601com� Autor � Daniela Maria Uez     � Data �10/02/2010���
�������������������������������������������������������������������������Ĵ��
���Descricao � Lista os itens que atingiram o ponto de pedido.            ���
���          � Baseado no original MATR440 de Alexandre In�cio Lemes      ���
���          � Se par�metro considera estoque de seguran�a = n�o, qtd a   ���
���          � comprar = estoque seguran�a - estoque atual.               ���
���          � Quantidade a comprar = estoque seguran�a - (Saldo atual +  ���
���          � quantidade de entrada prevista).Caso (Saldo atual + qtd    ���
���          � entrada prevista) > estoque seguran�a, a qtd a comprar = 0.���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe   � MATR440(void)                                              ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ�� 
���        ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.              ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���Eduardo Fern�24.07.06�XXXXXX�Inclusao mv_par19 (Seleciona Filiais ?)   ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
user function fb601com()	
	Local oReport 
	fb601rel()
Return

/*                           
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Descri��o � PLANO DE MELHORIA CONTINUA        �Programa   MATR440.PRX  ���
�������������������������������������������������������������������������Ĵ��
���ITEM PMC  � Responsavel              � Data                            ���
�������������������������������������������������������������������������Ŀ��
���Fun��o    � fbestr3� Autor � Eveli Morasco         � Data � 16/04/93   ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Lista os itens que atingiram o ponto de pedido             ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � Generico                                                   ���
�������������������������������������������������������������������������Ĵ��
���         ATUALIZACOES SOFRIDAS DESDE A CONSTRU�AO INICIAL.             ���
�������������������������������������������������������������������������Ĵ��
���Programador � Data   � BOPS �  Motivo da Alteracao                     ���
�������������������������������������������������������������������������Ĵ��
���            �        �      �                                          ���
���            �        �      �                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
static Function  fb601rel //MATR440R3
//��������������������������������������������������������������Ŀ
//� Define Variaveis                                             �
//����������������������������������������������������������������
Local wnrel
Local Tamanho  := "G"
Local cDesc1   := "Emite uma relacao com os itens em estoque que atingiram o Ponto de"
Local cDesc2   := "Pedido ,sugerindo a quantidade a comprar."
Local cDesc3   := ""

Local aFilsCalc :={}

//��������������������������������������������������������������Ŀ
//� Variaveis tipo Private padrao de todos os relatorios         �
//����������������������������������������������������������������
Private nomeprog := "FB601COM"
Private cString  := "SB1"
Private aReturn  := { "Zebrado", 1,"Administracao", 2, 2, 1, "",1 }
Private nLastKey := 0
Private cPerg    := padr("MTR440", LEN(SX1->X1_GRUPO), " ") 
Private titulo   := OemToAnsi("Itens em Ponto de Pedido")
//��������������������������������������������������������������Ŀ
//� Contadores de linha e pagina                                 �
//����������������������������������������������������������������
Private li       := 80
Private m_pag    := 1

AjustaSX1()

//��������������������������������������������������������������Ŀ
//� Verifica as perguntas selecionadas                           �
//����������������������������������������������������������������
//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para parametros                         �
//� mv_par01             // Produto de                           �
//� mv_par02             // Produto ate                          �
//� mv_par03             // Grupo de                             �
//� mv_par04             // Grupo ate                            �
//� mv_par05             // Tipo de                              �
//� mv_par06             // Tipo ate                             �
//� mv_par07             // Local de                             �
//� mv_par08             // Local ate                            �
//� mv_par09             // Considera Necess Bruta   1 - Sim     �
//� mv_par10             // Saldo Neg Considera      1 - Sim     � 
//� mv_par11             // Considera C.Q.           1 - Sim     �
//� mv_par12             // Cons.Qtd. De 3os.? Sim / Nao         �
//� mv_par13             // Cons.Qtd. Em 3os.? Sim / Nao         �
//� mv_par14             // Qtd. PV nao Liberado ?" Subtr/Ignora �
//� mv_par15             // Descricao completa do produto?       �
//� mv_par16             // Considera Saldo Armazem de           �
//� mv_par17             // Considera Saldo Armazem ate          �
//� mv_par18             // Data limite p/ empenhos              �
//� mv_par19             // Seleciona Filiais ? (Sim/Nao)        �
//����������������������������������������������������������������
Pergunte(cPerg,.F.)

//��������������������������������������������������������������Ŀ
//� Envia controle para a funcao SETPRINT                        �
//����������������������������������������������������������������
wnrel:=SetPrint(cString,NomeProg,cPerg,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",.F.,Tamanho)

If nLastKey = 27
	dbClearFilter()
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	dbClearFilter()
	Return
Endif

Processa( { |lEnd| R440Imp( @lEnd, tamanho, wnrel, cString, MatFilCalc( mv_par19 == 1 ) ) }, Titulo )

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun��o    � R440IMP  � Autor � Cristina M. Ogura     � Data � 09.11.95 ���
�������������������������������������������������������������������������Ĵ��
���Descri��o � Chamada do Relatorio                                       ���
�������������������������������������������������������������������������Ĵ��
��� Uso      � MATR440			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function R440Imp(lEnd,tamanho,wnrel,cString,aFilsCalc)

Local cLocCQ   := GetMV("MV_CQ")
Local cRodaTxt := "PRODUTO(S)"
Local cTipoVal := ""
Local cabec1   := ""
Local cabec2   := ""

Local nQuant   := 0
Local nSaldo   := 0
Local nValUnit := 0
Local nValor   := 0
Local nValTot  := 0
Local nPrazo   := 0
Local nToler   := 0
Local nEstSeg  := 0
Local nNeces   := 0
Local nCntImpr := 0
Local nTipo    := 0
Local nAuxQuant:= 0
Local nSaldAux := 0
Local nX       := 0
Local nPrevis  := 0
Local lValidSB1:=.T.
Local lQuery   :=.F.

Local bWhile   := {}

#IFDEF TOP
	Local aStru		:= {}
	Local cAliasSB1 := GetNextAlias()
	Local cQuery	:= ""
	Local cQueryPE	:= ""
	Local lMT170QRY := ExistBlock( "MT170QRY" )
#ELSE
	Local cAliasSB1 := "SB1"
#ENDIF

//��������������������������������������������������������������Ŀ
//� Variaveis utilizadas para Tratamento da impressao por Filiais�
//����������������������������������������������������������������
Local nForFilial := 0
Local cFilBack   := cFilAnt

//�������������������������������������������������������������������Ŀ
//� Inicializa os codigos de caracter Comprimido/Normal da impressora �
//���������������������������������������������������������������������
nTipo  := IIf(aReturn[4]==1,15,18)

//��������������������������������������������������������������Ŀ
//� Monta os Cabecalhos                                          �
//����������������������������������������������������������������
cabec1 := "CODIGO          DESCRICAO                      TP GRP  UM  SALDO ATUAL      ENTRADA     PONTO DE   ESTOQUE DE         LOTE QUANTIDADE A   VALOR ESTIMADO VALOR UNITARIO"
cabec2 := "                                                                           PREVISTA       PEDIDO    SEGURANCA    ECONOMICO      COMPRAR        DA COMPRA      DA COMPRA"
     //    123456789012345 123456789012345678901234567890 12 1234 12 9.999.999,99 9.999.999,99 9.999.999,99 9.999.999,99 9.999.999,99 9.999.999,99 9.999.999.999,99 999.999.999,99 
     //    0         1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21
     //    0123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123

If !Empty(aFilsCalc)                                                                                  
	
	dbSelectArea("SB1")
	aStru := SB1->(dbStruct())

	For nForFilial := 1 to Len(aFilsCalc)
		
		If aFilsCalc[nForFilial,1]
			
			// Altera filial corrente
			cFilAnt := aFilsCalc[nForFilial,2]
			
			li := 80 // Reinicia Paginas
			
			lQuery := .F.
			dbSelectArea("SB1")
			ProcRegua(RecCount())

			#IFDEF TOP
				If ( TcSrvType()!="AS/400" )
					lQuery := .T.
					cQuery := "SELECT SB1.*,SB1.R_E_C_N_O_ SB1RECNO FROM " + RetSqlName("SB1")+" SB1 "
					cQuery += "WHERE SB1.B1_FILIAL ='"+xFilial("SB1")+"' AND "
					cQuery += "SB1.B1_COD >='"  +mv_Par01+"' AND SB1.B1_COD <='"  +mv_Par02+"' AND "
					cQuery += "SB1.B1_GRUPO>='" +mv_Par03+"' AND SB1.B1_GRUPO<='" +mv_Par04+"' AND "
					cQuery += "SB1.B1_TIPO>='"  +mv_Par05+"' AND SB1.B1_TIPO<='"  +mv_Par06+"' AND "
					cQuery += "SB1.B1_LOCPAD>='"+mv_Par07+"' AND SB1.B1_LOCPAD<='"+mv_Par08+"' AND "
					cQuery += "SB1.B1_CONTRAT<>'S' AND SB1.B1_CONTRAT<>'A' AND SB1.B1_TIPO<>'BN' AND "
					cQuery += "SB1.D_E_L_E_T_ = ' ' "					
					cQuery += " ORDER BY SB1.B1_COD"
					
					cQuery := ChangeQuery(cQuery)
					dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cAliasSB1)

					For nX := 1 To Len(aStru)
						If ( aStru[nX][2] <> "C" .And. FieldPos(aStru[nX][1])<>0 )
							TcSetField(cAliasSB1,aStru[nX][1],aStru[nX][2],aStru[nX][3],aStru[nX][4])
						EndIf
					Next

					dbGoTop()
					bWhile := { || !(cAliasSB1)->(Eof()) }
				Else
					dbSeek( xFilial("SB1")+mv_Par01,.T. )
					bWhile := { ||  !SB1->(Eof()) .And. SB1->B1_FILIAL+SB1->B1_COD <= xFilial("SB1")+mv_par02 }
				EndIf
			#ELSE
				dbSeek( xFilial("SB1")+mv_Par01,.T. )
				bWhile := { ||  !SB1->(Eof()) .And. SB1->B1_FILIAL+SB1->B1_COD <= xFilial("SB1")+mv_par02 }
			#ENDIF
	
			nValTot := 0
			
			While Eval(bWhile)
				//U__log(alltrim((cAliasSB1)->B1_COD))
				
				If lEnd
					@PROW()+1,001 PSAY "CANCELADO PELO OPERADOR"
					Exit
				Endif
				
				IncProc( OemToAnsi(STR0029) + ": " + aFilsCalc[ nForFilial, 3 ] )

				If IsProdMod((cAliasSB1)->B1_COD)
					//���������������������������������Ŀ
					//� Filtra produtos MOD				�
					//�����������������������������������
				   	(cAliasSB1)->(dbSkip())
			   		Loop
				EndIf

				If !Empty(aReturn[7])
					If !&(aReturn[7])
						(cAliasSB1)->(dbSkip())
						Loop
					Endif   
				EndIf
				If !lQuery
					//���������������������������������������������Ŀ
					//� Filtra grupos e tipos nao selecionados  	�
					//�����������������������������������������������
					If (cAliasSB1)->B1_GRUPO < mv_par03 .Or. (cAliasSB1)->B1_GRUPO > mv_par04 .Or.;
						(cAliasSB1)->B1_TIPO  < mv_par05 .Or. (cAliasSB1)->B1_TIPO  > mv_par06 .Or.;
						(cAliasSB1)->B1_TIPO == "BN" .Or. (cAliasSB1)->B1_CONTRAT == "S" .Or. (cAliasSB1)->B1_CONTRAT == "A"
					   	dbSkip()
				   		Loop
					EndIf
			
					//����������������������������������Ŀ
					//� Filtra armazem padrao do Produto �
					//������������������������������������
					If (cAliasSB1)->B1_LOCPAD < mv_par07 .Or. (cAliasSB1)->B1_LOCPAD > mv_par08
						dbSkip()
						Loop
					EndIf
				EndIf

				//�����������������������������������������������������������Ŀ
				//� Direciona para funcao que calcula o necessidade de compra �
				//�������������������������������������������������������������
				//�������������������������������������������������Ŀ
				//� Calcula o saldo atual de todos os almoxarifados �
				//���������������������������������������������������
				dbSelectArea("SB2")
				dbSeek( xFilial("SB2") + (cAliasSB1)->B1_COD )
				While !Eof() .And. SB2->B2_FILIAL + SB2->B2_COD == xFilial("SB2") + (cAliasSB1)->B1_COD
					If SB2->B2_LOCAL < mv_par16 .OR. SB2->B2_LOCAL > mv_par17
						dbSkip()
						Loop
					EndIf
					//�������������������������������������������Ŀ
					//� inclui os produtos que estao no C.Q.      �
					//���������������������������������������������
					If SB2->B2_LOCAL == cLocCQ .And. mv_par11 == 2
						dbSkip()
						Loop
					EndIf
					nSaldo += (SaldoSB2(NIL,NIL,If(Empty(mv_par18),dDataBase,mv_par18),mv_par12==1,;
								mv_par13==1)+SB2->B2_SALPEDI+SB2->B2_QACLASS)
					If mv_par14 == 1
						nSaldo -= SB2->B2_QPEDVEN
					EndIf
					nPrevis += SB2->B2_SALPEDI
					dbSkip()
				EndDo

				nEstSeg := CalcEstSeg( RetFldProd((cAliasSB1)->B1_COD,"B1_ESTFOR",cAliasSB1),cAliasSB1 )
				If mv_par20 == 1
					nSaldo -= nEstSeg
				EndIf
				If (Round(nSaldo,4) # 0) .Or. (mv_par09 == 1)
					Do Case
						Case ( RetFldProd((cAliasSB1)->B1_COD,"B1_EMIN",cAliasSB1) != 0 .And. MV_PAR09 == 1 )
							If ( mv_par10 == 2 .And. nSaldo < 0 )
								nSaldo -= RetFldProd((cAliasSB1)->B1_COD,"B1_LE",cAliasSB1)
							EndIf
							
							nNeces := If((nSaldo < 0),Abs(nSaldo)+RetFldProd((cAliasSB1)->B1_COD,"B1_EMIN",cAliasSB1),;
										(If(QtdComp(nSaldo)==QtdComp(RetFldProd((cAliasSB1)->B1_COD,"B1_EMIN",cAliasSB1)),1,0);
										+RetFldProd((cAliasSB1)->B1_COD,"B1_EMIN",cAliasSB1)-nSaldo))
							
							//-- Soma 1 na quantidade da necessidade:
							//-- Ex: Ponto Pedido = 10 e Estoque = 9, ao inves de gerar 2 SCs de 1 pc ira gera 1 SC de 2 pcs
							If nSaldo <  QtdComp(RetFldProd((cAliasSB1)->B1_COD,"B1_EMIN",cAliasSB1)) //-- Se o Saldo for menor que o Ponto do Pedido
								nNeces += 1
							EndIf
							
						Case ( RetFldProd((cAliasSB1)->B1_COD,"B1_EMIN",cAliasSB1) != 0 .And. MV_PAR09 == 2 )
							If ( mv_par10 == 2 .And. nSaldo < 0 )
								nSaldo -= RetFldProd((cAliasSB1)->B1_COD,"B1_LE",cAliasSB1)
							EndIf
							
							nNeces := If((nSaldo < 0),Abs(nSaldo),;
										(If(QtdComp(nSaldo) ==  QtdComp(RetFldProd((cAliasSB1)->B1_COD,"B1_EMIN",cAliasSB1)),1,0);
										+RetFldProd((cAliasSB1)->B1_COD,"B1_EMIN",cAliasSB1)-nSaldo))
							
							//-- Soma 1 na quantidade da necessidade:
							//-- Ex: Ponto Pedido = 10 e Estoque = 9, ao inves de gerar 2 SCs de 1 pc ira gera 1 SC de 2 pcs
							If nSaldo < QtdComp(RetFldProd((cAliasSB1)->B1_COD,"B1_EMIN",cAliasSB1)) //-- Se o Saldo for menor que o Ponto do Pedido
								nNeces += 1
							EndIf
							
						Case ( RetFldProd((cAliasSB1)->B1_COD,"B1_LE",cAliasSB1) != 0 .And. (nSaldo < 0  .or. mv_par09 == 2) )
							If ( mv_par10 == 2 .And. nSaldo < 0 )
								nNeces := Abs(nSaldo)+RetFldProd((cAliasSB1)->B1_COD,"B1_LE",cAliasSB1)
							Else
								nNeces := If( Abs(nSaldo)<RetFldProd((cAliasSB1)->B1_COD,"B1_LE",cAliasSB1),RetFldProd((cAliasSB1)->B1_COD,"B1_LE",cAliasSB1),if(nSaldo<0,Abs(nSaldo),0))
							EndIf
						OtherWise
							nNeces := If(mv_par09 == 1,IIf(nSaldo<0,Abs(nSaldo)+1,0),0)
					EndCase
				Else
					If RetFldProd((cAliasSB1)->B1_COD,"B1_EMIN",cAliasSB1) != 0
						nNeces := ( RetFldProd((cAliasSB1)->B1_COD,"B1_EMIN",cAliasSB1) ) 
						nNeces += 1
					Else
						nNeces := 0
					Endif
				EndIf
				
				If nNeces > 0
					//�����������������������������������������������������������Ŀ
					//� Verifica se o produto tem estrutura                       �
					//�������������������������������������������������������������
					dbSelectArea("SG1")
					If dbSeek( xFilial("SG1")+(cAliasSB1)->B1_COD )
						aQtdes := CalcLote((cAliasSB1)->B1_COD,nNeces,"F")
					Else
						aQtdes := CalcLote((cAliasSB1)->B1_COD,nNeces,"C")
					Endif
					For nX := 1 to Len(aQtdes)
						nQuant += aQtdes[nX]
					Next
				EndIf
				                                    
				
			 if mv_par20 <> 1
					_nValAtu := 0    
					_nSaldoTMP := 0
					
					dbSelectArea("SB2")
					dbSetOrder(1)
					dbSeek( xFilial("SB2")+(cAliasSB1)->B1_COD)
					
					While !Eof() .And. SB2->B2_FILIAL + SB2->B2_COD == xFilial("SB2")+(cAliasSB1)->B1_COD
										
						If SB2->B2_LOCAL >= mv_par16  .and. SB2->B2_LOCAL <= mv_par17	
																			
					    	_nValAtu   += SB2->B2_QATU	 								// QTD ATUAL
							_nSaldoTMP += SB2->B2_SALPEDI 							// QTD PREVISTA PARA ENTREGA
					    endif                      
					   
						SB2->(dbSkip())
					EndDo
					//U__log()              
				   //	U__log(alltrim((cAliasSB1)->B1_COD) + "qatu: "  + alltrim(str(_nValAtu)) + ;
				 	// 	" - nPrev: "  + alltrim(str(_nSaldoTMP)) +;
					//	" - emin: "  + alltrim(str((cAliasSB1)->B1_EMIN)) +;
				 	//	" - estseg: " + alltrim(str((cAliasSB1)->B1_ESTSEG)))
					
					if _nValAtu < (cAliasSB1)->B1_EMIN 
						nQuant  := iif( ((cAliasSB1)->B1_ESTSEG - (_nValAtu + _nSaldoTMP)) < 0, 0,;
										((cAliasSB1)->B1_ESTSEG - (_nValAtu + _nSaldoTMP)))
						nSaldo  := _nValAtu						
						nPrevis := _nSaldoTMP
					else
						(cAliasSB1)->(dbSkip())
						Loop
					endif                  
					
					dbSelectArea(cAliasSB1)
				endif 

				dbSelectArea(cAliasSB1)
								              
				If nSaldo < (cAliasSB1)->B1_EMIN .AND. (cAliasSB1)->B1_EMIN > 0
					
					//���������������������������������������������Ŀ
					//� Pega o prazo de entrega do material         �
					//�����������������������������������������������
					nPrazo := CalcPrazo((cAliasSB1)->B1_COD,nQuant)
					dbSelectArea(cAliasSB1)
					
					//���������������������������������������������Ŀ
					//� Calcula a tolerancia do item                �
					//�����������������������������������������������
					
					If li > 55
						Cabec( titulo + " - " + aFilsCalc[ nForFilial, 3 ], cabec1, cabec2, nomeprog, Tamanho, nTipo )
					EndIf
					
					//�������������������������������������������������������Ŀ
					//� Adiciona 1 ao contador de registros impressos         �
					//���������������������������������������������������������
					nCntImpr++
					
					//���������������������������������������������������������Ŀ
					//� Verifica qual dos precos e' mais recente servir de base �
					//�����������������������������������������������������������
					If RetFldProd((cAliasSB1)->B1_COD,"B1_UCOM",cAliasSB1) < B1_DATREF
						cTipoVal := "STD"
						dData    := B1_DATREF
						nValUnit := RetFldProd((cAliasSB1)->B1_COD,"B1_CUSTD",cAliasSB1)
					Else
						cTipoVal := "U.CO"
						dData    := RetFldProd((cAliasSB1)->B1_COD,"B1_UCOM",cAliasSB1)
						nValUnit := RetFldProd((cAliasSB1)->B1_COD,"B1_UPRC",cAliasSB1)
					EndIf
					nValor := nQuant * nValUnit
					
					@ li,000 PSAY B1_COD
					@ li,016 PSAY SubStr(B1_DESC,1,30)
					@ li,047 PSAY B1_TIPO
					@ li,050 PSAY B1_GRUPO
					@ li,055 PSAY B1_UM
					@ li,058 PSAY iif(mv_par20==1,nSaldo-nPrevis,nSaldo) 			  Picture PesqPictQt("B1_LE",12)
					@ li,071 PSAY nPrevis   							 			  Picture PesqPict("SB2","B2_SALPEDI",12) //ENT PREV
					@ li,084 PSAY RetFldProd((cAliasSB1)->B1_COD,"B1_EMIN",cAliasSB1) Picture PesqPictQt("B1_EMIN",12)        //PTO PED
					@ li,097 PSAY nESTSEG   										  Picture PesqPictQt("B1_ESTSEG",12)      // EST SEG
					@ li,110 PSAY RetFldProd((cAliasSB1)->B1_COD,"B1_LE",cAliasSB1)   Picture PesqPictQt("B1_LE",12)          // LOTE EC
					@ li,123 PSAY nQuant    										  Picture PesqPictQt("B1_LE",12)
					@ li,136 PSAY nValor    										  Picture TM(nValor,16)
					@ li,153 PSAY nValUnit  										  Picture TM(nValUnit,14)
					
					nValTot += nValor
					li++
					
				EndIf
				
				nSaldo := 0
				nQuant := 0
				nPrevis:= 0
				
				dbSelectArea(cAliasSB1)
				dbSkip()
				
			EndDo
			
			If li != 80
				Li++
				@ li,000 PSAY PADR("TOTAL GERAL A COMPRAR", 135, ".")
				@ li,136 PSAY nValTot Picture TM(nValTot,16)
				Roda(nCntImpr,cRodaTxt,Tamanho)
			EndIf

		EndIf
		//��������������������������������������������������������������Ŀ
		//� Devolve a condicao original do arquivo principal             �
		//����������������������������������������������������������������
		If lQuery
			If Select(cAliasSB1) > 0
				(cAliasSB1)->(dbCloseArea())
			Endif	
		EndIf		
	Next nForFilial
	
	dbSelectArea(cString)
	dbClearFilter()
	Set Order To 1

	If aReturn[5] = 1
		Set Printer To
		dbCommitAll()
		OurSpool(wnrel)
	EndIf

	MS_FLUSH()

EndIf

// Restaura filial original apos processamento
cFilAnt:=cFilBack 

Return .T.

/*/
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Funcao    �AjustaSX1 � Autor � Nereu Humberto Jr     � Data �01.08.2005���
�������������������������������������������������������������������������Ĵ��
���Descricao �Cria as perguntas necesarias para o programa                ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function AjustaSX1()

Local aHelpPor :={ }
Local aHelpEng :={ }
Local aHelpSpa :={ }

PutSX1("MTR440","14","Qtd. PV nao Liberado ?","Ctd. PV no Liberado ?","Qt So Not Relesead ?","mv_che","N",01,0,1,"C","","","","","mv_par14","Subtrae","Resta","Subtract","","Ignora","Ignora","Ignore","","","","","","","","","")

Aadd( aHelpPor, "Informar se a quantidade do pedido de   " )
Aadd( aHelpPor, "venda n�o liberado dever� ser subtra�do " )
Aadd( aHelpPor, "ou ignorado.                            " )

Aadd( aHelpEng, "Enter if the quantity of the sales order" )
Aadd( aHelpEng, " not released must be substracted or    " )
Aadd( aHelpEng, "ignored.                                " )

Aadd( aHelpSpa, "Informar si la cantidad de pedido de    " )
Aadd( aHelpSpa, "venta no liberado debera ser substraido " )
Aadd( aHelpSpa, "o ignorado.                             " )

PutSX1Help("P.MTR44014.",aHelpPor,aHelpEng,aHelpSpa)

//-------------------------------------------------------------------------------------------------------------------------------//
aHelpPor :={ }
aHelpEng :={ }
aHelpSpa :={ }
Aadd( aHelpPor, "Informar se a impressao da descricao do " )
Aadd( aHelpPor, "produto sera reduzida ou completa.      " )

Aadd( aHelpEng, "Enter if the printout of the product des" )
Aadd( aHelpEng, "cription will be summarized or complete." )

Aadd( aHelpSpa, "Informar si la impresion de descripcion " )
Aadd( aHelpSpa, "del producto sera reducida o completa.  " )

PutSx1( "MTR440","15","Descricao completa produto ?","�Descripcion completa pdcto. ?","Full product description ?","mv_chf",;
	"N",1,0,1,"C","","","","","mv_par15","Nao","No","No","","Sim","Si","Yes","","","","","","","","","")
PutSX1Help("P.MTR44015.",aHelpPor,aHelpEng,aHelpSpa)

//-------------------------------------------------------------------------------------------------------------------------------//
aHelpPor :={ }
aHelpEng :={ }
aHelpSpa :={ }

aAdd( aHelpPor, "Armazem inicial a ser considerado na    " )
aAdd( aHelpPor, "filtragem do Cadastro de Saldos (SB2).  " )

aAdd( aHelpEng, "To filter stock from initial            " )
aAdd( aHelpEng, "warehouse (SB2).                        " )

aAdd( aHelpSpa, "Filtrar Saldo Deposito inicial (SB2).   " )
aAdd( aHelpSpa, "                                        " )

PutSX1("MTR440","16","Considera Saldo Armazem de", "Consd. Deposito de","Cons. Warehouse from","mv_chg",;
	"C",2,0,1,"G","","","","","mv_par16","","","","","","","","","","","","","","","","")
PutSX1Help("P.MTR44016.",aHelpPor,aHelpEng,aHelpSpa)
//-------------------------------------------------------------------------------------------------------------------------------//
aHelpPor :={ }
aHelpEng :={ }
aHelpSpa :={ }

aAdd( aHelpPor, "Armazem final a ser considerado na      " )
aAdd( aHelpPor, "filtragem do Cadastro de Saldos (SB2).  " )

aAdd( aHelpEng, "To filter stock from final              " )
aAdd( aHelpEng, "warehouse (SB2).                        " )

aAdd( aHelpSpa, "Filtrar Saldo Deposito final (SB2).     " )
aAdd( aHelpSpa, "                                        " )

PutSX1("MTR440","17","Considera Saldo Armazem ate","Consd. Deposito a", "Cons. Warehouse to","mv_chh",;
	"C",2,0,1,"G","","","","","mv_par17","","","","ZZ","","","","","","","","","","","","")
PutSX1Help("P.MTR44017.",aHelpPor,aHelpEng,aHelpSpa)
//-------------------------------------------------------------------------------------------------------------------------------//
aHelpPor :={ }
aHelpEng :={ }
aHelpSpa :={ }

Aadd( aHelpPor, "Informe a data limite para empenhos.    " )
Aadd( aHelpPor, "                                        " )

Aadd( aHelpEng, "Limit date for allocations.             " )
Aadd( aHelpEng, "                                        " )

Aadd( aHelpSpa, "Fecha limite para reservas.             " )
Aadd( aHelpSpa, "                                        " )

PutSX1("MTR440","18","Data Limite para Empenho ? ","Fch.Limite p/ Res.Produccion", "Deadline to Allocat. ?","mv_chi",;
	"D",8,0,0,"G","","","","","mv_par18","","","","","","","","","","","","","","","","")
PutSX1Help("P.MTR44018.",aHelpPor,aHelpEng,aHelpSpa)   

PutSx1("MTR440", ;   	                            //-- 01 - X1_GRUPO
	'19' , ;                                        //-- 02 - X1_ORDEM
	'Seleciona Filiais ?', ;           				//-- 03 - X1_PERGUNT
	'�Selecciona Sucursales?', ;       				//-- 04 - X1_PERSPA
	'Select branch offices?', ;        				//-- 05 - X1_PERENG
	'mv_chj', ;                                     //-- 06 - X1_VARIAVL
	'N', ;                                          //-- 07 - X1_TIPO
	1, ;                                            //-- 08 - X1_TAMANHO
	0, ;                                            //-- 09 - X1_DECIMAL
	2, ;                                            //-- 10 - X1_PRESEL
	'C', ;                                          //-- 11 - X1_GSC
	'', ;                                           //-- 12 - X1_VALID
	'', ;                                           //-- 13 - X1_F3
	'', ;                                           //-- 14 - X1_GRPSXG
	'', ;                                           //-- 15 - X1_PYME
	'mv_par19', ;                                   //-- 16 - X1_VAR01
	'Sim' , ;                           			//-- 17 - X1_DEF01
	'Si', ; 	                           			//-- 18 - X1_DEFSPA1
	'Yes', ;                            			//-- 19 - X1_DEFENG1
	'', ;                                           //-- 20 - X1_CNT01
	'Nao', ;                            			//-- 21 - X1_DEF02
	'No', ;	                            			//-- 22 - X1_DEFSPA2
	'No', ; 	                           			//-- 23 - X1_DEFENG2
	'', ;                             				//-- 24 - X1_DEF03
	'', ;                             				//-- 25 - X1_DEFSPA3
	'', ;                             				//-- 26 - X1_DEFENG3
	'', ;                                           //-- 27 - X1_DEF04
	'', ;                                           //-- 28 - X1_DEFSPA4
	'', ;                                           //-- 29 - X1_DEFENG4
	'', ;                                           //-- 30 - X1_DEF05
	'', ;                                           //-- 31 - X1_DEFSPA5
	'', ;                                           //-- 32 - X1_DEFENG5
	{'Seleciona as filiais desejadas. Se NAO', ;	//-- 33 - HelpPor1#3
	 'apenas a filial corrente sera afetada.', ; 	//--      HelpPor2#3
	 '                                        '}, ;	//--      HelpPor3#3
	{'Selecciona las sucursales deseadas. Si', ; 	//-- 34 - HelpPor1#3
	 'NO solamente la sucursal actual es', ;  		//--      HelpPor2#3
	 'afectado.'}, ; 								//--      HelpPor3#3
	{'Select desired branch offices. If NO', ;  	//-- 35 - HelpPor1#3                                             	
	 'only current branch office will be', ; 	 	//--      HelpPor2#3
	 'affected.'}, ;								//--      HelpPor3#3
	 '')                                            //-- 36 - X1_HELP

PutSx1("MTR440", "20", "Considera Est. Seguranca ?", "�Considera stock de la segu. ?", "It considers Security Inv. ?", "mv_chk", "N", 1, 0, 1, "C","","","","","mv_par20", "Sim"    , "Si"       , "Yes"       , "", "Nao"       , "No"        , "No"        ,"","","","","","","","","",;
		{"Define se o Estoque de Seguran�a ","informado no Cadastro de Produtos, ","ser� considerado para o c�lculo ","das necessidades."}, ;
		{"It defines if the Security Inventory ","informed in I register in cadastre it ","of products, will be considered for ","the calculation of the necessities."}, ;
		{"Define si el Stock de la Seguridad me ","inform� adentro lo coloca en cadastre","de productos, es considerado para","el c�lculo de las necesidades."})

Return
