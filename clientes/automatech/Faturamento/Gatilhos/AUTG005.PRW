#include "protheus.ch"
#include "topconn.ch"

User Function xMaTesInt(nEntSai,cTpOper,cClieFor,cLoja,cTipoCF,cProduto,cCampo)

Local aArea		:= GetArea()
Local aAreaSA1	:= SA1->(GetArea())
Local aAreaSA2	:= SA2->(GetArea())
Local aAreaSB1	:= SB1->(GetArea())
Local aTes 		:= {}
Local aDadosCfo := {} 
Local cTesRet	:= "   "
Local cGrupo	:= ""
Local cGruProd	:= ""
Local cQuery	:= ""  
Local cProg     := "MT100"
Local cNCM      := ""
Local cEstado   := ""
Local cAliasSFM := "SFM"         
Local cTabela   := ""
Local lQuery	:= .F.
Local nPosCpo	:= 0
Local nPosCfo   := 0

DEFAULT cTpOper  := &(ReadVar())
DEFAULT cClieFor := ""
DEFAULT cProduto := ""
DEFAULT nEntSai  := 0
DEFAULT cTipoCF  := "C"
DEFAULT cCampo	  := ""

If !Empty(cCampo)
	nPosCpo	:= aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim(cCampo) })
	cTabela  := aHeader[nPosCpo,9]
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o grupo de tributacao do cliente/fornecedor         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(IIf(cTipoCF == "C","SA1","SA2"))
dbSetOrder(1)
MsSeek(xFilial()+cClieFor+cLoja)
If cTipoCF == "C"
	cGrupo  := SA1->A1_GRPTRIB
	cEstado := SA1->A1_EST
Else
	cGrupo  := SA2->A2_GRPTRIB
	cEstado := SA2->A2_EST
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o grupo do produto                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SB1")
dbSetOrder(1)
MsSeek(xFilial("SB1")+cProduto)
cGruProd := SB1->B1_GRTRIB
cNCM     := SB1->B1_POSIPI
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa por todas as regras validas para este caso          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
	lQuery := .T.
	cAliasSFM := GetNextAlias() 
	cQuery += "SELECT * FROM " + RetSqlName("SFM") + " SFM "
	cQuery += "WHERE SFM.FM_FILIAL = '" + xFilial("SFM") + "'"
	cQuery += "AND SFM.FM_TIPO = '" + cTpOper + "'"
	cQuery += "AND SFM.D_E_L_E_T_=' ' "
	cQuery += "ORDER BY "+SqlOrder(SFM->(IndexKey()))
	cQuery := ChangeQuery(cQuery)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasSFM,.T.,.T.)
#ELSE
	dbSelectArea("SFM")
	dbSetOrder(1)
	MsSeek(xFilial("SFM")+cTpOper)
