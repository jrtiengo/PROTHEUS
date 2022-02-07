User Function FPROPSINO(cPdRot)
    Local CREFFER := GetValType('C')
    Local NIDFER := GetValType('N')
    Local NSAVINS := GetValType('N')
    Local NSAVPER := GetValType('N')
    Local NBASFER := GetValType('N')
    Local NPOSAUX := GetValType('N')
    
    cVerbaRot := cPdRot
    
    Begin Sequence
        If ( AbortProc() )
            Break
        EndIf
    
        LDFERAVI := !(SRG->RG_DFERAVI == 0 .AND. NDIASAV > 0 .AND. CCOMPL == "S")
    
        CREFFER := GETMVRH("MV_REFFER",NIL,"A")
    
        NIDFER := 087
    
        NSAVINS := NINTINSAL
    
        NSAVPER := NINTPERCUL
    
        NINTINSAL := IF( TYPE('NINTRESINS') <> "U" .AND. NINTRESINS > 0, NINTRESINS, NINTINSAL )
    
        NINTPERCUL := IF( TYPE('NINTRESPER') <> "U" .AND. NINTRESPER > 0, NINTRESPER, NINTPERCUL )
    
        IF ( SRA->RA_TPCONTR != "3" )
    
            IF ( SRA->RA_CATFUNC $ "E*G" )
    
                NIDFER := 1425
    
            EndIF
    
    
            IF ( GETMEMVAR("RG_DFERPRO") > 0 .AND. AINCRES[4] == "S" .AND. !EMPTY(ACODFOL[NIDFER,1]) )
    
                NBASFER := SALARIO + NADTSERV + NINTPERCUL - ( FBUSCAPD("140,147,148",'V',,,)*0.30) + NINTINSAL + NADCCONF + NADCTRF
    
                IF ( SRA->RA_CATFUNC == "H" .AND. LHOJORVA )
    
                    NBASFER := NSALMESFP + NADTSERV + NINTPERCUL - ( FBUSCAPD("140,147,148",'V',,,)*0.30) + NINTINSAL + NADCCONF + NADCTRF
    
                EndIF
    
    
                NFERVEP := (((NBASFER ) / P_QTDIAMES) * GETMEMVAR("RG_DFERPRO")) + NGCOMISFP+NGTAREFFP
    
                IF ( EMPTY(ACODFOL[249,1]) )
    
                    IF ( !LDFERAVI )
    
                        IF ( CMEDDIR == "S" )
    
                            NFERMEDI := (NMEDFERP / (GETMEMVAR("RG_DFERPRO")-NDFERIND)) * NDFERIND
    
                        EndIF
    
    
                        NFERVEP += NMEDFERP + NFERMEDI
    
                        NFERIND := (NFERVEP / GETMEMVAR("RG_DFERPRO")) * NDFERIND
    
                        NFERVEP -= NFERIND
    
                        IF ( NDFERIND > GETMEMVAR("RG_DFERPRO") )
    
                            NFERVEP := MAX(NFERVEP,0)
    
                        EndIF
    
    
                        IF ( ASCAN(APD,{ |X| X[1] = ACODFOL[NIDFER,1] .AND. X[9] # "D" } ) == 0 )
    
                            FGERAVERBA( ACODFOL[NIDFER,1] , ROUND( NFERVEP , 2), IF( CREFFER == "D" , GETMEMVAR("RG_DFERPRO") , INT(NDFERAVE/ATABFER[4])+0.12), , ,"V","R")
    
                        EndIF
    
    
                    EndIF
    
    
                    IF ( LDFERAVI )
    
                        IF ( CMEDDIR == "S" )
    
                            NFERVEP += NMEDFERP
    
                        EndIF
    
    
                        IF ( CMEDDIR <> "S" )
    
                            IF ( GETMEMVAR("RG_DFERPRO") + GETMEMVAR("RG_DFERAVI") < 30 )
    
                                NFERVEP += ( ( NMEDFERP / ( GETMEMVAR("RG_DFERPRO") + GETMEMVAR("RG_DFERAVI") ) ) * GETMEMVAR("RG_DFERPRO" ) )
    
                            EndIF
    
    
                            IF ( GETMEMVAR("RG_DFERPRO") + GETMEMVAR("RG_DFERAVI") >= 30 )
    
                                NFERVEP += (NMEDFERP / P_QTDIAMES  ) * GETMEMVAR("RG_DFERPRO")
    
                            EndIF
    
    
                        EndIF
    
    
                        IF ( ASCAN(APD,{ |X| X[1] = ACODFOL[NIDFER,1] .AND. X[9] # "D" } ) == 0 )
    
                            FGERAVERBA(ACODFOL[NIDFER,1] , ROUND(NFERVEP,2) , IF( CREFFER == "D" , GETMEMVAR("RG_DFERPRO") , INT( NDFERAVE/ATABFER[4])+0.12), , ,"V","R")
    
                        EndIF
    
    
                    EndIF
    
    
                EndIF
    
    
                IF ( !EMPTY(ACODFOL[249,1]) )
    
                    IF ( !LDFERAVI )
    
                        NFERMEDP += NMEDFERP
    
                        IF ( CMEDDIR == "S" )
    
                            NFERMEDI := (NFERMEDP / ( GETMEMVAR("RG_DFERPRO") - NDFERIND ) ) * NDFERIND
    
                        EndIF
    
    
                        IF ( CMEDDIR # "S" )
    
                            NFERMEDI := (NFERMEDP / GETMEMVAR("RG_DFERPRO") ) * NDFERIND
    
                            NFERMEDP -= NFERMEDI
    
                        EndIF
    
    
                        NFERIND := (NFERVEP / GETMEMVAR("RG_DFERPRO")) * NDFERIND
    
                        NFERVEP -= NFERIND
    
                        IF ( NDFERIND > GETMEMVAR("RG_DFERPRO") )
    
                            NFERVEP := MAX(NFERVEP,0)
    
                        EndIF
    
    
                        IF ( ASCAN(APD,{ |X| X[1] = ACODFOL[NIDFER,1] .AND. X[9] # "D" } ) == 0 )
    
                            FGERAVERBA( ACODFOL[NIDFER,1] , ROUND(NFERVEP,2) , IF ( CREFFER == "D" , GETMEMVAR("RG_DFERPRO") - NDFERIND , INT(( NDFERAVE - NDFERIND ) / ATABFER[4]) + 0.12), , ,"V","R")
    
                        EndIF
    
    
                        IF ( ASCAN(APD,{ |X| X[1] = ACODFOL[249,1] .AND. X[9] # "D" } ) == 0 )
    
                            FGERAVERBA( ACODFOL[249,1] , ROUND(NFERMEDP,2) , IF ( CREFFER == "D" , NDFERAVE - NDFERIND , INT(( NDFERAVE - NDFERIND ) / ATABFER[4] ) + 0.12 ) , , ,"V","R")
    
                        EndIF
    
    
                    EndIF
    
    
                    IF ( LDFERAVI )
    
                        IF ( CMEDDIR == "S" )
    
                            NFERMEDP := NMEDFERP
    
                        EndIF
    
    
                        IF ( CMEDDIR # "S" )
    
                            IF ( GETMEMVAR("RG_DFERPRO") + GETMEMVAR("RG_DFERAVI") < 30 )
    
                                NFERMEDP := ( ( NMEDFERP / ( GETMEMVAR("RG_DFERPRO") + GETMEMVAR("RG_DFERAVI") ) ) * GETMEMVAR("RG_DFERPRO" ) )
    
                            EndIF
    
    
                            IF ( GETMEMVAR("RG_DFERPRO") + GETMEMVAR("RG_DFERAVI") >= 30 )
    
                                NFERMEDP := (NMEDFERP / P_QTDIAMES  ) * GETMEMVAR("RG_DFERPRO")
    
                            EndIF
    
    
                        EndIF
    
    
                        IF ( ASCAN(APD,{ |X| X[1] = ACODFOL[NIDFER,1] .AND. X[9] # "D" } ) == 0 )
    
                            FGERAVERBA( ACODFOL[NIDFER,1] , ROUND( NFERVEP , 2) ,  IF ( CREFFER == "D" , GETMEMVAR("RG_DFERPRO") , INT( NDFERAVE / ATABFER[4] ) + 0.12), , ,"V","R")
    
                        EndIF
    
    
                        IF ( ASCAN(APD,{ |X| X[1] = ACODFOL[249,1] .AND. X[9] # "D" } ) == 0 )
    
                            FGERAVERBA(ACODFOL[249,1] , ROUND( NFERMEDP , 2 ) , IF ( CREFFER == "D" , NDFERAVE , INT( NDFERAVE / ATABFER[4] ) + 0.12), , ,"V","R")
    
                        EndIF
    
    
                    EndIF
    
    
                EndIF
    
    
                NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[NIDFER,1] } )
    
                IF ( NPOSAUX == 0 )
    
                    NORDGRPD++
    
                    AADD(ASALBASE,{ ACODFOL[NIDFER,1] , NBASFER , NORDGRPD})
    
                EndIF
    
    
                IF ( NPOSAUX > 0 )
    
                    ASALBASE[NPOSAUX,2] := NBASFER
    
                    ASALBASE[NPOSAUX,3] := NORDGRPD
    
                EndIF
    
    
            EndIF
    
    
        EndIF
    
    
        NINTINSAL := NSAVINS
    
        NINTPERCUL := NSAVPER
    
    End Sequence
Return
