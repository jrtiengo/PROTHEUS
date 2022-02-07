User Function DECSIRTEC(cPdRot)
    cVerbaRot := cPdRot
    
    Begin Sequence
        If ( AbortProc() )
            Break
        EndIf             
        
IF ( SRA->RA_ADCPERI = "2" )
               
        M_000 := ROUND(FBUSCAPD("253",'H',,,),0) 
        
        M_001:=FBUSCAPD("140,147,148",'V',,,)*0.30 
        
        M_003 := (FBUSCAPD("115",'V',,,)*0.30)/12 * M_000
        
        M_VALOR := M_001 / 12
        
        M_DEDUZIR := m_VALOR * M_000 
    
        M_002:=FBUSCAPD("253",'V',,,)- (M_DEDUZIR + (FBUSCAPD("115",'V',,,)*0.30)/12 * M_000) 
        
         
       FGERAVERBA("253",M_002,FBUSCAPD("253",'H',,,),,,,"R",,,,.T.,,,,,,,,)       
       
ELSE 

    	FCAL13O(APD,ACODFOL,NMED13O)    
    	
    	 
EndIF       
    
    End Sequence
Return