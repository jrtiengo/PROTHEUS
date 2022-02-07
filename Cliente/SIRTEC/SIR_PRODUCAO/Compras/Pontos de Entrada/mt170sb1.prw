/* 
 * Ponto de entrada na gera��o da solicita��o de compras por ponto de pedido  
 * retorna .T. se o pedido deve gerar solicita��o    
 * Daniela Maria Uez - 08/07/2010
 */

user function MT170SB1	
 	Local aAreaSB2 := SB2->(GetArea())
	Local aAreaSB1 := SB1->(GetArea())     
	local	_lRet  := .t. 
 	local _cAlias  := paramixb[1]
		                    
	//u_showtrb((_cAlias))		                              
	//if mv_par21 <> 1           
		//�������������������������������������������������Ŀ
		//� Calcula o saldo atual de todos os almoxarifados �
		//���������������������������������������������������
		dbSelectArea("SB2")
		dbSetOrder(1)
		dbSeek( xFilial("SB2") + (_cAlias)->B1_COD, .T.)
		_nValAtu := 0    
		_nSaldoTMP := 0  
		
		While !Eof() .And. SB2->B2_FILIAL + SB2->B2_COD == xFilial("SB2")+(_cAlias)->B1_COD
			//#31541 Estava dando erro de typemismatch, pegando as perguntas 16 e 17. Correto � 17 e 18. Mauro - Solutio. 25/01/2022.
			If SB2->B2_LOCAL >= mv_par17   .AND. SB2->B2_LOCAL <= mv_par18 
			// If SB2->B2_LOCAL >= mv_par16   .AND. SB2->B2_LOCAL <= mv_par17   
			
		    	_nValAtu += SB2->B2_QATU	 
				_nSaldoTMP += SB2->B2_SALPEDI 
		    endif 
			SB2->(dbSkip())
		EndDo
	
 		IF ((_cAlias)->B1_EMIN <= (_nSaldoTMP + _nValAtu) .or. (_cAlias)->B1_EMIN<=0 )
 			_lRet := .F.	                                                                                                
 		else
 			_lRet := .T.
		endif     
	
	//endif 	
 	
 	RestArea(aAreaSB2)
	RestArea(aAreaSB1)
return _lRet
