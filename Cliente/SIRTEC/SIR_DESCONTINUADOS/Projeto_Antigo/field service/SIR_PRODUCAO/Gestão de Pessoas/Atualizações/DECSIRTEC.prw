User Function DECSIRTEC(cPdRot)
    cVerbaRot := cPdRot
    
    Begin Sequence
        If ( AbortProc() )
            Break
        EndIf             
        
IF ( SRA->RA_ADCPERI = "2" )
               
        M_000 := ROUND(FBUSCAPD("253",'H',,,),0) 
        
        M_001:=FBUSCAPD("140,147,148",'V',,,)*0.30 
        
        M_003 := salmes + NADCCONF + salmes * 0.30 +  NADTSERV + NINTINSAL 
        
        M_004 := M_003/ 12
        
        M_valor := M_004 * M_000 
    
               
        FGERAVERBA("253",M_valor,FBUSCAPD("253",'H',,,),,,,"R",,,,.T.,,,,,,,,)       
       
ELSE 

    	M_000 := ROUND(FBUSCAPD("253",'H',,,),0) 
        
        M_001:=FBUSCAPD("140,147,148",'V',,,)*0.30 
        
        M_003 := salmes + NADCCONF +  NADTSERV + NINTINSAL 
        
        M_004 := M_003/ 12
        
        M_valor := M_004 * M_000 
    
               
        FGERAVERBA("253",M_valor,FBUSCAPD("253",'H',,,),,,,"R",,,,.T.,,,,,,,,)         
EndIF       
    
    End Sequence
Return