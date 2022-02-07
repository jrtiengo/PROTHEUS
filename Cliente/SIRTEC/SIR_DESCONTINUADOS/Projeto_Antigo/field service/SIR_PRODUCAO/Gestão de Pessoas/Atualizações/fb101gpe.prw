#INCLUDE "PROTHEUS.CH"
#INCLUDE "TopConn.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ fb101gpe ³ Autor ³ Daniela Maria Uez     ³ Data ³05/08/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Rotina para envio do workflow avisando dos funcionário que ³±±
±±³          ³ estão próximo do vencimento do segundo período de férias.  ³±±
±±³          ³ Conforme documento MIT044 - especificacao_de_personalizacao³±±
±±³          ³_sirtec_Workflow_ferias.doc de 05/08/2010                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Objetivo  ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

user function fb101gpe  
	Local _mMes := SuperGetMv( "ML_MESWORK",  .F., "00" )    
	Local _cFol := SuperGetMv( "MV_FOLMES",  .F., "000000" )      
	                                               
	_mMes := iif(_mMes == "12", "00", _mMes)
	// se a folha foi fechada, no parâmetro vai ter os dados desse mês.  
	// pode rodar então.
	_dAT := strzero(year(date()),4) + strzero(month(date()),2)
	 
  	if _cFol <> "000000" .and._cFol == _dAT .and. val(_mMes) < month(date()) 
		Processa( {|| _workgpe() }, "Aguarde...", "Buscando dados das férias dos funcionários... ",.F.)
		PutMv("ML_MESWORK",strzero(month(date()),2))
 	endif 
	
return 

