User Function SIR_FER_AVISO(cPdRot)
    cVerbaRot := cPdRot
    
    Begin Sequence
        If ( AbortProc() )
            Break
        EndIf                 
        
      	M_000 := FBUSCAPD("251",'V',,,)   
      	
      	M_001 := ROUND(FBUSCAPD("215",'H',,,),0)
      	
      	M_002 := M_000/12
      	
      	M_003 := M_002* M_001 
              
         
       FGERAVERBA("240",M_003,FBUSCAPD("240",'H',,,),,,,"G",,,,.T.,,,,,,,,)
    
    End Sequence  
    
Return
