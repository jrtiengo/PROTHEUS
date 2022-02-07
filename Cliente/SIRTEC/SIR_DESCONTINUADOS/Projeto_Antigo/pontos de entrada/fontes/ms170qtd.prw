/* 
 * Ponto de entrada na geração da solicitação de compras por ponto de pedido  
 * define a quantidade da solicitação
 * Daniela Maria Uez - 08/07/2010
 */

user function MS170QTD
	Local _nQtd := PARAMIXB
	Local aAreaSB2 := SB2->(GetArea())
	Local aAreaSB1 := SB1->(GetArea())     
	
	if mv_par21 <> 1           
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Calcula o saldo atual de todos os almoxarifados ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SB2")
		dbSetOrder(1)
		dbSeek( xFilial("SB2") + SB1->B1_COD, .T.)
		_nValAtu 	:= 0    
		_nSaldoTMP 	:= 0  
		
		While !Eof() .And. SB2->B2_FILIAL + SB2->B2_COD == xFilial("SB2")+SB1->B1_COD
			
			If SB2->B2_LOCAL >= mv_par17   .AND.  SB2->B2_LOCAL <= mv_par18    
			
		    	_nValAtu	+= B2_QATU	 
				_nSaldoTMP 	+= SB2->B2_SALPEDI 
		    endif 
			SB2->(dbSkip())
		EndDo                                                 
		                                 
		//U__log("QTD:" + SB1->B1_COD + "-> Saldotmp: "  + alltrim(str(_nSaldoTMP)) + " : vatu: " +;
		//			alltrim(str(_nValAtu)) + " : emin: " + alltrim(str(SB1->B1_EMIN)))    	
			
		IF(SB1->B1_EMIN > (_nSaldoTMP + _nValAtu))	
			_nQtd := SB1->B1_ESTSEG - (_nValAtu + _nSaldoTMP)
		Endif 	
	
	endif 	
 	                     
	RestArea(aAreaSB2)
	RestArea(aAreaSB1)
            
return _nQtd