static Function _workgpe
	Local _usrRH    := SuperGetMv( "ML_FUNCRH",  .F., "" )  
	Local _usrGer	:= SuperGetMv( "ML_FUNCGER", .F., "" )    
	
	_aMais25 := {}
	                         
	oProcess := nil
	
	_cEmailRH  := ""           
	_cEmailGer := ""	
  	
  	while len(_usrRH) >= 6		// tem que ter no mínimo 6 caracteres
  		
  		// Procura o endereço de email do usuário que fez o cadastro para enviar o email a partir dele
	  	PswOrder(1)
		PswSeek(substr(_usrRH, 1, 6)) // pega os 6 caracteres referentes ao código do usuário
		aDadosUsu := PswRet() // Retorna vetor com informações do usuário
		  		                
  		if len(_cEmailRH) > 0
  			_cEmailRH += ","
  		endif 
  		_cEmailRH += alltrim(aDadosUsu[1][14])
  		
  		if len(_usrRH)> 7 // 6 caracteres do usuário + vírgula
  			_usrRH := substr(_usrRH,8)
  		else           
  			_usrRH := ""		// Senão não tem mais usuário
  		endif 	
  	enddo      
  	
  	
  	// busca emails dos 
  	while len(_usrGer) >= 6		// tem que ter no mínimo 6 caracteres
  		
  		// Procura o endereço de email do usuário que fez o cadastro para enviar o email a partir dele
	  	PswOrder(1)
		PswSeek(substr(_usrGer, 1, 6)) // pega os 6 caracteres referentes ao código do usuário
		aDadosUsu := PswRet() // Retorna vetor com informações do usuário
		  		                
  		if len(_cEmailGer) > 0
  			_cEmailGer += ","
  		endif 
  		_cEmailGer += alltrim(aDadosUsu[1][14])
  		
  		if len(_usrGer)>= 6 // 6 caracteres do usuário + vírgula
  			_usrGer := substr(_usrGer,8)
  		else           
  			_usrGer := ""		// Senão não tem mais usuário
  		endif 	
  	enddo 	
		
   _cQuery := "SELECT SRF.RF_MAT, SRF.RF_DFERAAT, SRF.RF_DFERVAT, SRF.RF_DATABAS, " +;
   			"	SRA.RA_CC, SRA.RA_NOME " +;   			
   			"  FROM " + RetSqlName("SRF") + " SRF, " +;
   						RetSqlName("SRA") + " SRA " +;
			"  WHERE SRF.RF_FILIAL = '" + xFilial("SRF") + "' AND " +;  
			"		SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND " +;
			" 		SRF.D_E_L_E_T_ = ' ' AND " +;
			" 		SRA.D_E_L_E_T_ = ' ' AND " +;
			"		SRF.RF_DFERAAT >= 20 AND " +;
			"		SRF.RF_DFERVAT > 0 AND " +;
			" 		SRA.RA_MAT = SRF.RF_MAT  AND " +;
			" 		SRA.RA_SITFOLH  = ' '" +;
			"  ORDER BY SRA.RA_CC, SRF.RF_DFERAAT, SRF.RF_DFERVAT "

	_cQuery := changeQuery(_cQuery)	                                               
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery),"_TRBRF", .T., .T.)
     
    dbSelectArea("_TRBRF")
    dbGotop()
    _cCC := ""
    while !_TRBRF->(eof())
         
       	// se mudou o centro de custos, envia esse email e começa outro. 
		if _cCC <> _TRBRF->RA_CC    
		                            
			_cEmail := "" 
			
			if oProcess <>  nil
				oProcess:Start() 
				oProcess:finish()
				oProcess := nil
			endif                
			
        	_cCC := _TRBRF->RA_CC                   
        	 
        	// procura líder do centro de custo
        	_cQuery := "SELECT SRA.RA_MAT, SRA.RA_SUSER, SRA.RA_NOME " +;   			
			   			"  FROM " + RetSqlName("SRA") + " SRA " +;
						"  WHERE SRA.RA_FILIAL = '" + xFilial("SRA") + "' AND " +;
						" 		SRA.D_E_L_E_T_ = ' ' AND " +;
						" 		SRA.RA_CC = '" + _cCC + "' AND " +;
						" 		SRA.RA_CODFUNC = '00008' AND " +;
						" 		SRA.RA_SITFOLH  = ' '" 
			
			_cQuery := changeQuery(_cQuery)	                                               
			dbUseArea( .T., "TOPCONN", TCGENQRY(,,_cQuery),"_cLCC", .T., .T.)
        
        	dbSelectArea("_cLCC")  
        	dbGotop()        	                                         
        	                           
        	if !_cLCC->(EOF())
	        	PswOrder(1)
				PswSeek(_cLCC->RA_SUSER) 	// pega os 6 caracteres referentes ao código do usuário
			  //	PswOrder(2)  // por nome
			  //	PswSeek(_cLCC->RA_NOME)
				aDadosUsu := PswRet() 		// Retorna vetor com informações do usuário			
		  		_cEmail := alltrim(aDadosUsu[1][14])
	  	   	endif 	        	
        	
        	_cLCC->(dbCloseArea())
        	         
			dbSelectArea("CTT")
			dbSetOrder(1)
			dbSeek(xFilial("CTT")+_cCC)        	        		             
			_cCTT := CTT->CTT_DESC01      	
        	
        	// cria o processo
			oProcess := TWFProcess():New( "WFFER", "Workflow Aviso Férias")	
			
			// inicia a tarefa passando o arquivo HTML utilizado
			oProcess :NewTask( "Envio do Pedido de compras", "\workflow\htm\wffer_enf.htm" ) 
			
			// Assunto do email
			oProcess:cSubject  := "Workflow - Aviso de Férias - Funcionários Centro de Custos " + alltrim(_cCTT)
            			
			// cria HTML
			oHtml := oProcess:oHTML	
	
			oHtml:ValByName("NOMEEMP",  SM0->M0_NOMECOM)  // EMPRESA 
			oProcess:cTo := iif(len(_cEmail)>0, _cEmail + ",", + "") + _cEmailRH      
    	endif   		      
	   	                                                
	   	IncProc()
	   	
		AAdd( (oHtml:ValByName("func.cod")),  	alltrim(_TRBRF->RF_MAT))				// número item  
		AAdd( (oHtml:ValByName("func.nome")), 	alltrim(_TRBRF->RA_NOME))
		AAdd( (oHtml:ValByName("func.cc")),  	alltrim(_TRBRF->RA_CC) + " - " + alltrim(_cCTT) )     
		AAdd( (oHtml:ValByName("func.dBase")),  dtoc(stod(_TRBRF->RF_DATABAS)))
		AAdd( (oHtml:ValByName("func.fvenc")),  _TRBRF->RF_DFERVATS)
		AAdd( (oHtml:ValByName("func.favenc")), _TRBRF->RF_DFERAAT)       
		
		if _TRBRF->RF_DFERAAT >= 25
			aadd(_aMais25, {alltrim(_TRBRF->RF_MAT),;
							alltrim(_TRBRF->RA_NOME),;
							alltrim(_TRBRF->RA_CC) + " - " + alltrim(_cCTT),; 
							dtoc(stod(_TRBRF->RF_DATABAS)),;
							_TRBRF->RF_DFERVATS,;
							_TRBRF->RF_DFERAAT })  
		endif 
		
		dbSelectArea("_TRBRF")						
		_TRBRF->(dbskip())
	enddo 
	
	_TRBRF->(dbCloseArea()) 
	
	
	// envia o último email e ve se precisa enviar pro gerente
	if oProcess <>  nil
		oProcess:Start() 
		oProcess:finish()
		oProcess := nil
	endif                
                  
   // só envia pro gerente se tiver funcionários com 25 dias de férias pra vencer...
	if len(_aMais25) > 0 			
	    // cria o processo
		oProcess := TWFProcess():New( "WFFER", "Workflow Aviso Férias")	
		
		// inicia a tarefa passando o arquivo HTML utilizado
		oProcess :NewTask( "Envio do Pedido de compras", "\workflow\htm\wffer_enf.htm" ) 
		
		// Assunto do email
		oProcess:cSubject  := "Workflow - Aviso de Férias - Funcionários com 25 dias de férias no segundo período"
	            			
		// cria HTML
		oHtml := oProcess:oHTML  
	
		oHtml:ValByName("NOMEEMP",  SM0->M0_NOMECOM)  // EMPRESA 
		oProcess:cTo :=  _cEmailGer    
	    
		for _n := 1 to len(_aMais25)
			
			IncProc()
				 	
			AAdd( (oHtml:ValByName("func.cod")),  	_aMais25[_n, 1])
			AAdd( (oHtml:ValByName("func.nome")), 	_aMais25[_n, 2])
			AAdd( (oHtml:ValByName("func.cc")),  	_aMais25[_n, 3])     
			AAdd( (oHtml:ValByName("func.dBase")),  _aMais25[_n, 4])
			AAdd( (oHtml:ValByName("func.fvenc")),  _aMais25[_n, 5])
			AAdd( (oHtml:ValByName("func.favenc")), _aMais25[_n, 6])      
		next 
	endif 	
	oProcess:Start() 
return 