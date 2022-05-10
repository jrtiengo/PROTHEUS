#INCLUDE "protheus.ch"

user function  F090FIL

	Local _cFiltro  := "" //E2_FORNECE=='005459'"
	Local OLDMVPAR01:=MV_PAR01 
	Local OLDMVPAR02:=MV_PAR02
	Local aHelpPor:={} 
	Local aHelpSpa:={}
	Local aHelpEng:={}
	Local aHelpPor1:={} 
	Local aHelpSpa1:={}
	Local aHelpEng1:={}	
	
	Aadd( aHelpPor, 'Selecione o código do Fornecedor.'  )
	Aadd( aHelpPor, 'Branco=Seleciona todos.'  )
	Aadd( aHelpSpa, ''  )
	Aadd( aHelpEng, ''  )

	Aadd( aHelpPor1, 'Selecione o código da Natureza.'  )
	Aadd( aHelpPor1, 'Branco=Seleciona todos.'  )
	Aadd( aHelpSpa1, ''  )
	Aadd( aHelpEng1, ''  )


	//PutSx1( 'SCIF090', "01", "Fornecedor(Branco=Todos)?","","Código do Cliente?","mv_ch1","C",6,0,0,"G","","SA2","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa)
	//PutSx1( 'SCIF090', "02", "Natureza(Branco=Todos)?","","Natureza?"           ,"mv_ch1","C",10,0,0,"G","","SED","","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor1,aHelpEng1,aHelpSpa1)
    
    PERGUNTE('SCIF090',.T.)
	
	if !Empty(MV_PAR01)
		_cFiltro  := "E2_FORNECE=='"+MV_PAR01+"'" 
	ELSE              
		_cFiltro  := ".T. == .T. "
	END
	
	if !Empty(MV_PAR02)
		_cFiltro  += ".AND. E2_NATUREZ=='"+MV_PAR02+"'" 
	ELSE              
		_cFiltro  += ".AND. .T. == .T. "
	END
	                      
	
	MV_PAR01:=OLDMVPAR01 
	MV_PAR02:=OLDMVPAR02
	
Return( _cFiltro ) 
