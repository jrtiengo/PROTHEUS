Function U_UFORDES(cPdRot)
    cVerbaRot := cPdRot
    
    Begin Sequence
        // IFs sendo chamados, sem declarar EndIf. Mauro - Solutio. 23/01/2022.
        If ( AbortProc() )
            Break
        EndIf
        
        
        iF SRA->RA_CATFUNC <> 'E'
    
            FGERAVERBA('973',ROUND(M_CONTRDES/M_FUNCDES,2),4.5,,,'V','G',,,,.T.,,,,,,,,)
        EndIF
    
    End Sequence
Return