#ENDIF
While !Eof() .And. (cAliasSFM)->FM_TIPO==cTpOper
	
	If cTipoCF == "C" 
		If  ( 	Empty(	(cAliasSFM)->FM_PRODUTO;
		               +(cAliasSFM)->FM_CLIENTE;
		               +(cAliasSFM)->FM_LOJACLI;
		               +(cAliasSFM)->FM_GRTRIB;
		               +(cAliasSFM)->FM_GRPROD;
		               +IIf(SFM->(FieldPos("FM_POSIPI"))<>0,(cAliasSFM)->FM_POSIPI,"");
		               +IIf(SFM->(FieldPos("FM_EST"))<>0,(cAliasSFM)->FM_EST,"");
		              ) .Or.;
		               ((	(cAliasSFM)->FM_PRODUTO == cProduto .Or. Empty((cAliasSFM)->FM_PRODUTO)) ;
						.And. (Alltrim(cGruProd) == Alltrim((cAliasSFM)->FM_GRPROD) .Or. Empty((cAliasSFM)->FM_GRPROD));
						.And. (cClieFor+cLoja == (cAliasSFM)->FM_CLIENTE+(cAliasSFM)->FM_LOJACLI .Or. Empty((cAliasSFM)->FM_CLIENTE+(cAliasSFM)->FM_LOJACLI));
						.And. (cGrupo == (cAliasSFM)->FM_GRTRIB .Or. Empty((cAliasSFM)->FM_GRTRIB));
						.And. (SFM->(FieldPos("FM_EST"))==0 .Or. cEstado == (cAliasSFM)->FM_EST .Or. Empty((cAliasSFM)->FM_EST));
						.And. (SFM->(FieldPos("FM_POSIPI"))==0 .Or. cNCM == (cAliasSFM)->FM_POSIPI .Or. Empty((cAliasSFM)->FM_POSIPI)       ));
		     )
			 			 
			aadd(aTes, {(cAliasSFM)->FM_PRODUTO,;
				 (cAliasSFM)->FM_GRPROD,;
				 IIf(SFM->(FieldPos("FM_POSIPI"))<>0,(cAliasSFM)->FM_POSIPI,""),;
				 (cAliasSFM)->FM_CLIENTE,;
				 (cAliasSFM)->FM_LOJACLI,;
				 (cAliasSFM)->FM_GRTRIB,;
				 IIf(SFM->(FieldPos("FM_EST"))<>0,(cAliasSFM)->FM_EST,""),;
				 (cAliasSFM)->FM_TE,;
				 (cAliasSFM)->FM_TS})
				
		EndIf
	Else
		If (Empty((cAliasSFM)->FM_PRODUTO+(cAliasSFM)->FM_FORNECE+(cAliasSFM)->FM_LOJAFOR+(cAliasSFM)->FM_GRTRIB+(cAliasSFM)->FM_GRPROD+IIf(SFM->(FieldPos("FM_POSIPI"))<>0,(cAliasSFM)->FM_POSIPI,"")+IIf(SFM->(FieldPos("FM_EST"))<>0,(cAliasSFM)->FM_EST,"")) .Or.;
			(((cAliasSFM)->FM_PRODUTO == cProduto .Or. Empty((cAliasSFM)->FM_PRODUTO)) .And.;
			 (Alltrim(cGruProd) == Alltrim((cAliasSFM)->FM_GRPROD) .Or. Empty((cAliasSFM)->FM_GRPROD)) .And.;
			 (cClieFor+cLoja == (cAliasSFM)->FM_FORNECE+(cAliasSFM)->FM_LOJAFOR .Or. Empty((cAliasSFM)->FM_FORNECE+(cAliasSFM)->FM_LOJAFOR)) .And.;
			 (cGrupo == (cAliasSFM)->FM_GRTRIB .Or. Empty((cAliasSFM)->FM_GRTRIB)) .And.;
			 (SFM->(FieldPos("FM_EST"))==0 .Or. cEstado == (cAliasSFM)->FM_EST .Or. Empty((cAliasSFM)->FM_EST)) .And.;	
			 (SFM->(FieldPos("FM_POSIPI"))==0 .Or. cNCM == (cAliasSFM)->FM_POSIPI .Or. Empty((cAliasSFM)->FM_POSIPI))))
			 			 
			aadd(aTes,{(cAliasSFM)->FM_PRODUTO,;
					(cAliasSFM)->FM_GRPROD,;
					IIf(SFM->(FieldPos("FM_POSIPI"))<>0,(cAliasSFM)->FM_POSIPI,""),;
					(cAliasSFM)->FM_FORNECE,;
					(cAliasSFM)->FM_LOJAFOR,;
					(cAliasSFM)->FM_GRTRIB,;
					 IIf(SFM->(FieldPos("FM_EST"))<>0,(cAliasSFM)->FM_EST,""),;
					(cAliasSFM)->FM_TE,;
					(cAliasSFM)->FM_TS})
			
		EndIf
	EndIf
	dbSelectArea(cAliasSFM)
	dbSkip()
EndDo
If ( lQuery )
	dbSelectArea(cAliasSFM)
	dbCloseArea()
	dbSelectArea("SFM")
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Pesquisa por todas as regras validas para este caso          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSort(aTES,,,{|x,y| x[1]+x[2]+x[3]+x[4]+x[5]+x[6]+x[7] > y[1]+y[2]+y[3]+y[4]+y[5]+x[6]+x[7]})
If Len(aTes) <> 0
	cTesRet := If(nEntSai==1,aTes[1][8],aTes[1][9])
