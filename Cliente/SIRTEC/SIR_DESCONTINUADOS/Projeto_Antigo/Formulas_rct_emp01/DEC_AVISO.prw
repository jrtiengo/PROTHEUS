User Function DEC_AVISO(cPdRot)
    cVerbaRot := cPdRot
    
    Begin Sequence
        If ( AbortProc() )
            Break
        EndIf                 
        
      	M_000 := FBUSCAPD("251",'V',,,)   
      	
      	M_001 := ROUND(FBUSCAPD("254",'H',,,),0)
      	
      	M_002 := M_000/12
      	
      	M_003 := M_002* M_001 
                       
        /* M_000 := ROUND(FBUSCAPD("253",'H',,,),0) 
        
        M_001:=FBUSCAPD("140,147,148",'V',,,)*0.30
        
        M_VALOR := M_001 / 12
        
        M_DEDUZIR := m_VALOR * M_000 
    
        M_002:=FBUSCAPD("253",'V',,,)- M_DEDUZIR  */
        
         
       FGERAVERBA("254",M_003,FBUSCAPD("254",'H',,,),,,,"R",,,,.T.,,,,,,,,)
    
    End Sequence  
    
Return
