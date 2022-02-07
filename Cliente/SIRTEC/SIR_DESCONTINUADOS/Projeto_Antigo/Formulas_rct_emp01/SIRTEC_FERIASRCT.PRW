User Function SIRTEC_FERIASRCT(cPdRot)
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
 
IF ( SRA->RA_ADCPERI = "2" )
 
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
    
                NBASFER := SALARIO + NADTSERV + NINTPERCUL - ( FBUSCAPD("140,147,148",'V',,,)*0.30) - ( FBUSCAPD("115",'V',,,)*0.30) + NINTINSAL + NADCCONF + NADCTRF
    
                IF ( SRA->RA_CATFUNC == "H" .AND. LHOJORVA )
    
                    NBASFER := NSALMESFP + NADTSERV + NINTPERCUL - ( FBUSCAPD("140,147,148",'V',,,)*0.30) - ( FBUSCAPD("115",'V',,,)*0.30) + NINTINSAL + NADCCONF + NADCTRF
    
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
Else

LDFERAVI := !(SRG->RG_DFERAVI == 0 .AND. NDIASAV > 0 .AND. CCOMPL == "S")
    
        CREFFER := GETMVRH("MV_REFFER",NIL,"A")
    
        NIDFER := 087
    
        NSAVINS := NINTINSAL
    
        NSAVPER := NINTPERCUL
    
        NINTINSAL := IF( TYPE('NINTRESINS') <> "U" .AND. NINTRESINS > 0, NINTRESINS, NINTINSAL )
    
        NINTPERCUL := IF( TYPE('NINTRESPER') <> "U" .AND. NINTRESPER > 0, NINTRESPER, NINTPERCUL )
    
        NVALFERATS := 0
    
        NVALFERPER := 0
    
        NVALFERINS := 0
    
        NVALFERCON := 0
    
        NVALFERTRA := 0
    
        NMDPERFP := 0
    
        NMDPERFPI := 0
    
        NMDINSFP := 0
    
        NMDINSFPI := 0
    
        LADCSRESC := LEN(ACODFOL) > 1680 .AND. !EMPTY(ACODFOL[1680,1])
    
        IF ( SRA->RA_TPCONTR != "3" )
    
            IF ( SRA->RA_CATFUNC $ "E*G" )
    
                NIDFER := 1425
    
            EndIF
    
    
            IF ( GETMEMVAR("RG_DFERPRO") > 0 .AND. AINCRES[4] == "S" .AND. !EMPTY(ACODFOL[NIDFER,1]) )
    
                IF ( LADCSRESC .AND. ( CCOMPL <> "S" .OR. LTEMIDRESC) )
    
                    NBASFER := SALARIO + FINCSEMID(STRZERO(NIDFER,4))
    
                    NVALFERATS := (NADTSERV / P_QTDIAMES) * GETMEMVAR("RG_DFERPRO")
    
                    NVALFERPER := (NINTPERCUL / P_QTDIAMES) * GETMEMVAR("RG_DFERPRO")
    
                    NVALFERINS := (NINTINSAL / P_QTDIAMES) * GETMEMVAR("RG_DFERPRO")
    
                    NVALFERCONF := (NADCCONF / P_QTDIAMES) * GETMEMVAR("RG_DFERPRO")
    
                    NVALFERTRA := (NADCTRF / P_QTDIAMES) * GETMEMVAR("RG_DFERPRO")
    
                EndIF
    
    
                IF ( !LADCSRESC .OR. (CCOMPL == "S" .AND.  !LTEMIDRESC) )
    
                    NBASFER := SALARIO + NADTSERV + NINTPERCUL + NINTINSAL + NADCCONF + NADCTRF + FINCSEMID(STRZERO(NIDFER,4))
    
                EndIF
    
    
                IF ( SRA->RA_CATFUNC == "H" .AND. LHOJORVA )
    
                    IF ( !LADCSRESC .OR. (CCOMPL == "S" .AND.  !LTEMIDRESC) )
    
                        NBASFER := NSALMESFP + NADTSERV + NINTPERCUL + NINTINSAL + NADCCONF + NADCTRF
    
                    EndIF
    
    
                    IF ( LADCSRESC .AND. ( CCOMPL <> "S" .OR. LTEMIDRESC) )
    
                        NBASFER := NSALMESFP
    
                        NVALFERATS := (NADTSERV / P_QTDIAMES) * GETMEMVAR("RG_DFERPRO")
    
                        NVALFERPER := (NINTPERCUL / P_QTDIAMES) * GETMEMVAR("RG_DFERPRO")
    
                        NVALFERINS := (NINTINSAL / P_QTDIAMES) * GETMEMVAR("RG_DFERPRO")
    
                        NVALFERCONF := (NADCCONF / P_QTDIAMES) * GETMEMVAR("RG_DFERPRO")
    
                        NVALFERTRA := (NADCTRF / P_QTDIAMES) * GETMEMVAR("RG_DFERPRO")
    
                    EndIF
    
    
                EndIF
    
    
                NFERVEP := (((NBASFER ) / P_QTDIAMES) * GETMEMVAR("RG_DFERPRO")) + NGCOMISFP+NGTAREFFP
    
                NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[NIDFER,1] } )
    
                IF ( NPOSAUX == 0 )
    
                    NORDGRPD++
    
                    AADD(ASALBASE,{ ACODFOL[NIDFER,1] , NBASFER , NORDGRPD})
    
                EndIF
    
    
                IF ( NPOSAUX > 0 )
    
                    ASALBASE[NPOSAUX,2] := NBASFER
    
                    ASALBASE[NPOSAUX,3] := NORDGRPD
    
                EndIF
    
    
                IF ( EMPTY(ACODFOL[249,1]) )
    
                    IF ( !LDFERAVI )
    
                        IF ( CMEDDIR == "S" )
    
                            NFERMEDI := (NMEDFERP / (GETMEMVAR("RG_DFERPRO")-NDFERIND)) * NDFERIND
    
                            NMDPERFPI := (NMEDPERFP / (GETMEMVAR("RG_DFERPRO")-NDFERIND)) * NDFERIND
    
                            NMDINSFPI := (NMEDINSFP / (GETMEMVAR("RG_DFERPRO")-NDFERIND)) * NDFERIND
    
                        EndIF
    
    
                        NFERVEP += NMEDFERP + NFERMEDI
    
                        NFERIND := (NFERVEP / GETMEMVAR("RG_DFERPRO")) * NDFERIND
    
                        NFERVEP -= NFERIND
    
                        NMDPERFP := NMEDPERFP - NMDPERFPI
    
                        NMDINSFP := NMEDINSFP - NMDINSFPI
    
                        IF ( NDFERIND > GETMEMVAR("RG_DFERPRO") )
    
                            NFERVEP := MAX(NFERVEP,0)
    
                        EndIF
    
    
                        IF ( !LADCSRESC .OR. (CCOMPL == "S" .AND.  !LTEMIDRESC) )
    
                            IF ( ASCAN(APD,{ |X| X[1] = ACODFOL[NIDFER,1] .AND. X[9] # "D" } ) == 0 )
    
                                FGERAVERBA( ACODFOL[NIDFER,1] , ROUND( NFERVEP , 2), IF( CREFFER == "D" , GETMEMVAR("RG_DFERPRO") , INT(NDFERAVE/ATABFER[4])+0.12), , ,"V","R")
    
                            EndIF
    
    
                        EndIF
    
    
                        IF ( LADCSRESC .AND. ( CCOMPL <> "S" .OR. LTEMIDRESC) )
    
                            IF ( ASCAN(APD,{ |X| X[1] = ACODFOL[NIDFER,1] .AND. X[9] # "D" } ) == 0 )
    
                                FGERAVERBA( ACODFOL[NIDFER,1] , ROUND( NFERVEP , 2) ,  IF ( CREFFER == "D" , GETMEMVAR("RG_DFERPRO") , INT( NDFERAVE / ATABFER[4] ) + 0.12), , ,"V","R")
    
                            EndIF
    
    
                            NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[1705,1] } )
    
                            IF ( NPOSAUX == 0 )
    
                                NORDGRPD++
    
                                AADD(ASALBASE,{ ACODFOL[1705,1] , NADTSERV , NORDGRPD})
    
                            EndIF
    
    
                            IF ( NPOSAUX > 0 )
    
                                ASALBASE[NPOSAUX,2] := NADTSERV
    
                                ASALBASE[NPOSAUX,3] := NORDGRPD
    
                            EndIF
    
    
                            NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[1681,1] } )
    
                            IF ( NPOSAUX == 0 )
    
                                NORDGRPD++
    
                                AADD(ASALBASE,{ ACODFOL[1681,1] , NINTPERCUL , NORDGRPD})
    
                            EndIF
    
    
                            IF ( NPOSAUX > 0 )
    
                                ASALBASE[NPOSAUX,2] := NINTPERCUL
    
                                ASALBASE[NPOSAUX,3] := NORDGRPD
    
                            EndIF
    
    
                            NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[1693,1] } )
    
                            IF ( NPOSAUX == 0 )
    
                                NORDGRPD++
    
                                AADD(ASALBASE,{ ACODFOL[1693,1] , NINTINSAL , NORDGRPD})
    
                            EndIF
    
    
                            IF ( NPOSAUX > 0 )
    
                                ASALBASE[NPOSAUX,2] := NINTINSAL
    
                                ASALBASE[NPOSAUX,3] := NORDGRPD
    
                            EndIF
    
    
                            NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[1717,1] } )
    
                            IF ( NPOSAUX == 0 )
    
                                NORDGRPD++
    
                                AADD(ASALBASE,{ ACODFOL[1717,1] , NADCCONF , NORDGRPD})
    
                            EndIF
    
    
                            IF ( NPOSAUX > 0 )
    
                                ASALBASE[NPOSAUX,2] := NADCCONF
    
                                ASALBASE[NPOSAUX,3] := NORDGRPD
    
                            EndIF
    
    
                            NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[1711,1] } )
    
                            IF ( NPOSAUX == 0 )
    
                                NORDGRPD++
    
                                AADD(ASALBASE,{ ACODFOL[1711,1] , NADCTRF , NORDGRPD})
    
                            EndIF
    
    
                            IF ( NPOSAUX > 0 )
    
                                ASALBASE[NPOSAUX,2] := NADCTRF
    
                                ASALBASE[NPOSAUX,3] := NORDGRPD
    
                            EndIF
    
    
                            IF ( ASCAN(APD,{ |X| X[1] = ACODFOL[NIDFER,1] .AND. X[9] # "D" } ) == 0 )
    
                                FGERAVERBA( ACODFOL[NIDFER,1] , ROUND( NFERVEP , 2) ,  IF ( CREFFER == "D" , GETMEMVAR("RG_DFERPRO") , INT( NDFERAVE / ATABFER[4] ) + 0.12), , ,"V","R")
    
                            EndIF
    
    
                            IF ( ASCAN(APD,{ |X| X[1] = ACODFOL[249,1] .AND. X[9] # "D" } ) == 0 )
    
                                FGERAVERBA(ACODFOL[249,1] , ROUND( NFERMEDP , 2 ) , IF ( CREFFER == "D" , NDFERAVE , INT( NDFERAVE / ATABFER[4] ) + 0.12), , ,"V","R")
    
                            EndIF
    
    
                            FGERAVERBA(ACODFOL[1705,1] , ROUND( NVALFERATS , 2 ) , IF ( CREFFER == "D" , NDFERAVE , INT( NDFERAVE / ATABFER[4] ) + 0.12), , ,"V","R")
    
                            FGERAVERBA(ACODFOL[1681,1] , ROUND( NVALFERPER , 2 ) , IF ( CREFFER == "D" , NDFERAVE , INT( NDFERAVE / ATABFER[4] ) + 0.12), , ,"V","R")
    
                            FGERAVERBA(ACODFOL[1693,1] , ROUND( NVALFERINS , 2 ) , IF ( CREFFER == "D" , NDFERAVE , INT( NDFERAVE / ATABFER[4] ) + 0.12), , ,"V","R")
    
                            FGERAVERBA(ACODFOL[1717,1] , ROUND( NVALFERCON , 2 ) , IF ( CREFFER == "D" , NDFERAVE , INT( NDFERAVE / ATABFER[4] ) + 0.12), , ,"V","R")
    
                            FGERAVERBA(ACODFOL[1711,1] , ROUND( NVALFERTRA , 2 ) , IF ( CREFFER == "D" , NDFERAVE , INT( NDFERAVE / ATABFER[4] ) + 0.12), , ,"V","R")
    
                            FGERAVERBA(ACODFOL[1687,1] , ROUND( NMDPERFP, 2 ) , IF ( CREFFER == "D" , NDFERAVE , INT( NDFERAVE / ATABFER[4] ) + 0.12), , ,"V","R")
    
                            FGERAVERBA(ACODFOL[1699,1] , ROUND( NMDINSFP, 2 ) , IF ( CREFFER == "D" , NDFERAVE , INT( NDFERAVE / ATABFER[4] ) + 0.12), , ,"V","R")
    
                        EndIF
    
    
                    EndIF
    
    
                    IF ( LDFERAVI )
    
                        IF ( CMEDDIR == "S" )
    
                            NFERVEP += NMEDFERP
    
                            NMDPERFP := NMEDPERFP
    
                            NMDINSFP := NMEDINSFP
    
                        EndIF
    
    
                        IF ( CMEDDIR <> "S" )
    
                            IF ( GETMEMVAR("RG_DFERPRO") + GETMEMVAR("RG_DFERAVI") < 30 )
    
                                NFERVEP += ( ( NMEDFERP / ( GETMEMVAR("RG_DFERPRO") + GETMEMVAR("RG_DFERAVI") ) ) * GETMEMVAR("RG_DFERPRO" ) )
    
                                NMDPERFP += ( ( NMEDPERFP / ( GETMEMVAR("RG_DFERPRO") + GETMEMVAR("RG_DFERAVI") ) ) * GETMEMVAR("RG_DFERPRO" ) )
    
                                NMDINSFP += ( ( NMEDINSFP / ( GETMEMVAR("RG_DFERPRO") + GETMEMVAR("RG_DFERAVI") ) ) * GETMEMVAR("RG_DFERPRO" ) )
    
                            EndIF
    
    
                            IF ( GETMEMVAR("RG_DFERPRO") + GETMEMVAR("RG_DFERAVI") >= 30 )
    
                                NFERVEP += (NMEDFERP / P_QTDIAMES  ) * GETMEMVAR("RG_DFERPRO")
    
                                NMDPERFP += ( NMEDPERFP / P_QTDIAMES ) * GETMEMVAR("RG_DFERPRO")
    
                                NMDINSFP += ( NMEDINSFP / P_QTDIAMES ) * GETMEMVAR("RG_DFERPRO")
    
                            EndIF
    
    
                        EndIF
    
    
                        IF ( ASCAN(APD,{ |X| X[1] = ACODFOL[NIDFER,1] .AND. X[9] # "D" } ) == 0 )
    
                            FGERAVERBA(ACODFOL[NIDFER,1] , ROUND(NFERVEP,2) , IF( CREFFER == "D" , GETMEMVAR("RG_DFERPRO") , INT( NDFERAVE/ATABFER[4])+0.12), , ,"V","R")
    
                        EndIF
    
    
                        IF ( LADCSRESC .AND. ( CCOMPL <> "S" .OR. LTEMIDRESC) )
    
                            FGERAVERBA(ACODFOL[1699,1] , ROUND(NMDINSFP,2) , IF( CREFFER == "D" , GETMEMVAR("RG_DFERPRO") , INT( NDFERAVE/ATABFER[4])+0.12), , ,"V","R")
    
                            FGERAVERBA(ACODFOL[1687,1] , ROUND(NMDPERFP,2) , IF( CREFFER == "D" , GETMEMVAR("RG_DFERPRO") , INT( NDFERAVE/ATABFER[4])+0.12), , ,"V","R")
    
                        EndIF
    
    
                    EndIF
    
    
                EndIF
    
    
                IF ( !EMPTY(ACODFOL[249,1]) )
    
                    IF ( !LDFERAVI )
    
                        NFERMEDP += NMEDFERP
    
                        IF ( CMEDDIR == "S" )
    
                            NFERMEDI := (NFERMEDP / ( GETMEMVAR("RG_DFERPRO") - NDFERIND ) ) * NDFERIND
    
                            NMDPERFERI := (NMEDPERFP / ( GETMEMVAR("RG_DFERPRO") - NDFERIND ) ) * NDFERIND
    
                            NMDINSFERI := (NMEDINSFP / ( GETMEMVAR("RG_DFERPRO") - NDFERIND ) ) * NDFERIND
    
                        EndIF
    
    
                        IF ( CMEDDIR # "S" )
    
                            NFERMEDI := (NFERMEDP / GETMEMVAR("RG_DFERPRO") ) * NDFERIND
    
                            NFERMEDP -= NFERMEDI
    
                            NMDPERFERI := (NMEDPERFP /GETMEMVAR("RG_DFERPRO") ) * NDFERIND
    
                            NMDINSFERI := (NMEDINSFP /GETMEMVAR("RG_DFERPRO") ) * NDFERIND
    
                            NMEDINSFP -= NMDINSFERI
    
                            NMEDPERFP -= NMDPERFERI
    
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
    
    
                        IF ( LADCSRESC .AND. ( CCOMPL <> "S" .OR. LTEMIDRESC) )
    
                            FGERAVERBA( ACODFOL[1687,1] , ROUND(NMEDPERFP,2) , IF ( CREFFER == "D" , GETMEMVAR("RG_DFERPRO") - NDFERIND , INT(( NDFERAVE - NDFERIND ) / ATABFER[4]) + 0.12), , ,"V","R")
    
                            FGERAVERBA( ACODFOL[1699,1] , ROUND(NMEDINSFP,2) , IF ( CREFFER == "D" , GETMEMVAR("RG_DFERPRO") - NDFERIND , INT(( NDFERAVE - NDFERIND ) / ATABFER[4]) + 0.12), , ,"V","R")
    
                        EndIF
    
    
                    EndIF
    
    
                    IF ( LDFERAVI )
    
                        IF ( CMEDDIR == "S" )
    
                            NFERMEDP := NMEDFERP
    
                            NMDPERFER := NMEDPERFP
    
                            NMDINSFER := NMEDINSFP
    
                        EndIF
    
    
                        IF ( CMEDDIR # "S" )
    
                            IF ( GETMEMVAR("RG_DFERPRO") + GETMEMVAR("RG_DFERAVI") < 30 )
    
                                NFERMEDP := ( ( NMEDFERP / ( GETMEMVAR("RG_DFERPRO") + GETMEMVAR("RG_DFERAVI") ) ) * GETMEMVAR("RG_DFERPRO" ) )
    
                                NMDPERFP += ( ( NMEDPERFP / ( GETMEMVAR("RG_DFERPRO") + GETMEMVAR("RG_DFERAVI") ) ) * GETMEMVAR("RG_DFERPRO" ) )
    
                                NMDINSFP += ( ( NMEDINSFP / ( GETMEMVAR("RG_DFERPRO") + GETMEMVAR("RG_DFERAVI") ) ) * GETMEMVAR("RG_DFERPRO" ) )
    
                            EndIF
    
    
                            IF ( GETMEMVAR("RG_DFERPRO") + GETMEMVAR("RG_DFERAVI") >= 30 )
    
                                NFERMEDP := (NMEDFERP / P_QTDIAMES  ) * GETMEMVAR("RG_DFERPRO")
    
                                NMDPERFP += ( NMEDPERFP / P_QTDIAMES ) * GETMEMVAR("RG_DFERPRO")
    
                                NMDINSFP += ( NMEDINSFP / P_QTDIAMES ) * GETMEMVAR("RG_DFERPRO")
    
                            EndIF
    
    
                        EndIF
    
    
                        IF ( !LADCSRESC .OR. (CCOMPL == "S" .AND.  !LTEMIDRESC) )
    
                            IF ( ASCAN(APD,{ |X| X[1] = ACODFOL[NIDFER,1] .AND. X[9] # "D" } ) == 0 )
    
                                FGERAVERBA( ACODFOL[NIDFER,1] , ROUND( NFERVEP , 2) ,  IF ( CREFFER == "D" , GETMEMVAR("RG_DFERPRO") , INT( NDFERAVE / ATABFER[4] ) + 0.12), , ,"V","R")
    
                            EndIF
    
    
                            IF ( ASCAN(APD,{ |X| X[1] = ACODFOL[249,1] .AND. X[9] # "D" } ) == 0 )
    
                                FGERAVERBA(ACODFOL[249,1] , ROUND( NFERMEDP , 2 ) , IF ( CREFFER == "D" , NDFERAVE , INT( NDFERAVE / ATABFER[4] ) + 0.12), , ,"V","R")
    
                            EndIF
    
    
                        EndIF
    
    
                        IF ( LADCSRESC .AND. ( CCOMPL <> "S" .OR. LTEMIDRESC) )
    
                            NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[NIDFER,1] } )
    
                            IF ( NPOSAUX == 0 )
    
                                NORDGRPD++
    
                                AADD(ASALBASE,{ ACODFOL[NIDFER,1] , NBASFER , NORDGRPD})
    
                            EndIF
    
    
                            IF ( NPOSAUX > 0 )
    
                                ASALBASE[NPOSAUX,2] := NBASFER
    
                                ASALBASE[NPOSAUX,3] := NORDGRPD
    
                            EndIF
    
    
                            IF ( ASCAN(APD,{ |X| X[1] = ACODFOL[NIDFER,1] .AND. X[9] # "D" } ) == 0 )
    
                                FGERAVERBA( ACODFOL[NIDFER,1] , ROUND( NFERVEP , 2) ,  IF ( CREFFER == "D" , GETMEMVAR("RG_DFERPRO") , INT( NDFERAVE / ATABFER[4] ) + 0.12), , ,"V","R")
    
                            EndIF
    
    
                            IF ( ASCAN(APD,{ |X| X[1] = ACODFOL[249,1] .AND. X[9] # "D" } ) == 0 )
    
                                FGERAVERBA(ACODFOL[249,1] , ROUND( NFERMEDP , 2 ) , IF ( CREFFER == "D" , NDFERAVE , INT( NDFERAVE / ATABFER[4] ) + 0.12), , ,"V","R")
    
                            EndIF
    
    
                            NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[1705,1] } )
    
                            IF ( NPOSAUX == 0 )
    
                                NORDGRPD++
    
                                AADD(ASALBASE,{ ACODFOL[1705,1] , NADTSERV , NORDGRPD})
    
                            EndIF
    
    
                            IF ( NPOSAUX > 0 )
    
                                ASALBASE[NPOSAUX,2] := NADTSERV
    
                                ASALBASE[NPOSAUX,3] := NORDGRPD
    
                            EndIF
    
    
                            NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[1681,1] } )
    
                            IF ( NPOSAUX == 0 )
    
                                NORDGRPD++
    
                                AADD(ASALBASE,{ ACODFOL[1681,1] , NINTPERCUL , NORDGRPD})
    
                            EndIF
    
    
                            IF ( NPOSAUX > 0 )
    
                                ASALBASE[NPOSAUX,2] := NINTPERCUL
    
                                ASALBASE[NPOSAUX,3] := NORDGRPD
    
                            EndIF
    
    
                            NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[1693,1] } )
    
                            IF ( NPOSAUX == 0 )
    
                                NORDGRPD++
    
                                AADD(ASALBASE,{ ACODFOL[1693,1] , NINTINSAL , NORDGRPD})
    
                            EndIF
    
    
                            IF ( NPOSAUX > 0 )
    
                                ASALBASE[NPOSAUX,2] := NINTINSAL
    
                                ASALBASE[NPOSAUX,3] := NORDGRPD
    
                            EndIF
    
    
                            NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[1717,1] } )
    
                            IF ( NPOSAUX == 0 )
    
                                NORDGRPD++
    
                                AADD(ASALBASE,{ ACODFOL[1717,1] , NADCCONF , NORDGRPD})
    
                            EndIF
    
    
                            IF ( NPOSAUX > 0 )
    
                                ASALBASE[NPOSAUX,2] := NADCCONF
    
                                ASALBASE[NPOSAUX,3] := NORDGRPD
    
                            EndIF
    
    
                            NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[1711,1] } )
    
                            IF ( NPOSAUX == 0 )
    
                                NORDGRPD++
    
                                AADD(ASALBASE,{ ACODFOL[1711,1] , NADCTRF , NORDGRPD})
    
                            EndIF
    
    
                            IF ( NPOSAUX > 0 )
    
                                ASALBASE[NPOSAUX,2] := NADCTRF
    
                                ASALBASE[NPOSAUX,3] := NORDGRPD
    
                            EndIF
    
    
                            IF ( ASCAN(APD,{ |X| X[1] = ACODFOL[NIDFER,1] .AND. X[9] # "D" } ) == 0 )
    
                                FGERAVERBA( ACODFOL[NIDFER,1] , ROUND( NFERVEP , 2) ,  IF ( CREFFER == "D" , GETMEMVAR("RG_DFERPRO") , INT( NDFERAVE / ATABFER[4] ) + 0.12), , ,"V","R")
    
                            EndIF
    
    
                            IF ( ASCAN(APD,{ |X| X[1] = ACODFOL[249,1] .AND. X[9] # "D" } ) == 0 )
    
                                FGERAVERBA(ACODFOL[249,1] , ROUND( NFERMEDP , 2 ) , IF ( CREFFER == "D" , NDFERAVE , INT( NDFERAVE / ATABFER[4] ) + 0.12), , ,"V","R")
    
                            EndIF
    
    
                            FGERAVERBA(ACODFOL[1705,1] , ROUND( NVALFERATS , 2 ) , IF ( CREFFER == "D" , NDFERAVE , INT( NDFERAVE / ATABFER[4] ) + 0.12), , ,"V","R")
    
                            FGERAVERBA(ACODFOL[1681,1] , ROUND( NVALFERPER , 2 ) , IF ( CREFFER == "D" , NDFERAVE , INT( NDFERAVE / ATABFER[4] ) + 0.12), , ,"V","R")
    
                            FGERAVERBA(ACODFOL[1693,1] , ROUND( NVALFERINS , 2 ) , IF ( CREFFER == "D" , NDFERAVE , INT( NDFERAVE / ATABFER[4] ) + 0.12), , ,"V","R")
    
                            FGERAVERBA(ACODFOL[1717,1] , ROUND( NVALFERCON , 2 ) , IF ( CREFFER == "D" , NDFERAVE , INT( NDFERAVE / ATABFER[4] ) + 0.12), , ,"V","R")
    
                            FGERAVERBA(ACODFOL[1711,1] , ROUND( NVALFERTRA , 2 ) , IF ( CREFFER == "D" , NDFERAVE , INT( NDFERAVE / ATABFER[4] ) + 0.12), , ,"V","R")
    
                            FGERAVERBA(ACODFOL[1687,1] , ROUND( NMDPERFP , 2 ) , IF ( CREFFER == "D" , NDFERAVE , INT( NDFERAVE / ATABFER[4] ) + 0.12), , ,"V","R")
    
                            FGERAVERBA(ACODFOL[1699,1] , ROUND( NMDINSFP , 2 ) , IF ( CREFFER == "D" , NDFERAVE , INT( NDFERAVE / ATABFER[4] ) + 0.12), , ,"V","R")
    
                        EndIF
    
    
                    EndIF
    
    
                EndIF
    
    
            EndIF
    
    
        EndIF    
 EndIf
    
        NINTINSAL := NSAVINS
    
        NINTPERCUL := NSAVPER
    
    End Sequence
Return
