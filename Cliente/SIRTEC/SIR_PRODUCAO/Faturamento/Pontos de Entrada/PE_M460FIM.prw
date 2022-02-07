#INCLUDE "Totvs.ch"

/*---------------------------------------------------------------------------
-----------------------------------------------------------------------------
|| Funcao    | U_M460FIM | Autor | Gregory Araujo     | Data 12/02/2019    ||
||-------------------------------------------------------------------------||
|| Descricao | Ponto de entrada na geracao da nota fiscal de saida para    ||
||           | gerar parcela de cau��o para a data final do contrato       ||
||-------------------------------------------------------------------------||
|| Parametros|                                                             ||
||-------------------------------------------------------------------------||
|| Retorno   |                                                             ||
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/     
User Function M460Fim()
	
	Local cAreaAnt := Alias()
	Local aAreaSD2 := SD2->(getArea())
	Local aAreaSF2 := SF2->(getArea())
	Local aAreaSC5 := SC5->(getArea())
	Local aAreaSC9 := SC9->(getArea())
	Local aAreaSE1 := SE1->(getArea())   
	Local aAreaSA1 := SA1->(getArea())
	Local aDuplic	:= {}
	Local cCondTp	:= ''
	Local dDtContr	:= dDataBase
	Local dDtVenCnt	:= dDataBase      
	
	// Valida a empresa 02, que n�o possui o campo A1_DTCONTR. Basta adicionar outras empresa, no caso de novos problemas.
	// Mauro -  Solutio. 25/06/2019.
	If cEmpAnt <> "02"
	
		//Posiciona-se na tabela de condi��es de pagamento, pois PE s� ser� executado para condi��es do tipo 8.
		dbSelectArea("SE4")
		dbSetOrder(1)
		dbSeek(xFilial("SE4")+SC5->C5_CONDPAG)
		cCondTp := SE4->E4_TIPO
		 
		If cCondTp == '8'
			
			//Posiciona-se na tabela de titulos para buscar a ultima duplicata gerada.
			dbSelectArea('SE1')
			dbSetOrder(2) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
			If dbSeek( SF2->F2_FILIAL + SF2->F2_CLIENT + SF2->F2_LOJA + SF2->F2_PREFIXO + SF2->F2_DOC ) 
				
				While SF2->F2_PREFIXO == SE1->E1_PREFIXO .AND. SF2->F2_DOC == SE1->E1_NUM
					aAdd(aDuplic, {SE1->E1_FILIAL, SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO})
					SE1->(dbSkip())
				EndDo
				
			EndIf
			
		EndIf
		
		//Busca-se na tabela de cliente o campo CUSTOMIZADO de data final do contrato, caso n�o estiver vazio, altera a data da duplicata
		dbSelectArea('SA1')
		dbSetOrder(1)
		dbSeek(xFilial("SA1") + SC5->C5_CLIENT)
		If !Empty( SA1->A1_DTCONTR )
			dDtContr := A1_DTCONTR
			
			dbSelectArea('SE1')
			dbSetOrder(1) // E1_FILIAL, E1_PREFIXO, E1_NUM, E1_PARCELA, E1_TIPO, R_E_C_N_O_, D_E_L_E_T_
			If dbSeek( aTail(aDuplic)[1] + aTail(aDuplic)[2] + aTail(aDuplic)[3] + aTail(aDuplic)[4] + aTail(aDuplic)[5] ) 
				dDtVenCnt := ProcVenc(dDtContr)   
				If RecLock("SE1", .F.)
					SE1->E1_VENCTO := dDtContr
					SE1->E1_VENCREA := dDtVenCnt
					MsUnlock()
				EndIf
			EndIf
			
		EndIf
	
	EndIf
	
	// Restaura ambiente
	RestArea(aAreaSD2)
	RestArea(aAreaSF2)
	RestArea(aAreaSC5)
	RestArea(aAreaSC9)   
	RestArea(aAreaSE1)
	RestArea(aAreaSA1)  
	dbSelectArea(cAreaAnt)

Return
        
/*---------------------------------------------------------------------------
-----------------------------------------------------------------------------
|| Funcao    | ProcVenc  | Autor | Gregory.solutio    | Data |28/09/2017   ||
||-------------------------------------------------------------------------||
|| Descricao | De acordo com regra de neg�cio da empresa, as datas de pagto||
||           | dever�o ser sempre nas ter�as e quintas                     ||
-----------------------------------------------------------------------------
---------------------------------------------------------------------------*/                               
Static Function ProcVenc(dDtContr)
    
	Local nDoW := 0
	
	dDtContr := DataValida(dDtContr)
	nDoW := DoW(dDtContr)

	If nDoW > 0 //se a dat n�o estiver vazia
	
		If nDoW < 3 //Caso a data seja anterior � ter�a feira
			dDtContr := dDtContr + ( 3 - nDow) //recebe a diferen�a de dias at� ter�a feira;		
		EndIf
		
		If nDow == 4 //Caso seja quarta feira
			dDtContr := dDtContr + 1 // Deixa-se o vencimento para quinta feira
		EndIf
		
		If nDow > 5 //caso seja posterior � quinta feira
			dDtContr := dDtContr + ( 7-nDow + 3) //recebe a diferen�a de dias at� a pr�xima ter�a feira;
		EndIf
		
	EndIf
	                                    
	//Caso a data resultante do c�lculo para ter�a ou quinta feira seja um feriado, chama a fun��o novamente passando um dia a mais
	If dDtContr <> DataValida(dDtContr) 
		dDtContr := ProcVenc(dDtContr+1) 
	EndIf
	
Return(dDtContr)              