EndIf
If nPosCpo > 0 .And. !Empty(cTesRet) .And. Type('aCols') <> "U"
	aCols[n][nPosCpo] := cTesRet
	Do Case
		Case cTabela == "SD1"
			nPosCfo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("D1_CF") })
		Case cTabela == "SD2"
			nPosCfo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("D2_CF") })
		Case cTabela == "SC6"     
			dbSelectArea("SF4")
			dbSetOrder(1)
			nPosCfo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("C6_CF") })
			If nPosCfo > 0 .And. MsSeek(xFilial("SF4")+cTesRet)
				aDadosCfo := {} 
			 	AAdd(aDadosCfo,{"OPERNF","S"})
			 	AAdd(aDadosCfo,{"TPCLIFOR",If(cTipoCF == "C", SA1->A1_TIPO , SA2->A2_TIPO )})
			 	AAdd(aDadosCfo,{"UFDEST"  ,If(cTipoCF == "C", SA1->A1_EST  , SA2->A2_EST  )})
			 	AAdd(aDadosCfo,{"INSCR"   ,If(cTipoCF == "C", SA1->A1_INSCR, SA2->A2_INSCR)})
				aCols[n][nPosCfo] := U_MaFisCfo( ,SF4->F4_CF,aDadosCfo ) 
			EndIf
			nPosCfo := 0      
		Case cTabela == "SC7"
			cProg := "MT120"
		Case cTabela == "SC8"
			cProg := "MT150"
		Case cTabela == "SUB"
			nPosCfo := aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim("UB_CF") })
			cProg := "TK273"
	EndCase
	If nPosCfo > 0
		aCols[n][nPosCfo] := Space(Len(aCols[n][nPosCfo]))
	EndIf
	If MaFisFound("IT",N)
		MaFisAlt("IT_TES",cTesRet,n)
		MaFisRef("IT_TES",cProg,cTesRet)
	EndIf
EndIf
If !Empty(cTesRet)
	dbSelectArea("SF4")
	If MsSeek(xFilial("SF4")+cTesRet)
		If !RegistroOK("SF4")
			cTesRet := Space(Len(cTesRet))
		EndIf
	EndIf
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Restaura a integridade da rotina                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RestArea(aAreaSA2)
RestArea(aAreaSA1)
RestArea(aAreaSB1)
RestArea(aArea)

Return(cTesRet)     

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ MaFisCFO ³ Autor ³ Edson Maricate        ³ Data ³13.12.1999³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Processa o Codigo Fiscal do item especificado               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ExpC1 := MaFisCFO(ExpN1,ExpC2,[ExpA1])                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpN1: Item                                                 ³±±
±±³          ³ExpC2: Codigo Fiscal Original ( Opcional )                  ³±±
±±³          ³ExpA1: Array de parametros opcional a ser enviado quando    ³±±
±±³          ³a funcao e chamada de fora da matxfis. Estrutura:           ³±±
±±³          ³  1 - Identificador do parametro ( mnemonico )              ³±±
±±³          ³  2 - Conteudo                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpC1: Codigo Fiscal de Operacao                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function MaFisCFO(nItem,cAuxCF,aDados)
Local cCfo	:= IIf(cAuxCF==Nil,aTes[TS_CF],cAuxCF)
Local cRetCF:= ""

Local cOperNf   := ""
Local cTpCliFor := ""
Local cUfOrigem := ""
Local cUfDest   := ""
Local cTpComp   := ""
Local cInscri   := ""
Local cRestoCfo := "" 

Local lInscrito := .T. 

Local nLoop     := 0	// controle de loop
Local lUsaCfps	:= GetNewPar("MV_USACFPS",.F.)

If ValType( aDados ) == "A"
	cUfOrigem   := SuperGetMv("MV_ESTADO")
	cUfDest     := SuperGetMv("MV_ESTADO")
	For nLoop := 1 To Len( aDados )
		Do Case
		Case aDados[ nLoop, 1 ] == "OPERNF"
			cOperNF   := aDados[ nLoop, 2 ]		
		Case aDados[ nLoop, 1 ] == "TPCLIFOR"
			cTpCliFor := aDados[ nLoop, 2 ]				
		Case aDados[ nLoop, 1 ] == "UFORIGEM"
			cUfOrigem := aDados[ nLoop, 2 ]
		Case aDados[ nLoop, 1 ] == "UFDEST"
			cUfDest   := aDados[ nLoop, 2 ]
		Case aDados[ nLoop, 1 ] == "TPCOMP"					
			cTpComp   := aDados[ nLoop, 2 ]	
		Case aDados[ nLoop, 1 ] == "INSCR"
 			cInscri   := aDados[ nLoop, 2 ]
 			lInscrito := !(Empty(cInscri).OR."ISENT" $ cInscri)
		EndCase	
	Next nLoop

