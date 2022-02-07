User Function DECSINO(cPdRot)
    cVerbaRot := cPdRot
    
    Begin Sequence
        If ( AbortProc() )
            Break
        EndIf             
        
               
        M_000 := ROUND(FBUSCAPD("253",'H',,,),0) 
        
        M_001:=FBUSCAPD("140,147,148",'V',,,)*0.30
        
        M_VALOR := M_001 / 12
        
        M_DEDUZIR := m_VALOR * M_000 
    
        M_002:=FBUSCAPD("253",'V',,,)- M_DEDUZIR 
        
         
       FGERAVERBA("253",M_002,FBUSCAPD("253",'H',,,),,,,"R",,,,.T.,,,,,,,,)
    
    End Sequence
Return
