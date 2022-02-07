User Function FERSIRTEC(cPdRot)
    Local LCALDIND := GetValType('L')
    Local NFALPRO := GetValType('N')
    Local LNOPERDPER := GetValType('L')
    Local NIDVENC := GetValType('N')
    Local NIDPROP := GetValType('N')
    Local CREFFER := GetValType('C')
    Local NSAVINS := GetValType('N')
    Local NSAVPER := GetValType('N')
    Local NBASFER := GetValType('N')
    Local NSALMESF := GetValType('N')
    Local NFERANT := GetValType('N')
    Local NCONT := GetValType('N')
    Local CSEQ := GetValType('C')
    Local NFERDAUX := GetValType('N')
    Local NFERSFAL := GetValType('N')
    Local NTIPFAL := GetValType('N')
    Local NPOSFAL := GetValType('N')
    Local NFERVAUX := GetValType('N')
    Local NFERMAUX := GetValType('N')
    Local NPOS := GetValType('N')
    Local NIDFERAUX := GetValType('N')
    Local NIDMEDAUX := GetValType('N')
    Local NPOSAUX := GetValType('N')
    
    cVerbaRot := cPdRot
    
    Begin Sequence
        If ( AbortProc() )
            Break
        EndIf
		
IF ( SRA->RA_ADCPERI = "2" )
    
        LDFERAVI := !(SRG->RG_DFERAVI == 0 .AND. NDIASAV > 0 .AND. CCOMPL == "S")
    
        LCALDIND := NDFERINDP > 0
    
        NFALPRO := 0
    
        LNOPERDPER := .T.
    
        NIDVENC := 086
    
        NIDPROP := 087
    
        CREFFER := GETMVRH("MV_REFFER",NIL,"A")
    
        NSAVINS := NINTINSAL
    
        NSAVPER := NINTPERCUL
    
        NINTINSAL := IF( TYPE('NINTRESINS') <> "U" .AND. NINTRESINS > 0, NINTRESINS, NINTINSAL )
    
        NINTPERCUL := IF( TYPE('NINTRESPER') <> "U" .AND. NINTRESPER > 0, NINTRESPER, NINTPERCUL )
    
        IF ( SRA->RA_TPCONTR != "3" )
    
            IF ( SRA->RA_CATFUNC $ "E*G" )
    
                NIDVENC := 1424
    
                NIDPROP := 1425
    
            EndIF
    
    
            //# VERIFICA SE CALCULA FERIAS A PARTIR DA CONFIGURACAO DO CAMPO 'FERVENCIDA' DA TABELA S043
    
            IF ( ( LEN(AINCRES) < 20 ) .OR. !( AINCRES[20] == "N" ) )
    
                IF ( ( GETMEMVAR("RG_DFERVEN") > 0 .AND. !EMPTY(ACODFOL[NIDVENC,1]) ) .OR. LCALDIND )
    
                    IF ( BUSCATRP( SRA->RA_FILIAL + SRA->RA_MAT + "2" + "998" + "9698", @NFALPRO ) )
    
                        LNOPERDPER := IF( NFALPRO <= 32, .T., .F. )
    
                    EndIF
    
    
                    IF ( !LDFERAVI )
    
                        IF ( ( ( GETMEMVAR("RG_DFERPRO") == 0 .AND. LNOPERDPER ) .OR. ( ( GETMEMVAR("RG_DFERPRO") == NDFERIND ) .AND. NFALPRO <= 5 ) ) .AND. NDFERIND > 0 )
    
                            IF ( GETMEMVAR("RG_DFERPRO") == 0 .AND. LEN(APERFERIAS) > 0 )
    
                                APERFERIAS[LEN(APERFERIAS),3] -= NDFERIND
    
                            EndIF
    
    
                            IF ( EMPTY(ACODFOL[252,1]) )
    
                                NBASFER := SALARIO + NINTPERCUL - ( FBUSCAPD("115",'V',,,)*0.30) - ( FBUSCAPD("140,147,148",'V',,,)*0.30)  + NADTSERV + NINTINSAL + NADCCONF + NADCTRF + NGCOMISFV + NMEDFERV + NGTAREFFV
    
                                IF ( SRA->RA_CATFUNC == "H" .AND. LHOJORVA )
    
                                    NBASFER := NSALMESFV + NINTPERCUL - ( FBUSCAPD("115",'V',,,)*0.30)- ( FBUSCAPD("140,147,148",'V',,,)*0.30)  + NADTSERV + NINTINSAL + NADCCONF + NADCTRF + NGCOMISFV + NMEDFERV + NGTAREFFV
    
                                EndIF
    
    
                                NFERIND := (((NBASFER) / P_QTDIAMES) * NDFERIND)
    
                            EndIF
    
    
                            IF ( !EMPTY(ACODFOL[252,1]) )
    
                                NBASFER := SALARIO + NINTPERCUL - ( FBUSCAPD("115",'V',,,)*0.30)- ( FBUSCAPD("140,147,148",'V',,,)*0.30)  + NADTSERV + NINTINSAL + NADCCONF + NADCTRF + NGCOMISFV + NGTAREFFV
    
                                IF ( SRA->RA_CATFUNC == "H" .AND. LHOJORVA )
    
                                    NBASFER := NSALMESF + NINTPERCUL - ( FBUSCAPD("115",'V',,,)*0.30) - ( FBUSCAPD("140,147,148",'V',,,)*0.30)  + NADTSERV + NINTINSAL + NADCCONF + NADCTRF + NGCOMISFV + NGTAREFFV
    
                                EndIF
    
    
                                NFERIND := (((NBASFER) / P_QTDIAMES) * NDFERIND)
    
                                NFERMEDI := ( ( NMEDFERV / P_QTDIAMES ) * NDFERIND)
    
                            EndIF
    
    
                        EndIF
    
    
                    EndIF
    
    
                    IF ( LEN(APERFERIAS) > 0 )
    
                        NFERANT := IF( EMPTY(NDFERANT) , NDIASANT , NDFERANT )
    
                        NCONT := 1
    
                        While ( NCONT <= LEN(APERFERIAS) )
                                            IF ( AbortProc() )
                                                                Break
                                            EndIF
    
    
                            IF ( APERFERIAS[NCONT,3] > 0 )
    
                                CSEQ := IF(NCONT=1," ",CVALTOCHAR(NCONT-1))
    
                                NFERDAUX := APERFERIAS[NCONT,3]
    
                                NFERSFAL := NFERDAUX
    
                                IF ( !EMPTY(AFALTASPER) )
    
                                    NTIPFAL := NCONT + IF(NCONT>1,3,0)
    
                                    NPOSFAL := ASCAN(AFALTASPER,{|X| X[1] = CVALTOCHAR(NTIPFAL)})
    
                                    IF ( NPOSFAL > 0 )
    
                                        NFERDAUX -= AFALTASPER[NPOSFAL,2]
    
                                    EndIF
    
    
                                EndIF
    
    
                                IF ( NFERANT > 0 )
    
                                    NFERDAUX := MAX(NFERDAUX-NFERANT,0)
    
                                    NFERSFAL := MAX(NFERSFAL-NFERANT,0)
    
                                    NFERANT := 0
    
                                EndIF
    
    
                                NFERVAUX := (((SALARIO + NINTPERCUL - ( FBUSCAPD("115",'V',,,)*0.30)- ( FBUSCAPD("140,147,148",'V',,,)*0.30) + NADTSERV + NINTINSAL + NADCCONF + NADCTRF + NGCOMISFV+NGTAREFFV) / P_QTDIAMES) * NFERDAUX)
    
                                IF ( SRA->RA_CATFUNC == "H" .AND. LHOJORVA )
    
                                    NFERVAUX := (((NSALMESFV + NINTPERCUL - ( FBUSCAPD("115",'V',,,)*0.30)- ( FBUSCAPD("140,147,148",'V',,,)*0.30) + NADTSERV + NINTINSAL + NADCCONF + NADCTRF + NGCOMISFV+NGTAREFFV) / P_QTDIAMES) * NFERDAUX)
    
                                EndIF
    
    
                                NFERMAUX := 0
    
                                NPOS := ASCAN(APERMEDIA, {|X| X[2] = MESANO(APERFERIAS[NCONT,1])})
    
                                IF ( NPOS > 0 )
    
                                    NFERMAUX += ((APERMEDIA[NPOS,4] / P_QTDIAMES) * NFERDAUX)
    
                                EndIF
    
    
                                IF ( NPOS == 0 )
    
                                    IF ( NMEDFERV > 0 .AND. NFERDAUX > 0 )
    
                                        NFERMAUX +=  ((NMEDFERV / P_QTDIAMES) * NFERDAUX)
    
                                    EndIF
    
    
                                EndIF
    
    
                                IF ( !LDFERAVI )
    
                                    IF ( NDFERIND > 0 .AND. (APERFERIAS[NCONT,3] + NDFERIND) >= 30 .AND. NFERSFAL < 30 .AND. APERFERIAS[NCONT,2] > DDATADEM1 )
    
                                        NIDFERAUX := NIDPROP
    
                                        NIDMEDAUX := 249
    
                                    EndIF
    
    
                                    IF ( !(NDFERIND > 0 .AND. (APERFERIAS[NCONT,3] + NDFERIND) >= 30 .AND. NFERSFAL < 30 .AND. APERFERIAS[NCONT,2] > DDATADEM1) )
    
                                        NIDFERAUX := NIDVENC
    
                                        NIDMEDAUX := 248
    
                                    EndIF
    
    
                                EndIF
    
    
                                IF ( LDFERAVI )
    
                                    NIDFERAUX := NIDVENC
    
                                    NIDMEDAUX := 248
    
                                EndIF
    
    
                                IF ( EMPTY(ACODFOL[248,1]) )
    
                                    NFERVAUX += NFERMAUX
    
                                    IF ( ASCAN(APD,{ |X| X[1] == ACODFOL[NIDFERAUX,1] .AND. X[9] # "D" .AND. X[11] == CSEQ } ) == 0 )
    
                                        FGERAVERBA(ACODFOL[NIDFERAUX,1],ROUND(NFERVAUX,2),IF(CREFFER="D",NFERSFAL,INT(NFERSFAL/ATABFER[4])+0.12), , ,"V","R", , , , , ,, CSEQ, DTOS(APERFERIAS[NCONT,1]) + " - " + DTOS(APERFERIAS[NCONT,2]))
    
                                    EndIF
    
    
                                EndIF
    
    
                                IF ( !EMPTY(ACODFOL[248,1]) )
    
                                    IF ( ASCAN(APD,{ |X| X[1] == ACODFOL[NIDFERAUX,1] .AND. X[9] # "D" .AND. X[11] == CSEQ } ) == 0 )
    
                                        FGERAVERBA( ACODFOL[NIDFERAUX,1] , ROUND(NFERVAUX,2) , IF(CREFFER="D",NFERSFAL , INT(NFERSFAL/ATABFER[4])+0.12) , , ,"V","R", , , , , ,, CSEQ , DTOS(APERFERIAS[NCONT,1]) + " - " + DTOS(APERFERIAS[NCONT,2]))
    
                                    EndIF
    
    
                                    IF ( ASCAN(APD,{ |X| X[1] == ACODFOL[NIDMEDAUX,1] .AND. X[9] # "D" .AND. X[11] == CSEQ } ) == 0 )
    
                                        FGERAVERBA(ACODFOL[NIDMEDAUX,1],ROUND(NFERMAUX,2),IF(CREFFER="D",NFERSFAL,INT(NFERSFAL/ATABFER[4])+0.12), , ,"V","R", , , , , ,, CSEQ, DTOS(APERFERIAS[NCONT,1]) + " - " + DTOS(APERFERIAS[NCONT,2]))
    
                                    EndIF
    
    
                                EndIF
    
    
                                NFERVEV += NFERVAUX
    
                                NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[NIDFERAUX,1] } )
    
                                IF ( NPOSAUX == 0 )
    
                                    NORDGRPD++
    
                                    AADD(ASALBASE,{ACODFOL[NIDFERAUX,1] , NBASFER , NORDGRPD})
    
                                EndIF
    
    
                                IF ( NPOSAUX > 0 )
    
                                    ASALBASE[NPOSAUX,2] := NBASFER
    
                                    ASALBASE[NPOSAUX,3] := NORDGRPD
    
                                EndIF
    
    
                            EndIF
    
    
                            NCONT++
    
    
                        End
    
                    EndIF
    
    
                EndIF
    
    
            EndIF
    
    
        EndIF
    
    
        NINTINSAL := NSAVINS
    
            IF ( SRA->RA_CATFUNC == "H" .AND. LHOJORVA )
    
                NFERVAUX := (((NSALMESF) / P_QTDIAMES) * NFERDAUX)
    
                    IF ( SRA->RA_CATFUNC == "H" .AND. LHOJORVA )
    
                        NBASFER := NSALMESF
    
                    EndIF
    
    
            EndIF
Else

        LDFERAVI := !(SRG->RG_DFERAVI == 0 .AND. NDIASAV > 0 .AND. CCOMPL == "S")
    
        LCALDIND := NDFERINDP > 0
    
        NFALPRO := 0
    
        LNOPERDPER := .T.
    
        NIDVENC := 086
    
        NIDPROP := 087
    
        CREFFER := GETMVRH("MV_REFFER",NIL,"A")
    
        NSAVINS := NINTINSAL
    
        NSAVPER := NINTPERCUL
    
        NINTINSAL := IF( TYPE('NINTRESINS') <> "U" .AND. NINTRESINS > 0, NINTRESINS, NINTINSAL )
    
        NINTPERCUL := IF( TYPE('NINTRESPER') <> "U" .AND. NINTRESPER > 0, NINTRESPER, NINTPERCUL )
    
        LADCSRESC := LEN(ACODFOL) >= 1680 .AND. !EMPTY(ACODFOL[1680,1])
    
        NMEDINSFV := IF( TYPE("NMEDINSFV") <> "U",NMEDINSFV, 0)
    
        NMEDPERFV := IF( TYPE("NMEDPERFV") <> "U",NMEDPERFV, 0)
    
        NVALFERATS := 0
    
        NVALFERPER := 0
    
        NVALFERINS := 0
    
        NVALFERCON := 0
    
        NVALFERTRA := 0
    
        IF ( SRA->RA_TPCONTR != "3" )
    
            IF ( SRA->RA_CATFUNC $ "E*G" )
    
                NIDVENC := 1424
    
                NIDPROP := 1425
    
            EndIF
    
    
            //# VERIFICA SE CALCULA FERIAS A PARTIR DA CONFIGURACAO DO CAMPO 'FERVENCIDA' DA TABELA S043
    
            IF ( ( LEN(AINCRES) < 20 ) .OR. !( AINCRES[20] == "N" ) )
    
                IF ( ( GETMEMVAR("RG_DFERVEN") > 0 .AND. !EMPTY(ACODFOL[NIDVENC,1]) ) .OR. LCALDIND )
    
                    IF ( BUSCATRP( SRA->RA_FILIAL + SRA->RA_MAT + "2" + "998" + "9698", @NFALPRO ) )
    
                        LNOPERDPER := IF( NFALPRO <= 32, .T., .F. )
    
                    EndIF
    
    
                    IF ( !LDFERAVI )
    
                        IF ( ( ( GETMEMVAR("RG_DFERPRO") == 0 .AND. LNOPERDPER ) .OR. ( ( GETMEMVAR("RG_DFERPRO") == NDFERIND ) .AND. NFALPRO <= 5 ) ) .AND. NDFERIND > 0 )
    
                            IF ( GETMEMVAR("RG_DFERPRO") == 0 .AND. LEN(APERFERIAS) > 0 )
    
                                APERFERIAS[LEN(APERFERIAS),3] -= NDFERIND
    
                            EndIF
    
    
                            IF ( EMPTY(ACODFOL[252,1]) )
    
                                NBASFER := SALARIO + NADTSERV - ( FBUSCAPD("115",'V',,,)*0.30) - ( FBUSCAPD("140,147,148",'V',,,)*0.30)+ NINTPERCUL + NINTINSAL + NADCCONF + NADCTRF + NGCOMISFV + NMEDFERV + NGTAREFFV + FINCSEMID("0086")
    
                                IF ( SRA->RA_CATFUNC == "H" .AND. LHOJORVA )
    
                                    NBASFER := NSALMESFV + NADTSERV - ( FBUSCAPD("115",'V',,,)*0.30)- ( FBUSCAPD("140,147,148",'V',,,)*0.30) + NINTPERCUL + NINTINSAL + NADCCONF + NADCTRF + NGCOMISFV + NMEDFERV + NGTAREFFV
    
                                EndIF
    
    
                                NFERIND := (((NBASFER) / P_QTDIAMES) * NDFERIND)
    
                            EndIF
    
    
                            IF ( !EMPTY(ACODFOL[252,1]) )
    
                                NBASFER := SALARIO + NADTSERV + NINTPERCUL - ( FBUSCAPD("115",'V',,,)*0.30)- ( FBUSCAPD("140,147,148",'V',,,)*0.30) + NINTINSAL + NADCCONF + NADCTRF + NGCOMISFV + NGTAREFFV + FINCSEMID("0086")
    
                                IF ( SRA->RA_CATFUNC == "H" .AND. LHOJORVA )
    
                                    NBASFER := NSALMESF + NADTSERV - ( FBUSCAPD("115",'V',,,)*0.30)- ( FBUSCAPD("140,147,148",'V',,,)*0.30) + NINTPERCUL + NINTINSAL + NADCCONF + NADCTRF + NGCOMISFV + NGTAREFFV
    
                                EndIF
    
    
                                NFERIND := (((NBASFER) / P_QTDIAMES) * NDFERIND)
    
                                NFERMEDI := ( ( NMEDFERV / P_QTDIAMES ) * NDFERIND)
    
                            EndIF
    
    
                        EndIF
    
    
                    EndIF
    
    
                    IF ( LEN(APERFERIAS) > 0 )
    
                        NFERANT := IF( EMPTY(NDFERANT) , NDIASANT , NDFERANT )
    
                        NCONT := 1
    
                        While ( NCONT <= LEN(APERFERIAS) )
                                            IF ( AbortProc() )
                                                                Break
                                            EndIF
    
    
                            IF ( APERFERIAS[NCONT,3] > 0 )
    
                                CSEQ := IF(NCONT=1," ",CVALTOCHAR(NCONT-1))
    
                                NFERDAUX := APERFERIAS[NCONT,3]
    
                                NFERSFAL := NFERDAUX
    
                                IF ( !EMPTY(AFALTASPER) )
    
                                    NTIPFAL := NCONT + IF(NCONT>1,3,0)
    
                                    NPOSFAL := ASCAN(AFALTASPER,{|X| X[1] = CVALTOCHAR(NTIPFAL)})
    
                                    IF ( NPOSFAL > 0 )
    
                                        NFERDAUX -= AFALTASPER[NPOSFAL,2]
    
                                    EndIF
    
    
                                EndIF
    
    
                                IF ( NFERANT > 0 )
    
                                    NFERDAUX := MAX(NFERDAUX-NFERANT,0)
    
                                    NFERSFAL := MAX(NFERSFAL-NFERANT,0)
    
                                    NFERANT := 0
    
                                EndIF
    
    
                                IF ( LADCSRESC .AND. ( CCOMPL <> "S" .OR. LTEMIDRESC) )
    
                                    NFERVAUX := (((SALARIO + NGCOMISFV+NGTAREFFV +FINCSEMID("0086") ) / P_QTDIAMES) * NFERDAUX)
    
                                    NVALFERATS := (NADTSERV / P_QTDIAMES) * NFERDAUX
    
                                    NVALFERPER := (NINTPERCUL / P_QTDIAMES) * NFERDAUX
    
                                    NVALFERINS := (NINTINSAL / P_QTDIAMES) * NFERDAUX
    
                                    NVALFERCON := (NADCCONF / P_QTDIAMES) * NFERDAUX
    
                                    NVALFERTRA := (NADCTRF / P_QTDIAMES) * NFERDAUX
    
                                    NBASFER := SALARIO + NGCOMISFV + NGTAREFFV + FINCSEMID("0086")
    
                                    IF ( SRA->RA_CATFUNC == "H" .AND. LHOJORVA )
    
                                        NFERVAUX := (((NSALMESFV + NGCOMISFV+NGTAREFFV) / P_QTDIAMES) * NFERDAUX)
    
                                    EndIF
    
    
                                EndIF
    
    
                                IF ( !LADCSRESC .OR. (CCOMPL == "S" .AND. !LTEMIDRESC) )
    
                                    NFERVAUX := (((SALARIO + NADTSERV - ( FBUSCAPD("115",'V',,,)*0.30)- ( FBUSCAPD("140,147,148",'V',,,)*0.30) + NINTPERCUL + NINTINSAL + NADCCONF + NADCTRF + NGCOMISFV+NGTAREFFV + FINCSEMID("0086")) / P_QTDIAMES) * NFERDAUX)
    
                                    IF ( SRA->RA_CATFUNC == "H" .AND. LHOJORVA )
    
                                        NFERVAUX := (((NSALMESFV + NADTSERV - ( FBUSCAPD("115",'V',,,)*0.30)- ( FBUSCAPD("140,147,148",'V',,,)*0.30) + NINTPERCUL + NINTINSAL + NADCCONF + NADCTRF + NGCOMISFV+NGTAREFFV) / P_QTDIAMES) * NFERDAUX)
    
                                    EndIF
    
    
                                EndIF
    
    
                                NFERMAUX := 0
    
                                NPOS := ASCAN(APERMEDIA, {|X| X[2] = MESANO(APERFERIAS[NCONT,1])})
    
                                IF ( NPOS > 0 )
    
                                    NFERMAUX += ((APERMEDIA[NPOS,4] / P_QTDIAMES) * NFERDAUX)
    
                                EndIF
    
    
                                IF ( NPOS == 0 )
    
                                    IF ( NMEDFERV > 0 .AND. NFERDAUX > 0 )
    
                                        NFERMAUX +=  ((NMEDFERV / P_QTDIAMES) * NFERDAUX)
    
                                    EndIF
    
    
                                EndIF
    
    
                                IF ( !LDFERAVI )
    
                                    IF ( NDFERIND > 0 .AND. (APERFERIAS[NCONT,3] + NDFERIND) >= 30 .AND. NFERSFAL < 30 .AND. APERFERIAS[NCONT,2] > DDATADEM1 )
    
                                        NIDFERAUX := NIDPROP
    
                                        NIDMEDAUX := 249
    
                                    EndIF
    
    
                                    IF ( !(NDFERIND > 0 .AND. (APERFERIAS[NCONT,3] + NDFERIND) >= 30 .AND. NFERSFAL < 30 .AND. APERFERIAS[NCONT,2] > DDATADEM1) )
    
                                        NIDFERAUX := NIDVENC
    
                                        NIDMEDAUX := 248
    
                                    EndIF
    
    
                                EndIF
    
    
                                IF ( LDFERAVI )
    
                                    NIDFERAUX := NIDVENC
    
                                    NIDMEDAUX := 248
    
                                EndIF
    
    
                                NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[NIDFERAUX,1] } )
    
                                IF ( NPOSAUX > 0 )
    
                                    ASALBASE[NPOSAUX,2] := NFERVAUX
    
                                    ASALBASE[NPOSAUX,3] := NORDGRPD
    
                                EndIF
    
    
                                IF ( NPOSAUX == 0 )
    
                                    NORDGRPD++
    
                                    AADD(ASALBASE,{ACODFOL[NIDFERAUX,1] , NFERVAUX , NORDGRPD})
    
                                EndIF
    
    
                                IF ( EMPTY(ACODFOL[248,1]) )
    
                                    IF ( LADCSRESC .AND. ( CCOMPL <> "S" .OR. LTEMIDRESC) )
    
                                        NFERVAUX += NFERMAUX
    
                                        NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[1704,1] } )
    
                                        IF ( NPOSAUX > 0 )
    
                                            ASALBASE[NPOSAUX,2] := NADTSERV
    
                                            ASALBASE[NPOSAUX,3] := NORDGRPD
    
                                        EndIF
    
    
                                        IF ( NPOSAUX == 0 )
    
                                            NORDGRPD++
    
                                            AADD(ASALBASE,{ACODFOL[1704,1] , NADTSERV , NORDGRPD})
    
                                        EndIF
    
    
                                        NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[1680,1] } )
    
                                        IF ( NPOSAUX > 0 )
    
                                            ASALBASE[NPOSAUX,2] := NINTPERCUL
    
                                            ASALBASE[NPOSAUX,3] := NORDGRPD
    
                                        EndIF
    
    
                                        IF ( NPOSAUX == 0 )
    
                                            NORDGRPD++
    
                                            AADD(ASALBASE,{ACODFOL[1680,1] , NINTPERCUL , NORDGRPD})
    
                                        EndIF
    
    
                                        NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[1692,1] } )
    
                                        IF ( NPOSAUX > 0 )
    
                                            ASALBASE[NPOSAUX,2] := NINTINSAL
    
                                            ASALBASE[NPOSAUX,3] := NORDGRPD
    
                                        EndIF
    
    
                                        IF ( NPOSAUX == 0 )
    
                                            NORDGRPD++
    
                                            AADD(ASALBASE,{ACODFOL[1692,1] , NINTINSAL , NORDGRPD})
    
                                        EndIF
    
    
                                        NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[1716,1] } )
    
                                        IF ( NPOSAUX > 0 )
    
                                            ASALBASE[NPOSAUX,2] := NADCCONF
    
                                            ASALBASE[NPOSAUX,3] := NORDGRPD
    
                                        EndIF
    
    
                                        IF ( NPOSAUX == 0 )
    
                                            NORDGRPD++
    
                                            AADD(ASALBASE,{ACODFOL[1716,1] , NADCCONF , NORDGRPD})
    
                                        EndIF
    
    
                                        NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[1710,1] } )
    
                                        IF ( NPOSAUX > 0 )
    
                                            ASALBASE[NPOSAUX,2] := NADCTRF
    
                                            ASALBASE[NPOSAUX,3] := NORDGRPD
    
                                        EndIF
    
    
                                        IF ( NPOSAUX == 0 )
    
                                            NORDGRPD++
    
                                            AADD(ASALBASE,{ACODFOL[1710,1] , NADCTRF, NORDGRPD})
    
                                        EndIF
    
    
                                        FGERAVERBA(ACODFOL[NIDFERAUX,1],ROUND(NFERVAUX,2),IF(CREFFER="D",NFERDAUX,INT(NFERDAUX/ATABFER[4])+0.12), , ,"V","R", , , , , ,, CSEQ, DTOS(APERFERIAS[NCONT,1]) + " - " + DTOS(APERFERIAS[NCONT,2]))
    
                                        FGERAVERBA(ACODFOL[1704,1],ROUND(NVALFERATS,2),IF(CREFFER="D",NFERDAUX,INT(NFERDAUX/ATABFER[4])+0.12), , ,"V","R", , , , , ,, CSEQ, DTOS(APERFERIAS[NCONT,1]) + " - " + DTOS(APERFERIAS[NCONT,2]))
    
                                        FGERAVERBA(ACODFOL[1680,1],ROUND(NVALFERPER,2),IF(CREFFER="D",NFERDAUX,INT(NFERDAUX/ATABFER[4])+0.12), , ,"V","R", , , , , ,, CSEQ, DTOS(APERFERIAS[NCONT,1]) + " - " + DTOS(APERFERIAS[NCONT,2]))
    
                                        FGERAVERBA(ACODFOL[1692,1],ROUND(NVALFERINS,2),IF(CREFFER="D",NFERDAUX,INT(NFERDAUX/ATABFER[4])+0.12), , ,"V","R", , , , , ,, CSEQ, DTOS(APERFERIAS[NCONT,1]) + " - " + DTOS(APERFERIAS[NCONT,2]))
    
                                        FGERAVERBA(ACODFOL[1716,1],ROUND(NVALFERCON,2),IF(CREFFER="D",NFERDAUX,INT(NFERDAUX/ATABFER[4])+0.12), , ,"V","R", , , , , ,, CSEQ, DTOS(APERFERIAS[NCONT,1]) + " - " + DTOS(APERFERIAS[NCONT,2]))
    
                                        FGERAVERBA(ACODFOL[1710,1],ROUND(NVALFERTRA,2),IF(CREFFER="D",NFERDAUX,INT(NFERDAUX/ATABFER[4])+0.12), , ,"V","R", , , , , ,, CSEQ, DTOS(APERFERIAS[NCONT,1]) + " - " + DTOS(APERFERIAS[NCONT,2]))
    
                                        FGERAVERBA(ACODFOL[1686,1],ROUND(NMEDPERFV,2),IF(CREFFER="D",NFERDAUX,INT(NFERDAUX/ATABFER[4])+0.12), , ,"V","R", , , , , ,, CSEQ, DTOS(APERFERIAS[NCONT,1]) + " - " + DTOS(APERFERIAS[NCONT,2]))
    
                                        FGERAVERBA(ACODFOL[1698,1],ROUND(NMEDINSFV,2),IF(CREFFER="D",NFERDAUX,INT(NFERDAUX/ATABFER[4])+0.12), , ,"V","R", , , , , ,, CSEQ, DTOS(APERFERIAS[NCONT,1]) + " - " + DTOS(APERFERIAS[NCONT,2]))
    
                                    EndIF
    
    
                                    IF ( !LADCSRESC .OR. (CCOMPL == "S" .AND. !LTEMIDRESC) )
    
                                        NFERVAUX += NFERMAUX
    
                                        IF ( ASCAN(APD,{ |X| X[1] == ACODFOL[NIDFERAUX,1] .AND. X[9] # "D" .AND. X[11] == CSEQ } ) == 0 )
    
                                            FGERAVERBA(ACODFOL[NIDFERAUX,1],ROUND(NFERVAUX,2),IF(CREFFER="D",NFERDAUX,INT(NFERDAUX/ATABFER[4])+0.12), , ,"V","R", , , , , ,, CSEQ, DTOS(APERFERIAS[NCONT,1]) + " - " + DTOS(APERFERIAS[NCONT,2]))
    
                                        EndIF
    
    
                                    EndIF
    
    
                                EndIF
    
    
                                IF ( !EMPTY(ACODFOL[248,1]) )
    
                                    IF ( !LADCSRESC .OR. (CCOMPL == "S" .AND. !LTEMIDRESC) )
    
                                        IF ( ASCAN(APD,{ |X| X[1] == ACODFOL[NIDMEDAUX,1] .AND. X[9] # "D" .AND. X[11] == CSEQ } ) == 0 )
    
                                            FGERAVERBA(ACODFOL[NIDMEDAUX,1],ROUND(NFERMAUX,2),IF(CREFFER="D",NFERDAUX,INT(NFERDAUX/ATABFER[4])+0.12), , ,"V","R", , , , , ,, CSEQ, DTOS(APERFERIAS[NCONT,1]) + " - " + DTOS(APERFERIAS[NCONT,2]))
    
                                        EndIF
    
    
                                        IF ( ASCAN(APD,{ |X| X[1] == ACODFOL[NIDFERAUX,1] .AND. X[9] # "D" .AND. X[11] == CSEQ } ) == 0 )
    
                                            FGERAVERBA( ACODFOL[NIDFERAUX,1] , ROUND(NFERVAUX,2) , IF(CREFFER="D",NFERDAUX , INT(NFERDAUX/ATABFER[4])+0.12) , , ,"V","R", , , , , ,, CSEQ , DTOS(APERFERIAS[NCONT,1]) + " - " + DTOS(APERFERIAS[NCONT,2]))
    
                                        EndIF
    
    
                                    EndIF
    
    
                                    IF ( LADCSRESC .AND. ( CCOMPL <> "S" .OR. LTEMIDRESC) )
    
                                        NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[1704,1] } )
    
                                        IF ( NPOSAUX > 0 )
    
                                            ASALBASE[NPOSAUX,2] := NADTSERV
    
                                                AADD(ASALBASE,{ACODFOL[NIDFERAUX,1] , NBASFER , NORDGRPD})
    
                                                    ASALBASE[NPOSAUX,3] := NORDGRPD
    
                                            ASALBASE[NPOSAUX,3] := NORDGRPD
    
                                        EndIF
    
    
                                        IF ( NPOSAUX == 0 )
    
                                            NORDGRPD++
    
                                            AADD(ASALBASE,{ACODFOL[1704,1],NADTSERV,NORDGRPD})
    
                                        EndIF
    
    
                                        NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[1680,1] } )
    
                                        IF ( NPOSAUX == 0 )
    
                                            NORDGRPD++
    
                                            AADD(ASALBASE,{ACODFOL[1680,1] , NINTPERCUL , NORDGRPD})
    
                                        EndIF
    
    
                                        IF ( NPOSAUX > 0 )
    
                                            ASALBASE[NPOSAUX,2] := NINTPERCUL
    
                                            ASALBASE[NPOSAUX,3] := NORDGRPD
    
                                        EndIF
    
    
                                        NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[1692,1] } )
    
                                        IF ( NPOSAUX > 0 )
    
                                            ASALBASE[NPOSAUX,2] := NINTINSAL
    
                                            ASALBASE[NPOSAUX,3] := NORDGRPD
    
                                        EndIF
    
    
                                        IF ( NPOSAUX == 0 )
    
                                            NORDGRPD++
    
                                            AADD(ASALBASE,{ACODFOL[1692,1] , NINTINSAL , NORDGRPD})
    
                                        EndIF
    
    
                                        NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[1716,1] } )
    
                                        IF ( NPOSAUX > 0 )
    
                                            ASALBASE[NPOSAUX,2] := NADCCONF
    
                                            ASALBASE[NPOSAUX,3] := NORDGRPD
    
                                        EndIF
    
    
                                        IF ( NPOSAUX == 0 )
    
                                            NORDGRPD++
    
                                            AADD(ASALBASE,{ACODFOL[1716,1] , NADCCONF , NORDGRPD})
    
                                        EndIF
    
    
                                        NPOSAUX := ASCAN(ASALBASE, { |X| X[1] == ACODFOL[1710,1] } )
    
                                        IF ( NPOSAUX > 0 )
    
                                            ASALBASE[NPOSAUX,2] := NADCTRF
    
                                            ASALBASE[NPOSAUX,3] := NORDGRPD
    
                                        EndIF
    
    
                                        IF ( NPOSAUX == 0 )
    
                                            NORDGRPD++
    
                                            AADD(ASALBASE,{ACODFOL[1710,1] , NADCTRF, NORDGRPD})
    
                                        EndIF
    
    
                                        IF ( ASCAN(APD,{ |X| X[1] == ACODFOL[NIDFERAUX,1] .AND. X[9] # "D" .AND. X[11] == CSEQ } ) == 0 )
    
                                            FGERAVERBA( ACODFOL[NIDFERAUX,1] , ROUND(NFERVAUX,2) , IF(CREFFER="D",NFERDAUX , INT(NFERDAUX/ATABFER[4])+0.12) , , ,"V","R", , , , , ,, CSEQ , DTOS(APERFERIAS[NCONT,1]) + " - " + DTOS(APERFERIAS[NCONT,2]))
    
                                        EndIF
    
    
                                        IF ( ASCAN(APD,{ |X| X[1] == ACODFOL[NIDMEDAUX,1] .AND. X[9] # "D" .AND. X[11] == CSEQ } ) == 0 )
    
                                            FGERAVERBA(ACODFOL[NIDMEDAUX,1],ROUND(NFERMAUX,2),IF(CREFFER="D",NFERDAUX,INT(NFERDAUX/ATABFER[4])+0.12), , ,"V","R", , , , , ,, CSEQ, DTOS(APERFERIAS[NCONT,1]) + " - " + DTOS(APERFERIAS[NCONT,2]))
    
                                        EndIF
    
    
                                        FGERAVERBA(ACODFOL[1704,1],ROUND(NVALFERATS,2),IF(CREFFER="D",NFERDAUX,INT(NFERDAUX/ATABFER[4])+0.12), , ,"V","R", , , , , ,, CSEQ, DTOS(APERFERIAS[NCONT,1]) + " - " + DTOS(APERFERIAS[NCONT,2]))
    
                                        FGERAVERBA(ACODFOL[1680,1],ROUND(NVALFERPER,2),IF(CREFFER="D",NFERDAUX,INT(NFERDAUX/ATABFER[4])+0.12), , ,"V","R", , , , , ,, CSEQ, DTOS(APERFERIAS[NCONT,1]) + " - " + DTOS(APERFERIAS[NCONT,2]))
    
                                        FGERAVERBA(ACODFOL[1692,1],ROUND(NVALFERINS,2),IF(CREFFER="D",NFERDAUX,INT(NFERDAUX/ATABFER[4])+0.12), , ,"V","R", , , , , ,, CSEQ, DTOS(APERFERIAS[NCONT,1]) + " - " + DTOS(APERFERIAS[NCONT,2]))
    
                                        FGERAVERBA(ACODFOL[1716,1],ROUND(NVALFERCON,2),IF(CREFFER="D",NFERDAUX,INT(NFERDAUX/ATABFER[4])+0.12), , ,"V","R", , , , , ,, CSEQ, DTOS(APERFERIAS[NCONT,1]) + " - " + DTOS(APERFERIAS[NCONT,2]))
    
                                        FGERAVERBA(ACODFOL[1710,1],ROUND(NVALFERTRA,2),IF(CREFFER="D",NFERDAUX,INT(NFERDAUX/ATABFER[4])+0.12), , ,"V","R", , , , , ,, CSEQ, DTOS(APERFERIAS[NCONT,1]) + " - " + DTOS(APERFERIAS[NCONT,2]))
    
                                        FGERAVERBA(ACODFOL[1686,1],ROUND(NMEDPERFV,2),IF(CREFFER="D",NFERDAUX,INT(NFERDAUX/ATABFER[4])+0.12), , ,"V","R", , , , , ,, CSEQ, DTOS(APERFERIAS[NCONT,1]) + " - " + DTOS(APERFERIAS[NCONT,2]))
    
                                        FGERAVERBA(ACODFOL[1698,1],ROUND(NMEDINSFV,2),IF(CREFFER="D",NFERDAUX,INT(NFERDAUX/ATABFER[4])+0.12), , ,"V","R", , , , , ,, CSEQ, DTOS(APERFERIAS[NCONT,1]) + " - " + DTOS(APERFERIAS[NCONT,2]))
    
                                    EndIF
    
    
                                EndIF
    
    
                                IF ( !LADCSRESC .OR. (CCOMPL == "S" .AND. !LTEMIDRESC) )
    
                                    NFERVEV += NFERVAUX
    
                                EndIF
    
    
                                IF ( LADCSRESC .AND. ( CCOMPL <> "S" .OR. LTEMIDRESC) )
    
                                    NFERVEV += (NFERVAUX + NVALFERATS + NVALFERPER + NVALFERINS + NVALFERCON + NVALFERTRA)
    
                                EndIF
    
    
                            EndIF
    
    
                            NCONT++
    
    
                        End
    
                    EndIF
    
    
                EndIF
    
    
            EndIF
    
    
        EndIF
    
    
        NINTINSAL := NSAVINS
    
            IF ( SRA->RA_CATFUNC == "H" .AND. LHOJORVA )
    
                NFERVAUX := (((NSALMESF) / P_QTDIAMES) * NFERDAUX)
    
                    IF ( SRA->RA_CATFUNC == "H" .AND. LHOJORVA )
    
                        AADD(ASALBASE,{ACODFOL[NIDFERAUX,1] , NBASFER , NORDGRPD})
    
                        NBASFER := NSALMESF
    
                    EndIF
    
    
            EndIF  
EndIF    
        NINTPERCUL := NSAVPER
    
    End Sequence
Return