Else	
	cOperNf     := aNfCab[NF_OPERNF]
	cTpCliFor   := aNfCab[NF_TPCLIFOR]
	cUfOrigem   := aNfCab[NF_UFORIGEM]
	cUfDest     := aNfCab[NF_UFDEST]
	cTpComp     := aNfCab[NF_TPCOMP]
	lInscrito   := !( aNfCab[NF_LINSCR] ) 	
EndIf 

cRestoCfo := SubStr(cCfo,2,Len(cCfo)-1)

If cPaisLoc=="BRA"
	If SubStr(cCfo,1,3) == "999" .OR. SubStr(cCfo,1,3) == "000" .OR. SubStr(cCfo,1,4) $ "1601#1602#5601#5602"
		cRetCF := cCfo
	Else
		If cOperNf == "E"
			If cUfOrigem == "EX" .OR. cTpCliFor == "X"
				cRetCF := "3"
			Else
				If cUfOrigem == SuperGetMv("MV_ESTADO")
					cRetCF := "1"
				Else
					cRetCF := "2"
				EndIf
			EndIf
		Else
			If cUfDest == cUfOrigem .AND. cTpCliFor <> "X"
				cRetCF := "5"
				If GetNewPar( "MV_CONVCFO", "1" ) == "1"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Caso seja operacao com consumidor final troca a terminacao ³
				//³ do CFOP                                                    ³				
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ					
				If (cTpCliFor == "F" .OR. !lInscrito) .AND. AllTrim( cRestoCfo ) == "655"
						cRestoCfo := "656" + Space( Len( cRestoCfo ) - 3 )
					EndIf
				EndIf
			ElseIf cTpCliFor <> "X"
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Conversao do CFO interestadual                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cRetCF := "6"			
				If GetNewPar( "MV_CONVCFO", "1" ) == "1"
					If !lInscrito
						If AllTrim( cRestoCfo ) == "102"
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Caso seja operacao interestadual para nao inscritos        ³
							//³ altera o final do CFO de 102 para 108                      ³				
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cRestoCfo := "108" + Space( Len( cRestoCfo ) - 3 )
						ElseIf AllTrim( cRestoCfo ) == "101"
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Caso seja operacao interestadual para nao inscritos        ³
							//³ altera o final do CFO de 101 para 107                      ³				
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cRestoCfo := "107" + Space( Len( cRestoCfo ) - 3 )
						ElseIf AllTrim( cRestoCfo ) == "106"
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³ Caso seja operacao interestadual para nao inscritos        ³
							//³ altera o final do CFO de 106 para 108                      ³				
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							cRestoCfo := "108" + Space( Len( cRestoCfo ) - 3 )
						EndIf					
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Caso seja operacao com consumidor final troca a terminacao ³
					//³ do CFOP                                                    ³				
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If (cTpCliFor == "F" .OR. !lInscrito) .AND. AllTrim( cRestoCfo ) == "655"
						cRestoCfo := "656" + Space( Len( cRestoCfo ) - 3 )
					EndIf
				EndIf
			Else
				cRetCF := "7"
			EndIf
		EndIf
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Tratamento para Complemento de Frete                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cTpComp == "F" .AND. GetNewPar( "MV_CONVCFO", "1" ) == "1"
			cRetCF += IIf(SubStr(cCfo,2,3)$"931/932/933/351/352/353/354/355/356",SubStr(cCfo,2,3),"352")	
		Else
			cRetCF += cRestoCfo 
		EndIf
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ajuste do CFO para fora do estado quando for 4 digitos     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Left(cRetCf,4) == "6405" .AND. GetNewPar( "MV_CONVCFO", "1" ) == "1"
		cRetCf := "6404"+SubStr(cRetCf,5)
	EndIf
	If lUsaCfps .AND. Left(LTrim(cCfo),1)=="9"
		cRetCf := "9"+cRestoCfo 
	EndIf
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica os CFOPS de Importacao e Exportacao.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SubStr(cRetCF,1,2) == "79"
		SX5->(dbSetOrder(1))
		If !SX5->(MsSeek(xFilial("SX5")+"13"+cRetCF))
			cRetCf := "7949"
		EndIf
	EndIf
	
Else
	cRetCF:=Alltrim(cCfo)
EndIf

If ValType( aDados ) <> "A"
	aNfItem[nItem][IT_CF]	:= PadR(cRetCF,Len(SF4->F4_CF))
Endif	

Return ( cRetCF )


